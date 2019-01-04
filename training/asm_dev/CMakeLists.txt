cmake_minimum_required(VERSION 3.8)
project(asm_dev)

enable_language(ASM)

set(CMAKE_C_STANDARD 90)
set(CMAKE_C_FLAGS -m32)

set(SOURCE_FILES main.c asm/asm.asm libs/test.c)
add_executable(asm_dev ${SOURCE_FILES})