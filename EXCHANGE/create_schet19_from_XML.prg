***** счета с 2019 года
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 18.08.21 создать счета по результатам прочитанного реестра СП
Function create_schet19_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
  Local arr_schet := {}, c, len_stand, _arr_stand, lshifr, i, j, k, lbukva,;
        doplataF, doplataR, mnn, fl, name_zip, arr_zip := {}, lshifr1,;
        CODE_LPU := glob_mo[_MO_KOD_TFOMS], code_schet, mb, me, nsh,;
        CODE_MO  := glob_mo[_MO_KOD_FFOMS], s1
  local controlVer
  local tmpSelect

  DEFAULT fl_msg TO .t., arr_s TO {}
  Private pole
  //
  use (cur_dir+"tmp1file") new alias TMP1
  mdate_schet := tmp1->_DSCHET
  nsh := f_mb_me_nsh(tmp1->_year,@mb,@me)
  // составляем массив будущих счетов
  // открыть распакованный реестр
  use (cur_dir+"tmp_r_t1") new index (cur_dir+"tmpt1") alias T1
  use (cur_dir+"tmp_r_t2") new index (cur_dir+"tmpt2") alias T2
  use (cur_dir+"tmp_r_t3") new index (cur_dir+"tmpt3") alias T3
  use (cur_dir+"tmp_r_t4") new index (cur_dir+"tmpt4") alias T4
  use (cur_dir+"tmp_r_t5") new index (cur_dir+"tmpt5") alias T5
  use (cur_dir+"tmp_r_t6") new index (cur_dir+"tmpt6") alias T6
  use (cur_dir+"tmp_r_t7") new index (cur_dir+"tmpt7") alias T7
  use (cur_dir+"tmp_r_t8") new index (cur_dir+"tmpt8") alias T8
  use (cur_dir+"tmp_r_t9") new index (cur_dir+"tmpt9") alias T9
  use (cur_dir+"tmp_r_t10") new index (cur_dir+"tmpt10") alias T10
  use (cur_dir+"tmp_r_t11") new index (cur_dir+"tmpt11") alias T11
  use (cur_dir+"tmp_r_t12") new index (cur_dir+"tmpt12") alias T12
  use (cur_dir+"tmp_r_t1_1") new index (cur_dir+"tmpt1_1") alias T1_1
  R_Use(dir_server+"mo_pers",,"PERS")
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"uslugi",,"USL")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_
  G_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_, to u_kod into USL
  R_Use(dir_server+"mo_su",,"MOSU")
  G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
  set relation to u_kod into MOSU
  G_Use(dir_server+"mo_xml",,"MO_XML")
  G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  use_base("human")
  set order to 0
  set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
  use (cur_dir+"tmp2file") new alias TMP2
  index on upper(fio) to (cur_dir+"tmp2") for _OPLATA == 1
  go top
  do while !eof()
    c := " "
    lal := "HUMAN"
    dbSelectArea(lal)
    goto (tmp2->kod_human)
    if human->ishod == 88
      lal += "_3"
      dbSelectArea(lal)
      set order to 1
      find (str(tmp2->kod_human,7))
    elseif human->ishod == 89
      lal += "_3"
      dbSelectArea(lal)
      set order to 2
      find (str(tmp2->kod_human,7))
    endif
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      lbukva := " "
      if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,@lbukva)
        lshifr1 := iif(empty(lshifr1), usl->shifr, lshifr1)
        if hu->STOIM_1 > 0 .or. left(lshifr1,3) == "71."  // скорая помощь
          if !empty(lbukva)
            c := lbukva
            exit
          endif
        endif
      endif
      select HU
      skip
    enddo
    if type("pr_array_schet") == "A" .and. empty(c)
      c := "A"   // искусственно для экспорта из чужих БД случаев с отсутствующими услугами
    endif
    if empty(c)
      s := alltrim(human->fio)+" - не найдена буква счёта"
      aadd(aerr,s)
      close databases
      return func_error(4,s)
    else
      tmp2->SCHET_CHAR := c
    endif
    if (i := ascan(arr_schet, {|x| x[1]==tmp2->_SMO .and. x[2]==tmp2->SCHET_CHAR})) == 0
      aadd(arr_schet, {tmp2->_SMO,tmp2->SCHET_CHAR,0,0,0,0,0,0,0,0})
      i := len(arr_schet)
    endif
    arr_schet[i,3] ++
    arr_schet[i,4] += &lal.->cena_1
    arr_schet[i,8] := 0 // сюда запишем код счёта
    arr_schet[i,9] := 0 // сюда запишем номер пакета
    arr_schet[i,10] := 0 // сюда запишем индекс массива pr_array_schet
    tmp2->SCHET_ZAP := arr_schet[i,3]
    tmp2->SCHET := i
    //
    select TMP2
    skip
  enddo
  if type("pr_array_schet") == "A"
    for ii := 1 to len(arr_schet)
      fl := .f.
      mn_schet := alltrim(arr_schet[ii,1])+"-"+alltrim(tmp1->_NSCHET)+arr_schet[ii,2]
      if (i := ascan(pr_array_schet, {|x| alltrim(x[3])==mn_schet .and. x[6]==tmp1->_year})) > 0
        arr_schet[ii,9] := pr_array_schet[i,2] // сюда запишем номер пакета
        arr_schet[ii,10] := i
      endif
      if arr_schet[ii,10] == 0
        my_debug(,lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" не найден счёт "+mn_schet)
      else
        i := arr_schet[ii,10]
        s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,15)
        s += "max: "+lstr(pr_array_schet[i,8])
        if pr_array_schet[i,8] == arr_schet[ii,3]
          s += " = "
          s1 := "+"
        else
          s += " != "
          s1 := "-"
          fl := .t.
        endif
        s += lstr(arr_schet[ii,3])+", кол: "+lstr(pr_array_schet[i,7])
        if pr_array_schet[i,7] == arr_schet[ii,3]
          s += " = "
          s1 += "+"
        else
          s += " != "
          s1 += "-"
          fl := .t.
        endif
        s += lstr(arr_schet[ii,3])+", сум: "+lstr(pr_array_schet[i,5],13,2)
        if round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2)
          s += " = "
          s1 += "+"
        else
          s += " != "
          s1 += "-"
          fl := .t.
        endif
        s += lstr(arr_schet[ii,4],13,2)
        my_debug(,s1+s)
      endif
      if arr_schet[ii,10] > 0 // счёт найден в "pr_array_schet"
        i := arr_schet[ii,10]
        arr_schet[ii,3] := arr_schet[ii,4] := 0
        select TMP2
        index on upper(_ID_C) to (cur_dir+"tmp2") for schet == ii
        dbeval({|| tmp2->SCHET_ZAP := 0 }) // обнуляем номер позиции в счёте
        use (cur_dir+"tmp_s_id") new alias TS
        index on NIDCASE to (cur_dir+"tmp_ts") for kod == pr_array_schet[i,11]
        go top
        do while !eof()
          select TMP2
          find (upper(ts->ID_C))
          if found()
            tmp2->SCHET_ZAP := ts->NIDCASE
            human->(dbGoto(tmp2->kod_human))
            arr_schet[ii,3] ++
            arr_schet[ii,4] += human->cena_1 // потом исправим при спасении кого-нибудь
          else
            my_debug(,"в счёте не найден пациент с GUID "+ts->ID_C)
            my_debug(,"└─>"+print_array(pr_array_schet[i]))
          endif
          select TS
          skip
        enddo
        ts->(dbCloseArea())
        if fl .or. !(pr_array_schet[i,8] == arr_schet[ii,3] .and. ;
                     pr_array_schet[i,7] == arr_schet[ii,3] .and. ;
                     round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2))
          if fl
            my_debug(,"после исправления:")
          else
            my_debug(,"что-то случилось:")
          endif
          s := lstr(tmp1->_year)+"/"+strzero(tmp1->_month,2)+" "+padr(mn_schet,15)
          s += "max: "+lstr(pr_array_schet[i,8])
          if pr_array_schet[i,8] == arr_schet[ii,3]
            s += " = "
            s1 := "+"
          else
            s += " != "
            s1 := "-"
          endif
          s += lstr(arr_schet[ii,3])+", кол: "+lstr(pr_array_schet[i,7])
          if pr_array_schet[i,7] == arr_schet[ii,3]
            s += " = "
            s1 += "+"
          else
            s += " != "
            s1 += "-"
          endif
          s += lstr(arr_schet[ii,3])+", сум: "+lstr(pr_array_schet[i,5],13,2)
          if round(pr_array_schet[i,5],2) == round(arr_schet[ii,4],2)
            s += " = "
            s1 += "+"
          else
            s += " != "
            s1 += "-"
          endif
          s += lstr(arr_schet[ii,4],13,2)
          my_debug(,s1+s)
        endif
      endif
    next
  endif
  R_Use(dir_server+"schet_",,"SCH")
  index on smo+str(nn,nsh) to (cur_dir+"tmp_sch") for nyear == tmp1->_YEAR .and. nmonth == tmp1->_MONTH
  fl := .f.
  for i := 1 to len(arr_schet)
    fl := .f. ; sKodSMO := arr_schet[i,1]
    if arr_schet[i,9] > 0
      find (sKodSMO+str(arr_schet[i,9],nsh))
      if found() // номер уже занят
        arr_schet[i,9] := 0
      endif
    endif
    fl := (arr_schet[i,9] > 0)
    if !fl
      for mnn := mb to me
        if ascan(arr_schet, {|x| x[1] == sKodSMO .and. x[9] == mnn}) == 0
          find (sKodSMO+str(mnn,nsh))
          if !found() // нашли свободный номер
            fl := .t. ; arr_schet[i,9] := mnn ; exit
          endif
        endif
      next
    endif
    if !fl ; exit ; endif
  next
  if !fl
    close databases
    s := "Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!"
    aadd(aerr,s)
    return func_error(4,s)
  endif
  sch->(dbCloseArea())
  use_base("schet")
  set relation to
  // определим дату счёта, чтобы она не была раньше даты чтения реестра в ТФОМС
  mdate_schet := max(mdate_schet,sys_date)
  strfile(space(10)+"Список составленных счетов:"+hb_eol(),cFileProtokol,.t.)
  select TMP2
  index on str(schet,6)+str(schet_zap,6) to (cur_dir+"tmp2") for schet_zap > 0
  for ii := 1 to len(arr_schet)
    mnn := arr_schet[ii,9]
    sKodSMO := alltrim(arr_schet[ii,1])
    s := "M"+CODE_LPU+iif(sKodSMO=='34',"T","S")+sKodSMO+"_"+;
         right(strzero(tmp1->_YEAR,4),2)+strzero(tmp1->_MONTH,2)+;
         strzero(mnn,nsh)
    mn_schet := sKodSMO+"-"+alltrim(tmp1->_NSCHET)+arr_schet[ii,2]
    stat_msg("Составление реестра случаев по счёту № "+mn_schet)
    //
    c := upper(left(name_sp_tk,1)) // {"H","F"}[p_tip_reestr]+s
    p_tip_reestr := iif(c == "H", 1, 2)
    select SCHET
    AddRec(6)
    arr_schet[ii,8] := mkod := recno()
    schet->KOD := mkod
    schet->NOMER_S := mn_schet
    aadd(arr_s,mn_schet)
    schet->PDATE := dtoc4(mdate_schet)
    schet->KOL   := arr_schet[ii,3]
    schet->SUMMA := arr_schet[ii,4]
    schet->KOL_OST   := arr_schet[ii,3]
    schet->SUMMA_OST := arr_schet[ii,4]
    //
    select SCHET_
    do while schet_->(lastrec()) < mkod
      APPEND BLANK
    enddo
    goto (mkod)
    G_RLock(forever)
    schet_->IFIN       := 1 // источник финансирования;1-ТФОМС(СМО)
    schet_->IS_MODERN  := 0 // является модернизацией, 0-нет
    schet_->IS_DOPLATA := 0 // является доплатой;0-нет
    schet_->BUKVA      := arr_schet[ii,2]
    schet_->NSCHET     := mn_schet
    schet_->DSCHET     := mdate_schet
    schet_->SMO        := sKodSMO
    schet_->NYEAR      := tmp1->_YEAR
    schet_->NMONTH     := tmp1->_MONTH
    schet_->NN         := mnn
    schet_->NAME_XML   := c+s // {"H","F"}[p_tip_reestr]+s
    schet_->XML_REESTR := mXML_REESTR
    schet_->NREGISTR   := 1 // ещё не зарегистрирован
    schet_->CODE := ret_unique_code(mkod,12)
    code_schet := schet_->code
    //
    select MO_XML
    AddRecN()
    mo_xml->KOD    := recno()
    mo_xml->FNAME  := c+s
    mo_xml->FNAME2 := "L"+s
    mo_xml->DFILE  := schet_->DSCHET
    mo_xml->TFILE  := hour_min(seconds())
    mo_xml->TIP_OUT := _XML_FILE_SCHET  // тип высылаемого файла;2-счет
    mo_xml->SCHET   := mkod  // код счета (отсылаемого или обработанного СМО)
    //
    schet_->KOD_XML := mo_xml->KOD
    UnLock
    //
    strfile(lstr(ii)+". "+mn_schet+" от "+date_8(mdate_schet)+" ("+;
            lstr(arr_schet[ii,3])+" чел.) "+;
            inieditspr(A__MENUVERT,glob_arr_smo,int(val(sKodSMO)))+;
            hb_eol(),cFileProtokol,.t.)
    //
    oXmlDoc := HXMLDoc():New()
    oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
    oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    s := '3.11'
    controlVer := tmp1->_YEAR * 100 + tmp1->_MONTH
    if (controlVer >= 202201) .and. (p_tip_reestr == 1) // с января 2022 года
      s := '3.2'
    endif
  
    mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
    mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(arr_schet[ii,3])) // новое поле
    oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
    mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_schet))
    mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
    mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(tmp1->_YEAR ))
    mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(tmp1->_MONTH))
    mo_add_xml_stroke(oXmlNode,"NSCHET" ,mn_schet)
    mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(schet_->DSCHET))
    mo_add_xml_stroke(oXmlNode,"PLAT"   ,schet_->SMO)
    mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(schet->SUMMA,15,2))
    // запись номера счета по больным
    iidserv := 0
    select TMP2
    find (str(ii,6))
    do while tmp2->schet == ii .and. !eof()
      @ maxrow(),0 say str(tmp2->schet_zap/arr_schet[ii,3]*100,6,2)+"%" color cColorSt2Msg
      //
      select T1
      find (str(tmp2->_N_ZAP,6))
      if found() // нашли в отосланном реестре
       kol_sl := iif(int(val(t1->VB_P)) == 1, 2, 1)
       for isl := 1 to kol_sl
        select HUMAN
        goto (tmp2->kod_human)
        if isl == 1 .and. kol_sl == 2
          fl := .f.
          select HUMAN_3
          if human->ishod == 88
            set order to 1
          else
            set order to 2
          endif
          find (str(tmp2->kod_human,7))
          human_3->(G_RLock(forever))
          human_3->schet := mkod
          human_3->schet_zap := tmp2->schet_zap
          if human_3->SCHET_NUM < 99
            human_3->SCHET_NUM := human_3->SCHET_NUM + 1
          endif
          UnLock
          select HUMAN
          goto (human_3->kod)  // встали на 1-й лист учёта
        endif
        select HUMAN
        if isl == 2
          goto (human_3->kod2)  // встали на 2-ой лист учёта
        endif
        human->(G_RLock(forever))
        human->schet := mkod ; human->tip_h := B_SCHET
        human_->(G_RLock(forever))
        human_->schet_zap := tmp2->schet_zap
        if human_->SCHET_NUM < 99
          human_->SCHET_NUM := human_->SCHET_NUM+1
        endif
        UnLock
        a_usl := {}
        select HU
        find (str(human->kod,7))
        do while hu->kod == human->kod .and. !eof()
          if is_usluga_TFOMS(usl->shifr,opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data),human->k_data)
            aadd(a_usl,{hu->(recno()),hu_->REES_ZAP})
          endif
          select HU
          skip
        enddo
        a_fusl := {}
        select MOHU
        find (str(human->kod,7))
        do while mohu->kod == human->kod .and. !eof()
          aadd(a_fusl,{mohu->(recno()),mohu->REES_ZAP})
          skip
        enddo
        if isl == 1
          oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
          mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(human_->schet_zap))
          mo_add_xml_stroke(oZAP,"PR_NOV",t1->PR_NOV)
          oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
          mo_add_xml_stroke(oPAC,"ID_PAC",t1->ID_PAC)
          mo_add_xml_stroke(oPAC,"VPOLIS",t1->VPOLIS)
          if !empty(t1->SPOLIS)
            mo_add_xml_stroke(oPAC,"SPOLIS",t1->SPOLIS)
          endif
          mo_add_xml_stroke(oPAC,"NPOLIS",t1->NPOLIS)
          if !empty(t1->ENP)
            mo_add_xml_stroke(oPAC,"ENP",t1->ENP)
          endif
          //mo_add_xml_stroke(oPAC,"ST_OKATO" ,...) // Регион страхования
          if !empty(t1->smo)
            mo_add_xml_stroke(oPAC,"SMO",t1->smo)
          endif
          mo_add_xml_stroke(oPAC,"SMO_OK",t1->SMO_OK)
          if !empty(t1->SMO_NAM)
            mo_add_xml_stroke(oPAC,"SMO_NAM",t1->SMO_NAM)
          endif
          mo_add_xml_stroke(oPAC,"NOVOR",t1->NOVOR)
          mo_add_xml_stroke(oPAC,"MO_PR",t1->MO_PR)
          if !empty(t1->VNOV_D)
            mo_add_xml_stroke(oPAC,"VNOV_D",t1->VNOV_D)
          endif
          if !empty(t1->INV) // Сведения о первичном признании застрахованного лица инвалидом
           oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
            mo_add_xml_stroke(oDISAB,"INV",t1->INV)
            mo_add_xml_stroke(oDISAB,"DATA_INV",t1->DATA_INV)
            mo_add_xml_stroke(oDISAB,"REASON_INV",t1->REASON_INV)
            if !empty(t1->DS_INV)
              mo_add_xml_stroke(oDISAB,"DS_INV",t1->DS_INV)
            endif
          endif
          oSLUCH := oZAP:Add( HXMLNode():New( "Z_SL" ) )
          mo_add_xml_stroke(oSLUCH,"IDCASE",lstr(human_->schet_zap))
          mo_add_xml_stroke(oSLUCH,"ID_C"  ,t1->ID_C)
          if !empty(t1->DISP)
            mo_add_xml_stroke(oSLUCH,"DISP",t1->DISP) // Тип диспансеризации
          endif
          mo_add_xml_stroke(oSLUCH,"USL_OK",t1->USL_OK)
          mo_add_xml_stroke(oSLUCH,"VIDPOM",t1->VIDPOM)
          if p_tip_reestr == 1
            mo_add_xml_stroke(oSLUCH,"ISHOD",t1->ISHOD)
            if !empty(t1->VB_P)
              mo_add_xml_stroke(oSLUCH,"VB_P",t1->VB_P) // Признак внутрибольничного перевода при оплате законченного случая как суммы стоимостей пребывания пациента в разных профильных отделениях, каждое из которых оплачивается по КСГ
            endif
            mo_add_xml_stroke(oSLUCH,"IDSP",t1->IDSP)
            mo_add_xml_stroke(oSLUCH,"SUMV",t1->sumv)
            if !empty(t1->FOR_POM)
              mo_add_xml_stroke(oSLUCH,"FOR_POM",t1->FOR_POM)
            endif
            if !empty(t1->NPR_MO)
              mo_add_xml_stroke(oSLUCH,"NPR_MO",t1->NPR_MO)
            endif
            if !empty(t1->NPR_DATE)
              mo_add_xml_stroke(oSLUCH,"NPR_DATE",t1->NPR_DATE)
            endif
            mo_add_xml_stroke(oSLUCH,"LPU",t1->LPU)
          else
            if !empty(t1->FOR_POM)
              mo_add_xml_stroke(oSLUCH,"FOR_POM",t1->FOR_POM)
            endif
            mo_add_xml_stroke(oSLUCH,"LPU",t1->LPU)
            mo_add_xml_stroke(oSLUCH,"VBR",t1->VBR)
            mo_add_xml_stroke(oSLUCH,"P_CEL",t1->p_cel)
            mo_add_xml_stroke(oSLUCH,"P_OTK",t1->p_otk) // Признак отказа
          endif
          mo_add_xml_stroke(oSLUCH,"DATE_Z_1",t1->DATE_Z_1)
          mo_add_xml_stroke(oSLUCH,"DATE_Z_2",t1->DATE_Z_2)
          if !empty(t1->kd_z)
            mo_add_xml_stroke(oSLUCH,"KD_Z",t1->kd_z) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
          endif
          for j := 1 to 3
            pole := "t1->VNOV_M"+iif(j==1, "", "_"+lstr(j))
            if !empty(&pole)
              mo_add_xml_stroke(oSLUCH,"VNOV_M",&pole)
            endif
          next
          mo_add_xml_stroke(oSLUCH,"RSLT",t1->RSLT)
          if p_tip_reestr == 1
            if !empty(t1->MSE)
              mo_add_xml_stroke(oSLUCH,"MSE",t1->MSE)
            endif
          else
            mo_add_xml_stroke(oSLUCH,"ISHOD",t1->ISHOD)
            mo_add_xml_stroke(oSLUCH,"IDSP",t1->IDSP)
            mo_add_xml_stroke(oSLUCH,"SUMV",t1->sumv)
          endif
          lal := "t1"
        else
          lal := "t1_1"
          dbSelectArea(lal)
          find (t1->IDCASE)
        endif
        oSL := oSLUCH:Add( HXMLNode():New( "SL" ) )
        mo_add_xml_stroke(oSL,"SL_ID",&lal.->SL_ID)
        if !empty(&lal.->VID_HMP)
          mo_add_xml_stroke(oSL,"VID_HMP",&lal.->VID_HMP)
        endif
        if !empty(&lal.->METOD_HMP)
          mo_add_xml_stroke(oSL,"METOD_HMP",&lal.->METOD_HMP)
        endif
        if !empty(&lal.->LPU_1)
          mo_add_xml_stroke(oSL,"LPU_1",&lal.->LPU_1)
        endif
        if !empty(&lal.->PODR)
          mo_add_xml_stroke(oSL,"PODR",&lal.->PODR)
        endif
        mo_add_xml_stroke(oSL,"PROFIL",&lal.->PROFIL)
        if p_tip_reestr == 1
          if !empty(&lal.->PROFIL_K)
            mo_add_xml_stroke(oSL,"PROFIL_K",&lal.->PROFIL_K)
          endif
          if !empty(&lal.->DET)
            mo_add_xml_stroke(oSL,"DET",&lal.->DET)
          endif
          if !empty(&lal.->P_CEL)
            mo_add_xml_stroke(oSL,"P_CEL",&lal.->P_CEL)
          endif
        endif
        if !empty(&lal.->TAL_D)
          mo_add_xml_stroke(oSL,"TAL_D",&lal.->TAL_D)
          mo_add_xml_stroke(oSL,"TAL_P",&lal.->TAL_P)
          if !empty(&lal.->TAL_NUM)
            mo_add_xml_stroke(oSL,"TAL_NUM",&lal.->TAL_NUM)
          endif
        endif
        mo_add_xml_stroke(oSL,"NHISTORY",&lal.->NHISTORY)
        if !empty(&lal.->P_PER)
          mo_add_xml_stroke(oSL,"P_PER",&lal.->P_PER)
        endif
        mo_add_xml_stroke(oSL,"DATE_1",&lal.->DATE_1)
        mo_add_xml_stroke(oSL,"DATE_2",&lal.->DATE_2)
        if !empty(&lal.->kd)
          mo_add_xml_stroke(oSL,"KD",&lal.->kd) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
        endif

        if ! empty(&lal.->WEI) .and. p_tip_reestr == 1  // по новым правилам ПУМП от 11.01.22
          mo_add_xml_stroke(oSL,"WEI", &lal.->WEI)
        endif
  
        if !empty(&lal.->DS0)
          mo_add_xml_stroke(oSL,"DS0",&lal.->DS0)
        endif
        mo_add_xml_stroke(oSL,"DS1",&lal.->DS1)
        if p_tip_reestr == 2
          if !empty(&lal.->DS1_PR)
          mo_add_xml_stroke(oSL,"DS1_PR",&lal.->DS1_PR)
         endif
         if !empty(&lal.->PR_D_N)
          mo_add_xml_stroke(oSL,"PR_D_N",&lal.->PR_D_N)
         endif
      endif
      if p_tip_reestr == 1
        for j := 1 to 7
          pole := lal+"->DS2"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSL,"DS2",&pole)
          endif
        next
        for j := 1 to 3
          pole := lal+"->DS3"+iif(j==1, "", "_"+lstr(j))
          if !empty(&pole)
            mo_add_xml_stroke(oSL,"DS3",&pole)
          endif
        next
        if !empty(&lal.->C_ZAB)
          mo_add_xml_stroke(oSL,"C_ZAB",&lal.->C_ZAB)
        endif
        if !empty(&lal.->DS_ONK)
          mo_add_xml_stroke(oSL,"DS_ONK",&lal.->DS_ONK)
        endif
        if !empty(&lal.->DN)
          mo_add_xml_stroke(oSL,"DN",&lal.->DN)
        endif
      else // диспансеризация
           for j1 := 1 to 4
            pole := lal+"->DS2N"+iif(j1==1, "", "_"+lstr(j1))
            if !empty(&pole)
             oD := oSL:Add( HXMLNode():New( "DS2_N" ) )
              mo_add_xml_stroke(oD,"DS2",&pole)
              pole := lal+"->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_PR"
              if !empty(&pole)
                mo_add_xml_stroke(oD,"DS2_PR",&pole)
              endif
              pole := lal+"->DS2N"+iif(j1==1, "", "_"+lstr(j1))+"_D"
              if !empty(&pole)
                mo_add_xml_stroke(oD,"PR_D",&pole)
              endif
            endif
           next
           mo_add_xml_stroke(oSL,"DS_ONK",&lal.->DS_ONK)
           select T5
           find (t1->IDCASE+str(isl,6))
           if found()
            oPRESCRIPTION := oSL:Add( HXMLNode():New( "PRESCRIPTION" ) )
            do while t1->IDCASE == t5->IDCASE .and. isl == t5->sluch .and. !eof()
              oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
              if !empty(t5->NAZ_N)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",t5->NAZ_N)
              endif
              if !empty(t5->NAZ_R)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",t5->NAZ_R)
              endif

              // добавил по новому ПУМП от 02.08.2021
              if !empty(t5->NAZ_IDDT)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_IDDOKT",t5->NAZ_IDDT)
              endif
              if !empty(t5->NAZ_SPDT)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SPDOCT",t5->NAZ_SPDT)
              endif

              if !empty(t5->NAZR)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZR",t5->nazr)
              endif
              if !empty(t5->NAZ_SP)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",t5->NAZ_SP)
              endif
              /*for i := 1 to 3
                pole := "t5->NAZ_SP"+lstr(i)
                if !empty(&pole)
                  mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",&pole)
                endif
              next*/
              if !empty(t5->NAZ_V)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",t5->NAZ_V)
              endif
              /*for i := 1 to 3
                pole := "t5->NAZ_V"+lstr(i)
                if !empty(&pole)
                  mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",&pole)
                endif
              next*/
              if !empty(t5->naz_usl)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_USL",t5->naz_usl)
              endif
              if !empty(t5->NAPR_DATE)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_DATE",t5->NAPR_DATE)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_MO",t5->NAPR_MO)
              endif
              if !empty(t5->NAZ_PMP)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",t5->NAZ_PMP)
              endif
              if !empty(t5->NAZ_PK)
                mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",t5->NAZ_PK)
              endif
              select T5
              skip
            enddo
           endif
          endif
          if !empty(&lal.->n_ksg)
           oKSG := oSL:Add( HXMLNode():New( "KSG_KPG" ) )
            mo_add_xml_stroke(oKSG,"N_KSG",&lal.->n_ksg)
            if !empty(&lal.->crit)
             mo_add_xml_stroke(oKSG,"CRIT",&lal.->crit)
            endif
            if !empty(&lal.->crit2)
             mo_add_xml_stroke(oKSG,"CRIT",&lal.->crit2)
            endif
            mo_add_xml_stroke(oKSG,"SL_K",&lal.->sl_k)
            if !empty(&lal.->IT_SL)
             mo_add_xml_stroke(oKSG,"IT_SL",&lal.->IT_SL)
             if !empty(&lal.->kod_kslp)
              oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
               mo_add_xml_stroke(oSLk,"ID_SL",&lal.->kod_kslp)
               mo_add_xml_stroke(oSLk,"VAL_C",&lal.->koef_kslp)
             endif
             if !empty(&lal.->kod_kslp2)
              oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
               mo_add_xml_stroke(oSLk,"ID_SL",&lal.->kod_kslp2)
               mo_add_xml_stroke(oSLk,"VAL_C",&lal.->koef_kslp2)
             endif
             if !empty(&lal.->kod_kslp3)
              oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
               mo_add_xml_stroke(oSLk,"ID_SL",&lal.->kod_kslp3)
               mo_add_xml_stroke(oSLk,"VAL_C",&lal.->koef_kslp3)
             endif
            endif
            if !empty(&lal.->CODE_KIRO)
              oSLk := oKSG:Add( HXMLNode():New( "S_KIRO" ) )
               mo_add_xml_stroke(oSLk,"CODE_KIRO",&lal.->CODE_KIRO)
               mo_add_xml_stroke(oSLk,"VAL_K",&lal.->VAL_K)
            endif
          elseif !empty(&lal.->CODE_MES1)
            mo_add_xml_stroke(oSL,"CODE_MES1",&lal.->CODE_MES1)
          endif
          //
          select T6
          find (t1->IDCASE+str(isl,6))
          do while t1->IDCASE == t6->IDCASE .and. isl == t6->sluch .and. !eof()
            oNAPR := oSL:Add( HXMLNode():New( "NAPR" ) )

            // добавил по новому ПУМП от 02.08.2021
            if !empty(t5->NAZ_IDDT)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_IDDOKT",t6->NAZ_IDDT)
            endif
            if !empty(t5->NAZ_SPDT)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SPDOCT",t6->NAZ_SPDT)
            endif

            mo_add_xml_stroke(oNAPR,"NAPR_DATE",t6->NAPR_DATE)
            if !empty(t6->NAPR_MO)
              mo_add_xml_stroke(oNAPR,"NAPR_MO",t6->NAPR_MO)
            endif
            mo_add_xml_stroke(oNAPR,"NAPR_V",t6->NAPR_V)
            if int(val(t6->NAPR_V)) == 3
              mo_add_xml_stroke(oNAPR,"MET_ISSL",t6->MET_ISSL)
              mo_add_xml_stroke(oNAPR,"NAPR_USL",t6->U_KOD)
            endif
            skip
          enddo
          if !empty(&lal.->PR_CONS)
            oCONS := oSL:Add( HXMLNode():New( "CONS" ) ) // консилиумов м.б.несколько (но у нас один)
             mo_add_xml_stroke(oCONS,"PR_CONS",&lal.->PR_CONS)
             if !empty(&lal.->DT_CONS)
              mo_add_xml_stroke(oCONS,"DT_CONS",&lal.->DT_CONS)
             endif
          endif
          if !empty(&lal.->DS1_T)
           oONK_SL := oSL:Add( HXMLNode():New( "ONK_SL" ) )
            mo_add_xml_stroke(oONK_SL,"DS1_T",&lal.->DS1_T)
            if !empty(&lal.->STAD)
              mo_add_xml_stroke(oONK_SL,"STAD",&lal.->STAD)
            endif
            if !empty(&lal.->ONK_T)
              mo_add_xml_stroke(oONK_SL,"ONK_T",&lal.->ONK_T)
            endif
            if !empty(&lal.->ONK_N)
              mo_add_xml_stroke(oONK_SL,"ONK_N",&lal.->ONK_N)
            endif
            if !empty(&lal.->ONK_M)
              mo_add_xml_stroke(oONK_SL,"ONK_M",&lal.->ONK_M)
            endif
            if !empty(&lal.->MTSTZ)
              mo_add_xml_stroke(oONK_SL,"MTSTZ",&lal.->MTSTZ)
            endif
            if !empty(&lal.->SOD)
              mo_add_xml_stroke(oONK_SL,"SOD",&lal.->SOD)
            endif
            if !empty(t1->K_FR)
              mo_add_xml_stroke(oONK_SL,"K_FR",t1->K_FR)
            endif
            if !empty(&lal.->WEI)
              mo_add_xml_stroke(oONK_SL,"WEI",&lal.->WEI)
            endif
            if !empty(&lal.->HEI)
              mo_add_xml_stroke(oONK_SL,"HEI",&lal.->HEI)
            endif
            if !empty(&lal.->BSA)
              mo_add_xml_stroke(oONK_SL,"BSA",&lal.->BSA)
            endif
            select T7
            find (t1->IDCASE+str(isl,6))
            do while t1->IDCASE == t7->IDCASE .and. isl == t7->sluch .and. !eof()
             oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
              mo_add_xml_stroke(oDIAG,"DIAG_DATE",t7->DIAG_DATE)
              mo_add_xml_stroke(oDIAG,"DIAG_TIP", t7->DIAG_TIP)
              mo_add_xml_stroke(oDIAG,"DIAG_CODE",t7->DIAG_CODE)
              if !empty(t7->DIAG_RSLT)
               mo_add_xml_stroke(oDIAG,"DIAG_RSLT",t7->DIAG_RSLT)
              endif
              if !empty(t7->REC_RSLT)
               mo_add_xml_stroke(oDIAG,"REC_RSLT",t7->REC_RSLT)
              endif
             skip
            enddo
            select T8
            find (t1->IDCASE+str(isl,6))
            do while t1->IDCASE == t8->IDCASE .and. isl == t8->sluch .and. !eof()
             oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
              mo_add_xml_stroke(oPROT,"PROT",t8->PROT)
              mo_add_xml_stroke(oPROT,"D_PROT",t8->D_PROT)
             skip
            enddo
            select T9
            find (t1->IDCASE+str(isl,6))
            do while t1->IDCASE == t9->IDCASE .and. isl == t9->sluch .and. !eof()
             oONK := oONK_SL:Add( HXMLNode():New( "ONK_USL" ) )
              mo_add_xml_stroke(oONK,"USL_TIP",t9->USL_TIP)
              if !empty(t9->HIR_TIP)
               mo_add_xml_stroke(oONK,"HIR_TIP",t9->HIR_TIP)
              endif
              if !empty(t9->LEK_TIP_L)
               mo_add_xml_stroke(oONK,"LEK_TIP_L",t9->LEK_TIP_L)
              endif
              if !empty(t9->LEK_TIP_V)
               mo_add_xml_stroke(oONK,"LEK_TIP_V",t9->LEK_TIP_V)
              endif
              if !empty(t9->LUCH_TIP)
               mo_add_xml_stroke(oONK,"LUCH_TIP",t9->LUCH_TIP)
              endif
              if eq_any(int(val(t9->USL_TIP)),2,4)
                old_lek := space(6) ; old_sh := space(10)
                //цикл по БД лекарств
                select T10
                find (t1->IDCASE+str(isl,6))
                do while t1->IDCASE == t10->IDCASE .and. isl == t10->sluch .and. !eof()
                  if !(old_lek == t10->REGNUM .and. old_sh == t10->CODE_SH)
                   oLEK := oONK:Add( HXMLNode():New( "LEK_PR" ) )
                    mo_add_xml_stroke(oLEK,"REGNUM",t10->REGNUM)
                    mo_add_xml_stroke(oLEK,"CODE_SH",t10->CODE_SH)
                  endif
                    // цикл по датам приёма данного лекарства
                    mo_add_xml_stroke(oLEK,"DATE_INJ",t10->DATE_INJ)
                  old_lek := t10->REGNUM ; old_sh := t10->CODE_SH
                  select T10
                  skip
                enddo
                if !empty(t9->PPTR)
                 mo_add_xml_stroke(oONK,"PPTR",t9->PPTR)
                endif
              endif
              select T9
              skip
            enddo
          endif
          if p_tip_reestr == 1
            mo_add_xml_stroke(oSL,"PRVS",&lal.->PRVS)
            if !empty(&lal.->IDDOKT)
              mo_add_xml_stroke(oSL,"IDDOKT",&lal.->IDDOKT)
            endif
            if !empty(&lal.->ED_COL)
              mo_add_xml_stroke(oSL,"ED_COL",&lal.->ED_COL)
              mo_add_xml_stroke(oSL,"TARIF" ,&lal.->TARIF)
            endif
            mo_add_xml_stroke(oSL,"SUM_M",&lal.->SUM_M)
/////////////// insert LEK_PR
            //цикл по БД лекарств
            select T11
            find (t1->IDCASE + str(isl, 6))
            do while t1->IDCASE == t11->IDCASE .and. isl == t11->sluch .and. !eof()
              oLEK := oSL:Add( HXMLNode():New( "LEK_PR" ) )
              mo_add_xml_stroke(oLEK, "DATA_INJ", t11->DATA_INJ)
              mo_add_xml_stroke(oLEK, "CODE_SH", alltrim(t11->CODE_SH))
              if ! empty(t11->REGNUM)
                mo_add_xml_stroke(oLEK, "REGNUM", t11->REGNUM)
                // mo_add_xml_stroke(oLEK, "CODE_MARK", '')  // для дальнейшего использования
                oDOSE := oLEK:Add( HXMLNode():New( 'LEK_DOSE' ) )
                mo_add_xml_stroke(oDOSE, "ED_IZM", t11->ED_IZM)
                mo_add_xml_stroke(oDOSE, "DOSE_INJ", t11->DOSE_INJ)
                mo_add_xml_stroke(oDOSE, "METHOD_INJ", t11->METHOD_I)
                mo_add_xml_stroke(oDOSE, "COL_INJ", t11->COL_INJ)
              endif
              select T11
              skip
            enddo
///////////////

            if !empty(&lal.->NEXT_VISIT)
              mo_add_xml_stroke(oSL,"NEXT_VISIT",&lal.->NEXT_VISIT)
            endif
            if !empty(&lal.->COMENTSL)
              mo_add_xml_stroke(oSL,"COMENTSL",&lal.->COMENTSL)
            endif
          else
            if !empty(&lal.->ED_COL)
              mo_add_xml_stroke(oSL,"ED_COL",&lal.->ED_COL)
            endif
            mo_add_xml_stroke(oSL,"PRVS",&lal.->PRVS)
            if !empty(&lal.->TARIF)
              mo_add_xml_stroke(oSL,"TARIF" ,&lal.->TARIF)
            endif
            mo_add_xml_stroke(oSL,"SUM_M",&lal.->SUM_M)
          endif
          select T2
          find (t1->IDCASE+str(isl,6))
          do while t1->IDCASE == t2->IDCASE .and. isl == t2->sluch .and. !eof()
            ++iidserv
            if (j := ascan(a_fusl, {|x| x[2] == int(val(t2->IDSERV))} )) > 0
              select MOHU
              goto (a_fusl[j,1])
              mohu->(G_RLock(forever))
              mohu->SCHET_ZAP := iidserv
              UnLock
            else
              j := ascan(a_usl, {|x| x[2] == int(val(t2->IDSERV))} )
              if between(j,1,len(a_usl))
                select HU
                goto (a_usl[j,1])
                hu_->(G_RLock(forever))
                hu_->SCHET_ZAP := iidserv
                UnLock
              endif
            endif
            oUSL := oSL:Add( HXMLNode():New( "USL" ) )
            mo_add_xml_stroke(oUSL,"IDSERV"  ,t2->IDSERV)
            mo_add_xml_stroke(oUSL,"ID_U"    ,t2->ID_U)
            mo_add_xml_stroke(oUSL,"LPU"     ,t2->LPU)
            if !empty(t2->LPU_1)
              mo_add_xml_stroke(oUSL,"LPU_1" ,t2->LPU_1)
            endif
            if !empty(t2->PODR)
              mo_add_xml_stroke(oUSL,"PODR"  ,t2->PODR)
            endif
            mo_add_xml_stroke(oUSL,"PROFIL"  ,t2->PROFIL)
            if !empty(t2->VID_VME)
              mo_add_xml_stroke(oUSL,"VID_VME",t2->VID_VME)
            endif
            if !empty(t2->DET)
              mo_add_xml_stroke(oUSL,"DET"   ,t2->DET)
            endif
            mo_add_xml_stroke(oUSL,"DATE_IN" ,t2->DATE_IN)
            mo_add_xml_stroke(oUSL,"DATE_OUT",t2->DATE_OUT)
            if !empty(t2->DS)
              mo_add_xml_stroke(oUSL,"DS"    ,t2->DS)
            endif
            if !empty(t2->P_OTK)
              mo_add_xml_stroke(oUSL,"P_OTK" ,t2->P_OTK)
            endif
            mo_add_xml_stroke(oUSL,"CODE_USL",t2->CODE_USL)
            mo_add_xml_stroke(oUSL,"KOL_USL" ,t2->KOL_USL)
            mo_add_xml_stroke(oUSL,"TARIF"   ,t2->TARIF)
            mo_add_xml_stroke(oUSL,"SUMV_USL",t2->SUMV_USL)

            if p_tip_reestr == 1 .and. (xml2date(t1->DATE_Z_2) >= 0d20220101) // добавил по новому ПУМП от 18.01.22
              // имплантант
              tmpSelect := select()                            
              select T12
              find (t12->IDCASE + str(isl, 6))
              do while t12->IDCASE == t12->IDCASE .and. isl == t12->sluch .and. !eof()
                oIMPLANT := oUSL:Add( HXMLNode():New( "MED_DEV" ) )
                mo_add_xml_stroke(oIMPLANT, "DATE_MED", T12->DATE_MED)
                mo_add_xml_stroke(oIMPLANT, "CODE_MEDDEV", T12->CODE_DEV)
                mo_add_xml_stroke(oIMPLANT, "NUMBER_SER", T12->NUM_SER)
              enddo
              select(tmpSelect)
            endif

            // добавил по новому ПУМП от 02.08.2021
            if p_tip_reestr == 2 .and. (xml2date(t1->DATE_Z_2) >= 0d20210801)
              if !empty(t2->PRVS) .and. !empty(t2->CODE_MD) // после разговора с Л.Н.Антоновой 18.08.2021
                oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
                mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))
                mo_add_xml_stroke(oMR_USL_N,"PRVS",t2->PRVS)
                mo_add_xml_stroke(oMR_USL_N,"CODE_MD",t2->CODE_MD)
              endif
            // добавил по новому ПУМП от 04-18-02 от 18.01.2022
            elseif p_tip_reestr == 1 .and. (xml2date(t1->DATE_Z_2) >= 0d20220101)
              if !empty(t2->PRVS) .and. !empty(t2->CODE_MD) // после разговора с Л.Н.Антоновой 18.08.2021
                oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
                mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))
                mo_add_xml_stroke(oMR_USL_N,"PRVS",t2->PRVS)
                mo_add_xml_stroke(oMR_USL_N,"CODE_MD",t2->CODE_MD)
              endif
            else
              mo_add_xml_stroke(oUSL,"PRVS"    ,t2->PRVS)
              mo_add_xml_stroke(oUSL,"CODE_MD",t2->CODE_MD)
            endif

            if !empty(t2->COMENTU)
              mo_add_xml_stroke(oUSL,"COMENTU",t2->COMENTU)
            endif
            select T2
            skip
          enddo
          if p_tip_reestr == 2 .and. !empty(&lal.->COMENTSL)
            mo_add_xml_stroke(oSL,"COMENTSL",&lal.->COMENTSL)
          endif
        next isl
      else // не нашли в отосланном реестре - почему?
        func_error(4,'В реестре не найден пациент "'+alltrim(human->fio)+'"')
      endif
      //
      select TMP2
      skip
    enddo
    Commit
    @ maxrow(),0 say " запись" color cColorSt2Msg
    oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
    name_zip := alltrim(mo_xml->FNAME)+szip
    arr_zip := {alltrim(mo_xml->FNAME)+sxml}
    //
    stat_msg("Составление реестра пациентов по счёту № "+mn_schet)
    oXmlDoc := HXMLDoc():New()
    oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
     oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
      s := '3.11'
      if strzero(tmp1->_YEAR,4)+strzero(tmp1->_MONTH,2) > "201910" // с ноября 2019 года
        s := '3.2'
      endif
      mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
      mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(schet_->DSCHET))
      mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
      mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
    select TMP2
    find (str(ii,6))
    do while tmp2->schet == ii .and. !eof()
      @ maxrow(),0 say str(tmp2->schet_zap/arr_schet[ii,3]*100,6,2)+"%" color cColorSt2Msg
      select T3
      find (upper(tmp2->_ID_PAC))
      if found() // нашли в отосланном реестре
        oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
        mo_add_xml_stroke(oPAC,"ID_PAC",t3->ID_PAC)
        mo_add_xml_stroke(oPAC,"FAM"   ,t3->FAM)
        mo_add_xml_stroke(oPAC,"IM"    ,t3->IM)
        if !empty(t3->OT)
          mo_add_xml_stroke(oPAC,"OT"  ,t3->OT)
        endif
        mo_add_xml_stroke(oPAC,"W"     ,t3->W)
        mo_add_xml_stroke(oPAC,"DR"    ,t3->DR)
        if !empty(t3->dost)
          mo_add_xml_stroke(oPAC,"DOST",t3->dost) // отсутствует отчество
        endif
        if !empty(t3->tel)
          mo_add_xml_stroke(oPAC,"TEL",t3->tel)
        endif
        if !empty(t3->FAM_P)
          mo_add_xml_stroke(oPAC,"FAM_P",t3->FAM_P)
          mo_add_xml_stroke(oPAC,"IM_P" ,t3->IM_P)
          if !empty(t3->OT_P)
            mo_add_xml_stroke(oPAC,"OT_P" ,t3->OT_P)
          endif
          mo_add_xml_stroke(oPAC,"W_P"  ,t3->W_P)
          mo_add_xml_stroke(oPAC,"DR_P" ,t3->DR_P)
          if !empty(t3->dost_p)
            mo_add_xml_stroke(oPAC,"DOST_P",t3->dost_p) // отсутствует отчество
          endif
        endif
        if !empty(t3->MR)
          mo_add_xml_stroke(oPAC,"MR",t3->MR)
        endif
        if !empty(t3->DOCNUM)
          mo_add_xml_stroke(oPAC,"DOCTYPE",t3->DOCTYPE)
          if !empty(t3->DOCSER)
            mo_add_xml_stroke(oPAC,"DOCSER",t3->DOCSER)
          endif
          mo_add_xml_stroke(oPAC,"DOCNUM" ,t3->DOCNUM)
        endif
        if !empty(t3->DOCDATE)
          mo_add_xml_stroke(oPAC,"DOCDATE",t3->DOCDATE)
        endif
        if !empty(t3->DOCORG)
          mo_add_xml_stroke(oPAC,"DOCORG",t3->DOCORG)
        endif
        if !empty(t3->SNILS)
          mo_add_xml_stroke(oPAC,"SNILS",t3->SNILS)
        endif
        if !empty(t3->OKATOG)
          mo_add_xml_stroke(oPAC,"OKATOG",t3->OKATOG)
        endif
        if !empty(t3->OKATOP)
          mo_add_xml_stroke(oPAC,"OKATOP",t3->OKATOP)
        endif
      else // не нашли в отосланном реестре
        func_error(4,'В реестре не найден пациент "'+alltrim(tmp2->_ID_PAC)+'"')
      endif
      select TMP2
      skip
    enddo
    @ maxrow(),0 say " запись" color cColorSt2Msg
    oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
    aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
    if chip_create_zipXML(name_zip,arr_zip,.t.)
      // может быть, сделать ещё что-нибудь после записи счёта?
    endif
  next
  // запишем время окончания обработки
  select MO_XML
  goto (mXML_REESTR)
  G_RLock(forever)
  mo_xml->TWORK2 := hour_min(seconds())
  close databases
  if fl_msg
    stat_msg("Запись счетов завершена!") ; mybell(2,OK)
  endif
  return .t.
  
