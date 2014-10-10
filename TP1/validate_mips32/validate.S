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





				addiu	t1,t1,1				#aumento en 1 el puntero al archivo cargado en mem
				lb		t5,0(t1)			#cargo la siguiente letra del texto
				b		loop_general
				
		
		
incrementar_linea:
				addiu	t4,t4,1
				b		continuar1

encontre_tag:	lb		t5,1(t1)
				beq		t5,BINVERT,es_tag_cierre	#si despues de < viene \ entonces es de cierre
													#desde aca se que es un tag de abertura
				li	 	v0,777		#TESTINGG
				b		exit		#TESTINGG
				
es_tag_cierre:
				li	 	v0,-111		#TESTINGG
				b		exit		#TESTINGG
fin_archivo:
				move 	v0,t4
				b 		exit
		
exit:
				lw		gp,O_GP(sp)
				lw		fp,O_FP(sp)
				
				jr		ra

				.end		validate
