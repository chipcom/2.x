#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

function input_polis_OMS(cur_row, mkod)

  // переменные mvidpolis, m1vidpolis, mspolis, mnpolis объявлены ранее как PRIVATE
  default mkod to 0
  @ cur_row, 1 say 'Полис ОМС: вид' get mvidpolis ;
    reader {|x|menu_reader(x, mm_vid_polis, A__MENUVERT, , , .f.)}
  @ row(), col() + 3 say 'серия' get mspolis when m1vidpolis == 1
  @ row(), col() + 3 say 'номер' get mnpolis ;
    picture iif(m1vidpolis == 3 .or. m1vidpolis == 1, '9999999999999999', '999999999');
    valid {|| findKartoteka(2, @mkod) ,func_valid_polis(m1vidpolis, mspolis, mnpolis)}

  return nil

// 10.02.17
Function get_fio_kart( k, r, c )

  Local s := '', ret, buf, tmp_keys

  Private fl_write_kartoteka := .f.

  buf := SaveScreen()
  tmp_keys := my_savekey()
  edit_kartotek( mkod_k, r + 1, , .t., mkod )
  my_restkey( tmp_keys )
  If fl_write_kartoteka
    r_use( dir_server + 'kartote2', , 'KART2' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartote_', , 'KART_' )
    Goto ( mkod_k )
    r_use( dir_server + 'kartotek', , 'KART' )
    Goto ( mkod_k )
    M1FIO := 1
    mfio := kart->fio
    mpol := kart->pol
    mdate_r := kart->date_r
    mfio_kart := _f_fio_kart()
    If Type( 'mn_data' ) == 'D'
      If Type( 'm1novor' ) == 'N' .and. Type( 'mdate_r2' ) == 'D' .and. m1novor > 0
        mvozrast := count_years( mdate_r2, mn_data )
      Else
        mvozrast := count_years( mdate_r, mn_data )
      Endif
    Endif
    If Type( 'm1novor' ) == 'N' .and. m1novor > 0
      M1VZROS_REB := 1 // ребенок
    Else
      M1VZROS_REB := kart->VZROS_REB
    Endif
    mADRES      := kart->ADRES
    mMR_DOL     := kart->MR_DOL
    m1RAB_NERAB := kart->RAB_NERAB
    m1komu      := kart->komu
    mPOLIS      := kart->POLIS
    m1VIDPOLIS  := kart_->VPOLIS
    mSPOLIS     := kart_->SPOLIS
    mNPOLIS     := kart_->NPOLIS
    msmo        := kart_->SMO
    m1okato     := kart_->KVARTAL_D // ОКАТО субъекта РФ территории страхования
    mokato      := inieditspr( A__MENUVERT, glob_array_srf, m1okato )
    mkomu       := inieditspr( A__MENUVERT, mm_komu, m1komu )
    mvidpolis   := inieditspr( A__MENUVERT, mm_vid_polis, m1vidpolis )
    If !Empty( mn_data )
      fv_date_r( mn_data, .f. )
    Endif
    f_valid_komu(, -1 )
    m1company   := Int( Val( msmo ) )
    mcompany    := inieditspr( A__MENUVERT, mm_company, m1company )
    If m1company == 34
      mnameismo := ret_inogsmo_name( 1, , .t. ) // открыть и закрыть
    Elseif !( Left( msmo, 2 ) == '34' )
      m1ismo := msmo
      msmo := '34'
      m1company := 34
      mismo := init_ismo( m1ismo )
    Endif
    If m1company == 34
      If !Empty( mismo )
        mcompany := mismo
      Elseif !Empty( mnameismo )
        mcompany := mnameismo
      Endif
    Endif
    If !Empty( mcompany )
      old_name_smo := PadR( mcompany, 38 )
    Endif
    If m1komu > 0
      m1company := 0
      mcompany := ''
      If eq_any( m1komu, 1, 3 )
        m1company := m1str_crb := kart->STR_CRB
        mcompany := inieditspr( A__MENUVERT, mm_company, m1company )
      Endif
    Endif
    mcompany := PadR( mcompany, 38 )
    If eq_any( is_uchastok, 1, 3 )
      s := amb_kartan()
    Elseif mem_kodkrt == 2
      s := lstr( mkod_k )
    Endif
    If !Empty( s ) .and. ValType( MUCH_DOC ) == 'C'
      If Empty( MUCH_DOC )
        MUCH_DOC := PadR( s, 10 )
      Elseif is_uchastok == 3 .and. !( MUCH_DOC == PadR( s, 10 ) )
        MUCH_DOC := PadR( s, 10 )
      Endif
    Endif
    Close databases
  Endif
  RestScreen( buf )

  Return ret

// 24.02.16
Function _f_fio_kart()

  Return PadR( AllTrim( mfio ) + ' ' + iif( mpol == 'М', '(муж.)', '(жен.)' ), 50 )
