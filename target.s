%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

schedulerOffset EQU 0
xOffset EQU 12
xOffsetPlusFOUR EQU 16
yOffset EQU 20
yOffsetPlusFOUR EQU 24
angleOffset EQU 28
angleOffsetPlusFOUR EQU 32


section .rodata
format_destroyed: db "Target Destroyed",10,0
format_floatX: db "Inside mayDestroy: TargetCurrentX: %.2f",10,0
format_floatY: db "Inside mayDestroy: TargetCurrentY: %.2f",10,0

global generateMyXY
global mayDestroy
global destroyTarget
global targetRoutine
global targetX
global targetY
extern CORS
extern seed
extern generateNumber
extern maxShortNumShit
extern hundred
extern D
extern BETA
extern threeSixty
extern printf
extern hunderedEighty
extern stpArr
extern resume

section .data
targetX: dq 0
targetY: dq 0
diffY: dq 0
diffX: dq 0
gamma: dq 0
tempSub: dq 0

section .text


targetRoutine:
	;push ebp
	;mov ebp,esp
	pushingAll
	call createTarget
	popingAll

	mov ebx,[stpArr+schedulerOffset]
	call resume
	jmp targetRoutine

	mov esp,ebp
	pop ebp
	ret

createTarget:
	push ebp
	mov ebp,esp
	pushingAll
	call generateMyXY
	popingAll
	mov esp,ebp
	pop ebp
	ret

mayDestroy:
	push ebp
	mov ebp,esp
	mov ebx,[ebp+8]

	;pushingAll ;; Print generated X,Y
	;push dword [targetX+4]
	;push dword [targetX]
	;push format_floatX
	;call printf
	;add esp,12
	;popingAll
	;pushingAll
	;push dword [targetY+4]
	;push dword [targetY]
	;push format_floatY
	;call printf
	;add esp,12
	;popingAll


	mov esi,[CORS]
	mov eax,[esi+4*ebx]
	finit
	fld qword [targetY] ; y2
	fld qword [eax+yOffset] ; y1
	fsub
	fstp qword [diffY]
	fld qword [targetX]; x2
	fld qword [eax+xOffset]; x1
	fsub
	fstp qword [diffX]
	fld qword [diffY] ; st0=deltaX,st1=deltaY
	fld qword [diffX]
	fpatan ; st(1)/st(0) -> st(0)
	fild dword [hunderedEighty]
	fmul
	fldpi
	fdiv
	fstp qword [gamma]; -pi/2<arctan(x)<pi/2
	fld qword [eax+angleOffset]; alpha
	fld qword [gamma]
	debLabel1:
	fsub ; alpha (st1) - gamma (st0)-> st0
	fabs
	fild dword [threeSixty]
	fcomip
	jb SubstractionAboveThreeSixty ; if 360 < (abs(alpha-gamma)) -> bad.
	jmp conMayDestroy1


	SubstractionAboveThreeSixty: ;; assuming gamma is lesser
		fld qword [gamma]
		fild dword [threeSixty]
		fadd ; adding 360 to gamma
		fld qword [eax+angleOffset]
		fsub ; alpa (st0) - gamma (st1)
		fabs
		
	conMayDestroy1: ; assumes we got in st0 the substraction
		fild dword [BETA]
		fcomip 
		ja FlagUP ; if (abs(alpha-gamma) < beta) -> flagUp
		jmp OneOftheconditionsIsFalse

	FlagUP:
		fld qword [diffY]
		fld qword [diffY]
		fmul
		fld qword [diffX]
		fld qword [diffX]
		fmul
		fadd
		fsqrt
		fild dword [D]
		fcomip
		ja BothConditionsAreGood ; if D > all the shit calculated up
		jmp endPointmayDestroy

	OneOftheconditionsIsFalse:
		mov eax,0
		jmp endPointmayDestroy

	BothConditionsAreGood:
		mov eax,1
	endPointmayDestroy:

mov esp,ebp
pop ebp
ret


generateMyXY:

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
	fstp qword [targetX]

	pushingAll
	call generateNumber
	popingAll
	fild dword [seed] ; st1 = randomized
	fild dword [maxShortNumShit] ;st0 = 65535
	fdiv ; st0 = randomized/65535 
	fild dword [hundred]
	fmul
	fstp qword [targetY]

	mov esp,ebp
	pop ebp
	ret

destroyTarget:
	push ebp
	mov ebp,esp
	mov dword [targetX+4],0
	mov dword [targetX],0
	mov dword [targetY+4],0
	mov dword [targetY],0
	mov esp,ebp
	pop ebp
	ret
