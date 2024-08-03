#include 'function.ch'
#include 'chip_mo.ch'

function test_init()

  // local aaa

  //aaa := getUsl_pcel()
  // use_base( 'reg_fns', 'reg_fns' )
  // use_base( 'link_fns', 'link_fns' )
  // use_base( 'xml_fns', 'xml_fns' )
  // use_base( 'xml_link_fns', 'xml_link' )
  // altd()
  // aaa := loadCriteria21(2023)
  return nil

// 12.07.24
function convert_P_CEL()

  static hPCEL

  if HB_ISNIL( hPCEL )
    hPCEL := hb_Hash( ;
      1 , '1.0', ;
      2 , '1.1', ;
      3 , '1.2', ;
      4 , '1.3', ;
      5 , '2.1', ;
      6 , '2.2', ;
      7 , '2.3', ;
      8 , '2.5', ;
      9 , '2.6', ;
      10 , '3.0', ;
      11 , '3.1', ;
      12 , '3.2', ;
      13 , '1.4', ;
      14 , '1.5', ;
      15 , '1.6', ;
      16 , '1.7', ;
      17 , '1.2' ;  // до 23 года
    )
  endif

  return hPCEL