#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"
#include 'dbstruct.ch'

****** 21.03.22 - просмотр списка имплантантов
function view_implantant(arrImplantant, date_usl, fl_change)
  local tmp_keys
  local oBox, oBrowse, oColumn
  local nTop := 7, nLeft := 10, nBottom := 17, nRight := 70
  local cAlias := 'tmp_001'
  local oldSelect := select()
  local row, mtitle, l_color
  local mo_implant := {;  // имплантанты
    {'KOD_HUM',   'N',   7, 0},; // код листа учёта по файлу "human"
    {'KOD_K',     'N',   7, 0},; // код по картотеке
    {'MO_HU_K',   'N',   7, 0},; // recno() из файла mo_hu.dbf
    {'DATE_UST',  'D',   8, 0},; // дата установки импланта
    {'RZN',       'N',   6, 0},;  // Код вида медицинского изделия (номенклатурная классификация медицинских изделий справочника МинЗдрава (OID 1.2.643.5.1.13.13.11.1079))
    {'SER_NUM',   'C', 100, 0};  // Серийный номер
  }
  local fl_found
  local buf := savescreen()

  dbCreate( cur_dir + 'tmp_impl', mo_implant )
  G_Use( cur_dir + 'tmp_impl', , cAlias, , .t.)
  dbSelectArea(cAlias)
  for each row in arrImplantant
    (cAlias)->(dbAppend())
    (cAlias)->KOD_HUM := row[1]
    (cAlias)->KOD_K := row[2]
    if fl_change
      (cAlias)->DATE_UST := date_usl
    else
      (cAlias)->DATE_UST := row[3]
    endif
    (cAlias)->RZN := row[4]
    (cAlias)->SER_NUM := row[5]
    (cAlias)->MO_HU_K := row[6]
  next
  fl_found := ((cAlias)->(lastrec()) > 0)

  (cAlias)->(dbGoTop())
  if fl_found
    keyboard chr(K_RIGHT)
  else
    keyboard chr(K_INS)
  endif

	tmp_keys := my_savekey()
	save gets to tmp_gets

  l_color := "W+/B,W+/RB,BG+/B,BG+/RB,G+/B,GR+/B"

  mtitle := 'Установленные имплантанты'
  Alpha_Browse(nTop, nLeft, nBottom, nRight, 'f_view_implant', color1, mtitle, col_tit_popup, ;
               .f., .t., , 'f1_view_implant', 'f2_view_implant', , ;
               {"═", "│", "═", l_color, .t., 180} )

  (cAlias)->(dbCloseArea())
	restore gets from tmp_gets
	my_restkey( tmp_keys )
  select(oldSelect)
  restscreen(buf)
  return nil

***** 14.03.22
Function f_view_implant(oBrow)
  Local oColumn, blk_color
  blk_color := {|| {1, 2} }

  oColumn := TBColumnNew('Вид имплантанта',{|| padr(inieditspr(A__MENUVERT, get_implantant(), tmp_001->RZN), 31) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(' Серийный номер имплантанта',{|| padr(tmp_001->SER_NUM, 27) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление")
  return NIL

***** 13.03.22
Function f1_view_implant()
  return NIL

***** 14.03.22 
Function f2_view_implant(nKey, oBrow)
  local flag := -1, ret

  do case
    case nKey == K_INS .or. (nKey == K_ENTER)
      if nKey == K_ENTER
        ret := select_implantant(tmp_001->DATE_UST, tmp_001->RZN, tmp_001->SER_NUM)
      else
        ret := select_implantant(tmp->DATE_U1)
        if ret != nil
          tmp_001->(dbAppend())
        endif
      endif
      if lastkey() != K_ESC
        tmp_001->DATE_UST := ret[1]
        tmp_001->RZN := ret[2]
        tmp_001->SER_NUM := ret[3]
        tmp_001->KOD_HUM := tmp->KOD
        tmp_001->KOD_K := glob_kartotek
        tmp_001->MO_HU_K := tmp->rec_hu
        tmp_001->(dbGoTop())
      endif
      flag := 0
    case nKey == K_DEL .and. f_Esc_Enter(2)
      tmp_001->(dbDelete())
      tmp_001->(__dbPack())
      oBrow:goTop()
      tmp_001->(dbGoTop())
    otherwise
      keyboard ''
  endcase
  return flag
  
****** 17.03.22 - выбор импланта 
function select_implantant(date_ust, rzn, ser_num)
  local ret := NIL, oBox
  local buf, tmp_keys, iRow
  local sPicture
  local mNUMBER

  private mVIDIMPL := '', m1VIDIMPL := 0
  Private glob_Implantant := get_implantant()
  private tmp_Implantant := create_classif_FFOMS(2, 'Implantant')

  default rzn to 0
  default ser_num to space(100)

  m1VIDIMPL := rzn
  mNUMBER := padr(ser_num, 100)

  mVIDIMPL := padr(inieditspr(A__MENUVERT, get_implantant(), m1VIDIMPL), 44)

	buf := savescreen()
	change_attr()
	iRow := 11
	tmp_keys := my_savekey()
	save gets to tmp_gets

	oBox := TBox():New( iRow, 10, iRow + 5, 70, .t. )
	oBox:CaptionColor := 'B/B*'
	oBox:Color := cDataCGet
	oBox:MessageLine := '^<Esc>^ - выход;  ^<PgDn>^ - подтверждение ввода'
	oBox:Caption := 'Выберите имплантант'
	oBox:View()

	do while .t.
		iRow := 12

    @ ++iRow, 12 say 'Вид импланта:' get mVIDIMPL ;
          reader {|x| menu_reader(x, tmp_Implantant, A__MENUVERT, , , .f.)} ;
          valid {|| mVIDIMPL := padr(mVIDIMPL, 44), .t. }

    sPicture := '@S40'
		@ ++iRow, 12 say 'Серийный номер:' get mNUMBER picture sPicture ;
          valid {|| !empty(mNUMBER) }
	
		myread()
		if lastkey() != K_ESC .and. m1VIDIMPL != 0
      ret := {date_ust, m1VIDIMPL, alltrim(mNUMBER)}
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

****** 12.03.22 вернуть имплантант в листе учета
function exist_implantant_in_DB(mkod_human, rec_hu)
  local oldSelect := select()
  local arrImplantant, ser_num
  local cAlias := 'IMPL', impAlias
  local fl := .f.

  // default rec_hu to 0
  HB_Default(@rec_hu, 0)
  impAlias := select(cAlias)
  if impAlias == 0
    R_Use(dir_server + 'human_im', dir_server + 'human_im', cAlias)
  endif
  dbSelectArea(cAlias)
  if rec_hu == 0
    (cAlias)->(dbSeek(str(mkod_human, 7)))
  else
    (cAlias)->(dbSeek(str(mkod_human, 7) + str(rec_hu, 7)))
  endif
  if (cAlias)->(found())
    fl := .t.
  endif
  (cAlias)->(dbCloseArea())
  select(oldSelect)
  if impAlias == 0
    (cAlias)->(dbCloseArea())
  endif
  return fl

****** 18.03.22 вернуть имплантант в листе учета
function collect_implantant(mkod_human, rec_hu)
  local oldSelect := select()
  local ser_num, arrImplantant := {}
  local cAlias := 'IMPL', impAlias

  HB_Default(@rec_hu, 0)
  impAlias := select(cAlias)
  if impAlias == 0
    R_Use(dir_server + 'human_im', dir_server + 'human_im', cAlias)
  endif
  dbSelectArea(cAlias)
  if rec_hu == 0
    (cAlias)->(dbSeek(str(mkod_human, 7)))
  else
    (cAlias)->(dbSeek(str(mkod_human, 7) + str(rec_hu, 7)))
  endif
  if (cAlias)->(found())
    do while !(cAlias)->(EOF()) .and. mkod_human == (cAlias)->KOD_HUM
      if rec_hu != 0 .and. rec_hu != (cAlias)->MO_HU_K
        (cAlias)->(dbSkip())
        loop
      endif
      // найти серийный номер если есть
      ser_num := chek_implantant_ser_number((cAlias)->(recno()))
      // создать массив
      AAdd(arrImplantant, {(cAlias)->KOD_HUM, (cAlias)->KOD_K, (cAlias)->DATE_UST, (cAlias)->RZN, iif(ser_num != nil, ser_num, ''), (cAlias)->MO_HU_K})
      (cAlias)->(dbSkip())
    enddo
  endif
  (cAlias)->(dbCloseArea())
  select(oldSelect)
  if impAlias == 0
    (cAlias)->(dbCloseArea())
  endif
  return arrImplantant

****** 16.03.22 удалить имплантанты в листе учета
function delete_implantants(mkod_human, rec_hu)
  local oldSelect := select()
  local cAlias := 'IMPL'

  HB_Default(@rec_hu, 0)
  Use_base("human_im")
  // find (str(mkod_human, 7))
  dbSelectArea(cAlias)
  (cAlias)->(dbGoTop())
  do while !(cAlias)->(EOF())
    if mkod_human == (cAlias)->KOD_HUM
      if rec_hu == 0
        // вначале удалить серийный номер если есть
        delete_implantant_ser_number((cAlias)->(recno()))
        DeleteRec(.t.)  // очистка записи с пометкой на удаление
      else
        if (cAlias)->MO_HU_K == rec_hu
          // вначале удалить серийный номер если есть
          delete_implantant_ser_number((cAlias)->(recno()))
          DeleteRec(.t.)  // очистка записи с пометкой на удаление
        endif
      endif
    endif
    (cAlias)->(dbSkip())
  enddo
  (cAlias)->(dbCloseArea())
  select(oldSelect)
  return nil

****** 16.03.22 сохранить имплантант в БД учета
function save_implantants(mkod_human, rec_hu)
  local oldSelect := select()
  local cAlias := 'tmp_001'

  Use_base("human_im")

  R_Use( cur_dir + 'tmp_impl', , cAlias)
  dbSelectArea(cAlias)
  (cAlias)->(dbGoTop())
  do while ! (cAlias)->(EOF())
    dbSelectArea('IMPL')
    AddRec(7, , .t.)
    IMPL->KOD_HUM   := (cAlias)->KOD_HUM
    IMPL->KOD_K     := (cAlias)->KOD_K
    IMPL->DATE_UST  := (cAlias)->DATE_UST
    IMPL->RZN       := (cAlias)->RZN
    IMPL->MO_HU_K   := (cAlias)->MO_HU_K
    if ! empty((cAlias)->SER_NUM)
      // сохранить серийный номер если есть
      save_implantant_ser_number(IMPL->(recno()), (cAlias)->SER_NUM)
    endif
    dbSelectArea(cAlias)
    (cAlias)->(dbSkip())
  end do
  (cAlias)->(dbCloseArea())
  IMPL->(dbCloseArea())
  select(oldSelect)
  return nil

***** 01.02.22 вернуть массив услуга для имплантации
Function ret_impl_V036(s_code, lk_data)
  // s_code - код федеральной услуги
  // lk_data - дата оказания услуги
  Local i, retArr := nil
  local code := alltrim(s_code)

  if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code .and. (x[3] == 1 .or. x[3] == 3) })) > 0) // согласно ПУМП 04-18-03 от 31.01.2022
    retArr := getV036()[i]
  endif
  return retArr

***** 12.03.22 услуга требует имплантанты
Function service_requires_implants(s_code, lk_data)
  // s_code - код федеральной услуги
  // lk_data - дата оказания услуги
  Local i, fl := .f.
  local code := alltrim(s_code)

  if !empty(code) .and. ((i := ascan(getV036(), {|x| x[1] == code .and. (x[3] == 1 .or. x[3] == 3) })) > 0) // согласно ПУМП 04-18-03 от 31.01.2022
    fl := .t.
  endif
  return fl
