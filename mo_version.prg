#include 'ver_date.ch'
#include 'set.ch'
#include 'function.ch'
#include 'chip_mo.ch'

static st_version := {2, 11, 28, ''}
static st_date_version := _DATA_VER
static st__s_full_name := 'ЧИП + Учёт работы Медицинской Организации'

***** 24.06.21 возврат номера версии
function _version()

  return st_version

***** 24.06.21 возврат даты версии
function _date_version()
  
  return st_date_version

***** 24.06.21 возврат наименования программного комплекса
function __s_full_name()
  
return st__s_full_name

***** 23.06.21 возврат строкового представления версии
function __s_version()
  return '  в. ' + fs_version(_version()) + ' от ' + _date_version() + ' тел.(8442)23-69-56'
