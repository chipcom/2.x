// #include 'hbhash.ch' 
#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// #require 'hbsqlit3'

// 04.12.23
// это МО "Волгомедлаб"
function is_VOLGOMEDLAB()

  return hb_main_curOrg:Kod_Tfoms == VOLGOMEDLAB

// 23.10.23
function getUCH()
  static arr
  static time_load
  local dbAlias
  local oldSelect

  if timeout_load(@time_load)
    oldSelect := Select()
    dbAlias := '__UCH'
    arr := {}
    R_Use(dir_server + 'mo_uch', , dbAlias)
    (dbAlias)->(dbGoTop())
    while ! (dbAlias)->(Eof())

      //   {'KOD',       'N', 3, 0}, ; // код;;из 'l_ucher'
      //   {'NAME',      'C', 30, 0}, ; // наименование;сократили с 70 до 30;'из ''l_ucher'''
      //   {'SHORT_NAME', 'C', 5, 0}, ; // сокращенное наименование;;
      //   {'IS_TALON',  'N', 1, 0}, ; // учреждение работает со статталоном?;0-нет, 1-да;оставить 0, или поставить 1 в зависимости от массива UCHER_TALON (см. c_allpub.prg строка 273)
      //   {'IDCHIEF',   'N', 4, 0}, ; // номер записи в файле mo_pers. Ссылка на руководителя учреждения
      //   {'ADDRESS',  'C', 150, 0}, ; // адрес нахождения учреждения
      //   {'COMPET',    'C', 40, 0}, ; // документ утверждения руководителя
      //   {'DBEGIN',    'D', 8, 0}, ; // дата начала действия;;поставить 01.01.1993
      //   {'DEND',      'D', 8, 0} ;  // дата окончания действия;;поставить 31.12.2000, или оставить пустым в зависимости от массива UCHER_ARRAY (см. b_init.prg)
      AAdd(arr, {(dbAlias)->NAME, (dbAlias)->KOD, (dbAlias)->SHORT_NAME, (dbAlias)->IS_TALON, (dbAlias)->IDCHIEF, ;
        (dbAlias)->ADDRESS, (dbAlias)->COMPET, (dbAlias)->DBEGIN, (dbAlias)->DEND})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseAre())
    Select(oldSelect)
  endif

  return arr

// 23.10.23
function getUCH_Name(kod)
  local cName := ''
  local i, arr := getUCH()

  if kod > 0 .and. kod <= len(arr)
    if (i := hb_Ascan(arr, {|x| x[2] == kod})) > 0
      cName := arr[i, 1]
    endif
  endif
  return cName

// 23.10.23
function getOTD()
  static arr
  static time_load
  local dbAlias
  local oldSelect

  if timeout_load(@time_load)
    oldSelect := Select()
    dbAlias := '__OTD'
    arr := {}
    R_Use(dir_server + 'mo_otd', , dbAlias)
    (dbAlias)->(dbGoTop())
    while ! (dbAlias)->(Eof())

      // {'KOD',       'N', 3, 0}, ; // код
      // {'NAME',      'C', 30, 0}, ; // наименование
      // {'KOD_LPU',   'N', 3, 0}, ; // код учреждения
      // {'SHORT_NAME', 'C', 5, 0}, ; // сокращенное наименование
      // {'DBEGIN',    'D', 8, 0}, ; // дата начала действия в задаче ОМС
      // {'DEND',      'D', 8, 0}, ; // дата окончания действия в задаче ОМС
      // {'DBEGINP',   'D', 8, 0}, ; // дата начала действия в задаче 'Платные услуги'
      // {'DENDP',     'D', 8, 0}, ; // дата окончания действия в задаче 'Платные услуги'
      // {'DBEGINO',   'D', 8, 0}, ; // дата начала действия в задаче 'Ортопедия'
      // {'DENDO',     'D', 8, 0}, ; // дата окончания действия в задаче 'Ортопедия'
      // {'PLAN_VP',   'N', 6, 0}, ; // план врачебных приемов
      // {'PLAN_PF',   'N', 6, 0}, ; // план профилактик
      // {'PLAN_PD',   'N', 6, 0}, ; // план приемов на дому
      // {'PROFIL',    'N', 3, 0}, ; // профиль для данного отделения по справочнику V002, по умолчанию прописывать его в лист учета и в услугу
      // {'PROFIL_K',  'N', 3, 0}, ; // профиль койки для данного отделения по справочнику V020, по умолчанию прописывать его в лист учета
      // {'IDSP',      'N', 2, 0}, ; // код способа оплаты мед.помощи для данного отделения по справочнику V010
      // {'IDUMP',     'N', 2, 0}, ; // код условий оказания медицинской помощи
      // {'IDVMP',     'N', 2, 0}, ; // код видов медицинской помощи
      // {'TIP_OTD',   'N', 2, 0}, ; // тип отд-ия: 1-приёмный покой
      // {'KOD_PODR',  'C', 25, 0}, ; // код подразделения по паспорту ЛПУ
      // {'TIPLU',     'N', 2, 0}, ; // тип листа учёта: 0-стандарт, 1-СМП, 2-ДДС, 3-ДВН, и т.д.
      // {'CODE_DEP',  'N', 3, 0}, ; // код отделения по кодировке ТФОМС из справочника SprDep - 2018 год
      // {'ADRES_PODR', 'N', 2, 0}, ; // код удалённого подразделения по массиву glob_arr_podr - 2017 год
      // {'ADDRESS',  'C', 150, 0}, ; // адрес нахождения учреждения
      // {'CODE_TFOMS', 'C', 6, 0}, ; // код подразделения по кодировке ТФОМС - 2017 год
      // {'KOD_SOGL',  'N', 10, 0}, ; // код согласования одного отделения с программой SDS
      // {'SOME_SOGL', 'C', 255, 0} ;  // код согласования нескольких отделений с программой SDS
      AAdd(arr, {(dbAlias)->NAME, (dbAlias)->KOD, (dbAlias)->KOD_LPU, (dbAlias)->SHORT_NAME, (dbAlias)->DBEGIN, (dbAlias)->DEND, (dbAlias)->DBEGINP, (dbAlias)->DENDP, (dbAlias)->DBEGINO, (dbAlias)->DENDO, ;
        (dbAlias)->PLAN_VP, (dbAlias)->PLAN_PF, (dbAlias)->PLAN_PD, (dbAlias)->PROFIL, (dbAlias)->PROFIL_K, (dbAlias)->IDSP, (dbAlias)->IDUMP, (dbAlias)->IDVMP, (dbAlias)->TIP_OTD, (dbAlias)->KOD_PODR, ;
        (dbAlias)->TIPLU, (dbAlias)->CODE_DEP, (dbAlias)->ADRES_PODR, (dbAlias)->ADDRESS, ;
        (dbAlias)->CODE_TFOMS, (dbAlias)->KOD_SOGL, (dbAlias)->SOME_SOGL})
      (dbAlias)->(dbSkip())
    enddo
    (dbAlias)->(dbCloseAre())
    Select(oldSelect)
  endif

  return arr

// 24.10.23
function getOTD_Name(kod)
  local cName := ''
  local i, arr := getOTD()

  if kod > 0 .and. kod <= len(arr)
    if (i := hb_Ascan(arr, {|x| x[2] == kod})) > 0
      cName := arr[i, 1]
    endif
  endif
  return cName

// 24.10.23
function getOTD_record(kod)
  local retArr := {}
  local i, arr := getOTD()

  if kod > 0 .and. kod <= len(arr)
    if (i := hb_Ascan(arr, {|x| x[2] == kod})) > 0
      retArr := arr[i]
    endif
  endif
  return retArr

