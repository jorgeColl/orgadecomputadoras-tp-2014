CCARGS = -Wall -g -c
PROG = tp1


tp1: main.o validate.o
	$(CC) validate.o main.o -o $(PROG)

main.o: main.c
	$(CC) $(CCARGS) main.c

validate.o: validate.S
	$(CC) $(CCARGS) validate.S

clean:
	rm -rf *.o $(PROG)
