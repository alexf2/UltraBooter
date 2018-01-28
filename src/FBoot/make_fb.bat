tasm /ml /m3 /q /e     fboot.asm   > f_asm
tlink /C /c /m /s /n  fboot.obj     > f_lnk
exe2bin fboot.exe fboot.bin
