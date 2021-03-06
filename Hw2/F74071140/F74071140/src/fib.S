main:
    addi $a0, $zero, 10 # n = 10
    jal fib          # call fib(10)
    j exit

fib:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)    # Save $ra register into stack
    
    slti $t0, $a0, 2    # if n<2, then t0=1, else t0=0
    beq $t0, $zero, L1  # if the statement above is true, then do the next instruction, else jump to L1
    add $v0, $v0, $a0  # return n+previous value
    addi $sp, $sp, 4   # recover the stack
    jr $ra
L1:
    addi $a0, $a0, -1  # call fib(n-1)
    jal fib  # call fib with n-1
    addi $a0, $a0, 1  # recover the original n 
    addi $a0, $a0, -2  # call fib(n-2) 
    jal fib  
    addi $a0, $a0, 2
    
    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
#    add $v0, $v0, $zero  
    jr $ra

exit:
