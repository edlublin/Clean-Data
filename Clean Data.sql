CREATE table dacl (UniqueID numeric,
				   ParcelID	 text,
				   LandUse text,
				   PropertyAddress text,
				   SaleDate date,
				   SalePrice numeric,
				   LegalReference text,
				   SoldAsVacant text,
				   OwnerName text,
				   OwnerAddress text,
				   Acreage numeric,
				   TaxDistrict text,
				   LandValue numeric,
				   BuildingValue numeric,
				   TotalValue numeric,
				   YearBuilt numeric,
				   Bedrooms numeric,
				   FullBath numeric,
				   HalfBath numeric)
				   
select * from dacl 

-- Populate property address

select propertyaddress from dacl
where propertyaddress is null

select a.parcelid, coalesce(a.propertyaddress, b.propertyaddress) as propertyaddress, b.parcelid, b.propertyaddress from dacl a
join dacl b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is not null

update dacl as a
set propertyaddress = b.propertyaddress from dacl b
where a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid and
a.propertyaddress is null

select a.parcelid,a.propertyaddress, b.parcelid, b.propertyaddress from dacl a
join dacl b
on a.parcelid = b.parcelid

-- Breaking out Address into single column (address, city, state)

select propertyaddress, split_part(propertyaddress, ',', 1) splitaddress,
		split_part(propertyaddress, ',', 2) splitcity
from dacl 

alter table dacl
add propertysplitaddress varchar(250)

update dacl
set propertysplitaddress = split_part(propertyaddress, ',', 1)

alter table dacl
add propertysplitcity varchar(250) 

update dacl
set propertysplitcity = split_part(propertyaddress, ',', 2)


select owneraddress, split_part(owneraddress, ',', 1),
split_part(owneraddress, ',', 2), split_part(owneraddress, ',', 3)
from dacl

alter table dacl
add ownersplitaddress varchar(250)

update dacl
set ownersplitaddress = split_part(owneraddress, ',', 1)

alter table dacl
add ownersplitcity varchar(250)

update dacl
set ownersplitcity = split_part(owneraddress, ',', 2)

alter table dacl
add ownersplitdistrict varchar (250)

update dacl
set ownersplitdistrict = split_part(owneraddress, ',', 3)

select * from dacl
where ownersplitdistrict is not null


-- Change Y and N to YES and NO in 'Soldasvacant' field

select distinct(soldasvacant), count(*) from dacl
group by soldasvacant
order by 2

select soldasvacant, 
CASE 
	when soldasvacant = 'Y' then 'YES'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
end
from dacl

UPDATE dacl
set soldasvacant = CASE 
	when soldasvacant = 'Y' then 'YES'
	when soldasvacant = 'N' then 'No'
	when soldasvacant = 'YES' then 'Yes'
	else soldasvacant
end

select distinct(soldasvacant), count(*) from dacl
group by soldasvacant
order by 2

-- Remove Duplicates

delete from dacl
		where uniqueid in (
			select uniqueid from ( 
			SELECT *, 
				row_number() over (
				partition by parcelId,
							propertyaddress,
							saleprice,
							saledate,
							legalreference
							order by 
								uniqueid
									) as row_num
			from dacl) as x
			where x.row_num > 1); 

select * from ( 
			SELECT *, 
				row_number() over (
				partition by parcelId,
							propertyaddress,
							saleprice,
							saledate,
							legalreference
							order by 
								uniqueid
									) as row_num
			from dacl) as x
where x.row_num > 1

-- Delete unused Columns

select * from dacl

alter table dacl
drop column saledate