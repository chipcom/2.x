***** mo_omss.prg - ࠡ�� � ��⠬� � ����� ���
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 28.12.21 ���� 䠩�� �� ����� (��� ���)
Function read_from_tf()
Local name_zip, _date, _time, s, arr_f := {}, buf, blk_sp_tk, fl := .f., n, hUnzip,;
      nErr, cFile, cName, arr_XML_info[7], tip_csv_file := 0, kod_csv_reestr := 0
if ! hb_user_curUser:IsAdmin()
  return func_error(4,err_admin)
endif
if find_unfinished_reestr_sp_tk()
  return func_error(4,"����⠩��� ᭮��")
endif
Private p_var_manager := "Read_From_TFOMS", p_ctrl_enter_sp_tk := .f.
blk_sp_tk := {|| p_ctrl_enter_sp_tk := .t., __keyboard(CHR(K_ENTER)) }
SETKEY(K_CTRL_ENTER, blk_sp_tk)
Private full_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*.zip")
SETKEY(K_CTRL_ENTER, nil)
if !empty(full_zip)
  full_zip := upper(full_zip)
  name_zip := StripPath(full_zip)
  cName := Name_Without_Ext(name_zip)
  /*if right(full_zip,4) == scsv
    if Is_Our_CSV(cName,@tip_csv_file,@kod_csv_reestr)
      fl := read_CSV_from_TF(full_zip,tip_csv_file,kod_csv_reestr)
    endif
    return fl
  endif*/
  // �᫨ �� ��㯭�� ��娢, �ᯠ������ � ������
  if !Is_Our_ZIP(cName,@tip_csv_file,@kod_csv_reestr)
    return fl
  endif
  if tip_csv_file > 0 // �᫨ �� CSV-䠩�� �ਪ९�����/��९�����
    if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
      if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
        fl := read_CSV_from_TF(arr_f[n],tip_csv_file,kod_csv_reestr)
      else
        fl := func_error(4,"� ��娢� "+name_zip+" ��� 䠩�� "+cName+scsv)
      endif
    endif
    return NIL
  endif
  // ��� ࠧ, �.�. ����� ���� ��८�।����� ��६����� full_zip
  name_zip := StripPath(full_zip)
  cName := Name_Without_Ext(name_zip)
  // �஢�ਬ, � ��� �� �।�����祭 ����� 䠩�
  if !Is_Our_XML(cName,arr_XML_info)
    return fl
  endif
  // �஢�ਬ, �⠫� �� 㦥 ����� 䠩�
  if Verify_Is_Already_XML(cName,@_date,@_time)
    // ����� ���� �� ��� ࠧ ����, �.�. 㦥 �⠫�
    func_error(4,"����� 䠩� 㦥 �� ���⠭ � ��ࠡ�⠭ � "+_time+" "+date_8(_date)+"�.")
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+cName+stxt,60,80),,,,.t.,,,2)
    return fl
  else
    s := "�⥭�� "
    do case
      case arr_XML_info[1] == _XML_FILE_FLK
        s += "��⮪��� ���"
      case arr_XML_info[1] == _XML_FILE_SP
        s += "॥��� �� � ��"
      case arr_XML_info[1] == _XML_FILE_RAK
        s += "�-� ��⮢ ����஫�"
      case arr_XML_info[1] == _XML_FILE_RPD
        s += "॥��� ����.���-⮢"
      case arr_XML_info[1] == _XML_FILE_R02
        s += "䠩�� �⢥� �� R01"
      case arr_XML_info[1] == _XML_FILE_R12
        s += "䠩�� �⢥� �� R11"
      case arr_XML_info[1] == _XML_FILE_R06
        s += "䠩�� �⢥� �� R05"
      case arr_XML_info[1] == _XML_FILE_D02
        s += "䠩�� �⢥� �� D01"
    endcase
    buf := savescreen()
    f_message({"���⥬��� ���: "+date_month(sys_date,.t.),;
               "���頥� ��� ��������, �� ��᫥",;
               s,;
               "�� ���㬥��� ���� ᮧ���� � �⮩ ��⮩.",;
               "",;
               "�������� �� �㤥� ����������!"},,"R/R*","N/R*")
    fl := .t.
    if arr_XML_info[1] == _XML_FILE_SP .and. p_ctrl_enter_sp_tk
      fl := involved_password(2,"HT34M111111_"+right(cName,7),"�⥭�� � �������� ॥��� �� � ��")
    endif
    if year(sys_date) < 2016
      fl := func_error(4,"������ ������ �������� ��稭�� � 2016 ����!")
    elseif fl
      fl := f_Esc_Enter(s,.t.)
    endif
    restscreen(buf)
    if !fl
      return fl
    endif
  endif
  if (arr_f := Extract_Zip_XML(KeepPath(full_zip),name_zip)) != NIL
    if (n := ascan(arr_f,{|x| upper(Name_Without_Ext(x)) == upper(cName)})) > 0
      fl := read_XML_from_TF(arr_f[n],arr_XML_info,arr_f)
    else
      fl := func_error(4,"� ��娢� "+name_zip+" ��� 䠩�� "+cName+sxml)
    endif
  endif
endif
return fl

***** 26.05.19 �⥭�� � ������ � ������ XML-䠩��
Function read_XML_from_TF(cFile,arr_XML_info,arr_f)
Local nTypeFile := 0, aerr := {}, j, oXmlDoc, oXmlNode, oNode1, oNode2, ;
      nCountWithErr := 0, adbf, go_to_schet := .f., go_to_akt := .f.,;
      go_to_rpd := .f., nerror, buf := save_maxrow()
nTypeFile := arr_XML_info[1]
for j := 1 to 4
  if !myFileDeleted(cur_dir+"tmp"+lstr(j)+"file"+sdbf)
    return NIL
  endif
next
for j := 1 to 8
  if !myFileDeleted(cur_dir+"tmp_r_t"+lstr(j)+sdbf)
    return NIL
  endif
next
if eq_any(nTypeFile,_XML_FILE_FLK,_XML_FILE_R02,_XML_FILE_R12,_XML_FILE_R06,_XML_FILE_D02)
  //
elseif !mo_Lock_Task(X_OMS)
  return .f.
endif
mywait("�ந�������� ������ 䠩�� "+cFile)
Private cReadFile := Name_Without_Ext(cFile), ;
        cTimeBegin := hour_min(seconds()),;
        mkod_reestr := 0, mXML_REESTR := 0, mdate_schet, is_err_FLK := .f.
Private cFileProtokol := cReadFile+stxt
strfile(space(10)+"��⮪�� ��ࠡ�⪨ 䠩��: "+cFile+hb_eol(),cFileProtokol)
strfile(space(10)+full_date(sys_date)+"�. "+cTimeBegin+hb_eol(),cFileProtokol,.t.)
// �⠥� 䠩� � ������
oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile,,@nerror)
if oXmlDoc == NIL .or. empty( oXmlDoc:aItems )
  aadd(aerr,"�訡�� � �⥭�� 䠩�� "+cFile)
elseif oXmlDoc:GetAttribute("encoding") == "UTF-8"
  aadd(aerr,"")
  aadd(aerr,"� 䠩�� "+cFile+" ����஢�� UTF-8, � ������ ���� Windows-1251")
elseif nTypeFile == _XML_FILE_FLK
  is_err_FLK := protokol_flk_tmpfile(arr_f,aerr)
elseif nTypeFile == _XML_FILE_SP
  reestr_sp_tk_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_RAK
  reestr_rak_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_RPD
  reestr_rpd_tmpfile(oXmlDoc,aerr,cReadFile)
elseif eq_any(nTypeFile,_XML_FILE_R02,_XML_FILE_R12)
  reestr_R02_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_R06
  reestr_R06_tmpfile(oXmlDoc,aerr,cReadFile)
elseif nTypeFile == _XML_FILE_D02
  reestr_D02_tmpfile(oXmlDoc,aerr,cReadFile)
endif
close databases
if empty(aerr)
  do case
    case nTypeFile == _XML_FILE_FLK
      strfile(hb_eol()+"��� 䠩��: ��⮪�� ��� (�ଠ⭮-�����᪮�� ����஫�)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      if read_XML_FILE_FLK(arr_XML_info,aerr)
        // ����襬 �ਭ������ 䠩� (��⮪�� ���)
        //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
        chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
        use (cur_dir+"tmp1file") new alias TMP1
        G_Use(dir_server+"mo_xml",,"MO_XML")
        AddRecN()
        mo_xml->KOD := recno()
        mo_xml->FNAME := cReadFile
        mo_xml->DREAD := sys_date
        mo_xml->TREAD := hour_min(seconds())
        mo_xml->TIP_IN := _XML_FILE_FLK // ⨯ �ਭ�������� 䠩��;3-���
        mo_xml->DWORK  := sys_date
        mo_xml->TWORK1 := cTimeBegin
        mo_xml->TWORK2 := hour_min(seconds())
        mo_xml->REESTR := mkod_reestr
        mo_xml->KOL2   := tmp1->KOL2
      endif
    case nTypeFile == _XML_FILE_SP
      strfile(hb_eol()+"��� 䠩��: ॥��� �� � �� (���客�� �ਭ��������� � �孮�����᪮�� ����஫�)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      if read_XML_FILE_SP(arr_XML_info,aerr,@nCountWithErr) > 0
        go_to_schet := create_schet_from_XML(arr_XML_info,aerr,,,cReadFile)
      elseif nCountWithErr > 0 // �� ��諨 � �訡���
        G_Use(dir_server+"mo_xml",,"MO_XML")
        goto (mXML_REESTR)
        G_RLock(forever)
        mo_xml->TWORK2 := hour_min(seconds())
      endif
    case nTypeFile == _XML_FILE_RAK
      strfile(hb_eol()+"��� 䠩��: ��� (॥��� ��⮢ ����஫�)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      read_XML_FILE_RAK(arr_XML_info,aerr)
      go_to_akt := empty(aerr)
    case nTypeFile == _XML_FILE_RPD
      strfile(hb_eol()+"��� 䠩��: ��� (॥��� ������� ���㬥�⮢)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      read_XML_FILE_RPD(arr_XML_info,aerr)
      go_to_rpd := empty(aerr)
    case nTypeFile == _XML_FILE_R02
      strfile(hb_eol()+"��� 䠩��: PR01 (�⢥� �� 䠩� R01)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      read_XML_FILE_R02(arr_XML_info,aerr,@nCountWithErr,_XML_FILE_R02)
      G_Use(dir_server+"mo_xml",,"MO_XML")
      goto (mXML_REESTR)
      G_RLock(forever)
      mo_xml->TWORK2 := hour_min(seconds())
    case nTypeFile == _XML_FILE_R12
      strfile(hb_eol()+"��� 䠩��: PR11 (�⢥� �� 䠩� R11)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      read_XML_FILE_R02(arr_XML_info,aerr,@nCountWithErr,_XML_FILE_R12)
      G_Use(dir_server+"mo_xml",,"MO_XML")
      goto (mXML_REESTR)
      G_RLock(forever)
      mo_xml->TWORK2 := hour_min(seconds())
    case nTypeFile == _XML_FILE_R06
      strfile(hb_eol()+"��� 䠩��: PR05 (�⢥� �� 䠩� R05)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      read_XML_FILE_R06(arr_XML_info,aerr,@nCountWithErr)
      G_Use(dir_server+"mo_xml",,"MO_XML")
      goto (mXML_REESTR)
      G_RLock(forever)
      mo_xml->TWORK2 := hour_min(seconds())
    case nTypeFile == _XML_FILE_D02
      strfile(hb_eol()+"��� 䠩��: D02 (�⢥� �� 䠩� D01)"+hb_eol()+hb_eol(),cFileProtokol,.t.)
      nCountWithErr := 0
      read_XML_FILE_D02(arr_XML_info,aerr,@nCountWithErr)
      G_Use(dir_server+"mo_xml",,"MO_XML")
      goto (mXML_REESTR)
      G_RLock(forever)
      mo_xml->TWORK2 := hour_min(seconds())
  endcase
endif
close databases
rest_box(buf)
if eq_any(nTypeFile,_XML_FILE_FLK,_XML_FILE_R02,_XML_FILE_R06,_XML_FILE_D02)
  //
else
  mo_UnLock_Task(X_OMS)
endif
if empty(aerr) .or. nCountWithErr > 0 // ����襬 䠩� ��⮪��� ��ࠡ�⪨
  chip_copy_zipXML(cFileProtokol,dir_server+dir_XML_TF)
endif
if !empty(aerr)
  aeval(aerr,{|x| put_long_str(x,cFileProtokol) })
endif
viewtext(Devide_Into_Pages(cFileProtokol,60,80),,,,.t.,,,2)
delete file (cFileProtokol)
if go_to_schet // �᫨ �믨ᠭ� ���
  keyboard chr(K_TAB)+chr(K_ENTER)
elseif go_to_akt // �᫨ �ਭ��� ����
  keyboard replicate(chr(K_TAB),3)+replicate(chr(K_ENTER),2)
elseif go_to_rpd // �᫨ �ਭ��� ����񦪨
  keyboard replicate(chr(K_TAB),4)+chr(K_ENTER)
endif
return NIL

*

***** 26.04.20 ������ ॥��� ���
Function read_XML_FILE_FLK(arr_XML_info,aerr)
Local ii, pole, i, k, t_arr[2], adbf, ar
mkod_reestr := arr_XML_info[7]
use (cur_dir+"tmp1file") new alias TMP1
R_Use(dir_server+"mo_rees",,"REES")
goto (arr_XML_info[7])
strfile("��ࠡ��뢠���� �⢥� ����� �� ॥��� � "+;
        lstr(rees->NSCHET)+" �� "+full_date(rees->DSCHET)+"�. ("+;
        lstr(rees->KOL)+" 祫.)"+;
        hb_eol(),cFileProtokol,.t.)
if !emptyany(rees->nyear,rees->nmonth)
  strfile("���⠢����� �� "+;
          mm_month[rees->nmonth]+str(rees->nyear,5)+" ����"+;
          hb_eol(),cFileProtokol,.t.)
endif
use (cur_dir+"tmp2file") new alias TMP2
index on str(tip,1)+str(oshib,3)+soshib to (cur_dir+"tmp2")
if is_err_FLK
  if !extract_reestr(rees->(recno()),rees->name_xml)
    aadd(aerr,center("�� ������ ZIP-��娢 � �������� � "+lstr(rees->nschet)+" �� "+date_8(rees->DSCHET),80))
    aadd(aerr,"")
    aadd(aerr,center(dir_server+dir_XML_MO+cslash+alltrim(rees->name_xml)+szip,80))
    aadd(aerr,"")
    aadd(aerr,center("��� ������� ��娢� ���쭥��� ࠡ�� ����������!",80))
    close databases
    return .f.
  endif
  use (cur_dir+"tmp_r_t1") new alias T1
  index on upper(ID_PAC) to (cur_dir+"tmp_r_t1")
  use (cur_dir+"tmp_r_t2") new alias T2
  use (cur_dir+"tmp_r_t3") new alias T3
  use (cur_dir+"tmp_r_t4") new alias T4
  use (cur_dir+"tmp_r_t5") new alias T5
  use (cur_dir+"tmp_r_t6") new alias T6
  use (cur_dir+"tmp_r_t7") new alias T7
  use (cur_dir+"tmp_r_t8") new alias T8
  // ��������� ���� "N_ZAP" � 䠩�� "tmp2"
  fill_tmp2_file_flk()
  R_Use(dir_server+"mo_otd",,"OTD")
  G_Use(dir_server+"human_",,"HUMAN_")
  G_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to otd into OTD
  G_Use(dir_server+"mo_rhum",,"RHUM")
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
  select TMP2 // ᭠砫� �஢�ઠ
  go top
  do while !eof()
    select RHUM
    find (str(tmp2->N_ZAP,6))
    if found()
      human->(dbGoto(rhum->KOD_HUM))
      if rhum->OPLATA > 0
        aadd(aerr,"��樥�� � REES_ZAP="+lstr(rhum->REES_ZAP)+" �� ���⠭ � ॥��� �� � ��")
        if !empty(human->fio)
          aadd(aerr,"��>(��� ��樥�� = "+alltrim(human->fio)+")")
        endif
      endif
      if !(rhum->REES_ZAP == human_->REES_ZAP)
        aadd(aerr,"�� ࠢ�� ��ࠬ��� REES_ZAP: "+lstr(rhum->REES_ZAP)+" != "+lstr(human_->REES_ZAP))
      endif
    else
      aadd(aerr,"�� ������ ��砩 � N_ZAP="+lstr(tmp2->N_ZAP))
    endif
    select TMP2
    skip
  enddo
  if !empty(aerr)
    close databases
    return .f.
  endif
endif
for ii := 1 to 2
  pole := "tmp1->fname"+lstr(ii)
  strfile(hb_eol()+"��ࠡ�⠭ 䠩� "+&pole+hb_eol(),cFileProtokol,.t.)
  select TMP2
  find (str(ii,1))
  if found()
    strfile("  ���᮪ �訡��:"+hb_eol(),cFileProtokol,.t.)
    do while tmp2->tip == ii .and. !eof()
      if empty(tmp2->SOSHIB)
        s := "��� �訡�� = "+lstr(tmp2->OSHIB)+" "
        if (i := ascan(glob_F012,{|x| x[2] == tmp2->OSHIB})) > 0
          s += '"'+glob_F012[i,5]+'"'
        endif
      else
        s := "��� �訡�� = "+tmp2->SOSHIB+" "
        // if (i := ascan(glob_Q017,{|x| x[1] == left(tmp2->SOSHIB,4)})) > 0
        //   s += '"'+glob_Q017[i,2]+'" '
        // endif
        s += '"' + getCategoryCheckErrorByID_Q017(left(tmp2->SOSHIB,4))[2] + '" '
        s += alltrim(inieditspr(A__POPUPMENU, dir_exe+"_mo_Q015", tmp2->SOSHIB))
      endif
      if !empty(tmp2->IM_POL)
        s += ", ��� ���� = "+alltrim(tmp2->IM_POL)
      endif
      if !empty(tmp2->BAS_EL)
        s += ", ��� �������� ����� = "+alltrim(tmp2->BAS_EL)
      endif
      if !empty(tmp2->ID_BAS)
        s += ", GUID �������� ����� = "+alltrim(tmp2->ID_BAS)
      endif
      if !empty(tmp2->COMMENT)
        s += ", ���ᠭ�� �訡�� = "+alltrim(tmp2->COMMENT)
      endif
      if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
        if empty(tmp2->N_ZAP)
          s += ", ������ �� ������!"
        else
          select RHUM
          find (str(tmp2->N_ZAP,6))
          G_RLock(forever)
          rhum->OPLATA := 2
          tmp2->kod_human := rhum->KOD_HUM
          select HUMAN
          goto (rhum->KOD_HUM)
          if human_->REESTR == mkod_reestr
            G_RLock(forever)
            human_->(G_RLock(forever))
            human_->OPLATA := 2
            human_->REESTR := 0 // ���ࠢ����� �� ���쭥�襥 ।���஢����
            human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
            if human_->REES_NUM > 0
              human_->REES_NUM := human_->REES_NUM-1
            endif
            UnLock
            s += ", "+alltrim(human->fio)+", "+full_date(human->date_r)+;
                 iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                 " "+date_8(human->n_data)+"-"+date_8(human->k_data)
          endif
        endif
      endif
      k := perenos(t_arr,s,75)
      strfile(hb_eol(),cFileProtokol,.t.)
      for i := 1 to k
        strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol,.t.)
      next
      select TMP2
      skip
    enddo
  else
    strfile("-- �訡�� �� �����㦥�� -- "+hb_eol(),cFileProtokol,.t.)
  endif
next
close databases
return .t.

***** 22.01.19 ��������� ���� "N_ZAP" � 䠩�� "tmp2"
Function fill_tmp2_file_flk()
Local i, s, s1, adbf, ar
use (cur_dir+"tmp22fil") new alias TMP22
select TMP2
adbf := array(fcount())
go top
do while !eof()
  if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
    s := alltrim(tmp2->BAS_EL) ; s1 := alltrim(tmp2->ID_BAS)
    do case
      case s == "ZAP"
        select T1
        Locate for t1->N_ZAP==padr(s1,6)
        if found()
          tmp2->N_ZAP := val(t1->N_ZAP)
        endif
      case s == "PACIENT"
        ar := {}
        select T1
        find (padr(upper(s1),36))
        do while upper(t1->ID_PAC)==padr(upper(s1),36)
          aadd(ar,int(val(t1->N_ZAP)))
          skip
        enddo
        if len(ar) > 0
          select TMP2
          tmp2->N_ZAP := ar[1]
          if len(ar) > 1
            aeval(adbf, {|x,i| adbf[i] := fieldget(i) }  )
            select TMP22
            for i := 2 to len(ar)
              append blank
              aeval(adbf, {|x,i| fieldput(i,x) } )
              tmp22->N_ZAP := ar[i]
            next
          endif
        endif
      case eq_any(s,"SLUCH","Z_SL")
        select T1
        Locate for upper(t1->ID_C)==padr(upper(s1),36)
        if found()
          tmp2->N_ZAP := val(t1->N_ZAP)
        endif
      case s == "USL"
        select T2
        Locate for upper(t2->ID_U)==padr(upper(s1),36)
        if found()
          select T1
          Locate for t1->N_ZAP==t2->IDCASE
          if found()
            tmp2->N_ZAP := val(t1->N_ZAP)
          endif
        endif
      case s == "PERS"
        select T3
        Locate for upper(t3->ID_PAC)==padr(upper(s1),36)
        if found()
          ar := {}
          select T1
          find (padr(upper(s1),36))
          do while upper(t1->ID_PAC)==padr(upper(s1),36)
            aadd(ar,int(val(t1->N_ZAP)))
            skip
          enddo
          if len(ar) > 0
            select TMP2
            tmp2->N_ZAP := ar[1]
            if len(ar) > 1
              aeval(adbf, {|x,i| adbf[i] := fieldget(i) }  )
              select TMP22
              for i := 2 to len(ar)
                append blank
                aeval(adbf, {|x,i| fieldput(i,x) } )
                tmp22->N_ZAP := ar[i]
              next
            endif
          endif
        endif
    endcase
  endif
  select TMP2
  skip
enddo
i := tmp22->(lastrec())
tmp22->(dbCloseArea())
if i > 0
  select TMP2
  append from tmp22fil codepage "RU866"
  index on str(tip,1)+str(oshib,3) to (cur_dir+"tmp2")
endif
return NIL

***** 15.10.21 ������ � "ࠧ����" �� ����� ������ ॥��� �� � ��
Function read_XML_FILE_SP(arr_XML_info,aerr,/*@*/current_i2)
  Local count_in_schet := 0, mnschet, bSaveHandler, ii1, ii2, i, k, t_arr[2],;
      ldate_sptk, s, fl_589, mANSREESTR

  local reserveKSG_ID_C := '' // GUID ��� ��������� ������� ��砥�

if !(type("p_ctrl_enter_sp_tk") == "L")
  Private p_ctrl_enter_sp_tk := .f.
endif
use (cur_dir+"tmp1file") new alias TMP1
ldate_sptk := tmp1->_DATA
mnschet := int(val(tmp1->_NSCHET))  // � �᫮ (��१��� ���, �� ��᫥ "-")
mANSREESTR := afteratnum("-",tmp1->_NSCHET)
R_Use(dir_server+"mo_rees",,"REES")
index on str(NSCHET,6) to (cur_dir+"tmp_rees") for NYEAR == tmp1->_YEAR
find (str(mnschet,6))
if found()
  mkod_reestr := arr_XML_info[7] := rees->kod
  strfile("��ࠡ��뢠���� �⢥� ����� ("+alltrim(tmp1->_NSCHET)+") �� ॥��� � "+;
          lstr(rees->NSCHET)+" �� "+full_date(rees->DSCHET)+"�. ("+;
          lstr(rees->KOL)+" 祫.)"+;
          hb_eol(),cFileProtokol,.t.)
  if !emptyany(rees->nyear,rees->nmonth)
    strfile("���⠢����� �� "+;
            mm_month[rees->nmonth]+str(rees->nyear,5)+" ����"+;
            hb_eol(),cFileProtokol,.t.)
  endif
  strfile(hb_eol(),cFileProtokol,.t.)
  //
  R_Use(dir_server+"mo_xml",,"MO_XML")
  index on ANSREESTR to (cur_dir+"tmp_xml") for reestr == mkod_reestr
  find (mANSREESTR)
  if found()
    aadd(aerr,'�� ॥���� � '+lstr(mnschet)+' �� '+date_8(tmp1->_DSCHET)+' 㦥 ���⠭ �⢥� ����� "'+alltrim(tmp1->_NSCHET)+'"')
  endif
else
  aadd(aerr,"�� ������ ������ � "+lstr(mnschet)+" �� "+date_8(tmp1->_DSCHET))
endif
if empty(aerr) .and. !extract_reestr(rees->(recno()),rees->name_xml)
  aadd(aerr,center("�� ������ ZIP-��娢 � �������� � "+lstr(mnschet)+" �� "+date_8(tmp1->_DSCHET),80))
  aadd(aerr,"")
  aadd(aerr,center(dir_server+dir_XML_MO+cslash+alltrim(rees->name_xml)+szip,80))
  aadd(aerr,"")
  aadd(aerr,center("��� ������� ��娢� ���쭥��� ࠡ�� ����������!",80))
endif
if empty(aerr)
  R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  R_Use(dir_server+"human",,"HUMAN")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"mo_rhum",,"RHUM")
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
  use (cur_dir+"tmp2file") new alias TMP2
  // ᭠砫� �஢�ઠ
  ii1 := ii2 := 0
  go top
  do while !eof()
    if tmp2->_OPLATA == 1
      ++ii1
      if ascan(glob_arr_smo,{|x| x[2] == int(val(tmp2->_SMO)) }) == 0
        aadd(aerr,"�����४⭮� ���祭�� ��ਡ�� SMO: "+tmp2->_SMO)
      endif
    elseif tmp2->_OPLATA == 2
      ++ii2
    else
      aadd(aerr,"�����४⭮� ���祭�� ��ਡ�� OPLATA: "+lstr(tmp2->_OPLATA))
    endif
    select RHUM
    find (str(tmp2->_N_ZAP,6))
    if found()
      human_->(dbGoto(rhum->KOD_HUM))
      human->(dbGoto(rhum->KOD_HUM))
      if human->ishod == 89 // �� 2-�� ��砩 � ������� ��砥
        select HUMAN_3
        set order to 2
        find (str(rhum->KOD_HUM,7))
        if found()
          reserveKSG_ID_C = human_3->ID_C
          human_->(dbGoto(human_3->kod))   // ����� �� 1-� ��砩
          human->(dbGoto(human_3->kod))    // �.�. GUID'� � ॥��� �� 1-�� ����
        endif
      endif
      tmp2->fio := human->fio
      if rhum->OPLATA > 0
        aadd(aerr,"��樥�� � REES_ZAP="+lstr(rhum->REES_ZAP)+" �� ���⠭ � �।��饬 ॥��� �� � ��")
        if !empty(human->fio)
          aadd(aerr,"��>(��� ��樥�� = "+alltrim(human->fio)+")")
        endif
      endif
      if iif(p_ctrl_enter_sp_tk, (tmp2->_OPLATA == 1), .t.)
        if !(rhum->REES_ZAP == human_->REES_ZAP)
          aadd(aerr,"�� ࠢ�� ��ࠬ��� REES_ZAP: "+lstr(rhum->REES_ZAP)+" != "+lstr(human_->REES_ZAP))
        endif
        if !(upper(tmp2->_ID_PAC) == upper(human_->ID_PAC))
          aadd(aerr,"�� ࠢ�� ��ࠬ��� ID_PAC: "+tmp2->_ID_PAC+" != "+human_->ID_PAC)
        endif
        if empty(reserveKSG_ID_C) .and. !(upper(tmp2->_ID_C) == upper(human_->ID_C))
          aadd(aerr,"�� ࠢ�� ��ࠬ��� ID_C: "+tmp2->_ID_C+" != "+human_->ID_C)
        elseif !empty(reserveKSG_ID_C) .and. !(upper(tmp2->_ID_C) == upper(reserveKSG_ID_C))
          aadd(aerr,"�� ࠢ�� ��ࠬ��� ID_C ��� ���������� �������� ����: "+tmp2->_ID_C+" != "+reserveKSG_ID_C)
        endif
      endif
    else
      aadd(aerr,"�� ������ ��砩 � N_ZAP="+lstr(tmp2->_N_ZAP)+", _ID_PAC="+tmp2->_ID_PAC)
    endif
    reserveKSG_ID_C := ''
    select TMP2
    skip
  enddo
  tmp1->kol1 := ii1
  tmp1->kol2 := ii2
  close databases
  if empty(aerr) // �᫨ �஢�ઠ ��諠 �ᯥ譮
    Private fl_open := .t.
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
      if ii1 > 0 // �뫨 ��樥��� ��� �訡��
        index_base("schet") // ��� ��⠢����� ��⮢
        index_base("human") // ��� ࠧ��᪨ ��⮢
        index_base("human_3") // ������ ��砨
        use (dir_server+"human_u") new READONLY
        index on str(kod,7)+date_u to (dir_server+"human_u") progress
        use
        Use (dir_server+"mo_hu") new READONLY
        index on str(kod,7)+date_u to (dir_server+"mo_hu") progress
        Use
      endif
      if ii2 > 0 // �뫨 ��樥��� � �訡����
        if !p_ctrl_enter_sp_tk
          index_base("mo_refr")  // ��� ����� ��稭 �⪠���
        endif
        if ii1 == 0 // � �⢥⭮� 䠩�� �� �뫮 ��樥�⮢ ��� �訡��
          index_base("human") // ��� ࠧ��᪨ ���
        endif
      endif
    RECOVER USING error
      aadd(aerr,"�������� ���।�������� �訡�� �� ��२�����஢����!")
    END
    ERRORBLOCK(bSaveHandler)
    close databases
  endif
  if empty(aerr) // �᫨ �஢�ઠ ��諠 �ᯥ譮
    // ����襬 �ਭ������ 䠩� (॥��� ��)
    //chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
    chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
    G_Use(dir_server+"mo_xml",,"MO_XML")
    AddRecN()
    mo_xml->KOD := recno()
    mo_xml->FNAME := cReadFile
    mo_xml->DFILE := ldate_sptk
    mo_xml->TFILE := ""
    mo_xml->DREAD := sys_date
    mo_xml->TREAD := hour_min(seconds())
    mo_xml->TIP_IN := _XML_FILE_SP // ⨯ �ਭ�������� 䠩��;3-���,4-��,5-���,6-��� ��襬 � ��⠫�� XML_TF
    mo_xml->DWORK  := sys_date
    mo_xml->TWORK1 := cTimeBegin
    mo_xml->REESTR := mkod_reestr
    mo_xml->ANSREESTR := mANSREESTR
    mo_xml->KOL1 := ii1
    mo_xml->KOL2 := ii2
    //
    mXML_REESTR := mo_xml->KOD
    use
    if ii2 > 0
      if !p_ctrl_enter_sp_tk
        G_Use(dir_server+"mo_refr",dir_server+"mo_refr","REFR")
      endif
      //G_Use(dir_server+"mo_kfio",,"KFIO")
      //index on str(kod,7) to (cur_dir+"tmp_kfio")
    endif
    // ������ �ᯠ������� ॥���
    use (cur_dir+"tmp_r_t1") new alias T1
    index on str(val(n_zap),6) to (cur_dir+"tmpt1")
    use (cur_dir+"tmp_r_t2") new alias T2
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt2")
    use (cur_dir+"tmp_r_t3") new alias T3
    index on upper(ID_PAC) to (cur_dir+"tmpt3")
    use (cur_dir+"tmp_r_t4") new alias T4
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt4")
    use (cur_dir+"tmp_r_t5") new alias T5
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt5")
    use (cur_dir+"tmp_r_t6") new alias T6
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt6")
    use (cur_dir+"tmp_r_t7") new alias T7
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt7")
    use (cur_dir+"tmp_r_t8") new alias T8
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt8")
    use (cur_dir+"tmp_r_t9") new alias T9
    index on IDCASE+str(sluch,6) to (cur_dir+"tmpt9")
    use (cur_dir+"tmp_r_t10") new alias T10
    index on IDCASE+str(sluch,6)+regnum+code_sh+date_inj to (cur_dir+"tmpt10")
    use (cur_dir+"tmp_r_t1_1") new alias T1_1
    index on IDCASE to (cur_dir+"tmpt1_1")
    //
    G_Use(dir_server+"mo_kfio",,"KFIO")
    index on str(kod,7) to (cur_dir+"tmp_kfio")
    G_Use(dir_server+"kartote2",,"KART2")
    G_Use(dir_server+"kartote_",,"KART_")
    G_Use(dir_server+"kartotek",dir_server+"kartoten","KART")
    set order to 0 // ������ ����� ��� ४������樨 �� ��१���� ��� � ���� ஦�����
    R_Use(dir_server+"mo_otd",,"OTD")
    G_Use(dir_server+"human_",,"HUMAN_")
    G_Use(dir_server+"human",{dir_server+"humann",dir_server+"humans"},"HUMAN")
    set order to 0 // ������� ������ ��� ४������樨 �� ��१���� ���
    set relation to recno() into HUMAN_, to otd into OTD
    G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
    G_Use(dir_server+"mo_rhum",,"RHUM")
    index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for reestr == mkod_reestr
    use (cur_dir+"tmp3file") new alias TMP3
    index on str(_n_zap,8) to (cur_dir+"tmp3")
    use (cur_dir+"tmp2file") new alias TMP2
    count_in_schet := lastrec() ; current_i2 := 0
    go top
    do while !eof()
      if tmp2->_OPLATA == 1
        select T1
        find (str(tmp2->_N_ZAP,6))
        if found()
          t1->VPOLIS := lstr(tmp2->_VPOLIS)
          t1->SPOLIS := tmp2->_SPOLIS
          t1->NPOLIS := tmp2->_NPOLIS
          t1->ENP    := tmp2->_ENP
          t1->SMO    := tmp2->_SMO
          t1->SMO_OK := tmp2->_SMO_OK
          t1->MO_PR  := tmp2->_MO_PR
        endif
      endif
      select RHUM
      find (str(tmp2->_N_ZAP,6))
      G_RLock(forever)
      rhum->OPLATA := tmp2->_OPLATA
      tmp2->kod_human := rhum->KOD_HUM
      is_2 := 0
      select HUMAN
      goto (rhum->KOD_HUM)
      if eq_any(human->ishod,88,89)
        select HUMAN_3
        if human->ishod == 88
          set order to 1
          is_2 := 1
        else
          set order to 2
          is_2 := 2
        endif
        find (str(rhum->KOD_HUM,7))
        if found() // �᫨ ��諨 ������� ��砩
          select HUMAN
          if human->ishod == 88  // �᫨ ॥��� ��⠢��� �� 1-�� �����
            goto (human_3->kod2)  // ����� �� 2-��
          else
            goto (human_3->kod)   // ���� - �� 1-�
          endif
          human_->(G_RLock(forever))
          human_->OPLATA := tmp2->_OPLATA
          if tmp2->_OPLATA > 1 .and. !p_ctrl_enter_sp_tk
            human_->REESTR := 0 // ���ࠢ����� �� ���쭥�襥 ।���஢����
            human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
          endif
          human_3->(G_RLock(forever))
          human_3->OPLATA := tmp2->_OPLATA
          human_3->REESTR := 0
        endif
      endif
      select HUMAN
      goto (rhum->KOD_HUM)
      G_RLock(forever)
      human_->(G_RLock(forever))
      human_->OPLATA := tmp2->_OPLATA
      kart->(dbGoto(human->kod_k))
      fl_589 := .f.
      if tmp2->_OPLATA == 1
        human->POLIS   := make_polis(tmp2->_spolis,tmp2->_npolis)
        human_->VPOLIS := tmp2->_VPOLIS
        human_->SPOLIS := tmp2->_SPOLIS
        human_->NPOLIS := tmp2->_NPOLIS
        human_->OKATO  := tmp2->_SMO_OK
        if int(val(tmp2->_SMO)) != 34 // �� �����த���
          human_->SMO := tmp2->_SMO
        endif
        if kart->za_smo == -9
          select KART
          G_RLock(forever)
          kart->za_smo := 0  // ���� �ਧ��� "�஡���� � ����ᮬ"
          dbUnLock()
        endif
        if !eq_any(tmp2->_MO_PR,space(6),replicate('0',6)) .or. !empty(tmp2->_enp)
          select KART2
          do while kart2->(lastrec()) < human->kod_k
            APPEND BLANK
          enddo
          goto (human->kod_k)
          if empty(kart2->MO_PR)
            G_RLock(forever)
            if !eq_any(tmp2->_MO_PR,space(6),replicate('0',6))
              kart2->MO_PR := tmp2->_MO_PR
              kart2->TIP_PR := 2 // ⨯/����� �ਪ९����� 2-�� ॥��� �� � ��
              kart2->DATE_PR := ldate_sptk
              if empty(kart2->pc4)
                kart2->pc4 := date_8(kart2->pc4)
              endif
            endif
            if !empty(tmp2->_enp)
              kart2->kod_mis := tmp2->_enp
            endif
            dbUnLock()
          endif
        endif
      else // tmp2->_OPLATA == 2
        --count_in_schet    // �� ����砥��� � ���,
        if !p_ctrl_enter_sp_tk
          human_->REESTR := 0 // � ���ࠢ����� �� ���쭥�襥 ।���஢����
          human_->ST_VERIFY := 0 // ᭮�� ��� �� �஢�७
          if current_i2 == 0
            strfile(space(10)+"���᮪ ��砥� � �訡����"+hb_eol()+hb_eol(),cFileProtokol,.t.)
          endif
          ++current_i2
          lal := "human"
          if is_2 > 0
            lal += "_3"
          endif
          strfile(lstr(current_i2)+". "+alltrim(human->fio)+", "+;
                       full_date(human->date_r)+;
                       iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                       " "+alltrim(human->KOD_DIAG)+;
                       " "+date_8(&lal.->n_data)+"-"+;
                       date_8(&lal.->k_data)+hb_eol(),cFileProtokol,.t.)
          // ��������� ���
          if !emptyall(tmp2->CORRECT,tmp2->_FAM,tmp2->_IM,tmp2->_OT,tmp2->_DR)
            arr_fio := retFamImOt(2,.f.,.t.)
            mdate_r := human->date_r
            s := ""
            //s := space(5)+"!�訡�� � ���ᮭ����� ������!"+eos
            if !empty(tmp2->_FAM)
              //s += space(5)+'���� 䠬���� "'+alltrim(arr_fio[1])+'", �������� �� "'+alltrim(tmp2->_FAM)+'"'+eos
              s += space(5)+'䠬���� � ��襩 �� "'+alltrim(arr_fio[1])+'", � ॣ���� ����� "'+alltrim(tmp2->_FAM)+'"'+eos
              arr_fio[1] := alltrim(tmp2->_FAM)
            endif
            if !empty(tmp2->_IM)
              //s += space(5)+'��஥ ��� "'+alltrim(arr_fio[2])+'", �������� �� "'+alltrim(tmp2->_IM)+'"'+eos
              s += space(5)+'��� � ��襩 �� "'+alltrim(arr_fio[2])+'", � ॣ���� ����� "'+alltrim(tmp2->_IM)+'"'+eos
              arr_fio[2] := alltrim(tmp2->_IM)
            endif
            if !emptyall(tmp2->CORRECT,tmp2->_OT)
              //s += space(5)+'��஥ ����⢮ "'+alltrim(arr_fio[3])+'", �������� �� "'+alltrim(tmp2->_OT)+'"'+eos
              s += space(5)+'����⢮ � ��襩 �� "'+alltrim(arr_fio[3])+'", � ॣ���� ����� "'+alltrim(tmp2->_OT)+'"'+eos
              arr_fio[3] := alltrim(tmp2->_OT)
            endif
            if !empty(tmp2->_DR)
              mdate_r := xml2date(tmp2->_DR)
              //s += space(5)+"���� ��� ஦����� "+full_date(human->date_r)+", �������� �� "+full_date(mdate_r)+eos
              s += space(5)+"��� ஦����� � ��襩 �� "+full_date(human->date_r)+", � ॣ���� ����� "+full_date(mdate_r)+eos
            endif
            //s += space(5)+"(��ࠢ���� - ���� � ।���஢���� �/� � ���⢥न�� ������)"+eos
            //s += space(5)+"(��ࠢ��� ᠬ����⥫쭮; � ��砥 ��ᮣ���� ���頩��� � �⤥� �����"+eos
            //s += space(5)+" �� ������� ॣ���� �����客����� ���, ⥫.94-71-59, 95-87-88, 94-67-41)"+eos
            strfile(s,cFileProtokol,.t.)
            /*
            newMEST_INOG := 0
            if TwoWordFamImOt(arr_fio[1]) .or. TwoWordFamImOt(arr_fio[2]) .or. TwoWordFamImOt(arr_fio[3])
              newMEST_INOG := 9
            endif
            mfio := arr_fio[1]+" "+arr_fio[2]+" "+arr_fio[3]
            if kart->MEST_INOG == 9 .or. newMEST_INOG == 9
              select KFIO
              find (str(kart->kod,7))
              if found()
                if newMEST_INOG == 9
                  G_RLock(forever)
                  kfio->FAM := arr_fio[1]
                  kfio->IM  := arr_fio[2]
                  kfio->OT  := arr_fio[3]
                  dbUnLock()
                else
                  DeleteRec(.t.)
                endif
              else
                if newMEST_INOG == 9
                  AddRec(7)
                  kfio->kod := kart->kod
                  kfio->FAM := arr_fio[1]
                  kfio->IM  := arr_fio[2]
                  kfio->OT  := arr_fio[3]
                  dbUnLock()
                endif
              endif
            endif
            select KART
            G_RLock(forever)
            kart->fio := mfio
            kart->date_r := mdate_r
            kart->MEST_INOG := newMEST_INOG
            dbUnLock()
            select HUMAN
            G_RLock(forever)
            human->fio := mfio
            human->date_r := mdate_r
            dbUnLock()
            */
          endif
          select REFR
          do while .t.
            find (str(1,1)+str(mkod_reestr,6)+str(1,1)+str(rhum->KOD_HUM,8))
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          select TMP3
          find (str(tmp2->_N_ZAP,8))
          do while tmp2->_N_ZAP == tmp3->_N_ZAP .and. !eof()
            select REFR
            AddRec(1)
            refr->TIPD := 1
            refr->KODD := mkod_reestr
            refr->TIPZ := 1
            refr->KODZ := rhum->KOD_HUM
            refr->IDENTITY := tmp2->_IDENTITY
            refr->REFREASON := tmp3->_REFREASON
            refr->SREFREASON := tmp3->SREFREASON
            if empty(refr->SREFREASON)
              if empty(s := ret_t005(refr->REFREASON))
                strfile(space(5)+lstr(refr->REFREASON)+" �������⭠� ��稭� �⪠��"+;
                        hb_eol(),cFileProtokol,.t.)
              else
                if tmp3->_REFREASON == 562
                  s += " (ᯥ�-�� ��� "+ret_tmp_prvs(human_->PRVS)+")"
                elseif tmp3->_REFREASON == 589 .and. int(val(tmp2->_SMO)) > 0
                  fl_589 := .t.
                  s += " (� �/� � � ����窥 ��樥�� ��ࠢ���� ����� � ��� - ���� � ।���஢���� �/� � ���⢥न�� ������)"
                endif
                k := perenos(t_arr,s,75)
                for i := 1 to k
                  strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol,.t.)
                next
              endif
              if eq_any(refr->REFREASON,57,59) .and. kart->za_smo != -9
                select KART
                G_RLock(forever)
                kart->za_smo := -9  // ��⠭����� �ਧ��� "�஡���� � ����ᮬ"
                dbUnLock()
              endif
              if refr->REFREASON == 513 .or. !eq_any(tmp2->_MO_PR,space(6),replicate('0',6))
                select KART2
                do while kart2->(lastrec()) < human->kod_k
                  APPEND BLANK
                enddo
                goto (human->kod_k)
                if empty(kart2->MO_PR)
                  G_RLock(forever)
                  kart2->MO_PR := tmp2->_MO_PR
                  kart2->TIP_PR := 2
                  kart2->DATE_PR := ldate_sptk
                  if empty(kart2->pc4)
                    kart2->pc4 := date_8(kart2->pc4)
                  endif
                  dbUnLock()
                endif
              endif
            else
              s := "��� �訡�� = "+tmp3->SREFREASON+" "
              // if (i := ascan(glob_Q017,{|x| x[1] == left(tmp3->SREFREASON,4)})) > 0
              //   s += '"'+glob_Q017[i,2]+'" '
              // endif
              s += '"' + getCategoryCheckErrorByID_Q017(left(tmp3->SREFREASON,4))[2] + '" '
              s += alltrim(inieditspr(A__POPUPMENU, dir_exe+"_mo_Q015", tmp3->SREFREASON))
              k := perenos(t_arr,s,75)
              for i := 1 to k
                strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol,.t.)
              next
            endif
            select TMP3
            skip
          enddo
          if is_2 > 0
            strfile(space(5)+'- ࠧ���� ������� ��砩 � ०��� "���/������ ��砨/���������"'+;
                    hb_eol(),cFileProtokol,.t.)
            strfile(space(5)+'- ��।������ ����� �� ��砥� � ०��� "���/������஢����"'+;
                    hb_eol(),cFileProtokol,.t.)
            strfile(space(5)+'- ᭮�� ᮡ��� ��砩 � ०��� "���/������ ��砨/�������"'+;
                    hb_eol(),cFileProtokol,.t.)
          endif
        endif
      endif
      UnLock ALL
      if fl_589
        select HUMAN
        G_RLock(forever)
        human->POLIS := make_polis(tmp2->_spolis,tmp2->_npolis)
        //
        human_->(G_RLock(forever))
        human_->VPOLIS := tmp2->_VPOLIS
        human_->SPOLIS := tmp2->_SPOLIS
        human_->NPOLIS := tmp2->_NPOLIS
        human_->SMO    := tmp2->_SMO
        human_->OKATO  := tmp2->_SMO_OK
        //
        select KART_
        goto (human->kod_k)
        G_RLock(forever)
        kart_->VPOLIS    := tmp2->_VPOLIS
        kart_->SPOLIS    := tmp2->_SPOLIS
        kart_->NPOLIS    := tmp2->_NPOLIS
        kart_->SMO       := tmp2->_SMO
        kart_->KVARTAL_D := tmp2->_SMO_OK
        //
        UnLock ALL
      endif
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

***** 26.11.18 ᮧ���� ��� �� १���⠬ ���⠭���� ॥��� ��
Function create_schet_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
Local arr_schet := {}, c, len_stand, _arr_stand, lshifr, i, j, k, lbukva,;
      doplataF, doplataR, mnn, fl, name_zip, arr_zip := {}, lshifr1,;
      CODE_LPU := glob_mo[_MO_KOD_TFOMS], code_schet, mb, me, nsh,;
      CODE_MO  := glob_mo[_MO_KOD_FFOMS], s1
DEFAULT fl_msg TO .t., arr_s TO {}
Private pole
//
use (cur_dir+"tmp1file") new alias TMP1
mdate_schet := tmp1->_DSCHET
nsh := f_mb_me_nsh(tmp1->_year,@mb,@me)
k := tmp1->_year
close databases
if k > 2018
  return create_schet19_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
else
  return create_schet17_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
endif
return .t.

***** 02.04.13 ��ᬮ�� ᯨ᪠ ��⮢, ������ ��� �����, ����� ��⮢
Function view_list_schet()
Local i, k, buf := savescreen(), tmp_help := chm_help_code, mdate := stod("20130101")
mywait()
close databases
R_Use(dir_server+"mo_rees",,"REES")
G_Use(dir_server+"mo_xml",,"MO_XML")
G_Use(dir_server+"schet_",,"SCHET_")
G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
dbseek(dtoc4(mdate),.t.)
index on dtos(schet_->dschet)+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp_sch") ;
      for schet_->dschet >= mdate .and. !empty(pdate) .and.;
          (schet_->IS_DOPLATA==1 .or. !empty(val(schet_->smo))) ;
      DESCENDING
go top
if eof()
  restscreen(buf)
  close databases
  return func_error(4,"��� �믨ᠭ��� ��⮢ c "+date_month(mdate))
endif
chm_help_code := 122
box_shadow(maxrow()-3,0,maxrow()-1,79,color0)
Alpha_Browse(T_ROW,0,maxrow()-4,79,"f1_view_list_schet",color0,,,,,,"f21_view_list_schet",;
             "f2_view_list_schet",,{'�','�','�',"N/BG,W+/N,B/BG,BG+/B,R/BG,RB/BG,GR/BG",.t.,60} )
close databases
chm_help_code := tmp_help
restscreen(buf)
return NIL

*****
Function f1_view_list_schet(oBrow)
Local s, oColumn, ;
   blk := {|| iif(!empty(schet_->NAME_XML).and.empty(schet_->date_out), {3,4}, {1,2}) }
oColumn := TBColumnNew("����� ���",{|| schet_->nschet })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  ���",{|| date_8(schet_->dschet) })
oColumn:colorBlock := {|| f23_view_list_schet() }
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("��-;ਮ�",;
          {|| iif(emptyany(schet_->nyear,schet_->nmonth), ;
                  space(5), ;
                  right(str(schet_->nyear,4),2)+"/"+strzero(schet_->nmonth,2)) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" �㬬� ���",{|| put_kop(schet->summa,13) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("���.;���.", {|| str(schet->kol,4) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("���਩", {|| padr(f3_view_list_schet(),10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("�ਭ����������;���",{|| padr(f4_view_list_schet(),14) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  ",{|| f22_view_list_schet() })
oColumn:colorBlock := {|| f23_view_list_schet() }
oBrow:addColumn(oColumn)
status_key("^<Esc>^ - ��室;  ^<F5>^ - ������ ��⮢ �� ����;  ^<F9>^ - ����� ����/॥���")
return NIL

*****
Function f21_view_list_schet()
Local s := "", fl := .t., r := row(), c := col()
if !emptyany(schet_->name_xml,schet_->kod_xml)
  fl := hb_FileExists(dir_server+dir_XML_MO+cslash+alltrim(schet_->name_xml)+szip)
  s := iif(fl,"XML-䠩�: ","��� XML-䠩��: ")+alltrim(schet_->name_xml)
  mo_xml->(dbGoto(schet_->XML_REESTR))
  if mo_xml->REESTR > 0
    rees->(dbGoto(mo_xml->REESTR))
    s += ", �� ॥���� � "+lstr(rees->NSCHET)+" �� "+;
         date_8(rees->DSCHET)+"�. ("+lstr(rees->KOL)+" 祫.)"
  endif
endif
@ maxrow()-2,1 say padc(s,78) color iif(fl,color0,"R/BG")
setpos(r,c)
return NIL

*****
Function f22_view_list_schet()
Local s := "  "
if schet_->NREGISTR == 1 // ��� �� ��ॣ����஢��
  s := ""
elseif schet_->NREGISTR == 2 // �� �㤥� ��ॣ����஢��
  s := "��"
elseif schet_->NREGISTR == 3 // 㤠��
  s := "--"
endif
return s

*****
Function f23_view_list_schet()
Local arr := iif(!empty(schet_->NAME_XML).and.empty(schet_->date_out), {3,4}, {1,2})
if schet_->NREGISTR == 1 // ��� �� ��ॣ����஢��
  arr[1] := 5
elseif schet_->NREGISTR == 2 // �� �㤥� ��ॣ����஢��
  arr[1] := 6
elseif schet_->NREGISTR == 3 // 㤠��
  arr[1] := 7
endif
return arr

*

***** 02.04.13
Function f2_view_list_schet(nKey,oBrow)
Local ret := -1, rec := schet->(recno()), tmp_color := setcolor(), r, r1, r2,;
      s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
do case
  case nKey == K_F5
    r := row()
    arr := {} ; k := 0 ; mdate := schet_->dschet
    find (dtos(mdate))
    do while schet_->dschet == mdate .and. !eof()
      if !emptyany(schet_->name_xml,schet_->kod_xml)
        aadd(arr, {schet_->nschet,schet_->name_xml,schet_->kod_xml,schet->(recno())})
        if empty(schet_->date_out)
          ++k
        endif
      endif
      skip
    enddo
    if len(arr) == 0
      func_error(4,"��祣� �����뢠��!")
    else
      if len(arr) > 1
        asort(arr,,,{|x,y| x[1] < y[1]})
        for i := 1 to len(arr)
          schet->(dbGoto(arr[i,4]))
          aadd(arr_pmt, {"���� � "+alltrim(schet_->nschet)+" ("+;
                         lstr(schet_->nyear)+"/"+strzero(schet_->nmonth,2)+;
                         ") 䠩� "+alltrim(schet_->name_xml),aclone(arr[i])})
        next
        if r+2+len(arr) > maxrow()-2
          r2 := r-1
          r1 := r2-len(arr)-1
          if r1 < 0 ; r1 := 0 ; endif
        else
          r1 := r+1
        endif
        arr := {}
        if (t_arr := bit_popup(r1,10,arr_pmt,,color5,1,"�����뢠��� 䠩�� ��⮢ ("+date_8(mdate)+")","B/W")) != NIL
          aeval(t_arr, {|x| aadd(arr,aclone(x[2])) })
        endif
        t_arr := array(2)
      endif
      if len(arr) > 0
        s := "������⢮ ��⮢ - "+lstr(len(arr))+;
             ", �����뢠���� � ���� ࠧ - "+lstr(k)+":"
        for i := 1 to len(arr)
          if i > 1
            s += ","
          endif
          s += " "+alltrim(arr[i,1])+" ("+alltrim(arr[i,2])+szip+")"
        next
        perenos(t_arr,s,74)
        f_message(t_arr,,color1,color8)
        if f_Esc_Enter("����� ��⮢ �� "+date_8(mdate)+"�.")
          Private p_var_manager := "copy_schet"
          s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" ��� �롮� ��⠫���
          if !empty(s)
            goal_dir := dir_server+dir_XML_MO+cslash
            if upper(s) == upper(goal_dir)
              func_error(4,"�� ��ࠫ� ��⠫��, � ���஬ 㦥 ����ᠭ� 楫��� 䠩��! �� �������⨬�.")
            else
              cFileProtokol := "prot_sch"+stxt
              strfile(hb_eol()+center(glob_mo[_MO_SHORT_NAME],80)+hb_eol()+hb_eol(),cFileProtokol)
              smsg := "��� ����ᠭ� ��: "+s+;
                      " ("+full_date(sys_date)+"�. "+hour_min(seconds())+")"
              strfile(center(smsg,80)+hb_eol(),cFileProtokol,.t.)
              k := 0
              for i := 1 to len(arr)
                zip_file := alltrim(arr[i,2])+szip
                if hb_fileExists(goal_dir+zip_file)
                  mywait('����஢���� "'+zip_file+'" � ��⠫�� "'+s+'"')
                  //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
                  copy file (goal_dir+zip_file) to (s+zip_file)
                  //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
                  if hb_fileExists(s+zip_file)
                    ++k
                    schet->(dbGoto(arr[i,4]))
                    smsg := lstr(i)+". ���� � "+alltrim(schet_->nschet)+;
                            " �� "+date_8(mdate)+"�. (���.��ਮ� "+;
                             lstr(schet_->nyear)+"/"+strzero(schet_->nmonth,2)+;
                             ") "+alltrim(schet_->name_xml)+szip
                    strfile(hb_eol()+smsg+hb_eol(),cFileProtokol,.t.)
                    smsg := "   ������⢮ ��樥�⮢ - "+lstr(schet->kol)+;
                            ", �㬬� ���� - "+expand_value(schet->summa,2)
                    strfile(smsg+hb_eol(),cFileProtokol,.t.)
                    schet_->(G_RLock(forever))
                    schet_->DATE_OUT := sys_date
                    if schet_->NUMB_OUT < 99
                      schet_->NUMB_OUT ++
                    endif
                    //
                    mo_xml->(dbGoto(arr[i,3]))
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
              next
              UnLock
              Commit
              viewtext(cFileProtokol,,,,.t.,,,2)
              /*asize(t_arr,1)
              perenos(t_arr,"����ᠭ� ��⮢ - "+lstr(k)+" � ��⠫�� "+s+;
                     iif(k == len(arr), "", ", �� ����ᠭ� ��⮢ - "+lstr(len(arr)-k)),60)
              stat_msg("������ �����襭�!")
              n_message(t_arr,,"GR+/B","W+/B",18,,"G+/B")*/
            endif
          endif
        endif
      endif
    endif
    select SCHET
    goto (rec)
    ret := 0
  case nKey == K_F9
    print_schet(oBrow)
    select SCHET
    ret := 0
  case nKey == K_CTRL_F11 .and. !empty(schet_->NAME_XML) .and. schet_->XML_REESTR > 0
    k := schet_->XML_REESTR // ��뫪� �� ॥��� �� � ��
    arr := {}
    go top
    do while !eof()
      if !emptyany(schet_->name_xml,schet_->kod_xml) .and. k == schet_->XML_REESTR
        aadd(arr,schet->(recno()))
      endif
      skip
    enddo
    if len(arr) == 0
      func_error(4,"��㤠�� ����!")
    else
      if len(arr) > 1
        for i := 1 to len(arr)
          schet->(dbGoto(arr[i]))
          aadd(arr_pmt, {"���� � "+alltrim(schet_->nschet)+" ("+;
                         lstr(schet_->nyear)+"/"+strzero(schet_->nmonth,2)+;
                         ") 䠩� "+alltrim(schet_->name_xml),arr[i]})
        next
        r := row()
        if r+2+len(arr) > maxrow()-2
          r2 := r-1
          r1 := r2-len(arr)-1
          if r1 < 0 ; r1 := 0 ; endif
        else
          r1 := r+1
        endif
        arr := {}
        if (t_arr := bit_popup(r1,10,arr_pmt,,"N/W*,GR+/R",1,"���ᮧ������� 䠩�� ��⮢","B/W*")) != NIL
          aeval(t_arr, {|x| aadd(arr,x[2]) })
        endif
      endif
      if len(arr) > 0
        ReCreate_some_Schet_From_FILE_SP(arr)
        close databases
        R_Use(dir_server+"mo_rees",,"REES")
        G_Use(dir_server+"mo_xml",,"MO_XML")
        G_Use(dir_server+"schet_",,"SCHET_")
        G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
        set relation to recno() into SCHET_
        go top
        ret := 1
      endif
    endif
  case nKey == K_CTRL_F12 .and. !empty(schet_->NAME_XML) .and. schet_->XML_REESTR > 0
    ReCreate_some_Schet_From_FILE_SP({schet->(recno())})
    close databases
    R_Use(dir_server+"mo_rees",,"REES")
    G_Use(dir_server+"mo_xml",,"MO_XML")
    G_Use(dir_server+"schet_",,"SCHET_")
    G_Use(dir_server+"schet",dir_server+"schetd","SCHET")
    set relation to recno() into SCHET_
    go top
    ret := 1
endcase
setcolor(tmp_color)
restscreen(buf)
return ret

*

***** 26.04.15
Function f3_view_list_schet()
Local s := ""
if schet_->nyear < 2013 .and. schet_->IS_MODERN == 1 // ���� ����୨��樥�?;0-���, 1-�� ��� IFIN=1
  s := "����୨����"
endif
if schet_->IS_DOPLATA == 1 // ���� �����⮩?;0-���, 1-�� ��� IFIN=1 ��� 2
  s := "����."
  if schet_->IFIN == 1
    s += "�����"
  elseif schet_->IFIN == 2
    s += "�����"
  endif
endif
if empty(s) .and. schet_->IFIN > 0
  s := "��� "
  if schet_->bukva     == "A"
    s += "�-��"
  elseif schet_->bukva == "D"
    s += "���"
  elseif schet_->bukva == "E"
    s += "���"
  elseif schet_->bukva == "F"
    s += "����."
  elseif schet_->bukva == "G"
    s += "��ଠ�"
  elseif schet_->bukva == "H"
    s += "���"
  elseif schet_->bukva == "I"
    s += "���ਮ"
  elseif schet_->bukva == "J"
    s += "�-��"
  elseif schet_->bukva == "K"
    s += "�/�/�"
  elseif schet_->bukva == "M"
    s += "���/�"
  elseif schet_->bukva == "O"
    s += "�����"
  elseif schet_->bukva == "R"
    s += "�����"
  elseif schet_->bukva == "S"
    s += "���."
  elseif schet_->bukva == "T"
    s += "�⮬��"
  elseif schet_->bukva == "U"
    s += "�����"
  elseif schet_->bukva == "V"
    s += "��।."
  elseif schet_->bukva == "Z"
    s += "��/��."
  elseif schet_->IFIN == 1
    s += "�����"
  elseif schet_->IFIN == 2
    s += "�����"
  endif
endif
return s

*****
Function f4_view_list_schet(lkomu,lsmo,lstr_crb)
Local s := ""
DEFAULT lkomu TO schet->komu, lsmo TO schet_->smo, lstr_crb TO schet->str_crb
if lkomu == 5
  s := "���� ����"
elseif !empty(lsmo)
  s := inieditspr(A__MENUVERT, glob_arr_smo, int(val(lsmo)))
  if empty(s)
    s := inieditspr(A__POPUPMENU, dir_server+"str_komp", lstr_crb)
    if empty(s)
      s := lsmo
    endif
  endif
elseif lkomu == 1
  s := inieditspr(A__POPUPMENU, dir_server+"str_komp", lstr_crb)
elseif lkomu == 3
  s := inieditspr(A__POPUPMENU, dir_server+"komitet", lstr_crb)
endif
return s

***** ��� ᮢ���⨬��� � ��ன ���ᨥ� �ணࠬ��
Function func1_komu(lkomu,lstr_crb)
return f4_view_list_schet(lkomu,"",lstr_crb)

*

*****
Function print_schet(oBrow)
Static si := 1
Local i, r := row(), r1, r2, mm_menu := {}
if schet_->IS_DOPLATA == 1 // ���� �����⮩?;0-���, 1-�� ��� IFIN=1 ��� 2
  if schet_->IFIN == 1  // "�����"
    print_schet_doplata(1)
  elseif schet_->IFIN == 2 // "�����"
    print_schet_doplata(2)
  endif
elseif !empty(val(schet_->smo))
  for i := 1 to 2
    aadd(mm_menu, "����� "+iif(i==1,"","॥��� ")+"���� �� ������ ����樭᪮� �����")
  next
  if r <= maxrow()/2
    r1 := r+1 ; r2 := r1+3
  else
    r2 := r-1 ; r1 := r2 - 3
  endif
  if (i := popup_prompt(r1,10,si,mm_menu,,,color5)) > 0
    si := i
    print_schet_S(i)
  endif
else
  print_other_schet(1)
endif
return NIL


*

***** 17.02.21 ����� ���
Function print_schet_S(reg)
Local adbf, j, s, ii := 0, fl_numeration := .f., buf := save_maxrow(),;
      lshifr1, ldate1, ldate2, hGauge
mywait()
delFRfiles()
adbf := {{"name","C",130,0},;
         {"name_schet","C",130,0},;
         {"adres","C",110,0},;
         {"ogrn","C",15,0},;
         {"inn","C",12,0},;
         {"kpp","C",9,0},;
         {"bank","C",130,0},;
         {"r_schet","C",45,0},;
         {"bik","C",10,0},;
         {"ruk","C",20,0},;
         {"bux","C",20,0},;
         {"k_schet","C",45,0},;
         {"ispolnit","C",20,0},;
         {"plat","C",250,0},;
         {"nschet","C",20,0},;
         {"dschet","C",30,0},;
         {"date_begin","C",30,0},;
         {"date_end","C",30,0},;
         {"date_podp","C",13,0},;
         {"susluga","C",250,0},;
         {"summa","N",15,2}}
dbcreate(fr_titl, adbf)
R_Use(dir_server+"organiz",,"ORG")
use (fr_titl) new alias FRT
append blank
frt->name := frt->name_schet := org->name
if !empty(org->name_schet)
  frt->name_schet := org->name_schet
endif
s := alltrim(org->adres)
if !empty(charrem("-",org->telefon))
  s += " ⥫."+alltrim(org->telefon)
endif
frt->adres := s
frt->ogrn := org->ogrn
sinn := org->inn ; skpp := ""
if "/" $ sinn
  skpp := afteratnum("/",sinn)
  sinn := beforatnum("/",sinn)
endif
frt->inn := sinn
frt->kpp := skpp
frt->bank := org->bank
frt->r_schet := org->r_schet
frt->bik := org->smfo
frt->ruk := org->ruk
frt->bux := org->bux
frt->k_schet := org->k_schet
frt->ispolnit := org->ispolnit
frt->date_podp := full_date(sys_date)+" �."
s := ""
if (j := ascan(arr_rekv_smo,{|x| x[1]==schet_->SMO})) > 0
  s := arr_rekv_smo[j,2]
  if reg == 2 .and. int(val(schet_->SMO)) == 34 // �����த��� !
    reg := 3
  endif
elseif schet->str_crb > 0
  if schet->komu == 3
    s := inieditspr(A__POPUPMENU, dir_server+"komitet", schet->str_crb)
  else
    s := inieditspr(A__POPUPMENU, dir_server+"str_komp", schet->str_crb)
  endif
endif
frt->plat := s
frt->nschet := schet_->nschet
frt->dschet := date_month(schet_->dschet)
s := "�� ����樭��� ������, ��������� "
if !empty(schet_->SMO)
  s += "�����客���� ��栬 "
endif
if !emptyany(schet_->nyear,schet_->nmonth)
  s += "�� "+mm_month[schet_->nmonth]+str(schet_->nyear,5)+" ����"
  ldate := stod(strzero(schet_->nyear,4)+strzero(schet_->nmonth,2)+"01")
  frt->date_begin := date_month(ldate)
  frt->date_end   := date_month(eom(ldate))
else
  s := "�� ��������� ����樭��� ������"
  fl_numeration := .t.
endif
frt->susluga := s
frt->summa := schet->summa
org->(dbCloseArea())
rest_box(buf)
//
if reg > 1
  hGauge := GaugeNew(,,{"GR+/RB","BG+/RB","G+/RB"},"���⠢����� ����",.t.)
  GaugeDisplay( hGauge )
  adbf := {{"nomer","N",4,0},;
           {"fio","C",50,0},;
           {"pol","C",10,0},;
           {"date_r","C",10,0},;
           {"mesto_r","C",100,0},;
           {"pasport","C",50,0},;
           {"adresp","C",250,0},;
           {"adresg","C",250,0},;
           {"snils","C",50,0},;
           {"polis","C",50,0},;
           {"vid_pom","C",10,0},;
           {"diagnoz","C",10,0},;
           {"n_data","C",10,0},;
           {"k_data","C",10,0},;
           {"ob_em","N",5,0},;
           {"profil","C",10,0},;
           {"vrach","C",10,0},;
           {"cena","N",12,2},;
           {"stoim","N",12,2},;
           {"rezultat","C",10,0}}
  dbcreate(fr_data,adbf)
  use (fr_data) new alias FRD
  index on str(nomer,4) to (fr_data)
  use_base("lusl")
  R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                              dir_server+"uslugi1s"},"USL1")
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to u_kod into USL
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_
  G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",dir_server+"humans","HUMAN")
  set relation to recno() into HUMAN_, to kod_k into KART
  Select HUMAN
  find (str(schet->kod,6))
  do while human->schet == schet->kod .and. !eof()
    fl := .t. ; fl_2 := .f.
    lal := "human"
    if human->ishod == 88
      fl_2 := .t.
      lal += "_3"
      select HUMAN_3
      find (str(human->kod,7))
    elseif human->ishod == 89
      fl := .f. // ��ன ��砩 � ������� �ய�᪠��
    endif
    if fl
      GaugeUpdate( hGauge, ++ii/schet->kol )
      ldate1 := iif(ldate1==nil, &lal.->k_data, min(ldate1,&lal.->k_data))
      ldate2 := iif(ldate2==nil, &lal.->k_data, max(ldate2,&lal.->k_data))
      a_diag := diag_for_xml(,.t.,,,.t.)
      is_zak_sl := is_zak_sl_d := is_zak_sl_v := .f.
      lst := kol_dn := mcena := 0 ; lvidpom := 1 ; au := {}
      select HU
      find (str(human->kod,7))
      do while hu->kod == human->kod .and. !eof()
        lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
        if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          if (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
            lvidpom := i
          endif
          if left(lshifr,5) == "55.1." // ������� ��樮��� � 1 ��५� 2013 ����
            kol_dn += hu->KOL_1
          elseif eq_any(left(lshifr,4),"55.2","55.3","55.4") // ���� ������� ��樮���
            kol_dn += hu->KOL_1 ; mcena := hu->u_cena
          elseif left(lshifr,2) == "1."
            kol_dn += hu->KOL_1 ; mcena := hu->u_cena
          endif
          if lst == 1
            if left(lshifr,2) == "1."
              is_zak_sl := .t. ; mcena := hu->u_cena
            elseif left(lshifr,3) == "55."
              if human->k_data < d_01_04_2013 // ������� ��樮��� �� 1 ��५�
                is_zak_sl_d := .t.
              endif
              mcena := hu->u_cena
            elseif f_is_zak_sl_vr(lshifr) // ���.��砩 � �-��
              is_zak_sl_v := .t. ; mcena := hu->u_cena
            endif
          else
            j := ascan(au,{|x| x[1]==lshifr .and. x[2]==hu->date_u })
            if j == 0
              aadd(au,{lshifr,hu->date_u,0,hu->u_cena})
              j := len(au)
            endif
            au[j,3] += hu->kol_1
          endif
        endif
        select HU
        skip
      enddo
      if fl_2
        kol_dn := human_3->k_data - human_3->n_data
      elseif is_zak_sl
        kol_dn := human->k_data - human->n_data
      elseif is_zak_sl_d
        kol_dn := human->k_data - human->n_data + 1
      elseif is_zak_sl_v
        for j := 1 to len(au)
          if left(au[j,1],2) == "2."
            kol_dn += au[j,3]
          endif
        next
      elseif empty(kol_dn)
        for j := 1 to len(au)
          kol_dn += au[j,3]
        next
        if kol_dn > 0
          mcena := round_5(human->cena_1/kol_dn,2)
          if !(round(mcena,2) == round(au[1,4],2))
            kol_dn := mcena := 0
          endif
        endif
      endif
      select FRD
      append blank
      frd->nomer := iif(fl_numeration, ii, human_->SCHET_ZAP)
      frd->fio := human->fio
      frd->pol := iif(human->pol=="�","��","���")
      frd->date_r := full_date(human->date_r)
      frd->mesto_r := kart_->mesto_r
      s := ""
      if (j := ascan(menu_vidud, {|x| x[2] == kart_->vid_ud})) > 0
        s := menu_vidud[j,4]+" "
      endif
      if !empty(kart_->ser_ud)
        s += alltrim(kart_->ser_ud)+" "
      endif
      if !empty(kart_->nom_ud)
        s += alltrim(kart_->nom_ud)
      endif
      frd->pasport := s
      frd->adresg := ret_okato_ulica(kart->adres,kart_->okatog,0,2)
      if empty(kart_->okatop)
        frd->adresp := frd->adresg
      else
        frd->adresp := ret_okato_ulica(kart_->adresp,kart_->okatop,0,2)
      endif
      if !empty(kart->snils)
        frd->snils := transform(kart->SNILS,picture_pf)
      endif
      frd->polis := alltrim(alltrim(human_->SPOLIS)+" "+human_->NPOLIS)
      frd->vid_pom := lstr(lvidpom)
      frd->diagnoz := a_diag[1]
      frd->n_data := full_date(&lal.->n_data)
      frd->k_data := full_date(&lal.->k_data)
      frd->ob_em := kol_dn
      if human_->PROFIL > 0
        frd->profil := lstr(human_->PROFIL)
      endif
      if !empty(human_->PRVS)
        frd->vrach := put_prvs_to_reestr(human_->PRVS,schet_->nyear)
        lstr(abs(human_->PRVS))
      endif
      if fl_2
        frd->cena := frd->stoim := human_3->cena_1
        frd->rezultat := lstr(human_3->RSLT_NEW)
      else
        frd->cena := mcena
        frd->stoim := human->cena_1
        frd->rezultat := lstr(human_->RSLT_NEW)
      endif
    endif
    Select HUMAN
    skip
  enddo
  close_use_base('lusl')
  // lusl->(dbCloseArea())
  // lusl21->(dbCloseArea())
  // lusl20->(dbCloseArea())
  // lusl19->(dbCloseArea())
  // lusl18->(dbCloseArea())
  usl1->(dbCloseArea())
  usl->(dbCloseArea())
  hu->(dbCloseArea())
  kart_->(dbCloseArea())
  kart->(dbCloseArea())
  human_3->(dbCloseArea())
  human_->(dbCloseArea())
  human->(dbCloseArea())
  frd->(dbCloseArea())
  if fl_numeration .and. !emptyany(ldate1,ldate2)
    frt->date_begin := date_month(ldate1)
    frt->date_end   := date_month(ldate2)
  endif
  CloseGauge(hGauge)
endif
frt->(dbCloseArea())
do case
  case reg == 1
    call_fr("mo_schet")
  case reg == 2
    call_fr("mo_reesv")
  case reg == 3
    call_fr("mo_reesi")
endcase
select SCHET
return NIL

*

***** ��ᬮ�� � ����� �믨ᠭ��� ��⮢/॥��஢ �� �������
Function print_schet_doplata(reg)
// reg = 1 - ������ �����
// reg = 2 - ������ �����
Local arr_title, arr1title, sh, HH := 57, n_file := "schetd"+stxt,;
      s, i, j, j1, a_shifr[10], k1, k2, k3, lshifr, v_doplata, rec,;
      buf := save_maxrow(), t_arr[2], llpu, lbank, ssumma := 0,;
      fl_numeration, is_20_11, sdate := stod("20121120") // 20.11.2012�.
if schet_->NREGISTR == 0 // ��ॣ����஢���� ���
  is_20_11 := (date_reg_schet() >= sdate)
else
  is_20_11 := (schet_->DSCHET > stod("20121210")) // 10.12.2012�.
endif
s1 := iif(reg==2,space(11),"� ᮯ����. ")
s2 := iif(reg==2,space(11),"��������   ")
arr_title := {;
"��������������������������������������������������������������������������������",;
"�   �� ��� �� ��� �� ���客�������    ����       ����        ������� ��    ",;
"�����               ����� �    ���� ��������祭- ��᭮�����  ������� ��㣥 ",;
"樨 �               ���� �� �������     �����      ���������   ��� �।��    ",;
"॥�               �            �        �����    �"+s1+     "���� "+iif(reg==2,"����� ","����� "),;
"�� �               �            �        �          �"+s2+     "�(�㡫��)      ",;
"��������������������������������������������������������������������������������",;
" 1  �       2       �      3     �   4    �    5     �     6     �       7      ",;
"��������������������������������������������������������������������������������"}
  arr1title := {;
"��������������������������������������������������������������������������������",;
" 1  �       2       �      3     �   4    �    5     �     6     �       7      ",;
"��������������������������������������������������������������������������������"}
//
use_base("lusl")
use_base("lusld")
use_base("luslf")
R_Use(dir_server+"uslugi",,"USL")
R_Use(dir_server+"human_u",dir_server+"human_u","HU")
set relation to u_kod into USL
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server+"organiz",,"ORG")
R_Use(dir_server+"schetd",,"SD")
index on str(kod,6) to (cur_dir+"tmp_sd")
//
sh := len(arr_title[1])
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(center("��� � "+alltrim(schet_->nschet)+" �� "+full_date(schet_->dschet)+" �.",sh))
s := "�� ������ ����樭᪮� ����� �� ��� �।�� ��� "+iif(reg==2,"����ࠫ쭮��","�����ਠ�쭮��")+" 䮭�� "
s += "��易⥫쭮�� ����樭᪮�� ���客���� "+iif(reg==2,"","������ࠤ᪮� ������ ")+"�� �ணࠬ�� ����୨��樨 ��ࠢ���࠭���� "
s += "������ࠤ᪮� ������ �� 2011-2012 ���� � ��� ॠ����樨 ��ய��⨩ �� "
s += "���⠯���� ����७�� �⠭���⮢ ����樭᪮� �����"
for k := 1 to perenos(t_arr,s,sh)
  add_string(center(alltrim(t_arr[k]),sh))
next
add_string("")
sinn := org->inn ; skpp := ""
if "/" $ sinn
  skpp := afteratnum("/",sinn)
  sinn := beforatnum("/",sinn)
endif
sname    := org->name
sbank    := org->bank
sr_schet := org->r_schet
sbik     := org->smfo
if reg==2
  if !empty(org->r_schet2)
    sbank    := org->bank2
    sr_schet := org->r_schet2
    sbik     := org->smfo2
  endif
  if !empty(org->name2)
    sname := org->name2
  endif
endif
k := perenos(t_arr,sname,sh-11)
add_string("���⠢騪: "+t_arr[1])
for i := 2 to k
  add_string(space(11)+t_arr[2])
next
add_string("���: "+padr(sinn,12)+", ���: "+skpp)
add_string("����: "+rtrim(org->adres))
k := perenos(t_arr,sbank,sh-17)
add_string("���� ���⠢騪�: "+t_arr[1])
for i := 2 to k
  add_string(space(17)+t_arr[2])
next
add_string("������ ���: "+alltrim(sr_schet)+", ���: "+alltrim(sbik))
add_string("")
add_string("")
if (j := ascan(arr_rekv_smo,{|x| x[1]==schet_->SMO})) == 0
  j := len(arr_rekv_smo) // �᫨ �� ��諨 - ���⠥� ४������ �����
endif
k := perenos(t_arr,arr_rekv_smo[j,2],sh-12)
add_string("���⥫�騪: "+t_arr[1])
for i := 2 to k
  add_string(space(12)+t_arr[2])
next
add_string("���: "+arr_rekv_smo[j,3]+", ���: "+arr_rekv_smo[j,4])
k := perenos(t_arr,arr_rekv_smo[j,6],sh-7)
add_string("����: "+t_arr[1])
for i := 2 to k
  add_string(space(7)+t_arr[2])
next
k := perenos(t_arr,arr_rekv_smo[j,7],sh-18)
add_string("���� ���⥫�騪�: "+t_arr[1])
for i := 2 to k
  add_string(space(18)+t_arr[2])
next
add_string("������ ���: "+alltrim(arr_rekv_smo[j,8])+", ���: "+alltrim(arr_rekv_smo[j,9]))
add_string("")
add_string("")
add_string(center("������ ��� � "+alltrim(schet_->nschet)+" �� "+full_date(schet_->dschet)+" �.",sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
select SCHET
fl_numeration := emptyany(schet_->nyear,schet_->nmonth)
rec := recno()
set index to
j := 0
select SD
find (str(rec,6))
do while sd->kod == rec .and. !eof()
  schet->(dbGoto(sd->kod2))
  j1 := 0
  Select HUMAN
  find (str(sd->kod2,6))
  do while human->schet == sd->kod2 .and. !eof()
    lshifr := "" ; v_doplata := r_doplata := 0
    ret_zak_sl(@lshifr,@v_doplata,@r_doplata,,,iif(is_20_11, sdate, nil))
    if iif(reg==1, !empty(r_doplata), .t.)
      a_diag := diag_for_xml(,.t.,,,.t.)
      s_diag := a_diag[1]
      if reg==1 .and. len(a_diag)>1 .and. !empty(a_diag[2])
        s_diag += " "+a_diag[2]
      endif
      s := padr(lstr(++j),5)+;
           padc(alltrim(schet_->nschet),15)+" "+;
           padr(str(iif(fl_numeration, ++j1, human_->SCHET_ZAP),7),13)+;
           date_8(schet_->dschet)+" "+;
           padc(lshifr,10)+;
           padc(alltrim(s_diag),13)+;
           str(iif(reg==2,v_doplata,r_doplata),11,2)
      ssumma += iif(reg==2,v_doplata,r_doplata)
      if verify_FF(HH,.t.,sh)
        aeval(arr1title, {|x| add_string(x) } )
      endif
      add_string(s)
    endif
    //
    Select HUMAN
    skip
  enddo
  select SD
  skip
enddo
if verify_FF(HH-8,.t.,sh)
  aeval(arr1title, {|x| add_string(x) } )
endif
add_string(replicate("�",sh))
add_string(padl("�ᥣ�: "+lstr(ssumma,14,2),sh-3))
add_string("")
k := perenos(t_arr,"� �����: "+srub_kop(ssumma,.t.),sh)
add_string(t_arr[1])
for j := 2 to k
  add_string(padl(alltrim(t_arr[j]),sh))
next
add_string("")
add_string("  ������ ��� ����樭᪮� �࣠����樨      _____________ / "+alltrim(org->ruk)+" /")
add_string("  ������ ��壠��� ����樭᪮� �࣠����樨 _____________ / "+alltrim(org->bux)+" /")
add_string("                                        �.�.")
fclose(fp)

rest_box(buf)
close_use_base('lusl')
// lusl->(dbCloseArea())
// lusl21->(dbCloseArea())
// lusl20->(dbCloseArea())
// lusl19->(dbCloseArea())
// lusl18->(dbCloseArea())

lusld->(dbCloseArea())

close_use_base('luslf')
// luslf->(dbCloseArea())
// luslf21->(dbCloseArea())
// luslf20->(dbCloseArea())
// luslf19->(dbCloseArea())
// luslf18->(dbCloseArea())

usl->(dbCloseArea())
hu->(dbCloseArea())
human_->(dbCloseArea())
human->(dbCloseArea())
org->(dbCloseArea())
sd->(dbCloseArea())
if select("USL1") > 0
  usl1->(dbCloseArea())
endif
select SCHET
if !(round(ssumma,2) == round(schet->summa,2))
  // �᫨ ����� ������ 業��� - ��१���襬 �㬬� ����
  goto (rec)
  G_RLock(forever)
  schet->summa := schet->summa_ost := ssumma
  UnLock
  Commit
endif
set index to (cur_dir+"tmp_sch")
goto (rec)
viewtext(n_file,,,,.t.,,,2)
return NIL

*

***** 23.04.13 ����� ����� ॥��� �� XML-䠩��� � ������� �� �६���� DBF-䠩��
Function my_extract_reestr()
Local cName, full_zip
full_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*"+szip)
if !empty(full_zip)
  cName := Name_Without_Ext(StripPath(full_zip))
  if left(cName,3) == "HRM" // 䠩� ॥���
    extract_reestr(1,cName,,,KeepPath(full_zip)+cslash)
  else
    func_error(4,"�� �� 䠩� ॥���")
  endif
endif
return NIL

***** 02.11.19 ������ ��⮪�� ��� �� �६���� 䠩��
Function protokol_flk_tmpfile(arr_f,aerr)
Local adbf, ii, j, s, oXmlDoc, oXmlNode, is_err_FLK := .f.
adbf := {;
 {"FNAME",  "C", 27,0},;
 {"FNAME1", "C", 26,0},;
 {"FNAME2", "C", 26,0},;
 {"DATE_F", "D",  8,0},;
 {"KOL2",   "N",  6,0};   // ���-�� �訡��
}
dbcreate(cur_dir+"tmp1file",adbf)
adbf := {; // ������ PR
 {"TIP",        "N",  1,0},;  // ⨯(�����) ��ࠡ��뢠����� 䠩��
 {"OSHIB",      "N",  3,0},;  // ��� �訡�� T005
 {"SOSHIB",     "C", 12,0},;  // ��� �訡�� Q015, Q022
 {"IM_POL",     "C", 20,0},;  // ��� ����, � ���஬ �訡��
 {"BAS_EL",     "C", 20,0},;  // ��� �������� �����
 {"ID_BAS",     "C", 36,0},;  // GUID �������� �����
 {"COMMENT",    "C",250,0},;  // ���ᠭ�� �訡��
 {"N_ZAP",      "N",  6,0},;  // ���� �� ��ࢨ筮�� ॥���
 {"KOD_HUMAN",  "N",  7,0};   // ��� �� �� ���⮢ ����
}
dbcreate(cur_dir+"tmp2file",adbf) // ������ PR
dbcreate(cur_dir+"tmp22fil",adbf) // ���.䠩�, �᫨ �� ������ ��樥��� > 1 ���� ����
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
for ii := 1 to len(arr_f)
  // �.�. � ZIP'� ��� XML-䠩��, ��ன 䠩� ⠪�� ������
  if upper(right(arr_f[ii],4)) == sxml .and. valtype(oXmlDoc := HXMLDoc():Read(_tmp_dir1+arr_f[ii])) == "O"
    FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
      oXmlNode := oXmlDoc:aItems[1]:aItems[j]
      do case
        case "FNAME" == oXmlNode:title
          tmp1->FNAME := mo_read_xml_tag(oXmlNode,aerr,.t.)
        case "FNAME_I" == oXmlNode:title
          if ii == 1
            tmp1->FNAME1 := mo_read_xml_tag(oXmlNode,aerr,.t.)
          else
            tmp1->FNAME2 := mo_read_xml_tag(oXmlNode,aerr,.t.)
          endif
        case "DATE_F" == oXmlNode:title
          tmp1->DATE_F := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_F",aerr,.f.))
        case "PR" == oXmlNode:title
          select TMP2
          append blank
          tmp2->tip := ii
          s := alltrim(mo_read_xml_stroke(oXmlNode,"OSHIB",aerr))
          if len(s) > 3 .or. "." $ s
            tmp2->SOSHIB := s
          else
            tmp2->OSHIB := val(s)
          endif
          tmp2->IM_POL  := mo_read_xml_stroke(oXmlNode,"IM_POL",aerr,.f.)
          tmp2->BAS_EL  := mo_read_xml_stroke(oXmlNode,"BAS_EL",aerr,.f.)
          tmp2->ID_BAS  := mo_read_xml_stroke(oXmlNode,"ID_BAS",aerr,.f.)
          tmp2->COMMENT := mo_read_xml_stroke(oXmlNode,"COMMENT",aerr,.f.)
          if !empty(tmp2->BAS_EL) .and. !empty(tmp2->ID_BAS)
            is_err_FLK := .t.
            tmp1->KOL2 ++
          endif
      endcase
    NEXT j
  endif
next ii
commit
return is_err_FLK

*

***** 27.04.20 ������ ॥��� �� � �� �� �६���� 䠩��
Function reestr_sp_tk_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, _ar, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("��ᯠ�����/�⥭��/������ ॥��� �� � �� "+beforatnum(".",mname_xml))
dbcreate(cur_dir+"tmp1file", {;
 {"_VERSION",   "C",  5,0},;
 {"_DATA",      "D",  8,0},;
 {"_FILENAME",  "C", 26,0},;
 {"_CODE",      "N",  8,0},;
 {"_CODE_MO",   "C",  6,0},;
 {"_YEAR",      "N",  4,0},;
 {"_MONTH",     "N",  2,0},;
 {"_NSCHET",    "C", 15,0},;
 {"_DSCHET",    "D",  8,0},;
 {"KOL1",       "N",  6,0},;
 {"KOL2",       "N",  6,0};
})
dbcreate(cur_dir+"tmp2file", {;
 {"_N_ZAP",     "N",  8,0},;
 {"_ID_PAC",    "C", 36,0},;
 {"_VPOLIS",    "N",  1,0},;
 {"_SPOLIS",    "C", 10,0},;
 {"_NPOLIS",    "C", 20,0},;
 {"_ENP",       "C", 16,0},;
 {"_SMO",       "C",  5,0},;
 {"_SMO_OK",    "C",  5,0},;
 {"_MO_PR",     "C",  6,0},;
 {"KOD_HUMAN",  "N",  7,0},; // ��� �� �� ���⮢ ����
 {"FIO",        "C", 50,0},;
 {"SCHET_CHAR", "C",  1,0},; // ����, �㪢� "M", ��� �㪢� "D"
 {"SCHET"    ,  "N",  6,0},; // ��� ���
 {"SCHET_ZAP",  "N",  6,0},; // ����� ����樨 ����� � ���
 {"_IDCASE",    "N",  8,0},;
 {"_ID_C",      "C", 36,0},;
 {"_IDENTITY",  "N",  1,0},;
 {"CORRECT",    "C",  2,0},;
 {"_FAM"  ,     "C", 40,0},; //
 {"_IM"   ,     "C", 40,0},; //
 {"_OT"   ,     "C", 40,0},; //
 {"_DR"   ,     "C", 10,0},; //
 {"_OPLATA",    "N",  1,0};
})
dbcreate(cur_dir+"tmp3file", {;
 {"_N_ZAP",     "N",  8,0},;
 {"_REFREASON", "N",  3,0},;
 {"SREFREASON", "C", 12,0};
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
      tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION", aerr)
      tmp1->_DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA",    aerr))
      tmp1->_FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILENAME",aerr)
    case "SCHET" == oXmlNode:title
      tmp1->_CODE    :=      val(mo_read_xml_stroke(oXmlNode,"CODE",   aerr))
      tmp1->_CODE_MO :=          mo_read_xml_stroke(oXmlNode,"CODE_MO",aerr)
      tmp1->_YEAR    :=      val(mo_read_xml_stroke(oXmlNode,"YEAR",   aerr))
      tmp1->_MONTH   :=      val(mo_read_xml_stroke(oXmlNode,"MONTH",  aerr))
      tmp1->_NSCHET  :=          mo_read_xml_stroke(oXmlNode,"NSCHET", aerr)
      tmp1->_DSCHET  := xml2date(mo_read_xml_stroke(oXmlNode,"DSCHET", aerr))
    case "ZAP" == oXmlNode:title
      select TMP2
      append blank
      tmp2->_N_ZAP := val(mo_read_xml_stroke(oXmlNode,"N_ZAP",aerr))
      if (oNode1 := oXmlNode:Find("PACIENT")) == NIL
        aadd(aerr,'��������� ���祭�� ��易⥫쭮�� �� "PACIENT"')
      else
        tmp2->_ID_PAC := upper(mo_read_xml_stroke(oNode1,"ID_PAC",aerr))
        tmp2->_VPOLIS :=   val(mo_read_xml_stroke(oNode1,"VPOLIS",aerr))
        tmp2->_SPOLIS :=       mo_read_xml_stroke(oNode1,"SPOLIS",aerr,.f.)
        tmp2->_NPOLIS :=       mo_read_xml_stroke(oNode1,"NPOLIS",aerr)
        tmp2->_ENP    :=       mo_read_xml_stroke(oNode1,"ENP"   ,aerr,.f.)
        tmp2->_SMO    :=       mo_read_xml_stroke(oNode1,"SMO"   ,aerr)
        tmp2->_SMO_OK :=       mo_read_xml_stroke(oNode1,"SMO_OK",aerr)
        tmp2->_MO_PR  :=       mo_read_xml_stroke(oNode1,"MO_PR" ,aerr,.f.)
        tmp2->_IDENTITY := val(mo_read_xml_stroke(oNode1,"IDENTITY",aerr,.f.))
        if empty(tmp2->_MO_PR)
          tmp2->_MO_PR := replicate("0",6)
        endif
        if (oNode2 := oNode1:Find("CORRECTION")) != NIL
          tmp2->_FAM := mo_read_xml_stroke(oNode2,"FAM",aerr,.f.)
          tmp2->_IM  := mo_read_xml_stroke(oNode2,"IM",aerr,.f.)
          tmp2->_OT  := mo_read_xml_stroke(oNode2,"OT",aerr,.f.)
          tmp2->_DR  := mo_read_xml_stroke(oNode2,"DR",aerr,.f.)
          if oNode2:Find("OT") != NIL .and. empty(tmp2->_OT)
            tmp2->CORRECT := "OT" // �.�. ���⮥ ����⢮
          endif
        endif
      endif
      if alltrim(tmp1->_VERSION) == "3.11"
        if (oNode1 := oXmlNode:Find("Z_SL")) == NIL
          aadd(aerr,'��������� ���祭�� ��易⥫쭮�� �� "Z_SL"')
        endif
      else
        if (oNode1 := oXmlNode:Find("SLUCH")) == NIL
          aadd(aerr,'��������� ���祭�� ��易⥫쭮�� �� "SLUCH"')
        endif
      endif
      if oNode1 != NIL
        tmp2->_IDCASE :=   val(mo_read_xml_stroke(oNode1,"IDCASE",aerr))
        tmp2->_ID_C   := upper(mo_read_xml_stroke(oNode1,"ID_C"  ,aerr))
        tmp2->_OPLATA :=   val(mo_read_xml_stroke(oNode1,"OPLATA",aerr))
        if tmp2->_OPLATA > 1
          _ar := mo_read_xml_array(oNode1,"REFREASON")
          for j1 := 1 to len(_ar)
            select TMP3
            append blank
            tmp3->_N_ZAP := tmp2->_N_ZAP
            s := alltrim(_ar[j1])
            if len(s) > 3 .or. "." $ s
              tmp3->SREFREASON := s
            else
              tmp3->_REFREASON := val(s)
            endif
          next
        endif
      endif
  endcase
NEXT j
commit
rest_box(buf)
return NIL
