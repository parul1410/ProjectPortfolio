-- Cleaning data in SQL queries
use projectportfolio;
select * from nashvillehousing limit 5000;

-- standardize date format

select saledate, convert(saledate, date) from nashvillehousing;

update nashvillehousing
set SaleDate = convert(saledate,date);

use projectportfolio;
ALTER TABLE nashvillehousing
ADD SalesDateConverted Date;
 
update nashvillehousing
set SalesDateConverted = CONVERT(SALEDATE, DATE);
 
 select Saledate, salesDateConverted from nashvillehousing;
 
 -- populate property address data
 
select propertyaddress from nashvillehousing ;

select propertyaddress from nashvillehousing
where propertyaddress = "";

update nashvillehousing
set propertyaddress = 'null'
where propertyaddress = "";

update nashvillehousing
set propertyaddress = null
where propertyaddress = 'null';
 
select *
from nashvillehousing
where propertyaddress is null;

select *
from nashvillehousing
order by parcelid;

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
from nashvillehousing a
join nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, iFnull(a.propertyaddress,b.propertyaddress) as propadd
from nashvillehousing a
join nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

UPDATE a
SET PROPERTYADDRESS = ifnull(a.propertyaddress,b.propertyaddress);
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, iFnull(a.propertyaddress,b.propertyaddress) as propadd
from nashvillehousing a
join nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

-- breaking into address into individual columns (Address, city, state)

select propertyaddress from nashvillehousing;

select
substring(propertyaddress, 1, position(','in propertyaddress)) as address,
position(','in propertyaddress) as position
from nashvillehousing;

select
substring(propertyaddress, 1, position(','in propertyaddress)-1) as address
from nashvillehousing;

select PROPERTYADDRESS,
substring(propertyaddress, 1, position(','in propertyaddress)-1) as address,
substring(propertyaddress,position(','in propertyaddress)+1,length(propertyaddress)) as address
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress varchar(255);
 
update nashvillehousing
set PropertySplitAddress = substring(propertyaddress, 1, position(','in propertyaddress)-1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity varchar(255);
 
update nashvillehousing
set PropertySplitCity = substring(propertyaddress,position(','in propertyaddress)+1,length(propertyaddress));

-- breaking Owner address into split(Address, City, State)

select owneraddress from nashvillehousing;

select owneraddress,
substring_index(owneraddress, ',',1) as address,
substring_index(substring_index(owneraddress, ',',2),',',-1) as city,
substring_index(owneraddress, ',',-1) as state
from nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress varchar(255);
 
update nashvillehousing
set OwnerSplitAddress = substring_index(owneraddress, ',',1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity varchar(255);
 
update nashvillehousing
set OwnerSplitCity = substring_index(substring_index(owneraddress, ',',2),',',-1);

ALTER TABLE nashvillehousing
ADD OwnerSplitState varchar(255);
 
update nashvillehousing
set OwnerSplitState = substring_index(owneraddress, ',',-1);

select * from nashvillehousing;

-- Change Y & N to Yes & No in "Sold as Vacant' field

use projectportfolio;
select SoldAsVacant , count(soldasvacant) from nashvillehousing
group by soldasvacant
order by soldasvacant;

select SoldAsVacant,
case
when soldasvacant = 'Y' THEN 'Yes'
when soldasvacant = 'N' THEN 'No'
else soldasvacant
end as updtaedSoldasVacant
from nashvillehousing;

update nashvillehousing
set soldasvacant =
case
when soldasvacant = 'Y' THEN 'Yes'
when soldasvacant = 'N' THEN 'No'
else soldasvacant
end;

select SoldAsVacant from nashvillehousing
where soldasvacant = 'Y';

-- identify DUPLICATES

select *,
row_nuMBER () OVER (PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, saledate, legalreference order by uniqueId) row_num
from nashvillehousing
order by parcelid;

with RowNumCTE as(
select *,
row_nuMBER () OVER (PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, saledate, legalreference order by uniqueId) row_num
from nashvillehousing)
select * from rownumcte
where row_num>1
order by propertyaddress;

-- -- remove DUPLICATES

with RowNumCTE as(
select *,
row_nuMBER () OVER (PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, saledate, legalreference order by uniqueId) row_num
from nashvillehousing)
delete from nashvillehousing
using nashvillehousing
join RowNumCTE
on nashvillehousing.uniqueid = RowNumCTE.uniqueid
where row_num>1;

-- delete unused columns

select * from nashvillehousing;

alter table nashvillehousing
drop TaxDistrict;

alter table nashvillehousing
drop propertyaddress;

alter table nashvillehousing
drop owneraddress;

alter table nashvillehousing
drop saledate;



