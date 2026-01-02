// Audit.prg - работа с данными работы пользователями системы
// ****************************************************************************
// 13.11.18 AuditWrite( task, type, work, quantity, field ) - запись информации в файл аудита
// ****************************************************************************

#include 'hbthread.ch'
#include 'common.ch'
#include 'set.ch'
#include 'inkey.ch'

#include 'function.ch'
#include 'edit_spr.ch'
#include 'chip_mo.ch'

// 28.07.25 - запись информации в файл аудита
function AuditWrite( task, type, work, quantity, field )

	local oAudit, id_user

	id_user := currentuser():ID

	oAudit := TAuditDB():getByParam( Date(), id_user, task, type, work )
	if isnil( oAudit )
		oAudit := TAudit():New()
		oAudit:Date := Date()
		oAudit:Operator := id_user
		oAudit:Task := task
		oAudit:Type := type
		oAudit:Work := work
	endif
	oAudit:Quantity += hb_defaultValue( quantity, 0 )
	oAudit:Field += hb_defaultValue( field, 0 )
	TAuditDB():Save( oAudit )
	return .t.