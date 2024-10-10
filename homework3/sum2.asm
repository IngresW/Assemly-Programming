.model small
.data
    PromptMsg db "Please input a number: $"
    Msg db "The sum is: $"
    result dw ?
.code
START:
    MOV  AX, @data
    MOV  DS, AX

    MOV  AH, 09H
    MOV  DX, OFFSET PromptMsg
    INT  21H

    XOR  DX, DX

Read_Input:
    MOV  AH, 01H              
    INT  21H              
    CMP  AL, 0DH             
    JE   Calculate

    SUB  AL, '0'
    MOV  BL, AL
    MOV  AX, DX
    MOV  DX, 10
    MUL  DX
    ADD  AX, BX
    MOV  DX, AX
    JMP  READ_INPUT           ; 继续读取下一个输入字符

Calculate:
    MOV  CX, DX               ; 使用CX作为计数器，存储输入的数字
    MOV  BX, 1                ; 初始化BX为1，用于从1开始累加
    XOR  AX, AX

Sum_Loop:        
    ADD  result, BX         ; 将当前数字累加到结果
    INC  BX                 ; 输入数字自增
    LOOP Sum_Loop

    ; 输出结果
    MOV  AH, 09H
    MOV  DX, OFFSET Msg
    INT  21H

    MOV  AX, result
    CALL Print_Ans

END_PROC:
    MOV  AX,4C00H
    INT  21H

; 将结果数字转换为字符串并输出
Print_Ans PROC
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
