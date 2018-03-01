***** mo_omso.prg - работа с оплатой счетов в задаче ОМС (акты контроля)
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "chip_mo.ch"

Static lcount_uch := 1
Static lcount_otd := 1

***** 14.02.17 прочитать и "разнести" по базам данных РАК
Function read_XML_FILE_RAK(arr_XML_info,aerr)
Local fl_akt, fl_schet, blk_akt, blk_schet, i, k, s, s1, arr_s := {}, t_arr[2],;
      ia, is, ih, arr, aakt := {}, no_write := .t.
blk_akt := {|| aadd(aerr,"АКТ № "+alltrim(tmp2->_nakt)+" от "+date_8(tmp2->_dakt)) }
blk_schet := {|| aadd(aerr," СЧЁТ № "+alltrim(tmp3->_nschet)+" от "+date_8(tmp3->_dschet)) }
use (cur_dir+"tmp1file") new alias TMP1
tmp1->_SMO     := arr_XML_info[2]
tmp1->_CODE_MO := arr_XML_info[3]
tmp1->_YEAR    := arr_XML_info[4]
tmp1->_MONTH   := arr_XML_info[5]
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
index on str(kod_a,6) to (cur_dir+"tmp3")
use (cur_dir+"tmp4file") new alias TMP4
index on str(kod_a,6)+str(kod_s,6) to (cur_dir+"tmp4")
// сначала найдём коды счетов и коды листов учёта
G_Use(dir_server+"schet_",,"SCHET_")
index on dtos(dschet)+upper(nschet) to (cur_dir+"tmp_sch_")
R_Use(dir_server+"mo_otd",,"OTD")
G_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
//R_Use(dir_server+"mo_os",,"MO_OS")
//index on str(kod,7) to (cur_dir+"tmp_moos") for NEXT_KOD > 0
ia := is := ih := 0
@ maxrow(),0 say space(maxcol()+1) color "G+/R*"
select TMP2
go top
do while !eof()
  ++ia
  fl_akt := .t. ; arr := {}
  select TMP3
  find (str(tmp2->kod_a,6))
  do while tmp2->kod_a == tmp3->kod_a .and. !eof()
    ++is
    fl_schet := .t.
    select SCHET_
    find (dtos(tmp3->_dschet)+upper(tmp3->_nschet))
    if found()
      no_write := .f.
      aadd(arr,schet_->(recno()))
      tmp3->kod_schet := schet_->(recno())
      if !(tmp3->_PLAT == schet_->smo)
        if fl_akt
          eval(blk_akt) ; fl_akt := .f.
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
      index on str(human_->schet_zap,6) to (cur_dir+"tmp_hum") while schet==tmp3->kod_schet
      select TMP4
      find (str(tmp3->kod_a,6)+str(tmp3->kod_s,6))
      do while tmp3->kod_a == tmp4->kod_a .and. tmp3->kod_s == tmp4->kod_s .and. !eof()
        ++ih
        @ maxrow(),1  say "подготовка: "+lstr(ia) color "G+/R*"
        @ row(),col() say "/"      color "R/R*"
        @ row(),col() say lstr(is) color "GR+/R*"
        @ row(),col() say "/"      color "R/R*"
        @ row(),col() say lstr(ih) color "W+/R*"
        select HUMAN
        find (str(tmp4->_IDCASE,6))
        if found()
          tmp4->KOD_H := human->kod
          if !(upper(tmp4->_ID_C) == upper(human_->ID_C))
            if fl_akt
              eval(blk_akt) ; fl_akt := .f.
            endif
            if fl_schet
              eval(blk_schet) ; fl_schet := .f.
            endif
            aadd(aerr,"  случай № "+lstr(tmp4->_IDCASE)+", "+alltrim(human->fio)+", л/у "+lstr(human->kod))
            aadd(aerr,"   ID_C в СМО = "+tmp4->_ID_C+", ID_C у нас = "+human_->ID_C)
          endif
        else
          if fl_akt
            eval(blk_akt) ; fl_akt := .f.
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
      if fl_akt
        //eval(blk_akt) ; fl_akt := .f.
      endif
      aadd(arr_s,{tmp3->kod_a,tmp3->kod_s,;
                  " Не найден СЧЁТ № "+alltrim(tmp3->_nschet)+" от "+date_8(tmp3->_dschet)})
    endif
    select TMP3
    skip
  enddo
  aadd(aakt,{tmp2->kod_a,arr})
  select TMP2
  skip
enddo
commit
if no_write
  aadd(aerr," Из этого РАК нечего записывать в текущую базу данных")
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
mo_xml->TIP_IN := _XML_FILE_RAK
mo_xml->DWORK  := sys_date
mo_xml->TWORK1 := hour_min(seconds())
mo_xml->TWORK2 := ""
mo_xml->KOL1 := tmp1->KOL_AKT
mo_xml->KOL2 := tmp1->KOL_SCH
rec_xml := mo_xml->KOD
UnLock
Commit
strfile(hb_eol()+;
        "Количество актов - "+lstr(tmp1->KOL_AKT)+hb_eol()+;
        "Количество счетов - "+lstr(tmp1->KOL_SCH)+hb_eol()+;
        "Количество пациентов всего - "+lstr(tmp1->KOL_PAC)+hb_eol()+;
        "  в т.ч. количество снятий - "+lstr(tmp1->KOL_ERR)+hb_eol(),cFileProtokol,.t.)
//
select HUMAN
set index to
G_Use(dir_server+"mo_rak",,"RAK")
set relation to KOD_XML into MO_XML
index on str(akt,6) to (cur_dir+"tmprak")
index on ret_owner_rak(mo_xml->FNAME)+str(year(dakt),4)+upper(padr(nakt,25)) to (cur_dir+"tmprak1")
set index to (cur_dir+"tmprak"),(cur_dir+"tmprak1")
G_Use(dir_server+"mo_raks",,"RAKS")
index on str(akt,6) to (cur_dir+"tmpraks")
G_Use(dir_server+"mo_raksh",,"RAKSH")
index on str(kod_raks,6) to (cur_dir+"tmpraksh")
ia := is := ih := 0
@ maxrow(),0 say space(maxcol()+1) color "G+/R*"
select TMP2
go top
do while !eof()
  ++ia
  s := hb_eol()+"АКТ № "+alltrim(tmp2->_nakt)+" от "+date_8(tmp2->_dakt)
  select RAK
  set order to 2
  find (ret_owner_rak(cReadFile)+str(year(tmp2->_dakt),4)+upper(padr(tmp2->_nakt,25)))
  if found()
    strfile(s+" - дубликат в "+rtrim(mo_xml->FNAME)+hb_eol()+hb_eol(),cFileProtokol,.t.)
  elseif (i := ascan(aakt,{|x| x[1] == tmp2->kod_a })) > 0 .and. empty(aakt[i,2])
    strfile(s+" - не найдено счетов в базе данных"+hb_eol()+hb_eol(),cFileProtokol,.t.)
  else
    s += ", счетов - "+lstr(tmp2->KOL_SCH)+;
         ", пациентов всего - "+lstr(tmp2->KOL_PAC)
    if tmp2->KOL_ERR > 0
      s += ", в т.ч. снятий - "+lstr(tmp2->KOL_ERR)
    endif
    strfile(s+hb_eol(),cFileProtokol,.t.)
    s := ""
    if between(tmp2->_KONT,1,3)
      s += "вид контроля: "+inieditspr(A__MENUVERT,mm_vid_kont,tmp2->_KONT)+", "
    endif
    s += iif(tmp2->_TYPEK==1, "первичный", "повторный")+" контроль"
    if between(tmp2->_SKONT,1,2)
      s += ", вид экспертизы: "+iif(tmp2->_skont==1,"плановая","целевая")
    endif
    strfile(s+hb_eol(),cFileProtokol,.t.)
    select RAK
    set order to 1
    AddRec(6)
    rak->AKT     := recno() // код акта
    rak->KOD_XML := rec_xml
    rak->CODEA   := tmp2->_CODEA
    rak->NAKT    := tmp2->_NAKT
    rak->DAKT    := tmp2->_DAKT
    rak->NSCHET  := ""
    rak->KOL_SCH := tmp2->KOL_SCH
    rak->KOL_PAC := tmp2->KOL_PAC
    rak->KOL_ERR := tmp2->KOL_ERR
    rak->KONT    := tmp2->_KONT
    rak->TYPEK   := tmp2->_TYPEK
    rak->SKONT   := tmp2->_SKONT
    select TMP3
    find (str(tmp2->kod_a,6))
    do while tmp2->kod_a == tmp3->kod_a .and. !eof()
      ++is
      if tmp3->kod_schet == 0
        if (i := ascan(arr_s,{|x| x[1]==tmp3->kod_a .and. x[2]==tmp3->kod_s})) > 0
          strfile(hb_eol()+" "+arr_s[i,3]+hb_eol()+hb_eol(),cFileProtokol,.t.)
        endif
      else
        schet_->(dbGoto(tmp3->kod_schet))
        schet_->(G_RLock(forever))
        schet_->SUMMAP    := tmp3->_SUMMAP
        schet_->SANK_MEK  := tmp3->_SANK_MEK
        schet_->SANK_MEE  := tmp3->_SANK_MEE
        schet_->SANK_EKMP := tmp3->_SANK_EKMP
        if tmp2->KOL_SCH == 1
          rak->NSCHET := schet_->NSCHET
        endif
        //
        s := hb_eol()+;
             "  СЧЁТ № "+alltrim(tmp3->_nschet)+" от "+date_8(tmp3->_dschet)+;
             ", отчётный период - "+strzero(schet_->nyear,4)+"/"+strzero(schet_->nmonth,2)+hb_eol()+;
             "  пациентов всего - "+lstr(tmp3->KOL_PAC)
        if tmp3->KOL_ERR > 0
          s += ", в т.ч. снятий - "+lstr(tmp3->KOL_ERR)
        endif
        s += hb_eol()+;
             "  Выставлено: "+lstr(tmp3->_SUMMAV,15,2)+"р., "+;
             "принято к оплате: "+lstr(tmp3->_SUMMAP,15,2)+"р."
        if !empty(tmp3->_SANK_MEK)
          s += ", санкции МЭК: "+lstr(tmp3->_SANK_MEK,15,2)+"р."
        endif
        if !empty(tmp3->_SANK_MEE)
          s += ", санкции МЭЭ: "+lstr(tmp3->_SANK_MEE,15,2)+"р."
        endif
        if !empty(tmp3->_SANK_EKMP)
          s += ", санкции ЭКМП: "+lstr(tmp3->_SANK_EKMP,15,2)+"р."
        endif
        strfile(s+hb_eol(),cFileProtokol,.t.)
        if tmp3->KOL_ERR > 0
          strfile(hb_eol()+space(4)+"Список снятий:"+hb_eol(),cFileProtokol,.t.)
        endif
        select RAKS
        AddRec(6)
        raks->KOD_RAKS  := recno()
        raks->AKT       := rak->AKT
        raks->SCHET     := tmp3->kod_schet
        raks->KOL_PAC   := tmp3->KOL_PAC
        raks->KOL_ERR   := tmp3->KOL_ERR
        raks->PLAT      := tmp3->_PLAT
        raks->SUMMAV    := tmp3->_SUMMAV
        raks->SUMMAP    := tmp3->_SUMMAP
        raks->SANK_MEK  := tmp3->_SANK_MEK
        raks->SANK_MEE  := tmp3->_SANK_MEE
        raks->SANK_EKMP := tmp3->_SANK_EKMP
        commit
        select TMP4
        find (str(tmp3->kod_a,6)+str(tmp3->kod_s,6))
        do while tmp3->kod_a == tmp4->kod_a .and. tmp3->kod_s == tmp4->kod_s .and. !eof()
          ++ih
          @ maxrow(),1  say "запись: "+lstr(ia) color "G+/R*"
          @ row(),col() say "/"      color "R/R*"
          @ row(),col() say lstr(is) color "GR+/R*"
          @ row(),col() say "/"      color "R/R*"
          @ row(),col() say lstr(ih) color "W+/R*"
          human->(dbGoto(tmp4->KOD_H))
          human_->(G_RLock(forever))
          if human_->OPLATA < 9
            human_->OPLATA := tmp4->_OPLATA
          endif
          if tmp4->_OPLATA > 1
            s := "Сумма лечения: "+lstr(human->cena_1,15,2)+"р., "+;
                 "принято к оплате: "+lstr(tmp4->_SUMP,15,2)+"р."
            if !empty(tmp4->_SANK_MEK)
              s += ", санкции МЭК: "+lstr(tmp4->_SANK_MEK,15,2)+"р."
            endif
            if !empty(tmp4->_SANK_MEE)
              s += ", санкции МЭЭ: "+lstr(tmp4->_SANK_MEE,15,2)+"р."
            endif
            if !empty(tmp4->_SANK_EKMP)
              s += ", санкции ЭКМП: "+lstr(tmp4->_SANK_EKMP,15,2)+"р."
            endif
            s1 := ""
            if tmp4->_OPLATA == 2
              s1 := " (полный отказ)"
            elseif tmp4->_OPLATA == 3
              s1 := " (частичный отказ)"
            elseif tmp4->_OPLATA == 4
              s1 := " (восстановление ранее удержанной суммы)"
            endif
            strfile(hb_eol()+;
                    space(4)+"Случай № "+lstr(tmp4->_IDCASE)+". "+alltrim(human->fio)+", "+;
                         full_date(human->date_r)+;
                         iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                         " "+date_8(human->n_data)+"-"+;
                         date_8(human->k_data)+hb_eol()+;
                    space(5)+s+hb_eol()+;
                    space(5)+"OPLATA = "+lstr(tmp4->_OPLATA)+s1+hb_eol(),cFileProtokol,.t.)
            if emptyall(tmp4->_SANK_MEK,tmp4->_SANK_MEE,tmp4->_SANK_EKMP)
              s := iif(tmp2->_TYPEK==1, "первичный", "повторный")+" контроль "
              if between(tmp2->_KONT,1,3)
                s += inieditspr(A__MENUVERT,mm_vid_kont,tmp2->_KONT)+" "
              endif
              if between(tmp2->_SKONT,1,2)
                s += "("+iif(tmp2->_skont==1,"плановая","целевая")+" экспертиза)"
              endif
              s += "подтвердил предыдущее снятие"
              strfile(space(5)+s+hb_eol(),cFileProtokol,.t.)
            elseif empty(s := ret_t005(tmp4->_REFREASON))
              strfile(space(5)+lstr(tmp4->_REFREASON)+" неизвестная причина отказа"+;
                      hb_eol(),cFileProtokol,.t.)
            else
              k := perenos(t_arr,"код дефекта: "+s,75)
              for i := 1 to k
                strfile(space(5)+t_arr[i]+hb_eol(),cFileProtokol,.t.)
              next
            endif
          endif
          human_->SUMP      := tmp4->_SUMP
          human_->SANK_MEK  := tmp4->_SANK_MEK
          human_->SANK_MEE  := tmp4->_SANK_MEE
          human_->SANK_EKMP := tmp4->_SANK_EKMP
          //
          select RAKSH
          AddRec(6)
          raksh->KOD_RAKS  := raks->KOD_RAKS
          raksh->KOD_H     := tmp4->KOD_H
          raksh->OPLATA    := tmp4->_OPLATA
          raksh->REFREASON := tmp4->_REFREASON
          raksh->SUMP      := tmp4->_SUMP
          raksh->SANK_MEK  := tmp4->_SANK_MEK
          raksh->SANK_MEE  := tmp4->_SANK_MEE
          raksh->SANK_EKMP := tmp4->_SANK_EKMP
          raksh->IS_REPEAT := 0
          raksh->DATE_REP  := ctod("")
          raksh->NEXT_KOD  := 0
          /*if raksh->REFREASON > 0
            select MO_OS
            find (str(raksh->kod_h,7))
            if found()
              raksh->IS_REPEAT := 1
              raksh->DATE_REP  := iif(empty(mo_os->DATE_OPL), sys_date, mo_os->DATE_OPL)
              raksh->NEXT_KOD  := mo_os->NEXT_KOD
              strfile(space(5)+"СЛУЧАЙ УЖЕ БЫЛ ПОВТОРНО ВЫСТАВЛЕН"+hb_eol(),cFileProtokol,.t.)
            endif
          endif*/
          select TMP4
          skip
        enddo
        commit
      endif
      select TMP3
      skip
    enddo
  endif
  select TMP2
  skip
enddo
// запишем время окончания обработки
select MO_XML
goto (rec_xml)
G_RLock(forever)
mo_xml->TWORK2 := hour_min(seconds())
close databases
return NIL

*

***** 10.02.17 зачитать Реестр Актов Контроля во временные файлы
Function reestr_rak_tmpfile(oXmlDoc,aerr,mname_xml)
Static s_big := 10000000000
Local j, j1, oXmlNode, oNode1, oNode2, buf := save_maxrow()
DEFAULT aerr TO {}, mname_xml TO ""
stat_msg("Распаковка/чтение/анализ реестра актов контроля "+beforatnum(".",mname_xml))
dbcreate(cur_dir+"tmp1file", {; // одна запись
 {"_VERSION",   "C",  5,0},;
 {"_DATA",      "D",  8,0},;
 {"_FILENAME",  "C", 26,0},;
 {"_SMO",       "C",  5,0},; // код СМО или ТФ
 {"_CODE_MO",   "C",  6,0},; // код МО
 {"KOL_AKT",    "N",  6,0},; // кол-во актов в файле
 {"KOL_SCH",    "N",  6,0},; // кол-во счетов в файле
 {"KOL_PAC",    "N",  6,0},; // кол-во пациентов в файле
 {"KOL_ERR",    "N",  6,0},; // кол-во пациентов с ошибкой
 {"_YEAR",      "N",  4,0},;
 {"_MONTH",     "N",  2,0};
})
dbcreate(cur_dir+"tmp2file", {;  // много актов
 {"kod_a",      "N",  6,0},; // код акта
 {"_CODEA",     "N", 10,0},; // код записи акта
 {"_NAKT",      "C", 25,0},; // номер акта контроля
 {"_DAKT",      "D",  8,0},; // дата акта контроля
 {"KOL_SCH",    "N",  6,0},; // кол-во счетов в акте
 {"KOL_PAC",    "N",  6,0},; // кол-во пациентов в акте
 {"KOL_ERR",    "N",  6,0},; // кол-во пациентов с ошибкой
 {"_KONT",      "N",  1,0},; // 1-МЭК, 2-МЭЭ, 3-ЭКМП
 {"_TYPEK",     "N",  1,0},; // 1-первичный контроль, 2-повторный
 {"_SKONT",     "N",  1,0};  // вид экспертизы: 0-МЭК, 1-плановая, 2-целевая
})
dbcreate(cur_dir+"tmp3file", {; // в каждом акте много счетов
 {"kod_s",      "N",  6,0},; // код счета
 {"kod_a",      "N",  6,0},; // код акта
 {"_CODE",      "N", 12,0},; // код записи счета
 {"_CODE_MO",   "C",  6,0},; // код МО по F003
 {"_YEAR",      "N",  4,0},;
 {"_MONTH",     "N",  2,0},;
 {"KOD_SCHET",  "N",  6,0},; // код нашего счета
 {"_NSCHET",    "C", 15,0},; // номер нашего счета
 {"_DSCHET",    "D",  8,0},; // дата нашего счета
 {"KOL_PAC",    "N",  6,0},; // кол-во пациентов в счете
 {"KOL_ERR",    "N",  6,0},; // кол-во пациентов с ошибкой
 {"_PLAT",      "C",  5,0},; // плательщик (СМО или ТФ)
 {"_SUMMAV",    "N", 15,2},; // сумма МО, выставленная на оплату
 {"_SUMMAP",    "N", 15,2},; // сумма, принятая к оплате СМО или ТФ
 {"_SANK_MEK",  "N", 15,2},; // финансовые снкции МЭК
 {"_SANK_MEE",  "N", 15,2},; // финансовые снкции МЭЭ
 {"_SANK_EKMP", "N", 15,2};  // финансовые снкции ЭКМП
})
dbcreate(cur_dir+"tmp4file", {;
 {"kod_s",      "N",  6,0},; // код счета
 {"kod_a",      "N",  6,0},; // код акта
 {"_IDCASE",    "N",  8,0},; // номер записи в счете
 {"KOD_H",      "N",  7,0},; // код листа учета по БД "human"
 {"_ID_C",      "C", 36,0},; // код случая
 {"_LPU",       "C",  6,0},; // код МО по T001
 {"_OPLATA",    "N",  1,0},;
 {"_SUMP",      "N", 15,2},;
 {"_REFREASON", "N",  3,0},;
 {"_SANK_MEK",  "N", 15,2},;
 {"_SANK_MEE",  "N", 15,2},;
 {"_SANK_EKMP", "N", 15,2};
})
use (cur_dir+"tmp1file") new alias TMP1
append blank
use (cur_dir+"tmp2file") new alias TMP2
use (cur_dir+"tmp3file") new alias TMP3
use (cur_dir+"tmp4file") new alias TMP4
FOR j := 1 TO Len( oXmlDoc:aItems[1]:aItems )
  @ maxrow(),1 say padr(lstr(j),6) color cColorSt2Msg
  oXmlNode := oXmlDoc:aItems[1]:aItems[j]
  do case
    case "ZGLV" == oXmlNode:title
      tmp1->_VERSION :=          mo_read_xml_stroke(oXmlNode,"VERSION", aerr)
      tmp1->_DATA    := xml2date(mo_read_xml_stroke(oXmlNode,"DATA",    aerr))
      tmp1->_FILENAME:=          mo_read_xml_stroke(oXmlNode,"FILENAME",aerr)
    case "AKT" == oXmlNode:title
      tmp1->KOL_AKT ++
      select TMP2
      append blank
      tmp2->kod_a   := recno()
      tmp2->_CODEA  :=      val(mo_read_xml_stroke(oXmlNode,"CODEA",aerr))
      tmp2->_NAKT   :=          mo_read_xml_stroke(oXmlNode,"NAKT",aerr)
      tmp2->_DAKT   := xml2date(mo_read_xml_stroke(oXmlNode,"DAKT",aerr))
      tmp2->_KONT   :=      val(mo_read_xml_stroke(oXmlNode,"KONT",aerr))
      tmp2->_TYPEK  :=      val(mo_read_xml_stroke(oXmlNode,"TYPEK",aerr))
      tmp2->_SKONT  :=      val(mo_read_xml_stroke(oXmlNode,"SKONT",aerr))
      if empty(tmp2->_CODEA)
        tmp2->_CODEA := s_big - tmp2->(recno())
      endif
      for j1 := 1 to len(oXmlNode:aitems) // последовательный просмотр
        oNode1 := oXmlNode:aItems[j1]     // т.к. счетов м.б. несколько
        if valtype(oNode1) != "C" .AND. oNode1:title == "SCHET"
          tmp1->KOL_SCH ++
          tmp2->KOL_SCH ++
          select TMP3
          append blank
          tmp3->kod_a     := tmp2->kod_a
          tmp3->kod_s     := recno()
          tmp3->_CODE     :=      val(mo_read_xml_stroke(oNode1,"CODE",aerr))
          tmp3->_CODE_MO  :=          mo_read_xml_stroke(oNode1,"CODE_MO",aerr)
          tmp3->_YEAR     :=      val(mo_read_xml_stroke(oNode1,"YEAR",aerr))
          tmp3->_MONTH    :=      val(mo_read_xml_stroke(oNode1,"MONTH",aerr))
          tmp3->_NSCHET   :=    upper(mo_read_xml_stroke(oNode1,"NSCHET",aerr))
          tmp3->_DSCHET   := xml2date(mo_read_xml_stroke(oNode1,"DSCHET",aerr))
          tmp3->_PLAT     :=          mo_read_xml_stroke(oNode1,"PLAT",aerr)
          tmp3->_SUMMAV   :=      val(mo_read_xml_stroke(oNode1,"SUMMAV",aerr))
          tmp3->_SUMMAP   :=      val(mo_read_xml_stroke(oNode1,"SUMMAP",aerr))
          tmp3->_SANK_MEK :=      val(mo_read_xml_stroke(oNode1,"SANK_MEK",aerr))
          tmp3->_SANK_MEE :=      val(mo_read_xml_stroke(oNode1,"SANK_MEE",aerr))
          tmp3->_SANK_EKMP:=      val(mo_read_xml_stroke(oNode1,"SANK_EKMP",aerr))
          for j2 := 1 to len(oNode1:aitems) // последовательный просмотр
            oNode2 := oNode1:aItems[j2]     // т.к. случаев м.б. несколько
            if valtype(oNode2) != "C" .AND. oNode2:title == "SLUCH"
              tmp1->KOL_PAC ++
              tmp2->KOL_PAC ++
              tmp3->KOL_PAC ++
              select TMP4
              append blank
              tmp4->kod_a     := tmp3->kod_a
              tmp4->kod_s     := tmp3->kod_s
              tmp4->_IDCASE   :=   val(mo_read_xml_stroke(oNode2,"IDCASE",aerr))
              tmp4->_ID_C     := upper(mo_read_xml_stroke(oNode2,"ID_C",aerr))
              tmp4->_LPU      :=       mo_read_xml_stroke(oNode2,"LPU",aerr)
              tmp4->_OPLATA   :=   val(mo_read_xml_stroke(oNode2,"OPLATA",aerr))
              tmp4->_SUMP     :=   val(mo_read_xml_stroke(oNode2,"SUMP",aerr))
              tmp4->_REFREASON:=   val(mo_read_xml_stroke(oNode2,"REFREASON",aerr,.f.))
              tmp4->_SANK_MEK :=   val(mo_read_xml_stroke(oNode2,"SANK_MEK",aerr))
              tmp4->_SANK_MEE :=   val(mo_read_xml_stroke(oNode2,"SANK_MEE",aerr))
              tmp4->_SANK_EKMP:=   val(mo_read_xml_stroke(oNode2,"SANK_EKMP",aerr))
              if tmp4->_OPLATA > 1
                tmp1->KOL_ERR ++
                tmp2->KOL_ERR ++
                tmp3->KOL_ERR ++
              endif
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

***** 16.01.16
Function akt_kontrol(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    /*mas_pmt := {"Реестры ~актов контроля",;
                "Акты контроля (~2012 год)"}
    mas_msg := {"Просмотр реестров актов контроля (РАК)",;
                "Поиск счёта для ввода или просмотра актов контроля за 2012 год"}
    mas_fun := {"akt_kontrol(11)",;
                "akt_kontrol(12)"}
    popup_prompt(T_ROW,T_COL+5,si1,mas_pmt,mas_msg,mas_fun)*/
    akt_kontrol(11)
  case k == 11
    view_rak()
  case k == 12
    akt_kontrol_2012()
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*

***** 11.02.13
Function view_rak()
Local str_sem := "Просмотр РАК"
if !G_SLock(str_sem)
  return func_error(4,"В данный момент с реестрами актов контроля работает другой пользователь.")
endif
G_Use(dir_server+"mo_xml",,"MO_XML")
index on dtos(DFILE) to (cur_dir+"tmp_xml") for tip_in==_XML_FILE_RAK DESCENDING
go top
if eof()
  func_error(4,"Нет реестров актов контроля")
else
  Alpha_Browse(T_ROW,2,maxrow()-2,maxcol()-2,"f1_view_rak",color0,,,,,,,;
               "f2_view_rak",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
endif
close databases
G_SUnLock(str_sem)
return NIL

***** 11.02.13
Function f1_view_rak(oBrow)
Local oColumn, blk := {|| iif(empty(mo_xml->TWORK2), {5,6}, {1,2}) }
oColumn := TBColumnNew("Наименование файла;реестра актов контроля",{|| padr(mo_xml->FNAME,23) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew("Дата файла; реестра",{|| full_date(mo_xml->dfile) })
oColumn:colorBlock := blk
oBrow:addColumn(oColumn)
oColumn := TBColumnNew(" Кол.;актов", {|| str(mo_xml->kol1,5) })
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
status_key("^<Esc>^ выход; ^<Enter>^ просмотр актов; ^<F3>^ протокол чтения файла реестра")
return NIL

***** 31.03.13
Function f2_view_rak(nKey,oBrow)
Local ret := -1, rec := mo_xml->(recno()), buf := savescreen()
do case
  case nKey == K_F3
    viewtext(Devide_Into_Pages(dir_server+dir_XML_TF+cslash+alltrim(mo_xml->FNAME)+stxt,60,80),,,,.t.,,,2)
    ret := 0
  case nKey == K_ENTER
    view_rak_akt(rec)
    close databases
    //
    G_Use(dir_server+"mo_xml",cur_dir+"tmp_xml","MO_XML")
    goto (rec)
    ret := 0
  case nKey == K_CTRL_F12
    ret := delete_rak(rec,alltrim(upper(mo_xml->FNAME)),empty(mo_xml->TWORK2))
    close databases
    G_Use(dir_server+"mo_xml",cur_dir+"tmp_xml","MO_XML")
    goto (rec)
endcase
restscreen(buf)
return ret

*

***** 24.04.13
Function delete_rak(lrec,lname,not_end)
Local ret := 0, arr_next := {}, fl, ia, is, ih, buf := save_maxrow()
mywait()
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_raksh",,"RAKSH")
R_Use(dir_server+"mo_raks",,"RAKS")
R_Use(dir_server+"mo_rak",,"RAK")
index on nakt to (cur_dir+"tmp_rak") for kod_xml == mo_xml->(recno()) .and. KOL_ERR > 0
go top
do while !eof()
  select RAKS
  index on str(kod_raks,6) to (cur_dir+"tmp_raks") for akt == rak->akt .and. KOL_ERR > 0
  go top
  do while !eof()
    select RAKSH
    index on str(kod_h,7) to (cur_dir+"tmp_raksh") for KOD_RAKS == raks->KOD_RAKS .and. oplata > 1
    go top
    do while !eof()
      if raksh->next_kod > 0
        human->(dbGoto(raksh->kod_h))
        if year(human->k_data) > 2012 // начиная с 2013 года
          aadd(arr_next, {raksh->kod_h,;
                          raksh->REFREASON,;
                          raksh->SANK_MEK,;
                          raksh->SANK_MEE,;
                          raksh->SANK_EKMP,;
                          raksh->next_kod,;
                          raksh->DATE_REP;
                         })
        endif
      endif
      skip
    enddo
    select RAKS
    skip
  enddo
  select RAK
  skip
enddo
raksh->(dbCloseArea())
raks->(dbCloseArea())
rak->(dbCloseArea())
rest_box(buf)
if (ih := len(arr_next)) > 0
  buf := savescreen()
  f_message({"",;
             "По некоторым пациентам данного РАК",;
             "уже были повторно выставлены случаи - "+lstr(ih)+" чел.",;
             ""},,"GR+/R","W+/R")
  fl := f_Esc_Enter("удаления РАК",.t.)
  restscreen(buf)
  if !fl
    return ret
  endif
endif
if not_end
  fl := .t.
else
  fl := involved_password(2,lname,"подтверждения возврата (удаления) РАК")
endif
if fl .and. f_Esc_Enter("удаления РАК",.t.)
  stat_msg("Подтвердите удаление ещё раз.") ; mybell(2)
  if f_Esc_Enter("удаления РАК",.t.)
    mywait("Ждите. Производится удаление РАК.")
    if ih > 0
      G_Use(dir_server+"mo_os",,"MO_OS")
      index on str(kod,7) to (cur_dir+"tmp_moos")
      for i := 1 to ih
        find (str(arr_next[i,1],7))
        if found()
          G_RLock(forever)
        else
          AddRec(7)
          mo_os->KOD := arr_next[i,1]
        endif
        mo_os->REFREASON := arr_next[i,2]
        mo_os->SANK_MEK  := arr_next[i,3]
        mo_os->SANK_MEE  := arr_next[i,4]
        mo_os->SANK_EKMP := arr_next[i,5]
        mo_os->NEXT_KOD  := arr_next[i,6]
        mo_os->DATE_OPL  := arr_next[i,7]
        mo_os->OPLATA    := 2
        mo_os->IS_REPEAT := 1
        UnLock
      next
    endif
    G_Use(dir_server+"mo_raksh",,"RAKSH")
    index on str(kod_raks,6) to (cur_dir+"tmpraksh")
    G_Use(dir_server+"mo_raks",,"RAKS")
    index on str(akt,6) to (cur_dir+"tmpraks")
    G_Use(dir_server+"mo_rak",,"RAK")
    index on str(kod_xml,6) to (cur_dir+"tmprak")
    ia := is := ih := 0
    do while .t.
      ++ia
      select RAK
      find (str(lrec,6))
      if !found() ; exit ; endif
      do while .t.
        ++is
        select RAKS
        find (str(rak->akt,6))
        if !found() ; exit ; endif
        do while .t.
          ++ih
          select RAKSH
          find (str(raks->KOD_RAKS,6))
          if !found() ; exit ; endif
          @ maxrow(),1  say lstr(ia) color "G+/R*"
          @ row(),col() say "/"      color "R/R*"
          @ row(),col() say lstr(is) color "GR+/R*"
          @ row(),col() say "/"      color "R/R*"
          @ row(),col() say lstr(ih) color "W+/R*"
          DeleteRec(.t.)
        enddo
        select RAKS
        DeleteRec(.t.)
      enddo
      select RAK
      DeleteRec(.t.)
    enddo
    select MO_XML
    DeleteRec(.t.)
    stat_msg("Реестр актов контроля "+lname+" удалён!") ; mybell(2,OK)
    ret := 1
  endif
endif
return ret

*

***** 14.02.17
Function view_rak_akt(lrec)
Local blk, blk_akt, blk_typek, blk_skont, t_arr[BR_LEN]
R_Use(dir_server+"mo_rak",,"RAK")
index on nakt to (cur_dir+"tmp_rak") for kod_xml == lrec
go top
if eof()
  return func_error(4,"Не обнаружено актов в данном РАКе")
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := maxcol()-2
t_arr[BR_TITUL] := "РАК "+alltrim(mo_xml->FNAME)+sxml+" от "+date_8(mo_xml->dfile)
t_arr[BR_TITUL_COLOR] := "B/G*"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(empty(rak->kol_err), {1,2}, {3,4}) }
blk_akt := {|_n,_s,_l| _s := iif(empty(rak->nschet),"","("+alltrim(rak->nschet)+")"),;
                       _l := len(_s), padr(rak->nakt,_n-_l)+_s }
blk_typek := {|| iif(rak->typek==1,"первичный",iif(rak->typek==2,"повторный","")) }
blk_skont := {|| iif(rak->skont==1,"плановая",iif(rak->skont==2,"целевая","МЭК")) }
t_arr[BR_COLUMN] := {{"Номер акта контроля     (счёт)", {|| eval(blk_akt,30) }, blk },;
                     {"Дата акта", {|| full_date(rak->dakt) }, blk },;
                     {"Кол-во;счетов", {|| str(rak->kol_sch,6) }, blk },;
                     {"Кол-во;снятий", {|| put_val(rak->kol_err,6) }, blk },;
                     {"Контроль", {|| padr(eval(blk_typek),9) }, blk },;
                     {"Вид экс-;пертизы", {|| padr(eval(blk_skont),8) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор акта для просмотра счетов") }
t_arr[BR_EDIT] := {|nk,ob| f1_view_rak_akt(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

***** 11.02.13
Function f1_view_rak_akt(nk,ob,regim)
Local ret := -1, rec
if regim == "edit" .and. nk == K_ENTER
  rec := rak->(recno())
  view_rak_akt_schet(rak->akt)
  close databases
  //
  R_Use(dir_server+"mo_rak",cur_dir+"tmp_rak","RAK")
  goto (rec)
  ret := 0
endif
return ret

*

***** 14.02.17
Function view_rak_akt_schet(lakt)
Local blk, blk_eks, t_arr[BR_LEN]
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"mo_raks",,"RAKS")
set relation to schet into SCHET_
index on dtos(schet_->dschet)+schet_->nschet to (cur_dir+"tmp_raks") for akt == lakt
go top
if eof()
  return func_error(4,"Не обнаружено счетов в данном акте")
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-2
t_arr[BR_LEFT] := 2
t_arr[BR_RIGHT] := maxcol()-2
t_arr[BR_TITUL] := "Акт контроля "+alltrim(rak->nakt)+" от "+date_8(rak->dakt)+;
                   iif(between(rak->kont,1,3)," ["+inieditspr(A__MENUVERT,mm_vid_kont,rak->KONT)+"]","")
t_arr[BR_TITUL_COLOR] := "B/GR*"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(empty(raks->kol_err), {1,2}, {3,4}) }
blk_eks := {|| iif(!empty(raks->SANK_MEK),"МЭК",;
                   iif(!empty(raks->SANK_MEE),"МЭЭ",;
                       iif(!empty(raks->SANK_EKMP),"ЭКМП",""))) }
t_arr[BR_COLUMN] := {{" Номер счёта", {|| schet_->nschet }, blk },;
                     {"Пе-;риод", {|| right(str(schet_->nyear,4),2)+"/"+strzero(schet_->nmonth,2) }, blk },;
                     {"  Дата; счёта", {|| date_8(schet_->dschet) }, blk },;
                     {"Паци-;ентов", {|| str(raks->kol_pac,5) }, blk },;
                     {"Сня-;тий", {|| put_val(raks->kol_err,4) }, blk },;
                     {" Сумма счёта", {|| put_kop(raks->SUMMAV,13) }, blk },;
                     {" СМО приняла;  к оплате", {|| put_kop(raks->SUMMAP,13) }, blk },;
                     {"Вид;эксп", {|| padr(eval(blk_eks),4) }, blk }}
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор счёта для просмотра пациентов") }
t_arr[BR_EDIT] := {|nk,ob| f1_view_rak_akt_schet(nk,ob,"edit") }
edit_browse(t_arr)
return NIL

***** 11.02.13
Function f1_view_rak_akt_schet(nk,ob,regim)
Local ret := -1, rec
if regim == "edit" .and. nk == K_ENTER
  rec := raks->(recno())
  view_rak_akt_schet_human(raks->KOD_RAKS)
  close databases
  //
  R_Use(dir_server+"schet_",,"SCHET_")
  R_Use(dir_server+"mo_raks",cur_dir+"tmp_raks","RAKS")
  set relation to schet into SCHET_
  goto (rec)
  ret := 0
endif
return ret

*

***** 14.02.17
Function view_rak_akt_schet_human(lkod_raks)
Local blk, t_arr[BR_LEN], buf := savescreen()
R_Use(dir_server+"schet",,"SCHET")
goto (raks->schet)
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_
G_Use(dir_server+"mo_raksh",,"RAKSH")
set relation to KOD_H into HUMAN
index on str(human_->SCHET_ZAP,6) to (cur_dir+"tmp_raksh") for KOD_RAKS == lkod_raks
go top
if eof()
  return func_error(4,"Не обнаружено пациентов в данном счете")
endif
t_arr[BR_TOP] := T_ROW
t_arr[BR_BOTTOM] := maxrow()-1
t_arr[BR_LEFT] := 0
t_arr[BR_RIGHT] := maxcol()
t_arr[BR_TITUL] := "Счёт № "+alltrim(schet_->nschet)+" от "+;
                   date_8(schet_->dschet)+" "+f4_view_list_schet()
t_arr[BR_TITUL_COLOR] := "B/W*"
t_arr[BR_COLOR] := color0
t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
blk := {|| iif(raksh->oplata==1, {1,2}, {3,4}) }
t_arr[BR_COLUMN] := {{ " №№;случ", {|| str(human_->SCHET_ZAP,4) }, blk },;
                     { " Ф.И.О.", {|| padr(human->fio,27) }, blk },;
                     { "Дата рожд.", {|| full_date(human->date_r) }, blk },;
                     { " Стоимость", {|| put_kop(human->cena_1,10) }, blk },;
                     { " Принято; к оплате", {|| put_kop(raksh->sump,10) }, blk },;
                     { "Код;деф", {|| put_val(raksh->REFREASON,3) }, blk },;
                     { "Повторн.;выставл.", {|| iif(empty(raksh->NEXT_KOD),space(8),date_8(raksh->DATE_REP)) }, blk } }
t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход; ^<F2>^ поиск; ^<Enter>^ повторное выставление пациента (или отмена)") }
t_arr[BR_EDIT] := {|nk,ob| f1_view_rak_akt_schet_human(nk,ob,"edit") }
t_arr[BR_STEP_FUNC] := {|| f2_view_rak_akt_schet_human() }
Private rhuman := 1, chuman := maxcol()-39
box_shadow(rhuman,chuman,rhuman+3,maxcol()-2,"N+/GR*",,,0)
edit_browse(t_arr)
restscreen(buf)
return NIL

***** 16.01.16
Function f1_view_rak_akt_schet_human(nk,ob,regim)
Local ret := -1, rec, s, s1
if !(regim == "edit")
  return ret
elseif nk == K_F2
  if (s := input_value(18,10,20,69,color1,;
         space(5)+"Введите номер случая в счёте (для поиска)",0,"9999")) != NIL ;
         .and. s > 0
    rec := raksh->(recno())
    ob:gotop()
    go top
    find (str(s,6))
    if found()
      ret := 0
    else
      func_error(4,"Не найден случай с номером "+lstr(s))
      goto (rec)
    endif
  endif
elseif nk == K_ENTER .and. year(human->k_data) > 2012
  s := 0
  if !empty(raksh->SANK_MEK)
    s := raksh->SANK_MEK
  elseif !empty(raksh->SANK_MEE)
    s := raksh->SANK_MEE
  elseif !empty(raksh->SANK_EKMP)
    s := raksh->SANK_EKMP
  endif
  if human->cena_1 > 0 .and. empty(s)
    func_error(4,"Повторное выставление случая невозможно при нулевой сумме отказа")
    return ret
  elseif !(round(human->cena_1,2)==round(s+raksh->sump,2) .and. raksh->OPLATA == 2)
    func_error(4,"Повторное выставление случая возможно только для OPLATA = 2 и полного отказа")
    return ret
  endif
  if tip_polzovat != 0
    func_error(4,err_admin)
    return ret
  endif
  rec := raksh->(recno())
  s := alltrim(human->fio)+" "+date_8(human->n_data)+"-"+date_8(human->k_data)+;
       " ("+lstr(human->cena_1)+"р.)"
  s1 := "код дефекта: "+lstr(raksh->REFREASON)
  if emptyall(human->cena_1,raksh->SANK_MEK,raksh->SANK_MEE,raksh->SANK_EKMP) // скорая помощь
    s1 += ", санкции "+inieditspr(A__MENUVERT,mm_vid_kont,rak->KONT)+": 0р. (СМП)"
  elseif !empty(raksh->SANK_MEK)
    s1 += ", санкции МЭК: "+lstr(raksh->SANK_MEK,15,2)+"р."
  elseif !empty(raksh->SANK_MEE)
    s1 += ", санкции МЭЭ: "+lstr(raksh->SANK_MEE,15,2)+"р."
  elseif !empty(raksh->SANK_EKMP)
    s1 += ", санкции ЭКМП: "+lstr(raksh->SANK_EKMP,15,2)+"р."
  endif
  if empty(raksh->NEXT_KOD)
    if human_->OPLATA == 9
      func_error("Ошибка! Данный случай уже был перевыставлен!")
    else
      rak_akt_schet_human_add_next(s,s1,rec)
    endif
  else
    rak_akt_schet_human_del_next(s,s1,rec)
  endif
  //
  close databases
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  R_Use(dir_server+"mo_raksh",cur_dir+"tmp_raksh","RAKSH")
  set relation to KOD_H into HUMAN
  goto (rec)
  ret := 0
endif
return ret

***** 16.01.16
Function f2_view_rak_akt_schet_human()
Local arr[4], i, n, s, lcolor := "N", tmp_select := select()
afill(arr,"")
n := 76-chuman
if select("RAKS") == 0
  R_Use(dir_server+"mo_raks",,"RAKS")
endif
if select("RAK") == 0
  R_Use(dir_server+"mo_rak",,"RAK")
endif
raks->(dbGoto(raksh->kod_raks))
rak->(dbGoto(raks->akt))
i := 0
if between(rak->kont,1,3)
  arr[++i] := "вид контроля: "+inieditspr(A__MENUVERT,mm_vid_kont,rak->KONT)
  if between(rak->SKONT,1,2)
    arr[i] += "["+{"плановая","целевая"}[rak->SKONT]+"]"
  endif
endif
arr[++i] := iif(rak->TYPEK==1, "первичный", "повторный")+" контроль"
if !between(rak->kont,1,3)
  arr[++i] := "вид экспертизы: "+iif(rak->skont==1,"плановая",iif(rak->skont==2,"целевая","МЭК"))
endif
++i
if raksh->OPLATA == 1
  arr[i] := "полностью оплачен"
elseif raksh->OPLATA == 2
  arr[i] := "полный отказ"
elseif raksh->OPLATA == 3
  arr[i] := "частичный отказ"
elseif raksh->OPLATA == 4
  arr[i] := "восст-ние ранее удержанной суммы"
endif
s := 0
if !empty(raksh->SANK_MEK)
  s := raksh->SANK_MEK
elseif !empty(raksh->SANK_MEE)
  s := raksh->SANK_MEE
elseif !empty(raksh->SANK_EKMP)
  s := raksh->SANK_EKMP
endif
if raksh->OPLATA == 2
  if empty(s) .and. human->cena_1 > 0
    if rak->kont == 1 .or. rak->skont == 0 
      lcolor := "R"
      arr[++i] := "ошибка СМО - нет суммы санкций!"
    endif
    if rak->kont > 1 .or. rak->skont > 0
      lcolor := "RB"
      arr[++i] := "снято предыдущей санкцией"
    endif
  elseif round(human->cena_1,2)==round(s+raksh->sump,2)
    arr[++i] := "снято "+lstr(s,11,2)+"р."
    lcolor := "B"
  endif
endif
for i := 1 to 4
  @ rhuman-1+i,chuman+1 say padc(arr[i],n) color lcolor+"/GR*"
next
select (tmp_select)
return NIL

*

***** 12.02.13
Function rak_akt_schet_human_add_next(s,s1,lrec)
Local i, arr1, arr2, mkod, buf := save_maxrow()
glob_perso := raksh->kod_h
arr1 := {s,;
         s1,;
         "После подтверждения данный лист учёта будет выставлен",;
         "повторно (для последующего исправления и отправки в ТФОМС).",;
         'Редактировать новый л/у в режиме "Выбор по акту снятия из СМО"',;
         ""}
arr2 := {" Отказ "," Повторное выставление "}
if f_alert(arr1,arr2,1,"N+/G*","N/G*",13,,"N/G*") == 2
  if f_alert(arr1,arr2,1,"N+/G*","R/G*",14,,"N/G*") == 2
    mywait()
    close databases
    // сначала запоминаем копию листа учёта в массивах
    use_base("human")
    set relation to // "отвязываем"
    goto (glob_perso)
    ahuman := get_field()
    select HUMAN_
    goto (glob_perso)
    ahuman_ := get_field()
    select HUMAN_2
    goto (glob_perso)
    ahuman_2 := get_field()
    if (fl_iname := (human_->smo == '34   '))
      G_Use(dir_server+"mo_hismo",,"SN")
      index on str(kod,7) to (cur_dir+"tmp_ismo")
      find (str(glob_perso,7))
      mnameismo := sn->smo_name
    endif
    arr_hu := {}
    use_base("human_u")
    set relation to // "отвязываем"
    find (str(glob_perso,7))
    do while hu->kod == glob_perso .and. !eof()
      ahu := get_field()
      select HU_
      goto (hu->(recno()))
      ahu_ := get_field()
      aadd(arr_hu,{ahu,ahu_})
      select HU
      skip
    enddo
    arr_mohu := {}
    Use_base("mo_hu")
    find (str(glob_perso,7))
    do while mohu->kod == glob_perso .and. !eof()
      aadd(arr_mohu,get_field())
      skip
    enddo
    arr_disp := read_arr_DISPANS(glob_perso)
    //
    select HUMAN_
    goto (glob_perso)
    G_RLock(forever)
    human_->OPLATA := 9
    // теперь записываем в БД копию листа учёта
    select HUMAN
    Add1Rec(7)
    mkod := recno()
    aeval(ahuman, {|x,i| fieldput(i,x) } )
    human->kod      := mkod
    human->TIP_H    := B_STANDART // лечение завершено
    human->DATE_OPL := ""
    human->schet    := 0
    //
    select HUMAN_
    do while human_->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    aeval(ahuman_, {|x,i| fieldput(i,x) } )
    human_->KOD_UP    := glob_perso // код оригинального листа учёта
    human_->SUMP      := 0
    human_->OPLATA    := 0
    human_->SANK_MEK  := 0
    human_->SANK_MEE  := 0
    human_->SANK_EKMP := 0
    human_->REESTR    := 0
    human_->REES_ZAP  := 0
    human_->SCHET_ZAP := 0
    human_->ST_VERIFY := 0 // снова ещё не проверен
    //
    select HUMAN_2
    do while human_2->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    aeval(ahuman_2, {|x,i| fieldput(i,x) } )
    if fl_iname
      select SN
      find (str(mkod,7))
      if found()
        if !empty(mnameismo)
          G_RLock(forever)
          sn->smo_name := mnameismo
        else
          DeleteRec(.t.)
        endif
      else
        if !empty(mnameismo)
          AddRec(7)
          sn->kod := mkod
          sn->smo_name := mnameismo
        endif
      endif
    endif
    for i := 1 to len(arr_hu)
      select HU
      Add1Rec(7)
      aeval(arr_hu[i,1], {|x,i| fieldput(i,x) } )
      hu->kod := mkod
      select HU_
      do while hu_->(lastrec()) < hu->(recno())
        APPEND BLANK
      enddo
      goto (hu->(recno()))
      G_RLock(forever)
      aeval(arr_hu[i,2], {|x,i| fieldput(i,x) } )
      hu_->OPLATA    := 0
      hu_->REES_ZAP  := 0
      hu_->SCHET_ZAP := 0
    next
    //
    for i := 1 to len(arr_mohu)
      select MOHU
      Add1Rec(7)
      aeval(arr_mohu[i], {|x,i| fieldput(i,x) } )
      mohu->kod       := mkod
      mohu->OPLATA    := 0
      mohu->REES_ZAP  := 0
      mohu->SCHET_ZAP := 0
    next
    save_arr_DISPANS(mkod,arr_disp)
    //
    G_Use(dir_server+"mo_raksh",,"RAKSH")
    goto (lrec)
    G_RLock(forever)
    raksh->IS_REPEAT := 1
    raksh->DATE_REP  := sys_date
    raksh->NEXT_KOD  := mkod
    close databases
    stat_msg("Данный лист учёта выставлен повторно") ; mybell(2,OK)
  endif
endif
rest_box(buf)
return NIL

*

***** 12.02.13
Function rak_akt_schet_human_del_next(s,s1,lrec)
Local i, arr1, arr2, mkod, buf := save_maxrow()
glob_perso := raksh->kod_h
if (mkod := raksh->next_kod) > 0
  select RAKSH
  set relation to
  select HUMAN
  goto (mkod)
  if human->schet > 0 .or. human_->REESTR > 0
    return func_error(10,"Повторно выставленный лист учёта уже попал в реестр (счёт). Удаление запрещено!")
  endif
endif
arr1 := {s,;
         s1,;
         "После подтверждения повторно выставленный лист учёта будет удалён",;
         ""}
arr2 := {" Отказ "," Удалить повторно выставленный л/у "}
if f_alert(arr1,arr2,1,"N+/GR*","N/GR*",15,,"N/GR*") == 2
  if f_alert(arr1,arr2,1,"N+/GR*","R/GR*",16,,"N/GR*") == 2
    mywait()
    close databases
    use_base("mo_hdisp")
    Use_base("mo_hu")
    Use_base("human_u")
    Use_base("human")
    G_Use(dir_server+"mo_raksh",,"RAKSH")
    G_Use(dir_server+"mo_os",,"MO_OS")
    index on str(kod,7) to (cur_dir+"tmp_moos") for NEXT_KOD > 0
    find (str(glob_perso,7))
    if found()
      DeleteRec(.t.)
    endif
    do while .t.
      select HDISP
      find (str(mkod,7))
      if !found() ; exit ; endif
      DeleteRec(.t.)
    enddo
    do while .t.
      select MOHU
      find (str(mkod,7))
      if !found() ; exit ; endif
      DeleteRec(.t.,.f.)  // без пометки на удаление
    enddo
    do while .t.
      select HU
      find (str(mkod,7))
      if !found() ; exit ; endif
      //
      select HU_
      DeleteRec(.t.,.f.)
      select HU
      DeleteRec(.t.,.f.)  // без пометки на удаление
    enddo
    select HUMAN
    find (str(mkod,7))
    select HUMAN_
    DeleteRec(.t.,.f.)
    select HUMAN
    DeleteRec(.t.,.f.)  // без пометки на удаление
    G_RLock(forever)
    replace human->schet with -1  // (вместо нуля)
    //
    select RAKSH
    goto (lrec)
    G_RLock(forever)
    raksh->IS_REPEAT := 0
    raksh->DATE_REP  := ctod("")
    raksh->NEXT_KOD  := 0
    //
    select HUMAN
    goto (glob_perso)
    select HUMAN_
    G_RLock(forever)
    human_->OPLATA    := raksh->OPLATA
    human_->SANK_MEK  := raksh->SANK_MEK
    human_->SANK_MEE  := raksh->SANK_MEE
    human_->SANK_EKMP := raksh->SANK_EKMP
    close databases
    stat_msg("Повторно выставленный лист учёта удалён") ; mybell(2,OK)
  endif
endif
rest_box(buf)
return NIL

*

***** 10.12.13
Function ret_menu_rak_schet(r,c)
Static si := 4,;
       arr := {{"по дате отчётного периода",1},;
               {"по дате выписки счёта",2},;
               {"по дате регистрации счёта",3},;
               {"по дате акта контроля",4},;
               {"по дате РеестраАктовКонтроля",5}}
Local i, ret, ret_arr
DEFAULT r TO T_ROW, c TO T_COL-5
if popup_2array(arr,r,c,si,1,@ret_arr) > 0 .and. valtype(ret_arr) == "A"
  si := ret_arr[2]
  ret := {ret_arr[2],ret_arr[1]}
endif
return ret

***** 22.11.15 список снятий по актам
Function akt_list_of_refusal_pacient()
Static si := 3
Static mas_pmt := {"случаи полного снятия",;
                   "случаи частичного снятия",;
                   "все случаи снятия",;
                   "перевыставленные случаи полного снятия",;
                   "не перевыставленные случаи полного снятия"}
Local buf := save_maxrow(), lsmo, lmenu, i, j, k, s, t_arr[2], ;
      ireg, fl, arr_m, n_file := "spis_sn"+stxt, sh := 80, HH := 60
Private a_otd := {}      
if (st_a_uch := inputN_uch(T_ROW,T_COL-5,,,@lcount_uch)) == NIL
  return NIL
endif
if len(st_a_uch) == 1
  glob_uch := st_a_uch[1]
  if (st_a_otd := inputN_otd(T_ROW,T_COL-5,.f.,.f.,glob_uch,@lcount_otd)) == NIL
    return NIL
  endif
  aeval(st_a_otd, {|x| aadd(a_otd,x[1]) })
else
  R_Use(dir_server+"mo_otd",,"OTD")
  go top
  do while !eof()
    if f_is_uch(st_a_uch,otd->kod_lpu)
      aadd(a_otd, otd->(recno()))
    endif
    skip
  enddo
  otd->(dbCloseArea())
endif
if (lsmo := ret_actual_smo()) == NIL
  return NIL
endif
if (lmenu := ret_menu_rak_schet()) == NIL
  return NIL
endif
if (arr_m := year_month(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (ireg := popup_prompt(T_ROW,T_COL-5,si,mas_pmt)) == 0
  return NIL
endif
si := ireg
if lmenu[1] == 1 .and. !is_otch_period(arr_m)
  return NIL
endif
mywait()
delFRfiles()
adbf := {{"name","C",130,0},;
         {"name1","C",130,0},;
         {"name2","C",130,0},;
         {"sroki","C",100,0},;
         {"sdata","C",100,0},;
         {"ssmo","C",50,0},;
         {"summa1","N",15,2},;
         {"summa2","N",15,2},;
         {"nitog1","N",5,0},;
         {"nitog2","N",5,0}}
dbcreate(fr_titl, adbf)
use (fr_titl) new alias FRT
append blank
frt->name := glob_mo[_MO_SHORT_NAME]
frt->sroki := arr_m[4]
frt->sdata := lmenu[2]+iif(ireg < 3,"", " / "+mas_pmt[ireg])
frt->ssmo  := lsmo[2]
adbf := {{"nrak","C",50,0},;
         {"drak","C",10,0},;
         {"nakt","C",50,0},;
         {"dakt","C",10,0},;
         {"nschet","C",50,0},;
         {"dschet","C",10,0},;
         {"dregschet","C",10,0},;
         {"fio","C",60,0},;
         {"date_r","C",10,0},;
         {"otd","C",5,0},;
         {"n_data","C",10,0},;
         {"k_data","C",10,0},;
         {"cena_1","N",11,2},;
         {"sum_sn","N",11,2},;
         {"REFREASON","C",15,0},;
         {"DATE_REP","C",10,0}}
dbcreate(fr_data,adbf)
use (fr_data) new alias FRD
adbf := {{"REFREASON","N",3,0},;
         {"kol","N",6,0},;
         {"name","C",120,0}}
dbcreate(fr_data+"1",adbf)
use (fr_data+"1") new alias FRD1
index on str(REFREASON,3) to (fr_data+"1")
//
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
if ireg == 3
  s := "Список снятий по актам контроля"
elseif ireg == 2
  s := "Список частичных снятий по актам контроля"
else
  s := "Список снятий (полных отказов) по актам контроля"
endif
add_string(center(s,sh))
frt->name1 := s
add_string(center(arr_m[4],sh))
add_string(center("[ "+lmenu[2]+" ]",sh))
add_string(center(lsmo[2],sh))
add_string("")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human_",,"HUMAN_")
R_Use(dir_server+"human",,"HUMAN")
set relation to recno() into HUMAN_, to otd into OTD
R_Use(dir_server+"mo_raksh",,"RAKSH")
index on str(kod_raks,6) to (cur_dir+"tmpraksh")
R_Use(dir_server+"mo_raks",,"RAKS")
index on str(akt,6) to (cur_dir+"tmpraks") for plat == lsmo[1]
R_Use(dir_server+"mo_rak",,"RAK")
index on str(kod_xml,6)+dtos(dakt)+nakt to (cur_dir+"tmprak")
R_Use(dir_server+"mo_xml",,"MO_XML")
index on dfile to (cur_dir+"tmp_xml") for TIP_IN == _XML_FILE_RAK
j := 0
go top
do while !eof()
  if iif(lmenu[1] == 5, between(mo_xml->DFILE,arr_m[5],arr_m[6]), .t.)
    fl_xml := .t.
    select RAK
    find (str(mo_xml->kod,6))
    do while mo_xml->kod == rak->kod_xml .and. !eof()
      if iif(lmenu[1] == 4, between(rak->dakt,arr_m[5],arr_m[6]), .t.)
        fl_rak := .t.
        select RAKS
        find (str(rak->akt,6))
        do while rak->akt == raks->akt .and. !eof()
          schet_->(dbGoto(raks->schet))
          fl := .t.
          if lmenu[1] == 1
            fl := between_otch_period(schet_->dschet,schet_->NYEAR,schet_->NMONTH,arr_m[5],arr_m[6])
          elseif lmenu[1] == 2
            fl := between(schet_->dschet,arr_m[5],arr_m[6])
          elseif lmenu[1] == 3
            fl := (schet_->NREGISTR==0 .and. between(date_reg_schet(),arr_m[5],arr_m[6]))
          endif
          if fl
            fl_raks := .t.
            select RAKSH
            find (str(raks->kod_raks,6))
            do while raks->kod_raks == raksh->kod_raks .and. !eof()
              human->(dbGoto(raksh->KOD_H))
              s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
              s1 := ""
              if !empty(raksh->SANK_MEK)
                s1 += "МЭК"
              endif
              if !empty(raksh->SANK_MEE)
                s1 += "МЭЭ"
              endif
              if !empty(raksh->SANK_EKMP)
                s1 += "ЭКМП"
              endif
              if (fl := (raksh->REFREASON > 0 .and. s > 0)) //round(human->cena_1,2)==round(s+raksh->SUMP,2)
                if ireg == 2 // частичное
                  fl := (raksh->oplata == 3)
                elseif ireg == 3 // все случаи
                  fl := eq_any(raksh->oplata,2,3)
                else
                  if (fl := (raksh->oplata == 2))
                    if ireg == 4 // перевыставленные
                      fl := (raksh->NEXT_KOD > 0)
                    elseif ireg == 5 // не перевыставленные
                      fl := (raksh->NEXT_KOD == 0)
                    endif
                  endif
                endif
              endif
              if fl
                fl := (ascan(a_otd,human->otd) > 0)
              endif
              if fl
                procent := round(s/human->cena_1*100,0)
                verify_FF(HH-3, .t., sh)
                select FRD
                append blank
                frd->nrak := alltrim(mo_xml->FNAME)
                frd->drak := date_8(mo_xml->DFILE)
                if fl_xml
                  add_string("РАК: "+alltrim(mo_xml->FNAME)+" от "+date_8(mo_xml->DFILE))
                  fl_xml := .f.
                endif
                frd->nakt := alltrim(rak->nakt)
                frd->dakt := date_8(rak->dakt)
                if fl_rak
                  add_string(space(2)+"акт: "+alltrim(rak->nakt)+" от "+date_8(rak->dakt))
                  fl_rak := .f.
                endif
                frd->nschet := alltrim(schet_->nschet)
                frd->dschet := date_8(schet_->dschet)
                if schet_->NREGISTR == 0
                  frd->dregschet := date_8(date_reg_schet())
                endif
                if fl_raks
                  add_string(space(4)+"счёт: "+alltrim(schet_->nschet)+" от "+date_8(schet_->dschet))
                  fl_raks := .f.
                endif
                verify_FF(HH-3, .t., sh)
                add_string(space(6)+lstr(++j)+". "+alltrim(human->fio)+", "+;
                           full_date(human->date_r)+;
                           iif(empty(otd->SHORT_NAME), "", " ["+alltrim(otd->SHORT_NAME)+"]")+;
                           " "+date_8(human->n_data)+"-"+date_8(human->k_data))
                add_string(space(8)+"! полный отказ - "+lstr(human->cena_1,11,2)+"р.")
                if raksh->oplata == 2
                  frt->nitog1 ++
                  frt->summa1 += s
                else
                  frt->nitog2 ++
                  frt->summa2 += s
                endif
                frd->fio    := human->fio
                frd->date_r := full_date(human->date_r)
                frd->otd    := otd->SHORT_NAME
                frd->n_data := left(date_8(human->n_data),5)
                frd->k_data := date_8(human->k_data)
                frd->cena_1 := human->cena_1
                frd->sum_sn := s
                if empty(s := ret_t005(raksh->REFREASON))
                  s := lstr(raksh->REFREASON)+" неизвестная причина отказа"
                endif
                frd->REFREASON := lstr(raksh->REFREASON)+"/"+s1
                select FRD1
                find (str(raksh->REFREASON,3))
                if !found()
                  append blank
                  frd1->REFREASON := raksh->REFREASON
                  frd1->name := s
                endif
                frd1->kol ++
                k := perenos(t_arr,s,72)
                for i := 1 to k
                  add_string(space(8)+t_arr[i])
                next
                if raksh->NEXT_KOD > 0
                  add_string(space(8)+"! случай уже перевыставлен "+date_8(raksh->DATE_REP))
                  frd->DATE_REP := date_8(raksh->DATE_REP)
                elseif between(procent,1,99)
                  frd->DATE_REP := "- "+lstr(procent)+" %"
                endif
              endif
              select RAKSH
              skip
            enddo
          endif
          select RAKS
          skip
        enddo
      endif
      select RAK
      skip
    enddo
  endif
  select MO_XML
  skip
enddo
fclose(fp)
s := ""
if frt->nitog1 > 0
  s := "Итого пациентов с полным отказом "+lstr(frt->nitog1)+" чел. на сумму "+lstr(frt->summa1,15,2)+"р. "
endif
if frt->nitog2 > 0
  s += " Итого пациентов с частичным отказом "+lstr(frt->nitog2)+" чел. на сумму "+lstr(frt->summa2,15,2)+"р."
endif
frt->name2 := s
close databases
rest_box(buf)
name_fr := "mo_spis_sn"+sfr3
if _upr_epson() .or. !file(dir_exe+name_fr)
  viewtext(n_file,,,,.f.,,,2)
else
  call_fr(name_fr)
endif
return NIL

***** 20.02.18 Список РАК
Function pr_list_RAK()
Static arr_smo
Local buf := save_maxrow(), arr_m, n_file := "list_RAK"+stxt, ta[2], i, s, asmo,;
      krak := 0, kakt, ksch, kpac, kerr, sh, HH := 60
if arr_smo == NIL
  arr_smo := mo_cut_menu(glob_arr_smo)
endif
if (arr_m := year_month(T_ROW,T_COL-5)) == NIL
  return NIL
endif
if (asmo := bit_popup(T_ROW,T_COL-5,arr_smo,,color0)) == NIL
  return NIL
endif
s := ""
for i := 1 to len(asmo)
  s += asmo[i,1]+", "
next
arr_title := {;
  "──────────┬─────┬─────────────────────────┬─────┬──────┬──────┬──────┬──────",;
  "   Дата   │Отчёт│                         │     │кол-во│кол-во│кол-во│кол-во",;
  "   РАК    │перио│      Акт контроля       │ СМО │актов │счетов│пациен│снятий",;
  "──────────┴─────┴─────────────────────────┴─────┴──────┴──────┴──────┴──────"}
sh := len(arr_title[1])
k := perenos(ta,left(s,len(s)-2),sh)   
//
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(glob_mo[_MO_SHORT_NAME])
add_string("")
add_string(center("Список реестров актов контроля",sh))
add_string(center(arr_m[4],sh))
for i := 1 to k
  add_string(center(alltrim(ta[i]),sh))
next  
add_string("")
aeval(arr_title, {|x| add_string(x) } )
//
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"mo_raks",,"RAKS")
index on str(akt,6) to tmpraks memory 
R_Use(dir_server+"mo_rak",,"RAK")
index on str(kod_xml,6) to tmprak memory
R_Use(dir_server+"mo_xml",,"MO_XML")
index on dfile to tmp_xml for TIP_IN == _XML_FILE_RAK memory
go top
do while !eof()
  if between(mo_xml->DFILE,arr_m[5],arr_m[6])
    otch_period := space(6) ; lsmo := space(5)
    kakt := ksch := kpac := kerr := 0
    select RAK
    find (str(mo_xml->kod,6))
    do while mo_xml->kod == rak->kod_xml .and. !eof()
      select RAKS
      find (str(rak->akt,6))
      do while rak->akt == raks->akt .and. !eof()
        if ascan(asmo,{|x| x[2] == int(val(raks->plat)) }) > 0
          lsmo := raks->plat
          schet_->(dbGoto(raks->schet))
          s := right(str(schet_->NYEAR,4),2)+"/"+strzero(schet_->NMONTH,2)+" "
          if empty(otch_period)
            otch_period := s
          elseif !(otch_period == s) .and. !(right(otch_period,1) == "+") 
            otch_period := left(otch_period,5)+"+"
          endif
        endif
        select RAKS
        skip
      enddo
      kakt++ 
      ksch += rak->KOL_SCH 
      kpac += rak->KOL_PAC
      kerr += rak->KOL_ERR
      select RAK
      skip
    enddo
    if !empty(otch_period)
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      krak++
      add_string(full_date(mo_xml->DFILE)+" "+otch_period+padr(mo_xml->FNAME,26)+lsmo+;
                 put_val(kakt,7)+put_val(ksch,7)+put_val(kpac,7)+put_val(kerr,7))
    endif
  endif
  select MO_XML
  skip
enddo
add_string(replicate("─",sh))
add_string("  Итого количество РАК (реестров актов контроля) - "+lstr(krak))
fclose(fp)
close databases
rest_box(buf)
viewtext(n_file,,,,.f.,,,2)
return NIL

***** 29.11.15 Список счетов без РАК
Function pr_schet_bez_RAK()
Local buf := save_maxrow(), arr_m, n_file := "s_bezRAK"+stxt, sh, HH := 60
if (arr_m := year_month(T_ROW,T_COL-5,,4)) == NIL
  return NIL
endif
arr_title := {;
  "───────────────┬────────┬─────╥─────┬────────────╥────────╥─────────────────",;
  "               │  Дата  │Отчёт║ Кол.│            ║Дата ре-║                 ",;
  "  Номер счета  │  счета │перио║больн│ Сумма счёта║гистр-ии║  Акт контроля   ",;
  "───────────────┴────────┴─────╨─────┴────────────╨────────╨─────────────────"}
sh := len(arr_title[1])
//
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string("")
add_string(center("Список счетов, по которым нет актов контроля",sh))
add_string(center(arr_m[4],sh))
add_string(center("[ по дате отчётного периода ]",sh))
add_string("")
aeval(arr_title, {|x| add_string(x) } )
R_Use(dir_server+"mo_raks",,"RAKS")
index on str(schet,6) to (cur_dir+"tmpraks")
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"schet",,"SCHET")
set relation to recno() into SCHET_
index on str(schet_->nyear,4)+str(schet_->nmonth,2) to (cur_dir+"tmp_schet") ;
      for empty(schet_->IS_DOPLATA)
dbseek(str(arr_m[1],4)+str(arr_m[2],2),.t.)
do while schet_->nyear == arr_m[1] .and. schet_->nmonth <= arr_m[3] .and. !eof()
  select RAKS
  find (str(schet->(recno()),6))
  if !found()
    s := schet_->nschet+" "+date_8(schet_->dschet)+" "+;
                 put_otch_period()+;
                 put_val(schet->kol,6)+put_kop(schet->summa,13)+" "
    if schet_->NREGISTR == 1 // ещё не зарегистрирован
      s += "ещё нет "
    elseif schet_->NREGISTR == 2 // не будет зарегистрирован
      s += "не будет"
    elseif schet_->NREGISTR == 3 // удалён
      s += "удалён  "
    else
      s += date_8(schet_->DREGISTR)
    endif
    s += "     нет акта"
    if verify_FF(HH,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string(s)
  endif
  select SCHET
  skip
enddo
fclose(fp)
close databases
rest_box(buf)
viewtext(n_file,,,,.f.,,,2)
return NIL

*

***** 29.11.15 суммы снятий по актам
Function akt_summa_of_refusal()
Local buf := save_maxrow(), arr_m, n_file := "sum_RAK"+stxt, sh, HH := 40,;
      arr_smo := aclone(glob_arr_smo)
if (arr_m := year_month(T_ROW,T_COL-5)) == NIL
  return NIL
endif
adbf := {{"REFREASON","N",3,0},;
         {"srefr","C",12,0},;
         {"smo","C",5,0},;
         {"kol","N",6,0},;
         {"summa","N",15,2},;
         {"kol1","N",6,0},;
         {"summa1","N",15,2},;
         {"kol2","N",6,0},;
         {"summa2","N",15,2},;
         {"kol3","N",6,0},;
         {"summa3","N",15,2}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on smo+str(REFREASON,3) to (cur_dir+"tmp")         
R_Use(dir_server+"mo_raksh",,"RAKSH")
index on str(kod_raks,6) to (cur_dir+"tmpraksh")
R_Use(dir_server+"mo_raks",,"RAKS")
index on str(akt,6) to (cur_dir+"tmpraks")
R_Use(dir_server+"mo_rak",,"RAK")
index on dtos(dakt) to (cur_dir+"tmprak") for between(dakt,arr_m[5],arr_m[6])
go top
do while !eof()
  @ maxrow(),0 say padr(date_8(rak->dakt),80) color "W/R"
  select RAKS
  find (str(rak->akt,6))
  do while rak->akt == raks->akt .and. !eof()
    select RAKSH
    find (str(raks->kod_raks,6))
    do while raks->kod_raks == raksh->kod_raks .and. !eof()
      s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
      if raksh->REFREASON > 0 .and. s > 0
        select TMP
        for i := 1 to 2
          lsmo := {space(5),raks->plat}[i]
          for k := 1 to 2
            lrefr := {0,raksh->REFREASON}[k]
            find (lsmo+str(lrefr,3))
            if !found()
              append blank
              tmp->REFREASON := lrefr
              tmp->smo := lsmo
            endif
            tmp->kol ++
            tmp->summa += s
            if !empty(raksh->SANK_MEK)
              tmp->kol1 ++
              tmp->summa1 += raksh->SANK_MEK
            endif
            if !empty(raksh->SANK_MEE)
              tmp->kol2 ++
              tmp->summa2 += raksh->SANK_MEE
            endif
            if !empty(raksh->SANK_EKMP)
              tmp->kol3 ++
              tmp->summa3 += raksh->SANK_EKMP
            endif
          next k
        next i
      endif
      select RAKSH
      skip
    enddo
    select RAKS
    skip
  enddo
  select RAK
  skip
enddo
arr_title := {;
"______________________________________________________________________________________________",;
"код       |кол-во|сумма отказа |______________________в_том_числе_____________________________",;         
"нарушения |нару- |в оплате руб.|________МЭК_________|________МЭЭ_________|________ЭКМП________",;
"          |шений |             |кол-во| сумма снятий|кол-во| сумма снятий|кол-во| сумма снятий",;   
"__________|______|_____________|наруш_|_____________|наруш_|_____________|наруш_|_____________"}
sh := len(arr_title[1])
//
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(glob_mo[_MO_SHORT_NAME])
add_string("")
add_string(center("Структура нарушений по результатам контроля объемов, сроков, качества и условий",sh))
add_string(center("предоставления медицинской помощи по обязательному медицинскому страхованию",sh))
add_string(center("даты актов контроля - "+arr_m[4],sh))
aeval(arr_title, {|x| add_string(x) } )
R_Use(exe_dir+"_mo_t005",cur_dir+"_mo_t005","T5")
select TMP
go top
do while !eof()
  if tmp->REFREASON == 0
    tmp->srefr := "Итого"
  else
    select T5
    find (str(tmp->REFREASON,3))
    if found()
      s := alltrim(t5->name)
      s1 := ""
      for i := 1 to len(s)
        if ISLETTER(substr(s,i,1))
          exit
        endif
        s1 += substr(s,i,1)
      next
      tmp->srefr := s1
    endif
  endif
  select TMP
  skip
enddo  
index on smo+str(iif(empty(REFREASON),999,REFREASON),3) to (cur_dir+"tmp")         
for i := 1 to len(arr_smo)
  arr_smo[i,2] := padr(lstr(arr_smo[i,2]),5)
next
aadd(arr_smo, {"Всего",space(5),1})
for i := 1 to len(arr_smo)
  select TMP
  find (arr_smo[i,2])
  if found()
    if verify_FF(HH-3,.t.,sh)
      aeval(arr_title, {|x| add_string(x) } )
    endif
    add_string("")
    add_string(center(arr_smo[i,1],sh))
    add_string(center(replicate("~",len(arr_smo[i,1])+2),sh))
    do while tmp->smo == arr_smo[i,2] .and. !eof()
      if verify_FF(HH,.t.,sh)
        aeval(arr_title, {|x| add_string(x) } )
      endif
      if tmp->REFREASON == 0
        add_string(replicate("-",sh))
      endif
      add_string(padr(tmp->srefr,11)+str(tmp->kol,6)+put_kop(tmp->summa,14)+;
                 put_val(tmp->kol1,7)+put_kopE(tmp->summa1,14)+;
                 put_val(tmp->kol2,7)+put_kopE(tmp->summa2,14)+;
                 put_val(tmp->kol3,7)+put_kopE(tmp->summa3,14))
      select TMP
      skip
    enddo
  endif
next  
fclose(fp)
close databases
rest_box(buf)
Private yes_albom := .t.
viewtext(n_file,,,,.t.,,,1)
return NIL

*

***** 14.12.15 список снятий по актам (дефекты)
Function akt_list_of_refusal_defect()
Static arr_smo
Static mm_poisk := {{"По дате РАК (XML-файла)",0},;
                    {"По дате акта контроля ",1}}
Static mm_akt := {{"отдельно по каждому акту   ",0},;
                  {"объединять акты (как счета)",1}}
Static mm_schet := {{"отдельно по каждому счёту      ",0},;
                    {"объединять по отчётному периоду",1},;
                    {"объединять все счета           ",2}}
Static mm_eks := {{"все ",0},{"МЭК ",1},{"МЭЭ ",2},{"ЭКМП",3}}
Static s1poisk := 1, s1schet := 0, s1akt := 0, s1eks := 0, s1smo := 0
Local buf := savescreen(), i, ar, s, r := 14
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
        meks, m1eks := s1eks,;
        makt, m1akt := s1akt
Private pdate, gl_arr := {;  // для битовых полей
  {"smo","N",10,0,,,,{|x|inieditspr(A__MENUBIT,arr_smo,x)} };
 }
mpoisk := inieditspr(A__MENUVERT, mm_poisk, m1poisk)
mschet := inieditspr(A__MENUVERT, mm_schet, m1schet)
meks   := inieditspr(A__MENUVERT, mm_eks,   m1eks  )
makt   := inieditspr(A__MENUVERT, mm_akt,   m1akt  )
msmo   := inieditspr(A__MENUBIT,  arr_smo,  m1smo  )
setcolor(cDataCGet)
myclear(r)
Private gl_area := {r,1,maxrow()-1,maxcol(),0}, pdate
status_key("^<Esc>^ - выход;  ^<PgDn>^ - составление документа")
//
@ r,0 to maxrow()-1,maxcol() COLOR color8
str_center(r," Список снятий по актам (подготовка информации) ",color14)
do while .t.
  @ r+2,2 say "Страховая(ые) компания(и)" get msmo ;
          reader {|x|menu_reader(x,arr_smo,A__MENUBIT,,,.f.)}
  @ r+3,2 say "Как подсчитывать (РАК/акты)" get mpoisk ;
          reader {|x|menu_reader(x,mm_poisk,A__MENUVERT,,,.f.)}
  @ r+4,2 say "Период времени" get mdate ;
          reader {|x| menu_reader(x,{{|k,r,c| ;
                       k:=year_month(r+1,c),iif(k==nil,nil,(pdate:=aclone(k),k:={k[1],k[4]})),;
                       k }},A__FUNCTION,,,.f.)}
  @ r+5,2 say "Вид экспертизы" get meks ;
          reader {|x|menu_reader(x,mm_eks,A__MENUVERT,,,.f.)}
  @ r+6,2 say "Информация по счетам" get mschet ;
          reader {|x|menu_reader(x,mm_schet,A__MENUVERT,,,.f.)}
  @ r+7,2 say "Информация по актам" get makt ;
          reader {|x|menu_reader(x,mm_akt,A__MENUVERT,,,.f.)}
  myread()
  if lastkey() == K_ESC
    exit
  endif  
  s1smo   := m1smo
  s1schet := m1schet
  s1poisk := m1poisk
  s1akt   := m1akt
  s1eks   := m1eks
  if empty(pdate)
    func_error(4,"Не введён период времени")
  elseif empty(m1smo)
    func_error(4,"Не введена страховая компания")
  else
    ar := {} ; s := ""
    for i := 1 to len(arr_smo)
      if isbit(s1smo,i)
        aadd(ar, arr_smo[i,3])
        s += arr_smo[i,1] + ", "
      endif
    next
    s := substr(s,1,len(s)-2)
    f1akt_list_of_refusal_defect(ar,s)
  endif
enddo
restscreen(buf)
return NIL

*

***** 17.12.15 функция для списка снятий по актам (дефекты)
Function f1akt_list_of_refusal_defect(asmo,ssmo)
Local adbf, s, otch_period, n_file := "sp_sn"+stxt, HH := 60, buf := save_maxrow()
mywait()
adbf := {{"nrak","C",26,0},;
         {"drak","D",8,0},;
         {"rak","N",6,0},;
         {"srak","C",50,0},;
         {"nakt","C",26,0},;
         {"dakt","D",8,0},;
         {"akt","N",6,0},;
         {"sakt","C",50,0},;
         {"op","C",6,0},;
         {"sop","C",50,0},;
         {"nschet","C",15,0},;
         {"dschet","D",8,0},;
         {"schet","N",6,0},;
         {"ssch","C",50,0},;
         {"otd","N",3,0},;
         {"kol","N",6,0},;
         {"sum_sn","N",15,2},;
         {"REFREASON","N",3,0}}
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
R_Use(dir_server+"schet_",,"SCHET_")
R_Use(dir_server+"mo_otd",,"OTD")
R_Use(dir_server+"human",,"HUMAN")
R_Use(dir_server+"mo_raksh",,"RAKSH")
index on str(kod_raks,6) to tmpraksh memory
R_Use(dir_server+"mo_raks",,"RAKS")
index on str(akt,6) to tmpraks memory 
R_Use(dir_server+"mo_rak",,"RAK")
index on str(kod_xml,6)+dtos(dakt)+nakt to tmprak memory
R_Use(dir_server+"mo_xml",,"MO_XML")
index on dfile to tmp_xml for TIP_IN == _XML_FILE_RAK memory
go top
do while !eof()
  if iif(m1poisk == 0, between(mo_xml->DFILE,pdate[5],pdate[6]), .t.)
    select RAK
    find (str(mo_xml->kod,6))
    do while mo_xml->kod == rak->kod_xml .and. !eof()
      if iif(m1poisk == 1, between(rak->dakt,pdate[5],pdate[6]), .t.)
        select RAKS
        find (str(rak->akt,6))
        do while rak->akt == raks->akt .and. !eof()
          if ascan(asmo,raks->plat) > 0
            schet_->(dbGoto(raks->schet))
            otch_period := str(schet_->NYEAR,4)+strzero(schet_->NMONTH,2)
            select RAKSH
            find (str(raks->kod_raks,6))
            do while raks->kod_raks == raksh->kod_raks .and. !eof()
              human->(dbGoto(raksh->KOD_H))
              s := 0 
              if m1eks == 0
                s := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
              elseif m1eks == 1
                s := raksh->SANK_MEK
              elseif m1eks == 2                                 
                s := raksh->SANK_MEE
              elseif m1eks == 3                                
                s := raksh->SANK_EKMP
              endif
              if raksh->REFREASON > 0 .and. s > 0
                select TMP
                append blank
                tmp->nrak := alltrim(mo_xml->FNAME)
                tmp->drak := mo_xml->DFILE
                tmp->rak := mo_xml->kod
                tmp->nakt := alltrim(rak->nakt)
                tmp->dakt := rak->dakt
                tmp->akt := rak->akt
                tmp->nschet := alltrim(schet_->nschet)
                tmp->dschet := schet_->dschet
                tmp->schet := raks->KOD_RAKS
                tmp->op := otch_period
                tmp->sum_sn := s
                tmp->REFREASON := raksh->REFREASON
                tmp->otd := human->otd
              endif
              select RAKSH
              skip
            enddo
          endif
          select RAKS
          skip
        enddo
      endif
      select RAK
      skip
    enddo
  endif
  select MO_XML
  skip
enddo
dbcreate(cur_dir+"tmp1",adbf)
use (cur_dir+"tmp1") new
index on str(rak,6)+str(akt,6)+op+str(schet,6)+str(otd,3)+str(REFREASON,3) to (cur_dir+"tmp1")
old_rak := old_akt := old_schet := -1
old_op := space(18)     
select TMP
go top
do while !eof()
  lrak := iif(m1poisk == 0, tmp->rak, 0)
  lakt := tmp->akt
  lschet := tmp->schet
  lop := space(6)  
  if m1schet == 0 // отдельно по каждому счёту
    lakt := tmp->akt 
  elseif m1schet == 1 // объединять по отчётному периоду
    lop := tmp->op  
    lschet := 0
    if m1akt == 0 // отдельно по каждому акту 
    else          // объединять акты (как счета)
      lakt := 0 
    endif
  else // объединять все счета
    lschet := 0
    if m1akt == 0 // отдельно по каждому акту 
    else          // объединять акты (как счета)
      lakt := 0 
    endif
  endif
  select TMP1
  find (str(lrak,6)+str(lakt,6)+lop+str(lschet,6)+str(tmp->otd,3)+str(tmp->REFREASON,3))
  if !found()
    append blank
    tmp1->rak := lrak
    tmp1->akt := lakt 
    tmp1->op := lop 
    tmp1->schet := lschet
    if m1poisk == 0 .and. !(old_rak == lrak)
      tmp1->srak := "РАК: "+rtrim(tmp->nrak)+" от "+date_8(tmp->drak)
      old_rak := lrak 
    endif 
    if m1schet == 0  // отдельно по каждому счёту
      if m1akt == 0 ; // отдельно по каждому акту
         .and. !(old_akt == lakt)
        tmp1->sakt := rtrim(tmp->nakt)+","+date_8(tmp->dakt)
        old_akt := lakt
      endif 
      if !(old_schet == lschet)
        tmp1->ssch := rtrim(tmp->nschet)+","+date_8(tmp->dschet)
        old_schet := lschet
      endif 
    elseif m1schet == 1 // объединять по отчётному периоду
      if m1akt == 0 ; // отдельно по каждому акту
         .and. !(old_akt == lakt)
        tmp1->sakt := rtrim(tmp->nakt)+","+date_8(tmp->dakt)
        old_akt := lakt
      endif 
      if !(old_op == str(lrak,6)+str(lakt,6)+lop)
        tmp1->sop := mm_month[int(val(substr(tmp1->op,5)))]+" "+left(tmp1->op,4)+" года"
        old_op := str(lrak,6)+str(lakt,6)+lop
      endif
    else // объединять все счета
      if m1akt == 0 ; // отдельно по каждому акту
         .and. !(old_akt == lakt)
        tmp1->sakt := rtrim(tmp->nakt)+","+date_8(tmp->dakt)
        old_akt := lakt
      endif 
    endif 
    tmp1->REFREASON := tmp->REFREASON
    tmp1->otd := tmp->otd
  endif     
  tmp1->kol ++
  tmp1->sum_sn += tmp->sum_sn  
  select TMP
  skip
enddo
arr_title := {;
"_______________________________________________________________________________",;
" № акта, дата       | Проверяемый счёт   |кол-во|  Сумма      |  Коды    |Отде-",;
"                    |                    |снятий|  снятий     |  снятий  |ление",;
"____________________|____________________|______|_____________|__________|_____"}
sh := len(arr_title[1])
//
fp := fcreate(n_file) ; n_list := 1 ; tek_stroke := 0
add_string(glob_mo[_MO_SHORT_NAME])
add_string("")
add_string(center("Снятия по экспертизам",sh))
add_string(center("Вид экспертизы: "+meks,sh))
add_string(center("СМО: "+ssmo,sh))
add_string(center("даты "+iif(m1poisk == 0, "РАК - ", "актов контроля - ")+pdate[4],sh))
aeval(arr_title, {|x| add_string(x) } )
R_Use(exe_dir+"_mo_t005",cur_dir+"_mo_t005","T5")
ssum := skol := sum_rak := kol_rak := 0 ; n := 20
select TMP1
set order to 0
go top
do while !eof()
  if !empty(tmp1->srak)
    if !empty(kol_rak)  
      add_string(space(n)+replicate("-",n*2+3))
      add_string(padl("Итого по РАК:",41)+str(kol_rak,7)+str(sum_rak,14,2))
      sum_rak := kol_rak := 0
    endif
    add_string("")
    add_string(padc(alltrim(tmp1->srak),sh,"_"))
  endif
  s1 := lstr(tmp1->REFREASON)
  select T5
  find (str(tmp1->REFREASON,3))
  if found()
    s1 := "" ; s2 := ltrim(t5->name)
    for i := 1 to len(s2)
      if ISLETTER(substr(s2,i,1))
        exit
      endif
      s1 += substr(s2,i,1)
    next
  endif
  if empty(tmp1->sakt)
    s := space(n)
  else 
    s := padr(tmp1->sakt,n) 
  endif
  s += " " 
  if empty(tmp1->ssch)
    s += padr(tmp1->sop,n)
  else
    s += padr(tmp1->ssch,n)
  endif
  s += put_val(tmp1->kol,7)+str(tmp1->sum_sn,14,2)+" "+padr(charrem(" ",s1),11)
  skol += tmp1->kol 
  ssum += tmp1->sum_sn
  if m1poisk == 0
    kol_rak += tmp1->kol 
    sum_rak += tmp1->sum_sn
  endif
  otd->(dbGoto(tmp1->otd))
  if empty(otd->short_name)
    s += otd->name
  else
    s += otd->short_name
  endif
  if verify_FF(HH-3,.t.,sh)
    aeval(arr_title, {|x| add_string(x) } )
  endif
  add_string(s)
  select TMP1
  skip
enddo
if !empty(kol_rak)  
  add_string(space(n)+replicate("-",n*2+3))
  add_string(padl("Итого по РАК:",41)+str(kol_rak,7)+str(sum_rak,14,2))
endif
add_string(replicate("-",sh))
add_string(padl("Всего:",41)+str(skol,7)+str(ssum,14,2))
fclose(fp)
close databases
rest_box(buf)  
viewtext(n_file,,,,.t.,,,2)
return NIL
