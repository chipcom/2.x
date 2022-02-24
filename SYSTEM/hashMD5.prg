#include 'fileio.ch'
#include 'directry.ch'
#include 'function.ch'
#include 'chip_mo.ch'

#define FILE_HASH   'files.hst'   // имя файла для хэшев файлов

function read_files_md5(source)
  local fp, i, s
  LOCAL aFiles, aFile
  LOCAL cBuffer, nFileSize
  local aStr, hash_files, tArr, row

  if HB_VFEXISTS(source)
    hash_files := hb_Hash()

    fp := HB_VFOPEN(source, FO_READ)
    nFileSize := hb_vfSize( fp )
    cBuffer := Space( nFileSize )
    IF hb_vfRead( fp, @cBuffer, nFileSize ) != nFileSize
    else
      aStr := split(cBuffer, hb_eol())
      for each row in aStr
        tArr := split(row, ', ')
        if len(tArr) == 2
          hash_files[tArr[1]] := tArr[2]
        endif
      next
    endif

    hb_vfClose( fp )
    return hash_files
  endif
  return nil

function create_files_md5(source, ext)
  local fp, i, s
  LOCAL aFiles, aFile
  
  fp := fcreate(source + FILE_HASH, FC_HIDDEN)
  IF ! Empty( aFiles := hb_vfDirectory( source + ext ) )
    // IF ! Empty( aFiles := hb_vfDirectory( source + '*.xml' ) )
    s := ''
    FOR EACH aFile IN aFiles
      s := upper(aFile[ F_NAME ]) + ', ' + hb_MD5File( source + aFile[ F_NAME ] ) + hb_eol()
      FWrite( fp, s)
    NEXT
  endif
  fclose(fp)
  return nil
  
function check_izm_file_MD5(hash_files, nameRef, nfile, /*@*/sMD5)
  local fl := .f.
  local hashMD5File, tmpMD5

  tmpMD5 := hb_MD5File( nfile )
  if hash_files != nil
    nameRef := upper(nameRef)
    if hb_HHasKey( hash_files, nameRef )
      hashMD5File := hb_HGet(hash_files, nameRef)
      if hashMD5file == tmpMD5 // файл не изменялся
        // if hashMD5file == hb_MD5File( nfile ) // файл не изменялся
        fl := .t.
      endif
    endif
  endif
  sMD5 := tmpMD5
  return fl

function add_hash_row(hash_files, name, sMD5)

  if hash_files == nil
    hash_files := hb_Hash()
  endif
  hash_files[name] := sMD5

  return hash_files