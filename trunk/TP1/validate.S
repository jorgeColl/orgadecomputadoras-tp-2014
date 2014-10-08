# validate.S
# - int validate(char* text, char** errmsg);
#
# 	Argumentos:
# 		* a0: char*
#		* a1: char**
#
# 	Stack Frame:
# 		*
#
#
#
#
# - void write_error(int tipo_de_error, int pos_tag1, int pos_tag2, int nro_linea, char** errmsg)
#
#	Argumentos:
#		* a0:tipo_de_error
#		* a1:pos_tag1
#		* a2:pos_tag2
		* a3:nro_linea
#		* :errmsg
#
#	Stack Frame:
#
#
#
#
#
# - int comparar_tags(int abrio, int cerro, char* text);
#   Argumentos:
# 		* a0: abrio
#		* a1: cerro
# 		* a2: text
#
# 	Stack Frame:
# 		*
#
#
#
#
#
#
#include <sys/syscall.h>
#include <mips/regdef.h>
#include "validate.h"
#include "mymalloc.h"

# - int validate(char* text, char** errmsg);

	.text
	.align 	2
	.globl	validate
	.ent	validate
validate:
	.frame $fp, SSIZE, ra
   	.set noreorder
   	.cpload t9
   	.set reorder

		subu	sp,sp,SSIZE 		#crea el stack.

	.end	validate
