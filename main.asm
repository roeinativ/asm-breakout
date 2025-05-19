.MODEL small
INCLUDE utilFunc.asm
INCLUDE drawings.asm
INCLUDE drawBmp.asm
	

.STACK 100h

.DATA
move_rec dw 10 ;distance of the board x moved each press

move_ball_y dw -2 ;the distance the ball y moves each frame
move_ball_x dw 2 ; the distance the ball x moves each frame

save_move_ball_y dw 2 ;saves move_ball_y
save_move_ball_x dw 3 ;saves move_ball_x

deviation dw 0 ;the deviation changes according to the ball speed so he wont exit the screen


stuck_on_board dw 1 ; 1 = stuck on board, 0 = free

blocks_hit dw 0

lifes_left dw 3

score dw 0
score_text db "Score: ", "$"
score_digits db "00000$"


block_matrix dw  48,  35,   80,  35,  112,  35,  144,  35,  176,  35,  208,  35,  240,  35
             dw  48,  47,   80,  47,  112,  47,  144,  47,  176,  47,  208,  47,  240,  47
             dw  48,  59,   80,  59,  112,  59,  144,  59,  176,  59,  208,  59,  240,  59
             dw  48,  71,   80,  71,  112,  71,  144,  71,  176,  71,  208,  71,  240,  71
			 
save_block_matrix dw  48,  35,   80,  35,  112,  35,  144,  35,  176,  35,  208,  35,  240,  35
             dw  48,  47,   80,  47,  112,  47,  144,  47,  176,  47,  208,  47,  240,  47
             dw  48,  59,   80,  59,  112,  59,  144,  59,  176,  59,  208,  59,  240,  59
             dw  48,  71,   80,  71,  112,  71,  144,  71,  176,  71,  208,  71,  240,  71

.CODE
main:
    mov ax, @data
    mov ds, ax
	
	call OpeningScreen ; The game opening screen

; Waits for a key press in the opening screen 
check_key:
    mov ah,01h      
    int 16h
    jz check_key  
    
    mov ah,00h     
    int 16h
    
    cmp al,13
	je start_game
    
	cmp al,1Bh
	jne	countinue6
	jmp text_mode

; Used for the out of range error
countinue6:
	
	jmp check_key

; Restarts all of the game parameters to fit into a new game	
start_game:
	mov word ptr [stuck_on_board],1
	mov word ptr [lifes_left],3
	mov word ptr [blocks_hit],0
	mov word ptr [score],0
	

	mov si, offset save_block_matrix  
    mov di, offset block_matrix       
    mov cx, 28 * 2

	; Save ball location and movement
	mov word ptr [board_x],140
	mov word ptr [ball_x],162
	mov word ptr [ball_y],179
	
	mov ax,[save_move_ball_x]
	mov word ptr [move_ball_x],ax
	
	mov ax,[save_move_ball_y]
	mov word ptr [move_ball_y],ax

; Copy the current block matrix into the new one
copy_loop1:
    mov ax, [si]              
    mov [di], ax                  
    add si, 2                       
    add di, 2                         
    loop copy_loop1                   

    mov word ptr [blocks_hit], 0       
 	
	call clear_screen_opening
	call draw_all_blocks

; The game loop of the game
game_loop:	
	call display_score
	call draw_all_lifes
	call draw_rectangle
	call draw_ball
	call direction
	call hit_block
	call ball_move
	call delay_loop

	;Escape button	
	cmp al, 1Bh 
	je pause1

	; Compares if the player lost all of his lifes
	cmp word ptr [lifes_left],0
	je game_over
	jmp game_loop

; If player lost the game moves into this part of the ending screen 	
game_over:
	call clear_screen_opening
	call EndingScreen
	jmp check_key_ending

; Awaits for the player to press a key	
check_key_ending:
	mov ah,01h
	int 16h
	jz check_key_ending
	
	mov ah,00h
	int 16h
	
	cmp al,13
	jne countinue9
	jmp start_game

; Used because of the out of range error	
countinue9:	
	cmp al,1Bh
	je text_mode
	
	jmp check_key_ending
	
	
; If the player presses escape move to the pause screen	
pause1:
    call PauseScreen 

; A waits for a key press to countinue the game
check_key_pause:
    mov ah,01h
    int 16h
    jz check_key_pause
    
    mov ah,00h
    int 16h
    
    cmp al,1Bh
    je text_mode
    
    cmp al,32    ; Space key
    je continue_game
    
    cmp al,13    ; Enter key
    je restart_game
    
    jmp check_key_pause

continue_game:
    call clear_screen_opening
    call draw_all_blocks
    jmp game_loop
    
restart_game:
    jmp start_game   
	
; Move back to the editor text mode	
text_mode:
    mov ah, 0
    mov al, 2
    int 10h
	jmp exit

; Exit the code end close the game
exit:
    mov ax, 4c00h
    int 21h



; A function that gets an arrow input and moves the board
direction proc
	mov ah,01h
	int 16h
	jnz check_input
	ret
	
check_input:	
	mov ah, 00h ;checks if the input is an arrow
	int 16h
	cmp al, 0
	je arrows
	
	cmp al, 20h ; Space button
	je launch_ball
	jmp  direction_end
	
	
launch_ball:
	mov ax, [stuck_on_board]
    cmp ax, 1
    je countinue
	ret
countinue:	
    mov ax, 0
    mov [stuck_on_board], ax
    jmp  direction_end
	
arrows:	
	cmp ah, 4Dh
	je move_right
	
	cmp ah, 4Bh
	je move_left
	jmp  direction_end
	
move_right:	
	; Make so the board wont exit the screen
	push ax
	mov ax, [board_x]
	cmp ax, 270
	jae skip_move_right

	; Make so the board will erase himself and also move
	mov [prev_board_x],ax
	call erase_board
	
	add ax, [move_rec] 	
	mov [board_x], ax
	
	call draw_rectangle
	
	; If the ball is stuck on the board move it with the board
	mov ax, [stuck_on_board]
	cmp ax,1
	je move_ball_right
	
	jmp skip_move_right
	
move_ball_right:
	call erase_ball
	mov ax, [ball_x]
	add ax, [move_rec]
	mov [ball_x], ax
	call draw_ball
	
skip_move_right:
	pop ax
	jmp direction_end

move_left:
	; Make so the board wont exit the screen
	push ax
	mov ax, [board_x]
	cmp ax,0
	jbe skip_move_left
	
	mov [prev_board_x],ax
	
	
	call erase_board
	
	sub ax, [move_rec]
	mov [board_x], ax
	
	call draw_rectangle
	
	mov ax, [stuck_on_board]
	cmp ax,1
	je move_ball_left
	
	jmp skip_move_left
	
move_ball_left:
	call erase_ball
	mov ax, [ball_x]
	sub ax, [move_rec]
	mov [ball_x], ax
	call draw_ball

	
	
skip_move_left:
	pop ax
	jmp direction_end

direction_end:
	ret
direction endp

; A function that moves the ball if he is not stuck on the board
ball_move proc
	push ax
	push bx
	push cx
	push dx

	mov ax, [stuck_on_board]
	cmp ax,1
	jne ball_countinue
	pop dx
	pop cx
	pop bx
	pop ax
	ret

ball_countinue:	
	call erase_ball
	mov bx, [ball_x]
	add bx, [move_ball_x]
	mov [ball_x], bx
	; Checks if the ball hit the left wall
	cmp bx,0
	jle sides_wall
	
	; Makes so the ball wont exit the screen based on his speed that is changing
	mov ax, 316
	mov dx,[deviation]
	sub ax,dx
	
	; Checks if the ball hit the right wall
	cmp bx, ax
	jge sides_wall
	
	mov [ball_x], bx
	
	
	mov cx, [ball_y]
	add cx, [move_ball_y]
	mov [ball_y], cx

	; Checks if the ball hit the top or bottom wall
	cmp cx, 1
	je top_wall
	cmp cx, 199
	je bottom_wall
	
	cmp cx,181
	je check_ball_x
	
	call draw_ball
	jmp ball_move_end

; Makes the ball bounce back based on which wall he hit	
sides_wall:
	
	mov bx, [move_ball_x]
	neg bx
	mov [move_ball_x],bx
	jmp ball_move_end
	
	
	
top_wall:
	mov cx, [move_ball_y]
	neg cx
	mov [move_ball_y],cx
	jmp ball_move_end
	
	
	
bottom_wall:
	mov ax, [stuck_on_board]
	mov ax,1
	mov [stuck_on_board],ax
	
	mov bx,[board_x]
	add bx,22
	mov [ball_x],bx
	
	mov cx,[board_y]
	sub cx,6
	mov [ball_y],cx
	
	mov bx,[save_move_ball_x]
	mov [move_ball_x],bx
	
	mov cx,[save_move_ball_y]
	mov [move_ball_y],cx
	
	mov ax,[lifes_left]
	dec ax
	mov [lifes_left],ax
	
; When the ball y level is the same as the board it checks if he hit it and where
check_ball_x:
	mov bx,[ball_x]
	mov cx,[board_x]
	
	; Checks if the ball is to the left of the board
	mov dx,cx
	sub dx,10
	
	cmp bx,dx
	jge countinue4
	pop dx
	pop cx
	pop bx
	pop ax
	ret

; Countinue because of the out of range error
; Checks if the ball is to the right of the board

countinue4:
	add dx,64
	cmp bx,dx
	jg ball_move_end
	
	cmp bx,140
	je edges
	
	cmp bx, 180
	je edges
	
	cmp bx,160
	je middle_board
	
	jmp rest_of_board

edges:
	mov cx,[move_ball_y]
	neg cx
	mov [move_ball_y],cx

	mov ax,[move_ball_x]
	inc ax
	mov [move_ball_x],ax
	
	; adds deviation in order to the ball to not exit the screen
	cmp ax,3
	je inc_devation
	
	jmp ball_move_end

inc_devation:
	mov dx,[deviation]
	cmp dx,3
	je skip_deviation
	
	inc dx
	mov [deviation],dx
	
	jmp ball_move_end

	
middle_board:
	mov cx,[move_ball_y]
	neg cx
	mov [move_ball_y],cx
	jmp ball_move_end
	
	
rest_of_board:
	mov cx,[move_ball_y]
	neg cx
	mov [move_ball_y],cx
	
	mov ax,[move_ball_x]
	cmp ax,1
	je countinue3
	dec ax
	mov [move_ball_x],ax
	
countinue3:	
	cmp ax,2
	je dec_deviation
	
	jmp ball_move_end

dec_deviation:
	mov dx,[deviation]
	cmp dx, 0
	je skip_deviation
	
	dec dx
	mov [deviation],dx

skip_deviation:
	jmp ball_move_end
	
ball_move_end:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
ball_move endp

; A function that checks if the ball hit a block and if so erases it
hit_block proc
	push ax
	push bx
	push dx
	push si
	
	
	mov ax,[stuck_on_board]
	cmp ax,1
	jne block_countinue1
	pop si
	pop dx
	pop bx
	pop ax
	ret

block_countinue1:	
	mov si, offset block_matrix
	mov bx,0
		
; Runs for each value of the matrix and checks if he hit it
row_loop:	
	mov cx,0
	col_loop:
		mov ax,[ball_x]
		add ax,[ball_size]
		cmp ax, [si]
		jge countinue7
		jmp next_block
		
countinue7:
		mov ax,[ball_x]
		mov dx,[si] ; si = block x
		add dx,[block_width]
		cmp ax,dx
		jg next_block
		
		
		mov ax,[ball_y]
		add ax,[ball_size]
		cmp ax, [si+2] ; si + 2 = block y
		jl next_block
		
		mov ax,[ball_y]
		mov dx,[si+2]
		add dx,[block_hight]
		cmp ax,dx
		jg next_block
		
		; If the block x or y is -1 it means this block has already been hit so skip it
		mov ax,[si]
		cmp ax,-1
		je next_block
		
		push [si]
		push [si+2]
		call erase_block
		
		mov word ptr [si],-1
		mov word ptr [si+2],-1
		
		add word ptr [score],50
		
		mov ax,[ball_x]

		cmp ax,[si]
		je hit_sides_block
		
		cmp ax,[si] + [block_width]
		je hit_sides_block
		
		jmp hit_roofs_block

; Bounce the ball based on where he hit the ball		
hit_roofs_block:
	mov bx, [move_ball_y]
	neg bx
	mov [move_ball_y],bx
	
	mov ax,[blocks_hit]
	inc ax
	mov [blocks_hit],ax
	cmp ax,28
	je out_of_blocks
	
	jmp hit_block_end
		
hit_sides_block:
	mov bx, [move_ball_x]
	neg bx
	mov [move_ball_x],bx
	
	mov ax,[blocks_hit]
	inc ax
	mov [blocks_hit],ax
	cmp ax,28
	je out_of_blocks
	
	jmp hit_block_end
	
; Add si 4 to move to the next block and check if finished all of the blocks on the row	
next_block:
	add si,4
	inc cx
	cmp cx,7
	jge countinue5
	jmp col_loop

countinue5:	
    inc bx
    cmp bx,4
    jge skip_row_jump
    jmp row_loop
skip_row_jump:
    jmp hit_block_end


; When there are no blocks left move the block matrix into a one that saves him in order to create new blocks 
out_of_blocks:
    mov si, offset save_block_matrix  
    mov di, offset block_matrix       
    mov cx, 28 * 2                    

copy_loop2:
    mov ax, [si]              
    mov [di], ax                  
    add si, 2                       
    add di, 2                         
    loop copy_loop2                    

    mov word ptr [blocks_hit], 0       

    call draw_all_blocks              



			
hit_block_end:
	pop si
	pop dx
	pop bx
	pop ax
	ret


hit_block endp








; Delay the screen in order to the ball to not go to fast 
delay_loop proc
    mov cx, 25000    ; Maximum value for a 16-bit register
delay_inner:
    nop
    loop delay_inner
    ret
delay_loop endp

END main
