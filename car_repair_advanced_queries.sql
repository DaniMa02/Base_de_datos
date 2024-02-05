-- 1. Diferencia de precio entre el producto más caro y el más barato

SELECT MAX(price)-MIN(price) AS price_difference
FROM product;

-- 2. Diferencia de precio entre la batería de 75A y la de 90A

SELECT ABS(p1.price-p2.price)
FROM product p1, product p2
WHERE p1.description='Battery 75A' AND p2.description='Battery 90A';

-- 3. Precio medio de las baterías

SELECT AVG(price)
FROM product
WHERE description LIKE 'Battery%';

-- 4. Para cada marca, número de vehículos

SELECT brand, COUNT(*)
FROM vehicle
GROUP BY brand;

-- 5. Para cada marca y modelo, número de vehículos

SELECT brand, model, COUNT(*)
FROM vehicle
GROUP BY brand, model;

-- 6. Equijoin de las tablas client, invoice y vehicle

SELECT *
FROM client c, invoice i, vehicle v
WHERE c.client_id=i.client_id AND i.vehicle_id=v.vehicle_id;

-- 7. Identificadores de clientes que tengan un vehículo Renault

SELECT DISTINCT i.client_id
FROM invoice i, vehicle v
WHERE i.vehicle_id=v.vehicle_id
AND v.brand='Renault';

-- 8. Todos los datos de clientes que tengan un vehículo Renault

SELECT DISTINCT c.*
FROM client c, invoice i, vehicle v
WHERE c.client_id=i.client_id AND i.vehicle_id=v.vehicle_id
AND v.brand='Renault';

-- 9. Identificadores de mecánicos que hayan hecho alguna reparación a un Renault

SELECT DISTINCT iw.worker_id
FROM vehicle v, invoice i, item_work iw
WHERE v.vehicle_id=i.vehicle_id AND i.invoice_id=iw.invoice_id
AND v.brand='Renault';

-- 10. Todos los datos de mecánicos que hayan hecho alguna reparación a un Renault

SELECT DISTINCT w.*
FROM vehicle v, invoice i, item_work iw, worker w
WHERE v.vehicle_id=i.vehicle_id AND i.invoice_id=iw.invoice_id
AND iw.worker_id=w.worker_id
AND v.brand='Renault';

-- 11. Todos los datos de los ítems de piezas, calculando el importe e IVA (21%)

SELECT *, price*units AS import, ROUND(price*units*0.21,2) AS iva
FROM item_product;

-- 12. Añadir a la consulta anterior la descripción de la pieza

SELECT i.*, p.description, i.price*i.units AS import, ROUND(i.price*i.units*0.21,2) AS iva
FROM item_product i, product p
WHERE i.product_id=p.product_id;

-- 13. Todos los datos de los ítems de mano de obra, calculando el importe e IVA (21%)

SELECT iw.*, i.price_hour*iw.hours AS import, 
ROUND(i.price_hour*iw.hours*0.21,2) AS iva
FROM invoice i, item_work iw
WHERE i.invoice_id=iw.invoice_id;

-- 14. Añadir a la consulta anterior el nombre del mecánico

SELECT iw.*, w.name, i.price_hour*iw.hours AS import, 
ROUND(i.price_hour*iw.hours*0.21,2) AS iva
FROM invoice i, item_work iw, worker w
WHERE i.invoice_id=iw.invoice_id AND iw.worker_id=w.worker_id;

-- 15. Clientes (sin duplicados) que tengan alguna factura

SELECT DISTINCT client_id
FROM invoice;

-- Si queremos todos los datos, es necesario equijoin

SELECT DISTINCT c.*
FROM client c, invoice i
WHERE c.client_id=i.client_id;

-- 16. Vehículos (sin duplicados) que tengan alguna factura

SELECT DISTINCT vehicle_id
FROM invoice;

-- Si queremos todos los datos, es necesario equijoin

SELECT DISTINCT v.*
FROM vehicle v, invoice i
WHERE v.vehicle_id=i.vehicle_id;

-- 17. Suma de importe y de iva de piezas de la factura 20190001

SELECT SUM(price*units) AS sum_import, 
SUM(ROUND(price*units*0.21,2)) AS sum_iva
FROM item_product
WHERE invoice_id=20190001;

-- 18. Suma de importe y de iva de mano de obra de la factura 20190005

SELECT ROUND(SUM(i.price_hour*iw.hours),2) AS import
ROUND(SUM(i.price_hour*iw.hours)*0.21,2) AS iva
FROM invoice i, item_work iw
WHERE i.invoice_id=iw.invoice_id AND i.invoice_id=20190005;

-- 19. Inserta un nuevo vehículo Mercedes Clase A y matrícula 9090GRR

INSERT INTO vehicle
VALUES ('9090GRR','Mercedes','Clase A',NULL);

-- 20. Inserta una nueva factura del coche anterior con 85200 kms,
-- la fecha de hoy y el cliente es Sayaka Yamamoto
-- Ojo: Previamente hay que añadir el cliente

INSERT INTO client(name) VALUES
('Yamamoto, Sayaka');

INSERT INTO invoice(invoice_id,client_id,invoice_date,vehicle_id,kms) VALUES
(20230001,11,'2023-01-11','9090GRR',85200);

-- 21. El mecánico Michael Kurtiss le ha cambiado el espejo derecho y cuatro bujías, 
-- empleando dos horas y media; inserta los ítems correspondientes (factura nueva y item_work)

INSERT INTO worker(name) VALUES 
('Kurtiss, Michael');

INSERT INTO item_work(invoice_id,worker_id,hours) VALUES
(20230001,7,2.5);

INSERT INTO product(description, price) VALUES
('Right mirror',120);

INSERT INTO item_product(invoice_id,product_id, price, units) VALUES
(20230001,4,5.95,4),
(20230001,11,120,1);

-- 22. Items de piezas donde aparezcan las bujías

SELECT i.*
FROM item_product i, product p
WHERE i.product_id=p.product_id
AND p.description='Spark Plug';

-- 23. Identificadores de facturas donde aparezca Michael Kurtiss

SELECT iw.invoice_id
FROM item_work iw, worker w
WHERE iw.worker_id=w.worker_id
AND w.name='Kurtiss, Michael';

-- 24. Todos los datos de facturas donde aparezca Michael Kurtiss

SELECT i.*
FROM invoice i, item_work iw, worker w
WHERE i.invoice_id=iw.invoice_id 
AND iw.worker_id=w.worker_id
AND w.name='Kurtiss, Michael';

-- 25. En cuántos vehículos distintos ha trabajado Michael Kurtiss

SELECT COUNT(DISTINCT i.vehicle_id)
FROM invoice i, item_work iw, worker w
WHERE i.invoice_id=iw.invoice_id 
AND iw.worker_id=w.worker_id
AND w.name='Kurtiss, Michael';

-- 26. En cuántas marcas de vehículos distintos ha trabajado Michael Kurtiss

SELECT COUNT(DISTINCT v.brand)
FROM vehicle v, invoice i, item_work iw, worker w
WHERE v.vehicle_id=i.vehicle_id
AND i.invoice_id=iw.invoice_id 
AND iw.worker_id=w.worker_id
AND w.name='Kurtiss, Michael';

-- 27. Para cada identificador de factura, número de items de piezas,
-- suma de importe y suma de IVA (21%)

SELECT invoice_id, COUNT(*), SUM(price*units) AS import,
ROUND(SUM(price*units)*0.21,2) AS iva
FROM item_product
GROUP BY invoice_id;

-- 28. Lo mismo de antes pero añadiendo la fecha de factura

SELECT i.invoice_id, i.invoice_date,
COUNT(*), SUM(price*units) AS import,
ROUND(SUM(price*units)*0.21,2) AS iva
FROM invoice i, item_product ip
WHERE i.invoice_id=ip.invoice_id
GROUP BY i.invoice_id, i.invoice_date;

-- 29. Lo mismo de antes añadiendo el cif y el nombre del cliente

SELECT i.invoice_id, i.invoice_date, c.cif, c.name,
COUNT(*), SUM(price*units) AS import,
ROUND(SUM(price*units)*0.21,2) AS iva
FROM client c, invoice i, item_product ip
WHERE c.client_id=i.client_id
AND i.invoice_id=ip.invoice_id
GROUP BY i.invoice_id, i.invoice_date, c.cif, c.name;

-- 30. Lo mismo pero sin el identificador de factura y
-- la fecha agrupando sólo por cliente

SELECT c.cif, c.name,
COUNT(*), SUM(price*units) AS import,
ROUND(SUM(price*units)*0.21,2) AS iva
FROM client c, invoice i, item_product ip
WHERE c.client_id=i.client_id
AND i.invoice_id=ip.invoice_id
GROUP BY c.cif, c.name;

-- 31. Para cada año y mes, número de facturas

SELECT YEAR(invoice_date), MONTH(invoice_date),
COUNT(*) AS num_invoices
FROM invoice
GROUP BY YEAR(invoice_date), MONTH(invoice_date);

-- 32. Para cada año y mes, número de ítems y suma de importe de piezas

SELECT YEAR(invoice_date), MONTH(invoice_date),
COUNT(*), SUM(price*units) AS import
FROM invoice i, item_product ip
WHERE i.invoice_id=ip.invoice_id
GROUP BY YEAR(invoice_date), MONTH(invoice_date);

-- 33. Para cada mecánico, su nombre y suma de horas

SELECT w.name, SUM(i.hours)
FROM item_work i, worker w
WHERE i.worker_id=w.worker_id
GROUP BY w.name;

---------------- SUBCONSULTAS --------------------
-- Es una consulta anidada en una consulta
-- El nivel de anidamiento no tiene límite
-- Siempre entre paréntesis
-- Puede devolver una o varias filas
-- Puede devolver una o varias columnas
-- Pueden aparecer en casi cualquier parte de una consulta
-- Primero se evalúa la subconsulta y luego la consulta
-- Las subconsultas son más eficientes y modulares

-- 34. Todos los datos de items de Erv Yoshimura

-- Equijoin

SELECT i.*
FROM item_work i, worker w
WHERE i.worker_id=w.worker_id
AND w.name='Yoshimura, Erv';

-- Subconsulta

SELECT *
FROM item_work
WHERE worker_id=(
	SELECT worker_id
	FROM worker
	WHERE name='Yoshimura, Erv'
);

-- 35. Todas las facturas de Li Deng

SELECT *
FROM invoice
WHERE client_id=(
	SELECT client_id
	FROM client
	WHERE name='Deng, Li'
);

-- 36. Todas las facturas de vehículos Renault

SELECT *
FROM invoice
WHERE vehicle_id IN (
	SELECT vehicle_id
	FROM vehicle
	WHERE brand='Renault'
);

-- 37. Diferencia de precio entre la batería de 75A y la de 90A

SELECT (
	SELECT price
	FROM product
	WHERE description='Battery 90A'
) - (
	SELECT price
	FROM product
	WHERE description='Battery 75A'
);

-- 38. Todos los datos de clientes que tengan un 
-- vehículo de marca Renault

SELECT *
FROM client
WHERE client_id IN (
	SELECT client_id
	FROM invoice
	WHERE vehicle_id IN (
		SELECT vehicle_id
		FROM vehicle
		WHERE brand='Renault'
	)
);

-- 39. Todos los datos de facturas de clientes de Bollullos

SELECT *
FROM invoice
WHERE client_id IN (
	SELECT client_id
	FROM client
	WHERE city='Bollullos'
);

-- 40. Todos los datos de facturas del vehículo 0987QQQ

SELECT *
FROM invoice
WHERE vehicle_id='0987QQQ';

-- 41. Todos los datos de facturas de vehículos que no son Opel

SELECT *
FROM invoice
WHERE vehicle_id IN (
	SELECT vehicle_id
	FROM vehicle
	WHERE brand != 'Opel'
);

-- 42. Todos los datos del producto más caro

SELECT *
FROM product
WHERE price = (
	SELECT MAX(price)
	FROM product
);

-- 43. Todos los datos de los productos más baratos que la media

SELECT *
FROM product
WHERE price < (
	SELECT AVG(price)
	FROM product
);

-- 44. Todos los datos de clientes con facturas

SELECT *
FROM client
WHERE invoice_id IN (
	SELECT invoice_id
	FROM invoice
);

-- 45. Todos los datos de clientes sin facturas

SELECT *
FROM client
WHERE invoice_id NOT IN (
	SELECT invoice_id
	FROM invoice
);

-- 46. Todos los datos de productos que no se han vendido nunca

SELECT *
FROM product
WHERE product_id NOT IN (
	SELECT product_id
	FROM item_product
);

-- 47. Todos los datos de clientes que compraron el producto 2

SELECT *
FROM client
WHERE client_id IN (
	SELECT client_id
	FROM invoice
	WHERE invoice_id IN (
		SELECT invoice_id
		FROM item_product
		WHERE product_id=2
	)
);

-- 48. Todos los datos de clientes que compraron alguna batería

SELECT *
FROM client
WHERE client_id IN (
	SELECT client_id
	FROM invoice
	WHERE invoice_id IN (
		SELECT invoice_id
		FROM item_product
		WHERE product_id IN (
			SELECT product_id
			FROM product
			WHERE description LIKE 'Battery%'
		)
	)
);

-- 49. Identificador de vehículos reparados por Erv Yoshimura

SELECT vehicle_id
FROM invoice
WHERE invoice_id IN (
	SELECT invoice_id
	FROM item_work
	WHERE worker_id=(
		SELECT worker_id
		FROM worker
		WHERE name='Yoshimura, Erv'
	)
);

-- 50. Todos los datos de vehículos reparados por Erv Yoshimura

SELECT *
FROM vehicle
WHERE vehicle_id IN (
	SELECT vehicle_id
	FROM invoice
	WHERE invoice_id IN (
		SELECT invoice_id
		FROM item_work
		WHERE worker_id=(
			SELECT worker_id
			FROM worker
			WHERE name='Yoshimura, Erv'
		)
	)
);

-- 51. Facturas que tienen sólo ítems de productos

SELECT * FROM invoice
WHERE invoice_id IN (
	SELECT invoice_id
	FROM item_product
)
AND invoice_id NOT IN (
	SELECT invoice_id
	FROM item_work
);

-- 52. Facturas que tienen sólo ítems de mano de obra

SELECT * FROM invoice
WHERE invoice_id NOT IN (
	SELECT invoice_id
	FROM item_product
)
AND invoice_id IN (
	SELECT invoice_id
	FROM item_work
);

-- 53. Facturas que tienen ítems de productos y de mano de obra

SELECT * FROM invoice
WHERE invoice_id IN (
	SELECT invoice_id
	FROM item_product
)
AND invoice_id IN (
	SELECT invoice_id
	FROM item_work
);

-- 54. Facturas sin ningun ítem

SELECT * FROM invoice
WHERE invoice_id NOT IN (
	SELECT invoice_id
	FROM item_product
)
AND invoice_id NOT IN (
	SELECT invoice_id
	FROM item_work
);

-- 56. Todos los datos de clientes a los que no les haya 
-- reparado el coche nunca Erv Yoshimura

	SELECT *
	FROM client
	WHERE client_id NOT IN (
		SELECT client_id
		FROM invoice
		WHERE invoice_id IN (
			SELECT invoice_id
			FROM item_work
			WHERE worker_id = (
				SELECT worker_id
				FROM worker
				WHERE name="Yoshimura, Erv"
			)
		)

	)


-- El operador ALL se utiliza detrás de >= y de <= 
-- cuando la subconsulta devuelve varias filas.
-- Sirve para calcular máximos y mínimos

-- 57. Todos los datos de la factura más antigua


-- Solución usando MIN
SELECT *
FROM invoice
WHERE invoice_date = (
	SELECT MIN(invoice_date)
	FROM invoice
)
-- Solución usando ALL
SELECT *
FROM invoice
WHERE invoice_date <= ALL (
	SELECT invoice_date
	FROM invoice
)
-- La clausula HAVING sirve para poner condiciones
-- a los grupos, usando alguna función de agregados

-- 58. Identificadores de facturas con 2 ítems de productos

SELECT invoice_id, COUNT(*)
FROM item_product
GROUP BY invoice_id
HAVING COUNT(*)=2;


-- 59. Identificadores de clientes con más de una factura

SELECT client_id, COUNT(*)
FROM invoice
GROUP BY client_id
HAVING COUNT(*)>1

-- 60. Añadir a lo anterior todos los datos del cliente

SELECT c.*, COUNT(*)
FROM invoice i, client c
WHERE c.client_id=i.client_id
GROUP BY c.client_id, c.cif, c.name, c.address, c.city, c.phone_number
HAVING COUNT(*)>1

-- 61. Identificador del cliente con más facturas
-- Se requiere subconsulta en HAVING y el operador ALL

SELECT client_id, COUNT(*)
FROM invoice
GROUP BY client_id
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM invoice
	GROUP BY client_id
)

-- 62. Añadir a lo anterior todos los datos del cliente


SELECT c.*, COUNT(*)
FROM invoice i, client c
WHERE c.client_id=i.client_id
GROUP BY c.client_id, c.cif, c.name, c.address, c.city, c.phone_number
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM invoice
	GROUP BY client_id
)

-- 63. Identificador del producto que más se ha vendido


SELECT product_id, SUM(units)
FROM item_product
GROUP BY product_id
HAVING SUM(units) >= ALL (
	SELECT SUM(units)
	FROM item_product
	GROUP BY product_id
)

-- 64. Añadir a lo anterior todos los datos del producto

SELECT p.*, SUM(units)
FROM item_product ip, product p
WHERE ip.product_id=p.product_id
GROUP BY p.product_id, p.description, p.price
HAVING SUM(units) >= ALL (
	SELECT SUM(units)
	FROM item_product
	GROUP BY product_id
)

-- 65. Ciudad donde tenemos más clientes

SELECT city, COUNT(*)
FROM client
GROUP BY city
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM client
	GROUP BY city
)

-- 66. Marca con más vehículos

SELECT brand, COUNT(*)
FROM vehicle
GROUP BY brand
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM vehicle
	GROUP BY brand
)

-- 67. Identificador del mecánico con más horas

SELECT worker_id, SUM(hours)
FROM item_work
GROUP BY worker_id
HAVING SUM(hours) >= ALL (
	SELECT SUM(hours)
	FROM item_work
	GROUP	 BY worker_id
)

-- 68. Añadir a lo anterior todos los datos del mecánico

SELECT w.*, SUM(hours)
FROM item_work iw, worker w 
WHERE iw.worker_id=w.worker_id
GROUP BY w.worker_id, w.cif, w.name, w.phone_number
HAVING SUM(hours) >= ALL (
	SELECT SUM(hours)
	FROM item_work
	GROUP	 BY worker_id
)

-- 69. Todos los datos del vehiculo con mas facturas

SELECT v.*, COUNT(*)
FROM vehicle v, invoice i
WHERE v.vehicle_id=i.vehicle_id
GROUP BY v.vehicle_id, v.brand, v.model, v.color
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM invoice
	GROUP BY vehicle_id
)

-- 70. Todos los datos del vehiculo con mas suma de horas de mano de obra

SELECT v.*, SUM(iw.hours)
FROM item_work iw, invoice i, vehicle v
WHERE i.invoice_id=iw.invoice_id AND v.vehicle_id=i.vehicle_id
GROUP BY v.vehicle_id, v.brand, v.model, v.color
HAVING SUM(iw.hours) >= ALL (
	SELECT SUM(iw.hours)
	FROM item_work iw, invoice i
	WHERE i.invoice_id=iw.invoice_id
	GROUP BY i.vehicle_id
)

-- La funcion IF(condición, valor_si_verdadero, valor_si falso)

--71. Todos los datos de los productos, añadiendo una columna que indique si el producto es caro o barato si cuesta más de 100€ o no, respectivamente.

SELECT *, IF(price<100,"Cheap","Expensive") AS category
FROM product

-- 72. Lo mismo de antes pero teniendo en cuenta más casos:
-- -- Very cheap -> menor que 20€
-- -- Cheap -> menor que 40€
-- -- Medium -> menor que 60€
-- -- Expensive -> menor que 80€
-- -- Very expensive -> 80€ o más

SELECT *, 
IF(price<20,"Very Cheap",
	IF(price<40,"Cheap",
		IF(price<60,"Medium",
			IF(price<80,"Expensive","Very Expensive")))
)
AS category
FROM product

-- 73. Calcular un descuento para cada factura, en funcion de su importe de productos.
-- El 0% para facturas de hasta 100€.
-- El 10% para facturas de más de 100€.
-- El 15% para facturas de más de 200€.

SELECT invoice_id, SUM(price*units) AS import,
IF(SUM(price*units)<=100,0,
	IF SUM(price*units)<200,(SUM(price*units)*0.1), (SUM(price*units)*0.15) )
FROM item_product
GROUP BY invoice_id;



