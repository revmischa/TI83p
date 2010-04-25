 include "..\..\ti83plus.inc"
 globals on

ImageStorage EQU appBackUpScreen

 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "Remote", 000h, 000h
 db 080h, 081h
 db 001h
 db 080h, 090h
 db 003h, 026h, 009h, 004h
 db 00Dh, 02Ch, 025h, 03Ch
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

 ei
 b_call ClrLCDFull

 call SplashScreen

 call GetScreenShot
MainKeyLoop:
	ei
	halt

	res indicOnly, (IY + indicFlags)
	res indicRun, (IY + indicFlags)

	b_call GetKey
	ld b, a
	cp kLinkIO
	jr z, TheEnd
	
	call SendByteage
	ei
	halt
	call GetScreenShot

	jr MainKeyLoop

TheEnd:
	b_call ClrLCDFull
	b_jump JForceCmdNoChar

GetScreenShot: ;send $03,$6D,$00,$00
	ld a, 03h
	b_call SendAByte
	ld a, 6Dh
	b_call SendAByte
	ld a, 00h
	b_call SendAByte
	ld a, 00h
	b_call SendAByte

	;receive $83,$56,$00,$00
	call Rec4Bytes

	ld hl, ImageStorage

	;receive some random stuff about data structure or whatever
	;the scree dump sends before the stuff we care aboot
	call Rec4Bytes

	;receive 768 bytes
	ld bc, 768
	push bc
	ReceiveLoop:
		pop bc
		ld a, c
		or b
		cp 00h
		jr z, ReceiveLoopEnd
		dec bc
		push bc

		push hl
		b_call RecAByteIO

		;display progress bar
		b_call ZeroOP2
		pop bc
		ld h, b
		ld l, c
		push bc
		b_call SetXXXXOP2
		b_call OP1ToOP2
		ld hl, 768
		b_call SetXXXXOP2 ;now OP1=bc, OP2=768
		b_call FPDiv ;OP1 = bc/768

 		ld hl, 95
		b_call SetXXXXOP2
		b_call FPMult ;OP1 = number of pixels across the progress bar to be
		b_call Int ;OP1 is an integer now
		b_call ConvOP1 ;stash OP1 into DE
		;ld a, d
		;ld b, e ;stash de into hl
		
		;fill the progress bar rect from (h,l) to (d,e)
		ld h, 60
		ld l, 0
		ld d, 63
		;ld e, 63
		b_call FillRect

		pop hl

		ld (hl), a

		inc hl

		jr ReceiveLoop
	ReceiveLoopEnd:

	ld hl, ImageStorage
	b_call BufCpy

	halt
	b_call RecAByteIO
	b_call RecAByteIO

	ld a, 03h ;send $03,$56,$00,$00
	b_call SendAByte
	ld a, 56h
	b_call SendAByte
	ld a, 00h
	b_call SendAByte
	ld a, 00h
	b_call SendAByte

	ret

SendByteage: ;sends a keypress/instruction byte to another calc (the value of b)
	push bc 		; save b for later because b is mercelessly slaughtered
					; by SendAByte
	ld a, 83h
	b_call SendAByte
	ld a, 87h
	b_call SendAByte

	pop bc
	ld a, b
	b_call SendAByte

	ld a, 00h
	b_call SendAByte

	call Rec4Bytes
	call Rec4Bytes

	ret
Rec4Bytes:
	;receive 4 bytes
	b_call RecAByteIO
	b_call RecAByteIO
	b_call RecAByteIO
	b_call RecAByteIO

	ret

SplashScreen:
	res fracDrawLFont, (IY + fontFlags)	;small font

	xor a
   ld (penCol),a
   ld a, 0
   ld (penRow),a
	ld hl, SplashStr1
	call DrawString

	xor a
   ld (penCol),a
   ld a, 8
   ld (penRow),a
	ld hl, SplashStr2
	call DrawString

	xor a
   ld (penCol),a
   ld a, 16
   ld (penRow),a
	ld hl, SplashStr3
	call DrawString

	xor a
   ld (penCol),a
   ld a, 24
   ld (penRow),a
	ld hl, SplashStr4
	call DrawString

	xor a
   ld (penCol),a
   ld a, 32
   ld (penRow),a
	ld hl, SplashStr5
	call DrawString

	ei
	keyloop:
		halt
		b_call GetKey
		cp 00h
		jr z, keyloop

	xor a
   ld (penCol),a
	ld a, 48
   ld (penRow),a
	ld hl, PleaseWait
	call DrawString

	ret

DrawString:
	ld de, OP1
	b_call StrCopy
	ld hl, OP1
	b_call VPutS
	ret
   
SplashStr1 .asciz "This App controls another"
SplashStr2 .asciz "calculator through a link"
SplashStr3 .asciz "cable."
SplashStr4 .asciz "Press 2nd+Link to quit."
SplashStr5 .asciz "Press any key to start."
PleaseWait .asciz "Connecting... Please Wait"
