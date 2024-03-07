.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    li t0, 1

    blt a2, t0, err_size

    blt a3, t0, err_stride
    blt a4, t0, err_stride

    slli a3, a3, 2 # distance of element of v0
    slli a4, a4, 2 # distance of element of v1
    mul t0, a3, a2
    add t0, t0, a0 # pointer to end of v0
    li t1, 0 # sum

loop_start:
    
    lw t2, 0(a0)
    lw t3, 0(a1)
    mul t2, t2, t3
    add t1, t1, t2

    add a0, a0, a3
    add a1, a1, a4
    blt a0, t0, loop_start

loop_end:
    mv a0, t1

    ret

err_size:
    li a1, 75
    jal exit2

err_stride:
    li a1, 76
    jal exit2
