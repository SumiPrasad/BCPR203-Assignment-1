-- delete the database if exists 
drop database if exists SysmexHospital;
-- create and use the database
create database SysmexHospital;
use SysmexHospital;

-- ******************************************************************************************************************************************************
-- Create and Load the Tables

-- Create table ReferType
create table ReferType(
typeId int not null auto_increment,
primary key(typeId),
typeName varchar(14)
)engine=InnoDB;

-- Load table ReferFrom
load data local infile 'E:\\Refertype.csv'
into table ReferType
lines terminated by '\n'
(typeName);


-- Create table Referee
create table Referee(
refereeId int not null auto_increment,
primary key(refereeId),
refFname varchar(10),
refLname varchar(10),
typeId int ,
foreign key(typeId) references ReferType(typeId)
)engine=InnoDB;

-- Load table Referee
load data local infile 'E:\\Referee.csv'
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
gender varchar(6),
hte char(3),
primary key(patientId)
)engine=InnoDB;

 -- Load table Patient
load data local infile 'E:\\Patient.csv'
into table Patient
fields terminated by ','
lines terminated by '\n'
(nhi,patientFname,patientLname,dob,gender,hte);



-- Create table Department
 create table Department(
 depId int not null auto_increment, 
 primary key(depId),
 depName varchar(18) 
 )engine=InnoDB;
 
  -- Load table Department
load data local infile 'E:\\Department.csv'
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
load data local infile 'E:\\Surgeon.csv'
into table Surgeon
fields terminated by ','
lines terminated by '\n'
(sFname,sLname,depId);



-- Create table Referral
 create table Referral(
 refId int not null auto_increment,
 refDate date,
 waitList date,
 fsa date,
 primary key(refId),
 patientId int,
 surgeonId int,
 refereeId int,
 foreign key(patientId) references Patient(patientId),
 foreign key(surgeonId) references Surgeon(surgeonId),
 foreign key(refereeId) references Referee(refereeId)
)engine=InnoDB;

-- Load table Referral
load data local infile 'E:\\Referral.csv'
into table Referral
fields terminated by ','
lines terminated by '\n'
(refDate,waitList,fsa,patientId,surgeonId,refereeId);
set sql_safe_updates = 0; 

-- Update blank fsa field with current date
 -- update Referral set fsa = now() where fsa like '0000-00-00';
-- ******************************************************************************************************************************************************

-- Display the tables ReferType, Referee, Referral, Patient, Department and Surgeon

select typeID as 'Referral Type ID', typeName as 'Referred From' from ReferType;

select refereeId as 'Referee ID', refFname as 'Referee First Name', refLname as 'Referee Last Name', typeID as 'Referral Type ID' from Referee;


-- Derive Waiting Days and display the table Referral
select refId as 'Reference ID', refDate as 'Referral Date', waitList as 'Added to WaitList Date',fsa as 'FSA Date',patientId as 'Patient ID', 
surgeonId as 'Surgeon ID',refereeId as 'Referee ID',datediff(fsa,refDate) as 'Waitingdays' from Referral;


-- Derive Patient Age from Date of Birth and display the table Patient
select patientId as 'Patient ID', sha2('nhi',256) as 'Encrypted NHI',patientFname as 'Patient First Name',patientLname as 'Patient Last Name',
dob as 'DOB',gender as 'Gender',hte as 'HTE',floor(datediff(sysdate(),dob)/365.25) as 'Patient Age' from Patient;

select depId as 'Department ID', depName as 'Department Name' from Department;

select surgeonId as 'Surgeon ID', sFname as 'Surgeon First Name', sLname as 'Surgeon Last Name', depID as 'Department ID' from Surgeon;

-- ******************************************************************************************************************************************************

-- Queries

-- Q1 How many people have been referred for surgery?
select count(refId) 'Total Patients referred for Surgery' from Referral;


-- Q2 What is the average time taken to see a Surgeon by Department?
select Department.depName as 'Department Name',floor(avg(datediff(fsa,refDate))) 
as 'Average Days to see Surgeon' from Referral
join Surgeon on Referral.surgeonId = Surgeon.surgeonId
join Department on Surgeon.depId = Department.depId
group by depName;


-- Q3 Who has each Surgeon had on their list and how long have they been waiting or did they wait?
select Surgeon.surgeonId as 'Surgeon ID', concat_ws(" ",sFname,sLname) as 'Surgeon Nmae', concat(patientFname," ",patientLname) as 'Patient Name', 
 datediff(fsa,refDate) as 'Waiting Days',
 (case
 when datediff(fsa,refDate) > 0 
 then 'Yes' 
 else  'No' 
 end) as 'Waiting Status' from Patient
join Referral on Patient.patientId = Referral.patientId
join Surgeon on Referral.SurgeonId = Surgeon.surgeonId
order by Surgeon.surgeonId;


-- Q4 Assuming that all patients under 18 need to be seen by Paediatric Surgery, are there any patients who need to be reassigned? 
select Patient.patientId as  'Pateint ID', concat(patientFname," ",patientLname) as 'Patient Name', depName as 'Currently Assigned Department'
from Patient 
join Referral on Patient.patientId = Referral.patientId
join Surgeon on Referral.SurgeonId = Surgeon.surgeonId
join Department on Surgeon.depId = Department.depId
where (datediff(refDate,dob)/365.25) < 18 and Surgeon.depId <> 5  ;


-- Q5 What percentage of patient were seen within the target of 80 days by department?
-- Step 1
select Department.depName, count(refId) as 'Number of Patients seen within 80 days'
from Referral
join Surgeon on Surgeon.surgeonId = Referral.surgeonId and  datediff(fsa,refDate) < 80
join Department on Surgeon.depId = Department.depId
group by Department.depId;

-- Step 2
select Department.depName, count(refId) as 'Total Number of Patients seen'
from Referral
join Surgeon on Surgeon.surgeonId = Referral.surgeonId 
join Department on Surgeon.depId = Department.depId
group by Department.depId;

-- Step 3
select s.dep as 'Department Name',concat(floor((s.cnt/j.cnt) *100),'%') as 'Percentage'
from
(select  Department.depName as dep, count(refId) as cnt
from Referral
join Surgeon on Surgeon.surgeonId = Referral.surgeonId and  datediff(fsa,refDate) < 80
join Department on Surgeon.depId = Department.depId
group by Department.depId) s
cross join
(select Department.depName, count(refId) as cnt
from Referral
join Surgeon on Surgeon.surgeonId = Referral.surgeonId 
join Department on Surgeon.depId = Department.depId
group by Department.depId) j;






-- ******************************************************************************************************************************************************