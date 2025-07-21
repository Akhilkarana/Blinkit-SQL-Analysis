# Blinkit Sales Performance Analysis

## Overview

This project conducts a comprehensive analysis of Blinkit's sales performance, customer satisfaction, and inventory distribution. The goal is to identify key insights and opportunities for optimization using various Key Performance Indicators (KPIs) and visualizations. The analysis is performed using SQL for data cleaning and aggregation, with the intention of creating interactive dashboards in Power BI.

## Business Requirements

The primary business requirement is to conduct a comprehensive analysis of Blinkit's sales performance, customer satisfaction, and inventory distribution to identify key insights and opportunities for optimization using various KPIs and visualizations in Power BI.

## Key Performance Indicator (KPI) Requirements

The following KPIs were identified for this analysis:

  **Total Sales**: The overall revenue generated from all items sold.
  **Average Sales**: The average revenue per sale.
  **Number of Items**: The total count of different items sold (or number of orders).
  **Average Rating**: The average customer rating for items sold.

## Granular Requirements

To gain deeper insights, the analysis focuses on the following granular requirements:

1.  **Total Sales by Fat Content**:
      **Objective**: Analyze the impact of fat content on total sales.
      **Additional KPI Metrics**: Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.
2.  **Total Sales by Item Type**:
      **Objective**: Identify the performance of different item types in terms of total sales.
      **Additional KPI Metrics**: Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with item type.
3.  **Fat Content by Outlet for Total Sales**:
      **Objective**: Compare total sales across different outlets segmented by fat content.
      **Additional KPI Metrics**: Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content for each outlet.
4.  **Total Sales by Outlet Establishment Year**:
      **Objective**: Evaluate how the age of the outlet influences total sales.

## Chart Requirements

Visualizations will be created to represent the following:

1.  **Percentage of Sales by Outlet Size**:
      **Objective**: Analyze the correlation between outlet size and total sales.
2.  **Sales by Outlet Location**:
      **Objective**: Assess the geographic distribution of sales across different locations.
3.  **All Metrics by Outlet Type**:
      **Objective**: Provide a comprehensive view of all key metrics (Total Sales, Average Sales, Number of Items, Average Rating) broken down by different outlet types.

## Data Source

The analysis uses the `BlinkIT Grocery Data.csv` dataset, which contains detailed information about Blinkit's sales.

## SQL Queries

The `Blinkit SQL.sql` file contains all the SQL queries used for data cleaning, KPI calculation, and granular analysis.

### Data Cleaning

The `Item_Fat_Content` field had inconsistent values (e.g., 'LF', 'low fat', 'reg' instead of 'Low Fat' and 'Regular').The following `UPDATE` statement was used to standardize these values:

```sql
UPDATE Blinkit_data
SET Item_Fat_Content = 
CASE 
WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END;
```

After execution, `SELECT DISTINCT Item_Fat_Content FROM Blinkit_data;` confirms that the data has been cleaned to 'Low Fat' and 'Regular' categories.

### A. KPI Calculations

1.  **Total Sales**:

      Query: `SELECT CAST(SUM(Total_Sales) / 1000000.0 AS DECIMAL(10,2)) AS Total_Sales_Million FROM Blinkit_data;`
      Result: 1.20 Million

2.  **Average Sales**:

      Query: `SELECT CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales FROM Blinkit_data;`
      Result: 141.0

3.  **Number of Items (Orders)**:

      Query: `SELECT COUNT(*) AS No_of_Orders FROM Blinkit_data;`
      Result: 8523

4.  **Average Rating**:

      Query: `SELECT CAST(AVG(Rating) AS DECIMAL(10,1)) AS Avg_Rating FROM Blinkit_data;`
      Result: 4.0

### B. Granular Analysis

1.  **Total Sales by Fat Content**:

      Query: `SELECT Item_Fat_Content, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales FROM Blinkit_data GROUP BY Item_Fat_Content;`
      * Results:
          Low Fat: 776319.68
          Regular: 425361.80

2.  **Total Sales by Item Type**:

      Query: `SELECT Item_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales FROM Blinkit_data GROUP BY Item_Type ORDER BY Total_Sales DESC;`
      Top Item Types by Total Sales:
          * Fruits and Vegetables: 178124.08
          * Snack Foods: 175433.92
          * Household: 135976.88

3.  **Fat Content by Outlet for Total Sales (Pivoted)**:

      This query transforms total sales data by `Outlet_Location_Type` and `Item_Fat_Content` into a pivoted format, showing 'Low Fat' and 'Regular' sales as separate columns for each location type.`ISNULL` is used to replace `NULL` values with 0 for cleaner reporting.
      Query:
        ```sql
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
        ORDER BY Outlet_Location_Type;
        ```
      Results:
          * Tier 1: Low\_Fat = 215047.91, Regular = 121349.90
          * Tier 2: Low\_Fat = 254464.77, Regular = 138685.87
          * Tier 3: Low\_Fat = 306806.99, Regular = 165326.03

4.  **Total Sales by Outlet Establishment Year**:

      Query: `SELECT Outlet_Establishment_Year, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales FROM Blinkit_data GROUP BY Outlet_Establishment_Year ORDER BY Outlet_Establishment_Year;`
      * Results show total sales for each establishment year.For example:
          * 1998: 204522.26
          * 2000: 131809.02
          * 2010: 132113.37

### C. Chart Data Preparation

1.  **Percentage of Sales by Outlet Size**:

      This query calculates the total sales and the percentage contribution of each `Outlet_Size` to the overall sales.
      Query:
        ```sql
        SELECT Outlet_Size,
               CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
               CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
        FROM Blinkit_data
        GROUP BY Outlet_Size
        ORDER BY Total_Sales DESC;
        ```
      Results:
          * Medium: Total\_Sales = 507895.73, Sales\_Percentage = 42.27
          * Small: Total\_Sales = 444794.17, Sales\_Percentage = 37.01
          * High: Total\_Sales = 248991.58, Sales\_Percentage = 20.72

2.  **Sales by Outlet Location**:

      Query: `SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales FROM Blinkit_data GROUP BY Outlet_Location_Type ORDER BY Total_Sales DESC;` 
      Results:
          * Tier 3: 472133.03
          * Tier 2: 393150.64
          * Tier 1: 336397.81

3.  **All Metrics by Outlet Type**:

      Query: 
        ```sql
        SELECT Outlet_Type,
               CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
               CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
               COUNT(*) AS No_Of_Items,
               CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
               CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
        FROM Blinkit_data
        GROUP BY Outlet_Type
        ORDER BY Total_Sales DESC;
        ```
      * Results:
          * Supermarket Type1: Total\_Sales = 787549.89, Avg\_Sales = 141, No\_Of\_Items = 5577, Avg\_Rating = 3.96, Item\_Visibility = 0.06
          * Grocery Store: Total\_Sales = 151939.15, Avg\_Sales = 140, No\_Of\_Items = 1083, Avg\_Rating = 3.99, Item\_Visibility = 0.10
          * Supermarket Type2: Total\_Sales = 131477.77, Avg\_Sales = 142, No\_Of\_Items = 928, Avg\_Rating = 3.97, Item\_Visibility = 0.06
          * Supermarket Type3: Total\_Sales = 130714.67, Avg\_Sales = 140, No\_Of\_Items = 935, Avg\_Rating = 3.95, Item\_Visibility = 0.06
