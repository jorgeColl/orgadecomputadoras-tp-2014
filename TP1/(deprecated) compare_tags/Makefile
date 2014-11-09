CCARGS = -Wall -g -c
PROG = tp1


tp1: main.o compare_tags.o
	$(CC) compare_tags.o main.o -o $(PROG)

main.o: main.c
	$(CC) $(CCARGS) main.c

compare_tags.o: compare_tags.S
	$(CC) $(CCARGS) compare_tags.S

clean:
	rm -rf *.o $(PROG)
