#include <mips/regdef.h>
#include <sys/syscall.h>

#ifndef 	fp
#define	fp	$fp
#endif

#define DISTINTOS 			(0)
#define IGUALES				(1)

#para caracteres ascii
#define	NUEVA_LINEA			(10)
#define	MENOR				(60) 
#define	BINVERT				(92)

#define VA_SRA_SIZE			(16)
#define VA_LTA_SIZE			(24)
#define	VA_ABA_SIZE			(16)
#define VA_STACK_SIZE		VA_SRA_SIZE + VA_LTA_SIZE + VA_ABA_SIZE

#define	VA_ABA_POS_INI		(0)
#define VA_LTA_POS_INI		VA_ABA_POS_INI + VA_ABA_SIZE
#define VA_SRA_POS_INI		VA_LTA_POS_INI + VA_LTA_SIZE

#define VA_RA				VA_SRA_POS_INI + 8
#define	VA_O_FP				VA_SRA_POS_INI + 4
#define	VA_O_GP				VA_SRA_POS_INI + 0

#define VA_O_ARG0			(VA_STACK_SIZE)
#define VA_O_ARG1			((VA_STACK_SIZE) + 4)

	/* int validate(char* text, char** errmsg);	*/
	# uso de registros
	# t1 puntero a texto
	# t2 mensaje error
	# t3 count
	# t4 nro_linea
	# t5 caracter actual texto
	# t6 puntero a abrio
	# t7 temporal
	
	.text
	.align 	2
	.globl	validate
	.ent	validate

validate:
   	.frame fp,VA_STACK_SIZE,ra
   	.set  noreorder
   	.cpload  t9  
   	.set  reorder    
   	.cprestore VA_O_GP 
	
				subu	sp,sp,VA_STACK_SIZE

				sw		gp,VA_O_GP(sp)
				sw		fp,VA_O_FP(sp)
				sw		ra,VA_RA(sp)
				
				move	fp,sp

				sw		a0,VA_O_ARG0(fp)
				sw		a1,VA_O_ARG1(fp)
				
				move	t1,a0			#cargo en t1 el puntero al archivo cargado en memoria
				move	t2,a1			#cargo en t2 el puntero al mensage de error que llenaré si se produce un error
				move	t3,zero			#inicializo en 0, el count, encargado de contar la cantidad de tags en la pila
				move	t4,zero			#inicializo en 0, el nro_linea, encargado de contar la cantidad de lineas en el texto
				move	t5,zero
				li		v0,-666			#si devuelve este numero quiere decir que hubo un error
				lb		t5,0(t1)		#cargo 1ra letra del texto
							
loop_general:	beq		t5,0,fin_archivo		#si llegue al '\0', llegue al final del archivo
				beq		t5,NUEVA_LINEA,incrementar_linea
continuar1:		beq		t5,MENOR,encontre_tag	#si es '<' entonces es un tag

				addiu	t1,t1,1					#aumento en 1 el puntero al archivo cargado en mem
continuar2:		lb		t5,0(t1)				#cargo la siguiente letra del texto
				b		loop_general
				
				
				
incrementar_linea:
				addiu	t4,t4,1
				b		continuar1

encontre_tag:	addiu	t1,t1,1						#muevo el puntero una letra despues de '<'
				lb		t5,0(t1)					#cargo la letra que apunta el puntero de texto
				beq		t5,BINVERT,es_tag_cierre	#si despues de < viene \ entonces es de cierre
				
							#Desde aca se que es un TAG DE ABERTURA
													
				subu	fp,fp,4						#hago lugar en el stack para guardar el puntero al inicio del tag de abertura
				sw		t1,0(fp)					#guardo el puntero en el stack
				addiu	t3,t3,1						#aumento en 1 el count
				subu	fp,fp,4						#hago lugar en el stack para guardar el numero de linea del tag de abertura
				sw		t4,0(fp)					#guardo el numero de linea en el stack
				addiu	t3,t3,1						#aumento en 1 el count
				b		continuar2					#sigo en el bucle principal
				
es_tag_cierre:
				addiu	t1,t1,1						#muevo el puntero una letra despues de '\'
				beqz	t3,tag_sin_abrir			#si no hay ningun tag abierto entonces count=0
				lw		t6,4(fp)					#cargo direccion del ultimo tag abierto SIN INCLUIR EL '<'
				
				#INICIO de guardado de registros
				#guardo los temporales antes de realizar la llamada
				sw		t1,VA_LTA_POS_INI(sp)
				sw		t2,VA_LTA_POS_INI + 4(sp)
				sw		t3,VA_LTA_POS_INI + 8(sp)
				sw		t4,VA_LTA_POS_INI + 12(sp)
				sw		t5,VA_LTA_POS_INI + 16(sp)
				sw		t6,VA_LTA_POS_INI + 20(sp)
				
				#guardo fp , gp y ra antes de realizar la llamada
				subu	fp,fp,8			
				sw		sp,0(fp)		
				sw		gp,4(fp)		
				subu	fp,fp,16 		
				move	sp,fp 			
				#FIN de guardado de registros
				
				move	a0,t6
				move	a1,t1
				jal		compare_tags    #compare_tags(t6 , t1) -> v0 (int 0 si no son iguales, 1 si son iguales)
				
				#INICIO de recarga de registros guardados
				addiu	fp,fp,16		
				lw		sp,0(fp)		
				lw		gp,4(fp)		
				addiu	fp,fp,8			
				
				lw		t1,VA_LTA_POS_INI(sp)
				lw		t2,VA_LTA_POS_INI + 4(sp)
				lw		t3,VA_LTA_POS_INI + 8(sp)
				lw		t4,VA_LTA_POS_INI + 12(sp)
				lw		t5,VA_LTA_POS_INI + 16(sp)
				lw		t6,VA_LTA_POS_INI + 20(sp)
				#FIN de recarga de registros
		
		
				beq		v0,0,tag_malo
								#Desde aca los tags son iguales
				subu	t3,t3,2						#disminuyo el count en 2
				addiu	fp,fp,8						#disminuyo de tamaño el stack en 2 elementos
				
				b		continuar2
	
								
tag_malo:		#ACA AVERIGUA QUE TIPO DE ERROR ES, TAG_MAL_ANIDADO O TAG_SIN_ABRIR
			
tag_malo_loop:	beqz	t3,tag_sin_abrir
				
				subu	t3,t3,2						#disminuyo el count en 2
				addiu	fp,fp,4						#fp ahora tiene en 0 a la dir del tag que abre
				lw		t6,0(fp)					#cargo direccion del ultimo tag abierto SIN INCLUIR EL '<'
				
				#COPYPASTE DE LO DE ARRIBA
				
				#INICIO de guardado de registros
				#guardo los temporales antes de realizar la llamada
				sw		t1,VA_LTA_POS_INI(sp)
				sw		t2,VA_LTA_POS_INI + 4(sp)
				sw		t3,VA_LTA_POS_INI + 8(sp)
				sw		t4,VA_LTA_POS_INI + 12(sp)
				sw		t5,VA_LTA_POS_INI + 16(sp)
				sw		t6,VA_LTA_POS_INI + 20(sp)
				
				#guardo fp , gp y ra antes de realizar la llamada
				subu	fp,fp,8			
				sw		sp,0(fp)		
				sw		gp,4(fp)		
				subu	fp,fp,16 		
				move	sp,fp 			
				#FIN de guardado de registros
				
				move	a0,t6
				move	a1,t1
				jal		compare_tags    #compare_tags(t6 , t1) -> v0 (int 0 si no son iguales, 1 si son iguales)
				
				#INICIO de recarga de registros guardados
				addiu	fp,fp,16		
				lw		sp,0(fp)		
				lw		gp,4(fp)		
				addiu	fp,fp,8			
				
				lw		t1,VA_LTA_POS_INI(sp)
				lw		t2,VA_LTA_POS_INI + 4(sp)
				lw		t3,VA_LTA_POS_INI + 8(sp)
				lw		t4,VA_LTA_POS_INI + 12(sp)
				lw		t5,VA_LTA_POS_INI + 16(sp)
				lw		t6,VA_LTA_POS_INI + 20(sp)
				#FIN de recarga de registros
				
				#FIN DE COPYPASTE DE LO DE ARRIBA
				
				beq		v0,1,tags_mal_anidado
				addiu	fp,fp,4	
				b		tag_malo_loop
				

fin_archivo:
				bnez	t3,tags_sin_cerrar		#si count es mayor que 0, quiere decir que hay un tag que no se cerro
				li		v0,1					#wiii EL XML ESTA BIEN !!!!
				b 		exit
				
tag_sin_abrir:
				#[  AQUI LLAMAR A write_error(1, abrio = t6, cerro = t1, nro_linea = t4, errmsg = t2);
				li		v0,-222		#TESTINGG
				b		exit
				
tags_sin_cerrar:
				lw		t4,0(fp)				#cargo el numero de linea en donde esta el tag que no fue cerrado
				lw		t6,4(fp)				#cargo la posicion en donde empieza el tag que no fue cerrado
				
				#[  AQUI LLAMAR A write_error(3, abrio = t6, NULL, nro_linea = t4, errmsg = t2);
				li		v0,-888		#TESTINGG
				b		exit

tags_mal_anidado:
				#[  AQUI LLAMAR A write_error(2, abrio = t6, cerro = t1, nro_linea = t4, errmsg = t2); ]
				li		v0,-111		#TESTINGG
				b		exit
				
exit:			
				lw		ra,VA_RA(sp)
				lw		gp,VA_O_GP(sp)
				lw		fp,VA_O_FP(sp)
				
				jr		ra

				.end		validate


		
				
###########################COMPARE_TAGS#################################

#define CT_SSIZE		(8)

#define	CT_O_FP			(4)
#define	CT_O_GP			(0)

#define 	CT_O_ARG0		(CT_SSIZE)
#define 	CT_O_ARG1		((CT_SSIZE) + 4)

	/* int compare_tags(char* abrio,char* cerro);	*/
	.text
	.align 	2
	.globl	compare_tags
	.ent	compare_tags

compare_tags:
   	.frame fp,CT_SSIZE,ra
   	.set  noreorder
   	.cpload  t9  
   	.set  reorder     
	
		subu	sp,sp,CT_SSIZE

		sw		gp,CT_O_GP(sp)
		sw		fp,CT_O_FP(sp)
		
		move	fp,sp

		sw		a0,CT_O_ARG0(fp)
		sw		a1,CT_O_ARG1(fp)
		
		move	t1,a0			#cargo en t1 el puntero al tag1
		move	t2,a1			#cargo en t2 el puntero al tag2
		
		beq		t1,0,distintos	#veo si tag1 no es NULL
		
loop:	
		lb		t3,0(t1)		#cargo desde memoria la siguiente letra de tag1
		lb		t4,0(t2)		#cargo desde memoria la siguiente letra de tag2
		
		beq		t3,62,largo		#veo si tag1 alcanzo '>'
		beq		t4,62,largo		#veo si tag2 alcanzo '>'
		
		bne		t3,t4,distintos	#veo si tag1[i]==tag2[i], si son distintos entonces se va a distintos
		
		addiu	t1,t1,1			#aumento en 1 los punteros de tag1, y tag2
		addiu	t2,t2,1			#NOTA: si o si tag1 y tag2 TIENEN que tener un '>' al final sino genera core segment
		b		loop

largo:
		bne		t3,62,distintos
		bne		t4,62,distintos
		b		iguales
		
distintos:
		li		v0,0
		b		exit_compare_tags
		
iguales:
		li		v0,1
		b		exit_compare_tags
		
exit_compare_tags:
		lw		gp,CT_O_GP(sp)
		lw		fp,CT_O_FP(sp)
		
		jr		ra

		.end		compare_tags
