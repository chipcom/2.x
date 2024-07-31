#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 22.02.19 запрос 'хитрого' пароля для доступа к операции аннулирования
Function involved_password(par,_n_reestr,smsg)
  Local fl := .f., c, c1, n := 0, n1, s, i, i_p := 0, n_reestr

  DEFAULT smsg TO ''
  smsg := 'Введите пароль для '+smsg
  if (n := len(smsg)) > 61
    smsg := padr(smsg, 61)
  elseif n < 59
    smsg := space((61-n)/2)+smsg
  endif
  c1 := int((maxcol()-75)/2)
  n := 0
  do while i_p < 3  // до 3х попыток
    ++i_p
    n_reestr := _n_reestr
    if (n := input_value(maxrow()-6,c1,maxrow()-4,maxcol()-c1,color1,smsg,n,'9999999999')) != NIL
      if par == 1 // реестр
        s := lstr(n_reestr)
      elseif par == 2 // РАК или РПД
        s := substr(n_reestr, 3)
        s := right(beforatnum('M',s), 1)+left(afteratnum('_',s), 7)
      elseif eq_any(par, 3, 4) // счёт
        s := iif(par == 3, '', '1')
        n_reestr := substr(alltrim(upper(n_reestr)), 3)
        for i := 1 to len(n_reestr)
          c := substr(n_reestr,i, 1)
          if between(c,'0','9')
            s += c
          elseif between(c,'A','Z')
            s += lstr(asc(c))
          endif
        next
      endif
      s := charrem('0',s)+lstr(_version()[1])+lstr(_version()[2])+lstr(_version()[3]*7, 10, 0)
      do while len(s) > 7
        s := left(s,len(s)-1)
      enddo
      n1 := int(val(ntoc(s, 8)))
      if n == n1
        fl := .t. ; exit
      else
        func_error(4,'Пароль неверен. Нет доступа к данному режиму!')
      endif
    else
      exit
    endif
  enddo
  return fl

// 18.07.24 ввод пароля
Function inp_password(is_local_version,is_create)
  Local pss := space(10), tmp_pss := my_parol(), i_p := 0, ta := {}, s, fl_g := .f.
  Public TIP_ADM := 0
  Public grup_polzovat := 1, dolj_polzovat := '', ;
         kod_polzovat := chr(0), tip_polzovat := TIP_ADM, fio_polzovat := '', ;
         yes_parol := .t.
  if (is_local_version .and. !hb_FileExists(dir_server+'base1'+sdbf)) .or. is_create
    yes_parol := .f.
    return ta
  endif
  do while i_p < 3  // до 3х попыток
    pss := get_parol(,,,,,'N/W','W/N*')
    if lastkey() == K_ESC
      f_end()
    else
      ++i_p
      if ascan(tmp_pss, crypt(pss,gpasskod)) == 0
        pss := padr(crypt(pss,gpasskod), 10)
        if !hb_FileExists(dir_server+'base1'+sdbf)
          func_error('Не обнаружено базы данных паролей (BASE1.DBF)!')
          f_end()
        elseif R_Use(dir_server+'base1',,'base1')
          locate for base1->p3 == pss .and. !empty(base1->p1)
          if (fl := found())
            mfio := crypt(base1->p1,gpasskod)
            fio_polzovat := alltrim(mfio)
            kod_polzovat := chr(recno())
            tip_polzovat := base1->p2
            if (fl_g := (fieldnum('p5') > 0))
              dolj_polzovat := iif(empty(base1->p5), '', crypt(base1->p5,gpasskod))
              grup_polzovat := base1->p6
            endif
            // для доступа к кассовому аппарату пароль = целое число
            oper_parol := int(val(crypt(pss,gpasskod)))
            if fieldnum('p7') > 0
              s := iif(empty(base1->p7), '', crypt(base1->p7,gpasskod))
              if !empty(s) .and. int(val(s)) > 0
                oper_parol := int(val(s))
              endif
            endif
            // для ОТЧеТОВ доступа к кассовому аппарату пароль = целое число
            oper_frparol := int(val(crypt(pss,gpasskod)))
            if fieldnum('p8') > 0
              s := iif(empty(base1->p8), '', crypt(base1->p8,gpasskod))
              if !empty(s) .and. int(val(s)) > 0
                oper_frparol := int(val(s))
              else
                oper_frparol := oper_parol
              endif
            endif
            if fieldnum('inn') > 0 // ИНН кассира
              oper_fr_inn := alltrim(crypt(base1->inn,gpasskod))
            endif
            oper_dov_date   := stod(crypt(base1->dov_date,gpasskod))
            oper_dov_nomer  := alltrim(crypt(base->dov_nomer,gpasskod))
          endif
          base1->(dbCloseArea())
          if !fl
            func_error('Пароль не зарегистрирован. Нет прав доступа к системе!')
            if i_p < 3 ; loop ; endif  // до 3х попыток
            f_end()
          endif
        else
          func_error('В данный момент нет доступа к системе!')
          f_end()
        endif
      elseif !hb_FileExists(dir_server+'base1'+sdbf)
        yes_parol := .f.
      endif
    endif
    exit
  enddo
  aadd(ta,alltrim(fio_polzovat))
  aadd(ta, 'Тип доступа: "' + {'Администратор', 'Оператор', '' ,'Контролёр'}[tip_polzovat + 1] + '"')
  if !empty(dolj_polzovat)
    aadd(ta,'Должность: '+alltrim(dolj_polzovat))
  endif
//  if fl_g .and. between(grup_polzovat, 1, 3)
//    aadd(ta,'Группа экспертизы (КЭК): '+lstr(grup_polzovat))
//  endif
  return ta

// 11.07.24
Function edit_password()
  Local buf := save_maxrow()
  Local mas11 := {}, mpic := {,,,{1, 0}}, mas13 := {.F.,.F.,.T.}, ;
        mas12 := {{1,padr(' Ф.И.О.', 20)}, ;
                  {2,padr(' Тип доступа', 13)}, ;
                  {3,padr(' Должность', 20)};
                 }
  Local blk := {|b,ar,nDim,nElem,nKey| f1editpass(b,ar,nDim,nElem,nKey)}
  Private menu_tip := {{'АДМИНИСТРАТОР', 0}, ;
                       {'ОПЕРАТОР     ', 1}, ;
                       {'КОНТРОЛЕР    ', 3}}
  Private c_1 := T_COL+5, c_2
  if ! hb_user_curUser:IsAdmin()
    return func_error(4,err_admin)
  endif
  if !G_SLock('edit_pass')
    return func_error(4,'В данный момент пароли редактирует другой администратор. Ждите.')
  endif
  mywait()
  c_2 := c_1+64
//  if is_task(X_KEK)
//    c_1 := 2 ; c_2 := 77
//    aadd(mas12, {4,'Группа КЭК'})
//  endif
  R_Use(dir_server+'base1')
  do while !eof()
    aadd(mas11, {crypt(p1,gpasskod), ;                       //  1
                 inieditspr(A__MENUVERT,menu_tip,p2), ;      //  2
                 iif(empty(p5), p5, crypt(p5,gpasskod)), ;   //  3
                 p6, ;                        //  4
                 crypt(p3,gpasskod), ;        //  5
                 p2, ;                        //  6
                 recno(), ;                   //  7
                 iif(empty(p7), p7, crypt(p7,gpasskod)), ;     //  8
                 iif(empty(p8), p8, crypt(p8,gpasskod)), ;     //  9
                 iif(empty(inn), inn, crypt(inn,gpasskod)), ;  //  10
                 IDROLE, ;                                     //  11
                 iif(empty(dov_data), dov_data, crypt(dov_data,gpasskod)), ;  //  12 
                 iif(empty(dov_nom), dov_nom, crypt(dov_nom,gpasskod));   //  13 
                };
        )
    skip
  enddo
  close databases
  if len(mas11) == 0
    aadd(mas11, {space(20),space(25),space(20), 0,space(10), 1, 0,space(10),space(10),space(12), 0, space(8),space(20)})
  endif
  //
  if len(mas11) > 254
    mas13[3] := .F.
  endif
  //
  Arrn_Browse(T_ROW,c_1,maxrow()-2,c_2,mas11,mas12, 1,,color5,,,,,mpic,blk,mas13)
  close databases
  setcolor(color0)
  rest_box(buf)
  G_SUnlock('edit_pass')
  RETURN NIL

// 11.07.24
Static Function f1editpass(b, ar, nDim, nElem, nKey)
  Local nRow := ROW(), nCol := COL(), tmp_color, buf := save_maxrow(), buf1, fl := .f., r1, r2, i, ;
        mm_gruppa := { ;
         {'0 - не работает в задаче КЭК', 0}, ;
         {'1 - уровень зав.отделением', 1}, ;
         {'2 - уровень зам.гл.врача', 2}, ;
         {'3 - уровень комиссии КЭК', 3}}
  local obj, menu_idrole := {}

  // собирем доступные группы пользователей
  aadd(menu_idrole, {'Группа пользователей не выбрана', 0})
  for each obj in TRoleUserDB():getList()
    aadd(menu_idrole, {obj:Name, obj:ID})
  next

  keyboard ''
  if nKey == K_ENTER 
    Private mfio, mdolj, mgruppa, m1gruppa := 0, mtip, m1tip, mpass, moper, ;
    mfroper,minn,  mdov_date, mdov_nomer, gl_area := {1, 0, maxrow() - 1, 79, 0}

    if ar[nElem, 7] == 0 .and. len(ar) > 1
      ar[nElem, 6] := 1 // по умолчанию добавляется оператор
    endif
    mfio := ar[nElem, 1]
    mdolj := ar[nElem, 3]
    m1tip := ar[nElem, 6]
    mtip := inieditspr(A__MENUVERT, menu_tip, m1tip)
    mpass := ar[nElem, 5]
    tmp_color := setcolor(cDataCGet)
    r1 := maxrow() - 10
    r2 := maxrow() - 3
//    if is_task(X_KEK)
//      m1gruppa := ar[nElem, 4]
//      mgruppa := inieditspr(A__MENUVERT, mm_gruppa, m1gruppa)
//      --r1
//    endif
    if is_task(X_PLATN) .or. is_task(X_ORTO) .or. is_task(X_KASSA)
      minn  := ar[nElem, 10]
      moper := ar[nElem, 8]
      --r1
      --r1
      mfroper := ar[nElem, 9]
      --r1
    endif

    m1idrole := ar[nElem, 11]
    midrole := inieditspr(A__MENUVERT, menu_idrole, m1idrole)
    mdov_date  := stod(ar[nElem, 12])
    mdov_nomer :=  ar[nElem, 13]

    buf1 := box_shadow(r1, c_1 + 1, r2, c_2 - 1, , iif(ar[nElem, 7] == 0, 'Добавление', 'Редактирование'), cDataPgDn)
    if is_task(X_PLATN) .or. is_task(X_ORTO) .or. is_task(X_KASSA)
      @ r1 + 2, c_1 + 3 say 'Ф.И.О. пользователя' get mfio valid func_empty(mfio)
      @ r1 + 2, c_1 + 46 say 'ИНН' get minn
    else
      @ r1 + 2, c_1 + 3 say 'Ф.И.О. пользователя' get mfio valid func_empty(mfio)
    endif
    @ r1 + 3, c_1 + 3 say 'Должность' get mdolj

    @ r1 + 4, c_1 + 3 say 'Группа пользователей' get midrole READER {|x|menu_reader(x, menu_idrole, A__MENUVERT, , , .f.)}

    @ r1 + 5, c_1 + 3 say 'Тип доступа' get mtip READER {|x|menu_reader(x, menu_tip, A__MENUVERT, , , .f.)}
    @ r1 + 6, c_1 + 3 say 'Пароль' get mpass picture '@!' valid func_empty(mpass)
    i := 6
//    if is_task(X_KEK)
//      ++i
//      @ r1 + i, c_1 + 3 say 'Группа КЭК' get mgruppa READER {|x|menu_reader(x, mm_gruppa, A__MENUVERT, , , .f.)}
//    endif
    if is_task(X_PLATN) .or. is_task(X_ORTO) .or. is_task(X_KASSA)
      ++i
      @ r1 + i, c_1 + 3 say 'Пароль для фискального регистратора' get moper picture '@!'
      ++i
      @ r1 + i, c_1 + 3 say 'Пароль для снятия отчета фискального регистратора' get mfroper picture '@!'
      ++i
      @ r1 + i, c_1 + 3 say 'N доверен-ти' get mdov_nomer
      @ r1 + i, c_1 + 36 say 'Дата доверен-ти' get mdov_date 
    endif
    status_key('^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода')
    myread()
    rest_box(buf)
    setcolor(tmp_color)
    if lastkey() != K_ESC .and. f_Esc_Enter(1)
      ar[nElem, 1]  := mfio
      ar[nElem, 6]  := m1tip
      ar[nElem, 3]  := mdolj
      ar[nElem, 4]  := m1gruppa
      ar[nElem, 2]  := inieditspr(A__MENUVERT, menu_tip, m1tip)
      ar[nElem, 5]  := mpass
      ar[nElem, 8]  := moper
      ar[nElem, 9]  := mfroper
      ar[nElem, 10] := minn
      ar[nElem, 11] := m1idrole
      ar[nElem, 12] := dtos(mdov_date)
      ar[nElem, 13] := mdov_nomer
      if G_Use(dir_server + 'base1', , , .t.)
        if ar[nElem, 7] == 0
          G_RLock(.t., FOREVER)
          ar[nElem, 7] := recno()
        else
          goto (ar[nElem, 7])
          G_RLock(FOREVER)
        endif
        replace p1  with crypt(mfio, gpasskod), ;
                p2  with m1tip, ;
                p3  with crypt(mpass, gpasskod), ;
                p5  with crypt(mdolj, gpasskod), ;
                p6  with m1gruppa, ;
                p7  with crypt(moper, gpasskod), ;
                p8  with crypt(mfroper, gpasskod), ;
                inn with crypt(minn, gpasskod), ;
                IDROLE  with m1idrole, ;
                DOV_DATA  with crypt(dtos(mdov_date), gpasskod), ;
                DOV_NOM   with crypt (mdov_nomer, gpasskod)
       
        b:refreshAll()
        fl := .t.
      endif
    endif
    close databases
    rest_box(buf1)
    @ nRow, nCol SAY ''

  endif
  return fl