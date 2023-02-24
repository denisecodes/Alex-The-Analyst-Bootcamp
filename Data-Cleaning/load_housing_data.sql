DROP TABLE IF EXISTS housing_data;
CREATE TABLE housing_data(
UniqueID VARCHAR(20),
ParcelID VARCHAR(50),
LandUse VARCHAR(50),
PropertyAddress VARCHAR(100),
SaleDate VARCHAR(50),
SalePrice FLOAT,
LegalReference VARCHAR(50),
SoldAsVacant VARCHAR (10),
OwnerName VARCHAR(100),
OwnerAddress VARCHAR(100),
Acreage FLOAT,
TaxDistrict VARCHAR(50),
LandValue INT,
BuildingValue INT,
TotalValue INT,
YearBuilt INT,
Bedrooms SMALLINT,
FullBath SMALLINT,
HalfBath SMALLINT
);

LOAD DATA LOCAL INFILE '/Users/denisechan/Documents/Alex The Analyst Bootcamp/Data-Cleaning/Nashville Housing Data for Data Cleaning.csv'
INTO TABLE housing_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

SET GLOBAL local_infile=1;

SELECT * FROM housing_data;
