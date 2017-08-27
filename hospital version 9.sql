drop database if exists Hospital;
create database Hospital;
use Hospital;

-- Create table ReferFrom
create table ReferFrom(
typeId int not null auto_increment,
primary key(typeId),
refFrom varchar(15)
)engine=InnoDB;

-- Load table ReferFrom
load data local infile 'E:\\Referfrom.csv'
into table ReferFrom
lines terminated by '\n'
(refFrom);
select * from ReferFrom;

-- Create table Referee
create table Referee(
refereeId int not null auto_increment,
primary key(refereeId),
refFname varchar(10),
refLname varchar(10),
typeId int,
foreign key(typeId) references ReferFrom(typeId)
)engine=InnoDB;

-- Load table Referee
load data local infile 'E:\\Referee.csv'
into table Referee
fields terminated by ','
lines terminated by '\n'
(refFname,refLname);
-- SET typeId = (SELECT typeId FROM ReferFrom);
select * from Referee;

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
load data local infile 'E:\\Patient.csv'
into table Patient
fields terminated by ','
lines terminated by '\n'
(nhi,patientFname,patientLname,dob,gender,hte);
select * from Patient;

-- Derive Patient Age from Date of Birth
select floor(datediff(sysdate(),dob)/365.25) as 'Patient Age' from Patient;

-- Create table Department
 create table Department(
 depId int not null auto_increment, 
 primary key(depId),
 depName varchar(20) 
 )engine=InnoDB;
 
  -- Load table Department
load data local infile 'E:\\Department.csv'
into table Department
fields terminated by ','
lines terminated by '\n'
(depName);
select * from Department;

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
(sFname,sLname);
select * from Surgeon;

-- Create table Referral
 create table Referral(
 refId int not null auto_increment,
 refDate date,
 waitList date,
 fsa date,
 primary key(refId),
 patientId int,
 depId int,
 refereeId int,
 foreign key(depId) references Department(depId),
 foreign key(patientId) references Patient(patientId),
 foreign key(refereeId) references Referee(refereeId)
)engine=InnoDB;

-- Load table Referral
load data local infile 'E:\\Referral.csv'
into table Referral
fields terminated by ','
lines terminated by '\n'
(refDate,waitList,fsa);
select * from Referral;

-- Derive Waiting Days 
select datediff(fsa,refDate) as 'Days Waiting from Referrral Date'
from Referral;