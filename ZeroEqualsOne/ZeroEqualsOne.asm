 include "..\ti83plus.inc"

 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "KeyHook", 000h
 db 080h, 081h
 db 001h
 db 080h, 090h
 db 003h, 026h, 009h, 004h
 db 00Ch, 006h, 01Eh, 029h
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

 ;

;

;   this will handle turning off, battery pulls & GOTO's on errors
;
;****************************************************
;			Equates
;****************************************************
intrptEnPort	equ 3 ; interrupt enable (in/out) 
_ClrCursorHook	equ 4F69h
;_PutAway		equ 403Ch
_LCD_DRIVERON 	equ 4978h 
onFlags 		equ 9 ;on key flags 
onRunning 		equ 3 ; 1=calculator is running 
iall equ 1011b
_AppInit		equ 404Bh
;
;
;

StartApp:
    ld      hl,AppVectors
    b_call  AppInit          ; install monitor vectors to catch putaways
;
    b_call RunIndicOff
;
;   I set an error handler so that if somehow the system displays an error
;   I can block the 'GOTO' option from being given.
;
;   quitSP is some ram location defined by the app writer 2 bytes
;
;   If you do this then when you exit your app from a 'QUIT' option

;   the stack level must be what it is at immediately following
;   the 'AppOnErr' macro below:
;
;    AppOnErr  NoGoTo
;
;    ld      (quitSP),sp      ; save sp so can do appofferr safely
;
;
;   execute your application
;
;

KeyLoop:
	EI
	HALT
	B_CALL GetCSC
	cp skClear
	jr nz, KeyLoop
	
	B_JUMP JForceCmdNoChar
;

;
;   This is exitting the app by the USERS CHOICE from selecting a
;   quit option in the main loop of your app
;
;   If the 'AppOnErr' was done at the start of the app then the
;   stack MUST be at the level immediately after the execution
;   of the 'AppOnErr' in order for the 'AppOffErr' below to work
;   properly.

;
;QUITApp:
;    ld      sp,(quitSP)      ; restore sp so can do appofferr safely
;    AppOffErr                ; remove error handler to kill GOTO's
;
;
;   This entry point is entered in the MON VECTOR table set up at
;   the start of the app.
;
;
AppPutaway:
    res     plotLoc,(IY+plotFlags)      ; draws to display & buffer
    res     textWrite,(IY+sGrFlags)     ; small font written to dispaly
;
    b_call  ReloadAppEntryVecs          ; reload MON VECTORS with app loaders
;
    ld      (IY+textFlags),0
;
    bit     monAbandon,(IY+monFlags)    ; Is calc being turned off ?
    jr      nz, turningOff                ; jump if turning off
;

    ld      a,iall
    out     (intrptEnPort),a
    b_call  LCD_DRIVERON
    set     onRunning,(IY+onFlags)
    ei
;
    b_jump  JForceCmdNoChar
;

turningOff:
    b_jump  PutAway                     ; don't switch to home screen
;                                       ; just do putaway of app

rawkeyHand:
dummy:
    ret


;


;   app's MON VECTOR table

;

AppVectors:
    dw      dummy
    dw      dummy
    dw      AppPutaway
    dw      dummy
    dw      dummy
    dw      dummy
    db      0



; From 83psysroutines.pdf:

;Monitor vector table format:

;VecTab: 
;	DW CXMainPtr
;	DW CXPPutAwayPtr
;	DW CXPutAwayPtr
;	DW CXRedispPtr
;	DW CXErrorEPPtr
;	DW CXSizeWindPtr
;	DB AppFlagsByte



;
;
;   system error is being generated, kill the GOTO option.

;

;

NoGoTo:
    push    af
;
;   turning of the cursor hook is optional if you need to do it
;

    b_call  ClrCursorHook
;
    res     curAble,(IY+curFlags)
    pop     af
    res     e_editf,a
    b_jump  JError
