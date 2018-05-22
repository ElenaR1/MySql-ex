use movies_original
-- да се напише изглед, който намира имената на всички актьори, играли във филми с дължина под 120 минути или с неизвестна дължина

go

create view stars
as
select distinct starname
from starsin
join movie on movietitle = title and movieyear = year
where length < 120 or length is null;

go

select * from stars;

-- Да се направи възможно изтриването на редове в изгледа. При изпълнение на delete заявка върху stars 
-- да се изтриват съответните редове от starsin.

go

create trigger DeleteStars
on stars
instead of delete
as
delete from starsin
where starname in (select starname
				from deleted);

go

-- да се изтрият всички участия на филмови звезди (редове в StarsIn)
-- във филми, чието заглавие започва със Star, но само ако не са играли във филми, незапочващи със Star.

delete
from starsin
where movietitle like 'Star%'
	and starname not in (select starname
						from starsin
						where movietitle not like 'Star%');

-- да се изтрият всички компютри, произведени от производител, който не произвежда цветни принтери
use pc;
go

delete
from pc
where model in (select model
				from product
				where maker not in (select maker
									from product
									join printer on product.model = printer.model
									where color = 'y'));

go

-- а) да се създаде изглед, който показва кодовете, моделите, процесорите, RAM паметта, харддиска и цената
-- на всички PC-та и лаптопи. Да има допълнителна колона, която указва типа на продукта - PC или Laptop.
-- б) да се направи възможно изпълнението на DELETE заявки върху този изглед

create view Computers
as
select code, model, speed, ram, hd, price, 'PC'
from pc
union all
select code, model, speed, ram, hd, price, 'Laptop'
from laptop;


go

create view Computers
as
select code, model, speed, ram, hd, price, 'PC' as type
from pc
union all
select code, model, speed, ram, hd, price, 'Laptop'
from laptop;

go

create trigger DeleteComputers
on Computers
instead of delete
as
begin
	delete from pc
	where code in (select code
					from deleted
					where type = 'PC');

	delete from laptop
	where code in (select code
					from deleted
					where type = 'Laptop');

end;

delete Computers
where code = 1 and type = 'PC';

select * from Computers;

drop trigger DeleteComputers;
drop view Computers;
