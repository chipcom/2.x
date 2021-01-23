#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

#include "tbox.ch"

function kslp(k,r,c)
    Local mlen, t_mas := {}, ret, ;
          i, tmp_color := setcolor(),;
          tmp_select := select(), r1, a_uch := {}

    Local m1var := '', s := "", countKSLP := 0
    local oBox
    // 1 ? ��������� ��祭�� ��樥��, �易���� � �����⮬ (��� 75 ��� � ����) (� ⮬ �᫥, ������ ��������� ���-��ਠ��);
    // 3 - �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫� (��� �� 4 ���, ��� ���� 4 ��� �� ����稨 ����樭᪨� ���������);
    // 4 - �஢������ ��ࢮ� ���㭨��樨 ��⨢ �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� ��䥪樨 � ��ਮ� ��ᯨ⠫���樨 �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� ��ਮ��, ������ ���������� � ���㭨��樨;
    // 5 - �������뢠��� �������㠫쭮�� ����;
    // 6 - �஢������ ��⠭��� ���ࣨ�᪨� ����⥫���;
    // 7 - �஢������ ����⨯��� ����権 �� ����� �࣠���;
    // 8 - �஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠�������;
    // 9 - ����稥 � ��樥�� �殮��� ᮯ������饩 ��⮫����, �᫮������ �����������, ᮯ�������� �����������, ������� �� ᫮������ ��祭�� ��樥�� (���祭� 㪠������ ����������� � ���ﭨ�;
    // 10 - ����夫�⥫�� �ப� ��ᯨ⠫���樨, ���᫮������ ����樭᪨�� ��������ﬨ

    aadd(t_mas, { '   ' + ' 1-�易���� � �����⮬ (��� 75 ��� � ����) (� ⮬ �᫥, ������ ��������� ���-��ਠ��)', .f. })
    aadd(t_mas, { '   ' + ' 3-�।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫� (��� �� 4 ���, ��� ���� 4 ��� �� ����稨 ����樭᪨� ���������)', .f. })
    aadd(t_mas, { '   ' + ' 4-�஢������ ��ࢮ� ���㭨��樨 ��⨢ �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� ��䥪樨 � ��ਮ� ��ᯨ⠫���樨 �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� ��ਮ��, ������ ���������� � ���㭨��樨', .t. })
    aadd(t_mas, { '   ' + ' 5-�������뢠��� �������㠫쭮�� ����', .t. })
    aadd(t_mas, { '   ' + ' 6-�஢������ ��⠭��� ���ࣨ�᪨� ����⥫���', .t. })
    aadd(t_mas, { '   ' + ' 7-�஢������ ����⨯��� ����権 �� ����� �࣠���', .t. })
    aadd(t_mas, { '   ' + ' 8-�஢������ ��⨬��஡��� �࠯�� ��䥪権, �맢����� ����१��⥭�묨 ���ம࣠�������', .t. })
    aadd(t_mas, { '   ' + ' 9-����稥 � ��樥�� �殮��� ᮯ������饩 ��⮫����, �᫮������ �����������, ᮯ�������� �����������, ������� �� ᫮������ ��祭�� ��樥�� (���祭� 㪠������ ����������� � ���ﭨ�', .t. })
    aadd(t_mas, { '   ' + '10-����夫�⥫�� �ப� ��ᯨ⠫���樨, ���᫮������ ����樭᪨�� ��������ﬨ', .t. })

    status_key("^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - ᬥ�� ��樨 ⥪�饩 ����ୠ⨢�")

    mlen := len(t_mas)

    // oBox := TBox():New(4,18,16,63)
    // oBox:View()

    // �ᯮ��㥬 popupN �� ������⥪� FunLib
    // if (ret := popupN(5,19,15,62,t_mas,i,color0,.t.,"fmenu_reader",,;
    if (ret := popupN(5,19,15,62,t_mas,i,color0,.t.,"fmenu_readerN",,;
        "�⬥��� ����",col_tit_popup,,,{.f.,.f.,.f.,.t.,.t.,.f.,.t.,.f.,.f.})) > 0
        for i := 1 to mlen
            if "*" == substr(t_mas[i, 1],2,1)
                // k := chr(int(val(right(t_mas[i],10))))
                // m1var += k
                m1var += '1'
                countKSLP += 1
            else
              m1var += '0'
            endif
        next
        // s := "= "+lstr(len(m1var))+"�᫯. ="
        alertx(countKSLP)
        s := "= "+alltrim(str(countKSLP))+"�᫯. ="
    endif

    Select(tmp_select)

    @ 4, 10 say m1var picture '999999999999999'

Return iif(ret==0, NIL, {m1var,s})

Function inp_bit_otd__(k,r,c)
    Local mlen, t_mas := {}, buf := savescreen(), ret, ;
          i, tmp_color := setcolor(), m1var := "", s := "",;
          tmp_select := select(), r1, a_uch := {}
    mywait()
    R_Use(dir_server+"mo_uch",,"LPU")
    dbeval({|| iif(between_date(lpu->dbegin,lpu->dend,sys_date), ;
                   aadd(a_uch,lpu->(recno())), nil) })
    R_Use(dir_server+"mo_otd",,"OTD")
    set relation to kod_lpu into LPU
    dbeval({|| s := if(chr(recno()) $ k," * ","   ")+;
                    padr(otd->name,30)+" "+padr(lpu->short_name,5)+str(recno(),10),;
               aadd(t_mas,s);
           },;
           {|| between_date(otd->dbegin,otd->dend,sys_date) .and. ;
               ascan(a_uch,otd->kod_lpu) > 0 };
          )
    otd->(dbCloseArea())
    lpu->(dbCloseArea())
    if tmp_select > 0
      select(tmp_select)
    endif
    mlen := len(t_mas)
    asort(t_mas,,,{|x,y| if(substr(x,35,5) == substr(y,35,5), ;
                              (substr(x,4,30) < substr(y,4,30)), ;
                              (substr(x,35,5) < substr(y,35,5))) } )
    i := 1
    status_key("^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - ᬥ�� ��樨 ⥪�饩 ����ୠ⨢�")
    if (r1 := r-1-mlen-1) < 2
      r1 := 2
    endif
    if (ret := popup(r1,19,r-1,62,t_mas,i,color0,.t.,"fmenu_reader",,;
                     "� ����� �⤥������ ࠧ�蠥��� ���� ��㣨",col_tit_popup)) > 0
      for i := 1 to mlen
        if "*" == substr(t_mas[i],2,1)
          k := chr(int(val(right(t_mas[i],10))))
          m1var += k
        endif
      next
      s := "= "+lstr(len(m1var))+"��. ="
    endif
    restscreen(buf)
    setcolor(tmp_color)
    Return iif(ret==0, NIL, {m1var,s})
    