%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

schedulerOffset EQU 0

global printBoard
extern N
extern CORS
extern targetX
extern targetY
extern printf
extern stpArr
extern resume

section .rodata
format_target: db "%.2f,%.2f",10,0
format_dronePrint: db "%d,%.2f,%.2f,%.2f,%d",10,0 ; ID,X,Y,Angle,Destroyed
format_enter: db 10,0



section .text

printBoard:
	;push ebp
	;mov ebp,esp
	pushingAll
	push dword [targetY+4]
	push dword [targetY]
	push dword [targetX+4]
	push dword [targetX]
	push format_target
	call printf
	add esp,20
	popingAll

	mov ecx,[N]
    mov ebx, 0
  dronePrintLoop:
    pushingAll
    mov esi,[CORS]
    push dword [esi+4*ebx]
    call printDrone
    add esp, 4
    popingAll
   	inc ebx
    loop dronePrintLoop, ecx

    pushingAll
    push format_enter
    call printf
    add esp,4
    popingAll
    
    mov ebx,[stpArr+schedulerOffset]
    call resume
    jmp printBoard

	mov esp,ebp
	pop ebp
	ret


printDrone:
	push ebp
	mov ebp,esp
	mov eax,[ebp+8]
	pushingAll
	push dword [eax+36]; 4 bytes of Destroyed
	push dword [eax+32]; 4 LSB bytes of angle
	push dword [eax+28]; 4 MSB bytes of angle
	push dword [eax+24]; 4 LSB bytes of Y
	push dword [eax+20]; 4 MSB bytes of Y
	push dword [eax+16]; 4 LSB bytes of X
	push dword [eax+12]; 4 MSB bytes of X
	push dword [eax+8]; 4 bytes of ID
	push format_dronePrint
	call printf
	add esp,36
	popingAll
	mov esp,ebp
	pop ebp
	ret

