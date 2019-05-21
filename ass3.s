%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

NULL equ 0x00
STKSZ equ 16*1024
STRUCTSIZE equ 28
CODEP equ 0
SPP equ 4

section	.rodata	
format_string: db "%d",0
format_string2: db "hi! the string is: %s",10,0
format_string3: db "12",0
format_string4: db "functionPointer : %p stackPointer: %p ID: %d X:%d Y:%d Angle: %d Destroyed: %d",10,0

global seed

section .data ; TODO : PUT inside the first, the name of the function of each component
sche:dd NULL
	 dd schedulerSTACK
target:dd NULL
	   dd targetSTACK
printe:dd NULL
	   dd printerSTACK
stpArr:dd sche
	   dd target
	   dd printe
SPT :  dd NULL

seed: dd 0

section .bss
schedulerSTACK: resb STKSZ
targetSTACK: resb STKSZ
printerSTACK: resb STKSZ
N: resd 1
T: resd 1
K: resd 1
BETA: resd 1
D: resd 1
curr_break: resd 1
init_break: resd 1
new_break:resd 1
sizeOfBytes: resd 1
sizeOfBytesPointerArray: resd 1
sizeOfBytesStackArray: resd 1
CORS: resd 1
STACKARRAY : resd 1


section .text
  align 16
  	 global main
     extern printf 
     extern fprintf 
     extern sscanf
     extern calloc
	 extern free
	 extern calculatePosition

main: 
	push ebp
	mov ebp,esp

parseArgs:
	mov eax, [ebp+12] ;; Print template
	;pushingAll
	;push dword [eax+4]
	;push format_string2
	;call printf
	;add esp,8
	;popingAll

	pushingAll
	push N
	push format_string
	push dword [eax+4]
	call sscanf
	add esp,12
	popingAll

	pushingAll
	push T
	push format_string
	push dword [eax+8]
	call sscanf
	add esp,12
	popingAll

	pushingAll
	push K
	push format_string
	push dword [eax+12]
	call sscanf
	add esp,12
	popingAll

	pushingAll
	push BETA
	push format_string
	push dword [eax+16]
	call sscanf
	add esp,12
	popingAll

	pushingAll
	push D
	push format_string
	push dword [eax+20]
	call sscanf
	add esp,12
	popingAll

	pushingAll
	push seed
	push format_string
	push dword [eax+24]
	call sscanf
	add esp,12
	popingAll

	pushingAll
	call initialize
	popingAll

	pushingAll
	call calculatePosition
	popingAll

	mov eax, [seed]
	pushingAll
	
	push eax
	push format_string
	call printf
	add esp, 8
	popingAll

	mov esp,ebp
	pop ebp
	ret


initialize:
	push ebp
	mov ebp,esp

	pushingAll
	push dword STRUCTSIZE
	push dword [N]
	call calloc
	mov [new_break], eax
	add esp, 8
	popingAll

	pushingAll
	push dword 4
	push dword [N]
	call calloc
	mov [CORS], eax
	add esp, 8
	popingAll

	pushingAll
	push dword STKSZ
	push dword [N]
	call calloc
	mov [STACKARRAY], eax
	add esp, 8
	popingAll

	;mov ecx,[N]
	;mov ebx,0
	;reducingAddressByStackSize:
		;mov eax,[STACKARRAY+STKSZ*ebx]

		;inc ebx
		;loop reducingAddressByStackSize,ecx

	mov ebx, 0
    mov ecx, [N]
    myLoop1:
    	mov eax, ebx
    	mov esi, STRUCTSIZE
    	mul esi
    	add eax, [new_break] ; inside eax we got the struct address + offset to the desired
    	mov [CORS+4*ebx], eax ; in eax there is the starting address of the struct
    	mov [eax+8], ebx
    	inc ebx
    	loop myLoop1, ecx


    mov ebx,0
    mov ecx,[N]
    myLoop2:
    	;; push into the struct member the stack pointer
    	mov eax, ebx
    	mov esi, STKSZ
    	mul esi
    	add eax,STKSZ
    	add eax, [STACKARRAY]
    	mov edx, [CORS+4*ebx]
    	mov [edx+4], eax
    	inc ebx
    	loop myLoop2, ecx

    mov ecx,[N]
    mov ebx, 0
    ZoopaLoopa1:
    pushingAll
    push dword [CORS+4*ebx]
    call printMyStruct
    add esp, 4
    popingAll
   	inc ebx
    loop ZoopaLoopa1, ecx

    mov edx,0
    mov ecx,[N]
    initialDronesLoop:
    pushingAll
    push edx
    call initCo
    add esp,4
    popingAll
    inc edx
    loop initialDronesLoop,ecx


    mov ecx,[N]
    mov ebx, 0
    ZoopaLoopa2:
    pushingAll
    push dword [CORS+4*ebx]
    call printMyStruct
    add esp, 4
    popingAll
   	inc ebx
    loop ZoopaLoopa2, ecx

	mov esp,ebp
	pop ebp
	ret




;PRINT IS ONLY POSSIBLE IF X Y ANGLE ARE 4 byte
;TODO -> change the struct in order to support X Y ANGLE to 10bytes
printMyStruct: ; address of startingStruct and prints all of it. 
	push ebp
	mov ebp,esp
	mov eax, [ebp+8]
	pushingAll
	push dword [eax+24]
	push dword [eax+20]
	push dword [eax+16]
	push dword [eax+12]
	push dword [eax+8]
	push dword [eax+4]
	push dword [eax]
	push format_string4
	call printf
	add esp, 32
	popingAll

	mov esp, ebp
	pop ebp
	ret


initCo:
	push ebp
	mov ebp,esp

	mov ebx, [ebp+8] ; get co-routine ID number
	mov ebx, [4*ebx + CORS] ; get pointer to COi struct
	mov eax, [ebx+CODEP] ; get initial EIP value – pointer to COi function
	mov [SPT], ESP ; save ESP value
	mov esp, [ebx+SPP] ; get initial ESP value – pointer to COi stack
	push eax ; push initial “return” address the co-routine function
	pushfd ; push flags
	pushad ; push all other registers
	mov [ebx+SPP], esp ; save new SPi value (after all the pushes)
	mov ESP, [SPT] ; restore ESP value

	mov esp,ebp
	pop ebp
	ret