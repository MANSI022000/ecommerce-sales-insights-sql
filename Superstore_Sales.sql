CREATE DATABASE db_SuperstoreSales
USE db_SuperstoreSales;

SELECT * FROM train;

-- BASIC EXPLORATION
--1. Total number of orders and total sales
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders , Sum(Sales) AS Total_Sales
FROM train;

--2. Unique values in each categorical column (e.g., Region, Segment, Ship Mode)
-- Unique values in Region
SELECT DISTINCT Region AS Unique_Region
FROM train;

-- Unique values in Segment
SELECT DISTINCT Segment AS Unique_Segment
FROM train;

-- Unique values in Ship Mode
SELECT DISTINCT [Ship_Mode] AS Unique_Ship_Mode
FROM train;

--3. Top 10 most sold products
SELECT TOP 10 Product_Name, COUNT(Product_ID) FROM train
GROUP BY Product_Name
ORDER BY COUNT(Product_ID) DESC;

-- SALES & PROFIT ANALYSIS
--4. Total sales by region
SELECT Region, SUM(Sales) AS "Total Sales"
FROM train
GROUP BY Region;

--5. Total sales and quantity by category and sub-category?
--Category
SELECT Category, SUM(Sales) AS "Total Sales", COUNT(Product_ID) AS "Quantity"
FROM train
Group BY Category;

--Sub_Category
SELECT Sub_Category, SUM(Sales) AS "Total Sales", COUNT(Product_ID) AS "Quantity"
FROM train
Group BY Sub_Category;

--6. 10 products which have the highest quantities sold
SELECT TOP 10 Product_Name, COUNT(Product_Name) AS "Quantity Sold"
FROM train
Group by Product_Name
Order BY COUNT(Product_Name) DESC;

--CUSTOMER INSIGHTS
--7. Top 10 customers by Total Sales
SELECT TOP 10 Customer_Name, ROUND(SUM(Sales),2) AS "Total Sales"
FROM train
GROUP BY Customer_Name
ORDER BY SUM(Sales) DESC;

--8. Average order value per customer
SELECT Customer_Name, ROUND(SUM(Sales)/COUNT(DISTINCT Order_ID),2) AS "AVG ORD / Customer"
FROM train
GROUP BY Customer_Name;

--9. How many unique customers are there?
SELECT COUNT(DISTINCT Customer_Name) AS "Unique Customer"
FROM train

--TIME BASED ANALYSIS
--10. Monthly total sales trends
SELECT FORMAT(Order_Date, 'yyyy-MM') AS "Month", ROUND(SUM(Sales),2) AS "Sales"
FROM train
Group By FORMAT(Order_Date, 'yyyy-MM')
ORDER BY FORMAT(Order_Date, 'yyyy-MM');

--11. Which months see the highest number of orders?
SELECT TOP 1 FORMAT(Order_Date, 'yyyy-MM') AS "Month"
FROM train
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY COUNT(Order_ID) DESC;

--12. Average sales per order over time
SELECT FORMAT(Order_Date, 'yyyy-MM') AS Month, SUM(Sales) / COUNT(DISTINCT Order_ID) AS Avg_Sales_Per_Order
FROM train
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month;

--ADVANCED SQL (CASE, WINDOW FUNCTIONS)
--13. Ranking all products by total sales
SELECT Product_Name, SUM(Sales) AS Total_Sales,
    DENSE_RANK() OVER (ORDER BY SUM(Sales) DESC) AS Sales_Rank
FROM train
GROUP BY Product_Name
ORDER BY Sales_Rank;

--14. Creating sales tiers (Low, Medium, High) using CASE based on total sales per order
SELECT Order_ID, SUM(Sales) AS Total_Order_Sales,
    CASE 
        WHEN SUM(Sales) < 54.49 THEN 'Low'
        WHEN SUM(Sales) = 54.49 THEN 'Medium'
        ELSE 'High'
    END AS Sales_Tier
FROM train
GROUP BY Order_ID;

--15. Running total of sales over time (month/year)
SELECT  
    CAST(YEAR(Order_Date) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(Order_Date) AS VARCHAR(2)),2) AS YearMonth,
    SUM(Sales) AS MonthlySales,
    SUM( SUM(Sales)) OVER (ORDER BY CAST(YEAR(Order_Date) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(Order_Date) AS VARCHAR(2)),2)) AS Running_Total
FROM train
GROUP BY Year(Order_date), Month(Order_Date)
ORDER BY MonthlySales; 

--16. What % of total sales does each region contribute?
SELECT Region, SUM(Sales) AS Region_Sales,
    ROUND(SUM(Sales)*100/
        (SELECT SUM(Sales) FROM train),2) AS "Percentage of total"
FROM train
GROUP BY Region;

--17. Which sub-categories have the most consistent sales volume?
SELECT Sub_Category, ROUND(STDEV(Sum_Sales),2) AS SD
FROM(
    SELECT Sub_Category,
    CAST(YEAR(Order_Date) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(Month(Order_Date) AS VARCHAR(2)),2) AS YearMonth,
    ROUND(SUM(Sales),2) AS Sum_Sales
    FROM train
    GROUP BY Sub_Category, YEAR(Order_date), Month(Order_Date)
    ) AS MonthlySales
GROUP BY Sub_Category
ORDER BY SD;

--SHIPPING PERFORMANCE
--18. Average Shipping time
SELECT 
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS Average_Shipping_Time
FROM train;

--19. Which region has the longest average shipping time?
SELECT Region, 
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS Average_Shipping_Time
FROM train
GROUP BY Region
ORDER BY Average_Shipping_Time DESC;

--20. Which Ship Mode is most frequently used?
SELECT TOP 1 Ship_Mode, COUNT(Ship_Mode) AS Number_of_times_Used
FROM train
GROUP BY Ship_Mode
ORDER BY Number_of_times_Used DESC;


