#include 'common.ch'
#include 'Directry.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// 22.10.24
function dir_server( path_server )
  // вызов с параметром path_server устанавливает переменную пути к БД программы,
  // без параметра возвращает путь к БД программы

  static dir
  local cslash := hb_ps()

  if ! isnil( path_server )
    If Right( path_server, 1 ) != cslash
      path_server += cslash
    Endif
    dir := path_server
  endif
  return dir

// 21.08.24
function dir_XML_FNS()

  static dir

  if isnil( dir )
    dir := dir_server + 'XML_FNS' + hb_ps()
  endif

  return dir

// 15.10.24
function _tmp_dir()
  
return 'TMP___'

// 15.10.24
function _tmp_dir1()

return 'TMP___' + hb_ps()

// 15.10.24
function _tmp2dir()
  
  return 'TMP2___'

// 15.10.24
function _tmp2dir1()
  
  return 'TMP2___' + hb_ps()

// 14.10.24
function dir_exe()
  
  static dir

  if isnil( dir )
    dir := hb_DirBase()
  endif
  return dir

// 22.03.24
function cur_dir()

  static dir

  if isnil( dir )
    dir := chip_CurrPath()
  endif
  return dir

// 14.04.23
function chip_CurrPath()

  local cPrefix

#ifdef __PLATFORM__UNIX
  cPrefix := '/'
#else
  cPrefix := hb_curDrive() + ':\'
#endif

  RETURN cPrefix + CurDir() + hb_ps()

// 12.11.24
function dir_fonts()

  static dir

  if isnil( dir )
#ifdef __PLATFORM__UNIX
    dir := '/'
#else
    dir := HB_GETENV( 'windir' ) + hb_ps() + 'Fonts' + hb_ps()
#endif
  endif

  RETURN dir

// 14.04.23
// function chip_ExePath()

//   return upper(beforatnum(hb_ps(), exename())) + hb_ps()

// 17.04.23
function check_extension_file(fileName, sExt)

  return lower(right(fileName, len(sExt))) == lower(sExt)

