;kvm -drive file=boot.bin,index=0,if=floppy,format=raw -soundhw pcspk
org 7C00h

Start:
xor cx,cx
mov ds,cx

push 0x0b000
pop es

random_screen:
in al,0x40
and al,1
add al,0x30
stosb
loop random_screen
call music
call timertest
xor cx,cx
test al,15
jne random_screen

mov bh,1Fh
call clear_scr
inc cx

;Windows Bluescreen
bluescreen_loop:
mov bx,00F1h
mov dx,0620h
mov si,Error
call write_string

mov dx,0905h
mov bl,1Fh
call write_string

mov dx,101Ah
call write_string
halt:
;some music
call music

in al,60h
test al,0x80
jne halt

;Amiga Meditation
meditation:
xor bx,bx
call clear_scr
mov dx,[borderflag]
dec dx
je no_border
mov bl,040h
no_border:

mov cl,80
xor dx,dx
call plot_line
mov dh,06h
call plot_line

border:
xor dl,dl
mov cl,1
call plot_line
mov dl,79
call plot_line
dec dh
jne border

inc cx
mov dx,0205h
mov bl,04h
mov si,GuruMedidation
call write_string
mov dx,021Ah
call write_string
mov dx,040Fh
call write_string
;some music
call music
call timertest
test al,15
jnz meditation

push 0x0a000
pop es
mov ax, 0013h
int 10h
 
mainloop:
mov ax,0xCCCD
mul di
mov al,31
cmp dh,100
jb lower
cmp dh,115
ja lower

;Draw bomb
mov bx,TOSBomb
sub dh,100
and dl,15
shl dh,1
add bl,dh
mov cl,dl
mov dx,word [bx]
shl dx,cl
jnc lower
mov al,0h
lower:

putpixel:

stosb
;some music
call music
jmp mainloop

write_string:
lodsb
mov ah,2
int 10h
mov ah,09h
int 10h
inc dx
cmp al,0
jne write_string
ret

plot_line:
mov ax,0220h
int 10h
mov ah,09h
int 10h
ret

clear_scr:
mov ax,0600h
xor cx,cx
mov dx,0184Fh
int 10h
ret

music:
or al,0x4B
out 0x42,al
out 0x61,al
ret

timertest:
halt2:
mov bl,byte[borderflag]
xor ax,ax
int 1Ah
and dl,8
shr dl,3
cmp bl,dl
jne halt2

xor bl,1
mov [borderflag],bl

inc byte [timer]
mov al,byte [timer]
ret

timer: db 0

Error: db "BlueScreenOS",0
Error_Message: db "A fatal exception DEADB00701 has occured at DEAD:CAFE01 in BOOTDEMO.",0
AnyKey: db "Press any key to continue",0

GuruMedidation: db "Software failure.",0
GuruMedidation_Mouse: db "Press left mouse button to continue.",0
GuruMedidation_Code: db "Guru Meditation #DEADCAFE.DEADBEEF",0

borderflag: db 0

TOSBomb:
dw 0000110000000000b
dw 0101001000000000b
dw 0000000100000000b
dw 1001000010000000b
dw 0010001111100000b
dw 0000001111100000b
dw 0000111111111000b
dw 0001111111111100b
dw 0001111111111100b
dw 0011111111111110b
dw 0011111111011110b
dw 0001111111011100b
dw 0001111110111100b
dw 0000111111111000b
dw 0000011111110000b
dw 0000000111000000b
times 0200h - 2 - ($ - $$)  db 0
 
dw 0AA55h
