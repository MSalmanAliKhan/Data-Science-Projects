-- To use Regional Sales Database
USE US_Regional_Sales; 

-- Creating the Entities Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Entities' AND xtype='U')

CREATE TABLE Entities(
    [OrderNumber] varchar(12)  NOT NULL ,
    [SalesChannel] varchar(15)  NOT NULL ,
    [WarehouseCode] varchar(12)  NOT NULL ,
    [SalesTeamID] varchar(4)  NOT NULL ,
    [CustomerID] varchar(4)  NOT NULL ,
    [StoreID] varchar(5)  NOT NULL ,
    [ProductID] varchar(4)  NOT NULL ,
    CONSTRAINT [PK_Entities] PRIMARY KEY CLUSTERED (
        [OrderNumber] ASC
    )
)

-- Creating the Orders Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')

CREATE TABLE Orders(
    [OrderNumber] varchar(12)  NOT NULL ,
    [ProcuredDate] date  NOT NULL ,
    [OrderDate] date  NOT NULL ,
    [ShipDate] date  NOT NULL ,
    [DeliveryDate] date  NOT NULL ,
    [OrderQuantity] int  NOT NULL ,
    [OrderAndDeliveryDifference] int  NOT NULL ,
    [ProcurementAndOrderDIfference] int  NOT NULL ,
    [DeliveryDate(Year)] int  NOT NULL ,
    [DeliveryDate(Quarter)] varchar(4)  NOT NULL ,
    [DeliveryDate(MonthIndex)] int  NOT NULL ,
    [DeliveryDate(Month)] varchar(3)  NOT NULL ,
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED (
        [OrderNumber] ASC
    )
)

-- Creating the Finances Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Finances' AND xtype='U')

CREATE TABLE Finances (
    [OrderNumber] varchar(12)  NOT NULL ,
    [DiscountApplied] float  NOT NULL ,
    [UnitCost] float  NOT NULL ,
    [UnitPrice] float  NOT NULL ,
    [UnitProfit] float  NOT NULL ,
    [TotalProfit] float  NOT NULL ,
    CONSTRAINT [PK_Finances] PRIMARY KEY CLUSTERED (
        [OrderNumber] ASC
    )
)

-- Connecting  Entities and Orders Table
ALTER TABLE Entities WITH CHECK ADD CONSTRAINT [FK_Entities_OrderNumber] FOREIGN KEY([OrderNumber])
REFERENCES Orders ([OrderNumber])

ALTER TABLE Entities CHECK CONSTRAINT [FK_Entities_OrderNumber]

-- Connecting  Finances and Orders Table
ALTER TABLE Orders WITH CHECK ADD CONSTRAINT [FK_Orders_OrderNumber] FOREIGN KEY([OrderNumber])
REFERENCES Finances ([OrderNumber])

ALTER TABLE Orders CHECK CONSTRAINT [FK_Orders_OrderNumber]

