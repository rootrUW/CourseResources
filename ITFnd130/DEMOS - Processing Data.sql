--*************************************************************************--
-- Title: Module04
-- Desc: This file demonstrates the typical statements involved with selecting data
--       1) Insert
--       2) Update
--       3) Delete
--       4) Transactions
--       5) Try-Catch
--       6) Dynamic SQL Statements
-- Change Log: When,Who,What
-- 2017-07-16,RRoot,Created File
--**************************************************************************--

-- *** Set Up Code ***
-----------------------------------------------------------------------------------------------------------------------
Use Master;
Go

If Exists (
  Select Name
  From SysDatabases
  Where Name = 'Module04DemoDB'
)
Begin
  Alter Database Module04DemoDB
    Set Single_User With Rollback Immediate;

  Drop Database Module04DemoDB;
End;
Go

Create Database Module04DemoDB;
Go

Use Module04DemoDB;
Go

Create Table dbo.Contacts (
  ContactId int Not Null Identity,
  FirstName varchar(100) Not Null,
  LastName varchar(100) Not Null,
  EmailAddress varchar(100) Not Null,
  Constraint pkContacts Primary Key (ContactId),
  Constraint uqContactsEmailAddress Unique (EmailAddress)
);
Go

Create Table dbo.ContactLog (
  ContactLogId int Identity,
  ContactDate datetime Not Null,
  ContactId int Not Null,
  Message varchar(8000) Not Null,
  Constraint pkContactLog Primary Key (ContactLogId)
);
Go

-- *** Insert Statements ***
-----------------------------------------------------------------------------------------------------------------------
Insert Into dbo.Contacts (
  FirstName,
  LastName,
  EmailAddress
)
Values (
  'Bob',
  'Smith',
  'BSmith@MyCo.Com'
);
Go

Select *
From dbo.Contacts;
Go

Select @@Identity;
Go

Insert Into dbo.Contacts
Values (
  'Sue',
  'Jones',
  'SJones@MyCo.Com'
);
Go

Select *
From dbo.Contacts;
Go

-- Multiple rows
Insert Into dbo.Contacts (
  FirstName,
  LastName,
  EmailAddress
)
Values
  ('Tim', 'Thomas', 'TThomas@MyCo.Com'),
  ('Pat', 'Pruit', 'PPruit@MyCo.Com');
Go

Select *
From dbo.Contacts;
Go

-- Insert from Select
Insert Into dbo.Contacts (
  FirstName,
  LastName,
  EmailAddress
)
Select
  au_fname,
  au_lname,
  Substring(au_fname, 1, 1) + au_lname + '@MyCo.com'
From Pubs.dbo.Authors;
Go

Select *
From dbo.Contacts;
Go

-- Filtered insert
Insert Into dbo.Contacts (
  FirstName,
  LastName,
  EmailAddress
)
Select
  au_fname,
  au_lname,
  Substring(au_fname, 1, 1) + au_lname + '@MyCo.com'
From Pubs.dbo.Authors
Where au_lname != 'Ringer';
Go

Select *
From dbo.Contacts;
Go

-- Dates
Insert Into dbo.ContactLog (
  ContactDate,
  ContactId,
  Message
)
Values
  ('20170101 03:01:05', 1, 'Hey, Bob! How are things?'),
  (GetDate(), 2, 'Hey, Sue! How are things?');
Go

Select *
From dbo.ContactLog;
Go

-- Transactions
Begin Transaction;

Insert Into dbo.ContactLog (
  ContactDate,
  ContactId,
  Message
)
Values (
  GetDate(),
  3,
  'Hey, Tim! How are things?'
);

Commit Transaction;
Go

Begin Tran;

Insert Into dbo.ContactLog (
  ContactDate,
  ContactId,
  Message
)
Values (
  GetDate(),
  3,
  'Hey, Tim! How are things?'
);

Rollback Tran;
Go

Select @@TranCount;
Go

-- Try-Catch
Begin Try
  Begin Tran;

  Insert Into dbo.ContactLog (
    ContactDate,
    ContactId,
    Message
  )
  Values (
    GetDate(),
    4,
    'Hey, Pat! How are things?'
  );

  Commit Tran;
End Try
Begin Catch
  Rollback Transaction;
End Catch;
Go

Select *
From dbo.ContactLog;
Go

-- Error handling
Begin Try
  Begin Tran;

  Insert Into dbo.Contacts (
    FirstName,
    LastName,
    EmailAddress
  )
  Values (
    'Pat',
    'Pruit',
    'PPruit@MyCo.Com'
  );

  Commit Tran;
End Try
Begin Catch
  Rollback Transaction;
  Print 'There was an Error!';
  Print Error_Message();
End Catch;
Go

-- *** Update Statements ***
-----------------------------------------------------------------------------------------------------------------------
Update dbo.Contacts
Set LastName = 'Smith'
Where ContactId = 2;
Go

Update dbo.Contacts
Set LastName = 'Smith',
    EmailAddress = 'SSmith@MyCo.com'
Where ContactId = 2;
Go

Select @@RowCount;
Go

-- Multi-row safety
Begin Tran;

Update dbo.Contacts
Set LastName = 'Smith';

Rollback Tran;
Go

Begin Try
  Begin Tran;

  Update dbo.Contacts
  Set LastName = 'Smith';

  If (@@RowCount > 1)
    RaisError('Do not change more than one row!', 15, 1);

  Commit Tran;
End Try
Begin Catch
  Rollback Transaction;
  Print Error_Message();
End Catch;
Go

-- *** Delete Statements ***
-----------------------------------------------------------------------------------------------------------------------
Delete
From dbo.Contacts
Where ContactId = 5;
Go

Begin Try
  Begin Tran;

  Delete
  From dbo.Contacts;

  If (@@RowCount > 1)
    RaisError('Do not change more than one row!', 15, 1);

  Commit Tran;
End Try
Begin Catch
  Rollback Transaction;
  Print Error_Message();
End Catch;
Go

-- Delete with subquery
Begin Try
  Begin Tran;

  Delete
  From dbo.ContactLog
  Where ContactId In (
    Select ContactId
    From dbo.Contacts
    Where FirstName = 'Bob'
      And LastName = 'Smith'
  );

  Delete
  From dbo.Contacts
  Where ContactId = 1;

  Commit Tran;
End Try
Begin Catch
  Rollback Transaction;
  Print Error_Message();
End Catch;
Go

-- Delete with Join
Begin Try
  Begin Tran;

  Delete CL
  From dbo.ContactLog As CL
  Inner Join dbo.Contacts As C
    On CL.ContactId = C.ContactId
  Where C.FirstName = 'Bob'
    And C.LastName = 'Smith';

  Delete
  From dbo.Contacts
  Where ContactId = 1;

  Commit Tran;
End Try
Begin Catch
  Rollback Transaction;
  Print Error_Message();
End Catch;
Go

-- *** Foreign Key ***
-----------------------------------------------------------------------------------------------------------------------
Alter Table dbo.ContactLog
Add Constraint fkContactLogContacts
  Foreign Key (ContactId)
  References dbo.Contacts (ContactId);
Go

-- *** Dynamic SQL ***
-----------------------------------------------------------------------------------------------------------------------
Declare
  @FirstName varchar(100) = 'Zeb',
  @LastName varchar(100) = 'Zalanzy',
  @EmailAddress varchar(100) = 'ZZalanzy@MyCo.com';

Select
  'Insert Into dbo.Contacts (FirstName, LastName, EmailAddress) Values (''' +
  @FirstName + ''', ''' +
  @LastName + ''', ''' +
  @EmailAddress + ''');';
Go

Execute (
  'Insert Into dbo.Contacts (FirstName, LastName, EmailAddress) Values (''' +
  @FirstName + ''', ''' +
  @LastName + ''', ''' +
  @EmailAddress + ''');'
);
Go

Select *
From dbo.Contacts
Order By ContactId Desc;
Go