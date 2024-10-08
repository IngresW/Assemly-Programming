.model small
.data
    char DB "a"
    line_count DB 2
.code
    START:
        MOV  AX,@DATA
        MOV  DS,AX

    LL:
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

        DEC  line_count
        JNZ  LL

        MOV  AH,4CH
        INT  21H
END    START