CREATE DATABASE ZOO
GO
USE ZOO
GO

create table Building(
city varchar(20) ,
name varchar(20) primary key,
);

create table Enclosure(
type varchar(20) primary key,
);


create table Animal(
id int primary key ,
species varchar(20) ,
gender char(1) ,
zoo varchar(20)REFERENCES Building(name)
);

create table Employee(
hireDate varchar(50),
name varchar(20) primary key,
);

create table Housing(
id int  REFERENCES Animal(id),
typeOfEnclosure varchar(20) REFERENCES Enclosure(type)
);

create table TakesCareOf(
 name varchar(20) REFERENCES Employee(name),
 animalId int  REFERENCES Animal(id),

);

create table WorksIn(
 name varchar(20) REFERENCES Employee(name),
 zoo varchar(20)  REFERENCES Building(name),
);

drop table  WorksIn
drop table  Housing
drop table  TakesCareOf
drop table  Employee
drop table  Animal
drop table  Building
drop table  Enclosure





insert into Building(city,name)
values('Miami','Sunset Zoo')
insert into Building(city,name)
values('New York','New York Zoo')
insert into Building(city,name)
values('Miami','Zoo Miami')
insert into Building(city,name)
values('Chicago','Chicago Wild Park')
insert into Building(city,name)
values('Boston','Boston Zoo')


insert into Enclosure(type)
values('laminated glass')
insert into Enclosure(type)
values('nocturnal house')
insert into Enclosure(type)
values('wire fence')



insert into Animal(id,species,gender,zoo)
values(100,'lion','M','Sunset Zoo')
insert into Animal(id,species,gender,zoo)
values(200,'lion','M','Zoo Miami')
insert into Animal(id,species,gender,zoo)
values(300,'lion','F','New York Zoo')
insert into Animal(id,species,gender,zoo)
values(400,'lion','F','Chicago Wild Park')
insert into Animal(id,species,gender,zoo)
values(500,'lion','M','Boston Zoo')

insert into Animal(id,species,gender,zoo)
values(101,'zebra','M','Sunset Zoo')
insert into Animal(id,species,gender,zoo)
values(201,'zebra','F','Zoo Miami')

insert into Animal(id,species,gender,zoo)
values(102,'lizard','F','Sunset Zoo')
insert into Animal(id,species,gender,zoo)
values(202,'lizard','M','Zoo Miami')
insert into Animal(id,species,gender,zoo)
values(301,'lizard','M','New York Zoo')

insert into Animal(id,species,gender,zoo)
values(103,'tiger','F','Sunset Zoo')

insert into Animal(id,species,gender,zoo)
values(104,'impala','M','Sunset Zoo')
 



insert into Employee(name,hireDate)
values('Jeff Bingam','2015-07-07')
insert into Employee(name,hireDate)
values('John Leyes','2015-01-03')
insert into Employee(name,hireDate)
values('Maya Stafford','2000-12-07')
insert into Employee(name,hireDate)
values('Jim Sagga','1999-07-12')
insert into Employee(name,hireDate)
values('Charlie Roberts','2015-10-07')
insert into Employee(name,hireDate)
values('Lisa Richards','2015-11-17')
insert into Employee(name,hireDate)
values('Greg Johnson','2012-11-17')




insert into Housing(id,typeOfEnclosure)
values(100,'laminated glass')
insert into Housing(id,typeOfEnclosure)
values(200,'laminated glass')
insert into Housing(id,typeOfEnclosure)
values(300,'laminated glass')
insert into Housing(id,typeOfEnclosure)
values(400,'laminated glass')
insert into Housing(id,typeOfEnclosure)
values(500,'laminated glass')
insert into Housing(id,typeOfEnclosure)
values(103,'laminated glass')

insert into Housing(id,typeOfEnclosure)
values(101,'wire fence')
insert into Housing(id,typeOfEnclosure)
values(201,'wire fence')
insert into Housing(id,typeOfEnclosure)
values(104,'wire fence')

insert into Housing(id,typeOfEnclosure)
values(102,'nocturnal house')
insert into Housing(id,typeOfEnclosure)
values(202,'nocturnal house')
insert into Housing(id,typeOfEnclosure)
values(301,'nocturnal house')


insert into TakesCareOf(name,animalId)
values('Maya Stafford',100)
insert into TakesCareOf(name,animalId)
values('Maya Stafford',101)
insert into TakesCareOf(name,animalId)
values('Jim Sagga',102)
insert into TakesCareOf(name,animalId)
values('Jim Sagga',103)
insert into TakesCareOf(name,animalId)
values('Jim Sagga',104)

insert into TakesCareOf(name,animalId)
values('Jeff Bingam',200)
insert into TakesCareOf(name,animalId)
values('Jeff Bingam',201)
insert into TakesCareOf(name,animalId)
values('John Leyes',202)

insert into TakesCareOf(name,animalId)
values('Charlie Roberts',300)
insert into TakesCareOf(name,animalId)
values('Charlie Roberts',301)

insert into TakesCareOf(name,animalId)
values('Lisa Richards',400)

insert into TakesCareOf(name,animalId)
values('Greg Johnson',500)



insert into WorksIn(name,zoo)
values('Maya Stafford','Sunset Zoo')
insert into WorksIn(name,zoo)
values('Jim Sagga','Sunset Zoo')

insert into WorksIn(name,zoo)
values('Jeff Bingam','Zoo Miami')
insert into WorksIn(name,zoo)
values('John Leyes','Zoo Miami')

insert into WorksIn(name,zoo)
values('Charlie Roberts','New York Zoo')
insert into WorksIn(name,zoo)
values('Lisa Richards','Chicago Wild Park')
insert into WorksIn(name,zoo)
values('Greg Johnson','Boston Zoo')



--Напишете заявка, която извежда всички животни, чиято клетка е от тип 'телена ограда'
select a.species,a.id 
from housing h
join animal a on a.id=h.id
where h.typeOfEnclosure='wire fence'


--Напишете заявка, която извежда имената на всички служители, които се грижат за лъвове в зоопарковете.
select t.name
from TakesCareOf t
join animal a on a.id=t.animalId
where a.species='lion'


--Напишете заявка, която извежда всички градове,в които има зоопарк, в който има импала.
select city
from building b
join animal a on a.zoo=b.name
where a.species='impala'

--Напишете заявка, която извежда всички работници в 'New York Zoo'.
select *
from WorksIn 
where zoo='New York Zoo'

--Напишете заявка, която извежда всички работници, които работят в град Маями .
select *
from WorksIn w
join building b on b.name=w.zoo
where city='Miami'

