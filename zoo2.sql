CREATE DATABASE ZOO
GO
USE ZOO
GO

create table Building(
id int primary key,
city varchar(20) ,
name varchar(20) unique,
);

create table Enclosure(
id int  primary key,
type varchar(20) unique,
);


create table Animal(
id int  primary key,
species varchar(20) ,
--type varchar(20), 
gender char(1) ,
--enclosure varchar(20) REFERENCES Enclosure(type),
--diet varchar(20) REFERENCES Diet(type),
zoo varchar(20)REFERENCES Building(name)
);

create table Employee(
id int  primary key,
name varchar(20),
);

create table typeOfAnimal(
 animalId int  REFERENCES Animal(id),
enclosure int  REFERENCES Enclosure(id)
);

create table takesCareOf(
 employeeId int  REFERENCES Employee(id),
 animalId int  REFERENCES Animal(id),
);

create table worksIn(
 employeeId int  REFERENCES Employee(id),
 zooId int  REFERENCES Building(id),
);

drop table  worksIn
drop table  typeOfAnimal
drop table  takesCareOf
drop table  Employee
drop table  Animal
drop table  Building
drop table  Enclosure





insert into Building(id,city,name)
values(1,'Miami','Sunset Zoo')
insert into Building(id,city,name)
values(2,'Miami','Zoo Miami')
insert into Building(id,city,name)
values(3,'New York','New York Zoo')
insert into Building(id,city,name)
values(4,'Chicago','Chicago Wild Park')
insert into Building(id,city,name)
values(5,'Boston','Boston Zoo')
select *from building

insert into Enclosure(id,type)
values(1,'laminated glass')
insert into Enclosure(id,type)
values(2,'nocturnal house')
insert into Enclosure(id,type)
values(3,'wire fence')
select *from enclosure



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
 
select *from Animal


insert into Employee(id,name)
values(10,'Maya Stafford')
insert into Employee(id,name)
values(11,'Jim Sagga')
insert into Employee(id,name)
values(20,'Jeff Bingam')
insert into Employee(id,name)
values(21,'John Leyes')
insert into Employee(id,name)
values(30,'Charlie Roberts')
insert into Employee(id,name)
values(40,'Lisa Richards')
insert into Employee(id,name)
values(50,'Greg Johnson')
select * from Employee


insert into typeOfAnimal(animalId,enclosure)
values(100,1)
insert into typeOfAnimal(animalId,enclosure)
values(200,1)
insert into typeOfAnimal(animalId,enclosure)
values(300,1)
insert into typeOfAnimal(animalId,enclosure)
values(400,1)
insert into typeOfAnimal(animalId,enclosure)
values(500,1)
insert into typeOfAnimal(animalId,enclosure)
values(103,1)

insert into typeOfAnimal(animalId,enclosure)
values(101,3)
insert into typeOfAnimal(animalId,enclosure)
values(201,3)
insert into typeOfAnimal(animalId,enclosure)
values(104,3)

insert into typeOfAnimal(animalId,enclosure)
values(102,2)
insert into typeOfAnimal(animalId,enclosure)
values(202,2)
insert into typeOfAnimal(animalId,enclosure)
values(301,2)

select * from animal a

insert into takesCareOf(employeeId,animalId)
values(10,100)
insert into takesCareOf(employeeId,animalId)
values(10,101)
insert into takesCareOf(employeeId,animalId)
values(11,102)
insert into takesCareOf(employeeId,animalId)
values(11,103)
insert into takesCareOf(employeeId,animalId)
values(11,104)

insert into takesCareOf(employeeId,animalId)
values(20,200)--Jeff takes care of a lion
insert into takesCareOf(employeeId,animalId)
values(20,201)--ansd Jeff takews care of a zebra
insert into takesCareOf(employeeId,animalId)--John leyes takes care of a lizard
values(21,202)

insert into takesCareOf(employeeId,animalId)
values(30,300)
insert into takesCareOf(employeeId,animalId)
values(30,301)

insert into takesCareOf(employeeId,animalId)
values(40,400)

insert into takesCareOf(employeeId,animalId)
values(50,500)

select * from takesCareOf

insert into worksIn(employeeId,zooId)
values(10,1)
insert into worksIn(employeeId,zooId)
values(11,1)
insert into worksIn(employeeId,zooId)
values(20,2)
insert into worksIn(employeeId,zooId)
values(21,2)
insert into worksIn(employeeId,zooId)
values(30,3)
insert into worksIn(employeeId,zooId)
values(40,4)
insert into worksIn(employeeId,zooId)
values(50,5)

select * from worksIn



--Напишете заявка, която извежда всички животни, чиято клетка е от тип 'телена ограда'
select * 
from animal a
join typeOfAnimal t on t.animalId=a.id
join enclosure e on t.enclosure=e.id
where e.type='wire fence'


--Напишете заявка, която извежда информация за всички служители, които се грижат за лъвове в зоопарковете.
select e.name,e.id
from Employee e
join takesCareOf t on e.id=t.employeeId
join animal a on a.id=t.animalId
where a.species='lion'


--Напишете заявка, която извежда всички градове,в които има зоопарк, в който има импала.
select city
from building b
join animal a on a.zoo=b.name
where a.species='impala'

--Напишете заявка, която извежда всички работници в 'New York Zoo'.
select e.id,e.name
from employee e
join worksIn w on e.id=w.employeeId
join building b on b.id=w.zooId
where b.name='New York Zoo'
