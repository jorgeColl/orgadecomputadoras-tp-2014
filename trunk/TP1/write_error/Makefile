CCARGS = -Wall -g -c
PROG = tp1


tp1: main.o write_error.o
	$(CC) write_error.o main.o -o $(PROG)

main.o: main.c
	$(CC) $(CCARGS) main.c

write_error.o: write_error.S
	$(CC) $(CCARGS) write_error.S

clean:
	rm -rf *.o $(PROG)
