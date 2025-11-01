#include "function.ch"
#include "chip_mo.ch"

// ***** 20.01.22 ������ �਩�� ����� ������⠭� �� �� ���
Function chek_implantant_ser_number( rec_n )

  Return check_ser_number( 'I', rec_n )

// ***** 20.01.22 ������ �਩�� ����� ������⢥����� �९��� �� �� ���
Function check_lek_preparat_ser_number( rec_n )

  Return check_ser_number( 'L', rec_n )

// ***** 20.01.22 ������ �਩�� ����� � ��
Function check_ser_number( type, rec_n )

  Local tmpSelect := Select()
  Local ret_ser_num, fl

  type := Upper( type )

  If fl := r_use( dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER' )
    find ( type + Str( rec_n, 7 ) )
    If NUM_SER->( Found() )
      ret_ser_num := NUM_SER->SER_NUM
    Endif
  Endif
  NUM_SER->( dbCloseArea() )
  Select( tmpSelect )

  Return ret_ser_num

// ***** 20.01.22 ��࠭��� �਩�� ����� ������⠭� � �� ���
Function save_implantant_ser_number( rec_n, ser_num )

  save_ser_number( 'I', rec_n, ser_num )

  Return Nil

// ***** 20.01.22 ��࠭��� �਩�� ����� ������⢥����� �९��� � �� ���
Function save_lek_preparat_ser_number( rec_n, ser_num )

  save_ser_number( 'L', rec_n, ser_num )

  Return Nil

// ***** 20.01.22 ��࠭��� �਩�� ����� � �� ���
// ***** type: ⨯ 䠩�� "I" - ������⠭��, "L" - ������⢥��� �९����
Function save_ser_number( type, rec_n, ser_num )

  Local tmpSelect := Select(), fl

  type := Upper( type )

  If fl := g_use( dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER', , .f., .f. )
    find ( type + Str( rec_n, 7 ) )
    If NUM_SER->( Found() )
      g_rlock( forever )
      NUM_SER->TYPE_FIL   := type
      NUM_SER->REC_N      := rec_n
      NUM_SER->SER_NUM    := ser_num
      Unlock
    Else
      addrec( ' ', , .t. )
      NUM_SER->TYPE_FIL   := type
      NUM_SER->REC_N      := rec_n
      NUM_SER->SER_NUM    := ser_num
    Endif
    NUM_SER->( dbCloseArea() )
  Endif
  Select( tmpSelect )

  Return Nil

// ***** 20.01.22 㤠���� �਩�� ����� ������⠭� � �� ���
Function delete_implantant_ser_number( rec_n )

  delete_ser_number( 'I', rec_n )

  Return Nil

// ***** 20.01.22 㤠���� �਩�� ����� ������⢥����� �९��� � �� ���
Function delete_lek_preparat_ser_number( rec_n )

  delete_ser_number( 'L', rec_n )

  Return Nil

// ***** 16.03.22 㤠���� �਩�� ����� � ��
Function delete_ser_number( type, rec_n )

  Local tmpSelect := Select()

  type := Upper( type )

  If fl := g_use( dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER', , .f., .f. )
    find ( type + Str( rec_n, 7 ) )
    If NUM_SER->( Found() )
      deleterec( .t. )  // ���⪠ ����� � ����⪮� �� 㤠�����
    Endif
  Endif
  NUM_SER->( dbCloseArea() )
  Select( tmpSelect )

  Return Nil
