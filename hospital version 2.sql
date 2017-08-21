--drop database if exists Hospital;
create database Hospital;
use Hospital;

create table Patient(
patientId int NOT NULL AUTO_INCREMENT ,
nhi char(7),
patientFname varchar(10),
patientLname varchar(10),
dob date,
gender char(6),
hte char(3),
primary key(patientId)
);

create table Department(
depName varchar(10) primary key,
waitList date,
fsa date
);

create table Surgeon(
empId int NOT NULL AUTO_INCREMENT,
sFname varchar(10),
sLname varchar(10),
depName varchar(10),
primary key(empId),
foreign key(depName) references Department(depName)
);

create table Reference(
refId int primary key,
refDate date,
refFrom char(8),
refFname varchar(10),
refLname varchar(10),
depName varchar(10),
patientId int,
foreign key(depName) references Department(depName),
foreign key(patientId) references Patient(patientId)
);