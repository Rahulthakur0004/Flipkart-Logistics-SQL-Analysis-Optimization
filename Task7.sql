USE flipkart_logistics;
-- Task 7.1: Average delivery delay (days) per region (Start_Location)
SELECT
    r.Start_Location AS Region,
    AVG(
        DATEDIFF(
            STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d'),
            STR_TO_DATE(o.Expected_Delivery_Date,'%Y-%m-%d')
        )
    ) AS Avg_Delay_Days
FROM Flipkart_Orders o
JOIN Flipkart_Routes r
  ON o.Route_ID = r.Route_ID
GROUP BY r.Start_Location
ORDER BY Avg_Delay_Days DESC;
-- Task 7.2: Overall On-Time Delivery Percentage
SELECT
    COUNT(*) AS Total_Deliveries,
    SUM(
        CASE 
            WHEN STR_TO_DATE(Actual_Delivery_Date,  '%Y-%m-%d') <=
                 STR_TO_DATE(Expected_Delivery_Date,'%Y-%m-%d')
            THEN 1 ELSE 0
        END
    ) AS OnTime_Deliveries,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN STR_TO_DATE(Actual_Delivery_Date,  '%Y-%m-%d') <=
                     STR_TO_DATE(Expected_Delivery_Date,'%Y-%m-%d')
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS OnTime_Percentage
FROM Flipkart_Orders;
-- Optional: On-Time % per region (Start_Location)
SELECT
    r.Start_Location AS Region,
    COUNT(*) AS Total_Deliveries,
    SUM(
        CASE 
            WHEN STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d') <=
                 STR_TO_DATE(o.Expected_Delivery_Date,'%Y-%m-%d')
            THEN 1 ELSE 0
        END
    ) AS OnTime_Deliveries,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d') <=
                     STR_TO_DATE(o.Expected_Delivery_Date,'%Y-%m-%d')
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS OnTime_Percentage
FROM Flipkart_Orders o
JOIN Flipkart_Routes r
  ON o.Route_ID = r.Route_ID
GROUP BY r.Start_Location
ORDER BY OnTime_Percentage DESC;
-- Task 7.3: Average traffic delay per route
SELECT
    Route_ID,
    Start_Location,
    End_Location,
    AVG(Traffic_Delay_Min) AS Avg_Traffic_Delay_Min
FROM Flipkart_Routes
GROUP BY Route_ID, Start_Location, End_Location
ORDER BY Avg_Traffic_Delay_Min DESC;
