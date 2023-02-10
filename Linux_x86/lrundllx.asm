format ELF executable 3
entry start

include 'import32.inc'

start:

     mov ebp, esp

     mov EAX,[printf]
     mov [prin_],EAX


     lea ESI,[EBP+8]
   @cst:
     lodsd
     test EAX,EAX
     je @cnd
     push ESI
     mov esi,eax
     mov edi,eax

   .lnb:
     lodsb
     test AL,AL
     jne .bcm
     stosb
     jmp .ecl

    .bcm:
     cmp AL,'$'
     jne .oe
     lodsb
     cmp AL,'0'
     jge .nze
   .nerr:
     dec ESI
     mov AL,'$'
     jmp .oe
   .nze:
     cmp AL,'9'
     jle .hx
     cmp AL,'A'
     jl .nerr
     cmp AL,'F'
     jle .hx
     cmp AL,'a'
     jl .nerr
     cmp AL,'f'
     jg .nerr
   .hx:
     sub AL,$30
     cmp AL,0Ah
     jl .nx1
     sub AL,7
     cmp AL,10h
     jl .nx1
     sub AL,20h
   .nx1:
     mov AH,AL
     shl AH,4
     lodsb
     sub AL,$30
     cmp AL,0Ah
     jl .nx2
     sub AL,7
     cmp AL,10h
     jl .nx2
     sub AL,20h
   .nx2:
     add AL,AH

   .oe:
     stosb
     jmp .lnb

    .ecl:
     pop esi
     jmp @cst

    @cnd:
     lea ESI,[EBP+8]

   @nfc:

     lodsd
     test EAX,EAX
     je @orp

   @ncl:
     push 1
     push EAX
     call [dlopen]     ; Çàãðóæàåì áèáëèîòåêó.
     mov EBX,EAX
   @lal:
     mov [lib],EAX
     lodsd 
     test EAX,EAX
     je @nll
     push EAX
     push EBX
     call [dlsym]   ;   Ïîëó÷àåì óêàçàòåëü ôóíêöèè.
     mov [addr],EAX
     mov EBX,EAX
     test EAX,EAX
     jne @lpl
     sub ESI,8
     mov EBX,@nll
     
   @lpl:                   ;  Êèäàåì ïàðàìåòðû â ñòåê.
     lodsd
     test EAX,EAX
     je @cll
     mov CL,[EAX]

     cmp CL,'P'         ; Ïàðàìåòð íà÷èíàåòüñÿ ñ "P" ñòðîêà.
     jne @pnS
     inc EAX
     push EAX
     jmp @lpl

   @pnS:
     cmp CL,'S'       ; ESP+ if int+ = 0 ESP to Buffe
     jne @pnC
     call GInt
     add ESP,EAX
     test EAX,EAX
     jz @lpl
     mov [Buffe],ESP
     jmp @lpl

   @pnC:
     cmp CL,'C'       ; copy [Buffe] to [Buffe]+
     jne @pnI
     call GInt
     lea ECX,[EAX+Buffe]
     mov EAX,[Buffe]
     mov [ECX],EAX
     jmp @lpl

   @pnI:
     cmp CL,'I'       ; input [ESP] to Buffe
     jne @pnR
     call GInt
     mov ECX,[ESP]
     mov [EAX+Buffe],ECX
     jmp @lpl

   @pnR:
     cmp CL,'R'        ; call ìóëòè.
     jne @pnA
     mov CL,[EAX+1]
     cmp CL,'P'        ;call printf
     jne .npP
     call [printf]
     jmp @nfc
   .npP:
     cmp CL,'E'
     jne .npE
     push [Buffe]
     call [exit]
     jmp @nfc
   .npE:
     cmp CL,'R'        ;relase steck
     jne .npR_
     mov ESP,EBP
     jmp @nfc
   .npR_:
     cmp CL,'S'  ;call [ESP]
     je .npS
     cmp CL,'A'   ;call [buffe+]
     je .npA
     cmp CL,'L'     ;Load Addres
     jne .npL
     inc EAX
     call GInt
     test EAX,EAX
     je @nfc
     mov ECX,[addr]
     mov [EAX+Buffe],ECX
     xor ECX,ECX
     jmp @nfc
   .npL:
     call GInt
     test EAX,EAX
     jne .npR
     cmp EBX,@nll
     je @nfc
     call EBX
   .ret:
     mov [Buffe],EAX
     jmp @nfc
   .npR:
     add EAX,Buffe
     call EAX
     jmp .ret
   .npS:
     inc EAX
     call GInt
     call dword[EAX+ESP]
     jmp .ret
   .npA:
     inc EAX
     call GInt
     call dword[EAX+Buffe]
     jmp .ret

   @pnA:
     cmp CL,'A'       ; [Buffe]+ â ñò¸ê.
     jne @pnT
     call GInt
     push dword[EAX+Buffe]
     jmp @lpl

   @pnT:
     cmp CL,'T'       ; Buffe+ â ñò¸ê.
     jne @pnL
     call GInt
     add EAX,Buffe
     push EAX
     jmp @lpl

   @pnL:
     cmp CL,'L'       ; load string length (ESP+4:length,ESP:string)
     jne @pnW
     inc EAX
     mov EDI,EAX
     mov ECX,[ESI]
     not EAX
     lea EAX,[ECX+EAX]
     push EAX
     push EDI
     jmp @lpl

   @pnW:
     cmp CL,'W'       ; Write to Buffe (ESP+4:length,ESP:string)
     jne @pnD
     mov ECX,[ESP+4]
     push ESI
     call GInt
     mov ESI,[ESP+4]
     lea EDI,[EAX+Buffe]
     rep  movsb
     pop ESI
     add ESP,8
     jmp @lpl

   @pnD:
     cmp CL,'D'       ; Debug OUT
     jne @pnd
     inc EAX
     push ESI
     push EDX
     mov ESI,EAX
     mov EDX,Buffe
     call @pot
     pop EDX
     pop ESI
     jmp @lpl

   @pnd:
     cmp CL,'d'
     jne @pno
     call GInt_
     and [Buffe],EAX
     jmp @lpl

   @pno:
     cmp CL,'o'
     jne @pna
     call GInt_
     or [Buffe],EAX
     jmp @lpl

   @pna:
     cmp CL,'a'
     jne @pns
     call GInt_
     add [Buffe],EAX
     jmp @lpl

   @pns:
     cmp CL,'s'
     jne @pnu
     call GInt_
     sub [Buffe],EAX
     jmp @lpl

   @pnu:
     cmp CL,'l'
     jne @pnr
     call GInt_
     mov CL,AL
     shl dword[Buffe],CL
     jmp @lpl

   @pnr:
     cmp CL,'r'
     jne @pnc
     call GInt_
     mov CL,AL
     shr dword[Buffe],CL
     jmp @lpl

   @pnc:
     cmp CL,'c'
     jne @pnm
     call GInt_
     mov EAX,[Buffe+EAX]
     mov [Buffe],EAX
     jmp @lpl

   @pnm:
     cmp CL,'m'
     jne @pnH
     call GInt_
     mov [Buffe],EAX
     jmp @lpl

     GInt_:
     inc EAX
     mov CL,[EAX]
     cmp CL,'s'
     jne .ns
     call GInt
     mov EAX,[ESP+EAX+4]
     jmp .end

     .ns:
     cmp CL,'b'
     jne .nb
     call GInt
     mov EAX,[Buffe+EAX]
     jmp .end

     .nb:
     dec EAX
     call GInt
     .end:
     ret

   @pnH:
     cmp CL,'H'       ; DATA to Hex format $00$01$02...
     jne @pnJ
     mov ECX,[ESP+4]
     jecxz .zer
     cmp ECX,65535
     ja .zer
     push ESI
     call GInt
     mov ESI,[ESP+4]
     lea EDI,[EAX+Buffe]
   .hh:
     xor EAX,EAX
     lodsb
     mov AH,AL
     and AL,0xf
     add AL,48
     cmp AL,58
     jb .h1
     add AL,7
   .h1:
     xchg AH,AL
     shr AL,4
     add AL,48
     cmp AL,58
     jb .h2
     add AL,7
   .h2:
     shl EAX,8
     mov AL,$24
     stosd
     dec EDI
     loop .hh
     pop ESI
   .zer:
     add ESP,8
     jmp @lpl

   @pnJ:                    ; JAMP
     cmp CL,'J'
     jne @pnl
     mov EDX,JMP_
     mov CL,[EAX+1]
     cmp CL,'E'
     jne .ne
     mov byte[EDX],$85
     jmp .j
   .ne:
     cmp CL,'A'
     jne .na
     mov byte[EDX],$87
     jmp .j
   .na:
     cmp CL,'B'
     jne .nb
     mov byte[EDX],$82
     jmp .j
   .nb:
     cmp CL,'G'
     jne .ng
     mov byte[EDX],$8F
     jmp .j
   .ng:
     cmp CL,'L'
     jne .nl
     mov byte[EDX],$8C
     jmp .j
   .nl:
     cmp CL,'N'
     jne .nn
     mov byte[EDX],$84
   .j:
     inc EAX
     add ESP,8
     mov ECX,[ESP-4]
     cmp ECX,[ESP-8]
     JMP_ = $+1
     je @lpl
   .nn:
     call GInt
     lea ESI,[ESI+EAX*4]
     jmp @lpl


   @pnl:
     dec EAX                 ; ÷èñëî.
     call GInt
     push EAX
     jmp @lpl  
       
   @cll:
     call EBX

   @nll:
     lea ESI,[EBP+12]
     mov EDX,Buffe
     mov dword[EDX],EAX

     cmp byte[ESI],'-'
     jne @orp
     inc ESI
     push @orp

   @pot:
     lodsb
     test AL,AL
     je @edb
     mov EDI,Print+1
     
     cmp AL,'s'              ; ñòðîêà.
     jne .nstr
     mov byte[EDI],AL
     call getInt
     add EDX,EAX
     mov EAX,EDX
     call OutPar
     jmp @pot
   .nstr:

     cmp AL,'t'              ; addr ñòðîêè.
     jne .ntnt
     mov byte[EDI],'s'
     jmp .intg
   .ntnt:

     cmp AL,'c'              ; çíàê.
     jne .ncha
     mov byte[EDI],AL
     call getInt
     add EDX,EAX
     movzx EAX,byte[EDX]
     call OutPar
     jmp @pot
   .ncha:

     cmp AL,'i'              ; ñî çíàêîì.
     jne .nint
     mov byte[EDI],AL
     jmp .intg
   .nint:

     cmp AL,'a'              ; ñî çíàêîì.
     jne .nant
     mov byte[EDI],AL
     jmp .intg
   .nant:

     cmp AL,'x'              ; ñî çíàêîì.
     jne .nxnt
     mov byte[EDI],AL
     jmp .intg
   .nxnt:

     cmp AL,'X'              ; ñî çíàêîì.
     jne .nXnt
     mov dword[EDI-1],'0x%X'
     mov dword[EDI+3],32
     jmp .intg
   .nXnt:

     cmp AL,'u'              ; áåç çíàêà
     jne @smi
     mov byte[EDI],AL

   .intg:
     call getInt
     add EDX,EAX
     mov EAX,[EDX]
     call OutPar
     mov dword[Print],'%i '
     jmp @pot

   @smi:
     dec ESI
     call getInt
     test EAX,EAX
     jne .plc
     inc ESI
     jmp @pot
   .plc:
     add EDX,EAX
     jmp @pot
     
   @edb:
     ret

   @orp:
     mov ESP,EBP
     mov EAX,[Buffe]
     push EAX
     call [exit]

    OutPar:
      push EDX
      push EAX
      push Print
      call [printf]
      add ESP,8
      pop EDX
      ret

    GInt:
      push ESI
      lea ESI,[EAX+1]
      call getInt
      pop ESI
      ret
        
      getInt:                
      push EDX
      push EBX
      xor EBX,EBX
      xor EDX,EDX
      cmp byte[ESI],'-'
      jne @1
      not EBX
      inc ESI
    @1:
      xor EAX,EAX
      lodsb
      sub AL,48
      cmp AL,9
      ja @2
      lea EDX,[EDX*4+EDX]
      shl EDX,1
      add EDX,EAX
      jmp @1
    @2:
      mov EAX,EDX
      dec ESI
      test EBX,EBX
      jz @3
      neg EAX
    @3:
      pop EBX
      pop EDX
      ret

interpreter '/lib/ld-linux.so.2'

needed 'libc.so.6','libdl.so.2'
import printf,exit,dlopen,dlsym

align 4
Print db '%i ',0,0,0,0,0
Commb rd 400h
lib   rd 1
addr  rd 1
prin_ rd 1

Buffe rd 20000h
