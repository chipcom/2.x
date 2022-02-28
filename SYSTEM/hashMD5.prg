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
          hash_files[upper(tArr[1])] := tArr[2]
        endif
      next
    endif

    hb_vfClose( fp )
    return hash_files
  endif
  return nil

function save_files_md5(aHash, destinationFile)
  local fp, i, s
  local key, sMD5
  local aKeys

  if HB_VFEXISTS(destinationFile)
    hb_vfErase( destinationFile )
  endif
  
  aKeys := hb_hKeys( aHash )
  fp := fcreate(destinationFile, FC_HIDDEN)
  for each key in aKeys
    s := ''
    sMD5 := aHash[ key ]
    s := upper(key) + ', ' + sMD5 + hb_eol()
    FWrite( fp, s)
  next
  fclose(fp)
  return nil
  
function check_izm_file_MD5(hash_files, nameRef, sMD5)
  local fl := .f.
  local hashMD5File

  if hash_files != nil
    nameRef := upper(nameRef)
    if hb_HHasKey( hash_files, nameRef )
      hashMD5File := hb_HGet(hash_files, nameRef)
      if hashMD5file == sMD5 // файл не изменялся
        fl := .t.
      endif
    endif
  endif
  return fl

function add_hash_row(hash_files, name, sMD5)

  if hash_files == nil
    hash_files := hb_Hash()
  endif
  hash_files[upper(name)] := sMD5

  return hash_files