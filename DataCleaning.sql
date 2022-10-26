--Cleaning data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)

Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

--Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing

--Where PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Breaking out Address to Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySlpitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySlpitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not null

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
		PARSENAME(REPLACE(OwnerAddress,',','.'),2),
		PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not null

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					Else SoldAsVacant
					END

--Remove Duplicate

WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,	SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

Select *
From PortfolioProject.dbo.NashvilleHousing
