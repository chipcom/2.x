***** реестры/счета с 2019 года
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static sadiag1 := {}

***** 19.01.20
Function create1reestr19(_recno,_nyear,_nmonth)
  Local buf := savescreen(), s, i, j, pole
  Private mpz[100], oldpz[100], atip[100], p_array_PZ := iif(_nyear > 2019, glob_array_PZ_20, glob_array_PZ_19)
  for j := 0 to 99
    pole := "tmp->PZ"+lstr(j)
    mpz[j+1] := oldpz[j+1] := &pole
    atip[j+1] := "-"
    if (i := ascan(p_array_PZ, {|x| x[1] == j })) > 0
      atip[j+1] := p_array_PZ[i,4]
    endif
  next
  Private pkol := tmp->kol, psumma := tmp->summa, pnyear := _nyear
  Private old_kol := pkol, old_summa := psumma, p_blk := {|mkol,msum| f_blk_create1reestr19(_nyear) }
  close databases
  R_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  set order to 2
  R_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_
  use (cur_dir+"tmpb") new alias TMP
  set relation to kod_human into HUMAN
  index on upper(human->fio)+dtos(tmp->k_data) to (cur_dir+"tmpb") for kod_tmp == _recno
  go top
  eval(p_blk)
  if Alpha_Browse(3,0,maxrow()-4,79,"f1create1reestr19",color0,;
                  "Составление реестра случаев за "+mm_month[_nmonth]+str(_nyear,5)+" года","BG+/GR",;
                  .t.,.t.,,,"f2create1reestr19",,;
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
        create2reestr19(_recno,_nyear,_nmonth,j)
      endif
    endif
  endif
  close databases
  restscreen(buf)
  return NIL
  
  ***** 21.05.17
  Function f_blk_create1reestr19(_nyear)
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
  
  ***** 19.01.20
  Static Function f_p_z19(_pzkol,_pz,k)
  Local s, s2, i
  s2 := alltrim(str_0(_pzkol,9,2))
  s := atip[_PZ+1]
  if (i := ascan(p_array_PZ, {|x| x[1] == _PZ })) > 0 .and. !empty(p_array_PZ[i,5])
    s2 += p_array_PZ[i,5]
  endif
  return iif(k == 1, s, s2)
  
  ***** 06.02.19
  Function f1create1reestr19(oBrow)
  Local oColumn, tmp_color, blk_color := {|| if(tmp->plus, {1,2}, {3,4}) }, n := 32
  oColumn := TBColumnNew(" ", {|| if(tmp->plus,""," ") })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center("Ф.И.О. больного",n), {|| iif(tmp->ishod==89,padr(human->fio,n-4)+" 2сл",padr(human->fio,n)) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("План-заказ", {|| padc(f_p_z19(tmp->pzkol,tmp->pz,1),10) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Кол-во", {|| padc(f_p_z19(tmp->pzkol,tmp->pz,2),6) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Нача-; ло", {|| left(dtoc(tmp->n_data),5) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Окончан.;лечения", {|| date_8(tmp->k_data) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Стоимость; лечения", {|| put_kopE(tmp->cena_1,10) })
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
  
  ***** 19.01.20
  Function f2create1reestr19(nKey,oBrow)
  Local buf, rec, k := -1, s, i, j, mas_pmt := {}, arr, r1, r2
  do case
    case nkey == K_INS
      replace tmp->plus with !tmp->plus
      j := tmp->pz + 1
      i := ascan(p_array_PZ, {|x| x[1] == tmp->PZ })
      if tmp->plus
        psumma += tmp->cena_1 ; pkol++
        if i > 0 .and. !empty(p_array_PZ[i,5])
          mpz[j] ++
        else
          mpz[j] += tmp->PZKOL
        endif
      else
        psumma -= tmp->cena_1 ; pkol--
        if i > 0 .and. !empty(p_array_PZ[i,5])
          mpz[j] --
        else
          mpz[j] -= tmp->PZKOL
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
      for j := 2 to len(oldpz)
        if !empty(oldpz[j]) .and. (i := ascan(p_array_PZ, {|x| x[1] == j-1 })) > 0
          aadd(mas_pmt, 'Отметить "'+p_array_PZ[i,3]+'"') ; aadd(arr,j-1)
        endif
      next
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
              psumma += tmp->cena_1
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
  
***** 25.07.21 создание XML-файлов реестра
Function create2reestr19(_recno,_nyear,_nmonth,reg_sort)
  Local mnn, mnschet := 1, fl, mkod_reestr, name_zip, arr_zip := {}, lst, lshifr1, code_reestr, mb, me, nsh
  //
  local iAKSLP, tKSLP, cKSLP // счетчик для цикла по КСЛП
  //
  close databases
  if empty(sadiag1)
    Private file_form, diag1 := {}, len_diag := 0
    if (file_form := search_file("DISP_NAB"+sfrm)) == NIL
      return func_error(4,"Не обнаружен файл DISP_NAB"+sfrm)
    endif
    f2_vvod_disp_nabl("A00")
    sadiag1 := diag1
  endif
  for i := 1 to 5
    sk := lstr(i)
    pole_diag := "mdiag"+sk
    pole_1dispans := "m1dispans"+sk
    pole_dn_dispans := "mdndispans"+sk
    Private &pole_diag := space(6)
    Private &pole_1dispans := 0
    Private &pole_dn_dispans := ctod("")
  next
  stat_msg("Составление реестра случаев")
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
  use_base("lusl")
  use_base("luslc")
  use_base("luslf")
  laluslf := "luslf"+iif(_nyear==2019,"19","")
  R_Use(dir_server+"mo_uch",,"UCH")
  R_Use(dir_server+"mo_otd",,"OTD")
  R_Use(dir_server+"mo_pers",,"P2")
  R_Use(dir_server+"mo_pers",dir_server+"mo_pers","P2TABN")
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
  R_Use(dir_server+"mo_onkco",dir_server+"mo_onkco","ONKCO")
  R_Use(dir_server+"mo_onksl",dir_server+"mo_onksl","ONKSL") // Сведения о случае лечения онкологического заболевания
  R_Use(dir_server+"mo_onkdi",dir_server+"mo_onkdi","ONKDI") // Диагностический блок
  R_Use(dir_server+"mo_onkpr",dir_server+"mo_onkpr","ONKPR") // Сведения об имеющихся противопоказаниях
  G_Use(dir_server+"mo_onkus",dir_server+"mo_onkus","ONKUS")
  G_Use(dir_server+"mo_onkle",dir_server+"mo_onkle","ONKLE")
  G_Use(dir_server+"human_3",{dir_server+"human_3",dir_server+"human_32"},"HUMAN_3")
  set order to 2 // индекс по 2-му случаю
  G_Use(dir_server+"human_2",,"HUMAN_2")
  G_Use(dir_server+"human_",,"HUMAN_")
  R_Use(dir_server+"human",,"HUMAN")
  set relation to recno() into HUMAN_, to recno() into HUMAN_2, to kod_k into KART
  R_Use(exe_dir+"_mo_t2_v1",,"T21")
  index on shifr to (cur_dir+"tmp_t21")
  use (cur_dir+"tmpb") new
  if reg_sort == 1
    index on upper(fio) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
  else
    index on str(pz,2)+str(10000000-cena_1,11,2) to (cur_dir+"tmpb") for kod_tmp==_recno .and. plus
  endif
  pkol := psumma := iusl := 0
  go top
  do while !eof()
    @ maxrow(),1 say lstr(pkol) color cColorSt2Msg
    select HUMAN
    goto (tmpb->kod_human)
    pkol++ ; psumma += human->cena_1
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
    if tmpb->ishod == 89  // 2-й случай
      select HUMAN_3
      find (str(tmpb->kod_human,7))
      if found()
        G_RLock(forever)
        if human_3->REES_NUM < 99
          human_3->REES_NUM := human_3->REES_NUM+1
        endif
        human_3->REESTR := mkod_reestr
        human_3->REES_ZAP := pkol
        //
        select HUMAN
        goto (human_3->kod)  // встать на 1-й случай
        human_->(G_RLock(forever))
        psumma += human->cena_1
        if human_->REES_NUM < 99
          human_->REES_NUM := human_->REES_NUM+1
        endif
        human_->REESTR := mkod_reestr
        human_->REES_ZAP := pkol
      endif
    endif
    if pkol % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    select TMPB
    skip
  enddo
  select REES
  G_RLock(forever)
  rees->KOL := pkol
  rees->SUMMA := psumma
  dbUnlockAll()
  dbCommitAll()
  //
  //
  Private arr_usl_otkaz, adiag_talon[16]
  //
  // создадим новый XML-документ
  oXmlDoc := HXMLDoc():New()

  // заполним корневой элемент XML-документа
  oXmlDoc:Add( HXMLNode():New( "ZL_LIST") )
  oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )

  // заполним заголовок XML-документа
  s := '3.11'
  mo_add_xml_stroke(oXmlNode,"VERSION" ,s)
  mo_add_xml_stroke(oXmlNode,"DATA"    ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME",mo_xml->FNAME)
  mo_add_xml_stroke(oXmlNode,"SD_Z"    ,lstr(pkol))

  // заполним реестр случаев для XML-документа
  oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "SCHET" ) )
  mo_add_xml_stroke(oXmlNode,"CODE"   ,lstr(code_reestr))
  mo_add_xml_stroke(oXmlNode,"CODE_MO",CODE_MO)
  mo_add_xml_stroke(oXmlNode,"YEAR"   ,lstr(_NYEAR))
  mo_add_xml_stroke(oXmlNode,"MONTH"  ,lstr(_NMONTH))
  mo_add_xml_stroke(oXmlNode,"NSCHET" ,lstr(rees->NSCHET))
  mo_add_xml_stroke(oXmlNode,"DSCHET" ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"SUMMAV" ,str(psumma,15,2))
  //mo_add_xml_stroke(oXmlNode,"COMENTS","")
  //
  //
  select RHUM
  index on str(REES_ZAP,6) to (cur_dir+"tmp_rhum") for REESTR==mkod_reestr
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    //
    fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
    lshifr_zak_sl := lvidpoms := cSMOname := ""
    a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
    atmpusl := {} ; akslp := {} ; akiro := {} ; mdiagnoz := {} ; mdiagnoz3 := {}
    is_KSG := is_mgi := .f.
    kol_kd := v_reabil_slux := m1veteran := m1mobilbr := 0  // мобильная бригада
    tarif_zak_sl := m1mesto_prov := m1p_otk := 0    // признак отказа
    m1dopo_na := m1napr_v_mo := 0 // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    arr_mo_spec := {}
    m1napr_stac := 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    m1profil_stac := m1napr_reab := m1profil_kojki := 0
    pr_amb_reab := fl_disp_nabl := is_disp_DVN := is_disp_DVN_COVID := .f.
    ldate_next := ctod("")
    ar_dn := {}
    is_oncology_smp := is_oncology := 0
    arr_onkna := {}
    arr_onkdi := {}
    arr_onkpr := {}
    arr_onk_usl := {}
    a_otkaz := {}
    arr_nazn := {}

    mtab_v_dopo_na := mtab_v_mo := mtab_v_stac := mtab_v_reab := mtab_v_sanat := 0

    //
    select HUMAN
    goto (rhum->kod_hum)  // встали на 2-ой лист учёта
    kol_sl := iif(human->ishod == 89, 2, 1)
    for isl := 1 to kol_sl
      if isl == 1 .and. kol_sl == 2
        select HUMAN_3
        find (str(rhum->kod_hum,7))
        select HUMAN
        goto (human_3->kod)  // встали на 1-й лист учёта
      endif
      if isl == 2
        select HUMAN
        goto (human_3->kod2)  // встали на 2-ой лист учёта
      endif
      f1_create2reestr19(_nyear,_nmonth)

      // заполним реестр записями для XML-документа
      if isl == 1
        oZAP := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZAP" ) )
        mo_add_xml_stroke(oZAP,"N_ZAP" ,lstr(rhum->REES_ZAP))
        mo_add_xml_stroke(oZAP,"PR_NOV",iif(human_->SCHET_NUM > 0, '1', '0')) // если попал в счёт 2-й раз и т.д.
        
        // заполним сведения о пациенте для XML-документа 
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
        //mo_add_xml_stroke(oPAC,"ST_OKATO" ,...) // Регион страхования
        if empty(cSMOname)
          mo_add_xml_stroke(oPAC,"SMO" ,human_->smo)
        endif
        mo_add_xml_stroke(oPAC,"SMO_OK",iif(empty(human_->OKATO),"18000",human_->OKATO))
        if !empty(cSMOname)
          mo_add_xml_stroke(oPAC,"SMO_NAM",cSMOname)
        endif
        if human_->NOVOR == 0
          mo_add_xml_stroke(oPAC,"NOVOR",'0')
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
          // заполним сведения об инвалидности пациента для XML-документа 
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
        // заполним сведения о законченном случае оказания медицинской помощи для XML-документа
        oSLUCH := oZAP:Add( HXMLNode():New( "Z_SL" ) )
        mo_add_xml_stroke(oSLUCH,"IDCASE"  ,lstr(rhum->REES_ZAP))
        mo_add_xml_stroke(oSLUCH,"ID_C"    ,human_->ID_C)
        if p_tip_reestr == 2  // для реестров по диспансеризации
          s := space(3) 
          ret_tip_lu(@s)
          if !empty(s)
            mo_add_xml_stroke(oSLUCH,"DISP",s) // Тип диспансеризации
          endif
        endif
        mo_add_xml_stroke(oSLUCH,"USL_OK"  ,lstr(human_->USL_OK))
        mo_add_xml_stroke(oSLUCH,"VIDPOM"  ,lstr(lvidpom))
        if p_tip_reestr == 1
          lal := iif(kol_sl == 2, "human_3", "human_")
          mo_add_xml_stroke(oSLUCH,"ISHOD"   ,lstr(&lal.->ISHOD_NEW))
          if kol_sl == 2
            mo_add_xml_stroke(oSLUCH,"VB_P"  ,'1') // Признак внутрибольничного перевода при оплате законченного случая как суммы стоимостей пребывания пациента в разных профильных отделениях, каждое из которых оплачивается по КСГ
          endif
          mo_add_xml_stroke(oSLUCH,"IDSP"    ,lstr(human_->IDSP))
          lal := iif(kol_sl == 2, "human_3", "human")
          mo_add_xml_stroke(oSLUCH,"SUMV"    ,lstr(&lal.->cena_1,10,2))
          do case
            case human_->USL_OK == 1 // стационар
              i := iif(left(human_->FORMA14,1)=='1', 1, 3)
            case human_->USL_OK == 2 // дневной стационар
              i := iif(left(human_->FORMA14,1)=='2', 2, 3)
            case human_->USL_OK == 4 // скорая помощь
              i := iif(left(human_->FORMA14,1)=='1', 1, 2)
            otherwise
              i := lfor_pom
          endcase
          mo_add_xml_stroke(oSLUCH,"FOR_POM",lstr(i)) // 1 - экстренная, 2 - неотложная, 3 - плановая
          if !empty(human_->NPR_MO) .and. !empty(mNPR_MO := ret_mo(human_->NPR_MO)[_MO_KOD_FFOMS])
            mo_add_xml_stroke(oSLUCH,"NPR_MO",mNPR_MO)
            s := iif(empty(human_2->NPR_DATE),human->N_DATA, human_2->NPR_DATE)
            mo_add_xml_stroke(oSLUCH,"NPR_DATE",date2xml(s))
          endif
          mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
        else  // для реестров по диспансеризации
          mo_add_xml_stroke(oSLUCH,"FOR_POM",'3') // 3 - плановая
          mo_add_xml_stroke(oSLUCH,"LPU",CODE_LPU)
          mo_add_xml_stroke(oSLUCH,"VBR",iif(m1mobilbr==0,'0','1'))
          if eq_any(human->ishod,301,302,203)
            s := "2.1" // Медицинский осмотр
          else
            s := "2.2" // Диспансеризация
          endif
          mo_add_xml_stroke(oSLUCH,"P_CEL",s)
          mo_add_xml_stroke(oSLUCH,"P_OTK",iif(m1p_otk==0,'0','1')) // Признак отказа
        endif
        lal := iif(kol_sl == 2, "human_3", "human")
        mo_add_xml_stroke(oSLUCH,"DATE_Z_1",date2xml(&lal.->N_DATA))
        mo_add_xml_stroke(oSLUCH,"DATE_Z_2",date2xml(&lal.->K_DATA))
        if p_tip_reestr == 1
          if kol_sl == 2
            mo_add_xml_stroke(oSLUCH,"KD_Z",lstr(human_3->k_data-human_3->n_data)) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
          elseif kol_kd > 0
            mo_add_xml_stroke(oSLUCH,"KD_Z",lstr(kol_kd)) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
          endif
        endif
        if human_->USL_OK == 1 // стационар
          // вес недоношенных детей для л/у матери
          lal := iif(kol_sl == 2, "human_3", "human_2")
          if &lal.->VNR1 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(&lal.->VNR1))
          endif
          if &lal.->VNR2 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(&lal.->VNR2))
          endif
          if &lal.->VNR3 > 0
            mo_add_xml_stroke(oSLUCH,"VNOV_M",lstr(&lal.->VNR3))
          endif
        endif
        lal := iif(kol_sl == 2, "human_3", "human_")
        mo_add_xml_stroke(oSLUCH,"RSLT",lstr(&lal.->RSLT_NEW))
        if p_tip_reestr == 1
          //mo_add_xml_stroke(oSLUCH,"MSE",'1')
        else    // для реестров по диспансеризации
          mo_add_xml_stroke(oSLUCH,"ISHOD",lstr(human_->ISHOD_NEW))
          mo_add_xml_stroke(oSLUCH,"IDSP" ,lstr(human_->IDSP))
          mo_add_xml_stroke(oSLUCH,"SUMV" ,lstr(human->cena_1,10,2))
        endif
      endif // окончание тегов ZAP + PACIENT + Z_SL

      // заполним сведения о случае оказания медицинской помощи для XML-документа
      oSL := oSLUCH:Add( HXMLNode():New( "SL" ) )
      mo_add_xml_stroke(oSL,"SL_ID",human_->ID_C)
      if (is_vmp := human_->USL_OK == 1 .and. human_2->VMP == 1 ;// ВМП
                            .and. !emptyany(human_2->VIDVMP,human_2->METVMP))
        mo_add_xml_stroke(oSL,"VID_HMP",human_2->VIDVMP)
        mo_add_xml_stroke(oSL,"METOD_HMP",lstr(human_2->METVMP))
      endif
      otd->(dbGoto(human->OTD))
      if human_->USL_OK == 1 .and. is_otd_dep
        f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
        if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
          i := 1
        endif
        mo_add_xml_stroke(oSL,"LPU_1",lstr(mm_otd_dep[i,3]))
        mo_add_xml_stroke(oSL,"PODR" ,lstr(glob_otd_dep))
      endif
      mo_add_xml_stroke(oSL,"PROFIL",lstr(human_->PROFIL))
      if p_tip_reestr == 1
        if human_->USL_OK < 3
          mo_add_xml_stroke(oSL,"PROFIL_K",lstr(human_2->PROFIL_K))
        endif
        mo_add_xml_stroke(oSL,"DET",iif(human->VZROS_REB==0,'0','1'))
        if human_->USL_OK == 3
          s := "2.6"
          if (i := ascan(glob_V025, {|x| x[2] == human_->povod})) > 0
            s := glob_V025[i,3]
          endif
          mo_add_xml_stroke(oSL,"P_CEL",s)
        endif
      endif
      if is_vmp
        mo_add_xml_stroke(oSL,"TAL_D" ,date2xml(human_2->TAL_D)) // Дата выдачи талона на ВМП
        mo_add_xml_stroke(oSL,"TAL_P" ,date2xml(human_2->TAL_P)) // Дата планируемой госпитализации в соответствии с талоном на ВМП
        mo_add_xml_stroke(oSL,"TAL_NUM",human_2->TAL_NUM) // номер талона на ВМП
      endif
      mo_add_xml_stroke(oSL,"NHISTORY",iif(empty(human->UCH_DOC),lstr(human->kod),human->UCH_DOC))
      
      if !is_vmp .and. eq_any(human_->USL_OK,1,2)
        mo_add_xml_stroke(oSL,"P_PER",lstr(human_2->P_PER)) // Признак поступления/перевода
      endif
      mo_add_xml_stroke(oSL,"DATE_1",date2xml(human->N_DATA))
      mo_add_xml_stroke(oSL,"DATE_2",date2xml(human->K_DATA))
      if p_tip_reestr == 1
        if kol_kd > 0
          mo_add_xml_stroke(oSL,"KD",lstr(kol_kd)) // Указывается количество койко-дней для стационара, количество пациенто-дней для дневного стационара
        endif
        if !empty(human_->kod_diag0)
          mo_add_xml_stroke(oSL,"DS0",human_->kod_diag0)
        endif
      endif
      mo_add_xml_stroke(oSL,"DS1",rtrim(mdiagnoz[1]))
      if p_tip_reestr == 2  // для реестров по диспансеризации
        s := 3 // не подлежит диспансерному наблюдению
        if adiag_talon[1] == 1 // впервые
          mo_add_xml_stroke(oSL,"DS1_PR",'1') // Признак первичного установления  диагноза
          if adiag_talon[2] == 2
            s := 2 // взят на диспансерное наблюдение
          endif
        elseif adiag_talon[1] == 2 // ранее
          if adiag_talon[2] == 1
            s := 1 // состоит на диспансерном наблюдении
          elseif adiag_talon[2] == 2
            s := 2 // взят на диспансерное наблюдение
          endif
        endif
        mo_add_xml_stroke(oSL,"PR_D_N",lstr(s))
        if (is_disp_DVN .or. is_disp_DVN_COVID) .and. s == 2 // взят на диспансерное наблюдение
          aadd(ar_dn, {'2',rtrim(mdiagnoz[1]),"",""})
        endif
      endif
      if p_tip_reestr == 1
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
            mo_add_xml_stroke(oSL,"DS2" ,rtrim(mdiagnoz[i]))
          endif
        next
        for i := 1 to len(mdiagnoz3) // ЕЩЁ ДИАГНОЗы ОСЛОЖНЕНИЯ ЗАБОЛЕВАНИЯ
          if !empty(mdiagnoz3[i])
            mo_add_xml_stroke(oSL,"DS3",rtrim(mdiagnoz3[i]))
          endif
        next
        if need_reestr_c_zab(human_->USL_OK,mdiagnoz[1]) .or. is_oncology_smp > 0
          if human_->USL_OK == 3 .and. human_->povod == 4 // если P_CEL=1.3
            mo_add_xml_stroke(oSL,"C_ZAB",'2') // При диспансерном наблюдении характер заболевания не может быть <Острое>
          else
            mo_add_xml_stroke(oSL,"C_ZAB",'1') // Характер основного заболевания
          endif
        endif
        if human_->USL_OK < 4
          i := 0
          if human->OBRASHEN == '1' .and. is_oncology < 2
            i := 1
          endif
          mo_add_xml_stroke(oSL,"DS_ONK",lstr(i))
        else
          mo_add_xml_stroke(oSL,"DS_ONK",'0')
        endif
        if human_->USL_OK == 3 .and. human_->povod == 4 // Обязательно, если P_CEL=1.3
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
          mo_add_xml_stroke(oSL,"DN",lstr(s))
        endif
      else   // для реестров по диспансеризации
        for i := 2 to len(mdiagnoz)
          if !empty(mdiagnoz[i])
            oDiag := oSL:Add( HXMLNode():New( "DS2_N" ) )
            mo_add_xml_stroke(oDiag,"DS2",rtrim(mdiagnoz[i]))
            s := 3 // не подлежит диспансерному наблюдению
            if adiag_talon[i*2-1] == 1 // впервые
              mo_add_xml_stroke(oDiag,"DS2_PR",'1')
              if adiag_talon[i*2] == 2
                s := 2 // взят на диспансерное наблюдение
              endif
            elseif adiag_talon[i*2-1] == 2 // ранее
              if adiag_talon[i*2] == 1
                s := 1 // состоит на диспансерном наблюдении
              elseif adiag_talon[i*2] == 2
                s := 2 // взят на диспансерное наблюдение
              endif
            endif
            mo_add_xml_stroke(oDiag,"PR_D",lstr(s))
            if (is_disp_DVN .or. is_disp_DVN_COVID) .and. s == 2 // взят на диспансерное наблюдение
              aadd(ar_dn, {'2',rtrim(mdiagnoz[i]),"",""})
            endif
          endif
        next
        i := iif(human->OBRASHEN == '1', 1, 0)
        mo_add_xml_stroke(oSL,"DS_ONK",lstr(i))
        if len(arr_nazn) > 0 .or. (human->OBRASHEN == '1' .and. len(arr_onkna) > 0)
          // заполним сведения о назначениях по результатам диспансеризации для XML-документа
          oPRESCRIPTION := oSL:Add( HXMLNode():New( "PRESCRIPTION" ) )
          for j := 1 to len(arr_nazn)
            oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j))
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(arr_nazn[j,1]))

            // if !empty(arr_nazn[j,3])   // по новому ПУМП с 01.08.2021
            //   mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_IDDOKT", arr_nazn[j,3])
            // endif

            // if !empty(arr_nazn[j,4])   // по новому ПУМП с 01.08.2021
            //   mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SPDOCT", arr_nazn[j,4])
            // endif
            
            if eq_any(arr_nazn[j,1],1,2) // {"в нашу МО",1},{"в иную МО",2}}
              // к какому специалисту направлен
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",arr_nazn[j,2]) // результат ф-ии put_prvs_to_reestr(human_->PRVS,_NYEAR)
            elseif arr_nazn[j,1] == 3
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_nazn[j,2]))
              //if human->OBRASHEN == '1'
                //mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_USL",arr_nazn[j,3]) // Мед.услуга (код), указанная в направлении
              //endif
            elseif eq_any(arr_nazn[j,1],4,5)
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PMP",lstr(arr_nazn[j,2]))
            elseif arr_nazn[j,1] == 6
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_PK",lstr(arr_nazn[j,2]))
            endif
          next j
          if human->OBRASHEN == '1' // подозрение на ЗНО
            for j := 1 to len(arr_onkna)
            // заполним сведения о назначениях по результатам диспансеризации для XML-документа
            oPRESCRIPTIONS := oPRESCRIPTION:Add( HXMLNode():New( "PRESCRIPTIONS" ) )
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_N",lstr(j+len(arr_nazn)))
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_R",lstr(iif(arr_onkna[j,2]==1, 2, arr_onkna[j,2])))
            if arr_onkna[j,2] == 1 // направление к онкологу
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_SP",iif(human->VZROS_REB==0,'41','19')) // спец-ть онкология или детская онкология
            else // == 3 на дообследование
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_V",lstr(arr_onkna[j,3]))
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAZ_USL",arr_onkna[j,4])
            endif
            mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_DATE",date2xml(arr_onkna[j,1]))
            if !empty(arr_onkna[j,5]) .and. !empty(mNPR_MO := ret_mo(arr_onkna[j,5])[_MO_KOD_FFOMS])
              mo_add_xml_stroke(oPRESCRIPTIONS,"NAPR_MO",mNPR_MO)
            endif
            next j
          endif
        endif
      endif
      if is_KSG
        // заполним сведения о КСГ для XML-документа
        oKSG := oSL:Add( HXMLNode():New( "KSG_KPG" ) )
        mo_add_xml_stroke(oKSG,"N_KSG",lshifr_zak_sl)
        if !empty(human_2->pc3) .and. !left(human_2->pc3,1) == '6' // кроме "старости"
          mo_add_xml_stroke(oKSG,"CRIT",human_2->pc3)
        elseif is_oncology  == 2
          if !empty(onksl->crit) .and. !(alltrim(onksl->crit) == "нет")
            mo_add_xml_stroke(oKSG,"CRIT",onksl->crit)
          endif
          if !empty(onksl->crit2)
            mo_add_xml_stroke(oKSG,"CRIT",onksl->crit2)  // второй критерий
          endif
        endif
        mo_add_xml_stroke(oKSG,"SL_K",iif(empty(akslp),'0','1'))
        if !empty(akslp)
          // заполним сведения о КСГ для XML-документа
          if year(human->K_DATA) == 2021     // 02.02.2021 Байкин 
            tKSLP := getKSLPtable(human->K_DATA)
            mo_add_xml_stroke(oKSG,"IT_SL",lstr(ret_koef_kslp_21_XML(akslp,tKSLP),7,5))
            for iAKSLP := 1 to len(akslp)
              if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
                oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
                mo_add_xml_stroke( oSLk, "ID_SL", lstr(akslp[ iAKSLP ] ) )
                mo_add_xml_stroke( oSLk, "VAL_C", lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
              endif
            next
          else
            mo_add_xml_stroke(oKSG,"IT_SL",lstr(ret_koef_kslp(akslp),7,5))
            oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
            mo_add_xml_stroke(oSLk,"ID_SL",lstr(akslp[1]))
            mo_add_xml_stroke(oSLk,"VAL_C",lstr(akslp[2],7,5))
            if len(akslp) >= 4
              oSLk := oKSG:Add( HXMLNode():New( "SL_KOEF" ) )
              mo_add_xml_stroke(oSLk,"ID_SL",lstr(akslp[3]))
              mo_add_xml_stroke(oSLk,"VAL_C",lstr(akslp[4],7,5))
            endif
          endif
        endif
        if !empty(akiro)
          // заполним сведения о КИРО для XML-документа
          oSLk := oKSG:Add( HXMLNode():New( "S_KIRO" ) )
          mo_add_xml_stroke(oSLk,"CODE_KIRO",lstr(akiro[1]))
          mo_add_xml_stroke(oSLk,"VAL_K",lstr(akiro[2],4,2))
        endif
      elseif is_zak_sl .or. is_zak_sl_vr
        mo_add_xml_stroke(oSL,"CODE_MES1",lshifr_zak_sl)
      endif
      if human_->USL_OK < 4 .and. is_oncology > 0
        for j := 1 to len(arr_onkna)
          // заполним сведения о направлениях для XML-документа
          oNAPR := oSL:Add( HXMLNode():New( "NAPR" ) )
          mo_add_xml_stroke(oNAPR,"NAPR_DATE",date2xml(arr_onkna[j,1]))
          if !empty(arr_onkna[j,5]) .and. !empty(mNPR_MO := ret_mo(arr_onkna[j,5])[_MO_KOD_FFOMS])
            mo_add_xml_stroke(oNAPR,"NAPR_MO",mNPR_MO)
          endif
          mo_add_xml_stroke(oNAPR,"NAPR_V",lstr(arr_onkna[j,2]))
          if arr_onkna[j,2] == 3
            mo_add_xml_stroke(oNAPR,"MET_ISSL",lstr(arr_onkna[j,3]))
            mo_add_xml_stroke(oNAPR,"NAPR_USL",arr_onkna[j,4])
          endif
        next j
      endif
      if is_oncology > 0 .or. is_oncology_smp > 0
        // заполним сведения о консилиумах для XML-документа
        oCONS := oSL:Add( HXMLNode():New( "CONS" ) ) // консилиумов м.б.несколько (но у нас один)
        mo_add_xml_stroke(oCONS,"PR_CONS",lstr(onkco->PR_CONS)) // N019
        if !empty(onkco->DT_CONS)
          mo_add_xml_stroke(oCONS,"DT_CONS",date2xml(onkco->DT_CONS))
        endif
      endif
      if human_->USL_OK < 4 .and. is_oncology == 2
        // заполним сведения об онкологии для XML-документа
        oONK_SL := oSL:Add( HXMLNode():New( "ONK_SL" ) )
        mo_add_xml_stroke(oONK_SL,"DS1_T",lstr(onksl->DS1_T))
        if between(onksl->DS1_T,0,4)
          mo_add_xml_stroke(oONK_SL,"STAD",lstr(onksl->STAD))
          if onksl->DS1_T == 0 .and. human->vzros_reb == 0
            mo_add_xml_stroke(oONK_SL,"ONK_T",lstr(onksl->ONK_T))
            mo_add_xml_stroke(oONK_SL,"ONK_N",lstr(onksl->ONK_N))
            mo_add_xml_stroke(oONK_SL,"ONK_M",lstr(onksl->ONK_M))
          endif
          if between(onksl->DS1_T,1,2) .and. onksl->MTSTZ == 1
            mo_add_xml_stroke(oONK_SL,"MTSTZ",lstr(onksl->MTSTZ))
          endif
        endif
        if eq_ascan(arr_onk_usl,3,4)
          mo_add_xml_stroke(oONK_SL,"SOD",lstr(onksl->sod,6,2))
          mo_add_xml_stroke(oONK_SL,"K_FR",lstr(onksl->k_fr))
        endif
        if eq_ascan(arr_onk_usl,2,4)
          mo_add_xml_stroke(oONK_SL,"WEI",lstr(onksl->WEI,5,1))
          mo_add_xml_stroke(oONK_SL,"HEI",lstr(onksl->HEI))
          mo_add_xml_stroke(oONK_SL,"BSA",lstr(onksl->BSA,5,2))
        endif
        for j := 1 to len(arr_onkdi)
          // заполним сведения о диагностических услугах для XML-документа
          oDIAG := oONK_SL:Add( HXMLNode():New( "B_DIAG" ) )
          mo_add_xml_stroke(oDIAG,"DIAG_DATE",date2xml(arr_onkdi[j,1]))
          mo_add_xml_stroke(oDIAG,"DIAG_TIP", lstr(arr_onkdi[j,2]))
          mo_add_xml_stroke(oDIAG,"DIAG_CODE",lstr(arr_onkdi[j,3]))
          if arr_onkdi[j,4] > 0
            mo_add_xml_stroke(oDIAG,"DIAG_RSLT",lstr(arr_onkdi[j,4]))
            mo_add_xml_stroke(oDIAG,"REC_RSLT",'1')
          endif
        next j
        for j := 1 to len(arr_onkpr)
          // заполним сведения о противоказаниях и отказах для XML-документа
          oPROT := oONK_SL:Add( HXMLNode():New( "B_PROT" ) )
          mo_add_xml_stroke(oPROT,"PROT",lstr(arr_onkpr[j,1]))
          mo_add_xml_stroke(oPROT,"D_PROT",date2xml(arr_onkpr[j,2]))
        next j
        if human_->USL_OK < 3 .and. iif(human_2->VMP == 1, .t., between(onksl->DS1_T,0,2)) .and. len(arr_onk_usl) > 0
          select ONKUS
          find (str(human->kod,7))
          do while onkus->kod == human->kod .and. !eof()
            if between(onkus->USL_TIP,1,5)
              // заполним сведения об услуге прилечении онкологического больного для XML-документа
              oONK := oONK_SL:Add( HXMLNode():New( "ONK_USL" ) )
              mo_add_xml_stroke(oONK,"USL_TIP",lstr(onkus->USL_TIP))
              if onkus->USL_TIP == 1
                mo_add_xml_stroke(oONK,"HIR_TIP",lstr(onkus->HIR_TIP))
              endif
              if onkus->USL_TIP == 2
                mo_add_xml_stroke(oONK,"LEK_TIP_L",lstr(onkus->LEK_TIP_L))
                mo_add_xml_stroke(oONK,"LEK_TIP_V",lstr(onkus->LEK_TIP_V))
              endif
              if eq_any(onkus->USL_TIP,3,4)
                mo_add_xml_stroke(oONK,"LUCH_TIP",lstr(onkus->LUCH_TIP))
              endif
              if eq_any(onkus->USL_TIP,2,4)
                old_lek := space(6) ; old_sh := space(10)
                select ONKLE  //  цикл по БД лекарств
                find (str(human->kod,7))
                do while onkle->kod == human->kod .and. !eof()
                  if !(old_lek == onkle->REGNUM .and. old_sh == onkle->CODE_SH)
                    // заполним сведения о примененных лекарственных препаратах при лечении онкологического больного для XML-документа
                    oLEK := oONK:Add( HXMLNode():New( "LEK_PR" ) )
                    mo_add_xml_stroke(oLEK,"REGNUM",onkle->REGNUM)
                    mo_add_xml_stroke(oLEK,"CODE_SH",onkle->CODE_SH)
                  endif
                  // цикл по датам приёма данного лекарства
                  mo_add_xml_stroke(oLEK,"DATE_INJ",date2xml(onkle->DATE_INJ))
                  old_lek := onkle->REGNUM ; old_sh := onkle->CODE_SH
                  select ONKLE
                  skip
                enddo
                if onkus->PPTR > 0
                  mo_add_xml_stroke(oONK,"PPTR",'1')
                endif
              endif
            endif
            select ONKUS
            skip
          enddo
        endif
      endif
      sCOMENTSL := ""
      if p_tip_reestr == 1
        mo_add_xml_stroke(oSL,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
        if (!is_mgi .and. ascan(kod_LIS,glob_mo[_MO_KOD_TFOMS]) > 0 .and. eq_any(human_->profil,6,34)) .or. human_->profil == 15 //гистология
          mo_add_xml_stroke(oSL,"IDDOKT","0")
        else
          p2->(dbGoto(human_->vrach))
          mo_add_xml_stroke(oSL,"IDDOKT",p2->snils)
        endif
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSL,"ED_COL",'1')
          mo_add_xml_stroke(oSL,"TARIF" ,lstr(tarif_zak_sl,10,2))
        endif
        mo_add_xml_stroke(oSL,"SUM_M",lstr(human->cena_1,10,2))
        if !empty(ldate_next)
          mo_add_xml_stroke(oSL,"NEXT_VISIT",date2xml(bom(ldate_next)))
        endif
        //
        j := 0
        if (ibrm := f_oms_beremenn(mdiagnoz[1])) == 1 .and. eq_any(human_->profil,136,137) // акушерству и гинекологии
          j := iif(human_2->pn2 == 1, 4, 3)
        elseif ibrm == 2 .and. human_->USL_OK == 3 // поликлиника
          j := iif(human_2->pn2 == 1, 5, 6)
          if j == 5 .and. !eq_any(human_->profil,136,137)
            j := 6  // т.е. только акушер-гинеколог может поставить на учёт по беременности
          endif
        endif
        if j > 0
          sCOMENTSL += lstr(j)
        endif
        if human_->USL_OK == 3 .and. eq_any(lvidpom,1,11,12,13)
          sCOMENTSL += ":;" // пока так (потом добавим дисп.наблюдение)
        endif
      else   // для реестров по диспансеризации
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSL,"ED_COL",'1')
        endif
        mo_add_xml_stroke(oSL,"PRVS",put_prvs_to_reestr(human_->PRVS,_NYEAR))
        if is_zak_sl .or. is_zak_sl_vr
          mo_add_xml_stroke(oSL,"TARIF" ,lstr(tarif_zak_sl,10,2))
        endif
        mo_add_xml_stroke(oSL,"SUM_M",lstr(human->cena_1,10,2))
        //
        if between(human->ishod,201,205) // ДВН
          j := iif(human->RAB_NERAB==0,20,iif(human->RAB_NERAB==1,10,14))
          if human->ishod != 203 .and. m1veteran == 1
            j := iif(human->RAB_NERAB==0, 21, 11)
          endif
          sCOMENTSL := lstr(j)
        elseif between(human->ishod,301,302)
          j := iif(between(m1mesto_prov,0,1), m1mesto_prov, 0)
          sCOMENTSL := lstr(j)
        endif
      endif
      if p_tip_reestr == 1 .and. !empty(sCOMENTSL)
        mo_add_xml_stroke(oSL,"COMENTSL",sCOMENTSL)
      endif
      if !is_zak_sl
        for j := 1 to len(a_usl)
          select HU
          goto (a_usl[j])
          hu_->(G_RLock(forever))
          hu_->REES_ZAP := ++iusl
          lshifr1 := opr_shifr_TFOMS(usl->shifr1,usl->kod,human->k_data)
          lshifr := alltrim(iif(empty(lshifr1), usl->shifr, lshifr1))
          // заполним сведения об услугах для XML-документа
          oUSL := oSL:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV",lstr(hu_->REES_ZAP))
          mo_add_xml_stroke(oUSL,"ID_U",hu_->ID_U)
          fl := .f.
          if eq_any(hu->is_edit,1,2) // гематологические исследования
            mo_add_xml_stroke(oUSL,"LPU",kod_LIS[hu->is_edit]) // иссл-ие проводится в КДП2 или РДЛ
          elseif lshifr == "4.20.2" .or. hu->is_edit == 3 // жидкостная цитология или приём в ВОКОД
            mo_add_xml_stroke(oUSL,"LPU",'103001') // т.е. иссл-ие проводится в онкологии
          elseif hu->is_edit == 4
            mo_add_xml_stroke(oUSL,"LPU",'000000') // т.е. иссл-ие проводится в нашем пат.анат.бюро
          elseif hu->is_edit == 5
            mo_add_xml_stroke(oUSL,"LPU",'999999') // т.е. иссл-ие проводится в пат.анат.бюро в другой области
          else
            if pr_amb_reab .and. left(lshifr,2)=='4.' .and. left(hu_->zf,6) == '999999'
              fl := .t.
              mo_add_xml_stroke(oUSL,"LPU",'999999')
            elseif pr_amb_reab .and. left(lshifr,2)=='4.' .and. !empty(left(hu_->zf,6)) .and. left(hu_->zf,6)!=glob_mo[_MO_KOD_TFOMS]
              fl := .t.
              mo_add_xml_stroke(oUSL,"LPU",left(hu_->zf,6))
            else
              mo_add_xml_stroke(oUSL,"LPU",CODE_LPU)
            endif
          endif
          if p_tip_reestr == 1
            if human_->USL_OK == 1 .and. is_otd_dep
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
          select T21
          find (padr(lshifr,10))
          if found()
            mo_add_xml_stroke(oUSL,"VID_VME",alltrim(t21->shifr_mz))
          endif
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

          // if human->k_data >= 0d20210801 .and. p_tip_reestr == 2  // новые правила заполнения с 01.08.2021 письмо № 04-18-13 от 20.07.2021
          //   oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
          //   mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))   // уточнить
          //   mo_add_xml_stroke(oMR_USL_N,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
          //   if c4tod(hu->DATE_U) < human->n_data ; // если сделано ранее
          //       .or. eq_any(hu->is_edit,-1,1,2,3) .or. lshifr == "4.20.2" .or. left(lshifr,5) == "60.8." .or. fl
          //     mo_add_xml_stroke(oMR_USL_N,"CODE_MD",'0') // не заполняется код врача
          //   else
          //     p2->(dbGoto(hu->kod_vr))
          //     mo_add_xml_stroke(oMR_USL_N,"CODE_MD",p2->snils)
          //   endif
          // elseif human->k_data < 0d20210801 .and. p_tip_reestr == 2
            mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
            if c4tod(hu->DATE_U) < human->n_data ; // если сделано ранее
                .or. eq_any(hu->is_edit,-1,1,2,3) .or. lshifr == "4.20.2" .or. left(lshifr,5) == "60.8." .or. fl
              mo_add_xml_stroke(oUSL,"CODE_MD",'0') // не заполняется код врача
            else
              p2->(dbGoto(hu->kod_vr))
              mo_add_xml_stroke(oUSL,"CODE_MD",p2->snils)
            endif
          // endif

        next
      endif
      if p_tip_reestr == 2 .and. len(a_otkaz) > 0 // отказы (диспансеризация или профосмоты несовешеннолетних)
        // заполним сведения об услугах для XML-документа
        for j := 1 to len(a_otkaz)
          oUSL := oSL:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(++iusl))
          mo_add_xml_stroke(oUSL,"ID_U"    ,mo_guid(3,iusl))
          mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(a_otkaz[j,4]))
          select T21
          find (padr(a_otkaz[j,1],10))
          if found()
            mo_add_xml_stroke(oUSL,"VID_VME",alltrim(t21->shifr_mz))
          endif
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
      // if p_tip_reestr == 1 .and. len(a_fusl) > 0 // добавляем операции
      if len(a_fusl) > 0 // добавляем операции // исправил чтобы брала углубленную диспансеризацию COVID
        for j := 1 to len(a_fusl)
          select MOHU
          goto (a_fusl[j])
          mohu->(G_RLock(forever))
          mohu->REES_ZAP := ++iusl
          lshifr := alltrim(mosu->shifr1)
          // заполним сведения об услугах для XML-документа
          oUSL := oSL:Add( HXMLNode():New( "USL" ) )
          mo_add_xml_stroke(oUSL,"IDSERV"  ,lstr(mohu->REES_ZAP))
          mo_add_xml_stroke(oUSL,"ID_U"    ,mohu->ID_U)
          mo_add_xml_stroke(oUSL,"LPU"     ,CODE_LPU)
          if human_->USL_OK == 1 .and. is_otd_dep
            otd->(dbGoto(mohu->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            if (i := ascan(mm_otd_dep, {|x| x[2] == glob_otd_dep})) == 0
              i := 1
            endif
            mo_add_xml_stroke(oUSL,"LPU_1",lstr(mm_otd_dep[i,3]))
            mo_add_xml_stroke(oUSL,"PODR" ,lstr(glob_otd_dep))
          endif
          mo_add_xml_stroke(oUSL,"PROFIL"  ,lstr(mohu->PROFIL))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"VID_VME",lshifr)
            mo_add_xml_stroke(oUSL,"DET"     ,iif(human->VZROS_REB==0,'0','1'))
          endif
          mo_add_xml_stroke(oUSL,"DATE_IN" ,date2xml(c4tod(mohu->DATE_U)))
          mo_add_xml_stroke(oUSL,"DATE_OUT",date2xml(c4tod(mohu->DATE_U2)))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"DS"      ,mohu->kod_diag)
          endif
          if p_tip_reestr == 2
// разобраться с отказами услугами ФФОМС
            mo_add_xml_stroke(oUSL,"P_OTK" ,'0')
          endif
          mo_add_xml_stroke(oUSL,"CODE_USL",lshifr)
          mo_add_xml_stroke(oUSL,"KOL_USL" ,lstr(mohu->KOL_1,6,2))
          if p_tip_reestr == 1
            mo_add_xml_stroke(oUSL,"TARIF"   ,lstr(mohu->U_CENA,10,2))//lstr(mohu->U_CENA,10,2))
            mo_add_xml_stroke(oUSL,"SUMV_USL",lstr(mohu->STOIM_1,10,2))//lstr(mohu->STOIM_1,10,2))
          elseif p_tip_reestr == 2
            mo_add_xml_stroke(oUSL,"TARIF"   ,'0')//lstr(mohu->U_CENA,10,2))
            mo_add_xml_stroke(oUSL,"SUMV_USL",'0')//lstr(mohu->STOIM_1,10,2))
          endif
          // mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))  // закоментировал 04.08.21
          fl := .f.
          if is_telemedicina(lshifr,@fl) // не заполняется код врача
            mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))  // добавил 04.08.21
            mo_add_xml_stroke(oUSL,"CODE_MD",'0')
          else
            if human->k_data >= 0d20210801 .and. p_tip_reestr == 2  // новые правила заполнения с 01.08.2021 письмо № 04-18-13 от 20.07.2021
              oMR_USL_N := oUSL:Add( HXMLNode():New( "MR_USL_N" ) )
              mo_add_xml_stroke(oMR_USL_N,"MR_N",lstr(1))   // уточнить
              mo_add_xml_stroke(oMR_USL_N,"PRVS",put_prvs_to_reestr(hu_->PRVS,_NYEAR))
              p2->(dbGoto(mohu->kod_vr))
              mo_add_xml_stroke(oMR_USL_N,"CODE_MD",p2->snils)
            elseif human->k_data < 0d20210801 .and. p_tip_reestr == 2
              p2->(dbGoto(mohu->kod_vr))
              mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)
            elseif p_tip_reestr == 1
              mo_add_xml_stroke(oUSL,"PRVS",put_prvs_to_reestr(mohu->PRVS,_NYEAR))  // добавил 04.08.21
              p2->(dbGoto(mohu->kod_vr))                                            // добавил 04.08.21
              mo_add_xml_stroke(oUSL,"CODE_MD" ,p2->snils)                          // добавил 04.08.21
            endif
          endif
          if !empty(mohu->zf)
            dbSelectArea(laluslf)
            find (padr(lshifr,20))
            if found()
              if fl // телемедицина + НМИЦ
                mo_add_xml_stroke(oUSL,"COMENTU",mohu->zf) // код НМИЦ:факт получения результата
              elseif STisZF(human_->USL_OK,human_->PROFIL) .and. &laluslf.->zf == 1  // обязателен ввод зубной формулы
                mo_add_xml_stroke(oUSL,"COMENTU",arr2list(STretArrZF(mohu->zf))) // формула зуба
              elseif !empty(&laluslf.->par_org) // проверим на парные операции
                mo_add_xml_stroke(oUSL,"COMENTU",mohu->zf) // парные органы
              endif
            endif
          endif
        next j
      endif
      if p_tip_reestr == 2 .and. !empty(sCOMENTSL)   // для реестров по диспансеризации
        if (is_disp_DVN .or. is_disp_DVN_COVID)
          sCOMENTSL += ":"
          if !empty(ar_dn) // взят на диспансерное наблюдение
            for i := 1 to 5
              sk := lstr(i)
              pole_diag := "mdiag"+sk
              pole_1dispans := "m1dispans"+sk
              pole_dn_dispans := "mdndispans"+sk
              if !empty(&pole_diag) .and. &pole_1dispans == 1 .and. ascan(sadiag1,alltrim(&pole_diag)) > 0 ;
                              .and. !empty(&pole_dn_dispans) ;
                              .and. (j := ascan(ar_dn,{|x| alltrim(x[2]) == alltrim(&pole_diag) })) > 0
                ar_dn[j,4] := date2xml(bom(&pole_dn_dispans))
              endif
            next
            for j := 1 to len(ar_dn)
              if !empty(ar_dn[j,4])
                sCOMENTSL += "2,"+alltrim(ar_dn[j,2])+",,"+ar_dn[j,4]+"/"
              endif
            next
            if right(sCOMENTSL,1) == "/"
              sCOMENTSL := left(sCOMENTSL,len(sCOMENTSL)-1)
            endif
          endif
          sCOMENTSL += ";"
        endif
        mo_add_xml_stroke(oSL,"COMENTSL",sCOMENTSL)
      endif
    next isl
    select RHUM
    if rhum->REES_ZAP % 2000 == 0
      dbUnlockAll()
      dbCommitAll()
    endif
    skip
  enddo
  dbUnlockAll()
  dbCommitAll()

  stat_msg("Запись XML-документа в файл реестра случаев")

  oXmlDoc:Save(alltrim(mo_xml->FNAME)+sxml)
  name_zip := alltrim(mo_xml->FNAME)+szip
  aadd(arr_zip, alltrim(mo_xml->FNAME)+sxml)
  //
  //
  fl_ver := 311
  stat_msg("Составление реестра пациентов")
  oXmlDoc := HXMLDoc():New()
  // заполним корневой элемент реестра пациентов для XML-документа
  oXmlDoc:Add( HXMLNode():New( "PERS_LIST") )
  // заполним заголовок файла реестра пациентов для XML-документа
  oXmlNode := oXmlDoc:aItems[1]:Add( HXMLNode():New( "ZGLV" ) )
  s := '3.11'
  if strzero(_nyear,4)+strzero(_nmonth,2) > "201910" // с ноября 2019 года
    fl_ver := 32
    s := '3.2'
  endif
  mo_add_xml_stroke(oXmlNode,"VERSION"  ,s)
  mo_add_xml_stroke(oXmlNode,"DATA"     ,date2xml(rees->DSCHET))
  mo_add_xml_stroke(oXmlNode,"FILENAME" ,mo_xml->FNAME2)
  mo_add_xml_stroke(oXmlNode,"FILENAME1",mo_xml->FNAME)
  select RHUM
  go top
  do while !eof()
    @ maxrow(),0 say str(rhum->REES_ZAP/pkol*100,6,2)+"%" color cColorSt2Msg
    select HUMAN
    goto (rhum->kod_hum)  // встали на 1-ый лист учёта
    if human->ishod == 89  // а это не 1-ый, а 2-ой л/у
      select HUMAN_3
      set order to 2
      find (str(rhum->kod_hum,7))
      select HUMAN
      goto (human_3->kod)  // встали на 1-й лист учёта
    endif
    arr_fio := retFamImOt(2,.f.)
    // заполним сведения о пациенте для XML-документа
    oPAC := oXmlDoc:aItems[1]:Add( HXMLNode():New( "PERS" ) )
    mo_add_xml_stroke(oPAC,"ID_PAC" ,human_->ID_PAC)
    if human_->NOVOR == 0
      mo_add_xml_stroke(oPAC,"FAM"  ,arr_fio[1])
      if !empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"IM"   ,arr_fio[2])
      endif
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"OT" ,arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,"W"    ,iif(human->pol=="М",'1','2'))
      mo_add_xml_stroke(oPAC,"DR"   ,date2xml(human->date_r))
      if empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"DOST",'1') // отсутствует отчество
      endif
      if empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"DOST",'3') // отсутствует имя
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
      if !empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"IM_P" ,arr_fio[2])
      endif
      if !empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"OT_P",arr_fio[3])
      endif
      mo_add_xml_stroke(oPAC,"W_P"  ,iif(human->pol=="М",'1','2'))
      mo_add_xml_stroke(oPAC,"DR_P" ,date2xml(human->date_r))
      if empty(arr_fio[3])
        mo_add_xml_stroke(oPAC,"DOST_P",'1') // отсутствует отчество
      endif
      if empty(arr_fio[2])
        mo_add_xml_stroke(oPAC,"DOST_P",'3') // отсутствует имя
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
    if fl_ver == 32 .and. human_->vpolis < 3 .and. !eq_any(left(human_->OKATO,2),"  ","18") // иногородние
      if !empty(kart_->kogdavyd)
        mo_add_xml_stroke(oPAC,"DOCDATE",date2xml(kart_->kogdavyd))
      endif
      if !empty(kart_->kemvyd) .and. ;
         !empty(smr := del_spec_symbol(inieditspr(A__POPUPMENU, dir_server+"s_kemvyd", kart_->kemvyd)))
        mo_add_xml_stroke(oPAC,"DOCORG",smr)
      endif
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
  stat_msg("Запись XML-документа в файл реестр пациентов")
  oXmlDoc:Save(alltrim(mo_xml->FNAME2)+sxml)
  aadd(arr_zip, alltrim(mo_xml->FNAME2)+sxml)
  //
  close databases
  if chip_create_zipXML(name_zip,arr_zip,.t.)
    keyboard chr(K_TAB)+chr(K_ENTER)
  endif
  return NIL
  
  ***** 05.11.19 создать счета по результатам прочитанного реестра СП
  Function create_schet19_from_XML(arr_XML_info,aerr,fl_msg,arr_s,name_sp_tk)
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
          lal := "t11"
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
            mo_add_xml_stroke(oUSL,"PRVS"    ,t2->PRVS)
            mo_add_xml_stroke(oUSL,"CODE_MD",t2->CODE_MD)
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
  
***** 05.01.21 работаем по текущей записи
Function f1_create2reestr19(_nyear,_nmonth)
  Local i, j, lst, s

  fl_DISABILITY := is_zak_sl := is_zak_sl_vr := .f.
  lshifr_zak_sl := lvidpoms := ""
  a_usl := {} ; a_fusl := {} ; lvidpom := 1 ; lfor_pom := 3
  atmpusl := {} ; akslp := {} ; akiro := {} ; tarif_zak_sl := human->cena_1
  kol_kd := 0
  is_KSG := is_mgi := .f.
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
  pr_amb_reab := .f.
  fl_disp_nabl := .f.
  is_disp_DVN := .f.
  is_disp_DVN_COVID := .f.
  ldate_next := ctod("")
  ar_dn := {}
  //
  is_oncology_smp := 0
  is_oncology := f_is_oncology(1,@is_oncology_smp)
  if p_tip_reestr == 2
    is_oncology := 0
  endif
  arr_onkna := {}
  select ONKNA
  find (str(human->kod,7))
  do while onkna->kod == human->kod .and. !eof()
    mosu->(dbGoto(onkna->U_KOD))
    aadd(arr_onkna, {onkna->NAPR_DATE,onkna->NAPR_V,onkna->MET_ISSL,mosu->shifr1,onkna->NAPR_MO})
    skip
  enddo
  select ONKCO
  find (str(human->kod,7))
  //
  select ONKSL
  find (str(human->kod,7))
  //
  arr_onkdi := {}
  if eq_any(onksl->b_diag,98,99)
    select ONKDI
    find (str(human->kod,7))
    do while onkdi->kod == human->kod .and. !eof()
      aadd(arr_onkdi, {onkdi->DIAG_DATE,onkdi->DIAG_TIP,onkdi->DIAG_CODE,onkdi->DIAG_RSLT})
      skip
    enddo
  endif
  //
  arr_onkpr := {}
  if human_->USL_OK < 3 // противопоказания по лечению только в стационаре и дневном стационаре
    select ONKPR
    find (str(human->kod,7))
    do while onkpr->kod == human->kod .and. !eof()
      aadd(arr_onkpr, {onkpr->PROT,onkpr->D_PROT})
      skip
    enddo
  endif
  if eq_any(onksl->b_diag,0,7,8) .and. ascan(arr_onkpr,{|x| x[1] == onksl->b_diag }) == 0
    // добавим отказ,не показано,противопоказано по гистологии
    aadd(arr_onkpr, {onksl->b_diag,human->n_data})
  endif
  //
  arr_onk_usl := {}
  if iif(human_2->VMP == 1, .t., between(onksl->DS1_T,0,2))
    select ONKUS
    find (str(human->kod,7))
    do while onkus->kod == human->kod .and. !eof()
      if between(onkus->USL_TIP,1,5)
        aadd(arr_onk_usl,onkus->USL_TIP)
      endif
      skip
    enddo
  endif
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
      if eq_any(left(lshifr,5),"1.11.","55.1.")
        kol_kd += hu->kol_1
        is_KSG := .t.
      elseif left(lshifr,5) == "2.89."
        pr_amb_reab := .t.
      elseif left(lshifr,5) == "60.9."
        is_mgi := .t.
      endif
      if !empty(s) .and. "," $ s
        lvidpoms := s
      endif
      if (hu->stoim_1 > 0 .or. left(lshifr,3) == "71.") .and. (i := ret_vid_pom(1,lshifr,human->k_data)) > 0
        lvidpom := i
      endif
      if human_->USL_OK == 3
        if f_is_neotl_pom(lshifr)
          lfor_pom := 2 // неотложная
        elseif eq_any(left(lshifr,5),"60.4.","60.5.","60.6.","60.7.","60.8.")
          select OTD
          dbGoto(human->otd)
          if fieldnum("TIP_OTD") > 0 .and. otd->TIP_OTD == 1  // отделение приёмного покоя стационара
            lfor_pom := 2 // неотложная
          endif
        endif
      endif
      if lst == 1
        lshifr_zak_sl := lshifr
        if f_is_zak_sl_vr(lshifr) // зак.случай в п-ке
          is_zak_sl_vr := .t.
        else
          is_zak_sl_vr := .t. // КСГ
          if human_->USL_OK < 3 .and. p_tip_reestr == 1
            tarif_zak_sl := hu->STOIM_1
            if !empty(human_2->pc1)
              akslp := List2Arr(human_2->pc1)
            endif
            if !empty(human_2->pc2)
              akiro := List2Arr(human_2->pc2)
            endif
          endif
          if !empty(akslp) .or. !empty(akiro)
            otd->(dbGoto(human->OTD))
            f_put_glob_podr(human_->USL_OK,human->K_DATA) // заполнить код подразделения
            tarif_zak_sl := fcena_oms(lshifr,(human->vzros_reb==0),human->k_data)
          endif
        endif
      else
        aadd(a_usl,hu->(recno()))
      endif
    endif
    select HU
    skip
  enddo
  if human_->USL_OK == 1 .and. human_2->VMP == 1 .and. !emptyany(human_2->VIDVMP,human_2->METVMP) // ВМП
    is_KSG := .f.
  endif
  if !empty(lvidpoms)
    if !eq_ascan(atmpusl,"55.1.2","55.1.3") .or. glob_mo[_MO_KOD_TFOMS] == '801935' // ЭКО-Москва
      lvidpoms := ret_vidpom_licensia(human_->USL_OK,lvidpoms,human_->profil) // только для дн.стационара при стационаре
    else
      if eq_ascan(atmpusl,"55.1.3")
        lvidpoms := ret_vidpom_st_dom_licensia(human_->USL_OK,lvidpoms,human_->profil)
      endif
    endif
    if !empty(lvidpoms) .and. !("," $ lvidpoms)
      lvidpom := int(val(lvidpoms))
      lvidpoms := ""
    endif
  endif
  if !empty(lvidpoms)
    if eq_ascan(atmpusl,"55.1.1","55.1.4")
      if "31" $ lvidpoms
        lvidpom := 31
      endif
    elseif eq_ascan(atmpusl,"55.1.2","55.1.3","2.76.6","2.76.7","2.81.67")
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
    is_disp_DVN := .t.
    arr_usl_otkaz := {}
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := "mdiag"+sk
      pole_1dispans := "m1dispans"+sk
      pole_dn_dispans := "mdndispans"+sk
      &pole_diag := space(6)
      &pole_1dispans := 0
      &pole_dn_dispans := ctod("")
    next
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
  elseif between(human->ishod,401,402) // углубленная диспансеризация после COVID
    is_disp_DVN_COVID := .t.
    arr_usl_otkaz := {}
    for i := 1 to 5
      sk := lstr(i)
      pole_diag := "mdiag"+sk
      pole_1dispans := "m1dispans"+sk
      pole_dn_dispans := "mdndispans"+sk
      &pole_diag := space(6)
      &pole_1dispans := 0
      &pole_dn_dispans := ctod("")
    next
    read_arr_DVN_COVID(human->kod)
    if valtype(arr_usl_otkaz) == "A"
      for j := 1 to len(arr_usl_otkaz)
        ar := arr_usl_otkaz[j]
        if valtype(ar) == "A" .and. len(ar) >= 10 .and. valtype(ar[5]) == "C"
          lshifr := alltrim(ar[5])
          if (i := ascan(uslugiEtap_DVN_COVID(iif(human->ishod == 401, 1, 2)), {|x| valtype(x[2])=="C" .and. x[2]==lshifr})) > 0
          else   // записываем только федеральные услуги
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
        if mtab_v_dopo_na != 0
          if P2TABN->(dbSeek(str(mtab_v_dopo_na,5)))
            aadd(arr_nazn,{3, i, P2TABN->snils, put_prvs_to_reestr(P2TABN->PRVS,_NYEAR)}) // теперь каждое назначение в отдельном PRESCRIPTIONS
          else
            aadd(arr_nazn,{3, i, '', ''}) // теперь каждое назначение в отдельном PRESCRIPTIONS
          endif
        else
          aadd(arr_nazn,{3, i, '', ''}) // теперь каждое назначение в отдельном PRESCRIPTIONS
        endif
        // aadd(arr_nazn,{3, i, mtab_v_dopo_na}) // теперь каждое назначение в отдельном PRESCRIPTIONS
      endif
    next
    //aadd(arr_nazn,{3,{}}) ; j := len(arr_nazn)
    //for i := 1 to 4
      //if isbit(m1dopo_na,i)
        //aadd(arr_nazn[j,2],i)
      //endif
    //next
  endif
  if between(m1napr_v_mo,1,2) .and. !empty(arr_mo_spec) // {{"-- нет --",0},{"в нашу МО",1},{"в иную МО",2}}, ;
    for i := 1 to len(arr_mo_spec) // теперь каждая специальность в отдельном PRESCRIPTIONS
      if mtab_v_mo != 0
        if P2TABN->(dbSeek(str(mtab_v_mo,5)))
          aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), P2TABN->snils, , put_prvs_to_reestr(P2TABN->PRVS,_NYEAR)}) // "-", т.к. спец-ть была в кодировке V015
        else
          aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), '', ''}) // "-", т.к. спец-ть была в кодировке V015
        endif
      else
        aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), '', ''}) // "-", т.к. спец-ть была в кодировке V015
      endif
      // aadd(arr_nazn,{m1napr_v_mo, put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR), mtab_v_mo}) // "-", т.к. спец-ть была в кодировке V015
    next
    //aadd(arr_nazn,{m1napr_v_mo,{}}) ; j := len(arr_nazn)
    //for i := 1 to min(3,len(arr_mo_spec))
    //  aadd(arr_nazn[j,2],put_prvs_to_reestr(-arr_mo_spec[i],_NYEAR)) // "-", т.к. спец-ть была в кодировке V015
    //next
  endif
  if between(m1napr_stac,1,2) .and. m1profil_stac > 0 // {{"--- нет ---",0},{"в стационар",1},{"в дн. стац.",2}}, ;
    if mtab_v_stac != 0
      if P2TABN->(dbSeek(str(mtab_v_stac,5)))
        aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, P2TABN->snils, , put_prvs_to_reestr(P2TABN->PRVS,_NYEAR)})
      else
        aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, '', ''})
      endif
    else
      aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, '', ''})
    endif
    // aadd(arr_nazn,{iif(m1napr_stac==1,5,4), m1profil_stac, mtab_v_stac})
  endif
  if m1napr_reab == 1 .and. m1profil_kojki > 0
    if mtab_v_reab != 0
      if P2TABN->(dbSeek(str(mtab_v_reab,5)))
        aadd(arr_nazn,{6, m1profil_kojki, P2TABN->snils, , put_prvs_to_reestr(P2TABN->PRVS,_NYEAR)})
      else
        aadd(arr_nazn,{6, m1profil_kojki, '', ''})
      endif
    else
      aadd(arr_nazn,{6, m1profil_kojki, '', ''})
    endif
    // aadd(arr_nazn,{6, m1profil_kojki, mtab_v_reab})
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
    if human->OBRASHEN == '1' .and. ascan(mdiagnoz, {|x| padr(x,5) == "Z03.1" }) == 0
      aadd(mdiagnoz,"Z03.1")
    endif
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
  return NIL
  