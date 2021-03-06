set ISE_VER=14.7

REM mira si es correcta la localitzacio del ISE
if NOT "%XILINX%" == "C:\Xilinx\%ISE_VER%\ISE_DS\ISE" GOTO CHECK64
GOTO CREATE_MFS

REM mira si realment es 64 bits i esta al lloc on toca
:CHECK64
if NOT "%PROCESSOR_ARCHITECTURE%" == "AMD64" GOTO SET32
call C:\Xilinx\%ISE_VER%\ISE_DS\settings64.bat
GOTO CREATE_MFS

REM si no es 64 bits nomes pot ser 32
:SET32
call C:\Xilinx\%ISE_VER%\ISE_DS\settings32.bat
GOTO CREATE_MFS

REM crea la imatge per la pagina web
:CREATE_MFS
mfsgen -cvbf ./image.mfs 3000 css images js yui index.html xapp1026.pdf
REM mfsgen -cvbf ./image.mfs 16 css index.html
GOTO DO_BATCH

REM si ha detectat el ISE correctament i la imatge ja ha estat creada
:DO_BATCH
@echo setMode -bscan															>  configuracio_batch_impact.cmd
@echo setCable -target "digilent_plugin DEVICE=SN:000000000000 FREQUENCY=-1"	>> configuracio_batch_impact.cmd
@echo identify																	>> configuracio_batch_impact.cmd
@echo assignfile -p 1 -file download.bit										>> configuracio_batch_impact.cmd
@echo program -p 1																>> configuracio_batch_impact.cmd
@echo quit																		>> configuracio_batch_impact.cmd
GOTO CONNECT

REM un cop ja ha carregat el bootloop a la Spartan6

REM connect mb mdm -port COMx -baud 115200 -timeout 5 -cable type digilent_plugin

:CONNECT
impact -batch configuracio_batch_impact.cmd
sleep 3
@echo connect mb mdm -cable type digilent_plugin	>  xmd.ini
@echo rst											>> xmd.ini
@echo dow -data image.mfs 0xA5000000				>> xmd.ini
@echo dow raw_apps.elf								>> xmd.ini
@echo run											>> xmd.ini
@echo exit											>> xmd.ini

xmd

:EOF
