.data
    ; for write functions
    hexString db '0000$', 0    ; Buffer for the hexadecimal string
    decString db 6 dup('$')    ; Buffer for the decimal string
    newline db 0Dh,0Ah,'$'     ; Newline for printing - Carriage return and line feed characters

    ; for read functions
    inputBuffer db 7 ; max 5 digits for numbers up to 127 and CR+LF
    ;number dw ?
    nextChr dw ?

    current_random_state dw 1 ; this is the seed of random numbers
    modResult dw ?
    numRows  dw 25
    numClmns dw 80

.code

; this function check if character exist in string
myStrLen1 equ [bp+8]
myStr1 	  equ [bp+6]
myNum1    equ [bp+4]
check_char_in_string proc
	push bp
	mov bp,sp
	push bx
	push cx
	push si
	
    mov si, myStr1          ; Load address of the array into SI
	mov bx, myNum1
    mov cx, myStrLen1       ; Number of elements in the array
	
    xor ax, ax            ; AX = 0, indicating "not found" by default
	
check_loop:
    cmp bl, [si]         ; Compare BL (character) with the current byte in the string
    je found             ; If equal, we found a match
    inc si               ; Move to the next character
    loop check_loop      ; Loop until CX becomes 0
    jmp exit_proc        ; If loop completes, no match was found

found:
    mov ax, 1            ; Set AX = 1 to indicate the character was found

exit_proc:	
	pop si
	pop cx
	pop bx
	pop bp
	ret 6				 ; Clean up 3 words of parameters (6 bytes)
check_char_in_string endp


;Clear the screen - text mode
clear_screen proc
    push ax
    push cx
    push di
    push es
    
    ; Set ES to video memory segment (A000h for mode 13h)
    mov ax, 0A000h
    mov es, ax
    
    ; Set DI to the start of video memory
    xor di, di          ; DI = 0
    
    ; Set AL to the color you want to fill with (0 for black)
    xor al, al          ; AL = 0 (black)
    
    ; Set CX to the number of pixels (320x200 = 64000 pixels in mode 13h)
    mov cx, 64000       ; 320x200 pixels in mode 13h
    
    ; Use REP STOSB to fill memory with the color in AL
    cld                 ; Clear direction flag (increment DI)
    rep stosb           ; Repeat CX times: Store AL at ES:DI and increment DI
    
    pop es
    pop di
    pop cx
    pop ax
    ret
clear_screen endp



clear_screen_opening proc
    mov ax, 13h
    int 10h
    ret
clear_screen_opening endp



clearScreenGraphics proc
    mov ax, 0A000h     ; Set ES to the video memory segment
    mov es, ax
    xor di, di         ; Start at the beginning of video memory
    mov al, 1          ; Color value to set (1 is blue in the default palette)
    mov cx, 32000      ; Number of words to set (64000 bytes / 2)
    cld                ; Clear direction flag for forward copying
    rep stosw          ; Fill the video memory with the color (word-wise for efficiency)
    ret
clearScreenGraphics endp


clearScreenGraphics1 proc
    mov ax, 0A000h     ; Set ES to the video memory segment
    mov es, ax
    xor di, di         ; Start at the beginning of video memory
    mov al, 0          ; Color value to set (0 is black in the default palette)
    mov cx, 64000      ; Number of words to set (64000 bytes / 2)
    cld                ; Clear direction flag for forward copying
    rep stosb          ; Fill the video memory with the color (word-wise for efficiency)
    ret
clearScreenGraphics1 endp

; this procedure generate a 1 second delay
delay_1s proc
    push ax
    push cx
    push dx
    mov al, 0 
    mov ah, 86h
    ; cx:dx it the delay time in microseconds. so 000F4240 microseconds is 1 second
    mov cx, 0Fh
    mov dx, 04240h
    int 15h
    pop dx
    pop cx
    pop ax
    ret
delay_1s endp

delay_1_second proc
    push cx
    push dx

    mov cx, 0FFFFh  ; Large outer loop
delay_outer_loop:
    mov dx, 0FFFFh  ; Large inner loop
delay_inner_loop:
    dec dx
    jnz delay_inner_loop  ; Repeat inner loop

    dec cx
    jnz delay_outer_loop  ; Repeat outer loop

    pop dx
    pop cx
    ret
delay_1_second endp



; delay with loop - very inaccurate
delay11 proc near
    push ax
    push bx
    push cx
    mov bx, 20    ; Outer loop count
OuterDelayLoop:
    mov cx, 0FFFFh  ; Inner loop count
InnerDelayLoop:
    dec cx
    jnz InnerDelayLoop
    dec bx
    jnz OuterDelayLoop
    pop cx
    pop bx
    pop ax
    ret
delay11 endp


; this procedure generate a 16.7 mili second delay
delay_16ms proc
    push ax
    push cx
    push dx
    mov al, 0 
    mov ah, 86h
    ; cx:dx it the delay time in microseconds. so 000411ah is 16666 microseconds is 16.7 milisecond
    mov cx, 0h
    mov dx, 0411ah
    int 15h
    pop dx
    pop cx
    pop ax
    ret
delay_16ms endp


; this procedure generate a 33.3 mili second delay
delay_33ms proc
    push ax
    push cx
    push dx
    mov al, 0 
    mov ah, 86h
    ; cx:dx it the delay time in microseconds. so 0008235h is 33333 microseconds is 33.3 milisecond
    mov cx, 0h
    mov dx, 08235h
    int 15h
    pop dx
    pop cx
    pop ax
    ret
delay_33ms endp



; return ax-random row, bx- random column
getXy proc

    ; get coloumn ( 0 to 79)
    call xor_shift_16
    
    push [numClmns]
    call myModulo
    mov bx,[modResult]
    
    
    ; get row ( 0 to 24)
    call xor_shift_16
    
    push [numRows]
    call myModulo
    mov ax,[modResult]

    ret
getXy endp


 

; the function do modulu
; MyNumber % myModDiv or a%b
;
; to use this Function
; mov a,13
; mov b,10
; push a
; push b
; call myModulo1
; mov ax,[modResult]
; call print_dec ; print ax
;
myNumber equ [bp+6]
myModDiv equ [bp+4]

myModulo proc 
    push bp
    mov bp,sp
    ;push ax
    push cx
    push dx
    MOV AX, myNumber ; Load the value of x into AX
    XOR DX, DX   ; Clear DX before division to hold the high word of the dividend
    ;MOV CX, 80    ; Move the divisor (80) into CX
    MOV CX, myModDiv    ; Move the divisor (80) into CX
    DIV CX       ; Divide DX:AX by CX, quotient goes to AX, remainder to DX
    ; Now, DX holds the result of x % 80
    mov ax,dx
 ;   mov [modResult],dx
    pop dx
    pop cx
   ; pop ax
    pop bp
    ret 4 ; release two parameters from stack
myModulo endp  

print_dec PROC
    PUSH AX    ; Save AX
    PUSH BX    ; Save BX
    PUSH CX    ; Save CX
    PUSH DX    ; Save DX
    PUSH SI    ; Save SI

    MOV CX, 0  ; Clear CX, it will count the number of digits
    MOV BX, 10 ; BX will be our divisor for the decimal conversion

    ; Check if AX is 0, and handle this special case
    TEST AX, AX
    JZ print_zero

    LEA SI, decString + 5 ; Start from the end of the buffer
    MOV byte ptr [SI], '$' ; Null-terminate the string

    convert_loop_dec:
        XOR DX, DX      ; Clear DX for DIV
        DIV BX          ; AX = DX:AX / BX, DX = remainder
        ADD DL, '0'     ; Convert remainder to ASCII
        DEC SI          ; Move back in the string buffer
        MOV [SI], DL    ; Store ASCII character
        INC CX          ; Increment digit count
        TEST AX, AX     ; Check if AX is zero now
        JNZ convert_loop_dec

    ; Print the string
    MOV DX, SI
    MOV AH, 09h
    INT 21h
    mov dx, OFFSET newline ; Print carriage return and line feed to start a new line
    int 21h
    JMP done_dec

    print_zero:
    MOV DX, OFFSET decString
    mov SI, dx
    MOV byte ptr [SI], '0'
    MOV byte ptr [SI + 1], '$'
    MOV AH, 09h
    INT 21h
    mov dx, OFFSET newline ; Print carriage return and line feed to start a new line
    int 21h

    done_dec:
    POP SI     ; Restore registers
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_dec ENDP


print_hex PROC
    PUSH AX    ; Save AX
    PUSH BX    ; Save BX
    PUSH CX    ; Save CX
    PUSH DX    ; Save DX

    MOV CX, 4   ; We will convert 4 nibbles (16 bits)
    LEA DI, hexString + 3 ; Start from the end of the buffer

    convert_loop:
        PUSH AX    ; Save AX register
        MOV AH, 0  ; Clear AH
        AND AX, 0Fh ; Isolate the lowest nibble
        CMP AL, 9
        JG letter
        ADD AL, '0' ; Convert to ASCII number
        JMP done
    letter:
        ADD AL, 'A' - 10 ; Convert to ASCII letter
    done:
        MOV [DI], AL ; Store the character
        POP AX       ; Restore AX register
        SHR AX, 4    ; Shift right by 4 bits to process the next nibble
        DEC DI       ; Move to the previous character in the buffer
        LOOP convert_loop

    ; Print the string
    MOV DX, OFFSET hexString
    MOV AH, 09h
    INT 21h
    mov dx, OFFSET newline ; Print carriage return and line feed to start a new line
    int 21h

    POP DX    ; Restore registers
    POP CX
    POP BX
    POP AX
    RET
print_hex ENDP

print_newline proc
	push ax
	push dx
	lea dx, newline         ; Print newline
    mov ah, 9
    int 21h
	pop dx
	pop ax
	ret
print_newline endp

print_string PROC
    PUSH AX    ; Save AX register
    PUSH DX    ; Save DX register if it's not the source

    MOV AH, 09h    ; Function 09h - Write string to standard output
    ; DX should already contain the offset of the string
    INT 21h        ; DOS interrupt
    mov dx, OFFSET newline ; Print carriage return and line feed to start a new line
    int 21h

    POP DX     ; Restore DX register
    POP AX     ; Restore AX register
    RET
print_string ENDP


;write functions
print_string_nonewline PROC
    PUSH AX    ; Save AX register
    PUSH DX    ; Save DX register if it's not the source

    MOV AH, 09h    ; Function 09h - Write string to standard output
    ; DX should already contain the offset of the string
    INT 21h        ; DOS interrupt

    POP DX     ; Restore DX register
    POP AX     ; Restore AX register
    RET
print_string_nonewline ENDP







;read functions
ReadNumber PROC
    ;PUSH AX    ; no need to save AX , because we return value in ax
    PUSH BX    ; Save BX
    PUSH CX    ; Save CX
    PUSH DX    ; Save DX


    ; Read string
    mov ah, 0Ah
    lea dx, inputBuffer
    int 21h

    ; Convert string to number
    xor bx, bx       ; BX = 0 
    xor cx, cx       ; cx = 0 
    mov si, OFFSET inputBuffer + 2 ; Skip max length and actual length bytes
    
        xor ax, ax    ; Clear AX
        mov al, [si]  ; read first character
        cmp al, 13    ; Check for carriage return (end of input)
        je end_convert
        sub al, '0'   ; Convert ASCII to numerical value
        mov [nextChr],ax 
        add cx,[nextChr]     

    convert_loop_rd:
        xor ax, ax
        inc si        
        mov al, [si]
        cmp al, 13    
        je end_convert
        sub al, '0'   
        mov [nextChr], ax
    
        xor ax,ax
        mov ax,cx 
        mov bl, 10
        mul bl       ; al*bl
        mov cx,ax
        add cx,[nextChr]

        jmp convert_loop_rd
    end_convert:
        ;add cx,[nextChr]
        mov ax,cx
    
    POP DX
    POP CX
    POP BX
    ;POP AX
    ret
ReadNumber ENDP


mySeed equ [bp+4]

set_random_seed proc
	push bp
	mov bp,sp
	push ax

	MOV AX, mySeed ;
	mov [current_random_state], ax

	pop ax
	pop bp
	ret 2
set_random_seed endp

; function do create pseudo random numbers. 
; i think i took it from chatgpt
;
; at the start of running 'current_random_state' holds some number for example 12345
; than it does some calculation and 'current_random_state' will change to other number
; each time we call to 'xor_shift_16' , the variable 'current_random_state' is changes
; 
; no need to pass any variable
; the function return the random number to ax

xor_shift_16 proc 
    ;push ax
    push bx
    mov ax,[current_random_state]
    mov bx,[current_random_state]
    shl ax,13
    xor bx,ax
    mov [current_random_state],bx
    mov ax,bx ; current_random_state
    shr ax,9
    xor bx,ax
    mov [current_random_state],bx
    mov ax,bx ; current_random_state
    shl ax,7
    xor bx,ax
    mov [current_random_state],bx
	
	mov ax, [current_random_state] ; return the next random number
	
    pop bx
    ;pop ax
    ret
xor_shift_16 endp 


