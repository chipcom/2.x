#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

****** 21.01.22 - �롮� ������� 
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
	oBox:MessageLine := '^<Esc>^ - ��室;  ^<PgDn>^ - ���⢥ত���� �����'
	oBox:Caption := '�롥�� ������⠭�'
	oBox:View()

	do while .t.
		iRow := 11

    @ ++iRow, 12 say "��� ��⠭����" get mDATE_INST ;
          valid {|g| fDateImplant(g) }
    
    @ ++iRow, 12 say '��� �������:' get mVIDIMPL ;
          reader {|x| menu_reader(x, tmp_Implantant, A__MENUVERT, , , .f.)} ;
          valid {|| mVIDIMPL := padr(mVIDIMPL, 44), .t. }

    sPicture := '@S40'
		@ ++iRow, 12 say '��਩�� �����:' get mNUMBER picture sPicture ;
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

****** 20.01.22 ������ ������⠭� � ���� ���
function check_implantant(mkod_human)
  local tmpSelect := select()
  local arrImplantant, ser_num

  Use_base("human_im")
  find (str(mkod_human, 7))
  if IMPL->(found())
    // ���� �਩�� ����� �᫨ ����
    ser_num := chek_implantant_ser_number(IMPL->(recno()))
    // ᮧ���� ���ᨢ
    arrImplantant := {IMPL->KOD_HUM, IMPL->KOD_K, IMPL->DATE_UST, IMPL->RZN, iif(ser_num != nil, ser_num, '')}
  endif
  IMPL->(dbCloseArea())
  select(tmpSelect)
  return arrImplantant

****** 20.01.22 㤠���� ������⠭� � ���� ���
function delete_implantant(mkod_human)
  local tmpSelect := select()

  Use_base("human_im")
  find (str(mkod_human, 7))
  if IMPL->(found())
    // ���砫� 㤠���� �਩�� ����� �᫨ ����
    delete_implantant_ser_number(IMPL->(recno()))
    DeleteRec(.t.,.t.)  // ���⪠ ����� � ����⪮� �� 㤠�����
  endif
  IMPL->(dbCloseArea())
  select(tmpSelect)
  return nil

****** 20.01.22 ��࠭��� ������⠭� � �� ���
function save_implantant(arrImplantant)
  local tmpSelect := select()

  Use_base("human_im")
  find (str(arrImplantant[1], 7))
  if IMPL->(found())
    G_RLock(forever)
    IMPL->KOD_HUM   := arrImplantant[1]
    IMPL->KOD_K     := arrImplantant[2]
    IMPL->DATE_UST  := arrImplantant[3]
    IMPL->RZN       := arrImplantant[4]
    UNLOCK
    // ��࠭��� �਩�� ����� �᫨ ����
  else
    AddRec(7)
    IMPL->KOD_HUM   := arrImplantant[1]
    IMPL->KOD_K     := arrImplantant[2]
    IMPL->DATE_UST  := arrImplantant[3]
    IMPL->RZN       := arrImplantant[4]
  endif
  if ! empty(arrImplantant[5])
    // ��࠭��� �਩�� ����� �᫨ ����
    save_implantant_ser_number(IMPL->(recno()), arrImplantant[5])
  endif
  IMPL->(dbCloseArea())
  select(tmpSelect)
  return nil

****** 28.01.22 �஢�ઠ ���� ��⠭���� ������⠭⮢
function fDateImplant(get)

  if ctod(get:buffer) < human->n_data
    get:varPut( get:original )
    func_error(4, '��� ��⠭���� ������⠭� ����� ���� ��砫� ��祭��!')
    return .f.
  endif

  if ctod(get:buffer) > human->k_data
    get:varPut( get:original )
    func_error(4, '��� ��⠭���� ������⠭� ����� ���� ����砭�� ��祭��!')
    return .f.
  endif
  return .t.