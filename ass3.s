%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

NULL equ 0x00
schedulerOffset EQU 0
STKSZ equ 16*1024
STRUCTSIZE equ 40
CODEP equ 0
SPP equ 4
xOffset EQU 12
xOffsetPlusFOUR EQU 16
yOffset EQU 20
yOffsetPlusFOUR EQU 24
angleOffset EQU 28
angleOffsetPlusFOUR EQU 32

section	.rodata	
format_string: db "%d",0
format_string2: db "hi! the string is: %s",10,0
format_string3: db "12",0
format_string4: db "functionPointer : %p stackPointer: %p ID: %d X:%.2f Y:%.2f Angle: %.2f Destroyed: %d",10,0

extern threeSixty
extern generateNumber
extern maxShortNumShit
extern hundred
extern meaEsrim
extern shishim
extern generateMyXY
extern droner
extern schedulerMain
extern targetRoutine
extern printBoard
global freeAll
global resume
global N
global CURR
global K
global stpArr
global seed
global CORS
global BETA
global D
global T
global CURR
section .data ; TODO : PUT inside the first, the name of the function of each component
sche:dd schedulerMain
	 dd schedulerSTACK+STKSZ
target:dd targetRoutine
	   dd targetSTACK+STKSZ
printe:dd printBoard
	   dd printerSTACK+STKSZ
stpArr:dd sche
	   dd target
	   dd printe
SPT :  dd NULL
CURR: dd NULL
seed: dd 0
tempX: dq 0
tempY: dq 0
tempAng: dq 0

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
SPMAIN: resd 1


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


    call startCo

    call endCo

    pushingAll
    call printBoard
    popingAll

	mov esp,ebp
	pop ebp
	ret

startCo:
		pushad ; save registers of main ()
		mov [SPMAIN], esp ; save ESP of main ()
		mov ebx, [schedulerOffset + stpArr] ; gets a pointer to a scheduler struct
		jmp do_resume ; resume a scheduler co-routine

endCo:
	mov esp, [SPMAIN] ; restore ESP of main()
	popad ; restore registers of main()

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
	mov [CORS], eax ; [CORS] -> holds pointer to the array of structs.
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
    mov esi,[CORS]
    myLoop1:
    	mov eax, ebx
    	mov edx, STRUCTSIZE
    	mul edx
    	add eax, [new_break] ; inside eax we got the struct address + offset to the desired
    	mov [esi+4*ebx], eax ; in eax there is the starting address of the struct
    	mov [eax+8], ebx ; ID
    	inc ebx
    	loop myLoop1, ecx
debugCORS2:

	pushingAll ;Generating initial x,y for the target
	call generateMyXY
	popingAll


    mov ebx,0
    mov ecx,[N]
    myLoop2:
    	;; push into the struct member the stack pointer
    	mov eax, ebx
    	mov esi, STKSZ
    	mul esi
    	add eax,STKSZ
    	add eax, [STACKARRAY]
    	mov esi,[CORS]
    	pushingAll
    	call generateXYAngle
    	popingAll
    	mov edx, [esi+4*ebx]
    	mov [edx+SPP], eax ; Putting stackpointers

    	mov esi,[tempX+4] ; Generating X
    	mov [edx+xOffsetPlusFOUR],esi
    	mov esi,[tempX]
    	mov [edx+xOffset],esi

    	mov esi,[tempY+4] ; Generating Y
    	mov [edx+yOffsetPlusFOUR],esi
    	mov esi,[tempY]
    	mov [edx+yOffset],esi

    	mov esi,[tempAng+4] ; Generating Angle
    	mov [edx+angleOffsetPlusFOUR],esi
    	mov esi,[tempAng]
    	mov [edx+angleOffset],esi

    	inc ebx
    	loop myLoop2, ecx

    mov ecx,[N]
    mov ebx, 0
    ZoopaLoopa1:
    pushingAll
    mov esi,[CORS]
    push dword [esi+4*ebx]
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

    mov edx,0
    mov ecx,3
    initialstpArrLoop:
    pushingAll
    push edx
    call initCoForSTP
    add esp,4
    popingAll
    inc edx
    loop initialstpArrLoop,ecx


    mov ecx,[N]
    mov ebx, 0
    ZoopaLoopa2:
    pushingAll
    mov esi,[CORS]
    push dword [esi+4*ebx]
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
	push dword [eax+36]; 4 bytes of Destroyed
	push dword [eax+32]; 4 LSB bytes of angle
	push dword [eax+28]; 4 MSB bytes of angle
	push dword [eax+24]; 4 LSB bytes of Y
	push dword [eax+20]; 4 MSB bytes of Y
	push dword [eax+16]; 4 LSB bytes of X
	push dword [eax+12]; 4 MSB bytes of X
	push dword [eax+8]; 4 bytes of ID
	push dword [eax+4]; 4 bytes of stackPointer
	push dword [eax]; 4 bytes of functionPointer
	push format_string4
	call printf
	add esp, 44
	popingAll

	mov esp, ebp
	pop ebp
	ret


initCo:
	push ebp
	mov ebp,esp

	mov ebx, [ebp+8] ; get co-routine ID number
	mov esi,[CORS]
	mov ebx, [4*ebx + esi] ; get pointer to COi struct
	mov edx,droner
	mov [ebx],edx
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

initCoForSTP:
	push ebp
	mov ebp,esp
	mov ebx, [ebp+8] ; get co-routine ID number
	mov ebx, [4*ebx + stpArr] ; get pointer to COi struct
	mov eax, [ebx+CODEP] ; get initial EIP value – pointer to COi function
	mov [SPT], esp ; save ESP value
	mov esp, [ebx+SPP] ; get initial ESP value – pointer to COi stack
	push eax ; push initial “return” address the co-routine function
	pushfd ; push flags
	pushad ; push all other registers
	mov [ebx+SPP], esp ; save new SPi value (after all the pushes)
	mov esp, [SPT] ; restore ESP value

	mov esp,ebp
	pop ebp
	ret




resume: ; save state of current co-routine
	pushfd
	pushad
	mov edx, [CURR] ; CURR suppose to have the address of the start of the struct
	mov [edx+SPP], esp ; save current ESP
do_resume: ; load ESP for resumed co-routine
	mov esp,[ebx+SPP]
	mov [CURR], ebx
	popad ; restore resumed co-routine state
	popfd
ret ; "return" to resumed co-routine

generateXYAngle:
	push ebp
	mov ebp,esp
	pushingAll
	call generateNumber
	popingAll

	fild dword [seed] ; st1 = randomized
	fild dword [maxShortNumShit] ;st0 = 65535
	fdiv ; st0 = randomized/65535 
	fild dword [hundred]
	fmul
	fstp qword [tempX]

	pushingAll
	call generateNumber
	popingAll
	fild dword [seed] ; st1 = randomized
	fild dword [maxShortNumShit] ;st0 = 65535
	fdiv ; st0 = randomized/65535 
	fild dword [hundred]
	fmul
	fstp qword [tempY]

	pushingAll
	call generateNumber
	popingAll

	finit
	fild dword [seed] ; st1 = randomized
	fild dword [maxShortNumShit] ;st0 = 65535
	fdiv ; st0 = randomized/65535 


	fild dword [threeSixty] ; st2 = 120
	fmul ; st1 = st2 * st1 = (randomized/65535)*120
	fstp qword [tempAng]

	mov esp,ebp
	pop ebp
	ret

	freeAll:
		push ebp
		mov ebp,esp

		pushingAll
		push dword [new_break]
		call free
		add esp,4
		popingAll

		pushingAll
		push dword [CORS]
		call free
		add esp,4
		popingAll

		pushingAll
		push dword [STACKARRAY]
		call free
		add esp,4
		popingAll

		mov esp,ebp
		pop ebp
		ret