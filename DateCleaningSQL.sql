--DATA CLEANING IN SQL

Select*
From [dbo].[NashvilleHousing]

.......................................................................................................................................
 --STANDARDIZE DATE FORMAT

 Select SaleDate, CONVERT(Date, SaleDate)
 From [dbo].[NashvilleHousing]

 Update [dbo].[NashvilleHousing]
 Set SaleDate =  CONVERT(Date, SaleDate)

 -- If it doesn't Update properly

 ALTER TABLE[dbo].[NashvilleHousing]
 Add Saledate2 Date;

 Update [dbo].[NashvilleHousing]
 Set Saledate2 =  CONVERT(Date, SaleDate)

 Select Saledate2, CONVERT(Date, SaleDate)
 From [dbo].[NashvilleHousing]

..........................................................................................................................................

--POPULATE PROPERTY ADDRESS DATA

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From [dbo].[NashvilleHousing] as a
Join [dbo].[NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  
From [dbo].[NashvilleHousing] as a
Join [dbo].[NashvilleHousing] as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select*
From [dbo].[NashvilleHousing]
Order by ParcelID
..................................................................................................................................

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Adress, City, State)

Select PropertyAddress
From [dbo].[NashvilleHousing]

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
From [dbo].[NashvilleHousing]


ALTER TABLE[dbo].[NashvilleHousing]
 Add PropertySplitAddress nvarchar(255);

 Update [dbo].[NashvilleHousing]
 Set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

 ALTER TABLE[dbo].[NashvilleHousing]
 Add PropertySplitCity nvarchar(255);

 Update [dbo].[NashvilleHousing]
 Set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

 Select*
 From [dbo].[NashvilleHousing]
 .....................................................................................................................................

 --SPLITTING OWNER ADDRESS

 Select OwnerAddress
 From[dbo].[NashvilleHousing]

 Select
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
 ,  PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
 ,  PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
 From[dbo].[NashvilleHousing]

 ALTER TABLE[dbo].[NashvilleHousing]
 Add OwnerSplitAddress nvarchar(255);

 Update [dbo].[NashvilleHousing]
 Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

 ALTER TABLE[dbo].[NashvilleHousing]
 Add OwnerSplitCity nvarchar(255);

 Update [dbo].[NashvilleHousing]
 Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

 ALTER TABLE[dbo].[NashvilleHousing]
 Add OwnerSplitState nvarchar(255);

 Update [dbo].[NashvilleHousing]
 Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

 Select*
 From [dbo].[NashvilleHousing]
 .......................................................................................................................................

 --CHANGE Y AND N TO YES AND NO TO SOLD AS VACANT FIELD

 Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
 From [dbo].[NashvilleHousing]
 Group by SoldAsVacant


 Select SoldAsVacant,
 CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
 From [dbo].[NashvilleHousing]

 Update [dbo].[NashvilleHousing]
 Set  SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
 From [dbo].[NashvilleHousing]

 Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
 From [dbo].[NashvilleHousing]
 Group by SoldAsVacant
 ......................................................................................................................................

--Remove Duplicates (DONT DO THIS TO THE RAW DATA Ask before deleting anything from the database)

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) as row_num

From [dbo].[NashvilleHousing]
--Order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

...........................................................................................................................................

--DELETE UNUSED COLUMNS

Select*
From [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict






