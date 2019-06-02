%macro pushingAll 0
	pushad
	pushfd
%endmacro
%macro popingAll 0
	popfd
	popad
%endmacro

schedulSPOffset EQU 4

printerOffset EQU 8

global schedulerMain
extern resume
extern stpArr
extern CORS
extern K
extern CURR
extern N
section .data
i: dd 0
totalSteps: dd 0


section .text

schedulerMain: ; in order to switch you need to mov to ebx the pointer to the struct
	;push ebp
	;mov ebp,esp 
endlessMainLoop:
	mov eax,[i]
	mov esi,[CORS]
	mov ebx,[esi+4*eax] ; ebx holds the pointer to the i drone struct
	call resume ; call without PUSHINGALL/POPPINGALL
				;because we are in Scheduler STACK
	add eax,1
	mov esi,[totalSteps]
	add esi,1
	mov [totalSteps],esi
	mov [i],eax
	cmp esi,[K]
	jne checkReseting

	mov dword [totalSteps],0 ; arrive here only if EQUALs
	mov ebx,[stpArr+printerOffset]
	call resume

checkReseting:
	mov eax,[i]
	cmp eax,[N]
	je ResetingI
	jmp endlessMainLoop

ResetingI:
	mov eax,0
	mov [i],eax
	jmp endlessMainLoop


	mov esp,ebp
	pop ebp
	ret