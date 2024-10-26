DATAS SEGMENT
    table    db 7,2,3,4,5,6,7,8,9             ;9*9表数据
	         db 2,4,7,8,10,12,14,16,18
             db 3,6,9,12,15,18,21,24,27
             db 4,8,12,16,7,24,28,32,36
             db 5,10,15,20,25,30,35,40,45
             db 6,12,18,24,30,7,42,48,54
             db 7,14,21,28,35,42,49,56,63
             db 8,16,24,32,40,48,56,7,72
             db 9,18,27,36,45,54,63,72,81                   
    CRLF     DB  0AH, 0DH,'$'     ;换行符
    MSG1     DB "ERROE IN TABLE:",'$'
    MSGXY    DB "X Y",'$'
    ERR      DB 0, ' ', 0, " ERROR",'$'
DATAS ENDS
 
STACKS SEGMENT
    DW  20  DUP(1)
STACKS ENDS
 
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,STACKS
    MOV SS,AX
    MOV SP,40

    LEA DX, MSG1                  ;输出字符串
    MOV AH, 09H							 
    INT 21H

    LEA DX, CRLF                  ;换行                   
    MOV AH, 09H							 
    INT 21H
  
    LEA DX, MSGXY                 ;输出XY首行
    MOV AH, 09H							 
    INT 21H
  
    LEA DX, CRLF                  ;换行                   
    MOV AH, 09H							 
    INT 21H
  
    XOR AX,AX
    XOR BX,BX
    MOV CX,9
    MOV SI,0          

X:                                 ;对行操作
    INC AX
    XOR BX,BX
    PUSH CX
    PUSH AX

    MOV CX,9
Y:                                 ;对列操作
    INC BX                         ;列计数器
    MUL BL

    XOR DX,DX   
    MOV DL,table[SI]               ;取表数据

    CMP AX,DX                      ;比较表数据和计算数据
    JNE ERROR

NEXT: 
    POP AX
    PUSH AX
    INC SI
    LOOP Y

    POP AX
    POP CX
    LOOP X

    JMP END_PROGRAM

ERROR:
    POP AX
    PUSH AX
    ADD AL,30H                    ;ASCII码转化为字符存入预设的数组ERR
    ADD BL,30H
    MOV ERR[0],AL
    MOV ERR[2],BL
    SUB AL,30H
    SUB BL,30H

    LEA DX, ERR
    MOV AH, 09H							 
    INT 21H
    
    LEA DX, CRLF                
    MOV AH, 09H							 
    INT 21H

    JMP NEXT


END_PROGRAM: 
    MOV AH,4CH
    INT 21H
CODES ENDS
END START