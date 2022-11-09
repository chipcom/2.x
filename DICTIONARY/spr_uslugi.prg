** spr_uslugi.prg - ����� � �ࠢ�筨���� ���
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** ������஢���� �ࠢ�筨�� ���
Function edit_spr_uslugi(k)
  Static sk := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j
  
  DEFAULT k TO 0
  do case
    case k == 0
      if ! hb_user_curUser:IsAdmin()
        return func_error(4, err_admin)
      endif
      mas_pmt := {'~������஢���� ���', ;
                  '��㣨 �����ࠢ� �� (~�����)', ;
                  '~��������� ��㣨', ;
                  '������஢���� ~���', ;
                  '������� �~��', ;
                  '��ᮢ���⨬���� �� ~���', ;
                  '��㣨 ��� ~��祩', ;
                  '��㣨 - ~1 ࠧ � ����', ;
                  '������஢���� ~�㦡'}
      mas_msg := {'������஢���� �ࠢ�筨�� ��� (����� � ��)', ;
                  '������஢���� �ࠢ�筨�� ��� ��������⢠ ��ࠢ���࠭���� �� (�������樨 �����)', ;
                  '������஢���� �ࠢ�筨�� ���������� ��� (��� 㤮��⢠ ����� ������)', ;
                  '������஢���� �����樥�⮢ ��㤮񬪮�� ��� (���)', ;
                  '������஢���� �������� ����筮� ��㤮񬪮�� ���ᮭ���', ;
                  '������஢���� �ࠢ�筨�� ���, ����� �� ������ ���� ������� � ���� ����', ;
                  '����/।���஢���� ���, � ������ �� �������� ��� (����⥭�)', ;
                  '����/।���஢���� ���, ����� ����� ���� ������� 祫����� ⮫쪮 ࠧ � ����', ;
                  '������஢���� �ࠢ�筨�� �㦡'}
      mas_fun := {'edit_spr_uslugi(1)', ;
                  'edit_spr_uslugi(2)', ;
                  'edit_spr_uslugi(3)', ;
                  'edit_spr_uslugi(4)', ;
                  'edit_spr_uslugi(5)', ;
                  'edit_spr_uslugi(6)', ;
                  'edit_spr_uslugi(7)', ;
                  'edit_spr_uslugi(8)', ;
                  'edit_spr_uslugi(9)'}
      popup_prompt(T_ROW, T_COL+5, sk, mas_pmt, mas_msg, mas_fun)
    case k == 1
      f1_uslugi()
    case k == 2
      spr_uslugi_FFOMS()
    case k == 3
      f_k_uslugi()
    case k == 4
      f_trkoef()
    case k == 5
      f_trpers()
    case k == 6
      f_ns_uslugi()
    case k == 7
      f_usl_uva()
    case k == 8
      f_usl_raz()
    case k == 9
      f5_uslugi(2, T_COL + 10)
  endcase
  if k > 0
    sk := k
  endif
  return NIL

** 02.12.21
FUNCTION f1_uslugi()
  Local arr_block, buf := savescreen(), str_sem := '������஢���� ���'
  local tmpAlias, i
  
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  if !Use_base('lusl') .or. !Use_base('luslc') .or. ;
      !G_Use(dir_server + 'uslugi1', {dir_server + 'uslugi1', ;
            dir_server + 'uslugi1s'}, 'USL1') .or. ;
      !G_Use(dir_server + 'uslugi', , 'USL') .or. ;
      !G_Use(dir_server + 'usl_otd', dir_server + 'usl_otd', 'UO') .or. ;
      !R_Use(dir_server + 'slugba', dir_server + 'slugba', 'SL')
      close databases
    return NIL
  endif
  mywait()
  if is_otd_dep .and. glob_otd_dep == 0 .and. len(mm_otd_dep) > 0
    glob_otd_dep := mm_otd_dep[1, 2] // ���� ���� ��ࢮ� �⤥�����
  endif
  if !(type('arr_date_usl') == 'A')
    Public arr_date_usl := {}
    for i := 2018 to WORK_YEAR
      tmpAlias := create_name_alias('LUSLC', i)
      select (tmpAlias)
      index on dtos(datebeg) to (cur_dir + 'tmp1') unique
      dbeval({|| aadd(arr_date_usl, (tmpAlias)->datebeg)})
      set index to (cur_dir + prefixFileRefName(i) + 'uslc'), (cur_dir + prefixFileRefName(i) + 'uslu')
    next
  endif
  Private tmp_V002 := create_classif_FFOMS(0, 'V002') // PROFIL
  dbcreate(cur_dir + 'tmp_usl1', {{'shifr1',  'C', 10, 0}, ;
                               {'name',    'C', 77, 0}, ;
                               {'date_b',  'D', 8, 0}})
  use (cur_dir + 'tmp_usl1') new
  index on dtos(date_b) to (cur_dir + 'tmp_usl1')
  select USL
  index on iif(kod>0, '1', '0') + fsort_usl(shifr) to (cur_dir + 'tmp_usl')
  set index to (cur_dir + 'tmp_usl'), ;
               (dir_server + 'uslugi'), ;
               (dir_server + 'uslugish'), ;
               (dir_server + 'uslugis1'), ;
               (dir_server + 'uslugisl')
  Private str_find := '1', muslovie := 'usl->kod > 0'
  arr_block := {{|| FindFirst(str_find)}, ;
              {|| FindLast(str_find)}, ;
              {|n| SkipPointer(n, muslovie)}, ;
              str_find, muslovie;
               }
  find ('1')
  Private fl_found := found()
  if fl_found
    do while empty(shifr) .and. !eof()
      skip
    enddo
  else
    keyboard chr(K_INS)
  endif
  Alpha_Browse(2, 0, maxrow() - 1, 79, 'f1_es_uslugi', color0, '������஢���� ���', 'B/BG', ;
               .f., , arr_block, , 'f2_es_uslugi', , ;
               {'�', '�', '�', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R,N+/BG,W/N,RB/BG,W+/RB', .t., 180} )
  close databases
  G_SUnLock(str_sem)
  restscreen(buf)
  return NIL
  
**
Function f1_es_uslugi(oBrow)
  Local n := 56
  Local oColumn, blk := {|_c| _c := f0_es_uslugi(), {{1, 2}, {3, 4}, {5, 6}, {7, 8}, {9, 10}}[_c]}
  oColumn := TBColumnNew('   ����', {|| usl->shifr })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('���� �����', {|| opr_shifr_TFOMS(usl->shifr1, usl->kod)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  if is_zf_stomat == 1
    oColumn := TBColumnNew('��', {|| iif(usl->zf == 1, '��', '  ')})
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
    n -= 3
  endif
  oColumn := TBColumnNew(center('������������ ��㣨', n), {|| left(usl->name, n)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ ��室 ^<Enter>^ ।���஢���� ^<Ins>^ ���������� ^<Del>^ 㤠����� ^<F2>^ ����')
  return NIL
  
**
Function f2_es_uslugi(nKey,oBrow)
  Static sshifr := '          '
  LOCAL j := 0, k := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
        tmp_color := setcolor(), r1 := 14, c1 := 2

  do case
    case nKey == K_F2
      rec := recno()
      if (mshifr := input_value(18, 10, 20, 69, color1, ;
                '  ������ ����室��� ��� ��㣨 ��� ���᪠', ;
                sshifr, '@K@!')) != NIL
        sshifr := mshifr := transform_shifr(mshifr)
        set order to 3
        find (padr(mshifr, 10))
        if found()
          rec := recno()
          fl := .t.
        endif
        set order to 1
        if fl
          oBrow:goTop()
          goto (rec)
          k := 0
        else
          goto (rec)
          func_error(4, '��㣠 � ��஬ "' + alltrim(mshifr) + '" �� �������!')
        endif
      endif
    case nKey == K_INS .or. (nKey == K_ENTER .and. usl->kod > 0)
      rec := f3_es_uslugi(nKey)
      select USL
      oBrow:goTop()
      goto (rec)
      k := 0
    case nKey == K_DEL .and. usl->kod > 0
      stat_msg('����! �ந�������� �஢�ઠ �� ����稥 㤠�塞�� ��㣨 � ��㣨� ����� ������.')
      mybell(0.1, OK)
      R_Use(dir_server + 'human_u', dir_server + 'human_uk', 'HU')
      find (str(usl->kod, 4))
      fl := found()
      hu->(dbCloseArea())
      if !fl
        R_Use(dir_server + 'hum_p_u', dir_server + 'hum_p_uk', 'HU')
        find (str(usl->kod, 4))
        fl := found()
        hu->(dbCloseArea())
      endif
      if !fl
        R_Use(dir_server + 'hum_oru', dir_server + 'hum_oruk', 'HU')
        find (str(usl->kod, 4))
        fl := found()
        hu->(dbCloseArea())
      endif
      if !fl
        R_Use(dir_server + 'kas_pl_u', dir_server + 'kas_pl2u', 'HU')
        find (str(usl->kod, 4))
        fl := found()
        hu->(dbCloseArea())
        if !fl
          R_Use(dir_server + 'kas_ortu', dir_server + 'kas_or2u', 'HU')
          find (str(usl->kod, 4))
          fl := found()
          hu->(dbCloseArea())
        endif
      endif
      select USL
      if fl
        func_error(4, '������ ��㣠 ����砥��� � ��㣨� ����� ������. �������� ����饭�!')
      elseif f_Esc_Enter(2, .t.)
        mywait()
        useUch_Usl()
        select UU1
        do while .t.
          find (STR(usl->kod, 4))
          if !found()
            exit
          endif
          DeleteRec(.t.)
        enddo
        select UU
        find (STR(usl->kod, 4))
        do while uu->kod == usl->kod .and. !eof()
          G_RLock(forever)
          uu->vkoef_v := 0
          uu->vkoef_r := 0
          uu->akoef_v := 0
          uu->akoef_r := 0
          uu->koef_v := 0
          uu->koef_r := 0
          UNLOCK
          skip
        enddo
        uu->(dbCloseArea())
        uu1->(dbCloseArea())
        //
        select USL1
        do while .t.
          find (STR(usl->kod, 4))
          if !found()
            exit
          endif
          DeleteRec(.t.)
        enddo
        //
        select USL
        G_RLock(forever)
        replace usl->kod with -1, ;
                usl->slugba with -1, ;
                usl->name with '', ;
                usl->shifr with '', ;
                usl->shifr1 with ''
        UNLOCK
        Commit
        stat_msg('��㣠 㤠����!')
        mybell(1,OK)
        oBrow:goTop()
        k := 0
      endif
  endcase
  rest_box(buf)
  return k
  
** 03.09.17
Function f3_es_uslugi(nKey)
  Static menu_nul := {{'���', .f.}, {'��', .t.}}
  Local tmp_help := chm_help_code, buf := savescreen(), r, r1 := maxrow() - 11, ;
        k, tmp_color := setcolor(), ret := usl->(recno()), old_m1otd, s, is_full

  Private mkod, mname, mpcena, mpcena_d, mshifr, mshifr1, mcena, mcena_d, ;
          m1shifr1, m1PROFIL, mPROFIL, mpnds, mpnds_d, mzf, m1zf, ;
          mdms_cena, m1is_nul, mis_nul, motdel := space(10), m1otdel:='', ;
          mname1:='', mslugba, m1slugba, gl_area, ;
          m1is_nulp, mis_nulp, yes_tfoms := .f., pifin := 0, pifinr, pifinc
  if (is_full := (is_task(X_ORTO) .or. is_task(X_KASSA) .or. is_task(X_PLATN)))
    r1 -= 4
  endif
  gl_area := {r1 + 1, 0, 23, 79, 0}
  //
  select TMP_USL1
  zap
  //
  mkod      := IF(nKey == K_INS, 0, usl->kod)
  mname     := IF(nKey == K_INS, SPACE(65), usl->name)
  mfull_name:= IF(nKey == K_INS, SPACE(255),usl->full_name)
  mshifr    := if(nKey == K_INS, space(10), usl->shifr)
  mshifr1   := if(nKey == K_INS, space(10), usl->shifr1)
  m1PROFIL  := IF(nKey == K_INS, 0, usl->profil)
  mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
  mcena     := IF(nKey == K_INS, 0, usl->cena)
  mcena_d   := IF(nKey == K_INS, 0, usl->cena_d)
  mpcena    := IF(nKey == K_INS, 0, usl->pcena)
  mpcena_d  := IF(nKey == K_INS, 0, usl->pcena_d)
  mpnds     := IF(nKey == K_INS, 0, usl->pnds)
  mpnds_d   := IF(nKey == K_INS, 0, usl->pnds_d)
  mdms_cena := IF(nKey == K_INS, 0, usl->dms_cena)
  m1slugba  := if(nKey == K_INS, -1, usl->slugba)
  m1zf      := if(nKey == K_INS, .f., (usl->zf == 1))
  mzf       := inieditspr(A__MENUVERT, menu_nul, m1zf)
  m1is_nul  := if(nKey == K_INS, .f., usl->is_nul)
  mis_nul   := inieditspr(A__MENUVERT, menu_nul, m1is_nul)
  m1is_nulp := if(nKey == K_INS, .f., usl->is_nulp)
  mis_nulp  := inieditspr(A__MENUVERT, menu_nul, m1is_nulp)
  if m1slugba >= 0
    select SL
    find (str(m1slugba, 3))
    mslugba := lstr(sl->shifr) + '. ' + alltrim(sl->name)
  else
    mslugba := space(10)
  endif
  if nKey == K_ENTER // ।���஢����
    if !empty(s := f0_e_uslugi1(mkod, , .t.))
      mshifr1 := s
    endif
    select UO
    find (str(mkod, 4))
    if found()
      k := atnum(chr(0), uo->otdel, 1)
      motdel := '= ' + lstr(k - 1) + '��. ='
      m1otdel := left(uo->otdel, k - 1)
    endif
  endif
  m1shifr1 := mshifr1
  old_m1otd := m1otdel
  chm_help_code := 1//H_Edit_uslugi
  //
  SETCOLOR(color8)
  Scroll( r1, 0, maxrow()-1, maxcol() )
  @ r1, 0 to r1, maxcol()
  status_key('^<Esc>^ - ��室 ��� �����;  ^<PgDn>^ - ������')
  IF nKey == K_INS
    str_center(r1, ' ���������� ��㣨 ')
  ELSE
    str_center(r1, ' ������஢���� ')
  ENDIF
  f4_es_uslugi(0)
  DO WHILE .T.
    SETCOLOR(cDataCGet)
    if !m1is_nul
      keyboard chr(K_TAB)
    endif
    r := r1
    @ ++r, 1 SAY '����蠥��� ���� ������ ��㣨 �� ������� 業� � ����� ���?' ;
            get mis_nul reader {|x|menu_reader(x, menu_nul, A__MENUVERT, , , .f.)}
    @ ++r, 1 SAY '������������ ��㣨 �� �ࠢ�筨�� �����'
    @ ++r, 3 GET mname1 when .f. color color14
    @ ++r, 1 SAY '���� ��' get mshifr picture '@!' valid f4_es_uslugi(1, .t., nKey)
    @ row(), col() + 5 SAY '��� �����' get mshifr1 ;
                    reader {|x|menu_reader(x, {{|k, r, c| f1_e_uslugi1(k, r, c) }}, A__FUNCTION, , , .f.)} ;
                    valid f4_es_uslugi(0) ;
                    color 'R/W'
  if is_zf_stomat == 1
    @ row(), col() + 5 SAY '���� �㡭�� ����' get mzf ;
                    reader {|x|menu_reader(x, menu_nul, A__MENUVERT, , , .f.)}
  endif
    @ ++r, 1 SAY '������������ ��㣨' GET mname PICTURE '@S59'
  if is_full
    @ ++r, 1 SAY '������������/�����' GET mfull_name PICTURE '@S58'
  endif
    @ ++r, 1 SAY '���� ��㣨 ���: ��� ���᫮��' GET mcena PICTURE pict_cena when !yes_tfoms color color14
    @ row(), col() SAY ', ��� ॡ����' GET mcena_d PICTURE pict_cena when !yes_tfoms color color14
    @ ++r, 1 say '��䨫�' get MPROFIL ;
            reader {|x|menu_reader(x, tmp_V002, A__MENUVERT_SPACE, , , .f.)}
  if is_full
    @ ++r, 1 SAY '����蠥��� ���� ������� ��㣨 �� ������� 業�?' ;
            get mis_nulp reader {|x|menu_reader(x, menu_nul, A__MENUVERT, , , .f.)}
    @ ++r, 1 SAY '���� ������� ��㣨: ��� ���᫮��' GET mpcena PICTURE pict_cena
    @ row(), col() SAY ' (� �.�. ���' GET mpnds PICTURE pict_cena
    @ row(), col() SAY ')'
    @ ++r, 1 SAY '   ��� ॡ����' GET mpcena_d PICTURE pict_cena
    @ row(), col() SAY ' (� �.�. ���' GET mpnds_d PICTURE pict_cena
    @ row(), col() SAY '); 業� �� ���' GET mdms_cena PICTURE pict_cena
  endif
  
    @ ++r, 1 SAY '��㦡�' get mslugba ;
            reader {|x|menu_reader(x, {{|k, r, c| fget_slugba(k, r, c)}}, A__FUNCTION, , , .f.)} ;
            color 'R/W'
    @ ++r, 1 say '� ����� �⤥������ ࠧ�蠥��� ���� ��㣨' get motdel ;
            reader {|x|menu_reader(x, {{|k, r, c|inp_bit_otd(k, r, c)}}, A__FUNCTION, , , .f.)}
  
    myread()
    if LASTKEY() != K_ESC
      fl := .t.
      if EMPTY(mname)
        fl := func_error('�� ������� �������� ��㣨. ��� �����.')
      elseif empty(mshifr)
        fl := func_error('�� ������ ��� ��㣨. ��� �����.')
      endif
      if fl
        mywait()
        select USL
        SET ORDER TO 2
        if nKey == K_INS
          FIND (STR(-1, 4))
          if found()
            G_RLock(forever)
          else
            AddRec(4)
          endif
          mkod := recno()
          usl->kod := mkod
        else
          FIND (STR(mkod, 4))
          G_RLock(forever)
        endif
        usl->name     := mname
        usl->full_name:= mfull_name
        usl->shifr    := mshifr
        usl->shifr1   := mshifr1
        usl->PROFIL   := m1PROFIL
        usl->zf       := iif(m1zf, 1, 0)
        usl->is_nul   := m1is_nul
        usl->is_nulp  := m1is_nulp
        usl->slugba   := m1slugba
        if valtype(mcena) == 'C'
          usl->cena   := val(mcena)
          usl->cena_d := val(mcena_d)
        else
          usl->cena   := mcena
          usl->cena_d := mcena_d
        endif
        usl->pcena    := mpcena
        usl->pcena_d  := mpcena_d
        usl->dms_cena := mdms_cena
        usl->pnds     := mpnds
        usl->pnds_d   := mpnds_d
        //
        select USL1
        do while .t.
          find (STR(mkod, 4))
          if !found()
            exit
          endif
          DeleteRec(.t.)
        enddo
        select TMP_USL1
        go top
        do while !eof()
          select USL1
          AddRec(4)
          usl1->kod    := mkod
          usl1->shifr1 := tmp_usl1->shifr1
          usl1->date_b := tmp_usl1->date_b
          select TMP_USL1
          skip
        enddo
        //
        if !(old_m1otd == m1otdel)
          select UO
          if len(m1otdel) == 0
            find (str(mkod, 4))
            if found()
              DeleteRec(.t.)
            endif
          else
            find (str(mkod, 4))
            if found()
              G_RLock(forever)
            else
              AddRec(4)
              uo->kod := mkod
            endif
            uo->otdel := padr(m1otdel, 255, chr(0))
          endif
        endif
        UNLOCK ALL
        COMMIT
        ret := mkod
      else
        loop
      ENDIF
    ENDIF
    exit
  ENDDO
  chm_help_code := tmp_help
  restscreen(buf)
  setcolor(tmp_color)
  select USL
  set order to 1
  Return ret
  
** 15.01.19
Function f4_es_uslugi(k, fl_poisk, nKey)
  Local fl, v1, v2, s, rec, fl1del, fl2del

  if k > 0
    DEFAULT fl_poisk TO .f.
    Private tmp := readvar()
    &tmp := transform_shifr(&tmp)
    if fl_poisk .and. !empty(mshifr)
      select USL
      rec := recno()
      set order to 1
      v1 := 0
      find (mshifr)
      do while usl->shifr == mshifr .and. !eof()
        if nKey == K_INS
          ++v1
        elseif recno() != rec
          ++v1
        endif
        skip
      enddo
      goto (rec)
      if v1 > 0
        return func_error(4, '����� ��� ��㣨 㦥 ����砥��� � �ࠢ�筨�� ���!')
      endif
      R_Use(dir_server + 'mo_su', dir_server + 'mo_sush', 'MOSU')
      find (mshifr)
      if found()
        v1 := 1
      endif
      dbCloseArea()
      select USL
      if v1 > 0
        return func_error(4, '����� ��� ��㣨 㦥 ����砥��� � �ࠢ�筨�� ����権!')
      endif
    endif
  endif
  s := iif(empty(mshifr1), mshifr, mshifr1)
  mname1 := space(77)
  yes_tfoms := .f.
  if !empty(s)
    s := padr(transform_shifr(s), 10)
    select LUSL
    find (s)
    if found()
      yes_tfoms := .t.
      mname1 := padr(lusl->name, 77)
      if empty(mname)
        mname := padr(mname1, 65)
      endif
      v1 := fcena_oms(lusl->shifr, .t., sys_date,  @fl1del, , @pifin)
      v2 := fcena_oms(lusl->shifr, .f., sys_date, @fl2del, , @pifin)
      if fl1del .and. fl2del
        mcena := mcena_d := padr('㤠����', 10)
      else
        mcena := put_kop(v1, 10)
        mcena_d := put_kop(v2, 10)
      endif
    else
      mname1 := padr('�� �������', 77)
    endif
    select USL
  endif
  return update_gets()
  
** 15.01.19
Function f0_es_uslugi()
  Local k := 3, v1, v2, fl1del, fl2del, s := iif(empty(usl->shifr1), usl->shifr, usl->shifr1)

  s := padr(transform_shifr(s), 10)
  select LUSL
  find (s)
  if found()
    k := 4  // �������, �� ��� 業�
    v1 := fcena_oms(lusl->shifr, .t., sys_date, @fl1del)
    v2 := fcena_oms(lusl->shifr, .f., sys_date, @fl2del)
    if fl1del .and. fl2del
      k := 5  // 㤠����
    elseif !emptyall(v1, v2)
      k := 1  // ���� 業�
    endif
  elseif !emptyall(usl->pcena, usl->pcena_d, usl->dms_cena)
    k := 2  // ���� ���⭠� 業�
  endif
  select USL
  return k
  
**
Function f0_e_uslugi1(lkod, ldate, is_base)
  Local s := '', tmp_select := select()

  DEFAULT ldate TO sys_date, is_base TO .f.
  select USL1
  find (str(lkod, 4))
  do while usl1->kod == lkod .and. !eof()
    if usl1->date_b <= ldate
      s := usl1->shifr1
    endif
    if is_base .and. !empty(usl1->shifr1)
      select TMP_USL1
      append blank
      tmp_usl1->date_b := usl1->date_b
      tmp_usl1->shifr1 := usl1->shifr1
      select LUSL
      find (padr(usl1->shifr1, 10))
      if found()
        tmp_usl1->name := lusl->name
      else
        tmp_usl1->name := '�� ������� ������������ ��㣨'
      endif
    endif
    select USL1
    skip
  enddo
  if is_base .and. tmp_usl1->(lastrec()) == 0 .and. !empty(mshifr1)
    select TMP_USL1
    append blank
    tmp_usl1->date_b := arr_date_usl[1]
    tmp_usl1->shifr1 := mshifr1
    select LUSL
    find (padr(mshifr1, 10))
    tmp_usl1->name := lusl->name
  endif
  select (tmp_select)
  return s
  
**
Function f1_e_uslugi1(k, r, c)
  Local t_arr := array(BR_LEN), tmp_select := select(), ret := {space(10), space(10)}

  t_arr[BR_TOP] := r - 10
  t_arr[BR_BOTTOM] := r - 1
  t_arr[BR_LEFT]  := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_COLOR] := color5
  t_arr[BR_TITUL] := '������஢���� ��� ����� ��� ��㣨 ' + alltrim(mshifr)
  t_arr[BR_TITUL_COLOR] := 'BG+/GR'
  t_arr[BR_ARR_BROWSE] := {'�', '�', '�', , .t.}
  t_arr[BR_OPEN] := {|nk, ob| f2_e_uslugi1(nk, ob, 'open') }
  t_arr[BR_COLUMN] := {{'   ���;  ��砫�; ����⢨�', {|| full_date(tmp_usl1->date_b)}}, ;
                       {'���� �����', {|| tmp_usl1->shifr1}}, ;
                       {' ������������', {|| left(tmp_usl1->name, 56)}}}
  t_arr[BR_EDIT] := {|nk, ob| f2_e_uslugi1(nk, ob, 'edit') }
  edit_browse(t_arr)
  //
  select TMP_USL1
  go top
  do while !eof()
    if tmp_usl1->date_b > sys_date
      exit
    endif
    ret := {tmp_usl1->shifr1, tmp_usl1->shifr1}
    skip
  enddo
  select (tmp_select)
  return ret
  
**
Function f2_e_uslugi1(nKey, oBrow, regim)
  Local ret := -1, buf, fl := .f., rec, rec1, r1, r2, tmp_color

  do case
    case regim == 'open'
      select TMP_USL1
      go top
      if (ret := !eof())
        keyboard chr(K_CTRL_PGDN)  // ����� �� ��᫥���� ������
      endif
    case regim == 'edit'
      do case
        case eq_any(nKey, K_INS, K_ENTER)
          rec := recno()
          save screen to buf
          if nkey == K_INS .and. !fl_found
            colorwin(pr1 + 4, pc1, pr1 + 4, pc2, 'W/W', 'GR+/R')
          endif
          Private gl_area := {1, 0, maxrow() - 1, 79, 0}, ;
                  mdate_b := if(nKey == K_INS, atail(arr_date_usl), tmp_usl1->date_b), ;
                  mshifr1 := if(nKey == K_INS, space(10), tmp_usl1->shifr1), ;
                  mname1  := if(nKey == K_INS, space(77), tmp_usl1->name)
          tmp_color := setcolor(cDataCScr)
          box_shadow(pr2 - 5, 0, pr2 - 1, 79, , ;
                         if(nKey == K_INS, '����������', '������஢����'), ;
                         cDataPgDn)
          setcolor(cDataCGet)
          @ pr2 - 4, 2 say '��� ��砫� ����⢨� ��� �����' get mdate_b valid {|g| f3_e_uslugi1(g, mdate_b) }
          @ pr2 - 3, 2 say '���� �����' get mshifr1 pict '@!' valid {|g| f4_e_uslugi1(g) }
          @ pr2 - 2, 2 get mname1 when .f.
          status_key('^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����')
          myread()
          select TMP_USL1
          if lastkey() != K_ESC .and. !emptyany(mdate_b, mshifr1) .and. f_Esc_Enter(1)
            if nKey == K_INS
              fl_found := .t.
              append blank
              rec := recno()
            else
              G_RLock(forever)
            endif
            replace tmp_usl1->date_b with mdate_b, ;
                    tmp_usl1->shifr1 with mshifr1, ;
                    tmp_usl1->name   with mname1
            COMMIT
            oBrow:goTop()
            goto (rec)
            ret := 0
          elseif nKey == K_INS .and. !fl_found
            ret := 1
          endif
          setcolor(tmp_color)
          restore screen from buf
        case nKey == K_DEL .and. !empty(tmp_usl1->date_b) .and. f_Esc_Enter(2)
          Delete
          pack
          oBrow:goTop()
          ret := 0
          if eof()
            ret := 1
          endif
      endcase
  endcase
  return ret
  
**
Function f3_e_uslugi1(get, ldate)
  Local i := 1, fl := .t.

  if empty(ldate)
    fl := func_error(4, '������ ���� �� ����� ���� �����')
  elseif ascan(arr_date_usl, ldate) == 0
    if ldate > atail(arr_date_usl)
      i := len(arr_date_usl)
    elseif ldate > arr_date_usl[1]
      do while ldate > arr_date_usl[1]
        --ldate
        if (i := ascan(arr_date_usl, ldate)) > 0
          exit
        endif
        i := 1
      enddo
    endif
    fl := func_error(4, '����୮� ���祭�� (�������� ��� ᬥ�� 業 ' + date_8(arr_date_usl[i]) + '�.)')
  endif
  return fl
  
** 16.01.13
Function f4_e_uslugi1(get)
  Local fl := .t., fl1del, fl2del

  if !empty(mshifr1 := transform_shifr(mshifr1))
    select LUSL
    find (mshifr1)
    if found()
      mname1 := padr(lusl->name, 77)
      fcena_oms(lusl->shifr, .t., mdate_b, @fl1del)
      fcena_oms(lusl->shifr, .f., mdate_b, @fl2del)
      if fl1del .and. fl2del
        fl := func_error(4, '������ ��㣠 㤠���� ����� �� ���ﭨ� �� ' + date_8(mdate_b) + '�.')
      endif
    else
      fl := func_error(4, '�� ������� ��㣠 � ����� ��஬')
    endif
    if !fl
      mshifr1 := get:original
    endif
  endif
  return fl
  
    
******************************************************************************************************  
**
Function spr_uslugi_FFOMS()
  Static menu_nul := {{'���', .f.}, {'��', .t.}}
  Local arr_block, buf := savescreen(),  str_sem

  str_sem := '������஢���� ���'
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  if !Use_base('luslf') .or. !G_Use(dir_server + 'mo_su', , 'MOSU')
    close databases
    return NIL
  endif
  mywait()
  Private tmp_V002 := create_classif_FFOMS(0, 'V002') // PROFIL
  select MOSU
  index on iif(kod>0, '1', '0') + shifr1 to (cur_dir + 'tmp_usl')
  set index to (cur_dir + 'tmp_usl'), ;
               (dir_server + 'mo_su'), ;
               (dir_server + 'mo_sush'), ;
               (dir_server + 'mo_sush1')
  Private str_find := '1', muslovie := 'mosu->kod > 0'
  arr_block := {{|| FindFirst(str_find)}, ;
                {|| FindLast(str_find)}, ;
                {|n| SkipPointer(n, muslovie)}, ;
                str_find, muslovie;
               }
  find ('1')
  Private fl_found := found()
  if !fl_found
    keyboard chr(K_INS)
  endif
  Alpha_Browse(2, 0,maxrow() - 1, 79, 'f1_FF_uslugi', color0, ;
               '������஢���� ��� ��������⢠ ��ࠢ���࠭���� ��', 'W+/GR', ;
               .f., , arr_block, , 'f2_FF_uslugi', , ;
               {'�', '�', '�', 'N/BG,W+/N,B/BG,BG+/B,R/BG,W+/R,N+/BG,W/N,RB/BG,W+/RB', .t., 180} )
  close databases
  G_SUnLock(str_sem)
  restscreen(buf)
  return NIL

** 05.08.16
Function f1_FF_uslugi(oBrow)
  Local n := 46, oColumn, blk

  oColumn := TBColumnNew(' ���� �����', {|| mosu->shifr1 })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(' ���� ��', {|| mosu->shifr })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  if is_zf_stomat == 1
    oColumn := TBColumnNew('��', {|| iif(mosu->zf == 1, '��', '  ') })
    oColumn:colorBlock := blk
    oBrow:addColumn(oColumn)
    n -= 3
  endif
  oColumn := TBColumnNew(center('������������ ��㣨', n), {|| left(mosu->name, n) })
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ ��室 ^<Enter>^ ।���஢���� ^<Ins>^ ���������� ^<Del>^ 㤠����� ^<F2>^ ����')
  return NIL
  
** 09.09.18
Function f2_FF_uslugi(nKey, oBrow)
  Static sshifr := '          '
  LOCAL j := 0, k := -1, buf := save_maxrow(), buf1, fl := .f., rec, ;
        tmp_color := setcolor(), r1 := maxrow() - 10, c1 := 2

  do case
    case nKey == K_F2
      rec := recno()
      if (mshifr := input_value(18, 10, 20, 69, color1, ;
                '  ������ ����室��� ��� ��㣨 ��� ���᪠', ;
                sshifr, '@K@!')) != NIL
        sshifr := mshifr := transform_shifr(mshifr)
        set order to 3
        find (mshifr)
        if found()
          rec := recno()
          fl := .t.
        endif
        set order to 1
        if fl
          oBrow:goTop()
          goto (rec)
          k := 0
        else
          goto (rec)
          func_error(4, '��㣠 � ��஬ "' + alltrim(mshifr) + '" �� �������!')
        endif
      endif
    case nKey == K_INS .or. (nKey == K_ENTER .and. mosu->kod > 0)
      rec := f3_FF_uslugi(nKey)
      select MOSU
      oBrow:goTop()
      goto (rec)
      k := 0
    case nKey == K_DEL .and. mosu->kod > 0
      stat_msg('����! �ந�������� �஢�ઠ �� ����稥 㤠�塞�� ��㣨 � ��㣨� ����� ������.')
      mybell(0.1, OK)
      R_Use(dir_server + 'mo_hu', dir_server + 'mo_huk', 'HU')
      find (str(mosu->kod, 6))
      fl := found()
      hu->(dbCloseArea())
      if !fl
        R_Use(dir_server + 'mo_onkna', , 'NAPR') // �������ࠢ�����
        Locate for U_KOD == mosu->kod
        fl := found()
        napr->(dbCloseArea())
      endif
      select MOSU
      if fl
        func_error(4, '������ ��㣠 ����砥��� � ��㣨� ����� ������. �������� ����饭�!')
      elseif f_Esc_Enter(2, .t.)
        G_RLock(forever)
        replace mosu->kod with -1, ;
                mosu->name with '', tip with 0, ;
                mosu->shifr with '', mosu->shifr1 with ''
        UNLOCK
        Commit
        stat_msg('��㣠 㤠����!') ; mybell(1,OK)
        oBrow:goTop()
        k := 0
      endif
  endcase
  rest_box(buf)
  return k
  
  ** 31.01.17
  Function f3_FF_uslugi(nKey)
  Static menu_nul := {{'���', .f.}, {'��', .t.}}
  Local buf := savescreen(), r1 := maxrow()-9, ;
        k, tmp_color := setcolor(), ret := mosu->(recno())
  Private mkod, mname, mshifr, mshifr1, m1PROFIL, mPROFIL, mzf, m1zf, m1tip, ;
          mname1, gl_area := {r1+1, 0, maxrow()-1, maxcol(), 0}
  //
  m1tip     := IF(nKey==K_INS, 0, mosu->tip)
  mkod      := IF(nKey==K_INS, 0, mosu->kod)
  mname     := IF(nKey==K_INS, SPACE(65), mosu->name)
  mshifr    := if(nKey==K_INS, space(10), mosu->shifr)
  mshifr1   := if(nKey==K_INS, space(20), mosu->shifr1)
  m1PROFIL  := IF(nKey==K_INS, 0, mosu->profil)
  mPROFIL   := inieditspr(A__MENUVERT, glob_V002, m1PROFIL)
  m1zf      := if(nKey==K_INS, .f., (mosu->zf==1))
  mzf       := inieditspr(A__MENUVERT, menu_nul, m1zf)
  //
  SETCOLOR(color8)
  Scroll( r1, 0, maxrow()-1, maxcol() )
  @ r1, 0 to r1,maxcol()
  status_key('^<Esc>^ - ��室 ��� �����;  ^<PgDn>^ - ������')
  IF nKey == K_INS
    str_center(r1, ' ���������� ��㣨 ')
  ELSE
    str_center(r1, ' ������஢���� ')
  ENDIF
  f4_FF_uslugi(0)
  DO WHILE .T.
    SETCOLOR(cDataCGet)
    @ r1+1, 1 SAY '���� � ��� (�����)' get mshifr1 picture '@!' ;
             when empty(mshifr1) valid f4_FF_uslugi(1,nKey)
    @ r1+2, 1 SAY '������������ ��㣨 �� �ࠢ�筨�� �����ࠢ� (�����)'
    @ r1+3, 2 GET mname1 when .f. color color14
    @ r1+4, 1 SAY '���� ��㣨 (� ��)' get mshifr picture '@!' valid f4_FF_uslugi(2,nKey)
    @ r1+5, 1 SAY '������������ ��㣨' GET mname PICTURE '@S59'
    @ r1+6, 1 say '��䨫�' get MPROFIL ;
             reader {|x|menu_reader(x,tmp_V002,A__MENUVERT_SPACE, , , .f.)}
  if is_zf_stomat == 1
    @ r1+7, 1 SAY '���� �㡭�� ����' get mzf ;
                    reader {|x|menu_reader(x,menu_nul,A__MENUVERT, , , .f.)}
  endif
    myread()
    if LASTKEY() != K_ESC
      fl := .t.
      if empty(mshifr1)
        fl := func_error('�� ������ ��� �����ࠢ� (�����). ��� �����.')
      endif
      if fl
        mywait()
        select MOSU
        SET ORDER TO 2
        if nKey == K_INS
          FIND (STR(-1, 6))
          if found()
            G_RLock(forever)
          else
            AddRec(6)
          endif
          mkod := recno()
          mosu->kod := mkod
        else
          FIND (STR(mkod, 6))
          G_RLock(forever)
        endif
        mosu->name     := mname
        mosu->shifr    := mshifr
        mosu->shifr1   := mshifr1
        mosu->PROFIL   := m1PROFIL
        mosu->zf       := iif(m1zf, 1, 0)
        UnLock
        commit
        ret := mkod
      else
        loop
      ENDIF
    ENDIF
    exit
  ENDDO
  restscreen(buf)
  setcolor(tmp_color)
  select MOSU
  set order to 1
  Return ret
  
  ** 31.01.17
  Function f4_FF_uslugi(k,nKey)
  Local fl := .t., rec, v1
  select MOSU
  rec := recno()
  do case
    case k == 0 // ��। �室�� � GET
      mname1 := space(78)
      if !empty(mshifr1)
        if m1tip > 0
          mname1 := padr('㤠����', 78)
        else
          select LUSLF
          find (mshifr1)
          if found()
            mname1 := padr(luslf->name, 78)
            if empty(mname)
              mname := padr(mname1, 65)
            endif
          else
            mname1 := padr('�� �������', 78)
          endif
        endif
      endif
    case k == 1
      mshifr1 := transform_shifr(mshifr1)
      select LUSLF
      find (mshifr1)
      if found()
        if nKey == K_INS
          select MOSU
          set order to 4
          find (mshifr1)
          if found()
            fl := func_error(4, '����� ��� ����� 㦥 ����砥��� � �ࠢ�筨��!')
            mshifr1 := space(20)
          endif
        endif
        if fl
          mname1 := padr(luslf->name, 78)
          if empty(mname)
            mname := padr(mname1, 65)
          endif
          update_gets()
        endif
      else
        fl := func_error(1, '�� ������� ��㣠 � ⠪�� ��஬')
        mshifr1 := space(20)
      endif
    case k == 2
      mshifr := transform_shifr(mshifr)
      if !empty(mshifr)
        v1 := 0
        set order to 3
        find (mshifr)
        do while mosu->shifr == mshifr .and. !eof()
          if nKey == K_INS
            ++v1
          elseif recno() != rec
            ++v1
          endif
          skip
        enddo
        if v1 > 0
          fl := func_error(4, '����� ��� ��㣨 㦥 ����砥��� � �ࠢ�筨��!')
          mshifr := space(10)
        endif
        if fl
          R_Use(dir_server + 'uslugi', dir_server + 'uslugish', 'USL')
          find (mshifr)
          if found()
            fl := func_error(4, '����� ��� ��㣨 㦥 ����砥��� � �᭮���� �ࠢ�筨�� ���!')
            mshifr := space(10)
          endif
          dbCloseArea()
        endif
      endif
  endcase
  select MOSU
  set order to 1
  goto (rec)
  return fl
  
*********************************************************************************************************  
** ������஢���� �ࠢ�筨�� ���������� ��� (��� 㤮��⢠ ����� ������)
Function f_k_uslugi(r1)
  Local str_sem := '������஢���� ���������� ���'

  DEFAULT r1 TO 2
  Private pr1 := r1, pc1 := 2, pc2 := 77, fl_found := .t.
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'PERSO')
  G_Use(dir_server + 'uslugi_k', dir_server + 'uslugi_k', 'UK')
  go top
  if eof()
    fl_found := .f.
    keyboard chr(K_INS)
  endif
  Alpha_Browse(pr1, pc1, maxrow() - 2, pc2, 'f1_k_uslugi', color0, , , , , , , 'f2_k_uslugi', , ;
               {'�', '�', '�', , .t.} )
  close databases
  G_SUnLock(str_sem)
  return NIL
  
** ������஢���� �����樥�⮢ ��㤮񬪮�� ��� (���)
Function f_trkoef()
  Local uslugi := {{'kod',    'N', 4, 0}, ;
                   {'name',   'C', 65, 0}, ;
                   {'shifr',  'C', 10, 0}, ;
                   {'vkoef_v', 'N', 7, 4}, ;   // ��� - ��� ��� ���᫮��
                   {'akoef_v', 'N', 7, 4}, ;   // ���. - ��� ��� ���᫮��
                   {'vkoef_r', 'N', 7, 4}, ;   // ��� - ��� ��� ॡ����
                   {'akoef_r', 'N', 7, 4}, ;   // ���. - ��� ��� ॡ����
                   {'koef_v', 'N', 7, 4}, ;
                   {'koef_r', 'N', 7, 4}}
  Local k1, k2, buf := save_maxrow(), fl, ;
        fl_plat := is_task(X_PLATN), ; // ��� ������ ���
        str_sem := '������஢���� �����樥�⮢ - UCH_USL'

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  mywait()
  dbcreate(cur_dir + 'tmp', uslugi)
  use (cur_dir + 'tmp') alias tmp
  index on fsort_usl(shifr) to (cur_dir + 'tmp')
  if useUch_Usl() .and. R_Use(dir_server + 'uslugi', , 'USL')
    k1 := usl->(lastrec())
    k2 := uu->(lastrec())
    select UU
    do while k2 < k1
      G_RLock(.t., forever)
      replace kod with recno()
      unlock
      k2++
    enddo
    select USL
    set relation to str(kod, 4) into UU
    go top
    do while !eof()
      if usl->kod > 0
        fl := (usl->cena > 0 .or. usl->cena_d > 0)
        if !fl .and. fl_plat
          fl := (usl->pcena > 0 .or. usl->pcena_d > 0 .or. usl->dms_cena > 0)
        endif
        if !fl .and. (usl->is_nul .or. usl->is_nulp) // �᫨ �������� ���� ��㣨 ��� 業�
          fl := .t.
        endif
        if fl
          select TMP
          append blank
          tmp->kod     := usl->kod
          tmp->name    := usl->name
          tmp->shifr   := usl->shifr
          tmp->vkoef_v := uu->vkoef_v
          tmp->akoef_v := uu->akoef_v
          tmp->vkoef_r := uu->vkoef_r
          tmp->akoef_r := uu->akoef_r
          tmp->koef_v  := uu->koef_v
          tmp->koef_r  := uu->koef_r
        endif
      endif
      select USL
      skip
    enddo
    set relation to
    usl->(dbCloseArea())
    select TMP
    dbcommit()
    set relation to str(kod, 4) into UU
    go top
    do while empty(shifr) .and. !eof()
      skip
    enddo
    Alpha_Browse(0, 0, maxrow() - 1, 79, 'f1_trkoef', color0, ;
       '�᫮��� ������� ��㤮������ ��� ��� ������ � ��⥩', 'BG+/GR', ;
       .f., , , , 'f2_trkoef', , ;
       {'�', '�', '�', 'N/BG,W+/N,B/BG,BG+/B,GR+/BG,BG+/GR,R/BG,BG+/R', .t., 180} )
  endif
  close databases
  rest_box(buf)
  G_SUnLock(str_sem)
  return NIL
  
** �������� ����筠� ��㤮������� ���ᮭ���
Function f_trpers()
  Static si := 1
  Local i, arr_m, mtitle, k1, k2, buf := save_maxrow(), ;
        str_sem := '������஢���� �������� ��㤮������ - UCH_PERS'

  if (i := popup_prompt(T_ROW, T_COL + 5, si, {'�।�������� ���', ;
                                          '��� �� ������� �����'})) == 0
    return NIL
  endif
  si := i
  Private lgod := 0, lmes := 0
  if i == 1
    mtitle := '������� �।�������� ��� ���ᮭ���'
  else
    if (arr_m := year_month(T_ROW, T_COL + 5, , 3)) == NIL
      return NIL
    endif
    lgod := arr_m[1]
    lmes := arr_m[2]
    mtitle := '������� ��� ���ᮭ��� ' + arr_m[4]
  endif
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  mywait()
  if G_Use(dir_server + 'uch_pers', dir_server + 'uch_pers', 'UCHP') .and. ;
     R_Use(dir_server + 'mo_pers', , 'PERSO')
    index on str(kod, 4) to (cur_dir + 'tmp_pers') for kod > 0
    select UCHP
    set order to 0
    go top
    do while !eof()
      if empty(uchp->m_trud)
        DeleteRec(.t.)
      else
        select PERSO
        find (str(uchp->kod, 4))
        if !found()
          select UCHP
          DeleteRec(.t.)
        endif
      endif
      select UCHP
      skip
    enddo
    Commit
    set order to 1
    select PERSO
    go top
    do while !eof()
      select UCHP
      find (str(perso->kod, 4) + str(lgod, 4) + str(lmes, 2))
      if !found()
        AddRec(4)
        uchp->kod := perso->kod
        uchp->god := lgod
        uchp->mes := lmes
        UnLock
      endif
      select PERSO
      skip
    enddo
    Commit
    select UCHP
    set relation to str(kod, 4) into PERSO
    index on upper(perso->fio) to (cur_dir + 'tmp_uch') for god == lgod .and. mes == lmes
    set index to (cur_dir + 'tmp_uch'), (dir_server + 'uch_pers')
    go top
    Alpha_Browse(2, 2, maxrow() - 2, 77, 'f1_trpers',color0,mtitle, 'BG+/GR', ;
                 .f., , , , 'f2_trpers', , {, , , 'N/BG,W+/N,B/BG,BG+/B', .t., 180} )
  endif
  close databases
  rest_box(buf)
  G_SUnLock(str_sem)
  return NIL
  
** ������஢���� �ࠢ�筨�� ���, ����� �� ������ ���� ������� � ���� ����
Function f_ns_uslugi()
  Local str_sem, r1 := T_ROW

  Private pr1 := r1, pc1 := T_COL + 5, pc2 := T_COL + 5 + 33, fl_found := .t.
  str_sem := '������஢���� ��ᮢ���⨬�� ���'
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  G_Use(dir_server + 'ns_usl', , 'UK')
  index on upper(name) to (cur_dir + 'tmp_usl')
  go top
  if eof()
    fl_found := .f.
    keyboard chr(K_INS)
  endif
  Alpha_Browse(pr1, pc1, maxrow() - 2, pc2, 'f1_ns_uslugi', color0, , , , , , , 'f2_ns_uslugi', , ;
               {, , , , .t.} )
  close databases
  G_SUnLock(str_sem)
  return NIL
  
** ����/।���஢���� ���, � ������ �� �������� ��� (����⥭�)
Function f_usl_uva()
  Local t_arr[BR_LEN], mtitle := '��㣨, ��� �� �������� ��� (���.)'

  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := T_COL + 5
  t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 41
  t_arr[BR_OPEN] := {|| f1_usl_uva( , , 'open') }
  t_arr[BR_CLOSE] := {|| dbCloseAll() }
  t_arr[BR_SEMAPHORE] := mtitle
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := mtitle
  t_arr[BR_TITUL_COLOR] := 'B/BG'
  t_arr[BR_ARR_BROWSE] := { , , , , .t.}
  t_arr[BR_COLUMN] := {{ '   ����', {|| dbf1->shifr } }, ;
            { '��� ���?', {|| padc(if(dbf1->kod_vr == 1, '**', ''), 10) } }, ;
            { '���-� ���?', {|| padc(if(dbf1->kod_as == 1, '**', ''), 12) } }}
  t_arr[BR_EDIT] := {|nk, ob| f1_usl_uva(nk, ob, 'edit') }
  edit_browse(t_arr)
  return NIL
  
** ����/।���஢���� ���, ����� ����� ���� ������� 祫����� ⮫쪮 ࠧ � ����
Function f_usl_raz()
  Local buf := savescreen(), adbf, i, n_file := dir_server + 'usl1year' + smem

  Private fl_found := .f., arr_usl1year := {}
  if hb_fileExists(n_file)
    arr_usl1year := rest_arr(n_file)
  endif
  mywait()
  R_Use(dir_server + 'uslugi', dir_server + 'uslugish', 'USL')
  adbf := {{'kod', 'N', 4, 0}, ;
           {'shifr', 'C', 10, 0}, ;
           {'name', 'C', 64, 0}}
  dbcreate(cur_dir + 'tmp', adbf)
  use (cur_dir + 'tmp') new alias TMP
  index on fsort_usl(shifr) to (cur_dir + 'tmp')
  for i := 1 to len(arr_usl1year)
    fl_found := .t.
    select USL
    goto (arr_usl1year[i])
    select TMP
    append blank
    tmp->kod := arr_usl1year[i]
    tmp->shifr := usl->shifr
    tmp->name := usl->name
  next
  select TMP
  go top
  if !fl_found
    keyboard chr(K_INS)
  endif
  box_shadow(0, 2, 0, 77, 'GR+/RB', '���᮪ ���, ����� ࠧ�蠥��� ������� ⮫쪮 ࠧ � ����', , 0)
  Alpha_Browse(2, 1, maxrow() - 1, 77, 'f4_ns_uslugi', color0, , , .t., .t., , , 'f1_usl_raz', , ;
               {'�', '�', '�', 'N/BG,W+/N,B/BG', .t., 58} )
  close databases
  restscreen(buf)
  if f_Esc_Enter(1)
    arr_usl1year := {}
    use (cur_dir + 'tmp')
    go top
    do while !eof()
      if !empty(tmp->kod)
        aadd(arr_usl1year, tmp->kod )
      endif
      skip
    enddo
    save_arr(arr_usl1year, n_file)
  endif
  close databases
  return NIL
  
** 08.11.22
Function f5_uslugi(r1, c1)
  Local c2 := c1 + 50, str_sem := '������஢���� �㦡'

  Private pr1 := r1, pc1, pc2
  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  if c2 > 77
    c2 := 77
    c1 := 27
  endif
  pc1 := c1
  pc2 := c2
  G_Use(dir_server + 'slugba', dir_server + 'slugba', 'SL')
  go top
  if lastrec() == 0
    AddRec(3)
    UnLock
    keyboard chr(K_INS)
  elseif lastrec() == 1 .and. sl->shifr == 0 .and. empty(sl->name)
    keyboard chr(K_INS)
  endif
  Alpha_Browse(r1, c1, maxrow() - 2, c2, 'f51_uslugi', color0, , , , , , , 'f52_uslugi', , ;
             { , , , , .t.})
  dbCloseArea()
  G_SUnLock(str_sem)
  return NIL

**
Function f51_uslugi(oBrow)
  Local oColumn

  oColumn := TBColumnNew('����', {|| sl->shifr })
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center('������������ �㦡�', 40), {|| sl->name })
  oBrow:addColumn(oColumn)
  if type('pr1') == 'N'
    status_key('^<Esc>^ - ��室;  ^<Enter>^ - ।���஢����;  ^<Ins>^ - ����������;  ^<Del>^ - 㤠�����')
  else
    status_key('^<Esc>^ - ��室;  ^<Enter>^ - �롮� �㦡�')
  endif
  return NIL
  
  **
  Function f52_uslugi(nKey, oBrow)
  Local buf, fl := .f., rec, rec1, k := maxrow() - 7, tmp_color
  do case
    case nKey == K_INS .or. nKey == K_ENTER
      save screen to buf
      if nkey == K_INS .and. lastrec() == 1 .and. sl->shifr == 0 .and. empty(sl->name)
        colorwin(pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N')
      endif
      if nKey == K_ENTER
        rec := recno()
      endif
      Private mshifr, mname, gl_area := {1, 0,maxrow() - 1, 79, 0}, old_shifr
      old_shifr := mshifr := if(nKey == K_INS, 0, sl->shifr)
      mname := if(nKey == K_INS, space(40), sl->name)
      tmp_color := setcolor(cDataCScr)
      box_shadow(k, pc1 + 1, maxrow() - 3, pc2 - 1, , ;
                if(nKey==K_INS, '����������', '������஢����') + ' �㦡�', cDataPgDn)
      setcolor(cDataCGet)
      @ k + 1, pc1 + 3 say '���� �㦡�' get mshifr picture '999'
      @ k + 2,pc1 + 3 say '������������ �㦡�'
      @ k + 3,pc1 + 5 get mname valid func_empty(mname)
      status_key('^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����')
      myread()
      k := -1
      if lastkey() != K_ESC
        fl := .t.
        if nKey == K_ENTER .and. old_shifr != mshifr
          find (str(mshifr, 3))
          do while sl->shifr == mshifr .and. !eof()
            if recno() != rec
              fl := func_error(4, '��㦡� � ����� ��஬ 㦥 ��������� � ���� ������!')
              exit
            endif
            skip
          enddo
          goto (rec)
        endif
        if fl .and. f_Esc_Enter(1)
          mywait()
          if nKey == K_INS
            fl := .f.
            if lastrec() == 1
              go top
              if sl->shifr == 0 .and. empty(sl->name)
                G_RLock(forever)
                fl := .t.
              endif
            endif
            if !fl
              AddRec(3)
            endif
          else
            G_RLock(forever)
          endif
          replace sl->shifr with mshifr, sl->name with mname
          UNLOCK
          COMMIT
          if nKey == K_ENTER .and. old_shifr != mshifr
            G_Use(dir_server + 'uslugi', {dir_server + 'uslugisl'}, 'USL')
            do while .t.
              find (str(old_shifr, 3))
              if !found()
                exit
              endif
              G_RLock(forever)
              usl->slugba := mshifr
              UnLock
            enddo
            usl->(dbCloseArea())
            select SL
          endif
          oBrow:gotop()
          find (str(mshifr, 3))
          k := 0
        endif
      elseif nKey == K_INS .and. lastrec() == 1
        go top
        if sl->shifr == 0 .and. empty(sl->name)
          k := 1
        endif
      endif
      setcolor(tmp_color)
      restore screen from buf
      return k
    case nKey == K_DEL .and. !empty(sl->name) .and. f_Esc_Enter(2)
      R_Use(dir_server + 'uslugi', {dir_server + 'uslugisl'}, 'USL')
      find (str(sl->shifr, 3))
      fl := found()
      dbCloseArea()
      select SL
      if fl
        func_error(4, '������ �㦡� ��������� � �ࠢ�筨�� ���. �������� ����饭�!')
      else
        DeleteRec()
        return 0
      endif
  endcase
  return -1
  
  