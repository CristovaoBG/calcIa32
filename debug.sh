nasm -f elf -g -F dwarf t2.asm
ld -m elf_i386 -o t2 t2.o
gdb t2
