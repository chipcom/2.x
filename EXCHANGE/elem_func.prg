// функции для формирования элемента реестра пацентов
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 20.02.26
function elem_napr( oSl, arr_onkna, lDispans )

  local oNAPR
  local mNPR_MO, j

  For j := 1 To Len( arr_onkna )
    // заполним сведения о направлениях для XML-документа
    oNAPR := oSL:add( hxmlnode():new( 'NAPR' ) )
    mo_add_xml_stroke( oNAPR, 'NAPR_DATE', date2xml( arr_onkna[ j, 1 ] ) )

    If ! lDispans    // согласно ПУМП вер. 4.6 ( без поликлиники-диспансеризации)
      mo_add_xml_stroke( oNapr, 'NAPR_NUM', get_NAPR_MO( human->kod, _NPR_LECH ) )
    endif

    If !Empty( arr_onkna[ j, 5 ] ) .and. !Empty( mNPR_MO := ret_mo( arr_onkna[ j, 5 ] )[ _MO_KOD_FFOMS ] )
      mo_add_xml_stroke( oNAPR, 'NAPR_MO', mNPR_MO )
    Endif
    mo_add_xml_stroke( oNAPR, 'NAPR_V', lstr( arr_onkna[ j, 2 ] ) )
    If arr_onkna[ j, 2 ] == 3
      mo_add_xml_stroke( oNAPR, 'MET_ISSL', lstr( arr_onkna[ j, 3 ] ) )
      mo_add_xml_stroke( oNAPR, 'NAPR_USL', arr_onkna[ j, 4 ] )
    Endif
  Next j

  return nil

// 31.01.26
function elem_prescriptions( oSl, human_kod, mdata, arr_onkna )

  local oPRESCRIPTIONS, oPRESCRIPTION
  local arr_nazn, j //, arr_onkna
  local mNPR_MO

//  if is_oncology > 0
//    arr_onkna := collect_schet_onkna()
//  else
//    arr_onkna := {}
//  endif
  arr_nazn := prescriptions_dispans( human_kod, Year( mdata ) )

  If Len( arr_nazn ) > 0 .or. ( human->OBRASHEN == '1' .and. Len( arr_onkna ) > 0 )
    // заполним сведения о назначениях по результатам диспансеризации для XML-документа
    oPRESCRIPTION := oSL:add( hxmlnode():new( 'PRESCRIPTION' ) )
    For j := 1 To Len( arr_nazn )
      oPRESCRIPTIONS := oPRESCRIPTION:add( hxmlnode():new( 'PRESCRIPTIONS' ) )
      mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_N', lstr( j ) )
      mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_R', lstr( arr_nazn[ j, 1 ] ) )

      If !Empty( arr_nazn[ j, 3 ] )   // по новому ПУМП с 01.08.21
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_IDDOKT', arr_nazn[ j, 3 ] )
      Endif

      If !Empty( arr_nazn[ j, 4 ] )   // по новому ПУМП с 01.08.21
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SPDOCT', arr_nazn[ j, 4 ] )
      Endif

      If eq_any( arr_nazn[ j, 1 ], 1, 2 )
        // к какому специалисту направлен
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SP', arr_nazn[ j, 2 ] ) // результат ф-ии put_prvs_to_reestr(human_->PRVS, _NYEAR)
      Elseif arr_nazn[ j, 1 ] == 3
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_V', lstr( arr_nazn[ j, 2 ] ) )
        // if human->OBRASHEN == '1'
        // mo_add_xml_stroke(oPRESCRIPTIONS,'NAZ_USL',arr_nazn[j, 3]) // Мед.услуга (код), указанная в направлении
        // endif
      Elseif eq_any( arr_nazn[ j, 1 ], 4, 5 )
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_PMP', lstr( arr_nazn[ j, 2 ] ) )
      Elseif arr_nazn[ j, 1 ] == 6
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_PK', lstr( arr_nazn[ j, 2 ] ) )
      Endif
    Next j
    If human->OBRASHEN == '1' // подозрение на ЗНО
      For j := 1 To Len( arr_onkna )
        // заполним сведения о назначениях по результатам диспансеризации для XML-документа
        oPRESCRIPTIONS := oPRESCRIPTION:add( hxmlnode():new( 'PRESCRIPTIONS' ) )
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_N', lstr( j + Len( arr_nazn ) ) )
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_R', lstr( iif( arr_onkna[ j, 2 ] == 1, 2, arr_onkna[ j, 2 ] ) ) )

        If !Empty( arr_onkna[ j, 6 ] )   // по новому ПУМП с 01.08.21
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_IDDOKT', arr_onkna[ j, 6 ] )
        Endif

        If !Empty( arr_onkna[ j, 7 ] )   // по новому ПУМП с 01.08.21
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SPDOCT', arr_onkna[ j, 7 ] )
        Endif

        If arr_onkna[ j, 2 ] == 1 // направление к онкологу
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_SP', iif( human->VZROS_REB == 0, '41', '19' ) ) // спец-ть онкология или детская онкология
        Else // == 3 на дообследование
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_V', lstr( arr_onkna[ j, 3 ] ) )
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAZ_USL', arr_onkna[ j, 4 ] )
        Endif
        mo_add_xml_stroke( oPRESCRIPTIONS, 'NAPR_DATE', date2xml( arr_onkna[ j, 1 ] ) )
        If !Empty( arr_onkna[ j, 5 ] ) .and. !Empty( mNPR_MO := ret_mo( arr_onkna[ j, 5 ] )[ _MO_KOD_FFOMS ] )
          mo_add_xml_stroke( oPRESCRIPTIONS, 'NAPR_MO', mNPR_MO )
        Endif
      Next j
    Endif
  Endif

  return nil

// 28.10.25
function elem_lek_pr_zno( oONK, mdata, human_recno, mkod_human )

  // тэг Сведения о примененных лекарственных препаратах при химиотерапевтическом или химиолучевом лечении
  // добавим в xml-документ информацию о лекарственных препаратах

  local oLEK, oINJ, arrLP, aRegnum, i, iLekPr
  local old_lek, old_sh

  If mdata >= 0d20250101
    arrLP := collect_lek_pr( human_recno )
    If Len( arrLP ) > 0
      aRegnum := unique_val_in_array( arrLP, 3 ) // получим уникальные REGNUM
      For i := 1 To Len( aRegnum )
        // Соберем типы лек. препаратов
        // заполним сведения о примененных лекарственных препаратах при лечении онкологического больного для XML-документа
        oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
        mo_add_xml_stroke( oLEK, 'REGNUM', aRegnum[ i, 3 ] )
        mo_add_xml_stroke( oLEK, 'REGNUM_DOP', ;
          get_sootv_n021( aRegnum[ i, 2 ], aRegnum[ i, 3 ], mdata )[ 7 ] )
        mo_add_xml_stroke( oLEK, 'CODE_SH', aRegnum[ i, 2 ] )
        For iLekPr := 1 To Len( arrLp )
          If arrLP[ iLekPr, 3 ] == aRegnum[ i, 3 ]
            oINJ := oLek:add( hxmlnode():new( 'INJ' ) )
            mo_add_xml_stroke( oINJ, 'DATE_INJ', date2xml( arrLP[ iLekPr, 1 ] ) )
            mo_add_xml_stroke( oINJ, 'KV_INJ', Str( arrLP[ iLekPr, 5 ], 8, 3 ) )
            mo_add_xml_stroke( oINJ, 'KIZ_INJ', Str( arrLP[ iLekPr, 9 ], 8, 3 ) )
            mo_add_xml_stroke( oINJ, 'S_INJ', Str( arrLP[ iLekPr, 10 ], 15, 6 ) )
            mo_add_xml_stroke( oINJ, 'SV_INJ', ;
              Str( arrLP[ iLekPr, 5 ] * arrLP[ iLekPr, 10 ], 15, 2 ) )
            mo_add_xml_stroke( oINJ, 'SIZ_INJ', ;
              Str( arrLP[ iLekPr, 9 ] * arrLP[ iLekPr, 10 ], 15, 2 ) )
            mo_add_xml_stroke( oINJ, 'RED_INJ', Str( arrLP[ iLekPr, 11 ], 1, 0 ) )
          Endif
        Next
      Next
    Endif
  Else
    old_lek := Space( 6 )
    old_sh := Space( 10 )
//    Select ONKLE  // цикл по БД лекарств
    ONKLE->( dbSeek( Str( mkod_human, 7 ) ) )   //  find ( Str( mkod_human, 7 ) )
    Do While ONKLE->kod == mkod_human .and. ! ONKLE->( Eof() )
      If !( old_lek == ONKLE->REGNUM .and. old_sh == ONKLE->CODE_SH )
        // заполним сведения о примененных лекарственных препаратах при лечении онкологического больного для XML-документа
        oLEK := oONK:add( hxmlnode():new( 'LEK_PR' ) )
        mo_add_xml_stroke( oLEK, 'REGNUM', ONKLE->REGNUM )
        mo_add_xml_stroke( oLEK, 'CODE_SH', ONKLE->CODE_SH )
      Endif
      // цикл по датам приёма данного лекарства
      mo_add_xml_stroke( oLEK, 'DATE_INJ', date2xml( ONKLE->DATE_INJ ) )
      old_lek := ONKLE->REGNUM
      old_sh := ONKLE->CODE_SH
//      Select ONKLE
      ONKLE->( dbSkip() )   //  Skip
    Enddo
  Endif
  return nil

// 27.10.25
function elem_lek_pr( oSl, mkod_human )

  // тэг Сведения о введенных лекарственных препаратах (за исключением случаев оказания высокотехнологичной медицинской помощи и 
  // медицинской помощи при ЗНО)
  // добавим в xml-документ информацию о лекарственных препаратах

  local oLEK, oDOSE
  local arrLP, row

  arrLP := collect_lek_pr( mkod_human )
  If Len( arrLP ) != 0
    For Each row in arrLP
      oLEK := oSL:add( hxmlnode():new( 'LEK_PR' ) )
      mo_add_xml_stroke( oLEK, 'DATA_INJ', date2xml( row[ 1 ] ) )
      mo_add_xml_stroke( oLEK, 'CODE_SH', row[ 8 ] )
      If ! Empty( row[ 3 ] )
        mo_add_xml_stroke( oLEK, 'REGNUM', row[ 3 ] )
        // mo_add_xml_stroke(oLEK, 'CODE_MARK', '')  // для дальнейшего использования
        oDOSE := oLEK:add( hxmlnode():new( 'LEK_DOSE' ) )
        mo_add_xml_stroke( oDOSE, 'ED_IZM', Str( row[ 4 ], 3, 0 ) )
        mo_add_xml_stroke( oDOSE, 'DOSE_INJ', Str( row[ 5 ], 8, 2 ) )
        mo_add_xml_stroke( oDOSE, 'METHOD_INJ', Str( row[ 6 ], 3, 0 ) )
        mo_add_xml_stroke( oDOSE, 'COL_INJ', Str( row[ 7 ], 5, 0 ) )
      Endif
    Next
  Endif
  return nil

// 27.10.25
function elem_med_dev( oUsl, human_kod, mohu_recno )

  // тэг о Сведения о медицинских изделиях, имплантируемых в организм человека

  local oMED_DEV, row

  For Each row in collect_implantant( human_kod, mohu_recNo )
    oMED_DEV := oUSL:add( hxmlnode():new( 'MED_DEV' ) )
    mo_add_xml_stroke( oMED_DEV, 'DATE_MED', date2xml( row[ 3 ] ) )
    mo_add_xml_stroke( oMED_DEV, 'CODE_MEDDEV', lstr( row[ 4 ] ) )
    mo_add_xml_stroke( oMED_DEV, 'NUMBER_SER', AllTrim( row[ 5 ] ) )
  Next
  return nil

// 27.10.25
function elem_mr_usl_n( oUsl, nyear, number, prvs, snils )

  // тэг о мед. работниках выполнивших услугу

  local oMR_USL_N

  oMR_USL_N := oUSL:add( hxmlnode():new( 'MR_USL_N' ) )
  mo_add_xml_stroke( oMR_USL_N, 'MR_N', lstr( number ) )   // пока ставим 1 исполнитель
  mo_add_xml_stroke( oMR_USL_N, 'PRVS', put_prvs_to_reestr( prvs, nyear ) )
  mo_add_xml_stroke( oMR_USL_N, 'CODE_MD', snils )
  return nil

// 26.10.25
function elem_ksg( oSl, lshifr_zak_sl, mdata, is_oncology )

  // тэг добавляется только для реестров 1 типа и помощь в условиях дневного
  // и кругосуточного стационара

  Local dPUMPver40 := 0d20240301
  local oKSG, oSLk
  Local akslp, iAKSLP, tKSLP, cKSLP // массив, счетчик для цикла по КСЛП
  Local akiro

  // заполним сведения о КСГ для XML-документа
  akslp := {}
  akiro := {}
  oKSG := oSL:add( hxmlnode():new( 'KSG_KPG' ) )
  mo_add_xml_stroke( oKSG, 'N_KSG', lshifr_zak_sl )

  If mdata >= dPUMPver40   // дата окончания случая после 01.03.24
    mo_add_xml_stroke( oKSG, 'K_ZP', '1' )  // пока ставим 1
  Endif

  If !Empty( human_2->pc3 ) .and. !Left( human_2->pc3, 1 ) == '6' // кроме 'старости'
    mo_add_xml_stroke( oKSG, 'CRIT', human_2->pc3 )
  Elseif is_oncology  == 2
    If !Empty( onksl->crit ) .and. !( AllTrim( onksl->crit ) == 'нет' )
      mo_add_xml_stroke( oKSG, 'CRIT', onksl->crit )
    Endif
    If !Empty( onksl->crit2 )
      mo_add_xml_stroke( oKSG, 'CRIT', onksl->crit2 )  // второй критерий
    Endif
  Endif

  If ! Empty( human_2->pc1 )
    akslp := list2arr( human_2->pc1 )
  Endif

  mo_add_xml_stroke( oKSG, 'SL_K', iif( Empty( akslp ), '0', '1' ) )
  If !Empty( akslp )
    // заполним сведения о КСГ для XML-документа
    If Year( human->K_DATA ) >= 2021     // 02.02.21 Байкин
      tKSLP := getkslptable( human->K_DATA )

      mo_add_xml_stroke( oKSG, 'IT_SL', lstr( ret_koef_kslp_21_xml( akslp, tKSLP, Year( human->K_DATA ) ), 7, 5 ) )

      For iAKSLP := 1 To Len( akslp )
        If ( cKSLP := AScan( tKSLP, {| x| x[ 1 ] == akslp[ iAKSLP ] } ) ) > 0
          oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
          mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ iAKSLP ] ) )
          mo_add_xml_stroke( oSLk, 'VAL_C', lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
        Endif
      Next
    Else
/*
      mo_add_xml_stroke( oKSG, 'IT_SL', lstr( ret_koef_kslp( akslp ), 7, 5 ) )
      oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
      mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ 1 ] ) )
      mo_add_xml_stroke( oSLk, 'VAL_C', lstr( akslp[ 2 ], 7, 5 ) )
      If Len( akslp ) >= 4
        oSLk := oKSG:add( hxmlnode():new( 'SL_KOEF' ) )
        mo_add_xml_stroke( oSLk, 'ID_SL', lstr( akslp[ 3 ] ) )
        mo_add_xml_stroke( oSLk, 'VAL_C', lstr( akslp[ 4 ], 7, 5 ) )
      Endif
*/
    Endif
  Endif

  If ! Empty( human_2->pc2 )
    akiro := list2arr( human_2->pc2 )
  Endif
  If ! Empty( akiro )
    // заполним сведения о КИРО для XML-документа
    oSLk := oKSG:add( hxmlnode():new( 'S_KIRO' ) )
    mo_add_xml_stroke( oSLk, 'CODE_KIRO', lstr( akiro[ 1 ] ) )
    mo_add_xml_stroke( oSLk, 'VAL_K', lstr( akiro[ 2 ], 4, 2 ) )
  Endif
  return nil

// 25.12.25
function elem_disability( oPac )

  // тэг добавляется только для реестров 1 типа и амбулаторно-поликлинической помощи в
  // учреждениях имеющих прикрепленное население
  
  local oDISAB
  Local tmpSelect

  if Between( kart_->INVALID, 1, 4 )                   // инвалид
    tmpSelect := Select()
    dbSelectArea( 'INV' )
    inv->( dbSeek( Str( human->kod_k, 7 ) ) )
    If inv->( Found() ) .and. ! ( empty( inv->DATE_INV ) .or. Empty( inv->PRICH_INV ) )
      // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
      if ( inv->DATE_INV < human->n_data .and. human->n_data <= AddMonth( inv->DATE_INV, 12 ) )
        if Year( human->k_data ) >= 2026  // ПУМП от 22.12.25 № 04-18-23
          mo_add_xml_stroke( oPAC, 'INV', lstr( kart_->invalid ) )   // группа инвалидности при первичном признании застрахованного лица инвалидом
        else  // старый ПУМП
          // заполним сведения об инвалидности пациента для XML-документа
          oDISAB := oPAC:add( hxmlnode():new( 'DISABILITY' ) )
          // группа инвалидности при первичном признании застрахованного лица инвалидом
          mo_add_xml_stroke( oDISAB, 'INV', lstr( kart_->invalid ) )
          // Дата первичного установления инвалидности
          mo_add_xml_stroke( oDISAB, 'DATA_INV', date2xml( inv->DATE_INV ) )
          // Код причины установления  инвалидности
          mo_add_xml_stroke( oDISAB, 'REASON_INV', lstr( inv->PRICH_INV ) )
          If !Empty( inv->DIAG_INV ) // Код основного заболевания по МКБ-10
            mo_add_xml_stroke( oDISAB, 'DS_INV', inv->DIAG_INV )
          Endif
        endif
      endif
    Endif
    Select( tmpSelect )
  Endif
  return nil

// 20.08.25
Function schet_smoname()

  Local cRet

  cRet := ''
  If AllTrim( human_->smo ) == '34'
    cRet := ret_inogsmo_name( 2 )
  Endif

  Return cRet

// 19.08.25
Function schet_is_oncology( p_tip_reestr, /*@*/is_oncology_smp )

  is_oncology_smp := 0

  Return iif( p_tip_reestr == TYPE_REESTR_DISPASER, 0, f_is_oncology( 1, @is_oncology_smp ) )

// 19.08.25
Function collect_schet_onkna()

  Local arr_onkna, tmpSelect

  tmpSelect := Select()
  arr_onkna := {}
  dbSelectArea( 'ONKNA' )
  onkna->( dbSeek( Str( human->kod, 7 ) ) )
  Do While onkna->kod == human->kod .and. !onkna->( Eof() )
    P2TABN->( dbGoto( onkna->KOD_VR ) )
    If !( P2TABN->( Eof() ) ) .and. !( P2TABN->( Bof() ) )
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, P2TABN->snils, lstr( ret_prvs_v015tov021( P2TABN->PRVS_NEW ) ) } )
    Else
      mosu->( dbGoto( onkna->U_KOD ) )
      AAdd( arr_onkna, { onkna->NAPR_DATE, onkna->NAPR_V, onkna->MET_ISSL, mosu->shifr1, onkna->NAPR_MO, '', '' } )
    Endif
    onkna->( dbSkip() )
  Enddo
  Select( tmpSelect )

  Return arr_onkna

// 19.08.25
Function collect_schet_onkco()

  Local arr_onkco, tmpSelect

  tmpSelect := Select()
  arr_onkco := {}
  dbSelectArea( 'ONKCO' )
  onkco->( dbSeek( Str( human->kod, 7 ) ) )
  Select( tmpSelect )

  Return arr_onkco

// 19.08.25
Function collect_schet_onksl()

  Local arr_onksl, tmpSelect

  tmpSelect := Select()
  arr_onksl := {}
  dbSelectArea( 'ONKSL' )
  onksl->( dbSeek( Str( human->kod, 7 ) ) )
  Select( tmpSelect )

  Return arr_onksl

// 19.08.25
Function collect_schet_onkdi()

  Local arr_onkdi, tmpSelect

  tmpSelect := Select()
  arr_onkdi := {}
  dbSelectArea( 'ONKSL' )
  onksl->( dbSeek( Str( human->kod, 7 ) ) )

  If eq_any( onksl->b_diag, 98, 99 )
    dbSelectArea( 'ONKDI' )
    onkdi->( dbSeek( Str( human->kod, 7 ) ) )
    Do While onkdi->kod == human->kod .and. !Eof()
      AAdd( arr_onkdi, { onkdi->DIAG_DATE, onkdi->DIAG_TIP, onkdi->DIAG_CODE, onkdi->DIAG_RSLT } )
      onkdi->( dbSkip() )
    Enddo
  Endif
  Select( tmpSelect )

  Return arr_onkdi

// 19.08.25
Function collect_schet_onkpr()

  Local arr_onkpr, tmpSelect

  tmpSelect := Select()
  arr_onkpr := {}
  dbSelectArea( 'ONKSL' )
  onksl->( dbSeek( Str( human->kod, 7 ) ) )

  If human_->USL_OK < 3 // противопоказания по лечению только в стационаре и дневном стационаре
    dbSelectArea( 'ONKPR' )
    onkpr->( dbSeek( Str( human->kod, 7 ) ) )
    Do While onkpr->kod == human->kod .and. ! onkpr->( Eof() )
      AAdd( arr_onkpr, { onkpr->PROT, onkpr->D_PROT } )
      onkpr->( dbSkip() )
    Enddo
  Endif
  If eq_any( onksl->b_diag, 0, 7, 8 ) .and. AScan( arr_onkpr, {| x| x[ 1 ] == onksl->b_diag } ) == 0
    // добавим отказ,не показано,противопоказано по гистологии
    AAdd( arr_onkpr, { onksl->b_diag, human->n_data } )
  Endif
  Select( tmpSelect )

  Return arr_onkpr

// 19.08.25
Function collect_schet_onkusl()

  Local arr_onkusl, tmpSelect

  tmpSelect := Select()
  arr_onkusl := {}
  If iif( human_2->VMP == 1, .t., Between( onksl->DS1_T, 0, 2 ) )
    dbSelectArea( 'ONKUS' )
    onkus->( dbSeek( Str( human->kod, 7 ) ) )
    Do While onkus->kod == human->kod .and. !onkus->( Eof() )
      If Between( onkus->USL_TIP, 1, 5 )
        AAdd( arr_onkusl, onkus->USL_TIP )
      Endif
      onkus->( dbSkip() )
    Enddo
  Endif
  Select( tmpSelect )

  Return arr_onkusl

/*
// 26.10.25
Function is_disability( p_tip_reestr )

  Local fl_DISABILITY := .f.
  Local tmpSelect

  If p_tip_reestr == TYPE_REESTR_GENERAL
    If glob_mo()[ _MO_IS_UCH ] .and. ;                      // наше МО имеет прикреплённое население
        human_->USL_OK == USL_OK_POLYCLINIC .and. ;                    // поликлиника
        kart2->MO_PR == glob_mo()[ _MO_KOD_TFOMS ] .and. ;  // прикреплён к нашему МО
        Between( kart_->INVALID, 1, 4 )                   // инвалид
      tmpSelect := Select()
      dbSelectArea( 'INV' )
      inv->( dbSeek( Str( human->kod_k, 7 ) ) )
      If inv->( Found() ) .and. ! emptyany( inv->DATE_INV, inv->PRICH_INV )
        // дата начала лечения отстоит от даты первичного установления инвалидности не более чем на год
        fl_DISABILITY := ( inv->DATE_INV < human->n_data .and. human->n_data <= AddMonth( inv->DATE_INV, 12 ) )
      Endif
      Select( tmpSelect )
    Endif
  Endif

  Return fl_DISABILITY
*/

// 19.08.25 необходимо ли вывести характер заболевания в реестр
Function need_reestr_c_zab_2025( is_oncology, lUSL_OK, osn_diag )

  Local fl := .f.

  If lUSL_OK < 4
    If lUSL_OK == 3 .and. !( Left( osn_diag, 1 ) == 'Z' )
      fl := .t. // условия оказания <амбулаторно> (USL_OK=3) и основной диагноз не из группы Z00-Z99
    Elseif is_oncology == 2
      fl := .t. // при установленном ЗНО
    Endif
  Endif

  Return fl
