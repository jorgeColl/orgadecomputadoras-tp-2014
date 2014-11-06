#include <unistd.h>
#include <stdio.h>

int validate(char* text, char** errmsg);

#define MALXML 0
#define BIENXML 1
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <stdbool.h>


static struct option long_options[] = {
		/* para cada opcion, se registra si necesita argumento y que letra devuelve getopt_long(), en caso
		 * de encontrarse con esa opcion */
		{ "input",		required_argument,	0, 'i' },
		{ "version", 	no_argument,		0, 'v' },
		{ "help", 		no_argument,		0, 'h' },
		// esto lo demanda la funcion
		{ 0, 0, 0, 0 }
};

static char short_options[] = "hvi:";

static char mensaje_de_ayuda[]="Usage:\n"
		" validate -h\n"
		" validate -V \n"
		" validate [options] file\n"
		"Options:\n"
		" -h, --help Prints usage information.\n"
		" -V, --version Prints version information.\n"
		" -i, --input Path to input file (-i - for stdin)\n"
		"Examples:\n"
		" validate -i -\n"
		" validate myfile.tagged\n"
		" validate -i myfile.tagged\n";
/**
 * Funcion encargada de cargar todo el archivo en un char*
 * Esto se hace asumiendo que todo el archivo entra en memoria
 */
char* cargar_archivo(FILE* fd) {
	long TAM = 5;
	char* buff = (char*) malloc(sizeof(char) * TAM);
	long cont = 0;
	while (!feof(fd)) {
		char c = fgetc(fd);
		buff[cont] = c;
		cont++;
		if (cont == TAM) {
			TAM = 2 * TAM;
			buff = realloc(buff, TAM);
		}
	}
	buff[cont - 1] = '\0';
	fclose(fd);
	return buff;
}

int main(int argc, char **argv) {
	FILE* fd = NULL;
	int option_index = 0;
	int c = getopt_long(argc, argv, short_options, long_options, &option_index);
	switch (c) {
	case 'h':
		printf("%s", mensaje_de_ayuda);
		return EXIT_SUCCESS;

	case 'v':
		printf("Version 1.00\n");
		return EXIT_SUCCESS;

	case 'i':
		if (optarg[0] == '-' && optarg[1] == '\0') {
			fd = stdin;
		} else {
			fd = fopen(optarg, "r");
			if (fd == NULL) {
				fprintf(stderr, "%s", "error al abrir el archivo\n");
				perror("");
				return EXIT_FAILURE;
			}
		}

		break;
	default:
		break;
	}
	char* buff = cargar_archivo(fd);
	char* error = NULL;
	
	int resultado = validate(buff,&error);
	printf("resultado: %d\n",resultado);
	//if(resultado == 1){
	//	fprintf(stderr,"%s",error);
	//	free(error);
	//}
	free(buff);
	return resultado;
		
}
