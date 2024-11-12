// mo_omsid.prg - информация по диспансеризации в ОМС
#include "inkey.ch"
#include "fastreph.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

#define MONTH_UPLOAD 12 //МЕСЯЦ для выгрузки R11

// 22.01.24 Создание файла обмена R11...
Function f_create_R11()
  Local buf := save_maxrow(), i, j, ir, s := "", arr := {}, fl := .t., fl1 := .f., a_reestr := {}, ar
  Private SMONTH := 1, mdate := sys_date, mrec := 1
  Private c_view := 0, c_found := 0, fl_exit := .f., pj, arr_rees := {},;
          pkol := 0, CODE_LPU := glob_mo[_MO_KOD_TFOMS], CODE_MO := glob_mo[_MO_KOD_FFOMS],;
          mkol := {0,0,0,0,0}, skol[5], ames[12,5], ame[12], bm := SMONTH,; // начальный месяц минус один
          _arr_vozrast_DVN := ret_arr_vozrast_DVN(0d20231201)
  
  Private sgod := 2024
  //
  mywait()
  fl := .t.
  fl_1 := .f.
  SMONTH := lm := MONTH_UPLOAD //МЕСЯЦ
  dbcreate(cur_dir+"tmp_00",{;
     {"reestr",     "N", 6,0},;
     {"kod",        "N", 7,0},; // код по картотеке
     {"tip",        "N", 1,0},; // 1-диспансеризация, 2-профосмотр
     {"tip1",       "N", 1,0},; // 1-пенсионер,2-65 лет,3-66 лет и старше
     {"voz",        "N", 1,0};  // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-остальные
    })
  R_Use(dir_server+"mo_xml",,"MO_XML")
  index on str(reestr,6) to (cur_dir+"tmp_xml") for tip_in == _XML_FILE_R12 .and. empty(TIP_OUT)
  R_Use(dir_server+"mo_dr01",,"REES")
  index on str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. eq_any(NMONTH,SMONTH-1,SMONTH) .and. tip == 1
  go top
  do while !eof()
  
    if rees->kol_err < 0
      fl := func_error(4,"В файле PR11 за "+lstr(rees->NMONTH)+"-й месяц "+;
                         lstr(sgod)+"г. ошибки на уровне файла! Операция запрещена")
    elseif empty(rees->answer)
      fl := func_error(4,"Файл PR11 за "+lstr(rees->NMONTH)+"-й месяц "+;
                         lstr(sgod)+" года не был прочитан! Операция запрещена")
    else
      select MO_XML
      find (str(rees->kod,6))
      if found()
        if empty(mo_xml->TWORK2)
          fl := func_error(4,"Прервано чтение файла "+alltrim(mo_xml->FNAME)+;
                             "! Аннулируйте (Ctrl+F12) и прочитайте снова")
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
  
  if fl_1 //.or. code_lpu == "321001"// не первый раз
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
    // только для нужного месяца
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
        tmp->n_m := tmp->n_q := 0 // если уже заходили в режим и не подтвердили создание XML
        if between(j,1,2)
          if between(j1,1,3)
            mkol[j1+2] ++
          else
            mkol[j] ++ // подсчёт оставшегося кол-ва в пуле пациентов
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
          if r01k->oplata == 1  // учтён в ТФОМС
            j := r01k->tip
            j1 := r01k->tip1
            if !between(j,1,2)
              fl := func_error(4,"Некорректный вид осмотра в файле MO_DR01k.DBF! Операция запрещена")
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
        fl := func_error(4,"Более не требуется создания файлов обмена!")
      else
        for j := 1 to 5
          if mkol[j] < skol[j]
            s := {"диспансеризаций","профосмотров","дисп.пенсионеров","дисп.65 лет","дисп.66 лет и старше"}[j]
            fl := func_error(4,"Не хватает "+lstr(skol[j]-mkol[j])+" чел. в картотеке для профосмотров")
          endif
        next
      endif
    endif
  
    if fl
      mywait()
      for v := 1 to 5
        j := {2,4,5,3,1}[v]
        // порядок: 2-профосмотр, 4-65 лет, 5-66 и старше, 3-пенсионеры, 1-остальная дисп-ия
        if empty(skol[j])
          loop
        endif
        pj := j
        d := koef := int(mkol[j] / skol[j]) + 1 // через сколько записей прыгаем
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
              if ames[i,j,1] > ames[i,j,2] // если ещё не набрали месяц
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
              tmp->n_q := int((tmp->n_m+2)/3) // определяем номер квартала по месяцу
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
  else // первый раз
  /*  select REES
    index on str(NMONTH,2)+str(nn,3) to (cur_dir+"tmp_dr01") for NYEAR == sgod .and. tip == 0
    find (str(lm,2))
    do while lm == rees->NMONTH .and. !eof()
      aadd(arr_rees,rees->kod) // список R01 за февраль
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
          if rhum->tip == 2 // профосмотр
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
            rhum->oplata := 2 // все в ошибки
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
      aadd(arr_rees,rees->kod) // список R01 за февраль
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
  
// 09.02.20 переопределить все три первичных ключа в картотеке
Static Function f0_create_R11(sgod)
  Local fl, v, ltip := 0, ltip1 := 0, lvoz := 0, ag, lgod_r
  if !emptyany(kart->kod,kart->fio,kart->date_r) // данную запись в картотеке недавно удалили
    lgod_r := year(kart->date_r)
    v := sgod - lgod_r
    if (fl := (v > 17)) // только взрослое население
      lvoz := 4
      ltip1 := 0
      if ascan(_arr_vozrast_DVN,v) > 0
        ltip := 1 // диспансеризация
        // 1-65 лет, 2-66 лет и старше, 3-пенсионер, 4-прочие
        if v >= iif(kart->POL == "М", 60, 55)
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
        ltip := 2 // профосмотры
      endif
    endif
  endif
  return {ltip,ltip1,lvoz}
  
// 22.10.21
Function f1_create_R11(lm,fl_dr00)
  Local nsh := 3, smsg, lnn := 0 ,buf := save_maxrow()
  if !f_Esc_Enter("создания файла R11",.t.)
    return NIL
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
    smsg := "Составление файла R11 за "+lstr(SMONTH)+"-й месяц"
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
    mo_xml->TIP_OUT := _XML_FILE_R11  // тип высылаемого файла - R11
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
        if fl_dr00 // для второго и т.д. реестров в месяце
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
      mo_add_xml_stroke(oXmlNode,"SEX",iif(kart->pol=="М",'1','2'))
      if !empty(kart->snils)
        mo_add_xml_stroke(oXmlNode,"SS",transform(kart->SNILS,picture_pf))
      endif
       //  проверим наличие ЕНП - иначе старый вариант
       if len(alltrim(kart2->KOD_MIS)) > 14
        mo_add_xml_stroke(oXmlNode,"TYPE_P",lstr(3)) // только НОВЫЙ
        s := alltrim(kart2->KOD_MIS)
        s := padr(s,16,"0")
        // 
        mo_add_xml_stroke(oXmlNode,"NUM_P",s)
        mo_add_xml_stroke(oXmlNode,"ENP",s)
      else
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
      endif
  /*
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
      endif*/
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
    stat_msg("Запись XML-файла")
    oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
    chip_create_zipXML(alltrim(mo_xml->FNAME)+szip,{alltrim(mo_xml->FNAME)+sxml},.t.)
  rm->(G_RLock(forever))
  rm->TWORK2 := hour_min(seconds())
  close databases
  keyboard chr(K_TAB)+chr(K_ENTER)
  rest_box(buf)
  return NIL
  
// 28.12.21
Function delete_reestr_R11()
  Local t_arr[BR_LEN], blk
  if ! hb_user_curUser:IsAdmin()
    return func_error(4,err_admin)
  endif
  G_Use(dir_server+"mo_dr01m",,"R01m")
  index on descend(dtos(DWORK)+TWORK1) to (cur_dir+"tmp_dr01m")
  go top
  if eof()
    func_error(4,"Не было создано файлов R11...")
  else
    t_arr[BR_TOP] := T_ROW
    t_arr[BR_BOTTOM] := maxrow()-2
    t_arr[BR_LEFT] := 2
    t_arr[BR_RIGHT] := 77
    t_arr[BR_COLOR] := color0
    t_arr[BR_TITUL] := "Список созданных пакетов реестров R11"
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(empty(r01m->twork2),{3,4},{1,2}) }
    t_arr[BR_COLUMN] := {;
     { "  Дата;создания",{|| date_8(r01m->dwork) }, blk },;
     { "янв;арь", {|| iif(r01m->reestr01 > 0,"да ","нет") }, blk },;
     { "фев;рал", {|| iif(r01m->reestr02 > 0,"да ","нет") }, blk },;
     { "мар;т  ", {|| iif(r01m->reestr03 > 0,"да ","нет") }, blk },;
     { "апр;ель", {|| iif(r01m->reestr04 > 0,"да ","нет") }, blk },;
     { "май;   ", {|| iif(r01m->reestr05 > 0,"да ","нет") }, blk },;
     { "июн;ь  ", {|| iif(r01m->reestr06 > 0,"да ","нет") }, blk },;
     { "июл;ь  ", {|| iif(r01m->reestr07 > 0,"да ","нет") }, blk },;
     { "авг;уст", {|| iif(r01m->reestr08 > 0,"да ","нет") }, blk },;
     { "сен;тяб", {|| iif(r01m->reestr09 > 0,"да ","нет") }, blk },;
     { "окт;ябр", {|| iif(r01m->reestr10 > 0,"да ","нет") }, blk },;
     { "ноя;брь", {|| iif(r01m->reestr11 > 0,"да ","нет") }, blk },;
     { "дек;абр", {|| iif(r01m->reestr12 > 0,"да ","нет") }, blk },;
     { "Время;начала",    {|| r01m->twork1 }, blk },;
     { "Время;окончания", {|| padr(iif(empty(r01m->twork2),"НЕ ЗАВЕРШЕНО",r01m->twork2),10) }, blk };
    }
    t_arr[BR_EDIT] := {|nk,ob| f1_delete_reestr_R11(nk,ob,"edit") }
    t_arr[BR_FL_INDEX] := .f.
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - аннулирование создания пакета реестров R01") }
    edit_browse(t_arr)
  endif
  close databases
  return NIL
  
// 09.02.20
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
            fl := func_error(4,"Это файл R01. Операция запрещена!")
            exit
          elseif rees->ANSWER == 1
            fl := func_error(4,"Уже получен ответ PR11 за "+lstr(ir)+"-й месяц. Операция запрещена!")
            exit
          endif
        endif
      next
      REES->(dbCloseArea())
      select R01m
      if fl .and. f_Esc_Enter("аннулирования R11")
        mywait()
        f2_delete_reestr_R11(rec_m)
        stat_msg("Аннулирование завершено!") ; mybell(2,OK)
        ret := 1
      endif
    else
      func_error(4,"Процесс создания реестра R11 завершён корректно. Операция запрещена!")
    endif
  endif
  return ret
  
  
// 09.02.20 аннулировать чтение реестра R11
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
  
// 13.02.20 удаление всех пакетов R11(PR11) за конкретный месяц
Function delete_month_R11()
  Local pss := space(10), tmp_pss := my_parol()
  Local i, lm, mkod_reestr, ar_m := {}, buf
  if select("MO_XML") > 0
    return NIL
  endif
  if (lm := input_value(18,6,20,73,color1,space(9)+"Введите удаляемый месяц (все файлы R11,PR11)",2,"99")) == NIL
    return NIL
  elseif !between(lm,2,12)
    return NIL
  else
    pss := get_parol(,,,,,"N/W","W/N*")
    if lastkey() == K_ENTER .and. ascan(tmp_pss,crypt(pss,gpasskod)) > 0 .and. f_Esc_Enter("удаления файлов R11",.t.)
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
    func_error(10,"Не обнаружено реестров R11 за "+lstr(lm)+" месяц!")
  else
    for i := len(ar_m) to 1 step -1
      stat_msg("Удаляется "+lstr(i)+"-й реестр R11")
      if ar_m[i,3] > 0
        f2_delete_reestr_R02(ar_m[i,2],ar_m[i,3])
      endif
      close databases
      G_Use(dir_server+"mo_dr01m",,"R01m")
      f2_delete_reestr_R11(ar_m[i,1])
    next
    stat_msg("Успешно удалено реестров R11 - "+lstr(len(ar_m))+" (и, соответственно, ответов на них PR11)")
    inkey(10)
  endif
  rest_box(buf)
  close databases
  return NIL

// 28.02.21 удаление всех пакетов R01(PR01) за конкретный месяц
/*
Function delete_month_R01()
Local pss := space(10), tmp_pss := my_parol()
Local i, lm, mkod_reestr, ar_m := {}, buf
if select("MO_XML") > 0
  return NIL
endif
if (lm := input_value(18,6,20,73,color1,space(9)+"Введите удаляемый месяц (все файлы R01,PR01)",2,"99")) == NIL
  return NIL
elseif !between(lm,2,12)
  return NIL
else
  pss := get_parol(,,,,,"N/W","W/N*")
  if lastkey() == K_ENTER .and. ascan(tmp_pss,crypt(pss,gpasskod)) > 0 .and. f_Esc_Enter("удаления файлов R01",.t.)
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
  func_error(10,"Не обнаружено реестров R01 за "+lstr(lm)+" месяц!")
else
  for i := len(ar_m) to 1 step -1
    stat_msg("Удаляется "+lstr(i)+"-й реестр R01")
    if ar_m[i,3] > 0
      f2_delete_reestr_R02(ar_m[i,2],ar_m[i,3])
    endif
    close databases
    G_Use(dir_server+"mo_dr01m",,"R01m")
    f2_delete_reestr_R01(ar_m[i,1])
  next
  stat_msg("Успешно удалено реестров R01 - "+lstr(len(ar_m))+" (и, соответственно, ответов на них PR01)")
  inkey(10)
endif
rest_box(buf)
close databases
return NIL
*/

// 25.02.21
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
  // только для нужного месяца
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
  add_string(center("Общая информация (R11)",80))
  add_string("")
  mmt := {"диспансеризация","профосмотр","дисп.пенсионеры","дисп.65 лет","дисп.66 и старше"}
  for i := lm to lm
  add_string("──────────────────────────┬─────────────┬─────────────┬────────────┬────────────")
  add_string("     месяц                │  по плану   │  отправлено │  в ТФОМСе  │ расхождение")
  add_string("──────────────────────────┴─────────────┴─────────────┴────────────┴────────────")
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
  add_string(padr("Итого:",n))
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

  