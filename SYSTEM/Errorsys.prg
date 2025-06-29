/***
*	Errorsys.prg
*  Standard Clipper error handler
*     (���������� ������� �.�. 12.09.2001 ��� Clipper'�)
*     (���������� ������� �.�. 16.11.2011 ��� Harbour'�)
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*/

#include 'function.ch'
#include 'Directry.ch'
#include 'common.ch'
#include 'error.ch'
#include 'inkey.ch'
#include 'hbver.ch'

// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr( <list> )

static err_file := 'error.txt'

// automatically executes at startup
proc ErrorSys()
	ErrorBlock( { | e | DefError( e ) } )
	return

//
static function DefError( e )
	local i, k, s, cMessage, aOptions, nChoice, arr_error := {}
	local cName

	// �� 㬮�砭�� ������� �� ���� ���� ����
	if ( e:genCode == EG_ZERODIV )
		return ( 0 )
	end
	// ��� �訡�� ������ 䠩�� � �⥢�� ���㦥���..��⠭���� NETERR()
	// � ���祭�� SUBSYSTEM �� 㬮�砭��
	if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
		NetErr( .t. )
		return ( .f. )                  // NOTE
	end
	// ��� �訡�� �����஢�� �� �६� APPEND BLANK..��⠭���� NETERR()
	// � ���祭�� SUBSYSTEM �� 㬮�砭��
	if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
		NetErr( .t. )
		return ( .f. )                  // NOTE
	end
	// ����஥��� ᮮ�饭�� �� �訡��
	cMessage := ErrorMessage( e )
	// ����஥��� ���ᨢ� ����権 ��� �롮�
	aOptions := { '��������' }                 // 1
	if ( e:canRetry )
		AAdd( aOptions, '�������' )             // 2
	endif
	if ( e:canDefault )
		AAdd( aOptions, '�ய�����' )            // 3
	endif
	// ��⨢����� ALERT-����
	nChoice := 0
	while ( nChoice == 0 )
		if ( Empty(e:osCode) )
			nChoice := Alert( cMessage, aOptions )
		else
			nChoice := Alert( cMessage + ;
				';(��� DOS-�訡��: ' + lstr( e:osCode ) + ')', ;
				aOptions )
		end
		if ( nChoice == NIL )
			exit
		end
	end
	if ( !Empty( nChoice ) )
		// �믮������ �� ������樨 ������
		if ( aOptions[ nChoice ] == '�������' )
			return (.t.)
		elseif ( aOptions[ nChoice ] == '�ய�����' )
			return ( .f. )
		end
	end
	// �⮡ࠦ���� ᮮ�饭�� � �⥪� �맮�� ��楤�� (�� ��������)
	if ( !Empty( e:osCode ) )
		cMessage += ' (��� DOS-�訡��: ' + lstr( e:osCode ) + ')'
	end
	aadd( arr_error, cMessage )
	? cMessage
	i := 0
	while ( !Empty( s := alltrim( ProcName( i ) ) ) )
		k := ProcLine( i )
		if isFuncErr( s )   // �᫨ �-�� �� �室�� � ᯨ᮪ "���㦭��" �맮���
			cMessage := '�맮� �� ' + s + '(' + lstr( k ) + ')'
			? cMessage
			aadd( arr_error, cMessage )
		endif
		++i
	end
	// ������ � 䠩� ���ଠ樨 �� �訡��

	cMessage := __errMessage( arr_error )
	__errSave( cMessage )

	ErrorLevel(1)
	f_end()
	return (.f.)

//
function ErrorMessage( e )
	local cMessage

	// ��砫� ᮮ�饭�� �� �訡��
	cMessage := if( e:severity > ES_WARNING, '�訡�� ', '�।�०����� ' )
	// ���������� ����� �����⥬� (�᫨ ����㯭�)
	if ( ValType(e:subsystem) == 'C' )
		cMessage += e:subsystem()
	else
		cMessage += '???'
	end
	// ���������� SUBSYSTEM ���� �訡�� (�᫨ ����㯭�)
	if ( ValType( e:subCode ) == 'N' )
		cMessage += ( '/' + lstr( e:subCode ) )
	else
		cMessage += '/???'
	end
	// ���������� ���ᠭ�� �訡�� (�᫨ ����㯭�)
	if ( ValType( e:description ) == 'C' )
		cMessage += ( '  ' + iif( ischaracter( e:subsystem ) .and. alltrim( e:subsystem ) == 'WINOLE', win_ANSIToOEM( e:description ), e:description ) )
	end
	// ���������� ���� FILENAME, ���� �������� ����樨
	if ( !Empty( e:filename ) )
		cMessage += ( ': ' + StripPath( e:filename ) )
	elseif ( !Empty( e:operation ) )
		cMessage += ( ': ' + e:operation )
	end
	return ( cMessage )

// �室�� �� �㭪�� � ᯨ᮪ ��, �� �㦭� �뢥�� � ERROR.TXT
static function isFuncErr( s )
	static delfunction := { 'DEFERROR', 'ERRORSYS', 'LOCKERRHAN', 'INITHANDL' }
	local fl := .t., i

	s := upper( s )
	for i := 1 to len( delfunction )
		if delfunction[ i ] $ s
			fl := .f.
			exit
		endif
	next
	return fl

// 28.05.17 ��ᬮ�� 䠩�� �訡�� (४��������� ������� � ���� "��ࢨ�")
function view_errors()

	if !file( dir_server() + err_file )
		return func_error( 4, '�� �����㦥� 䠩� �訡��!' )
	endif
	// keyboard chr( K_END )
	viewtext( Devide_Into_Pages( dir_server() + err_file, 80, 84 ), , , , .t., , , 5, , , .f. )
	return nil

// ࠧ���� ⥪�⮢� 䠩� �� ��࠭���
function Devide_Into_Pages( cFile, HH, sh )
	local tmp_file := '_TMP_.txt'
	
	DEFAULT HH TO 60
	fp := fcreate( tmp_file ) ; n_list := 1 ; tek_stroke := 0
	ft_use( cFile )
	do while !ft_Eof()
		verify_FF( HH, valtype( sh ) == 'N', sh )
		add_string( ft_ReadLn() )
		ft_Skip()
	enddo
	ft_use()
	fclose( fp )
	return tmp_file

// �㭪�� �ନ஢���� ⥪�⮢��� ᮮ�饭�� ��� �訡��
function __errMessage( arr_error )
	local s := '', cMessage := ''
	
	set date german
	s := exename()
	cMessage += '���: ' + dtoc( date() ) + ', �६�: ' + sectotime( seconds() ) + ' ' + StripPath( s )
	cMessage += '(' + dtoc( directory( s )[ 1, F_DATE ] ) + ', ' + lstr( memory( 1 ) ) + '��)' + hb_eol()
//	cMessage += '�����: ' + Err_version + hb_eol()
	cMessage += '�����: ' + Err_version() + hb_eol()
	if type( 'fio_polzovat' ) == 'C' .and. !empty( fio_polzovat )
		cMessage += '���짮��⥫�: ' + alltrim( fio_polzovat )
	endif
	cMessage += hb_eol()
	
	cMessage += '->OS: ' + OS() + hb_eol()
	cMessage += '->Computer Name: ' + GetEnv( 'COMPUTERNAME' ) + hb_eol()
	cMessage += '->User Name: '     + GetEnv( 'USERNAME' ) + hb_eol()
	cMessage += '->Logon Server: '  + Substr( GetEnv( 'LOGONSERVER' ), 2 ) + hb_eol()
	cMessage += '->Client Name: '   + GetEnv( 'CLIENTNAME' ) + hb_eol()
	cMessage += '->User Domain: '   + GetEnv( 'USERDOMAIN' ) + hb_eol()

	aeval( arr_error, { | x | cMessage += x + hb_eol() } )
	cMessage += replicate( '*', 79 ) + hb_eol()
	return cMessage

// �㭪�� ����� � 䠩� �訡��
function __errSave( cMessage )
	local cName

	if __mvExist( 'dir_server' )
		if type( 'dir_server' ) != 'C'
			private dir_server := ''
		endif
	else
		private dir_server := ''
	endif
	
	cName := TempFile( dir_server(), 'txt', SetFCreate() )
	strfile( cMessage, cName, .t. )
	if hb_FileExists( dir_server() + err_file )
		if filesize( dir_server() + err_file ) > 500000  // �᫨ ����� 0.5 ��,
			FErase( dir_server() + err_file )        // 㤠�塞 䠩� � ��稭��� � ���
		endif
		nRet := FileAppend( dir_server() + err_file, cName )
	endif
	FileCopy( cName, dir_server() + err_file, )
	FErase( cName )        // 㤠�塞 �६���� 䠩�
	return nil
