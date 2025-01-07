.model small
.386
.data
    pixel_color db 1
    eraser_mode db 0    ; 橡皮擦模式标志，0=关闭，1=开启

.code
start:
    mov ax, @data
    mov ds, ax

    MOV AH , 0
    MOV AL , 13h      ; 320x200的标准VGA模式
    INT 10H

    ; 初始化鼠标
    mov ax, 0
    int 33h
    or ax, ax
    jz near ptr exit

    ; 设置鼠标热点位置
    mov ax, 4        
    mov cx, 0        
    mov dx, 0        
    int 33h

    ; 显示鼠标光标
    mov ax, 1
    int 33h

    ; 初始绘制颜色指示器
    call draw_indicator

mouse_loop:
    ; 获取鼠标状态
    mov ax, 3
    int 33h
    
    ; 检查是否按下左键
    test bx, 1
    jz near ptr check_exit
    
    ; 保存原始坐标
    push cx
    push dx
    
    ; 转换鼠标坐标，似乎DOSBOX中的鼠标点击位置和实际位置不一致
    shr cx, 1
    
    ; 检查是否在橡皮擦模式
    cmp [eraser_mode], 1
    je erase_area
    
    ; 正常绘制模式
    mov ah, 0Ch
    mov al, [pixel_color]
    mov bh, 0
    int 10h
    jmp drawing_done

erase_area:
    ; 绘制3x3的区域
    mov ah, 0Ch
    mov al, 0        ; 黑色(擦除)
    mov bh, 0
    
    ; 左上
    dec cx
    dec dx
    int 10h
    ; 上中
    inc cx
    int 10h
    ; 右上
    inc cx
    int 10h
    ; 左中
    sub cx, 2
    inc dx
    int 10h
    ; 中心
    inc cx
    int 10h
    ; 右中
    inc cx
    int 10h
    ; 左下
    sub cx, 2
    inc dx
    int 10h
    ; 下中
    inc cx
    int 10h
    ; 右下
    inc cx
    int 10h

drawing_done:
    ; 恢复原始坐标
    pop dx
    pop cx

check_exit:
    ; 检查键盘
    mov ah, 1
    int 16h
    jz near ptr mouse_loop
    
    mov ah, 0
    int 16h
    
    ; 检查'q'键
    cmp al, 'q'
    je exit
    
    ; 检查'c'键
    cmp al, 'c'
    jne check_m
    
    ; 清屏前隐藏鼠标
    mov ax, 2
    int 33h
    
    ; 清屏
    mov ah, 0
    mov al, 13h
    int 10h
    
    ; 重新显示鼠标
    mov ax, 1
    int 33h

    ; 更新颜色指示器
    call draw_indicator
    
    jmp mouse_loop

check_m:
    ; 检查'm'键
    cmp al, 'm'
    jne check_n
    
    ; 切换橡皮擦模式
    xor byte ptr [eraser_mode], 1
    
    ; 重绘指示器
    call draw_indicator
    jmp mouse_loop

check_n:    
    ; 检查是否按下'n'键
    cmp al, 'n'
    jne near ptr mouse_loop
    
    ; 处理'n'键 - 改变颜色
    inc byte ptr [pixel_color]  
    cmp byte ptr [pixel_color], 15   ; 只使用前16种颜色
    jbe update_indicator
    mov byte ptr [pixel_color], 1    ; 重置为1而不是0（0是黑色）
    
update_indicator:
    ; 更新颜色指示器
    call draw_indicator
    jmp mouse_loop

draw_indicator:
    push ax
    push bx
    push cx
    push dx

    ; 检查是否在橡皮擦模式
    cmp [eraser_mode], 0
    je draw_color_box
    
    ; 绘制红色X形状表示橡皮擦
    mov ah, 0Ch
    mov al, 4        ; 红色
    mov bh, 0
    
    ; 绘制第一条斜线 (\)
    mov cx, 5        ; 起始X
    mov dx, 5        ; 起始Y
draw_line1:
    int 10h
    inc cx
    inc dx
    cmp cx, 15
    jne draw_line1
    
    ; 绘制第二条斜线 (/)
    mov cx, 5        ; 起始X
    mov dx, 15       ; 起始Y
draw_line2:
    int 10h
    inc cx
    dec dx
    cmp cx, 15
    jne draw_line2
    
    jmp indicator_done

draw_color_box:
    mov ah, 0Ch
    mov al, [pixel_color]
    mov bh, 0

    ; 绘制一个10x10的方块
    mov dx, 5        ; 起始Y坐标
draw_y:
    mov cx, 5        ; 起始X坐标
draw_x:
    int 10h
    inc cx
    cmp cx, 15       ; 结束X坐标
    jne draw_x
    inc dx
    cmp dx, 15       ; 结束Y坐标
    jne draw_y

indicator_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

exit:
    mov ax, 4C00h
    int 21h

end start