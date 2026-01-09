USE flipkart_logistics;
-- Task 6.1: Last checkpoint and time for each order
SELECT
    st.Order_ID,
    st.Checkpoint      AS Last_Checkpoint,
    st.Checkpoint_Time AS Last_Checkpoint_Time
FROM Flipkart_ShipmentTracking st
JOIN (
    SELECT
        Order_ID,
        MAX(Checkpoint_Time) AS Max_Checkpoint_Time
    FROM Flipkart_ShipmentTracking
    GROUP BY Order_ID
) latest
  ON st.Order_ID       = latest.Order_ID
 AND st.Checkpoint_Time = latest.Max_Checkpoint_Time
ORDER BY st.Order_ID;
-- Task 6.2: Most common delay reasons (excluding 'None' and NULL)
SELECT
    Delay_Reason,
    COUNT(*) AS Occurrences
FROM Flipkart_ShipmentTracking
WHERE Delay_Reason IS NOT NULL
  AND Delay_Reason <> 'None'
GROUP BY Delay_Reason
ORDER BY Occurrences DESC;
-- Task 6.3: Orders with more than 2 delayed checkpoints
SELECT
    Order_ID,
    COUNT(*) AS Delayed_Checkpoints
FROM Flipkart_ShipmentTracking
WHERE Delay_Minutes > 0
GROUP BY Order_ID
HAVING COUNT(*) > 2
ORDER BY Delayed_Checkpoints DESC;
