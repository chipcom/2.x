// �ᯮ�짮����� ᥬ��஢ ��� ࠡ��� � ��
//
// G_SOpen(<��� ᥬ���/open>,<��� ᥬ���/lock>,_fio,_comp) --> <�ᯥ譮��� ������>
// ���뢠�� ᥬ��� ��� ᮢ���⭮�� �ᯮ�짮����� (�室 � ������)
// G_SClose(<��� ᥬ���>) --> <�ᯥ�>
// ����뢠�� ������ ���� ᥬ��� (��室 �� �����)
// G_SCount(<��� ᥬ���>) --> <�᫮>
// �����頥� �᫮ ࠡ��� �⠭権, ᮢ���⭮ �ᯮ������ ��� ᥬ���
// (�.�. ᪮�쪮 ���짮��⥫�� ࠡ���� � ����� ������ � �⮩ �����)
// G_SIsLock(<��� ᥬ���>) --> <.t.-�������஢��, .f.-���>
// �஢����, �������஢�� �� ����� ᥬ���
// G_SLock(<��� ᥬ���>) --> <�ᯥ譮��� �����஢��>
// �������� �����஢��� ᥬ��� ��� �������쭮�� �ᯮ�짮�����
// G_SUnlock(<��� ᥬ���>)
// �᢮������� �������஢���� ���� ᥬ���
// G_SUnlockArr(<���ᨢ ᥬ��஢>)
// �᢮������� �������஢���� ���� ᥬ����
// G_SLock1Task(cSemaphore_task,cSemaphore_lock) --> <�ᯥ譮��� �����஢��>
// �������� �����஢��� ᥬ���, �᫨ ����饭 ⮫쪮 ���� ������ �����
// G_SValue(<��� ᥬ���>) --> <���祭�� ���稪�>
// �����頥� ⥪�饥 ���祭�� ����७���� ���稪� ᥬ���
// (�� �� ���祭�� ����뢠�� ���ﭨ� ��� ᫥���騥 �㭪樨)
// G_SPlus(<��� ᥬ���>) --> <�ᯥ�>
// 㢥��稢��� ⥪�饥 ���祭�� ����७���� ���稪� ᥬ���
// G_SMinus(<��� ᥬ���>) --> <�ᯥ�>
// 㬥��蠥� ⥪�饥 ���祭�� ����७���� ���稪� ᥬ���
// G_SValueNLock(cSemaphore_value,nValue,cSemaphore_lock) --> <�ᯥ譮��� �����஢��>
// �������� �����஢��� ᥬ��� cSemaphore_lock, �᫨
// G_SValue(cSemaphore_value) �����頥� <= nValue
//
//
#include 'set.ch'
#include 'fileio.ch'
#include 'function.ch'

//#define file_sem  (dir_server()+'semaphor')
#define S_LOCK      1
#define S_IS_LOCK  11
#define S_UNLOCK    2
#define S_OPEN      3
#define S_CLOSE     4
#define S_COUNT     5
#define S_VALUE     6
#define S_VALUE_LOCK  61
#define S_MINUS     7
#define S_PLUS      8
#define S_UNLOCKARR 9

Static task_name := 0
Static task_fio  := ''
Static task_comp := ''

//
// G_SLock1Task(cSemaphore_task, cSemaphore_lock) --> <�ᯥ譮��� ������>
//
// �� �㭪�� �������� �����஢��� ᥬ��� ��� �������쭮�� �ᯮ�짮�����,
// �᫨ ����饭 ⮫쪮 ���� ������ �����
//
Function g_slock1task( cSemaphore_task, cSemaphore_lock )
  Return g_soperation( cSemaphore_lock, S_LOCK,, cSemaphore_task )

//
// G_SValueNLock(cSemaphore_value,nValue,cSemaphore_lock) --> <�ᯥ譮��� ������>
//
// �� �㭪�� �������� �����஢��� ᥬ��� cSemaphore_lock, �᫨
// G_SValue(cSemaphore_value) �����頥� <= nValue
//
Function g_svaluenlock( cSemaphore_value, nValue, cSemaphore_lock )
  Return g_soperation( cSemaphore_value, S_VALUE_LOCK,, cSemaphore_lock, nValue )

//
// G_SIsLock(<��� ᥬ���>) --> <.t.-�������஢��, .f.-���>
// �஢����, �������஢�� �� ����� ᥬ���
//
Function g_sislock( cSemaphore )
  Return g_soperation( cSemaphore, S_IS_LOCK )

//
// G_SLock(<��� ᥬ���>) --> <�ᯥ譮��� ������>
//
// �� �㭪�� �������� �����஢��� ᥬ��� ��� �������쭮�� �ᯮ�짮�����.
//
Function g_slock( cSemaphore )
  Return g_soperation( cSemaphore, S_LOCK )

//
// G_SUnlock(<��� ᥬ���>)
//
// �� �㭪�� �᢮������� �������஢���� ���� ᥬ���.
//
Function g_sunlock( cSemaphore )
  Return g_soperation( cSemaphore, S_UNLOCK )

//
// G_SUnlockArr(<���ᨢ ᥬ��஢>)
//
// �� �㭪�� �᢮������� �������஢���� ���� ᥬ����.
//
Function g_sunlockarr( arrSemaphore )
  Return g_soperation( '_', S_UNLOCKARR, arrSemaphore )

//
// G_SOpen(<��� ᥬ���/open>,<��� ᥬ���/lock>) --> <�ᯥ譮��� ������>
//
// �� �㭪�� ���뢠�� ᥬ��� ��� ᮢ���⭮�� �ᯮ�짮�����.
//
Function g_sopen( cSemaphore_open, cSemaphore_lock, _fio, _comp )

  Default cSemaphore_lock To '', _fio To '', _comp To ''
  task_fio := _fio
  If Empty( _comp )
    _comp := date_8( Date() ) + '��� �����'
  Endif
  task_comp := _comp

  Return g_soperation( cSemaphore_open, S_OPEN,, cSemaphore_lock )

//
// G_SClose(<��� ᥬ���>) --> <�ᯥ�>
//
// �� �㭪�� ����뢠�� ������ ���� ᥬ���.
//
Function g_sclose( cSemaphore )
  Return g_soperation( cSemaphore, S_CLOSE )

//
// G_SCount(<��� ᥬ���>) --> <�᫮>
//
// �� �㭪�� �����頥� �᫮ ࠡ��� �⠭権, ᮢ���⭮ �ᯮ������ �
// �����騩 ������ ��� ᥬ��� (�.�. ᪮�쪮 ���짮��⥫�� ࠡ����
// � ����� ������ � �⮩ �����).
//
Function g_scount( cSemaphore )
  Return g_soperation( cSemaphore, S_COUNT )

//
// G_SValue(<��� ᥬ���>) --> <���祭�� ���稪�>
//
// �� �㭪�� �����頥� ⥪�饥 ���祭�� ����७���� ���稪� ᥬ���.
// (�� �� ���祭�� ����뢠�� ���ﭨ� ��� ᫥���騥 �㭪樨.)
//
Function g_svalue( cSemaphore )
  Return g_soperation( cSemaphore, S_VALUE )

//
// G_SMinus(<��� ᥬ���>) --> <�ᯥ�>
//
// �� �㭪�� 㬥��蠥� ⥪�饥 ���祭�� ����७���� ���稪� ᥬ���.
//
Function g_sminus( cSemaphore )
  Return g_soperation( cSemaphore, S_MINUS )

//
// G_SPlus(<��� ᥬ���>) --> <�ᯥ�>
//
// �� �㭪�� 㢥��稢��� ⥪�饥 ���祭�� ����७���� ���稪� ᥬ���.
//
Function g_splus( cSemaphore )
  Return g_soperation( cSemaphore, S_PLUS )

// 16.09.25
Static Function g_soperation( cSemaphore, cOperation, arrSemaphore, cSemaphore2, nV )

  Static adbf := { ;
    { 'KOD',  'N', 1, 0 }, ;  // ��� ����樨
    { 'NAME', 'C', 60, 0 }, ;  // ������������ (ᮤ�ঠ���) ᥬ���
    { 'VALUE', 'N', 4, 0 }, ;  // ���祭�� ���稪�
    { 'TASK', 'N', 7, 0 }, ;  // ������⢮ ᥪ㭤 ��᫥ ���㭮�
    { 'EXE',  'C', 12, 0 }, ;  // ������������ 䠩�� �����
    { 'DATA', 'D', 8, 0 }, ;  // ��� ����᪠ �����
    { 'FIO',  'C', 20, 0 }, ;  // ��� ���짮��⥫�
    { 'COMP', 'C', 17, 0 } }   // ������������ ��������
  Local i, lnRetValue := .f., tmp_select := Select(), fl, bSaveHandler
  Local sbase, sem_dbf, fp

  Default cSemaphore To '', cOperation To 0, cSemaphore2 To ''
  If equalany( cOperation, S_COUNT, S_VALUE )
    lnRetValue := 0
  Endif
  If Empty( cSemaphore )
    Return lnRetValue
  Endif
  sbase := dir_server() + 'semaphor'
  sem_dbf := sbase + '.dbf'
  cSemaphore  := PadR( Upper( LTrim( cSemaphore ) ), 60 )
  cSemaphore2 := PadR( Upper( LTrim( cSemaphore2 ) ), 60 )
  i := 0 ; fl := .f.
  Do While .t.
    //
    bSaveHandler := ErrorBlock( {| x| Break( x ) } )
    //
    Begin Sequence
      If !hb_FileExists( sem_dbf )  // ��⠥��� ᮧ���� DBF-䠩�
        dbCreate( sbase, adbf )
      Endif
      dbUseArea( .t., ;          // new
        , ;            // rdd
        sbase, ;    // db
        'SEMAPHOR', ;  // alias
        .f., ;          // !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
        , ;            // readonly
        'RU866' )
      fl := .t.
    RECOVER USING error
      fl := .f.
      If Select( 'SEMAPHOR' ) > 0
        SEMAPHOR->( dbCloseArea() )
      Endif
    End
    //
    ErrorBlock( bSaveHandler )
    //
    If fl // �� 㤠筮� ����⨨ ᮧ��� ������ � ࠡ�祬 ��⠫���
      Index On Str( FIELD->kod, 1 ) + FIELD->name + Str( FIELD->task, 7 ) To tmp_sem
      Exit
    Else
      If++i > 30
        f_alert( { '���������� ������ 䠩� ' + Upper( sem_dbf ) + '.', ;
          '����⭥� �ᥣ�, �� ����� ��㣨� ���짮��⥫��.', ;
          '' }, ;
          { ' <Enter> - ��������� ᭮�� ' }, ;
          1, 'W/N', 'G+/N',,, 'W+/N,N/BG' )
        i := 0
      Endif
    Endif
    Millisec( 20 )
  Enddo
  If fl
    Do Case
    Case cOperation == S_IS_LOCK
      find ( Str( S_LOCK, 1 ) + cSemaphore )
      lnRetValue := Found()
    Case cOperation == S_LOCK
      lnRetValue := .t.
      If !Empty( cSemaphore2 )
        i := 0
        find ( Str( S_OPEN, 1 ) + cSemaphore2 )
        Do While SEMAPHOR->kod == S_OPEN .and. SEMAPHOR->name == cSemaphore2 .and. !Eof()
          i++
          Skip
        Enddo
        lnRetValue := ( i < 2 )
      Endif
      If lnRetValue
        find ( Str( S_LOCK, 1 ) + cSemaphore )
        If ( lnRetValue := !Found() )
          s_addrec( 1 )
          Replace kod With S_LOCK, name With cSemaphore, task With task_name
        Endif
      Endif
    Case cOperation == S_UNLOCK
      find ( Str( S_LOCK, 1 ) + cSemaphore + Str( task_name, 7 ) )
      If Found()
        s_deleterec()
      Endif
      lnRetValue := .t.
    Case cOperation == S_UNLOCKARR
      For i := 1 To Len( arrSemaphore )
        find ( Str( S_LOCK, 1 ) + PadR( Upper( LTrim( arrSemaphore[ i ] ) ), 60 ) + Str( task_name, 7 ) )
        If Found()
          s_deleterec()
        Endif
      Next
      lnRetValue := .t.
    Case cOperation == S_OPEN
      If task_name == 0
        If LastRec() > 20
          Pack  // �᫨ 㦥 ����让 䠩�, 㯠�㥬 ���
        Endif
        del_sem_files()  // 㤠��� �� ���� ᥬ����
        task_name := Int( Seconds() * 100 )
        fp := FCreate( lstr( task_name ) + '.000', FC_HIDDEN )
        FWrite( fp, lstr( task_name ) )
        FClose( fp )
      Endif
      lnRetValue := .t.
      If !Empty( cSemaphore2 )
        find ( Str( S_LOCK, 1 ) + cSemaphore2 )
        lnRetValue := !Found()
      Endif
      If lnRetValue .and. !Empty( task_fio ) .and. Type( 'verify_fio_polzovat' ) == 'L'
        find ( Str( S_OPEN, 1 ) + cSemaphore )
        Do While SEMAPHOR->kod == S_OPEN .and. SEMAPHOR->name == cSemaphore .and. !Eof()
          If SEMAPHOR->fio == PadR( task_fio, 20 )
            lnRetValue := .f.
            verify_fio_polzovat := .t.
            Exit
          Endif
          Skip
        Enddo
      Endif
      If lnRetValue
        s_addrec( 1 )
        Replace kod  With S_OPEN, ;
          name With cSemaphore, ;
          task With task_name, ;
          Data With Date(), ;
          fio  With task_fio, ;
          comp With task_comp, ;
          exe  With strippath( ExeName() )
      Endif
    Case cOperation == S_CLOSE
      lnRetValue := del_sem_files() // 㤠��� �� ���� ᥬ����
    Case cOperation == S_COUNT
      lnRetValue := 0
      find ( Str( S_OPEN, 1 ) + cSemaphore )
      Do While SEMAPHOR->kod == S_OPEN .and. SEMAPHOR->name == cSemaphore .and. !Eof()
        lnRetValue++
        Skip
      Enddo
    Case cOperation == S_VALUE
      lnRetValue := 0
      find ( Str( S_VALUE, 1 ) + cSemaphore )
      Do While SEMAPHOR->kod == S_VALUE .and. SEMAPHOR->name == cSemaphore .and. !Eof()
        lnRetValue += semaphor->value
        Skip
      Enddo
    Case cOperation == S_VALUE_LOCK
      i := 0
      find ( Str( S_VALUE, 1 ) + cSemaphore )
      Do While SEMAPHOR->kod == S_VALUE .and. SEMAPHOR->name == cSemaphore .and. !Eof()
        i += semaphor->value
        Skip
      Enddo
      If ( lnRetValue := ( i <= nV ) )
        find ( Str( S_LOCK, 1 ) + cSemaphore2 )
        If ( lnRetValue := !Found() )
          s_addrec( 1 )
          Replace SEMAPHOR->kod With S_LOCK, SEMAPHOR->name With cSemaphore2, SEMAPHOR->task With task_name
        Endif
      Endif
    Case cOperation == S_MINUS
      find ( Str( S_VALUE, 1 ) + cSemaphore + Str( task_name, 7 ) )
      If Found()
        Replace SEMAPHOR->value With SEMAPHOR->value - 1
      Endif
      lnRetValue := .t.
    Case cOperation == S_PLUS
      find ( Str( S_VALUE, 1 ) + cSemaphore + Str( task_name, 7 ) )
      If !Found()
        s_addrec( 1 )
        Replace SEMAPHOR->kod With S_VALUE, SEMAPHOR->name With cSemaphore, SEMAPHOR->task With task_name
      Endif
      Replace SEMAPHOR->value With SEMAPHOR->value + 1
      lnRetValue := .t.
    Endcase
  Endif
  If Select( 'SEMAPHOR' ) > 0   // �� ��直� ��砩 �� ࠧ��襭�� �����᭮�� 䠩��
    SEMAPHOR->( dbCloseArea() )
  Endif
  If tmp_select > 0
    Select( tmp_select )
  Endif
  Return ( lnRetValue )

//
Static Function del_sem_files( arr_files )

  Local i, t_name

  Default arr_files To Directory( '*.000', 'H' )
  Set Order To 0
  For i := 1 To Len( arr_files )
    t_name := Int( Val( FileStr( arr_files[ i, 1 ] ) ) )
    Go Top
    Do While !Eof()
      If SEMAPHOR->task == t_name
        s_deleterec()
      Endif
      Skip
    Enddo
    Delete File ( arr_files[ i, 1 ] )
  Next
  Set Order To 1
  Return .t.

// ���������� � ������ �ᯮ�짮������ 㤠������ ����ᥩ (���� ������)
Function s_addrec( k )

  // k - ����� ��஢��� ����
  Local lOldDeleted := Set( _SET_DELETED, .f. )
  find ( Str( 0, k ) )
  If Found() .and. Deleted()
    Recall
  Else
    Append Blank
  Endif
  Set( _SET_DELETED, lOldDeleted )  // ����⠭������� �।�
  Return .t.

// ������ ������ 䠩�� ᥬ��� � ������� ��� 㤠�����
Function s_deleterec()

  Replace SEMAPHOR->kod With 0, SEMAPHOR->name With '', SEMAPHOR->value With 0, SEMAPHOR->task With 0, ;
    SEMAPHOR->Data With CToD( '' ), SEMAPHOR->fio With '', SEMAPHOR->comp With '', SEMAPHOR->exe With ''
  Delete
  Return .t.
