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
refFrom varchar(15) not null
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
refFname varchar(10) not null,
refLname varchar(10) not null,
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
patientFname varchar(10) not null,
patientLname varchar(10) not null,
dob date not null,
gender enum('MALE','FEMALE','OTHER'),
hte char(3) not null,
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
 sFname varchar(10) not null,
 sLname varchar(10) not null,
 primary key(surgeonId),
 depId int not null,
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
 waitList date not null,
 fsa date not null,
 primary key(waitlistId),
 surgeonId int not null,
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
 refDate date not null,
 primary key(refId),
 waitlistId int not null,
 patientId int not null,
 refereeId int not null,
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


select surgeonId as 'Surgeon ID', sFname as 'Surgeon First Name', sLname as 'Surgeon Last Name', depID as 'Department ID' from Surgeon;

select depId as 'Department ID', depName as 'Department Name' from Department;

-- Set the FSA date to current date if null
-- To resolve safe update mode Errorcode 1175 
set sql_safe_updates = 0; 
update Waitlistpatient set fsa = sysdate() where fsa is null;

-- Derive Waiting Days and display the table Waitlistpatient
select Waitlistpatient.waitlistId as 'Wait List ID',surgeonId as 'Surgeon ID' , waitList as 'Added to WaitList Date',fsa as 'FSA Date',
datediff(fsa,refDate) as 'Waiting Days'
from Waitlistpatient
inner join Referral
on Waitlistpatient.waitlistId = Referral.refId ;

select refId as 'Reference ID',refDate as 'Referral Date', waitlistId as 'Waiting List Patient ID', patientId as 'Patient ID', 
refereeId as 'Referee ID' from Referral;

-- Derive Patient Age from Date of Birth and display the table Patient
select Patient.patientId as 'Patient ID', sha2('nhi',256) as 'Encrypted NHI',patientFname as 'Patient First Name',patientLname as 'Patient Last Name',
dob as 'DOB',gender as 'Gender',hte as 'HTE',floor(datediff(refDate,dob)/365.25) as 'Patient Age' from Patient
inner join Referral
on Patient.patientId = Referral.refId ;

-- ******************************************************************************************************************************************************

-- Queries

-- Q1 How many people have been referred for surgery?
select count(nhi) 'Total Patients referred for Surgery' from Patient;

-- Q2 What is the average time taken to see a Surgeon by Department?

-- Q3 Who has each Surgeon had on their list and how long have they been waiting or did they wait?

-- Q4 Assuming that all patients under 18 need to be seen by Paediatric Surgery, are there any patients who need to be reassigned? 



-- Q5 What percentage of patient were seen within the target of 80 days by department?
select (count(refId)/100)*100  as 'Percentage' from Referral
join Waitlistpatient
on datediff(fsa,refDate) < '80';

-- ******************************************************************************************************************************************************