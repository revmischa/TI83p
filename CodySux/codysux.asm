 include "..\..\ti83plus.inc"

_EnableTokenHook equ 4F99h

tokenHookPtr equ 9BC8h 

StringStorage equ 86ECh

 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "Cody Sux"
 db 080h, 081h
 db 001h
 db 080h, 090h
 db 003h, 026h, 009h, 004h
 db 00Eh, 037h, 0B8h, 03Fh
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

 ProgramStart:
	b_call ClrLCDFull

	in a, (06)
	ld hl, TokenHook
	b_call EnableTokenHook

	call reset

	b_jump JForceCmdNoChar

TokenHook:
	add a,e

	push af
	push de

	ld hl, thenumberone 	;pointer to length of token string
	ld de, StringStorage	;stash at beginning
	call LoadAByteToStringLand

  	ld a,(tokenHookPtr+3)
  	inc a
  	ld (tokenHookPtr+3),a
  	cp 07 ;length of codysux
	jr nz, noreset
	
	;reset to 0
	call reset

noreset:

	ld hl, codysux

	;add a to hl
addloop:
	cp 0
	jr z, addloopend
	inc hl
	dec a
	jr addloop
addloopend:

	ld de, StringStorage+1	;store after the first byte (length)
	call LoadAByteToStringLand

	pop de
	ld d, 1
	ld hl, StringStorage-1

	pop af
	ret

reset:
	ld a, 0
	ld (tokenHookPtr+3), a
	ret

codysux:
 db "codysux"

LoadAByteToStringLand
	;in: 	hl=location of byte on flash rom page
	;		de=location to stash byte
	in a, (06)
	ld bc, 1
	b_call FlashToRam
	ret

thenumberone:
 db 1

  include "..\..\filler.txt"
