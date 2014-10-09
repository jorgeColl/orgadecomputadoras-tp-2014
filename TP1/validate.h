/*
 * validate.h
 *
 *  Created on: 07/10/2014
 *      Author: jorge
 */

#ifndef VALIDATE_H_
#define VALIDATE_H_

int validate (char* text, char** errmsg);
void write_error(int tipo_de_error, char* tag1, char* tag2, int nro_linea, char** errmsg);
#endif /* VALIDATE_H_ */
