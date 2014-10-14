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
#define ERRMSG 52

/* funcion auxiliar de validate, tambien implementada en assembly
 * dado dos posiciones y un char*,realiza la comparacion si esas dos
 * posiciones tienen los mismos tags, en caso afirmativo devuelve true, en caso contrario devuelve false
 *
 * abrio: posicion inicial del tag1
 * cerro: posicion inicial del tag2
 */
int compare_tags(char* abrio, char* cerro) {
	if(abrio==NULL){
		return 0;
	}
	// desplazamiento que voy haciendo para comparar los dos tags
	long desplazamiento = 0;

	while (abrio[desplazamiento] != '>' && cerro [ desplazamiento != '>']) {
		if (abrio [desplazamiento] != cerro [desplazamiento]) {
			return 0;
		}
		desplazamiento++;
	}
	if(abrio[desplazamiento] != '>' || cerro [desplazamiento] != '>'){
		return 0;
	}

	return 1;
}

void print_tag(char* tag, char** errmsg) {
	int tam = strlen(*errmsg);
	while(*tag != '>'){
		(*errmsg)[tam] = *tag;
		tam++;		
		tag++;
	}
	(*errmsg)[tam] = '\0';
}
// funcion de asistencia para testing
void print_tagg(char* tag) {
	while(*tag != '>'){
		printf("%c",*tag);
		tag++;
	}
	printf("\n");
}


size_t calcular_largo(char* tag) {
	if (tag == NULL) return 0;
	size_t tam = 0;	
	while(*tag != '>'){
		tam++;		
		tag++;
	}
	return tam;
}

// funcion auxiliar de validate, tambien implementada en assembly
void write_error(int tipo_de_error, char* tag1, char* tag2, int nro_linea, char** errmsg) {
	size_t size = ERRMSG + calcular_largo(tag1) + calcular_largo(tag2);
	(*errmsg) = (char*)malloc(sizeof(char)*size);
	(*errmsg)[size-1]='\0';

	switch (tipo_de_error) {
	case 1:
		sprintf(*errmsg, "es tag sin abrir - nro de linea: %d - tag: ", nro_linea);
		print_tag(tag2, errmsg);
		break;
	case 2:
		sprintf(*errmsg, "es tag mal anidado - nro de linea: %d - tags: ", nro_linea);
		print_tag(tag1, errmsg);
		int tam = strlen(*errmsg);
		(*errmsg)[tam] = ' ';
		(*errmsg)[tam+1] = 'y';
		(*errmsg)[tam+2] = ' ';
		(*errmsg)[tam+3] = '\0';
		print_tag(tag2, errmsg);
		break;
	case 3:
		sprintf(*errmsg, "hay tags sin cerrar - nro de linea: %d - tag: ", nro_linea);
		print_tag(tag1, errmsg);
		break;
	default:
		break;
	}
}


bool es_tag_sin_abrir(char* cerro, int count, char* pila[]) {
	/*int i;
	for (i = 0; i < count; i+=2) {
		bool tags_son_iguales = compare_tags(pila[i], cerro);
		if(tags_son_iguales){
			return false;
		}
	}*/
	while (count != 0) {
		bool tags_son_iguales = compare_tags(pila[count-2], cerro);
		if (tags_son_iguales) {
			return false;
		}
		count -= 2;
	}
	return true;
}

int validate(char* text, char** errmsg) {
	// esta pila va a ser el sp en assembly por lo que no vamos a tener que preocuparnos por su tamaño
	char** pila = malloc(sizeof(char*) * strlen(text));

	//count cantida de tags abiertos
	long count = 0;

	//numero de linea
	int nro_linea = 0;

	int i = 0;
	while (text[i] != '\0') {
		if (text[i] == '\n') {
			nro_linea++;
		}
		if (text[i] == '<') {
			i++;
			if (text[i] != '\\') {
				//printf("encontre abierto ");
				//print_tagg(&text[i+1]);

				// guardo posicion en donde esta el inicio del tag
				pila[count] = &text[i];
				count++;
				// no importa este warning
				pila[count] = nro_linea;
				count++;

			} else {
				// verifico que este bien cerrado

				// pos donde se abrio el tag
				char* abrio = pila[count - 2];

				i++;
				//pos donde empieza el tag que cierra
				char* cerro = &text[i];

				// solo para debug
				//printf("encontre cerrado ");
				//print_tagg(cerro);

				bool son_iguales = compare_tags(abrio, cerro);

				if (son_iguales == false) {
					// ve si es tagl mal anidado o tag sin abrir
					while (count != 0) {
						count -= 2;
						bool tags_son_iguales = compare_tags(pila[count], cerro);
						if (tags_son_iguales) {
							//es tag mal anidado
							write_error(2, abrio, cerro, nro_linea, errmsg);
							free(pila);
							return 1;
						}
					}
					// es tag sin abrir
					write_error(1, abrio, cerro, nro_linea, errmsg);
					free(pila);
					return 1;
				}
				//si, esta bien cerrado
				count-=2;
			}
		}
		i++;
	}

	if (count > 0) {
		// hay tags que no estan cerrados, ya que la "pila" sigue teniendo tags que no fueron cerrados
		write_error(3, pila[0], NULL, (int) pila[1], errmsg);
		free(pila);
		return 1;
	}
	printf("todo ok\n");
	free(pila);
	return 0;
}
