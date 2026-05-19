#include 'function.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 19.05.26 Приложение к письму ГБУЗ 'ВОМИАЦ' №1025 от 08.07.2019г.
Function svod_KZVO_children( par )      // f21_inf_dnl

  Local arr_m, buf := save_maxrow(), adbf
  Local name_file := 'ПО дети с репродуктивкой 15-17_'
  Local name_file_full := name_file + '.xlsx'
  local arr_PO := {}, arr_15_17 := {}, arr_NP := {}
  local arr_deti_DDS, arr_deti_DDSOP, arr_2510_DDS, arr_2510_DDSOP

  local blk_open
  Local lkod_h, lkod_k, rec

  If ( arr_m := year_month(,,, 5 ) ) != NIL

    Private arr_deti, arr_2510

    If arr_m[ 1 ] < 2020
      Return func_error( 4, 'Данная форма утверждена с 2020 года' )
    Endif
    mywait()  // 'подождите, работаю'

    svod_inf_dnl( arr_m, par > 1, par == 3, { 301, 302 } )

    r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
    Index On Str( FIELD->KOD_H, 7 ) to ( cur_dir() + 'tmprpdsh' )
    adbf := { ;
      { 'ti',     'N', 1, 0 }, ;
      { 'stroke', 'C', 8, 0 }, ;
      { 'mm',     'N', 2, 0 }, ;
      { 'mm1',    'N', 1, 0 }, ;
      { 'vsego',  'N', 6, 0 }, ;
      { 'vsego1', 'N', 6, 0 }, ;
      { 'vsegoM', 'N', 6, 0 }, ;
      { 'g1',     'N', 6, 0 }, ;
      { 'g2',     'N', 6, 0 }, ;
      { 'g3',     'N', 6, 0 }, ;
      { 'g4',     'N', 6, 0 }, ;
      { 'g4inv',  'N', 6, 0 }, ;
      { 'g5',     'N', 6, 0 }, ;
      { 'g5inv',  'N', 6, 0 }, ;
      { 'mg1',    'N', 6, 0 }, ;
      { 'mg2',    'N', 6, 0 }, ;
      { 'mg3',    'N', 6, 0 }, ;
      { 'mg4',    'N', 6, 0 }, ;
      { 'sv',     'N', 6, 0 }, ;
      { 'so',     'N', 6, 0 }, ;
      { 'v2',     'N', 6, 0 }, ;
      { 'm15',    'N', 6, 0 }, ;
      { 'm15s',   'N', 6, 0 }, ;
      { 'm15pos', 'N', 6, 0 }, ;
      { 'm15poss','N', 6, 0 }, ;
      { 'm15a',   'N', 6, 0 }, ;
      { 'm15p',   'N', 6, 0 }, ;
      { 'm15ps',  'N', 6, 0 }, ;
      { 'm15p1',  'N', 6, 0 }, ;
      { 'm15p1s', 'N', 6, 0 }, ;
      { 'm15e',   'N', 6, 0 }, ;
      { 'g15',    'N', 6, 0 }, ;
      { 'g15s',   'N', 6, 0 }, ;
      { 'g15pos', 'N', 6, 0 }, ;
      { 'g15poss','N', 6, 0 }, ;
      { 'g15g',   'N', 6, 0 }, ;
      { 'g15p',   'N', 6, 0 }, ;
      { 'g15ps',  'N', 6, 0 }, ;
      { 'g15p1',  'N', 6, 0 }, ;
      { 'g15p1s', 'N', 6, 0 }, ;
      { 'g15e',   'N', 6, 0 }, ;
      { 'g18',    'N', 6, 0 }, ;
      { 'g18s',   'N', 6, 0 }, ;
      { 'm18',    'N', 6, 0 }, ;
      { 'm18s',   'N', 6, 0 } }
    dbCreate( cur_dir() + 'tmp1', adbf )
    Use ( cur_dir() + 'tmp1' ) new
    Index On Str( FIELD->mm, 2 ) to ( cur_dir() + 'tmp1' )
    add_inf_dbf_dnl( 'tmp1', 0, 'Всего' )
    add_inf_dbf_dnl( 'tmp1', 1, '0-14 лет' )
    add_inf_dbf_dnl( 'tmp1', 2, 'до 1 г.' )
    add_inf_dbf_dnl( 'tmp1', 3, '15-17 л.' )
    add_inf_dbf_dnl( 'tmp1', 4, '15-17 юн' )
    add_inf_dbf_dnl( 'tmp1', 5, 'школьники' )
    adbf := { ;
      { 'ti',   'N', 1, 0 }, ;
      { 'g1',   'N', 6, 0 }, ;
      { 'g2',   'N', 6, 0 }, ;
      { 'g3',   'N', 6, 0 }, ;
      { 'g31',  'N', 6, 0 }, ;
      { 'g32',  'N', 6, 0 }, ;
      { 'g4',   'N', 6, 0 }, ;
      { 'g5',   'N', 6, 0 }, ;
      { 'g6',   'N', 6, 0 }, ;
      { 'g7',   'N', 6, 0 }, ;
      { 'g8',   'N', 6, 0 }, ;
      { 'g9',   'N', 6, 0 }, ;
      { 'g10',  'N', 6, 0 }, ;
      { 'g11',  'N', 6, 0 }, ;
      { 'g12',  'N', 6, 0 }, ;
      { 'g13',  'N', 6, 0 }, ;
      { 'g14',  'N', 6, 0 }, ;
      { 'g15',  'N', 6, 0 }, ;
      { 'g7n',  'N', 6, 0 }, ;
      { 'g8n',  'N', 6, 0 }, ;
      { 'g12n', 'N', 6, 0 }, ;
      { 'g13n', 'N', 6, 0 }, ;
      { 'g14n', 'N', 6, 0 }, ;
      { 'g16n', 'N', 6, 0 } }
    dbCreate( cur_dir() + 'tmp2', adbf )
    Use ( cur_dir() + 'tmp2' ) new
    Index On Str( FIELD->ti, 1 ) to ( cur_dir() + 'tmp2' )
    r_use( dir_server() + 'mo_schoo',, 'SCH' )
    r_use( dir_server() + 'schet_',, 'SCHET_' )
    r_use( dir_server() + 'uslugi',, 'USL' )
    r_use_base( 'human_u' )
    r_use( dir_server() + 'kartote_',, 'KART_' )
    r_use( dir_server() + 'human_',, 'HUMAN_' )
    r_use( dir_server() + 'human',, 'HUMAN' )
    Set Relation To RecNo() into HUMAN_, To FIELD->kod_k into KART_
    Use ( cur_dir() + 'tmp' ) new
    Set Relation To FIELD->kod into HUMAN
    tmp->( dbGoTop() )
    mywait( '' )  // очистим информационную строку
    Do While !tmp->( Eof() )
      @ MaxRow(), 0 Say 'Профосмотры несовершеннолетних: ' + Str( RecNo() / LastRec() * 100, 6, 2 ) + '%' Color cColorWait
      svod_inf_dnl_LU( tmp->kod, tmp->kod_k )
      Select TMP
      tmp->( dbSkip() )
    Enddo
    dbCloseAll()
    Use ( cur_dir() + 'tmp1' ) index ( cur_dir() + 'tmp1' ) new
    tmp1->( dbGoTop() )
    Do While !tmp1->( Eof() )
      if tmp1->( Recno() ) == 1
        AAdd( arr_15_17, { tmp1->m15, tmp1->m15s, tmp1->m15pos, tmp1->m15poss, tmp1->m15a, tmp1->m15p, ;
          tmp1->m15ps, tmp1->m15p1, tmp1->m15p1s, tmp1->m15e, tmp1->m18, tmp1->m18s } ;
        )
        AAdd( arr_15_17, { tmp1->g15, tmp1->g15s, tmp1->g15pos, tmp1->g15poss, tmp1->g15g, tmp1->g15p, ;
          tmp1->g15ps, tmp1->g15p1, tmp1->g15p1s, tmp1->g15e, tmp1->g18, tmp1->g18s } ;
        )
      endif
      AAdd( arr_PO, { tmp1->vsego, tmp1->vsego1, tmp1->vsegoM, ;
        tmp1->g1, tmp1->g2, tmp1->g3, tmp1->g4, tmp1->g4inv, tmp1->g5, tmp1->g5inv, ;
        tmp1->mg1, tmp1->mg2, tmp1->mg3, tmp1->mg4, tmp1->sv, tmp1->so, tmp1->v2, tmp1->v2 } ;
      )
      tmp1->( dbSkip() )
    Enddo
    //
    tmp1->( dbGoTop() )
    Use ( cur_dir() + 'tmp2' ) index ( cur_dir() + 'tmp2' ) new
    tmp2->( dbGoTop() )
    Do While ! tmp2->( Eof() ) 
      AAdd( arr_NP, { tmp2->g2, tmp2->g3, tmp2->g5, tmp2->g6, tmp2->g7n, tmp2->g8n, tmp2->g7, tmp2->g8, tmp2->g7, 0, tmp2->g12n, tmp2->g13n, ;
        tmp2->g14n, tmp2->g11, tmp2->g12, tmp2->g16n, tmp2->g13, tmp2->g14, tmp2->g15 })
      tmp2->( dbSkip() )
    Enddo
    //
    dbCloseAll()

// дети-сироты под опекой
/*
    mywait( '' )  // очистим информационную строку
    // сформируем массивы
    arr_deti := { ;
      { '1', 'Всего', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
      { '1.1', '0-14 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
      { '1.2', '15-17 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    }
    arr_2510 := { ;
      { '001 дети 0-14 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
      { '002 из них дети до 1 г.', 0, 0, 0, 0, 0, 0, 0 }, ;
      { '003 дети 15-17 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
      { '004 15-17 лет - юноши', 0, 0, 0, 0, 0, 0, 0 }, ;
      { '005 школьники', 0, 0, 0, 0, 0, 0, 0 };
    }
    // сначала соберем дети сироты по опекой
    svod_inf_dds( arr_m, TIP_LU_DDSOP, par > 1, par == 3 )

    blk_open := {|| dbCloseAll(), ;
      r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
      r_use( dir_server() + 'human',, 'HUMAN' ), ;
      dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
      r_use( cur_dir() + 'tmp' ), ;
      dbSetRelation( 'HUMAN', {|| FIELD->kod }, 'kod' );
    }

    Do While .t.
      Eval( blk_open )
      If rec == NIL
        tmp->( dbGoTop() )
      Else
        tmp->( dbGoto( rec ) )
        tmp->( dbSkip() )
        If tmp->( Eof() )
          Exit
        Endif
      Endif
      rec := tmp->( RecNo() )
      @ MaxRow(), 0 Say 'Диспансеризация детей-сирот под опекой: ' + Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      dbCloseAll()
      oms_sluch_dds( TIP_LU_DDSOP, lkod_h, lkod_k, 'svod_inf_DDS_LU' )
    Enddo
    arr_deti_DDSOP := AClone( arr_deti )
    arr_2510_DDSOP := AClone( arr_2510 )
    dbCloseAll()
*/
    arr_2510_DDSOP := collect_arr2510( arr_m, TIP_LU_DDSOP, par, 'Диспансеризация детей-сирот под опекой: ' )

// дети-сироты стационарные
//    mywait( '' )  // очистим информационную строку
    // снова сформируем массивы
//    arr_deti := { ;
//      { '1', 'Всего', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
//      { '1.1', '0-14 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
//      { '1.2', '15-17 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
//    }
//    arr_2510 := { ;
//      { '001 дети 0-14 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
//      { '002 из них дети до 1 г.', 0, 0, 0, 0, 0, 0, 0 }, ;
//      { '003 дети 15-17 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
//      { '004 15-17 лет - юноши', 0, 0, 0, 0, 0, 0, 0 }, ;
//      { '005 школьники', 0, 0, 0, 0, 0, 0, 0 };
//    }

//    svod_inf_dds( arr_m, TIP_LU_DDS, par > 1, par == 3 )
/*
    blk_open := {|| dbCloseAll(), ;
      r_use( dir_server() + 'human_',, 'HUMAN_' ), ;
      r_use( dir_server() + 'human',, 'HUMAN' ), ;
      dbSetRelation( 'HUMAN_', {|| RecNo() }, 'recno()' ), ;
      r_use( cur_dir() + 'tmp' ), ;
      dbSetRelation( 'HUMAN', {|| FIELD->kod }, 'FIELD->kod' );
    }
*/
//    r_use( cur_dir() + 'tmp' )
//    tmp->( dbGoTop() )
//    do while !tmp->( Eof() )
//      rec := tmp->( RecNo() )
//      @ MaxRow(), 0 Say 'Диспансеризация детей-сирот: ' + Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
//      oms_sluch_dds( TIP_LU_DDS, tmp->kod, tmp->kod_k, 'svod_inf_DDS_LU' )
//      dbCloseAll()
//      r_use( cur_dir() + 'tmp' )
//      tmp->( dbGoto( rec ) )
//      tmp->( dbSkip() )
//    Enddo
/*
    Do While .t.
      Eval( blk_open )
      If rec == NIL
        tmp->( dbGoTop() )
      Else
        tmp->( dbGoto( rec ) )
        tmp->( dbSkip() )
        If tmp->( Eof() )
          Exit
        Endif
      Endif
      rec := tmp->( RecNo() )
      @ MaxRow(), 0 Say 'Диспансеризация детей-сирот: ' + Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
      lkod_h := human->kod
      lkod_k := human->kod_k
      dbCloseAll()
      oms_sluch_dds( TIP_LU_DDS, lkod_h, lkod_k, 'svod_inf_DDS_LU' )
    Enddo
*/    
//    arr_deti_DDS := AClone( arr_deti )
//    arr_2510_DDS := AClone( arr_2510 )
//    dbCloseAll()

    arr_2510_DDS := collect_arr2510( arr_m, TIP_LU_DDS, par, 'Диспансеризация детей-сирот: ' )
/*      
      sh := iif( par2 == 3, 92, 68 )
      Do While .t.
        // R_Use_base('human_u')
        Eval( blk_open )
        If rec == NIL
          tmp->( dbGoTop() )    //  Go Top
        Else
          tmp->( dbGoto( rec ) )      //  Goto ( rec )
          tmp->( dbSkip() )       //  Skip
          If tmp->( Eof() )
            Exit
          Endif
        Endif
        rec := tmp->( RecNo() )
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        dbCloseAll()
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, 'svod_inf_DDS_LU' )
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
      ft:add_string( '[ ' + CharRem( '~', mas1pmt()[ par ] ) + ' ]', FILE_CENTER, ' ' )
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
*/

    writexlsx_inf_pn( hb_OEMToANSI( name_file_full ), arr_m, arr_PO, arr_15_17, arr_NP, ;
      arr_2510_DDS, arr_2510_DDSOP )
    work_with_excel_file( name_file_full )
  Endif
  dbCloseAll()
  rest_box( buf )

  Return Nil

// 19.05.26
function collect_arr2510( arr_m, type_LU, par, titul )

  local rec

  private arr_deti, arr_2510

  mywait( '' )  // очистим информационную строку
  // сформируем массивы
  arr_deti := { ;
    { '1', 'Всего', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
    { '1.1', '0-14 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
    { '1.2', '15-17 лет', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  }
  arr_2510 := { ;
    { '001 дети 0-14 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
    { '002 из них дети до 1 г.', 0, 0, 0, 0, 0, 0, 0 }, ;
    { '003 дети 15-17 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
    { '004 15-17 лет - юноши', 0, 0, 0, 0, 0, 0, 0 }, ;
    { '005 школьники', 0, 0, 0, 0, 0, 0, 0 };
  }

  svod_inf_dds( arr_m, type_LU, par > 1, par == 3 )

  r_use( cur_dir() + 'tmp' )
  tmp->( dbGoTop() )
  do while !tmp->( Eof() )
    rec := tmp->( RecNo() )
    @ MaxRow(), 0 Say titul + Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + '%' Color cColorWait
    oms_sluch_dds( type_LU, tmp->kod, tmp->kod_k, 'svod_inf_DDS_LU' )
    dbCloseAll()
    r_use( cur_dir() + 'tmp' )
    tmp->( dbGoto( rec ) )
    tmp->( dbSkip() )
  Enddo
  dbCloseAll()

  return AClone( arr_2510 )

// 18.05.26
Function svod_inf_dnl( arr_m, is_schet, is_reg, arr_ishod, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f., arr_ishod TO { 301, 302 } // профилактика 1 и 2 этап

  If !del_dbf_file( cur_dir() + 'tmp' + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + 'tmp', { ;
    { 'kod', 'N', 7, 0 }, ;
    { 'kod_k', 'N', 7, 0 }, ;
    { 'is', 'N', 1, 0 }, ;
    { 'ishod', 'N', 6, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To FIELD->kod_k into KART
  
  human->( dbSeek( DToS( arr_m[ 5 ] ), .t. ) )
  Index On FIELD->kod to ( cur_dir() + 'tmp_h' ) ;
    For AScan( arr_ishod, FIELD->ishod ) > 0 .and. iif( is_schet, FIELD->schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] PROGRESS
  human->( dbGoTop() )
  Do While !human->( Eof() )
    fl := .t.
    If is_reg
      fl := .f.
      Select SCHET_
      schet_->( dbGoto( human->schet ) )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      tmp->( dbAppend() )
      tmp->kod := human->kod
      tmp->kod_k := human->kod_k
      tmp->ishod := human->ishod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    Select HUMAN
    human->( dbSkip() )
  Enddo
  fl := .t.
//  If tmp->( LastRec() ) == 0
//    fl := func_error( 4, 'Не найдено л/у по медосмотрам несовершеннолетних ' + arr_m[ 4 ] )
//  Endif
  dbCloseAll()

  Return fl

// 18.05.26
Function svod_inf_dnl_LU( Loc_kod, kod_kartotek ) // сводная информация из листов учета

  Local ii, im, i, j, k, s, sumr := 0, ar := { 0 }, ltip_school := -1, ar15[ 26 ], ;
    is_2 := .f., ad := {}, arr, a3 := {}, fl_ves := .t.
  local fl, is_selo, mvar, m1var, lshifr, pole

  Private m1tip_school := -1, m1school := 0, mvozrast, mdvozrast, mgruppa := 0, m1GR_FIZ := 1, m1invalid1 := 0
//  Private mvar, m1var, 
  Private m1FIZ_RAZV1, m1napr_stac := 0

  AFill( ar15, 0 )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  For i := 1 To 5
    For k := 1 To 16
      s := 'diag_16_' + lstr( i ) + '_' + lstr( k )
      mvar := 'm' + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := 'm1' + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  ii := 1
  is_2 := ( human->ishod == 302 ) // это второй этап
  read_arr_pn( Loc_kod, .t., human->K_DATA )
  If human->pol == 'М'
    If m1napr_stac > 0
      ar15[ 23 ] ++
      If f_is_selo()
        ar15[ 24 ] ++
      Endif
    Endif
  Else
    If m1napr_stac > 0
      ar15[ 25 ] ++
      If f_is_selo()
        ar15[ 26 ] ++
      Endif
    Endif
  Endif
  //
  mGRUPPA := human_->RSLT_NEW - 331// L_BEGIN_RSLT
  If mvozrast == 0
    AAdd( ar, 2 )
  Endif
  If mdvozrast < 15
    AAdd( ar, 1 )
  Else
    AAdd( ar, 3 )
    If human->pol == 'М'
      AAdd( ar, 4 )
    Endif
  Endif
  If mdvozrast > 6 // школьники ?
    AAdd( ar, 5 )
  Endif
  If m1school > 0
    Select SCH
    sch->( dbGoto( m1school ) )
    ltip_school := sch->tip
  Endif
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
  //
  arr := Array( 24 )
  AFill( arr, 0 )
  arr[ 16 ] := 3
  arr[ 1 ] := 1
  If ( is_selo := f_is_selo() )
    arr[ 4 ] := 1
  Endif
  If DoW( human->k_data ) == 7 // суббота
    arr[ 3 ] := 1
    If is_selo
      arr[ 6 ] := 1
    Endif
  Endif

  For i := 1 To Len( ad )
    If !( Left( ad[ i, 1 ], 1 ) == 'A' .or. Left( ad[ i, 1 ], 1 ) == 'B' ) .and. ad[ i, 2 ] > 0 // неинфекционные заболевания уст.впервые
      arr[ 7 ] ++
      If Left( ad[ i, 1 ], 1 ) == 'I' // болезни системы кровообращения
        arr[ 8 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'J' // болезни органов дыхания
        arr[ 11 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'K' // болезни органов пищеварения
        arr[ 12 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'M' // болезни костно-мышечной системы
        arr[ 19 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'H' // болезни глаз
        arr[ 20 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == 'E' // болезни эндокринология
        arr[ 21 ] ++
      Endif
      If Left( ad[ i, 1 ], 3 ) == 'E78'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'R73.9'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.0'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.4'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'R63.5'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.3'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.1'
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == 'Z72.2'
        arr[ 22 ] ++
        fl_ves := .f.
      Endif
      // надо деффицит массы тела
      If Left( ad[ i, 1 ], 1 ) == 'C' .or. Between( Left( ad[ i, 1 ], 3 ), 'D00', 'D09' ) // ЗНО может быть добавить  .or. between(left(ad[i, 1], 3),'D45','D47')
        arr[ 9 ] ++
      Endif
      // добавить
      If ad[ i, 3 ] == 2 // дисп.набл.установлено впервые
        arr[ 13 ] ++
      Endif
      If ad[ i, 10 ] == 1 // 1-лечение назначено
        arr[ 14 ] ++    // ?? было начато лечение
        If is_selo
          arr[ 15 ] ++
        Endif
      Endif
    Endif
  Next
  AAdd( a3, AClone( arr ) )
  If Between( mdvozrast, 15, 17 )
    arr[ 16 ] := 2
    j := iif( human->pol == 'М', 1, 7 )
    ar15[ j ] ++
    If is_selo
      ar15[ j + 1 ] ++
    Endif
    If ( i := AScan( ad, {| x| Left( x[ 1 ], 1 ) == 'N' } ) ) > 0 // патология органов репродуктивной системы
      ar15[ j + 3 ] ++
      If is_selo
        ar15[ j + 4 ] ++
      Endif
      If ad[ i, 2 ] > 0 // заболевания уст.впервые
        If is_2
          ar15[ j + 5 ] ++
        Endif
        If j == 1
          ar15[ 13 ] ++
          If is_selo
            ar15[ 14 ] ++
          Endif
        Else
          ar15[ 15 ] ++
          If is_selo
            ar15[ 16 ] ++
          Endif
        Endif
      Endif
    Endif

    fl := .f.
    Select HU
    hu->( dbSeek( Str( Loc_kod, 7 ) ) )      //  find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. ! hu->( Eof() )
      If eq_any( hu_->PROFIL, 19, 136 )
        fl := .t.
      Endif
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If Left( lshifr, 2 ) == '2.'  // врачебный приём
        If Left( lshifr, 4 ) != '2.91'  // не полноценные игнорируем
          If j == 1
            ar15[ 17 ] ++
            If is_selo
              ar15[ 18 ] ++
            Endif
          Else
            ar15[ 19 ] ++
            If is_selo
              ar15[ 20 ] ++
            Endif
          Endif
          // mydebug(,human->fio)
          If hu_->PROFIL == 19
            arr[ 17 ] ++
          Endif
          If hu_->PROFIL == 136
            arr[ 18 ] ++
          Endif
        Endif
      Endif
      Select HU
      hu->( dbSkip() )      //  Skip
    Enddo
    If fl
      ar15[ j + 2 ] ++
    Endif
  Else
    arr[ 16 ] := 1
  Endif
  AAdd( a3, AClone( arr ) )
  //
  // aadd(arr,{'12.4.1',m1FIZ_RAZV1})  // 'N',физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  If m1fiz_razv1 == 1
    If fl_ves
      arr[ 22 ] ++
    Endif
  Endif
  //
  For j := 1 To Len( a3 )
    Select TMP2
    tmp2->( dbseek( Str( a3[ j, 16 ], 1 ) ) )      //  find ( Str( a3[ j, 16 ], 1 ) )
    If !tmp2->( Found() )
      tmp2->( dbAppend() )      //  Append Blank
      tmp2->ti := a3[ j, 16 ]
    Endif
    For i := 1 To 15
      pole := 'tmp2->g' + lstr( i )
      &pole := &pole + a3[ j, i ]
    Next
    tmp2->g7n  := tmp2->g7n  + arr[ 17 ]
    tmp2->g8n  := tmp2->g8n  + arr[ 18 ]
    tmp2->g12n := tmp2->g12n + arr[ 19 ]
    tmp2->g13n := tmp2->g13n + arr[ 20 ]
    tmp2->g14n := tmp2->g14n + arr[ 21 ]
    tmp2->g16n := tmp2->g16n + arr[ 22 ]
  Next
  //
  For j := 1 To Len( ar )
    im := ar[ j ]
    Select TMP1
    tmp1->( dbSeek( Str( im, 2 ) ) )      //  find ( Str( im, 2 ) )
    tmp1->vsego++
    If is_selo
      tmp1->vsego1++
    Endif
    tmp1->m15  += ar15[ 1 ]
    tmp1->m15s += ar15[ 2 ]
    tmp1->m15pos += ar15[ 17 ]
    tmp1->m15poss += ar15[ 18 ]
    tmp1->m15a += ar15[ 3 ]
    tmp1->m15p += ar15[ 4 ]
    tmp1->m15ps += ar15[ 5 ]
    tmp1->m15p1 += ar15[ 13 ]
    tmp1->m15p1s += ar15[ 14 ]
    tmp1->m15e += ar15[ 6 ] // 2-й этап
    tmp1->g15  += ar15[ 7 ]
    tmp1->g15s += ar15[ 8 ]
    tmp1->g15pos += ar15[ 19 ]
    tmp1->g15poss += ar15[ 20 ]
    tmp1->g15g += ar15[ 9 ]
    tmp1->g15p += ar15[ 10 ]
    tmp1->g15ps += ar15[ 11 ]
    tmp1->g15p1 += ar15[ 15 ]
    tmp1->g15p1s += ar15[ 16 ]
    tmp1->g15e += ar15[ 12 ] // 2-й этап
    tmp1->g18 += ar15[ 23 ]
    tmp1->g18s += ar15[ 24 ]
    tmp1->m18 += ar15[ 25 ]
    tmp1->m18s += ar15[ 26 ]
    If Between( mgruppa, 1, 5 )
      pole := 'tmp1->g' + lstr( mgruppa )
      &pole := &pole + 1
      If Between( mgruppa, 4, 5 ) .and. m1invalid1 == 1 // инвалидность-да
        pole += 'inv'
        &pole := &pole + 1
      Endif
      If /*ltip_school == 0 .and.*/ between(m1GR_FIZ, 1, 4)
        pole := 'tmp1->mg' + lstr( m1GR_FIZ )
        &pole := &pole + 1
      Endif
      If is_2 // I и II этап
        tmp1->v2++
      Endif
    Endif
    If human->schet > 0
      Select SCHET_
      schet_->( dbGoto( human->schet ) )      //  Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        tmp1->sv++
        sumr := 0
        Select RPDSH
        rpdsh->( dbSeek( Str( Loc_kod, 7 ) ) )       //  find ( Str( Loc_kod, 7 ) )
        Do While rpdsh->KOD_H == Loc_kod .and. !rpdsh->( Eof() )
          sumr += rpdsh->S_SL
          rpdsh->( dbSkip() )       //  Skip
        Enddo
        If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // полностью оплачен
          tmp1->so++
        Endif
      Endif
    Endif
  Next

  Return Nil

// 11.03.19
Function svod_inf_dds( arr_m, tip_lu, is_schet, is_reg, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f.
  If !del_dbf_file( cur_dir() + 'tmp' + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + 'tmp', { ;
    { 'kod',    'N', 7, 0 }, ;
    { 'kod_k',  'N', 7, 0 }, ;
    { 'is',     'N', 1, 0 } } ;
  )
  Use ( cur_dir() + 'tmp' ) new
  r_use( dir_server() + 'schet_',, 'SCHET_' )
  r_use( dir_server() + 'kartotek',, 'KART' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To FIELD->kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On FIELD->kod to ( cur_dir() + 'tmp_h' ) ;
    For iif( tip_lu == TIP_LU_DDS, !Empty( FIELD->za_smo ), Empty( FIELD->za_smo ) ) .and. ;
    eq_any( FIELD->ishod, 101, 102 ) .and. iif( is_schet, FIELD->schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] PROGRESS
  human->( dbGoTop() )
  Do While ! human->( Eof() )
    fl := .t.
    If is_reg
      fl := .f.
      schet_->( dbGoto( human->schet ) )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      tmp->( dbAppend() )
      tmp->kod := human->kod
      tmp->kod_k := human->kod_k
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    human->( dbSkip() )
  Enddo
  fl := .t.
//  If tmp->( LastRec() ) == 0
//    fl := func_error( 4, 'Не найдено л/у по диспансеризации детей-сирот ' + arr_m[ 4 ] )
//  Endif
  dbCloseAll()

  Return fl

// 19.05.26
Function svod_inf_dds_LU( Loc_kod, kod_kartotek, mvozrast )

  Local i, j, k, is_selo, ad := {}, ar := { 1 }, ar1 := {}, arr
  local ar2, lshifr, fl
  local mvar, m1var, s

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
          AAdd( ad, arr )
          j := Len( ad )
        Endif
      Elseif j > 0
        m1var := 'm1' + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next

  r_use( dir_server() + 'kartote2',, 'KART2' )
  kart2->( dbGoto( kod_kartotek ) )     //  Goto ( kod_kartotek )
  r_use( dir_server() + 'kartote_',, 'KART_' )
  kart_->( dbGoto( kod_kartotek ) )     //  Goto ( kod_kartotek )

  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use_base( 'human_u' )
  r_use( dir_server() + 'human',, 'HUMAN' )

  r_use( dir_server() + 'kartotek',, 'KART' )
  kart->( dbGoto( kod_kartotek ) )     //  Goto ( kod_kartotek )
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
  Select HU
  hu->( dbSeek( Str( Loc_kod, 7 ) ) )      //  find ( Str( Loc_kod, 7 ) )
  Do While hu->kod == Loc_kod .and. !hu->( Eof() )
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
    hu->( dbSkip() )    //  Skip
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
