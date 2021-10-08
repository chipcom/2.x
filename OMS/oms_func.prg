**** 01.10.21
**** возврат структуры временного файла для направлений на онкологию
function create_struct_temporary_onkna()
  return {; // онконаправления
    {"KOD"      ,   "N",     7,     0},; // код больного
    {"NAPR_DATE",   "D",     8,     0},; // Дата направления
    {"NAPR_MO",     "C",     6,     0},; // код другого МО, куда выписано направление
    {"NAPR_V"  ,    "N",     1,     0},; // Вид направления:1-к онкологу,2-на биопсию,3-на дообследование,4-для опр.тактики лечения
    {"MET_ISSL" ,   "N",     1,     0},; // Метод диагностического исследования(при NAPR_V=3):1-лаб.диагностика;2-инстр.диагностика;3-луч.диагностика;4-КТ, МРТ, ангиография
    {"shifr"  ,     "C",    20,     0},;
    {"shifr_u"  ,   "C",    20,     0},;
    {"shifr1"   ,   "C",    20,     0},;
    {"name_u"   ,   "C",    65,     0},;
    {"U_KOD"    ,   "N",     6,     0},;  // код услуги
    {"KOD_VR"   ,   "N",     5,     0};  // код врача (справочник mo_pers)
  }

**** 01.10.21
function get_kod_vrach_by_tabnom(tabnom)
  local aliasIsUse
  local oldSelect, ret := 0

  if tabnom == 0
    return 0
  endif

  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",dir_server+"mo_pers","TPERS") 
  endif

  if TPERS->(dbSeek(str(tabnom,5)))
    ret := TPERS->kod
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret

**** 01.10.21
function get_tabnom_vrach_by_kod(kod)
  local aliasIsUse
  local oldSelect, ret := 0

  if kod == 0
    return ret
  endif
  
  aliasIsUse := aliasIsAlreadyUse('TPERS')
  if ! aliasIsUse
    oldSelect := Select()
    R_Use(dir_server+"mo_pers",,"TPERS") 
  endif

  TPERS->(dbGoto(kod))
  if ! (TPERS->(Eof()) .or. TPERS->(Bof()))
    ret := TPERS->tab_nom
  endif

  if ! aliasIsUse
    TPERS->(dbCloseArea())
  endif
  Select(oldSelect)
  return ret
