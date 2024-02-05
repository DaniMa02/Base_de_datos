-- 1. Función que devuelve el número de facturas del cliente que se 
-- pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS count_invoices//
CREATE FUNCTION count_invoices(par_client_id INT(5))
RETURNS INT
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM invoice
		WHERE client_id=par_client_id
	);
END//
DELIMITER ;

-- 2. Probar la función anterior con todos los clientes

SELECT *, count_invoices(client_id)
FROM client;

-- 3. Todos los datos del cliente con más facturas

SELECT *, count_invoices(client_id)
FROM client
WHERE count_invoices(client_id) >= ALL (
	SELECT count_invoices(client_id)
	FROM client
);

-- 4. Función que devuelve la suma de importe de las facturas
-- del cliente que se pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS sum_import_client//
CREATE FUNCTION sum_import_client(par_client_id INT(5))
RETURNS DECIMAL(8,2)
BEGIN
	RETURN (
		SELECT IFNULL(SUM(i.price_hour*iw.hours),0)
		FROM invoice i, item_work iw
		WHERE i.invoice_id=iw.invoice_id
		AND i.client_id=par_client_id
	) + (
		SELECT IFNULL(SUM(ip.units*ip.price),0)
		FROM invoice i, item_product ip
		WHERE i.invoice_id=ip.invoice_id
		AND i.client_id=par_client_id
	);
END//
DELIMITER ;

-- 5. Probar la función anterior con todos los clientes

SELECT *, count_invoices(client_id) AS count_inv,
sum_import_client(client_id) AS sum_imp
FROM client;

-- 6. Todos los datos de clientes con más importe que la media

SELECT *, count_invoices(client_id) AS count_inv,
sum_import_client(client_id) AS sum_imp
FROM client
WHERE sum_import_client(client_id) > (
	SELECT AVG(sum_import_client(client_id))
	FROM client
);

-- 7. Función que devuelve el importe de una factura que
-- se pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS imp_invoice//
CREATE FUNCTION imp_invoice(par_invoice_id INT(8))
RETURNS DECIMAL(8,2) 
BEGIN
	RETURN ROUND(
		(
			SELECT IFNULL(SUM(i.price_hour*iw.hours),0)
			FROM invoice i, item_work iw
			WHERE i.invoice_id=iw.invoice_id
			AND i.invoice_id=par_invoice_id
		) + (
			SELECT IFNULL(SUM(units*price),0)
			FROM item_product
			WHERE invoice_id=par_invoice_id
		)
	,2);	
END//
DELIMITER ;

-- 8. Probar la función anterior con todas las facturas

SELECT *, imp_invoice(invoice_id)
FROM invoice;

-- 9. La factura con el importe máximo

SELECT *, imp_invoice(invoice_id)
FROM invoice
WHERE imp_invoice(invoice_id) >= ALL (
	SELECT imp_invoice(invoice_id)
	FROM invoice
);

-- 10. Función que devuelve la suma de unidades vendidas
-- del producto que se pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS sum_units//
CREATE FUNCTION sum_units(par_product_id INT)
RETURNS INT
BEGIN
	RETURN (
		SELECT IFNULL(SUM(units),0)
		FROM item_product
		WHERE product_id=par_product_id
	);
END//
DELIMITER ;

-- 11. Probar la función anterior con todos los productos

SELECT *, sum_units(product_id)
FROM product;

-- 12. El producto más vendido

SELECT *, sum_units(product_id)
FROM product
WHERE sum_units(product_id) >= ALL (
	SELECT sum_units(product_id)
	FROM product
);

-- Lo mismo usando MAX

SELECT *, sum_units(product_id)
FROM product
WHERE sum_units(product_id) = (
	SELECT MAX(sum_units(product_id))
	FROM product
);

-- 13. Función que devuelve la suma de importe facturado
-- en la fecha que se pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS sum_imp_dat//
CREATE FUNCTION sum_imp_dat(par_date DATE)
RETURNS DECIMAL(8,2)
BEGIN
	RETURN (
		SELECT SUM(imp_invoice(invoice_id))
		FROM invoice
		WHERE invoice_date=par_date
	);
END//
DELIMITER ;

-- 14. Probar el funcionamiento con todas las fechas (sin duplicados)
-- en las que haya facturas

SELECT DISTINCT invoice_date, sum_imp_dat(invoice_date)
FROM invoice;

-- 15. Función que devuelve la suma de importe facturado
-- del vehículo cuya matrícula se pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS sum_imp_veh//
CREATE FUNCTION sum_imp_veh(par_vehicle_id VARCHAR(7))
RETURNS DECIMAL(8,2)
BEGIN
	RETURN (
		SELECT IFNULL(SUM(imp_invoice(invoice_id)),0)
		FROM invoice
		WHERE vehicle_id=par_vehicle_id
	);
END//
DELIMITER ;

-- 16. Suma de importe e iva facturado a cada vehículo

SELECT *, sum_imp_veh(vehicle_id) AS import, 
ROUND(sum_imp_veh(vehicle_id)*0.21,2) AS iva
FROM vehicle;

-- 17. Función que recibe como parámetro los cuatro dígitos
-- de un año y devuelve el número siguiente de la última factura
-- de ese año

DELIMITER //
DROP FUNCTION IF EXISTS next_invoice//
CREATE FUNCTION next_invoice(par_year INT(4))
RETURNS INT(8)
BEGIN
	RETURN (
		SELECT IFNULL(MAX(invoice_id)+1,par_year*10000+1)
		FROM invoice
		WHERE YEAR(invoice_date)=par_year
	);
END//
DELIMITER ;

-- 18. Prueba la función con los años 2019, 2020, 2021 y 2022

SELECT next_invoice(2019); --> 20190009
SELECT next_invoice(2020); --> 20200007
SELECT next_invoice(2021); --> 20210003
SELECT next_invoice(2022); --> 20220001

-- 19. Función que recibe como parámetros la matrícula de un vehículo
-- y los kilómetros actuales y devuelve los kilómetros recorridos 
-- desde la última factura

DELIMITER //
DROP FUNCTION IF EXISTS kms_run//
CREATE FUNCTION kms_run(par_vehicle_id VARCHAR(7), par_kms INT(6))
RETURNS INT(6)
BEGIN
	RETURN (
		SELECT par_kms-MAX(kms)
		FROM invoice
		WHERE vehicle_id=par_vehicle_id
	);
END//
DELIMITER ;

-- 20. Entra en el taller el vehículo 2134KJH con 76543 kilómetros.
-- ¿Cuántos kilómetros recorrió desde la última factura?

SELECT kms_run('2134KJH',76543);