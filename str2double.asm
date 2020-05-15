format ms64 coff

public str2double


section '.code' code readable executable

str2double:
        ; rcx-in: addr of 'numb str'

        test  rcx,rcx
        jz  _BranReturn

        push  rbx    ; @@@ mem acc
        push  rbp    ; @@@ mem acc
        mov  rbp,rsp

        mov  rbx,rcx
        xor  rax,rax
        xor  r8,r8
        mov  r9,10
        LoopDecInt2Bin:
            mov  r8b,[rbx]    ; @@@ mem acc
            inc  rbx
            cmp  r8b,2eh
            jz  _BreakDecInt2Bin
            mul  r9
            sub  r8b,30h
            add  rax,r8
            jmp  LoopDecInt2Bin
        ; rax = binary conversion of integer decimal 'numb str'
       _BreakDecInt2Bin:
        xor  rdx,rdx
        LoopCountFrac:
            mov  r8b,[rbx + rdx]    ; @@@ mem acc
            inc  rdx
            test  r8b,r8b
            jnz  LoopCountFrac
        ; rdx = length of fraction decimal 'numb str'
        sub  rsp,rdx
        mov  r9,rdx
        LoopInitFrac:
            dec  rdx
            mov  r8b,[rbx + rdx]    ; @@@ mem acc
            mov  [rsp + rdx],r8b    ; @@@ mem acc
            jnz  LoopInitFrac
        ; fraction numbers copied to stack
       _LableInit2xNumb:
        sub  rsp,11    ; extra 1 byte of space
        mov  rdx,3432303836343230h
        mov  [rsp],rdx    ; store '02468024' @@@ mem acc
        shr  rdx,24    ; dx = 3836h
        mov  [rsp + 8],dx    ; store '68' @@@ mem acc
       _LableCheckZeroInt:
        test  rax,rax
        jz  _BranIntegerZero    ; if integer part is 0
       _LableExponent:
        xor  r8,r8
        mov  rdx,rax
        mov  cl,53    ; 53 is frac starting bit + 1 in float64 format
        LoopCountBit:
            inc  r8
            shr  rdx,1
            jnz  LoopCountBit
        ; r8 = count of binary digit of int
        sub  rcx,r8    ; shift left value to position in 52th bit
        shl  rax,cl
        add  r8,3feh
        btr  rax,52    ; clear 52th bit
        shl  r8,52
        dec  cl    ; cl = next frac bit shift count
        or  rax,r8    ; add exponent
        jmp  _LabelRestFrac    ; calculate rest frac
       _BranIntegerZero:
        xor  r9,r9
        mov  ax,3feh
        LoopFirstNonZeroBit:
            mov  r8b,[rsp + 11]    ; get first digit of frac @@@ mem acc
            xor  rdx,rdx
           .LoopDoubleFrac:
                mov  r9b,[rsp + rdx + 11]    ; @@@ mem acc
                test  r9b,r9b
                jz  .BreakDoubleFrac
                cmp  r9b,35h
                setnc  cl    ; carry
                add  [rsp + rdx + 10],cl    ; @@@ mem acc
                and  r9b,0fh    ; character to number
                mov  r9b,[rsp + r9]    ; get 2x of digit @@@ mem acc
                mov  [rsp + rdx + 11],r9b    ; update digit @@@ mem acc
                inc  rdx
                jmp  .LoopDoubleFrac
           .BreakDoubleFrac:
            cmp  r8b,35h
            jnc  _BreakFirstNonZeroBit
            dec  eax
            jmp  LoopFirstNonZeroBit
       _BreakFirstNonZeroBit:
        shl  rax,52
        mov  cl,51
       _LabelRestFrac:
        LoopFillFrac:
            xor  r9,r9
            mov  r8b,[rsp + 11]    ; get first digit of frac @@@ mem acc
            xor  rdx,rdx
           .LoopDoubleFrac:
                mov  r9b,[rsp + rdx + 11]    ; @@@ mem acc
                test  r9b,r9b
                jz  .BreakDoubleFrac
                cmp  r9b,35h
                setnc  ch    ; carry
                add  [rsp + rdx + 10],ch    ; @@@ mem acc
                and  r9b,0fh
                mov  r9b,[rsp + r9]    ; get 2x of digit @@@ mem acc
                inc  rdx
                mov  [rsp + rdx + 10],r9b    ; @@@ mem acc
                jmp  .LoopDoubleFrac
           .BreakDoubleFrac:
            cmp  r8b,35h
            setnc  r9b
            shl  r9,cl
            or  rax,r9
            sub  cl,1
            jnc  LoopFillFrac    ; if shift count < 0
       _LabelCheckCarry:
        mov  r8b,[rsp + 11]    ; @@@ mem acc
        cmp  r8b,35h
        setnc  r9b
        add  rax,r9

        mov  rsp,rbp
        pop  rbp    ; @@@ mem acc
        pop  rbx    ; @@@ mem acc

       _BranReturn:
        ret
