.MODEL SMALL

data SEGMENT
    dw 0H
data ENDS

stk SEGMENT
    dw 0H
stk ENDS

ASSUME DS:data
.code
    ; 采用放在寄存器的方法
    ; START:
    ;     MOV  AH,02H  
    ;     MOV  DX,1    ;当前加数
    ;     MOV  BX,0    ;SUM
    ;     MOV  CX,100  ;计数器
    ; L:
    ;     ADD  BX,DX   ;加
    ;     INC  DX      ;自增
    ;     LOOP L

    ; 采用放在数据段的方法
    ; START:
    ;     MOV  BX,data  ;BX指向数据段
    ;     MOV  DS,BX    
    ;     MOV  AH,02H  
    ;     MOV  DX,1      ;当前加数
    ;     MOV  BX,0      ;SUM
    ;     MOV  DS:[0],BX 
    ;     MOV  CX,100  
    ; L:
    ;     ADD  BX,DX     ;加
    ;     MOV  DS:[0],BX ;和放入数据段
    ;     INC  DX        ;自增
    ;     LOOP L

    ; 采用放在栈的方法
    START:
        MOV  BX,stk    ;BX指向栈
        MOV  SS,BX
        MOV  SP,0
        MOV  AH,02H  
        MOV  DX,1      ;当前加数
        MOV  BX,0      ;SUM
        PUSH BX        ;和放入栈
        MOV  CX,100  
    L:
        POP  BX
        ADD  BX,DX     ;加
        PUSH BX        ;和放入栈
        INC  DX        ;自增
        LOOP L

    ;分解位数
        MOV  CX,1000D;千位
        MOV  AX,BX
        MOV  DX,0
        DIV  CX      ;ax/cx
        MOV  BX,DX   ;余数给dx
        MOV  DL,AL
        ADD  DL,30H  ;变成ASCII
        MOV  AH,02H 
        INT  21H    

        MOV  CX,100D ;百位
        MOV  AX,BX
        MOV  DX,0
        DIV  CX
        MOV  BX,DX
        MOV  DL,AL
        ADD  DL,30H
        MOV  AH,02H
        INT  21H

        MOV  CX,10D  ;十位
        MOV  AX,BX
        MOV  DX,0
        DIV  CX
        MOV  BX,DX
        MOV  DL,AL
        ADD  DL,30H
        MOV  AH,02H
        INT  21H

        MOV  CX,1D   ;个位
        MOV  AX,BX
        MOV  DX,0
        DIV  CX
        MOV  BX,DX
        MOV  DL,AL
        ADD  DL,30H
        MOV  AH,02H
        INT  21H

        MOV  AH,4CH  ;退出
        INT  21H
END START
