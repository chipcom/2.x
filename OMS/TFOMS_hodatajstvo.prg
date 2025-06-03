***** работа с ходотайствами в ТФОМС - TFOMS_hodotajstvo.prg
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

Static Shodata_sem := "Работа с ходатайствами"
Static Shodata_err := "В данный момент с ходатайствами работает другой пользователь."

***** 13.05.22 оформление ходатайства
Function TFOMS_hodatajstvo(arr_m,iRefr,par)
  // Функция отрабатывает только par = 1 или 2 и ошибку iReft = 57 или 599
  // arr_m - временной массив
  // iRefr - код ошибки 57 или 599
  // par - параметр указывающий действие,
  //      1 - Создание файла ХОДАТАЙСТВА для отсылки в ТФОМС
  //      2 - Оформление (печать) ХОДАТАЙСТВА (по старому)
  Local buf24 := save_maxrow(), t_arr[BR_LEN], blk

  if !myFileDeleted(cur_dir()+"tmp_k"+sdbf)
    return NIL
  endif

  mywait()
  dbcreate(cur_dir()+"tmp_k",{{"kod","N",7,0},;
                            {"kod_lu","N",7,0},;
                            {"k_data","D",8,0},;
                            {"is","N",1,0}})
  use (cur_dir()+"tmp_k") new
  R_Use(dir_server()+"human",,"HUMAN")
  use (cur_dir()+"tmp_h") new
  go top
  do while !eof()
    if tmp_h->REFREASON == iRefr
      human->(dbGoto(tmp_h->kod))
      select TMP_K
      append blank
      replace kod with human->kod_k,;
              kod_lu with human->(recno()),;
              k_data with human->k_data,;
              is with 1
    endif
    select TMP_H
    skip
  enddo
  close databases
  if par == 1     // Создание файла ХОДАТАЙСТВА для отсылки в ТФОМС
    return create_file_hodatajstvo(arr_m)
  endif
  //
  R_Use(dir_server()+"kartote_",,"KART_")
  R_Use(dir_server()+"kartotek",,"KART")
  use (cur_dir()+"tmp_k") new alias TMP
  set relation to kod into KART, to kod into KART_
  index on upper(kart->fio) to (cur_dir()+"tmp_k")
  rest_box(buf24)
  //
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow()-2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := "Выбор пациентов для оформления ходатайства"
  t_arr[BR_TITUL_COLOR] := "B/BG"
  t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
  blk := {|| iif(tmp->is==1, {1,2}, {3,4}) }
  t_arr[BR_COLUMN] := {{ ' ', {|| iif(tmp->is==1, '', ' ') },blk },;
                       { center("ФИО",30), {|| padr(kart->fio,30) },blk },;
                       { " ",{|| kart->pol },blk },;
                       { "Дата рожд.",{|| full_date(kart->date_r) },blk },;
                       { " Адрес",{|| padr(ret_okato_ulica(kart->adres,kart_->okatog,,2),26) },blk }}
  t_arr[BR_EDIT] := {|nk,ob| f1tfoms_hodatajstvo(nk,ob,"edit") }
  t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ выход для редактирования и печати;  ^<+,-,Ins>^ отметить пациента для печати") }
  go top
  Private ob_kol := tmp->(lastrec())
  edit_browse(t_arr)
  if ob_kol > 0
    delFRfiles()
    adbf := {{"name","C",80,0},;
             {"predst","C",40,0},;
             {"data","C",10,0}}
    dbcreate(fr_titl, adbf)
    use (fr_titl) new alias FRT
    append blank
    frt->name   := glob_mo[_MO_SHORT_NAME]
    frt->predst := ""
    frt->data   := full_date(sys_date)
    //
    adbf := {{"fio","C",30,0},;
             {"fam","C",40,0},;
             {"ima","C",40,0},;
             {"ots","C",40,0},;
             {"pol_m","C",1,0},;
             {"pol_g","C",1,0},;
             {"date_r","C",10,0},;
             {"mesto_r","C",100,0},;
             {"vpasport","C",50,0},;
             {"spasport","C",10,0},;
             {"npasport","C",20,0},;
             {"dpasport","C",10,0},;
             {"gragd","C",40,0},;
             {"snils","C",14,0},;
             {"iadres","C",6,0},;
             {"sadres","C",40,0},;
             {"radres","C",40,0},;
             {"gadres","C",40,0},;
             {"nadres","C",40,0},;
             {"ulica","C",50,0},;
             {"dom","C",10,0},;
             {"korp","C",10,0},;
             {"kvar","C",10,0},;
             {"phone","C",20,0},;
             {"email","C",40,0},;
             {"is","N",1,0}}
    dbcreate(fr_data,adbf)
    use (fr_data) new alias FRD
    select TMP
    go top
    do while !eof()
      if tmp->is == 1
        arr := retFamImOt(1,.f.)
        select FRD
        append blank
        frd->fio := fam_i_o(kart->fio,arr)
        frd->fam := arr[1]
        frd->ima := arr[2]
        frd->ots := arr[3]
        frd->pol_m := iif(kart->pol=="М",'√',' ')
        frd->pol_g := iif(kart->pol=="М",' ','√')
        frd->date_r := full_date(kart->date_r)
        frd->mesto_r := kart_->mesto_r
        frd->vpasport := inieditspr(A__MENUVERT, getF011(), kart_->vid_ud)
        frd->spasport := kart_->ser_ud
        frd->npasport := kart_->nom_ud
        frd->dpasport := full_date(kart_->kogdavyd)
        if !(empty(kart_->strana) .or. kart_->strana=='643')
          frd->gragd := inieditspr(A__MENUVERT, getO001(), kart_->strana)
        endif
        if !empty(kart->SNILS)
          frd->snils := transform(kart->SNILS,picture_pf)
        endif
        frd->iadres := ""
        arr := ret_okato_Array(kart_->okatog)
        frd->sadres := arr[1]
        frd->radres := arr[2]
        frd->gadres := arr[3]
        frd->nadres := arr[4]
        frd->ulica := kart->adres
        frd->dom := ""
        frd->korp := ""
        frd->kvar := ""
        frd->phone := kart_->PHONE_W
        frd->email := ""
      endif
      select TMP
      skip
    enddo
    //
    t_arr[BR_TOP] := 2
    t_arr[BR_BOTTOM] := maxrow()-2
    t_arr[BR_LEFT] := 2
    t_arr[BR_RIGHT] := 77
    t_arr[BR_COLOR] := color0
    t_arr[BR_TITUL] := "Редактирование пациентов для оформления ходатайства"
    t_arr[BR_TITUL_COLOR] := "B/BG"
    t_arr[BR_ARR_BROWSE] := {'═','░','═',"N/BG,W+/N,B/BG,W+/B",.t.}
    blk := {|| iif(frd->is==1, {1,2}, {3,4}) }
    t_arr[BR_COLUMN] := {{ center("ФИО",20), {|| padr(fio,20) },blk },;
                         { "Дата рожд.",{|| full_date(date_r) },blk },;
                         { " Улица",{|| padr(ulica,40) },blk }}
    t_arr[BR_EDIT] := {|nk,ob| f2tfoms_hodatajstvo(nk,ob,"edit") }
    t_arr[BR_STAT_MSG] := {|| status_key("^<Esc>^ - выход;  ^<Enter>^ - редактирование адреса;  ^<F9>^ - печать ходатайств") }
    select FRD
    go top
    edit_browse(t_arr)
    close databases
  endif
  close databases
  return NIL

*****
Function f1tfoms_hodatajstvo(nKey,oBrow,regim)
  Local k := -1, rec, fl
  if regim == "edit"
    do case
      case nkey == K_INS
        replace tmp->is with if(tmp->is==1,0,1)
        if tmp->is==1
          ob_kol++
        else
          ob_kol--
        endif
        k := 0
        keyboard chr(K_TAB)
      case nkey == 43 .or. nkey == 45  // + или -
        fl := (nkey == 43)
        rec := recno()
        tmp->(dbeval({|| tmp->is := iif(fl,1,0) }))
        goto (rec)
        if fl
          ob_kol := tmp->(lastrec())
        else
          ob_kol := 0
        endif
        k := 0
    endcase
  endif
  return k
  
*****
Function f2tfoms_hodatajstvo(nKey,oBrow,regim)
  Local k := -1, rec, fl, buf := savescreen()
  if regim == "edit"
    do case
      case nkey == K_ENTER
        Private miadres := frd->iadres,;
                msadres := frd->sadres,;
                mradres := frd->radres,;
                mgadres := frd->gadres,;
                mnadres := frd->nadres,;
                mulica  := frd->ulica ,;
                mdom    := frd->dom   ,;
                mkorp   := frd->korp  ,;
                mkvar   := frd->kvar  ,;
                mphone  := frd->phone ,;
                memail  := frd->email ,;
                mpredst := frt->predst,;
                mdata   := frt->data
        r := 8
        setcolor(cDataCGet)
        ClrLines(r,23)
        @ r,0 to r,79
        str_center(r,alltrim(frd->fio))
        ++r
        ++r ; @ r,1 say "Почтовый индекс" get miadres
        ++r ; @ r,1 say "Регион" get msadres when .f.
        ++r ; @ r,1 say "Район" get mradres
        ++r ; @ r,1 say "Город" get mgadres
        ++r ; @ r,1 say "Село" get mnadres
        ++r ; @ r,1 say "Улица" get mulica
        ++r ; @ r,1 say "Дом" get mdom
        ++r ; @ r,1 say "Корпус" get mkorp
        ++r ; @ r,1 say "Квартира" get mkvar
        ++r ; @ r,1 say "Служебный телефон" get mphone
        ++r ; @ r,1 say "E-mail" get memail
        ++r ; @ r,1 say "Представитель" get mpredst
        ++r ; @ r,1 say "Дата ходатайства" get mdata
        status_key("^<Esc>^ - выход;  ^<PgDn>^ - запись")
        myread()
        if lastkey() != K_ESC
          frd->is := 1
          frd->iadres := miadres
          frd->sadres := msadres
          frd->radres := mradres
          frd->gadres := mgadres
          frd->nadres := mnadres
          frd->ulica  := mulica
          frd->dom    := mdom
          frd->korp   := mkorp
          frd->kvar   := mkvar
          frd->phone  := mphone
          frd->email  := memail
          frt->predst := mpredst
          frt->data   := mdata
          Commit
        endif
        restscreen(buf)
        k := 0
      case nkey == K_F9
        rec := recno()
        close databases
        call_fr("mo_hodat")
        use (fr_titl) new alias FRT
        use (fr_data) new alias FRD
        goto (rec)
        k := 0
    endcase
  endif
  return k
  
// 29.03.23 создание файла ХОДАТАЙСТВА для отсылки в ТФОМС
Function create_file_hodatajstvo(arr_m)
  // arr_m - временной массив
  Local i, k := 0, as, fl := .f., mnn, mb, me, mfilial,;
        buf := save_maxrow()

  R_Use(dir_server()+"organiz",,"ORG")
  if empty(mfilial := org->filial_h)
    close databases
    return func_error(4,'Не выбран филиал ТФОМС для отправки файла с ходатайствами ("Ваша организация")')
  endif

  mywait()
  dbcreate(cur_dir()+"tmp_k1",{{"kod","N",7,0},;
                             {"kod_lu","N",7,0},;
                             {"k_data","D",8,0},;
                             {"ntable","N",1,0},;
                             {"is","N",1,0}})
  use (cur_dir()+"tmp_k1") new
  index on str(kod,7) to (cur_dir()+"tmp_k1")

  use (cur_dir()+"tmp_k") new
  go top
  do while !eof()
    select TMP_K1
    find (str(tmp_k->kod,7))
    if found()
      if tmp_k->k_data > tmp_k1->k_data
        replace kod_lu with tmp_k->kod_lu,;
                k_data with tmp_k->k_data
      endif
    else
      append blank
      replace kod    with tmp_k->kod,;
              kod_lu with tmp_k->kod_lu,;
              k_data with tmp_k->k_data,;
              is with 1
    endif
    select TMP_K
    skip
  enddo

  f_mb_me_nsh(2013,@mb,@me)

  R_Use(dir_server()+"mo_hod",,"HOD")
  index on str(nn,3) to (cur_dir()+"tmp_rees") for year(dfile)==year(sys_date)

  for mnn := mb to me
    find (str(mnn,3))
    if !found() // нашли свободный номер
      fl := .t.
      exit
    endif
  next

  if !fl
    rest_box(buf)
    close databases
    return func_error(10,"Не удалось найти свободный номер пакета в ТФОМС. Проверьте настройки!")
  endif
  set index to

  R_Use(dir_server()+"mo_hod_k",,"HODK")
  set relation to kod into HOD
  index on str(kod_k,7) to (cur_dir()+"tmp_hodk") ;
        for hod->nyear==arr_m[1] .and. hod->nmonth==arr_m[2]

  select TMP_K1
  go top
  do while !eof()
    select HODK
    find (str(tmp_k1->kod,7))
    if found()
      tmp_k1->is := 0
    endif
    select TMP_K1
    skip
  enddo
  delete for is == 0
  pack
  as := {{0,'34001',''},{0,'34002',''},{0,'34006',''},{0,'34007',''},{0,'прочие',''}}

  R_Use(dir_server()+"human_",,"HUMAN_")
  select TMP_K1
  set index to
  go top
  do while !eof()
    human_->(dbGoto(tmp_k1->kod_lu))
    i := 3
    if human_->smo == as[1,2]
      i := 1
    elseif human_->smo == as[2,2]
      i := 2
    endif
    tmp_k1->ntable := i
    ++k
    ++as[i,1]
    skip
  enddo
  close databases
  rest_box(buf)
  if k == 0
    return func_error(4, 'По всем пациентам уже отправлены ходатайства ' + arr_m[4])
  endif
  j := 0
  for i := 1 to 3
    if as[i,1] > 0
      ++j
    endif
  next
  if f_alert({'Составляется архив с ходатайствами',;
              '(количество пациентов - '+lstr(k)+', количество таблиц Excel - '+lstr(j)+').',;
              '',;
              'Выберите действие:'},;
             {" Отказ "," Создание файла ходатайства "},;
             2,"GR+/R","W+/R",16,,"GR+/R,N/BG") == 2
    n_file := 'HD_' + lstr(mfilial) + '_M' + glob_mo[_MO_KOD_TFOMS] + '_' + lstr(mnn)
    for i := 1 to 3
      if as[i,1] > 0
        // as[i,3] := n_file+"_"+as[i,2]+".xls"
        as[i,3] := n_file+"_"+as[i,2]+".xlsx"
        delete file (as[i,3])
        delFRfiles()
        adbf := {{"name_f","C",30,0},;
                 {"codemo","C",6,0},;
                 {"name","C",60,0},;
                 {"data","C",10,0}}
        dbcreate(fr_titl, adbf)
        use (fr_titl) new alias FRT
        append blank
        frt->name_f := as[i,3]
        frt->codemo := glob_mo[_MO_KOD_TFOMS]
        frt->name   := glob_mo[_MO_SHORT_NAME]
        frt->data   := full_date(sys_date)
        adbf := {{"nomer","N",4,0},;
                 {"fam","C",50,0},;
                 {"im","C",50,0},;
                 {"ot","C",50,0},;
                 {"pol","C",3,0},;
                 {"date_r","C",10,0},;
                 {"vid_ud","N",2,0},;
                 {"name_ud","C",20,0},;
                 {"ser_ud","C",10,0},;
                 {"nom_ud","C",20,0},;
                 {"mesto_r","C",100,0},;
                 {"snils","C",14,0},;
                 {"okatog","C",11,0},;
                 {"adresg","C",250,0},;
                 {"vidpolis","C",10,0},;
                 {"polis","C",40,0},;
                 {"smo","C",5,0},;
                 {"name_smo","C",60,0},;
                 {"okato","C",5,0},;
                 {"region","C",60,0},;
                 {"proch","C",60,0}}
        dbcreate(fr_data,adbf)
        use (fr_data) new alias FRD
        R_Use(dir_exe()+"_mo_smo",cur_dir()+"_mo_smo2","SMO")
        R_Use(dir_server()+"kartote_",,"KART_")
        R_Use(dir_server()+"kartotek",,"KART")
        set relation to recno() into KART_
        R_Use(dir_server()+"human_",,"HUMAN_")
        R_Use(dir_server()+"human",,"HUMAN")
        set relation to recno() into HUMAN_, kod_k into KART
        use (cur_dir()+"tmp_k1") new
        set relation to kod_lu into HUMAN
        index on upper(human->fio) to (cur_dir()+"tmp_k1")
        k := 0
        go top
        do while !eof()
          if tmp_k1->ntable == i
            arr_fio := retFamImOt(2)
            select FRD
            append blank
            frd->nomer := ++k
            frd->FAM := arr_fio[1]
            frd->IM  := arr_fio[2]
            frd->OT  := arr_fio[3]
            frd->pol := iif(human->pol == 'М', 'муж', 'жен')
            frd->date_r := full_date(human->date_r)
            frd->vid_ud := kart_->vid_ud
            frd->name_ud := get_Name_Vid_Ud(kart_->vid_ud)
            frd->ser_ud := kart_->ser_ud
            frd->nom_ud := kart_->nom_ud
            if !empty(smr := del_spec_symbol(kart_->mesto_r))
              frd->mesto_r := charone(" ",smr)
            endif
            if !empty(kart->snils)
              frd->snils := transform(kart->SNILS,picture_pf)
            endif
            frd->okatog := kart_->okatog
            frd->adresg := ret_okato_ulica(kart->adres,kart_->okatog,1,2)
            frd->vidpolis := lstr(human_->VPOLIS)+"-"+inieditspr(A__MENUVERT, mm_vid_polis, human_->VPOLIS)
            frd->polis := alltrim(alltrim(human_->SPOLIS)+" "+human_->NPOLIS)
            frd->smo := human_->smo
            frd->name_smo := inieditspr(A__MENUVERT, glob_arr_smo, int(val(human_->smo)))
            if empty(frd->name_smo)
              select SMO
              find (padr(human_->smo,5))
              frd->name_smo := smo->name
            endif
            if empty(frd->okato := human_->okato)
              select SMO
              find (padr(human_->smo,5))
              frd->okato := smo->okato
            endif
            frd->region := inieditspr(A__MENUVERT, glob_array_srf, frd->okato)
            frd->proch := alltrim(alltrim(kart_->PHONE_H)+" "+alltrim(kart_->PHONE_M)+" "+kart_->PHONE_W)
          endif
          select TMP_K1
          skip
        enddo
        close databases

        error := hodotajstvoXLS( n_file + '_' + as[i, 2] )
        if ! empty(error)
          return func_error(4, 'Ошибка создания файла ходатайства.')
        endif
        // call_fr("mo_hodex",3,as[i,3],,.f.)
      endif
    next
    
    G_Use(dir_server()+"mo_hod",,"HOD")
    AddRecN()
    hod->KOD := recno()
    hod->NYEAR := arr_m[1]
    hod->NMONTH := arr_m[2]
    hod->NN := mnn
    hod->KOL1 := 0
    hod->KOL2 := 0
    hod->KOL3 := 0
    hod->FNAME := n_file
    hod->DFILE := sys_date
    hod->TFILE := hour_min(seconds())
    hod->DATE_OUT := ctod("")
    hod->NUMB_OUT := 0
    G_Use(dir_server()+"mo_hod_k",,"HODK")
    index on str(kod,6) to (cur_dir()+"tmp_hodk")
    use (cur_dir()+"tmp_k1") new
    arr_zip := {}
    for i := 1 to 3
      if as[i,1] > 0
        aadd(arr_zip, as[i,3])
        select TMP_K1
        go top
        do while !eof()
          if tmp_k1->ntable == i
            select HODK
            AddRec(6)
            hodk->KOD := hod->KOD
            hodk->KOD_K := tmp_k1->kod
            pole := "hod->KOL"+lstr(i)
            &pole := &pole + 1
          endif
          select TMP_K1
          skip
        enddo
      endif
    next
    close databases
    if chip_create_zipXML(n_file+szip(),arr_zip,.t.)
      view_list_hodatajstvo()
    endif
  endif
  return NIL
  
***** 04.02.13
Function view_list_hodatajstvo()
  Local buf := savescreen()

  if !G_SLock(Shodata_sem)
    return func_error(4,Shodata_err)
  endif
  Private goal_dir := dir_server()+dir_XML_MO()+hb_ps()
  G_Use(dir_server()+"mo_hod",,"HOD")
  index on str(year(dfile),4)+str(nn,4) to (cur_dir()+"tmp_hod") DESCENDING
  go top
  if eof()
    func_error(4,"Нет файлов ходатайств")
  else
    Alpha_Browse(T_ROW,2,22,77,"f1_view_list_hodatajstvo",color0,,,,,,,;
                 "f2_view_list_hodatajstvo",,{'═','░','═',"N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R",.t.,180} )
  endif
  close databases
  G_SUnLock(Shodata_sem)
  restscreen(buf)
  return NIL
  
  ***** 22.02.17
  Function f1_view_list_hodatajstvo(oBrow)
  Local oColumn, ;
        blk := {|| iif(hb_fileExists(goal_dir+alltrim(hod->FNAME)+szip()), ;
                       iif(empty(hod->date_out), {3,4}, {1,2}),;
                       {5,6}) }
  oColumn := TBColumnNew("Номер",{|| hod->nn })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("  Дата",{|| date_8(hod->dfile) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Пери-;од",{|| right(str(hod->nyear,4),2)+"/"+strzero(hod->nmonth,2) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Кол.;Капитал", {|| put_val(hod->kol1,6) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Кол.;Согаз", {|| put_val(hod->kol2,6) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Кол.;прочие", {|| put_val(hod->kol3,6) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(" Наименование файла",{|| padr(hod->FNAME,20) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew("Примечание",{|| f11_view_list_hodatajstvo() })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key("^<Esc>^ выход ^<Enter>^ просмотр ^<F5>^ запись ^<Del>^ удалить ещё не записанный файл")
  return NIL
  
*****
Static Function f11_view_list_hodatajstvo()
  Local s := ""

  if !hb_fileExists(goal_dir+alltrim(hod->FNAME)+szip())
    s := "нет файла"
  elseif empty(hod->date_out)
    s := "не записан"
  else
    s := "зап. "+lstr(hod->NUMB_OUT)+" раз"
  endif
  return padr(s,10)
  
// 15.10.24
Function f2_view_list_hodatajstvo(nKey,oBrow)
  Local ret := -1, tmp_color := setcolor(), r, r1, r2, arr_f,;
        s, buf := savescreen(), arr, i, k, mdate, t_arr[2], arr_pmt := {}
  local error


  do case
    case nKey == K_ENTER
      if (arr_f := Extract_Zip_XML(goal_dir,alltrim(hod->FNAME)+szip())) != NIL
        if (k := len(arr_f)) > 1
          stat_msg("Ждите. Сейчас будут открыты "+lstr(k)+" таблицы Excel в разных окнах.")
        else
          stat_msg("Ждите. Сейчас будет открыта таблица Excel "+arr_f[1])
        endif
        mybell(2,OK)
        for i := 1 to k
          // openExcel(_tmp_dir1()+arr_f[i])
          view_file_in_Viewer(_tmp_dir1()+arr_f[i])
        next
      endif
    case nKey == K_F5
      if f_Esc_Enter("записи файла за "+date_8(hod->dfile))
        Private p_var_manager := "copy_schet"
        s := manager(T_ROW,T_COL+5,maxrow()-2,,.t.,2,.f.,,,) // "norton" для выбора каталога
        if !empty(s)
          if upper(s) == upper(goal_dir)
            func_error(4,"Вы выбрали каталог, в котором уже записан целевой файл! Это недопустимо.")
          else
            zip_file := alltrim(hod->FNAME)+szip()
            if hb_fileExists(goal_dir+zip_file)
              mywait('Копирование "'+zip_file+'" в каталог "'+s+'"')
              //copy file (goal_dir+zip_file) to (hb_OemToAnsi(s)+zip_file)
              copy file (goal_dir+zip_file) to (s+zip_file)
              //if hb_fileExists(hb_OemToAnsi(s)+zip_file)
              if hb_fileExists(s+zip_file)
                hod->(G_RLock(forever))
                hod->DATE_OUT := sys_date
                if hod->NUMB_OUT < 99
                  hod->NUMB_OUT ++
                endif
                UnLock
                Commit
              else
                smsg := "Ошибка записи файла "+s+zip_file
                func_error(4,"Ошибка записи файла "+s+zip_file)
              endif
            else
              func_error(4,"Не обнаружен файл "+goal_dir+zip_file)
            endif
          endif
        endif
      endif
      ret := 0
    case nKey == K_DEL .and. empty(hod->DATE_OUT)
      if f_Esc_Enter("удаления файла за "+date_8(hod->dfile),.t.)
        stat_msg("Подтвердите удаление ещё раз.") ; mybell(2)
        if f_Esc_Enter("удаления файла за "+date_8(hod->dfile),.t.)
          mywait("Ждите. Производится удаление файла ходатайства.")
          G_Use(dir_server()+"mo_hod_k",,"HODK")
          index on str(kod,6) to (cur_dir()+"tmp_hodk")
          do while .t.
            find (str(hod->kod,6))
            if !found() ; exit ; endif
            DeleteRec(.t.)
          enddo
          zip_file := alltrim(hod->fname)+szip()
          if hb_fileExists(goal_dir+zip_file)
            delete file (goal_dir+zip_file)
          endif
          select HOD
          DeleteRec(.t.)
          stat_msg("Файл ходатайства удалён!") ; mybell(2,OK)
          ret := 1
        endif
      endif
  endcase
  setcolor(tmp_color)
  restscreen(buf)
  return ret
  