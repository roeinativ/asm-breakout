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


; A function that draws a horizontal line for the board
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


; A function that draws the player board
draw_rectangle proc
    push ax
    push bx
    push cx
    push dx
    push si


    mov ax, [board_y]      
    add ax, [height] 
    mov si, ax       ; si now holds the bottom coordinate

    mov dx, [board_y]     

fill_loop:
    mov cx, [board_x]      ; Starting x for the horizontal line
    mov bx, [width1] 
	
	
	mov ah,0
	mov al,[board_color]
	push ax ; push the color
    call draw_horizontal_line  

    inc dx         ; Move to the next row
    cmp dx, si     
    jl fill_loop   ; If dx < bottom countinue the loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_rectangle endp




; A function that draws the ball
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

; Loops around the ball row and columns	
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


; A function that draws the life
draw_life proc
	push bp 
	mov bp,sp
	
	push ax
	push bx
	push cx
	push dx
	
	mov al,[ball_color]

	; Uses bp as parameters to draw them
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

; A function that draws all of the lifes
draw_all_lifes proc
    push ax

    mov ax, [lifes_left]

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

; A function that erases a life
erase_life proc
    push bp
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov al, [black_color]
    
    mov cx, [bp+6]    
    mov dx, [bp+4]    
    

    mov bx, cx
    add bx, 6          ; Right edge
    mov si, dx
    add si, 6          ; Left edge
    
erase_life_row:
    mov cx, [bp+6]     
    
erase_life_column:
    mov ah, 0ch        ; Put pixel function
    int 10h            
    
    inc cx            
    cmp cx, bx
    jb erase_life_column
    
    inc dx            
    cmp dx, si
    jb erase_life_row
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4            
erase_life endp

; S function that takes the board previous x erases him and draws him again
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
	
    mov al, [black_color]
    mov [board_color], al
    
    ; Draw a black rectangle at previous position
    call draw_rectangle
    
    pop ax
    mov [board_color], al

    pop ax
    mov [board_x], ax
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
erase_board endp


; A function that erases a block
erase_block proc
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx

	mov al, [black_color]  ; Set color to black

	push ax
	push [bp+6]  
	push [bp+4]  
	call draw_block  ; Redraw block at given position with black color

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
erase_block endp



; A function that erases the ball
erase_ball proc
    push ax
    push bx
    push cx
    push dx
    push si
    

    mov al, [ball_color]
    push ax
    
    ; Set color to black for erasing
    mov al, [black_color]
    
    ; Draw a black square where the ball currently is
    mov cx, [ball_x]
    mov dx, [ball_y]
    mov bx, cx
    add bx, 6    
    
    mov si, dx
    add si, 6    
	
erase_ball_row:
    mov cx, [ball_x]
    
erase_ball_column:
    mov ah, 0ch  ; Put pixel function
    int 10h     
    
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


; A function that draws the ball using bp as parameters
draw_block proc
	push bp
	mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push si
	
	mov ax,[bp+6]
	cmp ax,-1
	je skip_draw_block

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
	
skip_draw_block:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
	pop bp
    ret 6
draw_block endp


; A function that takes the block matrix and uses each position as parameters to draw the block and also adds him colors
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

; A function that draws the score
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
    div bx           
    add dl, '0'      
    mov [si], dl
    dec si
    loop conv_loop
    
    
    mov ah, 02h
    mov bh, 0        ; Page 0
    mov dh, 1        ; Row 1
    mov dl, 68        ; Column 68
    int 10h
    
    ; Display Score:  text
    mov ah, 09h
    mov dx, offset score_text
    int 21h
    
    ; Display Score digits
    mov dx, offset score_digits
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_score endp