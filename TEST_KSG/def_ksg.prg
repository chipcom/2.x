#include 'common.ch'
#include 'chip_mo.ch'

function defenitionKSG(DOB, gender, dBegSl, dEndSl, uslOK, mDiag, aDiagAdd, aDiagOsl, aFedUsluga, aAdCrit, aFr)
  // DOB - дата рождения пациента
  // gender - пол пациента (1-мужской, 2-женский)
  // dBegSl - дата начала случая
  // dEndSl - дата окончания случая
  // uslOK - условия оказания (круглосуточный или дневной стационар)
  // mDiag - код по МКБ-10 основного диагноза
  // aDiagAdd - список по МКБ-10 дополнительных диагнозов 
  // aDiagOsl - список по МКБ-10 диагнозов осложнений
  // aFedUsluga - список из номенклатуры федеральных услуг
  // aAdCrit - список дополнительных критериев
  // aFr - диапазон фракций
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
  default uslOK to USL_OK_HOSPITAL  // круглосуточный стационар

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

    if substr((aliasK006)->shifr, 1, 2) != cUslOk // отбираем по условию оказания мед. помощи
      (aliasK006)->(dbSkip())
      loop
    endif
    if !empty((aliasK006)->AGE) .and. ((aliasK006)->AGE != vid_age)     // выборка по группе возраста
      (aliasK006)->(dbSkip())
      loop
    endif
    if !empty((aliasK006)->SEX) .and. ((aliasK006)->SEX != cGender)     // выборка по полу
      (aliasK006)->(dbSkip())
      loop
    endif
    if !empty((aliasK006)->DS) .and. ((aliasK006)->DS != mDiag) .and. ((aliasK006)->DS != cDiag)  // выборка по основному диагнозу
      (aliasK006)->(dbSkip())
      loop
    endif
    // добавить фильтр по доп. диагнозам и диагнозам осложнений
    //
    //
    if !empty((aliasK006)->SY) .and. (iScan := ascan(aFedUsluga, alltrim((aliasK006)->SY)) == 0)     // выборка по группе федеральным услугам
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
  ldni := dBegSl - DOB // для ребёнка возраст в днях
  count_ymd(DOB, dBegSl, @y, @m, @d)

  if (y < 18)  // дети
    vid := '5'
    s := 'дети'
    if ldni  <= 28
      vid := '1' // дети до 28 дней
      s := '0-28дн.'
    elseif ldni  <= 90
      vid := '2' // дети до 90 дней
      s := '29-90дн.'
    elseif y < 1
      vid := '3' // дети от 91 дня до 1 года
      s := '91день-1год'
    elseif y <= 2
      vid := '4' // дети до 2 лет
      s := 'до2лет включ.'
    endif 
  elseif (y >= 18) .and. (y < 21)
    vid := '7'
    s := 'до21г.'
  else
    vid := '6'
    s := 'взр.'
  endif

  // if lvr == 0 //
  //   lage := '6'
  //   s := 'взр.'
  // else
  //   lage := '5'
  //   s := 'дети'
  //   fl := .t.
  //   if ldni <= 28
  //     lage += '1' // дети до 28 дней
  //     s := '0-28дн.'
  //     fl := .f.
  //   elseif ldni <= 90
  //     lage += '2' // дети до 90 дней
  //     s := '29-90дн.'
  //     fl := .f.
  //   elseif y < 1 // до 1 года
  //     lage += '3' // дети от 91 дня до 1 года
  //     s := '91день-1год'
  //     fl := .f.
  //   endif
  //   if y <= 2 // до 2 лет включительно
  //     lage += '4' // дети до 2 лет
  //     if fl
  //       s := 'до2лет включ.'
  //     endif
  //   endif
  // endif

  return vid
