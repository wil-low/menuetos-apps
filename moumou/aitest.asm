format PE console
entry start
COLOR_ORDER equ MENUETOS

    macro stdcall proc,[arg]
     {
      reverse push arg
      common call proc
     }

    macro invoke proc,[arg]
     { common stdcall [proc],arg }


section '.text' code readable executable writeable
include 'd:\ivushkin\menuetos\gif_lite.inc'
start:
include 'd:\ivushkin\menuetos\ai\moumou.asm'


section '.idata' import data readable writeable

  dd 0,0,0,rva kernel_name,rva kernel_table
  dd 0,0,0,0,0

  kernel_table:
    ExitProcess dd rva _ExitProcess
    CreateFileA dd rva _CreateFileA
    WriteFile dd rva _WriteFile
    CloseHandle dd rva _CloseHandle
    dd 0

  kernel_name db 'KERNEL32.DLL',0

  _ExitProcess dw 0
    db 'ExitProcess',0
  _CreateFileA dw 0
    db 'CreateFileA',0
  _WriteFile dw 0
    db 'WriteFile',0
  _CloseHandle dw 0
    db 'CloseHandle',0

section '.reloc' fixups data readable discardable
