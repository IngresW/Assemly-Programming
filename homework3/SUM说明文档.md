# Assignment 3  SUM

## T1.打印1+2+3+...+100的和

```
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

```

### 1. 使用寄存器的方法

```assembly
START:
    MOV  AH,02H  
    MOV  DX,1    ; 当前加数
    MOV  BX,0    ; SUM
    MOV  CX,100  ; 计数器
L:
    ADD  BX,DX   ; 加
    INC  DX      ; 自增
    LOOP L
```

- **AH, DX, BX, CX寄存器**：使用 `AH` 来设置一个系统调用，`DX` 用于存储当前的加数（从1开始），`BX` 用来累积和，`CX` 是循环计数器（总共循环100次）。
- **循环**：在标签 `L` 处，执行加法 `ADD BX, DX`，每次将 `DX` 的值加到 `BX` 中。然后将 `DX` 自增，直至 `CX` 为零。
- **优点**：使用寄存器直接进行运算，速度快。

### 2. 使用数据段的方法

```assembly
START:
    MOV  BX,data  ; BX指向数据段
    MOV  DS,BX    
    MOV  AH,02H  
    MOV  DX,1      ; 当前加数
    MOV  BX,0      ; SUM
    MOV  DS:[0],BX 
    MOV  CX,100  
L:
    ADD  BX,DX     ; 加
    MOV  DS:[0],BX ; 和放入数据段
    INC  DX        ; 自增
    LOOP L
```

- **数据段**：通过 `MOV BX, data` 将 `BX` 指向数据段，然后用 `MOV DS, BX` 设置数据段寄存器。
- **存储和**：同样进行求和计算，但这次每次计算后将当前的和存储回数据段 `DS:[0]`。
- **优点**：这种方式使得计算结果可以在数据段中持久化，便于后续访问。

### 3. 使用栈的方法

```assembly
START:
    MOV  BX,stk    ; BX指向栈
    MOV  SS,BX
    MOV  SP,0
    MOV  AH,02H  
    MOV  DX,1      ; 当前加数
    MOV  BX,0      ; SUM
    PUSH BX        ; 和放入栈
    MOV  CX,100  
L:
    POP  BX
    ADD  BX,DX     ; 加
    PUSH BX        ; 和放入栈
    INC  DX        ; 自增
    LOOP L
```

- **栈段**：通过 `MOV BX, stk` 和 `MOV SS, BX` 指定栈段，然后将栈指针 `SP` 初始化为0。
- **使用栈存储和**：初始和 `BX` 被压入栈中，计算时从栈中弹出 `BX`，进行加法运算后再压入栈中。
- **优点**：栈的使用使得临时数据的存放和回收变得灵活，可以在调用不同的处理过程时保持数据的隔离性。

## T2.用户输入一个1~100的正整数，输出结果

```
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
 
; 将结果数字转换为字符串并输出的函数
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
```

1. **数据段**：
   - `input`：用于存储用户输入的数据。
   - `buffer`：用于临时存储转换后的数字。
   - `result`：用于存储最终的累加和，类型为 `dw`，以支持更大的值。
2. **输入处理**：
   - `INT 21H` 指令用于获取用户输入，输入数据存储在 `input` 中。
3. **字符转换**：
   - 循环 `Str_To_Int`：将用户输入的字符转换为数字，并存储在 `buffer` 中。
4. **累加计算**：
   - `ADD result, BL` 将当前数字（由 `BL` 保持）累加到 `result` 中。
   - `INC BL` 用于自增数字。
5. **输出和的描述信息**：
   - 调用 `Print_Ans` 过程，将计算结果从数字转换为字符并在屏幕上显示

## C语言反汇编

```
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

int main() {
	int input, sum = 0;
	scanf("%d", &input);
	for (int i = 1; i <= input; i++) {
		sum += i;
	}
	printf("Your number is %d.\n", input);
	printf("The sum is %d.\n", sum);
	return 0;
}
```

将C语言编译后得到的`Sum_C.exe`通过` DOSBOX`的`debug -u`指令反汇编得到如下结果

```
076A:0000 0E            PUSH CS         ; 将代码段寄存器压入栈中
076A:0001 1F            POP  DS         ; 从栈中弹出到数据段寄存器
076A:0002 BA0E00        MOV  DX,000E    ; 将 0E 赋值给 DX 寄存器
076A:0005 B409          MOV  AH,09      ; 将 09 赋值给 AH 寄存器，用于 DOS 显示字符串功能
076A:0007 CD21          INT  21         ; 调用 DOS 中断 21h
076A:0009 B8014C        MOV  AX,4C01    ; 将 4C01 赋值给 AX 寄存器，准备退出程序
076A:000C CD21          INT  21         ; 调用 DOS 中断 21h，退出程序
076A:000E 54            PUSH SP         ; 将栈指针压入栈中
076A:000F 68            DB 68           ; 定义字节 68
076A:0010 69            DB 69           ; 定义字节 69
076A:0011 7320          JNB 0033        ; 如果不进位则跳转到地址 0033
076A:0013 7072          JO  0087        ; 如果溢出则跳转到地址 0087
076A:0015 6F            DB 6F           ; 定义字节 6F
076A:0016 67            DB 67           ; 定义字节 67
076A:0017 7261          JB 007A         ; 如果借位则跳转到地址 007A
076A:0019 6D            DB 6D           ; 定义字节 6D
076A:001A 206361        AND [BP+DI+61], AH ; 对内存地址 (BP+DI+61) 的值与 AH 进行逻辑与
076A:001D 6E            DB 6E           ; 定义字节 6E
076A:001E 6E            DB 6E           ; 定义字节 6E
076A:001F 6F            DB 6F           ; 定义字节 6F
```

