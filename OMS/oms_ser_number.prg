#include "function.ch"
#include "chip_mo.ch"

****** 20.01.22 ������ �਩�� ����� ������⠭� �� �� ���
function chek_implantant_ser_number(rec_n)

return check_ser_number('I', rec_n)

****** 20.01.22 ������ �਩�� ����� ������⢥����� �९��� �� �� ���
function check_lek_preparat_ser_number(rec_n)

return check_ser_number('L', rec_n)

****** 20.01.22 ������ �਩�� ����� � ��
function check_ser_number(type, rec_n)
local tmpSelect := select()
local ret_ser_num, fl

type := Upper(type)

if fl := R_Use(dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER')
  find (type + str(rec_n, 7))
  if NUM_SER->(found())
    ret_ser_num := NUM_SER->SER_NUM
  endif
endif
NUM_SER->(dbCloseArea())
select(tmpSelect)
return ret_ser_num

****** 20.01.22 ��࠭��� �਩�� ����� ������⠭� � �� ���
function save_implantant_ser_number(rec_n, ser_num)

save_ser_number('I', rec_n, ser_num)
return nil

****** 20.01.22 ��࠭��� �਩�� ����� ������⢥����� �९��� � �� ���
function save_lek_preparat_ser_number(rec_n, ser_num)

save_ser_number('L', rec_n, ser_num)
return nil

****** 20.01.22 ��࠭��� �਩�� ����� � �� ���
****** type: ⨯ 䠩�� "I" - ������⠭��, "L" - ������⢥��� �९����
function save_ser_number(type, rec_n, ser_num)
local tmpSelect := select(), fl

type := Upper(type)

if fl := G_Use(dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER', , .f., .f.)
  find (type + str(rec_n, 7))
  if NUM_SER->(found())
    G_RLock(forever)
    NUM_SER->TYPE_FIL   := type
    NUM_SER->REC_N      := rec_n
    NUM_SER->SER_NUM    := ser_num
    UNLOCK
  else
    AddRec(' ', , .t.)
    NUM_SER->TYPE_FIL   := type
    NUM_SER->REC_N      := rec_n
    NUM_SER->SER_NUM    := ser_num
  endif
  NUM_SER->(dbCloseArea())
endif
select(tmpSelect)
return nil

****** 20.01.22 㤠���� �਩�� ����� ������⠭� � �� ���
function delete_implantant_ser_number(rec_n)

delete_ser_number('I', rec_n)
return nil

****** 20.01.22 㤠���� �਩�� ����� ������⢥����� �९��� � �� ���
function delete_lek_preparat_ser_number(rec_n)

delete_ser_number('L', rec_n)
return nil

****** 16.03.22 㤠���� �਩�� ����� � ��
function delete_ser_number(type, rec_n)
local tmpSelect := select()

type := Upper(type)

if fl := G_Use(dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER', , .f., .f.)
  find (type + str(rec_n, 7))
  if NUM_SER->(found())
    DeleteRec(.t.)  // ���⪠ ����� � ����⪮� �� 㤠�����
  endif
endif
NUM_SER->(dbCloseArea())
select(tmpSelect)
return nil
