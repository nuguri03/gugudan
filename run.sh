nasm -f elf64 -g -F dwarf gugudan.asm -o gugudan.o
ld gugudan.o -o gugudan
./gugudan