// mo_index.prg - модуль переиндексирования
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// запуск режима переиндексирования из меню
Function m_index_db()

  Local t2 := 0

  If g_slock1task( sem_task, sem_vagno )  // запрет доступа всем
    If f_esc_enter( "переиндексирования" )
      t2 := pereindex()
      ___uslugi()
    Endif
    // разрешение доступа всем
    g_sunlock( sem_vagno )
    Keyboard ""
    If t2 > 0
      n_message( { "", "Время переиндексирования - " + SecToTime( t2 ) },, ;
        color1, cDataCSay,,, color8 )
    Endif
  Else
    func_error( 4, "В данный момент работают другие задачи. Переиндексирование запрещено!" )
  Endif

  Return Nil

// 31.07.24 внутренняя функция переиндексирования
Function pereindex()

  Local buf := SaveScreen(), t1, t2, i, hGauge, ae[ 3 ], k, ab

  f_message( { "Внимание! Пpоизводится пеpеиндексирование базы данных.", ;
    "", ;
    "Во избежание разрушения данных", ;
    "не прерывайте процесс!" },, "GR+/R", "W+/R", 13 )

  t1 := Seconds()
  Private fl_open := .t.
  For i := 1 To Len( array_files_DB )
    index_base( array_files_DB[ i ] )
  Next
  //
  Use ( dir_server + "mo_ppadd" ) new
  Pack
  Use
  //
  pereindex_263()
//  If is_task( X_KEK )
//    pereindex_kek()
//  Endif
  //
  stat_msg( 'Поиск и копирование ЕНП' )
  use_base( "kartotek",, .t. ) // открыть в монопольном режиме
  Set Index To
  Go Top
  Do While !Eof()
    If kart->kod > 0
      @ MaxRow(), 1 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + "%" Color cColorStMsg
      Select KART2
      Goto ( kart->( RecNo() ) )
      If !Empty( kart2->kod_mis ) .and. !( kart->kod_mis == kart2->kod_mis )
        kart->kod_mis := kart2->kod_mis
      Endif
    Endif
    Select KART
    If RecNo() % 5000 == 0
      Commit
    Endif
    Skip
  Enddo
  Index On if( kod > 0, "1", "0" ) + kod_mis to ( dir_server + "kartotee" ) progress
  Close databases
  //
  mywait()
  Use ( dir_server + "mo_raksh" ) New Alias RAKSH
  Index On Str( kod_raks, 6 ) to ( cur_dir + "tmpraksh" )
  Use ( dir_server + "mo_raks" ) New Alias RAKS
  Index On Str( akt, 6 ) to ( cur_dir + "tmpraks" )
  Use ( dir_server + "mo_rak" ) New Alias RAK
  Index On Str( akt, 6 ) to ( cur_dir + "tmprak" )
  Use ( dir_server + "mo_xml" ) New Alias MO_XML
  Locate For kod == 0 .and. !Deleted()
  If Found()
    Delete // если прервали процесс
  Endif
  //
  Select RAK
  find ( Str( 0, 6 ) )
  Do While rak->akt == 0 .and. !Eof()
    If !Deleted() // если прервали процесс
      Do While .t.
        Select RAKS
        find ( Str( rak->( RecNo() ), 6 ) )
        If !Found()
          Exit
        Endif
        Do While .t.
          Select RAKSH
          find ( Str( raks->KOD_RAKS, 6 ) )
          If !Found()
            Exit
          Endif
          deleterec( .t. )
        Enddo
        Select RAKS
        deleterec( .t. )
      Enddo
      Select RAK
      deleterec( .t. )
    Endif
    Select RAK
    Skip
  Enddo
  //
  Select RAKS
  find ( Str( 0, 6 ) )
  Do While raks->akt == 0 .and. !Eof()
    If raks->KOD_RAKS == 0 .and. !Deleted() // если прервали процесс
      Do While .t.
        Select RAKSH
        find ( Str( raks->( RecNo() ), 6 ) )
        If !Found()
          Exit
        Endif
        deleterec( .t. )
      Enddo
      Select RAKS
      deleterec( .t. )
    Endif
    Select RAKS
    Skip
  Enddo
  //
  Select RAKSH
  find ( Str( 0, 6 ) )
  Do While raksh->kod_raks == 0 .and. !Eof()
    If !Deleted() // если не помечена на удаление
      Delete
    Endif
    Skip
  Enddo
  //
  Select RAKSH
  Pack // упаковка файла нижнего уровня
  Close databases
  Use ( dir_server + "mo_rpdsh" ) new
  Pack // упаковка файла нижнего уровня
  Close databases
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
      if Extract_Zip_XML(dir_server+dir_XML_TF(),cFile+szip) != NIL
        oXmlDoc := HXMLDoc():Read(_tmp_dir1()+cFile+sxml)
        reestr_rak_tmpfile(oXmlDoc,{},_tmp_dir1()+cFile+szip)
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

  Use ( dir_server + "mo_nnapr" ) New Alias NAPR
  Go Top
  Do While !Eof()
    If !Empty( napr->num_d ) .and. !Between( napr->USL_OK_1, 1, 2 )
      napr->USL_OK_1 := 1
    Endif
    If napr->TYPE_H_4 > 0 .and. !Between( napr->USL_OK_4, 1, 2 )
      napr->USL_OK_4 := 1
    Endif
    Skip
  Enddo
  Use ( dir_server + "mo_n7in" ) New Alias N7i
  Go Top
  Do While !Eof()
    If !Between( n7i->USL_OK, 1, 2 )
      n7i->USL_OK := 1
    Endif
    Skip
  Enddo
  Use ( dir_server + "mo_n7out" ) New Alias N7
  Go Top
  Do While !Eof()
    If !Between( n7->USL_OK, 1, 2 )
      n7->USL_OK := 1
    Endif
    Skip
  Enddo
  Close databases
  // Use ( dir_server + "mo_kekh" ) New Alias HU
  // Go Top
  // Do While !Eof()
  //   If !Between( hu->USL_OK, 1, 3 )
  //     hu->USL_OK := 1
  //   Endif
  //   Skip
  // Enddo
  // Close databases
  //
  stat_msg( "Пеpеиндексирование завеpшено!" )
  t2 := Seconds() - t1
  RestScreen( buf )

  Return t2


// 23.08.17
Function pereindex_263()

  Local n, pole, buf := save_maxrow()

  stat_msg( "Поиск/попытка исправления избыточных ошибок в направлениях на госпитализацию" )
  g_use( dir_server + "mo_nnapr",, "NAPR" )
  g_use( dir_server + "mo_nfina",, "NFN" )
  Index On Str( KOD_F, 6 ) + Str( KOD_N, 6 ) to ( cur_dir + "tmp_nfn" )
  g_use( dir_server + "mo_nfile",, "NF" )
  Index On kod to ( cur_dir + "tmp_nf" ) For in_out == 1 .and. tip_f < 7 .and. Year( date_r ) > 2016
  Go Top
  Do While !Eof()
    If nf->T_ANS == 2 // в файле были ошибки
      If ( n := nf->tip_f ) == 5
        n := 4
      Endif
      pole := "napr->t_ans_" + lstr( n )
      Select NFN
      find ( Str( nf->kod, 6 ) )
      Do While nf->kod == nfn->kod_f .and. !Eof()
        If nfn->OSHIB == 0
          Select NAPR
          Goto ( nfn->kod_n )
          if &pole == 2 // если занесена ошибка
            g_rlock( forever )
            &pole := 1 // убираем ошибку
            dbUnlock()
          Endif
        Endif
        Select NFN
        Skip
      Enddo
    Endif
    Select NF
    Skip
  Enddo
  Close databases
  rest_box( buf )

  Return Nil

// 11.07.24 функция переиндексирования для одной задачи
Function pereindex_task( n_task )

  Local buf := SaveScreen()

  Default n_Task To glob_task
  If mo_lock_task( n_Task ) .and. f_esc_enter( "переиндексирования" )
    f_message( { 'Внимание! Пpоизводится пеpеиндексирование сегмента базы данных', ;
      'для подзадачи "' + array_tasks[ ind_task( n_Task ), 1 ] + '"', ;
      '', ;
      'Во избежание разрушения данных не прерывайте процесс!' },, 'GR+/R', 'W+/R', 13 )
    Private fl_open := .t.
    If !emptyany( array_task_DB[ n_Task, 1 ], array_task_DB[ n_Task, 2 ] )
      For i := array_task_DB[ n_Task, 1 ] To array_task_DB[ n_Task, 2 ]
        index_base( array_files_DB[ i ] )
      Next
    Endif
    If n_Task == X_263
      pereindex_263()
//    Elseif n_Task == X_KEK
//      pereindex_kek()
    Endif
    // разрешение доступа всем к данной задаче
    mo_unlock_task( n_Task )
    Keyboard ""
    RestScreen( buf )
    stat_msg( "Переиндексирование части базы данных завершено!" ) ; mybell( 2, OK )
  Endif
  RestScreen( buf )

  Return Nil


// 03.12.16 специально для ЦРБ Городищенского р-на
Function ___uslugi()

  Local adbf, buf := save_maxrow()

  If .t. // !(glob_mo[_MO_KOD_TFOMS] == '321001')
    Return Nil
  Endif
  //
  e_use( dir_server + "uslugi",, "USL" )
/*if lastrec() < 8000
  close databases
  return NIL
endif*/
  mywait()
  //
  e_use( dir_server + "human_u", { dir_server + "human_u", ;
    dir_server + "human_uk", ;
    dir_server + "human_ud", ;
    dir_server + "human_uv", ;
    dir_server + "human_ua" }, "HU" )
  // index on str(u_kod,4) to (dir_server+"human_uk") progress
  Set Order To 2
  //
  e_use( dir_server + "hum_p_u", { dir_server + "hum_p_u", ;
    dir_server + "hum_p_uk", ;
    dir_server + "hum_p_ud", ;
    dir_server + "hum_p_uv", ;
    dir_server + "hum_p_ua" }, "HPU" )
  // index on str(u_kod,4) to (dir_server+"hum_p_uk") progress
  Set Order To 2
  //
  e_use( dir_server + "pu_cena", { dir_server + "pu_cena", ;
    dir_server + "pu_cenau" }, "PUC" )
  // index on str(kod_usl,4)+str(kod_date,4) to (dir_server+"pu_cenau") progress
  Set Order To 2
  //
  e_use( dir_server + "hum_oru", { dir_server + "hum_oru", ;
    dir_server + "hum_oruk", ;
    dir_server + "hum_orud", ;
    dir_server + "hum_oruv", ;
    dir_server + "hum_orua" }, "HOU" )
  // index on str(u_kod,4) to (dir_server+"hum_oruk") progress
  Set Order To 2
  //
  e_use( dir_server + "kas_pl_u", { dir_server + "kas_pl1u", ;
    dir_server + "kas_pl2u" }, "KPU" )
  // index on str(u_kod,4) to (dir_server+"kas_pl2u") progress
  Set Order To 2
  //
  e_use( dir_server + "kas_ortu", { dir_server + "kas_or1u", ;
    dir_server + "kas_or2u" }, "KOU" )
  // index on str(u_kod,4) to (dir_server+"kas_or2u") progress
  Set Order To 2
  //
  e_use( dir_server + "kas_usl",, "KUU" )
  Index On Str( u_kod, 4 ) to ( cur_dir + "tmp_kuu" )
  //
  e_use( dir_server + "kas_usld",, "KUUD" )
  Index On Str( u_kod, 4 ) to ( cur_dir + "tmp_kuud" )
  //
  e_use( dir_server + "uslugi1", { dir_server + "uslugi1", ;
    dir_server + "uslugi1s" }, "USL1" )
  // index on str(kod,4)+dtos(date_b) to (dir_server+"uslugi1") progress
  //
  e_use( dir_server + "uch_usl", dir_server + "uch_usl", "UCH_USL" )
  // index on str(kod,4) to (dir_server+"uch_usl") progress
  //
  e_use( dir_server + "uch_usl1", dir_server + "uch_usl1", "UCH_USL1" )
  // index on str(kod,4)+dtos(date_b) to (dir_server+"uch_usl1") progress
  //
  If ( flag_udel := hb_FileExists( dir_server + "usl_del" + sdbf ) )
    e_use( dir_server + "usl_del",, "UDEL" )
    Index On Str( kod, 4 ) to ( cur_dir + "tmp_udel" )
  Endif
  //
  e_use( dir_server + "usl_otd", dir_server + "usl_otd", "UOTD" )
  // index on str(kod,4) to (dir_server+"usl_otd") progress
  //
  adbf := { ;
    { "kod",     "N", 4, 0 }, ;
    { "kod_tmp", "N", 4, 0 }, ;
    { "kol",     "N", 6, 0 }, ;
    { "shifr",   "C", 10, 0 }, ;
    { "cena",    "N", 10, 2 }, ;
    { "cena_d",  "N", 10, 2 };
    }
  dbCreate( cur_dir + "tmp", adbf )
  Use ( cur_dir + "tmp" ) new
  Index On shifr + Str( cena, 10, 2 ) + Str( cena_d, 10, 2 ) to ( cur_dir + "tmp" )
  dbCreate( cur_dir + "tmp1", adbf )
  Use ( cur_dir + "tmp1" ) new
  hGauge := gaugenew(,,, "Поиск дубликатов услуг", .t. )
  gaugedisplay( hGauge )
  Set Deleted Off
  Select USL
  Go Top
  Do While RecNo() < 10000 .and. !Eof()
    @ MaxRow(), 0 Say PadR( Str( RecNo() / LastRec() * 100, 7, 2 ) + "%", 80 ) Color cColorStMsg
    gaugeupdate( hGauge, RecNo() / LastRec() )
    //
    If Deleted()
      Recall
    Endif
    If usl->kod > 0 .and. AllTrim( usl->shifr ) == "8.1.5" .and. !usl->is_nulp .and. ;
        emptyall( usl->shifr1, usl->pcena, usl->pcena_d, usl->dms_cena, usl->pnds, usl->pnds_d )
      Select USL1
      find ( Str( usl->kod, 4 ) )
      If !Found() // нет поля "шифр ТФОМС"
        Select TMP
        find ( usl->shifr + Str( usl->cena, 10, 2 ) + Str( usl->cena_d, 10, 2 ) )
        If !Found()
          Append Blank
          tmp->shifr  := usl->shifr
          tmp->cena   := usl->cena
          tmp->cena_d := usl->cena_d
        Endif
        tmp->kol++
        Select TMP1
        Append Blank
        tmp1->kod := usl->kod
        tmp1->kod_tmp := tmp->( RecNo() )
      Endif
    Endif
    Select USL
    Skip
  Enddo
  Commit
  closegauge( hGauge )
  Select TMP
  If LastRec() > 0
    Index On Str( kol, 6 ) to ( cur_dir + "tmp" )
    Go Bottom
    If tmp->kol > 10
      i := 0
      Select TMP1
      Index On Str( kod, 4 ) to ( cur_dir + "tmp1" ) For tmp1->kod_tmp == tmp->( RecNo() )
      Go Top
      lkod_usl := tmp1->kod // первая запись
      Do While !Eof()
        If lkod_usl != tmp1->kod // пропускаем первую запись
          @ MaxRow(), 0 Say PadR( Str( ++i ) + " - удалено дубликатов услуг", 80 ) Color cColorStMsg
          Select HU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            hu->u_kod := lkod_usl
          Enddo
          Select HPU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            hpu->u_kod := lkod_usl
          Enddo
          Select PUC
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            puc->kod_usl := lkod_usl
          Enddo
          Select HOU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            hou->u_kod := lkod_usl
          Enddo
          Select KPU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            kpu->u_kod := lkod_usl
          Enddo
          Select KOU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            kou->u_kod := lkod_usl
          Enddo
          Select KUU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            kuu->u_kod := lkod_usl
          Enddo
          Select KUUD
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            kuud->u_kod := lkod_usl
          Enddo
          Select USL1
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            usl1->kod := lkod_usl
          Enddo
          Select UCH_USL
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            uch_usl->kod := lkod_usl
          Enddo
          Select UCH_USL1
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            uch_usl1->kod := lkod_usl
          Enddo
          If flag_udel
            Select UDEL
            Do While .t.
              find ( Str( tmp1->kod, 4 ) )
              If !Found() ; exit ; Endif
              udel->kod := lkod_usl
            Enddo
          Endif
          Select UOTD
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found() ; exit ; Endif
            uotd->kod := lkod_usl
          Enddo
          Select USL
          Goto ( tmp1->kod )
          Replace usl->kod With -1, ;
            usl->slugba With -1, ;
            usl->name With "", ;
            usl->shifr With "", usl->shifr1 With ""
          If i % 100 == 0
            Commit
          Endif
        Endif
        Select TMP1
        Skip
      Enddo
      Close databases
      Use ( dir_server + "uslugi" ) New Alias USL
      Go Bottom
      Do While !Bof()
        If RecNo() > 9999 .or. usl->kod == -1
          Delete
        Else
          Exit
        Endif
        Skip -1
      Enddo
      Pack
      index_base( "uslugi" )
    Endif
  Endif
  Close databases
  Set Deleted On
  rest_box( buf )

  Return Nil

// 02.09.15 поиск и удаление дубликатов в картотеке по ключу "код ТФ(PID)+ФИО+дата рождения"
Function dubl_zap_kod_tf()

  Local j := 0, old_tf := 0, ii := 0, k, ar[ 10 ], name_file := "kod_tf.txt", ;
    rec, i, j1, j2, ak := {}, buf := SaveScreen()

  f_message( { "Ждите! Пpоизводится поиск и удаление дубликатов в картотеке.", ;
    "", ;
    "Ни в коем случае не прерывайте процесс", ;
    "во избежание нежелательных последствий!" },, "G+/R", "GR+/R", 13 )
  stat_msg( 'Поиск дубликатов по ключу "код ТФ(PID)+ФИО+дата рождения"' )
  adbf := { { "kod", "N", 7, 0 }, { "kodh", "N", 7, 0 } }
  dbCreate( cur_dir + "t_dubl", adbf )
  AAdd( adbf, { "kod1", "N", 7, 0 } )
  dbCreate( cur_dir + "t1dubl", adbf )
  Use ( cur_dir + "t_dubl" ) New Alias t
  Use ( cur_dir + "t1dubl" ) New Alias t1
  Use ( dir_server + "human" ) New Alias HUMAN
  Index On Str( kod_k, 7 ) + Str( Descend( k_data ), 10 ) to ( cur_dir + "tmp_human" ) For !Empty( k_data )
  Use ( dir_server + "kartote_" ) New Alias KART_
  Use ( dir_server + "kartotek" ) New Alias KART
  Use ( dir_server + "kartote2" ) New Alias KART2
  Set Relation To RecNo() into KART_, To RecNo() into KART
  Index On Str( kart2->kod_tf, 10 ) to ( cur_dir + "tmp_kart2" ) ;
    For kart2->kod_tf > 0 .and. !kart->( Eof() ) .and. kart->kod > 0
  Go Top
  Do While !Eof()
    If ii < 10 .or. ii % 10 == 0
      @ MaxRow(), 1 Say lstr( ii ) Color cColorStMsg
    Endif
    If kart2->kod_tf > old_tf
      old_tf := kart2->kod_tf ; k := 0
      Select KART2
      Do While old_tf == kart2->kod_tf .and. !Eof()
        ++k
        Skip
      Enddo
      rec := RecNo()
      If k > 1
        arr1 := {}
        Select KART2
        find ( Str( old_tf, 10 ) )
        Do While old_tf == kart2->kod_tf .and. !Eof()
          If ( i := AScan( arr1, {| x| x[ 2 ] == Upper( kart->fio ) .and. x[ 3 ] == kart->date_r } ) ) == 0
            AAdd( arr1, { 0, Upper( kart->fio ), kart->date_r, {} } ) ; i := Len( arr1 )
          Endif
          arr1[ i, 1 ] ++
          AAdd( arr1[ i, 4 ], kart2->( RecNo() ) )
          Skip
        Enddo
        If Len( arr1 ) > 1
          ASort( arr1,,, {| x, y| x[ 1 ] > y[ 1 ] } )
        Endif
        If ( k := arr1[ 1, 1 ] ) > 1
          ++ii ; j += k
          If ( i := AScan( ak, {| x| x[ 1 ] == k } ) ) == 0
            AAdd( ak, { k, 0 } ) ; i := Len( ak )
          Endif
          ak[ i, 2 ] ++
          arr := {}
          For i := 1 To Len( arr1[ 1, 4 ] )
            Select KART2
            Goto ( arr1[ 1, 4, i ] )
            Select HUMAN
            find ( Str( kart->kod, 7 ) )
            AAdd( arr, { arr1[ 1, 4, i ], ;
              iif( Found(), Int( Val( DToS( human->k_data ) ) ), 0 ), ;
              kart_->VPOLIS, ;
              kart_->vid_ud, ;
              kart_->ser_ud, ;
              iif( Left( kart2->PC2, 1 ) == "1", 1, 0 ), ;
              iif( Found(), human->kod, 0 ) } )
          Next
          ASort( arr,,, {| x, y| iif( x[ 2 ] == y[ 2 ], ;
            iif( x[ 3 ] == y[ 3 ], ;
            iif( x[ 4 ] == y[ 4 ], x[ 5 ] > y[ 5 ], x[ 4 ] > y[ 4 ] ), ;
            x[ 3 ] > y[ 3 ] ), ;
            x[ 2 ] > y[ 2 ] ) } )
          For k := 1 To Len( arr )
            Select KART2
            Goto ( arr[ k, 1 ] )
            If k == 1
              Select T
              Append Blank
              t->kod  := arr[ k, 1 ]
              t->kodh := arr[ k, 7 ]
            Else // k > 1
              Select T1
              Append Blank
              t1->kod  := t->kod
              t1->kod1 := arr[ k, 1 ]
              t1->kodh := arr[ k, 7 ]
            Endif
          Next
          If ii % 2000 == 0
            Commit
          Endif
        Endif
      Endif
      Select KART2
      Goto ( rec )
      Skip -1
    Endif
    Select KART2
    Skip
  Enddo
  j1 := t->( LastRec() )
  j2 := t1->( LastRec() )
  Close databases
  If j1 > 0
    Private mfio, mdate_r, mbukva, muchast, mkod_vu, mkod_AK, ;
      MADRES, MMR_DOL, M1VID_UD, mser_ud, mnom_ud, M1KEMVYD, MKOGDAVYD, ;
      m1vidpolis, mpolis, mspolis, mnpolis, msmo, mmesto_r, msnils, ;
      m1kategor, m1kategor2, mokatog, mokatop, madresp, ;
      mPHONE_H, mPHONE_M, mPHONE_W, m1okato
    stat_msg( 'Удаление дубликатов по ключу "код ТФ(PID)+ФИО+дата рождения"' )
    fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( "Будет удалено записей в картотеке - " + lstr( j - ii ) )
    ASort( ak,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    add_string( print_array( ak ) )
    add_string( Replicate( "-", 102 ) )
    f_open_files_dubl_zap( .t. ) // монопольное открытие всех файлов
    e_use( dir_server + "human", dir_server + "humankk", "HUMAN" ) // монопольно
    use_base( "kartotek",, .t. ) // монопольно
    Set Order To 0
    Use ( cur_dir + "t1dubl" ) New Alias t1
    Index On Str( kod, 7 ) to ( cur_dir + "t1dubl" )
    Use ( cur_dir + "t_dubl" ) New Alias t
    Go Top
    Do While !Eof()
      If RecNo() < 10 .or. RecNo() % 10 == 0
        @ MaxRow(), 0 Say Str( RecNo() / j1 * 100, 6, 2 ) + "%" Color cColorStMsg
      Endif
      ar[ 1 ] := "код |"
      ar[ 2 ] := "уч-к|"
      ar[ 3 ] := "пол.|"
      ar[ 4 ] := "пасп|"
      ar[ 5 ] := "адр.|"
      ar[ 6 ] := "прож|"
      Select KART
      Goto ( t->kod )
      ar[ 1 ] += lstr( t->kod )
      If t->kodh > 0
        human->( dbGoto( t->kodh ) )
        ar[ 1 ] += "(п/л/у " + full_date( human->k_data ) + ")"
      Endif
      ar[ 1 ] += iif( Left( kart2->PC2, 1 ) == "1", " УМЕР", "" ) + "|"
      ar[ 2 ] += " участок " + lstr( kart->uchast ) + "|"
      ar[ 3 ] += lstr( kart_->VPOLIS, 1 ) + " " + AllTrim( kart_->NPOLIS ) + "|"
      ar[ 4 ] += lstr( kart_->vid_ud ) + " " + AllTrim( kart_->ser_ud ) + " " + AllTrim( kart_->nom_ud ) + "|"
      ar[ 5 ] += RTrim( kart_->okatog ) + " " + AllTrim( kart->adres ) + "|"
      ar[ 6 ] += RTrim( kart_->okatop ) + " " + AllTrim( kart_->adresp ) + "|"
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
      Select T1
      find ( Str( t->kod, 7 ) )
      Do While t1->kod == t->kod .and. !Eof()
        ++k
        Select KART
        Goto ( t1->kod1 )
        If Empty( muchast ) .and. !Empty( kart->uchast )
          mbukva  := kart->bukva
          muchast := kart->uchast
          mkod_vu := kart->kod_vu
          iuch := k
        Endif
        If Empty( mkod_AK )
          mkod_AK := kart2->kod_AK
        Endif
        If emptyany( mokatog, mADRES ) .and. !emptyall( kart_->okatog, kart->ADRES )
          iadres := k
          mokatog := kart_->okatog       // код места жительства по ОКАТО
          mADRES  := kart->ADRES
          If emptyany( mokatop, mADRESp ) .and. !emptyall( kart_->okatop, kart_->adresp )
            mokatop := kart_->okatop       // код места пребывания по ОКАТО
            madresp := kart_->adresp       // адрес места пребывания
          Endif
        Endif
        If Empty( mMR_DOL ) .and. !Empty( kart->MR_DOL )
          imrab := k
          mMR_DOL := kart->MR_DOL
        Endif
        If Empty( msnils ) .and. !Empty( kart->snils )
          isnils := k
          msnils := kart->snils
        Endif
        If m1vidpolis < kart_->VPOLIS
          ipolis := k
          mpolis     := kart->POLIS   // полис
          m1vidpolis := kart_->VPOLIS // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый
          mspolis    := kart_->SPOLIS // серия полиса
          mnpolis    := kart_->NPOLIS // номер полиса
          msmo       := kart_->SMO    // реестровый номер СМО
          m1okato    := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
        Endif
        If m1vid_ud < kart_->vid_ud .or. ;
            ( m1vid_ud == kart_->vid_ud .and. !Empty( kart_->ser_ud ) ;
            .and. val_ud_ser( 2, kart_->vid_ud, kart_->ser_ud ) ;
            .and. mser_ud < kart_->ser_ud )
          iud := k
          m1vid_ud  := kart_->vid_ud   // вид удостоверения личности
          mser_ud   := kart_->ser_ud   // серия удостоверения личности
          mnom_ud   := kart_->nom_ud   // номер удостоверения личности
          m1kemvyd  := kart_->kemvyd   // кем выдан документ
          mkogdavyd := kart_->kogdavyd // когда выдан документ
        Endif
        If eq_any( m1kategor, 0, 13 ) .and. !Empty( kart_->kategor )
          m1kategor := kart_->kategor  // категория пациента
        Endif
        If Empty( m1kategor2 )
          m1kategor2 := kart_->kategor2 // категория пациента (собственная для МО)
        Endif
        If Empty( mmesto_r ) .and. !Empty( kart_->mesto_r )
          imr := k
          mmesto_r := kart_->mesto_r    // место рождения;;
        Endif
        If Empty( mPHONE_H ) .and. !Empty( kart_->PHONE_H )
          ith := k
          mPHONE_H := kart_->PHONE_H    // телефон домашний;;
        Endif
        If Empty( mPHONE_M ) .and. !Empty( kart_->PHONE_M )
          itm := k
          mPHONE_M := kart_->PHONE_M    // телефон мобильный;;
        Endif
        If Empty( mPHONE_W ) .and. !Empty( kart_->PHONE_W )
          itw := k
          mPHONE_W := kart_->PHONE_W    // телефон рабочий;;
        Endif
        ar[ 1 ] += lstr( t1->kod1 )
        If t1->kodh > 0
          human->( dbGoto( t1->kodh ) )
          ar[ 1 ] += "(п/л/у " + full_date( human->k_data ) + ")"
        Endif
        If !( Upper( mfio ) == Upper( kart->fio ) .and. mdate_r == kart->date_r )
          ar[ 1 ] += " err " + fam_i_o( kart->fio ) + " " + full_date( kart->date_r )
        Endif
        ar[ 1 ] += iif( Left( kart2->PC2, 1 ) == "1", " УМЕР", "" ) + "|"
        ar[ 2 ] += " участок " + lstr( kart->uchast ) + "|"
        ar[ 3 ] += lstr( kart_->VPOLIS, 1 ) + " " + AllTrim( kart_->NPOLIS ) + "|"
        ar[ 4 ] += lstr( kart_->vid_ud ) + " " + AllTrim( kart_->ser_ud ) + " " + AllTrim( kart_->nom_ud ) + "|"
        ar[ 5 ] += RTrim( kart_->okatog ) + " " + AllTrim( kart->adres ) + "|"
        ar[ 6 ] += RTrim( kart_->okatop ) + " " + AllTrim( kart_->adresp ) + "|"
        f_delete_dubl_zap( t1->kod, t1->kod1, .f. ) // не блокировать записи
        Select T1
        Skip
      Enddo
      Select KART
      Goto ( t->kod )
      add_string( PadR( lstr( kart2->kod_tf ) + "/" + lstr( t->( RecNo() ) ) + " (" + lstr( k ) + ")", 102, "-" ) )
      add_string( AllTrim( kart->fio ) + " " + full_date( kart->date_r ) )
      For k := 1 To 6
        add_string( ar[ k ] )
      Next
      add_string( "уч-ок" + iif( iuch == 1, ":", "(" + lstr( iuch ) + "):" ) + AllTrim( mbukva ) + lstr( muchast ) + "/" + lstr( mkod_vu ) + " " + mkod_AK )
      add_string( "полис" + iif( ipolis == 1, ":", "(" + lstr( ipolis ) + "):" ) + lstr( m1vidpolis ) + " " + AllTrim( mspolis ) + " " + AllTrim( mnpolis ) )
      add_string( "удост" + iif( iud == 1, ":", "(" + lstr( iud ) + "):" ) + lstr( m1vid_ud ) + " " + AllTrim( mser_ud ) + " " + AllTrim( mnom_ud ) )
      add_string( "рожд." + iif( imr == 1, ":", "(" + lstr( imr ) + "):" ) + RTrim( mmesto_r ) )
      add_string( "адрес" + iif( iadres == 1, ":", "(" + lstr( iadres ) + "):" ) + mokatog + " " + RTrim( mADRES ) + "/" + mokatop + " " + RTrim( mADRESp ) )
      If !Empty( mmr_dol )
        add_string( "работ" + iif( imrab == 1, ":", "(" + lstr( imrab ) + "):" ) + RTrim( mmr_dol ) )
      Endif
      add_string( "СНИЛС" + iif( isnils == 1, ":", "(" + lstr( isnils ) + "):" ) + Transform( mSNILS, picture_pf ) )
      s := ""
      If !Empty( mPHONE_H )
        s += "тел.Д" + iif( ith == 1, ":", "(" + lstr( ith ) + "):" ) + mPHONE_H
      Endif
      If !Empty( mPHONE_M )
        s += "тел.М" + iif( itm == 1, ":", "(" + lstr( itm ) + "):" ) + mPHONE_m
      Endif
      If !Empty( mPHONE_W )
        s += "тел.Р" + iif( itw == 1, ":", "(" + lstr( itw ) + "):" ) + mPHONE_w
      Endif
      If !Empty( s )
        add_string( s )
      Endif
      //
      Select KART
      Goto ( t->kod )
      Select KART_
      Do While kart_->( LastRec() ) < t->kod
        Append Blank
      Enddo
      Goto ( t->kod )
      Select KART2
      Do While kart2->( LastRec() ) < t->kod
        Append Blank
      Enddo
      Goto ( t->kod )
      //
      If !( kart_->okatog == mokatog )
        kart_->okatog := mokatog
      Endif
      If !( kart->ADRES == mADRES )
        kart->ADRES := mADRES
      Endif
      If !( kart_->okatop == mokatop )
        kart_->okatop := mokatop
      Endif
      If !( kart_->adresp == madresp )
        kart_->adresp := madresp
      Endif
      If !( kart->MR_DOL == mMR_DOL )
        kart->MR_DOL := mMR_DOL
      Endif
      If !( kart->snils == msnils )
        kart->snils := msnils
      Endif
      If !( kart->bukva == mbukva )
        kart->bukva := mbukva
      Endif
      If kart->uchast != muchast
        kart->uchast := muchast
      Endif
      If kart->kod_vu != mkod_vu
        kart->kod_vu := mkod_vu
      Endif
      If !( kart2->kod_AK == mkod_AK )
        kart2->kod_AK := mkod_AK
      Endif
      If kart_->VPOLIS != m1vidpolis
        kart_->VPOLIS := m1vidpolis
      Endif
      If !( kart->POLIS == mpolis )
        kart->POLIS := mpolis
      Endif
      If !( kart_->SPOLIS == mspolis )
        kart_->SPOLIS := mspolis
      Endif
      If !( kart_->NPOLIS == mnpolis )
        kart_->NPOLIS := mnpolis
      Endif
      If !( kart_->SMO == msmo )
        kart_->SMO := msmo
      Endif
      If !( kart_->KVARTAL_D == m1okato )
        kart_->KVARTAL_D := m1okato
      Endif
      If kart_->vid_ud != m1vid_ud
        kart_->vid_ud := m1vid_ud
      Endif
      If !( kart_->ser_ud == mser_ud )
        kart_->ser_ud := mser_ud
      Endif
      If !( kart_->nom_ud == mnom_ud )
        kart_->nom_ud := mnom_ud
      Endif
      If kart_->kemvyd != m1kemvyd
        kart_->kemvyd := m1kemvyd
      Endif
      If kart_->kogdavyd != mkogdavyd
        kart_->kogdavyd := mkogdavyd
      Endif
      If kart_->kategor != m1kategor
        kart_->kategor := m1kategor
      Endif
      If kart_->kategor2 != m1kategor2
        kart_->kategor2 := m1kategor2
      Endif
      If !( kart_->mesto_r == mmesto_r )
        kart_->mesto_r := mmesto_r
      Endif
      If !( kart_->PHONE_H == mPHONE_H )
        kart_->PHONE_H := mPHONE_H
      Endif
      If !( kart_->PHONE_M == mPHONE_M )
        kart_->PHONE_M := mPHONE_M
      Endif
      If !( kart_->PHONE_W == mPHONE_W )
        kart_->PHONE_W := mPHONE_W
      Endif
      Select T
      If RecNo() % 400 == 0
        @ MaxRow(), 7 Say "rec" Color "W/R"
        Commit
        @ MaxRow(), 7 Say "   " Color cColorStMsg
      Endif
      Skip
    Enddo
    Close databases
    Delete File ( "t1dubl" + sntx )
    FClose( fp )
  Endif
  Delete File ( "t_dubl" + sdbf )
  Delete File ( "t1dubl" + sdbf )
  RestScreen( buf )

  Return { j1, j2 }

// 11.01.19 открыть все файлы для удаления дубликатов записей в картотеке
Function f_open_files_dubl_zap( lExcluUse )

  g_use( dir_server + "mo_d01k",, "D01K",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_d01k" )
  // список пациентов в реестрах будущих диспансеризаций
  g_use( dir_server + "mo_dr01k",, "R01K",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_r01k" )
  // направления на госпитализацию
  g_use( dir_server + "mo_nnapr",, "NAPR",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_napr" )
  //
  g_use( dir_server + "mo_kinos", dir_server + "mo_kinos", "KIS",, lExcluUse )
  //
  g_use( dir_server + "mo_kismo",, "SN",, lExcluUse )
  Index On Str( kod, 7 ) to ( cur_dir + "tmp_ismo" )
  // платные услуги
  g_use( dir_server + "hum_p", dir_server + "hum_pkk", "HUM_P",, lExcluUse )
  // ортопедия
  g_use( dir_server + "hum_ort", dir_server + "hum_ortk", "HUM_O",, lExcluUse )
  // приемный покой
  g_use( dir_server + "mo_pp", dir_server + "mo_pp_r", "PP",, lExcluUse )
  // касса платные
  g_use( dir_server + "kas_pl", dir_server + "kas_pl1", "KASP",, lExcluUse )
  // касса ортопедия
  g_use( dir_server + "kas_ort", dir_server + "kas_ort1", "KASO",, lExcluUse )
  // подобие регистра застрахованных
  g_use( dir_server + "kart_etk",, "kart_etk",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_kart_etk" )
  // примечания к картотеке
  g_use( dir_server + "k_prim1", dir_server + "k_prim1", "K_PRIM1",, lExcluUse )
  // оплата по ДМС и взаимозачету
  g_use( dir_server + "plat_vz",, "PVZ",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_pvz" )
  Set Index to ( cur_dir + "tmp_pvz" ), ( dir_server + "plat_vz" )
  // регистрация печати л/у
  g_use( dir_server + "mo_regi", { dir_server + "mo_regi1", ;
    dir_server + "mo_regi2", ;
    dir_server + "mo_regi3" }, "RU",, lExcluUse )
  Set Order To 3
  // МСЭК
  g_use( dir_server + "msek", dir_server + "msek", "MSEK",, lExcluUse )
  // cписок карточек пациентов в отосланных ходатайствах
  g_use( dir_server + "mo_hod_k",, "HK",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_hk" )
  // список прикреплений по пациенту во времени
  g_use( dir_server + "mo_kartp", dir_server + "mo_kartp", "KARTP",, lExcluUse )
  // список карточек в реестрах на прикрепление
  g_use( dir_server + "mo_krtp",, "KRTP",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_krtp" )
  // список ошибок в реестрах на прикрепление
  g_use( dir_server + "mo_krte",, "KRTE",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_krte" )
  // список карточек в файлах на открепление
  g_use( dir_server + "mo_krto",, "KRTO",, lExcluUse )
  Index On Str( kod_k, 7 ) to ( cur_dir + "tmp_krto" )

  Return Nil

// 11.01.19 удалить дубликаты записей в картотеке
Function f_delete_dubl_zap( dubl1_kart, dubl2_kart, is_lock )

  // dubl1_kart - Человек, которому переносится информация
  // dubl2_kart - Человек, который удаляется
  // is_lock    - логическая величина - блокировать ли запись
  Default is_lock To .t.
  // список пациентов в реестрах будущих диспансеризаций
  Select D01K
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    d01k->kod_k := dubl1_kart
  Enddo
  Select R01K
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    r01k->kod_k := dubl1_kart
  Enddo
  // направления на госпитализацию
  Select NAPR
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    napr->kod_k := dubl1_kart
  Enddo
  Select HUMAN
  // должен уже стоять на индексе (dir_server+"humankk")
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    human->kod_k := dubl1_kart
  Enddo
  Select KIS
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select SN
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select HUM_P
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    hum_p->kod_k := dubl1_kart
  Enddo
  Select HUM_O
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    hum_o->kod_k := dubl1_kart
  Enddo
  Select PP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    pp->kod_k := dubl1_kart
  Enddo
  Select KASP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    kasp->kod_k := dubl1_kart
  Enddo
  Select KASO
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    kaso->kod_k := dubl1_kart
  Enddo
  Select kart_etk
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select K_PRIM1
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    deleterec( .t.,, is_lock )
  Enddo
  Select PVZ
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    pvz->kod_k := dubl1_kart
  Enddo
  Select RU
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    ru->kod_k := dubl1_kart
  Enddo
  Select MSEK
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    msek->kod_k := dubl1_kart
  Enddo
  Select HK
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    hk->kod_k := dubl1_kart
  Enddo
  Select KARTP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    kartp->kod_k := dubl1_kart
  Enddo
  Select KRTP
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    krtp->kod_k := dubl1_kart
  Enddo
  Select KRTE
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    krte->kod_k := dubl1_kart
  Enddo
  Select KRTO
  Do While .t.
    find ( Str( dubl2_kart, 7 ) )
    If !Found() ; exit ; Endif
    If is_lock
      g_rlock( forever )
    Endif
    krto->kod_k := dubl1_kart
  Enddo
  // картотека
  Select KART
  Set Order To 0
  Goto ( dubl2_kart )
  // т.к. relation
  Select KART2
  Goto ( dubl2_kart )
  If !Eof()
    deleterec( .t., .f., is_lock )  // очистка записи без пометки на удаление
  Endif
  Select KART_
  Goto ( dubl2_kart )
  If !Eof()
    deleterec( .t., .f., is_lock )  // очистка записи без пометки на удаление
  Endif
  Select KART
  Goto ( dubl2_kart )
  deleterec( .t., .f., is_lock )  // очистка записи без пометки на удаление
  If is_lock
    dbUnlockAll()
  Endif

  Return Nil

// 14.09.16 поправить номер полиса из реестров СПТК
Function correct_polis_from_sptk()

  Local ii := 0, jj := 0, fl, buf := save_maxrow()

  stat_msg( "Поиск/попытка исправления полисов в картотеке" )
  Use ( dir_server + "human_" ) new
  Use ( dir_server + "human" ) new
  Set Relation To RecNo() into HUMAN_
  Private mdate := SToD( "20190630" )
  Index On Str( kod_k, 7 ) + Str( Descend( k_data ), 10 ) to ( cur_dir + "tmp_human" ) For k_data > mdate
  use_base( "kartotek",, .t. ) // открываем в монопольном режиме
  Set Order To 2
  find ( "1" )
  Do While kart->kod > 0 .and. !Eof()
    If++ii % 500 == 0
      @ MaxRow(), 0 Say Str( ii / LastRec() * 100, 6, 2 ) + "%" Color cColorStMsg
    Endif
    Select HUMAN
    find ( Str( kart->kod, 7 ) )
    Do While human->kod_k == kart->kod .and. !Eof()
      If !Empty( k_data ) .and. kod > 0 .and. ;
          Between( human_->VPOLIS, 1, 3 ) .and. schet > 0 .and. ; // в счете
        human_->REESTR > 0 .and. Between( human_->smo, '34001', '34007' )
        fl := .f.
        If human_->VPOLIS == kart_->VPOLIS
          fl := !( kart_->NPOLIS == human_->NPOLIS )
        Elseif human_->VPOLIS > kart_->VPOLIS
          fl := .t.
        Endif
        If fl
          kart->POLIS   := make_polis( human_->spolis, human_->npolis )
          kart_->VPOLIS := human_->VPOLIS
          kart_->SPOLIS := human_->SPOLIS
          kart_->NPOLIS := human_->NPOLIS
          If++jj % 2000 == 0
            Commit
          Endif
        Endif
        Exit
      Endif
      Select HUMAN
      Skip
    Enddo
    Select KART
    Skip
  Enddo
  Close databases
  rest_box( buf )

  Return Nil
