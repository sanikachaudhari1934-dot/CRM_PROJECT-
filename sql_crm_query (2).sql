use crm;

SELECT 
    -- 1. Total Lead
    COUNT(`Lead ID`) AS Total_Lead,

    -- 2. Expected Amount from Converted Leads (Joined with Opportunity Table)
    (SELECT SUM(o.`Expected Amount`) 
     FROM `opportunity_tbl` o 
     INNER JOIN `lead` l ON l.`Converted Opportunity ID` = o.`Opportunity ID` 
     WHERE l.`Converted` = 'True') AS Expected_Amount_from_Converted_Leads,

    -- 3. Conversion Rate (%) = (Converted / Total) * 100
    ROUND(
        (COUNT(CASE WHEN `Converted` = 'True' THEN 1 END) * 100.0) / COUNT(`Lead ID`), 
        2
    ) AS `Conversion_Rate (%)`,

    -- 4. Converted Accounts
    sum(`# Converted Accounts`) AS Converted_Accounts,

    -- 5. Converted Opportunities
    sum(`# Converted Opportunities`) AS Converted_Opportunities

FROM `crm`.`lead`;



SELECT `Lead Source`, COUNT(*) AS Lead_Count
FROM `lead`
GROUP BY `Lead Source`
ORDER BY Lead_Count DESC;


-- 7. Leads by Industry
SELECT Industry, COUNT(*) AS Lead_Count
FROM `lead`
GROUP BY Industry
ORDER BY Lead_Count DESC;

-- 8. Leads by Stage
SELECT Status, COUNT(*) AS Lead_Count
FROM `lead`
GROUP BY Status
ORDER BY Lead_Count DESC;


#Oppoertunity dashboard

SELECT
    SUM(`Expected Amount`) AS expected_amount
FROM opportunity_tbl;

#1. Expected Amount
SELECT
    SUM(`Expected Amount`) AS expected_amount
FROM opportunity_dash_data;

# 2. Active Opportunities (Open only)
SELECT
    COUNT(DISTINCT `Opportunity ID`) AS active_opportunities
FROM opportunity_tbl
WHERE `Stage` NOT IN ('Closed Won', 'Closed Lost');


# 3. Total Created Opportunities
SELECT
    count( `Opportunity ID`) AS total_opportunities
FROM opportunity_dash_data;





#6. Conversion Rate (%)

# Formula: (Won / Total Opportunities) × 100

SELECT
    ROUND(
        (COUNT(CASE WHEN `Stage` = 'Closed Won' THEN 1 END) * 100.0)
        / NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_percentage
FROM opportunity_dash_data;

# 7. Win Rate (%)

#Formula: (Won / (Won + Lost)) × 100

SELECT
    ROUND(
        (COUNT(CASE WHEN `Stage` = 'Closed Won' THEN 1 END) * 100.0)
        / NULLIF(
            COUNT(CASE WHEN `Stage` IN ('Closed Won', 'Closed Lost') THEN 1 END),
            0
        ),
        2
    ) AS win_rate_percentage
FROM opportunity_dash_data;

#8. Loss Rate (%)

#Formula: (Lost / Total Opportunities) × 100

SELECT
    ROUND(
        (COUNT(CASE WHEN `Stage` = 'Closed Lost' THEN 1 END) * 100.0)
        / NULLIF(COUNT(*), 0),
        2
    ) AS loss_rate_percentage
FROM opportunity_dash_data;



# 10. Active vs Total Opportunities (Cumulative)
WITH yearly_opportunities AS (
    SELECT
        `Close Year` AS close_year,

        COUNT(*) AS total_opportunities,

        SUM(
            CASE
                WHEN `Stage` NOT IN ('Closed Won', 'Closed Lost') THEN 1
                ELSE 0
            END
        ) AS active_opportunities
    FROM opportunity_dash_data
    WHERE `Close Year` IS NOT NULL
    GROUP BY `Close Year`
)

SELECT
    close_year,

    SUM(total_opportunities) OVER (
        ORDER BY close_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS total_opportunities_running,

    SUM(active_opportunities) OVER (
        ORDER BY close_year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS active_opportunities_running
FROM yearly_opportunities
ORDER BY close_year;


# 11. Closed Won vs Total Opportunities (Daily Trend)
SELECT
    SUM(CASE WHEN Stage IN ('Closed Won', 'Closed Lost') THEN 1 ELSE 0 END)
        AS total_closed_opportunities,

    SUM(CASE WHEN Stage = 'Closed Won' THEN 1 ELSE 0 END)
        AS won_opportunities
FROM opportunity_dash_data;

# 12. Closed Won vs Closed Lost
SELECT
    SUM(CASE WHEN `Stage` = 'Closed Won' THEN 1 ELSE 0 END) AS closed_won,
    SUM(CASE WHEN `Stage` = 'Closed Lost' THEN 1 ELSE 0 END) AS closed_lost
FROM opportunity_dash_data;

#📊 CATEGORY ANALYSIS
# 13. Expected Amount by Opportunity Type
SELECT
    `Opportunity Type`,
    SUM(`Expected Amount`) AS expected_amount
FROM opportunity_dash_data
GROUP BY `Opportunity Type`
ORDER BY expected_amount DESC;

# 14. Opportunities by Industry
SELECT
    Industry,
    COUNT(DISTINCT `Opportunity ID`) AS total_opportunities
FROM opportunity_dash_data
GROUP BY Industry
ORDER BY total_opportunities DESC;





  
  
  
  
  
  
  