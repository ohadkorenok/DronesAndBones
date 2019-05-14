%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

NULL equ 0x00
section	.rodata	
format_string: db "%d",0
format_string2: db "hi! the string is: %s",10,0
format_string3: db "12",0

section .bss
;mystack: resb 4*LEN ; each slot is 4 bytes, LEN slots equal to 4*LEN bytes
N: resd 1
T: resd 1
K: resd 1
BETA: resd 1
D: resd 1
seed: resd 1
curr_break: resd 1
init_break: resd 1
new_break:resd 1
sizeOfBytes: resd 1

toolsArr: resb 24

section .text
  align 16
  	 global main
     extern printf 
     extern fprintf 
     extern sscanf

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
	call free
	popingAll

	mov esp,ebp
	pop ebp
	ret


initialize:
	push ebp
	mov ebp,esp

	mov    eax, 45              ;system call brk
    mov    ebx, 0               ;invalid address
    int    0x80
    mov    [curr_break], eax
    mov    [init_break], eax

    mov edx, [N]
    mov eax, 28 ; StackPointer , FuncPointer, ID, X , Y, Angle, destroyed
    mul edx
    mov [sizeOfBytes], eax
    add eax, [curr_break] 
    mov ebx, eax  
 	mov eax, 45              ;system call brk
    int    0x80

    mov [curr_break], eax ; end of the allocated segment
    sub eax, [sizeOfBytes]
    mov [new_break], eax ; start of the allocated segment


	mov esp,ebp
	pop ebp
	ret

free:
	push ebp
	mov ebp,esp

    mov    eax, 45              ;brk
    mov    ebx, [init_break] ;get back to init address
    int    0x80
    mov    [new_break], eax

	mov esp,ebp
	pop ebp
	ret
