// mo_mzxml.prg создание XML-файлов для загрузки на портал МинЗдрава РФ
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 12.09.25 создать XML-файл по несовершеннолетним
Function mo_mzxml_n( _regim, n_file, stitle, lvozrast )

  Static oXmlDoc, _kol, sname_xml, ;
    arr_np := { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 18, 24, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144, 156, 168, 180, 192, 204 }
  Local i, k, s, y, m, d, fl, arr, arr1, buf, blk_sex, arr_before

  Private p_xml_code_page := 'UTF-8'

  If _regim == 1
    oXmlDoc := hxmldoc():new( p_xml_code_page )
    oXmlDoc:add( hxmlnode():new( 'children' ) )
    _kol := 0
    r_use( dir_server() + 'organiz', , 'ORG' )
    sname_xml := AllTrim( org->name_xml )
    Use
  Elseif _regim == 2
    ++_kol
    oChild := oXmlDoc:aItems[ 1 ]:add( hxmlnode():new( 'child' ) )
    mo_add_xml_stroke( oChild, 'idInternal', human_->ID_PAC )
    s := iif( eq_any( p_tip_lu, TIP_LU_DDS, TIP_LU_DDSOP ), '1', '3' )
    mo_add_xml_stroke( oChild, 'idType', s )
    arr := retfamimot( 2, .f. )
    oName := oChild:add( hxmlnode():new( 'name' ) )
    mo_add_xml_stroke( oName, 'last', arr[ 1 ] )
    mo_add_xml_stroke( oName, 'first', arr[ 2 ] )
    If !Empty( arr[ 3 ] )
      mo_add_xml_stroke( oName, 'middle', arr[ 3 ] )
    Endif
    mo_add_xml_stroke( oChild, 'idSex', iif( mpol == 'М', '1', '2' ) )
    mo_add_xml_stroke( oChild, 'dateOfBirth', date2xml( mdate_r ) )
    If !( Type( 'm1kateg_uch' ) == 'N' ) .or. !Between( m1kateg_uch, 0, 3 )
      m1kateg_uch := 3
    Endif
    Do Case
    Case m1kateg_uch == 0 // ребенок-сирота', 0
      i := 1
    Case m1kateg_uch == 1 // ребенок, оставшийся без попечения родителей', 1
      i := 3
    Case m1kateg_uch == 2 // ребенок, находящийся в трудной жизненной ситуации', 2
      i := 2
    Case m1kateg_uch == 3 // нет категории', 3
      i := 4
    Endcase
    mo_add_xml_stroke( oChild, 'idCategory', lstr( i ) )
    mo_add_xml_stroke( oChild, 'idDocument', iif( kart_->vid_ud == 14, '14', '3' ) )
    If Empty( s := AllTrim( kart_->ser_ud ) )
      s := '-'
    Endif
    mo_add_xml_stroke( oChild, 'documentSer', s )
    If Empty( s := AllTrim( kart_->nom_ud ) )
      s := '111111'
    Endif
    mo_add_xml_stroke( oChild, 'documentNum', s )
    If !Empty( kart->snils ) .and. val_snils( kart->snils, 2 )
//      s := CharRepl( ' ', Transform( kart->SNILS, picture_pf ), '-' )
      s := CharRepl( ' ', Transform_SNILS( kart->SNILS ), '-' )
      mo_add_xml_stroke( oChild, 'snils', s )
    Else
      i := 2 // другое
      Store 0 To m, d, y
      count_ymd( human->date_r, human->n_data, @y, @m, @d ) // реальный возраст на начало
      If y == 0 .and. m == 0 // ребёнку менее 1 месяца
        i := 0 // новорожденный
      Endif
      If !Empty( kart_->strana ) .and. !( kart_->strana == '643' ) .and. AScan( geto001(), {| x| x[ 2 ] == kart_->strana } ) > 0
        i := 1 // иностранный гражданин
      Endif
      mo_add_xml_stroke( oChild, 'without_snils_reason', lstr( i ) )
      If i == 2
        i := Random() % 3 + 1
        If !Between( i, 1, 3 )
          i := 1
        Endif
        s := { 'Утерян', 'Не представлен', 'Не предоставлен' }[ i ]
        mo_add_xml_stroke( oChild, 'without_snils_other', s )
      Endif
    Endif
    If !Empty( human_->SPOLIS )
      mo_add_xml_stroke( oChild, 'polisSer', human_->SPOLIS )
    Endif
    If Empty( s := AllTrim( human_->NPOLIS ) )
      s := '3400000000000000'
    Endif
    mo_add_xml_stroke( oChild, 'polisNum', s )
    mo_add_xml_stroke( oChild, 'idInsuranceCompany', iif( human_->smo == '34002', '115', '290' ) )
    If Len( sname_xml ) > 5
      mo_add_xml_stroke( oChild, 'medSanName', sname_xml )
    Else
      mo_add_xml_stroke( oChild, 'medSanName', ret_mo( m1MO_PR )[ _MO_FULL_NAME ] )
    Endif
    mo_add_xml_stroke( oChild, 'medSanAddress', ret_mo( m1MO_PR )[ _MO_ADRES ] )
    oAddress := oChild:add( hxmlnode():new( 'address' ) )
    // mo_add_xml_stroke(oAddress, 'fiasAoid', '') // код города проживания по ФИАС
    // mo_add_xml_stroke(oAddress, 'cityName', '')   // строковое наименование пункта проживания
    mo_add_xml_stroke( oAddress, 'regionCode', '34' )   // код региона по ФИАС
    mo_add_xml_stroke( oAddress, 'fiasAoid', 'af757d44-3438-4040-9b68-d95099318998' ) // код города проживания по ФИАС
    If eq_any( p_tip_lu, TIP_LU_PREDN, TIP_LU_PERN )  // if type('m1school') == 'N' .and. m1school > 0
      mo_add_xml_stroke( oChild, 'idEducationOrg', '90713' )  // лицей 5
    Endif
    If eq_any( p_tip_lu, TIP_LU_DDS, TIP_LU_DDSOP )
      s := '0'
      If Type( 'm1gde_nahod' ) == 'N' .and. Between( m1gde_nahod, 0, 5 )
        Do Case
        Case m1gde_nahod == 3 // передан в приемную семью
          s := '4'
        Case m1gde_nahod == 4 // передан в патронатную семью
          s := '8'
        Case m1gde_nahod == 5 // усыновлен (удочерена)
          s := '3'
        Otherwise
          s := lstr( m1gde_nahod )
        Endcase
      Endif
      mo_add_xml_stroke( oChild, 'idOrphHabitation', s )
      If Empty( mdate_post )
        mdate_post := mn_data -1
      Endif
      mo_add_xml_stroke( oChild, 'dateOrphHabitation', date2xml( mdate_post ) )
    Endif
    /*if type('m1stacionar') == 'N' .and. m1stacionar > 0
      mo_add_xml_stroke(oChild, 'idStacOrg', '0')
    endif*/
    oCards := oChild:add( hxmlnode():new( 'cards' ) )
    // будем делать одно лечение
    oCard := oCards:add( hxmlnode():new( 'card' ) )
    mo_add_xml_stroke( oCard, 'idInternal', human_->ID_C )
    mo_add_xml_stroke( oCard, 'dateOfObsled', date2xml( MN_DATA ) )
    If p_tip_lu == TIP_LU_PN
      mperiod := ret_period_pn( mdate_r, mn_data, mk_data )
      If !Between( mperiod, 1, 31 )
        mperiod := 31
      Endif
      mo_add_xml_stroke( oCard, 'ageObsled', lstr( arr_np[ mperiod ] ) )
      i := 2 // профилактика 1 и 2 этап
    Elseif p_tip_lu == TIP_LU_PREDN
      i := 3 // пред.осмотры 1 и 2 этап
    Elseif p_tip_lu == TIP_LU_PERN
      i := 4 // период.осмотры
    Else
      y := m := 0
      count_ymd( mdate_r, mn_data, @y, @m, )
      mo_add_xml_stroke( oCard, 'ageObsled', lstr( Int( y * 12 ) + m ) )
      i := 1 // дети-сироты
    Endif
    mo_add_xml_stroke( oCard, 'idType', lstr( i ) )
    If !( Type( 'mHEIGHT' ) == 'N' )
      mHEIGHT := 0
    Endif
    mo_add_xml_stroke( oCard, 'height', lstr( mHEIGHT ) )
    If !( Type( 'mWEIGHT' ) == 'N' )
      mWEIGHT := 0
    Endif
    mo_add_xml_stroke( oCard, 'weight', lstr( mWEIGHT ) )
    If !( Type( 'mPER_HEAD' ) == 'N' )
      mPER_HEAD := 0
    Endif
    mo_add_xml_stroke( oCard, 'headSize', lstr( mPER_HEAD ) )
    If Type( 'm1FIZ_RAZV' ) == 'N' .and. m1FIZ_RAZV > 0 ;
        .and. ( Between( m1FIZ_RAZV1, 1, 2 ) .or. Between( m1FIZ_RAZV2, 1, 2 ) )
      oHealthProblems := oCard:add( hxmlnode():new( 'healthProblems' ) )
      If Between( m1FIZ_RAZV1, 1, 2 )
        mo_add_xml_stroke( oHealthProblems, 'problem', lstr( m1FIZ_RAZV1 ) )
      Endif
      If Between( m1FIZ_RAZV2, 1, 2 )
        mo_add_xml_stroke( oHealthProblems, 'problem', lstr( m1FIZ_RAZV2 + 2 ) )
      Endif
    Endif
    If !( Type( 'm1psih11' ) == 'N' )
      m1psih11 := m1psih12 := m1psih13 := m1psih14 := 0
      m1psih21 := m1psih22 := m1psih23 := 0
    Endif
    If lvozrast < 5
      oPshycDevelopment := oCard:add( hxmlnode():new( 'pshycDevelopment' ) )
      mo_add_xml_stroke( oPshycDevelopment, 'poznav', lstr( m1psih11 ) )
      mo_add_xml_stroke( oPshycDevelopment, 'motor', lstr( m1psih12 ) )
      mo_add_xml_stroke( oPshycDevelopment, 'emot', lstr( m1psih13 ) )
      mo_add_xml_stroke( oPshycDevelopment, 'rech', lstr( m1psih14 ) )
    Else
      oPshycState := oCard:add( hxmlnode():new( 'pshycState' ) )
      mo_add_xml_stroke( oPshycState, 'psihmot', lstr( m1psih21 ) )
      mo_add_xml_stroke( oPshycState, 'intel', lstr( m1psih22 ) )
      mo_add_xml_stroke( oPshycState, 'emotveg', lstr( m1psih23 ) )
    Endif
    If !( Type( 'm141p' ) == 'N' )
      m141p := m141ax := m141fa := 0
      m142p := m142ma := m142ax := m142me := 0
    Endif
    blk_sex := {| x| lstr( iif( Between( x, 0, 3 ), x, 3 ) ) }
    If mpol == 'М' // если мальчик
      oSexFormulaMale := oCard:add( hxmlnode():new( 'sexFormulaMale' ) )
      mo_add_xml_stroke( oSexFormulaMale, 'P', Eval( blk_sex, m141p ) )
      mo_add_xml_stroke( oSexFormulaMale, 'Ax', Eval( blk_sex, m141ax ) )
      mo_add_xml_stroke( oSexFormulaMale, 'Fa', Eval( blk_sex, m141fa ) )
    Else // если девочка
      oSexFormulaFemale := oCard:add( hxmlnode():new( 'sexFormulaFemale' ) )
      mo_add_xml_stroke( oSexFormulaFemale, 'P', Eval( blk_sex, m142p ) )
      mo_add_xml_stroke( oSexFormulaFemale, 'Ma', Eval( blk_sex, m142ma ) )
      mo_add_xml_stroke( oSexFormulaFemale, 'Ax', Eval( blk_sex, m142ax ) )
      mo_add_xml_stroke( oSexFormulaFemale, 'Me', Eval( blk_sex, m142me ) )
      If Type( 'm142me1' ) == 'N' .and. ( i := Int( m142me1 * 12 ) + m142me2 ) > 0
        oMenses := oCard:add( hxmlnode():new( 'menses' ) )
        mo_add_xml_stroke( oMenses, 'menarhe', lstr( i ) )
        If emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
          m1142me3 := m1142me4 := m1142me5 := -1
        Endif
        If Between( m1142me3, 0, 1 ) .or. Between( m1142me4, 0, 2 ) .or. Between( m1142me5, 0, 1 )
          oCharacters := oMenses:add( hxmlnode():new( 'characters' ) )
          If Between( m1142me3, 0, 1 )
            mo_add_xml_stroke( oCharacters, 'char', lstr( m1142me3 + 1 ) )
          Endif
          If Between( m1142me4, 0, 2 )
            If m1142me4 == 0     // {{'обильные', 0}, ;
              i := 3
            Elseif m1142me4 == 1 // {'умеренные', 1}, ;
              i := 5
            Else                 // {'скудные', 2}}
              i := 4
            Endif
            mo_add_xml_stroke( oCharacters, 'char', lstr( i ) )
          Endif
          If Between( m1142me5, 0, 1 )
            mo_add_xml_stroke( oCharacters, 'char', lstr( m1142me5 + 6 ) )
          Endif
        Endif
      Endif
    Endif
    If !( Type( 'mGRUPPA_DO' ) == 'N' ) .or. !Between( mGRUPPA_DO, 1, 5 )
      mGRUPPA_DO := 1
    Endif
    mo_add_xml_stroke( oCard, 'healthGroupBefore', lstr( mGRUPPA_DO ) )
    If Type( 'm1GR_FIZ_DO' ) == 'N' .and. Between( m1GR_FIZ_DO, 0, 4 )
      If m1GR_FIZ_DO == 0 ; m1GR_FIZ_DO := 4 ; Endif
      If m1GR_FIZ_DO == 5 .and. m1GR_FIZ_DO < mGRUPPA_DO
        --m1GR_FIZ_DO
      Endif
      mo_add_xml_stroke( oCard, 'fizkultGroupBefore', lstr( m1GR_FIZ_DO ) )
    Endif
    kol_DiagnosisBefore := 0
    arr_before := {}
    If Type( 'm1diag_15_1' ) == 'N' .and. m1diag_15_1 == 0
      For i := 1 To 5
        fl := .f.
        For k := 1 To 14
          mvar := 'mdiag_15_' + lstr( i ) + '_' + lstr( k )
          If k == 1
            fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
          Else
            m1var := 'm1diag_15_' + lstr( i ) + '_' + lstr( k )
            If fl
              Do Case
              Case eq_any( k, 4, 5, 6, 7 )
                mvar := 'm1diag_15_' + lstr( i ) + '_3'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Case eq_any( k, 9, 10, 11, 12 )
                mvar := 'm1diag_15_' + lstr( i ) + '_8'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Case k == 14
                mvar := 'm1diag_15_' + lstr( i ) + '_13'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Endcase
            Else
              &m1var := -1
            Endif
          Endif
        Next
      Next
      For i := 1 To 5
        arr := {}
        For k := 1 To 14
          mvar := 'mdiag_15_' + lstr( i ) + '_' + lstr( k )
          If k == 1
            s := AllTrim( &mvar )
            If !Empty( s ) .and. m1diag_15_1 == 0
              If Len( s ) > 5
                s := Left( s, 5 )
              Endif
              arr := { s, 3, 1, 2, 1, 2, 0 }
            Else
              Exit
            Endif
          Else
            m1var := 'm1diag_15_' + lstr( i ) + '_' + lstr( k )
            Do Case
            Case k == 2 // Диспансерное наблюдение
              If eq_any( &m1var, 1, 2 )
                // На текущий момент для 17й учетной формы в разделе 'Диагнозы до' (diagnosisBefore) в поле 'Диспансерное наблюдение' (dispNablud) доступно к выбору только два значения: 1 - да, 3 - нет.
                arr[ 2 ] := 1 // &m1var
              Endif
            Case k == 3
              fl := ( &m1var == 1 ) // Лечение было назначено
            Case k == 4 .and. fl
              If Between( &m1var, 0, 2 )
                arr[ 3 ] := &m1var + 1
              Endif
            Case k == 5 .and. fl
              if &m1var == 1
                arr[ 4 ] := 1
              elseif &m1var == 2
                arr[ 4 ] := 3
              elseif &m1var == 3
                arr[ 4 ] := 4
              Endif
            Case k == 8
              fl := ( &m1var == 1 ) // Медицинская реабилитация и (или) санаторно-курортное лечение были назначены
            Case k == 9 .and. fl
              If Between( &m1var, 0, 2 )
                arr[ 5 ] := &m1var + 1
              Endif
            Case k == 10 .and. fl
              if &m1var == 1
                arr[ 6 ] := 1
              elseif &m1var == 2
                arr[ 6 ] := 3
              elseif &m1var == 3
                arr[ 6 ] := 4
              elseif &m1var == 4
                arr[ 6 ] := 5
              Endif
            Case k == 13 // ВМП
              fl := ( &m1var == 1 )
            Case k == 14 .and. fl // ВМП была рекомендована
              arr[ 7 ] := iif( &m1var == 1, 1, 2 ) // 1-оказана, 2-не оказана
            Endcase
          Endif
        Next
        If Len( arr ) > 0
          If kol_DiagnosisBefore == 0
            oDiagnosisBefore := oCard:add( hxmlnode():new( 'diagnosisBefore' ) )
          Endif
          ++kol_DiagnosisBefore
          AAdd( arr_before, { AllTrim( arr[ 1 ] ), arr[ 2 ] } )
          oDiagnosis := oDiagnosisBefore:add( hxmlnode():new( 'diagnosis' ) )
          mo_add_xml_stroke( oDiagnosis, 'mkb', arr[ 1 ] )
          mo_add_xml_stroke( oDiagnosis, 'dispNablud', lstr( arr[ 2 ] ) )
          oLechen := oDiagnosis:add( hxmlnode():new( 'lechen' ) )
          mo_add_xml_stroke( oLechen, 'condition', lstr( arr[ 3 ] ) )
          mo_add_xml_stroke( oLechen, 'organ', lstr( arr[ 4 ] ) )
          // oNotDone := oLechen:Add( HXMLNode():New( 'notDone' ) )
          // mo_add_xml_stroke(oNotDone, 'reason',)
          // mo_add_xml_stroke(oNotDone, 'reasonOther',)
          oReabil := oDiagnosis:add( hxmlnode():new( 'reabil' ) )
          mo_add_xml_stroke( oReabil, 'condition', lstr( arr[ 5 ] ) )
          mo_add_xml_stroke( oReabil, 'organ', lstr( arr[ 6 ] ) )
          // oNotDone := oReabil:Add( HXMLNode():New( 'notDone' ) )
          // mo_add_xml_stroke(oNotDone, 'reason',)
          // mo_add_xml_stroke(oNotDone, 'reasonOther',)
          mo_add_xml_stroke( oDiagnosis, 'vmp', lstr( arr[ 7 ] ) )
        Endif
      Next
    Endif
    If !( Left( mkod_diag, 1 ) == 'Z' )
      If lvozrast < 14
        MKOD_DIAG := 'Z00.1'
      Else
        MKOD_DIAG := 'Z00.3'
      Endif
    Endif
    kol_DiagnosisAfter := 0
    If Type( 'm1diag_16_1' ) == 'N' .and. m1diag_16_1 == 0
      For i := 1 To 5
        fl := .f.
        For k := 1 To 16
          mvar := 'mdiag_16_' + lstr( i ) + '_' + lstr( k )
          If k == 1
            fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
          Else
            m1var := 'm1diag_16_' + lstr( i ) + '_' + lstr( k )
            If fl
              Do Case
              Case eq_any( k, 5, 6 )
                mvar := 'm1diag_16_' + lstr( i ) + '_4'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Case eq_any( k, 8, 9 )
                mvar := 'm1diag_16_' + lstr( i ) + '_7'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Case eq_any( k, 11, 12 )
                mvar := 'm1diag_16_' + lstr( i ) + '_10'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Case eq_any( k, 14, 15 )
                mvar := 'm1diag_16_' + lstr( i ) + '_13'
                if &mvar != 1 // если не 'да'
                  &m1var := -1
                Endif
              Endcase
            Else
              &m1var := -1
            Endif
          Endif
        Next
      Next
      For i := 1 To 5
        arr := {}
        For k := 1 To 16
          mvar := 'mdiag_16_' + lstr( i ) + '_' + lstr( k )
          If k == 1
            s := AllTrim( &mvar )
            If !Empty( s ) .and. m1diag_16_1 == 0
              If Len( s ) > 5
                s := Left( s, 5 )
              Endif
              arr := { s, 0, 0, 1, 2, 1, 2, 1, 2, 0, 0, 0, 0 }
            Else
              Exit
            Endif
          Else
            m1var := 'm1diag_16_' + lstr( i ) + '_' + lstr( k )
            Do Case
            Case k == 2 // Диагноз установлен впервые
              arr[ 2 ] := &m1var
            Case k == 3 // Диспансерное наблюдение
              If eq_any( &m1var, 1, 2 )
                arr[ 3 ] := &m1var
              Endif
            Case k == 4
              fl := ( &m1var == 1 ) // Дополнительные консультации и исследования назначены
            Case k == 5 .and. fl
              If Between( &m1var, 0, 2 )
                arr[ 8 ] := &m1var + 1
              Endif
            Case k == 6 .and. fl
              if &m1var == 1
                arr[ 9 ] := 1
              elseif &m1var == 2
                arr[ 9 ] := 3
              elseif &m1var == 3
                arr[ 9 ] := 4
              Endif
            Case k == 7
              arr[ 10 ] := &m1var // Дополнительные консультации и исследования выполнены
            Case k == 10
              fl := ( &m1var == 1 ) // Лечение было назначено
            Case k == 11 .and. fl
              If Between( &m1var, 0, 2 )
                arr[ 4 ] := &m1var + 1
              Endif
            Case k == 12 .and. fl
              if &m1var == 1
                arr[ 5 ] := 1
              elseif &m1var == 2
                arr[ 5 ] := 3
              elseif &m1var == 3
                arr[ 5 ] := 4
              Endif
            Case k == 13
              fl := ( &m1var == 1 ) // Медицинская реабилитация и (или) санаторно-курортное лечение были назначены
            Case k == 14 .and. fl
              If Between( &m1var, 0, 2 )
                arr[ 6 ] := &m1var + 1
              Endif
            Case k == 15 .and. fl
              if &m1var == 1
                arr[ 7 ] := 1
              elseif &m1var == 2
                arr[ 7 ] := 3
              elseif &m1var == 3
                arr[ 7 ] := 4
              elseif &m1var == 4
                arr[ 7 ] := 5
                arr[ 13 ] := 1
              Endif
            Case k == 16 // Высокотехнологичная медицинская помощь была рекомендована
              arr[ 11 ] := iif( &m1var == 1, 1, 0 )
            Endcase
          Endif
        Next k
        If Len( arr ) > 0
          If kol_DiagnosisAfter == 0
            oDiagnosisAfter := oCard:add( hxmlnode():new( 'diagnosisAfter' ) )
          Endif
          ++kol_DiagnosisAfter
          If ( k := AScan( arr_before, {| x| x[ 1 ] == AllTrim( arr[ 1 ] ) } ) ) > 0 // был такой диагноз до осмотра
            arr[ 2 ] := 0 // выявлен впервые - безусловно поставить 'нет'
            If arr_before[ k, 2 ] == 1 // Диспансерное наблюдение 1 - было установлено ранее
              arr[ 3 ] := 1 // сейчас безусловно установлено ранее
            Elseif arr_before[ k, 2 ] == 2 // 2 - было установлено впервые
              arr[ 3 ] := 1 // сейчас безусловно установлено ранее
            Else // 0 - не было установлено
              If arr[ 3 ] == 1 // сейчас стоит установлено ранее
                arr[ 3 ] := 2 // меняем на установлено впервые
              Endif
            Endif
          Endif
          oDiagnosis := oDiagnosisAfter:add( hxmlnode():new( 'diagnosis' ) )
          mo_add_xml_stroke( oDiagnosis, 'mkb', arr[ 1 ] )
          mo_add_xml_stroke( oDiagnosis, 'firstTime', lstr( arr[ 2 ] ) )
          mo_add_xml_stroke( oDiagnosis, 'dispNablud', lstr( arr[ 3 ] ) )
          oLechen := oDiagnosis:add( hxmlnode():new( 'lechen' ) )
          mo_add_xml_stroke( oLechen, 'condition', lstr( arr[ 4 ] ) )
          mo_add_xml_stroke( oLechen, 'organ', lstr( arr[ 5 ] ) )
          oReabil := oDiagnosis:add( hxmlnode():new( 'reabil' ) )
          mo_add_xml_stroke( oReabil, 'condition', lstr( arr[ 6 ] ) )
          mo_add_xml_stroke( oReabil, 'organ', lstr( arr[ 7 ] ) )
          oConsul := oDiagnosis:add( hxmlnode():new( 'consul' ) )
          mo_add_xml_stroke( oConsul, 'condition', lstr( arr[ 8 ] ) )
          mo_add_xml_stroke( oConsul, 'organ', lstr( arr[ 9 ] ) )
          mo_add_xml_stroke( oConsul, 'state', lstr( arr[ 10 ] ) )
          mo_add_xml_stroke( oDiagnosis, 'needVMP', lstr( arr[ 11 ] ) )
          mo_add_xml_stroke( oDiagnosis, 'needSMP', lstr( arr[ 12 ] ) )
          mo_add_xml_stroke( oDiagnosis, 'needSKL', lstr( arr[ 13 ] ) )
          mo_add_xml_stroke( oDiagnosis, 'recommendNext', 'Рекомендации' )
        Endif
      Next
    Endif
    If kol_DiagnosisAfter == 0
      mo_add_xml_stroke( oCard, 'healthyMKB', MKOD_DIAG )
    Endif
    If Type( 'm1invalid1' ) == 'N' .and. m1invalid1 == 1
      oInvalid := oCard:add( hxmlnode():new( 'invalid' ) )
      mo_add_xml_stroke( oInvalid, 'type', lstr( m1invalid2 + 1 ) )
      If Empty( minvalid3 )
        minvalid3 := mdate_r
      Endif
      mo_add_xml_stroke( oInvalid, 'dateFirstDetected', date2xml( minvalid3 ) )
      If Empty( minvalid4 )
        minvalid4 := mn_data
      Endif
      mo_add_xml_stroke( oInvalid, 'dateLastConfirmed', date2xml( minvalid4 ) )
      arr := {}
      Do Case
      Case m1invalid5 ==   1 // некоторые инфекционные и паразитарные, ', 1}, ;
        arr := { 1 }
      Case m1invalid5 == 101 // из них: туберкулез, ', 101}, ;
        arr := { 1, 2 }
      Case m1invalid5 == 201 // сифилис, ', 201}, ;
        arr := { 1, 3 }
      Case m1invalid5 == 301 // ВИЧ-инфекция;', 301}, ;
        arr := { 1, 4 }
      Case m1invalid5 ==   2 // новообразования;', 2}, ;
        arr := { 5 }
      Case m1invalid5 ==   3 // болезни крови, кроветворных органов ...', 3}, ;
        arr := { 6 }
      Case m1invalid5 ==   4 // болезни эндокринной системы ...', 4}, ;
        arr := { 10 }
      Case m1invalid5 == 104 // из них: сахарный диабет;', 104}, ;
        arr := { 10, 13 }
      Case m1invalid5 ==   5 // психические расстройства и расстройства поведения, ', 5}, ;
        arr := { 14 }
      Case m1invalid5 == 105 // в том числе умственная отсталость;', 105}, ;
        arr := { 14, 15 }
      Case m1invalid5 ==   6 // болезни нервной системы, ', 6}, ;
        arr := { 16 }
      Case m1invalid5 == 106 // из них: церебральный паралич, ', 106}, ;
        arr := { 16, 17 }
      Case m1invalid5 == 206 // другие паралитические синдромы;', 206}, ;
        arr := { 16, 17 }
      Case m1invalid5 ==   7 // болезни глаза и его придаточного аппарата;', 7}, ;
        arr := { 18 }
      Case m1invalid5 ==   8 // болезни уха и сосцевидного отростка;', 8}, ;
        arr := { 19 }
      Case m1invalid5 ==   9 // болезни системы кровообращения;', 9}, ;
        arr := { 20 }
      Case m1invalid5 ==  10 // болезни органов дыхания, ', 10}, ;
        arr := { 21 }
      Case m1invalid5 == 110 // из них: астма, ', 110}, ;
        arr := { 21, 22 }
      Case m1invalid5 == 210 // астматический статус;', 210}, ;
        arr := { 21, 23 }
      Case m1invalid5 ==  11 // болезни органов пищеварения;', 11}, ;
        arr := { 24 }
      Case m1invalid5 ==  12 // болезни кожи и подкожной клетчатки;', 12}, ;
        arr := { 25 }
      Case m1invalid5 ==  13 // болезни костно-мышечной системы и соединительной ткани;', 13}, ;
        arr := { 26 }
      Case m1invalid5 ==  14 // болезни мочеполовой системы;', 14}, ;
        arr := { 27 }
      Case m1invalid5 ==  15 // отдельные состояния, возникающие в перинатальном периоде;', 15}, ;
        arr := { 28 }
      Case m1invalid5 ==  16 // врожденные аномалии, ', 16}, ;
        arr := { 29 }
      Case m1invalid5 == 116 // из них: аномалии нервной системы, ', 116}, ;
        arr := { 29, 30 }
      Case m1invalid5 == 216 // аномалии системы кровообращения, ', 216}, ;
        arr := { 29, 31 }
      Case m1invalid5 == 316 // аномалии опорно-двигательного аппарата;', 316}, ;
        arr := { 29, 32 }
      Case m1invalid5 ==  17 // последствия травм, отравлений и др.', 17}}
        arr := { 33 }
      Endcase
      If Empty( arr )
        arr := { 1 }
      Endif
      oIllnesses := oInvalid:add( hxmlnode():new( 'illnesses' ) )
      For i := 1 To Len( arr ) // заболевание по инвалидности
        mo_add_xml_stroke( oIllnesses, 'illness', lstr( arr[ i ] ) )
      Next
      If !Between( m1invalid6, 1, 9 ) // виды нарушений в состоянии здоровья
        m1invalid6 := 9
      Endif
      oDefects := oInvalid:add( hxmlnode():new( 'defects' ) )
      mo_add_xml_stroke( oDefects, 'defect', lstr( m1invalid6 ) )
    Endif
    arr := {}
    arr1 := {}
    If p_tip_lu == TIP_LU_PN        // профилактика 1 и 2 этап
      arr := f4_inf_dnl_karta( 1 )
      arr1 := f4_inf_dnl_karta( 2 )
      If ( i := AScan( arr1, {| x| x[ 5 ] == 7 } ) ) > 0  // УЗИ сердца
        arr1[ i, 5 ] := 20                             // эхокардиография
      Endif
    Elseif p_tip_lu == TIP_LU_PREDN // пред.осмотры 1 и 2 этап
      arr := f4_inf_predn_karta( 1 )
      arr1 := f4_inf_predn_karta( 2 )
    Elseif p_tip_lu == TIP_LU_PERN  // период.осмотры
      arr := f4_inf_pern_karta( 1 )
      arr1 := f4_inf_pern_karta( 2 )
    Else                            // дети-сироты
      arr := f4_inf_dds_karta( 1 )
      arr1 := f4_inf_dds_karta( 2 )
    Endif
    arr := make_unique_arr5( arr )
    arr1 := make_unique_arr5( arr1 )
    // if len(arr1) == 0 // искусственно добавим одно исследование до 18 года
    // aadd(arr1, {'общий анализ мочи', mn_data, '', 1, 2})
    // endif
    If Len( arr1 ) > 0
      oIssled := oCard:add( hxmlnode():new( 'issled' ) )
      oBasic := oIssled:add( hxmlnode():new( 'basic' ) )
      For i := 1 To Len( arr1 ) // исследования
        oRecord := oBasic:add( hxmlnode():new( 'record' ) )
        mo_add_xml_stroke( oRecord, 'id', lstr( arr1[ i, 5 ] ) )
        mo_add_xml_stroke( oRecord, 'date', date2xml( arr1[ i, 2 ] ) )
        If Empty( arr1[ i, 3 ] )
          arr1[ i, 3 ] := 'норма'
        Endif
        mo_add_xml_stroke( oRecord, 'result', arr1[ i, 3 ] )
      Next
    Endif
    // oOther := oIssled:Add( HXMLNode():New( 'other' ) )
    // цикл oOther // дополнительные исследования
    // oRecord := oOther:Add( HXMLNode():New( 'record' ) )
    // mo_add_xml_stroke(oRecord, 'date',)
    // mo_add_xml_stroke(oRecord, 'name',)
    // mo_add_xml_stroke(oRecord, 'result',)
    // конец цикла oOther
    If !( Type( 'mGRUPPA' ) == 'N' ) .or. !Between( mGRUPPA, 1, 5 )
      mGRUPPA := 1
    Endif
    mo_add_xml_stroke( oCard, 'healthGroup', lstr( mGRUPPA ) )
    If Type( 'm1GR_FIZ' ) == 'N' .and. Between( m1GR_FIZ, 0, 4 )
      If m1GR_FIZ == 0 ; m1GR_FIZ := 4 ; Endif
      If m1GR_FIZ == 5 .and. m1GR_FIZ < mGRUPPA
        --m1GR_FIZ
      Endif
      mo_add_xml_stroke( oCard, 'fizkultGroup', lstr( m1GR_FIZ ) )
    Endif
    mo_add_xml_stroke( oCard, 'zakluchDate', date2xml( mk_data ) )
    mfio := AllTrim( p2->fio )
    s := ''
    k := 0
    arr1 := { '', '', '' }
    For i := 1 To NumToken( mfio, ' .' )
      s1 := AllTrim( Token( mfio, ' .', i ) )
      If !Empty( s1 )
        ++k
        If k < 3
          arr1[ k ] := s1
        Else
          s += s1 + ' '
        Endif
      Endif
    Next
    arr1[ 3 ] := AllTrim( s )
    oZakluchVrachName := oCard:add( hxmlnode():new( 'zakluchVrachName' ) )
    mo_add_xml_stroke( oZakluchVrachName, 'last', arr1[ 1 ] )
    mo_add_xml_stroke( oZakluchVrachName, 'first', arr1[ 2 ] )
    mo_add_xml_stroke( oZakluchVrachName, 'middle', arr1[ 3 ] )
    If Len( arr ) == 0 // искусственно добавим один осмотр
      AAdd( arr, { 'педиатр', mk_data, '', 1, 1 } )
    Endif
    oOsmotri := oCard:add( hxmlnode():new( 'osmotri' ) )
    For i := 1 To Len( arr )
      oRecord := oOsmotri:add( hxmlnode():new( 'record' ) )
      mo_add_xml_stroke( oRecord, 'id', lstr( arr[ i, 5 ] ) )
      mo_add_xml_stroke( oRecord, 'date', date2xml( arr[ i, 2 ] ) )
    Next
    If !( Type( 'mrek_form' ) == 'C' ) .or. Empty( mrek_form )
      mrek_form := 'Рекомендации'
    Endif
    mo_add_xml_stroke( oCard, 'recommendZOZH', mrek_form )
    If Type( 'm1invalid1' ) == 'N' .and. m1invalid1 == 1 .and. !Empty( minvalid7 )
      oReabilitation := oCard:add( hxmlnode():new( 'reabilitation' ) )
      mo_add_xml_stroke( oReabilitation, 'date', date2xml( minvalid7 ) )
      If !Between( m1invalid8, 1, 3 )
        m1invalid8 := 4
      Endif
      mo_add_xml_stroke( oReabilitation, 'state', lstr( m1invalid8 ) )
    Endif
    If !( Type( 'm1privivki1' ) == 'N' ) .or. !Between( m1privivki1, 0, 2 )
      m1privivki1 := 0
    Endif
    If m1privivki1 == 0
      i := 1
    Elseif m1privivki1 == 1
      i := iif( m1privivki2 == 1, 2, 3 )
    Else
      i := iif( m1privivki2 == 1, 4, 5 )
    Endif
    oPrivivki := oCard:add( hxmlnode():new( 'privivki' ) )
    mo_add_xml_stroke( oPrivivki, 'state', lstr( i ) )
    // oPrivs := oPrivivki:Add( HXMLNode():New( 'privs' ) )
    // цикл oPrivs // прививки
    // mo_add_xml_stroke(oPrivs, 'priv',)
    // конец цикла oPrivs
    i := s := 0
    Select RPDSH
    find ( Str( human->kod, 7 ) )
    Do While rpdsh->KOD_H == human->kod .and. !Eof()
      s += rpdsh->S_SL
      Skip
    Enddo
    If Round( mcena_1, 2 ) == Round( s, 2 ) // полностью оплачен
      i := 1
    Endif
    If emptyall( i, s )
      Select RAKSH
      find ( Str( human->kod, 7 ) )
      Do While raksh->KOD_H == human->kod .and. !Eof()
        If raksh->oplata == 2
          i := 2 ; Exit
        Endif
        Skip
      Enddo
    Endif
    mo_add_xml_stroke( oCard, 'oms', lstr( i ) )
    // конец цикла oCards
  Else
    buf := save_maxrow()
    mywait( 'Ждите! Производится сохранение XML-файла...' )
    oXmlDoc:save( n_file + sxml() )
    rest_box( buf )
    n_message( { stitle + '- ' + lstr( _kol ) + ' чел.;', ;
      'в каталоге ' + Upper( cur_dir() ) + ' создан файл ' + Upper( n_file + sxml() ), ;
      'для загрузки на портал Минздрава РФ.' }, , ;
      cColorStMsg, cColorStMsg, , , cColorSt2Msg )
  Endif

  Return Nil

// 25.11.13
Static Function make_unique_arr5( ar )

  Local i, ret_arr := {}

  For i := 1 To Len( ar )
    If ar[ i, 5 ] > 0 .and. AScan( ret_arr, {| x| x[ 5 ] == ar[ i, 5 ] } ) == 0
      AAdd( ret_arr, ar[ i ] )
    Endif
  Next

  Return ret_arr

// 18.04.23 Создание отчётов по иногородним / иностранцам для КЗВО
Function pr_inog_inostr()

  Local arr_m, fl_exit := .f., buf := save_maxrow(), kh := 0, jh := 0, mm_p_per := 0

  If ( arr_m := year_month() ) == NIL
    Return Nil
  Endif
  waitstatus( 'ОМС' )
  dbCreate( cur_dir() + 'tmp_kart', { { 'kod', 'N', 7, 0 }, ;
    { 'vozr', 'N', 2, 0 }, ;
    { 'vid', 'N', 1, 0 }, ;
    { 'profil', 'N', 3, 0 }, ;
    { 'region', 'C', 3, 0 }, ;
    { 'osnov', 'N', 2, 0 }, ;
    { 'kols', 'N', 6, 0 }, ;
    { 'ist_fin', 'N', 1, 0 }, ;
    { 'summa', 'N', 10, 2 }, ;
    { 'k_day', 'N', 5, 0 }, ;
    { 'd_begin', 'C', 10, 0 }, ;
    { 'forma', 'N', 1, 0 } } )
  Use ( cur_dir() + 'tmp_kart' ) new
  Index On Str( kod, 7 ) + Str( vid, 1 ) + Str( profil, 3 ) + region + Str( osnov, 2 ) + Str( ist_fin, 1 ) to ( cur_dir() + 'tmp_kart' )
  //
  Private _arr_if := {}, _what_if := _init_if(), _arr_komit := {}
  r_use( dir_exe() + '_okator', cur_dir() + '_okatr', 'REGION' )
  r_use( dir_server() + 'kartote_', , 'KART_' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'mo_kinos', dir_server() + 'mo_kinos', 'KIS' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )
  r_use( dir_server() + 'human_3', { dir_server() + 'human_3', ;
    dir_server() + 'human_32' }, 'HUMAN_3' )
  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  r_use( dir_server() + 'human_', , 'HUMAN_' )
  r_use( dir_server() + 'human', { dir_server() + 'humand', ;
    dir_server() + 'humank', ;
    dir_server() + 'humankk' }, 'HUMAN' )
  Set Relation To kod_k into KART, To RecNo() into HUMAN_, To RecNo() into HUMAN_2
  dbSeek( DToS( arr_m[ 5 ] ), .t. )

  Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
    @ MaxRow(), 71 Say date_8( human->k_data ) Color 'W/R'
    @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
    If jh > 0
      @ Row(), Col() Say '/' Color 'W/R'
      @ Row(), Col() Say lstr( jh ) Color cColorStMsg
    Endif
    updatestatus()
    If Inkey() == K_ESC
      fl_exit := .t. ; Exit
    Endif
    If human_->oplata < 9 .and. human->ishod != 88
      lregion := Space( 3 ) ; losnov := 0
      If human->CENA_1 > 0 .and. f1pr_inog_inostr( 1, human->kod_k, @lregion, @losnov, arr_m )
        lprofil := human_->profil
        lvid := 2
        Do Case
        Case human_->USL_OK == 1
          lvid := 1
        Case human_->USL_OK == 2
          lvid := 4
        Case human_->USL_OK == 3
          lvid := 2
        Case human_->USL_OK == 4
          lvid := 3
        Endcase
        list_fin := f2pr_inog_inostr( _what_if )
        mn_data := human->N_DATA
        msumma := human->CENA_1
        If human->ishod == 89
          Select HUMAN_3
          Set Order To 2 // встать на индекс по 2-му случаю
          find ( Str( human->kod, 7 ) )
          If Found()
            msumma := human_3->CENA_1
            mn_data := human_3->N_DATA
            mm_p_per := human_2->p_per
          Endif
        Endif
        // добавка для КБ25
        sum_koiko_den := 0
        lshifr := ''
        Select HU
        find ( Str( human->kod, 7 ) )
        Do While human->kod == hu->kod .and. !Eof()
          usl->( dbGoto( hu->u_kod ) )
          If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
            lshifr := usl->shifr
          Endif
          lshifr := AllTrim( lshifr )
          If lshifr == '1.11.1'
            sum_koiko_den += hu->kol
          Endif
          Select HU
          Skip
        Enddo
        //
        Select TMP_KART
        find ( Str( human->kod_k, 7 ) + Str( lvid, 1 ) + Str( lprofil, 3 ) + lregion + Str( losnov, 2 ) + Str( list_fin, 1 ) )
        If !Found()
          Append Blank
          tmp_kart->kod := human->kod_k
          tmp_kart->vid := lvid
          tmp_kart->profil := lprofil
          tmp_kart->region := lregion
          tmp_kart->osnov := losnov
          tmp_kart->ist_fin := list_fin
          tmp_kart->d_begin := full_date( human->n_data )
          tmp_kart->forma := mm_p_per
        Endif
        tmp_kart->kols++
        tmp_kart->vozr := f0pr_inog_inostr( human->date_r, mn_data )
        tmp_kart->summa += msumma
        tmp_kart->k_day += sum_koiko_den
        ++jh
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  If is_task( X_PLATN )
    waitstatus( 'Платные услуги' )
    r_use( dir_server() + 'hum_p', dir_server() + 'hum_pd', 'HUMP' )
    Set Relation To kod_k into KART
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While hump->k_data <= arr_m[ 6 ] .and. !Eof()
      @ MaxRow(), 71 Say date_8( hump->k_data ) Color 'W/R'
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say '/' Color 'W/R'
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      lregion := Space( 3 ) ; losnov := 0
      If hump->CENA > 0 .and. f1pr_inog_inostr( 2, hump->kod_k, @lregion, @losnov, arr_m )
        lprofil := 97 // терапии
        lvid := 2     // амбулаторно
        If hump->otd > 0
          otd->( dbGoto( hump->otd ) )
          If !Empty( otd->profil )
            lprofil := otd->profil
          Endif
          If otd->IDUMP == 1
            lvid := 1
          Endif
        Endif
        list_fin := iif( hump->tip_usl == 1, 2, 1 )
        Select TMP_KART
        find ( Str( hump->kod_k, 7 ) + Str( lvid, 1 ) + Str( lprofil, 3 ) + lregion + Str( losnov, 2 ) + Str( list_fin, 1 ) )
        If !Found()
          Append Blank
          tmp_kart->kod := hump->kod_k
          tmp_kart->vid := lvid
          tmp_kart->profil := lprofil
          tmp_kart->region := lregion
          tmp_kart->osnov := losnov
          tmp_kart->ist_fin := list_fin
        Endif
        kart->( dbGoto( hump->kod_k ) )
        tmp_kart->kols++
        tmp_kart->vozr := f0pr_inog_inostr( kart->date_r, hump->n_data )
        tmp_kart->summa += hump->CENA
        ++jh
      Endif
      Select HUMP
      Skip
    Enddo
  Endif
  If is_task( X_ORTO )
    waitstatus( 'Ортопедия' )
    r_use( dir_server() + 'hum_ort', dir_server() + 'hum_ortd', 'HUMO' )
    Set Relation To kod_k into KART
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While humo->k_data <= arr_m[ 6 ] .and. !Eof()
      @ MaxRow(), 71 Say date_8( humo->k_data ) Color 'W/R'
      @ MaxRow(), 1 Say lstr( ++kh ) Color cColorSt2Msg
      If jh > 0
        @ Row(), Col() Say '/' Color 'W/R'
        @ Row(), Col() Say lstr( jh ) Color cColorStMsg
      Endif
      updatestatus()
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      lregion := Space( 3 ) ; losnov := 0
      If humo->CENA > 0 .and. f1pr_inog_inostr( 2, humo->kod_k, @lregion, @losnov, arr_m )
        lprofil := 88 // стоматологии ортопедической
        lvid := 2     // амбулаторно
        If humo->tip_usl == 1
          list_fin := 4
        Elseif humo->tip_usl == 3
          list_fin := 2
        Else
          list_fin := 1
        Endif
        Select TMP_KART
        find ( Str( humo->kod_k, 7 ) + Str( lvid, 1 ) + Str( lprofil, 3 ) + lregion + Str( losnov, 2 ) + Str( list_fin, 1 ) )
        If !Found()
          Append Blank
          tmp_kart->kod := humo->kod_k
          tmp_kart->vid := lvid
          tmp_kart->profil := lprofil
          tmp_kart->region := lregion
          tmp_kart->osnov := losnov
          tmp_kart->ist_fin := list_fin
        Endif
        kart->( dbGoto( humo->kod_k ) )
        tmp_kart->kols++
        tmp_kart->vozr := f0pr_inog_inostr( kart->date_r, humo->n_data )
        tmp_kart->summa += humo->CENA
        ++jh
      Endif
      Select HUMO
      Skip
    Enddo
  Endif
  rest_box( buf )
  Close databases
  If jh == 0
    func_error( 4, 'Не обнаружено информации по иногородним и иностранцам за указанный период' )
  Else
    j := 0
    Do While ( j := popup_prompt( T_ROW, T_COL - 5, j, ;
        { 'Приложение ~1 - список иностранцев', ;
        'Приложение ~2 - список иногородних', ;
        'Приложение ~3 - сводная информация по иностранцам', ;
        'Приложение ~4 - сводная информация по иногородним', ;
        'Расширенный Список ~Иностранцев' } ) ) > 0
      f3pr_inog_inostr( j, arr_m )
    Enddo
  Endif

  Return Nil

// 12.08.18
Function f0pr_inog_inostr( ldate_r, _data )

  Local cy := count_years( ldate_r, _data )

  Return iif( cy < 100, cy, 99 )

// 28.09.20
Function f1pr_inog_inostr( par, lkod, /*@*/lregion, /*@*/losnov, arr_m)

  Local rec

  Select KART
  Goto ( lkod )
  If !Empty( kart_->strana ) .and. AScan( geto001(), {| x| x[ 2 ] == kart_->strana } ) > 0
    lregion := kart_->strana
    Select KIS
    find ( Str( lkod, 7 ) )
    If Found()
      losnov := kis->osn_preb
    Endif
  Endif
  If lregion == '643'
    lregion := Space( 3 ) ; losnov := 0
  Endif
  If Empty( lregion ) .and. !eq_any( Left( kart_->okatog, 2 ), '  ', '00', '18' )
    Select REGION
    find ( Left( kart_->okatog, 2 ) )
    If Found()
      lregion := Left( kart_->okatog, 2 ) + ' '
      losnov := -1
    Endif
    If par == 1 .and. !Empty( lregion ) // иногородний?
      If human->komu == 0 .and. Val( human_->smo ) > 34000 .and. Val( human_->smo ) < 35000 // полис Волгоградский
        lregion := Space( 3 ) ; losnov := 0                                               // не учитываем
      Endif
    Endif
  Endif

  Return !Empty( lregion )

// 14.11.19
Function f2pr_inog_inostr( _what_if )

  Local list_fin := I_FIN_OMS, _ist_fin, i

  If human->komu == 5
    list_fin := I_FIN_PLAT // личный счет = платные услуги
  Elseif eq_any( human->komu, 1, 3 )
    If ( i := AScan( _what_if[ 2 ], {| x| x[ 1 ] == human->komu .and. x[ 2 ] == human->str_crb } ) ) > 0
      list_fin := _what_if[ 2, i, 3 ]
    Endif
  Endif
  // 1-пл., 2-ДМС, 3-ОМС, 4-бюджет, 5-средства МО, 6-средства субъекта РФ
  If list_fin == I_FIN_OMS
    _ist_fin := 3
  Elseif list_fin == I_FIN_PLAT
    _ist_fin := 1
  Elseif list_fin == I_FIN_DMS
    _ist_fin := 2
  Elseif list_fin == I_FIN_LPU
    _ist_fin := 5
  Else
    _ist_fin := 6
  Endif

  Return _ist_fin

// 08.04.23
Function f3pr_inog_inostr( j, arr_m )

  Static sprofil := 'терапии'
  Static mm_vid := { 'медицинская помощь, оказанная в стационарных условиях', ;
    'медицинская помощь, оказанная в амбулаторных условиях', ;
    'Экстренная медицинская помощь', ;
    'медицинская помощь в условиях дневного стационара' }
  Static mm_ist_fin := { 'Личные средства гражданина', 'ДМС', 'ОМС', 'средства фед.бюджета', 'средства МО', 'средства субъекта РФ' }
  
  Local name_fr := 'mo_iipr', buf := save_maxrow()

  mywait()
  delfrfiles()
  dbCreate( fr_titl, { { 'name', 'C', 255, 0 }, ;
    { 'period', 'C', 255, 0 } } )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_FULL_NAME ]
  frt->period := arr_m[ 4 ]
  dbCreate( fr_data, { ;
    { 'vid', 'C', 60, 0 }, ;
    { 'profil', 'C', 255, 0 }, ;
    { 'region', 'C', 255, 0 }, ;
    { 'ist_fin', 'C', 30, 0 }, ;
    { 'osnov', 'C', 50, 0 }, ;
    { 'fio', 'C', 60, 0 }, ;
    { 'kol', 'N', 6, 0 }, ;
    { 'kols', 'N', 6, 0 }, ;
    { 'vozr', 'N', 2, 0 }, ;
    { 'summa', 'N', 15, 2 }, ;
    { 'k_day', 'N', 5, 0 }, ;
    { 'd_begin', 'C', 10, 0 }, ;
    { 'forma', 'C', 60, 0 } } )
  Use ( fr_data ) New Alias FRD
  r_use( dir_exe() + '_okator', cur_dir() + '_okatr', 'REGION' )
  r_use( dir_server() + 'kartotek', , 'KART' )
  Use ( cur_dir() + 'tmp_kart' ) new
  If j == 1 .or. j == 2 .or. j == 5
    Set Relation To kod into KART
    Index On Upper( kart->fio ) + Str( kart->kod, 7 ) + Str( vid, 1 ) + Str( profil, 3 ) + region + Str( osnov, 2 ) + Str( ist_fin, 1 ) to ( cur_dir() + 'tmp_kart' )
  Else
    Index On region + Str( osnov, 2 ) + Str( ist_fin, 1 ) + Str( vid, 1 ) + Str( profil, 3 ) to ( cur_dir() + 'tmp_kart' )
  Endif
  If j == 1 .or. j == 2 .or. j == 5
    Select TMP_KART
    Go Top
    Do While !Eof()
      If j == 2
        If tmp_kart->osnov < 0
          Select FRD
          Append Blank
          frd->vid := mm_vid[ tmp_kart->vid ]
          If Empty( frd->profil := inieditspr( A__MENUVERT, getv002(), tmp_kart->PROFIL ) )
            frd->profil := sprofil
          Endif
          frd->ist_fin := mm_ist_fin()[ tmp_kart->ist_fin ]
          Select REGION
          find ( Left( tmp_kart->region, 2 ) )
          frd->region := CharRem( '*', name )
          frd->fio := kart->fio
          frd->kols += tmp_kart->kols
          frd->vozr := tmp_kart->vozr
          frd->summa := tmp_kart->summa
          frd->k_day := tmp_kart->k_day
          frd->d_begin := tmp_kart->d_begin
          frd->forma := iif( tmp_kart->forma == 2, 'Доставлен СП', 'Плановая' )
        Endif
      Else
        If tmp_kart->osnov >= 0
          Select FRD
          Append Blank
          frd->vid := mm_vid[ tmp_kart->vid ]
          If Empty( frd->profil := inieditspr( A__MENUVERT, getv002(), tmp_kart->PROFIL ) )
            frd->profil := sprofil
          Endif
          frd->ist_fin := mm_ist_fin()[ tmp_kart->ist_fin ]
          frd->region := inieditspr( A__MENUVERT, geto001(), tmp_kart->region )
          frd->osnov := inieditspr( A__MENUVERT, get_osn_preb_rf(), tmp_kart->osnov )
          frd->fio := kart->fio
          frd->kols += tmp_kart->kols
          frd->vozr := tmp_kart->vozr
          frd->summa := tmp_kart->summa
          frd->k_day := tmp_kart->k_day
          frd->d_begin := tmp_kart->d_begin
          frd->forma := iif( tmp_kart->forma == 2, 'Доставлен СП', 'Плановая' )
        Endif
      Endif
      Select TMP_KART
      Skip
    Enddo
  Else
    dbCreate( cur_dir() + 'tmp1', { { 'vid', 'N', 1, 0 }, ;
      { 'profil', 'N', 3, 0 }, ;
      { 'region', 'C', 3, 0 }, ;
      { 'osnov', 'N', 2, 0 }, ;
      { 'ist_fin', 'N', 1, 0 }, ;
      { 'kol', 'N', 6, 0 }, ;
      { 'kols', 'N', 6, 0 }, ;
      { 'summa', 'N', 15, 2 } } )
    Use ( cur_dir() + 'tmp1' ) new
    Index On region + Str( osnov, 2 ) + Str( ist_fin, 1 ) + Str( vid, 1 ) + Str( profil, 3 ) to ( cur_dir() + 'tmp1' )
    Select TMP_KART
    Go Top
    Do While !Eof()
      fl := .f.
      If j == 4
        If tmp_kart->osnov < 0
          fl := .t.
        Endif
      Else
        If tmp_kart->osnov >= 0
          fl := .t.
        Endif
      Endif
      If fl
        Select TMP1
        find ( tmp_kart->region + Str( tmp_kart->osnov, 2 ) + Str( tmp_kart->ist_fin, 1 ) + Str( tmp_kart->vid, 1 ) + Str( tmp_kart->profil, 3 ) )
        If !Found()
          Append Blank
          tmp1->vid := tmp_kart->vid
          tmp1->profil := tmp_kart->profil
          tmp1->region := tmp_kart->region
          tmp1->osnov := tmp_kart->osnov
          tmp1->ist_fin := tmp_kart->ist_fin
        Endif
        tmp1->kol++
        tmp1->kols += tmp_kart->kols
        tmp1->summa += tmp_kart->summa
      Endif
      Select TMP_KART
      Skip
    Enddo
    Select TMP1
    Go Top
    Do While !Eof()
      Select FRD
      Append Blank
      frd->vid := mm_vid[ tmp1->vid ]
      If Empty( frd->profil := inieditspr( A__MENUVERT, getv002(), tmp1->PROFIL ) )
        frd->profil := sprofil
      Endif
      frd->ist_fin := mm_ist_fin()[ tmp1->ist_fin ]
      If tmp1->osnov < 0
        Select REGION
        find ( Left( tmp1->region, 2 ) )
        frd->region := CharRem( '*', name )
      Else
        frd->region := inieditspr( A__MENUVERT, geto001(), tmp1->region )
        frd->osnov := inieditspr( A__MENUVERT, get_osn_preb_rf(), tmp1->osnov )
      Endif
      frd->kols := tmp1->kols
      frd->kol := tmp1->kol
      frd->summa := tmp1->summa
      Select TMP1
      Skip
    Enddo
  Endif
  Close databases
  rest_box( buf )
  call_fr( name_fr + lstr( j ) )

  Return Nil
