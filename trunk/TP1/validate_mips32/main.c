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
	char* a ="<\naa\naaa\n>";
	char* b ="<\\bbbbbb>";
	char* c ="<aaaaaac>";
	char* d ="<aa>";
	
	/*aux(a,BIENXML);
	aux(b,MALXML);
	aux(c,MALXML);
	aux(d,MALXML);*/
	char* errmsg = NULL;
	int resultado = validate(a, &errmsg);
	printf("%d\n",resultado);
	resultado = validate(b, &errmsg);
	printf("%d\n",resultado);
	return 0;
}
