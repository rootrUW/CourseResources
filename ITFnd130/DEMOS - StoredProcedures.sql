--*************************************************************************--
-- Title: Module08 
-- Desc: This file demonstrates creating and using Stored Procedures
--       Stored Procedure Basics
--       Getting Info About Stored Procedures
--       Stored Procedures For Transaction 
--       Stored Procedures For Abstraction
--       Stored Procedures With Error Handling
--       Stored Procedures With Return Codes
--       Creating a Stored Procedure Template 
-- Change Log: When,Who,What
-- 2017-08-01,RRoot,Created File
--**************************************************************************--

Print '*** Begin Setup Code ***';
-----------------------------------------------------------------------------------------------------------------------
Begin Try
  Use Master;

  If Exists (
    Select *
    From Sys.Databases
    Where Name = 'Module08Demos'
  )
  Begin
    Alter Database Module08Demos
      Set Single_User With Rollback Immediate;

    Drop Database Module08Demos;
  End;

  Create Database Module08Demos;
End Try
Begin Catch
  Print Error_Message();
End Catch;
Go

Use Module08Demos;
Go

-- Tables STORE data
Create Table dbo.Customers (
  CustomerId int Identity(1,1) Not Null,
  CustomerFirstName nvarchar(100),
  CustomerLastName nvarchar(100),
  CustomerEmail nvarchar(100),
  Constraint pkCustomers Primary Key (CustomerId),
  Constraint uqCustomersEmail Unique (CustomerEmail)
);
Go

-- Seed data
Begin Transaction;

Insert Into dbo.Customers (
  CustomerFirstName,
  CustomerLastName,
  CustomerEmail
)
Values (
  'Bob',
  'Smith',
  'BSmith@MyCo.com'
);

Commit Transaction;
Go

-- View abstraction
Create View vCustomers
As
Select
  CustomerId,
  CustomerFirstName,
  CustomerLastName,
  CustomerEmail
From dbo.Customers;
Go

Select
  CustomerId,
  CustomerFirstName,
  CustomerLastName,
  CustomerEmail
From vCustomers;
Go

Print '*** End Setup Code ***';


Print '*** Stored Procedure Basics ***';
-----------------------------------------------------------------------------------------------------------------------
Create Procedure pAddValues
As
Begin
  Select [Sum] = 1 + 2;
End;
Go

Exec pAddValues;
Exec pAddValues;
pAddValues;
Go

Alter Procedure pAddValues
As
Begin
  Select [Sum] = 2 + 3;
  Print 2 + 4;
End;
Go

Exec pAddValues;
Go

-- Parameters
Alter Procedure pAddValues (
  @Value1 float,
  @Value2 float
)
As
Begin
  Select [Sum] = @Value1 + @Value2;
End;
Go

Exec pAddValues @Value1 = 4, @Value2 = 5;
Exec pAddValues 4, 5;
Go

-- Defaults
Alter Procedure pAddValues (
  @Value1 float = 0,
  @Value2 float = 0
)
As
Begin
  Select [Sum] = @Value1 + @Value2;
End;
Go

Exec pAddValues @Value1 = 5, @Value2 = 3;
Exec pAddValues;
Exec pAddValues @Value1 = 5;
Exec pAddValues @Value2 = 3;
Exec pAddValues @Value1 = 5, @Value2 = Default;
Go

Print '*** Metadata ***';
-----------------------------------------------------------------------------------------------------------------------
Select *
From SysObjects
Where Name = 'pAddValues';

Select *
From SysComments
Where Id = Object_Id('pAddValues');

Exec sp_Help 'pAddValues';
Exec sp_HelpText 'pAddValues';
Go


Print '*** Transaction Stored Procedures ***';
-----------------------------------------------------------------------------------------------------------------------
Alter Procedure pInsCustomers (
  @CustomerFirstName nvarchar(100),
  @CustomerLastName nvarchar(100),
  @CustomerEmail nvarchar(100)
)
As
Begin
  Begin Tran;

  Insert Into dbo.Customers (
    CustomerFirstName,
    CustomerLastName,
    CustomerEmail
  )
  Values (
    @CustomerFirstName,
    @CustomerLastName,
    @CustomerEmail
  );

  Commit Tran;
End;
Go

Exec pInsCustomers
  @CustomerFirstName = 'Sue',
  @CustomerLastName = 'Jones',
  @CustomerEmail = 'SJones@MyCo.com';
Go

Create Procedure pUpdCustomers (
  @CustomerId int,
  @CustomerFirstName nvarchar(100),
  @CustomerLastName nvarchar(100),
  @CustomerEmail nvarchar(100)
)
As
Begin
  Begin Tran;

  Update dbo.Customers
  Set CustomerFirstName = @CustomerFirstName,
      CustomerLastName = @CustomerLastName,
      CustomerEmail = @CustomerEmail
  Where CustomerId = @CustomerId;

  Commit Tran;
End;
Go

Select *
From vCustomers;

Exec pUpdCustomers
  @CustomerId = 2,
  @CustomerFirstName = 'Susan',
  @CustomerLastName = 'Jones',
  @CustomerEmail = 'SJones@MyCo.com';
Go

Create Procedure pDelCustomers (
  @CustomerId int
)
As
Begin
  Begin Tran;

  Delete
  From dbo.Customers
  Where CustomerId = @CustomerId;

  Commit Tran;
End;
Go


Print '*** Abstraction ***';
-----------------------------------------------------------------------------------------------------------------------
Create Procedure pSelCustomers
As
Begin
  Select
    CustomerId,
    CustomerFirstName,
    CustomerLastName,
    CustomerEmail
  From dbo.Customers;
End;
Go

Exec pSelCustomers;
Go

Alter Procedure pSelCustomers (
  @CustomerId int = 0
)
As
Begin
  Select
    CustomerId,
    CustomerFirstName,
    CustomerLastName,
    CustomerEmail
  From dbo.Customers
  Where CustomerId = @CustomerId
     Or @CustomerId = 0;
End;
Go

Exec pSelCustomers;
Exec pSelCustomers @CustomerId = 1;
Go

Deny Select, Insert, Update, Delete
On dbo.Customers
To Public;
Go

-- This forces ALL data access through Views and Stored Procedures
Grant Select On vCustomers To Public;
Grant Exec On pSelCustomers To Public;
Grant Exec On pInsCustomers To Public;
Go


Print '*** Error Handling ***';
-----------------------------------------------------------------------------------------------------------------------
Alter Procedure pInsCustomers (
  @CustomerFirstName nvarchar(100),
  @CustomerLastName nvarchar(100),
  @CustomerEmail nvarchar(100)
)
As
Begin
  Begin Try
    Begin Tran;

    Insert Into dbo.Customers (
      CustomerFirstName,
      CustomerLastName,
      CustomerEmail
    )
    Values (
      @CustomerFirstName,
      @CustomerLastName,
      @CustomerEmail
    );

    If @@TranCount > 0 Commit Tran;
  End Try
  Begin Catch
    If @@TranCount > 0 Rollback Tran;

    Print Error_Number();
    Print Error_Message();
  End Catch;
End;
Go


Print '*** Return Codes ***';
-----------------------------------------------------------------------------------------------------------------------
Alter Procedure pInsCustomers (
  @CustomerFirstName nvarchar(100),
  @CustomerLastName nvarchar(100),
  @CustomerEmail nvarchar(100)
)
As
Begin
  Declare @Rc int = 0;

  Begin Try
    Begin Tran;

    Insert Into dbo.Customers (
      CustomerFirstName,
      CustomerLastName,
      CustomerEmail
    )
    Values (
      @CustomerFirstName,
      @CustomerLastName,
      @CustomerEmail
    );

    If @@TranCount > 0 Commit Tran;

    Set @Rc = +1;
  End Try
  Begin Catch
    If @@TranCount > 0 Rollback Tran;

    Print Error_Number();
    Print Error_Message();

    Set @Rc = -1;
  End Catch;

  Return @Rc;
End;
Go

Declare @Status int;

Exec @Status = pInsCustomers
  @CustomerFirstName = 'Tim',
  @CustomerLastName = 'Thomas',
  @CustomerEmail = 'TThomasz@MyCo.com';

Select [Return Code] = @Status;
Go


Print '*** Template ***';
-----------------------------------------------------------------------------------------------------------------------
Create Procedure <pTrnTableName> (
  <@P1 int = 0>
)
/* Author: <YourNameHere>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2017-01-01>,<Your Name Here>,Created Sproc.
*/
As
Begin
  Declare @Rc int = 0;

  Begin Try
    Begin Transaction;

    -- Transaction Code --

    If @@TranCount > 0 Commit Transaction;

    Set @Rc = +1;
  End Try
  Begin Catch
    If @@TranCount > 0 Rollback Transaction;

    Print Error_Message();

    Set @Rc = -1;
  End Catch;

  Return @Rc;
End;
Go