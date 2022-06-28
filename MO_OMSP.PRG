***** mo_omsp.prg - работа с платёжными документами в задаче ОМС
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 19.02.20 прочитать и "разнести" по базам данных РПД
Function read_XML_FILE_RPD(arr_XML_info,aerr)
Local fl_PD, fl_schet, blk_PD, blk_schet, i, k, s, s1, arr_s := {}, t_arr[2], ssum,;
      arr, apd := {}, no_write := .t.
blk_PD := {|| aadd(aerr,"Платёжный документ № "+alltrim(tmp2->_N_PD)+" от "+date_8(tmp2->_D_PD)) }
blk_schet := {|| aadd(aerr," СЧЁТ № "+alltrim(tmp3->_nschet)+" от "+date_8(tmp3->_dschet)) }
use (cur_dir+"tmp1file") new alias TMP1
tmp1->_SMO     := arr_XML_info[2]
tmp1->_CODE_MO := arr_XML_info[3]
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
index on str(kod_pd,10) to (cur_dir+"tmp3")
use (cur_dir+"tmp4file") new alias TMP4
index on str(kod_pd,10)+str(kod_s,10) to (cur_dir+"tmp4")
// сначала найдём коды счетов и коды листов учёта
G_Use(dir_server+"schet_",,"SCHET_")
index on dtos(dschet)+upper(nschet) to (cur_dir+"tmp_sch_")
R_Use(dir_server+"mo_otd",,"OTD")
G_Use(dir_server+"human_",,"HUMAN_")
G_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
select TMP2
go top
do while !eof()
  fl_PD := .t. ; arr := {}
  select TMP3
  find (str(tmp2->kod_pd,10))
  do while tmp2->kod_pd == tmp3->kod_pd .and. !eof()
    fl_schet := .t.
    select SCHET_
    find (dtos(tmp3->_dschet)+upper(tmp3->_nschet))
    if found()
      no_write := .f.
      aadd(arr,schet_->(recno()))
      tmp3->kod_schet := schet_->(recno())
      if !(tmp3->_PLAT == schet_->smo)
        if fl_PD
          eval(blk_PD) ; fl_PD := .f.
        endif
        if fl_schet
          eval(blk_schet) ; fl_schet := .f.
        endif
        aadd(aerr,"  не равен код плательщика: в файле - "+alltrim(tmp3->_PLAT)+", у нас - "+alltrim(schet_->smo))
      endif
      //
      select HUMAN
      set index to (dir_server+"humans")
      find (str(tmp3->kod_schet,6))
      index on str(human_->schet_zap,6) to (cur_dir+"tmp_hum") for ishod != 89 while schet == tmp3->kod_schet
      select TMP4
      find (str(tmp3->kod_pd,10)+str(tmp3->kod_s,10))
      do while tmp3->kod_pd == tmp4->kod_pd .and. tmp3->kod_s == tmp4->kod_s .and. !eof()
        select HUMAN
        find (str(tmp4->_IDCASE,6))
        if found()
          tmp4->KOD_H := human->kod
          if !(upper(tmp4->_ID_C) == upper(human_->ID_C))
            if fl_PD
              eval(blk_PD) ; fl_PD := .f.
            endif
            if fl_schet
              eval(blk_schet) ; fl_schet := .f.
            endif
            aadd(aerr,"  случай № "+lstr(tmp4->_IDCASE)+", "+alltrim(human->fio)+", л/у "+lstr(human->kod))
            aadd(aerr,"   ID_C в СМО = "+tmp4->_ID_C+", ID_C у нас = "+human_->ID_C)
          endif
        else
          if fl_PD
            eval(blk_PD) ; fl_PD := .f.
          endif
          if fl_schet
            eval(blk_schet) ; fl_schet := .f.
          endif
          aadd(aerr,"   не найден пациент с IDCASE = "+lstr(tmp4->_IDCASE))
        endif
        select TMP4
        skip
      enddo
    else
      if fl_PD
        //eval(blk_PD) ; fl_PD := .f.
      endif
      aadd(arr_s,{tmp3->kod_pd,tmp3->kod_s,;
                  " Не найден СЧЁТ № "+alltrim(tmp3->_nschet)+" от "+date_8(tmp3->_dschet)})
    endif
    select TMP3
    skip
  enddo
  aadd(apd,{tmp2->kod_pd,arr})
  select TMP2
  skip
enddo
commit
if no_write
  aadd(aerr," Из этого РПД нечего записывать в текущую базу данных")
endif
if !empty(aerr)
  for i := 1 to len(arr_s)
    aadd(aerr,arr_s[i,3])
  next
  return NIL
endif
// запишем принимаемый файл (РАК)
//chip_copy_zipXML(hb_OemToAnsi(full_zip),dir_server+dir_XML_TF)
chip_copy_zipXML(full_zip,dir_server+dir_XML_TF)
G_Use(dir_server+"mo_xml",,"MO_XML")
AddRecN()
mo_xml->KOD := recno()
mo_xml->FNAME := cReadFile
mo_xml->DFILE := tmp1->_DATA
mo_xml->TFILE := ""
mo_xml->DREAD := sys_date
mo_xml->TREAD := hour_min(seconds())
mo_xml->TIP_IN := _XML_FILE_RPD
mo_xml->DWORK  := sys_date
mo_xml->TWORK1 := hour_min(seconds())
mo_xml->TWORK2 := ""
mo_xml->KOL1   := tmp1->KOL_PD
mo_xml->KOL2   := tmp1->KOL_SCH
strfile(hb_eol()+;
        "Количество платёжных документов - "+lstr(tmp1->KOL_PD)+hb_eol()+;
        "Количество счетов - "+lstr(tmp1->KOL_SCH)+hb_eol()+;
        "Количество оплаченных пациентов - "+lstr(tmp1->KOL_PAC)+hb_eol(),cFileProtokol,.t.)
//
select HUMAN
set index to
R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
G_Use(dir_server+"schet",,"SCHET")
G_Use(dir_server+"mo_rpd",,"RPD")
index on str(PD,6) to (cur_dir+"tmprpd")
G_Use(dir_server+"mo_rpds",,"RPDS")
index on str(PD,6) to (cur_dir+"tmprpds")
G_Use(dir_server+"mo_rpdsh",,"RPDSH")
index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
select TMP2
go top
do while !eof()
  s := hb_eol()+"Платёжный документ № "+alltrim(tmp2->_N_PD)+" от "+date_8(tmp2->_D_PD)
  if (i := ascan(apd,{|x| x[1] == tmp2->kod_pd })) > 0 .and. empty(apd[i,2])
    strfile(s+" - не найдено счетов в базе данных"+hb_eol()+hb_eol(),cFileProtokol,.t.)
  else
    strfile(s+", счетов - "+lstr(tmp2->KOL_SCH)+;
              ", пациентов - "+lstr(tmp2->KOL_PAC)+hb_eol(),cFileProtokol,.t.)
    select RPD
    AddRec(6)
    rpd->PD      := recno() // код ПД
    rpd->KOD_XML := mo_xml->KOD
    rpd->T_PD    := tmp2->_T_PD
    rpd->N_PD    := tmp2->_N_PD
    rpd->D_PD    := tmp2->_D_PD
    rpd->NSCHET  := ""
    rpd->KOL_SCH := tmp2->KOL_SCH
    rpd->KOL_PAC := tmp2->KOL_PAC
    rpd->S_PD    := tmp2->_S_PD
    rpd->S_ALL   := tmp2->_S_ALL
    rpd->KBK     := tmp2->_KBK
    select TMP3
    find (str(tmp2->kod_pd,10))
    do while tmp2->kod_pd == tmp3->kod_pd .and. !eof()
      if tmp3->kod_schet == 0
        if (i := ascan(arr_s,{|x| x[1]==tmp3->kod_pd .and. x[2]==tmp3->kod_s})) > 0
          strfile(hb_eol()+" "+arr_s[i,3]+hb_eol()+hb_eol(),cFileProtokol,.t.)
        endif
      else
        schet_->(dbGoto(tmp3->kod_schet))
        schet->(dbGoto(tmp3->kod_schet))
        if tmp2->KOL_SCH == 1
          rpd->NSCHET := schet_->NSCHET
        endif
        //
        strfile(hb_eol()+;
                "  СЧЁТ № "+alltrim(tmp3->_nschet)+" от "+date_8(tmp3->_dschet)+;
                ", отчётный период - "+strzero(schet_->nyear,4)+"/"+strzero(schet_->nmonth,2)+hb_eol()+;
                "  выставлено: пациентов -"+str(schet->kol   ,5)+", на сумму - "+lstr(schet->SUMMA,15,2)+"р."+hb_eol()+;
                "  оплачено  : пациентов -"+str(tmp3->KOL_PAC,5)+", на сумму - "+lstr(tmp3->_S_SCH,15,2)+"р."+hb_eol(),cFileProtokol,.t.)
        select RPDS
        AddRec(6)
        rpds->KOD_RPDS := recno()
        rpds->PD       := rpd->PD
        rpds->SCHET    := tmp3->kod_schet
        rpds->KOL_PAC  := tmp3->KOL_PAC
        rpds->PLAT     := tmp3->_PLAT
        rpds->S_SCH    := tmp3->_S_SCH
        commit
        k := k1 := 0
        select TMP4
        find (str(tmp3->kod_pd,10)+str(tmp3->kod_s,10))
        do while tmp3->kod_pd == tmp4->kod_pd .and. tmp3->kod_s == tmp4->kod_s .and. !eof()
          human->(dbGoto(tmp4->KOD_H))
          //human->(G_RLock(forever))
          //human->DATE_OPL := dtoc4(rpd->D_PD) т.к. будем заносить next_vizit
          ssum := human->cena_1
          if human->ishod == 88
            select HUMAN_3
            set order to 1
            find (str(human->kod,7))
            ssum := human_3->CENA_1
          endif
          if round(ssum,2) == round(tmp4->_S_SL,2)
            ++k
          else
            sumr := 0
            select RPDSH
            find (str(tmp4->KOD_H,7))
            do while rpdsh->KOD_H == tmp4->KOD_H .and. !eof()
              sumr += rpdsh->S_SL
              skip
            enddo
            s := space(4)+"сумма лечения: "+lstr(ssum,15,2)+"р., "+;
                          "оплачено: "+lstr(tmp4->_S_SL,15,2)+"р., "
            if empty(sumr)
              s += "не оплачено: "+lstr(ssum-tmp4->_S_SL,15,2)+"р."
            else
              s += "ранее оплачено: "+lstr(sumr,15,2)+"р."
              if round(ssum,2) == round(sumr+tmp4->_S_SL,2)
                ++k1
                s += hb_eol()+space(4)+"=итого случай полностью оплачен="
              endif
            endif
            strfile("  - "+"Случай № "+lstr(tmp4->_IDCASE)+". "+alltrim(human->fio)+", "+;
                         full_date(human->date_r)+;
                         iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                         " "+date_8(human->n_data)+"-"+;
                         date_8(human->k_data)+hb_eol()+s+;
                         hb_eol(),cFileProtokol,.t.)
          endif
          //
          select RPDSH
          AddRec(7)
          rpdsh->KOD_RPDS := rpds->KOD_RPDS
          rpdsh->KOD_H    := tmp4->KOD_H
          rpdsh->S_SL     := tmp4->_S_SL
          select TMP4
          skip
        enddo
        commit
        if k > 0
          if k == tmp3->KOL_PAC .and. k == schet->kol
            strfile("  Все пациенты оплачены полностью"+hb_eol(),cFileProtokol,.t.)
          else
            strfile("  Полностью оплачено пациентов - "+lstr(k)+hb_eol(),cFileProtokol,.t.)
            if tmp3->KOL_PAC > k
              if tmp3->KOL_PAC-k > k1
                strfile("  не полностью оплачено пациентов - "+lstr(tmp3->KOL_PAC-k-k1)+hb_eol(),cFileProtokol,.t.)
              endif
              if k1 > 0
                strfile("  дооплачено пациентов - "+lstr(k1)+hb_eol(),cFileProtokol,.t.)
              endif
            endif
          endif
        endif
      endif
      select TMP3
      skip
    enddo
  endif
  select TMP2
  skip
enddo
// запишем время окончания обработки
mo_xml->TWORK2 := hour_min(seconds())
close databases
return NIL

*

***** 10.02.17 зачитать Реестр Платёжных Документов во временные файлы
Function reestr_rpd_tmpfile(oXmlDoc,aerr,mname_xml)
Local j, j1, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ реестра платёжных докмуентов "+beforatnum(".",mname_xml))
dbcreate(cur_dir+"tmp1file", {; // одна запись
 {"_VERSION",   "C",  5,0},;
 {"_DATA",      "D",  8,0},;
 {"_FILENAME",  "C", 26,0},;
 {"_SMO",       "C",  5,0},; // код СМО или ТФ
 {"_CODE_MO",   "C",  6,0},; // код МО
 {"KOL_PD",     "N",  6,0},; // кол-во ПД в файле
 {"KOL_SCH",    "N",  6,0},; // кол-во счетов в файле
 {"KOL_PAC",    "N",  6,0};  // кол-во пациентов в файле
})
dbcreate(cur_dir+"tmp2file", {;  // много ПД
 {"kod_pd",     "N",  6,0},; // код записи ПД
 {"_T_PD",      "N",  1,0},; // 1-платёжное поручение,2-письмо об уменьшении задолжненности
 {"_N_PD",      "C", 25,0},; // номер ПД
 {"_D_PD",      "D",  8,0},; // дата ПД
 {"KOL_SCH",    "N",  6,0},; // кол-во счетов в ПД
 {"KOL_PAC",    "N",  6,0},; // кол-во пациентов в ПД
 {"_S_PD",      "N", 15,2},; // сумма ПД
 {"_S_ALL",     "N", 15,2},; // сумма оплаты
 {"_KBK",       "C", 20,0};  // КБК
})
dbcreate(cur_dir+"tmp3file", {; // в каждом ПД много счетов
 {"kod_pd",     "N",  6,0},; // код записи ПД
 {"kod_s",      "N",  6,0},; // код счета
 {"_CODE",      "N", 12,0},; // код записи счета
 {"_CODE_MO",   "C",  6,0},; // код МО по F003
 {"_YEAR",      "N",  4,0},;
 {"_MONTH",     "N",  2,0},;
 {"KOD_SCHET",  "N",  6,0},; // код нашего счета
 {"_NSCHET",    "C", 15,0},; // номер нашего счета
 {"_DSCHET",    "D",  8,0},; // дата нашего счета
 {"KOL_PAC",    "N",  6,0},; // кол-во пациентов в счете
 {"_PLAT",      "C",  5,0},; // плательщик (СМО или ТФ)
 {"_S_SCH",     "N", 15,2};  // суммы оплаты счёта в ПД
})
dbcreate(cur_dir+"tmp4file", {;
 {"kod_pd",     "N",  6,0},; // код записи ПД
 {"kod_s",      "N",  6,0},; // код счета
 {"_CODE",      "N", 12,0},; // код записи счета
 {"_IDCASE",    "N",  8,0},; // номер записи в счете
 {"KOD_H",      "N",  7,0},; // код листа учета по БД "human"
 {"_ID_C",      "C", 36,0},; // код случая
 {"_S_SL",      "N", 11,2};  // сумма оплаты случая в ПД
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
use (cur_dir+"tmp4file") new alias TMP4
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ 24,1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->_VERSION  :=          mo_read_xml_stroke(oXmlNode,"VERSION", aerr)
      tmp1->_DATA     := xml2date(mo_read_xml_stroke(oXmlNode,"DATA",    aerr))
      tmp1->_FILENAME :=          mo_read_xml_stroke(oXmlNode,"FILENAME",aerr)
    case "PD" == oXmlNode:title
      tmp1->KOL_PD ++
      select TMP2
      append blank
      tmp2->kod_pd  := recno()
      tmp2->_T_PD   :=      val(mo_read_xml_stroke(oXmlNode,"T_PD",aerr))
      tmp2->_N_PD   :=          mo_read_xml_stroke(oXmlNode,"N_PD",aerr)
      tmp2->_D_PD   := xml2date(mo_read_xml_stroke(oXmlNode,"D_PD",aerr))
      tmp2->_S_PD   :=      val(mo_read_xml_stroke(oXmlNode,"S_PD",aerr))
      tmp2->_S_ALL  :=      val(mo_read_xml_stroke(oXmlNode,"S_ALL",aerr))
      tmp2->_KBK    :=          mo_read_xml_stroke(oXmlNode,"KBK",aerr)
      for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
        oNode1 := oXmlNode:aItems[j1]     // т.к. счетов м.б. несколько
        if valtype(oNode1) != "C" .AND. oNode1:title == "SCHET"
          tmp1->KOL_SCH ++
          tmp2->KOL_SCH ++
          select TMP3
          append blank
          tmp3->kod_pd   := tmp2->kod_pd
          tmp3->kod_s    := recno()
          tmp3->_CODE    :=      val(mo_read_xml_stroke(oNode1,"CODE",aerr))
          tmp3->_CODE_MO :=          mo_read_xml_stroke(oNode1,"CODE_MO",aerr)
          tmp3->_YEAR    :=      val(mo_read_xml_stroke(oNode1,"YEAR",aerr))
          tmp3->_MONTH   :=      val(mo_read_xml_stroke(oNode1,"MONTH",aerr))
          tmp3->_NSCHET  :=    upper(mo_read_xml_stroke(oNode1,"NSCHET",aerr))
          tmp3->_DSCHET  := xml2date(mo_read_xml_stroke(oNode1,"DSCHET",aerr))
          tmp3->_PLAT    :=          mo_read_xml_stroke(oNode1,"PLAT",aerr)
          tmp3->_S_SCH   :=      val(mo_read_xml_stroke(oNode1,"S_SCH",aerr))
          for j2 := 1 to len(oNode1:aitems) // последовательный просмотр
            oNode2 := oNode1:aItems[j2]     // т.к. случаев м.б. несколько
            if valtype(oNode2) != "C" .AND. oNode2:title == "SLUCH"
              tmp1->KOL_PAC ++
              tmp2->KOL_PAC ++
              tmp3->KOL_PAC ++
              select TMP4
              append blank
              tmp4->kod_pd  := tmp3->kod_pd
              tmp4->kod_s   := tmp3->kod_s
              tmp4->_CODE   := tmp3->_CODE
              tmp4->_IDCASE :=   val(mo_read_xml_stroke(oNode2,"IDCASE",aerr))
              tmp4->_ID_C   := upper(mo_read_xml_stroke(oNode2,"ID_C",aerr))
              tmp4->_S_SL   :=   val(mo_read_xml_stroke(oNode2,"S_SL",aerr))
            endif
          NEXT j2
        endif
      NEXT j1
  endcase
NEXT j
commit
rest_box(buf)
return NIL

*

***** 17.03.13
Function view_pd()
G_Use(dir_server+"mo_xml",,"MO_XML")
index on dtos(DFILE) to (cur_dir+"tmp_xml") for tip_in==_XML_FILE_RPD DESCENDING
go top
if eof()
  func_error(4,"Нет реестров платёжных документов")
else
  Alpha_Browse(T_ROW,2,22,77,"f1_view_rpd",color0,,,,,,,;
               "f2_view_rpd",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
return NIL

***** 17.03.13
Function f1_view_rpd(oBrow)
Local oColumn, blk := {|| iif(empty(mo_xml->TWORK2), {5,6}, {1,2}) }
oColumn := TBColumnNew("Наименование файла;реестра плат.документов",{|| padr(mo_xml->FNAME,23) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дата файла; реестра",{|| full_date(mo_xml->dfile) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.; ПД", {|| str(mo_xml->kol1,5) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.;счетов", {|| str(mo_xml->kol2,6) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("  Дата; чтения",{|| date_8(mo_xml->dread) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Время;чтения",{|| mo_xml->tread })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Примечание",{|| padr(iif(empty(mo_xml->TWORK2),"не дочитан",""),10) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
status_key("^<Esc>^ выход; ^<Enter>^ просмотр платёжных документов; ^<F3>^ протокол чтения файла")
return NIL

***** 17.03.13
Function f2_view_rpd(nKey,oBrow)
Local ret := -1, rec := mo_xml->(recno()), buf := savescreen()
do case
  case nKey == K_F3
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
    ret := 0
  case nKey == K_ENTER
    view_rpd_pd(rec)
    close databases
    //
    G_Use(dir_server+"mo_xml",cur_dir+"tmp_xml","MO_XML")
    goto (rec)
    ret := 0
  case nKey == K_CTRL_F12
    ret := delete_rpd(rec,alltrim(mo_xml->FNAME),empty(mo_xml->TWORK2))
    close databases
    G_Use(dir_server+"mo_xml",cur_dir+"tmp_xml","MO_XML")
    goto (rec)
endcase
restscreen(buf)
return ret


***** 21.12.21
Function delete_rpd(lrec,lname,not_end)
Local ret := 0, fl, ia, is, ih
if not_end .or. hb_user_curUser:IsAdmin()
  fl := .t.
else
  fl := involved_password(2,lname,"подтверждения расформирования РПД")
endif
if fl .and. f_Esc_Enter("расформирования РПД",.t.)
  stat_msg("Подтвердите расформирование ещё раз.") ; mybell(2)
  if f_Esc_Enter("расформирования РПД",.t.)
    mywait("Ждите. Производится расформирование РПД.")
    G_Use(dir_server+"mo_rpdsh",,"RPDSH")
    index on str(kod_rpds,6) to (cur_dir+"tmprpdsh")
    G_Use(dir_server+"mo_rpds",,"RPDS")
    index on str(pd,6) to (cur_dir+"tmprpds")
    G_Use(dir_server+"mo_rpd",,"RPD")
    index on str(kod_xml,6) to (cur_dir+"tmprpd")
    ia := is := ih := 0
    do while .t.
      ++ia
      select RPD
      find (str(lrec,6))
      if !found() ; exit ; endif
      do while .t.
        ++is
        select RPDS
        find (str(rpd->pd,6))
        if !found() ; exit ; endif
        do while .t.
          ++ih
          select RPDSH
          find (str(rpds->KOD_RPDS,6))
          if !found() ; exit ; endif
          @ maxrow(),1  say lstr(ia) color "G+/R*"
          @ row(),col() say "/"      color "R/R*"
          @ row(),col() say lstr(is) color "GR+/R*"
          @ row(),col() say "/"      color "R/R*"
          @ row(),col() say lstr(ih) color "W+/R*"
          DeleteRec(.t.)
        enddo
        select RPDS
        DeleteRec(.t.)
      enddo
      select RPD
      DeleteRec(.t.)
    enddo
    select MO_XML
    DeleteRec(.t.)
    stat_msg("Реестр платёжных документов "+lname+" удалён!") ; mybell(2,OK)
    ret := 1
  endif
endif
return ret

*

***** 17.03.13
Function view_rpd_pd(lrec)
Local blk, blk_t_pd, t_arr[BR_LEN]
R_Use(dir_server+"mo_rpd",,"RPD")
index on n_pd to (cur_dir+"tmp_rpd") for kod_xml == lrec
go top
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := 22
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_TITUL] := "РПД "+alltrim(mo_xml->FNAME)+sxml+" от "+date_8(mo_xml->dfile)
t_arr[BR_TITUL_COLOR] := "B/G*"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk_t_pd := {|| iif(rpd->t_pd==1,"плат.поручение","уменьш.задолж.") }
t_arr[BR_COLUMN] := {{" Номер ПД", {|| left(rpd->n_pd,15) }, blk },;
                     {" Дата ПД", {|| date_8(rpd->d_pd) }, blk },;
                     {" Тип ПД", {|| padr(eval(blk_t_pd),14) }, blk },;
                     {"Кол-во;счетов", {|| str(rpd->kol_sch,6) }, blk },;
                     {"Сумма ПД", {|| put_kop(rpd->S_PD,13) }, blk },;
                     {"Сумма оплаты", {|| put_kop(rpd->S_ALL,13) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор ПД для просмотра счетов") }
t_arr[BR_EDIT] := {|nk,ob| f1_view_rpd_pd(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

***** 17.03.13
Function f1_view_rpd_pd(nk,ob,regim)
Local ret := -1, rec
if regim == "edit" .and. nk == K_ENTER
  rec := rpd->(recno())
  view_rpd_pd_schet(rpd->pd)
  close databases
  //
  R_Use(dir_server+"mo_rpd",cur_dir+"tmp_rpd","rpd")
  goto (rec)
  ret := 0
endif
return ret

*

***** 17.03.13
Function view_rpd_pd_schet(lpd)
Local blk, t_arr[BR_LEN]
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
R_Use(dir_server+"mo_rpds",,"RPDS")
set relation to schet into SCHET, to schet into SCHET_
index on dtos(schet_->dschet)+schet_->nschet to (cur_dir+"tmp_rpds") for pd == lpd
go top
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := 22
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := 77
t_arr[BR_TITUL] := iif(rpd->t_pd==1,"Платёжный документ","Письмо об уменьшении задолженности")+;
                   " № "+alltrim(rpd->n_pd)+" от "+date_8(rpd->d_pd)
t_arr[BR_TITUL_COLOR] := "B/GR*"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(round(schet->SUMMA,2)==round(rpds->S_SCH,2), {1,2}, {3,4}) }
t_arr[BR_COLUMN] := {{" Номер счёта", {|| schet_->nschet }, blk },;
                     {"Пе-;риод", {|| right(str(schet_->nyear,4),2)+"/"+strzero(schet_->nmonth,2) }, blk },;
                     {"  Дата; счёта", {|| date_8(schet_->dschet) }, blk },;
                     {"Паци-;ентов", {|| str(schet->kol,5) }, blk },;
                     {"Опла-;чено", {|| put_val(rpds->kol_pac,5) }, blk },;
                     {" Сумма счёта", {|| put_kop(schet->SUMMA,13) }, blk },;
                     {" Оплаченная; сумма", {|| put_kop(rpds->S_SCH,13) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор счёта для просмотра пациентов") }
t_arr[BR_EDIT] := {|nk,ob| f1_view_rpd_pd_schet(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

***** 20.03.13
Function f1_view_rpd_pd_schet(nk,ob,regim)
Local ret := -1, rec
if regim == "edit" .and. nk == K_ENTER
  rec := rpds->(recno())
  view_rpd_pd_schet_human(rpds->kod_rpds,round(schet->SUMMA,2)==round(rpds->S_SCH,2))
  close databases
  //
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"schet",,"SCHET")
  R_Use(dir_server+"mo_rpds",cur_dir+"tmp_rpds","RPDS")
  set relation to schet into SCHET, to schet into SCHET_
  goto (rec)
  ret := 0
endif
return ret

*

***** 20.03.13
Function view_rpd_pd_schet_human(lkod_rpds,is_equal)
Local blk, t_arr[BR_LEN]
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
G_Use(dir_server+"mo_rpdsh",,"rpdSH")
set relation to KOD_H into HUMAN
if is_equal
  index on str(kod_h,7) to (cur_dir+"tmp_rpdsh1") for kod_rpds == lkod_rpds
else
  index on str(kod_h,7) to (cur_dir+"tmp_rpdsh1")
endif
index on str(human_->SCHET_ZAP,6) to (cur_dir+"tmp_rpdsh") for kod_rpds == lkod_rpds
set index to (cur_dir+"tmp_rpdsh"),(cur_dir+"tmp_rpdsh1")
go top
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := 23
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := 79
t_arr[BR_TITUL] := "Счёт № "+alltrim(schet_->nschet)+" от "+;
                   date_8(schet_->dschet)+" "+f4_view_list_schet()
t_arr[BR_TITUL_COLOR] := "B/W*"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(round(human->cena_1,2)==round(rpdsh->S_SL,2), {1,2}, {3,4}) }
t_arr[BR_COLUMN] := {{ " №№;случ", {|| str(human_->SCHET_ZAP,4) }, blk },;
                     { " Ф.И.О.", {|| padr(human->fio,38) }, blk },;
                     { "Дата рожд.", {|| full_date(human->date_r) }, blk },;
                     { " Стоимость", {|| put_kop(human->cena_1,10) }, blk },;
                     { " Оплачено", {|| put_kop(rpdsh->s_sl,10) }, blk },;
                     { " ", {|| f1_view_rpd_pd_schet_human(1) }, blk }}
t_arr[BR_EDIT] := {|nk| f1_view_rpd_pd_schet_human(2,nk,"edit") }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - просмотр оплат случая") }
edit_browse(t_arr)
return NIL

***** 20.03.13
Function f1_view_rpd_pd_schet_human(par,nk,regim)
Local ret := -1, c := " ", rec, lkod, sumr := 0, i, n, r1, r2, ar := {}, buf
if par == 2 .and. !(regim == "edit" .and. nk == K_ENTER)
  return ret
endif
if !(round(human->cena_1,2)==round(rpdsh->S_SL,2))
  rec := rpdsh->(recno())
  lkod := rpdsh->kod_h
  if par == 2
    if select("RPDS") == 0
      R_Use(dir_server+"mo_rpds",,"RPDS")
    else
      select RPDS
      set index to
    endif
    if select("RPD") == 0
      R_Use(dir_server+"mo_rpd",,"RPD")
    else
      select RPD
      set index to
    endif
  endif
  i := 0
  select RPDSH
  set order to 2
  find (str(lkod,7))
  do while lkod == rpdsh->kod_h .and. !eof()
    ++i
    if i > 1
      c := "+"
    endif
    sumr += rpdsh->s_sl
    if par == 2
      rpds->(dbGoto(rpdsh->kod_rpds))
      rpd->(dbGoto(rpds->pd))
      aadd(ar,{alltrim(rpd->n_pd),rpd->d_pd,rpdsh->s_sl})
    endif
    select RPDSH
    skip
  enddo
  asort(ar,,,{|x,y| x[2] < y[2] })
  for i := 1 to len(ar)
    ar[i] := str(ar[i,3],10,2)+" - пл.№ "+ar[i,1]+" от "+date_8(ar[i,2])
  next
  select RPDSH
  set order to 1
  goto (rec)
  if round(human->cena_1,2)==round(sumr,2)
    aadd(ar,"      =    - случай оплачен")
    c := "="
  else
    aadd(ar,str(human->cena_1-sumr,10,2)+" - недооплачено")
  endif
  if par == 2
    n := 0 ; aeval(ar, {|x| n := max(n,len(x)) })
    if row() > 13
      r2 := row()-1
      r1 := r2 - len(ar) - 1
    else
      r1 := row()+1
      r2 := r1 + len(ar) + 1
    endif
    buf := box_shadow(r1,77-3-n,r2,77,color5,"Оплата случая","B/W*")
    for i := 1 to len(ar)
      @ r1+i,77-1-n say ar[i] color color5
    next
    mybell()
    inkey(0)
    rest_box(buf)
  endif
  ret := 0
endif
return iif(par==1, c, ret)

*

***** 15.12.13
Function ret_menu_rpd_schet(r,c)
Static si := 4,;
       arr := {{"по дате отчётного периода",1},;
               {"по дате выписки счёта",2},;
               {"по дате регистрации счёта",3},;
               {"по дате платёжного документа",4},;
               {"по дате РеестраПлатёжныхДокументов",5}}
Local i, ret, ret_arr
DEFAULT r TO T_ROW, c TO T_COL-5
if popup_2array(arr,r,c,si,1,@ret_arr) > 0 .and. valtype(ret_arr) == "A"
  si := ret_arr[2]
  ret := {ret_arr[2],ret_arr[1]}
endif
return ret

***** 16.12.13 список платёжных поручений
Function i_list_of_pd()
Local buf := save_maxrow(), lsmo := {}, arr_smo, lmenu, i, j, k, s, t_arr[2], ;
      fl, arr_m, name_file := "spis_pd", sh := 80, HH := 60
if (lmenu := ret_menu_rpd_schet()) == NIL
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if lmenu[1] == 1 .and. !is_otch_period(arr_m)
  return NIL
endif
mywait()
dbcreate(cur_dir+"tmp",{;
  {"tip","N",1,0},;
  {"rec","N",7,0},;
  {"rec_up","N",7,0},;
  {"plat","C",5,0},;
  {"summa","N",15,2}})
use (cur_dir+"tmp") new
index on str(tip,1)+str(rec,7) to (cur_dir+"tmp")
dbcreate(cur_dir+"tmp1",{;
  {"tip","N",1,0},;
  {"rec","N",7,0},;
  {"bukva","C",1,0},;
  {"summa","N",15,2}})
use (cur_dir+"tmp1") new
index on str(tip,1)+str(rec,7)+bukva to (cur_dir+"tmp1")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
R_Use(dir_server+"mo_rpdsh",,"RPDSH")
index on str(KOD_RPDS,6) to (cur_dir+"tmprpdsh")
R_Use(dir_server+"mo_rpds",,"RPDS")
index on str(PD,6) to (cur_dir+"tmprpds")
R_Use(dir_server+"mo_rpd",,"RPD")
index on str(kod_xml,6) to (cur_dir+"tmprpd")
R_Use(dir_server+"mo_xml",,"MO_XML")
index on dfile to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_RPD
go top
do while !eof()
  @ maxrow(),0 say date_8(mo_xml->DFILE) color cColorWait
  if iif(lmenu[1] == 5, between(mo_xml->DFILE,arr_m[5],arr_m[6]), .t.)
    select RPD
    find (str(mo_xml->kod,6))
    do while mo_xml->kod == rpd->kod_xml .and. !eof()
      if iif(lmenu[1] == 4, between(rpd->D_PD,arr_m[5],arr_m[6]), .t.)
        select RPDS
        find (str(rpd->pd,6))
        do while rpd->pd == rpds->pd .and. !eof()
          schet->(dbGoto(rpds->schet))
          fl := .t.
          if lmenu[1] == 1
            fl := between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
          elseif lmenu[1] == 2
            fl := between(schet_->dschet,arr_m[5],arr_m[6])
          elseif lmenu[1] == 3
            fl := (schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_m[5],arr_m[6]))
          endif
          if fl
            if ascan(lsmo,rpds->plat) == 0
              aadd(lsmo,rpds->plat)
            endif
            arr := {{1,0},;
                    {mo_xml->kod,1},;
                    {rpd->pd,2},;
                    {rpds->KOD_RPDS,3};
                   }
            for i := 1 to len(arr)
              select TMP
              find (str(arr[i,2],1)+str(arr[i,1],7))
              if !found()
                append blank
                tmp->tip := arr[i,2]
                tmp->rec := arr[i,1]
                if i > 1
                  tmp->rec_up := arr[i-1,1]
                endif
                tmp->plat := rpds->plat
              endif
              tmp->summa += rpds->S_SCH
              select TMP1
              find (str(arr[i,2],1)+str(arr[i,1],7)+schet_->BUKVA)
              if !found()
                append blank
                tmp1->tip := arr[i,2]
                tmp1->rec := arr[i,1]
                tmp1->bukva := schet_->BUKVA
              endif
              tmp1->summa += rpds->S_SCH
            next
            select RPDSH
            find (str(rpds->kod_rpds,6))
            do while rpds->kod_rpds == rpdsh->kod_rpds .and. !eof()
              select TMP
              find (str(4,1)+str(rpdsh->KOD_H,7))
              if !found()
                append blank
                tmp->tip := 4
                tmp->rec := rpdsh->KOD_H
                tmp->rec_up := rpds->KOD_RPDS
                tmp->plat := rpds->plat
              endif
              tmp->summa += rpdsh->S_SL
              select RPDSH
              skip
            enddo
          endif
          select RPDS
          skip
        enddo
      endif
      select RPD
      skip
    enddo
  endif
  select MO_XML
  skip
enddo
arr_bukva := {}
select TMP1
find (str(0,1))
do while tmp1->tip == 0 .and. !eof()
  if !empty(bukva) .and. ascan(arr_bukva,{|x| x[2] == tmp1->bukva}) == 0 ;
                 .and. (j := ascan(mm_bukva,{|x| x[2] == tmp1->bukva})) > 0
    aadd(arr_bukva,{mm_bukva[j,1],mm_bukva[j,2],0})
  endif
  skip
enddo
close databases
arr_smo := {}
for i := 1 to len(glob_arr_smo)
  if ascan(lsmo, {|x| int(val(x)) == glob_arr_smo[i,2] }) > 0
    aadd(arr_smo,glob_arr_smo[i])
  endif
next
rest_box(buf)
if empty(arr_smo)
  return func_error(4,"Нет информации!")
endif
ireg := 1
do while .t.
  mybell(1,OK)
  keyboard ""
  if len(arr_smo) == 1
    lsmo := aclone(arr_smo)
  elseif (lsmo := bit_popup(T_ROW,T_COL-5,arr_smo)) == NIL
    exit
  endif
  if len(arr_bukva) == 1
    lbukva := aclone(arr_bukva)
  elseif (lbukva := bit_popup(T_ROW,T_COL-5,arr_bukva)) == NIL
    exit
  endif
  aeval(lbukva, {|x,i| lbukva[i,3] := 0 })
  mas_pmt := {;
    "Реестры Платёжных Документов",;
    "РПД + Платёжные Документы",;
    "РПД + ПД + счёта",;
    "РПД + ПД + счёта + пациенты";
   }
  if (ireg := popup_prompt(T_ROW,T_COL-5,ireg,mas_pmt)) == 0
    exit
  endif
  n_file := name_file+lstr(ireg)+stxt
  mywait()
  fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
  add_string(padr(glob_mo[_MO_SHORT_NAME],sh-14)+date_8(sys_date)+" "+hour_min(seconds()))
  add_string("")
  add_string(center("Платёжные поручения",sh))
  add_string(center(arr_m[4],sh))
  add_string(center("[ "+lmenu[2]+" ]",sh))
  if len(lsmo) < len(arr_smo)
    s := ""
    aeval(lsmo, {|x| s += x[1]+", " })
    add_string(center("СМО: "+left(s,len(s)-2),sh))
  endif
  if len(lbukva) < len(arr_bukva)
    s := ""
    aeval(lbukva, {|x| s += x[2]+", " })
    add_string(center("Типы счетов: "+left(s,len(s)-2),sh))
  endif
  add_string("")
  sv := 0
  do case
    case ireg == 1
      arr_title := {;
"───────────────┬──────────────────────────┬─────────────────────────────────────",;
"     Сумма     │  Наименование файла РПД  │   дата                              ",;
"───────────────┴──────────────────────────┴─────────────────────────────────────"}
      aeval(arr_title, {|x| add_string(x) } )
      R_Use(dir_server+"mo_xml",,"MO_XML")
      use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
      use (cur_dir+"tmp") new
      set relation to rec into MO_XML
      index on dtos(mo_xml->DFILE)+mo_xml->FNAME to (cur_dir+"tmp_") for tip == 1
      go top
      do while !eof()
        if ascan(lsmo, {|x| int(val(tmp->plat)) == x[2] }) > 0
          v := 0 ; arr := {}
          select TMP1
          find (str(1,1)+str(tmp->rec,7))
          do while tmp1->tip==1 .and. tmp1->rec==tmp->rec .and. !eof()
            if (j := ascan(lbukva, {|x| tmp1->bukva == x[2] })) > 0
              v += tmp1->summa
              aadd(arr,str(tmp1->summa,16,2)+" "+lbukva[j,1])
              lbukva[j,3] += tmp1->summa
            endif
            skip
          enddo
          if !empty(v)
            sv += v
            if verify_FF(HH-2-len(arr),.t.,sh)
              aeval(arr_title, {|x| add_string(x) } )
            endif
            add_string(str(v,15,2)+" "+padr(mo_xml->FNAME,27)+full_date(mo_xml->DFILE))
            add_string(replicate("-",sh))
            aeval(arr,{|x| add_string(x) })
            add_string(replicate("-",sh))
          endif
        endif
        select TMP
        skip
      enddo
    case ireg == 2
      arr_title := {;
"───────────────┬──────────────────────────┬─────────────────────────────────────",;
"     Сумма     │  Номер платёжного док-та │   дата                              ",;
"───────────────┴──────────────────────────┴─────────────────────────────────────"}
      aeval(arr_title, {|x| add_string(x) } )
      R_Use(dir_server+"mo_rpd",,"RPD")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
      use (cur_dir+"tmp") new
      set relation to rec into MO_XML, to rec into RPD
      index on dtos(mo_xml->DFILE)+mo_xml->FNAME to (cur_dir+"tmp_") for tip == 1
      index on str(rec_up,7)+dtos(rpd->D_PD)+rpd->N_PD to (cur_dir+"tmp2_") for tip == 2
      set index to (cur_dir+"tmp_"),(cur_dir+"tmp2_")
      set order to 1
      go top
      do while !eof()
        if ascan(lsmo, {|x| int(val(tmp->plat)) == x[2] }) > 0
          s_xml := padl(" РПД:",15,"=")+" "+alltrim(mo_xml->FNAME)+" от "+full_date(mo_xml->DFILE)
          rec_tmp := tmp->(recno())
          lrec := tmp->rec
          select TMP
          set order to 2
          find (str(lrec,7))
          do while lrec == tmp->rec_up .and. !eof()
            v := 0 ; arr := {}
            select TMP1
            find (str(2,1)+str(tmp->rec,7))
            do while tmp1->tip==2 .and. tmp1->rec==tmp->rec .and. !eof()
              if (j := ascan(lbukva, {|x| tmp1->bukva == x[2] })) > 0
                v += tmp1->summa
                aadd(arr,str(tmp1->summa,16,2)+" "+lbukva[j,1])
                lbukva[j,3] += tmp1->summa
              endif
              skip
            enddo
            if !empty(v)
              if !empty(s_xml)
                add_string(s_xml)
                add_string(replicate("-",sh))
                s_xml := ""
              endif
              sv += v
              if verify_FF(HH-2-len(arr),.t.,sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              add_string(str(v,15,2)+" "+padr(rpd->N_PD,27)+full_date(rpd->D_PD))
              add_string(replicate("-",sh))
              aeval(arr,{|x| add_string(x) })
              add_string(replicate("-",sh))
            endif
            select TMP
            skip
          enddo
          select TMP
          set order to 1
          goto (rec_tmp)
        endif
        select TMP
        skip
      enddo
    case ireg == 3
      arr_title := {;
"───────────────┬───────────────┬──────────┬─────────────────────────────────────",;
"     Сумма     │ Номер счёта   │дата счёта│дата регистрации                     ",;
"───────────────┴───────────────┴──────────┴─────────────────────────────────────"}
      aeval(arr_title, {|x| add_string(x) } )
      R_Use(dir_server+"schet_",,"SCHET_")
      R_Use(dir_server+"mo_rpds",,"RPDS")
      set relation to schet into SCHET_
      R_Use(dir_server+"mo_rpd",,"RPD")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
      use (cur_dir+"tmp") new
      set relation to rec into MO_XML, to rec into RPD, to rec into RPDS
      index on dtos(mo_xml->DFILE)+mo_xml->FNAME to (cur_dir+"tmp_") for tip == 1
      index on str(rec_up,7)+dtos(rpd->D_PD)+rpd->N_PD to (cur_dir+"tmp2_") for tip == 2
      index on str(rec_up,7)+dtos(schet_->DSCHET)+schet_->NSCHET to (cur_dir+"tmp3_") for tip == 3
      set index to (cur_dir+"tmp_"),(cur_dir+"tmp2_"),(cur_dir+"tmp3_")
      set order to 1
      go top
      do while !eof()
        if ascan(lsmo, {|x| int(val(tmp->plat)) == x[2] }) > 0
          s_xml := padl(" РПД:",15,"=")+" "+alltrim(mo_xml->FNAME)+" от "+full_date(mo_xml->DFILE)
          rec_tmp := tmp->(recno())
          lrec := tmp->rec
          select TMP
          set order to 2
          find (str(lrec,7))
          do while lrec == tmp->rec_up .and. !eof()
            s_pd := " "+padl(" ПД:",14,">")+" "+alltrim(rpd->N_PD)+" от "+full_date(rpd->D_PD)
            rec_tmp2 := tmp->(recno())
            lrec2 := tmp->rec
            v := 0 ; arr := {}
            select TMP
            set order to 3
            find (str(lrec2,7))
            do while lrec2 == tmp->rec_up .and. !eof()
              if (j := ascan(lbukva, {|x| schet_->bukva == x[2] })) > 0
                v += tmp->summa
                aadd(arr,str(tmp->summa,15,2)+" "+;
                         padr(schet_->NSCHET,16)+full_date(schet_->DSCHET)+" "+;
                         iif(schet_->NREGISTR==0, full_date(date_reg_schet()), "") )
                lbukva[j,3] += tmp->summa
              endif
              skip
            enddo
            if !empty(v)
              if !empty(s_xml)
                add_string(s_xml)
                add_string(replicate("-",sh))
                s_xml := ""
              endif
              if !empty(s_pd)
                add_string(s_pd)
                add_string(replicate("-",sh))
                s_pd := ""
              endif
              sv += v
              if verify_FF(HH-len(arr),.t.,sh)
                aeval(arr_title, {|x| add_string(x) } )
              endif
              aeval(arr,{|x| add_string(x) })
              add_string(replicate("-",sh))
            endif
            select TMP
            set order to 2
            goto (rec_tmp2)
            skip
          enddo
          select TMP
          set order to 1
          goto (rec_tmp)
        endif
        select TMP
        skip
      enddo
    case ireg == 4
      arr_title := {;
"───────────┬────────────┬───────────────────────────────────────────────────────",;
"   Оплата  │Сумма случая│ № в счёте, ФИО пациента, отд., сроки лечения          ",;
"───────────┴────────────┴───────────────────────────────────────────────────────"}
      aeval(arr_title, {|x| add_string(x) } )
      R_Use(dir_server+"mo_otd",,"OTD")
      R_Use(dir_server+"human_",,"HUMAN_")
      R_Use(dir_server+"human",,"HUMAN")
      set relation to recno() into HUMAN_, to otd into OTD
      R_Use(dir_server+"schet_",,"SCHET_")
      R_Use(dir_server+"mo_rpds",,"RPDS")
      set relation to schet into SCHET_
      R_Use(dir_server+"mo_rpd",,"RPD")
      R_Use(dir_server+"mo_xml",,"MO_XML")
      use (cur_dir+"tmp1") index (cur_dir+"tmp1") new
      use (cur_dir+"tmp") new
      set relation to rec into MO_XML, to rec into RPD, to rec into RPDS, to rec into HUMAN
      index on dtos(mo_xml->DFILE)+mo_xml->FNAME to (cur_dir+"tmp_") for tip == 1
      index on str(rec_up,7)+dtos(rpd->D_PD)+rpd->N_PD to (cur_dir+"tmp2_") for tip == 2
      index on str(rec_up,7)+dtos(schet_->DSCHET)+schet_->NSCHET to (cur_dir+"tmp3_") for tip == 3
      index on str(rec_up,7)+str(human_->SCHET_ZAP,6) to (cur_dir+"tmp4_") for tip == 4
      set index to (cur_dir+"tmp_"),(cur_dir+"tmp2_"),(cur_dir+"tmp3_"),(cur_dir+"tmp4_")
      set order to 1
      go top
      do while !eof()
        if ascan(lsmo, {|x| int(val(tmp->plat)) == x[2] }) > 0
          s_xml := padl(" РПД:",15,"=")+" "+alltrim(mo_xml->FNAME)+" от "+full_date(mo_xml->DFILE)
          rec_tmp := tmp->(recno())
          lrec := tmp->rec
          select TMP
          set order to 2
          find (str(lrec,7))
          do while lrec == tmp->rec_up .and. !eof()
            s_pd := " "+padl(" ПД:",14,">")+" "+alltrim(rpd->N_PD)+" от "+full_date(rpd->D_PD)
            rec_tmp2 := tmp->(recno())
            lrec2 := tmp->rec
            select TMP
            set order to 3
            find (str(lrec2,7))
            do while lrec2 == tmp->rec_up .and. !eof()
              if (j := ascan(lbukva, {|x| schet_->bukva == x[2] })) > 0
                s_schet := "  "+padl(" счёт:",13,"<")+" "+;
                           alltrim(schet_->NSCHET)+" "+full_date(schet_->DSCHET)+;
                           iif(schet_->NREGISTR==0, " (рег."+full_date(date_reg_schet())+")", "")
                rec_tmp3 := tmp->(recno())
                lrec3 := tmp->rec
                select TMP
                set order to 4
                find (str(lrec3,7))
                do while lrec3 == tmp->rec_up .and. !eof()
                  if verify_FF(HH-6,.t.,sh)
                    aeval(arr_title, {|x| add_string(x) } )
                  endif
                  if !empty(s_xml)
                    add_string(s_xml)
                    add_string(replicate("-",sh))
                  endif
                  if !empty(s_pd)
                    add_string(s_pd)
                    add_string(replicate("-",sh))
                  endif
                  if !empty(s_schet)
                    add_string(s_schet)
                    add_string(replicate("-",sh))
                  endif
                  s_xml := s_pd := s_schet := ""
                  sv += tmp->summa
                  if round(tmp->summa,2) < round(human->cena_1,2)
                    s := " <"
                  elseif round(tmp->summa,2) > round(human->cena_1,2)
                    s := " >"
                  else
                    s := " ="
                  endif
                  add_string(str(tmp->summa,11,2)+s+str(human->cena_1,11,2)+" "+;
                             lstr(human_->SCHET_ZAP)+". "+alltrim(human->fio)+" "+;
                             iif(empty(otd->SHORT_NAME), "", "["+alltrim(otd->SHORT_NAME)+"] ")+;
                             date_8(human->n_data)+"-"+date_8(human->k_data))
                  lbukva[j,3] += tmp->summa
                  select TMP
                  skip
                enddo
                add_string(replicate("-",sh))
                select TMP
                set order to 3
                goto (rec_tmp3)
              endif
              select TMP
              skip
            enddo
            select TMP
            set order to 2
            goto (rec_tmp2)
            skip
          enddo
          select TMP
          set order to 1
          goto (rec_tmp)
        endif
        select TMP
        skip
      enddo
  endcase
  if !empty(sv)
    arr := {}
    aeval(lbukva, {|x| iif(empty(x[3]),,aadd(arr,str(x[3],16,2)+" "+x[1])) })
    if verify_FF(HH-2-len(arr),.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(str(sv,15,2)+" И_Т_О_Г_О")
    add_string(replicate("-",sh))
    aeval(arr,{|x| add_string(x) })
    add_string(replicate("-",sh))
  endif
  fclose(fp)
  close databases
  rest_box(buf)
  viewtext(n_file,,,,.t.,,,2)
enddo
return NIL

***** 14.09.21 вернуть вид экспертизы
Function ret_vid_eks()
Local i
if rak->TYPEK > 0
  i := rak->SKONT // до 2019 года
elseif rak->kont < 4    // далее работаем по F006
  i := rak->kont-1    // 1,2,3
elseif rak->kont < 20
  i := 0 // МЭК
elseif rak->kont < 30
  i := 1 // МЭЭ
elseif rak->kont < 50
  i := 2 // ЭКМП
elseif rak->kont < 70  //c 25.05.2021 МЭЭ
  i := 1 // МЭЭ
else      //  c 25.05.2021  до 86
  i := 2 // ЭКМП
endif
return i

** 28.06.22 Акты сверки по СМО
Function akt_sverki_smo()
Static sitog := {;
  "2. Общая сумма средств на оплату по зарег.счетам за месяц",;
  "3. Сумма средств, удержанных по результатам контроля",;
  " 3.1. по результатам МЭК",;
  " 3.2. по результатам МЭЭ",;
  " 3.3. по результатам ЭКМП",;
  "5. Перечисленная сумма средств",;
  "      кроме того, сумма штрафов"}
Local buf := save_maxrow(), lsmo, i, j, k, s, aitog[2,7], hitog[2,7], ismo, vid_eks,;
      b1, b2, a1, a2, name_file := "aktsver", sh := 80, HH := 60, is_smp := {.f.,.f.},;
      mas_txt[30], k_txt := 0, ii
if (lsmo := ret_actual_smo()) == NIL
  return NIL
endif
if (arr_m := year_month(,,,3)) == NIL
  return NIL
endif
mywait()
ret_days_for_akt_sverki(arr_m,@b1,@b2,@a1,@a2)
adbf := {{"tip","N",1,0},;
         {"nomer","N",1,0},;
         {"ndoc","C",25,0},;
         {"ddoc","D",8,0},;
         {"nsch","C",15,0},;
         {"dsch","D",8,0},;
         {"summa","N",15,2}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
afillall(aitog,0)
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
go top
do while !eof()
  if schet_->IS_DOPLATA==0 .and. schet_->smo == lsmo[1] .and. schet_->NREGISTR == 0 // только зарегистрированные
    ismo := int(val(schet_->smo))
    @ maxrow(),0 say padr("№ "+alltrim(schet_->NSCHET)+" от "+date_8(schet_->DSCHET),28) color cColorWait
    mdate := date_reg_schet() // дата регистрации
    if between(mdate,arr_m[5]+iif(ismo==34,0,b1),arr_m[6]+iif(ismo==34,0,b2))
      ltip := iif(schet_->BUKVA == "E", 2, 1)
      is_smp[ltip] := .t.
      aitog[ltip,1] += schet->SUMMA
      select TMP
      append blank
      tmp->tip := ltip
      tmp->nomer := 1
      tmp->nsch := schet_->NSCHET
      tmp->dsch := schet_->DSCHET
      tmp->summa := schet->SUMMA
    endif
  endif
  select SCHET
  skip
enddo
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to KOD_H into HUMAN
index on str(kod_raks,6) to (cur_dir+"tmp_raksh") for !emptyall(SANK_MEK,SANK_MEE,SANK_EKMP,PENALTY)
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to schet into SCHET
index on str(akt,6) to (cur_dir+"tmpraks") for plat == lsmo[1]
R_Use(dir_server+"mo_rak",,"RAK")
index on str(kod_xml,6) to (cur_dir+"tmprak") //for between(dakt,arr_m[5],arr_m[6])
R_Use(dir_server+"mo_xml",,"MO_XML")
if ismo == 34
  index on dfile to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_RAK .and. between(dfile,arr_m[5],arr_m[6])
else
  index on dfile to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_RAK .and. between(dfile,arr_m[5]+a1,arr_m[6]+a2)
endif
go top
do while !eof()
  select RAK
  find (str(mo_xml->kod,6))
  do while mo_xml->kod == rak->kod_xml .and. !eof()
    vid_eks := ret_vid_eks()
    select RAKS
    find (str(rak->akt,6))
    do while rak->akt == raks->akt .and. !eof()
      ltip := iif(schet_->BUKVA == "E", 2, 1)
      s := raks->SANK_MEK+raks->SANK_MEE+raks->SANK_EKMP
      if !emptyall(s,raks->PENALTY)
        is_smp[ltip] := .t.
        if vid_eks == 2 .or. !empty(raks->SANK_EKMP)
          s := f1akt_sverki_smo(5,s,hitog)
          aitog[ltip,5] += s
        elseif vid_eks == 1 .or. !empty(raks->SANK_MEE)
          s := f1akt_sverki_smo(4,s,hitog)
          aitog[ltip,4] += s
        else
          s := f1akt_sverki_smo(3,s,hitog)
          aitog[ltip,3] += s
        endif
        aitog[ltip,2] += s
        //
        s := f1akt_sverki_smo(7,raks->PENALTY,hitog)
        aitog[ltip,7] += s
      endif
      select RAKS
      skip
    enddo
    select RAK
    skip
  enddo
  select MO_XML
  skip
enddo
select RAKS
set relation to
R_Use(dir_server+"mo_rpds",,"RPDS")
set relation to schet into SCHET
index on str(PD,6) to (cur_dir+"tmprpds") for plat == lsmo[1]
R_Use(dir_server+"mo_rpd",,"RPD")
index on str(kod_xml,6) to (cur_dir+"tmprpd") //for between(d_pd,arr_m[5],arr_m[6])
select MO_XML
if ismo == 34
  index on dfile to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_RPD .and. between(dfile,arr_m[5],arr_m[6])
else
  index on dfile to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_RPD .and. between(dfile,arr_m[5]+a1,arr_m[6]+a2)
endif
go top
do while !eof()
  select RPD
  find (str(mo_xml->kod,6))
  do while mo_xml->kod == rpd->kod_xml .and. !eof()
    select RPDS
    find (str(rpd->pd,6))
    do while rpd->pd == rpds->pd .and. !eof()
      ltip := iif(schet_->BUKVA == "E", 2, 1)
      is_smp[ltip] := .t.
      aitog[ltip,6] += rpds->S_SCH
      select TMP
      append blank
      tmp->tip := ltip
      tmp->nomer := 6
      tmp->ndoc := rpd->N_PD
      tmp->ddoc := rpd->D_PD
      tmp->nsch := schet_->NSCHET
      tmp->dsch := schet_->DSCHET
      tmp->summa := rpds->S_SCH
      select RPDS
      skip
    enddo
    select RPD
    skip
  enddo
  select MO_XML
  skip
enddo
close databases
//
mas_pmt := {"Распечатка акта сверки"}
if is_smp[1]
  aadd(mas_pmt,"Протокол акта сверки")
endif
if is_smp[2]
  aadd(mas_pmt,"Протокол акта сверки для СМП")
endif
rest_box(buf)
if (ireg := popup_prompt(T_ROW,T_COL-5,1,mas_pmt)) == 0
  return NIL
endif
if ireg == 2
  name_file += "p"
elseif ireg == 3
  name_file += "s"
endif
mywait()
fp := fcreate(name_file+stxt) ; n_list := 1 ; tek_stroke := 0
add_string(glob_mo[_MO_SHORT_NAME])
if ireg == 1
  for i := 1 to 2
    if is_smp[i]
      add_string("")
      if i == 1
        add_string(center("Акт сверки (за вычетом СМП)",sh))
      else
        add_string(center("Акт сверки (СМП)",sh))
      endif
      add_string(center(lsmo[2],sh))
      add_string(center("по состоянию на "+date_month(arr_m[6]+1,.t.),sh))
      add_string("")
      for j := 1 to 6
        add_string(padr(sitog[j],sh-15)+str(aitog[i,j],15,2))
        if j == 5 .and. !empty(aitog[i,7])
          add_string(padr(sitog[7],sh-15)+str(aitog[i,7],15,2))
        endif
      next
    endif
  next
else
  use (cur_dir+"tmp") new
  index on str(tip,1)+str(nomer,1)+dtos(dsch)+nsch to (cur_dir+"tmp")
  arr_title := {;
"───────────────┬────────────────────────┬───────────────────────────────────────",;
"     Сумма     │   Номер и дата счёта   │№ и дата акта контроля (плат.документа)",;
"───────────────┴────────────────────────┴───────────────────────────────────────"}
  add_string("")
  if ireg == 2
    add_string(center("Протокол акта сверки (за вычетом СМП)",sh))
  else
    add_string(center("Протокол акта сверки (СМП)",sh))
  endif
  add_string(center(lsmo[2],sh))
  add_string(center("по состоянию на "+date_month(arr_m[6]+1,.t.),sh))
  add_string("")
  aeval(arr_title, {|x| add_string(x) } )
  for k := 1 to 7
    if k == 6
      j := 7
    elseif k == 7
      j := 6
    else
      j := k
    endif
    if verify_FF(HH-3,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    if j > 1 .and. skol > 0
      add_string(replicate("-",sh))
    endif
    skol := 0
    add_string(str(aitog[ireg-1,j],15,2)+" "+sitog[j])
    add_string(replicate("-",sh))
    if eq_any(j,3,4,5,7) .and. valtype(hitog[ireg-1,j]) == "A"
      asort(hitog[ireg-1,j],,,{|x,y| x[1] < y[1] })
      for j1 := 1 to len(hitog[ireg-1,j])
        if verify_FF(HH,.t.,sh)
          aeval(arr_title, {|x| add_string(x) } )
        endif
        k_txt := perenos(mas_txt,alltrim(ret_t005_smol(hitog[ireg-1,j,j1,1])),38)
        add_string(str(hitog[ireg-1,j,j1,2],15,2)+;
                   " ("+lstr(hitog[ireg-1,j,j1,3])+" л/у) "+;
                    mas_txt[1])
        for ii := 2 to k_txt
          add_string(space(42)+mas_txt[ii])
        next  
      next
      add_string(replicate("-",sh))
    endif
    find (str(ireg-1,1)+str(j,1))
    do while tmp->tip == ireg-1 .and. tmp->nomer == j .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      s := str(tmp->summa,15,2)+" "+tmp->nsch+" "+date_8(tmp->dsch)+"  "
      if !empty(tmp->ndoc)
        s += alltrim(tmp->ndoc)+" "
      endif
      if !empty(tmp->ddoc)
        s += "от "+date_8(tmp->ddoc)
      endif
      ++skol
      add_string(s)
      skip
    enddo
  next k
endif
close databases
fclose(fp)
rest_box(buf)
viewtext(name_file+stxt,,,,.t.,,,2)
return NIL

***** 14.02.19
Function f1akt_sverki_smo(k,s,hitog)
Local i, s1
if !empty(s)
  s := 0 // обнуляем, т.к. в РАК на уровне счёта м.б. ошибка
  select RAKSH
  find (str(raks->kod_raks,6))
  do while raks->kod_raks == raksh->kod_raks .and. !eof()
    if k == 7
      s1 := raksh->penalty
    else
      s1 := raksh->SANK_MEK+raksh->SANK_MEE+raksh->SANK_EKMP
    endif
    if !empty(s1)
      if hitog[ltip,k] == NIL
        hitog[ltip,k] := {}
      endif
      if (i := ascan(hitog[ltip,k], {|x| x[1] == raksh->REFREASON})) == 0
        aadd(hitog[ltip,k], {raksh->REFREASON,0,0}) ; i := len(hitog[ltip,k])
      endif
      hitog[ltip,k,i,2] += s1
      hitog[ltip,k,i,3] ++
      s += s1
    endif
    select RAKSH
    skip
  enddo
  if !empty(s)
    select TMP
    append blank
    tmp->tip := ltip
    tmp->nomer := k
    tmp->ndoc := rak->NAKT
    tmp->ddoc := rak->DAKT
    tmp->nsch := schet_->NSCHET
    tmp->dsch := schet_->DSCHET
    tmp->summa := s
  endif
endif
return s

***** 22.12.15 Распечатка информации по выставленным счетам, снятиям по ним, оплате и долге
Function pr1_oborot_schet()
Static arr_smo
Static mm_poisk := {{"по дате отчётного периода",0},;
                    {"по дате выставления счета",1},;
                    {"по дате регистрации счета",2}}
Static mm_dolg := {{"все строки",0},;
                   {"только строки с долгом",1}}
Static mm_schet := {{"итого по СМО",0},;
                    {"итого по учреждениям/отделениям",1},;
                    {"итого по типам счетов",2},;
                    {"отдельно по каждому счёту",3}}
Static s1poisk := 0, s1schet := 3, s1dolg := 0, s1smo := 0, s1bukva := ""
Local buf := savescreen(), i, ar, s, r := 13
if empty(s1bukva)
  s1bukva := ""
  for i := 1 to len(mm_bukva)
    s1bukva += mm_bukva[i,2]
  next
endif
if arr_smo == NIL
  arr_smo := mo_cut_menu(glob_arr_smo)
  for i := 1 to len(arr_smo)
    arr_smo[i,3] := padr(lstr(arr_smo[i,2]),5)
    arr_smo[i,2] := i
  next
endif
if empty(s1smo)
  s1smo := 0
  for i := 1 to len(arr_smo)
    s1smo := setbit(s1smo,arr_smo[i,2])
  next
endif
Private mdate := space(10), m1date := 0,;
        mpoisk, m1poisk := s1poisk,;
        mschet, m1schet := s1schet,;
        msmo, m1smo := s1smo,;
        mdolg, m1dolg := s1dolg,;
        much_otd := space(10), m1uch_otd := 0,;
        mbukva := ini_ed_tip_schet(s1bukva), m1bukva := s1bukva
Private pdate, gl_arr := {;  // для битовых полей
  {"smo","N",10,0,,,,{|x|inieditspr(A__MENUBIT,arr_smo,x)} };
 }
Private pr_a_uch := {}, pr_a_otd := {}
mpoisk := inieditspr(A__MENUVERT, mm_poisk, m1poisk)
mschet := inieditspr(A__MENUVERT, mm_schet, m1schet)
mdolg  := inieditspr(A__MENUVERT, mm_dolg,  m1dolg )
msmo   := inieditspr(A__MENUBIT,  arr_smo,  m1smo  )
setcolor(cDataCGet)
myclear(r)
Private gl_area := {r,1,maxrow()-1,maxcol(),0}, pdate
status_key("^<Esc>^ - выход;  ^<PgDn>^ - составление документа")
//
@ r,0 to maxrow()-1,maxcol() COLOR color8
str_center(r," Снятия, оплата и долги по счетам (подготовка информации) ",color14)
do while .t.
  @ r+2,2 say "Выборка информации" get mpoisk ;
          reader {|x| menu_reader(x,mm_poisk,A__MENUVERT,,,.f.)}
  @ r+3,2 say "Страховая(ые) компания(и)" get msmo ;
          reader {|x| menu_reader(x,arr_smo,A__MENUBIT,,,.f.)}
  @ r+4,2 say "Учреждения/отделения" get much_otd ;
          reader {|x| menu_reader(x,{{|k,r,c| ret_Nuch_Notd(k,r,c) }},A__FUNCTION,,,.f.)}
  @ r+5,2 say "Типы счетов" get mbukva ;
          reader {|x| menu_reader(x,{{|k,r,c| inp_bit_tip_schet(k,r,c) }},A__FUNCTION,,,.f.)}
  @ r+6,2 say "Период времени" get mdate ;
          reader {|x| menu_reader(x,{{|k,r,c| ;
                      k:=year_month(r+1,c),iif(k==nil,nil,(pdate:=aclone(k),k:={k[1],k[4]})),;
                      k }},A__FUNCTION,,,.f.)}
  @ r+7,2 say "Группировка выходной информации" get mschet ;
          reader {|x| menu_reader(x,mm_schet,A__MENUVERT,,,.f.)}
  @ r+8,2 say "Все ли строки выводить" get mdolg ;
          reader {|x| menu_reader(x,mm_dolg,A__MENUVERT,,,.f.)}
  myread()
  if lastkey() == K_ESC
    exit
  endif
  s1smo   := m1smo
  s1schet := m1schet
  s1poisk := m1poisk
  s1dolg  := m1dolg
  s1bukva := m1bukva
  if empty(pdate)
    func_error(4,"Не введён период времени")
  elseif empty(m1smo)
    func_error(4,"Не введена страховая компания")
  elseif empty(m1bukva)
    func_error(4,"Не выбраны типы счетов")
  elseif empty(m1uch_otd)
    func_error(4,"Не выбраны учреждения/отделения")
  elseif m1poisk == 0 .and. !is_otch_period(pdate)
    //
  else
    ar := {} ; s := ""
    for i := 1 to len(arr_smo)
      if isbit(s1smo,i)
        aadd(ar, arr_smo[i,3])
        s += arr_smo[i,1] + ", "
      endif
    next
    s := substr(s,1,len(s)-2)
    f1pr1_oborot_schet(ar,s)
  endif
enddo
restscreen(buf)
return NIL

***** 13.02.19
Function f1pr1_oborot_schet(asmo,ssmo)
Local adbf, i, n, arr_title, n_file := "oborot1"+stxt, sh, HH := 60, buf := save_maxrow()
mywait()
adbf := {{"nschet","C",15,0},;
         {"dschet","D",8,0},;
         {"dregis","D",8,0},;
         {"schet","N",6,0},;
         {"BUKVA","C",1,0},; // буква на конце счета
         {"SMO",  "C",5,0},; // код получателя;реестровый номер СМО или 34 для иногородних;
         {"ot_per","C",4,0},;
         {"uch","N",2,0},;
         {"otd","N",3,0},;
         {"kol","N",6,0},;
         {"kol1","N",6,0},;
         {"summa","N",15,2},;
         {"summa1","N",15,2},;
         {"sum_sn","N",15,2},;
         {"penalty","N",15,2},;
         {"sum_op","N",15,2}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
dbcreate(cur_dir+"tmp1",adbf)
use (cur_dir+"tmp1") new
do case
  case m1schet == 0 // итого по СМО
    index on smo to (cur_dir+"tmp1")
  case m1schet == 1 // итого по учреждениям/отделениям
    index on str(otd,3) to (cur_dir+"tmp1")
  case m1schet == 2 // итого по типам счетов
    index on bukva to (cur_dir+"tmp1")
endcase
Private arr_m := pdate
R_Use(dir_server+"mo_uch",,"UCH")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",dir_server+"humans","HUMAN")
set relation to recno() into HUMAN_
R_Use(dir_server+"mo_raksh",,"RAKSH")
index on str(kod_h,7) to (cur_dir+"tmp_raksh") for !emptyall(SANK_MEK,SANK_MEE,SANK_EKMP)
R_Use(dir_server+"mo_rpdsh",,"RPDSH")
index on str(KOD_H,7) to (cur_dir+"tmprpdsh")
//
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",dir_server+"schetd","SCHET")
set relation to recno() into SCHET_
do case
  case m1poisk == 0 // по дате отчётного периода
    index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
          for schet_->NREGISTR==0 .and. empty(schet_->IS_DOPLATA) .and. ;
              between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
  case m1poisk == 1 // по дате выставления счета
    dbseek(arr_m[7],.t.)
    index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
          for schet_->NREGISTR==0 .and. empty(schet_->IS_DOPLATA) ;
          while pdate <= arr_m[8]
  case m1poisk == 2 // по дате регистрации счета
    index on pdate+fsort_schet(schet_->nschet,nomer_s) to (cur_dir+"tmp") ;
          for schet_->NREGISTR==0 .and. empty(schet_->IS_DOPLATA) .and. ;
              between(date_reg_schet(),arr_m[5],arr_m[6])
endcase
go top
do while !eof()
  select TMP
  append blank
  tmp->nschet := schet_->nschet
  tmp->dschet := schet_->dschet
  tmp->dregis := schet_->DREGISTR
  tmp->schet  := schet->kod
  tmp->ot_per := right(str(schet_->NYEAR,4),2)+strzero(schet_->NMONTH,2)
  tmp->BUKVA  := schet_->bukva
  tmp->SMO    := schet_->smo
  tmp->kol    := schet->kol
  tmp->kol1   := 0
  tmp->summa  := schet->summa
  tmp->summa1 := 0
  tmp->sum_sn := 0
  tmp->sum_op := 0
  tmp->penalty:= 0
  if ascan(asmo,schet_->smo) > 0 .and. schet_->bukva $ m1bukva
    select HUMAN
    find (str(schet->kod,6))
    do while schet->kod == human->schet .and. !eof()
      if ascan(pr_a_otd, {|x| x[1] == human->otd }) > 0
        tmp->kol1 ++
        tmp->summa1 += human->cena_1
        if m1schet == 1 // итого по учреждениям/отделениям
          select TMP1
          find (str(human->otd,3))
          if !found()
            append blank
            tmp1->otd := human->otd
            otd->(dbGoto(human->otd))
            tmp1->uch := otd->kod_lpu
          endif
          tmp1->kol1 ++
          tmp1->summa1 += human->cena_1
        endif
        select RAKSH
        find(str(human->kod,7))
        do while raksh->kod_h == human->kod .and. !eof()
          tmp->sum_sn += raksh->SANK_MEK+raksh->SANK_MEE+raksh->SANK_EKMP
          tmp->penalty += raksh->penalty
          if m1schet == 1 // итого по учреждениям/отделениям
            tmp1->sum_sn += raksh->SANK_MEK+raksh->SANK_MEE+raksh->SANK_EKMP
            tmp1->penalty += raksh->penalty
          endif
          select RAKSH
          skip
        enddo
        select RPDSH
        find(str(human->kod,7))
        do while rpdsh->kod_h == human->kod .and. !eof()
          tmp->sum_op += rpdsh->S_SL
          if m1schet == 1 // итого по учреждениям/отделениям
            tmp1->sum_op += rpdsh->S_SL
          endif
          select RPDSH
          skip
        enddo
      endif
      select HUMAN
      skip
    enddo
  endif
  select SCHET
  skip
enddo
Commit
if eq_any(m1schet,0,2)
  select TMP
  go top
  do while !eof()
    if tmp->kol1 > 0
      select TMP1
      if m1schet == 0 // итого по СМО
        find (tmp->smo)
        if !found()
          append blank
          tmp1->smo := tmp->smo
        endif
      else // итого по типам счетов
        find (tmp->bukva)
        if !found()
          append blank
          tmp1->bukva := tmp->bukva
        endif
      endif
      tmp1->kol1   += tmp->kol1
      tmp1->summa1 += tmp->summa1
      tmp1->sum_sn += tmp->sum_sn
      tmp1->sum_op += tmp->sum_op
      tmp1->penalty+= tmp->penalty
    endif
    select TMP
    skip
  enddo
elseif m1schet == 3 // по счетам
  close databases
  copy file tmp.dbf to tmp1.dbf
  use (cur_dir+"tmp1") new
endif
Commit
select TMP1
do case
  case m1schet == 0 // по СМО
    index on smo to (cur_dir+"tmp1")
    n := 25 // glob_arr_smo[i,1]
    arr_title := {;
"_________________________",;
"    Страховая компания   ",;
"_________________________"}
  case m1schet == 1 // по отделениям
    set relation to otd into OTD, to uch into UCH
    index on upper(uch->name)+str(uch,3)+upper(otd->name)+str(otd,3) to (cur_dir+"tmp1")
    n := 31
    arr_title := {;
"_______________________________",;
"    Учреждение/отделение       ",;
"_______________________________"}
  case m1schet == 2 // по типам счетов
    index on bukva to (cur_dir+"tmp1")
    n := 45
    arr_title := {;
"_____________________________________________",;
"   Типы счетов                               ",;
"_____________________________________________"}
  case m1schet == 3 // по счетам
    index on ot_per+smo+nschet+dtos(dschet) to (cur_dir+"tmp1") ;
          for kol1 > 0 .and. iif(m1dolg==0, .t., !empty(summa1-sum_sn-sum_op))
    n := 39
    arr_title := {;
"_______________________________________",;
" Номер счёта   |  Дата  |Дата рег|От/пе",;
"_______________|________|________|_____"}
endcase
arr_title[1] += "_________________________________________________________"
arr_title[2] += "|  выставлено  |   снято   |  оплачено    |    долг      "
arr_title[3] += "|______________|___________|______________|______________"
sh := len(arr_title[1])
//
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(glob_mo[_MO_SHORT_NAME])
add_string("")
add_string(center("Снятия, оплата и долги по счетам"+iif(m1dolg==1.and.m1schet==3," (только строки с долгом)",""),sh))
add_string(center("СМО: "+ssmo,sh))
add_string(center("Учреждения/отделения: "+much_otd,sh))
add_string(center("Типы счетов: "+mbukva,sh))
add_string(center("["+mpoisk+"] "+pdate[4],sh))
aeval(arr_title, {|x| add_string(x) } )
s1 := s2 := s3 := spenalty := 0
do case
  case m1schet == 0 // по СМО
    for i := 1 to len(glob_arr_smo)
      find (padr(lstr(glob_arr_smo[i,2]),5))
      if found()
        add_string(padr(glob_arr_smo[i,1],n)+put_kop(tmp1->summa1,15,2)+;
                   put_kopE(tmp1->sum_sn,12,2)+put_kopE(tmp1->sum_op,15,2)+;
                   put_kopE(tmp1->summa1-tmp1->sum_sn-tmp1->sum_op,15,2))
        s1 += tmp1->summa1
        s2 += tmp1->sum_sn
        s3 += tmp1->sum_op
        if !empty(tmp1->penalty)
          add_string(put_kop(tmp1->penalty,n+15+12,2)+"(штраф)")
          spenalty += tmp1->penalty
        endif
      endif
    next
  case m1schet == 1 // по отделениям
    old_uch := 0
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if old_uch != tmp1->uch
        if old_uch > 0
          add_string("")
        endif
        add_string(upper(uch->name))
        add_string(replicate("═",sh))
        old_uch := tmp1->uch
      endif
      add_string(padr(otd->name,n)+put_kop(tmp1->summa1,15,2)+;
                 put_kopE(tmp1->sum_sn,12,2)+put_kopE(tmp1->sum_op,15,2)+;
                 put_kopE(tmp1->summa1-tmp1->sum_sn-tmp1->sum_op,15,2))
      s1 += tmp1->summa1
      s2 += tmp1->sum_sn
      s3 += tmp1->sum_op
      if !empty(tmp1->penalty)
        add_string(put_kop(tmp1->penalty,n+15+12,2)+"(штраф)")
        spenalty += tmp1->penalty
      endif
      select TMP1
      skip
    enddo
  case m1schet == 2 // по типам счетов
    for i := 1 to len(mm_bukva)
      find (mm_bukva[i,2])
      if found()
        add_string(padr(mm_bukva[i,1],n)+put_kop(tmp1->summa1,15,2)+;
                   put_kopE(tmp1->sum_sn,12,2)+put_kopE(tmp1->sum_op,15,2)+;
                   put_kopE(tmp1->summa1-tmp1->sum_sn-tmp1->sum_op,15,2))
        s1 += tmp1->summa1
        s2 += tmp1->sum_sn
        s3 += tmp1->sum_op
        if !empty(tmp1->penalty)
          add_string(put_kop(tmp1->penalty,n+15+12,2)+"(штраф)")
          spenalty += tmp1->penalty
        endif
      endif
    next
  case m1schet == 3 // по счетам
    go top
    do while !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      add_string(tmp1->nschet+" "+date_8(tmp1->dschet)+" "+date_8(tmp1->dregis)+" "+;
                 left(tmp1->ot_per,2)+"/"+right(tmp1->ot_per,2)+put_kop(tmp1->summa1,15,2)+;
                 put_kopE(tmp1->sum_sn,12,2)+put_kopE(tmp1->sum_op,15,2)+;
                 put_kopE(tmp1->summa1-tmp1->sum_sn-tmp1->sum_op,15,2))
      s1 += tmp1->summa1
      s2 += tmp1->sum_sn
      s3 += tmp1->sum_op
      if !empty(tmp1->penalty)
        add_string(put_kop(tmp1->penalty,n+15+12,2)+"(штраф)")
        spenalty += tmp1->penalty
      endif
      select TMP1
      skip
    enddo
endcase
add_string(replicate("─",sh))
add_string(padc("Итого:",n)+put_kop(s1,15,2)+;
                 put_kopE(s2,12,2)+put_kopE(s3,15,2)+;
                 put_kopE(s1-s2-s3,15,2))
if !empty(spenalty)
  add_string(put_kop(spenalty,n+15+12,2)+"(штраф)")
endif
close databases
fclose(fp)
rest_box(buf)
viewtext(n_file,,,,.t.,,,2)
return NIL

*

***** Составление оборотной ведомости
Function pr2_oborot_schet()
ne_real()
return NIL

*

***** Ввод входящего сальдо для корректного формирования оборотной ведомости
Function saldo_oborot_schet()
ne_real()
return NIL
