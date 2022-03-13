#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"
#include 'dbstruct.ch'

****** 13.03.22 - просмотр списка имплантантов
function view_implantant(arrImplantant)
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
  G_Use( cur_dir + 'tmp_impl', , cAlias)
  dbSelectArea(cAlias)
  for each row in arrImplantant
    (cAlias)->(dbAppend())
    (cAlias)->KOD_HUM := row[1]
    (cAlias)->KOD_K := row[2]
    (cAlias)->DATE_UST := row[3]
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

***** 13.02.22
Function f_view_implant(oBrow)
  Local oColumn, blk_color
  blk_color := {|| {1, 2} }

  oColumn := TBColumnNew('Вид имплантанта',{|| padr(inieditspr(A__MENUVERT, get_implantant(), tmp_001->RZN), 31) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(' Серийный номер имплантанта',{|| padr(tmp_001->SER_NUM, 27) })
  oColumn:colorBlock := blk_color
  oBrow:addColumn(oColumn)
  status_key("^<Esc>^ выход; ^<Enter>^ ред-ие; ^<Ins>^ добавление; ^<Del>^ удаление; ^<F1>^ помощь")
  return NIL

***** 13.03.22
Function f1_view_implant()
  // LOCAL nRow := ROW(), nCol := COL(), s := tmp->name_u, lcolor := cDataCSay

  // if is_zf_stomat == 1 .and. !empty(tmp->zf)
  //   s := alltrim(tmp->zf) + " / " + s
  //   lcolor := color8
  // endif
  // @ maxrow()-2,2 say padr(s, 65) color lcolor
  // if empty(tmp->u_cena)
  //   s := iif(tmp->n_base==0, "", "ФФОМС")
  // else
  //   s := alltrim(dellastnul(tmp->u_cena, 10, 2))
  // endif
  // @ maxrow() - 2, 68 say padc(s, 11) color cDataCSay
  // f3oms_usl_sluch()
  // @ nRow, nCol SAY ""
  return NIL

***** 13.02.22 
Function f2_view_implant(nKey, oBrow)
  local flag := -1, ret

  do case
    case nKey == K_F10 .and. f_Esc_Enter("запоминания услуг")
      flag := 0
    case eq_any(nKey,K_CTRL_F10,K_F11)
    case eq_any(nKey,K_F4,K_F5,K_CTRL_F5)
    case nKey == K_INS .or. (nKey == K_ENTER)
      if nKey == K_ENTER
        ret := select_implantant(tmp_001->DATE_UST, tmp_001->RZN, tmp_001->SER_NUM)
      else
        ret := select_implantant()
        if ret != nil
          tmp_001->(dbAppend())
        endif
      endif
      tmp_001->DATE_UST := ret[1]
      tmp_001->RZN := ret[2]
      tmp_001->SER_NUM := ret[3]
      tmp_001->(dbGoTop())
      flag := 0
    case nKey == K_DEL .and. f_Esc_Enter(2)
    otherwise
      keyboard ''
  endcase
  return flag
  
****** 21.01.22 - выбор импланта 
function select_implantant(date_ust, rzn, ser_num)
  local ret := NIL, oBox
  local buf, tmp_keys, iRow
  local sPicture
  local mDATE_INST, mNUMBER

  private mVIDIMPL := '', m1VIDIMPL := 0
  Private glob_Implantant := get_implantant()
  private tmp_Implantant := create_classif_FFOMS(2,"Implantant")

  default date_ust to sys_date
  default rzn to 0
  default ser_num to space(100)

  mDATE_INST := date_ust
  m1VIDIMPL := rzn
  mNUMBER := padr(ser_num, 100)

  mVIDIMPL := padr(inieditspr(A__MENUVERT, get_implantant(), m1VIDIMPL), 44)

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

    @ ++iRow, 12 say "Дата установки" get mDATE_INST ;
          valid {|g| fDateImplant(g) }
    
    @ ++iRow, 12 say 'Вид импланта:' get mVIDIMPL ;
          reader {|x| menu_reader(x, tmp_Implantant, A__MENUVERT, , , .f.)} ;
          valid {|| mVIDIMPL := padr(mVIDIMPL, 44), .t. }

    sPicture := '@S40'
		@ ++iRow, 12 say 'Серийный номер:' get mNUMBER picture sPicture ;
          valid {|| !empty(mNUMBER) }
	
		myread()
		if lastkey() != K_ESC .and. m1VIDIMPL != 0
      ret := {mDATE_INST, m1VIDIMPL, alltrim(mNUMBER)}
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

****** 12.03.22 вернуть имплантант в листе учета
function collect_implantant(mkod_human, rec_hu)
  local oldSelect := select()
  local ser_num, arrImplantant := {}
  local cAlias := 'IMPL', impAlias

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
    do while !(cAlias)->(EOF()) .and. mkod_human == (cAlias)->KOD_HUM
      if rec_hu == 0
      else
        if rec_hu == (cAlias)->MO_HU_K
          // найти серийный номер если есть
          ser_num := chek_implantant_ser_number((cAlias)->(recno()))
          // создать массив
          AAdd(arrImplantant, {(cAlias)->KOD_HUM, (cAlias)->KOD_K, (cAlias)->DATE_UST, (cAlias)->RZN, iif(ser_num != nil, ser_num, ''), (cAlias)->MO_HU_K})
        endif
      endif
      (cAlias)->(dbSkip())
    enddo
  endif
  (cAlias)->(dbCloseArea())
  select(oldSelect)
  if impAlias == 0
    (cAlias)->(dbCloseArea())
  endif
  return arrImplantant

****** 20.01.22 удалить имплантант в листе учета
function delete_implantant(mkod_human)
  local oldSelect := select()

  Use_base("human_im")
  find (str(mkod_human, 7))
  if IMPL->(found())
    // вначале удалить серийный номер если есть
    delete_implantant_ser_number(IMPL->(recno()))
    DeleteRec(.t.,.f.)  // очистка записи с пометкой на удаление
  endif
  IMPL->(dbCloseArea())
  select(oldSelect)
  return nil

****** 10.03.22 сохранить имплантант в БД учета
function save_implantant(arrImplantant)
  local oldSelect := select()

  Use_base("human_im")
  find (str(arrImplantant[1], 7))
  if IMPL->(found())
    G_RLock(forever)
    IMPL->KOD_HUM   := arrImplantant[1]
    IMPL->KOD_K     := arrImplantant[2]
    IMPL->DATE_UST  := arrImplantant[3]
    IMPL->RZN       := arrImplantant[4]
    IMPL->MO_HU_K   := arrImplantant[5]
    UNLOCK
    // сохранить серийный номер если есть
  else
    AddRec(7)
    IMPL->KOD_HUM   := arrImplantant[1]
    IMPL->KOD_K     := arrImplantant[2]
    IMPL->DATE_UST  := arrImplantant[3]
    IMPL->RZN       := arrImplantant[4]
    IMPL->MO_HU_K   := arrImplantant[5]
  endif
  if ! empty(arrImplantant[5])
    // сохранить серийный номер если есть
    save_implantant_ser_number(IMPL->(recno()), arrImplantant[5])
  endif
  IMPL->(dbCloseArea())
  select(oldSelect)
  return nil

****** 28.01.22 проверка даты установки имплантантов
function fDateImplant(get)

  if ctod(get:buffer) < human->n_data
    get:varPut( get:original )
    func_error(4, 'Дата установки имплантанта меньше даты начала лечения!')
    return .f.
  endif

  if ctod(get:buffer) > human->k_data
    get:varPut( get:original )
    func_error(4, 'Дата установки имплантанта больше даты окончания лечения!')
    return .f.
  endif
  return .t.