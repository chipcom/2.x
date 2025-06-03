#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// * 24.01.23
Function b_25_perinat_2()
  Static si := 1, sk := 1
  Local buf := SaveScreen(), arr_m, i, _arr_komit := {}, fl_exit := .f.

  If ( arr_m := year_month(,,, 4 ) ) == NIL
    Return Nil
  Endif
  If ( musl_ok := popup_prompt( T_ROW, T_COL - 5, si, { 'Стационарное лечение', 'Дневной стационар' } ) ) == 0
    Return Nil
  Endif
  si := musl_ok
  If ( mkomp := popup_prompt( T_ROW, T_COL - 5, sk, { 'Страховые компании', 'Прочие компании', 'Комитеты (МО)' } ) ) == 0
    Return Nil
  Endif
  If ( sk := mkomp ) > 1
    n_file := { '', 'str_komp', 'komitet' }[ sk ]
    If hb_FileExists( dir_server() + n_file + sdbf() )
      arr := {}
      r_use( dir_server() + n_file,, '_B' )
      Go Top
      Do While !Eof()
        If iif( sk == 1, !Between( _b->tfoms, 44, 47 ), .t. )
          AAdd( arr, { AllTrim( _b->name ), _b->kod } )
        Endif
        Skip
      Enddo
      _b->( dbCloseArea() )
      If Len( arr ) > 0
        If ( r := T_ROW - 3 -Len( arr ) ) < 2
          r := 2
        Endif
        If ( a := bit_popup( r, T_COL - 5, arr ) ) != NIL
          For i := 1 To Len( a )
            AAdd( _arr_komit, AClone( a[ i ] ) )
          Next
        Else
          Return func_error( 4, 'Нет выбора' )
        Endif
      Else
        Return func_error( 4, 'Ошибка' )
      Endif
    Else
      Return func_error( 4, 'Не обнаружен файл ' + dir_server() + n_file + sdbf() )
    Endif
  Endif
  waitstatus( arr_m[ 4 ] )
  dbCreate( cur_dir() + 'tmp', { ;
    { 'ID_PAC',  'N', 7, 0 }, ;
    { 'ID_SL',   'N', 7, 0 }, ;
    { 'VID_MP',  'N', 1, 0 }, ;
    { 'OSN_DIAG', 'C', 6, 0 }, ;
    { 'SOP_DIAG', 'C', 50, 0 }, ;
    { 'OSL_DIAG', 'C', 20, 0 }, ;
    { 'DNI',     'N', 3, 0 }, ;
    { 'KOD_OTD', 'C', 6, 0 }, ;
    { 'PROFIL',  'C', 99, 0 }, ;
    { 'POL_PAC', 'N', 1, 0 }, ;
    { 'DATE_ROG', 'C', 10, 0 }, ;
    { 'DATE_GOS', 'C', 10, 0 }, ;
    { 'VIDVMP',  'C', 12, 0 }, ; // вид ВМП по справочнику V018
  { 'METVMP',  'C', 4, 0 }, ; // метод ВМП по справочнику V019
  { 'REANIMAC', 'C', 3, 0 }, ;
    { 'SEBESTO', 'C', 12, 0 }, ;
    { 'USLUGI',  'C', 99, 0 } } )
  Use ( cur_dir() + 'tmp' ) new
  r_use( dir_server() + 'mo_otd',, 'OTD' )
  r_use( dir_server() + 'mo_su',, 'MOSU' )
  g_use( dir_server() + 'mo_hu', dir_server() + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  use_base( 'lusl' )
  r_use( dir_server() + 'uslugi',, 'USL' )
  r_use( dir_server() + 'human_u_',, 'HU_' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server() + 'human_2',, 'HUMAN_2' )
  r_use( dir_server() + 'human_',, 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humand', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    fl := .f.
    Do Case
    Case mkomp == 1
      fl := ( human->komu == 0 .or. !Empty( Val( human_->smo ) ) )
    Case mkomp == 2
      fl := ( human->komu == 1 .and. AScan( _arr_komit, {| x| x[ 2 ] == human->str_crb } ) > 0 )
    Case mkomp == 3
      fl := ( human->komu == 3 .and. AScan( _arr_komit, {| x| x[ 2 ] == human->str_crb } ) > 0 )
    Endcase
    If fl .and. human_->oplata < 9 .and. human_->usl_ok == musl_ok
      is_dializ := .f. ; arr_sl := {}
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
        If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data )
          lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
          If eq_any( Left( lshifr, 5 ), '1.11.', '55.1.' )
            lshifr1 := AllTrim( usl->shifr )
            i := Len( arr_sl )
            If i > 0 .and. hu->otd == arr_sl[ i, 7 ] .and. hu_->profil == arr_sl[ i, 3 ] .and. lshifr1 == arr_sl[ i, 2 ]
              arr_sl[ i, 5 ] := hu_->date_u2
              arr_sl[ i, 6 ] += hu->kol_1
            Else
              AAdd( arr_sl, { lshifr, ;              // 1
              lshifr1, ;             // 2
              hu_->profil, ;         // 3
              hu->date_u, ;          // 4
              hu_->date_u2, ;        // 5
              hu->kol_1, ;           // 6
              hu->otd, ;             // 7
              lshifr } )              // 8 - услуги Минздрава
            Endif
          Elseif !is_dializ
            is_dializ := ( AScan( glob_KSG_dializ, lshifr ) > 0 ) // КСГ с диализом
          Endif
        Endif
        Select HU
        Skip
      Enddo
      If !is_dializ
        mdiagnoz := diag_for_xml(, .t.,,, .t. )
        mdiagnoz2 := ''
        For i := 2 To Len( mdiagnoz )
          If !Empty( mdiagnoz[ i ] )
            mdiagnoz2 += mdiagnoz[ i ] + ';'
          Endif
        Next
        If !Empty( mdiagnoz2 )
          mdiagnoz2 := Left( mdiagnoz2, Len( mdiagnoz2 ) -1 )
        Endif
        mdiagnoz3 := ''
        If !Empty( human_2->OSL1 )
          mdiagnoz3 += AllTrim( human_2->OSL1 ) + ';'
        Endif
        If !Empty( human_2->OSL2 )
          mdiagnoz3 += AllTrim( human_2->OSL2 ) + ';'
        Endif
        If !Empty( human_2->OSL3 )
          mdiagnoz3 += AllTrim( human_2->OSL3 ) + ';'
        Endif
        If !Empty( mdiagnoz3 )
          mdiagnoz3 := Left( mdiagnoz3, Len( mdiagnoz3 ) -1 )
        Endif
        Select MOHU
        find ( Str( human->kod, 7 ) )
        Do While mohu->kod == human->kod .and. !Eof()
          If ( i := AScan( arr_sl, {| x| mohu->DATE_U >= x[ 4 ] .and. mohu->DATE_U2 <= x[ 5 ] } ) ) > 0
            arr_sl[ i, 8 ] += ';' + AllTrim( mosu->shifr1 )
          Endif
          Select MOHU
          Skip
        Enddo
        For i := 1 To Len( arr_sl )
          Select OTD
          Goto ( arr_sl[ i, 7 ] )
          Select TMP
          Append Blank
          tmp->ID_PAC   := human->kod_k
          tmp->ID_SL    := human->kod
          tmp->VID_MP   := iif( human_2->vmp > 0, 1, 0 )
          tmp->OSN_DIAG := mdiagnoz[ 1 ]
          tmp->SOP_DIAG := mdiagnoz2
          tmp->OSL_DIAG := mdiagnoz3
          tmp->DNI      := arr_sl[ i, 6 ]
          If arr_sl[ i, 1 ] == arr_sl[ i, 2 ]
            tmp->KOD_OTD := lstr( arr_sl[ i, 7 ] )
          Else
            tmp->KOD_OTD := arr_sl[ i, 2 ]
          Endif
          tmp->PROFIL   := inieditspr( A__MENUVERT, getv002(), arr_sl[ i, 3 ] )
          tmp->POL_PAC  := iif( iif( human_->NOVOR > 0, human_->pol2, human->pol ) == 'М', 1, 0 )
          tmp->DATE_ROG := full_date( iif( human_->NOVOR > 0, human_->date_r2, human->date_r ) )
          tmp->DATE_GOS := full_date( c4tod( arr_sl[ i, 4 ] ) )
          tmp->VIDVMP   := iif( human_2->vmp > 0, human_2->VIDVMP, '' )
          tmp->METVMP   := iif( human_2->vmp > 0, lstr( human_2->METVMP ), '' )
          tmp->REANIMAC := iif( arr_sl[ i, 3 ] == 5, lstr( arr_sl[ i, 6 ] ), '' )
          tmp->USLUGI   := arr_sl[ i, 8 ]
        Next
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  Close databases
  RestScreen( buf )
  If !fl_exit
    n_file := 'SVED'
    Copy File ( cur_dir() + 'tmp' + sdbf() ) to ( cur_dir() + n_file + sdbf() )
    n_message( { 'В каталоге ' + Upper( cur_dir() ), ;
      'создан файл ' + Upper( n_file + sdbf() ), ;
      'со сведениями о случаях лечения пациентов.' },, ;
      cColorStMsg, cColorStMsg,,, cColorSt2Msg )
  Endif

  Return Nil
