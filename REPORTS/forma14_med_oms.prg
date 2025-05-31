// информация по форма 14-МЕД ОМС (по счетам)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.04.25 форма 14-МЕД (ОМС)
Function forma14_med_oms()

  Static group_ini := 'f14_med_oms'
  Local begin_date, end_date, buf := SaveScreen(), arr_m, i, j, k, k1, k2, ;
    t_arr[ 10 ], t_arr1[ 10 ], name_file := cur_dir() + 'f14med.txt', tfoms_pz[ 5, 11 ], ;
    sh, HH := 80, reg_print := 5, is_trudosp, is_rebenok, is_inogoro, is_onkologia, ;
    is_reabili, is_ekstra, lshifr1, koef, vid_vp, r1 := 9, fl_exit := .f., ;
    is_vmp, d2_year, ar, arr_excel := {}, fl_error := .f., is_z_sl, ;
    cFileProtokol := cur_dir + 'tmp.txt', arr_prof := {}, arr_usl, au, ii, is_school, ;
    filetmp14 := cur_dir + 'tmp14.txt', sum_k := 0, sum_ki := 0, sum_kd := 0, sum_kt := 0, kol_d := 0, sum_d := 0
  Local arr_skor[ 81, 2 ], arr_eko[ 2, 2 ], arr_profil := {}, arr_dn_stac := {}, arrDdn_stac[ 4 ], fl_pol1[ 15 ], ;
    arr_pol[ 32 ], arr_pol1[ 15, 5 ], arr_pril5[ 32, 3 ], ifff := 0, kol_stom_pos := 0, ;
    arr_pol3000[ 29, 6 ], vr_rec := 0, arr_full_usl, ;
    fl_pol3000_PROF, fl_pol3000_DVN2 := .t.

  Local sbase
  Local lal, lalf
  Local nameArr // , funcGetPZ

  old5 := old2 := 0
  afillall( arr_skor, 0 )
  afillall( arr_eko, 0 )
  AFill( arrDdn_stac, 0 )
  AFill( arr_pol, 0 )
  afillall( arr_pril5, 0 )
  afillall( arr_pol1, 0 )
  afillall( arr_pol3000, 0 )
  arr_pol1[ 1, 1 ] := 'Посещений - всего (02+11+13)'
  arr_pol1[ 2, 1 ] := 'Посещения с профилактическими и иными целями (03+06+09)'
  arr_pol1[ 3, 1 ] := 'посещения с профилактическими целями, всего'
  arr_pol1[ 4, 1 ] := 'из строки 03 - посещения, связанные с диспансеризацией'
  arr_pol1[ 5, 1 ] := 'из строки 03 - посещения по специальности "стоматология"'
  arr_pol1[ 6, 1 ] := 'разовые посещения в связи с заболеваниями, всего'
  arr_pol1[ 7, 1 ] := 'из строки 06 - посещения на дому'
  arr_pol1[ 8, 1 ] := 'из строки 06 - посещения по специальности "стоматология"'
  arr_pol1[ 9, 1 ] := 'посещения с иными целями, всего'
  arr_pol1[ 10, 1 ] := 'из строки 09 паллиативная медицинская помощь'
  arr_pol1[ 11, 1 ] := 'Посещения при оказании помощи в неотложной форме, всего'
  arr_pol1[ 12, 1 ] := 'из строки 11 - посещения на дому'
  arr_pol1[ 13, 1 ] := 'Посещения, включенные в обращение в связи с заболеваниями'
  arr_pol1[ 14, 1 ] := 'из строки 13 - посещения по специальности "стоматология"'
  arr_pol1[ 15, 1 ] := 'Из строки 01 - посещения к среднему медперсоналу'
  //
  arr_pol3000[ 1, 1 ] := 'Посещений - всего (02+21+25)' // 1-1
  arr_pol3000[ 1, 6 ] := 1
  arr_pol3000[ 2, 1 ] := 'Посещения с профилактическими и иными целями (03+06)' //
  arr_pol3000[ 2, 6 ] := 2
  arr_pol3000[ 3, 1 ] := 'посещения с профилактическими целями, всего (04+05)'
  arr_pol3000[ 3, 6 ] := 3
  arr_pol3000[ 4, 1 ] := 'из строки 03 - посещения, связанные с профосмотрами'
  arr_pol3000[ 4, 6 ] := 4
  arr_pol3000[ 5, 1 ] := 'из строки 03 - посещения, связанные с диспансеризацией'
  arr_pol3000[ 5, 6 ] := 5
  arr_pol3000[ 6, 1 ] := 'посещения с иными целями, всего (07+08+12+14+15+16+19+20)'
  arr_pol3000[ 6, 6 ] := 6
  arr_pol3000[ 7, 1 ] := 'из строки 06 посещения с целью диспансерного наблюдения'
  arr_pol3000[ 7, 6 ] := 7
  arr_pol3000[ 8, 1 ] := 'из строки 06 посещения с целью диспансеризации'
  arr_pol3000[ 8, 6 ] := 8
  arr_pol3000[ 9, 1 ] := 'из строки 06 разовые посещения в связи с заболеваниями'
  arr_pol3000[ 9, 6 ] := 12
  arr_pol3000[ 10, 1 ] := 'из строки 12 - посещения на дому'
  arr_pol3000[ 10, 6 ] := 13
  arr_pol3000[ 11, 1 ] := 'из строки 06 - посещения центров доровья'
  arr_pol3000[ 11, 6 ] := 14
  arr_pol3000[ 12, 1 ] := 'из строки 06 - посещения работников, со средним м/о'
  arr_pol3000[ 12, 6 ] := 15
  arr_pol3000[ 13, 1 ] := 'из строки 06 - посещения амбулаторных ОНКО центров'
  arr_pol3000[ 13, 6 ] := 16
  arr_pol3000[ 14, 1 ] := 'из строки 12 - посещения по специальности "онкология"'
  arr_pol3000[ 14, 6 ] := 17
  arr_pol3000[ 15, 1 ] := 'из строки 13 - посещения по специальности "стоматология"'
  arr_pol3000[ 15, 6 ] := 18
  arr_pol3000[ 16, 1 ] := 'посещения с другими целями, всего'
  arr_pol3000[ 16, 6 ] := 20
  arr_pol3000[ 17, 1 ] := 'Посещения при оказании помощи в неотложной форме, всего'
  arr_pol3000[ 17, 6 ] := 21
  arr_pol3000[ 18, 1 ] := 'из строки 21 - посещения на дому'
  arr_pol3000[ 18, 6 ] := 22
  arr_pol3000[ 19, 1 ] := 'из строки 21 - посещения по специальности "стоматология"'
  arr_pol3000[ 19, 6 ] := 24
  arr_pol3000[ 20, 1 ] := 'Посещения, включенные в обращение в связи с заболеваниями'
  arr_pol3000[ 20, 6 ] := 25
  arr_pol3000[ 21, 1 ] := 'из строки 25 - посещения по специальности "онкология"'
  arr_pol3000[ 21, 6 ] := 26
  arr_pol3000[ 22, 1 ] := 'из строки 25 - посещения по специальности "стоматология"'
  arr_pol3000[ 22, 6 ] := 27
  arr_pol3000[ 23, 1 ] := ' КТ'
  arr_pol3000[ 23, 6 ] := 28
  arr_pol3000[ 24, 1 ] := ' МРТ'
  arr_pol3000[ 24, 6 ] := 29
  arr_pol3000[ 25, 1 ] := ' УЗИ ССС'
  arr_pol3000[ 25, 6 ] := 30
  arr_pol3000[ 26, 1 ] := ' Эндоскопические диагностические исследования'
  arr_pol3000[ 26, 6 ] := 31
  arr_pol3000[ 27, 1 ] := ' Молекулярно-генетические исследования'
  arr_pol3000[ 27, 6 ] := 32
  arr_pol3000[ 28, 1 ] := ' Гистологические исследования'
  arr_pol3000[ 28, 6 ] := 33
  arr_pol3000[ 29, 1 ] := ' Тестирование на COVID-19'
  arr_pol3000[ 29, 6 ] := 34


  //
  arr_pril5[ 1, 1 ] := 'Объёмы всего ,руб.'
  arr_pril5[ 2, 1 ] := 'СМП - вызовов, ед.'
  arr_pril5[ 3, 1 ] := 'СМП - лиц, чел.'
  arr_pril5[ 4, 1 ] := 'СМП - руб.'
  arr_pril5[ 8, 1 ] := 'Всего посещений'
  arr_pril5[ 9, 1 ] := 'Всего расходов на амб.помощь'
  arr_pril5[ 10, 1 ] := 'Число обращений по поводу заболевания'
  arr_pril5[ 32, 1 ] := 'Число обращений по поводу Диспансерного наблюдения'
  arr_pril5[ 11, 1 ] := 'Число посещений с проф.(иной) целью'
  arr_pril5[ 12, 1 ] := 'руб.'
  arr_pril5[ 13, 1 ] := 'Число посещений по неотл.мед.помощи'
  arr_pril5[ 14, 1 ] := 'руб.'
  arr_pril5[ 15, 1 ] := 'Стационар - койко-дней'
  arr_pril5[ 16, 1 ] := 'Стационар - случаев госпитализации'
  arr_pril5[ 17, 1 ] := 'Стационар - руб.'
  arr_pril5[ 18, 1 ] := 'Стац(ВМП) - койко-дней'
  arr_pril5[ 19, 1 ] := 'Стац(ВМП) - случаев госпитализации'
  arr_pril5[ 20, 1 ] := 'Стац(ВМП) - руб.'
  arr_pril5[ 21, 1 ] := 'Стац(реабил) - койко-дней'
  arr_pril5[ 22, 1 ] := 'Стац(реабил) - случаев госпитализации'
  arr_pril5[ 23, 1 ] := 'Стац(реабил) - руб.'
  arr_pril5[ 24, 1 ] := 'Дн.стац. - пациенто-дней'
  arr_pril5[ 25, 1 ] := 'Дн.стац. - пациентов, чел.'
  arr_pril5[ 26, 1 ] := 'Дн.стац. - руб.'
  arr_pril5[ 27, 1 ] := 'Дн.стац.ЭКО - пациенто-дней'
  arr_pril5[ 28, 1 ] := 'Дн.стац.ЭКО - пациентов, чел.'
  arr_pril5[ 29, 1 ] := 'Дн.стац.ЭКО - руб.'
  arr_pril5[ 30, 1 ] := 'Стац - стентирование, единиц'
  arr_pril5[ 31, 1 ] := 'Стац - стентирование иногородние, единиц'


  // //////////////////////////////////////////////////////////////////
  arr_m := { 2025, 1, 3, 'за январь - март 2025 года', 0d20250101, 0d20250331 }  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // //////////////////////////////////////////////////////////////////
  lal := create_name_alias( 'lusl', arr_m[ 1 ] )
  lalf := create_name_alias( 'luslf', arr_m[ 1 ] )
  Private mk1, mk2, mk3, mk4, md1, md11, md12, md2, md21, md22, md3, md4
  ar := getinisect( tmp_ini, group_ini )
  mk1 := Int( Val( a2default( ar, 'mk1', '0' ) ) )
  mk2 := Int( Val( a2default( ar, 'mk2', '0' ) ) )
  mk3 := Int( Val( a2default( ar, 'mk3', '0' ) ) )
  mk4 := Int( Val( a2default( ar, 'mk4', '0' ) ) )
  md1 := Int( Val( a2default( ar, 'md1', '0' ) ) )
  md11 := Int( Val( a2default( ar, 'md11', '0' ) ) )
  md12 := Int( Val( a2default( ar, 'md12', '0' ) ) )
  md2 := Int( Val( a2default( ar, 'md2', '0' ) ) )
  md21 := Int( Val( a2default( ar, 'md21', '0' ) ) )
  md22 := Int( Val( a2default( ar, 'md22', '0' ) ) )
  md3 := Int( Val( a2default( ar, 'md3', '0' ) ) )
  md4 := Int( Val( a2default( ar, 'md4', '0' ) ) )
  box_shadow( r1, 2, 22, 77, color1, 'Форма 14-МЕД ' + arr_m[ 4 ], color8 )
  tmp_solor := SetColor( cDataCGet )
  @ r1 + 1, 4 Say Center( 'Стационар (раздел II)', 72 ) Color color14
  @ r1 + 2, 4 Say 'Число коек на конец отчетного периода (коек)      ' Get mk1 Pict '9999'
  @ r1 + 3, 4 Say '  из них: для детей (0-17 лет включительно) (коек)' Get mk2 Pict '9999'
  @ r1 + 4, 4 Say 'Число коек в среднем за отчетный период (коек)    ' Get mk3 Pict '9999'
  @ r1 + 5, 4 Say '  из них: для детей (0-17 лет включительно) (коек)' Get mk4 Pict '9999'
  @ r1 + 6, 4 Say Center( 'Дневной стационар (раздел IV)', 72 ) Color color14
  @ r1 + 7, 4 Say 'Число дневных стационаров                   ' Get md1 Pict '9999'
  @ r1 + 8, 4 Say '    из них при оказании специализированной помощи' Get md11 Pict '9999' Valid md11 <= md1
  @ Row(), Col() Say ', в т.ч.ВМП' Get md12 Pict '9999' Valid md12 <= md11
  @ r1 + 9, 4 Say '  Из них оказывающие помощь детям (0-17 лет)' Get md2 Pict '9999'
  @ r1 + 10, 4 Say '    из них при оказании специализированной помощи' Get md21 Pict '9999' Valid md21 <= md2
  @ Row(), Col() Say ', в т.ч.ВМП' Get md22 Pict '9999' Valid md22 <= md21
  @ r1 + 11, 4 Say 'Число мест на конец отчетного периода       ' Get md3 Pict '9999'
  @ r1 + 12, 4 Say 'Число мест, в среднем за отчетный период    ' Get md4 Pict '9999'
  status_key( '^<Esc>^ - выход;  ^<PgDn>^ - создание отчёта' )
  myread()
  RestScreen( buf )
  If LastKey() == K_ESC
    Return Nil
  Endif
  setinisect( tmp_ini, group_ini, { { 'mk1', mk1 }, ;
    { 'mk2', mk2 }, ;
    { 'mk3', mk3 }, ;
    { 'mk4', mk4 }, ;
    { 'md1', md1 }, ;
    { 'md11', md11 }, ;
    { 'md12', md12 }, ;
    { 'md2', md2 }, ;
    { 'md21', md21 }, ;
    { 'md22', md22 }, ;
    { 'md3', md3 }, ;
    { 'md4', md4 } } )
  waitstatus( arr_m[ 4 ] )
  @ MaxRow(), 0 Say ' ждите...' Color 'W/R'
  begin_date := dtoc4( arr_m[ 5 ] )
  end_date := dtoc4( arr_m[ 6 ] )
  dbCreate( cur_dir + 'tmp', { { 'nstr', 'N', 2, 0 }, ;
    { 'sum4', 'N', 15, 2 }, ;
    { 'sum5', 'N', 15, 2 }, ;
    { 'sum6', 'N', 15, 2 }, ;
    { 'sum7', 'N', 15, 2 }, ;
    { 'sum8', 'N', 15, 2 }, ;
    { 'sum9', 'N', 15, 2 } } )
  Use ( cur_dir + 'tmp' ) New Alias TMP
  Index On Str( nstr, 2 ) to ( cur_dir + 'tmp' )
  Append blank ; tmp->nstr :=  1 ; tmp->sum4 := tmp->sum5 := mk1
  Append blank ; tmp->nstr :=  2 ; tmp->sum4 := tmp->sum5 := mk2
  Append blank ; tmp->nstr :=  3 ; tmp->sum4 := tmp->sum5 := mk3
  Append blank ; tmp->nstr :=  4 ; tmp->sum4 := tmp->sum5 := mk4
  Append blank ; tmp->nstr := 46 ; tmp->sum4 := tmp->sum5 := md1 ; tmp->sum7 := md11 ; tmp->sum8 := md12
  Append blank ; tmp->nstr := 47 ; tmp->sum4 := tmp->sum5 := md2 ; tmp->sum7 := md21 ; tmp->sum8 := md22
  Append blank ; tmp->nstr := 48 ; tmp->sum4 := tmp->sum5 := md3
  Append blank ; tmp->nstr := 49 ; tmp->sum4 := tmp->sum5 := md4
  dbCreate( cur_dir + 'tmpf14', { ;
    { 'KOD_XML',  'N', 6, 0 }, ; // ссылка на файл 'mo_xml'
    { 'SCHET',    'N', 6, 0 }, ; //
    { 'KOD_RAK',  'N', 6, 0 }, ; // № записи в файле RAK
    { 'KOD_RAKS', 'N', 6, 0 }, ; // № записи в файле RAKS
    { 'KOD_RAKSH', 'N', 8, 0 }, ; // № записи в файле RAKSH
    { 'kol_akt',  'N', 2, 0 }, ; //
    { 'usl_ok',   'N', 1, 0 }, ; //
    { 'KOD_H',    'N', 7, 0 };  // код листа учета по БД 'human'
  } )
  Use ( cur_dir + 'tmpf14' ) New Alias TMPF14
  use_base( 'lusl' )
  use_base( 'luslf' )

  sbase := prefixfilerefname( arr_m[ 1 ] ) + 'unit'
  r_use( dir_exe() + sbase, cur_dir() + sbase, 'MOUNIT' )

  r_use( dir_server + 'mo_su',, 'MOSU' )
  r_use( dir_server + 'mo_hu', dir_server + 'mo_hu', 'MOHU' )
  Set Relation To u_kod into MOSU
  r_use( dir_server + 'uslugi', , 'USL' )
  r_use( dir_server + 'human_u_', , 'HU_' )
  r_use( dir_server + 'human_u', dir_server + 'human_u', 'HU' )
  Set Relation To RecNo() into HU_, To u_kod into USL
  r_use( dir_server + 'kartote_', , 'KART_' )
  r_use( dir_server + 'kartotek', , 'KART' )
  Set Relation To RecNo() into KART_
  r_use( dir_server + 'human_2', , 'HUMAN_2' )
  r_use( dir_server + 'human_', , 'HUMAN_' )
  r_use( dir_server + 'human', dir_server + 'humans', 'HUMAN' )
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2, To kod_k into KART
  //
  // //////////////////////////////////////////////////////////////////
  mdate_rak := arr_m[ 6 ] + 13 // по какую дату РАК сумма к оплате 13.04.25    Основание - письмо  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // //////////////////////////////////////////////////////////////////
  r_use( dir_server + 'mo_xml', , 'MO_XML' )
  r_use( dir_server + 'mo_rak', , 'RAK' )
  Set Relation To kod_xml into MO_XML
  r_use( dir_server + 'mo_raks', , 'RAKS' )
  Set Relation To akt into RAK
  r_use( dir_server + 'mo_raksh', , 'RAKSH' )
  Set Relation To kod_raks into RAKS
  Index On Str( kod_h, 7 ) to ( cur_dir + 'tmp_raksh' ) For mo_xml->DFILE <= mdate_rak
  //
  r_use( dir_server + 'schet_', , 'SCHET_' )
  r_use( dir_server + 'schet', , 'SCHET' )
  Set Relation To RecNo() into SCHET_
  ob_kol := 0
  Go Top
  Do While !Eof()
    fl := .f.
    If schet_->IS_DOPLATA == 0 .and. !Empty( Val( schet_->smo ) ) .and. schet_->NREGISTR == 0 // только зарегистрированные
      @ MaxRow(), 0 Say PadR( AllTrim( schet_->NSCHET ) + ' от ' + date_8( schet_->DSCHET ), 27 ) Color 'W/R'
      // дата регистрации
      mdate := date_reg_schet()
      // дата отчетного периода
      mdate1 := SToD( StrZero( schet_->nyear, 4 ) + StrZero( schet_->nmonth, 2 ) + '25' ) // !!!
      //
      // 2025 год
      k := 7 // дата регистрации по 07.04.25 // Основание - письмо!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      //
      fl := Between( mdate, arr_m[ 5 ], arr_m[ 6 ] + k ) .and. Between( mdate1, arr_m[ 5 ], arr_m[ 6 ] ) // !!отч.период 2023 год
    Endif
    If fl
      Select HUMAN
      find ( Str( schet->kod, 6 ) )
      Do While human->schet == schet->kod .and. !Eof()
        updatestatus()
        If Inkey() == K_ESC
          fl_exit := .t.
          Exit
        Endif
        // по умолчанию оплачен, если даже нет РАКа
        koef := 1 ; k := j := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While human->kod == raksh->kod_h .and. !Eof()
          If !Empty( raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP )
            ++j
          Endif
          k += raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          Skip
        Enddo
        If !Empty( Round( k, 2 ) )
          If Empty( human->cena_1 ) // скорая помощь
            koef := 0
          Elseif round_5( human->cena_1, 2 ) <= round_5( k, 2 ) // полное снятие
            koef := 0
          Else // частичное снятие
            koef := ( human->cena_1 - k ) / human->cena_1
          Endif
          Select RAKSH
          find ( Str( human->kod, 7 ) )
          Do While human->kod == raksh->kod_h .and. !Eof()
            If !Empty( raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP )
              Select TMPF14
              Append Blank
              tmpf14->KOD_XML   := rak->kod_xml
              tmpf14->SCHET     := schet->kod
              tmpf14->KOD_RAK   := raks->AKT
              tmpf14->KOD_RAKS  := raksh->KOD_RAKS
              tmpf14->KOD_RAKSH := raksh->( RecNo() )
              tmpf14->KOD_H     := human->kod
              tmpf14->kol_akt   := j
              tmpf14->usl_ok    := iif( schet_->BUKVA == 'T', 5, human_->USL_OK )
            Endif
            Select RAKSH
            Skip
          Enddo
        Endif
        If koef > 0
          AFill( fl_pol1, 0 )
          is_vmp := ( human_2->VMP == 1 )
          is_trudosp := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data, 4 ) // настроен на 2023-2024 год
          is_reabili := ( human_->PROFIL == 158 )
          is_rebenok := ( human->VZROS_REB > 0 )
          is_inogoro := ( Int( Val( schet_->smo ) ) == 34 )
          igs := iif( f_is_selo( kart_->gorod_selo, kart_->okatog ), 3, 2 )
          If !( fl_stom := ( schet_->BUKVA == 'T' ) ) // стоматология в отдельной таблице
            arr_pril5[ 1, igs ] += Round( human->cena_1 * koef, 2 )
          Endif
          If schet_->BUKVA == 'K' // отдельные медицинские услуги учитываем только суммой d 14-й форме
            arr_pol1[ 6, 4 ] += Round( human->cena_1 * koef, 2 )
            If is_inogoro
              arr_pol1[ 6, 5 ] += Round( human->cena_1 * koef, 2 )
            Endif
            // теперь делим по услугам
            svp := Space( 5 )
            vr_rec := hu->( RecNo() )
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
                lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              Endif
              If PadR( AllTrim( lshifr ), 5 ) == '60.4.'
                // KT
                arr_pol3000[ 23, 4 ] += Round( hu->stoim_1 * koef, 2 )
                arr_pol3000[ 23, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 23, 5 ] += Round( hu->stoim_1 * koef, 2 )
                  arr_pol3000[ 23, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.5.'
                // МРТ
                arr_pol3000[ 24, 4 ] += Round( hu->stoim_1 * koef, 2 )
                arr_pol3000[ 24, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 24, 5 ] += Round( hu->stoim_1 * koef, 2 )
                  arr_pol3000[ 24, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.6.'
                // УЗИ ССС
                arr_pol3000[ 25, 4 ] += Round( hu->stoim_1 * koef, 2 )
                arr_pol3000[ 25, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 25, 5 ] += Round( hu->stoim_1 * koef, 2 )
                  arr_pol3000[ 25, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.7.'
                // ' Эндоскопические диагностические исследования'
                arr_pol3000[ 26, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 26, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 26, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 26, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.9.'
                // ' Молекулярно-генетические исследования'
                arr_pol3000[ 27, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 27, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 27, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 27, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '60.8.'
                // ' Гистологические исследования'
                arr_pol3000[ 28, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 28, 2 ] += 1
                arr_pol1[ 6, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 28, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 28, 3 ] += 1
                  arr_pol1[ 6, 3 ] += 1
                Endif
              Endif
              Skip
            Enddo
            Select HU
            Goto ( vr_rec )
            Select HUMAN
          Endif
          //
          If human_->USL_OK == 3 // только поликлиника
            // if !eq_any(schet_->BUKVA,'K','T','S','Z','M','H')
            // теперь делим по услугам
            svp := Space( 5 )
            vr_rec := hu->( RecNo() )
            Select HU
            find ( Str( human->kod, 7 ) )
            Do While hu->kod == human->kod .and. !Eof()
              lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
              If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
                lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              Endif
              If eq_any( PadR( AllTrim( lshifr ), 8 ), ;
                  '2.79.34 ', '2.79.37 ', '2.79.38 ', ;
                  '2.79.49 ', '2.79.50 ', '2.79.63 ', ;
                  '2.79.64 ', '2.88.35 ', '2.88.36 ', ;
                  '2.79.37 ', '2.88.50 ', '2.88.54 ', ;
                  '2.88.116', '2.88.117', '2.88.118' )
                // 'из строки 06 - посещения работников, со средним м/о'
                arr_pol3000[ 12, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 12, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 12, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 12, 3 ] += 1
                Endif
              Elseif PadR( AllTrim( lshifr ), 8 ) == '2.88.107'
                // 'из строки 06 - посещения амбулаторных ОНКО центров'
                arr_pol3000[ 13, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 13, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 13, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 13, 3 ] += 1
                Endif
              Elseif eq_any( PadR( AllTrim( lshifr ), 8 ), ;
                  '2.88.24 ', '2.88.25 ', '2.88.104', ;
                  '2.81.24 ', '2.81.25 ', '2.81.26 ', ;
                  '2.81.27 ', '2.81.28 ', '2.81.29 ', ;
                  '2.81.30 ', '2.81.31 ', '2.81.32 ', ;
                  '2.81.33 ', '2.81.45 ', '2.88.104' )
                // 'из строки 12 - посещения по специальности 'онкология''
                arr_pol3000[ 14, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 14, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 14, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 14, 3 ] += 1
                Endif
              Elseif eq_any( Left( lshifr, 5 ), '2.79.', '2.76.' )
                // 'посещения с другими целями, всего'
                If eq_any( PadR( AllTrim( lshifr ), 7 ), ;
                    '2.79.34', '2.79.37', '2.79.38', ;
                    '2.79.49', '2.79.50', '2.79.59', ;
                    '2.79.60', '2.79.61', '2.79.62', ;
                    '2.79.63', '2.79.64' )
                Else
                  arr_pol3000[ 16, 4 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 16, 2 ] += 1
                  If is_inogoro
                    arr_pol3000[ 16, 5 ] += Round( human->cena_1 * koef, 2 )
                    arr_pol3000[ 16, 3 ] += 1
                  Endif
                Endif
              Elseif eq_any( PadR( AllTrim( lshifr ), 8 ), ;
                  '2.78.61 ', '2.78.62 ', '2.78.63 ', ;
                  '2.78.64 ', '2.78.65 ', '2.78.66 ', ;
                  '2.78.67 ', '2.78.68 ', '2.78.69 ', ;
                  '2.78.70 ', '2.78.71 ', '2.78.72 ', ;
                  '2.78.73 ', '2.78.74 ', '2.78.75 ', ;
                  '2.78.76 ', '2.78.77 ', '2.78.78 ', ;
                  '2.78.79 ', '2.78.80 ', '2.78.81 ', ;
                  '2.78.82 ', '2.78.83 ', '2.78.84 ', ;
                  '2.78.85 ', '2.78.86 ', ;
                  '2.78.109', '2.78.110', '2.78.111', '2.78.112' )
                // 'из строки 06 посещения с целью диспансерного наблюдения'
                If eq_any( PadR( AllTrim( lshifr ), 8 ), '2.78.109', '2.78.110', '2.78.111', '2.78.112' )
                  arr_pol3000[ 7, 4 ] += Round( human->cena_1 * koef, 2 )
                  If is_inogoro
                    arr_pol3000[ 7, 5 ] += Round( human->cena_1 * koef, 2 )
                  Endif
                Else
                  arr_pol3000[ 7, 4 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 7, 2 ] += 1
                  If is_inogoro
                    arr_pol3000[ 7, 5 ] += Round( human->cena_1 * koef, 2 )
                    arr_pol3000[ 7, 3 ] += 1
                  Endif
                Endif
              Elseif PadR( AllTrim( lshifr ), 5 ) == '2.60.'
                If eq_any( human_->pztip, 38, 42, 43, 44, ) // только 2024 год
                  // '2.78.109', '2.78.110','2.78.111','2.78.112')
                  // 'из строки 06 посещения с целью диспансерного наблюдения'
                  // только посещения
                  arr_pol3000[ 7, 2 ] += 1
                  If is_inogoro
                    arr_pol3000[ 7, 3 ] += 1
                  Endif
                Endif
              Endif
              Skip
            Enddo
            Select HU
            Goto ( vr_rec )
            Select HUMAN
            // endif // конце счетов !К
          Endif
          //
          is_dializ := .f.
          is_z_sl := .f.
          is_ekstra := .f.
          is_centr_z := .f.
          is_s_obsh := .f.
          is_disp_nabluden := .f.
          is_kt := .f.
          is_school := .f.
          is_prvs_206 := ( ret_new_prvs( human_->prvs ) == 206 ) // лечебное дело
          kol_2_3 := kol_2_6 := kol_2_60 := kol_sr := kol_2_sr := 0
          isp := 1
          is_sred_stom := .f.
          ds_spec := ds1_spec := kol_stom := kol_dializ := 0
          vid_vp := 0 // по умолчанию профилактика
          d2_year := Year( human->k_data )
          If human_->USL_OK == 1 // стационар
            //
          Elseif human_->USL_OK == 2 // дневной стационар
            is_ekstra := ( human_->PROFIL == 137 )
          Elseif human_->USL_OK == 3 // поликлиника
            vid_vp := -1
          Elseif human_->USL_OK == 4 // скорая помощь
            i := Int( Val( SubStr( human_->FORMA14, 1, 1 ) ) )
            isp := iif( i == 0, 1, 2 )
          Endif
          afillall( tfoms_pz, 0 )
          ap := {}
          arr_usl := {} ; au := {}
          arr_full_usl := {}
          lvidpom := 1
          lvidpoms := ''
          svp := Space( 5 )
          Select HU
          find ( Str( human->kod, 7 ) )
          Do While hu->kod == human->kod .and. !Eof()
            lshifr1 := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data )
            If is_usluga_tfoms( usl->shifr, lshifr1, human->k_data, , , , , @svp )
              lshifr := iif( Empty( lshifr1 ), usl->shifr, lshifr1 )
              AAdd( arr_full_usl, lshifr )
              ta := f14tf_nastr( @lshifr, , d2_year )
              lshifr := AllTrim( lshifr )
              AAdd( au, { lshifr, hu->kol_1, Round( hu->stoim_1 * koef, 2 ), 0, 0, hu->kol_1 } )
              i16 := 0
              dbSelectArea( lal )
              find ( PadR( lshifr, 10 ) )
              If Found() .and. !Empty( &lal.->unit_code )
                Select MOUNIT    // !!! ВНИМАНИЕ
                find ( Str( &lal.->unit_code, 3 ) )
                If Found() .and. mounit->pz > 0
                  If ( i16 := mounit->ii ) > 0
                    nameArr := get_array_pz( year( human->k_data ) )
                    j1 := nameArr[ i16, 2 ] // j1 := nameArr[i16, 1]

                    If eq_any( j1, 30 )  // в 2023-68  75 убрал - это бывшая стом //09.07.23
                      vid_vp := 0 // Посещение профилактическое
                    Elseif eq_any( j1, 31 ) // в 2023-69 76 убрал - это бывшая стом//09.07.23
                      vid_vp := 1 // в неотложной форме
                    Elseif eq_any( j1, 32, 322, 323 )  // в 2023 (70, 91, 92) 77 убрал - это бывшая стом //09.07.23
                      vid_vp := 2 // обращения с лечебной целью
                    Elseif j1 == 38 // 2023 -71
                      is_centr_z := .t.
                      vid_vp := 0 // Посещение профилактическое Центра здоровья
                    Elseif eq_any( j1, 261, 262, 318, 319, 320, 321, 512, 513, 670, 671 )  // 2023- 73, 74, 87, 88, 89, 90, 59, 78 т.е.   //09.07.23
                      // добавлена Д репродуктивного здоровья
                      vid_vp := 0 // комплексное посещение при диспансеризации
                      is_z_sl := .t.
                      fl_pol3000_DVN2 := .f.
                      // вставить деление на ПРОФОСМОТР
                      fl_pol3000_DVN2 := .t.
                      If j1 == 262 // ДВН - 2 этап
                        fl_pol3000_DVN2 := .f.
                      Endif
                      //
                    Elseif eq_any( j1, 206, 153, 69, 148, 149, 150, 151, 161, 162 )  .or. Between( j1, 324, 329 ) // исследования
                      is_kt := .t.
                      ds1_spec := 1
                      vid_vp := 2 // с лечебной целью
                    Elseif eq_any( j1, 205, 388, 259 )
                      is_dializ := .t.
                      // elseif   57 - реабилитация
                    Elseif j1 == 583 // 583 - школа сах диабета - посещение профилактическое
                      vid_vp := 0 // Посещение профилактическое
                      is_school := .t.
                    Endif
                  Endif
                Endif
                Select HU
              Endif
              If human_->USL_OK == 1 // стационар
                If Left( lshifr, 5 ) == '1.11.'
                  kol_dializ += hu->kol_1 // койко-день
                Endif
              Elseif human_->USL_OK == 2  // дневной стационар
                If Left( lshifr, 5 ) == '60.3.'
                  is_dializ := .t.
                  kol_dializ += hu->kol_1
                Endif
                AAdd( arr_usl, lshifr )
                // aadd(arr_full_usl,lshifr)
                If !Empty( svp ) .and. ',' $ svp
                  lvidpoms := svp
                Endif
                If ( i := ret_vid_pom( 1, lshifr, human->k_data ) ) > 0
                  lvidpom := i
                Endif
              Elseif eq_any( Left( lshifr, 5 ), '2.78.', '2.89.' ) // обращения с лечебной целью
                If  eq_any( Left( lshifr, 8 ), '2.78.107', '2.78.109', '2.78.110', '2.78.111', '2.78.112' )// диспансерное наблюдение
                  // диспансерное наблюдение
                  is_disp_nabluden := .t.
                Endif
                vid_vp := 2 // обращения с лечебной целью
                If lshifr == '2.78.2'
                  is_s_obsh := .t. // врачи общей практики
                Elseif eq_any( lshifr, '2.78.36', '2.78.39', '2.78.40' )
                  kol_sr += hu->kol_1
                Endif
                If Left( lshifr, 5 ) == '2.89.'
                  ds_spec := 1 // первичная специализированная
                  is_reabili := .t.
                Elseif !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87 )
                  ds_spec := 1
                Endif
                // признак онкологии
                // if eq_any(lshifr, '2.78.19', '2.78.45', '2.78.87', '2.78.90', '2.78.91')
                //
                // endif
              Endif
              If f_is_zak_sl_vr( lshifr )
                is_z_sl := .t.
              Endif
              //
              If eq_any( Left( lshifr, 4 ), '2.6.', '2.60' )
                kol_stom += hu->kol_1
              Endif
              // онкология
              If eq_any( lshifr, '2.3.3', '2.3.4', '2.60.3', '2.60.4' ) // фельдшерские приёмы
                fl_pol1[ 15 ] := -1
              Endif
              If eq_any( lshifr, '2.78.60', '2.79.63', '2.79.64', '2.80.38', '2.88.50' ) // зубной врач (средний мед.персонал)
                fl_pol1[ 15 ] := -1
                is_sred_stom := .t.
              Endif
              If Left( lshifr, 5 ) == '2.80.' .and. hu->KOL_RCP < 0 // посещения в неотложной форме на дому
                fl_pol1[ 12 ] += hu->kol_1
              Endif
              If Left( lshifr, 5 ) == '2.88.' .and. hu->KOL_RCP < 0 // разовое посещение на дому
                fl_pol1[ 7 ] += hu->kol_1
              Endif
              //
              For j := 1 To Len( ta )
                k := ta[ j, 1 ]
                mkol1 := 0
                If Between( k, 1, 10 )
                  If ta[ j, 2 ] == 1 // законченный случай стационара
                    mkol := human->k_data - human->n_data  // койко-день
                  Elseif ta[ j, 2 ] == 0
                    mkol := hu->kol_1
                  Else
                    mkol := 0
                    mkol1 := hu->kol_1
                  Endif
                  muet := 0
                  msum := Round( hu->stoim_1 * koef, 2 )
                  //
                  ii := 0
                  is_obsh := .f.
                  If k == 2 // стационар
                    ii := 1
                  Elseif k == 1 // поликлиника
                    ii := 2
                    AAdd( arr_usl, Left( lshifr, 5 ) )
                    If Left( lshifr, 2 ) == '2.'
                      If Left( lshifr, 4 ) == '2.3.'
                        kol_2_3 += hu->kol_1
                        If eq_any( lshifr, '2.3.3', '2.3.4' )
                          kol_2_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 4 ) == '2.6.'
                        kol_2_6 += hu->kol_1
                      Elseif Left( lshifr, 5 ) == '2.60.'
                        kol_2_60 += hu->kol_1
                        If eq_any( lshifr, '2.60.3', '2.60.4' )
                          kol_2_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.76.' // центр здоровья
                        vid_vp := 0 // Посещение профилактическое
                        // !!!
                        arr_pol3000[ 11, 4 ] := Round( human->cena_1 * koef, 2 )
                        arr_pol3000[ 11, 2 ] := 1
                        If is_inogoro
                          arr_pol3000[ 11, 5 ] := Round( human->cena_1 * koef, 2 )
                          arr_pol3000[ 11, 3 ] := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.92.' // школа сахарного диабета
                        vid_vp := 0 // Посещение профилактическое
                        // !!!
                        arr_pol3000[ 11, 4 ] := Round( human->cena_1 * koef, 2 )
                        arr_pol3000[ 11, 2 ] := 1
                        If is_inogoro
                          arr_pol3000[ 11, 5 ] := Round( human->cena_1 * koef, 2 )
                          arr_pol3000[ 11, 3 ] := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.79.' // посещение с профилактической целью
                        vid_vp := 0 // Посещение профилактическое
                        If !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87 )
                          ds1_spec := 1 // первичная специализированная
                        Endif
                        If eq_any( lshifr, '2.79.2', '2.79.45' )
                          is_obsh := .t.
                        Endif
                        If eq_any( lshifr, '2.79.34', '2.79.37', '2.79.38', '2.79.49', '2.79.50' )
                          kol_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.80.' // в неотложной форме
                        vid_vp := 1 // в неотложной форме
                        If !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87, 160 )
                          ds1_spec := 1
                        Endif
                        // if lshifr == '2.80.2' - нет такой услуги
                        // is_obsh := .t.
                        // endif
                        // if eq_any(lshifr,'2.80.19','2.80.22','2.80.23','2.80.27') - услуги удалены
                        If eq_any( lshifr, '2.80.53', '2.80.54' ) // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                          kol_sr += hu->kol_1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.81.' // консультации специалистов
                        vid_vp := 0 // Посещение профилактическое
                        If !eq_any( human_->PROFIL, 68, 97 )
                          ds1_spec := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.82.' // Посещение в приёмном покое (в неотложной форме)
                        vid_vp := 1 // в неотложной форме
                        If !eq_any( human_->PROFIL, 57, 68, 97 )
                          ds1_spec := 1
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.83.' // диспансеризация детей-сирот
                        If lshifr == '2.83.15'
                          is_obsh := .t.
                        Endif
                      Elseif Left( lshifr, 5 ) == '2.88.' // разовое посещение
                        vid_vp := 0 // Посещение профилактическое
                        If !eq_any( human_->PROFIL, 97, 57, 68, 3, 42, 85, 87 )
                          ds1_spec := 1
                        Endif
                        If eq_any( lshifr, '2.88.3' ) // ,'2.88.53','2.88.79' - нет услуг
                          is_obsh := .t.
                        Endif
                        If eq_any( lshifr, '2.88.35', '2.88.36', '2.88.37' )
                          kol_sr += hu->kol_1
                        Endif
                      Endif
                    Elseif Left( lshifr, 5 ) == '60.3.'
                      is_dializ := .t.
                    Endif
                    If i16 > 0
                      AAdd( ap, { lshifr, iif( Empty( mkol ), mkol1, mkol ), is_obsh } )
                    Endif
                  Elseif k == 7 // отд.мед.услуги
                    If glob_mo[ _MO_KOD_TFOMS ] == '171004' .and. human_->USL_OK == 1 // стационар КБ4
                      ii := 1 // стационар
                    Else
                      ii := 2 // в поликлинику
                      mkol := 0  // участвует не количеством, а только суммой
                      is_kt := .t.
                      ds1_spec := 1
                    Endif
                  Elseif k == 8 // СМП
                    ii := 5
                  Elseif eq_any( k, 3, 4, 5 ) // дневной стационар
                    ii := 4
                    If Left( lshifr, 5 ) == '55.1.'
                      //
                    Else
                      mkol := 0
                    Endif
                  Endif
                  If is_dializ
                    If human_->USL_OK == 1 // стационар
                      ii := 1
                    Elseif human_->USL_OK == 2 // дневной стационар
                      ii := 4
                    Elseif human_->USL_OK == 3 // поликлиника
                      ii := 2
                      mkol := 1
                      ds_spec := ds1_spec := 1
                      vid_vp := 2 // по поводу заболевания
                    Endif
                  Endif
                  If fl_stom // стоматология
                    //
                  Elseif ii > 0
                    tfoms_pz[ ii, 1 ] := 1
                    tfoms_pz[ ii, 2 ] += mkol
                    tfoms_pz[ ii, 3 ] += msum
                    If is_vmp
                      tfoms_pz[ ii, 9 ] := 1
                      tfoms_pz[ ii, 10 ] += mkol
                      tfoms_pz[ ii, 11 ] += msum
                    Endif
                    If ii == 2 // поликлиника
                      If is_obsh
                        tfoms_pz[ ii, 7 ] += mkol
                        tfoms_pz[ ii, 8 ] += msum
                        If ds1_spec == 1
                          tfoms_pz[ ii, 9 ] += mkol
                          tfoms_pz[ ii, 10 ] += msum
                        Endif
                      Else
                        If ds1_spec == 1
                          tfoms_pz[ ii, 5 ] += mkol
                          tfoms_pz[ ii, 6 ] += msum
                        Endif
                      Endif
                    Endif
                  Endif
                Endif
              Next j
            Endif
            Select HU
            Skip
          Enddo
          If kol_dializ > 0
            tfoms_pz[ ii, 2 ] := kol_dializ // заменяем на кол-во диализных процедур
          Endif
          ta := {}
          If fl_stom // стоматология
            tfoms_pz[ 1, 1 ] := 0
            tfoms_pz[ 2, 1 ] := 0
            tfoms_pz[ 3, 1 ] := 1
            tfoms_pz[ 4, 1 ] := 0
            tfoms_pz[ 5, 1 ] := 0
          Endif
          Do Case
            // стационар
          Case tfoms_pz[ 1, 1 ] > 0
            tfoms_pz[ 1, 2 ] := kol_dializ
            If ( i := AScan( arr_profil, {| x| x[ 1 ] == human_->PROFIL } ) ) == 0
              AAdd( arr_profil, { human_->PROFIL, 0, 0, 0, 0 } ) ; i := Len( arr_profil )
            Endif
            If human->ishod == 88 // это 1-й л/у в двойном случае
              tfoms_pz[ 1, 1 ] := 0
            Else
              arr_profil[ i, 2 ] ++
            Endif
            arr_profil[ i, 3 ] += Round( human->cena_1 * koef, 2 )
            If is_inogoro
              arr_profil[ i, 4 ] ++; arr_profil[ i, 5 ] += Round( human->cena_1 * koef, 2 )
            Endif
            arr_pril5[ 15, igs ] += tfoms_pz[ 1, 2 ] // 'Стационар - койко-дней'
            arr_pril5[ 16, igs ] += tfoms_pz[ 1, 1 ] // 'Стационар - случаев госпитализации'
            arr_pril5[ 17, igs ] += tfoms_pz[ 1, 3 ] // 'Стационар - руб.'
            If is_vmp
              arr_pril5[ 18, igs ] += tfoms_pz[ 1, 2 ] // Стац(ВМП) - койко-дней'
              arr_pril5[ 19, igs ] += tfoms_pz[ 1, 1 ] // Стац(ВМП) - случаев госпитализации'
              arr_pril5[ 20, igs ] += tfoms_pz[ 1, 3 ] // Стац(ВМП) - руб.'
            Endif
            AAdd( ta, { 5, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
            AAdd( ta, { 10, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            If is_rebenok
              AAdd( ta, { 6, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 11, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            If is_trudosp
              AAdd( ta, { 7, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 12, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            If is_reabili
              arr_pril5[ 21, igs ] += tfoms_pz[ 1, 2 ] // 'Стац(реабил) - койко-дней'
              arr_pril5[ 22, igs ] += tfoms_pz[ 1, 1 ] // 'Стац(реабил) - случаев госпитализации'
              arr_pril5[ 23, igs ] += tfoms_pz[ 1, 3 ] // 'Стац(реабил) - руб.'
              AAdd( ta, { 8, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 13, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            If is_inogoro
              AAdd( ta, { 9, tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 1 ], tfoms_pz[ 1, 9 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 3 ], tfoms_pz[ 1, 11 ] } )
              AAdd( ta, { 14, tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 2 ], tfoms_pz[ 1, 10 ] } )
            Endif
            // поликлиника
          Case tfoms_pz[ 2, 1 ] > 0
            arr_pril5[ 9, igs ] += Round( human->cena_1 * koef, 2 ) // 'Всего расходов на амб.помощь'
            If is_kt // для КТ обнуляем количество
              tfoms_pz[ ii, 1 ] := tfoms_pz[ ii, 2 ] := tfoms_pz[ ii, 5 ] := tfoms_pz[ ii, 7 ] := tfoms_pz[ ii, 9 ] := 0
            Elseif is_dializ // перит.диализ
              vid_vp := 2 // по поводу заболевания
              ds_spec := 1
            Endif
            If kol_2_60 > 0 .and. AScan( arr_usl, '2.78.' ) > 0
              arr_pril5[ 8, igs ] += kol_2_60 // 'Всего посещений'
              // //////////////////////////////////////////////
            Endif
            If kol_2_60 > 0 .and. AScan( arr_usl, '2.78.' ) > 0
              arr_pril5[ 8, igs ] += kol_2_60 // 'Всего посещений'
              // //////////////////////////////////////////////
            Endif
            // онкология в т.3000
            If kol_2_60 > 0 // .and. ;
              If eq_ascan( arr_full_usl, '2.78.19', '2.78.45', '2.78.87', '2.78.90', '2.78.91' )
                arr_pol3000[ 21, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 21, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 21, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 21, 3 ] += 1
                Endif
              Endif
            Endif
            If schet_->BUKVA == 'O'  // диспансеризация 2-й этап
              If AScan( arr_usl, '2.84.' ) > 0 .or. AScan( arr_full_usl, '56.1.723' ) > 0
                arr_pol3000[ 8, 4 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 8, 2 ] += 1
                If is_inogoro
                  arr_pol3000[ 8, 5 ] += Round( human->cena_1 * koef, 2 )
                  arr_pol3000[ 8, 3 ] += 1
                Endif
              Endif
            Endif
            //
            If kol_2_6 > 0 .and. AScan( arr_usl, '2.89.' ) > 0
              arr_pril5[ 8, igs ] += kol_2_6 // 'Всего посещений'
            Endif
            fl := eq_any( schet_->BUKVA, 'A', 'K' )
            If schet_->BUKVA == 'K'
              vid_vp := 2 // по поводу заболевания
              ds1_spec := 1
              sum_k += tfoms_pz[ 2, 3 ]
              If is_rebenok
                sum_kd += tfoms_pz[ 2, 3 ]
              Endif
              If is_trudosp
                sum_kt += tfoms_pz[ 2, 3 ]
              Endif
              If is_inogoro
                sum_ki += tfoms_pz[ 2, 3 ]
              Endif
            Endif
            If vid_vp == 1 // в неотложной форме
              fl_pol1[ 11 ] += tfoms_pz[ 2, 2 ]
              arr_pril5[ 8, igs ] += tfoms_pz[ 2, 2 ] // 'Всего посещений'
              arr_pril5[ 13, igs ] += tfoms_pz[ 2, 2 ] // 'Число посещений по неотл.мед.помощи'
              arr_pril5[ 14, igs ] += tfoms_pz[ 2, 3 ] // 'руб.'
              AAdd( ta, { 22, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 24
              AAdd( ta, { 23, tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 9 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 10 ] } ) // 25
              If fl
                arr_pol[ 22 ] += tfoms_pz[ 2, 3 ]
                arr_pol[ 23 ] += tfoms_pz[ 2, 8 ]
              Endif
              If is_rebenok
                AAdd( ta, { 24, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 26
                If fl
                  arr_pol[ 24 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_trudosp
                AAdd( ta, { 25, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 27
                If fl
                  arr_pol[ 25 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_inogoro
                AAdd( ta, { 26, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } ) // 28
                If fl
                  arr_pol[ 26 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
            Elseif vid_vp == 2 // по поводу заболевания
              fl_pol1[ 13 ] := -1
              If is_disp_nabluden
                arr_pril5[ 32, igs ] += tfoms_pz[ 2, 1 ] // 'Число обращений по поводу заболевания'
              Else
                arr_pril5[ 10, igs ] += tfoms_pz[ 2, 1 ] // 'Число обращений по поводу заболевания'
                AAdd( ta, { 27, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                If fl
                  arr_pol[ 27 ] += tfoms_pz[ 2, 3 ]
                Endif
                If is_s_obsh
                  AAdd( ta, { 28, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 28 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_rebenok
                  AAdd( ta, { 29, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 29 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_trudosp
                  AAdd( ta, { 30, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 30 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_reabili
                  AAdd( ta, { 31, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 31 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
                If is_inogoro
                  AAdd( ta, { 32, tfoms_pz[ 2, 1 ], tfoms_pz[ 2, 1 ], iif( ds_spec == 1, tfoms_pz[ 2, 1 ], 0 ), tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], iif( ds_spec == 1 .or. ds1_spec == 1, tfoms_pz[ 2, 3 ], 0 ) } )
                  If fl
                    arr_pol[ 32 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
              Endif
            Elseif vid_vp == 0 // профилактика
              tfoms_pz[ 2, 2 ] := tfoms_pz[ 2, 7 ] := tfoms_pz[ 2, 9 ] := tfoms_pz[ 2, 5 ] := 0 // обнулим количество приемов
              If eq_any( schet_->BUKVA, 'O', 'F', 'R', 'D', 'U', 'W', 'Y', 'I', 'V' ) // диспансеризация и профосмотры + углубленная + репродуктивка 09.07.24
                lshifr := 'дисп-ия' ; lkol := 1
                If ( j := AScan( arr_prof, {| x| x[ 1 ] == lshifr } ) ) == 0
                  AAdd( arr_prof, { lshifr, 0 } ) ; j := Len( arr_prof )
                Endif
                arr_prof[ j, 2 ] += lkol
                //
                tfoms_pz[ 2, 2 ] += lkol
                If is_prvs_206 // лечебное дело в диспансеризации
                  fl_pol1[ 15 ] += lkol
                Endif
                // терапевт, педиатр, врач общей практики, фельдшер при диспансеризации
                fl_pol1[ 3 ] += lkol
                fl_pol1[ 4 ] += lkol
                fl_pol3000_PROF := .f.
                If eq_any( schet_->BUKVA, 'F', 'R' ) // диспансеризация и профосмотры
                  fl_pol3000_PROF := .t.
                Else
                  fl_pol3000_PROF := .f.
                Endif
              Else
                For i := 1 To Len( ap )
                  lshifr := ap[ i, 1 ] ; lkol := ap[ i, 2 ]
                  If ( j := AScan( arr_prof, {| x| x[ 1 ] == lshifr } ) ) == 0
                    AAdd( arr_prof, { lshifr, 0 } ) ; j := Len( arr_prof )
                  Endif
                  arr_prof[ j, 2 ] += lkol
                  //
                  tfoms_pz[ 2, 2 ] += lkol
                  If ap[ i, 3 ] // is_obsh
                    tfoms_pz[ 2, 7 ] += lkol
                    If ds1_spec == 1
                      tfoms_pz[ 2, 9 ] += lkol
                    Endif
                  Else
                    If ds1_spec == 1
                      tfoms_pz[ 2, 5 ] += lkol
                    Endif
                  Endif
                  If eq_any( Left( lshifr, 5 ), '2.79.', '2.76.' ) // профилактика и центры здоровья
                    If between_shifr( lshifr, '2.79.44', '2.79.50' )  // патронаж
                      fl_pol1[ 9 ] += lkol
                      If eq_any( human_->profil, 49, 53, 54 ) // паллиативная медицинская помощь
                        fl_pol1[ 10 ] += lkol
                      Endif
                    Else
                      fl_pol1[ 3 ] += lkol
                    Endif
                  Endif
                  If eq_any( lshifr, '2.79.34', '2.79.37', '2.79.38', '2.79.49', '2.79.50', ; // фельдшерские приёмы
                    '2.79.63', '2.79.64', '2.88.50', ;
                      '2.80.19', '2.80.22', '2.80.23', '2.80.27', ;
                      '2.88.35', '2.88.36', '2.88.37', '2.90.2' )
                    fl_pol1[ 15 ] += lkol
                  Endif
                  If eq_any( Left( lshifr, 5 ), '2.88.', '2.81.' ) // разовое посещение или консультации
                    fl_pol1[ 6 ] += lkol
                  Endif
                Next
              Endif
              If is_z_sl .and. tfoms_pz[ 2, 2 ] > 0
                tfoms_pz[ 2, 3 ] := Round( human->cena_1 * koef, 2 )
                If ds1_spec == 1
                  tfoms_pz[ 2, 6 ] := Round( human->cena_1 * koef, 2 )
                Endif
                If is_obsh
                  tfoms_pz[ 2, 8 ] := Round( human->cena_1 * koef, 2 )
                  If ds1_spec == 1
                    tfoms_pz[ 2, 10 ] := Round( human->cena_1 * koef, 2 )
                  Endif
                Endif
              Endif
              If eq_any( schet_->BUKVA, 'G', 'J', 'D', 'O', 'R', 'F', 'V', 'I', 'U' )
                kol_d += tfoms_pz[ 2, 2 ]
                sum_d += tfoms_pz[ 2, 3 ]
              Endif
              arr_pril5[ 8, igs ] += tfoms_pz[ 2, 2 ] // 'Всего посещений'
              arr_pril5[ 11, igs ] += tfoms_pz[ 2, 2 ] // 'Число посещений с проф.(иной) целью'
              arr_pril5[ 12, igs ] += tfoms_pz[ 2, 3 ] // 'руб.'
              AAdd( ta, { 15, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
              AAdd( ta, { 16, tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 7 ], tfoms_pz[ 2, 9 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 8 ], tfoms_pz[ 2, 10 ] } )
              If fl
                arr_pol[ 15 ] += tfoms_pz[ 2, 3 ]
                arr_pol[ 16 ] += tfoms_pz[ 2, 8 ]
              Endif
              If is_centr_z
                AAdd( ta, { 17, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 17 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_rebenok
                AAdd( ta, { 18, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 18 ] += tfoms_pz[ 2, 3 ]
                Endif
                If is_centr_z
                  AAdd( ta, { 19, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                  If fl
                    arr_pol[ 19 ] += tfoms_pz[ 2, 3 ]
                  Endif
                Endif
              Endif
              If is_trudosp
                AAdd( ta, { 20, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 20 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
              If is_inogoro
                AAdd( ta, { 21, tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 2 ], tfoms_pz[ 2, 5 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 3 ], tfoms_pz[ 2, 6 ] } )
                If fl
                  arr_pol[ 21 ] += tfoms_pz[ 2, 3 ]
                Endif
              Endif
            Endif
            // стоматология
          Case tfoms_pz[ 3, 1 ] > 0
            au_flu := {} ; muet := 0
            Select MOHU
            find ( Str( human->kod, 7 ) )
            Do While mohu->kod == human->kod .and. !Eof()
              AAdd( au_flu, { mosu->shifr1, ;         // 1
              c4tod( mohu->date_u ), ;  // 2
              mohu->profil, ;         // 3
              mohu->PRVS, ;           // 4
              mosu->shifr, ;          // 5
              mohu->kol_1, ;          // 6
              c4tod( mohu->date_u2 ), ; // 7
              mohu->kod_diag } )       // 8
              dbSelectArea( lalf )
              find ( mosu->shifr1 )
              muet += round_5( mohu->kol_1 * iif( human->vzros_reb == 0, &lalf.->uetv, &lalf.->uetd ), 2 )
              Select MOHU
              Skip
            Enddo
            tfoms_pz[ 3, 4 ] := muet
            ret_tip := 0
            // 1 с лечебной целью
            // 2 с профилактической целью
            // 2  -- ' -- ' -- ' -- ' -- разовое по поводу заболевания
            // 3 при оказании неотложной помощи
            ret_kol := 0
            is_2_88 := .f.
            f_vid_p_stom( au, {},,, human->k_data, @ret_tip, @ret_kol, @is_2_88, au_flu )
            Do Case
            Case ret_tip == 1
              vid_vp := 2 // по поводу заболевания
              fl_pol1[ 13 ] := -1
              fl_pol1[ 14 ] := -1
            Case ret_tip == 2
              vid_vp := 0 // профилактика
              If is_2_88 // разовое по поводу заболевания
                fl_pol1[ 6 ] := -1
                fl_pol1[ 8 ] := -1
              Else
                fl_pol1[ 3 ] := -1
                fl_pol1[ 5 ] := -1
              Endif
            Case ret_tip == 3
              vid_vp := 1 // в неотложной форме
              fl_pol1[ 11 ] := -1
            Endcase
            tfoms_pz[ 3, 1 ] := 1
            tfoms_pz[ 3, 2 ] := ret_kol
            tfoms_pz[ 3, 3 ] := Round( human->cena_1 * koef, 2 )
            // из строки 06 разовые посещения в связи с заболеваниями
            // из строки 12 - посещения по специальности 'стоматология'
            // СТАВИМ НОООЛЬ
            // 'Посещения при оказании помощи в неотложной форме, всего'
            // 'из строки 21 - посещения по специальности 'стоматология''
            //
            // 'Посещения, включенные в обращение в связи с заболеваниями'
            // 'из строки 25 - посещения по специальности 'стоматология''
            If ret_tip == 1
              arr_pol3000[ 22, 4 ] += Round( human->cena_1 * koef, 2 )
              arr_pol3000[ 22, 2 ] += ret_kol
              If is_inogoro
                arr_pol3000[ 22, 5 ] += Round( human->cena_1 * koef, 2 )
                arr_pol3000[ 22, 3 ] += ret_kol
              Endif
            Endif
            func_f14_stom( tfoms_pz[ 3, 3 ], ret_tip, ret_kol, is_2_88, is_rebenok, is_trudosp, is_inogoro, is_sred_stom )
            kol_stom := ret_kol
            kol_stom_pos += ret_kol
            // в таблицу Excel добавляются только УЕТ-ы
            AAdd( ta, { 45, tfoms_pz[ 3, 4 ], tfoms_pz[ 3, 4 ], tfoms_pz[ 3, 3 ], tfoms_pz[ 3, 3 ] } )
            // дневной стационар
          Case tfoms_pz[ 4, 1 ] > 0
            If !Empty( lvidpoms )
              If !eq_ascan( arr_usl, '55.1.2', '55.1.3' ) .or. glob_mo[ _MO_KOD_TFOMS ] == '801935' // ЭКО-Москва
                lvidpoms := ret_vidpom_licensia( human_->USL_OK, lvidpoms, human_->profil ) // только для дн.стационара при стационаре
              Endif
              If !Empty( lvidpoms ) .and. !( ',' $ lvidpoms )
                lvidpom := Int( Val( lvidpoms ) )
                lvidpoms := ''
              Endif
            Endif
            If !Empty( lvidpoms )
              If eq_ascan( arr_usl, '55.1.1', '55.1.4' )
                If '31' $ lvidpoms
                  lvidpom := 31
                Endif
              Elseif eq_ascan( arr_usl, '55.1.2', '55.1.3', '2.76.6', '2.76.7', '2.81.67' )
                If eq_any( human_->PROFIL, 57, 68, 97 ) // терапия,педиатр,врач общ.практики
                  If '12' $ lvidpoms
                    lvidpom := 12
                  Endif
                Else
                  If '13' $ lvidpoms
                    lvidpom := 13
                  Endif
                Endif
              Endif
            Endif
            //
            If ( i := AScan( arr_dn_stac, {| x| x[ 1 ] == human_->PROFIL } ) ) == 0
              AAdd( arr_dn_stac, { human_->PROFIL, 0, 0, 0, 0 } ) ; i := Len( arr_dn_stac )
            Endif
            is_onkologia := .f.
            If equalany( human_->PROFIL, 18, 60, 76 )
              is_onkologia := .t.
            Endif
            If is_dializ
              lvidpom := 31 // !!!!!!!
            Endif
            arr_dn_stac[ i, 2 ] += tfoms_pz[ 4, 1 ]
            arr_dn_stac[ i, 3 ] += tfoms_pz[ 4, 3 ]
            If lvidpom == 13
              ds_spec := 1
            Elseif lvidpom == 31
              ds_spec := 2
            Else
              ds_spec := 0
            Endif
            If is_rebenok
              arr_dn_stac[ i, 5 ] += tfoms_pz[ 4, 2 ]
            Else
              arr_dn_stac[ i, 4 ] += tfoms_pz[ 4, 2 ]
            Endif
            If AScan( arr_usl, '55.1.3' ) > 0 // на дому
              arrDdn_stac[ 1 ] += tfoms_pz[ 4, 1 ]
              arrDdn_stac[ 2 ] += tfoms_pz[ 4, 3 ]
              If is_rebenok
                arrDdn_stac[ 4 ] += tfoms_pz[ 4, 2 ]
              Else
                arrDdn_stac[ 3 ] += tfoms_pz[ 4, 2 ]
              Endif
            Endif
            arr_pril5[ 24, igs ] += tfoms_pz[ 4, 2 ] // 'Дн.стац. - пациенто-дней'
            arr_pril5[ 25, igs ] += tfoms_pz[ 4, 1 ] // 'Дн.стац. - пациентов, чел.'
            arr_pril5[ 26, igs ] += tfoms_pz[ 4, 3 ] // 'Дн.стац. - руб.'
            AAdd( ta, { 50, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
            AAdd( ta, { 56 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            If is_rebenok // 52 и 57
              AAdd( ta, { 51, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 57 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_trudosp // 54 и 59
              AAdd( ta, { 52, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 58 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_reabili  // 55 и 60
              AAdd( ta, { 53, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 59 -1, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_inogoro  // 56 и 61
              AAdd( ta, { 55 -1, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], iif( ds_spec == 1, tfoms_pz[ 4, 1 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 61 -2, tfoms_pz[ 4, 2 ], tfoms_pz[ 4, 2 ], iif( ds_spec == 1, tfoms_pz[ 4, 2 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 2 ], 0 ), tfoms_pz[ 4, 10 ] } )
            Endif
            If is_ekstra
              arr_pril5[ 27, igs ] += tfoms_pz[ 4, 2 ] // 'Дн.стац.ЭКО - пациенто-дней'
              arr_pril5[ 28, igs ] += tfoms_pz[ 4, 1 ] // 'Дн.стац.ЭКО - пациентов, чел.'
              arr_pril5[ 29, igs ] += tfoms_pz[ 4, 3 ] // 'Дн.стац.ЭКО - руб.'
              arr_eko[ 1, 1 ] += tfoms_pz[ 4, 2 ]
              arr_eko[ 1, 2 ] += tfoms_pz[ 4, 10 ]
              AAdd( ta, { 68 -3, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
              AAdd( ta, { 70 -3, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
              If is_inogoro
                arr_eko[ 2, 1 ] += tfoms_pz[ 4, 2 ]
                arr_eko[ 2, 2 ] += tfoms_pz[ 4, 10 ]
                AAdd( ta, { 69 -3, tfoms_pz[ 4, 1 ], tfoms_pz[ 4, 1 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 1 ], 0 ), tfoms_pz[ 4, 9 ] } )
                AAdd( ta, { 71 -3, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], 0, iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
              Endif
            Endif
            AAdd( ta, { 62 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            If is_rebenok
              AAdd( ta, { 63 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
            If is_trudosp
              AAdd( ta, { 64 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
            If is_reabili
              AAdd( ta, { 65 -2, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
            If is_inogoro
              AAdd( ta, { 67 -3, tfoms_pz[ 4, 3 ], tfoms_pz[ 4, 3 ], iif( ds_spec == 1, tfoms_pz[ 4, 3 ], 0 ), iif( ds_spec == 2, tfoms_pz[ 4, 3 ], 0 ), tfoms_pz[ 4, 11 ] } )
            Endif
              /*if is_onkologia // онкология
                 //  добавка 13.07.22    // стр 54, 60, 66
                 aadd(ta, {54, tfoms_pz[4, 1], tfoms_pz[4, 1], iif(ds_spec == 1, tfoms_pz[4, 1], 0), iif(ds_spec==2, tfoms_pz[4, 1], 0), tfoms_pz[4, 9]})
                 aadd(ta, {60, tfoms_pz[4, 2], tfoms_pz[4, 2], iif(ds_spec == 1, tfoms_pz[4, 2], 0), iif(ds_spec==2, tfoms_pz[4, 2], 0), tfoms_pz[4, 10]})
                 aadd(ta, {66, tfoms_pz[4, 3], tfoms_pz[4, 3], iif(ds_spec == 1, tfoms_pz[4, 3], 0), iif(ds_spec==2, tfoms_pz[4, 3], 0), tfoms_pz[4, 11]})
              endif
              */
            // скорая помощь
          Case tfoms_pz[ 5, 1 ] > 0
            arr_pril5[ 2, igs ] += tfoms_pz[ 5, 1 ] // 'СМП - вызовов, ед.'
            arr_pril5[ 3, igs ] += tfoms_pz[ 5, 1 ] // 'СМП - лиц, чел.'
            arr_pril5[ 4, igs ] += tfoms_pz[ 5, 3 ] // 'СМП - руб.'
            AAdd( ta, { 69, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
            arr_skor[ 69, isp ] += tfoms_pz[ 5, 1 ]
            AAdd( ta, { 73, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
            arr_skor[ 73, isp ] += tfoms_pz[ 5, 1 ]
            AAdd( ta, { 77, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
            arr_skor[ 77, isp ] += tfoms_pz[ 5, 3 ]
            If is_rebenok
              AAdd( ta, { 70, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 70, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 74, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 74, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 78, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
              arr_skor[ 78, isp ] += tfoms_pz[ 5, 3 ]
            Endif
            If is_trudosp
              AAdd( ta, { 71, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 71, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 75, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 75, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 79, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
              arr_skor[ 79, isp ] += tfoms_pz[ 5, 3 ]
            Endif
            If is_inogoro
              AAdd( ta, { 72, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 72, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 76, tfoms_pz[ 5, 1 ], tfoms_pz[ 5, 1 ] } )
              arr_skor[ 76, isp ] += tfoms_pz[ 5, 1 ]
              AAdd( ta, { 80, tfoms_pz[ 5, 3 ], tfoms_pz[ 5, 3 ] } )
              arr_skor[ 80, isp ] += tfoms_pz[ 5, 3 ]
            Endif
          Endcase
          For j := 1 To Len( ta )
            Select TMP
            find ( Str( ta[ j, 1 ], 2 ) )
            If !Found()
              Append Blank
              tmp->nstr := ta[ j, 1 ]
            Endif
            // !!!!
            tmp->sum4 += ta[ j, 2 ]
            tmp->sum5 += ta[ j, 3 ]
            // !!!!
            If Len( ta[ j ] ) > 3
              tmp->sum6 += ta[ j, 4 ]
            Endif
            If Len( ta[ j ] ) > 4
              tmp->sum7 += ta[ j, 5 ]
            Endif
            If Len( ta[ j ] ) > 5
              tmp->sum8 += ta[ j, 6 ]
            Endif
            If Len( ta[ j ] ) > 6
              tmp->sum9 += ta[ j, 7 ]
            Endif
          Next
          For i := 1 To Len( arr_pol1 )
            If fl_pol1[ i ] > 0
              arr_pol1[ i, 2 ] += fl_pol1[ i ]
              arr_pol1[ i, 4 ] += Round( human->cena_1 * koef, 2 )
              If is_inogoro
                arr_pol1[ i, 3 ] += fl_pol1[ i ]
                arr_pol1[ i, 5 ] += Round( human->cena_1 * koef, 2 )
              Endif
              If i == 4
                If fl_pol3000_PROF   // профосмотры
                  arr_pol3000[ 4, 2 ] += fl_pol1[ i ]
                  arr_pol3000[ 4, 4 ] += Round( human->cena_1 * koef, 2 )
                Else
                  If fl_pol3000_DVN2
                    arr_pol3000[ 5, 2 ] += fl_pol1[ i ]
                    arr_pol3000[ 5, 4 ] += Round( human->cena_1 * koef, 2 )
                  Endif
                Endif
              Endif
            Elseif fl_pol1[ i ] < 0
              If i == 13 .and. schet_->BUKVA == 'K'
                //
              Else
                arr_pol1[ i, 2 ] += kol_stom
                arr_pol1[ i, 4 ] += Round( human->cena_1 * koef, 2 )
                If is_inogoro
                  arr_pol1[ i, 3 ] += kol_stom
                  arr_pol1[ i, 5 ] += Round( human->cena_1 * koef, 2 )
                Endif
                If i == 4
                  If fl_pol3000_PROF   // профосмотры
                    arr_pol3000[ 4, 2 ] += fl_pol1[ i ]
                    arr_pol3000[ 4, 4 ] += Round( human->cena_1 * koef, 2 )
                  Else
                    If fl_pol3000_DVN2
                      arr_pol3000[ 5, 2 ] += fl_pol1[ i ]
                      arr_pol3000[ 5, 4 ] += Round( human->cena_1 * koef, 2 )
                    Endif
                  Endif
                Endif
              Endif
            Endif
          Next
        Endif
        Select HUMAN
        Skip
      Enddo
    Endif
    If fl_exit ; exit ; Endif
    Select SCHET
    Skip
  Enddo
  Delete File ( filetmp14 )
  If !fl_exit .and. tmpf14->( LastRec() ) > 0
    HH := 80
    arr_title := { ;
      '──────────────────────┬──────────────────────┬──────────┬───────────────────────────', ;
      '  № в счёте, ФИО,     │ отч.период, № счёта, │Суммы слу-│                           ', ;
      '  ст-ть случая        │ дата счёта           │чая,снятия│ РАК, № и дата акта        ', ;
      '──────────────────────┴──────────────────────┴──────────┴───────────────────────────' }
    sh := Len( arr_title[ 1 ] )
    //
    fp := FCreate( filetmp14 ) ; n_list := 1 ; tek_stroke := 0
    add_string( '' )
    add_string( Center( 'Список случаев, не вошедших в форму 14', sh ) )
    Select RAKSH
    Set Index To
    Select HUMAN
    Set Index To
    Select TMPF14
    Set Relation To KOD_RAKSH into RAKSH, To schet into SCHET, To kod_h into HUMAN
    Index On Str( usl_ok, 1 ) + Str( schet_->nyear, 4 ) + Str( schet_->nmonth, 2 ) + ;
      Str( human_->SCHET_ZAP, 6 ) to ( cur_dir + 'tmpf14' )
    For j := 1 To 5
      find ( Str( j, 1 ) )
      If Found()
        add_string( '' )
        If j == 5
          add_string( Center( '[ стоматология ]', sh ) )
        Else
          add_string( Center( '[' + inieditspr( A__MENUVERT, getv006(), j ) + ']', sh ) )
        Endif
        AEval( arr_title, {| x| add_string( x ) } )
        Do While tmpf14->usl_ok == j .and. !Eof()
          s1 := lstr( human_->SCHET_ZAP ) + '. ' + AllTrim( human->fio )
          If tmpf14->kol_akt > 1
            s1 += ' (' + lstr( tmpf14->kol_akt ) + ' актов)'
          Endif
          s2 := Right( Str( schet_->nyear, 4 ), 2 ) + '/' + StrZero( schet_->nmonth, 2 ) + ' ' + ;
            AllTrim( schet_->nschet ) + ' от ' + date_8( schet_->dschet )
          s3 := AllTrim( rak->nakt ) + ' от ' + date_8( rak->dakt )
          arr1 := Array( 5 )
          arr2 := Array( 5 )
          arr3 := Array( 5 )
          k1 := perenos( arr1, s1, 22 )
          k2 := perenos( arr2, s2, 22 )
          k3 := perenos( arr3, s3, 27 )
          ins_array( arr3, 1, AllTrim( mo_xml->fname ) )
          ++k3
          k := Max( k1, k2, k3, 3 )
          If verify_ff( HH - k, .t., sh )
            AEval( arr_title, {| x| add_string( x ) } )
          Endif
          v := raksh->SANK_MEK + raksh->SANK_MEE + raksh->SANK_EKMP
          If Round( human->cena_1, 2 ) == Round( v, 2 )
            s := '='
          Elseif Empty( human->cena_1 )
            s := '>'
          Else
            s := '<'
          Endif
          add_string( PadR( arr1[ 1 ], 23 ) + PadR( arr2[ 1 ], 22 ) + Str( human->cena_1, 11, 2 ) + ' ' + arr3[ 1 ] )
          add_string( PadR( arr1[ 2 ], 23 ) + PadR( arr2[ 2 ], 22 ) + Str( v, 11, 2 ) + ' ' + arr3[ 2 ] )
          add_string( PadR( arr1[ 3 ], 23 ) + PadR( arr2[ 3 ], 22 ) + PadL( s, 11 ) + ' ' + arr3[ 3 ] )
          For i := 4 To k
            add_string( PadR( arr1[ i ], 23 ) + PadR( arr2[ i ], 23 ) + Space( 11 ) + ' ' + arr3[ i ] )
          Next
          add_string( Replicate( '─', sh ) )
          Select TMPF14
          Skip
        Enddo
      Endif
    Next
    FClose( fp )
  Endif
  Close databases
  If fl_exit
    RestScreen( buf )
    Return func_error( 4, 'Процесс прерван!' )
  Endif
  //
  arr_razdel := { ;
    { '2. стационар', 1, 14 }, ;
    { '3. амбулаторная медицинская помощь', 15, 32 }, ;
    { '4. стоматологическая помощь', 33, 45 }, ;
    { '5. дневные стационары', 46, 68 }, ;
    { '6. скорая медицинская помощь', 69, 81 };
    }
  //
  r_use( dir_server + 'organiz', , 'ORG' )
  ar := {}
  AAdd( ar, { 12, 77, mm_month[ arr_m[ 3 ] ] } )
  AAdd( ar, { 12, 94, Right( lstr( arr_m[ 1 ] ), 2 ) } )
  AAdd( ar, { 35, 48, glob_mo[ _MO_FULL_NAME ] } )
  AAdd( ar, { 37, 19, glob_mo[ _MO_ADRES ] } )
  AAdd( ar, { 42, 19, org->okpo } )
  AAdd( arr_excel, { 'Лист 1', AClone( ar ) } )
  //
  Use ( cur_dir + 'tmp' ) index ( cur_dir + 'tmp' ) new
  For i := 1 To Len( arr_razdel )
    ar := {}
    i_stroke := iif( eq_any( i, 1, 4 ), 7, 6 )
    For j := arr_razdel[ i, 2 ] To arr_razdel[ i, 3 ]
      ++i_stroke
      find ( Str( j, 2 ) )
      If Found()
        Do Case
        Case i == 1
          dm := 9
        Case i == 2
          dm := 9
        Case i == 3
          dm := 7
        Case i == 4
          dm := 8
        Case i == 5
          dm := 5
        Endcase
        i_column := iif( i == 5, 4, 3 )
        For k := 4 To dm
          ++i_column
          d := 0
          Do Case
          Case i == 1
            d := iif( k < 7, 0, 2 )
          Case i == 2
            d := iif( k < 7, 0, 2 )
          Case i == 3
            d := iif( k < 6, 0, 2 )
          Case i == 4
            d := iif( Between( j, 60, 64 ) .or. j > 66, 2, 0 )
          Case i == 5
            d := iif( j < 77, 0, 2 )
          Endcase
          pole := 'tmp->sum' + lstr( k )
          If !Empty( &pole )
            AAdd( ar, { i_stroke, i_column, lstr( &pole, 15, d ) } )
          Endif
        Next
      Endif
    Next
    For k := 1 To Len( ar )
      If '.' $ ar[ k, 3 ]
        ar[ k, 3 ] := CharRepl( '.', ar[ k, 3 ], ',' )
      Endif
    Next
    AAdd( arr_excel, { 'Раздел ' + Left( arr_razdel[ i, 1 ], 1 ), AClone( ar ) } )
  Next
  Close databases
  RestScreen( buf )
  Delete File ( cFileProtokol )
  /*k := 0
  for i := 1 to len(arr_prof)
    fl_error := .t.
    strfile(padr(arr_prof[i, 1], 10) + str(arr_prof[i, 2], 10) + ;
            hb_eol(), cFileProtokol, .t.)
    k += arr_prof[i, 2]
  next
  strfile(padr('Профприёмы', 10) + str(k, 10) + hb_eol(), cFileProtokol, .t.)*/
  //
  StrFile( hb_eol() + ;
    PadC( 'Дополнительные данные для заполнения формы 62', 80 ) + ;
    hb_eol(), cFileProtokol, .t. )
  If kol_stom_pos > 0
    fl_error := .t.
    Use ( cur_dir + 'TMP_STOM' ) new
    StrFile( hb_eol() + ;
      'Отчёт о количестве и стоимости обращений и посещений при оказании стоматологической помощи' + ;
      hb_eol() + ;
      '___________________________________________________________________________________________________________________________' + hb_eol() + ;
      '___________________________|______всего____________|_________дети__________|____старше трудоспос.__|____иногородние________' + hb_eol() + ;
      '                           |случа|посе-|  сумма    |случа|посе-|  сумма    |случа|посе-|  сумма    |случа|посе-|  сумма    ' + hb_eol() + ;
      '___________________________|ев___|щений|___________|ев___|щений|___________|ев___|щений|___________|ев___|щений|___________' + hb_eol(), cFileProtokol, .t. )
    For i := 1 To 10
      Goto ( i )
      If i == 9 .and. Empty( tmp_stom->k2 )
        Loop
      Endif
      StrFile( tmp_stom->name + Str( tmp_stom->k2, 6 ) + Str( tmp_stom->k3, 6 ) + Str( tmp_stom->k4, 12, 2 ) + ;
        Str( tmp_stom->k5, 6 ) + Str( tmp_stom->k6, 6 ) + Str( tmp_stom->k7, 12, 2 ) + ;
        Str( tmp_stom->k8, 6 ) + Str( tmp_stom->k9, 6 ) + Str( tmp_stom->k10, 12, 2 ) + ;
        Str( tmp_stom->k11, 6 ) + Str( tmp_stom->k12, 6 ) + Str( tmp_stom->k13, 12, 2 ) + hb_eol(), cFileProtokol, .t. )
    Next
    // 21 'Посещения при оказании помощи в неотложной форме, всего'
    // 24 'из строки 21 - посещения по специальности 'стоматология''
    Goto 7
    arr_pol3000[ 19, 2 ] := tmp_stom->k3 // кол-во
    arr_pol3000[ 19, 3 ] := tmp_stom->k12 // ко-во иногородних
    arr_pol3000[ 19, 4 ] := tmp_stom->k4 // сумма
    arr_pol3000[ 19, 5 ] := tmp_stom->k13 // сумма иногородих
    Use
  Endif
  fl := .f.
  For i := 1 To Len( arr_pril5 )
    If !Empty( arr_pril5[ i, 2 ] + arr_pril5[ i, 3 ] )
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadL( 'Приложение 5 к форме 62', 80 ) + hb_eol() + ;
      '─────────────────────────────────────────┬────────────┬────────────┬────────────' + hb_eol() + ;
      '                                         │   всего    │городские ж.│сельские жит' + hb_eol() + ;
      '─────────────────────────────────────────┴────────────┴────────────┴────────────' + hb_eol(), cFileProtokol, .t. )
    For i := 1 to ( Len( arr_pril5 ) -1 )
      If !Empty( arr_pril5[ i, 2 ] + arr_pril5[ i, 3 ] )
        StrFile( PadR( arr_pril5[ i, 1 ], 39 ) + Str( i, 2 ) + ;
          PadL( AllTrim( put_val_0( arr_pril5[ i, 2 ] + arr_pril5[ i, 3 ], 13, 2 ) ), 13 ) + ;
          PadL( AllTrim( put_val_0( arr_pril5[ i, 2 ], 13, 2 ) ), 13 ) + ;
          PadL( AllTrim( put_val_0( arr_pril5[ i, 3 ], 13, 2 ) ), 13 ) + ;
          hb_eol(), cFileProtokol, .t. )
        If i == 10
          StrFile( PadR( arr_pril5[ 32, 1 ], 39 ) + Str( 10, 2 ) + ;
            PadL( AllTrim( put_val_0( arr_pril5[ 32, 2 ] + arr_pril5[ 32, 3 ], 13, 2 ) ), 13 ) + ;
            PadL( AllTrim( put_val_0( arr_pril5[ 32, 2 ], 13, 2 ) ), 13 ) + ;
            PadL( AllTrim( put_val_0( arr_pril5[ 32, 3 ], 13, 2 ) ), 13 ) + ;
            hb_eol(), cFileProtokol, .t. )
        Endif
      Endif
    Next
  Endif
  If !Empty( arr_dn_stac )
    fl_error := .t.
    ASort( arr_dn_stac,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    AAdd( arr_dn_stac, { '', 0, 0, 0, 0 } ) ; j := Len( arr_dn_stac )
    StrFile( hb_eol() + ;
      PadC( 'Дневной стационар по профилям', 80 ) + hb_eol() + ;
      '──────────────────────────────┬─────────────────────┬──────┬──────────────────────' + hb_eol() + ;
      '                              │        Всего        │ сред.│  число пациенто-дней ' + hb_eol() + ;
      '            Профиль           ├───────┬─────────────│ длит.├───────┬──────┬───────' + hb_eol() + ;
      '                              │случаев│    сумма    │1случ.│ всего │взрос.│ дети  ' + hb_eol() + ;
      '──────────────────────────────┴───────┴─────────────┴──────┴───────┴──────┴───────' + hb_eol(), cFileProtokol, .t. )
    For i := 1 To Len( arr_dn_stac ) -1
      s := PadR( lstr( arr_dn_stac[ i, 1 ] ) + ' ' + inieditspr( A__MENUVERT, getv002(), arr_dn_stac[ i, 1 ] ), 30 ) + ;
        put_val( arr_dn_stac[ i, 2 ], 8 ) + put_kope( arr_dn_stac[ i, 3 ], 14 )
      k := 0
      If arr_dn_stac[ i, 2 ] > 0
        k := ( arr_dn_stac[ i, 4 ] + arr_dn_stac[ i, 5 ] ) / arr_dn_stac[ i, 2 ]
      Endif
      s += Str( k, 6, 1 ) + put_val( arr_dn_stac[ i, 4 ] + arr_dn_stac[ i, 5 ], 9 ) + ;
        put_val( arr_dn_stac[ i, 4 ], 7 ) + put_val( arr_dn_stac[ i, 5 ], 7 )
      StrFile( s + hb_eol(), cFileProtokol, .t. )
      arr_dn_stac[ j, 2 ] += arr_dn_stac[ i, 2 ]
      arr_dn_stac[ j, 3 ] += arr_dn_stac[ i, 3 ]
      arr_dn_stac[ j, 4 ] += arr_dn_stac[ i, 4 ]
      arr_dn_stac[ j, 5 ] += arr_dn_stac[ i, 5 ]
    Next
    StrFile( Replicate( '─', 83 ) + hb_eol(), cFileProtokol, .t. )
    s := PadR( 'Итого:', 30 ) + ;
      put_val( arr_dn_stac[ j, 2 ], 8 ) + put_kope( arr_dn_stac[ j, 3 ], 14 )
    k := 0
    If arr_dn_stac[ j, 2 ] > 0
      k := ( arr_dn_stac[ j, 4 ] + arr_dn_stac[ j, 5 ] ) / arr_dn_stac[ j, 2 ]
    Endif
    s += Str( k, 6, 1 ) + put_val( arr_dn_stac[ j, 4 ] + arr_dn_stac[ j, 5 ], 9 ) + ;
      put_val( arr_dn_stac[ j, 4 ], 7 ) + put_val( arr_dn_stac[ j, 5 ], 7 )
    StrFile( s + hb_eol(), cFileProtokol, .t. )
    StrFile( Replicate( '─', 83 ) + hb_eol(), cFileProtokol, .t. )
    s := PadR( 'в т.ч.в дн.стационарах на дому', 30 ) + ;
      put_val( arrDdn_stac[ 1 ], 8 ) + put_kope( arrDdn_stac[ 2 ], 14 )
    k := 0
    If arrDdn_stac[ 1 ] > 0
      k := ( arrDdn_stac[ 3 ] + arrDdn_stac[ 4 ] ) / arrDdn_stac[ 1 ]
    Endif
    s += Str( k, 6, 1 ) + put_val( arrDdn_stac[ 3 ] + arrDdn_stac[ 4 ], 9 ) + ;
      put_val( arrDdn_stac[ 3 ], 7 ) + put_val( arrDdn_stac[ 4 ], 7 )
    StrFile( s + hb_eol(), cFileProtokol, .t. )
  Endif
  If !Empty( arr_profil )
    fl_error := .t.
    ASort( arr_profil,,, {| x, y| x[ 1 ] < y[ 1 ] } )
    StrFile( hb_eol() + ;
      PadC( 'Стационар по профилям', 80 ) + hb_eol() + ;
      '──────────────────────────────┬────────────────────────┬────────────────────────' + hb_eol() + ;
      '                              │        Всего           │   в т.ч. иногородние   ' + hb_eol() + ;
      '            Профиль           ├─────────┬──────────────┼─────────┬──────────────' + hb_eol() + ;
      '                              │пациентов│     сумма    │пациентов│     сумма    ' + hb_eol() + ;
      '──────────────────────────────┴─────────┴──────────────┴─────────┴──────────────' + hb_eol(), cFileProtokol, .t. )
    For i := 1 To Len( arr_profil )
      StrFile( PadR( lstr( arr_profil[ i, 1 ] ) + ' ' + inieditspr( A__MENUVERT, getv002(), arr_profil[ i, 1 ] ), 30 ) + ;
        put_val( arr_profil[ i, 2 ], 10 ) + put_kope( arr_profil[ i, 3 ], 15 ) + ;
        put_val( arr_profil[ i, 4 ], 10 ) + put_kope( arr_profil[ i, 5 ], 15 ) + ;
        hb_eol(), cFileProtokol, .t. )
    Next
  Endif
  fl := .f.
  For i := 15 To 32
    If arr_pol[ i ] > 0
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadC( 'Амбулаторно-поликлиническая помощь', 80 ) + hb_eol() + ;
      '──────────────────────────────────────────────────┬─────────────────────────────' + hb_eol() + ;
      '                                                  │стоимость по счетам "A" и "K"' + hb_eol() + ;
      '──────────────────────────────────────────────────┴─────────────────────────────' + hb_eol() + ;
      'Посещения с профилактической целью, всего          15' + put_kope( arr_pol[ 15 ], 20 ) + hb_eol() + ;
      '  из них: врачей общей практики (семейных врачей)  16' + put_kope( arr_pol[ 16 ], 20 ) + hb_eol() + ;
      '          центров здоровья                         17' + put_kope( arr_pol[ 17 ], 20 ) + hb_eol() + ;
      '  из строки 15: детьми (0-17 лет включительно)     18' + put_kope( arr_pol[ 18 ], 20 ) + hb_eol() + ;
      '    из них центров здоровья детьми (0-17 лет)      19' + put_kope( arr_pol[ 19 ], 20 ) + hb_eol() + ;
      '           лицами старше трудоспособного возраста  20' + put_kope( arr_pol[ 20 ], 20 ) + hb_eol() + ;
      ' лицами, застрахованными за пределами субъекта РФ  21' + put_kope( arr_pol[ 21 ], 20 ) + hb_eol() + ;
      'Посещения при оказании мед.помощи в неотл.форме    22' + put_kope( arr_pol[ 22 ], 20 ) + hb_eol() + ;
      '  из них: врачей общей практики (семейных врачей)  23' + put_kope( arr_pol[ 23 ], 20 ) + hb_eol() + ;
      '  из строки 22: детьми (0-17 лет включительно)     24' + put_kope( arr_pol[ 24 ], 20 ) + hb_eol() + ;
      '           лицами старше трудоспособного возраста  25' + put_kope( arr_pol[ 25 ], 20 ) + hb_eol() + ;
      ' лицами, застрахованными за пределами субъекта РФ  26' + put_kope( arr_pol[ 26 ], 20 ) + hb_eol() + ;
      'Обращения по поводу заболевания, всего             27' + put_kope( arr_pol[ 27 ], 20 ) + hb_eol() + ;
      ' из них к врачам общей практики (семейным врачам)  28' + put_kope( arr_pol[ 28 ], 20 ) + hb_eol() + ;
      '  из строки 27: детей (0-17 лет включительно)      29' + put_kope( arr_pol[ 29 ], 20 ) + hb_eol() + ;
      '     лиц старше трудоспособного возраста           30' + put_kope( arr_pol[ 30 ], 20 ) + hb_eol() + ;
      '     лиц, при прохождении реабилитации             31' + put_kope( arr_pol[ 31 ], 20 ) + hb_eol() + ;
      '     лиц, застрахованных за пределами субъекта РФ  32' + put_kope( arr_pol[ 32 ], 20 ) + hb_eol(), cFileProtokol, .t. )
  Endif

  fl := .f.
  For i := 1 To 15
    If arr_pol1[ i, 2 ] > 0
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadC( '3000 Фактические объёмы посещений и их финансирование (Старый вариант)', 80 ) + hb_eol() + ;
      '────────────────────────────────────┬───────────────┬───────────────────────────' + hb_eol() + ;
      '                                    │   посещений   │          сумма            ' + hb_eol() + ;
      ' Наименование показателя            ├───────┬───────┼─────────────┬─────────────' + hb_eol() + ;
      '                                    │ всего │иногор.│    всего    │в т.ч. иногор' + hb_eol() + ;
      '────────────────────────────────────┴───────┴───────┴─────────────┴─────────────' + hb_eol(), cFileProtokol, .t. )
    add_val_2_array( arr_pol1, 2, 3, 2, 5 )
    add_val_2_array( arr_pol1, 2, 6, 2, 5 )
    add_val_2_array( arr_pol1, 2, 9, 2, 5 )
    //
    add_val_2_array( arr_pol1, 1, 2, 2, 5 )
    add_val_2_array( arr_pol1, 1, 11, 2, 5 )
    add_val_2_array( arr_pol1, 1, 13, 2, 5 )
    For i := 1 To Len( arr_pol1 )
      k := perenos( t_arr, arr_pol1[ i, 1 ], 33 )
      StrFile( PadR( RTrim( t_arr[ 1 ] ), 34, '.' ) + StrZero( i, 2 ) + ;
        put_val( arr_pol1[ i, 2 ], 8 ) + put_val( arr_pol1[ i, 3 ], 8 ) + ;
        put_kope( arr_pol1[ i, 4 ], 14 ) + put_kope( arr_pol1[ i, 5 ], 14 ) + hb_eol(), cFileProtokol, .t. )
      For j := 2 To k
        StrFile( PadL( AllTrim( t_arr[ j ] ), 34 ) + hb_eol(), cFileProtokol, .t. )
      Next
    Next
  Endif
  If !Empty( sum_k )
    fl_error := .t.
    StrFile( hb_eol() + 'Сумма по счетам, имеющим параметр К = ' + lstr( sum_k, 12, 2 ) + ;
      ' (в т.ч.дети ' + lstr( sum_kd, 12, 2 ) + ', трудоспос.' + lstr( sum_kt, 12, 2 ) + ;
      ', иногородние ' + lstr( sum_ki, 12, 2 ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif
  If !Empty( sum_d )
    fl_error := .t.
    StrFile( hb_eol() + 'По счетам, имеющим параметр G,J,D,O,R,F,V,I,U = ' + lstr( kol_d ) + ' приёмов на сумму ' + lstr( sum_d, 12, 2 ) + hb_eol(), cFileProtokol, .t. )
  Endif
  If arr_eko[ 1, 1 ] > 0
    fl_error := .t.
    StrFile( hb_eol() + ;
      'Проведено выбывшими пациентами пациенто-дней при ЭКО  ' + lstr( arr_eko[ 1, 1 ] ) + ' (в т.ч.ВМП ' + lstr( arr_eko[ 1, 2 ] ) + ')' + hb_eol() + ;
      '  из них лиц, застрахованных за пределами субъекта РФ ' + lstr( arr_eko[ 2, 1 ] ) + ' (в т.ч.ВМП ' + lstr( arr_eko[ 2, 2 ] ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif


  fl := .f.
  For i := 1 To 29
    If arr_pol3000[ i, 2 ] > 0
      fl := .t. ; Exit
    Endif
  Next
  If fl
    fl_error := .t.
    StrFile( hb_eol() + ;
      PadC( '3000 Фактические объёмы посещений и их финансирование', 80 ) + hb_eol() + ;
      '────────────────────────────────────┬───────────────┬───────────────────────────' + hb_eol() + ;
      '                                    │   посещений   │          сумма            ' + hb_eol() + ;
      ' Наименование показателя            ├───────┬───────┼─────────────┬─────────────' + hb_eol() + ;
      '                                    │ всего │иногор.│    всего    │в т.ч. иногор' + hb_eol() + ;
      '────────────────────────────────────┴───────┴───────┴─────────────┴─────────────' + hb_eol(), cFileProtokol, .t. )
    //
    // '02 Посещения с профилактическими и иными целями (03+06)'
    // add_val_2_array(arr_pol3000, 2, 3, 2, 5)
    // add_val_2_array(arr_pol3000, 2, 6, 2, 5)
    // 01 Посещений - всего (02+21+25)
    // add_val_2_array(arr_pol3000, 1, 2, 2, 5)
    // add_val_2_array(arr_pol3000, 1, 17, 2, 5)
    // add_val_2_array(arr_pol3000, 1, 20, 2, 5)
    //
    // Переприсвоение
    For xx := 2 To 5
      arr_pol3000[ 1, xx ] := arr_pol1[ 1, xx ]
    Next
    //
    For xx := 2 To 5
      arr_pol3000[ 2, xx ] := arr_pol1[ 2, xx ]
    Next
    // 12 'из строки 06 разовые посещения в связи с заболеваниями'
    For xx := 2 To 5
      arr_pol3000[ 9, xx ] := arr_pol1[ 6, xx ]
    Next
    // 13 'из строки 12 - посещения на дому'
    For xx := 2 To 5
      arr_pol3000[ 10, xx ] := arr_pol1[ 7, xx ]
    Next
    // 'Посещения при оказании помощи в неотложной форме, всего'
    For xx := 2 To 5
      arr_pol3000[ 17, xx ] := arr_pol1[ 11, xx ]
    Next
    // 'из строки 21 - посещения на дому'
    For xx := 2 To 5
      arr_pol3000[ 18, xx ] := arr_pol1[ 12, xx ]
    Next
    // 'Посещения, включенные в обращение в связи с заболеваниями'
    For xx := 2 To 5
      arr_pol3000[ 20, xx ] := arr_pol1[ 13, xx ]
    Next
    // '06 посещения с иными целями, всего (07+08+12+14+15+16+19+20)'
    // add_val_2_array(arr_pol3000, 6, 7, 2, 5)   // 7
    // add_val_2_array(arr_pol3000, 6, 8, 2, 5)   // 8
    // add_val_2_array(arr_pol3000, 6, 9, 2, 5)   // 12
    // add_val_2_array(arr_pol3000, 6, 11, 2, 5)  // 14
    // add_val_2_array(arr_pol3000, 6, 12, 2, 5)  // 15
    // add_val_2_array(arr_pol3000, 6, 13, 2, 5)  // 16
    // //add_val_2_array(arr_pol3000, 6,, 2, 5)  // 19 нет в системе ОМС
    // add_val_2_array(arr_pol3000, 6, 16, 2, 5)  // 20

    // '03 посещения с профилактическими целями, всего (04+05)'
    add_val_2_array( arr_pol3000, 3, 4, 2, 5 )
    add_val_2_array( arr_pol3000, 3, 5, 2, 5 )
    //
    For xx := 2 To 5
      arr_pol3000[ 6, xx ] := arr_pol3000[ 2, xx ] - arr_pol3000[ 3, xx ]
    Next
    //
    For i := 1 To Len( arr_pol3000 )
      k := perenos( t_arr, arr_pol3000[ i, 1 ], 33 )
      StrFile( PadR( RTrim( t_arr[ 1 ] ), 34, '.' ) + StrZero( arr_pol3000[ i, 6 ], 2 ) + ; // strzero(arr_pol3000[i, 1], 2) + ;
      put_val( arr_pol3000[ i, 2 ], 8 ) + put_val( arr_pol3000[ i, 3 ], 8 ) + ;
        put_kope( arr_pol3000[ i, 4 ], 14 ) + put_kope( arr_pol3000[ i, 5 ], 14 ) + hb_eol(), cFileProtokol, .t. )
      For j := 2 To k
        StrFile( PadL( AllTrim( t_arr[ j ] ), 34 ) + hb_eol(), cFileProtokol, .t. )
      Next
    Next
  Endif
  If !Empty( sum_k )
    fl_error := .t.
    StrFile( hb_eol() + 'Сумма по счетам, имеющим параметр К = ' + lstr( sum_k, 12, 2 ) + ;
      ' (в т.ч.дети ' + lstr( sum_kd, 12, 2 ) + ', трудоспос.' + lstr( sum_kt, 12, 2 ) + ;
      ', иногородние ' + lstr( sum_ki, 12, 2 ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif
  If !Empty( sum_d )
    fl_error := .t.
    StrFile( hb_eol() + 'По счетам, имеющим параметр G,J,D,O,R,F,V,I,U = ' + lstr( kol_d ) + ' приёмов на сумму ' + lstr( sum_d, 12, 2 ) + hb_eol(), cFileProtokol, .t. )
  Endif
  If arr_eko[ 1, 1 ] > 0
    fl_error := .t.
    StrFile( hb_eol() + ;
      'Проведено выбывшими пациентами пациенто-дней при ЭКО  ' + lstr( arr_eko[ 1, 1 ] ) + ' (в т.ч.ВМП ' + lstr( arr_eko[ 1, 2 ] ) + ')' + hb_eol() + ;
      '  из них лиц, застрахованных за пределами субъекта РФ ' + lstr( arr_eko[ 2, 1 ] ) + ' (в т.ч.ВМП ' + lstr( arr_eko[ 2, 2 ] ) + ')' + hb_eol(), cFileProtokol, .t. )
  Endif
  If arr_skor[ 69, 1 ] > 0 .or. arr_skor[ 69, 2 ] > 0
    fl_error := .t.
    StrFile( hb_eol() + PadC( 'Скорая помощь', 80 ) + hb_eol() + ;
      '──────────────────────────────────────────────────────┬────────────┬────────────' + hb_eol() + ;
      '                                                      │в неотлож.ф.│в экстрен.ф.' + hb_eol() + ;
      '──────────────────────────────────────────────────────┴────────────┴────────────' + hb_eol() + ;
      'Число выполненных вызовов скорой медицинской помощи, 69' + put_kope( arr_skor[ 69, 1 ], 13 ) + put_kope( arr_skor[ 69, 2 ], 13 ) + hb_eol() + ;
      '  из них: к детям (0-17 лет включительно)          , 70' + put_kope( arr_skor[ 70, 1 ], 13 ) + put_kope( arr_skor[ 70, 2 ], 13 ) + hb_eol() + ;
      '          к лицам старше трудоспособного возраста  , 71' + put_kope( arr_skor[ 71, 1 ], 13 ) + put_kope( arr_skor[ 71, 2 ], 13 ) + hb_eol() + ;
      '   к лицам, застрахованным за пределами субъекта РФ, 72' + put_kope( arr_skor[ 72, 1 ], 13 ) + put_kope( arr_skor[ 72, 2 ], 13 ) + hb_eol() + ;
      'Число лиц, обслуженных бригадами скорой мед.помощи , 73' + put_kope( arr_skor[ 73, 1 ], 13 ) + put_kope( arr_skor[ 73, 2 ], 13 ) + hb_eol() + ;
      '  из них: детей (0-17 лет включительно)            , 74' + put_kope( arr_skor[ 74, 1 ], 13 ) + put_kope( arr_skor[ 74, 2 ], 13 ) + hb_eol() + ;
      '          лиц старше трудоспособного возраста      , 75' + put_kope( arr_skor[ 75, 1 ], 13 ) + put_kope( arr_skor[ 75, 2 ], 13 ) + hb_eol() + ;
      '       лиц, застрахованных за пределами субъекта РФ, 76' + put_kope( arr_skor[ 76, 1 ], 13 ) + put_kope( arr_skor[ 76, 2 ], 13 ) + hb_eol() + ;
      'Стоимость оказанной скорой медицинской помощи,всего, 77' + put_kope( arr_skor[ 77, 1 ], 13 ) + put_kope( arr_skor[ 77, 2 ], 13 ) + hb_eol() + ;
      '  из них: детям (0-17 лет включительно)            , 78' + put_kope( arr_skor[ 78, 1 ], 13 ) + put_kope( arr_skor[ 78, 2 ], 13 ) + hb_eol() + ;
      '          лицам старше трудоспособного возраста    , 79' + put_kope( arr_skor[ 79, 1 ], 13 ) + put_kope( arr_skor[ 79, 2 ], 13 ) + hb_eol() + ;
      '     лицам, застрахованным за пределами субъекта РФ, 80' + put_kope( arr_skor[ 80, 1 ], 13 ) + put_kope( arr_skor[ 80, 2 ], 13 ) + hb_eol() + ;
      'Стоимость иных видов медицинской помощи и услуг    , 81' + put_kope( arr_skor[ 81, 1 ], 13 ) + put_kope( arr_skor[ 81, 2 ], 13 ) + hb_eol(), cFileProtokol, .t. )
  Endif
  If File( filetmp14 )
    viewtext( filetmp14,,,, .t.,,, 5 )
  Endif
  If fl_error
    viewtext( devide_into_pages( cFileProtokol, 60, 80 ),,,, .t.,,, 3 )
  Endif
  fill_in_excel_book( dir_exe() + 'mo_14med' + sxls(), ;
    cur_dir() + '__14med' + sxls(), ;
    arr_excel, ;
    'присланный из ТФОМС' )
  Return Nil