-- To use Regional Sales Database
USE US_Regional_Sales

-- To rename the imported table to Entities
--EXEC sp_rename 'Sheet1$', 'Entities';

-- To view the table
SELECT *
FROM Entities

-- To rename the imported table to Entities
--EXEC sp_rename 'Sheet1$', 'Finances';

-- To view the table
SELECT *
FROM Finances

-- To rename the imported table to Entities
--EXEC sp_rename 'Sheet1$', 'Orders';

-- To view the table
SELECT *
FROM Orders

-- For Sales Overview Dashboard

-- Total Profit Over Time
SELECT O.DeliveryDate, O.[DeliveryDate(Year)], O.[DeliveryDate(Month)], O.[DeliveryDate(Quarter)], F.TotalProfit
FROM Orders O JOIN Finances F ON O.OrderNumber = F.OrderNumber 
ORDER BY O.DeliveryDate;

-- Total Cost Over Time
SELECT O.DeliveryDate, O.[DeliveryDate(Year)], O.[DeliveryDate(Month)], O.[DeliveryDate(Quarter)], (F.UnitCost*O.OrderQuantity) AS TotalCost
FROM Orders O JOIN Finances F ON O.OrderNumber = F.OrderNumber 
ORDER BY O.DeliveryDate;

-- Total Profit by Sales Channels
SELECT E.SalesChannel, SUM(F.TotalProfit) AS TotalProfit
FROM Entities E JOIN Finances F ON E.OrderNumber = F.OrderNumber
GROUP BY E.SalesChannel
ORDER BY TotalProfit DESC;

-- Average Order Quantity by Month
SELECT O.[DeliveryDate(Month)] AS Month, AVG(O.OrderQuantity) AS AvgOrderQuantity
FROM Orders O
GROUP BY O.[DeliveryDate(Month)]
ORDER BY Month;

-- For Product Analysis Dashboard

-- Top 10 Best Selling Products
SELECT TOP 10 E.ProductID, SUM(O.OrderQuantity) AS TotalOrderQuantity
FROM Entities E JOIN Orders O ON E.OrderNumber = O.OrderNumber
GROUP BY E.ProductID
ORDER BY TotalOrderQuantity DESC;

-- Profit Margin by Product
SELECT E.ProductID, (SUM(F.UnitProfit) / SUM(F.UnitCost)) * 100 AS ProfitMargin
FROM Entities E JOIN Finances F ON E.OrderNumber = F.OrderNumber
GROUP BY E.ProductID
ORDER BY ProfitMargin DESC;

-- Profit Contribution by Product Category
SELECT LEFT(LTRIM(RTRIM(E.ProductID)), 4)  AS ProductCategory, SUM(F.UnitProfit) AS TotalProfit
FROM Entities E JOIN Finances F ON E.OrderNumber = F.OrderNumber
GROUP BY LEFT(LTRIM(RTRIM(E.ProductID)), 4) 
ORDER BY TotalProfit DESC;

-- For Customer Insights Dashboard

-- Top 10 Customers with the most orders
SELECT TOP 10 E.CustomerID, COUNT(*) AS OrderCount
FROM Entities E
GROUP BY E.CustomerID
ORDER BY OrderCount DESC;

-- Customer Lifetime Value
SELECT E.CustomerID, SUM(F.TotalProfit) AS CustomerLifetimeValue
FROM Entities E JOIN Finances F ON E.OrderNumber = F.OrderNumber
GROUP BY E.CustomerID
ORDER BY CustomerLifetimeValue DESC;

-- Customer Retention Analysis
WITH CustomerRetention AS (
    SELECT E.CustomerID, DATEPART(YEAR, O.OrderDate) AS Year, O.[DeliveryDate(Month)] AS Month
    FROM Entities E JOIN Orders O ON E.OrderNumber = O.OrderNumber
    GROUP BY E.CustomerID, DATEPART(YEAR, O.OrderDate), O.[DeliveryDate(Month)]
)
SELECT Year, Month, 100.0 * COUNT(*) / (SELECT COUNT(*) FROM CustomerRetention) AS RetentionPercentage
FROM CustomerRetention
GROUP BY Year, Month
ORDER BY Year, Month;

-- For Order Analysis Dashboard

-- Entities by Number of Orders
SELECT E.SalesTeamID, E.CustomerID, E.StoreID, E.ProductID, E.WarehouseCode, O.OrderQuantity
FROM (
    SELECT DISTINCT OrderNumber, SalesTeamID, CustomerID, StoreID, ProductID, WarehouseCode
    FROM Entities
) E
JOIN Orders O ON E.OrderNumber = O.OrderNumber
ORDER BY O.OrderQuantity DESC;

-- Orders Delivered in Each Quarter
SELECT DATEPART(QUARTER, O.DeliveryDate) AS Quarter, COUNT(*) AS OrderCount
FROM Orders O
GROUP BY DATEPART(QUARTER, O.DeliveryDate)
ORDER BY Quarter;

-- Average Daily Order Trends
WITH DailyOrderQuantity AS (
    SELECT CAST(O.OrderDate AS DATE) AS OrderDate, SUM(O.OrderQuantity) AS DailyOrderQuantity
    FROM Orders O
    GROUP BY CAST(O.OrderDate AS DATE)
)
SELECT DOQ.OrderDate, AVG(DOQ.DailyOrderQuantity) AS AvgDailyOrderQuantity
FROM Orders O
JOIN DailyOrderQuantity DOQ ON CAST(O.OrderDate AS DATE) = DOQ.OrderDate
GROUP BY DOQ.OrderDate
ORDER BY DOQ.OrderDate;


-- Late Deliveries by Sales Team
SELECT E.SalesTeamID, COUNT(*) AS LateDeliveries
FROM Entities E JOIN Orders O ON E.OrderNumber = O.OrderNumber
WHERE O.DeliveryDate > O.ShipDate
GROUP BY E.SalesTeamID
ORDER BY LateDeliveries DESC;

-- For Inventory and Procurement Dashboard

-- Total Cost Over Time
SELECT O.DeliveryDate, O.[DeliveryDate(Year)], O.[DeliveryDate(Month)], O.[DeliveryDate(Quarter)], (F.UnitCost*O.OrderQuantity) AS TotalCost
FROM Orders O JOIN Finances F ON O.OrderNumber = F.OrderNumber 
ORDER BY O.DeliveryDate;

-- Inventory Turnover Analysis
WITH InventoryTurnover AS (
    SELECT E.ProductID, AVG(O.OrderQuantity) / DATEDIFF(day, MIN(O.ProcuredDate), MAX(O.OrderDate)) AS TurnoverRatio
    FROM Entities E JOIN Orders O ON E.OrderNumber = O.OrderNumber
    GROUP BY E.ProductID
)
SELECT IT.ProductID, IT.TurnoverRatio
FROM InventoryTurnover IT
ORDER BY TurnoverRatio DESC;

-- Average Lead Time for Products
SELECT E.ProductID, AVG(DATEDIFF(day, O.OrderDate, O.DeliveryDate)) AS AvgLeadTime
FROM Entities E JOIN Orders O ON E.OrderNumber = O.OrderNumber
GROUP BY E.ProductID
ORDER BY AvgLeadTime;
