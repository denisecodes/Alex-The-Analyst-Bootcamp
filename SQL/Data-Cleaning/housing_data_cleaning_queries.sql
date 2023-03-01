-- Standardize Date Format

SELECT CONVERT(SaleDate, DATE) AS SaleDate
FROM housing_data;

-- The update query did not work so added a new column called SaleDate Converted instead
-- to standardize date format in a new column

UPDATE housing_data
SET SaleDate = CONVERT(SaleDate, DATE);

ALTER TABLE housing_data
ADD COLUMN SaleDateConverted Date;

UPDATE housing_data
SET SaleDateConverted = CONVERT(SaleDate, DATE);

SELECT SaleDateConverted
FROM housing_data;

-- Populate Property Address data
-- Set property address field as NULL if empty
UPDATE housing_data SET PropertyAddress=IF(PropertyAddress='',NULL,PropertyAddress);

SELECT *
FROM housing_data
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Self Join 
-- COALESE converts NULL values from one column to another value specified after it

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM housing_data a
JOIN housing_data b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- USE TEMPORARY TABLE TO UPDATE Property Address 

DROP TEMPORARY TABLE IF EXISTS UpdatePropertyAddress;
CREATE TEMPORARY TABLE UpdatePropertyAddress(
a_ParcelID VARCHAR(50), 
a_PropertyAddress VARCHAR(100), 
b_ParceID VARCHAR(50), 
b_Property_Address VARCHAR(100)
);
INSERT INTO UpdatePropertyAddress
(SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM housing_data a
JOIN housing_data b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL);

UPDATE housing_data
INNER JOIN UpdatePropertyAddress
ON housing_data.ParcelID = UpdatePropertyAddress.a_ParcelID
SET housing_data.PropertyAddress = UpdatePropertyAddress.b_Property_Address;

-- Returns no NULL values, shows that PropertyAddress has been updated

SELECT * 
FROM housing_data
WHERE PropertyAddress IS NULL;

-- Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM housing_data;

-- USE SUBSTRING function to look at property address column at position one. Use LOCATE function to look 
-- for a specific string/char, in a particular column name, returning the char num  ',' is located at, 
-- so adding -1 at the end of the SUBSTRING function would take away the comma

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(",", PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(",", PropertyAddress) +1, LENGTH(PropertyAddress)) AS City
FROM housing_data;

ALTER TABLE housing_data
ADD COLUMN PropertySplitAddress NVARCHAR(255);

UPDATE housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(",", PropertyAddress) -1);

ALTER TABLE housing_data
ADD COLUMN PropertySplitCity NVARCHAR(255);

UPDATE housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(",", PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity 
FROM housing_data;

-- USE SUBSTRING_INDEX instead of SUBSTRING to split the Owner Address

SELECT OwnerAddress
FROM housing_data;

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',', -1) AS City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM housing_data;

ALTER TABLE housing_data
ADD COLUMN OwnerSplitAddress NVARCHAR(255);

UPDATE housing_data
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE housing_data
ADD COLUMN OwnerSplitCity NVARCHAR(255);

UPDATE housing_data
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',', -1);

ALTER TABLE housing_data
ADD COLUMN OwnerSplitState NVARCHAR(255);

UPDATE housing_data
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM housing_data;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing_data
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

-- This query is not able to show 'Y' and 'N' results, leading to the next error

SELECT SoldAsVacant,
CASE
	WHEN 'Y' THEN 'Yes'
	WHEN 'N' THEN 'No'
    ELSE SoldAsVacant
END AS SoldAsVacantUpdated
FROM housing_data;

-- Unfortunately this did not work for me in MySQL Workbench 
-- I get error code 1292, Truncated incorrected Double value: 'Y'
-- Tried to google, created a simple test table to solve this error but nothing worked.

UPDATE housing_data
SET SoldAsVacant = CASE
	WHEN 'Y' THEN 'Yes'
	WHEN 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- As CASE WHEN did not work, I hfound an alternative method using UPDATE TABLE below.

UPDATE housing_data
SET SoldasVacant = 'Yes'
WHERE SoldasVacant = 'Y';

UPDATE housing_data
SET SoldasVacant = 'No'
WHERE SoldasVacant = 'N';

-- Remove Duplicates
-- PARTITION BY values that should be unique, where ROW_NUMBER returns the row_num 
-- Gives error 1288, saying target CTE of the DELETE is not updatable 

WITH Row_Num_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
					UniqueID
                    ) AS row_num
FROM housing_data)
DELETE
FROM Row_Num_CTE
WHERE row_num > 1;

-- ChatGPT suggested the following and it worked

DELETE FROM housing_data
WHERE UniqueID NOT IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
            ORDER BY UniqueID
        ) AS row_num
        FROM housing_data
    ) subquery
    WHERE row_num = 1
);

-- Delete Unused Columns

ALTER TABLE housing_data
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

-- Check final data cleaning results
SELECT * FROM housing_data
