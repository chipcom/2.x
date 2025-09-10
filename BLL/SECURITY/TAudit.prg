#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'common.ch'
#include 'property.ch'

// класс для аудита
CREATE CLASS TAudit	INHERIT	TBaseObjectBLL
	VISIBLE:
		PROPERTY Date AS DATE READ getDate WRITE setDate					// дата ввода
		PROPERTY Operator AS OBJECT READ getOperator WRITE setOperator	// код оператора
		PROPERTY Task AS NUMERIC READ getTask WRITE setTask				// код задачи
		PROPERTY Type AS NUMERIC READ getType WRITE setType				// тип (1-карточка, 2-л/у, 3-услуги)
		PROPERTY Work AS NUMERIC READ getWork WRITE setWork				// 1-добавление, 2-редактирование, 3-удаление
		PROPERTY Quantity AS NUMERIC READ getQuantity WRITE setQuantity	// кол-во (карточек, л/у или услуг)
		PROPERTY Field AS NUMERIC READ getField WRITE setField			// количество введённых полей
		
		METHOD New( nID, lNew, lDeleted )
	HIDDEN:
		DATA FDate		INIT ctod( '' )
		DATA FOperator	INIT nil
		DATA FTask		INIT 0
		DATA FType		INIT 0
		DATA FWork		INIT 0
		DATA FQuantity	INIT 0
		DATA FField		INIT 0
		
		METHOD getDate
		METHOD setDate( param )
		METHOD getOperator
		METHOD setOperator( param )
		METHOD getTask
		METHOD setTask( param )
		METHOD getType
		METHOD setType( param )
		METHOD getWork
		METHOD setWork( param )
		METHOD getQuantity
		METHOD setQuantity( param )
		METHOD getField
		METHOD setField( param )
END CLASS

METHOD function getDate() CLASS TAudit
	return ::FDate
	
METHOD procedure setDate( param ) CLASS TAudit

	::FDate := param
	return

METHOD function getOperator() CLASS TAudit
	return ::FOperator
	
METHOD procedure setOperator( param ) CLASS TAudit
	if isnumber( param )
		::FOperator := TUserDB():GetByID( param )
	elseif isobject( param ) .and. param:ClassName() == upper( 'TUser' )
		::FOperator := param
	elseif param == nil
		::FOperator := nil
	endif
	return

METHOD function getTask() CLASS TAudit
	return ::FTask
	
METHOD procedure setTask( param ) CLASS TAudit

	::FTask := param
	return

METHOD function getType() CLASS TAudit
	return ::FType
	
METHOD procedure setType( param ) CLASS TAudit

	::FType := param
	return

METHOD function getWork() CLASS TAudit
	return ::FWork
	
METHOD procedure setWork( param ) CLASS TAudit

	::FWork := param
	return

METHOD function getQuantity() CLASS TAudit
	return ::FQuantity
	
METHOD procedure setQuantity( param ) CLASS TAudit

	::FQuantity := param
	return

METHOD function getField() CLASS TAudit
	return ::FField
	
METHOD procedure setField( param ) CLASS TAudit

	::FField := param
	return

METHOD New( nID, lNew, lDeleted ) CLASS TAudit
	::super:new( nID, lNew, lDeleted )
	return self

// класс для 'mo_oper.dbf'
CREATE CLASS TAudit_main	INHERIT	TBaseObjectBLL
	VISIBLE:
		PROPERTY Operator AS OBJECT READ getOperator WRITE setOperator		// код оператора asc(po)
		PROPERTY Date AS DATE READ getDate WRITE setDate						// дата ввода c4tod(pd)
		PROPERTY V0 AS CHARACTER READ getV0 WRITE setV0						// добавление в регистратуре
		PROPERTY VR AS CHARACTER READ getVR WRITE setVR						// полные реквизиты
		PROPERTY VK AS CHARACTER READ getVK WRITE setVK						// реквизиты из картотеки => ft_unsqzn(V..., 6)
		PROPERTY VU AS CHARACTER READ getVU WRITE setVU						// ввод услуг
		PROPERTY Task AS NUMERIC READ getTask WRITE setTask					// код задачи
		PROPERTY Character AS CHARACTER READ getCharacter WRITE setCharacter	// количество введённых символов
		PROPERTY Edit AS LOGICAL READ getEdit WRITE setEdit					// 0 - добавление, 1 - редактирование
	
		METHOD New()
		&& METHOD Save()
	HIDDEN:
		DATA FOperator	INIT nil
		DATA FDate		INIT ctod( '' )
		DATA FV0		INIT space( 3 )
		DATA FVR		INIT space( 3 )
		DATA FVK		INIT space( 3 )
		DATA FVU		INIT space( 3 )
		DATA FTask		INIT 0
		DATA FCharacter	INIT space( 4 )
		DATA FEdit		INIT .f.

		METHOD getDate
		METHOD setDate( param )
		METHOD getOperator
		METHOD setOperator( param )
		METHOD getTask
		METHOD setTask( param )
		METHOD getV0
		METHOD setV0( param )
		METHOD getVR
		METHOD setVR( param )
		METHOD getVK
		METHOD setVK( param )
		METHOD getVU
		METHOD setVU( param )
		METHOD getCharacter
		METHOD setCharacter( param )
		METHOD getEdit
		METHOD setEdit( param )
END CLASS

METHOD function getDate() CLASS TAudit_main
	return ::FDate
	
METHOD procedure setDate( param ) CLASS TAudit_main

	::FDate := param
	return

METHOD function getOperator() CLASS TAudit_main
	return ::FOperator
	
METHOD procedure setOperator( param ) CLASS TAudit_main
	
	if isnumber( param )
		::FOperator := TUserDB():GetByID( param )
	elseif isobject( param ) .and. param:ClassName() == upper( 'TUser' )
		::FOperator := param
	elseif param == nil
		::FOperator := nil
	endif
	return

METHOD function getTask() CLASS TAudit_main
	return ::FTask
	
METHOD procedure setTask( param ) CLASS TAudit_main

	::FTask := param
	return

METHOD function getV0() CLASS TAudit_main
	return ::FV0
	
METHOD procedure setV0( param ) CLASS TAudit_main

	::FV0 := param
	return

METHOD function getVK() CLASS TAudit_main
	return ::FVK
	
METHOD procedure setVK( param ) CLASS TAudit_main

	::FVK := param
	return

METHOD function getVR() CLASS TAudit_main
	return ::FVR
	
METHOD procedure setVR( param ) CLASS TAudit_main

	::FVR := param
	return

METHOD function getVU() CLASS TAudit_main
	return ::FVU
	
METHOD procedure setVU( param ) CLASS TAudit_main

	::FVU := param
	return

METHOD function getCharacter() CLASS TAudit_main
	return ::FCharacter

METHOD procedure setCharacter( param ) CLASS TAudit_main

	::FCharacter := param
	return

METHOD function getEdit() CLASS TAudit_main
	return ::FEdit

METHOD procedure setEdit( param ) CLASS TAudit_main

	::FEdit := param
	return

METHOD New( nID, lNew, lDeleted ) CLASS TAudit_main
	
	::super:new( nID, lNew, lDeleted )
	return self
