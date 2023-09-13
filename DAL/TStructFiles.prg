#include 'hbclass.ch'
#include 'dbstruct.ch'
#include 'function.ch'

CREATE CLASS TStructFiles

	CLASSDATA oSelf           INIT Nil          // ссылка на самое себя
  
	HIDDEN:
		VAR hbFiles
  
	VISIBLE:
  
		METHOD New()
		METHOD GetDescr( className )		   INLINE   ::hbFiles[ Upper( className ) ]
		METHOD ExistFileClass( className )

ENDCLASS

METHOD ExistFileClass( className ) CLASS TStructFiles
	local ret := .f., descrFile := ::getDescr( className )
	
	return hb_FileExists( descrFile:FileName )

METHOD New() CLASS TStructFiles

	Local cClassName := '', aEtalonDB := {}, aIndex := { }, cName := '', cAlias := ''
	Local arr, xValue
                  
	If ::oSelf != Nil
		Return ::oSelf
	EndIf
  
	::hbFiles := hb_Hash()    // создаем массив объектов описателей файлов

// версия БД
	cClassName := Upper( 'TVersionDB' )
	cName := dir_server + 'VER_BASE' + sdbf
	aEtalonDB :=	{ ;
					{ 'VERSION',      'N',  10,   0 } ; 
					}             
	cAlias := 'VER'
	aIndex := { }
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Версия БД' ) )
//---------

// справочник пользователей
	cClassName := Upper( 'TUserDB' )
	cName := dir_server + 'base1' + sdbf
	aEtalonDB := 	{ ;
					{ 'P1',      'C',  20,   0 }, ; // Ф.И.О.
					{ 'P2',      'N',   1,   0 }, ; // тип доступа
					{ 'P3',      'C',  10,   0 }, ; // пароль
					{ 'P4',      'C',   1,   0 }, ; // код отделения [ chr(kod) ]
					{ 'P5',      'C',  20,   0 }, ; // должность
					{ 'P6',      'N',   1,   0 }, ; // Группа КЭК (1-3)
					{ 'P7',      'C',  10,   0 }, ; // пароль1 для фискального регистратора
					{ 'P8',      'C',  10,   0 }, ; // пароль2 для фискального регистратора
					{ 'INN',     'C',  12,   0 }, ; // ИНН кассира
					{ 'IDROLE',  'N',   4,   0}, ;  // ID группы пользователей
					{ 'DOV_DATA','C',   8,   0}, ; // Дата доверенности кассира 
					{ 'DOV_NOM', 'C',  20,   0}; // Номер доверенности кассира
							 }
	cAlias := 'TUserDB'
	aIndex := { }
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл пользователей системы' ) )

// фуйл учета работы операторов
	cClassName := Upper( 'TAudit_mainDB' )
	cName := dir_server + 'mo_oper' + sdbf
	aEtalonDB := 	{ ;
					{ 'PO',			'C',   1,   0 }, ; // код оператора asc(po)
					{ 'PD',			'C',   4,   0 }, ; // дата ввода c4tod(pd)
					{ 'V0',			'C',   3,   0 }, ; // добавление в регистратуре
					{ 'VR',			'C',   3,   0 }, ; // полные реквизиты      \
					{ 'VK',			'C',   3,   0 }, ; // реквизиты из картотеки => ft_unsqzn(V..., 6)
					{ 'VU',			'C',   3,   0 }, ; // ввод услуг            /
					{ 'TASK',		'N',   1,   0 }, ; // код задачи            /
					{ 'CS',			'C',   4,   0 }, ; // количество введённых символов
					{ 'APP_EDIT',	'N',   1,   0};  // 0 - добавление, 1 - редактирование
					}
	cAlias := 'TAudit_mainDB'
	aIndex := { ;
				{ dir_server + 'mo_oper', 'pd + po + str( task, 1 ) + str( app_edit, 1 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Учет работы операторов главный' ) )

	cClassName := Upper( 'TAuditDB' )
	cName := dir_server + 'mo_opern' + sdbf
	aEtalonDB := 	{ ;
					{ 'PD',		'C',   4,   0}, ; // дата ввода c4tod(pd)
					{ 'PO',		'C',   1,   0}, ; // код оператора asc(po)
					{ 'PT',		'C',   1,   0}, ; // код задачи
					{ 'TP',		'C',   1,   0}, ; // тип (1-карточка, 2-л/у, 3-услуги)
					{ 'AE',		'C',   1,   0}, ; // 1-добавление, 2-редактирование, 3-удаление
					{ 'KK',		'C',   3,   0}, ; // кол-во (карточек, л/у или услуг)
					{ 'KP',		'C',   3,   0};  // количество введённых полей
					}
	cAlias := 'TAuditDB'
	aIndex := { ;
				{ dir_server + 'mo_opern', 'pd + po + pt + tp + ae' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Учет работы операторов' ) )
	
	cClassName := Upper( 'TRoleUserDB' )
	cName := dir_server + 'Roles' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',    'C',  30,   0 }, ; // название роли
					{ 'ACL_TASK','C',  255,   0 }, ; // доступ к задачам
					{ 'ACL_DEP', 'C',  255,   0 } ; // доступ к учреждениям
					}
	cAlias := 'TRoleUserDB'
	aIndex := { }
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл ролей пользователей системы' ) )
//---------

// справочник пациентов 1
	cClassName := Upper( 'TPatientDB' )
	cName := dir_server + 'kartotek' + sdbf
	aEtalonDB :=	{ ;
					{ 'KOD',		'N',     7,     0 }, ;
					{ 'FIO',		'C',    50,     0 }, ; // Ф.И.О. больного
					{ 'POL',		'C',     1,     0 }, ; // пол
					{ 'DATE_R',		'D',     8,     0 }, ; // дата рождения больного
					{ 'VZROS_REB',	'N',     1,     0 }, ; // 0-взрослый, 1-ребенок, 2-подросток
					{ 'ADRES',		'C',    50,     0 }, ; // адрес больного
					{ 'MR_DOL',		'C',    50,     0 }, ; // место работы или причина безработности
					{ 'RAB_NERAB',	'N',     1,     0 }, ; // 0-работающий, 1-неработающий
					{ 'KOMU',		'N',     1,     0 }, ; // от 1 до 5
					{ 'STR_CRB',	'N',     2,     0 }, ; // код стр.компании, комитета и т.п.
					{ 'ZA_SMO',		'N',     2,     0 }, ; // 0-нет,'-8'-полис недействителен,'-9'-ошибки в реквизитах
					{ 'POLIS',		'C',    17,     0 }, ; // серия и номер страхового полиса
					{ 'SROK_POLIS',	'C',     4,     0 }, ; // срок действия полиса
					{ 'MI_GIT',		'N',     1,     0 }, ; // 0-нет, 9-рабочее поле KOMU
					{ 'RAJON_GIT',	'N',     2,     0 }, ; // код района места жительства
					{ 'MEST_INOG',	'N',     1,     0 }, ; // 0-нет,9-отдельные ФИО
					{ 'RAJON',		'N',     2,     0 }, ; // код района финансирования
					{ 'BUKVA',		'C',     1,     0 }, ; // одна буква
					{ 'UCHAST',		'N',     2,     0 }, ; // номер участка
					{ 'KOD_VU',		'N',     5,     0 }, ; // код в участке
					{ 'SNILS',		'C',    11,     0 }, ;
					{ 'DEATH',		'N',	1,		0 }, ; // 0-нет,1-умер по результатам сверки
					{ 'KOD_TF',		'N',	10,		0 }, ; // код по кодировке ТФОМС
					{ 'KOD_MIS',	'C',	20,		0 }, ; // ЕНП - единый номер полиса ОМС
					{ 'KOD_AK',		'C',	10,		0 }, ; // собственный номер амбулаторной карты
					{ 'TIP_PR',		'N',	1,		0 }, ; // тип/статус прикрепления 1-из WQ,2-из реестра СП и ТК,3-из файла прикрепления,4-открепление,5-сверка
					{ 'MO_PR',		'C',	6,		0 }, ; // код МО прикрепления
					{ 'DATE_PR',	'D',	8,		0 }, ; // дата прикрепления
					{ 'SNILS_VR',	'C',	11,		0 }, ; // СНИЛС участкового врача
					{ 'PC1',		'C',	10,		0 }, ; // при добавлении:kod_polzovat+c4sys_date+hour_min(seconds())
					{ 'PC2',		'C',	10,		0 }, ; // 0-нет,1-умер по результатам сверки
					{ 'PC3',		'C',	10,		0 }, ;
					{ 'PN1',		'N',	10,		0 }, ;
					{ 'PN2',		'N',	10,		0 }, ;
					{ 'PN3',		'N',	10,		0 } ;
				}
	cAlias := 'TPatientDB'
	aIndex :=	{ ;
				{ dir_server + 'kartotek', 'str( kod, 7 )' }, ;
				{ dir_server + 'kartoten', 'if( kod > 0, "1", "0" ) + upper( fio ) + dtos( date_r )' }, ;
				{ dir_server + 'kartotep', 'if( kod > 0, "1", "0" ) + polis' }, ;
				{ dir_server + 'kartoteu', 'strzero( uchast, 2 ) + strzero( kod_vu, 5 )' }, ;
				{ dir_server + 'kartotes', 'if( kod > 0, "1", "0" ) + snils' }, ;
				{ dir_server + 'kartotee', 'if( kod > 0, "1", "0" ) + kod_mis' } ;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Пациенты, содержимое файла картотеки' ) )
//---------

// справочник пациентов 2
	cClassName := Upper( 'TPatientExtDB' )
	cName := dir_server + 'kartote_' + sdbf
	aEtalonDB :=	{ ;
				{ 'VPOLIS',		'N',  1, 0 }, ; // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый;по умолчанию 1 - старый
				{ 'SPOLIS',		'C', 10, 0 }, ; // серия полиса;;для наших - разделить по пробелу
				{ 'NPOLIS',		'C', 20, 0 }, ; // номер полиса;;"для иногородних - вынуть из ""k_inog"" и разделить"
				{ 'SMO',		'C',  5, 0 }, ; // реестровый номер СМО;;преобразовать из старых кодов в новые, иногродние = 34
				{ 'BEG_POLIS',	'C',  4, 0 }, ; // дата начала действия полиса ;в формате dtoc4();"поле ""beg_polis"" из файла ""k_inog"" для иногородних"
				{ 'STRANA',		'C',  3, 0 }, ; // гражданство пациента (страна);выбор из справочника стран;"поле ""strana"" из файла ""k_inog"" для иногородних, для остальных пусто = РФ"
				{ 'GOROD_SELO',	'N',  1, 0 }, ; // житель?;1-город, 2-село, 3-рабочий поселок;"поле ""gorod_selo"" из файла ""pp_human"""
				{ 'VID_UD',		'N',  2, 0 }, ; // вид удостоверения личности;по кодировке ФФОМС
				{ 'SER_UD',		'C', 10, 0 }, ; // серия удостоверения личности
				{ 'NOM_UD',		'C', 20, 0 }, ; // номер удостоверения личности
				{ 'KEMVYD',		'N',  4, 0 }, ; // кем выдан документ;"справочник ""s_kemvyd"""
				{ 'KOGDAVYD',	'D',  8, 0 }, ; // когда выдан документ
				{ 'KATEGOR',	'N',  3, 0 }, ; // категория пациента
				{ 'KATEGOR2',	'N',  3, 0 }, ; // категория пациента (собственная для МО)
				{ 'MESTO_R',	'C',100, 0 }, ; // место рождения;;
				{ 'OKATOG',		'C', 11, 0 }, ; // код места жительства по ОКАТО;выбор из справочника ОКАТО;попытаться сформировать для нашей области по коду района
				{ 'OKATOP',		'C', 11, 0 }, ; // код места пребывания по ОКАТО;;
				{ 'ADRESP',		'C', 50, 0 }, ; // адрес места пребывания;сюда будем заносить остаток адреса места пребывания;
				{ 'DMS_SMO',	'N',  3, 0 }, ; // код СМО ДМС
				{ 'DMS_POLIS',	'C', 17, 0 }, ; // код полиса ДМС
				{ 'KVARTAL',	'C',  5, 0 }, ; // квартал для Волжского
				{ 'KVARTAL_D',	'C',  5, 0 }, ; // дом в квартале Волжского
				{ 'PHONE_H',	'C', 11, 0 }, ; // телефон домашний
				{ 'PHONE_M',	'C', 11, 0 }, ; // телефон мобильный
				{ 'PHONE_W',	'C', 11, 0 }, ; // телефон рабочий
				{ 'KOD_LGOT',	'C',  3, 0 }, ; // код льготы по ДЛО
				{ 'IS_REGISTR',	'N',  1, 0 }, ; // есть ли в регистре ДЛО;0-нет, 1-есть;
				{ 'PENSIONER',	'N',  1, 0 }, ; // является пенсионером?;0-нет, 1-да;
				{ 'INVALID',	'N',  1, 0 }, ; // инвалидность;0-нет,1,2,3-степень, 4-инвалид детства;
				{ 'INVALID_ST',	'N',  1, 0 }, ; // степень инвалидности;1 или 2;
				{ 'BLOOD_G',	'N',  1, 0 }, ; // группа крови;от 1 до 4;
				{ 'BLOOD_R',	'C',  1, 0 }, ; // резус-фактор;"+" или "-";
				{ 'WEIGHT',		'N',  3, 0 }, ; // вес в кг;;
				{ 'HEIGHT',		'N',  3, 0 }, ; // рост в см;;
				{ 'WHERE_KART',	'N',  1, 0 }, ; // где амбулаторная карта;0-в регистратуре, 1-у врача, 2-на руках
				{ 'GR_RISK',	'N',  3, 0 }, ; // группа риска по стандарту горздрава;;если есть REGI_FL.DBF, то взять из него
				{ 'DATE_FL',	'C',  4, 0 }, ; // дата последней флюорогрфии;;если есть REGI_FL.DBF, то взять из него
				{ 'DATE_MR',	'C',  4, 0 }, ; // дата последнего муниципального рецепта
				{ 'DATE_FR',	'C',  4, 0 };  // дата последнего федерального рецепта
				}
	cAlias := 'TPatientExtDB'
	aIndex :=	{ ;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Пациенты, содержимое файла картотеки. Дополнительная информация 1' ) )
//---------

// справочник пациентов 3
	cClassName := Upper( 'TPatientAddDB' )
	cName := dir_server + 'kartote2' + sdbf
	aEtalonDB := { ;
				{ 'KOD_TF',    'N', 10,0 }, ; // код по кодировке ТФОМС
				{ 'KOD_MIS',   'C', 20,0 }, ; // ЕНП - единый номер полиса ОМС
				{ 'KOD_AK',    'C', 10,0 }, ; // собственный номер амбулаторной карты (КМИС/ЛИС)
				{ 'TIP_PR',    'N',  1,0 }, ; // тип/статус прикрепления 1-из WQ,2-из реестра СП и ТК,3-из файла прикрепления,4-открепление,5-сверка
				{ 'MO_PR',     'C',  6,0 }, ; // код МО прикрепления
				{ 'DATE_PR',   'D',  8,0 }, ; // дата прикрепления
				{ 'SNILS_VR',  'C', 11,0 }, ; // СНИЛС участкового врача
				{ 'PC1',       'C', 10,0 }, ; // при добавлении:kod_polzovat+c4sys_date+hour_min(seconds())
				{ 'PC2',       'C', 10,0 }, ; // 0-нет,1-умер по результатам сверки
				{ 'PC3',       'C', 10,0 }, ; //
				{ 'PC4',       'C', 10,0 }, ; // дата прикрепления к МО
				{ 'PC5',       'C', 10,0 }, ; //
				{ 'PN1',       'N', 10,0 }, ; //
				{ 'PN2',       'N', 10,0 }, ; //
				{ 'PN3',       'N', 10,0};  //
				}
	cAlias := 'TPatientAddDB'
	aIndex :=	{ ;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Пациенты, содержимое файла картотеки. Дополнительная информация 2' ) )
//---------

// информация об организации
	cClassName := Upper( 'TOrganizationDB' )
	cName := dir_server + 'organiz' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD_TFOMS',	'C',	8,	0 }, ;
					{ 'NAME_TFOMS',	'C',	60,	0 }, ;
					{ 'UROVEN',		'N',	1,	0 }, ;
					{ 'NAME',		'C',  130,	0 }, ;
					{ 'NAME_SCHET',	'C',  130,	0 }, ;
					{ 'INN',			'C',   20,	0 }, ;
					{ 'ADRES',		'C',   70,	0 }, ;
					{ 'TELEFON',		'C',   20,	0 }, ;
					{ 'BANK',		'C',  130,	0 }, ;
					{ 'SMFO',		'C',   10,	0 }, ;
					{ 'R_SCHET',		'C',   45,	0 }, ;
					{ 'K_SCHET',		'C',   20,	0 }, ;
					{ 'OKONH',		'C',   15,	0 }, ;
					{ 'OKPO',		'C',   15,	0 }, ;
					{ 'E_1',			'C',	1,	0 }, ;
					{ 'NAME2',		'C',  130,	0 }, ;
					{ 'BANK2',		'C',  130,	0 }, ;
					{ 'SMFO2',		'C',   10,	0 }, ;
					{ 'R_SCHET2',	'C',   45,	0 }, ;
					{ 'K_SCHET2',	'C',   20,	0 }, ;
					{ 'OGRN',		'C',   15,	0 }, ;
					{ 'RUK_FIO',		'C',   60,	0 }, ;
					{ 'RUK',			'C',   20,	0 }, ;
					{ 'RUK_R',		'C',   20,	0 }, ;
					{ 'BUX',			'C',   20,	0 }, ;
					{ 'ISPOLNIT',	'C',   20,	0 }, ;
					{ 'NAME_D',		'C',   32,	0 }, ;
					{ 'FILIAL_H',	'N',	1,	0 } ;
					}
	cAlias := 'TOrganizationDB'
	aIndex := { }
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл описания организации' ) )
//---------

// справочник учреждений
	cClassName := Upper( 'TDepartmentDB' )
	cName := dir_server + 'mo_uch' + sdbf
	aEtalonDB :=	{ ;
					{ 'KOD',       'N', 3, 0 }, ; // код;;из 'l_ucher'
					{ 'NAME',      'C',30, 0 }, ; // наименование;сократили с 70 до 30;'из ''l_ucher'''
					{ 'SHORT_NAME','C', 5, 0 }, ; // сокращенное наименование;;
					{ 'IDCHIEF',   'N', 4,  0}, ;  // номер записи в файле mo_pers. Ссылка на руководителя учреждения
					{ 'ADDRESS',   'C', 150, 0}, ; // адрес нахождения учреждения
					{ 'COMPET',    'C', 40, 0}, ; // документ утверждения руководителя
					{ 'IS_TALON',  'N', 1, 0 }, ; // учреждение работает со статталоном?;0-нет, 1-да;оставить 0, или поставить 1 в зависимости от массива UCHER_TALON (см. c_allpub.prg строка 273)
					{ 'DBEGIN',    'D', 8, 0 }, ; // дата начала действия;;поставить 01.01.1993
					{ 'DEND',      'D', 8, 0 } ;  // дата окончания действия;;поставить 31.12.2000, или оставить пустым в зависимости от массива UCHER_ARRAY (см. b_init.prg строка 428 и далее)
				}             
	cAlias := 'TDepartmentDB'
	aIndex :=	{ ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Учреждения' ) )
//---------

	cClassName := Upper( 'TSubdivisionDB' )
	cName := dir_server + 'mo_otd' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',       'N', 3, 0 }, ; // код
					{ 'NAME',      'C',30, 0 }, ; // наименование
					{ 'KOD_LPU',   'N', 3, 0 }, ; // код учреждения
					{ 'SHORT_NAME','C', 5, 0 }, ; // сокращенное наименование
					{ 'DBEGIN',    'D', 8, 0 }, ; // дата начала действия в задаче ОМС
					{ 'DEND',      'D', 8, 0 }, ; // дата окончания действия в задаче ОМС
					{ 'DBEGINP',   'D', 8, 0 }, ; // дата начала действия в задаче "Платные услуги"
					{ 'DENDP',     'D', 8, 0 }, ; // дата окончания действия в задаче "Платные услуги"
					{ 'DBEGINO',   'D', 8, 0 }, ; // дата начала действия в задаче "Ортопедия"
					{ 'DENDO',     'D', 8, 0 }, ; // дата окончания действия в задаче "Ортопедия"
					{ 'PLAN_VP',   'N', 6, 0 }, ; // план врачебных приемов
					{ 'PLAN_PF',   'N', 6, 0 }, ; // план профилактик
					{ 'PLAN_PD',   'N', 6, 0 }, ; // план приемов на дому
					{ 'PROFIL',    'N', 3, 0 }, ; // профиль для данного отделения;по справочнику V002, по умолчанию прописывать его в лист учета и в услугу
					{ 'PROFIL_K',  'N', 3, 0 }, ; // профиль койки для данного отделения по справочнику V020, по умолчанию прописывать его в лист учета
					{ 'IDSP',      'N', 2, 0 }, ; // код способа оплаты мед.помощи для данного отделения;по справочнику V010
					{ 'IDUMP',     'N', 2, 0 }, ; // код условий оказания медицинской помощи
					{ 'IDVMP',     'N', 2, 0 }, ; // код видов медицинской помощи
					{ 'TIP_OTD',   'N', 2, 0 }, ; // тип отд-ия: 1-приёмный покой
					{ 'KOD_PODR',  'C',25, 0 }, ; // код подразделения по паспорту ЛПУ
					{ 'TIPLU',     'N', 2, 0 }, ; // тип листа учёта: 0-стандарт,1-СМП,2-ДДС,3-ДВН
					{ 'CODE_DEP',  'N', 3, 0 }, ; // код отделения по кодировке ТФОМС из справочника SprDep - 2018 год
					{ 'ADRES_PODR','N', 2, 0 }, ; // код удалённого подразделения по массиву glob_arr_podr - 2017 год
					{ 'ADDRESS',   'C',150,0 }, ; // адрес нахождения учреждения
					{ 'CODE_TFOMS','C', 6, 0 }, ; // код подразделения по кодировке ТФОМС - 2017 год
					{ 'KOD_SOGL',  'N',10, 0 }, ; // код согласования одного отделения с программой SDS
					{ 'SOME_SOGL', 'C',255,0 } ;  // код согласования нескольких отделений с программой SDS
					}
	cAlias := 'TSubdivisionDB'
	aIndex := { }
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл отделений' ) )

// список сотрудников
	cClassName := Upper( 'TEmployeeDB' )
	cName := dir_server + 'mo_pers' + sdbf
	aEtalonDB :=	{ ;
				{ 'KOD',       'N',	4,	0 }, ; // код
				{ 'UCH',       'N', 3,	0 }, ; // код учреждения
				{ 'OTD',       'N', 3,	0 }, ; // код отделения
				{ 'NAME_DOLJ', 'C',30,	0 }, ; // наименование должности
				{ 'KATEG',     'N', 1,	0 }, ; // код категории
				{ 'FIO',       'C',50,	0 }, ; // ФИО
				{ 'STAVKA',    'N', 4,	2 }, ; // ставка
				{ 'VID',       'N', 1,	0 }, ; // вид работы;0-основной, 1-совмещение
				{ 'VR_KATEG',  'N', 1,	0 }, ; // код врачебной категории 'kateg'
				{ 'DOLJKAT',   'C',15,	0 }, ; // наименование должности по категории
				{ 'D_KATEG',   'D', 8,	0 }, ; // дата подтверждения категории
				{ 'SERTIF',    'N', 1,	0 }, ; // наличие сертификата;0-нет, 1-да
				{ 'D_SERTIF',  'D', 8,	0 }, ; // дата подтверждения сертификата
				{ 'PRVS',      'N', 9,	0 }, ; // Специальность врача по справочнику V004
				{ 'PRVS_NEW',  'N', 4,	0 }, ; // Специальность врача по справочнику V015
				{ 'PROFIL',    'N', 3,  0 }, ; // профиль для данной специальности по справочнику V002
				{ 'TAB_NOM',   'N', 5,	0 }, ; // табельный номер
				{ 'SVOD_NOM',  'N', 5,	0 }, ; // сводный табельный номер (вводится, если у человека несколько таб.номеров, используется в сводной статистике по сотруднику)
				{ 'KOD_DLO',   'N', 5,	0 }, ; // код врача для выписки рецептов по ДЛО
				{ 'UROVEN',    'N', 2,	0 }, ; // уровень оплаты (от 1 до 99)
				{ 'OTDAL',     'N', 1,	0 }, ; // признак отдаленности;0-нет, 1-да
				{ 'SNILS',     'C',11,	0 }, ; // СНИЛС врача
				{ 'DBEGIN',    'D', 8,	0 }, ; // дата начала действия
				{ 'DEND',      'D', 8,	0 } ;  // дата окончания действия
				}             
	cAlias := 'TEmployeeDB'
	aIndex :=	{ ;
				{ dir_server + 'mo_pers', 'str( tab_nom, 5 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл списка персонала' ) )
//---------

// плановая месячная трудоемкость персонала
	cClassName := Upper( 'TPlannedMonthlyStaffDB' )
	cName := dir_server + 'uch_pers' + sdbf
	aEtalonDB :=	{ ;
				{ 'KOD',       'N',	4,	0 }, ; // код
				{ 'GOD',       'N', 4,	0 }, ; // 
				{ 'MES',       'N', 4,	0 }, ; //
				{ 'M_TRUD',	   'N', 6,	1 } ; //
				}             
	cAlias := 'TPlannedMonthlyStaffDB'
	
	aIndex :=	{ ;
				{ dir_server + 'uch_pers', 'str( kod, 4 ) + str( god, 4 ) + str( mes, 2 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл плановая месячная трудоемкость персонала' ) )
//---------

//справочник диагнозов
	cClassName := Upper( 'TICD10DB' )
	cName := dir_exe + '_mo_mkb' + sdbf
	aEtalonDB :=	{ ;
				{ 'SHIFR',  'C',  6,   0 }, ;
				{ 'NAME',   'C', 65,  0 }, ;
				{ 'KS',     'N',  1,   0 }, ; 
				{ 'DBEGIN', 'D',  8,   0 }, ;
				{ 'DEND',   'D',  8,   0 }, ;
				{ 'POL',    'C',  1,   0 }  ;
				}             
	cAlias := 'DIAGDB'
	aIndex :=	{ ;
				{ cur_dir + '_MO_MKB', 'SHIFR + STR( KS, 1 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Диагнозы' ) )
//---------

//справочник групп (классов) диагнозов
	cClassName := Upper( 'TICD10ClassDB' )
	cName := dir_exe + '_mo_mkbk' + sdbf
	aEtalonDB :=	{ ;
				{ 'KLASS',  'C',  5,   0 }, ;
				{ 'SH_B',   'C',  3,   0 }, ; 
				{ 'SH_E',   'C',  3,   0 }, ; 
				{ 'NAME',   'C', 65,  0 }, ;
				{ 'KS',     'N',  1,   0 }  ;
				}             
	cAlias := 'DIAGClassDB'
	aIndex :=	{ ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Классов диагнозов' ) )
//---------

//справочник подгрупп диагнозов
	cClassName := Upper( 'TICD10GroupDB' )
	cName := dir_exe + '_mo_mkbg' + sdbf
	aEtalonDB :=	{ ;
				{ 'SH_B',   'C',  3,   0 }, ; 
				{ 'SH_E',   'C',  3,   0 }, ; 
				{ 'NAME',   'C', 65,  0 }, ;
				{ 'KS',     'N',  1,   0 }  ;
				}             
	cAlias := 'DIAGGroupDB'
	aIndex :=	{ ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Группы диагнозов' ) )
//---------

// справочник служб организации
	cClassName := Upper( 'TSlugbaDB' )
	cName := dir_server + 'slugba' + sdbf
	aEtalonDB := 	{ ;
					{ 'SHIFR',      'N',      3,      0 }, ;
					{ 'NAME',       'C',     40,      0 } ;
					}
	cAlias := 'TSlugbaDB'
	aIndex := { ;
				{ dir_server + 'slugba', 'STR( SHIFR, 3 )' } ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл служб организации' ) )
//---------

// справочник стационаров детей-сирот
	cClassName := Upper( 'TStddsDB' )
	cName := dir_server + 'mo_stdds' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',    250,      0 }, ;
					{ 'ADRES',      'C',    250,      0 }, ;
					{ 'VEDOM',      'N',      1,      0 }, ;
					{ 'FED_KOD',    'N',     10,      0 } ;
					}
	cAlias := 'TStddsDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл стационаров детей-сирот' ) )
//---------

// справочник образовательных учреждений
	cClassName := Upper( 'TSchoolDB' )
	cName := dir_server + 'mo_schoo' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',     30,      0 }, ;
					{ 'FNAME',      'C',    250,      0 }, ;
					{ 'ADRES',      'C',    250,      0 }, ;
					{ 'TIP',        'N',      1,      0 }, ;
					{ 'FED_KOD',    'N',     10,      0 } ;
					}
	cAlias := 'TSchoolDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл образовательных учреждений' ) )
//---------

// справочник адресных строк
	cClassName := Upper( 'TAddressStringDB' )
	cName := dir_server + 's_adres' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',     40,      0 } ;
					}
	cAlias := 'TAddressStringDB'
	aIndex := { ;
				{ dir_server + 's_adres', 'UPPER( name )' } ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл адресных сокращений' ) )
//---------

// справочник органов МВД выдавших документы
	cClassName := Upper( 'TPublisherDB' )
	cName := dir_server + 's_kemvyd' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',     150,      0 } ;
					}
	cAlias := 'TPublisherDB'
	aIndex := { ;
				{ dir_server + 's_kemvyd', 'UPPER( name )' } ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл органов МВД выдавших докменты' ) )
//---------

// справочник мест работы
	cClassName := Upper( 'TPlaceOfWorkDB' )
	cName := dir_server + 's_mr' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',     50,      0 } ;
					}
	cAlias := 'TPlaceOfWorkDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл места работы' ) )
//---------

// справочник прочих компаний
	cClassName := Upper( 'TInsuranceCompanyDB' )
	cName := dir_server + 'str_komp' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',        'N',      2,      0 }, ;
					{ 'NAME',       'C',     30,      0 }, ;
					{ 'FNAME',      'C',     70,      0 }, ;
					{ 'INN',        'C',     20,      0 }, ;
					{ 'ADRES',      'C',     50,      0 }, ;
					{ 'TELEFON',    'C',      8,      0 }, ;
					{ 'BANK',       'C',     70,      0 }, ;
					{ 'SMFO',       'C',     10,      0 }, ;
					{ 'R_SCHET',    'C',     45,      0 }, ;
					{ 'K_SCHET',    'C',     20,      0 }, ;
					{ 'OKONH',      'C',     15,      0 }, ;
					{ 'OKPO',       'C',     15,      0 }, ;
					{ 'TFOMS',      'N',      2,      0 }, ;
					{ 'PARAKL',     'N',      1,      0 }, ;
					{ 'IST_FIN',    'N',      1,      0 } ;
					}
	cAlias := 'TInsuranceCompanyDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник прочих компаний' ) )
//---------

// справочник страховых компаний ДМС
	cClassName := Upper( 'TCompanyDMSDB' )
	cName := dir_server + 'p_d_smo' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',     30,      0 }, ;
					{ 'FNAME',      'C',     70,      0 }, ;
					{ 'INN',        'C',     20,      0 }, ;
					{ 'ADRES',      'C',    100,      0 }, ;
					{ 'TELEFON',    'C',      8,      0 }, ;
					{ 'BANK',       'C',    100,      0 }, ;
					{ 'SMFO',       'C',     10,      0 }, ;
					{ 'R_SCHET',    'C',     45,      0 }, ;
					{ 'K_SCHET',    'C',     20,      0 }, ;
					{ 'N_DOG',      'C',     30,      0 }, ;
					{ 'D_DOG',      'D',      8,      0 } ;
					}
	cAlias := 'TCompanyDMSDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник страховых компаний ДМС' ) )
//---------

// справочник компаний для взаимозачета
	cClassName := Upper( 'TCompanyVzaimDB' )
	cName := dir_server + 'p_pr_vz' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',       'C',     30,      0 }, ;
					{ 'FNAME',      'C',     70,      0 }, ;
					{ 'INN',        'C',     20,      0 }, ;
					{ 'ADRES',      'C',    100,      0 }, ;
					{ 'TELEFON',    'C',      8,      0 }, ;
					{ 'BANK',       'C',    100,      0 }, ;
					{ 'SMFO',       'C',     10,      0 }, ;
					{ 'R_SCHET',    'C',     45,      0 }, ;
					{ 'K_SCHET',    'C',     20,      0 }, ;
					{ 'N_DOG',      'C',     30,      0 }, ;
					{ 'D_DOG',      'D',      8,      0 } ;
					}
	cAlias := 'TCompanyVzaimDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник компаний для взаимозачетов' ) )
//---------

// справочник комитетов
	cClassName := Upper( 'TCommitteeDB' )
	cName := dir_server + 'komitet' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',        'N',      2,      0 }, ;
					{ 'NAME',       'C',     30,      0 }, ;
					{ 'FNAME',      'C',     70,      0 }, ;
					{ 'INN',        'C',     20,      0 }, ;
					{ 'ADRES',      'C',     50,      0 }, ;
					{ 'TELEFON',    'C',      8,      0 }, ;
					{ 'BANK',       'C',     70,      0 }, ;
					{ 'SMFO',       'C',     10,      0 }, ;
					{ 'R_SCHET',    'C',     45,      0 }, ;
					{ 'K_SCHET',    'C',     20,      0 }, ;
					{ 'OKONH',      'C',     15,      0 }, ;
					{ 'OKPO',       'C',     15,      0 }, ;
					{ 'PARAKL',     'N',      1,      0 }, ;
					{ 'IST_FIN',    'N',      1,      0 } ;
					}
	cAlias := 'TCommitteeDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник комитетов' ) )
//---------

// справочник группы услуг для способа оплаты = 5
	cClassName := Upper( 'TUSL_U5DB' )
	cName := dir_server + 'u_usl_5' + sdbf
	aEtalonDB := 	{ ;
					{ 'TIP',		'N',  2, 0 }, ;
					{ 'USL_1',		'C', 10, 0 }, ;
					{ 'USL_2',		'C', 10, 0 }, ;
					{ '_USL_1',		'C', 20, 0 }, ;
					{ '_USL_2',		'C', 20, 0 }, ;
					{ 'PROCENT',	'N',  5, 2 }, ;
					{ 'PROCENT2',	'N',  5, 2 }, ;
					{ 'RAZRYAD',	'N',  2, 0 }, ;
					{ 'OTDAL',		'N',  1, 0 } ;
					}
	cAlias := 'TUSL_U5DB'
	aIndex := { }
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'группы услуг для способа оплаты = 5' ) )
//---------

// справочник привязка участковых врачей к участкам
	cClassName := Upper( 'TDistrictDoctorDB' )
	cName := dir_server + 'mo_uchvr' + sdbf
	aEtalonDB := 	{ ;
					{ 'UCH',	'N',	2,	0 }, ;
					{ 'IS',		'N',	2,	0 }, ;
					{ 'VRACH',	'N',	4,	0 }, ;
					{ 'VRACHV',	'N',	4,	0 }, ;
					{ 'VRACHD',	'N',	4,	0 } ;
					}
	cAlias := 'TDistrictDoctorDB'
	aIndex := { ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл привязка участковых врачей к участкам' ) )
//---------

	cClassName := Upper( 'TServiceDB' )
	cName := dir_server + 'uslugi' + sdbf
	aEtalonDB :=	{ ;
				{ 'KOD',     'N',  4,	0 }, ;
				{ 'KOD_UP',  'N',  4,	0 }, ;
				{ 'NAME',    'C', 65,	0 }, ;
				{ 'SHIFR',   'C', 10,	0 }, ;
				{ 'SHIFR1',  'C', 10,	0 }, ;
				{ 'SLUGBA',  'N',  3,	0 }, ;
				{ 'CENA',    'N', 10,	2 }, ;
				{ 'CENA_D',  'N', 10,	2 }, ;
				{ 'PCENA',   'N', 10,	2 }, ;
				{ 'PCENA_D', 'N', 10,	2 }, ;
				{ 'DMS_CENA','N', 10,	2 }, ;
				{ 'PNDS',    'N', 10,	2 }, ;
				{ 'PNDS_D',  'N', 10,	2 }, ;
				{ 'IS_NUL',  'L',  1,	0 }, ;
				{ 'IS_NULP', 'L',  1,	0 }, ;
				{ 'GRUPPA',  'N',  1,	0 }, ;
				{ 'ZF',      'N',  1,	0 }, ;
				{ 'FULL_NAME','C', 255, 0 }, ;
				{ 'PROFIL',  'N',  3,	0 } ;  // профиль;по справочнику V002
				}             
	cAlias := 'TServiceDB'
	aIndex :=	{ ;
				{ dir_server + 'uslugi', 'str( kod, 4 )' }, ;
				{ dir_server + 'uslugish', 'shifr' }, ;
				{ dir_server + 'uslugis1', 'IIF(Empty( shifr1 ), shifr, shifr1 )' }, ;
				{ dir_server + 'uslugisl', 'Str( slugba, 3 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл услуг' ) )
//---------

	cClassName := Upper( 'TIntegratedServiceDB' )
	cName := dir_server + 'uslugi_k' + sdbf
	aEtalonDB :=	{ ;
				{ 'SHIFR',		'C',	10,	0 }, ;	// шифр услуги
				{ 'NAME',		'C',	60,	0 }, ;	// наименование услуги
				{ 'KOD_VR',		'N',	4,	0 }, ;  // код врача
				{ 'KOD_AS',		'N',	4,	0 } ;  // код ассистента
				}             
	cAlias := 'TIntegratedServiceDB'
	aIndex :=	{ ;
				{ dir_server + 'uslugi_k', 'SHIFR' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл для комплексных услуг' ) )
//---------

	cClassName := Upper( 'TComponentsIntegratedServiceDB' )
	cName := dir_server + 'uslugi1k' + sdbf
	aEtalonDB :=	{ ;
				{ 'SHIFR',		'C',	10,	0 }, ;	// шифр комплексной услуги
				{ 'SHIFR1',		'C',	10,	0 } ;	// шифр входящей услуги
				}             
	cAlias := 'TComponentsIntegratedServiceDB'
	aIndex :=	{ ;
				{ dir_server + 'uslugi1k', 'SHIFR + SHIFR1' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл cостава комплексных услуг' ) )
//---------

// справочник услуг без врачей и ассистентов
	cClassName := Upper( 'TServiceWoDoctorDB' )
	cName := dir_server + 'usl_uva' + sdbf
	aEtalonDB := 	{ ;
					{ 'SHIFR',	'C',	10,	0 }, ; // шифр услуги (шаблон)
					{ 'KOD_VR',	'N',	1,	0 }, ; // не вводить код врача ?
					{ 'KOD_AS',	'N',	1,	0 }, ; // не вводить код ассистента ?
					{ 'KOD_VRN','N',	1,	0 }, ; // не вводить код направившего врача ?
					{ 'KOD_ASN','N',	1,	0 }	; // не вводить код направившего ассистента ?
					}
	cAlias := 'TServiceWoDoctorDB'
	aIndex := { ;
				{ dir_server + 'usl_uva', 'shifr' } ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника услуг без врачей и ассистентов' ) )
//---------

// справочник несоместимых услуг
	cClassName := Upper( 'TCompostionIncompServiceDB' )
	cName := dir_server + 'ns_usl' + sdbf
	aEtalonDB := 	{ ;
					{ 'NAME',	'C',	30,	0 }, ; // 
					{ 'KOL',	'N',	6,	0 } ; // 
					}
	cAlias := 'TCompostionIncompServiceDB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника несовместиых услуг' ) )
//---------

// справочник комплексных услуг
	cClassName := Upper( 'TIncompatibleServiceDB' )
	cName := dir_server + 'ns_usl_k' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',	'N',	6,	0 }, ; // 
					{ 'SHIFR',	'C',	10,	0 } ; // 
					}
	cAlias := 'TIncompatibleServiceDB'
	aIndex := { ;
				{ dir_server + 'ns_usl_k', 'STR( kod, 6 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника комплексных услуг' ) )
//---------

// справочник услуги Минздрава РФ (ФФОМС) // группа файлов
	cClassName := Upper( 'TServiceFFOMSDB' )
	cName := exe_dir + '_mo_uslf' + sdbf
	aEtalonDB := 	{ ;
					{ 'SHIFR',		'C',	20,	0 }, ; // 
					{ 'NAME',		'C',  255,	0 }, ; // 
					{ 'DATEBEG',	'D',	8,	0 }, ; // 
					{ 'DATEEND',	'D',	8,	0 } ; // 
					}
	cAlias := 'TServiceFFOMSDB'
	aIndex := { ;
				{ cur_dir + '_mo_uslf', 'shifr' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника услуг ФФОМС' ) )
//---------

// справочник услуги Минздрава РФ (ФФОМС) 2017 // группа файлов
	cClassName := Upper( 'TServiceFFOMS7DB' )
	cName := exe_dir + '_mo7uslf' + sdbf
	aEtalonDB := 	{ ;
					{ 'SHIFR',		'C',	20,	0 }, ; // 
					{ 'NAME',		'C',  255,	0 }, ; // 
					{ 'TIP',		'N',	1,	0 }, ; // 
					{ 'GRP',		'N',	1,	0 }, ; // 
					{ 'UETV',		'N',	5,	2 }, ; // 
					{ 'UETD',		'N',	5,	2 }, ; // 
					{ 'DATEBEG',	'D',	8,	0 }, ; // 
					{ 'DATEEND',	'D',	8,	0 } ; // 
					}
	cAlias := 'TServiceFFOMS7DB'
	aIndex := { ;
				{ cur_dir + '_mo7uslf', 'shifr' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника услуг ФФОМС 2017' ) )
//---------

// справочник совмещения наших услуг с услугами Минздрава РФ (ФФОМС)
	cClassName := Upper( 'TMo_suDB' )
	cName := dir_server + 'mo_su' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',		'N',	6,	0 }, ;	// 
					{ 'NAME',		'C',	65,	0 }, ;	// 
					{ 'SHIFR',		'C',	10,	0 }, ;	// 
					{ 'SHIFR1',		'C',	20,	0 }, ;	// 
					{ 'TIP',		'N',	1,	0 }, ;	// 5-для стомат.услуг 2016 года
					{ 'SLUGBA',		'N',	3,	0 }, ;	// 
					{ 'ZF',			'N',	1,	0 }, ;	// 
					{ 'PROFIL',		'N',	3,	0 } ;	// профиль;по справочнику V002
					}
	cAlias := 'TMo_suDB'
	aIndex := { ;
				{ dir_server + 'mo_su', 'STR( kod, 6 )' }, ;
				{ dir_server + 'mo_sush', 'shifr' }, ;
				{ dir_server + 'mo_sush1', 'shifr + STR( tip, 1 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника совмещения наших услуг с услугами Минздрава РФ (ФФОМС)' ) )
//---------

// справочник услуг по подразделениям
	cClassName := Upper( 'TServiceBySubdivisionDB' )
	cName := dir_server + 'usl_otd' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',		'N',	4,	0 }, ;	// 
					{ 'OTDEL',		'C',	255,0 } ;	// 
					}
	cAlias := 'TServiceBySubdivisionDB'
	aIndex := { ;
				{ dir_server + 'usl_otd', 'STR( kod, 4 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл справочника услуг по подразделениям' ) )
//---------

// файл содержащий платные договора
	cClassName := Upper( 'TContractDB' )
	cName := dir_server + 'hum_p' + sdbf
	aEtalonDB := { ;
					{ 'KOD_K'     ,   'N',     7,     0 }, ; // код по картотеке
					{ 'N_KVIT'    ,   'N',     5,     0 }, ; // номер квитанционной книжки
					{ 'KV_CIA'    ,   'N',     6,     0 }, ; // номер квитанции
					{ 'KOD_DIAG'  ,   'C',     5,     0 }, ; // шифр 1-ой осн.болезни
					{ 'SOPUT_B1'  ,   'C',     5,     0 }, ; // шифр 1-ой сопутствующей болезни
					{ 'SOPUT_B2'  ,   'C',     5,     0 }, ; // шифр 2-ой сопутствующей болезни
					{ 'SOPUT_B3'  ,   'C',     5,     0 }, ; // шифр 3-ой сопутствующей болезни
					{ 'SOPUT_B4'  ,   'C',     5,     0 }, ; // шифр 4-ой сопутствующей болезни
					{ 'SOPUT_B5'  ,   'C',     5,     0 }, ; // шифр 5-ой сопутствующей болезни
					{ 'LPU'       ,   'N',     3,     0 }, ; // код учреждения
					{ 'OTD'       ,   'N',     3,     0 }, ; // код отделения
					{ 'N_DATA'    ,   'D',     8,     0 }, ; // дата начала лечения
					{ 'K_DATA'    ,   'D',     8,     0 }, ; // дата окончания лечения
					{ 'KOD_VR'    ,   'N',     4,     0 }, ; // код направившего врача
					{ 'CENA'      ,   'N',    10,     2 }, ; // стоимость лечения
					{ 'TIP_USL'   ,   'N',     1,     0 }, ; // 0-платная, 1-д/страх., 2-в/зачет
					{ 'PR_SMO'    ,   'N',     6,     0 }, ; // код предприятия / добровольного СМО
					{ 'D_POLIS'   ,   'C',    25,     0 }, ; // полис по добровольному страх-ию
					{ 'GP_NOMER'  ,   'C',    16,     0 }, ; // № гарантийного письма по ДМС
					{ 'GP_DATE'   ,   'D',     8,     0 }, ; // дата гарантийного письма по ДМС
					{ 'GP2NOMER'  ,   'C',    16,     0 }, ; // № 2-го гарантийного письма по ДМС
					{ 'GP2DATE'   ,   'D',     8,     0 }, ; // дата 2-го гарантийного письма по ДМС
					{ 'PDATE'     ,   'C',     4,     0 }, ; // дата оплаты услуги
					{ 'DATE_VOZ'  ,   'C',     4,     0 }, ; // дата возврата
					{ 'SUM_VOZ'   ,   'N',    10,     2 }, ; // сумма возврата
					{ 'SBANK'     ,   'N',    10,     2 }, ; // сумма, оплаченная по банковской карте
					{ 'DATE_CLOSE',   'D',     8,     0 }, ; // дата закрытия листа учета
					{ 'IS_KAS'    ,   'N',     1,     0 }, ; // касса(0-без кассы,1-чек,2-нет чека)
					{ 'PLAT_FIO'  ,   'C',    40,     0 }, ; // ФИО плательщика
					{ 'PLAT_INN'  ,   'C',    12,     0 }, ; // ИНН плательщика
					{ 'FR_DATA'   ,   'C',     4,     0 }, ; // дата записи
					{ 'FR_TIME'   ,   'N',     5,     0 }, ; // время записи
					{ 'KOD_OPER'  ,   'N',     3,     0 }, ; // код оператора
					{ 'FR_ZAVOD'  ,   'C',    16,     0 }, ; // зав.номер кассы
					{ 'FR_TIP'    ,   'N',     1,     0 }, ; // тип кассы
					{ 'VZFR_DATA' ,   'C',     4,     0 }, ; // возврат дата записи
					{ 'VZFR_TIME' ,   'N',     5,     0 }, ; // возврат время записи
					{ 'VZKOD_OPER',   'N',     3,     0 }, ; // возврат код оператора
					{ 'VZFR_ZAVOD',   'C',    16,     0 }, ; // возврат зав.номер кассы
					{ 'VZFR_TIP'  ,   'N',     1,     0 }, ; // возврат тип кассы
					{ 'FR_TIPKART',   'N',     1,     0 }, ; // ТИП банковской карты
					{ 'I_POST'    ,   'C',    30,     0 } ;  // электронная почта
				}
	cAlias := 'TContractDB'
    && index on str(kod_k,7)+dtos(k_data)+str(KV_CIA,6) to (dir_server+"hum_pkk") descending progress
    && index on str(otd,3) to (dir_server+"hum_pn") progress
    && index on dtos(k_data) to (dir_server+"hum_pd") progress
    && index on str(n_kvit,5) to (dir_server+"hum_pv") progress
    && index on str(tip_usl,1)+iif(empty(date_close),"0"+dtos(k_data),;
             && "1"+dtos(date_close))+dtos(k_data) to (dir_server+"hum_pc") progress
	aIndex := { ;
				{ dir_server + 'hum_pkk', 'str( kod_k, 7 ) + dtos( k_data ) + str( KV_CIA, 6 )' }, ;
				{ dir_server + 'hum_pn', 'str( otd, 3 )' }, ;
				{ dir_server + 'hum_pd', 'dtos( k_data )' }, ;
				{ dir_server + 'hum_pv', 'str( n_kvit, 5 )' }, ;
				{ dir_server + 'hum_pc', 'str( tip_usl, 1 ) + iif( empty( date_close ), "0" + dtos( k_data ), "1" + dtos( date_close ) ) + dtos( k_data )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий содержащий платные договора' ) )
//---------

	cClassName := Upper( 'TContractPayerDB' )
	cName := dir_server + 'hum_plat' + sdbf
	aEtalonDB :=	{ ;
					{ 'KOD',		'N',	7,		0 }, ;	// код листа учета (по БД hum_p)
					{ 'ADRES',		'C',	50,		0 }, ;	// Адрес плательщика
					{ 'PASPORT',	'C',	15,		0 }, ;  // Паспорт плательщика
					{ 'I_POST',		'C',	30,		0 }, ;  // электронная почта 01.17
					{ 'PHONE',		'C',	11,		0 } ;	// телефон 
				}             
	cAlias := 'TContractPayerDB'
	aIndex := { ;
				{ dir_server + 'hum_plat', 'str( KOD, 7 )' } ;
			}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл описывающий плательщиков платных услуг' ) )
//---------

// файл содержащий услуги составляющие платный договор
	cClassName := Upper( 'TContractServiceDB' )
	cName := dir_server + 'hum_p_u' + sdbf
	aEtalonDB := { ;
				{ 'KOD',	'N',	7,	0 }, ; // код листа учета (по БД hum_p)
				{ 'DATE_U',	'C',	4,	0 }, ; // дата оказания услуги
				{ 'U_KOD',	'N',	4,	0 }, ; // код услуги
				{ 'U_CENA',	'N',	10,	2 }, ; // цена услуги
				{ 'U_KOEF',	'N',	5,	3 }, ; // коэф-т индексации услуги
				{ 'KOD_VR',	'N',	4,	0 }, ; // код врача
				{ 'KOD_AS',	'N',	4,	0 }, ; // код ассистента
				{ 'MED1',	'N',	4,	0 }, ; // код медсестры
				{ 'MED2',	'N',	4,	0 }, ; // код медсестры
				{ 'MED3',	'N',	4,	0 }, ; // код медсестры
				{ 'SAN1',	'N',	4,	0 }, ; // код санитарки
				{ 'SAN2',	'N',	4,	0 }, ; // код санитарки
				{ 'SAN3',	'N',	4,	0 }, ; // код санитарки
				{ 'KOL',	'N',	3,	0 }, ; // количество услуг
				{ 'STOIM',	'N',	10,	2 }, ; // итоговая стоимость услуги
				{ 'T_EDIT',	'N',	1,	0 }, ; // редактировалась ли сумма
				{ 'OTD',	'N',	3,	0 } ;  // код отделения
				}
	cAlias := 'TContractServiceDB'
	aIndex := { ;
				{ dir_server + 'hum_p_u', 'str( kod, 7 )' }, ;
				{ dir_server + 'hum_p_uk', 'str( u_kod, 4 )' }, ;
				{ dir_server + 'hum_p_ud', 'date_u' }, ;
				{ dir_server + 'hum_p_uv', 'str( kod_vr, 4 ) + date_u' }, ;
				{ dir_server + 'hum_p_ua', 'str( kod_as, 4 ) + date_u' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий услуги составляющие платный договор' ) )
//---------

// ДЛЯ ГОСПИТАЛИЗАЦИИ
//
// файл содержащий ссылки на файлы обмена
	cClassName := Upper( 'TExchangFile263' )
	cName := dir_server + 'mo_nfile' + sdbf
	aEtalonDB := { ;
				{ 'KOD',		'N', 6,0 }, ; // код файла
				{ 'DATE_F',		'D', 8,0 }, ; // дата файла
				{ 'NAME_F',		'C',26,0 }, ; // имя файла без расширения (и ZIP-архива)
				{ 'DATE_R',		'D', 8,0 }, ; // отчётная дата
				{ 'NN',			'N', 4,0 }, ; // порядковый номер пакета за отчётную дату
				{ 'TIP_F',		'N', 1,0 }, ; // от 1 до 7 (пакеты от I01 до I07)
				{ 'IN_OUT',		'N', 1,0 }, ; // 1-в ТФОМС,2-из ТФОМС
				{ 'DATE_OUT',	'D', 8,0 }, ; // дата отправки в ТФОМС
				{ 'KOL',		'N', 6,0 }, ; // количество пациентов в файле
				{ 'DWORK',		'D', 8,0 }, ; // дата обработки файла
				{ 'TWORK1',		'C', 5,0 }, ; // время начала обработки
				{ 'TWORK2',		'C', 5,0 }, ; // время окончания обработки
				{ 'TXT_F',		'C',15,0 }, ; // имя текстового файла протокола без расширения
				{ 'D_ANS',		'D', 8,0 }, ; // дата протокола ответа из ТФОМС
				{ 'T_ANS',		'N', 1,0 } ;  // тип ответа (0-не было, 1-всё хорошо, 2-ошибка)
				}
	cAlias := 'TExchangFile263'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий ссылки на файлы обмена' ) )
//---------

// файл содержащий список направлений
	cClassName := Upper( 'TNapravlenie263' )
	cName := dir_server + 'mo_nnapr' + sdbf
	aEtalonDB := { ;
				{ 'KOD',         'N', 6,0 }, ; // код направления - номер записи
				{ 'KOD_K',       'N', 7,0 }, ; // код по картотеке
				{ 'N_NAPR',      'N', 6,0 }, ; // уникальный номер направления (п-ка)
				{ 'NUM_D',       'C',15,0 }, ; // номер направления
				{ 'DATE_D',      'D', 8,0 }, ; // дата направления
				{ 'MCOD_1',      'C', 6,0 }, ; // код поликлиники
				{ 'CODEM_1',     'C', 6,0 }, ; // код поликлиники
				{ 'DS_1',        'C', 6,0 }, ; // диагноз поликлиники
				{ 'USL_OK_1',    'N', 1,0 }, ; // условия оказания мед.помощи 1-стационар,2-дневной стационар
				{ 'F_MEDC_1',    'N', 1,0 }, ; // форма оказания мед.помощи по V014 (для п-ки 2-неотложная и 3-плановая)
				{ 'ID_1',        'C',36,0 }, ; // GUID+lstr(mo_nnapr->KOD) ID направления
				{ 'DATE_H_1',    'D', 8,0 }, ; // планируемая дата госпитализации
				{ 'DISP_1',      'N', 1,0 }, ; // Направление выдано по результатам диспансеризации/профосмотра взрослого населения
				{ 'OTD_1',       'N', 3,0 }, ; // отделение, где выписано направление
				{ 'PROFIL_1',    'N', 3,0 }, ; // профиль мед.помощи по справочнику V002
				{ 'PROFIL_K_1',  'N', 3,0 }, ; // профиль койки по справочнику T007
				{ 'VRACH_1',     'N', 4,0 }, ; // лечащий врач по mo_pers
				{ 'KOD_F_1OUT',  'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'KOD_F_1IN',   'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'T_ANS_1',     'N', 1,0 }, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
				{ 'S_MCOD',      'C', 6,0 }, ; // код стационара
				{ 'S_CODEM',     'C', 6,0 }, ; //_код стационара
				{ 'OTD_2',       'N', 3,0 }, ; // отделение, куда положат
				{ 'DATE_2',      'D', 8,0 }, ; // дата ввода даты госпитализации
				{ 'DATE_H_2',    'D', 8,0 }, ; // дата госпитализации, переданная из стационара
				{ 'KOD_F_2OUT',  'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'KOD_F_2IN',   'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'T_ANS_2',     'N', 1,0 }, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
				{ 'INF_PAC',     'N', 1,0 }, ; //_кто информирует пациента 1-СМО, 2-поликлиника
				{ 'TIP_ANNUL',   'N', 1,0 }, ; // кто аннулировал (1-СМО,2-стац,3-пол)
				{ 'REA_ANNUL',   'N', 2,0 }, ; // причина аннулирования (от 1 до 9)
				{ 'DATE_3',      'D', 8,0 }, ; // дата аннулирования
				{ 'T_ANS_3',     'N', 1,0 }, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
				{ 'KOD_F_3OUT',  'N', 6,0 }, ; //_код файла - по файлу mo_nfile
				{ 'KOD_F_3IN',   'N', 6,0 }, ; //_код файла - по файлу mo_nfile
				{ 'CODEM_FROM',  'C', 6,0 }, ; // из какого МО направлен (п-ка, другой стационар или наш же стационар)
				{ 'KOD_UP',      'N', 6,0 }, ; // код пред.направления (после перевода в др.отд-ие)
				{ 'KOD_PP',      'N', 7,0 }, ; // код по БД приёмного покоя
				{ 'TYPE_H_4',    'N', 1,0 }, ; // госп-ия: 1-по направлению, 2-перевод из другого МО, 3-перевод внутри нашего МО, 4-экстр./неотл. (I05)
				{ 'DATE_H_4',    'D', 8,0 }, ; // реальная дата госпитализации
				{ 'TIME_H_4',    'C', 5,0 }, ; // время госпитализации
				{ 'DNEJ_H_4',    'N', 3,0 }, ; // планируемое количество дней госпитализации (по умолчанию 7)
				{ 'ID_4',        'C',36,0 }, ; // GUID+lstr(mo_nnapr->KOD) ID госпитализации для tip_f=4
				{ 'OTD_4',       'N', 3,0 }, ; // отделение, куда положили
				{ 'PROFIL_4',    'N', 3,0 }, ; // профиль мед.помощи по справочнику V002
				{ 'PROFIL_K_4',  'N', 3,0 }, ; // профиль койки по справочнику T007
				{ 'DS_4',        'C', 6,0 }, ; // диагноз приёмного отделения стационара
				{ 'USL_OK_4',    'N', 1,0 }, ; // условия оказания мед.помощи 1-стационар,2-дневной стационар
				{ 'F_MEDC_4',    'N', 1,0 }, ; // форма оказания мед.помощи по V014 (1-экстренная, 2-неотложная, 3-плановая)
				{ 'NUM_HIST_4',  'C',50,0 }, ; // номер истории болезни
				{ 'T_ANS_4',     'N', 1,0 }, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
				{ 'KOD_F_4OUT',  'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'KOD_F_4IN',   'N', 6,0 }, ; //_код файла - по файлу mo_nfile
				{ 'TYPE_6',      'N', 1,0 }, ; // выбытие: 1-выписан, 2-умер, 3-перевод внутри нашего МО
				{ 'KOD_NEXT',    'N', 6,0 }, ; // код следующей госпитализации (после перевода в др.отд-ие)
				{ 'ID_6',        'C',36,0 }, ; // GUID+lstr(mo_nnapr->KOD) ID выписки для tip_f=6
				{ 'DATE_6',      'D', 8,0 }, ; // дата выбытия
				{ 'T_ANS_6',     'N', 1,0 }, ; // 1-нормально, 2-обнаружена ошибка при ответе из ТФОМС
				{ 'KOD_F_6OUT',  'N', 6,0 }, ; //_код файла - по файлу mo_nfile
				{ 'KOD_F_6IN',   'N', 6,0 }, ; //_код файла - по файлу mo_nfile
				{ 'DATE_R',      'D', 8,0 }, ; // дата рождения
				{ 'SEX',         'N', 1,0 }, ; // пол
				{ 'ENP',         'C',16,0 } ;  // единый номер полиса ОМС
				}
	cAlias := 'TNapravlenie263'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий список направлений' ) )
//---------

// файл содержащий ссылки на файлы обмена+направления
	cClassName := Upper( 'TExchangFileNapravlenie263' )
	cName := dir_server + 'mo_nfina' + sdbf
	aEtalonDB := { ;
				{ 'KOD_F',	'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'KOD_N',	'N', 6,0 }, ; // код направления - по файлу mo_nnapr
				{ 'OSHIB',	'N', 3,0 }, ; // код ошибки
				{ 'IM_POL',	'C',20,0 } ;  // имя поля, в котором произошла ошибка
				}
	cAlias := 'TExchangFileNapravlenie263'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий ссылки на файлы обмена+направления' ) )
//---------

// файл содержащий ссылки на файлы обмена+направления
	cClassName := Upper( 'TNapr263' )
	cName := dir_server + 'mo_n7in' + sdbf
	aEtalonDB := { ;
				{ 'KOD_F',       'N', 6,0 }, ; // код файла - по файлу mo_nfile
				{ 'CODEM',       'C', 6,0 }, ; // код стационара
				{ 'ID_PL',       'C',36,0 }, ; // GUID записи
				{ 'USL_OK',      'N', 1,0 }, ; // условия оказания мед.помощи 1-стационар,2-дневной стационар
				{ 'PROFIL_K',    'N', 3,0 }, ; // профиль койки
				{ 'PROFIL',      'N', 3,0 }, ; // профиль мед.помощи
				{ 'KOL_KD',      'N', 3,0 }, ; // кол-во дней по-умолчанию по данному профилю койки
				{ 'QUANTITY',    'N', 3,0 }, ; // количество коек
				{ 'Q_P',         'N', 3,0 }, ; // состояло пациентов на начало пред.суток
				{ 'Q_AP',        'N', 3,0 }, ; // поступило пациентов за пред.сутки
				{ 'Q_DP',        'N', 3,0 }, ; // выбыло пациентов за пред.сутки
				{ 'Q_HP',        'N', 3,0 }, ; // запланировано госпитализаций на тек.день
				{ 'PLACE_FREE',  'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M',        'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W',        'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C',        'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE1',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M1',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W1',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C1',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE2',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M2',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W2',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C2',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE3',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M3',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W3',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C3',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE4',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M4',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W4',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C4',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE5',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M5',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W5',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C5',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE6',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M6',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W6',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C6',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE7',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M7',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W7',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C7',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE8',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M8',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W8',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C8',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE9',      'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M9',       'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W9',       'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C9',       'N', 3,0 }, ; // --""-- для детей
				{ 'PLACE10',     'N', 3,0 }, ; // количество свободных мест
				{ 'PF_M10',      'N', 3,0 }, ; // --""-- для мужчин
				{ 'PF_W10',      'N', 3,0 }, ; // --""-- для женщин
				{ 'PF_C10',      'N', 3,0 }, ; // --""-- для детей
				{ 'V_H34001',    'N',15,0 }, ; // количество госпитализаций СНГ
				{ 'V_H34002',    'N',15,0 }, ; // количество госпитализаций СНГ
				{ 'V_H34006',    'N',15,0 }, ; // количество госпитализаций СНГ
				{ 'V_H34007',    'N',15,0 } ; // количество госпитализаций СНГ
				}
	cAlias := 'TNapr263'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий' ) )
	
	// у следующего файла структура идентична
	cClassName := Upper( 'TNaprOut263' )
	cName := dir_server + 'mo_n7out' + sdbf
	cAlias := 'TNaprOut263'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'файл содержащий' ) )
	
//---------

// одна запись
	cClassName := Upper( 'TExchangOneRecord263' )
	cName := dir_server + 'mo_n7d' + sdbf
	aEtalonDB := { ;
				{ 'DATE_R_EDI',	'D', 8,0 }, ; // отчётная дата (за какое утро вводим)
				{ 'DATE_R_OUT',	'D', 8,0 }, ; // отчётная дата (за какое утро уже отправили)
				{ 'DATE_OUT',	'D', 8,0 }, ; // дата последней отправки
				{ 'DATE_E',		'D', 8,0 }, ; // дата редактирования
				{ 'TIME_E',		'C', 5,0 }, ; // время редактирования
				{ 'END_EDIT',	'N', 1,0 }, ; // 0-не закончено, 1-закончено редактирование
				{ 'KOD_OPER',	'N', 3,0 } ;  // код оператора
				}
	cAlias := 'TExchangOneRecord263'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'одна запись' ) )
//---------
// для госпитализации
/////////////////

	// cClassName := Upper( 'TServiceUSL' )
	// cName := dir_server + 'uch_usl' + sdbf
	// aEtalonDB :=	{ ;
				// { 'KOD',		'N',	4,	0 }, ;	// код услуги
				// { 'VKOEF_V',	'N',	7,	4 }, ;	// врач - УЕТ для взрослого
				// { 'AKOEF_V',	'N',	7,	4 }, ;  // асс. - УЕТ для взрослого
				// { 'VKOEF_R',	'N',	7,	4 }, ;  // врач - УЕТ для ребенка
				// { 'AKOEF_R',	'N',	7,	4 }, ;  // асс. - УЕТ для ребенка
				// { 'KOEF_V',		'N',	7,	4 }, ;  // итого УЕТ для взрослого
				// { 'KOEF_R',		'N',	7,	4 } ;   // итого УЕТ для ребенка
				// }             
	// cAlias := 'TServiceUSL'
	// aIndex :=	{ ;
				// { dir_server + 'uch_usl', 'str( KOD, 4 )' } ;
				// }
	// hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл для услуг' ) )
//---------

	// cClassName := Upper( 'TServiceUSL1' )
	// cName := dir_server + 'uch_usl' + sdbf
	// aEtalonDB :=	{ ;
				// { 'KOD',		'N',	4,	0 }, ;	// код услуги
				// { 'VKOEF_V',	'N',	7,	4 }, ;	// врач - УЕТ для взрослого
				// { 'AKOEF_V',	'N',	7,	4 }, ;  // асс. - УЕТ для взрослого
				// { 'VKOEF_R',	'N',	7,	4 }, ;  // врач - УЕТ для ребенка
				// { 'AKOEF_R',	'N',	7,	4 }, ;  // асс. - УЕТ для ребенка
				// { 'KOEF_V',		'N',	7,	4 }, ;  // итого УЕТ для взрослого
				// { 'KOEF_R',		'N',	7,	4 }, ;   // итого УЕТ для ребенка
				// { 'DATE_B',		'D',	8,	0 } ;    // дата начала действия
				// }             
	// cAlias := 'TServiceUSL1'
	// aIndex :=	{ ;
				// { dir_server + 'uch_usl1', 'str( KOD, 4 ) + dtos( DATE_B )' } ;
				// }
	// hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'Файл для услуг' ) )
//---------

// справочник группы услуг для способа оплаты = 7
	// cClassName := Upper( 'TUSL_U7' )
	// cName := dir_server + 'u_usl_7' + sdbf
	// aEtalonDB := 	{ ;
					// { 'NAME',      'C',  20, 0 }, ;
					// { 'VARIANT',   'N',   1, 0 }, ;
					// { 'V_UET_OMS', 'N',   6, 2 }, ;
					// { 'A_UET_OMS', 'N',   6, 2 }, ;
					// { 'V_UET_PL',  'N',   6, 2 }, ;
					// { 'A_UET_PL',  'N',   6, 2 }, ;
					// { 'V_UET_DMS', 'N',   6, 2 }, ;
					// { 'A_UET_DMS', 'N',   6, 2 }, ;
					// { 'USL_INS',   'C', 110, 0 }, ;
					// { 'USL_DEL',   'C', 110, 0 } ;
					// }
	// cAlias := 'TUSL_U7'
	// aIndex := { }
	// hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'группы услуг для способа оплаты = 7' ) )
//---------

//
// ФАЙЛЫ НАХОДЯЩИЕСЯ В КАТАЛОГЕ ЗАДАЧИ
//

// справочник _mo_form
	cClassName := Upper( 'T_MO_FORM' )
	cName := exe_dir + '_mo_form' + sdbf
	aEtalonDB := 	{ ;
					{ 'FORMA',		'N',	2, 0 }, ;
					{ 'TABLE',		'N',	4, 0 }, ;
					{ 'BOLD',		'N',	1, 0 }, ;
					{ 'NAME',		'C',  250, 0 }, ;
					{ 'STROKE',		'C',   10, 0 }, ;
					{ 'DIAGNOZ',	'C',   40, 0 } ;
					}
	cAlias := '_MO_FORM'
	aIndex := { ;
		;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник mo_form' ) )
//---------

// справочник _mo_kek
	cClassName := Upper( 'T_MO_KEK' )
	cName := exe_dir + '_mo_kek' + sdbf
	aEtalonDB := 	{ ;
					{ 'SHIFR',		'C',	8, 0 }, ;
					{ 'NN',			'N',	3, 0 }, ;
					{ 'NAME',		'C',  118, 0 } ;
					}
	cAlias := '_MO_KEK'
	aIndex := { ;
		;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник mo_kek' ) )
//---------

// справочник _mo_kekd
	cClassName := Upper( 'T_MO_KEKD' )
	cName := exe_dir + '_mo_kekd' + sdbf
	aEtalonDB := 	{ ;
					{ 'SHIFR',		'C',	8, 0 }, ;
					{ 'VZR',		'N',	1, 0 }, ;
					{ 'REB',		'N',	1, 0 }, ;
					{ 'NAME',		'C',  150, 0 } ;
					}
	cAlias := '_MO_KEKD'
	aIndex := { ;
		;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник mo_kekd' ) )
//---------

// справочник подразделений из паспорта ЛПУ
	cClassName := Upper( 'T_Mo_PodrDB' )
	cName := exe_dir + '_mo_podr' + sdbf
	aEtalonDB := 	{ ;
					{ 'CODEMO',		'C',	6, 0 }, ;
					{ 'OGRN',		'C',   13, 0 }, ;
					{ 'OIDMO',		'C',   27, 0 }, ;
					{ 'KODOTD',		'C',   25, 0 }, ;
					{ 'NAMEOTD',	'C',   76, 0 }, ;
					}
	cAlias := '_MO_PODRDB'
	aIndex := { ;
		{ cur_dir + '_mo_podr', 'codemo + padr( upper( kodotd ), 25 )' } ;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник подразделений из паспорта ЛПУ' ) )
//---------

// справочник _mo_smo
	cClassName := Upper( 'T_MO_SMODB' )
	cName := exe_dir + '_mo_smo' + sdbf
	aEtalonDB := 	{ ;
					{ 'OKATO',		'C',	5, 0 }, ;
					{ 'SMO',		'C',	5, 0 }, ;
					{ 'NAME',		'C',   70, 0 }, ;
					{ 'OGRN',		'C',   15, 0 }, ;
					{ 'D_BEGIN',	'D',	8, 0 }, ;
					{ 'D_END',		'D',	8, 0 } ;
					}
	cAlias := '_MO_SMO'
	aIndex := { ;
		{ cur_dir + '_mo_smo', 'okato + smo' }, ;
		{ cur_dir + '_mo_smo2', 'smo' }, ;
		{ cur_dir + '_mo_smo3', 'okato + ogrn' } ;
	}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник _mo_smo' ) )
//---------

// справочник _okatoo
	cClassName := Upper( 'T_OKATOODB' )
	cName := exe_dir + '_okatoo' + sdbf
	aEtalonDB := 	{ ;
					{ 'OKATO',		'C',	5,	0 }, ;
					{ 'NAME',		'C',   72,	0 }, ;
					{ 'FL_VIBOR',	'N',	1,	0 }, ;
					{ 'FL_ZAGOL',	'N',	1,	0 }, ;
					{ 'TIP',		'N',	1,	0 }, ;
					{ 'SELO',		'N',	1,	0 } ;
					}
	cAlias := 'OBLAST'
	aIndex := { ;
				{ cur_dir + '_okato', 'okato' }, ;
				{ cur_dir + '_okaton', 'substr( okato, 1, 5 ) + upper( substr( name, 1, 30 ) )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник ОКАТО областей' ) )
//---------

// справочник _okatoo8
	cClassName := Upper( 'T_OKATOO8DB' )
	cName := exe_dir + '_okatoo8' + sdbf
	aEtalonDB := 	{ ;
					{ 'OKATO',		'C',	5,	0 }, ;
					{ 'NAME',		'C',   72,	0 }, ;
					{ 'FL_VIBOR',	'N',	1,	0 }, ;
					{ 'FL_ZAGOL',	'N',	1,	0 }, ;
					{ 'TIP',		'N',	1,	0 }, ;
					{ 'SELO',		'N',	1,	0 } ;
					}
	cAlias := '_OKATOO8'
	aIndex := { ;
				{ cur_dir + '_okato8', 'okato' }, ;
				{ cur_dir + '_okaton8', 'substr( okato, 1, 5 ) + upper( substr( name, 1, 30 ) )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник _okatoo8' ) )
//---------

// справочник _okator
	cClassName := Upper( 'T_OKATORDB' )
	cName := exe_dir + '_okator' + sdbf
	aEtalonDB := 	{ ;
					{ 'OKATO',		'C',	2,	0 }, ;
					{ 'NAME',		'C',   72,	0 } ;
					}
	cAlias := 'REGION'
	aIndex := { ;
				{ cur_dir + '_okatr', 'okato' }, ;
				{ cur_dir + '_okatrn', 'okato + upper( substr( name, 1, 30 ) )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник ОКАТО регионов' ) )
//---------

// справочник _okatos
	cClassName := Upper( 'T_OKATOSDB' )
	cName := exe_dir + '_okatos' + sdbf
	aEtalonDB := 	{ ;
					{ 'OKATO',		'C',   11,	0 }, ;
					{ 'NAME',		'C',   72,	0 }, ;
					{ 'FL_VIBOR',	'N',	1,	0 }, ;
					{ 'FL_ZAGOL',	'N',	1,	0 }, ;
					{ 'TIP',		'N',	1,	0 }, ;
					{ 'SELO',		'N',	1,	0 } ;
					}
	cAlias := '_OKATOS'
	aIndex := { ;
				{ cur_dir + '_okats', 'okato' }, ;
				{ cur_dir + '_okatsn', 'substr( okato, 1, 8 ) + upper( substr( name, 1, 30 ) )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник ОКАТО село' ) )
//---------

// справочник _okatos8
	cClassName := Upper( 'T_OKATOS8DB' )
	cName := exe_dir + '_okatos8' + sdbf
	aEtalonDB := 	{ ;
					{ 'OKATO',		'C',   11,	0 }, ;
					{ 'NAME',		'C',   72,	0 }, ;
					{ 'FL_VIBOR',	'N',	1,	0 }, ;
					{ 'FL_ZAGOL',	'N',	1,	0 }, ;
					{ 'TIP',		'N',	1,	0 }, ;
					{ 'SELO',		'N',	1,	0 } ;
					}
	cAlias := '_OKATOS8'
	aIndex := { ;
				{ cur_dir + '_okats8', 'okato' }, ;
				{ cur_dir + '_okatsn8', 'substr( okato, 1, 8 ) + upper( substr( name, 1, 30 ) )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник _okatos8' ) )
//---------

// справочник двойных фамилий
	cClassName := Upper( 'TDubleFIODB' )
	cName := dir_server + 'mo_kfio' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD',	'N',	7,	0 }, ; // код человека по kartotek.dbf
					{ 'FAM',	'C',	40,	0 }, ;
					{ 'IM',		'C',	40,	0 }, ;
					{ 'OT',		'C',	40,	0 } ;
					}
	cAlias := 'TDubleFIODB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник _okatos8' ) )
//---------

// справочник human
	cClassName := Upper( 'THumanDB' )
	cName := dir_server + 'human' + sdbf
	aEtalonDB := 	{ ;
					{ 'KOD'      ,   'N',     7,     0 }, ; // код (номер записи)
					{ 'KOD_K'    ,   'N',     7,     0 }, ; // код по картотеке
					{ 'TIP_H'    ,   'N',     1,     0 }, ; // 1-лечится,2-лечение не завершено,3-лечение не завершено,4-выписан счет,5-оплачен полностью,6-больной не оплачивается
					{ 'FIO'      ,   'C',    50,     0 }, ; // Ф.И.О. больного
					{ 'POL'      ,   'C',     1,     0 }, ; // пол
					{ 'DATE_R'   ,   'D',     8,     0 }, ; // дата рождения больного
					{ 'VZROS_REB',   'N',     1,     0 }, ; // 0-взрослый, 1-ребенок, 2-подросток
					{ 'ADRES'    ,   'C',    50,     0 }, ; // адрес больного
					{ 'MR_DOL'   ,   'C',    50,     0 }, ; // место работы или причина безработности
					{ 'RAB_NERAB',   'N',     1,     0 }, ; // 0-работающий, 1-неработающий
					{ 'KOD_DIAG' ,   'C',     5,     0 }, ; // шифр 1-ой осн.болезни
					{ 'KOD_DIAG2',   'C',     5,     0 }, ; // шифр 2-ой осн.болезни
					{ 'KOD_DIAG3',   'C',     5,     0 }, ; // шифр 3-ой осн.болезни
					{ 'KOD_DIAG4',   'C',     5,     0 }, ; // шифр 4-ой осн.болезни
					{ 'SOPUT_B1' ,   'C',     5,     0 }, ; // шифр 1-ой сопутствующей болезни
					{ 'SOPUT_B2' ,   'C',     5,     0 }, ; // шифр 2-ой сопутствующей болезни
					{ 'SOPUT_B3' ,   'C',     5,     0 }, ; // шифр 3-ой сопутствующей болезни
					{ 'SOPUT_B4' ,   'C',     5,     0 }, ; // шифр 4-ой сопутствующей болезни
					{ 'DIAG_PLUS',   'C',     8,     0 }, ; // дополнение к диагнозам (+,-)
					{ 'OBRASHEN' ,   'C',     1,     0 }, ; // пробел-ничего, '1'-подозрение на ЗНО, '2'-онкология???
					{ 'KOMU'     ,   'N',     1,     0 }, ; // от 1 до 5
					{ 'STR_CRB'  ,   'N',     2,     0 }, ; // код стр.компании, комитета и т.п.
					{ 'ZA_SMO'   ,   'N',     2,     0 }, ; // ЗаСМО
					{ 'POLIS'    ,   'C',    17,     0 }, ; // серия и номер страхового полиса
					{ 'LPU'      ,   'N',     3,     0 }, ; // код учреждения
					{ 'OTD'      ,   'N',     3,     0 }, ; // код отделения
					{ 'UCH_DOC'  ,   'C',    10,     0 }, ; // вид и номер учетного документа
					{ 'MI_GIT'   ,   'N',     1,     0 }, ; // 0-город, 1-область, 2-иногородний
					{ 'RAJON_GIT',   'N',     2,     0 }, ; // код района места жительства
					{ 'MEST_INOG',   'N',     1,     0 }, ; // 0-город, 1-область, 2-иногородний
					{ 'RAJON'    ,   'N',     2,     0 }, ; // код района финансирования
					{ 'REG_LECH' ,   'N',     1,     0 }, ; // 0-основные, 9-дополнительные объёмы
					{ 'N_DATA'   ,   'D',     8,     0 }, ; // дата начала лечения
					{ 'K_DATA'   ,   'D',     8,     0 }, ; // дата окончания лечения
					{ 'CENA'     ,   'N',    10,     2 }, ; // стоимость лечения
					{ 'CENA_1'   ,   'N',    10,     2 }, ; // оплачиваемая сумма лечения
					{ 'BOLNICH'  ,   'N',     1,     0 }, ; // больничный
					{ 'DATE_B_1' ,   'C',     4,     0 }, ; // дата начала больничного
					{ 'DATE_B_2' ,   'C',     4,     0 }, ; // дата окончания больничного
					{ 'DATE_E'   ,   'C',     4,     0 }, ; // дата добавления листа учета
					{ 'KOD_P'    ,   'C',     1,     0 }, ; // код пользователя, добавившего л/у
					{ 'DATE_OPL' ,   'C',     4,     0 }, ; // дата след.визита для дисп.наблюдения 
					{ 'SCHET'    ,   'N',     6,     0 }, ; // код счета
					{ 'ISHOD'    ,   'N',     3,     0 } ;
					}
	cAlias := 'THUMANDB'
	aIndex := { ;
				{ dir_server + 'humank', 'str( kod, 7 )' }, ;
				{ dir_server + 'humankk', 'str( if( kod > 0, kod_k, 0 ), 7 ) + str( tip_h, 1 )' }, ;
				{ dir_server + 'humann', 'str( tip_h, 1 ) + str( otd, 3 ) + upper( substr( fio, 1, 20 ) )' }, ;
				{ dir_server + 'humand', 'dtos( k_data ) + uch_doc' }, ;
				{ dir_server + 'humano', 'date_opl' }, ;
				{ dir_server + 'humans', 'str( schet, 6 ) + str( tip_h, 1 ) + upper( substr( fio, 1, 20 ) )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник human' ) )

// справочник human_
	cClassName := Upper( 'THumanExtDB' )
	cName := dir_server + 'human_' + sdbf
	aEtalonDB := 	{ ;
				{ 'DISPANS',	'C',	16,	0 }, ; // то, что вводится по <F10>
				{ 'STATUS_ST',	'C',	10,	0 }, ; // статус стоматологического пациента;проверка по собственному справочнику МО для стоматологии
				{ 'POVOD',		'N',	 2,	0 }, ; // повод обращения
				{ 'TRAVMA',		'N',	 2,	0 }, ; // вид травмы
				{ 'ID_PAC',		'C',	36,	0 }, ; // код записи о пациенте;GUID пациента в листе учета;создается при добавлении записи
				{ 'ID_C',		'C',	36,	0 }, ; // код случая оказания;GUID листа учета;создается при добавлении записи
				{ 'VPOLIS',		'N',	 1,	0 }, ; // вид полиса (от 1 до 3);1-старый,2-врем.,3-новый;по умолчанию 1 - старый
				{ 'SPOLIS',		'C',	10,	0 }, ; // серия полиса
				{ 'NPOLIS',		'C',	20,	0 }, ; // номер полиса
				{ 'SMO',		'C',	 5,	0 }, ; // реестровый номер СМО возвращается с реестром из ТФОМС, иногродние = 34
				{ 'OKATO',		'C',	 5,	0 }, ; // ОКАТО территории страхования возвращается с реестром из ТФОМС для иногородних
				{ 'NOVOR',		'N',	 2,	0 }, ; // признак новорожденного 0-нет, 1,2,... - порядковый номер новорожденного ребенка
				{ 'DATE_R2',	'D',	 8,	0 }, ; // дата рождения ребенка для NOVOR > 0;
				{ 'POL2',		'C',	 1,	0 }, ; // пол ребенка для NOVOR > 0;
				{ 'USL_OK',		'N',	 2,	0 }, ; // условия оказания медицинской помощи по справочнику V006
				{ 'VIDPOM',		'N',	 4,	0 }, ; // вид помощи по справочнику V008
				{ 'PROFIL',		'N',	 3,	0 }, ; // профиль по справочнику V002
				{ 'IDSP',		'N',	 2,	0 }, ; // код способа оплаты мед.помощи по справочнику V010
				{ 'NPR_MO',		'C',	 6,	0 }, ; // код МО, направившего на лечение по справочнику T001
				{ 'FORMA14',	'C',	 6,	0 }, ; // для стат.формы 14 в первых 4 байтах: планово/экстренно, доставлен скорой помощью, проведено вскрытие, установлено расхождение
				{ 'KOD_DIAG0',	'C',	 6,	0 }, ; // диагноз первичный
				{ 'RSLT_NEW',	'N',	 3,	0 }, ; // результат обращения/госпитализации по справочнику V009
				{ 'ISHOD_NEW',	'N',	 3,	0 }, ; // исход заболевания по справочнику V012
				{ 'VRACH',		'N',	 4,	0 }, ; // лечащий врач (врач, закрывший талон)
				{ 'PRVS',		'N',	 9,	0 }, ; // Специальность врача по справочнику V004, с минусом - по справочнику V015
				{ 'RODIT_DR',	'D',	 8,	0 }, ; // дата рождения родителя (для human->bolnich=2)
				{ 'RODIT_POL',	'C',	 1,	0 }, ; // пол родителя (для human->bolnich=2)
				{ 'DATE_E2',	'C',	 4,	0 }, ; // дата редактирования листа учета
				{ 'KOD_P2',		'C',	 1,	0 }, ; // код пользователя, исправившего л/у
				{ 'PZTIP',		'N',	 2,	0 }, ; // тип план-заказа от 1 до 99
				{ 'PZKOL',		'N',	 6,	2 }, ; // кол-во выполненного план-заказа
				{ 'ST_VERIFY',	'N',	 1,	0 }, ; // стадия проверки: 0-после редактирования; от 5 до 9-проверено
				{ 'KOD_UP',		'N',	 7,	0 }, ; // номер предыдущей записи (в случае повторного выставления в другом счёте)
				{ 'OPLATA',		'N',	 1,	0 }, ; // тип оплаты;0,1 или 2, 1 - в счет, 2 - ред-ие; 9-счёт не оплачен и сделана копия л/у
				{ 'SUMP',		'N',	10,	2 }, ; // сумма, принятая к оплате СМО (ТФОМС);всего;
				{ 'SANK_MEK',	'N',	10,	2 }, ; // финансовые санкции (МЭК);суммарные;
				{ 'SANK_MEE',	'N',	10,	2 }, ; // финансовые санкции (МЭЭ);суммарные;
				{ 'SANK_EKMP',	'N',	10,	2 }, ; // финансовые санкции (ЭКМП);суммарные;
				{ 'REESTR',		'N',	 6,	0 }, ; // код (последнего) реестра;по файлу "mo_rees"
				{ 'REES_NUM',	'N',	 2,	0 }, ; // номер отправки реестра в ТФОМСа;в реестре первый раз отправили = 1, после исправления отправили второй раз = 2, и т.д.;
				{ 'REES_ZAP',	'N',	 6,	0 }, ; // номер позиции записи в реестре;поле "IDCASE" (и "ZAP") в реестре случаев
				{ 'SCHET_NUM',	'N',	 2,	0 }, ; // номер отправки счёта в ТФОМС;в счёте первый раз отправили = 0, после отказа в оплате и исправления отправили второй раз = 1, и т.д.;
				{ 'SCHET_ZAP',	'N',	 6,	0 } ;  // номер позиции записи в счете;поле "IDCASE" (и "ZAP") в реестре счетов;сформировать по индексу humans для schet > 0
				}
	cAlias := 'THumanExtDB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник human' ) )

// справочник human_2
	cClassName := Upper( 'THumanAddDB' )
	cName := dir_server + 'human_2' + sdbf
	aEtalonDB := 	{ ;
				{ 'OSL1',		'C',	 6,	0 }, ; // шифр 1-ого диагноза осложнения заболевания
				{ 'OSL2',		'C',	 6,	0 }, ; // шифр 2-ого диагноза осложнения заболевания
				{ 'OSL3',		'C',	 6,	0 }, ; // шифр 3-ого диагноза осложнения заболевания
				{ 'NPR_DATE',	'D',	 8,	0 }, ; // Дата направления, выданного МО, указанной в NPR_MO
				{ 'PROFIL_K',	'N',	 3,	0 }, ; // профиль койки по справочнику V020 (стационар и дневной стационар)
				{ 'VMP',		'N',	 1,	0 }, ; // 0-нет,1-да ВМП
				{ 'VIDVMP',		'C',	12,	0 }, ; // вид ВМП по справочнику V018
				{ 'METVMP',		'N',	 4,	0 }, ; // метод ВМП по справочнику V019
				{ 'TAL_NUM',	'C',	20,	0 }, ; // Номер талона на ВМП
				{ 'TAL_D',		'D',	 8,	0 }, ; // Дата выдачи талона на ВМП
				{ 'TAL_P',		'D',	 8,	0 }, ; // Дата планируемой госпитализации в соответствии с талоном на ВМП
				{ 'P_PER',		'N',	 1,	0 }, ; // Признак поступления/перевода 1-4
				{ 'VNR',		'N',	 4,	0 }, ; // вес недоношенного ребёнка (лечится ребёнок)
				{ 'VNR1',		'N',	 4,	0 }, ; // вес 1-го недоношенного ребёнка (лечится мать)
				{ 'VNR2',		'N',	 4,	0 }, ; // вес 2-го недоношенного ребёнка (лечится мать)
				{ 'VNR3',		'N',	 4,	0 }, ; // вес 3-го недоношенного ребёнка (лечится мать)
				{ 'PC1',		'C',	20,	0 }, ; // КСЛП (в 2017 - в первом знаке 1-3 - кол-во стентов в коронарных сосудах)
				{ 'PC2',		'C',	10,	0 }, ; // КИРО
				{ 'PC3',		'C',	10,	0 }, ; // дополнительный критерий
				{ 'PC4',		'C',	10,	0 }, ;
				{ 'PC5',		'C',	10,	0 }, ; // для мед. реабилитации строка вида 'vid_reab,vid_srm'
				{ 'PC6',		'C',	10,	0 }, ; //
				{ 'PN1',		'N',	10,	0 }, ; // для реабилитации пациентов после кохлеарной имплантации
				{ 'PN2',		'N',	10,	0 }, ; // для абортов
				{ 'PN3',		'N',	10,	0 }, ; // код согласования с программами SDS/ЛИС
				{ 'PN4',		'N',	10,	0 }, ; // двойные л/у (1-ый л/у - ссылка на 2-ой лист, (2-ой л/у - ссылка на 1-ый лист)
				{ 'PN5',		'N',	10,	0 }, ; // 
				{ 'PN6',		'N',	10,	0 };  // 
				}
	cAlias := 'THumanAddDB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'справочник human' ) )

// информация по инвалидам
	cClassName := Upper( 'TDisabilityDB' )
	cName := dir_server + 'kart_inv' + sdbf
	aEtalonDB := { ;
				{ 'KOD',		'N',	7,	0}, ; // код (номер записи по БД kartotek)
				{ 'DATE_INV',	'D',	8,	0}, ; // дата первичного установления инвалидности
				{ 'PRICH_INV',	'N',	2,	0}, ; // причина первичного установления инвалидности
				{ 'DIAG_INV',	'C',	5,	0} ;  // 
				}
	cAlias := 'TDisabilityDB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile( ):New( cName, aIndex, cAlias, aEtalonDB, 'информация по инвалидам' ) )
//---------

// 
	cClassName := Upper( 'Tk_prim1DB' )
	cName := dir_server + 'k_prim1' + sdbf
	aEtalonDB := { ;
				{ 'KOD',	'N',	7,	0 }, ;
				{ 'STROKE',	'N',	1,	0 }, ;
				{ 'NAME',	'C',	60,	0 } ;
				}
	cAlias := 'Tk_prim1DB'
	aIndex := { ;
				{ dir_server + 'k_prim1', 'str( kod, 7 ) + str( stroke, 1 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile():New( cName, aIndex, cAlias, aEtalonDB, '' ) )
//---------

// иногородние страховые компании
	cClassName := Upper( 'TMo_kismoDB' )
	cName := dir_server + 'mo_kismo' + sdbf
	aEtalonDB := { ;
				{ 'KOD',	'N',	7,	0 }, ;	// ID пациента
				{ 'SMO_NAME','C',  100,	0 } ;	// наименование иногородней СМО
				}
	cAlias := 'TMOKISMODB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile():New( cName, aIndex, cAlias, aEtalonDB, 'иногородние страховые компании' ) )
//---------

// иногородние страховые компании
	cClassName := Upper( 'TMo_hismoDB' )
	cName := dir_server + 'mo_hismo' + sdbf
	aEtalonDB := { ;
				{ 'KOD',	'N',	7,	0 }, ;	// ID пациента
				{ 'SMO_NAME','C',  100,	0 } ;	// наименование иногородней СМО
				}
	cAlias := 'TMOHISMODB'
	aIndex := { ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile():New( cName, aIndex, cAlias, aEtalonDB, 'иногородние страховые компании' ) )
//---------

// сведения об иностранных гражданах
	cClassName := Upper( 'TForeignCitizenDB' )
	cName := dir_server + 'mo_kinos' + sdbf
	aEtalonDB := { ;
				{ 'KOD',		'N',	7,	0 }, ; // ID пациента
				{ 'OSN_PREB',	'N',	2,	0 }, ; // основание пребывания в РФ
				{ 'ADRES_PRO',	'C',	60,	0 }, ; // адрес проживания в Волг.обл.
				{ 'MIGR_KARTA',	'C',	20,	0 }, ; // данные миграционной карты
				{ 'DATE_P_G',	'D',	8,	0 }, ; // дата пересечения границы
				{ 'DATE_R_M',	'D',	8,	0 } ;  // дата регистрации в миграционной службе
				}
	cAlias := 'TForeignCitizenDB'
	aIndex := { ;
				{ dir_server + 'mo_kinos', 'str( kod, 7 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile():New( cName, aIndex, cAlias, aEtalonDB, 'сведения об иностранных гражданах' ) )
//---------

// справочник представителей
	cClassName := Upper( 'TRepresentativeDB' )
	cName := dir_server + 'mo_kpred' + sdbf
	aEtalonDB := { ;
				{ 'KOD',		'N',	7,	0 }, ;	// ID пациента
				{ 'NN',			'N',	1,	0 }, ;	// номер представителя
				{ 'FIO',		'C',	50,	0 }, ;	// Ф.И.О.
				{ 'STATUS',		'N',	2,	0 }, ;	// Cтатус сопр.лица: 0-прочий,1-родитель,2-опекун
				{ 'IS_UHOD',	'N',	1,	0 }, ; // 0-нет, 1-по уходу за больным
				{ 'IS_FOOD',	'N',	1,	0 }, ; // 0-нет, 1-с питанием
				{ 'DATE_R',		'D',	8,	0 }, ; // дата рождения
				{ 'ADRES',		'C',	50,	0 }, ; // адрес
				{ 'MR_DOL',		'C',	50,	0 }, ; // место работы
				{ 'PHONE',		'C',	11,	0 }, ; // контактный телефон
				{ 'PASPORT',	'C',	15,	0 }, ; // паспортные данные
				{ 'POLIS',		'C',	25,	0 } ;  // данные о страховом полисе
				}
	cAlias := 'TRepresentative'
	aIndex := { ;
				{ dir_server + 'mo_kpred', 'str( kod, 7 ) + str( nn, 1 )' } ;
				}
	hb_hSet( ::hbFiles, cClassName, TDBFile():New( cName, aIndex, cAlias, aEtalonDB, 'справочник представителей' ) )
//---------

	::oSelf := Self

	return self