-- 1. Procedimiento que incrementa o decrementa el precio
-- de un producto. 
-- Los parámetros de entrada son:
-- -- Identificador del producto
-- -- Porcentaje de incremento/decremento
-- Un parámetro de salida devuelve el nuevo precio si se
-- ha podido calcular, o NULL en caso contrario.


DELIMITER //
DROP PROCEDURE IF EXISTS upsert_price //
CREATE PROCEDURE upsert_price(
    par_product_id INT(5),
    par_porcentaje FLOAT,
    OUT par_out DECIMAL(6,2)
)
BEGIN 
      SET par_out=(
      	SELECT ROUND(price+price*par_porcentaje/100,2)
        FROM product
        WHERE product_id=par_product_id
      );
      IF par_out IS NOT NULL THEN
        UPDATE product
        SET price=par_out
        WHERE product_id=par_product_id;
    END IF;
END //
DELIMITER ;

-- 2. Incrementa el precio de un producto un 10%

CALL upsert_price(1,10,@x);
SELECT @x

-- 3. Decrementa el precio de un producto un 1.5%

CALL upsert_price(2,-1.5,@x);
SELECT @x

-- 4. Lo mismo con un producto que no existe

CALL upsert_price(30,10,@x);
SELECT @x

-- 5. Procedimiento que inserta una nueva factura.
-- Los parámetros de entrada son:
-- -- Fecha
-- -- Identificador del cliente
-- -- Identificador del vehículo
-- Un parámetro de salida devuelve el identificador
-- de la factura si se ha podido insertar, o NULL en caso 
-- contrario (cliente o vehículo inexistentes).

DELIMITER //
DROP PROCEDURE IF EXISTS ins_invoice//
CREATE PROCEDURE ins_invoice (
  par_date DATE,
 par_client_id INT(5),
 par_vehicle_id VARCHAR(7),
 OUT par_invoice_id INT(8)

)

BEGIN 
  IF par_client_id NOT IN (
    SELECT client_id
    FROM client
  )
  OR
  par_vehicle_id NOT IN (
    SELECT vehicle_id
    FROM vehicle
  )
  THEN
    SET par_invoice_id=NULL;
  ELSE
    SET par_invoice_id=nex_inv_date(YEAR(par_date));
    INSERT INTO invoice (invoice_id,invoice_date,client_id,vehicle_id) 
    VALUES (par_invoice_id,par_date,par_client_id,par_vehicle_id);
  END IF;
  END//
DELIMITER ;

-- 6. Inserta una factura con fecha 13-11-2019 del cliente 4
-- y el vehículo 9090GRR

CALL ins_invoice("2019-11-13",4,"9090GRR",@x);
SELECT @x;

-- 7. Inserta una factura con fecha 23-12-2020 del cliente 12
-- y el vehículo 9090GRR

CALL ins_invoice("2020-12-23",12,"9090GRR",@x);
SELECT @x;


-- 8. Inserta una factura con fecha 23-12-2020 del cliente 10
-- y el vehículo 9091GRR

CALL ins_invoice("2020-12-23",10,"9091GRR",@x);
SELECT @x;
