data segment
    years db '1975','1976','1977','1978','1979','1980','1981','1982','1983','1984','1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995'
    revenues dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514,345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    employees dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226,11542,14430,15257,17800
data ends

table segment
    db 21 dup('year summ ne ?? ')
table ends

stack segment
    db 32 dup(0)
stack ends

code segment
    ASSUME CS: code, DS: data, ES: table, SS: stack
    EXTRN PRINT_TAB: FAR, PRINT_NEWLINE: FAR, PRINT_NUMBER: FAR
main PROC FAR
    MOV AX, data
    MOV DS, AX
    MOV AX, table
    MOV ES, AX

; 处理年份数据
    MOV SI, OFFSET years
    MOV DI, 0
    MOV CX, 21  ; 21年数据
copy_year:
    MOVSB
    MOVSB
    MOVSB
    MOVSB
    ADD DI, 12                  ; 每次跳过12个空格
    LOOP copy_year

; 处理收入数据
    MOV SI, OFFSET revenues
    MOV DI, 5                   ; 表中收入的起始偏移量
    MOV CX, 21
copy_revenues:
    MOV AX, [SI]
    MOV DX, [SI + 2]
    MOV ES:[DI], AX
    MOV ES:[DI + 2], DX
    ADD DI, 16
    ADD SI, 4
    LOOP copy_revenues

; 处理员工数据
    MOV SI, OFFSET employees
    MOV DI, 10                  ; 表中员工数量的起始偏移量
    MOV CX, 21
copy_employees:
    MOV AX, [SI]
    MOV ES:[DI], AX
    ADD DI, 16
    ADD SI, 2
    LOOP copy_employees

; 计算平均收入
    MOV SI, OFFSET revenues
    MOV DI, OFFSET employees
    MOV BX, 13
    MOV CX, 21
calculate:
    PUSH BX
    ; 收入数据
    MOV AX, [SI]
    MOV DX, [SI + 2]
    ADD SI, 4
    ; 员工数据
    MOV BX, [DI]
    ADD DI, 2
    ; 计算平均收入
    DIV BX
    POP BX
    PUSH DI

    ; 将平均收入存储到表中
    MOV DI, BX
    MOV ES:[DI], AX
    ADD DI, 16
    MOV BX, DI
    POP DI
    
    LOOP calculate

; 打印输出
    MOV AX, table
    MOV DS, AX
    MOV BX, 21
    MOV SI, 0

PRINT_TABLE:
    CALL PRINT_TAB

    MOV CX, 4                   ; 打印年份的长度
    PRINT_YEAR:
        MOV DL, [SI]                ; 逐个字符显示年份
        MOV AH, 02H
        INT 21H
        INC SI
        LOOP PRINT_YEAR

    ; 打印制表符
    CALL PRINT_TAB
    CALL PRINT_TAB
    CALL PRINT_TAB

    ; 打印收入
    INC SI
    MOV AX, [SI]
    ADD SI, 2
    MOV DX, [SI]
    ADD SI, 2
    CALL PRINT_NUMBER
    CALL PRINT_TAB
    CALL PRINT_TAB

    ; 打印员工数量
    INC SI
    MOV AX, [SI]
    MOV DX, 0
    ADD SI, 2
    CALL PRINT_NUMBER
    CALL PRINT_TAB
    CALL PRINT_TAB

    ; 打印平均收入
    INC SI
    MOV AX, [SI]
    MOV DX, 0
    ADD SI, 2
    CALL PRINT_NUMBER
    INC SI

    ; 换行
    CALL PRINT_NEWLINE
    
    DEC BX
    JNZ PRINT_TABLE

END_PROC:
    MOV AX, 4C00H
    INT 21H

main ENDP
code ends
END main