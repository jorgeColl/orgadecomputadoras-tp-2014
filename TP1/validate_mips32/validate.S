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

#define VA_O_ARG0			VA_STACK_SIZE
#define VA_O_ARG1			VA_STACK_SIZE + 4

#define VA_0_T1				VA_LTA_POS_INI + 0
#define VA_0_T2				VA_LTA_POS_INI + 4
#define VA_0_T3				VA_LTA_POS_INI + 8
#define VA_0_T4				VA_LTA_POS_INI + 12
#define VA_0_T5				VA_LTA_POS_INI + 16
#define VA_0_T6				VA_LTA_POS_INI + 20
#define VA_0_T7				VA_LTA_POS_INI + 24


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
				sw		t1,VA_0_T1(sp)
				sw		t2,VA_0_T2(sp)
				sw		t3,VA_0_T3(sp)
				sw		t4,VA_0_T4(sp)
				sw		t5,VA_0_T5(sp)
				sw		t6,VA_0_T6(sp)
				
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
				
				lw		t1,VA_0_T1(sp)
				lw		t2,VA_0_T2(sp)
				lw		t3,VA_0_T3(sp)
				lw		t4,VA_0_T4(sp)
				lw		t5,VA_0_T5(sp)
				lw		t6,VA_0_T6(sp)
				#FIN de recarga de registros
		
		
				beq		v0,0,tag_malo
								#Desde aca los tags son iguales
				subu	t3,t3,2						#disminuyo el count en 2
				addiu	fp,fp,8						#disminuyo de tamaño el stack en 2 elementos
				
				b		continuar2
	
								
tag_malo:		#ACA AVERIGUA QUE TIPO DE ERROR ES, TAG_MAL_ANIDADO O TAG_SIN_ABRIR
				
				lw		t6,4(fp)
				sw		t6,VA_0_T7(sp)				#antes de iterar guardo el ultimo tag que abria solamente porque despues si es el caso de un tag mal anidado tengo que decir que tag se abrio antes del tag que se cerro
				
tag_malo_loop:	beqz	t3,tag_sin_abrir
				
				subu	t3,t3,2						#disminuyo el count en 2
				addiu	fp,fp,4						#fp ahora tiene en 0 a la dir del tag que abre
				lw		t6,0(fp)					#cargo direccion del ultimo tag abierto SIN INCLUIR EL '<'
				
				#COPYPASTE DE LO DE ARRIBA
				
				#INICIO de guardado de registros
				#guardo los temporales antes de realizar la llamada
				sw		t1,VA_0_T1(sp)
				sw		t2,VA_0_T2(sp)
				sw		t3,VA_0_T3(sp)
				sw		t4,VA_0_T4(sp)
				sw		t5,VA_0_T5(sp)
				sw		t6,VA_0_T6(sp)
				
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
				
				lw		t1,VA_0_T1(sp)
				lw		t2,VA_0_T2(sp)
				lw		t3,VA_0_T3(sp)
				lw		t4,VA_0_T4(sp)
				lw		t5,VA_0_T5(sp)
				lw		t6,VA_0_T6(sp)
				#FIN de recarga de registros
				
				#FIN DE COPYPASTE DE LO DE ARRIBA
				
				beq		v0,1,tags_mal_anidado
				addiu	fp,fp,4	
				b		tag_malo_loop
				

fin_archivo:
				bnez	t3,tags_sin_cerrar		#si count es mayor que 0, quiere decir que hay (al menos) un tag que no se cerro
				li		v0,0					#wiii EL XML ESTA BIEN !!!!
				b 		exit
				
tag_sin_abrir:
				#li		v0,1		#TESTINGG
				li		a0,1
				b		llamada_a_write_error	#write_error(1, abrio = t6, cerro = t1, nro_linea = t4, errmsg = t2);
				
tags_sin_cerrar:
				#li		v0,-888		#TESTINGG
				
				lw		t4,0(fp)				#cargo el numero de linea en donde esta el tag que no fue cerrado
				lw		t6,4(fp)				#cargo la posicion en donde empieza el tag que no fue cerrado
				li		a0,3
				b		llamada_a_write_error 	#write_error(3, abrio = t6, NULL, nro_linea = t4, errmsg = t2);

tags_mal_anidado:
				#li		v0,-111		#TESTINGG
				lw		t6,VA_0_T7(sp)			#cargo el tag que abria justo antes del tag mal anidado
				li		a0,2
				b		llamada_a_write_error	#write_error(2, abrio = t6, cerro = t1, nro_linea = t4, errmsg = t2); ]

llamada_a_write_error:

				#llamada generica
				#guardo fp y gp antes de realizar la llamada
				subu	fp,fp,8			
				sw		sp,0(fp)		
				sw		gp,4(fp)
				
				subu	fp,fp,24	
				move	sp,fp 	
				sw		t2,16(fp)	#guardo **errmgs
				
				move	a1,t6
				move	a2,t1
				move	a3,t4
				
				jal 	write_error
		
				addiu	fp,fp,24
				lw		sp,0(fp)
				lw		gp,4(fp)
				addiu	fp,fp,8
				
				li		v0,1
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

######################write_error#######################################

#ifndef 	fp
#define	fp	$fp
#endif

#define SRA (16)
#define ABA (16)
#define SSIZE (SRA+ABA)

#define O_RA	(28)
#define	O_FP	(24)
#define	O_GP	(20)
#define O_S1	(16)
#define O_ARG0	(SSIZE)
#define O_ARG1	((SSIZE) + 4)
#define O_ARG2	((SSIZE) + 8)
#define O_ARG3	((SSIZE) + 12)
#define O_ARG4	((SSIZE) + 16)

#define ESPACIO 32
#define GUION 	45
#define Y 		121
#define	CIERRE	62
#define	ERRMSG  60

	/* void write_error(int tipo_de_error, char* tag1, char* tag2, int nro_linea, char** errmsg)*/
	.text
	.align 	2
	.globl	write_error
	.ent	write_error

write_error:
   	.frame fp,SSIZE,ra
   	.set  noreorder
   	.cpload  t9  
   	.set  reorder     
	
		subu	sp,sp,SSIZE
		.cprestore O_GP 

		sw		ra,O_RA(sp)
		sw		gp,O_GP(sp)
		sw		fp,O_FP(sp)
		sw		s1,O_S1(sp)
		
		sw		a0,O_ARG0(sp)		#tipo de error
		sw		a1,O_ARG1(sp)
		sw		a2,O_ARG2(sp)
		sw		a3,O_ARG3(sp)
		
		li		s1,ERRMSG 			#s1 contiene el tamaño de errmsg		
		move	a0,a1				#cargo en a0 el puntero al tag1			
		jal		calcular_largo 		#calculo el tamaño del tag1

		lw		gp,O_GP(sp)			#recupero gp
		lw		ra,O_RA(sp)			#recupero ra

		addu	s1,s1,v0 			#sumo el tamaño del tag1 a s1
		move	a0,a2				#cargo en a0 el puntero al tag2			
		jal		calcular_largo 		#calculo el tamaño del tag2

		lw		gp,O_GP(sp)			#recupero gp
		lw		ra,O_RA(sp)			#recupero ra

		addu	s1,s1,v0 			#sumo el tamaño del tag2 a s1

pedir_memoria:
		/* 	void *mymalloc(size_t) */
		move	a0,s1				#guardo el tamaño del tag en a0 para pasarlo como argumento
		jal		mymalloc			#llamo a mymalloc (me devuelve un void* en v0)	

		lw		gp,O_GP(sp)
		lw		ra,O_RA(sp)
		lw		t2,SSIZE+16(sp)		# **errmgs
		sw		v0,0(t2)			# guardo puntero que devuelve malloc en el errmgs

		lw t3, O_ARG0(sp)			#guardo tipo de error
		move t0,t3 					#cargo en t0 el tipo de error
		addiu t0,-1 				#le resto uno al tipo de error
		sll t0,t0,2					#multiplico por 4 para obtener el offset
		lw t1,error(t0)				#t1 es puntero a error[x]
we_loop:	lb t2,0(t1)					#puntero a caracter de error[x]
		sb t2,0(v0)					#guardo el caracter en el arreglo allocado
		beq	t2,0,tipo_error			#si es '\0' terminar loop		
		addiu t1,t1,1 				#paso al siguiente caracter de error[x]
		addiu v0,v0,1 				#paso al siguiente caracter del arreglo allocado
		b  we_loop

tipo_error:
		lw 	a1,O_ARG1(sp)
		lw 	a2,O_ARG2(sp)
		beq	t3,1,tipo1
		beq	t3,2,tipo2
		beq	t3,3,tipo3

tipo1:	#tag2
		li t5,0 					#no se carga tag 1
		li t6,1 					#se carga tag2
		b  tags

tipo2: 	#tag 1 y 2
		li t5,1 					#se carga tag1
		li t6,1 					#se carga tag2
		b  tags

tipo3:	#tag 1					
		li t5,1 					#se carga tag1
		li t6,0 					#no se carga tag2
		b  tags

tags:   beq		t5,0,tag2			#si no se debe cargar tag1 paso directo a tag2
tag1:	lb		t4,0(a1)			#desreferencio el puntero a a1 = tag1.
		beq		t4,CIERRE, siguiente #si es '<' sale
		sb 		t4,0(v0) 			#guardo el caracter en el arreglo allocado
		addiu	v0,v0,1 			#v0 + 1: siguiente posicion
		addiu	a1,a1,1 			#a1 + 1: siguiente caracter
		b 		tag1
siguiente:		
		beq		t6,0,we_exit 			#si no se debe cargar tag 2 termina
		li 		t1,ESPACIO			#si se debe cargar tag 2 agrego " y "
		sb 		t1,0(v0)
		addiu	v0,v0,1
		li 		t1,Y 				
		sb 		t1,0(v0)
		addiu	v0,v0,1
		li 		t1,ESPACIO
		sb 		t1,0(v0)
		addiu	v0,v0,1
tag2:	lb		t4,0(a2)			#desreferencio el puntero a a2 = tag2.
		beq		t4,CIERRE, we_exit 	#si es '<' sale
		sb 		t4,0(v0) 			#guardo el caracter en el arreglo allocado
		addiu	v0,v0,1 			#v0 + 1: siguiente posicion
		addiu	a2,a2,1 			#a2 + 1: siguiente caracter
		b 		tag2

we_exit:	
		li 		t5,0
		sb 		t5,0(v0)			#agrego '\0'
		move	v0,t5
		lw		ra,O_RA(sp)
		lw		gp,O_GP(sp)
		lw		fp,O_FP(sp)
		lw		s1,O_S1(sp)

		lw		a0,O_ARG0(sp)
		lw		a1,O_ARG1(sp)
		lw		a2,O_ARG2(sp)
		lw		a3,O_ARG3(sp)		

		addiu	sp,sp,SSIZE
		
		jr		ra

		.end	write_error



#define CL_SRA (8)
#define CL_ABA (16)
#define CL_SSIZE (CL_SRA+CL_ABA)
#define	CL_FP	(20)
#define	CL_GP	(16)
#define	CL_ARG0	(CL_SSIZE)
#define	CL_ARG1	((CL_SSIZE) + 4)
#define	CL_ARG2	((CL_SSIZE) + 8)
#define	CL_ARG3	((CL_SSIZE) + 12)


	/* size_t calcular_largo(char* tag) */
	.text
	.align 	2
	.globl	calcular_largo
	.ent	calcular_largo

calcular_largo:
   	.frame fp,CL_SSIZE,ra
   	.set  noreorder
   	.cpload  t9  
   	.set  reorder     
	
		subu	sp,sp,CL_SSIZE		

		sw		gp,CL_GP(sp)
		sw		fp,CL_FP(sp)
		sw		a0,CL_ARG0(sp)
		sw		a1,CL_ARG1(sp)
		sw		a2,CL_ARG2(sp)
		sw		a3,CL_ARG3(sp)

		li		t2, 0					#t2 contiene el tamaño del tag
		beq		a0, 0, cl_exit			#si tag es null, retorna con t2 = 0
cl_loop:	
		lb		t4, 0(a0)				#desreferencio el puntero t1.
		beq		t4, CIERRE, cl_exit		#si es '<' sale
		addiu	a0,a0,1 				#t1 + 1: siguiente caracter
		addiu	t2,t2,1 				#t2 + 1: aumenta en uno el tamaño
		b 		cl_loop
		
cl_exit:
		move	v0, t2 					#retorna el tamaño del tag
		lw		gp,CL_GP(sp)
		lw		fp,CL_FP(sp)
		lw		a0,CL_ARG0(sp)
		lw		a1,CL_ARG1(sp)
		lw		a2,CL_ARG2(sp)
		lw		a3,CL_ARG3(sp)

		addiu	sp,sp,CL_SSIZE

		jr		ra

		.end	calcular_largo


.globl	error
	.rdata
	.align	2

error: .word sinabrir,malanidado,sincerrar
	
	.size error, 12
	.align 0

sinabrir: .asciiz "es tag sin abrir: \000"
malanidado: .asciiz "es tag mal anidado: \000"
sincerrar: .asciiz "hay tags sin cerrar: \000"
