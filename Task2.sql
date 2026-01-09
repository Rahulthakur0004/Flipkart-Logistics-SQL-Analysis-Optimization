USE flipkart_logistics;
SELECT 
    Order_ID,
    Warehouse_ID,
    Route_ID,
    Expected_Delivery_Date,
    Actual_Delivery_Date,
    DATEDIFF(
        STR_TO_DATE(Actual_Delivery_Date, '%Y-%m-%d'),
        STR_TO_DATE(Expected_Delivery_Date, '%Y-%m-%d')
    ) AS Delay_Days
FROM Flipkart_Orders
ORDER BY Delay_Days DESC;
SELECT 
    Route_ID,
    AVG(
        DATEDIFF(
            STR_TO_DATE(Actual_Delivery_Date, '%Y-%m-%d'),
            STR_TO_DATE(Expected_Delivery_Date, '%Y-%m-%d')
        )
    ) AS Avg_Delay_Days
FROM Flipkart_Orders
GROUP BY Route_ID
ORDER BY Avg_Delay_Days DESC
LIMIT 10;
SELECT
    Warehouse_ID,
    Order_ID,
    Expected_Delivery_Date,
    Actual_Delivery_Date,
    DATEDIFF(
        STR_TO_DATE(Actual_Delivery_Date, '%Y-%m-%d'),
        STR_TO_DATE(Expected_Delivery_Date, '%Y-%m-%d')
    ) AS Delay_Days,
    RANK() OVER (
        PARTITION BY Warehouse_ID
        ORDER BY 
            DATEDIFF(
                STR_TO_DATE(Actual_Delivery_Date, '%Y-%m-%d'),
                STR_TO_DATE(Expected_Delivery_Date, '%Y-%m-%d')
            ) DESC
    ) AS Delay_Rank
FROM Flipkart_Orders
ORDER BY Warehouse_ID, Delay_Rank;
