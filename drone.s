%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

schedulerOffset EQU 0
targetStructOffset EQU 4
maxNum EQU 65535
IDoffset EQU 8
xOffset EQU 12
xOffsetPlusFOUR EQU 16
yOffset EQU 20
yOffsetPlusFOUR EQU 24
angleOffset EQU 28
angleOffsetPlusFOUR EQU 32
destroyedNumOffset EQU 36
TRUE EQU 1
FALSE equ 0


section .rodata
format_win: db "Drone id %d: I am a winner",10,0
format_distancefloat: db "Inside calculatePoistion :Distance generated: %.2f",10,0
format_anglefloat: db "Inside calculatePoistion :Angle generated: %.2f",10,0

extern freeAll
global droner
extern resume
extern stpArr
extern seed
extern mayDestroy
extern CORS
extern destroyTarget
extern T
extern CURR
global threeSixty
global calculatePosition
global generateNumber
global maxShortNumShit
global hundred
global hunderedEighty
global meaEsrim
global shishim
section .data
tempAngle: dq 0
meaEsrim: dd 120
shishim: dd 60
hamishim: dd 50
maxShortNumShit: dd maxNum
tempDistance: dq 0
droneID: dd 0
threeSixty: dd 360
zero: dd 0
xTag: dq 0
yTag: dq 0
hundred: dd 100
hunderedEighty: dd 180
ninty: dd 90
rtrnValue: dd -1


extern printf

section .text

droner:
	;push ebp
	;mov ebp,esp
	mov ebx,[CURR]
	mov eax,[ebx+IDoffset] ; TODO : (VERY IMPORTANT) you dont get the ID as a function, you need to get it from the struct
	                ; TODO: the CURR variable stores the struct to the current drone struct, 
	                ; Achieve the ID from that struct.
	mov [droneID],eax ; putting the ID of the current drone inside this variable

	pushingAll
	call calculatePosition
	popingAll

	pushingAll
	push eax
	call mayDestroy
	mov [rtrnValue],eax
	add esp,4
	popingAll

	mov eax,[rtrnValue]
	cmp eax,TRUE
	jne CannotDestroy
	CanDestroy:
		pushingAll
		call destroyTarget
		popingAll
		mov ebx,[droneID]
		mov esi,[CORS]
		mov eax,[esi+4*ebx]
		mov ebx,[eax+destroyedNumOffset]
		add ebx,1
		mov [eax+destroyedNumOffset],ebx
		cmp ebx, [T]
		jb resumeTarget
		pushingAll ; Announce winner and exit.
		push dword [droneID]
		push format_win
		call printf
		add esp,8
		popingAll
		pushingAll
		call freeAll
		popingAll
		mov eax,1
		mov ebx,0
		int 0x80

	resumeTarget:
		mov ebx,[stpArr+targetStructOffset]
		call resume
		jmp droner


	CannotDestroy:
		mov ebx,[stpArr+schedulerOffset]
		call resume
	debiLabel2:
		jmp droner

	mov esp,ebp
	pop ebp
	ret

generateNumber:
	push ebp
	mov ebp,esp
	mov eax,[seed]

	and eax, 1 ; for the 16th digit , result is 0 or 1
	shl eax , 2 ; getting ready for the 14th digit
	mov edx, [seed]
	and edx, 4 ; for the 14th digit

	xor eax, edx ; xor between the 14th digit and the 16th digit

	shl eax, 1 ; getting ready for the 13th digit
	mov edx, [seed]
	and edx, 8 ; for the 13th digit
	xor eax, edx ; xor between the xor of the 14th and the 16th digit and the 13th digit

	shl eax ,2
	mov edx, [seed]
	and edx, 32 ; for the 11th digit
	xor eax, edx ; xor between the 11th, 13th , 14th , 16th digit

	shl eax, 10 ; getting ready for the 1st digit 
	mov ebx, [seed]
	shr ebx ,1 ; open space for the msb we are going to insert
	or eax, ebx
	mov [seed], eax

	mov esp, ebp
	pop ebp
	ret


generateAngle:
	push ebp
	mov ebp,esp

	pushingAll
	call generateNumber
	popingAll

	finit
	fild dword [seed] ; st1 = randomized
	fild dword [maxShortNumShit] ;st0 = 65535
	fdiv ; st0 = randomized/65535 


	fild dword [meaEsrim] ; st2 = 120
	fmul ; st1 = st2 * st1 = (randomized/65535)*120
	fild dword [shishim]
	fsub ; st0 = st1 - st0 =  (randomized/65535)*120 - 60
	fstp qword [tempAngle]

	;pushingAll
	;push dword [tempAngle+4]
	;push dword [tempAngle]
	;push dword format_anglefloat
	;call printf
	;add esp,12
	;popingAll



	mov esp, ebp
	pop ebp
	ret

generateDistance:

	push ebp
	mov ebp,esp

	pushingAll
	call generateNumber
	popingAll

	fild dword [seed] ; st1 = randomized
	fild dword [maxShortNumShit] ;st0 = 65535
	fdiv ; st0 = randomized/65535 
	fild dword [hamishim]
	fmul
	fstp qword [tempDistance]

	;pushingAll
	;push dword [tempDistance+4]
	;push dword [tempDistance]
	;push dword format_distancefloat
	;call printf
	;add esp,12
	;popingAll


	mov esp, ebp
	pop ebp
	ret


calculatePosition:

	push ebp
	mov ebp, esp

	pushingAll
	call generateAngle
	popingAll

	pushingAll
	call generateDistance
	popingAll

	;Right now we have the deltaAlpha in tempAngle 
	; and also deltaDistance in tempDistance
	;Updating alpha+deltaAlpha in the struct
	mov ebx,[droneID]
	mov esi,[CORS]
	mov eax,[esi+4*ebx]
	fld qword [tempAngle]
	fld qword [eax+angleOffset]
	fadd ; adding alpha+deltaAlpha
	fild dword [zero]
	fcomip
	ja AlphaUnderZero ; compare 0 to a+deltaAlpha
	fild dword [threeSixty]
	fcomip ; compare 360 to a+deltaAlpha
	ja AlphaBetweenRange
	jmp AlphaAboveThreeSixty

	AlphaUnderZero:
		fild dword [threeSixty]
		fadd
		fstp qword [tempAngle]
		jmp continueInserting

	AlphaBetweenRange:
		fstp qword [tempAngle]
		jmp continueInserting

	AlphaAboveThreeSixty:
		fild dword [threeSixty]
		fsub ; st0=st1-st0 -> (alpha+deltaAlpha)-360
		fstp qword [tempAngle]
	continueInserting:
		mov ebx,[tempAngle+4]
		mov edx,[tempAngle]
		mov [eax+angleOffsetPlusFOUR],ebx
		mov [eax+angleOffset],edx


	;calculating new X
	fld qword [tempAngle] ; exchanging to radians
	fldpi
	fmul
	fild dword [hunderedEighty]
	fdiv
	fcos
	fld qword [tempDistance]
	fmul
	fld qword [eax+xOffset]
	fadd
	fild dword [zero]
	fcomip 
	ja XUnderZero;
	fild dword [hundred]
	fcomip
	ja XBetweenRange
	jmp XAboveHundred

	XUnderZero:
		fild dword [hundred]
		fadd
		jmp continueXInserting

	XBetweenRange:
		jmp continueXInserting

	XAboveHundred:
		fild dword [hundred]
		fsub

	continueXInserting:
		fstp qword [xTag]
		mov ebx,[xTag+4]
		mov edx,[xTag]
		mov [eax+xOffsetPlusFOUR],ebx
		mov [eax+xOffset],edx


	;calculating new Y
	fld qword [tempAngle]; exchanging to radians
	fldpi
	fmul
	fild dword [hunderedEighty]
	fdiv
	fsin
	fld qword [tempDistance]
	fmul
	fld qword [eax+yOffset]
	fadd
	fild dword [zero]
	fcomip 
	ja YUnderZero;
	fild dword [hundred]
	fcomip
	ja YBetweenRange
	jmp YAboveHundred

	YUnderZero:
		fild dword [hundred]
		fadd
		jmp continueYInserting

	YBetweenRange:
		jmp continueYInserting

	YAboveHundred:
		fild dword [hundred]
		fsub
	continueYInserting:
		fstp qword [yTag]
		mov ebx,[yTag+4]
		mov edx,[yTag]
		mov [eax+yOffsetPlusFOUR],ebx
		mov [eax+yOffset],edx

	;TODO :// Add support in cos(90)=0, after exchanging to radians it becomes very little number (cos(1.5707) in radians)

	;pushingAll
	;push word [tempDistance]
	;push dword format_2pfloat
	;call printf
	;add esp, 6
	;popingAll


	mov esp, ebp
	pop ebp
	ret





