#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 09.09.25
function glob_adres_podr()

  static arr_address

  if isnil( arr_address )
    arr_address := { ;
      { '103001', { ;
        { '103001', 1, 'г.Волгоград, ул.Землячки, д.78' }, ;
        { '103099', 2, 'г.Михайловка, ул.Мичурина, д.8' }, ;
        { '103099', 3, 'г.Волжский, ул.Комсомольская, д.25' }, ;
        { '103099', 4, 'г.Волжский, ул.Оломоуцкая, д.33' }, ;
        { '103099', 5, 'г.Камышин, ул.Днепровская, д.43' }, ;
        { '103099', 6, 'г.Камышин, ул.Мира, д.51' }, ;
        { '103099', 7, 'г.Урюпинск, ул.Фридек-Мистек, д.8' } ;
        };
      }, ;
      { '101003', ;
        { ;
          { '101003', 1, 'г.Волгоград, ул.Циолковского, д.1' }, ;
          { '101099', 2, 'г.Волгоград, ул.Советская, д.47' } ;
        };
      }, ;
      { '131001', ;
        { ;
          { '131001', 1, 'г.Волгоград, ул.Кирова, д.10' }, ;
          { '131099', 2, 'г.Волгоград, ул.Саши Чекалина, д.7' }, ;
          { '131099', 3, 'г.Волгоград, ул.им.Федотова, д.18' } ;
        };
      }, ;
      { '171004', ;
        { ;
          { '171004', 1, 'г.Волгоград, ул.Ополченская, д.40' }, ;
          { '171099', 2, 'г.Волгоград, ул.Тракторостроителей, д.13' } ;
        };
      };
    }
  endif
  return arr_address
  
// 09.09.25
function glob_arr_mo( reload )

  static arr_mo
  local dbName := '_mo_mo'

  if isnil( arr_mo )
    create_mo_add()
    arr_mo := getmo_mo( dbName )
  elseif ! isnil( reload ) .and. reload
    arr_mo := getmo_mo( dbName, reload )
  endif
  return arr_mo

// 09.09.25
function is_adres_podr( param )

  static lAddressPodr

  if isnil( lAddressPodr )
    lAddressPodr := .f.
  else
    lAddressPodr := param
  endif
  return lAddressPodr

// 09.09.25
function glob_mo( param )

  static mo

  if isnil( mo ) .and. ValType( param ) == 'A'
    mo := param
  endif
  return mo
