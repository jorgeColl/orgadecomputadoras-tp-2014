#include <unistd.h>
#include <stdio.h>

int validate(char* text, char** errmsg);
/*
void aux (char* y, int esperado){
	char* errmsg = NULL;
	int resultado = validate(y, &errmsg);
	printf("texto:\n%s\n", y);
	printf("mensaje de error: %s\n",errmsg);
	
	if (resultado==esperado){
		printf("FAIL\n");
	}else{
		printf("OK\n");
	}
}*/
#define MALXML 0
#define BIENXML 1

int main(int argc,char **argv) {
	char* a ="<aa\naaa\n>";
	char* b ="<z><\\bbbbbb>";
	char* c ="<aaaaaac><\\aaaaaac>";
	char* d ="<aa>";
	
	/*aux(a,BIENXML);
	aux(b,MALXML);
	aux(c,MALXML);
	aux(d,MALXML);*/
	char* errmsg = NULL;
	int resultado = validate(a, &errmsg);
	printf("%s resultado:%d\n",a,resultado);
	resultado = validate(b, &errmsg);
	printf("%s resultado:%c\n",b,(char)resultado);
	resultado = validate(c, &errmsg);
	printf("%s resultado:%c\n",c,(char)resultado);
	resultado = validate(d, &errmsg);
	printf("%s resultado:%d\n",d,resultado);
	return 0;
}
