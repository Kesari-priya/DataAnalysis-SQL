use practicedb;
--Cleaning Data with SQL Queries
select * from dbo.HousingData;

-- Standardizing Date Format

Select SaleDateConverted, Convert(Date, SaleDate) as NewDate
From dbo.HousingData;

Update dbo.HousingData
Set SaleDate= Convert(Date, SaleDate);

Alter Table dbo.HousingData
Add SaleDateConverted Date;

Update dbo.HousingData
Set SaleDateConverted= Convert(Date, SaleDate);

---------------------------------------------------------------------------------------------------------


-- Populate Property Address Data

Select * From dbo.HousingData order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
From dbo.HousingData a
join dbo.HousingData b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from dbo.HousingData a
Join dbo.HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

---------------------------------------------------------------------------------------------------------



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from dbo.HousingData
--where PropertyAddress is null
--order by ParcelID


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from dbo.HousingData;



Alter Table dbo.HousingData
Add PropertySplitAddress Nvarchar (255);

Update dbo.HousingData
Set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


Alter Table dbo.HousingData
Add PropertySplitCity Nvarchar (255);

Update dbo.HousingData
Set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));



Select * from dbo.HousingData;


Select OwnerAddress from dbo.HousingData;


Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From dbo.HousingData;



Alter Table dbo.HousingData
Add OwnerSplitAddress NVARCHAR(255);

update dbo.HousingData
SET OwnerSplitAddress= PARSENAME(Replace(OwnerAddress, ',', '.'), 3);



Alter Table dbo.HousingData
Add OwnerSplitCity NVARCHAR(255);

update dbo.HousingData
SET OwnerSplitCity= PARSENAME(Replace(OwnerAddress, ',', '.'), 2);



Alter Table dbo.HousingData
Add OwnerSplitState NVARCHAR(255);

update dbo.HousingData
SET OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1);



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from dbo.HousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant, 
	CASE when SoldAsVacant='Y' Then 'Yes'
			when SoldAsVacant='N' Then 'No'
		Else SoldAsVacant
	End
From dbo.HousingData
order by SoldAsVacant


Update dbo.HousingData
SET SoldAsVacant= CASE when SoldAsVacant='Y' Then 'Yes'
						when SoldAsVacant='N' Then 'No'
					Else SoldAsVacant
				  End


---------------------------------------------------------------------------------------------------------



-- Remove Duplicates



With CTE As(
Select *, 
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
			Order by
				 UniqueID
				 ) row_num
From dbo.HousingData
)

Delete from CTE 
where row_num > 1;
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


ALTER TABLE dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

Select * from dbo.HousingData;
