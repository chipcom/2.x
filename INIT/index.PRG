// mo_index.prg - модуль переиндексирования
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// запуск режима переиндексирования из меню
Function m_index_db()

  Local t2 := 0

  If g_slock1task( sem_task(), sem_vagno() )  // запрет доступа всем
    If f_esc_enter( 'переиндексирования' )
      t2 := pereindex()
      ___uslugi()
    Endif
    // разрешение доступа всем
    g_sunlock( sem_vagno() )
    Keyboard ''
    If t2 > 0
      n_message( { '', 'Время переиндексирования - ' + SecToTime( t2 ) },, ;
        color1, cDataCSay,,, color8 )
    Endif
  Else
    func_error( 4, 'В данный момент работают другие задачи. Переиндексирование запрещено!' )
  Endif
  Return Nil

// 10.09.25 внутренняя функция переиндексирования
Function pereindex()

  Local buf := SaveScreen(), t1, t2, i, ae[ 3 ]

  f_message( { 'Внимание! Пpоизводится пеpеиндексирование базы данных.', ;
    '', ;
    'Во избежание разрушения данных', ;
    'не прерывайте процесс!' },, 'GR+/R', 'W+/R', 13 )

  t1 := Seconds()
//  Private fl_open := .t.
  For i := 1 To Len( array_files_DB() )
    index_base( array_files_DB()[ i ] )
  Next
  //
  Use ( dir_server() + 'mo_ppadd' ) new
  Pack
  Use
  //
  pereindex_263()
  //
  move_ENP()
  //
  mywait()
  Use ( dir_server() + 'mo_raksh' ) New Alias RAKSH
  Index On Str( FIELD->kod_raks, 6 ) to ( cur_dir() + 'tmpraksh' )
  Use ( dir_server() + 'mo_raks' ) New Alias RAKS
  Index On Str( FIELD->akt, 6 ) to ( cur_dir() + 'tmpraks' )
  Use ( dir_server() + 'mo_rak' ) New Alias RAK
  Index On Str( FIELD->akt, 6 ) to ( cur_dir() + 'tmprak' )
  Use ( dir_server() + 'mo_xml' ) New Alias MO_XML
  Locate For FIELD->kod == 0 .and. !Deleted()
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
  Use ( dir_server() + 'mo_rpdsh' ) new
  Pack // упаковка файла нижнего уровня
  Close databases
  //
  Use ( dir_server() + 'mo_nnapr' ) New Alias NAPR
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
  Use ( dir_server() + 'mo_n7in' ) New Alias N7i
  Go Top
  Do While !Eof()
    If !Between( n7i->USL_OK, 1, 2 )
      n7i->USL_OK := 1
    Endif
    Skip
  Enddo
  Use ( dir_server() + 'mo_n7out' ) New Alias N7
  Go Top
  Do While !Eof()
    If !Between( n7->USL_OK, 1, 2 )
      n7->USL_OK := 1
    Endif
    Skip
  Enddo
  Close databases
  //
  stat_msg( 'Пеpеиндексирование завеpшено!' )
  t2 := Seconds() - t1
  RestScreen( buf )
  Return t2

// 23.08.17
Function pereindex_263()

  Local n, pole, buf := save_maxrow()

  stat_msg( 'Поиск/попытка исправления избыточных ошибок в направлениях на госпитализацию' )
  g_use( dir_server() + 'mo_nnapr',, 'NAPR' )
  g_use( dir_server() + 'mo_nfina',, 'NFN' )
  Index On Str( FIELD->KOD_F, 6 ) + Str( FIELD->KOD_N, 6 ) to ( cur_dir() + 'tmp_nfn' )
  g_use( dir_server() + 'mo_nfile',, 'NF' )
  Index On FIELD->kod to ( cur_dir() + 'tmp_nf' ) For FIELD->in_out == 1 .and. FIELD->tip_f < 7 .and. Year( FIELD->date_r ) > 2016
  Go Top
  Do While !Eof()
    If nf->T_ANS == 2 // в файле были ошибки
      If ( n := nf->tip_f ) == 5
        n := 4
      Endif
      pole := 'napr->t_ans_' + lstr( n )
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

// 10.09.25 функция переиндексирования для одной задачи
Function pereindex_task( n_task )

  Local buf := SaveScreen(), i

  Default n_Task To glob_task
  If mo_lock_task( n_Task ) .and. f_esc_enter( 'переиндексирования' )
    f_message( { 'Внимание! Пpоизводится пеpеиндексирование сегмента базы данных', ;
      'для подзадачи "' + array_tasks()[ ind_task( n_Task ), 1 ] + '"', ;
      '', ;
      'Во избежание разрушения данных не прерывайте процесс!' },, 'GR+/R', 'W+/R', 13 )
//    Private fl_open := .t.
    If !emptyany( array_task_DB( array_files_DB() )[ n_Task, 1 ], array_task_DB( array_files_DB() )[ n_Task, 2 ] )
      For i := array_task_DB( array_files_DB() )[ n_Task, 1 ] To array_task_DB( array_files_DB() )[ n_Task, 2 ]
        index_base( array_files_DB()[ i ] )
      Next
    Endif
    If n_Task == X_263
      pereindex_263()
    Endif
    // разрешение доступа всем к данной задаче
    mo_unlock_task( n_Task )
    Keyboard ''
    RestScreen( buf )
    stat_msg( 'Переиндексирование части базы данных завершено!' )
    mybell( 2, OK )
  Endif
  RestScreen( buf )
  Return Nil

// 03.12.16 специально для ЦРБ Городищенского р-на
Function ___uslugi()

  Local adbf, buf := save_maxrow()
  Local hGauge, i
  local lkod_usl, flag_udel

  If .t. // !(glob_mo[_MO_KOD_TFOMS] == '321001')
    Return Nil
  Endif
  //
  e_use( dir_server() + 'uslugi',, 'USL' )
  mywait()
  //
  e_use( dir_server() + 'human_u', ;
    { dir_server() + 'human_u', ;
      dir_server() + 'human_uk', ;
      dir_server() + 'human_ud', ;
      dir_server() + 'human_uv', ;
      dir_server() + 'human_ua' }, ;
    'HU' )
  // index on str(FIELD->u_kod,4) to (dir_server()+"human_uk") progress
  Set Order To 2
  //
  e_use( dir_server() + 'hum_p_u', ;
    { dir_server() + 'hum_p_u', ;
      dir_server() + 'hum_p_uk', ;
      dir_server() + 'hum_p_ud', ;
      dir_server() + 'hum_p_uv', ;
      dir_server() + 'hum_p_ua' }, ;
    'HPU' )
  // index on str(FIELD->u_kod,4) to (dir_server()+"hum_p_uk") progress
  Set Order To 2
  //
  e_use( dir_server() + 'pu_cena', ;
    { dir_server() + 'pu_cena', ;
      dir_server() + 'pu_cenau' }, ;
    'PUC' )
  // index on str(FIELD->kod_usl,4)+str(kod_date,4) to (dir_server()+"pu_cenau") progress
  Set Order To 2
  //
  e_use( dir_server() + 'hum_oru', ;
    { dir_server() + 'hum_oru', ;
      dir_server() + 'hum_oruk', ;
      dir_server() + 'hum_orud', ;
      dir_server() + 'hum_oruv', ;
      dir_server() + 'hum_orua' }, ;
    'HOU' )
  // index on str(FIELD->u_kod,4) to (dir_server()+"hum_oruk") progress
  Set Order To 2
  //
  e_use( dir_server() + 'kas_pl_u', ;
    { dir_server() + 'kas_pl1u', ;
      dir_server() + 'kas_pl2u' }, ;
    'KPU' )
  // index on str(FIELD->u_kod,4) to (dir_server()+"kas_pl2u") progress
  Set Order To 2
  //
  e_use( dir_server() + 'kas_ortu', ;
    { dir_server() + 'kas_or1u', ;
      dir_server() + 'kas_or2u' }, ;
    'KOU' )
  // index on str(FIELD->u_kod,4) to (dir_server()+"kas_or2u") progress
  Set Order To 2
  //
  e_use( dir_server() + 'kas_usl',, 'KUU' )
  Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmp_kuu' )
  //
  e_use( dir_server() + 'kas_usld',, 'KUUD' )
  Index On Str( FIELD->u_kod, 4 ) to ( cur_dir() + 'tmp_kuud' )
  //
  e_use( dir_server() + 'uslugi1', ;
    { dir_server() + 'uslugi1', ;
      dir_server() + 'uslugi1s' }, ;
    'USL1' )
  // index on str(FIELD->kod,4)+dtos(FIELD->date_b) to (dir_server()+"uslugi1") progress
  //
  e_use( dir_server() + 'uch_usl', dir_server() + 'uch_usl', 'UCH_USL' )
  // index on str(FIELD->kod,4) to (dir_server()+"uch_usl") progress
  //
  e_use( dir_server() + 'uch_usl1', dir_server() + 'uch_usl1', 'UCH_USL1' )
  // index on str(FIELD->kod,4)+dtos(date_b) to (dir_server()+"uch_usl1") progress
  //
  If ( flag_udel := hb_FileExists( dir_server() + 'usl_del' + sdbf() ) )
    e_use( dir_server() + 'usl_del',, 'UDEL' )
    Index On Str( FIELD->kod, 4 ) to ( cur_dir() + 'tmp_udel' )
  Endif
  //
  e_use( dir_server() + 'usl_otd', dir_server() + 'usl_otd', 'UOTD' )
  // index on str(FIELD->kod,4) to (dir_server()+"usl_otd") progress
  //
  adbf := { ;
    { 'kod',     'N', 4, 0 }, ;
    { 'kod_tmp', 'N', 4, 0 }, ;
    { 'kol',     'N', 6, 0 }, ;
    { 'shifr',   'C', 10, 0 }, ;
    { 'cena',    'N', 10, 2 }, ;
    { 'cena_d',  'N', 10, 2 };
    }
  dbCreate( cur_dir() + 'tmp', adbf )
  Use ( cur_dir() + 'tmp' ) new
  Index On FIELD->shifr + Str( FIELD->cena, 10, 2 ) + Str( FIELD->cena_d, 10, 2 ) to ( cur_dir() + 'tmp' )
  dbCreate( cur_dir() + 'tmp1', adbf )
  Use ( cur_dir() + 'tmp1' ) new
  hGauge := gaugenew(,,, 'Поиск дубликатов услуг', .t. )
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
    If usl->kod > 0 .and. AllTrim( usl->shifr ) == '8.1.5' .and. !usl->is_nulp .and. ;
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
    Index On Str( FIELD->kol, 6 ) to ( cur_dir() + 'tmp' )
    Go Bottom
    If tmp->kol > 10
      i := 0
      Select TMP1
      Index On Str( FIELD->kod, 4 ) to ( cur_dir() + 'tmp1' ) For tmp1->kod_tmp == tmp->( RecNo() )
      Go Top
      lkod_usl := tmp1->kod // первая запись
      Do While !Eof()
        If lkod_usl != tmp1->kod // пропускаем первую запись
          @ MaxRow(), 0 Say PadR( Str( ++i ) + ' - удалено дубликатов услуг', 80 ) Color cColorStMsg
          Select HU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            hu->u_kod := lkod_usl
          Enddo
          Select HPU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            hpu->u_kod := lkod_usl
          Enddo
          Select PUC
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            puc->kod_usl := lkod_usl
          Enddo
          Select HOU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            hou->u_kod := lkod_usl
          Enddo
          Select KPU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            kpu->u_kod := lkod_usl
          Enddo
          Select KOU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            kou->u_kod := lkod_usl
          Enddo
          Select KUU
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            kuu->u_kod := lkod_usl
          Enddo
          Select KUUD
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            kuud->u_kod := lkod_usl
          Enddo
          Select USL1
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            usl1->kod := lkod_usl
          Enddo
          Select UCH_USL
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            uch_usl->kod := lkod_usl
          Enddo
          Select UCH_USL1
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            uch_usl1->kod := lkod_usl
          Enddo
          If flag_udel
            Select UDEL
            Do While .t.
              find ( Str( tmp1->kod, 4 ) )
              If !Found()
                exit
              Endif
              udel->kod := lkod_usl
            Enddo
          Endif
          Select UOTD
          Do While .t.
            find ( Str( tmp1->kod, 4 ) )
            If !Found()
              exit
            Endif
            uotd->kod := lkod_usl
          Enddo
          Select USL
          Goto ( tmp1->kod )
          Replace usl->kod With -1, ;
            usl->slugba With -1, ;
            usl->name With '', ;
            usl->shifr With '', usl->shifr1 With ''
          If i % 100 == 0
            Commit
          Endif
        Endif
        Select TMP1
        Skip
      Enddo
      Close databases
      Use ( dir_server() + 'uslugi' ) New Alias USL
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
      index_base( 'uslugi' )
    Endif
  Endif
  Close databases
  Set Deleted On
  rest_box( buf )
  Return Nil

// 03.08.25
function move_ENP()

  Local oPb
  Local buf := save_maxrow()

  stat_msg( 'Поиск и копирование ЕНП' )
  use_base( 'kartotek',, .t. ) // открыть в монопольном режиме
  Set Index To
  Go Top
  oPb := TProgressBar():New( MaxRow(), 0, 20, 0, kart->( LastRec() ))
  oPb:Color := cColorStMsg
  oPb:Symbol := Chr( 219 )
  oPb:Display()
  Do While !Eof()
    If kart->kod > 0
//      @ MaxRow(), 1 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + "%" Color cColorStMsg
      oPb:Update( kart->( RecNo() ) )
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
  Index On if( FIELD->kod > 0, '1', '0' ) + FIELD->kod_mis to ( dir_server() + 'kartotee' ) progress
  Close databases
  oPb := nil
  rest_box( buf )
  return nil