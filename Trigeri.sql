-- 1. Да се направи така, че при добавяне
-- на нов клас автоматично да се добавя и
-- нов кораб със същото име и с година на
-- пускане на вода = null.
use ships;
go
create trigger t1
on classes
after insert
as
	insert into ships(name, class)
	select class, class
	from inserted;

-- тестване:
insert into classes
values('Test', 'bb', 'Bulgaria', 14, 20, 80000);
select * from ships where name = 'Test';
drop trigger t1;

-- 2. При изтриване на кораб автоматично да се изтрива и неговият клас, ако
-- няма повече кораби от този клас.
-- Забележка: ако преди това е имало класове без кораби - да не се пипат!
-- Забележка: клас без кораби може да се получи и при update
go

create trigger t2
on ships
after delete
as
	delete from classes
	where class in (select class
					from deleted
					where class not in (select class
										from ships));
-- Забележка: ако не използвахме deleted,
-- а направо ships, щяхме да изтрием и 
-- класове, които са били празни и преди
-- съответния delete

-- тестване:
-- в предишната задача вече сме добавили нов клас и нов кораб, ще използваме тях
delete from ships
where name = 'Test';
select * 
from classes
where class = 'Test';
drop trigger t2;
go

-- леко - искаме при изтриване на клас да се изтриват и 
-- всички кораби - ами може с on delete cascade


-- 3. Да се направи така, че ако при 
-- добавяне или обновяване на кораб
-- годината му на пускане е по-голяма от 
-- текущата година, то годината му да бъде
-- променена на null. (това е задача 3-А от 12.exerciseTriggers.pdf)

-- в MSSQL няма BEFORE тригери, затова ще търсим друг начин
create trigger t3
on ships
after insert, update
as
	update ships
	set launched = null
	where name in (select name
					from inserted
					where launched > year(getdate()));
-- тестване:
insert into ships values('Test','Iowa',2250);
select * from ships where name='Test';
delete from ships where name='Test';
drop trigger t3;
go
-- горното решение ще гръмне, ако има check(launched <= year(getdate()) в ships!

-- ако трябва в тялото на тригер да разграничим дали е бил извикан при insert или при update,
-- можем да проверим if exists (select * from deleted)

-- ако беше само за insert, можеше да направим instead of insert и всичко щеше да е наред
create trigger t
on ships
instead of insert
as
insert into ships(name, class, launched)
select name, class, case 
			when launched > year(getdate()) then null 
			else launched 
			end
from inserted;

-- вариант без case: 
-- insert into ships 
-- select * from inserted where launched <= year(getdate())
-- union all
-- select name, class, null from inserted where launched > year(getdate());
drop trigger t;
go

-- 4. При промяна на черно-бял филм на цветен съответният продуцент да получава $100000.
-- Ако в една UPDATE заявка са били променени няколко филма на един продуцент, той да получи 
-- само веднъж 100000.
use movies;
go

create trigger t4
on movie
after update
as
	update movieexec
	set networth = networth + 100000
	where cert# in (select i.producerc#
					from deleted d
					join inserted i on d.title = i.title and d.year = i.year
					where d.inColor = 'n' and i.inColor = 'y');

drop trigger t4;
go

-- Следващият пример е за валидация на данни. Всички задачи от такъв тип може да се решат аналогично.

-- 5. Да не се допуска добавянето на ред
-- в OUTCOMES, който да указва, че даден
-- кораб е участвал в битка, преди да бъде
-- пуснат на вода.

-- Aко се добавят няколко реда и поне един от тях нарушава условието за коректност, 
-- цялата операция ще бъде отменена.
use ships;
go

create trigger t5
on outcomes
after insert
as
	if exists (select *
				from inserted
				join ships on ship = ships.name
				join battles on battle = battles.name
				where launched > year(battles.date))
	begin
		raiserror('Error: ship is launched after the battle', 16, 10); -- има само едно "е"
		rollback;
	end;

-- проверка:
insert into outcomes(ship, battle, result) 
values('Iowa', 'North Atlantic', 'sunk');

select * from outcomes
where ship='Iowa';

drop trigger t5;
go


-- С помощта на INSTEAD OF тригерите може да се изпълняват INSERT, UPDATE и DELETE заявки върху всеки изглед.

-- 6. Да се създаде изглед за всички
-- потънали кораби (име на кораб и битка), т.е. за всеки 
-- потънал кораб да казва в коя битка е потънал,
-- който да позволява insert, update, delete.

create view SunkShips
as
select ship, battle
from outcomes
where result = 'sunk';
go

-- UPDATE и DELETE могат да се изпълнят безпроблемно,
-- но при INSERT новият ред би имал result = null, което не ни върши работа.

create trigger t6
on SunkShips
instead of insert
as
	insert into outcomes(ship, battle, result)
	select ship, battle, 'sunk'
	from inserted;

drop trigger t6;

-- 7. -- Симулиране на ON DELETE SET NULLS
-- MS SQL не поддържа ON DELETE SET NULLS. Да се реализира с 
-- тригери за външния ключ movie.producerc#
go
use movies;
go

create trigger t
on movieexec
instead of delete --не може after trigger заради FK; 
-- в други СУБД има before тригери
as
begin
	update movie
	set producerc# = null
	where producerc# in (select cert# from deleted);

	-- следващата операция е тази, която по принцип щеше да се изпълни и без тригер
	delete from movieexec
	where cert# in (select cert# from deleted);
end;

-- ако имаме INSTEAD OF INSERT и искаме да изпълним INSERT заявката, която е била предвидена:
-- INSERT INTO <table>
-- SELECT * FROM INSERTED;

go
-- 12.exerciseTriggers.pdf

-- Зад. 1. Да се напише тригер за таблицата MovieExec, който не позволява 
-- средната стойност на Networth да е по-малка от 500 000 (ако при промени в 
-- таблицата тази стойност стане по-малка от 500 000, промените да бъдат 
-- отхвърлени).
create trigger t
on movieexec
after insert, update, delete
as
	if (select AVG(networth)
		from movieexec) < 500000
	begin
		raiserror('Error: Average networth cannot be < 500000', 16, 10);
		rollback;
	end;

-- 3 Д) - модифицирана версия:
-- При добавяне на нов запис в StarsIn, ако новият кортеж указва несъществуващ
-- филм или актьор, да се добавят липсващите данни в съответната таблица
-- (неизвестните данни да бъдат NULL):
create trigger t
on starsin
instead of insert
as
begin
	insert into moviestar(name)
	select distinct starname
	from inserted
	where starname not in (select name from moviestar);
	
	insert into movie(title, year)
	select distinct movietitle, movieyear
	from inserted
	where not exists (select * from movie
					  where title = movietitle and YEAR = movieyear);
	
	insert into starsin
	select * 
	from inserted;
end;

-- 2 Б) Никой производител на компютри не може да произвежда и принтери;
use pc;
create trigger t
on product
after insert, update
as
if exists  (select * 
			from Product p1
			join Product p2 on p1.maker = p2.maker
			where p1.type = 'PC' and p2.type = 'Printer')
begin
	raiserror('...', 16, 10);
	rollback;
end;

-- 2 Г) При променяне на данните в таблицата Laptop се уверете, че средната 
-- цена на лаптопите за всеки производител е поне 2000;
create trigger t
on laptop
after update
as
if exists  (select maker
			from laptop
			join Product on laptop.model = Product.model
			group by maker
			having AVG(price) < 2000)
begin
	raiserror('...', 16, 10);
	rollback;
end;

-- 2 Д) - по-добре с CHECK

-- 3 В) Никой клас не може да има повече от два кораба;
create trigger t
on ships
after insert, update
as
if exists  (select class
			from ships
			group by class
			having COUNT(*) > 2)
begin
	raiserror('...', 16, 10);
	rollback;
end;

-- 3 E) прилича на 2 Г) и 3 В)

-- 3 Ж) подобно нещо вече направихме за outcomes, но трябва тригер и за battles

create trigger t
on outcomes
after insert, update
as
if exists  (select *
			from outcomes o1
			join battles b1 on o1.battle = b1.name
			join outcomes o2 on o1.ship = o2.ship
			join battles b2 on o2.battle = b2.name
			where o1.result = 'sunk'
			and b1.date < b2.date)
begin
	raiserror('...', 16, 10);
	rollback;
end;
-- същият тригер и за battles, но само за update

-- примерни теоретични въпроси...
