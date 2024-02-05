CREATE TABLE concerts ( 
	concert_id INT(5) PRIMARY KEY,
	auditorium VARCHAR(30),
	people INT(5),
	concert_date DATE
);

CREATE TABLE performers ( 
	performer_id INT(5) PRIMARY KEY,
	name VARCHAR(30),
	birth_date DATE
);

CREATE TABLE composers ( 
	composer_id INT(5) PRIMARY KEY,
	name VARCHAR(30),
	birth_date DATE,
	dead_date DATE
);

CREATE TABLE pieces ( 
	piece_id INT(5) PRIMARY KEY,
	title VARCHAR(30),
	composer_id INT(5),
	FOREIGN KEY fk_pieces (composer_id) REFERENCES composers(composer_id)
);

CREATE TABLE con_per ( 
	concert_id INT(5),
	performer_id INT(5),
	instrument VARCHAR(30),
	PRIMARY KEY (concert_id, performer_id, instrument),
	FOREIGN KEY con_per_1 (concert_id) REFERENCES concerts(concert_id),
	FOREIGN KEY con_per_2 (performer_id) REFERENCES performers(performer_id)
);

CREATE TABLE con_pie (
	concert_id INT(5),
	piece_id INT(5),
	PRIMARY KEY (concert_id, piece_id),
	FOREIGN KEY con_pie_1 (concert_id) REFERENCES concerts(concert_id),
	FOREIGN KEY con_pie_2 (piece_id) REFERENCES pieces(piece_id)	
);

INSERT INTO concerts VALUES
	(1,'Casa Colón',1250,'2017-09-07'),
	(2,'Gran Teatro',655,'2018-10-22'),
	(3,'Casa Colón',1756,'2018-11-07'),
	(4,'Castillo de Niebla',2100,'2018-12-14'),
	(5,'Gran Teatro',1001,'2018-12-25'),
	(6,'Foro Iberoamericano',2370,'2019-01-05'),
	(7,'Casa Colón',1650,'2019-02-07'),
	(8,'Casa Colón',993,'2019-03-09'),
	(9,'IES La Marisma',238,'2019-05-22'),
	(10,'Foro Iberoamericano',2300,'2019-06-12'),
	(11,'Universidad de Huelva',4612,'2019-06-30'),
	(12,'Parque Alonso Sánchez',1345,'2019-07-28'),
	(13,'Castillo de Niebla',2100,'2019-08-14');

INSERT INTO performers VALUES
	(1,'García López, Juan','1967-10-10'),
	(2,'Stropov, Igor','1988-12-21'),
	(3,'Pérez Díaz, Ana','1999-11-22'),
	(4,'Rivas Conde, Amancio','1954-13-11'),
	(5,'Kamarazova, Tatiana','1970-09-23'),
	(6,'Yamamoto, Koji','1970-04-13'),
	(7,'Smith, Margaret','1999-08-30'),
	(8,'Pérez García, José','2000-12-14'),
	(9,'Maroto Rojas, Luis','1998-02-15'),
	(10,'Pereira Gómez, Juan','1997-09-15'),
	(11,'Díaz Díaz, Juana','1978-11-09'),
	(12,'Li, Deng','1976-12-23'),
	(13,'Romero Sánchez, Lucas','1980-03-22'),
	(14,'Dolgopolov, Dimitri','1990-03-17'),
	(15,'Johanson, James','1989-09-23');

INSERT INTO composers VALUES
	(1,'Wagner, Richard','1813-05-22','1883-02-13'),
	(2,'Mozart, Wolfgang Amadeus','1756-01-27','1791-12-05'),
	(3,'Falla, Manuel de','1876-11-23','1946-11-14'),
	(4,'Williams, John','1932-02-08',NULL),
	(5,'Beethoven, Ludwig Van','1770-12-16','1827-03-26'),
	(6,'Morricone, Ennio','1928-11-10',NULL),
	(7,'Richard Strauss','1864-06-11','1949-09-08');

INSERT INTO pieces VALUES
	(1,'The ride of the valkyries',1),
	(2,'The magic flute',2),
	(3,'Requiem',2),
	(4,'El amor brujo',3),
	(5,'El sombrero de tres picos',3),
	(6,'Soundtrack Star Wars',4),
	(7,'Soundtrack Indiana Jones',4),
	(8,'Symphony No. 1',5),
	(9,'Symphony No. 9',5),
	(10,'Soundtrack The mission',6),
	(11,'Soundtrack The good, the bad and the ugly',6),
	(12,'Thus spoke Zarathustra',7),
	(13,'Don Giovanni',2),
	(14,'The marriage of Figaro',2),
	(15,'Symphony No. 1',2),
	(16,'Symphony No. 2',2);
	
INSERT INTO con_per VALUES
	(1,1,'Triangle'),
	(1,2,'Violin'),
	(1,3,'Baton'),
	(1,10,'Violin'),
	(1,12,'Trumpet'),
	(1,14,'Violin'),
	(2,1,'Kettledrum'),
	(2,2,'Violin'),
	(2,3,'Baton'),
	(2,4,'Violin'),
	(2,7,'Flute'),
	(3,1,'Baton'),
	(3,2,'Violin'),
	(3,9,'Violin'),
	(4,1,'Baton'),
	(4,4,'Violin'),
	(4,5,'Guitar'),
	(4,10,'Violin'),
	(5,1,'Kettledrum'),
	(5,2,'Violin'),
	(5,3,'Baton'),
	(5,10,'Violin'),
	(5,10,'Viola'),
	(5,11,'Violin'),
	(5,12,'Viola'),
	(6,1,'Kettledrum'),
	(6,2,'Violin'),
	(6,3,'Baton'),
	(6,4,'Flute'),
	(6,10,'Violin'),
	(6,11,'Violin'),
	(6,12,'Guitar'),
	(6,13,'Tuba'),
	(7,2,'Kettledrum'),
	(7,3,'Violin'),
	(7,4,'Baton'),
	(7,5,'Violin'),
	(7,7,'Flute'),
	(8,2,'Kettledrum'),
	(8,3,'Violin'),
	(8,4,'Baton'),
	(8,5,'Violin'),
	(8,7,'Flute'),
	(9,9,'Violin'),
	(9,1,'Baton'),
	(9,4,'Violin'),
	(9,5,'Guitar'),
	(9,10,'Violin'),
	(9,1,'Kettledrum'),
	(9,1,'Triangle'),
	(10,1,'Triangle'),
	(10,2,'Violin'),
	(10,3,'Baton'),
	(11,10,'Violin'),
	(11,12,'Trumpet'),
	(11,14,'Violin'),
	(11,3,'Baton'),
	(12,1,'Piano'),
	(12,2,'Violin'),
	(12,3,'Baton'),
	(12,4,'Violin'),
	(12,7,'Flute');

INSERT INTO con_pie VALUES
	(1,1),
	(1,2),
	(1,3),
	(2,4),
	(3,2),
	(3,5),
	(4,1),
	(4,4),
	(4,11),
	(5,8),
	(5,9),
	(6,1),
	(6,8),
	(6,9),
	(6,11),
	(7,2),
	(7,7),
	(7,10),
	(7,16),
	(8,1),
	(8,2),
	(8,6),
	(9,15),
	(10,1),
	(10,7),
	(11,10),
	(12,9),
	(12,8);
