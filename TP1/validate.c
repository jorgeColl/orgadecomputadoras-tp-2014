/*
 * validate.c
 *
 *  Created on: 07/10/2014
 *      Author: jorge
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <stdbool.h>

/* funcion auxiliar de validate, tambien implementada en assembly
 * dado dos posiciones y un char*,realiza la comparacion si esas dos
 * posiciones tienen los mismos tags, en caso afirmativo devuelve true, en caso contrario devuelve false
 *
 * abrio: posicion inicial del tag1
 * cerro: posicion inicial del tag2
 */
bool comparar_tags(char* abrio, char* cerro) {
	if(abrio==NULL){
		return false;
	}
	// desplazamiento que voy haciendo para comparar los dos tags
	long desplazamiento = 0;

	// caso comun, las dos tienen el mismo largo
	while (abrio[desplazamiento] != '>' && cerro [ desplazamiento != '>']) {
		if (abrio [desplazamiento] != cerro [desplazamiento]) {
			// error los tags tienen distintas letras
			printf("los tags tienen distintas letras: %c,%c\n",abrio[desplazamiento],cerro[desplazamiento]);
			return false;
		}
		desplazamiento++;
	}
	if (abrio[desplazamiento] == '>' && cerro [desplazamiento] != '>') {
		// error el tag que abria es mas chico que el tag que cierra
		printf("el tag que abria es mas chico que el tag que cierra\n");
		return false;
	}
	if (abrio [desplazamiento] != '>' && cerro[desplazamiento] == '>') {
		// error el tag que abria es mas grande que el tag que cierra
		printf("el tag que abria es mas grande que el tag que cierra\n");
		return false;
	}

	return true;
}

void print_tag(char* tag) {
	while(*tag != '>'){
		printf("%c",*tag);
		tag++;
	}
	printf("\n");
}

// funcion auxiliar de validate, tambien implementada en assembly
// TODO terminar de implementar correctamente
void write_error(int tipo_de_error, char* tag1, char* tag2, int nro_linea, char** errmsg) {
	switch (tipo_de_error) {
	case 1:
		printf("es tag sin abrir");
		printf("nro de linea:%d tag:",nro_linea);
		print_tag(tag2);
		break;
	case 2:
		printf("es tag mal anidado");
		printf("nro de linea %d tag:",nro_linea);
		print_tag(tag1);
		printf("y tag:");
		print_tag(tag2);
		break;
	case 3:
		printf("hay tags sin cerrar\n");
		printf("nro de linea %d tag:",nro_linea);
		print_tag(tag1);
		break;
	default:
		break;
	}
}

bool es_tag_sin_abrir(char* cerro, int count, char* pila[]) {
	int i;
	for (i = 0; i < count; i++) {
		bool tags_son_iguales = comparar_tags(pila[i], cerro);
		if(tags_son_iguales){
			return false;
		}
	}
	return true;
}

int validate(char* text, char** errmsg) {
	// esta pila va a ser el sp en assembly por lo que no vamos a tener que preocuparnos por su tamaño
	char* pila[1000];

	//count cantida de tags abiertos
	long count = 0;

	//numero de linea
	int nro_linea = 0;

	int i=0;
	while (text[i] != '\0') {
		if(text[i]=='\n'){
			nro_linea++;
		}
		if (text[i] == '<' && text[i+1]!='\\') {
			printf("encontre abierto ");
			print_tag(&text[i]);
			// guardo posicion en donde esta el inicio del tag
			count++;
			pila[2 * (count - 1)] = &text[i+1];
			// no importa este warning
			pila[(2 * (count - 1)) + 1] = nro_linea;

		} else if (text[i] == '<' && text[i + 1] == '\\') {
			// verifico que este bien cerrado

			// pos donde se abrio el tag
			char* abrio = pila[2*(count - 1)];

			//pos donde empieza el tag que cierra
			char* cerro = &text[i + 2];

			// solo para debug
			printf("encontre cerrado ");
			print_tag(cerro);

			bool son_iguales = comparar_tags(abrio, cerro);

			if (son_iguales == false) {
				// veo si el error es de tags sin abrir o de tags mal anidados
				bool bool_es_tag_sin_abrir = es_tag_sin_abrir(cerro, count, pila);

				if(bool_es_tag_sin_abrir) {
					write_error(1,abrio,cerro,nro_linea,errmsg);
				}else{
					write_error(2,abrio,cerro,nro_linea,errmsg);
				}
				return 1;
			}
			//si, esta bien cerrado
			count--;
		}
		i++;
	}
	if (count > 0) {
		// hay tags que no estan cerrados, ya que la "pila" sigue teniendo tags que no fueron cerrados
		printf("hay tags sin cerrar, cant:%ld\n", count);
		write_error(3,pila[0],NULL,(int)pila[1],errmsg);
	}
	printf("todo ok\n");
	//free(pila);
	return 0;
}
