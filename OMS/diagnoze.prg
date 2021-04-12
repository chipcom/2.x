#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "chip_mo.ch"

***** �஢�ઠ ����� �������� � ��砥 ���
Function val1_10diag(fl_search,fl_plus,fl_screen,ldate,lpol)
  // fl_search - �᪠�� ������ ������� � �ࠢ�筨��
  // fl_plus   - ����᪠���� �� ���� ��ࢨ筮(+)/����୮(-) � ���� ��������
  // fl_screen - �뢮���� �� �� �࠭ ������������ ��������
  // ldate     - ���, �� ���ன �஢������ ������� �� ���
  // lpol      - ��� ��� �஢�ન �����⨬��� ����� �������� �� ����
  Local fl := .t., mshifr, tmp_select := select(), c_plus := " ", i, arr,;
        lis_talon := .f., jt, m1, s, mshifr6, fl_4
  local isGeneralDiagnoze
        
  DEFAULT fl_search TO .t., fl_plus TO .f., fl_screen TO .f., ldate TO sys_date
  if type("is_talon") == "L" .and. is_talon
    lis_talon := .t.
  endif
  Private mvar := upper(readvar())

  isGeneralDiagnoze := (mvar == 'MKOD_DIAG')  // ��⠭���� ���� �� �஢��塞�� ���� �᭮��� ���������
  
  mshifr := alltrim(&mvar)
  if lis_talon
    arr := {"MKOD_DIAG" ,;
            "MKOD_DIAG2",;
            "MKOD_DIAG3",;
            "MKOD_DIAG4",;
            "MSOPUT_B1" ,;
            "MSOPUT_B2" ,;
            "MSOPUT_B3" ,;
            "MSOPUT_B4"}
    if (jt := ascan(arr,mvar)) == 0
      lis_talon := .f.
    endif
  endif
  if fl_plus
    if (c_plus := right(mshifr,1)) $ yes_d_plus  // "+-"
      mshifr := alltrim(left(mshifr,len(mshifr)-1))
    else
      c_plus := " "
    endif
  endif
  mshifr6 := padr(mshifr,6)
  mshifr := padr(mshifr,5)
  if empty(mshifr)
    diag_screen(2)
  elseif fl_search
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
    mshifr := mshifr6
    find (mshifr)
    if found()
      fl_4 := .f.
      if !empty(ldate) .and. !between_date(diag->dbegin,diag->dend,ldate, , isGeneralDiagnoze)
        fl_4 := .t.  // ������� �� �室�� � ���
      endif
      if fl_4 .and. mem_diag4 == 2 .and. !("." $ mshifr) // �᫨ ��� ��姭���
        m1 := alltrim(mshifr)+"."
        // ⥯��� �஢�ਬ �� ����稥 ��� ����姭�筮�� ���
        find (m1)
        if found()
          s := ""
          for i := 0 to 9
            find (m1+str(i,1))
            if found()
              s += alltrim(diag->shifr)+","
            endif
          next
          s := substr(s,1,len(s)-1)
          &mvar := padr(m1,5)+c_plus
          fl := func_error(4,"����㯭� ����: "+s)
        endif
      endif
      if fl .and. fl_screen .and. mem_diagno == 2
        arr := {"","","",""} ; i := 1
        find (mshifr)
        arr[1] := mshifr+" "+diag->name
        skip
        do while i < 4 .and. diag->shifr == mshifr .and. !eof()
          arr[++i] := space(6)+diag->name
          skip
        enddo
        s := ""
        find (mshifr)
        if !empty(ldate) .and. !between_date(diag->dbegin,diag->dend,ldate, , isGeneralDiagnoze)
          s := "������� �� �室�� � ���"
        endif
        if !empty(lpol) .and. !empty(diag->pol) .and. !(diag->pol == lpol)
          if empty(s)
            s := "�"
          else
            s += ", �"
          endif
          s += "�ᮢ���⨬���� �������� �� ����"
        endif
        if !empty(s)
          arr[4] := padc(alltrim(s)+"!",71)
          mybell()
        endif
        diag_screen(1,arr)
      endif
    else
      if "." $ mshifr  // �᫨ ��� ����姭���
        m1 := beforatnum(".",mshifr)
        // ᭠砫� �஢�ਬ �� ����稥 ��姭�筮�� ���
        find (m1)
        if found()
          // ⥯��� �஢�ਬ �� ����稥 ��� ����姭�筮�� ���
          find (m1+".")
          if found()
            s := ""
            for i := 0 to 9
              find (m1+"."+str(i,1))
              if found()
                s += alltrim(diag->shifr)+","
              endif
            next
            s := substr(s,1,len(s)-1)
            &mvar := padr(m1+".",5)+c_plus
            fl := func_error(4,"����㯭� ����: "+s)
          else
            &mvar := padr(m1,5)+c_plus
            fl := func_error(4,"����� ������� ��������� ⮫쪮 � ���� �������筮�� ���!")
          endif
        endif
      endif
      if fl
        &mvar := space(if(fl_plus,6,5))
        fl := func_error(4,"������� � ⠪�� ��஬ �� ������!")
      endif
    endif
    diag->(dbCloseArea())
    if tmp_select > 0
      select (tmp_select)
    endif
  endif
  if fl
    if right(mshifr6,1) != " "
      &mvar := mshifr6
    else
      &mvar := padr(mshifr,5)+c_plus
    endif
  endif
  if lis_talon .and. type("adiag_talon")=="A"
    if empty(&mvar)  // �᫨ ���⮩ ������� -> ����塞 ������� � ����
      for i := jt*2-1 to jt*2
        adiag_talon[i] := 0
      next
    endif
    put_dop_diag()
  endif
  return fl
  
  ***** ���񭭠� �஢�ઠ ����� ��������
  Function val2_10diag()
  Local fl := .t., mshifr, tmp_select := select()
  Private mvar := upper(readvar())
  mshifr := alltrim(&mvar)
  mshifr := padr(alltrim(&mvar),5)
  if !empty(mshifr)
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
    find (mshifr)
    fl := found()
    diag->(dbCloseArea())
    if tmp_select > 0
      select (tmp_select)
    endif
    if !fl
      func_error(4,"������� �� ᮮ⢥����� ���-10")
    endif
  endif
  return fl
  
  ***** ����� �� ���� ��������
  Function input_10diag()
  Static sshifr := "     "
  Local buf := box_shadow(18,20,20,59,color8), bg := {|o,k| get_MKB10(o,k) }
  Private mshifr := sshifr, ashifr := {}, fl_F3 := .f.
  @ 19,26 say "������ ��� �����������" color color1 ;
              get mshifr PICTURE "@K@!" ;
              reader {|o| MyGetReader(o,bg) } ;
              valid val1_10diag(.f.) color color1
  status_key("^<Esc>^ - �⪠� �� �����;  ^<Enter>^ - ���⢥ত���� �����;  ^<F3>^ - �롮� �� ᯨ᪠")
  set key K_F3 TO f1input_10diag()
  myread({"confirm"})
  set key K_F3 TO
  if fl_F3
    sshifr := mshifr
  elseif lastkey() != K_ESC .and. !empty(mshifr)
    R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
    find (mshifr)
    if found()
      sshifr := mshifr ; ashifr := f2input_10diag()
    else
      mshifr := ""
      func_error(4,"������� � ⠪�� ��஬ �� ������!")
    endif
    Use
  endif
  rest_box(buf)
  return {mshifr,ashifr}
  
  *****
  Function f1input_10diag()
  Local buf := savescreen(), agets, fl := .f.
  Private pregim := 1, uregim := 1
  set key K_F3 TO
  SAVE GETS TO agets
  R_Use(dir_exe+"_mo_mkb",cur_dir+"_mo_mkb","DIAG")
  if !empty(mshifr)
    find (alltrim(mshifr))
    fl := found()
  endif
  if !fl
    go top
  endif
  if Alpha_Browse(2,1,maxrow()-2,77,"f1_10diag",color0,,,.t.,,,,"f2_10diag",,,{,,,"N/BG,W+/N,B/BG,BG+/B"} )
    fl_F3 := .t. ; mshifr := FIELD->shifr ; ashifr := f2input_10diag()
    keyboard chr(K_ENTER)
  endif
  close databases
  restscreen(buf)
  RESTORE GETS FROM agets
  set key K_F3 TO f1input_10diag()
  return NIL
  
  *****
  Static Function f2input_10diag()
  Local arr_t := {}
  do while FIELD->ks > 0
    skip -1
  enddo
  aadd(arr_t, alltrim(FIELD->name))
  skip
  do while FIELD->ks > 0
    aadd(arr_t, alltrim(FIELD->name))
    skip
  enddo
  return arr_t
  
  ***** ����� ���᪨� �㪢� �� ��⨭᪨� �� ����� ��������
  Function get_mkb10(oGet,nKey,fl_F7)
  Local cKey, arr, i, mvar, mvar_old
  if nKey == K_F7 .and. fl_F7 .and. !(yes_d_plus == "+-")
    arr := {"MKOD_DIAG" ,;
            "MKOD_DIAG2",;
            "MKOD_DIAG3",;
            "MKOD_DIAG4",;
            "MSOPUT_B1" ,;
            "MSOPUT_B2" ,;
            "MSOPUT_B3" ,;
            "MSOPUT_B4" ,;
            "MKOD_DIAG0"}
    mvar := readvar()
    if (i := ascan(arr,{|x| x==mvar})) > 1
      mvar_old := arr[i-1]
      if !empty(&mvar_old)
        keyboard chr(K_HOME)+left(&mvar_old,5)
      endif
    endif
  elseif between(nKey, 32, 255)
    cKey := CHR( nKey )
    ************** ���� ��� �㪢�, ������ �� ��������� ⠬ ��, ��� � ���
    if oGet:pos < 4  // ����� � ��砫�
      cKey := kb_rus_lat(ckey)  // �᫨ ���᪠� �㪢�
    endif
    if cKey == ","
      cKey := "." // ������� ������� �� ��� (��஢�� ��������� ��� Windows)
    endif
    **************
    IF ( SET( _SET_INSERT ) )
      oGet:insert( cKey )
    ELSE
      oGet:overstrike( cKey )
    ENDIF
    IF ( oGet:typeOut )
      IF ( SET( _SET_BELL ) )
        ?? CHR(7)
      ENDIF
      IF ( !SET( _SET_CONFIRM ) )
        oGet:exitState := GE_ENTER
      ENDIF
    ENDIF
  ENDIF
  return NIL
  
***** � ���� "�������" ������� �����
Function when_diag()
  SETCURSOR()
  return .t.
  
    