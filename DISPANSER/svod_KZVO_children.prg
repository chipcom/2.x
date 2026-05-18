#include 'function.ch'
#include 'chip_mo.ch'
#include 'tfile.ch'

// 18.05.26 Приложение к письму ГБУЗ 'ВОМИАЦ' №1025 от 08.07.2019г.
Function svod_KZVO_children( par )      // f21_inf_dnl

  Local arr_m, buf := save_maxrow(), s, adbf, i, sh, HH := 40, n_file := cur_dir() + 'svod_dnl.txt'
  Local name_file := 'ПО дети с репродуктивкой 15-17_'
  Local name_file_full := name_file + '.xlsx'
  local arr_PO := {}, arr_15_17 := {}, arr_NP := {}

  If ( arr_m := year_month(,,, 5 ) ) != NIL

    If arr_m[ 1 ] < 2020
      Return func_error( 4, 'Данная форма утверждена с 2020 года' )
    Endif
    mywait()

    svod_inf_dnl( arr_m, par > 1, par == 3, { 301, 302 } )
      r_use( dir_server() + 'mo_rpdsh',, 'RPDSH' )
      Index On Str( FIELD->KOD_H, 7 ) to ( cur_dir() + 'tmprpdsh' )
      adbf := { ;
        { 'ti', 'N', 1, 0 }, ;
        { 'stroke', 'C', 8, 0 }, ;
        { 'mm', 'N', 2, 0 }, ;
        { 'mm1', 'N', 1, 0 }, ;
        { 'vsego', 'N', 6, 0 }, ;
        { 'vsego1', 'N', 6, 0 }, ;
        { 'vsegoM', 'N', 6, 0 }, ;
        { 'g1', 'N', 6, 0 }, ;
        { 'g2', 'N', 6, 0 }, ;
        { 'g3', 'N', 6, 0 }, ;
        { 'g4', 'N', 6, 0 }, ;
        { 'g4inv', 'N', 6, 0 }, ;
        { 'g5', 'N', 6, 0 }, ;
        { 'g5inv', 'N', 6, 0 }, ;
        { 'mg1', 'N', 6, 0 }, ;
        { 'mg2', 'N', 6, 0 }, ;
        { 'mg3', 'N', 6, 0 }, ;
        { 'mg4', 'N', 6, 0 }, ;
        { 'sv', 'N', 6, 0 }, ;
        { 'so', 'N', 6, 0 }, ;
        { 'v2', 'N', 6, 0 }, ;
        { 'm15', 'N', 6, 0 }, ;
        { 'm15s', 'N', 6, 0 }, ;
        { 'm15pos', 'N', 6, 0 }, ;
        { 'm15poss', 'N', 6, 0 }, ;
        { 'm15a', 'N', 6, 0 }, ;
        { 'm15p', 'N', 6, 0 }, ;
        { 'm15ps', 'N', 6, 0 }, ;
        { 'm15p1', 'N', 6, 0 }, ;
        { 'm15p1s', 'N', 6, 0 }, ;
        { 'm15e', 'N', 6, 0 }, ;
        { 'g15', 'N', 6, 0 }, ;
        { 'g15s', 'N', 6, 0 }, ;
        { 'g15pos', 'N', 6, 0 }, ;
        { 'g15poss', 'N', 6, 0 }, ;
        { 'g15g', 'N', 6, 0 }, ;
        { 'g15p', 'N', 6, 0 }, ;
        { 'g15ps', 'N', 6, 0 }, ;
        { 'g15p1', 'N', 6, 0 }, ;
        { 'g15p1s', 'N', 6, 0 }, ;
        { 'g15e', 'N', 6, 0 }, ;
        { 'g18', 'N', 6, 0 }, ;
        { 'g18s', 'N', 6, 0 }, ;
        { 'm18', 'N', 6, 0 }, ;
        { 'm18s', 'N', 6, 0 } }

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
        { 'ti', 'N', 1, 0 }, ;
        { 'g1', 'N', 6, 0 }, ;
        { 'g2', 'N', 6, 0 }, ;
        { 'g3', 'N', 6, 0 }, ;
        { 'g31', 'N', 6, 0 }, ;
        { 'g32', 'N', 6, 0 }, ;
        { 'g4', 'N', 6, 0 }, ;
        { 'g5', 'N', 6, 0 }, ;
        { 'g6', 'N', 6, 0 }, ;
        { 'g7', 'N', 6, 0 }, ;
        { 'g8', 'N', 6, 0 }, ;
        { 'g9', 'N', 6, 0 }, ;
        { 'g10', 'N', 6, 0 }, ;
        { 'g11', 'N', 6, 0 }, ;
        { 'g12', 'N', 6, 0 }, ;
        { 'g13', 'N', 6, 0 }, ;
        { 'g14', 'N', 6, 0 }, ;
        { 'g15', 'N', 6, 0 }, ;
        { 'g7n', 'N', 6, 0 }, ;
        { 'g8n', 'N', 6, 0 }, ;
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
      Do While !tmp->( Eof() )
        @ MaxRow(), 0 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + '%' Color cColorWait
        f1_f21_inf_dnl( tmp->kod, tmp->kod_k )
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
      writexlsx_inf_pn( hb_OEMToANSI( name_file_full ), arr_m, arr_PO, arr_15_17, arr_NP )
      work_with_excel_file( name_file_full )
  Endif
  dbCloseAll()
  rest_box( buf )

  Return Nil

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
