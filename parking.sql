-- Diseñar una base de datos para un aparcamiento. En la puerta controlamos
-- la matrícula y la fecha/hora de los vehículos que entran y salen.
-- En cada planta del edificio tenemos varias plazas de aparcamiento.
-- En cada plaza de aparcamiento registramos todos los datos del
-- vehículo que la ocupa: matrícula, marca, modelo y color.
-- Cada vez que un vehículo sale del aparcamiento se le imprime y cobra
-- un tiquet por su estancia. Tenemos una tabla de precios por minuto y 
-- por días completos que varían en el tiempo.

CREATE TABLE vehicle(
	vehicle_id VARCHAR(8) PRIMARY KEY,
	mark VARCHAR(30),
	model VARCHAR(30),
	color VARCHAR(30)
);

CREATE TABLE place(
	place_id INTEGER PRIMARY KEY,
	place_floor INTEGER
);

CREATE TABLE stay(
	stay_id INTEGER PRIMARY KEY,
	in_date DATETIME,
	out_date DATETIME,
	vehicle_id VARCHAR(8),
	place_id INTEGER,
	FOREIGN KEY fk1(vehicle_id) REFERENCES vehicle(vehicle_id),
	FOREIGN KEY fk2(place_id) REFERENCES place(place_id)
);

CREATE TABLE price(
	price_id INTEGER PRIMARY KEY,
	from_date DATE,
	until_date DATE,
	price_day DECIMAL(5,3),
	price_minute DECIMAL(5,3)
);

INSERT INTO vehicle VALUES
('1234-GCS','Renault','Clio','Azul'),
('5432-GGS','Citroen','C3','Verde'),
('0987-BSR','Citroen','C1','Plata'),
('7890-CVF','Renault','Twingo','Blanco'),
('0973-BGF','Mercedes','E','Blanco'),
('4343-BNM','Citroen','C4','Rojo'),
('2211-CSD','Opel','Astra','Amarillo'),
('6755-CQW','Renault','Laguna','Rojo'),
('1661-CZX','Renault','Megane','Rojo'),
('5554-BFF','Opel','Senator','Amarillo'),
('3245-CFD','Opel','Kadett','Gris'),
('5654-CXZ','Opel','Corsa','Amarillo'),
('3454-GFF','Citroen','C3','Rojo'),
('6767-GFR','Citroen','C5','Gris'),
('9909-CFD','Mercedes','A','Gris'),
('9919-CFH','Mercedes','B','Gris'),
('9949-CFD','Mercedes','C','Azul'),
('2245-BHG','Mercedes','C','Amarillo'),
('1135-BBV','Opel','Astra','Gris'),
('7676-BFJ','Opel','Insignia','Gris');

INSERT INTO place VALUES
(1,1),
(2,1),
(3,1),
(4,2),
(5,2),
(6,2),
(7,2),
(8,2);

INSERT INTO stay VALUES
(1,'2018-10-01 00:05',NULL,'1234-GCS',1),
(2,'2018-10-01 00:12','2018-10-01 08:23','5432-GGS',1),
(3,'2018-10-01 00:13',NULL,'0987-BSR',3),
(4,'2018-10-01 01:23','2018-10-03 00:54','7890-CVF',3),
(5,'2018-10-01 03:45','2018-10-01 22:22','0973-BGF',2),
(6,'2018-10-01 05:22','2018-10-01 06:11','4343-BNM',6),
(7,'2018-10-01 08:21','2018-10-02 02:12','2211-CSD',4),
(8,'2018-10-01 09:34','2018-10-01 10:34','6755-CQW',1),
(9,'2018-10-01 10:55','2018-10-01 11:52','1661-CZX',2),
(10,'2018-10-01 11:54','2018-10-01 14:39','5554-BFF',1),
(11,'2018-10-01 12:43','2018-10-01 23:01','3245-CFD',2),
(12,'2018-10-01 14:23','2018-10-01 22:00','5654-CXZ',5),
(13,'2018-10-01 17:11','2018-10-01 22:00','3454-GFF',2),
(14,'2018-10-01 18:54','2018-10-01 19:23','6767-GFR',2),
(15,'2018-10-02 02:33','2018-10-02 03:12','9909-CFD',3),
(16,'2018-10-02 03:12','2018-10-02 04:34','2245-BHG',6),
(17,'2018-10-02 03:21','2018-10-03 02:12','1135-BBV',6),
(18,'2018-10-02 11:59','2018-10-02 12:45','7676-BFJ',6),
(19,'2018-10-03 09:33','2018-10-03 10:54','7890-CVF',3),
(20,'2018-10-03 10:22','2018-10-03 11:22','0973-BGF',1),
(21,'2018-10-03 11:55',NULL,'4343-BNM',6),
(22,'2018-10-03 11:44',NULL,'2211-CSD',4),
(23,'2018-10-03 14:01','2018-10-04 14:34','6755-CQW',3),
(24,'2018-10-03 16:20',NULL,'1661-CZX',2),
(25,'2018-10-04 00:12','2018-10-09 08:43','5432-GGS',1),
(26,'2018-10-04 17:01',NULL,'6755-CQW',5);

INSERT INTO price VALUES
(1,'2017-01-01','2017-06-30',12.00,0.010),
(2,'2017-07-01','2017-12-31',12.10,0.011),
(3,'2018-01-01','2018-10-02',12.20,0.012),
(4,'2018-10-03',NULL,12.30,0.013);
