-- delete the database if exists
drop database if exists Hospital;
-- create and use the database
create database Hospital;
use Hospital;

-- ******************************************************************************************************************************************************
-- Create and Load the Tables

-- Create table ReferFrom
create table ReferFrom(
typeId int not null auto_increment,
primary key(typeId),
refFrom varchar(15)
)engine=InnoDB;

-- Load table ReferFrom
load data local infile 'H:\\Referfrom.csv'
into table ReferFrom
lines terminated by '\n'
(refFrom);

-- Create table Referee
create table Referee(
refereeId int not null auto_increment,
primary key(refereeId),
refFname varchar(10),
refLname varchar(10),
typeId int ,
foreign key(typeId) references ReferFrom(typeId)
)engine=InnoDB;

-- Load table Referee
load data local infile 'H:\\Referee.csv'
into table Referee
fields terminated by ','
lines terminated by '\n'
(refFname,refLname,typeId);

-- Create table Patient
create table Patient(
patientId int not null auto_increment,
nhi char(7),
patientFname varchar(10),
patientLname varchar(10),
dob date,
gender enum('MALE','FEMALE','OTHER'),
hte char(3),
primary key(patientId)
)engine=InnoDB;

 -- Load table Patient
load data local infile 'H:\\Patient.csv'
into table Patient
fields terminated by ','
lines terminated by '\n'
(nhi,patientFname,patientLname,dob,gender,hte);


-- Create table Department
 create table Department(
 depId int not null auto_increment, 
 primary key(depId),
 depName varchar(20) 
 )engine=InnoDB;
 
  -- Load table Department
load data local infile 'H:\\Department.csv'
into table Department
fields terminated by ','
lines terminated by '\n'
(depName);


-- Create table Surgeon
 create table Surgeon(
 surgeonId int not null auto_increment,
 sFname varchar(10),
 sLname varchar(10),
 primary key(surgeonId),
 depId int,
 foreign key(depId) references Department(depId)
 )engine=InnoDB;
 
-- Load table Surgeon
load data local infile 'H:\\Surgeon.csv'
into table Surgeon
fields terminated by ','
lines terminated by '\n'
(sFname,sLname,depId);

-- Create table Waitpatient
 create table Waitlistpatient (
 waitlistId int not null auto_increment,
 waitList date,
 fsa date,
 primary key(waitlistId),
 surgeonId int,
 foreign key(surgeonId) references Surgeon(surgeonId)
 )engine=InnoDB;
 
-- Load table Waitlist
load data local infile 'H:\\Waitlistpatient.csv'
into table Waitlistpatient
fields terminated by ','
lines terminated by '\n'
(surgeonId,waitList,fsa);

-- Create table Referral
 create table Referral(
 refId int not null auto_increment,
 refDate date,
 primary key(refId),
 waitlistId int,
 patientId int,
 refereeId int,
 foreign key(waitlistId) references Waitlistpatient(waitlistId),
 foreign key(patientId) references Patient(patientId),
 foreign key(refereeId) references Referee(refereeId)
)engine=InnoDB;

-- Load table Referral
load data local infile 'H:\\Referral.csv'
into table Referral
fields terminated by ','
lines terminated by '\n'
(refDate,waitlistId,patientId,refereeId);

-- ******************************************************************************************************************************************************

-- Display the tables ReferFrom, Referee, Referral, Patient, Surgeon,Department and Waitlistpatient

select typeID as 'Type ID', refFrom as 'Referred From' from ReferFrom;

select refereeId as 'Referee ID', refFname as 'Referee First Name', refLname as 'Referee Last Name', typeID as 'Type ID' from Referee;

-- Derive Patient Age from Date of Birth and display the table Patient
select patientId as 'Patient ID', sha2('nhi',256) as 'Encrypted NHI',patientFname as 'Patient First Name',patientLname as 'Patient Last Name',
dob as 'DOB',gender as 'Gender',hte as 'HTE',floor(datediff(sysdate(),dob)/365.25) as 'Patient Age' from Patient;

select surgeonId as 'Surgeon ID', sFname as 'Surgeon First Name', sLname as 'Surgeon Last Name', depID as 'Department ID' from Surgeon;

select depId as 'Department ID', depName as 'Department Name' from Department;

-- Derive Waiting Days and display the table Waitlistpatient
select waitlistId as 'Wait List ID',surgeonId as 'Surgeon ID' , waitList as 'Added to WaitList Date',fsa as 'FSA Date' from Waitlistpatient;
 
 
select refId as 'Reference ID',refDate as 'Referral Date', waitlistId as 'Waiting List Patient ID', patientId as 'Patient ID', 
refereeId as 'Referee ID' from Referral;



-- ******************************************************************************************************************************************************

-- Queries

-- Q1 How many people have been referred for surgery?
select count(nhi) 'Total Patients for Surgery' from Patient;

-- Q4 Assuming that all patients under 18 need to be seen by Paediatric Surgery, are there
-- any patients who need to be reassigned? 
select distinct Patient.patientFname,Patient.patientLname
from Patient 
join Department
on (select Department.depName  not like 'Paediatric Surgery'
where floor(datediff(sysdate(),dob)/365.25) < '18');


-- Q5 What percentage of patient were seen within the target of 80 days by department?
select (count(refId)/100)*100  as 'Percentage' from Referral
where datediff(fsa,refDate) < '80';

-- ******************************************************************************************************************************************************