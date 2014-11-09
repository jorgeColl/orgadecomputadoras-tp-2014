#include <mips/regdef.h>
#include <sys/syscall.h>

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
loop:	lb t2,0(t1)					#puntero a caracter de error[x]
		sb t2,0(v0)					#guardo el caracter en el arreglo allocado
		beq	t2,0,tipo_error			#si es '\0' terminar loop		
		addiu t1,t1,1 				#paso al siguiente caracter de error[x]
		addiu v0,v0,1 				#paso al siguiente caracter del arreglo allocado
		b  loop

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
		beq		t6,0,exit 			#si no se debe cargar tag 2 termina
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
		beq		t4,CIERRE, exit 	#si es '<' sale
		sb 		t4,0(v0) 			#guardo el caracter en el arreglo allocado
		addiu	v0,v0,1 			#v0 + 1: siguiente posicion
		addiu	a2,a2,1 			#a2 + 1: siguiente caracter
		b 		tag2

exit:	
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
