cmake_minimum_required(VERSION 2.8)
project(bootloader C)


set(CMAKE_ASM_NASM_LINK_EXECUTABLE "clang -nostdlib -m16 -T ${CMAKE_SOURCE_DIR}/linker.ld -target i686-elf-none <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf32)
enable_language(ASM_NASM)

include_directories(PRIVATE ${CMAKE_SOURCE_DIR}/inc)
include_directories(PRIVATE SYSTEM ${CMAKE_SOURCE_DIR}/inc)

add_library(lib STATIC "lib/memory.asm" "lib/console.asm")
#add_library(console STATIC "lib/console.asm")

link_libraries(lib)

add_custom_target(run
    sudo qemu-system-x86_64 -smp cpus=2,threads=1 -drive format=raw,file=boot.bin -m 2G -cpu host --enable-kvm
)

add_executable(boot.bin
	src/boot.asm
	src/stage.asm
)


# set_property(TARGET boot.bin PROPERTY C_STANDARD 11)

