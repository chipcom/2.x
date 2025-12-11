// Users.prg - работа с пользователями системы
// ////////////////////////////
// 04.11.18 edit_Users_bay() - редактирование списка пользователей
// 20.10.18 editUser( oBrowse, aObjects, object, nKey ) - редактирование объекта 'пользователь'
// 28.12.21 inp_password_bay( is_local_version, is_create ) - запрос и проверка пароля
// 20.10.18 get_parol_bay( r1, c1, r2, c2, ltip, color_say, color_get ) - функция окна ввода пароля
// 11.07.17 layoutUser( oBrow, aList ) - формирование колонок для отображения списка пользователей
// 01.09.16 PassExist( obj, aObjects, pass ) - проверка существования пользователя с указанным паролем
// ////////////////////////////
#include 'hbthread.ch'
#include 'common.ch'
#include 'set.ch'
#include 'inkey.ch'

#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 11.12.25
Function currentuser( val )

  Static stUser

  If HB_ISNIL( stUser ) .and. ! HB_ISNIL( val )
    stUser := val
  Endif

  Return stUser

// 11.12.25 ввод пароля
Function inp_password_bay( is_local_version, is_create )

  Local strPassword := Space( 10 )
  Local i_p := 0, ta := {}
  Local oUser := nil
  Local aMessageRepeat := { 'Не верный пароль!', 'Попробуйте еще раз...' }
  Local aMessageEnd := { 'Нет прав доступа к системе!', 'Вы превысили число возможных попыток получить доступ!' }

  Public kod_polzovat := Chr( 0 ), ;
    yes_parol := .t.

  // public  fio_polzovat := ''
  // Public dolj_polzovat := '', grup_polzovat := 1, tip_polzovat := TIP_ADM
  // public TIP_ADM := 0

  If ( is_local_version .and. ! tstructfiles():new():existfileclass( 'TUserDB' ) ) .or. is_create
    oUser := tuser():new(, 'Локальная версия', 0 )

		hb_user_curUser := oUser // TUser():New(, 'Локальная версия', 0)
    currentuser( oUser )
    yes_parol := .f.
    Return ta
  Endif
  Do While i_p < 3  // до 3х попыток
    strPassword := get_parol_bay()
    If LastKey() == K_ESC
      f_end()
    Else
      ++i_p
      If ! tstructfiles():new():existfileclass( 'TUserDB' )
        hb_Alert( { 'Отсутствует таблица пользователей системы.', 'Продолжение работы невозможно!' }, , , 4 )
        f_end()
      Elseif ( oUser := tuserdb():new():getbypassword( strPassword ) ) != nil
        // присвоим текущего пользователя
        hb_user_curUser := oUser
        currentuser( oUser )
        // mfio   := oUser:FIO
        // fio_polzovat := alltrim( mfio )
        kod_polzovat := Chr( oUser:Id() )
        // tip_polzovat := oUser:Access
        // dolj_polzovat := alltrim( oUser:Position )
        // grup_polzovat := oUser:KEK

        oper_parol := oUser:PasswordFR // int(val(s))
        oper_frparol := oUser:PasswordFRSuper // oper_parol
        oper_fr_inn := oUser:INN
        oper_dov_date   := oUser:Dov_Date // stod(crypt(base1->dov_date,gpasskod))
        oper_dov_nomer  := oUser:Dov_nom // alltrim(crypt(base->dov_nomer,gpasskod))
      Else
        If i_p < 3  // до 3х попыток
          hb_Alert( aMessageRepeat, , , 4 )
          Loop
        Else
          hb_Alert( aMessageEnd, , , 4 )
          f_end()
        Endif
      Endif
    Endif
    Exit
  Enddo
//  AAdd( ta, AllTrim( hb_user_curUser:FIO ) )
  AAdd( ta, AllTrim( currentuser():FIO ) )
  AAdd( ta, 'Тип доступа: "' + { 'Администратор', 'Оператор', '', 'Контролёр' }[ oUser:Access + 1 ] + '"' )
  If !Empty( AllTrim( oUser:Position ) )
    AAdd( ta, 'Должность: ' + AllTrim( oUser:Position ) )
  Endif
  // if between( currentuser():KEK, 1, 3 )
  // aadd( ta, 'Группа экспертизы (КЭК): ' + lstr( currentuser():KEK ) )
  // endif

  Return ta

// 20.10.18 функция окна ввода пароля
Function get_parol_bay()

  Local s := Space( 10 )
  Local color_say := 'N/W', color_get := 'W/N*'
  Local r1 := MaxRow() -5, c1 := Int( ( MaxCol() -36 ) / 2 )
  Local oBox

  oBox := tbox():new( r1, c1, MaxRow() -3, MaxRow() + 31, .t. )
  oBox:MessageLine := '^<Esc>^ - выход из задачи;  ^<Enter>^ - подтверждение ввода пароля'
  oBox:Color := color_say + ',' + color_get
  oBox:Frame := 0
  oBox:view()
  Set Confirm On
  SetCursor()
  @ r1 + 1, c1 + 18 Say s Color color_get  // т.к. не работает get в выделенном цвете
  s := Upper( GetSecret( s, r1 + 1, c1 + 10, , 'Пароль:' ) )
  SetCursor( 0 )
  Set Confirm Off

  Return s

// 11.12.25 редактирование списка пользователей
Function edit_users_bay()

  Local blkEditObject
  Local oBox, aEdit := {}
  Local c_1 := T_COL + 5, c_2 := c_1 + 67
  Local lWork
  Local aProperties

  // if is_task( X_KEK )
  // c_1 := 2
  // c_2 := 77
  // endif
  blkEditObject := {| oBrowse, aObjects, object, nKey | edituser( oBrowse, aObjects, object, nKey ) }

//  If hb_user_curUser:isadmin()
  If currentuser():isadmin()
    aEdit := { .t., .t., .t., .t. }
    lWork := g_slock( 'edit_pass' )
  Else
    aEdit := { .f., .f., .f., .f. }
    lWork := .t.
  Endif
  If lWork
    aProperties := { { 'FIO', 'Ф.И.О.', 20 }, { 'DepShortName', 'Под-ние', 7 }, { 'Position', 'Должность', 20 }, { 'Type_F', 'Тип', 3 } }
    // if is_task( X_KEK )
    // aadd( aProperties, { 'KEK', 'КЭК', 3 } )
    // endif

    oBox := tbox():new( T_ROW, c_1, MaxRow() -2, c_2, .t. )
    oBox:Caption := 'Список пользователей'
    oBox:Color := color5
    // просмотр и редактирование списка пользователей, возврат функции не интересует
    listobjectsbrowse( 'TUser', oBox, tuserdb():getlist(), 1, aProperties, ;
      blkEditObject, aEdit, , ' ^<F9>^-печать', )

  Else
    Return func_error( 4, 'В данный момент пароли редактирует другой администратор. Ждите.' )
  Endif
//  If lWork .and. hb_user_curUser:isadmin()
  If lWork .and. currentuser():isadmin()
    g_sunlock( 'edit_pass' )
  Endif

  Return Nil

// 11.07.24 редактирование объекта пользователя
Function edituser( oBrowse, aObjects, oUser, nKey )

  Local fl := .f.
  Local r1 := MaxRow() -12, r2 := MaxRow() -3, i, j
  Local c_1 := T_COL + 5, c_2 := c_1 + 62
  Local oBox

  Local mm_gruppa := { ;
    { '0 - не работает в задаче КЭК', 0 }, ;
    { '1 - уровень зав.отделением', 1 }, ;
    { '2 - уровень зам.гл.врача', 2 }, ;
    { '3 - уровень комиссии КЭК', 3 } }

  Private mtip, m1tip, mgruppa, mDepartment, m1Department, mrole, m1role, m1gruppa := 0

  Keyboard ''
  If nKey == K_F8
    If ( j := f_alert( { PadC( 'Выберите порядок сортировки', 60, '.' ) }, ;
        { ' По ФИО ', ' По номеру ' }, ;
        1, 'W+/N', 'N+/N', MaxRow() -2, , 'W+/N,N/BG' ) ) != 0
      If j == 1
        ASort( aObjects, , , {| x, y | x:FIO < y:FIO } )
      Elseif j == 2
        ASort( aObjects, , , {| x, y | x:ID < y:ID } )
      Endif
      oBrowse:refreshall()
      Return .t.
    Endif
  Elseif nKey == K_F9 .and. glob_mo[ _MO_KOD_TFOMS ] == '102604' // Для ВОККВД
    // hb_threadStart( HB_THREAD_INHERIT_PUBLIC, @printUserList(), aObjects )
    // WaitingReport( 3 )
    // return .t.
  Elseif nKey == K_INS .or. nKey == K_ENTER
    m1tip := oUser:Access
    mtip := inieditspr( A__MENUVERT, tuser():aMenuType, m1tip )
    m1role := oUser:IDRole
    mrole := inieditspr( A__MENUVERT, troleuserdb():MenuRoles, m1role )
    m1Department := oUser:iddepartment()
    mDepartment := inieditspr( A__MENUVERT, tdepartmentdb():menudepartments(), m1Department )

    // if is_task( X_KEK )
    // m1gruppa := oUser:KEK
    // mgruppa := inieditspr( A__MENUVERT, mm_gruppa, m1gruppa )
    // --r1
    // c_1 := 2
    // c_2 := 77
    // endif
    If is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
      --r1
    Endif

    oBox := tbox():new( r1, c_1 + 1, r2, c_2 -1, .t. )
    oBox:Caption := iif( nKey == K_INS .or. nKey == K_F4, 'Добавление', 'Редактирование' )
    oBox:MessageLine := '^<Esc>^ - выход без записи;  ^<Enter>^ - подтверждение ввода'
    oBox:Color := cDataCGet
    oBox:view()

    If is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
      @ r1 + 2, c_1 + 3 Say 'Ф.И.О. пользователя' Get oUser:FIO Valid func_empty( oUser:FIO )
      @ r1 + 2, c_1 + 44 Say 'ИНН пользователя' Get oUser:INN Picture '999999999999'
    Else
      @ r1 + 2, c_1 + 3 Say 'Ф.И.О. пользователя' Get oUser:FIO Valid func_empty( oUser:FIO )
    Endif

    @ r1 + 3, c_1 + 3 Say 'Учреждение' Get mDepartment ;
      READER {| x | menu_reader( x, tdepartmentdb():menudepartments(), A__MENUVERT, , , .f. ) }
    @ r1 + 4, c_1 + 3 Say 'Должность' Get oUser:Position
    @ r1 + 5, c_1 + 3 Say 'Группа пользователей' Get mrole ;
      READER {| x | menu_reader( x, troleuserdb():menuroles(), A__MENUVERT, , , .f. ) }
    @ r1 + 6, c_1 + 3 Say 'Тип доступа' Get mtip ;
      READER {| x | menu_reader( x, tuser():aMenuType, A__MENUVERT, , , .f. ) }
    @ r1 + 7, c_1 + 3 Say 'Пароль' Get oUser:Password Picture '@!' Valid func_empty( oUser:Password ) .and. !passexist( oUser, aObjects, oUser:Password )
    i := 7
    // if is_task( X_KEK )
    // ++i
    // @ r1 + i, c_1 + 3 say 'Группа КЭК' get mgruppa READER { | x | menu_reader( x, mm_gruppa, A__MENUVERT, , , .f. ) }
    // endif
    If is_task( X_PLATN ) .or. is_task( X_ORTO ) .or. is_task( X_KASSA )
      ++i
      @ r1 + i, c_1 + 3 Say 'Пароль для фискального регистратора' Get oUser:PasswordFR Picture '99999999'
      ++i
      @ r1 + i, c_1 + 3 Say 'N доверен-ти' Get oUser:Dov_Nom
      @ r1 + i, c_1 + 36 Say 'Дата доверен-ти' Get oUser:Dov_Date
    Endif
    myread()
    If LastKey() != K_ESC .and. f_esc_enter( 1 )
      oUser:iddepartment( m1Department )
      oUser:KEK := m1gruppa
      oUser:Access := m1tip
      oUser:IDRole := m1role
      tuserdb():save( oUser )
      fl := .t.
    Endif
    oBox := nil
  Elseif nKey == K_DEL
    // не реализовано
  Endif

  Return fl

// 01.09.16 проверка существования пользователя с указанным паролем
// obj - объект пользователя не участвующего в проверке
// aObjects - список пользователей
// pass - строка пароля
Function passexist( obj, aObjects, pass )

  Local ret := .f., oUser := nil

  pass := AllTrim( pass )
  For Each oUser in aObjects
    If ( AllTrim( oUser:Password ) == pass ) .and. ( !obj:equal( oUser ) )
      hb_Alert( 'Пользователь с указанным паролем существует!', , , 4 )
      ret := .t.
      Exit
    Endif
  Next

  Return ret
