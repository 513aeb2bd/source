FORMAT MS64 COFF

PUBLIC SortHeap AS 'sortHeap'

SECTION '.code' CODE READABLE EXECUTABLE

; MWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWM
; MWM                                                         MWM
; MWM Sort Heap                                               MWM
; MWM if compare function returns non-zero, then exchange     MWM
; MWM                                                         MWM
; MWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWM

SortHeap:
        ; rcx-in: addr of array
        ; rdx-in: number of item
        ; r8-in: size of item [byte]
        ; r9-in: addr of exchange condition function

        ; rbx: addr of array
        ; rbp: temporary
        ; r12: target idx
        ; r13: child idx
        ; r14: parent idx
        ; r15: total size of array

        push  r15    ; @@@ mem acc
        push  r14    ; @@@ mem acc
        push  r13    ; @@@ mem acc
        push  r12    ; @@@ mem acc
        push  rbp    ; @@@ mem acc
        push  rsi    ; @@@ mem acc
        push  rdi    ; @@@ mem acc
        push  rbx    ; @@@ mem acc

        sub  rsp,r8    ; make space for temporary item
        sub  rcx,r8    ; heap idx starts from 1, so subtract 'size of item'
        sub  rsp,18h
        mov  [rsp + 10h],r9    ; addr of exchange condition function @@@ mem acc
        mov  [rsp + 8h],r8    ; size of item [byte] @@@ mem acc
        mov  [rsp + 0h],rcx    ; addr of array @@@ mem acc

        cld    ; rsi and rdi increments when movs intruction
        cmp  rdx,2
        jc  _BranNoNeedSort    ; if 'number of item' < 2
        mov  rbx,rcx    ; address of array
        mov  rax,rdx
        mul  r8
        mov  r12,rax    ; 'target idx' = total size of array
        mov  r15,rax    ; total size of array
        shr  r12,1    ; start from last item that has child
        LoopInitialHeap:    ; make initial heap
            lea  rsi,[rbx + r12]    ; 'target value'
            mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
            lea  rdi,[rsp + 18h]    ; 'temp item'
            @@:    ; 'temp item' = 'terget item'
                movsb
                loop  @r
            mov  r13,r12    ; point 'target'
            mov  r14,r12    ; point 'target'
           .LoopHeapify:
                shl  r13,1    ; point 'left child'
                mov  rbp,r13    ; point 'left child'
                cmp  r15,r13
                jc  .BreakLocalHeapDone    ; if 'parent' has no 'child''
                ; 'parent' has 'child'
                jz  .BranOnlyLeftChild    ; if 'parent' has 'left child' only
                ; 'parent' has 'right child', compare two children
                add  rbp,[rsp + 8h]    ; point 'right child' @@@ mem acc
                mov  rax,[rsp + 10h]    ; point 'exchange condition function' @@@ mem acc
                lea  rcx,[rbx + r13]    ; argument 1: 'left child idx'
                lea  rdx,[rbx + rbp]    ; argument 2: 'right child idx'
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rax    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                cmovnz  r13,rbp    ; if 'function' returns non-zero, then point 'right child'
               .BranOnlyLeftChild:
                mov  rax,[rsp + 10h]    ; point 'exchange condition function' @@@ mem acc
                lea  rcx,[rsp + 18h]    ; argument 1: 'temp idx'
                lea  rdx,[rbx + r13]    ; argument 2: 'child idx'
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rax    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                jz  .BreakLocalHeapDone    ; if 'function' returns zero
                ; need exchange
                lea  rsi,[rbx + r13]    ; 'child idx'
                mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
                lea  rdi,[rbx + r14]    ; 'parent idx'
                @@:    ; 'parent item' = 'child item'
                    movsb
                    loop @r
                mov  r14,r13    ; 'parent idx' = 'child idx'
                jmp .LoopHeapify
           .BreakLocalHeapDone:
            lea  rsi,[rsp + 18h]    ; 'temp item'
            mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
            lea  rdi,[rbx + r14]    ; point 'current item'
            @@:    ; 'current item' = 'temp item'
                movsb
                loop @r
            sub  r12,[rsp + 8h]    ; @@@ mem acc
            jnz  LoopInitialHeap    ; if 'target idx' != 0
        LoopHeapSort:
            lea  rsi,[rbx + r15]    ; point 'last item'
            mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
            lea  rdi,[rsp + 18h]    ; 'temp item'
            @@:    ; 'temp item' = 'last item'
                movsb
                loop @r
            lea  rsi,[rbx]    ; point 'addr of array'
            mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
            lea  rdi,[rbx + r15]    ; point 'last item'
            add  rsi,rcx    ; point 'first item'
            mov  r14,rcx    ; point 'first item'
            mov  r13,rcx    ; point 'first item'
            @@:    ; 'last item' = 'first item'
                movsb
                loop @r
            sub  r15,[rsp + 8h]    ; decrement 'current idx' @@@ mem acc
            jz  _BreakHeapifyDone    ; if 'current idx' == 0
           .LoopHeapify:
                shl  r13,1    ; point 'left child'
                mov  rbp,r13    ; point 'left child'
                cmp  r15,r13
                jc  .BreakLocalHeapDone    ; if 'parent' has no 'child'
                ; 'parent' has 'child'
                jz  .BranOnlyLeftChild    ; if 'parent' has 'left child' only
                ; 'parent' has 'right child', compare two children
                add  rbp,[rsp + 8h]    ; point 'right child' @@@ mem acc
                mov  rax,[rsp + 10h]    ; point 'exchange condition function' @@@ mem acc
                lea  rcx,[rbx + r13]    ; argument 1: 'left child idx'
                lea  rdx,[rbx + rbp]    ; argument 2: 'right child idx'
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rax    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                cmovnz  r13,rbp    ; if 'function' returns non-zero, then point 'right child'
               .BranOnlyLeftChild:
                mov  rax,[rsp + 10h]    ; point 'exchange condition function' @@@ mem acc
                lea  rcx,[rsp + 18h]    ; argument 1: 'temp idx'
                lea  rdx,[rbx + r13]    ; argument 2: 'child idx'
                sub  rsp,20h    ; @@@ amd64 windows calling convention
                call  rax    ; call 'exchange condition function' @@@ mem acc
                add  rsp,20h    ; @@@ amd64 windows calling convention
                test  rax,rax
                jz  .BreakLocalHeapDone    ; if 'function' returns zero
                ; need exchange
                lea  rsi,[rbx + r13]    ; point 'child'
                mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
                lea  rdi,[rbx + r14]    ; point 'parent'
                @@:    ; 'parent item' = 'child item'
                    movsb
                    loop @r
                mov  r14,r13    ; 'parent idx' = 'child idx'
                jmp  .LoopHeapify
           .BreakLocalHeapDone:
            lea  rsi,[rsp + 18h]    ; point 'temp item'
            mov  rcx,[rsp + 8h]    ; 'size of item' @@@ mem acc
            lea  rdi,[rbx + r14]    ; point 'parent item'
            @@:    ; 'parent item' = 'temp item'
                movsb
                loop @r
            jmp  LoopHeapSort
       _BreakHeapifyDone:
       _BranNoNeedSort:

        add  rsp,[rsp + 8h]    ; @@@ mem acc
        add  rsp,18h

        pop  rbx    ; @@@ mem acc
        pop  rdi    ; @@@ mem acc
        pop  rsi    ; @@@ mem acc
        pop  rbp    ; @@@ mem acc
        pop  r12    ; @@@ mem acc
        pop  r13    ; @@@ mem acc
        pop  r14    ; @@@ mem acc
        pop  r15    ; @@@ mem acc

        ret    ; end of sortHeap
