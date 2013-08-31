;; MOU-MOU CARD GAME v0.1
;; Written in pure assembler by Ivushkin Andrey aka Willow
;;
;; Created: August 1, 2004
;;
;; Last changed:
;;

COLOR_ORDER equ MENUETOS
CUR_DIR equ '/HD/1/MEOS/' ; change it to appropriate path
SKIN_SIZE equ 756576
CARDS equ 36
Count equ dword[esi+CARDS]
Xy equ dword[esi+CARDS+4]

WIN_X equ (50 shl 16+570)
WIN_Y equ (180 shl 16+380)

; field dimensions
IMG_SIZE equ 71 shl 16+96 ; 14 shl 16+26
CARD_SHIFT equ 20
WND_COLOR equ 0x03aabbcc

SA_X equ 290 shl 16+40
SA_Y equ 170 shl 16+40
SA_SHIFT equ 50 shl 16
SUIT_H equ 20
SUIT_W equ 16
SUIT_DX equ 12
SUIT_DY equ 9
JACK_XY equ 250 shl 16+150
H1 equ 18
W1 equ 14


FL_ERASE    equ 29

FL_ERASEALL equ 12
FL_TAKEN    equ 10
FL_ASKING   equ 14
FL_TERM     equ 11
FL_SIX      equ 9
FL_JACK     equ 8

TURNBAR_X   equ 530 shl 16+20
TURNBAR_Y   equ 30  shl 16+20

struc DeckRec
{
    rb CARDS
    .count dd ?
    .xy dd ?
}

macro cards_in deck
{
   debug_print <13,10,'*'>
   mov   eax,[deck+CARDS]
   debug_print_dec eax
}

macro show_xy arg
{
   pusha
   pushf
   mov  ecx,arg
   and  ecx,0xffff
   shr  arg,16
   debug_print_dec arg
   debug_print_dec ecx
   debug_print <'%',13,10>
   popf
   popa
}

V_6 equ 6
V_7 equ 7
V_8 equ 8
V_9 equ 9
V_10 equ 10
V_JACK equ 11
V_QUEEN equ 12
V_KING equ 13
V_ACE equ 14

S_CLUBS equ 1
S_DIAMONDS equ 2
S_HEARTS equ 3
S_SPADES equ 4
jmp START
;use32                ; включить 32-битный режим ассемблера
;
;  org    0x0         ; адресация с нуля
;
;  db     'MENUET01'  ; 8-байтный идентификатор MenuetOS
;  dd     0x01        ; версия заголовка (всегда 1)
;  dd     START       ; адрес метки, с которой начинается выполнение программы
;  dd     I_END       ; размер программы
;  dd     0x200000    ; количество памяти
;  dd     0x17fff0    ; адрес вершины стэка
;  dd     0x0         ; адрес буфера для строки параметров (не используется)
;  dd     0x0         ; зарезервировано

include 'macros.inc'    ; decrease code size & some defs
include 'debug.inc'
;include '/hd/1/gif/gif_lite.inc'
;include 'gif_lite.inc'

lang equ ru             ; russian interface; english if undefined


Card_array:
;    db   V_10 shl 4+S_CLUBS
;    db   V_ACE shl 4+S_HEARTS
;    db   V_7 shl 4+S_CLUBS
;    db   V_8 shl 4+S_SPADES
;    db   V_6 shl 4+S_HEARTS
;    db   V_QUEEN shl 4+S_CLUBS
;    db   V_9 shl 4+S_HEARTS
;    db   V_KING shl 4+S_SPADES

    db   V_10 shl 4+S_HEARTS
    db   V_KING shl 4+S_CLUBS
    db   V_KING shl 4+S_HEARTS
    db   V_ACE shl 4+S_CLUBS
    db   V_6 shl 4+S_DIAMONDS
    db   V_8 shl 4+S_HEARTS
    db   V_6 shl 4+S_CLUBS

;    db   V_KING shl 4+S_HEARTS
;    db   V_7 shl 4+S_HEARTS
;    db   V_7 shl 4+S_SPADES
;    db   V_6 shl 4+S_CLUBS
;    db   V_10 shl 4+S_HEARTS
;    db   V_ACE shl 4+S_CLUBS


START:                  ; здесь начинается выполнение программы
;    jmp  .skipAI
    mov  [Cpu.count],7
    mov  al,[Card_array]
    mov  byte[status],al
    mov  esi,(Card_array+1)
    mov  edi,Cpu
    mov  ecx,6
    rep  movsb
    mov  edi,status
    call AI
    jmp  close

  .skipAI:
    mov  esi,array_xy
    mov  edi,(Cpu+CARDS+4)
    mov  ecx,5
  .lop:
    movsd
    add  edi,CARDS+4
    loop .lop

    mov  eax,58         
    mov  ebx,file_info  
    int  0x40
    mov  esi,workarea
    mov  edi,strip
    mov  eax,hashtable
    call ReadGIF

    mov  eax,40
    mov  ebx,0100101b
    int  0x40
    mov  eax,3
    int  0x40
    mov  eax,0x1234567
    mov  cl,16
    ror  eax,cl
    mov  [generator],eax
; filling main deck
  new_game:
    mov  ecx,9
    mov  [Main.count],CARDS
    mov  edi,Main
  fd_loop1:
    lea  eax,[ecx+5]
    shl  eax,4
    push ecx
    mov  ecx,S_SPADES
  fd_loop2:
    inc  eax
    stosb
    loop fd_loop2
    pop  ecx
    loop fd_loop1
    xor  eax,eax
    mov  [Player.count],eax
    mov  [Cpu.count],eax
    mov  [Table.count],eax
    mov  [Laid.count],eax
    call shuffle
    mov  edi,Main
    mov  esi,Player
    mov  [cur],esi
    mov  eax,5
    call take_cards
    call lay_card
    call resort
    mov  esi,Cpu
    push esi
    call take_cards
    call how_many
    pop  esi
    call take_cards
    call flush_laid

red:                    ; перерисовать окно

    call draw_window    ; вызываем процедуру отрисовки окна

still:                  ; ГЛАВНЫЙ ЦИКЛ ПРОГРАММЫ

    mov  eax,10         ; функция 10 - ждать события
    int  0x40           ; вызываем систему

    cmp  eax,1          ; перерисовать окно ?
    je   red            ; если да - на метку red
    cmp  eax,3          ; нажата кнопка ?
    je   button         ; если да - на button
    bt   [status],FL_ASKING
    jc   still
    cmp  eax,2          ; нажата клавиша ?
    je   key            ; если да - на key
    cmp  eax,6
    je   mouse
    jmp  still          ; если другое событие - в начало цикла

  key:                  ; нажата клавиша на клавиатуре
    mov  eax,2          ; функция 2 - считать код символа
    int  0x40           ; вызов системы

    jmp  still          ; вернуться к началу цикла

  button:               ; нажата кнопка в окне программы
    mov  eax,17         ; 17 - получить идентификатор нажатой кнопки
    int  0x40           ; вызов системы

    cmp  ah,1           ; идентификатор == 1 ?
    jne  noclose        ; если нет - иди вперёд на noclose
  close:
    or   eax,-1         ; выход из программы
    int  0x40           ; вызов системы

  noclose:
    sub  ah,2
    jz   new_game
    mov  byte[jacksuit],ah ;lastcard
    btr  [status],FL_ASKING
    jmp  red          ; возвращаемся

  mouse:
    mov  eax,37
    mov  ebx,2
    int  0x40
    and  eax,1
    cmp  al,[pressed]
    jz   still
    mov  [pressed],al
    test al,al
    jz   still
                       ; left button pressed
    mov  eax,37
    xor  ebx,ebx
    int  0x40

    mov  ebx,eax
    shr  eax,16        ; eax - Xmouse
    sub  eax,[process.x_start]
    jle  still
    and  ebx,0xffff    ; ebx - Ymouse
    sub  ebx,[process.y_start]
    jle  still
    shl  eax,16
    add  ebx,eax
    mov  ecx,4
    mov  esi,Table
  .l:
    mov  edx,Count
    test edx,edx
    jz   .e_loop
    mov  eax,Xy
    and  eax,0x9fffffff
    btr  eax,31
    jc   .shifted
    mov  edx,1
  .shifted:                ; edx - card count
    push edx
    imul edx,CARD_SHIFT
    add  edx,71-CARD_SHIFT ; edx - Xmax
    cmp  ax,bx             ; Ymin < Ymouse
    jae  .e_loop
    add  ax,96             ; ax - Ymax
    cmp  ax,bx             ; Ymax <Ymouse
    jle  .e_loop
    shr  eax,16            ; ax - Xmin
    mov  edi,ebx
    shr  edi,16            ; bx - Xmouse
    sub  edi,eax           ; ebx - Xrel
    jle  .e_loop
    cmp  edi,edx           ; Xrel < Xmax
    ja   .e_loop
    mov  eax,edi           ; eax - Xrel
    xor  edx,edx           ; edx=0
    mov  edi,CARD_SHIFT
    div  edi               ; eax -card num
    pop  edx
    cmp  eax,edx
    jb  .ok
    lea  eax,[edx-1]
  .ok:
    inc  eax
    jmp  .ex
  .e_loop:
;    debug_print '?'
    add  esi,CARDS+8
    loop .l2
    jmp  .ex
  .l2:
    jmp  .l
  .ex:
    test  ecx,ecx
    jne  .ret1
    xor  eax,eax
  .ret1:

;   -------------------------------------
;   -------------------------------------

    test eax,eax
    jz   still
  .first:
    mov  edi,status
    cmp  esi,Table                  ; ** TABLE **
    jne  .notable
    cmp  Count,0
    je   .chgturn
    call how_many
    pusha
    mov  edi,Main
    mov  esi,Cpu
    call take_cards
    popa
    call flush_laid
    bt   dword[edi],FL_JACK
    jc   .jackput
    and  byte[jacksuit],0
    jmp  .chgturn
  .jackput:
    bts  dword[edi],FL_ASKING
  .chgturn:
    call draw_window
    bt  dword[edi],FL_TERM
    jnc  .upd
    mov  eax, Player
    add  eax,Cpu
    sub  eax,[cur]
    mov  [cur],eax
;    debug_print <'Your turn!',13,10>
    btr  dword[edi],FL_TAKEN
    btr  dword[edi],FL_TERM
    jmp  .upd
  .notable:

    cmp  esi,Player                 ; ** PLAYER **
    jne  .noplayer
    call move_check
    jnz   still
    call lay_card
    jmp  .upd

  .noplayer:
    mov  edi,esi
    mov  esi,Player
    cmp  edi,Main                   ; ** MAIN **
    jne  .nomain
    bt   [status],FL_SIX
    jc   .maytake
    bt   [status],FL_TAKEN
    jc   still
    bts  [status],FL_TAKEN
  .maytake:
    mov  eax,1
    call take_cards
;    call resort
  .upd:
    mov  edi,status
    call check_status
    call update
    jmp  still
  .nomain:
    cmp  edi,Laid                   ; ** LAID **
    jne  .nolaid
    cmp  eax,[Laid.count]
    jne  still
    cmp  eax,1
    jne  .noone
    mov  ebx,[Table.count]
    mov  bl,[Table+ebx-1]
    jmp  .one
  .noone:
    movzx ebx,byte[Laid+eax-2]
  .one:
    mov  byte[status],bl
;    debug_print_dec ebx
    jmp  .maytake
  .nolaid:
    jmp  still

;   *********************************************
;   *******  ОПРЕДЕЛЕНИЕ И ОТРИСОВКА ОКНА *******
;   *********************************************

draw_window:
    pusha
    mov  eax,12                    ; функция 12: сообщить ОС об отрисовке окна
    mov  ebx,1                     ; 1 - начинаем рисовать
    int  0x40
    btr  dword[status],FL_ERASEALL
                                   ; СОЗДАЁМ ОКНО
    xor  eax,eax                   ; функция 0 : определить и отрисовать окно
    mov  ebx,WIN_X
    mov  ecx,WIN_Y
    mov  edx,WND_COLOR ;0x03aabbcc ; цвет рабочей области  RRGGBB,8->
    mov  esi,0x805080d0            ; цвет полосы заголовка RRGGBB,8->color gl
    mov  edi,0x005080d0            ; цвет рамки            RRGGBB
    int  0x40

    mov  eax,4                     ; функция 4 : написать в окне текст
    mov  ebx,8*65536+8             ; [x] *65536 + [y]
    mov  ecx,0x10ddeeff            ; шрифт 1 и цвет ( 0xF0RRGGBB )
    mov  edx,zagolovok             ; адрес строки
    mov  esi,zag_konets-zagolovok  ; и её длина
    int  0x40

    mov  bl,byte[status]
    mov  edx,400 shl 16+20
    call draw_img

    mov  eax,9
    mov  ebx,process
    mov  ecx,-1
    int  0x40

    mov  eax,8
    mov  ebx,10 shl 16+10
    mov  ecx,30 shl 16+10
    mov  edx,2
    mov  esi,0x6688dd
    int  0x40

    call update

    bt   [status],FL_ASKING
    jnc  .noask

    mov  ecx,4
    mov  esi,WND_COLOR
    mov  edi,SA_Y
    mov  ebx,SA_X
  .suitloop:
    inc  edx
    pusha
    mov  ecx,edi
    int  0x40
    shr  ebx,16
    add  ebx,SUIT_DX
    shr  ecx,16
    add  ecx,SUIT_DY
    sub  edx,2
    call draw_suit
    popa
    add  ebx,SA_SHIFT
    loop .suitloop

    mov  eax,4
    mov  ebx,JACK_XY
    mov  ecx,0x104e00e7
    mov  edx,jack_msg
    mov  esi,jack_end-jack_msg
    int  0x40

  .noask:
    bts  dword[status],FL_ERASEALL

    bt   [status],FL_JACK
    jnc  .enddraw
    mov  ebx,500
    mov  ecx,50
    movzx edx,byte[jacksuit]
    call draw_suit


  .enddraw:
    mov  eax,12                    ; функция 12: сообщить ОС об отрисовке окна
    mov  ebx,2                     ; 2, закончили рисовать
    int  0x40
    popa
    ret                            ; выходим из процедуры

;   *********************************************
;   *********** DRAW SUIT SIGN ******************
;   *********************************************
;   in:   ebx - [x], ecx - [y], edx - suit (1..4)

draw_suit:
    test edx,edx
    jz   .ex
    pusha
    imul edx,9
    sub  edx,6
    imul esi,edx,71*96*3
    mov  edi,ecx
    add  esi,(strip+12+71*H1+W1*3)
    mov  ecx,SUIT_H
    mov  eax,1
  .hloop:
    push ecx ebx
    mov  ecx,SUIT_W
  .wloop:
    push ecx
    mov  ecx,edi
    mov  edx,[esi]
    and  edx,0xffffff
    cmp  edx,0xfcfefc
    jz   .noput
    int  0x40
  .noput:
    inc  ebx
    add  esi,3
    pop  ecx
    loop .wloop
    pop  ebx
    inc  edi
    add  esi,(71-SUIT_W)*3
    pop  ecx
    loop .hloop
    popa
  .ex:
    ret

;   *********************************************
;   *********** RECYCLE & SHUFFLE DECK **********
;   *********************************************

recycle_deck:
    pusha
    mov  edx,[doubles]
    push edx
    mov  ecx,[Table.count]
    sub  ecx,edx
    mov  [Main.count],ecx
    mov  esi,Table
    mov  edi,Main
    cld
    rep  movsb
    mov  edi,Table
    pop  ecx
    mov  [Table.count],ecx
    rep  movsb
    popa
shuffle:
    pusha
    mov  edi,workarea
    mov  esi,edi
    mov  ecx,[Main.count]
    mov  edx,ecx
    mov  eax,[generator]
    cld
  sh_cycle:                ; generating RND to shuffle
    sub  eax,0x43ab45b5
    ror  eax,1
    xor  eax,0x32c4324f
    ror  eax,1
    mov  [generator],eax
    push eax
    mov  al,[Main+ecx-1]
    stosw
    pop  eax
    loop sh_cycle
    call linear_sort
    mov  edi,Main
    mov  ecx,[edi+CARDS]
    mov  esi,workarea
  loop2:
    lodsw
    stosb
    loop loop2
    popa
    ret

;   *********************************************
;   *********** LINEAR SORTING OF WORDS *********
;   *********************************************
  do_swap:
    lea  ebx,[edi-2]
    mov  ax,[ebx]
    dec  ecx
    jecxz tail
  loop1:
    scasw
    ja  do_swap
    loop loop1
  tail:
    xchg ax,[esi-2]
    mov  [ebx],ax
linear_sort:
    mov  ebx,esi
    lodsw
    mov  edi,esi
    dec  edx
    mov  ecx,edx
    jg   loop1
    ret

;   *********************************************
;   *********** TAKE CARDS FROM THE DECK ********
;   *********************************************
;   in:     edi - source deck pointer
;           eax - amount of cards to take

take_cards:
    pusha
    mov  ecx,eax
    jecxz .ex
    xchg esi,edi
    call erase_deck_img
    xchg esi,edi
    xor  edx,edx
    mov  ecx,eax
    mov  ebx,Count
  .new:
    mov  eax,[edi+CARDS]
  .loop:
    test eax,eax
    jnz  .gt0
    call recycle_deck
;    debug_print '!'
    jmp  .new
;    mov  eax,[edi+CARDS]
  .gt0:
    mov  edx,[edi+eax-1]
    mov  [esi+ebx],dl
    dec  eax
    inc  ebx
    loop .loop
    mov  [edi+CARDS],eax
    mov  Count,ebx
 .ex:
    popa
    ret

;   *********************************************
;   ***********  LAY CARD ON THE TABLE **********
;   *********************************************
;   in:     esi - deck pointer
;           eax - card index (1..n)

lay_card:
    pusha
    call erase_deck_img
    mov  ecx,[Laid.count]
    inc  dword[Laid.count]
    lea  edi,[esi+eax-1]
    mov  dl,[edi]
    mov  [Laid+ecx],dl
    mov  ebx,status
    mov  byte[ebx],dl
    shr  dl,4
    cmp  dl,V_6
    jne  .no6
    bts  dword[ebx],FL_SIX
    jmp  .is6
  .no6:
    btr  dword[ebx],FL_SIX
  .is6:
    mov  ecx,Count
    dec  Count
    sub  ecx,eax
    lea  esi,[edi+1]
    cld
    rep  movsb
    call check_status
    popa
    ret

;   *********************************************
;   *********** DRAW CARD IMAGE *****************
;   *********************************************

draw_img:               ; in: bl- card, edx-coordinates
    pusha
    mov  ecx, IMG_SIZE
    movzx ebx,bl
    test ebx,ebx
    jz   di_0
    movzx eax,bl
    and  ebx,0xf
    shr  eax,4
    imul ebx,9
    add  ebx,eax
    sub  ebx,14
    imul ebx, 71*96*3   ;14*26*3
  di_0:
    add  ebx,strip+12
    mov  eax,7          ; draw_image sysfunc
    int  0x40
  no_img:
    popa
    ret

;   *********************************************
;   *********** DRAW DECK ***********************
;   *********************************************

draw_deck:              ; in: esi-DECK pointer
    bt   [status],FL_ERASEALL
    jnc  .noerase
    btr  Xy,FL_ERASE
    jnc  .noerase
    call erase_deck_img
  .noerase:
    pusha
    xor  ebx,ebx
    mov  ecx,Count
    jecxz .noshift
    mov  edx,Xy
    btr  edx,30
    adc  bh,bh
    cld
    btr  edx,31
    jc  .loop
    lea  esi,[esi+ecx-1]
    mov  ecx,1
  .loop:
    lodsb
    test bh,bh
    jz   .closed
    mov  bl,al
  .closed:
    call draw_img
    add  edx,CARD_SHIFT shl 16
    loop .loop
  .noshift:
    popa
    ret

;   *********************************************
;   *********** ERASE DECK BACKGROUND ***********
;   *********************************************
;   in: esi - deck pointer

erase_deck_img:
    pusha
    mov  ebx,Xy
    bt   ebx,31
    jnc  .ex
    and  ebx,0x1fffffff
    shrd ecx,ebx,16  ; ebx[x][y], ecx[y][?]
    movzx  bx,[esi+CARDS]
    test bx,bx
    jz   .ex
    imul bx,CARD_SHIFT
    add  bx,71-CARD_SHIFT
    mov  cx,96
    mov  edx,WND_COLOR
    mov  eax,13
    int  0x40
  .ex:
    popa
    ret

;   *********************************************
;   *********** REDRAW ALL DECKS ****************
;   *********************************************

update:
    pusha
    mov  esi,Cpu
    mov  ecx,5
  .draw:
    call draw_deck
    add  esi,CARDS+8
    loop .draw
    mov  eax,13
    mov  ebx,TURNBAR_X
    mov  ecx,TURNBAR_Y
    bt   [status],FL_TERM
    jc   .cpu_turn
;    cmp  [cur],Player
;    jne  .cpu_turn
    mov  edx,0x4ba010
    jmp  .ex
  .cpu_turn:
    mov  edx,0xcc0000
  .ex:
    int  0x40
    popa
    ret

;   *********************************************
;   ******* RESORT PLAYER'S CARDS BY VALUE ******
;   *********************************************

resort:
    pusha
    mov  esi,Player
    mov  edi,workarea
    mov  ecx,Count
    xor  eax,eax
    cld
    pusha
  .l1:
    lodsb
    stosw
    loop .l1
    mov  esi,[esp]
    mov  edx,[esp+24]
    call linear_sort
    popa
    xchg esi,edi
    jmp  loop2

;   *********************************************
;   ******* MOVE ALL LAID CARD INTO TABLE DECK **
;   *********************************************

flush_laid:
    pusha
    mov  esi,Laid
    mov  ecx,Count
    call erase_deck_img     ; && Laid <<
    mov  esi,Laid
    movzx eax,byte[esi+ecx-1]
;    mov  byte[status],al    ; last card
;    call check_term
;    shr  al,4
;    cmp  al,V_JACK
;    jne  .noask

    mov  eax,[Table.count]
    lea  edi,[Table+eax]
    add  [Table.count],ecx
    and  Count,0
    cld
    rep  movsb
    btr  [status],FL_TAKEN
  .ex:
    popa
    ret

;   *********************************************
;   ******* VERIFY IF CARD PUT IS VALID *********
;   *********************************************
;   in - eax=new card index, esi-DeckRec, edi-status
;   out  ZF=1, if OK

move_check:
    pusha
    movzx ebx,byte[esi+eax-1] ; ebx-card of index [eax]
    mov  edx,ebx
    mov  bh,bl
    movzx  ecx,byte[edi]        ; last card in Laid
    mov  ch,cl
    shr  ch,4              ; ch -value of last card
    shr  bh,4              ; bh -value of new card
    cmp  bh,ch
    je   .ex
    cmp  [Laid.count],1
    jbe  .notermcheck
    mov  eax,[edi]
    and  eax,1 shl FL_TERM
    jnz  .ex
  .notermcheck:
    cmp  ch,V_JACK
    jne  .noasksuit
    mov  cl,byte[jacksuit]
  .noasksuit:
    cmp  bh,V_6
    je   .ex
    cmp  bh,V_JACK
    je   .ex
    and  cl,0xf            ; cl -suit of last card
    and  bl,0xf            ; bl -suit of new card
    cmp  cl,bl
  .ex:
    mov  byte[edi],dl
    popa
    ret

;   *********************************************
;   ******* CHECK IF CARD IS A TERMINATOR *******
;   *********************************************
;   in: al-card, edi-status
check_status:
    mov  al,byte[edi]
check_term:
    pusha
    and  dword[edi],0xffffffff-1 shl FL_TERM-1 shl FL_JACK
    bts  dword[edi], FL_SIX
;    cmp  [Laid.count],0
;    je   .ex
;    debug_print '/'
    cmp  al,V_KING shl 4+S_CLUBS
    je   .ex
    shr  al,4
    cmp  al,V_JACK
    jne  .term
    bts  dword[edi],FL_JACK
  .term:
    cmp  al,V_6
    je   .ex
    btr  dword[edi],FL_SIX
    cmp  al,V_8
    je   .ex
    cmp  al,V_ACE
    je   .ex
    bts  dword[edi],FL_TERM
  .ex:
    popa
    ret

;   *********************************************
;   ******* HOW MANY CARDS TO TAKE **************
;   *********************************************
;   out - eax, esi-DeckRec

how_many:
    push ecx ebx esi
    xor  ebx,ebx
    mov  esi,Laid
    mov  ecx,Count
    jecxz .ex2
  .lp:
    lodsb
    cmp  al,V_KING shl 4+S_CLUBS
    jne  .noking
    add  ebx,5
  .noking:
    shr  al,4
    cmp  al,V_8
    jne  .no8
    add  ebx,2
  .no8:
    cmp  al,V_7
    jne  .ex
    inc  ebx
  .ex:
    loop .lp
  .ex2:
    mov  eax,ebx
    pop  esi ebx ecx
    ret

;   *********************************************
;   ******* SCORE CALCULATION *******************
;   *********************************************
;   in: esi - DeckRec
;   out - eax

calc_score:
    push ebx ecx esi
    xor  ebx,ebx
    mov  ecx,Count
  .lp:
    lodsb
    shr  al,4
    cmp  al,V_10
    jb   .ex
    add  ebx,2
    cmp  al,V_JACK
    jne  .nojack
    add  ebx,2
  .nojack:
    cmp  al,V_ACE
    jne  .ex
    inc  ebx
  .ex:
    loop .lp
    mov  eax,ebx
    pop  esi ecx ebx
    ret

;   *********************************************
;   ******* EMPIRIC EVALUATION ******************
;   *********************************************
;   in: edi -status
;   out - eax

evaluate:
    push ebx
    mov  ebx,[Laid.count]; cards laid
    shl  ebx,2              ; *4 points
    call how_many
    add  ebx,eax            ; 1 pt for a card to be taken
    mov  esi,Laid
    call calc_score         ; 1:1 score points
    add  ebx,eax
    bt   dword[edi],FL_TERM
    jc   .term_yes
    inc  ebx                ; last nonterminal
  .term_yes:
    bt   dword[edi],FL_SIX
    jnc   .no6
    sub  ebx,2              ; last 6
  .no6:
    bt   dword[edi],FL_JACK
    jnc   .nojack
    add  ebx,2              ; last Jack
  .nojack:
    mov  eax,ebx
    pop  ebx
    ret

;   *********************************************
;   ******* ARTIFICIAL INTELLIGENCE *************
;   *********************************************
;   in: edi - status
;   out - eax

AI:
    pusha
    mov  al,[edi]
    mov  [lastcard],al
    xor  eax,eax
    mov  [Seq0.xy],eax
    mov  [Seq1.xy],eax
    mov  [Seq2.xy],eax
    mov  edx,TestSeq
    push [status]
    pop  [cache]
    int3
  .lev_up:
    mov  eax,[Cpu.count]
    inc  [Laid.count]
    mov  [edx],al
  .lp:
    push [cache]
;    mov  esi,TestSeq
    mov  al,[edx]       ; card in TestSeq
    mov  ecx,[Laid.count]; check for repeats in seq
    dec  ecx
    mov  bl,[Cpu+eax-1]
    mov  [Laid+ecx],bl
    jecxz .norepeat     ; no repeat
    mov  edi,TestSeq
    repne scasb
    je   .repeats       ; card repeats, skipping
  .norepeat:
    mov  esi,Cpu
    mov  edi,cache
    call move_check
    jnz  .repeats       ; skipping
    mov  al,bl          ; card itself
    call check_term     ; terminal & other flags
;    bt   dword[edi],FL_TERM
;    jc   .eval
    inc  edx
    jmp  .lev_up
  .eval:
    mov  esi,TestSeq  
    int3
    call evaluate       ; terminal - evaluate seq and
    mov  edi,Seq0       ; store if necessary
    mov  ecx,3
    int3
  .cmploop:
    cmp  eax,[edi+CARDS+4]
    ja   .greater       ; new one is greater
    add  edi,CARDS+8
    loop .cmploop
    jmp  .repeats       ; not greater-skipping
  .greater:
    mov  esi,TestSeq
    mov  ecx,[Laid.count]
    mov  [edi+CARDS],ecx
    mov  [edi+CARDS+4],eax
;    add  ecx,8
    rep  movsb
  .repeats:             ; next card at current level
    pop  [cache]
    dec  byte[edx]
    jnz  .lp
    dec  edx            ; no more cards at level
    dec  [Laid.count]
    cmp  edx,TestSeq    ; no cards in seq
    jae  .eval
    mov  esi,Cpu
    mov  ecx,Count
    mov  edi,Seq0
    int3
  .layloop:
    movzx eax,byte[edi]
    call lay_card
    inc  edi
    loop .layloop
    popa
    ret

; Здесь находятся данные программы:
; интерфейс программы двуязычный - задайте язык в macros.inc

win_msg:
if lang eq ru
     db 'Ура!!! Вы прошли уровень!'
else
     db "You've completed the level!"
end if
win_msg_end:

jack_msg:
if lang eq ru
     db 'Вы положили валета. Выберите масть:'
else
     db "You've laid a Jack. Select suit desired:"
end if
jack_end:

lose_msg:
if lang eq ru
     db 'Вы парализованы! Проигрыш...'
else
     db "You're paralized! Game over..."
end if
lose_msg_end:

zagolovok:               ; строка заголовка
if lang eq ru
     db   'МАУ-МАУ'
else
     db   'MOU-MOU'
end if
zag_konets:              ; и её конец

file_info:
status     dd 0
generator  dd 0
cur        dd 0x10000
cache      dd workarea
jacksuit   dd 0x10000
           db CUR_DIR
;           db 'erodeck.gif'
;           db 'ANTIK.GIF'
           db 'CARDS36.GIF'
pressed    db 0

array_xy:
    dd 20 shl 16+30+2 shl 30
    dd 105 shl 16+150+1 shl 30
    dd 20 shl 16+270+3 shl 30
    dd 290 shl 16+150+3 shl 30
    dd 20 shl 16+150

I_END:  ; конец программы

Cpu     DeckRec
Table   DeckRec
Player  DeckRec
Laid    DeckRec
Main    DeckRec

lastcard rb 1
TestSeq DeckRec
Seq0    DeckRec
Seq1    DeckRec
Seq2    DeckRec

process process_information

doubles dd ?
strip:
    rb SKIN_SIZE

align 4
hashtable rd 4096

workarea:
