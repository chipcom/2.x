// information_DDS.prg - информация по диспансеризации детей сирот
#include 'inkey.ch'
#include 'fastreph.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 23.09.20 Информация по диспансеризации детей-сирот
Function inf_dds( k ) 

  Static si1 := 1, si2 := 1, sj := 1, sj1 := 1, sj2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { ;
      '~Карта диспансеризации', ;
      '~Список пациентов', ;
      'Своды для Обл~здрава', ;
      'Форма № 030-Д/с/~о-13', ;
      'XML-файл для ~портала МЗРФ' }
    mas_msg := { ;
      'Распечатка карты диспансеризации (учётная форма № 030-Д/с/у-13)', ;
      'Распечатка списка пациентов, которым проведена диспансеризация детей-сирот', ;
      'Распечатка различных сводов для Облздрава Волгоградской области', ;
      'Сведения о диспансеризации несовершеннолетних (отчётная форма № 030-Д/с/о-13)', ;
      'Создание XML-файла для загрузки на портал Минздрава РФ' }
    mas_fun := { ;
      'inf_DDS(11)', ;
      'inf_DDS(12)', ;
      'inf_DDS(13)', ;
      'inf_DDS(14)', ;
      'inf_DDS(15)' }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case Between( k, 11, 19 )
    If ( j := popup_prompt( T_ROW, T_COL -5, sj, ;
        { 'Находящиеся в стационаре', 'Находящиеся под опекой' } ) ) == 0
      Return Nil
    Endif
    sj := j
    Private p_tip_lu := iif( j == 1, TIP_LU_DDS, TIP_LU_DDSOP )
    Do Case
    Case k == 11
      inf_dds_karta()
    Case k == 12
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 3, mas1pmt() ) ) > 0
        inf_dds_svod( 1,, j1 )
      Endif
    Case k == 13
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
        If ( j := popup_prompt( T_ROW, T_COL -5, sj2, ;
            { ;
              'Вывод таблицы со списком детей', ;
              'Вывод в Excel для ВОДКБ', ;
              'Вывод таблицы к письму №14-05/50', ;
              'Вывод таблицы 2510' } ) ) > 0
          sj2 := j
          If j > 2
            inf_dds_svod2( j, j1 )
          Else
            inf_dds_svod( 2, j, j1 )
          Endif
        Endif
      Endif
    Case k == 14
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
        inf_dds_030dso( j1 )
      Endif
    Case k == 15
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt() ) ) > 0
        inf_dds_xmlfile( j1 )
      Endif
    Endcase
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Endif
  Endif

  Return Nil

// 12.07.13 Распечатка карты диспансеризации (учётная форма № 030-Д/с/у-13)
Function inf_dds_karta()

  Local arr_m, buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, .f. )
      r_use( dir_server() + 'human',, 'HUMAN' )
      Use ( cur_dir() + 'tmp' ) new
      Set Relation To FIELD->kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + 'tmp' )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        r_use( cur_dir() + 'tmp', cur_dir() + 'tmp' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := 'Диспансеризация детей-сирот ' + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := 'B/BG'
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
      blk := {|| iif( human->schet > 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { ;
        { ' Ф.И.О.',      {|| PadR( human->fio, 39 ) }, blk }, ;
        { 'Дата рожд.',   {|| full_date( human->date_r ) }, blk }, ;
        { '№ ам.карты',   {|| human->uch_doc }, blk }, ;
        { 'Сроки леч-я',  {|| Left( date_8( human->n_data ), 5 ) + '-' + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { 'Этап',         {|| iif( human->ishod == 101, ' I  ', 'I-II' ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход;  ^<Enter>^ - распечатать карту диспансеризации' ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_dds_karta( nk, ob, 'edit' ) }
      edit_browse( t_arr )
    Endif
  Endif
  dbCloseAll()
  rest_box( buf )

  Return Nil

// 11.03.19
Function f0_inf_dds( arr_m, is_schet, is_reg, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f.
  If !del_dbf_file( cur_dir() + 'tmp' + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + 'tmp', { { 'kod', 'N', 7, 0 }, { 'is', 'N', 1, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To FIELD->kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On FIELD->kod to ( cur_dir() + 'tmp_h' ) ;
    For iif( p_tip_lu == TIP_LU_DDS, !Empty( FIELD->za_smo ), Empty( FIELD->za_smo ) ) .and. ;
    eq_any( FIELD->ishod, 101, 102 ) .and. iif( is_schet, FIELD->schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] PROGRESS
  human->( dbGoTop() )  //  Go Top
  Do While ! human->( Eof() )
    fl := .t.
    If is_reg
      fl := .f.
//      Select SCHET_
      schet_->( dbGoto( human->schet ) ) // Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
//      Select TMP
//      Append Blank
      tmp->( dbAppend() )
      tmp->kod := human->kod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
//    Select HUMAN
    human->( dbSkip() )   // Skip
  Enddo
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, 'Не найдено л/у по диспансеризации детей-сирот ' + arr_m[ 4 ] )
  Endif
  dbCloseAll()

  Return fl

// 05.07.13
Function f1_inf_dds_karta( nKey, oBrow, regim )

  Local ret := -1, lkod_h, lkod_k, rec := tmp->( RecNo() ), buf := save_maxrow()

  If regim == 'edit' .and. nKey == K_ENTER
    mywait()
    lkod_h := human->kod
    lkod_k := human->kod_k
    dbCloseAll()
    oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, 'f2_inf_DDS_karta' )
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif
  Return ret

// 05.07.13
Function f3_inf_dds_karta( _menu, _i, _r, ub, ue, fl )

  Local j, s := ''

  Default _r To ', ', fl To .t.
  For j := 1 To Len( _menu )
    If _i == _menu[ j, 2 ]
      s += ub
    Endif
    s += LTrim( _menu[ j, 1 ] )
    If _i == _menu[ j, 2 ]
      s += ue
    Endif
    If j < Len( _menu )
      s += _r
    Endif
  Next
  If fl
    s += ' (нужное подчеркнуть).'
  Endif
  Return s

// 09.11.25
Function inf_dds_svod( par, par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec
  local adbf
  local poled, polet, j
  local fr_data := '_data', fr_titl := '_titl'

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      adbf := { ;
        { 'nomer',   'N',  6, 0 }, ;
        { 'KOD',     'N',  7, 0 }, ; // код (номер записи)
        { 'KOD_K',   'N',  7, 0 }, ; // код по картотеке
        { 'FIO',     'C', 50, 0 }, ; // Ф.И.О. больного
        { 'DATE_R',  'D',  8, 0 }, ; // дата рождения больного
        { 'N_DATA',  'D',  8, 0 }, ; // дата начала лечения
        { 'K_DATA',  'D',  8, 0 }, ; // дата окончания лечения
        { 'sroki',   'C', 11, 0 }, ; // сроки лечения
        { 'noplata', 'N',  1, 0 }, ; //
        { 'oplata',  'C', 30, 0 }, ; // оплата
        { 'CENA_1',  'N', 10, 2 }, ; // оплачиваемая сумма лечения
        { 'KOD_DIAG','C',  5, 0 }, ; // шифр 1-ой осн.болезни
        { 'etap',    'N',  1, 0 }, ; //
        { 'gruppa_do','N', 1, 0 }, ; //
        { 'gruppa',  'N',  1, 0 }, ; //
        { 'gd1',     'C',  1, 0 }, ; //
        { 'gd2',     'C',  1, 0 }, ; //
        { 'gd3',     'C',  1, 0 }, ; //
        { 'gd4',     'C',  1, 0 }, ; //
        { 'gd5',     'C',  1, 0 }, ; //
        { 'g1',      'C',  1, 0 }, ; //
        { 'g2',      'C',  1, 0 }, ; //
        { 'g3',      'C',  1, 0 }, ; //
        { 'g4',      'C',  1, 0 }, ; //
        { 'g5',      'C',  1, 0 }, ; //
        { 'vperv',   'C',  1, 0 }, ; //
        { 'dispans', 'C',  1, 0 }, ; //
        { 'n1',      'C',  1, 0 }, ; //
        { 'n2',      'C',  1, 0 }, ; //
        { 'n3',      'C',  1, 0 }, ; //
        { 'p1',      'C',  1, 0 }, ; //
        { 'p2',      'C',  1, 0 }, ; //
        { 'p3',      'C',  1, 0 }, ; //
        { 'f1',      'C',  1, 0 }, ; //
        { 'f2',      'C',  1, 0 }, ; //
        { 'f3',      'C',  1, 0 }, ; //
        { 'f4',      'C',  1, 0 }, ; //
        { 'f5',      'C',  1, 0 }; //
      }
//      For i := 1 To Len( dds_arr_iss() )
      For i := 1 To Len( DDS_arr_issled( arr_m[ 5 ] ) )
        AAdd( adbf, { 'di_' + lstr( i ), 'C', 8, 0 } )
      Next
      For i := 1 To Len( dds_arr_osm1( arr_m[ 5 ] ) )
        AAdd( adbf, { 'd1_' + lstr( i ), 'C', 8, 0 } )
      Next
      AAdd( adbf, { 'd1_zs', 'C', 8, 0 } )
      For i := 1 To Len( dds_arr_osm2( arr_m[ 5 ] ) ) 
        AAdd( adbf, { 'd2_' + lstr( i ), 'C', 8, 0 } )
      Next
      dbCreate( cur_dir() + 'tmpfio', adbf )
      r_use( dir_server() + 'mo_rak',, 'RAK' )
      r_use( dir_server() + 'mo_raks',, 'RAKS' )
      Set Relation To FIELD->akt into RAK
      r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
      Set Relation To FIELD->kod_raks into RAKS
      Index On Str( FIELD->kod_h, 7 ) + DToS( rak->DAKT ) to ( cur_dir() + 'tmp_raksh' )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        r_use( cur_dir() + 'tmp' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      Do While .t.
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, 'f2_inf_DDS_svod' )
      Enddo
      Close databases
      delfrfiles()
      r_use( dir_server() + 'organiz',, 'ORG' )
      adbf := { ;
        { 'name',   'C', 130, 0 }, ;
        { 'nomer',  'N',  6, 0 }, ;
        { 'kol_opl','N',  6, 0 }, ;
        { 'CENA_1', 'N', 15, 2 }, ;
        { 'period', 'C', 250, 0 }, ;
        { 'period2','C', 50, 0 }, ;
        { 'kol2',   'C', 60, 0 }, ;
        { 'kol3',   'C', 60, 0 }, ;
        { 'kol4',   'C', 60, 0 }, ;
        { 'gd1',    'N',  8, 0 }, ; //
        { 'gd2',    'N',  8, 0 }, ; //
        { 'gd3',    'N',  8, 0 }, ; //
        { 'gd4',    'N',  8, 0 }, ; //
        { 'gd5',    'N',  8, 0 }, ; //
        { 'g1',     'N',  8, 0 }, ; //
        { 'g2',     'N',  8, 0 }, ; //
        { 'g3',     'N',  8, 0 }, ; //
        { 'g4',     'N',  8, 0 }, ; //
        { 'g5',     'N',  8, 0 }, ; //
        { 'vperv',  'N',  8, 0 }, ; //
        { 'dispans','N',  8, 0 }, ; //
        { 'n1',     'N',  8, 0 }, ; //
        { 'n2',     'N',  8, 0 }, ; //
        { 'n3',     'N',  8, 0 }, ; //
        { 'p1',     'N',  8, 0 }, ; //
        { 'p2',     'N',  8, 0 }, ; //
        { 'p3',     'N',  8, 0 }, ; //
        { 'f1',     'N',  8, 0 }, ; //
        { 'f2',     'N',  8, 0 }, ; //
        { 'f3',     'N',  8, 0 }, ; //
        { 'f4',     'N',  8, 0 }, ; //
        { 'f5',     'N',  8, 0 } }
      For i := 1 To Len( dds_arr_iss() )
        AAdd( adbf, { 'di_' + lstr( i ), 'N', 8, 0 } )
      Next
      For i := 1 To Len( dds_arr_osm1() )
        AAdd( adbf, { 'd1_' + lstr( i ), 'N', 8, 0 } )
      Next
      AAdd( adbf, { 'd1_zs', 'N', 8, 0 } )
      For i := 1 To Len( dds_arr_osm2() )
        AAdd( adbf, { 'd2_' + lstr( i ), 'N', 8, 0 } )
      Next
      dbCreate( fr_titl, adbf )
      Use ( fr_titl ) New Alias FRT
      Append Blank
      frt->name := glob_mo()[ _MO_SHORT_NAME ]
      frt->period := iif( p_tip_lu == TIP_LU_DDS, ;
        'пребывающих в стационарных условиях детей-сирот и детей, находящихся в трудной жизненной ситуации', ;
        'детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновлённых (удочерённых), принятых под опеку (попечительство), в приёмную или патронатную семью' )
      frt->period2 := arr_m[ 4 ]
      If par2 == 1
        frt->kol2 := 'Ф.И.О'
        frt->kol3 := 'Дата рождения'
        frt->kol4 := 'Дата начала диспансеризации'
      Else
        frt->kol2 := 'Наименование медицинской организации'
        frt->kol3 := 'Плановые показатели'
        frt->kol4 := 'Фактические показатели выполнения: осмотрено/обработано карт'
      Endif
      Copy File ( cur_dir() + 'tmpfio' + sdbf() ) to ( fr_data + sdbf() )
      Do Case
      Case par == 1
        Use ( fr_data ) New Alias FRD
        Index On DToS( FIELD->n_data ) + Upper( FIELD->fio ) to ( fr_data )
        Go Top
        j := 0
        Do While !Eof()
          frd->nomer := ++j
          Select FRT
          frt->nomer := frd->nomer
          frt->kol_opl += frd->noplata
          frt->cena_1 += frd->cena_1
          For i := 1 To Len( dds_arr_iss() )
            poled := 'frd->di_' + lstr( i )
            polet := 'frt->di_' + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          For i := 1 To Len( dds_arr_osm1() )
            poled := 'frd->d1_' + lstr( i )
            polet := 'frt->d1_' + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          If !Empty( frd->d1_zs )
            frt->d1_zs++
          Endif
          For i := 1 To Len( dds_arr_osm2() )
            poled := 'frd->d2_' + lstr( i )
            polet := 'frt->d2_' + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          Select FRD
          Skip
        Enddo
        Close databases
        call_fr( 'mo_ddsTF' )
      Case par == 2
        Use ( fr_data ) New Alias FRD
        Index On DToS( FIELD->n_data ) + Upper( FIELD->fio ) to ( fr_data )
        Go Top
        j := 0
        Do While !Eof()
          frd->nomer := ++j
          Select FRT
          frt->nomer := frd->nomer
          For i := 1 To 5
            poled := 'frd->gd' + lstr( i )
            polet := 'frt->gd' + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          For i := 1 To 5
            poled := 'frd->g' + lstr( i )
            polet := 'frt->g' + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          If !Empty( frd->vperv )
            frt->vperv++
          Endif
          If !Empty( frd->dispans )
            frt->dispans++
          Endif
          If !Empty( frd->n1 )
            frt->n1++
          Endif
          If !Empty( frd->n2 )
            frt->n2++
          Endif
          If !Empty( frd->n3 )
            frt->n3++
          Endif
          If !Empty( frd->f1 )
            frt->f1++
          Endif
          If !Empty( frd->f3 )
            frt->f3++
          Endif
          If !Empty( frd->f4 )
            frt->f4++
          Endif
          If !Empty( frd->f5 )
            frt->f5++
          Endif
          Select FRD
          Skip
        Enddo
        If par2 == 2
          Select FRD
          Zap
        Endif
        Close databases
        call_fr( 'mo_ddsMZ', iif( par2 == 2, 3, ) )
      Endcase
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 09.11.25
Function f2_inf_dds_svod( Loc_kod, kod_kartotek ) // сводная информация

  Local i := 0, c, s := 'НЕТ акта', pole, arr, ddo := {}, dposle := {}

  r_use( dir_server() + 'mo_rak',, 'RAK' )
  r_use( dir_server() + 'mo_raks',, 'RAKS' )
  Set Relation To FIELD->akt into RAK
  r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
  Set Relation To FIELD->kod_raks into RAKS
  Set Index to ( cur_dir() + 'tmp_raksh' )
  Select RAKSH
  find ( Str( Loc_kod, 7 ) )
  Do While Loc_kod == raksh->kod_h .and. !Eof()
    If Round( raksh->sump, 2 ) == Round( mCENA_1, 2 )
      i := 1
      s := 'оплачен'
    Else
      i := 0
      s := 'НЕ опл.: акт ' + AllTrim( rak->NAKT ) + ' от ' + date_8( rak->DAKT )
    Endif
    Skip
  Enddo
  Use ( cur_dir() + 'tmpfio' ) New Alias TF
  tf->( dbAppend() )    //Append Blank
  tf->KOD := Loc_kod
  tf->KOD_K := kod_kartotek
  tf->FIO := mfio
  tf->DATE_R := mdate_r
  tf->N_DATA := mN_DATA
  tf->K_DATA := mK_DATA
  tf->sroki := Left( date_8( mN_DATA ), 5 ) + '-' + Left( date_8( mK_DATA ), 5 )
  tf->noplata := i
  tf->oplata := s
  tf->CENA_1 := mCENA_1
  tf->KOD_DIAG := mkod_diag
  tf->etap := metap
  tf->gruppa_do := mgruppa_do
  If Between( mgruppa_do, 1, 5 )
    pole := 'tf->gd' + lstr( mgruppa_do )
    &pole := 'X'
  Endif
  tf->gruppa := mgruppa
  If Between( mgruppa, 1, 5 )
    pole := 'tf->g' + lstr( mgruppa )
    &pole := 'X'
  Endif
  For i := 1 To 5
    pole := 'mdiag_16_' + lstr( i ) + '_1'
    If !Empty( &pole )
      AAdd( ddo, AllTrim( &pole ) )
    Endif
  Next
  For i := 1 To 5
    pole := 'mdiag_16_' + lstr( i ) + '_1'
    If !Empty( &pole )
      AAdd( dposle, AllTrim( &pole ) )
      pole := 'm1diag_16_' + lstr( i ) + '_2'
      if &pole == 1
        tf->vperv := 'X'
      Endif
      pole := 'm1diag_16_' + lstr( i ) + '_3'
      if &pole == 2
        tf->dispans := 'X'
      Endif
      pole := 'm1diag_16_' + lstr( i ) + '_13'
      if &pole == 1
        tf->n2 := 'X'
        pole := 'm1diag_16_' + lstr( i ) + '_15'
        if &pole == 4
          tf->n1 := 'X'
        Endif
      Endif
      pole := 'm1diag_16_' + lstr( i ) + '_16'
      if &pole == 1
        tf->n3 := 'X'
      Endif
    Endif
  Next
  For i := 1 To Len( ddo )
    c := Left( ddo[ i ], 3 )
    If Between( c, 'F00', 'F69' ) .or. Between( c, 'F80', 'F99' )
      tf->f3 := 'X'
    Endif
  Next
  For i := 1 To Len( dposle )
    If AScan( ddo, dposle[ i ] ) == 0
      tf->f1 := 'X'
    Endif
    c := Left( dposle[ i ], 3 )
    If Between( c, 'F00', 'F69' ) .or. Between( c, 'F80', 'F99' )
      tf->f4 := 'X'
    Endif
  Next
  If !Empty( tf->f3 ) .and. Empty( tf->f4 )
    tf->f5 := 'X'
  Endif
  arr := f4_inf_dds_karta( 1, 1 )
  For i := 1 To Len( arr )
    pole := 'tf->d1_' + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  tf->d1_zs := mshifr_zs
  arr := f4_inf_dds_karta( 1, 2, 1 ) // стоматолог и эндокринолог на 2 этапе
  For i := 1 To Len( arr )
    pole := 'tf->d1_' + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  arr := f4_inf_dds_karta( 1, 2, 2 ) // остальные приёмы на 2 этапе
  For i := 1 To Len( arr )
    pole := 'tf->d2_' + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  arr := f4_inf_dds_karta( 2 )
  For i := 1 To Len( arr )
    pole := 'tf->di_' + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next

  Return Nil

// 09.11.25 Приложение к письму КЗВО №14-05/50 от 07.02.2020г.
Function inf_dds_svod2( par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec
  local sh, n_file := cur_dir() + 'ddssvod2.txt'
  local s, ft, j

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        r_use( cur_dir() + 'tmp' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }

      Private arr_deti := { ;
        { '1', 'Всего', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
        { '1.1', '0-14 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
        { '1.2', '15-17 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        }
      Private arr_2510 := { ;
        { '001 дети 0-14 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '002 из них дети до 1 г.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '003 дети 15-17 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '004 15-17 лет - юноши', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '005 школьники', 0, 0, 0, 0, 0, 0, 0 };
        }

      sh := iif( par2 == 3, 92, 68 )
      Do While .t.
        // R_Use_base('human_u')
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        dbCloseAll()
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, 'f2_inf_DDS_svod2' )
      Enddo
      dbCloseAll()
      ft := tfiletext():new( n_file, sh, .t., , .t. )
      ft:add_string( glob_mo()[ _MO_SHORT_NAME ], FILE_LEFT, ' ' )
      ft:add_string( '' )
      If par2 == 3
        ft:add_string( 'Приложение', FILE_RIGHT, ' ' )
        ft:add_string( 'к письму КЗВО', FILE_RIGHT, ' ' )
        ft:add_string( '№14-05/50 от 07.02.2020г.', FILE_RIGHT )
      Endif
      ft:add_string( '' )
      ft:add_string( 'Сведения о диспансеризации несовершеннолетних,', FILE_CENTER, ' ' )
      If p_tip_lu == TIP_LU_DDS
        ft:add_string( 'пребывающих в стационарных условиях детей-сирот и детей,', FILE_CENTER, ' ' )
        ft:add_string( 'находящихся в трудной жизненной ситуации', FILE_CENTER, ' ' )
      Else
        ft:add_string( 'детей-сирот и детей, оставшихся без попечения родителей, в том числе', FILE_CENTER, ' ' )
        ft:add_string( 'усыновлённых (удочерённых), принятых под опеку (попечительство),', FILE_CENTER, ' ' )
        ft:add_string( 'в приёмную или патронатную семью', FILE_CENTER, ' ' )
      Endif
      ft:add_string( '[ ' + CharRem( '~', mas1pmt()[ is_schet ] ) + ' ]', FILE_CENTER, ' ' )
      ft:add_string( arr_m[ 4 ], FILE_CENTER, ' ' )
      ft:add_string( '' )
      If par2 == 3
        ft:add_string( '───┬──────────┬─────────────────┬─────┬───────────────────────────────────┬─────┬─────┬─────' )
        ft:add_string( '№№ │          │     Осмотрено   │неинф│           из них                  │Факто│взято│из 6г' )
        ft:add_string( 'пп │Показатель├─────┬─────┬─────┤забол├─────┬─────┬─────┬─────┬─────┬─────┤ры   ┤на ди│начат' )
        ft:add_string( '   │          │всего│андро│гинек│вперв│крово│ ЗНО │ко_мы│ глаз│эндок│пищев│риска│спанс│лечен' )
        ft:add_string( '───┼──────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────' )
        ft:add_string( ' 1 │    2     │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 │  14 │  15 ' )
        ft:add_string( '───┴──────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' )
        For i := 1 To 3
          s := PadR( arr_deti[ i, 1 ], 4 ) + PadR( arr_deti[ i, 2 ], 9 )
          s += put_val( arr_deti[ i, 3 ], 6 )
          s += put_val( arr_deti[ i, 16 ], 6 ) // андролог
          s += put_val( arr_deti[ i, 17 ], 6 ) // гинеколог
          s += put_val( arr_deti[ i, 7 ], 6 )
          s += put_val( arr_deti[ i, 8 ], 6 )
          s += put_val( arr_deti[ i, 9 ], 6 )
          s += put_val( arr_deti[ i, 21 ], 6 ) // кости- связки
          s += put_val( arr_deti[ i, 18 ], 6 ) // глаза
          s += put_val( arr_deti[ i, 19 ], 6 ) // эндокринка
          // s += put_val(arr_deti[i, 11], 6)
          s += put_val( arr_deti[ i, 12 ], 6 )
          s += put_val( arr_deti[ i, 20 ], 6 ) // факторы риска
          s += put_val( arr_deti[ i, 13 ], 6 )
          s += put_val( arr_deti[ i, 14 ], 6 )
          // for j := 3 to 15
          // s += put_val(arr_deti[i,j], 6)
          // next
          ft:add_string( s )
          ft:add_string( Replicate( '─', sh ) )
        Next
      Else
        ft:add_string( '─────────────────────────┬───────────┬─────────────────────────────' )
        ft:add_string( '                         │Число детей│     по группам здоровья     ' )
        ft:add_string( '     Дети - сироты       ├─────┬─────┼─────┬─────┬─────┬─────┬─────' )
        ft:add_string( '     таблица 2510        │всего│ село│  1  │  2  │  3  │  4  │  5  ' )
        ft:add_string( '─────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────' )
        ft:add_string( '                         │  5  │  6  │  7  │  8  │  9  │  12 │  13 ' )
        ft:add_string( '─────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' )
        For i := 1 To Len( arr_2510 )
          s := PadR( arr_2510[ i, 1 ], 25 )
          For j := 2 To Len( arr_2510[ i ] )
            s += put_val( arr_2510[ i, j ], 6 )
          Next
          ft:add_string( s )
        Next
      Endif
      ft := nil
      viewtext( n_file,,,, .t.,,, 2 )
    Endif
  Endif
  dbCloseAll()
  rest_box( buf )

  Return Nil

// 20.06.21
Function f2_inf_dds_svod2( Loc_kod, kod_kartotek, mvozrast )

  Local i, j, k, is_selo, ad := {}, ar := { 1 }, ar1 := {}
  local ar2 // := Array( Len( arr_deti[ 1 ] ) )

  ar2 := Array( Len( arr_deti[ 1 ] ) )
  If mvozrast < 15
    AAdd( ar, 2 )
  Else
    AAdd( ar, 3 )
  Endif
  //
  For i := 1 To 5
    j := 0
    For k := 1 To 3
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        If !Empty( &mvar )
          arr := { AllTrim( &mvar ), 0, 0 }
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next

  r_use( dir_server() + 'kartote2',, 'KART2' )
  Goto ( kod_kartotek )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  Goto ( kod_kartotek )

  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use_base( 'human_u' )
  // R_Use(dir_server() + 'human_',,'HUMAN_')
  r_use( dir_server() + 'human',, 'HUMAN' )
  // set relation to recno() into HUMAN_, to kod_k into KART_
  // use (cur_dir() + 'tmp') new
  // set relation to kod into HUMAN
  // go top

  r_use( dir_server() + 'kartotek',, 'KART' )
  Goto ( kod_kartotek )
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )
  If mvozrast == 0
    AAdd( ar1, 2 )
  Endif
  If mvozrast < 15
    AAdd( ar1, 1 )
  Else
    AAdd( ar1, 3 )
    If kart->pol == 'М'
      AAdd( ar1, 4 )
    Endif
  Endif
  If mvozrast > 6 // школьники ?
    AAdd( ar1, 5 )
  Endif
  //
  AFill( ar2, 0 )
  For i := 1 To Len( ad ) // цикл по диагнозам
    If !( Left( ad[ i, 1 ], 1 ) == 'A' .or. Left( ad[ i, 1 ], 1 ) == 'B' ) .and. ad[ i, 2 ] == 1 // неинфекционные заболевания уст.впервые
      // arr_deti[k, 7] ++
      ar2[ 7 ] := 1
      If Left( ad[ i, 1 ], 1 ) == 'I' // болезни системы кровообращения
        ar2[ 8 ] := 1     // arr_deti[k, 8] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == 'J' // болезни органов дыхания
        ar2[ 11 ] := 1      // arr_deti[k, 11] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == 'K' // болезни органов пищеварения
        ar2[ 12 ] := 1     // arr_deti[k, 12] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == 'H' // болезни глаз
        ar2[ 18 ] := 1    // arr_deti[k, 18] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == 'E' // болезни эндокринология
        ar2[ 19 ] := 1  // arr_deti[k, 19] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == 'M' // болезни костно-мышечной системы
        ar2[ 21 ] := 1  // arr_deti[k, 21] ++
      Endif
      //
      If Left( ad[ i, 1 ], 3 ) == 'E78'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'R73.9'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.0'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.4'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'R63.5'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.3'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.1'
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.2'
        ar2[ 20 ] := 1
      Endif
      //
      If Left( ad[ i, 1 ], 1 ) == 'C' .or. Between( Left( ad[ i, 1 ], 3 ), 'D00', 'D09' ) // ЗНО
        ar2[ 9 ] := 1  // arr_deti[k, 9] ++
      Endif
      If ad[ i, 3 ] > 0
        ar2[ 13 ] := 1  // arr_deti[k, 13] ++  // взяты на диспасерное наблюдение
      Endif
      If m1napr_stac > 0 // направлен на лечение
        ar2[ 14 ] := 1 // arr_deti[k, 14] ++ // считаем, что было начато лечение
        If is_selo
          ar2[ 15 ] := 1   // arr_deti[k, 15] ++
        Endif
      Endif
    Endif
  Next i
  // надо деффицит массы тела
  If m1fiz_razv1 == 1
    ar2[ 20 ] := 1
  Endif

  For j := 1 To 2
    k := ar[ j ]
    arr_deti[ k, 3 ] ++
    If DoW( mk_data ) == 7 // суббота
      arr_deti[ k, 4 ] ++
    Endif
    If is_selo
      arr_deti[ k, 5 ] ++
      If DoW( mk_data ) == 7 // суббота
        arr_deti[ k, 6 ] ++
      Endif
    Endif
    //
    For i := 7 To Len( ar2 )
      arr_deti[ k, i ] += ar2[ i ]
    Next
  Next
  //
  fl := .f.
  //
  //
  Select HU
  find ( Str( Loc_kod, 7 ) )
  Do While hu->kod == Loc_kod .and. !Eof()
    If eq_any( hu_->PROFIL, 19, 136 )
      fl := .t.
    Endif
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
      lshifr := usl->shifr
    Endif
    If Left( lshifr, 2 ) == '2.'  // врачебный приём
      If hu_->PROFIL == 19
        // ar2[16] := 1
        arr_deti[ k, 16 ] ++
      Endif
      If hu_->PROFIL == 136
        // ar2[17] := 1
        arr_deti[ k, 17 ] ++
      Endif
    Endif
    Select HU
    Skip
  Enddo
  //
  For j := 1 To Len( ar1 )
    k := ar1[ j ]
    arr_2510[ k, 2 ] ++
    If is_selo
      arr_2510[ k, 3 ] ++
    Endif
    If Between( mgruppa, 1, 5 )
      arr_2510[ k, 3 + mgruppa ] ++
    Endif
  Next

  Return Nil

// 09.11.25
Function inf_dds_030dso( is_schet )

  Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec
  local sh := 80, HH := 80, n_file := cur_dir() + 'f_030dso.txt', d1, d2
  local arr1title, arr2title, arr3title, arr4title
  local s, s1, k

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti[ 5 ]
      Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
      Private arr_vozrast := { ;
        { 4, 0, 4 }, ;
        { 5, 5, 9 }, ;
        { 6, 10, 14 }, ;
        { 7, 15, 17 }, ;
        { 8, 0, 14 }, ;
        { 9, 0, 17 };
        }
      Private arr1vozrast := { ;
        { 0, 17 }, ;
        { 0, 14 }, ;
        { 0, 4 }, ;
        { 5, 9 }, ;
        { 10, 14 }, ;
        { 15, 17 };
        }
      Private arr_4 := { ;
        { '1', 'Некоторые инфекционные и паразит...', 'A00-B99',, }, ;
        { '1.1', 'туберкулез', 'A15-A19',, }, ;
        { '1.2', 'ВИЧ-инфекция, СПИД', 'B20-B24',, }, ;
        { '2', 'Новообразования', 'C00-D48',, }, ;
        { '3', 'Болезни крови и кроветворных органов ...', 'D50-D89',, }, ;
        { '3.1', 'анемии', 'D50-D53',, }, ;
        { '4', 'Болезни эндокринной системы, расстройства...', 'E00-E90',, }, ;
        { '4.1', 'сахарный диабет', 'E10-E14',, }, ;
        { '4.2', 'недостаточность питания', 'E40-E46',, }, ;
        { '4.3', 'ожирение', 'E66',, }, ;
        { '4.4', 'задержка полового развития', 'E30.0',, }, ;
        { '4.5', 'преждевременное половое развитие', 'E30.1',, }, ;
        { '5', 'Психические расстройства и расстро...', 'F00-F99',, }, ;
        { '5.1', 'умственная отсталость', 'F70-F79',, }, ;
        { '6', 'Болезни нервной системы, из них:', 'G00-G98',, }, ;
        { '6.1', 'церебральный паралич и другие ...', 'G80-G83',, }, ;
        { '7', 'Болезни глаза и его придаточного аппарата', 'H00-H59',, }, ;
        { '8', 'Болезни уха и сосцевидного отростка', 'H60-H95',, }, ;
        { '9', 'Болезни системы кровообращения', 'I00-I99',, }, ;
        { '10', 'Болезни органов дыхания, из них:', 'J00-J99',, }, ;
        { '10.1', 'астма, астматический статус', 'J45-J46',, }, ;
        { '11', 'Болезни органов пищеварения', 'K00-K93',, }, ;
        { '12', 'Болезни кожи и подкожной клетчатки', 'L00-L99',, }, ;
        { '13', 'Болезни костно-мышечной ...', 'M00-M99',, }, ;
        { '13.1', 'кифоз, лордоз, сколиоз', 'M40-M41',, }, ;
        { '14', 'Болезни мочеполовой системы, из них:', 'N00-N99',, }, ;
        { '14.1', 'болезни мужских половых органов', 'N40-N51',, }, ;
        { '14.2', 'нарушения ритма и характера менструаций', 'N91-N94.5',, }, ;
        { '14.3', 'воспалительные заболевания ...', 'N70-N77',, }, ;
        { '14.4', 'невоспалительные болезни ...', 'N83-N83.9',, }, ;
        { '14.5', 'болезни молочной железы', 'N60-N64',, }, ;
        { '15', 'Отдельные состояния, возника...', 'P00-P96',, }, ;
        { '16', 'Врожденные аномалии (пороки ...', 'Q00-Q99',, }, ;
        { '16.1', 'развития нервной системы', 'Q00-Q07',, }, ;
        { '16.2', 'системы кровообращения', 'Q20-Q28',, }, ;
        { '16.3', 'костно-мышечной системы', 'Q65-Q79',, }, ;
        { '16.4', 'женских половых органов', 'Q50-Q52',, }, ;
        { '16.5', 'мужских половых органов', 'Q53-Q55',, }, ;
        { '17', 'Травмы, отравления и некоторые...', 'S00-T98',, }, ;
        { '18', 'Прочие', '',, }, ;
        { '19', 'ВСЕГО ЗАБОЛЕВАНИЙ', 'A00-T98',, };
      }

      AFill( arr_deti, 0 )
      For n := 1 To Len( arr_4 )
        If '-' $ arr_4[ n, 3 ]
          d1 := Token( arr_4[ n, 3 ], '-', 1 )
          d2 := Token( arr_4[ n, 3 ], '-', 2 )
        Else
          d1 := d2 := arr_4[ n, 3 ]
        Endif
        arr_4[ n, 4 ] := diag_to_num( d1, 1 )
        arr_4[ n, 5 ] := diag_to_num( d2, 2 )
      Next
      dbCreate( cur_dir() + 'tmp4', { ;
        { 'name', 'C', 100, 0 }, ;
        { 'diagnoz', 'C', 20, 0 }, ;
        { 'stroke', 'C', 4, 0 }, ;
        { 'ns', 'N', 2, 0 }, ;
        { 'diapazon1', 'N', 10, 0 }, ;
        { 'diapazon2', 'N', 10, 0 }, ;
        { 'tbl', 'N', 1, 0 }, ;
        { 'k04', 'N', 8, 0 }, ;
        { 'k05', 'N', 8, 0 }, ;
        { 'k06', 'N', 8, 0 }, ;
        { 'k07', 'N', 8, 0 }, ;
        { 'k08', 'N', 8, 0 }, ;
        { 'k09', 'N', 8, 0 }, ;
        { 'k10', 'N', 8, 0 }, ;
        { 'k11', 'N', 8, 0 } ;
      } )
      Use ( cur_dir() + 'tmp4' ) New Alias TMP
      For i := 1 To Len( arr_vozrast )
        For n := 1 To Len( arr_4 )
          tmp->( dbAppend() )   //  Append Blank
          tmp->tbl := arr_vozrast[ i, 1 ]
          tmp->stroke := arr_4[ n, 1 ]
          tmp->name := arr_4[ n, 2 ]
          tmp->ns := n
          tmp->diagnoz := arr_4[ n, 3 ]
          tmp->diapazon1 := arr_4[ n, 4 ]
          tmp->diapazon2 := arr_4[ n, 5 ]
        Next
      Next
      Index On Str( FIELD->tbl, 1 ) + Str( FIELD->ns, 2 ) to ( cur_dir() + 'tmp4' )
      Use
      dbCreate( cur_dir() + 'tmp10', { ;
        { 'voz', 'N', 1, 0 }, ;
        { 'tbl', 'N', 2, 0 }, ;
        { 'tip', 'N', 1, 0 }, ;
        { 'kol', 'N', 6, 0 } ;
      } )
      Use ( cur_dir() + 'tmp10' ) New Alias TMP10
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->tbl, 1 ) + Str( FIELD->tip, 1 ) to ( cur_dir() + 'tmp10' )
      Use
      Copy file tmp10.dbf To tmp11.dbf
      Use ( cur_dir() + 'tmp11' ) New Alias TMP11
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->tbl, 2 ) + Str( FIELD->tip, 1 ) to ( cur_dir() + 'tmp11' )
      Use
      dbCreate( cur_dir() + 'tmp13', { ;
        { 'voz', 'N', 1, 0 }, ;
        { 'tip', 'N', 2, 0 }, ;
        { 'kol', 'N', 6, 0 } ;
      } )
      Use ( cur_dir() + 'tmp13' ) New Alias TMP13
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->tip, 2 ) to ( cur_dir() + 'tmp13' )
      Use
      dbCreate( cur_dir() + 'tmp16', { ;
        { 'voz', 'N', 1, 0 }, ;
        { 'man', 'N', 1, 0 }, ;
        { 'tip', 'N', 2, 0 }, ;
        { 'kol', 'N', 6, 0 } ;
      } )
      Use ( cur_dir() + 'tmp16' ) New Alias TMP16
      Index On Str( FIELD->voz, 1 ) + Str( FIELD->man, 1 ) + Str( FIELD->tip, 2 ) to ( cur_dir() + 'tmp16' )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        r_use( cur_dir() + 'tmp' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      Do While .t.
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, 'f2_inf_DDS_030dso' )
      Enddo
      Close databases
      fp := FCreate( n_file )
      n_list := 1
      tek_stroke := 0
      add_string( glob_mo()[ _MO_SHORT_NAME ] )
      add_string( PadL( 'Приложение 3', sh ) )
      add_string( PadL( 'к Приказу МЗРФ', sh ) )
      add_string( PadL( '№72н от 15.02.2013г.', sh ) )
      add_string( '' )
      add_string( PadL( 'Отчетная форма № 030-Д/с/о-13', sh ) )
      add_string( '' )
      add_string( Center( 'Сведения о диспансеризации несовершеннолетних,', sh ) )
      If p_tip_lu == TIP_LU_DDS
        add_string( Center( 'пребывающих в стационарных условиях детей-сирот и детей,', sh ) )
        add_string( Center( 'находящихся в трудной жизненной ситуации', sh ) )
      Else
        add_string( Center( 'детей-сирот и детей, оставшихся без попечения родителей, в том числе', sh ) )
        add_string( Center( 'усыновлённых (удочерённых), принятых под опеку (попечительство),', sh ) )
        add_string( Center( 'в приёмную или патронатную семью', sh ) )
      Endif
      add_string( Center( '[ ' + CharRem( '~', mas1pmt()[ is_schet ] ) + ' ]', sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( '' )
      add_string( '2. Число детей, прошедших диспансеризацию в отчетном периоде:' )
      add_string( '  2.1. всего в возрасте от 0 до 17 лет включительно:' + Str( arr_deti[ 1 ], 6 ) + ' (человек), из них:' )
      add_string( '  2.1.1. в возрасте от 0 до 4 лет включительно      ' + Str( arr_deti[ 2 ], 6 ) + ' (человек),' )
      add_string( '  2.1.2. в возрасте от 5 до 9 лет включительно      ' + Str( arr_deti[ 3 ], 6 ) + ' (человек),' )
      add_string( '  2.1.3. в возрасте от 10 до 14 лет включительно    ' + Str( arr_deti[ 4 ], 6 ) + ' (человек),' )
      add_string( '  2.1.4. в возрасте от 15 до 17 лет включительно    ' + Str( arr_deti[ 5 ], 6 ) + ' (человек).' )
      For i := 1 To Len( arr_vozrast )
        verify_ff( HH -50, .t., sh )
        add_string( '' )
        add_string( Center( lstr( arr_vozrast[ i, 1 ] ) + ;
          '. Структура выявленных заболеваниях (сосотояний) у детей в возрасте от ' + ;
          lstr( arr_vozrast[ i, 2 ] ) + ' до ' + lstr( arr_vozrast[ i, 3 ] ) + ' лет включительно', sh ) )
        add_string( '────┬───────────────────┬───────┬─────┬─────┬─────┬─────┬───────────────────────' )
        add_string( ' №№ │    Наименование   │ Код по│Всего│в т.ч│выяв-│в т.ч│Состоит под дисп.наблюд' )
        add_string( ' пп │    заболеваний    │ МКБ-10│зарег│маль-│лено │маль-├─────┬─────┬─────┬─────' )
        add_string( '    │                   │       │забол│чики │вперв│чики │всего│мальч│взято│мальч' )
        add_string( '────┼───────────────────┼───────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────' )
        add_string( ' 1  │          2        │   3   │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  ' )
        add_string( '────┴───────────────────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' )
        Use ( cur_dir() + 'tmp4' ) index ( cur_dir() + 'tmp4' ) New Alias TMP
        find ( Str( arr_vozrast[ i, 1 ], 1 ) )
        Do While tmp->tbl == arr_vozrast[ i, 1 ] .and. !Eof()
          s := tmp->stroke + ' ' + PadR( tmp->name, 19 ) + ' ' + PadC( AllTrim( tmp->diagnoz ), 7 )
          For n := 4 To 11
            s += put_val( tmp->&( 'k' + StrZero( n, 2 ) ), 6 )
          Next
          add_string( s )
          Skip
        Enddo
        Use
        add_string( Replicate( '─', sh ) )
      Next
      arr1title := { ;
        '────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        '                    │   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных ', ;
        '  Возраст детей     │           │           │субъекта РФ│  ных ГУЗ  │    МО     ', ;
        '                    │           │           │           │           │           ', ;
        '────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────', ;
        '          1         │     2     │     3     │     4     │     5     │     6     ', ;
        '────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────' }
      arr2title := { ;
        '────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        '                    │   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных ', ;
        '  Возраст детей     ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────', ;
        '                    │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ', ;
        '────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '          1         │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 ', ;
        '────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      arr3title := { ;
        '────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        ' Возраст│   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных │в санаторно', ;
        ' детей  │           │           │субъекта РФ│  ных ГУЗ  │    МО     │-курортных ', ;
        '        │           │           │           │           │           │организ-ях ', ;
        '────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────', ;
        '    1   │     2     │     3     │     4     │     5     │     6     │     7     ', ;
        '────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────' }
      arr4title := { ;
        '────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────', ;
        ' Возраст│   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных │в сан.-кур.', ;
        ' детей  ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────┼──орг-иях──', ;
        '        │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ', ;
        '────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────', ;
        '    1   │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ', ;
        '────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' }
      verify_ff( HH -50, .t., sh )
      add_string( '10. Результаты дополнительных консультаций, исследований, лечения и медицинской' )
      add_string( '    реабилитации детей по результатам проведения настоящей диспансеризации:' )
      Use ( cur_dir() + 'tmp10' ) index ( cur_dir() + 'tmp10' ) New Alias TMP10
      For i := 1 To 8
        verify_ff( HH -16, .t., sh )
        add_string( '' )
        s := Space( 5 )
        If i == 1
          add_string( s + '10.1. Нуждались в дополнительных консультациях и исследованиях' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Elseif i == 2
          add_string( s + '10.2. Прошли дополнительные консультации и исследования' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Elseif i == 3
          add_string( s + '10.3. Нуждались в дополнительных консультациях и исследованиях' )
          add_string( s + '      в стационарных условиях' )
        Elseif i == 4
          add_string( s + '10.4. Прошли дополнительные консультации и исследования' )
          add_string( s + '      в стационарных условиях' )
        Elseif i == 5
          add_string( s + '10.5. Рекомендовано лечение в амбулаторных условиях и в условиях' )
          add_string( s + '      дневного стационара' )
        Elseif i == 6
          add_string( s + '10.6. Рекомендовано лечение в стационарных условиях' )
        Elseif i == 7
          add_string( s + '10.7. Рекомендована медицинская реабилитация' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Else
          add_string( s + '10.8. Рекомендованы медицинская реабилитация и (или)' )
          add_string( s + '      санаторно-курортное лечение в стационарных условиях' )
        Endif
        n := 20
        If eq_any( i, 1, 3, 5, 6, 7 )
          AEval( arr1title, {| x| add_string( x ) } )
        Elseif eq_any( i, 2, 4 )
          AEval( arr2title, {| x| add_string( x ) } )
        Else
          AEval( arr3title, {| x| add_string( x ) } )
          n := 8
        Endif
        For j := 1 To Len( arr1vozrast )
          s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
          skol := oldkol := 0
          s1 := ''
          For k := 1 To iif( i == 8, 5, 4 )
            find ( Str( j, 1 ) + Str( i, 1 ) + Str( k, 1 ) )
            If Found() .and. ( v := tmp10->kol ) > 0
              skol += v
              If eq_any( i, 2, 4 )
                s1 += Str( v, 6 )
                find ( Str( j, 1 ) + Str( i -1, 1 ) + Str( k, 1 ) )
                If Found() .and. tmp10->kol > 0
                  s1 += ' ' + umest_val( v / tmp10->kol * 100, 5, 2 )
                  oldkol += tmp10->kol
                Else
                  s1 += Space( 6 )
                Endif
              Else
                s1 += ' ' + PadC( lstr( v ), 11 )
              Endif
            Else
              s1 += Space( 12 )
            Endif
          Next
          If skol > 0
            If eq_any( i, 2, 4 )
              s += Str( skol, 6 ) + ' ' + umest_val( skol / oldkol * 100, 5, 2 )
            Else
              s += ' ' + PadC( lstr( skol ), 11 )
            Endif
            add_string( s + s1 )
          Else
            add_string( s )
          Endif
        Next
        add_string( Replicate( '─', sh ) )
      Next
      Use
      //
      verify_ff( HH -50, .t., sh )
      add_string( '11. Результаты лечения, медицинской реабилитации и (или) санаторно-курортного' )
      add_string( '    лечения детей до проведения настоящей диспансеризации:' )
      vkol := 0
      Use ( cur_dir() + 'tmp11' ) index ( cur_dir() + 'tmp11' ) New Alias TMP11
      For i := 1 To 12
        If i % 3 > 0
          verify_ff( HH -16, .t., sh )
          add_string( '' )
        Endif
        s := Space( 5 )
        If i == 1
          add_string( s + '11.1. Рекомендовано лечение в амбулаторных условиях и в условиях' )
          add_string( s + '      дневного стационара' )
        Elseif i == 2
          add_string( s + '11.2. Проведено лечение в амбулаторных условиях и в условиях' )
          add_string( s + '      дневного стационара' )
        Elseif i == 3
          add_string( s + '11.3. Причины невыполнения рекомендаций по лечению в амбулаторных условиях' )
          add_string( s + '      и в условиях дневного стационара:' )
          add_string( s + '        11.3.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Elseif i == 4
          add_string( s + '11.4. Рекомендовано лечение в стационарных условиях' )
        Elseif i == 5
          add_string( s + '11.5. Проведено лечение в стационарных условиях' )
        Elseif i == 6
          add_string( s + '11.6. Причины невыполнения рекомендаций по лечению в стационарных условиях:' )
          add_string( s + '        11.6.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Elseif i == 7
          add_string( s + '11.7. Рекомендована медицинская реабилитация' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Elseif i == 8
          add_string( s + '11.8. Проведена медицинская реабилитация' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара' )
        Elseif i == 9
          add_string( s + '11.9. Причины невыполнения рекомендаций по медицинской реабилитации' )
          add_string( s + '      в амбулаторных условиях и в условиях дневного стационара:' )
          add_string( s + '        11.9.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Elseif i == 10
          add_string( s + '11.10. Рекомендованы медицинская реабилитация и (или)' )
          add_string( s + '       санаторно-курортное лечение в стационарных условиях' )
        Elseif i == 11
          add_string( s + '11.11. Проведена медицинская реабилитация и (или)' )
          add_string( s + '       санаторно-курортное лечение в стационарных условиях' )
        Else
          add_string( s + '11.12. Причины невыполнения рекомендаций по медицинской реабилитации' )
          add_string( s + '       и (или) санаторно-курортному лечению в стационарных условиях:' )
          add_string( s + '         11.12.1. не прошли всего ' + lstr( vkol ) + ' (человек)' )
        Endif
        If i % 3 > 0
          n := 20
          If eq_any( i, 1, 4, 7 )
            AEval( arr1title, {| x| add_string( x ) } )
          Elseif eq_any( i, 2, 5, 8 )
            AEval( arr2title, {| x| add_string( x ) } )
          Elseif i == 10
            AEval( arr3title, {| x| add_string( x ) } )
            n := 8
          Elseif i == 11
            AEval( arr4title, {| x| add_string( x ) } )
            n := 8
          Endif
          For j := 1 To Len( arr1vozrast )
            s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
            skol := oldkol := 0
            s1 := ''
            For k := 1 To iif( i > 10, 5, 4 )
              find ( Str( j, 1 ) + Str( i, 2 ) + Str( k, 1 ) )
              If Found() .and. ( v := tmp11->kol ) > 0
                skol += v
                If eq_any( i, 2, 5, 8, 11 )
                  s1 += Str( v, 6 )
                  find ( Str( j, 1 ) + Str( i -1, 2 ) + Str( k, 1 ) )
                  If Found() .and. tmp11->kol > 0
                    s1 += ' ' + umest_val( v / tmp11->kol * 100, 5, 2 )
                    oldkol += tmp11->kol
                  Else
                    s1 += Space( 6 )
                  Endif
                Else
                  s1 += ' ' + PadC( lstr( v ), 11 )
                Endif
              Else
                s1 += Space( 12 )
              Endif
            Next
            If eq_any( i, 2, 5, 8, 11 )
              vkol := oldkol - skol
            Endif
            If skol > 0
              If eq_any( i, 2, 5, 8, 11 )
                s += Str( skol, 6 ) + ' ' + umest_val( skol / oldkol * 100, 5, 2 )
              Else
                s += ' ' + PadC( lstr( skol ), 11 )
              Endif
              add_string( s + s1 )
            Else
              add_string( s )
            Endif
          Next
          add_string( Replicate( '─', sh ) )
        Endif
      Next
      Use
      verify_ff( HH -3, .t., sh )
      add_string( '' )
      add_string( '12. Оказание высокотехнологичной медицинской помощи:' )
      add_string( '  12.1. рекомендована (по итогам настоящей диспанc-ции): ' + lstr( s12_1 ) + ' чел., в т.ч. ' + lstr( s12_1m ) + ' мальчикам' )
      add_string( '  12.2. оказана (по итогам диспансеризации в пред.году): ' + lstr( s12_2 ) + ' чел., в т.ч. ' + lstr( s12_2m ) + ' мальчикам' )
      Use ( cur_dir() + 'tmp13' ) index ( cur_dir() + 'tmp13' ) New Alias TMP13
      verify_ff( HH -16, .t., sh )
      n := 32
      add_string( '' )
      add_string( '13. Число детей-инвалидов из числа детей, прошедших диспансеризацию' )
      add_string( '    в отчетном периоде' )
      add_string( '────────────────────────────────┬───────────┬───────────┬───────────┬─────┬─────' )
      add_string( '                                │ с рождения│приобретённ│уст.впервые│ чел.│  %  ' )
      add_string( '         Возраст детей          ├─────┬─────┼─────┬─────┼─────┬─────┤детей│детей' )
      add_string( '                                │ чел.│  %  │ чел.│  %  │ чел.│  %  │инвал│инвал' )
      add_string( '────────────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────' )
      add_string( '               1                │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  ' )
      add_string( '────────────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 0, 2 ) )
        oldkol := iif( Found(), tmp13->kol, 0 )
        For i := 1 To 4
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += Str( tmp13->kol, 6 ) + ' ' + umest_val( tmp13->kol / oldkol * 100, 5, 2 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( '─', sh ) )
      verify_ff( HH -16, .t., sh )
      n := 26
      add_string( '' )
      add_string( '14. Выполнение индивидуальных программ реабилитации (ИПР) детей-инвалидов' )
      add_string( '    в отчетном периоде' )
      add_string( '──────────────────────────┬─────┬───────────┬───────────┬───────────┬───────────' )
      add_string( '                          │назна│вып.полност│вып.частичн│ ИПР начата│не выполнен' )
      add_string( '       Возраст детей      │чено ├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────' )
      add_string( '                          │ чел.│ чел.│  %  │ чел.│  %  │ чел.│  %  │ чел.│  %  ' )
      add_string( '──────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────' )
      add_string( '             1            │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 ' )
      add_string( '──────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────' )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 10, 2 ) )
        oldkol := 0
        If Found()
          oldkol := tmp13->kol
        Endif
        s += put_val( oldkol, 6 )
        For i := 11 To 14
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += Str( tmp13->kol, 6 ) + ' ' + umest_val( tmp13->kol / oldkol * 100, 5, 2 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( '─', sh ) )
      verify_ff( HH -15, .t., sh )
      n := 20
      add_string( '' )
      add_string( '15. Охват профилактическими прививками в отчетном периоде' )
      add_string( '────────────────────┬───────────┬───────────────────────┬───────────────────────' )
      add_string( '                    │  Привито  │Не привиты по мед.показ│Не привиты по друг.прич' )
      add_string( '    Возраст детей   │    чел.   ├───────────┬───────────┼───────────┬───────────' )
      add_string( '                    │           │ полностью │ частично  │ полностью │ частично  ' )
      add_string( '────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────' )
      add_string( '          1         │     2     │     3     │     4     │     5     │     6     ' )
      add_string( '────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────' )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 20, 2 ) )
        If Found()
          s += ' ' + PadC( lstr( tmp13->kol ), 11 )
        Else
          s += Space( 12 )
        Endif
        For i := 21 To 24
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += ' ' + PadC( lstr( tmp13->kol ), 11 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( '─', sh ) )
      Use ( cur_dir() + 'tmp16' ) index ( cur_dir() + 'tmp16' ) New Alias TMP16
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( '' )
      add_string( '16. Распределение детей по уровню физического развития' )
      add_string( '────────────────────┬─────────┬─────────┬───────────────────────────────────────' )
      add_string( '                    │Число про│Норм.физ.│ Отклонения физического развития (чел.)' )
      add_string( '    Возраст детей   │шедших ди│развитие ├─────────┬─────────┬─────────┬─────────' )
      add_string( '                    │спансериз│   чел.  │дефиц.мас│избыт.мас│низк.рост│высо.рост' )
      add_string( '────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────' )
      add_string( '          1         │    2    │    3    │    4    │    5    │    6    │    7    ' )
      add_string( '────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────' )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( ' ' + lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, '', ' (мальчики)' ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += ' ' + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 1 To 5
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            If Found()
              s += ' ' + PadC( lstr( tmp16->kol ), 9 )
            Else
              s += Space( 10 )
            Endif
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( '─', sh ) )
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( '' )
      add_string( '17. Распределение детей по группам состояния здоровья' )
      add_string( '────────────────────┬─────────┬────────────────────────┬────────────────────────' )
      add_string( '                    │Число про│ до диспансеризации     │ по результатам дисп-ии ' )
      add_string( '    Возраст детей   │шедших ди├────┬────┬────┬────┬────┼────┬────┬────┬────┬────' )
      add_string( '                    │спансериз│ I  │ II │ III│ IV │ V  │ I  │ II │ III│ IV │ V  ' )
      add_string( '────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────' )
      add_string( '          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 ' )
      add_string( '────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────' )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( ' ' + lstr( arr1vozrast[ j, 1 ] ) + ' - ' + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, '', ' (мальчики)' ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += ' ' + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 11 To 15
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 21 To 25
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( '─', sh ) )
      FClose( fp )
      viewtext( n_file,,,, .f.,,, 5 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 08.11.13
Function f2_inf_dds_030dso( Loc_kod, kod_kartotek ) // сводная информация

  Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
    is_man := ( mpol == 'М' ), blk_tbl, blk_tip, blk_put_tip, ;
    a10[ 9 ], a11[ 13 ]

  blk_tbl := {| _k| iif( _k < 2, 1, 2 ) }
  blk_tip := {| _k| iif( _k == 0, 2, iif( _k > 1, _k + 1, _k ) ) }
  blk_put_tip := {| _e, _k| iif( _k > _e, _k, _e ) }
  arr_deti[ 1 ] ++
  If mvozrast < 5
    arr_deti[ 2 ] ++
  Elseif mvozrast < 10
    arr_deti[ 3 ] ++
  Elseif mvozrast < 15
    arr_deti[ 4 ] ++
  Else
    arr_deti[ 5 ] ++
  Endif
  For i := 1 To Len( arr_vozrast )
    If Between( mvozrast, arr_vozrast[ i, 2 ], arr_vozrast[ i, 3 ] )
      AAdd( av, arr_vozrast[ i, 1 ] ) // список таблиц с 4 по 9
    Endif
  Next
  For i := 1 To Len( arr1vozrast )
    If Between( mvozrast, arr1vozrast[ i, 1 ], arr1vozrast[ i, 2 ] )
      AAdd( av1, i )
    Endif
  Next
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  Use ( cur_dir() + 'tmp4' ) index ( cur_dir() + 'tmp4' ) New Alias TMP
  Use ( cur_dir() + 'tmp10' ) index ( cur_dir() + 'tmp10' ) New Alias TMP10
  AFill( a10, 0 )
  For i := 1 To Len( ad ) // цикл по диагнозам
    au := {}
    d := diag_to_num( ad[ i, 1 ], 1 )
    For n := 1 To Len( arr_4 )
      If !Empty( arr_4[ n, 3 ] ) .and. Between( d, arr_4[ n, 4 ], arr_4[ n, 5 ] )
        AAdd( au, n )
      Endif
    Next
    If Len( au ) == 1
      AAdd( au, Len( arr_4 ) -1 )  // {'18','Прочие','',,}, ;
    Endif
    Select TMP
    For n := 1 To Len( av ) // цикл по списку таблиц с 4 по 9
      For j := 1 To Len( au )
        find ( Str( av[ n ], 1 ) + Str( au[ j ], 2 ) )
        If Found()
          tmp->k04++
          If is_man
            tmp->k05++
          Endif
          If ad[ i, 2 ] > 0 // уст.впервые
            tmp->k06++
            If is_man
              tmp->k07++
            Endif
          Endif
          If ad[ i, 3 ] > 0 // дисп.набл.установлено
            tmp->k08++
            If is_man
              tmp->k09++
            Endif
            If ad[ i, 3 ] == 2 // дисп.набл.установлено впервые
              tmp->k10++
              If is_man
                tmp->k11++
              Endif
            Endif
          Endif
        Endif
      Next
    Next
    If ad[ i, 4 ] == 1 // 1-доп.конс.назначены
      ntbl := Eval( blk_tbl, ad[ i, 5 ] )
      ntip := Eval( blk_tip, ad[ i, 6 ] )
      If ntbl == 1 .and. a10[ 3 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a10[ 1 ] := 0
        a10[ 3 ] := Eval( blk_put_tip, a10[ 3 ], ntip )
      Else
        a10[ 1 ] := Eval( blk_put_tip, a10[ 1 ], ntip )
        a10[ 3 ] := 0
      Endif
    Endif
    If ad[ i, 7 ] == 1 // 1-доп.конс.выполнены
      ntbl := Eval( blk_tbl, ad[ i, 8 ] )
      ntip := Eval( blk_tip, ad[ i, 9 ] )
      If ntbl == 1 .and. a10[ 4 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a10[ 2 ] := 0
        a10[ 4 ] := Eval( blk_put_tip, a10[ 4 ], ntip )
      Else
        a10[ 2 ] := Eval( blk_put_tip, a10[ 2 ], ntip )
        a10[ 4 ] := 0
      Endif
    Endif
    If ad[ i, 10 ] == 1 // 1-лечение назначено
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a10[ 6 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a10[ 5 ] := 0
        a10[ 6 ] := Eval( blk_put_tip, a10[ 6 ], ntip )
      Else
        a10[ 5 ] := Eval( blk_put_tip, a10[ 5 ], ntip )
        a10[ 6 ] := 0
      Endif
    Endif
    If ad[ i, 13 ] == 1 // 1-реабил.назначена
      ntbl := Eval( blk_tbl, ad[ i, 14 ] )
      ntip := Eval( blk_tip, ad[ i, 15 ] )
      If ntbl == 1 .and. a10[ 8 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2 .or. ntip == 5 // или санаторий
        a10[ 7 ] := 0
        a10[ 8 ] := Eval( blk_put_tip, a10[ 8 ], ntip )
      Else
        a10[ 7 ] := Eval( blk_put_tip, a10[ 7 ], ntip )
        a10[ 8 ] := 0
      Endif
    Endif
    If ad[ i, 16 ] == 1 // 1-ВМП назначена
      a10[ 9 ] := 1
    Endif
  Next
  Select TMP10
  For n := 1 To Len( av1 ) // цикл по возрастам таблиц 10
    For j := 1 To Len( a10 ) -1
      If a10[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 1 ) + Str( a10[ j ], 1 ) )
        If !Found()
          Append Blank
          tmp10->voz := av1[ n ]
          tmp10->tbl := j
          tmp10->tip := a10[ j ]
        Endif
        tmp10->kol++
      Endif
    Next
  Next
  ad := {}
  For i := 1 To 5
    j := 0
    For k := 1 To 14
      s := 'diag_15_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 14 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  Use ( cur_dir() + 'tmp11' ) index ( cur_dir() + 'tmp11' ) New Alias TMP11
  AFill( a11, 0 )
  For i := 1 To Len( ad ) // цикл по диагнозам
    If ad[ i, 3 ] == 1 // 1-лечение назначено
      ntbl := Eval( blk_tbl, ad[ i, 4 ] )
      ntip := Eval( blk_tip, ad[ i, 5 ] )
      If ntbl == 1 .and. a11[ 4 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a11[ 1 ] := 0
        a11[ 4 ] := Eval( blk_put_tip, a11[ 4 ], ntip )
      Else
        a11[ 1 ] := Eval( blk_put_tip, a11[ 1 ], ntip )
        a11[ 4 ] := 0
      Endif
      // лечение выполнено
      ntbl := Eval( blk_tbl, ad[ i, 6 ] )
      ntip := Eval( blk_tip, ad[ i, 7 ] )
      If ntbl == 1 .and. a11[ 5 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a11[ 2 ] := 0
        a11[ 5 ] := Eval( blk_put_tip, a11[ 5 ], ntip )
      Else
        a11[ 2 ] := Eval( blk_put_tip, a11[ 2 ], ntip )
        a11[ 5 ] := 0
      Endif
    Endif
    If ad[ i, 8 ] == 1 // 1-реабил.назначена
      ntbl := Eval( blk_tbl, ad[ i, 9 ] )
      ntip := Eval( blk_tip, ad[ i, 10 ] )
      If ntbl == 1 .and. a11[ 10 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2
        a11[ 7 ] := 0
        a11[ 10 ] := Eval( blk_put_tip, a11[ 10 ], ntip )
      Else
        a11[ 7 ] := Eval( blk_put_tip, a11[ 7 ], ntip )
        a11[ 10 ] := 0
      Endif
      // 1-реабил.выполнена
      ntbl := Eval( blk_tbl, ad[ i, 11 ] )
      ntip := Eval( blk_tip, ad[ i, 12 ] )
      If ntbl == 1 .and. a11[ 11 ] > 0 // уже есть стационар
        //
      Elseif ntbl == 2 .or. ntip == 5 // или санаторий
        a11[ 8 ] := 0
        a11[ 11 ] := Eval( blk_put_tip, a11[ 11 ], ntip )
      Else
        a11[ 8 ] := Eval( blk_put_tip, a11[ 8 ], ntip )
        a11[ 11 ] := 0
      Endif
    Endif
    If ad[ i, 14 ] == 1 // 1-ВМП проведена
      a11[ 13 ] := 1
    Endif
  Next
  Select TMP11
  For n := 1 To Len( av1 ) // цикл по возрастам таблиц 10
    For j := 1 To Len( a11 ) -1
      If a11[ j ] > 0
        find ( Str( av1[ n ], 1 ) + Str( j, 2 ) + Str( a11[ j ], 1 ) )
        If !Found()
          Append Blank
          tmp11->voz := av1[ n ]
          tmp11->tbl := j
          tmp11->tip := a11[ j ]
        Endif
        tmp11->kol++
      Endif
    Next
  Next
  If a10[ 9 ] > 0
    s12_1++
    If is_man
      s12_1m++
    Endif
  Endif
  If a11[ 13 ] > 0
    s12_2++
    If is_man
      s12_2m++
    Endif
  Endif
  ad := { 0 }
  If m1invalid1 == 1 // инвалидность-да
    AAdd( ad, 4 )
    If m1invalid2 == 0 // с рождения
      AAdd( ad, 1 )
    Else               // приобретенная
      AAdd( ad, 2 )
      If !Empty( minvalid3 ) .and. minvalid3 >= mn_data
        AAdd( ad, 3 )
      Endif
    Endif
    If !Empty( minvalid7 ) // Дата назначения инд.программы реабилитации
      AAdd( ad, 10 )
      Do Case // выполнение
      Case m1invalid8 == 1 // полностью, 1
        AAdd( ad, 11 )
      Case m1invalid8 == 2 // частично, 2
        AAdd( ad, 12 )
      Case m1invalid8 == 3 // начата, 3
        AAdd( ad, 13 )
      Otherwise            // не выполнена, 0
        AAdd( ad, 14 )
      Endcase
    Endif
  Endif
  If m1privivki1 == 1     // не привит по медицинским показаниям', 1}, ;
    If m1privivki2 == 1
      AAdd( ad, 21 )
    Else
      AAdd( ad, 22 )
    Endif
  Elseif m1privivki1 == 2 // не привит по другим причинам', 2}}
    If m1privivki2 == 1
      AAdd( ad, 23 )
    Else
      AAdd( ad, 24 )
    Endif
  Else                    // привит по возрасту', 0}, ;
    AAdd( ad, 20 )
  Endif
  Use ( cur_dir() + 'tmp13' ) index ( cur_dir() + 'tmp13' ) New Alias TMP13
  For n := 1 To Len( av1 ) // цикл по возрастам таблицы
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp13->voz := av1[ n ]
        tmp13->tip := ad[ j ]
      Endif
      tmp13->kol++
    Next
  Next
  ad := { 0 }
  If m1fiz_razv == 0
    AAdd( ad, 1 )
  Else
    If m1fiz_razv1 == 1
      AAdd( ad, 2 )
    Elseif m1fiz_razv1 == 2
      AAdd( ad, 3 )
    Endif
    If m1fiz_razv2 == 1
      AAdd( ad, 4 )
    Elseif m1fiz_razv2 == 2
      AAdd( ad, 5 )
    Endif
  Endif
  AAdd( ad, mGRUPPA_DO + 10 )
  AAdd( ad, mGRUPPA + 20 )
  // index on str(voz, 1)+str(man, 1)+str(tip, 2) to tmp16
  Use ( cur_dir() + 'tmp16' ) index ( cur_dir() + 'tmp16' ) New Alias TMP16
  For n := 1 To Len( av1 ) // цикл по возрастам таблицы
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + '0' + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp16->voz := av1[ n ]
        tmp16->tip := ad[ j ]
      Endif
      tmp16->kol++
      If is_man
        find ( Str( av1[ n ], 1 ) + '1' + Str( ad[ j ], 2 ) )
        If !Found()
          Append Blank
          tmp16->voz := av1[ n ]
          tmp16->man := 1
          tmp16->tip := ad[ j ]
        Endif
        tmp16->kol++
      Endif
    Next
  Next

  Return Nil

// 24.12.19
Function inf_dds_xmlfile( is_schet )

  Static stitle := 'XML-портал: диспансеризация детей-сирот '
  Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3, .t. )
      r_use( dir_server() + 'human',, 'HUMAN' )
      Use ( cur_dir() + 'tmp' ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + 'tmp' )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        e_use( cur_dir() + 'tmp', cur_dir() + 'tmp' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := 2
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := stitle + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := 'B/BG'
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t. }
      blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { ' ', {|| iif( tmp->is == 1, '', ' ' ) }, blk }, ;
        { ' Ф.И.О.', {|| PadR( human->fio, 37 ) }, blk }, ;
        { 'Дата рожд.', {|| full_date( human->date_r ) }, blk }, ;
        { '№ ам.карты', {|| human->uch_doc }, blk }, ;
        { 'Сроки леч-я', {|| Left( date_8( human->n_data ), 5 ) + '-' + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { 'Этап', {|| iif( human->ishod == 101, ' I  ', 'I-II' ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( '^<Esc>^ - выход для создания файла;  ^<+,-,Ins>^ - отметить/снять отметку с пациента' ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_n_xmlfile( nk, ob, 'edit' ) }
      edit_browse( t_arr )
      Select TMP
      Delete For is == 0
      Pack
      n := LastRec()
      Close databases
      rest_box( buf )
      If n == 0 .or. !f_esc_enter( 'составления XML-файла' )
        Return Nil
      Endif
      mywait()
      r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + 'tmprpdsh' )
      Use
      r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + 'tmpraksh' )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
        r_use( dir_server() + 'human',, 'HUMAN' ), ;
        dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
        r_use( cur_dir() + 'tmp', cur_dir() + 'tmp' ), ;
        dbSetRelation( 'HUMAN', {|| kod }, 'kod' );
        }
      mo_mzxml_n( 1 )
      n := 0
      Do While .t.
        ++n
        Eval( blk_open )
        If rec == NIL
          Go Top
        Else
          Goto ( rec )
          Skip
          If Eof()
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say PadR( Str( n / tmp->( LastRec() ) * 100, 6, 2 ) + '%' + ' ' + ;
          RTrim( human->fio ) + ' ' + date_8( human->n_data ) + '-' + ;
          date_8( human->k_data ), 80 ) Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, 'f2_inf_N_XMLfile' )
      Enddo
      Close databases
      rest_box( buf )
      mo_mzxml_n( 3, 'tmp', stitle )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil
