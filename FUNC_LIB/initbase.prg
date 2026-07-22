#include 'function.ch'

// инициализация БД (редактирование которой осуществляется f_edit_spr)
Function init_base( file_base, string, gmenu, len_key, func_index, fl_NET, arr_ind )

// file_base -  имя БД с путем и расширением
// string     - строка текста с пояснением содержимого БД
// gmenu -      указатель на инициализирующий массив
// len_key -    длина поля kod (или 0 в случае отсутствия в БД поля KOD)
// func_index - наименование функции индексирования БД
// fl_NET -     флаг, указывающий, где создается БД, - на сервере или нет
// arr_ind    - массив индексных файлов (чтобы сделать их транзакционными)

  Local i, k, adbf

  DEFAULT len_key TO 0, fl_NET TO .f.
  adbf := if( len_key == 0, { }, { { 'kod', 'N', len_key, 0 } } )
  for i := 1 to len( gmenu )
    k := aclone( gmenu[ i ] )
    asize( k, 4 )
    aadd( adbf, aclone( k ) )
  next
  reconstruct( file_base, adbf, func_index, string, fl_NET, arr_ind )

  return NIL
