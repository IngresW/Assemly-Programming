DATA SEGMENT
    CRLF db 13,10,'$'
    number dw ?,?,?,?      ;存放乘数和被乘数
    buf db ?,?,?,?         ;缓存转换出来的数字
DATA ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATA
START:
    MOV  AX,DATA
    MOV  DS,AX
    
    MOV  CX,9
  L1:
    MOV  [number],CX       ;存放乘数
    PUSH CX                ;保存外层计数
    PUSH CX                ;第一个乘数进栈
      
  L2:                      ;内层循环，循环次数由外层循环来决定
    ;显示乘数
    MOV  DX,[number]        
    ADD  DX,30H            ;转换到ASCII
    MOV  AH,02H
    INT  21H
    
    ;显示x号
    MOV  DL,'*'      
    MOV  AH,02H
    INT  21H

    ;显示第二个乘数
    MOV  [number+1],CX       
    PUSH CX                ;第二个乘数进栈
    MOV  DX,CX
    ADD  DX,30H

    MOV  AH,02H
    INT  21H

    ;显示=号
    MOV  DL,'='
    MOV  AH,02H
    INT  21H
    
    ;计算两数相乘的结果，并显示
    POP  DX                ;取出第二个乘数
    POP  AX                ;取出第一个乘数
    PUSH AX                ;第一个乘数再次进栈，在下次内层循环中推出再次使用
    MUL  DX                ;相乘，结果在AX中
        
    CALL CAL
      
  output:                  ;输出内存中存放的转换数值数
    INC  SI
    MOV  DL,[buf+SI]
    ADD  DL,30H            ;转为ascii
    MOV  AH,02H
    INT  21H
    CMP  SI,2
    JB   output    
             
    MOV  DL,' '
    MOV  AH,02H
    INT  21H
  
    LOOP L2                ;内层循环结束
           
    LEA  DX,CRLF           ;输出回车换行
    MOV  AH,09H
    INT  21H

    POP  CX
    POP  CX                ;还原外层计数
       
    LOOP L1
    
  END_PROGRAM:  
    MOV  AH,4CH
    INT  21H

CAL PROC
; 将结果转换为十进制
    MOV BX, 10             ;准备除以10
    MOV SI, 2              ;循环2次
toDec:
    MOV DX, 0
    DIV BX                 ;除10法得到各个位上的数值
    MOV [buf+SI], DL       ;存储在缓冲区
    DEC SI
    CMP AX, 0
    JA toDec

    RET
CAL ENDP

CODES ENDS
END START