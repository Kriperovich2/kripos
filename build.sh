#!/bin/bash

echo "Building KripOS ISO..."

# Удаляем старую папку build если существует
rm -rf build

# Создаем директории для сборки
mkdir -p build/iso/boot/grub

# Компилируем загрузчик
nasm -f bin src/boot.asm -o build/KripOS.bin

# Проверяем успешность компиляции
if [ ! -f "build/KripOS.bin" ]; then
    echo "Error: Compilation failed!"
    exit 1
fi

# Создаем загрузочный образ дискеты (1.44MB)
dd if=/dev/zero bs=512 count=2880 of=build/floppy.img 2>/dev/null
dd if=build/KripOS.bin of=build/floppy.img conv=notrunc 2>/dev/null

# Копируем floppy.img в ISO
cp build/floppy.img build/iso/

# Копируем memdisk (часть syslinux)
# путь может отличаться в зависимости от дистрибутива:
# в Ubuntu/Debian обычно /usr/lib/syslinux/memdisk
# в Arch /usr/lib/syslinux/bios/memdisk
if [ -f /usr/lib/syslinux/memdisk ]; then
    cp /usr/lib/syslinux/memdisk build/iso/
elif [ -f /usr/lib/syslinux/bios/memdisk ]; then
    cp /usr/lib/syslinux/bios/memdisk build/iso/
else
    echo "Error: memdisk not found. Install syslinux package."
    exit 1
fi

# Создаем конфигурацию GRUB
cat > build/iso/boot/grub/grub.cfg << EOF
set timeout=10
set default=0

menuentry "Launch KripOS" {
    linux16 /memdisk
    initrd16 /floppy.img
}

menuentry "Power OFF" {
    halt
}

menuentry "Reboot" {
    reboot
}
EOF

# Создаем ISO образ
grub-mkrescue -o build/KripOS.iso build/iso/ 2>/dev/null

echo "Build complete!"
echo "ISO image: build/KripOS.iso"
echo "Run with: qemu-system-i386 -cdrom build/KripOS.iso"
