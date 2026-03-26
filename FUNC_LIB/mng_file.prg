#include 'inkey.ch'
#include 'function.ch'

// 'norton' для выборки пути к файлам
Function mng_file( n_file, r, c, _p_var, blk_F3, maska, yes_floppy )

  return mng_dir_file( 1, n_file, r, c, _p_var, blk_F3, maska, yes_floppy )

// 'norton' для выбора каталога
Function mng_dir( n_file, r, c, _p_var, blk_F3, maska, yes_floppy )
  
  return mng_dir_file( 2, n_file, r, c, _p_var, blk_F3, maska, yes_floppy )

//
Static Function mng_dir_file( par, n_file, r, c, _p_var, blk_F3, maska, yes_floppy )

  Local s, r1, r2, fl_space := .f.
  if valtype( _p_var ) == 'C'
    Private p_var_manager := _p_var
  endif
  if r < 13
    r1 := r + 1
    r2 := 22
  else
    r1 := 2
    r2 := r - 1
  endif
  s := manager( r1, c, r2, , yes_floppy, par, .t., @fl_space, blk_F3, maska )
  if ! empty( s )
    n_file := s
  endif
  if empty( n_file ) .or. fl_space // если не было выбора (и пустой вход) или нажат пробел
    n_file := space( 10 )
  endif
  return { n_file, n_file }
