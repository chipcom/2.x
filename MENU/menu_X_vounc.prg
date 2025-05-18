#include "common.ch"
#include "function.ch"
#include "chip_mo.ch"

function menu_X_vounc()

  Local old, fl := .t.

  fl := begin_task_vounc()
  old := is_uchastok
  my_mo_f1main()

  If glob_mo[ _MO_KOD_TFOMS ] == kod_VOUNC
    is_uchastok := 1 // ΅γªΆ  + ό γη αβª  + ό Ά γη αβª¥ "“25/123"
    vounc_f1main()
    is_uchastok := old
  Endif
  return fl
