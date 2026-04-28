#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.04.26 
Function correct_vidpom()

  Local buf := save_maxrow()
  local Slist_sem := 'Работа с листами учета'

  If ! currentUser():isadmin()
    Return func_error( 4, err_admin() )
  Endif

  If !g_slock( Slist_sem )
    Return func_error( 4, 'В данный момент с реестрами работает другой пользователь.' )
  Endif

  waitstatus( 'Проверяем информацию...' )

  r_use( dir_server() + 'mo_otd', , 'OTD' )
  r_use( dir_server() + 'mo_pers', , 'P2' )
  r_use( dir_server() + 'uslugi', , 'USL' )
  r_use( dir_server() + 'human_u', dir_server() + 'human_u', 'HU' )

  r_use( dir_server() + 'human_2', , 'HUMAN_2' )
  g_use( dir_server() + 'human_', , 'HUMAN_', , .t. )
  r_use( dir_server() + 'human', , 'HUMAN' )
  index On dtoc( FIELD->K_DATA ) to ( cur_dir() + 'tmp_corr' ) for Year( FIELD->K_DATA ) > 2025
  Set Relation To RecNo() into HUMAN_, To RecNo() into HUMAN_2

  human->( dbGoTop() )

  do while ! human->( Eof() )
    if human_->VIDPOM == 0 .and. human->schet == 0
//      human_->( dbRLock() )
      human_->VIDPOM := define_vidpom( human->OTD, human->kod, human->K_DATA, human_->USL_OK )
//      human_->( dbUnlock() )
    endif
    human->( dbSkip() )
  enddo

  dbCloseAll()
  g_sunlock( Slist_sem )
  rest_box( buf )

  Return Nil