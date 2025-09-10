#include 'hbclass.ch'
#include 'hbhash.ch'
#include 'property.ch'
#include 'function.ch'

// ª« áá ¤«ï 'Roles.dbf'
CREATE CLASS TRoleUser	INHERIT	TBaseObjectBLL
	VISIBLE:
		PROPERTY Name AS STRING READ getName WRITE SetName
		PROPERTY ACLDep AS STRING READ getACLDep WRITE SetACLDep
		PROPERTY ACLTask AS STRING READ getACLTask WRITE SetACLTask
		
		METHOD New( nID, cName, cACL_DEP, cACL_TASK, lNew, lDeleted )
		METHOD StrAcceptDepartment()
		METHOD StrAcceptTask()
		METHOD Name1251()
	HIDDEN:
		DATA FName		INIT space( 30 )
		DATA FACLDep	INIT space( 255 )
		DATA FACLTask	INIT space( 255 )
		
		METHOD getName
		METHOD setName( cText )
		METHOD getACLDep
		METHOD setACLDep( cText )
		METHOD getACLTask
		METHOD setACLTask( cText )
END CLASS

METHOD Function Name1251()	CLASS TRoleUser
	
	return win_OEMToANSI( ::FName )

METHOD function getName()	CLASS TRoleUser
	return ::FName

METHOD PROCEDURE setName( cText )	CLASS TRoleUser
	
	::FName := cText
	return

METHOD function getACLDep()	CLASS TRoleUser
	return ::FACLDep

METHOD PROCEDURE SetACLDep( cText )	CLASS TRoleUser
	
	::FACLDep := cText
	return

METHOD function getACLTask()	CLASS TRoleUser
	return ::FACLTask
	
METHOD PROCEDURE SetACLTask( cText )	CLASS TRoleUser
	
	::FACLTask := cText
	return

METHOD StrAcceptDepartment() CLASS TRoleUser

	local k

	k := atnum( chr( 0 ), ::FACLDep, 1 )
	return '= ' + lstr( k - 1 ) + 'ãçà. ='

METHOD StrAcceptTask() CLASS TRoleUser

	local k, tempStr := ''

	k := atnum( chr( 0 ), ::ACLTask, 1 )
	tempStr := ' § ¤ ç'
	if k - 1 == 1
		tempStr := tempStr +' '
	elseif  k - 1 > 1 .and. k - 1 < 5
		tempStr := tempStr +'¨'
	endif
	return '= ' + lstr( k - 1 ) + tempStr + ' ='
	
//
// Ñîçäàòü íîâûé îáúåêò TRoleUser
METHOD New( nID, cName, cACL_DEP, cACL_TASK, lNew, lDeleted )	CLASS TRoleUser
			
	::FName			:= hb_DefaultValue( cName, space( 30 ) )
	::FACLDep		:= hb_DefaultValue( cACL_DEP, space( 255 ) )
	::FACLTask		:= hb_DefaultValue( cACL_TASK, space( 255 ) )
	
	::FID			:= hb_DefaultValue( nID, 0 )
	::FNew			:= hb_DefaultValue( lNew, .t. )
	::FDeleted		:= hb_DefaultValue( lDeleted, .f. )
	return self
