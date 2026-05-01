-- ============================================================
-- MOSAIC PACKAGE BUILD 
-- S360 Individual:  PROXIMA.PUBLIC.SHOPPER360_SEGMENTS_20260331   (ADDRESS1)
-- S360 Household:   PROXIMA.PUBLIC.SHOPPER360_HH_SEGMENTS_20260317 (ADDRESS)
-- Lifestyle:        PROXIMA.PUBLIC.LIFESTYLE_SEGMENTS_L730D_20260429 (ADDRESS)
-- Product:          PROXIMA.PUBLIC.PRODUCT_SEGMENTS_20260409       (ADDRESS)
-- Core:             PROXIMA.PUBLIC.CORE_SEGMENTS_20260413          (ADDRESS)
-- ============================================================


-- ------------------------------------------------------------
-- SEGMENT NAME REFERENCE
-- ------------------------------------------------------------
--
-- SHOPPER360 / HH (use display name exactly as-is):
--   'Health Avid Shopper'
--   'Health Active Shopper'
--   'Health Occasional Shopper'
--   'Health Shopper - 90 Day Recency'
--   'Health Shopper with Free Shipping'
--   'Health Shopper with No Discount'
--   'High Lifetime Value Health Shopper'
--   'High Average Order Value Health Shopper'
--   'High Lifetime Value Shopper'
--   'High Average Order Value Shopper'
--   'Subscription Purchase Health Shopper'
--   'Subscription Shopper'
--   'Female Health Shopper' / 'Male Health Shopper'
--   'Female Shopper' / 'Male Shopper'
--   'Avid Shopper' / 'Active Shopper' / 'Occasional Shopper'
--   'Discount Shopper' / 'No Discount Shopper' / 'Free Shipping Shopper'
--   (all other Shopper360 display names verbatim)
--
-- PRODUCT segments:
--   BabyGiftSetsL30DayShopper / L60D / L90D
--   BabyTransportAccessoriesL30DayShopper / L60D / L90D
--   BeveragesL30DayShopper / L60D / L90D
--   ClothingAccessoriesL30DayShopper / L60D / L90D
--   ClothingL30DayShopper / L60D / L90D
--   DecorL30DayShopper / L60D / L90D
--   DiaperingL30DayShopper / L60D / L90D
--   FoodItemsL30DayShopper / L60D / L90D
--   HandbagsWalletsAndCasesL30DayShopper / L60D / L90D
--   HealthCareL30DayShopper / L60D / L90D
--   HouseholdSuppliesL30DayShopper / L60D / L90D
--   JewelryL30DayShopper / L60D / L90D
--   JewelryCleaningAndCareL30DayShopper / L60D / L90D
--   KitchenAndDiningL30DayShopper / L60D / L90D
--   LawnAndGardenL30DayShopper / L60D / L90D
--   NursingAndFeedingL30DayShopper / L60D / L90D
--   PersonalCareL30DayShopper / L60D / L90D
--   PlantsL30DayShopper / L60D / L90D
--   ShoesL30DayShopper / L60D / L90D
--   SwaddlingAndReceivingBlanketsL30DayShopper / L60D / L90D
--   TobaccoProductsL30DayShopper / L60D / L90D
--
-- LIFESTYLE segments (table: LIFESTYLE_SEGMENTS_L730D_20260429, format: segment_name_L730D_lookback):
--   anime_&_manga_L730D_lookback
--   athletic_performance_&_recovery_L730D_lookback
--   clean_&_non-toxic_obsession_L730D_lookback
--   cognitive_performance_&_nootropics_L730D_lookback
--   cruelty-free_&_vegan_L730D_lookback
--   dog_owners_L730D_lookback / cats_owners_L730D_lookback
--   functional_mushroom_&_adaptogen_users_L730D_lookback
--   gut_health_&_digestion_interest_L730D_lookback
--   high-intensity_&_bodybuilding_L730D_lookback
--   insta_luxe_L730D_lookback
--   it_girl_L730D_lookback
--   joint_pain_&_inflammation_relief_interest_L730D_lookback
--   longevity_&_anti-aging_science_L730D_lookback
--   menopause_support_interest_L730D_lookback
--   mindfulness_&_meditation_L730D_lookback
--   minimalist_luxe_essentials_L730D_lookback
--   new_parents_&_postpartum_L730D_lookback
--   organic_lifestyle_L730D_lookback
--   parents_of_school-age_children_L730D_lookback
--   parents_of_toddlers_&_young_children_L730D_lookback
--   premium_loungewear_L730D_lookback
--   running_&_endurance_L730D_lookback
--   sleep_optimization_interest_L730D_lookback
--   stress_&_anxiety_relief_interest_L730D_lookback
--   supports_female-founded_brands_L730D_lookback
--   sustainable_fashion_&_beauty_L730D_lookback
--   target_chic_L730D_lookback
--   weight_management_interest_L730D_lookback
--   working_mothers_L730D_lookback
--   yoga_&_pilates_L730D_lookback
--   (see AUDIENCES list in mosaic.html for all 160 segments)
--
-- CORE segments:
--   AnimalPetSupplies
--   ApparelAccessories
--   ArtsEntertainment
--   Automobile
--   Beauty
--   DTCDiscount / DTCNonDiscount
--   DTCFrequent
--   DTCHighAOV / DTCHighLTV
--   DTCMultiBrand
--   DTCOnline / DTCRecentOnline
--   DTCSubscription
--   Electronics
--   FoodBeverages
--   Health
--   HomeGarden
--   SportingGoods
--   Travel
--   YoungFamilyEssentials


-- ============================================================
-- PACKAGE 1: [Package Name]
-- ============================================================

CREATE OR REPLACE TABLE PROXIMA.PUBLIC.SPEC_[BRAND]_[PACKAGENAME] AS
WITH combined AS (

  SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
  FROM IDENTIFIER($tbl_s360)
  WHERE SEGMENT_NAME IN (
    'Segment Name Here'
  )
  AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL

  UNION ALL

  SELECT ADDRESS1 AS ADDRESS, CITY, STATE, ZIP
  FROM IDENTIFIER($tbl_s360_hh)
  WHERE SEGMENT_NAME IN (
    'Segment Name Here'
  )
  AND ADDRESS1 IS NOT NULL AND ZIP IS NOT NULL

  -- Uncomment if package includes Product segments
  -- UNION ALL
  -- SELECT ADDRESS, CITY, STATE, ZIP
  -- FROM IDENTIFIER($tbl_product)
  -- WHERE SEGMENT_NAME IN ('SegmentNameHere')
  -- AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

  -- Uncomment if package includes Lifestyle segments
  -- UNION ALL
  -- SELECT ADDRESS, CITY, STATE, ZIP
  -- FROM IDENTIFIER($tbl_lifestyle)
  -- WHERE SEGMENT_NAME IN ('segment_name_L730D_lookback')
  -- AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

  -- Uncomment if package includes Core segments
  -- UNION ALL
  -- SELECT ADDRESS, CITY, STATE, ZIP
  -- FROM IDENTIFIER($tbl_core)
  -- WHERE SEGMENT_NAME IN ('Health','DTCFrequent')
  -- AND ADDRESS IS NOT NULL AND ZIP IS NOT NULL

),
deduped AS (
  SELECT ADDRESS, CITY, STATE, ZIP,
    ROW_NUMBER() OVER (PARTITION BY ADDRESS, ZIP ORDER BY ADDRESS) AS rn
  FROM combined
)
SELECT ADDRESS, CITY, STATE, ZIP FROM deduped WHERE rn = 1;


-- ============================================================
-- PACKAGE 2: [Package Name]
-- ============================================================

-- (copy Package 1 block, update table name and segments)


-- ============================================================
-- PACKAGE 3: [Package Name]
-- ============================================================

-- (copy Package 1 block, update table name and segments)


-- ============================================================
-- FINAL: ALL PACKAGE COUNTS IN ONE RESULT
-- Add a line per package built above
-- ============================================================

SELECT '[Package 1 Name]' AS PACKAGE_NAME, COUNT(*) AS SIZE
FROM PROXIMA.PUBLIC.SPEC_[BRAND]_[PACKAGENAME]

UNION ALL
SELECT '[Package 2 Name]' AS PACKAGE_NAME, COUNT(*) AS SIZE
FROM PROXIMA.PUBLIC.SPEC_[BRAND]_[PACKAGENAME2]

UNION ALL
SELECT '[Package 3 Name]' AS PACKAGE_NAME, COUNT(*) AS SIZE
FROM PROXIMA.PUBLIC.SPEC_[BRAND]_[PACKAGENAME3]

ORDER BY PACKAGE_NAME;
