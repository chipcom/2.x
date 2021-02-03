#include "set.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "..\_mylib_hbt\function.ch"
#include "..\_mylib_hbt\edit_spr.ch"
#include "..\chip_mo.ch"

#define CODE_KSLP   1
#define NAME_KSLP   2
#define NAMEF_KSLP  3
#define COEF_KSLP   4

#include "tbox.ch"

***** 29.01.21 �᫨ ����, ��१������ ���祭�� ���� � ���� � HUMAN_2
Function put_str_kslp_kiro(arr,fl)
  Local lpc1 := "", lpc2 := ""

  if len(arr) > 4 .and. !empty(arr[5])
    if year(human->k_data) != 2021  // added 29.01.2021
      lpc1 := lstr(arr[5,1])+","+lstr(arr[5,2],5,2)
      if len(arr[5]) >= 4
        lpc1 += ","+lstr(arr[5,3])+","+lstr(arr[5,4],5,2)
      endif
    endif
  endif
  if len(arr) > 5 .and. !empty(arr[6])
    lpc2 := lstr(arr[6,1])+","+lstr(arr[6,2],5,2)
  endif
  if !(padr(lpc1,20) == human_2->pc1 .and. padr(lpc2,10) == human_2->pc2)
    DEFAULT fl TO .t. // �����஢��� � ࠧ�����஢��� ������ � HUMAN_2
    select HUMAN_2
    if fl
      G_RLock(forever)
    endif

    // �������� ����� ����
    tmSel := select('HUMAN_2')
    if (tmSel)->(dbRlock())
      if year(human->k_data) != 2021  // added 29.01.2021
        human_2->pc1 := lpc1
      endif
      human_2->pc2 := lpc2
      (tmSel)->(dbRUnlock())
    endif
    select(tmSel)
    if fl
      UnLock
    endif
  endif
  return NIL

***** 01.02.2021
// �����頥� ���ᨢ ���� �� 㪠������ ����
function getKIROtable( dateSl )
  Local dbName, dbAlias := 'KIRO_'
  local tmp_select := select()
  local tmpKIRO := {}

  static aKIRO, loadKIRO := .f.

  if loadKIRO //�᫨ ���ᨢ ���� ������� ��୥� ���
    if (iy := ascan(aKIRO, {|x| x[1] == Year(dateSl) })) > 0 // ���
      return aKIRO[ iy, 2 ]
    endif
  endif

  if year(dateSl) == 2021 // ���� �� 2021 ���
    tmp_select := select()
    aKIRO := {}
    // tmpKIRO := {}
    dbName := '_mo1kiro'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(tmpKIRO, { (dbAlias)->CODE, (dbAlias)->NAME, (dbAlias)->NAME_F, (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    aadd(aKIRO, { Year(dateSl), tmpKIRO })
    loadKIRO := .t.
  else
    alertx('�� 㪠������ ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif
  return tmpKIRO

  // �����頥� ���ᨢ ���� �� 㪠������ ����
function getKSLPtable( dateSl )
  Local dbName, dbAlias := 'KSLP_'
  local tmp_select := select()
  local tmpKSLP := {}

  static aKSLP, loadKSLP := .f.

  if loadKSLP //�᫨ ���ᨢ ���� ������� ��୥� ���
    if (iy := ascan(aKSLP, {|x| x[1] == Year(dateSl) })) > 0 // ���
      return aKSLP[ iy, 2 ]
    endif
  endif

  if year(dateSl) == 2021 // ���� �� 2021 ���
    tmp_select := select()
    aKSLP := {}
    // tmpKSLP := {}
    dbName := '_mo1kslp'
    dbUseArea( .t., "DBFNTX", exe_dir + dbName, dbAlias , .t., .f. )

    (dbAlias)->(dbGoTop())
    do while !(dbAlias)->(EOF())
      aadd(tmpKSLP, { (dbAlias)->CODE, (dbAlias)->NAME, (dbAlias)->NAME_F, (dbAlias)->COEFF, (dbAlias)->DATEBEG, (dbAlias)->DATEEND })
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseArea())
    Select(tmp_select)
    aadd(aKSLP, { Year(dateSl), tmpKSLP })
    loadKSLP := .t.
  else
    alertx('�� 㪠������ ���� ' + DToC(dateSl) + ' ���� ����������!')
  endif
  return tmpKSLP

// private mKSLP := '1,3,4,5', m1KSLP := "1,3,4,5"
// @ ++r,1 say "����" get mKSLP ;
//         reader {|x|menu_reader(x,{{|k,r,c|selectKSLP(k,r,c,sys_date,CToD('22/01/2014'))}},A__FUNCTION,,,.f.)}

// 31.01.2021
// �㭪�� �롮� ��⠢� ����, �����頥� { ��᪠,��ப� ������⢠ ���� }, ��� nil
function selectKSLP( k, r, c, dateBegin, dateEnd, DOB, shifrUsl )
  // k - ���祭�� m1KSLP (��࠭�� ����)
  // r - ��ப� �࠭�
  // c - ������� �࠭�
  // dateBegin - ��� ��砫� �����祭���� ����
  // dateEnd - ��� ����砭�� �����祭���� ����
  // DOB - ��� ஦����� ��樥��

  Local mlen, t_mas := {}, ret, ;
    i, tmp_select := select()
  Local r1 := 0 // ���稪 ����ᥩ
  Local strArr := '', age

  Local m1var := '', s := "", countKSLP := 0
  local row, oBox
  local aKSLP := getKSLPtable( dateEnd )
  local aa := list2arr(k) // ����稬 ���ᨢ ��࠭��� ����
  local nLast, srok := dateEnd - dateBegin
  local sh := lower(substr(shifrUsl,1,2))
  local recN, permissibleKSLP := {}, isPermissible
  local sAsterisk := ' * ', sBlank := '   '

  default DOB to sys_date
  default dateBegin to sys_date
  default dateEnd to sys_date

  if sh != 'st' .and. sh != 'ds'
    return nil
  else
    recN := ('lusl')->(RecNo())
    ('lusl')->(dbGoTop())
    if ('lusl')->(dbSeek(shifrUsl))
      permissibleKSLP := list2arr(('lusl')->KSLPS)
    endif
  endif
  
  age := count_years(DOB, dateEnd)
  
  for each row in aKSLP
    r1++

    isPermissible := ascan(permissibleKSLP, row[ CODE_KSLP ]) > 0

    if (ascan(aa, {|x| x == row[ CODE_KSLP ] }) > 0) .and. isPermissible
      strArr := sAsterisk
    else
      strArr := sBlank
    endif

    if row[ CODE_KSLP ] == 1  // ���� 75 ���
      if (age >= 75) .and. isPermissible
        strArr := sAsterisk
      else
        strArr := sBlank
      endif
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 3 .and. isPermissible  // ���� ��������� �।�⠢�⥫�
      if (age < 4)
        strArr := sAsterisk
        strArr += row[ NAME_KSLP ]
      elseif (age < 18)
        strArr += row[ NAME_KSLP ]
      else
        strArr := sBlank
        strArr += row[ NAME_KSLP ]
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 4 .and. isPermissible  // ���㭨���� ���
      if (age < 18)
        strArr += row[ NAME_KSLP ]
      else
        strArr := sBlank
        strArr += row[ NAME_KSLP ]
      endif
      aadd(t_mas, { strArr, (age < 18), row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 9 // ���� ᮯ������騥 �����������
      if isPermissible  // .and. strArr == sAsterisk
        strArr := sAsterisk
      else
        strArr := sBlank
      endif
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, .t., row[ CODE_KSLP ] })
    elseif row[ CODE_KSLP ] == 10 .and. isPermissible // ��祭�� ��� 70 ���� ᮣ��᭮ ������樨
      strArr := iif(srok > 70, sAsterisk, sBlank)
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, .f., row[ CODE_KSLP ] })
  else
      strArr += row[ NAME_KSLP ]
      aadd(t_mas, { strArr, isPermissible, row[ CODE_KSLP ] })
    endif
  next

  strStatus := '^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - �⬥��� / ���� �⬥��'

  mlen := len(t_mas)

  // �ᯮ��㥬 popupN �� ������⥪� FunLib
  if (ret := popupN(5,20,15,61,t_mas,i,color0,.t.,"fmenu_readerN",,;
      "�⬥��� ����",col_tit_popup,,strStatus)) > 0
    for i := 1 to mlen
      if "*" == substr(t_mas[i, 1],2,1)
        m1var += alltrim(str(t_mas[i, 3])) + ','
        countKSLP += 1
      endif
    next
    if (nLast := RAt(',', m1var)) > 0
      m1var := substr(m1var, 1, nLast - 1)  // 㤠��� ��᫥���� �� �㦭�� ','
    endif
    s := m1var
  endif

  Select(tmp_select)

  Return iif(ret==0, NIL, {m1var,s})

// �����頥� �㬬� �⮣����� ���� �� ��᪥ ���� � ��� ����
function calcKSLP(cKSLP, dateSl)
  // cKSLP - ��ப� ��࠭��� ����
  // dateSl - ��� �����祭���� ����
  local summ := 0, i
  local fl := .f.
  local arrKSLP := getKSLPtable( dateSl )
  Local maxKSLP := 1.8  // �� ������樨 �� 2021 ���

  for i := 1 to len(cKSLP)
    if SubStr(cKSLP,i,1) == '1'
      if ! fl
        summ += arrKSLP[i, 4]
        fl := .t.
      else
        summ += (arrKSLP[i, 4] - 1)
      endif
    endif
  next
  if summ > maxKSLP
    summ := maxKSLP
  endif
  return summ

  ***** 01.02.21 
Function f_cena_kiro(/*@*/_cena, lkiro, dateSl )
  // _cena - �����塞�� 業�
  // lkiro - �஢��� ����
  // dateSl - ��� ����
  Local _akiro := {0,1}
  local aKIRO, i

  if year(dateSl) == 2021
    aKIRO := getKIROtable( dateSl )
    if (i := ascan(aKIRO, {|x| x[1] == lkiro })) > 0
      if between_date(aKIRO[i, 5], aKIRO[i, 6], dateSl)
        _akiro := { lkiro, aKIRO[i, 4] }
      endif
    endif
  else
    do case
      case lkiro == 1 // ����� 4-� ����, �믮����� ����.����⥫��⢮
        _akiro := {lkiro,0.8}
      case lkiro == 2 // ����� 4-� ����, ����.��祭�� �� �஢�������
        _akiro := {lkiro,0.2}
      case lkiro == 3 // ����� 3-� ����, �믮����� ����.����⥫��⢮, ��祭�� ��ࢠ��
        _akiro := {lkiro,0.9}
      case lkiro == 4 // ����� 3-� ����, ����.��祭�� �� �஢�������, ��祭�� ��ࢠ��
        _akiro := {lkiro,0.9}
      case lkiro == 5 // ����� 4-� ����, ��ᮡ���� ������樨 �� ���� �९���
        _akiro := {lkiro,0.2}
      case lkiro == 6 // ����� 3-� ����, ��ᮡ���� ������樨 �� ���� �९���, ��祭�� ��ࢠ��
        _akiro := {lkiro,0.9}
    endcase
  endif
  _cena := round_5(_cena*_akiro[2],0)  // ���㣫���� �� �㡫�� � 2019 ����
  return _akiro

***** 30.01.21 ��।����� ����-� ᫮����� ��祭�� ��樥�� � �������� 業�
Function f_cena_kslp(/*@*/_cena,_lshifr,_date_r,_n_data,_k_data,lkslp,arr_usl,lPROFIL_K,arr_diag,lpar_org,lad_cr)
  Static s_1_may := 0d20160430, s_18 := 0d20171231, s_19 := 0d20181231
  static s_20 := 0d20201231
  Static s_kslp17 := {;
    {1,1.1, 0,  3},;   // �� 4 ���
    {2,1.1,75,999};    // 75 ��� � ����
   }
  Static s_kslp16 := {;
    {1,1.1 , 0,  3},;   // �� 4 ���
    {2,1.05,75,999};    // 75 ��� � ����
   }
  Local i, j, vksg, y := 0, fl, ausl := {}, s_kslp, _akslp := {}, sop_diag
  local countDays := _k_data - _n_data // ���-�� ���� ��祭��

  local savedKSLP, newKSLP := '', nLast
  local nameFunc := '', argc, row

  DEFAULT lad_cr TO space(10)

  _lshifr := alltrim(_lshifr) // ��७��

  if _k_data > s_20
    if empty(lkslp)
      return _akslp
    endif
    // �.3 ������樨
    // ������ ��樥�� ��।������ �� ������ ����㯫���� �� ��樮��୮� ��祭��.
    // �� ��砨 �ਬ������ ���� (�� �᪫�祭��� ����1) �����࣠���� �ᯥ�⭮�� ����஫�.
    count_ymd( _date_r, _n_data, @y )
    lkslp := list2arr(lkslp)  // �८�ࠧ㥬 ��ப� �����⨬�� ���� � ���ᨢ
    savedKSLP := iif(empty(HUMAN_2->PC1), "'"+"'", "'" + alltrim(HUMAN_2->PC1) + "'")  // ����稬 ��࠭���� ����

    argc := '(' + savedKSLP + ',' + ;
    "'" + dtoc(_date_r) + "'," + "'" + dtoc(_n_data) + "'," + ;
    lstr(lPROFIL_K) + ',' + "'" + _lshifr + "'," + lstr(lpar_org) + ',' + ;
    "'" + arr2SlistN(arr_diag) + "'," + lstr(countDays) + ')'

  for each row in getKSLPtable( _k_data )
      nameFunc := 'conditionKSLP_' + alltrim(str(row[1],2)) + '_21'
      nameFunc := namefunc + argc

      if ascan( lkslp, row[1]) > 0 .and. &nameFunc
        newKSLP += alltrim(str(row[1],2)) + ','
        aadd(_akslp, row[1])
        aadd(_akslp,row[4])
      endif
    next
    if (nLast := RAt(',', newKSLP)) > 0
      newKSLP := substr(newKSLP, 1, nLast - 1)  // 㤠��� ��᫥���� �� �㦭�� ','
    endif

    // ��⠭���� 業� � ��⮬ ����
    if !empty(_akslp)
      _cena := round_5(_cena*ret_koef_kslp_21(_akslp),0)  // � 2019 ���� 業� ���㣫���� �� �㡫��

      if year(_k_data) == 2021
        // �������� ����� ����
        tmSel := select('HUMAN_2')
        if (tmSel)->(dbRlock())
          HUMAN_2->PC1 := newKSLP
          (tmSel)->(dbRUnlock())
        endif
        select(tmSel)
      endif
    endif

  elseif _k_data > s_19  // � 2019 ����
    if !empty(lkslp)
      if _lshifr == "ds02.005" // ���, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // ���ᨢ ���������
          else
            aadd(ausl,alltrim(arr_usl[i]))    // ���ᨢ ��������
          endif
        next i
        j := 0 // ���� - 1 �奬�
        if ascan(ausl,"A11.20.031") > 0  // �ਮ
          j := 13  // 6 �奬�
          if ascan(ausl,"A11.20.028") > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // ���� �⠯
          j := 12  // 3 �奬�
          if ascan(ausl,"A11.20.036") > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          elseif ascan(ausl,"A11.20.028") > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
        endif
        if !empty(_akslp) .and. _k_data > 0d20191231 // � 2020 ����
          _akslp[1] += 3 // �.�. � 2020 ���� ���� ��� ��� 15,16,17
        endif
      else // ��⠫�� ���
        s_kslp := {;
          { 1,1.10, 0,  0},;  // �� 1 ����
          { 2,1.10, 1,  3},;  // �� 1 �� 3 ��� �����⥫쭮
          { 4,1.02,75,999},;  // 75 � ����
          { 5,1.10,60,999};   // 60 � ���� � ��⥭��
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0 // �⮨� ����� ���� � ��࠭��� ���
            if between(y,s_kslp[i,3],s_kslp[i,4])
              fl := .t.
              if lkslp[j] == 4
                fl := (lprofil_k != 16 ; // ��樥�� ����� �� �� ��஭⮫����᪮� �����
                        .and. !(_lshifr == "st38.001"))
              elseif lkslp[j] == 5
                sop_diag := aclone(arr_diag)
                del_array(sop_diag,1)
                fl := (lprofil_k == 16 .and. ; // ��樥�� ����� �� ��஭⮫����᪮� �����
                        !(_lshifr == "st38.001") .and. ;//!(alltrim(arr_diag[1]) == "R54") .and. ; // � �᭮��� ��������� �� <R54-������>
                        ascan(sop_diag, {|x| alltrim(x) == "R54"}) > 0 ) // � ᮯ.��������� ���� <R54-������>
              endif
              if fl
                aadd(_akslp,s_kslp[i,1])
                aadd(_akslp,s_kslp[i,2])
                exit
              endif
            endif
          endif
        next
        if ascan(lkslp,11) > 0 .and. lpar_org > 1 // ࠧ�襭� ����=11 � ������� ���� �࣠��
          aadd(_akslp,11)
          aadd(_akslp,1.2)
        endif
        if ascan(lkslp,18) > 0 .and. "cr6" $ lad_cr // ࠧ�襭� ����=18 � ��� ᫮����� COVID-19
          aadd(_akslp,18)
          aadd(_akslp,1.2)
        endif
        if !empty(_akslp)
          _cena := round_5(_cena*ret_koef_kslp(_akslp),0)  // � 2019 ���� 業� ���㣫���� �� �㡫��
        endif
      endif
    endif
  elseif _k_data > s_18  // � 2018 ����
    if !empty(lkslp)
      if _lshifr == "2005.0" // ���, lkslp = 12,13,14
        s_kslp := {;
          {12,0.60},;
          {13,1.10},;
          {14,0.19};
        }
        for i := 1 to len(arr_usl)
          if valtype(arr_usl[i]) == "A"
            aadd(ausl,alltrim(arr_usl[i,1]))  // ���ᨢ ���������
          else
            aadd(ausl,alltrim(arr_usl[i]))    // ���ᨢ ��������
          endif
        next i
        j := 0 // ���� - 1 �奬�
        if ascan(ausl,"A11.20.031") > 0  // �ਮ
          j := 13  // 6 �奬�
          if ascan(ausl,"A11.20.028") > 0 // ��⨩ �⠯
            j := 0   // 2 �奬�
          endif
        elseif ascan(ausl,"A11.20.025.001") > 0  // ���� �⠯
          j := 12  // 3 �奬�
          if ascan(ausl,"A11.20.036") > 0  // �������騩 ��ன �⠯
            j := 12  // 4 �奬�
          elseif ascan(ausl,"A11.20.028") > 0  // �������騩 ��⨩ �⠯
            j := 12  // 5 �奬�
          endif
        elseif ascan(ausl,"A11.20.030.001") > 0  // ⮫쪮 �⢥��� �⠯
          j := 14  // 7 �奬�
        endif
        if (i := ascan(s_kslp, {|x| x[1] == j})) > 0
          aadd(_akslp,s_kslp[i,1])
          aadd(_akslp,s_kslp[i,2])
          _cena := round_5(_cena*s_kslp[i,2],1)
        endif
      else // ��⠫�� ���
        s_kslp := {;
          { 1,1.10, 0,  0},;  // �� 1 ����
          { 2,1.10, 1,  3},;  // �� 1 �� 3 ��� �����⥫쭮
          { 4,1.05,75,999},;  // 75 � ����
          { 5,1.10,60,999};   // 60 � ���� � ��⥭��
        }
        count_ymd(_date_r,_n_data,@y)
        lkslp := list2arr(lkslp)
        for j := 1 to len(lkslp)
          if (i := ascan(s_kslp, {|x| x[1] == lkslp[j]})) > 0
            if between(i,1,5) .and. between(y,s_kslp[i,3],s_kslp[i,4])
              aadd(_akslp,s_kslp[i,1])
              aadd(_akslp,s_kslp[i,2])
              _cena := round_5(_cena*s_kslp[i,2],1)
              exit
            endif
          endif
        next
      endif
    endif
  elseif _k_data > s_1_may ;                 // � 1 ��� 2016 ����
              .and. left(_lshifr,1) == '1' ; // ��㣫������ ��樮���
              .and. !("." $ _lshifr)         // �� ��� ���
    count_ymd(_date_r,_n_data,@y)
    vksg := int(val(right(_lshifr,3))) // ��᫥���� �� ���� - ��� ���
    if (fl := vksg < 900) // �� ������
      if year(_k_data) > 2016
        s_kslp := s_kslp17
        if y < 1 .and. between(vksg,105,111) // �� 1 ���� � ����� ���� �� ஦�����
          fl := .f.
        endif
      else
        s_kslp := s_kslp16
      endif
      if fl
        for i := 1 to len(s_kslp)
          if between(y,s_kslp[i,3],s_kslp[i,4])
            aadd(_akslp,s_kslp[i,1])
            aadd(_akslp,s_kslp[i,2])
            _cena := round_5(_cena*s_kslp[i,2],1)
            exit
          endif
        next
      endif
    endif
  endif
  return _akslp
  
***** 26.01.21 ������ �⮣��� ���� ��� 2021 ����
Function ret_koef_kslp_21(akslp)
  Local k := 1  // ���� ࠢ�� 1

  if valtype(akslp) == "A" .and. len(akslp) >= 2
    for i := 1 TO len(akslp) STEP 2
      if i == 1
        k := akslp[2]
      else
        k += (akslp[i + 1] - 1)
      endif
    next
  endif
  if k > 1.8
    k := 1.8  // ᮣ��᭮ �.3 ������樨
  endif
  return k

***** 03.02.21 ������ �⮣��� ���� ��� 2021 ����
Function ret_koef_kslp_21_XML(akslp, tKSLP)
  Local k := 1  // ���� ࠢ�� 1
  local iAKSLP

  if valtype(akslp) == "A"
    for iAKSLP := 1 to len(akslp)
      if (cKSLP := ascan(tKSLP, {|x| x[1] == akslp[ iAKSLP ] })) > 0
        // mo_add_xml_stroke( oSLk, "ID_SL", lstr(akslp[ iAKSLP ] ) )
        // mo_add_xml_stroke( oSLk, "VAL_C", lstr( tKSLP[ cKSLP, 4 ], 7, 5 ) )
        k += (tKSLP[ cKSLP, 4 ] - 1)
      endif
    next
  endif
  if k > 1.8
    k := 1.8  // ᮣ��᭮ �.3 ������樨
  endif
  return k

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=1 ��� 2021 ����
function conditionKSLP_1_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // ����=1 ��樥��� ���� 75 ���
  count_ymd( ctod(DOB), ctod(n_date), @y )
  if y > 75
    if (profil != 16 .and. ! (lshifr == "st38.001"))
      fl := .t.
    endif
  endif
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=3 ��� 2021 ����
function conditionKSLP_3_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // ����=3 ᯠ�쭮� ���� ��������� �।�⠢�⥫�, ����� ������
  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if between(y, 0, 18) .and. ascan(aKSLP_, 3) > 0
    // �㭪� 3.1.1
    // �।��⠢����� ᯠ�쭮�� ���� � ��⠭�� ��������� �।�⠢�⥫�, �� ������ 
    // ॡ���� ���� 4 ���, �����⢫���� �� ����稨 ����樭᪨� ��������� � 
    // ��ଫ���� ��⮪���� ��祡��� �����ᨨ � ��易⥫�� 㪠������ � ��ࢨ筮� 
    // ����樭᪮� ���㬥��樨.
    fl := .t.
    endif
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=4 ��� 2021 ����
function conditionKSLP_4_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f., y

  // ����=4 ���㭨���� ���, ����� ������
  count_ymd( ctod(DOB), ctod(n_date), @y )
  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  if between(y, 0, 18) .and. ascan(aKSLP_, 4) > 0
    // �㭪� 3.1.2
    // ���� �ਬ������ � ����� �᫨ �ப� �஢������ ��ࢮ� ���㭨��樨 ��⨢ 
    // �ᯨ��୮-ᨭ�⨠�쭮� ����᭮� (���) ��䥪樨 ᮢ������ �� �६��� � 
    // ��ᯨ⠫���樥� �� ������ ��祭�� ����襭��, ���������� � ��ਭ�⠫쭮� 
    // ��ਮ��, ������ ���������� � ���㭨��樨.
    fl := .t.
  endif
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=5 ��� 2021 ����
function conditionKSLP_5_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  // ����=5 ࠧ����뢠��� �������㠫쭮�� ����, ����� ������
  if ascan(aKSLP_,5) > 0
    fl := .t.
  endif
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=6 ��� 2021 ����
function conditionKSLP_6_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  // ����=6 ��⠭�� ���ࣨ�᪨� ����樨
  if ascan(aKSLP_,6) > 0
    // �㭪� 3.1.3
    // ���祭� ��⠭��� (ᨬ��⠭���) ���ࣨ�᪨� ����⥫���, �믮��塞�� �� 
    // �६� ����� ��ᯨ⠫���樨, �।�⠢��� � ⠡���:        
    fl := .t.
  endif
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=7 ��� 2021 ����
function conditionKSLP_7_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  // ����=7 ���� �࣠�� � ������� ���� �࣠��
  if lpar_org > 1
    // �㭪� 3.1.4
    // � ����� ������ 楫�ᮮ�ࠧ�� �⭮��� ����樨 �� ����� �࣠���/����� ⥫�,
    // �� �믮������ ������ ����室���, � ⮬ �᫥ ��ண����騥 ��室�� ���ਠ��.
    // ���祭� ���ࣨ�᪨� ����⥫���, �� �஢������ ������ �����६���� �� ����
    // ����� �࣠��� ����� ���� �ਬ���� ����, �।�⠢��� � ⠡���:
    fl := .t.
  endif
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=8 ��� 2021 ����
function conditionKSLP_8_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  local fl := .f.

  aKSLP_ := list2arr(aKSLP)  // �८�ࠧ㥬 ��ப� ��࠭��� ���� � ���ᨢ
  // ���� = 8 ��⨬��஡��� �࠯��, ����� ������
  if ascan(aKSLP_,8) > 0
      // �㭪� 3.1.5
    // � ����� ��祭�� ��樥�⮢ � ��樮����� �᫮���� �� ������������ � �� 
    // �᫮�������, �맢����� ���ம࣠������� � ��⨡��⨪�१��⥭⭮����, � ⠪�� 
    // � ����� ��祭�� �� ������ ���������� ������� �ਬ������ ���� � ᮮ⢥��⢨� 
    // � �ᥬ� ����᫥��묨 ����ﬨ:
    //  1)�����稥 ��䥪樮����� �������� � ����� ����10, �뭥ᥭ���� � ������᪨� 
    //    ������� (�⮫��� �����஢�� ��㯯 ?�᭮���� �������? ��� ?������� �᫮������?);
    //  2)�����稥 १���⮢ ���஡�������᪮�� ��᫥������� � ��।������� 
    //    ���⢨⥫쭮�� �뤥������ ���ம࣠������ � ��⨡���ਠ��� �९��⠬ 
    //    �/��� ��⥪樨 �᭮���� ����ᮢ ��ࡠ������� (�ਭ���, ��⠫����⠫��⠬���),
    //    ���⢥ত���� ���᭮�������� �����祭�� �奬� ��⨡���ਠ�쭮� �࠯�� 
    //    (�।���������� ����稥 १���⮢ �� ������ �����襭�� ���� ��ᯨ⠫���樨, 
    //    � ⮬ �᫥ ��ࢠ�����);
    //  3)��ਬ������ ��� ������ ������ ������⢥����� �९��� � ��७�ࠫ쭮� �ଥ 
    //    �� ����� ��� � ��⠢� �奬 ��⨡���ਠ�쭮� �/��� ��⨬�����᪮� �࠯�� 
    //    � �祭�� �� ����� 祬 5 ��⮪:        
    fl := .t.
  endif
  return fl


***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=9 ��� 2021 ����
function conditionKSLP_9_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
    // arr_diag - ���ᨢ ���������, 1 ����� - �᭮���� �������,
  //   ��⠫�� ᮯ������騥 � �᫮������
  //
  // �������� �����騥 �� ���� 9
  // �㭪� 3.1.6
  //  � ⠪�� ᮯ������騬 ����������� � �᫮������ ����������� �⭮�����:
  //    ? ����� ������ ⨯� 1 � 2 (E10.0-E10.9; E11.0-E11.9);
  //    ? �����������, ����祭�� � ���祭� ।��� (��䠭���) �����������, 
  //      ࠧ��饭�� �� ��樠�쭮� ᠩ� ��������⢠ ��ࠢ���࠭���� ��1;
  //    ? ����ﭭ� ᪫�஧ (G35);
  //    ? �஭��᪨� �������� ������ (C91.1);
  //    ? ����ﭨ� ��᫥ �࠭ᯫ���樨 �࣠��� � (���) ⪠��� 
  //      (Z94.0; Z94.1; Z94.4; Z94.8);
  //    ? ���᪨� �ॡࠫ�� ��ࠫ�� (G80.0-G80.9);
  //    ? ���/����, �⠤�� 4� � 4�, ����� (B20 ? B24);
  //    ? ��ਭ�⠫�� ���⠪� �� ���-��䥪樨, ��� (Z20.6).
  // �� �ਬ������ ����9 � ��易⥫쭮� ���浪� � ��ࢨ筮� ����樭᪮� 
  // ���㬥��樨 ��ࠦ����� ��ய���� �஢����� �� ������ ��祭�� 
  // ���㪠������ �殮��� ᮯ������饩 ��⮫���� (���ਬ��: �������⥫�� 
  // ��祡��-���������᪨� ��ய����, �����祭�� ������⢥���� �९��⮢, 
  // 㢥��祭�� �ப� ��ᯨ⠫���樨 � �.�.), ����� ��ࠦ��� �������⥫�� 
  // ������ ����樭᪮� �࣠����樨 �� ��祭�� ������� ��樥��. 
  local diag, i := 0, tmp
  local inclDIAG := {;
    "E10.0", "E10.1", "E10.2", "E10.3", "E10.4", "E10.5", "E10.6", "E10.7", "E10.8", "E10.9", ;
    "E11.0", "E11.1", "E11.2", "E11.3", "E11.4", "E11.5", "E11.6", "E11.7", "E11.8", "E11.9", ;
    "G35", "C91.1", "Z94.0", "Z94.1", "Z94.4", "Z94.8", ;
    "G80.0", "G80.1", "G80.2", "G80.3", "G80.4", "G80.8", "G80.9", ;
    "B20", "B21", "B22", "B23", "B24", ;
    "Z20.6";
  }
  local fl := .f., aDiagnozis

  aDiagnozis := Slist2arr(arr_diag)  // �८�ࠧ㥬 ��ப� ��࠭��� ��������� � ���ᨢ

  for each diag in aDiagnozis
    i++
    if i == 1
      loop
    endif
    if upper(substr(diag,1,1)) == 'B' // ��-� � ���
      tmp := upper(substr(diag,1,3))
    else
      tmp := upper(diag)
    endif
    if ascan(inclDIAG, diag) > 0
      fl := .t.
      exit
    endif
  next
  return fl

***** 30.01.21 �஢�ઠ ��㢨� ��� �ਬ������ ����=10 ��� 2021 ����
// function conditionKSLP_10_21( par )
function conditionKSLP_10_21(aKSLP, DOB, n_date, profil, lshifr, lpar_org, arr_diag, duration)
  // duration - �த����⥫쭮��� ��祭�� � ����
  // lshifr - ��� ��㣨 ���
  //
  // �㭪� 3.1.7
  // �ࠢ��� �⭥ᥭ�� ��砥� � ᢥ�夫�⥫�� �� �����࠭����� �� ���, 
  // ��ꥤ����騥 ��砨 �஢������ ��祢�� �࠯��, � ⮬ �᫥ � ��⠭�� 
  // � ������⢥���� �࠯��� (st19.075-st19.089, ds19.050-ds19.062), 
  // �.�. 㪠����� ��砨 �� ����� ������� ᢥ�夫�⥫�묨 � ����稢����� 
  // � �ਬ������� ����10.
  //
  // ��㣨 ��� �᪫�祭�� ��� ���� 10
  local exclKSG := {"st19.075", "st19.076", "st19.077", "st19.078", "st19.079", ;
    "st19.080", "st19.081", "st19.082", "st19.083", "st19.084", "st19.085", ;
    "st19.086", "st19.087", "st19.088", "st19.089",; 
    "ds19.050", "ds19.051", "ds19.052", "ds19.053", "ds19.054", "ds19.055", ;
    "ds19.056", "ds19.057", "ds19.058", "ds19.059", "ds19.060", "ds19.061", ;
    "ds19.062" }
  local fl := .f.

  // if ( par[8] > 70 ) .and. ( ascan(exclKSG, par[5]) == 0 )
  if ( duration > 70 ) .and. ( ascan(exclKSG, lshifr) == 0 )
    fl := .t.
  endif
  return fl