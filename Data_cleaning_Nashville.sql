select*
from Nashville

-- Date format cleaning

select saleDate, CONVERT(date, saleDate)
from Nashville

update Nashville
set saleDate=CONVERT(date, saleDate) -- this is not workink, let's look for an alternative

--alternative--
alter table Nashville
add sale_date_converted date
update Nashville
set sale_date_converted = CONVERT(date, saleDate)



select sale_date_converted
from Nashville

--- Populate pproperties adddress data---

select*
from Nashville
where PropertyAddress is null
order by ParcelID

select a.PropertyAddress , a.ParcelID , b.PropertyAddress, b.ParcelID, ISNULL( a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress= ISNULL( a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


--- Let us break address into individual columns (address, city and state)---

select PropertyAddress
from Nashville

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as address
from Nashville

alter table Nashville
add property_address nvarchar(255) 

update Nashville
set property_address  = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

alter table Nashville
add property_city nvarchar(255)  

update Nashville
set property_city  = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) 


select*
from Nashville


select OwnerAddress
from Nashville

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3), -- Since parsename only works with '.' we replace to change ',' into '.'
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from Nashville

alter table Nashville
add Owner_address nvarchar(255)

update Nashville
set Owner_address=PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

alter table Nashville
add Owner_city nvarchar(255)

update Nashville
set Owner_city=PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

alter table Nashville
add Owner_state nvarchar(255)
	
update Nashville
set Owner_state=PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

select*
from Nashville


---- Changing y and n to yes and no in 'Sold as vacant field'----

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
    when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	else SoldAsVacant
	end
from Nashville

update Nashville
set SoldAsVacant=case 
    when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	else SoldAsVacant
	end
from Nashville


----let us remove duplicates from our table

WITH rowNberCTE as( 
select*, 
ROW_NUMBER() over (partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num 
from Nashville)

select*
from rowNberCTE 
where row_num >1
order by PropertyAddress

/**WITH rowNberCTE as( 
select*, 
ROW_NUMBER() over (partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num 
from Nashville)

delete
from rowNberCTE 
where row_num >1
 This code came before the previous one, it removed duplicates when ran at once from the 'with statement'.
 also, note that deleting columns from  raw data is not advisable , it needs a legal authorization*/



 -------------- Now it is time to remove unuseful columns---------------
 select*
 from Nashville

 alter table Nashville
 drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate









