--*************************************************************************--
-- Title: Module05
-- Desc: This file demonstrates selecting data using Joins and Subqueries
--       1) Inner Joins
--       2) Outer Joins
--       3) Cross Joins
--       4) Self Joins
--       5) Unions
--       6) Subqueries
--       7) Temp Tables
--       8) Common Table Expression
-- Change Log: When,Who,What
-- 2017-07-24,RRoot,Created File
--**************************************************************************--

-- *** Inner Joins ***
-----------------------------------------------------------------------------------------------------------------------
Use Pubs;
Go

Select *
From dbo.Titles;

Select *
From dbo.Sales;
Go

Select
  Title_Id,
  Title
From dbo.Titles
Order By Title_Id;

Select
  Title_Id,
  Ord_Date,
  Qty
From dbo.Sales
Order By Title_Id;
Go

-- NON ANSI
Select
  Titles.Title_Id,
  Title,
  Ord_Date,
  Qty
From dbo.Titles,
     dbo.Sales
Where Titles.Title_Id = Sales.Title_Id;
Go

-- ANSI
Select
  Titles.Title_Id,
  Title,
  Ord_Date,
  Qty
From dbo.Titles
Inner Join dbo.Sales
  On Titles.Title_Id = Sales.Title_Id;
Go

-- Multiple joins
Select
  Stores.Stor_Id,
  Stor_Name,
  Titles.Title_Id,
  Title,
  Ord_Date,
  Qty
From dbo.Titles
Inner Join dbo.Sales
  On Titles.Title_Id = Sales.Title_Id
Inner Join dbo.Stores
  On Sales.Stor_Id = Stores.Stor_Id;
Go

-- Aliases
Select
  St.Stor_Id,
  Stor_Name,
  T.Title_Id,
  Title,
  Ord_Date,
  Qty
From dbo.Titles As T
Inner Join dbo.Sales As S
  On T.Title_Id = S.Title_Id
Inner Join dbo.Stores As St
  On S.Stor_Id = St.Stor_Id;
Go

-- Column aliases
Select
  [Store ID] = St.Stor_Id,
  [Store Name] = Stor_Name,
  [Title ID] = T.Title_Id,
  [Title] = Title,
  [Sales Date] = Ord_Date,
  [Sales Quantity] = Qty
From dbo.Titles As T
Inner Join dbo.Sales As S
  On T.Title_Id = S.Title_Id
Inner Join dbo.Stores As St
  On S.Stor_Id = St.Stor_Id;
Go

-- Bridge table example
Select
  [Author Name] = A.Au_Fname + ' ' + A.Au_Lname,
  [Title] = Title
From dbo.Authors As A
Inner Join dbo.TitleAuthor As TA
  On A.Au_Id = TA.Au_Id
Inner Join dbo.Titles As T
  On T.Title_Id = TA.Title_Id;
Go

-- Multi-hop join
Select
  [Store Name] = Stor_Name,
  [Author Name] = A.Au_Fname + ' ' + A.Au_Lname
From dbo.Authors As A
Inner Join dbo.TitleAuthor As TA
  On A.Au_Id = TA.Au_Id
Inner Join dbo.Titles As T
  On T.Title_Id = TA.Title_Id
Inner Join dbo.Sales As S
  On T.Title_Id = S.Title_Id
Inner Join dbo.Stores As St
  On S.Stor_Id = St.Stor_Id;
Go

-- *** Outer Joins ***
-----------------------------------------------------------------------------------------------------------------------
Select
  Pub_Id,
  Pub_Name
From dbo.Publishers;

Select
  Pub_Id,
  Title
From dbo.Titles;
Go

Select Distinct
  Pub_Id
From dbo.Titles;
Go

Select
  Pub_Id,
  Pub_Name
From dbo.Publishers
Where Pub_Id Not In (
  Select Distinct Pub_Id
  From dbo.Titles
);
Go

Select
  Pub_Name,
  Title
From dbo.Publishers
Left Outer Join dbo.Titles
  On Titles.Pub_Id = Publishers.Pub_Id;

Select
  Pub_Name,
  Title
From dbo.Titles
Right Outer Join dbo.Publishers
  On Titles.Pub_Id = Publishers.Pub_Id;

Select
  Pub_Name,
  Title
From dbo.Titles
Right Outer Join dbo.Publishers
  On Titles.Pub_Id = Publishers.Pub_Id
Where Title Is Null;
Go

-- *** Cross Join ***
-----------------------------------------------------------------------------------------------------------------------
Select
  Pub_Name,
  Title
From dbo.Titles
Cross Join dbo.Publishers;
Go

-- *** Self Join ***
-----------------------------------------------------------------------------------------------------------------------
Use Northwind;
Go

Select *
From dbo.Employees;
Go

Select
  Mgr.EmployeeId,
  Mgr.LastName,
  Emp.EmployeeId,
  Emp.LastName
From dbo.Employees As Emp
Inner Join dbo.Employees As Mgr
  On Emp.ReportsTo = Mgr.EmployeeId
Order By 1, 2, 3, 4;
Go

Select
  [Manager] = IsNull(Mgr.EmployeeId, 0),
  [Employee] = Emp.FirstName + ' ' + Emp.LastName
From dbo.Employees As Emp
Left Join dbo.Employees As Mgr
  On Emp.ReportsTo = Mgr.EmployeeId
Order By IsNull(Mgr.EmployeeId, 0), Emp.EmployeeId;
Go

-- *** Union ***
-----------------------------------------------------------------------------------------------------------------------
Use Pubs;
Go

Select
  Stor_Name,
  Stor_Address,
  City,
  State,
  Zip
From dbo.Stores

Union

Select
  Au_Lname + ' ' + Au_Fname,
  Address,
  City,
  State,
  Zip
From dbo.Authors
Order By 4, 3, 1;
Go

-- *** Subqueries ***
-----------------------------------------------------------------------------------------------------------------------
Select
  [Grand Total] = Sum(Sales.Qty)
From dbo.Sales;

Select
  [State] = State,
  [Total By State] = Sum(Sales.Qty),
  [Grand Total] = (
    Select Sum(Qty)
    From dbo.Sales
  )
From dbo.Sales
Inner Join dbo.Stores
  On Stores.Stor_Id = Sales.Stor_Id
Group By State;
Go

-- *** Temp Tables ***
-----------------------------------------------------------------------------------------------------------------------
Select
  [State] = State,
  [Total By State] = Sum(Sales.Qty)
Into #SalesByState
From dbo.Sales
Inner Join dbo.Stores
  On Stores.Stor_Id = Sales.Stor_Id
Group By State;

If Object_Id('tempdb..#SalesByState') Is Not Null
  Drop Table #SalesByState;
Go

-- *** CTE ***
-----------------------------------------------------------------------------------------------------------------------
With SalesByState As (
  Select
    State,
    Sum(Qty) As TotalQty
  From dbo.Sales
  Inner Join dbo.Stores
    On Stores.Stor_Id = Sales.Stor_Id
  Group By State
)
Select *
From SalesByState;
Go

-- *** Variables ***
-----------------------------------------------------------------------------------------------------------------------
Declare @GrandTotal int;

Select
  @GrandTotal = Sum(Qty)
From dbo.Sales;

Select
  State,
  Sum(Qty) As TotalQty,
  @GrandTotal As GrandTotal
From dbo.Sales
Inner Join dbo.Stores
  On Stores.Stor_Id = Sales.Stor_Id
Group By State;
Go