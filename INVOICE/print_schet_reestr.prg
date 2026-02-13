#include 'function.ch'
#include 'chip_mo.ch'

// 12.09.25
function schet_reestr( arr, destination, one, reg )
  // arr - массив счетов
  // destination - целевой каталог
  // one - флаг печати одиночного счета, .t. - да, .f. - нет
  // reg - что печаем, если one == .t., 1 - счет, 2 - реестр счета

  Local adbf, adbf1, i, j, s, ii := 0, fl_numeration := .f., ;
    lshifr, lshifr1, ldate, ldate1, ldate2, hGauge, iSchet
  local  buf := save_maxrow()
  local sinn, skpp, fl, fl_2, lal
  local a_diag, is_zak_sl, is_zak_sl_d, is_zak_sl_v, lst, kol_dn, mcena, lvidpom, au

  local fNameSchet, fNameReestr, tailName, fError

  default reg to 0, one to .t.
  if ! one
    fError := tfiletext():new( cur_dir() + 'error_pdf.txt', , .t., , .t. ) 
    fError:width := 80
  endif
  mywait()
  adbf := { { 'name', 'C', 130, 0 }, ;
    { 'name_schet', 'C', 130, 0 }, ;
    { 'adres', 'C', 110, 0 }, ;
    { 'ogrn', 'C', 15, 0 }, ;
    { 'inn', 'C', 12, 0 }, ;
    { 'kpp', 'C', 9, 0 }, ;
    { 'bank', 'C', 130, 0 }, ;
    { 'r_schet', 'C', 45, 0 }, ;
    { 'bik', 'C', 10, 0 }, ;
    { 'ruk', 'C', 20, 0 }, ;
    { 'bux', 'C', 20, 0 }, ;
    { 'k_schet', 'C', 45, 0 }, ;
    { 'ispolnit', 'C', 20, 0 }, ;
    { 'plat', 'C', 250, 0 }, ;
    { 'nschet', 'C', 20, 0 }, ;
    { 'dschet', 'C', 30, 0 }, ;
    { 'date_begin', 'C', 30, 0 }, ;
    { 'date_end', 'C', 30, 0 }, ;
    { 'date_podp', 'C', 13, 0 }, ;
    { 'susluga', 'C', 250, 0 }, ;
    { 'summa', 'N', 15, 2 } }

  adbf1 := { { 'nomer', 'N', 4, 0 }, ;
    { 'fio', 'C', 50, 0 }, ;
    { 'pol', 'C', 10, 0 }, ;
    { 'date_r', 'C', 10, 0 }, ;
    { 'mesto_r', 'C', 100, 0 }, ;
    { 'pasport', 'C', 50, 0 }, ;
    { 'adresp', 'C', 250, 0 }, ;
    { 'adresg', 'C', 250, 0 }, ;
    { 'snils', 'C', 50, 0 }, ;
    { 'polis', 'C', 50, 0 }, ;
    { 'vid_pom', 'C', 10, 0 }, ;
    { 'diagnoz', 'C', 10, 0 }, ;
    { 'n_data', 'C', 10, 0 }, ;
    { 'k_data', 'C', 10, 0 }, ;
    { 'ob_em', 'N', 5, 0 }, ;
    { 'profil', 'C', 10, 0 }, ;
    { 'vrach', 'C', 10, 0 }, ;
    { 'cena', 'N', 12, 2 }, ;
    { 'stoim', 'N', 12, 2 }, ;
    { 'rezultat', 'C', 10, 0 } }

  r_use( dir_server() + 'organiz', , 'ORG' )
  use_base( 'lusl' )
  r_use( dir_server() + 'uslugi1', { dir_server() + 'uslugi1', ;
    dir_server() + 'uslugi1s' }, 'USL1' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  Set Relation To u_kod into USL

  r_use_base( 'kartotek', , .f. ) // индексы не нужны

  g_use( dir_server() + 'human_3', { dir_server() + 'human_3', dir_server() + 'human_32' }, 'HUMAN_3' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', dir_server() + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To kod_k into KART

  For iSchet := 1 To Len( arr )
    schet->( dbGoto( arr[ iSchet ] ) )  // встанем на счет
    delfrfiles()
    dbCreate( fr_titl, adbf )
    dbCreate( fr_data, adbf1 )

    tailName := AllTrim( glob_mo[ _MO_KOD_TFOMS ] ) ;
      + iif( AllTrim( schet_->SMO ) == '34', 'T34', 'S' + AllTrim( schet_->SMO ) ) ;
      + '_' + AllTrim( schet_->nschet ) + '_' ;
      + str( Year( schet_->DSCHET ), 4 ) + StrZero( Month( schet_->DSCHET ), 2 ) + StrZero( Day( schet_->DSCHET ), 2 )  + '.pdf'
    fNameSchet := destination + 'SCM' + tailName
    fNameReestr := destination + 'SRM' + tailName
  
    Use ( fr_data ) New Alias FRD
    Index On Str( FIELD->nomer, 4 ) to ( fr_data )
    
    Use ( fr_titl ) New Alias FRT
//    Append Blank
    frt->( dbAppend() )
    frt->name := frt->name_schet := org->name
    If !Empty( org->name_schet )
      frt->name_schet := org->name_schet
    Endif
    s := AllTrim( org->adres )
    If !Empty( CharRem( '-', org->telefon ) )
      s += ' тел.' + AllTrim( org->telefon )
    Endif
    frt->adres := s
    frt->ogrn := org->ogrn
    sinn := org->inn
    skpp := ''
    If '/' $ sinn
      skpp := AfterAtNum( '/', sinn )
      sinn := BeforAtNum( '/', sinn )
    Endif
    frt->inn := sinn
    frt->kpp := skpp
    frt->bank := org->bank
    frt->r_schet := org->r_schet
    frt->bik := org->smfo
    frt->ruk := org->ruk
    frt->bux := org->bux
    frt->k_schet := org->k_schet
    frt->ispolnit := org->ispolnit
    frt->date_podp := full_date( sys_date ) + ' г.'

    s := ''
    If ( j := AScan( get_rekv_smo(), {| x| x[ 1 ] == schet_->SMO } ) ) > 0
      s := get_rekv_smo()[ j, 2 ]
    Elseif schet->str_crb > 0
      If schet->komu == 3
        s := inieditspr( A__POPUPMENU, dir_server() + 'komitet', schet->str_crb )
      Else
        s := inieditspr( A__POPUPMENU, dir_server() + 'str_komp', schet->str_crb )
      Endif
    Endif
    frt->plat := s
    frt->nschet := schet_->nschet
    frt->dschet := date_month( schet_->dschet )

    s := 'За медицинскую помощь, оказанную '
    If !Empty( schet_->SMO )
      s += 'застрахованным лицам '
    Endif
    If ! emptyany( schet_->nyear, schet_->nmonth )
      s += 'за ' + mm_month[ schet_->nmonth ] + Str( schet_->nyear, 5 ) + ' года'
      ldate := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '01' )
      frt->date_begin := date_month( ldate )
      frt->date_end   := date_month( EoM( ldate ) )
    Else
      s := 'За оказанную медицинскую помощь'
      fl_numeration := .t.
    Endif
    frt->susluga := s
    frt->summa := schet->summa
altd()
  if ! one .or. ( one .and. reg == 2 )
    hGauge := gaugenew( , , { 'GR+/RB', 'BG+/RB', 'G+/RB' }, 'Составление реестра счёта № ' + AllTrim( schet_->nschet ), .t. )
    gaugedisplay( hGauge )
    Select HUMAN
    find ( Str( schet->kod, 6 ) )
    Do While human->schet == schet->kod .and. !Eof()
      fl := .t.
      fl_2 := .f.
      lal := 'human'
      If human->ishod == 88
        fl_2 := .t.
        lal += '_3'
        Select HUMAN_3
        find ( Str( human->kod, 7 ) )
      Elseif human->ishod == 89
        fl := .f. // второй случай в двойном пропускаем
      Endif
      If fl
        gaugeupdate( hGauge, ++ii / schet->kol )
        ldate1 := iif( ldate1 == nil, &lal.->k_data, Min( ldate1, &lal.->k_data ) )
        ldate2 := iif( ldate2 == nil, &lal.->k_data, Max( ldate2, &lal.->k_data ) )
        a_diag := diag_for_xml( , .t., , , .t. )
        is_zak_sl := is_zak_sl_d := is_zak_sl_v := .f.
        lst := kol_dn := mcena := 0
        lvidpom := 1
        au := {}
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While hu->kod == human->kod .and. !Eof()
          lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
          If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , @lst )
            lshifr := AllTrim( iif( Empty( lshifr1 ), usl->shifr, lshifr1 ) )
            If ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
              lvidpom := i
            Endif
            If Left( lshifr, 5 ) == '55.1.' // дневной стационар с 1 апреля 2013 года
              kol_dn += hu->KOL_1
            Elseif eq_any( Left( lshifr, 4 ), '55.2', '55.3', '55.4' ) // старый дневной стационар
              kol_dn += hu->KOL_1
              mcena := hu->u_cena
            Elseif Left( lshifr, 2 ) == '1.'
              kol_dn += hu->KOL_1
              mcena := hu->u_cena
            Endif
            If lst == 1
              If Left( lshifr, 2 ) == '1.'
                is_zak_sl := .t.
                mcena := hu->u_cena
              Elseif Left( lshifr, 3 ) == '55.'
                If human->k_data < 0d20130401 // дневной стационар до 1 апреля 2013
                  is_zak_sl_d := .t.
                Endif
                mcena := hu->u_cena
              Elseif f_is_zak_sl_vr( lshifr ) // зак.случай в п-ке
                is_zak_sl_v := .t.
                mcena := hu->u_cena
              Endif
            Else
              j := AScan( au, {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu->date_u } )
              If j == 0
                AAdd( au, { lshifr, hu->date_u, 0, hu->u_cena } )
                j := Len( au )
              Endif
              au[ j, 3 ] += hu->kol_1
            Endif
          Endif
          Select HU
          Skip
        Enddo
        If fl_2
          kol_dn := human_3->k_data - human_3->n_data
        Elseif is_zak_sl
          kol_dn := human->k_data - human->n_data
        Elseif is_zak_sl_d
          kol_dn := human->k_data - human->n_data + 1
        Elseif is_zak_sl_v
          For j := 1 To Len( au )
            If Left( au[ j, 1 ], 2 ) == '2.'
              kol_dn += au[ j, 3 ]
            Endif
          Next
        Elseif Empty( kol_dn )
          For j := 1 To Len( au )
            kol_dn += au[ j, 3 ]
          Next
          If kol_dn > 0
            mcena := round_5( human->cena_1 / kol_dn, 2 )
            If !( Round( mcena, 2 ) == Round( au[ 1, 4 ], 2 ) )
              kol_dn := mcena := 0
            Endif
          Endif
        Endif
        Select FRD
altd()
//        Append Blank
        frd->( dbAppend() )
        frd->nomer := iif( fl_numeration, ii, human_->SCHET_ZAP )
        frd->fio := human->fio
        frd->pol := iif( human->pol == 'М', 'муж', 'жен' )
        frd->date_r := full_date( human->date_r )
        frd->mesto_r := kart_->mesto_r
        s :=  get_name_vid_ud( kart_->vid_ud, , ' ' )
        If !Empty( kart_->ser_ud )
          s += AllTrim( kart_->ser_ud ) + ' '
        Endif
        If !Empty( kart_->nom_ud )
          s += AllTrim( kart_->nom_ud )
        Endif
        frd->pasport := s
        frd->adresg := ret_okato_ulica( kart->adres, kart_->okatog, 0, 2 )
        If Empty( kart_->okatop )
          frd->adresp := frd->adresg
        Else
          frd->adresp := ret_okato_ulica( kart_->adresp, kart_->okatop, 0, 2 )
        Endif
        If !Empty( kart->snils )
//          frd->snils := Transform( kart->SNILS, picture_pf )
          frd->snils := Transform_SNILS( kart->SNILS )
        Endif
        frd->polis := AllTrim( AllTrim( human_->SPOLIS ) + ' ' + human_->NPOLIS )
        frd->vid_pom := lstr( lvidpom )
        If diagnosis_for_replacement( a_diag[ 1 ], human_->USL_OK )
          frd->diagnoz := a_diag[ 2 ]
        Else
          frd->diagnoz := a_diag[ 1 ]
        Endif
        frd->n_data := full_date( &lal.->n_data )
        frd->k_data := full_date( &lal.->k_data )
        frd->ob_em := kol_dn
        If human_->PROFIL > 0
          frd->profil := lstr( human_->PROFIL )
        Endif
        If !Empty( human_->PRVS )
          frd->vrach := put_prvs_to_reestr( human_->PRVS, schet_->nyear )
          lstr( Abs( human_->PRVS ) )
        Endif
        If fl_2
          frd->cena := frd->stoim := human_3->cena_1
          frd->rezultat := lstr( human_3->RSLT_NEW )
        Else
          frd->cena := mcena
          frd->stoim := human->cena_1
          frd->rezultat := lstr( human_->RSLT_NEW )
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    If fl_numeration .and. !emptyany( ldate1, ldate2 )
      frt->date_begin := date_month( ldate1 )
      frt->date_end   := date_month( ldate2 )
    Endif
    closegauge( hGauge )
  endif

  frd->( dbGoTop() )
altd()
  if one
    frd->( dbCloseArea() )
    frt->( dbCloseArea() )
    if reg == 1
      call_fr( 'mo_schet' )
    elseif reg == 2
      call_fr( 'mo_reesv' )
    endif
  else
    print_pdf_order( fNameSchet, fError )
    print_pdf_reestr( fNameReestr, fError )
    frd->( dbCloseArea() )
    frt->( dbCloseArea() )
  endif

  next
  org->( dbCloseArea() )
  close_use_base( 'kartotek' )
  close_use_base( 'lusl' )
  usl1->( dbCloseArea() )
  usl->( dbCloseArea() )
  hu->( dbCloseArea() )
  human_3->( dbCloseArea() )
  human_->( dbCloseArea() )
  human->( dbCloseArea() )
  rest_box( buf )
  return nil
