#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 29.12.24
function baseRate( dt, type_USL_OK )
  static aRate
  local ret := 1, row

  if isnil( aRate )
    // временно
    // на 2025 базовая ставка стационарного случая 28003,9 руб
    // на 2025 базовая ставка для случая дневного стационара 16026 руб
    // временно

    // на 2024 базовая ставка стационарного случая 28003,9 руб
    // на 2024 базовая ставка для случая дневного стационара 16026 руб
    // на 2023 после 01.10.2023 базовая ставка стационарного случая 29995.8 руб
    // на 2023 до 01.10.2023 базовая ставка стационарного случая 25986,7 руб
    // на 2023 базовая ставка для случая дневного стационара 15029,1 руб 
    // на 2022 базовая ставка стационарного случая 24322,6 руб
    // на 2022 базовая ставка для случая дневного стационара 13915,7 руб

    // вид условия оказани, базовая ставка, дата начала, дата окончания
    aRate := { ;
      { USL_OK_HOSPITAL, 28003.9, ctod( '01/01/2025' ), ctod( '31/12/2025' ) }, ; // временно 2025
      { USL_OK_DAY_HOSPITAL, 16026, ctod( '01/01/2025' ), ctod( '31/12/2025' ) }, ; // временно 2025
      { USL_OK_HOSPITAL, 28003.9, ctod( '01/01/2024' ), ctod( '31/12/2024' ) }, ; // КС 2024 с 01.01.24
      { USL_OK_DAY_HOSPITAL, 16026, ctod( '01/01/2024' ), ctod( '31/12/2024' ) }, ; // ДС 2024 с 01.01.24
      { USL_OK_HOSPITAL, 29995.8, ctod( '01/10/2023' ), ctod( '31/12/2023' ) }, ; // КС 2023 с 01.10.23
      { USL_OK_HOSPITAL, 25986.7, ctod( '01/01/2023' ), ctod( '30/09/2023' ) }, ; // КС 2023 до 01.10.23
      { USL_OK_DAY_HOSPITAL, 15029.1, ctod( '01/01/2023' ), ctod( '31/12/2023' ) }, ; // ДС 2023
      { USL_OK_HOSPITAL, 24322.6, ctod( '01/01/2022' ), ctod( '31/12/2022' ) }, ; // КС 2022
      { USL_OK_DAY_HOSPITAL, 13915.7, ctod( '01/01/2022' ), ctod( '31/12/2022' ) } ; // ДС 2022
    } 
  endif
  for each row in aRate
    if row[ 1 ] == type_USL_OK .and. between_date( row[ 3 ], row[ 4 ], dt )
      ret := row[ 2 ]
    endif
  next
  return ret

// 28.12.24
function code_services_VMP( nYear )
  static arrVMP

  if isnil( arrVMP )
    arrVMP := hb_Hash()
    hb_HSet( arrVMP, 2025, '1.23.' )  // временно
    hb_HSet( arrVMP, 2024, '1.23.' )
    hb_HSet( arrVMP, 2023, '1.22.' )
    hb_HSet( arrVMP, 2022, '1.21.' )
    hb_HSet( arrVMP, 2021, '1.20.' )
    hb_HSet( arrVMP, 2020, '1.12.' )
    hb_HSet( arrVMP, 2019, '1.12.' )
    hb_HSet( arrVMP, 2018, '1.12.' )
  endif
  return iif( nYear < 2018, '', arrVMP[ nYear ])

// 13.03.23
function isServiceVMP( lshifr )
  local ret := .f.

  return ret