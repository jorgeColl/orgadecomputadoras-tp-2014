#include <mips/regdef.h>
#include <sys/syscall.h>

#ifndef 	fp
#define	fp	$fp
#endif

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
