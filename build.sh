#!/bin/bash
Name=$1
nasm -f elf64 -F stabs $Name.asm
ld -o $Name $Name.o
