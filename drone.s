%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

maxNum EQU 65535

extern seed
global calculatePosition
section .data
tempAngle: dq 0
meaEsrim: dd 120
shishim: dd 60
maxShortNumShit: dd maxNum
tempDistance: dw 0

section	.rodata
format_2pfloat: db "%.2f",10,0

extern printf

section .text

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

debugLabel:
finit
;fild dword [shishim] ; st0 = 60 
fild dword [seed] ; st1 = randomized
fild dword [maxShortNumShit] ;st0 = 65535
fdiv ; st0 = randomized/65535 


fild dword [meaEsrim] ; st2 = 120
fmul ; st1 = st2 * st1 = (randomized/65535)*120
fild dword [shishim]
fsub ; st0 = st1 - st0 =  (randomized/65535)*120 - 60
fstp qword [tempAngle]

pushingAll
push dword [tempAngle+4]
push dword [tempAngle]
push dword format_2pfloat
call printf
add esp,12
popingAll




;pushingAll
;mov eax, tempAngle
;sub esp,8
;fld dword [eax]
;fstp qword [esp]
;push dword format_2pfloat
;call printf
;add esp, 12
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
mov eax, [seed]

mov edx, 0
mov dx, maxNum

mov ecx, 0
mov cx, 50
div dx
mul cx 

mov esp, ebp
pop ebp
ret


calculatePosition:

push ebp
mov ebp, esp

pushingAll
call generateAngle
popingAll
mov eax, [tempAngle]

;pushingAll
;call generateDistance
;mov [tempDistance], eax
;popingAll

pushingAll
push dword [tempAngle]
push dword format_2pfloat
call printf
add esp, 8
popingAll


;pushingAll
;push word [tempDistance]
;push dword format_2pfloat
;call printf
;add esp, 6
;popingAll


mov esp, ebp
pop ebp
ret

