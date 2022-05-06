/* 

Cleaning Data in SQL Queries

*/

USE PortfolioProject;

Select *
from PortfolioProject.dbo.NashHousing



--------------------------------------------------------------------------------------------------------------------------------------


-- Standardize Data Format

Update NashHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashHousing
Add SaleDateConverted Date;

Update NashHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashHousing


-------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashHousing a
JOIN PortfolioProject.dbo.NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashHousing a
JOIN PortfolioProject.dbo.NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Indivitual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From PortfolioProject.dbo.NashHousing


ALTER TABLE NashHousing
Add PropertySplitAddress Nvarchar(255);

Update NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashHousing
Add PropertySplitCity Nvarchar(255);

Update NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Select *
--from PortfolioProject.dbo.NashHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashHousing



-- OwnerSPlitAddress

ALTER TABLE NashHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- OwnerSplitCity

ALTER TABLE NashHousing
Add OwnerSplitCity Nvarchar(255);

Update NashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- OwnerSplitState

ALTER TABLE NashHousing
Add OwnerSplitState Nvarchar(255);

Update NashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
from PortfolioProject.dbo.NashHousing





----------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Solid as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashHousing
Group by SoldAsVacant
Order by 2

-- Using CASE statement to change Y and N to Yes and No

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject.dbo.NashHousing

Update NashHousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'Yes'
					When SoldAsVacant = 'N' THEN 'No'
					Else SoldAsVacant
					END





------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





--------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashHousing
DROP COLUMN SaleDate

-- Confirm Columns have been dropped

Select *
from PortfolioProject.dbo.NashHousing



----------------------------------------------------------------------------------------------------------

-- Check Data without fields with NULL values


Select *
from PortfolioProject.dbo.NashHousing
WHERE OwnerName IS NOT NULL
AND Acreage IS NOT NULL
AND LandValue IS NOT NULL
AND BuildingValue IS NOT NULL
AND TotalValue IS NOT NULL
AND YearBuilt IS NOT NULL
AND Bedrooms IS NOT NULL
AND FullBath IS NOT NULL
AND HalfBath IS NOT NULL
AND OwnerSplitAddress IS NOT NULL
AND OwnerSplitCity IS NOT NULL
AND OwnerSplitState IS NOT NULL;



-- Create View to Store Data without NULL values

Use PortfolioProject
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create View NashHousingClean AS
Select *
from PortfolioProject.dbo.NashHousing
WHERE OwnerName IS NOT NULL
AND Acreage IS NOT NULL
AND LandValue IS NOT NULL
AND BuildingValue IS NOT NULL
AND TotalValue IS NOT NULL
AND YearBuilt IS NOT NULL
AND Bedrooms IS NOT NULL
AND FullBath IS NOT NULL
AND HalfBath IS NOT NULL
AND OwnerSplitAddress IS NOT NULL
AND OwnerSplitCity IS NOT NULL
AND OwnerSplitState IS NOT NULL;

GO


Select *
from PortfolioProject.dbo.NashHousingClean

