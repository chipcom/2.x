c:\Harbour\bin\hbmk2 chip_mo_bay.hbp
copy chip_mo.exe d:\_mo\_arc
copy *.shb  d:\_mo\_arc
copy *.frm  d:\_mo\_arc
copy *.fr3  d:\_mo\_arc
copy *.xls  d:\_mo\_arc
copy chip_mo.exe d:\_mo\chip\exe

if exist d:\_mo\_build\chip_mo.rar del d:\_mo\_build\chip_mo.rar
copy d:\_mo\_arc\readme.rtf d:\_mo\_build\readme.rtf
C:\"Program Files"\WinRAR\Rar.exe a -ep d:\_mo\_build\chip_mo @d:\_mo\2.x\chip_mo_bay.lst
