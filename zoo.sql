CREATE DATABASE ZOO
GO
USE ZOO
GO

create table Building(
city varchar(20) ,
name varchar(20) primary key,
);

create table Enclosure(
id int identity primary key,
type varchar(20) unique,
);

create table Diet(
type varchar(20) unique,
schedule varchar(10)
);

create table Animal(
id int  primary key,
type varchar(20) ,
gender char(1) ,
enclosure varchar(20) REFERENCES Enclosure(type),
diet varchar(20) REFERENCES Diet(type),
zoo varchar(20)REFERENCES Building(name)
);

create table Employee(
id int identity primary key,
name varchar(20),
workplace  varchar(20) REFERENCES Building(name),
takingCareOf int REFERENCES Animal(id)
);


drop table  Employee
drop table  Animal
drop table  Diet
drop table  Enclosure
drop table  Building





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
select *from building

insert into Enclosure(type)
values('laminated glass')
insert into Enclosure(type)
values('nocturnal house')
insert into Enclosure(type)
values('wire fence')
select *from enclosure

insert into Diet(type,schedule)
values('meat','once')
insert into Diet(type,schedule)
values('insects','twice')
insert into Diet(type,schedule)
values('plants','once')
select *from Diet

insert into Animal(id,type,gender,enclosure,diet,zoo)
values(100,'lion','M','laminated glass','meat','Sunset Zoo')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(200,'lion','M','laminated glass','meat','Zoo Miami')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(300,'lion','F','laminated glass','meat','New York Zoo')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(400,'lion','F','laminated glass','meat','Chicago Wild Park')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(500,'lion','M','laminated glass','meat','Boston Zoo')

insert into Animal(id,type,gender,enclosure,diet,zoo)
values(101,'zebra','M','wire fence','plants','Sunset Zoo')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(201,'zebra','F','wire fence','plants','Zoo Miami')

insert into Animal(id,type,gender,enclosure,diet,zoo)
values(102,'lizard','F','nocturnal house','insects','Sunset Zoo')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(202,'lizard','M','nocturnal house','insects','Zoo Miami')
insert into Animal(id,type,gender,enclosure,diet,zoo)
values(301,'lizard','M','nocturnal house','insects','New York Zoo')

insert into Animal(id,type,gender,enclosure,diet,zoo)
values(103,'tiger','F','laminated glass','meat','Sunset Zoo')

insert into Animal(id,type,gender,enclosure,diet,zoo)
values(104,'impala','M','wire fence','plants','Sunset Zoo')

 
select *from Animal

delete from Animal where zoo='Zoo Miami' and type='zebra'

insert into Employee(name,workplace,takingCareOf)
values('Jeff Bingam','Zoo Miami',200)
insert into Employee(name,workplace,takingCareOf)
values('Jeff Bingam','Zoo Miami',201)
insert into Employee(name,workplace,takingCareOf)
values('John Leyes','Zoo Miami',202)

insert into Employee(name,workplace,takingCareOf)
values('Mya Stafford','Sunset Zoo',100)
insert into Employee(name,workplace,takingCareOf)
values('Mya Stafford','Sunset Zoo',101)
insert into Employee(name,workplace,takingCareOf)
values('Jim Sagga','Sunset Zoo',102)
insert into Employee(name,workplace,takingCareOf)
values('Jim Sagga','Sunset Zoo',103)
insert into Employee(name,workplace,takingCareOf)
values('Jim Sagga','Sunset Zoo',104)

insert into Employee(name,workplace,takingCareOf)
values('Charlie Roberts','New York Zoo',300)
insert into Employee(name,workplace,takingCareOf)
values('Charlie Roberts','New York Zoo',301)


insert into Employee(name,workplace,takingCareOf)
values('Lisa Richards','Chicago Wild Park',400)


insert into Employee(name,workplace,takingCareOf)
values('Greg Johnson','Boston Zoo',500)



select*from animal a
join diet d on d.type=a.diet
where d.type='plants'

--Изведете информация за всички служители, които се грижат за лъвове в зоопарковете.
select e.id,e.name,e.workplace
from Employee e
join animal a on a.id=e.takingCareOf and a.type='lion'

--Изведете всички  животни, които са тревопасни и се намират в зоопарк 'Sunset Zoo'
select *
from animal a
where a.diet='plants' and zoo='Sunset Zoo'

--Изведете всички градове,в които има зоопарк, в който има импала.
select city
from building b
join animal a on a.zoo=b.name
where a.type='impala'
