[org 0x0100]
jmp start

oldisr: dd 0

score: dw 0
lives: dw 3


rules0: db 'Please read the following instructions',0
rules1: db '1) Game ends when all bricks are broken ',0
rules2: db '2) Use A and D keys to move the breaker/paddle',0
rules3: db '3) Goodluck and Have Fun!',0

WelcomeStr: db 'Welcome to CyaN ATARI BREAKOUT!!!',0
pressEnter: db 'Press Enter to play the game',0
pressEsc: db 'Press Esc to exit',0

gameover0: db 'GAME OVER!!!',0
gameover1: db 'Your Score was: ',0



;ball direction
x: dw 2
y: dw 160

next_pos_ball: dw 2954
previos_pos_ball: dw 2954

;bar position
bar_pos_current: dw 3736
bar_pos_previous: dw 3736

;subroutine to clear the screen

clrscr:
	push es
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax  							; point es to video base
	xor di, di  							; point di to top left column
	mov ax, 0x0720  						; space char in normal attribute
	mov cx, 2000 							; number of screen locations
	cld  									; auto increment mode
	rep stosw  								; clear the whole screen
	pop di
	pop cx
	pop ax
	pop es
	ret
	
PrintStr:     ;push pos,attribute,address
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	pop es 												; load ds in es
	mov di, [bp+4] 										; point di to string
	mov cx, 0xffff 										; load maximum number in cx
	xor al, al 											; load a zero in al
	repne scasb 										; find zero in the string
	mov ax, 0xffff 										; load maximum number in ax
	sub ax, cx 											; find change in cx
	dec ax 												; exclude null from length
	jz exit 											; no printing if string is empty
	mov cx, ax 											; load string length in cx
	mov ax, 0xb800
	mov es, ax  										; point es to video base
	mov di,[bp+8]										; point di to starting position
	mov si, [bp+4]  									; point si to string
	cld  												; auto increment mode
	
	nextchar: 
		mov ah,[bp+6]
		lodsb  											; load next char in al
		cmp al,0x2A
		jne star
		mov ah,0x1E
		star:
		stosw  											; print char/attribute pair
		loop nextchar  									; repeat for the whole string
exit: 
	pop es
	popa
	pop bp
	ret 6

printnum: 
	push bp
	mov bp, sp
	pusha
	push es
	push ds
	
	mov ax, 0xb800
	mov es, ax ; point es to video base
	mov ax, [bp+4] ; load number in ax
	mov bx, 10 ; use base 10 for division
	mov cx, 0 ; initialize count of digits
	nextdigit: 
		mov dx, 0 ; zero upper half of dividend
		div bx ; divide by 10
		add dl, 0x30 ; convert digit into ascii value
		push dx ; save ascii value on stack
		inc cx ; increment count of values
		cmp ax, 0 ; is the quotient zero
		jnz nextdigit ; if no divide it again
		mov di, [bp+8] ; 
	nextpos: 
		pop dx ; remove a digit from the stack
		mov dh, [bp+6] ; use normal attribute
		mov [es:di], dx ; print char on screen
		add di, 2 ; move to next screen location
		loop nextpos ; repeat for all digits on stack
	pop ds
	pop es
	popa
	ret 6
	
	
delay:
	push cx
	push ax
	
	mov ax,2
	mov cx,0xffff
	
	del0:
		del1:
			sub cx,1
			cmp cx,0
			jne del1
		sub ax,1
		jne del0
		
	pop ax
	pop cx
	ret
	
	
Beep:
	pusha
	push es
	push ds
	
	mov al,182
	out 43h,al
	mov ax,1355
	out 42h,al
	mov al,ah
	out 42h,al
	in al,61h
	
	or al,00000011b
	out 61h,al
	
	mov bx,1
	
	beep1:
	mov cx,0xffff
		beep2:
		dec cx
		jnz beep2
	dec bx
	jnz beep1
	
	in al,61h
	and al,11111100b
	out 61h,al

	pop ds
	pop es
	popa
	ret
	
	
Border:
	pusha
	
	mov di,0
	mov si,158
	mov ax,0xb800
	mov es,ax
	mov ah,0x70
	mov al,0x20
	
	mov cx,25
	border0:
	mov [es:si],ax
	mov [es:di],ax
	add si,160
	add di,160
	loop border0
	
	mov di,2
	mov si,156
	mov cx,25
	border:
	mov [es:si],ax
	mov [es:di],ax
	add si,160
	add di,160
	loop border
	
	mov di,4
	mov si,154
	mov cx,25
	border2:
	mov word [es:si],0x0720
	mov word [es:di],0x0720
	add si,160
	add di,160
	loop border2
	
	mov si,0

	mov cx,80
	border1:
	mov [es:si],ax
	add si,2
	loop border1
	
	popa
	ret
	
ClearBrick:
	push ax
	push bx
	push si
	push di
	
	call Beep
	
	cmp word [es:di], 0x7020
	je brk1
	cmp word [es:di], 0x2F7F
	je brk1
	cmp word [es:di], 0x0720
	je brk1
	
	jmp brk0
	brk1:
	jmp BorderCollision
	
	brk0:
	add word [score],1
	cmp word [score],47
	jl brk
	jmp GameOver
	brk:
	mov bx,di
	mov si,di
	add bx,160
	sub si,160
	
	mov word [es:di],0x0720
	mov word [es:bx],0x0720
	mov word [es:si],0x0720
	
	push di
	push si
	push bx


	
	breakleft:
	sub di,2
	sub bx,2
	sub si,2
	
	cmp word [es:di],0x0720
	je breakright0
	mov word [es:di],0x0720
	mov word [es:bx],0x0720
	mov word [es:si],0x0720


	jmp breakleft
	
	breakright0:
	pop bx
	pop si
	pop di
	
	breakright:
	add di,2
	add bx,2
	add si,2
	
	cmp word [es:di],0x0720
	je BorderCollision
	mov word [es:di],0x0720
	mov word [es:bx],0x0720
	mov word [es:si],0x0720

	jmp breakright

	BorderCollision:
	pop di
	pop si
	pop bx
	pop ax
	ret
	
	
	
Breaker:
	
	pusha
	
	mov ax,0xb800
	mov es,ax
	
	mov si,[bar_pos_current]
	mov di,[bar_pos_previous]
	mov cx,20
	
	
	break:
	
	mov word[es:di],0x0720
	add di,2
	loop break
	
	mov cx,20
	break0:
	
	mov word[es:si],0x2F7F
	add si,2
	loop break0
	
	mov si,[bar_pos_current]
	mov [bar_pos_previous],si
	
	popa

	ret

Ball:
	
	pusha
	
	mov ax,0xb800
	mov es,ax
	mov di,[next_pos_ball]
	mov si,[previos_pos_ball]
	
	mov word[es:si],0x0720
	mov word[es:di],0x0FDC
	
	
	
	popa
	
	ret

	

	
WELCOME:
	pusha
	
	call clrscr
	
	mov dx,370
	push dx
	mov ax,0x0C
	push ax
	mov ax,WelcomeStr
	push ax
	call PrintStr
	
	call Beep
	
	sub dx,10
	add dx,160
	
	add dx,160
	push dx
	mov ax,0x07
	push ax
	mov ax,rules0
	push ax
	call PrintStr
	
	call Beep
	
	add dx,160
	push dx
	mov ax,0x07
	push ax
	mov ax,rules1
	push ax
	call PrintStr
	
	call Beep
	
	add dx,160
	push dx
	mov ax,0x07
	push ax
	mov ax,rules2
	push ax
	call PrintStr
	
	call Beep
	
	add dx,160
	push dx
	mov ax,0x07
	push ax
	mov ax,rules3
	push ax
	call PrintStr
	
	add dx, 10
	
	add dx, 640
	push dx
	mov ax,0x09
	push ax
	mov ax,pressEnter
	push ax
	call PrintStr
	
	call Beep
	
	add dx, 330
	push dx
	mov ax,0x09
	push ax
	mov ax,pressEsc
	push ax
	call PrintStr
	
	call Beep
	
	popa
	
	ret
	

PLAYLOOP:
	;implement everything here, rn its just a constant loop
	pusha	

	
	mov ax,0xb800
	mov es,ax
	mov ax,0
	
	call clrscr
	call Blocks
	
	call Ball
	call Border
	call Breaker
	
	DRAWGAME:

	
	call delay
	
	
	mov di,[next_pos_ball]
	add di,[x]
	add di,[y]
	cmp di,4000
	jl LifeNotLost
	jmp LifeLost
	
	LifeNotLost:
	cmp word [es:di],0x0720
	jne Collision
	jmp noCollision
	
	
	Collision:
	mov si,di
	cmp word [y],0
	jg DOWN
	;UP
	add si,2
	cmp word [es:si],0x0720
	je upRIGHT
	sub si,4
	cmp word [es:si],0x0720
	je upLEFT
	;middle
	mov word[y],+160
	jmp clear_brick
	upLEFT:
	add si,2
	cmp word[x],0
	jg uppositive0
	;negative
	mov word[y],+160
	jmp clear_brick
	uppositive0:
	mov word[x],-2
	jmp clear_brick
	upRIGHT:
	sub si,2
	cmp word[x],0
	jg uppositive1
	;negative
	
	mov word [x],+2
	jmp clear_brick
	uppositive1:
	mov word[y],+160
	jmp clear_brick
	
	DOWN:
	add si,2
	cmp word [es:si],0x0720
	je dRIGHT
	sub si,4
	cmp word [es:si],0x0720
	je dLEFT
	;middle
	cmp word [es:si],0x0FDC
	je dLEFT
	add si,2
	mov word[y],-160
	jmp clear_brick
	dLEFT:
	add si,2
	cmp word[x],0
	jg dpositive0
	;negative
	mov word[y],-160
	jmp clear_brick
	dpositive0:
	mov word[x],-2
	jmp clear_brick
	dRIGHT:
	sub si,2
	cmp word[x],0
	jg dpositive1
	;negative
	mov word[x],+2
	jmp clear_brick
	dpositive1:
	cmp word [es:si],0x7020
	je l
	mov word[y],-160
	jmp clear_brick
	l:
	mov word[x],-2
	jmp clear_brick
	
	
	clear_brick:
	call ClearBrick
	
	
	noCollision:
	
	mov di,[next_pos_ball]
	mov [previos_pos_ball],di
	add di,[x]
	add di,[y]
	mov [next_pos_ball],di
	call Ball
	
	jmp DRAWGAME
	
	LifeLost:
	call Beep
	call Beep
	call Beep
	sub word [lives],1
	cmp word [lives],0
	je GameOver
	sub di,[x]
	sub di,[y]
	mov word [es:di],0x0720
	mov word[previos_pos_ball],2954
	mov word[next_pos_ball],2954
	mov word[x],2
	mov word[y],160
	mov word [bar_pos_current],3736
	
	call Breaker
	
	call delay
	call delay
	jmp DRAWGAME
	
	GameOver:
	
	mov ax,0
	mov es, ax 					;load zero in es
	
	;cli
	;mov ax, [oldisr]
	;mov [es:9*4], ax 				; save offset of old routine
	;mov ax, [oldisr+2]
	;mov [es:9*4+2], ax 				; save segment of old routine
	;sti
	;
	call clrscr
	
	mov dx,390
	push dx
	mov ax,0x0C
	push ax
	mov ax,gameover0
	push ax
	call PrintStr
	
	sub dx,10
	add dx,160
	
	add dx,160
	push dx
	mov ax,0x07
	push ax
	mov ax,gameover1
	push ax
	call PrintStr
	
	add dx,40
	push dx
	mov ax,0x07
	push ax
	mov ax,[score]
	push ax
	call printnum
	
	ret


fun:
	pusha
	
	
	
	in al,0x60
	cmp al,30
	je left
	cmp al,32
	je right
	jmp exit2
	
	left:
	sub word [bar_pos_current],2
	cmp word [bar_pos_current],3684
	jge sk0
	add word [bar_pos_current],2
	sk0:
	call Breaker
	jmp exit2 
	
	right:
	add word [bar_pos_current],2
	cmp word [bar_pos_current],3796
	jle sk1
	sub word [bar_pos_current],2
	sk1:
	call Breaker
	jmp exit2
	
	
	exit2
	mov al, 0x20
	out 0x20, al ; send EOI to PIC
	popa
	iret
	
	
start:
		
	
	call WELCOME

l0:	mov ah,0
	int 0x16
	cmp al, 27
	je EXIT
	cmp al, 13
	jne l0
	
	mov ax,0
	mov es, ax 					;load zero in es

	mov ax, [es:9*4]
	mov [oldisr], ax 				; save offset of old routine
	mov ax, [es:9*4+2]
	mov [oldisr+2], ax 				; save segment of old routine
	cli 							; disable interrupts
	mov word [es:9*4], fun 		; store offset at n*4
	mov [es:9*4+2], cs 				; store segment at n*4+2
	sti
	
	call PLAYLOOP
	
	cli
	mov ax, [oldisr]
	mov [es:9*4], ax 				; save offset of old routine
	mov ax, [oldisr+2]
	mov [es:9*4+2], ax 
	sti
	
	
	
EXIT:
call clrscr	
mov ax,0x4c00
int 21h

Blocks:

	push ax
	push cx
	push di
	push si

	mov ax,0xb800
	mov es,ax
	
	;;;;;;;;;;;;;;;;;;;;;;line 1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov di,322
	
	mov cx,7

	;line 1
	
	r_1
	
	mov word[es:di],0x04DB
	add di,2
	
	loop r_1
	
	add di,2
	
	mov si,482
	
	mov cx,7
	r_11:
	
	mov word[es:si],0x04DB
	add si,2

	loop r_11
	
	add si,2
	;
	mov cx,5
	
	mov dl,0xdb
	mov dh,12
	
	r_2
	
	mov word[es:di],dx
	add di,2
	
	loop r_2
	add di,2
	
	mov cx,5
	r_12:
	
	mov word[es:si],dx
	add si,2

	loop r_12
	add si,2
	;
	mov cx,4
	
	mov dl,0xdb
	mov dh,04
	
	r_3
	
	mov word[es:di],dx
	add di,2
	
	loop r_3
	add di,2
	
	mov cx,4
	r_13:
	
	mov word[es:si],dx
	add si,2

	loop r_13
	add si,2
	;
	
	mov cx,9
	
	mov dl,0xdb
	mov dh,12
	
	r_4
	
	mov word[es:di],dx
	add di,2
	
	loop r_4
	add di,2
	
	mov cx,9
	r_14:
	
	mov word[es:si],dx
	add si,2

	loop r_14
	add si,2
	
	;
	
	mov cx,5
	
	mov dl,0xdb
	mov dh,4
	
	r_5
	
	mov word[es:di],dx
	add di,2
	
	loop r_5
	add di,2
	
	mov cx,5
	r_15:
	
	mov word[es:si],dx
	add si,2

	loop r_15
	add si,2
	
	;
	
	mov cx,2
	
	mov dl,0xdb
	mov dh,12
	
	r_6
	
	mov word[es:di],dx
	add di,2
	
	loop r_6
	add di,2
	
	mov cx,2
	r_16:
	
	mov word[es:si],dx
	add si,2

	loop r_16
	add si,2
	
	;
	
	mov cx,7
	
	mov dl,0xdb
	mov dh,4
	
	r_7
	
	mov word[es:di],dx
	add di,2
	
	loop r_7
	add di,2
	
	mov cx,7
	r_17:
	
	mov word[es:si],dx
	add si,2

	loop r_17
	add si,2
	
	;
	
	mov cx,10
	
	mov dl,0xdb
	mov dh,12
	
	r_8
	
	mov word[es:di],dx
	add di,2
	
	loop r_8
	add di,2
	
	mov cx,10
	r_18:
	
	mov word[es:si],dx
	add si,2

	loop r_18
	add si,2
	
	;
	mov cx,4
	
	mov dl,0xdb
	mov dh,04
	
	r_9
	
	mov word[es:di],dx
	add di,2
	
	loop r_9
	add di,2
	
	mov cx,4
	r_19:
	
	mov word[es:si],dx
	add si,2

	loop r_19
	add si,2
	;
	
	mov cx,3
	
	mov dl,0xdb
	mov dh,12
	
	r_10
	
	mov word[es:di],dx
	add di,2
	
	loop r_10
	add di,2
	
	mov cx,3
	r_20:
	
	mov word[es:si],dx
	add si,2

	loop r_20
	add si,2
	
	;
	
	mov cx,5
	
	mov dl,0xdb
	mov dh,4
	
	r_21:
	
	mov word[es:di],dx
	add di,2
	
	loop r_21
	add di,2
	
	mov cx,5
	r_22:
	
	mov word[es:si],dx
	add si,2

	loop r_22
	add si,2
	;
	
	mov cx,6
	
	mov dl,0xdb
	mov dh,12
	
	r_23:
	
	mov word[es:di],dx
	add di,2
	
	loop r_23
	add di,2
	
	mov cx,6
	r_24:
	
	mov word[es:si],dx
	add si,2

	loop r_24
	add si,2
	;
	
	;;;;;;;;;;;;;;;;;;line 2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;B light blue
	;D light purple
	;E Light yellow
	
	mov di,802
	mov si,962
	
	mov cx,3
	
	r_25:
	
	mov word[es:di],0x0EDB
	add di,2
	
	loop r_25
	
	add di,2
	
	mov cx,3
	r_26:
	
	mov word[es:si],0x0EDB
	add si,2

	loop r_26
	
	add si,2
	;
	mov cx,4
	
	mov dl,0xdb
	mov dh,0x6
	
	r_27
	
	mov word[es:di],dx
	add di,2
	
	loop r_27
	add di,2
	
	mov cx,4
	r_28:
	
	mov word[es:si],dx
	add si,2

	loop r_28
	add si,2
	;
	mov cx,7
	
	mov dl,0xdb
	mov dh,0xE
	
	r_29
	
	mov word[es:di],dx
	add di,2
	
	loop r_29
	add di,2
	
	mov cx,7
	r_30:
	
	mov word[es:si],dx
	add si,2

	loop r_30
	add si,2
	;
	
	mov cx,10
	
	mov dl,0xdb
	mov dh,6
	
	r_31
	
	mov word[es:di],dx
	add di,2
	
	loop r_31
	add di,2
	
	mov cx,10
	r_32:
	
	mov word[es:si],dx
	add si,2

	loop r_32
	add si,2
	
	;
	
	mov cx,5
	
	mov dl,0xdb
	mov dh,0xE
	
	r_33
	
	mov word[es:di],dx
	add di,2
	
	loop r_33
	add di,2
	
	mov cx,5
	r_34:
	
	mov word[es:si],dx
	add si,2

	loop r_34
	add si,2
	
	;
	
	mov cx,8
	
	mov dl,0xdb
	mov dh,6
	
	r_35
	
	mov word[es:di],dx
	add di,2
	
	loop r_35
	add di,2
	
	mov cx,8
	r_36:
	
	mov word[es:si],dx
	add si,2

	loop r_36
	add si,2
	
	;
	
	mov cx,2
	
	mov dl,0xdb
	mov dh,0xE
	
	r_37
	
	mov word[es:di],dx
	add di,2
	
	loop r_37
	add di,2
	
	mov cx,2
	r_38:
	
	mov word[es:si],dx
	add si,2

	loop r_38
	add si,2
	
	;
	
	mov cx,3
	
	mov dl,0xdb
	mov dh,6
	
	r_39
	
	mov word[es:di],dx
	add di,2
	
	loop r_39
	add di,2
	
	mov cx,3
	r_40:
	
	mov word[es:si],dx
	add si,2

	loop r_40
	add si,2
	
	;
	mov cx,4
	
	mov dl,0xdb
	mov dh,0xE
	
	r_41
	
	mov word[es:di],dx
	add di,2
	
	loop r_41
	add di,2
	
	mov cx,4
	r_42:
	
	mov word[es:si],dx
	add si,2

	loop r_42
	add si,2
	;
	
	mov cx,5
	
	mov dl,0xdb
	mov dh,6
	
	r_43
	
	mov word[es:di],dx
	add di,2
	
	loop r_43
	add di,2
	
	mov cx,5
	r_44:
	
	mov word[es:si],dx
	add si,2

	loop r_44
	add si,2
	
	;
	
	mov cx,6
	
	mov dl,0xdb
	mov dh,0xE
	
	r_45:
	
	mov word[es:di],dx
	add di,2
	
	loop r_45
	add di,2
	
	mov cx,6
	r_46:
	
	mov word[es:si],dx
	add si,2

	loop r_46
	add si,2
	;
	
	mov cx,10
	
	mov dl,0xdb
	mov dh,06
	
	r_47:
	
	mov word[es:di],dx
	add di,2
	
	loop r_47
	add di,2
	
	mov cx,10
	r_48:
	
	mov word[es:si],dx
	add si,2

	loop r_48
	add si,2
	;
	
	;;;;;;;;;;;;;;;;;;line 3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;B light blue
	;D light purple
	;E Light yellow
	
	mov di,1282
	mov si,1442
	
	mov cx,10
	
	r_49:
	
	mov word[es:di],0x01DB
	add di,2
	
	loop r_49
	
	add di,2
	
	mov cx,10
	r_50:
	
	mov word[es:si],0x01DB
	add si,2

	loop r_50
	
	add si,2
	;
	mov cx,12
	
	mov dl,0xdb
	mov dh,0xB
	
	r_51
	
	mov word[es:di],dx
	add di,2
	
	loop r_51
	add di,2
	
	mov cx,12
	r_52:
	
	mov word[es:si],dx
	add si,2

	loop r_52
	add si,2
	;
	mov cx,2
	
	mov dl,0xdb
	mov dh,0x1
	
	r_53
	
	mov word[es:di],dx
	add di,2
	
	loop r_53
	add di,2
	
	mov cx,2
	r_54:
	
	mov word[es:si],dx
	add si,2

	loop r_54
	add si,2
	;
	
	mov cx,7
	
	mov dl,0xdb
	mov dh,0XB
	
	r_55
	
	mov word[es:di],dx
	add di,2
	
	loop r_55
	add di,2
	
	mov cx,7
	r_56:
	
	mov word[es:si],dx
	add si,2

	loop r_56
	add si,2
	
	;
	
	mov cx,1
	
	mov dl,0xdb
	mov dh,01
	
	r_57
	
	mov word[es:di],dx
	add di,2
	
	loop r_57
	add di,2
	
	mov cx,1
	r_58:
	
	mov word[es:si],dx
	add si,2

	loop r_58
	add si,2
	
	;
	
	mov cx,3
	
	mov dl,0xdb
	mov dh,0XB
	
	r_59
	
	mov word[es:di],dx
	add di,2
	
	loop r_59
	add di,2
	
	mov cx,3
	r_60:
	
	mov word[es:si],dx
	add si,2

	loop r_60
	add si,2
	
	;
	
	mov cx,6
	
	mov dl,0xdb
	mov dh,1
	
	r_61
	
	mov word[es:di],dx
	add di,2
	
	loop r_61
	add di,2
	
	mov cx,6
	r_62:
	
	mov word[es:si],dx
	add si,2

	loop r_62
	add si,2
	

	mov cx,3
	
	mov dl,0xdb
	mov dh,0XB
	
	r_63
	
	mov word[es:di],dx
	add di,2
	
	loop r_63
	add di,2
	
	mov cx,3
	r_64:
	
	mov word[es:si],dx
	add si,2

	loop r_64
	add si,2
	
	;
	mov cx,5
	
	mov dl,0xdb
	mov dh,01
	
	r_65
	
	mov word[es:di],dx
	add di,2
	
	loop r_65
	add di,2
	
	mov cx,5
	r_66:
	
	mov word[es:si],dx
	add si,2

	loop r_66
	add si,2
	;
	
	mov cx,4
	
	mov dl,0xdb
	mov dh,0XB
	
	r_67
	
	mov word[es:di],dx
	add di,2
	
	loop r_67
	add di,2
	
	mov cx,4
	r_68:
	
	mov word[es:si],dx
	add si,2

	loop r_68
	add si,2
	
	;
	
	mov cx,8
	
	mov dl,0xdb
	mov dh,01
	
	r_69:
	
	mov word[es:di],dx
	add di,2
	
	loop r_69
	add di,2
	
	mov cx,8
	r_70:
	
	mov word[es:si],dx
	add si,2

	loop r_70
	add si,2
	;
	
	mov cx,6
	
	mov dl,0xdb
	mov dh,0XB
	
	r_71:
	
	mov word[es:di],dx
	add di,2
	
	loop r_71
	add di,2
	
	mov cx,6
	r_72:
	
	mov word[es:si],dx
	add si,2

	loop r_72
	add si,2
	;
	
	;;;;;;;;;;;;;;;;;;line 4;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;B light blue
	;D light purple
	;E Light yellow
	
	mov di,1762
	mov si,1922
	
	mov cx,5
	
	r_73:
	
	mov word[es:di],0x0DDB
	add di,2
	
	loop r_73
	
	add di,2
	
	mov cx,5
	r_74:
	
	mov word[es:si],0x0DDB
	add si,2

	loop r_74
	
	add si,2
	;
	mov cx,3
	
	mov dl,0xdb
	mov dh,0x5
	
	r_75
	
	mov word[es:di],dx
	add di,2
	
	loop r_75
	add di,2
	
	mov cx,3
	r_76:
	
	mov word[es:si],dx
	add si,2

	loop r_76
	add si,2
	;
	mov cx,7
	
	mov dl,0xdb
	mov dh,0x0D
	
	r_77
	
	mov word[es:di],dx
	add di,2
	
	loop r_77
	add di,2
	
	mov cx,7
	r_78:
	
	mov word[es:si],dx
	add si,2

	loop r_78
	add si,2
	;
	
	mov cx,2
	
	mov dl,0xdb
	mov dh,0X5
	
	r_79
	
	mov word[es:di],dx
	add di,2
	
	loop r_79
	add di,2
	
	mov cx,2
	r_80:
	
	mov word[es:si],dx
	add si,2

	loop r_80
	add si,2
	
	;
	
	mov cx,8
	
	mov dl,0xdb
	mov dh,0x0D
	
	r_81
	
	mov word[es:di],dx
	add di,2
	
	loop r_81
	add di,2
	
	mov cx,8
	r_82:
	
	mov word[es:si],dx
	add si,2

	loop r_82
	add si,2
	
	;
	
	mov cx,9
	
	mov dl,0xdb
	mov dh,0X5
	
	r_83
	
	mov word[es:di],dx
	add di,2
	
	loop r_83
	add di,2
	
	mov cx,9
	r_84:
	
	mov word[es:si],dx
	add si,2

	loop r_84
	add si,2
	
	;
	
	mov cx,5
	
	mov dl,0xdb
	mov dh,0x0D
	
	r_85
	
	mov word[es:di],dx
	add di,2
	
	loop r_85
	add di,2
	
	mov cx,5
	r_86:
	
	mov word[es:si],dx
	add si,2

	loop r_86
	add si,2
	
	;
	
	mov cx,10
	
	mov dl,0xdb
	mov dh,0X5
	
	r_87
	
	mov word[es:di],dx
	add di,2
	
	loop r_87
	add di,2
	
	mov cx,10
	r_89:
	
	mov word[es:si],dx
	add si,2

	loop r_89
	add si,2
	
	;
	mov cx,5
	
	mov dl,0xdb
	mov dh,0x0D
	
	r_90
	
	mov word[es:di],dx
	add di,2
	
	loop r_90
	add di,2
	
	mov cx,5
	r_91:
	
	mov word[es:si],dx
	add si,2

	loop r_91
	add si,2
	;
	
	mov cx,4
	
	mov dl,0xdb
	mov dh,0X5
	
	r_92
	
	mov word[es:di],dx
	add di,2
	
	loop r_92
	add di,2
	
	mov cx,4
	r_93:
	
	mov word[es:si],dx
	add si,2

	loop r_93
	add si,2
	
	;
	
	mov cx,3
	
	mov dl,0xdb
	mov dh,0x0D
	
	r_94:
	
	mov word[es:di],dx
	add di,2
	
	loop r_94
	add di,2
	
	mov cx,3
	r_95:
	
	mov word[es:si],dx
	add si,2

	loop r_95
	add si,2
	;
	
	mov cx,6
	
	mov dl,0xdb
	mov dh,0X5
	
	r_96:
	
	mov word[es:di],dx
	add di,2
	
	loop r_96
	add di,2
	
	mov cx,6
	r_97:
	
	mov word[es:si],dx
	add si,2

	loop r_97
	add si,2
	;
	
	pop si
	pop di
	pop cx
	pop ax
	
	ret