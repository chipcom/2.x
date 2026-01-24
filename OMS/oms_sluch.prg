#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 24.01.26 селектор для добавления или редактирования случаев (листов учета)
Function oms_sluch( Loc_kod, kod_kartotek )

  // Loc_kod - код по БД human.dbf (если =0 - добавление листа учета)
  // kod_kartotek - код по БД kartotek.dbf (если =0 - добавление в картотеку)

  Local otdelenie

  otdelenie := glob_otd

  If Len( otdelenie ) > 2 .and. otdelenie[ 3 ] == 4 // скорая помощь
    Return oms_sluch_smp( Loc_kod, kod_kartotek, TIP_LU_SMP )
  Elseif Len( otdelenie ) > 3
    If eq_any( otdelenie[ 4 ], TIP_LU_SMP, TIP_LU_NMP ) // скорая помощь (неотложная медицинская помощь)
      Return oms_sluch_smp( Loc_kod, kod_kartotek, otdelenie[ 4 ] )
    Elseif eq_any( otdelenie[ 4 ], TIP_LU_DDS, TIP_LU_DDSOP ) // диспансеризация сирот
      Return oms_sluch_dds( otdelenie[ 4 ], Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_DVN   // диспансеризация взрослого населения
      Return oms_sluch_dvn( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_DRZ // диспансеризация репродуктивного здоровья взрослого населения
      Return oms_sluch_dvn_drz( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_DVN_COVID // углубленная диспансеризация COVID
      Return oms_sluch_dvn_covid( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_PN    // профосмотры несовершеннолетних
      Return oms_sluch_pn( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_PREDN // предварительные осмотры несовершеннолетних
      Return func_error( 4, 'С 2018 года предварительные осмотры несовершеннолетних не проводятся' )
    Elseif otdelenie[ 4 ] == TIP_LU_PERN  // периодические осмотры несовершеннолетних
      Return func_error( 4, 'С 2018 года периодические осмотры несовершеннолетних не проводятся' )
    Elseif otdelenie[ 4 ] == TIP_LU_PREND // пренатальная диагностика
      Return oms_sluch_prend( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_G_CIT // жидкостная цитология рака шейки матки
      Return oms_sluch_g_cit( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_MED_REAB // амбулаторная медицинская реабилитация
      Return oms_sluch_med_reab( Loc_kod, kod_kartotek )
    Elseif otdelenie[ 4 ] == TIP_LU_ONKO_DISP // постановка на диспансерный учет онкопациетов в поликлинике
      Return oms_sluch_onko_disp( Loc_kod, kod_kartotek )
    Else  // основной вид листа учета
      Return oms_sluch_main( Loc_kod, kod_kartotek )
    Endif
  Endif
  Return Nil
