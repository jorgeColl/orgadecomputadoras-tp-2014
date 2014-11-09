CCARGS = -Wall -g -c
PROG = tp1


tp1: main.o validate.o mymalloc.o
	$(CC) mymalloc.o validate.o main.o -o $(PROG)

main.o: main.c
	$(CC) $(CCARGS) main.c

validate.o: validate.S
	$(CC) $(CCARGS) validate.S

mymalloc.o: mymalloc.S
	$(CC) $(CCARGS) mymalloc.S

clean:
	rm -rf *.o $(PROG)
