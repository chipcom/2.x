***** mo_omsna.prg - ��ᯠ��୮� �������
#include "inkey.ch"
#include "..\_mylib_hbt\fastreph.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch  := 1

***** 28.11.18 ���樠������ ��� 䠩��� ���.ᮯ஢������� �� ��ᯠ��ਧ�樨
Function f_init_d01()
Local mo_dnab := {; // ��ᯠ��୮� �������
   {"KOD_K",    "N", 7,0},; // ��� �� ����⥪�
   {"VRACH",    "N", 4,0},; // ���騩 ���
   {"PRVS",     "N", 9,0},; // ���樠�쭮��� ��� �� �ࠢ�筨�� V004, � ����ᮬ - �� �ࠢ�筨�� V015
   {"KOD_DIAG" ,"C", 5,0},; // ������� �����������, �� ������ ���ண� ��樥�� �������� ��ᯠ��୮�� �������
   {"N_DATA"   ,"D", 8,0},; // ��� ��砫� ��ᯠ��୮�� �������
   {"NEXT_DATA","D", 8,0},; // ��� � � 楫�� ��ᯠ��୮�� �������
   {"MESTO",    "N", 1,0};  // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
  }
Local mo_d01 := {; // ���뫠��� 䠩�� D01
   {"KOD",         "N", 6,0},; // ��� ॥��� (����� �����)
   {"DSCHET",      "D", 8,0},; // ��� 䠩��
   {"NYEAR",       "N", 4,0},; // ����� ���
   {"MM",          "N", 2,0},; // ����� �����
   {"NN",          "N", 3,0},; // ���浪��� ����� �����;����� �� ���浪� ����� � ������ ���⭮� ��ਮ�� (3 ����� � �������騬 �㫥�);
   {"NAME_XML",    "C",26,0},; // ��� XML-䠩�� ��� ���७�� (� ZIP-��娢�)
   {"KOD_XML",     "N", 6,0},; // ��뫪� �� 䠩� "mo_xml"
   {"DATE_OUT",    "D", 8,0},; // ��� ��ࠢ�� � �����
   {"NUMB_OUT",    "N", 2,0},; // ᪮�쪮 ࠧ �ᥣ� �����뢠�� 䠩� �� ���⥫�;
   {"ANSWER",      "N", 1,0},; // 0-�� �뫮 �⢥�, 1-����祭 �⢥� (D02)
   {"KOL",         "N", 6,0},; // ������⢮ ��樥�⮢ � ॥���/䠩��
   {"KOL_ERR",     "N", 6,0};  // ������⢮ ��樥�⮢ � �訡���� � ॥���
  }
Local mo_d01k := {; // ᯨ᮪ ��樥�⮢ � ॥����
   {"REESTR",   "N", 6,0},; // ��� ॥��� �� 䠩�� "mo_d01"
   {"KOD_K",    "N", 7,0},; // ��� �� ����⥪�
   {"D01_ZAP",  "N", 6,0},; // ����� ����樨 ����� � ॥���;"ZAP" � D01
   {"ID_PAC",   "C",36,0},; // GUID ��樥�� � D01 (ᮧ������ �� ���������� �����)
   {"MESTO",    "N", 1,0},; // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
   {"OPLATA",   "N", 1,0};  // ⨯ ������: ᭠砫� 0, ��⥬ �� ����� 1,2,3,4
  }
Local mo_d01d := {; // ᯨ᮪ ��������� ��樥�⮢
   {"KOD_D",    "N", 6,0},; // ��� (����� �����) �� 䠩�� "mo_d01k"
   {"PRVS",     "N", 4,0},; // ���樠�쭮��� ��� �� �ࠢ�筨�� V021
   {"KOD_DIAG" ,"C", 5,0},; // ������� �����������, �� ������ ���ண� ��樥�� �������� ��ᯠ��୮�� �������
   {"N_DATA"   ,"D", 8,0},; // ��� ��砫� ��ᯠ��୮�� �������
   {"NEXT_DATA","D", 8,0};  // ��� � � 楫�� ��ᯠ��୮�� �������
  }
Local mo_d01e := {; // ᯨ᮪ �訡�� � ॥���� ����� ��ᯠ��ਧ�権
   {"REESTR",   "N", 6,0},; // ��� ॥���;�� 䠩�� "mo_d01"
   {"D01_ZAP",  "N", 6,0},; // ����� ����樨 ����� � ॥���;"ZAP") � D01
   {"KOD_ERR",  "N", 3,0};  // ��� �訡�� ��
  }
reconstruct(dir_server+"mo_d01", mo_d01 ,,,.t.)
reconstruct(dir_server+"mo_d01k",mo_d01k,,,.t.)
reconstruct(dir_server+"mo_d01d",mo_d01d,,,.t.)
reconstruct(dir_server+"mo_d01e",mo_d01e,,,.t.)
reconstruct(dir_server+"mo_dnab",mo_dnab,"index_base('mo_dnab')",,.t.)
//index on str(KOD_K,7)+KOD_DIAG to (dir_server+"mo_dnab")
return NIL

***** 22.08.19 ��ᯠ��୮� �������
Function disp_nabludenie(k)
Static si1 := 1, si2 := 1, si3 := 2, si4 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    Private file_form, mdate_r, M1VZROS_REB, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      return func_error(4,"�� �����㦥� 䠩� DISP_NAB"+sfrm)
    endif
    mas_pmt := {"��ࢨ�� ~����",;
                "~���ଠ��",;
                "~����� � �����"}
    mas_msg := {"��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��",;
                "���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����",;
                "����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������"}
    mas_fun := {"disp_nabludenie(11)",;
                "disp_nabludenie(12)",;
                "disp_nabludenie(13)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    vvod_disp_nabl()
  case k == 12
    mas_pmt := {"���ଠ�� �� ~��ࢨ筮�� �����",;
                "���᮪ ��易⥫��� ~���������",; //"~��樥��� � ���������� ��� ��ᯠ��୮�� ����"
                "~���ଠ�� � �믮������"}
    mas_msg := {"���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����",;
                "���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������",; //"���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)"
                "���ଠ�� � �믮������ ��ᯠ��୮�� �������"}
    mas_fun := {"disp_nabludenie(21)",;
                "disp_nabludenie(22)",;
                "disp_nabludenie(23)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 13
    mas_pmt := {"~�������� 䠩�� ������ D01",;
                "~��ᬮ�� 䠩��� ������ D01"}
    mas_msg := {"�������� 䠩�� ������ D01... � ��� �� ��ࠢ����묨 ��樥�⠬� (����������)",;
                "��ᬮ�� 䠩��� ������ D01... � १���⮢ ࠡ��� � ����"}
    mas_fun := {"disp_nabludenie(31)",;
                "disp_nabludenie(32)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)
  case k == 21
    inf_disp_nabl()
  case k == 22
    spr_disp_nabl()
  case k == 23
    //pac_disp_nabl()
    mas_pmt := {"~�� �뫮 �/� � ��ᯠ���� ��������",;
                "~�뫨 �/� � ��ᯠ���� ��������",;
                "�뫨 ~��㣨� �/� � ��������� �� ᯨ᪠"}
    mas_msg := {"���᮪ ��樥�⮢, �� ����� �� �뫮 �/� � ��ᯠ���� ��������",;
                "���᮪ ��樥�⮢, �� ����� �뫨 �/� � ��ᯠ���� ��������",;
                "���᮪ ��樥�⮢, �� ����� �뫨 ��㣨� ����� ���� � ��������� �� ᯨ᪠"}
    mas_fun := {"disp_nabludenie(41)",;
                "disp_nabludenie(42)",;
                "disp_nabludenie(43)"}
    popup_prompt(T_ROW,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
  case k == 31
    f_create_D01()
  case k == 32
    f_view_D01()
  case k == 41
    f_inf_disp_nabl(1)
  case k == 42
    f_inf_disp_nabl(2)
  case k == 43
    f_inf_disp_nabl(3)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  elseif between(k,31,39)
    si3 := j
  elseif between(k,41,49)
    si4 := j
  endif
endif
return NIL

***** 23.08.19 ���᮪ ��樥�⮢, �� ����� �뫨 �/� � ��ᯠ���� ��������
Function f_inf_disp_nabl(par)
Local arr, adiagnoz, sh := 80, HH := 60, buf := save_maxrow(), name_file := "disp_nabl"+stxt,;
      ii1 := 0, ii2 := 0, ii3 := 0, s, name_dbf := "___DN"+sdbf
stat_msg("���� ���ଠ樨...")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
if par == 1
  arr_title := {;
    "������������������������������������������������������������������������������������",;
    "                                             �   ���   � �������� ��� ��ᯠ��୮��",;
    "  ��� ��樥��                               � ஦����� � �������                ",;
    "������������������������������������������������������������������������������������"}
  sh := len(arr_title[1])
  s := "���᮪ ��樥�⮢, �� ����� �� �뫮 �/� � ��ᯠ���� ��������"
elseif par == 2
  arr_title := {;
    "�����������������������������������������������������������������������������������������������",;
    "                                             �   ���   ���� ��-� ���.�����-�  ����  � �㬬�  ",;
    "  ��� ��樥��                               � ஦����� ��饭�� �����೭��  � ��㣨 � ���� ",;
    "�����������������������������������������������������������������������������������������������"}
  sh := len(arr_title[1])
  s := "���᮪ ��樥�⮢, �� ����� �뫨 �/� � ��ᯠ���� ��������"
else
  s := "���᮪ ��樥�⮢, �� ����� �뫨 ��㣨� ����� ���� � ��������� �� ᯨ᪠"
  dbcreate(cur_dir+name_dbf,{;
    {"nn","N",6,0},;
    {"fio","C",50,0},;
    {"date_rogd","C",10,0},;
    {"date_lech","C",50,0},;
    {"summa","C",10,0},;
    {"diadnoz","C",35,0},;
    {"shifr_usl","C",10,0},;
    {"vrach","C",5,0},;
    {"number_sch","C",15,0},;
    {"date_sch","C",10,0},;
    {"nomer_posi","C",6,0}})
  use (cur_dir+name_dbf) new alias TMP
endif
add_string("")
add_string(center(s,sh))
add_string("")
if par < 3
  aeval(arr_title, {|x| add_string(x) } )
endif
//
use_base("lusl")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"mo_pers",,"PERS")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"human_",,"HUMAN_")
set relation to vrach into PERS
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
set relation to recno() into HUMAN_
index on str(kod_k,7)+dtos(k_data) to (cur_dir+"tmp_humankk") ;
      for human_->USL_OK == 3 .and. human->k_data >= 0d20190101 ; // �.�. ��᫥���� ���
      progress
//
R_Use(dir_server+"mo_d01d",,"DD")
index on str(kod_d,6) to (cur_dir+"tmp_dd")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_d01k",,"RHUM")
set relation to kod_k into KART
index on upper(kart->fio)+dtos(kart->date_r)+str(kart->kod,7) to (cur_dir+"tmp_rhum") ;
      for kart->kod > 0 .and. rhum->oplata == 1
go top
do while !eof()
  arr := {}
  select DD
  find (str(rhum->(recno()),6))
  do while dd->kod_d == rhum->(recno()) .and. !eof()
    aadd(arr,dd->kod_diag)
    skip
  enddo
  if len(arr) > 0
    fl1 := .f.
    select HUMAN
    find (str(kart->kod,7))
    do while human->kod_k == kart->kod .and. !eof()
      fl := .f. ; ar := {}
      adiagnoz := diag_to_array()
      for i := 1 to len(adiagnoz)
        if !empty(adiagnoz[i]) //.and. f2_vvod_disp_nabl(adiagnoz[i])
          s := padr(adiagnoz[i],5)
          if ascan(arr,s) > 0
            aadd(ar,s)
            fl := .t.
          endif
        endif
      next i
      if fl // ���� �᭮����, ���� ᮯ������騥 �������� �� ᯨ᪠
        fl1 := .t.
        fl_disp := .f. ; ausl := {}
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data)
            lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
            left_lshifr_5 := left(lshifr,5)
            if left_lshifr_5 == "2.88."
              aadd(ausl,lshifr)
              if is_usluga_disp_nabl(lshifr)
                fl_disp := .t.
              endif
            elseif left_lshifr_5 == "2.79."
              if ascan(ausl,lshifr) == 0
                aadd(ausl,lshifr)
              endif
            endif
          endif
          select HU
          skip
        enddo
        if fl_disp .and. par == 2
          if verify_FF(HH,.t.,sh)
            aeval(arr_title, {|x| add_string(x) } )
          endif
          add_string(padr(lstr(++ii2)+". "+kart->fio,45)+" "+full_date(kart->date_r)+" "+date_8(human->k_data)+;
                     str(pers->tab_nom,6)+" "+padr(Arr2SList(ar),5)+" "+padr(ausl[1],8)+str(human->cena_1,9,2))
        endif
        if !fl_disp .and. par == 3 .and. len(ausl) > 0
          select TMP
          append blank
          tmp->nn := ++ii3
          tmp->fio := human->fio
          tmp->date_rogd := full_date(human->date_r)
          tmp->date_lech := full_date(human->k_data)
          tmp->summa := str(human->cena_1,10,2)
          tmp->diadnoz := Arr2SList(ar)
          tmp->shifr_usl := Arr2SList(ausl)
          tmp->vrach := str(pers->tab_nom,5)
          if human->tip_h >= B_SCHET .and. human->schet > 0
            select SCHET
            goto (human->schet)
            tmp->number_sch := schet_->nschet
            tmp->date_sch := full_date(schet_->dschet)
            tmp->nomer_posi := str(human_->schet_zap,6)
          endif
        endif
      endif
      select HUMAN
      skip
    enddo
    if !fl1 .and. par == 1
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(padr(lstr(++ii1)+". "+kart->fio,45)+" "+full_date(kart->date_r)+" "+Arr2SList(arr))
    endif
  endif
  @ maxrow(),1 say lstr({ii1,ii2,ii3}[par]) color cColorStMsg
  select RHUM
  skip
enddo
close databases
fclose(fp)
rest_box(buf)
if par == 3
  if ii3 == 0
    func_error(4,"�� ������� ��樥�⮢, �� ����� �뫨 ��㣨� ����� ���� � ��������� �� ᯨ᪠")
  else
    n_message({"������ 䠩� ��� ����㧪� � Excel: "+name_dbf},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
  endif
else
  viewtext(name_file,,,,(sh>80),,,2)
endif
return NIL

***** 09.12.18 ��ࢨ�� ���� ᢥ����� � ������ �� ��ᯠ��୮� ���� � ��襩 ��
Function vvod_disp_nabl()
Local buf := savescreen(), k, s, s1, t_arr := array(BR_LEN), str_sem1, lcolor
Private str_find, muslovie
if input_perso(T_ROW,T_COL-5)
  do while .t.
    buf := savescreen()
    k := -ret_new_spec(glob_human[7],glob_human[8])
    box_shadow(0,0,2,49,color13,,,0)
    @ 0,0 say padc("["+lstr(glob_human[5])+"] "+glob_human[2],50) color color14
    @ 1,0 say padc(ret_tmp_prvs(k),50) color color14
    @ 2,0 say padc("... �롮� ��樥�� ...",50) color color1
    k := polikl1_kart()
    close databases
    //
    str_sem1 := lstr(glob_kartotek)
    if k == 0
      exit
    elseif G_SLock(str_sem1)
      s1 := f0_vvod_disp_nabl()
      R_Use(dir_server+"kartote2",,"_KART2")
      goto (glob_kartotek)
      R_Use(dir_server+"kartotek",,"_KART")
      goto (glob_kartotek)
      s := alltrim(padr(_kart->fio,37))+" ("+full_date(_kart->date_r)+")"
      lcolor := color1
      if left(_kart2->PC2,1) == "1"
        s := "���� "+s ; lcolor := color8
      elseif !(_kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
        s := "�� ��� "+s ; lcolor := color8
      endif
      @ 2,0 say padc(s,50) color lcolor
      mdate_r := _kart->date_r ; M1VZROS_REB := _kart->VZROS_REB
      fv_date_r(sys_date) // ��८�।������ M1VZROS_REB
      if M1VZROS_REB > 0
        func_error(4,"����� ०�� ⮫쪮 ��� ������, � ��࠭�� ��樥�� ���� �������!")
      else
        if !empty(s1)
          box_shadow(3,0,3,49,color13,center(s1,50),"BG+/B",0)
        endif
        str_find := str(glob_kartotek,7) ; muslovie := "dn->kod_k == glob_kartotek"
        t_arr[BR_TOP] := T_ROW
        t_arr[BR_BOTTOM] := maxrow()-2
        t_arr[BR_LEFT] := 2
        t_arr[BR_RIGHT] := maxcol()-2
        t_arr[BR_COLOR] := color0
        t_arr[BR_ARR_BROWSE] := {,,,,.t.}
        t_arr[BR_OPEN] := {|nk,ob| f1_vvod_disp_nabl(nk,ob,"open") }
        t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)},;
                                {| | FindLast(str_find)},;
                                {|n| SkipPointer(n, muslovie)},;
                                str_find,muslovie;
                               }
        t_arr[BR_COLUMN] := {{"�������;�����������",{|| dn->kod_diag }}}
        aadd(t_arr[BR_COLUMN],{"   ���;���⠭����; �� ����",{|| full_date(dn->n_data) }})
        aadd(t_arr[BR_COLUMN],{"   ���;᫥���饣�;���饭��",{|| full_date(dn->next_data) }})
        aadd(t_arr[BR_COLUMN],{"���� �஢������;��ᯠ��୮��;�������",{|| iif(empty(dn->kod_diag),space(7),iif(dn->mesto==0," � ��  ","�� ����")) }})
        t_arr[BR_EDIT] := {|nk,ob| f1_vvod_disp_nabl(nk,ob,"edit") }
        Use_base("mo_dnab")
        edit_browse(t_arr)
      endif
      G_SUnLock(str_sem1)
    else
      func_error(4,"�� �⮬� ��樥��� � ����� ������ ������ ���ଠ�� ��㣮� ���짮��⥫�")
    endif
    close databases
    restscreen(buf)
  enddo
endif
close databases
restscreen(buf)
return NIL

***** 09.12.18
Function f0_vvod_disp_nabl()
Local s := ""
R_Use(dir_server+"mo_d01k",,"DK")
index on str(reestr,6) to (cur_dir+"tmp_dk") for kod_k == glob_kartotek
go top
do while !eof()
  if dk->oplata == 0
    s := "��ࠢ��� � ����� - �⢥� ��� �� ����祭"
    exit
  elseif dk->oplata == 1
    s := "��ࠢ��� � ����� - ��� �訡��"
    exit
  else
    s := "������ �� � �訡����"
  endif
  skip
enddo
dk->(dbCloseArea())
return s

***** 29.10.18
Function f1_vvod_disp_nabl(nKey,oBrow,regim)
Local ret := -1
Local buf, fl := .f., rec := 0, rec1, r1, r2, tmp_color
Local bg := {|o,k| get_MKB10(o,k,.t.) }
Local mm_dom := {{"� ��   ",0},;
                 {"�� ����",1}}
do case
  case regim == "open"
    find (str_find)
    ret := found()
  case regim == "edit"
    do case
      case nKey == K_INS .or. (nKey == K_ENTER .and. dn->kod_k > 0)
        if nKey == K_ENTER .and. dn->vrach != glob_human[1]
          func_error(4,"������ ��ப� ������� ��㣨� ��箬!")
          return ret
        endif
        if nKey == K_ENTER
          rec := recno()
        endif
        save screen to buf
        if nkey == K_INS .and. !fl_found
          colorwin(pr1+5,pc1,pr1+5,pc2,"N/N","W+/N")
        endif
        Private gl_area := {1,0,maxrow()-1,79,0}, ;
                mKOD_DIAG := iif(nKey == K_INS, space(5), dn->kod_diag),;
                mN_DATA := iif(nKey == K_INS, sys_date-1, dn->n_data),;
                mNEXT_DATA := iif(nKey == K_INS, 0d20181202, dn->next_data),;
                mMESTO, m1mesto := iif(nKey == K_INS, 0, dn->mesto)
        mmesto := inieditspr(A__MENUVERT, mm_dom, m1mesto)
        r1 := pr2-6 ; r2 := pr2-1
        tmp_color := setcolor(cDataCScr)
        box_shadow(r1,pc1+1,r2,pc2-1,,iif(nKey == K_INS,"����������","������஢����"),cDataPgDn)
        setcolor(cDataCGet)
        do while .t.
          @ r1+1,pc1+3 say "�������, �� ������ ���ண� ��樥�� �������� ���.�������" get mkod_diag ;
                       pict "@K@!" reader {|o|MyGetReader(o,bg)} ;
                       valid val1_10diag(.t.,.f.,.f.,0d20181201,_kart->pol)
          @ r1+2,pc1+3 say "��� ��砫� ��ᯠ��୮�� �������" get mn_data
          @ r1+3,pc1+3 say "��� ᫥���饩 � � 楫�� ��ᯠ��୮�� �������" get mnext_data
          @ r1+4,pc1+3 say "���� �஢������ ��ᯠ��୮�� �������" get mmesto ;
                       reader {|x|menu_reader(x,mm_dom,A__MENUVERT,,,.f.)}
          status_key("^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����")
          myread()
          if lastkey() != K_ESC .and. f_Esc_Enter(1)
            mKOD_DIAG := padr(mKOD_DIAG,5)
            fl := .t.
            if empty(mKOD_DIAG)
              fl := func_error(4,"�� ����� �������")
            elseif !f2_vvod_disp_nabl(mKOD_DIAG)
              fl := func_error(4,"������� �� �室�� � ᯨ᮪ �����⨬�� �� �ਪ��� �� � �����")
            else
              select DN
              find (str(glob_kartotek,7))
              do while dn->kod_k == glob_kartotek .and. !eof()
                if rec != recno() .and. mKOD_DIAG == dn->kod_diag
                  fl := func_error(4,"����� ������� 㦥 ����� ��� ������� ��樥��")
                  exit
                endif
                skip
              enddo
            endif
            if empty(mN_DATA)
              fl := func_error(4,"�� ������� ��� ��砫� ��ᯠ��୮�� �������")
            elseif mN_DATA >= 0d20181201
              fl := func_error(4,"��� ��砫� ��ᯠ��୮�� ������� ᫨誮� ������")
            endif
            if empty(mNEXT_DATA)
              fl := func_error(4,"�� ������� ��� ᫥���饩 �")
            elseif mN_DATA >= mNEXT_DATA
              fl := func_error(4,"��� ᫥���饩 � ����� ���� ��砫� ��ᯠ��୮�� �������")
            elseif mNEXT_DATA <= 0d20181201
              fl := func_error(4,"��� ᫥���饩 � ������ ���� �� ࠭�� 1 �������")
            endif
            if !fl
              loop
            endif
            select DN
            if nKey == K_INS
              fl_found := .t.
              AddRec(7)
              dn->kod_k := glob_kartotek
              rec := recno()
            else
              goto (rec)
              G_RLock(forever)
            endif
            dn->vrach := glob_human[1]
            dn->prvs  := iif(empty(glob_human[8]), glob_human[7], -glob_human[8])
            dn->kod_diag := mKOD_DIAG
            dn->n_data := mN_DATA
            dn->next_data := mNEXT_DATA
            dn->mesto := m1mesto
            UnLock
            COMMIT
            oBrow:goTop()
            goto (rec)
            ret := 0
          elseif nKey == K_INS .and. !fl_found
            ret := 1
          endif
          exit
        enddo
        select DN
        setcolor(tmp_color)
        restore screen from buf
      case nKey == K_DEL .and. dn->kod_k == glob_kartotek .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
        if eof() .or. !&muslovie
          ret := 1
        endif
    endcase
endcase
return ret

***** 09.12.18 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function f2_vvod_disp_nabl(ldiag)
Local fl := .f., lfp, i, s, d1, d2
if len_diag == 0
  lfp := fopen(file_form)
  do while !feof(lfp)
    s := fReadLn(lfp)
/*for i := 1 to len(s) // �஢�ઠ �� ���᪨� �㪢� � ���������
  if ISRALPHA(substr(s,i,1))
    strfile(s+eos,"ttt.ttt",.t.)
    exit
  endif
next*/
    if !empty(s)
      aadd(diag1, alltrim(s))
    endif
  enddo
  fclose(lfp)
  len_diag := len(diag1)
endif
return ascan(diag1,alltrim(ldiag)) > 0

***** 08.11.18 ���ଠ�� �� ��ࢨ筮�� ����� ᢥ����� � ������ �� ��ᯠ��୮� ����
Function inf_disp_nabl()
Static suchast := 0, svrach := 0, sdiag := ''
Local bg := {|o,k| get_MKB10(o,k,.f.) }
Local buf := savescreen(), r := 15, sh, HH := 60, name_file := "info_dn"+stxt
f2_vvod_disp_nabl("A00")
setcolor(cDataCGet)
myclear(r)
Private muchast := suchast,;
        mvrach := svrach,;
        mkod_diag := padr(sdiag,5),;
        gl_area := {r,0,maxrow()-1,maxcol(),0}
status_key("^<Esc>^ - ��室;  ^<PgDn>^ - ��⠢����� ���㬥��")
//
@ r,0 to r+8,maxcol() COLOR color8
str_center(r," ����� ���ଠ樨 �� ���񭭮�� ��ᯠ��୮�� ������� ",color14)
@ r+2,2 say "����� ���⪠ (0 - �� �ᥬ ���⪠�)" get muchast pict "99999"
@ r+3,2 say "������� ����� ��� (0 - �� �ᥬ ��砬)" get mvrach pict "99999"
@ r+4,2 say "������� (��� ��砫�� ᨬ����, ��� ����� ��ப�)" get mkod_diag ;
        pict "@K@!" reader {|o|MyGetReader(o,bg)}
myread()
if lastkey() != K_ESC
  if mvrach > 0
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERSO")
    find (str(mvrach,5))
    if found()
      glob_human := {perso->kod,;
                     alltrim(perso->fio),;
                     perso->uch,;
                     perso->otd,;
                     mvrach,;
                     alltrim(perso->name_dolj),;
                     perso->prvs,;
                     perso->prvs_new }
      fl1 := .t.
    else
      func_error(4,"����㤭��� � ⠡���� ����஬ "+lstr(i)+" ��� � ���� ������ ���ᮭ���!")
      mvrach := 0
    endif
    close databases
  endif
  if !empty(mkod_diag)
    fl_all_diag := .f.
    mkod_diag := alltrim(mkod_diag) ; l := len(mkod_diag)
    if ascan(diag1,mkod_diag) > 0
      fl_all_diag := .t.
    elseif ascan(diag1, {|x| left(x,l) == mkod_diag }) == 0
      func_error(4,mkod_diag+" �� �室�� � ᯨ᮪ �����⨬�� ��������� �� �ਪ��� �� � �����")
      mkod_diag := ""
    endif
  endif
  //
  suchast := muchast
  svrach := mvrach
  sdiag := mkod_diag
  //
  arr_title := {;
    "�����������������������������������������������������������������������������������������",;
    "                                             �   ���   ��� ���.�����-����⠭����������.",;
    "  ��� ��樥��                               � ஦����� ��᳭���೭��  ��� ���� ������   ",;
    "�����������������������������������������������������������������������������������������"}
  sh := len(arr_title[1])
  mywait()
  fp := fcreate(name_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("���᮪ ��樥�⮢, ������ �� ��ᯠ��୮� ����",sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  R_Use(dir_server+"mo_pers",,"PERS")
  R_Use(dir_server+"kartotek",,"KART")
  R_Use_base("mo_dnab")
  set relation to kod_k into KART, to vrach into PERS
  index on upper(kart->fio)+dtos(kart->date_r)+str(dn->kod_k,7)+dn->kod_diag to (cur_dir+"tmp_dn") ;
        for kart->kod > 0
  old := r := rs := 0
  go top
  do while !eof()
    fl := .t.
    if muchast > 0
      fl := (kart->uchast == muchast)
    endif
    if fl .and. mvrach > 0
      fl := (glob_human[1] == dn->vrach)
    endif
    if fl .and. !empty(mkod_diag)
      if fl_all_diag
        fl := (alltrim(dn->kod_diag) == mkod_diag)
      else
        fl := (left(dn->kod_diag,l) == mkod_diag)
      endif
    endif
    if fl
      if old == dn->kod_k
        s := space(45)+space(1+10+3)
      else
        s := padr(kart->fio,45)+" "+full_date(kart->date_r)+str(kart->uchast,3)
        ++r
      endif
      s += str(pers->tab_nom,6)+" "+dn->kod_diag+" "+date_8(dn->n_data)+" "+date_8(dn->next_data)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      old := dn->kod_k
      ++rs
    endif
    select DN
    skip
  enddo
  if empty(r)
    add_string("�� ������� ��樥�⮢ �� ��������� �᫮���")
  else
    add_string("=== �⮣� ��樥�⮢ - "+lstr(r)+" 祫., �⮣� ��砥� - "+lstr(rs)+" ===")
  endif
  close databases
  fclose(fp)
  viewtext(name_file,,,,(sh>80),,,2)
endif
restscreen(buf)
return NIL

***** 07.11.18 ���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� �������
Function spr_disp_nabl()
Local i, j, s := "", c := "  ", sh := 80, HH := 60, buf := save_maxrow(), name_file := "diagn_dn"+stxt
f2_vvod_disp_nabl("A00")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("���᮪ ���������, ��易⥫��� ��� ��ᯠ��୮�� ������� �� 21.11.18�.",sh))
for i := 1 to len(diag1)
  if c == substr(diag1[i],2,2)
    s += diag1[i]+" "
  else
    verify_FF(HH,.t.,sh)
    add_string(s)
    s := diag1[i]+" "
    c := substr(diag1[i],2,2)
  endif
next
add_string(s)
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
rest_box(buf)
return NIL

/***** 07.11.18 ���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)
Function pac_disp_nabl()
Static su := 0
Local ku, i, adiagnoz, ar, sh := 80, HH := 60, buf := save_maxrow(), name_file := "disp_nabl"+stxt,;
      s, c1, cv := 0, cf := 0, fl_exit := .f.
if (ku := input_value(20,20,22,59,color1,space(6)+"������ ����� ���⪠",su,"99")) == NIL
  return NIL
endif
su := ku
stat_msg("���� ���ଠ樨...")
fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("���᮪ ��樥�⮢ � ����������, ��易⥫�묨 ��� ��ᯠ��୮�� ���� (�� 2 ����)",sh))
add_string(center("���⮪ � "+lstr(ku),sh))
add_string("")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
R_Use_base("kartotek")
set order to 4
find (strzero(ku,2))
index on upper(fio) to (cur_dir+"tmp_kart") ;
      for kart->kod > 0 .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] .and. !(left(kart2->PC2,1) == "1") ;
      while ku == uchast
go top
do while !eof()
  @ maxrow(),1 say lstr(++cv) color cColorSt2Msg
  @ row(),col() say "/" color "W/R"
  c1 := col()
  @ row(),c1 say lstr(cf) color cColorStMsg
  if inkey() == K_ESC
    fl_exit := .t. ; exit
  endif
  if kart->kod > 0 .and. kart2->MO_PR == glob_mo[_MO_KOD_TFOMS] .and. !(left(kart2->PC2,1) == "1")
    mdate_r := kart->date_r ; M1VZROS_REB := kart->VZROS_REB
    fv_date_r(sys_date) // ��८�।������ M1VZROS_REB
    if M1VZROS_REB == 0
      ar := {}
      select HUMAN
      find (str(kart->kod,7))
      do while human->kod_k == kart->kod .and. !eof()
        if human->k_data > 0d20161231 // �.�. ��᫥���� ��� ���� � �� ᪮�� ������
          human_->(dbGoto(human->(recno())))
          if human_->USL_OK < 4
            adiagnoz := diag_to_array()
            for i := 1 to len(adiagnoz)
              if !empty(adiagnoz[i]) .and. f2_vvod_disp_nabl(adiagnoz[i])
                s := padr(adiagnoz[i],5)
                if ascan(ar,s) == 0
                  aadd(ar,s)
                endif
              endif
            next i
          endif
        endif
        select HUMAN
        skip
      enddo
      if len(ar) > 0
        s2 := ""
        if mem_kodkrt == 2
          s2 := "["
          if is_uchastok > 0
            s2 += alltrim(kart->bukva)
            s2 += lstr(kart->uchast,2)+"/"
          endif
          if is_uchastok == 1
            s2 += lstr(kart->kod_vu)
          elseif is_uchastok == 3
            s2 += alltrim(kart2->kod_AK)
          else
            s2 += lstr(kart->kod)
          endif
          s2 += "] "
        endif
        verify_FF(HH,.t.,sh)
        add_string(left(s2+alltrim(kart->fio)+" �.�."+full_date(kart->date_r),99))
        add_string(left("  "+arr2Slist(ar),99))
        if empty(kart_->okatop)
          add_string(left("  "+ret_okato_ulica(kart->adres,kart_->okatog,0,2),99))
        else
          add_string(left("  "+ret_okato_ulica(kart_->adresp,kart_->okatop,0,2),99))
        endif
        @ row(),c1 say lstr(++cf) color cColorStMsg
      endif
    endif
  endif
  select KART
  skip
enddo
if fl_exit
  add_string("*** "+expand("�������� ��������"))
elseif empty(cf)
  add_string("�� �����㦥�� ����訢����� ��樥�⮢ �� ������� �����.")
else
  add_string("=== �⮣� ��樥�⮢ - "+lstr(cf)+" 祫. ===")
endif
close databases
fclose(fp)
viewtext(name_file,,,,.t.,,,2)
rest_box(buf)
return NIL*/

***** 28.11.18 ����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������
Function f_create_D01()
Local fl := .t., arr, id01 := 0, lspec, lmesto, buf := save_maxrow()
mywait()
R_Use(dir_server+"mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_D02 .and. empty(TIP_OUT)
R_Use(dir_server+"mo_d01",,"REES")
index on str(nn,3) to (cur_dir+"tmp_d01")
go top
do while !eof()
  //aadd(a_reestr, rees->kod)
  if rees->kol_err < 0
    //fl := func_error(4,"� 䠩�� D02 �� �訡�� �� �஢�� 䠩��! ������ ����饭�")
  elseif empty(rees->answer)
    fl := func_error(4,"���� D02 �� �� ���⠭! ������ ����饭�")
  else
    select MO_XML
    find (str(rees->kod,6))
    if found()
      if empty(mo_xml->TWORK2)
        fl := func_error(4,"��ࢠ�� �⥭�� 䠩�� "+alltrim(mo_xml->FNAME)+;
                           "! ���㫨��� (Ctrl+F12) � ���⠩� ᭮��")
      else
        //aadd(arr_rees,rees->kod)
      endif
    endif
  endif
  select REES
  skip
enddo
if !fl
  close databases
  rest_box(buf)
  return NIL
endif
G_Use(dir_server+"mo_d01d",,"DD")
index on str(kod_d,6) to (cur_dir+"tmp_d01d")
G_Use(dir_server+"mo_d01k",,"DK")
index on str(reestr,6) to (cur_dir+"tmp_d01k")
do while .t.
  select DK
  find (str(0,6)) // �᫨ �� �६� ᮧ����� D01 �� ᡮ�
  if found()
    select DD
    do while .t.
      find (str(dk->(recno()),6))
      if found()
        DeleteRec(.t.)
      else
        exit
      endif
    enddo
    select DK
    DeleteRec(.t.)
  else
    exit
  endif
enddo
Commit
dbcreate(cur_dir+"tmp",{{"KOD_K","N",7,0}})
use (cur_dir+"tmp") new
select DK
index on str(kod_k,7) to (cur_dir+"tmp_d01k")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_dnab",,"DN")
set relation to kod_k into KART
index on str(kod_k,7) to (cur_dir+"tmp_dn") for kart->kod > 0 unique
go top
do while !eof()
  fl := .t.
  select DK
  find (str(dn->kod_k,7))
  do while dk->kod_k == dn->kod_k .and. !eof()
    if dk->oplata < 2 // �᫨ oplata = 0 (�⢥� ��� �� ����祭) ��� oplata = 1 (����祭)
      fl := .f.
    endif
    skip
  enddo
  if fl
    select TMP
    append blank
    tmp->kod_k := dn->kod_k
  endif
  select DN
  skip
enddo
if tmp->(lastrec()) == 0
  func_error(4,"�� �����㦥�� ��樥�⮢, ������ ��� ���.��������, ��� �� ��ࠢ������ � �����")
else
  f2_vvod_disp_nabl("A00")
  R_Use(dir_server+"mo_pers",,"PERSO")
  select DN
  set relation to vrach into PERSO
  index on str(kod_k,7) to (cur_dir+"tmp_dn")
  select TMP
  go top
  do while !eof()
    arr := {} ; lmesto := 0
    select DN
    find (str(tmp->kod_k,7))
    do while dn->kod_k == tmp->kod_k .and. !eof()
      if f2_vvod_disp_nabl(dn->kod_diag) // ⮫쪮 �������� �� ��᫥����� ᯨ᪠ �� 21 �����
        lspec := ret_prvs_V021(iif(empty(perso->prvs_new), perso->prvs, -perso->prvs_new))
        aadd(arr,{lspec,dn->kod_diag,dn->n_data,bom(dn->next_data)})
        if dn->mesto == 1
          lmesto := 1
        endif
      endif
      select DN
      skip
    enddo
    if len(arr) > 0
      select DK
      AddRec(7)
      dk->REESTR  := 0                     // ��� ॥��� �� 䠩�� "mo_d01"
      dk->KOD_K   := tmp->kod_k            // ��� �� ����⥪�
      dk->D01_ZAP := ++id01                // ����� ����樨 ����� � ॥���;"ZAP" � D01
      dk->ID_PAC  := mo_guid(1,tmp->kod_k) // GUID ��樥�� � D01 (ᮧ������ �� ���������� �����)
      dk->MESTO   := lmesto                // ���� �஢������ ��ᯠ��୮�� �������: 0 - � �� ��� 1 - �� ����
      dk->OPLATA  := 0                     // ⨯ ������: ᭠砫� 0, ��⥬ �� ����� 1,2,3,4
      select DD
      for i := 1 to len(arr)
        AddRec(6)
        dd->KOD_D     := dk->(recno()) // ��� (����� �����) �� 䠩�� "mo_d01k"
        dd->PRVS      := arr[i,1]      // ���樠�쭮��� ��� �� �ࠢ�筨�� V021
        dd->KOD_DIAG  := arr[i,2]      // ������� �����������, �� ������ ���ண� ��樥�� �������� ��ᯠ��୮�� �������
        dd->N_DATA    := arr[i,3]      // ��� ��砫� ��ᯠ��୮�� �������
        dd->NEXT_DATA := arr[i,4]      // ��� � � 楫�� ��ᯠ��୮�� �������
      next
      if id01 % 500 == 0
        Commit
      endif
    endif
    select TMP
    skip
  enddo
endif
close databases
rest_box(buf)
if id01 > 0 .and. f_Esc_Enter("ᮧ����� 䠩�� D01",.t.)
  mywait()
  inn := 0 ; nsh := 3
  G_Use(dir_server+"mo_d01",,"REES")
  index on str(nn,3) to (cur_dir+"tmp_d01")
  go top
  do while !eof()
    inn := rees->nn
    skip
  enddo
  set index to
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"mo_xml",,"MO_XML")
  smsg := "���⠢����� 䠩�� D01..."
  stat_msg(smsg)
  select REES
  AddRecN()
  rees->KOD    := recno()
  rees->DSCHET := sys_date
  rees->NYEAR  := 2018
  rees->MM     := 12
  rees->NN     := inn+1
  s := "D01"+"T34M"+glob_mo[_MO_KOD_TFOMS]+"_1812"+strzero(rees->NN,nsh)
  rees->NAME_XML := s
  mkod_reestr := rees->KOD
  //
  select MO_XML
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := s
  mo_xml->FNAME2 := ""
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_IN := 0
  mo_xml->TIP_OUT := _XML_FILE_D01  // ⨯ ���뫠����� 䠩�� - D01
  mo_xml->REESTR := mkod_reestr
  mo_xml->DWORK := sys_date
  mo_xml->TWORK1 := hour_min(seconds())
  //
  rees->KOD_XML := mo_xml->KOD
  UnLock
  Commit
  pkol := 0
  G_Use(dir_server+"mo_d01d",cur_dir+"tmp_d01d","DD")
  G_Use(dir_server+"mo_d01k",,"RHUM")
  index on str(REESTR,6)+str(D01_ZAP,6) to (cur_dir+"tmp_rhum")
  do while .t.
    find (str(0,6))
    if found()
      ++pkol
      @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
      //
      G_RLock(forever)
      rhum->REESTR := mkod_reestr
      if pkol % 2000 == 0
        dbUnlockAll()
        dbCommitAll()
      endif
    else
      exit
    endif
  enddo
  select REES
  G_RLock(forever)
  rees->KOL := pkol
  rees->KOL_ERR := 0
  dbUnlockAll()
  dbCommitAll()
  //
  stat_msg(smsg)
  //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    mo_add_xml_stroke(oXmlNode,"VERSION",'1.0')
    mo_add_xml_stroke(oXmlNode,"CODE_MO",glob_mo[_MO_KOD_FFOMS])
    mo_add_xml_stroke(oXmlNode,"CODEM",glob_mo[_MO_KOD_TFOMS])
    mo_add_xml_stroke(oXmlNode,"DATE_F",date2xml(mo_xml->DFILE))
    mo_add_xml_stroke(oXmlNode,"NAME_F",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SMO",'34')
    mo_add_xml_stroke(oXmlNode,"YEAR",lstr(rees->NYEAR))
    mo_add_xml_stroke(oXmlNode,"MONTH",lstr(rees->MM))
    mo_add_xml_stroke(oXmlNode,"N_PACK",lstr(rees->NN))
  //
  select RHUM
  set relation to kod_k into KART, to kod_k into KART_, to kod_k into KART2
  index on str(D01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->D01_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    arr_fio := retFamImOt(1,.f.)
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERSONS" ) )
    mo_add_xml_stroke(oXmlNode,"ZAP",lstr(rhum->D01_ZAP))
    mo_add_xml_stroke(oXmlNode,"IDPAC",rhum->ID_PAC)
    mo_add_xml_stroke(oXmlNode,"SURNAME",arr_fio[1])
    mo_add_xml_stroke(oXmlNode,"NAME",arr_fio[2])
    if !empty(arr_fio[3])
      mo_add_xml_stroke(oXmlNode,"PATRONYMIC",arr_fio[3])
    endif
    mo_add_xml_stroke(oXmlNode,"BIRTHDAY",date2xml(kart->date_r))
    mo_add_xml_stroke(oXmlNode,"SEX",iif(kart->pol=="�",'1','2'))
    if !empty(kart->snils)
      mo_add_xml_stroke(oXmlNode,"SS",transform(kart->SNILS,picture_pf))
    endif
    mo_add_xml_stroke(oXmlNode,"TYPE_P",lstr(iif(between(kart_->VPOLIS,1,3),kart_->VPOLIS,1)))
    if !empty(kart_->SPOLIS)
      mo_add_xml_stroke(oXmlNode,"SER_P",kart_->SPOLIS)
    endif
    s := alltrim(kart_->NPOLIS)
    if kart_->VPOLIS == 3 .and. len(s) != 16
      s := padr(s,16,"0")
    endif
    mo_add_xml_stroke(oXmlNode,"NUM_P",s)
    if kart_->VPOLIS == 3
      mo_add_xml_stroke(oXmlNode,"ENP",s)
    endif
    mo_add_xml_stroke(oXmlNode,"DOCTYPE",lstr(kart_->vid_ud))
    if !empty(kart_->ser_ud)
      mo_add_xml_stroke(oXmlNode,"DOCSER",kart_->ser_ud)
    endif
    mo_add_xml_stroke(oXmlNode,"DOCNUM",kart_->nom_ud)
    if !empty(smr := del_spec_symbol(kart_->mesto_r))
      mo_add_xml_stroke(oXmlNode,"MR",smr)
    endif
    mo_add_xml_stroke(oXmlNode,"PLACE",lstr(rhum->mesto))
    oCONTACTS := oXmlNode:Add( HXMLNode():New( "CONTACTS" ) )
     if !empty(kart_->PHONE_H)
       mo_add_xml_stroke(oCONTACTS,"TEL_F",left(kart_->PHONE_H,1)+"-"+substr(kart_->PHONE_H,2,4)+"-"+substr(kart_->PHONE_H,6))
     endif
     if !empty(kart_->PHONE_M)
       mo_add_xml_stroke(oCONTACTS,"TEL_M",left(kart_->PHONE_M,1)+"-"+substr(kart_->PHONE_M,2,3)+"-"+substr(kart_->PHONE_M,5))
     endif
     oADDRESS := oCONTACTS:Add( HXMLNode():New( "ADDRESS" ) )
      s := "18000"
      if len(alltrim(kart_->okatop)) == 11
        s := left(kart_->okatop,5)
      elseif len(alltrim(kart_->okatog)) == 11
        s := left(kart_->okatog,5)
      endif
      mo_add_xml_stroke(oADDRESS,"SUBJ",s)
      if !empty(kart->adres)
        mo_add_xml_stroke(oADDRESS,"UL",kart->adres)
      endif
    arr := {}
    select DD
    find (str(rhum->(recno()),6))
    do while dd->kod_d == rhum->(recno()) .and. !eof()
      if (i := ascan(arr, {|x| x[1] == dd->prvs })) == 0
        aadd(arr, {dd->prvs,{}} ) ; i := len(arr)
      endif
      aadd(arr[i,2], {dd->KOD_DIAG,dd->N_DATA,dd->NEXT_DATA} )
      skip
    enddo
    oSPECs := oXmlNode:Add( HXMLNode():New( "SPECIALISATIONS" ) )
    for i := 1 to len(arr)
     oSPEC := oSPECs:Add( HXMLNode():New( "SPECIALISATION" ) )
      mo_add_xml_stroke(oSPEC,"SPECIALIST",lstr(arr[i,1]))
      oREASONS := oSPEC:Add( HXMLNode():New( "REASONS" ) )
      for j := 1 to len(arr[i,2])
       oREASON := oREASONS:Add( HXMLNode():New( "REASON" ) )
        mo_add_xml_stroke(oREASON,"DS",arr[i,2,j,1])
        mo_add_xml_stroke(oREASON,"DATE_B",date2xml(arr[i,2,j,2]))
        mo_add_xml_stroke(oREASON,"DATE_VISIT",date2xml(arr[i,2,j,3]))
      next j
    next i
    select RHUM
    skip
  enddo
  stat_msg("������ XML-䠩��")
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  chip_create_zipXML(alltrim(mo_xml->FNAME)+szip,{alltrim(mo_xml->FNAME)+sxml},.t.)
  mo_xml->(G_RLock(forever))
  mo_xml->TWORK2 := hour_min(seconds())
  close databases
  keyboard chr(K_TAB)+chr(K_ENTER)
  rest_box(buf)
endif
return NIL

***** 29.11.18 ����� � ����� ���ଠ樥� �� ��ᯠ��୮�� �������
Function f_view_D01()
Local i, k, buf := savescreen()
Private goal_dir := dir_server+dir_XML_MO+cslash
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"mo_d01",,"REES")
index on descend(strzero(nn,3)) to (cur_dir+"tmp_rees")
go top
if eof()
  func_error(4,"�� �뫮 ᮧ���� 䠩��� D01...")
else
  Private reg := 1
  Alpha_Browse(T_ROW,2,maxrow()-2,77,"f1_view_D01",color0,,,,,,,;
               "f2_view_D01",,{'�','�','�',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
restscreen(buf)
return NIL

***** 29.11.18
Function f1_view_D01(oBrow)
Local oColumn, ;
      blk := {|| iif(hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip), ;
                     iif(empty(rees->date_out), {3,4}, {1,2}),;
                     {5,6}) }
oColumn := TBColumnNew(" ��",{|| str(rees->nn,3) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  ���",{|| date_8(rees->dschet) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("���-��;��樥�⮢", {|| str(rees->kol,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ���-��; �訡��", {|| iif(rees->kol_err < 0, "� 䠩��", put_val(rees->kol_err,7)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("��-;���", {|| iif(rees->answer==1,"�� ","���") })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" ������������ 䠩��",{|| padr(rees->NAME_XML,21) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("�ਬ�砭��",{|| f11_view_D01() })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
if reg == 1
  status_key("^<Esc>^ ��室; ^<F5>^ ������ ��� �����; ^<F3>^ ���ଠ�� � 䠩��")
else
  status_key("^<Esc>^ - ��室;  ^<Enter>^ - �롮� ॥��� ��� ������")
endif
return NIL

***** 03.12.18
Static Function f11_view_D01()
Local s := ""
if rees->kod_xml > 0
  mo_xml->(dbGoto(rees->kod_xml))
  if empty(mo_xml->twork2)
    s := "�� ������"
  endif
endif
if empty(s)
  if !hb_fileExists(goal_dir+alltrim(rees->NAME_XML)+szip)
    s := "��� 䠩��"
  elseif empty(rees->date_out)
    s := "�� ����ᠭ"
  else
    s := "���. "+lstr(rees->NUMB_OUT)+" ࠧ"
  endif
endif
return padr(s,10)

***** 03.12.18
Function f2_view_D01(nKey,oBrow)
Local ret := -1, rec := rees->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr := {}, i := 1, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    mdate := rees->dschet
    aadd(arr, {rees->name_xml,rees->kod_xml,rees->(recno())})
    s := "�����뢠���� 䠩� "+alltrim(arr[i,1])+szip+"."
    perenos(t_arr,s,74)
    f_message(t_arr,,color1,color8)
    if f_Esc_Enter("����� 䠩�� D01")
      Private p_var_manager := "copy_schet"
      s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" ��� �롮� ��⠫���
      if !empty(s)
        if upper(s) == upper(goal_dir)
          func_error(4,"�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ 楫���� 䠩�! �� �������⨬�.")
        else
          cFileProtokol := "prot_sch"+stxt
          strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
          smsg := "���� D01 ����ᠭ ��: "+s+" ("+full_date(sys_date)+"�. "+hour_min(seconds())+")"
          strfile(center(smsg,80)+hb_eol(),cFileProtokol,.t.)
          k := 0
          for i := 1 to len(arr)
            zip_file := alltrim(arr[i,1])+szip
            if hb_fileExists(goal_dir+zip_file)
              mywait('����஢���� "'+zip_file+'" � ��⠫�� "'+s+'"')
              //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
              copy file (goal_dir+zip_file) to (s+zip_file)
              //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
              if hb_fileExists(s+zip_file)
                ++k
                rees->(dbGoto(arr[i,3]))
                smsg := "����� D01 � "+lstr(rees->nn)+" �� "+date_8(mdate)+"�. "+alltrim(rees->name_xml)+szip
                strfile(hb_eol()+smsg+hb_eol(),cFileProtokol,.t.)
                smsg := "   ������⢮ ��樥�⮢ - "+lstr(rees->kol)
                strfile(smsg+hb_eol(),cFileProtokol,.t.)
                rees->(G_RLock(forever))
                rees->DATE_OUT := sys_date
                if rees->NUMB_OUT < 99
                  rees->NUMB_OUT ++
                endif
                //
                mo_xml->(dbGoto(arr[i,2]))
                mo_xml->(G_RLock(forever))
                mo_xml->DREAD := sys_date
                mo_xml->TREAD := hour_min(seconds())
              else
                smsg := "! �訡�� ����� 䠩�� "+s+zip_file
                func_error(4,smsg)
                strfile(smsg+hb_eol(),cFileProtokol,.t.)
              endif
            else
              smsg := "! �� �����㦥� 䠩� "+goal_dir+zip_file
              func_error(4,smsg)
              strfile(smsg+hb_eol(),cFileProtokol,.t.)
            endif
          next i
          UnLock
          Commit
          viewtext(cFileProtokol,,,,.t.,,,2)
        endif
      endif
    endif
    select REES
    goto (rec)
    ret := 0
  case nKey == K_F3
    f3_view_D01(oBrow)
    ret := 0
  case nKey == K_CTRL_F12
    if rees->ANSWER == 0
      mo_xml->(dbGoto(rees->kod_xml))
      if empty(mo_xml->twork2)
        ret := delete_reestr_D01(rees->(recno()))
      else
        func_error(4,"���� "+alltrim(rees->NAME_XML)+sxml+" ᮧ��� ���४⭮. ���㫨஢���� ����饭�!")
      endif
    else
      ret := delete_reestr_D02(rees->(recno()),alltrim(rees->NAME_XML))
    endif
    close databases
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"mo_d01",cur_dir+"tmp_rees","REES")
    if ret != 1
      goto (rec)
    endif
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

***** 29.11.18
Function f3_view_D01(oBrow)
Static si := 1
Local i, r := row(), r1, r2, buf := save_maxrow(), fl, s,;
      mm_func := {-99},;
      mm_menu := {"���᮪ ~��� ��樥�⮢ �� D01"}
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr==rees->kod .and. tip_in==_XML_FILE_D02 .and. empty(TIP_OUT)
go top
do while !eof()
  aadd(mm_func, -1)
  aadd(mm_menu, "1-��⠭������ ����.�ਭ����������, ���⢥ত��� �ਪ९����� � ��")
  aadd(mm_func, -2)
  aadd(mm_menu, "2-���������� �訡�� �孮�����᪮�� ����஫�")
  aadd(mm_func, -3)
  aadd(mm_menu, "3-�� ��⠭������ ���客�� �ਭ����������")
  aadd(mm_func, -4)
  aadd(mm_menu, "4-�� ��⠭������ ����.�ਭ����������, �� ���⢥ত��� �ਪ९����� � ��")
  s := "��⮪�� �⥭�� "+rtrim(mo_xml->FNAME)+" ���⠭ "+date_8(mo_xml->DWORK)
  if empty(mo_xml->TWORK2)
    s += "-������� �� ��������"
  else
    s += " � "+mo_xml->TWORK1
  endif
  aadd(mm_func, mo_xml->kod)
  aadd(mm_menu, s)
  skip
enddo
select MO_XML
set index to
if r <= 12
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
rest_box(buf)
if len(mm_menu) == 1
  i := 1
  si := i
  if mm_func[i] < 0
    f31_view_D01(abs(mm_func[i]),mm_menu[i])
  endif
elseif (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
  si := i
  if mm_func[i] < 0
    f31_view_D01(abs(mm_func[i]),mm_menu[i])
  else
    mo_xml->(dbGoto(mm_func[i]))
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
  endif
endif
select REES
return NIL

***** 29.11.18
Function f31_view_D01(reg,s)
Local fl := .t., buf := save_maxrow(), k := 0, n_file := "D01_spis"+stxt
mywait()
fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
add_string("")
add_string(center("���᮪ ��樥�⮢ 䠩�� "+alltrim(rees->NAME_XML)+" �� "+date_8(rees->dschet),80))
if reg == 99
  s := "�� ��樥���"
endif
add_string(center("[ "+s+" ]",80))
add_string("")
R_Use(dir_server+"mo_d01d",,"DD")
index on str(kod_d,6) to (cur_dir+"tmp_dd")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"mo_d01k",,"RHUM")
set relation to kod_k into KART
index on str(rhum->D01_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == rees->kod
go top
do while !eof()
  if iif(reg == 99, .t., rhum->OPLATA == reg)
    ++k
    s := str(rhum->D01_ZAP,5)+". "
    if empty(kart->fio)
      s += "㤠�� �㡫���� � ����⥪� (���="+lstr(kod_k)+")"
    else
      s += padr(upper(kart->fio),35)+" "+full_date(kart->date_r)
    endif
    s += " ("
    select DD
    find (str(rhum->(recno()),6))
    do while dd->kod_d == rhum->(recno()) .and. !eof()
       s += " "+alltrim(dd->kod_diag)
       skip
    enddo
    s += " )"
    verify_FF(60,.t.,80)
    add_string(s)
  endif
  select RHUM
  skip
enddo
add_string("")
add_string("�ᥣ� "+lstr(k)+" 祫.")
kart->(dbCloseArea())
rhum->(dbCloseArea())
dd->(dbCloseArea())
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

***** 29.11.18 ������ D01 �� �६���� 䠩��
Function reestr_D01_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("��ᯠ�����/�⥭��/������ 䠩�� "+mname_xml)
dbcreate(cur_dir+"tmp4file", {;
 {"ZAP",        "N",  6,0},;
 {"IDPAC",      "C", 36,0},;
 {"SURNAME",    "C", 40,0},;
 {"NAME",       "C", 40,0},;
 {"PATRONYMIC", "C", 40,0},;
 {"BIRTHDAY",   "C", 10,0},;
 {"SEX",        "C",  1,0},;
 {"SS",         "C", 14,0},;
 {"TYPE_P",     "C",  1,0},;
 {"SER_P",      "C", 10,0},;
 {"NUM_P",      "C", 20,0},;
 {"ENP",        "C", 16,0},;
 {"DOCTYPE",    "C",  2,0},;
 {"DOCSER",     "C", 10,0},;
 {"DOCNUM",     "C", 20,0},;
 {"MR",         "C",100,0},;
 {"PLACE",      "C",  1,0},;
 {"TEL_F",      "C", 13,0},;
 {"TEL_M",      "C", 13,0},;
 {"SUBJ",       "C",  5,0},;
 {"UL",         "C",120,0},;
 {"kod_k",      "N",  7,0},;
 {"OPLATA",     "N",  1,0};
})
dbcreate(cur_dir+"tmp5file", {;
 {"ZAP",        "N",  6,0},;
 {"PRVS"    ,   "C",  4,0},;
 {"DS"      ,   "C",  5,0},;
 {"DATE_B"  ,   "C", 10,0},;
 {"DATE_VIZIT", "C", 10,0};
})
use (cur_dir+"tmp4file") new alias TMP2
use (cur_dir+"tmp5file") new alias TMP5
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  if "PERSONS" == oXmlNode:title
    select TMP2
    append blank
    tmp2->ZAP       := val(mo_read_xml_stroke(oXmlNode,"ZAP",aerr))
    tmp2->IDPAC     :=     mo_read_xml_stroke(oXmlNode,"IDPAC",aerr,.f.)
    tmp2->SURNAME   :=     mo_read_xml_stroke(oXmlNode,"SURNAME",aerr,.f.)
    tmp2->NAME      :=     mo_read_xml_stroke(oXmlNode,"NAME",aerr,.f.)
    tmp2->PATRONYMIC:=     mo_read_xml_stroke(oXmlNode,"PATRONYMIC",aerr,.f.)
    tmp2->BIRTHDAY  :=     mo_read_xml_stroke(oXmlNode,"BIRTHDAY",aerr,.f.)
    tmp2->SEX       :=     mo_read_xml_stroke(oXmlNode,"SEX",aerr,.f.)
    tmp2->SS        :=     mo_read_xml_stroke(oXmlNode,"SS",aerr,.f.)
    tmp2->TYPE_P    :=     mo_read_xml_stroke(oXmlNode,"TYPE_P",aerr,.f.)
    tmp2->SER_P     :=     mo_read_xml_stroke(oXmlNode,"SER_P",aerr,.f.)
    tmp2->NUM_P     :=     mo_read_xml_stroke(oXmlNode,"NUM_P",aerr,.f.)
    tmp2->ENP       :=     mo_read_xml_stroke(oXmlNode,"ENP",aerr,.f.)
    tmp2->DOCTYPE   :=     mo_read_xml_stroke(oXmlNode,"DOCTYPE",aerr,.f.)
    tmp2->DOCSER    :=     mo_read_xml_stroke(oXmlNode,"DOCSER",aerr,.f.)
    tmp2->DOCNUM    :=     mo_read_xml_stroke(oXmlNode,"DOCNUM",aerr,.f.)
    tmp2->MR        :=     mo_read_xml_stroke(oXmlNode,"MR",aerr,.f.)
    tmp2->PLACE     :=     mo_read_xml_stroke(oXmlNode,"PLACE",aerr,.f.)
    if (oNode1 := oXmlNode:Find("CONTACTS")) != NIL
      tmp2->TEL_F   :=     mo_read_xml_stroke(oNode1,"TEL_F",aerr,.f.)
      tmp2->TEL_M   :=     mo_read_xml_stroke(oNode1,"TEL_M",aerr,.f.)
      if (oNode2 := oNode1:Find("ADDRESS")) != NIL
        tmp2->SUBJ  :=     mo_read_xml_stroke(oNode2,"SUBJ",aerr,.f.)
        tmp2->UL    :=     mo_read_xml_stroke(oNode2,"UL",aerr,.f.)
      endif
    endif
    if (oNode1 := oXmlNode:Find("SPECIALISATIONS")) != NIL
      _ar := mo_read_xml_array(oNode1,"SPECIALISATION")
      for j1 := 1 to len(_ar)
        lprvs := mo_read_xml_stroke(oNode1,"SPECIALIST",aerr,.f.)
        if (oNode2 := oXmlNode:Find("REASONS")) != NIL
          _ar2 := mo_read_xml_array(oNode2,"REASON")
          for j2 := 1 to len(_ar2)
            select TMP5
            append blank
            tmp5->N_ZAP := tmp2->_N_ZAP
            tmp5->PRVS := lprvs
            tmp5->DS := mo_read_xml_stroke(oNode2,"DS",aerr,.f.)
            tmp5->DATE_B := mo_read_xml_stroke(oNode2,"DATE_B",aerr,.f.)
            tmp5->DATE_VISIT := mo_read_xml_stroke(oNode2,"DATE_VISIT",aerr,.f.)
          next j2
        endif
      next j1
    endif
  endif
NEXT j
tmp2->(dbCloseArea())
tmp5->(dbCloseArea())
rest_box(buf)
return NIL

***** 27.11.18 ������ D02 �� �६���� 䠩��
Function reestr_D02_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("��ᯠ�����/�⥭��/������ 䠩�� "+mname_xml)
dbcreate(cur_dir+"tmp1file", {;
 {"_VERSION",   "C",  5,0},;
 {"_DATE_F",    "D",  8,0},;
 {"_NAME_F",    "C", 26,0},;
 {"_NAME_FE",   "C", 26,0},;
 {"KOL",        "N",  6,0},; // ������⢮ ��樥�⮢ � ॥���/䠩��
 {"KOL_ERR",    "N",  6,0};  // ������⢮ ��樥�⮢ � �訡���� � ॥���
})
dbcreate(cur_dir+"tmp2file", {;
 {"_N_ZAP",     "N",  6,0},;
 {"_SMO",       "C",  5,0},;
 {"_ENP",       "C", 16,0},;
 {"_OPLATA",    "N",  1,0};
})
dbcreate(cur_dir+"tmp3file", {;
 {"_N_ZAP",     "N",  6,0},;
 {"_ERROR",     "N",  3,0};
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION",aerr)
      tmp1->_DATE_F  := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_F", aerr))
      tmp1->_NAME_F  :=          mo_read_xml_stroke(oXmlNode,"NAME_F", aerr)
      tmp1->_NAME_FE :=          mo_read_xml_stroke(oXmlNode,"NAME_FE",aerr)
    case "ERRS" == oXmlNode:title
      select TMP3
      append blank
      tmp3->_N_ZAP := 0
      tmp3->_ERROR := val(mo_read_xml_tag(oXmlNode,aerr))
    case "ZAPS" == oXmlNode:title
      select TMP2
      append blank
      tmp2->_N_ZAP  := val(mo_read_xml_stroke(oXmlNode,"ZAP",aerr))
      tmp2->_ENP    :=     mo_read_xml_stroke(oXmlNode,"ENP",aerr,.f.)
      tmp2->_SMO    :=     mo_read_xml_stroke(oXmlNode,"SMO",aerr,.f.)
      tmp2->_OPLATA := val(mo_read_xml_stroke(oXmlNode,"RESULT",aerr))
      if tmp2->_OPLATA > 1 .and. (oNode1 := oXmlNode:Find("ERRORS")) != NIL
        _ar := mo_read_xml_array(oNode1,"ERROR")
        for j1 := 1 to len(_ar)
          select TMP3
          append blank
          tmp3->_N_ZAP := tmp2->_N_ZAP
          tmp3->_ERROR := val(_ar[j1])
        next
      endif
  endcase
NEXT j
commit
rest_box(buf)
return NIL

***** 29.11.18 ������ � "ࠧ����" �� ����� ������ 䠩� D02
Function read_XML_FILE_D02(arr_XML_info,aerr,/*@*/current_i2,lrec_xml)
Local count_in_schet := 0, bSaveHandler, ii1, ii2, i, j, k, t_arr[2], ldate_D02, s, err_file := .f.
DEFAULT lrec_xml TO 0
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
ldate_D02 := tmp1->_DATE_F
R_Use(dir_server+"mo_d01",,"REES")
goto (arr_XML_info[7])
strfile("��ࠡ��뢠���� �⢥� ����� (D02) �� ���ଠ樮��� ����� "+alltrim(rees->NAME_XML)+sxml+hb_eol()+;
        "�� "+date_8(rees->DSCHET)+"�. ("+lstr(rees->kol)+" 祫.)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
rees_kol := rees->kol
//
R_Use(dir_server+"mo_d01k",,"RHUM")
index on str(D01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
use (cur_dir+"tmp2file") new alias TMP2
i := 0 ; k := lastrec()
// ᭠砫� �஢�ઠ
ii1 := ii2 := 0
go top
do while !eof()
  @ maxrow(),0 say str(++i/k*100,6,2)+"%" color cColorWait
  if tmp2->_OPLATA == 1
    ++ii1
    if !empty(tmp2->_SMO) .and. ascan(glob_arr_smo,{|x| x[2] == int(val(tmp2->_SMO)) }) == 0
      aadd(aerr,"�����४⭮� ���祭�� ��ਡ�� SMO: "+tmp2->_SMO)
    endif
  elseif between(tmp2->_OPLATA,2,4)
    ++ii2
  else
    aadd(aerr,"�����४⭮� ���祭�� ��ਡ�� RESULT: "+lstr(tmp2->_OPLATA))
  endif
  select RHUM
  find (str(tmp2->_N_ZAP,6))
  if !found()
    aadd(aerr,"�� ������ ��砩 � N_ZAP = "+lstr(tmp2->_N_ZAP))
  endif
  select TMP2
  skip
enddo
tmp1->kol := ii1
tmp1->kol_err := ii2
if empty(ii2)
  use (cur_dir+"tmp3file") new alias TMP3
  index on str(_n_zap,6) to (cur_dir+"tmp3")
  find (str(0,6))
  err_file := found() // �訡�� �� �஢�� 䠩��
endif
close databases
if empty(aerr) // �᫨ �஢�ઠ ��諠 �ᯥ譮
  // ����襬 �ਭ������ 䠩� (॥��� ��)
  //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
  chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
  G_Use(dir_server+"mo_xml",,"MO_XML")
  if empty(lrec_xml)
    AddRecN()
  else
    goto (lrec_xml)
    G_RLock(forever)
  endif
  mo_xml->KOD := recno()
  mo_xml->KOD := recno()
  mo_xml->FNAME := cReadFile
  mo_xml->DFILE := ldate_D02
  mo_xml->TFILE := ""
  mo_xml->DREAD := sys_date
  mo_xml->TREAD := hour_min(seconds())
  mo_xml->TIP_IN := _XML_FILE_D02 // ⨯ �ਭ�������� 䠩��
  mo_xml->DWORK  := sys_date
  mo_xml->TWORK1 := cTimeBegin
  mo_xml->REESTR := mkod_reestr
  mo_xml->KOL1 := ii1
  mo_xml->KOL2 := ii2
  //
  mXML_REESTR := mo_xml->KOD
  use
  G_Use(dir_server+"mo_d01",,"REES")
  goto (mkod_reestr)
  G_RLock(forever)
  rees->answer := 1
  if ii2 > 0
    rees->kol_err := ii2
  elseif err_file
    rees->kol_err := -1
  endif
  use
  if ii2 > 0 .or. err_file
    use (cur_dir+"tmp3file") new alias TMP3
    index on str(_n_zap,6) to (cur_dir+"tmp3")
    G_Use(dir_server+"mo_d01e",,"REFR")
    index on str(REESTR,6)+str(D01_ZAP,6) to (cur_dir+"tmp_D01e")
    if err_file
      select REFR
      do while .t.
        find (str(mkod_reestr,6)+str(0,6))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      strfile("�訡�� �� �஢�� 䠩��:"+hb_eol(),cFileProtokol,.t.)
      select TMP3
      find (str(0,6))
      do while tmp3->_N_ZAP == 0 .and. !eof()
        select REFR
        AddRec(6)
        refr->reestr := mkod_reestr
        refr->D01_ZAP := 0
        refr->KOD_ERR := tmp3->_ERROR
        if (j := ascan(glob_T012, {|x| x[2] == tmp3->_ERROR })) > 0
          strfile(space(8)+"�訡�� "+lstr(tmp3->_ERROR)+" - "+glob_T012[j,1]+hb_eol(),cFileProtokol,.t.)
        else
          strfile(space(8)+"�訡�� "+lstr(tmp3->_ERROR)+" (�������⭠� �訡��)"+hb_eol(),cFileProtokol,.t.)
        endif
        select TMP3
        skip
      enddo
    endif
    tmp3->(dbCloseArea())
  endif
  G_Use(dir_server+"kartote2",,"KART2")
  G_Use(dir_server+"kartote_",,"KART_")
  G_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"mo_d01k",,"RHUM")
  index on str(D01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  i := 0
  if err_file
    go top
    do while !eof()
      @ maxrow(),0 say str(++i/rees_kol*100,6,2)+"%" color cColorWait
      G_RLock(forever)
      rhum->OPLATA := 2 // �����⢥��� ��ᢠ����� �訡�� "2"
      skip
    enddo
  else
    use (cur_dir+"tmp3file") new alias TMP3
    index on str(_n_zap,6) to (cur_dir+"tmp3")
    use (cur_dir+"tmp2file") new alias TMP2
    index on str(_n_zap,6) to (cur_dir+"tmp2")
    count_in_schet := lastrec() ; current_i2 := 0
    go top
    do while !eof()
      @ maxrow(),0 say str(++i/k*100,6,2)+"%" color cColorWait
      select RHUM
      find (str(tmp2->_N_ZAP,6))
      G_RLock(forever)
      rhum->OPLATA := tmp2->_OPLATA
      if !empty(tmp2->_enp)
        select KART2
        do while kart2->(lastrec()) < rhum->kod_k
          APPEND BLANK
        enddo
        goto (rhum->kod_k)
        if len(alltrim(kart2->kod_mis)) != 16
          G_RLock(forever)
          kart2->kod_mis := tmp2->_enp
          dbUnLock()
        endif
      endif
      if tmp2->_OPLATA > 1
        --count_in_schet    // �� ����砥��� � ���,
        if current_i2 == 0
          strfile(space(10)+"���᮪ ��砥� � �訡����:"+hb_eol()+hb_eol(),cFileProtokol,.t.)
        endif
        ++current_i2
        kart->(dbGoto(rhum->kod_k))
        if empty(kart->fio)
          strfile(str(tmp2->_N_ZAP,6)+". ��樥�� � ����� �� ����⥪� "+lstr(kart->(recno()))+hb_eol(),cFileProtokol,.t.)
        else
          strfile(str(tmp2->_N_ZAP,6)+". "+alltrim(kart->fio)+", "+full_date(kart->date_r)+hb_eol(),cFileProtokol,.t.)
        endif
        select REFR
        do while .t.
          find (str(mkod_reestr,6)+str(tmp2->_N_ZAP,6))
          if !found() ; exit ; endif
          DeleteRec(.t.)
        enddo
        select TMP3
        find (str(tmp2->_N_ZAP,6))
        do while tmp2->_N_ZAP == tmp3->_N_ZAP .and. !eof()
          select REFR
          AddRec(6)
          refr->reestr := mkod_reestr
          refr->D01_ZAP := tmp2->_N_ZAP
          refr->KOD_ERR := tmp3->_ERROR
          if (j := ascan(glob_T012, {|x| x[2] == tmp3->_ERROR })) > 0
            strfile(space(8)+"�訡�� "+lstr(tmp3->_ERROR)+" - "+glob_T012[j,1]+hb_eol(),cFileProtokol,.t.)
          else
            strfile(space(8)+"�訡�� "+lstr(tmp3->_ERROR)+" (�������⭠� �訡��)"+hb_eol(),cFileProtokol,.t.)
          endif
          select TMP3
          skip
        enddo
        if tmp2->_OPLATA == 3
          strfile(space(8)+"�� ��⠭������ ���客�� �ਭ����������"+hb_eol(),cFileProtokol,.t.)
        elseif tmp2->_OPLATA == 4
          strfile(space(8)+"�� ��⠭������ ���客�� �ਭ����������, �� ���⢥ত��� �ਪ९����� � ��"+hb_eol(),cFileProtokol,.t.)
        endif
      endif
      UnLock ALL
      select TMP2
      if recno() % 1000 == 0
        Commit
      endif
      skip
    enddo
  endif
endif
close databases
return count_in_schet

***** 03.12.18
Function delete_reestr_D01(mkod_reestr)
Local ret := -1, rec, ir, fl := .t.
if f_Esc_Enter("���㫨஢���� D01")
  mywait()
  select REES
  goto (mkod_reestr)
  G_Use(dir_server+"mo_d01d",,"DD")
  index on str(kod_d,6) to (cur_dir+"tmp_d01d")
  G_Use(dir_server+"mo_d01k",,"DK")
  index on str(reestr,6) to (cur_dir+"tmp_d01k")
  do while .t.
    select DK
    find (str(mkod_reestr,6))
    if found()
      select DD
      do while .t.
        find (str(dk->(recno()),6))
        if found()
          DeleteRec(.t.)
        else
          exit
        endif
      enddo
      select DK
      DeleteRec(.t.)
    else
      exit
    endif
  enddo
  select MO_XML
  goto (rees->KOD_XML)
  DeleteRec(.t.)
  select REES
  DeleteRec(.t.)
  dbUnlockAll()
  dbCommitAll()
  stat_msg("���㫨஢���� �����襭�!") ; mybell(2,OK)
  ret := 1
endif
return ret

***** 29.11.18 ���㫨஢��� �⥭�� �����⠭���� ॥��� D02
Function delete_reestr_D02(mkod_reestr,mname_reestr)
Local i, s, r := row(), r1, r2, buf := save_maxrow(), ;
      mm_menu := {}, mm_func := {}, mm_flag := {}, mreestr_sp_tk, ;
      arr_f, cFile, oXmlDoc, aerr := {}, is_allow_delete, ;
      cFileProtokol := "tmp"+stxt
mywait()
select MO_XML
index on FNAME to (cur_dir+"tmp_xml") ;
      for reestr == mkod_reestr .and. tip_in == _XML_FILE_D02 .and. TIP_OUT == 0
go top
do while !eof()
  aadd(mm_func, mo_xml->kod)
  s := "��⮪�� �⥭�� "+rtrim(mo_xml->FNAME)+" ���⠭ "+date_8(mo_xml->DWORK)
  if empty(mo_xml->TWORK2)
    aadd(mm_flag,.t.)
    s += "-������� �� ��������"
  else
    aadd(mm_flag,.f.)
    s += " � "+mo_xml->TWORK1
  endif
  aadd(mm_menu,s)
  skip
enddo
select MO_XML
set index to
rest_box(buf)
if len(mm_menu) == 0
  func_error(4,"�� �뫮 �⥭�� 䠩�� D02...")
  return 0
endif
if r <= 18
  r1 := r+1 ; r2 := r1+len(mm_menu)+1
else
  r2 := r-1 ; r1 := r2-len(mm_menu)-1
endif
if (i := popup_prompt(r1,10,1,mm_menu,,,color5)) > 0
  is_allow_delete := mm_flag[i]
  mreestr_sp_tk := mm_func[i]
  select MO_XML
  goto (mreestr_sp_tk)
  cFile := alltrim(mo_xml->FNAME)
  mtip_in := mo_xml->TIP_IN
  close databases
  if !is_allow_delete
    func_error(4,"���� "+cFile+sxml+" ���४⭮ ���⠭. ���㫨஢���� ����饭�!")
    return 0
  endif
  if (arr_f := Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip)) != NIL
    cFile += sxml
    // �⠥� 䠩� � ������
    oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile)
    if oXmlDoc == NIL .or. Empty( oXmlDoc:aItems )
      func_error(4,"�訡�� � �⥭�� 䠩�� "+cFile)
    else // �⠥� � �����뢠�� XML-䠩� �� �६���� TMP-䠩��
      reestr_D02_tmpfile(oXmlDoc,aerr,cFile)
      if !empty(aerr)
        Ins_Array(aerr,1,"")
        Ins_Array(aerr,1,center("�訡�� � �⥭�� 䠩�� "+cFile,80))
        aeval(aerr,{|x| strfile(x+hb_eol(),cFileProtokol,.t.) })
        viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
        delete file (cFileProtokol)
      else
        if !is_allow_delete .and. involved_password(2,cFile,"���㫨஢���� �⥭�� 䠩�� D02")
          is_allow_delete := .t.
        endif
        if is_allow_delete
          close databases
          G_Use(dir_server+"mo_d01",,"REES")
          goto (mkod_reestr)
          use (cur_dir+"tmp1file") new alias TMP1
          use (cur_dir+"tmp2file") new alias TMP2
          arr := {}
          aadd(arr,"���ଠ樮��� ����� "+alltrim(rees->NAME_XML)+sxml+" �� "+date_8(rees->DSCHET)+"�.")
          aadd(arr,"�� "+lstr(rees->NYEAR)+" ���, ���-�� ��樥�⮢ "+lstr(rees->kol)+" 祫.")
          aadd(arr,"")
          G_Use(dir_server+"mo_xml",,"MO_XML")
          goto (mreestr_sp_tk)
          aadd(arr,"���㫨����� 䠩� �⢥� "+cFile+" �� "+date_8(mo_xml->DFILE)+"�.")
          aadd(arr,"��᫥ ���⢥ত���� ���㫨஢���� �� ��᫥��⢨� �⥭�� �������")
          aadd(arr,"䠩�� D02, � ⠪�� ᠬ 䠩� D02, ���� 㤠����.")
          f_message(arr,,cColorSt2Msg,cColorSt1Msg)
          s := "���⢥न� ���㫨஢���� 䠩�� D02"
          stat_msg(s) ; mybell(1)
          is_allow_delete := .f.
          if f_Esc_Enter("���㫨஢����",.t.)
            stat_msg(s+" ��� ࠧ.") ; mybell(3)
            if f_Esc_Enter("���㫨஢����",.t.)
              mywait()
              is_allow_delete := .t.
            endif
          endif
          close databases
        endif
        if is_allow_delete
          G_Use(dir_server+"mo_xml",,"MO_XML")
          G_Use(dir_server+"mo_d01",,"REES")
          goto (mkod_reestr)
          G_RLock(forever)
          rees->answer := 0
          rees->kol_err := 0
          G_Use(dir_server+"mo_d01e",,"REFR")
          index on str(REESTR,6)+str(D01_ZAP,6) to (cur_dir+"tmp_D01e")
          select REFR
          do while .t.
            find (str(mkod_reestr,6)+str(0,6)) // 㤠��� �訡�� �� �஢�� 䠩��
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          G_Use(dir_server+"mo_d01k",,"RHUM")
          index on str(D01_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
          use (cur_dir+"tmp2file") new alias TMP2
          go top
          do while !eof()
            select RHUM
            find (str(tmp2->_N_ZAP,6))
            G_RLock(forever)
            rhum->OPLATA := 0
            UnLock
            select REFR
            do while .t.
              find (str(mkod_reestr,6)+str(tmp2->_N_ZAP,6))
              if !found() ; exit ; endif
              DeleteRec(.t.)
            enddo
            select TMP2
            skip
          enddo
          select MO_XML
          goto (mreestr_sp_tk)
          DeleteRec()
          close databases
          stat_msg("���� "+cFile+" �ᯥ譮 ���㫨஢��. ����� ������ ��� ࠧ.") ; mybell(5)
        endif
      endif
    endif
  endif
endif
rest_box(buf)
return 0
