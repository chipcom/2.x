echo #DEFINE _DATA_VER + "%DATE%" > ver_date.ch
c:\Harbour\bin\hbmk2 chip_mo.hbp -comp=mingw
copy chip_mo.exe d:\_mo\_arc
copy *.shb  d:\_mo\_arc
copy *.frm  d:\_mo\_arc
copy *.fr3  d:\_mo\_arc
copy *.xls  d:\_mo\_arc
copy *.xlsx  d:\_mo\_arc
copy *.ttf  d:\_mo\_arc
copy chip_mo.exe d:\_mo\chip\exe
copy *.shb  d:\_mo\chip\exe
copy *.frm  d:\_mo\chip\exe
copy *.fr3  d:\_mo\chip\exe
copy *.xls  d:\_mo\chip\exe
copy *.xlsx  d:\_mo\chip\exe
copy *.ttf  d:\_mo\chip\exe
copy d:\_mo\_arc\*.dbf  d:\_mo\chip\exe
copy d:\_mo\_arc\*.dbt  d:\_mo\chip\exe

if exist d:\_mo\_build\chip_mo.rar del d:\_mo\_build\chip_mo.rar
copy d:\_mo\DOC\readme.rtf d:\_mo\_arc
copy d:\_mo\DOC\readme.rtf d:\_mo\_build\readme.rtf
C:\"Program Files"\WinRAR\Rar.exe a -ep d:\_mo\_build\chip_mo @d:\_mo\2.x\chip_mo.lst
copy d:\_mo\_build\chip_mo.rar d:\_mo\_build\KVD\chip_mo.rar
