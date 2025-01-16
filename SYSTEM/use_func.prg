// различные функции общего пользования для работы с файлами БД - use_func.prg
#include 'inkey.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static exists_year_tfoms

// 21.11.23 - функция проверяющая наличие справочников ТФОМС на конкретный год.
Function check_files_tfoms( nYear )

  Local lRet := .f.

  If ISNIL( exists_year_tfoms ) // вспомогательно, если доэтого не использовался use_base('lusl')
    use_base( 'lusl' )
    close_use_base( 'lusl' )
  Endif

  If hb_HHasKey( exists_year_tfoms, nYear )
    lRet := exists_year_tfoms[ nYear ]
  Endif

  Return lRet

// 31.01.17
Function r_use_base( sBase, lAlias )
  Return use_base( sBase, lAlias, , .t. )

// 18.03.23 закрывает алиасы для lusl, luslc и luslf
Function close_use_base( sBase )

  Local countYear, lAlias

  sBase := Lower( sBase ) // проверим, что алиас открыт и выйдем если нет, пока lusl, luslc, luslf
  If ! SubStr( sBase, 1, 4 ) == 'lusl'
    Return Nil
  Endif
  If Select( sBase ) == 0
    Return Nil
  Endif

  For countYear := 2018 To WORK_YEAR
    lAlias := sBase + iif( countYear == WORK_YEAR, '', SubStr( Str( countYear, 4 ), 3 ) )
    If exists_file_tfoms( countYear, SubStr( sBase, 2 ) )
      If ( lAlias )->( Used() )
        ( lAlias )->( dbCloseArea() )
      Endif
    Endif
  Next

  Return Nil

// 14.10.24
Function existsnsifile( sbase, vYear )

  Local fl := .f., fName, findex, fIndex_add

  fName := prefixfilerefname( vYear ) + SubStr( sbase, 2 )
  If ( fl := hb_vfExists( dir_exe() + fName + sdbf ) )
    Do Case
    Case sBase == 'lusl'
      fIndex := cur_dir() + fName + sntx
      If ( fl := hb_vfExists( dir_exe() + fName + sdbf ) )
        If ! hb_vfExists( fIndex )
          r_use( dir_exe() + fName, , sBase )
          Index On shifr to ( fIndex )
          ( sBase )->( dbCloseArea() )
        Endif
      Endif
    Case sBase == 'luslc'
      fIndex := cur_dir() + fName + sntx
      fIndex_add :=  prefixfilerefname( vYear ) + 'uslu'  //
      If ( fl := hb_vfExists( dir_exe() + fName + sdbf ) )
        If ( ! hb_vfExists( fIndex ) ) .or. ( ! hb_vfExists( cur_dir() + fIndex_add + sntx ) )
          r_use( dir_exe() + fName, , sBase )
          Index On shifr + Str( vzros_reb, 1 ) + Str( depart, 3 ) + DToS( datebeg ) to ( findex ) ;
            For codemo == glob_mo[ _MO_KOD_TFOMS ]
          Index On codemo + shifr + Str( vzros_reb, 1 ) + Str( depart, 3 ) + DToS( datebeg ) to ( cur_dir() + fIndex_add ) ;
            For codemo == glob_mo[ _MO_KOD_TFOMS ] // для совместимости со старой версией справочника
          ( sBase )->( dbCloseArea() )
        Endif
      Endif
    Case sBase == 'luslf'
      fName := prefixfilerefname( vYear ) + 'uslf'
      fIndex := cur_dir() + fName + sntx
      If ( fl := hb_vfExists( dir_exe() + fName + sdbf ) )
        If ! hb_vfExists( fIndex )
          r_use( dir_exe() + fName, , sBase )
          Index On shifr to ( cur_dir() + fName )
          ( sBase )->( dbCloseArea() )
        Endif
      Endif
    Endcase
  Endif

  Return fl

// 14.01.25
Function use_base( sBase, lAlias, lExcluUse, lREADONLY )

  Local fl := .t., sind1 := '', sind2 := ''
  Local fname, fname_add
  Local countYear
  Local lExistHash

  sBase := Lower( sBase )
  Do Case
  Case sBase == 'lusl'
    If ( lExistHash := ISNIL( exists_year_tfoms ) )
      exists_year_tfoms := hb_Hash()
    Endif
    For countYear := 2018 To WORK_YEAR
      If exists_file_tfoms( countYear, 'usl' )
        hb_HSet( exists_year_tfoms, countYear, .t. )
        fName := prefixfilerefname( countYear ) + SubStr( sbase, 2 )
        lAlias := create_name_alias( sBase, countYear )
        If ! ( lAlias )->( Used() )
          sind1 := cur_dir() + fName + sntx
          If ! hb_vfExists( sind1 )
            r_use( dir_exe() + fName, , lAlias )
            Index On shifr to ( sind1 )
          Else
            r_use( dir_exe() + fName, sind1, lAlias )
          Endif
        Endif
      Else
        hb_HSet( exists_year_tfoms, countYear, .f. )
      Endif
    Next
  Case sBase == 'luslc'
    For countYear := 2018 To WORK_YEAR
      If exists_file_tfoms( countYear, 'uslc' )
        fName := prefixfilerefname( countYear ) + SubStr( sbase, 2 )
        fname_add := prefixfilerefname( countYear ) + SubStr( sbase, 2, 3 ) + 'u'
        lAlias := sBase + iif( countYear == WORK_YEAR, '', SubStr( Str( countYear, 4 ), 3 ) )
        If ! ( lAlias )->( Used() )
          sind1 := cur_dir() + fName + sntx
          sind2 := cur_dir() + fname_add + sntx
          If ! ( hb_vfExists( sind1 ) .or. hb_vfExists( sind2 ) )
            r_use( dir_exe() + fName, , lAlias )
            Index On shifr + Str( vzros_reb, 1 ) + Str( depart, 3 ) + DToS( datebeg ) to ( sind1 ) ;
              For codemo == glob_mo[ _MO_KOD_TFOMS ]
            Index On codemo + shifr + Str( vzros_reb, 1 ) + Str( depart, 3 ) + DToS( datebeg ) to ( sind2 ) ;
              For codemo == glob_mo[ _MO_KOD_TFOMS ] // для совместимости со старой версией справочника
          Else
            r_use( dir_exe() + fName, { cur_dir() + fName, cur_dir() + fName_add }, lAlias )
          Endif
        Endif
      Endif
    Next
  Case sBase == 'luslf'
    For countYear := 2018 To WORK_YEAR
      If exists_file_tfoms( countYear, 'uslf' )
        fName := prefixfilerefname( countYear ) + SubStr( sbase, 2 )
        lAlias := sBase + iif( countYear == WORK_YEAR, '', SubStr( Str( countYear, 4 ), 3 ) )
        If ! ( lAlias )->( Used() )
          sind1 := cur_dir() + fName + sntx
          If ! hb_vfExists( sind1 )
            r_use( dir_exe() + fName, , lAlias )
            Index On shifr to ( sind1 )
          Else
            r_use( dir_exe() + fName, cur_dir() + fName, lAlias )
          Endif
        Endif
      Endif
    Next
  Case sBase == 'organiz'
    Default lAlias To 'ORG'
    fl := g_use( dir_server + 'organiz', , lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'komitet'
    If ( fl := g_use( dir_server + 'komitet', , lAlias, , lExcluUse, lREADONLY ) )
      Index On Str( kod, 2 ) to ( cur_dir() + 'tmp_komi' )
    Endif
  Case sBase == 'str_komp'
    If ( fl := g_use( dir_server + 'str_komp', , lAlias, , lExcluUse, lREADONLY ) )
      Index On Str( kod, 2 ) to ( cur_dir() + 'tmp_strk' )
    Endif
  Case sBase == 'mo_pers'
    Default lAlias To 'P2'
    fl := g_use( dir_server + 'mo_pers', dir_server + 'mo_pers', lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'mo_su'
    Default lAlias To 'MOSU'
    fl := g_use( dir_server + 'mo_su', { dir_server + 'mo_su', ;
      dir_server + 'mo_sush', ;
      dir_server + 'mo_sush1' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'uslugi'
    Default lAlias To 'USL'
    fl := g_use( dir_server + 'uslugi', { dir_server + 'uslugi', ;
      dir_server + 'uslugish', ;
      dir_server + 'uslugis1', ;
      dir_server + 'uslugisl' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'kartotek'
    fl := g_use( dir_server + 'kartote_', , 'KART_', , lExcluUse, lREADONLY ) .and. ;
      g_use( dir_server + 'kartote2', , 'KART2', , lExcluUse, lREADONLY ) .and. ;
      g_use( dir_server + 'kartotek', { dir_server + 'kartotek', ;
      dir_server + 'kartoten', ;
      dir_server + 'kartotep', ;
      dir_server + 'kartoteu', ;
      dir_server + 'kartotes', ;
      dir_server + 'kartotee' }, 'KART', , lExcluUse, lREADONLY )
    If fl
      Set Relation To RecNo() into KART_, To RecNo() into KART2
    Endif
  Case sBase == 'human'
    Default lAlias To 'HUMAN'
    fl := g_use( dir_server + 'human_', , 'HUMAN_', , lExcluUse, lREADONLY ) .and. ;
      g_use( dir_server + 'human_2', , 'HUMAN_2', , lExcluUse, lREADONLY ) .and. ;
      g_use( dir_server + 'human', { dir_server + 'humank', ;
      dir_server + 'humankk', ;
      dir_server + 'humann', ;
      dir_server + 'humand', ;
      dir_server + 'humano', ;
      dir_server + 'humans' }, lAlias, , lExcluUse, lREADONLY )
    If fl
      Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2
    Endif
  Case sBase == 'human_im'
    Default lAlias To 'IMPL'
    fl := g_use( dir_server + 'human_im', dir_server + 'human_im', lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'human_u'
    Default lAlias To 'HU'
    fl := g_use( dir_server + 'human_u_', , 'HU_', , lExcluUse, lREADONLY ) .and. ;
      g_use( dir_server + 'human_u', { dir_server + 'human_u', ;
      dir_server + 'human_uk', ;
      dir_server + 'human_ud', ;
      dir_server + 'human_uv', ;
      dir_server + 'human_ua' }, lAlias, , lExcluUse, lREADONLY )
    If fl
      Set Relation To RecNo() into HU_
    Endif
  Case sBase == 'mo_hu'
    Default lAlias To 'MOHU'
    fl := g_use( dir_server + 'mo_hu', { dir_server + 'mo_hu', ;
      dir_server + 'mo_huk', ;
      dir_server + 'mo_hud', ;
      dir_server + 'mo_huv', ;
      dir_server + 'mo_hua' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'mo_dnab'
    Default lAlias To 'DN'
    fl := g_use( dir_server + 'mo_dnab', dir_server + 'mo_dnab', lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'mo_hdisp'
    Default lAlias To 'HDISP'
    fl := g_use( dir_server + 'mo_hdisp', dir_server + 'mo_hdisp', lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'schet'
    Default lAlias To 'SCHET'
    fl := g_use( dir_server + 'schet_', , 'SCHET_', , lExcluUse, lREADONLY ) .and. ;
      g_use( dir_server + 'schet', { dir_server + 'schetk', ;
      dir_server + 'schetn', ;
      dir_server + 'schetp', ;
      dir_server + 'schetd' }, lAlias, , lExcluUse, lREADONLY )
    If fl
      Set Relation To RecNo() into SCHET_
    Endif
  Case sBase == 'kartdelz'
    fl := g_use( dir_server + 'kartdelz', dir_server + 'kartdelz', ,, lExcluUse, lREADONLY )
  Case sBase == 'kart_st'
    fl := g_use( dir_server + 'kart_st', { dir_server + 'kart_st', ;
      dir_server + 'kart_st1' }, ,, lExcluUse, lREADONLY )
  Case sBase == 'humanst'
    fl := g_use( dir_server + 'humanst', dir_server + 'humanst', ,, lExcluUse, lREADONLY )
  Case sBase == 'mo_pp'
    Default lAlias To 'HU'
    fl := g_use( dir_server + 'mo_pp', { dir_server + 'mo_pp_k', ;
      dir_server + 'mo_pp_d', ;
      dir_server + 'mo_pp_r', ;
      dir_server + 'mo_pp_i', ;
      dir_server + 'mo_pp_h' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'hum_p'
    Default lAlias To 'HU'
    fl := g_use( dir_server + 'hum_p', { dir_server + 'hum_pkk', ;
      dir_server + 'hum_pn', ;
      dir_server + 'hum_pd', ;
      dir_server + 'hum_pv', ;
      dir_server + 'hum_pc' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'hum_p_u'
    Default lAlias To 'HU'
    fl := g_use( dir_server + 'hum_p_u', { dir_server + 'hum_p_u', ;
      dir_server + 'hum_p_uk', ;
      dir_server + 'hum_p_ud', ;
      dir_server + 'hum_p_uv', ;
      dir_server + 'hum_p_ua' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'hum_ort'
    fl := g_use( dir_server + 'hum_ort', { dir_server + 'hum_ortk', ;
      dir_server + 'hum_ortn', ;
      dir_server + 'hum_ortd', ;
      dir_server + 'hum_orto' }, 'HUMAN', , lExcluUse, lREADONLY )
  Case sBase == 'hum_oru'
    fl := g_use( dir_server + 'hum_oru', { dir_server + 'hum_oru', ;
      dir_server + 'hum_oruk', ;
      dir_server + 'hum_orud', ;
      dir_server + 'hum_oruv', ;
      dir_server + 'hum_orua' }, 'HU', , lExcluUse, lREADONLY )
  Case sBase == 'hum_oro'
    fl := g_use( dir_server + 'hum_oro', { dir_server + 'hum_oro', ;
      dir_server + 'hum_orov', ;
      dir_server + 'hum_orod' }, 'HO', , lExcluUse, lREADONLY )
  Case sBase == 'kas_pl'
    fl := g_use( dir_server + 'kas_pl', { dir_server + 'kas_pl1', ;
      dir_server + 'kas_pl2', ;
      dir_server + 'kas_pl3' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'kas_pl_u'
    fl := g_use( dir_server + 'kas_pl_u', { dir_server + 'kas_pl1u', ;
      dir_server + 'kas_pl2u' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'kas_ort'
    fl := g_use( dir_server + 'kas_ort', { dir_server + 'kas_ort1', ;
      dir_server + 'kas_ort2', ;
      dir_server + 'kas_ort3', ;
      dir_server + 'kas_ort4', ;
      dir_server + 'kas_ort5' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'kas_ortu'
    fl := g_use( dir_server + 'kas_ortu', { dir_server + 'kas_or1u', ;
      dir_server + 'kas_or2u' }, lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'reg_fns'
    fl := g_use( dir_server + 'register_fns', { dir_server + 'reg_fns' }, ;
      lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'link_fns'
    fl := g_use( dir_server + 'reg_link_fns', { dir_server + 'reg_link' }, ;
      lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'xml_fns'
    fl := g_use( dir_server + 'reg_xml_fns', { dir_server + 'reg_xml' }, ;
      lAlias, , lExcluUse, lREADONLY )
//  Case sBase == 'payer'
//    fl := g_use( dir_server + 'payer', { dir_server + 'payer' }, ;
//      lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'reg_people_fns'
    fl := g_use( dir_server + 'reg_people_fns', { dir_server + 'reg_people_fns', dir_server + 'reg_people_fns_fio' }, ;
      lAlias, , lExcluUse, lREADONLY )
  // Case sBase == 'mo_kekh'
  //   Default lAlias To 'HU'
  //   fl := g_use( dir_server + 'mo_kekh', dir_server + 'mo_kekh', lAlias, , lExcluUse, lREADONLY )
  // Case sBase == 'mo_keke'
  //   Default lAlias To 'EKS'
  //   fl := g_use( dir_server + 'mo_keke', { dir_server + 'mo_keket', ;
  //     dir_server + 'mo_kekee', ;
  //     dir_server + 'mo_keked' }, lAlias, , lExcluUse, lREADONLY )
  // Case sBase == 'mo_kekez'
  //   Default lAlias To 'EKSZ'
  //   fl := g_use( dir_server + 'mo_kekez', dir_server + 'mo_kekez', lAlias, , lExcluUse, lREADONLY )
  Case sBase == 'lusld'
    fl := r_use( dir_exe() + '_mo_usld', cur_dir() + '_mo_usld', sBase )
  Endcase

  Return fl

// *
Function useuch_usl()

  Return g_use( dir_server + 'uch_usl', dir_server + 'uch_usl', 'UU' ) .and. ;
    g_use( dir_server + 'uch_usl1', dir_server + 'uch_usl1', 'UU1' )


// 21.01.19 проверить, заблокирована ли запись, и, если нет, то заблокировать её
Function my_rec_lock( n )

  If AScan( dbRLockList(), n ) == 0
    g_rlock( forever )
  Endif

  Return Nil

// вернуть в массиве запись базы данных
Function get_field()

  Local arr := Array( FCount() )

  AEval( arr, {| x, i| arr[ i ] := FieldGet( i ) }  )

  Return arr


// 04.04.18 блокировать запись, где поле KOD == 0 (иначе добавить запись)
Function add1rec( n, lExcluUse )

  Local fl := .t., lOldDeleted := Set( _SET_DELETED, .f. )

  Default lExcluUse To .f.
  find ( Str( 0, n ) )
  If Found()
    Do While kod == 0 .and. !Eof()
      If iif( lExcluUse, .t., RLock() )
        If Deleted()
          Recall
        Endif
        fl := .f.
        Exit
      Endif
      Skip
    Enddo
  Endif
  If fl  // добавление записи
    If lExcluUse
      Append Blank
    Else
      Do While .t.
        Append Blank
        If !NetErr()
          Exit
        Endif
      Enddo
    Endif
  Endif
  Set( _SET_DELETED, lOldDeleted )  // Восстановление среды

  Return Nil

// 11.04.18 выравнивание вторичного файла базы данных до первичного
Function dbf_equalization( lAlias, lkod )

  Local fl := .t.

  dbSelectArea( lAlias )
  Do While LastRec() < lkod
    Do While .t.
      Append Blank
      fl := .f.
      If !NetErr()
        Exit
      Endif
    Enddo
  Enddo
  If fl  // т.е. нужная запись не заблокирована при добавлении
    Goto ( lkod )
    g_rlock( forever )
  Endif

  Return Nil

// открытие файла базы данных в сети ТОЛЬКО ДЛЯ ЧТЕНИЯ
Function r_use_1( cFile, cIndices, cAlias, lTryForever, lExcluUse )
  Return g_use( cFile, cIndices, cAlias, lTryForever, lExcluUse, .t. )

// монопольное открытие файла базы данных
Function e_use( cFile, cIndices, cAlias )
  Return g_use( cFile, cIndices, cAlias, , .t. )

// открытие файла базы данных в сети
Function g_use( cFile, cIndices, cAlias, lTryForever, lExcluUse, lREADONLY )

  // cFile - файл БД
  // cIndices - список индексов (или строка в случае одного индекса)
  // cAlias - строка алиаса
  // lTryForever - логическая величина (.T. - пытаться бесконечно)
  // lExcluUse - логическая величина (.T. - монопольное открытие БД)
  // lREADONLY - логическая величина (.T. - открытие БД только для чтения)
  Local cMessage, lRetValue, UpcFile, c1Array := { 'Попытаться снова' }, cArray

  If '.DBF' == Upper( Right( cFile, 4 ) )
    cFile := SubStr( cFile, 1, Len( cFile ) - 4 )
  Endif
  UpcFile := strippath( cFile )
  // чтобы все файлы в данном модуле открывались только для чтения,
  // определите PRIVATE-перемменную "PRIVATE use_readonly := .T."
  If lREADONLY == Nil .and. Type( 'use_readonly' ) == 'L' .and. use_readonly
    lREADONLY := .t.
  Endif

  Default cIndices TO {}, cAlias To UpcFile, lTryForever To .f., ;
    lExcluUse To .f., lREADONLY To .f.
  
  If !File( cFile + '.DBF' ) // проверка на наличие файла
    cMessage := 'ОШИБКА: Файл ' + UpcFile + ' не существует!'
    cMessage += ';Операция прекращена'
    Alert( cMessage, { 'Завершить' }, color0 )
    lRetValue := .f.
  Else
    // Попытки открытия базы данных до успеха или отказа
    Do While lRetValue == NIL
      dbUseArea( .t., ;          // new
        , ;            // rdd
        cFile, ;       // db
        cAlias, ;      // alias
        !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
        lREADONLY, ;   // readonly
        'RU866' )
      If !NetErr()
        If Empty( cIndices )  // нет индексов при вызове ф-ии
          lRetValue := .t.
          dbClearIndex()  // все равно закрыть - для FOXPRO
        Elseif !( lRetValue := g_index( cIndices ) )
          Use  // закрыть БД при отсутствии индекса(ов)
        Endif
      Else
        If !lTryForever
          cMessage := 'Невозможно открыть файл ' + UpcFile
          cMessage += ';Он занят другим пользователем'
          cArray := AClone( c1Array )
          AAdd( cArray, 'Завершить' )
          If Alert( cMessage, cArray, color0 ) != 1
            lRetValue := .f.
          Endif
        Endif
      Endif
    Enddo
  Endif

  Return ( lRetValue )

// 18.01.24 открытие файла базы данных в сети
Function r_use( cFile, cIndices, cAlias, lTryForever, lExcluUse )

  // cFile - файл БД
  // cIndices - список индексов (или строка в случае одного индекса)
  // cAlias - строка алиаса
  // lTryForever - логическая величина (.T. - пытаться бесконечно)
  // lExcluUse - логическая величина (.T. - монопольное открытие БД)
  Local cMessage, lRetValue, UpcFile, c1Array := { 'Попытаться снова' }, cArray

  If '.DBF' == Upper( Right( cFile, 4 ) )
    cFile := SubStr( cFile, 1, Len( cFile ) - 4 )
  Endif
  UpcFile := strippath( cFile )

  Default cIndices TO {}, cAlias To UpcFile, lTryForever To .f., ;
    lExcluUse To .f.
  
  If !File( cFile + '.DBF' ) // проверка на наличие файла
    cMessage := 'ОШИБКА: Файл ' + UpcFile + ' не существует!'
    cMessage += ';Операция прекращена'
    Alert( cMessage, { 'Завершить' }, color0 )
    lRetValue := .f.
  Else
    // Попытки открытия базы данных до успеха или отказа
    Do While lRetValue == NIL
      dbUseArea( .t., ;          // new
        , ;            // rdd
        cFile, ;       // db
        cAlias, ;      // alias
        !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
        .t., ;   // readonly
        'RU866' )
      If !NetErr()
        If Empty( cIndices )  // нет индексов при вызове ф-ии
          lRetValue := .t.
          dbClearIndex()  // все равно закрыть - для FOXPRO
        Elseif !( lRetValue := g_index( cIndices ) )
          Use  // закрыть БД при отсутствии индекса(ов)
        Endif
      Else
        If !lTryForever
          cMessage := 'Невозможно открыть файл ' + UpcFile
          cMessage += ';Он занят другим пользователем'
          cArray := AClone( c1Array )
          AAdd( cArray, 'Завершить' )
          If Alert( cMessage, cArray, color0 ) != 1
            lRetValue := .f.
          Endif
        Endif
      Endif
    Enddo
  Endif

  Return ( lRetValue )
