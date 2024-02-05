-- Rutinas almacenadas en la Base de Datos 
-- Se escriben en un lenguaje llamado PL-SQL
-- Procedimental Language Structured Query Language
-- En PLSQL se programan tres tipos de objetos o rutinas:
-- -- Funciones: Tienen una lista de argumentos de entrada (parámetros)
-- -- y devuelven un valor. Son de sólo lectura (readonly).
-- -- Procedimientos: Tienen una lista de argumentos de entrada
-- -- y de salida y no devuelven ningún valor. No son readonly,
-- -- sino que modifican los datos mediante INSERT, DELETE, UPDATE.
-- -- Disparadores: No tienen lista de argumentos, no devuelven
-- -- ningún valor y se disparan automáticamente cuando se
-- -- ejecuta alguna operación DML (INSERT, DELETE, UPDATE)

-- 1. Función que recibe como argumento el identificador 
-- de una receta y devuelve el número de ingredientes

DELIMITER //
DROP FUNCTION IF EXISTS count_ingreds//
CREATE FUNCTION count_ingreds(par_recipe_id INT)
RETURNS INT
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM item
		WHERE recipe_id=par_recipe_id
	);
END//
DELIMITER ;

-- 2. Para cada receta, todos sus datos y número de ingredientes

SELECT *, count_ingreds(recipe_id)
FROM recipe;

-- Sin usar la función sería

SELECT r.*, COUNT(i.recipe_id)
FROM recipe r LEFT JOIN item i
ON r.recipe_id=i.recipe_id
GROUP BY r.recipe_id, r.description, r.diff_level;

-- 3. Número de ingredientes de la receta 5

SELECT count_ingreds(5);

-- 4. Todos los datos de la receta con más ingredientes

SELECT *, count_ingreds(recipe_id)
FROM recipe
WHERE count_ingreds(recipe_id) >= ALL(
	SELECT count_ingreds(recipe_id)
	FROM recipe
);

-- 5. Función que recibe como parámetro el identificador de
-- una receta y devuelve la suma de sus calorías por ración

DELIMITER //
DROP FUNCTION IF EXISTS sum_calories//
CREATE FUNCTION sum_calories(par_recipe_id INT)
RETURNS INT
BEGIN
	RETURN (
		SELECT SUM(i.calories/100*it.quantity)
		FROM ingredient i, item it
		WHERE i.ingredient_id=it.ingredient_id
		AND it.recipe_id=par_recipe_id
	);
END//
DELIMITER ;

-- 6. Para cada receta, todos sus datos y suma de calorías

SELECT *, sum_calories(recipe_id)
FROM recipe;

-- 7. La receta más ligera

SELECT *, sum_calories(recipe_id)
FROM recipe
WHERE sum_calories(recipe_id) = (
	SELECT MIN(sum_calories(recipe_id))
	FROM recipe
);

-- Usando ALL

SELECT *, sum_calories(recipe_id)
FROM recipe
WHERE sum_calories(recipe_id) <= ALL (
	SELECT sum_calories(recipe_id)
	FROM recipe
	WHERE sum_calories(recipe_id) IS NOT NULL
);

-- 8. Función booleana que devuelve verdadero si un ingrediente
-- se ha usado en una fecha determinada. Recibe dos parámetros:
-- -- Identificador del ingrediente
-- -- Fecha

DELIMITER //
DROP FUNCTION IF EXISTS used//
CREATE FUNCTION used(par_ingredient_id INT, par_date DATE)
RETURNS BOOLEAN
BEGIN
	RETURN (
		SELECT par_date IN (
			SELECT command_date
			FROM command
			WHERE recipe_id IN (
				SELECT recipe_id
				FROM item
				WHERE ingredient_id=par_ingredient_id
			)
		)
	);
END//
DELIMITER ;

-- 9. Probar la función anterior para saber si se usó bacon (20) el
-- día 6 de abril de 2021.

SELECT used(20,'2021-04-06');

-- 10. Función booleana que devuelve verdadero si existe suficiente 
-- stock de ingredientes para una receta. Recibe dos parámetros:
-- -- Identificador de la receta
-- -- Número de raciones

DELIMITER //
DROP FUNCTION IF EXISTS enough_stock//
CREATE FUNCTION enough_stock(par_recipe_id INT, par_n INT)
RETURNS BOOLEAN
BEGIN
	RETURN 1 = ALL (
		SELECT i.stock >= it.quantity*par_n
		FROM ingredient i, item it
		WHERE i.ingredient_id=it.ingredient_id
		AND recipe_id=par_recipe_id
	);
END//
DELIMITER ;

-- 11. Probar la función para saber si hay stock para 45 raciones
-- de Grilled tuna (2)

SELECT i.stock >= it.quantity*45
FROM ingredient i, item it
WHERE i.ingredient_id=it.ingredient_id
AND recipe_id=2;

-- usando la función

SELECT enough_stock(2,45);

-- 12. ¿De qué recetas tenemos stock suficiente para 20 raciones?

SELECT *
FROM recipe
WHERE enough_stock(recipe_id,20);

-- 13. Función que devuelve la clasificación energética de la receta
-- cuyo identificador se pasa como parámetro, según la siguiente tabla:
-- -- hasta 300 calorías 'Low'
-- -- más de 300 y hasta 500 'Medium'
-- -- más de 500 y hasta 700 'High'
-- -- más de 700 'Very high'

DELIMITER //
DROP FUNCTION IF EXISTS energy_class//
CREATE FUNCTION energy_class(par_recipe_id INT)
RETURNS VARCHAR(10)
BEGIN
	RETURN 
		IF(sum_calories(par_recipe_id)<=300,'Low',
			IF(sum_calories(par_recipe_id)<=500,'Medium',
				IF(sum_calories(par_recipe_id)<=700,'High','Very high')
			)
		);
END//
DELIMITER ;

-- Usando una variable para guardar la suma de calorías

DELIMITER //
DROP FUNCTION IF EXISTS energy_class//
CREATE FUNCTION energy_class(par_recipe_id INT)
RETURNS VARCHAR(10)
BEGIN
	DECLARE x INT;
	SET x=sum_calories(par_recipe_id);
	RETURN 
		IF(x<=300,'Low',
			IF(x<=500,'Medium',
				IF(x<=700,'High','Very high')
			)
		);
END//
DELIMITER ;

-- Usando la sentencia IF-THEN-ELSE en lugar de la función IF

DELIMITER //
DROP FUNCTION IF EXISTS energy_class//
CREATE FUNCTION energy_class(par_recipe_id INT)
RETURNS VARCHAR(10)
BEGIN
	DECLARE x INT;
	SET x=sum_calories(par_recipe_id);
	IF x<=300 THEN
		RETURN 'Low';
	ELSE
		IF x<=500 THEN
			RETURN 'Medium';
		ELSE
			IF x<=700 THEN
				RETURN 'High';
			ELSE
				RETURN 'Very high';
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

-- 14. Probar la función anterior para visulizar la clasificación
-- energética del desayuno inglés (3)

SELECT sum_calories(3), energy_class(3);

-- 15. Clasificación energética de todas las recetas

SELECT *, energy_class(recipe_id)
FROM recipe;

-- 16. Función que devuelve verdadero si con cierta cantidad euros
-- tenemos suficiente dinero para un número de raciones de una receta.
-- Recibe como parámetros:
-- -- Cantidad de euros
-- -- Identificador de la receta
-- -- Número de raciones

DELIMITER //
DROP FUNCTION IF EXISTS enough_money//
CREATE FUNCTION enough_money(par_money FLOAT, par_recipe_id INT, par_n INT)
RETURNS BOOLEAN
BEGIN
	RETURN par_money >= (
		SELECT SUM(quantity/1000*price)*par_n
		FROM ingredient i, item it
		WHERE i.ingredient_id=it.ingredient_id
		AND it.recipe_id=par_recipe_id
	);
END//
DELIMITER ;

-- 17. Para todas las recetas, comprobueba qué devuelve la función
-- con 10 euros y 9 raciones

SELECT *, enough_money(10,recipe_id,9)
FROM recipe;
 
-- 18. Función que devuelve el coste de una ración de una receta que
-- se pasa como parámetro

DELIMITER //
DROP FUNCTION IF EXISTS cost//
CREATE FUNCTION cost(par_recipe_id INT)
RETURNS FLOAT
BEGIN
	RETURN (
		SELECT ROUND(SUM(quantity/1000*price),2)
		FROM ingredient i, item it
		WHERE i.ingredient_id=it.ingredient_id
		AND it.recipe_id=par_recipe_id
	);
END//
DELIMITER ;

-- 19. El coste de todas las recetas

SELECT *, cost(recipe_id)
FROM recipe;

-- 20. Utiliza la función del ejercicio 18 para simplificar la función
-- del ejercicio 16

DELIMITER //
DROP FUNCTION IF EXISTS enough_money//
CREATE FUNCTION enough_money(par_money FLOAT, par_recipe_id INT, par_n INT)
RETURNS BOOLEAN
BEGIN
	RETURN par_money >= cost(par_recipe_id)*par_n;
END//
DELIMITER ;
