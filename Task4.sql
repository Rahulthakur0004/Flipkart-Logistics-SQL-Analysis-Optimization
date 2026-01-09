USE flipkart_logistics;
-- Task 4.1: Top 3 warehouses by avg processing time
SELECT
    Warehouse_ID,
    Warehouse_Name,
    City,
    Average_Processing_Time_Min
FROM Flipkart_Warehouses
ORDER BY Average_Processing_Time_Min DESC
LIMIT 3;
-- Task 4.2: Total vs delayed shipments per warehouse
SELECT
    Warehouse_ID,
    COUNT(*) AS Total_Shipments,
    SUM(
        CASE 
            WHEN STR_TO_DATE(Actual_Delivery_Date,  '%Y-%m-%d') >
                 STR_TO_DATE(Expected_Delivery_Date, '%Y-%m-%d')
            THEN 1 ELSE 0 
        END
    ) AS Delayed_Shipments
FROM Flipkart_Orders
GROUP BY Warehouse_ID
ORDER BY Total_Shipments DESC;
-- Task 4.3: Bottleneck warehouses (processing time > global average)
WITH WarehouseStats AS (
    SELECT
        Warehouse_ID,
        Warehouse_Name,
        City,
        Average_Processing_Time_Min
    FROM Flipkart_Warehouses
),
GlobalAvg AS (
    SELECT
        AVG(Average_Processing_Time_Min) AS Global_Avg_Processing_Time
    FROM WarehouseStats
)
SELECT
    w.Warehouse_ID,
    w.Warehouse_Name,
    w.City,
    w.Average_Processing_Time_Min,
    g.Global_Avg_Processing_Time
FROM WarehouseStats w
CROSS JOIN GlobalAvg g
WHERE w.Average_Processing_Time_Min > g.Global_Avg_Processing_Time
ORDER BY w.Average_Processing_Time_Min DESC;
-- Task 4.4: Rank warehouses by on-time delivery %
WITH WarehouseDelivery AS (
    SELECT
        Warehouse_ID,
        COUNT(*) AS Total_Shipments,
        SUM(
            CASE 
                WHEN STR_TO_DATE(Actual_Delivery_Date,  '%Y-%m-%d') <=
                     STR_TO_DATE(Expected_Delivery_Date, '%Y-%m-%d')
                THEN 1 ELSE 0
            END
        ) AS OnTime_Shipments
    FROM Flipkart_Orders
    GROUP BY Warehouse_ID
),
WarehouseOnTime AS (
    SELECT
        Warehouse_ID,
        Total_Shipments,
        OnTime_Shipments,
        ROUND(100.0 * OnTime_Shipments / Total_Shipments, 2) AS OnTime_Percentage
    FROM WarehouseDelivery
)
SELECT
    w.Warehouse_ID,
    wh.Warehouse_Name,
    wh.City,
    w.Total_Shipments,
    w.OnTime_Shipments,
    w.OnTime_Percentage,
    RANK() OVER (ORDER BY w.OnTime_Percentage DESC) AS OnTime_Rank
FROM WarehouseOnTime w
LEFT JOIN Flipkart_Warehouses wh
  ON w.Warehouse_ID = wh.Warehouse_ID
ORDER BY OnTime_Rank;

