.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    li t0, 1
    bge a1, t0, start

    li a1, 77
    jal exit2

start:

    lw t0, 0(a0) # max element
    li t1, 0 # index of max element
    addi t2, a0, 4 # pointer to current element
    li t3, 1 # index of current element

loop_start:
    bge t3, a1, loop_end

    lw t4, 0(t2)
    blt t4, t0, loop_continue
    mv t0, t4
    mv t1, t3


loop_continue:
    addi t2, t2, 4
    addi t3, t3, 1
    j loop_start


loop_end:
    mv a0, t1
    ret
