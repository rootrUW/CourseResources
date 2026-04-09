--*************************************************************************--
-- Title: Module02
-- Desc: This file demonstrate Typical additions to database tables
--       1) Constraints
--       2) Indexes
--       3) Views
--       4) Stored Procedures
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--

-- 1) Constraints
--****************************************************--
-- SQL Server supports four types of data integrity:
-- Entity integrity, Domain integrity, Referential integrity,
-- and User-Defined integrity (Found in Stored procedures and Triggers).

Create Database CommonOptionsDemoDB;
Go

Use CommonOptionsDemoDB;
Go

Create Table dbo.Demo (
  Col1 int Not Null,
  Col2 int,
  Col3 int,
  Col4 int,
  Col5 int,
  Col6 int Not Null,
  Constraint pkDemo Primary Key (Col1),
  Constraint uqDemoCol2 Unique (Col2),
  Constraint ckDemoCol3 Check (Col3 > 0),
  Constraint fkDemoCol4 Foreign Key (Col4) References dbo.Demo (Col2),
  Constraint dfDemoCol5 Default (0) For Col5
);
Go

Exec sp_Help Demo;
Go

Exec sp_HelpConstraint Demo;
Go

Select *
From sys.default_constraints;

Select *
From sys.check_constraints;

Select *
From sys.key_constraints;

Select *
From sys.foreign_keys;
Go

Select
  Object_Name(Id),
  *
From syscomments;
Go

-- *** Default and Null Constraints ***
Create Table dbo.Products (
  ProductId int Identity(1,1) Not Null,
  ProductName nvarchar(40) Not Null,
  SupplierId int Null,
  UnitPrice money Null,
  UnitsInStock smallint Null,
  Constraint pkProducts Primary Key (ProductId),
  Constraint dfProductsUnitPrice Default (0) For UnitPrice,
  Constraint dfProductsUnitsInStock Default (0) For UnitsInStock
);
Go

Select *
From sys.default_constraints
Where parent_object_id = Object_Id('Products');
Go

-- *** Primary Key Constraints ***
Create Table dbo.Suppliers (
  SupplierId int Not Null,
  ContactId int Not Null,
  Constraint pkSuppliers Primary Key Clustered (SupplierId)
);
Go

Alter Table dbo.Products
Add Constraint pkProductsClustered Primary Key Clustered (ProductId);
Go

-- *** Unique Constraint ***
Alter Table dbo.Suppliers
Add Constraint uqSuppliersContactId Unique Nonclustered (ContactId);
Go

-- *** Foreign Key Constraint ***
Alter Table dbo.Products
Add Constraint fkProductsSuppliers
  Foreign Key (SupplierId)
  References dbo.Suppliers (SupplierId)
  On Update Cascade
  On Delete Cascade;
Go

-- *** Check Constraint ***
Alter Table dbo.Products
Add Constraint ckProductsUnitPrice Check (UnitPrice >= 0);
Go

-- *** Default Constraint ***
Alter Table dbo.Suppliers
Add Constraint dfSuppliersContactId Default (1)
For ContactId;
Go

Exec sp_HelpConstraint Products;
Exec sp_HelpConstraint Suppliers;
Go

-- 2) Indexes
--****************************************************--

-- Heap Example
Create Table dbo.PhoneList (
  Id int,
  Name varchar(50),
  Extension char(5)
);
Go

Insert Into dbo.PhoneList (
  Id,
  Name,
  Extension
)
Values
  (1, 'Bob Smith', '#11'),
  (2, 'Sue Jones', '#12'),
  (3, 'Joe Harris', '#13');
Go

Select *
From dbo.PhoneList;
Go

Delete From dbo.PhoneList
Where Id = 2;
Go

Insert Into dbo.PhoneList (
  Id,
  Name,
  Extension
)
Values (4, 'Tim Thomas', '#14');
Go

Select *
From dbo.PhoneList;
Go

Create Clustered Index ciPhoneListId
On dbo.PhoneList (Id);
Go

Create Nonclustered Index nciPhoneListName
On dbo.PhoneList (Name);
Go

Select *
From dbo.PhoneList;

Select
  Name
From dbo.PhoneList;
Go

Select *
From dbo.PhoneList
Order By Id;

Select *
From dbo.PhoneList
Order By Name;

Select *
From dbo.PhoneList
Where Id = 4;

Select *
From dbo.PhoneList
Where Name = 'Joe Harris';

Select
  Name
From dbo.PhoneList;

Select
  Id,
  Name
From dbo.PhoneList;
Go

-- 3) Views
--****************************************************--

Use Northwind;
Go

Create View vCustomerOrders
As
Select
  Orders.OrderId,
  Customers.CompanyName,
  Customers.ContactName
From Orders
Inner Join Customers
  On Orders.CustomerId = Customers.CustomerId;
Go

Select *
From vCustomerOrders;
Go

Select *
From syscomments
Where id = Object_Id('vCustomerOrders');
Go

Exec sp_HelpText vCustomerOrders;
Go

-- 4) Stored Procedures
--****************************************************--

Use Northwind;
Go

Create Procedure pGetEmployeeData
As
Begin
  Select
    FirstName,
    LastName,
    HireDate
  From Employees;
End;
Go

Exec pGetEmployeeData;
Go

Select *
From syscomments
Where id = Object_Id('pGetEmployeeData');
Go

Exec sp_HelpText 'pGetEmployeeData';
Go