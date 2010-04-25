 include "..\..\ti83plus.inc"

_EnableGraphingHook equ 4FEA
 
 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "GrafHook"
 db 080h, 081h
 db 001h
 db 080h, 090h
 db 003h, 026h, 009h, 004h
 db 00Eh, 0A7h, 0AFh, 08Bh
 db 002h, 00Dh, 040h, 0A1h, 06Bh, 099h, 0F6h, 059h, 0BCh, 067h
 db 0F5h, 085h, 09Ch, 009h, 06Ch, 00Fh, 0B4h, 003h, 09Bh, 0C9h
 db 003h, 032h, 02Ch, 0E0h, 003h, 020h, 0E3h, 02Ch, 0F4h, 02Dh
 db 073h, 0B4h, 027h, 0C4h, 0A0h, 072h, 054h, 0B9h, 0EAh, 07Ch
 db 03Bh, 0AAh, 016h, 0F6h, 077h, 083h, 07Ah, 0EEh, 01Ah, 0D4h
 db 042h, 04Ch, 06Bh, 08Bh, 013h, 01Fh, 0BBh, 093h, 08Bh, 0FCh
 db 019h, 01Ch, 03Ch, 0ECh, 04Dh, 0E5h, 075h
 db 080h, 07Fh
 db 000h, 000h, 000h, 000h
 db 000h, 000h, 000h, 000h
 db 000h, 000h, 000h, 000h
 db 000h, 000h, 000h, 000h
 db 000h, 000h, 000h, 000h

  StartApp:
 	b_call ClrLCDFull

	in a, (6)
	ld hl, hook
	b_call EnableGraphingHook

	b_jump JForceCmdNoChar

 hook:
 	add a, e

	push de
	push hl
	push bc
	push af

	cp 4 ;just evaluated a point
	jr nz, endofhook

	;OP1 is the X coordinate after evaluation. OP2 is the Y coordinate after evaluation

	;save op2
	ld hl, OP2
	ld de, savesscreen
	ld bc, 16
	ldir

	;save op3
	ld hl, OP3
	ld de, savesscreen+16
	ld bc, 16
	ldir

	b_call Minus1

	;save op1
	ld hl, OP1
	ld de, savesscreen+32
	ld bc, 16
	ldir

	b_call OP3ToOP1
	b_call Minus1
	b_call OP1ToOP3

	b_call OP5ToOP1
	b_call Minus1
	b_call OP1ToOP5

	;restore op1
	ld hl, savesscreen+32
	ld de, OP1
	ld bc, 16
	ldir

	;restore op2
	ld hl, savesscreen
	ld de, OP2
	ld bc, 16
	ldir

	;restore op3
	;ld hl, savesscreen+16
	;ld de, OP3
	;ld bc, 16
	;ldir

	;b_call InvOP2S

endofhook:
	pop af
	pop bc
	pop hl
	pop de
	xor a
	ret

	
  include "..\..\filler.txt"
