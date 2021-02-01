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
      if isPermissible .and. strArr == sAsterisk
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
      aadd(tmpKSLP, { (dbAlias)->CODE, (dbAlias)->NAME, (dbAlias)->NAME_F, (dbAlias)->COEFF })
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

