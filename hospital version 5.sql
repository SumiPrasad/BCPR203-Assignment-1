drop database if exists Hospital;
create database Hospital;
use Hospital;

create table ReferFrom(
typeId int not null auto_increment,
primary key(typeId),
refFrom varchar(10)
)engine=InnoDB;

-- Load external file
load data local infile 'H:\\ARA Referfrom.csv'
into table ReferFrom
-- fields terminated by ','
lines terminated by '\n'
(refFrom);

select * from ReferFrom;
  
create table Refree(
refreeId int not null auto_increment,
primary key(refreeId),
refFname varchar(10),
refLname varchar(10),
typeId int,
foreign key(typeId) references ReferFrom(typeId)
);
drop table if exists Patient;
create table Patient(
patientId int not null auto_increment,
nhi char(7),
patientFname varchar(10),
patientLname varchar(10),
dob date,
gender char(6),
hte char(3),
primary key(patientId)
);

-- Load external file
load data local infile 'H:\\ARA DATA Patient.csv'
into table Patient
fields terminated by ','
lines terminated by '\n'
(nhi,patientFname,patientLname,dob,gender,hte);
select * from Patient;

create table Department(
depId int not null auto_increment, 
primary key(depId),
depName varchar(10) 
);

create table Surgeon(
surgeonId int not null auto_increment,
sFname varchar(10),
sLname varchar(10),
primary key(surgeonId),
depId int,
foreign key(depId) references Department(depId)
);

create table Referal(
refId int primary key,
refDate date,
waitList date,
fsa date,
patientId int,
depId int,
refreeId int,
foreign key(depId) references Department(depId),
foreign key(patientId) references Patient(patientId),
foreign key(refreeId) references Refree(refreeId)
);