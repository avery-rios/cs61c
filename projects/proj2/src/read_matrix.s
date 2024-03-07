.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw ra, 12(sp)

    mv s1, a1 # pointer to rows
    mv s2, a2 # pointer to columns

    mv a1, a0
    li a2, 0
    jal fopen
    li t0, -1
    beq a0, t0, err_fopen
    mv s0, a0 # file descriptor

    addi sp, sp, -8
    mv a1, s0
    mv a2, sp
    li a3, 8
    jal fread
    li t0, 8
    bne a0, t0, err_fread

    lw t0, 0(sp) # number of rows
    lw t1, 4(sp) # number of columns
    addi sp, sp, 8

    sw t0, 0(s1)
    sw t1, 0(s2)

    mul s1, t0, t1
    slli s1, s1, 2  # size of array
    mv a0, s1
    jal malloc
    beq a0, zero, err_malloc
    mv s2, a0 # pointer to matrix

    mv a1, s0
    mv a2, s2
    mv a3, s1
    jal fread
    bne a0, s1, err_fread

    mv a1, s0
    jal fclose
    bne a0, zero, err_fclose

    mv a0, s2

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16

    ret

err_malloc:
    li a1, 88
    jal exit2

err_fopen:
    li a1, 90
    jal exit2

err_fread:
    li a1, 91
    jal exit2

err_fclose:
    li a1, 92
    jal exit2
