.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    li t0, 1
    bge a1, t0, loop_start

    li a1, 78
    jal exit2

loop_start:
    
    mv t0, a0 # pointer to current element
    slli t1, a1, 2
    add t1, t1, a0 # pointer to end element

loop_continue:

    lw t2, 0(t0)
    bge t2, zero, loop_end
    mv t2, zero

loop_end:
    sw t2, 0(t0)
    addi t0, t0, 4
    blt t0, t1, loop_continue

    # Epilogue

    
	ret
