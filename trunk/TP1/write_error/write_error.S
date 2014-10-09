#include <mips/regdef.h>
#include <sys/syscall.h>

#ifndef 	fp
#define	fp	$fp
#endif

#define SSIZE			(8)

#define	O_FP			(4)
#define	O_GP			(0)

#define 	O_ARG0		(SSIZE)
#define 	O_ARG1		((SSIZE) + 4)

	/* int write_error(--------	*/
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

		sw		gp,O_GP(sp)
		sw		fp,O_FP(sp)
		
		move	fp,sp

		sw		a0,O_ARG0(fp)
		sw		a1,O_ARG1(fp)
		
		move	t1,a0			#cargo en t1 el puntero al tag1
		move	t2,a1			#cargo en t2 el puntero al tag2
		
		

exit:
		lw		gp,O_GP(sp)
		lw		fp,O_FP(sp)
		
		jr		ra

		.end		write_error
