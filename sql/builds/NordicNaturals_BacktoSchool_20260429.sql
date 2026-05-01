-- ============================================================
-- MOSAIC PACKAGE BUILD — Nordic Naturals
-- Hard coded table names — update when data refreshes
-- S360 Individual:  PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331   (ADDRESS1)
-- S360 Household:   PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317 (ADDRESS)
-- Lifestyle:        PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_L730D_20260429 (ADDRESS)
-- Product:          PROXIMA.PUBLIC.PRODUCT_SEGMENTS_20260409         (ADDRESS)
-- Core:             PROXIMA.PUBLIC.CORE_SEGMENTS_20260413            (ADDRESS)
-- ============================================================


-- Package: Premium Health-Focused Parents
CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_NORDICNATURALS_PREMIUMHEALTHFOCUSEDPARENTS AS
WITH
  s360 AS (
    SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331
    WHERE SEGMENT_NAME IN (
    'High Lifetime Value Health Shopper',
    'High Lifetime Value Children Shopper',
    'Subscription Purchase Health Shopper',
    'Female Health Shopper'
    )
    AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL
  ),

  s360_hh AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317
    WHERE SEGMENT_NAME IN (
    'High Lifetime Value Health Shopper',
    'High Lifetime Value Children Shopper',
    'Subscription Purchase Health Shopper',
    'Female Health Shopper'
    )
    AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL
  ),

  lifestyle AS (
    SELECT ADDRESS, CITY, STATE, ZIP
    FROM PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_L730D_20260429
    WHERE SEGMENT_NAME IN (
    'parents_of_school-age_children_L730D_lookback'
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
-- FINAL: ALL PACKAGE COUNTS
-- ============================================================

  SELECT 'Premium Health-Focused Parents' AS PACKAGE_NAME, COUNT(*) AS SIZE FROM PROXIMA.PUBLIC.SPEC_NORDICNATURALS_PREMIUMHEALTHFOCUSEDPARENTS
ORDER BY PACKAGE_NAME;