#include <mips/regdef.h>
#include <sys/syscall.h>

#ifndef 	fp
#define	fp	$fp
#endif

#define SRA (16)
#define ABA (24)
#define SSIZE (SRA+ABA)

#define O_RA			(32)
#define	O_FP			(28)
#define	O_GP			(24)
#define 	O_ARG0		(SSIZE)
#define 	O_ARG1		((SSIZE) + 4)
#define 	O_ARG2		((SSIZE) + 8)
#define 	O_ARG3		((SSIZE) + 12)
#define 	O_ARG4		((SSIZE) + 16)

#define		CIERRE	62
#define		ERRMSG  52

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
		
		sw		a0,O_ARG0(sp)
		sw		a1,O_ARG1(sp)
		sw		a2,O_ARG2(sp)
		sw		a3,O_ARG3(sp)
		sw		s4,O_ARG4(sp)
		
		li		s1,ERRMSG 			#s1 contiene el tamaño de errmsg
		move	s3,a0 				#guardo el tipo de error en s3.
		move	a0,a1				#cargo en a0 el puntero al tag1			
		jal		calcular_largo 		#calculo el tamaño del tag1
		addu	s1,s1,v0 			#sumo el tamaño del tag1 a s1
		move	a0,a2				#cargo en a0 el puntero al tag2			
		jal		calcular_largo 		#calculo el tamaño del tag2
		addu	s1,s1,v0 			#sumo el tamaño del tag2 a s1

pedir_memoria:
		/* 	void *mymalloc(size_t) */
		move	a0,s1				#guardo el tamaño del tag en a0
		jal		mymalloc			#llamo a mymalloc
		#lw		s2, 0(s4)			#desreferencio puntero a puntero a errmsg
		#move	s2, v0				#asigno el puntero obtenido al (*errmsg) #??
		sw		v0,0(s4)
		###################################

tipo_error:
		beq		s3,1,tipo1
		beq		s3,2,tipo2
		beq		s3,3,tipo3

tipo1:
		li 	 	v0,1
		b 		exit
tipo2:
		li 		v0,2
		b 		exit
tipo3:						
		li 		v0,3
exit:
		lw		ra,O_RA(sp)
		lw		gp,O_GP(sp)
		lw		fp,O_FP(sp)

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

		li		t2, 0				#t2 contiene el tamaño del tag
		beq		a0, 0, cl_exit		#si tag es null, retorna con t2 = 0
loop:	
		lb		t4, 0(a0)			#desreferencio el puntero t1.
		beq		t4, CIERRE, cl_exit	#si es '<' sale
		addiu	a0,a0,1 			#t1 + 1: siguiente caracter
		addiu	t2,t2,1 			#t2 + 1: aumenta en uno el tamaño
		b 		loop
		
cl_exit:
		move	v0, t2 				#retorna el tamaño del tag
		lw		gp,CL_GP(sp)
		lw		fp,CL_FP(sp)
		lw		a0,CL_ARG0(sp)
		lw		a1,CL_ARG1(sp)
		lw		a2,CL_ARG2(sp)
		lw		a3,CL_ARG3(sp)

		addiu	sp,sp,CL_SSIZE

		jr		ra

		.end	calcular_largo

