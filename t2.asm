global _start

section .bss
inputBuffer: resw 256

section .data

msg0: db "ESCOLHA UMA OPÇÃO:", 10,"-1: SOMA", 10,"-2: SUBTRAÇÃO", 10,"-3: MULTIPLICAÇÃO", 10,"-4: DIVISÃO", 10,"-5: MOD", 10,"-6: SAIR", 10,0
MSG0SIZE equ $-msg0
msg1: db "Digide dois operandos:",10,0
MSG1SIZE equ $-msg1
msg2: db "Nome do usuário: ",0
MSG2SIZE equ $-msg2
msg3: db "Olá, ",0
MSG3SIZE equ $-msg3
msg4: db ", bem-vindo ao programa de CALC IA-32",10,0
MSG4SIZE equ $-msg4
msg5: db "digite primeiro argumento: ",0
msg6: db "digite segundo argumento:  ",0
msg7: db "resultado: ",0
newLine: db 10

;%macro print 2 ; arg1 = msg, arg2 = tamanho
;mov eax, 4
;mov ebx, 1
;mov ecx, %1
;mov edx, %2
;int 80h
;%endmacro

section .text


print:
enter 0,0 ;push ebp; move ebp, esp
mov eax, 4
mov ebx, 1
mov ecx, [ebp+12]	;endereco
mov edx, [ebp+8]	;tamanho
int 80h
leave
ret 

strlen:
push ebp
mov ebp,esp
mov eax,[ebp+8]	;argumento = endereco da string
sub ecx,ecx
strlenLoop:
;cmp byte [eax],10
;jz fimStrlen
cmp byte [eax],0
jz fimStrlen
inc ecx
inc eax
jmp strlenLoop
fimStrlen:
mov eax,ecx	;valor de retorno
mov esp,ebp
pop ebp
ret

printStr:
push ebp
mov ebp,esp
;calcula tamanho da string
push dword[ebp+8]
call strlen
add esp,4
;chama funcao pra printar
push dword[ebp+8]
push eax	;qtdd de bytes a printar
call print
add esp,4
mov esp,ebp
pop ebp
ret

nl:	;nova linha
push ebp
mov ebp,esp
push newLine
push dword 1
call print
;add esp,8
mov esp,ebp
pop ebp
ret

multEaxPor10:
push ebx
mov ebx,eax
shl eax,3
add eax,ebx
add eax,ebx
pop ebx
ret


;converte string para int
str2uint:
push ebp
mov ebp,esp
sub eax,eax			;zera eax
sub ecx,ecx			;zera ecx
mov ecx, [esp+8]	;carrega endereco do primeiro digito em ascii
cmp dword [ecx],0			;se primeiro digito for \0 ja sai
je endStr2uint		
str2uintLoop:
sub edx,edx			;zera edx
mov dl, [ecx]		;carrega digito em edx
sub edx, 0x30		;converte para digito numerico
add eax,edx			;adiciona ao acumulador
cmp byte [ecx+1], 0	;verifica se eh o digito menos significativo
je endStr2uint
; se nao for o digito menos significativo multiplica acumulador por 10, incrementa o cursor e salta para o loop
push eax			;empilha valor original
shl eax, 3			;multiplica por oito
add eax,[esp]			;soma com valor original
add eax,[esp]		;multiplicou por dez
add esp,4			;desempilha eax
inc ecx				;incrementa cursor da string
jmp str2uintLoop
endStr2uint:
mov esp,ebp
pop ebp
ret

str2int:
push ebp
mov ebp,esp
;le primeiro caractere e ve se eh negativo
mov eax,[esp+8]
cmp byte [eax],'-'
je str2intEhNegativo
push dword [esp+8]	;se nao for negativo le normal
call str2uint
add esp,4
jmp fimStr2int
str2intEhNegativo:
;le o numero ignorando o sinal a principio
mov eax, [esp+8]
inc eax
push eax
call str2uint
add esp,4
;subtrai de zero, para negativar
mov ebx,0
sub ebx,eax	; ebx recebe numero negativasdo
mov eax,ebx ; passa para eax o retorno
fimStr2int:
mov esp,ebp
pop ebp
ret


read:
push ebp
mov ebp, esp
mov eax, 3
mov ebx, 0
mov ecx,[ebp+8]
mov edx, 1024
int 80h
;remove \n do final
mov eax,[ebp+8]	;argumento = endereco da string
readStrlenLoop:
cmp byte [eax],10
jz fimReadStrlen
inc eax
jmp readStrlenLoop
fimReadStrlen:
mov byte [eax],0
mov esp,ebp
pop ebp
ret

soma:
push ebp
mov ebp,esp
mov eax,[ebp+12]	;primeiro argumento
add eax,[ebp+8]		;soma segundo argumento
mov esp,ebp
pop ebp
ret

subtracao:
push ebp
mov ebp,esp
mov eax,[ebp+12]	;primeiro argumento
sub eax,[ebp+8]		;subtrai segundo argumento
mov esp,ebp
pop ebp
ret

multiplicacao:
push ebp
mov ebp,esp
sub edx,edx			;zera edx
mov eax,[ebp+12]	;primeiro argumento
mul dword [ebp+8]	;divide pelo segundo argumentos
mov esp,ebp
pop ebp
ret

divisao:
push ebp
mov ebp,esp
sub edx,edx			;zera edx
mov eax,[ebp+12]	;primeiro argumento
div dword [ebp+8]	;divide pelo segundo argumentos
mov esp,ebp
pop ebp
ret

resto:
push ebp
mov ebp,esp
sub edx,edx			;zera edx
mov eax,[ebp+12]	;primeiro argumento
idiv dword [ebp+8]	;divide pelo segundo argumentos
mov eax,edx			;retorna o resto
mov esp,ebp
pop ebp
ret

uint2str:
	push ebp
	mov ebp,esp
	mov eax,[ebp+8]	;valor a ser printado
uint2strLoop:		;divide por 10
	mov ebx, 10
	mov edx, 0
	div ebx
;salva resto
	add edx,0x30 ;converte para char
	push edx
;loop com o valor da divisao se nao for 0
	cmp eax,0
	ja uint2strLoop
uint2strInverte:		;inverte de antes do cursor ate ebp
	mov eax,[ebp+12]	;eax <- endereco da string final
uint2strInverteLoop:
	cmp esp,ebp	
	jae fimUint2str
;salva na posicao do cursor
	pop ebx
	mov [eax],bl
;incrementa cursores e repete 
	inc eax
	jmp uint2strInverteLoop
fimUint2str:
	mov byte [eax],0
	mov esp,ebp
	pop ebp
	ret


int2str:
	push ebp
	mov ebp,esp
;verifica se eh maior que zero
	mov eax,[ebp+8]
	cmp eax,0
	js int2strIsNeg
;se nao for negativo faz uint2str normalmente
	push dword [ebp+12]
	push dword [ebp+8]
	call uint2str
	add esp,8
	jmp endInt2str
int2strIsNeg: 		;insere '-' na frente
	mov eax,[ebp+12]
	mov byte [eax], '-'
	add eax,1
	push eax
	mov eax, [ebp+8]
	neg eax		;pega valor absoluto
	push eax
	call uint2str
	add esp,8
endInt2str:
	mov esp,ebp
	pop ebp
	ret

_start:
;imprime msg perguntando nome
	push msg2
	call printStr
	add esp,4
;le input do nome
	push inputBuffer
	call read
	add esp,4
	call nl
;imprime primeira parte da msg de boas vindas
	push msg3
	call printStr
	add esp,4
;imprime nome
	push inputBuffer
	call printStr
	add esp,4
;imprime resto da msg
	push msg4
	call printStr
	add esp,4
;imprime menu
menu:
	call nl
	push msg0
	call printStr
	add esp,4
	call nl
;le input do menu e empilha
	push inputBuffer
	call read
	add esp,4
	sub byte [inputBuffer],0x30 ;converte para numero
	sub eax,eax
	mov al,[inputBuffer]
;se for exit ja sai
	cmp al,6
	je end
	push eax	;empilha conteudo lido LEMBRAR DE DESEMPILHAR!
;le input e empilha (primeiro arg)
	push msg5
	call printStr
	add esp,4
	push inputBuffer
	call read
	add esp,4
;converte string para numero
	push inputBuffer
	call str2int
	add esp,4
	push eax ;emppilha primeiro argumento da operacao a ser feita
;le input e empilha (segundo arg)
	push msg6
	call printStr
	add esp,4
	push inputBuffer
	call read
	add esp,4
;converte string para numero
	push inputBuffer
	call str2int
	add esp,4
	push eax ;emppilha primeiro argumento da operacao a ser feita
;le primeir  umero empilhado la em cima e vai para menu correspondente
	cmp byte [esp+8],1	;ve se eh soma
	jne naoEhSoma	;os argumentos ja estao empilhados logo acima
	call soma
	jmp fimOp
naoEhSoma:
	cmp byte [esp+8],3 ;ve se eh mult
	jne naoEhMult
	call multiplicacao
	jmp fimOp
naoEhMult:
	cmp byte [esp+8],2 ;ve se eh subtracao
	jne naoEhSub
	call subtracao
	jmp fimOp
naoEhSub:
	cmp byte [esp+8],4 ;ve se eh div
	jne naoEhDiv
	call divisao
	jmp fimOp
naoEhDiv:
	cmp byte [esp+8],5 ;ve se eh mod
	jne naoEhMod
	call resto
	jmp fimOp
naoEhMod:
	jmp menu

fimOp:
	add esp,10	;8 para a funcao e dois para o numero do menu
; imprime resultado na tela
	push inputBuffer
	push eax
	call nl
	push msg7
	call printStr
	add esp,4
	call int2str
	add esp,8
	push inputBuffer
	call printStr
	add esp,4
	call nl
	jmp menu

end:


mov eax, 1
mov ebx, 0
int 80h

