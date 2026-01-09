CREATE DATABASE flipkart_logistics;
USE flipkart_logistics;
CREATE TABLE Flipkart_Orders (
    Order_ID                 VARCHAR(30) PRIMARY KEY,
    Warehouse_ID             VARCHAR(30),
    Route_ID                 VARCHAR(30),
    Agent_ID                 VARCHAR(30),
    Order_Date               VARCHAR(20),   -- will convert to DATE later
    Expected_Delivery_Date   VARCHAR(20),
    Actual_Delivery_Date     VARCHAR(20),
    Status                   VARCHAR(50),
    Order_Value              DECIMAL(10,2)
);
CREATE TABLE Flipkart_Routes (
    Route_ID                   VARCHAR(30) PRIMARY KEY,
    Start_Location             VARCHAR(100),
    End_Location               VARCHAR(100),
    Distance_KM                INT,
    Average_Travel_Time_Min    INT,
    Traffic_Delay_Min          INT
);
CREATE TABLE Flipkart_DeliveryAgents (
    Agent_ID                       VARCHAR(30) PRIMARY KEY,
    Agent_Name                     VARCHAR(100),
    Route_ID                       VARCHAR(30),
    Avg_Speed_KMPH                 DECIMAL(5,2),
    On_Time_Delivery_Percentage    DECIMAL(5,2),
    Experience_Years               DECIMAL(4,1)
);
CREATE TABLE Flipkart_Warehouses (
    Warehouse_ID                   VARCHAR(30) PRIMARY KEY,
    Warehouse_Name                 VARCHAR(150),
    City                           VARCHAR(100),
    Processing_Capacity            INT,
    Average_Processing_Time_Min    INT
);
CREATE TABLE Flipkart_ShipmentTracking (
    Tracking_ID        VARCHAR(30) PRIMARY KEY,
    Order_ID           VARCHAR(30),
    Checkpoint         VARCHAR(150),
    Checkpoint_Time    VARCHAR(25),   -- will convert to DATETIME later
    Delay_Reason       VARCHAR(100),
    Delay_Minutes      INT
);
SELECT * FROM Flipkart_Orders           LIMIT 5;
SELECT * FROM Flipkart_Routes           LIMIT 5;
SELECT * FROM Flipkart_DeliveryAgents   LIMIT 5;
SELECT * FROM Flipkart_Warehouses       LIMIT 5;
SELECT * FROM Flipkart_ShipmentTracking LIMIT 5;
USE flipkart_logistics;
SELECT 
    Order_ID,
    COUNT(*) as Duplicate_Count
FROM Flipkart_Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;
-- Check how many NULLs
SELECT COUNT(*) AS null_delay_rows
FROM Flipkart_Routes
WHERE Traffic_Delay_Min IS NULL;

-- Fill NULLs with average delay for that route
UPDATE Flipkart_Routes r
JOIN (
    SELECT 
        Route_ID,
        AVG(Traffic_Delay_Min) AS avg_delay
    FROM Flipkart_Routes
    WHERE Traffic_Delay_Min IS NOT NULL
    GROUP BY Route_ID
) t
  ON r.Route_ID = t.Route_ID
SET r.Traffic_Delay_Min = t.avg_delayTracking_ID
WHERE r.Traffic_Delay_Min IS NULL;

-- Optional: fill any leftover NULLs with global average
UPDATE Flipkart_Routes
SET Traffic_Delay_Min = (
    SELECT AVG(Traffic_Delay_Min)
    FROM Flipkart_Routes
    WHERE Traffic_Delay_Min IS NOT NULL
)
WHERE Traffic_Delay_Min IS NULL;
USE flipkart_logistics;

-- 1) Add the flag column (run once)
ALTER TABLE Flipkart_Orders
ADD COLUMN Delivery_Date_Flag VARCHAR(20);

-- 2) Temporarily disable safe update mode (so UPDATE works)
SET SQL_SAFE_UPDATES = 0;

-- 3) Set the flag
UPDATE Flipkart_Orders
SET Delivery_Date_Flag =
    CASE
        WHEN Actual_Delivery_Date < Order_Date THEN 'INVALID_DATE'
        ELSE 'OK'
    END;

-- 4) (Optional) Turn safe mode back on
SET SQL_SAFE_UPDATES = 1;

-- 5) See any invalid records
SELECT *
FROM Flipkart_Orders
WHERE Delivery_Date_Flag = 'INVALID_DATE';
SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;
SELECT *
FROM Flipkart_Orders
WHERE Delivery_Date_Flag = 'INVALID_DATE';

