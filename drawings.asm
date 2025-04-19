.MODEL small


.STACK 100h

.DATA
board_x dw 140     
board_y dw 185     
prev_board_x dw 0

width1 dw 50  ; Width of the rectangle
height dw 5 ; Height of the rectangle
board_color db 4   ; Color (red)
black_color db 0

ball_x dw 162  
ball_y dw 179
ball_color db 15 ;White color

block_width dw 30
block_hight dw 8

ball_size dw 6

blue db 9
red db 12
yellow db 14
green db 10

lifes_y dw 8
life1_x dw 8
life2_x dw 22
life3_x dw 36












.CODE

;-----------------------
; Draw Horizontal Line
; CX = X start, DX = Y, BX = width
;-----------------------
draw_horizontal_line proc
	push bp
	mov bp,sp
    push cx
    push dx
    push bx

draw_h_loop:
    mov ah, 0Ch     ; Put pixel function
    mov al, [bp+4] ; Color
    int 10h
    inc cx
    dec bx
    jnz draw_h_loop

    pop bx
    pop dx
    pop cx
	pop bp
    ret 2
draw_horizontal_line endp

;-----------------------
; Draw Vertical Line
; CX = X, DX = Y start, BX = height
;-----------------------



draw_rectangle proc
    push ax
    push bx
    push cx
    push dx
    push si

    ; Compute bottom Y coordinate: bottom = y + height
    mov ax, [board_y]      ; Load y into AX
    add ax, [height] ; AX = y + height
    mov si, ax       ; SI now holds the bottom coordinate

    mov dx, [board_y]      ; Initialize DX to starting y

fill_loop:
    mov cx, [board_x]      ; Starting x for the horizontal line
    mov bx, [width1] ; Width of the rectangle (number of pixels)
	
	
	mov ah,0
	mov al,[board_color]
	push ax
    call draw_horizontal_line  ; Draw one horizontal line at row DX

    inc dx         ; Move to the next row
    cmp dx, si     ; Compare current row with bottom coordinate
    jl fill_loop   ; If DX < bottom, continue the loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_rectangle endp





draw_ball proc
	push ax
	push bx
	push cx
	push dx
	
	mov al,[ball_color]

	
	mov cx,[ball_x]
	mov dx,[ball_y]
	mov bx,cx
	add bx,[ball_size]
	
	mov si, dx
	add si,[ball_size]
	
ball_row:
	mov cx, [ball_x]
	
ball_column:
	mov ah, 0ch
	int 10h
	
	inc cx
	cmp cx,bx
	jb ball_column
	
	inc dx
	cmp dx,si
	jb ball_row
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
draw_ball endp



draw_life proc
	push bp 
	mov bp,sp
	
	push ax
	push bx
	push cx
	push dx
	
	mov al,[ball_color]

	
	mov cx,[bp+6]
	mov dx,[bp+4]
	mov bx,cx
	add bx,6
	
	mov si, dx
	add si,6
	
life_row:
	mov cx, [bp+6]
	
life_column:
	mov ah, 0ch
	int 10h
	
	inc cx
	cmp cx,bx
	jb life_column
	
	inc dx
	cmp dx,si
	jb life_row
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
draw_life endp

draw_all_lifes proc
    push ax

    mov ax, [lifes_left]

    ; --- Life 1 ---
    cmp ax, 1
    jl erase_life1  ; if lifes_left < 1
    ; draw life1
    push life1_x
    push lifes_y
    call draw_life
    jmp check_life2

erase_life1:
    push life1_x
    push lifes_y
    call erase_life

check_life2:
    cmp ax, 2
    jl erase_life2  ; if lifes_left < 2
    ; draw life2
    push life2_x
    push lifes_y
    call draw_life
    jmp check_life3

erase_life2:
    push life2_x
    push lifes_y
    call erase_life

check_life3:
    cmp ax, 3
    jl erase_life3  ; if lifes_left < 3
    ; draw life3
    push life3_x
    push lifes_y
    call draw_life
    jmp draw_all_lifes_end

erase_life3:
    push life3_x
    push lifes_y
    call erase_life

draw_all_lifes_end:
    pop ax
    ret
draw_all_lifes endp


erase_life proc
    push bp
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov al, [black_color]
    
    ; CORRECT PARAMETER ACCESS:
    mov cx, [bp+6]    ; X coordinate (first pushed)
    mov dx, [bp+4]    ; Y coordinate (second pushed)
    
    ; Calculate boundaries
    mov bx, cx
    add bx, 6          ; Right edge (X + width)
    mov si, dx
    add si, 6          ; Bottom edge (Y + height)
    
erase_life_row:
    mov cx, [bp+6]     ; Reset X position
    
erase_life_column:
    mov ah, 0ch        ; Put pixel function
    int 10h            ; Draw black pixel
    
    inc cx             ; Move right
    cmp cx, bx
    jb erase_life_column
    
    inc dx             ; Move down
    cmp dx, si
    jb erase_life_row
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4              ; Clean up 4 bytes (2 words)
erase_life endp

erase_board proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Store original board_x
    mov ax, [board_x]
    push ax
    
    ; Store original color
    mov al, [board_color]
    push ax
    
    ; Set board_x to previous position for erasing
    mov ax, [prev_board_x]
    mov [board_x], ax
    
    ; Set color to black
    mov al, [black_color]
    mov [board_color], al
    
    ; Draw a black rectangle at previous position
    call draw_rectangle
    
    ; Restore original color
    pop ax
    mov [board_color], al
    
    ; Restore original board_x
    pop ax
    mov [board_x], ax
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
erase_board endp



erase_block proc
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx

	mov al, [black_color]  ; Set color to black

	push ax
	push [bp+6]  ; X coordinate
	push [bp+4]  ; Y coordinate
	call draw_block  ; Redraw block in black

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
erase_block endp




; Add this new procedure to erase the ball
erase_ball proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Store original ball color
    mov al, [ball_color]
    push ax
    
    ; Set color to black for erasing
    mov al, [black_color]
    
    ; Draw a black square where the ball currently is
    mov cx, [ball_x]
    mov dx, [ball_y]
    mov bx, cx
    add bx, 6    ; Ball width = 4
    
    mov si, dx
    add si, 6    ; Ball height = 4
    
erase_ball_row:
    mov cx, [ball_x]
    
erase_ball_column:
    mov ah, 0ch  ; Put pixel function
    int 10h      ; Draw black pixel
    
    inc cx
    cmp cx, bx
    jb erase_ball_column
    
    inc dx
    cmp dx, si
    jb erase_ball_row
    
    ; Restore original ball color
    pop ax
    mov [ball_color], al
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
erase_ball endp









draw_block proc
	push bp
	mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push si

    mov ax, [bp+4]
    add ax, [block_hight]
    mov si, ax

    mov dx, [bp+4]

block_loop:
    mov cx, [bp+6]
    mov bx, [block_width]
	push [bp+8]
    call draw_horizontal_line

    inc dx
    cmp dx, si
    jl block_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
	pop bp
    ret 6
draw_block endp



draw_all_blocks proc
    push ax
    push bx
    push cx
    push dx
    push si
	

    mov si, offset block_matrix
    mov cx, 28
    mov dx, 0
    mov bx, 0

draw_blocks:
    cmp bx, 0
    je set_color_blue
    cmp bx, 1
    je set_color_red
    cmp bx, 2
    je set_color_yellow
	cmp bx, 3
	je set_color_green
    mov al, [green]

set_color_blue:
    mov al, [blue]
    jmp set_color_done

set_color_red:
    mov al, [red]
    jmp set_color_done

set_color_yellow:
    mov al, [yellow]
	jmp set_color_done
	
set_color_green:
	mov al, [green]

set_color_done:
    mov ah, 0
    push ax
    push [si]
    push [si+2]
    call draw_block


    add si, 4
    inc dx

    cmp dx, 7
    jne skip_row_update
    mov dx, 0
    inc bx

skip_row_update:
    loop draw_blocks

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_all_blocks endp


display_score proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Convert score to ASCII digits
    mov ax, [score]
    mov cx, 5        ; 5 digits
    mov si, offset score_digits + 4 ; Point to last digit
    
conv_loop:
    mov dx, 0
    mov bx, 10
    div bx           ; AX = quotient, DX = remainder
    add dl, '0'      ; Convert to ASCII
    mov [si], dl
    dec si
    loop conv_loop
    
    ; Set cursor position (top-left corner)
    mov ah, 02h
    mov bh, 0        ; Page 0
    mov dh, 1        ; Row 0
    mov dl, 68        ; Column 0
    int 10h
    
    ; Display "Score: " text
    mov ah, 09h
    mov dx, offset score_text
    int 21h
    
    ; Display score digits
    mov dx, offset score_digits
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_score endp