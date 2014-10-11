#include <mips/regdef.h>
#include <sys/syscall.h>

#ifndef 	fp
#define	fp	$fp
#endif

#define	NUEVA_LINEA		(10)
#define	MENOR			(60) 
#define	BINVERT			(92)
#define SSIZE			(8)

#define	O_FP			(4)
#define	O_GP			(0)

#define 	O_ARG0		(SSIZE)
#define 	O_ARG1		((SSIZE) + 4)

	/* int validate(char* text, char** errmsg);	*/
	.text
	.align 	2
	.globl	validate
	.ent	validate

validate:
   	.frame fp,SSIZE,ra
   	.set  noreorder
   	.cpload  t9  
   	.set  reorder     
	
				subu	sp,sp,SSIZE

				sw		gp,O_GP(sp)
				sw		fp,O_FP(sp)
				
				move	fp,sp

				sw		a0,O_ARG0(fp)
				sw		a1,O_ARG1(fp)
				
				move	t1,a0			#cargo en t1 el puntero al archivo cargado en memoria
				move	t2,a1			#cargo en t2 el puntero al mensage de error que llenaré si se produce un error
				
				move	t3,zero			#inicializo en 0, el count, encargado de contar la cantidad de tags en la pila
				move	t4,zero			#inicializo en 0, el nro_linea, encargado de contar la cantidad de lineas en el texto
				
				lb		t5,0(t1)				#cargo 1ra letra del texto
							
loop_general:	beq		t5,0,fin_archivo		#si llegue al '\0', llegue al final del archivo
				beq		t5,NUEVA_LINEA,incrementar_linea
continuar1:		beq		t5,MENOR,encontre_tag	#si es '<' entonces es un tag





continuar2:		addiu	t1,t1,1				#aumento en 1 el puntero al archivo cargado en mem
				lb		t5,0(t1)			#cargo la siguiente letra del texto
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
				lw		t6,4(fp)					#cargo direccion del ultimo tag abierto SIN INCLUIR EL '<'
				
				#TESTINGG
				#TESTINGG   [AQUI LLAMAR A FUNCION compare_tags(t6 , t1) -> v0 (int  0 si no son iguales, 1 si son iguales)
				#TESTINGG
				
				li		v0,0		#TESTINGG		ASUMO QUE ME DEVOLVIO IGUALES
				
				beq		v0,1,tag_malo
													#Desde aca los tags son iguales
				subu	t3,t3,2						#disminuyo el count en 2
				addiu	fp,fp,8						#disminuyo de tamaño el stack en 2 elementos
				b		continuar2

tag_malo:		
				li		v0,-999		#TESTINGG
				b 		exit

fin_archivo:
				bne		t3,0,tags_sin_cerrar		#si count es mayor que 0, quiere decir que hay un tag que no se cerro
				li		v0,63		#TESTINGG
				b 		exit

tags_sin_cerrar:
				#[  AQUI LLAMAR A write_error(3,-aaaaa-,X,t4,t2); ]
				li		v0,1
				b		exit

exit:
				lw		gp,O_GP(sp)
				lw		fp,O_FP(sp)
				
				jr		ra

				.end		validate
