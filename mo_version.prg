#include 'set.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

  // public _version := {2, 11, 22, 'd+'}
  // public _date_version := '21.06.21г.'
  // public __s_full_name := 'ЧИП + Учёт работы Медицинской Организации'

***** 23.06.21 возврат номера версии
function _version()

  // local version := {2, 11, 22, 'd+'}

  // return version
  return {2, 11, 22, 'd+'}

***** 23.06.21 возврат даты версии
function _date_version()
  
  // local _date := '21.06.21г.'

  // return _date
  return '21.06.21г.'

***** 23.06.21 возврат наименования программного комплекса
function __s_full_name()
  
  return 'ЧИП + Учёт работы Медицинской Организации'

***** 23.06.21 возврат строкового представления версии
function __s_version()
  return '  в. ' + fs_version(_version()) + ' от ' + _date_version() + ' тел.(8442)23-69-56'
