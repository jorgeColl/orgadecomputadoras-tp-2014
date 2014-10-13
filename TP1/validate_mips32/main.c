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
	
	
	//char* a ="<sss><\\sss>"; DIOS SANTO PODEROSO, NO PUEDO HUMANAMENTE COMPRENDER PORQUE SI DESCOMENTO ESTA LINEA,
	// EL PRINT DE UNA DE LAS PRUEBAS NO ANDA, Y LA PRUEBA TAMBIEN DA CUALQUIER COSA
	// mmm podria ser por el parche asqueroso que use adentro del assembly
	char* b ="<z><d><fofo><pepe><\\bbbbbb>";
	char* c ="<abaaaac><\\abaaaac><zzz><\\zz>";
	char* d ="<aza><sese><sisi>";
	char* e ="<\\aaaa>";
	
	
	
	/*aux(a,BIENXML);
	aux(b,MALXML);
	aux(c,MALXML);
	aux(d,MALXML);*/
	
	char* errmsg = NULL;
	int resultado;
	//int resultado = validate(a, &errmsg);
	//printf("PRUEBA 1: %s resultado:%d\n",a,resultado);
	
	resultado = validate(b, &errmsg);
	printf("PRUEBA 2: %s resultado:%d\n",b,resultado);
	
	resultado = validate(c, &errmsg);
	printf("PRUEBA 3: %s resultado:%d\n",c,resultado);
	
	resultado = validate(d, &errmsg);
	printf("PRUEBA 4: %s resultado:%d\n",d,resultado);
	
	resultado = validate(e, &errmsg);
	printf("PRUEBA 5: %s resultado:%d\n",e,resultado);

	return 0;
}
