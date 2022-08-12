***** mo_omsid.prg - ���ଠ�� �� ��ᯠ��ਧ�樨 � ���
#include "inkey.ch"
#include "fastreph.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define MONTH_UPLOAD 9 //����� ��� ���㧪� R11

Static lcount_uch  := 1
Static mas1pmt := {"~�� �������� ��砨",;
                   "��砨 � ���⠢������ ~����",;
                   "��砨 � ��~ॣ����஢����� ����"}

***** 28.10.18 ��ᯠ��ਧ���, ��䨫��⨪� � ����ᬮ���
Function dispanserizacia(k)
Static si1 := 1, si2 := 1, sj := 1, sj1 := 1
Local mas_pmt, mas_msg, mas_fun, j, j1
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~���-����",;
                "~���᫮� ��ᥫ����",;
                "~��ᮢ��襭����⭨�",;
                "~������� ���ଠ��"}
    mas_msg := {"���ଠ�� �� ��ᯠ��ਧ�樨 ��⥩-���",;
                "���ଠ�� �� ��ᯠ��ਧ�樨 � ��䨫��⨪� ���᫮�� ��ᥫ����",;
                "���ଠ�� �� ����樭᪨� �ᬮ�ࠬ ��ᮢ��襭����⭨�",;
                "������ ���㬥��� �� �ᥬ ����� ��ᯠ��ਧ�樨 � ��䨫��⨪�"}
    mas_fun := {"dispanserizacia(11)",;
                "dispanserizacia(12)",;
                "dispanserizacia(13)",;
                "dispanserizacia(14)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    inf_DDS()
  case k == 12
    inf_DVN()
  case k == 13
    inf_DNL()
  case k == 14
    inf_DISP()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

***** 23.09.20 ���ଠ�� �� ��ᯠ��ਧ�樨 ��⥩-���
Function inf_DDS(k)
Static si1 := 1, si2 := 1, sj := 1, sj1 := 1, sj2 := 1
Local mas_pmt, mas_msg, mas_fun, j, j1
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~���� ��ᯠ��ਧ�樨",;
                "~���᮪ ��樥�⮢",;
                "����� ��� ���~��ࠢ�",;
                "��ଠ � 030-�/�/~�-13",;
                "XML-䠩� ��� ~���⠫� ����"}
    mas_msg := {"��ᯥ�⪠ ����� ��ᯠ��ਧ�樨 (���⭠� �ଠ � 030-�/�/�-13)",;
                "��ᯥ�⪠ ᯨ᪠ ��樥�⮢, ����� �஢����� ��ᯠ��ਧ��� ��⥩-���",;
                "��ᯥ�⪠ ࠧ����� ᢮��� ��� �����ࠢ� ������ࠤ᪮� ������",;
                "�������� � ��ᯠ��ਧ�樨 ��ᮢ��襭����⭨� (����⭠� �ଠ � 030-�/�/�-13)",;
                "�������� XML-䠩�� ��� ����㧪� �� ���⠫ �����ࠢ� ��"}
    mas_fun := {"inf_DDS(11)",;
                "inf_DDS(12)",;
                "inf_DDS(13)",;
                "inf_DDS(14)",;
                "inf_DDS(15)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case between(k,11,19)
    if (j := popup_prompt(T_ROW,T_COL-5,sj,;
        {"��室�騥�� � ��樮���","��室�騥�� ��� ������"})) == 0
      return NIL
    endif
    sj := j
    Private p_tip_lu := iif(j==1, TIP_LU_DDS, TIP_LU_DDSOP)
    do case
      case k == 11
        inf_DDS_karta()
      case k == 12
        if (j1 := popup_prompt(T_ROW,T_COL-5,3,mas1pmt)) > 0
          inf_DDS_svod(1,,j1)
        endif
      case k == 13
        if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
          if (j := popup_prompt(T_ROW,T_COL-5,sj2,;
              {"�뢮� ⠡���� � ᯨ᪮� ��⥩",;
               "�뢮� � Excel ��� �����",;
               "�뢮� ⠡���� � ����� �14-05/50",;
               "�뢮� ⠡���� 2510"})) > 0
            sj2 := j
            if j > 2
              inf_DDS_svod2(j,j1)
            else
              inf_DDS_svod(2,j,j1)
            endif
          endif
        endif
      case k == 14
        if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
          inf_DDS_030dso(j1)
        endif
      case k == 15
        if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
          inf_DDS_XMLfile(j1)
        endif
    endcase
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

***** 12.07.13 ��ᯥ�⪠ ����� ��ᯠ��ਧ�樨 (���⭠� �ଠ � 030-�/�/�-13)
Function inf_DDS_karta()
Local arr_m, buf := save_maxrow(), blk, t_arr[BR_LEN]
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,.f.)
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmp")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_TITUL] := "��ᯠ��ਧ��� ��⥩-��� "+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'�','�','�',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(human->schet > 0, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" �.�.�.", {|| padr(human->fio,39) }, blk },;
                         {"��� ஦�.", {|| full_date(human->date_r) }, blk },;
                         {"� ��.�����", {|| human->uch_doc }, blk },;
                         {"�ப� ���-�", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"�⠯", {|| iif(human->ishod==101," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Enter>^ - �ᯥ���� ����� ��ᯠ��ਧ�樨") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_DDS_karta(nk,ob,"edit") }
    edit_browse(t_arr)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 11.03.19
Function f0_inf_DDS(arr_m,is_schet,is_reg,is_snils)
Local fl := .t.
DEFAULT is_schet TO .t., is_reg TO .f., is_snils TO .f.
if !del_dbf_file("tmp"+sdbf)
  return .f.
endif
dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                        {"is", "N",1,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
index on kod to (cur_dir+"tmp_h") ;
      for iif(p_tip_lu==TIP_LU_DDS,!empty(za_smo),empty(za_smo)) .and. ;
          eq_any(ishod,101,102) .and. iif(is_schet, schet > 0, .t.) ;
      while human->k_data <= arr_m[6] ;
      PROGRESS
go top
do while !eof()
  fl := .t.
  if is_reg
    fl := .f.
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      fl := .t.
    endif
  endif
  if fl .and. ret_koef_from_RAK(human->kod) > 0
    select TMP
    append blank
    tmp->kod := human->kod
    tmp->is := iif(is_snils .and. empty(kart->snils), 0, 1)
  endif
  select HUMAN
  skip
enddo
fl := .t.
if tmp->(lastrec()) == 0
  fl := func_error(4,"�� ������� �/� �� ��ᯠ��ਧ�樨 ��⥩-��� "+arr_m[4])
endif
close databases
return fl

***** 05.07.13
Function f1_inf_DDS_karta(nKey,oBrow,regim)
Local ret := -1, lkod_h, lkod_k, rec := tmp->(recno()), buf := save_maxrow()
if regim == "edit" .and. nKey == K_ENTER
  mywait()
  lkod_h := human->kod
  lkod_k := human->kod_k
  close databases
  oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_karta")
  eval(blk_open)
  goto (rec)
  rest_box(buf)
endif
return ret

***** 22.04.18
Function f2_inf_DDS_karta(Loc_kod,kod_kartotek,lvozrast)
Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {|s| __dbAppend(), field->stroke := s }
delFRfiles()
R_Use(dir_server+"mo_stdds")
if type("m1stacionar") == "N" .and. m1stacionar > 0
  goto (m1stacionar)
endif
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
R_Use(dir_server+"mo_pers",,"P2")
goto (m1vrach)
R_Use(dir_server+"organiz",,"ORG")
adbf := {{"name","C",130,0},;
         {"prikaz","C",50,0},;
         {"forma","C",50,0},;
         {"titul","C",100,0},;
         {"fio","C",50,0},;
         {"k_data","C",40,0},;
         {"vrach","C",40,0},;
         {"glavn","C",40,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->fio := mfio
frt->k_data := date_month(mk_data)
frt->vrach := fam_i_o(p2->fio)
frt->glavn := fam_i_o(org->ruk)
adbf := {{"stroke","C",2000,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
if p_tip_lu == TIP_LU_PN // ��䨫��⨪� ��ᮢ��襭����⭨�
  frt->prikaz := "�� 21.12.2012�. � 1346�"
  frt->forma  := "030-��/�-12"
  frt->titul  := "���� ��䨫����᪮�� ����樭᪮�� �ᬮ�� ��ᮢ��襭����⭥��"
  s := st+"1. �������, ���, ����⢮ ��ᮢ��襭����⭥��: "+ub+alltrim(mfio)+ue+"."
  frd->(eval(blk,s))
  s := st+"���: "+f3_inf_DDS_karta({{"��.","�"},{"���.","�"}},mpol,"/",ub,ue)
  frd->(eval(blk,s))
  s := st+"��� ஦�����: "+ub+date_month(mdate_r,.t.)+ue+"."
  frd->(eval(blk,s))
  s := st+"2. ����� ��易⥫쭮�� ����樭᪮�� ���客����: "
  s += "��� "+iif(empty(mspolis), replicate("_",15), ub+alltrim(mspolis)+ue)
  s += " � "+ub+alltrim(mnpolis)+ue+"."
  frd->(eval(blk,s))
  s := st+"���客�� ����樭᪠� �࣠������: "+ub+alltrim(mcompany)+ue+"."
  frd->(eval(blk,s))
  s := st+"3. ���客�� ����� �������㠫쭮�� ��楢��� ���: "
  s += iif(empty(kart->snils), replicate("_",25), ub+transform(kart->SNILS,picture_pf)+ue)+"."
  frd->(eval(blk,s))
  s := st+"4. ���� ���� ��⥫��⢠: "
  if emptyall(kart_->okatog,kart->adres)
    s += replicate("_",50)+" "+replicate("_",sh)+"."
  else
    s += ub+ret_okato_ulica(kart->adres,kart_->okatog,1,2)+ue+"."
  endif
  frd->(eval(blk,s))
  s := st+"5. ��⥣���: "+f3_inf_DDS_karta(mm_kateg_uch,m1kateg_uch,"; ",ub,ue)
  frd->(eval(blk,s))
  s := st+"6. ������ ������������ ����樭᪮� �࣠����樨, � ���ன "+;
          "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
  s += ub+ret_mo(m1MO_PR)[_MO_FULL_NAME]+ue+"."
  frd->(eval(blk,s))
  s := st+"7. �ਤ��᪨� ���� ����樭᪮� �࣠����樨, � ���ன " +;
           "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
  s += ub+ret_mo(m1MO_PR)[_MO_ADRES]+ue+"."
  frd->(eval(blk,s))
  madresschool := ""
  if type("m1school") == "N" .and. m1school > 0
    R_Use(dir_server+"mo_schoo",,"SCH")
    goto (m1school)
    if !empty(sch->fname)
      mschool := alltrim(sch->fname)
      madresschool := alltrim(sch->adres)
    endif
  endif
  s := st+"8. ������ ������������ ��ࠧ���⥫쭮�� ��०�����, � ���஬ "+;
          "���砥��� ��ᮢ��襭����⭨�: "+ub+mschool+ue+"."
  frd->(eval(blk,s))
  s := st+"9. �ਤ��᪨� ���� ��ࠧ���⥫쭮�� ��०�����, � ���஬ "+;
          "���砥��� ��ᮢ��襭����⭨�: "
  if empty(madresschool)
    frd->(eval(blk,s))
    s := replicate("_",sh)+"."
  else
    s += ub+madresschool+ue+"."
  endif
  frd->(eval(blk,s))
  s := st+"10. ��� ��砫� ����樭᪮�� �ᬮ��: "+ub+full_date(mn_data)+ue+"."
  frd->(eval(blk,s))
else // ��ᯠ��ਧ��� ��⥩-���
  frt->prikaz := "�� 15.02.2013�. � 72�"
  frt->forma  := "030-�/�/�-13"
  frt->titul  := "���� ��ᯠ��ਧ�樨 ��ᮢ��襭����⭥��"
  s := st+"1. ������ ������������ ��樮��୮�� ��०�����: "
  if p_tip_lu == TIP_LU_DDS
    s += ub+alltrim(mstacionar)+ue+"."
    frd->(eval(blk,s))
  else
    frd->(eval(blk,s))
    s := replicate("_",sh)+"."
    frd->(eval(blk,s))
  endif
  s := st+"1.1. �०��� ������������ (� ��砥 ��� ���������):"
  frd->(eval(blk,s))
  s := replicate("_",sh)+"."
  frd->(eval(blk,s))
  s := st+"1.2. ������⢥���� �ਭ����������: "
  if p_tip_lu == TIP_LU_DDS
    i := mo_stdds->vedom
    if !between(i,0,3)
      i := 3
    endif
  else
    i := -1
  endif
  mm_vedom := {{"�࣠�� ��ࠢ���࠭����",0},;
               {"��ࠧ������",1},;
               {"�樠�쭮� �����",2},;
               {"��㣮�",3}}
  s += f3_inf_DDS_karta(mm_vedom,i,,ub,ue)
  frd->(eval(blk,s))
  s := st+"1.3. �ਤ��᪨� ���� ��樮��୮�� ��०�����: "
  if p_tip_lu == TIP_LU_DDS .and. !empty(mo_stdds->adres)
    s += ub+alltrim(mo_stdds->adres)+ue+"."
  endif
  frd->(eval(blk,s))
  if p_tip_lu == TIP_LU_DDSOP .or. empty(mo_stdds->adres)
    s := replicate("_",sh)+"."
    frd->(eval(blk,s))
  endif
  s := st+"2. �������, ���, ����⢮ ��ᮢ��襭����⭥��: "+ub+alltrim(mfio)+ue+"."
  frd->(eval(blk,s))
  s := st+"2.1. ���: "
  s += f3_inf_DDS_karta({{"��.","�"},{"���.","�"}},mpol,"/",ub,ue)
  frd->(eval(blk,s))
  s := st+"2.2. ��� ஦�����: "+ub+date_month(mdate_r,.t.)+ue+"."
  frd->(eval(blk,s))
  s := st+"2.3. ��⥣��� ��� ॡ����, ��室�饣��� � �殮��� ��������� ���樨: "
  s += f3_inf_DDS_karta(mm_kateg_uch,m1kateg_uch,"; ",ub,ue)
  frd->(eval(blk,s))
  s := st+"2.4. �� ������ �஢������ ��ᯠ��ਧ�樨 ��室���� "
  mm_gde_nahod1[3,1] := "�����⥫��⢮�"
  s += f3_inf_DDS_karta(mm_gde_nahod1,m1gde_nahod,,ub,ue)
  frd->(eval(blk,s))
  s := st+"3. ����� ��易⥫쭮�� ����樭᪮�� ���客����:"
  frd->(eval(blk,s))
  s := st+"��� "+iif(empty(mspolis), replicate("_",15), ub+alltrim(mspolis)+ue)
  s += " � "+ub+alltrim(mnpolis)+ue+"."
  frd->(eval(blk,s))
  s := st+"���客�� ����樭᪠� �࣠������: "+ub+alltrim(mcompany)+ue+"."
  frd->(eval(blk,s))
  s := st+"���客�� ����� �������㠫쭮�� ��楢��� ���: "
  s += iif(empty(kart->snils), replicate("_",25), ub+transform(kart->SNILS,picture_pf)+ue)+"."
  frd->(eval(blk,s))
  s := st+"4. ��� ����㯫���� � ��樮��୮� ��०�����: "
  s += iif(p_tip_lu==TIP_LU_DDSOP.or.empty(mdate_post), replicate("_",15), ub+full_date(mdate_post)+ue)+"."
  frd->(eval(blk,s))
  s := st+"5. ��稭� ����� �� ��樮��୮�� ��०�����: "
  Del_Array(mm_prich_vyb,1) // 㤠���� 1-� ������� "{"�� ���",0}"
  s += f3_inf_DDS_karta(mm_prich_vyb,m1prich_vyb,,ub,ue)
  frd->(eval(blk,s))
  s := st+"5.1. ��� �����: "+iif(empty(mDATE_VYB), replicate("_",15), ub+full_date(mDATE_VYB)+ue)+"."
  frd->(eval(blk,s))
  s := st+"6. ��������� �� ������ �஢������ ��ᯠ��ਧ�樨:"
  frd->(eval(blk,s))
  s := replicate("_",73)+" (㪠���� ��稭�)."
  frd->(eval(blk,s))
  s := st+"7. ���� ���� ��⥫��⢠: "
  if emptyall(kart_->okatog,kart->adres)
    s += replicate("_",50)+" "+replicate("_",sh)+"."
  else
    s += ub+ret_okato_ulica(kart->adres,kart_->okatog,1,2)+ue+"."
  endif
  frd->(eval(blk,s))
  s := st+"8. ������ ������������ ����樭᪮� �࣠����樨, ��࠭��� "+;
          "��ᮢ��襭����⭨� (��� த�⥫�� ��� ��� ������� �।�⠢�⥫��) "+;
          "��� ����祭�� ��ࢨ筮� ������-ᠭ��୮� �����: "
  s += ub+ret_mo(m1MO_PR)[_MO_FULL_NAME]+ue+"."
  frd->(eval(blk,s))
  s := st+"9. �ਤ��᪨� ���� ����樭᪮� �࣠����樨, ��࠭��� "+;
           "��ᮢ��襭����⭨� (��� த�⥫�� ��� ��� ������� �।�⠢�⥫��) "+;
           "��� ����祭�� ��ࢨ筮� ������-ᠭ��୮� �����: "
  s += ub+ret_mo(m1MO_PR)[_MO_ADRES]+ue+"."
  frd->(eval(blk,s))
  s := st+"10. ��� ��砫� ��ᯠ��ਧ�樨: "+ub+full_date(mn_data)+ue+"."
  frd->(eval(blk,s))
endif
s := st+"11. ������ ������������ � �ਤ��᪨� ���� ����樭᪮� �࣠����樨, "+;
        "�஢����襩 "+iif(p_tip_lu==TIP_LU_PN,"��䨫����᪨� ����樭᪨� �ᬮ��: ","��ᯠ��ਧ���: ")+;
        ub+glob_mo[_MO_FULL_NAME]+", "+glob_mo[_MO_ADRES]+ue+"."
frd->(eval(blk,s))
s := st+"12. �業�� 䨧��᪮�� ࠧ���� � ��⮬ ������ �� ������ "+;
        iif(p_tip_lu==TIP_LU_PN,"����樭᪮�� �ᬮ��:","��ᯠ��ਧ�樨:")
frd->(eval(blk,s))
count_ymd(mdate_r,mn_data,@y,@m,@d)
s := ub+st+lstr(d)+st+ue+" (�᫮ ����) "+;
     ub+st+lstr(m)+st+ue+" (����楢) "+;
     ub+st+lstr(y)+st+ue+" ���."
frd->(eval(blk,s))
mm_fiz_razv1 := {{"����� ����� ⥫�",1},{"����⮪ ����� ⥫�",2}}
mm_fiz_razv2 := {{"������ ���",1},{"��᮪�� ���",2}}
for i := 1 to 2
  s := st+"12."+lstr(i)+". ��� ��⥩ � ������ "+;
          {"0 - 4 ���: ","5 - 17 ��� �����⥫쭮: "}[i]
  if i == 1
    fl := (lvozrast < 5)
  else
    fl := (lvozrast > 4)
  endif
  s += "���� (��) "+iif(!fl,"________",ub+st+lstr(mWEIGHT)+st+ue)+"; "
  s += "��� (�) "+iif(!fl,"________",ub+st+lstr(mHEIGHT)+st+ue)+"; "
  s += "���㦭���� ������ (�) "+iif(!fl.or.mPER_HEAD==0,"________",ub+st+lstr(mPER_HEAD)+st+ue)+"; "
  s += "䨧��᪮� ࠧ��⨥ "+f3_inf_DDS_karta(mm_fiz_razv,iif(fl,m1FIZ_RAZV,-1),,ub,ue,.f.)
  s += " ("+f3_inf_DDS_karta(mm_fiz_razv1,iif(fl,m1FIZ_RAZV1,-1),,ub,ue,.f.)
  s += ", "+f3_inf_DDS_karta(mm_fiz_razv2,iif(fl,m1FIZ_RAZV2,-1),,ub,ue,.f.)
  s += " - �㦭�� ����ભ���)."
  frd->(eval(blk,s))
next
fl := (lvozrast < 5)
s := st+"13. �業�� ����᪮�� ࠧ���� (���ﭨ�):"
frd->(eval(blk,s))
s := st+"13.1. ��� ��⥩ � ������ 0 - 4 ���:"
frd->(eval(blk,s))
s := st+"�������⥫쭠� �㭪�� (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih11)+st+ue)+";"
frd->(eval(blk,s))
s := st+"���ୠ� �㭪�� (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih12)+st+ue)+";"
frd->(eval(blk,s))
s := st+"���樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih13)+st+ue)+";"
frd->(eval(blk,s))
s := st+"�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih14)+st+ue)+"."
frd->(eval(blk,s))
fl := (lvozrast > 4)
s := st+"13.2. ��� ��⥩ � ������ 5 - 17 ���:"
frd->(eval(blk,s))
s := st+"13.2.1. ��宬��ୠ� ���: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih21,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.2. ��⥫����: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih22,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.3. ���樮���쭮-�����⨢��� ���: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih23,-1),,ub,ue)
frd->(eval(blk,s))
fl := (mpol == "�" .and. lvozrast > 9)
s := st+"14. �業�� �������� ࠧ���� (� 10 ���):"
frd->(eval(blk,s))
s := st+"14.1. ������� ��㫠 ����稪�: � "+iif(!fl.or.m141p==0,"________",ub+st+lstr(m141p)+st+ue)
s += " �� "+iif(!fl.or.m141ax==0,"________",ub+st+lstr(m141ax)+st+ue)
s += " Fa "+iif(!fl.or.m141fa==0,"________",ub+st+lstr(m141fa)+st+ue)+"."
frd->(eval(blk,s))
fl := (mpol == "�" .and. lvozrast > 9)
s := st+"14.2. ������� ��㫠 ����窨: � "+iif(!fl.or.m142p==0,"________",ub+st+lstr(m142p)+st+ue)
s += " �� "+iif(!fl.or.m142ax==0,"________",ub+st+lstr(m142ax)+st+ue)
s += " Ma "+iif(!fl.or.m142ma==0,"________",ub+st+lstr(m142ma)+st+ue)
s += " Me "+iif(!fl.or.m142me==0,"________",ub+st+lstr(m142me)+st+ue)+";"
frd->(eval(blk,s))
s := st+"�ࠪ���⨪� ������㠫쭮� �㭪樨: menarhe ("
s += iif(!fl.or.m142me1==0,"________",ub+st+lstr(m142me1)+st+ue)+" ���, "
s += iif(!fl.or.m142me2==0,"________",ub+st+lstr(m142me2)+st+ue)+" ����楢); "
if fl .and. emptyall(m142p,m142ax,m142ma,m142me,m142me1,m142me2)
  m1142me3 := m1142me4 := m1142me5 := -1
endif
s += "menses (�ࠪ���⨪�): "+f3_inf_DDS_karta(mm_142me3,iif(fl,m1142me3,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me4,iif(fl,m1142me4,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me5,iif(fl,m1142me5,-1)," � ",ub,ue)
frd->(eval(blk,s))
s := st+"15. ����ﭨ� ���஢�� �� �஢������ "+;
     iif(p_tip_lu==TIP_LU_PN,"�����饣� ��䨫����᪮�� ����樭᪮�� �ᬮ��:","��ᯠ��ਧ�樨:")
frd->(eval(blk,s))
if lvozrast < 14
  mdef_diagnoz := "Z00.1"
else
  mdef_diagnoz := "Z00.3"
endif
s := st+"15.1. �ࠪ��᪨ ���஢ "+iif(m1diag_15_1==0,replicate("_",30),ub+st+rtrim(mdef_diagnoz)+st+ue)+" (��� �� ���)."
frd->(eval(blk,s))
//
mm_dispans := {{"��⠭������ ࠭��",1},{"��⠭������ �����",2},{"�� ��⠭������",0}}
mm_danet := {{"��",1},{"���",0}}
mm_usl := {{"� ���㫠���� �᫮����",0},;
           {"� �᫮���� �������� ��樮���",1},;
           {"� ��樮����� �᫮����",2}}
mm_uch := {{"� �㭨樯����� ����樭᪨� �࣠�������",1},;
           {"� ���㤠��⢥���� ����樭᪨� �࣠������� ��ꥪ� ���ᨩ᪮� �����樨 ",0},;
           {"� 䥤�ࠫ��� ����樭᪨� �࣠�������",2},;
           {"����� ����樭᪨� �࣠�������",3}}
mm_uch1 := aclone(mm_uch)
aadd(mm_uch1, {"ᠭ��୮-������� �࣠�������",4})
mm_danet1 := {{"�������",1},{"�� �������",0}}
for i := 1 to 5
  fl := .f.
  for k := 1 to 14
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,4,5,6,7)
            mvar := "m1diag_15_"+lstr(i)+"_3"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,9,10,11,12)
            mvar := "m1diag_15_"+lstr(i)+"_8"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case k == 14
            mvar := "m1diag_15_"+lstr(i)+"_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := ""
  for k := 1 to 14
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
    endif
    do case
      case k == 1
        s := st+"15."+lstr(i+1)+". ������� "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (��� �� ���)."
      case k == 2
        s1 := st+"15."+lstr(i+1)+".1. ��ᯠ��୮� �������: "+f3_inf_DDS_karta(mm_dispans,&m1var,,ub,ue)
      case k == 3
        s2 := st+"15."+lstr(i+1)+".2. ��祭�� �뫮 �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 4
        s2 := left(s2,len(s2)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 5
        s2 := left(s2,len(s2)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 6
        s3 := st+"15."+lstr(i+1)+".3. ��祭�� �뫮 �믮�����: "+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 7
        s3 := left(s3,len(s3)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 8
        s4 := st+"15."+lstr(i+1)+".4. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �뫨 �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 9
        s4 := left(s4,len(s4)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 10
        s4 := left(s4,len(s4)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
      case k == 11
        s5 := st+"15."+lstr(i+1)+".5. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �뫨 �믮�����: "+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 12
        s5 := left(s5,len(s5)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
      case k == 13
        s6 := st+"15."+lstr(i+1)+".6. ��᮪��孮����筠� ����樭᪠� ������ �뫠 ४����������: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 14
        s6 := left(s6,len(s6)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_danet1,&m1var,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
  frd->(eval(blk,s2))
  frd->(eval(blk,s3))
  frd->(eval(blk,s4))
  frd->(eval(blk,s5))
  frd->(eval(blk,s6))
next
mm_gruppa := {{"I",1},{"II",2},{"III",3},{"IV",4},{"V",5}}
s := st+"15.9. ��㯯� ���ﭨ� ���஢��: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA_DO,,ub,ue)
frd->(eval(blk,s))
if p_tip_lu == TIP_LU_PN
  s := st+"15.10. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "
  s += f3_inf_DDS_karta(mm_gr_fiz_do,m1GR_FIZ_DO,,ub,ue)
  frd->(eval(blk,s))
endif
s := st+"16. ����ﭨ� ���஢�� �� १���⠬ �஢������ "+;
     iif(p_tip_lu==TIP_LU_PN,"�����饣� ��䨫����᪮�� ����樭᪮�� �ᬮ��:","��ᯠ��ਧ�樨:")
frd->(eval(blk,s))
s := st+"16.1. �ࠪ��᪨ ���஢ "+iif(m1diag_16_1==0,replicate("_",30),ub+st+rtrim(mkod_diag)+st+ue)+" (��� �� ���)."
frd->(eval(blk,s))
for i := 1 to 5
  fl := .f.
  for k := 1 to 16
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,5,6)
            mvar := "m1diag_16_"+lstr(i)+"_4"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,8,9)
            mvar := "m1diag_16_"+lstr(i)+"_7"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,11,12)
            mvar := "m1diag_16_"+lstr(i)+"_10"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,14,15)
            mvar := "m1diag_16_"+lstr(i)+"_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
  for k := 1 to 16
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
    endif
    do case
      case k == 1
        s := st+"16."+lstr(i+1)+". ������� "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (��� �� ���)."
      case k == 2
        s1 := st+"16."+lstr(i+1)+".1. ������� ��⠭����� �����: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 3
        s2 := st+"16."+lstr(i+1)+".2. ��ᯠ��୮� �������: "+f3_inf_DDS_karta(mm_dispans,&m1var,,ub,ue)
      case k == 4
        s3 := st+"16."+lstr(i+1)+".3. �������⥫�� �������樨 � ��᫥������� �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 5
        s3 := left(s3,len(s3)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 6
        s3 := left(s3,len(s3)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 7
        s4 := st+"16."+lstr(i+1)+".4. �������⥫�� �������樨 � ��᫥������� �믮�����: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 8
        s4 := left(s4,len(s4)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 9
        s4 := left(s4,len(s4)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 10
        s5 := st+"16."+lstr(i+1)+".5. ��祭�� �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 11
        s5 := left(s5,len(s5)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 12
        s5 := left(s5,len(s5)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 13
        s6 := st+"16."+lstr(i+1)+".6. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 14
        s6 := left(s6,len(s6)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 15
        s6 := left(s6,len(s6)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
      case k == 16
        s7 := st+"16."+lstr(i+1)+".7. ��᮪��孮����筠� ����樭᪠� ������ �뫠 ४����������: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
  frd->(eval(blk,s2))
  frd->(eval(blk,s3))
  frd->(eval(blk,s4))
  frd->(eval(blk,s5))
  frd->(eval(blk,s6))
  frd->(eval(blk,s7))
next
if m1invalid1 == 0
  m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
  minvalid3 := minvalid4 := minvalid7 := ctod("")
endif
if empty(minvalid7)
  m1invalid8 := -1
endif
s := st+'16.7. ������������: '+f3_inf_DDS_karta(mm_danet,m1invalid1,,ub,ue)
s := left(s,len(s)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_invalid2,m1invalid2,,ub,ue)
s := left(s,len(s)-1)+'; ��⠭������ ����� (���) '+iif(empty(minvalid3), replicate("_",15), ub+full_date(minvalid3)+ue)
s += '; ��� ��᫥����� �ᢨ��⥫��⢮����� '+iif(empty(minvalid4), replicate("_",15), ub+full_date(minvalid4)+ue)+'.'
frd->(eval(blk,s))
s := st+'16.7.1. �����������, ���᫮���訥 ������������� �����������:'
frd->(eval(blk,s))
mm_invalid5[6,1] := "������� �஢�, �஢�⢮��� �࣠��� � �⤥��� ����襭��, ��������騥 ���㭭� ��堭���;"
mm_invalid5[7,1] := "������� �����ਭ��� ��⥬�, ����ன�⢠ ��⠭�� � ����襭�� ������ �����,"
atail(mm_invalid5)[1] := "��᫥��⢨� �ࠢ�, ��ࠢ����� � ��㣨� �������⢨� ���譨� ��稭)"
s := st+'('+f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.���� ����襭�� � ���ﭨ� ���஢��:'
frd->(eval(blk,s))
s := st+f3_inf_DDS_karta(mm_invalid6,m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. �������㠫쭠� �ணࠬ�� ॠ�����樨 ॡ����-��������:'
frd->(eval(blk,s))
s := st+'��� �����祭��: '+iif(empty(minvalid7), replicate("_",15), ub+full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'�믮������ �� ������ ��ᯠ��ਧ�樨: '+f3_inf_DDS_karta(mm_invalid8,m1invalid8,,ub,ue)
frd->(eval(blk,s))
s := st+"16.8. ��㯯� ���ﭨ� ���஢��: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA,,ub,ue)
frd->(eval(blk,s))
if p_tip_lu == TIP_LU_PN
  s := st+"16.9. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "
  s += f3_inf_DDS_karta(mm_gr_fiz,m1GR_FIZ,,ub,ue)
  frd->(eval(blk,s))
endif
s := st+iif(p_tip_lu==TIP_LU_PN,'16.10','16.9')+;
     '. �஢������ ��䨫����᪨� �ਢ����:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1)
  if m1privivki1 == mm_privivki1[j,2]
    s += ub
  endif
  s += mm_privivki1[j,1]
  if m1privivki1 == mm_privivki1[j,2]
    s += ue
  endif
  if mm_privivki1[j,2] == 0
    s += "; "
  else
    s += ": "+f3_inf_DDS_karta(mm_privivki2,iif(m1privivki1==mm_privivki1[j,2],m1privivki2,-1),,ub,ue,.f.)+"; "
  endif
next
s += '�㦤����� � �஢������ ���樭�樨 (ॢ��樭�樨) � 㪠������ ������������ �ਢ���� (�㦭�� ����ભ���): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate("_",sh)+"."
frd->(eval(blk,s))
s := st+iif(p_tip_lu==TIP_LU_PN,'16.11','16.10')+;
     '. ���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன: '
k := 3
if !empty(mrek_form)
  k := 1
  s += ub+alltrim(mrek_form)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
if p_tip_lu == TIP_LU_PN
  s := st+'16.12. ���������樨 � ����室����� ��⠭������� ��� �த������� '+;
          '��ᯠ��୮�� �������, ������ ������� ����������� (���ﭨ�) '+;
          '� ��� ���, �� ��祭��, ����樭᪮� ॠ�����樨 � '+;
          'ᠭ��୮-����⭮�� ��祭�� � 㪠������ ���� ����樭᪮� '+;
          '�࣠����樨 (ᠭ��୮-����⭮� �࣠����樨) � ᯥ樠�쭮�� '+;
          '(��������) ���: '
else
  s := st+'16.11. ���������樨 �� ��ᯠ��୮�� �������, ��祭��, '+;
          '����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ '+;
          '�������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� '+;
          '(��������) ���: '
endif
k := 5
if !empty(mrek_disp)
  k := 2
  s += ub+alltrim(mrek_disp)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
//
adbf := {{"name","C",60,0},;
         {"data","C",10,0},;
         {"rezu","C",17,0}}
dbcreate(fr_data+"1",adbf)
use (fr_data+"1") new alias FRD1
dbcreate(fr_data+"2",adbf)
use (fr_data+"2") new alias FRD2
arr := iif(p_tip_lu==TIP_LU_PN,f4_inf_DNL_karta(1),f4_inf_DDS_karta(1))
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i,1]
  frd1->data := full_date(arr[i,2])
next
arr := iif(p_tip_lu==TIP_LU_PN,f4_inf_DNL_karta(2),f4_inf_DDS_karta(2))
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i,1]
  frd2->data := full_date(arr[i,2])
  frd2->rezu := arr[i,3]
next
//
close databases
call_fr("mo_030dcu13")
return NIL

*

***** 05.07.13
Function f3_inf_DDS_karta(_menu,_i,_r,ub,ue,fl)
Local j, s := ""
DEFAULT _r TO ", ", fl TO .t.
for j := 1 to len(_menu)
  if _i == _menu[j,2]
    s += ub
  endif
  s += ltrim(_menu[j,1])
  if _i == _menu[j,2]
    s += ue
  endif
  if j < len(_menu)
    s += _r
  endif
next
if fl
  s += " (�㦭�� ����ભ���)."
endif
return s

*

***** 04.05.16
Function f4_inf_DDS_karta(par,_etap,et2)
Local i, k, arr := {}
if par == 1
  if iif(_etap==nil, .t., _etap==1)
    for i := 1 to count_dds_arr_osm1
      k := 0
      do case
        case i ==  1 // {"��⠫쬮���","",0,17,{65},{1112},{"2.83.21"}},;
          k := 3
        case i ==  2 // {"��ਭ���ਭ�����","",0,17,{64},{1111,111101},{"2.83.22"}},;
          k := 5
        case i ==  3 // {"���᪨� ����","",0,17,{20},{1135},{"2.83.18"}},;
          k := 4
        case i ==  4 // {"�ࠢ��⮫��-��⮯��","",0,17,{100},{1123},{"2.83.19"}},;
          k := 6
        case i ==  5 // {"�����-��������� (����窨)","�",0,17,{2},{1101},{"2.83.16"}},;
          k := 11
        case i ==  6 // {"���᪨� �஫��-���஫�� (����稪�)","�",0,17,{19},{112603,113502},{"2.83.17"}},;
          k := 10
        case i ==  7 // {"���᪨� �⮬�⮫�� (� 3 ���)","",3,17,{86},{140102},{"2.83.23"}},;
          k := 8
        case i ==  8 // {"���᪨� �����ਭ���� (� 5 ���)","",5,17,{21},{1127,112702,113402},{"2.83.24"}},;
          k := 9
        case i ==  9 // {"���஫��","",0,17,{53},{1109},{"2.83.20"}},;
          k := 2
        case i == 10 // {"��娠��","",0,17,{72},{1115},{"2.4.1"}},;
          k := 7
        case i == 11 // {"�������","",0,17,{68,57},{1134,1110},{"2.83.14","2.83.15"}};
          k := 1
      endcase
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      if between(mvozrast,dds_arr_osm1[i,3],dds_arr_osm1[i,4]) .and. ;
              iif(empty(dds_arr_osm1[i,2]), .t., dds_arr_osm1[i,2]==mpol)
        if !emptyany(&mvard,&mvart)
          aadd(arr, {dds_arr_osm1[i,1], &mvard, "", i, k})
        endif
      endif
    next
  endif
  if metap == 2 .and. iif(_etap==nil, .t., _etap==2)
    DEFAULT et2 TO 0
    if eq_any(et2,0,1)
      for i := 7 to 8 // �⮬�⮫�� � �����ਭ���� �� 2 �⠯�
        k := 0
        mvart := "MTAB_NOMov"+lstr(i)
        mvard := "MDATEo"+lstr(i)
        if !between(mvozrast,dds_arr_osm1[i,3],dds_arr_osm1[i,4])
          if !emptyany(&mvard,&mvart)
            aadd(arr, {dds_arr_osm1[i,1], &mvard, "", i, k})
          endif
        endif
      next
    endif
    if eq_any(et2,0,2)
      for i := 1 to count_dds_arr_osm2
        k := 0
        mvart := "MTAB_NOM2ov"+lstr(i)
        mvard := "MDATE2o"+lstr(i)
        if !emptyany(&mvard,&mvart)
          aadd(arr, {dds_arr_osm2[i,1], &mvard, "", i, k})
        endif
      next
    endif
  endif
else
  for i := 1 to count_dds_arr_iss
    k := 0
    do case
      case i ==  1 // {"������᪨� ������ ���","",0,17,{34},{1107,1301,1402,1702},{"4.2.153"}},;
        k := 2
      case i ==  2 // {"������᪨� ������ �஢�","",0,17,{34},{1107,1301,1402,1702},{"4.11.136"}},;
        k := 1
      case i ==  3 // {"��᫥������� �஢�� ���� � �஢�","",0,17,{34},{1107,1301,1402,1702},{"4.12.169"}},;
        k := 4
      case i ==  4 // {"�����ப�न�����","",0,17,{111},{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202},{"13.1.1"}},;
        k := 13
      case i ==  5 // {"���ண��� ������ (� 15 ���)","",15,17,{78},{1118,1802},{"7.61.3"}},;
        k := 12
      case i ==  6 // {"��� ��������� ����� (����ᮭ�����) (�� 1 ����)","",0,0,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.1"}},;
        k := 11
      case i ==  7 // {"��� �⮢����� ������ (� 7 ���)","",7,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.2"}},;
        k := 8
      case i ==  8 // {"��� ���","",0,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.3"}},;
        k := 7
      case i ==  9 // {"��� ⠧����७��� ���⠢�� (�� 1 ����)","",0,0,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.1.4"}},;
        k := 10
      case i == 10 // {"��� �࣠��� ���譮� ������ �������᭮� ��䨫����᪮�","",0,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.2.1"}},;
        k := 6
      case i == 11 // {"��� �࣠��� ९த�⨢��� ��⥬�","",7,17,{106},{110101,111004,111802,111903,112211,112610,113416,113508,180203},{"8.2.2","8.2.3"}};
        k := 9
    endcase
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    if between(mvozrast,dds_arr_iss[i,3],dds_arr_iss[i,4])
      if !emptyany(&mvard,&mvart)
        aadd(arr, {dds_arr_iss[i,1], &mvard, &mvarr, i, k})
      endif
    endif
  next
endif
return arr

***** 28.01.15
Function inf_DDS_svod(par,par2,is_schet)
Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3)
    adbf := {;
     {"nomer"    ,   "N",     6,     0},;
     {"KOD"      ,   "N",     7,     0},; // ��� (����� �����)
     {"KOD_K"    ,   "N",     7,     0},; // ��� �� ����⥪�
     {"FIO"      ,   "C",    50,     0},; // �.�.�. ���쭮��
     {"DATE_R"   ,   "D",     8,     0},; // ��� ஦����� ���쭮��
     {"N_DATA"   ,   "D",     8,     0},; // ��� ��砫� ��祭��
     {"K_DATA"   ,   "D",     8,     0},; // ��� ����砭�� ��祭��
     {"sroki"    ,   "C",    11,     0},; // �ப� ��祭��
     {"noplata"  ,   "N",     1,     0},; //
     {"oplata"   ,   "C",    30,     0},; // �����
     {"CENA_1"   ,   "N",    10,     2},; // ����稢����� �㬬� ��祭��
     {"KOD_DIAG" ,   "C",     5,     0},; // ��� 1-�� ��.�������
     {"etap"     ,   "N",     1,     0},; //
     {"gruppa_do",   "N",     1,     0},; //
     {"gruppa"   ,   "N",     1,     0},; //
     {"gd1"      ,   "C",     1,     0},; //
     {"gd2"      ,   "C",     1,     0},; //
     {"gd3"      ,   "C",     1,     0},; //
     {"gd4"      ,   "C",     1,     0},; //
     {"gd5"      ,   "C",     1,     0},; //
     {"g1"       ,   "C",     1,     0},; //
     {"g2"       ,   "C",     1,     0},; //
     {"g3"       ,   "C",     1,     0},; //
     {"g4"       ,   "C",     1,     0},; //
     {"g5"       ,   "C",     1,     0},; //
     {"vperv"    ,   "C",     1,     0},; //
     {"dispans"  ,   "C",     1,     0},; //
     {"n1"       ,   "C",     1,     0},; //
     {"n2"       ,   "C",     1,     0},; //
     {"n3"       ,   "C",     1,     0},; //
     {"p1"       ,   "C",     1,     0},; //
     {"p2"       ,   "C",     1,     0},; //
     {"p3"       ,   "C",     1,     0},; //
     {"f1"       ,   "C",     1,     0},; //
     {"f2"       ,   "C",     1,     0},; //
     {"f3"       ,   "C",     1,     0},; //
     {"f4"       ,   "C",     1,     0},; //
     {"f5"       ,   "C",     1,     0}; //
    }
    for i := 1 to count_dds_arr_iss
      aadd(adbf,{"di_"+lstr(i),"C",8,0})
    next
    for i := 1 to count_dds_arr_osm1
      aadd(adbf,{"d1_"+lstr(i),"C",8,0})
    next
    aadd(adbf,{"d1_zs","C",8,0})
    for i := 1 to count_dds_arr_osm2
      aadd(adbf,{"d2_"+lstr(i),"C",8,0})
    next
    dbcreate(cur_dir+"tmpfio",adbf)
    R_Use(dir_server+"mo_rak",,"RAK")
    R_Use(dir_server+"mo_raks",,"RAKS")
    set relation to akt into RAK
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    set relation to kod_raks into RAKS
    index on str(kod_h,7)+dtos(rak->DAKT) to (cur_dir+"tmp_raksh")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    do while .t.
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say str(rec/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_svod")
    enddo
    close databases
    delFRfiles()
    R_Use(dir_server+"organiz",,"ORG")
    adbf := {{"name","C",130,0},;
             {"nomer","N",6,0},;
             {"kol_opl","N",6,0},;
             {"CENA_1","N",15,2},;
             {"period","C",250,0},;
             {"period2","C",50,0},;
             {"kol2","C",60,0},;
             {"kol3","C",60,0},;
             {"kol4","C",60,0},;
             {"gd1"      ,   "N",     8,     0},; //
             {"gd2"      ,   "N",     8,     0},; //
             {"gd3"      ,   "N",     8,     0},; //
             {"gd4"      ,   "N",     8,     0},; //
             {"gd5"      ,   "N",     8,     0},; //
             {"g1"       ,   "N",     8,     0},; //
             {"g2"       ,   "N",     8,     0},; //
             {"g3"       ,   "N",     8,     0},; //
             {"g4"       ,   "N",     8,     0},; //
             {"g5"       ,   "N",     8,     0},; //
             {"vperv"    ,   "N",     8,     0},; //
             {"dispans"  ,   "N",     8,     0},; //
             {"n1"       ,   "N",     8,     0},; //
             {"n2"       ,   "N",     8,     0},; //
             {"n3"       ,   "N",     8,     0},; //
             {"p1"       ,   "N",     8,     0},; //
             {"p2"       ,   "N",     8,     0},; //
             {"p3"       ,   "N",     8,     0},; //
             {"f1"       ,   "N",     8,     0},; //
             {"f2"       ,   "N",     8,     0},; //
             {"f3"       ,   "N",     8,     0},; //
             {"f4"       ,   "N",     8,     0},; //
             {"f5"       ,   "N",     8,     0}}
    for i := 1 to count_dds_arr_iss
      aadd(adbf,{"di_"+lstr(i),"N",8,0})
    next
    for i := 1 to count_dds_arr_osm1
      aadd(adbf,{"d1_"+lstr(i),"N",8,0})
    next
    aadd(adbf,{"d1_zs","N",8,0})
    for i := 1 to count_dds_arr_osm2
      aadd(adbf,{"d2_"+lstr(i),"N",8,0})
    next
    dbcreate(fr_titl, adbf)
    use (fr_titl) new alias FRT
    append blank
    frt->name := glob_mo[_MO_SHORT_NAME]
    frt->period := iif(p_tip_lu==TIP_LU_DDS,;
      "�ॡ뢠��� � ��樮����� �᫮���� ��⥩-��� � ��⥩, ��室����� � ��㤭�� ��������� ���樨",;
      "��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥ ��뭮����� (㤮�����), �ਭ���� ��� ����� (�����⥫��⢮), � ����� ��� ���஭���� ᥬ��")
    frt->period2 := arr_m[4]
    if par2 == 1
      frt->kol2 := "�.�.�"
      frt->kol3 := "��� ஦�����"
      frt->kol4 := "��� ��砫� ��ᯠ��ਧ�樨"
    else
      frt->kol2 := "������������ ����樭᪮� �࣠����樨"
      frt->kol3 := "������� ������⥫�"
      frt->kol4 := "�����᪨� ������⥫� �믮������: �ᬮ�७�/��ࠡ�⠭� ����"
    endif
    copy file ("tmpfio"+sdbf) to (fr_data+sdbf)
    do case
      case par == 1
        use (fr_data) new alias FRD
        index on dtos(n_data)+upper(fio) to (fr_data)
        go top
        j := 0
        do while !eof()
          frd->nomer := ++j
          select FRT
          frt->nomer := frd->nomer
          frt->kol_opl += frd->noplata
          frt->cena_1 += frd->cena_1
          for i := 1 to count_dds_arr_iss
            poled := "frd->di_"+lstr(i)
            polet := "frt->di_"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          for i := 1 to count_dds_arr_osm1
            poled := "frd->d1_"+lstr(i)
            polet := "frt->d1_"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          if !empty(frd->d1_zs)
            frt->d1_zs ++
          endif
          for i := 1 to count_dds_arr_osm2
            poled := "frd->d2_"+lstr(i)
            polet := "frt->d2_"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          select FRD
          skip
        enddo
        close databases
        call_fr("mo_ddsTF")
      case par == 2
        use (fr_data) new alias FRD
        index on dtos(n_data)+upper(fio) to (fr_data)
        go top
        j := 0
        do while !eof()
          frd->nomer := ++j
          select FRT
          frt->nomer := frd->nomer
          for i := 1 to 5
            poled := "frd->gd"+lstr(i)
            polet := "frt->gd"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          for i := 1 to 5
            poled := "frd->g"+lstr(i)
            polet := "frt->g"+lstr(i)
            if !empty(&poled)
              &polet := &polet + 1
            endif
          next
          if !empty(frd->vperv)
            frt->vperv ++
          endif
          if !empty(frd->dispans)
            frt->dispans ++
          endif
          if !empty(frd->n1)
            frt->n1 ++
          endif
          if !empty(frd->n2)
            frt->n2 ++
          endif
          if !empty(frd->n3)
            frt->n3 ++
          endif
          if !empty(frd->f1)
            frt->f1 ++
          endif
          if !empty(frd->f3)
            frt->f3 ++
          endif
          if !empty(frd->f4)
            frt->f4 ++
          endif
          if !empty(frd->f5)
            frt->f5 ++
          endif
          select FRD
          skip
        enddo
        if par2 == 2
          select FRD
          zap
        endif
        close databases
        call_fr("mo_ddsMZ",iif(par2==2,3,))
    endcase
  endif
endif
close databases
rest_box(buf)
return NIL

***** 04.05.16
Function f2_inf_DDS_svod(Loc_kod,kod_kartotek) // ᢮���� ���ଠ��
Local i := 0, c, s := "��� ���", pole, arr, ddo := {}, dposle := {}
R_Use(dir_server+"mo_rak",,"RAK")
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to akt into RAK
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to kod_raks into RAKS
set index to (cur_dir+"tmp_raksh")
select RAKSH
find (str(Loc_kod,7))
do while Loc_kod == raksh->kod_h .and. !eof()
  if round(raksh->sump,2) == round(mCENA_1,2)
    i := 1
    s := "����祭"
  else
    i := 0
    s := "�� ���.: ��� "+alltrim(rak->NAKT)+" �� "+date_8(rak->DAKT)
  endif
  skip
enddo
use (cur_dir+"tmpfio") new alias TF
append blank
tf->KOD := Loc_kod
tf->KOD_K := kod_kartotek
tf->FIO := mfio
tf->DATE_R := mdate_r
tf->N_DATA := mN_DATA
tf->K_DATA := mK_DATA
tf->sroki := left(date_8(mN_DATA),5)+"-"+left(date_8(mK_DATA),5)
tf->noplata := i
tf->oplata := s
tf->CENA_1 := mCENA_1
tf->KOD_DIAG := mkod_diag
tf->etap := metap
tf->gruppa_do := mgruppa_do
if between(mgruppa_do,1,5)
  pole := "tf->gd"+lstr(mgruppa_do)
  &pole := "X"
endif
tf->gruppa := mgruppa
if between(mgruppa,1,5)
  pole := "tf->g"+lstr(mgruppa)
  &pole := "X"
endif
for i := 1 to 5
  pole := "mdiag_16_"+lstr(i)+"_1"
  if !empty(&pole)
    aadd(ddo,alltrim(&pole))
  endif
next
for i := 1 to 5
  pole := "mdiag_16_"+lstr(i)+"_1"
  if !empty(&pole)
    aadd(dposle,alltrim(&pole))
    pole := "m1diag_16_"+lstr(i)+"_2"
    if &pole == 1
      tf->vperv := "X"
    endif
    pole := "m1diag_16_"+lstr(i)+"_3"
    if &pole == 2
      tf->dispans := "X"
    endif
    pole := "m1diag_16_"+lstr(i)+"_13"
    if &pole == 1
      tf->n2 := "X"
      pole := "m1diag_16_"+lstr(i)+"_15"
      if &pole == 4
        tf->n1 := "X"
      endif
    endif
    pole := "m1diag_16_"+lstr(i)+"_16"
    if &pole == 1
      tf->n3 := "X"
    endif
  endif
next
for i := 1 to len(ddo)
  c := left(ddo[i],3)
  if between(c,"F00","F69") .or. between(c,"F80","F99")
    tf->f3 := "X"
  endif
next
for i := 1 to len(dposle)
  if ascan(ddo,dposle[i]) == 0
    tf->f1 := "X"
  endif
  c := left(dposle[i],3)
  if between(c,"F00","F69") .or. between(c,"F80","F99")
    tf->f4 := "X"
  endif
next
if !empty(tf->f3) .and. empty(tf->f4)
  tf->f5 := "X"
endif
arr := f4_inf_DDS_karta(1,1)
for i := 1 to len(arr)
  pole := "tf->d1_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
tf->d1_zs := mshifr_zs
arr := f4_inf_DDS_karta(1,2,1) // �⮬�⮫�� � �����ਭ���� �� 2 �⠯�
for i := 1 to len(arr)
  pole := "tf->d1_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
arr := f4_inf_DDS_karta(1,2,2) // ��⠫�� ���� �� 2 �⠯�
for i := 1 to len(arr)
  pole := "tf->d2_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
arr := f4_inf_DDS_karta(2)
for i := 1 to len(arr)
  pole := "tf->di_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
return NIL

***** 20.06.21 �ਫ������ � ����� ���� �14-05/50 �� 07.02.2020�.
Function inf_DDS_svod2(par2,is_schet)
Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 91, HH := 60, n_file := "ddssvod2"+stxt
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3)
    Private arr_deti := {;
      {"1","�ᥣ�"      ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},;
      {"1.1","0-14 ���" ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},;
      {"1.2","15-17 ���",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    }
    Private arr_2510 := {;
      {'001 ��� 0-14 ��� ���.',0,0,0,0,0,0,0},;
      {'002 �� ��� ��� �� 1 �.',0,0,0,0,0,0,0},;
      {'003 ��� 15-17 ��� ���.',0,0,0,0,0,0,0},;
      {'004 15-17 ��� - �',0,0,0,0,0,0,0},;
      {'005 誮�쭨��',0,0,0,0,0,0,0};
    }
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }

    do while .t.
 //     R_Use_base("human_u")
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say str(rec/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_svod2")
    enddo
    close databases
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
   if par2 == 3
    add_string(padl("�ਫ������",sh))
    add_string(padl("� ����� ����",sh))
    add_string(padl("�14-05/50 �� 07.02.2020�.",sh))
   endif
    add_string("")
    add_string(center("�������� � ��ᯠ��ਧ�樨 ��ᮢ��襭����⭨�,",sh))
    if p_tip_lu == TIP_LU_DDS
      add_string(center("�ॡ뢠��� � ��樮����� �᫮���� ��⥩-��� � ��⥩,",sh))
      add_string(center("��室����� � ��㤭�� ��������� ���樨",sh))
    else
      add_string(center("��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥",sh))
      add_string(center("��뭮����� (㤮�����), �ਭ���� ��� ����� (�����⥫��⢮),",sh))
      add_string(center("� ����� ��� ���஭���� ᥬ��",sh))
    endif
    add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    add_string(center(arr_m[4],sh))
    add_string("")
   if par2 == 3
    //add_string("�������������������������������������������������������������������������������������������")
    //add_string("�� � ���⨭- � �ᬮ�७� ��� ��� ᥫ�������           �� ���            ����⮳�� 7���� 14")
    //add_string("�� � �����   �����������������������Ĵ����������������������������������Ĵ�� �������ᥫ� ")
    //add_string("   �         ��ᥣ��� �㡳�ᥣ��� �㡳���ࢳ�஢�� ��� �1�2�ⳤ�堭���饢�ᯠ�ᳫ�祭�     ")
    //add_string("�������������������������������������������������������������������������������������������")
    //add_string(" 1 �    2    �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 �  14 �  15 ")
    //add_string("�������������������������������������������������������������������������������������������")
    add_string("��������������������������������������������������������������������������������������������")
    add_string("�� �          �     �ᬮ�७�   ������           �� ���                  ����⮳���⮳�� 6�")
    add_string("�� �������⥫������������������Ĵ����������������������������������������Ĵ��   ��� �������")
    add_string("   �          ��ᥣ�����ள���������ࢳ�஢�� ��� ���_�� �������������饢��᪠�ᯠ�ᳫ�祭")
    add_string("��������������������������������������������������������������������������������������������")
    add_string(" 1 �    2     �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 �  14 �  15 ")
    add_string("��������������������������������������������������������������������������������������������")
    for i := 1 to 3
      s := padr(arr_deti[i,1],4)+padr(arr_deti[i,2],9)
      s += put_val(arr_deti[i,3],6)
      s += put_val(arr_deti[i,16],6) // ���஫��
      s += put_val(arr_deti[i,17],6) // ���������
      s += put_val(arr_deti[i,7],6)
      s += put_val(arr_deti[i,8],6)
      s += put_val(arr_deti[i,9],6)
      s += put_val(arr_deti[i,21],6) // ����- �離�
      s += put_val(arr_deti[i,18],6) // �����
      s += put_val(arr_deti[i,19],6) // �����ਭ��
      //s += put_val(arr_deti[i,11],6)
      s += put_val(arr_deti[i,12],6)
      s += put_val(arr_deti[i,20],6) // 䠪��� �᪠
      s += put_val(arr_deti[i,13],6)
      s += put_val(arr_deti[i,14],6)
      //for j := 3 to 15
      //  s += put_val(arr_deti[i,j],6)
      //next
      add_string(s)
      add_string(replicate("�",sh))
    next
   else
    add_string("�������������������������������������������������������������������")
    add_string("                         ���᫮ ��⥩�     �� ��㯯�� ���஢��     ")
    add_string("     ��� - ����       ������������������������������������������")
    add_string("     ⠡��� 2510        ��ᥣ�� ᥫ��  1  �  2  �  3  �  4  �  5  ")
    add_string("�������������������������������������������������������������������")
    add_string("                         �  5  �  6  �  7  �  8  �  9  �  12 �  13 ")
    add_string("�������������������������������������������������������������������")
    for i := 1 to len(arr_2510)
      s := padr(arr_2510[i,1],25)
      for j := 2 to len(arr_2510[i])
        s += put_val(arr_2510[i,j],6)
      next
      add_string(s)
    next
   endif
    fclose(fp)
    viewtext(n_file,,,,.t.,,,2)
  endif
endif
close databases
rest_box(buf)
return NIL


***** 20.06.21
Function f2_inf_DDS_svod2(Loc_kod,kod_kartotek)
Local i, j, k, is_selo, ad := {}, ar := {1}, ar1 := {},;
      ar2 := array(len(arr_deti[1]))
if mvozrast < 15
  aadd(ar,2)
else
  aadd(ar,3)
endif
//
for i := 1 to 5
  j := 0
  for k := 1 to 3
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := {alltrim(&mvar),0,0}
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next


R_Use(dir_server+"kartote2",,"KART2")
goto (kod_kartotek)
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)

R_Use(dir_server+"uslugi",,"USL")
R_Use_base("human_u")
//R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
//set relation to recno() into HUMAN_, to kod_k into KART_
//use (cur_dir+"tmp") new
//set relation to kod into HUMAN
//go top



R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)
if mvozrast == 0
  aadd(ar1,2)
endif
if mvozrast < 15
  aadd(ar1,1)
else
  aadd(ar1,3)
  if kart->pol == "�"
    aadd(ar1,4)
  endif
endif
if mvozrast > 6 // 誮�쭨�� ?
  aadd(ar1,5)
endif
//
afill(ar2,0)
for i := 1 to len(ad) // 横� �� ���������
  if !(left(ad[i,1],1) == "A" .or. left(ad[i,1],1) == "B") .and. ad[i,2] == 1 // ����䥪樮��� ����������� ���.�����
    //arr_deti[k,7] ++
    ar2[7] := 1
    if left(ad[i,1],1) == "I" // ������� ��⥬� �஢����饭��
      ar2[8] := 1     //arr_deti[k,8] ++
    endif
    if left(ad[i,1],1) == "J" // ������� �࣠��� ��堭��
      ar2[11] := 1      // arr_deti[k,11] ++
    endif
    if left(ad[i,1],1) == "K" // ������� �࣠��� ��饢�७��
      ar2[12] := 1     //   arr_deti[k,12] ++
    endif
    if left(ad[i,1],1) == "H" // ������� ����
      ar2[18] := 1    // arr_deti[k,18] ++
    endif
    if left(ad[i,1],1) == "E" // ������� �����ਭ������
      ar2[19] := 1  //   arr_deti[k,19] ++
    endif
    if left(ad[i,1],1) == "M" // ������� ���⭮-���筮� ��⥬�
      ar2[21] := 1  //  arr_deti[k,21] ++
    endif
    //
    if left(ad[i,1],3) == "E78"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "R73.9"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "Z72.0"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "Z72.4"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "R63.5"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "Z72.3"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "Z72.1"
      ar2[20] := 1
    elseif left(ad[i,1],5) == "Z72.2"
      ar2[20] := 1
    endif
    //
    //my_debug(,left(ad[i,1],5))
    //my_debug(,str(ar2[19])+"    "+str(ar2[20]))
    //
    if left(ad[i,1],1) == "C" .or. between(left(ad[i,1],3),"D00","D09") // ���
      ar2[9] := 1  //  arr_deti[k,9] ++
    endif
    if ad[i,3] > 0
      ar2[13] := 1  //  arr_deti[k,13] ++  // ����� �� ��ᯠ�୮� �������
    endif
    if m1napr_stac > 0 // ���ࠢ��� �� ��祭��
      ar2[14] := 1 //       arr_deti[k,14] ++ // ��⠥�, �� �뫮 ���� ��祭��
      if is_selo
        ar2[15] := 1   //  arr_deti[k,15] ++
      endif
    endif
  endif
next i
// ���� ������ ����� ⥫�
//    my_debug(,kart->fio)
//    my_debug(,str(m1fiz_razv1)+"   "+mfiz_razv1)
if m1fiz_razv1 == 1
   ar2[20] := 1
endif
//    my_debug(,str(ar2[20]))

for j := 1 to 2
  k := ar[j]
  arr_deti[k,3] ++
  if dow(mk_data) == 7 // �㡡��
    arr_deti[k,4] ++
  endif
  if is_selo
    arr_deti[k,5] ++
    if dow(mk_data) == 7 // �㡡��
      arr_deti[k,6] ++
    endif
  endif
  //
  for i := 7 to len(ar2)
    arr_deti[k,i] += ar2[i]
  next
next
//
fl := .f.
//

//
select HU
find (str(Loc_kod,7))
do while hu->kod == Loc_kod .and. !eof()
  if eq_any(hu_->PROFIL,19,136)
    fl := .t.
  endif
  usl->(dbGoto(hu->u_kod))
  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
    lshifr := usl->shifr
  endif
  if left(lshifr,2) == "2."  // ��祡�� ���
    if hu_->PROFIL == 19
      //ar2[16] := 1
       arr_deti[k,16] ++
    endif
    if hu_->PROFIL == 136
      //ar2[17] := 1
        arr_deti[k,17] ++
    endif
  endif
  select HU
  skip
enddo
//
for j := 1 to len(ar1)
  k := ar1[j]
  arr_2510[k,2] ++
  if is_selo
    arr_2510[k,3] ++
  endif
  if between(mgruppa,1,5)
    arr_2510[k,3+mgruppa] ++
  endif
next
return NIL

***** 08.11.13
Function inf_DDS_030dso(is_schet)
Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := "f_030dso"+stxt, d1, d2
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3)
    Private arr_deti[5] ; afill(arr_deti,0)
    Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
    Private arr_vozrast := {;
      {4, 0, 4},;
      {5, 5, 9},;
      {6,10,14},;
      {7,15,17},;
      {8, 0,14},;
      {9, 0,17};
     }
    Private arr1vozrast := {;
      { 0,17},;
      { 0,14},;
      { 0, 4},;
      { 5, 9},;
      {10,14},;
      {15,17};
     }
    Private arr_4 := {;
      {"1","������� ��䥪樮��� � ��ࠧ��...","A00-B99",,},;
      {"1.1","�㡥�㫥�","A15-A19",,},;
      {"1.2","���-��䥪��, ����","B20-B24",,},;
      {"2","������ࠧ������","C00-D48",,},;
      {"3","������� �஢� � �஢�⢮��� �࣠��� ...","D50-D89",,},;
      {"3.1","������","D50-D53",,},;
      {"4","������� �����ਭ��� ��⥬�, ����ன�⢠...","E00-E90",,},;
      {"4.1","���� ������","E10-E14",,},;
      {"4.2","�������筮��� ��⠭��","E40-E46",,},;
      {"4.3","���७��","E66",,},;
      {"4.4","����প� �������� ࠧ����","E30.0",,},;
      {"4.5","�०���६����� ������� ࠧ��⨥","E30.1",,},;
      {"5","����᪨� ����ன�⢠ � �����...","F00-F99",,},;
      {"5.1","��⢥���� ���⠫����","F70-F79",,},;
      {"6","������� ��ࢭ�� ��⥬�, �� ���:","G00-G98",,},;
      {"6.1","�ॡࠫ�� ��ࠫ�� � ��㣨� ...","G80-G83",,},;
      {"7","������� ����� � ��� �ਤ��筮�� ������","H00-H59",,},;
      {"8","������� �� � ��楢������ ����⪠","H60-H95",,},;
      {"9","������� ��⥬� �஢����饭��","I00-I99",,},;
      {"10","������� �࣠��� ��堭��, �� ���:","J00-J99",,},;
      {"10.1","��⬠, ��⬠��᪨� �����","J45-J46",,},;
      {"11","������� �࣠��� ��饢�७��","K00-K93",,},;
      {"12","������� ���� � ��������� �����⪨","L00-L99",,},;
      {"13","������� ���⭮-���筮� ...","M00-M99",,},;
      {"13.1","��䮧, ��म�, ᪮����","M40-M41",,},;
      {"14","������� ��祯������ ��⥬�, �� ���:","N00-N99",,},;
      {"14.1","������� ��᪨� ������� �࣠���","N40-N51",,},;
      {"14.2","����襭�� �⬠ � �ࠪ�� �������権","N91-N94.5",,},;
      {"14.3","��ᯠ��⥫�� ����������� ...","N70-N77",,},;
      {"14.4","����ᯠ��⥫�� ������� ...","N83-N83.9",,},;
      {"14.5","������� ����筮� ������","N60-N64",,},;
      {"15","�⤥��� ���ﭨ�, �������...","P00-P96",,},;
      {"16","�஦����� �������� (��ப� ...","Q00-Q99",,},;
      {"16.1","ࠧ���� ��ࢭ�� ��⥬�","Q00-Q07",,},;
      {"16.2","��⥬� �஢����饭��","Q20-Q28",,},;
      {"16.3","���⭮-���筮� ��⥬�","Q65-Q79",,},;
      {"16.4","���᪨� ������� �࣠���","Q50-Q52",,},;
      {"16.5","��᪨� ������� �࣠���","Q53-Q55",,},;
      {"17","�ࠢ��, ��ࠢ����� � �������...","S00-T98",,},;
      {"18","��稥","",,},;
      {"19","����� �����������","A00-T98",,};
     }
    for n := 1 to len(arr_4)
      if "-" $ arr_4[n,3]
        d1 := token(arr_4[n,3],"-",1)
        d2 := token(arr_4[n,3],"-",2)
      else
        d1 := d2 := arr_4[n,3]
      endif
      arr_4[n,4] := diag_to_num(d1,1)
      arr_4[n,5] := diag_to_num(d2,2)
    next
    dbcreate(cur_dir+"tmp4",{{"name","C",100,0},;
                     {"diagnoz","C",20,0},;
                     {"stroke","C",4,0},;
                     {"ns","N",2,0},;
                     {"diapazon1","N",10,0},;
                     {"diapazon2","N",10,0},;
                     {"tbl","N",1,0},;
                     {"k04","N",8,0},;
                     {"k05","N",8,0},;
                     {"k06","N",8,0},;
                     {"k07","N",8,0},;
                     {"k08","N",8,0},;
                     {"k09","N",8,0},;
                     {"k10","N",8,0},;
                     {"k11","N",8,0}})
    use (cur_dir+"tmp4") new alias TMP
    for i := 1 to len(arr_vozrast)
      for n := 1 to len(arr_4)
        append blank
        tmp->tbl := arr_vozrast[i,1]
        tmp->stroke := arr_4[n,1]
        tmp->name := arr_4[n,2]
        tmp->ns := n
        tmp->diagnoz := arr_4[n,3]
        tmp->diapazon1 := arr_4[n,4]
        tmp->diapazon2 := arr_4[n,5]
      next
    next
    index on str(tbl,1)+str(ns,2) to (cur_dir+"tmp4")
    use
    dbcreate(cur_dir+"tmp10",{{"voz","N",1,0},;
                      {"tbl","N",2,0},;
                      {"tip","N",1,0},;
                      {"kol","N",6,0}})
    use (cur_dir+"tmp10") new alias TMP10
    index on str(voz,1)+str(tbl,1)+str(tip,1) to (cur_dir+"tmp10")
    use
    copy file tmp10.dbf to tmp11.dbf
    use (cur_dir+"tmp11") new alias TMP11
    index on str(voz,1)+str(tbl,2)+str(tip,1) to (cur_dir+"tmp11")
    use
    dbcreate(cur_dir+"tmp13",{{"voz","N",1,0},;
                      {"tip","N",2,0},;
                      {"kol","N",6,0}})
    use (cur_dir+"tmp13") new alias TMP13
    index on str(voz,1)+str(tip,2) to (cur_dir+"tmp13")
    use
    dbcreate(cur_dir+"tmp16",{{"voz","N",1,0},;
                      {"man","N",1,0},;
                      {"tip","N",2,0},;
                      {"kol","N",6,0}})
    use (cur_dir+"tmp16") new alias TMP16
    index on str(voz,1)+str(man,1)+str(tip,2) to (cur_dir+"tmp16")
    use
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    do while .t.
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say str(rec/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_DDS_030dso")
    enddo
    close databases
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl("�ਫ������ 3",sh))
    add_string(padl("� �ਪ��� ����",sh))
    add_string(padl("�72� �� 15.02.2013�.",sh))
    add_string("")
    add_string(padl("���⭠� �ଠ � 030-�/�/�-13",sh))
    add_string("")
    add_string(center("�������� � ��ᯠ��ਧ�樨 ��ᮢ��襭����⭨�,",sh))
    if p_tip_lu == TIP_LU_DDS
      add_string(center("�ॡ뢠��� � ��樮����� �᫮���� ��⥩-��� � ��⥩,",sh))
      add_string(center("��室����� � ��㤭�� ��������� ���樨",sh))
    else
      add_string(center("��⥩-��� � ��⥩, ��⠢���� ��� ����祭�� த�⥫��, � ⮬ �᫥",sh))
      add_string(center("��뭮����� (㤮�����), �ਭ���� ��� ����� (�����⥫��⢮),",sh))
      add_string(center("� ����� ��� ���஭���� ᥬ��",sh))
    endif
    add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    add_string(center(arr_m[4],sh))
    add_string("")
    add_string("2. ��᫮ ��⥩, ��襤�� ��ᯠ��ਧ��� � ���⭮� ��ਮ��:")
    add_string("  2.1. �ᥣ� � ������ �� 0 �� 17 ��� �����⥫쭮:"+str(arr_deti[1],6)+" (祫����), �� ���:")
    add_string("  2.1.1. � ������ �� 0 �� 4 ��� �����⥫쭮      "+str(arr_deti[2],6)+" (祫����),")
    add_string("  2.1.2. � ������ �� 5 �� 9 ��� �����⥫쭮      "+str(arr_deti[3],6)+" (祫����),")
    add_string("  2.1.3. � ������ �� 10 �� 14 ��� �����⥫쭮    "+str(arr_deti[4],6)+" (祫����),")
    add_string("  2.1.4. � ������ �� 15 �� 17 ��� �����⥫쭮    "+str(arr_deti[5],6)+" (祫����).")
    for i := 1 to len(arr_vozrast)
      verify_FF(HH-50, .t., sh)
      add_string("")
      add_string(center(lstr(arr_vozrast[i,1])+;
                 ". ������� ������� ������������ (���ﭨ�) � ��⥩ � ������ �� "+;
                 lstr(arr_vozrast[i,2])+" �� "+lstr(arr_vozrast[i,3])+" ��� �����⥫쭮",sh))
      add_string("��������������������������������������������������������������������������������")
      add_string(" �� �    ������������   � ��� ����ᥣ��� �.糢��-�� �.糑��⮨� ��� ���.�����")
      add_string(" �� �    �����������    � ���-10���ॣ�����-����� �����-������������������������")
      add_string("    �                   �       �������稪� ����ࢳ稪� ��ᥣ������糢��⮳�����")
      add_string("��������������������������������������������������������������������������������")
      add_string(" 1  �          2        �   3   �  4  �  5  �  6  �  7  �  8  �  9  � 10  � 11  ")
      add_string("��������������������������������������������������������������������������������")
      use (cur_dir+"tmp4") index (cur_dir+"tmp4") new alias TMP
      find (str(arr_vozrast[i,1],1))
      do while tmp->tbl == arr_vozrast[i,1] .and. !eof()
        s := tmp->stroke+" "+padr(tmp->name,19)+" "+padc(alltrim(tmp->diagnoz),7)
        for n := 4 to 11
          s += put_val(tmp->&("k"+strzero(n,2)),6)
        next
        add_string(s)
        skip
      enddo
      use
      add_string(replicate("�",sh))
    next
    arr1title := {;
      "��������������������������������������������������������������������������������",;
      "                    �   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� ",;
      "  ������ ��⥩     �           �           ���ꥪ� ���  ��� ���  �    ��     ",;
      "                    �           �           �           �           �           ",;
      "��������������������������������������������������������������������������������",;
      "          1         �     2     �     3     �     4     �     5     �     6     ",;
      "��������������������������������������������������������������������������������"}
    arr2title := {;
      "��������������������������������������������������������������������������������",;
      "                    �   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� ",;
      "  ������ ��⥩     �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č������",;
      "                    � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ",;
      "��������������������������������������������������������������������������������",;
      "          1         �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 ",;
      "��������������������������������������������������������������������������������"}
    arr3title := {;
      "��������������������������������������������������������������������������������",;
      " ������   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ��୮",;
      " ��⥩  �           �           ���ꥪ� ���  ��� ���  �    ��     �-������� ",;
      "        �           �           �           �           �           ��࣠���-�� ",;
      "��������������������������������������������������������������������������������",;
      "    1   �     2     �     3     �     4     �     5     �     6     �     7     ",;
      "��������������������������������������������������������������������������������"}
    arr4title := {;
      "��������������������������������������������������������������������������������",;
      " ������   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ.-���.",;
      " ��⥩  �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č��������Į�-�����",;
      "        � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ",;
      "��������������������������������������������������������������������������������",;
      "    1   �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 ",;
      "��������������������������������������������������������������������������������"}
    verify_FF(HH-50, .t., sh)
    add_string("10. �������� �������⥫��� �������権, ��᫥�������, ��祭�� � ����樭᪮�")
    add_string("    ॠ�����樨 ��⥩ �� १���⠬ �஢������ �����饩 ��ᯠ��ਧ�樨:")
    use (cur_dir+"tmp10") index (cur_dir+"tmp10") new alias TMP10
    for i := 1 to 8
      verify_FF(HH-16, .t., sh)
      add_string("")
      s := space(5)
      if i == 1
        add_string(s+"10.1. �㦤����� � �������⥫��� ���������� � ��᫥��������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      elseif i == 2
        add_string(s+"10.2. ��諨 �������⥫�� �������樨 � ��᫥�������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      elseif i == 3
        add_string(s+"10.3. �㦤����� � �������⥫��� ���������� � ��᫥��������")
        add_string(s+"      � ��樮����� �᫮����")
      elseif i == 4
        add_string(s+"10.4. ��諨 �������⥫�� �������樨 � ��᫥�������")
        add_string(s+"      � ��樮����� �᫮����")
      elseif i == 5
        add_string(s+"10.5. ������������� ��祭�� � ���㫠���� �᫮���� � � �᫮����")
        add_string(s+"      �������� ��樮���")
      elseif i == 6
        add_string(s+"10.6. ������������� ��祭�� � ��樮����� �᫮����")
      elseif i == 7
        add_string(s+"10.7. ������������� ����樭᪠� ॠ�������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      else
        add_string(s+"10.8. ������������� ����樭᪠� ॠ������� � (���)")
        add_string(s+"      ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����")
      endif
      n := 20
      if eq_any(i,1,3,5,6,7)
        aeval(arr1title, {|x| add_string(x) } )
      elseif eq_any(i,2,4)
        aeval(arr2title, {|x| add_string(x) } )
      else
        aeval(arr3title, {|x| add_string(x) } )
        n := 8
      endif
      for j := 1 to len(arr1vozrast)
        s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
        skol := oldkol := 0
        s1 := ""
        for k := 1 to iif(i==8,5,4)
          find (str(j,1)+str(i,1)+str(k,1))
          if found() .and. (v := tmp10->kol) > 0
            skol += v
            if eq_any(i,2,4)
              s1 += str(v,6)
              find (str(j,1)+str(i-1,1)+str(k,1))
              if found() .and. tmp10->kol > 0
                s1 += " "+umest_val(v/tmp10->kol*100,5,2)
                oldkol += tmp10->kol
              else
                s1 += space(6)
              endif
            else
              s1 += " "+padc(lstr(v),11)
            endif
          else
            s1 += space(12)
          endif
        next
        if skol > 0
          if eq_any(i,2,4)
            s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
          else
            s += " "+padc(lstr(skol),11)
          endif
          add_string(s+s1)
        else
          add_string(s)
        endif
      next
      add_string(replicate("�",sh))
    next
    use
    //
    verify_FF(HH-50, .t., sh)
    add_string("11. �������� ��祭��, ����樭᪮� ॠ�����樨 � (���) ᠭ��୮-����⭮��")
    add_string("    ��祭�� ��⥩ �� �஢������ �����饩 ��ᯠ��ਧ�樨:")
    vkol := 0
    use (cur_dir+"tmp11") index (cur_dir+"tmp11") new alias TMP11
    for i := 1 to 12
      if i % 3 > 0
        verify_FF(HH-16, .t., sh)
        add_string("")
      endif
      s := space(5)
      if i == 1
        add_string(s+"11.1. ������������� ��祭�� � ���㫠���� �᫮���� � � �᫮����")
        add_string(s+"      �������� ��樮���")
      elseif i == 2
        add_string(s+"11.2. �஢����� ��祭�� � ���㫠���� �᫮���� � � �᫮����")
        add_string(s+"      �������� ��樮���")
      elseif i == 3
        add_string(s+"11.3. ��稭� ���믮������ ४������権 �� ��祭�� � ���㫠���� �᫮����")
        add_string(s+"      � � �᫮���� �������� ��樮���:")
        add_string(s+"        11.3.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      elseif i == 4
        add_string(s+"11.4. ������������� ��祭�� � ��樮����� �᫮����")
      elseif i == 5
        add_string(s+"11.5. �஢����� ��祭�� � ��樮����� �᫮����")
      elseif i == 6
        add_string(s+"11.6. ��稭� ���믮������ ४������権 �� ��祭�� � ��樮����� �᫮����:")
        add_string(s+"        11.6.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      elseif i == 7
        add_string(s+"11.7. ������������� ����樭᪠� ॠ�������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      elseif i == 8
        add_string(s+"11.8. �஢����� ����樭᪠� ॠ�������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      elseif i == 9
        add_string(s+"11.9. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���:")
        add_string(s+"        11.9.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      elseif i == 10
        add_string(s+"11.10. ������������� ����樭᪠� ॠ������� � (���)")
        add_string(s+"       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����")
      elseif i == 11
        add_string(s+"11.11. �஢����� ����樭᪠� ॠ������� � (���)")
        add_string(s+"       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����")
      else
        add_string(s+"11.12. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨")
        add_string(s+"       � (���) ᠭ��୮-����⭮�� ��祭�� � ��樮����� �᫮����:")
        add_string(s+"         11.12.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      endif
      if i % 3 > 0
        n := 20
        if eq_any(i,1,4,7)
          aeval(arr1title, {|x| add_string(x) } )
        elseif eq_any(i,2,5,8)
          aeval(arr2title, {|x| add_string(x) } )
        elseif i == 10
          aeval(arr3title, {|x| add_string(x) } )
          n := 8
        elseif i == 11
          aeval(arr4title, {|x| add_string(x) } )
          n := 8
        endif
        for j := 1 to len(arr1vozrast)
          s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
          skol := oldkol := 0
          s1 := ""
          for k := 1 to iif(i>10,5,4)
            find (str(j,1)+str(i,2)+str(k,1))
            if found() .and. (v := tmp11->kol) > 0
              skol += v
              if eq_any(i,2,5,8,11)
                s1 += str(v,6)
                find (str(j,1)+str(i-1,2)+str(k,1))
                if found() .and. tmp11->kol > 0
                  s1 += " "+umest_val(v/tmp11->kol*100,5,2)
                  oldkol += tmp11->kol
                else
                  s1 += space(6)
                endif
              else
                s1 += " "+padc(lstr(v),11)
              endif
            else
              s1 += space(12)
            endif
          next
          if eq_any(i,2,5,8,11)
            vkol := oldkol - skol
          endif
          if skol > 0
            if eq_any(i,2,5,8,11)
              s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
            else
              s += " "+padc(lstr(skol),11)
            endif
            add_string(s+s1)
          else
            add_string(s)
          endif
        next
        add_string(replicate("�",sh))
      endif
    next
    use
    verify_FF(HH-3, .t., sh)
    add_string("")
    add_string("12. �������� ��᮪��孮����筮� ����樭᪮� �����:")
    add_string("  12.1. ४���������� (�� �⮣�� �����饩 ��ᯠ�c-樨): "+lstr(s12_1)+" 祫., � �.�. "+lstr(s12_1m)+" ����稪��")
    add_string("  12.2. ������� (�� �⮣�� ��ᯠ��ਧ�樨 � �।.����): "+lstr(s12_2)+" 祫., � �.�. "+lstr(s12_2m)+" ����稪��")
    use (cur_dir+"tmp13") index (cur_dir+"tmp13") new alias TMP13
    verify_FF(HH-16, .t., sh)
    n := 32
    add_string("")
    add_string("13. ��᫮ ��⥩-��������� �� �᫠ ��⥩, ��襤�� ��ᯠ��ਧ���")
    add_string("    � ���⭮� ��ਮ��")
    add_string("��������������������������������������������������������������������������������")
    add_string("                                � � ஦����ﳯਮ���񭭳���.����륳 祫.�  %  ")
    add_string("         ������ ��⥩          �����������������������������������Ĵ��⥩���⥩")
    add_string("                                � 祫.�  %  � 祫.�  %  � 祫.�  %  ������������")
    add_string("��������������������������������������������������������������������������������")
    add_string("               1                �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
      find (str(j,1)+str(0,2))
      oldkol := iif(found(), tmp13->kol, 0)
      for i := 1 to 4
        find (str(j,1)+str(i,2))
        if found()
          s += str(tmp13->kol,6)+" "+umest_val(tmp13->kol/oldkol*100,5,2)
        else
          s += space(12)
        endif
      next
      add_string(s)
    next
    add_string(replicate("�",sh))
    verify_FF(HH-16, .t., sh)
    n := 26
    add_string("")
    add_string("14. �믮������ �������㠫��� �ணࠬ� ॠ�����樨 (���) ��⥩-���������")
    add_string("    � ���⭮� ��ਮ��")
    add_string("��������������������������������������������������������������������������������")
    add_string("                          ���������.������Ⳣ�.���筳 ��� ���⠳�� �믮����")
    add_string("       ������ ��⥩      �祭� ������������������������������������������������")
    add_string("                          � 祫.� 祫.�  %  � 祫.�  %  � 祫.�  %  � 祫.�  %  ")
    add_string("��������������������������������������������������������������������������������")
    add_string("             1            �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
      find (str(j,1)+str(10,2))
      oldkol := 0
      if found()
        oldkol := tmp13->kol
      endif
      s += put_val(oldkol,6)
      for i := 11 to 14
        find (str(j,1)+str(i,2))
        if found()
          s += str(tmp13->kol,6)+" "+umest_val(tmp13->kol/oldkol*100,5,2)
        else
          s += space(12)
        endif
      next
      add_string(s)
    next
    add_string(replicate("�",sh))
    verify_FF(HH-15, .t., sh)
    n := 20
    add_string("")
    add_string("15. �墠� ��䨫����᪨�� �ਢ������ � ���⭮� ��ਮ��")
    add_string("��������������������������������������������������������������������������������")
    add_string("                    �  �ਢ��  ��� �ਢ��� �� ���.�������� �ਢ��� �� ���.���")
    add_string("    ������ ��⥩   �    祫.   ������������������������������������������������")
    add_string("                    �           � ��������� � ���筮  � ��������� � ���筮  ")
    add_string("��������������������������������������������������������������������������������")
    add_string("          1         �     2     �     3     �     4     �     5     �     6     ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
      find (str(j,1)+str(20,2))
      if found()
        s += " "+padc(lstr(tmp13->kol),11)
      else
        s += space(12)
      endif
      for i := 21 to 24
        find (str(j,1)+str(i,2))
        if found()
          s += " "+padc(lstr(tmp13->kol),11)
        else
          s += space(12)
        endif
      next
      add_string(s)
    next
    add_string(replicate("�",sh))
    use (cur_dir+"tmp16") index (cur_dir+"tmp16") new alias TMP16
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("16. ���।������ ��⥩ �� �஢�� 䨧��᪮�� ࠧ����")
    add_string("��������������������������������������������������������������������������������")
    add_string("                    ���᫮ �ள���.䨧.� �⪫������ 䨧��᪮�� ࠧ���� (祫.)")
    add_string("    ������ ��⥩   �襤�� ���ࠧ��⨥ ����������������������������������������")
    add_string("                    �ᯠ��ਧ�   祫.  �����.��᳨����.��᳭���.��Ⳣ��.���")
    add_string("��������������������������������������������������������������������������������")
    add_string("          1         �    2    �    3    �    4    �    5    �    6    �    7    ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (����稪�)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 1 to 5
          find (str(j,1)+str(k,1)+str(i,2))
          if found()
            s += " "+padc(lstr(tmp16->kol),9)
          else
            s += space(10)
          endif
        next
        add_string(s)
      next
    next
    add_string(replicate("�",sh))
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("17. ���।������ ��⥩ �� ��㯯�� ���ﭨ� ���஢��")
    add_string("��������������������������������������������������������������������������������")
    add_string("                    ���᫮ �ள �� ��ᯠ��ਧ�樨     � �� १���⠬ ���-�� ")
    add_string("    ������ ��⥩   �襤�� ����������������������������������������������������")
    add_string("                    �ᯠ��ਧ� I  � II � III� IV � V  � I  � II � III� IV � V  ")
    add_string("��������������������������������������������������������������������������������")
    add_string("          1         �    2    � 3  � 4  � 5  � 6  � 7  � 8  � 9  � 10 � 11 � 12 ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (����稪�)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 11 to 15
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        for i := 21 to 25
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        add_string(s)
      next
    next
    add_string(replicate("�",sh))
    fclose(fp)
    viewtext(n_file,,,,.f.,,,5)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 08.11.13
Function f2_inf_DDS_030dso(Loc_kod,kod_kartotek) // ᢮���� ���ଠ��
Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
      is_man := (mpol == "�"), blk_tbl, blk_tip, blk_put_tip, ;
      a10[9], a11[13]
blk_tbl := {|_k| iif(_k < 2, 1, 2) }
blk_tip := {|_k| iif(_k == 0, 2, iif(_k > 1, _k+1, _k)) }
blk_put_tip := {|_e,_k| iif(_k > _e, _k, _e) }
arr_deti[1] ++
if mvozrast < 5
  arr_deti[2] ++
elseif mvozrast < 10
  arr_deti[3] ++
elseif mvozrast < 15
  arr_deti[4] ++
else
  arr_deti[5] ++
endif
for i := 1 to len(arr_vozrast)
  if between(mvozrast,arr_vozrast[i,2],arr_vozrast[i,3])
    aadd(av,arr_vozrast[i,1]) // ᯨ᮪ ⠡��� � 4 �� 9
  endif
next
for i := 1 to len(arr1vozrast)
  if between(mvozrast,arr1vozrast[i,1],arr1vozrast[i,2])
    aadd(av1,i)
  endif
next
for i := 1 to 5
  j := 0
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(16) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
use (cur_dir+"tmp4") index (cur_dir+"tmp4") new alias TMP
use (cur_dir+"tmp10") index (cur_dir+"tmp10") new alias TMP10
afill(a10,0)
for i := 1 to len(ad) // 横� �� ���������
  au := {}
  d := diag_to_num(ad[i,1],1)
  for n := 1 to len(arr_4)
    if !empty(arr_4[n,3]) .and. between(d,arr_4[n,4],arr_4[n,5])
      aadd(au,n)
    endif
  next
  if len(au) == 1
    aadd(au,len(arr_4)-1)  // {"18","��稥","",,},;
  endif
  select TMP
  for n := 1 to len(av) // 横� �� ᯨ�� ⠡��� � 4 �� 9
    for j := 1 to len(au)
      find (str(av[n],1)+str(au[j],2))
      if found()
        tmp->k04 ++
        if is_man
          tmp->k05 ++
        endif
        if ad[i,2] > 0 // ���.�����
          tmp->k06 ++
          if is_man
            tmp->k07 ++
          endif
        endif
        if ad[i,3] > 0 // ���.����.��⠭������
          tmp->k08 ++
          if is_man
            tmp->k09 ++
          endif
          if ad[i,3] == 2 // ���.����.��⠭������ �����
            tmp->k10 ++
            if is_man
              tmp->k11 ++
            endif
          endif
        endif
      endif
    next
  next
  if ad[i,4] == 1 // 1-���.����.�����祭�
    ntbl := eval(blk_tbl,ad[i,5])
    ntip := eval(blk_tip,ad[i,6])
    if ntbl == 1 .and. a10[3] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a10[1] := 0
      a10[3] := eval(blk_put_tip,a10[3],ntip)
    else
      a10[1] := eval(blk_put_tip,a10[1],ntip)
      a10[3] := 0
    endif
  endif
  if ad[i,7] == 1 // 1-���.����.�믮�����
    ntbl := eval(blk_tbl,ad[i,8])
    ntip := eval(blk_tip,ad[i,9])
    if ntbl == 1 .and. a10[4] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a10[2] := 0
      a10[4] := eval(blk_put_tip,a10[4],ntip)
    else
      a10[2] := eval(blk_put_tip,a10[2],ntip)
      a10[4] := 0
    endif
  endif
  if ad[i,10] == 1 // 1-��祭�� �����祭�
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a10[6] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a10[5] := 0
      a10[6] := eval(blk_put_tip,a10[6],ntip)
    else
      a10[5] := eval(blk_put_tip,a10[5],ntip)
      a10[6] := 0
    endif
  endif
  if ad[i,13] == 1 // 1-ॠ���.�����祭�
    ntbl := eval(blk_tbl,ad[i,14])
    ntip := eval(blk_tip,ad[i,15])
    if ntbl == 1 .and. a10[8] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
      a10[7] := 0
      a10[8] := eval(blk_put_tip,a10[8],ntip)
    else
      a10[7] := eval(blk_put_tip,a10[7],ntip)
      a10[8] := 0
    endif
  endif
  if ad[i,16] == 1 // 1-��� �����祭�
    a10[9] := 1
  endif
next
select TMP10
for n := 1 to len(av1) // 横� �� �����⠬ ⠡��� 10
  for j := 1 to len(a10)-1
    if a10[j] > 0
      find (str(av1[n],1)+str(j,1)+str(a10[j],1))
      if !found()
        append blank
        tmp10->voz := av1[n]
        tmp10->tbl := j
        tmp10->tip := a10[j]
      endif
      tmp10->kol ++
    endif
  next
next
ad := {}
for i := 1 to 5
  j := 0
  for k := 1 to 14
    s := "diag_15_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(14) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
use (cur_dir+"tmp11") index (cur_dir+"tmp11") new alias TMP11
afill(a11,0)
for i := 1 to len(ad) // 横� �� ���������
  if ad[i,3] == 1 // 1-��祭�� �����祭�
    ntbl := eval(blk_tbl,ad[i,4])
    ntip := eval(blk_tip,ad[i,5])
    if ntbl == 1 .and. a11[4] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a11[1] := 0
      a11[4] := eval(blk_put_tip,a11[4],ntip)
    else
      a11[1] := eval(blk_put_tip,a11[1],ntip)
      a11[4] := 0
    endif
    // ��祭�� �믮�����
    ntbl := eval(blk_tbl,ad[i,6])
    ntip := eval(blk_tip,ad[i,7])
    if ntbl == 1 .and. a11[5] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a11[2] := 0
      a11[5] := eval(blk_put_tip,a11[5],ntip)
    else
      a11[2] := eval(blk_put_tip,a11[2],ntip)
      a11[5] := 0
    endif
  endif
  if ad[i,8] == 1 // 1-ॠ���.�����祭�
    ntbl := eval(blk_tbl,ad[i,9])
    ntip := eval(blk_tip,ad[i,10])
    if ntbl == 1 .and. a11[10] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a11[ 7] := 0
      a11[10] := eval(blk_put_tip,a11[10],ntip)
    else
      a11[ 7] := eval(blk_put_tip,a11[7],ntip)
      a11[10] := 0
    endif
    // 1-ॠ���.�믮�����
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a11[11] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
      a11[ 8] := 0
      a11[11] := eval(blk_put_tip,a11[11],ntip)
    else
      a11[ 8] := eval(blk_put_tip,a11[8],ntip)
      a11[11] := 0
    endif
  endif
  if ad[i,14] == 1 // 1-��� �஢�����
    a11[13] := 1
  endif
next
select TMP11
for n := 1 to len(av1) // 横� �� �����⠬ ⠡��� 10
  for j := 1 to len(a11)-1
    if a11[j] > 0
      find (str(av1[n],1)+str(j,2)+str(a11[j],1))
      if !found()
        append blank
        tmp11->voz := av1[n]
        tmp11->tbl := j
        tmp11->tip := a11[j]
      endif
      tmp11->kol ++
    endif
  next
next
if a10[9] > 0
  s12_1++
  if is_man
    s12_1m++
  endif
endif
if a11[13] > 0
  s12_2++
  if is_man
    s12_2m++
  endif
endif
ad := {0}
if m1invalid1 == 1 // ������������-��
  aadd(ad,4)
  if m1invalid2 == 0 // � ஦�����
    aadd(ad,1)
  else               // �ਮ��⥭���
    aadd(ad,2)
    if !empty(minvalid3) .and. minvalid3 >= mn_data
      aadd(ad,3)
    endif
  endif
  if !empty(minvalid7) // ��� �����祭�� ���.�ணࠬ�� ॠ�����樨
    aadd(ad,10)
    do case // �믮������
      case m1invalid8 == 1 // ���������,1
        aadd(ad,11)
      case m1invalid8 == 2 // ���筮,2
        aadd(ad,12)
      case m1invalid8 == 3 // ����,3
        aadd(ad,13)
      otherwise            // �� �믮�����,0
        aadd(ad,14)
    endcase
  endif
endif
if m1privivki1 == 1     // �� �ਢ�� �� ����樭᪨� ���������",1},;
  if m1privivki2 == 1
    aadd(ad,21)
  else
    aadd(ad,22)
  endif
elseif m1privivki1 == 2 // �� �ਢ�� �� ��㣨� ��稭��",2}}
  if m1privivki2 == 1
    aadd(ad,23)
  else
    aadd(ad,24)
  endif
else                    // �ਢ�� �� �������",0},;
  aadd(ad,20)
endif
use (cur_dir+"tmp13") index (cur_dir+"tmp13") new alias TMP13
for n := 1 to len(av1) // 横� �� �����⠬ ⠡����
  for j := 1 to len(ad)
    find (str(av1[n],1)+str(ad[j],2))
    if !found()
      append blank
      tmp13->voz := av1[n]
      tmp13->tip := ad[j]
    endif
    tmp13->kol ++
  next
next
ad := {0}
if m1fiz_razv == 0
  aadd(ad,1)
else
  if m1fiz_razv1 == 1
    aadd(ad,2)
  elseif m1fiz_razv1 == 2
    aadd(ad,3)
  endif
  if m1fiz_razv2 == 1
    aadd(ad,4)
  elseif m1fiz_razv2 == 2
    aadd(ad,5)
  endif
endif
aadd(ad,mGRUPPA_DO+10)
aadd(ad,mGRUPPA+20)
    //index on str(voz,1)+str(man,1)+str(tip,2) to tmp16
use (cur_dir+"tmp16") index (cur_dir+"tmp16") new alias TMP16
for n := 1 to len(av1) // 横� �� �����⠬ ⠡����
  for j := 1 to len(ad)
    find (str(av1[n],1)+"0"+str(ad[j],2))
    if !found()
      append blank
      tmp16->voz := av1[n]
      tmp16->tip := ad[j]
    endif
    tmp16->kol ++
    if is_man
      find (str(av1[n],1)+"1"+str(ad[j],2))
      if !found()
        append blank
        tmp16->voz := av1[n]
        tmp16->man := 1
        tmp16->tip := ad[j]
      endif
      tmp16->kol ++
    endif
  next
next
return NIL

***** 24.12.19
Function inf_DDS_XMLfile(is_schet)
Static stitle := "XML-���⠫: ��ᯠ��ਧ��� ��⥩-��� "
Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[BR_LEN]
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DDS(arr_m,is_schet > 1,is_schet == 3,.t.)
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmp")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            E_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := 2
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_TITUL] := stitle+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'�','�','�',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" ", {|| iif(tmp->is==1,""," ") }, blk },;
                         {" �.�.�.", {|| padr(human->fio,37) }, blk },;
                         {"��� ஦�.", {|| full_date(human->date_r) }, blk },;
                         {"� ��.�����", {|| human->uch_doc }, blk },;
                         {"�ப� ���-�", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"�⠯", {|| iif(human->ishod==101," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室 ��� ᮧ����� 䠩��;  ^<+,-,Ins>^ - �⬥���/���� �⬥�� � ��樥��") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_N_XMLfile(nk,ob,"edit") }
    edit_browse(t_arr)
    select TMP
    delete for is == 0
    pack
    n := lastrec()
    close databases
    rest_box(buf)
    if n == 0 .or. !f_Esc_Enter("��⠢����� XML-䠩��")
      return NIL
    endif
    mywait()
    R_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
    Use
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    index on str(KOD_H,7) to (cur_dir+"tmpraksh")
    Use
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    mo_mzxml_N(1)
    n := 0
    do while .t.
      ++n
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say padr(str(n/tmp->(lastrec())*100,6,2)+"%"+" "+;
                            rtrim(human->fio)+" "+date_8(human->n_data)+"-"+;
                            date_8(human->k_data),80) color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      oms_sluch_DDS(p_tip_lu,lkod_h,lkod_k,"f2_inf_N_XMLfile")
    enddo
    close databases
    rest_box(buf)
    mo_mzxml_N(3,"tmp",stitle)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 06.09.21 ���ଠ�� �� ��ᯠ��ਧ�樨 � ��䨫��⨪� ���᫮�� ��ᥫ����
Function inf_DVN(k)
Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 2, si6 := 2, si7 := 2, sj := 1, sj1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"���� ���� �131/~�",;
                "~���᮪ ��樥�⮢",;
                "�������ਠ��� ~�����",;
                "����� ��� ~�����ࠢ�",;
                "����� �� �� ��� ~�����ࠢ�",;
                "����⭠� �ଠ �~131",;
                "����� ~䠩���� R0... � ��"}
    mas_msg := {"��ᯥ�⪠ ����� ���� ��ᯠ��ਧ�樨 (��䨫����᪨� ���.�ᬮ�஢) �131/�",;
                "��ᯥ�⪠ ᯨ᪠ ��樥�⮢, ��襤�� ��ᯠ��ਧ���/��䨫��⨪�",;
                "�������ਠ��� ����� �� ��ᯠ��ਧ�樨/��䨫��⨪� ���᫮�� ��ᥫ����",;
                "��ᯥ�⪠ ᢮��� ��� ������ࠤ᪮�� �����⭮�� ������ ��ࠢ���࠭����",;
                "��ᯥ�⪠ ᢮��� �� 㣫㡫����� ��ᯠ��ਧ�樨 ��� ������ࠤ᪮�� �����ࠢ�",;
                "�������� � ��ᯠ��ਧ�樨 ��।����� ��㯯 ���᫮�� ��ᥫ����",;
                "���ଠ樮���� ᮯ஢������� �� ��-樨 ��宦����� ��䨫����᪨� ��ய��⨩"}
    mas_fun := {"inf_DVN(11)",;
                "inf_DVN(12)",;
                "inf_DVN(13)",;
                "inf_DVN(14)",;
                "inf_DVN(17)",;
                "inf_DVN(15)",;
                "inf_DVN(16)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    f_131_u()
  case k == 12
    mas_pmt := aclone(mas1pmt)
    aadd(mas_pmt, "��砨, ��� ~�� �����訥 � ���")
    if (j := popup_prompt(T_ROW,T_COL-5,sj,mas_pmt)) > 0
      sj := j
      if (j := popup_prompt(T_ROW,T_COL-5,sj1,;
                            {"��ᯠ��ਧ��� ~1 �⠯",;
                             "���ࠢ���� �� 2 �⠯ - ��� ~�� ��諨",;
                             "��ᯠ��ਧ��� ~2 �⠯",;
                             "~��䨫��⨪�"})) > 0
        sj1 := j
        f2_inf_DVN(sj,sj1)
      endif
    endif
  case k == 13
    /*mas_pmt := {"~���, �������騥 ��ᯠ��ਧ�樨"}
    mas_msg := {"����� ���, ��������� ��ᯠ�ਧ�樨, ��⮤�� �������ਠ�⭮�� ���᪠"}
    mas_fun := {"inf_DVN(31)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)*/
    inf_DVN(31)
  case k == 14
    mas_pmt := {"~�������� � ��ᯠ��ਧ�樨 �� ���ﭨ� �� ...",;
                "~��������� �����ਭ�� ��ᯠ��ਧ�樨 ������"}
    mas_msg := {"�ਫ������ � �ਪ��� ���� �2066 �� 01.08.2013�.",;
                "��������� �����ਭ�� ��ᯠ��ਧ�樨 ������"}
    mas_fun := {"inf_DVN(21)",;
                "inf_DVN(22)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 15
    if (j := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      forma_131(j)
    endif
  case k == 16
    mas_pmt := {"����-��䨪 (R0~5)",;
                "����� ������ (R0~1)",;
                "~����� ������ (R11)"}
    mas_msg := {"�������� � ��ᬮ�� 䠩��� ������ R05...",;
                "�������� � ��ᬮ�� 䠩��� ������ R01...",;
                "�������� � ��ᬮ�� 䠩��� ������ R11..."}
    mas_fun := {"inf_DVN(41)",;
                "inf_DVN(42)",;
                "inf_DVN(43)"}
    str_sem := "�����"
    if G_SLock(str_sem)
      ///fff_init_r01()
      popup_prompt(T_ROW-len(mas_pmt)-3,T_COL-5,si4,mas_pmt,mas_msg,mas_fun)
      G_SUnLock(str_sem)
    else
      func_error(4,"� ����� ������ � �⨬ ०���� ࠡ�⠥� ��㣮� ���짮��⥫�.")
    endif
  case k == 17
    inf_YDVN()
  case k == 41
    mas_pmt := {"~�������� �����-��䨪�",;
                "~��ᬮ�� 䠩��� ������"}
    mas_msg := {"�������� 䠩�� ������ R05... � ������-��䨪�� �� ����栬",;
                "��ᬮ�� 䠩��� ������ R05... � १���⮢ ࠡ��� � ����"}
    mas_fun := {"inf_DVN(51)",;
                "inf_DVN(52)"}
    popup_prompt(T_ROW,T_COL-5,si5,mas_pmt,mas_msg,mas_fun)
  case k == 42
    mas_pmt := {"~�������� 䠩��� ������",;
                "~��ᬮ�� 䠩��� ������"}
    mas_msg := {"�������� 䠩��� ������ R01... �� �ᥬ ����栬",;
                "��ᬮ�� 䠩��� ������ R01... � १���⮢ ࠡ��� � ����"}
    mas_fun := {"inf_DVN(61)",;
                "inf_DVN(62)"}
    if need_delete_reestr_R01()
      aadd(mas_pmt, "~���㫨஢���� �����")
      aadd(mas_msg, "���㫨஢���� ������ᠭ���� ����� 䠩��� R01")
      aadd(mas_fun, "delete_reestr_R01()")
    endif
    //set key K_CTRL_F10 to delete_month_R01()
    popup_prompt(T_ROW,T_COL-5,si6,mas_pmt,mas_msg,mas_fun)
    //set key K_CTRL_F10 to

  case k == 21
    if (j := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      f21_inf_DVN(j)
    endif
  case k == 22
    f22_inf_DVN(j)
  case k == 31
    mnog_poisk_DVN1()
  case k == 51
    f_create_R05()
  case k == 52
    f_view_R05()
  case k == 61
    f_create_R01()
  case k == 62
    f_view_R01()
  case k == 43
    //ne_real()
    mas_pmt := {"~�������� 䠩��� ������",;
                "~��ᬮ�� 䠩��� ������"}
    mas_msg := {"�������� 䠩��� ������ R11... �� ������� �����",;
                "��ᬮ�� 䠩��� ������ R11... � १���⮢ ࠡ��� � ����"}
    mas_fun := {"inf_DVN(71)",;
                "inf_DVN(72)"}
    if need_delete_reestr_R01()
      aadd(mas_pmt, "~���㫨஢���� �����")
      aadd(mas_msg, "���㫨஢���� ������ᠭ���� ����� R11")
      aadd(mas_fun, "delete_reestr_R11()")
    endif
    set key K_CTRL_F10 to delete_month_R11()
    popup_prompt(T_ROW,T_COL-5,si7,mas_pmt,mas_msg,mas_fun)
    set key K_CTRL_F10 to
  case k == 71
    f_create_R11()
  case k == 72
    f_view_R01(_XML_FILE_R11)
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
  elseif between(k,51,59)
    si5 := j
  elseif between(k,61,69)
    si6 := j
  elseif between(k,71,79)
    si7 := j
  endif
endif
return NIL

***** 15.08.19
Function f0_inf_DVN(arr_m,is_schet,is_reg,is_1_2)
Local fl := .t., j := 0, n, buf := save_maxrow()
DEFAULT is_schet TO .t., is_reg TO .f., is_1_2 TO .f.
if !del_dbf_file("tmp"+sdbf)
  return .f.
endif
mywait()
dbcreate(cur_dir+"tmp",{{"kod_k","N",7,0},;
                        {"kod1h","N",7,0},;
                        {"date1","D",8,0},;
                        {"kod2h","N",7,0},;
                        {"date2","D",8,0},;
                        {"kod3h","N",7,0},;
                        {"date3","D",8,0},;
                        {"kod4h","N",7,0},;
                        {"date4","D",8,0}})
use (cur_dir+"tmp") new
index on str(kod_k,7) to (cur_dir+"tmp")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_
n := iif(is_1_2, 204, 203)
dbseek(dtos(arr_m[5]),.t.)
index on kod to (cur_dir+"tmp_h") ;
      for between(ishod,201,n) .and. human->cena_1 > 0 .and. iif(is_schet, schet > 0, .t.) ;
      while human->k_data <= arr_m[6] ;
      PROGRESS
go top
do while !eof()
  fl := f_is_uch(st_a_uch,human->lpu)
  if fl .and. is_reg
    fl := .f.
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      fl := .t.
    endif
  endif
  if fl .and. ret_koef_from_RAK(human->kod) > 0
    select TMP
    find (str(human->kod_k,7))
    if !found()
      append blank
      tmp->kod_k := human->kod_k
    endif
    do case
      case human->ishod == 201
        if (empty(tmp->date1) .or. human->k_data > tmp->date1)
          tmp->kod1h := human->kod
          tmp->date1 := human->k_data
        endif
      case human->ishod == 202
        if (empty(tmp->date2) .or. human->k_data > tmp->date2)
          tmp->kod2h := human->kod
          tmp->date2 := human->k_data
        endif
      case human->ishod == 203
        if (empty(tmp->date3) .or. human->k_data > tmp->date3)
          tmp->kod3h := human->kod
          tmp->date3 := human->k_data
        endif
      case human->ishod == 204
        tmp->kod4h := human->kod
        tmp->date4 := human->k_data
    endcase
    if ++j % 1000 == 0
      commit
    endif
  endif
  select HUMAN
  skip
enddo
rest_box(buf)
fl := .t.
if tmp->(lastrec()) == 0
  fl := func_error(4,"�� ������� �/� �� ��ᯠ��ਧ�樨 ���᫮�� ��ᥫ���� "+arr_m[4])
endif
close databases
return fl

*

***** 20.10.16 ���� ���� ��ᯠ��ਧ�樨 �� �ଥ �131/�
Function f_131_u()
Local arr_m, buf := save_maxrow(), k, blk, t_arr[BR_LEN], rec := 0
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
              .and. (arr_m := year_month(,,,5)) != NIL .and. f0_inf_DVN(arr_m,.f.)
  mywait()
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp") index (cur_dir+"tmp") new
  if glob_kartotek > 0
    find (str(glob_kartotek,7))
    if found()
      rec := tmp->(recno())
    endif
  endif
  set relation to kod_k into KART
  index on upper(kart->fio) to (cur_dir+"tmp")
  Private ;
    blk_open := {|| dbCloseAll(),;
                    R_Use(dir_server+"uslugi",,"USL"),;
                    R_Use(dir_server+"human_u_",,"HU_"),;
                    R_Use(dir_server+"human_u",dir_server+"human_u","HU"),;
                    dbSetRelation( "HU_", {|| recno() }, "recno()" ),;
                    R_Use(dir_server+"human_",,"HUMAN_"),;
                    R_Use(dir_server+"human",,"HUMAN"),;
                    dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                    R_Use(dir_server+"kartote_",,"KART_"),;
                    R_Use(dir_server+"kartotek",,"KART"),;
                    dbSetRelation( "KART_", {|| recno() }, "recno()" ),;
                    R_Use(cur_dir+"tmp",cur_dir+"tmp"),;
                    dbSetRelation( "KART", {|| kod_k }, "kod_k" );
                }
  eval(blk_open)
  go top
  if rec > 0
    goto (rec)
  endif
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := 23
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_TITUL] := "���᫮� ��ᥫ���� "+arr_m[4]
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {'�','�','�',"N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB",.t.}
  blk := {|| iif(emptyall(tmp->kod1h,tmp->kod2h), {5,6}, iif(empty(tmp->kod2h), {1,2}, {3,4})) }
  t_arr[BR_COLUMN] := {{" �.�.�.",     {|| padr(kart->fio,39) }, blk },;
                       {"��� ஦�.",  {|| full_date(kart->date_r) }, blk },;
                       {"� ��.�����",  {|| padr(__f_131_u(1),10) }, blk },;
                       {"�ப� ���-�", {|| padr(__f_131_u(2),11) }, blk },;
                       {"�⠯",        {|| padr(__f_131_u(3), 4) }, blk }}
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Enter>^ - �ᯥ���� ����� ���� ���-�� (���.�ᬮ��)") }
  t_arr[BR_EDIT] := {|nk,ob| f1_131_u(nk,ob,"edit") }
  edit_browse(t_arr)
endif
close databases
rest_box(buf)
return NIL

***** 20.09.15
Static Function __f_131_u(k)
Local s := "", ie := 1
if emptyall(tmp->kod1h,tmp->kod2h) // ����� ��䨫��⨪�
  human->(dbGoto(tmp->kod3h))
  ie := 3
else // ��ᯠ��ਧ���
  if empty(tmp->kod1h) // ��祬�-� ��� ��ࢮ�� �⠯�
    human->(dbGoto(tmp->kod2h))
  else
    human->(dbGoto(tmp->kod1h))
  endif
  if !empty(tmp->kod2h) // ���� ��ன �⠯
    ie := 2
  endif
endif
if k == 1
  s := human->uch_doc
elseif k == 2
  s := left(date_8(human->n_data),5)+"-"
  if ie == 2
    human->(dbGoto(tmp->kod2h))
  endif
  s += left(date_8(human->k_data),5)
else
  s := {"I ��","I-II","���"}[ie]
endif
return s

*

***** 21.07.19
Function f1_131_u(nKey,oBrow,regim)
Static lV := "V", sb1 := "<b><u>", sb2 := "</u></b>"
Static s_smg := "�� 㤠���� ��।����� ��㯯� ���஢��"
Local ret := -1, rec := tmp->(recno()), buf := save_maxrow(),;
      i, j, k, fl, lshifr, au := {}, ar, metap, m1gruppa, is_disp := .t.,;
      mpol := kart->pol, fl_dispans := .f., adbf, s, y, m, d, arr,;
      blk := {|s| __dbAppend(), field->stroke := s }
if regim == "edit" .and. nKey == K_ENTER
  glob_kartotek := tmp->kod_k
  delFRfiles()
  mywait()
  Private arr_otklon := {}, arr_usl_otkaz := {}, mvozrast, mdvozrast,;
          M1RAB_NERAB, m1veteran := 0, m1mobilbr := 0,;
          m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0,;
          m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
          mholest := 0, mglukoza := 0, ;
          m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
          m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0,;
          m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0,;
          m1spec_na := 0, m1sank_na := 0,;
          pole_diag, pole_1pervich, pole_1stadia, pole_1dispans,;
          mWEIGHT := 0, mHEIGHT := 0, mn_data, mk_data, mk_data1
  for i := 1 to 5
    pole_diag := "mdiag"+lstr(i)
    pole_d_diag := "mddiag"+lstr(i)
    pole_1pervich := "m1pervich"+lstr(i)
    pole_1stadia := "m1stadia"+lstr(i)
    pole_1dispans := "m1dispans"+lstr(i)
    pole_d_dispans := "mddispans"+lstr(i)
    Private &pole_diag := space(6)
    Private &pole_d_diag := ctod("")
    Private &pole_1pervich := 0
    Private &pole_1stadia := 0
    Private &pole_1dispans := 0
    Private &pole_d_dispans := ctod("")
  next
  if emptyall(tmp->kod1h,tmp->kod2h) // ����� ��䨫��⨪�
    is_disp := .f.
    human->(dbGoto(tmp->kod3h))
    if between(human_->RSLT_NEW,343,345)
      m1GRUPPA := human_->RSLT_NEW - 342
    elseif between(human_->RSLT_NEW,373,374)
      m1GRUPPA := human_->RSLT_NEW - 370
    endif
    if !between(m1gruppa,1,4)
      m1GRUPPA := 0 ; func_error(4,s_smg)
    endif
  else // I �⠯
    if empty(tmp->kod1h)
      func_error(4,"��������� II �⠯, �� ��������� I �⠯")
      rest_box(buf)
      return ret
    endif
    human->(dbGoto(tmp->kod1h))
    m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
    if !between(m1gruppa,0,4)
      m1GRUPPA := 0 ; func_error(4,s_smg)
    endif
  endif
  M1RAB_NERAB := human->RAB_NERAB
  mn_data := human->n_data
  mk_data := mk_data1 := human->k_data
  Private is_disp_19 := !(mk_data < d_01_05_2019)
  Private is_disp_21 := !(mk_data < d_01_01_2021)
  mdate_r := full_date(human->date_r)
  read_arr_DVN(human->kod)
  ret_arr_vozrast_DVN(mk_data)
  ret_arrays_disp(is_disp_19,is_disp_21)
  ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
  mvozrast := count_years(human->date_r,human->n_data)
  mdvozrast := year(human->n_data) - year(human->date_r)
  if m1veteran == 1
    mdvozrast := ret_vozr_DVN_veteran(mdvozrast,human->k_data)
  endif
  select HU
  find (str(human->kod,7))
  do while hu->kod == human->kod .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
      lshifr := usl->shifr
    endif
    if !eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.")
      aadd(au,{alltrim(lshifr),;
               hu_->PROFIL,;
               iif(left(hu_->kod_diag,1)=="Z","",hu_->kod_diag),;
               c4tod(hu->date_u);
              })
    endif
    select HU
    skip
  enddo
  k_nev_4_1_12 := 0
  for k := 1 to len(au)
    lshifr := au[k,1]
    if is_disp_19
        //
    elseif ((lshifr == "2.3.3" .and. au[k,2] == 3) .or.  ; // �����᪮�� ����
            (lshifr == "2.3.1" .and. au[k,2] == 136))    // �������� � �����������
      k_nev_4_1_12 := k
    endif
    if ascan(arr_otklon,au[k,1]) > 0
      au[k,3] := "+" // �⪫������ � ��᫥�������
      if eq_any(lshifr,"4.20.1","4.20.2") // �᫨ �⪫������ � ��᫥������� �⮫����.���ਠ��
        if (i := ascan(au, {|x| x[1] == "4.1.12"})) > 0
          au[i,3] := "+" // ������ �⪫������ � �ᬮ�� 䥫��� "4.1.12"
        endif
      endif
    endif
  next
  if is_disp_19
    arr_10 := {;
      { 1,"56.1.16","���� (�����஢����) �� ������ �஭��᪨� ����䥪樮���� �����������, 䠪�஢ �᪠ �� ࠧ����, ���ॡ����� ��મ��᪨� �।�� � ����ய��� ����� ��� �����祭�� ���"},;
      { 2,"3.1.19","���ய������ (����७�� ��� ���, ����� ⥫�, ���㦭��� ⠫��), ���� ������ ����� ⥫�"},;
      { 3,"3.1.5","����७�� ���ਠ�쭮�� ��������"},;
      { 4,"3.4.9","����७�� ����ਣ������� ��������"},;
      { 5,"4.12.174","��᫥������� �஢� �� ��騩 宫���ਭ"},;
      { 6,"4.12.169","��᫥������� �஢�� ���� � �஢�"},;
      { 7,"4.11.137","������᪨� ������ �஢� (3 ������⥫�)"},;
      { 8,"4.8.4","��᫥������� ���� �� ������ �஢�"},;
      { 9,"4.14.66","��᫥������� �஢� �� �����-ᯥ���᪨� ��⨣��"},;
      {10,{{"2.3.1",136},{"2.3.3",3},{"2.3.3",42}},"�ᬮ�� ����મ� ��� ����஬-�����������"},;
      {11,{"4.1.12","4.20.1","4.20.2"},"���⨥ ����� (�᪮��) � �����孮�� 襩�� ��⪨ (���㦭��� ���筮�� ����) � �ࢨ���쭮�� ������ �� �⮫����᪮� ��᫥�������"},;
      {12,"7.57.3","��������� ����� ������� �����"},;
      {13,"7.61.3","���ண��� �񣪨� ��䨫����᪠�"},;
      {14,"13.1.1","�����ப�न����� (� �����)"},;
      {15,"10.3.13","�������䠣�����த㮤���᪮���"},;
      {16,"56.1.18","��।������ �⭮�⥫쭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠","mdvozrast < 40"},;
      {17,"56.1.19","��।������ ��᮫�⭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠","39 < mdvozrast .and. mdvozrast < 65"},;
      {18,"56.1.14","��⪮� �������㠫쭮� ��䨫����᪮� �������஢����"},;
      {19,{{"2.3.7",57},{"2.3.7",97},{"2.3.2",57},{"2.3.2",97},{"2.3.4",42}},"�ਥ� (�ᬮ��) ���-�࠯���"};
     }
  else
    arr_10 := {;
      { 1,"56.1.16","���� (�����஢����) �� ������ �஭��᪨� ����䥪樮���� �����������, 䠪�஢ �᪠ �� ࠧ����, ���ॡ����� ��મ��᪨� �।�� � ����ய��� ����� ��� �����祭�� ���"},;
      { 2,"3.1.19","���ய������ (����७�� ��� ���, ����� ⥫�, ���㦭��� ⠫��), ���� ������ ����� ⥫�"},;
      { 3,"3.1.5","����७�� ���ਠ�쭮�� ��������"},;
      { 4,"4.12.174","��।������ �஢�� ��饣� 宫���ਭ� � �஢�"},;
      { 5,"4.12.169","��।������ �஢�� ���� � �஢� ������-��⮤��"},;
      { 6,{"56.1.17","56.1.18"},"��।������ �⭮�⥫쭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠","mdvozrast < 40"},;
      { 7,{"56.1.17","56.1.19"},"��।������ ��᮫�⭮�� �㬬�୮�� �थ筮-��㤨�⮣� �᪠","39 < mdvozrast .and. mdvozrast < 66"},;
      { 8,"13.1.1","�����ப�न����� (� �����)"},;
      { 9,{"4.1.12","4.20.1","4.20.2"},"�ᬮ�� 䥫��஬ (����મ�), ������ ���⨥ ����� (�᪮��) � �����孮�� 襩�� ��⪨ (���㦭��� ���筮�� ����) � �ࢨ���쭮�� ������ �� �⮫����᪮� ��᫥�������"},;
      {10,"7.61.3","���ண��� ������"},;
      {11,"7.57.3","��������� ����� ������� �����"},;
      {12,"4.11.137","������᪨� ������ �஢�"},;
      {13,"4.11.136","������᪨� ������ �஢� ࠧ������"},;
      {14,"4.12.172","������ �஢� ���娬��᪨� ����࠯����᪨�"},;
      {15,"4.2.153","��騩 ������ ���"},;
      {16,"4.8.4","��᫥������� ���� �� ������ �஢� ���㭮娬��᪨� ��⮤��"},;
      {17,{"8.2.1","8.2.4","8.2.5"},"����ࠧ�㪮��� ��᫥������� (���) �� �।��� �᪫�祭�� ������ࠧ������ �࣠��� ���譮� ������, ������ ⠧�"},;
      {18,"8.1.5","����ࠧ�㪮��� ��᫥������� (���) � 楫�� �᪫�祭�� ����ਧ�� ���譮� �����"},;
      {19,"3.4.9","����७�� ����ਣ������� ��������"},;
      {20,{{"2.3.1",97},{"2.3.1",57},{"2.3.2",97},{"2.3.2",57},{"2.3.3",42},{"2.3.5",57},{"2.3.5",97},{"2.3.6",57},{"2.3.6",97}},"�ਥ� (�ᬮ��) ���-�࠯���"};
     }
    if is_disp .and. year(mk_data) > 2017 // � 18 ����
      arr_10[13] := {13,"4.14.66","��᫥������� �஢� �� �����-ᯥ���᪨� ��⨣��"}
      Del_Array(arr_10,18)
      Del_Array(arr_10,17)
      Del_Array(arr_10,15)
      Del_Array(arr_10,14)
    endif
  endif
  dbcreate(fr_data,{{"name","C",200,0},;
                    {"ns","N",2,0},;
                    {"vv","C",10,0},;
                    {"vo","C",10,0},;
                    {"vd","C",20,0}})
  use (fr_data) new alias FRD
  for n := 1 to len(arr_10)
    append blank
    frd->name := arr_10[n,3]
    frd->ns := arr_10[n,1]
  next
  index on str(ns,2) to tmp_frd
  for i := 1 to len(arr_10)
    fl := fl_nev := .f. ;  date_o := ctod("")
    if valtype(arr_usl_otkaz) == "A"
      for k1 := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[k1]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C" ;
                              .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
          lshifr := alltrim(ar[5])
          if valtype(arr_10[i,2]) == "C"
            if lshifr == arr_10[i,2]
              fl := .t.
              if ar[10] == 1 // �⪠�
                date_o := ar[9]
              else // �������������
                fl_nev := .t.
              endif
            endif
          elseif valtype(arr_10[i,2,1]) == "C" // ���� � ���ᨢ�
            for j := 1 to len(arr_10[i,2])
              if lshifr == arr_10[i,2,j]
                fl := .t.
                if ar[10] == 1 // �⪠�
                  date_o := ar[9]
                else // �������������
                  fl_nev := .t.
                endif
                exit
              endif
            next
          else
            for j := 1 to len(arr_10[i,2])
              if lshifr == arr_10[i,2,j,1] .and. ar[4] == arr_10[i,2,j,2]
                fl := .t.
                if ar[10] == 1 // �⪠�
                  date_o := ar[9]
                else // �������������
                  fl_nev := .t.
                endif
                exit
              endif
            next
          endif
        endif
        if fl ; exit ; endif
      next
    endif
    if !fl
      if valtype(arr_10[i,2]) == "C" // ���� ���
        if (k := ascan(au, {|x| x[1] == arr_10[i,2]})) > 0
          fl := .t.
        endif
      elseif valtype(arr_10[i,2,1]) == "C" // ���� � ���ᨢ�
        for j := 1 to len(arr_10[i,2])
          if (k := ascan(au, {|x| x[1]==arr_10[i,2,j]})) > 0
            fl := .t. ; exit
          endif
        next
      else // � ���ᨢ� ����: ��� � ��䨫�
        for j := 1 to len(arr_10[i,2])
          if (k := ascan(au, {|x| x[1]==arr_10[i,2,j,1] .and. x[2]==arr_10[i,2,j,2]})) > 0
            fl := .t. ; exit
          endif
        next
      endif
    endif
    if fl .and. len(arr_10[i]) > 3
      fl := &(arr_10[i,4])
    endif
    if fl
      find (str(arr_10[i,1],2))
      if valtype(arr_10[i,2]) == "A" .and. valtype(arr_10[i,2,1]) == "C" ;
                                     .and. arr_10[i,2,1] == "4.1.12" .and. k_nev_4_1_12 > 0
        frd->vv := full_date(au[k_nev_4_1_12,4])
        frd->vd := "����������"
      elseif fl_nev
        frd->vv := "����������"
      elseif !empty(date_o)
        frd->vv := "�⪠�"
        frd->vo := full_date(date_o)
      else
        frd->vv := full_date(au[k,4])
        if au[k,4] < human->n_data
          frd->vo := full_date(au[k,4])
        endif
        frd->vd := iif(empty(au[k,3]), "-", "<b>"+au[k,3]+"</b>")
      endif
    endif
  next
  select FRD
  set index to
  go top
  do while !eof()
    if emptyall(frd->vv,frd->vd,frd->vo)
      delete
    endif
    skip
  enddo
  pack
  n := 0
  go top
  do while !eof()
    frd->ns := ++n
    skip
  enddo
  //
  adbf := {{"titul","C",50,0},;
           {"titul2","C",50,0},;
           {"fio","C",100,0},;
           {"fio2","C",60,0},;
           {"pol","C",50,0},;
           {"date_r","C",10,0},;
           {"d_dr","C",2,0},;
           {"m_dr","C",2,0},;
           {"y_dr","C",4,0},;
           {"vozrast","N",4,0},;
           {"subekt","C",50,0},;
           {"rajon","C",50,0},;
           {"gorod","C",50,0},;
           {"nas_p","C",50,0},;
           {"adres","C",200,0},;
           {"gorod_selo","C",50,0},;
           {"kod_lgot","C",2,0},;
           {"sever","C",30,0},;
           {"zanyat","C",200,0},;
           {"mobil","C",30,0},;
           {"n_data","C",10,0},;
           {"k_data","C",10,0},;
           {"v13_1","C",10,0},;
           {"v13_2","C",10,0},;
           {"v13_3","C",10,0},;
           {"v13_4","C",10,0},;
           {"v13_5","C",10,0},;
           {"v13_6","C",10,0},;
           {"v13_7","C",10,0},;
           {"v13_8","C",10,0},;
           {"v13_9","C",10,0},;
           {"v14","C",2,0},;
           {"v14_1","C",1,0},;
           {"v14_2","C",1,0},;
           {"v15","C",2,0},;
           {"v15_1","C",1,0},;
           {"v15_2","C",1,0},;
           {"v16_1","C",1,0},;
           {"v16_2","C",1,0},;
           {"v16_3","C",1,0},;
           {"v16_4","C",1,0},;
           {"v17","C",30,0},;
           {"v18","C",30,0},;
           {"v18_1","C",30,0},;
           {"v18_2","C",30,0},;
           {"v19","C",30,0},;
           {"v20","C",30,0},;
           {"vrach","C",100,0}}
  dbcreate(fr_titl, adbf)
  use (fr_titl) new alias FRT
  append blank
  frt->titul := iif(!emptyall(tmp->kod1h,tmp->kod2h), "��ᯠ��ਧ�樨", "��䨫����᪮�� ����樭᪮�� �ᬮ��")
  frt->titul2 := iif(!emptyall(tmp->kod1h,tmp->kod2h), "��ᯠ��ਧ���", "��䨫����᪨� ����樭᪨� �ᬮ��")
  arr := retFamImOt(1,.f.)
  frt->fio2 := arr[1]+" "+arr[2]+" "+arr[3]
  frt->fio := expand(upper(rtrim(frt->fio2)))
  frt->pol := iif(kart->pol=="�",sb1+"��. - 1"+sb2+", ���. - 2","��. - 1, "+sb1+"���. - 2"+sb2)
  frt->date_r := mdate_r
  frt->d_dr := substr(mdate_r,1,2)
  frt->m_dr := substr(mdate_r,4,2)
  frt->y_dr := substr(mdate_r,7,4)
  frt->vozrast := mvozrast
  if f_is_selo()
    frt->gorod_selo := "��த᪠� - 1, "+sb1+"ᥫ�᪠� - 2"+sb2
  else
    frt->gorod_selo := sb1+"��த᪠� - 1"+sb2+", ᥫ�᪠� - 2"
  endif
  arr := ret_okato_Array(kart_->okatog)
  frt->subekt := arr[1]
  frt->rajon  := arr[2]
  frt->gorod  := arr[3]
  frt->nas_p  := arr[4]
  if empty(kart->adres)
    frt->adres := "㫨�"+sb1+space(30)+sb2+" ���"+sb1+space(5)+sb2+" ������"+sb1+space(5)+sb2
  else
    frt->adres := sb1+padr(kart->adres,60)+sb2
  endif
  if (i := ascan(stm_kategor, {|x| x[2] == kart_->kategor })) > 0 .and. between(stm_kategor[i,3],1,8)
    frt->kod_lgot := lstr(stm_kategor[i,3])
  endif
  frt->mobil := f_131_u_da_net(m1mobilbr,sb1,sb2)
  frt->n_data := full_date(mn_data)
  frt->v13_1 := iif(mad1>140.and.mad2>90, frt->n_data, "-")
  frt->v13_2 := iif(m1glukozadn==1.or.mglukoza>6.1, frt->n_data, "-")
  frt->v13_3 := iif(m1tip_mas>=3, frt->n_data, "-")
  frt->v13_4 := iif(m1kurenie==1, frt->n_data, "-")
  frt->v13_5 := iif(m1riskalk==1, frt->n_data, "-")
  frt->v13_6 := iif(m1pod_alk==1, frt->n_data, "-")
  frt->v13_7 := iif(m1fiz_akt==1, frt->n_data, "-")
  frt->v13_8 := iif(m1ner_pit==1, frt->n_data, "-")
  frt->v13_9 := iif(m1ot_nasl1==1.or.m1ot_nasl2==1.or.m1ot_nasl3==1.or.m1ot_nasl4==1, frt->n_data, "-")
  if mdvozrast < 66
    if mdvozrast > 39
      frt->v15 := lstr(mssr)
      if 5 <= mssr .and. mssr < 10 // ��᮪�� ���.�㬬��� �थ筮-��㤨��� ��
        frt->v15_1 := lV
      elseif mssr >= 10 // �祭� ��᮪�� ���.�㬬��� �थ筮-��㤨��� ��
        frt->v16_2 := lV
      endif
    else
      frt->v14 := lstr(mssr)
      if mssr < 1 // ������ ��.�㬬��� �थ筮-��㤨��� ��
        frt->v14_1 := lV
      elseif 5 <= mssr .and. mssr < 10 // ������ ��.�㬬��� �थ筮-��㤨��� ��
        frt->v14_2 := lV
      endif
    endif
  endif
  dbcreate(fr_data+"1",{{"name","C",200,0},;
                        {"ns","N",2,0},;
                        {"vn","C",10,0},;
                        {"vv","C",10,0},;
                        {"vd","C",20,0}})
  if !empty(tmp->kod2h) // II �⠯
    human->(dbGoto(tmp->kod2h))
    M1RAB_NERAB := human->RAB_NERAB
    mk_data := human->k_data
    is_disp_19 := !(mk_data < d_01_05_2019)
    m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
    if !between(m1gruppa,1,4)
      m1GRUPPA := 0 ; func_error(4,s_smg)
    endif
    read_arr_DVN(human->kod)
    //
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      aadd(au,{alltrim(lshifr),;
               hu_->PROFIL,;
               iif(left(hu_->kod_diag,1)=="Z","",hu_->kod_diag),;
               c4tod(hu->date_u);
              })
      select HU
      skip
    enddo
    for k := 1 to len(au)
      if ascan(arr_otklon,au[k,1]) > 0
        au[k,3] := "+" // �⪫������ � ��᫥�������
      endif
    next
    if is_disp_19
      arr_11 := {;
        { 1,"�㯫��᭮� ᪠��஢���� ��娮�䠫��� ���਩","8.23.706"},;
        { 2,"���⣥������ �࣠��� ��㤭�� ���⪨","7.2.702"},;
        { 3,"�� �࣠��� ��㤭�� ������","7.2.701"},;
        { 4,"���ࠫ쭠� �� ������","7.2.703"},;
        { 5,"�� �࣠��� ��㤭�� ������ (� ��������-���)","7.2.704"},;
        { 6,"�����⮭��� ����ᨮ���� �� ������","7.2.705"},;
        { 7,"����ᨣ��������᪮��� ���������᪠�","10.6.710"},;
        { 8,"����஬���᪮���","10.4.701"},;
        { 9,"�������䠣�����த㮤���᪮���","10.3.713"},;
        {10,"���஬����","16.1.717"},;
        {11,"�ᬮ�� (���������) ��箬-���஫����","2.84.1"},;
        {12,"�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�஫����","2.84.10"},;
        {13,"�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�����ப⮫����","2.84.6"},;
        {14,"�ᬮ�� (���������) ��箬-����஬-�����������","2.84.5"},;
        {15,"�ᬮ�� (���������) ��箬-��ਭ���ਭ�������","2.84.8"},;
        {16,"�ᬮ�� (���������) ��箬-��⠫쬮�����","2.84.3"},;
        {17,"���㡫����� ��䨫����᪮� �������஢����","56.1.723"},;
        {18,"�ਥ� (�ᬮ��) ���-�࠯���","2.84.11"};
       }
    else
      arr_11 := {;
        { 1,"�㯫��᭮� ᪠��஢���� ��娮�䠫��� ���਩",{"8.23.6","8.23.706"}},;
        { 2,"�ᬮ�� (���������) ��箬-���஫����","2.84.1"},;
        { 3,"���䠣�����த㮤���᪮���","10.3.13"},;
        { 4,"�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�஫����","2.84.10"},;
        { 5,"�ᬮ�� (���������) ��箬-���࣮� ��� ��箬-�����ப⮫����","2.84.6"},;
        { 6,"������᪮��� ��� ४�஬���᪮���",{"10.4.1","10.6.10"}},;
        { 7,"��।������ ��������� ᯥ��� �஢�","4.12.173"},;
        { 8,"���஬����",{"16.1.17","16.1.717"}},;
        { 9,"�ᬮ�� (���������) ��箬-����஬-�����������","2.84.5"},;
        {10,"��।������ ���業��樨 �����஢������ ����������� � �஢� ��� ��� �� ⮫�࠭⭮��� � ����",{"4.12.170","4.12.171"}},;
        {11,"�ᬮ�� (���������) ��箬-��ਭ���ਭ�������","2.84.8"},;
        {12,"������ �஢� �� �஢��� ᮤ�ঠ��� �����ᯥ���᪮�� ��⨣���","4.14.66"},;
        {13,"�ᬮ�� (���������) ��箬-��⠫쬮�����","2.84.3"},;
        {14,"�������㠫쭮� 㣫㡫����� ��䨫����᪮� �������஢����",{"56.1.15","56.1.20"}},;
        {15,"��㯯���� ��䨫����᪮� �������஢���� (誮�� ��樥��)","0"},;
        {16,"�ਥ� (�ᬮ��) ���-�࠯���",{"2.84.2","2.84.7","2.84.9","2.84.11"}};
       }
      if is_disp .and. year(mk_data) > 2017 // � 18 ����
        arr_11[ 6] := { 6,"����ᨣ��������᪮��� ���������᪠�","10.6.710"}
        arr_11[14] := {14,"�������㠫쭮� ��� ��㯯���� (誮�� ��� ��樥��) 㣫㡫����� ��䨫����᪮� �������஢����","56.1.723"}
        Del_Array(arr_11,15)
        Del_Array(arr_11,12)
        Del_Array(arr_11,10)
        Del_Array(arr_11, 7)
        Del_Array(arr_11, 3)
      endif
    endif
    use (fr_data+"1") new alias FRD1
    for n := 1 to len(arr_11)
      append blank
      frd1->name := arr_11[n,2]
      frd1->ns := arr_11[n,1]
    next
    index on str(ns,2) to tmp_frd1
    for k := 1 to len(au)
      fl := .f.
      for i := 1 to len(arr_11)
        if valtype(arr_11[i,3]) == "A"
          fl := (ascan(arr_11[i,3],au[k,1]) > 0)
        else
          fl := (au[k,1]==arr_11[i,3])
        endif
        if fl ; exit ; endif
      next
      if fl
        find (str(arr_11[i,1],2))
        frd1->vn := full_date(mk_data1)
        frd1->vv := full_date(au[k,4])
        frd1->vd := iif(empty(au[k,3]), "-", "<b>"+au[k,3]+"</b>")
      endif
    next
    select FRD1
    set index to
    go top
    do while !eof()
      if emptyall(frd1->vv,frd1->vd,frd1->vn)
        delete
       endif
      skip
    enddo
    pack
    n := 0
    go top
    do while !eof()
      frd1->ns := ++n
      skip
    enddo
  endif
  frt->k_data := full_date(mk_data)
  frt->zanyat := iif(M1RAB_NERAB==0,sb1,"")+"1 - ࠡ�⠥�"+iif(M1RAB_NERAB==0,sb2,"")+";  "+;
     iif(M1RAB_NERAB==1,sb1,"")+"2 - �� ࠡ�⠥�"+iif(M1RAB_NERAB==1,sb2,"")+";  "+;
     iif(M1RAB_NERAB==2,"<u>","")+"3 - �����騩�� � ��ࠧ���⥫쭮� �࣠����樨 �� �筮� �ଥ"+iif(M1RAB_NERAB==2,"</u>","")+"."
  frt->sever := f_131_u_da_net(0,sb1,sb2)
  do case
    case m1gruppa == 1
      frt->v16_1 := lV
    case m1gruppa == 2
      frt->v16_2 := lV
    case m1gruppa == 3
      frt->v16_3 := lV
    case m1gruppa == 4
      frt->v16_4 := lV
  endcase
  frt->v17   := f_131_u_da_net(m1nazn_l,sb1,sb2)
  frt->v18   := f_131_u_da_net(m1dopo_na,sb1,sb2)
  frt->v18_1 := f_131_u_da_net(m1ssh_na,sb1,sb2)
  frt->v18_2 := f_131_u_da_net(m1psih_na,sb1,sb2)
  frt->v19   := f_131_u_da_net(m1spec_na,sb1,sb2)
  frt->v20   := f_131_u_da_net(m1sank_na,sb1,sb2)
  R_Use(dir_server+"mo_pers",,"P2")
  goto (human_->vrach)
  frt->vrach := p2->fio
  //
  arr_12 := {;
    { 7,"1","������� ��䥪樮��� � ��ࠧ���� �������","A00-B99"},;
    { 8,"1.1","  � ⮬ �᫥: �㡥�㫥�","A15-A19"},;
    { 9,"2","������ࠧ������","C00-D48"},;
    {10,"2.1","� ⮬ �᫥: �������⢥��� ������ࠧ������ � ������ࠧ������ in situ","C00-D09"},;
    {11,"2.2","� ⮬ �᫥: ��饢���","C15,D00.1"},;
    {12,"2.2.1"," �� ��� � 1-2 �⠤��","C15,D00.1","1"},;
    {13,"2.3","���㤪�","C16,D00.2"},;
    {14,"2.3.1"," �� ��� � 1-2 �⠤��","C16,D00.2","1"},;
    {15,"2.4","�����筮� ��誨","C18,D01.0"},;
    {16,"2.4.1"," �� ��� � 1-2 �⠤��","C18,D01.0","1"},;
    {17,"2.5","४�ᨣ�������� ᮥ�������, ��אַ� ��誨, ������� ��室� (����) � ����쭮�� ������","C19-C21,D01.1-D01.3"},;
    {18,"2.5.1"," �� ��� � 1-2 �⠤��","C19-C21,D01.1-D01.3","1"},;
    {19,"2.6","������㤮筮� ������","C25"},;
    {20,"2.6.1"," �� ��� � 1-2 �⠤��","C25","1"},;
    {21,"2.7","��奨, �஭客 � �������","C33,C34,D02.1-D02.2"},;
    {22,"2.7.1"," �� ��� � 1-2 �⠤��","C33,C34,D02.1-D02.2","1"},;
    {23,"2.8","����筮� ������","C50,D05"},;
    {24,"2.8.1"," �� ��� � 1-2 �⠤��","C50,D05","1"},;
    {25,"2.9","襩�� ��⪨","C53,D06"},;
    {26,"2.9.1"," �� ��� � 1-2 �⠤��","C53,D06","1"},;
    {27,"2.10","⥫� ��⪨","C54"},;
    {28,"2.10.1"," �� ��� � 1-2 �⠤��","C54","1"},;
    {29,"2.11","�筨��","C56"},;
    {30,"2.11.1"," �� ��� � 1-2 �⠤��","C56","1"},;
    {31,"2.12","�।��⥫쭮� ������","C61,D07.5"},;
    {32,"2.12.1"," �� ��� � 1-2 �⠤��","C61,D07.5","1"},;
    {33,"2.13","��窨, �஬� ���筮� ��堭��","C64"},;
    {34,"2.13.1"," �� ��� � 1-2 �⠤��","C64","1"},;
    {35,"3","������� �஢�, �஢�⢮��� �࣠��� � �⤥��� ����襭��, ��������騥 ���㭭� ��堭���","D50-D89"},;
    {36,"3.1","� ⮬ �᫥: ������, �易��� � ��⠭���, ��������᪨� ������, �������᪨� � ��㣨� ������","D50-D64"},;
    {37,"4","������� �����ਭ��� ��⥬�, ����ன�⢠ ��⠭�� � ����襭�� ������ �����","E00-E90"},;
    {38,"4.1","� ⮬ �᫥: ���� ������","E10-E14"},;
    {39,"4.2","���७��","E66"},;
    {40,"4.3","����襭�� ������ ������⥨��� � ��㣨� ���������","E78"},;
    {41,"5","������� ��ࢭ�� ��⥬�","G00-G99"},;
    {42,"5.1","� ⮬ �᫥: ��室�騥 �ॡࠫ�� �襬��᪨� ������ [�⠪�] � த�⢥��� ᨭ�஬�","G45"},;
    {43,"6","������� ����� � ��� �ਤ��筮�� ������","H00-H59"},;
    {44,"6.1","� ⮬ �᫥: ����᪠� ���ࠪ� � ��㣨� ���ࠪ��","H25,H26"},;
    {45,"6.2","���㪮��","H40"},;
    {46,"6.3","᫥��� � ���������� �७��","H54"},;
    {47,"7","������� ��⥬� �஢����饭��","I00-I99"},;
    {48,"7.1","� ⮬ �᫥: �������, �ࠪ�ਧ��騥�� ����襭�� �஢�� ���������","I10-I15"},;
    {49,"7.2","�襬��᪠� ������� ���","I20-I25"},;
    {50,"7.2.1","� ⮬ �᫥: �⥭���न� (��㤭�� ����)","I20"},;
    {51,"7.2.2","� ⮬ �᫥ ���⠡��쭠� �⥭���न�","I20.0"},;
    {52,"7.2.3","�஭��᪠� �襬��᪠� ������� ���","I25"},;
    {53,"7.2.4","� ⮬ �᫥: ��७�ᥭ�� � ��諮� ����� �����ठ","I25.2"},;
    {54,"7.3","��㣨� ������� ���","I30-I52"},;
    {55,"7.4","�ॡ஢������ �������","I60-I69"},;
    {56,"7.4.1","� ⮬ �᫥: ���㯮ઠ � �⥭�� ���ॡࠫ��� ���਩, �� �ਢ���騥 � ������ �����, � ���㯮ઠ � �⥭�� �ॡࠫ��� ���਩, �� �ਢ���騥 � ������ �����","I65,I66"},;
    {57,"7.4.2","��㣨� �ॡ஢������ �������","I67"},;
    {58,"7.4.3","��᫥��⢨� �㡠�孮����쭮�� �஢�����ﭨ�, ��᫥��⢨� ������९���� �஢�����ﭨ�, ��᫥��⢨� ��㣮�� ���ࠢ����᪮�� ������९���� �஢�����ﭨ�, ��᫥��⢨� ����� �����, ��᫥��⢨� ������, �� ��筥��� ��� �஢�����ﭨ� ��� ����� �����","I69.0-I69.4"},;
    {59,"7.4.4","����ਧ�� ���譮� �����","I71.3-I71.4"},;
    {60,"8","������� �࣠��� ��堭��","J00-J98"},;
    {61,"8.1","� ⮬ �᫥: ����᭠� ���������, ���������, �맢����� Streptococcus pneumonia, ���������, �맢����� Haemophilus influenza, ����ਠ�쭠� ���������, ���������, �맢����� ��㣨�� ��䥪樮��묨 ����㤨⥫ﬨ, ��������� �� ��������, �������஢����� � ��㣨� ��ਪ��, ��������� ��� ��筥��� ����㤨⥫�","J12-J18"},;
    {62,"8.2","�஭��, �� ��筥��� ��� ����� � �஭��᪨�, ���⮩ � ᫨����-������ �஭��᪨� �஭��, �஭��᪨� �஭�� ����筥���, ��䨧���","J40-J43"},;
    {63,"8.3","��㣠� �஭��᪠� ������⨢��� ����筠� �������, ��⬠, ��⬠��᪨� �����, �஭������᪠� �������","J44-J47"},;
    {64,"9","������� �࣠��� ��饢�७��","K00-K93"},;
    {65,"9.1","� ⮬ �᫥: 梨� ���㤪�, 梨� �������⨯���⭮� ��誨","K25,K26"},;
    {66,"9.2","������ � �㮤����","K29"},;
    {67,"9.3","����䥪樮��� ����� � �����","K50-K52"},;
    {68,"9.4","��㣨� ������� ���筨��","K55-K63"},;
    {69,"10","������� ��祯������ ��⥬�","N00-N99"},;
    {70,"10.1","� ⮬ �᫥: ����௫���� �।��⥫쭮� ������, ��ᯠ��⥫�� ������� �।��⥫쭮� ������, ��㣨� ������� �।��⥫쭮� ������","N40-N42"},;
    {71,"10.2","���ப���⢥���� ��ᯫ���� ����筮� ������","N60"},;
    {72,"10.3","��ᯠ��⥫�� ������� ���᪨� ⠧���� �࣠���","N70-N77"},;
    {73,"11","��稥 �����������",""};
   }
  len12 := len(arr_12)
  diag12 := array(len12)
  dbcreate(fr_data+"2",{{"name","C",350,0},;
                        {"diagnoz","C",50,0},;
                        {"ns","N",2,0},;
                        {"stroke","C",8,0},;
                        {"vz","C",10,0},;
                        {"v1","C",10,0},;
                        {"vd","C",10,0},;
                        {"vp","C",10,0}})
  use (fr_data+"2") new alias FRD2
  for n := 1 to len12
    append blank
    frd2->name := iif("."$arr_12[n,2],"","<b>")+arr_12[n,3]+iif("."$arr_12[n,2],"","</b>")
    frd2->ns := n
    frd2->stroke := arr_12[n,2]
    if len(arr_12[n]) < 5
      frd2->diagnoz := arr_12[n,4]
    endif
    s2 := arr_12[n,4]
    if len(arr_12[n]) > 4
      frd2->vp := "-"
    endif
    diag12[n] := {}
    for i := 1 to numtoken(s2,",")
      s3 := token(s2,",",i)
      if "-" $ s3
        d1 := token(s3,"-",1)
        d2 := token(s3,"-",2)
      else
        d1 := d2 := s3
      endif
      aadd(diag12[n], {diag_to_num(d1,1),diag_to_num(d2,2)} )
    next
  next
  for i := 1 to 5
    pole_diag := "mdiag"+lstr(i)
    pole_d_diag := "mddiag"+lstr(i)
    pole_1pervich := "m1pervich"+lstr(i)
    pole_1stadia := "m1stadia"+lstr(i)
    pole_1dispans := "m1dispans"+lstr(i)
    pole_d_dispans := "mddispans"+lstr(i)
    if !empty(&pole_diag) .and. !(left(&pole_diag,1) == "Z")
      au := {}
      d := diag_to_num(&pole_diag,1)
      for n := 1 to len12
        r := diag12[n]
        for j := 1 to len(r)
          fl := between(d,r[j,1],r[j,2])
          if fl .and. len(arr_12[n]) > 4 // ���� �஢���� �⠤��
            if human->k_data < d_01_04_2015
              fl := (&pole_1stadia == 0) // ࠭���
            else
              fl := (&pole_1stadia < 3) // 1 � 2 �⠤��
            endif
          endif
          if fl
            aadd(au,n)
          endif
        next
      next
      if empty(au) // ����ᨬ � ��稥 �����������
        aadd(au,len12)
      endif
      for j := 1 to len(au)
        goto (au[j])
        if &pole_1pervich == 1 // �����
          frd2->vz := frd2->v1 := frt->k_data // ��� ��� �࠯���
          if &pole_1dispans == 1
            frd2->vd := frt->k_data
          endif
        elseif &pole_1pervich == 0 // ࠭�� ������
          frd2->vz := full_date(&pole_d_diag)
          if &pole_1dispans == 1
            frd2->vd := iif(empty(&pole_d_dispans), frd2->vz, full_date(&pole_d_dispans))
          endif
        else // �।���⥫�� �������
          if empty(frd2->vp)
            frd2->vp := frt->k_data
          endif
        endif
      next
    endif
  next
  close databases
  call_fr("mo_131_u") // �����
  close databases
  eval(blk_open)
  goto (rec)
  rest_box(buf)
endif
return ret

***** 01.07.17
Static Function f_131_u_da_net(k,sb1,sb2)
if k > 1 ; k := 1 ; endif // �᫨ ����� "��" ��⮢� �⢥�
return f3_inf_DDS_karta({{"�� - 1",1},{"��� - 2",0}},k,";  ",sb1,sb2,.f.)

***** 03.09.20 �ਫ������ � �ਪ��� ���� "������" �� 12.05.2017�. �1615
Function f21_inf_DVN(par) // ᢮�
Local arr_m, buf := save_maxrow(), s, as := {}, as1[14], i, j, k, n, ar, at, ii, g1, sh := 65, fl, mdvozrast, adbf
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
              .and. (arr_m := year_month(,,,5)) != NIL .and. f0_inf_DVN(arr_m,par > 1,par == 3,.t.)
  Private arr_usl_bio := {{;
    "A11.20.010",;//          ������ ����筮� ������ ��᪮����
    "A11.20.010.001",;//      ������ ������ࠧ������ ����筮� ������ ��楫쭠� �㭪樮���� ��� ����஫�� ७⣥������᪮�� ��᫥�������
    "A11.20.010.002",;//      ������ ������ࠧ������ ����筮� ������ �ᯨ�樮���� ����㬭�� ��� ����஫�� ७⣥������᪮�� ��᫥�������
    "A11.20.010.004" ;//      ������ �����쯨�㥬�� ������ࠧ������ ����筮� ������ �ᯨ�樮���� ����㬭�� ��� ����஫�� ���ࠧ�㪮���� ��᫥�������
   },;
   {;
    "A11.18.001",;//          ������ �����筮� ��誨 ����᪮���᪠�
    "A11.18.002",;//          ������ �����筮� ��誨 ����⨢���
    "A11.19.001",;//          ������ ᨣ�������� ��誨 � ������� ���������᪮���᪨� �孮�����
    "A11.19.002",;//          ������ ��אַ� ��誨 � ������� ���������᪮���᪨� �孮�����
    "A11.19.003",;//          ������ ���� � ��ਠ���쭮� ������
    "A11.19.009" ;//          ������ ⮫�⮩ ��誨 �� �����᪮���
   },;
   {;
    "A11.20.011",;//          ������ 襩�� ��⪨
    "A11.20.011.001",;//      ������ 襩�� ��⪨ ࠤ����������
    "A11.20.011.002",;//      ������ 襩�� ��⪨ ࠤ���������� ����ᮢ�����
    "A11.20.011.003" ;//      ������ 襩�� ��⪨ �������
   },;
   {;
    "A11.01.001",;//          ������ ����
    "A11.07.001",;//          ������ ᫨���⮩ ������ ��
    "A11.07.002",;//          ������ �몠
    "A11.07.003",;//          ������ ���������, ���� � ���������
    "A11.07.004",;//          ������ ���⪨, ���� � ��窠
    "A11.07.005",;//          ������ ᫨���⮩ �।����� ������ ��
    "A11.07.006",;//          ������ ����
    "A11.07.007",;//          ������ ⪠��� ���
    "A11.07.016",;//          ������ ᫨���⮩ �⮣��⪨
    "A11.07.016.001",;//      ������ ᫨���⮩ �⮣��⪨ ��� ����஫�� ����᪮���᪮�� ��᫥�������
    "A11.07.020",;//          ������ ��� ������
    "A11.07.020.001",;//      ������ ������譮� ��� ������
    "A11.08.001",;//          ������ ᫨���⮩ �����窨 ���⠭�
    "A11.08.001.001",;//      ������ ⪠��� ���⠭� ��� ����஫�� ��ਭ��᪮���᪮�� ��᫥�������
    "A11.08.002",;//          ������ ᫨���⮩ �����窨 ������ ���
    "A11.08.003",;//          ������ ᫨���⮩ �����窨 ��ᮣ��⪨
    "A11.08.003.001",;//      ������ ᫨���⮩ �����窨 ��ᮣ��⪨ ��� ����஫�� ����᪮���᪮�� ��᫥�������
    "A11.08.015",;//          ������ ᫨���⮩ �����窨 �������ᮢ�� �����
    "A11.08.016",;//          ������ ⪠��� ���襢������ ��ଠ��
    "A11.08.016.001",;//      ������ ⪠��� ���襢������ ��ଠ�� ��� ����஫�� ����᪮���᪮�� ��᫥�������
    "A11.26.001" ;//          ������ ������ࠧ������ ���, ����⨢� ��� ண�����
   };
  }
  Private arr_21[50], arr_316 := {}, arr_ne := {}
  afill(arr_21,0)
  mywait("���� ����⨪�")
  adbf := {{"name","C",80,0},;
           {"NN","N",2,0},;
           {"g1","N",6,0},;
           {"g2","N",6,0},;
           {"g3","N",6,0},;
           {"g4","N",6,0},;
           {"g5","N",6,0},;
           {"g6","N",6,0},;
           {"g7","N",6,0},;
           {"g8","N",6,0},;
           {"g9","N",6,0}}
  dbcreate(cur_dir+"tmp1",adbf)
  use (cur_dir+"tmp1") new
  index on str(nn,2) to (cur_dir+"tmp1")
  append blank
  tmp1->nn := 2 ;  tmp1->name := "�ᬮ�७� �ᥣ� (�����訫� I �⠯)"
  append blank
  tmp1->nn := 3 ;  tmp1->name := "�� ��.2 ��᫥ 18:00"
  append blank
  tmp1->nn := 4 ;  tmp1->name := "�� ��.2 � �㡡���"
  append blank
  tmp1->nn := 5 ;  tmp1->name := "�� ��.2 ��襤訥 �� ��᫥������� � ���� ����"
  append blank
  tmp1->nn := 6 ;  tmp1->name := "�� ��.2 �ᥣ� ᥫ�᪨� ��⥫��"
  append blank
  tmp1->nn := 7 ;  tmp1->name := "�� ��.6 ᥫ�᪨� ��⥫�� ��᫥ 18:00"
  append blank
  tmp1->nn := 8 ;  tmp1->name := "�� ��.6 ᥫ�᪨� ��⥫�� � �㡡���"
  append blank
  tmp1->nn := 9 ;  tmp1->name := "������� � ����� ����.�����.����������ﬨ"
  append blank
  tmp1->nn := 10 ; tmp1->name := "�ᥣ� ����� ����� �����.�����������"
  append blank
  tmp1->nn := 11 ; tmp1->name := "�� ��.9 ������� ������� ���.�஢����饭��"
  append blank
  tmp1->nn := 12 ; tmp1->name := "�� ��.9 ������� ���"
  append blank
  tmp1->nn := 13 ; tmp1->name := "        �� ��.12 � �.�. � 1 � 2 �⠤���"
  append blank
  tmp1->nn := 14 ; tmp1->name := "�� ��.9 ������� ���� ������"
  append blank
  tmp1->nn := 15 ; tmp1->name := "        � �.�. ���� ������ I ⨯�"
  append blank
  tmp1->nn := 16 ; tmp1->name := "�� ��.9 ������� ���㪮��"
  append blank
  tmp1->nn := 17 ; tmp1->name := "�� ��.9 ������� �஭.������� �࣠��� ��堭��"
  append blank
  tmp1->nn := 18 ; tmp1->name := "�� ��.9 ������� ������� �࣠��� ��饢�७��"
  append blank
  tmp1->nn := 19 ; tmp1->name := "�� ��.9 ������� ����� �� ���.�������"
  append blank
  tmp1->nn := 20 ; tmp1->name := "�� ��.9 ������� �뫮 ���� ��祭��"
  append blank
  tmp1->nn := 21 ; tmp1->name := "   �� ��.19 �� ��� ᥫ�᪨� ��⥫��"
  dbcreate(cur_dir+"tmp11",adbf)
  use (cur_dir+"tmp11") new
  index on str(nn,2) to (cur_dir+"tmp11")
  append blank
  tmp11->nn :=  1 ; tmp11->name := "����� ����� �� ��ᯠ���� ����"
  append blank
  tmp11->nn :=  2 ; tmp11->name := "������� ᯥ樠����஢����� ���.������"
  append blank
  tmp11->nn :=  3 ; tmp11->name := "������� ॠ�����樮��� ��ய����"
  append blank
  tmp11->nn :=  4 ; tmp11->name := "�⪠������ �� �஢������ ���-�� � 楫��"
  append blank
  tmp11->nn :=  5 ; tmp11->name := "����� ��樥�⮢ � ������⮫�����"
  append blank
  tmp11->nn :=  6 ; tmp11->name := "  � �.�. 1 �⠤��"
  append blank
  tmp11->nn :=  7 ; tmp11->name := "         2 �⠤��"
  append blank
  tmp11->nn :=  8 ; tmp11->name := "         3 �⠤��"
  append blank
  tmp11->nn :=  9 ; tmp11->name := "         4 �⠤��"
  append blank
  tmp11->nn := 10 ; tmp11->name := "���ࠢ���� �� �������.㣫㡫.��䨫���.����-��"
  append blank
  tmp11->nn := 11 ; tmp11->name := "���-�� ��襤�� �������.㣫㡫.��䨫���.����-��"
  append blank
  tmp11->nn := 12 ; tmp11->name := "��業� �墠� �������.㣫㡫.��䨫���.����-���"
  append blank
  tmp11->nn := 13 ; tmp11->name := "���ࠢ���� �ࠦ��� �� ��㯯���� ��䨫���.����-��"
  append blank
  tmp11->nn := 14 ; tmp11->name := "���-�� ��襤�� ��㯯���� ��䨫���.����-��"
  append blank
  tmp11->nn := 15 ; tmp11->name := "��業� �墠� ��㯯��� ��䨫���.����-���"
  //
  dbcreate(cur_dir+"tmp12",adbf)
  use (cur_dir+"tmp12") new
  index on str(nn,2) to (cur_dir+"tmp12")
  append blank
  tmp12->nn :=  1 ; tmp12->name := "���-�� �������䨩 � ࠬ��� ��ᯠ��ਧ�樨"
  append blank
  tmp12->nn :=  2 ; tmp12->name := "  ���-�� �����客�����"
  append blank
  tmp12->nn :=  3 ; tmp12->name := "    ����� ��⮫���� � ����筮� ������"
  append blank
  tmp12->nn :=  4 ; tmp12->name := "      ���ࠢ���� �� 2 �⠯ ��ᯠ��ਧ�樨"
  append blank
  tmp12->nn :=  5 ; tmp12->name := "      �믮����� ������ ����筮� ������"
  append blank                        // C50,D05
  tmp12->nn :=  6 ; tmp12->name := "    ����� ��� ����筮� ������, �ᥣ�"
  append blank
  tmp12->nn :=  7 ; tmp12->name := "      in situ"
  append blank
  tmp12->nn :=  8 ; tmp12->name := "      �� ��� 1 �⠤��"
  append blank
  tmp12->nn :=  9 ; tmp12->name := "      �� ��� 2 �⠤��"
  append blank
  tmp12->nn := 10 ; tmp12->name := "      �� ��� 3 �⠤��"
  append blank
  tmp12->nn := 11 ; tmp12->name := "      �� ��� 4 �⠤��"
  append blank
  tmp12->nn := 12 ; tmp12->name := "���-�� �������� ���� �� ������ �஢�"
  append blank
  tmp12->nn := 13 ; tmp12->name := "  ���-�� �����客�����"
  append blank
  tmp12->nn := 14 ; tmp12->name := "    ���� ������⥫�� ��� �� ������ �஢� � ����"
  append blank
  tmp12->nn := 15 ; tmp12->name := "      ���ࠢ���� �� 2 �⠯ ��ᯠ��ਧ�樨"
  append blank
  tmp12->nn := 16 ; tmp12->name := "        �믮����� ������᪮���"
  append blank
  tmp12->nn := 17 ; tmp12->name := "        �믮����� ४�஬���᪮���"
  append blank
  tmp12->nn := 18 ; tmp12->name := "        �믮����� ������ �� ������᪮��� ��� ४�஬���᪮���"
  append blank                     // C18-C21,D01.0-D01.3
  tmp12->nn := 19 ; tmp12->name := "    ����� ��� ⮫�⮩/��אַ� ��誨, �ᥣ�"
  append blank
  tmp12->nn := 20 ; tmp12->name := "      in situ"
  append blank
  tmp12->nn := 21 ; tmp12->name := "      �� ��� 1 �⠤��"
  append blank
  tmp12->nn := 22 ; tmp12->name := "      �� ��� 2 �⠤��"
  append blank
  tmp12->nn := 23 ; tmp12->name := "      �� ��� 3 �⠤��"
  append blank
  tmp12->nn := 24 ; tmp12->name := "      �� ��� 4 �⠤��"
  append blank
  tmp12->nn := 25 ; tmp12->name := "���-�� ���-��⮢  � ࠬ��� ��ᯠ��ਧ�樨"
  append blank
  tmp12->nn := 26 ; tmp12->name := "  ���-�� �����客�����"
  append blank
  tmp12->nn := 27 ; tmp12->name := "    ��﫥�� ��⮫���� 襩�� ��⪨"
  append blank
  tmp12->nn := 28 ; tmp12->name := "      ���ࠢ���� �� 2 �⠯ ��ᯠ��ਧ�樨"
  append blank
  tmp12->nn := 29 ; tmp12->name := "      �믮����� ������ 襩�� ��⪨"
  append blank                    // �53,D06
  tmp12->nn := 30 ; tmp12->name := "    ����� ��� 襩�� ��⪨, �ᥣ�"
  append blank
  tmp12->nn := 31 ; tmp12->name := "      in situ"
  append blank
  tmp12->nn := 32 ; tmp12->name := "      �� ��� 1 �⠤��"
  append blank
  tmp12->nn := 33 ; tmp12->name := "      �� ��� 2 �⠤��"
  append blank
  tmp12->nn := 34 ; tmp12->name := "      �� ��� 3 �⠤��"
  append blank
  tmp12->nn := 35 ; tmp12->name := "      �� ��� 4 �⠤��"
  append blank
  tmp12->nn := 36 ; tmp12->name := "���-�� �����-��, � ������ ����� ��⮫���� ���� � ������� ᫨������"
  append blank
  tmp12->nn := 37 ; tmp12->name := "  ���ࠢ���� �� ������ ���� � ������� ᫨������"
  append blank                      // C00,C14.8,C43,C44,D00.0,D03,D04
  tmp12->nn := 38 ; tmp12->name := "  ����� ��� ���� � ������� ᫨������, �ᥣ�"
  append blank
  tmp12->nn := 39 ; tmp12->name := "    in situ"
  append blank
  tmp12->nn := 40 ; tmp12->name := "    �� ��� 1 �⠤��"
  append blank
  tmp12->nn := 41 ; tmp12->name := "    �� ��� 2 �⠤��"
  append blank
  tmp12->nn := 42 ; tmp12->name := "    �� ��� 3 �⠤��"
  append blank
  tmp12->nn := 43 ; tmp12->name := "    �� ��� 4 �⠤��"
  //
  dbcreate(cur_dir+"tmp2",{{"kod_k","N",7,0},;
                           {"rslt1","N",3,0},;
                           {"rslt2","N",3,0}})
  use (cur_dir+"tmp2") new
  index on str(kod_k,7) to (cur_dir+"tmp2")
  R_Use(dir_server+"mo_rpdsh",,"RPDSH")
  index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to kod_k into KART_
  R_Use(dir_server+"schet_",,"SCHET_")
  use (cur_dir+"tmp") index (cur_dir+"tmp") new
  f_error_DVN(1)
  ii := 0
  go top
  do while !eof()
    @ maxrow(),0 say str(++ii/tmp->(lastrec())*100,6,2)+"%" color cColorWait
    if !empty(tmp->kod4h) // ��ᯠ��ਧ��� 1 ࠧ � 2 ����
      human->(dbGoto(tmp->kod4h))
      mdvozrast := year(human->n_data) - year(human->date_r)
      g1 := ret_gruppa_DVN(human_->RSLT_NEW)
      /*if between(g1,1,4)
        arr_21[31] ++
        if human->pol == "�"
          arr_21[32] ++
        else
          arr_21[33] ++
        endif
        if human->pol == "�" .and. human->k_data < d_01_05_2019 .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
          arr_21[34] ++
        else
          arr_21[35] ++
        endif
      endif*/
    elseif emptyall(tmp->kod1h,tmp->kod2h) // ��䨫��⨪�
      human->(dbGoto(tmp->kod3h))
      mdvozrast := year(human->n_data) - year(human->date_r)
      g1 := 0
      if between(human_->RSLT_NEW,343,345)
        g1 := human_->RSLT_NEW - 342
      elseif between(human_->RSLT_NEW,373,374)
        g1 := human_->RSLT_NEW - 370
      endif
      if between(g1,1,4)
        arr_21[14] ++
        if f_is_selo(kart_->gorod_selo,kart_->okatog)
          arr_21[15] ++
        endif
        if g1 == 3
          arr_21[41] ++
        elseif g1 == 4
          arr_21[42] ++
        endif
        if g1 == 4 ; g1 := 3 ; endif // �⮣� III ��㯯�
        arr_21[15+g1] ++ // ���ᬮ��� �� ��㯯�� ���஢��
        if f_starshe_trudosp(human->POL,human->DATE_R,human->n_data)
          arr_21[40] ++
        endif
        f2_f21_inf_DVN(2)
      endif
    else
      f1_f21_inf_DVN()
    endif
    f_error_DVN(2)
    select TMP
    skip
  enddo
  close databases
  dbcreate(cur_dir+"tmp3",{{"et2","N",1,0},;
                   {"gr1","N",1,0},;
                   {"gr2","N",1,0},;
                   {"kol1","N",6,0},;
                   {"kol2","N",6,0}})
  use (cur_dir+"tmp3") new
  index on str(et2,1)+str(gr1,1)+str(gr2,1) to (cur_dir+"tmp3")
  R_Use(dir_server+"kartotek",,"KART")
  use (cur_dir+"tmp2") new
  go top
  do while !eof()
    fl := .f.
    g1 := ret_gruppa_DVN(tmp2->rslt1,@fl)
    if between(g1,0,4)
      k := iif(fl,1,0)
      g2 := ret_gruppa_DVN(tmp2->rslt2)
      if !between(g2,1,4)
        g2 := 0
      endif
      select TMP3
      find (str(k,1)+str(g1,1)+str(g2,1))
      if !found()
        append blank
        tmp3->et2 := k
        tmp3->gr1 := g1
        tmp3->gr2 := g2
      endif
      tmp3->kol1 ++
      if g2 > 0
        tmp3->kol2 ++
      endif
    endif
    if tmp2->rslt1 == 316 .and. empty(tmp2->rslt2)
      kart->(dbGoto(tmp2->kod_k))
      aadd(arr_316, alltrim(kart->fio)+" �.�."+full_date(kart->date_r))
    endif
    if tmp2->rslt1 == 0 .and. !empty(tmp2->rslt2)
      kart->(dbGoto(tmp2->kod_k))
      aadd(arr_ne, alltrim(kart->fio)+" �.�."+full_date(kart->date_r))
    endif
    select TMP2
    skip
  enddo
  close databases
  //
  at := {glob_mo[_MO_SHORT_NAME],"[ "+charrem("~",mas1pmt[par])+" �� ���⮬ �⪠��� � ����� ]",arr_m[4]}
  print_shablon("svod_dvn",{arr_21,at,ar},"tmp1.txt",.f.)
  fp := fcreate("tmp2.txt") ; n_list := 1 ; tek_stroke := 0
  fl := f_error_DVN(3,60,80)
  fclose(fp)
  if fl
    strfile("FF","tmp1.txt",.t.)
    feval("tmp2.txt",{|s| strfile(s+eos,"tmp1.txt",.t.) })
  endif
  viewtext("tmp1.txt",,,,,,,3)
endif
close databases
rest_box(buf)
return NIL

*



***** 05.05.22
Function inf_YDVN()

Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}, is_all
Local sh, HH := 53,  n_file := "gor_YDVN"+stxt, reg_print, arr_itog[19]
local t_rec, t_poisk, t_rezult 
local arr_title := {;
"��������������������������������������������������������������������������������������������������������������������������������������",;
"��諨� � ⮬ �   �    �   �   ���諨 ���      �      �      �      �      ����ࠢ-���諨�      �      �      �      �      ������",;
"1 �⠯� �᫥ ����୥���㡡���  ����   �   I  �  II  �  III � IIIa � IIIb ����� ���2 �⠯�   I  �  II  �  III � IIIa � IIIb �  ����",;
"      � ᥫ�  � �६�  �       �  ����   ���㯯����㯯����㯯����㯯����㯯�� 2 �⠯�      ���㯯����㯯����㯯����㯯����㯯�� � ���",;
"��������������������������������������������������������������������������������������������������������������������������������������",;
"   2  �  2.1  �   3    �   4   �    5    �   6  �   7  �   8  �   9  �  10  �   11  �  12  �  13  �  14  �  15  �  16  �  17  �   18  ",;
"��������������������������������������������������������������������������������������������������������������������������������������"}
Local title_zagol := {;
"��� �ࠦ����",;
"� ����ࡨ��� 䮭�� (����稥 ���� � ����� �஭��᪨� ����䥪樮���� ����������� - 1 ��㯯�",;
"�� ����� 祬 � ����� ᮯ������騬 �஭��᪨� ����䥪樮��� ������������ - 2 ��㯯�",;
"�⮣�"}
local mas_n_otchet[15]
Private  pole_pervich, pole_1pervich, pole_dispans, pole_1dispans

afill(mas_n_otchet,0)
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")

for i := 1 to 5
  sk := lstr(i)
 // pole_pervich := "mpervich"+sk
  pole_1pervich := "m1pervich"+sk
 // pole_dispans := "mdispans"+sk
  pole_1dispans := "m1dispans"+sk
 // Private &pole_pervich := space(7)
  Private &pole_1pervich := 0
//  Private &pole_dispans := space(10)
  Private &pole_1dispans := 0
next

if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
                                   .and. (arr_m := year_month(,,,5)) != NIL
  mywait()
  dbcreate(cur_dir+"tmp",{{"gruppa_1","N",1,0},;// 1-��㯯� 2- ��㯯� 3 - ��� ��㯯�
                        {"etap_1","N",1,0},;  // �⠯ 1-� 2-�
                        {"sub_day","N",1,0},; // �믮������ � �㡡��� 0-��� 1-��
                        {"one_day","N",1,0},; // �믮������ � 1 ���� 0-��� 1-��
                        {"gruppa","N",3,0},;  // ��㯯� ���஢�� 1,2.3a,3b
                        {"napr2","N",1,0},;   // ���ࠢ��� �� 2-� �⠯ 0-��� 1-��
                        {"selo","N",1,0},;    // ���� 0-��� 1-��
                        {"d_one","N",1,0},;   // ����� ���� �� �-��� 0-��� 1-��
                        {"kod_k","N",7,0}})   
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  use (cur_dir+"tmp") new
  //
  select HUMAN
  dbseek(dtos(arr_m[5]),.t.)
  do while human->k_data <= arr_m[6] .and. !eof()
    if between(human->ishod,401,402)
      // read_arr_DVN_COVID(human->kod)
      //is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // �ਧ��� ᥫ�
      select KART_
      goto (HUMAN->kod_k)
      select KART
      goto (HUMAN->kod_k)
      select HUMAN
      is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // �ਧ��� ᥫ�
      select TMP
      append blank
      tmp->kod_k := HUMAN->kod_k
      if is_selo
        tmp->selo := 1
      endif
      if dow(human->n_data) == 7
        tmp->sub_day := 1
      else
        tmp->sub_day := 0
      endif
      if human->k_data == human->n_data
        tmp->one_day := 1
      else
        tmp->one_day := 0
      endif
      if human->ishod == 401
        tmp->etap_1 := 1
      else
        tmp->etap_1 := 2
      endif
      // �롨ࠥ� ��㣨
//      larr := array(2, len(uslugiEtap_DVN_COVID(metap)))
//      arr_usl := {} // array(len(uslugiEtap_DVN_COVID(metap)))
      //
      arr := read_arr_DISPANS(human->kod) 
//      my_debug(,print_array(arr))
      //
      for i := 1 to len(arr)
        if valtype(arr[i]) == "A" .and. valtype(arr[i,1]) == "C"
          do case
            case arr[i,1] == "5" .and. valtype(arr[i,2]) == "N"
              tmp->gruppa_1 := arr[i,2]
            case eq_any(arr[i,1],"11","12","13","14")
              sk := right(arr[i,1],1)
              pole_1pervich := "m1pervich"+sk
              pole_1dispans := "m1dispans"+sk
              if valtype(arr[i,2,4]) == "N"
                &pole_1dispans := arr[i,2,4]
              endif
              if valtype(arr[i,2,2]) == "N"
                &pole_1pervich := arr[i,2,2]
              endif
              if &pole_1dispans == 1 .and. &pole_1pervich == 1
                tmp->d_one := 1
              endif
            case arr[i,1] == "40"
              tmp_mas := arr[i,2] 
              fl_t := .F.
              fl_t1 := .F.
              for jj := 1 to len(tmp_mas)
                 if alltrim(tmp_mas[jj])     == "70.8.2"     // 70- �஢������ ��� � 6 ����⭮� 室졮�
                  fl_t := .T. 
                   mas_n_otchet[3] ++
                 elseif alltrim(tmp_mas[jj]) == "A12.09.001" // 71- "�஢������ ᯨ஬��ਨ ��� ᯨண�䨨"
                  fl_t := .T.
                   mas_n_otchet[4] ++
                 elseif alltrim(tmp_mas[jj]) == "A12.09.005" //"69- ���ᮮ�ᨬ����"
                  fl_t := .T.
                   mas_n_otchet[2] ++
                 elseif alltrim(tmp_mas[jj]) == "A06.09.007" // 72- ���⣥������ ������
                  fl_t := .T.
                   mas_n_otchet[5] ++
                 elseif alltrim(tmp_mas[jj]) == "B03.016.003"// 73- "��騩 (������᪨�) ������ �஢� ࠧ������"    
                  fl_t := .T.
                   mas_n_otchet[6] ++
                 elseif alltrim(tmp_mas[jj]) == "B03.016.004"// 74- ������ �஢� ���娬��᪨� ����࠯����᪨�
                  fl_t := .T.
                   mas_n_otchet[7] ++
                 elseif alltrim(tmp_mas[jj]) == "70.8.3"     // 75 "��।������ ���業��樨 �-����� � �஢�" 
                  fl_t := .T.
                   mas_n_otchet[8] ++
                 elseif alltrim(tmp_mas[jj]) == "70.8.52"    // 2 - 78 �㯫��᭮� ᪠���-�� ��� ������ ����筮�⥩
                  fl_t1 := .T.
                  mas_n_otchet[10] ++
                 elseif alltrim(tmp_mas[jj]) == "70.8.51"    // 2 - 79 �஢������ �� ������ 
                  fl_t1 := .T.//mas_n_otchet[9] ++
                   mas_n_otchet[11] ++
                 elseif alltrim(tmp_mas[jj]) == "70.8.50"    // 2 - 80 �஢������ �宪�न���䨨
                  fl_t1 := .T.
                  mas_n_otchet[12] ++
                 endif 
              next    
              if fl_t
                mas_n_otchet[1] ++
              endif 
              if fl_t1
                mas_n_otchet[9] ++
              endif 
              case arr[i,1] == "56"  //ॠ�������
                if valtype(arr[i,2]) == "N"
                  //mas_n_otchet[14] ++
                elseif valtype(arr[i,2]) == "A"
                  if arr[i,2][2] > 0
                    mas_n_otchet[14] ++
                  endif  
                endif
            endcase
        endif
      next
//
      if human_->RSLT_NEW == 317
        tmp->gruppa := 1
        tmp->napr2  := 0
      elseif human_->RSLT_NEW == 318
        tmp->gruppa := 2
        tmp->napr2  := 0
      elseif human_->RSLT_NEW == 355
        tmp->gruppa := 3
        tmp->napr2  := 0
      elseif human_->RSLT_NEW == 356
        tmp->gruppa := 4
        tmp->napr2  := 0
      elseif human_->RSLT_NEW == 352
        tmp->gruppa := 1
        tmp->napr2  := 1
      elseif human_->RSLT_NEW == 353
        tmp->gruppa := 2
        tmp->napr2  := 1
      elseif human_->RSLT_NEW == 357
        tmp->gruppa := 3
        tmp->napr2  := 1
      else //if human_->RSLT_NEW == 358
        tmp->gruppa := 4
        tmp->napr2  := 1
      endif
    endif
    select HUMAN
    skip
  enddo
  select TMP
  index on str(kod_k,7)+str(etap_1,1)  to tmp_kk
  //
  go top
  do while !eof()
    if etap_1 == 2
      t_rec := tmp->(recno())
      t_poisk := str(tmp->kod_k,7)+str(1,1)
      t_rezult := 0 // �� 㬮�砭�� ����
      find(t_poisk)
      if found()
        t_rezult := tmp->gruppa_1 
      endif
      goto t_rec
      G_RLock(forever)
      tmp->gruppa_1  := t_rezult 
      unlock
    endif
    select TMP
    skip
  enddo
  // ᮧ���� ����
  reg_print := f_reg_print(arr_title,@sh,2)
   fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  //
  for II := 0 to 3
    afill(arr_itog,0)
    select TMP
    go top
    do while !eof()
      if iif(II==3,.T.,tmp->Gruppa_1 == II)
        if tmp->etap_1 == 1
          arr_itog[2] ++
          if tmp->sub_day == 1
            arr_itog[4] ++
          endif
          if tmp->one_day == 1
            arr_itog[5] ++
          endif
          if tmp->gruppa == 1
            arr_itog[6] ++
          endif
          if tmp->gruppa == 2
            arr_itog[7] ++
          endif
          if tmp->gruppa == 3
            arr_itog[8] ++
            arr_itog[9] ++
          endif
          if tmp->gruppa == 4
            arr_itog[8] ++
            arr_itog[10] ++
          endif
          if tmp->napr2 == 1
            arr_itog[11] ++
          endif
        else
          arr_itog[12] ++
          if tmp->gruppa == 1
            arr_itog[13] ++
          endif
          if tmp->gruppa == 2
            arr_itog[14] ++
          endif
          if tmp->gruppa == 3
            arr_itog[15] ++
            arr_itog[16] ++
          endif
          if tmp->gruppa == 4
            arr_itog[15] ++
            arr_itog[17] ++
          endif
        endif
        if tmp->d_one == 1
            arr_itog[18] ++
        endif
        if tmp->selo == 1
            arr_itog[19]++
        endif
      endif
      skip
    enddo
  // �뢮���
    add_string(center("���, ��७��訥 COVID-19",sh))
    if II==3
      add_string(center("�����",sh))
    else
      add_string(center(title_zagol[II+1],sh))
    endif
    add_string(center(arr_m[4],sh))
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    add_string(padl(lstr(arr_itog[2]),6)+;
               padl(lstr(arr_itog[19]),8)+;
               padl("",8)+;
               padl(lstr(arr_itog[4]),9)+;
               padl(lstr(arr_itog[5]),10)+;
               padl(lstr(arr_itog[6]),7)+;
               padl(lstr(arr_itog[7]),7)+;
               padl(lstr(arr_itog[8]),7)+;
               padl(lstr(arr_itog[9]),7)+;
               padl(lstr(arr_itog[10]),7)+;
               padl(lstr(arr_itog[11]),8)+;
               padl(lstr(arr_itog[12]),7)+;
               padl(lstr(arr_itog[13]),7)+;
               padl(lstr(arr_itog[14]),7)+;
               padl(lstr(arr_itog[15]),7)+;
               padl(lstr(arr_itog[16]),7)+;
               padl(lstr(arr_itog[17]),7)+;
               padl(lstr(arr_itog[18]),8))
    add_string("")
    add_string("")
  next
  if verify_FF(HH,.t.,sh)
    //aeval(arr_title, {|x| add_string(x) } )
  endif
//endif
add_string("���� ��� � �⪫�����ﬨ  �� ����, �����묨 � �ࠦ���, ��७��� ����� ��஭�������� ��䥪��" )
add_string("COVID-19 �� १���⠬ I �⠯� 㣫㡫����� ��ᯠ��ਧ�樨 (���� �� ������⢠ �ࠦ���, �����訢��")
add_string(" I �⠯ 㣫㡫����� ��ᯠ��ਧ�樨 � ��襤�� �����⭮� ��᫥�������, %)")  								
add_string("")
add_string("68- �ᥣ� ��� � �⪮����ﬨ I �⠯              = "+ padl(lstr(mas_n_otchet[1]),9)+" 祫.")
add_string("69- �������                                   = "+ padl(lstr(mas_n_otchet[2]),9)+" 祫.")
add_string("70- ���� � 6 ����⭮� 室졮�                   = "+ padl(lstr(mas_n_otchet[3]),9)+" 祫.")
add_string("71- ���஬����                                 = "+ padl(lstr(mas_n_otchet[4]),9)+" 祫.")
add_string("72- ���⣥������ ������                       = "+ padl(lstr(mas_n_otchet[5]),9)+" 祫.")
add_string("73- ��騩 ������ �஢�                          = "+ padl(lstr(mas_n_otchet[6]),9)+" 祫.")
add_string("74- ���娬��᪨� ������ �஢�                  = "+ padl(lstr(mas_n_otchet[7]),9)+" 祫.")
add_string("75- ��।������ ���業��樨 �-����� � �஢�   = "+ padl(lstr(mas_n_otchet[8]),9)+" 祫.")
add_string("")
add_string("���� ��� � �⪫�����ﬨ  �� ����, �����묨 � �ࠦ���, ��७��� ����� ��஭�������� ��䥪�� ")
add_string("COVID-19 �� १���⠬ II �⠯� 㣫㡫����� ��ᯠ��ਧ�樨 (���� �� ������⢠ �ࠦ���, �����訢�� ")
add_string(" II �⠯ 㣫㡫����� ��ᯠ��ਧ�樨 � ��襤�� �����⭮� ��᫥�������, %)")  			
add_string("")
add_string("77- �ᥣ� ��� � �⪮����ﬨ II �⠯             = "+ padl(lstr(mas_n_otchet[9]),9)+" 祫.")
add_string("78- �㯫��᭮� ᪠���-�� ��� ������ ����筮�⥩ = "+ padl(lstr(mas_n_otchet[10]),9)+" 祫.")
add_string("79- �஢������ �� ������                        = "+ padl(lstr(mas_n_otchet[11]),9)+" 祫.")
add_string("80- �஢������ �宪�न���䨨                  = "+ padl(lstr(mas_n_otchet[12]),9)+" 祫.")
add_string("")
add_string("��᫮ �ࠦ���, ������ �� ��ᯠ��୮� ������� � ���ࠢ������ �� ॠ������� ��")
add_string("१���⠬ 㣫㡫����� ��ᯠ��ਧ�樨  (���.�.)")  		
add_string("")
add_string("83- �ᥣ� �������� ��ᯠ��୮�� �������     = "+ padl(lstr(arr_itog[18]),9)+" 祫.")
add_string("85- ���ࠢ��� �� ॠ�������                   = "+ padl(lstr(mas_n_otchet[14]),9)+" 祫.")
  close databases
  fclose(fp)
  Private yes_albom := .t.
  viewtext(n_file,,,,(sh>80),,,reg_print)
endif
rest_box(buf)
close databases
//quit
return NIL


***** 27.04.20
Function f1_f21_inf_DVN()
Local sumr := 0, m1GRUPPA, fl2 := .f., is_selo
select TMP2
append blank
tmp2->kod_k := tmp->kod_k
// ��ᯠ��ਧ��� I �⠯
if empty(tmp->kod1h)
  // ��� 1 �⠯�, �� ���� ��ன
else
  human->(dbGoto(tmp->kod1h))
  mdvozrast := year(human->n_data) - year(human->date_r)
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW,@fl2)
  if between(m1gruppa,0,4)
    tmp2->rslt1 := human_->RSLT_NEW
    if m1gruppa == 0
      fl2 := .t. // ���ࠢ��� �� 2 �⠯
    endif
    Private m1veteran := 0, m1mobilbr := 0
    read_arr_DVN(human->kod,.f.)
    arr_21[3] ++
    if m1veteran == 1
      arr_21[4] ++
    endif
    if m1mobilbr == 1
      arr_21[5] ++
    endif
    if mdvozrast == 65
      arr_21[32] ++
    elseif mdvozrast > 65
      arr_21[33] ++
    endif
    if between(m1gruppa,1,4)
      arr_21[5+m1gruppa] ++
    endif
    if (is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog))
      arr_21[47] ++
    endif
    if f_starshe_trudosp(human->POL,human->DATE_R,human->n_data)
      arr_21[19] ++
      if is_selo
        arr_21[20] ++
      endif
      if between(m1gruppa,1,4)
        arr_21[42+m1gruppa] ++
      endif
    endif
    f2_f21_inf_DVN(1)
    if human->schet > 0
      select SCHET_
      goto (human->schet)
      if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
        arr_21[10] ++
        select RPDSH
        find (str(human->kod,7))
        do while rpdsh->KOD_H == human->kod .and. !eof()
          sumr += rpdsh->S_SL
          skip
        enddo
        if round(human->cena_1,2) == round(sumr,2) // ��������� ����祭
          arr_21[11] ++
        endif
      endif
    endif
  else
    // ��祬�-� ���ࠢ��쭠� ��㯯�
  endif
endif
if fl2 // ���ࠢ��� �� 2 �⠯
  arr_21[12] ++ // ���ࠢ��� �� 2 �⠯
endif
if !empty(tmp->kod2h) // ��ᯠ��ਧ��� II �⠯
  human->(dbGoto(tmp->kod2h))
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa,1,4)
    tmp2->rslt2 := human_->RSLT_NEW
    if empty(tmp2->rslt1)
    else
      arr_21[13] ++
      if !fl2  // �� �� ���ࠢ���, �� ��� ࠢ�� ����
        arr_21[12] ++ // ���ࠢ��� �� 2 �⠯
      endif
    endif
  else
    // ��祬�-� ���ࠢ��쭠� ��㯯�
  endif
endif
return NIL

***** 07.04.22
Function f2_f21_inf_DVN(par)
Local is_selo, i, j, k, k1 := 9, fl2 := .f., ar[21], arr11[15], arr12[43], au := {}, fl_pens
Private arr_otklon := {}, arr_usl_otkaz := {},;
        M1RAB_NERAB := human->RAB_NERAB, m1veteran := 0, m1mobilbr := 0,;
        m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0,;
        m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
        mholest := 0, mglukoza := 0, ;
        m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
        m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0,;
        m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0,;
        m1spec_na := 0, m1sank_na := 0,;
        pole_diag, pole_1pervich, pole_1stadia, pole_1dispans,;
        mWEIGHT := 0, mHEIGHT := 0
afill(ar,0) ; ar[2] := 1
afill(arr11,0)
afill(arr12,0)
if kart_->invalid > 0
  arr_21[21] ++
endif
if par == 1
  if mdvozrast < 35
    k1 := 1
  elseif mdvozrast < 40
    k1 := 2
  elseif mdvozrast < 55
    k1 := 3
  elseif mdvozrast < 60
    k1 := 4
  elseif mdvozrast < 65
    k1 := 5
  elseif mdvozrast < 75
    k1 := 6
  else
    k1 := 7
  endif
  //g5
endif
if human->n_data == human->k_data // �� ���� ����
  ar[5] := 1
endif
if (is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog))
  ar[6] := 1
endif
if dow(human->k_data) == 7 // �㡡��
  ar[4] := 1
  if is_selo
    ar[8] := 1
  endif
endif
fl_pens := f_starshe_trudosp(human->POL,human->DATE_R,human->n_data)
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  Private &pole_diag := space(6)
  Private &pole_1pervich := 0
  Private &pole_1stadia := 0
  Private &pole_1dispans := 0
next
read_arr_DVN(human->kod)
m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW,@fl2)
if between(m1gruppa,0,4)
  if m1gruppa == 0
    fl2 := .t. // ���ࠢ��� �� 2 �⠯
  endif
endif
if !empty(tmp->kod2h)
  fl2 := .t. // ��襫 2 �⠯
endif
select HU
find (str(tmp->kod1h,7))
do while hu->kod == tmp->kod1h .and. !eof()
  usl->(dbGoto(hu->u_kod))
  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
    lshifr := usl->shifr
  endif
  aadd(au,{alltrim(lshifr),;
           hu_->PROFIL,;
           0,;
           c4tod(hu->date_u);
          })
  select HU
  skip
enddo
for k := 1 to len(au)
  if ascan(arr_otklon,au[k,1]) > 0
    au[k,3] := 1 // �⪫������ � ��᫥�������
  endif
  if au[k,1] == "7.57.3"
    arr12[1] := arr12[2] := 1
    arr12[3] := au[k,3]
    if fl2 .and. au[k,3] == 1
      arr12[4] := 1
    endif
  elseif au[k,1] == "4.8.4"
    arr12[12] := arr12[13] := 1
    arr12[14] := au[k,3]
    if fl2 .and. au[k,3] == 1
      arr12[15] := 1
    endif
  elseif eq_any(au[k,1],"4.20.1","4.20.2")
    arr12[25] := arr12[26] := 1
    arr12[27] := au[k,3]
    if fl2 .and. au[k,3] == 1
      arr12[28] := 1
    endif
  //elseif eq_any(au[k,1],"56.1.15","56.1.20","56.1.21","56.1.721")
    //arr11[10] := arr11[11] := 1
  //elseif au[k,1] == "56.1.723"
    //arr11[13] := arr11[14] := 1
  endif
next
// ��ᯠ��ਧ��� II �⠯
if !empty(tmp->kod2h)
  human->(dbGoto(tmp->kod2h))
  m1GRUPPA2 := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa2,1,4) // �筮 ���� 2 �⠯
    read_arr_DVN(human->kod) // ������� �������� � �.�.
  endif
  au := {}
  select HU
  find (str(tmp->kod1h,7))
  do while hu->kod == tmp->kod1h .and. !eof()
    usl->(dbGoto(hu->u_kod))
    if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
      lshifr := usl->shifr
    endif
    aadd(au,{alltrim(lshifr),;
             hu_->PROFIL,;
             0,;
             c4tod(hu->date_u);
            })
    select HU
    skip
  enddo
  for k := 1 to len(au)
    if ascan(arr_otklon,au[k,1]) > 0
      au[k,3] := 1 // �⪫������ � ��᫥�������
    endif
    if eq_any(au[k,1],"10.6.10","10.6.710")
      arr12[16] := 1
    elseif eq_any(au[k,1],"10.4.1","10.4.701")
      arr12[17] := 1
    elseif eq_any(au[k,1],"56.1.15","56.1.20","56.1.21","56.1.721")
      arr11[10] := arr11[11] := 1
    elseif au[k,1] == "56.1.723"
      arr11[13] := arr11[14] := 1
    endif
  next
endif
for i := 1 to 5
  pole_diag := "mdiag"+lstr(i)
  pole_1pervich := "m1pervich"+lstr(i)
  pole_1stadia := "m1stadia"+lstr(i)
  pole_1dispans := "m1dispans"+lstr(i)
  if &pole_1pervich == 1 .and. &pole_1dispans == 1
    arr11[1] := 1
  endif
  if !(left(&pole_diag,1) == "A" .or. left(&pole_diag,1) == "B") .and. &pole_1pervich == 1 // ����䥪樮��� ����������� ���.�����
    ar[9] := 1
    ar[10] ++
    if left(&pole_diag,1) == "I" // ������� ��⥬� �஢����饭��
      ar[11] := 1
    elseif left(&pole_diag,1) == "J" // ������� �࣠��� ��堭��
      ar[17] := 1
    elseif left(&pole_diag,1) == "K" // ������� �࣠��� ��饢�७��
      ar[18] := 1
    endif
    if left(&pole_diag,1) == "C" .or. between(left(&pole_diag,3),"D00","D09") // ���
      ar[12] := 1
      if &pole_1stadia < 3 // 1 � 2 �⠤��
        ar[13] := 1
      endif
      arr11[5] := 1
      if between(&pole_1stadia,1,4)
        arr11[5+&pole_1stadia] := 1
      endif
      if left(&pole_diag,3) == "C50"
        arr12[6] := 1
        if between(&pole_1stadia,1,4)
          arr12[7+&pole_1stadia] := 1
        endif
      elseif left(&pole_diag,3) == "D05"
        arr12[6] := 1
        arr12[7] := 1 // in situ
      endif
      if eq_any(left(&pole_diag,3),"C18","C19","C20","C21")
        arr12[19] := 1
        if between(&pole_1stadia,1,4)
          arr12[20+&pole_1stadia] := 1
        endif
      elseif eq_any(left(&pole_diag,5),"D01.0","D01.1","D01.2","D01.3")
        arr12[19] := 1
        arr12[20] := 1 // in situ
      endif
      if left(&pole_diag,3) == "C53"
        arr12[30] := 1
        if between(&pole_1stadia,1,4)
          arr12[31+&pole_1stadia] := 1
        endif
      elseif left(&pole_diag,3) == "D06"
        arr12[30] := 1
        arr12[31] := 1 // in situ
      endif
      if eq_any(left(&pole_diag,3),"C00","C43","C44") .or. left(&pole_diag,5) == "C14.8"
        arr12[36] := 1
        arr12[38] := 1
        if between(&pole_1stadia,1,4)
          arr12[39+&pole_1stadia] := 1
        endif
      elseif eq_any(left(&pole_diag,3),"D03","D04") .or. left(&pole_diag,5) == "D00.0"
        arr12[36] := 1
        arr12[38] := 1
        arr12[39] := 1
      endif
    endif
    if between(left(&pole_diag,3),"E10","E14") // ���� ������
      ar[14] := 1
      if left(&pole_diag,3) == "E10" // I �⠤��
        ar[15] := 1
      endif
    endif
    if eq_any(left(&pole_diag,3),"H40","H42") .or. left(&pole_diag,5) == "Q15.0" // ���㪮��
      ar[16] := 1
    endif
    if &pole_1dispans == 1
      ar[19] := 1
      if is_selo
        ar[21] := 1
      endif
    endif
    if .f. // 1-��祭�� �����祭�
      ar[20] := 1 // ?? �뫮 ���� ��祭��
    endif
  endif
next
pole := "tmp1->g"+lstr(k1)
select TMP1
for i := 1 to len(ar)
  if ar[i] > 0
    find (str(i,2))
    &pole := &pole + ar[i]
    if k1 < 8 .and. fl_pens
      tmp1->g8 += ar[i]
    endif
  endif
next
select TMP11
for i := 1 to len(arr11)
  if arr11[i] > 0
    find (str(i,2))
    tmp11->g3 += arr11[i]
  endif
next
select TMP12
for i := 1 to len(arr12)
  if arr12[i] > 0
    find (str(i,2))
    tmp12->g3 += arr12[i]
  endif
next
return NIL

***** 20.10.16 ��������� �����ਭ�� ��ᯠ��ਧ�樨 ������
Function f22_inf_DVN()
Static group_ini := "f22_inf_DVN"
Static as := {;
  {1, 0,0,"��饥 �᫮ �ࠦ���, ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����"},;
  {2, 0,0,"������⢮ �ࠦ��� �� �᫠ ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����, ��襤�� 1-� �⠯ ��ᯠ��ਧ�樨 �� ����� ��ਮ�"},;
  {3, 0,0,"������⢮ �ࠦ��� �� �᫠ ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����, ��襤�� 2-� �⠯ ��ᯠ��ਧ�樨 �� ����� ��ਮ�"},;
  {4, 0,0,"������⢮ �ࠦ��� �� �᫠ ��������� ��ᯠ��ਧ�樨 � ⥪�饬 ����, ��������� �����訢�� ��ᯠ��ਧ��� �� ����� ��ਮ�, �� ���:"},;
  {4, 1,0,"����� I ��㯯� ���஢��"},;
  {4, 2,0,"����� II ��㯯� ���஢��"},;
  {4, 3,0,"����� III� ��㯯� ���஢��"},;
  {4, 4,0,"����� III� ��㯯� ���஢��"},;
  {5, 0,0,"������⢮ �ࠦ��� � ����� �����묨 �஭��᪨�� ����䥪樮��묨 ����������ﬨ, �� ���:"},;
  {5, 1,0,"� �⥭���न��"},;
  {5, 2,0,"� �஭��᪮� �襬��᪮� �������� ���"},;
  {5, 3,0,"� ���ਠ�쭮� �����⮭���"},;
  {5, 4,0,"� �⥭���� ᮭ��� ���਩ >50%"},;
  {5, 5,0,"� ����� ����襭��� ��������� �஢����饭�� � ��������"},;
  {5, 6,0,"� �����७��� �� �������⢥���� ������ࠧ������ ���㤪� �� १���⠬ 䨡ண����᪮���"},;
  {5, 6,1,"�� ࠭��� �⠤��"},;
  {5, 7,0,"� �����७��� �� �������⢥��� ������ࠧ������� ��⪨ � �� �ਤ�⪮�"},;
  {5, 7,1,"�� ࠭��� �⠤��"},;
  {5, 8,0,"� �����७��� �� �������⢥���� ������ࠧ������ ������ �� ����� �ᬮ�� ���-���࣠ (�஫���) � ��� �� �����ᯥ���᪨� ��⨣��"},;
  {5, 8,1,"�� ࠭��� �⠤��"},;
  {5, 9,0,"� �����७��� �� �������⢥���� ������ࠧ������ ��㤭�� ������ �� ����� �������䨨"},;
  {5, 9,1,"�� ࠭��� �⠤��"},;
  {5,10,0,"� �����७��� �� ����४⠫�� ࠪ �� ����� ४�஬���- � ������᪮���"},;
  {5,10,1,"�� ࠭��� �⠤��"},;
  {5,11,0,"� �����७��� �� �������⢥��� ����������� ��㣨� ��������権"},;
  {5,11,1,"�� ࠭��� �⠤��"},;
  {5,12,0,"� ���� �����⮬"},;
  {6, 0,0,"������⢮ �ࠦ��� � ����� ������ �㡥�㫥��� ������"},;
  {7, 0,0,"������⢮ �ࠦ��� � ����� ������� ���㪮���, �� ���:"},;
  {7, 0,1,"�� ࠭��� �⠤��"},;
  {8, 0,0,"������⢮ �ࠦ��� � ����� �����묨 ����������ﬨ ��㣨� �࣠��� � ��⥬ �� ����� ��ਮ�"},;
  {9, 0,0,"������⢮ �ࠦ���, ������ 䠪��� �᪠ �஭��᪨� ����䥪樮���� ����������� �� ����� ��ਮ�, �� ���:"},;
  {9, 1,0,"���ॡ���� ⠡�� (��७��)"},;
  {9, 2,0,"����襭��� ��"},;
  {9, 3,0,"�����筠� ���� ⥫�"},;
  {9, 4,0,"���७��"},;
  {9, 5,0,"�����宫���ਭ����, ��᫨�������"},;
  {9, 6,0,"����࣫������"},;
  {9, 7,0,"�������筠� 䨧��᪠� ��⨢�����"},;
  {9, 8,0,"���樮���쭮� ��⠭��"},;
  {9, 9,0,"�����७��� �� ���㡭�� ���ॡ����� ��������"},;
  {9,10,0,"����騥 2 䠪�� �᪠ � �����"},;
  {10,0,0,"������⢮ �ࠦ��� � �����७��� �� ����ᨬ���� �� ��������, ��મ⨪�� � ����ய��� �।��, �� ���:"},;
  {11,0,1,"�᫮ �ࠦ���, ���ࠢ������ � ��娠���-��મ����"},;
  {12,0,0,"������⢮ �ࠦ��� 2-� ��㯯� ���஢��, ��襤�� 㣫㡫����� ��䨫����᪮� �������஢����"},;
  {13,0,0,"������⢮ �ࠦ��� 2-� ��㯯� ���஢��, ��襤�� ��㯯���� ��䨫����᪮� �������஢����"},;
  {14,0,0,"������⢮ �ࠦ��� 3-� ��㯯� ���஢��, ��襤�� 㣫㡫����� ��䨫����᪮� �������஢����"},;
  {15,0,0,"������⢮ �ࠦ��� 3-� ��㯯� ���஢��, ��襤�� ��㯯���� ��䨫����᪮� �������஢����"};
 }
Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL ;
                                   .and. (arr_m := year_month(,,,5)) != NIL
  Private mk1, mispoln, mtel_isp
  ar := GetIniSect(tmp_ini,group_ini)
  mk1 := int(val(a2default(ar,"mk1","0")))
  mispoln := padr(a2default(ar,"mispoln",""),20)
  mtel_isp := padr(a2default(ar,"mtel_isp",""),20)
  s := " \"+;
    "      ��饥 �᫮ �ࠦ���, ��������� ��ᯠ��ਧ�樨 @          \"+;
    "      ������� � ���樠�� �ᯮ���⥫� @                           \"+;
    "      ����䮭 �ᯮ���⥫�            @                           \"+;
    " \"
  DisplBox(s,;
    , ;                   // 梥� ���� (㬮��. - cDataCGet)
    {"mk1","mispoln","mtel_isp"},; // ���ᨢ Private-��६����� ��� ।���஢����
    {"999999",,},; // ���ᨢ Picture ��� ।���஢����
    17)
  if lastkey() != K_ESC
    SetIniSect(tmp_ini,group_ini,{{"mk1",mk1},;
                                  {"mispoln",mispoln},;
                                  {"mtel_isp",mtel_isp};
                                 })
    mywait()
    if f0_inf_DVN(arr_m,.f.)
      mywait("���� ����⨪�")
      delFRfiles()
      dbcreate(fr_data,{;
        {"nomer","C",5,0},;
        {"nn1","N",2,0},;
        {"nn2","N",2,0},;
        {"nn3","N",2,0},;
        {"name","C",250,0},;
        {"v1","N",6,0},;
        {"v2","N",6,0}})
      use (fr_data) new alias FRD
      for i := 1 to len(as)
        append blank
        if !empty(as[i,1]) .and. empty(as[i,2])
          frd->nomer := lstr(as[i,1])+"."
        endif
        frd->nn1 := as[i,1]
        frd->nn2 := as[i,2]
        frd->nn3 := as[i,3]
        frd->name := iif(!empty(as[i,1]), "", space(10))+;
                     iif( empty(as[i,2]), "", space(10))+;
                     iif( empty(as[i,3]), "", space(10))+;
                     as[i,4]
        if i == 1
          frd->v1 := frd->v2 := mk1
        endif
      next
      index on str(nn1,2)+str(nn2,2)+str(nn3,2) to (cur_dir+"tmp_frd")
      //
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_
      R_Use(dir_server+"schet_",,"SCHET_")
      ii := 0
      use (cur_dir+"tmp") index (cur_dir+"tmp") new
      go top
      do while !eof()
        @ maxrow(),0 say str(++ii/tmp->(lastrec())*100,6,2)+"%" color cColorWait
        if !emptyall(tmp->kod1h,tmp->kod2h) // ⮫쪮 ��ᯠ��ਧ���
          f1_f22_inf_DVN()
        endif
        select TMP
        skip
      enddo
      close databases
      R_Use(dir_server+"organiz",,"ORG")
      dbcreate(fr_titl, {{"name","C",130,0},;
                         {"period","C",100,0},;
                         {"ispoln","C",100,0},;
                         {"glavn","C",100,0}})
      use (fr_titl) new alias FRT
      append blank
      frt->name := glob_mo[_MO_SHORT_NAME]
      frt->period := arr_m[4]
      frt->glavn :=  "������ ��� __________________ "+fam_i_o(org->ruk)
      frt->ispoln := "�ᯮ���⥫�: "+alltrim(mispoln)+" __________________ ⥫."+alltrim(mtel_isp)
      //
      ar := {}
      aadd(ar, {2,3,month(arr_m[6]+1) })
      aadd(ar, {2,4,"."+lstr(year(arr_m[6]+1)) })
      use (fr_data) new alias FRD
      for i := 1 to len(as)
        goto (i)
        if i != 4
          aadd(ar, {8+i,3,frd->v1})
        endif
        if !eq_any(i,1,4)
          aadd(ar, {8+i,5,frd->v2})
        endif
      next
      aadd(ar, {59,1,frt->glavn })
      aadd(ar, {61,1,frt->ispoln})
      aadd(arr_excel, {"�ଠ ����",aclone(ar)})
      close databases
      call_fr("mo_dvnMZ")
    endif
  endif
endif
return NIL

*

***** 23.09.15
Function f1_f22_inf_DVN() // ᢮���� ���ଠ��
Local i, ar := {}, fl_reg1 := .f., fl_reg2 := .f., is_d := .f., is_pr := .f.,;
      k5 := 0, k9 := 0, m1gruppa, fl
// ��ᯠ��ਧ��� I �⠯
if empty(tmp->kod1h)
  // ��� 1 �⠯�, �� ���� ��ன
else
  human->(dbGoto(tmp->kod1h))
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
  if !between(m1gruppa,0,4)
    return NIL
  endif
  Private m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
          mholest := 0, mglukoza := 0,;
          m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
          m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
          pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
  for i := 1 to 5
    pole_diag := "mdiag"+lstr(i)
    pole_1stadia := "m1stadia"+lstr(i)
    pole_1pervich := "m1pervich"+lstr(i)
    Private &pole_diag := space(6)
    Private &pole_1stadia := 0
    Private &pole_1pervich := 0
  next
  read_arr_DVN(human->kod)
  ret_tip_mas(mWEIGHT,mHEIGHT,@m1tip_mas)
  if human->schet > 0
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      fl_reg1 := .t.
    endif
  endif
  //
  aadd(ar,{2,0,0,fl_reg1})
  if m1kurenie == 1
    aadd(ar,{9,1,0,fl_reg1}) ; ++k9
  endif
  if mad1 > 140 .and. mad2 > 90
    aadd(ar,{9,2,0,fl_reg1}) ; ++k9
  endif
  if m1tip_mas == 3
    aadd(ar,{9,3,0,fl_reg1}) ; ++k9
  elseif m1tip_mas > 3
    aadd(ar,{9,4,0,fl_reg1}) ; ++k9
  endif
  if m1holestdn == 1 .or. mholest > 5
    aadd(ar,{9,5,0,fl_reg1}) ; ++k9
  endif
  if m1glukozadn == 1 .or. mglukoza > 6.1
    aadd(ar,{9,6,0,fl_reg1}) ; ++k9
  endif
  if m1fiz_akt == 1
    aadd(ar,{9,7,0,fl_reg1}) ; ++k9
  endif
  if m1ner_pit == 1
    aadd(ar,{9,8,0,fl_reg1}) ; ++k9
  endif
  if m1riskalk == 1
    aadd(ar,{9,9,0,fl_reg1}) ; ++k9
  endif
  if k9 > 1
    aadd(ar,{9,10,0,fl_reg1})
  endif
  if k9 > 0
    aadd(ar,{9,0,0,fl_reg1})
  endif
  if m1pod_alk == 1
    aadd(ar,{10,0,0,fl_reg1})
    if m1psih_na == 1
      aadd(ar,{11,0,1,fl_reg1})
    endif
  endif
  if !empty(tmp->kod2h) // ��ᯠ��ਧ��� II �⠯
    human->(dbGoto(tmp->kod2h))
    i := ret_gruppa_DVN(human_->RSLT_NEW)
    if between(i,1,4)
      m1gruppa := i
      if human->schet > 0
        select SCHET_
        goto (human->schet)
        if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
          fl_reg2 := .t.
        endif
      endif
      aadd(ar,{3,0,0,fl_reg2})
      if i == 2
        if m1prof_ko == 0
          aadd(ar,{12,0,0,fl_reg2})
        elseif m1prof_ko == 1
          aadd(ar,{13,0,0,fl_reg2})
        endif
      elseif eq_any(i,3,4)
        if m1prof_ko == 0
          aadd(ar,{14,0,0,fl_reg2})
        elseif m1prof_ko == 1
          aadd(ar,{15,0,0,fl_reg2})
        endif
      endif
    else // �᫨ ��-� �� ⠪ � ���� �⠯��
      human->(dbGoto(tmp->kod1h)) // �������� �� 1 �⠯
    endif
  endif
  if between(m1gruppa,1,4)
    fl := fl_reg1 .or. fl_reg2
    aadd(ar,{4,0,0,fl})
    aadd(ar,{4,m1gruppa,0,fl})
    for i := 1 to 5
      pole_diag := "mdiag"+lstr(i)
      pole_1stadia := "m1stadia"+lstr(i)
      pole_1pervich := "m1pervich"+lstr(i)
      if !empty(&pole_diag) .and. &pole_1pervich==1
        is_d := .t.
        if left(&pole_diag,3) == "I20"
          aadd(ar,{5,1,0,fl}) ; ++k5
        elseif left(&pole_diag,3) == "I25"
          aadd(ar,{5,2,0,fl}) ; ++k5
        elseif eq_any(left(&pole_diag,3),"I10","I11","I12","I13","I15")
          aadd(ar,{5,3,0,fl}) ; ++k5
        elseif left(&pole_diag,5) == "I65.2"
          aadd(ar,{5,4,0,fl}) ; ++k5
        elseif left(&pole_diag,3) == "I66"
          aadd(ar,{5,5,0,fl}) ; ++k5
        elseif left(&pole_diag,1) == "C"
          if left(&pole_diag,3) == "C16"
            aadd(ar,{5,6,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,6,1,fl})
            endif
          elseif eq_any(left(&pole_diag,3),"C53","C54","C55")
            aadd(ar,{5,7,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,7,1,fl})
            endif
          elseif left(&pole_diag,3) == "C61"
            aadd(ar,{5,8,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,8,1,fl})
            endif
          elseif left(&pole_diag,3) == "C50"
            aadd(ar,{5,9,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,9,1,fl})
            endif
          elseif eq_any(left(&pole_diag,3),"C17","C18","C19","C20","C21")
            aadd(ar,{5,10,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,10,1,fl})
            endif
          else
            aadd(ar,{5,11,0,fl}) ; ++k5
            if &pole_1stadia == 1
              aadd(ar,{5,11,1,fl})
            endif
          endif
        elseif eq_any(left(&pole_diag,3),"E10","E11","E12","E13","E14")
          aadd(ar,{5,12,0,fl}) ; ++k5
        elseif eq_any(left(&pole_diag,3),"A15","A16")
          aadd(ar,{6,0,0,fl}) ; is_pr := .t.
        elseif left(&pole_diag,3) == "H40"
          aadd(ar,{7,0,0,fl}) ; is_pr := .t.
          if &pole_1stadia == 1
            aadd(ar,{7,1,1,fl})
          endif
        endif
      endif
    next
    if k5 > 0
      aadd(ar,{5,0,0,fl})
    endif
    if is_d .and. empty(k5) .and. !is_pr
      aadd(ar,{8,0,0,fl})
    endif
  endif
endif
if !empty(ar)
  select FRD
  for i := 1 to len(ar)
    find (str(ar[i,1],2)+str(ar[i,2],2)+str(ar[i,3],2))
    if found()
      frd->v1 ++
      if ar[i,4]
        frd->v2 ++
      endif
    endif
  next
endif
return NIL

***** 20.01.21 ᯨ᮪ ��樥�⮢
Function f2_inf_DVN(is_schet,par)
Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, as := {},;
      a, sh, HH := 53, n, n_file := "spis_dvn"+stxt, reg_print
Private ppar := par, p_is_schet := is_schet
if par > 1
  ppar--
endif
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) != NIL .and. (arr_m := year_month(,,,5)) != NIL
  mywait()
  if f0_inf_DVN(arr_m,eq_any(is_schet,2,3),is_schet==3)
    adbf := {;
     {"nomer"    ,   "N",     6,     0},;
     {"KOD"      ,   "N",     7,     0},; // ��� (����� �����)
     {"KOD_K"    ,   "N",     7,     0},; // ��� �� ����⥪�
     {"FIO"      ,   "C",    50,     0},; // �.�.�. ���쭮��
     {"DATE_R"   ,   "D",     8,     0},; // ��� ஦����� ���쭮��
     {"N_DATA"   ,   "D",     8,     0},; // ��� ��砫� ��祭��
     {"K_DATA"   ,   "D",     8,     0},; // ��� ����砭�� ��祭��
     {"sroki"    ,   "C",    35,     0},; // �ப� ��祭��
     {"CENA_1"   ,   "N",    10,     2},; // ����稢����� �㬬� ��祭��
     {"KOD_DIAG" ,   "C",     5,     0},; // ��� 1-�� ��.�������
     {"etap"     ,   "N",     1,     0},; //
     {"gruppa"   ,   "N",     1,     0},; //
     {"vrach"    ,   "C",    15,     0},; // ���
     {"DATA_O"   ,   "C",    35,     0} ; // �ப� ��㣮�� �⠯�
    }
    ret_arrays_disp(.f.)
    Private count_dvn_arr_usl18 := len(dvn_arr_usl18)
    Private count_dvn_arr_umolch18 := len(dvn_arr_umolch18)
    ret_arrays_disp(.t.,.t.)
    for i := 1 to max(count_dvn_arr_usl18,count_dvn_arr_usl)
      aadd(adbf,{"d_"+lstr(i),"C",24,0})
    next
    for i := 1 to max(count_dvn_arr_umolch18,count_dvn_arr_umolch)
      aadd(adbf,{"du_"+lstr(i),"C",8,0})
    next
    aadd(adbf,{"fl_2018","L",1,0})
    aadd(adbf,{"d_zs","C",8,0})
    dbcreate(cur_dir+"tmpfio",adbf)
    use (cur_dir+"tmpfio") new alias TF
    R_Use(dir_server+"uslugi",,"USL")
    use_base("human_u")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_
    R_Use(dir_server+"mo_pers",,"PERS")
    R_Use(dir_server+"schet_",,"SCHET_")
    use (cur_dir+"tmp") new
    go top
    do while !eof()
      @ maxrow(),0 say str(tmp->(recno())/tmp->(lastrec())*100,6,2)+"%" color cColorWait
      do case
        case par == 1
          if tmp->kod1h > 0
            f2_inf_DVN_svod(1,tmp->kod1h)
          endif
        case par == 2
          if tmp->kod1h > 0 .and. tmp->kod2h == 0
            f2_inf_DVN_svod(0,tmp->kod1h)
          endif
        case par == 3
          if tmp->kod1h > 0 .and. tmp->kod2h > 0
            f2_inf_DVN_svod(2,tmp->kod2h)
          endif
        case par == 4
          if tmp->kod3h > 0
            f2_inf_DVN_svod(3,tmp->kod3h)
          endif
      endcase
      select TMP
      skip
    enddo
    close databases
    mywait()
    at := {;
      {"����ਣ������ ��������",{{1,.t.,1},{1,.f.,1}},0},;
      {"�஢� �� ��騩 宫���ਭ",{{1,.t.,2},{1,.f.,2},{3,.t.,2},{3,.f.,2}},0},;
      {"�஢��� ���� � �஢�",{{1,.t.,3},{1,.f.,3},{3,.t.,3},{3,.f.,3}},0},;
      {"������᪨� ������ ���",{{1,.t.,4},{1,.f.,4}},0},;
      {"������ �஢� (3 ������⥫�)",{{1,.t.,5},{1,.f.,5},{3,.t.,5},{3,.f.,5}},0},;
      {"������ �஢� (ࠧ������)",{{1,.t.,6},{1,.f.,6}},0},;
      {"���娬��᪨� ������ �஢�",{{1,.t.,7},{1,.f.,7}},0},;
      {"�஢� �� �����-ᯥ���᪨� ��⨣��",{{1,.t.,8},{2,.f.,21}},0},;
      {"��᫥������� ���� �� ������ �஢�",{{1,.t.,9},{1,.f.,8},{3,.t.,9},{3,.f.,8}},0},;
      {"�ᬮ�� ����મ�, ���⨥ ����� (�᪮��)",{{1,.t.,10},{1,.f.,9}},0},;
      {"��������� ������� �����",{{1,.t.,11},{1,.f.,11},{3,.t.,11},{3,.f.,11}},0},;
      {"���ண��� �񣪨�",{{1,.t.,12},{1,.f.,12},{3,.t.,12},{3,.f.,12}},0},;
      {"��� ���譮� ������",{{1,.t.,13},{1,.f.,13},{1,.f.,15}},0},;
      {"�����ப�न����� (� �����)",{{1,.t.,14},{1,.f.,16}},0},;
      {"���஬����",{{2,.f.,17}},0},;
      {"�����஢���� ���������� �஢�",{{2,.t.,15},{2,.f.,18}},0},;
      {"����࠭⭮��� � ����",{{2,.t.,16},{2,.f.,19}},0},;
      {"������� ᯥ��� �஢�",{{2,.t.,17},{2,.f.,20}},0},;
      {"������-�� ��娮�䠫��� ���਩",{{2,.t.,18},{2,.f.,22}},0},;
      {"�������䠣�����த㮤���᪮���",{{2,.t.,19},{2,.f.,23}},0},;
      {"����᪮��� ���������᪠�",{{2,.t.,20},{2,.f.,24}},0},;
      {"����ᨣ��������᪮��� ���������᪠�",{{2,.t.,21},{2,.f.,25}},0},;
      {"��� ��� ���஫���",{{1,.t.,22},{2,.t.,22},{2,.f.,26}},0},;
      {"��� ��� ��⠫쬮����",{{2,.t.,23},{2,.f.,27}},0},;
      {"��� ��� ��ਭ���ਭ������",{{2,.f.,28}},0},;
      {"��� ��� �஫��� (���࣠)",{{2,.t.,24},{2,.f.,29}},0},;
      {"��� ��� �����-����������",{{2,.t.,25},{2,.f.,30}},0},;
      {"��� ��� �����ப⮫��� (���࣠)",{{2,.t.,26},{2,.f.,31}},0},;
      {"��� ��� �࠯���",{{1,.t.,27},{1,.f.,32},{2,.t.,27},{2,.f.,32},{3,.t.,27},{3,.f.,32}},0};
    }
    lat := len(at)
    aitog := array(lat) ; afill(aitog,0) ; is_zs := 0
    use (cur_dir+"tmpfio") new alias TF
    index on upper(fio) to (cur_dir+"tmpfio")
    go top
    do while !eof()
      for i := 1 to iif(tf->fl_2018,count_dvn_arr_usl18,count_dvn_arr_usl)
        pole := "tf->d_"+lstr(i)
        if !empty(&pole)
          for j := 1 to lat
            if at[j,3] == 0 .and. ascan(at[j,2],{|x| x[1]==ppar .and. x[2]==tf->fl_2018 .and. x[3]==i }) > 0
              at[j,3] := 1 ; exit
            endif
          next
        endif
      next
      if empty(is_zs) .and. !empty(tf->d_zs)
        is_zs := 1
      endif
      skip
    enddo
    arr_title := {;
      "����������������������������������",;
      "            ���⠳  �ப�   � ��.",;
      "    �.�.�   �஦�� ��祭��  �����-",;
      "            �����          � ��� ",;
      "����������������������������������"}
    if ppar == 2
      arr_title[1] += "�����������"
      arr_title[2] += "����ଠ��"
      arr_title[3] += "�� I �⠯� "
      arr_title[4] += "���ᯠ�-樨"
      arr_title[5] += "�����������"
    endif
    for i := 1 to lat
      if at[i,3] > 0
        arr_title[1] += "���������"
        arr_title[2] += "�"+padr(substr(at[i,1], 1,8),8)
        arr_title[3] += "�"+padr(substr(at[i,1], 9,8),8)
        arr_title[4] += "�"+padr(substr(at[i,1],17,8),8)
        arr_title[5] += "���������"
      endif
    next
    if is_zs > 0
      arr_title[1] += "���������"
      arr_title[2] += "�  ���  "
      arr_title[3] += "������祭"
      arr_title[4] += "� ���� "
      arr_title[5] += "���������"
    endif
    if ppar == 1
      arr_title[1] += "�����������"
      arr_title[2] += "����ଠ��"
      arr_title[3] += "�� II �⠯�"
      arr_title[4] += "���ᯠ�-樨"
      arr_title[5] += "�����������"
    endif
    arr_title[1] += "����������"
    arr_title[2] += "��� �㬬� "
    arr_title[3] += "�� ����"
    arr_title[4] += "�� ���"
    arr_title[5] += "����������"
    reg_print := f_reg_print(arr_title,@sh,2)
    fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
    add_string("")
    if ppar == 1
      add_string(center("��ᯠ��ਧ��� ���᫮�� ��ᥫ���� 1 �⠯",sh))
      if par == 2
        add_string(center("���ࠢ���� �� 2 �⠯, �� ��� �� ��諨",sh))
      endif
    elseif ppar == 2
      add_string(center("��ᯠ��ਧ��� ���᫮�� ��ᥫ���� 2 �⠯",sh))
    else
      add_string(center("��䨫��⨪� ���᫮�� ��ᥫ����",sh))
    endif
    if is_schet == 4
      add_string(center("[ ��砨, ��� �� �����訥 � ��� ]",sh))
    else
      add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    endif
    add_string(center(arr_m[4],sh))
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    j1 := ss := 0
    go top
    do while !eof()
      s := lstr(++j1)+". "+tf->fio
      s1 := substr(s, 1,12)+" "
      s2 := substr(s,13,12)+" "
      s3 := substr(s,25,12)+" "
      s := full_date(tf->date_r)
      s1 += padr(substr(s,1,3),5)
      s2 += padr(substr(s,4,3),5)
      s3 += padr(substr(s,7)  ,5)
      //
      s1 += padr(substr(tf->sroki, 1,9),11)
      s2 += padr(substr(tf->sroki,10,9),11)
      s3 += padr(substr(tf->sroki,19)  ,11)
      //
      s1 += padr(tf->KOD_DIAG,6)
      s2 += space(6)
      s3 += space(6)
      if ppar == 2
        s1 += padr(substr(tf->data_o, 1,9),11)
        s2 += padr(substr(tf->data_o,10,9),11)
        s3 += padr(substr(tf->data_o,19)  ,11)
      endif
      for i := 1 to lat
        if at[i,3] > 0
          fl := .t.
          for j := 1 to len(at[i,2])
            if at[i,2,j,1] == ppar .and. at[i,2,j,2] == tf->fl_2018
              pole := "tf->d_"+lstr(at[i,2,j,3]) // ����� ������� �� ���ᨢ� �-�� mo_init
              if !empty(&pole)
                s1 += padr(substr(&pole, 1,8),9)
                s2 += padr(substr(&pole, 9,8),9)
                s3 += padr(substr(&pole,17)  ,9)
                if between(left(&pole,1),'0','9')
                  aitog[i] ++
                endif
                fl := .f.
                exit
              endif
            endif
          next
          if fl
            s1 += space(9)
            s2 += space(9)
            s3 += space(9)
          endif
        endif
      next
      if is_zs > 0
        s1 += padr(tf->d_zs,9)
        s2 += space(9)
        s3 += space(9)
      endif
      if ppar == 1
        s1 += padr(substr(tf->data_o, 1,9),11)
        s2 += padr(substr(tf->data_o,10,9),11)
        s3 += padr(substr(tf->data_o,19)  ,11)
      endif
      s1 += iif(tf->gruppa == 4, "3", put_val(tf->gruppa,1))+str(tf->CENA_1,8,2)
      if tf->gruppa > 2
        s2 += iif(tf->gruppa == 3, "�", "�")
      endif
      s3 += alltrim(tf->vrach)
      ss += tf->CENA_1
      if verify_FF(HH-3,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s1)
      add_string(s2)
      add_string(s3)
      add_string(replicate("�",sh))
      skip
    enddo
    s1 := padr("�⮣�:",13+5+11+6)
    if ppar == 2
      s1 += space(11)
    endif
    for i := 1 to lat
      if at[i,3] > 0
        if empty(aitog[i])
          space(9)
        else
          s1 += padc(lstr(aitog[i]),8)+" "
        endif
      endif
    next
    i := 0
    if is_zs > 0
      i += 9
    endif
    if ppar == 1
      i += 11
    endif
    i += 2
    s1 += str(ss,7+i,2)
    add_string(s1)
    close databases
    fclose(fp)
    Private yes_albom := .t.
    viewtext(n_file,,,,(sh>80),,,reg_print)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 15.02.20
Function f2_inf_DVN_svod(par,kod_h) // ᢮���� ���ଠ��
Static P_BEGIN_RSLT := 342
Local i, j, c, s, pole, ar, arr := {}, fl, lshifr, arr_usl := {}
Private metap := ppar, m1gruppa, mvozrast, mdvozrast, mpol, mn_data, mk_data,;
        arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1veteran := 0, mvar,;
        fl2 := .f., mshifr_zs := "", is_2019
select HUMAN
goto (kod_h)
mpol    := human->pol
mn_data := human->n_data
mk_data := human->k_data
is_2018 := p := (mk_data < d_01_05_2019)
is_2021 := p := (mk_data < d_01_01_2021)
is_2019 := !is_2018
ret_arr_vozrast_DVN(mk_data)
ret_arrays_disp(is_2019,is_2021)
if ppar == 1 // ��ᯠ��ਧ��� 1 �⠯
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW,@fl2)
  if between(m1gruppa,0,4)
    if m1gruppa == 0
      fl2 := .t. // ���ࠢ��� �� 2 �⠯
    endif
  else
    return NIL
  endif
  if par == 0 .and. !fl2
    return NIL
  endif
elseif ppar == 2 // ��ᯠ��ਧ��� 2 �⠯
  m1GRUPPA := ret_gruppa_DVN(human_->RSLT_NEW)
  if between(m1gruppa,1,4)
    //
  else
    return NIL
  endif
elseif ppar == 3 // ��䨫��⨪�
  m1GRUPPA := 0
  if between(human_->RSLT_NEW,343,345)
    m1GRUPPA := human_->RSLT_NEW - 342
  elseif between(human_->RSLT_NEW,373,374)
    m1GRUPPA := human_->RSLT_NEW - 370
  endif
  if !between(m1gruppa,1,4)
    return NIL
  endif
else
  return NIL
endif
read_arr_DVN(kod_h)
mvozrast := count_years(human->date_r,human->n_data)
mdvozrast := year(human->n_data) - year(human->date_r)
if m1veteran == 1
  mdvozrast := ret_vozr_DVN_veteran(mdvozrast,human->k_data)
endif
for i := 1 to iif(is_2018,count_dvn_arr_usl18,count_dvn_arr_usl)
  mvar := "MTAB_NOMv"+lstr(i)
  Private &mvar := 0
  mvar := "MDATE"+lstr(i)
  Private &mvar := ctod("")
  mvar := "M1OTKAZ"+lstr(i)
  Private &mvar := 0
next
fl := .f.
if ppar == 1 .and. tmp->kod2h > 0
  select HUMAN
  goto (tmp->kod2h)
  fl := (human_->oplata != 9)
elseif ppar == 2 .and. tmp->kod1h > 0
  select HUMAN
  goto (tmp->kod1h)
  fl := (human_->oplata != 9)
endif
if fl
  s := "�� � ����"
  if human->schet > 0
    s := "����ॣ.��"
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ��ॣ����஢����
      s := "���� ��ॣ"
    endif
  endif
  aadd(arr,{human->n_data,human->k_data,s})
endif
select HUMAN
goto (kod_h)
if p_is_schet == 4 .and. human->schet > 0
  return NIL
endif
s := "�� � ����"
if human->schet > 0
  s := "����ॣ.��"
  select SCHET_
  goto (human->schet)
  if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ��ॣ����஢����
    s := "���� ��ॣ"
  endif
endif
select TF
append blank
tf->KOD    := human->kod
tf->KOD_K  := tmp->kod_k
tf->FIO    := human->fio
tf->DATE_R := human->date_r
tf->N_DATA := mN_DATA
tf->K_DATA := mK_DATA
tf->sroki  := date_8(mN_DATA)+"-"+date_8(mK_DATA)+" "+s
tf->CENA_1 := human->CENA_1
tf->etap   := metap
tf->gruppa := m1gruppa
tf->KOD_DIAG := human->kod_diag
if len(arr) > 0
  tf->data_o := date_8(arr[1,1])+"-"+date_8(arr[1,2])+" "+arr[1,3]
endif
pers->(dbGoto(human_->vrach))
tf->vrach := fam_i_o(pers->fio)
lcount := iif(is_2018,count_dvn_arr_usl18,count_dvn_arr_usl)
larr_dvn := iif(is_2018,dvn_arr_usl18,dvn_arr_usl)
lcount_u := iif(is_2018,count_dvn_arr_umolch18,count_dvn_arr_umolch)
larr_dvn_u := iif(is_2018,dvn_arr_umolch18,dvn_arr_umolch)
larr := array(2,lcount) ; afillall(larr,0)
select HU
find (str(kod_h,7))
do while hu->kod == kod_h .and. !eof()
  usl->(dbGoto(hu->u_kod))
  if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,mk_data))
    lshifr := usl->shifr
  endif
  lshifr := alltrim(lshifr)
  if !eq_any(left(lshifr,5),"70.3.","70.7.","72.1.","72.5.","72.6.","72.7.","2.90.")
    mshifr_zs := lshifr
  else
    fl := .t.
    if metap != 2
      if is_2018
        if lshifr == "2.3.3" .and. hu_->PROFIL == 3 ; // �����᪮�� ����
            .and. (i := ascan(dvn_arr_usl18, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif
      else
        /*if ((lshifr == "2.3.3" .and. hu_->PROFIL == 3) .or.  ; // �����᪮�� ����
              (lshifr == "2.3.1" .and. hu_->PROFIL == 136))  ; // �������� � �����������
            .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif*/
      endif
    endif
    if fl
      for i := 1 to lcount_u
        if empty(larr[2,i]) .and. larr_dvn_u[i,2] == lshifr
          fl := .f. ; larr[2,i] := hu->(recno()) ; exit
        endif
      next
    endif
    if fl
      for i := 1 to lcount
        if empty(larr[1,i])
          if valtype(larr_dvn[i,2]) == "C"
            if larr_dvn[i,2] == lshifr
              fl := .f.
            elseif larr_dvn[i,2] == "4.20.1" .and. lshifr == "4.20.2"
              fl := .f.
            endif
          elseif len(larr_dvn[i]) > 11
            if ascan(larr_dvn[i,12],{|x| x[1]==lshifr .and. x[2]==hu_->PROFIL}) > 0
              fl := .f.
            endif
          endif
          if !fl
            larr[1,i] := hu->(recno()) ; exit
          endif
        endif
      next
    endif
  endif
  aadd(arr_usl,hu->(recno()))
  select HU
  skip
enddo
for i := 1 to lcount
  if !empty(larr[1,i])
    hu->(dbGoto(larr[1,i]))
    if hu->kod_vr > 0
      mvar := "MTAB_NOMv"+lstr(i)
      &mvar := hu->kod_vr
    endif
    mvar := "MDATE"+lstr(i)
    &mvar := c4tod(hu->date_u)
    mvar := "M1OTKAZ"+lstr(i)
    if metap != 2
      if is_2018
        if hu_->PROFIL == 3 .and. ;
            ascan(dvn_arr_usl18, {|x| valtype(x[2])=="C" .and. x[2]=="4.20.1"}) > 0
          &mvar := 2 // ������������� �믮������
        endif
      else
        /*if (hu_->PROFIL == 3 .or. hu_->PROFIL == 136)  ;
            .and. ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"}) > 0
          &mvar := 2 // ������������� �믮������
        endif*/
      endif
    endif
  endif
next
if metap != 2 .and. valtype(arr_usl_otkaz) == "A"
  for j := 1 to len(arr_usl_otkaz)
    ar := arr_usl_otkaz[j]
    if valtype(ar) == "A" .and. len(ar) >= 5 .and. valtype(ar[5]) == "C"
      lshifr := alltrim(ar[5])
      if (i := ascan(larr_dvn, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
        if valtype(ar[1]) == "N" .and. ar[1] > 0
          mvar := "MTAB_NOMv"+lstr(i)
          &mvar := ar[1]
        endif
        mvar := "MDATE"+lstr(i)
        &mvar := mn_data
        if len(ar) >= 9 .and. valtype(ar[9]) == "D"
          &mvar := ar[9]
        endif
        mvar := "M1OTKAZ"+lstr(i)
        &mvar := 1
        if len(ar) >= 10 .and. valtype(ar[10]) == "N" .and. between(ar[10],1,2)
          &mvar := ar[10]
        endif
      endif
    endif
  next
endif
//
if is_2018
  arr := f21_inf_DVN_svod18(1)
else
  arr := f21_inf_DVN_svod(1)
endif
for i := 1 to len(arr)
  pole := "tf->d_"+lstr(arr[i,4])
  if arr[i,5] == 1
    &pole := "�⪠�   ��樥��"
  elseif arr[i,5] == 2
    &pole := "������������� �믮������"
  else
    &pole := date_8(arr[i,2])
  endif
next
tf->d_zs := mshifr_zs
tf->fl_2018 := is_2018
if is_2018
  arr := f21_inf_DVN_svod18(2)
else
  arr := f21_inf_DVN_svod(2)
endif
for i := 1 to len(arr)
  pole := "tf->du_"+lstr(arr[i,4])
  &pole := date_8(arr[i,2])
next
return NIL

***** 10.11.19
Function f21_inf_DVN_svod18(par)
Local i, arr := {}
if par == 1
  for i := 1 to count_dvn_arr_usl18
    mvart := "MTAB_NOMv"+lstr(i)
    mvard := "MDATE"+lstr(i)
    mvaro := "M1OTKAZ"+lstr(i)
    if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      if !emptyany(&mvard,&mvart)
        aadd(arr, {dvn_arr_usl18[i,1], &mvard, "", i, &mvaro})
      endif
    endif
  next
else
  for i := 1 to count_dvn_arr_umolch18
    if f_is_umolch_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      aadd(arr, {dvn_arr_umolch18[i,1], iif(dvn_arr_umolch18[i,8]==0, mn_data, mk_data), "", i, 0})
    endif
  next
endif
return arr

***** 08.12.15
Function f21_inf_DVN_svod(par)
Local i, arr := {}
if par == 1
  for i := 1 to count_dvn_arr_usl
    mvart := "MTAB_NOMv"+lstr(i)
    mvard := "MDATE"+lstr(i)
    mvaro := "M1OTKAZ"+lstr(i)
    if f_is_usl_oms_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      if !emptyany(&mvard,&mvart)
        aadd(arr, {dvn_arr_usl[i,1], &mvard, "", i, &mvaro})
      endif
    endif
  next
else
  for i := 1 to count_dvn_arr_umolch
    if f_is_umolch_sluch_DVN(i,metap,iif(metap==3,mvozrast,mdvozrast),mpol)
      aadd(arr, {dvn_arr_umolch[i,1], iif(dvn_arr_umolch[i,8]==0, mn_data, mk_data), "", i, 0})
    endif
  next
endif
return arr



*

***** 19.02.18 ���ଠ�� �� ��䨫��⨪� � ����ᬮ�ࠬ ��ᮢ��襭����⭨�
Function inf_DNL(k)
Static si1 := 1, si2 := 1, sj1 := 1, sj2 := 1
Local mas_pmt, mas_msg, mas_fun, j, j1, j2
Local mas2pmt := {"��~䨫����᪨� �ᬮ���",;
                  "��~����⥫�� �ᬮ���",;
                  "��~ਮ���᪨� �ᬮ���"}
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~���� ���.����ᬮ��",;
                "~���᮪ ��樥�⮢",;
                "~�������ਠ��� �����",;
                "����� ��� ���~��ࠢ�",;
                "��ଠ � 030-��/~�-17",;
                "XML-䠩� ��� ~���⠫� ����"}
    mas_msg := {"���� ��䨫����᪮�� ����ᬮ�� ��ᮢ��襭����⭥�� (�ଠ � 030-��/�-17)",;
                "��ᬮ�� ᯨ�� ��樥�⮢, ��襤�� ����ᬮ���",;
                "�������ਠ��� ����� �� ��ᯠ��ਧ�樨/����ᬮ�ࠬ ��ᮢ��襭����⭨�",;
                "��ᯥ�⪠ ᢮��� ��� ������ࠤ᪮�� �����⭮�� ������ ��ࠢ���࠭����",;
                "�������� � ��䨫����᪨� �ᬮ��� ��ᮢ��襭����⭨� (�ଠ � 030-��/�-17)",;
                "�������� XML-䠩�� ��� ����㧪� �� ���⠫ �����ࠢ� ��"}
    mas_fun := {"inf_DNL(11)",;
                "inf_DNL(12)",;
                "inf_DNL(13)",;
                "inf_DNL(14)",;
                "inf_DNL(15)",;
                "inf_DNL(16)"}
    Private p_tip_lu := TIP_LU_PN
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    inf_DNL_karta()
  case k == 12
    ne_real()
  case k == 13
    mnog_poisk_DNL()
  case k == 14
    mas_pmt := {"~�������� � ���ᬮ��� ��⥩ �� ���ﭨ� �� ..."}
    mas_msg := {"�ਫ������ � �ਪ��� ������ �1025 �� 08.07.2019�."}
    mas_fun := {"inf_DNL(21)"}
    popup_prompt(T_ROW,T_COL-5,si2,mas_pmt,mas_msg,mas_fun)
  case k == 15
    if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      inf_DNL_030poo(j1)
    endif
  case k == 16
    //if (j2 := popup_prompt(T_ROW,T_COL-5,sj2,mas2pmt,,,"N/W,GR+/R,B/W,W+/R")) > 0
      //sj2 := j2
      //p_tip_lu := {TIP_LU_PN,TIP_LU_PREDN,TIP_LU_PERN}[j2]
      p_tip_lu := TIP_LU_PN
      if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
        //inf_DNL_XMLfile(j1,charrem("~",mas2pmt[j2]))
        inf_DNL_XMLfile(j1,"��䨫����᪨� �ᬮ���")
      endif
    //endif
  case k == 21
    if (j1 := popup_prompt(T_ROW,T_COL-5,1,mas1pmt)) > 0
      f21_inf_DNL(j1)
    endif
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

*

***** 25.03.18 ��ᯥ�⪠ ����� ���.���.�ᬮ�� (���⭠� �ଠ � 030-��/�...)
Function inf_DNL_karta()
Local arr_m, buf := save_maxrow(), blk, t_arr[BR_LEN]
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  if f0_inf_DNL(arr_m,.f.)
    copy file (cur_dir+"tmp"+sdbf) to (cur_dir+"tmpDNL"+sdbf) // �.�. ����� ⮦� ���� TMP-䠩�
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmpDNL") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmpDNL")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            R_Use(cur_dir+"tmpDNL",cur_dir+"tmpDNL","TMP"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    t_arr[BR_TITUL] := "���ᬮ��� ��ᮢ��襭����⭨� "+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'�','�','�',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(human->schet > 0, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" �.�.�.", {|| padr(human->fio,39) }, blk },;
                         {"��� ஦�.", {|| full_date(human->date_r) }, blk },;
                         {"� ��.�����", {|| human->uch_doc }, blk },;
                         {"�ப� ���-�", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"�⠯", {|| iif(human->ishod==301," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Enter>^ - �ᯥ���� ����� ��䨫����᪮�� ���.�ᬮ��") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_DNL_karta(nk,ob,"edit") }
    edit_browse(t_arr)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 11.03.19
Function f0_inf_DNL(arr_m,is_schet,is_reg,arr_ishod,is_snils)
Local fl := .t.
DEFAULT is_schet TO .t., is_reg TO .f., is_snils TO .f., arr_ishod TO {301,302} // ��䨫��⨪� 1 � 2 �⠯
if !del_dbf_file("tmp"+sdbf)
  return .f.
endif
dbcreate(cur_dir+"tmp",{{"kod","N",7,0},;
                        {"kod_k","N",7,0},;
                        {"is", "N",1,0},;
                        {"ishod","N",6,0}})
use (cur_dir+"tmp") new
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"kartotek",,"KART")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humand","HUMAN")
set relation to recno() into HUMAN_, to kod_k into KART
dbseek(dtos(arr_m[5]),.t.)
index on kod to (cur_dir+"tmp_h") ;
      for ascan(arr_ishod,ishod) > 0 .and. iif(is_schet, schet > 0, .t.) ;
      while human->k_data <= arr_m[6] ;
      PROGRESS
go top
do while !eof()
  fl := .t.
  if is_reg
    fl := .f.
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      fl := .t.
    endif
  endif
  if fl .and. ret_koef_from_RAK(human->kod) > 0
    select TMP
    append blank
    tmp->kod := human->kod
    tmp->kod_k := human->kod_k
    tmp->ishod := human->ishod
    tmp->is := iif(is_snils .and. empty(kart->snils), 0, 1)
  endif
  select HUMAN
  skip
enddo
fl := .t.
if tmp->(lastrec()) == 0
  fl := func_error(4,"�� ������� �/� �� ����ᬮ�ࠬ ��ᮢ��襭����⭨� "+arr_m[4])
endif
close databases
return fl

*

***** 07.08.13
Function f1_inf_DNL_karta(nKey,oBrow,regim)
Local ret := -1, lkod_h, lkod_k, rec := tmp->(recno()), buf := save_maxrow()
if regim == "edit" .and. nKey == K_ENTER
  mywait()
  lkod_h := human->kod
  lkod_k := human->kod_k
  close databases
  oms_sluch_PN(lkod_h,lkod_k,"f2_inf_DNL_karta")
  eval(blk_open)
  goto (rec)
  rest_box(buf)
endif
return ret

***** 22.04.18
Function f2_inf_DNL_karta(Loc_kod,kod_kartotek,lvozrast)
Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {|s| __dbAppend(), field->stroke := s }
delFRfiles()
R_Use(dir_server+"mo_stdds")
if type("m1stacionar") == "N" .and. m1stacionar > 0
  goto (m1stacionar)
endif
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
R_Use(dir_server+"mo_pers",,"P2")
goto (m1vrach)
R_Use(dir_server+"organiz",,"ORG")
adbf := {{"name","C",130,0},;
         {"prikaz","C",50,0},;
         {"forma","C",50,0},;
         {"titul","C",100,0},;
         {"fio","C",50,0},;
         {"k_data","C",40,0},;
         {"vrach","C",40,0},;
         {"glavn","C",40,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->fio := mfio
frt->k_data := date_month(mk_data)
frt->vrach := fam_i_o(p2->fio)
frt->glavn := fam_i_o(org->ruk)
adbf := {{"stroke","C",2000,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
frt->prikaz := "�� 10 ������ 2017 �. � 514�"
frt->forma  := "030-��/�-17"
frt->titul  := "���� ��䨫����᪮�� �ᬮ�� ��ᮢ��襭����⭥��"
s := st+"1. �������, ���, ����⢮ (�� ����稨) ��ᮢ��襭����⭥��: "+ub+alltrim(mfio)+ue+"."
frd->(eval(blk,s))
s := st+"���: "+f3_inf_DDS_karta({{"��.","�"},{"���.","�"}},mpol,"/",ub,ue)
frd->(eval(blk,s))
s := st+"��� ஦�����: "+ub+date_month(mdate_r,.t.)+ue+"."
frd->(eval(blk,s))
s := st+"2. ����� ��易⥫쭮�� ����樭᪮�� ���客����: "
s += "��� "+iif(empty(mspolis), replicate("_",15), ub+alltrim(mspolis)+ue)
s += " � "+ub+alltrim(mnpolis)+ue+"."
frd->(eval(blk,s))
s := st+"���客�� ����樭᪠� �࣠������: "+ub+alltrim(mcompany)+ue+"."
frd->(eval(blk,s))
s := st+"3. ���客�� ����� �������㠫쭮�� ��楢��� ���: "
s += iif(empty(kart->snils), replicate("_",25), ub+transform(kart->SNILS,picture_pf)+ue)+"."
frd->(eval(blk,s))
s := st+"4. ���� ���� ��⥫��⢠ (�ॡ뢠���): "
if emptyall(kart_->okatog,kart->adres)
  s += replicate("_",37)+" "+replicate("_",sh)+"."
else
  s += ub+ret_okato_ulica(kart->adres,kart_->okatog,1,2)+ue+"."
endif
frd->(eval(blk,s))
s := st+"5. ��⥣���: "+f3_inf_DDS_karta(mm_kateg_uch,m1kateg_uch,"; ",ub,ue)
frd->(eval(blk,s))
s := st+"6. ������ ������������ ����樭᪮� �࣠����樨, � ���ன "+;
        "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
s += ub+ret_mo(m1MO_PR)[_MO_FULL_NAME]+ue+"."
frd->(eval(blk,s))
s := st+"7. ���� ���� ��宦����� ����樭᪮� �࣠����樨, � ���ன " +;
         "��ᮢ��襭����⭨� ����砥� ��ࢨ��� ������-ᠭ����� ������: "
s += ub+ret_mo(m1MO_PR)[_MO_ADRES]+ue+"."
frd->(eval(blk,s))
madresschool := ""
if type("m1school") == "N" .and. m1school > 0
  R_Use(dir_server+"mo_schoo",,"SCH")
  goto (m1school)
  if !empty(sch->fname)
    mschool := alltrim(sch->fname)
    madresschool := alltrim(sch->adres)
  endif
endif
s := st+"8. ������ ������������ ��ࠧ���⥫쭮� �࣠����樨, � ���ன "+;
        "���砥��� ��ᮢ��襭����⭨�: "+ub+mschool+ue+"."
frd->(eval(blk,s))
s := st+"9. ���� ���� ��宦����� ��ࠧ���⥫쭮� �࣠����樨, � ���ன "+;
        "���砥��� ��ᮢ��襭����⭨�: "
if empty(madresschool)
  frd->(eval(blk,s))
  s := replicate("_",sh)+"."
else
  s += ub+madresschool+ue+"."
endif
frd->(eval(blk,s))
s := st+"10. ��� ��砫� ��䨫����᪮�� ����樭᪮�� �ᬮ�� ��ᮢ��襭����⭥�� (����� - ��䨫����᪨� �ᬮ��): "+ub+full_date(mn_data)+ue+"."
frd->(eval(blk,s))
s := st+"11. ������ ������������ � ���� ���� ��宦����� ����樭᪮� �࣠����樨, "+;
        "�஢����襩 ��䨫����᪨� �ᬮ��: "+;
        ub+glob_mo[_MO_FULL_NAME]+", "+glob_mo[_MO_ADRES]+ue+"."
frd->(eval(blk,s))
s := st+"12. �業�� 䨧��᪮�� ࠧ���� � ��⮬ ������ �� ������ ��䨫����᪮�� �ᬮ��:"
frd->(eval(blk,s))
count_ymd(mdate_r,mn_data,@y,@m,@d)
s := ub+st+lstr(d)+st+ue+" (�᫮ ����) "+;
     ub+st+lstr(m)+st+ue+" (����楢) "+;
     ub+st+lstr(y)+st+ue+" ���."
frd->(eval(blk,s))
mm_fiz_razv1 := {{"����� ����� ⥫�",1},{"����⮪ ����� ⥫�",2}}
mm_fiz_razv2 := {{"������ ���",1},{"��᮪�� ���",2}}
for i := 1 to 2
  s := st+"12."+lstr(i)+". ��� ��⥩ � ������ "+;
          {"0 - 4 ���: ","5 - 17 ��� �����⥫쭮: "}[i]
  if i == 1
    fl := (lvozrast < 5)
  else
    fl := (lvozrast > 4)
  endif
  s += "���� (��) "+iif(!fl,"________",ub+st+lstr(mWEIGHT)+st+ue)+"; "
  s += "��� (�) "+iif(!fl,"________",ub+st+lstr(mHEIGHT)+st+ue)+"; "
  if i == 1
    s += "���㦭���� ������ (�) "+iif(!fl.or.mPER_HEAD==0,"________",ub+st+lstr(mPER_HEAD)+st+ue)+"; "
  endif
  s += "䨧��᪮� ࠧ��⨥ "+f3_inf_DDS_karta(mm_fiz_razv,iif(fl,m1FIZ_RAZV,-1),,ub,ue,.f.)
  s += " ("+f3_inf_DDS_karta(mm_fiz_razv1,iif(fl,m1FIZ_RAZV1,-1),,ub,ue,.f.)
  s += ", "+f3_inf_DDS_karta(mm_fiz_razv2,iif(fl,m1FIZ_RAZV2,-1),,ub,ue,.f.)
  s += " - �㦭�� ����ભ���)."
  frd->(eval(blk,s))
next
fl := (lvozrast < 5)
s := st+"13. �業�� ����᪮�� ࠧ���� (���ﭨ�):"
frd->(eval(blk,s))
s := st+"13.1. ��� ��⥩ � ������ 0 - 4 ���:"
frd->(eval(blk,s))
s := st+"�������⥫쭠� �㭪�� (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih11)+st+ue)+";"
frd->(eval(blk,s))
s := st+"���ୠ� �㭪�� (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih12)+st+ue)+";"
frd->(eval(blk,s))
s := st+"���樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih13)+st+ue)+";"
frd->(eval(blk,s))
s := st+"�।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����) "+iif(!fl,"________",ub+st+lstr(m1psih14)+st+ue)+"."
frd->(eval(blk,s))
fl := (lvozrast > 4)
s := st+"13.2. ��� ��⥩ � ������ 5 - 17 ���:"
frd->(eval(blk,s))
s := st+"13.2.1. ��宬��ୠ� ���: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih21,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.2. ��⥫����: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih22,-1),,ub,ue)
frd->(eval(blk,s))
s := st+"13.2.3. ���樮���쭮-�����⨢��� ���: "+f3_inf_DDS_karta(mm_psih2,iif(fl,m1psih23,-1),,ub,ue)
frd->(eval(blk,s))
fl := (mpol == "�" .and. lvozrast > 9)
s := st+"14. �業�� �������� ࠧ���� (� 10 ���):"
frd->(eval(blk,s))
s := st+"14.1. ������� ��㫠 ����稪�: � "+iif(!fl.or.m141p==0,"________",ub+st+lstr(m141p)+st+ue)
s += " �� "+iif(!fl.or.m141ax==0,"________",ub+st+lstr(m141ax)+st+ue)
s += " Fa "+iif(!fl.or.m141fa==0,"________",ub+st+lstr(m141fa)+st+ue)+"."
frd->(eval(blk,s))
fl := (mpol == "�" .and. lvozrast > 9)
s := st+"14.2. ������� ��㫠 ����窨: � "+iif(!fl.or.m142p==0,"________",ub+st+lstr(m142p)+st+ue)
s += " �� "+iif(!fl.or.m142ax==0,"________",ub+st+lstr(m142ax)+st+ue)
s += " Ma "+iif(!fl.or.m142ma==0,"________",ub+st+lstr(m142ma)+st+ue)
s += " Me "+iif(!fl.or.m142me==0,"________",ub+st+lstr(m142me)+st+ue)+";"
frd->(eval(blk,s))
s := st+"�ࠪ���⨪� ������㠫쭮� �㭪樨: menarhe ("
s += iif(!fl.or.m142me1==0,"________",ub+st+lstr(m142me1)+st+ue)+" ���, "
s += iif(!fl.or.m142me2==0,"________",ub+st+lstr(m142me2)+st+ue)+" ����楢); "
if fl .and. emptyall(m142p,m142ax,m142ma,m142me,m142me1,m142me2)
  m1142me3 := m1142me4 := m1142me5 := -1
endif
s += "menses (�ࠪ���⨪�): "+f3_inf_DDS_karta(mm_142me3,iif(fl,m1142me3,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me4,iif(fl,m1142me4,-1),,ub,ue,.f.)
s += ", "+f3_inf_DDS_karta(mm_142me5,iif(fl,m1142me5,-1)," � ",ub,ue)
frd->(eval(blk,s))
s := st+"15. ����ﭨ� ���஢�� �� �஢������ �����饣� ��䨫����᪮�� �ᬮ��:"
frd->(eval(blk,s))
if lvozrast < 14
  mdef_diagnoz := "Z00.1"
else
  mdef_diagnoz := "Z00.3"
endif
s := st+"15.1. �ࠪ��᪨ ���஢ "+iif(m1diag_15_1==0,replicate("_",30),ub+st+rtrim(mdef_diagnoz)+st+ue)+" (��� �� ���)."
frd->(eval(blk,s))
//
mm_dispans := {{"��⠭������ ࠭��",1},{"��⠭������ �����",2},{"�� ��⠭������",0}}
mm_danet := {{"��",1},{"���",0}}
mm_usl := {{"� ���㫠���� �᫮����",0},;
           {"� �᫮���� �������� ��樮���",1},;
           {"� ��樮����� �᫮����",2}}
mm_uch := {{"� �㭨樯����� ����樭᪨� �࣠�������",1},;
           {"� ���㤠��⢥���� ����樭᪨� �࣠������� ��ꥪ� ���ᨩ᪮� �����樨 ",0},;
           {"� 䥤�ࠫ��� ����樭᪨� �࣠�������",2},;
           {"����� ����樭᪨� �࣠�������",3}}
mm_uch1 := aclone(mm_uch)
aadd(mm_uch1, {"ᠭ��୮-������� �࣠�������",4})
mm_danet1 := {{"�������",1},{"�� �������",0}}
for i := 1 to 5
  fl := .f.
  for k := 1 to 14
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,4,5,6,7)
            mvar := "m1diag_15_"+lstr(i)+"_3"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,9,10,11,12)
            mvar := "m1diag_15_"+lstr(i)+"_8"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case k == 14
            mvar := "m1diag_15_"+lstr(i)+"_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := ""
  for k := 1 to 2
    mvar := "mdiag_15_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_15_1 == 0
    else
      m1var := "m1diag_15_"+lstr(i)+"_"+lstr(k)
      if (j := &m1var) > 0
        j := 1
      endif
    endif
    do case
      case k == 1
        s := st+"15."+lstr(i+1)+". ������� "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (��� �� ���)."
      case k == 2
        s1 := st+"15."+lstr(i+1)+".1. ��ᯠ��୮� ������� ��⠭������: "+f3_inf_DDS_karta(mm_danet,j,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
next
mm_gruppa := {{"I",1},{"II",2},{"III",3},{"IV",4},{"V",5}}
s := st+"15.7. ��㯯� ���ﭨ� ���஢��: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA_DO,,ub,ue)
frd->(eval(blk,s))
s := st+"15.8. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "+f3_inf_DDS_karta(mm_gr_fiz_do,m1GR_FIZ_DO,,ub,ue)
frd->(eval(blk,s))
s := st+"16. ����ﭨ� ���஢�� �� १���⠬ �஢������ �����饣� ��䨫����᪮�� �ᬮ��:"
frd->(eval(blk,s))
s := st+"16.1. �ࠪ��᪨ ���஢ "+iif(m1diag_16_1==0,replicate("_",30),ub+st+rtrim(mkod_diag)+st+ue)+" (��� �� ���)."
frd->(eval(blk,s))
for i := 1 to 5
  fl := .f.
  for k := 1 to 16
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
      if fl
        do case
          case eq_any(k,5,6)
            mvar := "m1diag_16_"+lstr(i)+"_4"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,8,9)
            mvar := "m1diag_16_"+lstr(i)+"_7"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,11,12)
            mvar := "m1diag_16_"+lstr(i)+"_10"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
          case eq_any(k,14,15)
            mvar := "m1diag_16_"+lstr(i)+"_13"
            if &mvar != 1 // �᫨ �� "��"
              &m1var := -1
            endif
        endcase
      else
        &m1var := -1
      endif
    endif
  next
next
for i := 1 to 5
  fl := .f.
  s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
  for k := 1 to 15
    mvar := "mdiag_16_"+lstr(i)+"_"+lstr(k)
    if k == 1
      fl := !empty(&mvar) .and. m1diag_16_1 == 0
    else
      m1var := "m1diag_16_"+lstr(i)+"_"+lstr(k)
    endif
    do case
      case k == 1
        s := st+"16."+lstr(i+1)+". ������� "+iif(!fl,replicate("_",30),ub+st+rtrim(&mvar)+st+ue)+" (��� �� ���)."
      case k == 2
        s1 := st+"16."+lstr(i+1)+".1. ������� ��⠭����� �����: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 3
        s2 := st+"16."+lstr(i+1)+".2. ��ᯠ��୮� �������: "+f3_inf_DDS_karta(mm_dispans,&m1var,,ub,ue)
      case k == 4
        s3 := st+"16."+lstr(i+1)+".3. �������⥫�� �������樨 � ��᫥������� �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 5
        s3 := left(s3,len(s3)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 6
        s3 := left(s3,len(s3)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 7
        s4 := st+"16."+lstr(i+1)+".4. �������⥫�� �������樨 � ��᫥������� �믮�����: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 8
        s4 := left(s4,len(s4)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 9
        s4 := left(s4,len(s4)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 10
        s5 := st+"16."+lstr(i+1)+".5. ��祭�� �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 11
        s5 := left(s5,len(s5)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 12
        s5 := left(s5,len(s5)-1)+'; '+f3_inf_DDS_karta(mm_uch,&m1var,,ub,ue)
      case k == 13
        s6 := st+"16."+lstr(i+1)+".6. ����樭᪠� ॠ������� � (���) ᠭ��୮-����⭮� ��祭�� �����祭�: "+f3_inf_DDS_karta(mm_danet,&m1var,,ub,ue)
      case k == 14
        s6 := left(s6,len(s6)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_usl,&m1var,,ub,ue)
      case k == 15
        s6 := left(s6,len(s6)-1)+'; '+f3_inf_DDS_karta(mm_uch1,&m1var,,ub,ue)
    endcase
  next
  frd->(eval(blk,s))
  frd->(eval(blk,s1))
  frd->(eval(blk,s2))
  frd->(eval(blk,s3))
  frd->(eval(blk,s4))
  frd->(eval(blk,s5))
  frd->(eval(blk,s6))
next
if m1invalid1 == 0
  m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
  minvalid3 := minvalid4 := minvalid7 := ctod("")
endif
if empty(minvalid7)
  m1invalid8 := -1
endif
s := st+'16.7. ������������: '+f3_inf_DDS_karta(mm_danet,m1invalid1,,ub,ue)
s := left(s,len(s)-1)+'; �᫨ "��": '+f3_inf_DDS_karta(mm_invalid2,m1invalid2,,ub,ue)
s := left(s,len(s)-1)+'; ��⠭������ ����� (���) '+iif(empty(minvalid3), replicate("_",15), ub+full_date(minvalid3)+ue)
s += '; ��� ��᫥����� �ᢨ��⥫��⢮����� '+iif(empty(minvalid4), replicate("_",15), ub+full_date(minvalid4)+ue)+'.'
frd->(eval(blk,s))
/*s := st+'16.7.1. �����������, ���᫮���訥 ������������� �����������:'
frd->(eval(blk,s))
mm_invalid5[6,1] := "������� �஢�, �஢�⢮��� �࣠��� � �⤥��� ����襭��, ��������騥 ���㭭� ��堭���;"
mm_invalid5[7,1] := "������� �����ਭ��� ��⥬�, ����ன�⢠ ��⠭�� � ����襭�� ������ �����,"
atail(mm_invalid5)[1] := "��᫥��⢨� �ࠢ�, ��ࠢ����� � ��㣨� �������⢨� ���譨� ��稭)"
s := st+'('+f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.���� ����襭�� � ���ﭨ� ���஢��:'
frd->(eval(blk,s))
s := st+f3_inf_DDS_karta(mm_invalid6,m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. �������㠫쭠� �ணࠬ�� ॠ�����樨 ॡ����-��������:'
frd->(eval(blk,s))
s := st+'��� �����祭��: '+iif(empty(minvalid7), replicate("_",15), ub+full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'�믮������ �� ������ ��ᯠ��ਧ�樨: '+f3_inf_DDS_karta(mm_invalid8,m1invalid8,,ub,ue)
frd->(eval(blk,s))*/
s := st+"16.8. ��㯯� ���ﭨ� ���஢��: "+f3_inf_DDS_karta(mm_gruppa,mGRUPPA,,ub,ue)
frd->(eval(blk,s))
s := st+"16.9. ����樭᪠� ��㯯� ��� ����⨩ 䨧��᪮� �����ன: "
s += f3_inf_DDS_karta(mm_gr_fiz,m1GR_FIZ,,ub,ue)
frd->(eval(blk,s))
/*s := st+'16.10'+'. �஢������ ��䨫����᪨� �ਢ����:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1)
  if m1privivki1 == mm_privivki1[j,2]
    s += ub
  endif
  s += mm_privivki1[j,1]
  if m1privivki1 == mm_privivki1[j,2]
    s += ue
  endif
  if mm_privivki1[j,2] == 0
    s += "; "
  else
    s += ": "+f3_inf_DDS_karta(mm_privivki2,iif(m1privivki1==mm_privivki1[j,2],m1privivki2,-1),,ub,ue,.f.)+"; "
  endif
next
s += '�㦤����� � �஢������ ���樭�樨 (ॢ��樭�樨) � 㪠������ ������������ �ਢ���� (�㦭�� ����ભ���): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate("_",sh)+"."
frd->(eval(blk,s))*/
s := st+'17. ���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன: '
k := 3
if !empty(mrek_form)
  k := 1
  s += ub+alltrim(mrek_form)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
s := st+'18. ���������樨 �� �஢������ ��ᯠ��୮�� �������, '+;
        '��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭��: '
k := 5
if !empty(mrek_disp)
  k := 2
  s += ub+alltrim(mrek_disp)+ue
endif
frd->(eval(blk,s))
for i := 1 to k
  s := replicate("_",sh)+iif(i==k, ".", "")
  frd->(eval(blk,s))
next
//
adbf := {{"name","C",60,0},;
         {"data","C",10,0},;
         {"rezu","C",17,0}}
dbcreate(fr_data+"1",adbf)
use (fr_data+"1") new alias FRD1
dbcreate(fr_data+"2",adbf)
use (fr_data+"2") new alias FRD2
/*arr := f4_inf_DNL_karta(1)
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i,1]
  frd1->data := full_date(arr[i,2])
next
arr := f4_inf_DNL_karta(2)
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i,1]
  frd2->data := full_date(arr[i,2])
  frd2->rezu := arr[i,3]
next*/
//
close databases
call_fr("mo_030pou17")
return NIL

***** 02.06.20
Function f4_inf_DNL_karta(par,_etap)
Local i, k := 0, fl, arr := {}, ar
if type("mperiod") == "N" .and. between(mperiod,1,31)
  //
else
  mperiod := ret_period_PN(mdate_r,mn_data,mk_data,,@k)
endif
if !between(mperiod,1,31)
  mperiod := k
endif
if !between(mperiod,1,31)
  mperiod := 31
endif
np_oftal_2_85_21(mperiod,mk_data)
ar := np_arr_1_etap[mperiod]
if par == 1
  if iif(_etap==nil, .t., _etap==1)
    for i := 1 to count_pn_arr_osm-1
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(np_arr_osmotr[i,2])
        fl := (mpol == np_arr_osmotr[i,2])
      endif
      if fl
        fl := (!empty(ar[4]) .and. ascan(ar[4],np_arr_osmotr[i,1]) > 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {np_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
  endif
  aadd(arr, {"������� (��� ��饩 �ࠪ⨪�)", MDATEp1, "", -1, 1})
  if metap == 2 .and. iif(_etap==nil, .t., _etap==2)
    for i := 1 to count_pn_arr_osm-1
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(np_arr_osmotr[i,2])
        fl := (mpol == np_arr_osmotr[i,2])
      endif
      if fl
        fl := (ascan(ar[4],np_arr_osmotr[i,1]) == 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {np_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
    aadd(arr, {"������� (��� ��饩 �ࠪ⨪�)", MDATEp2, "", -2, 1})
  endif
else
  for i := 1 to count_pn_arr_iss // ��᫥�������
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    fl := .t.
    if fl .and. !empty(np_arr_issled[i,2])
      fl := (mpol == np_arr_issled[i,2])
    endif
    if fl
      fl := (ascan(ar[5],np_arr_issled[i,1]) > 0)
    endif
    if fl .and. !emptyany(&mvard,&mvart)
      k := 0
      do case
        case i == 1 // {"3.5.4"   ,   , "�㤨������᪨� �ਭ���",0,64,{1111,111101} },;
          k := 15
        case i == 2 // {"4.2.153" ,   , "��騩 ������ ���",0,34,{1107,1301,1402,1702} },;
          k := 2
        //case i == 3 // {"4.8.1"   ,   , "��騩 ������ ����",0,34,{1107,1301,1402,1702} },;
          //k := 3
        //case i == 4 // {"4.11.136",   , "������᪨� ������ �஢�",0,34,{1107,1301,1402,1702} },;
        case i == 3 // {"4.11.136",   , "������᪨� ������ �஢�",0,34,{1107,1301,1402,1702} },;
          k := 1
        //case i == 5 // {"4.12.169",   , "��᫥������� �஢�� ���� � �஢�",0,34,{1107,1301,1402,1702} },;
          //k := 4
        //case between(i,6,16) // {"4.14.67" ,   , "�஫��⨭ (��ମ�)",1,34,{1107,1301,1402,1702} },;
          //k := 5
        //case between(i,17,21) // {"4.26.1"  ,   , "�����⠫�� �ਭ��� �� �����८�",0,34,{1107,1301,1402,1702} },;
        case between(i,4,8) // {"4.26.1"  ,   , "�����⠫�� �ਭ��� �� �����८�",0,34,{1107,1301,1402,1702} },;
          k := 14
        //case i == 22 // {"7.61.3"  ,   , "���ண��� ������ � 1-� �஥�樨",0,78,{1118,1802} },;
          //k := 12
        //case i == 23 // {"8.1.1"   ,   , "��� ��������� ����� (����ᮭ�����)",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 9 // {"8.1.1"   ,   , "��� ��������� ����� (����ᮭ�����)",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 11
        //case i == 24 // {"8.1.2"   ,   , "��� �⮢����� ������",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          //k := 8
        case i == 12 // {"8.1.6"   , 12, "��� ��祪",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 18
        //case i == 25 // {"8.1.3"   ,   , "��� ���",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 10 // {"8.1.3"   ,   , "��� ���",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 7
        //case i == 26 // {"8.1.4"   ,   , "��� ⠧����७��� ���⠢��",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 11 // {"8.1.4"   ,   , "��� ⠧����७��� ���⠢��",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 10
        //case i == 27 // {"8.2.1"   ,   , "��� �࣠��� ���譮� ������",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
        case i == 13 // {"8.2.1"   ,   , "��� �࣠��� ���譮� ������",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 6
        //case between(i,28,29) // {"8.2.2"   ,"�", "��� �࣠��� ९த�⨢��� ��⥬�",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          //k := 9
        //case i == 30 // {"13.1.1"  ,   , "�����ப�न�����",0,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202} },;
        case i == 14 // {"13.1.1"  ,   , "�����ப�न�����",0,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202} },;
          k := 13
      endcase
      aadd(arr, {np_arr_issled[i,3], &mvard, &mvarr, i, k})
    endif
  next
  // ������� "2.4.2" "�ਭ��� �� ������ ����.ࠧ����"
  i := count_pn_arr_osm  // ��᫥���� ������� ���ᨢ�
  mvart := "MTAB_NOMov"+lstr(i)
  mvard := "MDATEo"+lstr(i)
  if (!empty(ar[4]) .and. ascan(ar[4],np_arr_osmotr[i,1]) > 0) .and. !emptyany(&mvard,&mvart)
    aadd(arr, {np_arr_osmotr[i,3], &mvard, "", i, 21})
  endif
endif
return arr

***** 25.11.13
Function f5_inf_DNL_karta(i)
Local k := 0
do case
  case i == 14 // {"2.85.16","�", "�����-���������", 2, {1101} },;
    k := 11
  case i == 15 // {"2.85.17","�", "���᪨� �஫��-���஫��", 19, {112603,113502} },;
    k := 10
  case i == 16 // {"2.85.18",   , "���᪨� ����", 20, {1135} },;
    k := 4
  case i == 17 // {"2.85.19",   , "�ࠢ��⮫��-��⮯��", 100, {1123} },;
    k := 6
  case i == 18 // {"2.85.20",   , "���஫��", 53, {1109} },;
    k := 2
  case i == 19 // {"2.85.21",   , "��⠫쬮���", 65, {1112} },;
    k := 3
  case i == 20 // {"2.85.22",   , "�⮫�ਭ�����", 64, {1111,111101} },;
    k := 5
  case i == 21 // {"2.85.23",   , "���᪨� �⮬�⮫��", 86, {140102} },;
    k := 8
  case i == 22 // {"2.85.24",   , "���᪨� �����ਭ����", 21, {1127,112702,113402} },;
    k := 9
  case i == 23 // {"2.4.1"  ,   , "��娠��", 72, {1115} };
    k := 7
endcase
return k

***** 09.06.20 �ਫ������ � ����� ���� "������" �1025 �� 08.07.2019�.
Function f21_inf_DNL(par)
Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, adbf, as, i, j, k, sh, HH := 40, n, n_file := "svod_dnl"+stxt
if (arr_m := year_month(,,,5)) != NIL
  if arr_m[1] < 2020
    return func_error(4,"������ �ଠ �⢥ত��� � 2020 ����")
  endif
  mywait()
  if f0_inf_DNL(arr_m,par > 1,par == 3,{301,302})
    R_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
    adbf := {{"ti","N",1,0},;
             {"stroke","C",8,0},;
             {"mm","N",2,0},;
             {"mm1","N",1,0},;
             {"vsego","N",6,0},;
             {"vsego1","N",6,0},;
             {"vsegoM","N",6,0},;
             {"g1","N",6,0},;
             {"g2","N",6,0},;
             {"g3","N",6,0},;
             {"g4","N",6,0},;
             {"g4inv","N",6,0},;
             {"g5","N",6,0},;
             {"g5inv","N",6,0},;
             {"mg1","N",6,0},;
             {"mg2","N",6,0},;
             {"mg3","N",6,0},;
             {"mg4","N",6,0},;
             {"sv","N",6,0},;
             {"so","N",6,0},;
             {"v2","N",6,0},;
             {"m15","N",6,0},;
             {"m15s","N",6,0},;
             {"m15pos","N",6,0},;
             {"m15poss","N",6,0},;
             {"m15a","N",6,0},;
             {"m15p","N",6,0},;
             {"m15ps","N",6,0},;
             {"m15p1","N",6,0},;
             {"m15p1s","N",6,0},;
             {"m15e","N",6,0},;
             {"g15","N",6,0},;
             {"g15s","N",6,0},;
             {"g15pos","N",6,0},;
             {"g15poss","N",6,0},;
             {"g15g","N",6,0},;
             {"g15p","N",6,0},;
             {"g15ps","N",6,0},;
             {"g15p1","N",6,0},;
             {"g15p1s","N",6,0},;
             {"g15e","N",6,0},;
             {"g18","N",6,0},;
             {"g18s","N",6,0},;
             {"m18","N",6,0},;
             {"m18s","N",6,0}}         
              
    dbcreate(cur_dir+"tmp1",adbf)
    use (cur_dir+"tmp1") new
    index on str(mm,2) to (cur_dir+"tmp1")
    append blank
    tmp1->mm := 0 ; tmp1->stroke := "�ᥣ�"
    append blank
    tmp1->mm := 1 ; tmp1->stroke := "0-14 ���"
    append blank
    tmp1->mm := 2 ; tmp1->stroke := "�� 1 �."
    append blank
    tmp1->mm := 3 ; tmp1->stroke := "15-17 �."
    append blank
    tmp1->mm := 4 ; tmp1->stroke := "15-17 �"
    append blank
    tmp1->mm := 5 ; tmp1->stroke := "誮�쭨��"
    adbf := {{"ti","N",1,0},;
             {"g1","N",6,0},;
             {"g2","N",6,0},;
             {"g3","N",6,0},;
             {"g31","N",6,0},;
             {"g32","N",6,0},;
             {"g4","N",6,0},;
             {"g5","N",6,0},;
             {"g6","N",6,0},;
             {"g7","N",6,0},;
             {"g8","N",6,0},;
             {"g9","N",6,0},;
             {"g10","N",6,0},;
             {"g11","N",6,0},;
             {"g12","N",6,0},;
             {"g13","N",6,0},;
             {"g14","N",6,0},;
             {"g15","N",6,0},;
             {"g7n","N",6,0},;
             {"g8n","N",6,0},;
             {"g12n","N",6,0},;
             {"g13n","N",6,0},;
             {"g14n","N",6,0},;
             {"g16n","N",6,0}}
    dbcreate(cur_dir+"tmp2",adbf)
    use (cur_dir+"tmp2") new
    index on str(ti,1) to (cur_dir+"tmp2")
    R_Use(dir_server+"mo_schoo",,"SCH")
    R_Use(dir_server+"schet_",,"SCHET_")
    R_Use(dir_server+"uslugi",,"USL")
    R_Use_base("human_u")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    set relation to recno() into HUMAN_, to kod_k into KART_
    use (cur_dir+"tmp") new
    set relation to kod into HUMAN
    go top
    do while !eof()
      @ maxrow(),0 say str(recno()/lastrec()*100,6,2)+"%" color cColorWait
      f1_f21_inf_DNL(tmp->kod,tmp->kod_k)
      select TMP
      skip
    enddo
    close databases
    arr_title := {;
"��������������������������������������������������������������������������������������������������������������������",;
"��⥣�- ���᫮ ��⥩ I�⠯���।������ �� ��㯯�� ���஢�� I �⠯ ����-�� �� ���.��㯯������砥� I�Ⳮ���.������",;
"ਨ     �����������������������������������������������������������������������������������������������Ĵ��   �訫� ",;
"��⥩   ��ᥣ�� ᥫ�����/��  1  �  2  �  3  �  4  �4���.�  5  �5���.��᭮��������ᯥ怳ᯥ恳��ॣ������2 ��.�2 ��.",;
"��������������������������������������������������������������������������������������������������������������������",;
"        �  5  � 5.1 �  6  �  7  �  8  �  9  �  10 � 10.1�  11 � 11.1�  12 �  13 �  14 �  15 �  16 �  17 �  18 �  19 ",;
"��������������������������������������������������������������������������������������������������������������������"}
    sh := len(arr_title[1])
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl('�ਫ������ � ����� ���� "������"',sh))
    add_string(padl("�1025 �� 08.07.2019�.",sh))
    add_string("")
    add_string(center("[ "+charrem("~",mas1pmt[par])+" ]",sh))
    add_string(center("("+arr_m[4]+")",sh))
    use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
    add_string("")
    add_string(center("�������� � ��䨫����᪨� �ᬮ��� ��ᮢ��襭����⭨�",sh))
    add_string("")
    aeval(arr_title, {|x| add_string(x) } )
    go top
    do while !eof()
      s := tmp1->stroke + put_val(tmp1->vsego,6)+;
               put_val(tmp1->vsego1,6)+;
               put_val(tmp1->vsegoM,6)+;
               put_val(tmp1->g1,6)+;
               put_val(tmp1->g2,6)+;
               put_val(tmp1->g3,6)+;
               put_val(tmp1->g4,6)+;
               put_val(tmp1->g4inv,6)+;
               put_val(tmp1->g5,6)+;
               put_val(tmp1->g5inv,6)+;
               put_val(tmp1->mg1,6)+;
               put_val(tmp1->mg2,6)+;
               put_val(tmp1->mg3,6)+;
               put_val(tmp1->mg4,6)+;
               put_val(tmp1->sv,6)+;
               put_val(tmp1->so,6)+;
               put_val(tmp1->v2,6)+;
               put_val(tmp1->v2,6)
               //put_val(tmp1->g31,6)+;
               //put_val(tmp1->g32,6)+;
      if verify_FF(HH-1,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      add_string(replicate("�",sh))
      skip
    enddo
    //
    verify_FF(HH-12,.t.,sh)
/*    arr_title := {;
"��������������������������������������������������������������������������������",;
"        �      ���� (15-17 ���)            �        ����誨 (15-17 ���)        ",;
"        ������������������������������������������������������������������������",;
"        �䠪� �ᬮ�.(祫.)���⮫� ��  �����.�䠪� �ᬮ�.(祫.)���⮫� ��  �����.",;
"        �����������������Ĵ९�.� ��.6��� II�����������������Ĵ९�.� ��.6��� II",;
"        ��ᥣ�� ᥫ�����ள���.� ᥫ���⠯ ��ᥣ�� ᥫ�����������.� ᥫ���⠯ ",;
"��������������������������������������������������������������������������������",;
"        �  3  �  4  �  5  �  6  �  7  �  8  �  3  �  4  �  5  �  6  �  7  �  8  ",;
"��������������������������������������������������������������������������������"}*/
    arr_title := {;
"�����������������������������������������������������������������������������������������������������������������������������������������������",;
"            ���� (15-17 ���)                                          �                         ����誨 (15-17 ���)                           ",;
"�����������������������������������������������������������������������������������������������������������������������������������������������",;
"     䠪� �ᬮ�.(祫.)       ���⮫� ��  ��� 7 � ��  �����.�����.� ��  �      䠪� �ᬮ�.(祫.)      ���⮫� ��  ��� 14� ��  �����.�����.� ��  ",;
"����������������������������Ĵ९�.� ��.7�����-� 7.2 ��� II��� �.�  9  �����������������������������Ĵ९�.���.14�����-�14.2 ��� II��� �.� 18  ",;
"�ᥣ�� ᥫ������ ᥫ�����ள���.� ᥫ����  � ᥫ���⠯ ��� 7 � ᥫ���ᥣ�� ᥫ������ ᥫ�����������.� ᥫ����  � ᥫ���⠯ ��� 16� ᥫ�",;
"�����������������������������������������������������������������������������������������������������������������������������������������������",;
"  3  �  4  �  5  � 5.1 �  6  �  7  � 7.1 � 7.2 � 7.3 �  8  �  9  � 9.1 �  13 � 13.1�  14 � 14.1�  15 �  16 � 16.1� 16.2� 16.3� 17  � 18  � 18.1",;
"�����������������������������������������������������������������������������������������������������������������������������������������������"}
    sh := len(arr_title[1])
    i := 1
    add_string("")
    add_string("��ᮢ��襭����⭨� � ������ 15-17 ���")
    aeval(arr_title, {|x| add_string(x) } )
    go top
    s :=   put_val(tmp1->m15,5)+;
           put_val(tmp1->m15s,6)+;
           put_val(tmp1->m15pos,6)+;
           put_val(tmp1->m15poss,6)+;
           put_val(tmp1->m15a,6)+;
           put_val(tmp1->m15p,6)+;
           put_val(tmp1->m15ps,6)+;
           put_val(tmp1->m15p1,6)+;
           put_val(tmp1->m15p1s,6)+;
           put_val(tmp1->m15e,6)+;
           put_val(tmp1->m18,6)+;
           put_val(tmp1->m18s,6)+;
           put_val(tmp1->g15,6)+;
           put_val(tmp1->g15s,6)+;
           put_val(tmp1->g15pos,6)+;
           put_val(tmp1->g15poss,6)+;
           put_val(tmp1->g15g,6)+;
           put_val(tmp1->g15p,6)+;
           put_val(tmp1->g15ps,6)+;
           put_val(tmp1->g15p1,6)+;
           put_val(tmp1->g15p1s,6)+;
           put_val(tmp1->g15e,6)+;
           put_val(tmp1->g18,6)+;
           put_val(tmp1->g18s,6)
    if verify_FF(HH-1,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
    add_string(replicate("�",sh))
    //
    verify_FF(HH-12,.t.,sh)
    arr_title := {;
"����������������������������������������������������������������������������������������������������������������������������������������",;
"         �    �ᬮ�७�    ��� ��� ᥫ�᪨� ���ᬮ-��ᬮ-�����-�                  �� ���                        �䠪�-��� �9��� �9���   ",;
"���⨭-  �����������������������������������Ĵ�७���७����  ������������������������������������������������Ĵ ��� �����볭��-���.20",;
"����     �     ���᫥�� �㡳     ���᫥�� �㡳�஫-�����-�����䳡�����     �  1�2 ��������������������������������᪠���   ��   �ᥫ�-",;
"         ��ᥣ��18:00����� ��ᥣ��18:00����� ����ள����-���樮��஢�� ��� � �⠤.��-��賣��� ��������࣠���࣠������-����.����-�᪨� ",;
"         �     �     �     �     �     �     ����������  ���� �����     ��� �11�ᮥ�.��ਤ.����.���堭���饢���  �����.����  ���⥫",;
"����������������������������������������������������������������������������������������������������������������������������������������",;
"         �  1  �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  � 10  �  11 �  12  �  13 �  14 �  15 �  16 �  17 �  18 �  19 �  20 �  21 ",;
"����������������������������������������������������������������������������������������������������������������������������������������"}
//           1     2     3     4     5     6     7n    8n    7     8     9     0                        11    12          13    14    15
    sh := len(arr_title[1])
    add_string("")
    add_string('� ࠬ��� ��樮���쭮�� �஥�� "��ࠢ���࠭����"')
    aeval(arr_title, {|x| add_string(x) } )
    use (cur_dir+"tmp2") index (cur_dir+"tmp2") new
    go top
    do while !eof()
      s := padr({"0-14 ���","15-17 ���","�ᥣ�"}[tmp2->ti],9)+;
           put_val(tmp2->g1,6)+;
           put_val(tmp2->g2,6)+;
           put_val(tmp2->g3,6)+;
           put_val(tmp2->g4,6)+;
           put_val(tmp2->g5,6)+;
           put_val(tmp2->g6,6)+;
           put_val(tmp2->g7n,6)+;
           put_val(tmp2->g8n,6)+;
           put_val(tmp2->g7,6)+;
           put_val(tmp2->g8,6)+;
           put_val(tmp2->g9,6)+;
           put_val(0,7)+;
           put_val(tmp2->g12n,6)+;
           put_val(tmp2->g13n,6)+;
           put_val(tmp2->g14n,6)+;
           put_val(tmp2->g11,6)+;
           put_val(tmp2->g12,6)+;
           put_val(tmp2->g16n,6)+;
           put_val(tmp2->g13,6)+;
           put_val(tmp2->g14,6)+;
           put_val(tmp2->g15,6)
      if verify_FF(HH-1,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s)
      add_string(replicate("�",sh))
      skip
    enddo
    //
    fclose(fp)
    close databases
    Private yes_albom := .t.
    viewtext(n_file,,,,(.t.),,,3)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 20.06.20
Function f1_f21_inf_DNL(Loc_kod,kod_kartotek) // ᢮���� ���ଠ��
Local ii, im, i, j, k, s, sumr := 0, ar := {0}, ltip_school := -1, ar15[26],;
      is_2 := .f., ad := {}, arr, a3 := {}, fl_ves := .T.
Private m1tip_school := -1, m1school := 0, mvozrast, mdvozrast, mgruppa := 0, m1GR_FIZ := 1, m1invalid1 := 0
Private mvar, m1var, m1FIZ_RAZV1, m1napr_stac := 0
afill(ar15,0)
mvozrast := count_years(human->date_r,human->n_data)
mdvozrast := year(human->n_data) - year(human->date_r)
for i := 1 to 5
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(3)
    endif
  next
next
ii := 1
is_2 := (human->ishod == 302) // �� ��ன �⠯
read_arr_PN(Loc_kod)
if human->pol == "�"
  if m1napr_stac > 0
    ar15[23] ++ 
    if f_is_selo() 
      ar15[24] ++ 
    endif 
  endif
else
  if m1napr_stac > 0
    ar15[25] ++ 
    if f_is_selo() 
      ar15[26] ++ 
    endif 
  endif
endif
//
mGRUPPA := human_->RSLT_NEW - 331//L_BEGIN_RSLT
if mvozrast == 0
  aadd(ar,2)
endif
if mdvozrast < 15
  aadd(ar,1)
else
  aadd(ar,3)
  if human->pol == "�"
    aadd(ar,4)
  endif
endif
if mdvozrast > 6 // 誮�쭨�� ?
  aadd(ar,5)
endif
  if m1school > 0
    select SCH
    goto (m1school)
    ltip_school := sch->tip
  endif
  for i := 1 to 5
    j := 0
    for k := 1 to 16
      s := "diag_16_"+lstr(i)+"_"+lstr(k)
      mvar := "m"+s
      if k == 1
        if !empty(&mvar)
          arr := array(16) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
          if len(arr[1]) > 5
            arr[1] := left(arr[1],5)
          endif
          aadd(ad,arr) ; j := len(ad)
        endif
      elseif j > 0
        m1var := "m1"+s
        ad[j,k] := &m1var
      endif
    next
  next
  //
  arr := array(24) ; afill(arr,0) ; arr[16] := 3
  arr[1] := 1
  if (is_selo := f_is_selo())
    arr[4] := 1
  endif
  if dow(human->k_data) == 7 // �㡡��
    arr[3] := 1
    if is_selo
      arr[6] := 1
    endif
  endif

  for i := 1 to len(ad)
    if !(left(ad[i,1],1) == "A" .or. left(ad[i,1],1) == "B") .and. ad[i,2] > 0 // ����䥪樮��� ����������� ���.�����
      arr[7] ++
      if left(ad[i,1],1) == "I" // ������� ��⥬� �஢����饭��
        arr[8] ++
      elseif left(ad[i,1],1) == "J" // ������� �࣠��� ��堭��
        arr[11] ++
      elseif left(ad[i,1],1) == "K" // ������� �࣠��� ��饢�७��
        arr[12] ++
      elseif left(ad[i,1],1) == "M" // ������� ���⭮-���筮� ��⥬�
        arr[19] ++
      elseif left(ad[i,1],1) == "H" // ������� ����
        arr[20] ++
      elseif left(ad[i,1],1) == "E" // ������� �����ਭ������
        arr[21] ++
      endif
      if left(ad[i,1],3) == "E78"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "R73.9"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "Z72.0"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "Z72.4"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "R63.5"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "Z72.3"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "Z72.1"
        arr[22] ++
        fl_ves := .F.
      elseif left(ad[i,1],5) == "Z72.2"
        arr[22] ++
        fl_ves := .F.
      endif
      // ���� ������ ����� ⥫�
      if left(ad[i,1],1) == "C" .or. between(left(ad[i,1],3),"D00","D09") // ��� ����� ���� ��������  .or. between(left(ad[i,1],3),"D45","D47")
        arr[9] ++
      endif
      // ��������
      if ad[i,3] == 2 // ���.����.��⠭������ �����
        arr[13] ++
      endif
      if ad[i,10] == 1 // 1-��祭�� �����祭�
        arr[14] ++ // ?? �뫮 ���� ��祭��
        if is_selo
          arr[15] ++
        endif
      endif
    endif
  next
  aadd(a3,aclone(arr))
  if between(mdvozrast,15,17)
    arr[16] := 2
    j := iif(human->pol == "�", 1, 7)
    ar15[j] ++
    if is_selo
      ar15[j+1] ++
    endif
    if (i := ascan(ad,{|x| left(x[1],1) == "N" })) > 0 // ��⮫���� �࣠��� ९த�⨢��� ��⥬�
      ar15[j+3] ++
      if is_selo
        ar15[j+4] ++
      endif
      if ad[i,2] > 0 // ����������� ���.�����
        if j == 1
          ar15[13] ++
          if is_selo
            ar15[14] ++
          endif
        else
          ar15[15] ++
          if is_selo
            ar15[16] ++
          endif
        endif
      endif
    endif
    if is_2
      ar15[j+5] ++
    endif
    fl := .f.
    select HU
    find (str(Loc_kod,7))
    do while hu->kod == Loc_kod .and. !eof()
      if eq_any(hu_->PROFIL,19,136)
        fl := .t.
      endif
      usl->(dbGoto(hu->u_kod))
      if empty(lshifr := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data))
        lshifr := usl->shifr
      endif
      if left(lshifr,2) == "2."  // ��祡�� ���
        if j == 1
          ar15[17] ++
          if is_selo
            ar15[18] ++
          endif
        else
          ar15[19] ++
          if is_selo
            ar15[20] ++
          endif
        endif
        if hu_->PROFIL == 19
          arr[17] ++
        endif
        if hu_->PROFIL == 136
          arr[18] ++
        endif
      endif
      select HU
      skip
    enddo
    if fl
      ar15[j+2] ++
    endif
  else
    arr[16] := 1
  endif
  aadd(a3,aclone(arr))
//
//aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",䨧��᪮� ࠧ��⨥ 0-��ଠ�쭮�, � �⪫�����ﬨ: 1-����� ����� ⥫�, 2-����⮪ ����� ⥫�, 3-������ ���, 4-��᮪�� ���
if m1fiz_razv1 == 1
  if fl_ves
    arr[22] ++
  endif
endif
//
for j := 1 to len(a3)
  select TMP2
  find (str(a3[j,16],1))
  if !found()
    append blank
    tmp2->ti := a3[j,16]
  endif
  for i := 1 to 15
    pole := "tmp2->g"+lstr(i)
    &pole := &pole + a3[j,i]
  next
  tmp2->g7n  := tmp2->g7n  + arr[17]
  tmp2->g8n  := tmp2->g8n  + arr[18]
  tmp2->g12n := tmp2->g12n + arr[19]
  tmp2->g13n := tmp2->g13n + arr[20]
  tmp2->g14n := tmp2->g14n + arr[21]
  tmp2->g16n := tmp2->g16n + arr[22]
next
//
for j := 1 to len(ar)
  im := ar[j]
  select TMP1
  find (str(im,2))
  tmp1->vsego ++
  if is_selo
    tmp1->vsego1 ++
  endif
  tmp1->m15  += ar15[1]
  tmp1->m15s += ar15[2]
  tmp1->m15pos += ar15[17]
  tmp1->m15poss += ar15[18]
  tmp1->m15a += ar15[3]
  tmp1->m15p += ar15[4]
  tmp1->m15ps += ar15[5]
  tmp1->m15p1 += ar15[13]
  tmp1->m15p1s += ar15[14]
  tmp1->m15e += ar15[6]
  tmp1->g15  += ar15[7]
  tmp1->g15s += ar15[8]
  tmp1->g15pos += ar15[19]
  tmp1->g15poss += ar15[20]
  tmp1->g15g += ar15[9]
  tmp1->g15p += ar15[10]
  tmp1->g15ps += ar15[11]
  tmp1->g15p1 += ar15[15]
  tmp1->g15p1s += ar15[16]
  tmp1->g15e += ar15[12]
  tmp1->g18 += ar15[23]
  tmp1->g18s += ar15[24]
  tmp1->m18 += ar15[25]
  tmp1->m18s += ar15[26]
  if between(mgruppa,1,5)
    pole := "tmp1->g"+lstr(mgruppa)
    &pole := &pole + 1
    if between(mgruppa,4,5) .and. m1invalid1 == 1 // ������������-��
      pole += "inv"
      &pole := &pole + 1
    endif
    if /*ltip_school == 0 .and.*/ between(m1GR_FIZ,1,4)
      pole := "tmp1->mg"+lstr(m1GR_FIZ)
      &pole := &pole + 1
    endif
    if is_2 // I � II �⠯
      tmp1->v2 ++
    endif
  endif
  if human->schet > 0
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      tmp1->sv ++
      sumr := 0
      select RPDSH
      find (str(Loc_kod,7))
      do while rpdsh->KOD_H == Loc_kod .and. !eof()
        sumr += rpdsh->S_SL
        skip
      enddo
      if round(human->cena_1,2) == round(sumr,2) // ��������� ����祭
        tmp1->so ++
      endif
    endif
  endif
next
return NIL

***** 25.03.18
Function inf_DNL_030poo(is_schet)
Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := "f_030poo"+stxt, d1, d2
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  if arr_m[1] < 2018
    return func_error(4,"������ �ଠ �⢥ত��� � 2018 ����")
  endif
  mywait()
  if f0_inf_DNL(arr_m,is_schet > 1,is_schet == 3)
    Private arr_deti[6] ; afill(arr_deti,0)
    Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
    Private arr_vozrast := {;
      {3,0,17};
     }
    Private arr1vozrast := {;
      { 0,17},;
      { 0, 4},;
      { 0,14},;
      { 5, 9},;
      {10,14},;
      {15,17};
     }
    Private arr_4 := {;
      {"1","������� ��䥪樮��� � ��ࠧ��...","A00-B99",,},;
      {"1.1","�㡥�㫥�","A15-A19",,},;
      {"1.2","���-��䥪��, ����","B20-B24",,},;
      {"2","������ࠧ������","C00-D48",,},;
      {"3","������� �஢� � �஢�⢮��� �࣠��� ...","D50-D89",,},;
      {"3.1","������","D50-D53",,},;
      {"4","������� �����ਭ��� ��⥬�, ����ன�⢠...","E00-E90",,},;
      {"4.1","���� ������","E10-E14",,},;
      {"4.2","�������筮��� ��⠭��","E40-E46",,},;
      {"4.3","���७��","E66",,},;
      {"4.4","����প� �������� ࠧ����","E30.0",,},;
      {"4.5","�०���६����� ������� ࠧ��⨥","E30.1",,},;
      {"5","����᪨� ����ன�⢠ � �����...","F00-F99",,},;
      {"5.1","��⢥���� ���⠫����","F70-F79",,},;
      {"6","������� ��ࢭ�� ��⥬�, �� ���:","G00-G98",,},;
      {"6.1","�ॡࠫ�� ��ࠫ�� � ��㣨� ...","G80-G83",,},;
      {"7","������� ����� � ��� �ਤ��筮�� ������","H00-H59",,},;
      {"8","������� �� � ��楢������ ����⪠","H60-H95",,},;
      {"9","������� ��⥬� �஢����饭��","I00-I99",,},;
      {"10","������� �࣠��� ��堭��, �� ���:","J00-J99",,},;
      {"10.1","��⬠, ��⬠��᪨� �����","J45-J46",,},;
      {"11","������� �࣠��� ��饢�७��","K00-K93",,},;
      {"12","������� ���� � ��������� �����⪨","L00-L99",,},;
      {"13","������� ���⭮-���筮� ...","M00-M99",,},;
      {"13.1","��䮧, ��म�, ᪮����","M40-M41",,},;
      {"14","������� ��祯������ ��⥬�, �� ���:","N00-N99",,},;
      {"14.1","������� ��᪨� ������� �࣠���","N40-N51",,},;
      {"14.2","����襭�� �⬠ � �ࠪ�� �������権","N91-N94.5",,},;
      {"14.3","��ᯠ��⥫�� ����������� ...","N70-N77",,},;
      {"14.4","����ᯠ��⥫�� ������� ...","N83",,},;
      {"14.5","������� ����筮� ������","N60-N64",,},;
      {"15","�⤥��� ���ﭨ�, �������...","P00-P96",,},;
      {"16","�஦����� �������� (��ப� ...","Q00-Q99",,},;
      {"16.1","ࠧ���� ��ࢭ�� ��⥬�","Q00-Q07",,},;
      {"16.2","��⥬� �஢����饭��","Q20-Q28",,},;
      {"16.3","���᪨� ������� �࣠���","Q50-Q52",,},;
      {"16.4","��᪨� ������� �࣠���","Q53-Q55",,},;
      {"16.5","���⭮-���筮� ��⥬�","Q65-Q79",,},;
      {"17","�ࠢ��, ��ࠢ����� � �������...","S00-T98",,},;
      {"18","��稥","",,},;
      {"19","����� �����������","A00-T98",,};
     }
    for n := 1 to len(arr_4)
      if "-" $ arr_4[n,3]
        d1 := token(arr_4[n,3],"-",1)
        d2 := token(arr_4[n,3],"-",2)
      else
        d1 := d2 := arr_4[n,3]
      endif
      arr_4[n,4] := diag_to_num(d1,1)
      arr_4[n,5] := diag_to_num(d2,2)
    next
    dbcreate(cur_dir+"tmp4",{{"name","C",100,0},;
                             {"diagnoz","C",20,0},;
                             {"stroke","C",4,0},;
                             {"ns","N",2,0},;
                             {"diapazon1","N",10,0},;
                             {"diapazon2","N",10,0},;
                             {"tbl","N",1,0},;
                             {"k04","N",8,0},;
                             {"k05","N",8,0},;
                             {"k06","N",8,0},;
                             {"k07","N",8,0},;
                             {"k08","N",8,0},;
                             {"k09","N",8,0},;
                             {"k10","N",8,0},;
                             {"k11","N",8,0}})
    use (cur_dir+"tmp4") new alias TMP
    for i := 1 to len(arr_vozrast)
      for n := 1 to len(arr_4)
        append blank
        tmp->tbl := arr_vozrast[i,1]
        tmp->stroke := arr_4[n,1]
        tmp->name := arr_4[n,2]
        tmp->ns := n
        tmp->diagnoz := arr_4[n,3]
        tmp->diapazon1 := arr_4[n,4]
        tmp->diapazon2 := arr_4[n,5]
      next
    next
    index on str(tbl,1)+str(ns,2) to (cur_dir+"tmp4")
    use
    dbcreate(cur_dir+"tmp10",{{"voz","N",1,0},;
                              {"tbl","N",2,0},;
                              {"tip","N",2,0},;
                              {"kol","N",6,0}})
    use (cur_dir+"tmp10") new alias TMP10
    index on str(voz,1)+str(tbl,1)+str(tip,2) to (cur_dir+"tmp10")
    use
    copy file (cur_dir+"tmp10"+sdbf) to (cur_dir+"tmp11"+sdbf)
    use (cur_dir+"tmp11") new alias TMP11
    index on str(voz,1)+str(tbl,2)+str(tip,2) to (cur_dir+"tmp11")
    use
    dbcreate(cur_dir+"tmp13",{{"voz","N",1,0},;
                              {"tip","N",2,0},;
                              {"kol","N",6,0}})
    use (cur_dir+"tmp13") new alias TMP13
    index on str(voz,1)+str(tip,2) to (cur_dir+"tmp13")
    use
    dbcreate(cur_dir+"tmp16",{{"voz","N",1,0},;
                              {"man","N",1,0},;
                              {"tip","N",2,0},;
                              {"kol","N",6,0}})
    use (cur_dir+"tmp16") new alias TMP16
    index on str(voz,1)+str(man,1)+str(tip,2) to (cur_dir+"tmp16")
    use
    dbCloseAll()
    use (cur_dir+"tmp4")  index (cur_dir+"tmp4")  new
    use (cur_dir+"tmp10") index (cur_dir+"tmp10") new
    use (cur_dir+"tmp11") index (cur_dir+"tmp11") new
    use (cur_dir+"tmp13") index (cur_dir+"tmp13") new
    use (cur_dir+"tmp16") index (cur_dir+"tmp16") new
    R_Use(dir_server+"human_",,"HUMAN_")
    R_Use(dir_server+"human",,"HUMAN")
    Set Relation to recno() into HUMAN_
    R_Use(cur_dir+"tmp")
    Set Relation to kod into HUMAN
    ii := 0
    mywait(" ")
    go top
    do while !eof()
      @ maxrow(),0 say padr(str(++ii/tmp->(lastrec())*100,6,2)+"%  "+alltrim(human->fio)+"  "+full_date(human->date_r),80) color cColorWait
      f2_inf_DNL_030poo(human->kod,human->kod_k)
      select TMP
      skip
    enddo
    close databases
    //
    fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
    add_string(glob_mo[_MO_SHORT_NAME])
    add_string(padl("�ਫ������ 3",sh))
    add_string(padl("� �ਪ��� ����",sh))
    add_string(padl("�514� �� 10.08.2017�.",sh))
    add_string("")
    add_string(padl("��ଠ ������᪮� ���⭮�� � 030-��/�-17",sh))
    add_string("")
    add_string(center("�������� � ��䨫����᪨� ����樭᪨� �ᬮ��� ��ᮢ��襭����⭨�",sh))
    add_string(center("[ "+charrem("~",mas1pmt[is_schet])+" ]",sh))
    add_string(center(arr_m[4],sh))
    add_string("")
    add_string("2. ��᫮ ��⥩, ��襤�� ���ᬮ��� � ���⭮� ��ਮ��:")
    add_string("  2.1. �ᥣ� � ������ �� 0 �� 17 ��� �����⥫쭮:"+str(arr_deti[1],6)+" (祫����), �� ���:")
    add_string("  2.1.1. � ������ �� 0 �� 4 ��� �����⥫쭮      "+str(arr_deti[2],6)+" (祫����),")
    add_string("  2.1.2. � ������ �� 0 �� 14 ��� �����⥫쭮     "+str(arr_deti[2]+arr_deti[3]+arr_deti[4],6)+" (祫����),")
    add_string("  2.1.3. � ������ �� 5 �� 9 ��� �����⥫쭮      "+str(arr_deti[3],6)+" (祫����),")
    add_string("  2.1.4. � ������ �� 10 �� 14 ��� �����⥫쭮    "+str(arr_deti[4],6)+" (祫����),")
    add_string("  2.1.5. � ������ �� 15 �� 17 ��� �����⥫쭮    "+str(arr_deti[5],6)+" (祫����),")
    add_string("  2.1.6. ��⥩-��������� �� 0 �� 17 ��� �����⥫쭮"+str(arr_deti[6],6)+" (祫����).")
    for i := 1 to len(arr_vozrast)
      verify_FF(HH-50, .t., sh)
      add_string("")
      add_string(center(lstr(arr_vozrast[i,1])+;
                 ". ������� ������� ������������ (���ﭨ�) � ��⥩ � ������ �� "+;
                 lstr(arr_vozrast[i,2])+" �� "+lstr(arr_vozrast[i,3])+" ��� �����⥫쭮",sh))
      add_string("��������������������������������������������������������������������������������")
      add_string(" �� �    ������������   � ��� ����ᥣ��� �.糢��-�� �.糑��⮨� ��� ���.�����")
      add_string(" �� �    �����������    � ���-10���ॣ�����-����� �����-������������������������")
      add_string("    �                   �       �������稪� ����ࢳ稪� ��ᥣ������糢��⮳�����")
      add_string("��������������������������������������������������������������������������������")
      add_string(" 1  �          2        �   3   �  4  �  5  �  6  �  7  �  8  �  9  � 10  � 11  ")
      add_string("��������������������������������������������������������������������������������")
      use (cur_dir+"tmp4") index (cur_dir+"tmp4") new alias TMP
      find (str(arr_vozrast[i,1],1))
      do while tmp->tbl == arr_vozrast[i,1] .and. !eof()
        s := tmp->stroke+" "+padr(tmp->name,19)+" "+padc(alltrim(tmp->diagnoz),7)
        for n := 4 to 11
          s += put_val(tmp->&("k"+strzero(n,2)),6)
        next
        add_string(s)
        skip
      enddo
      use
      add_string(replicate("�",sh))
    next
    arr1title := {;
      "��������������������������������������������������������������������������������",;
      "                    �   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� ",;
      "  ������ ��⥩     �           �           ���ꥪ� ���  ��� ���  �    ��     ",;
      "                    �           �           �           �           �           ",;
      "��������������������������������������������������������������������������������",;
      "          1         �     2     �     3     �     4     �     5     �     6     ",;
      "��������������������������������������������������������������������������������"}
    arr2title := {;
      "��������������������������������������������������������������������������������",;
      "                    �   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� ",;
      "  ������ ��⥩     �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č������",;
      "                    � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ",;
      "��������������������������������������������������������������������������������",;
      "          1         �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 ",;
      "��������������������������������������������������������������������������������"}
    arr3title := {;
      "��������������������������������������������������������������������������������",;
      " ������   �ᥣ�   �   � ��    �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ��୮",;
      " ��⥩  �           �           ���ꥪ� ���  ��� ���  �    ��     �-������� ",;
      "        �           �           �           �           �           ��࣠���-�� ",;
      "��������������������������������������������������������������������������������",;
      "    1   �     2     �     3     �     4     �     5     �     6     �     7     ",;
      "��������������������������������������������������������������������������������"}
    arr4title := {;
      "��������������������������������������������������������������������������������",;
      " ������   �ᥣ�   �� �㭨�.�� �   � ���   �� 䥤�ࠫ�-� � ����� �� ᠭ.-���.",;
      " ��⥩  �����������������������Ĵ��ꥪ� ����ĭ�� ���������Č��������Į�-�����",;
      "        � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  � ���.�  %  ",;
      "��������������������������������������������������������������������������������",;
      "    1   �  2  �  3  �  4  �  5  �  6  �  7  �  8  �  9  �  10 �  11 �  12 �  13 ",;
      "��������������������������������������������������������������������������������"}
    verify_FF(HH-50, .t., sh)
    add_string("4. �������� �������⥫��� �������権, ��᫥�������, ��祭��, ����樭᪮�")
    add_string("   ॠ�����樨 ��⥩ �� १���⠬ �஢������ ��䨫����᪨� �ᬮ�஢:")
    use (cur_dir+"tmp10") index (cur_dir+"tmp10") new alias TMP10
    for i := 1 to 2
      verify_FF(HH-16, .t., sh)
      add_string("")
      s := space(5)
      if i == 1
        add_string(s+"4.1. �������⥫�� �������樨 � (���) ��᫥�������")
      else
        add_string(s+"4.2. ��祭��, ����樭᪠� ॠ������� � ᠭ��୮-����⭮� ��祭��")
      endif
      n := 20
      if eq_any(i,1,3,5,6,7)
        aeval(arr1title, {|x| add_string(x) } )
      elseif eq_any(i,2,4)
        aeval(arr2title, {|x| add_string(x) } )
      else
        aeval(arr3title, {|x| add_string(x) } )
        n := 8
      endif
      for j := 1 to len(arr1vozrast)
        s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
        skol := oldkol := 0
        s1 := ""
        for k := 1 to iif(i==8,5,4)
          find (str(j,1)+str(i,1)+str(k,1))
          if found() .and. (v := tmp10->kol) > 0
            skol += v
            if eq_any(i,2,4)
              s1 += str(v,6)
              find (str(j,1)+str(i-1,1)+str(k,1))
              if found() .and. tmp10->kol > 0
                s1 += " "+umest_val(v/tmp10->kol*100,5,2)
                oldkol += tmp10->kol
              else
                s1 += space(6)
              endif
            else
              s1 += " "+padc(lstr(v),11)
            endif
          else
            s1 += space(12)
          endif
        next
        if skol > 0
          if eq_any(i,2,4)
            s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
          else
            s += " "+padc(lstr(skol),11)
          endif
          add_string(s+s1)
        else
          add_string(s)
        endif
      next
      add_string(replicate("�",sh))
    next
    use
    //
    //verify_FF(HH-50, .t., sh)
    //add_string("11. �������� ��祭��, ����樭᪮� ॠ�����樨 � (���) ᠭ��୮-����⭮��")
    //add_string("    ��祭�� ��⥩ �� �஢������ �����饣� ��䨫����᪮�� �ᬮ��:")
    vkol := 0
    use (cur_dir+"tmp11") index (cur_dir+"tmp11") new alias TMP11
    for i := 1 to 0//12
      if i % 3 > 0
        verify_FF(HH-16, .t., sh)
        add_string("")
      endif
      s := space(5)
      if i == 1
        add_string(s+"11.1. ������������� ��祭�� � ���㫠���� �᫮���� � � �᫮����")
        add_string(s+"      �������� ��樮���")
      elseif i == 2
        add_string(s+"11.2. �஢����� ��祭�� � ���㫠���� �᫮���� � � �᫮����")
        add_string(s+"      �������� ��樮���")
      elseif i == 3
        add_string(s+"11.3. ��稭� ���믮������ ४������権 �� ��祭�� � ���㫠���� �᫮����")
        add_string(s+"      � � �᫮���� �������� ��樮���:")
        add_string(s+"        11.3.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      elseif i == 4
        add_string(s+"11.4. ������������� ��祭�� � ��樮����� �᫮����")
      elseif i == 5
        add_string(s+"11.5. �஢����� ��祭�� � ��樮����� �᫮����")
      elseif i == 6
        add_string(s+"11.6. ��稭� ���믮������ ४������権 �� ��祭�� � ��樮����� �᫮����:")
        add_string(s+"        11.6.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      elseif i == 7
        add_string(s+"11.7. ������������� ����樭᪠� ॠ�������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      elseif i == 8
        add_string(s+"11.8. �஢����� ����樭᪠� ॠ�������")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���")
      elseif i == 9
        add_string(s+"11.9. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨")
        add_string(s+"      � ���㫠���� �᫮���� � � �᫮���� �������� ��樮���:")
        add_string(s+"        11.9.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      elseif i == 10
        add_string(s+"11.10. ������������� ����樭᪠� ॠ������� � (���)")
        add_string(s+"       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����")
      elseif i == 11
        add_string(s+"11.11. �஢����� ����樭᪠� ॠ������� � (���)")
        add_string(s+"       ᠭ��୮-����⭮� ��祭�� � ��樮����� �᫮����")
      else
        add_string(s+"11.12. ��稭� ���믮������ ४������権 �� ����樭᪮� ॠ�����樨")
        add_string(s+"       � (���) ᠭ��୮-����⭮�� ��祭�� � ��樮����� �᫮����:")
        add_string(s+"         11.12.1. �� ��諨 �ᥣ� "+lstr(vkol)+" (祫����)")
      endif
      if i % 3 > 0
        n := 20
        if eq_any(i,1,4,7)
          aeval(arr1title, {|x| add_string(x) } )
        elseif eq_any(i,2,5,8)
          aeval(arr2title, {|x| add_string(x) } )
        elseif i == 10
          aeval(arr3title, {|x| add_string(x) } )
          n := 8
        elseif i == 11
          aeval(arr4title, {|x| add_string(x) } )
          n := 8
        endif
        for j := 1 to len(arr1vozrast)
          s := padc(lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2]),n)
          skol := oldkol := 0
          s1 := ""
          for k := 1 to iif(i>10,5,4)
            find (str(j,1)+str(i,2)+str(k,1))
            if found() .and. (v := tmp11->kol) > 0
              skol += v
              if eq_any(i,2,5,8,11)
                s1 += str(v,6)
                find (str(j,1)+str(i-1,2)+str(k,1))
                if found() .and. tmp11->kol > 0
                  s1 += " "+umest_val(v/tmp11->kol*100,5,2)
                  oldkol += tmp11->kol
                else
                  s1 += space(6)
                endif
              else
                s1 += " "+padc(lstr(v),11)
              endif
            else
              s1 += space(12)
            endif
          next
          if eq_any(i,2,5,8,11)
            vkol := oldkol - skol
          endif
          if skol > 0
            if eq_any(i,2,5,8,11)
              s += str(skol,6)+" "+umest_val(skol/oldkol*100,5,2)
            else
              s += " "+padc(lstr(skol),11)
            endif
            add_string(s+s1)
          else
            add_string(s)
          endif
        next
        add_string(replicate("�",sh))
      endif
    next
    use
    use (cur_dir+"tmp16") index (cur_dir+"tmp16") new alias TMP16
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("5. ��᫮ ��⥩ �� �஢�� 䨧��᪮�� ࠧ����")
    add_string("��������������������������������������������������������������������������������")
    add_string("                    ���᫮ �ள���.䨧.� ����襭�� 䨧��᪮�� ࠧ���� (祫.) ")
    add_string("    ������ ��⥩   �襤��   �ࠧ��⨥ ����������������������������������������")
    add_string("                    ����.��.�   祫.  �����.��᳨����.��᳭���.��Ⳣ��.���")
    add_string("��������������������������������������������������������������������������������")
    add_string("          1         �    2    �    3    �    4    �    5    �    6    �    7    ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (����稪�)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 1 to 5
          find (str(j,1)+str(k,1)+str(i,2))
          if found()
            s += " "+padc(lstr(tmp16->kol),9)
          else
            s += space(10)
          endif
        next
        add_string(s)
      next
    next
    add_string(replicate("�",sh))
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("6. ��᫮ ��⥩ �� ����樭᪨� ��㯯�� ��� ����⨩ 䨧��᪮� �����ன")
    add_string("��������������������������������������������������������������������������������")
    add_string("                    ���᫮ �ள    �� ���.�ᬮ��     � �� १���⠬ ���.��")
    add_string("    ������ ��⥩   �襤��   ��������������������������������������������������")
    add_string("                    ����.��.� I  � II � III� IV ��� �� I  � II � III� IV ��� �")
    add_string("��������������������������������������������������������������������������������")
    add_string("          1         �    2    � 3  � 4  � 5  � 6  � 7  � 8  � 9  � 10 � 11 � 12 ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (����稪�)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 31 to 35
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        for i := 41 to 45
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        add_string(s)
      next
    next
    verify_FF(HH-21, .t., sh)
    n := 20
    add_string("")
    add_string("7. ��᫮ ��⥩ �� ��㯯�� ���஢��")
    add_string("��������������������������������������������������������������������������������")
    add_string("                    ���᫮ �ள    �� ���.�ᬮ��     � �� १���⠬ ���.��")
    add_string("    ������ ��⥩   �襤��   ��������������������������������������������������")
    add_string("                    ����.��.� I  � II � III� IV � V  � I  � II � III� IV � V  ")
    add_string("��������������������������������������������������������������������������������")
    add_string("          1         �    2    � 3  � 4  � 5  � 6  � 7  � 8  � 9  � 10 � 11 � 12 ")
    add_string("��������������������������������������������������������������������������������")
    for j := 1 to len(arr1vozrast)
      for k := 0 to 1
        s := padr(" "+lstr(arr1vozrast[j,1])+" - "+lstr(arr1vozrast[j,2])+;
                  iif(k==0,""," (����稪�)"),n)
        find (str(j,1)+str(k,1)+str(0,2))
        if found()
          s += " "+padc(lstr(tmp16->kol),9)
        else
          s += space(10)
        endif
        for i := 11 to 15
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        for i := 21 to 25
          find (str(j,1)+str(k,1)+str(i,2))
          s += put_val(tmp16->kol,5)
        next
        add_string(s)
      next
    next
    add_string(replicate("�",sh))
    fclose(fp)
    viewtext(n_file,,,,.t.,,,5)
  endif
endif
close databases
rest_box(buf)
return NIL

***** 14.07.19
Function f2_inf_DNL_030poo(Loc_kod,kod_kartotek) // ᢮���� ���ଠ��
Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
      is_man := (human->pol == "�"), blk_tbl, blk_tip, blk_put_tip, a10[9], a11[13]
blk_tbl := {|_k| iif(_k < 2, 1, 2) }
blk_tip := {|_k| iif(_k == 0, 2, iif(_k > 1, _k+1, _k)) }
blk_put_tip := {|_e,_k| iif(_k > _e, _k, _e) }
Private metap := 1, mperiod := 0, mshifr_zs := "", m1lis := 0,;
        mkateg_uch, m1kateg_uch := 3,; // ��⥣��� ��� ॡ����:
        mMO_PR := space(10), m1MO_PR := space(6),; // ��� �� �ਪ९�����
        mschool := space(10), m1school := 0,; // ��� ���.��०�����
        mWEIGHT := 0,;   // ��� � ��
        mHEIGHT := 0,;   // ��� � �
        mPER_HEAD := 0,; // ���㦭���� ������ � �
        mfiz_razv, m1FIZ_RAZV := 0,; // 䨧��᪮� ࠧ��⨥
        mfiz_razv1, m1FIZ_RAZV1 := 0,; // �⪫������ ����� ⥫�
        mfiz_razv2, m1FIZ_RAZV2 := 0,; // �⪫������ ���
        m1psih11 := 0,;  // �������⥫쭠� �㭪�� (������ ࠧ����)
        m1psih12 := 0,;  // ���ୠ� �㭪�� (������ ࠧ����)
        m1psih13 := 0,;  // ���樮���쭠� � �樠�쭠� (���⠪� � ���㦠�騬 ��஬) �㭪樨 (������ ࠧ����)
        m1psih14 := 0,;  // �।�祢�� � �祢�� ࠧ��⨥ (������ ࠧ����)
        mpsih21, m1psih21 := 0,;  // ��宬��ୠ� ���: (��ଠ, �⪫������)
        mpsih22, m1psih22 := 0,;  // ��⥫����: (��ଠ, �⪫������)
        mpsih23, m1psih23 := 0,;  // ���樮���쭮-�����⨢��� ���: (��ଠ, �⪫������)
        m141p   := 0,; // ������� ��㫠 ����稪� P
        m141ax  := 0,; // ������� ��㫠 ����稪� Ax
        m141fa  := 0,; // ������� ��㫠 ����稪� Fa
        m142p   := 0,; // ������� ��㫠 ����窨 P
        m142ax  := 0,; // ������� ��㫠 ����窨 Ax
        m142ma  := 0,; // ������� ��㫠 ����窨 Ma
        m142me  := 0,; // ������� ��㫠 ����窨 Me
        m142me1 := 0,; // ������� ��㫠 ����窨 - menarhe (���)
        m142me2 := 0,; // ������� ��㫠 ����窨 - menarhe (����楢)
        m142me3, m1142me3 := 0,; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
        m142me4, m1142me4 := 1,; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
        m142me5, m1142me5 := 1,; // ������� ��㫠 ����窨 - menses (�ࠪ���⨪�):
        mdiag_15_1, m1diag_15_1 := 1,; // ����ﭨ� ���஢�� �� �஢������ ���ᬮ��-�ࠪ��᪨ ���஢
        mdiag_15[5,14],; //
        mGRUPPA_DO := 0,; // ��㯯� ���஢�� �� ���-��
        mGR_FIZ_DO, m1GR_FIZ_DO := 1,;
        mdiag_16_1, m1diag_16_1 := 1,; // ����ﭨ� ���஢�� �� १���⠬ �஢������ ���ᬮ�� (�ࠪ��᪨ ���஢)
        mdiag_16[5,16],; //
        minvalid[8],;  // ࠧ��� 16.7
        mGRUPPA := 0,;    // ��㯯� ���஢�� ��᫥ ���-��
        mGR_FIZ, m1GR_FIZ := 1,;
        mPRIVIVKI[3],; // �஢������ ��䨫����᪨� �ਢ����
        mrek_form := space(255),; // "C100",���������樨 �� �ନ஢���� ���஢��� ��ࠧ� �����, ०��� ���, ��⠭��, 䨧��᪮�� ࠧ����, ���㭮��䨫��⨪�, ������ 䨧��᪮� �����ன
        mrek_disp := space(255),; // "C100",���������樨 �� ��ᯠ��୮�� �������, ��祭��, ����樭᪮� ॠ�����樨 � ᠭ��୮-����⭮�� ��祭�� � 㪠������ �������� (��� ���), ���� ����樭᪮� �࣠����樨 � ᯥ樠�쭮�� (��������) ���
        mhormon := "0 ��.", m1hormon := 1, not_hormon,;
        mstep2, m1step2 := 0
Private minvalid1, m1invalid1 := 0,;
        minvalid2, m1invalid2 := 0,;
        minvalid3 := ctod(""), minvalid4 := ctod(""),;
        minvalid5, m1invalid5 := 0,;
        minvalid6, m1invalid6 := 0,;
        minvalid7 := ctod(""),;
        minvalid8, m1invalid8 := 0
Private mprivivki1, m1privivki1 := 0,;
        mprivivki2, m1privivki2 := 0,;
        mprivivki3 := space(100)
Private mvar, m1var, m1lis := 0
//
for i := 1 to 5
  for k := 1 to 14
    s := "diag_15_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(4)
    endif
  next
next
//
for i := 1 to 5
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      Private &mvar := space(6)
    else
      m1var := "m1"+s
      Private &m1var := 0
      Private &mvar := space(3)
    endif
  next
next
mvozrast := count_years(human->date_r,human->n_data)
if !between(mvozrast,0,17)
  mvozrast := 17
endif
mdvozrast := year(human->n_data) - year(human->date_r)
if !between(mdvozrast,0,17)
  mdvozrast := 17
endif
read_arr_PN(Loc_kod)
arr_deti[1] ++
if mdvozrast < 5
  arr_deti[2] ++
elseif mdvozrast < 10
  arr_deti[3] ++
elseif mdvozrast < 15
  arr_deti[4] ++
else
  arr_deti[5] ++
endif
for i := 1 to len(arr_vozrast)
  if between(mdvozrast,arr_vozrast[i,2],arr_vozrast[i,3])
    aadd(av,arr_vozrast[i,1]) // ᯨ᮪ ⠡��� � 4 �� 9
  endif
next
for i := 1 to len(arr1vozrast)
  if between(mdvozrast,arr1vozrast[i,1],arr1vozrast[i,2])
    aadd(av1,i)
  endif
next
for i := 1 to 5
  j := 0
  for k := 1 to 16
    s := "diag_16_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(16) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
afill(a10,0)
for i := 1 to len(ad) // 横� �� ���������
  au := {}
  d := diag_to_num(ad[i,1],1)
  for n := 1 to len(arr_4)
    if !empty(arr_4[n,3]) .and. between(d,arr_4[n,4],arr_4[n,5])
      aadd(au,n)
    endif
  next
  if len(au) == 1
    aadd(au,len(arr_4)-1)  // {"18","��稥","",,},;
  endif
  select TMP4
  for n := 1 to len(av) // 横� �� ᯨ�� ⠡��� � 4 �� 9
    for j := 1 to len(au)
      find (str(av[n],1)+str(au[j],2))
      if found()
        tmp4->k04 ++
        if is_man
          tmp4->k05 ++
        endif
        if ad[i,2] > 0 // ���.�����
          tmp4->k06 ++
          if is_man
            tmp4->k07 ++
          endif
        endif
        if ad[i,3] > 0 // ���.����.��⠭������
          tmp4->k08 ++
          if is_man
            tmp4->k09 ++
          endif
          if ad[i,3] == 2 // ���.����.��⠭������ �����
            tmp4->k10 ++
            if is_man
              tmp4->k11 ++
            endif
          endif
        endif
      endif
    next
  next
  if ad[i,4] == 1 // 1-���.����.�����祭�
    ntbl := eval(blk_tbl,ad[i,5])
    ntip := eval(blk_tip,ad[i,6])
    if ntbl == 1 .and. a10[3] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a10[1] := 0
      a10[3] := eval(blk_put_tip,a10[3],ntip)
    else
      a10[1] := eval(blk_put_tip,a10[1],ntip)
      a10[3] := 0
    endif
  endif
  if ad[i,7] == 1 // 1-���.����.�믮�����
    ntbl := eval(blk_tbl,ad[i,8])
    ntip := eval(blk_tip,ad[i,9])
    if ntbl == 1 .and. a10[4] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a10[2] := 0
      a10[4] := eval(blk_put_tip,a10[4],ntip)
    else
      a10[2] := eval(blk_put_tip,a10[2],ntip)
      a10[4] := 0
    endif
  endif
  if ad[i,10] == 1 // 1-��祭�� �����祭�
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a10[6] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a10[5] := 0
      a10[6] := eval(blk_put_tip,a10[6],ntip)
    else
      a10[5] := eval(blk_put_tip,a10[5],ntip)
      a10[6] := 0
    endif
  endif
  if ad[i,13] == 1 // 1-ॠ���.�����祭�
    ntbl := eval(blk_tbl,ad[i,14])
    ntip := eval(blk_tip,ad[i,15])
    if ntbl == 1 .and. a10[8] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
      a10[7] := 0
      a10[8] := eval(blk_put_tip,a10[8],ntip)
    else
      a10[7] := eval(blk_put_tip,a10[7],ntip)
      a10[8] := 0
    endif
  endif
  if ad[i,16] == 1 // 1-��� �����祭�
    a10[9] := 1
  endif
next
select TMP10
for n := 1 to len(av1) // 横� �� �����⠬ ⠡��� 10
  for j := 1 to len(a10)-1
    if a10[j] > 0
      find (str(av1[n],1)+str(j,1)+str(a10[j],2))
      if !found()
        append blank
        tmp10->voz := av1[n]
        tmp10->tbl := j
        tmp10->tip := a10[j]
      endif
      tmp10->kol ++
    endif
  next
next
ad := {}
for i := 1 to 5
  j := 0
  for k := 1 to 14
    s := "diag_15_"+lstr(i)+"_"+lstr(k)
    mvar := "m"+s
    if k == 1
      if !empty(&mvar)
        arr := array(14) ; afill(arr,0) ; arr[1] := alltrim(&mvar)
        if len(arr[1]) > 5
          arr[1] := left(arr[1],5)
        endif
        aadd(ad,arr) ; j := len(ad)
      endif
    elseif j > 0
      m1var := "m1"+s
      ad[j,k] := &m1var
    endif
  next
next
afill(a11,0)
for i := 1 to len(ad) // 横� �� ���������
  if ad[i,3] == 1 // 1-��祭�� �����祭�
    ntbl := eval(blk_tbl,ad[i,4])
    ntip := eval(blk_tip,ad[i,5])
    if ntbl == 1 .and. a11[4] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a11[1] := 0
      a11[4] := eval(blk_put_tip,a11[4],ntip)
    else
      a11[1] := eval(blk_put_tip,a11[1],ntip)
      a11[4] := 0
    endif
    // ��祭�� �믮�����
    ntbl := eval(blk_tbl,ad[i,6])
    ntip := eval(blk_tip,ad[i,7])
    if ntbl == 1 .and. a11[5] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a11[2] := 0
      a11[5] := eval(blk_put_tip,a11[5],ntip)
    else
      a11[2] := eval(blk_put_tip,a11[2],ntip)
      a11[5] := 0
    endif
  endif
  if ad[i,8] == 1 // 1-ॠ���.�����祭�
    ntbl := eval(blk_tbl,ad[i,9])
    ntip := eval(blk_tip,ad[i,10])
    if ntbl == 1 .and. a11[10] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2
      a11[ 7] := 0
      a11[10] := eval(blk_put_tip,a11[10],ntip)
    else
      a11[ 7] := eval(blk_put_tip,a11[7],ntip)
      a11[10] := 0
    endif
    // 1-ॠ���.�믮�����
    ntbl := eval(blk_tbl,ad[i,11])
    ntip := eval(blk_tip,ad[i,12])
    if ntbl == 1 .and. a11[11] > 0 // 㦥 ���� ��樮���
      //
    elseif ntbl == 2 .or. ntip == 5 // ��� ᠭ��਩
      a11[ 8] := 0
      a11[11] := eval(blk_put_tip,a11[11],ntip)
    else
      a11[ 8] := eval(blk_put_tip,a11[8],ntip)
      a11[11] := 0
    endif
  endif
  if ad[i,14] == 1 // 1-��� �஢�����
    a11[13] := 1
  endif
next
select TMP11
for n := 1 to len(av1) // 横� �� �����⠬ ⠡��� 10
  for j := 1 to len(a11)-1
    if a11[j] > 0
      find (str(av1[n],1)+str(j,2)+str(a11[j],2))
      if !found()
        append blank
        tmp11->voz := av1[n]
        tmp11->tbl := j
        tmp11->tip := a11[j]
      endif
      tmp11->kol ++
    endif
  next
next
if a10[9] > 0
  s12_1++
  if is_man
    s12_1m++
  endif
endif
if a11[13] > 0
  s12_2++
  if is_man
    s12_2m++
  endif
endif
ad := {0}
if m1invalid1 == 1 // ������������-��
  arr_deti[6] ++
  aadd(ad,4)
  if m1invalid2 == 0 // � ஦�����
    aadd(ad,1)
  else               // �ਮ��⥭���
    aadd(ad,2)
    if !empty(minvalid3) .and. minvalid3 >= human->n_data
      aadd(ad,3)
    endif
  endif
  if !empty(minvalid7) // ��� �����祭�� ���.�ணࠬ�� ॠ�����樨
    aadd(ad,10)
    do case // �믮������
      case m1invalid8 == 1 // ���������,1
        aadd(ad,11)
      case m1invalid8 == 2 // ���筮,2
        aadd(ad,12)
      case m1invalid8 == 3 // ����,3
        aadd(ad,13)
      otherwise            // �� �믮�����,0
        aadd(ad,14)
    endcase
  endif
endif
if m1privivki1 == 1     // �� �ਢ�� �� ����樭᪨� ���������",1},;
  if m1privivki2 == 1
    aadd(ad,21)
  else
    aadd(ad,22)
  endif
elseif m1privivki1 == 2 // �� �ਢ�� �� ��㣨� ��稭��",2}}
  if m1privivki2 == 1
    aadd(ad,23)
  else
    aadd(ad,24)
  endif
else                    // �ਢ�� �� �������",0},;
  aadd(ad,20)
endif
select TMP13
for n := 1 to len(av1) // 横� �� �����⠬ ⠡����
  for j := 1 to len(ad)
    find (str(av1[n],1)+str(ad[j],2))
    if !found()
      append blank
      tmp13->voz := av1[n]
      tmp13->tip := ad[j]
    endif
    tmp13->kol ++
  next
next
ad := {0}
if m1fiz_razv == 0
  aadd(ad,1)
else
  if m1fiz_razv1 == 1
    aadd(ad,2)
  elseif m1fiz_razv1 == 2
    aadd(ad,3)
  endif
  if m1fiz_razv2 == 1
    aadd(ad,4)
  elseif m1fiz_razv2 == 2
    aadd(ad,5)
  endif
endif
mGRUPPA := human_->RSLT_NEW - 331 //L_BEGIN_RSLT
if !between(mgruppa,1,5)
  mgruppa := 1
endif
if !between(mgruppa_do,1,5)
  mgruppa_do := 1
endif
if !between(m1GR_FIZ,0,4)
  m1GR_FIZ := 1
endif
if !between(m1GR_FIZ_DO,0,4)
  m1GR_FIZ_DO := 1
endif
aadd(ad,mGRUPPA_DO+10)
aadd(ad,mGRUPPA+20)
aadd(ad,iif(m1GR_FIZ_DO==0, 35, m1GR_FIZ_DO+30))
aadd(ad,iif(m1GR_FIZ==0, 45, m1GR_FIZ+40))
select TMP16
for n := 1 to len(av1) // 横� �� �����⠬ ⠡����
  for j := 1 to len(ad)
    find (str(av1[n],1)+"0"+str(ad[j],2))
    if !found()
      append blank
      tmp16->voz := av1[n]
      tmp16->tip := ad[j]
    endif
    tmp16->kol ++
    if is_man
      find (str(av1[n],1)+"1"+str(ad[j],2))
      if !found()
        append blank
        tmp16->voz := av1[n]
        tmp16->man := 1
        tmp16->tip := ad[j]
      endif
      tmp16->kol ++
    endif
  next
next
return NIL

*

***** 11.03.19
Function inf_DNL_XMLfile(is_schet,stitle)
Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[BR_LEN], arr, n_func
if (arr_m := year_month(T_ROW,T_COL-5)) != NIL
  mywait()
  do case
    case p_tip_lu == TIP_LU_PN
      arr := {301,302} // ��䨫��⨪� 1 � 2 �⠯
    case p_tip_lu == TIP_LU_PREDN
      arr := {303,304} // �।.�ᬮ��� 1 � 2 �⠯
    case p_tip_lu == TIP_LU_PERN
      arr := {305} // ��ਮ�.�ᬮ���
  endcase
  if f0_inf_DNL(arr_m,is_schet > 1,is_schet == 3,arr,.t.)
    copy file (cur_dir+"tmp"+sdbf) to (cur_dir+"tmpDNL"+sdbf) // �.�. ����� ⮦� ���� TMP-䠩�
    R_Use(dir_server+"human",,"HUMAN")
    use (cur_dir+"tmpDNL") new
    set relation to kod into HUMAN
    index on upper(human->fio) to (cur_dir+"tmpDNL")
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            E_Use(cur_dir+"tmpDNL",cur_dir+"tmpDNL","TMP"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    eval(blk_open)
    go top
    t_arr[BR_TOP] := 2
    t_arr[BR_BOTTOM] := 23
    t_arr[BR_LEFT] := 0
    t_arr[BR_RIGHT] := 79
    stitle := "XML-���⠫: "+stitle+" ��ᮢ��襭����⭨� "
    t_arr[BR_TITUL] := stitle+arr_m[4]
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_COLOR] := color0
    t_arr[BR_ARR_BROWSE] := {'�','�','�',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{" ", {|| iif(tmp->is==1,""," ") }, blk },;
                         {" �.�.�.", {|| padr(human->fio,37) }, blk },;
                         {"��� ஦�.", {|| full_date(human->date_r) }, blk },;
                         {"� ��.�����", {|| human->uch_doc }, blk },;
                         {"�ப� ���-�", {|| left(date_8(human->n_data),5)+"-"+left(date_8(human->k_data),5) }, blk },;
                         {"�⠯", {|| iif(eq_any(human->ishod,301,303,305)," I  ","I-II") }, blk }}
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室 ��� ᮧ����� 䠩��;  ^<+,-,Ins>^ - �⬥���/���� �⬥�� � ��樥��") }
    t_arr[BR_EDIT] := {|nk,ob| f1_inf_N_XMLfile(nk,ob,"edit") }
    edit_browse(t_arr)
    select TMP
    delete for is == 0
    pack
    n := lastrec()
    close databases
    rest_box(buf)
    if n == 0 .or. !f_Esc_Enter("��⠢����� XML-䠩��")
      return NIL
    endif
    mywait()
    R_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
    Use
    R_Use(dir_server+"mo_raksh",,"RAKSH")
    index on str(KOD_H,7) to (cur_dir+"tmpraksh")
    Use
    Private blk_open := {|| dbCloseAll(),;
                            R_Use(dir_server+"human_",,"HUMAN_"),;
                            R_Use(dir_server+"human",,"HUMAN"),;
                            dbSetRelation( "HUMAN_", {|| recno() }, "recno()" ),;
                            E_Use(cur_dir+"tmpDNL",cur_dir+"tmpDNL","TMP"),;
                            dbSetRelation( "HUMAN", {|| kod }, "kod" );
                        }
    mo_mzxml_N(1)
    n := 0
    do while .t.
      ++n
      eval(blk_open)
      if rec == NIL
        go top
      else
        goto (rec)
        skip
        if eof()
          exit
        endif
      endif
      rec := tmp->(recno())
      @ maxrow(),0 say padr(str(n/tmp->(lastrec())*100,6,2)+"%"+" "+;
                            rtrim(human->fio)+" "+date_8(human->n_data)+"-"+;
                            date_8(human->k_data),80) color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      close databases
      n_func := "f2_inf_N_XMLfile"
      do case
        case p_tip_lu == TIP_LU_PN
          oms_sluch_PN(lkod_h,lkod_k,n_func) // ��䨫��⨪� 1 � 2 �⠯
        case p_tip_lu == TIP_LU_PREDN
          oms_sluch_PREDN(lkod_h,lkod_k,n_func) // �।.�ᬮ��� 1 � 2 �⠯
        case p_tip_lu == TIP_LU_PERN
          oms_sluch_PerN(lkod_h,lkod_k,n_func) // ��ਮ�.�ᬮ���
      endcase
    enddo
    close databases
    rest_box(buf)
    mo_mzxml_N(3,"tmp",stitle)
  endif
endif
close databases
rest_box(buf)
return NIL

*

***** 22.11.13
Function f1_inf_N_XMLfile(nKey,oBrow,regim)
Local ret := -1, rec := tmp->(recno())
if regim == "edit"
  do case
    case nkey == K_INS
      tmp->is := iif(tmp->is==1, 0, 1)
      ret := 0
      keyboard chr(K_TAB)
    case nkey == 43  // +
      tmp->(dbeval({|| tmp->is := 1 }))
      goto (rec)
      ret := 0
    case nkey == 45  //  -
      tmp->(dbeval({|| tmp->is := 0 }))
      goto (rec)
      ret := 0
  endcase
endif
return ret

*

***** 22.11.13 �� ����� ���� ��ᮢ��襭����⭥�� ᮧ���� ���� XML-䠩��
Function f2_inf_N_XMLfile(Loc_kod,kod_kartotek,lvozrast)
Local adbf, s, i, j, k, y, m, d, fl
R_Use(dir_server+"kartote_",,"KART_")
goto (kod_kartotek)
R_Use(dir_server+"kartotek",,"KART")
goto (kod_kartotek)
R_Use(dir_server+"human_",,"HUMAN_")
goto (Loc_kod)
R_Use(dir_server+"human",,"HUMAN")
goto (Loc_kod)
R_Use(dir_server+"mo_pers",,"P2")
goto (m1vrach)
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"mo_rpdsh",cur_dir+"tmprpdsh","RPDSH")
R_Use(dir_server+"mo_raksh",cur_dir+"tmpraksh","RAKSH")
mo_mzxml_N(2,,,lvozrast)
return NIL

*

***** 25.11.13
Function f4_inf_PREDN_karta(par,_etap)
Local i, k, fl, arr := {}, ar := npred_arr_1_etap[mperiod]
if par == 1
  if iif(_etap==nil, .t., _etap==1)
    for i := 1 to count_predn_arr_osm
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(npred_arr_osmotr[i,2])
        fl := (mpol == npred_arr_osmotr[i,2])
      endif
      if fl
        fl := (!empty(ar[4]) .and. ascan(ar[4],npred_arr_osmotr[i,1]) > 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {npred_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
  endif
  aadd(arr, {"������� (��� ��饩 �ࠪ⨪�)", MDATEp1, "", -1, 1})
  if metap == 2 .and. iif(_etap==nil, .t., _etap==2)
    for i := 1 to count_predn_arr_osm
      mvart := "MTAB_NOMov"+lstr(i)
      mvard := "MDATEo"+lstr(i)
      fl := .t.
      if fl .and. !empty(npred_arr_osmotr[i,2])
        fl := (mpol == npred_arr_osmotr[i,2])
      endif
      if fl
        fl := (ascan(ar[4],npred_arr_osmotr[i,1]) == 0)
      endif
      if fl .and. !emptyany(&mvard,&mvart)
        aadd(arr, {npred_arr_osmotr[i,3], &mvard, "", i, f5_inf_DNL_karta(i)})
      endif
    next
    aadd(arr, {"������� (��� ��饩 �ࠪ⨪�)", MDATEp2, "", -2, 1})
  endif
else
  for i := 1 to count_predn_arr_iss // ��᫥�������
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    fl := .t.
    if fl .and. !empty(npred_arr_issled[i,2])
      fl := (mpol == npred_arr_issled[i,2])
    endif
    if fl
      fl := (ascan(ar[5],npred_arr_issled[i,1]) > 0)
    endif
    if fl .and. !emptyany(&mvard,&mvart)
      k := 0
      do case
        case i ==  1 // {"4.2.153" ,   , "��騩 ������ ���",0,34,{1107,1301,1402,1702} },;
          k := 2
        case i ==  2 // {"4.11.136",   , "������᪨� ������ �஢�",0,34,{1107,1301,1402,1702} },;
          k := 1
        case i ==  3 // {"4.12.169",   , "��᫥������� �஢�� ���� � �஢�",0,34,{1107,1301,1402,1702} },;
          k := 4
        case i ==  4 // {"4.8.12"  ,   , "������ ���� �� �� ����⮢",0,34,{1107,1301,1402,1702} },;
          k := 16
        case i ==  5 // {"7.61.3"  ,   , "���ண��� ������ � 1-� �஥�樨",0,78,{1118,1802} },;
          k := 12
        case i ==  6 // {"8.1.2"   ,   , "��� �⮢����� ������",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 8
        case i ==  7 // {"8.1.3"   ,   , "��� ���",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 7
        case i ==  8 // {"8.2.1"   ,   , "��� �࣠��� ���譮� ������",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 6
        case i ==  9 // {"8.2.2"   ,"�", "��� �࣠��� ९த�⨢��� ��⥬�",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 9
        case i == 10 // {"8.2.3"   ,"�", "��� �࣠��� ९த�⨢��� ��⥬�",0,106,{110101,111004,111802,111903,112211,112610,113416,113508,180203} },;
          k := 9
        case i == 11 // {"13.1.1"  ,   , "�����ப�न�����",0,111,{110103,110303,110906,111006,111905,112212,112611,113418,113509,180202} },;
          k := 13
      endcase
      aadd(arr, {npred_arr_issled[i,3], &mvard, &mvarr, i, k})
    endif
  next
endif
return arr

*

***** 25.11.13
Function f4_inf_PerN_karta(par)
Local i, k, fl, arr := {}, ar := nper_arr_1_etap[mperiod]
if par == 1
  aadd(arr, {"������� (��� ��饩 �ࠪ⨪�)", MDATEp1, "", -1, 1})
else
  for i := 1 to count_Pern_arr_iss // ��᫥�������
    mvart := "MTAB_NOMiv"+lstr(i)
    mvard := "MDATEi"+lstr(i)
    mvarr := "MREZi"+lstr(i)
    fl := (ascan(ar[5],nPer_arr_issled[i,1]) > 0)
    if fl .and. !emptyany(&mvard,&mvart)
      k := 0
      do case
        case i ==  1 // {"4.2.153" ,   , "��騩 ������ ���",0,34,{1107,1301,1402,1702} },;
          k := 2
        case i ==  1 // {"4.11.136",   , "������᪨� ������ �஢�",0,34,{1107,1301,1402,1702} },;
          k := 1
        case i ==  1 // {"16.1.16" ,   , "������ ���� 㣫�த� ���堥�.������",0,34,{1107,1301,1402,1702} };
          k := 17
      endcase
      aadd(arr, {nPer_arr_issled[i,3], &mvard, &mvarr, i, k})
    endif
  next
endif
return arr

*

***** 31.10.16 ����� ��ᮢ��襭����⭨�, ��������� ����ᬮ�ࠬ, ��⮤�� �������ਠ�⭮�� ���᪠
Function mnog_poisk_DNL()
Local mm_tmp := {}, mm_sort
Local buf := savescreen(), tmp_color := setcolor(cDataCGet),;
      tmp_help := help_code, hGauge, name_file := "_kartDNL"+stxt,;
      sh := 80, HH := 77, i, a_diagnoz[10], ta, name_dbf := cur_dir+"_kartDNL"+sdbf,;
      mm_da_net := {{"���",1},{"�� ",2}}, ;
      mm_mest := {{"������ࠤ ��� �������",1},{"�����த���",2}},;
      mm_disp := {{"�������",0},{"�� ��室���",1},{"��諨",2}},;
      mm_death := {{"�뢮���� ���",0},{"�� �뢮���� 㬥���",1},{"�뢮���� ⮫쪮 㬥���",2}},;
      mm_prik := {{"�������",0},;
                  {"�ਪ९�� � ��襩 ��",1},;
                  {"�ਪ९�� � ��㣨� ��",2},;
                  {"�ਪ९����� �������⭮",3}},;
      tmp_file := cur_dir+"tmp_mn_p"+sdbf,;
      k_fio, k_adr, tt_fio[10], tt_adr[10], fl_exit := .f.
Local adbf := {;
   {"UCHAST" ,   "N",  2,0},; // ����� ���⪠
   {"KOD_VU" ,   "N",  6,0},; // ��� � ���⪥
   {"FIO"    ,   "C", 50,0},; // �.�.�. ���쭮��
   {"PHONE"  ,   "C", 40,0},; // ⥫�䮭 ���쭮��
   {"POL"    ,   "C",  1,0},; // ���
   {"DATE_R"   , "C", 10,0},; // ��� ஦����� ���쭮��
   {"LET"    ,   "N",  2,0},; // ᪮�쪮 ��� � �⮬ ����
   {"ADRESR"  ,  "C", 50,0},; // ���� ���쭮��
   {"ADRESP"  ,  "C", 50,0},; // ���� ���쭮��
   {"POLIS",     "C", 17,0},; // �����
   {"KOD_SMO",   "C",  5,0},; //
   {"SMO",       "C", 80,0},; // ॥��஢� ����� ���;;�८�ࠧ����� �� ����� ����� � ����, ����த��� = 34
   {"SNILS"  ,   "C", 14,0},;
   {"MO_PR",     "C",  6,0},; // ��� �� �ਯ�᪨
   {"MONAME_PR", "C", 60,0},; // ������������ �� �ਯ�᪨
   {"DATE_PR"  , "C", 10,0},; // ��� �ਯ�᪨
   {"LAST_L_U" , "C", 10,0};  // ��� ��᫥����� ���� ����
  }
if !myFileDeleted(name_dbf)
  return NIL
endif
Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
if is_talon
  is_kategor2 := !empty(stm_kategor2)
endif
for i := 1 to len(glob_arr_smo)
  if glob_arr_smo[i,3] == 1
    aadd(mm_smo,{glob_arr_smo[i,1],padr(lstr(glob_arr_smo[i,2]),5)})
  endif
next
ta := f2_mnog_poisk_DNL(,,,1)
aadd(mm_tmp, {"god","N",4,0,"9999",;
              nil,;
              year(sys_date),nil,;
              "� ����� ���� �� �뫮 ��������/��ᯠ��ਧ�樨"})
aadd(mm_tmp, {"v_period","C",100,0,NIL,;
              {|x|menu_reader(x,{{ |k,r,c| f2_mnog_poisk_DNL(k,r,c) }},A__FUNCTION)},;
              ta[1],{|x| ta[2] },;
              '������� ��ਮ�� ��������/��ᯠ��ਧ�樨'})
aadd(mm_tmp, {"o_prik","N",1,0,NIL,;
              {|x|menu_reader(x,mm_prik,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_prik,x)},;
              "�⭮襭�� � �ਪ९�����"})
aadd(mm_tmp, {"o_death","N",1,0,NIL,;
              {|x|menu_reader(x,mm_death,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_death,x)},;
              "�������� � ᬥ�� �� ᢥ����� �����"})
Private arr_uchast := {}
if is_uchastok > 0
  aadd(mm_tmp, {"bukva","C",1,0,"@!",;
                nil,;
                " ",nil,;
                "�㪢� (��। ���⪮�)"})
  aadd(mm_tmp, {"uchast","N",1,0,,;
                {|x|menu_reader(x,{{|k,r,c| get_uchast(r+1,c) }},A__FUNCTION)},;
                0,{|| init_uchast(arr_uchast) },;
                "���⮪ (���⪨)"})
  mm_sort := {;
   {"� ���⪠ + ��� + ���",1},;
   {"� ���⪠ + ��� + ����",2},;
   {"� ���⪠ + ���� + ���",4};
  }
  if is_uchastok == 1
    aadd(mm_sort, {'� ���⪠ + � � ���⪥',3})
  elseif is_uchastok == 2
    aadd(mm_sort, {'� ���⪠ + ��� �� ����⥪�',3})
  elseif is_uchastok == 3
    aadd(mm_sort, {'� ���⪠ + ����� �� ���',3})
  endif
else
  mm_sort := {;
   {"��� + ���",1},;
   {"��� + ����",2},;
   {"��� �� ����⥪�",3};
  }
  Del_Array(adbf,1) // 㡨ࠥ� ���⮪
  Del_Array(adbf,1) // 㡨ࠥ� ���⮪
endif
aadd(mm_tmp, {"fio","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "��� (��砫�� �㪢� ��� 蠡���)"})
aadd(mm_tmp, {"mi_git","N",2,0,NIL,;
              {|x|menu_reader(x,mm_mest,A__MENUVERT)},;
              -1,{|| space(10) },;
              "���� ��⥫��⢠:"})
aadd(mm_tmp, {"_okato","C",11,0,NIL,;
              {|x|menu_reader(x,;
                {{ |k,r,c| get_okato_ulica(k,r,c,{k,m_okato,}) }},A__FUNCTION)},;
              space(11),{|x| space(11)},;
              '���� ॣ����樨 (�����)'})
aadd(mm_tmp, {"adres","C",20,0,"@!",;
              nil,;
              space(20),nil,;
              "���� (�����ப� ��� 蠡���)"})
if is_talon
  aadd(mm_tmp, {"kategor","N",2,0,NIL,;
                {|x|menu_reader(x,mo_cut_menu(stm_kategor),A__MENUVERT)},;
                0,{|| space(10) },;
                "��� ��⥣�ਨ �죮��"})
  if is_kategor2
    aadd(mm_tmp, {"kategor2","N",4,0,NIL,;
                  {|x|menu_reader(x,stm_kategor2,A__MENUVERT)},;
                  0,{|| space(10) },;
                  "��⥣��� ��"})
  endif
endif
aadd(mm_tmp, {"pol","C",1,0,"!",;
              nil,;
              " ",nil,;
              "���", {|| mpol $ " ��" } })
aadd(mm_tmp, {"god_r_min","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "��� ஦����� (�������쭠�)"})
aadd(mm_tmp, {"god_r_max","D",8,0,,;
              nil,;
              ctod(""),nil,;
              "��� ஦����� (���ᨬ��쭠�)"})
aadd(mm_tmp, {"smo","C",5,0,NIL,;
              {|x|menu_reader(x,mm_smo,A__MENUVERT)},;
              space(5),{|| space(10) },;
              "���客�� ��������"})
aadd(mm_tmp, {"i_sort","N",1,0,NIL,;
              {|x|menu_reader(x,mm_sort,A__MENUVERT)},;
              1,{|x|inieditspr(A__MENUVERT,mm_sort,x)},;
              "����஢�� ��室���� ���㬥��"})
delete file (tmp_file)
init_base(tmp_file,,mm_tmp,0)
//
k := f_edit_spr(A__APPEND,mm_tmp,"������⢥����� ������",;
                "e_use(cur_dir+'tmp_mn_p')",0,1,,,,,"write_mn_p_DNL")
if k > 0
  mywait()
  use (tmp_file) new alias MN
  if is_talon .and. mn->kategor == 0
    is_talon := (is_kategor2 .and. mn->kategor2 > 0)
  endif
  Private mfio := "", madres := "", arr_vozr := List2Arr(mn->v_period)
  if !empty(mn->fio)
    mfio := alltrim(mn->fio)
    if !(right(mfio,1) == "*")
      mfio += "*"
    endif
  endif
  if !empty(mn->adres)
    madres := alltrim(mn->adres)
    if !(left(madres,1) == "*")
      madres := "*"+madres
    endif
    if !(right(madres,1) == "*")
      madres += "*"
    endif
  endif
  Private c_view := 0, c_found := 0
  Status_Key("^<Esc>^ - ��ࢠ�� ����")
  hGauge := GaugeNew(,,,"���� � ����⥪�",.t.)
  GaugeDisplay( hGauge )
  //
  dbcreate(cur_dir+"tmp",{{"kod","N",7,0}},,.t.,"TMP")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, recno() into KART2
  go top
  do while !eof()
    GaugeUpdate( hGauge, recno()/lastrec() )
    if inkey() == K_ESC
      fl_exit := .t. ; exit
    endif
    f1_mnog_poisk_DNL(@c_view,@c_found)
    select KART
    skip
  enddo
  CloseGauge(hGauge)
  j := tmp->(lastrec())
  close databases
  if j == 0
    if !fl_exit
      func_error(4,"��� ᢥ�����!")
    endif
  else
    stat_msg("���⠢����� ⥪�⮢��� � DBF-䠩���")
    use (tmp_file) new alias MN
    arr_title := {;
     "������",;
     " ��  �",;
     " ��  �",;
     "������"}
    if is_uchastok > 0 .or. mn->i_sort == 3 // ��� �� ����⥪�
      arr_title[1] += "����������"
      arr_title[2] += " ���⮪ �"
      arr_title[3] += "   ���   �"
      arr_title[4] += "����������"
    endif
    arr_title[1] += "��������������������������������������������������������������������������������������������������������������"
    arr_title[2] += "             �.�.�. ��樥��               ����   ���   �              ����                ���- ���᫥���� "
    arr_title[3] += "                (⥫�䮭)                  �� � ஦����� �                                   ��९.��/� �� ���"
    arr_title[4] += "��������������������������������������������������������������������������������������������������������������"
    reg_print := f_reg_print(arr_title,@sh,2)
    dbcreate(name_dbf,adbf,,.t.,"DVN")
    R_Use(dir_server+"human",dir_server+"humankk","HUMAN")
    R_Use(dir_server+"kartote2",,"KART2")
    R_Use(dir_server+"kartote_",,"KART_")
    R_Use(dir_server+"kartotek",,"KART")
    set relation to recno() into KART_, to recno() into KART2
    use (cur_dir+"tmp") new
    set relation to kod into KART
    if is_uchastok > 0
      if mn->i_sort == 1 // � ���⪠ + ��� ஦����� + ���
        index on str(kart->uchast,2)+str(mn->god-year(kart->date_r),4)+upper(kart->fio) to (cur_dir+"tmp")
      elseif mn->i_sort == 2 // � ���⪠ + ��� ஦����� + ����
        index on str(kart->uchast,2)+str(mn->god-year(kart->date_r),4)+upper(kart->adres) to (cur_dir+"tmp")
      elseif mn->i_sort == 4 // � ���⪠ + ���� + ��� ஦�����
        index on str(kart->uchast,2)+upper(kart->adres)+str(mn->god-year(kart->date_r),4) to (cur_dir+"tmp")
      elseif mn->i_sort == 3 // � ���⪠ + ���
        if is_uchastok == 1 // � ���⪠ + � � ���⪥
          index on str(kart->uchast,2)+str(kart->kod_vu,5)+upper(kart->fio) to (cur_dir+"tmp")
        elseif is_uchastok == 2 // � ���⪠ + ��� �� ����⥪�
          index on str(kart->uchast,2)+str(kart->kod,7) to (cur_dir+"tmp")
        elseif is_uchastok == 3 // � ���⪠ + ����� �� ���
          index on str(kart->uchast,2)+kart2->kod_AK+upper(kart->fio) to (cur_dir+"tmp")
        endif
      endif
    else
      if mn->i_sort == 1 // ��� ஦����� + ���
        index on str(mn->god-year(kart->date_r),4)+upper(kart->fio) to (cur_dir+"tmp")
      elseif mn->i_sort == 2 // ��� ஦����� + ����
        index on str(mn->god-year(kart->date_r),4)+upper(kart->adres) to (cur_dir+"tmp")
      elseif mn->i_sort == 3 // ��� �� ����⥪�
        index on str(kod,7) to (cur_dir+"tmp")
      endif
    endif
    fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
    add_string("")
    add_string(center(expand("��������� ���������������� ������"),sh))
    add_string("")
    add_string(" == ��������� ������ ==")
    add_string("� ����� ���� �� �뫮 ����ᬮ��/��ᯠ��ਧ�樨 ��ᮢ��襭����⭨�: "+lstr(mn->god))
    if !empty(mn->v_period)
      add_string("������� ��ਮ�� ����ᬮ��/��ᯠ��ਧ�樨: "+alltrim(mn->v_period))
    endif
    if mn->o_death == 1
      add_string("�� �᪫�祭��� 㬥��� (�� ᢥ����� �����)")
    elseif mn->o_death == 2
      add_string("���᮪ 㬥��� (�� ᢥ����� �����)")
    endif
    if !empty(mn->o_prik)
      add_string("�⭮襭�� � �ਪ९�����: "+inieditspr(A__MENUVERT, mm_prik, mn->o_prik))
    endif
    if is_uchastok > 0
      if !empty(mn->bukva)
        add_string("�㪢�: "+mn->bukva)
      endif
      if !empty(mn->uchast)
        add_string("���⮪: "+init_uchast(arr_uchast))
      endif
    endif
    if !empty(mfio)
      add_string("���: "+mfio)
    endif
    if mn->mi_git > 0
      add_string("���� ��⥫��⢠: "+inieditspr(A__MENUVERT, mm_mest, mn->mi_git))
    endif
    if !empty(mn->_okato)
      add_string("���� ॣ����樨 (�����): "+ret_okato_ulica('',mn->_okato))
    endif
    if !empty(madres)
      add_string("����: "+madres)
    endif
    if is_talon .and. mn->kategor > 0
      add_string("��� ��⥣�ਨ �죮��: "+inieditspr(A__MENUVERT, stm_kategor, mn->kategor))
    endif
    if is_talon .and. is_kategor2 .and. mn->kategor2 > 0
      add_string("��⥣��� ��: "+inieditspr(A__MENUVERT, stm_kategor2, mn->kategor2))
    endif
    if !empty(mn->pol)
      add_string("���: "+mn->pol)
    endif
    if !empty(mn->god_r_min) .or. !empty(mn->god_r_max)
      if empty(mn->god_r_min)
        add_string("���, த��訥�� �� "+full_date(mn->god_r_max))
      elseif empty(mn->god_r_max)
        add_string("���, த��訥�� ��᫥ "+full_date(mn->god_r_min))
      else
        add_string("���, த��訥�� � "+full_date(mn->god_r_min)+" �� "+full_date(mn->god_r_max))
      endif
    endif
    if !empty(mn->smo)
      add_string("���: "+inieditspr(A__MENUVERT, mm_smo, mn->smo))
    endif
    add_string("")
    add_string("������� ��樥�⮢: "+lstr(tmp->(lastrec()))+" 祫.")
    aeval(arr_title, {|x| add_string(x) } )
    ii := 0
    select TMP
    go top
    do while !eof()
      ++ii
      @ 24,1 say str(ii/tmp->(lastrec())*100,6,2)+"%" color cColorSt2Msg
      if inkey() == K_ESC
        fl_exit := .t. ; exit
      endif
      mdate := ctod("")
      select HUMAN
      find (str(tmp->kod,7))
      do while human->kod_k == tmp->kod .and. !eof()
        if empty(mdate)
          mdate := human->k_data
        else
          mdate := max(mdate,human->k_data)
        endif
        skip
      enddo
      select DVN
      append blank
      s1 := padr(lstr(ii),6)
      if is_uchastok > 0 .or. mn->i_sort == 3
        if is_uchastok > 0
          s := ""
          if !empty(kart->uchast)
            dvn->UCHAST := kart->uchast
            s += lstr(kart->uchast)
          endif
          if is_uchastok == 1 .and. !empty(kart->kod_vu) // � ���⪠ + � � ���⪥
            s += "/"+lstr(kart->kod_vu)
            dvn->KOD_VU := kart->kod_vu
          elseif is_uchastok == 2 // � ���⪠ + ��� �� ����⥪�
            s += "/"+lstr(kart->kod)
            dvn->KOD_VU := kart->kod
          elseif is_uchastok == 3 .and. !empty(kart2->kod_AK) // � ���⪠ + ����� �� ���
            s += "/"+ltrim(kart2->kod_AK)
            dvn->KOD_VU := val(kart2->kod_AK)
          endif
        else
          s := padl(lstr(tmp->kod),9)
        endif
        s1 += padr(s,10)
      endif
      s := ""
      if !empty(kart_->PHONE_H)
        s += "�."+alltrim(kart_->PHONE_H)+" "
      endif
      if !empty(kart_->PHONE_M)
        s += "�."+alltrim(kart_->PHONE_M)+" "
      endif
      if !empty(kart_->PHONE_W)
        s += "�."+alltrim(kart_->PHONE_W)
      endif
      dvn->FIO := kart->fio
      dvn->PHONE := s
      s := alltrim(kart->fio)+" "+s
      k_fio := perenos(tt_fio,s,43)
      s1 += padr(tt_fio[1],44)
      s1 += str(mn->god-year(kart->date_r),2)+" "
      s1 += full_date(kart->date_r)+" "
      dvn->POL := kart->pol
      dvn->DATE_R := full_date(kart->date_r)
      dvn->LET := mn->god-year(kart->date_r)
      k_adr := perenos(tt_adr,kart->adres,35)
      s1 += padr(tt_adr[1],36)
      dvn->ADRESR := kart->adres
      dvn->ADRESP := kart_->adresp
      dvn->POLIS := ltrim(kart_->NPOLIS)
      dvn->KOD_SMO := kart_->smo
      dvn->SMO := smo_to_screen(1)
      dvn->SNILS := iif(empty(kart->SNILS),"",transform(kart->SNILS,picture_pf))
      if !empty(dvn->mo_pr := kart2->mo_pr)
        dvn->MONAME_PR := ret_mo(kart2->mo_pr)[_MO_SHORT_NAME]
        if !empty(kart2->pc4)
          dvn->DATE_PR := left(kart2->pc4,6)+"20"+substr(kart2->pc4,7)
        else
          dvn->DATE_PR := full_date(kart2->DATE_PR)
        endif
      endif
      if empty(kart2->MO_PR)
        s := ""
      elseif kart2->MO_PR == glob_mo[_MO_KOD_TFOMS]
        s := "���"
      else
        s := "�㦮�"
      endif
      s1 += padr(s,6)
      s1 += full_date(mdate)
      dvn->last_l_u := full_date(mdate)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(s1)
      for i := 2 to max(k_fio,k_adr)
        s1 := space(6)
        if is_uchastok > 0 .or. mn->i_sort == 3
          s1 += space(10)
        endif
        s1 += padr(tt_fio[i],44)
        s1 += space(14)
        s1 += tt_adr[i]
        add_string(s1)
      next
      add_string(replicate("-",sh))
      select TMP
      skip
    enddo
    if fl_exit
      add_string("*** "+expand("�������� ��������"))
    else
      add_string("�⮣� ������⢮ ��樥�⮢: "+lstr(tmp->(lastrec()))+" 祫.")
    endif
    fclose(fp)
    close databases
    restscreen(buf)
    viewtext(name_file,,,,.t.,,,reg_print)
    n_message({"������ 䠩� ��� ����㧪� � Excel: "+name_dbf},,cColorStMsg,cColorStMsg,,,cColorSt2Msg)
  endif
endif
close databases
restscreen(buf) ; setcolor(tmp_color)
return NIL

***** 31.10.16
Function write_mn_p_DNL(k)
Local fl := .t.
if k == 1
  if empty(mgod)
    fl := func_error(4,'������ ���� ��������� ���� "��� �஢������ ����ᬮ��/��ᯠ��ਧ�樨"')
  elseif empty(mv_period)
    fl := func_error(4,'������ ���� ����� ��� �� ���� �����⭮� ��ਮ� ����ᬮ��/��ᯠ��ਧ�樨')
  endif
endif
return fl

*

***** 21.11.19
Static Function f1_mnog_poisk_DNL(cv,cf)
Local i, j, k, n, s, arr, fl, god_r, arr1, vozr
++cv
vozr := mn->god - year(kart->date_r)
if (fl := (vozr < 18))
  fl := (ascan(arr_vozr,vozr) > 0)
endif
if fl
  select HUMAN
  find (str(kart->kod,7))
  do while human->kod_k == kart->kod .and. !eof()
    if year(human->k_data) == mn->god .and. eq_any(human->ishod,101,102,301,302,303,304,305)
      fl := .f. ; exit
    endif
    skip
  enddo
endif
if fl .and. !empty(mn->o_prik)
  if mn->o_prik == 1 // � ��襩 ��
    fl := (kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  elseif mn->o_prik == 2 // � ��㣨� ��
    fl := !(kart2->MO_PR == glob_mo[_MO_KOD_TFOMS])
  else // �ਪ९����� �������⭮
    fl := empty(kart2->MO_PR)
  endif
endif
if fl .and. mn->o_death > 0
  if mn->o_death == 1 // �� �᪫�祭��� 㬥��� (�� ᢥ����� �����)
    fl := !(left(kart2->PC2,1) == "1")
  elseif mn->o_death == 2 // ���᮪ 㬥��� (�� ᢥ����� �����)
    fl := (left(kart2->PC2,1) == "1")
  endif
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->bukva)
  fl := (mn->bukva == kart->bukva)
endif
if fl .and. is_uchastok > 0 .and. !empty(mn->uchast)
  fl := f_is_uchast(arr_uchast,kart->uchast)
endif
if fl .and. !empty(mfio)
  fl := like(mfio,upper(kart->fio))
endif
if fl .and. !empty(madres)
  fl := like(madres,upper(kart->adres))
endif
if fl .and. is_talon .and. mn->kategor > 0
  fl := (mn->kategor == kart_->kategor)
endif
if fl .and. is_kategor2 .and. mn->kategor2 > 0
  fl := (mn->kategor2 == kart_->kategor2)
endif
if fl .and. !empty(mn->pol)
  fl := (kart->pol == mn->pol)
endif
if fl .and. !empty(mn->god_r_min)
  fl := (mn->god_r_min <= kart->date_r)
endif
if fl .and. !empty(mn->god_r_max)
  fl := (human->date_r <= mn->god_r_max)
endif
if fl .and. mn->mi_git > 0
  if mn->mi_git == 1
    fl := (left(kart_->okatog,2)=='18')
  else
    fl := !(left(kart_->okatog,2)=='18')
  endif
endif
if fl .and. !empty(mn->_okato)
  s := mn->_okato
  for i := 1 to 3
    if right(s,3)=='000'
      s := left(s,len(s)-3)
    else
      exit
    endif
  next
  fl := (left(kart_->okatog,len(s))==s)
endif
if fl .and. !empty(mn->smo)
  fl := (kart_->smo == mn->smo)
endif
if fl
  select TMP
  append blank
  tmp->kod := kart->kod
  if ++cf % 5000 == 0
    tmp->(dbCommit())
  endif
endif
@ 24,1 say lstr(cv) color cColorSt2Msg
@ row(),col() say "/" color "W/R"
@ row(),col() say lstr(cf) color cColorStMsg
return NIL

***** 31.10.16 ����� � GET-� �������� ��ਮ��� �������஢ ��ᮢ��襭����⭨�
Function f2_mnog_poisk_DNL(k,r,c,par)
Static sast, sarr
Local buf := save_maxrow(), a, i, j, s, s1
DEFAULT par TO 2
if sast == NIL
  sast := {} ; sarr := {}
  for j := 0 to 17
    aadd(sast,.t.)
    s := lstr(j)
    if j == 1
      s += " ���"
    elseif between(j,2,4)
      s += " ����"
    else
      s += " ���"
    endif
    aadd(sarr,{s,j})
  next
endif
s := s1 := ""
if par == 1
  sast := {}
  for i := 1 to len(sarr)
    aadd(sast,.t.)
    s += lstr(sarr[i,2])+iif(i<len(sarr),",","")
  next
  s1 := "��"
elseif (a := bit_popup(r,c,sarr,sast)) != NIL
  afill(sast,.f.)
  for i := 1 to len(a)
    if (j := ascan(sarr,{|x| x[2]==a[i,2] })) > 0
      sast[j] := .t.
      s += lstr(a[i,2])+iif(i<len(a),",","")
    endif
  next
  if len(a) == len(sast)
    s1 := "��"
  endif
endif
if empty(s)
  s := space(10)
endif
if empty(s1)
  s1 := s
endif
return {s,s1}

*

***** 18.12.13 ������ ���㬥��� �� �ᥬ ����� ��ᯠ��ਧ�樨 � ��䨫��⨪�
Function inf_DISP(k)
Static si1 := 1, si2 := 1
Local mas_pmt, mas_msg, mas_fun
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~�⮣� ��� �����"}
    mas_msg := {"�⮣� �� ��ਮ� �६��� ��� �����"}
    mas_fun := {"inf_DISP(11)"}
    popup_prompt(T_ROW,T_COL-5,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
   itog_svod_DISP_TF()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  elseif between(k,21,29)
    si2 := j
  endif
endif
return NIL

*

***** 18.12.13 �⮣� �� ��ਮ� �६��� ��� �����
Function itog_svod_DISP_TF()
Local i, k, arr_m, buf := save_maxrow(), ;
      sh := 80, hh := 60, n_file := "svod_dis"+stxt
if (arr_m := year_month(,,,5)) != NIL
  mywait()
  dbcreate(cur_dir+"tmpk",{{"kod","N",7,0},;
                           {"tip","N",1,0}})
  use (cur_dir+"tmpk") new
  index on str(tip,1)+str(kod,7) to (cur_dir+"tmpk")
  dbcreate(cur_dir+"tmp",{{"tip",  "N",1,0},;
                          {"kol_s","N",6,0},;
                          {"kol_o","N",6,0},;
                          {"kol_p","N",6,0}})
  use (cur_dir+"tmp") new
  index on str(tip,1) to (cur_dir+"tmp")
  R_Use(dir_server+"mo_rak",,"RAK")
  R_Use(dir_server+"mo_raks",,"RAKS")
  set relation to akt into RAK
  R_Use(dir_server+"mo_raksh",,"RAKSH")
  set relation to kod_raks into RAKS
  index on str(kod_h,7)+dtos(rak->dakt) to (cur_dir+"tmpraksh")
  R_Use(dir_server+"mo_rpd",,"RPD")
  R_Use(dir_server+"mo_rpds",,"RPDS")
  set relation to pd into RPD
  R_Use(dir_server+"mo_rpdsh",,"RPDSH")
  set relation to kod_rpds into RPDS
  index on str(kod_h,7)+dtos(rpd->d_pd) to (cur_dir+"tmprpdsh")
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humand","HUMAN")
  set relation to recno() into HUMAN_
  dbseek(dtos(arr_m[5]),.t.)
  index on kod to (cur_dir+"tmp_h") ;
        for ishod > 100 .and. human_->oplata != 9 .and. schet > 0 ;
        while human->k_data <= arr_m[6] ;
        PROGRESS
  i := 0
  go top
  do while !eof()
    ++i
    @ maxrow(),1 say lstr(i) color cColorWait
    ltip := 0
    select SCHET_
    goto (human->schet)
    if !schet_->(eof()) .and. schet_->NREGISTR == 0 // ⮫쪮 ��ॣ����஢����
      if eq_any(human->ishod,101,102)
        ltip := iif(empty(human->za_smo), 2, 1)
      elseif eq_any(human->ishod,301,302)
        ltip := 3
      elseif eq_any(human->ishod,303,304)
        m1gruppa := human_->RSLT_NEW - 316
        if between(m1gruppa,1,3)
          ltip := 4
        endif
      elseif human->ishod == 305
        ltip := 5
      elseif eq_any(human->ishod,201,202)
        ltip := 6
      elseif human->ishod == 203
        ltip := 7
      endif
    endif
    if ltip > 0
      select TMPK
      find (str(ltip,1)+str(human->kod_k,7))
      if !found()
        append blank
        tmpk->tip := ltip
        tmpk->kod := human->kod_k
        if lastrec() % 2000 == 0
          commit
        endif
      endif
      select TMP
      find (str(ltip,1))
      if !found()
        append blank
        tmp->tip := ltip
      endif
      tmp->kol_s ++
      //
      k := 0
      select RAKSH
      find (str(human->kod,7))
      do while raksh->kod_h == human->kod .and. !eof()
        if raksh->IS_REPEAT < 1
          k := iif(raksh->SUMP > 0, 1, 0)
        endif
        skip
      enddo
      if k == 1
        tmp->kol_o ++
      endif
      //
      k := 0
      select RPDSH
      find (str(human->kod,7))
      do while rpdsh->kod_h == human->kod .and. !eof()
        k += rpdsh->S_SL
        skip
      enddo
      if k > 0
        tmp->kol_p ++
      endif
    endif
    select HUMAN
    skip
  enddo
  //
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(glob_mo[_MO_SHORT_NAME])
  add_string("")
  add_string(center("�⮣� �� ��ᯠ��ਧ�樨, ��䨫��⨪� � ����ᬮ�ࠬ",sh))
  add_string(center("[ "+charrem("~",mas1pmt[3])+" ]",sh))
  add_string(center(arr_m[4],sh))
  add_string("")
  add_string("��������������������������������������������������������������������������������")
  add_string("                                        � ���-��  � ���-��  � ���-��  � ���-��  ")
  add_string("                                        � ��砥� � 祫���� � ��砥�,� ��砥�,")
  add_string("                                        �         �         � �ਭ���峮���祭�.")
  add_string("                                        �         �         � � ����⥳���������")
  add_string("                                        �         �         �         ���� ���.")
  add_string("��������������������������������������������������������������������������������")
  for i := 1 to 7
    s :=    {"��ᯠ��ਧ��� ��⥩-��� � ��樮���",;
             "��ᯠ��ਧ��� ��⥩-��� ��� ������",;
             "��䨫����.�ᬮ��� ��ᮢ��襭����⭨�",;
             "�।���⥫�.�ᬮ��� ��ᮢ��襭����⭨�",;
             "��ਮ���᪨� �ᬮ��� ��ᮢ��襭����⭨�",;
             "��ᯠ��ਧ��� ���᫮�� ��ᥫ����",;
             "��䨫��⨪� ���᫮�� ��ᥫ����"}[i]
    select TMP
    find (str(i,1))
    if found()
      k := 0
      select TMPK
      find (str(i,1))
      do while tmpk->tip == i .and. !eof()
        ++k
        skip
      enddo
      s := padr(s,40)+put_val(tmp->kol_s, 9)+;
                      put_val(k         ,10)+;
                      put_val(tmp->kol_o,10)+;
                      put_val(tmp->kol_p,10)
    endif
    add_string(s)
    add_string(replicate("�",sh))
  next
  close databases
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,.f.,,,2)
endif
return NIL

***** 18.01.21 �������� 䠩�� ������ R11...
Function f_create_R11()
Local buf := save_maxrow(), i, j, ir, s := "", arr := {}, fl := .t., fl1 := .f., a_reestr := {}, ar
Private SMONTH := 1, mdate := sys_date, mrec := 1
Private c_view := 0, c_found := 0, fl_exit := .f., pj, arr_rees := {},;
        pkol := 0, CODE_LPU := glob_mo[_MO_KOD_TFOMS], CODE_MO := glob_mo[_MO_KOD_FFOMS],;
        mkol := {0,0,0,0,0}, skol[5], ames[12,5], ame[12], bm := SMONTH,; // ��砫�� ����� ����� ����
        _arr_vozrast_DVN := ret_arr_vozrast_DVN(0d20211201)

Private sgod := 2022
//
mywait()
fl := .t.
fl_1 := .f.
SMONTH := lm := MONTH_UPLOAD //�����
dbcreate(cur_dir+"tmp_00",{;
   {"reestr",     "N", 6,0},;
   {"kod",        "N", 7,0},; // ��� �� ����⥪�
   {"tip",        "N", 1,0},; // 1-��ᯠ��ਧ���, 2-���ᬮ��
   {"tip1",       "N", 1,0},; // 1-���ᨮ���,2-65 ���,3-66 ��� � ����
   {"voz",        "N", 1,0};  // 1-65 ���, 2-66 ��� � ����, 3-���ᨮ���, 4-��⠫��
  })
R_Use(dir_server+"mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R12 .and. empty(TIP_OUT)
R_Use(dir_server+"mo_dr01",,"REES")
index on str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. eq_any(NMONTH,SMONTH-1,SMONTH) .and. tip == 1
go top
do while !eof()

  if rees->kol_err < 0
    //fl := func_error(4,"� 䠩�� R12 �� "+lstr(rees->NMONTH)+"-� ����� "+;
    //                   lstr(sgod)+"�. �訡�� �� �஢�� 䠩��! ������ ����饭�")
  elseif empty(rees->answer)
    fl := func_error(4,"���� PR11 �� "+lstr(rees->NMONTH)+"-� ����� "+;
                       lstr(sgod)+" ���� �� �� ���⠭! ������ ����饭�")
  else
    select MO_XML
    find (str(rees->kod,6))
    if found()
      if empty(mo_xml->TWORK2)
        fl := func_error(4,"��ࢠ�� �⥭�� 䠩�� "+alltrim(mo_xml->FNAME)+;
                           "! ���㫨��� (Ctrl+F12) � ���⠩� ᭮��")
      elseif rees->NMONTH == SMONTH
        aadd(arr_rees,rees->kod)
      endif
    endif
  endif
  select REES
  skip
enddo
if fl
  fl_1 := !empty(arr_rees)
else
  close databases
  return NIL
endif

if fl_1 .or. code_lpu == "321001"// �� ���� ࠧ
  R_Use(dir_server+"mo_dr05p",,"R05p")
  goto (mrec)
  skol[1] := r05p->KOL1
  skol[2] := r05p->KOL2
  skol[3] := r05p->KOL11
  skol[4] := r05p->KOL12
  skol[5] := r05p->KOL13
  skol[1] -= skol[3]
  skol[3] -= skol[4]
  skol[3] -= skol[5]
  for i := 1 to 12
    for j := 1 to 2
      ames[i,j] := { &("r05p->kol"+lstr(j)+"_"+strzero(i,2)), 0 }
    next
    for j := 1 to 3
      ames[i,j+2] := { &("r05p->kol1"+lstr(j)+"_"+strzero(i,2)), 0 }
    next
    ames[i,1,1] -= ames[i,3,1]
    ames[i,3,1] -= ames[i,4,1]
    ames[i,3,1] -= ames[i,5,1]
  next
  // ⮫쪮 ��� �㦭��� �����
  for j := 1 to 5
    skol[j] := ames[SMONTH,j,1]
  next

  afill(ame,0)
  //
  if fl
    R_Use(dir_server+"mo_dr01k",,"R01k")
    index on str(reestr,6)+str(kod_k,7) to (cur_dir+"tmp_dr01k")
    R_Use(dir_server+"kartotek",,"KART")
    Use (dir_server+"mo_dr00") new alias TMP
    index on kod to (cur_dir+"tmp_dr00") for reestr == 0 .and. kod > 0
    go top
    do while !eof()
      kart->(dbGoto(tmp->kod))
      ar := f0_create_R11(sgod)
      if !(tmp->tip == ar[1] .and. tmp->tip1 == ar[2] .and. tmp->voz == ar[3])
        tmp->tip := 0
      endif
      j := tmp->tip
      j1 := tmp->tip1
      tmp->n_m := tmp->n_q := 0 // �᫨ 㦥 ��室��� � ०�� � �� ���⢥न�� ᮧ����� XML
      if between(j,1,2)
        if between(j1,1,3)
          mkol[j1+2] ++
        else
          mkol[j] ++ // ������� ��⠢襣��� ���-�� � �㫥 ��樥�⮢
        endif
      endif
      skip
    enddo
    commit

    index on str(reestr,6) to (cur_dir+"tmp_dr00")
    for ir := 1 to len(arr_rees)
      select R01k
      find (str(arr_rees[ir],6))
      do while r01k->reestr == arr_rees[ir] .and. !eof()
        if r01k->oplata == 1  // ���� � �����
          j := r01k->tip
          j1 := r01k->tip1
          if !between(j,1,2)
            fl := func_error(4,"�����४�� ��� �ᬮ�� � 䠩�� MO_DR01k.DBF! ������ ����饭�")
            exit
          endif
          if between(j1,1,3)
            ames[SMONTH,j1+2,2] ++
            skol[j1+2] --
          else
            ames[SMONTH,j,2] ++
            skol[j] --
          endif
        endif
        select R01k
        skip
      enddo
      if !fl ; exit ; endif
    next ir
    if emptyall(skol[1],skol[2],skol[3],skol[4],skol[5])
      fl := func_error(4,"����� �� �ॡ���� ᮧ����� 䠩��� ������!")
    else
      for j := 1 to 5
        if mkol[j] < skol[j]
          s := {"��ᯠ��ਧ�権","���ᬮ�஢","���.���ᨮ��஢","���.65 ���","���.66 ��� � ����"}[j]
          fl := func_error(4,"�� 墠⠥� "+lstr(skol[j]-mkol[j])+" 祫. � ����⥪� ��� ���ᬮ�஢")
        endif
      next
    endif
  endif

  if fl
    mywait()
    for v := 1 to 5
      j := {2,4,5,3,1}[v]
      // ���冷�: 2-���ᬮ��, 4-65 ���, 5-66 � ����, 3-���ᨮ����, 1-��⠫쭠� ���-��
      if empty(skol[j])
        loop
      endif
      pj := j
      d := koef := int(mkol[j] / skol[j]) + 1 // �१ ᪮�쪮 ����ᥩ ��룠��
      if d > 40
        d := koef := 31
      endif
      i := 0
      do while skol[j] > 0
        select TMP
        if j == 2
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 2 .and. tmp->n_q == 0 //DESCENDING
        elseif j == 1
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_q == 0 //DESCENDING
        else
          index on kod to (cur_dir+"tmp_dr00") for eq_any(tmp->tip,1,2) .and. tmp->tip1 == pj-2 .and. tmp->n_q == 0 //DESCENDING
        endif
        go top
        do while !eof()
          if d == koef
            i := SMONTH
            if ames[i,j,1] > ames[i,j,2] // �᫨ ��� �� ���ࠫ� �����
              tmp->n_m := i
              ames[i,j,2] ++
              skol[j] --
            endif
            d := 0
          endif
          ++d
          if empty(skol[j])
            exit
          endif
          skip
        enddo
        select TMP
        if j == 2
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 2 .and. tmp->n_m > 0
        elseif j == 1
          index on kod to (cur_dir+"tmp_dr00") for tmp->tip == 1 .and. tmp->tip1 == 0 .and. tmp->n_m > 0
        else
          index on kod to (cur_dir+"tmp_dr00") for eq_any(tmp->tip,1,2) .and. tmp->tip1 == pj-2 .and. tmp->n_m > 0
        endif
        go top
        do while !eof()
          if tmp->n_q == 0 .and. tmp->n_m == SMONTH
            tmp->n_q := int((tmp->n_m+2)/3) // ��।��塞 ����� ����⠫� �� ������
            ame[tmp->n_m] ++
          endif
          skip
        enddo
      enddo
    next v
    Use (cur_dir+"tmp_00") new alias TMP1
    select TMP
    index on kod to (cur_dir+"tmp_dr00") for reestr == 0 .and. n_m > 0
    go top
    do while !eof()
      select TMP1
      append blank
      tmp1->kod  := tmp->KOD
      tmp1->tip  := tmp->tip
      tmp1->tip1 := tmp->tip1
      tmp1->voz  := tmp->voz
      select TMP
      skip
    enddo
  endif
  //quit
else // ���� ࠧ
/*  select REES
  index on str(NMONTH,2)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
  find (str(lm,2))
  do while lm == rees->NMONTH .and. !eof()
    aadd(arr_rees,rees->kod) // ᯨ᮪ R01 �� 䥢ࠫ�
    skip
  enddo
  Use (cur_dir+"tmp_00") new alias TMP
  R_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"mo_dr01k",,"RHUM",.T.,.T.)
  index on str(REESTR,6) to (cur_dir+"tmp_rhum")
  for i := 1 to len(arr_rees)
    select RHUM
    find (str(arr_rees[i],6))
    do while rhum->REESTR == arr_rees[i] .and. !eof()
      kart->(dbGoto(rhum->kod_k))
      if rhum->oplata == 1
        if rhum->tip == 2 // ���ᬮ��
          ar := f0_create_R11(sgod)
          if rhum->tip == ar[1] .and. rhum->tip1 == ar[2] .and. rhum->voz == ar[3]
            select TMP
            append blank
            tmp->kod  := rhum->KOD_K
            tmp->tip  := rhum->tip
            tmp->tip1 := rhum->tip1
            tmp->voz  := rhum->voz
          endif
        else
          rhum->oplata := 2 // �� � �訡��
        endif
      endif
      select RHUM
      skip
    enddo
  next */

  //
  select REES
  index on str(NMONTH,2)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
  find (str(lm,2))
  do while lm == rees->NMONTH .and. !eof()
    aadd(arr_rees,rees->kod) // ᯨ᮪ R01 �� 䥢ࠫ�
    skip
  enddo
  Use (cur_dir+"tmp_00") new alias TMP
  R_Use(dir_server+"kartotek",,"KART")
  G_Use(dir_server+"mo_dr01k",,"RHUM")
  index on str(REESTR,6) to (cur_dir+"tmp_rhum")
  for i := 1 to len(arr_rees)
    select RHUM
    find (str(arr_rees[i],6))
    do while rhum->REESTR == arr_rees[i] .and. !eof()
      kart->(dbGoto(rhum->kod_k))
      if rhum->oplata == 1
        ar := f0_create_R11(sgod)
        if rhum->tip == ar[1] .and. rhum->tip1 == ar[2] .and. rhum->voz == ar[3]
          select TMP
          append blank
          tmp->kod  := rhum->KOD_K
          tmp->tip  := rhum->tip
          tmp->tip1 := rhum->tip1
          tmp->voz  := rhum->voz
        endif
      endif
      select RHUM
      skip
    enddo
  next
endif

close databases
if fl
  f1_create_R11(lm,fl_1)
endif
return NIL

***** 09.02.20 ��८�।����� �� �� ��ࢨ��� ���� � ����⥪�
Static Function f0_create_R11(sgod)
Local fl, v, ltip := 0, ltip1 := 0, lvoz := 0, ag, lgod_r
if !emptyany(kart->kod,kart->fio,kart->date_r) // ������ ������ � ����⥪� ������� 㤠����
  lgod_r := year(kart->date_r)
  v := sgod - lgod_r
  if (fl := (v > 17)) // ⮫쪮 ���᫮� ��ᥫ����
    lvoz := 4
    ltip1 := 0
    if ascan(_arr_vozrast_DVN,v) > 0
      ltip := 1 // ��ᯠ��ਧ���
      // 1-65 ���, 2-66 ��� � ����, 3-���ᨮ���, 4-��稥
      if v >= iif(kart->POL == "�", 60, 55)
        lvoz := 3
        ltip1 := 1
        if v == 65
          lvoz := 1
          ltip1 := 2
        elseif v > 65
          lvoz := 2
          ltip1 := 3
        endif
      endif
    else
      ltip := 2 // ���ᬮ���
    endif
  endif
endif
return {ltip,ltip1,lvoz}

***** 22.10.21
Function f1_create_R11(lm,fl_dr00)
Local nsh := 3, smsg, lnn := 0 ,buf := save_maxrow()
if !f_Esc_Enter("ᮧ����� 䠩�� R11",.t.)
  return NIL
endif
if eq_any(CODE_LPU,'124528','184603','141016') .and. hb_fileExists(dir_server+"b18"+sdbf)
  lnn := 100 // ᯥ樠�쭮 ��� 28-�� �-�� ��᫥ ��ꥤ������ � 18-�� �-楩
             // ��� ��� 3-�� �-�� ��᫥ ��ꥤ������ � 12-�� �-���
             // ��� ��� �16 ��᫥ ��쥤������ � �24
endif
G_Use(dir_server+"mo_dr01m",,"RM")
AddRecN()
rm->DWORK := sys_date
rm->TWORK1 := hour_min(seconds())
UnLock
//
G_Use(dir_server+"mo_dr01k",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
G_Use(dir_server+"mo_dr01",,"REES")
index on str(NMONTH,2)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 1
find (str(lm,2))
do while lm == rees->NMONTH .and. !eof()
  if lnn < rees->nn
    lnn := rees->nn
  endif
  skip
enddo
set index to
G_Use(dir_server+"mo_xml",,"MO_XML")
R_Use(dir_server+"kartote2",,"KART2")
R_Use(dir_server+"kartote_",,"KART_")
R_Use(dir_server+"kartotek",,"KART")
set relation to recno() into KART_, recno() into KART2
if fl_dr00
  G_Use(dir_server+"mo_dr00",,"DR00")
  index on str(kod,7) to (cur_dir+"tmp_dr00")
endif
Use (cur_dir+"tmp_00") new alias TMP
set relation to kod into KART
index on upper(kart->fio)+dtos(kart->date_r) to (cur_dir+"tmp_00")
//
  SMONTH := lm
  smsg := "���⠢����� 䠩�� R11 �� "+lstr(SMONTH)+"-� �����"
  stat_msg(smsg)
  select REES
  AddRecN()
  rees->KOD    := recno()
  rees->tip    := 1
  rees->DSCHET := sys_date
  rees->NYEAR  := sgod
  rees->NMONTH := SMONTH
  rees->NN     := lnn+1
  s := "R11"+"T34M"+CODE_LPU+"_"+right(strzero(rees->NYEAR,4),2)+strzero(rees->NMONTH,2)+strzero(rees->NN,nsh)
  rees->NAME_XML := s
  mkod_reestr := rees->KOD
  //
  rm->(G_RLock(forever))
  &("rm->reestr"+strzero(SMONTH,2)) := mkod_reestr
  //
  select MO_XML
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := s
  mo_xml->FNAME2 := ""
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_IN := 0
  mo_xml->TIP_OUT := _XML_FILE_R11  // ⨯ ���뫠����� 䠩�� - R11
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  UnLock
  Commit
  pkol := 0
  select TMP
  go top
  do while !eof()
    if tmp->reestr == 0
      ++pkol
      @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
      if fl_dr00 // ��� ��ண� � �.�. ॥��஢ � �����
        select DR00
        find (str(tmp->kod,7))
        if found()
          G_RLock(forever)
          dr00->reestr := mkod_reestr
        endif
      endif
      //
      select RHUM
      AddRec(6)
      rhum->REESTR := mkod_reestr
      rhum->KOD_K := tmp->kod
      rhum->n_m := SMONTH
      rhum->tip := tmp->tip
      rhum->tip1 := tmp->tip1
      rhum->voz := tmp->voz
      rhum->R01_ZAP := pkol
      rhum->ID_PAC := mo_guid(1,tmp->kod)
      rhum->OPLATA := 0
    endif
    if pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    select TMP
    skip
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
    mo_add_xml_stroke(oXmlNode,"VERSION",'3.0')
    mo_add_xml_stroke(oXmlNode,"CODEM",CODE_LPU)
    mo_add_xml_stroke(oXmlNode,"DATE_F",date2xml(mo_xml->DFILE))
    mo_add_xml_stroke(oXmlNode,"NAME_F",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SMO",'34')
    mo_add_xml_stroke(oXmlNode,"YEAR",lstr(rees->NYEAR))
    mo_add_xml_stroke(oXmlNode,"MONTH",lstr(rees->NMONTH))
    mo_add_xml_stroke(oXmlNode,"N_PACK",lstr(rees->NN))
  //
  select RHUM
  set relation to kod_k into KART
  index on str(R01_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR == mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->R01_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    arr_fio := retFamImOt(1,.f.)
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERSONS" ) )
    mo_add_xml_stroke(oXmlNode,"ZAP",lstr(rhum->R01_ZAP))
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
    mo_add_xml_stroke(oXmlNode,"CATEGORY",'0')
    mo_add_xml_stroke(oXmlNode,"T_PR",{"O","R"}[rhum->tip])
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
    select RHUM
    skip
  enddo
  stat_msg("������ XML-䠩��")
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  chip_create_zipXML(alltrim(mo_xml->FNAME)+szip,{alltrim(mo_xml->FNAME)+sxml},.t.)
rm->(G_RLock(forever))
rm->TWORK2 := hour_min(seconds())
close databases
keyboard chr(K_TAB)+chr(K_ENTER)
rest_box(buf)
return NIL

***** 28.12.21
Function delete_reestr_R11()
Local t_arr[BR_LEN], blk
if ! hb_user_curUser:IsAdmin()
  return func_error(4,err_admin)
endif
G_Use(dir_server+"mo_dr01m",,"R01m")
index on descend(dtos(DWORK)+TWORK1) to (cur_dir+"tmp_dr01m")
go top
if eof()
  func_error(4,"�� �뫮 ᮧ���� 䠩��� R11...")
else
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "���᮪ ᮧ������ ����⮢ ॥��஢ R11"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {'�','�','�',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(empty(r01m->twork2),{3,4},{1,2}) }
  t_arr[BR_COLUMN] := {;
   { "  ���;ᮧ�����",{|| date_8(r01m->dwork) }, blk },;
   { "ﭢ;���", {|| iif(r01m->reestr01 > 0,"�� ","���") }, blk },;
   { "䥢;ࠫ", {|| iif(r01m->reestr02 > 0,"�� ","���") }, blk },;
   { "���;�  ", {|| iif(r01m->reestr03 > 0,"�� ","���") }, blk },;
   { "���;���", {|| iif(r01m->reestr04 > 0,"�� ","���") }, blk },;
   { "���;   ", {|| iif(r01m->reestr05 > 0,"�� ","���") }, blk },;
   { "��;�  ", {|| iif(r01m->reestr06 > 0,"�� ","���") }, blk },;
   { "��;�  ", {|| iif(r01m->reestr07 > 0,"�� ","���") }, blk },;
   { "���;���", {|| iif(r01m->reestr08 > 0,"�� ","���") }, blk },;
   { "ᥭ;��", {|| iif(r01m->reestr09 > 0,"�� ","���") }, blk },;
   { "���;��", {|| iif(r01m->reestr10 > 0,"�� ","���") }, blk },;
   { "���;���", {|| iif(r01m->reestr11 > 0,"�� ","���") }, blk },;
   { "���;���", {|| iif(r01m->reestr12 > 0,"�� ","���") }, blk },;
   { "�६�;��砫�",    {|| r01m->twork1 }, blk },;
   { "�६�;����砭��", {|| padr(iif(empty(r01m->twork2),"�� ���������",r01m->twork2),10) }, blk };
  }
  t_arr[BR_EDIT] := {|nk,ob| f1_delete_reestr_R11(nk,ob,"edit") }
  t_arr[BR_FL_INDEX] := .f.
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - ��室;  ^<Enter>^ - ���㫨஢���� ᮧ����� ����� ॥��஢ R01") }
  edit_browse(t_arr)
endif
close databases
return NIL

***** 09.02.20
Function f1_delete_reestr_R11(nKey,oBrow,regim)
Local ret := -1, rec_m := r01m->(recno()), ir, fl := .t.
if regim == "edit" .and. nKey == K_ENTER
  if empty(r01m->twork2)
    G_Use(dir_server+"mo_dr01",,"REES")
    for ir := 1 to 12
      mkod_reestr := &("r01m->reestr"+strzero(ir,2))
      if mkod_reestr > 0
        select REES
        goto (mkod_reestr)
        if rees->tip == 0
          fl := func_error(4,"�� 䠩� R01. ������ ����饭�!")
          exit
        elseif rees->ANSWER == 1
          fl := func_error(4,"��� ����祭 �⢥� PR11 �� "+lstr(ir)+"-� �����. ������ ����饭�!")
          exit
        endif
      endif
    next
    REES->(dbCloseArea())
    select R01m
    if fl .and. f_Esc_Enter("���㫨஢���� R11")
      mywait()
      f2_delete_reestr_R11(rec_m)
      stat_msg("���㫨஢���� �����襭�!") ; mybell(2,OK)
      ret := 1
    endif
  else
    func_error(4,"����� ᮧ����� ॥��� R11 ������� ���४⭮. ������ ����饭�!")
  endif
endif
return ret

***** 09.02.20 ���㫨஢��� �⥭�� ॥��� R11
Function f2_delete_reestr_R11(rec_m)
Local ir, mkod_reestr
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"mo_dr00",,"TMP")
index on str(REESTR,6) to (cur_dir+"tmp_dr00")
G_Use(dir_server+"mo_dr01k",,"RHUM")
index on str(REESTR,6) to (cur_dir+"tmp_rhum")
G_Use(dir_server+"mo_dr01",,"REES")
select R01m
goto (rec_m)
for ir := 12 to 1 step -1
  mkod_reestr := &("r01m->reestr"+strzero(ir,2))
  if mkod_reestr > 0
    select REES
    goto (mkod_reestr)
    select TMP
    do while .t.
      find (str(mkod_reestr,6))
      if !found() ; exit ; endif
      G_Rlock(forever)
      tmp->n_m := 0
      tmp->n_q := 0
      tmp->reestr := 0
      dbUnLock()
    enddo
    select RHUM
    do while .t.
      find (str(mkod_reestr,6))
      if !found() ; exit ; endif
      DeleteRec(.t.)
    enddo
    select MO_XML
    goto (rees->KOD_XML)
    DeleteRec(.t.)
    select REES
    DeleteRec(.t.)
    select R01m
    G_RLock(forever)
    &("r01m->reestr"+strzero(ir,2)) := 0
    dbUnlockAll()
    dbCommitAll()
  endif
next
mo_xml->(dbCloseArea())
tmp->(dbCloseArea())
RHUM->(dbCloseArea())
REES->(dbCloseArea())
select R01m
DeleteRec()
return NIL

***** 13.02.20 㤠����� ��� ����⮢ R11(PR11) �� ������� �����
Function delete_month_R11()
Local pss := space(10), tmp_pss := my_parol()
Local i, lm, mkod_reestr, ar_m := {}, buf
if select("MO_XML") > 0
  return NIL
endif
if (lm := input_value(18,6,20,73,color1,space(9)+"������ 㤠�塞� ����� (�� 䠩�� R11,PR11)",2,"99")) == NIL
  return NIL
elseif !between(lm,2,12)
  return NIL
else
  pss := get_parol(,,,,,"N/W","W/N*")
  if lastkey() == K_ENTER .and. ascan(tmp_pss,crypt(pss,gpasskod)) > 0 .and. f_Esc_Enter("㤠����� 䠩��� R11",.t.)
    //
  else
    return NIL
  endif
endif
G_Use(dir_server+"mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R12 .and. TIP_OUT == 0
G_Use(dir_server+"mo_dr01",,"REES")
G_Use(dir_server+"mo_dr01m",,"R01m")
go top
do while !eof()
  mkod_reestr := &("r01m->reestr"+strzero(lm,2))
  if mkod_reestr > 0
    select MO_XML
    find (str(mkod_reestr,6))
    select REES
    goto (mkod_reestr)
    if rees->tip == 1
      aadd(ar_m,{r01m->(recno()),mkod_reestr,iif(rees->answer==1,mo_xml->kod,0)})
    endif
  endif
  select R01m
  skip
enddo
REES->(dbCloseArea())
mo_xml->(dbCloseArea())
buf := save_maxrow()
if empty(ar_m)
  func_error(10,"�� �����㦥�� ॥��஢ R11 �� "+lstr(lm)+" �����!")
else
  for i := len(ar_m) to 1 step -1
    stat_msg("�������� "+lstr(i)+"-� ॥��� R11")
    if ar_m[i,3] > 0
      f2_delete_reestr_R02(ar_m[i,2],ar_m[i,3])
    endif
    close databases
    G_Use(dir_server+"mo_dr01m",,"R01m")
    f2_delete_reestr_R11(ar_m[i,1])
  next
  stat_msg("�ᯥ譮 㤠���� ॥��஢ R11 - "+lstr(len(ar_m))+" (�, ᮮ⢥��⢥���, �⢥⮢ �� ��� PR11)")
  inkey(10)
endif
rest_box(buf)
close databases
return NIL

/*
***** 28.02.21 㤠����� ��� ����⮢ R01(PR01) �� ������� �����
Function delete_month_R01()
Local pss := space(10), tmp_pss := my_parol()
Local i, lm, mkod_reestr, ar_m := {}, buf
if select("MO_XML") > 0
  return NIL
endif
if (lm := input_value(18,6,20,73,color1,space(9)+"������ 㤠�塞� ����� (�� 䠩�� R01,PR01)",2,"99")) == NIL
  return NIL
elseif !between(lm,2,12)
  return NIL
else
  pss := get_parol(,,,,,"N/W","W/N*")
  if lastkey() == K_ENTER .and. ascan(tmp_pss,crypt(pss,gpasskod)) > 0 .and. f_Esc_Enter("㤠����� 䠩��� R11",.t.)
    //
  else
    return NIL
  endif
endif
G_Use(dir_server+"mo_xml",,"MO_XML")
index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R02 .and. TIP_OUT == 0
G_Use(dir_server+"mo_dr01",,"REES")
G_Use(dir_server+"mo_dr01m",,"R01m")
go top
do while !eof()
  mkod_reestr := &("r01m->reestr"+strzero(lm,2))
  if mkod_reestr > 0
    select MO_XML
    find (str(mkod_reestr,6))
    select REES
    goto (mkod_reestr)
    if rees->tip == 0
      aadd(ar_m,{r01m->(recno()),mkod_reestr,iif(rees->answer==1,mo_xml->kod,0)})
    endif
  endif
  select R01m
  skip
enddo
REES->(dbCloseArea())
mo_xml->(dbCloseArea())
buf := save_maxrow()
if empty(ar_m)
  func_error(10,"�� �����㦥�� ॥��஢ R01 �� "+lstr(lm)+" �����!")
else
  for i := len(ar_m) to 1 step -1
    stat_msg("�������� "+lstr(i)+"-� ॥��� R01")
    if ar_m[i,3] > 0
      f2_delete_reestr_R02(ar_m[i,2],ar_m[i,3])
    endif
    close databases
    G_Use(dir_server+"mo_dr01m",,"R01m")
    f2_delete_reestr_R01(ar_m[i,1])
  next
  stat_msg("�ᯥ譮 㤠���� ॥��஢ R01 - "+lstr(len(ar_m))+" (�, ᮮ⢥��⢥���, �⢥⮢ �� ��� PR11)")
  inkey(10)
endif
rest_box(buf)
close databases
return NIL

*/

***** 25.02.21
Function f32_view_R11(lm)
  Local fl := .t., buf := save_maxrow(), k := 0, skol[5,3], ames[12,5,3], mrec := 2, n_file := "r11_itog"+stxt,;
        arr_rees := {}, mkod_reestr := 0
  Private par := .f.
  afillall(skol,0)
  afillall(ames,0)
  mywait()
  R_Use(dir_server+"mo_dr05p",,"R05p")
  goto (mrec)
  skol[1,1] := r05p->KOL1
  skol[2,1] := r05p->KOL2
  skol[3,1] := r05p->KOL11
  skol[4,1] := r05p->KOL12
  skol[5,1] := r05p->KOL13
  if par
    skol[1,1] -= skol[3,1]
    skol[3,1] -= skol[4,1]
    skol[3,1] -= skol[5,1]
  endif
  for i := 1 to 12
    for j := 1 to 2
      ames[i,j,1] := &("r05p->kol"+lstr(j)+"_"+strzero(i,2))
    next
    for j := 1 to 3
      ames[i,j+2,1] := &("r05p->kol1"+lstr(j)+"_"+strzero(i,2))
    next
    if par
      ames[i,1,1] -= ames[i,3,1]
      ames[i,3,1] -= ames[i,4,1]
      ames[i,3,1] -= ames[i,5,1]
    endif
  next
  r05p->(dbCloseArea())
  // ⮫쪮 ��� �㦭��� �����
  for j := 1 to 5
    skol[j] := ames[lm,j,1]
  next
  R_Use(dir_server+"mo_dr01k",,"RHUM")
  index on str(reestr,6)+str(rhum->R01_ZAP,6) to (cur_dir+"tmp_rhum")
  select REES
  go top
  do while !eof()
    aadd(arr_rees,rees->kod)
    skip
  enddo

  for k := len(arr_rees) to 1 step -1

    mkod_reestr := arr_rees[k]
    select RHUM
    find (str(mkod_reestr,6))
    do while rhum->reestr == mkod_reestr .and. !eof()
      if rhum->OPLATA < 2
        i := lm
        j := rhum->tip
        j1 := rhum->tip1
        if between(j1,1,3)
          ames[i,j1+2,2] ++
        elseif between(j,1,2)
          ames[i,j,2] ++
        endif
        if rhum->OPLATA == 1
          if between(j1,1,3)
            ames[i,j1+2,3] ++
          elseif between(j,1,2)
            ames[i,j,3] ++
          endif
        endif
      endif
      select RHUM
      skip
    enddo
  next k
  rhum->(dbCloseArea())
  if !par
    for i := 1 to 12
      for k := 2 to 3
        ames[i,3,k] += ames[i,4,k]
        ames[i,3,k] += ames[i,5,k]
        ames[i,1,k] += ames[i,3,k]
      next
    next
  endif
  //
  fp := fcreate(n_file) ; tek_stroke := 0 ; n_list := 1
  add_string("")
  add_string(center("���� ���ଠ�� (R11)",80))
  add_string("")
  mmt := {"��ᯠ��ਧ���","���ᬮ��","���.���ᨮ����","���.65 ���","���.66 � ����"}
  for i := lm to lm
  add_string("��������������������������������������������������������������������������������")
  add_string("     �����                �  �� �����   �  ��ࠢ���� �  � ������  � ��宦�����")
  add_string("��������������������������������������������������������������������������������")
    n := 26
    add_string(padr(mm_month[i],n))
    for j := 1 to 5
      add_string(padl(mmt[j],n)+put_val(ames[i,j,1],11)+;
                                put_val(ames[i,j,2],14)+;
                                put_val(ames[i,j,3],13)+;
                                put_val(ames[i,j,1]-ames[i,j,3],12))
      //skol[j,2] += ames[i,j,2]
      //skol[j,3] += ames[i,j,3]
    next
  next
  add_string(padr("�⮣�:",n))
/*  for j := 1 to 5
    add_string(padl(mmt[j],n)+put_val(skol[j,1],11)+;
                              put_val(skol[j,2],14)+;
                              put_val(skol[j,3],13)+;
                              put_val(skol[j,1]-skol[j,3],12))
  next
*/
  fclose(fp)
  rest_box(buf)
  viewtext(n_file,,,,.t.,,,2)
  return NIL

