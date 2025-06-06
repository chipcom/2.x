#include 'dbstruct.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 09.09.22 получить код специальности врача по V021 по табельному номеру сотрудника
Function get_spec_vrach_v021_by_tabnom( tabnom )

  // tabnom - табельный номер
  Local aliasIsUse
  Local oldSelect
  Local ret := 0

  If tabnom == 0
    Return 0
  Endif

  aliasIsUse := aliasisalreadyuse( 'TPERS' )
  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'TPERS' )
  Endif

  If TPERS->( dbSeek( Str( tabnom, 5 ) ) )
    ret := ret_prvs_v015tov021( TPERS->PRVS_NEW )
  Endif
  If ! aliasIsUse
    TPERS->( dbCloseArea() )
  Endif
  Select( oldSelect )
  Return ret

// 01.10.21
Function get_kod_vrach_by_tabnom( tabnom )

  Local aliasIsUse
  Local oldSelect, ret := 0

  If tabnom == 0
    Return 0
  Endif

  aliasIsUse := aliasisalreadyuse( 'TPERS' )
  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', dir_server() + 'mo_pers', 'TPERS' )
  Endif

  If TPERS->( dbSeek( Str( tabnom, 5 ) ) )
    ret := TPERS->kod
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
  Endif
  Select( oldSelect )
  Return ret

// 01.10.21
Function get_tabnom_vrach_by_kod( kod )

  Local aliasIsUse
  Local oldSelect, ret := 0

  If kod == 0
    Return ret
  Endif

  aliasIsUse := aliasisalreadyuse( 'TPERS' )
  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', , 'TPERS' )
  Endif

  TPERS->( dbGoto( kod ) )
  If ! ( TPERS->( Eof() ) .or. TPERS->( Bof() ) )
    ret := TPERS->tab_nom
  Endif

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
  Endif
  Select( oldSelect )
  Return ret

// 21.10.23
// поиск сотрудника по номеру записи в БД
Function find_employee( mkod, dontClose )

  Static dbTmp
  Local aliasIsUse
  Local oldSelect
  Local hEmployee
  Local aliasPersonal := 'P2'
  Local row
  Local i

  If mkod <= 0
    Return hEmployee
  Endif

  Default dontClose To .f.

  aliasIsUse := aliasisalreadyuse( aliasPersonal )
  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server() + 'mo_pers', , aliasPersonal )
    If ISNIL( dbTmp )
      dbTmp := ( aliasPersonal )->( dbStruct() )
    Endif
  Endif
  ( aliasPersonal )->( dbGoto( mkod ) )
  If ! ( ( aliasPersonal )->( Eof() ) .or. ( aliasPersonal )->( Bof() ) )
    hEmployee := hb_Hash()
    hb_HCaseMatch( hEmployee, .f. )
    i := 0
    For Each row in dbTmp
      ++i
      hb_HSet( hEmployee, row[ DBS_NAME ], ( aliasPersonal )->( FieldGet( i ) ) )
    Next
  Endif

  If ( ! aliasIsUse ) .and. ( ! dontClose )
    ( aliasPersonal )->( dbCloseArea() )
  Endif
  Select( oldSelect )
  Return hEmployee

// 10.04.19 поискать врача по СНИЛС и, м.б., по специальности
Function ret_perso_with_tab_nom( lsnils, lprvs )

  Static aprvs
  Local i, j, lvrach := 0

  Default aprvs To ret_arr_new_olds_prvs() // массив соответствий специальности V015 специальностям V004
  Select PERSO
  Set Order To 1
  find ( PadR( lsnils, 11 ) + Str( lprvs, 4 ) ) // ищем по коду специальности V015
  If Found()
    lvrach := perso->kod
  Elseif ( j := AScan( aprvs, {| x| x[ 1 ] == lprvs } ) ) > 0
    Set Order To 2
    For i := 1 To Len( aprvs[ j, 2 ] )
      find ( PadR( lsnils, 11 ) + Str( aprvs[ j, 2, i ], 9 ) )  // ищем по коду старой специальности
      If Found()
        lvrach := perso->kod
        Exit
      Endif
    Next
  Endif
  If Empty( lvrach )
    find ( PadR( lsnils, 11 ) )  // ищем просто по СНИЛС
    If Found()
      lvrach := perso->kod
    Endif
  Endif
  Return lvrach