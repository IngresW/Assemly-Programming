.model small
.data
    char DB "a"
.code
    START:
        MOV  AX,@DATA
        MOV  DS,AX

        MOV  CX,2   ; 控制分两行输出
    LL:
        MOV  BX,CX
        MOV  CX,13  ; 控制每行输出13个字符

    L:  
        MOV  AL,[char]   ; 输出字符
        MOV  DL,AL
        MOV  AH,02H
        INT  21H

        INC  AL
        MOV  [char],AL

        LOOP L

        ; 换行+回车
        MOV  DL,0DH
        INT  21H
        MOV  DL,0AH
        INT  21H

        MOV  CX,BX
        LOOP LL

        MOV  AH,4CH
        INT  21H
END    START