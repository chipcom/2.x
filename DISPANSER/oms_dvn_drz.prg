#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 27.03.24 диспнсеризация репродуктивного здоровья взрослого населения - добавление или редактирование случая (листа учета)
function oms_sluch_dvn_drz( Loc_kod, kod_kartotek )

  hb_Alert( 'Репродуктивное здоровье' )
  return nil