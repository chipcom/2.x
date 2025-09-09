#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 09.09.25 ���樠������ ���ᨢ� ��, ����� ���� �� (�� ����室�����)
Function init_mo()

  Local fl := .t., i, cCode := '', buf := save_maxrow()

  test_init()

  mywait()
  Public glob_arr_mo := {}, glob_mo
  
  Public oper_parol := 30  // ��஫� ��� �᪠�쭮�� ॣ������
  Public oper_frparol := 30 // ��஫� ��� �᪠�쭮�� ॣ������ �����
  Public oper_fr_inn  := '' // ��� �����
  Public oper_dov_date   := Date()  // ��� ����७����
  Public oper_dov_nomer  := Space( 20 )  // ����� ����७����
  Public glob_podr := ''
//  Public glob_podr_2 := ''
//  Public is_adres_podr := .f.
//  Public glob_adres_podr := { ;
//    { '103001', { { '103001', 1, '�.������ࠤ, �.�����窨, �.78' }, ;
//    { '103099', 2, '�.��堩�����, �.����ਭ�, �.8' }, ;
//    { '103099', 3, '�.����᪨�, �.���ᮬ���᪠�, �.25' }, ;
//    { '103099', 4, '�.����᪨�, �.������檠�, �.33' }, ;
//    { '103099', 5, '�.����設, �.����஢᪠�, �.43' }, ;
//    { '103099', 6, '�.����設, �.���, �.51' }, ;
//    { '103099', 7, '�.����, �.�ਤ��-���⥪, �.8' } };
//    }, ;
//    { '101003', { { '101003', 1, '�.������ࠤ, �.�������᪮��, �.1' }, ;
//    { '101099', 2, '�.������ࠤ, �.�����᪠�, �.47' } };
//    }, ;
//    { '131001', { { '131001', 1, '�.������ࠤ, �.��஢�, �.10' }, ;
//    { '131099', 2, '�.������ࠤ, �.��� ��������, �.7' }, ;
//    { '131099', 3, '�.������ࠤ, �.��.����⮢�, �.18' } };
//    }, ;
//    { '171004', { { '171004', 1, '�.������ࠤ, �.����祭᪠�, �.40' }, ;
//    { '171099', 2, '�.������ࠤ, �.�ࠪ����ந⥫��, �.13' } };
//    };
//    }

//  create_mo_add()
//  glob_arr_mo := getmo_mo( '_mo_mo' )
  glob_arr_mo := glob_arr_mo()

  If hb_FileExists( dir_server() + 'organiz' + sdbf() )
    r_use( dir_server() + 'organiz',, 'ORG' )
    If LastRec() > 0
      cCode := Left( org->kod_tfoms, 6 )
    Endif
  Endif
//  Close databases
  dbCloseAll()
  If !Empty( cCode )
//    If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
//      glob_mo := glob_arr_mo[ i ]
    If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
      glob_mo := glob_mo( glob_arr_mo()[ i ] )
//      If ( i := AScan( glob_adres_podr, {| x| x[ 1 ] == glob_mo[ _MO_KOD_TFOMS ] } ) ) > 0
      If ( i := AScan( glob_adres_podr(), {| x| x[ 1 ] == glob_mo()[ _MO_KOD_TFOMS ] } ) ) > 0
//        is_adres_podr := .t.
        is_adres_podr( .t. )
//        glob_podr_2 := glob_adres_podr()[ i, 2, 2, 1 ] // ��ன ��� ��� 㤠�񭭮�� ����
      Endif
    Else
      func_error( 4, '� �ࠢ�筨� ������ ���������騩 ��� �� "' + cCode + '". ������ ��� ������.' )
      cCode := ''
    Endif
  Endif
  If Empty( cCode )
    If ( cCode := input_value( 18, 2, 20, 77, color1, ;
        '������ ��� �� ��� ���ᮡ������� ���ࠧ�������, ��᢮���� �����', ;
        Space( 6 ), '999999' ) ) != Nil .and. !Empty( cCode )
//      If ( i := AScan( glob_arr_mo, {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
//        glob_mo := glob_arr_mo[ i ]
      If ( i := AScan( glob_arr_mo(), {| x| x[ _MO_KOD_TFOMS ] == cCode } ) ) > 0
        glob_mo := glob_mo( glob_arr_mo()[ i ] )
        If hb_FileExists( dir_server() + 'organiz' + sdbf() )
          g_use( dir_server() + 'organiz', , 'ORG' )
          If LastRec() == 0
            addrecn()
          Else
            g_rlock( forever )
          Endif
          org->kod_tfoms := glob_mo()[ _MO_KOD_TFOMS ]
          org->name_tfoms := glob_mo()[ _MO_SHORT_NAME ]
          org->uroven := get_uroven()
        Endif
        Close databases
        dbCloseAll()
      Else
        fl := func_error( '����� ���������� - ������ ��� �� "' + cCode + '" ����७.' )
      Endif
    Endif
  Endif
  If Empty( cCode )
    fl := func_error( '����� ���������� - �� ����� ��� ��.' )
  Endif
  rest_box( buf )
  If ! fl
    hard_err( 'delete' )
    app_finish()
  Endif
  Return main_up_screen()
