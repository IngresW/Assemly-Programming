# Assignment 2 ASCII

## LOOP实现小写英文字母输出

```
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
```

- 通过 `MOV AX,@DATA` 和 `MOV DS,AX` 初始化数据段寄存器。
- 使用外层的 `LL` 循环控制输出两行内容，每行输出13个字符。
- 内层的 `L` 循环则负责逐个输出字符，使用 `MOV AH, 02H` 调用 BIOS 中断进行字符输出。
- 每输出一个字符后，字符自增（从 'a' 到 'b'，然后到 'c'…），并更新数据段中的字符。
- 使用 `INT 21H` 中断实现换行，换行使用的是回车（`0DH`）和换行（`0AH`）。

**汇编语言的基本操作**： 通过学习使用`LOOP`，我更加清楚地理解了汇编语言中的寄存器操作、循环控制、内存访问等基本概念。特别是对 `MOV` 指令和循环指令的使用加深了理解。

**中断调用**在程序中发挥了重要的作用，了解如何使用 `BIOS` 中断来实现字符输出和程序结束，对后续学习更复杂的系统编程很有帮助。**字符的自增操作**非常直观，有助于理解计算机如何处理字符数据，尤其是在 ASCII 码的背景下，字符的处理变得更为简单。尽管实际开发中可能不经常使用汇编语言，但掌握底层语言有助于更深入地理解计算机的运行机制，尤其是在优化性能和处理底层系统时。

## JUMP实现小写英文字母输出

```
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
```

- 修改后的部分通过 `DEC line_count` 减少行计数，如果不为零就跳转回 `LL` 循环，继续输出下一行。

使用 `line_count` 变量来控制输出行数提高了程序的灵活性，可以更方便地扩展为输出更多行的字符，增强了**可维护性**和程序的**灵活性**。用**条件跳转**来控制循环的结束，让我学习了如何用 `DEC` 和 `JNZ` 结合来实现更复杂的循环结构，有助于更好地理解程序控制流。通过这段代码，我加强了对字符输出的了解，使得基础的输入输出操作有了实际应用的感知，使我对计算机的底层操作有了更清晰的认识，对于内存管理、寄存器使用、流程控制等都有了更深入的理解。

## 用C语言实现并反汇编

```
#include <stdio.h>

int main()
{
	for (int i = 0; i < 26; i++) {
		printf("%c", 'a' + i);
		if ((i + 1) % 13 == 0)
			printf("\n");
	}
	return 0;
}
```

在 `DOSBOX` 中使用 `debug -u`命令来查看C语言生成的EXE文件的机器码如下：

```
076A:0000 0E           PUSH CS        ; 将代码段寄存器推入栈
076A:0001 1F           POP DS         ; 从栈弹出到数据段寄存器
076A:0002 BA0E00       MOV DX,000E    ; 将立即数 0E00 移到 DX
076A:0005 B409         MOV AH,09      ; 将 09 移到 AH，准备显示字符串
076A:0007 CD21         INT 21         ; 调用 DOS 中断 21H
076A:0009 BB014C       MOV BX,4C01    ; 将 4C01 移到 BX，准备程序结束
076A:000C CD21         INT 21         ; 调用 DOS 中断 21H，终止程序
076A:000E 54           PUSH SP        ; 将栈指针推入栈
076A:000F 68           DB 68          ; 数据字节 68 'h'
076A:0010 69           DB 69          ; 数据字节 69 'i'
076A:0011 7320         JNB 0033       ; 如果没有进位，跳转到 0033
076A:0013 7072         JO 0087        ; 如果溢出，跳转到 0087
076A:0015 6F           DB 6F          ; 数据字节 6F 'o'
076A:0016 67           DB 67          ; 数据字节 67 'g'
076A:0017 7261         JB 007A        ; 如果有借位，跳转到 007A
076A:0019 6D           DB 6D          ; 数据字节 6D 'm'
076A:001A 206361       AND [BP+DI+611],AH ; AND 操作适用内存与 AH
076A:001D 6E           DB 6E          ; 数据字节 6E 'n'
076A:001E 6E           DB 6E          ; 数据字节 6E 'n'
076A:001F 6F           DB 6F          ; 数据字节 6F 'o'
```

