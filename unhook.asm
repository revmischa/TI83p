;;removes all hooks


 include "..\..\ti83plus.inc"

 db 080h, 00Fh
 db 000h, 000h, 000h, 000h
 db 080h, 012h
 db 001h, 004h
 db 080h, 021h
 db 001h
 db 080h, 031h
 db 001h
 db 080h, 048h
 db "Unhook", 000h, 000h
 db 080h, 081h
 db 001h
 db 080h, 090h
 db 003h, 026h, 009h, 004h
 db 00Eh, 0A1h, 044h, 06Ah
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


_DisableRawKeyHook equ 4F6Fh
_DisableTokenHook equ 4F9Ch
_DisableCxM_ModeHook equ 504Dh 
_DisableSilentLinkHook equ 4F69h
_DisableFontHook equ 4FE7h 
_DisableCharacterHook equ 4FAEh
_DisableLinkAssistHook equ 4F87h 
_DisableGetKeyHook equ 4F7Eh 
_DisableGraphingHook equ 4FEDh 

 StartApp:
 	B_CALL ClrLCDFull

	B_CALL DisableRawKeyHook
	B_CALL DisableTokenHook
	B_CALL DisableCxM_ModeHook
	B_CALL DisableSilentLinkHook
	B_CALL DisableFontHook
	B_CALL DisableCharacterHook
	B_CALL DisableLinkAssistHook
	B_CALL DisableGetKeyHook
	B_CALL DisableGraphingHook

	B_JUMP JForceCmdNoChar


  include "..\..\filler.txt"
