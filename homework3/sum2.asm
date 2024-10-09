.model small
.data
    Msg db "Your input is: $"
    Msg2 db "The sum is: $"
    input db 10,0
    buffer db 3 DUP(0)
    db 10 DUP(0)
    result dw 0

.code
START:
    MOV  AX, @data
    MOV  DS, AX

    ; 输入字符
    MOV  DX, OFFSET input 
    MOV  AH, 0AH 
    INT  21H
    
    MOV  DI, OFFSET buffer
    MOV  CX, 0

    MOV  CL, [input + 1]
    MOV  SI, OFFSET input + 2

Str_To_Int:
    ; 将字符转换为数字
    MOV  AL, [SI]
    SUB  AL, '0'
    MOV  [DI], AL
    INC  DI
    INC  SI
    LOOP Str_To_Int
    
    MOV  DI, OFFSET buffer
    MOV  AL, [DI]
    MOV  BL, 1
    MOV  result, 0

Sum_Loop:
    ADD  result, BL         ; 将当前数字累加到结果
    INC  BL                 ; 当前数字自增
    CMP  BL, AL             ; 比较当前数字和输入的数字
    JLE  Sum_Loop           ; 如果当前数字小于等于输入数字，则继续

    ; 输出结果
    MOV  AH, 09H
    MOV  DX, OFFSET Msg
    INT  21H

    MOV  DI, OFFSET buffer
    MOV  CL, [input + 1]

Int_To_Str:
    ; 转换数字回字符并输出
    MOV  AL, [DI]           ; 读取数字
    ADD  AL, '0'            ; 转换为字符
    MOV  DL, AL
    MOV  AH, 02H
    INT  21H

    INC  DI
    LOOP Int_To_Str

    ; 换行+回车
    MOV  DL,0DH
    INT  21H
    MOV  DL,0AH
    INT  21H
    ; 输出结果
    MOV  AH, 09H
    MOV  DX, OFFSET Msg2
    INT  21H

    MOV  AX, result
    CALL Print_Ans

END_PROC:
    MOV  AX,4C00H
    INT  21H

; 将结果数字转换为字符串并输出
Print_Ans PROC
    ; 将数字转换为字符
    MOV  DI, OFFSET buffer
    XOR  CX, CX             ; 清零 CX

Convert_Loop:
    XOR  DX, DX             ; 清零 DX
    MOV  BX, 10             ; 除以 10
    DIV  BX                 ; AX / 10
    PUSH DX                 ; 存余数 (当前数字的最低位)
    INC  CX                 
    CMP  AX, 0
    JNZ  Convert_Loop       ; 如果 AX 不为 0, 继续循环

Output_Loop:
    POP  DX                 ; 弹出余数
    ADD  DL, '0'            ; 转换为字符
    MOV  AH, 02H
    INT  21H
    LOOP Output_Loop        ; 输出所有字符

    RET
Print_Ans ENDP


END START
