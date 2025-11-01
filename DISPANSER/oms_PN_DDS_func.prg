#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 18.10.25
function input_psih_health( j, age, mdata )

  // j - текущая строка на экране
  // age - возраст
  // mdata - дата провдения
  @ ++j, 1 Say PadC( 'Оценка психического развития ' + iif( age < 5, '(возраст развития):', '' ), 78, '_' )
  If age < 5 .and. mdata < 0d20250901 // если меньше 5 лет и mdata < 0d20250901
    @ ++j, 1 Say 'познавательная функция' Get m1psih11 Pict '99'
    @ ++j, 1 Say 'моторная функция      ' Get m1psih12 Pict '99'
    @ --j, 30 Say 'эмоциональная и социальная    ' Get m1psih13 Pict '99'
    @ ++j, 30 Say 'предречевое и речевое развитие' Get m1psih14 Pict '99'
  elseif age >= 5 .and. mdata < 0d20250901
    @ ++j, 1 Say 'психомоторная сфера' Get mpsih21 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'интеллект          ' Get mpsih22 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
    @ --j, 40 Say 'эмоц.вегетативная сфера' Get mpsih23 reader {| x| menu_reader( x, mm_psih2(), A__MENUVERT, , , .f. ) }
    ++j
  elseif age < 5 .and. mdata >= 0d20250901
    @ ++j, 1 Say  'познавательная функция ' Get m1psih11 Pict '99'
    @ j, 28 Say  'моторная функция ' Get m1psih12 Pict '99'
    @ j, 50 Say 'речевое развитие    ' Get m1psih14 Pict '99'
    @ ++j, 1 Say 'нар.когнитивные ф-ции  ' Get mpsih24 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say 'нар. учебные навыки   ' Get mpsih25 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'эмоциональные нарушения' Get mpsih26 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say 'предречевое развитие  ' Get mpsih27 reader {| x| menu_reader( x, mm_activ(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'понимание речи         ' Get mpsih28 reader {| x| menu_reader( x, mm_partial(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say 'активная речь         ' Get mpsih29 reader {| x| menu_reader( x, mm_used(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'нар.коммуникатив. нав. ' Get mpsih30 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 40 Say 'сенсорное развитие    ' Get mpsih31 reader {| x| menu_reader( x, mm_sensor(), A__MENUVERT, , , .f. ) }
  elseif age >= 5 .and. mdata >= 0d20250901
    @ ++j, 1 Say 'внешний вид              ' Get mpsih32 reader {| x| menu_reader( x, mm_view_obraz(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  'доступен к контакту' Get mpsih33 reader {| x| menu_reader( x, mm_contact(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'фон настроения           ' Get mpsih34 reader {| x| menu_reader( x, mm_nastroenie(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  'обманы восприятия' Get mpsih35 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'интеллектуальная функция ' Get mpsih36 reader {| x| menu_reader( x, mm_intelect(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  'нарушения когнитивных функций' Get mpsih37 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'нарушение учебных навыков' Get mpsih38 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  'суицидальные наклонности' Get mpsih39 reader {| x| menu_reader( x, mm_danet(), A__MENUVERT, , , .f. ) }
    @ ++j, 1 Say 'самоповреждения          ' Get mpsih40 reader {| x| menu_reader( x, mm_self_harm(), A__MENUVERT, , , .f. ) }
    @ j, 45 Say  'социальная сфера' Get mpsih41 reader {| x| menu_reader( x, mm_socium(), A__MENUVERT, , , .f. ) }
  endif
  return j

// 18.10.25
function rep_psih_health_and_sex( lvozrast, mdata, type )

  // type - тип листа учета

  local st, ub, ue, fl, s, blk, head_psih, head_sex

  st := Space( 5 )
  ub := '<u><b>'
  ue := '</b></u>'
  head_psih := iif( type == TIP_LU_PN, '13.', '14.' )
  head_sex := iif( type == TIP_LU_PN, '14.', '15.' )
  blk := {| s| __dbAppend(), field->stroke := s }
  fl := ( lvozrast < 5 )
  s := st + head_psih + ' Оценка психического развития (состояния):'
  frd->( Eval( blk, s ) )
  if mdata < 0d20250901
    s := st + head_psih + '1. Для детей в возрасте 0 - 4 лет:'
    frd->( Eval( blk, s ) )
    s := st + 'познавательная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih11 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'моторная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih12 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'эмоциональная и социальная (контакт с окружающим миром) функции (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih13 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'предречевое и речевое развитие (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih14 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    fl := ( lvozrast > 4 )
    s := st + head_psih + '2. Для детей в возрасте 5 - 17 лет:'
    frd->( Eval( blk, s ) )
    s := st + head_psih + '2.1. Психомоторная сфера: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih21, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + head_psih + '2.2. Интеллект: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih22, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
    s := st + head_psih + '2.3. Эмоционально-вегетативная сфера: ' + f3_inf_dds_karta( mm_psih2(), iif( fl, m1psih23, -1 ),, ub, ue )
    frd->( Eval( blk, s ) )
  else
    s := st + head_psih + '1. Для детей в возрасте 0 - 4 лет:'
    frd->( Eval( blk, s ) )
    s := st + 'познавательная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih11 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение когнитивных функций ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih24 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение учебных навыков ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih25 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'моторная функция (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih12 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'эмоциональные нарушения ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih26 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'предречевое развитие ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_activ(), m1psih27 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'речевое развитие (возраст развития) ' + iif( !fl, '________', ub + st + lstr( m1psih14 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'понимание речи ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_partial(), m1psih28 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'активная речь ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_used(), m1psih29 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение коммуникативных навыков ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih30 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    s := st + 'сенсорное развитие ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_sensor(), m1psih31 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
    fl := ( lvozrast > 4 )
    s := st + head_psih + '2. Для детей в возрасте 5 - 17 лет:'
    frd->( Eval( blk, s ) )
    s := st + 'внешний вид ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_view_obraz(), m1psih32 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'доступен к контакту ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_contact(), m1psih33 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'фон настроения ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_nastroenie(), m1psih34 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'обманы восприятия ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih35 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'интеллектуальная функция ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_intelect(), m1psih36 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушения когнитивных функций ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih37 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'нарушение учебных навыков ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih38 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'суицидальные наклонности ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_danet(), m1psih39 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'самоповреждения ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_self_harm(), m1psih40 ) + st + ue ) + ';'
    frd->( Eval( blk, s ) )
    s := st + 'социальная сфера ' + iif( !fl, '________', ub + st + inieditspr( A__MENUVERT, mm_socium(), m1psih41 ) + st + ue ) + '.'
    frd->( Eval( blk, s ) )
  endif

  // половая характеристика
  fl := ( mpol == 'М' .and. lvozrast > 9 )
  s := st + '14. Оценка полового развития (с 10 лет):'
  frd->( Eval( blk, s ) )
  s := st + head_sex + '1. Половая формула мальчика: Р ' + iif( !fl .or. m141p == 0, '________', ub + st + lstr( m141p ) + st + ue )
  s += ' Ах ' + iif( !fl .or. m141ax == 0, '________', ub + st + lstr( m141ax ) + st + ue )
  s += ' Fa ' + iif( !fl .or. m141fa == 0, '________', ub + st + lstr( m141fa ) + st + ue ) + '.'
  frd->( Eval( blk, s ) )
  fl := ( mpol == 'Ж' .and. lvozrast > 9 )
  s := st + head_sex + '2. Половая формула девочки: Р ' + iif( !fl .or. m142p == 0, '________', ub + st + lstr( m142p ) + st + ue )
  s += ' Ах ' + iif( !fl .or. m142ax == 0, '________', ub + st + lstr( m142ax ) + st + ue )
  s += ' Ma ' + iif( !fl .or. m142ma == 0, '________', ub + st + lstr( m142ma ) + st + ue )
  s += ' Me ' + iif( !fl .or. m142me == 0, '________', ub + st + lstr( m142me ) + st + ue ) + ';'
  frd->( Eval( blk, s ) )
  s := st + 'характеристика менструальной функции: menarhe ('
  s += iif( !fl .or. m142me1 == 0, '________', ub + st + lstr( m142me1 ) + st + ue ) + ' лет, '
  s += iif( !fl .or. m142me2 == 0, '________', ub + st + lstr( m142me2 ) + st + ue ) + ' месяцев); '
  If fl .and. emptyall( m142p, m142ax, m142ma, m142me, m142me1, m142me2 )
    m1142me3 := m1142me4 := m1142me5 := -1
  Endif
  s += 'menses (характеристика): ' + f3_inf_dds_karta( mm_142me3(), iif( fl, m1142me3, -1 ),, ub, ue, .f. )
  s += ', ' + f3_inf_dds_karta( mm_142me4(), iif( fl, m1142me4, -1 ),, ub, ue, .f. )
  s += ', ' + f3_inf_dds_karta( mm_142me5(), iif( fl, m1142me5, -1 ), ' и ', ub, ue )
  frd->( Eval( blk, s ) )
  return nil

// 16.10.25
function calc_imt( /*@*/IMT )

  IMT := iif( mHEIGHT != 0, ( mWEIGHT / ( ( mHEIGHT / 100 ) ** 2 ) ), 0 )
  update_get( 'IMT' )
  return .t.

// 15.10.25
function mm_activ()
  return { { 'да', 1 }, { 'не активно', 2 }, { 'нет', 0 } }

// 15.10.25
function mm_partial()
  return { { 'да', 1 }, { 'частично', 2 }, { 'нет', 0 } }

// 15.10.25
function mm_used()
  return { { 'да', 1 }, { 'не пользуется', 2 }, { 'нет', 0 } }

// 15.10.25
function mm_sensor()
  return { { 'развито', 1 }, { 'частично развито', 2 }, { 'не развито', 0 } }

// 15.10.25
function mm_view_obraz()
  return { { 'опрятен', 1 }, { 'не опрятен', 0 } }

// 15.10.25
function mm_access()
  return { { 'да', 1 }, { 'частично доступен', 2 }, { 'нет', 0 } }

// 15.10.25
function mm_nastr()
  return { { 'ровный', 1 }, { 'лабильный', 2 }, { 'дисфоричный', 3 }, { 'тревожный', 0 } }

// 15.10.25
function mm_intelect()
  return { { 'без особенностей', 0 }, { 'нарущена', 1 } }

// 15.10.25
function mm_self_harm()
  return { { 'есть', 0 }, { 'нет', 1 } }

// 15.10.25
function mm_socium()
  return { { 'нарушена', 0 }, { 'не нарушена', 1 } }

// 16.10.25
function mm_contact()
  return { { 'да', 1 }, { 'частично доступен', 2 }, { 'нет', 0 } }

// 16.10.25
function mm_nastroenie()
  return { { 'ровный', 1 }, { 'лабильный', 2 }, { 'дисфоричный', 3 }, { 'тревожный', 0 } }

function mm_invalid2()
  return { { 'с рождения', 0 }, { 'приобретенная', 1 } }
  
function mm_invalid5()
  
  local arr := { ;
    { 'некоторые инфекционные и паразитарные,', 1 }, ;
    { ' из них: туберкулез,', 101 }, ;
    { '         сифилис,', 201 }, ;
    { '         ВИЧ-инфекция;', 301 }, ;
    { 'новообразования;', 2 }, ;
    { 'болезни крови, кроветворных органов ...', 3 }, ;
    { 'болезни эндокринной системы ...', 4 }, ;
    { ' из них: сахарный диабет;', 104 }, ;
    { 'психические расстройства и расстройства поведения,', 5 }, ;
    { ' в том числе умственная отсталость;', 105 }, ;
    { 'болезни нервной системы,', 6 }, ;
    { ' из них: церебральный паралич,', 106 }, ;
    { '         другие паралитические синдромы;', 206 }, ;
    { 'болезни глаза и его придаточного аппарата;', 7 }, ;
    { 'болезни уха и сосцевидного отростка;', 8 }, ;
    { 'болезни системы кровообращения;', 9 }, ;
    { 'болезни органов дыхания,', 10 }, ;
    { ' из них: астма,', 110 }, ;
    { '         астматический статус;', 210 }, ;
    { 'болезни органов пищеварения;', 11 }, ;
    { 'болезни кожи и подкожной клетчатки;', 12 }, ;
    { 'болезни костно-мышечной системы и соединительной ткани;', 13 }, ;
    { 'болезни мочеполовой системы;', 14 }, ;
    { 'отдельные состояния, возникающие в перинатальном периоде;', 15 }, ;
    { 'врожденные аномалии,', 16 }, ;
    { ' из них: аномалии нервной системы,', 116 }, ;
    { '         аномалии системы кровообращения,', 216 }, ;
    { '         аномалии опорно-двигательного аппарата;', 316 }, ;
    { 'последствия травм, отравлений и др.', 17 } ;
  }
  return arr

function mm_invalid6()
  
  local arr := { ;
    { 'умственные', 1 }, ;
    { 'другие психологические', 2 }, ;
    { 'языковые и речевые', 3 }, ;
    { 'слуховые и вестибулярные', 4 }, ;
    { 'зрительные', 5 }, ;
    { 'висцеральные и метаболические расстройства питания', 6 }, ;
    { 'двигательные', 7 }, ;
    { 'уродующие', 8 }, ;
    { 'общие и генерализованные', 9 } ;
  }
  return arr
  
function mm_invalid8()
  return { { 'полностью', 1 }, { 'частично', 2 }, { 'начата', 3 }, { 'не выполнена', 0 } }
  
function mm_privivki1()
  
  local arr := { ;
    { 'привит по возрасту', 0 }, ;
    { 'не привит по медицинским показаниям', 1 }, ;
    { 'не привит по другим причинам', 2 } ;
  }
  return arr
  
function mm_privivki2()
  return { { 'полностью', 1 }, { 'частично', 2 } }

function mm_fiz_razv()
  return { { 'нормальное', 0 }, { 'с отклонениями', 1 } }

function mm_fiz_razv1()
  return { { 'нет    ', 0 }, { 'дефицит', 1 }, { 'избыток', 2 } }
  
function mm_fiz_razv2()
  return { { 'нет    ', 0 }, { 'низкий ', 1 }, { 'высокий', 2 } }
  
function mm_psih2()
  return { { 'норма', 0 }, { 'отклонение', 1 } }

function mm_142me3()
  return { { 'регулярные', 0 }, { 'нерегулярные', 1 } }

function mm_142me4()
  return { { 'обильные', 0 }, { 'умеренные', 1 }, { 'скудные', 2 } }
  
function mm_142me5()
  return { { 'болезненные', 0 }, { 'безболезненные', 1 } }
  
// 20.09.25
function mm_dispans()
  return { { 'ранее', 1 }, { 'впервые', 2 }, { 'не уст.', 0 } }

// 20.09.25
function mm_usl()
  return { { 'амб.', 0 }, { 'дн/с', 1 }, { 'стац', 2 } }
  
// 20.09.25
function mm_uch()
  return { { 'МУЗ ', 1 }, { 'ГУЗ ', 0 }, { 'фед.', 2 }, { 'част', 3 } }

// 20.09.25
function mm_gr_fiz_do()
  return { { 'I', 1 }, { 'II', 2 }, { 'III', 3 }, { 'IV', 4 } }