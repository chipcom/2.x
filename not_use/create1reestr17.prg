#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** 24.02.22
Function create1reestr17(_recno,_nyear,_nmonth)
  Local buf := savescreen(), s, i, j, pole
  local nameArr
  
  Private mpz[100], oldpz[100], atip[100]
  for j := 0 to 99
    pole := "tmp->PZ"+lstr(j)
    mpz[j+1] := oldpz[j+1] := &pole
    atip[j+1] := "-"
    if _nyear < 2018
      if (i := ascan(glob_array_PZ, {|x| x[1] == j })) > 0
        atip[j+1] := glob_array_PZ[i,4]
      endif
    else
      nameArr := 'glob_array_PZ_' + last_digits_year(_nyear)
      // if (i := ascan(glob_array_PZ_18, {|x| x[1] == j })) > 0
      //   atip[j+1] := glob_array_PZ_18[i,4]
      if (i := ascan(&nameArr, {|x| x[1] == j })) > 0
        atip[j+1] := &nameArr.[i,4]
      endif
    endif
  next
  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma, p_blk := {|mkol,msum| f_blk_create1reestr17(_nyear) }
  close databases
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  use (cur_dir+"tmpb") new alias TMP
  set relation to kod_human into HUMAN
  index on upper(human->fio)+dtos(human->k_data) to (cur_dir+"tmpb") for kod_tmp == _recno
  go top
  eval(p_blk)
  if Alpha_Browse(3,0,maxrow()-4,79,"f1create1reestr17",color0,;
                  "Составление реестра случаев за "+mm_month[_nmonth]+str(_nyear,5)+" года","BG+/GR",;
                  .t.,.t.,,,"f2create1reestr17",,;
                  {'═','░','═',"N/BG,W+/N,B/BG,W+/B",,300} )
    if pkol > 0 .and. (j := f_alert({"",;
                    "Каким образом сортировать реестр, отправляемый в ТФОМС",;
                    ""},;
                   {" по ~ФИО пациента "," по ~убыванию стоимости "},;
                   1,"W/RB","G+/RB",maxrow()-6,,"BG+/RB,W+/R,W+/RB,GR+/R" )) > 0
      f_message({"Системная дата: "+date_month(sys_date,.t.),;
                 "Обращаем Ваше внимание, что",;
                 "реестр будет создан с этой датой.",;
                 "",;
                 "Изменить её будет НЕВОЗМОЖНО!",;
                 "",;
                 "Сортировка реестра: "+{"по ФИО пациента","по убыванию стоимости лечения"}[j]},,;
                 "GR+/R","W+/R")
      if f_Esc_Enter("составления реестра")
        restscreen(buf)
        create2reestr17(_recno,_nyear,_nmonth,j)
      endif
    endif
  endif
  close databases
  restscreen(buf)
  return NIL

***** 29.03.16
Function f1create1reestr17(oBrow)
  Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {1,2}, {3,4}) }, n := 30
  oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| padr(human->fio,n) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("План-заказ", {|| padc(f_p_z17(human_->pzkol,tmp->pz,1),10) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Кол-во", {|| padc(f_p_z17(human_->pzkol,tmp->pz,2),6) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(human->n_data),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(human->k_data) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Стоимость; лечения", {|| put_kopE(human->cena_1,10) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  tmp_color := setcolor("N/BG")
  @ maxrow()-3,0 say padr(" <Esc> - выход     <Enter> - подтверждение составления реестра",80)
  @ maxrow()-2,0 say padr(" <Ins> - отметить одного пациента или снять отметку с одного пациента",80)
  @ maxrow()-1,0 say padr(" <+> - отметить всех пациентов (или по одному виду ПЛАНА-ЗАКАЗА) ",80)
  @ maxrow()-0,0 say padr(" <-> - снять со всех отметки (никто не попадает в реестр)",80)
  mark_keys({"<Esc>","<Enter>","<Ins>","<+>","<->","<F9>"},"R/BG")
  setcolor(tmp_color)
  return NIL
  
***** 24.02.22
Function f2create1reestr17(nKey,oBrow)
  Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2
  local nameArr
  
  do case
    case nkey == K_INS
      replace tmp->plus with !tmp->plus
      j := tmp->pz + 1
      if pnyear >= 2018
        nameArr := 'glob_array_PZ_' + last_digits_year(pnyear)
        // i := ascan(glob_array_PZ_18, {|x| x[1] == tmp->PZ })
        i := ascan(&nameArr, {|x| x[1] == tmp->PZ })
      elseif pnyear >= 2016
        i := ascan(glob_array_PZ, {|x| x[1] == tmp->PZ })
      endif
      if tmp->plus
        psumma += human->cena_1 ; pkol++
        if pnyear < 2018
          if i > 0 .and. !empty(glob_array_PZ[i,5])
            mpz[j] ++
          else
            mpz[j] += human_->PZKOL
          endif
        else
          nameArr := 'glob_array_PZ_' + last_digits_year(pnyear)
          // if i > 0 .and. !empty(glob_array_PZ_18[i,5])
          if i > 0 .and. !empty(&nameArr.[i,5])
            mpz[j] ++
          else
            mpz[j] += human_->PZKOL
          endif
        endif
      else
        psumma -= human->cena_1 ; pkol--
        if pnyear < 2018
          if i > 0 .and. !empty(glob_array_PZ[i,5])
            mpz[j] --
          else
            mpz[j] -= human_->PZKOL
          endif
        else
          nameArr := 'glob_array_PZ_' + last_digits_year(pnyear)
          // if i > 0 .and. !empty(glob_array_PZ_18[i,5])
          if i > 0 .and. !empty(&nameArr.[i, 5])
            mpz[j] --
          else
            mpz[j] -= human_->PZKOL
          endif
        endif
      endif
      eval(p_blk)
      k := 0
      keyboard chr(K_TAB)
    case nkey == 43  // +
      arr := {}
      aadd(mas_pmt, "Отметить всех пациентов") ; aadd(arr,-1)
      if !empty(oldpz[1])
        aadd(mas_pmt, "Отметить неопределённых пациентов") ; aadd(arr,0)
      endif
      if pnyear < 2018
        for j := 2 to len(oldpz)
          if !empty(oldpz[j]) .and. (i := ascan(glob_array_PZ, {|x| x[1] == j-1 })) > 0
            aadd(mas_pmt, 'Отметить "'+glob_array_PZ[i,3]+'"') ; aadd(arr,j-1)
          endif
        next
      else
        nameArr := 'glob_array_PZ_' + last_digits_year(pnyear)
        for j := 2 to len(oldpz)
          // if !empty(oldpz[j]) .and. (i := ascan(glob_array_PZ_18, {|x| x[1] == j-1 })) > 0
          if !empty(oldpz[j]) .and. (i := ascan(&nameArr, {|x| x[1] == j-1 })) > 0
            // aadd(mas_pmt, 'Отметить "'+glob_array_PZ_18[i,3]+'"') ; aadd(arr,j-1)
            aadd(mas_pmt, 'Отметить "' + &nameArr.[i, 3]+'"') ; aadd(arr,j-1)
          endif
        next
      endif
      r1 := 12
      r2 := r1 + len(mas_pmt) + 1
      if r2 > maxrow()-2
        r2 := maxrow()-2
        r1 := r2 - len(mas_pmt) - 1
        if r1 < 2
          r1 := 2
        endif
      endif
      if (j := popup_SCR(r1,12,r2,67,mas_pmt,1,color5,.t.)) > 0
        j := arr[j]
        rec := recno()
        buf := save_maxrow()
        mywait()
        if j == -1
          tmp->(dbeval({|| tmp->plus := .t. }))
          psumma := old_summa ; pkol := old_kol
          aeval(mpz, {|x,i| mpz[i] := oldpz[i] })
        else
          psumma := pkol := 0
          afill(mpz,0)
          mpz[j+1] := oldpz[j+1]
          go top
          do while !eof()
            if tmp->pz == j
              tmp->plus := .t.
              psumma += human->cena_1
              pkol++
            else
              tmp->plus := .f.
            endif
            skip
          enddo
        endif
        goto (rec)
        rest_box(buf)
        eval(p_blk)
        k := 0
      endif
    case nkey == 45  //  -
      rec := recno()
      buf := save_maxrow()
      mywait()
      tmp->(dbeval({|| tmp->plus := .f. }))
      goto (rec)
      rest_box(buf)
      psumma := pkol := 0
      afill(mpz,0)
      eval(p_blk)
      k := 0
  endcase
  return k
  
***** 04.12.21 создание XML-файлов реестра
Function create2reestr17(_recno,_nyear,_nmonth,reg_sort)
  Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, ;
        lst, lshifr1, code_reestr, mb, me, nsh, adiag_talon[16]
  //
  Private version_3_1 := (strzero(_nyear,4)+strzero(_nmonth,2) > "201808") // с сентября 18 года
  //
  
  stat_msg("Составление реестра случаев")
  close databases
  nsh := f_mb_me_nsh(_nyear,@mb,@me)
  R_Use(dir_exe+"_mo_mkb",,"MKB_10")
  index on shifr+str(ks,1) to (cur_dir+"_mo_mkb")
  G_Use(dir_server+"mo_rees",,"REES")
  index on str(nn,nsh) to (cur_dir+"tmp_rees") for nyear == _nyear .and. nmonth == _nmonth
  fl := .f.
  for mnn := mb to me
    find (str(mnn,nsh))
    if !found() // нашли свободный номер
      fl := .t. ; exit
    endif
  next
  if !fl
    close databases
    return func_error(10,"Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!")
  endif
  index on str(nschet,6) to (cur_dir+"tmp_rees") for nyear == _nyear
  if !eof()
    go bottom
    mnschet := rees->nschet+1
  endif
  if !between(mnschet,mem_beg_rees,mem_end_rees)
    fl := .f.
    for mnschet := mem_beg_rees to mem_end_rees
      find (str(mnschet,6))
      if !found() // нашли свободный номер
        fl := .t. ; exit
      endif
    next
    if !fl
      close databases
      return func_error(10,"Не удалось найти свободный номер реестра. Проверьте настройки!")
    endif
  endif
  set index to
  AddRecN()
  rees->KOD    := recno()
  rees->NSCHET := mnschet
  rees->DSCHET := sys_date
  rees->NYEAR  := _NYEAR
  rees->NMONTH := _NMONTH
  rees->NN     := mnn
  s := "RM"+CODE_LPU+"T34"+"_"+right(strzero(_NYEAR,4),2)+strzero(_NMONTH,2)+strzero(mnn,nsh)
  rees->NAME_XML := {"H","F"}[p_tip_reestr]+s
  mkod_reestr := rees->KOD
  rees->CODE  := ret_unique_code(mkod_reestr)
  code_reestr := rees->CODE
  //
  G_Use(dir_server+"mo_xml",,"MO_XML")
  AddRecN()
  mo_xml->KOD    := recno()
  mo_xml->FNAME  := rees->NAME_XML
  mo_xml->FNAME2 := "L"+s
  mo_xml->DFILE  := rees->DSCHET
  mo_xml->TFILE  := hour_min(seconds())
  mo_xml->TIP_OUT := _XML_FILE_REESTR // тип высылаемого файла;1-реестр
  mo_xml->REESTR := mkod_reestr
  //
  rees->KOD_XML := mo_xml->KOD
  UnLock
  Commit
  //
  //R_Use(exe_dir+"_mo_v024",cur_dir+"_mo_v024","V024")
  use_base("lusl")
  use_base("luslc")
  use_base("luslf")
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"mo_pers",,"P2")
  R_Use(dir_server+"uslugi",,"USL")
  G_Use(dir_server+"mo_rhum",,"RHUM")
  index on str(REESTR,6) to (cur_dir+"tmp_rhum")
  G_Use(dir_server+"human_u_",,"HU_")
  R_Use(dir_server+"human_u",dir_server+"human_u","HU")
  set relation to recno() into HU_, to u_kod into USL
  R_Use(dir_server+"mo_su",,"MOSU")
  G_Use(dir_server+"mo_hu",dir_server+"mo_hu","MOHU")
  set relation to u_kod into MOSU
  if p_tip_reestr == 1
    R_Use(dir_server+"kart_inv",,"INV")
    index on str(kod,7) to (cur_dir+"tmp_inv")
  endif
  R_Use(dir_server+"kartote2",,"KART2")
  R_Use(dir_server+"kartote_",,"KART_")
  R_Use(dir_server+"kartotek",,"KART")
  set relation to recno() into KART_, to recno() into KART2
  R_Use(dir_server+"mo_onkna",dir_server+"mo_onkna","ONKNA") // онконаправления
  R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
  R_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
  R_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
  G_Use(dir_server+"human_2",,"HUMAN_2")
  G_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
  use (cur_dir+"tmpb") new
  set relation to kod_human into HUMAN
  if reg_sort == 1
    index on upper(human->fio) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
  else
    index on str(pz,2)+str(10000000-human->cena_1,11,2) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
  endif
  pkol := psumma := iusl := 0
  go top
  do while !eof()
    pkol++ ; psumma += human->cena_1
    @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
    select RHUM
    AddRec(6)
    rhum->REESTR := mkod_reestr
    rhum->KOD_HUM := human->kod
    rhum->REES_ZAP := pkol
    human_->(G_RLock(forever))
    if human_->REES_NUM < 99
      human_->REES_NUM := human_->REES_NUM+1
    endif
    human_->REESTR := mkod_reestr
    human_->REES_ZAP := pkol
    UnLock
    if pkol % 2000 == 0
      Commit
    endif
    select TMPB
    skip
  enddo
  select TMPB
  set relation to
  select REES
  G_RLock(forever)
  rees->KOL := pkol
  rees->SUMMA := psumma
  dbUnlockAll()
  dbCommitAll()
  //
  Private arr_usl_otkaz, fl_2_14 := .f.
  //
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    if version_3_1
      s := '3.1'
      fl_2_14 := .t.
    else
      s := '2.12'
      if p_tip_reestr == 1
        if _NYEAR > 2017
          s := '2.13'
          if _NYEAR == 2018 .and. _NMONTH >= 5 // с мая 18 года
            s := '2.14'
            fl_2_14 := .t.
          endif
        endif
      endif
    endif
    mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
    mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(rees->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
    mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(pkol)) // новое поле
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
    mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_reestr))
    mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
    mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(_NYEAR))
    mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(_NMONTH))
    mo_add_xml_stroke(oXmlNode,"NSCHET" ,lstr(rees->NSCHET))
    mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(rees->DSCHET))
    mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(psumma,15,2))
  //
  select RHUM
  set relation to kod_hum into HUMAN
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR==mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
    lshifr_zak_sl := lvidpoms := ""
    a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
    atmpusl := {} ; akslp := {} ; akiro := {} ; tarif_zak_sl := human->cena_1
    v_reabil_slux := 0
    m1veteran := 0
    m1mobilbr := 0  // мобильная бригада
    m1mesto_prov := 0
    m1p_otk := 0    // признак отказа
    m1dopo_na := 0
    m1napr_v_mo := 0 // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    arr_mo_spec := {}
    m1napr_stac := 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    m1profil_stac := 0
    m1napr_reab := 0
    m1profil_kojki := 0
    fl_disp_nabl := .f.
    ldate_next := ctod("")
    //
    is_oncology := f_is_oncology(1)
    if p_tip_reestr == 2
      is_oncology := 0
    endif
    arr_onkna := {}
    select ONKNA
    find (str(human->kod,7))
    do while onkna->kod == human->kod .and. !eof()
      mosu->(dbGoto(onkna->U_KOD))
      aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1})
      skip
    enddo
    //
    mvsod := 0
    select ONKSL
    find (str(human->kod,7))
    //
    arr_onkdi := {}
    select ONKDI
    find (str(human->kod,7))
    do while onkdi->kod == human->kod .and. !eof()
      aadd(arr_onkdi, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
      skip
    enddo
    //
    arr_onkpr := {}
    select ONKPR
    find (str(human->kod,7))
    do while onkpr->kod == human->kod .and. !eof()
      aadd(arr_onkpr, {onkpr->PROT,onkpr->D_PROT})
      skip
    enddo
    //
    select HU
    find (str(human->kod,7))
    do while hu->kod == human->kod .and. !eof()
      lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
      if is_usluga_TFOMS(usl->shifr,lshifr1,human->k_data,,,@lst,,@s)
        lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
        if human_->USL_OK == 3 .and. is_usluga_disp_nabl(lshifr)
          ldate_next := c4tod(human->DATE_OPL)
          fl_disp_nabl := .t.
        endif
        aadd(atmpusl,lshifr)
        if !empty(s) .and. "," $ s
          lvidpoms := s
        endif
        if (hu->stoim_1 > 0 .or. left(lshifr,3) == "71.") .and. (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
          lvidpom := i
        endif
        if f_is_neotl_pom(lshifr)
          lfor_pom := 2 // неотложная
        endif
        if ascan(glob_KSG_dializ,lshifr) > 0 // диализ в 2017 году
          lvidpoms := ""
          lvidpom := 31
        endif
        if lst == 1
          lshifr_zak_sl := lshifr
          if f_is_zak_sl_vr(lshifr) // зак.случай в п-ке
            is_zak_sl_vr := .t.
          else
            is_zak_sl_vr := .t. // КСГ
            if _NYEAR < 2018 // стационар
              if human_->USL_OK == 1 .and. p_tip_reestr == 1
                akslp := f_cena_kslp(hu->stoim,lshifr,iif(human_->NOVOR==0,human->date_r,human_->DATE_R2),human->n_data,human->k_data)
              endif
            else // 18 год
              if human_->USL_OK < 3 .and. p_tip_reestr == 1
                if !empty(human_2->pc1)
                  akslp := List2Arr(human_2->pc1)
                endif
                if !empty(human_2->pc2)
                  akiro := List2Arr(human_2->pc2)
                endif
              endif
            endif
            if !empty(akslp) .or. !empty(akiro)
              otd->(dbGoto(human->OTD))
              f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
              tarif_zak_sl := fcena_oms(lshifr,(human->vzros_reb==0),human->k_data)
            endif
            if eq_any(human_->USL_OK,1,2) .and. human_->PROFIL == 158 .and. is_reabil_slux
              if _NYEAR > 2017
                t_arr := {"1331.0","1332.0","1333.0","1335.0","2127.0","2128.0","2130.0"}
                for i := 1 to len(t_arr)
                  if t_arr[i] == lshifr .and. !between(human_2->PN1,1,3)
                    v_reabil_slux := human_2->PN1
                  endif
                next
              else
                t_arr := {"12???311","12???312","22???117","22???118"}
                for i := 1 to len(t_arr)
                  if like(t_arr[i],lshifr) .and. between(human_2->PN1,1,3)
                    v_reabil_slux := human_2->PN1
                  endif
                next
              endif
            endif
          endif
        else
          aadd(a_usl,hu->(recno()))
        endif
      endif
      select HU
      skip
    enddo
    if is_oncology == 2 .and. human_->USL_OK == 3 .and. fl_disp_nabl // Диспансерное наблюдение
      is_oncology := 1 // для дисп.наблюдения не вводится онкология
    endif
    if !empty(lvidpoms)
      if !eq_ascan(atmpusl,"55.1.2","55.1.3") .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ЭКО-Москва
        lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms) // только для дн.стационара при стационаре
      else
      /*  if eq_ascan(atmpusl,"55.1.3")
          lvidpoms := ret_vidpom_st_dom_licensia(human_->USL_OK,lvidpoms)
        endif
      */
      endif
      if !empty(lvidpoms) .and. !("," $ lvidpoms)
        lvidpom := int(val(lvidpoms))
        lvidpoms := ""
      endif
    endif
    if !empty(lvidpoms)
      if eq_ascan(atmpusl,"55.1.1","55.1.4","55.1.6")
        if "31" $ lvidpoms
          lvidpom := 31
        endif
      elseif eq_ascan(atmpusl,"55.1.2","55.1.3")
        if eq_any(human_->PROFIL,57,68,97) //терапия,педиатр,врач общ.практики
          if "12" $ lvidpoms
            lvidpom := 12
          endif
        else
          if "13" $ lvidpoms
            lvidpom := 13
          endif
        endif
      endif
    endif
    select MOHU
    find (str(human->kod,7))
    do while mohu->kod == human->kod .and. !eof()
      mvsod += mohu->PZKOL
      aadd(a_fusl,mohu->(recno()))
      skip
    enddo
    a_otkaz := {}
    arr_nazn := {}
    if eq_any(human->ishod,101,102) // дисп-ия детей-сирот
      read_arr_DDS(human->kod)
    elseif eq_any(human->ishod,301,302) // профосмотры несовершеннолетних
      arr_usl_otkaz := {}
      read_arr_PN(human->kod)
      if valtype(arr_usl_otkaz) == "A"
        for j := 1 to len(arr_usl_otkaz)
          ar := arr_usl_otkaz[j]
          if valtype(ar) == "A" .and. len(ar) > 9 .and. valtype(ar[5]) == "C" .and. ;
                                                        valtype(ar[10]) == "C" .and. ar[10] $ "io"
            lshifr := alltrim(ar[5])
            ldate := human->N_DATA // дата
            if valtype(ar[9]) == "D"
              ldate := ar[9]
            endif
            if ar[10] == "i" // исследования
              if (i := ascan(np_arr_issled, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0
                aadd(a_otkaz,{lshifr,;
                              ar[6],; // диагноз
                              ldate,; // дата
                              correct_profil(ar[4]),; // профиль
                              ar[2],; // специальность
                              0,;     // цена
                              1})     // 1-отказ,2-невозможность
              endif
            elseif (i := ascan(np_arr_osmotr, {|x| valtype(x[1]) == "C" .and. x[1] == lshifr})) > 0 // осмотры
              if (i := ascan(np_arr_osmotr_KDP2, {|x| x[1] == lshifr })) > 0
                lshifr := np_arr_osmotr_KDP2[i,3]  // замена врачебного приёма на 2.3.*
              endif
              aadd(a_otkaz,{lshifr,;
                            ar[6],; // диагноз
                            ldate,; // дата
                            correct_profil(ar[4]),; // профиль
                            ar[2],; // специальность
                            0,;     // цена
                            1})     // 1-отказ,2-невозможность
            endif
          endif
        next j
      endif
    elseif between(human->ishod,201,205) // дисп-ия I этап или профилактика
      arr_usl_otkaz := {}
      read_arr_DVN(human->kod)
      if valtype(arr_usl_otkaz) == "A" .and. eq_any(human->ishod,201,203) // не II этап
        for j := 1 to len(arr_usl_otkaz)
          ar := arr_usl_otkaz[j]
          if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
            lshifr := alltrim(ar[5])
            if (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
              if valtype(ar[10]) == "N" .and. between(ar[10],1,2)
                aadd(a_otkaz,{lshifr,;
                              ar[6],; // диагноз
                              human->N_DATA,; // дата
                              correct_profil(ar[4]),; // профиль
                              ar[2],; // специальность
                              ar[8],; // цена
                              ar[10]}) // 1-отказ,2-невозможность
              endif
            endif
          endif
        next j
      endif
    endif
    if m1dopo_na > 0
      for i := 1 to 4
        if isbit(m1dopo_na,i)
          aadd(arr_nazn,{3,i}) // теперь каждое назначение в отдельном PRESCRIPTIONS
        endif
      next
    endif
    if between(m1napr_v_mo,1,2) .and. !empty(arr_mo_spec) // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
      for i := 1 to len(arr_mo_spec)
        aadd(arr_nazn,{m1napr_v_mo,arr_mo_spec[i]})
      next
    endif
    if between(m1napr_stac,1,2) .and. m1profil_stac > 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
      aadd(arr_nazn,{iif(m1napr_stac==1,5,4),m1profil_stac})
    endif
    if m1napr_reab == 1 .and. m1profil_kojki > 0
      aadd(arr_nazn,{6,m1profil_kojki})
    endif
    cSMOname := ""
    if alltrim(human_->smo) == '34'
      cSMOname := ret_inogSMO_name(2)
    endif
    mdiagnoz := diag_for_xml(,.t.,,,.t.)
  
    if p_tip_reestr == 1
      if glob_mo[_MO_IS_UCH] .and. ;                    // наше МО имеет прикреплённое население
         human_->USL_OK == 3 .and. ;                    // поликлиника
         kart2->MO_PR == glob_MO[_MO_KOD_TFOMS] .and. ; // прикреплён к нашему МО
         between(kart_->INVALID,1,4)                    // инвалид
        select INV
        find (str(human->kod_k,7))
        if found() .and. !emptyany(inv->DATE_INV,inv->PRICH_INV)
          // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
          fl_DISABILITY := (inv->DATE_INV < human->n_data .and. human->n_data <= addmonth(inv->DATE_INV,12))
        endif
      endif
    else
      afill(adiag_talon,0)
      for i := 1 to 16
        adiag_talon[i] := int(val(substr(human_->DISPANS,i,1)))
      next
    endif
    mdiagnoz3 := {}
    if !empty(human_2->OSL1)
      aadd(mdiagnoz3,human_2->OSL1)
    endif
    if !empty(human_2->OSL2)
      aadd(mdiagnoz3,human_2->OSL2)
    endif
    if !empty(human_2->OSL3)
      aadd(mdiagnoz3,human_2->OSL3)
    endif
  
    oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
     mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(rhum->REES_ZAP))
     mo_add_xml_stroke(oZAP,"PR_NOV",iif(human_->SCHET_NUM > 0, '1', '0')) // если попал в счёт 2-й раз и т.д.
     oPAC := oZAP:Add( HXMLNode():New( "PACIENT" ) )
      mo_add_xml_stroke(oPAC,"ID_PAC",human_->ID_PAC)
      mo_add_xml_stroke(oPAC,"VPOLIS",lstr(human_->VPOLIS))
      if !empty(human_->SPOLIS)
        mo_add_xml_stroke(oPAC,"SPOLIS",human_->SPOLIS)
      endif
      mo_add_xml_stroke(oPAC,"NPOLIS",human_->NPOLIS)
      if len(alltrim(kart2->kod_mis)) == 16
        mo_add_xml_stroke(oPAC,"ENP",kart2->kod_mis) // Единый номер полиса единого образца
      endif
      if empty(cSMOname)
        mo_add_xml_stroke(oPAC,"SMO" ,human_->smo)
      endif
      mo_add_xml_stroke(oPAC,"SMO_OK",iif(empty(human_->OKATO),"18000",human_->OKATO))
      if !empty(cSMOname)
        mo_add_xml_stroke(oPAC,"SMO_NAM",cSMOname)
      endif
      if human_->NOVOR == 0
        mo_add_xml_stroke(oPAC,"NOVOR",lstr(human_->NOVOR))
      else
        mnovor := iif(human_->pol2=="М",'1','2')+;
                  strzero(day(human_->DATE_R2),2)+;
                  strzero(month(human_->DATE_R2),2)+;
                  right(lstr(year(human_->DATE_R2)),2)+;
                  strzero(human_->NOVOR,2)
        mo_add_xml_stroke(oPAC,"NOVOR",mnovor)
      endif
      //mo_add_xml_stroke(oPAC,"MO_PR",???)
      if human_->USL_OK == 1 .and. human_2->VNR > 0
        // стационар + л/у на недоношенного ребёнка
        mo_add_xml_stroke(oPAC,"VNOV_D",lstr(human_2->VNR))
      endif
      if fl_DISABILITY // Сведения о первичном признании застрахованного лица инвалидом
        oDISAB := oPAC:Add( HXMLNode():New( "DISABILITY" ) )
         // группа инвалидности при первичном признании застрахованного лица инвалидом
         mo_add_xml_stroke(oDISAB,"INV",lstr(kart_->invalid))
         // Дата первичного установления инвалидности
         mo_add_xml_stroke(oDISAB,"DATA_INV",date2xml(inv->DATE_INV))
         // Код причины установления  инвалидности
         mo_add_xml_stroke(oDISAB,"REASON_INV",lstr(inv->PRICH_INV))
        if !empty(inv->DIAG_INV) // Код основного заболевания по МКБ-10
         mo_add_xml_stroke(oDISAB,"DS_INV",inv->DIAG_INV)
        endif
      endif
     oSLUCH := oZAP:Add( HXMLNode():New( "SLUCH" ) )
      mo_add_xml_stroke(oSLUCH,"IDCASE"  ,lstr(rhum->REES_ZAP))
      mo_add_xml_stroke(oSLUCH,"ID_C"    ,human_->ID_C)
      if p_tip_reestr == 2
        s := space(3)
        ret_tip_lu(@s)
        if !empty(s)
          mo_add_xml_stroke(oSLUCH,"DISP",s) // Тип диспансеризации
        endif
      endif
      mo_add_xml_stroke(oSLUCH,"USL_OK"  ,lstr(human_->USL_OK))
      mo_add_xml_stroke(oSLUCH,"VIDPOM"  ,lstr(lvidpom))
      @ 10,10 say "HTTCNH________________HTTCNH"
  
      inkey(0)
      do case
        case human_->USL_OK == 1 // стационар
          i := iif(left(human_->FORMA14,1)=='1', 1, 3)
        case human_->USL_OK == 4 // скорая помощь
          i := iif(left(human_->FORMA14,1)=='1', 1, 2)
        otherwise
          i := lfor_pom
      endcase
      // 1 - экстренная, 2 - неотложная, 3 - плановая
      mo_add_xml_stroke(oSLUCH,"FOR_POM",lstr(i))
      if (is_vmp := human_->USL_OK == 1 .and. human_2->VMP == 1 ;// ВМП
                                        .and. !emptyany(human_2->VIDVMP,human_2->METVMP))
        mo_add_xml_stroke(oSLUCH,"VID_HMP",human_2->VIDVMP)
        mo_add_xml_stroke(oSLUCH,"METOD_HMP",lstr(human_2->METVMP))
      endif
      if p_tip_reestr == 1 .and. !empty(human_->NPR_MO) ;
                           .and. !empty(mNPR_MO := ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS])
        mo_add_xml_stroke(oSLUCH,"NPR_MO",mNPR_MO)
        if fl_2_14
          s := iif(empty(human_2->NPR_DATE), human->N_DATA, human_2->NPR_DATE)
          mo_add_xml_stroke(oSLUCH,"NPR_DATE",date2xml(s))
        endif
      endif
      if human_->USL_OK == 1 .and. !fl_2_14 // стационар
        i := int(val(left(human_->FORMA14,1)))
        mo_add_xml_stroke(oSLUCH,"EXTR",lstr(i+1))
      endif
      mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
      otd->(dbGoto(human->OTD))
      if human_->USL_OK == 1 .and. is_otd_dep .and. _NYEAR > 2017
        f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
        if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
          i := 1
        endif
        mo_add_xml_stroke(oSLUCH,"LPU_1",lstr(mm_otd_dep[i,3]))
        mo_add_xml_stroke(oSLUCH,"PODR" ,lstr(glob_otd_dep))
      elseif human_->USL_OK == 1 .and. is_adres_podr .and. _NYEAR == 2017 .and. human->K_DATA >= d_01_08_2017
        f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
        mo_add_xml_stroke(oSLUCH,"PODR"  ,glob_podr)
      endif
      mo_add_xml_stroke(oSLUCH,"PROFIL"  ,lstr(human_->PROFIL))
      if p_tip_reestr == 1
        if human_->USL_OK < 3 .and. fl_2_14
          mo_add_xml_stroke(oSLUCH,"PROFIL_K",lstr(human_2->PROFIL_K))
        endif
        mo_add_xml_stroke(oSLUCH,"DET"   ,iif(human->VZROS_REB==0,'0','1'))
        if human_->USL_OK == 3 .and. fl_2_14
          // s := "2.6"
          // if (i := ascan(glob_V025, {|x| x[2] == human_->povod})) > 0
          //   s := glob_V025[i,3]
          // endif
          if (s := get_IDPC_from_V025_by_number(human_->povod)) == ''
            s := '2.6'
          endif
          mo_add_xml_stroke(oSLUCH,"P_CEL",s)
        endif
      else
        mo_add_xml_stroke(oSLUCH,"VBR"   ,iif(m1mobilbr==0,'0','1'))
      endif
      if is_vmp
        mo_add_xml_stroke(oSLUCH,"TAL_D" ,date2xml(human_2->TAL_D)) // Дата выдачи талона на ВМП
        mo_add_xml_stroke(oSLUCH,"TAL_P" ,date2xml(human_2->TAL_P)) // Дата планируемой госпитализации в соответствии с талоном на ВМП
        if fl_2_14
          mo_add_xml_stroke(oSLUCH,"TAL_NUM" ,human_2->TAL_NUM) // номер талона на ВМП
        endif
      endif
      mo_add_xml_stroke(oSLUCH,"NHISTORY",iif(empty(human->UCH_DOC),lstr(human->kod),human->UCH_DOC))
      if !is_vmp .and. eq_any(human_->USL_OK,1,2)
        mo_add_xml_stroke(oSLUCH,"P_PER" ,lstr(human_2->P_PER)) // Признак поступления/перевода
      elseif p_tip_reestr == 2
        mo_add_xml_stroke(oSLUCH,"P_OTK" ,iif(m1p_otk==0,'0','1')) // Признак отказа
      endif
      mo_add_xml_stroke(oSLUCH,"DATE_1"  ,date2xml(human->N_DATA))
      mo_add_xml_stroke(oSLUCH,"DATE_2"  ,date2xml(human->K_DATA))
      if p_tip_reestr == 1 .and. !empty(human_->kod_diag0)
        mo_add_xml_stroke(oSLUCH,"DS0"   ,human_->kod_diag0)
      endif
      mo_add_xml_stroke(oSLUCH,"DS1"     ,rtrim(mdiagnoz[1]))
      if p_tip_reestr == 2
        s := 0
        if adiag_talon[1] == 1 // впервые
          mo_add_xml_stroke(oSLUCH,"DS1_PR",'1')
          if adiag_talon[2] == 2
            s := 1
          endif
        elseif adiag_talon[1] == 2 // ранее
          if adiag_talon[2] == 1
            s := 2 // состоит
          elseif adiag_talon[2] == 2
            s := 1 // взят
          endif
        endif
        if version_3_1 .and. human->OBRASHEN == '1'
          mo_add_xml_stroke(oSLUCH,"DS_ONK",'1')
        endif
        mo_add_xml_stroke(oSLUCH,"PR_D_N",lstr(s))
      endif
      if p_tip_reestr == 1
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
            mo_add_xml_stroke(oSLUCH,"DS2" ,rtrim(mdiagnoz[i]))
          endif
        next
        for i := 1 to len(mdiagnoz3) // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
          if !empty(mdiagnoz3[i])
            mo_add_xml_stroke(oSLUCH,"DS3",rtrim(mdiagnoz3[i]))
          endif
        next
        if version_3_1 .and. human_->USL_OK < 4
          if human->OBRASHEN == '1' .and. is_oncology < 2 //.and. human_->PROFIL != 158
            mo_add_xml_stroke(oSLUCH,"DS_ONK",'1')
          endif
          if human_->USL_OK == 3
            //mo_add_xml_stroke(oSLUCH,"C_ZAB",'1')
          endif
        endif
        if human_->USL_OK == 3 .and. fl_2_14 .and. human_->povod == 4 // Обязательно, если P_CEL=1.3
          s := 2 // взят
          if adiag_talon[1] == 2 // ранее
            if adiag_talon[2] == 1
              s := 1 // состоит
            elseif adiag_talon[2] == 2
              s := 2 // взят
            elseif adiag_talon[2] == 3 // снят
              s := 4 // снят по причине выздоровления
            elseif adiag_talon[2] == 4
              s := 6 // снят по другим причинам
            endif
          endif
          mo_add_xml_stroke(oSLUCH,"DN",lstr(s))
        endif
        //mo_add_xml_stroke(oSLUCH,"MSE",'1')
        if human_->USL_OK == 1 // стационар
          // вес недоношенных детей для л/у матери
          if human_2->VNR1 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR1))
          endif
          if human_2->VNR2 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR2))
          endif
          if human_2->VNR3 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(human_2->VNR3))
          endif
        endif
      else // диспансеризация
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
           oDiag := oSLUCH:Add( HXMLNode():New( "DS2_N" ) )
            mo_add_xml_stroke(oDiag,"DS2",rtrim(mdiagnoz[i]))
            s := 0
            if adiag_talon[i*2-1] == 1 // впервые
              mo_add_xml_stroke(oDiag,"DS2_PR",'1')
              if adiag_talon[i*2] == 2
                s := 1
              endif
            elseif adiag_talon[i*2-1] == 2 // ранее
              if adiag_talon[i*2] == 1
                s := 2 // состоит
              elseif adiag_talon[i*2] == 2
                s := 1 // взят
              endif
            endif
            mo_add_xml_stroke(oDiag,"PR_D",lstr(s))
          endif
        next
      endif
      if is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSLUCH,"CODE_MES1",lshifr_zak_sl)
      endif
      if version_3_1 .and. human_->USL_OK < 4 .and. is_oncology > 0
        for j := 1 to len(arr_onkna)
         oNAPR := oSLUCH:Add( HXMLNode():New( "NAPR" ) )
          mo_add_xml_stroke(oNAPR,"NAPR_DATE",date2xml(arr_onkna[j,1]))
          mo_add_xml_stroke(oNAPR,"NAPR_V",lstr(arr_onkna[j,2]))
          if arr_onkna[j,2] == 3
            mo_add_xml_stroke(oNAPR,"MET_ISSL",lstr(arr_onkna[j,3]))
            mo_add_xml_stroke(oNAPR,"NAPR_USL",arr_onkna[j,4])
          endif
        next j
        if is_oncology == 2
         oONK_SL := oSLUCH:Add( HXMLNode():New( "ONK_SL" ) )
          mo_add_xml_stroke(oONK_SL,"DS1_T",lstr(onksl->DS1_T))
          if .f. // between(onksl->PR_CONS,1,3)
            //mo_add_xml_stroke(oONK_SL,"PR_CONS",lstr(onksl->PR_CONS))
            //mo_add_xml_stroke(oONK_SL,"DT_CONS",date2xml(onksl->DT_CONS))
          endif
          mo_add_xml_stroke(oONK_SL,"STAD",lstr(onksl->STAD))
          mo_add_xml_stroke(oONK_SL,"ONK_T",lstr(onksl->ONK_T))
          mo_add_xml_stroke(oONK_SL,"ONK_N",lstr(onksl->ONK_N))
          mo_add_xml_stroke(oONK_SL,"ONK_M",lstr(onksl->ONK_M))
          if between(onksl->DS1_T,1,2) .and. onksl->MTSTZ == 1
            mo_add_xml_stroke(oONK_SL,"MTSTZ",lstr(onksl->MTSTZ))
          endif
          for j := 1 to len(arr_onkdi)
           oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
            if arr_onkdi[j,2] == 0
              mo_add_xml_stroke(oDIAG,"DIAG_DATE",date2xml(arr_onkdi[j,1]))
            else
              mo_add_xml_stroke(oDIAG,"DIAG_TIP", lstr(arr_onkdi[j,2]))
              mo_add_xml_stroke(oDIAG,"DIAG_CODE",lstr(arr_onkdi[j,3]))
              mo_add_xml_stroke(oDIAG,"DIAG_RSLT",lstr(arr_onkdi[j,4]))
            endif
          next j
          for j := 1 to len(arr_onkpr)
           oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
            mo_add_xml_stroke(oPROT,"PROT",lstr(arr_onkpr[j,1]))
            mo_add_xml_stroke(oPROT,"D_PROT",date2xml(arr_onkpr[j,2]))
          next j
          if mvsod > 0
            mo_add_xml_stroke(oONK_SL,"SOD",lstr(mvsod,6,2))
          endif
        endif
      endif
      mo_add_xml_stroke(oSLUCH,"RSLT",lstr(human_->RSLT_NEW))
      if p_tip_reestr == 2 .and. len(arr_nazn) > 0
        oPRESCRIPTION := oSLUCH:Add( HXMLNode():New( "PRESCRIPTION" ) )
        for j := 1 to len(arr_nazn)
         oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
          if version_3_1
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j))
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(arr_nazn[j,1]))
          else
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZR",lstr(arr_nazn[j,1]))
          endif
          if eq_any(arr_nazn[j,1],1,2)
            for i := 1 to len(arr_nazn[j,2])
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",lstr(arr_nazn[j,2,i]))
            next
          elseif arr_nazn[j,1] == 3
            for i := 1 to len(arr_nazn[j,2])
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_nazn[j,2,i]))
            next
          elseif eq_any(arr_nazn[j,1],4,5)
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",lstr(arr_nazn[j,2]))
          elseif arr_nazn[j,1] == 6
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",lstr(arr_nazn[j,2]))
          endif
        next
      endif
      mo_add_xml_stroke(oSLUCH,"ISHOD",lstr(human_->ISHOD_NEW))
      mo_add_xml_stroke(oSLUCH,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
      if p_tip_reestr == 1 .and. ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)
        mo_add_xml_stroke(oSLUCH,"IDDOKT","0")
      else
        p2->(dbGoto(human_->vrach))
        mo_add_xml_stroke(oSLUCH,"IDDOKT",p2->snils)
      endif
      mo_add_xml_stroke(oSLUCH,"IDSP"    ,lstr(human_->IDSP))
      if is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSLUCH,"ED_COL",'1')
        mo_add_xml_stroke(oSLUCH,"TARIF" ,lstr(tarif_zak_sl,10,2))
      endif
      mo_add_xml_stroke(oSLUCH,"SUMV"    ,lstr(human->cena_1,10,2))
      if p_tip_reestr == 1
        if _nyear > 2017 .and. !empty(human_2->pc3) .and. !left(human_2->pc3,1) == '6' // кроме "старости"
          mo_add_xml_stroke(oSLUCH,"AD_CRITERION",human_2->pc3)
          /*if fl_2_14
            select V024
            find (human_2->pc3)
            if found()
              mo_add_xml_stroke(oSLUCH,"DKK2",human_2->pc3)
            endif
          endif*/
        endif
        if !empty(akslp)
          mo_add_xml_stroke(oSLUCH,"IT_SL",lstr(akslp[2],4,2))
        endif
        if _nyear > 2017 .and. !empty(akiro)
          oSL := oSLUCH:Add( HXMLNode():New( "S_KIRO" ) )
           mo_add_xml_stroke(oSL,"CODE_KIRO",lstr(akiro[1]))
           mo_add_xml_stroke(oSL,"VAL_K",lstr(akiro[2],4,2))
        endif
        if !empty(ldate_next)
          mo_add_xml_stroke(oSLUCH,"NEXT_VISIT",date2xml(bom(ldate_next)))
        endif
      endif
      if !is_zak_sl
        for j := 1 to len(a_usl)
          select HU
          goto (a_usl[j])
          hu_->(G_RLock(forever))
          hu_->REES_ZAP := ++iusl
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(hu_->REES_ZAP))
          mo_add_xml_stroke(oUSL,"ID_U"    ,hu_->ID_U)
          if hu->is_edit == 1 // гематологические исследования
            mo_add_xml_stroke(oUSL,"LPU"   ,'125901') // т.е. иссл-ие проводится в КДП №2
          elseif lshifr == "4.20.2" // жидкостная цитология
            mo_add_xml_stroke(oUSL,"LPU"   ,'103001') // т.е. иссл-ие проводится в онкологии
          else
            mo_add_xml_stroke(oUSL,"LPU"   ,CODE_LPU)
          endif
          if p_tip_reestr == 1
            if human_->USL_OK == 1 .and. is_otd_dep .and. _NYEAR > 2017
              otd->(dbGoto(hu->OTD))
              f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
              if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
                i := 1
              endif
              mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
              mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
            elseif hu->KOL_RCP < 0 .and. DomUslugaTFOMS(lshifr)
              mo_add_xml_stroke(oUSL,"PODR",'0')
            endif
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(hu_->PROFIL))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"DET"   ,iif(human->VZROS_REB==0,'0','1'))
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(hu->DATE_U)))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(hu_->DATE_U2)))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"DS"    ,hu_->kod_diag)
          else
            mo_add_xml_stroke(oUSL,"P_OTK" ,'0')
          endif
          mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(hu->KOL_1,6,2))
          mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(hu->U_CENA,10,2))
          mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(hu->STOIM_1,10,2))
          mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
          if c4tod(hu->DATE_U) < human->n_data ; // если сделано ранее
                         .or. eq_any(hu->is_edit,-1,1) .or. lshifr == "4.20.2" // не заполняется код врача
            mo_add_xml_stroke(oUSL,"CODE_MD",'0')
          else
            p2->(dbGoto(hu->kod_vr))
            mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
          endif
        next
      endif
      if p_tip_reestr == 2 .and. len(a_otkaz) > 0 // отказы (диспансеризация или профосмоты несовешеннолетних)
        for j := 1 to len(a_otkaz)
          oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(++iusl))
          mo_add_xml_stroke(oUSL,"ID_U"    ,mo_guid(3,iusl))
          mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(a_otkaz[j,4]))
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(a_otkaz[j,3]))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(a_otkaz[j,3]))
          mo_add_xml_stroke(oUSL,"P_OTK"   ,lstr(a_otkaz[j,7]))
          mo_add_xml_stroke(oUSL,"CODE_USL",a_otkaz[j,1])
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(1,6,2))
          mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(a_otkaz[j,6],10,2))
          mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(a_otkaz[j,6],10,2))
          mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(a_otkaz[j,5],_NYEAR))
          mo_add_xml_stroke(oUSL,"CODE_MD" ,'0') // отказ => 0
        next
      endif
      if p_tip_reestr == 1 .and. len(a_fusl) > 0 // добавляем операции
        for j := 1 to len(a_fusl)
          select MOHU
          goto (a_fusl[j])
          mohu->(G_RLock(forever))
          mohu->REES_ZAP := ++iusl
          lshifr := alltrim(mosu->shifr1)
          oUSL := oSLUCH:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(mohu->REES_ZAP))
          mo_add_xml_stroke(oUSL,"ID_U"    ,mohu->ID_U)
          mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
          if human_->USL_OK == 1 .and. is_otd_dep .and. _NYEAR > 2017
            otd->(dbGoto(hu->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
              i := 1
            endif
            mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
            mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(mohu->PROFIL))
          mo_add_xml_stroke(oUSL,"VID_VME",lshifr)
          mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(mohu->DATE_U)))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(mohu->DATE_U2)))
          mo_add_xml_stroke(oUSL,"DS"      ,mohu->kod_diag)
          mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(mohu->KOL_1,6,2))
          mo_add_xml_stroke(oUSL,"TARIF"   ,'0')//lstr(mohu->U_CENA,10,2))
          mo_add_xml_stroke(oUSL,"SUMV_USL",'0')//lstr(mohu->STOIM_1,10,2))
          mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))
          if is_telemedicina(lshifr) // не заполняется код врача
            mo_add_xml_stroke(oUSL,"CODE_MD",'0')
          else
            p2->(dbGoto(mohu->kod_vr))
            mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
          endif
          if is_oncology == 2 .and. mohu->USL_TIP > 0 .and. human_->USL_OK < 3
           oONK := oUSL:Add( HXMLNode():New( "ONK_USL" ) )
            mo_add_xml_stroke(oONK,"USL_TIP",lstr(iif(mohu->USL_TIP==9,0,mohu->USL_TIP)))
            if mohu->USL_TIP == 1
              mo_add_xml_stroke(oONK,"HIR_TIP",lstr(mohu->HIR_TIP))
            endif
            if mohu->USL_TIP == 2
              mo_add_xml_stroke(oONK,"LEK_TIP_L",lstr(mohu->LEK_TIP_L))
              mo_add_xml_stroke(oONK,"LEK_TIP_V",lstr(mohu->LEK_TIP_V))
            endif
            if eq_any(mohu->USL_TIP,3,4)
              mo_add_xml_stroke(oONK,"LUCH_TIP",lstr(mohu->LUCH_TIP))
            endif
          endif
        next
      endif
      if p_tip_reestr == 1 .and. !empty(akslp)
        oSL := oSLUCH:Add( HXMLNode():New( "SL_KOEFF" ) )
         oCOEFF := oSL:Add( HXMLNode():New( "COEFF" ) )
          mo_add_xml_stroke(oCOEFF,"CODE_SL",lstr(akslp[1]))
          mo_add_xml_stroke(oCOEFF,"VAL_C",lstr(akslp[2],4,2))
      endif
      j := 0 ; fl := .f.
      if p_tip_reestr == 1
        if (ibrm := f_oms_beremenn(mdiagnoz[1])) == 1 .and. eq_any(human_->profil,136,137) // акушерству и гинекологии
          j := iif(human_2->pn2 == 1, 4, 3)
        elseif ibrm == 2 .and. human_->USL_OK == 3 // поликлиника
          j := iif(human_2->pn2 == 1, 5, 6)
          if j == 5 .and. !eq_any(human_->profil,136,137)
            j := 6  // т.е. только акушер-гинеколог может поставить на учёт по беременности
          endif
        elseif ibrm == 3 .and. human->K_DATA > stod("20170619") // основной диагноз - онкология с 20 июня
          j := iif(human_2->pn2 == 1, 8, 7)
        endif
      elseif p_tip_reestr == 2
        if between(human->ishod,201,205) // ДВН
          j := iif(human->RAB_NERAB==0,20,iif(human->RAB_NERAB==1,10,14))
          if human->ishod != 203 .and. m1veteran == 1
            j := iif(human->RAB_NERAB==0, 21, 11)
          endif
        elseif between(human->ishod,301,302) .and. human->K_DATA >= d_01_05_2018
          j := iif(between(m1mesto_prov,0,1), m1mesto_prov, 0)
          fl := .t.
        endif
      elseif v_reabil_slux > 0
        j := v_reabil_slux - 1
      endif
      if j > 0 .or. fl
        mo_add_xml_stroke(oSLUCH,"COMENTSL",lstr(j))
      endif
    select RHUM
    if rhum->REES_ZAP % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    skip
  enddo
  dbUnlockAll()
  dbCommitAll()
  stat_msg("Запись XML-файла реестра случаев")
  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  name_zip := alltrim(mo_xml->FNAME)+szip
  aadd(arr_zip, alltrim(mo_xml->FNAME)+sxml)
  //
  stat_msg("Составление реестра пациентов")
  oXmlDoc := HXMLDoc():New()
  oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
   oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
    mo_add_xml_stroke(oXmlNode,"VERSION" ,'2.12')
    mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(rees->DSCHET))
    mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
    mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
  select RHUM
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    arr_fio := retFamImOt(2,.f.)
    oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
    mo_add_xml_stroke(oPAC,"ID_PAC" ,human_->ID_PAC)
    if human_->NOVOR == 0
      mo_add_xml_stroke(oPAC,"FAM"  ,arr_fio[1])
      mo_add_xml_stroke(oPAC,"IM"   ,arr_fio[2])
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"OT" ,arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,"W"    ,iif(human->pol=="М",'1','2'))
      mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human->date_r))
      if empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"DOST",'1') // отсутствует отчество
      endif
      if p_tip_reestr == 2 // Указывается только для диспансеризации при предоставлении сведений
        if     len(alltrim(kart_->PHONE_H)) == 11
          mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_H,2))
        elseif len(alltrim(kart_->PHONE_M)) == 11
          mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_M,2))
        elseif len(alltrim(kart_->PHONE_W)) == 11
          mo_add_xml_stroke(oPAC,"TEL",substr(kart_->PHONE_W,2))
        endif
      endif
    else
      mo_add_xml_stroke(oPAC,"W"    ,iif(human_->pol2=="М",'1','2'))
      mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human_->date_r2))
      mo_add_xml_stroke(oPAC,"FAM_P",arr_fio[1])
      mo_add_xml_stroke(oPAC,"IM_P" ,arr_fio[2])
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"OT_P",arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,"W_P"  ,iif(human->pol=="М",'1','2'))
      mo_add_xml_stroke(oPAC,"DR_P" ,date2xml(human->date_r))
      if empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"DOST_P",'1') // отсутствует отчество
      endif
    endif
    if !empty(smr := del_spec_symbol(kart_->mesto_r))
      mo_add_xml_stroke(oPAC,"MR",smr)
    endif
    if human_->vpolis == 3 .and. emptyany(kart_->nom_ud,kart_->nom_ud)
      // для нового полиса паспорт необязателен
    else
      mo_add_xml_stroke(oPAC,"DOCTYPE",lstr(kart_->vid_ud))
      if !empty(kart_->ser_ud)
        mo_add_xml_stroke(oPAC,"DOCSER",kart_->ser_ud)
      endif
      mo_add_xml_stroke(oPAC,"DOCNUM",kart_->nom_ud)
    endif
    if !empty(kart->snils)
      mo_add_xml_stroke(oPAC,"SNILS",transform(kart->SNILS,picture_pf))
    endif
    if human_->vpolis == 3 .and. empty(kart_->okatog)
      // для нового полиса место регистрации необязательно
    else
      mo_add_xml_stroke(oPAC,"OKATOG" ,kart_->okatog)
    endif
    if len(alltrim(kart_->okatop)) == 11
      mo_add_xml_stroke(oPAC,"OKATOP",kart_->okatop)
    endif
    select RHUM
    skip
  enddo
  stat_msg("Запись XML-файла реестра пациентов")
  oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
  aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
  //
  close databases
  if chip_create_zipXML(name_zip,arr_zip,.t.)
    keyboard chr(K_TAB)+chr(K_ENTER)
  endif
  return NIL
  
***** 21.05.17
Function f_blk_create1reestr17(_nyear)
Local i, s, ta[2], sh := maxcol()+1
s := "Случаев - "+expand_value(pkol)+" на сумму "+expand_value(psumma,2)+" руб."
@ 0,0 say padc(s,sh) color color1
s := ""
for i := 1 to len(mpz)
  if !empty(mpz[i])
    s += alltrim(str_0(mpz[i],9,2))+" "+atip[i]+", "
  endif
next
if !empty(s)
  s := "(п/з: "+substr(s,1,len(s)-2)+")"
endif
perenos(ta,s,sh)
for i := 1 to 2
  @ i,0 say padc(alltrim(ta[i]),sh) color color1
next
return NIL

** 10.06.22
function f_p_z17(_pzkol, _pz, k)
  Local s, s2, i
  local nameArr

  if pnyear < 2018 .and. _PZ == 62
    s := "УЕТ"
    s2 := ltrim(str(_pzkol, 9, 2))
  else
    s2 := alltrim(str_0(_pzkol, 9, 2))
    s := atip[_PZ + 1]
    if pnyear < 2018
      if (i := ascan(glob_array_PZ, {|x| x[1] == _PZ })) > 0 .and. !empty(glob_array_PZ[i, 5])
        s2 += glob_array_PZ[i, 5]
      endif
    else
      nameArr := 'glob_array_PZ_' + last_digits_year(pnyear)
      if (i := ascan(&nameArr, {|x| x[1] == _PZ })) > 0 .and. !empty(&nameArr.[i, 5])
        s2 += &nameArr.[i, 5]
      endif
    endif
  endif
  return iif(k == 1, s, s2)

