FORMAT MS64 COFF

PUBLIC sortHeapIntegerAsc as 'sortHeapIntegerAsc'
PUBLIC sortHeapIntegerDesc as 'sortHeapIntegerDesc'

_BYTESZ = 4
_DAT EQU DWORD
_R9 EQU r9d
_R15 EQU r15d

SECTION '.code' code readable executable

;;;;;;; ;;;;;;; ;;;;;;; ;;;;;;; ;;;
; Sort Heap Integer Ascending ; ;;;
;;;;;;; ;;;;;;; ;;;;;;; ;;;;;;; ;;;

sortHeapIntegerAsc:
        ; rcx-in: addr of array to be sorted
        ; rdx-in: number of data
        ; r8-in: addr of array sorted

        ; rax: parent idx
        ; rbx: target idx
        ; rbp: child idx
        ; r9: target value
        ; r15: temp value

        PUSH rbp
        PUSH rbx
        PUSH r15

        SUB rcx, _BYTESZ ; in heap sort, start index from 1
        SUB r8, _BYTESZ

        MOV rbx, 1 ; "target idx" starts from 1

        ; parent value >= child value
        ; put biggest value on root
        LOOP_heapifyAsc:
          MOV _R9, _DAT [rcx + rbx*_BYTESZ]
          MOV rax, rbx ; "parent idx" start from "target idx"
          MOV rbp, rbx ; "child idx" start from "target idx"
          MOV _R15, _R9

          ; loop until "target value" < "parent value"
          LOOP_forTempoAsc:
            SHR rax, 1
            JZ BRAN_foundPlaceAsc ; if "parent idx" == 0, then found place
            ; now "parent" exist
            CMP _R9, _DAT [r8 + rax*_BYTESZ]
            JC BRAN_foundPlaceAsc ; if "target value" < "parent value", then found place
            ; now "target value" >= "parent value"
            MOV _R15, _DAT [r8 + rax*_BYTESZ]
            MOV _DAT [r8 + rbp*_BYTESZ], _R15 ; "child value" = "parent value"
            MOV rbp, rax ; current "parent idx" is new "child idx"
            JMP LOOP_forTempoAsc
          ;;; LOOP_forTempoAsc

          BRAN_foundPlaceAsc:

          MOV _DAT [r8 + rbp*_BYTESZ], _R9 ; "child value" = "target value"

          CMP rbx, rdx
          JZ BRAN_heapifyDoneAsc ; if "target idx" == "number of data"
          ; now "target idx" < "number of data"
          INC rbx
          JMP LOOP_heapifyAsc
        ;;; LOOP_heapifyAsc

        BRAN_heapifyDoneAsc:

        MOV rbx, rdx ; "target idx" = "last idx"

        LOOP_heapsortAsc:
          MOV _R15, _DAT [r8 + _BYTESZ] ; load top value
          MOV _R9, _DAT [r8 + rbx*_BYTESZ]
          MOV rbp, 1 ; "child idx" starts from top
          MOV _DAT [r8 + rbx*_BYTESZ], _R15 ; move top value to bottom
          SUB rbx, 1
          MOV rax, rbp ; "parent idx" starts from top
          JZ BRAN_sortDoneAsc ; if "target idx" == 1 then sort done

          ; loop until "target value" > "child value"
          LOOP_forTempo2Asc:
            SHL rbp, 1 ; "left child"
            CMP rbx, rbp
            JC BRAN_foundPlace2Asc ; if child not exist, then found place
            ; now "target idx" <= "left child idx"
            ; find bigger child
            MOV _R15, _DAT [r8 + rbp*_BYTESZ]
            JZ BRAN_compareChildParentAsc ; if "right child" not exist, then compare
            ; now "right child" exist, so compare two children value
            CMP _R15, _DAT [r8 + rbp*_BYTESZ + _BYTESZ]
            JNC BRAN_compareChildParentAsc ; if ["left child"] >= ["right child"] then compare
            ; now ["left child"] < ["right child"], so "right child" to be compared to "parent"
            MOV _R15, _DAT [r8 + rbp*_BYTESZ + _BYTESZ]
            INC rbp ; point "right child"

            BRAN_compareChildParentAsc:

            CMP _R9, _R15
            JNC BRAN_foundPlace2Asc ; if ["target idx"] >= ["child idx"], then found place
            MOV _DAT [r8 + rax*_BYTESZ], _R15
            MOV rax, rbp ; "parent idx" = "child idx"
            JMP LOOP_forTempo2Asc
          ;;; LOOP_forTempo2Asc

          BRAN_foundPlace2Asc:

          MOV _DAT [r8 + rax*_BYTESZ], _R9 ; "parent value" = "target value"
          JMP LOOP_heapsortAsc
        ;;; LOOP_heapsortAsc

        BRAN_sortDoneAsc:

        POP r15
        POP rbx
        POP rbp

        RET
;;; sortHeapIntegerAsc

;;;;;;; ;;;;;;; ;;;;;;; ;;;;;;; ;;;
; Sort Heap Integer Descending  ;;;
;;;;;;; ;;;;;;; ;;;;;;; ;;;;;;; ;;;

sortHeapIntegerDesc:
        ; rcx-in: addr of array to be sorted
        ; rdx-in: number of data
        ; r8-in: addr of array sorted

        ; rax: parent idx
        ; rbx: target idx
        ; rbp: child idx
        ; r9: target value
        ; r15: temp value

        PUSH rbp
        PUSH rbx
        PUSH r15

        SUB rcx, _BYTESZ ; in heap sort, start index from 1
        SUB r8, _BYTESZ

        MOV rbx, 1 ; "target idx" starts from 1

        ; parent value <= child value
        ; put smallest value on root
        LOOP_heapifyDesc:
          MOV _R9, _DAT [rcx + rbx*_BYTESZ]
          MOV rax, rbx ; "parent idx" start from "target idx"
          MOV rbp, rbx ; "child idx" start from "target idx"
          MOV _R15, _R9

          ; loop until "parent value" < "target value"
          LOOP_forTempoDesc:
            SHR rax, 1
            JZ BRAN_foundPlaceDesc ; if "parent idx" == 0, then found place
            ; now "parent" exist
            CMP _DAT [r8 + rax*_BYTESZ], _R9
            JC BRAN_foundPlaceDesc ; if "parent value" < "target value", then found place
            ; now "parent value" >= "target value"
            MOV _R15, _DAT [r8 + rax*_BYTESZ]
            MOV _DAT [r8 + rbp*_BYTESZ], _R15 ; "child value" = "parent value"
            MOV rbp, rax ; current "parent idx" is new "child idx"
            JMP LOOP_forTempoDesc
          ;;; LOOP_forTempoDesc

          BRAN_foundPlaceDesc:

          MOV _DAT [r8 + rbp*_BYTESZ], _R9 ; "child value" = "target value"

          CMP rbx, rdx
          JZ BRAN_heapifyDoneDesc ; if "target idx" == "number of data"
          ; now "target idx" < "number of data"
          INC rbx
          JMP LOOP_heapifyDesc
        ;;; LOOP_heapifyDesc

        BRAN_heapifyDoneDesc:

        MOV rbx, rdx ; "target idx" = "last idx"

        LOOP_heapsortDesc:
          MOV _R15, _DAT [r8 + _BYTESZ] ; load top value
          MOV _R9, _DAT [r8 + rbx*_BYTESZ]
          MOV rbp, 1 ; "child idx" starts from top
          MOV _DAT [r8 + rbx*_BYTESZ], _R15 ; move top value to bottom
          SUB rbx, 1
          MOV rax, rbp ; "parent idx" starts from top
          JZ BRAN_sortDoneDesc ; if "target idx" == 1 then sort done

          ; loop until "child value" > "target value"
          LOOP_forTempo2Desc:
            SHL rbp, 1 ; "left child"
            CMP rbx, rbp
            JC BRAN_foundPlace2Desc ; if child not exist, then found place
            ; now "target idx" <= "left child idx"
            ; find smaller child
            MOV _R15, _DAT [r8 + rbp*_BYTESZ] ; "left child value"
            JZ BRAN_compareChildParentDesc ; if "right child" not exist, then compare
            ; now "right child" exist, so compare two children value
            CMP _DAT [r8 + rbp*_BYTESZ + _BYTESZ], _R15
            JNC BRAN_compareChildParentDesc ; if ["left child"] <= ["right child"] then compare
            ; now ["left child"] > ["right child"], so "right child" to be compared to "parent"
            MOV _R15, _DAT [r8 + rbp*_BYTESZ + _BYTESZ]
            INC rbp ; point "right child"

            BRAN_compareChildParentDesc:

            CMP _R15, _R9
            JNC BRAN_foundPlace2Desc ; if "target value" <= "child value", then found place
            ; now "target value" > "child value", so "parent value" = "child value"
            MOV _DAT [r8 + rax*_BYTESZ], _R15
            MOV rax, rbp ; "parent idx" = "child idx"
            JMP LOOP_forTempo2Desc
          ;;; LOOP_forTempo2Desc

          BRAN_foundPlace2Desc:

          MOV _DAT [r8 + rax*_BYTESZ], _R9 ; "parent value" = "target value"
          JMP LOOP_heapsortDesc
        ;;; LOOP_heapsortDesc

        BRAN_sortDoneDesc:

        POP r15
        POP rbx
        POP rbp

        RET
;;; sortHeapIntegerDesc
