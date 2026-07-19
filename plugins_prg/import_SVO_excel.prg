#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#include 'simpleio.ch'
#include 'dbinfo.ch'

#require 'rddsql'
#require 'sddodbc'

#require 'hbodbc'

REQUEST SDDODBC, SQLMIX 
REQUEST HB_CODEPAGE_RU1251

// 19.07.26
function import_SVO_excel()

  local cFile, page, tmp
  local connect_string, cAlias
  local mLPU, mPost, mFam, mIm, mOt, mDOB, mSNILS, mReg, mGit, mTel, mENP, mNaim

  cFile := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*.xlsx' )
  SetKey( K_CTRL_ENTER, nil )
  If ! Empty( cFile )
    cAlias := 'XLS_'
    rddSetDefault( 'SQLMIX' ) 
    connect_string := 'Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};Dbq=' + cfile + ';HDR=YES;IMEX=1;'

    tmp := rddInfo( RDDI_CONNECT, { 'ODBC', connect_string } )

    page := '[‹¨αβ1$]'
    dbUseArea( .T., , 'select * from ' + page, cAlias )
altd()
    do while ! ( cAlias )->( Eof() )

      mLPU := AllTrim( ( cAlias )->( fieldget( 12 ) ) )

//      mPost := CToD( ( cAlias )->( fieldget( 2 ) ) )
      mFam := AllTrim( ( cAlias )->( fieldget( 3 ) ) )
      mIm := AllTrim( ( cAlias )->( fieldget( 4 ) ) )
      mOt := AllTrim( ( cAlias )->( fieldget( 5 ) ) )
//      mDOB := CToD( ( cAlias )->( fieldget( 6 ) ) )
      mSNILS := AllTrim( ( cAlias )->( fieldget( 7 ) ) )
      mReg := AllTrim( ( cAlias )->( fieldget( 8 ) ) )
      mGit := AllTrim( ( cAlias )->( fieldget( 9 ) ) )

      mTel := AllTrim( ( cAlias )->( fieldget( 10 ) ) )
      mENP := AllTrim( ( cAlias )->( fieldget( 11 ) ) )
      mNaim := AllTrim( ( cAlias )->( fieldget( 13 ) ) )

      ( cAlias )->( dbSkip() )
    enddo

    hb_Alert( ( cAlias )->( LastRec() ) )
  endif
  ( cAlias )->( dbCloseArea() )
  return nil