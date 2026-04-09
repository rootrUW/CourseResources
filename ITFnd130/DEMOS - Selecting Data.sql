--*************************************************************************--
-- Title: SQL Basics
-- Desc:This file highlights some of the most commonly used 
-- SQL Statements; Select, Insert, Update, and Delete
-- Change Log: When,Who,What
-- 2019-06-25,RRoot,Created File
--**************************************************************************--
use Northwind;

'*** Select Statements ***'
-----------------------------------------------------------------------------------------------------------------------
-- The SELECT main clauses are: SELECT, FROM, WHERE
SELECT CustomerID, CompanyName, ContactName 
 FROM Northwind.dbo.Customers  
  WHERE (CustomerID = 'alfki');

-- In most cases, SQL ignores SPACES, TAB, and CARRIAGE RETURNS. 
-- So, you will often see the Select Clause written like this.

SELECT -- Stacking the column listing; easier to read, but takes more space.	
	CustomerID, 
	CompanyName, 
	ContactName 
FROM Northwind.dbo.Customers
WHERE 
	(
	CustomerID = 'alfki' 
	OR 
	CustomerID = 'anatr'
	);

-- It even works like this, but it just does not look professional!.
SELECT	
CustomerID, 
			CompanyName, 
	ContactName 
                   FROM Northwind.dbo.Customers

WHERE 	(
								CustomerID = 'alfki' 
	OR 
CustomerID = 'anatr'	)


-- *** Using the Select Clause ***
-----------------------------------------------------------------------------------------------------------------------
-- This clause lists the columns you want in your result set,
-- even if the column does not exist in the database tables.

Select
  5 + 4,
  5 * 4;

-- (Column Aliases)
Select
  [Sum] = 5 + 4,
  [Product] = 5 * 4;

Use Northwind;
Go

-- Alias in Front style
Select
  [AVG Sales Price] = AVG(UnitPrice)
From [Order Details];

Select
  AVG(UnitPrice) As [AVG Sales Price]
From [Order Details];

Select
  AVG(UnitPrice) [AVG Sales Price]
From [Order Details];

Set Quoted_Identifier Off;

Select
  AVG(UnitPrice) As "AVG Sales Price"
From "Order Details"; -- Error example

-- Recommended
Select
  AVG(UnitPrice) As [AVG Sales Price]
From [Order Details];

Set Quoted_Identifier On;
Go

-- *** Using the From Clause ***
-----------------------------------------------------------------------------------------------------------------------
Select
  ProductName
From dbo.Products;

Select
  CompanyName
From dbo.Customers;

Select
  CompanyName
From Northwind.dbo.Customers;

Use Northwind;
Go

Select
  CompanyName
From Northwind..Customers;

-- Using Joins
Select
  Products.ProductName,
  Categories.CategoryName
From dbo.Products
Inner Join dbo.Categories
  On Products.CategoryId = Categories.CategoryId;

-- Table Aliases
Select
  P.ProductName,
  C.CategoryName
From dbo.Products As P
Inner Join dbo.Categories As C
  On P.CategoryId = C.CategoryId;

-- *** Using the Where Clause ***
-----------------------------------------------------------------------------------------------------------------------
Use Northwind;
Go

Select
  ProductName,
  UnitsInStock
From dbo.Products
Where ProductName = 'Chai';

-- NON ANSI Join
Select
  CompanyName,
  OrderDate
From dbo.Orders,
     dbo.Customers
Where Orders.CustomerId = Customers.CustomerId
  And OrderDate = '8/25/97';

-- ANSI Join
Select Distinct
  Customers.CompanyName,
  Orders.OrderDate
From dbo.Orders
Inner Join dbo.Customers
  On Orders.CustomerId = Customers.CustomerId
Where OrderDate = '8/25/97';

-- Wildcards
Select
  ProductName,
  UnitsInStock
From dbo.Products
Where ProductName Like 'Ch%';

Select
  ProductName,
  UnitsInStock
From dbo.Products
Where ProductName Like 'C_a%';

-- Operators
Select
  ProductName,
  UnitsInStock
From dbo.Products
Where UnitsInStock Between '0' And '35';

Select
  ProductName,
  UnitsInStock
From dbo.Products
Where ProductName Between 'Chai' And 'Chocolade'
Order By ProductName;

Select
  ProductName,
  UnitsInStock
From dbo.Products
Where UnitsInStock In ('0', '17');

Use Northwind;
Go

Select
  ProductId,
  ProductName,
  SupplierId,
  UnitPrice
From dbo.Products
Where ProductName Like 'T%'
  Or (ProductId = 46 And UnitPrice > 16.00);

-- Subquery
Select
  CustomerId,
  CompanyName
From dbo.Customers
Where CustomerId Not In (
  Select CustomerId
  From dbo.Orders
);

-- NULL handling
Select
  CompanyName,
  Fax
From dbo.Suppliers
Where Fax Is Null;

Select
  CompanyName,
  Fax
From dbo.Suppliers
Where Fax = Null; -- This will NEVER return rows 

Set Ansi_Nulls OFF; -- UNLESS you change this setting

If (Null = Null)
  Print 'True';
Else
  Print 'False';

Set Ansi_Nulls ON; -- However, it is recommended you leave it turn ON and always use IS NULL instead


-- *** Using the Order By Clause ***
-----------------------------------------------------------------------------------------------------------------------
Select
  Pub_Id,
  Type,
  Title_Id,
  Price
From Pubs..Titles
Order By
  Pub_Id Desc,
  Type,
  Price;

Select
  Pub_Id,
  Type,
  Title_Id,
  Price
From Pubs..Titles
Order By 2 Desc;

-- *** Aggregate Functions ***
-----------------------------------------------------------------------------------------------------------------------
Use Northwind;
Go

Select
  OrderId,
  CustomerId
From dbo.Orders
Where OrderDate = (
  Select Max(OrderDate)
  From dbo.Orders
);

Select
  ShippedDate
From dbo.Orders;

Select
  Max(ShippedDate)
From dbo.Orders;

Select
  Min(ShippedDate)
From dbo.Orders;

Select
  AVG(Price)
From Pubs.dbo.Titles;

Select
  [Grand Total] = Sum(ytd_sales),
  [Average Sales] = Avg(ytd_sales),
  [Number Of Sales] = Count(ytd_sales),
  [Number Of Entries] = Count(*)
From Pubs.dbo.Titles;

Use Northwind;
Go

Select
  [Custom Average Sales] = Sum(ytd_sales) / Count(*),
  [Standard Average Sales] = Avg(ytd_sales)
From Pubs.dbo.Titles;

-- *** Group By ***
-----------------------------------------------------------------------------------------------------------------------
Use Northwind;
Go

Select
  ProductName,
  Quantity
From [Order Details]
Inner Join dbo.Products
  On [Order Details].ProductId = Products.ProductId
Order By ProductName;

Select
  ProductName,
  Sum(Quantity) As TotalQty
From [Order Details]
Inner Join dbo.Products
  On [Order Details].ProductId = Products.ProductId
Group By ProductName
Order By ProductName;

-- *** Having ***
-----------------------------------------------------------------------------------------------------------------------
Select
  ProductName,
  Sum(Quantity)
From [Order Details]
Inner Join dbo.Products
  On [Order Details].ProductId = Products.ProductId
Where Quantity > 100
Group By ProductName
Having Sum(Quantity) > 200
Order By ProductName;

-- *** Distinct ***
-----------------------------------------------------------------------------------------------------------------------
Select Distinct
  Orders.CustomerId,
  Orders.OrderDate
From dbo.Orders;

-- *** Union ***
-----------------------------------------------------------------------------------------------------------------------
Select
  [Customer Orders] = Count(*),
  [Year] = 'For 1996'
From dbo.Orders
Where Year(OrderDate) = 1996

Union

Select
  Count(*),
  'For 1997'
From dbo.Orders
Where Year(OrderDate) = 1997

Union

Select
  Count(*),
  'For 1998'
From dbo.Orders
Where Year(OrderDate) = 1998;
Go

-- *** Top ***
-----------------------------------------------------------------------------------------------------------------------
Use Northwind;
Go

Select Top (5)
  OrderId,
  ProductId,
  Quantity
From [Order Details]
Order By Quantity Desc;

Select Top (5) With Ties
  OrderId,
  ProductId,
  Quantity
From [Order Details]
Order By Quantity Desc;

-- *** Rollup / Cube ***
-----------------------------------------------------------------------------------------------------------------------
Select
  Title_Id,
  Sum(qty) As Quantity
From Pubs.dbo.Sales
Group By Title_Id With Rollup
Order By Title_Id;

Select
  Stor_Id,
  Title_Id,
  Sum(qty) As Quantity
From Pubs.dbo.Sales
Group By Stor_Id, Title_Id With Cube
Order By 1, 2;

-- *** Functions ***
-----------------------------------------------------------------------------------------------------------------------
Select
  IsNull(Stor_Name, 'All Stores'),
  IsNull(Title, 'All Titles'),
  Sum(qty) As Quantity
From Pubs.dbo.Sales
Inner Join Pubs.dbo.Titles
  On Sales.Title_Id = Titles.Title_Id
Inner Join Pubs.dbo.Stores
  On Sales.Stor_Id = Stores.Stor_Id
Group By Stor_Name, Title With Cube
Order By 1, 2;