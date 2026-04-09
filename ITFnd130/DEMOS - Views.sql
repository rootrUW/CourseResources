--*************************************************************************--
-- Title: Module06 
-- Desc: This file demonstrates selecting data using Views 
--       Views vs Tables
--       Views as an Abstraction Layer
--       Views for Reporting
--       Views vs Temp Tables
-- Change Log: When,Who,What
-- 2017-07-28,RRoot,Created File
--**************************************************************************--

-- *** Views vs Tables ***
-----------------------------------------------------------------------------------------------------------------------
Begin Try
  Use Master;

  If Exists (
    Select Name
    From SysDatabases
    Where Name = 'Module06Demos'
  )
  Begin
    Alter Database Module06Demos
      Set Single_User With Rollback Immediate;

    Drop Database Module06Demos;
  End;

  Create Database Module06Demos;
End Try
Begin Catch
  Print Error_Message();
End Catch;
Go

Use Module06Demos;
Go

-- Tables STORE data
Create Table dbo.Categories (
  CategoryId int,
  CategoryName nvarchar(50)
);
Go

Insert Into dbo.Categories
Values
  (1, 'CatA'),
  (2, 'CatB');
Go

Select
  CategoryId,
  CategoryName
From dbo.Categories;
Go

-- Views DISPLAY data
Create View vCategories
As
Select
  CategoryId,
  CategoryName
From dbo.Categories;
Go

Select
  CategoryId,
  CategoryName
From vCategories;
Go

-- Insert THROUGH a view
Insert Into vCategories
Values (3, 'CatC');
Go

Select
  CategoryId,
  CategoryName
From dbo.Categories;

Select
  CategoryId,
  CategoryName
From vCategories;
Go

-- Alter table
Alter Table dbo.Categories
Alter Column CategoryId int Not Null;
Go

Alter Table dbo.Categories
Add Constraint pkCategories
  Primary Key (CategoryId);
Go

-- Alter view
Alter View vCategories
As
Select
  CategoryId,
  CategoryName As CatName
From dbo.Categories;
Go

Select
  CategoryId,
  CategoryName
From dbo.Categories
Order By 1, 2;

Select
  CategoryId,
  CatName
From vCategories
Order By 1, 2;
Go

-- Foreign Keys exist on tables, not views
Create Table dbo.Products (
  ProductId int,
  ProductName nvarchar(50),
  CategoryId int References dbo.Categories (CategoryId)
);
Go

Insert Into dbo.Products
Values
  (1, 'ProdA', 1),
  (2, 'ProdB', 1),
  (3, 'ProdC', 2);
Go

Select
  ProductId,
  ProductName,
  CategoryId
From dbo.Products;
Go

-- View across multiple tables
Create View vProductsByCategory
As
Select
  ProductId,
  ProductName,
  CategoryName
From dbo.Products
Inner Join dbo.Categories
  On Products.CategoryId = Categories.CategoryId;
Go

Select *
From vProductsByCategory;
Go

-- Schema binding
Alter View vCategories
With Schemabinding
As
Select
  CategoryId,
  CategoryName As CatName
From dbo.Categories;
Go

Alter Table dbo.Categories
Add IsDiscontinued int;
Go

Select *
From dbo.Categories;

Select *
From vCategories;
Go

-- *** Views as an Abstraction Layer ***
-----------------------------------------------------------------------------------------------------------------------
Create Table dbo.tblCustomers (
  CustomerId int Identity Primary Key,
  CustomerName nvarchar(100)
);
Go

Insert Into dbo.tblCustomers (CustomerName)
Values
  ('Bob Smith'),
  ('Sue Jones');
Go

Create View Customers
With Schemabinding
As
Select
  CustomerId,
  CustomerName
From dbo.tblCustomers;
Go

Select *
From Customers;
Go

-- Refactor pattern
Drop View Customers;

Select *
Into #TempCustomers
From dbo.tblCustomers;

Drop Table dbo.tblCustomers;

Create Table dbo.tblCustomers (
  CustomerId int Identity Primary Key,
  CustomerFirstName nvarchar(100),
  CustomerLastName nvarchar(100)
);
Go

Insert Into dbo.tblCustomers (
  CustomerFirstName,
  CustomerLastName
)
Select
  Substring(CustomerName, 1, 3),
  Substring(CustomerName, 4, 100)
From #TempCustomers;
Go

Create View Customers
With Schemabinding
As
Select
  CustomerId,
  CustomerFirstName + ' ' + CustomerLastName As CustomerName
From dbo.tblCustomers;
Go

Create View CustomersNormalized
With Schemabinding
As
Select
  CustomerId,
  CustomerFirstName,
  CustomerLastName
From dbo.tblCustomers;
Go

Select *
From dbo.tblCustomers;

Select *
From Customers;

Select *
From CustomersNormalized;
Go

Deny Select On dbo.tblCustomers To Public;
Grant Select On Customers To Public;
Go

-- *** Views for Reporting ***
-----------------------------------------------------------------------------------------------------------------------
Create View vAuthorsByTitles
As
Select
  [Title] = T.Title,
  [Author] = A.Au_Fname + ' ' + A.Au_Lname,
  [Order On Title] = Choose(TA.Au_Ord, '1st', '2nd', '3rd')
From Pubs.dbo.Titles As T
Inner Join Pubs.dbo.TitleAuthor As TA
  On T.Title_Id = TA.Title_Id
Inner Join Pubs.dbo.Authors As A
  On TA.Au_Id = A.Au_Id;
Go

Select *
From vAuthorsByTitles
Order By 1, 3;
Go

-- View with ORDER BY workaround
Alter View vCategories
As
Select Top (1000000000)
  CategoryId,
  CategoryName As CatName
From dbo.Categories
Order By CategoryName;
Go

-- *** Views vs Temp Tables ***
-----------------------------------------------------------------------------------------------------------------------
Create View vCustomerProductOrderSummary
As
Select Top (1000000) -- Required workaround: Views cannot include ORDER BY without TOP
  C.CompanyName,
  P.ProductName,
  [TotalQty] = Sum(OD.Quantity),
  [TotalPrice] = Format(Sum(OD.UnitPrice), 'C', 'en-us'),
  [ExtendedPrice] = Format((Sum(OD.Quantity) * Sum(OD.UnitPrice)), 'C', 'en-us')
From Northwind.dbo.Customers As C
Inner Join Northwind.dbo.Orders As O
  On C.CustomerId = O.CustomerId
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Inner Join Northwind.dbo.Products As P
  On OD.ProductId = P.ProductId
Group By
  P.ProductName,
  P.ProductId,
  C.CompanyName
Order By 1, 2, 3, 4;
Go

Select *
From vCustomerProductOrderSummary;
Go

Select *
Into #CustomerProductOrderSummary
From vCustomerProductOrderSummary;
Go

Select *
From #CustomerProductOrderSummary;
Go

Select *
Into ##CustomerProductOrderSummary
From vCustomerProductOrderSummary;
Go

Select *
From ##CustomerProductOrderSummary;
Go

Select *
Into CustomerProductOrderSummary
From vCustomerProductOrderSummary;
Go

Select *
From CustomerProductOrderSummary;
Go

Drop Table #CustomerProductOrderSummary;
Drop Table ##CustomerProductOrderSummary;
Drop Table CustomerProductOrderSummary;
Go