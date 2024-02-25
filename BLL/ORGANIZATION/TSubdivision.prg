#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'common.ch'
&& #include 'function.ch'
#include 'chip_mo.ch'

// класс для отделений учреждения файл mo_otd.dbf
CREATE CLASS TSubdivision	INHERIT	TBaseObjectBLL
	VISIBLE:
		CLASSDATA	aTypeLU		AS ARRAY INIT {;
								{ 'стандартный'                          ,0            }, ;  // 1
								{ 'скорая помощь'                        ,TIP_LU_SMP   }, ;  // 2
								{ 'дисп-ия детей-сирот в стационаре'     ,TIP_LU_DDS   }, ;  // 3
								{ 'дисп-ия детей-сирот под опекой'       ,TIP_LU_DDSOP }, ;  // 4
								{ 'профилактика несовешеннолетних'       ,TIP_LU_PN    }, ;  // 5
								{ 'предварит.осмотры несовешеннолетних'  ,TIP_LU_PREDN }, ;  // 6
								{ 'периодич.осмотры несовешеннолетних'   ,TIP_LU_PERN  }, ;  // 7
								{ 'дисп-ия/профосмотр взрослых'          ,TIP_LU_DVN   }, ;  // 8
								{ 'пренатальная диагностика'             ,TIP_LU_PREND }, ;  // 9
								{ 'гемодиализ'                           ,TIP_LU_H_DIA }, ;  // 10
								{ 'перитонеальный диализ'                ,TIP_LU_P_DIA }, ;  // 11
								{ 'жидкостная цитология'                ,TIP_LU_G_CIT }, ;  // 12
								{ 'неотложная медицинская помощь'       ,TIP_LU_NMP }, ;  // 13
								{ 'COVID углубленная диспансеризация взрослого населения',TIP_LU_DVN_COVID }, ;  // 15
								{ 'амбулаторная медицинская реабилитация',TIP_LU_MED_REAB } }  // 16
		
		PROPERTY Code READ getCode WRITE setCode							// код
		PROPERTY Name READ getName WRITE setName							// наименование
		PROPERTY Name1251 READ getName1251
		PROPERTY ShortName READ getShortName WRITE setShortName				// сокращенное наименование
		PROPERTY ShortName1251 READ getShortName1251
		PROPERTY IDDepartment READ getIDDepartment WRITE setIDDepartment	// код учреждения
		PROPERTY TypeLU READ getTypeLU WRITE setTypeLU						// тип листа учёта: 0-стандарт,1-СМП,2-ДДС,3-ДВН
		PROPERTY Profil READ getProfil WRITE setProfil						// профиль для данного отделения;по справочнику V002, по умолчанию прописывать его в лист учета и в услугу
		PROPERTY ProfilK READ getProfilK WRITE setProfilK					// 
		PROPERTY DBegin READ getDBegin WRITE setDBegin						// дата начала действия в задаче ОМС - поставить 01.01.1993
		PROPERTY DEnd READ getDEnd WRITE setDEnd							// дата окончания действия в задаче ОМС
		PROPERTY DBeginP READ getDBeginP WRITE setDBeginP					// дата начала действия в задаче "Платные услуги" - поставить 01.01.1993
		PROPERTY DEndP READ getDEndP WRITE setDEndP							// дата окончания действия в задаче "Платные услуги"
		PROPERTY DBeginO READ getDBeginO WRITE setDBeginO					// дата начала действия в задаче "Ортопедия" - поставить 01.01.1993
		PROPERTY DEndO READ getDEndO WRITE setDEndO							// дата окончания действия в задаче "Ортопедия"
		PROPERTY KodPodr READ getKodPodr WRITE setKodPodr					// код подразделения по паспорту ЛПУ
		PROPERTY TypePodr READ getTypePodr WRITE setTypePodr				// тип отд-ия: 1-приёмный покой
		PROPERTY Plan_VP READ getPlan_VP WRITE setPlan_VP					// план врачебных приемов
		PROPERTY Plan_PF READ getPlan_PF WRITE setPlan_PF					// план профилактик
		PROPERTY Plan_PD READ getPlan_PD WRITE setPlan_PD					// план приемов на дому
		PROPERTY IDSP READ getIDSP WRITE setIDSP							// код способа оплаты мед.помощи для данного отделения;по справочнику V010
		PROPERTY IDUMP READ getIDUMP WRITE setIDUMP							// код условий оказания медицинской помощи
		PROPERTY IDVMP READ getIDVMP WRITE setIDVMP							// код видов медицинской помощи
		PROPERTY KodSogl READ getKodSogl WRITE setKodSogl					// код согласования с программой SDS
		
		PROPERTY CodeSubTFOMS READ getCodeSubTFOMS WRITE setCodeSubTFOMS	// код отделения по кодировке ТФОМС из справочника SprDep - 2018 год
		PROPERTY AddressSubdivision READ getAddressSub WRITE setAddressSub	// код удалённого подразделения по массиву glob_arr_podr - 2017 год
		PROPERTY CodeTFOMS READ getCodeTFOMS WRITE setCodeTFOMS				// код подразделения по кодировке ТФОМС - 2017 год
		PROPERTY SomeSogl READ getSomeSogl WRITE setSomeSogl				// код согласования нескольких отделений с программой SDS
		PROPERTY Department READ getDepartment
		
		PROPERTY TypeLU_F READ getTypeLUFormat
		PROPERTY Profil_F READ getProfilFormat

		PROPERTY Address READ getAddress WRITE setAddress					// адрес отделения
		
		METHOD New( nId, lNew, lDeleted )
  
		&& METHOD listForJSON()
		METHOD forJSON()
	HIDDEN:
		CLASSDATA	aType		AS ARRAY INIT {;
								{ 'стандартный'                          ,0            }, ;  // 1
								{ 'скорая помощь'                        ,TIP_LU_SMP   }, ;  // 2
								{ 'дисп-ия детей-сирот в стационаре'     ,TIP_LU_DDS   }, ;  // 3
								{ 'дисп-ия детей-сирот под опекой'       ,TIP_LU_DDSOP }, ;  // 4
								{ 'профилактика несовешеннолетних'       ,TIP_LU_PN    }, ;  // 5
								{ 'предварит.осмотры несовешеннолетних'  ,TIP_LU_PREDN }, ;  // 6
								{ 'периодич.осмотры несовешеннолетних'   ,TIP_LU_PERN  }, ;  // 7
								{ 'дисп-ия/профосмотр взрослых'          ,TIP_LU_DVN   }, ;  // 8
								{ 'пренатальная диагностика'             ,TIP_LU_PREND }, ;  // 9
								{ 'гемодиализ'                           ,TIP_LU_H_DIA }, ;  // 10
								{ 'перитонеальный диализ'                ,TIP_LU_P_DIA }, ;  // 11
								{ 'жидкостная цитология'                 ,TIP_LU_G_CIT }, ;  // 12
								{ 'неотложная медицинская помощь'        ,TIP_LU_NMP 	 }, ;  // 13
								{ 'COVID углубленная диспансеризация взрослого населения',TIP_LU_DVN_COVID }, ;  // 15
								{ 'амбулаторная медицинская реабилитация',TIP_LU_MED_REAB }, ;  // 16
								{ 'постановка на диспансерный учет онкопациетов в поликлинике',TIP_LU_ONKO_DISP } ;  // 17
							}
										
		DATA FCode			INIT 0
		DATA FName			INIT space( 30 )
		DATA FShortName		INIT space( 5 )
		DATA FIDDepartment	INIT 0
		DATA FTypeLU		INIT 0
		DATA FProfil		INIT 0
		DATA FProfilK		INIT 0
		DATA FDBegin		INIT ctod( '01/01/1993' )
		DATA FDEnd			INIT ctod( '' )
		DATA FDBeginP		INIT ctod( '01/01/1993' )
		DATA FDEndP			INIT ctod( '' )
		DATA FDBeginO		INIT ctod( '01/01/1993' )
		DATA FDEndO			INIT ctod( '' )
		DATA FKodPodr		INIT space( 25 )
		DATA FTypePodr		INIT 0
		DATA FPlanVP		INIT 0
		DATA FPlanPF		INIT 0
		DATA FPlanPD		INIT 0
		DATA FIDSP			INIT 0
		DATA FIDUMP			INIT 0
		DATA FIDVMP			INIT 0
		DATA FKodSogl		INIT 0

		DATA FCodeSubTFOMS	INIT 0
		DATA FAddressSub	INIT 0
		DATA FCodeTFOMS		INIT space( 6 )
		DATA FSomeSogl		INIT space( 255 )
		DATA FDepartment	INIT nil
		DATA FAddress		INIT space(150)
		
		METHOD getCode
		METHOD setCode( nVal )
		METHOD getName
		METHOD setName( cVar )
		METHOD getName1251
		METHOD getShortName
		METHOD setShortName( cVar )
		METHOD getShortName1251
		METHOD getIDDepartment
		METHOD setIDDepartment( nVal )
		METHOD getTypeLU
		METHOD setTypeLU( nVal )
		METHOD getProfil
		METHOD setProfil( nVal )
		METHOD getProfilK
		METHOD setProfilK( nVal )
		METHOD getDBegin
		METHOD setDBegin( dVal )
		METHOD getDEnd
		METHOD setDEnd( dVal )
		METHOD getDBeginP
		METHOD setDBeginP( dVal )
		METHOD getDEndP
		METHOD setDEndP( dVal )
		METHOD getDBeginO
		METHOD setDBeginO( dVal )
		METHOD getDEndO
		METHOD setDEndO( dVal )
		METHOD getKodPodr
		METHOD setKodPodr( cVar )
		METHOD getTypePodr
		METHOD setTypePodr( nVar )
		METHOD getPlan_VP
		METHOD setPlan_VP( nVal )
		METHOD getPlan_PD
		METHOD setPlan_PD( nVal )
		METHOD getPlan_PF
		METHOD setPlan_PF( nVal )
		METHOD getIDSP
		METHOD setIDSP( nVal )
		METHOD getIDUMP
		METHOD setIDUMP( nVal )
		METHOD getIDVMP
		METHOD setIDVMP( nVal )
		METHOD getKodSogl
		METHOD setKodSogl( nVal )
		METHOD getAddress
		METHOD setAddress( cVar )
		
		METHOD getCodeSubTFOMS()				INLINE ::FCodeSubTFOMS
		METHOD setCodeSubTFOMS( param )		INLINE ::FCodeSubTFOMS := param
		METHOD getAddressSub
		METHOD setAddressSub( nVal )
		METHOD getCodeTFOMS
		METHOD setCodeTFOMS( cVar )
		METHOD getSomeSogl
		METHOD setSomeSogl( cVar )
		METHOD getDepartment
		
		METHOD getTypeLUFormat
		METHOD getProfilFormat

ENDCLASS

METHOD function forJSON()    CLASS TSubdivision
	local oRow := nil, obj := nil
	local hItems, hItem, h

	h := { => }
	hItems := { => }
	hItem := { => }
	hb_HSet( hItem, 'ID', ltrim( str( ::ID ) ) )
	hb_HSet( hItem, 'ShortName', alltrim( ::ShortName ) )
	hb_HSet( hItem, 'Name', alltrim( ::Name ) )
	if ::Department != nil
		hb_HSet( hItem, 'Department', ::Department:forJSON() )
	endif
	hb_HSet( hItem, 'CodeTFOMS', alltrim( ::CodeTFOMS ) )
	return hItem

&& METHOD function listForJSON()    CLASS TSubdivision
	&& local oRow := nil, obj := nil
	&& local hItems, hItem, h

	&& h := { => }
	&& hItems := { => }
	&& for each oRow in ::super:GetList( )
		&& hItem := { => }
		&& obj := ::FillFromHash( oRow )
		&& hb_HSet( hItem, 'ID', ltrim( str( obj:ID ) ) )
		&& hb_HSet( hItem, 'ShortName', alltrim( obj:ShortName ) )
		&& hb_HSet( hItem, 'Name', alltrim( obj:Name ) )
		&& if obj:Department != nil
			&& hb_HSet( hItem, 'Department', obj:Department:forJSON() )
		&& endif
		&& hb_HSet( hItem, 'CodeTFOMS', alltrim( obj:CodeTFOMS ) )
		&& hb_HSet( hItems, 'Отделение-' + ltrim( str( obj:ID ) ), hItem )
	&& next
	&& h[ 'СправочникОтделений' ] := hItems
	
	&& // MEMOWRIT( 'Department.json' , hb_jsonencode( h, .t., 'RU1251' ) )
	&& return h


METHOD FUNCTION getProfilFormat() 		 CLASS TSubdivision
	local ret := '', it

	if ::FProfil != 0
		if (it := ascan(getV002(), {|x| x[2] == ::FProfil})) > 0
			ret := getV002()[ it, 1 ]
		endif
	endif
	return ret

METHOD FUNCTION getTypeLUFormat() 		 CLASS TSubdivision
	return ::aType[ ::FTypeLU + 1, 1 ]

METHOD FUNCTION getCode() 		 CLASS TSubdivision
	return ::FCode

METHOD PROCEDURE setCode( nVal ) 		 CLASS TSubdivision

	::FCode := nVal
	return

METHOD FUNCTION getName() 		 CLASS TSubdivision
	return ::FName

METHOD PROCEDURE setName( cVar ) 		 CLASS TSubdivision

	::FName := cVar
	return

METHOD FUNCTION getName1251() 		 CLASS TSubdivision
	return hb_OEMToANSI( ::FName )

METHOD FUNCTION getShortName() 		 CLASS TSubdivision
	return ::FShortName

METHOD PROCEDURE setShortName( cVar ) 		 CLASS TSubdivision

	::FShortName := cVar
	return

METHOD FUNCTION getShortName1251() 		 CLASS TSubdivision
	return hb_OEMToANSI( ::FShortName )

METHOD FUNCTION getIDDepartment() 		 CLASS TSubdivision
	return ::FIDDepartment

METHOD PROCEDURE setIDDepartment( nVal ) 		 CLASS TSubdivision

	::FIDDepartment := nVal
	return

METHOD FUNCTION getTypeLU() 		 CLASS TSubdivision
	return ::FTypeLU

METHOD PROCEDURE setTypeLU( nVal ) 		 CLASS TSubdivision

	::FTypeLU := nVal
	return

METHOD FUNCTION getProfil() 		 CLASS TSubdivision
	return ::FProfil

METHOD PROCEDURE setProfil( nVal ) 		 CLASS TSubdivision

	::FProfil := nVal
	return

METHOD FUNCTION getProfilK() 		 		CLASS TSubdivision
	return ::FProfilK

METHOD PROCEDURE setProfilK( nVal ) 		 CLASS TSubdivision

	::FProfilK := nVal
	return

METHOD FUNCTION getDBegin() 		 CLASS TSubdivision
	return ::FDBegin

METHOD PROCEDURE setDBegin( dVal ) 		 CLASS TSubdivision

	::FDBegin := dVal
	return

METHOD FUNCTION getDEnd() 		 CLASS TSubdivision
	return ::FDEnd

METHOD PROCEDURE setDEnd( dVal ) 		 CLASS TSubdivision

	::FDEnd := dVal
	return

METHOD FUNCTION getDBeginP() 		 CLASS TSubdivision
	return ::FDBeginP

METHOD PROCEDURE setDBeginP( dVal ) 		 CLASS TSubdivision

	::FDBeginP := dVal
	return

METHOD FUNCTION getDEndP() 		 CLASS TSubdivision
	return ::FDEndP

METHOD PROCEDURE setDEndP( dVal ) 		 CLASS TSubdivision

	::FDEndP := dVal
	return

METHOD FUNCTION getDBeginO() 		 CLASS TSubdivision
	return ::FDBeginO

METHOD PROCEDURE setDBeginO( dVal ) 		 CLASS TSubdivision

	::FDBeginO := dVal
	return

METHOD FUNCTION getDEndO() 		 CLASS TSubdivision
	return ::FDEndO

METHOD PROCEDURE setDEndO( dVal ) 		 CLASS TSubdivision

	::FDEndO := dVal
	return

METHOD FUNCTION getKodPodr() 		 CLASS TSubdivision
	return ::FKodPodr

METHOD PROCEDURE setKodPodr( cVar ) 		 CLASS TSubdivision

	::FKodPodr := cVar
	return

METHOD FUNCTION getTypePodr() 		 CLASS TSubdivision
	return ::FTypePodr

METHOD PROCEDURE setTypePodr( nVar ) 		 CLASS TSubdivision

	::FTypePodr := nVar
	return

METHOD FUNCTION getPlan_VP() 		 CLASS TSubdivision
	return ::FPlanVP

METHOD PROCEDURE setPlan_VP( nVal ) 		 CLASS TSubdivision

	::FPlanVP := nVal
	return

METHOD FUNCTION getPlan_PF() 		 CLASS TSubdivision
	return ::FPlanPF

METHOD PROCEDURE setPlan_PF( nVal ) 		 CLASS TSubdivision

	::FPlanPF := nVal
	return

METHOD FUNCTION getPlan_PD() 		 CLASS TSubdivision
	return ::FPlanPD

METHOD PROCEDURE setPlan_PD( nVal ) 		 CLASS TSubdivision

	::FPlanPD := nVal
	return

METHOD FUNCTION getIDSP() 		 CLASS TSubdivision
	return ::FIDSP

METHOD PROCEDURE setIDSP( nVal ) 		 CLASS TSubdivision

	::FIDSP := nVal
	return

METHOD FUNCTION getIDUMP() 		 CLASS TSubdivision
	return ::FIDUMP

METHOD PROCEDURE setIDUMP( nVal ) 		 CLASS TSubdivision

	::FIDUMP := nVal
	return

METHOD FUNCTION getIDVMP() 		 CLASS TSubdivision
	return ::FIDVMP

METHOD PROCEDURE setIDVMP( nVal ) 		 CLASS TSubdivision

	::FIDVMP := nVal
	return

METHOD FUNCTION getKodSogl() 		 CLASS TSubdivision
	return ::FKodSogl

METHOD PROCEDURE setKodSogl( nVal ) 		 CLASS TSubdivision

	::FKodSogl := nVal
	return

METHOD FUNCTION getDepartment() 		 CLASS TSubdivision
	return ::FDepartment

METHOD FUNCTION getAddressSub() 		 CLASS TSubdivision
	return ::FAddressSub

METHOD PROCEDURE setAddressSub( nVal ) 		 CLASS TSubdivision

	::FAddressSub := nVal
	return

METHOD FUNCTION getCodeTFOMS() 		 CLASS TSubdivision
	return ::FCodeTFOMS

METHOD PROCEDURE setCodeTFOMS( cVar ) 		 CLASS TSubdivision

	::FCodeTFOMS := cVar
	return

METHOD FUNCTION getSomeSogl() 		 CLASS TSubdivision
	return ::FSomeSogl

METHOD PROCEDURE setSomeSogl( cVar ) 		 CLASS TSubdivision

	::FSomeSogl := cVar
	return

METHOD FUNCTION getAddress() 		 CLASS TSubdivision
	return ::FAddress

METHOD PROCEDURE setAddress( cVar ) 		 CLASS TSubdivision

	::FAddress := cVar
	return

METHOD Clone()		 CLASS TSubdivision
	local oTarget := nil
	
	oTarget := ::super:Clone()
	oTarget:Code( 0 )
	return oTarget

METHOD New( nId, lNew, lDeleted ) CLASS TSubdivision
			
	::FNew 					:= hb_defaultValue( lNew, .t. )
	::FDeleted			:= hb_defaultValue( lDeleted, .f. )
	::FID						:= hb_defaultValue( nID, 0 )

	if ascan( glob_klin_diagn, 1 ) > 0
		aadd( ::aTypeLU, { 'жидкостная цитология рака шейки матки', TIP_LU_G_CIT } )
	elseif ascan( glob_klin_diagn, 2 ) > 0
		aadd( aTypeLU, { 'пренатальный скрининг наруш.внутр.разв.', TIP_LU_G_CIT } )
	endif
	
	hb_ADel( ::aType, 7 , .t. )
	hb_ADel( ::aType, 6 , .t. )

	return self