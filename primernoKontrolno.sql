https://pastebin.com/KdRsRLTt

USE tvshow

SELECT * FROM Show
SELECT * FROM Episode
SELECT * FROM Actor
SELECT * FROM ShowStar
SELECT * FROM ShowStarGuest

-- 1. Да се модифицира базата от данни, така че да може да се съхранява иформация за звезди-гости,
-- които са актьори, поканени да участват в конкретен епизод на сериала. Да се изберат адекватни
-- ограничения за създадената таблица/таблици.
CREATE TABLE ShowStarGuest (
	ShowID int NOT NULL, 
    ActorID int NOT NULL REFERENCES Actor(ActorID),
	Season int NOT NULL,
    Episode int NOT NULL,
	FOREIGN KEY(ShowID,Season,Episode) REFERENCES Episode(ShowID, Season, Episode),
	Plays varchar(64),
	PRIMARY KEY(ShowID,ActorID,Season,Episode)
)

---------------------------------------------------------------------------------------------------------

-- 2. Да се добави като звезда гост George Clooney, които играе Dr. Mitchell в епизод 17 на
-- сезон 1 на сериала Friends
INSERT INTO Actor (FirstName, LastName) VALUES ('George', 'Clooney')
INSERT INTO ShowStarGuest VALUES (1,@@IDENTITY,1,17,'Dr. Mitchell')

---------------------------------------------------------------------------------------------------------

-- 3. Да се направи така, че да не се допуска въвеждане на сериали на език различен от английски, в случай,
-- че телевизията, която го поръчва е NBC или FOX.
ALTER TABLE Show
ADD CONSTRAINT language_valid CHECK ((Television like 'NBC' or Television like 'FOX') AND (Language like 'English'))
	
INSERT INTO Show VALUES (
    'Friends2',
    'Hilarious sitcom for adults and older teens. Follows the personal and professional lives of six 20 to 30-something-year-old friends living in Manhattan.',
    'Comedy',
    'French',
    'Warner Bros. Television',
    'NBC',
    'USA',
    13,
    8.9,
    3,
    1,
    3,
    2,
    NULL,
    3)

---------------------------------------------------------------------------------------------------------

--4
-- 4. Една от най-често използваните заявки от приложение, което работи с базата е със следната структурата
-- показана по-долу (стойностите за дата се задават от потребители да приложението).
-- Какво бихте направили, за да ускорите изпълнението на подобни заявки в базата, в която вече има съхранена
-- информация за десетки хиляди сериали и епизоди?
 
--SELECT ShowTitle, Title AS EpisodeTitle
--FROM Show s
--   JOIN Episode e ON s.ShowID = e.ShowID
--WHERE e.DateAired = '1994-11-17'
 
-- Създайте обектите, които са нужни със съответния SQL скрипт.
CREATE INDEX EpisodeDateAired ON Episode(DateAired)--tove e indeks po DateAired
select * from EpisodeDateAired

---------------------------------------------------------------------------------------------------------

-- 5. Кое би помогнало за ускоряването на заявката по-долу:
 
-- а) клъстеризиран индекс по ShowTitle
-- b) клъстеризиран индекс по Title
-- c) клъстеризиран индекс по (ShowTitle, Title)
-- d) клъстеризиран индекс по (Title, ShowTitle)
-- е) неклъстеризиран индекс по ShowTitle
-- f) неклъстеризиран индекс по Title
-- g) неклъстеризиран индекс по (ShowTitle, Title)
-- h) неклъстеризиран индекс по (Title, ShowTitle)
 
--SELECT ShowTitle, Title AS EpisodeTitle
--FROM Show s
--    JOIN Episode e ON s.ShowID = e.ShowID
--WHERE e.Title LIKE '%Evil%'
--GO

--Отговор: Никое, защото всичките клъстери подреждат по азбучен ред, а ние не знаем с какво започва нашия e.Title, защото първият търсен символ е % в '%Evil%'
--Ако имахме някакъв конкретен символ, вместо %, отговорът щеше да е неклъстеризиран индекс  по Title

---------------------------------------------------------------------------------------------------------

-- 6. Да се направи така, че да не е възможно звездите от основния каст, които участват в даден сериал,
-- да бъдат добавяни като звезди гости за епизоди на сериала.

--ALTER TABLE ShowStarGuest
--ADD CONSTRAINT regular_actor CHECK (ActorID not in (SELECT ss.ActorID FROM Actor ss WHERE ss.ActorID=ActorID))   HE!!!!!!!!!!!!!!!

GO
CREATE TRIGGER TrgAfterActorIsAddedAsGuestStar ON ShowStarGuest AFTER INSERT, UPDATE
AS
	IF(EXISTS (SELECT * FROM inserted JOIN ShowStar ss ON inserted.ShowID=ss.ShowId))
	BEGIN 
		ROLLBACK
	END
GO

INSERT INTO Actor (FirstName, LastName) VALUES ('David', 'Schwimmer')
--INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Chandler Bing')
INSERT INTO ShowStarGuest VALUES (1,@@IDENTITY,1,17,'Dr. Mitchell') --гърми, защото се е задействал тригерът

--бонус задача: Да добавим property EpisodeCount int в Show с DEFAULT 0. Да създадем тригер, който 
--при добавяне или махане на епизод за даден сериал да поддържа този EpisodeCount
ALTER TABLE Show ADD EpisodeCount int default 0

--игнорираме тая задача :D

---------------------------------------------------------------------------------------------------------

-- 7. Таблиците Person и Teacher имат следната структура:
 
-- CREATE TABLE Person (                 CREATE TABLE Teacher (
--    egn char(10),                         egn char(10),
--    name varchar(128),                    university varchar(64)
--    address varchar(128)               );
-- );
 
-- С кои от изброените средства може да се направи така, че един човек да не може да бъде преподавател
-- в повече от един университет?
 
-- a. чрез AFTER INSERT/UPDATE тригер за таблицата Person
-- b. чрез PRIMARY KEY ограничение за двойката колони university и egn в таблицата Teacher
-- c. чрез INSTEAD OF INSERT/UPDATE тригер за таблицата Person
-- d. чрез FOREIGN KEY ограничение в таблицата Person
-- e. чрез PRIMARY KEY ограничение за колоната university в таблицата Teacher
-- f. чрез UNIQUE ограничение за колоната university в таблицата Teacher
-- g. чрез INSTEAD OF INSERT/UPDATE тригер за таблицата Teacher
-- h. чрез CHECK ограничение за колоната university в таблицата Teacher
-- i. чрез UNIQUE ограничение за двойката колони university и egn в таблицата Teacher
-- j. чрез AFTER INSERT/UPDATE тригер за таблицата Teacher
-- k. чрез FOREIGN KEY ограничение в таблицата Teacher

--Отговор: всички такива неща може с тригер, не може с foreign key и check constraint-и, така че: g, j

---------------------------------------------------------------------------------------------------------
 
-- 8. В таблицата Person от предната задача има 10 милиона записа. Създаваме уникален индекс
-- по колоната egn. Кои заявки ще се ускорят?
--  
-- a. SELECT * FROM Person WHERE egn = '9106192093'
-- b. SELECT egn FROM Person WHERE egn = '9106192093'
-- c. SELECT egn, name FROM Person WHERE egn = '9106192093'
-- d. SELECT * FROM Person
--        WHERE egn IN ('9106192093', '9211218273', '9201218172', '9205091923', '6802012938')
-- e. SELECT egn FROM Person
--        WHERE egn IN ('9106192093', '9211218273', '9201218172', '9205091923', '6802012938')
-- f. SELECT egn, name FROM Person
--        WHERE egn IN ('9106192093', '9211218273', '9201218172', '9205091923', '6802012938')
-- g. UPDATE Person SET egn = '9106192834' WHERE egn = '9106192093'
-- h. UPDATE Person SET egn = '9106192834'
--        WHERE egn IN ('9106192093', '9211218273', '9201218172', '9205091923', '6802012938')
-- i. UPDATE Person SET name = 'Petar Petrov' WHERE egn = '9106192093'
-- j. UPDATE Person SET name = 'Petar Petrov'
--        WHERE egn IN ('9106192093', '9211218273', '9201218172', '9205091923', '6802012938')
-- k. DELETE FROM Person WHERE egn = '9106192093'
-- l. DELETE FROM Person
--        WHERE egn IN ('9106192093', '9211218273', '9201218172', '9205091923', '6802012938')

-- Отговор: Всичко се ускорява.
 
---------------------------------------------------------------------------------------------------------
 
-- 9. Кои тип данни е удачно да се използва за колона, която трябва да може да съхранява текст,
-- чиято дължина е от 1000 до 7000 латински символа?
 
-- a. char(1000)
-- b. char(7000)
-- c. varchar(1000)
-- d. varchar(7000)

-- Отговор: d

---------------------------------------------------------------------------------------------------------
 
-- 10. Кои от следните твърдения са верни?
 
-- a. Индексите ускоряват заявки, в чиито WHERE клаузи се съдържат условия от вида col LIKE '%word%'.
-- b. При добавяне на ограничение UNIQUE автоматично се създава клъстериран индекс.
-- c. При създаване на индекс може да се посочи повече от една колона и редът на колоните е от значение.
-- d. За дадена таблица може да има само един клъстеризиран индекс
-- е. Една от разликите межди таблици и изгледи е, че за изгледите немогат да се създават индекси.

-- Отговор: c, d
 
---------------------------------------------------------------------------------------------------------
 
-- 11. Кой от следните типове данни е най-подходящ за колона, съхраняваща цена на продукт?
 
-- a. CHAR(6)
-- b. DECIMAL(6, 2)
-- c. FLOAT
-- d. INT

-- Отговор: b
 
---------------------------------------------------------------------------------------------------------
 
-- 12. Кои от следните твърдения са верни?
 
-- a. При създаване на PRIMARY KEY ограничение, автоматично се създава неклъстериран индекс.
-- b. За да се ускори една SELECT заявка, в нея трябва изрично да е указано кои индекси да се използват.
-- c. Наличието на индекс върху колона col ще ускори изпълнението на SELECT заявка, съдържаща ORDER BY col.
-- d. Клъстеризиран индекс е добре да се създава след създаването неклъстеризираните индекси. ->oбратното е вярно

-- Отговор: c
 
---------------------------------------------------------------------------------------------------------
 
-- 13. Кои от следните твърдения са верни?
 
-- a. Ако искаме в една таблица да има първичен ключ, съставен от две колони, пишем PRIMARY KEY срещу всяка
--    от тях (напр. title VARCHAR(50) PRIMARY KEY, year INT PRIMARY KEY).
-- b. Първичен ключ, съставен от две колони, допуска във всяка от двете колони да има повторения, стига да
--    няма два реда, при които стойностите и за двете колони да съвпадат
-- c. Външният ключ не позволява NULL стойности, но позволява повторения //ако сочи към колона, която поддържа UNIQUE NULL стойности е вярно
-- d. Външният ключ трябва да реферира към колона, за която има дефинирано PRIMARY KEY или UNIQUE ограничение

-- Отговор: b, d
 
---------------------------------------------------------------------------------------------------------
 
-- 14. Кои твърдения са грешни?
 
-- a. върху изгледи може да се дефинират само INSTEAD OF тригери
-- b. AFTER DELETE тригерите не могат да отказват изтриването на редове в таблицата, за която са дефинирани
-- c. таблиците inserted и deleted са достъпни както в AFTER, така и в INSTEAD OF тригерите
-- d. върху таблици могат да се дефинират само AFTER тригери
-- e. таблицата inserted е винаги празна в тялото на AFTER UPDATE тригер

-- Отговор: b, d, e
 
---------------------------------------------------------------------------------------------------------
 
-- 15. Искаме клетките в дадена колона да не могат да приемат стойност NULL. Кои от следните средства не са
--    приложими за целта?
 
-- a. DEFAULT стойност
-- b. PRIMARY KEY
-- c. NOT NULL ограничение
-- d. AFTER тригер
-- e. INSTEAD OF тригер
-- f. CHECK ограничение

-- Отговор: a
 
---------------------------------------------------------------------------------------------------------
 
-- 16. Искаме при изтриване на клас автоматично да се изтриват и всички негови кораби. Кое не е приложимо
--     за целта?
 
-- a. AFTER тригер
-- b. INSTEAD OF тригер
-- c. политика ON DELETE CASCADE върху външния ключ
-- d. политика ON UPDATE CASCADE върху външния ключ

-- Отговор: d
 
---------------------------------------------------------------------------------------------------------
		   
		   
		   
		   USE master
 
DROP DATABASE tvshow
GO
 
CREATE DATABASE tvshow
GO
 
USE tvshow
 
CREATE TABLE Show (
   ShowID int IDENTITY PRIMARY KEY,
   ShowTitle varchar(64) UNIQUE NOT NULL,
   Description text NULL,
   Type varchar(32) NULL,
   Language varchar(32) NULL,
   Studio varchar(32) NULL,
   Television varchar(32) NULL,
   Country varchar(32) NULL,
   MinimumAge int NULL,
   PopularityRating decimal(18,1) NULL,
   PositivityRating decimal(18,1) NULL,
   ViolenceRating decimal(18,1) NULL,
   SexRating decimal(18,1) NULL,
   LanguageRating decimal(18,1) NULL,
   ConsumerismRating decimal(18,1) NULL,
   DrinkSmokeRating decimal(18,1) NULL
);
 
CREATE TABLE Episode (
  ShowID int REFERENCES Show(ShowID) NOT NULL,
  Season int NOT NULL,
  Episode int NOT NULL,
  Title varchar(64) NOT NULL,
  DateAired date NULL,
  Runtime int NULL,
  Viewers decimal(18,1) NULL,
  Rating decimal(18,1) NULL,
  PRIMARY KEY(ShowID, Season, Episode)
);
 
CREATE TABLE Actor (
    ActorID int IDENTITY PRIMARY KEY,
    FirstName varchar(64) NOT NULL,
    LastName varchar(64) NOT NULL,
    BirthDate date NULL
)
 
CREATE TABLE ShowStar (
    ShowID int NOT NULL REFERENCES Show(ShowID),
    ActorID int NOT NULL REFERENCES Actor(ActorID),
    Plays varchar(64)
)
 
INSERT INTO Show VALUES (
    'Friends',
    'Hilarious sitcom for adults and older teens. Follows the personal and professional lives of six 20 to 30-something-year-old friends living in Manhattan.',
    'Comedy',
    'English',
    'Warner Bros. Television',
    'NBC',
    'USA',
    13,
    8.9,
    3,
    1,
    3,
    2,
    NULL,
    3)
 
INSERT INTO Show VALUES (
    'Malcolm in the Middle',
    'Quirky, off-the-wall family humor. A gifted young teen tries to survive life with his dimwitted, dysfunctional family.',
    'Comedy',
    'English',
    '20th Century Fox Television',
    'FOX',
    'USA',
    13,
    8.0,
    1,
    2,
    2,
    2,
    NULL,
    NULL)
 
INSERT INTO Episode VALUES (1,
    1,
    1,
 
    'The Pilot',
    'September 22, 1994',
    22,
    21.5, 8.5
)
 
INSERT INTO Episode VALUES (1,
    1,
    2,
 
    'The One with the Sonogram at the End',
    'September 29, 1994',
    22,
    22.2, 8.2
)
 
INSERT INTO Episode VALUES (1,
    1,
    3,
 
    'The One with the Thumb',
    'October 6, 1994',
    22,
    19.5, 8.3
)
 
INSERT INTO Episode VALUES (1,
    1,
    4,
 
    'The One with George Stephanopoulos',
    'October 13, 1994',
    22,
    19.7, 8.2
)
 
INSERT INTO Episode VALUES (1,
    1,
    5,
 
    'The One with the East German Laundry Detergent',
    'October 20, 1994',
    22,
    18.6, 8.6
)
 
INSERT INTO Episode VALUES (1,
    1,
    6,
 
    'The One with the Butt',
    'October 27, 1994',
    22,
    18.2, 8.3
)
 
INSERT INTO Episode VALUES (1,
    1,
    7,
 
    'The One with the Blackout',
    'November 3, 1994',
    22,
    23.5, 9.0
)
 
INSERT INTO Episode VALUES (1,
    1,
    8,
 
    'The One Where Nana Dies Twice',
    'November 10, 1994',
    22,
    21.1, 8.2
)
 
INSERT INTO Episode VALUES (1,
    1,
    9,
 
    'The One Where Underdog Gets Away',
    'November 17, 1994',
    22,
    23.1, 8.3
)
 
INSERT INTO Episode VALUES (1,
    1,
    10,
 
    'The One with the Monkey',
    'December 15, 1994',
    22,
    19.9, 8.1
)
 
INSERT INTO Episode VALUES (1,
    1,
    11,
 
    'The One with Mrs. Bing',
    'January 5, 1995',
    22,
    26.6, 8.3
)
 
INSERT INTO Episode VALUES (1,
    1,
    12,
 
    'The One with the Dozen Lasagnas',
    'January 12, 1995',
    22,
    24.0, 8.3
)
 
INSERT INTO Episode VALUES (1,
    1,
    13,
 
    'The One with the Boobies',
    'January 19, 1995',
    22,
    25.8, 8.7
)
 
INSERT INTO Episode VALUES (1,
    1,
    14,
 
    'The One with the Candy Hearts',
    'February 9, 1995',
    22,
    23.8, 8.4
)
 
INSERT INTO Episode VALUES (1,
    1,
    15,
 
    'The One with the Stoned Guy',
    'February 16, 1995',
    22,
    24.8, 8.4
)
 
INSERT INTO Episode VALUES (1,
    1,
    16,
 
    'The One with Two Parts: Part 1',
    'February 23, 1995',
    22,
    26.1, 8.3
)
 
INSERT INTO Episode VALUES (1,
    1,
    17,
 
    'The One with Two Parts: Part 2',
    'February 23, 1995',
    22,
    30.5, 8.5
)
 
INSERT INTO Episode VALUES (1,
    1,
    18,
 
    'The One with All the Poker',
    'March 2, 1995',
    22,
    30.4, 8.9
)
INSERT INTO Episode VALUES (1,
    1,
    19,
 
    'The One Where the Monkey Gets Away',
    'March 9, 1995',
    22,
    29.4, 8.2
)
INSERT INTO Episode VALUES (1,
    1,
    20,
 
    'The One with the Evil Orthodontist',
    'April 6, 1995',
    22,
    30.0, 8.0
)
 
INSERT INTO Episode VALUES (1,
    1,
    21,
 
    'The One with the Fake Monica',
    'April 27, 1995',
    22,
    28.4, 8.0
)
 
INSERT INTO Episode VALUES (1,
    1,
    22,
 
    'The One with the Ick Factor',
    'April 27, 1995',
    22,
    29.9, 8.4
)
 
INSERT INTO Episode VALUES (1,
    1,
    23,
 
    'The One with the Birth',
    'May 11, 1995',
    22,
    28.7, 8.7
)
 
INSERT INTO Episode VALUES (1,
    1,
    24,
 
    'The One Where Rachel Finds Out',
    'May 18, 1995',
    22,
    31.3, 8.9
)
 
 
INSERT INTO Episode VALUES (1,
    2,
    1,
 
    'The One with Ross''s New Girlfriend',
    'Sep 21, 1995',
    22,
    32.1, 8.6
)
 
INSERT INTO Episode VALUES (1,
    2,
    2,
 
    'The One with the Breast Milk',
    'Sep 28, 1995',
    22,
    29.8, 8.3
)
 
INSERT INTO Episode VALUES (1,
    2,
    3,
 
    'The One Where Heckles Dies',
    'Oct 5, 1995',
    22,
    30.2, 8.4
)
 
INSERT INTO Episode VALUES (1,
    2,
    4,
 
    'The One with Phoebe''s Husband',
    'Oct 12, 1995',
    22,
    28.1, 8.0
)
 
INSERT INTO Episode VALUES (1,
    2,
    5,
 
    'The One with Five Steaks and an Eggplant',
    'Oct 12, 1995',
    22,
    28.3, 8.3
)
 
INSERT INTO Episode VALUES (1,
    2,
    6,
 
    'The One with the Baby on the Bus',
    'Oct 19, 1995',
    22,
    30.2, 8.6
)
 
INSERT INTO Episode VALUES (1,
    2,
    7,
 
    'The One Where Ross Finds Out',
    'Nov 9, 1995',
    22,
    30.5, 9.0
)
 
INSERT INTO Episode VALUES (1,
    2,
    8,
 
    'The One with the List',
    'Nov 16, 1995',
    22,
    32.9, 8.5
)
 
INSERT INTO Episode VALUES (1,
    2,
    9,
 
    'The One with Phoebe''s Dad',
    'Dec 14, 1995',
    22,
    27.8, 8.1
)
 
INSERT INTO Episode VALUES (1,
    2,
    10,
 
    'The One with Russ',
    'Jan 4, 1996',
    22,
    32.2, 8.2
)
 
INSERT INTO Episode VALUES (1,
    2,
    11,
 
    'The One with the Lesbian Wedding',
    'Jan 18, 1996',
    22,
    31.6, 8.2
)
INSERT INTO Episode VALUES (1,
    2,
    12,
 
    'The One After the Superbowl: Part 1',
    'Jan 28, 1996',
    22,
    52.9, 8.7
)
 
INSERT INTO Episode VALUES (1,
    2,
    13,
 
    'The One After the Superbowl: Part 2',
    'Jan 28, 1996',
    22,
    52.9, 8.8
)
 
INSERT INTO Episode VALUES (1,
    2,
    14,
 
    'The One with the Prom Video',
    'Feb 1, 1996',
    22,
    33.6, 9.4
)
 
INSERT INTO Episode VALUES (1,
    2,
    15,
 
    'The One Where Ross and Rachel... You Know',
    'Feb 8, 1996',
    22,
    32.9, 8.9
)
 
INSERT INTO Episode VALUES (1,
    2,
    16,
 
    'The One Where Joey Moves Out',
    'Feb 15, 1996',
    22,
    31.1, 8.6
)
 
INSERT INTO Episode VALUES (1,
    2,
    17,
 
    'The One Where Eddie Moves In',
    'Feb 22, 1996',
    22,
    30.2, 8.4
)
 
INSERT INTO Episode VALUES (1,
    2,
    18,
 
    'The One Where Dr. Ramoray Dies',
    'Mar 21, 1996',
    22,
    30.1, 8.5
)
 
INSERT INTO Episode VALUES (1,
    2,
    19,
 
    'The One Where Eddie Won''t Go',
    'Mar 28, 1996',
    22,
    31.2, 8.6
)
 
INSERT INTO Episode VALUES (1,
    2,
    20,
 
    'The One Where Old Yeller Dies',
    'April 4, 1996',
    22,
    27.4, 8.2
)
 
INSERT INTO Episode VALUES (1,
    2,
    21,
 
    'The One with the Bullies',
    'April 25, 1996',
    22,
    24.7, 8.3
)
 
INSERT INTO Episode VALUES (1,
    2,
    22,
 
    'The One with the Two Parties',
    'May 2, 1996',
    22,
    25.5, 9.0
)
 
INSERT INTO Episode VALUES (1,
    2,
    23,
 
    'The One with the Chicken Pox',
    'May 9, 1996',
    22,
    26.1, 8.2
)
 
INSERT INTO Episode VALUES (1,
    2,
    24,
 
    'The One with Barry and Mindy''s Wedding',
    'May 9, 1996',
    22,
    29.0, 8.3
)
 
INSERT INTO Episode VALUES (1,
    3,
    1,
 
    'The One with the Princess Leia Fantasy',
    'Sep 19, 1996',
    22,
    26.8, 8.5
)
 
INSERT INTO Episode VALUES (1,
    3,
    2,
 
    'The One Where No One''s Ready',
    'Sep 26, 1996',
    22,
    26.7, 9.0
)
 
INSERT INTO Episode VALUES (1,
    3,
    3,
 
    'The One with the Jam',
    'Oct 3, 1996',
    22,
    25.2, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    4,
 
    'The One with the Metaphorical Tunnel',
    'Oct 10, 1996',
    22,
    21.6, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    5,
 
    'The One with Frank Jr.',
    'Oct 17, 1996',
    22,
    23.3, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    6,
 
    'The One with the Flashback',
    'Oct 31, 1996',
    22,
    23.3, 9.1
)
 
INSERT INTO Episode VALUES (1,
    3,
    7,
 
    'The One with the Race Car Bed',
    'Nov 7, 1996',
    22,
    27.4, 8.4
)
 
INSERT INTO Episode VALUES (1,
    3,
    8,
 
    'The One with the Giant Poking Device',
    'Nov 14, 1996',
    22,
    28.7, 8.4
)
 
INSERT INTO Episode VALUES (1,
    3,
    9,
 
    'The One with the Football',
    'Nov 21, 1996',
    22,
    29.3, 9.1
)
 
INSERT INTO Episode VALUES (1,
    3,
    10,
 
    'The One Where Rachel Quits',
    'Dec 12, 1996',
    22,
    25.1, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    11,
 
    'The One Where Chandler Can''t Remember Which Sister',
    'Jan 9, 1997',
    22,
    29.8, 8.6
)
 
INSERT INTO Episode VALUES (1,
    3,
    12,
 
    'The One with All the Jealousy',
    'Jan 16, 1997',
    22,
    29.6, 8.3
)
 
INSERT INTO Episode VALUES (1,
    3,
    13,
 
    'The One Where Monica and Richard are Just Friends',
    'Jan 30, 1997',
    22,
    28.0, 8.3
)
 
INSERT INTO Episode VALUES (1,
    3,
    14,
 
    'The One with Phoebe''s Ex-Partner',
    'Feb 6, 1997',
    22,
    28.9, 8.0
)
 
INSERT INTO Episode VALUES (1,
    3,
    15,
 
    'The One Where Ross and Rachel Take a Break',
    'Feb 13, 1997',
    22,
    27.3, 8.6
)
 
INSERT INTO Episode VALUES (1,
    3,
    16,
 
    'The One the Morning After',
    'Feb 20, 1997',
    22,
    28.3, 9.1
)
 
INSERT INTO Episode VALUES (1,
    3,
    17,
 
    'The One Without the Ski Trip',
    'Mar 6, 1997',
    22,
    25.8, 8.4
)
 
INSERT INTO Episode VALUES (1,
    3,
    18,
 
    'The One with the Hypnosis Tape',
    'Mar 13, 1997',
    22,
    28.1, 8.5
)
 
INSERT INTO Episode VALUES (1,
    3,
    19,
 
    'The One with the Tiny T-Shirt',
    'Mar 27, 1997',
    22,
    23.7, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    20,
 
    'The One with the Dollhouse',
    'Apr 3, 1997',
    22,
    24.4, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    21,
 
    'The One with a Chick and a Duck',
    'Apr 17, 1997',
    22,
    23.2, 8.8
)
 
INSERT INTO Episode VALUES (1,
    3,
    22,
 
    'The One with the Screamer',
    'Apr 24, 1997',
    22,
    22.6, 8.4
)
 
INSERT INTO Episode VALUES (1,
    3,
    23,
 
    'The One with Ross''s Thing',
    'May 1, 1997',
    22,
    24.2, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    24,
 
    'The One with the Ultimate Fighting Champion',
    'May 8, 1997',
    22,
    23.1, 8.2
)
 
INSERT INTO Episode VALUES (1,
    3,
    25,
 
    'The One at the Beach',
    'May 15, 1997',
    22,
    28.8, 8.9
)
 
INSERT INTO Episode VALUES (2,
    1,
    1,
 
    'Pilot',
    'January 9, 2000',
    26,
    22.4, 8.4
)
 
INSERT INTO Episode VALUES (2,
    1,
    2,
 
    'Red Dress',
    'January 16, 2000',
    26,
    23.3, 8.5
)
 
INSERT INTO Episode VALUES (2,
    1,
    3,
 
    'Home Alone 4',
    'January 23, 2000',
    26,
    19.3, 8.0
)
 
INSERT INTO Episode VALUES (2,
    1,
    4,
 
    'Shame',
    'Feb 6, 2000',
    26,
    16.8, 7.9
)
 
INSERT INTO Episode VALUES (2,
    1,
    5,
 
    'Malcolm Babysits',
    'Feb 13, 2000',
    26,
    17.9, 8.2
)
 
INSERT INTO Episode VALUES (2,
    1,
    6,
 
    'Sleepover',
    'Feb 20, 2000',
    26,
    17.1, 8.2
)
 
INSERT INTO Episode VALUES (2,
    1,
    7,
 
    'Francis Escapes',
    'Feb 27, 2000',
    26,
    16.6, 7.7
)
 
INSERT INTO Episode VALUES (2,
    1,
    8,
 
    'Krelboyne Picnic',
    'Mar 12, 2000',
    26,
    15.5, 8.6
)
 
INSERT INTO Episode VALUES (2,
    1,
    9,
 
    'Lois vs. Evil',
    'Mar 19, 2000',
    26,
    16.3, 8.0
)
 
INSERT INTO Episode VALUES (2,
    1,
    10,
 
    'Stock Car Races',
    'Apr 2, 2000',
    26,
    14.4, 8.0
)
 
INSERT INTO Episode VALUES (2,
    1,
    11,
 
    'Funeral',
    'Apr 9, 2000',
    26,
    15.3, 8.2
)
 
INSERT INTO Episode VALUES (2,
    1,
    12,
 
    'Cheerleader',
    'Apr 16, 2000',
    26,
    13.0, 8.2
)
 
INSERT INTO Episode VALUES (2,
    1,
    13,
 
    'Rollerskates',
    'Apr 30, 2000',
    26,
    14.5, 8.7
)
 
INSERT INTO Episode VALUES (2,
    1,
    14,
 
    'The Bots and the Bees',
    'May 7, 2000',
    26,
    12.3, 8.0
)
 
INSERT INTO Episode VALUES (2,
    1,
    15,
 
    'Smunday',
    'May 14, 2000',
    26,
    12.6, 8.1
)
 
INSERT INTO Episode VALUES (2,
    1,
    16,
 
    'Water Park (Part 1)',
    'May 21, 2000',
    26,
    13.9, 8.7
)
 
INSERT INTO Actor (FirstName, LastName) VALUES ('Jennifer', 'Aniston')
INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Rachel Green')
 
INSERT INTO Actor (FirstName, LastName) VALUES ('Courteney', 'Cox')
INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Monica Geller')
 
INSERT INTO Actor (FirstName, LastName) VALUES ('Lisa', 'Kudrow')
INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Phoebe Buffay')
 
INSERT INTO Actor (FirstName, LastName) VALUES ('Matt', 'LeBlanc')
INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Joey Tribbiani')
 
INSERT INTO Actor (FirstName, LastName) VALUES ('Matthew', 'Perry')
INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Dr. Ross Geller')
 
INSERT INTO Actor (FirstName, LastName) VALUES ('David', 'Schwimmer')
INSERT INTO ShowStar VALUES (1, @@IDENTITY, 'Chandler Bing')
 
