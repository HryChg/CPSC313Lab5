# .pos 0x100
# main:
#     irmovq $stackEnd, %rsp
#     irmovq $array, %rdi           # rdi = address of array i.e. &array[0]
#     irmovq $arraySize, %rsi       # rsi = address arraySize
#     mrmovq (%rsi), %rsi           # rsi = arraySize
#     irmovq $resultStart, %rdx     # rdx = address of sa_start
#     irmovq $resultEnd, %rcx       # rcx = address of sa_end
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
    irmovq $1, %r9          # r9 = 1
    subq   %rsi, %r9        # if (size != 1), jump to L1
    jne    L1               #
    rmmovq %rdi, (%rcx)     # *sa_end = array;
    rmmovq %rdi, (%rdx)     # *sa_start = array;
    mrmovq (%rdi), %r13     # r13 = value of first element
    jmp    L9               # goto L9
L1:
    irmovq $2, %r10         # r10 = 2
    rrmovq %rsi, %rbx       # rbx = arraySize
    divq   %r10, %rbx       # rbx = half = arraySize // 2
    irmovq $8, %rbp         # rbp = step, element size
    mulq   %rbx, %rbp       # offset
    rrmovq %rsi, %r9        # r9 = arraySize
    addq   %rdi, %rbp       # *mid = array + half
    irmovq $8, %r8          # r8 = 8
    mulq   %r8, %r9         # r9 = offset
    addq   %rdi, %r9        # *end = array + offset
    subq   %r8, %r9         # *end = array + size - 1
    xorq   %rax, %rax       # set rax = 0, rax is possible "su,"
    rrmovq %rbp, %r11       # ptr = mid (right before loop body starts)
    subq   %r8, %r11        # ptr = mid - 1
    irmovq $0x8000000000000000, %r10
L2:                         # first loop
    rrmovq %r11, %r12       # r12 = ptr
    subq   %rdi, %r12       # ptr = ptr - array
    jl     L4               # jump if less than 0
    mrmovq (%r11), %r12     # r12 = *ptr
    addq   %r12, %rax       # sum += *ptr
    rrmovq %rax, %r12       # r12 = sum
    subq   %r10, %r12       # if (sum <= leftsum)
    jle    L3               # jump to L3
    rrmovq %rax, %r10       # leftsum = sum
    rmmovq %r11, (%rdx)     # *sa_start = ptr
L3:
    subq   %r8, %r11        # ptr--
    jmp    L2               # return to loop L2
L4:
    irmovq $0x8000000000000000, %r13    # some random bs
    rrmovq %rbp, %r11       # r11 = mid
    xorq   %rax, %rax       # rax = 0
L5:                         # second for-loop
    rrmovq %r11, %r12       # ptr = mid
    subq   %r9, %r12        # if (ptr > end)
    jg     L7               # jump to L7
    mrmovq (%r11), %r12     # r12= *ptr
    addq   %r12, %rax       # sum += *ptr
    rrmovq %rax, %r12       # r12 = sum
    subq   %r13, %r12       # if (sum <= rightsum)
    jle    L6               # jump to L6
    rrmovq %rax, %r13       # rightsum = sum
    rmmovq %r11, (%rcx)     # *sa_end = ptr
L6:
    addq   %r8, %r11        # ptr ++
    jmp    L5               # jump to L5
L7:                         # 2nd sum = maxsa
    addq   %r10, %r13       # bestsum = leftsum + rightsum
    rrmovq %rcx, %r14       # r14 = &sa_end
    rrmovq %rsi, %r9        # r9 = &arraySize
    subq   %rbx, %r9        # arraysize - half
    rrmovq %rdx, %r12       # r12 = &sa_start
    rrmovq %rbx, %rsi       # rsi = half
    rrmovq %r9, %rbx        # half = arraysize - half
    pushq  %rdx             # push half to stack
    rrmovq %rsp, %rdx       # rdx = stack pointer, stack pointer = stack pointer - 8
    pushq  %rcx             # push sa_end to stack
    rrmovq %rsp, %rcx       # rcx = stack pointer, stack pointer = stack pointer - 8
    call   maxSubArray      # call maxSubArray
    popq   %rcx             # get sa_end from stack, stack pointer = stack pointer + 8
    popq   %rdx             # get half from stack, stack pointer = stack pointer + 8
    rrmovq %rax, %r9        # r9 = result from maxSubArray
    subq   %r13, %r9        # if (sum <= bestSum)
    jle    L8               # jump to L8
    rrmovq %rax, %r13       # bestsum = sum
    rmmovq %rdx, (%r12)     # *sa_start = &sub_start
    rmmovq %rcx, (%r14)     # *sa_end = &sub_end
L8:                         # 1st sum = maxsa
    rrmovq %rbp, %rdi       # rdi = mid
    rrmovq %rbx, %rsi       # rsi = half
    pushq  %rdx             # push &sub_start to stack, stack pointer = stack pointer - 8
    rrmovq %rsp, %rdx       # rdx = stack pointer
    pushq  %rcx             # push &sub_end to stack, stack pointer = stack pointer - 8
    rrmovq %rsp, %rcx       # rcx = stack pointer
    call   maxSubArray      # call maxSubArray
    popq   %rcx             # rcx = &sub_end, stack pointer = stack pointer + 8
    popq   %rdx             # rdx = &sub_start, stack pointer = stack pointer + 8
    rrmovq %rax, %r9        # bestsum = sum
    subq   %r13, %r9        # if (sum <= bestsum)
    jle    L9               # jump to L9
    rrmovq %rax, %r13       # r13 = bestsum
    rmmovq %rdx, (%r12)     # *sa_start = &sub_start
    rmmovq %rcx, (%r14)     # *sa_end = &sub_end
L9:
    rrmovq %r13, %rax       # rax = r13
    popq   %r14
    popq   %r13
    popq   %r12
    popq   %rbp
    popq   %rbx
    ret                     # return


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
