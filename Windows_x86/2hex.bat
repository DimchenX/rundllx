@set /a BUF=1024*32
@set /a BUFa=%BUF%+512
@rundllx kernel32 _lopen 0 P%1 R kernel32 _lread %BUF% T32 A R A T32 H%BUFa% Ds%BUFa%> %1.hex
@pause