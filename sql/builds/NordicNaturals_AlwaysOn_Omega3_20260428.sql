-- ============================================================
-- MOSAIC PACKAGE BUILD — Nordic Naturals - Always On (Omega 3)
-- Hard coded table names — update when data refreshes
-- S360 Individual:  PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331   (ADDRESS1)
-- S360 Household:   PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317 (ADDRESS)
-- Lifestyle:        PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_20260409     (ADDRESS)
-- Product:          PROXIMA.PUBLIC.PRODUCT_SEGMENTS_20260409       (ADDRESS)
-- Core:             PROXIMA.PUBLIC.CORE_SEGMENTS_20260413          (ADDRESS)
-- ============================================================


-- ============================================================
-- PACKAGE 1: Scale & Reach: Health-Conscious Female Shoppers
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALSALWAYSONOMEGA3_SCALEREACHHEALTHCONSCIOUSFEMALESHOPPERS AS
WITH combined AS (

  SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
  WHERE SEGMENT_NAME IN (
    'Female Health Shopper',
    'Health Avid Shopper',
    'High Lifetime Value Health Shopper',
    'Health Shopper with No Discount',
    'Female Shopper'
  )
  AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
  WHERE SEGMENT_NAME IN (
    'Female Health Shopper',
    'Health Avid Shopper',
    'High Lifetime Value Health Shopper',
    'Health Shopper with No Discount',
    'Female Shopper'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.CORE_SEGMENTS_20260413
  WHERE SEGMENT_NAME IN (
    'Health'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

),
deduped AS (
  SELECT ADDRESS, CITY, STATE, ZIP,
    ROW_NUMBER() OVER (PARTITION BY ADDRESS, ZIP ORDER BY ADDRESS) AS rn
  FROM combined
)
SELECT ADDRESS, CITY, STATE, ZIP FROM deduped WHERE rn = 1;


-- ============================================================
-- PACKAGE 2: High-Value Precision: Subscription & Premium Health Buyers
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALSALWAYSONOMEGA3_HIGHVALUEPRECISIONSUBSCRIPTIONPREMIUMHEALTHBUYERS AS
WITH combined AS (

  SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
  WHERE SEGMENT_NAME IN (
    'Subscription Purchase Health Shopper',
    'High Average Order Value Health Shopper',
    'Health Shopper with No Discount'
  )
  AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
  WHERE SEGMENT_NAME IN (
    'Subscription Purchase Health Shopper',
    'High Average Order Value Health Shopper',
    'Health Shopper with No Discount'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.CORE_SEGMENTS_20260413
  WHERE SEGMENT_NAME IN (
    'DTCHighLTV',
    'DTCSubscription',
    'DTCNonDiscount'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

),
deduped AS (
  SELECT ADDRESS, CITY, STATE, ZIP,
    ROW_NUMBER() OVER (PARTITION BY ADDRESS, ZIP ORDER BY ADDRESS) AS rn
  FROM combined
)
SELECT ADDRESS, CITY, STATE, ZIP FROM deduped WHERE rn = 1;


-- ============================================================
-- PACKAGE 3: Lifestyle Affinity: Wellness-Oriented Women 30-55
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALSALWAYSONOMEGA3_LIFESTYLEAFFINITYWELLNESSORIENTEDWOMEN3055 AS
WITH combined AS (

  SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
  WHERE SEGMENT_NAME IN (
    'Female Health Shopper',
    'Health Active Shopper'
  )
  AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
  WHERE SEGMENT_NAME IN (
    'Female Health Shopper',
    'Health Active Shopper'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_20260409
  WHERE SEGMENT_NAME IN (
    'Women''s_Midlife_Wellness_Support_Interest_L90D',
    'Clean_&_Non-Toxic_Obsession_L90D',
    'At-Home_Anti-Aging_Treatments_L90D',
    'Athletic_Performance_&_Recovery_L90D'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS, CITY, STATE, ZIP
  FROM PROXIMA.PUBLIC.PRODUCT_SEGMENTS_20260409
  WHERE SEGMENT_NAME IN (
    'HealthCareL90DayShopper',
    'PersonalCareL90DayShopper'
  )
  AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

),
deduped AS (
  SELECT ADDRESS, CITY, STATE, ZIP,
    ROW_NUMBER() OVER (PARTITION BY ADDRESS, ZIP ORDER BY ADDRESS) AS rn
  FROM combined
)
SELECT ADDRESS, CITY, STATE, ZIP FROM deduped WHERE rn = 1;


-- ============================================================
-- FINAL: ALL PACKAGE COUNTS IN ONE RESULT
-- ============================================================

SELECT 'Scale & Reach: Health-Conscious Female Shoppers'              AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALSALWAYSONOMEGA3_SCALEREACHHEALTHCONSCIOUSFEMALESHOPPERS
UNION ALL
SELECT 'High-Value Precision: Subscription & Premium Health Buyers'   AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALSALWAYSONOMEGA3_HIGHVALUEPRECISIONSUBSCRIPTIONPREMIUMHEALTHBUYERS
UNION ALL
SELECT 'Lifestyle Affinity: Wellness-Oriented Women 30-55'            AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALSALWAYSONOMEGA3_LIFESTYLEAFFINITYWELLNESSORIENTEDWOMEN3055
ORDER BY PACKAGE_NAME;
