-- ============================================================
-- MOSAIC PACKAGE BUILD — Nordic Naturals: Vitamin D and Omega-3
-- October-November Flight
-- S360 Individual:  PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331   (ADDRESS1)
-- S360 Household:   PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317 (ADDRESS)
-- Lifestyle:        PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_20260409     (ADDRESS)
-- Product:          PROXIMA.PUBLIC.PRODUCT_SEGMENTS_20260409       (ADDRESS)
-- Core:             PROXIMA.PUBLIC.CORE_SEGMENTS_20260413          (ADDRESS)
-- ============================================================


-- ============================================================
-- PACKAGE 1: BF/CM Health Deal Seekers - Scale
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALSVITAMINDANDOMEGA3_BFCMHEALTHDEALSEEKERSSCALE AS
WITH
  s360 AS (
    SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
    WHERE SEGMENT_NAME IN (
      'Black Friday & Cyber Monday Health Shopper',
      'Discount Health Shopper',
      'Black Friday & Cyber Monday Shopper',
      'Health Active Shopper',
      'Active Shopper'
    )
    AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL
  ),

  s360_hh AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
    WHERE SEGMENT_NAME IN (
      'Black Friday & Cyber Monday Health Shopper',
      'Discount Health Shopper',
      'Black Friday & Cyber Monday Shopper',
      'Health Active Shopper',
      'Active Shopper'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  core AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.CORE_SEGMENTS_20260413
    WHERE SEGMENT_NAME IN (
      'DTCDiscount'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  combined AS (
    SELECT ADDRESS, CITY, STATE, ZIP FROM s360
    UNION ALL
    SELECT ADDRESS, CITY, STATE, ZIP FROM s360_hh
    UNION ALL
    SELECT ADDRESS, CITY, STATE, ZIP FROM core
  ),

  deduped AS (
    SELECT ADDRESS, CITY, STATE, ZIP,
      ROW_NUMBER() OVER (PARTITION BY ADDRESS, ZIP ORDER BY ADDRESS) AS rn
    FROM combined
  )

SELECT ADDRESS, CITY, STATE, ZIP FROM deduped WHERE rn = 1;


-- ============================================================
-- PACKAGE 2: High-Intent Supplement Loyalists - Precision
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALSVITAMINDANDOMEGA3_HIGHINTENTSUPPLEMENTLOYALISTSPRECISION AS
WITH
  s360 AS (
    SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
    WHERE SEGMENT_NAME IN (
      'High Lifetime Value Health Shopper',
      'Subscription Purchase Health Shopper',
      'Health Avid Shopper',
      'Health Shopper - 90 Day Recency'
    )
    AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL
  ),

  s360_hh AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
    WHERE SEGMENT_NAME IN (
      'High Lifetime Value Health Shopper',
      'Subscription Purchase Health Shopper',
      'Health Avid Shopper',
      'Health Shopper - 90 Day Recency'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  product AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.PRODUCT_SEGMENTS_20260409
    WHERE SEGMENT_NAME IN (
      'HealthCareL30DayShopper'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  combined AS (
    SELECT ADDRESS, CITY, STATE, ZIP FROM s360
    UNION ALL
    SELECT ADDRESS, CITY, STATE, ZIP FROM s360_hh
    UNION ALL
    SELECT ADDRESS, CITY, STATE, ZIP FROM product
  ),

  deduped AS (
    SELECT ADDRESS, CITY, STATE, ZIP,
      ROW_NUMBER() OVER (PARTITION BY ADDRESS, ZIP ORDER BY ADDRESS) AS rn
    FROM combined
  )

SELECT ADDRESS, CITY, STATE, ZIP FROM deduped WHERE rn = 1;


-- ============================================================
-- PACKAGE 3: Wellness Lifestyle & Family - Niche
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALSVITAMINDANDOMEGA3_WELLNESSLIFESTYLEFAMILYNICHE AS
WITH
  s360 AS (
    SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
    WHERE SEGMENT_NAME IN (
      'Female Health Shopper'
    )
    AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL
  ),

  s360_hh AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
    WHERE SEGMENT_NAME IN (
      'Female Health Shopper'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  lifestyle AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_20260409
    WHERE SEGMENT_NAME IN (
      'Clean_&_Non-Toxic_Obsession_L90D',
      'Athletic_Performance_&_Recovery_L90D',
      'Women''s_Midlife_Wellness_Support_Interest_L90D',
      'Parents_of_School-Age_Children_L90D',
      'Working_Mothers_L90D'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  combined AS (
    SELECT ADDRESS, CITY, STATE, ZIP FROM s360
    UNION ALL
    SELECT ADDRESS, CITY, STATE, ZIP FROM s360_hh
    UNION ALL
    SELECT ADDRESS, CITY, STATE, ZIP FROM lifestyle
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

SELECT 'BF/CM Health Deal Seekers - Scale'             AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALSVITAMINDANDOMEGA3_BFCMHEALTHDEALSEEKERSSCALE
UNION ALL
SELECT 'High-Intent Supplement Loyalists - Precision'  AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALSVITAMINDANDOMEGA3_HIGHINTENTSUPPLEMENTLOYALISTSPRECISION
UNION ALL
SELECT 'Wellness Lifestyle & Family - Niche'           AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALSVITAMINDANDOMEGA3_WELLNESSLIFESTYLEFAMILYNICHE
ORDER BY PACKAGE_NAME;
