org 100h

start:
    jmp main

; Data Section
; Prompt messages
welcome_msg      db 13,10,'==================================================='
                db 13,10,'|           SISTEM PENJUALAN CAT BANGUNAN          |'
                db 13,10,'===================================================','$'
nama_prompt      db 13,10,'Nama Anda     : $'
hp_prompt        db 13,10,'No. HP/Telp   : $'
alamat_prompt    db 13,10,'Alamat        : $'
qty_prompt       db 13,10,'Jumlah Pembelian: $'
payment_prompt   db 13,10,'Pilih Metode Pembayaran:'
                db 13,10,'1. Cash'
                db 13,10,'2. Credit Card'
                db 13,10,'3. Debit'
                db 13,10,'Pilihan (1-3): $'

; Buffers for input
tampung_nama     db 31,?,31 dup(?)
tampung_hp       db 14,?,14 dup(?)
tampung_alamat   db 31,?,31 dup(?)
cart_items       db 10 dup(0)      
cart_qty         db 10 dup(0)      
cart_count       db 0              
quantity         db 0
total_price      dw 0
payment_method   db 0

; Menu and formatting
menu_header      db 13,10,'+====================================================+'
                db 13,10,'|                 KATALOG PRODUK CAT                  |'
                db 13,10,'+====================================================+$'
menu_content     db 13,10,'| No |          Barang          |       Harga       |'
                db 13,10,'|----+------------------------+-------------------|'
                db 13,10,'| 01 | Nippon Paint-v Pro     | Rp.100.000      |'
                db 13,10,'| 02 | Dullux Catylac         | Rp.135.000      |'
                db 13,10,'| 03 | Aviter Galon 5kg       | Rp.110.000      |'
                db 13,10,'| 04 | CendanaInterior Paint  | Rp.125.000      |'
                db 13,10,'| 05 | Pargon                 | Rp.113.000      |'
                db 13,10,'| 06 | Racola Cat Kayu        | Rp.45.000       |'
                db 13,10,'| 07 | Avian                  | Rp.64.000       |'
                db 13,10,'| 08 | Kansai Paint           | Rp.68.000       |'
                db 13,10,'| 09 | Glo-Tex                | Rp.50.000       |'
                db 13,10,'| 10 | FTALIT                 | Rp.500.000      |$'

; Product prices (in thousands)
prices          dw 100, 135, 110, 125, 113, 45, 64, 68, 50, 500

; Nama produk
product_names    db 'Nippon Paint-v Pro     $'
                db 'Dullux Catylac         $'
                db 'Aviter Galon 5kg       $'
                db 'CendanaInterior Paint  $'
                db 'Pargon                 $'
                db 'Racola Cat Kayu        $'
                db 'Avian                  $'
                db 'Kansai Paint           $'
                db 'Glo-Tex                $'
                db 'FTALIT                 $'

; Messages
masukkan        db 13,10,'Masukkan kode produk (01-10): $'
menu_options    db 13,10,'[A]dd Item | [V]iew Cart | [C]heckout | [Q]uit: $'
error_msg       db 13,10,'Error: Kode tidak valid! $'
cart_empty      db 13,10,'Keranjang belanja masih kosong!$'
checkout_msg    db 13,10,'=== DETAIL PEMBELIAN ==='
                db 13,10,'Total Pembelian: Rp.$'
discount_msg    db 13,10,'Diskon (10%): Rp.$'
final_msg       db 13,10,'Total Setelah Diskon: Rp.$'
payment_msg     db 13,10,'Metode Pembayaran: $'
cash_msg        db 'Cash$'
credit_msg      db 'Credit Card$'
debit_msg       db 'Debit$'
selamat         db 13,10,13,10,'Terima kasih telah berbelanja!'
                db 13,10,'Silakan tunggu nota anda...$'

; Code Section
main proc
    ; Display welcome message
    mov ah, 09h
    lea dx, welcome_msg
    int 21h
    
    ; Get customer info
    call get_customer_info
    
menu_utama:
    ; Clear screen
    mov ax, 3
    int 10h
    
    ; Display menu
    mov ah, 09h
    lea dx, menu_header
    int 21h
    lea dx, menu_content
    int 21h
    
    ; Display menu options
    mov ah, 09h
    lea dx, menu_options
    int 21h
    
    ; Read choice
    mov ah, 01h
    int 21h
    
    ; Process menu choice
    cmp al, 'A'
    je add_item
    cmp al, 'V'
    je view_cart
    cmp al, 'C'
    je checkout
    cmp al, 'Q'
    je selesai
    jmp invalid_input
main endp

add_item proc
    ; Get product code
    mov ah, 09h
    lea dx, masukkan
    int 21h
    
    ; Read first digit
    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, al
    
    ; Read second digit
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ah, 0
    mov cl, 10
    mul cl
    add bl, al
    
    ; Validate input
    cmp bl, 1
    jl invalid_input
    cmp bl, 10
    jg invalid_input
    
    ; Get quantity
    mov ah, 09h
    lea dx, qty_prompt
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov [quantity], al
    
    ; Add to cart
    mov al, bl
    mov [cart_items + bx], al
    mov al, [quantity]
    mov [cart_qty + bx], al
    
    
    jmp menu_utama
add_item endp

view_cart proc
    ; Check if cart is empty
    je cart_is_empty
    
    ; Display cart items
    mov cx, 0
    mov cl, [cart_count]
    mov si, 0
    
view_cart_loop:
    push cx
    mov bl, [cart_items + si]
    mov bh, 0
    push si
    
    ; Calculate and display item details
    mov ah, 09h
    lea dx, checkout_msg
    int 21h
    
    pop si
    inc si
    pop cx
    loop view_cart_loop
    
    jmp menu_utama
view_cart endp

cart_is_empty proc
    mov ah, 09h
    lea dx, cart_empty
    int 21h
    jmp menu_utama
cart_is_empty endp

invalid_input proc
    mov ah, 09h
    lea dx, error_msg
    int 21h
    jmp menu_utama
invalid_input endp

checkout proc
    ; Check if cart is empty
    je cart_is_empty
    
    ; Get payment method
    mov ah, 09h
    lea dx, payment_prompt
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov [payment_method], al
    
    
    ; Display payment details
    mov ah, 09h
    lea dx, checkout_msg
    int 21h
    
    mov ax, [total_price]
    call display_number
    
    ; Apply discount if applicable
    call apply_discount
    
    jmp selesai
checkout endp

    mov cx, 0
    mov cl, [cart_count]
    mov si, 0
    
calc_loop:
    push cx
    mov bl, [cart_items + si]
    dec bl
    mov bh, 0
    shl bx, 1
    mov ax, [prices + bx]
    mov bl, [cart_qty + si]
    mov bh, 0
    mul bx
    add [total_price], ax
    inc si
    pop cx
    loop calc_loop
    ret

apply_discount proc

    
    mov ax, [total_price]
    mov bl, 10
    div bl
    mov [total_price], ax
    
    mov ah, 09h
    lea dx, discount_msg
    int 21h
    
    mov ax, [total_price]
    call display_number
    
skip_discount:
    ret
apply_discount endp

selesai proc
    mov ah, 09h
    lea dx, selamat
    int 21h
    int 20h
selesai endp

get_customer_info proc
    mov ah, 09h
    lea dx, nama_prompt
    int 21h
    mov ah, 0ah
    lea dx, tampung_nama
    int 21h
    
    mov ah, 09h
    lea dx, hp_prompt
    int 21h
    mov ah, 0ah
    lea dx, tampung_hp
    int 21h
    
    mov ah, 09h
    lea dx, alamat_prompt
    int 21h
    mov ah, 0ah
    lea dx, tampung_alamat
    int 21h
    ret
get_customer_info endp

display_number proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    mov cx, 0
    
convert_loop:
    mov dx, 0
    div bx
    push dx
    inc cx
    test ax, ax
    jnz convert_loop
    
print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_number endp

end start