FORMAT MS64 COFF

PUBLIC sortHeapIntegerDesc

_BYTESZ = 4
_DAT EQU DWORD
_R9 EQU r9d
_R15 EQU r15d

SECTION '.code' code readable executable

; WMWMWMW WMWMWMW WMWMWMW WMWMWMW WMW
; Sort Heap Integer Descending MW WMW
; WMWMWMW WMWMWMW WMWMWMW WMWMWMW WMW

sortHeapIntegerDesc:
        ; rcx-in: addr of array to be sorted
        ; rdx-in: number of data
        ; r8-in: addr of array sorted

        ; rax: parent idx (parent of rbp)
        ; rbx: target idx
        ; rbp: child idx (child of rax)
        ; r9: target value
        ; r15: temp value

        PUSH rbp
        PUSH rbx
        PUSH r15

        XOR rbx, rbx
        SUB rcx, _BYTESZ    ; in heap sort, start index from 1
        SUB r8, _BYTESZ    ; in heap sort, start index from 1
        ; put smallest value on root
        ITER_heapify:    ; loop until "target idx" == "number of data"
            INC rbx
            MOV _R9, _DAT [rcx + rbx*_BYTESZ]    ; load "target value"
            MOV rax, rbx    ; "parent idx" start from "target idx"
            MOV rbp, rbx    ; "current idx" start from "target idx"
            MOV _R15, _R9
            ITER_untilParentLess:    ; loop until "parent value" < "target value"
                SHR rax, 1    ; point parent
                JZ _BREAK_foundParentLess    ; if parent not exist
                ; "parent" exist
                CMP _DAT [r8 + rax*_BYTESZ], _R9
                JC _BREAK_foundParentLess    ; if "parent value" < "target value"
                ; "parent value" >= "target value"
                MOV _R15, _DAT [r8 + rax*_BYTESZ]
                MOV _DAT [r8 + rbp*_BYTESZ], _R15    ; "current value" = "parent value"
                MOV rbp, rax    ; "current idx" =now "parent value"
                JMP ITER_untilParentLess
           _BREAK_foundParentLess:
            MOV _DAT [r8 + rbp*_BYTESZ], _R9    ; "current value" = "target value"
            CMP rbx, rdx
            JNZ ITER_heapify    ; if "target idx" != "number of data"
            ; "target idx" == "number of data", heapify done
        XOR rcx, rcx    ; now rcx is useless, so to help rbp addition, rcx == 0 always
        ITER_heapsort:
            MOV _R15, _DAT [r8 + _BYTESZ]    ; load top value
            MOV _R9, _DAT [r8 + rbx*_BYTESZ]    ; load "target value"
            MOV rbp, 1    ; "child idx" starts from top
            MOV _DAT [r8 + rbx*_BYTESZ], _R15    ; move top value to bottom
            DEC rbx
            MOV rax, rbp    ; "parent idx" starts from top
            JZ _BREAK_sortDone    ; if "target idx" == 0
            ; "target idx" != 0
            ITER_untilChildGreater:    ; loop until "target value" <= "child value"
                SHL rbp, 1    ; point "left child"
                CMP rbx, rbp
                JC _BREAK_noChild    ; if child not exist
                ; child exist
                MOV _R15, _DAT [r8 + rbp*_BYTESZ]    ; load "left child value"
                JZ _BRAN_compareChildTarget    ; if "right child" not exist
                ; "right child" exist
                CMP _DAT [r8 + rbp*_BYTESZ + _BYTESZ], _R15
                ADC rbp, rcx    ; point "less child"
                MOV _R15, _DAT [r8 + rbp*_BYTESZ]    ; load "less child value"
               _BRAN_compareChildTarget:
                CMP _R15, _R9
                JNC _BREAK_noChildGreater    ; if "child value" >= "target value"
                ; "child value" < "target value"
                MOV _DAT [r8 + rax*_BYTESZ], _R15
                MOV rax, rbp    ; "parent idx" = "child idx"
                JMP ITER_untilChildGreater
           _BREAK_noChild:
           _BREAK_noChildGreater:
            MOV _DAT [r8 + rax*_BYTESZ], _R9    ; "parent value" = "target value"
            JMP ITER_heapsort
       _BREAK_sortDone:
        XOR rax, rax
        POP r15
        POP rbx
        POP rbp

RET