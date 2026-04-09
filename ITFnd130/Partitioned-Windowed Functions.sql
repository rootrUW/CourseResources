--*************************************************************************--
-- Title: Partitioned Windowed Functions
-- Desc: This script shows examples of partitioned (windowed) functions
-- Change Log: When,Who,What
-- 2030-01-01,RRoot,Created Script
--**************************************************************************--

-- *** Group By Example ***
-----------------------------------------------------------------------------------------------------------------------
Select
  Stor_Id,
  [Store Min Was] = Min(Qty),
  [Store Max Was] = Max(Qty)
From Pubs.dbo.Sales
Group By Stor_Id
Order By Stor_Id;
Go

-- Adding Qty breaks grouping logic
Select
  Stor_Id,
  Qty,
  [Store Min Was] = Min(Qty),
  [Store Max Was] = Max(Qty)
From Pubs.dbo.Sales
Group By Stor_Id, Qty
Order By Stor_Id;
Go

-- *** Window Functions (Partition By) ***
-----------------------------------------------------------------------------------------------------------------------
Select
  Stor_Id,
  Qty,
  [Store Min Was] = Min(Qty) Over (Partition By Stor_Id),
  [Store Max Was] = Max(Qty) Over (Partition By Stor_Id)
From Pubs.dbo.Sales
Order By Stor_Id;
Go

-- Equivalent to Group By when partition matches all columns
Select
  Stor_Id,
  Qty,
  [Store Min Was] = Min(Qty) Over (Partition By Stor_Id, Qty),
  [Store Max Was] = Max(Qty) Over (Partition By Stor_Id, Qty)
From Pubs.dbo.Sales
Order By Stor_Id;
Go

-- *** Percentage Calculations ***
-----------------------------------------------------------------------------------------------------------------------
Select
  [SortColumn] = 'a',
  [Result] = (3 / 9)
Union
Select 'b', (3 * 100 / 9)
Union
Select 'c', Cast((3 * 100 / 9) As float)
Union
Select 'd', (1.0 * 3 * 100 / 9)
Union
Select 'e', (1.0 * 12 * 100 / 706)
Order By SortColumn;
Go

Select
  Stor_Id,
  Title_Id,
  [QtyByStore] = Sum(Qty) Over (Partition By Stor_Id),
  [QtyByStoreAndTitle] = Sum(Qty) Over (Partition By Title_Id, Stor_Id),
  [Title Percent Per Store] =
    Cast(
      (1.0 * Sum(Qty) Over (Partition By Title_Id, Stor_Id) * 100)
      / Sum(Qty) Over (Partition By Stor_Id)
      As decimal(10,2)
    )
From Pubs.dbo.Sales
Order By Stor_Id;
Go

-- *** Ranking Functions ***
-----------------------------------------------------------------------------------------------------------------------
Select
  O.OrderId,
  O.CustomerId,
  OD.Quantity,
  Row_Number() Over (Order By OD.Quantity) As RowNum,
  Rank() Over (Order By OD.Quantity) As RankValue,
  Dense_Rank() Over (Order By OD.Quantity) As DenseRank,
  NTile(2) Over (Order By OD.Quantity) As NTileValue
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Where CustomerId = 'ALFKI'
Order By OD.Quantity;
Go

-- *** Lead / Lag ***
-----------------------------------------------------------------------------------------------------------------------
-- Following year
Select
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity),
  [FollowingYearlyTotalQty] =
    Lead(Sum(Quantity)) Over (Order By Year(OrderDate))
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Group By Year(OrderDate);
Go

-- Previous year
Select
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity),
  [PreviousYearlyTotalQty] =
    Lag(Sum(Quantity)) Over (Order By Year(OrderDate))
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Group By Year(OrderDate);
Go

-- *** Reporting View ***
-----------------------------------------------------------------------------------------------------------------------
Use TempDb;
Go

Create View vPreviousYearsTotals
As
Select
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity),
  [BadPreviousYearlyTotalQty] =
    IsNull(
      Lag(Sum(Quantity)) Over (Order By Year(OrderDate)),
      0
    )
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Group By Year(OrderDate);
Go

-- Test the view
Select
  OrderYear,
  YearlyTotalQty,
  PreviousYearlyTotalQty
From vPreviousYearsTotals;
Go

-- KPI Example
Select
  OrderYear,
  YearlyTotalQty,
  PreviousYearlyTotalQty,
  [Percentage] =
    Str(
      Iif(
        PreviousYearlyTotalQty != 0,
        (1.0 * PreviousYearlyTotalQty * 100) / YearlyTotalQty,
        100
      ),
      5,
      2
    )
From vPreviousYearsTotals;
Go

-- *** Functions for Reporting Pattern ***
-----------------------------------------------------------------------------------------------------------------------
Select Distinct
  OrderDate
From Northwind.dbo.Orders;

Select Distinct
  [OrderYear] = Year(OrderDate)
From Northwind.dbo.Orders;

Select
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity)
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Group By Year(OrderDate);

Select
  ProductName,
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity),
  [PreviousYearlyTotalQty] =
    Iif(
      Year(OrderDate) = 1996,
      0,
      Lag(Sum(Quantity)) Over (Order By ProductName, Year(OrderDate))
    ),
  [BadPreviousYearlyTotalQty] =
    IsNull(
      Lag(Sum(Quantity)) Over (Order By ProductName, Year(OrderDate)),
      0
    )
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Inner Join Northwind.dbo.Products As P
  On OD.ProductId = P.ProductId
Group By ProductName, Year(OrderDate);
Go

-- Final reporting view
Create View vProductOrderQtyByYear
As
Select
  ProductName,
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity),
  [PreviousYearlyTotalQty] =
    Iif(
      Year(OrderDate) = 1996,
      0,
      Lag(Sum(Quantity)) Over (Order By ProductName, Year(OrderDate))
    )
From Northwind.dbo.Orders As O
Inner Join Northwind.dbo.[Order Details] As OD
  On O.OrderId = OD.OrderId
Inner Join Northwind.dbo.Products As P
  On OD.ProductId = P.ProductId
Group By ProductName, Year(OrderDate);
Go

-- KPI usage
Select
  ProductName,
  OrderYear,
  YearlyTotalQty,
  PreviousYearlyTotalQty,
  [QtyChangeKpi] =
    Case
      When YearlyTotalQty > PreviousYearlyTotalQty Then 1
      When YearlyTotalQty = PreviousYearlyTotalQty Then 0
      When YearlyTotalQty < PreviousYearlyTotalQty Then -1
    End
From vProductOrderQtyByYear;
Go