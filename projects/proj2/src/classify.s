.globl classify

.text

# read matrix Returns
# a0: pointer
# a1: rows
# a2: columns
read_m:
    addi sp, sp, -12,
    sw ra, 8(sp)

    mv a1, sp
    addi a2, sp, 4
    jal read_matrix
    lw a1, 0(sp)
    lw a2, 4(sp)
    
    lw ra, 8(sp)
    addi sp, sp, 12
    ret

classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    addi sp, sp, -44
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw ra, 40(sp)


    li t0, 5
    bne a0, t0, err_args

    mv s0, a2 # whether should print the classification
    mv s1, a1 # argv

    # ===== m0 * input
    lw a0, 12(s1)
    jal read_m
    mv s2, a0 # input matrix
    mv s3, a1 # input row
    mv s4, a2 # input column

    lw a0, 4(s1)
    jal read_m
    mv s5, a0 # m0 matrix
    mv s6, a1 # m0 row
    mv s7, a2 # m0 column

    mul s9, s6, s4 # len(m0 * i)
    slli a0, s9, 2
    jal malloc
    beq a0, zero, err_malloc
    mv s8, a0 # m0 * input matrix

    mv a0, s5
    mv a1, s6
    mv a2, s7
    mv a3, s2
    mv a4, s3
    mv a5, s4
    mv a6, s8
    jal matmul

    mv a0, s2
    jal free # free input
    mv a0, s5
    jal free # free m0

    mv s2, s8 # m0 * i
    mv s3, s6 # row(m0 * i)
    # col(m0 * i) = col(i) which is in s4

    # ===== relu
    mv a0, s2
    mv a1, s9
    jal relu


    # ===== m1 * hidden
    lw a0, 8(s1)
    jal read_m
    mv s5, a0 # m1 matrix
    mv s6, a1 # row(m1)
    mv s7, a2 # col(m1)

    mul s9, s6, s4 # len (m1 * relu (m0 * i))
    slli a0, s9, 2
    jal malloc
    beq a0, zero, err_malloc
    mv s8, a0

    mv a0, s5
    mv a1, s6
    mv a2, s7
    mv a3, s2
    mv a4, s3
    mv a5, s4
    mv a6, s8
    jal matmul

    mv a0, s2
    jal free # free m0 * i
    mv a0, s5
    jal free # free m1

    mv s2, s8 # score
    mv s3, s6 # row(score)

    # ===== argmax
    mv a0, s2
    mv a1, s9
    jal argmax
    
    mv s5, a0 # classification

    # ===== output
    lw a0, 16(s1)
    mv a1, s2
    mv a2, s3
    mv a3, s4
    jal write_matrix

    mv a0, s2
    jal free # free(score)

    bne s0, zero, finish

    mv a1, s5
    jal print_int
    li a1, '\n'
    jal print_char

finish:
    mv a0, s5

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw ra, 40(sp)
    addi sp, sp, 44

    ret

err_malloc:
    li a1, 88
    jal exit2

err_args:
    li a1, 89
    jal exit2
