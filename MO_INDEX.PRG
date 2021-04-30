***** mo_index.prg - модуль переиндексирования и резервного копирования
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** запуск режима переиндексирования из меню
Function m_index_DB()
Local t2 := 0
if G_SLock1Task(sem_task,sem_vagno)  // запрет доступа всем
  if f_Esc_Enter("переиндексирования")
    t2 := pereindex()
    ___uslugi()
  endif
  // разрешение доступа всем
  G_SUnLock(sem_vagno)
  keyboard ""
  if t2 > 0
    n_message({"","Время переиндексирования - "+sectotime(t2)},,;
              color1,cDataCSay,,,color8)
  endif
else
  func_error(4,"В данный момент работают другие задачи. Переиндексирование запрещено!")
endif
return NIL

***** 18.11.18 внутренняя функция переиндексирования
Function pereindex()
Local buf := savescreen(), t1, t2, i, hGauge, ae[3], k, ab
f_message({"Ждите! Пpоизводится пеpеиндексирование базы данных.",;
           "",;
           "Ни в коем случае не прерывайте процесс",;
           "во избежание нежелательных последствий!"},,"GR+/R","W+/R",13)
t1 := seconds()
Private fl_open := .t.
for i := 1 to len(array_files_DB)
  index_base(array_files_DB[i])
next
//
use (dir_server+"mo_ppadd") new
pack
use
//
pereindex_263()
if is_task(X_KEK)
  pereindex_KEK()
endif
//
Stat_Msg('Поиск и копирование ЕНП')
use_base("kartotek",,.t.) // открыть в монопольном режиме
set index to
go top
do while !eof()
  if kart->kod > 0
    @ maxrow(),1 say str(recno()/lastrec()*100,6,2)+"%" color cColorStMsg
    select KART2
    goto (kart->(recno()))
    if !empty(kart2->kod_mis) .and. !(kart->kod_mis == kart2->kod_mis)
      kart->kod_mis := kart2->kod_mis
    endif
  endif
  select KART
  if recno() % 5000 == 0
    commit
  endif
  skip
enddo
index on if(kod>0,"1","0")+kod_mis to (dir_server+"kartotee") progress
close databases
//
mywait()
Use (dir_server+"mo_raksh") new alias RAKSH
index on str(kod_raks,6) to (cur_dir+"tmpraksh")
Use (dir_server+"mo_raks") new alias RAKS
index on str(akt,6) to (cur_dir+"tmpraks")
Use (dir_server+"mo_rak") new alias RAK
index on str(akt,6) to (cur_dir+"tmprak")
Use (dir_server+"mo_xml") new alias MO_XML
Locate for kod == 0 .and. !deleted()
if found()
  delete // если прервали процесс
endif
//
select RAK
find (str(0,6))
do while rak->akt == 0 .and. !eof()
  if !deleted() // если прервали процесс
    do while .t.
      select RAKS
      find (str(rak->(recno()),6))
      if !found() ; exit ; endif
      do while .t.
        select RAKSH
        find (str(raks->KOD_RAKS,6))
        if !found() ; exit ; endif
        DeleteRec(.t.)
      enddo
      select RAKS
      DeleteRec(.t.)
    enddo
    select RAK
    DeleteRec(.t.)
  endif
  select RAK
  skip
enddo
//
select RAKS
find (str(0,6))
do while raks->akt == 0 .and. !eof()
  if raks->KOD_RAKS == 0 .and. !deleted() // если прервали процесс
    do while .t.
      select RAKSH
      find (str(raks->(recno()),6))
      if !found() ; exit ; endif
      DeleteRec(.t.)
    enddo
    select RAKS
    DeleteRec(.t.)
  endif
  select RAKS
  skip
enddo
//
select RAKSH
find (str(0,6))
do while raksh->kod_raks == 0 .and. !eof()
  if !deleted() // если не помечена на удаление
    Delete
  endif
  skip
enddo
//
select RAKSH
pack // упаковка файла нижнего уровня
close databases
Use (dir_server+"mo_rpdsh") new
pack // упаковка файла нижнего уровня
close databases
//
/*Use (dir_server+"mo_rak") new alias RAK
index on str(akt,6) to (cur_dir+"tmprak") for empty(kod_xml)
arr_rak := {}
dbeval({|| aadd(arr_rak, {akt,codea,nakt,dakt}) })
if !empty(arr_rak) // не заполнен kod_xml из-за моей ошибки
  min_date := max_date := arr_rak[1,4]
  for i := 1 to len(arr_rak)
    min_date := min(min_date,arr_rak[i,4])
    max_date := max(max_date,arr_rak[i,4])
  next
  min_date -= 10
  max_date += 10
  select RAK
  set index to
  Use (dir_server+"mo_xml") new alias MO_XML
  index on str(kod,6) to (cur_dir+"tmpxml") ;
        for TIP_IN == _XML_FILE_RAK .and. between(DFILE,min_date,max_date)
  arr_xml := {}
  dbeval({|| aadd(arr_xml, {kod,fname,dfile}) })
  if !empty(arr_xml)
    mywait("Ждите! Производится исправление ошибки чтения РАК...")
  endif
  for j := 1 to len(arr_xml)
    close databases
    cFile := alltrim(arr_xml[j,2])
    if Extract_Zip_XML(dir_server+dir_XML_TF,cFile+szip) != NIL
      oXmlDoc := HXMLDoc():Read(_tmp_dir1+cFile+sxml)
      reestr_rak_tmpfile(oXmlDoc,{},_tmp_dir1+cFile+szip)
      Use (dir_server+"mo_rak") new alias RAK
      select TMP2
      go top
      do while !eof()
        if (i := ascan(arr_rak, {|x| x[2]==tmp2->_CODEA .and. x[3]==tmp2->_NAKT .and. x[4]==tmp2->_DAKT })) > 0
          select RAK
          goto (arr_rak[i,1])
          if empty(rak->KOD_XML)
            rak->KOD_XML := arr_xml[j,1]
          endif
        endif
        select TMP2
        skip
      enddo
    endif
  next
endif
close databases*/
Use (dir_server+"mo_nnapr") new alias NAPR
go top
do while !eof()
  if !empty(napr->num_d) .and. !between(napr->USL_OK_1,1,2)
    napr->USL_OK_1 := 1
  endif
  if napr->TYPE_H_4 > 0 .and. !between(napr->USL_OK_4,1,2)
    napr->USL_OK_4 := 1
  endif
  skip
enddo
Use (dir_server+"mo_n7in") new alias N7i
go top
do while !eof()
  if !between(n7i->USL_OK,1,2)
    n7i->USL_OK := 1
  endif
  skip
enddo
Use (dir_server+"mo_n7out") new alias N7
go top
do while !eof()
  if !between(n7->USL_OK,1,2)
    n7->USL_OK := 1
  endif
  skip
enddo
close databases
Use (dir_server+"mo_kekh") new alias HU
go top
do while !eof()
  if !between(hu->USL_OK,1,3)
    hu->USL_OK := 1
  endif
  skip
enddo
close databases
//
stat_msg("Пеpеиндексирование завеpшено!")
t2 := seconds() - t1
restscreen(buf)
return t2

***** 02.09.15 поиск и удаление дубликатов в картотеке по ключу "код ТФ(PID)+ФИО+дата рождения"
Function dubl_zap_kod_tf()
Local j := 0, old_tf := 0, ii := 0, k, ar[10], name_file := "kod_tf.txt",;
      rec, i, j1, j2, ak := {}, buf := savescreen()
f_message({"Ждите! Пpоизводится поиск и удаление дубликатов в картотеке.",;
           "",;
           "Ни в коем случае не прерывайте процесс",;
           "во избежание нежелательных последствий!"},,"G+/R","GR+/R",13)
Stat_Msg('Поиск дубликатов по ключу "код ТФ(PID)+ФИО+дата рождения"')
adbf := {{"kod","N",7,0},{"kodh","N",7,0}}
dbcreate(cur_dir+"t_dubl",adbf)
aadd(adbf,{"kod1","N",7,0})
dbcreate(cur_dir+"t1dubl",adbf)
use (cur_dir+"t_dubl") new alias t
use (cur_dir+"t1dubl") new alias t1
Use (dir_server+"human") new alias HUMAN
index on str(kod_k,7)+str(descend(k_data),10) to (cur_dir+"tmp_human") for !empty(k_data)
Use (dir_server+"kartote_") new alias KART_
Use (dir_server+"kartotek") new alias KART
Use (dir_server+"kartote2") new alias KART2
set relation to recno() into KART_, to recno() into KART
index on str(kart2->kod_tf,10) to (cur_dir+"tmp_kart2") ;
      for kart2->kod_tf > 0 .and. !kart->(eof()) .and. kart->kod > 0
go top
do while !eof()
  if ii < 10 .or. ii % 10 == 0
    @ maxrow(),1 say lstr(ii) color cColorStMsg
  endif
  if kart2->kod_tf > old_tf
    old_tf := kart2->kod_tf ; k := 0
    select KART2
    do while old_tf == kart2->kod_tf .and. !eof()
      ++k
      skip
    enddo
    rec := recno()
    if k > 1
      arr1 := {}
      select KART2
      find (str(old_tf,10))
      do while old_tf == kart2->kod_tf .and. !eof()
        if (i := ascan(arr1,{|x| x[2]==upper(kart->fio) .and. x[3]==kart->date_r})) == 0
          aadd(arr1,{0,upper(kart->fio),kart->date_r,{}}) ; i := len(arr1)
        endif
        arr1[i,1] ++
        aadd(arr1[i,4],kart2->(recno()))
        skip
      enddo
      if len(arr1) > 1
        asort(arr1,,,{|x,y| x[1] > y[1] })
      endif
      if (k := arr1[1,1]) > 1
        ++ii ; j += k
        if (i := ascan(ak,{|x| x[1] == k})) == 0
          aadd(ak, {k,0}) ; i := len(ak)
        endif
        ak[i,2] ++
        arr := {}
        for i := 1 to len(arr1[1,4])
          select KART2
          goto (arr1[1,4,i])
          select HUMAN
          find (str(kart->kod,7))
          aadd(arr, {arr1[1,4,i],;
                     iif(found(), int(val(dtos(human->k_data))), 0),;
                     kart_->VPOLIS,;
                     kart_->vid_ud,;
                     kart_->ser_ud,;
                     iif(left(kart2->PC2,1)=="1",1,0),;
                     iif(found(), human->kod, 0)})
        next
        asort(arr,,,{|x,y| iif(x[2] == y[2],;
                               iif(x[3] == y[3],;
                                   iif(x[4] == y[4], x[5] > y[5], x[4] > y[4]),;
                                   x[3] > y[3]),;
                               x[2] > y[2]) })
        for k := 1 to len(arr)
          select KART2
          goto (arr[k,1])
          if k == 1
            select T
            append blank
            t->kod  := arr[k,1]
            t->kodh := arr[k,7]
          else // k > 1
            select T1
            append blank
            t1->kod  := t->kod
            t1->kod1 := arr[k,1]
            t1->kodh := arr[k,7]
          endif
        next
        if ii % 2000 == 0
          commit
        endif
      endif
    endif
    select KART2
    goto (rec)
    skip -1
  endif
  select KART2
  skip
enddo
j1 := t->(lastrec())
j2 := t1->(lastrec())
close databases
if j1 > 0
  Private mfio, mdate_r, mbukva, muchast, mkod_vu, mkod_AK,;
          MADRES, MMR_DOL, M1VID_UD, mser_ud, mnom_ud, M1KEMVYD, MKOGDAVYD,;
          m1vidpolis, mpolis, mspolis, mnpolis, msmo, mmesto_r, msnils,;
          m1kategor, m1kategor2, mokatog, mokatop, madresp,;
          mPHONE_H, mPHONE_M, mPHONE_W, m1okato
  Stat_Msg('Удаление дубликатов по ключу "код ТФ(PID)+ФИО+дата рождения"')
  fp := fcreate(name_file) ; n_list := 1 ; tek_stroke := 0
  add_string("Будет удалено записей в картотеке - "+lstr(j-ii))
  asort(ak,,,{|x,y| x[1] < y[1] })
  add_string(print_array(ak))
  add_string(replicate("-",102))
  f_open_files_dubl_zap(.t.) // монопольное открытие всех файлов
  E_Use(dir_server+"human",dir_server+"humankk","HUMAN") // монопольно
  use_base("kartotek",,.t.) // монопольно
  set order to 0
  use (cur_dir+"t1dubl") new alias t1
  index on str(kod,7) to (cur_dir+"t1dubl")
  use (cur_dir+"t_dubl") new alias t
  go top
  do while !eof()
    if recno() < 10 .or. recno() % 10 == 0
      @ maxrow(),0 say str(recno()/j1*100,6,2)+"%" color cColorStMsg
    endif
    ar[1] := "код |"
    ar[2] := "уч-к|"
    ar[3] := "пол.|"
    ar[4] := "пасп|"
    ar[5] := "адр.|"
    ar[6] := "прож|"
    select KART
    goto (t->kod)
    ar[1] += lstr(t->kod)
    if t->kodh > 0
      human->(dbGoto(t->kodh))
      ar[1] += "(п/л/у "+full_date(human->k_data)+")"
    endif
    ar[1] += iif(left(kart2->PC2,1)=="1"," УМЕР","")+"|"
    ar[2] += " участок "+lstr(kart->uchast)+"|"
    ar[3] += lstr(kart_->VPOLIS,1)+" "+alltrim(kart_->NPOLIS)+"|"
    ar[4] += lstr(kart_->vid_ud)+" "+alltrim(kart_->ser_ud)+" "+alltrim(kart_->nom_ud)+"|"
    ar[5] += rtrim(kart_->okatog)+" "+alltrim(kart->adres)+"|"
    ar[6] += rtrim(kart_->okatop)+" "+alltrim(kart_->adresp)+"|"
    mfio := kart->fio ; mdate_r := kart->date_r
    mokatog     := kart_->okatog       // код места жительства по ОКАТО
    mADRES      := kart->ADRES
    mokatop     := kart_->okatop       // код места пребывания по ОКАТО
    madresp     := kart_->adresp       // адрес места пребывания
    mMR_DOL     := kart->MR_DOL
    msnils      := kart->snils
    mbukva      := kart->bukva
    muchast     := kart->uchast
    mkod_vu     := kart->kod_vu
    mkod_AK     := kart2->kod_AK
    m1vidpolis  := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
    mpolis      := kart->POLIS   // полис
    mspolis     := kart_->SPOLIS // серия полиса
    mnpolis     := kart_->NPOLIS // номер полиса
    msmo        := kart_->SMO    // реестровый номер СМО
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
    m1vid_ud    := kart_->vid_ud   // вид удостоверения личности
    mser_ud     := kart_->ser_ud   // серия удостоверения личности
    mnom_ud     := kart_->nom_ud   // номер удостоверения личности
    m1kemvyd    := kart_->kemvyd   // кем выдан документ
    mkogdavyd   := kart_->kogdavyd // когда выдан документ
    m1kategor   := kart_->kategor  // категория пациента
    m1kategor2  := kart_->kategor2 // категория пациента (собственная для МО)
    mmesto_r    := kart_->mesto_r    // место рождения;;
    mPHONE_H    := kart_->PHONE_H    // телефон домашний;;
    mPHONE_M    := kart_->PHONE_M    // телефон мобильный;;
    mPHONE_W    := kart_->PHONE_W    // телефон рабочий;;
    iuch := iadres := imrab := isnils := ipolis := iud := imr := ith := itm := itw := 1
    k := 1
    select T1
    find (str(t->kod,7))
    do while t1->kod == t->kod .and. !eof()
      ++k
      select KART
      goto (t1->kod1)
      if empty(muchast) .and. !empty(kart->uchast)
        mbukva  := kart->bukva
        muchast := kart->uchast
        mkod_vu := kart->kod_vu
        iuch := k
      endif
      if empty(mkod_AK)
        mkod_AK := kart2->kod_AK
      endif
      if emptyany(mokatog,mADRES) .and. !emptyall(kart_->okatog,kart->ADRES)
        iadres := k
        mokatog := kart_->okatog       // код места жительства по ОКАТО
        mADRES  := kart->ADRES
        if emptyany(mokatop,mADRESp) .and. !emptyall(kart_->okatop,kart_->adresp)
          mokatop := kart_->okatop       // код места пребывания по ОКАТО
          madresp := kart_->adresp       // адрес места пребывания
        endif
      endif
      if empty(mMR_DOL) .and. !empty(kart->MR_DOL)
        imrab := k
        mMR_DOL := kart->MR_DOL
      endif
      if empty(msnils) .and. !empty(kart->snils)
        isnils := k
        msnils := kart->snils
      endif
      if m1vidpolis < kart_->VPOLIS
        ipolis := k
        mpolis     := kart->POLIS   // полис
        m1vidpolis := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
        mspolis    := kart_->SPOLIS // серия полиса
        mnpolis    := kart_->NPOLIS // номер полиса
        msmo       := kart_->SMO    // реестровый номер СМО
        m1okato    := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
      endif
      if m1vid_ud < kart_->vid_ud .or. ;
           (m1vid_ud == kart_->vid_ud .and. !empty(kart_->ser_ud) ;
                        .and. val_ud_ser(2,kart_->vid_ud,kart_->ser_ud) ;
                                      .and. mser_ud < kart_->ser_ud)
        iud := k
        m1vid_ud  := kart_->vid_ud   // вид удостоверения личности
        mser_ud   := kart_->ser_ud   // серия удостоверения личности
        mnom_ud   := kart_->nom_ud   // номер удостоверения личности
        m1kemvyd  := kart_->kemvyd   // кем выдан документ
        mkogdavyd := kart_->kogdavyd // когда выдан документ
      endif
      if eq_any(m1kategor,0,13) .and. !empty(kart_->kategor)
        m1kategor := kart_->kategor  // категория пациента
      endif
      if empty(m1kategor2)
        m1kategor2 := kart_->kategor2 // категория пациента (собственная для МО)
      endif
      if empty(mmesto_r) .and. !empty(kart_->mesto_r)
        imr := k
        mmesto_r := kart_->mesto_r    // место рождения;;
      endif
      if empty(mPHONE_H) .and. !empty(kart_->PHONE_H)
        ith := k
        mPHONE_H := kart_->PHONE_H    // телефон домашний;;
      endif
      if empty(mPHONE_M) .and. !empty(kart_->PHONE_M)
        itm := k
        mPHONE_M := kart_->PHONE_M    // телефон мобильный;;
      endif
      if empty(mPHONE_W) .and. !empty(kart_->PHONE_W)
        itw := k
        mPHONE_W := kart_->PHONE_W    // телефон рабочий;;
      endif
      ar[1] += lstr(t1->kod1)
      if t1->kodh > 0
        human->(dbGoto(t1->kodh))
        ar[1] += "(п/л/у "+full_date(human->k_data)+")"
      endif
      if !(upper(mfio)==upper(kart->fio).and.mdate_r==kart->date_r)
        ar[1] += " err "+fam_i_o(kart->fio)+" "+full_date(kart->date_r)
      endif
      ar[1] += iif(left(kart2->PC2,1)=="1"," УМЕР","")+"|"
      ar[2] += " участок "+lstr(kart->uchast)+"|"
      ar[3] += lstr(kart_->VPOLIS,1)+" "+alltrim(kart_->NPOLIS)+"|"
      ar[4] += lstr(kart_->vid_ud)+" "+alltrim(kart_->ser_ud)+" "+alltrim(kart_->nom_ud)+"|"
      ar[5] += rtrim(kart_->okatog)+" "+alltrim(kart->adres)+"|"
      ar[6] += rtrim(kart_->okatop)+" "+alltrim(kart_->adresp)+"|"
      f_delete_dubl_zap(t1->kod,t1->kod1,.f.) // не блокировать записи
      select T1
      skip
    enddo
    select KART
    goto (t->kod)
    add_string(padr(lstr(kart2->kod_tf)+"/"+lstr(t->(recno()))+" ("+lstr(k)+")",102,"-"))
    add_string(alltrim(kart->fio)+" "+full_date(kart->date_r))
    for k := 1 to 6
      add_string(ar[k])
    next
    add_string("уч-ок"+iif(iuch==1,":","("+lstr(iuch)+"):")+alltrim(mbukva)+lstr(muchast)+"/"+lstr(mkod_vu)+" "+mkod_AK)
    add_string("полис"+iif(ipolis==1,":","("+lstr(ipolis)+"):")+lstr(m1vidpolis)+" "+alltrim(mspolis)+" "+alltrim(mnpolis))
    add_string("удост"+iif(iud==1,":","("+lstr(iud)+"):")+lstr(m1vid_ud)+" "+alltrim(mser_ud)+" "+alltrim(mnom_ud))
    add_string("рожд."+iif(imr==1,":","("+lstr(imr)+"):")+rtrim(mmesto_r))
    add_string("адрес"+iif(iadres==1,":","("+lstr(iadres)+"):")+mokatog+" "+rtrim(mADRES)+"/"+mokatop+" "+rtrim(mADRESp))
    if !empty(mmr_dol)
      add_string("работ"+iif(imrab==1,":","("+lstr(imrab)+"):")+rtrim(mmr_dol))
    endif
    add_string("СНИЛС"+iif(isnils==1,":","("+lstr(isnils)+"):")+transform(mSNILS,picture_pf))
    s := ""
    if !empty(mPHONE_H)
      s += "тел.Д"+iif(ith==1,":","("+lstr(ith)+"):")+mPHONE_H
    endif
    if !empty(mPHONE_M)
      s += "тел.М"+iif(itm==1,":","("+lstr(itm)+"):")+mPHONE_m
    endif
    if !empty(mPHONE_W)
      s += "тел.Р"+iif(itw==1,":","("+lstr(itw)+"):")+mPHONE_w
    endif
    if !empty(s)
      add_string(s)
    endif
    //
    select KART
    goto (t->kod)
    select KART_
    do while kart_->(lastrec()) < t->kod
      APPEND BLANK
    enddo
    goto (t->kod)
    select KART2
    do while kart2->(lastrec()) < t->kod
      APPEND BLANK
    enddo
    goto (t->kod)
    //
    if !(kart_->okatog == mokatog)
      kart_->okatog := mokatog
    endif
    if !(kart->ADRES == mADRES)
      kart->ADRES := mADRES
    endif
    if !(kart_->okatop == mokatop)
      kart_->okatop := mokatop
    endif
    if !(kart_->adresp == madresp)
      kart_->adresp := madresp
    endif
    if !(kart->MR_DOL == mMR_DOL)
      kart->MR_DOL := mMR_DOL
    endif
    if !(kart->snils == msnils)
      kart->snils := msnils
    endif
    if !(kart->bukva == mbukva)
      kart->bukva := mbukva
    endif
    if kart->uchast != muchast
      kart->uchast := muchast
    endif
    if kart->kod_vu != mkod_vu
      kart->kod_vu := mkod_vu
    endif
    if !(kart2->kod_AK == mkod_AK)
      kart2->kod_AK := mkod_AK
    endif
    if kart_->VPOLIS != m1vidpolis
      kart_->VPOLIS := m1vidpolis
    endif
    if !(kart->POLIS == mpolis)
      kart->POLIS := mpolis
    endif
    if !(kart_->SPOLIS == mspolis)
      kart_->SPOLIS := mspolis
    endif
    if !(kart_->NPOLIS == mnpolis)
      kart_->NPOLIS := mnpolis
    endif
    if !(kart_->SMO == msmo)
      kart_->SMO := msmo
    endif
    if !(kart_->KVARTAL_D == m1okato)
      kart_->KVARTAL_D := m1okato
    endif
    if kart_->vid_ud != m1vid_ud
      kart_->vid_ud := m1vid_ud
    endif
    if !(kart_->ser_ud == mser_ud)
      kart_->ser_ud := mser_ud
    endif
    if !(kart_->nom_ud == mnom_ud)
      kart_->nom_ud := mnom_ud
    endif
    if kart_->kemvyd != m1kemvyd
      kart_->kemvyd := m1kemvyd
    endif
    if kart_->kogdavyd != mkogdavyd
      kart_->kogdavyd := mkogdavyd
    endif
    if kart_->kategor != m1kategor
      kart_->kategor := m1kategor
    endif
    if kart_->kategor2 != m1kategor2
      kart_->kategor2 := m1kategor2
    endif
    if !(kart_->mesto_r == mmesto_r)
      kart_->mesto_r := mmesto_r
    endif
    if !(kart_->PHONE_H == mPHONE_H)
      kart_->PHONE_H := mPHONE_H
    endif
    if !(kart_->PHONE_M == mPHONE_M)
      kart_->PHONE_M := mPHONE_M
    endif
    if !(kart_->PHONE_W == mPHONE_W)
      kart_->PHONE_W := mPHONE_W
    endif
    select T
    if recno() % 400 == 0
      @ maxrow(),7 say "rec" color "W/R"
      Commit
      @ maxrow(),7 say "   " color cColorStMsg
    endif
    skip
  enddo
  close databases
  delete file ("t1dubl"+sntx)
  fclose(fp)
endif
delete file ("t_dubl"+sdbf)
delete file ("t1dubl"+sdbf)
restscreen(buf)
return {j1,j2}

***** 11.01.19 открыть все файлы для удаления дубликатов записей в картотеке
Function f_open_files_dubl_zap(lExcluUse)
G_Use(dir_server+"mo_d01k",,"D01K",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_d01k")
// список пациентов в реестрах будущих диспансеризаций
G_Use(dir_server+"mo_dr01k",,"R01K",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_r01k")
// направления на госпитализацию
G_Use(dir_server+"mo_nnapr",,"NAPR",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_napr")
//
G_Use(dir_server+"mo_kinos",dir_server+"mo_kinos","KIS",,lExcluUse)
//
G_Use(dir_server+"mo_kismo",,"SN",,lExcluUse)
index on str(kod,7) to (cur_dir+"tmp_ismo")
// платные услуги
G_Use(dir_server+"hum_p",dir_server+"hum_pkk","HUM_P",,lExcluUse)
// ортопедия
G_Use(dir_server+"hum_ort",dir_server+"hum_ortk","HUM_O",,lExcluUse)
// приемный покой
G_Use(dir_server+"mo_pp",dir_server+"mo_pp_r","PP",,lExcluUse)
// касса платные
G_Use(dir_server+"kas_pl",dir_server+"kas_pl1","KASP",,lExcluUse)
// касса ортопедия
G_Use(dir_server+"kas_ort",dir_server+"kas_ort1","KASO",,lExcluUse)
// подобие регистра застрахованных
G_Use(dir_server+"kart_etk",,"kart_etk",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_kart_etk")
// примечания к картотеке
G_Use(dir_server+"k_prim1",dir_server+"k_prim1","K_PRIM1",,lExcluUse)
// оплата по ДМС и взаимозачету
G_Use(dir_server+"plat_vz",,"PVZ",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_pvz")
set index to (cur_dir+"tmp_pvz"),(dir_server+"plat_vz")
// регистрация печати л/у
G_Use(dir_server+"mo_regi",{dir_server+"mo_regi1",;
                            dir_server+"mo_regi2",;
                            dir_server+"mo_regi3"},"RU",,lExcluUse)
set order to 3
// МСЭК
G_Use(dir_server+"msek",dir_server+"msek","MSEK",,lExcluUse)
// cписок карточек пациентов в отосланных ходатайствах
G_Use(dir_server+"mo_hod_k",,"HK",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_hk")
// список прикреплений по пациенту во времени
G_Use(dir_server+"mo_kartp",dir_server+"mo_kartp","KARTP",,lExcluUse)
// список карточек в реестрах на прикрепление
G_Use(dir_server+"mo_krtp",,"KRTP",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_krtp")
// список ошибок в реестрах на прикрепление
G_Use(dir_server+"mo_krte",,"KRTE",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_krte")
// список карточек в файлах на открепление
G_Use(dir_server+"mo_krto",,"KRTO",,lExcluUse)
index on str(kod_k,7) to (cur_dir+"tmp_krto")
return NIL

***** 11.01.19 удалить дубликаты записей в картотеке
Function f_delete_dubl_zap(dubl1_kart,dubl2_kart,is_lock)
// dubl1_kart - Человек, которому переносится информация
// dubl2_kart - Человек, который удаляется
// is_lock    - логическая величина - блокировать ли запись
DEFAULT is_lock TO .t.
// список пациентов в реестрах будущих диспансеризаций
select D01K
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  d01k->kod_k := dubl1_kart
enddo
select R01K
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  r01k->kod_k := dubl1_kart
enddo
// направления на госпитализацию
select NAPR
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  napr->kod_k := dubl1_kart
enddo
select HUMAN
// должен уже стоять на индексе (dir_server+"humankk")
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  human->kod_k := dubl1_kart
enddo
select KIS
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  DeleteRec(.t.,,is_lock)
enddo
select SN
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  DeleteRec(.t.,,is_lock)
enddo
select HUM_P
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  hum_p->kod_k := dubl1_kart
enddo
select HUM_O
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  hum_o->kod_k := dubl1_kart
enddo
select PP
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  pp->kod_k := dubl1_kart
enddo
select KASP
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  kasp->kod_k := dubl1_kart
enddo
select KASO
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  kaso->kod_k := dubl1_kart
enddo
select kart_etk
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  DeleteRec(.t.,,is_lock)
enddo
select K_PRIM1
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  DeleteRec(.t.,,is_lock)
enddo
select PVZ
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  pvz->kod_k := dubl1_kart
enddo
select RU
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  ru->kod_k := dubl1_kart
enddo
select MSEK
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  msek->kod_k := dubl1_kart
enddo
select HK
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  hk->kod_k := dubl1_kart
enddo
select KARTP
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  kartp->kod_k := dubl1_kart
enddo
select KRTP
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  krtp->kod_k := dubl1_kart
enddo
select KRTE
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  krte->kod_k := dubl1_kart
enddo
select KRTO
do while .t.
  find (str(dubl2_kart,7))
  if !found() ; exit ; endif
  if is_lock
    G_RLock(forever)
  endif
  krto->kod_k := dubl1_kart
enddo
// картотека
select KART
set order to 0
goto (dubl2_kart)
// т.к. relation
select KART2
goto (dubl2_kart)
if !eof()
  DeleteRec(.t.,.f.,is_lock)  // очистка записи без пометки на удаление
endif
select KART_
goto (dubl2_kart)
if !eof()
  DeleteRec(.t.,.f.,is_lock)  // очистка записи без пометки на удаление
endif
select KART
goto (dubl2_kart)
DeleteRec(.t.,.f.,is_lock)  // очистка записи без пометки на удаление
if is_lock
  dbUnLockAll()
endif
return NIL

***** 14.09.16 поправить номер полиса из реестров СПТК
Function correct_polis_from_sptk()
Local ii := 0, jj := 0, fl, buf := save_maxrow()
stat_msg("Поиск/попытка исправления полисов в картотеке")
Use (dir_server+"human_") new
use (dir_server+"human") new
set relation to recno() into HUMAN_
Private mdate := stod("20190630")
index on str(kod_k,7)+str(descend(k_data),10) to (cur_dir+"tmp_human") for k_data > mdate
use_base("kartotek",,.t.) // открываем в монопольном режиме
set order to 2
find ("1")
do while kart->kod > 0 .and. !eof()
  if ++ii % 500 == 0
    @ maxrow(),0 say str(ii/lastrec()*100,6,2)+"%" color cColorStMsg
  endif
  select HUMAN
  find (str(kart->kod,7))
  do while human->kod_k == kart->kod .and. !eof()
    if !empty(k_data) .and. kod > 0 .and. ;
       between(human_->VPOLIS,1,3) .and. schet > 0 .and. ; // в счете
       human_->REESTR > 0 .and. between(human_->smo,'34001','34007')
      fl := .f.
      if human_->VPOLIS == kart_->VPOLIS
        fl := !(kart_->NPOLIS == human_->NPOLIS)
      elseif human_->VPOLIS > kart_->VPOLIS
        fl := .t.
      endif
      if fl
        /*my_debug(,str(kart->kod,7)+" "+rtrim(kart->fio)+" "+full_date(kart->date_r)+"/"+date_8(human->k_data))
        my_debug(,space(7)+lstr(kart_->VPOLIS)+"/"+alltrim(kart_->SPOLIS)+"/"+alltrim(kart_->NPOLIS)+;
                 " => "+lstr(human_->VPOLIS)+"/"+alltrim(human_->SPOLIS)+"/"+alltrim(human_->NPOLIS))*/
        kart->POLIS   := make_polis(human_->spolis,human_->npolis)
        kart_->VPOLIS := human_->VPOLIS
        kart_->SPOLIS := human_->SPOLIS
        kart_->NPOLIS := human_->NPOLIS
        if ++jj % 2000 == 0
          commit
        endif
      endif
      exit
    endif
    select HUMAN
    skip
  enddo
  select KART
  skip
enddo
close databases
rest_box(buf)
return NIL

***** 23.08.17
Function pereindex_263()
Local n, pole, buf := save_maxrow()
stat_msg("Поиск/попытка исправления избыточных ошибок в направлениях на госпитализацию")
G_Use(dir_server+"mo_nnapr",,"NAPR")
G_Use(dir_server+"mo_nfina",,"NFN")
index on str(KOD_F,6)+str(KOD_N,6) to (cur_dir+"tmp_nfn")
G_Use(dir_server+"mo_nfile",,"NF")
index on kod to (cur_dir+"tmp_nf") for in_out == 1 .and. tip_f < 7 .and. year(date_r) > 2016
go top
do while !eof()
  if nf->T_ANS == 2 // в файле были ошибки
    if (n := nf->tip_f) == 5
      n := 4
    endif
    pole := "napr->t_ans_"+lstr(n)
    select NFN
    find (str(nf->kod,6))
    do while nf->kod == nfn->kod_f .and. !eof()
      if nfn->OSHIB == 0
        select NAPR
        goto (nfn->kod_n)
        if &pole == 2 // если занесена ошибка
          G_RLock(forever)
          &pole := 1 // убираем ошибку
          dbUnLock()
        endif
      endif
      select NFN
      skip
    enddo
  endif
  select NF
  skip
enddo
close databases
rest_box(buf)
return NIL

***** 29.11.17
Function pereindex_KEK()
Local i, hGauge, ae[3], k, ab, ar
if !(type("mem_ocen_kek") == "N")
  Public mem_ocen_kek := 0
endif
ar := GetIniSect(tools_ini,"КЭК")
mem_ocen_kek := int(val(a2default(ar,"ocen_kek","0")))
Private is_2017, p_ar := array(70)
//
hGauge := GaugeNew(,,,"Пересчет процента заполнения экспертиз",.t.)
GaugeDisplay( hGauge )
Use (dir_server+"mo_kekez") index (dir_server+"mo_kekez") new alias EKSZ
Use (dir_server+"mo_keke") index (dir_server+"mo_keket") new alias EKS
Use (dir_server+"mo_kekh") new alias HU
go top
do while !eof()
  GaugeUpdate( hGauge, recno()/lastrec() )
  is_2017 := (year(hu->K_DATA) > 2016)
  afill(ae," ")
  select EKS
  find (str(hu->(recno()),7))
  do while eks->kod == hu->(recno()) .and. !eof()
    if between(eks->TIP_EKS,1,3)
      ae[eks->TIP_EKS] := lstr(eks->TIP_EKS)
    endif
    if is_2017
      eks->EO_28 := kek_ret_s_70()
    endif
    ab := f_ball_kek(hu->ishod)
    k := 0
    select EKSZ
    find (str(eks->(recno()),7))
    dbeval({|| ++k},,{|| eksz->kod == eks->(recno()) })
    eks->N_ZAKLUCH := k
    eks->p_zapol := f_p_zapol_kek(hu->ISHOD,is_2017)
    eks->O_A     := ab[1,1]
    eks->O_B     := ab[1,2]
    eks->O_C     := ab[1,3]
    eks->O_D     := ab[1,4]
    eks->O_K     := ab[1,5]
    eks->O_P     := ab[1,6]
    eks->O_R     := ab[1,7]
    eks->O_E     := ab[1,8]
    eks->O_ALL   := ab[1,9]
    select EKS
    skip
  enddo
  select HU
  hu->KOL_EKS := ae[1]+ae[2]+ae[3]
  skip
enddo
close databases
CloseGauge(hGauge)
return NIL

***** 23.08.17 функция переиндексирования для одной задачи
Function pereindex_task(n_task)
Local buf := savescreen()
DEFAULT n_Task TO glob_task
if mo_Lock_Task(n_Task) .and. f_Esc_Enter("переиндексирования")
  f_message({"Ждите! Пpоизводится пеpеиндексирование сегмента базы данных",;
             'для подзадачи "'+array_tasks[ind_task(n_Task),1]+'"',;
             "Ни в коем случае не прерывайте процесс",;
             "во избежание нежелательных последствий!"},,"GR+/R","W+/R",13)
  Private fl_open := .t.
  if !emptyany(array_task_DB[n_Task,1],array_task_DB[n_Task,2])
    for i := array_task_DB[n_Task,1] to array_task_DB[n_Task,2]
      index_base(array_files_DB[i])
    next
  endif
  if n_Task == X_263
    pereindex_263()
  elseif n_Task == X_KEK
    pereindex_KEK()
  endif
  // разрешение доступа всем к данной задаче
  mo_UnLock_Task(n_Task)
  keyboard ""
  restscreen(buf)
  stat_msg("Переиндексирование части базы данных завершено!") ; mybell(2,OK)
endif
restscreen(buf)
return NIL


***** 10.01.19 инициализировать массив DBF-файлов базы данных
Function init_array_files_DB()
Local i, arr
Public array_files_DB := {}, array_task_DB[24,2]
afillall(array_task_DB,0)
// общие справочники
aadd(array_files_DB,"base1")
aadd(array_files_DB,"ver_base")
aadd(array_files_DB,"organiz")
aadd(array_files_DB,"mo_oper")
aadd(array_files_DB,"mo_opern")
aadd(array_files_DB,"s_adres")
aadd(array_files_DB,"s_kemvyd")
aadd(array_files_DB,"s_mr")
aadd(array_files_DB,"mo_kfio")
aadd(array_files_DB,"mo_kismo")
aadd(array_files_DB,"mo_hismo")
aadd(array_files_DB,"mo_stdds")
aadd(array_files_DB,"mo_schoo")
aadd(array_files_DB,"str_komp")
aadd(array_files_DB,"komitet")
aadd(array_files_DB,"slugba")
aadd(array_files_DB,"mo_su")
aadd(array_files_DB,"uslugi")
aadd(array_files_DB,"uslugi1")
aadd(array_files_DB,"uch_usl")
aadd(array_files_DB,"uch_usl1")
aadd(array_files_DB,"uch_pers")
aadd(array_files_DB,"uslugi_k")
aadd(array_files_DB,"uslugi1k")
aadd(array_files_DB,"ns_usl")
aadd(array_files_DB,"ns_usl_k")
aadd(array_files_DB,"usl_uva")
aadd(array_files_DB,"usl_otd")
aadd(array_files_DB,"u_usl_5")
aadd(array_files_DB,"u_usl_7")
aadd(array_files_DB,"mo_flis")
// стоматология
aadd(array_files_DB,"kart_st")
aadd(array_files_DB,"humanst")
// картотека
aadd(array_files_DB,"kartotek")
aadd(array_files_DB,"kartote_")
aadd(array_files_DB,"kartote2")
aadd(array_files_DB,"kart_et")
aadd(array_files_DB,"kart_inv")
aadd(array_files_DB,"kart_etk")
aadd(array_files_DB,"mo_kartp")
aadd(array_files_DB,"mo_krtp")
aadd(array_files_DB,"mo_krte")
aadd(array_files_DB,"mo_krtr")
aadd(array_files_DB,"mo_krto")
aadd(array_files_DB,"mo_krtf")
aadd(array_files_DB,"k_prim1")
aadd(array_files_DB,"mo_regi")
aadd(array_files_DB,"mo_kpred")
aadd(array_files_DB,"mo_kinos")
aadd(array_files_DB,"mo_dr00")
aadd(array_files_DB,"mo_dr01")
aadd(array_files_DB,"mo_dr01k")
aadd(array_files_DB,"mo_dr01m")
aadd(array_files_DB,"mo_dr01e")
aadd(array_files_DB,"mo_dr05")
aadd(array_files_DB,"mo_dr05k")
aadd(array_files_DB,"mo_dr05p")
aadd(array_files_DB,"mo_dr05e")
aadd(array_files_DB,"mo_d01")
aadd(array_files_DB,"mo_d01k")
aadd(array_files_DB,"mo_d01d")
aadd(array_files_DB,"mo_d01e")
aadd(array_files_DB,"mo_dnab")
aadd(array_files_DB,"msek")
aadd(array_files_DB,"p_priem")
// листы учёта ОМС
aadd(array_files_DB,"human")   ; array_task_DB[X_OMS,1] := len(array_files_DB)
aadd(array_files_DB,"human_")
aadd(array_files_DB,"human_2")
aadd(array_files_DB,"human_3")
aadd(array_files_DB,"kartdelz")
aadd(array_files_DB,"mo_sprav")
aadd(array_files_DB,"mo_rhum")
aadd(array_files_DB,"mo_refr")
aadd(array_files_DB,"mo_os")
aadd(array_files_DB,"mo_hu")
aadd(array_files_DB,"human_u")
aadd(array_files_DB,"human_u_")
aadd(array_files_DB,"mo_hdisp")
aadd(array_files_DB,"mo_hod")
aadd(array_files_DB,"mo_hod_k")
aadd(array_files_DB,"mo_rak")
aadd(array_files_DB,"mo_rakexp")
aadd(array_files_DB,"mo_raks")
aadd(array_files_DB,"mo_raksh")
aadd(array_files_DB,"mo_raksherr")
aadd(array_files_DB,"mo_rpd")
aadd(array_files_DB,"mo_rpds")
aadd(array_files_DB,"mo_rpdsh")
aadd(array_files_DB,"mo_onkna")
aadd(array_files_DB,"mo_onksl")
aadd(array_files_DB,"mo_onkdi")
aadd(array_files_DB,"mo_onkpr")
aadd(array_files_DB,"mo_onkus")
aadd(array_files_DB,"mo_onkco")
aadd(array_files_DB,"mo_onkle")
// реестры и счета
aadd(array_files_DB,"mo_rees")
aadd(array_files_DB,"mo_xml")
aadd(array_files_DB,"schet")
aadd(array_files_DB,"schet_")
aadd(array_files_DB,"schetd")  ; array_task_DB[X_OMS,2] := len(array_files_DB)
// структура организации
aadd(array_files_DB,"mo_uch")
aadd(array_files_DB,"mo_otd")
aadd(array_files_DB,"mo_uchvr")
aadd(array_files_DB,"mo_pers")
// приёмный покой
aadd(array_files_DB,"mo_ppst") ; array_task_DB[X_PPOKOJ,1] := len(array_files_DB)
aadd(array_files_DB,"mo_pp")
aadd(array_files_DB,"mo_ppdia")
aadd(array_files_DB,"mo_ppper")
aadd(array_files_DB,"mo_ppadd"); array_task_DB[X_PPOKOJ,2] := len(array_files_DB)
// платные услуги
aadd(array_files_DB,"hum_p")   ; array_task_DB[X_PLATN,1] := len(array_files_DB)
aadd(array_files_DB,"hum_p_u")
aadd(array_files_DB,"plat_ms")
aadd(array_files_DB,"plat_vz")
aadd(array_files_DB,"hum_plat")
aadd(array_files_DB,"payments")
aadd(array_files_DB,"payer")
aadd(array_files_DB,"pu_cena")
aadd(array_files_DB,"pu_date")
aadd(array_files_DB,"p_pr_vz")
aadd(array_files_DB,"p_d_smo") ; array_task_DB[X_PLATN,2] := len(array_files_DB)
// ортопедия
aadd(array_files_DB,"ortoped") ; array_task_DB[X_ORTO,1] := len(array_files_DB)
aadd(array_files_DB,"ortoped1")
aadd(array_files_DB,"ortoped2")
aadd(array_files_DB,"diag_ort")
aadd(array_files_DB,"ort_brk")
aadd(array_files_DB,"orto_uva")
aadd(array_files_DB,"hum_ort")
aadd(array_files_DB,"hum_oro")
aadd(array_files_DB,"hum_oru")
aadd(array_files_DB,"hum_orpl")
aadd(array_files_DB,"tip_orto"); array_task_DB[X_ORTO,2] := len(array_files_DB)
// касса ЛПУ
aadd(array_files_DB,"kas_pl")  ; array_task_DB[X_KASSA,1] := len(array_files_DB)
aadd(array_files_DB,"kas_pl_u")
aadd(array_files_DB,"kas_ort")
aadd(array_files_DB,"kas_ortu")
aadd(array_files_DB,"kas_usl")
aadd(array_files_DB,"kas_usld"); array_task_DB[X_KASSA,2] := len(array_files_DB)
// КЭК
aadd(array_files_DB,"mo_kekh") ; array_task_DB[X_KEK,1] := len(array_files_DB)
aadd(array_files_DB,"mo_keke")
aadd(array_files_DB,"mo_kekez"); array_task_DB[X_KEK,2] := len(array_files_DB)
// госпитализация
aadd(array_files_DB,"mo_nfile"); array_task_DB[X_263,1] := len(array_files_DB)
aadd(array_files_DB,"mo_nfina")
aadd(array_files_DB,"mo_nnapr")
aadd(array_files_DB,"mo_n7d")
aadd(array_files_DB,"mo_n7in")
aadd(array_files_DB,"mo_n7out"); array_task_DB[X_263,2] := len(array_files_DB)
//
arr := my_mo_init_array_files_DB()
for i := 1 to len(arr)
  aadd(array_files_DB,arr[i])
next
return NIL

***** 03.12.16 специально для ЦРБ Городищенского р-на
Function ___uslugi()
Local adbf, buf := save_maxrow()
if .t. //!(glob_mo[_MO_KOD_TFOMS] == '321001')
  return NIL
endif
//
E_Use(dir_server+"uslugi",,"USL")
/*if lastrec() < 8000
  close databases
  return NIL
endif*/
mywait()
//
E_Use(dir_server+"human_u",{dir_server+"human_u",;
                            dir_server+"human_uk",;
                            dir_server+"human_ud",;
                            dir_server+"human_uv",;
                            dir_server+"human_ua"},"HU")
//index on str(u_kod,4) to (dir_server+"human_uk") progress
set order to 2
//
E_Use(dir_server+"hum_p_u",{dir_server+"hum_p_u",;
                            dir_server+"hum_p_uk",;
                            dir_server+"hum_p_ud",;
                            dir_server+"hum_p_uv",;
                            dir_server+"hum_p_ua"},"HPU")
//index on str(u_kod,4) to (dir_server+"hum_p_uk") progress
set order to 2
//
E_Use(dir_server+"pu_cena",{dir_server+"pu_cena",;
                            dir_server+"pu_cenau"},"PUC")
//index on str(kod_usl,4)+str(kod_date,4) to (dir_server+"pu_cenau") progress
set order to 2
//
E_Use(dir_server+"hum_oru",{dir_server+"hum_oru",;
                            dir_server+"hum_oruk",;
                            dir_server+"hum_orud",;
                            dir_server+"hum_oruv",;
                            dir_server+"hum_orua"},"HOU")
//index on str(u_kod,4) to (dir_server+"hum_oruk") progress
set order to 2
//
E_Use(dir_server+"kas_pl_u",{dir_server+"kas_pl1u",;
                             dir_server+"kas_pl2u"},"KPU")
//index on str(u_kod,4) to (dir_server+"kas_pl2u") progress
set order to 2
//
E_Use(dir_server+"kas_ortu",{dir_server+"kas_or1u",;
                             dir_server+"kas_or2u"},"KOU")
//index on str(u_kod,4) to (dir_server+"kas_or2u") progress
set order to 2
//
E_Use(dir_server+"kas_usl",,"KUU")
index on str(u_kod,4) to (cur_dir+"tmp_kuu")
//
E_Use(dir_server+"kas_usld",,"KUUD")
index on str(u_kod,4) to (cur_dir+"tmp_kuud")
//
E_Use(dir_server+"uslugi1",{dir_server+"uslugi1",;
                            dir_server+"uslugi1s"},"USL1")
//index on str(kod,4)+dtos(date_b) to (dir_server+"uslugi1") progress
//
E_Use(dir_server+"uch_usl",dir_server+"uch_usl","UCH_USL")
//index on str(kod,4) to (dir_server+"uch_usl") progress
//
E_Use(dir_server+"uch_usl1",dir_server+"uch_usl1","UCH_USL1")
//index on str(kod,4)+dtos(date_b) to (dir_server+"uch_usl1") progress
//
if (flag_udel := hb_fileExists(dir_server+"usl_del"+sdbf))
  E_Use(dir_server+"usl_del",,"UDEL")
  index on str(kod,4) to (cur_dir+"tmp_udel")
endif
//
E_Use(dir_server+"usl_otd",dir_server+"usl_otd","UOTD")
//index on str(kod,4) to (dir_server+"usl_otd") progress
//
adbf := {;
   {"kod",     "N", 4,0},;
   {"kod_tmp", "N", 4,0},;
   {"kol",     "N", 6,0},;
   {"shifr",   "C",10,0},;
   {"cena",    "N",10,2},;
   {"cena_d",  "N",10,2};
  }
dbcreate(cur_dir+"tmp",adbf)
use (cur_dir+"tmp") new
index on shifr+str(cena,10,2)+str(cena_d,10,2) to (cur_dir+"tmp")
dbcreate(cur_dir+"tmp1",adbf)
use (cur_dir+"tmp1") new
hGauge := GaugeNew(,,,"Поиск дубликатов услуг",.t.)
GaugeDisplay( hGauge )
SET DELETED OFF
select USL
go top
do while recno() < 10000 .and. !eof()
  @ maxrow(),0 say padr(str(recno()/lastrec()*100,7,2)+"%",80) color cColorStMsg
  GaugeUpdate( hGauge, recno()/lastrec() )
  //
  if deleted()
    RECALL
  endif
  if usl->kod > 0 .and. alltrim(usl->shifr)=="8.1.5" .and. !usl->is_nulp .and. ;
     emptyall(usl->shifr1,usl->pcena,usl->pcena_d,usl->dms_cena,usl->pnds,usl->pnds_d)
    select USL1
    find (str(usl->kod,4))
    if !found() // нет поля "шифр ТФОМС"
      select TMP
      find (usl->shifr+str(usl->cena,10,2)+str(usl->cena_d,10,2))
      if !found()
        append blank
        tmp->shifr  := usl->shifr
        tmp->cena   := usl->cena
        tmp->cena_d := usl->cena_d
      endif
      tmp->kol ++
      select TMP1
      append blank
      tmp1->kod := usl->kod
      tmp1->kod_tmp := tmp->(recno())
    endif
  endif
  select USL
  skip
enddo
commit
CloseGauge(hGauge)
select TMP
if lastrec() > 0
  index on str(kol,6) to (cur_dir+"tmp")
  go bottom
  if tmp->kol > 10
    i := 0
    select TMP1
    index on str(kod,4) to (cur_dir+"tmp1") for tmp1->kod_tmp == tmp->(recno())
    go top
    lkod_usl := tmp1->kod // первая запись
    do while !eof()
      if lkod_usl != tmp1->kod // пропускаем первую запись
        @ maxrow(),0 say padr(str(++i)+" - удалено дубликатов услуг",80) color cColorStMsg
        select HU
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          hu->u_kod := lkod_usl
        enddo
        select HPU
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          hpu->u_kod := lkod_usl
        enddo
        select PUC
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          puc->kod_usl := lkod_usl
        enddo
        select HOU
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          hou->u_kod := lkod_usl
        enddo
        select KPU
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          kpu->u_kod := lkod_usl
        enddo
        select KOU
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          kou->u_kod := lkod_usl
        enddo
        select KUU
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          kuu->u_kod := lkod_usl
        enddo
        select KUUD
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          kuud->u_kod := lkod_usl
        enddo
        select USL1
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          usl1->kod := lkod_usl
        enddo
        select UCH_USL
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          uch_usl->kod := lkod_usl
        enddo
        select UCH_USL1
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          uch_usl1->kod := lkod_usl
        enddo
        if flag_udel
          select UDEL
          do while .t.
            find (str(tmp1->kod,4))
            if !found() ; exit ; endif
            udel->kod := lkod_usl
          enddo
        endif
        select UOTD
        do while .t.
          find (str(tmp1->kod,4))
          if !found() ; exit ; endif
          uotd->kod := lkod_usl
        enddo
        select USL
        goto (tmp1->kod)
        replace usl->kod with -1, ;
                usl->slugba with -1, ;
                usl->name with "", ;
                usl->shifr with "", usl->shifr1 with ""
        if i % 100 == 0
          Commit
        endif
      endif
      select TMP1
      skip
    enddo
    close databases
    use (dir_server+"uslugi") new alias USL
    go bottom
    do while !bof()
      if recno() > 9999 .or. usl->kod == -1
        Delete
      else
        exit
      endif
      skip -1
    enddo
    pack
    index_base("uslugi")
  endif
endif
close databases
SET DELETED ON
rest_box(buf)
return NIL
