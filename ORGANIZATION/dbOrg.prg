#include 'common.ch'
#include 'function.ch'
#include 'chip_mo.ch'

// 21.05.25
// íâ® ŒŽ "‚®«£®¬¥¤« ¡" ¨«¨ Œ‘—-40 (”Œ€)
function is_VOLGAMEDLAB()

  return hb_main_curOrg:Kod_Tfoms == TF_KOD_MO_VOLGAMEDLAB ;
    .or. hb_main_curOrg:Kod_Tfoms == TF_KOD_MO_MSCH40FMBA

// 23.10.23
function getUCH()
  static arr
  static time_load
  local dbAlias
  local oldSelect

  if timeout_load( @time_load )
    oldSelect := Select()
    dbAlias := '__UCH'
    arr := {}
    R_Use( dir_server() + 'mo_uch', , dbAlias )
    ( dbAlias )->( dbGoTop() )
    while ! ( dbAlias )->( Eof() )
      AAdd( arr, { ( dbAlias )->NAME, ( dbAlias )->KOD, ( dbAlias )->SHORT_NAME, ( dbAlias )->IS_TALON, ( dbAlias )->IDCHIEF, ;
        ( dbAlias )->ADDRESS, ( dbAlias )->COMPET, ( dbAlias )->DBEGIN, ( dbAlias )->DEND } )
      ( dbAlias )->( dbSkip() )
    enddo
    ( dbAlias )->( dbCloseAre() )
    Select( oldSelect )
  endif
  return arr

// 23.10.23
function getUCH_Name( kod )
  local cName := ''
  local i, arr := getUCH()

  if kod > 0 .and. kod <= len( arr )
    if ( i := hb_Ascan( arr, { | x | x[ 2 ] == kod } ) ) > 0
      cName := arr[ i, 1 ]
    endif
  endif
  return cName

// 23.10.23
function getOTD()
  static arr
  static time_load
  local dbAlias
  local oldSelect

  if timeout_load( @time_load )
    oldSelect := Select()
    dbAlias := '__OTD'
    arr := {}
    R_Use( dir_server() + 'mo_otd', , dbAlias )
    ( dbAlias )->( dbGoTop() )
    while ! ( dbAlias )->( Eof() )
      AAdd( arr, { ( dbAlias )->NAME, ( dbAlias )->KOD, ( dbAlias )->KOD_LPU, ( dbAlias )->SHORT_NAME, ( dbAlias )->DBEGIN, ( dbAlias )->DEND, ( dbAlias )->DBEGINP, ( dbAlias )->DENDP, ( dbAlias )->DBEGINO, ( dbAlias )->DENDO, ;
        ( dbAlias )->PLAN_VP, ( dbAlias )->PLAN_PF, ( dbAlias )->PLAN_PD, ( dbAlias )->PROFIL, ( dbAlias )->PROFIL_K, ( dbAlias )->IDSP, ( dbAlias )->IDUMP, ( dbAlias )->IDVMP, ( dbAlias )->TIP_OTD, ( dbAlias )->KOD_PODR, ;
        ( dbAlias )->TIPLU, ( dbAlias )->CODE_DEP, ( dbAlias )->ADRES_PODR, ( dbAlias )->ADDRESS, ;
        ( dbAlias )->CODE_TFOMS, ( dbAlias )->KOD_SOGL, ( dbAlias )->SOME_SOGL } )
      ( dbAlias )->( dbSkip() )
    enddo
    ( dbAlias )->( dbCloseAre() )
    Select( oldSelect )
  endif
  return arr

// 24.10.23
function getOTD_Name( kod )
  local cName := ''
  local i, arr := getOTD()

  if kod > 0 .and. kod <= len( arr )
    if ( i := hb_Ascan( arr, { | x | x[ 2 ] == kod } ) ) > 0
      cName := arr[ i, 1 ]
    endif
  endif
  return cName

// 24.10.23
function getOTD_record( kod )
  local retArr := {}
  local i, arr := getOTD()

  if kod > 0 .and. kod <= len( arr )
    if ( i := hb_Ascan( arr, { | x | x[ 2 ] == kod } ) ) > 0
      retArr := arr[ i ]
    endif
  endif
  return retArr