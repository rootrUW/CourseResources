--*************************************************************************--
-- Title: Creating Databases and Normalization
-- Desc: This file details common aspects creating database with using
-- the rules of Normalization
-- Change Log: When,Who,What
-- 2017.01.01,RRoot,Created File
--**************************************************************************--

-- [Data Design]
/*
The design of a relational database involves dividing data into 
individual "atomic" values.

"Bob Smith 206.444.1111, Sue Jones 206.999.1234" 

Becomes...
"Bob", "Smith", "206.444.1111"
"Sue", "Jones", "206.999.1234"

It is then named...
"FirstName": "Bob"  "LastName": "Smith"  "PhoneNumber": "206.444.1111"
"FirstName": "Sue"  "LastName": "Jones"  "PhoneNumber": "206.999.1234"

Next, it is grouped into collections...
{ "FirstName": "Bob", "LastName": "Smith", "PhoneNumber": "206.444.1111" }
{ "FirstName": "Sue", "LastName": "Jones", "PhoneNumber": "206.999.1234" }

These collections can be considered tuples (rows), and each row needs to be 
a unique combination of values.

Finally, rows are then collected into relations (tables) so that data can easily be located and viewed:
Persons: [
{ "FirstName": "Bob", "LastName": "Smith", "PhoneNumber": "206.444.1111" }
{ "FirstName": "Sue", "LastName": "Jones", "PhoneNumber": "206.999.1234" }
]
*/

-- [Common SQL Statements]
/*
Most of the time, you program relational databases using the 
Structured Query Language (SQL). The most common SQL programming 
statements are Create, Select, Insert, Update, and Delete.
*/

Create Database Lab01RRoot;
Go

Use Lab01RRoot;
Go

Create Table dbo.Products (
  ProductId int,
  ProductName varchar(100),
  ProductPrice money
);
Go

Insert Into dbo.Products (
  ProductId,
  ProductName,
  ProductPrice
)
Values (
  1,
  'ProdA',
  9.99
);
Go

Select
  ProductId,
  ProductName,
  ProductPrice
From dbo.Products;
Go

Update dbo.Products
Set ProductPrice = 19.99
Where ProductId = 1;
Go

Select
  ProductId,
  ProductName,
  ProductPrice
From dbo.Products;
Go

Delete From dbo.Products
Where ProductId = 1;
Go

Select
  ProductId,
  ProductName,
  ProductPrice
From dbo.Products;
Go

Create Database NormalizationDB;
Go

Use NormalizationDB;
Go

-- *** All Table should be about only one Subject or Event ***
Create Table dbo.CustomersProducts (
  CustomerName varchar(50) Null,
  CustomerPhone varchar(50) Null,
  ProductName varchar(50) Null,
  Price varchar(50) Null
);
Go

Insert Into dbo.CustomersProducts
Values (
  'Bob Smith',
  '555-1212',
  'Chia Pet',
  '$9.99'
);
Go

Select *
From dbo.CustomersProducts;
Go

Drop Table dbo.CustomersProducts;
Go

-- Better Design
Create Table dbo.Customers (
  CustomerName varchar(50) Null,
  CustomerPhone varchar(50) Null
);
Go

Create Table dbo.Products (
  ProductName varchar(50) Null,
  ProductPrice varchar(50) Null
);
Go

Insert Into dbo.Customers
Values (
  'Bob Smith',
  '555-8888'
);
Go

Insert Into dbo.Products
Values (
  'Chia Pet',
  '$9.99'
);
Go

Select *
From dbo.Customers;

Select *
From dbo.Products;
Go

-- *** Primary Keys ***
Drop Table dbo.Customers;
Drop Table dbo.Products;
Go

Create Table dbo.Customers (
  CustomerId int Not Null,
  CustomerName varchar(50) Null,
  CustomerPhone varchar(50) Null,
  Constraint pkCustomers Primary Key (CustomerId)
);
Go

Create Table dbo.Products (
  ProductId int Not Null,
  ProductName varchar(50) Null,
  ProductPrice varchar(50) Null,
  Constraint pkProducts Primary Key (ProductId)
);
Go

Insert Into dbo.Customers
Values (1, 'Bob Smith', '555-1212');
Go

Insert Into dbo.Products
Values (100, 'Chia Pet', '$9.99');
Go

Select *
From dbo.Customers;

Select *
From dbo.Products;
Go

-- *** Atomic Columns ***
Drop Table dbo.Customers;
Go

Create Table dbo.Customers (
  CustomerId int Not Null,
  CustomerName varchar(50),
  CustomerPhone varchar(50),
  CustomerAddress varchar(200),
  Constraint pkCustomers Primary Key (CustomerId)
);
Go

Insert Into dbo.Customers
Values (
  1,
  'Bob Smith',
  '555-1212',
  '123 Main, Bellevue, WA, 98223'
);
Go

Select *
From dbo.Customers;
Go

Drop Table dbo.Customers;
Go

Create Table dbo.Customers (
  CustomerId int Not Null,
  FirstName varchar(50),
  LastName varchar(50),
  Phone varchar(50),
  Address varchar(100),
  City varchar(50),
  State char(2),
  Zip char(5),
  Constraint pkCustomers Primary Key (CustomerId)
);
Go

Insert Into dbo.Customers
Values (
  1,
  'Bob',
  'Smith',
  '555-1212',
  '123 Main',
  'Bellevue',
  'WA',
  '98223'
);
Go

Select *
From dbo.Customers;
Go

-- *** Multi-Valued Fields ***
Create Table dbo.BadDesignSales (
  SalesId int Not Null,
  CustomerId int,
  ProductId varchar(50) Null,
  Qty varchar(50) Null,
  Constraint pkBadDesignSales Primary Key (SalesId)
);
Go

Insert Into dbo.BadDesignSales
Values (
  1001,
  1,
  '100, 101, 102',
  '2, 5, 3'
);
Go

Select *
From dbo.Customers;

Select *
From dbo.BadDesignSales;

Select *
From dbo.Products;
Go

Drop Table dbo.BadDesignSales;
Go

Create Table dbo.Sales (
  SalesId int Not Null,
  CustomerId int,
  Constraint pkSales Primary Key (SalesId)
);
Go

Create Table dbo.SalesLineItems (
  SalesId int,
  LineItemId int,
  ProductId int,
  Qty int,
  Constraint pkSalesLineItems Primary Key (SalesId, LineItemId)
);
Go

Insert Into dbo.Sales
Values (1001, 1);
Go

Insert Into dbo.SalesLineItems
Values
  (1001, 1, 100, 2),
  (1001, 2, 101, 5),
  (1001, 3, 102, 3);
Go

Select *
From dbo.Customers;

Select *
From dbo.Sales;

Select *
From dbo.SalesLineItems;

Select *
From dbo.Products;
Go