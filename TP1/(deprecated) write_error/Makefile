CCARGS = -Wall -g -c
PROG = tp1


tp1: main.o write_error.o mymalloc.o
	$(CC) write_error.o main.o mymalloc.o -o $(PROG)

main.o: main.c
	$(CC) $(CCARGS) main.c

write_error.o: write_error.S
	$(CC) $(CCARGS) write_error.S

mymalloc.o: mymalloc.S
	$(CC) $(CCARGS) mymalloc.S

clean:
	rm -rf *.o $(PROG)
