#include 'common.ch'
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 27.03.24 скорректировать массивы по углубленной диспансеризации COVID
Function ret_arrays_drz()

  Local dvn_drz_arr_usl

  // 1- наименование меню
  // 2- шифр услуги
  // 3- этап или список допустимых этапов, пример: {1,2}
  // 4 - диагноз (0 или 1) может быть?
  // 5- возможен отказ пациента (0 - нет, 1 - да)
  // 6 - возраст для мужчин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста
  // 7 - возраст для женщин (число лет), если 1 - все возраста, если список {} то конкретные значения возраста

  // 10- V002 - Классификатор прифилей оказанной медицинской помощи
  // 11- V004 - Классификатор медицинских специальностей
  // 12 - признак услуги ТФОМС/ФФОМС 0 - ТФОМС, 1 - ФФОМС
  // 13 - соответствующая услуга ФФОМС услуге ТФОМС
  dvn_drz_arr_usl := { ; // Услуги на экран для ввода
  { ;
    'Пульсооксиметрия', 'A12.09.005', 1, 0, 1, 1, 1, ;
    1, 1, 111, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { ;
    'Проведение спирометрии или спирографии', 'A12.09.001', 1, 0, 1, 1, 1, ;
    1, 1, 111, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { ;
    'Общий (клинический) анализ крови развернутый', 'B03.016.003', 1, 0, 1, 1, 1, ;
    1, 1, { 34, 37, 38 }, { 1107, 1301, 1402, 1702, 1801, 2011 }, ;
    1, '';
    }, ;
    { ;
    'Анализ крови биохимический общетерапевтический', 'B03.016.004', 1, 0, 1, 1, 1, ;
    1, 1, { 34, 37, 38 }, { 1107, 1301, 1402, 1702, 1801, 2011 }, ;
    1, '';
    }, ;
    { ;
    'Рентгенография легких', 'A06.09.007', 1, 0, 1, 1, 1, ;
    1, 1, 78, { 1118, 1802, 2020 }, ;
    1, '';
    }, ;
    { ;
    'Проведение теста с 6 минутной ходьбой', '70.8.2', 1, 0, 1, 1, 1, ;
    1, 1, { 42, 151 }, { 39, 76, 206 }, ;
    0, 'A23.30.023';
    }, ;
    { ;
    'Определение концентрации Д-димера в крови', '70.8.3', 1, 0, 1, 1, 1, ;
    1, 1, { 34, 37, 38 }, { 26, 215, 217 }, ;
    0, 'A09.05.051.001';
    }, ;
    { ;
    'Проведение Эхокардиографии', '70.8.50', 2, 0, 1, 1, 1, ;
    1, 1, { 106, 111 }, { 81, 89, 226 }, ;
    0, 'A04.10.002';
    }, ;
    { ;
    'Проведение КТ легких', '70.8.51', 2, 0, 1, 1, 1, ;
    1, 1, 78, 60, ;
    0, 'A06.09.005';
    }, ;
    { ;
    'Дуплексное сканир-ие вен нижних конечностей', '70.8.52', 2, 0, 1, 1, 1, ;
    1, 1, 106, 81, ;
    0, 'A04.12.006.002';
    }, ;
    { ;
    'Приём (осмотр) врачом-терапевтом первичный', 'B01.026.001', 1, 1, 0, 1, 1, ;
    1, 1, { 42, 151 }, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { ;
    'Приём (осмотр) врачом-терапевтом повторный', 'B01.026.002', 2, 1, 0, 1, 1, ;
    1, 1, { 42, 151 }, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    1, '';
    }, ;
    { ;
    'Комплексное посещение углубленная диспансеризация I этап', '70.8.1', 1, 1, 0, 1, 1, ;
    1, 1, { 42, 151 }, { 2021, 110103, 110303, 110906, 111006, 111905, 112212, 112611, 113418, 113509, 180202 }, ;
    0, '';
    };
    }

  Return dvn_drz_arr_usl

// 27.03.24
Function read_arr_drz( lkod, is_all )

  Local arr, i, sk
  Local aliasIsUse := aliasisalreadyuse( 'TPERS' )
  Local oldSelect

  If ! aliasIsUse
    oldSelect := Select()
    r_use( dir_server + 'mo_pers', , 'TPERS' )
  Endif

  Private mvar
  arr := read_arr_dispans( lkod )
  Default is_all To .t.
  For i := 1 To Len( arr )
    If ValType( arr[ i ] ) == 'A' .and. ValType( arr[ i, 1 ] ) == 'C'
      Do Case
      Case arr[ i, 1 ] == '0' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1mobilbr := arr[ i, 2 ]
      Case arr[ i, 1 ] == '1' .and. ValType( arr[ i, 2 ] ) == 'D'
        mDateCOVID := arr[ i, 2 ]
      Case arr[ i, 1 ] == '2' .and. ValType( arr[ i, 2 ] ) == 'N'
        mOKSI := arr[ i, 2 ]
      Case arr[ i, 1 ] == '3' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1strong := arr[ i, 2 ]
      Case arr[ i, 1 ] == '4' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1dyspnea := arr[ i, 2 ]
      Case arr[ i, 1 ] == '5' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1komorbid := arr[ i, 2 ]
      Case is_all .and. eq_any( arr[ i, 1 ], '11', '12', '13', '14', '15' ) .and. ;
          ValType( arr[ i, 2 ] ) == 'A' .and. Len( arr[ i, 2 ] ) >= 7
        sk := Right( arr[ i, 1 ], 1 )
        pole_diag := 'mdiag' + sk
        pole_1pervich := 'm1pervich' + sk
        pole_1stadia := 'm1stadia' + sk
        pole_1dispans := 'm1dispans' + sk
        pole_1dop := 'm1dop' + sk
        pole_1usl := 'm1usl' + sk
        pole_1san := 'm1san' + sk
        pole_d_diag := 'mddiag' + sk
        pole_d_dispans := 'mddispans' + sk
        pole_dn_dispans := 'mdndispans' + sk
        If ValType( arr[ i, 2, 1 ] ) == 'C'
          &pole_diag := arr[ i, 2, 1 ]
        Endif
        If ValType( arr[ i, 2, 2 ] ) == 'N'
          &pole_1pervich := arr[ i, 2, 2 ]
        Endif
        If ValType( arr[ i, 2, 3 ] ) == 'N'
          &pole_1stadia := arr[ i, 2, 3 ]
        Endif
        If ValType( arr[ i, 2, 4 ] ) == 'N'
          &pole_1dispans := arr[ i, 2, 4 ]
        Endif
        If ValType( arr[ i, 2, 5 ] ) == 'N' .and. Type( pole_1dop ) == 'N'
          &pole_1dop := arr[ i, 2, 5 ]
        Endif
        If ValType( arr[ i, 2, 6 ] ) == 'N' .and. Type( pole_1usl ) == 'N'
          &pole_1usl := arr[ i, 2, 6 ]
        Endif
        If ValType( arr[ i, 2, 7 ] ) == 'N' .and. Type( pole_1san ) == 'N'
          &pole_1san := arr[ i, 2, 7 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 8 .and. ValType( arr[ i, 2, 8 ] ) == 'D' .and. Type( pole_d_diag ) == 'D'
          &pole_d_diag := arr[ i, 2, 8 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 9 .and. ValType( arr[ i, 2, 9 ] ) == 'D' .and. Type( pole_d_dispans ) == 'D'
          &pole_d_dispans := arr[ i, 2, 9 ]
        Endif
        If Len( arr[ i, 2 ] ) >= 10 .and. ValType( arr[ i, 2, 10 ] ) == 'D' .and. Type( pole_dn_dispans ) == 'D'
          &pole_dn_dispans := arr[ i, 2, 10 ]
        Endif
      Case is_all .and. arr[ i, 1 ] == '19' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_usl_otkaz := arr[ i, 2 ]
      Case arr[ i, 1 ] == '30' .and. ValType( arr[ i, 2 ] ) == 'N'
        // m1GRUPPA := arr[i,2]
      Case arr[ i, 1 ] == '31' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1prof_ko := arr[ i, 2 ]
      Case is_all .and. arr[ i, 1 ] == '40' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_otklon := arr[ i, 2 ]
      Case arr[ i, 1 ] == '45' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1dispans  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '46' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1nazn_l   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '47'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1dopo_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1dopo_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_dopo_na := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '48' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1ssh_na   := arr[ i, 2 ]
      Case arr[ i, 1 ] == '49' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1spec_na  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '50'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1sank_na  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1sank_na  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_sanat := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '51' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1p_otk  := arr[ i, 2 ]
      Case arr[ i, 1 ] == '52'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_v_mo  := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_v_mo  := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_mo := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '53' .and. ValType( arr[ i, 2 ] ) == 'A'
        arr_mo_spec := arr[ i, 2 ]
      Case arr[ i, 1 ] == '54'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_stac := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_stac := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_stac := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '55' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_stac := arr[ i, 2 ]
      Case arr[ i, 1 ] == '56'
        If ValType( arr[ i, 2 ] ) == 'N'
          m1napr_reab := arr[ i, 2 ]
        Elseif ValType( arr[ i, 2 ] ) == 'A'
          m1napr_reab := arr[ i, 2 ][ 1 ]
          If arr[ i, 2 ][ 2 ] > 0
            TPERS->( dbGoto( arr[ i, 2 ][ 2 ] ) )
            mtab_v_reab := TPERS->tab_nom
          Endif
        Endif
      Case arr[ i, 1 ] == '57' .and. ValType( arr[ i, 2 ] ) == 'N'
        m1profil_kojki := arr[ i, 2 ]
      Endcase
    Endif
  Next

  If ! aliasIsUse
    TPERS->( dbCloseArea() )
    Select( oldSelect )
  Endif

  Return Nil

// 23.01.17
Function f_valid_diag_oms_sluch_drz( get, k )

  Local sk := lstr( k )

  Private pole_diag := 'mdiag' + sk, ;
    pole_d_diag := 'mddiag' + sk, ;
    pole_pervich := 'mpervich' + sk, ;
    pole_1pervich := 'm1pervich' + sk, ;
    pole_stadia := 'm1stadia' + sk, ;
    pole_dispans := 'mdispans' + sk, ;
    pole_1dispans := 'm1dispans' + sk, ;
    pole_d_dispans := 'mddispans' + sk

  If get == Nil .or. !( &pole_diag == get:original )
    If Empty( &pole_diag )
      &pole_pervich := Space( 12 )
      &pole_1pervich := 0
      &pole_d_diag := CToD( '' )
      &pole_stadia := 1
      &pole_dispans := Space( 3 )
      &pole_1dispans := 0
      &pole_d_dispans := CToD( '' )
    Else
      &pole_pervich := inieditspr( A__MENUVERT, mm_pervich, &pole_1pervich )
      &pole_dispans := inieditspr( A__MENUVERT, mm_danet, &pole_1dispans )
    Endif
  Endif
  If emptyall( m1dispans1, m1dispans2, m1dispans3, m1dispans4, m1dispans5 )
    m1dispans := 0
  Elseif m1dispans == 0
    m1dispans := ps1dispans
  Endif
  mdispans := inieditspr( A__MENUVERT, mm_dispans, m1dispans )
  update_get( pole_pervich )
  update_get( pole_d_diag )
  update_get( pole_stadia )
  update_get( pole_dispans )
  update_get( pole_d_dispans )
  update_get( 'mdispans' )

  Return .t.
