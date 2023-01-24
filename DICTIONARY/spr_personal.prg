#include 'set.ch'
#include 'getexit.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

** 15.08.17 редактирование справочника персонала
Function edit_pers()
  Local buf, fl := .f., arr_blk, str_sem := 'Редактирование персонала'

  if G_SLock(str_sem)
    buf := save_maxrow()
    mywait()
    Private tmp_V002 := create_classif_FFOMS(0, 'V002') // PROFIL
    Private str_find := '1', muslovie := 'p2->kod > 0'
    arr_blk := {{|| FindFirst(str_find)}, ;
                {|| dbGoBottom()}, ;
                {|n| SkipPointer(n, muslovie)}, ;
                str_find,muslovie;
               }
    if Use_base('mo_pers')
      index on iif(kod>0,'1','0')+upper(fio) to (cur_dir + 'tmp_pers')
      set index to (cur_dir + 'tmp_pers'),(dir_server + 'mo_pers')
      find (str_find)
      if !found()
        keyboard chr(K_INS)
      endif
      Private mr := T_ROW
      rest_box(buf)
      Alpha_Browse(T_ROW, 0,maxrow() - 1, 79, 'f1edit_pers',color0, , , , ,arr_blk, , 'f2edit_pers', , ;
                   {'═', '░', '═', 'N/BG,W+/N,B/BG,BG+/B,N+/BG,W/N', .t.} )
    endif
    close databases
    G_SUnLock(str_sem)
    rest_box(buf)
  else
    func_error(4, err_slock)
  endif
  return NIL

** 18.10.22
Function f1edit_pers(oBrow)
  Static ak := {'   ', 'вр.', 'ср.', 'мл.', 'пр.'}
  Local oColumn, nf := 27, n := 19, ;
      blk := {|| iif(between_date(dbegin, dend), ;
                        iif(P2->tab_nom > 0, {1, 2}, {5, 6}), ;
                        {3, 4})}

  oColumn := TBColumnNew(center('Ф.И.О.', nf), {|| left(P2->fio, nf)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('Таб.№', {|| put_val(P2->tab_nom, 5)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(padc('СНИЛС', 14), {|| transform(p2->SNILS, picture_pf)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('Кат', {|| ak[P2->kateg + 1]})
  oColumn:colorBlock := blk
  // oBrow:addColumn(oColumn)
  // oColumn := TBColumnNew(center('Специальность', n), {|| padr(ret_tmp_prvs(p2->prvs, p2->prvs_new), n)})
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew(center('Специальность', n), ;
        {|| padr(inieditspr(A__MENUVERT, getV021(), p2->prvs_021), n)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  oColumn := TBColumnNew('Свод.;таб.№', {|| put_val(P2->svod_nom, 5)})
  oColumn:colorBlock := blk
  oBrow:addColumn(oColumn)
  status_key('^<Esc>^ выход ^<Enter>^ редактирование ^<Ins>^ добавление ^<Del>^ удаление ^<F9>^ печать')
  @ mr, 62 say ' <F2> - поиск ' color 'GR+/BG'
  mark_keys({'<F2>'}, 'R/BG')
  return NIL

** 15.08.17
Function f2edit_pers(nKey, oBrow)
  Static gmenu_kateg := {{'врач                ', 1}, ;
                        {'средний мед.персонал', 2}, ;
                        {'младший мед.персонал', 3}, ;
                        {'прочие              ', 4}}
  Static menu_vr_kateg := {{'без категории   ', 0}, ;
                          {'2-ая категория  ', 1}, ;
                           {'1-ая категория  ', 2}, ;
                           {'высшая категория', 3}}
  Static osn_sovm := {{'основная работа', 0}, ;
                      {'совмещение     ', 1}}
  Local buf, fl := .f., rec, rec1, j, k, tmp_color, mkod, tmp_nhelp, r, ret := -1

  do case
    case nKey == K_F2
      return f4edit_pers(K_F2)
    case nKey == K_F9
      if (j := f_alert({padc('Выберите порядок сортировки при печати', 60, '.')}, ;
                     {' По ФИО ', ' По таб.номеру '}, ;
                     1, 'W+/N', 'N+/N',maxrow() - 2, , 'W+/N,N/BG' )) == 0
        return ret
      endif
      rec := p2->(recno())
      buf := save_maxrow()
      mywait()
      name_file := 'tab_nom' + stxt
      fp := fcreate(name_file)
      n_list := 1
      tek_stroke := 0
      sh := 81
      HH := 60
      add_string('')
      add_string(center('Список работающего персонала с табельными номерами', sh))
      add_string('')
      if j == 1
        set order to 1
        find (str_find)
        do while !eof()
          if between_date(dbegin, dend)
            verify_FF(HH, .t., sh)
            s := str(p2->tab_nom, 5) + ;
                iif(empty(p2->svod_nom), space(7), padl('(' + lstr(p2->svod_nom) + ')', 7)) + ;
                ' ' + padr(p2->fio, 40) + ' ' + transform(p2->SNILS, picture_pf) + ' ' + ;
            ret_tmp_prvs(p2->prvs,p2->prvs_new)
            add_string(s)
          endif
          skip
        enddo
      else
        set order to 2
        go top
        do while !eof()
          if kod > 0 .and. between_date(dbegin, dend)
            verify_FF(HH, .t., sh)
            s := str(p2->tab_nom, 5) + ;
                iif(empty(p2->svod_nom), space(7), padl('(' + lstr(p2->svod_nom) + ')', 7)) + ;
                ' ' + padr(p2->fio, 40) + ' ' + transform(p2->SNILS, picture_pf) + ' ' + ;
              ret_tmp_prvs(p2->prvs, p2->prvs_new)
            add_string(s)
          endif
          skip
        enddo
      endif
      set order to 2
      go bottom
      max_nom := p2->tab_nom
      verify_FF(HH-3, .t., sh)
      add_string(replicate('=', sh))
      add_string(center('Список свободных табельных номеров:', sh))
      s := ''
      k := 0
      for i := 1 to max_nom
        find (str(i, 5))
        if !found()
          s += lstr(i) + ', '
          if len(s) > sh
            verify_FF(HH, .t., sh)
            add_string(s)
            s := ''
            if ++k > 10
              add_string('...')
              exit
            endif
          endif
        endif
      next
      if !empty(s)
        add_string(s)
      endif
      set order to 1
      goto (rec)
      fclose(fp)
      rest_box(buf)
      viewtext(name_file, , , , .t., , , 2)
    case nKey == K_INS .or. (nKey == K_ENTER .and. kod > 0)
      save screen to buf
      Private mfio := space(50), m1uch := 0, m1otd := 0, m1kateg := 1, ;
            much, motd, mname_dolj := space(30), mkateg, mstavka := 1, ;
            mvid, m1vid := 0, mtab_nom := 0, msvod_nom := 0, mkod_dlo := 0, ;
            mvr_kateg, m1vr_kateg := 0, msnils := space(11), mprofil, m1profil := 0, fl_profil := .f., ;
            mDOLJKAT := space(15), mD_KATEG := ctod(''), ;
            mSERTIF, m1sertif := 0, mD_SERTIF := ctod(''), ;
            mPRVS, m1prvs := 0, muroven := 0, motdal := 0, ;
            mDBEGIN := boy(sys_date), mDEND := ctod(''), ;
            gl_area := {1, 0,maxrow() - 1, 79, 0}, ;
            mprvs_021, m1prvs_021 := 0
      if nKey == K_ENTER
        mkod       := recno()
        mfio       := p2->fio
        mtab_nom   := p2->tab_nom
        msvod_nom  := p2->svod_nom
        m1uch      := p2->uch
        m1otd      := p2->otd
        m1kateg    := p2->kateg
        mname_dolj := p2->name_dolj
        mstavka    := p2->stavka
        m1vid      := p2->vid
        mtab_nom   := p2->tab_nom
        msvod_nom  := p2->svod_nom
        mkod_dlo   := p2->kod_dlo
        m1vr_kateg := p2->vr_kateg
        mDOLJKAT   := p2->DOLJKAT
        mD_KATEG   := p2->D_KATEG
        m1sertif   := p2->sertif
        mD_SERTIF  := p2->D_SERTIF
        m1prvs     := ret_new_spec(p2->prvs, p2->prvs_new)
        m1prvs_021 := p2->prvs_021
        if fieldpos('profil') > 0
          fl_profil := .t.
          m1profil := p2->profil
        endif
        muroven    := p2->uroven
        motdal     := p2->otdal
        msnils     := p2->snils
        mDBEGIN    := p2->DBEGIN
        mDEND      := p2->DEND
      endif
      if mstavka <= 0
        mstavka := 1
      endif
      much      := inieditspr(A__POPUPBASE, dir_server + 'mo_uch', m1uch)
      motd      := inieditspr(A__POPUPBASE, dir_server + 'mo_otd', m1otd)
      mkateg    := inieditspr(A__MENUVERT, gmenu_kateg, m1kateg)
      mvid      := inieditspr(A__MENUVERT, osn_sovm, m1vid)
      mvr_kateg := inieditspr(A__MENUVERT, menu_vr_kateg, m1vr_kateg)
      msertif   := inieditspr(A__MENUVERT, mm_danet, m1sertif)
      m1prvs    := iif(empty(m1prvs), space(4), padr(lstr(m1prvs), 4))
      mprvs     := ret_tmp_prvs(0, m1prvs)

      m1prvs_021:= iif(empty(m1prvs_021), space(4), padr(lstr(m1prvs_021), 4))
      mprvs_021 := inieditspr(A__MENUVERT, getV021(), val(m1prvs_021))

      tmp_color := setcolor(cDataCScr)
      k := maxrow() - 19
      if fl_profil
        --k
        // mprofil := inieditspr(A__MENUVERT, glob_V002, m1profil)
        mprofil := inieditspr(A__MENUVERT, getV002(), m1profil)
      endif
      box_shadow(k - 1, 0, maxrow() - 1, 79, , ;
            if(nKey == K_INS, 'Добавление', 'Редактирование') + ' информации о сотруднике', color8)
      setcolor(cDataCGet)
      r := k
      @ ++r, 2 say 'Табельный номер' get mtab_nom picture '99999' ;
                valid {|g| val_tab_nom(g, nKey)}
      @ r, 36 say 'Сводный табельный номер' get msvod_nom picture '99999'
      @ ++r, 2 say 'Ф.И.О.' get mfio
      @ ++r, 2 say 'СНИЛС' get msnils picture picture_pf valid val_snils(msnils, 1)
      @ ++r, 2 say 'Мед.специальность' get mPRVS ;
                reader {|x|menu_reader(x, {{|k, r, c| fget_tmp_V015(k, r, c)}}, A__FUNCTION, , , .f.)} ;
                valid {|g| set_prvs(g, 1)}
      @ ++r, 2 say 'Мед.специальность V021' get mPRVS_021 ;
                reader {|x|menu_reader(x, getV021(), A__MENUVERT_SPACE, , , .f.)} ;
                valid {|g| set_prvs(g, 2)}
      if fl_profil
        @ ++r, 2 say 'Профиль' get mprofil ;
                  reader {|x|menu_reader(x, tmp_V002, A__MENUVERT_SPACE, , , .f.)}
      endif
      @ ++r, 2 say 'Учр-е' get much ;
                reader {|x|menu_reader(x, {{|k, r, c| ret_uch_otd(k, r, c)}}, A__FUNCTION, , , .f.)}
      @ r, 39 say 'Отделение' get motd when .f.
      @ ++r, 2 say 'Категория' get mkateg ;
                reader {|x|menu_reader(x, gmenu_kateg, A__MENUVERT, , , .f.)}
      @ ++r, 2 say 'Наименование должности' get mname_dolj
      @ ++r, 2 say 'Вид работы' get mvid ;
                reader {|x|menu_reader(x, osn_sovm, A__MENUVERT, , , .f.)}
      @ r, 36 say 'Ставка' color color8 get mstavka picture '9.99'
      @ ++r, 2 say 'Медицинская категория' get mvr_kateg ;
                reader {|x|menu_reader(x, menu_vr_kateg, A__MENUVERT, , , .f.)}
      @ ++r, 2 say 'Наименование должности по мед.категории' get mDOLJKAT
      @ ++r, 2 say 'Дата подтверждения мед.категории' get mD_KATEG
      @ ++r, 2 say 'Наличие сертификата' get mSERTIF ;
                reader {|x|menu_reader(x, mm_danet, A__MENUVERT, , , .f.)}
      @ ++r, 2 say 'Дата подтверждения сертификата' get mD_SERTIF
      @ ++r, 2 say 'Код врача для выписки рецептов по ДЛО' get mKOD_DLO pict '99999'
      @ ++r, 2 say 'Дата начала работы в должности' get mDBEGIN
      @ ++r, 2 say 'Дата окончания работы' get mDEND
      status_key('^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение ввода')
      myread()
      if lastkey() != K_ESC .and. !empty(mfio) .and. f_Esc_Enter(1)
        select P2
        if nKey == K_INS
          find ('0')
          if found()
            G_RLock(forever)
          else
            AddRecN()
          endif
          mkod := recno()
          replace kod with recno()
        else
          goto (mkod)
          G_RLock(forever)
        endif
        p2->fio      := mfio
        p2->tab_nom  := mtab_nom
        p2->svod_nom := msvod_nom
        p2->uch      := m1uch
        p2->otd      := m1otd
        p2->kateg    := m1kateg
        p2->name_dolj:= mname_dolj
        p2->stavka   := mstavka
        p2->vid      := m1vid
        p2->vr_kateg := m1vr_kateg
        p2->DOLJKAT  := mDOLJKAT
        p2->D_KATEG  := mD_KATEG
        p2->sertif   := m1sertif
        p2->D_SERTIF := mD_SERTIF
        p2->prvs_new := iif(valtype(m1prvs) == 'C', val(m1prvs), m1prvs)
        p2->prvs_021 := iif(valtype(m1prvs_021) == 'C', val(m1prvs_021), m1prvs_021)  //val(m1prvs_021)
        if fl_profil
          p2->profil := m1profil
        endif
        p2->uroven   := muroven
        p2->otdal    := motdal
        p2->kod_dlo  := mkod_dlo
        p2->snils    := msnils
        p2->DBEGIN   := mDBEGIN
        p2->DEND     := mDEND
        UNLOCK
        COMMIT
        oBrow:goTop()
        goto (mkod)
        ret := 0
      endif
      setcolor(tmp_color)
      restore screen from buf
    case nKey == K_DEL .and. (k := p2->kod) > 0
      buf := save_maxrow()
      s := 'Ждите! Производится проверка на допустимость удаления '
      mywait(s + 'human_u')
      R_Use(dir_server + 'human_u', , 'HU')
      set index to (dir_server + 'human_uv')
      find (str(k, 4))
      if !(fl := found())
        set index to (dir_server + 'human_ua')
        find (str(k, 4))
        fl := found()
      endif
      hu->(dbCloseArea())
      if !fl
        mywait(s + 'hum_p_u')
        R_Use(dir_server + 'hum_p_u', , 'HU')  // проверить Платные услуги
        set index to (dir_server + 'hum_p_uv')
        find (str(k, 4))
        if !(fl := found())
          set index to (dir_server + 'hum_p_ua')
          find (str(k, 4))
          fl := found()
        endif
        hu->(dbCloseArea())
      endif
      if !fl
        mywait(s + 'hum_oru')
        R_Use(dir_server + 'hum_oru', , 'HU') // проверить Ортопедию
        set index to (dir_server + 'hum_oruv')
        find (str(k, 4))
        if !(fl := found())
          set index to (dir_server + 'hum_orua')
          find (str(k, 4))
          fl := found()
        endif
        hu->(dbCloseArea())
      endif
      if !fl
        mywait(s + 'kas_pl_u')
        R_Use(dir_server + 'kas_pl_u', , 'HU') // проверить Кассу
        index on str(kod_vr, 4) to (cur_dir + 'tmp_hu') for kod_vr > 0
        find (str(k, 4))
        fl := found()
        hu->(dbCloseArea())
        if !fl
          mywait(s + 'kas_ort')
          R_Use(dir_server + 'kas_ort', , 'HU')
          index on str(kod_vr, 4) to (cur_dir + 'tmp_hu') for kod_vr > 0
          find (str(k, 4))
          if !(fl := found())
            index on str(kod_tex, 4) to (cur_dir + 'tmp_hu') for kod_tex > 0
            find (str(k, 4))
            fl := found()
          endif
          hu->(dbCloseArea())
        endif
      endif
      rest_box(buf)
      select P2
      if fl
        func_error(4, 'Данный человек встречается в других базах данных. Удаление запрещено!')
      elseif f_Esc_Enter(2)
        DeleteRec(, .f.)   // очистить без пометки на удаление
        find (str_find)
        oBrow:goTop()
        ret := 0
      endif
  endcase
  return ret

** 12.12.22
function set_prvs(get, regim)
  ** regim - место вызова, (1 - выбор mprvs, 2 - выбор mprvs_021)
  local fl := .t., prvs := 0, prvs_021 := 0

  if regim == 1
    prvs := iif(valtype(m1prvs) == 'C', val(m1prvs), m1prvs)
    m1prvs_021 := prvs_V015_to_V021(prvs)
    mprvs_021 := inieditspr(A__MENUVERT, getV021(), m1prvs_021)
    mname_dolj := DoljBySpec_V021(m1prvs_021)
    update_get('mprvs_021')
    update_get('mname_dolj')
  elseif regim == 2
    prvs_021 := m1prvs_021
    m1PRVS := prvs_V021_to_V015(prvs_021)
    mprvs  := ret_tmp_prvs(0, m1prvs)
    mname_dolj := DoljBySpec_V021(prvs_021)
    update_get('mprvs')
    update_get('mname_dolj')
  endif

  return fl

** проверка на допустимость табельного номера
Function val_tab_nom(get, nKey)
  Local fl := .t., rec := 0, norder

  if mtab_nom > 0 .and. !(mtab_nom == get:original)
    rec := recno()
    set order to 2
    find (str(mtab_nom, 5))
    do while tab_nom == mtab_nom .and. !eof()
      if nKey == K_ENTER
        if rec != recno()
          fl := .f.
          exit
        endif
      elseif nKey == K_INS
        fl := .f.
        exit
      endif
      skip
    enddo
    if !fl
      func_error(4, 'Человек с данным табельным номером уже присутствует в справочнике персонала!')
    endif
    set order to 1
    goto (rec)
    if !fl
      mtab_nom := get:original
    endif
  endif
  return fl

**
Function f4edit_pers(nkey)
  Static tmp := ' '
  Local buf := savescreen(), buf1, rec1 := recno(), fl := -1, tmp1, ;
      i, s, fl1

  if nkey != K_F2
    return -1
  endif
  buf1 := savescreen(13, 4, 19, 77)
  do while .t.
    tmp1 := padr(tmp, 50)
    setcolor(color8)
    box_shadow(13, 14, 18, 67)
    @ 15, 15 say center('Введите подстроку (или табельный номер) для поиска', 52)
    status_key('^<Esc>^ - отказ от ввода')
    @ 16, 16 get tmp1 picture '@K@!'
    myread()
    setcolor(color0)
    if lastkey() == K_ESC .or. empty(tmp1)
      exit
    endif
    mywait()
    tmp := alltrim(tmp1)
    // проверка на поиск по таб.номеру
    fl1 := .t.
    for i := 1 to len(tmp)
      if !(substr(tmp, i, 1) $ '0123456789')
        fl1 := .f.
        exit
      endif
    next
    Private tmp_mas := {}, tmp_kod := {}, t_len, k1 := mr + 3, k2 := 21
    i := 0
    if fl1  // поиск по табельному номеру
      set order to 2
      tmp1 := int(val(tmp))
      find (str(tmp1, 5))
      do while tab_nom == tmp1 .and. !eof()
        if kod > 0
          aadd(tmp_mas, P2->fio)
          aadd(tmp_kod, P2->kod)
        endif
        skip
      enddo
      set order to 1
    else
      find (str_find)
      do while !eof()
        if tmp $ upper(fio)
          aadd(tmp_mas, P2->fio)
          aadd(tmp_kod,P2->kod)
        endif
        skip
      enddo
    endif
    if (t_len := len(tmp_kod)) = 0
      stat_msg('Не найдено ни одной записи, удовлетворяющей данному запросу!')
      mybell(2)
      restscreen(13, 4, 19, 77, buf1)
      loop
    elseif t_len == 1  // по табельному номру найдена одна строка
      goto (tmp_kod[1])
      fl := 0
      exit
    else
      box_shadow(mr, 2, 22, 77)
      SETCOLOR('B/BG')
      @ k1 - 2, 15 say 'Подстрока: ' + tmp
      SETCOLOR(color0)
      if k1 + t_len + 2 < 21
        k2 := k1 + t_len + 2
      endif
      @ k1, 3 say center(' Количество найденных фамилий - ' + lstr(t_len), 74)
      status_key('^<Esc>^ - отказ от выбора')
      if (i := popup(k1 + 1, 13, k2, 66, tmp_mas, , color0)) > 0
        goto (tmp_kod[i])
        fl := 0
      endif
      exit
    endif
  enddo
  if fl == -1
    goto rec1
  endif
  restscreen(buf)
  return fl

