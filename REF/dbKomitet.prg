#include 'set.ch'
#include 'dbstruct.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'
#include 'function.ch'
#include 'common.ch'

// 16.02.26
function mm_filial_tf()
  
  return { ;
    { 'Волгоградский', 1 }, ;
    { 'Заволжский', 2 }, ;
    { 'Северный', 3 }, ;
    { 'Медведицкий', 4 }, ;
    { 'Хопёрский', 5 }, ;
    { 'Южный', 6 } ;
  }

// 16.02.26
function mm_ist_fin()
  
  local arr := AClone( mm1ist_fin() )
  ins_array( arr, 1, { 'ОМС', I_FIN_OMS } )
  // "Дата договора"})

  return arr

// 16.02.26
function mm1ist_fin()
  
  return { ;
    { 'бюджет',      I_FIN_BUD }, ;   // 1
    { 'расчеты с МО', I_FIN_LPU }, ;   // 2
    { 'платные',     I_FIN_PLAT }, ;  // 0
    { 'ДМС',         I_FIN_DMS }, ;   // 5
    { 'не оплачен',  I_FIN_NEOPL }, ; // 3
    { 'за свой счёт', I_FIN_OWN } ;    // 4
  }

// 01.04.23 комитеты/МО
function get_komitet()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'name', 'C', 30, 0, nil, nil, ;
                       space(30), nil, 'Название'})
    aadd(arr, {'fname', 'C', 70, 0, nil, nil, ;
                       space(70), nil, 'Полное наименование'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, ;
                       space(20), nil, 'ИНН/КПП'})
    aadd(arr, {'adres', 'C', 50, 0, nil, nil, ;
                       space(50), nil, 'Адрес'})
    aadd(arr, {'telefon', 'C', 8, 0, nil, nil, ;
                       '  -  -  ', nil, 'Телефон'})
    aadd(arr, {'bank', 'C', 70, 0, nil, nil, ;
                       space(70), nil, 'Банк'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, ;
                       'БИК'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, ;
                       'Расчетный счет'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, ;
                       'Корр.счет'})
    aadd(arr, {'okonh', 'C', 15, 0, nil, nil, space(15), nil, ;
                       'Код по ОКОНХ'})
    aadd(arr, {'okpo', 'C', 15, 0, nil, nil, space(15), nil, ;
                       'Код по ОКПО'})
    aadd(arr, {'parakl', 'N', 1, 0, nil, ;
                       {|x|menu_reader(x, mm_danet, A__MENUVERT)}, ;
                       0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
                       'Включать ПАРАКЛИНИКУ в сумму счета по данному комитету (МО):'})
    aadd(arr, {'ist_fin', 'N', 1, 0, nil, ;
                       {|x|menu_reader(x, mm1ist_fin(), A__MENUVERT)}, ;
                       0, {|x|inieditspr(A__MENUVERT, mm1ist_fin(), x)}, ;
                       'Источник финансирования:'})
  endif
  return arr

// 01.04.23 прочие страховые
function get_strah()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'name', 'C', 30, 0, nil, nil, ;
      space(30), nil, 'Название'})
    aadd(arr, {'fname', 'C', 70, 0, nil, nil, ;
      space(70), nil, 'Полное наименование'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, ;
      space(20), nil, 'ИНН/КПП'})
    aadd(arr, {'adres', 'C', 50, 0, nil, nil, ;
      space(50), nil, 'Адрес'})
    aadd(arr, {'telefon', 'C', 8, 0, nil, nil, ;
      '  -  -  ', nil, 'Телефон'})
    aadd(arr, {'bank', 'C', 70, 0, nil, nil, ;
      space(70), nil, 'Банк'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, ;
      'БИК'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, ;
      'Расчетный счет'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, ;
      'Корр.счет'})
    aadd(arr, {'okonh', 'C', 15, 0, nil, nil, space(15), nil, ;
      'Код по ОКОНХ'})
    aadd(arr, {'okpo', 'C', 15, 0, nil, nil, space(15), nil, ;
      'Код по ОКПО'})
    aadd(arr, {'tfoms', 'N', 2, 0, nil, nil, 0, nil, ;
      'Код ТФОМС', , {||.f.}})
    aadd(arr, {'parakl', 'N', 1, 0, nil, ;
      {|x|menu_reader(x, mm_danet, A__MENUVERT)}, ;
      0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
      'Включать ПАРАКЛИНИКУ в сумму счета по данной компании:'})
    aadd(arr, {'ist_fin', 'N', 1, 0, nil, ;
      {|x|menu_reader(x, mm1ist_fin(), A__MENUVERT)}, ;
      0, {|x|inieditspr(A__MENUVERT, mm1ist_fin(), x)}, ;
     'Источник финансирования:'})
  endif
  return arr

// 01.04.23 ДСМО и предприятия по взаимозачёту для платных услуг
function get_DMS()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'name', 'C', 30, 0, nil, nil, ;
      space(30), nil, 'Название'})
    aadd(arr, {'fname', 'C', 70, 0, nil, nil, ;
      space(70), nil, 'Полное наименование'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, ;
      space(20), nil, 'ИНН/КПП'})
    aadd(arr, {'adres', 'C', 100, 0, nil, nil, ;
      space(100), nil, 'Адрес'})
    aadd(arr, {'telefon', 'C', 8, 0, nil, nil, ;
      '  -  -  ', nil, 'Телефон'})
    aadd(arr, {'bank', 'C', 100, 0, nil, nil, ;
      space(100), nil, 'Банк'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, ;
      'БИК'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, ;
      'Расчетный счет'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, ;
      'Корр.счет'})
    aadd(arr, {'n_dog', 'C', 30, 0, nil, nil, space(30), nil, ;
      'Номер договора'})
    aadd(arr, {'d_dog', 'D', 8, 0, nil, nil, ctod(''), nil, ;
      'Дата договора'})
  endif
  return arr

// 01.04.23 Ваша организация
function get_struct_organiz()
  static arr

  if arr == nil
    arr := {}
    aadd(arr, {'kod_tfoms', 'C', 8, 0, nil, nil, ;
      space(8), nil, 'Регистрационный код МО в ТФОМС', ;
      {|g| valid_kod_tfoms(g) }, {|| currentuser():IsAdmin()}})
    aadd(arr, {'name_tfoms', 'C', 60, 0, nil, , '', , 'Наименование (в ТФОМС)', , {|| .f.}})
    aadd(arr, {'uroven', 'N', 1, 0, nil, , 0, , 'Уровень цен Вашей МО', , {|| .f.}})
    aadd(arr, {'name', 'C', 130, 0, nil, nil, space(130), nil, 'Название'})
    aadd(arr, {'name_schet', 'C', 130, 0, nil, nil, space(130), nil, 'Название для счёта'})
    aadd(arr, {'name_xml', 'C', 255, 0, nil, nil, space(255), nil, 'Название для портала МЗ РФ'})
    aadd(arr, {'inn', 'C', 20, 0, nil, nil, space(20), nil, 'ИНН/КПП'})
    aadd(arr, {'adres', 'C', 70, 0, nil, nil, space(70), nil, 'Адрес'})
    aadd(arr, {'telefon', 'C', 20, 0, nil, nil, space(20), nil, 'Телефон'})
    aadd(arr, {'bank', 'C', 130, 0, nil, nil, space(130), nil, 'Банк'})
    aadd(arr, {'smfo', 'C', 10, 0, nil, nil, space(10), nil, 'БИК'})
    aadd(arr, {'r_schet', 'C', 45, 0, nil, nil, space(45), nil, 'Расчетный счет'})
    aadd(arr, {'k_schet', 'C', 20, 0, nil, nil, space(20), nil, 'Корр.счет'})
    aadd(arr, {'okonh', 'C', 15, 0, nil, nil, space(15), nil, 'Код по ОКОНХ'})
    aadd(arr, {'okpo', 'C', 15, 0, nil, nil, space(15), nil, 'Код по ОКПО'})
    aadd(arr, {'e_1', 'C', 1, 0, nil, nil, ;
      space(1), nil, 'Банковские реквизиты для перечисления доплат из средств субсидий ФФОМС:', , ;
      {|| .f.}})
    aadd(arr, {'name2', 'C', 130, 0, nil, nil, space(130), nil, space(5) + '- название'})
    aadd(arr, {'bank2', 'C', 130, 0, nil, nil, space(130), nil, space(5) + '- банк'})
    aadd(arr, {'smfo2', 'C', 10, 0, nil, nil, space(10), nil, space(5) + '- БИК'})
    aadd(arr, {'r_schet2', 'C', 45, 0, nil, nil, space(45), nil, space(5) + '- расчетный счет'})
    aadd(arr, {'k_schet2', 'C', 20, 0, nil, nil, space(20), nil, space(5) + '- корр.счет'})
    aadd(arr, {'ogrn', 'C', 15, 0, ,, space(15), , 'ОГРН ЛПУ'})
    aadd(arr, {'ruk_fio', 'C', 60, 0, ,, space(60), , 'Ф.И.О. главного врача'})
    aadd(arr, {'ruk', 'C', 20, 0, ,, space(20), , 'Фамилия и инициалы главного врача (им.падеж)'})
    aadd(arr, {'ruk_r', 'C', 20, 0, ,, space(20), , 'Фамилия и инициалы главного врача (род.падеж)'})
    aadd(arr, {'bux', 'C', 20, 0, ,, space(20), , 'Фамилия и инициалы главного бухгалтера'})
    aadd(arr, {'ispolnit', 'C', 20, 0, ,, space(20), , 'Ф.И.О. исполнителя для счетов ОМС'})
    aadd(arr, {'name_d', 'C', 32, 0, ,, space(32), , 'Наименование орг-ии (для договора)'})
    aadd(arr, {'filial_h', 'N', 1, 0, nil, ;
      {|x|menu_reader(x, mm_filial_tf(), A__MENUVERT)}, ;
      0, {|x|inieditspr(A__MENUVERT, mm_filial_tf(), x)}, ;
      'Филиал ТФОМС, в который отправляется файл с ходатайствами'})
  endif
  return arr
