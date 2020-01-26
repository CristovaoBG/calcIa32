nasm -f elf -o t2.o t2.asm
ld -m elf_i386 -o t2 t2.o io.o
./t2
