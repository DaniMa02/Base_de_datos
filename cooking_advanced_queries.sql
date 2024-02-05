-- 1. Todos los datos de los comandas de mayo de 2021

SELECT *
FROM command
WHERE command_date BETWEEN "2021-05-01" AND "2021-05-31"

-- 2. Agrupar los comandas por año, contar filas y sumar personas

SELECT YEAR(command_date), COUNT(*) AS filas, SUM(rations) AS raciones
FROM command
GROUP BY YEAR(command_date)

-- 3. De la consulta anterior, obtener el año con más personas

SELECT YEAR(command_date), COUNT(*) AS filas, SUM(rations) AS raciones
FROM command
GROUP BY YEAR(command_date)
HAVING SUM(rations) >= ALL (
    SELECT SUM(rations)
    FROM command
    GROUP BY YEAR(command_date)
)

-- 4. Agrupar los comandas por año y mes, contar filas y sumar personas

SELECT YEAR(command_date), MONTH(command_date), COUNT(*) AS filas, SUM(rations) AS raciones
FROM command
GROUP BY YEAR(command_date), MONTH(command_date)
-- 5. Left join de ítems y recetas

SELECT *
FROM recipe r LEFT JOIN item i
ON r.recipe_id=i.recipe_id

-- 6. Todos los datos de los ingredientes de la paella

SELECT *
FROM ingredient
WHERE ingredient_id IN (
    SELECT ingredient_id
    FROM item
    WHERE recipe_id = (
        SELECT recipe_id
        FROM recipe
        WHERE description="Paella"
    )
)

-- 7. Todos los datos de las recetas donde el tomate es ingrediente

SELECT *
FROM recipe
WHERE recipe_id IN (
    SELECT recipe_id
    FROM item
    WHERE ingredient_id IN (
        SELECT ingredient_id
        FROM ingredient
        WHERE description ="Tomato"
    )
)
-- 8. Precio de unos Spaguetti carbonara para cuatro personas

SELECT SUM(i.price*it.quantity/1000)*4 AS precio
FROM ingredient i, item it
WHERE i.ingredient_id=it.ingredient_id
AND it.recipe_id = (
    SELECT recipe_id
    FROM recipe
    WHERE description="Spaghetti carbonara"
)

-- 9. Añadir 75 gramos de nata por persona a los Spaquetti a
-- la carbonara

INSERT INTO ingredient(description,price) VALUES
("cream",0.75);

SELECT @x:=recipe_id
FROM recipe
WHERE description="Spaghetti carbonara";

SELECT @y:= ingredient_id
FROM ingredient
WHERE description="cream";

INSERT INTO item VALUES
(@x,@y,75);

 

-- 10. Ingredientes con más calorías que las patatas

SELECT *
FROM ingredient
WHERE calories > ALL (
    SELECT calories
    FROM ingredient
    WHERE description="Potato"
)

-- 11. Calorías de una ración de desayuno inglés

SELECT SUM(calories)
FROM ingredient
WHERE ingredient_id IN (
    SELECT ingredient_id
    FROM item
    WHERE recipe_id = (
        SELECT recipe_id
        FROM recipe
        WHERE description="english breakfast"
    )
)

-- 12. Precio del comanda con identificador 1

SELECT ROUND(SUM(i.price*it.quantity/1000),2)*c.rations AS price
FROM item it, ingredient i, recipe r, command c
WHERE i.ingredient_id=it.ingredient_id AND it.recipe_id=r.recipe_id AND r.recipe_id=c.recipe_id
AND c.command_id=1

-- 13. Agrupar los ítems por identificador del ingrediente y contar

SELECT ingredient_id, COUNT(*)
FROM item
GROUP BY ingredient_id

-- 14. Añadir a lo anterior todos los datos del ingrediente


SELECT i.*, COUNT(*)
FROM item it, ingredient i
WHERE i.ingredient_id=it.ingredient_id
GROUP BY i.ingredient_id, i.description,i.price,i.calories,i.stock



-- 15. Agrupar los ítems por el identificador de la receta y contar

SELECT recipe_id, COUNT(*)
FROM item
GROUP BY recipe_id

-- 16. Añadir a lo anterior todos los datos de la receta

SELECT r.*, COUNT(*)
FROM item it, recipe r
WHERE it.recipe_id=r.recipe_id
GROUP BY r.recipe_id, r.description, r.diff_level

-- 17. Para cada identificador de receta, su precio por ración

SELECT it.recipe_id, SUM(it.quantity*i.price/1000) AS precio
FROM item it, ingredient i
WHERE it.ingredient_id=i.ingredient_id
GROUP BY it.recipe_id

-- 18. Añadir a lo anterior todos los datos de la receta

SELECT r.*, SUM(it.quantity*i.price/1000) AS precio
FROM item it, ingredient i, recipe r
WHERE it.ingredient_id=i.ingredient_id AND r.recipe_id=it.recipe_id
GROUP BY r.recipe_id, r.description, r.diff_level



-- 19. Para cada comanda, todos sus datos junto con precio y calorías

SELECT c.*, SUM(it.quantity*i.price/1000)*c.rations AS precio, SUM(it.quantity*i.calories/100)*c.rations AS calories
FROM command c, recipe r, item it, ingredient i
WHERE c.recipe_id=r.recipe_id AND r.recipe_id=it.recipe_id AND it.ingredient_id=i.ingredient_id
GROUP BY c.command_id

-- 20. Suma de kilos de arroz cocinados en el año 2021

    SELECT SUM(it.quantity*c.rations)
    FROM item it, recipe r, command c
    WHERE it.recipe_id=r.recipe_id AND r.recipe_id=c.recipe_id 
    AND
     ingredient_id = (
        SELECT ingredient_id
        FROM ingredient
        WHERE description="Rice" )
        AND YEAR(command_date)=2021
        




-- 21. Promedio de calorías de los comandas de 2021

    SELECT AVG(it.quantity*i.calories/100*c.rations)
    FROM item it, recipe r, command c, ingredient i
    WHERE it.recipe_id=r.recipe_id AND r.recipe_id=c.recipe_id AND i.ingredient_id=it.ingredient_id
        AND YEAR(command_date)=2021



-- 22. Para cada ingrediente, todos sus datos y número
-- de recetas donde se usa

SELECT i.*, COUNT(DISTINCT(r.recipe_id))
FROM recipe r LEFT JOIN item i 
ON r.recipe_id=i.recipe_id 
GROUP BY ingredient_id

-- 23. Contar las filas y calcular la media de número de
-- personas en la tabla comanda

SELECT COUNT(*),AVG(rations)
FROM command

-- 24. Lo mismo de antes, pero agrupando por mes y año

SELECT COUNT(*),AVG(rations)
FROM command
GROUP BY YEAR(command_date), MONTH(command_date)

-- 25. Todos los datos de la receta más barata

SELECT it.recipe_id, SUM(it.quantity*i.price/1000) AS precio
FROM item it, ingredient i
WHERE it.ingredient_id=i.ingredient_id
GROUP BY it.recipe_id
HAVING SUM(it.quantity*i.price/1000) <= ALL (
    SELECT SUM(it.quantity*i.price/1000)
    FROM item it, ingredient i
    WHERE it.ingredient_id=i.ingredient_id
    GROUP BY it.recipe_id
)


-- 26. Identificadores de ingredientes que están tanto en
-- la receta 7 como en la 8

SELECT ingredient_id
FROM item
WHERE ingredient_id IN (
    SELECT ingredient_id
    FROM item
    WHERE recipe_id=7
) AND ingredient_id IN (
    SELECT ingredient_id
    FROM item
    WHERE recipe_id=8
)
GROUP BY ingredient_id

-- 27. Identificadores de ingredientes que están tanto en 
-- la Paella como en el Gazpacho

SELECT ingredient_id
FROM item
WHERE ingredient_id = (
    SELECT ingredient_id
    FROM ingredient
    WHERE description="Gazpacho"
) AND ingredient_id = (
    SELECT ingredient_id
    FROM ingredient
    WHERE description="Paella"
)


-- 28. Porcentaje de tomate en el gazpacho









