 include "..\..\ti83plus.inc"

_EnableCharacterHook equ 4F93h

 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "CharHook"
 db 080h, 081h
 db 001h
 db 080h, 090h
 db 003h, 026h, 009h, 004h
 db 00Ch, 09Dh, 0B7h, 0FCh
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
 	B_CALL ClrLCDFull

	IN a, (6)
	LD hl, hook
	B_CALL EnableCharacterHook

	B_JUMP JForceCmdNoChar

 hook:
 	add a, e

	push de
;	push hl
	push bc
	push af

	;only modify if large font (a=76h)
	cp 76h
	jr nz, endofhook
	
;	pop hl
	;add 8 to HL
	ld a, 8
	add a,l
	ld l, a
;	push hl

endofhook:
	pop af
	pop bc
;	pop hl
	pop de
	ld a,1
	;xor a ;set zero flag
	ret
	
  include "..\..\filler.txt"
