# .pos 0x100
# main:
#     irmovq $stackEnd, %rsp
#     irmovq $array, %rdi
#     irmovq $arraySize, %rsi
#     mrmovq (%rsi), %rsi
#     irmovq $resultStart, %rdx
#     irmovq $resultEnd, %rcx
#     call   maxSubArray
#     irmovq $resultSum, %r8
#     rmmovq %rax, (%r8)
#     halt

# .pos 0x1000
maxSubArray:
    pushq  %rbx
    pushq  %rbp
    pushq  %r12
    pushq  %r13
    pushq  %r14
    irmovq $1, %r9
    subq   %rsi, %r9
    jne    L1
    rmmovq %rdi, (%rcx)
    rmmovq %rdi, (%rdx)
    mrmovq (%rdi), %r13
    jmp    L9
L1:
    irmovq $2, %r10
    rrmovq %rsi, %rbx
    divq   %r10, %rbx
    irmovq $8, %rbp
    mulq   %rbx, %rbp
    addq   %rdi, %rbp
    irmovq $8, %r8
    rrmovq %rsi, %r9
    mulq   %r8, %r9
    addq   %rdi, %r9
    subq   %r8, %r9
    xorq   %rax, %rax
    irmovq $0x8000000000000000, %r10
    rrmovq %rbp, %r11
    subq   %r8, %r11
L2:
    rrmovq %r11, %r12
    subq   %rdi, %r12
    jl     L4
    mrmovq (%r11), %r12
    addq   %r12, %rax
    rrmovq %rax, %r12
    subq   %r10, %r12
    jle    L3
    rrmovq %rax, %r10
    rmmovq %r11, (%rdx)
L3:
    subq   %r8, %r11
    jmp    L2
L4:
    irmovq $0x8000000000000000, %r13
    rrmovq %rbp, %r11
    xorq   %rax, %rax
L5:
    rrmovq %r11, %r12
    subq   %r9, %r12
    jg     L7
    mrmovq (%r11), %r12
    addq   %r12, %rax
    rrmovq %rax, %r12
    subq   %r13, %r12
    jle    L6
    rrmovq %rax, %r13
    rmmovq %r11, (%rcx)
L6:
    addq   %r8, %r11
    jmp    L5
L7:
    addq   %r10, %r13
    rrmovq %rcx, %r14
    rrmovq %rsi, %r9
    subq   %rbx, %r9
    rrmovq %rdx, %r12
    rrmovq %rbx, %rsi
    rrmovq %r9, %rbx
    pushq  %rdx
    rrmovq %rsp, %rdx
    pushq  %rcx
    rrmovq %rsp, %rcx
    call   maxSubArray
    popq   %rcx
    popq   %rdx
    rrmovq %rax, %r9
    subq   %r13, %r9
    jle    L8
    rrmovq %rax, %r13
    rmmovq %rdx, (%r12)
    rmmovq %rcx, (%r14)
L8:
    rrmovq %rbp, %rdi
    rrmovq %rbx, %rsi
    pushq  %rdx
    rrmovq %rsp, %rdx
    pushq  %rcx
    rrmovq %rsp, %rcx
    call   maxSubArray
    popq   %rcx
    popq   %rdx
    rrmovq %rax, %r9
    subq   %r13, %r9
    jle    L9
    rrmovq %rax, %r13
    rmmovq %rdx, (%r12)
    rmmovq %rcx, (%r14)
L9:
    rrmovq %r13, %rax
    popq   %r14
    popq   %r13
    popq   %r12
    popq   %rbp
    popq   %rbx
    ret


# .pos 0x2000
# array:
#     .quad 13
#     .quad -3
#     .quad -25
#     .quad -20
#     .quad -3
#     .quad -16
#     .quad -23
#     .quad 18
#     .quad 20
#     .quad -7
#     .quad 12
#     .quad -5
#     .quad -22
#     .quad 15
#     .quad -4
#     .quad 7
# arraySize:
#     .quad 16
#
# .pos 0x2500
# resultStart:
#     .quad 0
# resultEnd:
#     .quad 0
# resultSum:
#     .quad 0
#
# .pos 0x4000
# stack:
#     .quad 0, 1000
# stackEnd:
#     .quad 0
