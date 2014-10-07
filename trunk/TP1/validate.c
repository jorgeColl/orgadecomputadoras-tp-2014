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
/* funcion que dado dos posiciones y un char*,realiza la comparacion si esas dos
 * posiciones tienen los mismos tags, en caso afirmativo devuelve true, en caso contrario devuelve false
 */
bool comparar_tags(long abrio, long cerro, char* text) {
	// desplazamiento que voy haciendo para comparar los dos tags
	long desplazamiento = 0;

	// caso comun, las dos tienen el mismo largo
	while (text[abrio + desplazamiento] != '>' && text[cerro + desplazamiento != '>']) {
		if (text[abrio + desplazamiento] != text[cerro + desplazamiento]) {
			// error los tags tienen distintas letras
			printf("error los tags tienen distintas letras: %c,%c\n",text[abrio + desplazamiento],text[cerro + desplazamiento]);
			return false;
		}
		desplazamiento++;
	}
	if (text[abrio + desplazamiento] == '>' && text[cerro + desplazamiento] != '>') {
		// error el tag que abria es mas chico que el tag que cierra
		printf("error el tag que abria es mas chico que el tag que cierra\n");
		return false;
	}
	if (text[abrio + desplazamiento] != '>' && text[cerro + desplazamiento] == '>') {
		// error el tag que abria es mas grande que el tag que cierra
		printf("error el tag que abria es mas grande que el tag que cierra\n");
		return false;
	}

	return true;
}

bool es_tag_sin_abrir(long cerro, long count, long pila[], char text[]) {
	int i;
	for (i = 0; i < count; i++) {
		bool tags_son_iguales = comparar_tags(pila[i], cerro, text);
		if(tags_son_iguales){
			return false;
		}
	}
	return true;
}

int validate(char* text, char** error) {
	// esta pila va a ser el sp en assembly por lo que no vamos a tener que preocuparnos por su tamaño
	long pila[1000];

	//count cantida de tags abiertos
	long count = 0;

	//numero de linea
	long nro_linea = 0;

	int i=0;
	while (text[i] != '\0') {
		if(text[i]=='\n'){
			nro_linea++;
		}
		if (text[i] == '<' && text[i+1]!='\\') {
			printf("encontre abierto %c\n",text[i+1]);
			// guardo posicion en donde esta el inicio del tag
			count++;
			pila[2 * (count - 1)] = i + 1;
			pila[(2 * (count - 1)) + 1] = nro_linea;

		} else if (text[i] == '<' && text[i + 1] == '\\') {
			printf("encontre cerrado %c\n", text[i + 2]);
			// verifico que este bien cerrado

			// pos donde se abrio el tag
			long abrio = pila[2*(count - 1)];

			//pos donde empieza el tag que cierra
			long cerro = i + 2;

			bool son_iguales = comparar_tags(abrio, cerro, text);
			if (son_iguales == false) {
				// veo si el error es de tags sin abrir o de tags mal anidados
				bool bool_es_tag_sin_abrir = es_tag_sin_abrir(cerro, count, pila, text);

				if(bool_es_tag_sin_abrir){
					printf("es tag sin abrir\n");
					printf("nro de linea:%ld\n",nro_linea);
				}else{
					printf("es tag mal anidado\n");
					printf("nro de linea %ld \n",nro_linea);
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
		int i;
		for (i = 0; i < count; i++) {
			printf("linea: %ld tag: ",pila[(2*i)+1]);
			char c = text[pila[2*i]];
			int aux = 0;
			while (c != '>') {
				printf("%c", c);
				aux++;
				c = text[pila[2*i] + aux];
			}
			printf("\n");
		}
		return 1;
	}
	// todo ok
	printf("todo ok\n");
	//free(pila);
	return 0;
}
