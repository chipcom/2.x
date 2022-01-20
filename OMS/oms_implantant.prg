#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

****** 20.01.22 - выбор импланта
function select_impl(date_ust, rzn, ser_num)
  local ret := NIL, oBox
  local buf, tmp_keys, iRow
  local sPicture

  private mVIDIMPL := 0, m1VIDIMPL := 0  //iif(nKey == K_INS, human_->profil, tmp->profil)
  private mDATE_INST, mNUMBER

  default date_ust to sys_date
  default rzn to 0
  default ser_num to space(100)

  mDATE_INST := date_ust
  m1VIDIMPL := rzn
  mNUMBER := ser_num

  mVIDIMPL := padr(inieditspr(A__MENUVERT, get_implant(), m1VIDIMPL), 69)

	buf := savescreen()
	change_attr()
	iRow := 10
	tmp_keys := my_savekey()
	save gets to tmp_gets

	oBox := TBox():New( iRow, 10, iRow + 5, 70, .t. )
	oBox:CaptionColor := 'B/B*'
	oBox:Color := cDataCGet
	oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
	oBox:Caption := 'Выберите имплантант'
	oBox:View()

	do while .t.
		iRow := 11

    @ ++iRow, 12 say "Дата установки" get mDATE_INST

		@ ++iRow, 12 say 'Вид импланта:' get mVIDIMPL ;
          reader {|x| menu_reader(x,get_implant(), A__MENUVERT, , , .f.)} ;
          valid {|| mVIDIMPL := padr(mVIDIMPL, 69), .t. }

    sPicture := '@S40'
		@ ++iRow, 12 say 'Серийный номер:' get mNUMBER picture sPicture //;
	
		myread()
		if lastkey() != K_ESC .and. m1VIDIMPL != 0
      ret := {mDATE_INST, m1VIDIMPL, mNUMBER}
			exit
		else
			exit
		endif
	enddo
	update_gets()

	oBox := nil
	restscreen( buf )
	restore gets from tmp_gets
	my_restkey( tmp_keys )
  return ret

****** 20.01.22 вернуть имплантант в листе учета
function check_implantant(mkod_human)
  local tmpSelect := select()
  local arrImplantant

  Use_base("human_im")
  find (str(mkod_human, 7))
  if IMPL->(found())
    arrImplantant := {IMPL->KOD_HUM, IMPL->DATE_UST, IMPL->RZN, ''}  //, IMPL->SER_NUM}
  endif
  IMPL->(dbCloseArea())
  select(tmpSelect)
  return arrImplantant

****** 20.01.22 вернуть имплантант в листе учета
function delete_implantant(mkod_human)
  local tmpSelect := select()

  Use_base("human_im")
  find (str(mkod_human, 7))
  if IMPL->(found())
    DeleteRec(.t.,.t.)  // очистка записи без пометки на удаление
  endif
  IMPL->(dbCloseArea())
  select(tmpSelect)
  return nil
