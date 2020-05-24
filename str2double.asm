format ms64 coff

public str2double


section '.code' code readable executable

; stack structune
; (top)|30|32|34|36|38|30|32|34|36|38|frac...

str2double:
        ; rcx-in: addr of 'numb str'

       _LabelArgumentCheck:
        test  rcx,rcx
        jz  _BranReturn

        push  rbp    ; @@@ mem acc
        mov  rbp,rsp

        xor  rax,rax
        xor  r8,r8
        mov  r9,10
        LoopIntDec2Bin:
            mov  r8b,[rcx]    ; get int ascii @@@ mem acc
            inc  rcx    ; point next int ascii
            cmp  r8b,2eh
            jz  _BreakDecInt2Bin    ; if ascii == '.'
            mul  r9    ; shift dec number left by 1
            and  r8b,0fh    ; ascii to number
            add  rax,r8    ; add to dec number
            jmp  LoopIntDec2Bin
        ; rax = int dec to bin
        ; rcx = addr of first frac 'numb str'
       _BreakDecInt2Bin:
        xor  rdx,rdx
        LoopCountFrac:
            mov  r8b,[rcx + rdx]    ; get frac ascii @@@ mem acc
            inc  rdx    ; point next frac ascii
            test  r8b,r8b
            jnz  LoopCountFrac    ; if ascii == null
        ; rdx = length of dec frac including null
        sub  rsp,rdx    ; make space for frac ascii including null
        LoopCopyFrac:
            dec  rdx    ; point previous frac ascii
            mov  r8b,[rcx + rdx]    ; copy frac ascii @@@ mem acc
            mov  [rsp + rdx],r8b    ; paste frac ascii @@@ mem acc
            jnz  LoopCopyFrac    ; until all frac ascii copied
       _LabelInit2xNumb:
        sub  rsp,11    ; make 10 + 1 byte of space
        mov  rdx,3432303836343230h
        mov  [rsp],rdx    ; store '02468024' @@@ mem acc
        shr  rdx,24
        mov  [rsp + 8],dx    ; store '68' @@@ mem acc
       _LableCheckZeroInt:
        test  rax,rax
        jz  _BranIntZero    ; if int == 0
       _LabelExp:
        xor  r8,r8
        mov  rdx,rax
        mov  cl,53    ; 53 is exp least significant bit + 1
        LoopCountBit:
            inc  r8
            shr  rdx,1    ; count 1 bit
            jnz  LoopCountBit    ; if all bits counted
        ; r8 = number of figures of bin int
        ; r8 >= 1
        sub  rcx,r8
        shl  rax,cl    ; put most significant bit of int on 52nd bit
        add  r8,3feh    ; add (bias - 1)
        btr  rax,52    ; clear 52nd bit
        shl  r8,52    ; put exp to exp position
        dec  cl    ; cl = next frac bit shift count
        or  rax,r8    ; insert exp
        jmp  _LabelRestFrac
       _BranIntZero:
        xor  r9,r9
        mov  ax,3feh    ; exp start from (bias - 1)
        LoopFirstNonZeroBit:
            mov  r8b,[rsp + 11]    ; get first frac ascii @@@ mem acc
            xor  rdx,rdx
           .LoopDoubleFrac:
                mov  r9b,[rsp + rdx + 11]    ; get frac ascii @@@ mem acc
                test  r9b,r9b
                jz  .BreakDoubleFrac    ; if ascii == null
                cmp  r9b,35h
                setnc  cl    ; if ascii >= '5'
                add  [rsp + rdx + 10],cl    ; add carry @@@ mem acc
                and  r9b,0fh    ; ascii to number
                mov  r9b,[rsp + r9]    ; get 2x of number @@@ mem acc
                mov  [rsp + rdx + 11],r9b    ; update ascii @@@ mem acc
                inc  rdx    ; point next ascii
                jmp  .LoopDoubleFrac
           .BreakDoubleFrac:
            cmp  r8b,35h
            jnc  _BreakFirstNonZeroBit    ; if first frac ascii >= '5'
            dec  eax    ; decrement exp
            jmp  LoopFirstNonZeroBit
       _BreakFirstNonZeroBit:
        shl  rax,52    ; put exp to exp position
        mov  cl,51    ; frac bin is from 51st bit to 0th
       _LabelRestFrac:
        LoopFillFrac:
            xor  r9,r9
            mov  r8b,[rsp + 11]    ; get first frac ascii @@@ mem acc
            xor  rdx,rdx
           .LoopDoubleFrac:
                mov  r9b,[rsp + rdx + 11]    ; get frac ascii @@@ mem acc
                test  r9b,r9b
                jz  .BreakDoubleFrac    ; if ascii == null
                cmp  r9b,35h
                setnc  ch    ; if ascii >= '5'
                add  [rsp + rdx + 10],ch    ; add carry @@@ mem acc
                and  r9b,0fh    ; ascii to number
                mov  r9b,[rsp + r9]    ; get 2x of number @@@ mem acc
                mov  [rsp + rdx + 11],r9b    ; update ascii @@@ mem acc
                inc  rdx    ; point next ascii
                jmp  .LoopDoubleFrac
           .BreakDoubleFrac:
            cmp  r8b,35h
            setnc  r9b    ; if first frac ascii >= '5'
            shl  r9,cl    ; shift to current bit position
            or  rax,r9    ; insert frac bit
            sub  cl,1
            jnc  LoopFillFrac    ; if shift count < 0
       _LabelCheckLastCarry:
        mov  r8b,[rsp + 11]    ; get first frac ascii @@@ mem acc
        cmp  r8b,35h
        setnc  r9b    ; if first frac ascii >= '5'
        add  rax,r9    ; add carry

        mov  rsp,rbp
        pop  rbp    ; @@@ mem acc

       _BranReturn:
        ret
