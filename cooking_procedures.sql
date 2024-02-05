-- 1. Procedimiento que inserta o modifica un ingrediente.
-- Recibe como parámetros:
-- -- Descripción del ingrediente
-- -- Precio
-- -- Calorías
-- -- Stock
-- Si el ingrediente ya existe, se actualizan precio, calorías y stock.
-- Si el ingrediente es nuevo, se inserta una fila con todos los datos.

DELIMITER //
DROP PROCEDURE IF EXISTS upsert_ingredient//
CREATE PROCEDURE upsert_ingredient(
	par_description VARCHAR(40),
	par_price DECIMAL(6,2),
	par_calories INT(6),
	par_stock INT(6)
)
BEGIN
	IF par_description IN (SELECT description FROM ingredient) THEN
		UPDATE ingredient
		SET price=par_price, calories=par_calories, stock=stock+par_stock
		WHERE description=par_description;
	ELSE
		INSERT INTO ingredient
		VALUES (NULL,par_description,par_price,par_calories,par_stock);
	END IF;
END//
DELIMITER ;

-- 2. Prueba con un ingrediente que ya existe.


-- 3. Prueba con un ingrediente nuevo

CALL upsert_ingredient('Coconut oil',7.25,810,2000);

-- 4. Procedimiento que inserta o modifica un ítem.
-- Recibe como parámetros:
-- -- Identificador de la receta
-- -- Identificador del ingrediente
-- -- Cantidad
-- Si el ítem ya existía, se actualiza la cantidad.
-- Si el ítem es nuevo, se inserta una fila con todos los datos.
-- Ojo: la tabla ítem tiene una clave primaria compuesta.

DELIMITER //
DROP PROCEDURE IF EXISTS upsert_item//
CREATE PROCEDURE upsert_item(
	par_recipe_id INT(6),
	par_ingredient_id INT(6),
	par_quantity INT(6)
)
BEGIN
	DECLARE x BOOLEAN;
	SELECT TRUE INTO x
	FROM item
	WHERE recipe_id=par_recipe_id AND ingredient_id=par_ingredient_id;
	IF x THEN
		UPDATE item
		SET quantity=par_quantity
		WHERE recipe_id=par_recipe_id AND ingredient_id=par_ingredient_id;
	ELSE
		INSERT INTO item
		VALUES (par_recipe_id, par_ingredient_id, par_quantity);
	END IF;
END//
DELIMITER ;

-- 5. Prueba con un item que ya existe

CALL upsert_item(1, 5, 40);

-- 6. Prueba con un item nuevo

CALL upsert_item(1, 3, 75);

-- 7. Añadir al procedimiento anterior un parámetro de salida
-- de tipo entero que tomará el siguiente valor:
-- -- 1 si se modifica el item
-- -- 2 si se inserta el item

DELIMITER //
DROP PROCEDURE IF EXISTS upsert_item//
CREATE PROCEDURE upsert_item(
	par_recipe_id INT(6),
	par_ingredient_id INT(6),
	par_quantity INT(6),
	OUT par_out INT(1)
)
BEGIN
	DECLARE x BOOLEAN;
	SELECT TRUE INTO x
	FROM item
	WHERE recipe_id=par_recipe_id AND ingredient_id=par_ingredient_id;
	IF x THEN
		UPDATE item
		SET quantity=par_quantity
		WHERE recipe_id=par_recipe_id AND ingredient_id=par_ingredient_id;
		SET par_out=1;
	ELSE
		INSERT INTO item
		VALUES (par_recipe_id, par_ingredient_id, par_quantity);
		SET par_out=2;
	END IF;
END//
DELIMITER ;

-- 8. Prueba con un item que existe

CALL upsert_item(1, 5, 46, @y);
SELECT @y;

-- 9. Prueba con un item que no existe

CALL upsert_item(1, 25, 30, @y);
SELECT @y;

-- 10. Procedimiento que inserta una nueva comanda.
-- Los parámetros de entrada son dos:
-- -- número de raciones
-- -- identificador de la receta
-- Si hay suficiente stock de ingredientes para la comanda,
-- entonces se inserta la comanda con la fecha del sistema y
-- se actualizan (restando) los stocks de ingredientes.
-- Si no hay suficiente stock entonces no se hace nada.
-- Mediente un parámetro de salida se devuelve un 0 si no hay 
-- suficiente stock y un 1 en caso contrario.

DELIMITER //
DROP PROCEDURE IF EXISTS new_command//
CREATE PROCEDURE new_command(
	par_n INT(6),
	par_recipe_id INT(6),
	OUT par_out INT(1)
)
BEGIN
	IF enough_stock(par_recipe_id,par_n) THEN
		INSERT INTO command
		VALUES (NULL,CURRENT_DATE,par_n,par_recipe_id);
		UPDATE ingredient i1
		SET stock = stock - (
			SELECT quantity*par_n
			FROM item i2
			WHERE i1.ingredient_id=i2.ingredient_id
			AND recipe_id=par_recipe_id
		)
		WHERE ingredient_id IN (
			SELECT ingredient_id
			FROM item
			WHERE recipe_id=par_recipe_id
		);
		SET par_out=1;
	ELSE
		SET par_out=0;
	END IF;
END//
DELIMITER ;

-- 11. Nueva comanda de 100 raciones de paella

CALL new_command(100,5,@x);
SELECT @x;

-- 11. Nueva comanda de 2 raciones de paella

CALL new_command(2,5,@x);
SELECT @x;


