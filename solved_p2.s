# ---------------------------------------------------------------
long maxsa(long *array, long size, long **sa_start, long **sa_end) {
  long best_sum = 0;
  long current_sum = 0;
  long** best_start = 0;
  long** best_end = 0;
  long *ptr;
  long *end = array + size - 1;

  for (ptr = array; ptr <= end; ptr++) {
    long x = *ptr;
    if (0 > current_sum) {
      current_sum = x;
      best_start = best_end;
    } else {
      current_sum = current_sum + x;
    }
    if (best_sum < current_sum) {
      best_sum = current_sum;
      sa_start = best_start;
      sa_end = best_end;
    }
  }
  return best_sum;
}

# ---------------------------------------------------------------
rdi = *array
rsi = array size
rdx = sa_start
rcx = sa_end

r8 = ptr
r9 = end

r10 = best_sum
r11 = current_sum

rax = return

** Callee Saved Registers **
r12 = placceholder
r13 = best_start
r14 = best_end

** Can use rdi as a placeholder, only after the for loop starts
# ---------------------------------------------------------------


.pos 0x100
main:
    irmovq $stackEnd, %rsp
    irmovq $array, %rdi           # rdi = &array[0]
    irmovq $arraySize, %rsi       # rsi = &arraySize
    mrmovq (%rsi), %rsi           # rsi = arraySize
    irmovq $resultStart, %rdx     # rdx = &sa_start
    irmovq $resultEnd, %rcx       # rcx = &sa_end
    call   maxSubArray
    irmovq $resultSum, %r8        # r8 = &resultSum
    rmmovq %rax, (%r8)            # resultSum = ret value from maxSubArrry
    halt

# .pos 0x1000
maxSubArray:

    # init end, sa_start, sa_end,
    pushq %r14              # save r14 value to stack
    irmovq $0, %r10         # best_sum = 0
    irmovq $0, %r11         # current_sum = 0
    pushq %r13              # save r13 value to stack
    rrmovq %rdi, %r9        # r9 = &array
    pushq %r12              # save r12 value to stack
    irmovq $8, %r12         # r12 = 8
    mulq   %r12, %rsi       # rsi = offset
    addq   %rsi, %r9        # r9 = &array + offset
    subq   %r12, %r9        # r9 = end = &array + offset - 8
    rmmovq %rdi, (%rdx)     # sa_start = &array[0]
    rmmovq %rdi, (%rcx)     # sa_end = &array[0]
    rrmovq %rdi, %r13       # best_start = &array[0]
    rrmovq %rdi, %r14       # best_end = &array[0]

    # Init Ptr
    rrmovq %rdi, %r8        # r8 = ptr = &array[0]

LOOP_START: # for (ptr = array; ptr <= end; ptr++) {...}

LOOP_CONDITION:
    rrmovq %r9, %r12        # r12 = end
    subq   %r8, %r12        # r12 = end - ptr
    jl     EXIT_LOOP        # if end < ptr, goto EXIT_LOOP

INIT_X:
    mrmovq (%r8), %rdi      # x = *ptr

FIRST_IF:
    irmovq $0, %r12         # r12 = 0
    rrmovq %r11, %rax       # rax = current_sum
    subq   %rax, %r12       # if (0 > current_sum) goto L2
    jle    L2
    rrmovq %rdi, %r11       # current_sum = x
    rrmovq %r8, %r13        # best_start = best_end
    jmp       SECOND_IF

L2:
    addq %r11, %rdi         # rdi = current_sum + x
    rrmovq %rdi, %r11       # current_sum = current_sum + x

SECOND_IF:
    rrmovq %r10, %rdi       # rdi = best_sum
    subq   %r11, %rdi       # if (best_sum >= current_sum) goto LOOP_END
    jge LOOP_END
    rrmovq %r11, %r10       # best_sum = current_sum
    rmmovq %r13, (%rdx)     # sa_start = best_start
    rmmovq %r8, (%rcx)      # sa_end = best_end

LOOP_END:
    irmovq $8, %r12
    addq %r12, %r8          # ptr++
    jmp    LOOP_START       # goto LOOP_START

EXIT_LOOP:
    popq %r12               # restore value of r12
    popq %r13               # restore value of r13
    rrmovq %r10, %rax       # save best_sum to rax
    popq %r14               # restore value of r14
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
