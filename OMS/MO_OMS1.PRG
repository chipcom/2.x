// mo_oms1.prg - режимы ввода данных для задачи ОМС (продолжение)
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

#define BASE_ISHOD_RZD 500  //

// 04.02.16 вернуть шифр услуги законченного случая для ПредН
Function ret_shifr_zs_predn( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( m1lis == 1, '72.3.5', '72.3.1' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ДОУ 1 этап'
  Case _period == 2
    lshifr := iif( m1lis == 1, '72.3.6', '72.3.2' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ООУ 1 этап'
  Case _period == 3
    lshifr := iif( m1lis == 1, '72.3.7', '72.3.3' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ОУ НПО, ВПО, СОУ, ОУ для детей-сирот от 0 до 14 лет 1 этап'
  Case _period == 4
    lshifr := iif( m1lis == 1, '72.3.8', '72.3.4' )// 'Законченный случай предварительного осмотра несовершеннолетних при поступлении в ОУ НПО, ВПО, СОУ, ОУ для детей-сирот с 15 лет 1 этап'
  Endcase

  Return lshifr

// 14.08.13
Function add_pediatr_predn( _pv, _pa, _date, _diag )

  Local arr[ 9 ]

  AFill( arr, 0 )

  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  arr[ 5 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), '2.86.15', '2.86.14' ) // шифр услуги
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 25.08.13 вернуть шифр услуги законченного случая для ПерН
Function ret_shifr_zs_pern( _period )

  Local lshifr := ''

  Do Case
  Case _period == 1
    lshifr := iif( m1lis == 1, '72.4.3', '72.4.1' ) // 'Законченный случай периодического осмотра несовершеннолетних, обучающихся в ДОУ
  Case _period == 2
    lshifr := iif( m1lis == 1, '72.4.4', '72.4.2' ) // 'Законченный случай периодического осмотра несовершеннолетних, обучающихся в ООУ, ОУ НПО, ВПО, СОУ, ОУ для детей-сирот
  Endcase

  Return lshifr

// 25.08.13
Function add_pediatr_pern( _pv, _pa, _date, _diag )

  Local arr[ 9 ]

  AFill( arr,  0 )
  Select P2
  find ( Str( _pv, 5 ) )
  If Found()
    arr[ 1 ] := p2->kod
    arr[ 2 ] := -ret_new_spec( p2->prvs, p2->prvs_new )
  Endif
  If !Empty( _pa )
    Select P2
    find ( Str( _pa, 5 ) )
    If Found()
      arr[ 3 ] := p2->kod
    Endif
  Endif
  arr[ 4 ] := iif( eq_any( arr[ 2 ], 1110, -16 ), 57, 68 ) // профиль
  // arr[5] := iif(eq_any(arr[2], 1110,-16), '2.3.2', '2.3.1') // шифр услуги
  arr[ 5 ] := '2.3.2' // шифр услуги
  If Empty( _diag ) .or. Left( _diag, 1 ) == 'Z'
    arr[ 6 ] := mdef_diagnoz
  Else
    arr[ 6 ] := _diag
    Select MKB_10
    find ( PadR( arr[ 6 ], 6 ) )
    If Found() .and. !Empty( mkb_10->pol ) .and. !( mkb_10->pol == mpol )
      func_error( 4, 'Несовместимость диагноза по полу ' + arr[ 6 ] )
    Endif
  Endif
  arr[ 9 ] := _date

  Return arr

// 04.01.25 вернуть тип вводимого листа учёта
Function ret_tip_lu( /*@*/stip)

  Local k := 0, tmp_select

  stip := '   '
  If Between( human->ishod, 101, 102 )
    k := iif( !Empty( human->ZA_SMO ), TIP_LU_DDS, TIP_LU_DDSOP )
    If human->ishod == 101
//      stip := iif( !Empty( human->ZA_SMO ), 'ДС1', 'ДУ1' )
      stip := iif( !Empty( human->ZA_SMO ), 'ДС1', 'ДС2' )   // письмо ТФОМС 09-20-674 от 19.12.24
    Else // 102
//      stip := iif( !Empty( human->ZA_SMO ), 'ДС2', 'ДУ2' )
      stip := iif( !Empty( human->ZA_SMO ), 'ДС3', 'ДС4' )   // письмо ТФОМС 09-20-674 от 19.12.24
    Endif
  Elseif Between( human->ishod, 201, 205 )
    k := TIP_LU_DVN
    If human->ishod == 201
      if human->k_data < 0d20250101
        stip := 'ДВ1'
      else
        stip := 'ДВ4'   // письмо ТФОМС 09-20-674 от 19.12.24
      endif
    Elseif eq_any( human->ishod, 202, 205 )
      stip := 'ДВ2'
    Elseif human->ishod == 204
      stip := 'ДВ3'
    Else // 203
      stip := 'ОПВ'
    Endif
  Elseif Between( human->ishod, 301, 302 )
    k := TIP_LU_PN
    If human->ishod == 301
//      stip := 'ОН1'
      stip := 'ПН1'   // письмо ТФОМС 09-20-674 от 19.12.24
    Else // 302
//      stip := 'ОН2'
      stip := 'ПН2'   // письмо ТФОМС 09-20-674 от 19.12.24
    Endif
  Elseif Between( human->ishod, 303, 304 )
    k := TIP_LU_PREDN
    If human->ishod == 303
      stip := 'ПО1'
    Else // 304
      stip := 'ПО2'
    Endif
  Elseif human->ishod == 305
    k := TIP_LU_PERN
    stip := 'ОПН'
  // Elseif Between( human->ishod, 401, 402 )  // при углубленной диспансеризации после COVID
  Elseif is_sluch_dispanser_COVID( human->ishod )  // при углубленной диспансеризации после COVID
    k := TIP_LU_DVN_COVID
    If human->ishod == 401
      stip := 'УД1'             // для 1-го этапа
    Else // 402
      stip := 'УД2'             // для 2-го этапа
    Endif
  // Elseif Between( human->ishod, BASE_ISHOD_RZD + 1, BASE_ISHOD_RZD + 2 )  // при диспансеризации репродуктивного здоровья
  Elseif is_sluch_dispanser_DRZ( human->ishod )  // при диспансеризации репродуктивного здоровья
    k := TIP_LU_DRZ
    If human->ishod == BASE_ISHOD_RZD + 1
      stip := 'ДР1'             // для 1-го этапа
    Else // 502
      stip := 'ДР2'             // для 2-го этапа
    Endif
  Elseif human->ishod == 98
    k := TIP_LU_G_CIT
  Elseif human->ishod == 99
    k := TIP_LU_PREND
  Endif

  If k == 0
    tmp_select := Select()
    r_use( dir_server() + 'mo_otd', , '__OTD' )
    __otd->( dbGoto( glob_otd[ 1 ] ) )
    k := __otd->TIPLU
    __otd->( dbCloseArea() )
    If tmp_select > 0
      Select( tmp_select )
    Endif
  Endif

  Return k

// 06.11.19 сравнение профилей с учётом изменения правил в 2014 году
Function f_profil_ginek_otolar( lp1, lp2 )

  Static arr_ginek := { 2, 136 } // акушерству и гинекологии
  Static arr_otolar := { 64, 162 } // отоларингологии
  Local i, fl := .f.

  If ValType( lp1 ) == 'N'
    lp1 := { lp1 }
  Endif
  For i := 1 To Len( lp1 )
    If lp1[ i ] == lp2
      fl := .t.
    Elseif AScan( arr_ginek, lp1[ i ] ) > 0
      fl := ( AScan( arr_ginek, lp2 ) > 0 )
    Elseif AScan( arr_otolar, lp1[ i ] ) > 0
      fl := ( AScan( arr_otolar, lp2 ) > 0 )
    Endif
    If fl
      Exit
    Endif
  Next i

  Return fl
