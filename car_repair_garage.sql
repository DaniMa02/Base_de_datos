CREATE TABLE client (
  client_id int(5) PRIMARY KEY AUTO_INCREMENT,
  cif varchar(9),
  name varchar(30),
  email varchar(30),
  phone_number int(9),
  address varchar(30),
  city varchar(30)
);

INSERT INTO client (client_id, cif, name, email, phone_number, address, city) VALUES
(NULL, '91231523K', 'Kobayashi, Kazuto', NULL, 665665123, 'Gran Vía 23', 'Bollullos'),
(NULL, '09980598G', 'Smith, John', 'smith123@gmx.com', 959765432, 'Constitución 1', 'Bollullos'),
(NULL, '76557650M', 'Pérez García, Ana', NULL, 625144144, 'Concepción 18', 'Bollullos'),
(NULL, '09468765E', 'Deng, Li', 'deng_li@gmail.com', 678678678, 'Gran Vía 22', 'Bollullos'),
(NULL, '87265543P', 'Strogonoff, Irina', NULL, 954772772, 'Recaredo 11', 'Bollullos'),
(NULL, '83831384A', 'Ngonga, Mobutu','ngonga@hotmail.com', 665432100, 'Av. Andalucía 3','Huelva'),
(NULL, '27654210F', 'Pérez, Ana','perez@yahoo.es', 959667722, 'Gran Vía 22','Huelva'),
(NULL, '10203038H', 'Díaz, José','diaz@gmail.com', NULL, 'Santa Marta 5','Huelva'),
(NULL, '18726364M', 'Maroto, Eva','maroto@gmail.com', NULL, 'Gran Vía 8','Huelva'),
(NULL, '28765433V', 'García, Luis','garcia@yahoo.es', NULL, 'Av. Andalucía 6','Huelva');

CREATE TABLE vehicle (
  vehicle_id varchar(7) PRIMARY KEY,
  brand varchar(30),
  model varchar(30),
  color varchar(30)
);

INSERT INTO vehicle (vehicle_id, brand, model, color) VALUES
('0022HHY', 'Opel', 'Corsa', 'Red'),
('0987QQQ', 'Renault', 'Clio', 'Red'),
('2134KJH', 'Opel', 'Corsa', 'Blue'),
('8765WRT', 'Mercedes', 'Clase A', 'Yellow'),
('9090GRR', 'Mercedes', 'Clase A', 'White'),
('7654FCT', 'Renault', 'Megane', 'Red'),
('8345PKT', 'Renault', 'Megane', 'White');

CREATE TABLE invoice (
  invoice_id int(8) PRIMARY KEY,
  invoice_date date,
  client_id int(5),
  kms int(6),
  vehicle_id varchar(7),
  price_hour decimal(6,2),
  FOREIGN KEY (client_id) REFERENCES client(client_id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id)
);

INSERT INTO invoice (invoice_id, invoice_date, client_id, kms, vehicle_id, price_hour) VALUES
('20190001', '2019-01-09', 1, 15010, '2134KJH', 34.25),
('20190002', '2019-01-12', 1, 15400, '2134KJH', 34.25),
('20190003', '2019-02-01', 2, 95000, '8765WRT', 34.25),
('20190004', '2019-02-03', 2, 37800, '0987QQQ', 34.25),
('20190005', '2019-02-16', 3, 44230, '0987QQQ', 36.75),
('20190006', '2019-03-19', 4, 67900, '0022HHY', 36.75),
('20190007', '2019-11-12', 5, 85200, '9090GRR', 36.75),
('20190008', '2019-11-12', 5, NULL, NULL, NULL),
('20200001', '2020-02-03', 2, 59800, '0987QQQ', 38.95),
('20200002', '2020-02-06', 3, 87230, '0987QQQ', 38.95),
('20200003', '2020-03-29', 4, 77900, '0022HHY', 38.95),
('20200004', '2020-10-12', 7, 86300, '9090GRR', 38.95),
('20200005', '2020-10-12', 7, NULL, NULL, NULL),
('20200006', '2020-11-02', 7, NULL, NULL, NULL),
('20210001', '2021-03-12', 7, 99300, '0987QQQ', 38.95),
('20210002', '2021-10-22', 7, 90350, '9090GRR', 38.95);

CREATE TABLE product (
  product_id int(5) PRIMARY KEY AUTO_INCREMENT,
  description varchar(30),
  price decimal(6,2)
);

INSERT INTO product (product_id, description, price) VALUES
(NULL, 'Battery 90A', 89.95),
(NULL, 'Battery 75A', 79.95),
(NULL, 'Battery 60A', 67.95),
(NULL, 'Spark plug', 5.95),
(NULL, 'Oil 20W50 5 liter', 24.10),
(NULL, 'Oil 30W50 5 liter', 23.75),
(NULL, 'Air filter', 14.60),
(NULL, 'Fuel filter', 15.95),
(NULL, 'Oil filter', 19.00),
(NULL, 'Windshield wipers', 54.95);

CREATE TABLE worker (
  worker_id int(5) PRIMARY KEY AUTO_INCREMENT,
  cif VARCHAR(9),
  name varchar(30),
  phone_number int(9)
);

INSERT INTO worker (worker_id, cif, name, phone_number) VALUES
(NULL, '87655544P', 'Pliskonov, Sergei', 665432432),
(NULL, '19887755J', 'Ferruti, Paolo', 959887766),
(NULL, '30876512H', 'Yoshimura, Erv', 954009988),
(NULL, '31099876B', 'García Pérez, Ana', 665887766),
(NULL, '12233400T', 'López López, Juan', 654121212),
(NULL, '83612417P', 'Kabuto, Noburu', NULL);

CREATE TABLE item_product (
  invoice_id int(8),
  product_id int(5),
  price decimal(6,2),
  units int(5),
  PRIMARY KEY (invoice_id, product_id),
  FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO item_product (invoice_id, product_id, price, units) VALUES
('20190001', 1, '79.00', 2),
('20190001', 8, '19.00', 1),
('20190002', 2, '65.00', 1),
('20190003', 3, '5.00', 3),
('20190004', 8, '19.00', 1),
('20190005', 7, '15.00', 1),
('20190005', 8, '19.00', 2),
('20190007', 3, '4.25', 4),
('20190007', 7, '15.00', 1),
('20190008', 1, '80.00', 3),
('20200001', 1, '79.00', 2),
('20200001', 8, '19.00', 1),
('20200002', 2, '65.00', 1),
('20200003', 3, '5.00', 3),
('20200004', 8, '19.00', 1),
('20200004', 7, '29.00', 2),
('20200004', 6, '59.00', 1),
('20200005', 6, '59.00', 4),
('20200006', 6, '59.00', 3);

CREATE TABLE item_work (
  invoice_id int(8),
  worker_id int(5),
  hours decimal(3,1),
  PRIMARY KEY (invoice_id, worker_id),
  FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
  FOREIGN KEY (worker_id) REFERENCES worker(worker_id)
);

INSERT INTO item_work (invoice_id, worker_id, hours) VALUES
(20190001, 1, '2.0'),
(20190002, 2, '3.5'),
(20190003, 3, '10.0'),
(20190004, 4, '1.0'),
(20190005, 5, '9.5'),
(20190006, 4, '6.5'),
(20190006, 5, '4.0'),
(20190007, 3, '2.5'),
(20200002, 3, '3.5'),
(20200002, 1, '2.0');

