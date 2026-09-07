section .data
    enter_msg db "Enter a number (1-99): "
    enter_msg_len equ $ - enter_msg

    invalid_msg db "Invalid number! (1 <= number <= 99)", 10
    invalid_msg_len equ $ - invalid_msg

    gugudan_msg db "   *  =    ", 10
    gugudan_msg_len equ $ - gugudan_msg

section .bss
    buf resb 10

section .text
    global _start

_start:
    mov rdi, enter_msg
    mov rsi, enter_msg_len
    call print

    call input
    mov rbx, rax    ; rbx = input_len

    mov rdi, buf
    mov rsi, rbx
    call is_number
    cmp rax, 0
    je invalid

    push rbp
    mov rbp, rsp
    mov rdi, buf
    mov rsi, rbx
    call atoi
    mov rsp, rbp
    pop rbp

    cmp rax, 0
    je _exit

    mov rax, rbx

    cmp rax, 1
    jl invalid
    cmp rax, 99
    jg invalid

    xor rcx, rcx
    mov rdi, rax
    call print_gugudan

    jmp _exit

print:  ; rdi = msg / rsi = msg_len
    mov rax, 0x1        ; syscall 'write'
    mov rdx, rsi   
    mov rsi, rdi        
    mov rdi, 0x1        ; stdout
    syscall
    ret

print_gugudan:
    cmp rcx, gugudan_msg_len
    jge end_true
    
    

invalid:
    mov rdi, invalid_msg
    mov rsi, invalid_msg_len
    call print

    jmp _exit

input:
    mov rax, 0x0    ; syscall 'read'
    mov rdi, 0x0    ; stdin
    mov rsi, buf    
    mov rdx, 0xa    ; 10 bytes
    syscall
    
    ; '\n' -> 'NULL'
    sub rax, 1
    mov byte [buf + rax], 0     ; EOF 들어오면 버그 날 것임. 
    ret

is_number:
    xor rax, rax
    xor rcx, rcx
    call for_check_number
    ret

for_check_number:
    cmp rcx, rsi
    jge end_true

    mov al, [buf+rcx]
    cmp al, 0x00   ; NULL
    je end_true
    cmp al, '0'
    jl end_false
    cmp al, '9'
    jg end_false

    inc rcx
    jmp for_check_number

; 문자열 -> 숫자(수정 필요)
atoi:
    xor rbx, rbx    ; 최종 숫자
    xor rax, rax    
    xor rcx, rcx
    
    call for_atoi    

    ret

for_atoi:
    cmp rcx, rsi
    jge end_true

    mov al, [buf+rcx]
    cmp al, 0x0
    je end_true

    mul rbx, 10
    
    sub al, '0'
    add rbx, rax

    inc rcx
    jmp for_atoi

end_true:
    mov rax, 1
    ret

end_false:
    mov rax, 0
    ret

_exit:
    mov rax, 0x3c
    mov rdi, 0x0
    syscall