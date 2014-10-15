#include <unistd.h>
#include <stdio.h>

int write_error(int tipo_de_error, char* tag1, char* tag2, int nro_linea, char** errmsg);

int main(int argc,char **argv) {
	
	char* errmsg;
	printf("%d\n", write_error(1,"prueba>","pruebaz>",33,&errmsg));
	
	return 0;
}
