#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

function input_polis_OMS(cur_row, mkod)

  // переменные mvidpolis, m1vidpolis, mspolis, mnpolis объявлены ранее как PRIVATE
  default mkod to 0
  @ cur_row, 1 say 'Полис ОМС: вид' get mvidpolis ;
    reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)}
  @ row(), col() + 3 say 'серия' get mspolis when m1vidpolis == 1
  @ row(), col() + 3 say 'номер' get mnpolis ;
    picture iif(m1vidpolis == 3 .or. m1vidpolis == 1, '9999999999999999', '999999999');
    valid {|| findKartoteka(2, @mkod) ,func_valid_polis(m1vidpolis, mspolis, mnpolis)}

  return nil
