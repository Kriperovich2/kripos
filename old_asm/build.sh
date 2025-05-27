#!/bin/bash

mkdir -p build
nasm -f bin -Isrc/ src/boot.asm -o build/boot.bin || exit 1
dd if=/dev/zero of=build/disk.img bs=512 count=2880
dd if=build/boot.bin of=build/disk.img conv=notrunc
qemu-system-x86_64 -drive format=raw,file=build/disk.img
