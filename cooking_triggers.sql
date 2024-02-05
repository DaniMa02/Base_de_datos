-- Los valores de los campos de la fila afectada por la operación DML
-- están disponibles con los prefijos old y new:
-- -- INSERT sólo new
-- -- DELETE sólo old
-- -- UPDATE old y new

-- Básicamente los triggers se usan para dos funciones:
-- -- Guardar información de auditoría
-- -- Abortar operaciones no autorizadas que incumplen alguna restricción

-- 1. Disparador para auditar actualizaciones en la tabla ingredients. 
-- Se inserta en la tabla audit_price la fecha-tiempo de la operación, el 
-- identificador del ítem y el porcentaje de incremento (positivo o 
-- negativo) del precio del ingrediente. 
-- Pero si el porcentaje es cero (el precio no cambia), entonces no se 
-- inserta nada.

CREATE TABLE audit_price (
    audit_id INT(6) PRIMARY KEY AUTO_INCREMENT,
    audit_datetime DATETIME,
    ingredient_id INT(6),
    incre DECIMAL(6,2)
);

DELIMITER //
DROP TRIGGER IF EXISTS upd_price //
CREATE TRIGGER upd_price
BEFORE UPDATE ON ingredient
FOR EACH ROW
BEGIN
	DECLARE x DECIMAL(6,2);
	SET x = (new.price-old.price)/old.price*100;
	IF NOT x = 0 
	THEN 
		INSERT INTO audit_price(audit_datetime,ingredient_id,incre) VALUES
		(CURRENT_TIMESTAMP,new.ingredient_id,x);
	END IF;

END //
DELIMITER ;

-- 2. Disparador que impide que se puedan borrar filas de la tabla
-- command con más de 30 días de antigüedad 

DELIMITER //
DROP TRIGGER IF EXISTS no_del_command //
CREATE TRIGGER no_del_command
BEFORE DELETE ON command
FOR EACH ROW
BEGIN
		IF TIMESTAMPDIFF(DAY,old.command_date,CURRENT_DATE) >30 
			THEN
			SIGNAL SQLSTATE '20001' SET message_text='Error: ME LA SUDA';
		END IF;
END //
DELIMITER ;



-- 3. Disparador que impide que se puedan insertar filas de la tabla
-- command si existen más de cinco comandas con igual fecha que la
-- fecha de la que se está insertando

DELIMITER //
DROP TRIGGER IF EXISTS no_ins_command //
CREATE TRIGGER no_ins_command
BEFORE INSERT ON command 
FOR EACH ROW
BEGIN
	 DECLARE x INT ;
	 SET x = (
		SELECT COUNT(*)
		FROM command
		WHERE command_date = new.command_date
	 );

	 IF x > 5 
	 THEN 
		SIGNAL SQLSTATE '20002' SET message_text='Error: ME LA SUDA X2';

	 END IF;
END //
DELIMITER ;

-- 4. Se quiere guardar en la tabla audit_price el nombre del usuario
-- que realiza el cambio de precio. 

DROP TABLE IF EXISTS audit_price //
CREATE TABLE audit_price (
    audit_id INT(6) PRIMARY KEY AUTO_INCREMENT,
	username VARCHAR(30),
    audit_datetime DATETIME,
    ingredient_id INT(6),
    incre DECIMAL(6,2)
);

DELIMITER //
DROP TRIGGER IF EXISTS upd_price //
CREATE TRIGGER upd_price
BEFORE UPDATE ON ingredient
FOR EACH ROW
BEGIN
	DECLARE x DECIMAL(6,2);
	SET x = (new.price-old.price)/old.price*100;
	IF NOT x = 0 
	THEN 
		INSERT INTO audit_price(username,audit_datetime,ingredient_id,incre) VALUES
		(USER(),CURRENT_TIMESTAMP,new.ingredient_id,x);
	END IF;

END //
DELIMITER ;


-- 5. Disparador que impide que se inserte una nueva comanda si no hay
-- suficiente stock de alguno de los ingredientes

DELIMITER //
DROP TRIGGER IF EXISTS no_ins_command //
CREATE TRIGGER no_ins_command
BEFORE INSERT ON command
FOR EACH ROW
BEGIN
	IF NOT enough_stock(new.recipe_id,new.rations)
	THEN 
		SIGNAL SQLSTATE '20003' SET message_text='Error: ME LA SUDA X3';
	END IF;
END //
DELIMITER ;



-- 6. Modificar el disparador anterior para que se actualice el stock
-- de los ingredientes de la receta de la comanda

DELIMITER //
DROP TRIGGER IF EXISTS no_ins_command //
CREATE TRIGGER no_ins_command
BEFORE INSERT ON command
FOR EACH ROW
BEGIN
	IF NOT enough_stock(new.recipe_id,new.rations)
	THEN 
		SIGNAL SQLSTATE '20003' SET message_text='Error: ME LA SUDA X3';
	ELSE 
		UPDATE ingredient i1
		SET stock = stock - (
			SELECT quantity*new.rations
			FROM item i2
			WHERE i1.ingredient_id=i2.ingredient_id
			AND recipe_id=new.recipe_id
		) ;
	END IF;
END //
DELIMITER ;





