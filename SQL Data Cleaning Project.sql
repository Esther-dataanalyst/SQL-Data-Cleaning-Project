--Cleaning Data in SQL Queries


--Standardize date format

SELECT*
FROM [Portfolio Project].dbo.['Nashville Housing$']


SELECT SaleDateConvert, CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.['Nashville Housing$']


UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio Project].dbo.['Nashville Housing$']
Add SaleDateConvert Date;

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET SaleDateConvert = CONVERT(Date,SaleDate)

--Populate Property Address Data

SELECT *
FROM [Portfolio Project].dbo.['Nashville Housing$']
WHERE PropertyAddress is NULL


SELECT a. ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.['Nashville Housing$'] a
JOIN [Portfolio Project].dbo.['Nashville Housing$'] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
 WHERE a. PropertyAddress IS NULL

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM [Portfolio Project].dbo.['Nashville Housing$'] a
JOIN [Portfolio Project].dbo.['Nashville Housing$'] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
 WHERE a. PropertyAddress IS NULL


--Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project].dbo.['Nashville Housing$']


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.['Nashville Housing$']

ALTER TABLE [Portfolio Project].dbo.['Nashville Housing$']
Add PropertySplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio Project].dbo.['Nashville Housing$']
Add PropertySplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT*
FROM [Portfolio Project].dbo.['Nashville Housing$']

SELECT OwnerAddress
FROM [Portfolio Project].dbo.['Nashville Housing$']

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.['Nashville Housing$']



ALTER TABLE [Portfolio Project].dbo.['Nashville Housing$']
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Portfolio Project].dbo.['Nashville Housing$']
Add OwnerSplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Portfolio Project].dbo.['Nashville Housing$']
Add OwnerSplitState Nvarchar(255);

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Changing Y and N to Yes and No in "Sold as Vacant field"

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.['Nashville Housing$']
GROUP BY SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Project].dbo.['Nashville Housing$']

UPDATE [Portfolio Project].dbo.['Nashville Housing$']
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END


--Removing Duplicates

WITH RownumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID
			   ) row_num
FROM [Portfolio Project].dbo.['Nashville Housing$']
)
DELETE
FROM RownumCTE
WHERE row_num >1
--ORDER BY PropertyAddress