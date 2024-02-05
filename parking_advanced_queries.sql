-- 1. Todos los datos de los vehículos blancos o grises que
-- entraron el día 01-10-2018

SELECT *
FROM vehicle
WHERE color IN ("Blanco","Gris") 
AND vehicle_id IN (
    SELECT vehicle_id
    FROM stay
    WHERE in_date="2018-10-01"
)

-- No sale ninguno porque el campo in_date es DATETIME
-- La función DATE() devuelve la fecha de un DATETIME

SELECT *
FROM vehicle
WHERE color IN ("Blanco","Gris") 
AND vehicle_id IN (
    SELECT vehicle_id
    FROM stay
    WHERE DATE(in_date)="2018-10-01"
)

-- 2. Para cada marca, número de vehículos

SELECT mark, COUNT(*)
FROM vehicle
GROUP BY mark

-- 3. Para cada marca y modelo, número de vehículos

SELECT mark,model, COUNT(*)
FROM vehicle
GROUP BY mark,model

-- 4. Para cada matrícula, número de entradas y número de salidas

SELECT vehicle_id, COUNT(in_date), COUNT(out_date)
FROM stay
GROUP BY vehicle_id

-- 5. La matrícula del vehículo que más veces ha entrado

SELECT vehicle_id, COUNT(in_date)
FROM stay
GROUP BY vehicle_id
HAVING COUNT(in_date) >=ALL(
    SELECT COUNT(in_date)
    FROM stay
    GROUP BY vehicle_id
)

-- 6. Todos los datos de los vehículos que están actualmente estacionados

SELECT *
FROM vehicle
WHERE vehicle_id IN (
    SELECT vehicle_id
    FROM stay  
    WHERE out_date IS NULL
)

-- 7. Para cada día y cada planta, número de entradas y de salidas

SELECT DATE(s.in_date), p.place_floor, COUNT(s.in_date), COUNT(s.out_date)
FROM stay s, place p
WHERE s.place_id=p.place_id
GROUP BY DATE(s.in_date), p.place_floor

-- 8. Todos los datos de las estancias y los precios por día y minuto

SELECT *
FROM stay s, price p
WHERE s.in_date BETWEEN p.from_date AND p.until_date

-- 9. Todos los datos de las estancias junto con su duración en minutos

SELECT *, TIMESTAMPDIFF(MINUTE, in_date, out_date) 
FROM stay

-- 10. Teniendo en cuenta que un día tiene 1440 minutos, calcula
-- el número de días y de minutos de cada estancia
-- La función MOD y el operador % calculan el resto de la división

SELECT *, TIMESTAMPDIFF(MINUTE,in_date,out_date) AS total_min,
TIMESTAMPDIFF(DAY,in_date,out_date) AS num_days,
TIMESTAMPDIFF(MINUTE,in_date,out_date)%1440 AS rest_min
FROM stay

-- 11. Calcula el importe de cada estancia

SELECT s.*,
ROUND(
TIMESTAMPDIFF(DAY,in_date,out_date)*price_day +
TIMESTAMPDIFF(MINUTE,in_date,out_date)%1440*price_minute ,2) AS import
FROM stay s, price p
WHERE s.in_date BETWEEN p.from_date AND p.until_date

-- La función IF tiene tres parámetros:
-- la condición que se va a evaluar
-- el valor devuelto si la condición es verdadera
-- el valor devuelto si la condición es falsa

-- 12. Para cada estancia, calcula la columna 'Duration' con el siguiente valor:
-- "long" en estancias de más de 100 minutos
-- "short" en estancias menores o iguales a 100 minutos

SELECT *, IF(TIMESTAMPDIFF(MINUTE,in_date,out_date)>100,"short","long")
FROM stay

-- 13. Repite la consulta anterior pero con el valor "medium" para estancias
-- comprendidas entre 80 y 100 minutos

SELECT *,
IF (TIMESTAMPDIFF(MINUTE,in_date,out_date)>100,"Long",IF(TIMESTAMPDIFF(MINUTE,in_date,out_date)>=80,"Medium", "Short"))
FROM stay

-- 14. Repite la consulta anterior usando sólo el operador < (less than)

SELECT *,
IF(TIMESTAMPDIFF(MINUTE,in_date,out_date)<80,"Short",IF(TIMESTAMPDIFF(MINUTE,in_date,out_date<101,"Medium", "Long")))
FROM stay

-- 15. Todos los datos de la tabla vehículos junto con una columna
-- que muestre si el vehículo es alemán o del resto del mundo

SELECT *, IF(mark="Mercedes" OR mark="Opel", "German", "Rest of the world")
FROM vehicle

-- Con IN 
SELECT *, IF(mark IN("Mercedes","Opel"), "German", "Rest of the world")
FROM vehicle

-- 16. Recalcula el importe de las estancias teniendo en cuenta que
-- no se puede cobrar por minutos más que el precio de un día

SELECT s.*,
ROUND(
TIMESTAMPDIFF(DAY,in_date,out_date)*price_day +
IF (
TIMESTAMPDIFF(MINUTE,in_date,out_date)%1440*price_minute > price_day,price_day,TIMESTAMPDIFF(MINUTE,in_date,out_date)%1440*price_minute),2)
FROM stay s, price p
WHERE s.in_date BETWEEN p.from_date and p.until_date

-- 17. Vehículos para los que no hay ninguna estancia

SELECT *
FROM vehicle
WHERE vehicle_id NOT IN (
    SELECT vehicle_id
    FROM stay
)

-- 18. Para cada vehículo, número de estancias
-- Que aparezcan todos los vehículos

SELECT v.*, COUNT(s.vehicle_id)
FROM vehicle v LEFT JOIN stay s
ON v.vehicle_id=s.vehicle_id
GROUP BY v.vehicle_id, v.mark, v.model, v.color

-- 19. Para cada plaza, número de estancias
-- Que aparezcan todas las plazas

SELECT p.*, COUNT(s.place_id)
FROM place p LEFT JOIN stay s
ON p.place_id=s.place_id
GROUP BY p.place_id, p.place_floor

-- 20. Tiempo en minutos que estuvo ocupada cada plaza

SELECT place_id, SUM(TIMESTAMPDIFF(MINUTE, in_date, out_date)) AS tiempo_estancias
FROM stay
GROUP BY place_id

-- Para sustituir valores nulos por otra cosa,
-- se utiliza la función IFNULL, que tiene dos parámetros:
--   * la expresión que se evalúa
--   * el valor devuelto si la expresión es nula
-- En caso de que la expresión no sea nula, devuelve la expresión

-- 21. Para cada estancia, su duración en minutos suponiendo que 
-- que ahora son las 18:00 del 4 de noviembre de 2018

SELECT TIMESTAMPDIFF(MINUTE, in_date,IFNULL (out_date, "2018-11-04 18:00"))
FROM stay

-- 22. Minutos de ocupación el día 3 de octubre de 2018

SELECT *,TIMESTAMPDIFF(MINUTE,
IF(in_date<"2018-10-03","2018-10-03", in_date), 
IF(out_date>="2018-10-04","2018-10-04", out_date)) AS min_ocupación
FROM stay
WHERE in_date<"2018-10-04" AND out_date>="2018-10-03"

-- 23. Suma de minutos de ocupación el día 3 de octubre de 2018

SELECT SUM(TIMESTAMPDIFF(MINUTE,
IF(in_date<"2018-10-03","2018-10-03", in_date), 
IF(out_date>="2018-10-04","2018-10-04", out_date)))
FROM stay
WHERE in_date<"2018-10-04" AND out_date>="2018-10-03"

-- 24. Porcentaje de ocupación el día 3 de octubre de 2018

SELECT SUM(TIMESTAMPDIFF(MINUTE,
IF(in_date<"2018-10-03","2018-10-03", in_date), 
IF(out_date>="2018-10-04","2018-10-04", out_date)))/ (8*1440)*100
FROM stay
WHERE in_date<"2018-10-04" AND out_date>="2018-10-03"

-- Vamos a obtener el número de plazas (8) mediante una subconsulta

SELECT SUM(TIMESTAMPDIFF(MINUTE,
IF(in_date<"2018-10-03","2018-10-03", in_date), 
IF(out_date>="2018-10-04","2018-10-04", out_date)))/ ((
SELECT COUNT(*)
FROM place
)*1440)*100
FROM stay
WHERE in_date<"2018-10-04" AND out_date>="2018-10-03"

-- 25. En la consulta anterior, el número de plazas es 8
-- Podemos obtener este valor mediante una consulta
-- y guardarlo en una variable para su uso posterior
-- PARA GUARDAR UN VALOR @ LO QUE SEA:=

SELECT @x:=COUNT(*)
FROM place;

SELECT SUM(TIMESTAMPDIFF(MINUTE,
IF(in_date<"2018-10-03","2018-10-03", in_date), 
IF(out_date>="2018-10-04","2018-10-04", out_date)))/ (@x*1440)*100
FROM stay
WHERE in_date<"2018-10-04" AND out_date>="2018-10-03";

-- 26. Para cada marca con más de 4 vehículos, número de vehículos

SELECT mark, COUNT(*)
FROM vehicle
GROUP BY mark
HAVING COUNT(*) > 4

-- 27. Estado actual de las todas las plazas de aparcamiento
-- Para cada plaza, matrícula del vehículo que la ocupa
-- Si la plaza está vacía, que aparezca la palabra "empty"

SELECT *, IF(out_date IS NULL, vehicle_id,"Empty")
FROM place p LEFT JOIN stay s1
ON p.place_id=s1.place_id
HAVING in_date >=ALL(
    SELECT in_date
    FROM stay s2
    WHERE s1.place_id=s2.place_id
)

-- 28. Plazas en las que haya estacionado alguna vez un Opel Astra.

SELECT DISTINCT place_id
FROM stay
WHERE vehicle_id IN (
    SELECT vehicle_id
    FROM vehicle
    WHERE mark="Opel" AND model="Astra"
)

-- 29. Vehículos que nunca hayan estacionado en la primera planta.

SELECT *
FROM vehicle
WHERE vehicle_id NOT IN (
    SELECT vehicle_id
    FROM stay
    WHERE place_id IN (
        SELECT place_id
        FROM place
        WHERE place_floor=1
    )
)

-- 30. Estancias más cortas que la media. Supongamos que hoy es 10/10/2018

SELECT *, TIMESTAMPDIFF(MINUTE, in_date, IFNULL(out_date,"2018-10-10"))
FROM stay
WHERE TIMESTAMPDIFF(MINUTE, in_date, out_date)<(
    SELECT AVG(TIMESTAMPDIFF(MINUTE, in_date, out_date))
    FROM stay
)

-- 31. Vehículo con mayor número de minutos.

SELECT vehicle_id, SUM(TIMESTAMPDIFF(MINUTE, in_date, IFNULL(out_date,"2018-10-10")))
FROM stay
GROUP BY vehicle_id
HAVING SUM(TIMESTAMPDIFF(MINUTE, in_date, IFNULL(out_date,"2018-10-10")))>=ALL(
    SELECT SUM(TIMESTAMPDIFF(MINUTE, in_date, IFNULL(out_date,"2018-10-10")))
    FROM stay
    GROUP BY vehicle_id
)

-- 32. Día con mayor número de entradas.

SELECT DATE(in_date), COUNT(*)
FROM stay
GROUP BY DATE(in_date)
HAVING COUNT(*)>=ALL(
    SELECT COUNT(*)
    FROM stay
    GROUP BY DATE(in_date)
)

-- 33. Las estancias 9 y 24 son del mismo vehículo. Minutos que estuvo fuera.
-- Solución con variables

SELECT @x:=out_date
FROM stay
WHERE stay_id=9;

SELECT @y:=in_date
FROM stay
WHERE stay_id=24;

SELECT TIMESTAMPDIFF(MINUTE, @x, @y);

-- 34. Lo mismo pero con subconsultas
SELECT TIMESTAMPDIFF(MINUTE,
(
    SELECT out_date
    FROM stay
    WHERE stay_id=9
),(
    SELECT in_date
    FROM stay
    WHERE stay_id=24
));



-- 35. Incremento de precio del día desde el 01/02/2017 hasta 01/02/2018.

--Solucion con variables
SELECT @p1:= price_day
FROM price
WHERE "2017-02-01" BETWEEN from_date AND until_date;
SELECT @p2:= price_day
FROM price
WHERE "2018-02-01" BETWEEN from_date AND until_date;

SELECT (@p2 - @p1) / @p1 * 100;

--Solucion con subconsultas

SELECT (
    (
    SELECT price_day
    FROM price
    WHERE "2018-02-01" BETWEEN from_date AND until_date)
    -
    (
    SELECT price_day
    FROM price
    WHERE "2017-02-01" BETWEEN from_date AND until_date)) 
    / 
    (
    SELECT price_day
    FROM price
    WHERE "2017-02-01" BETWEEN from_date AND until_date
    )
     * 100 AS Subida_precio;
-- 36. Facturación diaria (suma de importes cobrados a la salida).

SELECT DATE(s.out_date), COUNT(*) AS num_outs,
 SUM(ROUND(
    TIMESTAMPDIFF(DAY,s.in_date,s.out_date)*p.price_day +
    TIMESTAMPDIFF(MINUTE,s.in_date,s.out_date)%1440*p.price_minute ,2)) AS import
    FROM stay s, price p
    WHERE s.in_date BETWEEN p.from_date AND p.until_date AND out_date IS NOT NULL    
    GROUP BY DATE (s.out_date)

-- 37. El vehículo '0987-BSR' aparca en la primera plaza libre

SELECT @x:=MAX(stay_id)+1
FROM stay;

SELECT @y:=MIN(place_id)
FROM place
WHERE place_id NOT IN (
    SELECT place_id
    FROM stay
    WHERE out_date IS NULL
);
INSERT INTO stay VALUES
(@x, CURRENT_TIMESTAMP, NULL, "0987-BSR",@y)

-- 38. Los precios suben a partir de hoy un 2.5%
-- 1º Modificar el último registro de precios
-- 2º Insertar un nuevo registro de precios
SELECT @cur_day_price:=price_day, @cur_minute_price:=price_minute
FROM price
WHERE until_date IS NULL;

UPDATE price
SET until_date=CURRENT_DATE-1
WHERE until_date IS NULL;

SELECT @x:= MAX(price_id)+1
FROM price;

SELECT @y:= @cur_day_price*102.5/100;

SELECT @z:= @cur_minute_price*102.5/100;

INSERT INTO price VALUES
(@x,CURRENT_DATE,NULL,@y,@z);

-- 39. Modificar la horas de entrada, incrementándolas en 5 minutos
-- para el vehículo '0987-BSR'

UPDATE stay
SET in_date=ADDTIME(in_date,300);
WHERE vehicle_id="0987-BSR"



-------------------
-- Transacciones --
-------------------

-- 40. Ver el valor de la variable del sistema AUTOCOMMIT

SELECT @@AUTOCOMMIT


-- DML (Data Manipulation Language) son las instrucciones de SQL
-- que sirven para insertar, modificar y borrar datos de las tablas
-- El valor 1 (verdadero) indica que cada orden DML (INSERT, UPDATE y DELETE) se confirma
-- automáticamente y no se puede volver atrás

-- 41. Poner AUTOCOMMIT a falso para que las transacciones no se 
-- confirmen hasta que ejecutemos la orden COMMIT

SET AUTOCOMMIT=FALSE

-- La orden START TRANSACTION inicia la transacción y establece
-- un punto al que volver en caso de hacer ROLLBACK

-- 42. Inicio de la transacción

START TRANSACTION

-- 43. Me olvido de poner el WHERE en el DELETE FROM

DELETE FROM stay

-- 44. Volvemos hasta el inicio de la transacción deshaciendo cambios

ROLLBACK

-- 45. Para terminar la transacción confirmando los cambios

COMMIT

-- 46. Crear una vista llamada stay_plus donde aparezcan todos los campos de la
-- tabla stay junto con dos campos nuevos: los días y los minutos de duración

--Para borrar una vista usamos la función DROP 
--Con la clausula IF EXISTS revisa si la vista existe y si existe realiza la funcion definida.

CREATE VIEW stay_plus AS
SELECT *, TIMESTAMPDIFF(DAY,in_date,out_date) AS días_stay, TIMESTAMPDIFF(MINUTE,in_date,out_date) AS min_stay
FROM stay

-- 47. Usa la vista anterior para simplificar la consulta 16

SELECT s.*,
ROUND(
días_stay*price_day +
IF (
min_stay%1440*price_minute > price_day,price_day,min_stay%1440*price_minute),2)
FROM stay_plus s, price p
WHERE s.in_date BETWEEN p.from_date and p.until_date

-- 48. Crea una vista llamada stay_plus_plus con todos los campos de la vista stay_plus más un campo nuevo: el importe de la estancia

CREATE VIEW stay_plus_plus AS
SELECT s.*, ROUND(
días_stay*price_day +
IF (
min_stay%1440*price_minute > price_day,price_day,min_stay%1440*price_minute),2) AS import
FROM stay_plus s, price p
WHERE s.in_date BETWEEN p.from_date and p.until_date

--49. Usando la vista stay stay_plus_plus, para cada vehiculo, numero de entradas, suma de minutos y suma de importe

SELECT vehicle_id, COUNT(*), SUM(min_stay), SUM(import)
FROM stay_plus_plus
GROUP BY vehicle_id

--50. De la consulta anterior, obtener el vehiculo con el maximo importe

SELECT vehicle_id, COUNT(*), SUM(min_stay), SUM(import)
FROM stay_plus_plus
WHERE out_date IS NOT NULL
GROUP BY vehicle_id
HAVING SUM(import) >= ALL (
    SELECT SUM(import)
    FROM stay_plus_plus
    WHERE out_date IS NOT NULL
    GROUP BY vehicle_id
)


--51. Para cada precio, numero de dias que estuvo vigente y numero de minutos a partir de los cuales se cobra el dia entero
SELECT *, 
TIMESTAMPDIFF(DAY,from_date,IFNULL(until_date,CURRENT_DATE)) AS vigencia, ROUND(price_day /price_minute,0) AS tiempo
FROM price

-- 1. Para cada receta (que salgan todas), todos sus datos 
-- junto con el número de menús y la suma de personas (sin valores nulos).

SELECT r.*, COUNT(c.command_id), IFNULL(SUM(c.rations),0)
FROM recipe r LEFT JOIN command c ON r.recipe_id=c.recipe_id
GROUP BY r.recipe_id, r.description, r.diff_level


-- 2. Descripción de los ingredientes de la paella, junto con su cantidad,
-- precio e importe en euros. 
-- Ojo que la cantidad está en gramos y el precio en euros por kilo.

SELECT i.description, i.ingredient_id,i.price, i.price*it.quantity/1000 AS precio
FROM ingredient i, item it
WHERE i.ingredient_id=it.ingredient_id AND it.recipe_id =(
    SELECT recipe_id
    FROM recipe
    WHERE description="Paella"
)
GROUP BY i.ingredient_id, i.description, i.price



-- 3. Suma de calorías de una ración de gazpacho. Ojo que la cantidad
-- está en gramos y las calorías son por cada 100 gramos.

SELECT SUM(i.calories*it.quantity)/100
FROM item it, ingredient i
WHERE i.ingredient_id=it.ingredient_id
AND recipe_id = (
    SELECT recipe_id
    FROM recipe
    WHERE description="Gazpacho"
)

-- 4. Para cada año, el identificador de la receta que más se repite.
-- Tienes los datos en la tabla menús.

SELECT YEAR(command_date), recipe_id, COUNT(recipe_id)
FROM command
GROUP BY YEAR(command_date), recipe_id
HAVING COUNT(recipe_id) >= ALL (
    SELECT COUNT(recipe_id)
    FROM command
    GROUP BY YEAR(command_date), recipe_id
)


-- 5. Identificadores de ingredientes que aparecen en más 
-- del 75% de las recetas

-- Con variables
