[org 0x100]
jmp start

basketVal: dw 3760
testVal: dw 346, 432, 364, 398, 444, 468, 432, 468
testAlph: dw 68, 70, 74, 78, 80, 86, 80, 86
tick: db 0,0,0,0,0,0,0,0
oldisr: dd 0
oldkbisr: dd 0
StartString: dw 'Press Any Button To Start!', 0
Lives: dw 'XXXXXXXXXX'
LivesL: dw 0
LivesString: dw 'LIVES :', 0
ScoreString: dw 'SCORE :', 0
Score: dw '0000',0
GameString: dw '----------------GAME OVER----------------', 0
attribute: db 0x07

rand: dw 0
randnum: dw 0

; taking n as parameter, generate random number from 0 to n nad return in the stack
randG:
   push bp
   mov bp, sp
   pusha
   cmp word [rand], 0
   jne next

  MOV     AH, 00h   ; interrupt to get system timer in CX:DX 
  INT     1AH
  inc word [rand]
  mov     [randnum], dx
  jmp next1

  next:
  mov     ax, 25173          ; LCG Multiplier
  mul     word  [randnum]     ; DX:AX = LCG multiplier * seed
  add     ax, 13849          ; Add LCG increment value
  ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
  mov     [randnum], ax          ; Update seed = return value

 next1:xor dx, dx
 mov ax, [randnum]
 mov cx, [bp+4]
 inc cx
 div cx
 
 mov [bp+6], dx
 popa
 pop bp
 ret 2

genLet:
sub sp, 2
push 25
call randG
pop dx
add dx, 65
ret

genCol:
push ax
push dx
sub sp, 2
push 79
call randG
pop ax
mov dx, 2
mul dx
add ax, 320
mov di, ax
pop dx
pop ax
ret

printnum: 
 push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
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
 mov di, [bp-12]
nextpos: pop dx ; remove a digit from the stack
 mov dh, [attribute] ; use normal attribute
 mov [es:di], dx ; print char on screen
 add di, 2 ; move to next screen location
 loop nextpos ; repeat for all digits on stack
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop es
 pop bp
ret 2



	
printString:

 push bp
 mov bp, sp
 push es
 push ax
 push cx
 push si
 push di 

 push ds
 pop es ; load ds in es
 mov di, [bp-8] ; point di to string
 mov cx, 0xffff ; load maximum number in cx
 mov al, 0 ; load a zero in al
 repne scasb ; find zero in the string
 mov ax, 0xffff ; load maximum number in ax
 sub ax, cx ; find change in cx
 dec ax 
 mov cx, ax ; load string length in cx
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov si, [bp-8] ; point si to string
 mov ah, [attribute]; load attribute in ah
 mov di, [bp-10]
 cld ; auto increment mode
nextchar: 
 lodsb ; load next char in al
 stosw ; print char/attribute pair
 loop nextchar ;

 pop di
 pop si
 pop cx
 pop ax
 pop es
 pop bp
 ret

printStringWithLength:

 push bp
 mov bp, sp
 push es
 push ax
 push cx
 push si
 push di 

cmp cx, 0
je exitprt
 push ds
 pop es ; load ds in es
 mov di, [bp-8] ; point di to string
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov si, [bp-8] ; point si to string
 mov ah, [attribute]; load attribute in ah
 mov di, [bp-10]
 cld ; auto increment mode
nextchar1: 
 lodsb ; load next char in al
 stosw ; print char/attribute pair
 loop nextchar1 ;

exitprt:
 pop di
 pop si
 pop cx
 pop ax
 pop es
 pop bp
 ret


;-------------------------------------------------------------------------
; COLUMN 1 MOVER
;-------------------------------------------------------------------------


movCol1:
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di
push es


inc byte[tick]
cmp byte[tick],17
jne near exitMov1
mov byte[tick], 0

mov di, [testVal]
mov ax, 0x0720
mov [es:di], ax
add di, 160
mov ah, 0x07
mov al, [testAlph]
mov [es:di], ax
mov [testVal], di

cmp di, 3680
jnae near exitMov1

cmp di, [basketVal]
jne subLife1

mov ax, [Score+3]
inc ax

cmp ax, 0x3A
jne print1

mov ax, [Score+2]
inc ax
mov word[Score+2], ax
mov ax, 0x30

print1:

mov word[Score+3], ax
mov si, Score
mov di, 280
mov word[attribute], 0x02
call printString
mov word[attribute], 0x02

call genCol
mov [testVal], di

call genLet
mov [testAlph], dx

mov ax, 0x0255
mov di, [basketVal]
mov [es:di], ax




jmp exitMov1


subLife1:
mov ax, 0x0720
mov [es:di], ax
mov ax, [LivesL]
inc ax
mov word[LivesL], ax
mov di, 180
mov si, Lives
mov cx, ax
mov byte[attribute], 0x04
call printStringWithLength
mov byte[attribute], 0x7
call genCol
mov [testVal], di
call genLet
mov [testAlph], dx


exitMov1:
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret
;-------------------------------------------------------------------------
; COLUMN 2 MOVER
;-------------------------------------------------------------------------
movCol2:
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di
push es


inc byte[tick+1]
cmp byte[tick+1],20
jne near exitMov2
mov byte[tick+1], 0

mov di, [testVal+2]
mov ax, 0x0720
mov [es:di], ax
add di, 160
mov ah, 0x07
mov al, [testAlph+2]
mov [es:di], ax
mov [testVal+2], di

cmp di, 3680
jnae near exitMov2

cmp di, [basketVal]
jne subLife2

mov ax, [Score+3]
inc ax

cmp ax, 0x3A
jne print2

mov ax, [Score+2]
inc ax
mov word[Score+2], ax
mov ax, 0x30

print2:

mov word[Score+3], ax
mov si, Score
mov di, 280
mov word[attribute], 0x02
call printString
mov word[attribute], 0x02

call genCol
mov [testVal+2], di

call genLet
mov [testAlph+2], dx

mov ax, 0x0255
mov di, [basketVal]
mov [es:di], ax




jmp exitMov2


subLife2:
mov ax, 0x0720
mov [es:di], ax
mov ax, [LivesL]
inc ax
mov word[LivesL], ax
mov di, 180
mov si, Lives
mov cx, ax
mov byte[attribute], 0x04
call printStringWithLength
mov byte[attribute], 0x7
call genCol
mov [testVal+2], di
call genLet
mov [testAlph+2], dx


exitMov2:
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret


;-------------------------------------------------------------------------
; COLUMN 3 MOVER
;-------------------------------------------------------------------------
movCol3:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    inc byte[tick+2]
    cmp byte[tick+2], 16
    jne near exitMov3
    mov byte[tick+2], 0

    mov di, [testVal+4]
    mov ax, 0x0720
    mov [es:di], ax
    add di, 160
    mov ah, 0x07
    mov al, [testAlph+4]
    mov [es:di], ax
    mov [testVal+4], di

    cmp di, 3680
    jnae near exitMov3

    cmp di, [basketVal]
    jne subLife3

    mov ax, [Score+3]
    inc ax

    cmp ax, 0x3A
    jne print3

    mov ax, [Score+2]
    inc ax
    mov word[Score+2], ax
    mov ax, 0x30

print3:
    mov word[Score+3], ax
    mov si, Score
    mov di, 280
    mov word[attribute], 0x02
    call printString
    mov word[attribute], 0x02

    call genCol
    mov [testVal+4], di

    call genLet
    mov [testAlph+4], dx

    mov ax, 0x0255
    mov di, [basketVal]
    mov [es:di], ax

    jmp exitMov3

subLife3:
    mov ax, 0x0720
    mov [es:di], ax
    mov ax, [LivesL]
    inc ax
    mov word[LivesL], ax
    mov di, 180
    mov si, Lives
    mov cx, ax
    mov byte[attribute], 0x04
    call printStringWithLength
    mov byte[attribute], 0x7
    call genCol
    mov [testVal+4], di
    call genLet
    mov [testAlph+4], dx

exitMov3:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

;-------------------------------------------------------------------------
; COLUMN 4 MOVER
;-------------------------------------------------------------------------

movCol4:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    inc byte[tick+3]
    cmp byte[tick+3], 13
    jne near exitMov4
    mov byte[tick+3], 0

    mov di, [testVal+6]
    mov ax, 0x0720
    mov [es:di], ax
    add di, 160
    mov ah, 0x07
    mov al, [testAlph+6]
    mov [es:di], ax
    mov [testVal+6], di

    cmp di, 3680
    jnae near exitMov4

    cmp di, [basketVal]
    jne subLife4

    mov ax, [Score+3]
    inc ax

    cmp ax, 0x3A
    jne print4

    mov ax, [Score+2]
    inc ax
    mov word[Score+2], ax
    mov ax, 0x30

print4:
    mov word[Score+3], ax
    mov si, Score
    mov di, 280
    mov word[attribute], 0x02
    call printString
    mov word[attribute], 0x02

    call genCol
    mov [testVal+6], di

    call genLet
    mov [testAlph+6], dx

    mov ax, 0x0255
    mov di, [basketVal]
    mov [es:di], ax

    jmp exitMov4

subLife4:
    mov ax, 0x0720
    mov [es:di], ax
    mov ax, [LivesL]
    inc ax
    mov word[LivesL], ax
    mov di, 180
    mov si, Lives
    mov cx, ax
    mov byte[attribute], 0x04
    call printStringWithLength
    mov byte[attribute], 0x7
    call genCol
    mov [testVal+6], di
    call genLet
    mov [testAlph+6], dx

exitMov4:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
; movCol5
movCol5:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    inc byte[tick+4]
    cmp byte[tick+4], 11
    jne near exitMov5
    mov byte[tick+4], 0

    mov di, [testVal+8]
    mov ax, 0x0720
    mov [es:di], ax
    add di, 160
    mov ah, 0x07
    mov al, [testAlph+8]
    mov [es:di], ax
    mov [testVal+8], di

    cmp di, 3680
    jnae near exitMov5

    cmp di, [basketVal]
    jne subLife5

    mov ax, [Score+3]
    inc ax

    cmp ax, 0x3A
    jne print5

    mov ax, [Score+2]
    inc ax
    mov word[Score+2], ax
    mov ax, 0x30

print5:
    mov word[Score+3], ax
    mov si, Score
    mov di, 280
    mov word[attribute], 0x02
    call printString
    mov word[attribute], 0x02


    call genCol
    mov [testVal+8], di

    call genLet
    mov [testAlph+8], dx

    mov ax, 0x0255
    mov di, [basketVal]
    mov [es:di], ax

    jmp exitMov5

subLife5:
    mov ax, 0x0720
    mov [es:di], ax
    mov ax, [LivesL]
    inc ax
    mov word[LivesL], ax
    mov di, 180
    mov si, Lives
    mov cx, ax
    mov byte[attribute], 0x04
    call printStringWithLength
    mov byte[attribute], 0x7
    call genCol
    mov [testVal+8], di
    call genLet
    mov [testAlph+8], dx

exitMov5:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

; movCol6
movCol6:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    inc byte[tick+5]
    cmp byte[tick+5], 8
    jne near exitMov6
    mov byte[tick+5], 0

    mov di, [testVal+10]
    mov ax, 0x0720
    mov [es:di], ax
    add di, 160
    mov ah, 0x07
    mov al, [testAlph+10]
    mov [es:di], ax
    mov [testVal+10], di

    cmp di, 3680
    jnae near exitMov6


    cmp di, [basketVal]
    jne subLife6

    mov ax, [Score+3]
    inc ax

    cmp ax, 0x3A
    jne print6

    mov ax, [Score+2]
    inc ax
    mov word[Score+2], ax
    mov ax, 0x30

print6:
    mov word[Score+3], ax
    mov si, Score
    mov di, 280
    mov word[attribute], 0x02
    call printString
    mov word[attribute], 0x02


    call genCol
    mov [testVal+10], di

    call genLet
    mov [testAlph+10], dx

    mov ax, 0x0255
    mov di, [basketVal]
    mov [es:di], ax

    jmp exitMov6

subLife6:
    mov ax, 0x0720
    mov [es:di], ax
    mov ax, [LivesL]
    inc ax
    mov word[LivesL], ax
    mov di, 180
    mov si, Lives
    mov cx, ax
    mov byte[attribute], 0x04
    call printStringWithLength
    mov byte[attribute], 0x7
    call genCol
    mov [testVal+10], di
    call genLet
    mov [testAlph+10], dx

exitMov6:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

; movCol7
movCol7:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es


    inc byte[tick+5]
    cmp byte[tick+5], 5
    jne near exitMov6
    mov byte[tick+5], 0


    mov di, [testVal+12]
    mov ax, 0x0720
    mov [es:di], ax
    add di, 160
    mov ah, 0x07
    mov al, [testAlph+12]
    mov [es:di], ax
    mov [testVal+12], di

    cmp di, 3680
    jnae near exitMov7

    cmp di, [basketVal]
    jne subLife7

    mov ax, [Score+3]
    inc ax

    cmp ax, 0x3A
    jne print7

    mov ax, [Score+2]
    inc ax
    mov word[Score+2], ax
    mov ax, 0x30

print7:
    mov word[Score+3], ax
    mov si, Score
    mov di, 280
    mov word[attribute], 0x02
    call printString
    mov word[attribute], 0x02

    call genCol
    mov [testVal+12], di

    call genLet
    mov [testAlph+12], dx

    mov ax, 0x0255
    mov di, [basketVal]
    mov [es:di], ax

    jmp exitMov7

subLife7:
    mov ax, 0x0720
    mov [es:di], ax
    mov ax, [LivesL]
    inc ax
    mov word[LivesL], ax
    mov di, 180
    mov si, Lives
    mov cx, ax
    mov byte[attribute], 0x04
    call printStringWithLength
    mov byte[attribute], 0x7
    call genCol
    mov [testVal+12], di
    call genLet
    mov [testAlph+12], dx

exitMov7:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret


; movCol8
movCol8:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    inc byte[tick+7]
    cmp byte[tick+7], 19
    jne near exitMov8
    mov byte[tick+7], 0

    mov di, [testVal+14]
    mov ax, 0x0720
    mov [es:di], ax
    add di, 160
    mov ah, 0x07
    mov al, [testAlph+14]
    mov [es:di], ax
    mov [testVal+14], di

    cmp di, 3840
    jnae near exitMov8

    sub di, 160
    cmp di, [basketVal]
    jne subLife8

    mov ax, [Score+3]
    inc ax

    cmp ax, 0x3A
    jne print8

    mov ax, [Score+2]
    inc ax
    mov word[Score+2], ax
    mov ax, 0x30

print8:
    mov word[Score+3], ax
    mov si, Score
    mov di, 280
    mov word[attribute], 0x02
    call printString
    mov word[attribute], 0x02

    mov di, [testVal+14]
    mov ax, 0x4020
    mov [es:di], ax

    call genCol
    mov [testVal+14], di

    call genLet
    mov [testAlph+14], dx

    mov ax, 0x0255
    mov di, [basketVal]
    mov [es:di], ax

    jmp exitMov8

subLife8:
    add di, 160
    mov ax, 0x4020
    mov [es:di], ax
    mov ax, [LivesL]
    inc ax
    cmp ax, 10
    je near done
    mov word[LivesL], ax
    mov di, 180
    mov si, Lives
    mov cx, ax
    mov byte[attribute], 0x04
    call printStringWithLength
    mov byte[attribute], 0x7
    call genCol
    mov [testVal+14], di
    call genLet
    mov [testAlph+14], dx

exitMov8:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret


;-------------------------------------------------------------------------
; TIMER INTERRUPT
;-------------------------------------------------------------------------


newtimer:
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di
push es


cmp word[LivesL], 10
jnge hehe
call clrscr


mov di,2000
sub di, 42
mov si, GameString
mov ax, 0xb800
mov es, ax
call printString
jmp exitTimer

hehe:
call movCol1
call movCol2
call movCol3
call movCol4
call movCol5
call movCol8

nextCheck:
cmp word[Score+3], 53
jnae exitTimer
call movCol6




exitTimer:
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
jmp far [cs:oldisr]

eexit:
pop si
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
jmp far [cs:oldisr]

clrscr:
 push es
 push ax
 push cx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 xor di, di ; point di to top left column
 mov ax, 0x0720 ; space char in normal attribute
 mov cx, 2000 ; number of screen locations
 cld ; auto increment mode
 rep stosw ; clear the whole screen
 pop di 
 pop cx
 pop ax
 pop es
 ret 


basket:
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di
push es

mov ax, [LivesL]
cmp ax, 10
jge exit

mov di, [basketVal]
mov ax, 0xb800
mov es, ax
mov ax, 0
mov ah, 00h
in al, 0x60
cmp al, 75
je movLeft
cmp al, 77
je movRight
cmp al, 0x01
je near eexit
jmp exit

movLeft:
mov ax, 0x0720
mov [es:di], ax

mov ax, 0x0255
sub di, 2
cmp di, 3678
jnbe update

mov di, 3838
jmp update

movRight:
mov ax, 0x0720
mov [es:di], ax

mov ax, 0x0255
add di, 2
cmp di, 3840
jne update

mov di,3680

update:
mov [es:di], ax
mov [basketVal], di
exit:
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
jmp far [oldkbisr]
ret


;-------------------------------------------------------------------------
; MAIN GAME LOOP
;-------------------------------------------------------------------------

mainGameLoop:

mov ax, 0x0255
mov di, [basketVal]
mov [es:di], ax

mov si, Score
mov di, 280
mov word[attribute], 0x02
call printString
mov word[attribute], 0x02


mov di, 20
mov si, LivesString
call printString

mov di, 120
mov si, ScoreString
call printString

label:
;call basket
mov ax, [LivesL]
cmp ax, 10
jnae label
jae done

start:
call clrscr
mov di,2000
sub di, 28
mov si, StartString
mov ax, 0xb800
mov es, ax
call printString


startLabel:
mov ah, 01h
int 16h
jz startLabel

cli
mov ax, 0
mov es, ax
mov ax,[es:32]
mov word[oldisr], ax
mov ax,[es:34]
mov word[oldisr+2], ax
mov word[es:32], newtimer
mov word[es:34], cs
sti

cli
mov ax, 0
mov es, ax
mov ax,[es:36]
mov word[oldkbisr], ax
mov ax,[es:38]
mov word[oldkbisr+2], ax
mov word[es:36], basket
mov word[es:38], cs
sti


call clrscr
mov cx, 80
mov ax, 0xb800
mov es, ax
mov ax, 0x4020
mov di, 3840

cld
rep stosw

jmp mainGameLoop






done:



mov ax, 0
mov es, ax
cli
mov ax,[oldisr]
mov word[es:32], ax
mov ax,[oldisr+2]
mov word[es:34], ax
sti

cli
mov ax,[oldkbisr]
mov word[es:36], ax
mov ax,[oldkbisr+2]
mov word[es:38], ax
sti


mov ax, 4c00h
int 21h

