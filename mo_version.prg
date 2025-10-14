#include 'ver_date.ch'
#include 'set.ch'
#include 'inkey.ch'
#include 'dbstruct.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

Static st_version := { 5, 10, 1, 'a+' }
Static st_date_version := _DATA_VER
Static st_full_name := '��� + ���� ࠡ��� ����樭᪮� �࣠����樨'
Static st_short_name := '[��� + ���� ࠡ��� ��]'

// 24.06.21 ������ ����� ���ᨨ
Function _version()

  Return st_version

// 24.06.21 ������ ���� ���ᨨ
Function _date_version()

  Return st_date_version

// 12.12.24 ������ ������������ �ணࠬ����� ��������
Function app_full_name()

  Return st_full_name

// 03.06.25 ������ ��ப����� �।�⠢����� ���ᨨ
Function str_version()
  Return ' �. ' + Err_version() + ' ⥫.(8442)23-69-56'

// 12.12.24
Function full_name_version()

  Return app_full_name() + str_version()

// 12.12.24
Function short_name_version()

  Return st_short_name + str_version()

// ������ ��ப� � ����஬ ���ᨨ
Function fs_version( aVersion )

  // aVersion - 4-���� ���ᨢ

  Return lstr( aVersion[ 1 ] ) + '.' + lstr( aVersion[ 2 ] ) + '.' + lstr( aVersion[ 3 ] ) + iif( Len( aVersion ) == 4, aVersion[ 4 ], '' )

// 20.08.24 ������ ��ப� � ����஬ ���ᨨ ������
Function fs_version_short( aVersion )

  // aVersion - 4-���� ���ᨢ

  Return lstr( aVersion[ 1 ] ) + '.' + lstr( aVersion[ 2 ] ) + '.' + lstr( aVersion[ 3 ] )

// 17.12.21 ������� �᫮��� ���祭�� ���ᨨ �� �����
Function get_version_db()

  Local nfile := 'ver_base'
  Local ver__base := 0

  If hb_FileExists( dir_server() + nfile + sdbf() )
    r_use( dir_server() + nfile, , 'ver' )
    ver__base := ver->version
    ver->( dbCloseArea() )
  Endif

  Return ver__base

// 15.02.23 ��࠭��� ����� �᫮��� ���祭�� ���ᨨ �� �����
Function save_version_db( nVersion )

  Local nfile := 'ver_base'

  reconstruct( dir_server() + nfile, { { 'version', 'N', 10, 0 } }, , , .t. )
  g_use( dir_server() + nfile, , 'ver' )
  If LastRec() == 0
    addrecn()
  Else
    g_rlock( forever )
  Endif
  Replace version With nVersion
  ver->( dbCloseArea() )

  Return .t.

// 15.02.23 ����஫� ���ᨨ ���� ������
Function controlversion( aVersion, oldVersion )

  // aVersion - �஢��塞�� �����
  Local ver__base
  Local snversion := Int( aVersion[ 1 ] * 10000 + aVersion[ 2 ] * 100 + aVersion[ 3 ] )

  If ( ver__base := get_version_db() ) != 0
    If snversion > ver__base
      Return .t.
    Elseif snversion == ver__base
      If Asc( SubStr( oldVersion[ 4 ], 1, 1 ) ) < Asc( aVersion[ 4 ] )
        Return .t.
      Endif
    Endif
  Endif

  Return .f.

// 15.02.23 ����஫� ���ᨨ ���� ������
Function controlbases( type_oper, aVersion )

  // type_oper  - ⨯ ����樨
  // 1 - ��᫥ ����᪠ �ணࠬ�� ����� ����� �� �� 䠩��
  // 2 - ���⢥न�� ࠧ�襭�� �� ४�������� (�� reconstruct)
  // 3 - ������� ��� ����� ���ᨨ �� (��᫥ ���樠����樨)
  // aVersion - ����� ��, ᮮ⢥������� ������ ᡮથ �ணࠬ��
  // ��易⥫쭠 ��� ��ࢮ�� �맮�� (���ᨢ �� ���� ����⮢)
  Static sl_reconstr, snversion, sl_smena, nfile := 'ver_base'
  Local ret_value, ver__base

  Default sl_reconstr To .t., sl_smena To .f.
  Do Case
  Case type_oper == 1
    Default snversion To Int( aVersion[ 1 ] * 10000 + aVersion[ 2 ] * 100 + aVersion[ 3 ] )
    If ( ver__base := get_version_db() ) != 0
      If snversion < ver__base
        func_error( '�� �����⨫� ����� ����� �ணࠬ��. ����� ����饭�!' )
        f_end()
      Else
        sl_smena := ( snversion != ver__base )
        sl_reconstr := .t.
      Endif
    Else
      sl_smena := .t.
    Endif
    ret_value := sl_smena
  Case type_oper == 2
    If !sl_reconstr
      func_error( '�� �����⨫� ����� ����� �ணࠬ��. ����� ����饭�!' )
      f_end()
    Endif
    ret_value := sl_reconstr
  Case type_oper == 3 .and. sl_smena
    save_version_db( snversion )
  Endcase

  Return ret_value
