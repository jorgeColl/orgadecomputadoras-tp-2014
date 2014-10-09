#include <unistd.h>
#include <stdio.h>

int compare_tags(char* abrio,char* cerro);

void aux (char* x,char* y,int esperado){
	int exito;
	char* salio[]={"FALLO","OK"};
	int resultado= compare_tags(x,y);
	 if(resultado==esperado){
		 exito=1;
	 }else{
		 exito=0;
	 }
		 
	 printf("%s vs %s -> %d : %s\n",x,y,resultado,salio[exito]);
}
#define DISTINTOS 0
#define IGUALES 1
int main(int argc,char **argv) {
	char* a ="<aaaaaa>";
	char* b ="<bbbbbb>";
	char* c ="<aaaaaac>";
	char* d ="<aa>";
	
	
	aux(NULL,a,DISTINTOS);
	aux(a,a,IGUALES);
	aux(b,b,IGUALES);
	aux(c,c,IGUALES);
	aux(d,d,IGUALES);
	aux(a,b,DISTINTOS);
	aux(a,c,DISTINTOS);
	aux(a,d,DISTINTOS);
	aux(b,c,DISTINTOS);
	aux(b,d,DISTINTOS);
	aux(c,d,DISTINTOS);
	aux(d,a,DISTINTOS);
	aux(d,b,DISTINTOS);
	aux(d,c,DISTINTOS);
	aux(c,a,DISTINTOS);
	aux(c,b,DISTINTOS);
	aux(b,a,DISTINTOS);
	
	
	
	return 0;
}
