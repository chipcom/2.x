** mo_spr.prg
#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

**
Function begin_task_sprav()
  Static n_zapusk := 0
  Local fl := .t.

  if n_zapusk == 0
    ++n_zapusk
  endif
  if copy_Tools_Ini()
    Tools_Ini_OMS(1, 0, 0)
  else
    fl := .f.
  endif
  return fl



**
Function inp_bit_otd(k, r, c)
  Local mlen, t_mas := {}, buf := savescreen(), ret, ;
      i, tmp_color := setcolor(), m1var := '', s := '', ;
      tmp_select := select(), r1, a_uch := {}

  mywait()
  R_Use(dir_server + 'mo_uch', , 'LPU')
  dbeval({|| iif(between_date(lpu->dbegin, lpu->dend, sys_date), ;
               aadd(a_uch, lpu->(recno())), nil)})
  R_Use(dir_server + 'mo_otd', , 'OTD')
  set relation to kod_lpu into LPU
  dbeval({|| s := if(chr(recno()) $ k, ' * ', '   ')+;
                padr(otd->name, 30)+ ' ' +padr(lpu->short_name, 5) + str(recno(), 10), ;
           aadd(t_mas, s)}, ;
          {|| between_date(otd->dbegin, otd->dend, sys_date) .and. ;
           ascan(a_uch, otd->kod_lpu) > 0};
        )
  otd->(dbCloseArea())
  lpu->(dbCloseArea())
  if tmp_select > 0
    select(tmp_select)
  endif
  mlen := len(t_mas)
  asort(t_mas, , , {|x, y| if(substr(x, 35, 5) == substr(y, 35, 5), ;
                          (substr(x, 4, 30) < substr(y, 4, 30)), ;
                          (substr(x, 35, 5) < substr(y, 35, 5)))})
  i := 1
  status_key('^<Esc>^ - отказ; ^<Enter>^ - подтверждение; ^<Ins>^ - смена опции текущей альтернативы')
  if (r1 := r - 1 - mlen - 1) < 2
    r1 := 2
  endif
  if (ret := popup(r1, 19, r - 1, 62, t_mas, i, color0, .t., 'fmenu_reader', , ;
                 'В каких отделениях разрешается ввод услуги', col_tit_popup)) > 0
    for i := 1 to mlen
      if '*' == substr(t_mas[i], 2, 1)
        k := chr(int(val(right(t_mas[i], 10))))
        m1var += k
      endif
    next
    s := '= ' + lstr(len(m1var)) + 'отд. ='
  endif
  restscreen(buf)
  setcolor(tmp_color)
  Return iif(ret==0, NIL, {m1var, s})

**
Function fget_slugba(k, r, c)
  Local tmp_help := chm_help_code, k1

  chm_help_code := -1
  select SL
  find (str(k, 3))
  if !found()
    go top
  endif
  if (fl := Alpha_Browse(2, c, r - 1, c + 50, 'f51_uslugi', color0, , , .f.))
    k1 := {sl->shifr, lstr(sl->shifr) + '. ' + alltrim(sl->name)}
  endif
  chm_help_code := tmp_help
  return k1

**
Function f1_ns_uslugi(oBrow)
  Local oColumn

  oColumn := TBColumnNew(center('Несовместимые услуги', 30), {|| uk->name})
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ выход; ^<Enter>^ ред-ние; ^<Ins>^ добавление; ^<Del>^ удал.; ^<Ctrl+Enter>^ услуги')
  return NIL

** прочие справочники
Function edit_proch_spr(k)
  Static sk1 := 1, sk2 := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j

  DEFAULT k TO 0
  do case
    case k == 0
      mas_pmt := {'Подстрока ~адреса', ;
                  'Подстрока ~места работы', ;
                  'Кем ~выдан документ', ;
                  '~Прочие компании', ;
                  '~Комитеты (МО)', ;
                  'О~бразовательные учреждения', ;
                  'Стационары детей-~сирот'}
      mas_msg := {'Редактирование справочника подстроки адреса', ;
                  'Редактирование справочника подстроки места работы', ;
                  'Редактирование справочника организаций, выдающих документы', ;
                  'Редактирование информации по прочим компаниям', ;
                  'Редактирование информации по комитетам здравоохранения (МО)', ;
                  'Редактирование справочника образовательных учреждений', ;
                  'Редактирование справочника стационаров детей-сирот'}
      mas_fun := {'edit_proch_spr(1)', ;
                  'edit_proch_spr(2)', ;
                  'edit_proch_spr(3)', ;
                  'edit_proch_spr(4)', ;
                  'edit_proch_spr(5)', ;
                  'edit_proch_spr(6)', ;
                  'edit_proch_spr(7)'}
      if eq_any(is_oplata, 5, 6, 7)
        aadd(mas_pmt, 'Способ ~оплаты')
        aadd(mas_msg, 'Ввод / редактирование справочников для Вашего способа оплаты')
        if eq_any(is_oplata, 5, 6)
          aadd(mas_fun, 'spr_opl_5()')
        elseif is_oplata == 7
          aadd(mas_fun, 'spr_opl_7()')
        endif
      endif
      popup_prompt(T_ROW, T_COL + 5, sk1, mas_pmt, mas_msg, mas_fun)
    case k == 1
      edit_s_adres()
    case k == 2
      str_sem := 'Редактирование места работы'
      if G_SLock(str_sem)
        popup_edit(dir_server + 's_mr', T_ROW, T_COL + 5, maxrow() - 2, , 1)
        G_SUnLock(str_sem)
      else
        func_error(4, err_slock)
      endif
    case k == 3
      mas_pmt := {'~Редактирование', ;
                  'Удаление ~дубликатов'}
      mas_msg := {'Редактирование справочника организаций, выдающих документы', ;
                  'Удаление дубликатов организаций'}
      mas_fun := {'edit_proch_spr(11)', ;
                  'edit_proch_spr(12)'}
      popup_prompt(T_ROW, T_COL + 5, sk2, mas_pmt, mas_msg, mas_fun)
    case k == 4
      edit_strah()
    case k == 5
      edit_komit()
    case k == 6
      edit_school()
    case k == 7
      edit_dds_stac()
    case k == 11
      fedit_s_kem()
    case k == 12
      fdeld_s_kem()
  endcase
  if between(k, 1, 10)
    sk1 := k
  elseif between(k, 11, 20)
    sk2 := k
  endif
  return NIL

** справочник подстроки адреса
Function edit_s_adres()
  Local t_arr[BR_LEN], buf := savescreen()

  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := T_COL + 5
  t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 43
  t_arr[BR_OPEN] := {|| f1_s_adres(, , 'open')}
  t_arr[BR_CLOSE] := {|| sa->(dbCloseArea())}
  t_arr[BR_SEMAPHORE] := 'Редактирование адреса'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {, , , , .t., 60}
  t_arr[BR_COLUMN] := {{center('Подстрока адреса', 40), {||sa->name}}}
  t_arr[BR_EDIT] := {|nk, ob| f1_s_adres(nk,ob, 'edit')}
  edit_browse(t_arr)
  restscreen(buf)
  return NIL

**
Function f1_s_adres(nKey, oBrow, regim)
  Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
      fl := .f., rec, mkod, tmp_color := setcolor()

  do case
    case regim == 'open'
      G_Use(dir_server + 's_adres', dir_server + 's_adres', 'SA')
      go top
      ret := !eof()
    case regim == 'edit'
      if nKey == K_INS .or. (nKey == K_ENTER .and. !empty(sa->name))
        rec := recno()
        Private mname := if(nKey == K_INS, space(40), sa->name), ;
              gl_area := {1, 0,maxrow() - 1, 79, 0}
        buf1 := box_shadow(pr2 - 3, pc1 + 1, pr2 - 1, pc2 - 1, color8, ;
                    iif(nKey == K_INS, 'Добавление', 'Редактирование'), cDataPgDn)
        setcolor(cDataCGet)
        @ pr2 - 2, pc1 + 2 get mname
        status_key('^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи')
        myread()
        if lastkey() != K_ESC .and. !empty(mname)
          if nKey == K_INS
            AddRecN()
            rec := recno()
          else
            G_RLock(forever)
          endif
          replace name with mname
          COMMIT
          UNLOCK
          oBrow:goTop()
          goto (rec)
          ret := 0
        endif
        setcolor(tmp_color)
        rest_box(buf)
        rest_box(buf1)
      elseif nKey == K_DEL .and. !empty(sa->name) .and. f_Esc_Enter(2)
        DeleteRec()
        oBrow:goTop()
        ret := 0
      else
        keyboard ''
      endif
  endcase
  return ret

**
Function fedit_s_kem()
  Local t_arr[BR_LEN], buf := savescreen()

  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := 4
  t_arr[BR_RIGHT] := 77
  t_arr[BR_OPEN] := {|| f1_s_kemvyd(, , 'open')}
  t_arr[BR_CLOSE] := {|| sa->(dbCloseArea())}
  t_arr[BR_SEMAPHORE] := 'КЕМ ВЫДАН'
  t_arr[BR_COLOR] := color0
  t_arr[BR_ARR_BROWSE] := {, , , , .t., 60}
  t_arr[BR_COLUMN] := {{center('Наименование организаций, выдающих документы', 70), {|| padr(sa->name, 70)}}}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход ^<Enter>^ ред-ие ^<Del>^ удаление ^<Ins>^ добавление ^<F2>^ поиск')}
  t_arr[BR_EDIT] := {|nk, ob| f1_s_kemvyd(nk,ob, 'edit', 1)}
  edit_browse(t_arr)
  restscreen(buf)
  return NIL

** 12.07.17
Function f1_s_kemvyd(nKey, oBrow, regim, par)
  Local ret := -1, j := 0, flag := -1, buf := save_maxrow(), buf1, ;
      fl := .f., rec, mkod, tmp_color := setcolor()

  do case
    case regim == 'open'
      G_Use(dir_server + 's_kemvyd', dir_server + 's_kemvyd', 'SA')
      go top
      if par != NIL .and. par > 0
        goto (par)
        if deleted() .or. eof()
          go top
        endif
      endif
      ret := !eof()
    case regim == 'edit'
      if nKey == K_INS .or. (nKey == K_ENTER .and. !empty(sa->name))
        rec := recno()
        Private mname := iif(nKey == K_INS, space(150), sa->name), gl_area := {1, 0,maxrow() - 1, 79, 0}
        buf1 := box_shadow(pr2 - 3, pc1 + 1, pr2 - 1, pc2 - 1, color8, ;
                         iif(nKey == K_INS, 'Добавление', 'Редактирование'), cDataPgDn)
        setcolor(cDataCGet)
        @ pr2 - 2, pc1 + 2 get mname pict '@S70'
        status_key('^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение записи')
        myread()
        if lastkey() != K_ESC .and. !empty(mname)
          if nKey == K_INS
            AddRecN()
            rec := recno()
          else
            G_RLock(forever)
          endif
          replace name with mname
          COMMIT
          UNLOCK
          oBrow:goTop()
          goto (rec)
          ret := 0
        endif
        setcolor(tmp_color)
        rest_box(buf)
        rest_box(buf1)
      elseif nKey == K_SPACE .and. par == 2
        _fl_space := .t.
        ret := 1
      elseif nKey == K_DEL .and. !empty(sa->name) .and. f_Esc_Enter(2)
        if yes_d_kemvyd(sa->(recno()))
          DeleteRec()
          oBrow:goTop()
          ret := 0
        endif
      elseif nKey == K_F2
        if (rec := poisk_kemvyd(pr1)) != NIL
          oBrow:goTop()
          goto (rec)
          ret := 0
        endif
      else
        keyboard ''
      endif
  endcase
  return ret

**
Function poisk_kemvyd(mr1)
  Static tmp := ''
  Local ret, rec := sa->(recno()), buf := savescreen(), i, tmp1

  do while .t.
    tmp1 := padr(tmp, 50)
    setcolor(color8)
    box_shadow(13, 14, 18, 67)
    @ 15, 15 say center('Введите подстроку поиска', 52)
    status_key('^<Esc>^ - отказ;  ^<Enter>^ - поиск')
    @ 16, 16 get tmp1 picture '@K@!'
    myread()
    setcolor(color0)
    if lastkey() == K_ESC .or. empty(tmp1)
      exit
    endif
    mywait()
    tmp := alltrim(tmp1)
    i := 0
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr1 + 3, k2 := 21, tmp2 := upper(tmp)
    go top
    do while !eof()
      if tmp2 $ upper(sa->name)
        if ++i > 100
          exit
        endif
        aadd(tmp_mas, sa->name)
        aadd(tmp_kod, sa->(recno()))
      endif
      skip
    enddo
    if (t_len := len(tmp_kod)) = 0
      stat_msg('Неудачный поиск!')
      mybell(2, ERR)
      loop
    else
      box_shadow(mr1, 2, 22, 77)
      SETCOLOR(col_tit_popup)
      @ k1 - 2, 15 say 'Поиск: ' + tmp2
      SETCOLOR(color0)
      if k1 + t_len + 2 < 21
        k2 := k1 + t_len + 2
      endif
      i := ascan(tmp_kod, rec)
      @ k1, 3 say center(' Количество найденных строк - ' + lstr(t_len), 74)
      status_key('^<Esc>^ - отказ от выбора;  ^<Enter>^ - выбор')
      if (i := popup(k1 + 1, 13, k2, 66, tmp_mas, i, color0)) > 0
        ret := tmp_kod[i]
      endif
      exit
    endif
  enddo
  goto (rec)
  restscreen(buf)
  return ret

**
Function get_s_kemvyd(k, r, c)
  Local r1, r2

  if (r1 := r + 1) > maxrow() / 2
    r2 := r - 1
    r1 := 2
  else
    r2 := maxrow() - 2
  endif
  return input_s_kemvyd(k, r1, r2)

**
Function input_s_kemvyd(k, r1, r2)
  Local t_arr[BR_LEN], tmp_select := select(), buf := savescreen(), ret, tmp_keys

  Private _fl_space := .f.
  t_arr[BR_TOP] := r1
  t_arr[BR_BOTTOM] := r2
  t_arr[BR_LEFT] := 4
  t_arr[BR_RIGHT] := 77
  t_arr[BR_OPEN] := {|| f1_s_kemvyd(, , 'open',k)}
  t_arr[BR_CLOSE] := {|| sa->(dbCloseArea())}
  t_arr[BR_COLOR] := color0
  t_arr[BR_COLUMN] := {{center('Наименование организаций, выдающих документы', 70), {|| padr(sa->name, 70)}}}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ выход ^<Enter>^ выбор ^<Пробел>^ очистка поля ^<Ins>^ добавление ^<F2>^ поиск')}
  t_arr[BR_EDIT] := {|nk, ob| f1_s_kemvyd(nk, ob, 'edit', 2)}
  t_arr[BR_ENTER] := {|| ret := {sa->(recno()), alltrim(sa->name)}}
  tmp_keys := my_savekey()
  edit_browse(t_arr)
  my_restkey(tmp_keys)
  if tmp_select > 0
    select(tmp_select)
  endif
  restscreen(buf)
  if _fl_space
    ret := {0, space(10)}
  endif
  return ret

**
Function yes_d_kemvyd(rec)
  Local tmp_select := select(), fl := .t., arr, i, j, s, kr

  R_Use(dir_server + 'kartote_', , 'TMPKART')
  Locate for kemvyd == rec progress
  if found()
    fl := func_error(4, 'Данная организация уже "привязана" к пациенту. Удаление запрещено!')
  endif
  tmpkart->(dbCloseArea())
  if tmp_select > 0
    select(tmp_select)
  endif
  return fl

** удаление дубликатов организаций, выдающих документы
Function fdeld_s_kem()
  Static sk
  Local buf, s1, s2, k1, k2, hGauge, r

  buf := savescreen()
  s1 := s2 := ''
  r := T_ROW
  if ! hb_user_curUser:IsAdmin()
    return func_error(4, 'Оператору доступ в данный режим запрещен!')
  endif
  if !G_SLock1Task(sem_task, sem_vagno)  // запрет доступа всем
    return func_error('В данный момент УДАЛЕНИЕ ДУБЛИКАТА запрещено. Работает другая задача.')
  endif
  n_message({'Данный режим предназначен для удаления одной строки', ;
             '"кем выдан документ" и переноса всей относящейся', ;
             'к ней информации другой строке'}, , ;
            cColorStMsg, cColorStMsg, , , cColorSt2Msg)
  f_message({'Выберите удаляемую строку'}, , color1, color8, 0)
  if (k1 := input_s_kemvyd(sk, r, maxrow() - 2)) != NIL
    s1 := k1[2]
    restscreen(buf)
    f_message({'Выберите строку, на которую переносится информация', ;
               'от <.. ' + s1 + ' ..>'}, , ;
              color1, color8, 0)
    if (k2 := input_s_kemvyd(k1[1], r, maxrow() - 2)) != NIL
      restscreen(buf)
      if k1[1] == k2[1]
        func_error(4, 'Два раза выбрана одна и та же организация!')
      else
        restscreen(buf)
        s2 := k2[2]
        f_message({'Удаляемая строка:', ;
                  '"' + s1 + '".', ;
                  'Вся информация переносится в строку:', ;
                  '"' + s2 + '".'}, , ;
                  color1, color8)
        if f_Esc_Enter('удаления', .t.)
          sk := k2[1]
          mywait()
          hGauge := GaugeNew(, , , '', .t.)
          GaugeDisplay( hGauge )
          G_Use(dir_server + 'kartote_', , 'TMPKART')
          go top
          do while !eof()
            GaugeUpdate( hGauge, recno() / lastrec() )
            if tmpkart->kemvyd == k1[1]
              G_RLock(forever)
              tmpkart->kemvyd := k2[1]
              UnLock
            endif
            skip
          enddo
          CloseGauge(hGauge)
          //
          G_Use(dir_server + 's_kemvyd', dir_server + 's_kemvyd', 'SA')
          set order to 0
          goto (k1[1])
          DeleteRec(.t.)
          close databases
          stat_msg('Операция завершена!')
          MyBell(2, OK)
        endif
      endif
    endif
  endif
  restscreen(buf)
  G_SUnLock(sem_vagno)
  return NIL

** 29.07.13
Function edit_school()
  Local blk, arr[US_LEN]

  arr[US_BOTTOM   ] := maxrow() - 2
  arr[US_LEFT     ] := 2
  arr[US_RIGHT    ] := 77
  arr[US_BASE     ] := dir_server + 'mo_schoo'
  arr[US_ARR_BROWSE]:= {'═', '░', '═', , .t.}
  arr[US_COLUMN   ] := {{' Наименование', {|| name },blk}, ;
                        {' Адрес', {|| left(adres, 26)},blk}, ;
                        {' Тип', {|| padr(inieditspr(A__MENUVERT, mm_tip_school, tip), 14)}, blk}}
  arr[US_BLK_DEL  ] := {|_k| fdel_school(_k)}
  arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := 'образовательные учреждения'
  arr[US_ROD_PADEG] := 'образовательных учреждений'
  arr[US_EDIT_SPR ] := {{'name', 'C', 30, 0, , ,space(30), , 'Сокращённое наименование'}, ;
                        {'fname', 'C', 250, 0, , ,space(250), , 'Полное наименование'}, ;
                        {'adres', 'C', 250, 0, , ,space(250), , 'Юридический адрес'}, ;
                        {'tip', 'N', 1, 0, , ;
                          {|x|menu_reader(x, mm_tip_school, A__MENUVERT, , , .f.)}, ;
                          0, {|x|inieditspr(A__MENUVERT, mm_tip_school, x)}, 'Тип'};
                        }
  edit_u_spr(1, arr)
  return NIL

** 08.11.22
Function fdel_school(k)
  Local _fl := .t., arr, i

  R_Use(dir_server + 'human', , '__B')
  index on kod to (cur_dir + 'tmp_b') for between(ishod, 301, 309)
  go top
  do while !eof()
    arr := read_arr_DISPANS(__b->kod)
    for i := 1 to len(arr)
      if valtype(arr[i]) == 'A' .and. valtype(arr[i, 1]) == 'C' ;
                 .and. arr[i, 1] == '8' .and. valtype(arr[i, 2]) == 'N'
        if (arr[i, 2] == k)
          _fl := .f.
        endif
        exit
      endif
    next
    if !_fl
      exit
    endif
    select __B
    skip
  enddo
  dbCloseArea()
  return _fl

** 25.05.13
Function edit_dds_stac()
  Static mm_vedom := {{'органы здравоохранения', 0}, ;
                      {'органы образования', 1}, ;
                      {'органы социальной защиты', 2}, ;
                      {'другое', 3}}
  Local blk, arr[US_LEN]

  arr[US_BOTTOM   ] := maxrow() - 2
  arr[US_LEFT     ] := 2
  arr[US_RIGHT    ] := 77
  arr[US_BASE     ] := dir_server + 'mo_stdds'
  arr[US_ARR_BROWSE]:= {'═', '░', '═', , .t.}
  arr[US_COLUMN   ] := {{' Наименование', {|| left(name, 40)}, blk}, ;
                      {' Адрес', {|| left(adres, 16)}, blk}, ;
                      {'Ведомственная;принадлежность', {|| padr(inieditspr(A__MENUVERT, mm_vedom, vedom), 14)}, blk}}
  arr[US_BLK_DEL  ] := {|_k| fdel_dds_stac(_k)}
  arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := 'Стационары детей-сирот'
  arr[US_ROD_PADEG] := 'учреждений'
  arr[US_EDIT_SPR ] := {{'name', 'C', 250, 0, , ,space(250), , 'Наименование стационара'}, ;
                        {'adres', 'C', 250, 0, , ,space(250), , 'Адрес'}, ;
                        {'vedom', 'N', 1, 0, , ;
                          {|x|menu_reader(x, mm_vedom, A__MENUVERT, , , .f.)}, ;
                          0, {|x|inieditspr(A__MENUVERT, mm_vedom, x)}, ;
                          'Ведомственная принадлежность'};
                      }
  edit_u_spr(1, arr)
  return NIL

** 08.11.22
Function fdel_dds_stac(k)
  Local _fl := .f.

  R_Use(dir_server + 'human', , '__B')
  dbLocateProgress( {|| __b->ZA_SMO == k } )
  _fl := ! found()
  dbCloseArea()
  return _fl

**
Function spr_opl_5(k)
  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, buf

  DEFAULT k TO 1
  do case
    case k == 1
      mas_pmt := {'Смена ~классов оплаты персоналу', ;
                  '% оплаты ~врачам (ОМС)', ;
                  '% оплаты ~ассистентам (ОМС)'}
      mas_msg := {'Настройка классов оплаты (и отдаленности работы) персонала', ;
                  'Настройка групп услуг (установка процентов оплаты врачей по ОМС)', ;
                  'Настройка групп услуг (установка процентов оплаты ассистентов по ОМС)'}
      mas_fun := {'spr_opl_5(11)', ;
                  'spr_opl_5(12)', ;
                  'spr_opl_5(13)'}
      if is_task(X_PLATN) // для платных услуг
        aadd(mas_pmt, '% оплаты вра~чам (платные)')
        aadd(mas_msg, 'Настройка групп услуг (установка процентов оплаты врачей по ПЛАТНЫМ УСЛУГАМ)')
        aadd(mas_fun, 'spr_opl_5(16)')
        aadd(mas_pmt, '% оплаты асс~истентам (платные)')
        aadd(mas_msg, 'Настройка групп услуг (установка процентов оплаты ассистентов по ПЛАТНЫМ УСЛУГАМ)')
        aadd(mas_fun, 'spr_opl_5(17)')
        aadd(mas_pmt, '% оплаты за ~направление на пл.услуги')
        aadd(mas_msg, 'Настройка групп услуг (проценты оплаты за направление на платные услуги)')
        aadd(mas_fun, 'spr_opl_5(18)')
      endif
      popup_prompt(T_ROW - len(mas_pmt) - 3, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun)
    case k == 11
      spr_opl_52()
    case k == 12
      spr_opl_51(O5_VR_OMS, 'врачам (ОМС)')
    case k == 13
      spr_opl_51(O5_AS_OMS, 'ассистентам (ОМС)')
    case k == 16
      spr_opl_51(O5_VR_PLAT, 'врачам (платные услуги)')
    case k == 17
      spr_opl_51(O5_AS_PLAT, 'ассистентам (платные услуги)')
    case k == 18
      spr_opl_51(O5_VR_NAPR, 'за направление на платные услуги')
  endcase
  if between(k, 11, 20)
    si1 := k - 10
  endif
  return NIL

**
Function spr_opl_7(k)
  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, buf

  DEFAULT k TO 1
  do case
    case k == 1
      mas_pmt := {'~Стоимость УЕТ', ;
                  '% оплаты ~врачам (ОМС)', ;
                  '% оплаты ~ассистентам (ОМС)'}
      mas_msg := {'Настройка стоимости УЕТ для врача и ассистента по группам услуг', ;
                  'Настройка групп услуг (установка процентов оплаты врачей по ОМС)', ;
                  'Настройка групп услуг (установка процентов оплаты ассистентов по ОМС)'}
      mas_fun := {'spr_opl_7(11)', ;
                  'spr_opl_7(12)', ;
                  'spr_opl_7(13)'}
      if is_task(X_PLATN) // для платных услуг
        aadd(mas_pmt, '% оплаты вра~чам (платные)')
        aadd(mas_msg, 'Настройка групп услуг (установка процентов оплаты врачей по ПЛАТНЫМ УСЛУГАМ)')
        aadd(mas_fun, 'spr_opl_7(14)')
        aadd(mas_pmt, '% оплаты асс~истентам (платные)')
        aadd(mas_msg, 'Настройка групп услуг (установка процентов оплаты ассистентов по ПЛАТНЫМ УСЛУГАМ)')
        aadd(mas_fun, 'spr_opl_7(15)')
        aadd(mas_pmt, '% оплаты врачам (~ДМС)')
        aadd(mas_msg, 'Настройка групп услуг (установка процентов оплаты врачей по ДМС)')
        aadd(mas_fun, 'spr_opl_7(16)')
        aadd(mas_pmt, '% оплаты ассистентам (Д~МС)')
        aadd(mas_msg, 'Настройка групп услуг (установка процентов оплаты ассистентов по ДМС)')
        aadd(mas_fun, 'spr_opl_7(17)')
      endif
      popup_prompt(T_ROW - len(mas_pmt) - 3, T_COL + 5, si1, mas_pmt, mas_msg, mas_fun)
    case k == 11
      spr_opl_71()
    case k == 12
      spr_opl_51(O5_VR_OMS, 'врачам (ОМС)')
    case k == 13
      spr_opl_51(O5_AS_OMS, 'ассистентам (ОМС)')
    case k == 14
      spr_opl_51(O5_VR_PLAT, 'врачам (платные услуги)')
    case k == 15
      spr_opl_51(O5_AS_PLAT, 'ассистентам (платные услуги)')
    case k == 16
      spr_opl_51(O5_VR_DMS, 'врачам (ДМС)')
    case k == 17
      spr_opl_51(O5_AS_DMS, 'ассистентам (ДМС)')
  endcase
  if between(k, 11, 20)
    si1 := k - 10
  endif
  return NIL

**
Function spr_opl_51(reg, s)
  Local blk, t_arr[BR_LEN], mtitle := '% оплаты ' + s

  Private str_find := str(reg, 2), muslovie := 'u5->tip==' + lstr(reg)
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := 13
  t_arr[BR_RIGHT] := t_arr[BR_LEFT] + 52
  t_arr[BR_OPEN] := {|| fs_opl_51(, , 'open',reg)}
  t_arr[BR_CLOSE] := {|| dbCloseAll()}
  t_arr[BR_ARR_BLOCK] := {{| | FindFirst(str_find)}, ;
                          {| | FindLast(str_find)}, ;
                          {|n| SkipPointer(n, muslovie)}, ;
                          str_find, muslovie;
                        }
  t_arr[BR_SEMAPHORE] := mtitle
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := mtitle
  t_arr[BR_TITUL_COLOR] := 'W+/GR'
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t., 300}
  blk := {|| if(empty(u5->razryad), {3, 4}, {1, 2})}
  t_arr[BR_COLUMN] := {}
  aadd(t_arr[BR_COLUMN], { 'Класс;оплаты', {|| put_val(u5->razryad, 2)}, blk})
  aadd(t_arr[BR_COLUMN], { 'Отдален-;ность', {|| padc(iif(u5->otdal==1, '√', ''), 9)}, blk})
  aadd(t_arr[BR_COLUMN], { 'Услуги с:', {|| u5->usl_1 }, blk})
  aadd(t_arr[BR_COLUMN], { '  по:', {|| u5->usl_2 }, blk})
  aadd(t_arr[BR_COLUMN], { '  Процент;  оплаты', {|| ft_opl_51(u5->procent,u5->procent2, 10)}, blk})
  t_arr[BR_STAT_MSG] := {|| ;
    status_key('^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать')}
  t_arr[BR_EDIT] := {|nk, ob| fs_opl_51(nk, ob, 'edit', reg)}
  edit_browse(t_arr)
  return NIL

**
Function fs_opl_51(nKey, oBrow, regim, lregim)
  Local ret := -1
  Local buf, fl := .f., rec, rec1, k := 14, tmp_color

  do case
    case regim == 'open'
      buf := save_maxrow()
      mywait()
      G_Use(dir_server + 'u_usl_5', , 'U5')
      go top
      do while !eof()
        G_RLock(forever)
        u5->_usl_1 := fsort_usl(u5->usl_1)
        u5->_usl_2 := fsort_usl(iif(empty(u5->usl_2), u5->usl_1, u5->usl_2))
        UnLock
        skip
      enddo
      Commit
      index on str(tip, 2) + _usl_1 + str(razryad, 2) + str(otdal, 1) to (cur_dir + 'tmp_u5')
      find (str_find)
      ret := found()
      rest_box(buf)
    case regim == 'edit'
      do case
        case nKey == K_F9
          buf := save_maxrow()
          mywait()
          rec := recno()
          arr_title := {;
            '─────┬─────┬─────────────────────╥─────────────────────', ;
            'Класс│Отда-│       Услуги        ║   % оплаты по ОМС   ', ;
            'опла-│лен- ├──────────┬──────────╫──────────┬──────────', ;
            'ты   │ность│    с     │    по    ║   врач   │ассистент ', ;
            '─────┴─────┴──────────┴──────────╨──────────┴──────────'}
          if is_task(X_PLATN) // для платных услуг
            if is_oplata == 7
              arr_title[1] := arr_title[1] + '╥───────────────────────────'
              arr_title[2] := arr_title[2] + '║% оплаты по платным услугам'
              arr_title[3] := arr_title[3] + '╫──────┬──────┬──────┬──────'
              arr_title[4] := arr_title[4] + '║ врач │ асс. │вр.ДМС│ассДМС'
              arr_title[5] := arr_title[5] + '╨──────┴──────┴──────┴──────'
            else
              arr_title[1] := arr_title[1] + '╥────────────────────'
              arr_title[2] := arr_title[2] + '║ % оплаты по пл.усл.'
              arr_title[3] := arr_title[3] + '╫──────┬──────╥──────'
              arr_title[4] := arr_title[4] + '║ врач │ асс. ║направ'
              arr_title[5] := arr_title[5] + '╨──────┴──────╨──────'
            endif
          endif
          n_file := 'pers_o51' + stxt
          HH := 58
          sh := 60
          Private reg_print := f_reg_print(arr_title, @sh)
          fp := fcreate(n_file)
          n_list := 1
          tek_stroke := 0
          add_string('')
          add_string(center('Проценты оплаты персоналу', sh))
          add_string(center('на ' +date_month(sys_date, .t.), sh))
          add_string('')
          aeval(arr_title, {|x| add_string(x)})
          go top
          do while !eof()
            if verify_FF(HH, .t., sh)
              aeval(arr_title, {|x| add_string(x)} )
            endif
            s := put_val(u5->razryad, 4) + ;
               iif(u5->otdal == 1, '   да',space(5)) + ;
                    space(3) + ;
                    u5->usl_1 + ' ' + ;
                if(empty(u5->usl_2), u5->usl_1, u5->usl_2)
            s1 := ''
            do case
              case u5->tip == O5_VR_OMS
                s1 := ' ' + ft_opl_51(u5->procent, u5->procent2, 10)
              case u5->tip == O5_AS_OMS
                s1 := space(12) + ft_opl_51(u5->procent, u5->procent2, 10)
              case u5->tip == O5_VR_PLAT
                s1 := space(22) + put_val_0(u5->procent, 7, 2)
              case u5->tip == O5_AS_PLAT
                s1 := space(22 + 7) + put_val_0(u5->procent, 7, 2)
              case u5->tip == O5_VR_NAPR .or. (u5->tip == O5_VR_DMS .and. is_oplata == 7)
                s1 := space(22 + 7 + 7) + put_val_0(u5->procent, 7, 2)
              case (u5->tip == O5_AS_DMS .and. is_oplata == 7)
                s1 := space(22 + 7 + 7 + 7) + put_val_0(u5->procent, 7, 2)
            endcase
            if !empty(s1)
              add_string(s + s1)
            endif
            skip
          enddo
          goto (rec)
          fclose(fp)
          rest_box(buf)
          viewtext(n_file, , , ,(sh > 80), , , reg_print)
        case nKey == K_INS .or. (nKey == K_ENTER .and. !empty(u5->usl_1))
          save screen to buf
          if nkey == K_INS .and. !fl_found
            colorwin(pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/N')
            colorwin(pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/B')
          endif
          rec := recno()
          Private mrazryad := if(nkey == K_INS, 0, u5->razryad), ;
                motdal := if(nkey == K_INS, ' ', iif(u5->otdal == 1, '√', ' ')), ;
                musl_1 := if(nkey == K_INS, space(10), u5->usl_1), ;
                musl_2 := if(nkey == K_INS, space(10), u5->usl_2), ;
                mprocent := if(nkey == K_INS, 0, u5->procent), ;
                mprocent2 := if(nkey == K_INS, 0, u5->procent2), ;
                bg := {|o, k| get_c_symb(o, k, '√')}, ;
                gl_area := {1, 0,maxrow() - 1, 79, 0}
          tmp_color := setcolor(cDataCScr)
          k := maxrow() - 10
          box_shadow(k, pc1 + 1,maxrow() - 3, pc2 - 1, , ;
                       if(nKey == K_INS, 'Добавление', 'Редактирование'), ;
                       cDataPgDn)
          setcolor(cDataCGet)
          @ k + 1, pc1 + 3 say 'Класс оплаты' get mrazryad pict '99' range 0, 99
          @ k + 2, pc1 + 3 say 'Отдаленность' get motdal reader {|o| MyGetReader(o, bg)}
          @ k + 3, pc1 + 3 say 'Услуги с:' get musl_1
          @ k + 4, pc1 + 3 say '      по:' get musl_2
          @ k + 5, pc1 + 3 say 'Процент оплаты' get mprocent pict '99.99'
          if eq_any(lregim, O5_VR_OMS, O5_VR_PLAT, O5_VR_DMS)
            @ k + 6, pc1 + 3 say 'Процент оплаты врачу без ассистента' get mprocent2 pict '99.99'
          elseif eq_any(lregim, O5_AS_OMS, O5_AS_PLAT, O5_AS_DMS)
            @ k + 6, pc1 + 3 say 'Процент оплаты ассистенту без врача' get mprocent2 pict '99.99'
          endif
          status_key('^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода')
          myread()
          if lastkey() != K_ESC .and. !emptyany(musl_1, mprocent) .and. f_Esc_Enter(1)
            if nKey == K_INS
              fl_found := .t.
              AddRec(2)
              replace u5->tip with lregim
              rec := recno()
            else
              G_RLock(forever)
            endif
            u5->usl_1    := musl_1
            u5->usl_2    := musl_2
            u5->procent  := mprocent
            u5->procent2 := mprocent2
            u5->razryad  := mrazryad
            u5->otdal    := iif(empty(motdal), 0, 1)
            u5->_usl_1   := fsort_usl(musl_1)
            u5->_usl_2   := fsort_usl(iif(empty(musl_2), musl_1, musl_2))
            UNLOCK
            COMMIT
            oBrow:goTop()
            goto (rec)
            ret := 0
          elseif nKey == K_INS .and. !fl_found
            ret := 1
          endif
          setcolor(tmp_color)
          restore screen from buf
        case nKey == K_DEL .and. !empty(u5->usl_1) .and. f_Esc_Enter(2)
          DeleteRec()
          oBrow:goTop()
          find (str_find)
          ret := 0
          if !found()
            ret := 1
          endif
      endcase
  endcase
  return ret

**
Function ft_opl_51(p1, p2, n)
  Local s1 := alltrim(put_val_0(p1, 5, 2)), s2

  if !empty(p2)
    s2 := alltrim(put_val_0(p2, 5, 2))
    if len(s1) + len(s2) + 3 <= n
      s1 += ' '
    endif
    s1 += '(' + s2 + ')'
  endif
  return padc(s1, n)

**
Function spr_opl_52()
  Local i, buf := savescreen(), t_arr[BR_LEN], n := 36

  Private menu_kateg := {{' без', 0}, ;
                         {'2-ая', 1}, ;
                         {'1-ая', 2}, ;
                         {'высш', 3}}
  mywait()
  G_Use(dir_server + 'mo_pers', , 'PERSO')
  index on upper(fio) to (cur_dir + 'tmp_pers')
  go top
  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := 'Корректировка уровней оплаты персонала'
  t_arr[BR_TITUL_COLOR] := 'W+/GR'
  t_arr[BR_ARR_BROWSE] := {, , , 'N/BG,W+/N,B/BG,W+/B,N+/BG', .t., 300}
  t_arr[BR_FL_INDEX] := .t.
  t_arr[BR_FL_NOCLEAR] := .t.
  t_arr[BR_SEMAPHORE] := t_arr[BR_TITUL]
  blk := {|| if(empty(perso->uroven), {3, 4}, {1, 2})}
  t_arr[BR_COLUMN] := {{ padc('Ф.И.О.',n), {|| left(perso->fio,n)}, blk}}
  aadd(t_arr[BR_COLUMN], { ' Таб.;номер', {|| put_val(perso->tab_nom, 5)}, blk})
  aadd(t_arr[BR_COLUMN], { 'Кате;гор.', {|| padr(inieditspr(A__MENUVERT, menu_kateg, perso->kateg), 4)}, {|| {5, 5}}, {5, 5}})
  aadd(t_arr[BR_COLUMN], { 'Класс;оплаты', {|| put_val(perso->uroven, 2)}, blk})
  aadd(t_arr[BR_COLUMN], { 'Отдален-;ность', {|| padc(iif(perso->otdal == 1, '√', ''), 9)}, blk})
  t_arr[BR_STAT_MSG] := {|| ;
    status_key('^<Esc>^ - выход;  ^<Enter>^ - редактирование;  ^<F9>^ - печать')}
  t_arr[BR_EDIT] := {|nk, ob| fs_opl_52(nk, ob, 'edit')}
  edit_browse(t_arr)
  close databases
  restscreen(buf)
  return NIL

**
Function fs_opl_52(nKey, oBrow, cregim)
  Local ret := -1, r := row(), c := col(), buf, fl := .f., ;
        tmp_color := setcolor(), n_file, sh, HH

  do case
    case cregim == 'edit'
      do case
        case nKey == K_F9
          buf := save_maxrow()
          mywait()
          rec := recno()
          arr_title := {;
            '──────────────────────────────────────────────────┬─────┬─────', ;
            '                                                  │Класс│Отда-', ;
            '                     Ф.И.О.                       │опла-│лен- ', ;
            '                                                  │ты   │ность', ;
            '──────────────────────────────────────────────────┴─────┴─────'}
          n_file := 'pers_o52' + stxt
          sh := len(arr_title[1])
          HH := 57
          fp := fcreate(n_file)
          n_list := 1 ; tek_stroke := 0
          add_string('')
          add_string(center('Список персонала', sh))
          add_string(center('на ' +date_month(sys_date, .t.), sh))
          add_string('')
          aeval(arr_title, {|x| add_string(x)})
          go top
          do while !eof()
            if !(emptyall(perso->UROVEN, perso->otdal))
              if verify_FF(HH, .t., sh)
                aeval(arr_title, {|x| add_string(x)} )
              endif
              lfio := padr('[' + lstr(perso->tab_nom) + ']', 8)
              lfio += perso->fio
              add_string(left(lfio, 50)+;
                         put_val(perso->UROVEN, 5)+;
                         iif(perso->otdal == 1, '   да', ''))
            endif
            skip
          enddo
          goto (rec)
          fclose(fp)
          rest_box(buf)
          viewtext(n_file, , , ,(sh > 80), , , 2)
        case nKey == K_ENTER
          buf := save_maxrow()
          Private mrazryad := perso->UROVEN, ;
                  motdal := iif(perso->otdal == 1, '√', ' '), ;
                  bg := {|o, k| get_c_symb(o, k, '√')}, ;
                  gl_area := {1, 0,maxrow() - 1, 79, 0}
          setcolor(cDataCGet)
          @ row(), 58 clear to row(), 76
          @ row(), 58 get mrazryad pict '99' range 0, 99
          @ row(), 71 get motdal reader {|o| MyGetReader(o, bg)}
          status_key('^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи')
          myread()
          if lastkey() != K_ESC
            G_RLock(forever)
            perso->UROVEN := mrazryad
            perso->otdal := iif(empty(motdal), 0, 1)
            UnLock
            Commit
            oBrow:down()
          endif
          rest_box(buf)
          setcolor(tmp_color)
          ret := 0
      endcase
  endcase
  @ r, c say ''
  return ret

**
Function get_c_symb(oGet, nKey, char_symbol)
  Local mvar

  if nKey >= 32
    mvar := readvar()
    if empty(&mvar)
      cKey := char_symbol
    else
      cKey := ' '  // пробел
    endif
    oGet:overstrike( cKey )
    IF ( oGet:typeOut )
      IF ( !SET( _SET_CONFIRM ) )
        oGet:exitState := GE_ENTER
      ENDIF
    ENDIF
  ENDIF
  return NIL

**
Function spr_opl_71()
  Local blk, t_arr[BR_LEN], mtitle := 'Стоимость УЕТ для группы услуг'

  t_arr[BR_TOP] := 2
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT] := 0
  t_arr[BR_RIGHT] := 79
  t_arr[BR_OPEN] := {|| fs_opl_71(, , 'open')}
  t_arr[BR_CLOSE] := {|| dbCloseAll()}
  t_arr[BR_SEMAPHORE] := mtitle
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := mtitle
  t_arr[BR_TITUL_COLOR] := 'W+/GR'
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t., 300}
  blk := {|| if(empty(u7->usl_ins), {3, 4}, {1, 2})}
  t_arr[BR_COLUMN] := {}
  aadd(t_arr[BR_COLUMN], { 'Наименование услуг', {|| u7->name }, blk })
  aadd(t_arr[BR_COLUMN], { 'Вар;рас;чет', {|| iif(u7->variant==1, ' 1 ', ' 2 ')}, blk })
  aadd(t_arr[BR_COLUMN], { 'Врач; УЕТ; ОМС', {|| put_val_0(u7->v_uet_oms, 6, 2)}, blk })
  aadd(t_arr[BR_COLUMN], { 'Ассис.; УЕТ; ОМС', {|| put_val_0(u7->a_uet_oms, 6, 2)}, blk })
  aadd(t_arr[BR_COLUMN], { 'Врач; УЕТ;платн.', {|| put_val_0(u7->v_uet_pl , 6, 2)}, blk })
  aadd(t_arr[BR_COLUMN], { 'Ассис.; УЕТ;платн.', {|| put_val_0(u7->a_uet_pl , 6, 2)}, blk })
  aadd(t_arr[BR_COLUMN], { 'Врач; УЕТ; ДМС', {|| put_val_0(u7->v_uet_dms, 6, 2)}, blk })
  aadd(t_arr[BR_COLUMN], { 'Ассис.; УЕТ; ДМС', {|| put_val_0(u7->a_uet_dms, 6, 2)}, blk })
  aadd(t_arr[BR_COLUMN], { 'Услуги', {|| padr(u7->usl_ins, 11)}, blk })
  t_arr[BR_STAT_MSG] := {|| ;
    status_key('^<Esc>^ выход ^<Enter>^ ред-е ^<Ins>^ доб. ^<Del>^ удал. ^<Ctrl+Enter>^ услуги ^<F9>^ печать')}
  t_arr[BR_EDIT] := {|nk, ob| fs_opl_71(nk, ob, 'edit', mtitle)}
  edit_browse(t_arr)
  return NIL

**
Function fs_opl_71(nKey, oBrow, regim, mtitle)
  Static menu_variant := {{'1 - при отсутствии асс-та врачу кол-во УЕТ врача и асс-та', 1}, ;
                          {'2 - при отсутствии асс-та врачу ст-ть УЕТ врача и асс-та', 0}}
  Local ret := -1, sh
  Local buf, fl := .f., rec, rec1, k := 12, tmp_color, a_da, a_net, t_arr[2]

  do case
    case regim == 'open'
      G_Use(dir_server + 'u_usl_7', , 'U7')
      index on upper(name) to (cur_dir + 'tmp_u7')
      go top
      ret := !eof()
    case regim == 'edit'
      do case
        case nKey == K_F9
          buf := save_maxrow()
          mywait()
          rec := recno()
          arr_title := {;
            '────────────────────────────────────────────────────────────────────┬─────┬─────', ;
            '                                                                    │ Врач│Ассис', ;
            '           Наименование услуги                                      │ УЕТ │ УЕТ ', ;
            '────────────────────────────────────────────────────────────────────┴─────┴─────'}
          n_file := 'pers_o71' + stxt
          HH := 58
          Private reg_print := f_reg_print(arr_title, @sh)
          fp := fcreate(n_file)
          n_list := 1
          tek_stroke := 0
          add_string('')
          add_string(center(mtitle + ' "' + alltrim(u7->name) + '"', sh))
          add_string(center('на ' + date_month(sys_date, .t.), sh))
          add_string('')
          s := 'Cтоимость УЕТ '
          add_string(s + 'ОМС для врача          :' + str(u7->v_uet_oms, 7, 2))
          add_string(s + 'ОМС для ассистента     :' + str(u7->a_uet_oms, 7, 2))
          add_string(s + 'пл.услуг для врача     :' + str(u7->v_uet_pl , 7, 2))
          add_string(s + 'пл.услуг для ассистента:' + str(u7->a_uet_pl , 7, 2))
          add_string(s + 'ДМС для врача          :' + str(u7->v_uet_dms, 7, 2))
          add_string(s + 'ДМС для ассистента     :' + str(u7->a_uet_dms, 7, 2))
          add_string('')
          aeval(arr_title, {|x| add_string(x)})
          a_da := Slist2arr(u7->usl_ins)
          a_net := Slist2arr(u7->usl_del)
          useUch_Usl()
          R_Use(dir_server + 'uslugi', , 'USL')
          index on fsort_usl(shifr) to (cur_dir + 'tmpu')
          go top
          do while !eof()
            if _f_usl_danet(a_da, a_net)
              if verify_FF(HH, .t., sh)
                aeval(arr_title, {|x| add_string(x)})
              endif
              select UU
              find (str(usl->kod, 4))
              k := perenos(t_arr, usl->name, sh - 11 - 12)
              add_string(usl->shifr + ' ' + padr(t_arr[1], sh - 11 - 12) + ;
                       put_val_0(uu->vkoef_v, 6, 2) + put_val_0(uu->akoef_v, 6, 2))
              for i := 2 to k
                add_string(space(11) + t_arr[i])
              next
            endif
            select USL
            skip
          enddo
          uu->(dbCloseArea())
          usl->(dbCloseArea())
          fclose(fp)
          rest_box(buf)
          viewtext(n_file, , , ,(sh > 80), , , reg_print)
          select U7
        case nKey == K_INS .or. (nKey == K_ENTER .and. !empty(u7->name))
          save screen to buf
          if nkey == K_INS .and. !fl_found
            colorwin(pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/N')
            colorwin(pr1 + 4, pc1, pr1 + 4, pc2, 'N/N', 'W+/B')
          endif
          rec := recno()
          Private mname := if(nkey == K_INS, space(20), u7->name), ;
                  m1variant := if(nkey == K_INS, 0, u7->variant), ;
                  mv_uet_oms := if(nkey == K_INS, 0, u7->v_uet_oms), ;
                  ma_uet_oms := if(nkey == K_INS, 0, u7->a_uet_oms), ;
                  mv_uet_pl  := if(nkey == K_INS, 0, u7->v_uet_pl), ;
                  ma_uet_pl  := if(nkey == K_INS, 0, u7->a_uet_pl), ;
                  mv_uet_dms := if(nkey == K_INS, 0, u7->v_uet_dms), ;
                  ma_uet_dms := if(nkey == K_INS, 0, u7->a_uet_dms), ;
                  mvariant, gl_area := {1, 0,maxrow() - 1, 79, 0}
          k := maxrow() - 12
          mvariant := inieditspr(A__MENUVERT, menu_variant, m1variant)
          tmp_color := setcolor(cDataCScr)
          box_shadow(k, pc1 + 1, maxrow() - 3, pc2 - 1, , ;
                       if(nKey == K_INS, 'Добавление', 'Редактирование'), ;
                       cDataPgDn)
          setcolor(cDataCGet)
          @ k + 1, pc1 + 3 say 'Наименование группы услуг' get mname
          @ k + 2, pc1 + 3 say 'Вариант расчета' get mvariant ;
                    reader {|x|menu_reader(x, menu_variant, A__MENUVERT, , , .f.)}
          @ k + 3, pc1 + 3 say 'Cтоимость УЕТ ОМС для врача          ' get mv_uet_oms pict '999.99'
          @ k + 4, pc1 + 3 say 'Cтоимость УЕТ ОМС для ассистента     ' get ma_uet_oms pict '999.99'
          @ k + 5, pc1 + 3 say 'Cтоимость УЕТ пл.услуг для врача     ' get mv_uet_pl  pict '999.99'
          @ k + 6, pc1 + 3 say 'Cтоимость УЕТ пл.услуг для ассистента' get ma_uet_pl  pict '999.99'
          @ k + 7, pc1 + 3 say 'Cтоимость УЕТ ДМС для врача          ' get mv_uet_dms pict '999.99'
          @ k + 8, pc1 + 3 say 'Cтоимость УЕТ ДМС для ассистента     ' get ma_uet_dms pict '999.99'
          status_key('^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода')
          myread()
          if lastkey() != K_ESC .and. !empty(mname) .and. f_Esc_Enter(1)
            if nKey == K_INS
              fl_found := .t.
              AddRecN()
              rec := recno()
            else
              G_RLock(forever)
            endif
            u7->name      := mname
            u7->variant   := m1variant
            u7->v_uet_oms := mv_uet_oms
            u7->a_uet_oms := ma_uet_oms
            u7->v_uet_pl  := mv_uet_pl
            u7->a_uet_pl  := ma_uet_pl
            u7->v_uet_dms := mv_uet_dms
            u7->a_uet_dms := ma_uet_dms
            UNLOCK
            COMMIT
            oBrow:goTop()
            goto (rec)
            ret := 0
          elseif nKey == K_INS .and. !fl_found
            ret := 1
          endif
          setcolor(tmp_color)
          restore screen from buf
        case nKey == K_DEL .and. !empty(u7->name) .and. f_Esc_Enter(2)
          DeleteRec()
          oBrow:goTop()
          ret := 0
          if !found()
            ret := 1
          endif
        case nKey == K_CTRL_ENTER .and. !empty(u7->name)
          fs_opl_72({Slist2arr(u7->usl_ins), Slist2arr(u7->usl_del)})
          ret := 0
      endcase
  endcase
  return ret
  return NIL

**
Function fs_opl_72(arr)
  Local s, ar, is_write := .f.

  s := 'Список услуг для группы "' + alltrim(u7->name) + '"'
  ar := forma_nastr(s, {s}, ,arr, @is_write)
  select U7
  if is_write
    G_RLock(forever)
    replace u7->usl_ins with arr2Slist(ar[1]), ;
            u7->usl_del with arr2Slist(ar[2])
    UnLock
  endif
  return NIL

** редактирование справочников персонала, отделений, учреждений, организации
Function spr_struct_org(k)
  Static sk := 1
  Local str_sem, mas_pmt, mas_msg, mas_fun, j

  DEFAULT k TO 0
  do case
    case k == 0
      mas_pmt := {'~Персонал', ;
                  '~Отделения', ;
                  '~Учреждения', ;
                  '~Ваша организация'}
      mas_msg := {'Редактирование справочника персонала', ;
                  'Редактирование справочника отделений', ;
                  'Редактирование справочника учреждений', ;
                  'Редактирование наименования, адреса и банковских реквизитов Вашей организации'}
      mas_fun := {'spr_struct_org(1)', ;
                  'spr_struct_org(2)', ;
                  'spr_struct_org(3)', ;
                  'spr_struct_org(4)'}
      if is_uchastok > 0
        aadd(mas_pmt, 'У~частковые врачи')
        aadd(mas_msg, 'Привязка участковых врачей к участкам')
        aadd(mas_fun, 'spr_struct_org(5)')
      endif
      popup_prompt(T_ROW, T_COL + 5, sk, mas_pmt, mas_msg, mas_fun)
    case k == 1
      edit_pers()
    case k == 2
      edit_otd()
    case k == 3
      edit_uch()
    case k == 4
      str_sem := 'Редактирование реквизитов организации'
      if G_SLock(str_sem)
        f_edit_spr(A__EDIT, gmenu_organ, 'реквизитам Вашей организации', ;
                 'use_base("organiz")', 0, 1)
        G_SUnLock(str_sem)
        reRead_glob_MO() // перечитать массив glob_MO
      else
        func_error(4, err_slock)
      endif
    case k == 5
      str_sem := 'Привязка участковых врачей к участкам'
      if G_SLock(str_sem)
        f_attach_uch_vrach()
        G_SUnLock(str_sem)
      else
        func_error(4, err_slock)
      endif
  endcase
  if k > 0
    sk := k
  endif
  return NIL

** 11.10.15 привязка участковых врачей к участкам
Function f_attach_uch_vrach()
  Local i, blk, arr := {}, t_arr[BR_LEN]

  R_Use(dir_server + 'kartotek', dir_server + 'kartoteu', 'KART')
  for i := 1 to 99
    find (strzero(i, 2))
    if found()
      aadd(arr, i)
    endif
  next
  dbCloseArea()
  if len(arr) == 0
    return func_error(4, 'В картотеке не настроены участки!')
  endif
  Private p2blk := {|i| i := iif(between(p2->kateg, 1, 4), p2->kateg, 1), ;
                                      ' (' + {'вр', 'ср', 'мл', 'пр'}[i] + '.) '}
  G_Use(dir_server + 'mo_uchvr', , 'UV')
  index on str(uch, 2) to (cur_dir + 'tmp')
  for i := 1 to len(arr)
    find (str(arr[i], 2))
    if !found()
      AddRec(2)
      uv->uch := arr[i]
    else
      G_RLock(forever)
    endif
    uv->is := 1
  next
  dbUnLockAll()
  set index to
  go top
  do while !eof()
    if ascan(arr,uv->uch) == 0
      G_RLock(forever)
      uv->is := 0
    endif
    skip
  enddo
  dbUnLockAll()
  index on str(uch, 2) to (cur_dir + 'tmp') for is == 1
  t_arr[BR_TOP] := T_ROW
  t_arr[BR_BOTTOM] := maxrow() - 2
  t_arr[BR_LEFT]  := 2
  t_arr[BR_RIGHT] := 77
  t_arr[BR_COLOR] := color0
  t_arr[BR_TITUL] := '"Привязка" участковых врачей к участкам'
  t_arr[BR_TITUL_COLOR] := 'BG+/GR'
  t_arr[BR_ARR_BROWSE] := {'═', '░', '═', , .t.}
  t_arr[BR_COLUMN] := {{'Уч-к', {|| str(uv->uch, 3)+ ' ' },blk}, ;
                       {' Участковый врач', {|| padr(f1_attach_uch_vrach(), 67)}, blk}}
  t_arr[BR_EDIT] := {|nk, ob| f2_attach_uch_vrach(nk, ob, 'edit')}
  t_arr[BR_STAT_MSG] := {|| status_key('^<Esc>^ - выход;  ^<Enter>^ - редактирование участкового врача')}
  R_Use(dir_server + 'mo_pers', dir_server + 'mo_pers', 'P2')
  select UV
  go top
  edit_browse(t_arr)
  close databases
  return NIL

** 11.10.15
Function f1_attach_uch_vrach()
  Local s := ''

  select P2
  if uv->vrach > 0
    goto (uv->vrach)
    s := alltrim(p2->fio) + eval(p2blk) + ' [' + lstr(p2->tab_nom) + ']'
  elseif uv->vrachv > 0
    goto (uv->vrachv)
    if uv->vrachd > 0
      s := 'взр.: ' + fam_i_o(p2->fio) + eval(p2blk) + ' [' + lstr(p2->tab_nom) + ']'
      goto (uv->vrachd)
      s += ', дети: ' + fam_i_o(p2->fio) + eval(p2blk) + ' [' + lstr(p2->tab_nom) + ']'
    else
      s := 'взрослые: ' +alltrim(p2->fio)+eval(p2blk)+ ' [' +lstr(p2->tab_nom)+ ']'
    endif
  elseif uv->vrachd > 0
    goto (uv->vrachd)
    s := 'дети: ' + alltrim(p2->fio) + eval(p2blk) + ' [' + lstr(p2->tab_nom) + ']'
  endif
  select UV
  return s

** 11.10.15
Function f2_attach_uch_vrach(nKey, oBrow, regim)
  Local ret := -1, buf, r1, r2

  if regim == 'edit' .and. nKey == K_ENTER
    save screen to buf
    if nkey == K_INS .and. !fl_found
      colorwin(pr1 + 4, pc1, pr1 + 4, pc2, 'W/W', 'GR+/R')
    endif
    Private gl_area := {1, 0, maxrow() - 1, 79, 0}, ;
          m1vrach  := uv->vrach , ;
          m1vrachv := uv->vrachv, ;
          m1vrachd := uv->vrachd, ;
          mvrach  := space(36), ;
          mvrachv := space(36), ;
          mvrachd := space(36), ;
          mtab_nom  := 0, ;
          mtab_nomv := 0, ;
          mtab_nomd := 0
    select P2
    if m1vrach > 0
      goto (m1vrach)
      MTAB_NOM := p2->tab_nom
      mvrach := padr(fam_i_o(p2->fio) + eval(p2blk) + ' ' + ret_tmp_prvs(p2->prvs, p2->prvs_new), 36)
    endif
    if m1vrachv > 0
      goto (m1vrachv)
      MTAB_NOMv := p2->tab_nom
      mvrachv := padr(fam_i_o(p2->fio) + eval(p2blk) + ' ' + ret_tmp_prvs(p2->prvs, p2->prvs_new), 36)
    endif
    if m1vrachd > 0
      goto (m1vrachd)
      MTAB_NOMd := p2->tab_nom
      mvrachd := padr(fam_i_o(p2->fio) + eval(p2blk) + ' ' + ret_tmp_prvs(p2->prvs, p2->prvs_new), 36)
    endif
    select UV
    tmp_color := setcolor(cDataCScr)
    box_shadow(pr2 - 5, 2, pr2 - 1, 77, , 'Редактирование участкового врача', cDataPgDn)
    setcolor(cDataCGet)
    @ pr2 - 4, 4 say 'Участ.врач (все возраста)' get mtab_nom pict '99999' ;
            valid {|g| v_kart_vrach_spr(g, 1)} ;
            when emptyall(m1vrachv, m1vrachd)
    @ row(), col() + 1 get mvrach when .f. color color14
    @ pr2 - 3, 4 say 'Участ.врач (взрослые)' get mtab_nomv pict '99999' ;
            valid {|g| v_kart_vrach_spr(g, 2)} ;
            when empty(m1vrach)
    @ row(), col() + 1 get mvrachv when .f. color color14
    @ pr2 - 2, 4 say 'Участ.врач (дети)' get mtab_nomd pict '99999' ;
            valid {|g| v_kart_vrach_spr(g, 3)} ;
            when empty(m1vrach)
    @ row(), col() + 1 get mvrachd when .f. color color14
    status_key('^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода')
    myread()
    if lastkey() != K_ESC .and. f_Esc_Enter(1)
      G_RLock(forever)
      uv->vrach  := m1vrach
      uv->vrachv := m1vrachv
      uv->vrachd := m1vrachd
      UnLock
      COMMIT
      ret := 0
    endif
    setcolor(tmp_color)
    restore screen from buf
  endif
  return ret

** 08.11.22 определить врача по табельному номеру для редактирования справочников
Function v_kart_vrach_spr(get, k)
  Local fl := .t.

  Private tmp := readvar()
  if &tmp != get:original
    if &tmp == 0
      do case
        case k == 1
          m1vrach := 0
          mvrach := space(36)
        case k == 2
          m1vrachv := 0
          mvrachv := space(36)
        case k == 3
          m1vrachd := 0
          mvrachd := space(36)
      endcase
    elseif &tmp != 0
      select P2
      find (str(&tmp, 5))
      if found()
        do case
          case k == 1
            m1vrach := p2->kod
            mvrach := padr(fam_i_o(p2->fio) + eval(p2blk) + ' ' + ret_tmp_prvs(p2->prvs, p2->prvs_new), 36)
          case k == 2
            m1vrachv := p2->kod
            mvrachv := padr(fam_i_o(p2->fio) + eval(p2blk) + ' ' + ret_tmp_prvs(p2->prvs, p2->prvs_new), 36)
          case k == 3
            m1vrachd := p2->kod
            mvrachd := padr(fam_i_o(p2->fio) + eval(p2blk) + ' ' + ret_tmp_prvs(p2->prvs, p2->prvs_new), 36)
        endcase
      else
        fl := func_error(3, 'Не найден сотрудник с табельным номером ' + lstr(&tmp) + ' в справочнике персонала!')
      endif
      select UV
    endif
    if !fl
      &tmp := get:original
      return .f.
    endif
    do case
      case k == 1
        update_get('mvrach')
      case k == 2
        update_get('mvrachv')
      case k == 3
        update_get('mvrachd')
    endcase
  endif
  return .t.

** 08.11.22 проверка правильности введенного кода ТФОМС
Function valid_kod_tfoms(get)
  Local fl := .t., i, cCode := left(mkod_tfoms, 6)

  if (i := ascan(glob_arr_mo, {|x| x[_MO_KOD_TFOMS] == cCode})) > 0
    glob_mo := glob_arr_mo[i]
    mname_tfoms := padr(glob_mo[_MO_SHORT_NAME], 60)
    muroven := get_uroven()
  else
    fl := func_error(4, 'Вы ввели несуществующий код МО "' + cCode + '". Попробуйте ешё раз.')
    mkod_tfoms := get:original
  endif
  return fl

** 13.11.22 редактирование справочника отделений
Function edit_otd()
  Local i, j, blk, arr[US_LEN], fl

  if input_uch(T_ROW - 1, T_COL + 5) == NIL
    return NIL
  endif
  Private tmp_V002 := create_classif_FFOMS(1, 'V002') // PROFIL
  Private tmp_V020 := create_classif_FFOMS(1, 'V020') // PROFIL_K
  Private tmp_V006 := create_classif_FFOMS(1, 'V006') // USL_OK
  //Private tmp_V008 := create_classif_FFOMS(1, 'V008') // VIDPOM
  //Private tmp_V010 := create_classif_FFOMS(1, 'V010') // IDSP
  Private mm_adres_podr := {}
  Private mm_tiplu := {;
    {'стандартный'                          , 0           }, ;  // 1
    {'скорая медицинская помощь'            ,TIP_LU_SMP  }, ;  // 2
    {'дисп-ия детей-сирот в стационаре'     ,TIP_LU_DDS  }, ;  // 3
    {'дисп-ия детей-сирот под опекой'       ,TIP_LU_DDSOP}, ;  // 4
    {'профилактика несовешеннолетних'       ,TIP_LU_PN   }, ;  // 5
    {'предварит.осмотры несовешеннолетних'  ,TIP_LU_PREDN}, ;  // 6
    {'периодич.осмотры несовешеннолетних'   ,TIP_LU_PERN }, ;  // 7
    {'диспансеризация/профосмотр взрослых'  ,TIP_LU_DVN  }, ;  // 8
    {'пренатальная диагностика'             ,TIP_LU_PREND}, ;  // 9
    {'гемодиализ'                           ,TIP_LU_H_DIA}, ;  // 10
    {'перитонеальный диализ'                ,TIP_LU_P_DIA}, ;  // 11
    {'COVID - углубленная диспансеризация' ,TIP_LU_DVN_COVID}, ;  // 15
    {'медицинская реабилитация'            ,TIP_LU_MED_REAB}, ;  // 16
    {'постановка на наблюдение онкопациентов',TIP_LU_ONKO_DISP}}  // 17
  if glob_mo[_MO_KOD_TFOMS] == '126501'
    Ins_Array(mm_tiplu, 3, {'неотложная медицинская помощь', TIP_LU_NMP})
  endif
  if ascan(glob_klin_diagn, 1) > 0
    aadd(mm_tiplu, {'жидкостная цитология рака шейки матки', TIP_LU_G_CIT})
  elseif ascan(glob_klin_diagn, 2) > 0
    aadd(mm_tiplu, {'пренатальный скрининг наруш.внутр.разв.', TIP_LU_G_CIT})
  endif
  Private mm1tiplu := aclone(mm_tiplu)
  hb_ADel( mm1tiplu, 7 , .t. )
  hb_ADel( mm1tiplu, 6 , .t. )
  blk := {|| iif(between_date(dbegin,dend), {1, 2}, {3, 4})}
  arr[US_BOTTOM   ] := maxrow() - 2
  arr[US_LEFT     ] := 2
  arr[US_RIGHT    ] := 77
  arr[US_BASE     ] := dir_server + 'mo_otd'
  arr[US_TITUL    ] := glob_uch[2]
  arr[US_TITUL_COLOR] := 'BG+/GR'
  arr[US_ARR_BROWSE]:= {'═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t.}
  arr[US_BLK_FILTER]:= {|| dbSetFilter( {|| kod_lpu == glob_uch[1]}, 'kod_lpu == glob_uch[1]' )}
  arr[US_BLK_WRITE] := {|| __us->kod_lpu := glob_uch[1] }
  arr[US_COLUMN   ] := {{' Наименование отделения', {|| name}, blk}, ;
                      {' ', {|| iif(empty(KOD_PODR), ' ', '√')}, blk}, ;
                      {'Сокр.', {|| short_name}, blk}, ;
                      {' Вид листа учёта', {|| padr(inieditspr(A__MENUVERT, mm_tiplu,tiplu), 19)}, blk}, ;
                      {' Профиль', {|| padr(inieditspr(A__MENUVERT, glob_V002, profil), 15)}, blk} ;
                     }
  arr[US_BLK_DEL  ] := {|_k| fdel_otd(_k)}
  arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := 'отделения'
  arr[US_ROD_PADEG] := 'отделений'
  arr[US_EDIT_SPR ] := {{'name', 'C', 30, 0, , ,space(30), , 'Наименование отделения'}, ;
                      {'short_name', 'C', 5, 0, , ,space(5), , 'Сокращённое наименование отделения'}, ;
                      {'TIPLU', 'N', 2, 0, , ;
                       {|x|menu_reader(x, mm1tiplu, A__MENUVERT, , , .f.)}, ;
                       0, {|x|inieditspr(A__MENUVERT, mm_tiplu, x)}, ;
                       'Вид листа учёта при вводе данных'}, ;
                      {'TIP_OTD', 'N', 2, 0, , ;
                       {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}, ;
                       0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
                       'Является данное отделение приёмным покоем стационара'}, ;
                      {'PROFIL', 'N', 3, 0, , ;
                       {|x|menu_reader(x, tmp_V002, A__MENUVERT_SPACE, , , .f.)}, ;
                       0, {|x|inieditspr(A__MENUVERT, glob_V002, x)}, ;
                       'Профиль мед.помощи'}, ;
                      {'PROFIL_K', 'N', 3, 0, , ;
                       {|x|menu_reader(x, tmp_V020, A__MENUVERT_SPACE, , , .f.)}, ;
                       0, {|x|inieditspr(A__MENUVERT, getV020(), x)}, ;
                       'Профиль койки'}, ;
                      {'IDUMP', 'N', 2, 0, , ;
                       {|x|menu_reader(x, tmp_V006, A__MENUVERT, , , .f.)}, ;
                       0, {|x|inieditspr(A__MENUVERT, getV006(), x)}, ;
                       'Условия оказания медицинской помощи'}, ;
                      {'KOD_PODR', 'C', 25, 0, , ;
                       {|x| menu_reader(x, {{|k, r, c| get_kod_podr(k, r, c)}}, A__FUNCTION, , , .f.)}, ;
                       '', {|x| ini_kod_podr(x)}, ;
                       'Код подразделения из паспорта ЛПУ'}, ;
                      {'ADDRESS', 'C', 150, 0, , ,space(150), , 'Адрес'}, ;
                      {'dbegin', 'D', 8, 0, , ,boy(sys_date), , ;
                       'Дата начала работы в задаче ОМС'}, ;
                      {'dend', 'D', 8, 0, , ,ctod(''), , ;
                       '     Дата окончания работы в задаче ОМС'};
                      }
  if is_otd_dep
    Ins_Array(arr[US_EDIT_SPR], 6, {'CODE_DEP', 'N', 2, 0, , ;
                                {|x|menu_reader(x, mm_otd_dep, A__MENUVERT_SPACE, , , .f.)}, ;
                                0, {|x|inieditspr(A__MENUVERT, mm_otd_dep, x)}, ;
                                'По справочнику ТФОМС'})
  endif
  /*if is_adres_podr
    if (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
      for j := 1 to len(glob_adres_podr[i, 2])
        aadd(mm_adres_podr, {glob_adres_podr[i, 2,j, 3],glob_adres_podr[i, 2,j, 2]})
      next
    endif
    Ins_Array(arr[US_EDIT_SPR], 7, {'ADRES_PODR', 'N', 2, 0, , ;
                                {|x|menu_reader(x,mm_adres_podr,A__MENUVERT, , , .f.)}, ;
                                0, {|x|inieditspr(A__MENUVERT,mm_adres_podr,x)}, ;
                                'Адрес удалённого подразделения для стационара'})
  endif
  if is_adres_podr .and. (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
    G_Use(dir_server + 'mo_otd', , 'OTD')
    go top
    do while !eof()
      if otd->ADRES_PODR > 0 .and. (j := ascan(glob_adres_podr[i, 2], {|x| x[2] == otd->ADRES_PODR })) > 0 ;
                           .and. !(otd->CODE_TFOMS == glob_adres_podr[i, 2,j, 1])
        G_RLock(forever)
        otd->CODE_TFOMS := glob_adres_podr[i, 2,j, 1]
        UnLock
      endif
      skip
    enddo
    close databases
  endif*/
  if is_task(X_PLATN)
    aadd(arr[US_EDIT_SPR], {'dbeginp', 'D', 8, 0, , , boy(sys_date), , ;
                         'Дата начала работы в задаче "Платные услуги"'})
    aadd(arr[US_EDIT_SPR], {'dendp', 'D', 8, 0, , , ctod(''), , ;
                         '     Дата окончания работы в задаче "Платные услуги"'})
  endif
  if is_task(X_ORTO)
    aadd(arr[US_EDIT_SPR], {'dbegino', 'D', 8, 0, , , boy(sys_date), , ;
                         'Дата начала работы в задаче "Ортопедия"'})
    aadd(arr[US_EDIT_SPR], {'dendo', 'D', 8, 0, , , ctod(''), , ;
                         '     Дата окончания работы в задаче "Ортопедия"'})
  endif
  aadd(arr[US_EDIT_SPR], {'PLAN_VP', 'N', 6, 0, , , 0, , 'План врачебных приемов на месяц'})
  aadd(arr[US_EDIT_SPR], {'PLAN_PF', 'N', 6, 0, , , 0, , 'План профилактик на месяц'})
  aadd(arr[US_EDIT_SPR], {'PLAN_PD', 'N', 6, 0, , , 0, , 'План приемов на дому на месяц'})
  edit_u_spr(1, arr)
  /*if is_adres_podr .and. (i := ascan(glob_adres_podr, {|x| x[1] == glob_mo[_MO_KOD_TFOMS] })) > 0
    G_Use(dir_server + 'mo_otd', , 'OTD')
    go top
    do while !eof()
      if otd->ADRES_PODR > 0 .and. (j := ascan(glob_adres_podr[i, 2], {|x| x[2] == otd->ADRES_PODR })) > 0 ;
                           .and. !(otd->CODE_TFOMS == glob_adres_podr[i, 2,j, 1])
        G_RLock(forever)
        otd->CODE_TFOMS := glob_adres_podr[i, 2,j, 1]
        UnLock
      endif
      skip
    enddo
    close databases
  endif*/
  return NIL

** 08.11.22
Function fdel_otd(k)
  Local _fl, i, tmp_select := select()

  R_Use(dir_server + 'mo_pers', , '__B')
  dbLocateProgress( {|| __b->otd == k} )
  _fl := !found()
  dbCloseArea()
  if _fl
    R_Use(dir_server + 'human', dir_server + 'humann', '__B')
    for i := 0 to 9
      find (str(i, 1) + str(k, 3)) // index on str(tip_h, 1)+ str(otd, 3)+...
      if found()
        _fl := .f.
        exit
      endif
    next
    dbCloseArea()
  endif
  if _fl
    R_Use(dir_server + 'hum_p', dir_server + 'hum_pn', '__B')
    find (str(k, 3)) // index on str(otd, 3)+...
    _fl := !found()
    dbCloseArea()
  endif
  select (tmp_select)
  return _fl

** 08.11.22
Function get_kod_podr(k, r, c)
  Static arr
  Local ret, ret_arr, tmp_select

  if arr == NIL // только при первом вызове
    arr := {}
    tmp_select := select()
    R_Use(exe_dir + '_mo_podr', cur_dir + '_mo_podr', 'PODR')
    find (glob_mo[_MO_KOD_TFOMS])
    do while podr->codemo == glob_mo[_MO_KOD_TFOMS] .and. !eof()
      aadd(arr, {'(' + alltrim(podr->KODOTD) + ') ' + alltrim(podr->NAMEOTD), podr->KODOTD})
      skip
    enddo
    dbCloseArea()
    select (tmp_select)
  endif
  popup_2array(arr, -r, c, k, 1, @ret_arr, 'Выбор из паспорта ЛПУ', 'GR+/RB', 'BG+/RB,N/BG')
  if valtype(ret_arr) == 'A'
    ret := array(2)
    ret[1] := ret_arr[2]
    ret[2] := ret_arr[1]
  endif
  return ret
  return {lkod, s}

** 08.11.22
Function ini_kod_podr(lkod)
  Local s := space(10), tmp_select := select()

  R_Use(exe_dir + '_mo_podr', cur_dir + '_mo_podr', 'PODR')
  find (glob_mo[_MO_KOD_TFOMS] + padr(upper(lkod), 25))
  if found()
    s := '(' + alltrim(podr->KODOTD) + ') ' + alltrim(podr->NAMEOTD)
  endif
  dbCloseArea()
  select (tmp_select)
  return s

** редактирование справочника учреждений
Function edit_uch()
  Local blk, arr[US_LEN]

  blk := {|| iif(between_date(dbegin, dend), {1, 2}, {3, 4})}
  arr[US_BOTTOM   ] := maxrow() - 2
  arr[US_LEFT     ] := T_COL + 5
  arr[US_RIGHT    ] := arr[US_LEFT] + 48
  arr[US_BASE     ] := dir_server + 'mo_uch'
  arr[US_ARR_BROWSE]:= {'═', '░', '═', 'N/BG,W+/N,B/BG,W+/B', .t.}
  arr[US_COLUMN   ] := {{' Наименование', {|| name}, blk}, ;
                        {'Сокр.;наим.', {|| SHORT_NAME }, blk}, ;
                        {'Работа с;талоном', {|| padc(inieditspr(A__MENUVERT, mm_danet, is_talon), 8)}, blk}}
  arr[US_BLK_DEL  ] := {|_k| fdel_uch(_k)}
  arr[US_IM_PADEG ] := arr[US_SEMAPHORE] := 'учреждения'
  arr[US_ROD_PADEG] := 'учреждений'
  arr[US_EDIT_SPR ] := {{'name', 'C', 30, 0, , ,space(30), , 'Наименование учреждения'}, ;
                          {'short_name', 'C', 5, 0, , ,space(5), , 'Сокращённое наименование'}, ;
                          {'ADDRESS', 'C', 150, 0, , ,space(150), , 'Адрес'}, ;
                          {'is_talon', 'N', 1, 0, , ;
                            {|x|menu_reader(x,mm_danet, A__MENUVERT, , , .f.)}, ;
                              0, {|x|inieditspr(A__MENUVERT,mm_danet,x)}, ;
                            'Работаем со стат.талоном?'}, ;
                          {'dbegin', 'D', 8, 0, , ,boy(sys_date), , ;
                            'Дата начала работы с учреждением'}, ;
                          {'dend', 'D', 8, 0, , ,ctod(''), , ;
                            '     Дата окончания работы'};
                        }
  edit_u_spr(1, arr)
  return NIL

** 08.11.22
Function fdel_uch(k)
  Local _fl, tmp_select := select()

  R_Use(dir_server + 'mo_otd', , '__B')
  dbLocateProgress( {|| __b->kod_lpu == k} )
  _fl := !found()
  dbCloseArea()
  select (tmp_select)
  return _fl

** редактирование справочника прочих компаний
Function edit_strah()
  Static mas_edit := { '~Просмотр', ;
                      '~Редактирование', ;
                      '~Добавление', ;
                      '~Удаление'}
  Local arr := aclone(gmenu_strah)
  Local i := 1, k, buf := savescreen(), str_sem := 'Редактирование прочих компаний'

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  if (k := ascan(arr, {|x| lower(x[1]) == 'tfoms'})) > 0
    Del_Array(arr, k)
  endif
  do while i > 0
    if (i := popup_prompt(T_ROW, T_COL + 5, i, mas_edit, , , , .f.)) == A__APPEND
      if (k := f_edit_spr(A__APPEND, arr, 'прочей компании', ;
                        'use_base("str_komp")', 2, , , , , , 'f_emp_strah')) > 0
        glob_strah[1] := k
      endif
    elseif i != 0 .and. ;
      (k := popup_edit(dir_server + 'str_komp', T_ROW + i + 1, T_COL + 5, ;
              T_ROW + i + 7, glob_strah[1], PE_RETURN, , , , {||!between(tfoms, 44, 47)})) != NIL
      glob_strah := k
      f_edit_spr(i, arr, 'прочей компании', ;
              'use_base("str_komp")', 2, k[1], , 'fdel_strah', , , 'f_emp_strah')
    endif
  enddo
  G_SUnLock(str_sem)
  restscreen(buf)
  return NIL

** редактирование справочника комитетов (МО)
Function edit_komit(d)
  Static mas_edit := { '~Просмотр', ;
                      '~Редактирование', ;
                      '~Добавление', ;
                      '~Удаление'}
  Local i := 1, k, buf := savescreen(), str_sem := 'Редактирование комитетов (МО)'

  if !G_SLock(str_sem)
    return func_error(4, err_slock)
  endif
  do while i > 0
    if (i := popup_prompt(T_ROW, T_COL + 5, i, mas_edit, , , , .f.)) == A__APPEND
      if (k := f_edit_spr(A__APPEND, gmenu_komit, 'комитету (МО)', ;
                        'use_base("komitet")', 2, , , , , , 'f_emp_strah')) > 0
        glob_komitet[1] := k
      endif
    elseif i != 0 .and. ;
          (k := popup_edit(dir_server + 'komitet', T_ROW + i + 1, T_COL + 5, ;
                          T_ROW + i + 7, glob_komitet[1], PE_RETURN)) != NIL
      glob_komitet := k
      f_edit_spr(i, gmenu_komit, 'комитету (МО)', ;
              'use_base("komitet")', 2, k[1], , 'fdel_komit', , , 'f_emp_strah')
    endif
  enddo
  G_SUnLock(str_sem)
  restscreen(buf)
  return NIL

**
Function fdel_strah(k)
  Local fl := fdel_ksc(1, k)

  if !fl
    func_error(4, 'Данная компания встречается в других базах данных!')
  endif
  return fl

**
Function fdel_komit(k)
  Local fl := fdel_ksc(3, k)

  if !fl
    func_error(4, 'Данный комитет (МО) встречается в других базах данных!')
  endif
  return fl

** 08.11.22
Function fdel_ksc(n, k)
  Local fl := .t., buf, i, afile := {'kartotek', 'human'}

  if k == 1
    buf := save_maxrow()
    stat_msg('Ждите! Производится проверка на допустимость удаления.')
    for i := 1 to len(afile)
      R_Use(dir_server + afile[i], , 'KK')
      Locate for kk->komu == n .and. kk->str_crb == mkod ;
               progress {'GR+/B', 'GR+/B', 'W*/B'} NUMPROCENT
      fl := !found()
      dbCloseArea()
      if !fl
        exit
      endif
    next
    rest_box(buf)
  endif
  return fl

**
Function f_emp_strah(k)
  Local fl := .t.

  if k == 1 .and. empty(mname)
    fl := func_error(4, 'Поле НАЗВАНИЕ не должно быть пустым!')
  endif
  return fl
