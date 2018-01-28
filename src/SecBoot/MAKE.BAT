tasm /D__TINY__ /D__CDECL__ /ml /m3 /q /e /l     sload.asm + drvfunc.asm + gensel.asm + int_13.asm   > m_asm
tlink /C /c /m /s /n     sload.obj  drvfunc.obj gensel.obj int_13.obj, mfunc, , cs.lib   > m_lnk
exe2bin mfunc.exe mfunc.bin
