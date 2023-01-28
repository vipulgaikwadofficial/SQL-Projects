-- OVERVIEW

SELECT * FROM housing_data..data

-- Sale Date format is in YYYY-MM-DD HH-MM-SS, we don't need the hours and minutes

SELECT SaleDate, CONVERT(Date, SaleDate) sale_date
FROM housing_data..data 

   -- Add a column for Converted sale date
ALTER TABLE data
ADD sale_date_conv date

UPDATE data
SET sale_date_conv = CONVERT(Date, SaleDate)
   
   -- CHECK 
SELECT sale_date_conv FROM housing_data..data 

--------------------------------------------------------------------------------

SELECT * FROM housing_data..data
WHERE PropertyAddress IS NULL
  
  -- There are some null values in property address, Hence we have to populate it. Self join it.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data..data a
JOIN housing_data..data b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

 -- UPDATE

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data..data a
JOIN housing_data..data b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

 -- CHECK
SELECT * FROM housing_data..data

-----------------------------------------------------------------------------------------------------------------

-- Splitting property address into individual columns

SELECT PropertyAddress FROM housing_data..data

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)) AS Address, 
CHARINDEX(',',PropertyAddress) -- Returns value at position 19 the comma is.
FROM housing_data..data

 -- Adding -1 will remove the comma
SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM housing_data..data

  -- UPDATE

ALTER TABLE data
ADD property_split_addreses nvarchar(255)

UPDATE data 
SET property_split_addreses = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE data
ADD property_split_city nvarchar(255)

UPDATE data
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

 -- CHECK
SELECT * FROM housing_data..data
--------------------------------------------------------------------------------------------------------------

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM housing_data..data

ALTER TABLE data
ADD owner_split_address nvarchar(255)

ALTER TABLE data
ADD owner_split_city nvarchar(255)

ALTER TABLE data
ADD owner_split_state nvarchar(255);

UPDATE data
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE data
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE data
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO in SOLD AS VACANT Field

SELECT DISTINCT(COUNT(SoldAsVacant)),
SoldAsVacant
FROM housing_data..data
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM housing_data..data

UPDATE data		
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

 -- CHECK
SELECT * FROM housing_data..data

----------------------------------------------------------------------------------

-- Remove Duplicates 

WITH row_num_cte AS (
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference 
ORDER BY UniqueID) AS row_num
FROM housing_data..data)
SELECT * FROM row_num_cte 
WHERE row_num >1
ORDER BY PropertyAddress

 -- Delete those rows
 WITH row_num_cte AS (
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference 
ORDER BY UniqueID) AS row_num
FROM housing_data..data)
DELETE FROM row_num_cte 
WHERE row_num >1

-----------------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMN 

SELECT * FROM housing_data..data 

ALTER TABLE data
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress, SaleDate

