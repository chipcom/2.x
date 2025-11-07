// information_DDS.prg - информация по диспансеризации детей сирот
#include 'inkey.ch'
#include 'fastreph.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

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

// 30.10.25
Function inf_dds_svod( par, par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec
  local adbf

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
      For i := 1 To Len( dds_arr_osm1( arr_m[ 5 ]) )
        AAdd( adbf, { 'd1_' + lstr( i ), 'C', 8, 0 } )
      Next
      AAdd( adbf, { 'd1_zs', 'C', 8, 0 } )
      For i := 1 To Len( dds_arr_osm2() ) 
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
      frt->name := glob_mo[ _MO_SHORT_NAME ]
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
        Index On DToS( n_data ) + Upper( fio ) to ( fr_data )
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
        Index On DToS( n_data ) + Upper( fio ) to ( fr_data )
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

// 04.05.16
Function f2_inf_dds_svod( Loc_kod, kod_kartotek ) // сводная информация

  Local i := 0, c, s := 'НЕТ акта', pole, arr, ddo := {}, dposle := {}

  r_use( dir_server() + 'mo_rak',, 'RAK' )
  r_use( dir_server() + 'mo_raks',, 'RAKS' )
  Set Relation To akt into RAK
  r_use( dir_server() + 'mo_raksh',, 'RAKSH' )
  Set Relation To kod_raks into RAKS
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
  Append Blank
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
