--CLEANING DATA WITH SQL QUEREIS
SELECT *
FROM DATACLEANING.. NashvilleHousing

--STANDARDIZE DATETIME FORMAT
SELECT SaleDateConverted, CONVERT(datetime, SaleDate)
FROM DATACLEANING.. NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATETIME

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(datetime, SaleDate)


--POPOULATE PROPERTY ADDRESS DATA
SELECT *
FROM DATACLEANING.. NashvilleHousing
--Where PropertyAddress is NULL
ORDER BY ParcelID

SELECT n.ParcelID, n.PropertyAddress, h.ParcelID, h.PropertyAddress, ISNULL(n.PropertyAddress, h.PropertyAddress)
FROM DATACLEANING.. NashvilleHousing n
JOIN DATACLEANING.. NashvilleHousing h
    ON n.ParcelID = h.ParcelID
    AND n.UniqueID <> h.UniqueID
WHERE n.PropertyAddress is NULL

UPDATE n
SET PropertyAddress = ISNULL(n.PropertyAddress, h.PropertyAddress)
FROM DATACLEANING.. NashvilleHousing n
JOIN DATACLEANING.. NashvilleHousing h
    ON n.ParcelID = h.ParcelID
    AND n.UniqueID <> h.UniqueID
WHERE n.PropertyAddress is NULL


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMES (ADDRESS, CITY, STATE)
--PROPERTY ADDRESS- USING SUBSTRING & CHARINDEX:
SELECT PropertyAddress
FROM DATACLEANING.. NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM DATACLEANING.. NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress -1)) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress +1), LEN(PropertyAddress)) as Address
FROM DATACLEANING.. NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress -1))

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR (255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress +1), LEN(PropertyAddress))

SELECT *
FROM DATACLEANING.. NashvilleHousing


--OWNER ADDRESS- USING PARSENAME: 
SELECT OwnerAddress
FROM DATACLEANING.. NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress ,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress ,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress ,',', '.'), 1)
FROM DATACLEANING.. NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress ,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress ,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR (255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress ,',', '.'), 1)

SELECT *
FROM DATACLEANING.. NashvilleHousing


--CHANGE Y AND N AS YES AND NO IN 'SOLDASVACANT' FIELD
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From DATACLEANING.. NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
From DATACLEANING.. NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END


--REMOVE DUPLICATES
WITH ROWNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) Row_num
FROM DATACLEANING.. NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM ROWNumCTE
WHERE Row_num > 1
--ORDER BY PropertyAddress

WITH ROWNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY UniqueID) Row_num
FROM DATACLEANING.. NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM ROWNumCTE
WHERE Row_num > 1
ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS
SELECT *
FROM DATACLEANING.. NashvilleHousing

ALTER TABLE DATACLEANING..NashvilleHousing
DROP COLUMN TaxDistrict, OwnerAddress

