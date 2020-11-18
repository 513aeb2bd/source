format ms64 coff

section '.text' code readable executable

public bernoulli as 'trialBernoulli'

; MWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWM
; MWM                                                 MWM
; MWM Bernoulli Trial                                 MWM
; MWM toss n coins, returns number of head side       MWM
; MWM                                                 MWM
; MWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWMWMWM MWM

bernoulli:
        ; rcx-in = number of total trial
    mov   r8,rcx    ; r8 = number of total trial
    shr   r8,6    ; r8 = quotient of r8 divided by 64
    xor   r9,r9    ; r9 = total number of 1s
    test   r8,r8
    LoopUntilR8Zero:
        jz  _BreakUntilR8Zero    ; if r8 == 0
            ; r8 != 0
        rdrand   rax    ; rax = random 64 bits
        popcnt   rax,rax    ; rax = number of 1s of rax
        add   r9,rax    ; r9 = r9 + rax
        dec   r8    ; r8 -= 1
        jmp   LoopUntilR8Zero
   _BreakUntilR8Zero:
    mov   r8,rcx    ; r8 = number of total trials
    and   rcx,3fh    ; rcx = remainder of rcx divided by 64
    mov   al,1
    shl   rax,cl
    mov   rcx,rax
    rdrand   rax    ; rax = random 64 bits
    dec   rcx    ; rcx = 2^rcx - 1 (least significant bits set)
    and   rax,rcx    ; clear most significant bits
    popcnt   rax,rax    ; rax = number of 1s of rax
    add   rax,r9    ; rax = number of total random 1s
    cvtsi2sd   xmm0,rax    ; xmm0 = number of total random 1s
    ret    ; return xmm0
