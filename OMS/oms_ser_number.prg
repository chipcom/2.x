#include "function.ch"
#include "chip_mo.ch"

****** 20.01.22 вернуть серийный номер имплантанта из БД учета
function chek_implantant_ser_number(rec_n)

return check_ser_number('I', rec_n)

****** 20.01.22 вернуть серийный номер лекарственного препарата из БД учета
function check_lek_preparat_ser_number(rec_n)

return check_ser_number('L', rec_n)

****** 20.01.22 вернуть серийный номер в БД
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

****** 20.01.22 сохранить серийный номер имплантанта в БД учета
function save_implantant_ser_number(rec_n, ser_num)

save_ser_number('I', rec_n, ser_num)
return nil

****** 20.01.22 сохранить серийный номер лекарственного препарата в БД учета
function save_lek_preparat_ser_number(rec_n, ser_num)

save_ser_number('L', rec_n, ser_num)
return nil

****** 20.01.22 сохранить серийный номер в БД учета
****** type: тип файла "I" - имплантанты, "L" - лекарственные препараты
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

****** 20.01.22 удалить серийный номер имплантанта в БД учета
function delete_implantant_ser_number(rec_n)

delete_ser_number('I', rec_n)
return nil

****** 20.01.22 удалить серийный номер лекарственного препарата в БД учета
function delete_lek_preparat_ser_number(rec_n)

delete_ser_number('L', rec_n)
return nil

****** 16.03.22 удалить серийный номер в БД
function delete_ser_number(type, rec_n)
local tmpSelect := select()

type := Upper(type)

if fl := G_Use(dir_server() + 'human_ser_num', dir_server() + 'human_ser_num', 'NUM_SER', , .f., .f.)
  find (type + str(rec_n, 7))
  if NUM_SER->(found())
    DeleteRec(.t.)  // очистка записи с пометкой на удаление
  endif
endif
NUM_SER->(dbCloseArea())
select(tmpSelect)
return nil
