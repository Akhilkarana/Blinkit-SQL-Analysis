SELECT * FROM Blinkit_data
SELECT COUNT(*) FROM Blinkit_data


-- DATA CLEANING
UPDATE Blinkit_data
SET Item_Fat_Content = 
CASE 
WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END

SELECT DISTINCT Item_Fat_Content FROM Blinkit_data


-- A. KPI's
-- 1. TOTAL SALES
SELECT CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million
FROM Blinkit_data
-- 2. AVERAGE SALES
SELECT CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales
FROM Blinkit_data
-- 3. NO OF ITEMS
SELECT COUNT(*) AS No_of_Orders
FROM Blinkit_data
-- 4. AVERAGE RATING
SELECT CAST(AVG(Rating) AS DECIMAL (10,1)) AS Avg_Rating
FROM Blinkit_data


-- B. GRANULAR REQUIREMENTS
-- 1. TOTAL SALES BY FAT CONTENT
SELECT Item_Fat_Content, CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales
FROM Blinkit_data
GROUP BY Item_Fat_Content
-- 2. TOTAL SALES BY ITEM TYPE
SELECT Item_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC
-- 3. FAT CONTENT BY OUTLET FOR TOTAL SALES
SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM Blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type
-- 4. TOTAL SALES BY OUTLET ESTABLISHMENT
SELECT Outlet_Establishment_Year, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM Blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year
-- 5. PERCENTAGE OF SALES BY OUTLET SIZE
SELECT Outlet_Size, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM Blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC
-- 6. SALES BY OUTLET LOCATION
SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM Blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC
-- 7. ALL METRICS BY OUTLET TYPE
SELECT Outlet_Type, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
COUNT(*) AS No_Of_Items,
CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM Blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC











