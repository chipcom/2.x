// mo_omsid.prg - информация по диспансеризации в ОМС
#include "inkey.ch"
#include "fastreph.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

// #define MONTH_UPLOAD 8 //МЕСЯЦ для выгрузки R11

Static lcount_uch  := 1
Static mas1pmt := { "~все оказанные случаи", ;
    "случаи в выставленных ~счетах", ;
    "случаи в за~регистрированных счетах" }

// 12.04.24 Диспансеризация, профилактика и медосмотры
Function dispanserizacia( k )

  Static si1 := 1, si2 := 1, sj := 1, sj1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~Дети-сироты", ;
      "~Взрослое население", ;
      "~Несовершеннолетние", ;
      "~Сводная информация", ;
      "~Репродуктивное здоровье" }
    mas_msg := { "Информация по диспансеризации детей-сирот", ;
      "Информация по диспансеризации и профилактике взрослого населения", ;
      "Информация по медицинским осмотрам несовершеннолетних", ;
      "Сводные документы по всем видам диспансеризации и профилактики", ;
      "Проведение диспансеризации репродуктивного здоровья" }
    mas_fun := { "dispanserizacia(11)", ;
      "dispanserizacia(12)", ;
      "dispanserizacia(13)", ;
      "dispanserizacia(14)", ;
      "dispanserizacia(15)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    inf_dds()
  Case k == 12
    inf_dvn()
  Case k == 13
    inf_dnl()
  Case k == 14
    inf_disp()
  Case k == 15
    inf_drz()
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Endif
  Endif

  Return Nil

// 23.09.20 Информация по диспансеризации детей-сирот
Function inf_dds( k )

  Static si1 := 1, si2 := 1, sj := 1, sj1 := 1, sj2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~Карта диспансеризации", ;
      "~Список пациентов", ;
      "Своды для Обл~здрава", ;
      "Форма № 030-Д/с/~о-13", ;
      "XML-файл для ~портала МЗРФ" }
    mas_msg := { "Распечатка карты диспансеризации (учётная форма № 030-Д/с/у-13)", ;
      "Распечатка списка пациентов, которым проведена диспансеризация детей-сирот", ;
      "Распечатка различных сводов для Облздрава Волгоградской области", ;
      "Сведения о диспансеризации несовершеннолетних (отчётная форма № 030-Д/с/о-13)", ;
      "Создание XML-файла для загрузки на портал Минздрава РФ" }
    mas_fun := { "inf_DDS(11)", ;
      "inf_DDS(12)", ;
      "inf_DDS(13)", ;
      "inf_DDS(14)", ;
      "inf_DDS(15)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case Between( k, 11, 19 )
    If ( j := popup_prompt( T_ROW, T_COL -5, sj, ;
        { "Находящиеся в стационаре", "Находящиеся под опекой" } ) ) == 0
      Return Nil
    Endif
    sj := j
    Private p_tip_lu := iif( j == 1, TIP_LU_DDS, TIP_LU_DDSOP )
    Do Case
    Case k == 11
      inf_dds_karta()
    Case k == 12
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 3, mas1pmt ) ) > 0
        inf_dds_svod( 1,, j1 )
      Endif
    Case k == 13
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
        If ( j := popup_prompt( T_ROW, T_COL -5, sj2, ;
            { "Вывод таблицы со списком детей", ;
            "Вывод в Excel для ВОДКБ", ;
            "Вывод таблицы к письму №14-05/50", ;
            "Вывод таблицы 2510" } ) ) > 0
          sj2 := j
          If j > 2
            inf_dds_svod2( j, j1 )
          Else
            inf_dds_svod( 2, j, j1 )
          Endif
        Endif
      Endif
    Case k == 14
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
        inf_dds_030dso( j1 )
      Endif
    Case k == 15
      If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
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
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmp" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := "Диспансеризация детей-сирот " + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( human->schet > 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " Ф.И.О.", {|| PadR( human->fio, 39 ) }, blk }, ;
        { "Дата рожд.", {|| full_date( human->date_r ) }, blk }, ;
        { "№ ам.карты", {|| human->uch_doc }, blk }, ;
        { "Сроки леч-я", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "Этап", {|| iif( human->ishod == 101, " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - распечатать карту диспансеризации" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_dds_karta( nk, ob, "edit" ) }
      edit_browse( t_arr )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 11.03.19
Function f0_inf_dds( arr_m, is_schet, is_reg, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f.
  If !del_dbf_file( cur_dir() + "tmp" + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, ;
    { "is", "N", 1, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + "tmp_h" ) ;
    For iif( p_tip_lu == TIP_LU_DDS, !Empty( za_smo ), Empty( za_smo ) ) .and. ;
    eq_any( ishod, 101, 102 ) .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := .t.
    If is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      Append Blank
      tmp->kod := human->kod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    Select HUMAN
    Skip
  Enddo
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, "Не найдено л/у по диспансеризации детей-сирот " + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 05.07.13
Function f1_inf_dds_karta( nKey, oBrow, regim )

  Local ret := -1, lkod_h, lkod_k, rec := tmp->( RecNo() ), buf := save_maxrow()

  If regim == "edit" .and. nKey == K_ENTER
    mywait()
    lkod_h := human->kod
    lkod_k := human->kod_k
    Close databases
    oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_karta" )
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 13.09.25
Function f2_inf_dds_karta( Loc_kod, kod_kartotek, lvozrast )

  Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
  Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {| s| __dbAppend(), field->stroke := s }
  local mm_invalid5 := mm_invalid5()

  delfrfiles()
  r_use( dir_server() + "mo_stdds" )
  If Type( "m1stacionar" ) == "N" .and. m1stacionar > 0
    Goto ( m1stacionar )
  Endif
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "mo_pers",, "P2" )
  Goto ( m1vrach )
  r_use( dir_server() + "organiz",, "ORG" )
  adbf := { { "name", "C", 130, 0 }, ;
    { "prikaz", "C", 50, 0 }, ;
    { "forma", "C", 50, 0 }, ;
    { "titul", "C", 100, 0 }, ;
    { "fio", "C", 50, 0 }, ;
    { "k_data", "C", 40, 0 }, ;
    { "vrach", "C", 40, 0 }, ;
    { "glavn", "C", 40, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_SHORT_NAME ]
  frt->fio := mfio
  frt->k_data := date_month( mk_data )
  frt->vrach := fam_i_o( p2->fio )
  frt->glavn := fam_i_o( org->ruk )
  adbf := { { "stroke", "C", 2000, 0 } }
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  If p_tip_lu == TIP_LU_PN // профилактика несовершеннолетних
    frt->prikaz := "от 21.12.2012г. № 1346н"
    frt->forma  := "030-ПО/у-12"
    frt->titul  := "Карта профилактического медицинского осмотра несовершеннолетнего"
    s := st + "1. Фамилия, имя, отчество несовершеннолетнего: " + ub + AllTrim( mfio ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "Пол: " + f3_inf_dds_karta( { { "муж.", "М" }, { "жен.", "Ж" } }, mpol, "/", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "Дата рождения: " + ub + date_month( mdate_r, .t. ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "2. Полис обязательного медицинского страхования: "
    s += "серия " + iif( Empty( mspolis ), Replicate( "_", 15 ), ub + AllTrim( mspolis ) + ue )
    s += " № " + ub + AllTrim( mnpolis ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "Страховая медицинская организация: " + ub + AllTrim( mcompany ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "3. Страховой номер индивидуального лицевого счета: "
//    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + "."
    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "4. Адрес места жительства: "
    If emptyall( kart_->okatog, kart->adres )
      s += Replicate( "_", 50 ) + " " + Replicate( "_", sh ) + "."
    Else
      s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    s := st + "5. Категория: " + f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, "; ", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "6. Полное наименование медицинской организации, в которой " + ;
      "несовершеннолетний получает первичную медико-санитарную помощь: "
    s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "7. Юридический адрес медицинской организации, в которой " + ;
      "несовершеннолетний получает первичную медико-санитарную помощь: "
    s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + "."
    frd->( Eval( blk, s ) )
    madresschool := ""
    If Type( "m1school" ) == "N" .and. m1school > 0
      r_use( dir_server() + "mo_schoo",, "SCH" )
      Goto ( m1school )
      If !Empty( sch->fname )
        mschool := AllTrim( sch->fname )
        madresschool := AllTrim( sch->adres )
      Endif
    Endif
    s := st + "8. Полное наименование образовательного учреждения, в котором " + ;
      "обучается несовершеннолетний: " + ub + mschool + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "9. Юридический адрес образовательного учреждения, в котором " + ;
      "обучается несовершеннолетний: "
    If Empty( madresschool )
      frd->( Eval( blk, s ) )
      s := Replicate( "_", sh ) + "."
    Else
      s += ub + madresschool + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    s := st + "10. Дата начала медицинского осмотра: " + ub + full_date( mn_data ) + ue + "."
    frd->( Eval( blk, s ) )
  Else // диспансеризация детей-сирот
    frt->prikaz := "от 15.02.2013г. № 72н"
    frt->forma  := "030-Д/с/у-13"
    frt->titul  := "Карта диспансеризации несовершеннолетнего"
    s := st + "1. Полное наименование стационарного учреждения: "
    If p_tip_lu == TIP_LU_DDS
      s += ub + AllTrim( mstacionar ) + ue + "."
      frd->( Eval( blk, s ) )
    Else
      frd->( Eval( blk, s ) )
      s := Replicate( "_", sh ) + "."
      frd->( Eval( blk, s ) )
    Endif
    s := st + "1.1. Прежнее наименование (в случае его изменения):"
    frd->( Eval( blk, s ) )
    s := Replicate( "_", sh ) + "."
    frd->( Eval( blk, s ) )
    s := st + "1.2. Ведомственная принадлежность: "
    If p_tip_lu == TIP_LU_DDS
      i := mo_stdds->vedom
      If !Between( i, 0, 3 )
        i := 3
      Endif
    Else
      i := -1
    Endif
    mm_vedom := { { "органы здравоохранения", 0 }, ;
      { "образования", 1 }, ;
      { "социальной защиты", 2 }, ;
      { "другое", 3 } }
    s += f3_inf_dds_karta( mm_vedom, i,, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "1.3. Юридический адрес стационарного учреждения: "
    If p_tip_lu == TIP_LU_DDS .and. !Empty( mo_stdds->adres )
      s += ub + AllTrim( mo_stdds->adres ) + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    If p_tip_lu == TIP_LU_DDSOP .or. Empty( mo_stdds->adres )
      s := Replicate( "_", sh ) + "."
      frd->( Eval( blk, s ) )
    Endif
    s := st + "2. Фамилия, имя, отчество несовершеннолетнего: " + ub + AllTrim( mfio ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "2.1. Пол: "
    s += f3_inf_dds_karta( { { "муж.", "М" }, { "жен.", "Ж" } }, mpol, "/", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "2.2. Дата рождения: " + ub + date_month( mdate_r, .t. ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "2.3. Категория учета ребенка, находящегося в тяжелой жизненной ситуации: "
    s += f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, "; ", ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "2.4. На момент проведения диспансеризации находится "
    mm_gde_nahod1[ 3, 1 ] := "попечительством"
    s += f3_inf_dds_karta( mm_gde_nahod1, m1gde_nahod,, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "3. Полис обязательного медицинского страхования:"
    frd->( Eval( blk, s ) )
    s := st + "серия " + iif( Empty( mspolis ), Replicate( "_", 15 ), ub + AllTrim( mspolis ) + ue )
    s += " № " + ub + AllTrim( mnpolis ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "Страховая медицинская организация: " + ub + AllTrim( mcompany ) + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "Страховой номер индивидуального лицевого счета: "
//    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + "."
    s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "4. Дата поступления в стационарное учреждение: "
    s += iif( p_tip_lu == TIP_LU_DDSOP .or. Empty( mdate_post ), Replicate( "_", 15 ), ub + full_date( mdate_post ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "5. Причина выбытия из стационарного учреждения: "
// НЕ ЗНАЮ ЗАЧЕМ    del_array( mm_prich_vyb(), 1 ) // удалить 1-ый элемент "{"не выбыл", 0}"
    s += f3_inf_dds_karta( mm_prich_vyb(), m1prich_vyb,, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + "5.1. Дата выбытия: " + iif( Empty( mDATE_VYB ), Replicate( "_", 15 ), ub + full_date( mDATE_VYB ) + ue ) + "."
    frd->( Eval( blk, s ) )
    s := st + "6. Отсутствует на момент проведения диспансеризации:"
    frd->( Eval( blk, s ) )
    s := Replicate( "_", 73 ) + " (указать причину)."
    frd->( Eval( blk, s ) )
    s := st + "7. Адрес места жительства: "
    If emptyall( kart_->okatog, kart->adres )
      s += Replicate( "_", 50 ) + " " + Replicate( "_", sh ) + "."
    Else
      s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + "."
    Endif
    frd->( Eval( blk, s ) )
    s := st + "8. Полное наименование медицинской организации, выбранной " + ;
      "несовершеннолетним (его родителем или иным законным представителем) " + ;
      "для получения первичной медико-санитарной помощи: "
    s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "9. Юридический адрес медицинской организации, выбранной " + ;
      "несовершеннолетним (его родителем или иным законным представителем) " + ;
      "для получения первичной медико-санитарной помощи: "
    s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + "."
    frd->( Eval( blk, s ) )
    s := st + "10. Дата начала диспансеризации: " + ub + full_date( mn_data ) + ue + "."
    frd->( Eval( blk, s ) )
  Endif
  s := st + "11. Полное наименование и юридический адрес медицинской организации, " + ;
    "проводившей " + iif( p_tip_lu == TIP_LU_PN, "профилактический медицинский осмотр: ", "диспансеризацию: " ) + ;
    ub + glob_mo[ _MO_FULL_NAME ] + ", " + glob_mo[ _MO_ADRES ] + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "12. Оценка физического развития с учетом возраста на момент " + ;
    iif( p_tip_lu == TIP_LU_PN, "медицинского осмотра:", "диспансеризации:" )
  frd->( Eval( blk, s ) )
  count_ymd( mdate_r, mn_data, @y, @m, @d )
  s := ub + st + lstr( d ) + st + ue + " (число дней) " + ;
    ub + st + lstr( m ) + st + ue + " (месяцев) " + ;
    ub + st + lstr( y ) + st + ue + " лет."
  frd->( Eval( blk, s ) )
  mm_fiz_razv1 := { { "дефицит массы тела", 1 }, { "избыток массы тела", 2 } }
  mm_fiz_razv2 := { { "низкий рост", 1 }, { "высокий рост", 2 } }
  For i := 1 To 2
    s := st + "12." + lstr( i ) + ". Для детей в возрасте " + ;
      { "0 - 4 лет: ", "5 - 17 лет включительно: " }[ i ]
    If i == 1
      fl := ( lvozrast < 5 )
    Else
      fl := ( lvozrast > 4 )
    Endif
    s += "масса (кг) " + iif( !fl, "________", ub + st + lstr( mWEIGHT ) + st + ue ) + "; "
    s += "рост (см) " + iif( !fl, "________", ub + st + lstr( mHEIGHT ) + st + ue ) + "; "
    s += "окружность головы (см) " + iif( !fl .or. mPER_HEAD == 0, "________", ub + st + lstr( mPER_HEAD ) + st + ue ) + "; "
    s += "физическое развитие " + f3_inf_dds_karta( mm_fiz_razv(), iif( fl, m1FIZ_RAZV, -1 ),, ub, ue, .f. )
    s += " (" + f3_inf_dds_karta( mm_fiz_razv1, iif( fl, m1FIZ_RAZV1, -1 ),, ub, ue, .f. )
    s += ", " + f3_inf_dds_karta( mm_fiz_razv2, iif( fl, m1FIZ_RAZV2, -1 ),, ub, ue, .f. )
    s += " - нужное подчеркнуть)."
    frd->( Eval( blk, s ) )
  Next
  fl := ( lvozrast < 5 )
  s := st + "13. Оценка психического развития (состояния):"
  frd->( Eval( blk, s ) )
  s := st + "13.1. Для детей в возрасте 0 - 4 лет:"
  frd->( Eval( blk, s ) )
  s := st + "познавательная функция (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih11 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "моторная функция (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih12 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih13 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "предречевое и речевое развитие (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih14 ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( lvozrast > 4 )
  s := st + "13.2. Для детей в возрасте 5 - 17 лет:"
  frd->( Eval( blk, s ) )
  s := st + "13.2.1. Психомоторная сфера: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.2. Интеллект: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.3. Эмоционально-вегетативная сфера: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  fl := ( mpol == "М" .and. lvozrast > 9 )
  s := st + "14. Оценка полового развития (с 10 лет):"
  frd->( Eval( blk, s ) )
  s := st + "14.1. Половая формула мальчика: Р " + iif( !fl .or. m141p == 0, "________", ub + st + lstr( m141p ) + st + ue )
  s += " Ах " + iif( !fl .or. m141ax == 0, "________", ub + st + lstr( m141ax ) + st + ue )
  s += " Fa " + iif( !fl .or. m141fa == 0, "________", ub + st + lstr( m141fa ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( mpol == "Ж" .and. lvozrast > 9 )
  s := st + "14.2. Половая формула девочки: Р " + iif( !fl .or. m142p == 0, "________", ub + st + lstr( m142p ) + st + ue )
  s += " Ах " + iif( !fl .or. m142ax == 0, "________", ub + st + lstr( m142ax ) + st + ue )
  s += " Ma " + iif( !fl .or. m142ma == 0, "________", ub + st + lstr( m142ma ) + st + ue )
  s += " Me " + iif( !fl .or. m142me == 0, "________", ub + st + lstr( m142me ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "характеристика менструальной функции: menarhe ("
  s += iif( !fl .or. m142me1 == 0, "________", ub + st + lstr( m142me1 ) + st + ue ) + " лет, "
  s += iif( !fl .or. m142me2 == 0, "________", ub + st + lstr( m142me2 ) + st + ue ) + " месяцев); "
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += "menses (характеристика): " + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), " и ", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "15. Состояние здоровья до проведения " + ;
    iif( p_tip_lu == TIP_LU_PN, "настоящего профилактического медицинского осмотра:", "диспансеризации:" )
  frd->( Eval( blk, s ) )
  If lvozrast < 14
    mdef_diagnoz := "Z00.1"
  Else
    mdef_diagnoz := "Z00.3"
  Endif
  s := st + "15.1. Практически здоров " + iif( m1diag_15_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mdef_diagnoz ) + st + ue ) + " (код по МКБ)."
  frd->( Eval( blk, s ) )
  //
  mm_dispans := { { "установлено ранее", 1 }, { "установлено впервые", 2 }, { "не установлено", 0 } }
  mm_danet := { { "да", 1 }, { "нет", 0 } }
  mm_usl := { { "в амбулаторных условиях", 0 }, ;
    { "в условиях дневного стационара", 1 }, ;
    { "в стационарных условиях", 2 } }
  mm_uch := { { "в муниципальных медицинских организациях", 1 }, ;
    { "в государственных медицинских организациях субъекта Российской Федерации ", 0 }, ;
    { "в федеральных медицинских организациях", 2 }, ;
    { "частных медицинских организациях", 3 } }
  mm_uch1 := AClone( mm_uch )
  AAdd( mm_uch1, { "санаторно-курортных организациях", 4 } )
  mm_danet1 := { { "оказана", 1 }, { "не оказана", 0 } }
  For i := 1 To 5
    fl := .f.
    For k := 1 To 14
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 4, 5, 6, 7 )
            mvar := "m1diag_15_" + lstr( i ) + "_3"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 9, 10, 11, 12 )
            mvar := "m1diag_15_" + lstr( i ) + "_8"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case k == 14
            mvar := "m1diag_15_" + lstr( i ) + "_13"
            if &mvar != 1 // если не "да"
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
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := ""
    For k := 1 To 14
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + "15." + lstr( i + 1 ) + ". Диагноз " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (код по МКБ)."
      Case k == 2
        s1 := st + "15." + lstr( i + 1 ) + ".1. Диспансерное наблюдение: " + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 3
        s2 := st + "15." + lstr( i + 1 ) + ".2. Лечение было назначено: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 4
        s2 := Left( s2, Len( s2 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 5
        s2 := Left( s2, Len( s2 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 6
        s3 := st + "15." + lstr( i + 1 ) + ".3. Лечение было выполнено: " + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 7
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 8
        s4 := st + "15." + lstr( i + 1 ) + ".4. Медицинская реабилитация и (или) санаторно-курортное лечение были назначены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 10
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 11
        s5 := st + "15." + lstr( i + 1 ) + ".5. Медицинская реабилитация и (или) санаторно-курортное лечение были выполнены: " + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 13
        s6 := st + "15." + lstr( i + 1 ) + ".6. Высокотехнологичная медицинская помощь была рекомендована: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_danet1, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
  Next
  mm_gruppa := { { "I", 1 }, { "II", 2 }, { "III", 3 }, { "IV", 4 }, { "V", 5 } }
  s := st + "15.9. Группа состояния здоровья: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_PN
    s := st + "15.10. Медицинская группа для занятий физической культурой: "
    s += f3_inf_dds_karta( mm_gr_fiz_do, m1GR_FIZ_DO,, ub, ue )
    frd->( Eval( blk, s ) )
  Endif
  s := st + "16. Состояние здоровья по результатам проведения " + ;
    iif( p_tip_lu == TIP_LU_PN, "настоящего профилактического медицинского осмотра:", "диспансеризации:" )
  frd->( Eval( blk, s ) )
  s := st + "16.1. Практически здоров " + iif( m1diag_16_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mkod_diag ) + st + ue ) + " (код по МКБ)."
  frd->( Eval( blk, s ) )
  For i := 1 To 5
    fl := .f.
    For k := 1 To 16
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 5, 6 )
            mvar := "m1diag_16_" + lstr( i ) + "_4"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 8, 9 )
            mvar := "m1diag_16_" + lstr( i ) + "_7"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 11, 12 )
            mvar := "m1diag_16_" + lstr( i ) + "_10"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 14, 15 )
            mvar := "m1diag_16_" + lstr( i ) + "_13"
            if &mvar != 1 // если не "да"
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
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
    For k := 1 To 16
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + "16." + lstr( i + 1 ) + ". Диагноз " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (код по МКБ)."
      Case k == 2
        s1 := st + "16." + lstr( i + 1 ) + ".1. Диагноз установлен впервые: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 3
        s2 := st + "16." + lstr( i + 1 ) + ".2. Диспансерное наблюдение: " + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 4
        s3 := st + "16." + lstr( i + 1 ) + ".3. Дополнительные консультации и исследования назначены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 5
        s3 := Left( s3, Len( s3 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 6
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 7
        s4 := st + "16." + lstr( i + 1 ) + ".4. Дополнительные консультации и исследования выполнены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 8
        s4 := Left( s4, Len( s4 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 10
        s5 := st + "16." + lstr( i + 1 ) + ".5. Лечение назначено: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 11
        s5 := Left( s5, Len( s5 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 13
        s6 := st + "16." + lstr( i + 1 ) + ".6. Медицинская реабилитация и (или) санаторно-курортное лечение назначены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 15
        s6 := Left( s6, Len( s6 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Case k == 16
        s7 := st + "16." + lstr( i + 1 ) + ".7. Высокотехнологичная медицинская помощь была рекомендована: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
    frd->( Eval( blk, s7 ) )
  Next
  If m1invalid1 == 0
    m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
    minvalid3 := minvalid4 := minvalid7 := CToD( "" )
  Endif
  If Empty( minvalid7 )
    m1invalid8 := -1
  Endif
  s := st + '16.7. Инвалидность: ' + f3_inf_dds_karta( mm_danet, m1invalid1,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_invalid2(), m1invalid2,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; установлена впервые (дата) ' + iif( Empty( minvalid3 ), Replicate( "_", 15 ), ub + full_date( minvalid3 ) + ue )
  s += '; дата последнего освидетельствования ' + iif( Empty( minvalid4 ), Replicate( "_", 15 ), ub + full_date( minvalid4 ) + ue ) + '.'
  frd->( Eval( blk, s ) )
  s := st + '16.7.1. Заболевания, обусловившие возникновение инвалидности:'
  frd->( Eval( blk, s ) )
  mm_invalid5[ 6, 1 ] := "болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм;"
  mm_invalid5[ 7, 1 ] := "болезни эндокринной системы, расстройства питания и нарушения обмена веществ,"
  ATail( mm_invalid5 )[ 1 ] := "последствия травм, отравлений и других воздействий внешних причин)"
  s := st + '(' + f3_inf_dds_karta( mm_invalid5, m1invalid5, ' ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.7.2.Виды нарушений в состоянии здоровья:'
  frd->( Eval( blk, s ) )
  s := st + f3_inf_dds_karta( mm_invalid6(), m1invalid6, '; ', ub, ue )
  frd->( Eval( blk, s ) )
  s := st + '16.7.3. Индивидуальная программа реабилитации ребенка-инвалида:'
  frd->( Eval( blk, s ) )
  s := st + 'дата назначения: ' + iif( Empty( minvalid7 ), Replicate( "_", 15 ), ub + full_date( minvalid7 ) + ue ) + ';'
  frd->( Eval( blk, s ) )
  s := st + 'выполнение на момент диспансеризации: ' + f3_inf_dds_karta( mm_invalid8(), m1invalid8,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "16.8. Группа состояния здоровья: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA,, ub, ue )
  frd->( Eval( blk, s ) )
  If p_tip_lu == TIP_LU_PN
    s := st + "16.9. Медицинская группа для занятий физической культурой: "
    s += f3_inf_dds_karta( mm_gr_fiz, m1GR_FIZ,, ub, ue )
    frd->( Eval( blk, s ) )
  Endif
  s := st + iif( p_tip_lu == TIP_LU_PN, '16.10', '16.9' ) + ;
    '. Проведение профилактических прививок:'
  frd->( Eval( blk, s ) )
  s := st
  For j := 1 To Len( mm_privivki1() )
    If m1privivki1 == mm_privivki1()[ j, 2 ]
      s += ub
    Endif
    s += mm_privivki1()[ j, 1 ]
    If m1privivki1 == mm_privivki1()[ j, 2 ]
      s += ue
    Endif
    If mm_privivki1()[ j, 2 ] == 0
      s += "; "
    Else
      s += ": " + f3_inf_dds_karta( mm_privivki2(), iif( m1privivki1 == mm_privivki1()[ j, 2 ], m1privivki2, -1 ),, ub, ue, .f. ) + "; "
    Endif
  Next
  s += 'нуждается в проведении вакцинации (ревакцинации) с указанием наименования прививки (нужное подчеркнуть): '
  If m1privivki1 > 0 .and. !Empty( mprivivki3 )
    s += ub + AllTrim( mprivivki3 ) + ue
  Endif
  frd->( Eval( blk, s ) )
  s := Replicate( "_", sh ) + "."
  frd->( Eval( blk, s ) )
  s := st + iif( p_tip_lu == TIP_LU_PN, '16.11', '16.10' ) + ;
    '. Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой: '
  k := 3
  If !Empty( mrek_form )
    k := 1
    s += ub + AllTrim( mrek_form ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  If p_tip_lu == TIP_LU_PN
    s := st + '16.12. Рекомендации о необходимости установления или продолжения ' + ;
      'диспансерного наблюдения, включая диагноз заболевания (состояния) ' + ;
      'и код МКБ, по лечению, медицинской реабилитации и ' + ;
      'санаторно-курортному лечению с указанием вида медицинской ' + ;
      'организации (санаторно-курортной организации) и специальности ' + ;
      '(должности) врача: '
  Else
    s := st + '16.11. Рекомендации по диспансерному наблюдению, лечению, ' + ;
      'медицинской реабилитации и санаторно-курортному лечению с указанием ' + ;
      'диагноза (код МКБ), вида медицинской организации и специальности ' + ;
      '(должности) врача: '
  Endif
  k := 5
  If !Empty( mrek_disp )
    k := 2
    s += ub + AllTrim( mrek_disp ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  //
  adbf := { { "name", "C", 60, 0 }, ;
    { "data", "C", 10, 0 }, ;
    { "rezu", "C", 17, 0 } }
  dbCreate( fr_data + "1", adbf )
  Use ( fr_data + "1" ) New Alias FRD1
  dbCreate( fr_data + "2", adbf )
  Use ( fr_data + "2" ) New Alias FRD2
  arr := iif( p_tip_lu == TIP_LU_PN, f4_inf_dnl_karta( 1 ), f4_inf_dds_karta( 1 ) )
  For i := 1 To Len( arr )
    Select FRD1
    Append Blank
    frd1->name := arr[ i, 1 ]
    frd1->data := full_date( arr[ i, 2 ] )
  Next
  arr := iif( p_tip_lu == TIP_LU_PN, f4_inf_dnl_karta( 2 ), f4_inf_dds_karta( 2 ) )
  For i := 1 To Len( arr )
    Select FRD2
    Append Blank
    frd2->name := arr[ i, 1 ]
    frd2->data := full_date( arr[ i, 2 ] )
    frd2->rezu := arr[ i, 3 ]
  Next
  //
  Close databases
  call_fr( "mo_030dcu13" )

  Return Nil

// 05.07.13
Function f3_inf_dds_karta( _menu, _i, _r, ub, ue, fl )

  Local j, s := ""

  Default _r To ", ", fl To .t.
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
    s += " (нужное подчеркнуть)."
  Endif

  Return s

// 04.05.16
Function f4_inf_dds_karta( par, _etap, et2 )

  Local i, k, arr := {}

  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To Len( dds_arr_osm1() )
        k := 0
        Do Case
        Case i ==  1 // {"офтальмолог","", 0, 17,{65},{1112},{"2.83.21"}}, ;
          k := 3
        Case i ==  2 // {"оториноларинголог","", 0, 17,{64},{1111, 111101},{"2.83.22"}}, ;
          k := 5
        Case i ==  3 // {"детский хирург","", 0, 17,{20},{1135},{"2.83.18"}}, ;
          k := 4
        Case i ==  4 // {"травматолог-ортопед","", 0, 17,{100},{1123},{"2.83.19"}}, ;
          k := 6
        Case i ==  5 // {"акушер-гинеколог (девочки)","Ж", 0, 17,{2},{1101},{"2.83.16"}}, ;
          k := 11
        Case i ==  6 // {"детский уролог-андролог (мальчики)","М", 0, 17,{19},{112603, 113502},{"2.83.17"}}, ;
          k := 10
        Case i ==  7 // {"детский стоматолог (с 3 лет)","", 3, 17,{86},{140102},{"2.83.23"}}, ;
          k := 8
        Case i ==  8 // {"детский эндокринолог (с 5 лет)","", 5, 17,{21},{1127, 112702, 113402},{"2.83.24"}}, ;
          k := 9
        Case i ==  9 // {"невролог","", 0, 17,{53},{1109},{"2.83.20"}}, ;
          k := 2
        Case i == 10 // {"психиатр","", 0, 17,{72},{1115},{"2.4.1"}}, ;
          k := 7
        Case i == 11 // {"педиатр","", 0, 17,{68, 57},{1134, 1110},{"2.83.14","2.83.15"}};
          k := 1
        Endcase
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        If Between( mvozrast, dds_arr_osm1()[ i, 3 ], dds_arr_osm1()[ i, 4 ] ) .and. ;
            iif( Empty( dds_arr_osm1()[ i, 2 ] ), .t., dds_arr_osm1()[ i, 2 ] == mpol )
          If !emptyany( &mvard, &mvart )
            AAdd( arr, { dds_arr_osm1()[ i, 1 ], &mvard, "", i, k } )
          Endif
        Endif
      Next
    Endif
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      Default et2 To 0
      If eq_any( et2, 0, 1 )
        For i := 7 To 8 // стоматолог и эндокринолог на 2 этапе
          k := 0
          mvart := "MTAB_NOMov" + lstr( i )
          mvard := "MDATEo" + lstr( i )
          If !Between( mvozrast, dds_arr_osm1()[ i, 3 ], dds_arr_osm1()[ i, 4 ] )
            If !emptyany( &mvard, &mvart )
              AAdd( arr, { dds_arr_osm1()[ i, 1 ], &mvard, "", i, k } )
            Endif
          Endif
        Next
      Endif
      If eq_any( et2, 0, 2 )
        For i := 1 To Len( dds_arr_osm2() )
          k := 0
          mvart := "MTAB_NOM2ov" + lstr( i )
          mvard := "MDATE2o" + lstr( i )
          If !emptyany( &mvard, &mvart )
            AAdd( arr, { dds_arr_osm2()[ i, 1 ], &mvard, "", i, k } )
          Endif
        Next
      Endif
    Endif
  Else
    For i := 1 To Len( dds_arr_iss() )
      k := 0
      Do Case
      Case i ==  1 // {"Клинический анализ мочи","", 0, 17,{34},{1107, 1301, 1402, 1702},{"4.2.153"}}, ;
        k := 2
      Case i ==  2 // {"Клинический анализ крови","", 0, 17,{34},{1107, 1301, 1402, 1702},{"4.11.136"}}, ;
        k := 1
      Case i ==  3 // {"Исследование уровня глюкозы в крови","", 0, 17,{34},{1107, 1301, 1402, 1702},{"4.12.169"}}, ;
        k := 4
      Case i ==  4 // {"Электрокардиография","", 0, 17,{111},{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202},{"13.1.1"}}, ;
        k := 13
      Case i ==  5 // {"Флюорография легких (с 15 лет)","", 15, 17,{78},{1118, 1802},{"7.61.3"}}, ;
        k := 12
      Case i ==  6 // {"УЗИ головного мозга (нейросонография) (до 1 года)","", 0, 0,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.1"}}, ;
        k := 11
      Case i ==  7 // {"УЗИ щитовидной железы (с 7 лет)","", 7, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.2"}}, ;
        k := 8
      Case i ==  8 // {"УЗИ сердца","", 0, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.3"}}, ;
        k := 7
      Case i ==  9 // {"УЗИ тазобедренных суставов (до 1 года)","", 0, 0,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.1.4"}}, ;
        k := 10
      Case i == 10 // {"УЗИ органов брюшной полости комплексное профилактическое","", 0, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.2.1"}}, ;
        k := 6
      Case i == 11 // {"УЗИ органов репродуктивной системы","", 7, 17,{106},{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203},{"8.2.2","8.2.3"}};
        k := 9
      Endcase
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      If Between( mvozrast, dds_arr_iss()[ i, 3 ], dds_arr_iss()[ i, 4 ] )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dds_arr_iss()[ i, 1 ], &mvard, &mvarr, i, k } )
        Endif
      Endif
    Next
  Endif

  Return arr

// 28.01.15
Function inf_dds_svod( par, par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      adbf := { ;
        { "nomer",   "N",     6,     0 }, ;
        { "KOD",   "N",     7,     0 }, ; // код (номер записи)
        { "KOD_K",   "N",     7,     0 }, ; // код по картотеке
        { "FIO",   "C",    50,     0 }, ; // Ф.И.О. больного
        { "DATE_R",   "D",     8,     0 }, ; // дата рождения больного
        { "N_DATA",   "D",     8,     0 }, ; // дата начала лечения
        { "K_DATA",   "D",     8,     0 }, ; // дата окончания лечения
        { "sroki",   "C",    11,     0 }, ; // сроки лечения
        { "noplata",   "N",     1,     0 }, ; //
        { "oplata",   "C",    30,     0 }, ; // оплата
        { "CENA_1",   "N",    10,     2 }, ; // оплачиваемая сумма лечения
        { "KOD_DIAG",   "C",     5,     0 }, ; // шифр 1-ой осн.болезни
        { "etap",   "N",     1,     0 }, ; //
        { "gruppa_do",   "N",     1,     0 }, ; //
        { "gruppa",   "N",     1,     0 }, ; //
        { "gd1",   "C",     1,     0 }, ; //
        { "gd2",   "C",     1,     0 }, ; //
        { "gd3",   "C",     1,     0 }, ; //
        { "gd4",   "C",     1,     0 }, ; //
        { "gd5",   "C",     1,     0 }, ; //
        { "g1",   "C",     1,     0 }, ; //
        { "g2",   "C",     1,     0 }, ; //
        { "g3",   "C",     1,     0 }, ; //
        { "g4",   "C",     1,     0 }, ; //
        { "g5",   "C",     1,     0 }, ; //
        { "vperv",   "C",     1,     0 }, ; //
        { "dispans",   "C",     1,     0 }, ; //
        { "n1",   "C",     1,     0 }, ; //
        { "n2",   "C",     1,     0 }, ; //
        { "n3",   "C",     1,     0 }, ; //
        { "p1",   "C",     1,     0 }, ; //
        { "p2",   "C",     1,     0 }, ; //
        { "p3",   "C",     1,     0 }, ; //
        { "f1",   "C",     1,     0 }, ; //
        { "f2",   "C",     1,     0 }, ; //
        { "f3",   "C",     1,     0 }, ; //
        { "f4",   "C",     1,     0 }, ; //
        { "f5",   "C",     1,     0 }; //
      }
      For i := 1 To Len( dds_arr_iss() )
        AAdd( adbf, { "di_" + lstr( i ), "C", 8, 0 } )
      Next
      For i := 1 To Len( dds_arr_osm1() )
        AAdd( adbf, { "d1_" + lstr( i ), "C", 8, 0 } )
      Next
      AAdd( adbf, { "d1_zs", "C", 8, 0 } )
      For i := 1 To Len( dds_arr_osm2() )
        AAdd( adbf, { "d2_" + lstr( i ), "C", 8, 0 } )
      Next
      dbCreate( cur_dir() + "tmpfio", adbf )
      r_use( dir_server() + "mo_rak",, "RAK" )
      r_use( dir_server() + "mo_raks",, "RAKS" )
      Set Relation To akt into RAK
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Set Relation To kod_raks into RAKS
      Index On Str( kod_h, 7 ) + DToS( rak->DAKT ) to ( cur_dir() + "tmp_raksh" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
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
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_svod" )
      Enddo
      Close databases
      delfrfiles()
      r_use( dir_server() + "organiz",, "ORG" )
      adbf := { { "name", "C", 130, 0 }, ;
        { "nomer", "N", 6, 0 }, ;
        { "kol_opl", "N", 6, 0 }, ;
        { "CENA_1", "N", 15, 2 }, ;
        { "period", "C", 250, 0 }, ;
        { "period2", "C", 50, 0 }, ;
        { "kol2", "C", 60, 0 }, ;
        { "kol3", "C", 60, 0 }, ;
        { "kol4", "C", 60, 0 }, ;
        { "gd1",   "N",     8,     0 }, ; //
        { "gd2",   "N",     8,     0 }, ; //
        { "gd3",   "N",     8,     0 }, ; //
        { "gd4",   "N",     8,     0 }, ; //
        { "gd5",   "N",     8,     0 }, ; //
        { "g1",   "N",     8,     0 }, ; //
        { "g2",   "N",     8,     0 }, ; //
        { "g3",   "N",     8,     0 }, ; //
        { "g4",   "N",     8,     0 }, ; //
        { "g5",   "N",     8,     0 }, ; //
        { "vperv",   "N",     8,     0 }, ; //
        { "dispans",   "N",     8,     0 }, ; //
        { "n1",   "N",     8,     0 }, ; //
        { "n2",   "N",     8,     0 }, ; //
        { "n3",   "N",     8,     0 }, ; //
        { "p1",   "N",     8,     0 }, ; //
        { "p2",   "N",     8,     0 }, ; //
        { "p3",   "N",     8,     0 }, ; //
        { "f1",   "N",     8,     0 }, ; //
        { "f2",   "N",     8,     0 }, ; //
        { "f3",   "N",     8,     0 }, ; //
        { "f4",   "N",     8,     0 }, ; //
        { "f5",   "N",     8,     0 } }
      For i := 1 To Len( dds_arr_iss() )
        AAdd( adbf, { "di_" + lstr( i ), "N", 8, 0 } )
      Next
      For i := 1 To Len( dds_arr_osm1() )
        AAdd( adbf, { "d1_" + lstr( i ), "N", 8, 0 } )
      Next
      AAdd( adbf, { "d1_zs", "N", 8, 0 } )
      For i := 1 To Len( dds_arr_osm2() )
        AAdd( adbf, { "d2_" + lstr( i ), "N", 8, 0 } )
      Next
      dbCreate( fr_titl, adbf )
      Use ( fr_titl ) New Alias FRT
      Append Blank
      frt->name := glob_mo[ _MO_SHORT_NAME ]
      frt->period := iif( p_tip_lu == TIP_LU_DDS, ;
        "пребывающих в стационарных условиях детей-сирот и детей, находящихся в трудной жизненной ситуации", ;
        "детей-сирот и детей, оставшихся без попечения родителей, в том числе усыновлённых (удочерённых), принятых под опеку (попечительство), в приёмную или патронатную семью" )
      frt->period2 := arr_m[ 4 ]
      If par2 == 1
        frt->kol2 := "Ф.И.О"
        frt->kol3 := "Дата рождения"
        frt->kol4 := "Дата начала диспансеризации"
      Else
        frt->kol2 := "Наименование медицинской организации"
        frt->kol3 := "Плановые показатели"
        frt->kol4 := "Фактические показатели выполнения: осмотрено/обработано карт"
      Endif
      Copy File ( cur_dir() + "tmpfio" + sdbf() ) to ( fr_data + sdbf() )
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
            poled := "frd->di_" + lstr( i )
            polet := "frt->di_" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          For i := 1 To Len( dds_arr_osm1() )
            poled := "frd->d1_" + lstr( i )
            polet := "frt->d1_" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          If !Empty( frd->d1_zs )
            frt->d1_zs++
          Endif
          For i := 1 To Len( dds_arr_osm2() )
            poled := "frd->d2_" + lstr( i )
            polet := "frt->d2_" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          Select FRD
          Skip
        Enddo
        Close databases
        call_fr( "mo_ddsTF" )
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
            poled := "frd->gd" + lstr( i )
            polet := "frt->gd" + lstr( i )
            If !Empty( &poled )
              &polet := &polet + 1
            Endif
          Next
          For i := 1 To 5
            poled := "frd->g" + lstr( i )
            polet := "frt->g" + lstr( i )
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
        call_fr( "mo_ddsMZ", iif( par2 == 2, 3, ) )
      Endcase
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 04.05.16
Function f2_inf_dds_svod( Loc_kod, kod_kartotek ) // сводная информация

  Local i := 0, c, s := "НЕТ акта", pole, arr, ddo := {}, dposle := {}

  r_use( dir_server() + "mo_rak",, "RAK" )
  r_use( dir_server() + "mo_raks",, "RAKS" )
  Set Relation To akt into RAK
  r_use( dir_server() + "mo_raksh",, "RAKSH" )
  Set Relation To kod_raks into RAKS
  Set Index to ( cur_dir() + "tmp_raksh" )
  Select RAKSH
  find ( Str( Loc_kod, 7 ) )
  Do While Loc_kod == raksh->kod_h .and. !Eof()
    If Round( raksh->sump, 2 ) == Round( mCENA_1, 2 )
      i := 1
      s := "оплачен"
    Else
      i := 0
      s := "НЕ опл.: акт " + AllTrim( rak->NAKT ) + " от " + date_8( rak->DAKT )
    Endif
    Skip
  Enddo
  Use ( cur_dir() + "tmpfio" ) New Alias TF
  Append Blank
  tf->KOD := Loc_kod
  tf->KOD_K := kod_kartotek
  tf->FIO := mfio
  tf->DATE_R := mdate_r
  tf->N_DATA := mN_DATA
  tf->K_DATA := mK_DATA
  tf->sroki := Left( date_8( mN_DATA ), 5 ) + "-" + Left( date_8( mK_DATA ), 5 )
  tf->noplata := i
  tf->oplata := s
  tf->CENA_1 := mCENA_1
  tf->KOD_DIAG := mkod_diag
  tf->etap := metap
  tf->gruppa_do := mgruppa_do
  If Between( mgruppa_do, 1, 5 )
    pole := "tf->gd" + lstr( mgruppa_do )
    &pole := "X"
  Endif
  tf->gruppa := mgruppa
  If Between( mgruppa, 1, 5 )
    pole := "tf->g" + lstr( mgruppa )
    &pole := "X"
  Endif
  For i := 1 To 5
    pole := "mdiag_16_" + lstr( i ) + "_1"
    If !Empty( &pole )
      AAdd( ddo, AllTrim( &pole ) )
    Endif
  Next
  For i := 1 To 5
    pole := "mdiag_16_" + lstr( i ) + "_1"
    If !Empty( &pole )
      AAdd( dposle, AllTrim( &pole ) )
      pole := "m1diag_16_" + lstr( i ) + "_2"
      if &pole == 1
        tf->vperv := "X"
      Endif
      pole := "m1diag_16_" + lstr( i ) + "_3"
      if &pole == 2
        tf->dispans := "X"
      Endif
      pole := "m1diag_16_" + lstr( i ) + "_13"
      if &pole == 1
        tf->n2 := "X"
        pole := "m1diag_16_" + lstr( i ) + "_15"
        if &pole == 4
          tf->n1 := "X"
        Endif
      Endif
      pole := "m1diag_16_" + lstr( i ) + "_16"
      if &pole == 1
        tf->n3 := "X"
      Endif
    Endif
  Next
  For i := 1 To Len( ddo )
    c := Left( ddo[ i ], 3 )
    If Between( c, "F00", "F69" ) .or. Between( c, "F80", "F99" )
      tf->f3 := "X"
    Endif
  Next
  For i := 1 To Len( dposle )
    If AScan( ddo, dposle[ i ] ) == 0
      tf->f1 := "X"
    Endif
    c := Left( dposle[ i ], 3 )
    If Between( c, "F00", "F69" ) .or. Between( c, "F80", "F99" )
      tf->f4 := "X"
    Endif
  Next
  If !Empty( tf->f3 ) .and. Empty( tf->f4 )
    tf->f5 := "X"
  Endif
  arr := f4_inf_dds_karta( 1, 1 )
  For i := 1 To Len( arr )
    pole := "tf->d1_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  tf->d1_zs := mshifr_zs
  arr := f4_inf_dds_karta( 1, 2, 1 ) // стоматолог и эндокринолог на 2 этапе
  For i := 1 To Len( arr )
    pole := "tf->d1_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  arr := f4_inf_dds_karta( 1, 2, 2 ) // остальные приёмы на 2 этапе
  For i := 1 To Len( arr )
    pole := "tf->d2_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next
  arr := f4_inf_dds_karta( 2 )
  For i := 1 To Len( arr )
    pole := "tf->di_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next

  Return Nil

// 20.06.21 Приложение к письму КЗВО №14-05/50 от 07.02.2020г.
Function inf_dds_svod2( par2, is_schet )

  Local arr_m, i, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 91, HH := 60, n_file := cur_dir() + "ddssvod2.txt"

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti := { ;
        { "1", "Всего", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
        { "1.1", "0-14 лет", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, ;
        { "1.2", "15-17 лет", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        }
      Private arr_2510 := { ;
        { '001 дети 0-14 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '002 из них дети до 1 г.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '003 дети 15-17 лет вкл.', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '004 15-17 лет - юноши', 0, 0, 0, 0, 0, 0, 0 }, ;
        { '005 школьники', 0, 0, 0, 0, 0, 0, 0 };
        }
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }

      Do While .t.
        // R_Use_base("human_u")
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
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_svod2" )
      Enddo
      Close databases
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      If par2 == 3
        add_string( PadL( "Приложение", sh ) )
        add_string( PadL( "к письму КЗВО", sh ) )
        add_string( PadL( "№14-05/50 от 07.02.2020г.", sh ) )
      Endif
      add_string( "" )
      add_string( Center( "Сведения о диспансеризации несовершеннолетних,", sh ) )
      If p_tip_lu == TIP_LU_DDS
        add_string( Center( "пребывающих в стационарных условиях детей-сирот и детей,", sh ) )
        add_string( Center( "находящихся в трудной жизненной ситуации", sh ) )
      Else
        add_string( Center( "детей-сирот и детей, оставшихся без попечения родителей, в том числе", sh ) )
        add_string( Center( "усыновлённых (удочерённых), принятых под опеку (попечительство),", sh ) )
        add_string( Center( "в приёмную или патронатную семью", sh ) )
      Endif
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      If par2 == 3
        // add_string("───┬─────────┬───────────┬───────────┬─────┬─────────────────────────────┬─────┬─────┬─────")
        // add_string("№№ │ Контин- │ Осмотрено │из них село│неинф│           из них            │взято│из 7г│из 14")
        // add_string("пп │ генты   ├─────┬─────┼─────┬─────┤забол├─────┬─────┬─────┬─────┬─────┤на ди│начат│село ")
        // add_string("   │         │всего│в суб│всего│в суб│вперв│крово│ ЗНО │1и2ст│дыхан│пищев│спанс│лечен│     ")
        // add_string("───┼─────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────")
        // add_string(" 1 │    2    │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 │  14 │  15 ")
        // add_string("───┴─────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────")
        add_string( "───┬──────────┬─────────────────┬─────┬───────────────────────────────────┬─────┬─────┬─────" )
        add_string( "№№ │          │     Осмотрено   │неинф│           из них                  │Факто│взято│из 6г" )
        add_string( "пп │Показатель├─────┬─────┬─────┤забол├─────┬─────┬─────┬─────┬─────┬─────┤ры   ┤на ди│начат" )
        add_string( "   │          │всего│андро│гинек│вперв│крово│ ЗНО │ко_мы│ глаз│эндок│пищев│риска│спанс│лечен" )
        add_string( "───┼──────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────" )
        add_string( " 1 │    2     │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 │  14 │  15 " )
        add_string( "───┴──────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" )
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
          add_string( s )
          add_string( Replicate( "─", sh ) )
        Next
      Else
        add_string( "─────────────────────────┬───────────┬─────────────────────────────" )
        add_string( "                         │Число детей│     по группам здоровья     " )
        add_string( "     Дети - сироты       ├─────┬─────┼─────┬─────┬─────┬─────┬─────" )
        add_string( "     таблица 2510        │всего│ село│  1  │  2  │  3  │  4  │  5  " )
        add_string( "─────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────" )
        add_string( "                         │  5  │  6  │  7  │  8  │  9  │  12 │  13 " )
        add_string( "─────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" )
        For i := 1 To Len( arr_2510 )
          s := PadR( arr_2510[ i, 1 ], 25 )
          For j := 2 To Len( arr_2510[ i ] )
            s += put_val( arr_2510[ i, j ], 6 )
          Next
          add_string( s )
        Next
      Endif
      FClose( fp )
      viewtext( n_file,,,, .t.,,, 2 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil


// 20.06.21
Function f2_inf_dds_svod2( Loc_kod, kod_kartotek )

  Local i, j, k, is_selo, ad := {}, ar := { 1 }, ar1 := {}, ;
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
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := { AllTrim( &mvar ), 0, 0 }
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next


  r_use( dir_server() + "kartote2",, "KART2" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )

  r_use( dir_server() + "uslugi",, "USL" )
  r_use_base( "human_u" )
  // R_Use(dir_server() + "human_",,"HUMAN_")
  r_use( dir_server() + "human",, "HUMAN" )
  // set relation to recno() into HUMAN_, to kod_k into KART_
  // use (cur_dir() + "tmp") new
  // set relation to kod into HUMAN
  // go top



  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )
  If mvozrast == 0
    AAdd( ar1, 2 )
  Endif
  If mvozrast < 15
    AAdd( ar1, 1 )
  Else
    AAdd( ar1, 3 )
    If kart->pol == "М"
      AAdd( ar1, 4 )
    Endif
  Endif
  If mvozrast > 6 // школьники ?
    AAdd( ar1, 5 )
  Endif
  //
  AFill( ar2, 0 )
  For i := 1 To Len( ad ) // цикл по диагнозам
    If !( Left( ad[ i, 1 ], 1 ) == "A" .or. Left( ad[ i, 1 ], 1 ) == "B" ) .and. ad[ i, 2 ] == 1 // неинфекционные заболевания уст.впервые
      // arr_deti[k, 7] ++
      ar2[ 7 ] := 1
      If Left( ad[ i, 1 ], 1 ) == "I" // болезни системы кровообращения
        ar2[ 8 ] := 1     // arr_deti[k, 8] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "J" // болезни органов дыхания
        ar2[ 11 ] := 1      // arr_deti[k, 11] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "K" // болезни органов пищеварения
        ar2[ 12 ] := 1     // arr_deti[k, 12] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "H" // болезни глаз
        ar2[ 18 ] := 1    // arr_deti[k, 18] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "E" // болезни эндокринология
        ar2[ 19 ] := 1  // arr_deti[k, 19] ++
      Endif
      If Left( ad[ i, 1 ], 1 ) == "M" // болезни костно-мышечной системы
        ar2[ 21 ] := 1  // arr_deti[k, 21] ++
      Endif
      //
      If Left( ad[ i, 1 ], 3 ) == "E78"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "R73.9"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.0"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.4"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "R63.5"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.3"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.1"
        ar2[ 20 ] := 1
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.2"
        ar2[ 20 ] := 1
      Endif
      //
      If Left( ad[ i, 1 ], 1 ) == "C" .or. Between( Left( ad[ i, 1 ], 3 ), "D00", "D09" ) // ЗНО
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
    If Left( lshifr, 2 ) == "2."  // врачебный приём
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

// 08.11.13
Function inf_dds_030dso( is_schet )

  Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := cur_dir() + "f_030dso.txt", d1, d2

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti[ 5 ] ; AFill( arr_deti, 0 )
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
        { "1", "Некоторые инфекционные и паразит...", "A00-B99",, }, ;
        { "1.1", "туберкулез", "A15-A19",, }, ;
        { "1.2", "ВИЧ-инфекция, СПИД", "B20-B24",, }, ;
        { "2", "Новообразования", "C00-D48",, }, ;
        { "3", "Болезни крови и кроветворных органов ...", "D50-D89",, }, ;
        { "3.1", "анемии", "D50-D53",, }, ;
        { "4", "Болезни эндокринной системы, расстройства...", "E00-E90",, }, ;
        { "4.1", "сахарный диабет", "E10-E14",, }, ;
        { "4.2", "недостаточность питания", "E40-E46",, }, ;
        { "4.3", "ожирение", "E66",, }, ;
        { "4.4", "задержка полового развития", "E30.0",, }, ;
        { "4.5", "преждевременное половое развитие", "E30.1",, }, ;
        { "5", "Психические расстройства и расстро...", "F00-F99",, }, ;
        { "5.1", "умственная отсталость", "F70-F79",, }, ;
        { "6", "Болезни нервной системы, из них:", "G00-G98",, }, ;
        { "6.1", "церебральный паралич и другие ...", "G80-G83",, }, ;
        { "7", "Болезни глаза и его придаточного аппарата", "H00-H59",, }, ;
        { "8", "Болезни уха и сосцевидного отростка", "H60-H95",, }, ;
        { "9", "Болезни системы кровообращения", "I00-I99",, }, ;
        { "10", "Болезни органов дыхания, из них:", "J00-J99",, }, ;
        { "10.1", "астма, астматический статус", "J45-J46",, }, ;
        { "11", "Болезни органов пищеварения", "K00-K93",, }, ;
        { "12", "Болезни кожи и подкожной клетчатки", "L00-L99",, }, ;
        { "13", "Болезни костно-мышечной ...", "M00-M99",, }, ;
        { "13.1", "кифоз, лордоз, сколиоз", "M40-M41",, }, ;
        { "14", "Болезни мочеполовой системы, из них:", "N00-N99",, }, ;
        { "14.1", "болезни мужских половых органов", "N40-N51",, }, ;
        { "14.2", "нарушения ритма и характера менструаций", "N91-N94.5",, }, ;
        { "14.3", "воспалительные заболевания ...", "N70-N77",, }, ;
        { "14.4", "невоспалительные болезни ...", "N83-N83.9",, }, ;
        { "14.5", "болезни молочной железы", "N60-N64",, }, ;
        { "15", "Отдельные состояния, возника...", "P00-P96",, }, ;
        { "16", "Врожденные аномалии (пороки ...", "Q00-Q99",, }, ;
        { "16.1", "развития нервной системы", "Q00-Q07",, }, ;
        { "16.2", "системы кровообращения", "Q20-Q28",, }, ;
        { "16.3", "костно-мышечной системы", "Q65-Q79",, }, ;
        { "16.4", "женских половых органов", "Q50-Q52",, }, ;
        { "16.5", "мужских половых органов", "Q53-Q55",, }, ;
        { "17", "Травмы, отравления и некоторые...", "S00-T98",, }, ;
        { "18", "Прочие", "",, }, ;
        { "19", "ВСЕГО ЗАБОЛЕВАНИЙ", "A00-T98",, };
      }
      For n := 1 To Len( arr_4 )
        If "-" $ arr_4[ n, 3 ]
          d1 := Token( arr_4[ n, 3 ], "-", 1 )
          d2 := Token( arr_4[ n, 3 ], "-", 2 )
        Else
          d1 := d2 := arr_4[ n, 3 ]
        Endif
        arr_4[ n, 4 ] := diag_to_num( d1, 1 )
        arr_4[ n, 5 ] := diag_to_num( d2, 2 )
      Next
      dbCreate( cur_dir() + "tmp4", { { "name", "C", 100, 0 }, ;
        { "diagnoz", "C", 20, 0 }, ;
        { "stroke", "C", 4, 0 }, ;
        { "ns", "N", 2, 0 }, ;
        { "diapazon1", "N", 10, 0 }, ;
        { "diapazon2", "N", 10, 0 }, ;
        { "tbl", "N", 1, 0 }, ;
        { "k04", "N", 8, 0 }, ;
        { "k05", "N", 8, 0 }, ;
        { "k06", "N", 8, 0 }, ;
        { "k07", "N", 8, 0 }, ;
        { "k08", "N", 8, 0 }, ;
        { "k09", "N", 8, 0 }, ;
        { "k10", "N", 8, 0 }, ;
        { "k11", "N", 8, 0 } } )
      Use ( cur_dir() + "tmp4" ) New Alias TMP
      For i := 1 To Len( arr_vozrast )
        For n := 1 To Len( arr_4 )
          Append Blank
          tmp->tbl := arr_vozrast[ i, 1 ]
          tmp->stroke := arr_4[ n, 1 ]
          tmp->name := arr_4[ n, 2 ]
          tmp->ns := n
          tmp->diagnoz := arr_4[ n, 3 ]
          tmp->diapazon1 := arr_4[ n, 4 ]
          tmp->diapazon2 := arr_4[ n, 5 ]
        Next
      Next
      Index On Str( tbl, 1 ) + Str( ns, 2 ) to ( cur_dir() + "tmp4" )
      Use
      dbCreate( cur_dir() + "tmp10", { { "voz", "N", 1, 0 }, ;
        { "tbl", "N", 2, 0 }, ;
        { "tip", "N", 1, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp10" ) New Alias TMP10
      Index On Str( voz, 1 ) + Str( tbl, 1 ) + Str( tip, 1 ) to ( cur_dir() + "tmp10" )
      Use
      Copy file tmp10.dbf To tmp11.dbf
      Use ( cur_dir() + "tmp11" ) New Alias TMP11
      Index On Str( voz, 1 ) + Str( tbl, 2 ) + Str( tip, 1 ) to ( cur_dir() + "tmp11" )
      Use
      dbCreate( cur_dir() + "tmp13", { { "voz", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp13" ) New Alias TMP13
      Index On Str( voz, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp13" )
      Use
      dbCreate( cur_dir() + "tmp16", { { "voz", "N", 1, 0 }, ;
        { "man", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp16" ) New Alias TMP16
      Index On Str( voz, 1 ) + Str( man, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp16" )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
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
        @ MaxRow(), 0 Say Str( rec / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_DDS_030dso" )
      Enddo
      Close databases
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( PadL( "Приложение 3", sh ) )
      add_string( PadL( "к Приказу МЗРФ", sh ) )
      add_string( PadL( "№72н от 15.02.2013г.", sh ) )
      add_string( "" )
      add_string( PadL( "Отчетная форма № 030-Д/с/о-13", sh ) )
      add_string( "" )
      add_string( Center( "Сведения о диспансеризации несовершеннолетних,", sh ) )
      If p_tip_lu == TIP_LU_DDS
        add_string( Center( "пребывающих в стационарных условиях детей-сирот и детей,", sh ) )
        add_string( Center( "находящихся в трудной жизненной ситуации", sh ) )
      Else
        add_string( Center( "детей-сирот и детей, оставшихся без попечения родителей, в том числе", sh ) )
        add_string( Center( "усыновлённых (удочерённых), принятых под опеку (попечительство),", sh ) )
        add_string( Center( "в приёмную или патронатную семью", sh ) )
      Endif
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      add_string( "2. Число детей, прошедших диспансеризацию в отчетном периоде:" )
      add_string( "  2.1. всего в возрасте от 0 до 17 лет включительно:" + Str( arr_deti[ 1 ], 6 ) + " (человек), из них:" )
      add_string( "  2.1.1. в возрасте от 0 до 4 лет включительно      " + Str( arr_deti[ 2 ], 6 ) + " (человек)," )
      add_string( "  2.1.2. в возрасте от 5 до 9 лет включительно      " + Str( arr_deti[ 3 ], 6 ) + " (человек)," )
      add_string( "  2.1.3. в возрасте от 10 до 14 лет включительно    " + Str( arr_deti[ 4 ], 6 ) + " (человек)," )
      add_string( "  2.1.4. в возрасте от 15 до 17 лет включительно    " + Str( arr_deti[ 5 ], 6 ) + " (человек)." )
      For i := 1 To Len( arr_vozrast )
        verify_ff( HH -50, .t., sh )
        add_string( "" )
        add_string( Center( lstr( arr_vozrast[ i, 1 ] ) + ;
          ". Структура выявленных заболеваниях (сосотояний) у детей в возрасте от " + ;
          lstr( arr_vozrast[ i, 2 ] ) + " до " + lstr( arr_vozrast[ i, 3 ] ) + " лет включительно", sh ) )
        add_string( "────┬───────────────────┬───────┬─────┬─────┬─────┬─────┬───────────────────────" )
        add_string( " №№ │    Наименование   │ Код по│Всего│в т.ч│выяв-│в т.ч│Состоит под дисп.наблюд" )
        add_string( " пп │    заболеваний    │ МКБ-10│зарег│маль-│лено │маль-├─────┬─────┬─────┬─────" )
        add_string( "    │                   │       │забол│чики │вперв│чики │всего│мальч│взято│мальч" )
        add_string( "────┼───────────────────┼───────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────" )
        add_string( " 1  │          2        │   3   │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  " )
        add_string( "────┴───────────────────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" )
        Use ( cur_dir() + "tmp4" ) index ( cur_dir() + "tmp4" ) New Alias TMP
        find ( Str( arr_vozrast[ i, 1 ], 1 ) )
        Do While tmp->tbl == arr_vozrast[ i, 1 ] .and. !Eof()
          s := tmp->stroke + " " + PadR( tmp->name, 19 ) + " " + PadC( AllTrim( tmp->diagnoz ), 7 )
          For n := 4 To 11
            s += put_val( tmp->&( "k" + StrZero( n, 2 ) ), 6 )
          Next
          add_string( s )
          Skip
        Enddo
        Use
        add_string( Replicate( "─", sh ) )
      Next
      arr1title := { ;
        "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        "                    │   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных ", ;
        "  Возраст детей     │           │           │субъекта РФ│  ных ГУЗ  │    МО     ", ;
        "                    │           │           │           │           │           ", ;
        "────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────", ;
        "          1         │     2     │     3     │     4     │     5     │     6     ", ;
        "────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────" }
      arr2title := { ;
        "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        "                    │   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных ", ;
        "  Возраст детей     ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────", ;
        "                    │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ", ;
        "────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "          1         │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 ", ;
        "────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      arr3title := { ;
        "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        " Возраст│   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных │в санаторно", ;
        " детей  │           │           │субъекта РФ│  ных ГУЗ  │    МО     │-курортных ", ;
        "        │           │           │           │           │           │организ-ях ", ;
        "────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────", ;
        "    1   │     2     │     3     │     4     │     5     │     6     │     7     ", ;
        "────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────" }
      arr4title := { ;
        "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        " Возраст│   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных │в сан.-кур.", ;
        " детей  ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────┼──орг-иях──", ;
        "        │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ", ;
        "────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "    1   │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ", ;
        "────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      verify_ff( HH -50, .t., sh )
      add_string( "10. Результаты дополнительных консультаций, исследований, лечения и медицинской" )
      add_string( "    реабилитации детей по результатам проведения настоящей диспансеризации:" )
      Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) New Alias TMP10
      For i := 1 To 8
        verify_ff( HH -16, .t., sh )
        add_string( "" )
        s := Space( 5 )
        If i == 1
          add_string( s + "10.1. Нуждались в дополнительных консультациях и исследованиях" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Elseif i == 2
          add_string( s + "10.2. Прошли дополнительные консультации и исследования" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Elseif i == 3
          add_string( s + "10.3. Нуждались в дополнительных консультациях и исследованиях" )
          add_string( s + "      в стационарных условиях" )
        Elseif i == 4
          add_string( s + "10.4. Прошли дополнительные консультации и исследования" )
          add_string( s + "      в стационарных условиях" )
        Elseif i == 5
          add_string( s + "10.5. Рекомендовано лечение в амбулаторных условиях и в условиях" )
          add_string( s + "      дневного стационара" )
        Elseif i == 6
          add_string( s + "10.6. Рекомендовано лечение в стационарных условиях" )
        Elseif i == 7
          add_string( s + "10.7. Рекомендована медицинская реабилитация" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Else
          add_string( s + "10.8. Рекомендованы медицинская реабилитация и (или)" )
          add_string( s + "      санаторно-курортное лечение в стационарных условиях" )
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
          s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
          skol := oldkol := 0
          s1 := ""
          For k := 1 To iif( i == 8, 5, 4 )
            find ( Str( j, 1 ) + Str( i, 1 ) + Str( k, 1 ) )
            If Found() .and. ( v := tmp10->kol ) > 0
              skol += v
              If eq_any( i, 2, 4 )
                s1 += Str( v, 6 )
                find ( Str( j, 1 ) + Str( i -1, 1 ) + Str( k, 1 ) )
                If Found() .and. tmp10->kol > 0
                  s1 += " " + umest_val( v / tmp10->kol * 100, 5, 2 )
                  oldkol += tmp10->kol
                Else
                  s1 += Space( 6 )
                Endif
              Else
                s1 += " " + PadC( lstr( v ), 11 )
              Endif
            Else
              s1 += Space( 12 )
            Endif
          Next
          If skol > 0
            If eq_any( i, 2, 4 )
              s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
            Else
              s += " " + PadC( lstr( skol ), 11 )
            Endif
            add_string( s + s1 )
          Else
            add_string( s )
          Endif
        Next
        add_string( Replicate( "─", sh ) )
      Next
      Use
      //
      verify_ff( HH -50, .t., sh )
      add_string( "11. Результаты лечения, медицинской реабилитации и (или) санаторно-курортного" )
      add_string( "    лечения детей до проведения настоящей диспансеризации:" )
      vkol := 0
      Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) New Alias TMP11
      For i := 1 To 12
        If i % 3 > 0
          verify_ff( HH -16, .t., sh )
          add_string( "" )
        Endif
        s := Space( 5 )
        If i == 1
          add_string( s + "11.1. Рекомендовано лечение в амбулаторных условиях и в условиях" )
          add_string( s + "      дневного стационара" )
        Elseif i == 2
          add_string( s + "11.2. Проведено лечение в амбулаторных условиях и в условиях" )
          add_string( s + "      дневного стационара" )
        Elseif i == 3
          add_string( s + "11.3. Причины невыполнения рекомендаций по лечению в амбулаторных условиях" )
          add_string( s + "      и в условиях дневного стационара:" )
          add_string( s + "        11.3.1. не прошли всего " + lstr( vkol ) + " (человек)" )
        Elseif i == 4
          add_string( s + "11.4. Рекомендовано лечение в стационарных условиях" )
        Elseif i == 5
          add_string( s + "11.5. Проведено лечение в стационарных условиях" )
        Elseif i == 6
          add_string( s + "11.6. Причины невыполнения рекомендаций по лечению в стационарных условиях:" )
          add_string( s + "        11.6.1. не прошли всего " + lstr( vkol ) + " (человек)" )
        Elseif i == 7
          add_string( s + "11.7. Рекомендована медицинская реабилитация" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Elseif i == 8
          add_string( s + "11.8. Проведена медицинская реабилитация" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Elseif i == 9
          add_string( s + "11.9. Причины невыполнения рекомендаций по медицинской реабилитации" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара:" )
          add_string( s + "        11.9.1. не прошли всего " + lstr( vkol ) + " (человек)" )
        Elseif i == 10
          add_string( s + "11.10. Рекомендованы медицинская реабилитация и (или)" )
          add_string( s + "       санаторно-курортное лечение в стационарных условиях" )
        Elseif i == 11
          add_string( s + "11.11. Проведена медицинская реабилитация и (или)" )
          add_string( s + "       санаторно-курортное лечение в стационарных условиях" )
        Else
          add_string( s + "11.12. Причины невыполнения рекомендаций по медицинской реабилитации" )
          add_string( s + "       и (или) санаторно-курортному лечению в стационарных условиях:" )
          add_string( s + "         11.12.1. не прошли всего " + lstr( vkol ) + " (человек)" )
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
            s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
            skol := oldkol := 0
            s1 := ""
            For k := 1 To iif( i > 10, 5, 4 )
              find ( Str( j, 1 ) + Str( i, 2 ) + Str( k, 1 ) )
              If Found() .and. ( v := tmp11->kol ) > 0
                skol += v
                If eq_any( i, 2, 5, 8, 11 )
                  s1 += Str( v, 6 )
                  find ( Str( j, 1 ) + Str( i -1, 2 ) + Str( k, 1 ) )
                  If Found() .and. tmp11->kol > 0
                    s1 += " " + umest_val( v / tmp11->kol * 100, 5, 2 )
                    oldkol += tmp11->kol
                  Else
                    s1 += Space( 6 )
                  Endif
                Else
                  s1 += " " + PadC( lstr( v ), 11 )
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
                s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
              Else
                s += " " + PadC( lstr( skol ), 11 )
              Endif
              add_string( s + s1 )
            Else
              add_string( s )
            Endif
          Next
          add_string( Replicate( "─", sh ) )
        Endif
      Next
      Use
      verify_ff( HH -3, .t., sh )
      add_string( "" )
      add_string( "12. Оказание высокотехнологичной медицинской помощи:" )
      add_string( "  12.1. рекомендована (по итогам настоящей диспанc-ции): " + lstr( s12_1 ) + " чел., в т.ч. " + lstr( s12_1m ) + " мальчикам" )
      add_string( "  12.2. оказана (по итогам диспансеризации в пред.году): " + lstr( s12_2 ) + " чел., в т.ч. " + lstr( s12_2m ) + " мальчикам" )
      Use ( cur_dir() + "tmp13" ) index ( cur_dir() + "tmp13" ) New Alias TMP13
      verify_ff( HH -16, .t., sh )
      n := 32
      add_string( "" )
      add_string( "13. Число детей-инвалидов из числа детей, прошедших диспансеризацию" )
      add_string( "    в отчетном периоде" )
      add_string( "────────────────────────────────┬───────────┬───────────┬───────────┬─────┬─────" )
      add_string( "                                │ с рождения│приобретённ│уст.впервые│ чел.│  %  " )
      add_string( "         Возраст детей          ├─────┬─────┼─────┬─────┼─────┬─────┤детей│детей" )
      add_string( "                                │ чел.│  %  │ чел.│  %  │ чел.│  %  │инвал│инвал" )
      add_string( "────────────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────" )
      add_string( "               1                │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  " )
      add_string( "────────────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 0, 2 ) )
        oldkol := iif( Found(), tmp13->kol, 0 )
        For i := 1 To 4
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += Str( tmp13->kol, 6 ) + " " + umest_val( tmp13->kol / oldkol * 100, 5, 2 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( "─", sh ) )
      verify_ff( HH -16, .t., sh )
      n := 26
      add_string( "" )
      add_string( "14. Выполнение индивидуальных программ реабилитации (ИПР) детей-инвалидов" )
      add_string( "    в отчетном периоде" )
      add_string( "──────────────────────────┬─────┬───────────┬───────────┬───────────┬───────────" )
      add_string( "                          │назна│вып.полност│вып.частичн│ ИПР начата│не выполнен" )
      add_string( "       Возраст детей      │чено ├─────┬─────┼─────┬─────┼─────┬─────┼─────┬─────" )
      add_string( "                          │ чел.│ чел.│  %  │ чел.│  %  │ чел.│  %  │ чел.│  %  " )
      add_string( "──────────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────" )
      add_string( "             1            │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 " )
      add_string( "──────────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 10, 2 ) )
        oldkol := 0
        If Found()
          oldkol := tmp13->kol
        Endif
        s += put_val( oldkol, 6 )
        For i := 11 To 14
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += Str( tmp13->kol, 6 ) + " " + umest_val( tmp13->kol / oldkol * 100, 5, 2 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( "─", sh ) )
      verify_ff( HH -15, .t., sh )
      n := 20
      add_string( "" )
      add_string( "15. Охват профилактическими прививками в отчетном периоде" )
      add_string( "────────────────────┬───────────┬───────────────────────┬───────────────────────" )
      add_string( "                    │  Привито  │Не привиты по мед.показ│Не привиты по друг.прич" )
      add_string( "    Возраст детей   │    чел.   ├───────────┬───────────┼───────────┬───────────" )
      add_string( "                    │           │ полностью │ частично  │ полностью │ частично  " )
      add_string( "────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────" )
      add_string( "          1         │     2     │     3     │     4     │     5     │     6     " )
      add_string( "────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────" )
      For j := 1 To Len( arr1vozrast )
        s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
        find ( Str( j, 1 ) + Str( 20, 2 ) )
        If Found()
          s += " " + PadC( lstr( tmp13->kol ), 11 )
        Else
          s += Space( 12 )
        Endif
        For i := 21 To 24
          find ( Str( j, 1 ) + Str( i, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp13->kol ), 11 )
          Else
            s += Space( 12 )
          Endif
        Next
        add_string( s )
      Next
      add_string( Replicate( "─", sh ) )
      Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) New Alias TMP16
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "16. Распределение детей по уровню физического развития" )
      add_string( "────────────────────┬─────────┬─────────┬───────────────────────────────────────" )
      add_string( "                    │Число про│Норм.физ.│ Отклонения физического развития (чел.)" )
      add_string( "    Возраст детей   │шедших ди│развитие ├─────────┬─────────┬─────────┬─────────" )
      add_string( "                    │спансериз│   чел.  │дефиц.мас│избыт.мас│низк.рост│высо.рост" )
      add_string( "────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────" )
      add_string( "          1         │    2    │    3    │    4    │    5    │    6    │    7    " )
      add_string( "────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (мальчики)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 1 To 5
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            If Found()
              s += " " + PadC( lstr( tmp16->kol ), 9 )
            Else
              s += Space( 10 )
            Endif
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( "─", sh ) )
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "17. Распределение детей по группам состояния здоровья" )
      add_string( "────────────────────┬─────────┬────────────────────────┬────────────────────────" )
      add_string( "                    │Число про│ до диспансеризации     │ по результатам дисп-ии " )
      add_string( "    Возраст детей   │шедших ди├────┬────┬────┬────┬────┼────┬────┬────┬────┬────" )
      add_string( "                    │спансериз│ I  │ II │ III│ IV │ V  │ I  │ II │ III│ IV │ V  " )
      add_string( "────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────" )
      add_string( "          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 " )
      add_string( "────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (мальчики)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
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
      add_string( Replicate( "─", sh ) )
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
    is_man := ( mpol == "М" ), blk_tbl, blk_tip, blk_put_tip, ;
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
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  Use ( cur_dir() + "tmp4" ) index ( cur_dir() + "tmp4" ) New Alias TMP
  Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) New Alias TMP10
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
      AAdd( au, Len( arr_4 ) -1 )  // {"18","Прочие","",,}, ;
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
      s := "diag_15_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 14 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) New Alias TMP11
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
  If m1privivki1 == 1     // не привит по медицинским показаниям", 1}, ;
    If m1privivki2 == 1
      AAdd( ad, 21 )
    Else
      AAdd( ad, 22 )
    Endif
  Elseif m1privivki1 == 2 // не привит по другим причинам", 2}}
    If m1privivki2 == 1
      AAdd( ad, 23 )
    Else
      AAdd( ad, 24 )
    Endif
  Else                    // привит по возрасту", 0}, ;
    AAdd( ad, 20 )
  Endif
  Use ( cur_dir() + "tmp13" ) index ( cur_dir() + "tmp13" ) New Alias TMP13
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
  Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) New Alias TMP16
  For n := 1 To Len( av1 ) // цикл по возрастам таблицы
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + "0" + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp16->voz := av1[ n ]
        tmp16->tip := ad[ j ]
      Endif
      tmp16->kol++
      If is_man
        find ( Str( av1[ n ], 1 ) + "1" + Str( ad[ j ], 2 ) )
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

  Static stitle := "XML-портал: диспансеризация детей-сирот "
  Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dds( arr_m, is_schet > 1, is_schet == 3, .t. )
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmp" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        e_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := 2
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := stitle + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " ", {|| iif( tmp->is == 1, "", " " ) }, blk }, ;
        { " Ф.И.О.", {|| PadR( human->fio, 37 ) }, blk }, ;
        { "Дата рожд.", {|| full_date( human->date_r ) }, blk }, ;
        { "№ ам.карты", {|| human->uch_doc }, blk }, ;
        { "Сроки леч-я", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "Этап", {|| iif( human->ishod == 101, " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход для создания файла;  ^<+,-,Ins>^ - отметить/снять отметку с пациента" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_n_xmlfile( nk, ob, "edit" ) }
      edit_browse( t_arr )
      Select TMP
      Delete For is == 0
      Pack
      n := LastRec()
      Close databases
      rest_box( buf )
      If n == 0 .or. !f_esc_enter( "составления XML-файла" )
        Return Nil
      Endif
      mywait()
      r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
      Use
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmpraksh" )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
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
        @ MaxRow(), 0 Say PadR( Str( n / tmp->( LastRec() ) * 100, 6, 2 ) + "%" + " " + ;
          RTrim( human->fio ) + " " + date_8( human->n_data ) + "-" + ;
          date_8( human->k_data ), 80 ) Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        oms_sluch_dds( p_tip_lu, lkod_h, lkod_k, "f2_inf_N_XMLfile" )
      Enddo
      Close databases
      rest_box( buf )
      mo_mzxml_n( 3, "tmp", stitle )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 23.01.25 Информация по диспансеризации и профилактике взрослого населения
Function inf_dvn( k )

  Static si1 := 1, si2 := 1, si3 := 1, si4 := 1, si5 := 2, si6 := 2, si7 := 2, sj := 1, sj1 := 1
  Local mas_pmt, mas_msg, mas_fun, j

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "Карта учёта №131/~у", ;
      "~Список пациентов", ;
      "Многовариантный ~запрос", ;
      "Своды для ~Облздрава", ;
      "Своды по УД для ~Облздрава", ;
      "Отчётная форма №~131", ;
      "Обмен ~файлами R0... с ТФ" }
    mas_msg := { "Распечатка карты учёта диспансеризации (профилактических мед.осмотров) №131/у", ;
      "Распечатка списка пациентов, прошедших диспансеризацию/профилактику", ;
      "Многовариантный запрос по диспансеризации/профилактике взрослого населения", ;
      "Распечатка сводов для Волгоградского областного Комитета здравоохранения", ;
      "Распечатка сводов по углубленной диспансеризации для Волгоградского облздрава", ;
      "Сведения о диспансеризации определённых групп взрослого населения", ;
      "Информационное сопровождение при орг-ции прохождения профилактических мероприятий" }
    mas_fun := { "inf_DVN(11)", ;
      "inf_DVN(12)", ;
      "inf_DVN(13)", ;
      "inf_DVN(14)", ;
      "inf_DVN(17)", ;
      "inf_DVN(15)", ;
      "inf_DVN(16)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    f_131_u()
  Case k == 12
    mas_pmt := AClone( mas1pmt )
    AAdd( mas_pmt, "случаи, ещё ~не попавшие в счета" )
    If ( j := popup_prompt( T_ROW, T_COL -5, sj, mas_pmt ) ) > 0
      sj := j
      If ( j := popup_prompt( T_ROW, T_COL -5, sj1, ;
          { "Диспансеризация ~1 этап", ;
          "Направлены на 2 этап - ещё ~не прошли", ;
          "Диспансеризация ~2 этап", ;
          "~Профилактика" } ) ) > 0
        sj1 := j
        f2_inf_dvn( sj, sj1 )
      Endif
    Endif
  Case k == 13
    /*mas_pmt := {"~Лица, подлежащие диспансеризации"}
    mas_msg := {"Запрос лиц, подлежащих диспасеризации, методом многовариантного поиска"}
    mas_fun := {"inf_DVN(31)"}
    popup_prompt(T_ROW,T_COL-5,si3,mas_pmt,mas_msg,mas_fun)*/
    inf_dvn( 31 )
  Case k == 14
    mas_pmt := { "~Сведения о диспансеризации по состоянию на ...", ;
      "~Индикаторы мониторинга диспансеризации взрослых" }
    mas_msg := { "Приложение к Приказу МЗВО №2066 от 01.08.2013г.", ;
      "Индикаторы мониторинга диспансеризации взрослых" }
    mas_fun := { "inf_DVN(21)", ;
      "inf_DVN(22)" }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    If ( j := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      forma_131( j )
    Endif
  Case k == 16
    mas_pmt := { "План-график (R0~5)", ;
      "Файлы обмена (R0~1)", ;
      "~Файлы обмена (R11)" }
    mas_msg := { "Создание и просмотр файлов обмена R05...", ;
      "Создание и просмотр файлов обмена R01...", ;
      "Создание и просмотр файлов обмена R11..." }
    mas_fun := { "inf_DVN(41)", ;
      "inf_DVN(42)", ;
      "inf_DVN(43)" }
    str_sem := "ИСОМП"
    If g_slock( str_sem )
      fff_init_r01() // открыл
      popup_prompt( T_ROW - Len( mas_pmt ) -3, T_COL -5, si4, mas_pmt, mas_msg, mas_fun )
      g_sunlock( str_sem )
    Else
      func_error( 4, "В данный момент с этим режимом работает другой пользователь." )
    Endif
  Case k == 17
    inf_ydvn()
  Case k == 41
    // ne_real()
    // if glob_mo[_MO_KOD_TFOMS] == '711001' // ЖД-больница
    mas_pmt := { "~Создание плана-графика", ;
      "~Просмотр файлов обмена" }
    mas_msg := { "Создание файла обмена R05... с планом-графиком по месяцам", ;
      "Просмотр файлов обмена R05... и результатов работы с ними" }
    mas_fun := { "inf_DVN(51)", ;
      "inf_DVN(52)" }
    popup_prompt( T_ROW, T_COL -5, si5, mas_pmt, mas_msg, mas_fun )
    // endif
  Case k == 42
    // ne_real()
    // if glob_mo[_MO_KOD_TFOMS] == '711001' // ЖД-больница
    mas_pmt := { "~Создание файлов обмена", ;
      "~Просмотр файлов обмена" }
    mas_msg := { "Создание файлов обмена R01... по всем месяцам", ;
      "Просмотр файлов обмена R01... и результатов работы с ними" }
    mas_fun := { "inf_DVN(61)", ;
      "inf_DVN(62)" }
    If need_delete_reestr_r01()
      AAdd( mas_pmt, "~Аннулирование пакета" )
      AAdd( mas_msg, "Аннулирование недописанного пакета файлов R01" )
      AAdd( mas_fun, "delete_reestr_R01()" )
    Endif
    // set key K_CTRL_F10 to delete_month_R01()
    popup_prompt( T_ROW, T_COL -5, si6, mas_pmt, mas_msg, mas_fun )
    // set key K_CTRL_F10 to
    // endif
  Case k == 21
    If ( j := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      f21_inf_dvn( j )
    Endif
  Case k == 22
    f22_inf_dvn( j )
  Case k == 31
    mnog_poisk_dvn1()
  Case k == 51
    f_create_r05()
  Case k == 52
    f_view_r05()
  Case k == 61
    f_create_r01()
  Case k == 62
    f_view_r01()
  Case k == 43
//    If glob_mo[ _MO_KOD_TFOMS ] == '711001' // ЖД-больница
      mas_pmt := { "~Создание файлов обмена", ;
        "~Просмотр файлов обмена" }
      mas_msg := { "Создание файлов обмена R11... за конкретный месяц", ;
        "Просмотр файлов обмена R11... и результатов работы с ними" }
      mas_fun := { "inf_DVN(71)", ;
        "inf_DVN(72)" }
      If need_delete_reestr_r01()
        AAdd( mas_pmt, "~Аннулирование пакета" )
        AAdd( mas_msg, "Аннулирование недописанного пакета R11" )
        AAdd( mas_fun, "delete_reestr_R11()" )
      Endif
      AAdd( mas_pmt, "~Повторный подбор пациентов" )
      AAdd( mas_msg, "Повторный подбор пациентов" )
      AAdd( mas_fun, "find_new_R00()" )
      AAdd( mas_pmt, "П~одбор 'НЕ НАШИХ' пациентов" )
      AAdd( mas_msg, "Подбор пациентов, прикрепленных к другим МО или БЕЗ прикрепления" )
      AAdd( mas_fun, "find_new_R000()" )

      // set key K_CTRL_F10 to delete_month_R11()
      popup_prompt( T_ROW, T_COL - 5, si7, mas_pmt, mas_msg, mas_fun )
      // set key K_CTRL_F10 to
//    Endif
  Case k == 71
    f_create_r11()
  Case k == 72
    f_view_r01( _XML_FILE_R11 )
  Endcase
  If k > 10
    j := Int( Val( Right( lstr( k ), 1 ) ) )
    If Between( k, 11, 19 )
      si1 := j
    Elseif Between( k, 21, 29 )
      si2 := j
    Elseif Between( k, 31, 39 )
      si3 := j
    Elseif Between( k, 41, 49 )
      si4 := j
    Elseif Between( k, 51, 59 )
      si5 := j
    Elseif Between( k, 61, 69 )
      si6 := j
    Elseif Between( k, 71, 79 )
      si7 := j
    Endif
  Endif

  Return Nil

// 15.08.19
Function f0_inf_dvn( arr_m, is_schet, is_reg, is_1_2 )

  Local fl := .t., j := 0, n, buf := save_maxrow()

  Default is_schet To .t., is_reg To .f., is_1_2 To .f.
  If !del_dbf_file( cur_dir() + "tmp" + sdbf() )
    Return .f.
  Endif
  mywait()
  dbCreate( cur_dir() + "tmp", { { "kod_k", "N", 7, 0 }, ;
    { "kod1h", "N", 7, 0 }, ;
    { "date1", "D", 8, 0 }, ;
    { "kod2h", "N", 7, 0 }, ;
    { "date2", "D", 8, 0 }, ;
    { "kod3h", "N", 7, 0 }, ;
    { "date3", "D", 8, 0 }, ;
    { "kod4h", "N", 7, 0 }, ;
    { "date4", "D", 8, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp" )
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_
  n := iif( is_1_2, 204, 203 )
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + "tmp_h" ) ;
    For Between( ishod, 201, n ) .and. human->cena_1 > 0 .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := f_is_uch( st_a_uch, human->lpu )
    If fl .and. is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      find ( Str( human->kod_k, 7 ) )
      If !Found()
        Append Blank
        tmp->kod_k := human->kod_k
      Endif
      Do Case
      Case human->ishod == 201
        If ( Empty( tmp->date1 ) .or. human->k_data > tmp->date1 )
          tmp->kod1h := human->kod
          tmp->date1 := human->k_data
        Endif
      Case human->ishod == 202
        If ( Empty( tmp->date2 ) .or. human->k_data > tmp->date2 )
          tmp->kod2h := human->kod
          tmp->date2 := human->k_data
        Endif
      Case human->ishod == 203
        If ( Empty( tmp->date3 ) .or. human->k_data > tmp->date3 )
          tmp->kod3h := human->kod
          tmp->date3 := human->k_data
        Endif
      Case human->ishod == 204
        tmp->kod4h := human->kod
        tmp->date4 := human->k_data
      Endcase
      If++j % 1000 == 0
        Commit
      Endif
    Endif
    Select HUMAN
    Skip
  Enddo
  rest_box( buf )
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, "Не найдено л/у по диспансеризации взрослого населения " + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 20.10.16 карта учёта диспансеризации по форме №131/у
Function f_131_u()

  Local arr_m, buf := save_maxrow(), k, blk, t_arr[ BR_LEN ], rec := 0

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != Nil .and. f0_inf_dvn( arr_m, .f. )
    mywait()
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    If glob_kartotek > 0
      find ( Str( glob_kartotek, 7 ) )
      If Found()
        rec := tmp->( RecNo() )
      Endif
    Endif
    Set Relation To kod_k into KART
    Index On Upper( kart->fio ) to ( cur_dir() + "tmp" )
    Private ;
      blk_open := {|| dbCloseAll(), ;
      r_use( dir_server() + "uslugi",, "USL" ), ;
      r_use( dir_server() + "human_u_",, "HU_" ), ;
      r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" ), ;
      dbSetRelation( "HU_", {|| RecNo() }, "recno()" ), ;
      r_use( dir_server() + "human_",, "HUMAN_" ), ;
      r_use( dir_server() + "human",, "HUMAN" ), ;
      dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
      r_use( dir_server() + "kartote_",, "KART_" ), ;
      r_use( dir_server() + "kartotek",, "KART" ), ;
      dbSetRelation( "KART_", {|| RecNo() }, "recno()" ), ;
      r_use( cur_dir() + "tmp", cur_dir() + "tmp" ), ;
      dbSetRelation( "KART", {|| kod_k }, "kod_k" );
      }
    Eval( blk_open )
    Go Top
    If rec > 0
      Goto ( rec )
    Endif
    t_arr[ BR_TOP ] := T_ROW
    t_arr[ BR_BOTTOM ] := 23
    t_arr[ BR_LEFT ] := 0
    t_arr[ BR_RIGHT ] := 79
    t_arr[ BR_TITUL ] := "Взрослое население " + arr_m[ 4 ]
    t_arr[ BR_TITUL_COLOR ] := "B/BG"
    t_arr[ BR_COLOR ] := color0
    t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B,RB/BG,W+/RB", .t. }
    blk := {|| iif( emptyall( tmp->kod1h, tmp->kod2h ), { 5, 6 }, iif( Empty( tmp->kod2h ), { 1, 2 }, { 3, 4 } ) ) }
    t_arr[ BR_COLUMN ] := { { " Ф.И.О.",     {|| PadR( kart->fio, 39 ) }, blk }, ;
      { "Дата рожд.",  {|| full_date( kart->date_r ) }, blk }, ;
      { "№ ам.карты",  {|| PadR( __f_131_u( 1 ), 10 ) }, blk }, ;
      { "Сроки леч-я", {|| PadR( __f_131_u( 2 ), 11 ) }, blk }, ;
      { "Этап",        {|| PadR( __f_131_u( 3 ), 4 ) }, blk } }
    t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - распечатать карту учёта дисп-ии (проф.осмотра)" ) }
    t_arr[ BR_EDIT ] := {| nk, ob| f1_131_u( nk, ob, "edit" ) }
    edit_browse( t_arr )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 20.09.15
Static Function __f_131_u( k )

  Local s := "", ie := 1

  If emptyall( tmp->kod1h, tmp->kod2h ) // значит профилактика
    human->( dbGoto( tmp->kod3h ) )
    ie := 3
  Else // диспансеризация
    If Empty( tmp->kod1h ) // почему-то нет первого этапа
      human->( dbGoto( tmp->kod2h ) )
    Else
      human->( dbGoto( tmp->kod1h ) )
    Endif
    If !Empty( tmp->kod2h ) // есть второй этап
      ie := 2
    Endif
  Endif
  If k == 1
    s := human->uch_doc
  Elseif k == 2
    s := Left( date_8( human->n_data ), 5 ) + "-"
    If ie == 2
      human->( dbGoto( tmp->kod2h ) )
    Endif
    s += Left( date_8( human->k_data ), 5 )
  Else
    s := { "I эт", "I-II", "проф" }[ ie ]
  Endif

  Return s

// 27.09.24
Function f1_131_u( nKey, oBrow, regim )

  Static lV := "V", sb1 := "<b><u>", sb2 := "</u></b>"
  Static s_smg := "Не удалось определить группу здоровья"
  Local ret := -1, rec := tmp->( RecNo() ), buf := save_maxrow(), ;
    i, j, k, fl, lshifr, au := {}, ar, metap, m1gruppa, is_disp := .t., ;
    mpol := kart->pol, fl_dispans := .f., adbf, s, y, m, d, arr, ;
    blk := {| s| __dbAppend(), field->stroke := s }

  If regim == "edit" .and. nKey == K_ENTER
    glob_kartotek := tmp->kod_k
    delfrfiles()
    mywait()
    Private arr_otklon := {}, arr_usl_otkaz := {}, mvozrast, mdvozrast, ;
      M1RAB_NERAB, m1veteran := 0, m1mobilbr := 0, ;
      m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0, ;
      m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
      mholest := 0, mglukoza := 0, ;
      m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
      m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0, ;
      m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0, ;
      m1spec_na := 0, m1sank_na := 0, ;
      pole_diag, pole_1pervich, pole_1stadia, pole_1dispans, ;
      mWEIGHT := 0, mHEIGHT := 0, mn_data, mk_data, mk_data1
    For i := 1 To 5
      pole_diag := "mdiag" + lstr( i )
      pole_d_diag := "mddiag" + lstr( i )
      pole_1pervich := "m1pervich" + lstr( i )
      pole_1stadia := "m1stadia" + lstr( i )
      pole_1dispans := "m1dispans" + lstr( i )
      pole_d_dispans := "mddispans" + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_d_diag := CToD( "" )
      Private &pole_1pervich := 0
      Private &pole_1stadia := 0
      Private &pole_1dispans := 0
      Private &pole_d_dispans := CToD( "" )
    Next
    If emptyall( tmp->kod1h, tmp->kod2h ) // значит профилактика
      is_disp := .f.
      human->( dbGoto( tmp->kod3h ) )
      If Between( human_->RSLT_NEW, 343, 345 )
        m1GRUPPA := human_->RSLT_NEW - 342
      Elseif Between( human_->RSLT_NEW, 373, 374 )
        m1GRUPPA := human_->RSLT_NEW - 370
      Endif
      If !Between( m1gruppa, 1, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
    Else // I этап
      If Empty( tmp->kod1h )
        func_error( 4, "Присутствует II этап, но отсутствует I этап" )
        rest_box( buf )
        Return ret
      Endif
      human->( dbGoto( tmp->kod1h ) )
      m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
      If !Between( m1gruppa, 0, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
    Endif
    M1RAB_NERAB := human->RAB_NERAB
    mn_data := human->n_data
    mk_data := mk_data1 := human->k_data
    Private is_disp_19 := !( mk_data < 0d20190501 )
    Private is_disp_21 := !( mk_data < 0d20210101 )
    Private is_disp_24 := !( mk_data < 0d20240901 )
    mdate_r := full_date( human->date_r )
    read_arr_dvn( human->kod )
    ret_arr_vozrast_dvn( mk_data )

    mvozrast := count_years( human->date_r, human->n_data )
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    If m1veteran == 1
      mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
    Endif

    // ret_arrays_disp( is_disp_19, is_disp_21, is_disp_24 )
    ret_arrays_disp( mk_data )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
    Select HU
    find ( Str( human->kod, 7 ) )
    Do While hu->kod == human->kod .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If !eq_any( Left( lshifr, 5 ), "70.3.", "70.7.", "72.1.", "72.5.", "72.6.", "72.7." )
        AAdd( au, { AllTrim( lshifr ), ;
          hu_->PROFIL, ;
          iif( Left( hu_->kod_diag, 1 ) == "Z", "", hu_->kod_diag ), ;
          c4tod( hu->date_u );
          } )
      Endif
      Select HU
      Skip
    Enddo
    k_nev_4_1_12 := 0
    For k := 1 To Len( au )
      lshifr := au[ k, 1 ]
      If is_disp_19
        //
      Elseif ( ( lshifr == "2.3.3" .and. au[ k, 2 ] == 3 ) .or.  ; // акушерскому делу
        ( lshifr == "2.3.1" .and. au[ k, 2 ] == 136 ) )    // акушерству и гинекологии
        k_nev_4_1_12 := k
      Endif
      If AScan( arr_otklon, au[ k, 1 ] ) > 0
        au[ k, 3 ] := "+" // отклонения в исследовании
        If eq_any( lshifr, "4.20.1", "4.20.2" ) // если отклонения в исследовании цитологич.материала
          If ( i := AScan( au, {| x| x[ 1 ] == "4.1.12" } ) ) > 0
            au[ i, 3 ] := "+" // занесём отклонения в осмотр фельдшера "4.1.12"
          Endif
        Endif
      Endif
    Next
    If is_disp_19
      arr_10 := { ;
        { 1, "56.1.16", "Опрос (анкетирование) на выявление хронических неинфекционных заболеваний, факторов риска их развития, потребления наркотических средств и психотропных веществ без назначения врача" }, ;
        { 2, "3.1.19", "Антропометрия (измерение роста стоя, массы тела, окружности талии), расчет индекса массы тела" }, ;
        { 3, "3.1.5", "Измерение артериального давления" }, ;
        { 4, "3.4.9", "Измерение внутриглазного давления" }, ;
        { 5, "4.12.174", "Исследование крови на общий холестерин" }, ;
        { 6, "4.12.169", "Исследование уровня глюкозы в крови" }, ;
        { 7, "4.11.137", "Клинический анализ крови (3 показателя)" }, ;
        { 8, "4.8.4", "Исследование кала на скрытую кровь" }, ;
        { 9, "4.14.66", "Исследование крови на простат-специфический антиген" }, ;
        { 10, { { "2.3.1", 136 }, { "2.3.3", 3 }, { "2.3.3", 42 } }, "Осмотр акушеркой или акушером-гинекологом" }, ;
        { 11, { "4.1.12", "4.20.1", "4.20.2" }, "Взятие мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование" }, ;
        { 12, "7.57.3", "Маммография обеих молочных желез" }, ;
        { 13, "7.61.3", "Флюорография лёгких профилактическая" }, ;
        { 14, "13.1.1", "Электрокардиография (в покое)" }, ;
        { 15, "10.3.13", "Фиброэзофагогастродуоденоскопия" }, ;
        { 16, "56.1.18", "Определение относительного суммарного сердечно-сосудистого риска", "mdvozrast < 40" }, ;
        { 17, "56.1.19", "Определение абсолютного суммарного сердечно-сосудистого риска", "39 < mdvozrast .and. mdvozrast < 65" }, ;
        { 18, "56.1.14", "Краткое индивидуальное профилактическое консультирование" }, ;
        { 19, { { "2.3.7", 57 }, { "2.3.7", 97 }, { "2.3.2", 57 }, { "2.3.2", 97 }, { "2.3.4", 42 } }, "Прием (осмотр) врача-терапевта" };
        }
    Else
      arr_10 := { ;
        { 1, "56.1.16", "Опрос (анкетирование) на выявление хронических неинфекционных заболеваний, факторов риска их развития, потребления наркотических средств и психотропных веществ без назначения врача" }, ;
        { 2, "3.1.19", "Антропометрия (измерение роста стоя, массы тела, окружности талии), расчет индекса массы тела" }, ;
        { 3, "3.1.5", "Измерение артериального давления" }, ;
        { 4, "4.12.174", "Определение уровня общего холестерина в крови" }, ;
        { 5, "4.12.169", "Определение уровня глюкозы в крови экспресс-методом" }, ;
        { 6, { "56.1.17", "56.1.18" }, "Определение относительного суммарного сердечно-сосудистого риска", "mdvozrast < 40" }, ;
        { 7, { "56.1.17", "56.1.19" }, "Определение абсолютного суммарного сердечно-сосудистого риска", "39 < mdvozrast .and. mdvozrast < 66" }, ;
        { 8, "13.1.1", "Электрокардиография (в покое)" }, ;
        { 9, { "4.1.12", "4.20.1", "4.20.2" }, "Осмотр фельдшером (акушеркой), включая взятие мазка (соскоба) с поверхности шейки матки (наружного маточного зева) и цервикального канала на цитологическое исследование" }, ;
        { 10, "7.61.3", "Флюорография легких" }, ;
        { 11, "7.57.3", "Маммография обеих молочных желез" }, ;
        { 12, "4.11.137", "Клинический анализ крови" }, ;
        { 13, "4.11.136", "Клинический анализ крови развернутый" }, ;
        { 14, "4.12.172", "Анализ крови биохимический общетерапевтический" }, ;
        { 15, "4.2.153", "Общий анализ мочи" }, ;
        { 16, "4.8.4", "Исследование кала на скрытую кровь иммунохимическим методом" }, ;
        { 17, { "8.2.1", "8.2.4", "8.2.5" }, "Ультразвуковое исследование (УЗИ) на предмет исключения новообразований органов брюшной полости, малого таза" }, ;
        { 18, "8.1.5", "Ультразвуковое исследование (УЗИ) в целях исключения аневризмы брюшной аорты" }, ;
        { 19, "3.4.9", "Измерение внутриглазного давления" }, ;
        { 20, { { "2.3.1", 97 }, { "2.3.1", 57 }, { "2.3.2", 97 }, { "2.3.2", 57 }, { "2.3.3", 42 }, { "2.3.5", 57 }, { "2.3.5", 97 }, { "2.3.6", 57 }, { "2.3.6", 97 } }, "Прием (осмотр) врача-терапевта" };
        }
      If is_disp .and. Year( mk_data ) > 2017 // с 18 года
        arr_10[ 13 ] := { 13, "4.14.66", "Исследование крови на простат-специфический антиген" }
        del_array( arr_10, 18 )
        del_array( arr_10, 17 )
        del_array( arr_10, 15 )
        del_array( arr_10, 14 )
      Endif
    Endif
    dbCreate( fr_data, { { "name", "C", 200, 0 }, ;
      { "ns", "N", 2, 0 }, ;
      { "vv", "C", 10, 0 }, ;
      { "vo", "C", 10, 0 }, ;
      { "vd", "C", 20, 0 } } )
    Use ( fr_data ) New Alias FRD
    For n := 1 To Len( arr_10 )
      Append Blank
      frd->name := arr_10[ n, 3 ]
      frd->ns := arr_10[ n, 1 ]
    Next
    Index On Str( ns, 2 ) To tmp_frd
    For i := 1 To Len( arr_10 )
      fl := fl_nev := .f. ;  date_o := CToD( "" )
      If ValType( arr_usl_otkaz ) == "A"
        For k1 := 1 To Len( arr_usl_otkaz )
          ar := arr_usl_otkaz[ k1 ]
          If ValType( ar ) == "A" .and. Len( ar ) >= 10 .and. ValType( ar[ 5 ] ) == "C" ;
              .and. ValType( ar[ 10 ] ) == "N" .and. Between( ar[ 10 ], 1, 2 )
            lshifr := AllTrim( ar[ 5 ] )
            If ValType( arr_10[ i, 2 ] ) == "C"
              If lshifr == arr_10[ i, 2 ]
                fl := .t.
                If ar[ 10 ] == 1 // отказ
                  date_o := ar[ 9 ]
                Else // невозможность
                  fl_nev := .t.
                Endif
              Endif
            Elseif ValType( arr_10[ i, 2, 1 ] ) == "C" // шифры в массиве
              For j := 1 To Len( arr_10[ i, 2 ] )
                If lshifr == arr_10[ i, 2, j ]
                  fl := .t.
                  If ar[ 10 ] == 1 // отказ
                    date_o := ar[ 9 ]
                  Else // невозможность
                    fl_nev := .t.
                  Endif
                  Exit
                Endif
              Next
            Else
              For j := 1 To Len( arr_10[ i, 2 ] )
                If lshifr == arr_10[ i, 2, j, 1 ] .and. ar[ 4 ] == arr_10[ i, 2, j, 2 ]
                  fl := .t.
                  If ar[ 10 ] == 1 // отказ
                    date_o := ar[ 9 ]
                  Else // невозможность
                    fl_nev := .t.
                  Endif
                  Exit
                Endif
              Next
            Endif
          Endif
          If fl ; exit ; Endif
        Next
      Endif
      If !fl
        If ValType( arr_10[ i, 2 ] ) == "C" // один шифр
          If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2 ] } ) ) > 0
            fl := .t.
          Endif
        Elseif ValType( arr_10[ i, 2, 1 ] ) == "C" // шифры в массиве
          For j := 1 To Len( arr_10[ i, 2 ] )
            If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2, j ] } ) ) > 0
              fl := .t. ; Exit
            Endif
          Next
        Else // в массиве пары: шифр и профиль
          For j := 1 To Len( arr_10[ i, 2 ] )
            If ( k := AScan( au, {| x| x[ 1 ] == arr_10[ i, 2, j, 1 ] .and. x[ 2 ] == arr_10[ i, 2, j, 2 ] } ) ) > 0
              fl := .t. ; Exit
            Endif
          Next
        Endif
      Endif
      If fl .and. Len( arr_10[ i ] ) > 3
        fl := &( arr_10[ i, 4 ] )
      Endif
      If fl
        find ( Str( arr_10[ i, 1 ], 2 ) )
        If ValType( arr_10[ i, 2 ] ) == "A" .and. ValType( arr_10[ i, 2, 1 ] ) == "C" ;
            .and. arr_10[ i, 2, 1 ] == "4.1.12" .and. k_nev_4_1_12 > 0
          frd->vv := full_date( au[ k_nev_4_1_12, 4 ] )
          frd->vd := "невозможно"
        Elseif fl_nev
          frd->vv := "невозможно"
        Elseif !Empty( date_o )
          frd->vv := "отказ"
          frd->vo := full_date( date_o )
        Else
          frd->vv := full_date( au[ k, 4 ] )
          If au[ k, 4 ] < human->n_data
            frd->vo := full_date( au[ k, 4 ] )
          Endif
          frd->vd := iif( Empty( au[ k, 3 ] ), "-", "<b>" + au[ k, 3 ] + "</b>" )
        Endif
      Endif
    Next
    Select FRD
    Set Index To
    Go Top
    Do While !Eof()
      If emptyall( frd->vv, frd->vd, frd->vo )
        Delete
      Endif
      Skip
    Enddo
    Pack
    n := 0
    Go Top
    Do While !Eof()
      frd->ns := ++n
      Skip
    Enddo
    //
    adbf := { { "titul", "C", 50, 0 }, ;
      { "titul2", "C", 50, 0 }, ;
      { "fio", "C", 100, 0 }, ;
      { "fio2", "C", 60, 0 }, ;
      { "pol", "C", 50, 0 }, ;
      { "date_r", "C", 10, 0 }, ;
      { "d_dr", "C", 2, 0 }, ;
      { "m_dr", "C", 2, 0 }, ;
      { "y_dr", "C", 4, 0 }, ;
      { "vozrast", "N", 4, 0 }, ;
      { "subekt", "C", 50, 0 }, ;
      { "rajon", "C", 50, 0 }, ;
      { "gorod", "C", 50, 0 }, ;
      { "nas_p", "C", 50, 0 }, ;
      { "adres", "C", 200, 0 }, ;
      { "gorod_selo", "C", 50, 0 }, ;
      { "kod_lgot", "C", 2, 0 }, ;
      { "sever", "C", 30, 0 }, ;
      { "zanyat", "C", 200, 0 }, ;
      { "mobil", "C", 30, 0 }, ;
      { "n_data", "C", 10, 0 }, ;
      { "k_data", "C", 10, 0 }, ;
      { "v13_1", "C", 10, 0 }, ;
      { "v13_2", "C", 10, 0 }, ;
      { "v13_3", "C", 10, 0 }, ;
      { "v13_4", "C", 10, 0 }, ;
      { "v13_5", "C", 10, 0 }, ;
      { "v13_6", "C", 10, 0 }, ;
      { "v13_7", "C", 10, 0 }, ;
      { "v13_8", "C", 10, 0 }, ;
      { "v13_9", "C", 10, 0 }, ;
      { "v14", "C", 2, 0 }, ;
      { "v14_1", "C", 1, 0 }, ;
      { "v14_2", "C", 1, 0 }, ;
      { "v15", "C", 2, 0 }, ;
      { "v15_1", "C", 1, 0 }, ;
      { "v15_2", "C", 1, 0 }, ;
      { "v16_1", "C", 1, 0 }, ;
      { "v16_2", "C", 1, 0 }, ;
      { "v16_3", "C", 1, 0 }, ;
      { "v16_4", "C", 1, 0 }, ;
      { "v17", "C", 30, 0 }, ;
      { "v18", "C", 30, 0 }, ;
      { "v18_1", "C", 30, 0 }, ;
      { "v18_2", "C", 30, 0 }, ;
      { "v19", "C", 30, 0 }, ;
      { "v20", "C", 30, 0 }, ;
      { "vrach", "C", 100, 0 } }
    dbCreate( fr_titl, adbf )
    Use ( fr_titl ) New Alias FRT
    Append Blank
    frt->titul := iif( !emptyall( tmp->kod1h, tmp->kod2h ), "диспансеризации", "профилактического медицинского осмотра" )
    frt->titul2 := iif( !emptyall( tmp->kod1h, tmp->kod2h ), "Диспансеризация", "Профилактический медицинский осмотр" )
    arr := retfamimot( 1, .f. )
    frt->fio2 := arr[ 1 ] + " " + arr[ 2 ] + " " + arr[ 3 ]
    frt->fio := Expand( Upper( RTrim( frt->fio2 ) ) )
    frt->pol := iif( kart->pol == "М", sb1 + "муж. - 1" + sb2 + ", жен. - 2", "муж. - 1, " + sb1 + "жен. - 2" + sb2 )
    frt->date_r := mdate_r
    frt->d_dr := SubStr( mdate_r, 1, 2 )
    frt->m_dr := SubStr( mdate_r, 4, 2 )
    frt->y_dr := SubStr( mdate_r, 7, 4 )
    frt->vozrast := mvozrast
    If f_is_selo()
      frt->gorod_selo := "городская - 1, " + sb1 + "сельская - 2" + sb2
    Else
      frt->gorod_selo := sb1 + "городская - 1" + sb2 + ", сельская - 2"
    Endif
    arr := ret_okato_array( kart_->okatog )
    frt->subekt := arr[ 1 ]
    frt->rajon  := arr[ 2 ]
    frt->gorod  := arr[ 3 ]
    frt->nas_p  := arr[ 4 ]
    If Empty( kart->adres )
      frt->adres := "улица" + sb1 + Space( 30 ) + sb2 + " дом" + sb1 + Space( 5 ) + sb2 + " квартира" + sb1 + Space( 5 ) + sb2
    Else
      frt->adres := sb1 + PadR( kart->adres, 60 ) + sb2
    Endif
    If ( i := AScan( stm_kategor, {| x| x[ 2 ] == kart_->kategor } ) ) > 0 .and. Between( stm_kategor[ i, 3 ], 1, 8 )
      frt->kod_lgot := lstr( stm_kategor[ i, 3 ] )
    Endif
    frt->mobil := f_131_u_da_net( m1mobilbr, sb1, sb2 )
    frt->n_data := full_date( mn_data )
    frt->v13_1 := iif( mad1 > 140 .and. mad2 > 90, frt->n_data, "-" )
    frt->v13_2 := iif( m1glukozadn == 1 .or. mglukoza > 6.1, frt->n_data, "-" )
    frt->v13_3 := iif( m1tip_mas >= 3, frt->n_data, "-" )
    frt->v13_4 := iif( m1kurenie == 1, frt->n_data, "-" )
    frt->v13_5 := iif( m1riskalk == 1, frt->n_data, "-" )
    frt->v13_6 := iif( m1pod_alk == 1, frt->n_data, "-" )
    frt->v13_7 := iif( m1fiz_akt == 1, frt->n_data, "-" )
    frt->v13_8 := iif( m1ner_pit == 1, frt->n_data, "-" )
    frt->v13_9 := iif( m1ot_nasl1 == 1 .or. m1ot_nasl2 == 1 .or. m1ot_nasl3 == 1 .or. m1ot_nasl4 == 1, frt->n_data, "-" )
    If mdvozrast < 66
      If mdvozrast > 39
        frt->v15 := lstr( mssr )
        If 5 <= mssr .and. mssr < 10 // Высокий абс.суммарный сердечно-сосудистый риск
          frt->v15_1 := lV
        Elseif mssr >= 10 // Очень высокий абс.суммарный сердечно-сосудистый риск
          frt->v16_2 := lV
        Endif
      Else
        frt->v14 := lstr( mssr )
        If mssr < 1 // низкий отн.суммарный сердечно-сосудистый риск
          frt->v14_1 := lV
        Elseif 5 <= mssr .and. mssr < 10 // низкий отн.суммарный сердечно-сосудистый риск
          frt->v14_2 := lV
        Endif
      Endif
    Endif
    dbCreate( fr_data + "1", { { "name", "C", 200, 0 }, ;
      { "ns", "N", 2, 0 }, ;
      { "vn", "C", 10, 0 }, ;
      { "vv", "C", 10, 0 }, ;
      { "vd", "C", 20, 0 } } )
    If !Empty( tmp->kod2h ) // II этап
      human->( dbGoto( tmp->kod2h ) )
      M1RAB_NERAB := human->RAB_NERAB
      mk_data := human->k_data
      is_disp_19 := !( mk_data < 0d20190501 )
      m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
      If !Between( m1gruppa, 1, 4 )
        m1GRUPPA := 0 ; func_error( 4, s_smg )
      Endif
      read_arr_dvn( human->kod )
      //
      Select HU
      find ( Str( human->kod, 7 ) )
      Do While hu->kod == human->kod .and. !Eof()
        usl->( dbGoto( hu->u_kod ) )
        If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
          lshifr := usl->shifr
        Endif
        AAdd( au, { AllTrim( lshifr ), ;
          hu_->PROFIL, ;
          iif( Left( hu_->kod_diag, 1 ) == "Z", "", hu_->kod_diag ), ;
          c4tod( hu->date_u );
          } )
        Select HU
        Skip
      Enddo
      For k := 1 To Len( au )
        If AScan( arr_otklon, au[ k, 1 ] ) > 0
          au[ k, 3 ] := "+" // отклонения в исследовании
        Endif
      Next
      If is_disp_19
        arr_11 := { ;
          { 1, "Дуплексное сканирование брахиоцефальных артерий", "8.23.706" }, ;
          { 2, "Рентгенография органов грудной клетки", "7.2.702" }, ;
          { 3, "КТ органов грудной полости", "7.2.701" }, ;
          { 4, "Спиральная КТ легких", "7.2.703" }, ;
          { 5, "КТ органов грудной полости (с контрастир-ием)", "7.2.704" }, ;
          { 6, "Однофотонная эмиссионная КТ легких", "7.2.705" }, ;
          { 7, "Ректосигмоколоноскопия диагностическая", "10.6.710" }, ;
          { 8, "Ректороманоскопия", "10.4.701" }, ;
          { 9, "Фиброэзофагогастродуоденоскопия", "10.3.713" }, ;
          { 10, "Спирометрия", "16.1.717" }, ;
          { 11, "Осмотр (консультация) врачом-неврологом", "2.84.1" }, ;
          { 12, "Осмотр (консультация) врачом-хирургом или врачом-урологом", "2.84.10" }, ;
          { 13, "Осмотр (консультация) врачом-хирургом или врачом-колопроктологом", "2.84.6" }, ;
          { 14, "Осмотр (консультация) врачом-акушером-гинекологом", "2.84.5" }, ;
          { 15, "Осмотр (консультация) врачом-оториноларингологом", "2.84.8" }, ;
          { 16, "Осмотр (консультация) врачом-офтальмологом", "2.84.3" }, ;
          { 17, "Углубленное профилактическое консультирование", "56.1.723" }, ;
          { 18, "Прием (осмотр) врача-терапевта", "2.84.11" };
          }
      Else
        arr_11 := { ;
          { 1, "Дуплексное сканирование брахиоцефальных артерий", { "8.23.6", "8.23.706" } }, ;
          { 2, "Осмотр (консультация) врачом-неврологом", "2.84.1" }, ;
          { 3, "Эзофагогастродуоденоскопия", "10.3.13" }, ;
          { 4, "Осмотр (консультация) врачом-хирургом или врачом-урологом", "2.84.10" }, ;
          { 5, "Осмотр (консультация) врачом-хирургом или врачом-колопроктологом", "2.84.6" }, ;
          { 6, "Колоноскопия или ректороманоскопия", { "10.4.1", "10.6.10" } }, ;
          { 7, "Определение липидного спектра крови", "4.12.173" }, ;
          { 8, "Спирометрия", { "16.1.17", "16.1.717" } }, ;
          { 9, "Осмотр (консультация) врачом-акушером-гинекологом", "2.84.5" }, ;
          { 10, "Определение концентрации гликированного гемоглобина в крови или тест на толерантность к глюкозе", { "4.12.170", "4.12.171" } }, ;
          { 11, "Осмотр (консультация) врачом-оториноларингологом", "2.84.8" }, ;
          { 12, "Анализ крови на уровень содержания простатспецифического антигена", "4.14.66" }, ;
          { 13, "Осмотр (консультация) врачом-офтальмологом", "2.84.3" }, ;
          { 14, "Индивидуальное углубленное профилактическое консультирование", { "56.1.15", "56.1.20" } }, ;
          { 15, "Групповое профилактическое консультирование (школа пациента)", "0" }, ;
          { 16, "Прием (осмотр) врача-терапевта", { "2.84.2", "2.84.7", "2.84.9", "2.84.11" } };
          }
        If is_disp .and. Year( mk_data ) > 2017 // с 18 года
          arr_11[ 6 ] := { 6, "Ректосигмоколоноскопия диагностическая", "10.6.710" }
          arr_11[ 14 ] := { 14, "Индивидуальное или групповое (школа для пациента) углубленное профилактическое консультирование", "56.1.723" }
          del_array( arr_11, 15 )
          del_array( arr_11, 12 )
          del_array( arr_11, 10 )
          del_array( arr_11, 7 )
          del_array( arr_11, 3 )
        Endif
      Endif
      Use ( fr_data + "1" ) New Alias FRD1
      For n := 1 To Len( arr_11 )
        Append Blank
        frd1->name := arr_11[ n, 2 ]
        frd1->ns := arr_11[ n, 1 ]
      Next
      Index On Str( ns, 2 ) To tmp_frd1
      For k := 1 To Len( au )
        fl := .f.
        For i := 1 To Len( arr_11 )
          If ValType( arr_11[ i, 3 ] ) == "A"
            fl := ( AScan( arr_11[ i, 3 ], au[ k, 1 ] ) > 0 )
          Else
            fl := ( au[ k, 1 ] == arr_11[ i, 3 ] )
          Endif
          If fl ; exit ; Endif
        Next
        If fl
          find ( Str( arr_11[ i, 1 ], 2 ) )
          frd1->vn := full_date( mk_data1 )
          frd1->vv := full_date( au[ k, 4 ] )
          frd1->vd := iif( Empty( au[ k, 3 ] ), "-", "<b>" + au[ k, 3 ] + "</b>" )
        Endif
      Next
      Select FRD1
      Set Index To
      Go Top
      Do While !Eof()
        If emptyall( frd1->vv, frd1->vd, frd1->vn )
          Delete
        Endif
        Skip
      Enddo
      Pack
      n := 0
      Go Top
      Do While !Eof()
        frd1->ns := ++n
        Skip
      Enddo
    Endif
    frt->k_data := full_date( mk_data )
    frt->zanyat := iif( M1RAB_NERAB == 0, sb1, "" ) + "1 - работает" + iif( M1RAB_NERAB == 0, sb2, "" ) + ";  " + ;
      iif( M1RAB_NERAB == 1, sb1, "" ) + "2 - не работает" + iif( M1RAB_NERAB == 1, sb2, "" ) + ";  " + ;
      iif( M1RAB_NERAB == 2, "<u>", "" ) + "3 - обучающийся в образовательной организации по очной форме" + iif( M1RAB_NERAB == 2, "</u>", "" ) + "."
    frt->sever := f_131_u_da_net( 0, sb1, sb2 )
    Do Case
    Case m1gruppa == 1
      frt->v16_1 := lV
    Case m1gruppa == 2
      frt->v16_2 := lV
    Case m1gruppa == 3
      frt->v16_3 := lV
    Case m1gruppa == 4
      frt->v16_4 := lV
    Endcase
    frt->v17   := f_131_u_da_net( m1nazn_l, sb1, sb2 )
    frt->v18   := f_131_u_da_net( m1dopo_na, sb1, sb2 )
    frt->v18_1 := f_131_u_da_net( m1ssh_na, sb1, sb2 )
    frt->v18_2 := f_131_u_da_net( m1psih_na, sb1, sb2 )
    frt->v19   := f_131_u_da_net( m1spec_na, sb1, sb2 )
    frt->v20   := f_131_u_da_net( m1sank_na, sb1, sb2 )
    r_use( dir_server() + "mo_pers",, "P2" )
    Goto ( human_->vrach )
    frt->vrach := p2->fio
    //
    arr_12 := { ;
      { 7, "1", "Некоторые инфекционные и паразитарные болезни", "A00-B99" }, ;
      { 8, "1.1", "  в том числе: туберкулез", "A15-A19" }, ;
      { 9, "2", "Новообразования", "C00-D48" }, ;
      { 10, "2.1", "в том числе: злокачественные новообразования и новообразования in situ", "C00-D09" }, ;
      { 11, "2.2", "в том числе: пищевода", "C15,D00.1" }, ;
      { 12, "2.2.1", " из них в 1-2 стадии", "C15,D00.1", "1" }, ;
      { 13, "2.3", "желудка", "C16,D00.2" }, ;
      { 14, "2.3.1", " из них в 1-2 стадии", "C16,D00.2", "1" }, ;
      { 15, "2.4", "ободочной кишки", "C18,D01.0" }, ;
      { 16, "2.4.1", " из них в 1-2 стадии", "C18,D01.0", "1" }, ;
      { 17, "2.5", "ректосигмоидного соединения, прямой кишки, заднего прохода (ануса) и анального канала", "C19-C21,D01.1-D01.3" }, ;
      { 18, "2.5.1", " из них в 1-2 стадии", "C19-C21,D01.1-D01.3", "1" }, ;
      { 19, "2.6", "поджелудочной железы", "C25" }, ;
      { 20, "2.6.1", " из них в 1-2 стадии", "C25", "1" }, ;
      { 21, "2.7", "трахеи, бронхов и легкого", "C33,C34,D02.1-D02.2" }, ;
      { 22, "2.7.1", " из них в 1-2 стадии", "C33,C34,D02.1-D02.2", "1" }, ;
      { 23, "2.8", "молочной железы", "C50,D05" }, ;
      { 24, "2.8.1", " из них в 1-2 стадии", "C50,D05", "1" }, ;
      { 25, "2.9", "шейки матки", "C53,D06" }, ;
      { 26, "2.9.1", " из них в 1-2 стадии", "C53,D06", "1" }, ;
      { 27, "2.10", "тела матки", "C54" }, ;
      { 28, "2.10.1", " из них в 1-2 стадии", "C54", "1" }, ;
      { 29, "2.11", "яичника", "C56" }, ;
      { 30, "2.11.1", " из них в 1-2 стадии", "C56", "1" }, ;
      { 31, "2.12", "предстательной железы", "C61,D07.5" }, ;
      { 32, "2.12.1", " из них в 1-2 стадии", "C61,D07.5", "1" }, ;
      { 33, "2.13", "почки, кроме почечной лоханки", "C64" }, ;
      { 34, "2.13.1", " из них в 1-2 стадии", "C64", "1" }, ;
      { 35, "3", "Болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм", "D50-D89" }, ;
      { 36, "3.1", "в том числе: анемии, связанные с питанием, гемолитические анемии, апластические и другие анемии", "D50-D64" }, ;
      { 37, "4", "Болезни эндокринной системы, расстройства питания и нарушения обмена веществ", "E00-E90" }, ;
      { 38, "4.1", "в том числе: сахарный диабет", "E10-E14" }, ;
      { 39, "4.2", "ожирение", "E66" }, ;
      { 40, "4.3", "нарушения обмена липопротеинов и другие липидемии", "E78" }, ;
      { 41, "5", "Болезни нервной системы", "G00-G99" }, ;
      { 42, "5.1", "в том числе: преходящие церебральные ишемические приступы [атаки] и родственные синдромы", "G45" }, ;
      { 43, "6", "Болезни глаза и его придаточного аппарата", "H00-H59" }, ;
      { 44, "6.1", "в том числе: старческая катаракта и другие катаракты", "H25,H26" }, ;
      { 45, "6.2", "глаукома", "H40" }, ;
      { 46, "6.3", "слепота и пониженное зрение", "H54" }, ;
      { 47, "7", "Болезни системы кровообращения", "I00-I99" }, ;
      { 48, "7.1", "в том числе: болезни, характеризующиеся повышенным кровяным давлением", "I10-I15" }, ;
      { 49, "7.2", "ишемическая болезнь сердца", "I20-I25" }, ;
      { 50, "7.2.1", "в том числе: стенокардия (грудная жаба)", "I20" }, ;
      { 51, "7.2.2", "в том числе нестабильная стенокардия", "I20.0" }, ;
      { 52, "7.2.3", "хроническая ишемическая болезнь сердца", "I25" }, ;
      { 53, "7.2.4", "в том числе: перенесенный в прошлом инфаркт миокарда", "I25.2" }, ;
      { 54, "7.3", "другие болезни сердца", "I30-I52" }, ;
      { 55, "7.4", "цереброваскулярные болезни", "I60-I69" }, ;
      { 56, "7.4.1", "в том числе: закупорка и стеноз прецеребральных артерий, не приводящие к инфаркту мозга, и закупорка и стеноз церебральных артерий, не приводящие к инфаркту мозга", "I65,I66" }, ;
      { 57, "7.4.2", "другие цереброваскулярные болезни", "I67" }, ;
      { 58, "7.4.3", "последствия субарахноидального кровоизлияния, последствия внутричерепного кровоизлияния, последствия другого нетравматического внутричерепного кровоизлияния, последствия инфаркта мозга, последствия инсульта, не уточненные как кровоизлияние или инфаркт мозга", "I69.0-I69.4" }, ;
      { 59, "7.4.4", "аневризма брюшной аорты", "I71.3-I71.4" }, ;
      { 60, "8", "Болезни органов дыхания", "J00-J98" }, ;
      { 61, "8.1", "в том числе: вирусная пневмония, пневмония, вызванная Streptococcus pneumonia, пневмония, вызванная Haemophilus influenza, бактериальная пневмония, пневмония, вызванная другими инфекционными возбудителями, пневмония при болезнях, классифицированных в других рубриках, пневмония без уточнения возбудителя", "J12-J18" }, ;
      { 62, "8.2", "бронхит, не уточненный как острый и хронический, простой и слизисто-гнойный хронический бронхит, хронический бронхит неуточненный, эмфизема", "J40-J43" }, ;
      { 63, "8.3", "другая хроническая обструктивная легочная болезнь, астма, астматический статус, бронхоэктатическая болезнь", "J44-J47" }, ;
      { 64, "9", "Болезни органов пищеварения", "K00-K93" }, ;
      { 65, "9.1", "в том числе: язва желудка, язва двенадцатиперстной кишки", "K25,K26" }, ;
      { 66, "9.2", "гастрит и дуоденит", "K29" }, ;
      { 67, "9.3", "неинфекционный энтерит и колит", "K50-K52" }, ;
      { 68, "9.4", "другие болезни кишечника", "K55-K63" }, ;
      { 69, "10", "Болезни мочеполовой системы", "N00-N99" }, ;
      { 70, "10.1", "в том числе: гиперплазия предстательной железы, воспалительные болезни предстательной железы, другие болезни предстательной железы", "N40-N42" }, ;
      { 71, "10.2", "доброкачественная дисплазия молочной железы", "N60" }, ;
      { 72, "10.3", "воспалительные болезни женских тазовых органов", "N70-N77" }, ;
      { 73, "11", "Прочие заболевания", "" };
      }
    len12 := Len( arr_12 )
    diag12 := Array( len12 )
    dbCreate( fr_data + "2", { { "name", "C", 350, 0 }, ;
      { "diagnoz", "C", 50, 0 }, ;
      { "ns", "N", 2, 0 }, ;
      { "stroke", "C", 8, 0 }, ;
      { "vz", "C", 10, 0 }, ;
      { "v1", "C", 10, 0 }, ;
      { "vd", "C", 10, 0 }, ;
      { "vp", "C", 10, 0 } } )
    Use ( fr_data + "2" ) New Alias FRD2
    For n := 1 To len12
      Append Blank
      frd2->name := iif( "." $ arr_12[ n, 2 ], "", "<b>" ) + arr_12[ n, 3 ] + iif( "." $ arr_12[ n, 2 ], "", "</b>" )
      frd2->ns := n
      frd2->stroke := arr_12[ n, 2 ]
      If Len( arr_12[ n ] ) < 5
        frd2->diagnoz := arr_12[ n, 4 ]
      Endif
      s2 := arr_12[ n, 4 ]
      If Len( arr_12[ n ] ) > 4
        frd2->vp := "-"
      Endif
      diag12[ n ] := {}
      For i := 1 To NumToken( s2, "," )
        s3 := Token( s2, ",", i )
        If "-" $ s3
          d1 := Token( s3, "-", 1 )
          d2 := Token( s3, "-", 2 )
        Else
          d1 := d2 := s3
        Endif
        AAdd( diag12[ n ], { diag_to_num( d1, 1 ), diag_to_num( d2, 2 ) } )
      Next
    Next
    For i := 1 To 5
      pole_diag := "mdiag" + lstr( i )
      pole_d_diag := "mddiag" + lstr( i )
      pole_1pervich := "m1pervich" + lstr( i )
      pole_1stadia := "m1stadia" + lstr( i )
      pole_1dispans := "m1dispans" + lstr( i )
      pole_d_dispans := "mddispans" + lstr( i )
      If !Empty( &pole_diag ) .and. !( Left( &pole_diag, 1 ) == "Z" )
        au := {}
        d := diag_to_num( &pole_diag, 1 )
        For n := 1 To len12
          r := diag12[ n ]
          For j := 1 To Len( r )
            fl := Between( d, r[ j, 1 ], r[ j, 2 ] )
            If fl .and. Len( arr_12[ n ] ) > 4 // надо проверить стадию
              If human->k_data < 0d20150401 // до 1.04.2015
                fl := ( &pole_1stadia == 0 ) // ранняя
              Else
                fl := ( &pole_1stadia < 3 ) // 1 и 2 стадия
              Endif
            Endif
            If fl
              AAdd( au, n )
            Endif
          Next
        Next
        If Empty( au ) // заносим в прочие заболевания
          AAdd( au, len12 )
        Endif
        For j := 1 To Len( au )
          Goto ( au[ j ] )
          if &pole_1pervich == 1 // впервые
            frd2->vz := frd2->v1 := frt->k_data // дата приёма терапевта
            if &pole_1dispans == 1
              frd2->vd := frt->k_data
            Endif
          elseif &pole_1pervich == 0 // ранее выявленный
            frd2->vz := full_date( &pole_d_diag )
            if &pole_1dispans == 1
              frd2->vd := iif( Empty( &pole_d_dispans ), frd2->vz, full_date( &pole_d_dispans ) )
            Endif
          Else // предварительный диагноз
            If Empty( frd2->vp )
              frd2->vp := frt->k_data
            Endif
          Endif
        Next
      Endif
    Next
    Close databases
    call_fr( "mo_131_u" ) // печать
    Close databases
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 01.07.17
Static Function f_131_u_da_net( k, sb1, sb2 )

  If k > 1 ; k := 1 ; Endif // если вместо "да" битовый ответ

  Return f3_inf_dds_karta( { { "да - 1", 1 }, { "нет - 2", 0 } }, k, ";  ", sb1, sb2, .f. )

// 28.05.24 Приложение к Приказу ГБУЗ "ВОМИАЦ" от 12.05.2017г. №1615
Function f21_inf_dvn( par ) // свод

  Local arr_m, buf := save_maxrow(), s, as := {}, as1[ 14 ], i, j, k, n, ar, at, ii, g1, sh := 65, fl, mdvozrast, adbf
  Local kol_2_year_dvn := 0, kol_2_year_prof := 0
  Local kol_2_year_dvn_40 := 0, kol_2_year_prof_40 := 0

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != Nil .and. f0_inf_dvn( arr_m, par > 1, par == 3, .t. )
    Private arr_usl_bio := { { ;
      "A11.20.010", ;// Биопсия молочной железы чрескожная
      "A11.20.010.001", ;// Биопсия новообразования молочной железы прицельная пункционная под контролем рентгенографического исследования
      "A11.20.010.002", ;// Биопсия новообразования молочной железы аспирационная вакуумная под контролем рентгенографического исследования
      "A11.20.010.004" ;// Биопсия непальпируемых новообразования молочной железы аспирационная вакуумная под контролем ультразвукового исследования
    }, ;
    { ;
      "A11.18.001", ;// Биопсия ободочной кишки эндоскопическая
      "A11.18.002", ;// Биопсия ободочной кишки оперативная
      "A11.19.001", ;// Биопсия сигмовидной кишки с помощью видеоэндоскопических технологий
      "A11.19.002", ;// Биопсия прямой кишки с помощью видеоэндоскопических технологий
      "A11.19.003", ;// Биопсия ануса и перианальной области
      "A11.19.009" ;// Биопсия толстой кишки при лапароскопии
    }, ;
    { ;
      "A11.20.011", ;// Биопсия шейки матки
      "A11.20.011.001", ;// Биопсия шейки матки радиоволновая
      "A11.20.011.002", ;// Биопсия шейки матки радиоволновая конусовидная
      "A11.20.011.003" ;// Биопсия шейки матки ножевая
    }, ;
    { ;
      "A11.01.001", ;// Биопсия кожи
      "A11.07.001", ;// Биопсия слизистой полости рта
      "A11.07.002", ;// Биопсия языка
      "A11.07.003", ;// Биопсия миндалины, зева и аденоидов
      "A11.07.004", ;// Биопсия глотки, десны и язычка
      "A11.07.005", ;// Биопсия слизистой преддверия полости рта
      "A11.07.006", ;// Биопсия пульпы
      "A11.07.007", ;// Биопсия тканей губы
      "A11.07.016", ;// Биопсия слизистой ротоглотки
      "A11.07.016.001", ;// Биопсия слизистой ротоглотки под контролем эндоскопического исследования
      "A11.07.020", ;// Биопсия слюнной железы
      "A11.07.020.001", ;// Биопсия околоушной слюнной железы
      "A11.08.001", ;// Биопсия слизистой оболочки гортани
      "A11.08.001.001", ;// Биопсия тканей гортани под контролем ларингоскопического исследования
      "A11.08.002", ;// Биопсия слизистой оболочки полости носа
      "A11.08.003", ;// Биопсия слизистой оболочки носоглотки
      "A11.08.003.001", ;// Биопсия слизистой оболочки носоглотки под контролем эндоскопического исследования
      "A11.08.015", ;// Биопсия слизистой оболочки околоносовых пазух
      "A11.08.016", ;// Биопсия тканей грушевидного кармана
      "A11.08.016.001", ;// Биопсия тканей грушевидного кармана под контролем эндоскопического исследования
      "A11.26.001" ;// Биопсия новообразования век, конъюнктивы или роговицы
    };
      }
    Private arr_21[ 50 ], arr_316 := {}, arr_ne := {}
    AFill( arr_21, 0 )
    mywait( "Сбор статистики" )
    adbf := { { "name", "C", 80, 0 }, ;
      { "NN", "N", 2, 0 }, ;
      { "g1", "N", 6, 0 }, ;
      { "g2", "N", 6, 0 }, ;
      { "g3", "N", 6, 0 }, ;
      { "g4", "N", 6, 0 }, ;
      { "g5", "N", 6, 0 }, ;
      { "g6", "N", 6, 0 }, ;
      { "g7", "N", 6, 0 }, ;
      { "g8", "N", 6, 0 }, ;
      { "g9", "N", 6, 0 } }
    dbCreate( cur_dir() + "tmp1", adbf )
    Use ( cur_dir() + "tmp1" ) new
    Index On Str( nn, 2 ) to ( cur_dir() + "tmp1" )
    Append Blank
    tmp1->nn := 2 ;  tmp1->name := "Осмотрено всего (завершили I этап)"
    Append Blank
    tmp1->nn := 3 ;  tmp1->name := "из гр.2 после 18:00"
    Append Blank
    tmp1->nn := 4 ;  tmp1->name := "из гр.2 в субботу"
    Append Blank
    tmp1->nn := 5 ;  tmp1->name := "из гр.2 прошедшие все исследования в один день"
    Append Blank
    tmp1->nn := 6 ;  tmp1->name := "из гр.2 всего сельских жителей"
    Append Blank
    tmp1->nn := 7 ;  tmp1->name := "из гр.6 сельских жителей после 18:00"
    Append Blank
    tmp1->nn := 8 ;  tmp1->name := "из гр.6 сельских жителей в субботу"
    Append Blank
    tmp1->nn := 9 ;  tmp1->name := "ГРАЖДАН с впервые выявлен.неинф.заболеваниями"
    Append Blank
    tmp1->nn := 10 ; tmp1->name := "всего впервые выявлено неинф.заболеваний"
    Append Blank
    tmp1->nn := 11 ; tmp1->name := "из гр.9 ГРАЖДАН болезни сист.кровообращения"
    Append Blank
    tmp1->nn := 12 ; tmp1->name := "из гр.9 ГРАЖДАН ЗНО"
    Append Blank
    tmp1->nn := 13 ; tmp1->name := "        из гр.12 в т.ч. в 1 и 2 стадиях"
    Append Blank
    tmp1->nn := 14 ; tmp1->name := "из гр.9 ГРАЖДАН сахарный диабет"
    Append Blank
    tmp1->nn := 15 ; tmp1->name := "        в т.ч. сахарный диабет I типа"
    Append Blank
    tmp1->nn := 16 ; tmp1->name := "из гр.9 ГРАЖДАН глаукома"
    Append Blank
    tmp1->nn := 17 ; tmp1->name := "из гр.9 ГРАЖДАН хрон.болезни органов дыхания"
    Append Blank
    tmp1->nn := 18 ; tmp1->name := "из гр.9 ГРАЖДАН болезни органов пищеварения"
    Append Blank
    tmp1->nn := 19 ; tmp1->name := "из гр.9 ГРАЖДАН взяты на дисп.наблюдение"
    Append Blank
    tmp1->nn := 20 ; tmp1->name := "из гр.9 ГРАЖДАН было начато лечение"
    Append Blank
    tmp1->nn := 21 ; tmp1->name := "   из гр.19 из них сельских жителей"
    dbCreate( cur_dir() + "tmp11", adbf )
    Use ( cur_dir() + "tmp11" ) new
    Index On Str( nn, 2 ) to ( cur_dir() + "tmp11" )
    Append Blank
    tmp11->nn :=  1 ; tmp11->name := "впервые взяты на диспансерный учёт"
    Append Blank
    tmp11->nn :=  2 ; tmp11->name := "оказана специализированная мед.помощь"
    Append Blank
    tmp11->nn :=  3 ; tmp11->name := "оказаны реабилитационные мероприятия"
    Append Blank
    tmp11->nn :=  4 ; tmp11->name := "отказались от проведения дисп-ии в целом"
    Append Blank
    tmp11->nn :=  5 ; tmp11->name := "выявлено пациентов с онкопатологией"
    Append Blank
    tmp11->nn :=  6 ; tmp11->name := "  в т.ч. 1 стадия"
    Append Blank
    tmp11->nn :=  7 ; tmp11->name := "         2 стадия"
    Append Blank
    tmp11->nn :=  8 ; tmp11->name := "         3 стадия"
    Append Blank
    tmp11->nn :=  9 ; tmp11->name := "         4 стадия"
    Append Blank
    tmp11->nn := 10 ; tmp11->name := "направлено на индивид.углубл.профилакт.конс-ие"
    Append Blank
    tmp11->nn := 11 ; tmp11->name := "кол-во прошедших индивид.углубл.профилакт.конс-ие"
    Append Blank
    tmp11->nn := 12 ; tmp11->name := "процент охвата индивид.углубл.профилакт.конс-ием"
    Append Blank
    tmp11->nn := 13 ; tmp11->name := "направлено граждан на групповое профилакт.конс-ие"
    Append Blank
    tmp11->nn := 14 ; tmp11->name := "кол-во прошедших групповое профилакт.конс-ие"
    Append Blank
    tmp11->nn := 15 ; tmp11->name := "процент охвата групповым профилакт.конс-ием"
    //
    dbCreate( cur_dir() + "tmp12", adbf )
    Use ( cur_dir() + "tmp12" ) new
    Index On Str( nn, 2 ) to ( cur_dir() + "tmp12" )
    Append Blank
    tmp12->nn :=  1 ; tmp12->name := "Кол-во маммографий в рамках диспансеризации"
    Append Blank
    tmp12->nn :=  2 ; tmp12->name := "  кол-во застрахованных"
    Append Blank
    tmp12->nn :=  3 ; tmp12->name := "    выявлена патология в молочной железе"
    Append Blank
    tmp12->nn :=  4 ; tmp12->name := "      направлено на 2 этап диспансеризации"
    Append Blank
    tmp12->nn :=  5 ; tmp12->name := "      выполнена биопсия молочной железы"
    Append Blank                        // C50,D05
    tmp12->nn :=  6 ; tmp12->name := "    выявлено ЗНО молочной железы, всего"
    Append Blank
    tmp12->nn :=  7 ; tmp12->name := "      in situ"
    Append Blank
    tmp12->nn :=  8 ; tmp12->name := "      из них 1 стадия"
    Append Blank
    tmp12->nn :=  9 ; tmp12->name := "      из них 2 стадия"
    Append Blank
    tmp12->nn := 10 ; tmp12->name := "      из них 3 стадия"
    Append Blank
    tmp12->nn := 11 ; tmp12->name := "      из них 4 стадия"
    Append Blank
    tmp12->nn := 12 ; tmp12->name := "Кол-во анализов кала на скрытую кровь"
    Append Blank
    tmp12->nn := 13 ; tmp12->name := "  кол-во застрахованных"
    Append Blank
    tmp12->nn := 14 ; tmp12->name := "    выявлен положительный тест на скрытую кровь в кале"
    Append Blank
    tmp12->nn := 15 ; tmp12->name := "      направлено на 2 этап диспансеризации"
    Append Blank
    tmp12->nn := 16 ; tmp12->name := "        выполнена колоноскопия"
    Append Blank
    tmp12->nn := 17 ; tmp12->name := "        выполнена ректороманоскопия"
    Append Blank
    tmp12->nn := 18 ; tmp12->name := "        выполнена биопсия при колоноскопии или ректороманоскопии"
    Append Blank                     // C18-C21,D01.0-D01.3
    tmp12->nn := 19 ; tmp12->name := "    выявлено ЗНО толстой/прямой кишки, всего"
    Append Blank
    tmp12->nn := 20 ; tmp12->name := "      in situ"
    Append Blank
    tmp12->nn := 21 ; tmp12->name := "      из них 1 стадия"
    Append Blank
    tmp12->nn := 22 ; tmp12->name := "      из них 2 стадия"
    Append Blank
    tmp12->nn := 23 ; tmp12->name := "      из них 3 стадия"
    Append Blank
    tmp12->nn := 24 ; tmp12->name := "      из них 4 стадия"
    Append Blank
    tmp12->nn := 25 ; tmp12->name := "Кол-во ПАП-тестов  в рамках диспансеризации"
    Append Blank
    tmp12->nn := 26 ; tmp12->name := "  кол-во застрахованных"
    Append Blank
    tmp12->nn := 27 ; tmp12->name := "    выялена патология шейки матки"
    Append Blank
    tmp12->nn := 28 ; tmp12->name := "      направлено на 2 этап диспансеризации"
    Append Blank
    tmp12->nn := 29 ; tmp12->name := "      выполнена биопсия шейки матки"
    Append Blank                    // С53,D06
    tmp12->nn := 30 ; tmp12->name := "    выявлено ЗНО шейки матки, всего"
    Append Blank
    tmp12->nn := 31 ; tmp12->name := "      in situ"
    Append Blank
    tmp12->nn := 32 ; tmp12->name := "      из них 1 стадия"
    Append Blank
    tmp12->nn := 33 ; tmp12->name := "      из них 2 стадия"
    Append Blank
    tmp12->nn := 34 ; tmp12->name := "      из них 3 стадия"
    Append Blank
    tmp12->nn := 35 ; tmp12->name := "      из них 4 стадия"
    Append Blank
    tmp12->nn := 36 ; tmp12->name := "Кол-во застр-ых, у которых выявлена патология кожи и видимых слизистых"
    Append Blank
    tmp12->nn := 37 ; tmp12->name := "  направлены на биопсию кожи и видимых слизистых"
    Append Blank                      // C00,C14.8,C43,C44,D00.0,D03,D04
    tmp12->nn := 38 ; tmp12->name := "  выявлено ЗНО кожи и видимых слизистых, всего"
    Append Blank
    tmp12->nn := 39 ; tmp12->name := "    in situ"
    Append Blank
    tmp12->nn := 40 ; tmp12->name := "    из них 1 стадия"
    Append Blank
    tmp12->nn := 41 ; tmp12->name := "    из них 2 стадия"
    Append Blank
    tmp12->nn := 42 ; tmp12->name := "    из них 3 стадия"
    Append Blank
    tmp12->nn := 43 ; tmp12->name := "    из них 4 стадия"
    //
    dbCreate( cur_dir() + "tmp2", { { "kod_k", "N", 7, 0 }, ;
      { "rslt1", "N", 3, 0 }, ;
      { "rslt2", "N", 3, 0 } } )
    Use ( cur_dir() + "tmp2" ) new
    Index On Str( kod_k, 7 ) to ( cur_dir() + "tmp2" )
    r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
    Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "uslugi",, "USL" )
    r_use( dir_server() + "human_u_",, "HU_" )
    r_use( dir_server() + "human_u", dir_server() + "human_u", "HU" )
    Set Relation To RecNo() into HU_
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human",, "HUMAN" )
    Set Relation To RecNo() into HUMAN_, To kod_k into KART_
    r_use( dir_server() + "schet_",, "SCHET_" )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    f_error_dvn( 1 )
    ii := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
      If !Empty( tmp->kod4h ) // Диспансеризация 1 раз в 2 года
        human->( dbGoto( tmp->kod4h ) )
        mdvozrast := Year( human->n_data ) - Year( human->date_r )
        g1 := ret_gruppa_dvn( human_->RSLT_NEW )
      /*if between(g1, 1, 4)
        arr_21[31] ++
        if human->pol == "М"
          arr_21[32] ++
        else
          arr_21[33] ++
        endif
        if human->pol == "Ж" .and. human->k_data < 0d20190501 .and. ascan(arr2g_vozrast_DVN,mdvozrast) > 0
          arr_21[34] ++
        else
          arr_21[35] ++
        endif
      endif*/
      Elseif emptyall( tmp->kod1h, tmp->kod2h ) // профилактика
        human->( dbGoto( tmp->kod3h ) )
        mdvozrast := Year( human->n_data ) - Year( human->date_r )
        g1 := 0
        If Between( human_->RSLT_NEW, 343, 345 )
          g1 := human_->RSLT_NEW - 342
        Elseif Between( human_->RSLT_NEW, 373, 374 )
          g1 := human_->RSLT_NEW - 370
        Endif
        If Between( g1, 1, 4 )
          arr_21[ 14 ] ++
          If f_is_selo( kart_->gorod_selo, kart_->okatog )
            arr_21[ 15 ] ++
          Endif
          If g1 == 3
            arr_21[ 41 ] ++
          Elseif g1 == 4
            arr_21[ 42 ] ++
          Endif
          If g1 == 4 ; g1 := 3 ; Endif // Итого III группа
          arr_21[ 15 + g1 ]++   // профосмотры по группам здоровья
          If f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
            arr_21[ 40 ] ++
          Endif
          f2_f21_inf_dvn( 2 )
        Endif
      Else
        f1_f21_inf_dvn()
      Endif
      f_error_dvn( 2 )
      Select TMP
      Skip
    Enddo
    Close databases
    // проверим посещения 2 года назад
    mywait( "Проверка на посещение учреждения в ближайшие 2 года" )
    r_use( dir_server() + "human",, "HUMAN" )
    Index On Str( KOD_k, 7 ) + DToS( n_data ) to ( cur_dir() + "tmp_2year" ) For n_data > ( Date() -800 )
    Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
    ii := 0
    Go Top
    Do While !Eof()
      @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
      If !Empty( tmp->kod4h ) // Диспансеризация 1 раз в 2 года
        //
      Elseif emptyall( tmp->kod1h, tmp->kod2h ) // профилактика
        Select human
        human->( dbGoto( tmp->kod3h ) )
        t_kod_k :=  human->kod_k
        t_date  :=  human->n_data
        Skip -1
        If human->kod_k == t_kod_k
          If ( ( t_date - human->n_data ) > 730 )
            kol_2_year_prof++
            If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
              kol_2_year_prof_40++
            Endif
          Endif
        Else
          kol_2_year_prof++
          If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
            kol_2_year_prof_40++
          Endif
        Endif
      Else// диспансеризация
        If ( tmp->kod1h > 0 )
          Select human
          human->( dbGoto( tmp->kod1h ) )
          t_kod_k :=  human->kod_k
          t_date  :=  human->n_data
          Skip -1
          If human->kod_k == t_kod_k
            If ( ( t_date - human->n_data ) > 730 )
              kol_2_year_dvn++
              If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 ) .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
                kol_2_year_dvn_40++
              Endif
            Endif
          Else
            kol_2_year_dvn++
            If ( mvozrast := count_years( human->date_r, human->n_data ) > 39 )  .and. ( mvozrast := count_years( human->date_r, human->n_data ) < 66 )
              kol_2_year_dvn_40++
            Endif
          Endif
        Endif
      Endif
      Select TMP
      Skip
    Enddo
    Close databases
    dbCreate( cur_dir() + "tmp3", { { "et2", "N", 1, 0 }, ;
      { "gr1", "N", 1, 0 }, ;
      { "gr2", "N", 1, 0 }, ;
      { "kol1", "N", 6, 0 }, ;
      { "kol2", "N", 6, 0 } } )
    Use ( cur_dir() + "tmp3" ) new
    Index On Str( et2, 1 ) + Str( gr1, 1 ) + Str( gr2, 1 ) to ( cur_dir() + "tmp3" )
    r_use( dir_server() + "kartotek",, "KART" )
    Use ( cur_dir() + "tmp2" ) new
    Go Top
    Do While !Eof()
      fl := .f.
      g1 := ret_gruppa_dvn( tmp2->rslt1, @fl )
      If Between( g1, 0, 4 )
        k := iif( fl, 1, 0 )
        g2 := ret_gruppa_dvn( tmp2->rslt2 )
        If !Between( g2, 1, 4 )
          g2 := 0
        Endif
        Select TMP3
        find ( Str( k, 1 ) + Str( g1, 1 ) + Str( g2, 1 ) )
        If !Found()
          Append Blank
          tmp3->et2 := k
          tmp3->gr1 := g1
          tmp3->gr2 := g2
        Endif
        tmp3->kol1++
        If g2 > 0
          tmp3->kol2++
        Endif
      Endif
      If tmp2->rslt1 == 316 .and. Empty( tmp2->rslt2 )
        kart->( dbGoto( tmp2->kod_k ) )
        AAdd( arr_316, AllTrim( kart->fio ) + " д.р." + full_date( kart->date_r ) )
      Endif
      If tmp2->rslt1 == 0 .and. !Empty( tmp2->rslt2 )
        kart->( dbGoto( tmp2->kod_k ) )
        AAdd( arr_ne, AllTrim( kart->fio ) + " д.р." + full_date( kart->date_r ) )
      Endif
      Select TMP2
      Skip
    Enddo
    Close databases
    //
    at := { glob_mo[ _MO_SHORT_NAME ], "[ " + CharRem( "~", mas1pmt[ par ] ) + " за вычетом отказов в оплате ]", arr_m[ 4 ] }
    print_shablon( "svod_dvn", { arr_21, at, ar }, "tmp1.txt", .f. )
    fp := FCreate( "tmp2.txt" ) ; n_list := 1 ; tek_stroke := 0
    fl := f_error_dvn( 3, 60, 80 )
    StrFile( "Лица прошедшие диспансеризацию/профосмотр, ранее не посещавшие учреждение более 2-х лет" + hb_eol(), "tmp1.txt", .t. )
    StrFile( " Диспансеризация == " + lstr( kol_2_year_dvn ) + " чел. из них 40-65 лет == " +  lstr( kol_2_year_dvn_40 )  + " чел."  + hb_eol(), "tmp1.txt", .t. )
    StrFile( " Профосмотр      == " + lstr( kol_2_year_prof ) + " чел. из них 40-65 лет == " +  lstr( kol_2_year_prof_40 )  + " чел."  +  + hb_eol(), "tmp1.txt", .t. )
    FClose( fp )
    If fl
      StrFile( "FF", "tmp1.txt", .t. )
      feval( "tmp2.txt", {| s| StrFile( s + hb_eol(), "tmp1.txt", .t. ) } )
    Endif
    viewtext( "tmp1.txt",,,,,,, 3 )
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 08.07.24
Function inf_ydvn()

  Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}, is_all
  Local sh, HH := 53,  n_file := cur_dir() + "gor_YDVN.txt", reg_print, arr_itog[ 20 ]
  Local t_rec, t_poisk, t_rezult, is_pesia
/*local arr_title := {;
"──────┬───────┬────────┬───────┬─────────┬──────┬──────┬──────┬──────┬──────┬───────┬──────┬──────┬──────┬──────┬──────┬──────┬───────", ;
"прошли│ в том │   в    │   в   │прошли за│      │      │      │      │      │направ-│прошли│      │      │      │      │      │впервые", ;
"1 этап│ числе │вечернее│субботу│  ОДИН   │   I  │  II  │  III │ IIIa │ IIIb │лено на│2 этап│   I  │  II  │  III │ IIIa │ IIIb │  взято", ;
"      │ село  │ время  │       │  день   │группа│группа│группа│группа│группа│ 2 этап│      │группа│группа│группа│группа│группа│ Д учет", ;
"──────┼───────┼────────┼───────┼─────────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼───────", ;
"   2  │  2.1  │   3    │   4   │    5    │   6  │   7  │   8  │   9  │  10  │   11  │  12  │  13  │  14  │  15  │  16  │  17  │   18  ", ;
"──────┴───────┴────────┴───────┴─────────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴───────"}*/
/*local arr_title := {;
"──────┬───────┬───────┬────────┬───────┬─────────┬──────┬──────┬──────┬──────┬──────┬───────┬──────┬──────┬──────┬──────┬──────┬──────┬───────", ;
"прошли│ старше│ в том │   в    │   в   │прошли за│      │      │      │      │      │направ-│прошли│      │      │      │      │      │впервые", ;
"1 этап│трудосп│ числе │вечернее│субботу│  ОДИН   │   I  │  II  │  III │ IIIa │ IIIb │лено на│2 этап│   I  │  II  │  III │ IIIa │ IIIb │  взято", ;
"      │ возр. │ село  │ время  │       │  день   │группа│группа│группа│группа│группа│ 2 этап│      │группа│группа│группа│группа│группа│ Д учет", ;
"──────┼───────┼───────┼────────┼───────┼─────────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼───────", ;
"   2  │  2.1  │  2.2  │   3    │   4   │    5    │   6  │   7  │   8  │   9  │  10  │   11  │  12  │  13  │  14  │  15  │  16  │  17  │   18  ", ;
"──────┴───────┴───────┴────────┴───────┴─────────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴───────"}
*/
  Local arr_title := { ;
    "──────────────────────┬─────────────────────────────────────────────────────────────┬───────┬──────┬──────────────────────────────────┬───────", ;
    "    Прошли 1-й этап   │                     Из графы 2                              │       │      │              Из Графы 2.1        │       ", ;
    "──────┬───────┬───────┼────────┬───────┬─────────┬──────┬──────┬──────┬──────┬──────┼       │      ┼──────┬──────┬──────┬──────┬──────┼       ", ;
    "прошли│ старше│ в том │   в    │   в   │прошли за│      │      │      │      │      │направ-│прошли│      │      │      │      │      │впервые", ;
    "1 этап│трудосп│ числе │вечернее│субботу│  ОДИН   │   I  │  II  │  III │ IIIa │ IIIb │лено на│2 этап│   I  │  II  │  III │ IIIa │ IIIb │  взято", ;
    "      │ возр. │ село  │ время  │       │  день   │группа│группа│группа│группа│группа│ 2 этап│      │группа│группа│группа│группа│группа│ Д учет", ;
    "──────┼───────┼───────┼────────┼───────┼─────────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼──────┼──────┼──────┼──────┼──────┼───────", ;
    "   2  │  2.1  │       │   3    │   4   │    5    │   6  │   7  │   8  │   9  │  10  │   11  │  12  │  13  │  14  │  15  │  16  │  17  │   18  ", ;
    "──────┴───────┴───────┴────────┴───────┴─────────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴──────┴──────┴──────┴──────┴──────┴───────" }

  Local title_zagol := { ;
    "Иные граждане", ;
    "с коморбидным фоном (наличие двух и более хронических неинфекционных заболеваний - 1 группа", ;
    "не более чем с одним сопутствующим хроническим неинфекционным заболеванием - 2 группа", ;
    "Итого" }
  Local mas_n_otchet[ 15 ]
  Private  pole_pervich, pole_1pervich, pole_dispans, pole_1dispans

  AFill( mas_n_otchet, 0 )
  r_use( dir_server() + "kartote_",, "KART_" )
  r_use( dir_server() + "kartotek",, "KART" )

  For i := 1 To 5
    sk := lstr( i )
    // pole_pervich := "mpervich"+sk
    pole_1pervich := "m1pervich" + sk
    // pole_dispans := "mdispans"+sk
    pole_1dispans := "m1dispans" + sk
    // Private &pole_pervich := space(7)
    Private &pole_1pervich := 0
    // Private &pole_dispans := space(10)
    Private &pole_1dispans := 0
  Next

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + "tmp", { { "gruppa_1", "N", 1, 0 }, ;// 1-группа 2- группа 3 - без группа
    { "etap_1", "N", 1, 0 }, ;  // Этап 1-й 2-й
    { "sub_day", "N", 1, 0 }, ; // Выполнение в субботу 0-нет 1-да
    { "one_day", "N", 1, 0 }, ; // Выполнение в 1 день 0-нет 1-да
    { "gruppa", "N", 3, 0 }, ;  // Группа здоровья 1, 2.3a, 3b
    { "napr2", "N", 1, 0 }, ;   // Направлен на 2-й этап 0-нет 1-да
    { "selo", "N", 1, 0 }, ;    // Село 0-нет 1-да
      { "pensia", "N", 1, 0 }, ;  // Пенсия 0-нет 1-да _pol=="М", 62, 57 по ЗАКОНУ за 2022 год - так в таблице
    { "d_one", "N", 1, 0 }, ;   // Впервые взято на Д-учет 0-нет 1-да
    { "kod_k", "N", 7, 0 } } )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    Use ( cur_dir() + "tmp" ) new
    //
    Select HUMAN
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Do While human->k_data <= arr_m[ 6 ] .and. !Eof()
      // If Between( human->ishod, 401, 402 )
      If is_sluch_dispanser_covid( human->ishod )
        // read_arr_DVN_COVID(human->kod)
        // is_selo := f_is_selo(kart_->gorod_selo,kart_->okatog)  // признак села
        Select KART_
        Goto ( HUMAN->kod_k )
        Select KART
        Goto ( HUMAN->kod_k )
        Select HUMAN
        is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog )  // признак села
        is_pensia := f_starshe_trudosp( kart->pol, kart->date_r, human->n_data, 3 ) // признак пенсионеров
        Select TMP
        Append Blank
        tmp->kod_k := HUMAN->kod_k
        If is_selo
          tmp->selo := 1
        Endif
        If is_pensia
          tmp->pensia := 1
        Endif
        If DoW( human->n_data ) == 7
          tmp->sub_day := 1
        Else
          tmp->sub_day := 0
        Endif
        If human->k_data == human->n_data
          tmp->one_day := 1
        Else
          tmp->one_day := 0
        Endif
        If human->ishod == 401
          tmp->etap_1 := 1
        Else
          tmp->etap_1 := 2
        Endif
        // выбираем услуги
        // larr := array(2, len(uslugiEtap_DVN_COVID(metap)))
        // arr_usl := {} // array(len(uslugiEtap_DVN_COVID(metap)))
        //
        arr := read_arr_dispans( human->kod )
        //
        For i := 1 To Len( arr )
          If ValType( arr[ i ] ) == "A" .and. ValType( arr[ i, 1 ] ) == "C"
            Do Case
            Case arr[ i, 1 ] == "5" .and. ValType( arr[ i, 2 ] ) == "N"
              tmp->gruppa_1 := arr[ i, 2 ]
            Case eq_any( arr[ i, 1 ], "11", "12", "13", "14" )
              sk := Right( arr[ i, 1 ], 1 )
              pole_1pervich := "m1pervich" + sk
              pole_1dispans := "m1dispans" + sk
              If ValType( arr[ i, 2, 4 ] ) == "N"
                &pole_1dispans := arr[ i, 2, 4 ]
              Endif
              If ValType( arr[ i, 2, 2 ] ) == "N"
                &pole_1pervich := arr[ i, 2, 2 ]
              Endif
              if &pole_1dispans == 1 .and. &pole_1pervich == 1
                tmp->d_one := 1
              Endif
            Case arr[ i, 1 ] == "40"
              tmp_mas := arr[ i, 2 ]
              fl_t := .f.
              fl_t1 := .f.
              For jj := 1 To Len( tmp_mas )
                If AllTrim( tmp_mas[ jj ] )     == "70.8.2"     // 70- Проведение теста с 6 минутной ходьбой
                  fl_t := .t.
                  mas_n_otchet[ 3 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "A12.09.001" // 71- "Проведение спирометрии или спирографии"
                  fl_t := .t.
                  mas_n_otchet[ 4 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "A12.09.005" // "69- Пульсооксиметрия"
                  fl_t := .t.
                  mas_n_otchet[ 2 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "A06.09.007" // 72- Рентгенография легких
                  fl_t := .t.
                  mas_n_otchet[ 5 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "B03.016.003"// 73- "Общий (клинический) анализ крови развернутый"
                  fl_t := .t.
                  mas_n_otchet[ 6 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "B03.016.004"// 74- Анализ крови биохимический общетерапевтический
                  fl_t := .t.
                  mas_n_otchet[ 7 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.3"     // 75 "Определение концентрации Д-димера в крови"
                  fl_t := .t.
                  mas_n_otchet[ 8 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.52"    // 2 - 78 Дуплексное сканир-ие вен нижних конечностей
                  fl_t1 := .t.
                  mas_n_otchet[ 10 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.51"    // 2 - 79 Проведение КТ легких
                  fl_t1 := .t. // mas_n_otchet[9] ++
                  mas_n_otchet[ 11 ] ++
                Elseif AllTrim( tmp_mas[ jj ] ) == "70.8.50"    // 2 - 80 Проведение Эхокардиографии
                  fl_t1 := .t.
                  mas_n_otchet[ 12 ] ++
                Endif
              Next
              If fl_t
                mas_n_otchet[ 1 ] ++
              Endif
              If fl_t1
                mas_n_otchet[ 9 ] ++
              Endif
            Case arr[ i, 1 ] == "56"  // реабилитация
              If ValType( arr[ i, 2 ] ) == "N"
                // mas_n_otchet[14] ++
              Elseif ValType( arr[ i, 2 ] ) == "A"
                If arr[ i, 2 ][ 2 ] > 0
                  mas_n_otchet[ 14 ] ++
                Endif
              Endif
            Endcase
          Endif
        Next
        //
        If human_->RSLT_NEW == 317
          tmp->gruppa := 1
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 318
          tmp->gruppa := 2
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 355
          tmp->gruppa := 3
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 356
          tmp->gruppa := 4
          tmp->napr2  := 0
        Elseif human_->RSLT_NEW == 352
          tmp->gruppa := 1
          tmp->napr2  := 1
        Elseif human_->RSLT_NEW == 353
          tmp->gruppa := 2
          tmp->napr2  := 1
        Elseif human_->RSLT_NEW == 357
          tmp->gruppa := 3
          tmp->napr2  := 1
        Else // if human_->RSLT_NEW == 358
          tmp->gruppa := 4
          tmp->napr2  := 1
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    Select TMP
    Index On Str( kod_k, 7 ) + Str( etap_1, 1 )  To tmp_kk
    //
    Go Top
    Do While !Eof()
      If etap_1 == 2
        t_rec := tmp->( RecNo() )
        t_poisk := Str( tmp->kod_k, 7 ) + Str( 1, 1 )
        t_rezult := 0 // по умолчанию ИНЫЕ
        find( t_poisk )
        If Found()
          t_rezult := tmp->gruppa_1
        Endif
        Goto t_rec
        g_rlock( forever )
        tmp->gruppa_1  := t_rezult
        Unlock
      Endif
      Select TMP
      Skip
    Enddo
    // создаем отчет
    reg_print := f_reg_print( arr_title, @sh, 2 )
    fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
    // add_string("")
    //
    For II := 0 To 3
      AFill( arr_itog, 0 )
      Select TMP
      Go Top
      Do While !Eof()
        If iif( II == 3, .t., tmp->Gruppa_1 == II )
          If tmp->etap_1 == 1
            arr_itog[ 2 ] ++
            If tmp->sub_day == 1
              arr_itog[ 4 ] ++
            Endif
            If tmp->one_day == 1
              arr_itog[ 5 ] ++
            Endif
            If tmp->gruppa == 1
              arr_itog[ 6 ] ++
            Endif
            If tmp->gruppa == 2
              arr_itog[ 7 ] ++
            Endif
            If tmp->gruppa == 3
              arr_itog[ 8 ] ++
              arr_itog[ 9 ] ++
            Endif
            If tmp->gruppa == 4
              arr_itog[ 8 ] ++
              arr_itog[ 10 ] ++
            Endif
            If tmp->napr2 == 1
              arr_itog[ 11 ] ++
            Endif
            // доработка 28.09.2023
            If tmp->gruppa == 1 .and. tmp->pensia == 1
              arr_itog[ 13 ] ++
            Endif
            If tmp->gruppa == 2  .and. tmp->pensia == 1
              arr_itog[ 14 ] ++
            Endif
            If tmp->gruppa == 3 .and. tmp->pensia == 1
              arr_itog[ 15 ] ++
              arr_itog[ 16 ] ++
            Endif
            If tmp->gruppa == 4 .and. tmp->pensia == 1
              arr_itog[ 15 ] ++
              arr_itog[ 17 ] ++
            Endif
          Else
            arr_itog[ 12 ] ++
         /* if tmp->gruppa == 1
            arr_itog[13] ++
          endif
          if tmp->gruppa == 2
            arr_itog[14] ++
          endif
          if tmp->gruppa == 3
            arr_itog[15] ++
            arr_itog[16] ++
          endif
          if tmp->gruppa == 4
            arr_itog[15] ++
            arr_itog[17] ++
          endif
          */
          Endif
          If tmp->d_one == 1
            arr_itog[ 18 ] ++
          Endif
          If tmp->selo == 1
            arr_itog[ 19 ]++
          Endif
          If tmp->pensia == 1
            arr_itog[ 20 ]++
          Endif
        Endif
        Skip
      Enddo
      // Выводим
      add_string( Center( "Лица, перенесшие COVID-19", sh ) )
      If II == 3
        add_string( Center( "ИТОГО", sh ) )
      Else
        add_string( Center( title_zagol[ II + 1 ], sh ) )
      Endif
      add_string( Center( arr_m[ 4 ], sh ) )
      // add_string("")
      AEval( arr_title, {| x| add_string( x ) } )
      add_string( PadL( lstr( arr_itog[ 2 ] ), 6 ) + ;
        PadL( lstr( arr_itog[ 20 ] ), 8 ) + ;
        PadL( lstr( arr_itog[ 19 ] ), 8 ) + ;
        PadL( "", 8 ) + ;
        PadL( lstr( arr_itog[ 4 ] ), 9 ) + ;
        PadL( lstr( arr_itog[ 5 ] ), 10 ) + ;
        PadL( lstr( arr_itog[ 6 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 7 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 8 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 9 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 10 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 11 ] ), 8 ) + ;
        PadL( lstr( arr_itog[ 12 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 13 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 14 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 15 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 16 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 17 ] ), 7 ) + ;
        PadL( lstr( arr_itog[ 18 ] ), 8 ) )
      // add_string("")
      add_string( "" )
    Next
    If verify_ff( HH, .t., sh )
      // aeval(arr_title, {|x| add_string(x) } )
    Endif
    // endif
    add_string( "Доля лиц с отклонениями  от нормы, выявленными у граждан, перенсеших новую коронавирусную инфекцию" )
    add_string( "COVID-19 по результатам I этапа углубленной диспансеризации (доля от количества граждан, завершивших" )
    add_string( " I этап углубленной диспансеризации и прошедших конкретное исследование, %)" )
    add_string( "" )
    add_string( "68- Всего лиц с отконениями I этап              = " + PadL( lstr( mas_n_otchet[ 1 ] ), 9 ) + " чел." )
    add_string( "69- Сатурация                                   = " + PadL( lstr( mas_n_otchet[ 2 ] ), 9 ) + " чел." )
    add_string( "70- Тест с 6 минутной ходьбой                   = " + PadL( lstr( mas_n_otchet[ 3 ] ), 9 ) + " чел." )
    add_string( "71- Спирометрия                                 = " + PadL( lstr( mas_n_otchet[ 4 ] ), 9 ) + " чел." )
    add_string( "72- Рентгенография легких                       = " + PadL( lstr( mas_n_otchet[ 5 ] ), 9 ) + " чел." )
    add_string( "73- Общий анализ крови                          = " + PadL( lstr( mas_n_otchet[ 6 ] ), 9 ) + " чел." )
    add_string( "74- Биохимический анализ крови                  = " + PadL( lstr( mas_n_otchet[ 7 ] ), 9 ) + " чел." )
    add_string( "75- Определение концентрации Д-димера в крови   = " + PadL( lstr( mas_n_otchet[ 8 ] ), 9 ) + " чел." )
    add_string( "" )
    add_string( "Доля лиц с отклонениями  от нормы, выявленными у граждан, перенсеших новую коронавирусную инфекцию " )
    add_string( "COVID-19 по результатам II этапа углубленной диспансеризации (доля от количества граждан, завершивших " )
    add_string( " II этап углубленной диспансеризации и прошедших конкретное исследование, %)" )
    add_string( "" )
    add_string( "77- Всего лиц с отконениями II этап             = " + PadL( lstr( mas_n_otchet[ 9 ] ), 9 ) + " чел." )
    add_string( "78- Дуплексное сканир-ие вен нижних конечностей = " + PadL( lstr( mas_n_otchet[ 10 ] ), 9 ) + " чел." )
    add_string( "79- Проведение КТ легких                        = " + PadL( lstr( mas_n_otchet[ 11 ] ), 9 ) + " чел." )
    add_string( "80- Проведение Эхокардиографии                  = " + PadL( lstr( mas_n_otchet[ 12 ] ), 9 ) + " чел." )
    add_string( "" )
    add_string( "Число граждан, взятых на диспансерное наблюдение и направленных на реабилитацию по" )
    add_string( "результатам углубленной диспансеризации  (абс.ч.)" )
    add_string( "" )
    add_string( "83- Всего подлежат Диспансерному наблюдению     = " + PadL( lstr( arr_itog[ 18 ] ), 9 ) + " чел." )
    add_string( "85- Направлен на реабилитацию                   = " + PadL( lstr( mas_n_otchet[ 14 ] ), 9 ) + " чел." )
    Close databases
    FClose( fp )
    Private yes_albom := .t.
    viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
  Endif
  rest_box( buf )
  Close databases

  Return Nil


// 27.04.20
Function f1_f21_inf_dvn()

  Local sumr := 0, m1GRUPPA, fl2 := .f., is_selo

  Select TMP2
  Append Blank
  tmp2->kod_k := tmp->kod_k
  // диспансеризация I этап
  If Empty( tmp->kod1h )
    // нет 1 этапа, но есть второй
  Else
    human->( dbGoto( tmp->kod1h ) )
    mdvozrast := Year( human->n_data ) - Year( human->date_r )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
    If Between( m1gruppa, 0, 4 )
      tmp2->rslt1 := human_->RSLT_NEW
      If m1gruppa == 0
        fl2 := .t. // направлен на 2 этап
      Endif
      Private m1veteran := 0, m1mobilbr := 0
      read_arr_dvn( human->kod, .f. )
      arr_21[ 3 ] ++
      If m1veteran == 1
        arr_21[ 4 ] ++
      Endif
      If m1mobilbr == 1
        arr_21[ 5 ] ++
      Endif
      If mdvozrast == 65
        arr_21[ 32 ] ++
      Elseif mdvozrast > 65
        arr_21[ 33 ] ++
      Endif
      If Between( m1gruppa, 1, 4 )
        arr_21[ 5 + m1gruppa ] ++
      Endif
      If ( is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ) )
        arr_21[ 47 ] ++
      Endif
      If f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
        arr_21[ 19 ] ++
        If is_selo
          arr_21[ 20 ] ++
        Endif
        If Between( m1gruppa, 1, 4 )
          arr_21[ 42 + m1gruppa ] ++
        Endif
      Endif
      f2_f21_inf_dvn( 1 )
      If human->schet > 0
        Select SCHET_
        Goto ( human->schet )
        If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
          arr_21[ 10 ] ++
          Select RPDSH
          find ( Str( human->kod, 7 ) )
          Do While rpdsh->KOD_H == human->kod .and. !Eof()
            sumr += rpdsh->S_SL
            Skip
          Enddo
          If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // полностью оплачен
            arr_21[ 11 ] ++
          Endif
        Endif
      Endif
    Else
      // почему-то неправильная группа
    Endif
  Endif
  If fl2 // направлен на 2 этап
    arr_21[ 12 ]++    // направлен на 2 этап
  Endif
  If !Empty( tmp->kod2h ) // диспансеризация II этап
    human->( dbGoto( tmp->kod2h ) )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa, 1, 4 )
      tmp2->rslt2 := human_->RSLT_NEW
      If Empty( tmp2->rslt1 )
      Else
        arr_21[ 13 ] ++
        If !fl2  // не был направлен, но всё равно прошёл
          arr_21[ 12 ]++    // направлен на 2 этап
        Endif
      Endif
    Else
      // почему-то неправильная группа
    Endif
  Endif

  Return Nil

// 07.04.22
Function f2_f21_inf_dvn( par )

  Local is_selo, i, j, k, k1 := 9, fl2 := .f., ar[ 21 ], arr11[ 15 ], arr12[ 43 ], au := {}, fl_pens
  Private arr_otklon := {}, arr_usl_otkaz := {}, ;
    M1RAB_NERAB := human->RAB_NERAB, m1veteran := 0, m1mobilbr := 0, ;
    m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, mssr := 0, ;
    m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
    mholest := 0, mglukoza := 0, ;
    m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, ;
    m1ot_nasl1 := 0, m1ot_nasl2 := 0, m1ot_nasl3 := 0, m1ot_nasl4 := 0, ;
    m1dispans := 0, m1nazn_l  := 0, m1dopo_na := 0, m1ssh_na  := 0, ;
    m1spec_na := 0, m1sank_na := 0, ;
    pole_diag, pole_1pervich, pole_1stadia, pole_1dispans, ;
    mWEIGHT := 0, mHEIGHT := 0

  AFill( ar, 0 ) ; ar[ 2 ] := 1
  AFill( arr11, 0 )
  AFill( arr12, 0 )
  If kart_->invalid > 0
    arr_21[ 21 ] ++
  Endif
  If par == 1
    If mdvozrast < 35
      k1 := 1
    Elseif mdvozrast < 40
      k1 := 2
    Elseif mdvozrast < 55
      k1 := 3
    Elseif mdvozrast < 60
      k1 := 4
    Elseif mdvozrast < 65
      k1 := 5
    Elseif mdvozrast < 75
      k1 := 6
    Else
      k1 := 7
    Endif
    // g5
  Endif
  If human->n_data == human->k_data // за один день
    ar[ 5 ] := 1
  Endif
  If ( is_selo := f_is_selo( kart_->gorod_selo, kart_->okatog ) )
    ar[ 6 ] := 1
  Endif
  If DoW( human->k_data ) == 7 // суббота
    ar[ 4 ] := 1
    If is_selo
      ar[ 8 ] := 1
    Endif
  Endif
  fl_pens := f_starshe_trudosp( human->POL, human->DATE_R, human->n_data )
  For i := 1 To 5
    pole_diag := "mdiag" + lstr( i )
    pole_1pervich := "m1pervich" + lstr( i )
    pole_1stadia := "m1stadia" + lstr( i )
    pole_1dispans := "m1dispans" + lstr( i )
    Private &pole_diag := Space( 6 )
    Private &pole_1pervich := 0
    Private &pole_1stadia := 0
    Private &pole_1dispans := 0
  Next
  read_arr_dvn( human->kod )
  m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
  If Between( m1gruppa, 0, 4 )
    If m1gruppa == 0
      fl2 := .t. // направлен на 2 этап
    Endif
  Endif
  If !Empty( tmp->kod2h )
    fl2 := .t. // прошел 2 этап
  Endif
  Select HU
  find ( Str( tmp->kod1h, 7 ) )
  Do While hu->kod == tmp->kod1h .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
      lshifr := usl->shifr
    Endif
    AAdd( au, { AllTrim( lshifr ), ;
      hu_->PROFIL, ;
      0, ;
      c4tod( hu->date_u );
      } )
    Select HU
    Skip
  Enddo
  For k := 1 To Len( au )
    If AScan( arr_otklon, au[ k, 1 ] ) > 0
      au[ k, 3 ] := 1 // отклонения в исследовании
    Endif
    If au[ k, 1 ] == "7.57.3"
      arr12[ 1 ] := arr12[ 2 ] := 1
      arr12[ 3 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 4 ] := 1
      Endif
    Elseif au[ k, 1 ] == "4.8.4"
      arr12[ 12 ] := arr12[ 13 ] := 1
      arr12[ 14 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 15 ] := 1
      Endif
    Elseif eq_any( au[ k, 1 ], "4.20.1", "4.20.2" )
      arr12[ 25 ] := arr12[ 26 ] := 1
      arr12[ 27 ] := au[ k, 3 ]
      If fl2 .and. au[ k, 3 ] == 1
        arr12[ 28 ] := 1
      Endif
      // elseif eq_any(au[k, 1],"56.1.15","56.1.20","56.1.21","56.1.721")
      // arr11[10] := arr11[11] := 1
      // elseif au[k, 1] == "56.1.723"
      // arr11[13] := arr11[14] := 1
    Endif
  Next
  // диспансеризация II этап
  If !Empty( tmp->kod2h )
    human->( dbGoto( tmp->kod2h ) )
    m1GRUPPA2 := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa2, 1, 4 ) // точно прошёл 2 этап
      read_arr_dvn( human->kod ) // перечитать диагнозы и т.п.
    Endif
    au := {}
    Select HU
    find ( Str( tmp->kod1h, 7 ) )
    Do While hu->kod == tmp->kod1h .and. !Eof()
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      AAdd( au, { AllTrim( lshifr ), ;
        hu_->PROFIL, ;
        0, ;
        c4tod( hu->date_u );
        } )
      Select HU
      Skip
    Enddo
    For k := 1 To Len( au )
      If AScan( arr_otklon, au[ k, 1 ] ) > 0
        au[ k, 3 ] := 1 // отклонения в исследовании
      Endif
      If eq_any( au[ k, 1 ], "10.6.10", "10.6.710" )
        arr12[ 16 ] := 1
      Elseif eq_any( au[ k, 1 ], "10.4.1", "10.4.701" )
        arr12[ 17 ] := 1
      Elseif eq_any( au[ k, 1 ], "56.1.15", "56.1.20", "56.1.21", "56.1.721" )
        arr11[ 10 ] := arr11[ 11 ] := 1
      Elseif au[ k, 1 ] == "56.1.723"
        arr11[ 13 ] := arr11[ 14 ] := 1
      Endif
    Next
  Endif
  For i := 1 To 5
    pole_diag := "mdiag" + lstr( i )
    pole_1pervich := "m1pervich" + lstr( i )
    pole_1stadia := "m1stadia" + lstr( i )
    pole_1dispans := "m1dispans" + lstr( i )
    if &pole_1pervich == 1 .and. &pole_1dispans == 1
      arr11[ 1 ] := 1
    Endif
    If !( Left( &pole_diag, 1 ) == "A" .or. Left( &pole_diag, 1 ) == "B" ) .and. &pole_1pervich == 1 // неинфекционные заболевания уст.впервые
      ar[ 9 ] := 1
      ar[ 10 ] ++
      If Left( &pole_diag, 1 ) == "I" // болезни системы кровообращения
        ar[ 11 ] := 1
      Elseif Left( &pole_diag, 1 ) == "J" // болезни органов дыхания
        ar[ 17 ] := 1
      Elseif Left( &pole_diag, 1 ) == "K" // болезни органов пищеварения
        ar[ 18 ] := 1
      Endif
      If Left( &pole_diag, 1 ) == "C" .or. Between( Left( &pole_diag, 3 ), "D00", "D09" ) // ЗНО
        ar[ 12 ] := 1
        if &pole_1stadia < 3 // 1 и 2 стадия
          ar[ 13 ] := 1
        Endif
        arr11[ 5 ] := 1
        If Between( &pole_1stadia, 1, 4 )
          arr11[ 5 + &pole_1stadia ] := 1
        Endif
        If Left( &pole_diag, 3 ) == "C50"
          arr12[ 6 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 7 + &pole_1stadia ] := 1
          Endif
        Elseif Left( &pole_diag, 3 ) == "D05"
          arr12[ 6 ] := 1
          arr12[ 7 ] := 1 // in situ
        Endif
        If eq_any( Left( &pole_diag, 3 ), "C18", "C19", "C20", "C21" )
          arr12[ 19 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 20 + &pole_1stadia ] := 1
          Endif
        Elseif eq_any( Left( &pole_diag, 5 ), "D01.0", "D01.1", "D01.2", "D01.3" )
          arr12[ 19 ] := 1
          arr12[ 20 ] := 1 // in situ
        Endif
        If Left( &pole_diag, 3 ) == "C53"
          arr12[ 30 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 31 + &pole_1stadia ] := 1
          Endif
        Elseif Left( &pole_diag, 3 ) == "D06"
          arr12[ 30 ] := 1
          arr12[ 31 ] := 1 // in situ
        Endif
        If eq_any( Left( &pole_diag, 3 ), "C00", "C43", "C44" ) .or. Left( &pole_diag, 5 ) == "C14.8"
          arr12[ 36 ] := 1
          arr12[ 38 ] := 1
          If Between( &pole_1stadia, 1, 4 )
            arr12[ 39 + &pole_1stadia ] := 1
          Endif
        Elseif eq_any( Left( &pole_diag, 3 ), "D03", "D04" ) .or. Left( &pole_diag, 5 ) == "D00.0"
          arr12[ 36 ] := 1
          arr12[ 38 ] := 1
          arr12[ 39 ] := 1
        Endif
      Endif
      If Between( Left( &pole_diag, 3 ), "E10", "E14" ) // сахарный диабет
        ar[ 14 ] := 1
        If Left( &pole_diag, 3 ) == "E10" // I стадия
          ar[ 15 ] := 1
        Endif
      Endif
      If eq_any( Left( &pole_diag, 3 ), "H40", "H42" ) .or. Left( &pole_diag, 5 ) == "Q15.0" // глаукома
        ar[ 16 ] := 1
      Endif
      if &pole_1dispans == 1
        ar[ 19 ] := 1
        If is_selo
          ar[ 21 ] := 1
        Endif
      Endif
      If .f. // 1-лечение назначено
        ar[ 20 ] := 1 // ?? было начато лечение
      Endif
    Endif
  Next
  pole := "tmp1->g" + lstr( k1 )
  Select TMP1
  For i := 1 To Len( ar )
    If ar[ i ] > 0
      find ( Str( i, 2 ) )
      &pole := &pole + ar[ i ]
      If k1 < 8 .and. fl_pens
        tmp1->g8 += ar[ i ]
      Endif
    Endif
  Next
  Select TMP11
  For i := 1 To Len( arr11 )
    If arr11[ i ] > 0
      find ( Str( i, 2 ) )
      tmp11->g3 += arr11[ i ]
    Endif
  Next
  Select TMP12
  For i := 1 To Len( arr12 )
    If arr12[ i ] > 0
      find ( Str( i, 2 ) )
      tmp12->g3 += arr12[ i ]
    Endif
  Next

  Return Nil

// 20.10.16 Индикаторы мониторинга диспансеризации взрослых
Function f22_inf_dvn()

  Static group_ini := "f22_inf_DVN"
  Static as := { ;
    { 1, 0, 0, "Общее число граждан, подлежащих диспансеризации в текущем году" }, ;
    { 2, 0, 0, "Количество граждан от числа подлежащих диспансеризации в текущем году, прошедших 1-й этап диспансеризации за отчетный период" }, ;
    { 3, 0, 0, "Количество граждан от числа подлежащих диспансеризации в текущем году, прошедших 2-й этап диспансеризации за отчетный период" }, ;
    { 4, 0, 0, "Количество граждан от числа подлежащих диспансеризации в текущем году, полностью завершивших диспансеризацию за отчетный период, из них:" }, ;
    { 4, 1, 0, "имеют I группу здоровья" }, ;
    { 4, 2, 0, "имеют II группу здоровья" }, ;
    { 4, 3, 0, "имеют IIIа группу здоровья" }, ;
    { 4, 4, 0, "имеют IIIб группу здоровья" }, ;
    { 5, 0, 0, "Количество граждан с впервые выявленными хроническими неинфекционными заболеваниями, из них:" }, ;
    { 5, 1, 0, "со стенокардией" }, ;
    { 5, 2, 0, "с хронической ишемической болезнью сердца" }, ;
    { 5, 3, 0, "с артериальной гипертонией" }, ;
    { 5, 4, 0, "со стенозом сонных артерий >50%" }, ;
    { 5, 5, 0, "с острым нарушением мозгового кровообращения в анамнезе" }, ;
    { 5, 6, 0, "с подозрением на злокачественное новообразование желудка по результатам фиброгастроскопии" }, ;
    { 5, 6, 1, "на ранней стадии" }, ;
    { 5, 7, 0, "с подозрением на злокачественным новообразованием матки и ее придатков" }, ;
    { 5, 7, 1, "на ранней стадии" }, ;
    { 5, 8, 0, "с подозрением на злокачественное новообразование простаты по данным осмотра врача-хирурга (уролога) и теста на простатспецифический антиген" }, ;
    { 5, 8, 1, "на ранней стадии" }, ;
    { 5, 9, 0, "с подозрением на злокачественное новообразование грудной железы по данным маммографии" }, ;
    { 5, 9, 1, "на ранней стадии" }, ;
    { 5, 10, 0, "с подозрением на колоректальный рак по данным ректоромано- и колоноскопии" }, ;
    { 5, 10, 1, "на ранней стадии" }, ;
    { 5, 11, 0, "с подозрением на злокачественные заболевания других локализаций" }, ;
    { 5, 11, 1, "на ранней стадии" }, ;
    { 5, 12, 0, "с сахарным диабетом" }, ;
    { 6, 0, 0, "Количество граждан с впервые выявленным туберкулезом легких" }, ;
    { 7, 0, 0, "Количество граждан с впервые выявленной глаукомой, из них:" }, ;
    { 7, 0, 1, "на ранней стадии" }, ;
    { 8, 0, 0, "Количество граждан с впервые выявленными заболеваниями других органов и систем за отчетный период" }, ;
    { 9, 0, 0, "Количество граждан, имеющих факторы риска хронических неинфекционных заболеваний за отчетный период, из них:" }, ;
    { 9, 1, 0, "потребляют табак (курение)" }, ;
    { 9, 2, 0, "повышенное АД" }, ;
    { 9, 3, 0, "избыточная масса тела" }, ;
    { 9, 4, 0, "ожирение" }, ;
    { 9, 5, 0, "гиперхолестеринемия, дислипидемия" }, ;
    { 9, 6, 0, "гипергликемия" }, ;
    { 9, 7, 0, "недостаточная физическая активность" }, ;
    { 9, 8, 0, "нерациональное питание" }, ;
    { 9, 9, 0, "подозрением на пагубное потребление алкоголя" }, ;
    { 9, 10, 0, "имеющие 2 фактора риска и более" }, ;
    { 10, 0, 0, "Количество граждан с подозрением на зависимость от алкоголя, наркотиков и психотропных средств, из них:" }, ;
    { 11, 0, 1, "число граждан, направленных к психиатру-наркологу" }, ;
    { 12, 0, 0, "Количество граждан 2-й группы здоровья, прошедших углубленное профилактическое консультирование" }, ;
    { 13, 0, 0, "Количество граждан 2-й группы здоровья, прошедших групповое профилактическое консультирование" }, ;
    { 14, 0, 0, "Количество граждан 3-й группы здоровья, прошедших углубленное профилактическое консультирование" }, ;
    { 15, 0, 0, "Количество граждан 3-й группы здоровья, прошедших групповое профилактическое консультирование" };
    }
  Local i, ii, s, arr_m, buf := save_maxrow(), ar, arr_excel := {}

  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != NIL ;
      .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    Private mk1, mispoln, mtel_isp
    ar := getinisect( tmp_ini(), group_ini )
    mk1 := Int( Val( a2default( ar, "mk1", "0" ) ) )
    mispoln := PadR( a2default( ar, "mispoln", "" ), 20 )
    mtel_isp := PadR( a2default( ar, "mtel_isp", "" ), 20 )
    s := " \" + ;
      "      Общее число граждан, подлежащих диспансеризации @          \" + ;
      "      Фамилия и инициалы исполнителя @                           \" + ;
      "      Телефон исполнителя            @                           \" + ;
      " \"
    displbox( s, ;
      , ;                   // цвет окна (умолч. - cDataCGet)
      { "mk1", "mispoln", "mtel_isp" }, ; // массив Private-переменных для редактирования
    { "999999",, }, ; // массив Picture для редактирования
    17 )
    If LastKey() != K_ESC
      setinisect( tmp_ini(), group_ini, { { "mk1", mk1 }, ;
        { "mispoln", mispoln }, ;
        { "mtel_isp", mtel_isp };
        } )
      mywait()
      If f0_inf_dvn( arr_m, .f. )
        mywait( "Сбор статистики" )
        delfrfiles()
        dbCreate( fr_data, { ;
          { "nomer", "C", 5, 0 }, ;
          { "nn1", "N", 2, 0 }, ;
          { "nn2", "N", 2, 0 }, ;
          { "nn3", "N", 2, 0 }, ;
          { "name", "C", 250, 0 }, ;
          { "v1", "N", 6, 0 }, ;
          { "v2", "N", 6, 0 } } )
        Use ( fr_data ) New Alias FRD
        For i := 1 To Len( as )
          Append Blank
          If !Empty( as[ i, 1 ] ) .and. Empty( as[ i, 2 ] )
            frd->nomer := lstr( as[ i, 1 ] ) + "."
          Endif
          frd->nn1 := as[ i, 1 ]
          frd->nn2 := as[ i, 2 ]
          frd->nn3 := as[ i, 3 ]
          frd->name := iif( !Empty( as[ i, 1 ] ), "", Space( 10 ) ) + ;
            iif( Empty( as[ i, 2 ] ), "", Space( 10 ) ) + ;
            iif( Empty( as[ i, 3 ] ), "", Space( 10 ) ) + ;
            as[ i, 4 ]
          If i == 1
            frd->v1 := frd->v2 := mk1
          Endif
        Next
        Index On Str( nn1, 2 ) + Str( nn2, 2 ) + Str( nn3, 2 ) to ( cur_dir() + "tmp_frd" )
        //
        r_use( dir_server() + "human_",, "HUMAN_" )
        r_use( dir_server() + "human",, "HUMAN" )
        Set Relation To RecNo() into HUMAN_
        r_use( dir_server() + "schet_",, "SCHET_" )
        ii := 0
        Use ( cur_dir() + "tmp" ) index ( cur_dir() + "tmp" ) new
        Go Top
        Do While !Eof()
          @ MaxRow(), 0 Say Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
          If !emptyall( tmp->kod1h, tmp->kod2h ) // только диспансеризация
            f1_f22_inf_dvn()
          Endif
          Select TMP
          Skip
        Enddo
        Close databases
        r_use( dir_server() + "organiz",, "ORG" )
        dbCreate( fr_titl, { { "name", "C", 130, 0 }, ;
          { "period", "C", 100, 0 }, ;
          { "ispoln", "C", 100, 0 }, ;
          { "glavn", "C", 100, 0 } } )
        Use ( fr_titl ) New Alias FRT
        Append Blank
        frt->name := glob_mo[ _MO_SHORT_NAME ]
        frt->period := arr_m[ 4 ]
        frt->glavn :=  "Главный врач __________________ " + fam_i_o( org->ruk )
        frt->ispoln := "исполнитель: " + AllTrim( mispoln ) + " __________________ тел." + AllTrim( mtel_isp )
        //
        ar := {}
        AAdd( ar, { 2, 3, Month( arr_m[ 6 ] + 1 ) } )
        AAdd( ar, { 2, 4, "." + lstr( Year( arr_m[ 6 ] + 1 ) ) } )
        Use ( fr_data ) New Alias FRD
        For i := 1 To Len( as )
          Goto ( i )
          If i != 4
            AAdd( ar, { 8 + i, 3, frd->v1 } )
          Endif
          If !eq_any( i, 1, 4 )
            AAdd( ar, { 8 + i, 5, frd->v2 } )
          Endif
        Next
        AAdd( ar, { 59, 1, frt->glavn } )
        AAdd( ar, { 61, 1, frt->ispoln } )
        AAdd( arr_excel, { "форма отчета", AClone( ar ) } )
        Close databases
        call_fr( "mo_dvnMZ" )
      Endif
    Endif
  Endif

  Return Nil

// 23.09.15
Function f1_f22_inf_dvn() // сводная информация

  Local i, ar := {}, fl_reg1 := .f., fl_reg2 := .f., is_d := .f., is_pr := .f., ;
    k5 := 0, k9 := 0, m1gruppa, fl

  // диспансеризация I этап
  If Empty( tmp->kod1h )
    // нет 1 этапа, но есть второй
  Else
    human->( dbGoto( tmp->kod1h ) )
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If !Between( m1gruppa, 0, 4 )
      Return Nil
    Endif
    Private m1kurenie := 0, mad1 := 120, mad2 := 80, m1tip_mas := 0, ;
      mholest := 0, mglukoza := 0, ;
      m1holestdn := 0, m1glukozadn := 0, m1fiz_akt := 0, m1ner_pit := 0, ;
      m1riskalk := 0, m1pod_alk := 0, m1psih_na := 0, m1prof_ko := 0, ;
      pole_diag, pole_1stadia, pole_1pervich, mWEIGHT := 0, mHEIGHT := 0
    For i := 1 To 5
      pole_diag := "mdiag" + lstr( i )
      pole_1stadia := "m1stadia" + lstr( i )
      pole_1pervich := "m1pervich" + lstr( i )
      Private &pole_diag := Space( 6 )
      Private &pole_1stadia := 0
      Private &pole_1pervich := 0
    Next
    read_arr_dvn( human->kod )
    ret_tip_mas( mWEIGHT, mHEIGHT, @m1tip_mas )
    If human->schet > 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl_reg1 := .t.
      Endif
    Endif
    //
    AAdd( ar, { 2, 0, 0, fl_reg1 } )
    If m1kurenie == 1
      AAdd( ar, { 9, 1, 0, fl_reg1 } ) ; ++k9
    Endif
    If mad1 > 140 .and. mad2 > 90
      AAdd( ar, { 9, 2, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1tip_mas == 3
      AAdd( ar, { 9, 3, 0, fl_reg1 } ) ; ++k9
    Elseif m1tip_mas > 3
      AAdd( ar, { 9, 4, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1holestdn == 1 .or. mholest > 5
      AAdd( ar, { 9, 5, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1glukozadn == 1 .or. mglukoza > 6.1
      AAdd( ar, { 9, 6, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1fiz_akt == 1
      AAdd( ar, { 9, 7, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1ner_pit == 1
      AAdd( ar, { 9, 8, 0, fl_reg1 } ) ; ++k9
    Endif
    If m1riskalk == 1
      AAdd( ar, { 9, 9, 0, fl_reg1 } ) ; ++k9
    Endif
    If k9 > 1
      AAdd( ar, { 9, 10, 0, fl_reg1 } )
    Endif
    If k9 > 0
      AAdd( ar, { 9, 0, 0, fl_reg1 } )
    Endif
    If m1pod_alk == 1
      AAdd( ar, { 10, 0, 0, fl_reg1 } )
      If m1psih_na == 1
        AAdd( ar, { 11, 0, 1, fl_reg1 } )
      Endif
    Endif
    If !Empty( tmp->kod2h ) // диспансеризация II этап
      human->( dbGoto( tmp->kod2h ) )
      i := ret_gruppa_dvn( human_->RSLT_NEW )
      If Between( i, 1, 4 )
        m1gruppa := i
        If human->schet > 0
          Select SCHET_
          Goto ( human->schet )
          If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
            fl_reg2 := .t.
          Endif
        Endif
        AAdd( ar, { 3, 0, 0, fl_reg2 } )
        If i == 2
          If m1prof_ko == 0
            AAdd( ar, { 12, 0, 0, fl_reg2 } )
          Elseif m1prof_ko == 1
            AAdd( ar, { 13, 0, 0, fl_reg2 } )
          Endif
        Elseif eq_any( i, 3, 4 )
          If m1prof_ko == 0
            AAdd( ar, { 14, 0, 0, fl_reg2 } )
          Elseif m1prof_ko == 1
            AAdd( ar, { 15, 0, 0, fl_reg2 } )
          Endif
        Endif
      Else // если что-то не так со вторым этапом
        human->( dbGoto( tmp->kod1h ) ) // вернуться на 1 этап
      Endif
    Endif
    If Between( m1gruppa, 1, 4 )
      fl := fl_reg1 .or. fl_reg2
      AAdd( ar, { 4, 0, 0, fl } )
      AAdd( ar, { 4, m1gruppa, 0, fl } )
      For i := 1 To 5
        pole_diag := "mdiag" + lstr( i )
        pole_1stadia := "m1stadia" + lstr( i )
        pole_1pervich := "m1pervich" + lstr( i )
        If !Empty( &pole_diag ) .and. &pole_1pervich == 1
          is_d := .t.
          If Left( &pole_diag, 3 ) == "I20"
            AAdd( ar, { 5, 1, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 3 ) == "I25"
            AAdd( ar, { 5, 2, 0, fl } ) ; ++k5
          Elseif eq_any( Left( &pole_diag, 3 ), "I10", "I11", "I12", "I13", "I15" )
            AAdd( ar, { 5, 3, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 5 ) == "I65.2"
            AAdd( ar, { 5, 4, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 3 ) == "I66"
            AAdd( ar, { 5, 5, 0, fl } ) ; ++k5
          Elseif Left( &pole_diag, 1 ) == "C"
            If Left( &pole_diag, 3 ) == "C16"
              AAdd( ar, { 5, 6, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 6, 1, fl } )
              Endif
            Elseif eq_any( Left( &pole_diag, 3 ), "C53", "C54", "C55" )
              AAdd( ar, { 5, 7, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 7, 1, fl } )
              Endif
            Elseif Left( &pole_diag, 3 ) == "C61"
              AAdd( ar, { 5, 8, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 8, 1, fl } )
              Endif
            Elseif Left( &pole_diag, 3 ) == "C50"
              AAdd( ar, { 5, 9, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 9, 1, fl } )
              Endif
            Elseif eq_any( Left( &pole_diag, 3 ), "C17", "C18", "C19", "C20", "C21" )
              AAdd( ar, { 5, 10, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 10, 1, fl } )
              Endif
            Else
              AAdd( ar, { 5, 11, 0, fl } ) ; ++k5
              if &pole_1stadia == 1
                AAdd( ar, { 5, 11, 1, fl } )
              Endif
            Endif
          Elseif eq_any( Left( &pole_diag, 3 ), "E10", "E11", "E12", "E13", "E14" )
            AAdd( ar, { 5, 12, 0, fl } ) ; ++k5
          Elseif eq_any( Left( &pole_diag, 3 ), "A15", "A16" )
            AAdd( ar, { 6, 0, 0, fl } ) ; is_pr := .t.
          Elseif Left( &pole_diag, 3 ) == "H40"
            AAdd( ar, { 7, 0, 0, fl } ) ; is_pr := .t.
            if &pole_1stadia == 1
              AAdd( ar, { 7, 1, 1, fl } )
            Endif
          Endif
        Endif
      Next
      If k5 > 0
        AAdd( ar, { 5, 0, 0, fl } )
      Endif
      If is_d .and. Empty( k5 ) .and. !is_pr
        AAdd( ar, { 8, 0, 0, fl } )
      Endif
    Endif
  Endif
  If !Empty( ar )
    Select FRD
    For i := 1 To Len( ar )
      find ( Str( ar[ i, 1 ], 2 ) + Str( ar[ i, 2 ], 2 ) + Str( ar[ i, 3 ], 2 ) )
      If Found()
        frd->v1++
        If ar[ i, 4 ]
          frd->v2++
        Endif
      Endif
    Next
  Endif

  Return Nil

// 27.09.24 список пациентов
Function f2_inf_dvn( is_schet, par )

  Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, as := {}, ;
    a, sh, HH := 53, n, n_file := cur_dir() + "spis_dvn.txt", reg_print
  Private ppar := par, p_is_schet := is_schet

  If par > 1
    ppar--
  Endif
  If ( st_a_uch := inputn_uch( T_ROW, T_COL -5,,, @lcount_uch ) ) != Nil .and. ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    If f0_inf_dvn( arr_m, eq_any( is_schet, 2, 3 ), is_schet == 3 )
      adbf := { ;
        { "nomer",   "N",     6,     0 }, ;
        { "KOD",   "N",     7,     0 }, ; // код (номер записи)
        { "KOD_K",   "N",     7,     0 }, ; // код по картотеке
        { "FIO",   "C",    50,     0 }, ; // Ф.И.О. больного
        { "DATE_R",   "D",     8,     0 }, ; // дата рождения больного
        { "N_DATA",   "D",     8,     0 }, ; // дата начала лечения
        { "K_DATA",   "D",     8,     0 }, ; // дата окончания лечения
        { "sroki",   "C",    35,     0 }, ; // сроки лечения
        { "CENA_1",   "N",    10,     2 }, ; // оплачиваемая сумма лечения
        { "KOD_DIAG",   "C",     5,     0 }, ; // шифр 1-ой осн.болезни
        { "etap",   "N",     1,     0 }, ; //
        { "gruppa",   "N",     1,     0 }, ; //
        { "vrach",   "C",    15,     0 }, ; // врач
        { "DATA_O",   "C",    35,     0 } ; // сроки другого этапа
      }
      // ret_arrays_disp( .f. )
      ret_arrays_disp()
      Private count_dvn_arr_usl18 := Len( dvn_arr_usl18 )
      Private count_dvn_arr_umolch18 := Len( dvn_arr_umolch18 )
      // ret_arrays_disp( .t., .t. )
      ret_arrays_disp()
      For i := 1 To Max( count_dvn_arr_usl18, count_dvn_arr_usl )
        AAdd( adbf, { "d_" + lstr( i ), "C", 24, 0 } )
      Next
      For i := 1 To Max( count_dvn_arr_umolch18, count_dvn_arr_umolch )
        AAdd( adbf, { "du_" + lstr( i ), "C", 8, 0 } )
      Next
      AAdd( adbf, { "fl_2018", "L", 1, 0 } )
      AAdd( adbf, { "d_zs", "C", 8, 0 } )
      dbCreate( cur_dir() + "tmpfio", adbf )
      Use ( cur_dir() + "tmpfio" ) New Alias TF
      r_use( dir_server() + "uslugi",, "USL" )
      use_base( "human_u" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( dir_server() + "mo_pers",, "PERS" )
      r_use( dir_server() + "schet_",, "SCHET_" )
      Use ( cur_dir() + "tmp" ) new
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( tmp->( RecNo() ) / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorWait
        Do Case
        Case par == 1
          If tmp->kod1h > 0
            f2_inf_dvn_svod( 1, tmp->kod1h )
          Endif
        Case par == 2
          If tmp->kod1h > 0 .and. tmp->kod2h == 0
            f2_inf_dvn_svod( 0, tmp->kod1h )
          Endif
        Case par == 3
          If tmp->kod1h > 0 .and. tmp->kod2h > 0
            f2_inf_dvn_svod( 2, tmp->kod2h )
          Endif
        Case par == 4
          If tmp->kod3h > 0
            f2_inf_dvn_svod( 3, tmp->kod3h )
          Endif
        Endcase
        Select TMP
        Skip
      Enddo
      Close databases
      mywait()
      at := { ;
        { "Внутриглазное давление", { { 1, .t., 1 }, { 1, .f., 1 } }, 0 }, ;
        { "Кровь на общий холестерин", { { 1, .t., 2 }, { 1, .f., 2 }, { 3, .t., 2 }, { 3, .f., 2 } }, 0 }, ;
        { "Уровень глюкозы в крови", { { 1, .t., 3 }, { 1, .f., 3 }, { 3, .t., 3 }, { 3, .f., 3 } }, 0 }, ;
        { "Клинический анализ мочи", { { 1, .t., 4 }, { 1, .f., 4 } }, 0 }, ;
        { "Анализ крови (3 показателя)", { { 1, .t., 5 }, { 1, .f., 5 }, { 3, .t., 5 }, { 3, .f., 5 } }, 0 }, ;
        { "Анализ крови (развёрнутый)", { { 1, .t., 6 }, { 1, .f., 6 } }, 0 }, ;
        { "Биохимический анализ крови", { { 1, .t., 7 }, { 1, .f., 7 } }, 0 }, ;
        { "Кровь на простат-специфический антиген", { { 1, .t., 8 }, { 2, .f., 21 } }, 0 }, ;
        { "Исследование кала на скрытую кровь", { { 1, .t., 9 }, { 1, .f., 8 }, { 3, .t., 9 }, { 3, .f., 8 } }, 0 }, ;
        { "Осмотр акушеркой, взятие мазка (соскоба)", { { 1, .t., 10 }, { 1, .f., 9 } }, 0 }, ;
        { "Маммография молочных желез", { { 1, .t., 11 }, { 1, .f., 11 }, { 3, .t., 11 }, { 3, .f., 11 } }, 0 }, ;
        { "Флюорография лёгких", { { 1, .t., 12 }, { 1, .f., 12 }, { 3, .t., 12 }, { 3, .f., 12 } }, 0 }, ;
        { "УЗИ брюшной полости", { { 1, .t., 13 }, { 1, .f., 13 }, { 1, .f., 15 } }, 0 }, ;
        { "Электрокардиография (в покое)", { { 1, .t., 14 }, { 1, .f., 16 } }, 0 }, ;
        { "Спирометрия", { { 2, .f., 17 } }, 0 }, ;
        { "Гликированный гемоглобин крови", { { 2, .t., 15 }, { 2, .f., 18 } }, 0 }, ;
        { "Толерантность к глюкозе", { { 2, .t., 16 }, { 2, .f., 19 } }, 0 }, ;
        { "Липидный спектр крови", { { 2, .t., 17 }, { 2, .f., 20 } }, 0 }, ;
        { "Сканир-ие брахиоцефальных артерий", { { 2, .t., 18 }, { 2, .f., 22 } }, 0 }, ;
        { "Фиброэзофагогастродуоденоскопия", { { 2, .t., 19 }, { 2, .f., 23 } }, 0 }, ;
        { "Ректоскопия диагностическая", { { 2, .t., 20 }, { 2, .f., 24 } }, 0 }, ;
        { "Ректосигмоколоноскопия диагностическая", { { 2, .t., 21 }, { 2, .f., 25 } }, 0 }, ;
        { "Приём врача невролога", { { 1, .t., 22 }, { 2, .t., 22 }, { 2, .f., 26 } }, 0 }, ;
        { "Приём врача офтальмолога", { { 2, .t., 23 }, { 2, .f., 27 } }, 0 }, ;
        { "Приём врача оториноларинголога", { { 2, .f., 28 } }, 0 }, ;
        { "Приём врача уролога (хирурга)", { { 2, .t., 24 }, { 2, .f., 29 } }, 0 }, ;
        { "Приём врача акушера-гинеколога", { { 2, .t., 25 }, { 2, .f., 30 } }, 0 }, ;
        { "Приём врача колопроктолога (хирурга)", { { 2, .t., 26 }, { 2, .f., 31 } }, 0 }, ;
        { "Приём врача терапевта", { { 1, .t., 27 }, { 1, .f., 32 }, { 2, .t., 27 }, { 2, .f., 32 }, { 3, .t., 27 }, { 3, .f., 32 } }, 0 };
      }
      lat := Len( at )
      aitog := Array( lat ) ; AFill( aitog, 0 ) ; is_zs := 0
      Use ( cur_dir() + "tmpfio" ) New Alias TF
      Index On Upper( fio ) to ( cur_dir() + "tmpfio" )
      Go Top
      Do While !Eof()
        For i := 1 To iif( tf->fl_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
          pole := "tf->d_" + lstr( i )
          If !Empty( &pole )
            For j := 1 To lat
              If at[ j, 3 ] == 0 .and. AScan( at[ j, 2 ], {| x| x[ 1 ] == ppar .and. x[ 2 ] == tf->fl_2018 .and. x[ 3 ] == i } ) > 0
                at[ j, 3 ] := 1 ; Exit
              Endif
            Next
          Endif
        Next
        If Empty( is_zs ) .and. !Empty( tf->d_zs )
          is_zs := 1
        Endif
        Skip
      Enddo
      arr_title := { ;
        "────────────┬────┬──────────┬─────", ;
        "            │Дата│  Сроки   │ Осн.", ;
        "    Ф.И.О   │рожд│ лечения  │диаг-", ;
        "            │ения│          │ ноз ", ;
        "────────────┴────┴──────────┴─────" }
      If ppar == 2
        arr_title[ 1 ] += "┬──────────"
        arr_title[ 2 ] += "│Информация"
        arr_title[ 3 ] += "│о I этапе "
        arr_title[ 4 ] += "│диспан-ции"
        arr_title[ 5 ] += "┴──────────"
      Endif
      For i := 1 To lat
        If at[ i, 3 ] > 0
          arr_title[ 1 ] += "┬────────"
          arr_title[ 2 ] += "│" + PadR( SubStr( at[ i, 1 ], 1, 8 ), 8 )
          arr_title[ 3 ] += "│" + PadR( SubStr( at[ i, 1 ], 9, 8 ), 8 )
          arr_title[ 4 ] += "│" + PadR( SubStr( at[ i, 1 ], 17, 8 ), 8 )
          arr_title[ 5 ] += "┴────────"
        Endif
      Next
      If is_zs > 0
        arr_title[ 1 ] += "┬────────"
        arr_title[ 2 ] += "│  шифр  "
        arr_title[ 3 ] += "│закончен"
        arr_title[ 4 ] += "│ случая "
        arr_title[ 5 ] += "┴────────"
      Endif
      If ppar == 1
        arr_title[ 1 ] += "┬──────────"
        arr_title[ 2 ] += "│Информация"
        arr_title[ 3 ] += "│о II этапе"
        arr_title[ 4 ] += "│диспан-ции"
        arr_title[ 5 ] += "┴──────────"
      Endif
      arr_title[ 1 ] += "┬─┬───────"
      arr_title[ 2 ] += "│Г│ Сумма "
      arr_title[ 3 ] += "│р│ случая"
      arr_title[ 4 ] += "│у│ Врач"
      arr_title[ 5 ] += "┴─┴───────"
      reg_print := f_reg_print( arr_title, @sh, 2 )
      fp := FCreate( n_file ) ; tek_stroke := 0 ; n_list := 1
      add_string( "" )
      If ppar == 1
        add_string( Center( "Диспансеризация взрослого населения 1 этап", sh ) )
        If par == 2
          add_string( Center( "направлены на 2 этап, но ещё не прошли", sh ) )
        Endif
      Elseif ppar == 2
        add_string( Center( "Диспансеризация взрослого населения 2 этап", sh ) )
      Else
        add_string( Center( "Профилактика взрослого населения", sh ) )
      Endif
      If is_schet == 4
        add_string( Center( "[ случаи, ещё не попавшие в счета ]", sh ) )
      Else
        add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      Endif
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      j1 := ss := 0
      Go Top
      Do While !Eof()
        s := lstr( ++j1 ) + ". " + tf->fio
        s1 := SubStr( s, 1, 12 ) + " "
        s2 := SubStr( s, 13, 12 ) + " "
        s3 := SubStr( s, 25, 12 ) + " "
        s := full_date( tf->date_r )
        s1 += PadR( SubStr( s, 1, 3 ), 5 )
        s2 += PadR( SubStr( s, 4, 3 ), 5 )
        s3 += PadR( SubStr( s, 7 ), 5 )
        //
        s1 += PadR( SubStr( tf->sroki, 1, 9 ), 11 )
        s2 += PadR( SubStr( tf->sroki, 10, 9 ), 11 )
        s3 += PadR( SubStr( tf->sroki, 19 ), 11 )
        //
        s1 += PadR( tf->KOD_DIAG, 6 )
        s2 += Space( 6 )
        s3 += Space( 6 )
        If ppar == 2
          s1 += PadR( SubStr( tf->data_o, 1, 9 ), 11 )
          s2 += PadR( SubStr( tf->data_o, 10, 9 ), 11 )
          s3 += PadR( SubStr( tf->data_o, 19 ), 11 )
        Endif
        For i := 1 To lat
          If at[ i, 3 ] > 0
            fl := .t.
            For j := 1 To Len( at[ i, 2 ] )
              If at[ i, 2, j, 1 ] == ppar .and. at[ i, 2, j, 2 ] == tf->fl_2018
                pole := "tf->d_" + lstr( at[ i, 2, j, 3 ] ) // номер элемента из массива ф-ии mo_init
                If !Empty( &pole )
                  s1 += PadR( SubStr( &pole, 1, 8 ), 9 )
                  s2 += PadR( SubStr( &pole, 9, 8 ), 9 )
                  s3 += PadR( SubStr( &pole, 17 ), 9 )
                  If Between( Left( &pole, 1 ), '0', '9' )
                    aitog[ i ] ++
                  Endif
                  fl := .f.
                  Exit
                Endif
              Endif
            Next
            If fl
              s1 += Space( 9 )
              s2 += Space( 9 )
              s3 += Space( 9 )
            Endif
          Endif
        Next
        If is_zs > 0
          s1 += PadR( tf->d_zs, 9 )
          s2 += Space( 9 )
          s3 += Space( 9 )
        Endif
        If ppar == 1
          s1 += PadR( SubStr( tf->data_o, 1, 9 ), 11 )
          s2 += PadR( SubStr( tf->data_o, 10, 9 ), 11 )
          s3 += PadR( SubStr( tf->data_o, 19 ), 11 )
        Endif
        s1 += iif( tf->gruppa == 4, "3", put_val( tf->gruppa, 1 ) ) + Str( tf->CENA_1, 8, 2 )
        If tf->gruppa > 2
          s2 += iif( tf->gruppa == 3, "а", "б" )
        Endif
        s3 += AllTrim( tf->vrach )
        ss += tf->CENA_1
        If verify_ff( HH -3, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        add_string( s2 )
        add_string( s3 )
        add_string( Replicate( "─", sh ) )
        Skip
      Enddo
      s1 := PadR( "Итого:", 13 + 5 + 11 + 6 )
      If ppar == 2
        s1 += Space( 11 )
      Endif
      For i := 1 To lat
        If at[ i, 3 ] > 0
          If Empty( aitog[ i ] )
            Space( 9 )
          Else
            s1 += PadC( lstr( aitog[ i ] ), 8 ) + " "
          Endif
        Endif
      Next
      i := 0
      If is_zs > 0
        i += 9
      Endif
      If ppar == 1
        i += 11
      Endif
      i += 2
      s1 += Str( ss, 7 + i, 2 )
      add_string( s1 )
      Close databases
      FClose( fp )
      Private yes_albom := .t.
      viewtext( n_file,,,, ( sh > 80 ),,, reg_print )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 27.09.24
Function f2_inf_dvn_svod( par, kod_h ) // сводная информация

  Static P_BEGIN_RSLT := 342
  Local i, j, c, s, pole, ar, arr := {}, fl, lshifr, arr_usl := {}
  Private metap := ppar, m1gruppa, mvozrast, mdvozrast, mpol, mn_data, mk_data, ;
    arr_usl_dop := {}, arr_usl_otkaz := {}, arr_otklon := {}, m1veteran := 0, mvar, ;
    fl2 := .f., mshifr_zs := "", is_2019

  Select HUMAN
  Goto ( kod_h )
  mpol    := human->pol
  mn_data := human->n_data
  mk_data := human->k_data
  is_2018 := p := ( mk_data < 0d20190501 )
  is_2021 := p := ( mk_data < 0d20210101 )
  is_2019 := !is_2018
  ret_arr_vozrast_dvn( mk_data )
  // ret_arrays_disp( is_2019, is_2021 )
  ret_arrays_disp( mk_data )
  If ppar == 1 // диспансеризация 1 этап
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW, @fl2 )
    If Between( m1gruppa, 0, 4 )
      If m1gruppa == 0
        fl2 := .t. // направлен на 2 этап
      Endif
    Else
      Return Nil
    Endif
    If par == 0 .and. !fl2
      Return Nil
    Endif
  Elseif ppar == 2 // диспансеризация 2 этап
    m1GRUPPA := ret_gruppa_dvn( human_->RSLT_NEW )
    If Between( m1gruppa, 1, 4 )
      //
    Else
      Return Nil
    Endif
  Elseif ppar == 3 // профилактика
    m1GRUPPA := 0
    If Between( human_->RSLT_NEW, 343, 345 )
      m1GRUPPA := human_->RSLT_NEW - 342
    Elseif Between( human_->RSLT_NEW, 373, 374 )
      m1GRUPPA := human_->RSLT_NEW - 370
    Endif
    If !Between( m1gruppa, 1, 4 )
      Return Nil
    Endif
  Else
    Return Nil
  Endif
  read_arr_dvn( kod_h )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  If m1veteran == 1
    mdvozrast := ret_vozr_dvn_veteran( mdvozrast, human->k_data )
  Endif
  For i := 1 To iif( is_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
    mvar := "MTAB_NOMv" + lstr( i )
    Private &mvar := 0
    mvar := "MDATE" + lstr( i )
    Private &mvar := CToD( "" )
    mvar := "M1OTKAZ" + lstr( i )
    Private &mvar := 0
  Next
  fl := .f.
  If ppar == 1 .and. tmp->kod2h > 0
    Select HUMAN
    Goto ( tmp->kod2h )
    fl := ( human_->oplata != 9 )
  Elseif ppar == 2 .and. tmp->kod1h > 0
    Select HUMAN
    Goto ( tmp->kod1h )
    fl := ( human_->oplata != 9 )
  Endif
  If fl
    s := "не в счёте"
    If human->schet > 0
      s := "незарег.сч"
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // зарегистрированные
        s := "счёт зарег"
      Endif
    Endif
    AAdd( arr, { human->n_data, human->k_data, s } )
  Endif
  Select HUMAN
  Goto ( kod_h )
  If p_is_schet == 4 .and. human->schet > 0
    Return Nil
  Endif
  s := "не в счёте"
  If human->schet > 0
    s := "незарег.сч"
    Select SCHET_
    Goto ( human->schet )
    If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // зарегистрированные
      s := "счёт зарег"
    Endif
  Endif
  Select TF
  Append Blank
  tf->KOD    := human->kod
  tf->KOD_K  := tmp->kod_k
  tf->FIO    := human->fio
  tf->DATE_R := human->date_r
  tf->N_DATA := mN_DATA
  tf->K_DATA := mK_DATA
  tf->sroki  := date_8( mN_DATA ) + "-" + date_8( mK_DATA ) + " " + s
  tf->CENA_1 := human->CENA_1
  tf->etap   := metap
  tf->gruppa := m1gruppa
  tf->KOD_DIAG := human->kod_diag
  If Len( arr ) > 0
    tf->data_o := date_8( arr[ 1, 1 ] ) + "-" + date_8( arr[ 1, 2 ] ) + " " + arr[ 1, 3 ]
  Endif
  pers->( dbGoto( human_->vrach ) )
  tf->vrach := fam_i_o( pers->fio )
  lcount := iif( is_2018, count_dvn_arr_usl18, count_dvn_arr_usl )
  larr_dvn := iif( is_2018, dvn_arr_usl18, dvn_arr_usl )
  lcount_u := iif( is_2018, count_dvn_arr_umolch18, count_dvn_arr_umolch )
  larr_dvn_u := iif( is_2018, dvn_arr_umolch18, dvn_arr_umolch )
  larr := Array( 2, lcount ) ; afillall( larr, 0 )
  Select HU
  find ( Str( kod_h, 7 ) )
  Do While hu->kod == kod_h .and. !Eof()
    usl->( dbGoto( hu->u_kod ) )
    If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, mk_data ) )
      lshifr := usl->shifr
    Endif
    lshifr := AllTrim( lshifr )
    If !eq_any( Left( lshifr, 5 ), "70.3.", "70.7.", "72.1.", "72.5.", "72.6.", "72.7.", "2.90." )
      mshifr_zs := lshifr
    Else
      fl := .t.
      If metap != 2
        If is_2018
          If lshifr == "2.3.3" .and. hu_->PROFIL == 3 ; // акушерскому делу
            .and. ( i := AScan( dvn_arr_usl18, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == "4.20.1" } ) ) > 0
            fl := .f. ; larr[ 1, i ] := hu->( RecNo() )
          Endif
        Else
        /*if ((lshifr == "2.3.3" .and. hu_->PROFIL == 3) .or.  ; // акушерскому делу
              (lshifr == "2.3.1" .and. hu_->PROFIL == 136))  ; // акушерству и гинекологии
            .and. (i := ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"})) > 0
          fl := .f. ; larr[1,i] := hu->(recno())
        endif*/
        Endif
      Endif
      If fl
        For i := 1 To lcount_u
          If Empty( larr[ 2, i ] ) .and. larr_dvn_u[ i, 2 ] == lshifr
            fl := .f. ; larr[ 2, i ] := hu->( RecNo() ) ; Exit
          Endif
        Next
      Endif
      If fl
        For i := 1 To lcount
          If Empty( larr[ 1, i ] )
            If ValType( larr_dvn[ i, 2 ] ) == "C"
              If larr_dvn[ i, 2 ] == lshifr
                fl := .f.
              Elseif larr_dvn[ i, 2 ] == "4.20.1" .and. lshifr == "4.20.2"
                fl := .f.
              Endif
            Elseif Len( larr_dvn[ i ] ) > 11
              If AScan( larr_dvn[ i, 12 ], {| x| x[ 1 ] == lshifr .and. x[ 2 ] == hu_->PROFIL } ) > 0
                fl := .f.
              Endif
            Endif
            If !fl
              larr[ 1, i ] := hu->( RecNo() ) ; Exit
            Endif
          Endif
        Next
      Endif
    Endif
    AAdd( arr_usl, hu->( RecNo() ) )
    Select HU
    Skip
  Enddo
  For i := 1 To lcount
    If !Empty( larr[ 1, i ] )
      hu->( dbGoto( larr[ 1, i ] ) )
      If hu->kod_vr > 0
        mvar := "MTAB_NOMv" + lstr( i )
        &mvar := hu->kod_vr
      Endif
      mvar := "MDATE" + lstr( i )
      &mvar := c4tod( hu->date_u )
      mvar := "M1OTKAZ" + lstr( i )
      If metap != 2
        If is_2018
          If hu_->PROFIL == 3 .and. ;
              AScan( dvn_arr_usl18, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == "4.20.1" } ) > 0
            &mvar := 2 // невозможность выполнения
          Endif
        Else
        /*if (hu_->PROFIL == 3 .or. hu_->PROFIL == 136)  ;
            .and. ascan(dvn_arr_usl, {|x| valtype(x[2])=="C" .and. x[2]=="4.1.12"}) > 0
          &mvar := 2 // невозможность выполнения
        endif*/
        Endif
      Endif
    Endif
  Next
  If metap != 2 .and. ValType( arr_usl_otkaz ) == "A"
    For j := 1 To Len( arr_usl_otkaz )
      ar := arr_usl_otkaz[ j ]
      If ValType( ar ) == "A" .and. Len( ar ) >= 5 .and. ValType( ar[ 5 ] ) == "C"
        lshifr := AllTrim( ar[ 5 ] )
        If ( i := AScan( larr_dvn, {| x| ValType( x[ 2 ] ) == "C" .and. x[ 2 ] == lshifr } ) ) > 0
          If ValType( ar[ 1 ] ) == "N" .and. ar[ 1 ] > 0
            mvar := "MTAB_NOMv" + lstr( i )
            &mvar := ar[ 1 ]
          Endif
          mvar := "MDATE" + lstr( i )
          &mvar := mn_data
          If Len( ar ) >= 9 .and. ValType( ar[ 9 ] ) == "D"
            &mvar := ar[ 9 ]
          Endif
          mvar := "M1OTKAZ" + lstr( i )
          &mvar := 1
          If Len( ar ) >= 10 .and. ValType( ar[ 10 ] ) == "N" .and. Between( ar[ 10 ], 1, 2 )
            &mvar := ar[ 10 ]
          Endif
        Endif
      Endif
    Next
  Endif
  //
  If is_2018
    arr := f21_inf_dvn_svod18( 1 )
  Else
    arr := f21_inf_dvn_svod( 1 )
  Endif
  For i := 1 To Len( arr )
    pole := "tf->d_" + lstr( arr[ i, 4 ] )
    If arr[ i, 5 ] == 1
      &pole := "отказ   пациента"
    Elseif arr[ i, 5 ] == 2
      &pole := "невозможность выполнения"
    Else
      &pole := date_8( arr[ i, 2 ] )
    Endif
  Next
  tf->d_zs := mshifr_zs
  tf->fl_2018 := is_2018
  If is_2018
    arr := f21_inf_dvn_svod18( 2 )
  Else
    arr := f21_inf_dvn_svod( 2 )
  Endif
  For i := 1 To Len( arr )
    pole := "tf->du_" + lstr( arr[ i, 4 ] )
    &pole := date_8( arr[ i, 2 ] )
  Next

  Return Nil

// 10.11.19
Function f21_inf_dvn_svod18( par )

  Local i, arr := {}

  If par == 1
    For i := 1 To count_dvn_arr_usl18
      mvart := "MTAB_NOMv" + lstr( i )
      mvard := "MDATE" + lstr( i )
      mvaro := "M1OTKAZ" + lstr( i )
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dvn_arr_usl18[ i, 1 ], &mvard, "", i, &mvaro } )
        Endif
      Endif
    Next
  Else
    For i := 1 To count_dvn_arr_umolch18
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        AAdd( arr, { dvn_arr_umolch18[ i, 1 ], iif( dvn_arr_umolch18[ i, 8 ] == 0, mn_data, mk_data ), "", i, 0 } )
      Endif
    Next
  Endif

  Return arr

// 08.12.15
Function f21_inf_dvn_svod( par )

  Local i, arr := {}

  If par == 1
    For i := 1 To count_dvn_arr_usl
      mvart := "MTAB_NOMv" + lstr( i )
      mvard := "MDATE" + lstr( i )
      mvaro := "M1OTKAZ" + lstr( i )
      If f_is_usl_oms_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        If !emptyany( &mvard, &mvart )
          AAdd( arr, { dvn_arr_usl[ i, 1 ], &mvard, "", i, &mvaro } )
        Endif
      Endif
    Next
  Else
    For i := 1 To count_dvn_arr_umolch
      If f_is_umolch_sluch_dvn( i, metap, iif( metap == 3, mvozrast, mdvozrast ), mpol )
        AAdd( arr, { dvn_arr_umolch[ i, 1 ], iif( dvn_arr_umolch[ i, 8 ] == 0, mn_data, mk_data ), "", i, 0 } )
      Endif
    Next
  Endif

  Return arr

// 19.02.18 Информация по профилактике и медосмотрам несовершеннолетних
Function inf_dnl( k )

  Static si1 := 1, si2 := 1, sj1 := 1, sj2 := 1
  Local mas_pmt, mas_msg, mas_fun, j, j1, j2
  Local mas2pmt := { "Про~филактические осмотры", ;
    "Пре~дварительные осмотры", ;
    "Пе~риодические осмотры" }

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~Карта проф.медосмотра", ;
      "~Список пациентов", ;
      "~Многовариантный запрос", ;
      "Своды для Обл~здрава", ;
      "Форма № 030-ПО/~о-17", ;
      "XML-файл для ~портала МЗРФ" }
    mas_msg := { "Карта профилактического медосмотра несовершеннолетнего (форма № 030-ПО/у-17)", ;
      "Просмотр спика пациентов, прошедших медосмотры", ;
      "Многовариантный запрос по диспансеризации/медосмотрам несовершеннолетних", ;
      "Распечатка сводов для Волгоградского областного Комитета здравоохранения", ;
      "Сведения о профилактических осмотрах несовершеннолетних (форма № 030-ПО/о-17)", ;
      "Создание XML-файла для загрузки на портал Минздрава РФ" }
    mas_fun := { "inf_DNL(11)", ;
      "inf_DNL(12)", ;
      "inf_DNL(13)", ;
      "inf_DNL(14)", ;
      "inf_DNL(15)", ;
      "inf_DNL(16)" }
    Private p_tip_lu := TIP_LU_PN
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    inf_dnl_karta()
  Case k == 12
    ne_real()
  Case k == 13
    mnog_poisk_dnl()
  Case k == 14
    mas_pmt := { "~Сведения о профосмотрах детей по состоянию на ..." }
    mas_msg := { "Приложение к Приказу ВОМИАЦ №1025 от 08.07.2019г." }
    mas_fun := { "inf_DNL(21)" }
    popup_prompt( T_ROW, T_COL -5, si2, mas_pmt, mas_msg, mas_fun )
  Case k == 15
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      inf_dnl_030poo( j1 )
    Endif
  Case k == 16
    // if (j2 := popup_prompt(T_ROW,T_COL-5,sj2,mas2pmt,,,"N/W,GR+/R,B/W,W+/R")) > 0
    // sj2 := j2
    // p_tip_lu := {TIP_LU_PN,TIP_LU_PREDN,TIP_LU_PERN}[j2]
    p_tip_lu := TIP_LU_PN
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      // inf_DNL_XMLfile(j1,charrem("~",mas2pmt[j2]))
      inf_dnl_xmlfile( j1, "Профилактические осмотры" )
    Endif
    // endif
  Case k == 21
    If ( j1 := popup_prompt( T_ROW, T_COL -5, 1, mas1pmt ) ) > 0
      f21_inf_dnl( j1 )
    Endif
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

// 25.03.18 Распечатка карты проф.мед.осмотра (учётная форма № 030-ПО/у...)
Function inf_dnl_karta()

  Local arr_m, buf := save_maxrow(), blk, t_arr[ BR_LEN ]

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    If f0_inf_dnl( arr_m, .f. )
      Copy File ( cur_dir() + "tmp" + sdbf() ) to ( cur_dir() + "tmpDNL" + sdbf() ) // т.к. внутри тоже есть TMP-файл
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmpDNL" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmpDNL" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        r_use( cur_dir() + "tmpDNL", cur_dir() + "tmpDNL", "TMP" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := T_ROW
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      t_arr[ BR_TITUL ] := "Профосмотры несовершеннолетних " + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( human->schet > 0, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " Ф.И.О.", {|| PadR( human->fio, 39 ) }, blk }, ;
        { "Дата рожд.", {|| full_date( human->date_r ) }, blk }, ;
        { "№ ам.карты", {|| human->uch_doc }, blk }, ;
        { "Сроки леч-я", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "Этап", {|| iif( human->ishod == 301, " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход;  ^<Enter>^ - распечатать карту профилактического мед.осмотра" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_dnl_karta( nk, ob, "edit" ) }
      edit_browse( t_arr )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 11.03.19
Function f0_inf_dnl( arr_m, is_schet, is_reg, arr_ishod, is_snils )

  Local fl := .t.

  Default is_schet To .t., is_reg To .f., is_snils To .f., arr_ishod TO { 301, 302 } // профилактика 1 и 2 этап
  If !del_dbf_file( cur_dir() + "tmp" + sdbf() )
    Return .f.
  Endif
  dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 }, ;
    { "kod_k", "N", 7, 0 }, ;
    { "is", "N", 1, 0 }, ;
    { "ishod", "N", 6, 0 } } )
  Use ( cur_dir() + "tmp" ) new
  r_use( dir_server() + "schet_",, "SCHET_" )
  r_use( dir_server() + "kartotek",, "KART" )
  r_use( dir_server() + "human_",, "HUMAN_" )
  r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
  Set Relation To RecNo() into HUMAN_, To kod_k into KART
  dbSeek( DToS( arr_m[ 5 ] ), .t. )
  Index On kod to ( cur_dir() + "tmp_h" ) ;
    For AScan( arr_ishod, ishod ) > 0 .and. iif( is_schet, schet > 0, .t. ) ;
    While human->k_data <= arr_m[ 6 ] ;
    PROGRESS
  Go Top
  Do While !Eof()
    fl := .t.
    If is_reg
      fl := .f.
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        fl := .t.
      Endif
    Endif
    If fl .and. ret_koef_from_rak( human->kod ) > 0
      Select TMP
      Append Blank
      tmp->kod := human->kod
      tmp->kod_k := human->kod_k
      tmp->ishod := human->ishod
      tmp->is := iif( is_snils .and. Empty( kart->snils ), 0, 1 )
    Endif
    Select HUMAN
    Skip
  Enddo
  fl := .t.
  If tmp->( LastRec() ) == 0
    fl := func_error( 4, "Не найдено л/у по медосмотрам несовершеннолетних " + arr_m[ 4 ] )
  Endif
  Close databases

  Return fl

// 07.08.13
Function f1_inf_dnl_karta( nKey, oBrow, regim )

  Local ret := -1, lkod_h, lkod_k, rec := tmp->( RecNo() ), buf := save_maxrow()

  If regim == "edit" .and. nKey == K_ENTER
    mywait()
    lkod_h := human->kod
    lkod_k := human->kod_k
    Close databases
    oms_sluch_pn( lkod_h, lkod_k, "f2_inf_DNL_karta" )
    Eval( blk_open )
    Goto ( rec )
    rest_box( buf )
  Endif

  Return ret

// 13.09.25
Function f2_inf_dnl_karta( Loc_kod, kod_kartotek, lvozrast )

  Static st := "     ", ub := "<u><b>", ue := "</b></u>", sh := 88
  Local adbf, s, i, j, k, y, m, d, fl, mm_danet, blk := {| s| __dbAppend(), field->stroke := s }
  local mm_invalid5 := mm_invalid5()

  delfrfiles()
  r_use( dir_server() + "mo_stdds" )
  If Type( "m1stacionar" ) == "N" .and. m1stacionar > 0
    Goto ( m1stacionar )
  Endif
  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "mo_pers",, "P2" )
  Goto ( m1vrach )
  r_use( dir_server() + "organiz",, "ORG" )
  adbf := { { "name", "C", 130, 0 }, ;
    { "prikaz", "C", 50, 0 }, ;
    { "forma", "C", 50, 0 }, ;
    { "titul", "C", 100, 0 }, ;
    { "fio", "C", 50, 0 }, ;
    { "k_data", "C", 40, 0 }, ;
    { "vrach", "C", 40, 0 }, ;
    { "glavn", "C", 40, 0 } }
  dbCreate( fr_titl, adbf )
  Use ( fr_titl ) New Alias FRT
  Append Blank
  frt->name := glob_mo[ _MO_SHORT_NAME ]
  frt->fio := mfio
  frt->k_data := date_month( mk_data )
  frt->vrach := fam_i_o( p2->fio )
  frt->glavn := fam_i_o( org->ruk )
  adbf := { { "stroke", "C", 2000, 0 } }
  dbCreate( fr_data, adbf )
  Use ( fr_data ) New Alias FRD
  frt->prikaz := "от 10 августа 2017 г. № 514н"
  frt->forma  := "030-ПО/у-17"
  frt->titul  := "Карта профилактического осмотра несовершеннолетнего"
  s := st + "1. Фамилия, имя, отчество (при наличии) несовершеннолетнего: " + ub + AllTrim( mfio ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "Пол: " + f3_inf_dds_karta( { { "муж.", "М" }, { "жен.", "Ж" } }, mpol, "/", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "Дата рождения: " + ub + date_month( mdate_r, .t. ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "2. Полис обязательного медицинского страхования: "
  s += "серия " + iif( Empty( mspolis ), Replicate( "_", 15 ), ub + AllTrim( mspolis ) + ue )
  s += " № " + ub + AllTrim( mnpolis ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "Страховая медицинская организация: " + ub + AllTrim( mcompany ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "3. Страховой номер индивидуального лицевого счета: "
//  s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform( kart->SNILS, picture_pf ) + ue ) + "."
  s += iif( Empty( kart->snils ), Replicate( "_", 25 ), ub + Transform_SNILS( kart->SNILS ) + ue ) + "."
  frd->( Eval( blk, s ) )
  s := st + "4. Адрес места жительства (пребывания): "
  If emptyall( kart_->okatog, kart->adres )
    s += Replicate( "_", 37 ) + " " + Replicate( "_", sh ) + "."
  Else
    s += ub + ret_okato_ulica( kart->adres, kart_->okatog, 1, 2 ) + ue + "."
  Endif
  frd->( Eval( blk, s ) )
  s := st + "5. Категория: " + f3_inf_dds_karta( mm_kateg_uch(), m1kateg_uch, "; ", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "6. Полное наименование медицинской организации, в которой " + ;
    "несовершеннолетний получает первичную медико-санитарную помощь: "
  s += ub + ret_mo( m1MO_PR )[ _MO_FULL_NAME ] + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "7. Адрес места нахождения медицинской организации, в которой " + ;
    "несовершеннолетний получает первичную медико-санитарную помощь: "
  s += ub + ret_mo( m1MO_PR )[ _MO_ADRES ] + ue + "."
  frd->( Eval( blk, s ) )
  madresschool := ""
  If Type( "m1school" ) == "N" .and. m1school > 0
    r_use( dir_server() + "mo_schoo",, "SCH" )
    Goto ( m1school )
    If !Empty( sch->fname )
      mschool := AllTrim( sch->fname )
      madresschool := AllTrim( sch->adres )
    Endif
  Endif
  s := st + "8. Полное наименование образовательной организации, в которой " + ;
    "обучается несовершеннолетний: " + ub + mschool + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "9. Адрес места нахождения образовательной организации, в которой " + ;
    "обучается несовершеннолетний: "
  If Empty( madresschool )
    frd->( Eval( blk, s ) )
    s := Replicate( "_", sh ) + "."
  Else
    s += ub + madresschool + ue + "."
  Endif
  frd->( Eval( blk, s ) )
  s := st + "10. Дата начала профилактического медицинского осмотра несовершеннолетнего (далее - профилактический осмотр): " + ub + full_date( mn_data ) + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "11. Полное наименование и адрес места нахождения медицинской организации, " + ;
    "проводившей профилактический осмотр: " + ;
    ub + glob_mo[ _MO_FULL_NAME ] + ", " + glob_mo[ _MO_ADRES ] + ue + "."
  frd->( Eval( blk, s ) )
  s := st + "12. Оценка физического развития с учетом возраста на момент профилактического осмотра:"
  frd->( Eval( blk, s ) )
  count_ymd( mdate_r, mn_data, @y, @m, @d )
  s := ub + st + lstr( d ) + st + ue + " (число дней) " + ;
    ub + st + lstr( m ) + st + ue + " (месяцев) " + ;
    ub + st + lstr( y ) + st + ue + " лет."
  frd->( Eval( blk, s ) )
  mm_fiz_razv1 := { { "дефицит массы тела", 1 }, { "избыток массы тела", 2 } }
  mm_fiz_razv2 := { { "низкий рост", 1 }, { "высокий рост", 2 } }
  For i := 1 To 2
    s := st + "12." + lstr( i ) + ". Для детей в возрасте " + ;
      { "0 - 4 лет: ", "5 - 17 лет включительно: " }[ i ]
    If i == 1
      fl := ( lvozrast < 5 )
    Else
      fl := ( lvozrast > 4 )
    Endif
    s += "масса (кг) " + iif( !fl, "________", ub + st + lstr( mWEIGHT ) + st + ue ) + "; "
    s += "рост (см) " + iif( !fl, "________", ub + st + lstr( mHEIGHT ) + st + ue ) + "; "
    If i == 1
      s += "окружность головы (см) " + iif( !fl .or. mPER_HEAD == 0, "________", ub + st + lstr( mPER_HEAD ) + st + ue ) + "; "
    Endif
    s += "физическое развитие " + f3_inf_dds_karta( mm_fiz_razv(), iif( fl, m1FIZ_RAZV, -1 ),, ub, ue, .f. )
    s += " (" + f3_inf_dds_karta( mm_fiz_razv1, iif( fl, m1FIZ_RAZV1, -1 ),, ub, ue, .f. )
    s += ", " + f3_inf_dds_karta( mm_fiz_razv2, iif( fl, m1FIZ_RAZV2, -1 ),, ub, ue, .f. )
    s += " - нужное подчеркнуть)."
    frd->( Eval( blk, s ) )
  Next
  fl := ( lvozrast < 5 )
  s := st + "13. Оценка психического развития (состояния):"
  frd->( Eval( blk, s ) )
  s := st + "13.1. Для детей в возрасте 0 - 4 лет:"
  frd->( Eval( blk, s ) )
  s := st + "познавательная функция (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih11 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "моторная функция (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih12 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih13 ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "предречевое и речевое развитие (возраст развития) " + iif( !fl, "________", ub + st + lstr( m1psih14 ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( lvozrast > 4 )
  s := st + "13.2. Для детей в возрасте 5 - 17 лет:"
  frd->( Eval( blk, s ) )
  s := st + "13.2.1. Психомоторная сфера: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.2. Интеллект: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "13.2.3. Эмоционально-вегетативная сфера: " + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
  frd->( Eval( blk, s ) )
  fl := ( mpol == "М" .and. lvozrast > 9 )
  s := st + "14. Оценка полового развития (с 10 лет):"
  frd->( Eval( blk, s ) )
  s := st + "14.1. Половая формула мальчика: Р " + iif( !fl .or. m141p == 0, "________", ub + st + lstr( m141p ) + st + ue )
  s += " Ах " + iif( !fl .or. m141ax == 0, "________", ub + st + lstr( m141ax ) + st + ue )
  s += " Fa " + iif( !fl .or. m141fa == 0, "________", ub + st + lstr( m141fa ) + st + ue ) + "."
  frd->( Eval( blk, s ) )
  fl := ( mpol == "Ж" .and. lvozrast > 9 )
  s := st + "14.2. Половая формула девочки: Р " + iif( !fl .or. m142p == 0, "________", ub + st + lstr( m142p ) + st + ue )
  s += " Ах " + iif( !fl .or. m142ax == 0, "________", ub + st + lstr( m142ax ) + st + ue )
  s += " Ma " + iif( !fl .or. m142ma == 0, "________", ub + st + lstr( m142ma ) + st + ue )
  s += " Me " + iif( !fl .or. m142me == 0, "________", ub + st + lstr( m142me ) + st + ue ) + ";"
  frd->( Eval( blk, s ) )
  s := st + "характеристика менструальной функции: menarhe ("
  s += iif( !fl .or. m142me1 == 0, "________", ub + st + lstr( m142me1 ) + st + ue ) + " лет, "
  s += iif( !fl .or. m142me2 == 0, "________", ub + st + lstr( m142me2 ) + st + ue ) + " месяцев); "
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += "menses (характеристика): " + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ", " + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), " и ", ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "15. Состояние здоровья до проведения настоящего профилактического осмотра:"
  frd->( Eval( blk, s ) )
  If lvozrast < 14
    mdef_diagnoz := "Z00.1"
  Else
    mdef_diagnoz := "Z00.3"
  Endif
  s := st + "15.1. Практически здоров " + iif( m1diag_15_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mdef_diagnoz ) + st + ue ) + " (код по МКБ)."
  frd->( Eval( blk, s ) )
  //
  mm_dispans := { { "установлено ранее", 1 }, { "установлено впервые", 2 }, { "не установлено", 0 } }
  mm_danet := { { "да", 1 }, { "нет", 0 } }
  mm_usl := { { "в амбулаторных условиях", 0 }, ;
    { "в условиях дневного стационара", 1 }, ;
    { "в стационарных условиях", 2 } }
  mm_uch := { { "в муниципальных медицинских организациях", 1 }, ;
    { "в государственных медицинских организациях субъекта Российской Федерации ", 0 }, ;
    { "в федеральных медицинских организациях", 2 }, ;
    { "частных медицинских организациях", 3 } }
  mm_uch1 := AClone( mm_uch )
  AAdd( mm_uch1, { "санаторно-курортных организациях", 4 } )
  mm_danet1 := { { "оказана", 1 }, { "не оказана", 0 } }
  For i := 1 To 5
    fl := .f.
    For k := 1 To 14
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 4, 5, 6, 7 )
            mvar := "m1diag_15_" + lstr( i ) + "_3"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 9, 10, 11, 12 )
            mvar := "m1diag_15_" + lstr( i ) + "_8"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case k == 14
            mvar := "m1diag_15_" + lstr( i ) + "_13"
            if &mvar != 1 // если не "да"
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
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := ""
    For k := 1 To 2
      mvar := "mdiag_15_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_15_1 == 0
      Else
        m1var := "m1diag_15_" + lstr( i ) + "_" + lstr( k )
        If ( j := &m1var ) > 0
          j := 1
        Endif
      Endif
      Do Case
      Case k == 1
        s := st + "15." + lstr( i + 1 ) + ". Диагноз " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (код по МКБ)."
      Case k == 2
        s1 := st + "15." + lstr( i + 1 ) + ".1. Диспансерное наблюдение установлено: " + f3_inf_dds_karta( mm_danet, j,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
  Next
  mm_gruppa := { { "I", 1 }, { "II", 2 }, { "III", 3 }, { "IV", 4 }, { "V", 5 } }
  s := st + "15.7. Группа состояния здоровья: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "15.8. Медицинская группа для занятий физической культурой: " + f3_inf_dds_karta( mm_gr_fiz_do, m1GR_FIZ_DO,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "16. Состояние здоровья по результатам проведения настоящего профилактического осмотра:"
  frd->( Eval( blk, s ) )
  s := st + "16.1. Практически здоров " + iif( m1diag_16_1 == 0, Replicate( "_", 30 ), ub + st + RTrim( mkod_diag ) + st + ue ) + " (код по МКБ)."
  frd->( Eval( blk, s ) )
  For i := 1 To 5
    fl := .f.
    For k := 1 To 16
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
        If fl
          Do Case
          Case eq_any( k, 5, 6 )
            mvar := "m1diag_16_" + lstr( i ) + "_4"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 8, 9 )
            mvar := "m1diag_16_" + lstr( i ) + "_7"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 11, 12 )
            mvar := "m1diag_16_" + lstr( i ) + "_10"
            if &mvar != 1 // если не "да"
              &m1var := -1
            Endif
          Case eq_any( k, 14, 15 )
            mvar := "m1diag_16_" + lstr( i ) + "_13"
            if &mvar != 1 // если не "да"
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
    fl := .f.
    s := s1 := s2 := s3 := s4 := s5 := s6 := s7 := ""
    For k := 1 To 15
      mvar := "mdiag_16_" + lstr( i ) + "_" + lstr( k )
      If k == 1
        fl := !Empty( &mvar ) .and. m1diag_16_1 == 0
      Else
        m1var := "m1diag_16_" + lstr( i ) + "_" + lstr( k )
      Endif
      Do Case
      Case k == 1
        s := st + "16." + lstr( i + 1 ) + ". Диагноз " + iif( !fl, Replicate( "_", 30 ), ub + st + RTrim( &mvar ) + st + ue ) + " (код по МКБ)."
      Case k == 2
        s1 := st + "16." + lstr( i + 1 ) + ".1. Диагноз установлен впервые: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 3
        s2 := st + "16." + lstr( i + 1 ) + ".2. Диспансерное наблюдение: " + f3_inf_dds_karta( mm_dispans, &m1var,, ub, ue )
      Case k == 4
        s3 := st + "16." + lstr( i + 1 ) + ".3. Дополнительные консультации и исследования назначены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 5
        s3 := Left( s3, Len( s3 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 6
        s3 := Left( s3, Len( s3 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 7
        s4 := st + "16." + lstr( i + 1 ) + ".4. Дополнительные консультации и исследования выполнены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 8
        s4 := Left( s4, Len( s4 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 9
        s4 := Left( s4, Len( s4 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 10
        s5 := st + "16." + lstr( i + 1 ) + ".5. Лечение назначено: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 11
        s5 := Left( s5, Len( s5 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 12
        s5 := Left( s5, Len( s5 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch, &m1var,, ub, ue )
      Case k == 13
        s6 := st + "16." + lstr( i + 1 ) + ".6. Медицинская реабилитация и (или) санаторно-курортное лечение назначены: " + f3_inf_dds_karta( mm_danet, &m1var,, ub, ue )
      Case k == 14
        s6 := Left( s6, Len( s6 ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_usl, &m1var,, ub, ue )
      Case k == 15
        s6 := Left( s6, Len( s6 ) -1 ) + '; ' + f3_inf_dds_karta( mm_uch1, &m1var,, ub, ue )
      Endcase
    Next
    frd->( Eval( blk, s ) )
    frd->( Eval( blk, s1 ) )
    frd->( Eval( blk, s2 ) )
    frd->( Eval( blk, s3 ) )
    frd->( Eval( blk, s4 ) )
    frd->( Eval( blk, s5 ) )
    frd->( Eval( blk, s6 ) )
  Next
  If m1invalid1 == 0
    m1invalid2 := m1invalid5 := m1invalid6 := m1invalid8 := -1
    minvalid3 := minvalid4 := minvalid7 := CToD( "" )
  Endif
  If Empty( minvalid7 )
    m1invalid8 := -1
  Endif
  s := st + '16.7. Инвалидность: ' + f3_inf_dds_karta( mm_danet, m1invalid1,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; если "да": ' + f3_inf_dds_karta( mm_invalid2(), m1invalid2,, ub, ue )
  s := Left( s, Len( s ) -1 ) + '; установлена впервые (дата) ' + iif( Empty( minvalid3 ), Replicate( "_", 15 ), ub + full_date( minvalid3 ) + ue )
  s += '; дата последнего освидетельствования ' + iif( Empty( minvalid4 ), Replicate( "_", 15 ), ub + full_date( minvalid4 ) + ue ) + '.'
  frd->( Eval( blk, s ) )
/*s := st+'16.7.1. Заболевания, обусловившие возникновение инвалидности:'
frd->(eval(blk,s))
mm_invalid5[6, 1] := "болезни крови, кроветворных органов и отдельные нарушения, вовлекающие иммунный механизм;"
mm_invalid5[7, 1] := "болезни эндокринной системы, расстройства питания и нарушения обмена веществ,"
atail(mm_invalid5)[1] := "последствия травм, отравлений и других воздействий внешних причин)"
s := st+'(' + f3_inf_DDS_karta(mm_invalid5,m1invalid5,' ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.2.Виды нарушений в состоянии здоровья:'
frd->(eval(blk,s))
s := st + f3_inf_DDS_karta(mm_invalid6(),m1invalid6,'; ',ub,ue)
frd->(eval(blk,s))
s := st+'16.7.3. Индивидуальная программа реабилитации ребенка-инвалида:'
frd->(eval(blk,s))
s := st+'дата назначения: '+iif(empty(minvalid7), replicate("_", 15), ub + full_date(minvalid7)+ue)+';'
frd->(eval(blk,s))
s := st+'выполнение на момент диспансеризации: ' + f3_inf_DDS_karta(mm_invalid8(),m1invalid8,,ub,ue)
frd->(eval(blk,s))*/
  s := st + "16.8. Группа состояния здоровья: " + f3_inf_dds_karta( mm_gruppa, mGRUPPA,, ub, ue )
  frd->( Eval( blk, s ) )
  s := st + "16.9. Медицинская группа для занятий физической культурой: "
  s += f3_inf_dds_karta( mm_gr_fiz, m1GR_FIZ,, ub, ue )
  frd->( Eval( blk, s ) )
/*s := st+'16.10'+'. Проведение профилактических прививок:'
frd->(eval(blk,s))
s := st
for j := 1 to len(mm_privivki1())
  if m1privivki1 == mm_privivki1()[j, 2]
    s += ub
  endif
  s += mm_privivki1()[j, 1]
  if m1privivki1 == mm_privivki1()[j, 2]
    s += ue
  endif
  if mm_privivki1()[j, 2] == 0
    s += "; "
  else
    s += ": " + f3_inf_DDS_karta(mm_privivki2(),iif(m1privivki1==mm_privivki1()[j, 2],m1privivki2,-1),,ub,ue,.f.)+"; "
  endif
next
s += 'нуждается в проведении вакцинации (ревакцинации) с указанием наименования прививки (нужное подчеркнуть): '
if m1privivki1 > 0 .and. !empty(mprivivki3)
  s += ub+alltrim(mprivivki3)+ue
endif
frd->(eval(blk,s))
s := replicate("_",sh)+"."
frd->(eval(blk,s))*/
  s := st + '17. Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой: '
  k := 3
  If !Empty( mrek_form )
    k := 1
    s += ub + AllTrim( mrek_form ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  s := st + '18. Рекомендации по проведению диспансерного наблюдения, ' + ;
    'лечению, медицинской реабилитации и санаторно-курортному лечению: '
  k := 5
  If !Empty( mrek_disp )
    k := 2
    s += ub + AllTrim( mrek_disp ) + ue
  Endif
  frd->( Eval( blk, s ) )
  For i := 1 To k
    s := Replicate( "_", sh ) + iif( i == k, ".", "" )
    frd->( Eval( blk, s ) )
  Next
  //
  adbf := { { "name", "C", 60, 0 }, ;
    { "data", "C", 10, 0 }, ;
    { "rezu", "C", 17, 0 } }
  dbCreate( fr_data + "1", adbf )
  Use ( fr_data + "1" ) New Alias FRD1
  dbCreate( fr_data + "2", adbf )
  Use ( fr_data + "2" ) New Alias FRD2
/*arr := f4_inf_DNL_karta(1)
for i := 1 to len(arr)
  select FRD1
  append blank
  frd1->name := arr[i, 1]
  frd1->data := full_date(arr[i, 2])
next
arr := f4_inf_DNL_karta(2)
for i := 1 to len(arr)
  select FRD2
  append blank
  frd2->name := arr[i, 1]
  frd2->data := full_date(arr[i, 2])
  frd2->rezu := arr[i, 3]
next*/
  //
  Close databases
  call_fr( "mo_030pou17" )

  Return Nil

// 02.06.20
Function f4_inf_dnl_karta( par, _etap )

  Local i, k := 0, fl, arr := {}, ar

  If Type( "mperiod" ) == "N" .and. Between( mperiod, 1, 31 )
    //
  Else
    mperiod := ret_period_pn( mdate_r, mn_data, mk_data,, @k )
  Endif
  If !Between( mperiod, 1, 31 )
    mperiod := k
  Endif
  If !Between( mperiod, 1, 31 )
    mperiod := 31
  Endif
  np_oftal_2_85_21( mperiod, mk_data )
  ar := np_arr_1_etap[ mperiod ]
  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To count_pn_arr_osm -1
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
    Endif
    AAdd( arr, { "педиатр (врач общей практики)", MDATEp1, "", -1, 1 } )
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      For i := 1 To count_pn_arr_osm -1
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( np_arr_osmotr[ i, 2 ] )
          fl := ( mpol == np_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) == 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
      AAdd( arr, { "педиатр (врач общей практики)", MDATEp2, "", -2, 1 } )
    Endif
  Else
    For i := 1 To count_pn_arr_iss // исследования
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      fl := .t.
      If fl .and. !Empty( np_arr_issled[ i, 2 ] )
        fl := ( mpol == np_arr_issled[ i, 2 ] )
      Endif
      If fl
        fl := ( AScan( ar[ 5 ], np_arr_issled[ i, 1 ] ) > 0 )
      Endif
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i == 1 // {"3.5.4"   ,   , "Аудиологический скрининг", 0, 64,{1111, 111101} }, ;
          k := 15
        Case i == 2 // {"4.2.153" ,   , "Общий анализ мочи", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
          // case i == 3 // {"4.8.1"   ,   , "Общий анализ кала", 0, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 3
          // case i == 4 // {"4.11.136",   , "Клинический анализ крови", 0, 34,{1107, 1301, 1402, 1702} }, ;
        Case i == 3 // {"4.11.136",   , "Клинический анализ крови", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
          // case i == 5 // {"4.12.169",   , "Исследование уровня глюкозы в крови", 0, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 4
          // case between(i, 6, 16) // {"4.14.67" ,   , "пролактин (гормон)", 1, 34,{1107, 1301, 1402, 1702} }, ;
          // k := 5
          // case between(i, 17, 21) // {"4.26.1"  ,   , "Неонатальный скрининг на гипотиреоз", 0, 34,{1107, 1301, 1402, 1702} }, ;
        Case Between( i, 4, 8 ) // {"4.26.1"  ,   , "Неонатальный скрининг на гипотиреоз", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 14
          // case i == 22 // {"7.61.3"  ,   , "Флюорография легких в 1-й проекции", 0, 78,{1118, 1802} }, ;
          // k := 12
          // case i == 23 // {"8.1.1"   ,   , "УЗИ головного мозга (нейросонография)", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 9 // {"8.1.1"   ,   , "УЗИ головного мозга (нейросонография)", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 11
          // case i == 24 // {"8.1.2"   ,   , "УЗИ щитовидной железы", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          // k := 8
        Case i == 12 // {"8.1.6"   , 12, "УЗИ почек", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 18
          // case i == 25 // {"8.1.3"   ,   , "УЗИ сердца", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 10 // {"8.1.3"   ,   , "УЗИ сердца", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 7
          // case i == 26 // {"8.1.4"   ,   , "УЗИ тазобедренных суставов", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 11 // {"8.1.4"   ,   , "УЗИ тазобедренных суставов", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 10
          // case i == 27 // {"8.2.1"   ,   , "УЗИ органов брюшной полости", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
        Case i == 13 // {"8.2.1"   ,   , "УЗИ органов брюшной полости", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 6
          // case between(i, 28, 29) // {"8.2.2"   ,"М", "УЗИ органов репродуктивной системы", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          // k := 9
          // case i == 30 // {"13.1.1"  ,   , "Электрокардиография", 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
        Case i == 14 // {"13.1.1"  ,   , "Электрокардиография", 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
          k := 13
        Endcase
        AAdd( arr, { np_arr_issled[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
    // добавим "2.4.2" "скрининг на выявление психич.развития"
    i := count_pn_arr_osm  // последний элемент массива
    mvart := "MTAB_NOMov" + lstr( i )
    mvard := "MDATEo" + lstr( i )
    If ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], np_arr_osmotr[ i, 1 ] ) > 0 ) .and. !emptyany( &mvard, &mvart )
      AAdd( arr, { np_arr_osmotr[ i, 3 ], &mvard, "", i, 21 } )
    Endif
  Endif

  Return arr

// 25.11.13
Function f5_inf_dnl_karta( i )

  Local k := 0

  Do Case
  Case i == 14 // {"2.85.16","Ж", "акушер-гинеколог", 2, {1101} }, ;
    k := 11
  Case i == 15 // {"2.85.17","М", "детский уролог-андролог", 19, {112603, 113502} }, ;
    k := 10
  Case i == 16 // {"2.85.18",   , "детский хирург", 20, {1135} }, ;
    k := 4
  Case i == 17 // {"2.85.19",   , "травматолог-ортопед", 100, {1123} }, ;
    k := 6
  Case i == 18 // {"2.85.20",   , "невролог", 53, {1109} }, ;
    k := 2
  Case i == 19 // {"2.85.21",   , "офтальмолог", 65, {1112} }, ;
    k := 3
  Case i == 20 // {"2.85.22",   , "отоларинголог", 64, {1111, 111101} }, ;
    k := 5
  Case i == 21 // {"2.85.23",   , "детский стоматолог", 86, {140102} }, ;
    k := 8
  Case i == 22 // {"2.85.24",   , "детский эндокринолог", 21, {1127, 112702, 113402} }, ;
    k := 9
  Case i == 23 // {"2.4.1"  ,   , "психиатр", 72, {1115} };
    k := 7
  Endcase

  Return k

// 09.06.20 Приложение к письму ГБУЗ "ВОМИАЦ" №1025 от 08.07.2019г.
Function f21_inf_dnl( par )

  Local arr_m, buf := save_maxrow(), lkod_h, lkod_k, rec, s, adbf, as, i, j, k, sh, HH := 40, n, n_file := cur_dir() + "svod_dnl.txt"

  If ( arr_m := year_month(,,, 5 ) ) != NIL
    If arr_m[ 1 ] < 2020
      Return func_error( 4, "Данная форма утверждена с 2020 года" )
    Endif
    mywait()
    If f0_inf_dnl( arr_m, par > 1, par == 3, { 301, 302 } )
      r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
      adbf := { { "ti", "N", 1, 0 }, ;
        { "stroke", "C", 8, 0 }, ;
        { "mm", "N", 2, 0 }, ;
        { "mm1", "N", 1, 0 }, ;
        { "vsego", "N", 6, 0 }, ;
        { "vsego1", "N", 6, 0 }, ;
        { "vsegoM", "N", 6, 0 }, ;
        { "g1", "N", 6, 0 }, ;
        { "g2", "N", 6, 0 }, ;
        { "g3", "N", 6, 0 }, ;
        { "g4", "N", 6, 0 }, ;
        { "g4inv", "N", 6, 0 }, ;
        { "g5", "N", 6, 0 }, ;
        { "g5inv", "N", 6, 0 }, ;
        { "mg1", "N", 6, 0 }, ;
        { "mg2", "N", 6, 0 }, ;
        { "mg3", "N", 6, 0 }, ;
        { "mg4", "N", 6, 0 }, ;
        { "sv", "N", 6, 0 }, ;
        { "so", "N", 6, 0 }, ;
        { "v2", "N", 6, 0 }, ;
        { "m15", "N", 6, 0 }, ;
        { "m15s", "N", 6, 0 }, ;
        { "m15pos", "N", 6, 0 }, ;
        { "m15poss", "N", 6, 0 }, ;
        { "m15a", "N", 6, 0 }, ;
        { "m15p", "N", 6, 0 }, ;
        { "m15ps", "N", 6, 0 }, ;
        { "m15p1", "N", 6, 0 }, ;
        { "m15p1s", "N", 6, 0 }, ;
        { "m15e", "N", 6, 0 }, ;
        { "g15", "N", 6, 0 }, ;
        { "g15s", "N", 6, 0 }, ;
        { "g15pos", "N", 6, 0 }, ;
        { "g15poss", "N", 6, 0 }, ;
        { "g15g", "N", 6, 0 }, ;
        { "g15p", "N", 6, 0 }, ;
        { "g15ps", "N", 6, 0 }, ;
        { "g15p1", "N", 6, 0 }, ;
        { "g15p1s", "N", 6, 0 }, ;
        { "g15e", "N", 6, 0 }, ;
        { "g18", "N", 6, 0 }, ;
        { "g18s", "N", 6, 0 }, ;
        { "m18", "N", 6, 0 }, ;
        { "m18s", "N", 6, 0 } }

      dbCreate( cur_dir() + "tmp1", adbf )
      Use ( cur_dir() + "tmp1" ) new
      Index On Str( mm, 2 ) to ( cur_dir() + "tmp1" )
      Append Blank
      tmp1->mm := 0 ; tmp1->stroke := "Всего"
      Append Blank
      tmp1->mm := 1 ; tmp1->stroke := "0-14 лет"
      Append Blank
      tmp1->mm := 2 ; tmp1->stroke := "до 1 г."
      Append Blank
      tmp1->mm := 3 ; tmp1->stroke := "15-17 л."
      Append Blank
      tmp1->mm := 4 ; tmp1->stroke := "15-17 юн"
      Append Blank
      tmp1->mm := 5 ; tmp1->stroke := "школьники"
      adbf := { { "ti", "N", 1, 0 }, ;
        { "g1", "N", 6, 0 }, ;
        { "g2", "N", 6, 0 }, ;
        { "g3", "N", 6, 0 }, ;
        { "g31", "N", 6, 0 }, ;
        { "g32", "N", 6, 0 }, ;
        { "g4", "N", 6, 0 }, ;
        { "g5", "N", 6, 0 }, ;
        { "g6", "N", 6, 0 }, ;
        { "g7", "N", 6, 0 }, ;
        { "g8", "N", 6, 0 }, ;
        { "g9", "N", 6, 0 }, ;
        { "g10", "N", 6, 0 }, ;
        { "g11", "N", 6, 0 }, ;
        { "g12", "N", 6, 0 }, ;
        { "g13", "N", 6, 0 }, ;
        { "g14", "N", 6, 0 }, ;
        { "g15", "N", 6, 0 }, ;
        { "g7n", "N", 6, 0 }, ;
        { "g8n", "N", 6, 0 }, ;
        { "g12n", "N", 6, 0 }, ;
        { "g13n", "N", 6, 0 }, ;
        { "g14n", "N", 6, 0 }, ;
        { "g16n", "N", 6, 0 } }
      dbCreate( cur_dir() + "tmp2", adbf )
      Use ( cur_dir() + "tmp2" ) new
      Index On Str( ti, 1 ) to ( cur_dir() + "tmp2" )
      r_use( dir_server() + "mo_schoo",, "SCH" )
      r_use( dir_server() + "schet_",, "SCHET_" )
      r_use( dir_server() + "uslugi",, "USL" )
      r_use_base( "human_u" )
      r_use( dir_server() + "kartote_",, "KART_" )
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_, To kod_k into KART_
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into HUMAN
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say Str( RecNo() / LastRec() * 100, 6, 2 ) + "%" Color cColorWait
        f1_f21_inf_dnl( tmp->kod, tmp->kod_k )
        Select TMP
        Skip
      Enddo
      Close databases
      arr_title := { ;
        "────────┬─────────────────┬─────────────────────────────────────────┬───────────────────────┬───────────┬─────┬─────", ;
        "катего- │Число детей Iэтап│распределение по группам здоровья I этап │распр-ие по мед.группам│Случаев Iэт│напр.│завер", ;
        "рии     ├─────┬─────┬─────┼─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────┬─────┬─────┬─────┼─────┬─────┤на   │шило ", ;
        "детей   │всего│ село│моб/к│  1  │  2  │  3  │  4  │4инв.│  5  │5инв.│основ│подго│спецА│спецБ│зарег│оплач│2 эт.│2 эт.", ;
        "────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "        │  5  │ 5.1 │  6  │  7  │  8  │  9  │  10 │ 10.1│  11 │ 11.1│  12 │  13 │  14 │  15 │  16 │  17 │  18 │  19 ", ;
        "────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      sh := Len( arr_title[ 1 ] )
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( PadL( 'Приложение к письму ГБУЗ "ВОМИАЦ"', sh ) )
      add_string( PadL( "№1025 от 08.07.2019г.", sh ) )
      add_string( "" )
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ par ] ) + " ]", sh ) )
      add_string( Center( "(" + arr_m[ 4 ] + ")", sh ) )
      Use ( cur_dir() + "tmp1" ) index ( cur_dir() + "tmp1" ) new
      add_string( "" )
      add_string( Center( "Сведения о профилактических осмотрах несовершеннолетних", sh ) )
      add_string( "" )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      Do While !Eof()
        s := tmp1->stroke + put_val( tmp1->vsego, 6 ) + ;
          put_val( tmp1->vsego1, 6 ) + ;
          put_val( tmp1->vsegoM, 6 ) + ;
          put_val( tmp1->g1, 6 ) + ;
          put_val( tmp1->g2, 6 ) + ;
          put_val( tmp1->g3, 6 ) + ;
          put_val( tmp1->g4, 6 ) + ;
          put_val( tmp1->g4inv, 6 ) + ;
          put_val( tmp1->g5, 6 ) + ;
          put_val( tmp1->g5inv, 6 ) + ;
          put_val( tmp1->mg1, 6 ) + ;
          put_val( tmp1->mg2, 6 ) + ;
          put_val( tmp1->mg3, 6 ) + ;
          put_val( tmp1->mg4, 6 ) + ;
          put_val( tmp1->sv, 6 ) + ;
          put_val( tmp1->so, 6 ) + ;
          put_val( tmp1->v2, 6 ) + ;
          put_val( tmp1->v2, 6 )
        // put_val(tmp1->g31, 6)+;
        // put_val(tmp1->g32, 6)+;
        If verify_ff( HH -1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        add_string( Replicate( "─", sh ) )
        Skip
      Enddo
      //
      verify_ff( HH -12, .t., sh )
/*    arr_title := {;
"────────┬───────────────────────────────────┬───────────────────────────────────", ;
"        │      Юноши (15-17 лет)            │        Девушки (15-17 лет)        ", ;
"        ├─────────────────┬─────┬─────┬─────┼─────────────────┬─────┬─────┬─────", ;
"        │факт осмот.(чел.)│патол│ из  │напр.│факт осмот.(чел.)│патол│ из  │напр.", ;
"        ├─────┬─────┬─────┤репр.│ гр.6│на II├─────┬─────┬─────┤репр.│ гр.6│на II", ;
"        │всего│ село│андро│сист.│ село│этап │всего│ село│гинек│сист.│ село│этап ", ;
"────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
"        │  3  │  4  │  5  │  6  │  7  │  8  │  3  │  4  │  5  │  6  │  7  │  8  ", ;
"────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────"}*/
      arr_title := { ;
        "───────────────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────", ;
        "            Юноши (15-17 лет)                                          │                         Девушки (15-17 лет)                           ", ;
        "─────────────────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┼─────────────────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬─────", ;
        "     факт осмот.(чел.)       │патол│ из  │из 7 │ из  │напр.│напр.│ из  │      факт осмот.(чел.)      │патол│ из  │из 14│ из  │напр.│напр.│ из  ", ;
        "─────┬─────┬─────┬─────┬─────┤репр.│ гр.7│впер-│ 7.2 │на II│на л.│  9  ├─────┬─────┬─────┬─────┬─────┤репр.│гр.14│впер-│14.2 │на II│на л.│ 18  ", ;
        "всего│ село│посещ│ село│андро│сист.│ село│вые  │ село│этап │из 7 │ село│всего│ село│посещ│ село│гинек│сист.│ село│вые  │ село│этап │из 16│ село", ;
        "─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "  3  │  4  │  5  │ 5.1 │  6  │  7  │ 7.1 │ 7.2 │ 7.3 │  8  │  9  │ 9.1 │  13 │ 13.1│  14 │ 14.1│  15 │  16 │ 16.1│ 16.2│ 16.3│ 17  │ 18  │ 18.1", ;
        "─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      sh := Len( arr_title[ 1 ] )
      i := 1
      add_string( "" )
      add_string( "Несовершеннолетние в возрасте 15-17 лет" )
      AEval( arr_title, {| x| add_string( x ) } )
      Go Top
      s :=   put_val( tmp1->m15, 5 ) + ;
        put_val( tmp1->m15s, 6 ) + ;
        put_val( tmp1->m15pos, 6 ) + ;
        put_val( tmp1->m15poss, 6 ) + ;
        put_val( tmp1->m15a, 6 ) + ;
        put_val( tmp1->m15p, 6 ) + ;
        put_val( tmp1->m15ps, 6 ) + ;
        put_val( tmp1->m15p1, 6 ) + ;
        put_val( tmp1->m15p1s, 6 ) + ;
        put_val( tmp1->m15e, 6 ) + ;
        put_val( tmp1->m18, 6 ) + ;
        put_val( tmp1->m18s, 6 ) + ;
        put_val( tmp1->g15, 6 ) + ;
        put_val( tmp1->g15s, 6 ) + ;
        put_val( tmp1->g15pos, 6 ) + ;
        put_val( tmp1->g15poss, 6 ) + ;
        put_val( tmp1->g15g, 6 ) + ;
        put_val( tmp1->g15p, 6 ) + ;
        put_val( tmp1->g15ps, 6 ) + ;
        put_val( tmp1->g15p1, 6 ) + ;
        put_val( tmp1->g15p1s, 6 ) + ;
        put_val( tmp1->g15e, 6 ) + ;
        put_val( tmp1->g18, 6 ) + ;
        put_val( tmp1->g18s, 6 )
      If verify_ff( HH -1, .t., sh )
        AEval( arr_title, {| x| add_string( x ) } )
      Endif
      add_string( s )
      add_string( Replicate( "─", sh ) )
      //
      verify_ff( HH -12, .t., sh )
      arr_title := { ;
        "─────────┬─────────────────┬─────────────────┬─────┬─────┬─────┬────────────────────────────────────────────────┬─────┬─────┬─────┬─────", ;
        "         │    Осмотрено    │из них сельских ж│осмо-│осмо-│впер-│                  из них                        │факт-│из г9│из г9│из   ", ;
        "Контин-  ├─────┬─────┬─────┼─────┬─────┬─────┤трено│трено│вые  ├─────┬─────┬──────┬─────┬─────┬─────┬─────┬─────┤ оры │взяты│нача-│гр.20", ;
        "гент     │     │после│в суб│     │после│в суб│урол-│гине-│неинф│болез│     │  1и2 │болез│болез│болез│болез│болез│риска│на   │то   │сель-", ;
        "         │всего│18:00│боту │всего│18:00│боту │андро│коло-│екцио│крово│ ЗНО │ стад.│к-мыш│глаз │эндок│орган│орган│впер-│дисп.│лече-│ских ", ;
        "         │     │     │     │     │     │     │логом│гом  │нные │обращ│     │из г11│соед.│прид.│сист.│дыхан│пищев│вые  │набл.│ние  │жител", ;
        "─────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼──────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "         │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │  11 │  12  │  13 │  14 │  15 │  16 │  17 │  18 │  19 │  20 │  21 ", ;
        "─────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴──────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      // 1     2     3     4     5     6     7n    8n    7     8     9     0                        11    12          13    14    15
      sh := Len( arr_title[ 1 ] )
      add_string( "" )
      add_string( 'В рамках национального проекта "Здравоохранение"' )
      AEval( arr_title, {| x| add_string( x ) } )
      Use ( cur_dir() + "tmp2" ) index ( cur_dir() + "tmp2" ) new
      Go Top
      Do While !Eof()
        s := PadR( { "0-14 лет", "15-17 лет", "Всего" }[ tmp2->ti ], 9 ) + ;
          put_val( tmp2->g1, 6 ) + ;
          put_val( tmp2->g2, 6 ) + ;
          put_val( tmp2->g3, 6 ) + ;
          put_val( tmp2->g4, 6 ) + ;
          put_val( tmp2->g5, 6 ) + ;
          put_val( tmp2->g6, 6 ) + ;
          put_val( tmp2->g7n, 6 ) + ;
          put_val( tmp2->g8n, 6 ) + ;
          put_val( tmp2->g7, 6 ) + ;
          put_val( tmp2->g8, 6 ) + ;
          put_val( tmp2->g9, 6 ) + ;
          put_val( 0, 7 ) + ;
          put_val( tmp2->g12n, 6 ) + ;
          put_val( tmp2->g13n, 6 ) + ;
          put_val( tmp2->g14n, 6 ) + ;
          put_val( tmp2->g11, 6 ) + ;
          put_val( tmp2->g12, 6 ) + ;
          put_val( tmp2->g16n, 6 ) + ;
          put_val( tmp2->g13, 6 ) + ;
          put_val( tmp2->g14, 6 ) + ;
          put_val( tmp2->g15, 6 )
        If verify_ff( HH -1, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s )
        add_string( Replicate( "─", sh ) )
        Skip
      Enddo
      //
      FClose( fp )
      Close databases
      Private yes_albom := .t.
      viewtext( n_file,,,, ( .t. ),,, 3 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 20.06.20
Function f1_f21_inf_dnl( Loc_kod, kod_kartotek ) // сводная информация

  Local ii, im, i, j, k, s, sumr := 0, ar := { 0 }, ltip_school := -1, ar15[ 26 ], ;
    is_2 := .f., ad := {}, arr, a3 := {}, fl_ves := .t.
  Private m1tip_school := -1, m1school := 0, mvozrast, mdvozrast, mgruppa := 0, m1GR_FIZ := 1, m1invalid1 := 0
  Private mvar, m1var, m1FIZ_RAZV1, m1napr_stac := 0

  AFill( ar15, 0 )
  mvozrast := count_years( human->date_r, human->n_data )
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  For i := 1 To 5
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  ii := 1
  is_2 := ( human->ishod == 302 ) // это второй этап
  read_arr_pn( Loc_kod )
  If human->pol == "М"
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
    If human->pol == "М"
      AAdd( ar, 4 )
    Endif
  Endif
  If mdvozrast > 6 // школьники ?
    AAdd( ar, 5 )
  Endif
  If m1school > 0
    Select SCH
    Goto ( m1school )
    ltip_school := sch->tip
  Endif
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
  //
  arr := Array( 24 ) ; AFill( arr, 0 ) ; arr[ 16 ] := 3
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
    If !( Left( ad[ i, 1 ], 1 ) == "A" .or. Left( ad[ i, 1 ], 1 ) == "B" ) .and. ad[ i, 2 ] > 0 // неинфекционные заболевания уст.впервые
      arr[ 7 ] ++
      If Left( ad[ i, 1 ], 1 ) == "I" // болезни системы кровообращения
        arr[ 8 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "J" // болезни органов дыхания
        arr[ 11 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "K" // болезни органов пищеварения
        arr[ 12 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "M" // болезни костно-мышечной системы
        arr[ 19 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "H" // болезни глаз
        arr[ 20 ] ++
      Elseif Left( ad[ i, 1 ], 1 ) == "E" // болезни эндокринология
        arr[ 21 ] ++
      Endif
      If Left( ad[ i, 1 ], 3 ) == "E78"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "R73.9"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.0"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.4"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "R63.5"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.3"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.1"
        arr[ 22 ] ++
        fl_ves := .f.
      Elseif Left( ad[ i, 1 ], 5 ) == "Z72.2"
        arr[ 22 ] ++
        fl_ves := .f.
      Endif
      // надо деффицит массы тела
      If Left( ad[ i, 1 ], 1 ) == "C" .or. Between( Left( ad[ i, 1 ], 3 ), "D00", "D09" ) // ЗНО может быть добавить  .or. between(left(ad[i, 1], 3),"D45","D47")
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
    j := iif( human->pol == "М", 1, 7 )
    ar15[ j ] ++
    If is_selo
      ar15[ j + 1 ] ++
    Endif
    If ( i := AScan( ad, {| x| Left( x[ 1 ], 1 ) == "N" } ) ) > 0 // патология органов репродуктивной системы
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
    find ( Str( Loc_kod, 7 ) )
    Do While hu->kod == Loc_kod .and. !Eof()
      If eq_any( hu_->PROFIL, 19, 136 )
        fl := .t.
      Endif
      usl->( dbGoto( hu->u_kod ) )
      If Empty( lshifr := opr_shifr_tfoms( usl->shifr1, usl->kod, human->k_data ) )
        lshifr := usl->shifr
      Endif
      If Left( lshifr, 2 ) == "2."  // врачебный приём
        If Left( lshifr, 4 ) != "2.91"  // не полноценные игнорируем
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
            // mydebug(,"2------------------------------------------")
          Endif
        Endif
      Endif
      Select HU
      Skip
    Enddo
    If fl
      ar15[ j + 2 ] ++
    Endif
  Else
    arr[ 16 ] := 1
  Endif
  AAdd( a3, AClone( arr ) )
  //
  // aadd(arr,{"12.4.1",m1FIZ_RAZV1})  // "N",физическое развитие 0-нормальное, с отклонениями: 1-дефицит массы тела, 2-избыток массы тела, 3-низкий рост, 4-высокий рост
  If m1fiz_razv1 == 1
    If fl_ves
      arr[ 22 ] ++
    Endif
  Endif
  //
  For j := 1 To Len( a3 )
    Select TMP2
    find ( Str( a3[ j, 16 ], 1 ) )
    If !Found()
      Append Blank
      tmp2->ti := a3[ j, 16 ]
    Endif
    For i := 1 To 15
      pole := "tmp2->g" + lstr( i )
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
    find ( Str( im, 2 ) )
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
      pole := "tmp1->g" + lstr( mgruppa )
      &pole := &pole + 1
      If Between( mgruppa, 4, 5 ) .and. m1invalid1 == 1 // инвалидность-да
        pole += "inv"
        &pole := &pole + 1
      Endif
      If /*ltip_school == 0 .and.*/ between(m1GR_FIZ, 1, 4)
        pole := "tmp1->mg" + lstr( m1GR_FIZ )
        &pole := &pole + 1
      Endif
      If is_2 // I и II этап
        tmp1->v2++
      Endif
    Endif
    If human->schet > 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        tmp1->sv++
        sumr := 0
        Select RPDSH
        find ( Str( Loc_kod, 7 ) )
        Do While rpdsh->KOD_H == Loc_kod .and. !Eof()
          sumr += rpdsh->S_SL
          Skip
        Enddo
        If Round( human->cena_1, 2 ) == Round( sumr, 2 ) // полностью оплачен
          tmp1->so++
        Endif
      Endif
    Endif
  Next

  Return Nil

// 25.03.18
Function inf_dnl_030poo( is_schet )

  Local arr_m, i, n, buf := save_maxrow(), lkod_h, lkod_k, rec, sh := 80, HH := 80, n_file := cur_dir() + "f_030poo.txt", d1, d2

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    If arr_m[ 1 ] < 2018
      Return func_error( 4, "Данная форма утверждена с 2018 года" )
    Endif
    mywait()
    If f0_inf_dnl( arr_m, is_schet > 1, is_schet == 3 )
      Private arr_deti[ 6 ] ; AFill( arr_deti, 0 )
      Private s12_1 := 0, s12_1m := 0, s12_2 := 0, s12_2m := 0
      Private arr_vozrast := { ;
        { 3, 0, 17 };
        }
      Private arr1vozrast := { ;
        { 0, 17 }, ;
        { 0, 4 }, ;
        { 0, 14 }, ;
        { 5, 9 }, ;
        { 10, 14 }, ;
        { 15, 17 };
        }
      Private arr_4 := { ;
        { "1", "Некоторые инфекционные и паразит...", "A00-B99",, }, ;
        { "1.1", "туберкулез", "A15-A19",, }, ;
        { "1.2", "ВИЧ-инфекция, СПИД", "B20-B24",, }, ;
        { "2", "Новообразования", "C00-D48",, }, ;
        { "3", "Болезни крови и кроветворных органов ...", "D50-D89",, }, ;
        { "3.1", "анемии", "D50-D53",, }, ;
        { "4", "Болезни эндокринной системы, расстройства...", "E00-E90",, }, ;
        { "4.1", "сахарный диабет", "E10-E14",, }, ;
        { "4.2", "недостаточность питания", "E40-E46",, }, ;
        { "4.3", "ожирение", "E66",, }, ;
        { "4.4", "задержка полового развития", "E30.0",, }, ;
        { "4.5", "преждевременное половое развитие", "E30.1",, }, ;
        { "5", "Психические расстройства и расстро...", "F00-F99",, }, ;
        { "5.1", "умственная отсталость", "F70-F79",, }, ;
        { "6", "Болезни нервной системы, из них:", "G00-G98",, }, ;
        { "6.1", "церебральный паралич и другие ...", "G80-G83",, }, ;
        { "7", "Болезни глаза и его придаточного аппарата", "H00-H59",, }, ;
        { "8", "Болезни уха и сосцевидного отростка", "H60-H95",, }, ;
        { "9", "Болезни системы кровообращения", "I00-I99",, }, ;
        { "10", "Болезни органов дыхания, из них:", "J00-J99",, }, ;
        { "10.1", "астма, астматический статус", "J45-J46",, }, ;
        { "11", "Болезни органов пищеварения", "K00-K93",, }, ;
        { "12", "Болезни кожи и подкожной клетчатки", "L00-L99",, }, ;
        { "13", "Болезни костно-мышечной ...", "M00-M99",, }, ;
        { "13.1", "кифоз, лордоз, сколиоз", "M40-M41",, }, ;
        { "14", "Болезни мочеполовой системы, из них:", "N00-N99",, }, ;
        { "14.1", "болезни мужских половых органов", "N40-N51",, }, ;
        { "14.2", "нарушения ритма и характера менструаций", "N91-N94.5",, }, ;
        { "14.3", "воспалительные заболевания ...", "N70-N77",, }, ;
        { "14.4", "невоспалительные болезни ...", "N83",, }, ;
        { "14.5", "болезни молочной железы", "N60-N64",, }, ;
        { "15", "Отдельные состояния, возника...", "P00-P96",, }, ;
        { "16", "Врожденные аномалии (пороки ...", "Q00-Q99",, }, ;
        { "16.1", "развития нервной системы", "Q00-Q07",, }, ;
        { "16.2", "системы кровообращения", "Q20-Q28",, }, ;
        { "16.3", "женских половых органов", "Q50-Q52",, }, ;
        { "16.4", "мужских половых органов", "Q53-Q55",, }, ;
        { "16.5", "костно-мышечной системы", "Q65-Q79",, }, ;
        { "17", "Травмы, отравления и некоторые...", "S00-T98",, }, ;
        { "18", "Прочие", "",, }, ;
        { "19", "ВСЕГО ЗАБОЛЕВАНИЙ", "A00-T98",, };
        }
      For n := 1 To Len( arr_4 )
        If "-" $ arr_4[ n, 3 ]
          d1 := Token( arr_4[ n, 3 ], "-", 1 )
          d2 := Token( arr_4[ n, 3 ], "-", 2 )
        Else
          d1 := d2 := arr_4[ n, 3 ]
        Endif
        arr_4[ n, 4 ] := diag_to_num( d1, 1 )
        arr_4[ n, 5 ] := diag_to_num( d2, 2 )
      Next
      dbCreate( cur_dir() + "tmp4", { { "name", "C", 100, 0 }, ;
        { "diagnoz", "C", 20, 0 }, ;
        { "stroke", "C", 4, 0 }, ;
        { "ns", "N", 2, 0 }, ;
        { "diapazon1", "N", 10, 0 }, ;
        { "diapazon2", "N", 10, 0 }, ;
        { "tbl", "N", 1, 0 }, ;
        { "k04", "N", 8, 0 }, ;
        { "k05", "N", 8, 0 }, ;
        { "k06", "N", 8, 0 }, ;
        { "k07", "N", 8, 0 }, ;
        { "k08", "N", 8, 0 }, ;
        { "k09", "N", 8, 0 }, ;
        { "k10", "N", 8, 0 }, ;
        { "k11", "N", 8, 0 } } )
      Use ( cur_dir() + "tmp4" ) New Alias TMP
      For i := 1 To Len( arr_vozrast )
        For n := 1 To Len( arr_4 )
          Append Blank
          tmp->tbl := arr_vozrast[ i, 1 ]
          tmp->stroke := arr_4[ n, 1 ]
          tmp->name := arr_4[ n, 2 ]
          tmp->ns := n
          tmp->diagnoz := arr_4[ n, 3 ]
          tmp->diapazon1 := arr_4[ n, 4 ]
          tmp->diapazon2 := arr_4[ n, 5 ]
        Next
      Next
      Index On Str( tbl, 1 ) + Str( ns, 2 ) to ( cur_dir() + "tmp4" )
      Use
      dbCreate( cur_dir() + "tmp10", { { "voz", "N", 1, 0 }, ;
        { "tbl", "N", 2, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp10" ) New Alias TMP10
      Index On Str( voz, 1 ) + Str( tbl, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp10" )
      Use
      Copy File ( cur_dir() + "tmp10" + sdbf() ) to ( cur_dir() + "tmp11" + sdbf() )
      Use ( cur_dir() + "tmp11" ) New Alias TMP11
      Index On Str( voz, 1 ) + Str( tbl, 2 ) + Str( tip, 2 ) to ( cur_dir() + "tmp11" )
      Use
      dbCreate( cur_dir() + "tmp13", { { "voz", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp13" ) New Alias TMP13
      Index On Str( voz, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp13" )
      Use
      dbCreate( cur_dir() + "tmp16", { { "voz", "N", 1, 0 }, ;
        { "man", "N", 1, 0 }, ;
        { "tip", "N", 2, 0 }, ;
        { "kol", "N", 6, 0 } } )
      Use ( cur_dir() + "tmp16" ) New Alias TMP16
      Index On Str( voz, 1 ) + Str( man, 1 ) + Str( tip, 2 ) to ( cur_dir() + "tmp16" )
      Use
      dbCloseAll()
      Use ( cur_dir() + "tmp4" )  index ( cur_dir() + "tmp4" )  new
      Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) new
      Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) new
      Use ( cur_dir() + "tmp13" ) index ( cur_dir() + "tmp13" ) new
      Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) new
      r_use( dir_server() + "human_",, "HUMAN_" )
      r_use( dir_server() + "human",, "HUMAN" )
      Set Relation To RecNo() into HUMAN_
      r_use( cur_dir() + "tmp" )
      Set Relation To kod into HUMAN
      ii := 0
      mywait( " " )
      Go Top
      Do While !Eof()
        @ MaxRow(), 0 Say PadR( Str( ++ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%  " + AllTrim( human->fio ) + "  " + full_date( human->date_r ), 80 ) Color cColorWait
        f2_inf_dnl_030poo( human->kod, human->kod_k )
        Select TMP
        Skip
      Enddo
      Close databases
      //
      fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( glob_mo[ _MO_SHORT_NAME ] )
      add_string( PadL( "Приложение 3", sh ) )
      add_string( PadL( "к Приказу МЗРФ", sh ) )
      add_string( PadL( "№514н от 10.08.2017г.", sh ) )
      add_string( "" )
      add_string( PadL( "Форма статистической отчетности № 030-ПО/о-17", sh ) )
      add_string( "" )
      add_string( Center( "Сведения о профилактических медицинских осмотрах несовершеннолетних", sh ) )
      add_string( Center( "[ " + CharRem( "~", mas1pmt[ is_schet ] ) + " ]", sh ) )
      add_string( Center( arr_m[ 4 ], sh ) )
      add_string( "" )
      add_string( "2. Число детей, прошедших профосмотры в отчетном периоде:" )
      add_string( "  2.1. всего в возрасте от 0 до 17 лет включительно:" + Str( arr_deti[ 1 ], 6 ) + " (человек), из них:" )
      add_string( "  2.1.1. в возрасте от 0 до 4 лет включительно      " + Str( arr_deti[ 2 ], 6 ) + " (человек)," )
      add_string( "  2.1.2. в возрасте от 0 до 14 лет включительно     " + Str( arr_deti[ 2 ] + arr_deti[ 3 ] + arr_deti[ 4 ], 6 ) + " (человек)," )
      add_string( "  2.1.3. в возрасте от 5 до 9 лет включительно      " + Str( arr_deti[ 3 ], 6 ) + " (человек)," )
      add_string( "  2.1.4. в возрасте от 10 до 14 лет включительно    " + Str( arr_deti[ 4 ], 6 ) + " (человек)," )
      add_string( "  2.1.5. в возрасте от 15 до 17 лет включительно    " + Str( arr_deti[ 5 ], 6 ) + " (человек)," )
      add_string( "  2.1.6. детей-инвалидов от 0 до 17 лет включительно" + Str( arr_deti[ 6 ], 6 ) + " (человек)." )
      For i := 1 To Len( arr_vozrast )
        verify_ff( HH -50, .t., sh )
        add_string( "" )
        add_string( Center( lstr( arr_vozrast[ i, 1 ] ) + ;
          ". Структура выявленных заболеваниях (состояний) у детей в возрасте от " + ;
          lstr( arr_vozrast[ i, 2 ] ) + " до " + lstr( arr_vozrast[ i, 3 ] ) + " лет включительно", sh ) )
        add_string( "────┬───────────────────┬───────┬─────┬─────┬─────┬─────┬───────────────────────" )
        add_string( " №№ │    Наименование   │ Код по│Всего│в т.ч│выяв-│в т.ч│Состоит под дисп.наблюд" )
        add_string( " пп │    заболеваний    │ МКБ-10│зарег│маль-│лено │маль-├─────┬─────┬─────┬─────" )
        add_string( "    │                   │       │забол│чики │вперв│чики │всего│мальч│взято│мальч" )
        add_string( "────┼───────────────────┼───────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────" )
        add_string( " 1  │          2        │   3   │  4  │  5  │  6  │  7  │  8  │  9  │ 10  │ 11  " )
        add_string( "────┴───────────────────┴───────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" )
        Use ( cur_dir() + "tmp4" ) index ( cur_dir() + "tmp4" ) New Alias TMP
        find ( Str( arr_vozrast[ i, 1 ], 1 ) )
        Do While tmp->tbl == arr_vozrast[ i, 1 ] .and. !Eof()
          s := tmp->stroke + " " + PadR( tmp->name, 19 ) + " " + PadC( AllTrim( tmp->diagnoz ), 7 )
          For n := 4 To 11
            s += put_val( tmp->&( "k" + StrZero( n, 2 ) ), 6 )
          Next
          add_string( s )
          Skip
        Enddo
        Use
        add_string( Replicate( "─", sh ) )
      Next
      arr1title := { ;
        "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        "                    │   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных ", ;
        "  Возраст детей     │           │           │субъекта РФ│  ных ГУЗ  │    МО     ", ;
        "                    │           │           │           │           │           ", ;
        "────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────", ;
        "          1         │     2     │     3     │     4     │     5     │     6     ", ;
        "────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────" }
      arr2title := { ;
        "────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        "                    │   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных ", ;
        "  Возраст детей     ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────", ;
        "                    │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ", ;
        "────────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "          1         │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 ", ;
        "────────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      arr3title := { ;
        "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        " Возраст│   Всего   │   в МО    │   в ГУЗ   │в федераль-│ в частных │в санаторно", ;
        " детей  │           │           │субъекта РФ│  ных ГУЗ  │    МО     │-курортных ", ;
        "        │           │           │           │           │           │организ-ях ", ;
        "────────┼───────────┼───────────┼───────────┼───────────┼───────────┼───────────", ;
        "    1   │     2     │     3     │     4     │     5     │     6     │     7     ", ;
        "────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────" }
      arr4title := { ;
        "────────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────", ;
        " Возраст│   Всего   │в муниц.МО │   в ГУЗ   │в федераль-│ в частных │в сан.-кур.", ;
        " детей  ├─────┬─────┼─────┬─────┤субъекта РФ├──ных ГУЗ──┼────МО─────┼──орг-иях──", ;
        "        │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  │ абс.│  %  ", ;
        "────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────", ;
        "    1   │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  10 │  11 │  12 │  13 ", ;
        "────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────" }
      verify_ff( HH -50, .t., sh )
      add_string( "4. Результаты дополнительных консультаций, исследований, лечения, медицинской" )
      add_string( "   реабилитации детей по результатам проведения профилактических осмотров:" )
      Use ( cur_dir() + "tmp10" ) index ( cur_dir() + "tmp10" ) New Alias TMP10
      For i := 1 To 2
        verify_ff( HH -16, .t., sh )
        add_string( "" )
        s := Space( 5 )
        If i == 1
          add_string( s + "4.1. Дополнительные консультации и (или) исследования" )
        Else
          add_string( s + "4.2. Лечение, медицинская реабилитация и санаторно-курортное лечение" )
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
          s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
          skol := oldkol := 0
          s1 := ""
          For k := 1 To iif( i == 8, 5, 4 )
            find ( Str( j, 1 ) + Str( i, 1 ) + Str( k, 1 ) )
            If Found() .and. ( v := tmp10->kol ) > 0
              skol += v
              If eq_any( i, 2, 4 )
                s1 += Str( v, 6 )
                find ( Str( j, 1 ) + Str( i -1, 1 ) + Str( k, 1 ) )
                If Found() .and. tmp10->kol > 0
                  s1 += " " + umest_val( v / tmp10->kol * 100, 5, 2 )
                  oldkol += tmp10->kol
                Else
                  s1 += Space( 6 )
                Endif
              Else
                s1 += " " + PadC( lstr( v ), 11 )
              Endif
            Else
              s1 += Space( 12 )
            Endif
          Next
          If skol > 0
            If eq_any( i, 2, 4 )
              s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
            Else
              s += " " + PadC( lstr( skol ), 11 )
            Endif
            add_string( s + s1 )
          Else
            add_string( s )
          Endif
        Next
        add_string( Replicate( "─", sh ) )
      Next
      Use
      //
      // verify_FF(HH-50, .t., sh)
      // add_string("11. Результаты лечения, медицинской реабилитации и (или) санаторно-курортного")
      // add_string("    лечения детей до проведения настоящего профилактического осмотра:")
      vkol := 0
      Use ( cur_dir() + "tmp11" ) index ( cur_dir() + "tmp11" ) New Alias TMP11
      For i := 1 To 0// 12
        If i % 3 > 0
          verify_ff( HH -16, .t., sh )
          add_string( "" )
        Endif
        s := Space( 5 )
        If i == 1
          add_string( s + "11.1. Рекомендовано лечение в амбулаторных условиях и в условиях" )
          add_string( s + "      дневного стационара" )
        Elseif i == 2
          add_string( s + "11.2. Проведено лечение в амбулаторных условиях и в условиях" )
          add_string( s + "      дневного стационара" )
        Elseif i == 3
          add_string( s + "11.3. Причины невыполнения рекомендаций по лечению в амбулаторных условиях" )
          add_string( s + "      и в условиях дневного стационара:" )
          add_string( s + "        11.3.1. не прошли всего " + lstr( vkol ) + " (человек)" )
        Elseif i == 4
          add_string( s + "11.4. Рекомендовано лечение в стационарных условиях" )
        Elseif i == 5
          add_string( s + "11.5. Проведено лечение в стационарных условиях" )
        Elseif i == 6
          add_string( s + "11.6. Причины невыполнения рекомендаций по лечению в стационарных условиях:" )
          add_string( s + "        11.6.1. не прошли всего " + lstr( vkol ) + " (человек)" )
        Elseif i == 7
          add_string( s + "11.7. Рекомендована медицинская реабилитация" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Elseif i == 8
          add_string( s + "11.8. Проведена медицинская реабилитация" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара" )
        Elseif i == 9
          add_string( s + "11.9. Причины невыполнения рекомендаций по медицинской реабилитации" )
          add_string( s + "      в амбулаторных условиях и в условиях дневного стационара:" )
          add_string( s + "        11.9.1. не прошли всего " + lstr( vkol ) + " (человек)" )
        Elseif i == 10
          add_string( s + "11.10. Рекомендованы медицинская реабилитация и (или)" )
          add_string( s + "       санаторно-курортное лечение в стационарных условиях" )
        Elseif i == 11
          add_string( s + "11.11. Проведена медицинская реабилитация и (или)" )
          add_string( s + "       санаторно-курортное лечение в стационарных условиях" )
        Else
          add_string( s + "11.12. Причины невыполнения рекомендаций по медицинской реабилитации" )
          add_string( s + "       и (или) санаторно-курортному лечению в стационарных условиях:" )
          add_string( s + "         11.12.1. не прошли всего " + lstr( vkol ) + " (человек)" )
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
            s := PadC( lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ), n )
            skol := oldkol := 0
            s1 := ""
            For k := 1 To iif( i > 10, 5, 4 )
              find ( Str( j, 1 ) + Str( i, 2 ) + Str( k, 1 ) )
              If Found() .and. ( v := tmp11->kol ) > 0
                skol += v
                If eq_any( i, 2, 5, 8, 11 )
                  s1 += Str( v, 6 )
                  find ( Str( j, 1 ) + Str( i -1, 2 ) + Str( k, 1 ) )
                  If Found() .and. tmp11->kol > 0
                    s1 += " " + umest_val( v / tmp11->kol * 100, 5, 2 )
                    oldkol += tmp11->kol
                  Else
                    s1 += Space( 6 )
                  Endif
                Else
                  s1 += " " + PadC( lstr( v ), 11 )
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
                s += Str( skol, 6 ) + " " + umest_val( skol / oldkol * 100, 5, 2 )
              Else
                s += " " + PadC( lstr( skol ), 11 )
              Endif
              add_string( s + s1 )
            Else
              add_string( s )
            Endif
          Next
          add_string( Replicate( "─", sh ) )
        Endif
      Next
      Use
      Use ( cur_dir() + "tmp16" ) index ( cur_dir() + "tmp16" ) New Alias TMP16
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "5. Число детей по уровню физического развития" )
      add_string( "────────────────────┬─────────┬─────────┬───────────────────────────────────────" )
      add_string( "                    │Число про│Норм.физ.│ Нарушения физического развития (чел.) " )
      add_string( "    Возраст детей   │шедших   │развитие ├─────────┬─────────┬─────────┬─────────" )
      add_string( "                    │проф.осм.│   чел.  │дефиц.мас│избыт.мас│низк.рост│высо.рост" )
      add_string( "────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────" )
      add_string( "          1         │    2    │    3    │    4    │    5    │    6    │    7    " )
      add_string( "────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (мальчики)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 1 To 5
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            If Found()
              s += " " + PadC( lstr( tmp16->kol ), 9 )
            Else
              s += Space( 10 )
            Endif
          Next
          add_string( s )
        Next
      Next
      add_string( Replicate( "─", sh ) )
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "6. Число детей по медицинским группам для занятий физической культурой" )
      add_string( "────────────────────┬─────────┬────────────────────────┬────────────────────────" )
      add_string( "                    │Число про│    до проф.осмотра     │ по результатам проф.осм" )
      add_string( "    Возраст детей   │шедших   ├────┬────┬────┬────┬────┼────┬────┬────┬────┬────" )
      add_string( "                    │проф.осм.│ I  │ II │ III│ IV │не д│ I  │ II │ III│ IV │не д" )
      add_string( "────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────" )
      add_string( "          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 " )
      add_string( "────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (мальчики)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
          Else
            s += Space( 10 )
          Endif
          For i := 31 To 35
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          For i := 41 To 45
            find ( Str( j, 1 ) + Str( k, 1 ) + Str( i, 2 ) )
            s += put_val( tmp16->kol, 5 )
          Next
          add_string( s )
        Next
      Next
      verify_ff( HH -21, .t., sh )
      n := 20
      add_string( "" )
      add_string( "7. Число детей по группам здоровья" )
      add_string( "────────────────────┬─────────┬────────────────────────┬────────────────────────" )
      add_string( "                    │Число про│    до проф.осмотра     │ по результатам проф.осм" )
      add_string( "    Возраст детей   │шедших   ├────┬────┬────┬────┬────┼────┬────┬────┬────┬────" )
      add_string( "                    │проф.осм.│ I  │ II │ III│ IV │ V  │ I  │ II │ III│ IV │ V  " )
      add_string( "────────────────────┼─────────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────" )
      add_string( "          1         │    2    │ 3  │ 4  │ 5  │ 6  │ 7  │ 8  │ 9  │ 10 │ 11 │ 12 " )
      add_string( "────────────────────┴─────────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────" )
      For j := 1 To Len( arr1vozrast )
        For k := 0 To 1
          s := PadR( " " + lstr( arr1vozrast[ j, 1 ] ) + " - " + lstr( arr1vozrast[ j, 2 ] ) + ;
            iif( k == 0, "", " (мальчики)" ), n )
          find ( Str( j, 1 ) + Str( k, 1 ) + Str( 0, 2 ) )
          If Found()
            s += " " + PadC( lstr( tmp16->kol ), 9 )
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
      add_string( Replicate( "─", sh ) )
      FClose( fp )
      viewtext( n_file,,,, .t.,,, 5 )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 14.07.19
Function f2_inf_dnl_030poo( Loc_kod, kod_kartotek ) // сводная информация

  Local i, j, k, av := {}, av1 := {}, ad := {}, arr, s, fl, ;
    is_man := ( human->pol == "М" ), blk_tbl, blk_tip, blk_put_tip, a10[ 9 ], a11[ 13 ]

  blk_tbl := {| _k| iif( _k < 2, 1, 2 ) }
  blk_tip := {| _k| iif( _k == 0, 2, iif( _k > 1, _k + 1, _k ) ) }
  blk_put_tip := {| _e, _k| iif( _k > _e, _k, _e ) }
  Private metap := 1, mperiod := 0, mshifr_zs := "", m1lis := 0, ;
    mkateg_uch, m1kateg_uch := 3, ; // Категория учета ребенка:
    mMO_PR := Space( 10 ), m1MO_PR := Space( 6 ), ; // код МО прикрепления
    mschool := Space( 10 ), m1school := 0, ; // код обр.учреждения
    mWEIGHT := 0, ;   // вес в кг
    mHEIGHT := 0, ;   // рост в см
    mPER_HEAD := 0, ; // окружность головы в см
    mfiz_razv, m1FIZ_RAZV := 0, ; // физическое развитие
    mfiz_razv1, m1FIZ_RAZV1 := 0, ; // отклонение массы тела
    mfiz_razv2, m1FIZ_RAZV2 := 0, ; // отклонение роста
    m1psih11 := 0, ;  // познавательная функция (возраст развития)
    m1psih12 := 0, ;  // моторная функция (возраст развития)
    m1psih13 := 0, ;  // эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития)
    m1psih14 := 0, ;  // предречевое и речевое развитие (возраст развития)
    mpsih21, m1psih21 := 0, ;  // Психомоторная сфера: (норма, отклонение)
    mpsih22, m1psih22 := 0, ;  // Интеллект: (норма, отклонение)
    mpsih23, m1psih23 := 0, ;  // Эмоционально-вегетативная сфера: (норма, отклонение)
    m141p   := 0, ; // Половая формула мальчика P
    m141ax  := 0, ; // Половая формула мальчика Ax
    m141fa  := 0, ; // Половая формула мальчика Fa
    m142p   := 0, ; // Половая формула девочки P
    m142ax  := 0, ; // Половая формула девочки Ax
    m142ma  := 0, ; // Половая формула девочки Ma
    m142me  := 0, ; // Половая формула девочки Me
    m142me1 := 0, ; // Половая формула девочки - menarhe (лет)
    m142me2 := 0, ; // Половая формула девочки - menarhe (месяцев)
    m142me3, m1142me3 := 0, ; // Половая формула девочки - menses (характеристика):
    m142me4, m1142me4 := 1, ; // Половая формула девочки - menses (характеристика):
    m142me5, m1142me5 := 1, ; // Половая формула девочки - menses (характеристика):
    mdiag_15_1, m1diag_15_1 := 1, ; // Состояние здоровья до проведения профосмотра-Практически здоров
    mdiag_15[ 5, 14 ], ; //
    mGRUPPA_DO := 0, ; // группа здоровья до дисп-ии
    mGR_FIZ_DO, m1GR_FIZ_DO := 1, ;
    mdiag_16_1, m1diag_16_1 := 1, ; // Состояние здоровья по результатам проведения профосмотра (Практически здоров)
    mdiag_16[ 5, 16 ], ; //
    minvalid[ 8 ], ;  // раздел 16.7
    mGRUPPA := 0, ;    // группа здоровья после дисп-ии
    mGR_FIZ, m1GR_FIZ := 1, ;
    mPRIVIVKI[ 3 ], ; // Проведение профилактических прививок
    mrek_form := Space( 255 ), ; // "C100",Рекомендации по формированию здорового образа жизни, режиму дня, питанию, физическому развитию, иммунопрофилактике, занятиям физической культурой
    mrek_disp := Space( 255 ), ; // "C100",Рекомендации по диспансерному наблюдению, лечению, медицинской реабилитации и санаторно-курортному лечению с указанием диагноза (код МКБ), вида медицинской организации и специальности (должности) врача
    mhormon := "0 шт.", m1hormon := 1, not_hormon, ;
    mstep2, m1step2 := 0
  Private minvalid1, m1invalid1 := 0, ;
    minvalid2, m1invalid2 := 0, ;
    minvalid3 := CToD( "" ), minvalid4 := CToD( "" ), ;
    minvalid5, m1invalid5 := 0, ;
    minvalid6, m1invalid6 := 0, ;
    minvalid7 := CToD( "" ), ;
    minvalid8, m1invalid8 := 0
  Private mprivivki1, m1privivki1 := 0, ;
    mprivivki2, m1privivki2 := 0, ;
    mprivivki3 := Space( 100 )
  Private mvar, m1var, m1lis := 0
  //
  For i := 1 To 5
    For k := 1 To 14
      s := "diag_15_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 4 )
      Endif
    Next
  Next
  //
  For i := 1 To 5
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        Private &mvar := Space( 6 )
      Else
        m1var := "m1" + s
        Private &m1var := 0
        Private &mvar := Space( 3 )
      Endif
    Next
  Next
  mvozrast := count_years( human->date_r, human->n_data )
  If !Between( mvozrast, 0, 17 )
    mvozrast := 17
  Endif
  mdvozrast := Year( human->n_data ) - Year( human->date_r )
  If !Between( mdvozrast, 0, 17 )
    mdvozrast := 17
  Endif
  read_arr_pn( Loc_kod )
  arr_deti[ 1 ] ++
  If mdvozrast < 5
    arr_deti[ 2 ] ++
  Elseif mdvozrast < 10
    arr_deti[ 3 ] ++
  Elseif mdvozrast < 15
    arr_deti[ 4 ] ++
  Else
    arr_deti[ 5 ] ++
  Endif
  For i := 1 To Len( arr_vozrast )
    If Between( mdvozrast, arr_vozrast[ i, 2 ], arr_vozrast[ i, 3 ] )
      AAdd( av, arr_vozrast[ i, 1 ] ) // список таблиц с 4 по 9
    Endif
  Next
  For i := 1 To Len( arr1vozrast )
    If Between( mdvozrast, arr1vozrast[ i, 1 ], arr1vozrast[ i, 2 ] )
      AAdd( av1, i )
    Endif
  Next
  For i := 1 To 5
    j := 0
    For k := 1 To 16
      s := "diag_16_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 16 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
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
      AAdd( au, Len( arr_4 ) -1 )  // {"18","Прочие","",,}, ;
    Endif
    Select TMP4
    For n := 1 To Len( av ) // цикл по списку таблиц с 4 по 9
      For j := 1 To Len( au )
        find ( Str( av[ n ], 1 ) + Str( au[ j ], 2 ) )
        If Found()
          tmp4->k04++
          If is_man
            tmp4->k05++
          Endif
          If ad[ i, 2 ] > 0 // уст.впервые
            tmp4->k06++
            If is_man
              tmp4->k07++
            Endif
          Endif
          If ad[ i, 3 ] > 0 // дисп.набл.установлено
            tmp4->k08++
            If is_man
              tmp4->k09++
            Endif
            If ad[ i, 3 ] == 2 // дисп.набл.установлено впервые
              tmp4->k10++
              If is_man
                tmp4->k11++
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
        find ( Str( av1[ n ], 1 ) + Str( j, 1 ) + Str( a10[ j ], 2 ) )
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
      s := "diag_15_" + lstr( i ) + "_" + lstr( k )
      mvar := "m" + s
      If k == 1
        If !Empty( &mvar )
          arr := Array( 14 ) ; AFill( arr, 0 ) ; arr[ 1 ] := AllTrim( &mvar )
          If Len( arr[ 1 ] ) > 5
            arr[ 1 ] := Left( arr[ 1 ], 5 )
          Endif
          AAdd( ad, arr ) ; j := Len( ad )
        Endif
      Elseif j > 0
        m1var := "m1" + s
        ad[ j, k ] := &m1var
      Endif
    Next
  Next
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
        find ( Str( av1[ n ], 1 ) + Str( j, 2 ) + Str( a11[ j ], 2 ) )
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
    arr_deti[ 6 ] ++
    AAdd( ad, 4 )
    If m1invalid2 == 0 // с рождения
      AAdd( ad, 1 )
    Else               // приобретенная
      AAdd( ad, 2 )
      If !Empty( minvalid3 ) .and. minvalid3 >= human->n_data
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
  If m1privivki1 == 1     // не привит по медицинским показаниям", 1}, ;
    If m1privivki2 == 1
      AAdd( ad, 21 )
    Else
      AAdd( ad, 22 )
    Endif
  Elseif m1privivki1 == 2 // не привит по другим причинам", 2}}
    If m1privivki2 == 1
      AAdd( ad, 23 )
    Else
      AAdd( ad, 24 )
    Endif
  Else                    // привит по возрасту", 0}, ;
    AAdd( ad, 20 )
  Endif
  Select TMP13
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
  mGRUPPA := human_->RSLT_NEW - 331 // L_BEGIN_RSLT
  If !Between( mgruppa, 1, 5 )
    mgruppa := 1
  Endif
  If !Between( mgruppa_do, 1, 5 )
    mgruppa_do := 1
  Endif
  If !Between( m1GR_FIZ, 0, 4 )
    m1GR_FIZ := 1
  Endif
  If !Between( m1GR_FIZ_DO, 0, 4 )
    m1GR_FIZ_DO := 1
  Endif
  AAdd( ad, mGRUPPA_DO + 10 )
  AAdd( ad, mGRUPPA + 20 )
  AAdd( ad, iif( m1GR_FIZ_DO == 0, 35, m1GR_FIZ_DO + 30 ) )
  AAdd( ad, iif( m1GR_FIZ == 0, 45, m1GR_FIZ + 40 ) )
  Select TMP16
  For n := 1 To Len( av1 ) // цикл по возрастам таблицы
    For j := 1 To Len( ad )
      find ( Str( av1[ n ], 1 ) + "0" + Str( ad[ j ], 2 ) )
      If !Found()
        Append Blank
        tmp16->voz := av1[ n ]
        tmp16->tip := ad[ j ]
      Endif
      tmp16->kol++
      If is_man
        find ( Str( av1[ n ], 1 ) + "1" + Str( ad[ j ], 2 ) )
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

// 11.03.19
Function inf_dnl_xmlfile( is_schet, stitle )

  Local arr_m, n, buf := save_maxrow(), lkod_h, lkod_k, rec, blk, t_arr[ BR_LEN ], arr, n_func

  If ( arr_m := year_month( T_ROW, T_COL -5 ) ) != NIL
    mywait()
    Do Case
    Case p_tip_lu == TIP_LU_PN
      arr := { 301, 302 } // профилактика 1 и 2 этап
    Case p_tip_lu == TIP_LU_PREDN
      arr := { 303, 304 } // пред.осмотры 1 и 2 этап
    Case p_tip_lu == TIP_LU_PERN
      arr := { 305 } // период.осмотры
    Endcase
    If f0_inf_dnl( arr_m, is_schet > 1, is_schet == 3, arr, .t. )
      Copy File ( cur_dir() + "tmp" + sdbf() ) to ( cur_dir() + "tmpDNL" + sdbf() ) // т.к. внутри тоже есть TMP-файл
      r_use( dir_server() + "human",, "HUMAN" )
      Use ( cur_dir() + "tmpDNL" ) new
      Set Relation To kod into HUMAN
      Index On Upper( human->fio ) to ( cur_dir() + "tmpDNL" )
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        e_use( cur_dir() + "tmpDNL", cur_dir() + "tmpDNL", "TMP" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
        }
      Eval( blk_open )
      Go Top
      t_arr[ BR_TOP ] := 2
      t_arr[ BR_BOTTOM ] := 23
      t_arr[ BR_LEFT ] := 0
      t_arr[ BR_RIGHT ] := 79
      stitle := "XML-портал: " + stitle + " несовершеннолетних "
      t_arr[ BR_TITUL ] := stitle + arr_m[ 4 ]
      t_arr[ BR_TITUL_COLOR ] := "B/BG"
      t_arr[ BR_COLOR ] := color0
      t_arr[ BR_ARR_BROWSE ] := { '═', '░', '═', "N/BG,W+/N,B/BG,W+/B", .t. }
      blk := {|| iif( tmp->is == 1, { 1, 2 }, { 3, 4 } ) }
      t_arr[ BR_COLUMN ] := { { " ", {|| iif( tmp->is == 1, "", " " ) }, blk }, ;
        { " Ф.И.О.", {|| PadR( human->fio, 37 ) }, blk }, ;
        { "Дата рожд.", {|| full_date( human->date_r ) }, blk }, ;
        { "№ ам.карты", {|| human->uch_doc }, blk }, ;
        { "Сроки леч-я", {|| Left( date_8( human->n_data ), 5 ) + "-" + Left( date_8( human->k_data ), 5 ) }, blk }, ;
        { "Этап", {|| iif( eq_any( human->ishod, 301, 303, 305 ), " I  ", "I-II" ) }, blk } }
      t_arr[ BR_STAT_MSG ] := {|| status_key( "^<Esc>^ - выход для создания файла;  ^<+,-,Ins>^ - отметить/снять отметку с пациента" ) }
      t_arr[ BR_EDIT ] := {| nk, ob| f1_inf_n_xmlfile( nk, ob, "edit" ) }
      edit_browse( t_arr )
      Select TMP
      Delete For is == 0
      Pack
      n := LastRec()
      Close databases
      rest_box( buf )
      If n == 0 .or. !f_esc_enter( "составления XML-файла" )
        Return Nil
      Endif
      mywait()
      r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmprpdsh" )
      Use
      r_use( dir_server() + "mo_raksh",, "RAKSH" )
      Index On Str( KOD_H, 7 ) to ( cur_dir() + "tmpraksh" )
      Use
      Private blk_open := {|| dbCloseAll(), ;
        r_use( dir_server() + "human_",, "HUMAN_" ), ;
        r_use( dir_server() + "human",, "HUMAN" ), ;
        dbSetRelation( "HUMAN_", {|| RecNo() }, "recno()" ), ;
        e_use( cur_dir() + "tmpDNL", cur_dir() + "tmpDNL", "TMP" ), ;
        dbSetRelation( "HUMAN", {|| kod }, "kod" );
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
        @ MaxRow(), 0 Say PadR( Str( n / tmp->( LastRec() ) * 100, 6, 2 ) + "%" + " " + ;
          RTrim( human->fio ) + " " + date_8( human->n_data ) + "-" + ;
          date_8( human->k_data ), 80 ) Color cColorWait
        lkod_h := human->kod
        lkod_k := human->kod_k
        Close databases
        n_func := "f2_inf_N_XMLfile"
        Do Case
        Case p_tip_lu == TIP_LU_PN
          oms_sluch_pn( lkod_h, lkod_k, n_func ) // профилактика 1 и 2 этап
        Case p_tip_lu == TIP_LU_PREDN
          oms_sluch_predn( lkod_h, lkod_k, n_func ) // пред.осмотры 1 и 2 этап
        Case p_tip_lu == TIP_LU_PERN
          oms_sluch_pern( lkod_h, lkod_k, n_func ) // период.осмотры
        Endcase
      Enddo
      Close databases
      rest_box( buf )
      mo_mzxml_n( 3, "tmp", stitle )
    Endif
  Endif
  Close databases
  rest_box( buf )

  Return Nil

// 22.11.13
Function f1_inf_n_xmlfile( nKey, oBrow, regim )

  Local ret := -1, rec := tmp->( RecNo() )

  If regim == "edit"
    Do Case
    Case nkey == K_INS
      tmp->is := iif( tmp->is == 1, 0, 1 )
      ret := 0
      Keyboard Chr( K_TAB )
    Case nkey == 43  // +
      tmp->( dbEval( {|| tmp->is := 1 } ) )
      Goto ( rec )
      ret := 0
    Case nkey == 45  // -
      tmp->( dbEval( {|| tmp->is := 0 } ) )
      Goto ( rec )
      ret := 0
    Endcase
  Endif

  Return ret

// 22.11.13 по листу учёта несовершеннолетнего создать часть XML-файла
Function f2_inf_n_xmlfile( Loc_kod, kod_kartotek, lvozrast )

  Local adbf, s, i, j, k, y, m, d, fl

  r_use( dir_server() + "kartote_",, "KART_" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "kartotek",, "KART" )
  Goto ( kod_kartotek )
  r_use( dir_server() + "human_",, "HUMAN_" )
  Goto ( Loc_kod )
  r_use( dir_server() + "human",, "HUMAN" )
  Goto ( Loc_kod )
  r_use( dir_server() + "mo_pers",, "P2" )
  Goto ( m1vrach )
  r_use( dir_server() + "organiz",, "ORG" )
  r_use( dir_server() + "mo_rpdsh", cur_dir() + "tmprpdsh", "RPDSH" )
  r_use( dir_server() + "mo_raksh", cur_dir() + "tmpraksh", "RAKSH" )
  mo_mzxml_n( 2,,, lvozrast )

  Return Nil

// 25.11.13
Function f4_inf_predn_karta( par, _etap )

  Local i, k, fl, arr := {}, ar := npred_arr_1_etap[ mperiod ]

  If par == 1
    If iif( _etap == nil, .t., _etap == 1 )
      For i := 1 To count_predn_arr_osm
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( npred_arr_osmotr[ i, 2 ] )
          fl := ( mpol == npred_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( !Empty( ar[ 4 ] ) .and. AScan( ar[ 4 ], npred_arr_osmotr[ i, 1 ] ) > 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { npred_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
    Endif
    AAdd( arr, { "педиатр (врач общей практики)", MDATEp1, "", -1, 1 } )
    If metap == 2 .and. iif( _etap == nil, .t., _etap == 2 )
      For i := 1 To count_predn_arr_osm
        mvart := "MTAB_NOMov" + lstr( i )
        mvard := "MDATEo" + lstr( i )
        fl := .t.
        If fl .and. !Empty( npred_arr_osmotr[ i, 2 ] )
          fl := ( mpol == npred_arr_osmotr[ i, 2 ] )
        Endif
        If fl
          fl := ( AScan( ar[ 4 ], npred_arr_osmotr[ i, 1 ] ) == 0 )
        Endif
        If fl .and. !emptyany( &mvard, &mvart )
          AAdd( arr, { npred_arr_osmotr[ i, 3 ], &mvard, "", i, f5_inf_dnl_karta( i ) } )
        Endif
      Next
      AAdd( arr, { "педиатр (врач общей практики)", MDATEp2, "", -2, 1 } )
    Endif
  Else
    For i := 1 To count_predn_arr_iss // исследования
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      fl := .t.
      If fl .and. !Empty( npred_arr_issled[ i, 2 ] )
        fl := ( mpol == npred_arr_issled[ i, 2 ] )
      Endif
      If fl
        fl := ( AScan( ar[ 5 ], npred_arr_issled[ i, 1 ] ) > 0 )
      Endif
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i ==  1 // {"4.2.153" ,   , "Общий анализ мочи", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
        Case i ==  2 // {"4.11.136",   , "Клинический анализ крови", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
        Case i ==  3 // {"4.12.169",   , "Исследование уровня глюкозы в крови", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 4
        Case i ==  4 // {"4.8.12"  ,   , "Анализ кала на яйца глистов", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 16
        Case i ==  5 // {"7.61.3"  ,   , "Флюорография легких в 1-й проекции", 0, 78,{1118, 1802} }, ;
          k := 12
        Case i ==  6 // {"8.1.2"   ,   , "УЗИ щитовидной железы", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 8
        Case i ==  7 // {"8.1.3"   ,   , "УЗИ сердца", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 7
        Case i ==  8 // {"8.2.1"   ,   , "УЗИ органов брюшной полости", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 6
        Case i ==  9 // {"8.2.2"   ,"М", "УЗИ органов репродуктивной системы", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 9
        Case i == 10 // {"8.2.3"   ,"Ж", "УЗИ органов репродуктивной системы", 0, 106,{110101, 111004, 111802, 111903, 112211, 112610, 113416, 113508, 180203} }, ;
          k := 9
        Case i == 11 // {"13.1.1"  ,   , "Электрокардиография", 0, 111,{110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202} }, ;
          k := 13
        Endcase
        AAdd( arr, { npred_arr_issled[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
  Endif

  Return arr

// 25.11.13
Function f4_inf_pern_karta( par )

  Local i, k, fl, arr := {}, ar := nper_arr_1_etap[ mperiod ]

  If par == 1
    AAdd( arr, { "педиатр (врач общей практики)", MDATEp1, "", -1, 1 } )
  Else
    For i := 1 To count_Pern_arr_iss // исследования
      mvart := "MTAB_NOMiv" + lstr( i )
      mvard := "MDATEi" + lstr( i )
      mvarr := "MREZi" + lstr( i )
      fl := ( AScan( ar[ 5 ], nPer_arr_issled[ i, 1 ] ) > 0 )
      If fl .and. !emptyany( &mvard, &mvart )
        k := 0
        Do Case
        Case i ==  1 // {"4.2.153" ,   , "Общий анализ мочи", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 2
        Case i ==  1 // {"4.11.136",   , "Клинический анализ крови", 0, 34,{1107, 1301, 1402, 1702} }, ;
          k := 1
        Case i ==  1 // {"16.1.16" ,   , "Анализ окиси углерода выдыхаем.воздуха", 0, 34,{1107, 1301, 1402, 1702} };
          k := 17
        Endcase
        AAdd( arr, { nPer_arr_issled[ i, 3 ], &mvard, &mvarr, i, k } )
      Endif
    Next
  Endif

  Return arr

// 12.09.25 Запрос несовершеннолетних, подлежащих медосмотрам, методом многовариантного поиска
Function mnog_poisk_dnl()

  Local mm_tmp := {}, mm_sort
  Local buf := SaveScreen(), tmp_color := SetColor( cDataCGet ), ;
    tmp_help := help_code, hGauge, name_file := cur_dir() + "_kartDNL.txt", ;
    sh := 80, HH := 77, i, a_diagnoz[ 10 ], ta, name_dbf := cur_dir() + "_kartDNL" + sdbf(), ;
    mm_da_net := { { "нет", 1 }, { "да ", 2 } }, ;
    mm_mest := { { "Волгоград или область", 1 }, { "иногородние", 2 } }, ;
    mm_disp := { { "неважно", 0 }, { "не проходили", 1 }, { "прошли", 2 } }, ;
    mm_death := { { "выводить всех", 0 }, { "не выводить умерших", 1 }, { "выводить только умерших", 2 } }, ;
    mm_prik := { { "неважно", 0 }, ;
    { "прикреплён к нашей МО", 1 }, ;
    { "прикреплён к другим МО", 2 }, ;
    { "прикрепление неизвестно", 3 } }, ;
    tmp_file := cur_dir() + "tmp_mn_p" + sdbf(), ;
    k_fio, k_adr, tt_fio[ 10 ], tt_adr[ 10 ], fl_exit := .f.
  Local adbf := { ;
    { "UCHAST",   "N",  2, 0 }, ; // номер участка
    { "KOD_VU",   "N",  6, 0 }, ; // код в участке
    { "FIO",   "C", 50, 0 }, ; // Ф.И.О. больного
    { "PHONE",   "C", 40, 0 }, ; // телефон больного
    { "POL",   "C",  1, 0 }, ; // пол
    { "DATE_R", "C", 10, 0 }, ; // дата рождения больного
    { "LET",   "N",  2, 0 }, ; // сколько лет в этом году
    { "ADRESR",  "C", 50, 0 }, ; // адрес больного
    { "ADRESP",  "C", 50, 0 }, ; // адрес больного
    { "POLIS",     "C", 17, 0 }, ; // полис
    { "KOD_SMO",   "C",  5, 0 }, ; //
    { "SMO",       "C", 80, 0 }, ; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
    { "SNILS",   "C", 14, 0 }, ;
    { "MO_PR",     "C",  6, 0 }, ; // код МО приписки
    { "MONAME_PR", "C", 60, 0 }, ; // наименование МО приписки
    { "DATE_PR", "C", 10, 0 }, ; // дата приписки
    { "LAST_L_U", "C", 10, 0 };  // дата последнего листа учёта
  }
  If !myfiledeleted( name_dbf )
    Return Nil
  Endif
  Private mm_smo := {}, pyear, mstr_crb := 0, is_kategor2 := .f., is_talon := ret_is_talon()
  If is_talon
    is_kategor2 := !Empty( stm_kategor2 )
  Endif
  For i := 1 To Len( glob_arr_smo )
    If glob_arr_smo[ i, 3 ] == 1
      AAdd( mm_smo, { glob_arr_smo[ i, 1 ], PadR( lstr( glob_arr_smo[ i, 2 ] ), 5 ) } )
    Endif
  Next
  ta := f2_mnog_poisk_dnl(,,, 1 )
  AAdd( mm_tmp, { "god", "N", 4, 0, "9999", ;
    nil, ;
    Year( sys_date ), nil, ;
    "В каком году не было медомотра/диспансеризации" } )
  AAdd( mm_tmp, { "v_period", "C", 100, 0, NIL, ;
    {| x| menu_reader( x, { {| k, r, c| f2_mnog_poisk_dnl( k, r, c ) } }, A__FUNCTION ) }, ;
    ta[ 1 ], {| x| ta[ 2 ] }, ;
    'Возрастные периоды медомотра/диспансеризации' } )
  AAdd( mm_tmp, { "o_prik", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_prik, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_prik, x ) }, ;
    "Отношение к прикреплению" } )
  AAdd( mm_tmp, { "o_death", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_death, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_death, x ) }, ;
    "Сведения о смерти по сведениям ТФОМС" } )
  Private arr_uchast := {}
  If is_uchastok > 0
    AAdd( mm_tmp, { "bukva", "C", 1, 0, "@!", ;
      nil, ;
      " ", nil, ;
      "Буква (перед участком)" } )
    AAdd( mm_tmp, { "uchast", "N", 1, 0,, ;
      {| x| menu_reader( x, { {| k, r, c| get_uchast( r + 1, c ) } }, A__FUNCTION ) }, ;
      0, {|| init_uchast( arr_uchast ) }, ;
      "Участок (участки)" } )
    mm_sort := { ;
      { "№ участка + Лет + ФИО", 1 }, ;
      { "№ участка + Лет + Адрес", 2 }, ;
      { "№ участка + Адрес + Лет", 4 };
      }
    If is_uchastok == 1
      AAdd( mm_sort, { '№ участка + № в участке', 3 } )
    Elseif is_uchastok == 2
      AAdd( mm_sort, { '№ участка + Код по картотеке', 3 } )
    Elseif is_uchastok == 3
      AAdd( mm_sort, { '№ участка + номер АК МИС', 3 } )
    Endif
  Else
    mm_sort := { ;
      { "Лет + ФИО", 1 }, ;
      { "Лет + Адрес", 2 }, ;
      { "Код по картотеке", 3 };
      }
    del_array( adbf, 1 ) // убираем участок
    del_array( adbf, 1 ) // убираем участок
  Endif
  AAdd( mm_tmp, { "fio", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "ФИО (начальные буквы или шаблон)" } )
  AAdd( mm_tmp, { "mi_git", "N", 2, 0, NIL, ;
    {| x| menu_reader( x, mm_mest, A__MENUVERT ) }, ;
    -1, {|| Space( 10 ) }, ;
    "Место жительства:" } )
  AAdd( mm_tmp, { "_okato", "C", 11, 0, NIL, ;
    {| x| menu_reader( x, ;
    { {| k, r, c| get_okato_ulica( k, r, c, { k, m_okato, } ) } }, A__FUNCTION ) }, ;
    Space( 11 ), {| x| Space( 11 ) }, ;
    'Адрес регистрации (ОКАТО)' } )
  AAdd( mm_tmp, { "adres", "C", 20, 0, "@!", ;
    nil, ;
    Space( 20 ), nil, ;
    "Улица (подстрока или шаблон)" } )
  If is_talon
    AAdd( mm_tmp, { "kategor", "N", 2, 0, NIL, ;
      {| x| menu_reader( x, mo_cut_menu( stm_kategor ), A__MENUVERT ) }, ;
      0, {|| Space( 10 ) }, ;
      "Код категории льготы" } )
    If is_kategor2
      AAdd( mm_tmp, { "kategor2", "N", 4, 0, NIL, ;
        {| x| menu_reader( x, stm_kategor2, A__MENUVERT ) }, ;
        0, {|| Space( 10 ) }, ;
        "Категория МО" } )
    Endif
  Endif
  AAdd( mm_tmp, { "pol", "C", 1, 0, "!", ;
    nil, ;
    " ", nil, ;
    "Пол", {|| mpol $ " МЖ" } } )
  AAdd( mm_tmp, { "god_r_min", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "Дата рождения (минимальная)" } )
  AAdd( mm_tmp, { "god_r_max", "D", 8, 0,, ;
    nil, ;
    CToD( "" ), nil, ;
    "Дата рождения (максимальная)" } )
  AAdd( mm_tmp, { "smo", "C", 5, 0, NIL, ;
    {| x| menu_reader( x, mm_smo, A__MENUVERT ) }, ;
    Space( 5 ), {|| Space( 10 ) }, ;
    "Страховая компания" } )
  AAdd( mm_tmp, { "i_sort", "N", 1, 0, NIL, ;
    {| x| menu_reader( x, mm_sort, A__MENUVERT ) }, ;
    1, {| x| inieditspr( A__MENUVERT, mm_sort, x ) }, ;
    "Сортировка выходного документа" } )
  Delete File ( tmp_file )
  init_base( tmp_file,, mm_tmp, 0 )
  //
  k := f_edit_spr( A__APPEND, mm_tmp, "множественному запросу", ;
    "e_use(cur_dir()+'tmp_mn_p')", 0, 1,,,,, "write_mn_p_DNL" )
  If k > 0
    mywait()
    Use ( tmp_file ) New Alias MN
    If is_talon .and. mn->kategor == 0
      is_talon := ( is_kategor2 .and. mn->kategor2 > 0 )
    Endif
    Private mfio := "", madres := "", arr_vozr := list2arr( mn->v_period )
    If !Empty( mn->fio )
      mfio := AllTrim( mn->fio )
      If !( Right( mfio, 1 ) == "*" )
        mfio += "*"
      Endif
    Endif
    If !Empty( mn->adres )
      madres := AllTrim( mn->adres )
      If !( Left( madres, 1 ) == "*" )
        madres := "*" + madres
      Endif
      If !( Right( madres, 1 ) == "*" )
        madres += "*"
      Endif
    Endif
    Private c_view := 0, c_found := 0
    status_key( "^<Esc>^ - прервать поиск" )
    hGauge := gaugenew(,,, "Поиск в картотеке", .t. )
    gaugedisplay( hGauge )
    //
    dbCreate( cur_dir() + "tmp", { { "kod", "N", 7, 0 } },, .t., "TMP" )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humankk", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    r_use( dir_server() + "kartote2",, "KART2" )
    r_use( dir_server() + "kartote_",, "KART_" )
    r_use( dir_server() + "kartotek",, "KART" )
    Set Relation To RecNo() into KART_, RecNo() into KART2
    Go Top
    Do While !Eof()
      gaugeupdate( hGauge, RecNo() / LastRec() )
      If Inkey() == K_ESC
        fl_exit := .t. ; Exit
      Endif
      f1_mnog_poisk_dnl( @c_view, @c_found )
      Select KART
      Skip
    Enddo
    closegauge( hGauge )
    j := tmp->( LastRec() )
    Close databases
    If j == 0
      If !fl_exit
        func_error( 4, "Нет сведений!" )
      Endif
    Else
      stat_msg( "Составление текстового и DBF-файлов" )
      Use ( tmp_file ) New Alias MN
      arr_title := { ;
        "─────┬", ;
        " №№  │", ;
        " пп  │", ;
        "─────┴" }
      If is_uchastok > 0 .or. mn->i_sort == 3 // Код по картотеке
        arr_title[ 1 ] += "─────────┬"
        arr_title[ 2 ] += " Участок │"
        arr_title[ 3 ] += "   код   │"
        arr_title[ 4 ] += "─────────┴"
      Endif
      arr_title[ 1 ] += "───────────────────────────────────────────┬──┬──────────┬───────────────────────────────────┬─────┬──────────"
      arr_title[ 2 ] += "             Ф.И.О. пациента               │Ле│   дата   │              Адрес                │при- │последний "
      arr_title[ 3 ] += "                (телефон)                  │т │ рождения │                                   │креп.│л/у по ОМС"
      arr_title[ 4 ] += "───────────────────────────────────────────┴──┴──────────┴───────────────────────────────────┴─────┴──────────"
      reg_print := f_reg_print( arr_title, @sh, 2 )
      dbCreate( name_dbf, adbf,, .t., "DVN" )
      r_use( dir_server() + "human", dir_server() + "humankk", "HUMAN" )
      r_use( dir_server() + "kartote2",, "KART2" )
      r_use( dir_server() + "kartote_",, "KART_" )
      r_use( dir_server() + "kartotek",, "KART" )
      Set Relation To RecNo() into KART_, To RecNo() into KART2
      Use ( cur_dir() + "tmp" ) new
      Set Relation To kod into KART
      If is_uchastok > 0
        If mn->i_sort == 1 // № участка + Год рождения + ФИО
          Index On Str( kart->uchast, 2 ) + Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 2 // № участка + Год рождения + Адрес
          Index On Str( kart->uchast, 2 ) + Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->adres ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 4 // № участка + Адрес + Год рождения
          Index On Str( kart->uchast, 2 ) + Upper( kart->adres ) + Str( mn->god - Year( kart->date_r ), 4 ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 3 // № участка + Код
          If is_uchastok == 1 // № участка + № в участке
            Index On Str( kart->uchast, 2 ) + Str( kart->kod_vu, 5 ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
          Elseif is_uchastok == 2 // № участка + Код по картотеке
            Index On Str( kart->uchast, 2 ) + Str( kart->kod, 7 ) to ( cur_dir() + "tmp" )
          Elseif is_uchastok == 3 // № участка + номер АК МИС
            Index On Str( kart->uchast, 2 ) + kart2->kod_AK + Upper( kart->fio ) to ( cur_dir() + "tmp" )
          Endif
        Endif
      Else
        If mn->i_sort == 1 // Год рождения + ФИО
          Index On Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->fio ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 2 // Год рождения + Адрес
          Index On Str( mn->god - Year( kart->date_r ), 4 ) + Upper( kart->adres ) to ( cur_dir() + "tmp" )
        Elseif mn->i_sort == 3 // Код по картотеке
          Index On Str( kod, 7 ) to ( cur_dir() + "tmp" )
        Endif
      Endif
      fp := FCreate( name_file ) ; n_list := 1 ; tek_stroke := 0
      add_string( "" )
      add_string( Center( Expand( "РЕЗУЛЬТАТ МНОГОВАРИАНТНОГО ПОИСКА" ), sh ) )
      add_string( "" )
      add_string( " == ПАРАМЕТРЫ ПОИСКА ==" )
      add_string( "В каком году не было медосмотра/диспансеризации несовершеннолетних: " + lstr( mn->god ) )
      If !Empty( mn->v_period )
        add_string( "Возрастные периоды медосмотра/диспансеризации: " + AllTrim( mn->v_period ) )
      Endif
      If mn->o_death == 1
        add_string( "За исключением умерших (по сведению ТФОМС)" )
      Elseif mn->o_death == 2
        add_string( "Список умерших (по сведению ТФОМС)" )
      Endif
      If !Empty( mn->o_prik )
        add_string( "Отношение к прикреплению: " + inieditspr( A__MENUVERT, mm_prik, mn->o_prik ) )
      Endif
      If is_uchastok > 0
        If !Empty( mn->bukva )
          add_string( "Буква: " + mn->bukva )
        Endif
        If !Empty( mn->uchast )
          add_string( "Участок: " + init_uchast( arr_uchast ) )
        Endif
      Endif
      If !Empty( mfio )
        add_string( "ФИО: " + mfio )
      Endif
      If mn->mi_git > 0
        add_string( "Место жительства: " + inieditspr( A__MENUVERT, mm_mest, mn->mi_git ) )
      Endif
      If !Empty( mn->_okato )
        add_string( "Адрес регистрации (ОКАТО): " + ret_okato_ulica( '', mn->_okato ) )
      Endif
      If !Empty( madres )
        add_string( "Улица: " + madres )
      Endif
      If is_talon .and. mn->kategor > 0
        add_string( "Код категории льготы: " + inieditspr( A__MENUVERT, stm_kategor, mn->kategor ) )
      Endif
      If is_talon .and. is_kategor2 .and. mn->kategor2 > 0
        add_string( "Категория МО: " + inieditspr( A__MENUVERT, stm_kategor2, mn->kategor2 ) )
      Endif
      If !Empty( mn->pol )
        add_string( "Пол: " + mn->pol )
      Endif
      If !Empty( mn->god_r_min ) .or. !Empty( mn->god_r_max )
        If Empty( mn->god_r_min )
          add_string( "Лица, родившиеся до " + full_date( mn->god_r_max ) )
        Elseif Empty( mn->god_r_max )
          add_string( "Лица, родившиеся после " + full_date( mn->god_r_min ) )
        Else
          add_string( "Лица, родившиеся с " + full_date( mn->god_r_min ) + " по " + full_date( mn->god_r_max ) )
        Endif
      Endif
      If !Empty( mn->smo )
        add_string( "СМО: " + inieditspr( A__MENUVERT, mm_smo, mn->smo ) )
      Endif
      add_string( "" )
      add_string( "Найдено пациентов: " + lstr( tmp->( LastRec() ) ) + " чел." )
      AEval( arr_title, {| x| add_string( x ) } )
      ii := 0
      Select TMP
      Go Top
      Do While !Eof()
        ++ii
        @ 24, 1 Say Str( ii / tmp->( LastRec() ) * 100, 6, 2 ) + "%" Color cColorSt2Msg
        If Inkey() == K_ESC
          fl_exit := .t. ; Exit
        Endif
        mdate := CToD( "" )
        Select HUMAN
        find ( Str( tmp->kod, 7 ) )
        Do While human->kod_k == tmp->kod .and. !Eof()
          If Empty( mdate )
            mdate := human->k_data
          Else
            mdate := Max( mdate, human->k_data )
          Endif
          Skip
        Enddo
        Select DVN
        Append Blank
        s1 := PadR( lstr( ii ), 6 )
        If is_uchastok > 0 .or. mn->i_sort == 3
          If is_uchastok > 0
            s := ""
            If !Empty( kart->uchast )
              dvn->UCHAST := kart->uchast
              s += lstr( kart->uchast )
            Endif
            If is_uchastok == 1 .and. !Empty( kart->kod_vu ) // № участка + № в участке
              s += "/" + lstr( kart->kod_vu )
              dvn->KOD_VU := kart->kod_vu
            Elseif is_uchastok == 2 // № участка + Код по картотеке
              s += "/" + lstr( kart->kod )
              dvn->KOD_VU := kart->kod
            Elseif is_uchastok == 3 .and. !Empty( kart2->kod_AK ) // № участка + номер АК МИС
              s += "/" + LTrim( kart2->kod_AK )
              dvn->KOD_VU := Val( kart2->kod_AK )
            Endif
          Else
            s := PadL( lstr( tmp->kod ), 9 )
          Endif
          s1 += PadR( s, 10 )
        Endif
        s := ""
        If !Empty( kart_->PHONE_H )
          s += "д." + AllTrim( kart_->PHONE_H ) + " "
        Endif
        If !Empty( kart_->PHONE_M )
          s += "м." + AllTrim( kart_->PHONE_M ) + " "
        Endif
        If !Empty( kart_->PHONE_W )
          s += "р." + AllTrim( kart_->PHONE_W )
        Endif
        dvn->FIO := kart->fio
        dvn->PHONE := s
        s := AllTrim( kart->fio ) + " " + s
        k_fio := perenos( tt_fio, s, 43 )
        s1 += PadR( tt_fio[ 1 ], 44 )
        s1 += Str( mn->god - Year( kart->date_r ), 2 ) + " "
        s1 += full_date( kart->date_r ) + " "
        dvn->POL := kart->pol
        dvn->DATE_R := full_date( kart->date_r )
        dvn->LET := mn->god - Year( kart->date_r )
        k_adr := perenos( tt_adr, kart->adres, 35 )
        s1 += PadR( tt_adr[ 1 ], 36 )
        dvn->ADRESR := kart->adres
        dvn->ADRESP := kart_->adresp
        dvn->POLIS := LTrim( kart_->NPOLIS )
        dvn->KOD_SMO := kart_->smo
        dvn->SMO := smo_to_screen( 1 )
//        dvn->SNILS := iif( Empty( kart->SNILS ), "", Transform( kart->SNILS, picture_pf ) )
        dvn->SNILS := iif( Empty( kart->SNILS ), "", Transform_SNILS( kart->SNILS ) )
        If !Empty( dvn->mo_pr := kart2->mo_pr )
          dvn->MONAME_PR := ret_mo( kart2->mo_pr )[ _MO_SHORT_NAME ]
          If !Empty( kart2->pc4 )
            dvn->DATE_PR := Left( kart2->pc4, 6 ) + "20" + SubStr( kart2->pc4, 7 )
          Else
            dvn->DATE_PR := full_date( kart2->DATE_PR )
          Endif
        Endif
        If Empty( kart2->MO_PR )
          s := ""
        Elseif kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ]
          s := "наш"
        Else
          s := "чужой"
        Endif
        s1 += PadR( s, 6 )
        s1 += full_date( mdate )
        dvn->last_l_u := full_date( mdate )
        If verify_ff( HH, .t., sh )
          AEval( arr_title, {| x| add_string( x ) } )
        Endif
        add_string( s1 )
        For i := 2 To Max( k_fio, k_adr )
          s1 := Space( 6 )
          If is_uchastok > 0 .or. mn->i_sort == 3
            s1 += Space( 10 )
          Endif
          s1 += PadR( tt_fio[ i ], 44 )
          s1 += Space( 14 )
          s1 += tt_adr[ i ]
          add_string( s1 )
        Next
        add_string( Replicate( "-", sh ) )
        Select TMP
        Skip
      Enddo
      If fl_exit
        add_string( "//* " + Expand( "ОПЕРАЦИЯ ПРЕРВАНА" ) )
      Else
        add_string( "Итого количество пациентов: " + lstr( tmp->( LastRec() ) ) + " чел." )
      Endif
      FClose( fp )
      Close databases
      RestScreen( buf )
      viewtext( name_file,,,, .t.,,, reg_print )
      n_message( { "Создан файл для загрузки в Excel: " + name_dbf },, cColorStMsg, cColorStMsg,,, cColorSt2Msg )
    Endif
  Endif
  Close databases
  RestScreen( buf ) ; SetColor( tmp_color )

  Return Nil

// 31.10.16
Function write_mn_p_dnl( k )

  Local fl := .t.

  If k == 1
    If Empty( mgod )
      fl := func_error( 4, 'Должно быть заполнено поле "Год проведения медосмотра/диспансеризации"' )
    Elseif Empty( mv_period )
      fl := func_error( 4, 'Должен быть введён хотя бы один возрастной период медосмотра/диспансеризации' )
    Endif
  Endif

  Return fl

// 21.11.19
Static Function f1_mnog_poisk_dnl( cv, cf )

  Local i, j, k, n, s, arr, fl, god_r, arr1, vozr

  ++cv
  vozr := mn->god - Year( kart->date_r )
  If ( fl := ( vozr < 18 ) )
    fl := ( AScan( arr_vozr, vozr ) > 0 )
  Endif
  If fl
    Select HUMAN
    find ( Str( kart->kod, 7 ) )
    Do While human->kod_k == kart->kod .and. !Eof()
      If Year( human->k_data ) == mn->god .and. eq_any( human->ishod, 101, 102, 301, 302, 303, 304, 305 )
        fl := .f. ; Exit
      Endif
      Skip
    Enddo
  Endif
  If fl .and. !Empty( mn->o_prik )
    If mn->o_prik == 1 // к нашей МО
      fl := ( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
    Elseif mn->o_prik == 2 // к другим МО
      fl := !( kart2->MO_PR == glob_mo[ _MO_KOD_TFOMS ] )
    Else // прикрепление неизвестно
      fl := Empty( kart2->MO_PR )
    Endif
  Endif
  If fl .and. mn->o_death > 0
    If mn->o_death == 1 // За исключением умерших (по сведению ТФОМС)
      fl := !( Left( kart2->PC2, 1 ) == "1" )
    Elseif mn->o_death == 2 // Список умерших (по сведению ТФОМС)
      fl := ( Left( kart2->PC2, 1 ) == "1" )
    Endif
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->bukva )
    fl := ( mn->bukva == kart->bukva )
  Endif
  If fl .and. is_uchastok > 0 .and. !Empty( mn->uchast )
    fl := f_is_uchast( arr_uchast, kart->uchast )
  Endif
  If fl .and. !Empty( mfio )
    fl := Like( mfio, Upper( kart->fio ) )
  Endif
  If fl .and. !Empty( madres )
    fl := Like( madres, Upper( kart->adres ) )
  Endif
  If fl .and. is_talon .and. mn->kategor > 0
    fl := ( mn->kategor == kart_->kategor )
  Endif
  If fl .and. is_kategor2 .and. mn->kategor2 > 0
    fl := ( mn->kategor2 == kart_->kategor2 )
  Endif
  If fl .and. !Empty( mn->pol )
    fl := ( kart->pol == mn->pol )
  Endif
  If fl .and. !Empty( mn->god_r_min )
    fl := ( mn->god_r_min <= kart->date_r )
  Endif
  If fl .and. !Empty( mn->god_r_max )
    fl := ( human->date_r <= mn->god_r_max )
  Endif
  If fl .and. mn->mi_git > 0
    If mn->mi_git == 1
      fl := ( Left( kart_->okatog, 2 ) == '18' )
    Else
      fl := !( Left( kart_->okatog, 2 ) == '18' )
    Endif
  Endif
  If fl .and. !Empty( mn->_okato )
    s := mn->_okato
    For i := 1 To 3
      If Right( s, 3 ) == '000'
        s := Left( s, Len( s ) -3 )
      Else
        Exit
      Endif
    Next
    fl := ( Left( kart_->okatog, Len( s ) ) == s )
  Endif
  If fl .and. !Empty( mn->smo )
    fl := ( kart_->smo == mn->smo )
  Endif
  If fl
    Select TMP
    Append Blank
    tmp->kod := kart->kod
    If++cf % 5000 == 0
      tmp->( dbCommit() )
    Endif
  Endif
  @ 24, 1 Say lstr( cv ) Color cColorSt2Msg
  @ Row(), Col() Say "/" Color "W/R"
  @ Row(), Col() Say lstr( cf ) Color cColorStMsg

  Return Nil

// 31.10.16 запрос в GET-е возрастных периодов медомотров несовершеннолетних
Function f2_mnog_poisk_dnl( k, r, c, par )

  Static sast, sarr
  Local buf := save_maxrow(), a, i, j, s, s1

  Default par To 2
  If sast == NIL
    sast := {} ; sarr := {}
    For j := 0 To 17
      AAdd( sast, .t. )
      s := lstr( j )
      If j == 1
        s += " год"
      Elseif Between( j, 2, 4 )
        s += " года"
      Else
        s += " лет"
      Endif
      AAdd( sarr, { s, j } )
    Next
  Endif
  s := s1 := ""
  If par == 1
    sast := {}
    For i := 1 To Len( sarr )
      AAdd( sast, .t. )
      s += lstr( sarr[ i, 2 ] ) + iif( i < Len( sarr ), ",", "" )
    Next
    s1 := "все"
  Elseif ( a := bit_popup( r, c, sarr, sast ) ) != NIL
    AFill( sast, .f. )
    For i := 1 To Len( a )
      If ( j := AScan( sarr, {| x| x[ 2 ] == a[ i, 2 ] } ) ) > 0
        sast[ j ] := .t.
        s += lstr( a[ i, 2 ] ) + iif( i < Len( a ), ",", "" )
      Endif
    Next
    If Len( a ) == Len( sast )
      s1 := "все"
    Endif
  Endif
  If Empty( s )
    s := Space( 10 )
  Endif
  If Empty( s1 )
    s1 := s
  Endif

  Return { s, s1 }

// 18.12.13 Сводные документы по всем видам диспансеризации и профилактики
Function inf_disp( k )

  Static si1 := 1, si2 := 1
  Local mas_pmt, mas_msg, mas_fun

  Default k To 1
  Do Case
  Case k == 1
    mas_pmt := { "~Итоги для ТФОМС" }
    mas_msg := { "Итоги за период времени для ТФОМС" }
    mas_fun := { "inf_DISP(11)" }
    popup_prompt( T_ROW, T_COL -5, si1, mas_pmt, mas_msg, mas_fun )
  Case k == 11
    itog_svod_disp_tf()
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

// 18.12.13 Итоги за период времени для ТФОМС
Function itog_svod_disp_tf()

  Local i, k, arr_m, buf := save_maxrow(), ;
    sh := 80, hh := 60, n_file := cur_dir() + "svod_dis.txt"

  If ( arr_m := year_month(,,, 5 ) ) != NIL
    mywait()
    dbCreate( cur_dir() + "tmpk", { { "kod", "N", 7, 0 }, ;
      { "tip", "N", 1, 0 } } )
    Use ( cur_dir() + "tmpk" ) new
    Index On Str( tip, 1 ) + Str( kod, 7 ) to ( cur_dir() + "tmpk" )
    dbCreate( cur_dir() + "tmp", { { "tip",  "N", 1, 0 }, ;
      { "kol_s", "N", 6, 0 }, ;
      { "kol_o", "N", 6, 0 }, ;
      { "kol_p", "N", 6, 0 } } )
    Use ( cur_dir() + "tmp" ) new
    Index On Str( tip, 1 ) to ( cur_dir() + "tmp" )
    r_use( dir_server() + "mo_rak",, "RAK" )
    r_use( dir_server() + "mo_raks",, "RAKS" )
    Set Relation To akt into RAK
    r_use( dir_server() + "mo_raksh",, "RAKSH" )
    Set Relation To kod_raks into RAKS
    Index On Str( kod_h, 7 ) + DToS( rak->dakt ) to ( cur_dir() + "tmpraksh" )
    r_use( dir_server() + "mo_rpd",, "RPD" )
    r_use( dir_server() + "mo_rpds",, "RPDS" )
    Set Relation To pd into RPD
    r_use( dir_server() + "mo_rpdsh",, "RPDSH" )
    Set Relation To kod_rpds into RPDS
    Index On Str( kod_h, 7 ) + DToS( rpd->d_pd ) to ( cur_dir() + "tmprpdsh" )
    r_use( dir_server() + "schet_",, "SCHET_" )
    r_use( dir_server() + "human_",, "HUMAN_" )
    r_use( dir_server() + "human", dir_server() + "humand", "HUMAN" )
    Set Relation To RecNo() into HUMAN_
    dbSeek( DToS( arr_m[ 5 ] ), .t. )
    Index On kod to ( cur_dir() + "tmp_h" ) ;
      For ishod > 100 .and. human_->oplata != 9 .and. schet > 0 ;
      While human->k_data <= arr_m[ 6 ] ;
      PROGRESS
    i := 0
    Go Top
    Do While !Eof()
      ++i
      @ MaxRow(), 1 Say lstr( i ) Color cColorWait
      ltip := 0
      Select SCHET_
      Goto ( human->schet )
      If !schet_->( Eof() ) .and. schet_->NREGISTR == 0 // только зарегистрированные
        If eq_any( human->ishod, 101, 102 )
          ltip := iif( Empty( human->za_smo ), 2, 1 )
        Elseif eq_any( human->ishod, 301, 302 )
          ltip := 3
        Elseif eq_any( human->ishod, 303, 304 )
          m1gruppa := human_->RSLT_NEW - 316
          If Between( m1gruppa, 1, 3 )
            ltip := 4
          Endif
        Elseif human->ishod == 305
          ltip := 5
        Elseif eq_any( human->ishod, 201, 202 )
          ltip := 6
        Elseif human->ishod == 203
          ltip := 7
        Endif
      Endif
      If ltip > 0
        Select TMPK
        find ( Str( ltip, 1 ) + Str( human->kod_k, 7 ) )
        If !Found()
          Append Blank
          tmpk->tip := ltip
          tmpk->kod := human->kod_k
          If LastRec() % 2000 == 0
            Commit
          Endif
        Endif
        Select TMP
        find ( Str( ltip, 1 ) )
        If !Found()
          Append Blank
          tmp->tip := ltip
        Endif
        tmp->kol_s++
        //
        k := 0
        Select RAKSH
        find ( Str( human->kod, 7 ) )
        Do While raksh->kod_h == human->kod .and. !Eof()
          If raksh->IS_REPEAT < 1
            k := iif( raksh->SUMP > 0, 1, 0 )
          Endif
          Skip
        Enddo
        If k == 1
          tmp->kol_o++
        Endif
        //
        k := 0
        Select RPDSH
        find ( Str( human->kod, 7 ) )
        Do While rpdsh->kod_h == human->kod .and. !Eof()
          k += rpdsh->S_SL
          Skip
        Enddo
        If k > 0
          tmp->kol_p++
        Endif
      Endif
      Select HUMAN
      Skip
    Enddo
    //
    fp := FCreate( n_file ) ; n_list := 1 ; tek_stroke := 0
    add_string( glob_mo[ _MO_SHORT_NAME ] )
    add_string( "" )
    add_string( Center( "Итоги по диспансеризации, профилактике и медосмотрам", sh ) )
    add_string( Center( "[ " + CharRem( "~", mas1pmt[ 3 ] ) + " ]", sh ) )
    add_string( Center( arr_m[ 4 ], sh ) )
    add_string( "" )
    add_string( "────────────────────────────────────────┬─────────┬─────────┬─────────┬─────────" )
    add_string( "                                        │ Кол-во  │ Кол-во  │ Кол-во  │ Кол-во  " )
    add_string( "                                        │ случаев │ человек │ случаев,│ случаев," )
    add_string( "                                        │         │         │ принятых│оплаченн." )
    add_string( "                                        │         │         │ к оплате│полностью" )
    add_string( "                                        │         │         │         │или част." )
    add_string( "────────────────────────────────────────┴─────────┴─────────┴─────────┴─────────" )
    For i := 1 To 7
      s :=    { "диспансеризация детей-сирот в стационаре", ;
        "диспансеризация детей-сирот под опекой", ;
        "профилактич.осмотры несовершеннолетних", ;
        "предварительн.осмотры несовершеннолетних", ;
        "периодические осмотры несовершеннолетних", ;
        "диспансеризация взрослого населения", ;
        "профилактика взрослого населения" }[ i ]
      Select TMP
      find ( Str( i, 1 ) )
      If Found()
        k := 0
        Select TMPK
        find ( Str( i, 1 ) )
        Do While tmpk->tip == i .and. !Eof()
          ++k
          Skip
        Enddo
        s := PadR( s, 40 ) + put_val( tmp->kol_s, 9 ) + ;
          put_val( k, 10 ) + ;
          put_val( tmp->kol_o, 10 ) + ;
          put_val( tmp->kol_p, 10 )
      Endif
      add_string( s )
      add_string( Replicate( "─", sh ) )
    Next
    Close databases
    FClose( fp )
    rest_box( buf )
    viewtext( n_file,,,, .f.,,, 2 )
  Endif

  Return Nil
