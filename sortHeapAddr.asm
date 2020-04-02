FORMAT MS64 COFF

PUBLIC SortHeapAddr AS 'sortHeapAddr'

SECTION '.code' CODE READABLE EXECUTABLE

SortHeapAddr:
        ; rcx-in: addr of array
        ; rdx-in: number of items
        ; r8-in: addr of exchange condition function

        ; rbx: addr of array
        ; rbp: temporary
        ; rsi: addr of exchange condition function
        ; rdi: temporary
        ; r12: target idx
        ; r13: child idx
        ; r14: parent idx
        ; r15: number of items

        push  rbx    ; @@@ mem acc
        push  rbp    ; @@@ mem acc
        push  rsi    ; @@@ mem acc
        push  rdi    ; @@@ mem acc
        push  r12    ; @@@ mem acc
        push  r13    ; @@@ mem acc
        push  r14    ; @@@ mem acc
        push  r15    ; @@@ mem acc

        mov  rsi,r8    ; addr of echange condition function
        mov  rbx,rcx    ; addr of array
        mov  r12,rdx    ; number of items
        mov  r15,rdx    ; number of items
        sub  rbx,8    ; heap index starts from 1, so subtract 8
        shr  r12,1    ; start from last index that has child
        jz  _BranNoNeedSort    ; if 'number of items' < 2
        LoopInitialHeap:
            mov  r13,r12    ; point 'target'
            mov  r14,r12    ; point 'target'
            mov  rbp,[rbx + r12*8]    ; store 'target addr' @@@ mem acc
           .LoopHeapify:
                shl  r13,1    ; point 'left child'
                mov  rdi,r13    ; point 'left child'
                cmp  r15,r13
                jc  .BreakLocalHeapDone    ; if 'parent' has no 'child'
                ; 'parent' has 'child'
                jz  .BranLeftChildOnly    ; if 'parent' has only 'left child'
                ; 'parent' has 'right child', compare two children
                inc  rdi    ; point 'right child'
                mov  rcx,[rbx + r13*8]    ; argument 1: 'left child addr' @@@ mem acc
                mov  rdx,[rbx + rdi*8]    ; argument 2: 'right child addr' @@@ mem acc
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rsi    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                cmovnz  r13,rdi    ; if 'function' returns non-zero, then point 'right child'
               .BranLeftChildOnly:
                mov  rcx,rbp    ; argument 1: 'target addr'
                mov  rdx,[rbx + r13*8]    ; argument 2: 'child addr' @@@ mem acc
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rsi    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                jz  .BreakLocalHeapDone    ; if 'function' returns zero
                ; 'function' returns non-zero
                mov  rax,[rbx + r13*8]    ; @@@ mem acc
                mov  [rbx + r14*8],rax    ; copy 'child addr' to 'parent index' @@@ mem acc
                mov  r14,r13    ; 'parent' =now 'child'
                jmp  .LoopHeapify
           .BreakLocalHeapDone:
            mov  [rbx + r14*8],rbp    ; 'parent addr' = 'terget addr' @@@ mem acc
            dec  r12
            jnz  LoopInitialHeap
        LoopHeapSort:
            mov  rax,[rbx + 8]    ; @@@ mem acc
            mov  r14,1    ; point 'first item'
            mov  rbp,[rbx + r15*8]    ; copy 'last item' to 'temporary space' @@@ mem acc
            mov  r13,r14
            mov  [rbx + r15*8],rax    ; copy 'first item' to 'last index' @@@ mem acc
            dec  r15
            jz  _BreakHeapifyDone
           .LoopHeapify:
                shl  r13,1    ; point 'left child'
                mov  rdi,r13    ; point 'left child'
                cmp  r15,r13
                jc  .BreakLocalHeapDone    ; if 'parent' has no 'child'
                ; 'parent' has 'child'
                jz  .BranLeftChildOnly    ; if 'parent' has only 'left child'
                ; 'parent' has 'right child', compare two children
                inc  rdi    ; point 'right child'
                mov  rcx,[rbx + r13*8]    ; argument 1: 'left child addr' @@@ mem acc
                mov  rdx,[rbx + rdi*8]    ; argument 2: 'right child addr' @@@ mem acc
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rsi    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                cmovnz  r13,rdi    ; if 'function' returns non-zero, then point 'right child'
               .BranLeftChildOnly:
                mov  rcx,rbp    ; argument 1: 'target value'
                mov  rdx,[rbx + r13*8]    ; argument 2: 'child addr' @@@ mem acc
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rsi    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                jz  .BreakLocalHeapDone    ; if 'function' returns zero
                ; 'function' returns non-zero
                mov  rax,[rbx + r13*8]    ; @@@ mem acc
                mov  [rbx + r14*8],rax    ; copy 'child addr' to 'parent index' @@@ mem acc
                mov  r14,r13    ; 'parent' =now 'child'
                jmp  .LoopHeapify
           .BreakLocalHeapDone:
            mov  [rbx + r14*8],rbp    ; 'parent addr' = 'terget addr'
            jmp  LoopHeapSort
       _BreakHeapifyDone:
       _BranNoNeedSort:

        pop  r15    ; @@@ mem acc
        pop  r14    ; @@@ mem acc
        pop  r13    ; @@@ mem acc
        pop  r12    ; @@@ mem acc
        pop  rdi    ; @@@ mem acc
        pop  rsi    ; @@@ mem acc
        pop  rbp    ; @@@ mem acc
        pop  rbx    ; @@@ mem acc

        ret    ; end of SortHeapAddr
