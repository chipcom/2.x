***** mo_sds.prg - ��⥣��� � �ணࠬ��� Smart Delta Systems  
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

***** 11.08.17 ��⥣��� � �ணࠬ��� Smart Delta Systems
Function integration_SDS(k)
Static sk := 1
Local mas_pmt, mas_msg, mas_fun, j, s, n_file
DEFAULT k TO 0
do case
  case k == 0
    mas_pmt := {"~��ᬮ�� XML-䠩��",;
                "~������ XML-䠩��",;
                "�����ᮢ���� ~�⤥�����"}
    mas_msg := {"��ᬮ�� ᮤ�ন���� XML-䠩�� �� Smart Delta Systems",;
                "������ XML-䠩�� �� Smart Delta Systems/ᮧ����� ���⮢ ���� � �ணࠬ�� CHIP_MO",;
                "�����ᮢ���� ����� �⤥����� � ������ �� �ணࠬ�� Smart Delta Systems"}
    mas_fun := {"integration_SDS(1)",;
                "integration_SDS(2)",;
                "integration_SDS(3)"}
    popup_prompt(T_ROW-len(mas_pmt)-3, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
  case k == 1
    Private pikol := {0,0,0}, file_error := "err_sds"+stxt
    if (n_file := f_get_file_XML_SDS()) != NIL .and. read_file_XML_SDS(n_file)
      n_message({"������ 䠩�� "+n_file,;
                 "",;
                 "�ᥣ� ����ᥩ - "+lstr(pikol[1]),;
                 "����ᥩ ��� �訡�� - "+lstr(pikol[2]),;
                 "����ᥩ � �訡���� - "+lstr(pikol[3]);
                },,"GR+/R","W+/R",,,"G+/R")
      if pikol[3] > 0
        viewtext(Devide_Into_Pages(file_error,60,80),,,,.t.,,,2)
      else
        viewtext(Devide_Into_Pages("ttt.ttt",60,80),,,,.t.,,,2)
      endif
    endif
  case k == 2
    Private pikol := {0,0,0}, file_error := "err_sds"+stxt, t1 := seconds()
    if (n_file := f_get_file_XML_SDS(@s)) != NIL .and. read_file_XML_SDS(n_file)
      if pikol[3] > 0
        viewtext(Devide_Into_Pages(file_error,60,80),,,,.t.,,,2)
      else
        write_file_XML_SDS(n_file,s)
      endif
    endif
  case k == 3
    SDS_kod_sogl_otd()
endcase
if k > 0
  sk := k
endif
return NIL

***** 30.01.18
Function read_file_XML_SDS(n_file)
Static cDelimiter := " ,"
Local _sluch := {;
   {"REC_HUMAN",   "N",     7,     0},; // � ����� ����� ����� 䠩�� human �㤥� ����ᠭ
   {"ID_SDS"    ,  "N",    15,     0},;
   {"KOD"      ,   "N",     7,     0},;
   {"N_ZAP"    ,   "C",     8,     0},; // ����� ����樨 ����� � ॥���;���� "ZAP"
   {"FIO"      ,   "C",    50,     0},;
   {"FAM"      ,   "C",    40,     0},;
   {"IM"       ,   "C",    40,     0},;
   {"OT"       ,   "C",    40,     0},;
   {"W"        ,   "N",     1,     0},;
   {"DR"       ,   "D",     8,     0},;
   {"VPOLIS"  ,    "N",     1,     0},;
   {"SPOLIS"  ,    "C",    10,     0},;
   {"NPOLIS"  ,    "C",    20,     0},;
   {"SMO",         "C",     5,     0},;
   {"SMO_OK",      "C",     5,     0},;
   {"SMO_NAM",     "C",   100,     0},; // ������������ �����த��� ���
   {"DOCTYPE",     "N",     2,     0},;
   {"DOCSER",      "C",    10,     0},;
   {"DOCNUM",      "C",    20,     0},;
   {"MR",          "C",   100,     0},;
   {"OKATOG",      "C",    11,     0},;
   {"OKATOP",      "C",    11,     0},;
   {"SNILS"    ,   "C",    11,     0},;
   {"OTD"      ,   "N",     3,     0},;
   {"OTD_SDS"  ,   "N",    10,     0},;
   {"REABIL",      "N",     3,     0},;
   {"PROFIL",      "N",     3,     0},;
   {"NHISTORY"  ,  "C",    10,     0},;
   {"DATE_1"   ,   "D",     8,     0},;
   {"DATE_2"   ,   "D",     8,     0},;
   {"DS0",         "C",     6,     0},;
   {"DS1" ,        "C",     6,     0},;
   {"DS2",         "C",     6,     0},;
   {"DS2_2",       "C",     6,     0},;
   {"DS2_3",       "C",     6,     0},;
   {"DS2_4",       "C",     6,     0},;
   {"DS2_5",       "C",     6,     0},;
   {"DS2_6",       "C",     6,     0},;
   {"DS2_7",       "C",     6,     0},;
   {"DS3",         "C",     6,     0},;
   {"DS3_2",       "C",     6,     0},;
   {"DS3_3",       "C",     6,     0},;
   {"NOVOR",       "N",     1,     0},;
   {"REB_NUMBER",  "N",     2,     0},;
   {"REB_DR",      "D",     8,     0},;
   {"REB_POL",     "N",     1,     0},;
   {"USL_OK",      "N",     2,     0},;
   {"DN_STAC",     "N",     2,     0},;
   {"NPR_MO",      "C",     6,     0},;
   {"EXTR",        "N",     1,     0},;
   {"F_SP",        "N",     1,     0},;
   {"RSLT",        "N",     3,     0},;
   {"ISHOD",       "N",     3,     0},;
   {"VRACH",       "N",     5,     0},;
   {"VRACH_SDS",   "N",     5,     0},;
   {"VR_SNILS",    "C",    11,     0},;
   {"VID_HMP",     "C",    12,     0},; // ��� ��� �� �ࠢ�筨�� V018
   {"METOD_HMP",   "N",     4,     0},; // ��⮤ ��� �� �ࠢ�筨�� V019
   {"AD_CR",       "C",    10,     0},;
   {"KSLP",        "C",    10,     0},;
   {"KIRO",        "C",    10,     0},;
   {"KSG",         "C",    10,     0},;
   {"CENA_KSG" ,   "N",    10,     2},;
   {"SUMV"     ,   "N",    10,     2};
  }
Local _sluch_p := {; // ���ࠧ������� (�⤥�����)
   {"KOD"      ,   "N",     7,     0},; // ��� �� 䠩�� _sluch
   {"OTD"      ,   "N",     3,     0},;
   {"OTD_SDS"  ,   "N",    10,     0},;
   {"DATE_1"   ,   "D",     8,     0},;
   {"DATE_2"   ,   "D",     8,     0},;
   {"PROFIL",      "N",     3,     0},;
   {"DS",          "C",     6,     0},;
   {"KOL_PD",      "N",     5,     0},; // ���-�� ��樥��-���� ��� �������� ��樮���
   {"VRACH",       "N",     5,     0},;
   {"VRACH_SDS",   "N",     5,     0},;
   {"VR_SNILS",    "C",    11,     0};
  }
Local _sluch_u := {; // ��㣨 (� �⤥�����)
   {"KOD"      ,   "N",     7,     0},; // ��� �� 䠩�� _sluch
   {"KODP"     ,   "N",     7,     0},; // ��� �� 䠩�� _sluch_p
   {"OTD"      ,   "N",     3,     0},;
   {"OTD_SDS"  ,   "N",    10,     0},;
   {"PROFIL",      "N",     3,     0},;
   {"DS",          "C",     6,     0},;
   {"CODE_USL"   , "C",    20,     0},;
   {"DATE_IN"   ,  "D",     8,     0},;
   {"DATE_OUT"  ,  "D",     8,     0},;
   {"KOL_USL"  ,   "N",     3,     0},;
   {"TARIF"   ,    "N",    10,     2},;
   {"SUMV_USL" ,   "N",    10,     2},;
   {"VRACH",       "N",     5,     0},;
   {"VRACH_SDS",   "N",     5,     0},;
   {"VR_SNILS",    "C",    11,     0};
  }
Local fl := .t., buf := save_maxrow()
//
mywait()
dbcreate(cur_dir+"_sluch",_sluch)
dbcreate(cur_dir+"_sluch_p",_sluch_p)
dbcreate(cur_dir+"_sluch_u",_sluch_u)
use (cur_dir+"_sluch") new alias IHUMAN 
index on str(kod,10) to (cur_dir+"tmp_ihum")
use (cur_dir+"_sluch_p") new alias IPODR
index on str(kod,10) to (cur_dir+"tmp_ip")
use (cur_dir+"_sluch_u") new alias IHU
index on str(kod,10) to (cur_dir+"tmp_ihu")
index on str(kodp,10) to (cur_dir+"tmp_ihup")
set index to (cur_dir+"tmp_ihu"),(cur_dir+"tmp_ihup")
set order to 2
dbcreate(cur_dir+"tmp1file", {;
  {"VERSION",   "C",  5,0},;
  {"FILENAME",  "C", 26,0},;
  {"DATA",      "D",  8,0},;
  {"TIME",      "C",  5,0},;
  {"DATE_1" ,   "D",  8,0},;
  {"DATE_2" ,   "D",  8,0},;
  {"FILENAME2", "C", 26,0},;
  {"DATA2",     "D",  8,0},;
  {"TIME2",     "C",  5,0},;
  {"KOL",       "N",  6,0};
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
// �⠥� 䠩� � ������
oXmlDoc := HXMLDoc():Read(n_file)
if Empty( oXmlDoc:aItems )
  close databases
  rest_box(buf)
  return func_error(4,"�訡�� � �⥭�� 䠩�� "+n_file)
endif
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say "��ப� "+lstr(j) color cColorWait
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION")
      tmp1->DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA"))
      tmp1->TIME    :=          mo_read_xml_stroke(oXmlNode,"TIME")
      tmp1->FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILE")
      if "-" $ tmp1->TIME
        tmp1->TIME := charrepl("-",tmp1->TIME,":") // �६� � ��� �ଠ�
      endif
    case "ZAP" == oXmlNode:title
      tmp1->kol ++
      select IHUMAN
      append blank
      ihuman->kod      := ihuman->(recno())
      ihuman->N_ZAP    :=          mo_read_xml_stroke(oXmlNode,"N_ZAP")
      ihuman->ID_SDS   :=      val(mo_read_xml_stroke(oXmlNode,"ID_SDS"))
      ihuman->VPOLIS   :=      val(mo_read_xml_stroke(oXmlNode,"VPOLIS",,.f.))
      ihuman->SPOLIS   :=          mo_read_xml_stroke(oXmlNode,"SPOLIS",,.f.)
      ihuman->NPOLIS   :=          mo_read_xml_stroke(oXmlNode,"NPOLIS",,.f.)
      ihuman->SMO      :=          mo_read_xml_stroke(oXmlNode,"SMO",,.f.)
      ihuman->SMO_OK   :=          mo_read_xml_stroke(oXmlNode,"SMO_OK",,.f.)
      ihuman->SMO_NAM  :=          mo_read_xml_stroke(oXmlNode,"SMO_NAM",,.f.)
      ihuman->FAM      :=          mo_read_xml_stroke(oXmlNode,"FAM")
      ihuman->IM       :=          mo_read_xml_stroke(oXmlNode,"IM")
      ihuman->OT       :=          mo_read_xml_stroke(oXmlNode,"OT",,.f.)
      ihuman->W        :=      val(mo_read_xml_stroke(oXmlNode,"W"))
      ihuman->DR       := xml2date(mo_read_xml_stroke(oXmlNode,"DR"))
      ihuman->MR       :=          mo_read_xml_stroke(oXmlNode,"MR",,.f.)
      ihuman->DOCTYPE  :=      val(mo_read_xml_stroke(oXmlNode,"DOCTYPE",,.f.))
      ihuman->DOCSER   :=          mo_read_xml_stroke(oXmlNode,"DOCSER",,.f.)
      ihuman->DOCNUM   :=          mo_read_xml_stroke(oXmlNode,"DOCNUM",,.f.)
      ihuman->SNILS    := charrem(" -",mo_read_xml_stroke(oXmlNode,"SNILS",,.f.))
      ihuman->OKATOG   :=          mo_read_xml_stroke(oXmlNode,"OKATOG",,.f.)
      ihuman->OKATOP   :=          mo_read_xml_stroke(oXmlNode,"OKATOP",,.f.)
      ihuman->USL_OK   :=      val(mo_read_xml_stroke(oXmlNode,"USL_OK"))
      ihuman->DN_STAC  :=      val(mo_read_xml_stroke(oXmlNode,"DN_STAC",,.f.))
      ihuman->VID_HMP  :=          mo_read_xml_stroke(oXmlNode,"VID_HMP",,.f.)
      ihuman->METOD_HMP:=      val(mo_read_xml_stroke(oXmlNode,"METOD_HMP",,.f.))
      ihuman->NPR_MO   :=          mo_read_xml_stroke(oXmlNode,"NPR_MO",,.f.)
      ihuman->REABIL   :=      val(mo_read_xml_stroke(oXmlNode,"REHABILITATION",,.f.))
      ihuman->AD_CR    :=          mo_read_xml_stroke(oXmlNode,"AD_CR",,.f.) 
      ihuman->EXTR     :=      val(mo_read_xml_stroke(oXmlNode,"EXTR",,.f.))
      ihuman->PROFIL   :=      val(mo_read_xml_stroke(oXmlNode,"PROFIL",,.f.))
      ihuman->NHISTORY :=          mo_read_xml_stroke(oXmlNode,"NHISTORY")
      ihuman->DATE_1   := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_1"))
      ihuman->DATE_2   := xml2date(mo_read_xml_stroke(oXmlNode,"DATE_2"))
      ihuman->DS0      :=          mo_read_xml_stroke(oXmlNode,"DS0",,.f.)
      ihuman->DS1      :=          mo_read_xml_stroke(oXmlNode,"DS1",,.f.)
      if ihuman->REABIL == 2 // �᫨ �� ॠ�������
        ihuman->PROFIL := 158 // � ��䨫� �� �஢�� ���� = 158 (���.ॠ�������)
      endif
      s := mo_read_xml_stroke(oXmlNode,"DS2",,.f.) ; _ar := {}
      for i := 1 to numtoken(s,cDelimiter)
        s1 := alltrim(token(s,cDelimiter,i))
        if !empty(s1)
          aadd(_ar,s1)
        endif
      next
      for j1 := 1 to min(7,len(_ar))
        pole := "ihuman->DS2"+iif(j1==1, "", "_"+lstr(j1))
        &pole := _ar[j1]
      next
      s := mo_read_xml_stroke(oXmlNode,"DS3",,.f.) ; _ar := {}
      for i := 1 to numtoken(s,cDelimiter)
        s1 := alltrim(token(s,cDelimiter,i))
        if !empty(s1)
          aadd(_ar,s1)
        endif
      next
      for j1 := 1 to min(3,len(_ar))
        pole := "ihuman->DS3"+iif(j1==1, "", "_"+lstr(j1))
        &pole := _ar[j1]
      next
      ihuman->RSLT  := val(mo_read_xml_stroke(oXmlNode,"RSLT"))
      ihuman->ISHOD := val(mo_read_xml_stroke(oXmlNode,"ISHOD"))
      if empty(ihuman->VRACH_SDS := val(mo_read_xml_stroke(oXmlNode,"VRACH",,.f.)))
        ihuman->VR_SNILS := charrem(" -",mo_read_xml_stroke(oXmlNode,"VRACH_SNILS",,.f.))
      endif
      for j1 := 1 to len(oXmlNode:aitems) // ��᫥����⥫�� ��ᬮ��
        oNode2 := oXmlNode:aItems[j1]     // �.�. ���ࠧ������� �.�. ��᪮�쪮
        if valtype(oNode2) != "C" .AND. oNode2:title == "PODR"
          select IPODR
          append blank
          ipodr->KOD       := ihuman->kod
          ipodr->OTD_SDS   :=      val(mo_read_xml_stroke(oNode2,"OTD"))
          ipodr->DATE_1    := xml2date(mo_read_xml_stroke(oNode2,"DATE_1"))
          ipodr->DATE_2    := xml2date(mo_read_xml_stroke(oNode2,"DATE_2"))
          ipodr->PROFIL    :=      val(mo_read_xml_stroke(oNode2,"PROFIL",,.f.))
          ipodr->DS        :=          mo_read_xml_stroke(oNode2,"DS",,.f.)
          ipodr->KOL_PD    :=      val(mo_read_xml_stroke(oNode2,"PATIENT_DAYS",,.f.))
          if empty(ipodr->VRACH_SDS := val(mo_read_xml_stroke(oNode2,"VRACH",,.f.)))
            ipodr->VR_SNILS := charrem(" -",mo_read_xml_stroke(oNode2,"VRACH_SNILS",,.f.))
          endif
          if empty(ipodr->DS) .and. !empty(ihuman->DS1)
            ipodr->DS := ihuman->DS1  
          endif 
          for j2 := 1 to len(oNode2:aitems) // ��᫥����⥫�� ��ᬮ��
            oNode3 := oNode2:aItems[j2]     // �.�. ��� �.�. ��᪮�쪮
            if valtype(oNode3) != "C" .AND. oNode3:title == "USL"
              select IHU
              append blank
              ihu->KODP      := ipodr->(recno())
              ihu->KOD       := ihuman->kod
              ihu->OTD_SDS   := ipodr->OTD_SDS
              ihu->PROFIL    :=      val(mo_read_xml_stroke(oNode3,"PROFIL",,.f.))
              ihu->DS        :=          mo_read_xml_stroke(oNode3,"DS",,.f.)
              ihu->DATE_IN   := xml2date(mo_read_xml_stroke(oNode3,"DATE"))
              ihu->CODE_USL  :=          mo_read_xml_stroke(oNode3,"CODE_USL")
              ihu->KOL_USL   :=      val(mo_read_xml_stroke(oNode3,"KOL_USL",,.f.))
              if empty(ihu->VRACH_SDS := val(mo_read_xml_stroke(oNode3,"VRACH",,.f.)))
                ihu->VR_SNILS := charrem(" -",mo_read_xml_stroke(oNode3,"VRACH_SNILS",,.f.))
              endif
              if empty(ihu->VRACH_SDS)
                ihu->VRACH_SDS := ipodr->VRACH_SDS
              elseif empty(ipodr->VRACH_SDS)
                ipodr->VRACH_SDS := ihu->VRACH_SDS  
              endif
              if empty(ihu->VR_SNILS)
                ihu->VR_SNILS := ipodr->VR_SNILS
              elseif empty(ipodr->VR_SNILS)
                ipodr->VR_SNILS := ihu->VR_SNILS  
              endif
              if empty(ihu->PROFIL)
                ihu->PROFIL := ipodr->PROFIL
              endif 
              if empty(ihu->DS)
                ihu->ds := ipodr->DS
              elseif empty(ipodr->DS)
                ipodr->DS := ihu->ds    
              endif 
            endif
          next j2
          if !empty(ipodr->VRACH_SDS)
            ihuman->VRACH_SDS := ipodr->VRACH_SDS
          endif
          if !empty(ipodr->VR_SNILS)
            ihuman->VR_SNILS := ipodr->VR_SNILS
          endif
          if !empty(ipodr->OTD_SDS)
            ihuman->OTD_SDS := ipodr->OTD_SDS
          endif
          if !empty(ipodr->PROFIL) .and. empty(ihuman->PROFIL)
            ihuman->PROFIL := ipodr->PROFIL
          endif
          if empty(ihuman->DS1)
            ihuman->DS1 := ipodr->DS 
          endif 
        endif
      next j1
  endcase
  if j % 500 == 0
    commit
  endif
next j
commit
//
Private pr_otd := {} // ���ᨢ ����� ᮣ��ᮢ���� �⤥�����
R_Use(dir_server+"mo_otd",,"OTD")
go top
do while !eof()
  if otd->KOD_SOGL > 0
    aadd(pr_otd, {otd->KOD_SOGL,otd->kod})
  elseif !empty(otd->SOME_SOGL)
    arr := List2Arr(otd->SOME_SOGL)
    for i := 1 to len(arr)
      aadd(pr_otd, {arr[i],otd->kod})
    next
  endif
  skip
enddo  
//
strfile(center("���᮪ �訡�� � �������㥬�� 䠩��",80)+eos,file_error)
strfile(center(n_file,80)+eos+eos,file_error,.t.)
strfile(center("��⮪�� �⥭�� 䠩��",80)+eos,"ttt.ttt")
strfile(center(n_file,80)+eos+eos,"ttt.ttt",.t.)
Private paso, pasv, pasp, pass
R_Use(dir_exe+"_okator",cur_dir+"_okatr","REGION")
R_Use(dir_exe+"_okatoo",cur_dir+"_okato","OBLAST")
R_Use(dir_exe+"_okatos",cur_dir+"_okats","SELO")
R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","MKB_10")
use_base("lusl")
use_base("luslc")
use_base("luslf")
R_Use(dir_server+"mo_pers",dir_server+"mo_pers","PERS")
index on snils to (cur_dir+"tmp_pers")
set index to (dir_server+"mo_pers"),(cur_dir+"tmp_pers")
Use_base("mo_su")
Use_base("uslugi")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
R_Use(exe_dir+"_mo_smo",{cur_dir+"_mo_smo",cur_dir+"_mo_smo2"},"SMO")
//
select IHUMAN
go top
do while !eof()
  //
  f1_read_file_XML_SDS(0)
  ae := {} ; ai := {}
  if empty(ihuman->date_1)
    ihuman->date_1 := sys_date
    aadd(ae,"����� ��� ��砫� ��祭��")
  endif
  if empty(ihuman->date_2)
    ihuman->date_2 := sys_date
    aadd(ae,"����� ��� ����砭�� ��祭��")
  endif
  if empty(ihuman->ds1)
    aadd(ae,'DS1 - �� ��������� ���� "�������� �������"')
  else
    select MKB_10
    find (padr(ihuman->ds1,6))
    if !found()
      aadd(ae, 'DS1="'+rtrim(ihuman->DS1)+'"-�᭮���� ������� �� ������ � �ࠢ�筨�� ���-10')
    elseif !between_date(mkb_10->dbegin,mkb_10->dend,ihuman->DATE_2)
      aadd(ae, 'DS1="'+rtrim(ihuman->DS1)+'"-�᭮���� ������� �� �室�� � ���')
    elseif !empty(mkb_10->pol) .and. !(mkb_10->pol == iif(ihuman->W==1,"�","�"))
      aadd(ae,'DS1="'+rtrim(ihuman->DS1)+'"-��ᮢ���⨬���� �������� �� ����')
    endif
  endif
  if empty(ihuman->VPOLIS)
    ihuman->VPOLIS := 1
  endif
  if ihuman->VPOLIS == 1
    if empty(ihuman->NPOLIS)
      ihuman->NPOLIS := charrem(" ",ihuman->SPOLIS)
      ihuman->SPOLIS := ""
    elseif !empty(ihuman->SPOLIS) .and. left(ihuman->smo,2) == '34'
      ihuman->NPOLIS := charrem(" ",ihuman->SPOLIS)+charrem(" ",ihuman->NPOLIS)
      ihuman->SPOLIS := ""
    endif
  else
    ihuman->NPOLIS := charrem(" ",ihuman->SPOLIS)+charrem(" ",ihuman->NPOLIS)
    ihuman->SPOLIS := ""
  endif
  Valid_SN_Polis(ihuman->vpolis,ihuman->SPOLIS,ihuman->NPOLIS,ae,,between(ihuman->SMO,'34001','34007'))
  if ascan(menu_vidud,{|x| x[2] == ihuman->DOCTYPE }) == 0
    if ihuman->VPOLIS < 3
      aadd(ae,'DOCTYPE-�� ��������� ���� "��� 㤮�⮢�७�� ��筮��"')
    endif
  else
    if empty(ihuman->DOCNUM)
      if ihuman->VPOLIS < 3
        aadd(ae,'DOCNUM-������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��"')
      endif
    elseif !ver_number(ihuman->DOCNUM)
      aadd(ae,'DOCNUM-���� "����� 㤮�⮢�७�� ��筮��" ������ ���� ��஢�')
    endif
    if !empty(ihuman->DOCNUM)
      s := space(80)
      if !val_ud_nom(2,ihuman->DOCTYPE,ihuman->DOCNUM,@s)
        aadd(ae,'DOCNUM-'+s)
      endif
    endif
    if eq_any(ihuman->DOCTYPE,1,3,14) .and. empty(ihuman->DOCSER)
      if !(ihuman->VPOLIS == 3 .and. empty(ihuman->DOCNUM))
        aadd(ae,'DOCSER-������ ���� ��������� ���� "����� 㤮�⮢�७�� ��筮��"')
      endif
    endif
    if !empty(ihuman->DOCSER)
      if ihuman->DOCTYPE == 14 .and. !(substr(ihuman->DOCSER,3,1) == " ")
        s := charrem(" ",ihuman->DOCSER)
        ihuman->DOCSER := left(s,2)+" "+substr(s,3) // ��ࠢ��� ��� ��ᯮ��
      endif
      s := space(80)
      if !val_ud_ser(2,ihuman->DOCTYPE,ihuman->DOCSER,@s)
        aadd(ae,'DOCSER-'+s)
      endif
    endif
  endif
  afio := {ihuman->fam,ihuman->im,ihuman->ot}
  ihuman->fio := mfio := alltrim(afio[1])+" "+alltrim(afio[2])+" "+alltrim(afio[3])
  if emptyany(ihuman->fam,ihuman->im)
    aadd(ae,'�� ��������� ��易⥫�� ���� FAM, IM')
  endif
  val_fio(afio,ae)
  if !empty(ihuman->SNILS)
    s := space(80)
    if !val_snils(ihuman->snils,2,@s)
      aadd(ai,'SNILS="'+transform(ihuman->SNILS,picture_pf)+'"-'+s)
    endif
  endif
  if empty(ihuman->NPR_MO)
    if ihuman->USL_OK == 1 .and. ihuman->EXTR == 1 // ��樮��� + �������� ��ᯨ⠫�����
      ihuman->NPR_MO := glob_mo[_MO_KOD_TFOMS]
    endif
  else
    if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == ihuman->NPR_MO })) > 0
      //
    elseif (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_FFOMS] == ihuman->NPR_MO })) > 0
      //
    endif
    if i == 0
      aadd(ai,"����୮� ���祭�� ���� NPR_MO = "+ihuman->NPR_MO)
    endif
  endif
  fl_okatosmo := .f. ; fl_nameismo := .f. ; fl_34 := .f.
  if empty(ihuman->SMO)
    aadd(ae,"�� ������ ��� ���")
  else
    select SMO
    set order to 2
    find (ihuman->SMO)
    if found()
      //
    elseif int(val(ihuman->SMO)) == 34
      fl_34 := .t.
    else
      aadd(ae,"����୮� ���祭�� ���� SMO = "+ihuman->SMO)
    endif
  endif
  if fl_34 .and. !empty(ihuman->SMO_OK)
    select SMO
    set order to 1
    find (ihuman->SMO_OK)
    if found()
      fl_okatosmo := .t.
    else
      aadd(ae,"����୮� ���祭�� ���� SMO_OK = "+ihuman->SMO_OK)
    endif
  endif
  if fl_34 .and. !empty(ihuman->SMO_NAM)
    fl_nameismo := .t.
  endif
  if fl_34
    if !fl_okatosmo
      aadd(ae,"�� ������� ����� ����ਨ ���客����")
    endif
    if !fl_nameismo
      aadd(ae,"�� ������� ������������ �����த��� ���")
    endif
  endif
  if !empty(ihuman->OKATOG) .and. !import_verify_okato(ihuman->OKATOG)
    aadd(ae,"����୮� ���祭�� ���� OKATOG = "+ihuman->OKATOG)
  endif
  if !empty(ihuman->OKATOP) .and. !import_verify_okato(ihuman->OKATOP)
    aadd(ae,"����୮� ���祭�� ���� OKATOP = "+ihuman->OKATOP)
  endif
  if ihuman->USL_OK == 1
    //
  elseif ihuman->USL_OK == 2
    if !between(ihuman->DN_STAC,1,3)
      aadd(ae,"����୮� ���祭�� ���� DN_STAC = "+lstr(ihuman->DN_STAC))
    endif
  else
    aadd(ae,"����୮� ���祭�� ���� USL_OK = "+lstr(ihuman->USL_OK))
  endif
  if !empty(ihuman->USL_OK) .and. ascan(glob_V006,{|x| x[2]==ihuman->USL_OK}) == 0
    aadd(ae,"����୮� ���祭�� ���� USL_OK = "+lstr(ihuman->USL_OK))
  endif
  if !empty(ihuman->RSLT)
    if int(val(left(lstr(ihuman->RSLT),1))) != ihuman->USL_OK 
      aadd(ae,"���� USL_OK = "+lstr(ihuman->USL_OK)+" �� ᮮ⢥����� ���祭�� ���� RSLT = "+lstr(ihuman->RSLT))
    elseif ascan(glob_V009,{|x| x[2]==ihuman->RSLT}) == 0
      aadd(ae,"����୮� ���祭�� ���� RSLT = "+lstr(ihuman->RSLT))
    endif
  endif
  if !empty(ihuman->ISHOD)
    if int(val(left(lstr(ihuman->ISHOD),1))) != ihuman->USL_OK 
      aadd(ae,"���� USL_OK = "+lstr(ihuman->USL_OK)+" �� ᮮ⢥����� ���祭�� ���� ISHOD = "+lstr(ihuman->ISHOD))
    elseif ascan(glob_V012,{|x| x[2]==ihuman->ISHOD}) == 0
      aadd(ae,"����୮� ���祭�� ���� ISHOD = "+lstr(ihuman->ISHOD))
    endif
  endif
  kol_usl := 0
  not_otd := .f.
  // ����⠭���� ���� ����� �⤥����� � ��祩
  if f1_read_file_XML_SDS(1,"ihuman",ae,ai,ihuman->profil) == 2
    not_otd := .t.
  endif
  select IPODR
  find (str(ihuman->kod,10))
  do while ihuman->kod == ipodr->kod .and. !eof()
    if empty(ipodr->date_1)
      ipodr->date_1 := sys_date
      //aadd(ae,"����� ��� ��砫� ��祭��")
    endif
    if empty(ipodr->date_2)
      ipodr->date_2 := sys_date
      //aadd(ae,"����� ��� ����砭�� ��祭��")
    endif
    if ihuman->USL_OK == 2 .and. empty(ipodr->KOL_PD)
      aadd(ae,"���⮥ ������⢮ ��樥��-���� (PATIENT_DAYS)")
    endif
    if f1_read_file_XML_SDS(2,"ipodr",ae,ai,ipodr->profil) == 2
      not_otd := .t.
    endif
    select IHU
    set order to 2 
    find (str(ipodr->(recno()),10))
    do while ihu->kodp == ipodr->(recno()) .and. !eof()
      select LUSLF
      find (padr(ihu->CODE_USL,20))
      if !found()
        select LUSL
        find (padr(ihu->CODE_USL,10))
        if !found()
          aadd(ae,"� �ࠢ�筨��� ����� �� ������� ��㣠 "+alltrim(ihu->CODE_USL))
        endif
      endif
      if !between(ihu->DATE_IN,ihuman->date_1,ihuman->date_2)
        aadd(ae,"��� ��㣨 "+alltrim(ihu->CODE_USL)+" ("+date_8(ihu->DATE_IN)+") �� �������� � �������� ��祭��: "+;
                date_8(ihuman->date_1)+"-"+date_8(ihuman->date_2))
      endif
      ++kol_usl
      if f1_read_file_XML_SDS(3,"ihu",ae,ai,ihu->profil) == 2
        not_otd := .t.
      endif
      select IHU
      skip
    enddo
    select IPODR
    skip
  enddo
  // ���������� ��� 1.11.* � 55.1.*
  if eq_any(ihuman->USL_OK,1,2) // ��樮��� � ������� ��樮���  
    select IPODR
    find (str(ihuman->kod,10))
    do while ihuman->kod == ipodr->kod .and. !eof()
      otd->(dbGoto(ipodr->otd))
      if ipodr->DATE_1 == ipodr->DATE_2 .and. ihuman->DATE_2 > ihuman->DATE_1
        aadd(ai,'��� ��砫� � ����砭�� ��祭�� � �⤥����� "'+rtrim(otd->short_name)+;
                '" - ���� � �� �� ���� '+date_8(ipodr->DATE_1))
      else
        if !between(ipodr->DATE_1,ihuman->DATE_1,ihuman->DATE_2)
          aadd(ae,'��� ��砫� ��祭�� � �⤥����� "'+rtrim(otd->short_name)+;
                  '" - '+date_8(ipodr->DATE_1)+' �� �।����� �ப�� ��祭��')
        endif
        if !between(ipodr->DATE_2,ihuman->DATE_1,ihuman->DATE_2)
          aadd(ae,'��� ����砭�� ��祭�� � �⤥����� "'+rtrim(otd->short_name)+;
                  '" - '+date_8(ipodr->DATE_2)+' �� �।����� �ப�� ��祭��')
        endif
        select IHU
        append blank 
        ihu->KOD := ihuman->kod
        ihu->KODP := ipodr->(recno()) 
        ihu->PROFIL := ipodr->PROFIL
        ihu->otd := ipodr->otd
        ihu->otd_sds := ipodr->otd_sds
        ihu->DS := ipodr->DS
        if ihuman->USL_OK == 1 // ��樮���  
          if ihuman->REABIL == 2
            ihu->CODE_USL := "1.11.2"
          else
            ihu->CODE_USL := "1.11.1"
          endif
          ihu->KOL_USL := ipodr->DATE_2 - ipodr->DATE_1
          if empty(ihu->KOL_USL) .and. ihuman->DATE_1 == ihuman->DATE_2
            ihu->KOL_USL := 1 // �믨ᠭ � �� �� ����, �� � ����㯨�
          endif
        else
          if ihuman->REABIL == 2
            ihu->CODE_USL := "55.1.4"
          else
            ihu->CODE_USL := "55.1."+lstr(ihuman->DN_STAC)
          endif
          ihu->KOL_USL := ipodr->KOL_PD
        endif 
        ihu->DATE_IN := ipodr->DATE_1
        ihu->DATE_OUT := ipodr->DATE_2
        ihu->TARIF := ihu->SUMV_USL := 0
        ihu->VRACH := ipodr->VRACH
        ihu->VRACH_SDS := ipodr->VRACH_SDS
        ihu->VR_SNILS := ipodr->VR_SNILS
      endif
      select IPODR
      skip
    enddo
    if !empty(ihuman->VID_HMP) .and. ihuman->USL_OK == 1 // ��樮���  
      make_V018_V019(ihuman->date_2)
      if ascan(glob_V018, {|x| x[1] == ihuman->VID_HMP }) == 0
        aadd(ae,'�� ������ ��� ��� "'+rtrim(ihuman->VID_HMP)+'" � �ࠢ�筨�� V018')
      elseif empty(ihuman->METOD_HMP)
        aadd(ae,'��� �������, ����� ��� ���, �� �� ����� ��⮤ ���')
      elseif (i := ascan(glob_V019, {|x| x[1] == ihuman->METOD_HMP })) > 0
        if glob_V019[i,4] == ihuman->VID_HMP
          if ascan(glob_V019[i,3], {|x| left(ihuman->ds1,len(x))==x }) == 0
            aadd(ae,'�᭮���� ������� �� ᮮ⢥����� ��⮤� ���')
          endif
        else
          aadd(ae,'��⮤ ��� '+lstr(ihuman->METOD_HMP)+' �� ᮮ⢥����� ���� ��� '+ihuman->VID_HMP)
        endif
      else
        aadd(ae,'�� ������ ��⮤ ��� '+lstr(ihuman->METOD_HMP)+' � �ࠢ�筨�� V019')
      endif
    endif
  endif
  if empty(ihuman->PROFIL)
    aadd(ae,'�� 㪠��� ��䨫�')
  endif
  mdate_r := ihuman->dr ; m1VZROS_REB := 0 ; M1NOVOR := ihuman->novor
  mDATE_R2 := ctod("")
  fv_date_r(ihuman->DATE_1)
  if eq_any(ihuman->USL_OK,1,2) // ��樮��� � ������� ��樮���  
    if emptyall(ihuman->ds1,kol_usl)
      aadd(ae,'���������� ��।����� ��� - ��� �᭮����� �������� � �� ����� ��㣨')
    else
      select IHU
      set order to 1
      arr_ksg := definition_KSG(2)
      if len(arr_ksg) == 7 // ������
        //
      elseif empty(arr_ksg[2]) // �᫨ ��� �訡��
        select IHU
        append blank 
        ihu->KOD := ihuman->kod
        ihu->PROFIL := ihuman->PROFIL
        ihu->DS := ihuman->DS1
        ihu->otd := ihuman->otd
        ihu->otd_sds := ihuman->otd_sds
        ihu->CODE_USL := arr_ksg[3]
        ihu->DATE_IN := ihuman->DATE_1
        ihu->KOL_USL := 1
        ihuman->sumv := ihu->TARIF := ihu->SUMV_USL := arr_ksg[4]
        ihu->VRACH := ihuman->VRACH
        ihu->VRACH_SDS := ihuman->VRACH_SDS
        ihu->VR_SNILS := ihuman->VR_SNILS
        if len(arr_ksg) > 4 .and. !empty(arr_ksg[5])
          ihuman->kslp := lstr(arr_ksg[5,1])+","+lstr(arr_ksg[5,2],5,2)
        endif
        if len(arr_ksg) > 5 .and. !empty(arr_ksg[6])
          ihuman->kiro := lstr(arr_ksg[6,1])+","+lstr(arr_ksg[6,2],5,2)
        endif
        //aeval(arr_ksg[1],{|x| aadd(ai,x) })
        if empty(ihuman->VID_HMP)
          aadd(ai,'��।����� ��� "'+arr_ksg[3]+'" � 業�� '+lstr(arr_ksg[4],11,2)+'�.')
        else
          aadd(ai,'��।����� ��㣠 ��� "'+arr_ksg[3]+'" � 業�� '+lstr(arr_ksg[4],11,2)+'�.')
        endif
      else
        aeval(arr_ksg[2],{|x| aadd(ae,x) })
      endif
    endif
  endif
  //
  pikol[1] ++
  if glob_mo[_MO_KOD_TFOMS] == '131940' .and. not_otd
    // � ���� ��� ����, ���⮬� �� ������㥬 �訡�� ������⢨� ���� �⤥����� � ᮣ��ᮢ����
  else
    otd->(dbGoto(ihuman->otd))    
    my_debug(,alltrim(ihuman->n_zap)+". "+alltrim(mfio)+" �.�."+full_date(ihuman->dr))
    my_debug(,"   "+date_8(ihuman->date_1)+"-"+date_8(ihuman->date_2)+" "+otd->name)
    if len(ae) > 0
      strfile(alltrim(ihuman->n_zap)+". "+alltrim(mfio)+" �.�."+full_date(ihuman->dr)+eos,file_error,.t.)
      strfile("   "+date_8(ihuman->date_1)+"-"+date_8(ihuman->date_2)+" "+otd->name+eos,file_error,.t.)
      for i := 1 to len(ae)
        my_debug(,"   -error: "+ltrim(ae[i]))
          strfile("   -error: "+ltrim(ae[i])+eos,file_error,.t.)
      next
      pikol[3] ++
    else
      pikol[2] ++
    endif
    for i := 1 to len(ai)
      my_debug(,"   -info: "+ai[i])
    next
  endif
  select IHUMAN
  skip
enddo
close databases
rest_box(buf)
return fl

***** 15.08.17
Function f1_read_file_XML_SDS(k,lal,aerr,ainf,lprofil)
Local i, s, lk, ret := 0
if k == 0
  paso := {} ; pasv := {} ; pasp := {} ; pass := {}
  return ret
endif
if !empty(k := &lal.->PROFIL)
  if ascan(glob_V002,{|x| x[2]==k}) == 0
    if ascan(pasp,k) == 0
      aadd(pasp,k) 
      aadd(aerr,"������� ����୮� ���祭�� ���� PROFIL = "+lstr(k))
    endif
    ret := 1
  endif
endif
if !empty(k := &lal.->otd_sds)
  if (i := ascan(pr_otd, {|x| x[1] == k })) > 0
    &lal.->otd := pr_otd[i,2]
  else
    if ascan(paso,k) == 0
      aadd(paso,k)
      aadd(aerr,"� �ࠢ�筨�� �⤥����� �� ᮣ��ᮢ��� �⤥����� � ����� "+lstr(k))
    endif
    ret := 2
  endif
endif
if !empty(k := &lal.->vrach_sds)
  select PERS
  set order to 1
  find (str(k,5))
  if found()
    &lal.->vrach := pers->kod
  else
    if ascan(pasv,k) == 0
      aadd(pasv,k)
      aadd(aerr,"� �ࠢ�筨�� ���ᮭ��� �� �����㦥� ���㤭�� � ⠡���� ����஬ "+lstr(k))
    endif
    if empty(ret)
      ret := 3
    endif
  endif
elseif !empty(k := &lal.->vr_snils)
  DEFAULT lprofil TO 0
  lk := 0
  select PERS
  set order to 2
  find (padr(k,11))
  do while k == pers->snils .and. !eof()
    if empty(lk)
      lk := pers->kod // ���� �������� ����������
    endif
    if fieldpos("profil") > 0 .and. lprofil == pers->profil // ᮣ��ᮢ�� ��䨫�
      lk := pers->kod
      exit
    endif
    skip
  enddo
  if lk > 0
    &lal.->vrach := lk 
  else
    if ascan(pass,k) == 0
      aadd(pass,k)
      s := space(80)
      if !val_snils(k,2,@s)
        aadd(aerr,'VRACH_SNILS="'+transform(k,picture_pf)+'"-'+s)
      endif
      aadd(aerr,"� �ࠢ�筨�� ���ᮭ��� �� �����㦥� ���㤭�� � ����� "+transform(k,picture_pf))
    endif
    if empty(ret)
      ret := 3
    endif
  endif
endif
return ret

***** 19.10.17
Function write_file_XML_SDS(n_file,path2_sds)
Local i, fl := .f.
Local name_file := StripPath(n_file)  // ��� 䠩�� ��� ���
Private cFileProtokol := "protokol"+stxt
delete file (cur_dir+cFileProtokol)
G_SPlus(f_name_task(X_OMS)) // ���� 1 ���짮��⥫� ���� � ������ ���
if G_SIsLock(sem_vagno_task[X_OMS])
  f_err_sem_vagno_task(X_OMS)
else
  fl := f1_write_file_XML_SDS(n_file)
endif
G_SMinus(f_name_task(X_OMS))  // ����� 1 ���짮��⥫� (��襫 �� ����� ���)
if hb_FileExists(cur_dir+cFileProtokol)
  viewtext(Devide_Into_Pages(cur_dir+cFileProtokol,60,80),,,,.t.,,,2)
endif
if fl
  for i := 1 to 3
    copy file (n_file) to (path2_sds+name_file)
    if hb_FileExists(path2_sds+name_file)
      delete file (n_file)
      exit
    endif
  next i
endif    
return NIL

***** 30.01.18
Function f1_write_file_XML_SDS(n_file)
Local buf := save_maxrow(), aerr := {}, arr, fl, i, j, t2, s, s1, afio[3]
mywait("������ 䠩�� ...")
strfile(center("��⮪�� ������ 䠩��",80)+eos,"ttt.ttt")
strfile(center(n_file,80)+eos+eos,"ttt.ttt",.t.)
glob_podr := "" ; glob_otd_dep := 0
Private is := 0, is1 := 0, iz := 0, isp1 := 0, isp2 := 0
use_base("lusl")
use_base("luslc")
use_base("luslf")
Use_base("mo_su")
Use_base("uslugi")
R_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
Use_base("mo_hu")
R_Use(dir_server+"mo_otd",,"OTD")
Use_base("human_u")
Use_base("human")
set relation to
select HUMAN_2
index on str(pn3,10) to (cur_dir+"tmp_human2")
G_Use(dir_server+"mo_kfio",,"KFIO")
index on str(kod,7) to (cur_dir+"tmp_kfio")
G_Use(dir_server+"mo_kismo",,"KSN")
index on str(kod,7) to (cur_dir+"tmpkismo")
G_Use(dir_server+"mo_hismo",,"HSN")
index on str(kod,7) to (cur_dir+"tmphismo")
Use_base("kartotek")
use (cur_dir+"_sluch_p") index (cur_dir+"tmp_ip") new alias IPODR
use (cur_dir+"_sluch_u") index (cur_dir+"tmp_ihu"),(cur_dir+"tmp_ihup") new alias IHU
use (cur_dir+"_sluch") new alias IHUMAN
go top
do while !eof()
  ++is
  if ihuman->otd > 0 // ᮣ��ᮢ�� ��� �⤥����� - ����� ����㦠��
    ++is1 ; fl := .t.
    afio[1] := ihuman->fam
    afio[2] := ihuman->im
    afio[3] := ihuman->ot
    mfio := alltrim(afio[1])+" "+alltrim(afio[2])+" "+alltrim(afio[3])
    if ihuman->id_sds > 0
      select HUMAN_2
      set order to 1
      find (str(ihuman->id_sds,10))
      if found() 
        ++isp1 ; fl := .f. // �.�. ����� ��砩 ����ᨫ� �१ ������ �㭪��
        s1 := "����� �������"
      endif
    endif
    if fl
      lkod_k := 0 ; mfio := padr(mfio,50)
      select KART
      set order to 2
      find ("1"+upper(mfio)+dtos(ihuman->dr))
      if found()
        lkod_k := kart->kod
        select HUMAN
        set order to 2
        find (str(lkod_k,7))
        do while lkod_k == human->kod_k .and. !eof()
          if human->k_data == ihuman->DATE_2 .and. human_->USL_OK == ihuman->USL_OK ;
                                             .and. human_->PROFIL == ihuman->PROFIL
            ++isp2 ; fl := .f. // �.�. ����� ��砩 ����ᨫ� ��窠��
            s1 := "����� �������� ����������"
            exit
          endif
          skip
        enddo
      endif  
    endif   
    if fl
      ++iz
      select KART
      set order to 1
      if empty(lkod_k)
        Add1Rec(7)
        lkod_k := kart->kod := recno()
        kart->FIO    := mfio
        kart->DATE_R := ihuman->dr
      else
        goto (lkod_k)
        G_RLock(forever)
      endif
      mdate_r := kart->DATE_R ; m1VZROS_REB := M1NOVOR := 0
      fv_date_r()
      kart->pol       := iif(ihuman->W==1, "�","�")
      kart->VZROS_REB := m1VZROS_REB
      kart->POLIS     := make_polis(ihuman->spolis,ihuman->npolis)
      kart->snils     := ihuman->snils
      if TwoWordFamImOt(afio[1]) .or. TwoWordFamImOt(afio[2]) .or. TwoWordFamImOt(afio[3])
        kart->MEST_INOG := 9
      else
        kart->MEST_INOG := 0
      endif
      select KART2
      do while kart2->(lastrec()) < lkod_k
        APPEND BLANK
      enddo
      goto (lkod_k)
      G_RLock(forever)
      //
      select KART_
      do while kart_->(lastrec()) < lkod_k
        APPEND BLANK
      enddo
      goto (lkod_k)
      G_RLock(forever)
      //
      kart_->VPOLIS := ihuman->vpolis
      kart_->SPOLIS := ihuman->SPOLIS
      kart_->NPOLIS := ihuman->NPOLIS
      kart_->SMO    := ihuman->smo
      kart_->vid_ud := ihuman->DOCTYPE
      kart_->ser_ud := ihuman->DOCSER
      kart_->nom_ud := ihuman->DOCNUM
      kart_->mesto_r:= ihuman->MR
      kart_->okatog := ihuman->OKATOG
      kart_->okatop := ihuman->OKATOP
      //
      select KFIO
      find (str(lkod_k,7))
      if found()
        if kart->MEST_INOG == 9
          G_RLock(forever)
          kfio->FAM := afio[1]
          kfio->IM  := afio[2]
          kfio->OT  := afio[3]
        else
          DeleteRec(.t.)
        endif
      else
        if kart->MEST_INOG == 9
          AddRec(7)
          kfio->kod := lkod_k
          kfio->FAM := afio[1]
          kfio->IM  := afio[2]
          kfio->OT  := afio[3]
        endif
      endif
      fl_nameismo := .f.
      if int(val(ihuman->SMO)) == 34
        fl_nameismo := .t.
        kart_->KVARTAL_D := ihuman->SMO_OK // ����� ��ꥪ� �� ����ਨ ���客����
      endif
      select KSN
      find (str(lkod_k,7))
      if found()
        if fl_nameismo
          G_RLock(forever)
          ksn->smo_name := ihuman->SMO_NAM
        else
          DeleteRec(.t.)
        endif
      else
        if fl_nameismo
          AddRec(7)
          ksn->kod := lkod_k
          ksn->smo_name := ihuman->SMO_NAM
        endif
      endif
      UnLock
      //
      M1NOVOR := ihuman->NOVOR ; mDATE_R2 := ihuman->REB_DR
      fv_date_r(ihuman->DATE_1)
      select HUMAN
      set order to 1
      Add1Rec(7)
      mkod := human->kod := recno()
      select HUMAN_
      do while human_->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      select HUMAN_2
      do while human_2->(lastrec()) < mkod
        APPEND BLANK
      enddo
      goto (mkod)
      G_RLock(forever)
      //
      human->kod_k      := lkod_k
      human->TIP_H      := B_STANDART
      human->FIO        := kart->FIO          // �.�.�. ���쭮��
      human->POL        := kart->POL          // ���
      human->DATE_R     := kart->DATE_R       // ��� ஦����� ���쭮��
      human->VZROS_REB  := M1VZROS_REB   // 0-�����, 1-ॡ����, 2-�����⮪
      human->KOD_DIAG   := ihuman->ds1
      for i := 1 to 7
        pole := "ihuman->ds2"+iif(i==1,"","_"+lstr(i))
        if !empty(&pole)
          poleh := {"KOD_DIAG2","KOD_DIAG3","KOD_DIAG4","SOPUT_B1","SOPUT_B2","SOPUT_B3","SOPUT_B4"}[i]
          poleh := "human->"+poleh
          &poleh := &pole
        endif
      next
      human->KOMU       := 0
      human_->SMO       := ihuman->smo
      human->POLIS      := make_polis(ihuman->spolis,ihuman->npolis)
      human->OTD        := ihuman->otd
      otd->(dbGoto(ihuman->otd))
      human->LPU        := otd->kod_lpu
      human->UCH_DOC    := ihuman->NHISTORY
      human->N_DATA     := ihuman->DATE_1
      human->K_DATA     := ihuman->DATE_2
      human->CENA := human->CENA_1 := ihuman->SUMV
      human_->VPOLIS    := ihuman->vpolis
      human_->SPOLIS    := ihuman->SPOLIS
      human_->NPOLIS    := ihuman->NPOLIS
      human_->OKATO     := ""
      if ihuman->novor == 0
        human_->NOVOR   := 0
        human_->DATE_R2 := ctod("")
        human_->POL2    := ""
      else
        human_->NOVOR   := ihuman->REB_NUMBER
        human_->DATE_R2 := ihuman->REB_DR
        human_->POL2    := iif(ihuman->REB_POL==1, "�","�")
      endif
      human_->USL_OK    := ihuman->USL_OK
      human_->VIDPOM    := 1//ihuman->VIDPOM
      human_->PROFIL    := ihuman->PROFIL
      human_->NPR_MO    := ihuman->NPR_MO
      if ihuman->USL_OK == 1
        v := iif(between(ihuman->EXTR,1,2), ihuman->EXTR, 1)
        human_->FORMA14 := str(v-1,1)+"000"
      elseif ihuman->USL_OK == 4
        v := iif(between(ihuman->F_SP,1,2), ihuman->F_SP, 1)
        human_->FORMA14 := str(v-1,1)+"000"
      endif
      human_->KOD_DIAG0 := ihuman->ds0
      human_->RSLT_NEW  := ihuman->rslt
      human_->ISHOD_NEW := ihuman->ishod
      human_->VRACH     := ihuman->vrach
      human_->OPLATA    := 0
      human_->ST_VERIFY := 0 // ��� �� �஢�७
      human_->ID_PAC    := mo_guid(1,human_->(recno()))
      human_->ID_C      := mo_guid(2,human_->(recno()))
      human_->SUMP      := 0
      human_->OPLATA    := 0
      human_->SANK_MEK  := 0
      human_->SANK_MEE  := 0
      human_->SANK_EKMP := 0
      human_->REESTR    := 0
      human_->REES_ZAP  := 0
      human->schet      := 0
      human_->SCHET_ZAP := 0
      human->kod_p   := chr(0)
      human->date_e  := ''
      if fl_nameismo
        human_->OKATO := ihuman->SMO_OK // ����� ��ꥪ� �� ����ਨ ���客����
      endif
      for i := 1 to 3
        pole := "ihuman->ds3"+iif(i==1,"","_"+lstr(i))
        if !empty(&pole)
          poleh := "human_2->osl"+lstr(i)
          &poleh := &pole
        endif
      next
      put_0_human_2()
      if !empty(ihuman->VID_HMP)
        human_2->VMP := 1
        human_2->VIDVMP := ihuman->VID_HMP
        human_2->METVMP := ihuman->METOD_HMP
      endif
      if eq_any(human_->usl_ok,1,2) .and. human_->profil == 158 // ॠ������� � ��樮��� � ������� ��樮���
        human_2->PN1 := 1 // ��� ������ ��⥬� ��嫥�୮� �������樨 � ��樥��
      endif 
      human_2->pc1 := ihuman->kslp
      human_2->pc2 := ihuman->kiro
      human_2->pc3 := ihuman->AD_CR 
      human_2->PN3 := ihuman->id_sds // ���祢�� ���� !!!
      select HSN
      find (str(mkod,7))
      if found()
        if fl_nameismo
          G_RLock(forever)
          hsn->smo_name := ihuman->SMO_NAM
        else
          DeleteRec(.t.)
        endif
      else
        if fl_nameismo
          AddRec(7)
          hsn->kod := mkod
          hsn->smo_name := ihuman->SMO_NAM
        endif
      endif
      ihuman->REC_HUMAN := mkod
      UnLock
      select IHU
      find (str(ihuman->kod,10))
      do while ihu->kod == ihuman->kod .and. !eof()
        kod_usl := kod_uslf := 0
        if len(alltrim(ihu->CODE_USL)) > 9
          select MOSU
          set order to 3 // �� ���� �����
          find (padr(ihu->CODE_USL,20))
          if found()
            kod_uslf := mosu->kod
          else
            select LUSLF
            find (padr(ihu->CODE_USL,20))
            if found()
              select MOSU
              set order to 1
              FIND (STR(-1,6))
              if found()
                G_RLock(forever)
              else
                AddRec(6)
              endif
              kod_uslf := mosu->kod := recno()
              mosu->name := luslf->name
              mosu->shifr1 := ihu->CODE_USL
              mosu->PROFIL := ihu->PROFIL
              UnLock
            endif
          endif
          if !empty(kod_uslf)
            select MOHU
            Add1Rec(7)
            mohu->kod     := human->kod
            mohu->kod_vr  := ihu->vrach
            //mohu->kod_as  := lassis
            mohu->u_kod   := kod_uslf
            mohu->u_cena  := 0//ihu->tarif
            mohu->date_u  := dtoc4(ihu->DATE_IN)
            mohu->date_u2 := dtoc4(ihu->DATE_OUT)
            mohu->otd     := ihu->otd
            mohu->kol_1   := ihu->KOL_USL
            mohu->stoim_1 := 0//ihu->SUMV_USL
            mohu->ID_U    := mo_guid(4,mohu->(recno()))
            mohu->PROFIL  := ihu->PROFIL
            //mohu->PRVS    := ihu->PRVS
            mohu->kod_diag := ihu->ds
            UNLOCK
          endif
        endif
        if empty(kod_uslf)
          select USL
          set order to 2
          find (padr(ihu->CODE_USL,10))
          if found()
            kod_usl := usl->kod
          else
            v1 := v2 := 0 ; mname := ""
            select LUSL
            find (padr(ihu->CODE_USL,10))
            if found()
              mname := lusl->name
              v1 := fcena_oms(lusl->shifr,.t.,sys_date)
              v2 := fcena_oms(lusl->shifr,.f.,sys_date)
            endif
            select USL
            set order to 1
            FIND (STR(-1,4))
            if found()
              G_RLock(forever)
            else
              AddRec(4)
            endif
            kod_usl := usl->kod := recno()
            usl->name := mname
            usl->shifr := ihu->CODE_USL
            usl->PROFIL := ihu->PROFIL
            usl->cena   := v1
            usl->cena_d := v2
            UnLock
          endif
          //
          select HU
          Add1Rec(7)
          hu->kod     := human->kod
          hu->kod_vr  := ihu->vrach
          //hu->kod_as  := lassis
          hu->u_koef  := 1
          hu->u_kod   := kod_usl
          /*if ihu->(fieldpos("dom")) > 0 ;
                          .and. ihu->(fieldtype("dom")) == "N" ;
                          .and. eq_any(ihu->dom,1,2)
            hu->KOL_RCP := -ihu->dom
          endif*/
          hu->u_cena  := ihu->tarif
          hu->is_edit := 0
          hu->date_u  := dtoc4(ihu->DATE_IN)
          hu->otd     := ihu->otd
          hu->kol := hu->kol_1 := ihu->KOL_USL
          hu->stoim := hu->stoim_1 := ihu->SUMV_USL
          select HU_
          do while hu_->(lastrec()) < hu->(recno())
            APPEND BLANK
          enddo
          goto (hu->(recno()))
          G_RLock(forever)
          hu_->date_u2 := dtoc4(ihu->DATE_OUT)
          hu_->ID_U := mo_guid(3,hu_->(recno()))
          hu_->PROFIL := ihu->PROFIL
          //hu_->PRVS   := ihu->PRVS
          hu_->kod_diag := ihu->ds
          UNLOCK
        endif
        select IHU
        skip
      enddo
      s1 := "��������"
      //
      @ maxrow(),0 say "��砥� "+lstr(is1) color "G+/R" 
      @ row(),col() say "/" color "W/R"
      @ row(),col() say "����㦥�� "+lstr(iz) color cColorSt2Msg
      if iz % 100 == 0
        dbUnlockAll()
        dbCommitAll()
      endif
    endif
    otd->(dbGoto(ihuman->otd))    
    my_debug(,alltrim(ihuman->n_zap)+". "+alltrim(mfio)+" �.�."+full_date(ihuman->dr))
    my_debug(,"   "+date_8(ihuman->date_1)+"-"+date_8(ihuman->date_2)+" "+otd->name+"  "+s1)
  endif
  select IHUMAN
  skip
enddo   
close databases
rest_box(buf)
t2 := seconds() - t1
arr := {'���� "'+alltrim(n_file)+'" ������஢��.',;
        "�६� ࠡ��� - "+sectotime(t2)+"."}
aadd(arr, "������⢮ ��砥� � 䠩�� "+lstr(is)+iif(is==is1, "", ", ��砥� ��� ����㧪� "+lstr(is1)))
s := ""
if isp1 > 0
  s := "࠭�� ����㦥�� ��砥� "+lstr(isp1)
endif
if isp2 > 0
  s += iif(empty(s), "", ", ")+"࠭�� ��������� ��砥� "+lstr(isp2)
endif
if !empty(s)
  aadd(arr, "("+s+")")
endif
aadd(arr, "����㦥�� ��砥� "+lstr(iz))
n_message(arr,,"GR+/R","W+/R",,,"G+/R")
//
viewtext(Devide_Into_Pages("ttt.ttt",60,80),,,,.t.,,,2)
return .t.

***** 10.08.17
Function f_get_file_XML_SDS(/*@*/path2_sds)
Static ini_file := "_manager", ini_group := "Read_Write"
Local path1_sds, name_zip, ar
if !is_obmen_sds()
  return NIL
endif
if tip_polzovat != 0
  func_error(4,err_admin)
  return NIL
endif
ar := GetIniSect(tmp_ini,"RAB_MESTO")
path1_sds := alltrim(a2default(ar,"path1_sds"))
path2_sds := alltrim(a2default(ar,"path2_sds"))
if empty(path1_sds)
  func_error(4,"�� ����஥� ��⠫�� ��� 䠩��� ������ � �ணࠬ��� Smart Delta Systems!")
  return NIL
else
  if empty(path2_sds)
    path1_sds := NIL
    func_error(4,"�� ����஥� ��⠫�� ��� ��ࠡ�⠭��� 䠩��� Smart Delta Systems!")
    return NIL
  endif
  if right(path1_sds,1) != cslash
    path1_sds += cslash
  endif
  if right(path2_sds,1) != cslash
    path2_sds += cslash
  endif
  if upper(path1_sds) == upper(path2_sds)
    path1_sds := NIL
    func_error(4,"��� ࠧ� ��࠭ �� �� ��⠫�� ��� 䠩��� Smart Delta Systems. �������⨬�!")
    return NIL
  endif
  Private p_var_manager := "Read_From_SDS"
  SetIniVar(ini_file, {{ini_group,p_var_manager,path1_sds}})
  name_zip := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,1,,,,"*.xml")
endif
return iif(empty(name_zip), NIL, name_zip)

*

***** 25.03.16 �����ᮢ���� ����� �⤥����� � ������ �� �ணࠬ�� Smart Delta Systems 
Function SDS_kod_sogl_otd()
Private t_arr := array(BR_LEN), s_msg, bc, n, c_plus, buf := save_maxrow()
mywait()
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79  
t_arr[BR_COLOR] := color0
t_arr[BR_TITUL] := "������஢���� ����� ᮣ��ᮢ���� �⤥����� �� �ணࠬ�� SDS"
t_arr[BR_TITUL_COLOR] := "BG+/GR"
t_arr[BR_ARR_BROWSE] := {"�","�","�","N/BG,W+/N,B/BG,BG+/B",.t.}
#ifdef NET
  t_arr[BR_SEMAPHORE] := t_arr[BR_TITUL] 
#endif
bc := {|| iif(emptyall(otd->kod_sogl,otd->some_sogl), {3,4}, {1,2}) }
t_arr[BR_COLUMN] := {;
  {" ������������ ��०�����", {|| uch->name },bc},;
  {" ������������ �⤥�����",  {|| otd->name },bc},;
  {"��� ᮣ��ᮢ����", {|| padr(iif(empty(otd->kod_sogl),otd->some_sogl,put_val(otd->kod_sogl,10)),16) },bc};
}
s_msg := "^<Esc>^ - ��室;  ^<Enter>^ - ।���஢���� ���� ᮣ��ᮢ����"
t_arr[BR_STAT_MSG] := {|| status_key(s_msg) }
t_arr[BR_EDIT] := {|nk,ob| f1SDS_kod_sogl_otd(nk,ob,'edit') }
R_Use(dir_server+"mo_uch",,"UCH")
G_Use(dir_server+"mo_otd",,"OTD")
set relation to kod_lpu into UCH
index on upper(uch->name)+str(kod_lpu,3)+upper(name)+str(kod,3) to (cur_dir+"tmp_otd")
rest_box(buf)
go top
if !eof()
  edit_browse(t_arr)
endif  
close databases
return NIL
  
***** 05.06.17
Function f1SDS_kod_sogl_otd(nKey,oBrow,cregim)
Local ret := -1, i, s := "", buf, tmp_color := setcolor()
do case
  case cregim == "edit"
    do case
      case nKey == K_ENTER
        Private mkod_sogl := otd->kod_sogl, msome_sogl := otd->some_sogl, gl_area := {1,0,23,79,0}
        buf := box_shadow(15,0,20,77,color8)
        tmp_color := setcolor(cDataCGet)
        @ 16,2 say "������������ ��०�����" get uch->name when .f.
        @ 17,2 say "������������ �⤥�����" get otd->name when .f.
        @ 18,2 say "��� ᮣ��ᮢ����/���� � ������" get mkod_sogl when empty(msome_sogl)
        @ 19,2 say "��� ᮣ��ᮢ����/���� �� ������/�१ �������" get msome_sogl pict "@S29" ;
               when empty(mkod_sogl)
        myread()
        if lastkey() != K_ESC
          for i := 1 to len(msome_sogl)
            if substr(msome_sogl,i,1) $ ",0123456789"
              s += substr(msome_sogl,i,1)
            endif
          next
          G_RLock(forever)
          replace kod_sogl with mkod_sogl, some_sogl with s
          Commit
          UnLock
          oBrow:down()
          ret := 0
        endif
        setcolor(tmp_color)
        rest_box(buf)
      otherwise
        keyboard ""
    endcase
endcase
return ret
  
*

***** ����� ���ଠ樥� � �ணࠬ��� Smart Delta Systems
Function is_obmen_sds()
return .t.//substr(glob_mo[_MO_PROD],X_RISZ,1) == '1'

***** 21.09.16 �-�� ��� ������ ���ଠ樥� � �ணࠬ��� Smart Delta Systems
Function import_kart_from_sds()
Static struct_sds := {;
   {"PCODE",      "N",     18,      0},; //      ID
   {"PAT_TYPE",   "C",    128,      0},; //      �㪢�
   {"CARDNUM",    "C",     48,      0},; //      ����� ���⪠/����� � ���⪥
   {"UCHST_KOD",  "C",     24,      0},; //      ����� ���⪠
   {"LASTNAME",   "C",     32,      0},; //      䠬����
   {"FIRSTNAME",  "C",     32,      0},; //      ���
   {"MIDNAME",    "C",     32,      0},; //      ����⢮
   {"POL",        "N",      4,      0},; // N1   ���
   {"BDATE",      "D",      8,      0},; //      ��� ஦�����
   {"SNILS",      "C",     24,      0},; // C11  �����
   {"PASPTYPE",   "N",     18,      0},; // N2   ��� ���-�, �-�� ��筮��� (1-18)
   {"PASPSER",    "C",     12,      0},; //      ��� ���㬥��
   {"PASPNUM",    "C",     12,      0},; //      ����� ���㬥��
   {"BIRTHPLACE", "C",    255,      0},; // C100 ���� ஦�����
   {"PASPPLACE",  "C",    128,      0},; //      ��� �뤠� ���㬥��
   {"PASPDATE",   "D",      8,      0},; //      ����� �뤠� ���㬥��
   {"ADDR_REG",   "C",    255,      0},; // C50  ���� ॣ����樨 (�����)
   {"OKATO_REG",  "C",     12,      0},; // C11  ����� ॣ����樨
   {"ADDR_PROJ",  "C",    255,      0},; // C50  ���� �ॡ뢠��� (�����)
   {"OKATO_PROJ", "C",     12,      0},; // C11  ����� �ॡ뢠���
   {"WORKPLACE",  "C",    255,      0},; // C50  ���� ࠡ���
   {"POLIS_SER",  "C",     24,      0},; // C10  ��� �����
   {"POLIS_NUM",  "C",     64,      0},; // C20  ����� �����
   {"P_DATABEG",  "D",      8,      0},; // ��砫� �����
   {"P_DATAFIN",  "D",      8,      0},; // ����砭�� �����
   {"P_DATACAN",  "D",      8,      0},; // ---------------
   {"SMO_NAME",   "C",    255,      0},; // C100 ������������ ���
   {"SMO_KODTER", "C",      9,      0},; // C5   ��� ����ਨ ���客����?
   {"SMO_KOD",    "C",     48,      0},; // C5   ��� ���
   {"SOC_STATUS", "N",     18,      0},; // N2   �樠��� �����?
   {"POLIS_TYPE", "N",     18,      0};  // N1   ⨯ ����� (1-3)
  }
Static struct_chip := {;
   {"CHIPCODE",   "N",      7,      0},; // ��� �� ����⥪�
   {"PCODE",      "N",     18,      0},; // ID
   {"PAT_TYPE",   "C",      1,      0},; // �㪢�
   {"CARDNUM",    "C",     10,      0},; // ����� ���⪠/����� � ���⪥
   {"LASTNAME",   "C",     32,      0},; // 䠬����
   {"FIRSTNAME",  "C",     32,      0},; // ���
   {"MIDNAME",    "C",     32,      0},; // ����⢮
   {"POL",        "N",      1,      0},; // ���
   {"BDATE",      "D",      8,      0},; // ��� ஦�����
   {"SNILS",      "C",     14,      0},; // �����
   {"PASPTYPE",   "N",      2,      0},; // ��� ���-�, �-�� ��筮��� (1-18)
   {"PASPSER",    "C",     12,      0},; // ��� ���㬥��
   {"PASPNUM",    "C",     12,      0},; // ����� ���㬥��
   {"BIRTHPLACE", "C",    100,      0},; // ���� ஦�����
   {"PASPPLACE",  "C",     70,      0},; // ��� �뤠� ���㬥��
   {"PASPDATE",   "D",      8,      0},; // ����� �뤠� ���㬥��
   {"ADDR_REG",   "C",     50,      0},; // ���� ॣ����樨 (�����)
   {"OKATO_REG",  "C",     11,      0},; // ����� ॣ����樨
   {"ADDR_PROJ",  "C",     50,      0},; // ���� �ॡ뢠��� (�����)
   {"OKATO_PROJ", "C",     11,      0},; // ����� �ॡ뢠���
   {"WORKPLACE",  "C",     50,      0},; // ���� ࠡ���
   {"POLIS_SER",  "C",     10,      0},; // ��� �����
   {"POLIS_NUM",  "C",     20,      0},; // ����� �����
   {"P_DATABEG",  "D",      8,      0},; //
   {"P_DATAFIN",  "D",      8,      0},; //
   {"SMO_NAME",   "C",    100,      0},; // ������������ ���
   {"SMO_KODTER", "C",      5,      0},; // ��� ����ਨ ���客����
   {"SMO_KOD",    "C",      5,      0},; // ��� ���
   {"SOC_STATUS", "N",      2,      0},; // �樠��� �����?
   {"POLIS_TYPE", "N",      1,      0};  // ⨯ ����� (1-3)
  }
Static path1_sds, path2_sds
//
Local ic, ii, i, j, arr_f, cFile, buf, bSaveHandler, fl, ar, arr_bad := {}
if !is_obmen_sds()
  return NIL
endif
if path1_sds == NIL // �஢��塞 ⮫쪮 ���� ࠧ
  ar := GetIniSect(tmp_ini,"RAB_MESTO")
  path1_sds := alltrim(a2default(ar,"path1_sds"))
  path2_sds := alltrim(a2default(ar,"path2_sds"))
  if !empty(path1_sds)
    if empty(path2_sds)
      path1_sds := NIL
      return func_error(4,"�� ����஥� ��⠫�� ��� ��ࠡ�⠭��� 䠩��� Smart Delta Systems!")
    endif
    if right(path1_sds,1) != cslash
      path1_sds += cslash
    endif
    if right(path2_sds,1) != cslash
      path2_sds += cslash
    endif
    if upper(path1_sds) == upper(path2_sds)
      path1_sds := NIL
      return func_error(4,"��� ࠧ� ��࠭ �� �� ��⠫�� ��� 䠩��� Smart Delta Systems. �������⨬�!")
    endif
  endif
endif
if !empty(path1_sds)
  arr_f := directory(path1_sds+"*"+sdbf) // �� DBF-䠩�� - � ���ᨢ
  if empty(arr_f)
    return NIL
  endif
  buf := save_maxrow()
  stat_msg("����! ��ࠡ��뢠���� ��������� � ����⥪� (�� Smart Delta Systems)")
  G_Use(dir_server+"s_kemvyd",dir_server+"s_kemvyd","SA")
  G_Use(dir_server+"mo_kfio",,"KFIO")
  index on str(kod,7) to (cur_dir+"tmp_kfio")
  G_Use(dir_server+"mo_kismo",,"KSN")
  index on str(kod,7) to (cur_dir+"tmp_ismo")
  Use_base("kartotek")
  for ic := 1 to 20 // ��� ���񦭮�� 20 横��� ���� ��⠫���
    if ic > 1 // ��ன � �.�. 横��
      arr_f := directory(path1_sds+"*"+sdbf) // �� DBF-䠩�� - � ���ᨢ
      if empty(arr_f)
        exit
      endif
    endif
    for ii := 1 to len(arr_f)
      cFile := StripPath(arr_f[ii,1])  // ��� 䠩�� ��� ��� (�� ��直� ��砩)
      if ic > 1 .and. ascan(arr_bad,cFile) > 0
        Loop
      endif
      @ maxrow(),1 say lstr(ii)+"("+lstr(ic)+")" color cColorSt2Msg
      bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
      //
      BEGIN SEQUENCE
        use (path1_sds+cFile) new alias T1
        fl := .t.
        for j := 1 to len(struct_sds)
          if fieldnum(struct_sds[j,1]) == 0
            fl := func_error(4,"� 䠩�� "+path1_sds+cFile+" ��� ���� "+struct_sds[j,1])
            aadd(arr_bad,cFile)
            exit
          endif
        next
        if fl
          dbcreate(path2_sds+cFile,struct_chip)
          use (path2_sds+cFile) new alias T2
          select T1
          go top
          do while !eof()
            MFIO := alltrim(t1->LASTNAME)+" "+alltrim(t1->FIRSTNAME)+" "+alltrim(t1->MIDNAME)
            lkod_k := 0 ; mfio := padr(charone(" ",mfio),50)
            if !emptyany(mfio,t1->bdate)
              select KART
              set order to 2
              find ("1"+upper(mfio)+dtos(t1->bdate))
              if found()
                lkod_k := kart->kod
              endif
              select KART
              set order to 1
              if empty(lkod_k)
                Add1Rec(7)
                lkod_k := kart->kod := recno()
                kart->FIO    := mFIO
                kart->DATE_R := t1->bdate
              else
                goto (lkod_k)
                G_RLock(forever)
              endif
              mdate_r := kart->DATE_R ; m1VZROS_REB := M1NOVOR := 0
              fv_date_r()
              kart->VZROS_REB := m1VZROS_REB
              if between(t1->pol,1,2)
                kart->pol := iif(t1->pol==1,"�","�")
              endif
              if !empty(t1->snils)
                kart->snils := charrem(" -",t1->snils)
              endif
              if !empty(t1->ADDR_REG)
                kart->ADRES := f_adres_sds(t1->ADDR_REG)
              endif
              if !empty(t1->WORKPLACE)
                kart->MR_DOL := ltrim(charone(" ",t1->WORKPLACE))
              endif
              if !empty(t1->P_DATAFIN)
                kart->srok_polis := dtoc4(t1->P_DATAFIN)
              endif
              kart->KOMU    := 0 // �� ���
              kart->STR_CRB := 0
              kart->MI_GIT  := 9
              if !empty(t1->PAT_TYPE)
                kart->bukva := ltrim(t1->PAT_TYPE)
              endif
              much_doc := ltrim(t1->CARDNUM)
              if !empty(charrem("/",much_doc))
                muchast := mkod_vu := 0
                if left(much_doc,1) == "/"
                  much_doc := "0"+much_doc
                endif
                if (muchast := int(val(much_doc))) > 99
                  muchast := 0
                endif
                if (i := at("/",much_doc)) > 0
                  if (mkod_vu := int(val(substr(much_doc,i+1)))) > 99999
                    mkod_vu := 0
                  endif
                endif
                kart->uchast := muchast
                kart->kod_vu := mkod_vu
              endif
              if TwoWordFamImOt(t1->LASTNAME) .or. TwoWordFamImOt(t1->FIRSTNAME);
                                              .or. TwoWordFamImOt(t1->MIDNAME)
                kart->MEST_INOG := 9
              else
                kart->MEST_INOG := 0
              endif
              //
              select KART2
              do while kart2->(lastrec()) < lkod_k
                APPEND BLANK
              enddo
              goto (lkod_k)
              G_RLock(forever)
              //
              select KART_
              do while kart_->(lastrec()) < lkod_k
                APPEND BLANK
              enddo
              goto (lkod_k)
              G_RLock(forever)
              if !emptyall(t1->POLIS_SER,t1->POLIS_NUM)
                kart->POLIS   := make_polis(t1->POLIS_SER,t1->POLIS_NUM)
                kart_->VPOLIS := iif(between(t1->POLIS_TYPE,1,3), t1->POLIS_TYPE, 1)
                kart_->SPOLIS := ltrim(t1->POLIS_SER)
                kart_->NPOLIS := ltrim(t1->POLIS_NUM)
              endif
              fl_nameismo := empty(t1->SMO_KOD) .and. !empty(t1->SMO_NAME)
              if fl_nameismo
                kart_->SMO := '34'
              elseif !empty(t1->SMO_KOD)
                kart_->SMO := ltrim(t1->SMO_KOD)
              endif
              if !empty(t1->P_DATABEG)
                kart_->beg_polis := dtoc4(t1->P_DATABEG)
              endif
              if !emptyall(t1->PASPSER,t1->PASPNUM)
                kart_->vid_ud := f_vid_ud_sds(t1->PASPTYPE)
                kart_->ser_ud := ltrim(t1->PASPSER)
                kart_->nom_ud := ltrim(t1->PASPNUM)
              endif
              if !empty(t1->PASPPLACE)
                kart_->kemvyd := f_kemvyd_sds(t1->PASPPLACE)
              endif
              if !empty(t1->PASPDATE)
                kart_->kogdavyd := t1->PASPDATE
              endif
              if !empty(t1->BIRTHPLACE)
                kart_->mesto_r:= t1->BIRTHPLACE
              endif
              if !empty(t1->OKATO_REG)
                kart_->okatog := t1->OKATO_REG
              endif
              if !empty(t1->OKATO_PROJ)
                kart_->okatop := t1->OKATO_PROJ
              endif
              if !empty(t1->ADDR_PROJ)
                kart_->adresp := f_adres_sds(t1->ADDR_PROJ)
              endif
              if kart_->okatog==kart_->okatop .and. kart->adres==kart_->adresp
                kart_->okatop := kart_->adresp := ""
              endif
              if between(t1->SOC_STATUS,1,3)
                kart->RAB_NERAB := iif(t1->SOC_STATUS==1, 0, 1)
                kart_->PENSIONER := iif(t1->SOC_STATUS==2, 1, 0)
              endif
              //
              select KFIO
              find (str(lkod_k,7))
              if found()
                if kart->MEST_INOG == 9
                  G_RLock(forever)
                  kfio->FAM := ltrim(charone(" ",t1->LASTNAME))
                  kfio->IM  := ltrim(charone(" ",t1->FIRSTNAME))
                  kfio->OT  := ltrim(charone(" ",t1->MIDNAME))
                else
                  DeleteRec(.t.)
                endif
              else
                if kart->MEST_INOG == 9
                  AddRec(7)
                  kfio->kod := lkod_k
                  kfio->FAM := ltrim(charone(" ",t1->LASTNAME))
                  kfio->IM  := ltrim(charone(" ",t1->FIRSTNAME))
                  kfio->OT  := ltrim(charone(" ",t1->MIDNAME))
                endif
              endif
              if !empty(t1->SMO_KODTER)
                kart_->KVARTAL_D := ltrim(t1->SMO_KODTER) // ����� ��ꥪ� �� ����ਨ ���客����
              endif
              select KSN
              find (str(lkod_k,7))
              if found()
                if fl_nameismo
                  G_RLock(forever)
                  ksn->smo_name := ltrim(t1->SMO_NAME)
                else
                  DeleteRec(.t.)
                endif
              else
                if fl_nameismo
                  AddRec(7)
                  ksn->kod := lkod_k
                  ksn->smo_name := ltrim(t1->SMO_NAME)
                endif
              endif
              UnLock
            endif
            //
            select T2
            append blank
            t2->CHIPCODE   := lkod_k
            t2->PCODE      := t1->PCODE
            t2->PAT_TYPE   := t1->PAT_TYPE
            t2->CARDNUM    := t1->CARDNUM
            t2->LASTNAME   := t1->LASTNAME
            t2->FIRSTNAME  := t1->FIRSTNAME
            t2->MIDNAME    := t1->MIDNAME
            t2->POL        := t1->POL
            t2->BDATE      := t1->BDATE
            t2->SNILS      := t1->SNILS
            t2->PASPTYPE   := t1->PASPTYPE
            t2->PASPSER    := t1->PASPSER
            t2->PASPNUM    := t1->PASPNUM
            t2->BIRTHPLACE := t1->BIRTHPLACE
            t2->PASPPLACE  := t1->PASPPLACE
            t2->PASPDATE   := t1->PASPDATE
            t2->ADDR_REG   := t1->ADDR_REG
            t2->OKATO_REG  := t1->OKATO_REG
            t2->ADDR_PROJ  := t1->ADDR_PROJ
            t2->OKATO_PROJ := t1->OKATO_PROJ
            t2->WORKPLACE  := t1->WORKPLACE
            t2->POLIS_SER  := t1->POLIS_SER
            t2->POLIS_NUM  := t1->POLIS_NUM
            t2->P_DATABEG  := t1->P_DATABEG
            t2->P_DATAFIN  := t1->P_DATAFIN
            t2->SMO_NAME   := t1->SMO_NAME
            t2->SMO_KODTER := t1->SMO_KODTER
            t2->SMO_KOD    := t1->SMO_KOD
            t2->SOC_STATUS := t1->SOC_STATUS
            t2->POLIS_TYPE := t1->POLIS_TYPE
            //
            select T1
            skip
          enddo
          t1->(dbCloseArea())
          t2->(dbCloseArea())
          delete file (path1_sds+cFile)
        else // �᫨ �� ��� 䠩�, � ���� ����뢠��
          t1->(dbCloseArea())
        endif
      RECOVER USING error
        if select("t1") > 0   // �᫨ �뫥⥫� �� �訡��
          t1->(dbCloseArea()) // ������� 䠩�
        endif
        if select("t2") > 0   // �᫨ �뫥⥫� �� �訡��
          t2->(dbCloseArea()) // ������� 䠩�
        endif
        // ����஥��� ᮮ�饭�� �� �訡��
        cMessage := ErrorMessage(error)
        if !Empty(error:osCode)
          cMessage += " (��� " + lstr(error:osCode) + ")"
        end
        if Valtype(error:osCode) == "N" .and. error:osCode == 32
          // 䠩� 㦥 ��ࠡ��뢠���� ��㣮� ࠡ.�⠭樥� - �訡�� �� �⮡ࠦ���
        else
          func_error(4,cMessage) // ��⠫�� �訡�� �뢮��� � ��᫥���� ��ப�
        endif
      END
      //
      ERRORBLOCK(bSaveHandler)
    next
  next
  close databases
  rest_box(buf)
endif
return NIL

*****
Static Function f_adres_sds(s)
Static cDelimiter := ",", sa := {"�.","�.","���.","��."}
Local i, j, s1, s2 := ""
s := alltrim(charone(" ",s))
for i := 1 to numtoken(s,cDelimiter)
  s1 := alltrim(token(s,cDelimiter,i))
  for j := 1 to len(sa)
    if s1 == sa[j]
      s1 := "" ; exit
    endif
  next
  if !empty(s1)
    if i > 1
      s1 := charrem(" ",s1)
    endif
    s2 += s1+", "
  endif
next
s2 := left(s2,len(s2)-2)
if len(s2) > 50
  s2 := charrem(" ",s2)
endif
do while len(s2) > 50
  s2 := substr(s2,2)
enddo
return s2

*****
Static Function f_vid_ud_sds(n)
Local v := 0
do case
  case n == 1  ; v := 14 // ��ᯮ�� ��
  case n == 2  ; v := 1  // ��ᯮ�� ����
  case n == 3  ; v := 15 // ���࠭��� ��ᯮ�� ��
  case n == 4  ; v := 2  // ���࠭��� ��ᯮ�� ����
  case n == 5  ; v := 3  // �����⥫��⢮ � ஦�����
  case n == 6  ; v := 4  // ����⮢�७�� ��筮�� ����
  case n == 7  ; v := 5  // ��ࠢ�� �� �᢮�������� �� ���� ��襭�� ᢮����
  case n == 8  ; v := 7  // ������ �����
  case n == 9  ; v := 8  // ���������᪨� ��ᯮ�� ��
  case n == 10 ; v := 9  // �����࠭�� ��ᯮ��
  case n == 11 ; v := 10 // �����⥫��⢮ ������
  case n == 12 ; v := 11 // ��� �� ��⥫��⢮
  case n == 13 ; v := 12 // ����⮢�७�� ������
  case n == 14 ; v := 13 // �६����� 㤮�⮢�७��
  case n == 15 ; v := 16 // ��ᯮ�� ���猪
  case n == 16 ; v := 17 // ������ ����� ���� �����
  case n == 88 ; v := 18 // ��� ���㬥���
endcase
return v

***** 12.07.17
Static Function f_kemvyd_sds(s)
Local l, lkod := 0, fl := .f.
if !empty(s)
  select SA
  l := fieldsize(fieldnum("name"))
  s := padr(alltrim(charone(" ",s)),l)
  find (upper(s))
  if found()
    lkod := sa->(recno())
  endif
  if lkod == 0 .and. lastrec() < 9999
    AddRecN()
    replace name with s
    lkod := sa->(recno())
    UNLOCK
  endif
endif
return lkod
