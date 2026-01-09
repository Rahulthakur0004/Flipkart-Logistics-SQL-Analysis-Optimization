USE flipkart_logistics;
-- Task 3.1: Route-level metrics
SELECT
    o.Route_ID,
    AVG(
        DATEDIFF(
            STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d'),
            STR_TO_DATE(o.Order_Date,            '%Y-%m-%d')
        )
    ) AS Avg_Delivery_Time_Days,
    AVG(r.Traffic_Delay_Min) AS Avg_Traffic_Delay_Min,
    r.Distance_KM,
    r.Average_Travel_Time_Min,
    (r.Distance_KM / r.Average_Travel_Time_Min) AS Distance_Time_Efficiency
FROM Flipkart_Orders o
JOIN Flipkart_Routes r
  ON o.Route_ID = r.Route_ID
GROUP BY
    o.Route_ID,
    r.Distance_KM,
    r.Average_Travel_Time_Min
ORDER BY Avg_Delivery_Time_Days DESC;
-- Task 3.2: 3 routes with worst distance-to-time efficiency
SELECT *
FROM (
    SELECT
        o.Route_ID,
        AVG(
            DATEDIFF(
                STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d'),
                STR_TO_DATE(o.Order_Date,            '%Y-%m-%d')
            )
        ) AS Avg_Delivery_Time_Days,
        AVG(r.Traffic_Delay_Min) AS Avg_Traffic_Delay_Min,
        r.Distance_KM,
        r.Average_Travel_Time_Min,
        (r.Distance_KM / r.Average_Travel_Time_Min) AS Distance_Time_Efficiency
    FROM Flipkart_Orders o
    JOIN Flipkart_Routes r
      ON o.Route_ID = r.Route_ID
    GROUP BY
        o.Route_ID,
        r.Distance_KM,
        r.Average_Travel_Time_Min
) AS route_stats
ORDER BY Distance_Time_Efficiency ASC      -- lowest efficiency first
LIMIT 3;
-- Task 3.3: Routes with more than 20% delayed shipments
SELECT
    Route_ID,
    COUNT(*) AS Total_Shipments,
    SUM(
        CASE
            WHEN STR_TO_DATE(Actual_Delivery_Date,  '%Y-%m-%d') >
                 STR_TO_DATE(Expected_Delivery_Date,'%Y-%m-%d')
            THEN 1 ELSE 0
        END
    ) AS Delayed_Shipments,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN STR_TO_DATE(Actual_Delivery_Date,  '%Y-%m-%d') >
                     STR_TO_DATE(Expected_Delivery_Date,'%Y-%m-%d')
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Delay_Percentage
FROM Flipkart_Orders
GROUP BY Route_ID
HAVING Delay_Percentage > 20;
WITH RouteMetrics AS (
    SELECT
        o.Route_ID,
        AVG(
            DATEDIFF(
                STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d'),
                STR_TO_DATE(o.Order_Date,            '%Y-%m-%d')
            )
        ) AS Avg_Delivery_Time_Days,
        AVG(r.Traffic_Delay_Min) AS Avg_Traffic_Delay_Min,
        r.Distance_KM,
        r.Average_Travel_Time_Min,
        (r.Distance_KM / r.Average_Travel_Time_Min) AS Distance_Time_Efficiency
    FROM Flipkart_Orders o
    JOIN Flipkart_Routes r
      ON o.Route_ID = r.Route_ID
    GROUP BY
        o.Route_ID,
        r.Distance_KM,
        r.Average_Travel_Time_Min
),
Overall AS (
    SELECT
        AVG(Avg_Delivery_Time_Days)      AS Overall_Avg_Delay,
        AVG(Distance_Time_Efficiency)    AS Overall_Avg_Eff
    FROM RouteMetrics
)
SELECT
    rm.*
FROM RouteMetrics rm
CROSS JOIN Overall o
WHERE rm.Avg_Delivery_Time_Days    > o.Overall_Avg_Delay
  AND rm.Distance_Time_Efficiency  < o.Overall_Avg_Eff
ORDER BY rm.Avg_Delivery_Time_Days DESC;
