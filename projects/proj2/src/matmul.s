.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    li t0, 1
    blt a1, t0, err_mat0
    blt a2, t0, err_mat0 # check dimensions of matrix 0

    blt a4, t0, err_mat1
    blt a5, t0, err_mat1 # check dimensions of matrix 1

    bne a2, a4, err_dim # check if the dimensions match

    # Prologue
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)
    
    mul s0, a1, a2
    slli s0, s0, 2
    add s0, a0, s0 # pointer to end of matrix 0
    mv s1, a0 # pointer to current row of matrix 0
    slli s2, a2, 2 # size of row of matrix 0

    mv s3, a3 # pointer to first column of matrix 1
    mv s4, a5 # stride of matrix 1
    slli s5, a5, 2
    add s5, a3, s5 # pointer to end of first column of matrix 1
    mv s6, a3 # pointer to current column of matrix 1

    mv s7, a6 # pointer to current result
    mv s8, a2 # size of dot product

outer_loop:
    mv s6, s3

inner_loop:
    mv a0, s1
    mv a1, s6
    mv a2, s8
    li a3, 1
    mv a4, s4
    jal dot

    sw a0, 0(s7)

    addi s7, s7, 4
    addi s6, s6, 4
    blt s6, s5, inner_loop

    add s1, s1, s2
    blt s1, s0, outer_loop

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40

    ret

err_mat0:
    li a1, 72
    jal exit2

err_mat1:
    li a1, 73
    jal exit2

err_dim:
    li a1, 74
    jal exit2
