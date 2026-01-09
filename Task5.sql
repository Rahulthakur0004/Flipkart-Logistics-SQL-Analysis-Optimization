USE flipkart_logistics;
DROP VIEW IF EXISTS vw_agent_performance;
CREATE VIEW vw_agent_performance AS
SELECT
    o.Agent_ID,
    da.Agent_Name,
    o.Route_ID,
    COUNT(*) AS Total_Shipments,
    SUM(
        CASE 
            WHEN STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d') <=
                 STR_TO_DATE(o.Expected_Delivery_Date,'%Y-%m-%d')
            THEN 1 ELSE 0
        END
    ) AS OnTime_Shipments,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN STR_TO_DATE(o.Actual_Delivery_Date,  '%Y-%m-%d') <=
                     STR_TO_DATE(o.Expected_Delivery_Date,'%Y-%m-%d')
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS OnTime_Percentage,
    da.Avg_Speed_KMPH,
    da.Experience_Years
FROM Flipkart_Orders o
LEFT JOIN Flipkart_DeliveryAgents da
  ON o.Agent_ID = da.Agent_ID
 AND o.Route_ID = da.Route_ID
GROUP BY
    o.Agent_ID,
    da.Agent_Name,
    o.Route_ID,
    da.Avg_Speed_KMPH,
    da.Experience_Years;
SELECT
    Agent_ID,
    Agent_Name,
    Route_ID,
    Total_Shipments,
    OnTime_Shipments,
    OnTime_Percentage,
    Avg_Speed_KMPH,
    Experience_Years
FROM vw_agent_performance
WHERE OnTime_Percentage < 80
ORDER BY OnTime_Percentage ASC;

WITH RankedAgents AS (
    SELECT
        Agent_ID,
        Agent_Name,
        Route_ID,
        OnTime_Percentage,
        Avg_Speed_KMPH,
        RANK() OVER (ORDER BY OnTime_Percentage DESC) AS PerfRankDesc,
        RANK() OVER (ORDER BY OnTime_Percentage ASC)  AS PerfRankAsc
    FROM vw_agent_performance
)
SELECT
    (SELECT AVG(Avg_Speed_KMPH)
     FROM RankedAgents
     WHERE PerfRankDesc <= 5) AS Top5_AvgSpeed,
    (SELECT AVG(Avg_Speed_KMPH)
     FROM RankedAgents
     WHERE PerfRankAsc  <= 5) AS Bottom5_AvgSpeed;

