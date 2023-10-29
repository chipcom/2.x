#include 'common.ch'
#include 'chip_mo.ch'

function defenitionKSG(DOB, gender, dBegSl, dEndSl, uslOK, mDiag, aDiagAdd, aDiagOsl, aFedUsluga, aAdCrit, aFr)
  // DOB - ��� ஦����� ��樥��
  // gender - ��� ��樥�� (1-��᪮�, 2-���᪨�)
  // dBegSl - ��� ��砫� ����
  // dEndSl - ��� ����砭�� ����
  // uslOK - �᫮��� �������� (��㣫������ ��� ������� ��樮���)
  // mDiag - ��� �� ���-10 �᭮����� ��������
  // aDiagAdd - ᯨ᮪ �� ���-10 �������⥫��� ��������� 
  // aDiagOsl - ᯨ᮪ �� ���-10 ��������� �᫮������
  // aFedUsluga - ᯨ᮪ �� ������������ 䥤�ࠫ��� ���
  // aAdCrit - ᯨ᮪ �������⥫��� ���ਥ�
  // aFr - �������� �ࠪ権
  Local _mo_usl := { ;
      {'SHIFR',      'C',     10,      0}, ;
      {'kz',         'N',      7,      3}, ;
      {'PROFIL',     'N',      2,      0}, ;
      {'DS',         'C',      6,      0}, ;
      {'DS1',        'M',     10,      0}, ;
      {'DS2',        'M',     10,      0}, ;
      {'SY',         'C',     20,      0}, ;
      {'AGE',        'C',      1,      0}, ;
      {'SEX',        'C',      1,      0}, ;
      {'LOS',        'C',      2,      0}, ;
      {'AD_CR',      'C',     20,      0}, ;
      {'AD_CR1',     'C',     20,      0}, ;
      {'DATEBEG',    'D',      8,      0}, ;
      {'DATEEND',    'D',      8,      0}, ;
      {'NS',         'N',      6,      0}, ;
      {'PRIOR',      'N',      6,      0}, ;
      {'ZATR',       'N',      6,      0} ;
    }
  local aRet := {}
  local aliasK006 := 'K006', aliasTMP := '__T'
  local cUslOk, vid_age, cGender, cDiag, iScan, i := 0

  default DOB to date()
  default gender to 1
  default dBegSl to date()
  default dEndSl to date()
  default uslOK to USL_OK_HOSPITAL  // ��㣫������ ��樮���

  if isnil(aDiagAdd)
    aDiagAdd := {}
  endif
  if isnil(aDiagOsl)
    aDiagOsl := {}
  endif
  if isnil(aFedUsluga)
    aFedUsluga := {}
  endif
  vid_age := vidAge(DOB, dBegSl, dEndSl)
  cUslOk := iif(uslOK == USL_OK_HOSPITAL, 'st', 'ds')
  cGender := iif(gender == 1, '1', '2')
  mDiag := upper(mDiag)
  cDiag := substr(mDiag, 1, 3)
  dbcreate('d:\_mo\2.x\test_ksg\tmp_u', _mo_usl)
  G_Use( 'd:\_mo\2.x\test_ksg\tmp_u', , aliasTMP, , .t.,  )


  (aliasK006)->(dbGoTop())
  do while !(aliasK006)->(Eof())

    if substr((aliasK006)->shifr, 1, 2) != cUslOk // �⡨ࠥ� �� �᫮��� �������� ���. �����
      (aliasK006)->(dbSkip())
      loop
    endif
    if !empty((aliasK006)->AGE) .and. ((aliasK006)->AGE != vid_age)     // �롮ઠ �� ��㯯� ������
      (aliasK006)->(dbSkip())
      loop
    endif
    if !empty((aliasK006)->SEX) .and. ((aliasK006)->SEX != cGender)     // �롮ઠ �� ����
      (aliasK006)->(dbSkip())
      loop
    endif
    if !empty((aliasK006)->DS) .and. ((aliasK006)->DS != mDiag) .and. ((aliasK006)->DS != cDiag)  // �롮ઠ �� �᭮����� ��������
      (aliasK006)->(dbSkip())
      loop
    endif
    // �������� 䨫��� �� ���. ��������� � ��������� �᫮������
    //
    //
    if !empty((aliasK006)->SY) .and. (iScan := ascan(aFedUsluga, alltrim((aliasK006)->SY)) == 0)     // �롮ઠ �� ��㯯� 䥤�ࠫ�� ��㣠�
      (aliasK006)->(dbSkip())
      loop
    endif
    (aliasTMP)->(dbAppend())
    (aliasTMP)->shifr := (aliasK006)->shifr
    (aliasTMP)->kz := (aliasK006)->kz
    (aliasTMP)->PROFIL := (aliasK006)->PROFIL
    (aliasTMP)->DS := (aliasK006)->DS
    (aliasTMP)->DS1 := (aliasK006)->DS1
    (aliasTMP)->DS2 := (aliasK006)->DS2
    (aliasTMP)->SY := (aliasK006)->SY
    (aliasTMP)->AGE := (aliasK006)->AGE
    (aliasTMP)->SEX := (aliasK006)->SEX
    (aliasTMP)->LOS := (aliasK006)->LOS
    (aliasTMP)->AD_CR := (aliasK006)->AD_CR
    (aliasTMP)->AD_CR1 := (aliasK006)->AD_CR1
    (aliasTMP)->DATEBEG := (aliasK006)->DATEBEG
    (aliasTMP)->DATEEND := (aliasK006)->DATEEND
    (aliasTMP)->NS := (aliasK006)->NS

    ++i
    (aliasK006)->(dbSkip())
  enddo

  // hb_Alert('Defention KSG function')

  altd()
  return aRet

function vidAge(DOB, dBegSl, dEndSl)
  local ldni, y, m, d, s
  local vid := '0'

  altd()
  ldni := dBegSl - DOB // ��� ॡ񭪠 ������ � ����
  count_ymd(DOB, dBegSl, @y, @m, @d)

  if (y < 18)  // ���
    vid := '5'
    s := '���'
    if ldni  <= 28
      vid := '1' // ��� �� 28 ����
      s := '0-28��.'
    elseif ldni  <= 90
      vid := '2' // ��� �� 90 ����
      s := '29-90��.'
    elseif y < 1
      vid := '3' // ��� �� 91 ��� �� 1 ����
      s := '91����-1���'
    elseif y <= 2
      vid := '4' // ��� �� 2 ���
      s := '��2��� �����.'
    endif 
  elseif (y >= 18) .and. (y < 21)
    vid := '7'
    s := '��21�.'
  else
    vid := '6'
    s := '���.'
  endif

  // if lvr == 0 //
  //   lage := '6'
  //   s := '���.'
  // else
  //   lage := '5'
  //   s := '���'
  //   fl := .t.
  //   if ldni <= 28
  //     lage += '1' // ��� �� 28 ����
  //     s := '0-28��.'
  //     fl := .f.
  //   elseif ldni <= 90
  //     lage += '2' // ��� �� 90 ����
  //     s := '29-90��.'
  //     fl := .f.
  //   elseif y < 1 // �� 1 ����
  //     lage += '3' // ��� �� 91 ��� �� 1 ����
  //     s := '91����-1���'
  //     fl := .f.
  //   endif
  //   if y <= 2 // �� 2 ��� �����⥫쭮
  //     lage += '4' // ��� �� 2 ���
  //     if fl
  //       s := '��2��� �����.'
  //     endif
  //   endif
  // endif

  return vid
