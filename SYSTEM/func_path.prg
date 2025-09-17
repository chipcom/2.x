#include 'common.ch'
#include 'Directry.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#require 'hbsqlit3'

// 17.09.25
Function read_server_mem( /*@*/is_local_version )

  Local nameFile := cur_dir() + 'server.mem'
  local cDir

  If hb_FileExists( nameFile )
    ft_use( nameFile )
    cDir := AllTrim( ft_readln() )
    ft_use()
    is_local_version := .f.
  Else // иначе = текущий каталог
    cDir := cur_dir()
    is_local_version := .t.
  Endif
  dir_server( cDir )
  Return dir_server()

// 03.06.25
Function checking_access_to_server( dir_s )
  
  // dir_s - путь к файл-серверу
  
  Local tmp_file, fp, err, s_err, flag

  flag := .f.
  if empty( dir_s )
    return flag
  endif
  tmp_file := dir_s + '_t' + lstr( seconds(), 15, 0 ) + '.$$$'
  if ( fp := fcreate( tmp_file ) ) == -1
    s_err := 'Не обнаружен путь доступа к файл-серверу: ' + dir_s
    err := ferror()
    do case
      case err == 4
        s_err := 'Слишком много открытых файлов'
      case err == 5
        s_err := 'Отказано в доступе к файл-серверу'
      case err == 8
        s_err := 'Нет памяти'
      case err == 15
        s_err := 'Неверно указано имя диска сервера'
      case err == 19
        s_err := 'Попытка записи на защищенный диск (сервер)'
      case err == 21
        s_err := 'Дисковод сервера не готов'
      case err == 29
        s_err := 'Ошибка записи на файл-сервер'
      case err == 32
        s_err := 'Нарушение совместного использования сервера'
      case err == 33
        s_err := 'Нарушение защиты сервера'
    endcase
    s_err += '! Код ошибки ' + lstr( err )
    func_error( s_err )
  else
    fclose( fp )
    hb_vfErase( tmp_file )
    flag := .t.
  endif
  return flag

// 29.05.25
function dir_server( path_server )
  // вызов с параметром path_server устанавливает переменную пути к БД программы,
  // без параметра возвращает путь к БД программы

  static dir

  if ! isnil( path_server )
    If Right( path_server, 1 ) != hb_ps()
      path_server += hb_ps()
    Endif
    dir := path_server
  endif
  return dir

// 21.08.24
function dir_XML_FNS()

  static dir

  if isnil( dir )
    dir := dir_server() + 'XML_FNS' + hb_ps()
  endif

  return dir

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

// 07.05.25
function dir_fonts()

  static dir

  if isnil( dir )
#ifdef __PLATFORM__UNIX
    dir := '/'
#else
    dir := getenv( 'SystemRoot' ) + '\fonts\'
#endif
  endif

  RETURN dir

// 14.04.23
// function chip_ExePath()

//   return upper(beforatnum(hb_ps(), exename())) + hb_ps()

// 17.04.23
function check_extension_file(fileName, sExt)

  return lower(right(fileName, len(sExt))) == lower(sExt)

// 16.09.25
function tmp_ini()
  return 'TMP' + sini()

// 16.09.25
function tools_ini()
  return dir_server() + 'TOOLS' + sini()

// 16.09.25
function local_tools_ini()
  return 'LOCTOOLS' + sini()

// 16.09.25
function f_stat_com()
  return dir_exe() + 'stat_com' + sfrm()

// 16.09.25
function f_stat_lpu()
  return dir_server() + 'stat_lpu' + sini()

// 16.09.25
function file_uchast()
  return dir_server() + 'prik_uch' + smem()
