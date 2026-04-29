-- ============================================================
-- MOSAIC MULTI-PACKAGE BUILD TEMPLATE
-- Update: (1) LIKE year patterns once a year
--         (2) Output table names and segments per package
-- ============================================================

-- ------------------------------------------------------------
-- STEP 0: AUTO-DETECT LATEST TABLE NAMES
-- Only update the year (2026%) once per year
-- ------------------------------------------------------------

SET tbl_s360 = (
  SELECT 'PROXIMA.PUBLIC.' || MAX(TABLE_NAME)
  FROM PROXIMA.INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = 'PUBLIC'
  AND TABLE_NAME LIKE 'SHOPPER360_SEGMENTS_2026%'
);

SET tbl_s360_hh = (
  SELECT 'PROXIMA.PUBLIC.' || MAX(TABLE_NAME)
  FROM PROXIMA.INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = 'PUBLIC'
  AND TABLE_NAME LIKE 'SHOPPER360_HH_SEGMENTS_2026%'
);

SET tbl_lifestyle = (
  SELECT 'PROXIMA.PUBLIC.' || MAX(TABLE_NAME)
  FROM PROXIMA.INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = 'PUBLIC'
  AND TABLE_NAME LIKE 'LIFESTYLE_SEGMENTS_2026%'
);

SET tbl_product = (
  SELECT 'PROXIMA.PUBLIC.' || MAX(TABLE_NAME)
  FROM PROXIMA.INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = 'PUBLIC'
  AND TABLE_NAME LIKE 'PRODUCT_SEGMENTS_2026%'
);

SET tbl_core = (
  SELECT 'PROXIMA.PUBLIC.' || MAX(TABLE_NAME)
  FROM PROXIMA.INFORMATION_SCHEMA.TABLES
  WHERE TABLE_SCHEMA = 'PUBLIC'
  AND TABLE_NAME LIKE 'CORE_SEGMENTS_2026%'
);

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
-- LIFESTYLE segments (spaces -> underscores, recency -> _L30D/_L60D/_L90D):
--   Insta_Luxe_L30D / L60D / L90D
--   Target_Chic_L30D / L60D / L90D
--   Premium_Loungewear_L30D / L60D / L90D
--   Workleisure_&_Modern_Business_Casual_L30D / L60D / L90D
--   Personalized_&_Sentimental_Gifting_L30D / L60D / L90D
--   IT_GIRL_L30D / L60D / L90D
--   Minimalist_Luxe_Essentials_L30D / L60D / L90D
--   Clean_&_Non-Toxic_Obsession_L30D / L60D / L90D
--   Golf_L30D / L60D / L90D
--   New_Parents_&_Postpartum_L30D / L60D / L90D
--   Parents_of_School-Age_Children_L30D / L60D / L90D
--   Parents_of_Toddlers_&_Young_Children_L30D / L60D / L90D
--   Working_Mothers_L30D / L60D / L90D
--   At-Home_Anti-Aging_Treatments_L30D / L60D / L90D
--   Athletic_Performance_&_Recovery_L30D / L60D / L90D
--   DIY_Beauty_&_At-Home_Salon_L30D / L60D / L90D
--   Dog_Owners_L30D / L60D / L90D
--   Pop_Culture_&_Fandom_L30D / L60D / L90D
--   Women's_Midlife_Wellness_Support_Interest_L30D / L60D / L90D
--   Sleep_Optimization_Interest_L30D / L60D / L90D
--   Stress_&_Anxiety_Relief_Interest_L30D / L60D / L90D
--   Weight_Management_Interest_L30D / L60D / L90D
--   Supports_Female-Founded_Brands_L30D / L60D / L90D
--   Cruelty-Free_&_Vegan_L30D / L60D / L90D
--   Sustainable_Fashion_&_Beauty_L30D / L60D / L90D
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
  -- WHERE SEGMENT_NAME IN ('Segment_Name_L60D')
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
