/*
 * main.c
 *
 *  Created on: 29/08/2014
 *      Author: jorge
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
/*
 * -s, --number-separator
 * -v, --starting-line-number
 * -i, --line-increment
 * -t, --non-empty
 * -l, --join-blank-lines
 * -h, --help
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
// optarg: opcion de argumento ej --add=gg  -> optarg = gg
/* Flag set by ‘--verbose’. */
static int verbose_flag;
static struct option long_options[] = {
		/* These options set a flag. */
		{ "verbose", no_argument, &verbose_flag, 1 },
		{ "brief", no_argument,&verbose_flag, 0 },
		/* These options don't set a flag. We distinguish them by their indices. */
		{ "number-separator", 	required_argument, 0, 's' },
		{ "starting-line-number", required_argument, 0, 'v' },
		{ "line-increment", 	required_argument, 0, 'i' },
		{ "non-empty",			no_argument, 0, 't' },
		{ "join-blank-lines", 	required_argument, 0, 'l' },
		{ "help", 				no_argument, 0, 'h' },
		{ 0, 0, 0, 0 }
};
int main(int argc, char **argv) {
	/* getopt_long stores the option index here. */
	int option_index = 0;
	int c = getopt_long(argc, argv, "s:v:i:t:l:h", long_options, &option_index);
	while (c!=-1) {
		switch (c) {
		case 0:
			/* If this option set a flag, do nothing else now. */
			if (long_options[option_index].flag != 0)
				break;
			printf("option %s", long_options[option_index].name);
			if (optarg)
				printf(" with arg %s", optarg);
			printf("\n");
			break;

		case 's':
			printf("option -s o number-separator con valor: %s\n", optarg);
			break;

		case 'v':
			printf("option -v o --starting-line-number con valor: %s\n", optarg);
			break;

		case 'i':
			printf("option -i o --line-increment con valor: %s\n", optarg);
			break;

		case 't':
			printf("option -t o --non-empty con valor: %s\n", optarg);
			break;

		case 'l':
			printf("option -l o --join-blank-lines con valor: %s\n", optarg);
			break;

		case 'h':
			printf("option -h o --help");
			break;

		default:
			printf("no se entiende:%c\n",c );
			abort();
		}
		c = getopt_long(argc, argv, "a:b:c:d:f:", long_options, &option_index);
	}

	/* Instead of reporting ‘--verbose’ and ‘--brief’ as they are encountered, we report the final status resulting from them. */
	if (verbose_flag)
		puts("verbose flag is set");

	/* Print any remaining command line arguments (not options). */
	if (optind < argc) {
		printf("elementos que no pudieron ser procesados: ");
		while (optind < argc)
			printf("%s ", argv[optind++]);
		putchar('\n');
	}

	exit(0);
} /*
 char separador[10];
 separador[1]=' ';
 int v=0;
 for (int i = 0; i < argc; i++) {
 char* input = argv[i];
 printf("input: %s\n",input);
 if (input[0] == '-' && input[1] != '-' && input[2]=='=') {
 printf("opcion corta:%s\n",input);
 switch (input[1]) {
 case 's':
 strcpy(separador,input);
 printf("SEPARADOR: %s\n",separador);
 break;
 case 'v':
 v=atoi(input[3]);
 break;
 case 'i':

 break;
 case 't':

 break;
 case 'l':

 break;
 case 'h':
 default:
 printf("comandos posibles:\n"
 "* -s, --number-separator\n"
 "* -v, --starting-line-number\n"
 "* -i, --line-increment\n"
 "* -t, --non-empty\n"
 "* -l, --join-blank-lines\n"
 "* -h, --help\n");

 break;
 }
 }
 if (input[0] == '-' && input[1] == '-') {
 printf("opcion larga:%s\n",input);
 }
 printf("%s\n", input);
 }*/

