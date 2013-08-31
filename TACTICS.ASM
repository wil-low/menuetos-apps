;
 ;   TACTICS GAME
 ;
;   Compile with FASM for Menuet
;
   
use32
   
        org    0x0
   
        db     'MENUET01'       ; 8 byte id
        dd     0x01        ; header version
        dd     START        ; start of code
        dd     I_END        ; size of image
        dd     0x100000        ; memory for app
        dd     0x7fff0        ; esp
        dd     0x0 , 0x0        ; I_Param , I_Icon
   
START:    ; start of execution
   
  call draw_window
   
still:
   
    mov  eax,10   ; wait here for event
    int  0x40
   
    cmp  eax,1   ; redraw request ?
    je  red
    cmp  eax,2   ; key in buffer ?
    je  key
    cmp  eax,3   ; button in buffer ?
    je  button
   
    jmp  still
   
  red:    ; redraw
    call draw_window
    jmp  still
   
  key:    ; key
    mov  eax,2   ; just read it and ignore
    int  0x40
    jmp  still
   
  button:   ; button
    mov  eax,17   ; get id
    int  0x40
   
    cmp  ah,1   ; button id=1 ?
    jne  noclose
   
    mov  eax,-1   ; close this program
    int  0x40
  noclose:
   
    cmp ah,17
    ja other_buttons
    shr ax,8
    dec ax
    mov [btn],ax
    dec ax
   
    btc [cur_field],ax
    call draw_window
    jmp still
  other_buttons:
    cmp ah,21
    jne no_reset
    mov bx,[old_field]
    mov [cur_field],bx
    call draw_window
    jmp still
  no_reset:
    cmp ah,22
    jne no_revert
    call revert
    mov [cur_field],dx
    call draw_window
    jmp still
  no_revert:
    mov ax,[cur_field]
    mov [old_field],ax
    call draw_window
    jmp  still
   
   
revert:
    push bx
    mov dx,[cur_field]
    mov cx,4
 m4:
    rol dx,1
    rcl bx,1
    rol dx,4
    rcl bx,1
    rol dx,4
    rcl bx,1
    rol dx,4
    rcl bx,1
    rol dx,4
    loop m4
    mov dx,bx
    pop bx       ; dx - out
    ret
   
;   *********************************************
;   *******  WINDOW DEFINITIONS AND DRAW ********
;   *********************************************
   
   
draw_window:
   
   
    mov  eax,12      ; function 12:tell os about windowdraw
    mov  ebx,1      ; 1, start of draw
    int  0x40
   
       ; DRAW WINDOW
    mov  eax,0        ; function 0 : define and draw window
    mov  ebx,100*65536+200    ; [x start] *65536 + [x size]
    mov  ecx,100*65536+200    ; [y start] *65536 + [y size]
    mov  edx,0x03ffffff     ; color of work area RRGGBB,8->color gl
    mov  esi,0x805080d0     ; color of grab bar RRGGBB,8->color gl
    mov  edi,0x005080d0     ; color of frames RRGGBB
    int  0x40
   
       ; WINDOW LABEL
    mov  eax,4              ; function 4 : write text to window
    mov  ebx,8*65536+8      ; [x start] *65536 + [y start]
    mov  ecx,0x10ddeeff     ; font 1 & color ( 0xF0RRGGBB )
    mov  edx,labelt         ; pointer to text beginning
    mov  esi,labellen-labelt   ; text length
    int  0x40
   
       ; MAIN BUTTONS
    mov  eax,8                     ; function 8 : define and draw button
    mov  ebx,(200-55)*65536+42     ; [x start] *65536 + [x size]
    mov  ecx,33*65536+20           ; [y start] *65536 + [y size]
    mov  edx,20                    ; button id
    mov  esi,0x6688dd              ; button color RRGGBB
    int  0x40
    mov  eax,4
     mov  ebx,(200-45)*65536+40
      mov  ecx,0xddeeff
   
     mov  edx,okt
      mov  esi,oklen-okt
   
    int  0x40                      ; draw button label OK
   
    mov  eax,8                     ; function 8 : define and draw button
    mov  ebx,(200-55)*65536+42     ; [x start] *65536 + [x size]
    mov  ecx,65*65536+20           ; [y start] *65536 + [y size]
    mov  edx,21                    ; button id
    mov  esi,0x6688dd              ; button color RRGGBB
    int  0x40
    mov  eax,4
    mov  ebx,(200-48)*65536+72
     mov  ecx,0xddeeff
      mov  edx,resett
   
     mov  esi,resetlen-resett
     int  0x40                      ; draw button label RESET
   
    mov  eax,8                     ; function 8 : define and draw button
    mov  ebx,(200-55)*65536+42     ; [x start] *65536 + [x size]
    mov  ecx,97*65536+20           ; [y start] *65536 + [y size]
    mov  edx,22                    ; button id
    mov  esi,0x6688dd              ; button color RRGGBB
    int  0x40
    mov  eax,4
    mov  ebx,(200-48)*65536+104
    mov  ecx,0xddeeff
    mov  edx,revt
   
    mov  esi,revlen-revt
    int  0x40                      ; draw button label REVERT
   
       ; DRAW BUTTONS
    mov ecx,16        ;16 buttons
m2:
    push ecx
    mov edx,ecx        ; button ID
    inc edx
    dec ecx         ; in cycle 0..15
    bt [old_field],cx      ; btn exists
    jnc no_button
    bt [cur_field],cx      ; btn marked as deleted
    jnc deleted
    mov esi,0x006677cc      ; no - normal color
    jmp m1
deleted:
    mov esi,0x00aa1111      ; yes - other color
m1:
    mov ebx,ecx
    and ebx,3        ; ostatok /4, x-column
    shl ebx,5
    add ebx,11
    shl ebx,16        ; btn size 32 pt
    add ebx,30
    shr ecx,2        ; chastnoe /4, y-row
    shl ecx,5
    add ecx,28
    shl ecx,16
    add ecx,30
    mov eax,8
    int 0x40        ; draw btn
   
no_button:
    pop ecx
    loop m2         ; end of cycle
   
    xor ecx,ecx     ; draw debug text
    mov cx,[btn]
    mov ebx,0x000f0200
    mov edx,20*65536+170
    mov esi, 0
    mov eax,47
    int 0x40
   
   
    mov  eax,12      ; function 12:tell os about windowdraw
    mov  ebx,2      ; 2, end of draw
    int  0x40
   
    ret
   
   
; DATA AREA
    cur_field dw 0xffff    ; current config
    old_field dw 0xffff    ; old config
; move history: player; history+8 - CPU
    history dw ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
    size1 equ 4      ; field size
    btn dw 0
   
   
labelt:
     db   'íÄä-íàäë'
labellen:
   
okt:
     db   ' OK '
oklen:
   
resett:
     db   'ëÅêéë'
resetlen:
   
revt:
      db   'éÅêÄí'
 revlen:
   
   
I_END:
   
   
   
   