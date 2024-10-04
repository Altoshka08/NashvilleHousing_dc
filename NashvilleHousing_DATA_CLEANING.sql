CREATE TABLE NashvilleHousing(
	uniqueID INT,
	parcelID VARCHAR(225),
	LandUse VARCHAR(225),
	PropertyAddress  VARCHAR(225),
	SaleDate DATE,
	SalePrice VARCHAR(225),
	LegalReference VARCHAR(225),
	SoldAsVacant VARCHAR(20),
	OwnerName VARCHAR(255),
	OwnerAddress VARCHAR(255),
	Acreage NUMERIC,
	TaxDistrict VARCHAR(255),
	LandValue INT,
	BuildingValue INT,
	TotalValue INT,
	YearBuilt INT,
	Bedrooms INT,
	FullBath INT,
	HalfBath INT
);

SELECT * FROM NashvilleHousing

---Data cleaning in SQL

---Populate Property Adress Data

Select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
WHERE a.propertyAddress is null


UPDATE NashvilleHousing a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing b
WHERE a.parcelID = b.parcelID
AND a.uniqueID <> b.uniqueID
AND	a.propertyAddress is null

---Breaking out Address into individual columns(Address, City, Street)

SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,  POSITION(',' IN PropertyAddress) +1, LENGTH(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PROPERTYSPLITADDRESS VARCHAR(255)

UPDATE NashvilleHousing
SET PROPERTYSPLITADDRESS = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PROPERTYSPLITCITY VARCHAR(255)

UPDATE NashvilleHousing
SET PROPERTYSPLITCITY = SUBSTRING(PropertyAddress,  POSITION(',' IN PropertyAddress) +1, LENGTH(PropertyAddress))

SELECT * FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 1),
SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 2),
SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 3)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OWNERSPLITADDRESS VARCHAR(255)

UPDATE NashvilleHousing
SET OWNERSPLITADDRESS = SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 1)

ALTER TABLE NashvilleHousing
ADD OWNERSPLITCITY VARCHAR(255)

UPDATE NashvilleHousing
SET OWNERSPLITCITY = SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 2)

ALTER TABLE NashvilleHousing
ADD OWNERSPLITSTATE VARCHAR(255)

UPDATE NashvilleHousing
SET OWNERSPLITSTATE = SPLIT_PART(REPLACE(OwnerAddress, ',', '.'), '.', 3)

SELECT *
FROM NashvilleHousing

---Change N and Y to YES and NO on the soldasVacant solumn
--We're going to use CASE statement

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2

UPDATE NashvilleHousing
SET SoldasVacant = CASE 
		WHEN SoldasVacant = 'Y' THEN 'Yes'
		WHEN SoldasVacant = 'N'	THEN 'No'
		ELSE SoldASVacant
		END
		
---REMOVE DUPLICATES
--we want to patition our data
--we're using row number 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				)
				row_num
FROM NashvilleHousing
)
delete 
FROM NashvilleHousing
WHERE UniqueID IN (
	SELECT UniqueID
	FROM RowNumCTE
	WHERE row_num >1)
	
---delete unusible columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress,
DROP COLUMN propertyaddress,
DROP COLUMN taxdistrict,
DROP COLUMN saledate;



