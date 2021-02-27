.pos 0x100
main:
    irmovq $stackEnd, %rsp
    irmovq $array, %rdi           # rdi = address of array i.e. &array[0]
    irmovq $arraySize, %rsi       # rsi = address arraySize
    mrmovq (%rsi), %rsi           # rsi = arraySize
    irmovq $resultStart, %rdx     # rdx = address of sa_start
    irmovq $resultEnd, %rcx       # rcx = address of sa_end
    call   maxSubArray
    irmovq $resultSum, %r8
    rmmovq %rax, (%r8)
    halt

.pos 0x1000
maxSubArray:
    pushq  %r13
    irmovq $1, %r9          # r9 = 1
    pushq  %r12
    subq   %rsi, %r9        # if (size != 1), jump to L1
    pushq  %r14
    jne    L1               #
    mrmovq (%rdi), %r13     # r13 = value of first element
    rmmovq %rdi, (%rcx)     # *sa_end = array;
    rmmovq %rdi, (%rdx)     # *sa_start = array;
    jmp    L9               # goto L9
L1:
    pushq  %rbx
    irmovq $2, %r10         # r10 = 2
    rrmovq %rsi, %rbx       # rbx = arraySize
    pushq  %rbp
    divq   %r10, %rbx       # rbx = half = arraySize // 2
    irmovq $8, %rbp         # rbp = step, element size
    mulq   %rbx, %rbp       # offset
    rrmovq %rsi, %r9        # r9 = arraySize
    addq   %rdi, %rbp       # *mid = array + half
    irmovq $8, %r8          # r8 = 8
    mulq   %r8, %r9         # r9 = offset
    rrmovq %rbp, %r11       # ptr = mid (right before loop body starts)
    addq   %rdi, %r9        # *end = array + offset
    xorq   %rax, %rax       # set rax = 0, rax is possible "su,"
    subq   %r8, %r9         # *end = array + size - 1
    subq   %r8, %r11        # ptr = mid - 1
    irmovq $0x8000000000000000, %r10 # leftsum = LONG_MIN
    irmovq $0x8000000000000000, %r13 # rightsum = LONG_MIN
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
    rrmovq %rdx, %r12       # r12 = &sa_start
    jle    L6               # jump to L6
    rrmovq %rax, %r13       # rightsum = sum
    rmmovq %r11, (%rcx)     # *sa_end = ptr
L6:
    addq   %r8, %r11        # ptr ++
    jmp    L5               # jump to L5
L7:                         # 1st sum = maxsa
    pushq  %rdx             # push &sa_start to stack, stack pointer = stack pointer - 8
    rrmovq %rsi, %r9        # r9 = arraySize
    rrmovq %rcx, %r14       # r14 = &sa_end
    subq   %rbx, %r9        # arraysize - half
    rrmovq %rsp, %rdx       # rdx = stack pointer
    pushq  %rcx             # push sa_end to stack, stack pointer = stack pointer - 8
    rrmovq %rbx, %rsi       # rsi = offset
    addq   %r10, %r13       # bestsum = leftsum + rightsum
    rrmovq %r9, %rbx        # rbx = arraysize - half
    rrmovq %rsp, %rcx       # rcx = stack pointer
    call   maxSubArray      # call maxSubArray
    popq   %rcx             # get sa_end from stack, stack pointer = stack pointer + 8
    rrmovq %rax, %r9        # r9 = result from maxSubArray
    subq   %r13, %r9        # if (sum <= bestSum)
    popq   %rdx             # get half from stack, stack pointer = stack pointer + 8
    jle    L8               # jump to L8
    rmmovq %rdx, (%r12)     # *sa_start = &sub_start
    rrmovq %rax, %r13       # bestsum = sum
    rmmovq %rcx, (%r14)     # *sa_end = &sub_end
L8:                         # 2nd sum = maxsa
    pushq  %rdx             # push &sub_start to stack, stack pointer = stack pointer - 8
    rrmovq %rbp, %rdi       # rdi = mid
    rrmovq %rsp, %rdx       # rdx = stack pointer
    pushq  %rcx             # push &sub_end to stack, stack pointer = stack pointer - 8
    rrmovq %rbx, %rsi       # rsi = half
    rrmovq %rsp, %rcx       # rcx = stack pointer
    call   maxSubArray      # call maxSubArray
    popq   %rcx             # rcx = &sub_end, stack pointer = stack pointer + 8
    popq   %rdx             # rdx = &sub_start, stack pointer = stack pointer + 8
    rrmovq %rax, %r9        # bestsum = sum
    popq   %rbp
    subq   %r13, %r9        # if (sum <= bestsum)
    popq   %rbx
    jle    L9               # jump to L9
    rmmovq %rdx, (%r12)     # *sa_start = &sub_start
    rrmovq %rax, %r13       # r13 = bestsum
    rmmovq %rcx, (%r14)     # *sa_end = &sub_end
L9:
    popq   %r14
    popq   %r12
    rrmovq %r13, %rax       # rax = r13
    popq   %r13
    ret                     # return


.pos 0x2000
array:
    .quad 13
    .quad -3
    .quad -25
    .quad -20
    .quad -3
    .quad -16
    .quad -23
    .quad 18
    .quad 20
    .quad -7
    .quad 12
    .quad -5
    .quad -22
    .quad 15
    .quad -4
    .quad 7
arraySize:
 .quad 16

.pos 0x2500
resultStart:
    .quad 0
resultEnd:
    .quad 0
resultSum:
    .quad 0
.pos 0x4000
stack:
    .quad 0, 1000
stackEnd:
    .quad 0
