-- да се използват редуцираните скриптове за БД

use movies;

-- яко:
begin transaction; -- изпълняваме този ред (F5)
-- пишем си заявките и си ги изпълняваме по познатия начин (F5, F5...)
delete from starsin;
select * from starsin;

-- накрая пишем:
rollback transaction;
-- всичко се връща както е било :)
select * from starsin;




begin transaction;

insert into movie(title, year, length, incolor, 
	studioname, producerc#)
	values('Mission London', 2010, 100, 'Y',
	'SIA', 121);


-- Да се добави информация за актрисата Nicole
-- Kidman. За нея знаем само, че е родена на
-- 20-и юни 1967.
insert into moviestar(name, gender, birthdate)
values('Nicole Kidman', 'F', '1967-06-20');

-- трябва да проверим какво е станало, например:
select * from moviestar;

-- Да се изтрият всички продуценти с печалба
-- (networth) под 10 милиона.

DELETE FROM MovieExec
WHERE networth < 10000000;

-- Да се изтрие информацията за всички филмови
-- звезди, за които адресът е неизвестен.

delete 
from moviestar 
where address is null;

-- Използвайки две INSERT заявки, съхранете в базата от
-- данни факта, че персонален компютър модел 1100 е
-- направен от производител C, има процесор 2400 MHz,
-- RAM 2048 MB, твърд диск 500 GB, 52x DVD устройство и струва $299. 
-- Нека новият компютър има код 12. Забележка: моделът и CD са от тип
-- низ.
-- Упътване: самото вмъкване на данни е очевидно как ще стане,
-- помислете в какъв ред е по-логично да са двете заявки.
use pc;

INSERT INTO Product(maker, model, type)
VALUES('C', '1100', 'PC');
INSERT INTO PC(code, model, speed, ram, hd, cd, price)
VALUES(12, '1100', 2400, 2048, 500, '52x', 299);

-- Да се изтрие всичката налична информация за компютри модел 1100.
delete from pc where model='1100';
delete from product where model='1100';

-- За всеки персонален компютър се продава и 15-инчов лаптоп със същите параметри,
-- но с $500 по-скъп. Кодът на такъв лаптоп е със 100 по-голям от кода на съответния
-- компютър. Добавете тази информация в базата.

-- ако искаме да сме съвсем точни (въпреки че в момента не е нужно),
-- трябва да добавим моделите в Product.
-- Нека производителят на тези лаптопи се казва 'Z'.
insert into product (model, maker, type)
select distinct model, 'Z', 'Laptop'
from pc;

-- ето това е очакваното решение на задачата:
insert into laptop(code, model, speed, ram, hd, price, screen)
select code+100, model, speed, ram, hd, price+500, 15
from pc;

-- Да се изтрият всички лаптопи, направени от производител, който не
-- произвежда принтери.
-- Упътване: Мислете си, че решавате задача от познат тип - "Да се
-- изведат всички лаптопи, ...". Накрая ще е нужна съвсем малка
-- промяна. Ако започнете директно да триете, много е вероятно при
-- някой грешен опит да изтриете всички лаптопи и ще трябва често да
-- възстановявате таблицата или да работите на сляпо.

DELETE FROM laptop
WHERE model IN ( SELECT model 
		         FROM product 
                 WHERE type='Laptop' AND
 		         maker NOT IN (SELECT maker
	                           FROM product
		                       WHERE type='Printer'));

-- Производител А купува производител B. На всички продукти на В
-- променете производителя да бъде А.

update product
set maker='A'
where maker='B';

-- Да се намали два пъти цената на всеки компютър и да се добавят по
-- 20 GB към всеки твърд диск. Упътване: няма нужда от две отделни заявки.

update pc
set price=price/2, hd=hd+20;

-- За всеки лаптоп от производител B добавете по един инч към диагонала
-- на екрана.

UPDATE laptop
SET screen=screen+1
WHERE model IN (SELECT model
		      FROM product
		      WHERE maker='B');

-- Два британски бойни кораба от класа Nelson - Nelson и Rodney - са
-- били пуснати на вода едновременно през 1927 г. Имали са девет
-- 16-инчови оръдия (bore) и водоизместимост от 34 000 тона (displacement).
-- Добавете тези факти към базата от данни.

use ships;

insert into classes
values('Nelson', 'bb', 'Gt.Britain', 9, 16, 34000);

insert into ships
values('Nelson', 'Nelson', 1927);

insert into ships
values('Rodney', 'Nelson', 1927);

-- Изтрийте от Ships всички кораби, които са потънали в битка.

delete from ships
where name in (select ship from outcomes where result='sunk');

-- Променете данните в релацията Classes така, че калибърът (bore) да се измерва
-- в сантиметри (в момента е в инчове, 1 инч ~ 2.5 см) и водоизместимостта
-- да се измерва в метрични тонове (1 м.т. = 1.1 т.)

update classes
set bore=bore*2.54, displacement=displacement/1.1;

-- Изтрийте всички класове, от които има по-малко от три кораба.
-- заб.: може да има класове без кораби
delete from classes
where class NOT in
(select class
from ships
group by class
having count(*) >= 3);

delete from classes where class in
(select classes.class 
from classes
left join ships on classes.class=ships.class
group by classes.class
having count(name)<3);

-- Променете калибъра на оръдията и водоизместимостта на класа 
--Iowa, така че да са същите като тези на класа Bismarck

UPDATE classes
SET bore=(SELECT bore
 			FROM classes WHERE class='Bismarck'),
    displacement=(SELECT displacement
			FROM classes WHERE class='Bismarck')
WHERE class='Iowa';


-- допълнителен материал, не са нужни за контролното:

-- с join:

update t1
set ...
from t1 join t2 on ...
where ...

готин пример:
Update a set a.c=b.c from a join b ...


-- корелативна:

use ships;
-- На всички кораби, пуснати в най-ранната година, да се сложи launched да е толкова, колкото е последната година на кораб от същия клас.
update x
set launched=(select max(launched) from ships s where s.class=x.class)
from ships x
where launched=(select min(launched) from ships);

--накрая да се възстановят данните!
rollback
