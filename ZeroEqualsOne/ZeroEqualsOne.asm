 include "..\..\ti83plus.inc"

_EnableCxM_HomeHook equ 4FABh 

 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "One=Zero"
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
	B_CALL EnableCxM_HomeHook

	B_JUMP JForceCmdNoChar

 hook:
 	add a, e

	push de
	push hl
	push bc
	push af
	;get current context
	ld hl, cxCurApp
	ld a, (hl)
	cp cxCmd ;home screen
	jr nz, endofhook

	pop de
	ld a, d
	;check to see if parse finished (and there is the result in OP1)
	cp 00h
	push de
	jr nz, endofhook

	;result of calculation waiting on OP1
	;test if OP1=0
	ld a, 00h
	b_call SetXXOP2
	b_call CpOP1OP2
	jr z, SetResultOne ;result = 0

	;test if OP1=1
	ld a, 01h
	b_call SetXXOP2
	b_call CpOP1OP2
	jr z, SetResultZero ;result = 1

endofhook:
	pop af
	pop bc
	pop hl
	pop de
	xor a ;set zero flag
	ret
SetResultOne:
	ld a, 01h
	b_call SetXXOP1
	jr endofhook

SetResultZero:
	ld a, 00h
	b_call SetXXOP1
	jr endofhook
