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

// 20.07.26
function import_SVO_excel()

  local cFile, page, tmp, iCount := 0
  local connect_string, cAlias, tmpRec
  local mLPU, mPost, mFam, mIm, mOt, mDOB, mSNILS, mENP, mReg, mGit, mTel, mNaim

  cFile := manager( T_ROW, T_COL + 5, MaxRow() -2, , .t., 1, , , , '*.xlsx' )
  SetKey( K_CTRL_ENTER, nil )
  If ! Empty( cFile )

    r_use( dir_server() + 'kartotek', , 'kart' )
    r_use( dir_server() + 'kartote2', , 'kart2' )
    index on FIELD->kod_mis to ( cur_dir() + 'tmp_enp' )
//    fl := r_use( dir_exe() + '_mo_usld', cur_dir() + '_mo_usld', sBase )

    cAlias := 'XLS_'
    rddSetDefault( 'SQLMIX' ) 
    connect_string := 'Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};Dbq=' + cfile + ';HDR=YES;IMEX=1;'

    tmp := rddInfo( RDDI_CONNECT, { 'ODBC', connect_string } )

    page := '[Лист1$]'
    dbUseArea( .T., , 'select * from ' + page, cAlias )

    do while ! ( cAlias )->( Eof() )


      if HB_ISNIL( mLPU := ( cAlias )->( fieldget( 12 ) ) )
        mLPU := ''
      else
        if ValType( mLPU ) == 'N'
          mLPU := Str( mLPU, 6 )
        endif
      endif

      if mLPU == glob_mo()[ _MO_KOD_TFOMS ]
        iCount++
        if HB_ISNIL( mFam := ( cAlias )->( fieldget( 3 ) ) )
          mFam := ''
        else
          mFam := AllTrim( mFam )
        endif
        if HB_ISNIL( mIm := ( cAlias )->( fieldget( 4 ) ) )
          mIm := ''
        else
          mIm := AllTrim( mIm )
        endif
        if HB_ISNIL( mOt := ( cAlias )->( fieldget( 5 ) ) )
          mOt := ''
        else
          mOt := AllTrim( mOt )
        endif
        if HB_ISNIL( mSNILS := ( cAlias )->( fieldget( 7 ) ) )
          mSNILS := ''
        else
          mSNILS := AllTrim( mSNILS )
        endif
/*
        if HB_ISNIL( mReg := ( cAlias )->( fieldget( 8 ) ) )
          mReg := ''
        else
          mReg := AllTrim( mReg )
        endif
        if HB_ISNIL( mGit := ( cAlias )->( fieldget( 9 ) ) )
          mGit := ''
        else
          mGit := AllTrim( mGit )
        endif
        if HB_ISNIL( mTel := ( cAlias )->( fieldget( 10 ) ) )
          mTel := ''
        else
          mTel := AllTrim( mTel )
        endif
*/
        if HB_ISNIL( mENP := ( cAlias )->( fieldget( 11 ) ) )
          mENP := ''
        else
          mENP := AllTrim( mENP )
        endif
//        if HB_ISNIL( mNaim := ( cAlias )->( fieldget( 13 ) ) )
//          mNaim := ''
//        else
//          mNaim := AllTrim( mNaim )
//        endif

        if HB_ISNIL( ( cAlias )->( fieldget( 2 ) ) )
          mPost := CToD( '' )
        else
          mPost := HB_TTOD( ( cAlias )->( fieldget( 2 ) ) )
        endif
        if HB_ISNIL( ( cAlias )->( fieldget( 6 ) ) )
          mDOB := CToD( '' )
        else
          mDOB := HB_TTOD( ( cAlias )->( fieldget( 6 ) ) )
        endif

      endif
      if ! empty( mENP )
        kart2->( dbSeek( mENP ) )
        do while AllTrim( kart2->kod_mis ) == mEnp .and. ! kart2->( Eof() )
//          hb_Alert( Str( kart2->( RecNo() ) ) )
          kart->( dbGoto( kart2->( RecNo() ) ) )
          kart2->( dbSkip() )
        enddo
      endif
      ( cAlias )->( dbSkip() )
    enddo
    hb_Alert( 'Обработано - ' + Str( iCount, 3 ) + ' записей.' )
    ( cAlias )->( dbCloseArea() )
    kart2->( dbCloseArea() )
  endif
  return nil