--*************************************************************************--
-- Title: Module07 
-- Desc: This file demonstrates selecting data using Functions 
--       Built-in Functions
--       User Defined Functions 
--       Functions vs Views 
--       Functions for Reporting
--       Functions for ETL Processing
-- Change Log: When,Who,What
-- 2017-08-01,RRoot,Created File
--**************************************************************************--

Print '*** Setup Code ***';
-----------------------------------------------------------------------------------------------------------------------
Begin Try
  Use Master;

  If DB_Id('Module07Demos') Is Not Null
  Begin
    Alter Database Module07Demos
      Set Single_User With Rollback Immediate;

    Drop Database Module07Demos;
  End;

  Create Database Module07Demos;
End Try
Begin Catch
  Print Error_Message();
End Catch;
Go

Use Module07Demos;
Go

-- Views to DISPLAY data
Create View vCategories
As
Select
  CategoryId,
  CategoryName
From Northwind.dbo.Categories;
Go

Create View vProducts
As
Select
  ProductId,
  ProductName,
  CurrentPrice = UnitPrice,
  CategoryId
From Northwind.dbo.Products;
Go

Create View vOrderDetails
As
Select
  OrderId,
  ProductId,
  UnitPrice,
  Quantity
From Northwind.dbo.[Order Details];
Go

Create View vOrders
As
Select
  OrderId,
  CustomerId,
  OrderDate,
  RequiredDate,
  ShippedDate
From Northwind.dbo.Orders;
Go

Print '*** Built-in Functions ***';
-----------------------------------------------------------------------------------------------------------------------
Select
  GetDate(),
  IsNull(Null, 0);

Select
  GetDate(),
  IsNull(CurrentPrice, 0),
  ProductName
From vProducts;
Go

Select
  Cast(GetDate() As date),
  IsNull(CurrentPrice, 0),
  IsNull(Cast(CurrentPrice As varchar(50)), 'Not For Sale!'),
  ProductName
From vProducts
Order By 3;
Go

-- Conversions
Select
  Cast('1' As int),
  Cast('1' As decimal(3,2)),
  Cast(1 As nvarchar(50));

Select
  Convert(int, '1'),
  Convert(decimal(3,2), '1'),
  Convert(nvarchar(50), 1);
Go

-- Convert formatting
Select
  [Simple Cast] = Cast(GetDate() As date),
  [Simple Convert] = Convert(date, GetDate()),
  [US Slash] = Convert(varchar(50), GetDate(), 101),
  [US Dash] = Convert(varchar(50), GetDate(), 110),
  [ANSI] = Convert(varchar(50), GetDate(), 112);
Go

-- Logical
Select Iif(5 = 5, 'T', 'F');

Select
  ProductName,
  [Category] = Choose(CategoryId, 'A', 'B', 'C')
From vProducts;
Go

Select
  ProductName,
  [Category] =
    Case CategoryId
      When 1 Then 'A'
      When 2 Then 'B'
      When 3 Then 'C'
    End
From vProducts;
Go

-- String functions
Select Upper('Test'), Lower('Test');
Go

Select Substring('Test', 2, 2), PatIndex('%s%', 'Test');
Go

-- Aggregate
Select
  ProductId,
  [Sum] = Sum(Quantity),
  [Max] = Max(Quantity),
  [Min] = Min(Quantity),
  [Avg] = Avg(Quantity),
  [Count] = Count(Quantity)
From vOrderDetails
Group By ProductId;
Go

-- Date functions
Declare @Date datetime = GetDate();

Select
  [IsDate] = IsDate(@Date),
  [DateName] = DateName(mm, @Date),
  [DateAdd] = DateAdd(mm, 1, @Date),
  [DateDiff] = DateDiff(yy, '20000101', @Date);
Go

Print '*** User Defined Functions ***';
-----------------------------------------------------------------------------------------------------------------------

-- Scalar
Create Function dbo.AddValues (
  @Value1 float,
  @Value2 float
)
Returns float
As
Begin
  Return (@Value1 + @Value2);
End;
Go

Select dbo.AddValues(4, 5);
Go

-- Inline table function
Create Function dbo.ArithmeticValues (
  @Value1 float,
  @Value2 float
)
Returns Table
As
Return (
  Select
    [Sum] = @Value1 + @Value2,
    [Difference] = @Value1 - @Value2,
    [Product] = @Value1 * @Value2,
    [Quotient] = @Value1 / @Value2
);
Go

Select *
From dbo.ArithmeticValues(4, 5);
Go

-- Multi-statement function
Create Function dbo.fArithmeticValuesWithFormat (
  @Value1 float,
  @Value2 float,
  @FormatAs char(1)
)
Returns @Results Table (
  [Sum] sql_variant,
  [Difference] sql_variant,
  [Product] sql_variant,
  [Quotient] sql_variant
)
As
Begin
  If @FormatAs = 'f'
    Insert Into @Results
    Select
      Cast(@Value1 + @Value2 As float),
      Cast(@Value1 - @Value2 As float),
      Cast(@Value1 * @Value2 As float),
      Cast(@Value1 / @Value2 As float);

  Return;
End;
Go

Select *
From dbo.fArithmeticValuesWithFormat(10, 3, 'f');
Go

Print '*** Functions vs Views ***';
-----------------------------------------------------------------------------------------------------------------------

Create Function fProducts()
Returns Table
As
Return (
  Select
    ProductId,
    ProductName,
    CategoryId
  From Northwind.dbo.Products
);
Go

Select *
From fProducts();
Go

Print '*** Functions for Reporting ***';
-----------------------------------------------------------------------------------------------------------------------

Select
  ProductName,
  [OrderYear] = Year(OrderDate),
  [YearlyTotalQty] = Sum(Quantity)
From vOrders As O
Inner Join vOrderDetails As OD
  On O.OrderId = OD.OrderId
Inner Join vProducts As P
  On OD.ProductId = P.ProductId
Group By ProductName, Year(OrderDate);
Go

Print '*** Functions for ETL Processing ***';
-----------------------------------------------------------------------------------------------------------------------

Create Table dbo.StagingForCustomers (
  Name varchar(100),
  Phone varchar(100)
);
Go

Insert Into dbo.StagingForCustomers
Values
  ('Bob Smith', '(206)555-1212'),
  ('Sue Jones', '(425)123-4567');
Go

Create Function dbo.fGetFirstName (@Name varchar(100))
Returns nvarchar(50)
As
Begin
  Return Substring(@Name, 1, CharIndex(' ', @Name));
End;
Go

Create Table dbo.Customers (
  CustomerId int Identity Primary Key,
  CustomerFirstName nvarchar(100),
  CustomerLastName nvarchar(100),
  PhoneAreaCode nvarchar(50),
  PhoneNumber nvarchar(100)
);
Go

Insert Into dbo.Customers (
  CustomerFirstName,
  CustomerLastName
)
Select
  dbo.fGetFirstName(Name),
  Name
From dbo.StagingForCustomers;
Go

Select *
From dbo.Customers;
Go