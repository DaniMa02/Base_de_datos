-- 1. Piezas musicales de compositores vivos

SELECT *
FROM pieces
WHERE composer_id IN (
    SELECT composer_id
    FROM composers
    WHERE dead_date IS NULL
)

-- 2. Identificadores de conciertos donde se tocaron piezas
-- de compositores vivos

SELECT DISTINCT concert_id
FROM con_pie
WHERE piece_id IN (
    SELECT piece_id
    FROM pieces
    WHERE composer_id IN (
        SELECT composer_id
        FROM composers
        WHERE dead_date IS NULL
    )
)
ORDER BY 1;

-- 3. Para cada intérprete (que salgan todos), todos sus datos
-- y número de conciertos en los que ha participado

SELECT p.*, COUNT(*)
FROM performers p, con_per cp
WHERE p.performer_id=cp.performer_id
GROUP BY p.performer_id, p.name, p.birth_date

-- La consulta anterior puede expresarse con otra sintaxis usando 
-- la clausula JOIN ON 

SELECT p.*, COUNT(*)
FROM performers p JOIN con_per cp
ON p.performer_id=cp.performer_id
GROUP BY p.performer_id, p.name, p.birth_date

-- LEFT JOIN ES UN EQUIJOIN DONDE APARECEN TODAS LAS FILAS DE LA TABLA PADRE
-- INCLUSO AQUELLAS QUE NO SE EMPAREJAN CON FILAS EN LA TABLA HIJA

SELECT p.*, COUNT(cp.concert_id)
FROM performers p LEFT JOIN con_per cp
ON p.performer_id=cp.performer_id
GROUP BY p.performer_id, p.name, p.birth_date

-- 4. Conciertos en los que se interpretó alguna pieza de Mozart

SELECT DISTINCT concert_id
FROM con_pie
WHERE piece_id IN (
    SELECT piece_id
    FROM pieces
    WHERE composer_id = (
        SELECT composer_id
        FROM composers
        WHERE name LIKE "%Mozart%"
    ))
    ORDER BY 1;

-- 5. Conciertos en los que no se interpretó ninguna pieza de Mozart
SELECT *
FROM concerts
WHERE concert_id NOT IN (
    SELECT concert_id
    FROM con_pie
    WHERE piece_id IN (
        SELECT piece_id
        FROM pieces
        WHERE composer_id = (
            SELECT composer_id
            FROM composers
            WHERE name LIKE "%Mozart%"
        )))
        ORDER BY 1;

-- La funcion TIMESTAMPDIFF(unit, timestamp1, timestamp2)
-- resta dos marcas de tiempo y devulve el resultado en las unidades 
-- que indica el primer parámetro. (YEAR,MONTH,DAY, HOUR, MINUTE, SECONDS)

-- 6. Edad media actual de los compositores vivos

SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR,birth_date, "2023-01-30")),0) AS age
FROM composers
WHERE dead_date IS NULL
-- 7. Para cada concierto y cada instrumento, número de músicos

SELECT concert_id, instrument
FROM con_per
GROUP BY concert_id, instrument, COUNT(*)
-- 8. El compositor que vivió más años

SELECT *, TIMESTAMPDIFF(YEAR,birth_date, dead_date) as AGE
FROM composers
WHERE dead_date IS NOT NULL 
AND TIMESTAMPDIFF(YEAR,birth_date, dead_date) = (
    SELECT MAX(TIMESTAMPDIFF(YEAR,birth_date, dead_date))
    FROM composers
    WHERE dead_date IS NOT NULL
)

--
SELECT *, TIMESTAMPDIFF(YEAR,birth_date, dead_date) as AGE
FROM composers
WHERE dead_date IS NOT NULL 
AND TIMESTAMPDIFF(YEAR,birth_date, dead_date) >= ALL (
    SELECT TIMESTAMPDIFF(YEAR,birth_date, dead_date)
    FROM composers
    WHERE dead_date IS NOT NULL
)


-- 9. El concierto más reciente

SELECT *
FROM concerts
WHERE concert_date >= ALL (
    SELECT concert_date
    FROM concerts
)
--
SELECT *
FROM concerts
WHERE concert_date = (
    SELECT MAX(concert_date)
    FROM concerts
)

-- 10. Músicos que nunca han tocado el violín

SELECT *
FROM performers
WHERE performer_id NOT IN (
    SELECT performer_id
    FROM con_per
    WHERE instrument = "Violin"

)


-- 11. Identificadores de conciertos de Margaret
SELECT concert_id
FROM con_per
WHERE performer_id = (
    SELECT performer_id
    FROM performers
    WHERE name LIKE "%Margaret%"
)

-- 12. Conciertos en los que Margaret y Dolgopolov han coincidido

FROM concerts
WHERE concert_id IN (
    SELECT concert_id
    FROM con_per
    WHERE performer_id = (
         SELECT performer_id
         FROM performers
         WHERE name LIKE "%Margaret%"
    )
)   AND concert_id IN 
        (
            SELECT concert_id
            FROM con_per
            WHERE performer_id = (
        SELECT performer_id
        FROM performers
        WHERE name LIKE "%Amancio%"
        )
        )



-- 13. Suma de público durante el año 2018
SELECT SUM(people)
FROM concerts
WHERE YEAR(concert_date)=2018

-- 14. Para cada código de concierto, número de músicos

SELECT concert_id, COUNT(DISTINCT performer_id)
FROM con_per
GROUP BY concert_id

-- 15. El concierto con más músicos

SELECT concert_id, COUNT(DISTINCT(performer_id))
FROM con_per
GROUP BY concert_id
HAVING COUNT(DISTINCT(performer_id)) >= ALL (
    SELECT COUNT(DISTINCT(performer_id))
    FROM con_per
    GROUP BY concert_id
)


-- 16. Para cada compositor (que salgan todos), número de
-- conciertos y número de piezas musicales distintas interpretadas

SELECT c.composer_id, c.name, COUNT(DISTINCT cp.concert_id) AS num_concerts, COUNT(DISTINCT cp.piece_id) AS num_pieces
FROM composers c 
LEFT JOIN pieces p ON c.composer_id=p.composer_id
LEFT JOIN con_pie cp ON p.piece_id=cp.piece_id
GROUP BY c.composer_id, c.name

-- 17. Intérpretes que hayan participado en todos los conciertos
-- de la Casa Colón


-- ¿Cuantos conciertos hubo en la Casa Colón?

SELECT COUNT(DISTINCT concert_id) AS Num_conc
FROM concerts
WHERE auditorium= "Casa Colón"
-- ¿Cuantos conciertos en la Casa Colón hizo cada intérprete?
SELECT performer_id, COUNT(DISTINCT concert_id)
FROM con_per
WHERE concert_id IN (
    SELECT concert_id
    FROM concerts
    WHERE auditorium="Casa Colón"
)
GROUP BY performer_id 


-- Todo junto

SELECT performer_id, COUNT(DISTINCT concert_id)
FROM con_per
WHERE concert_id IN (
    SELECT concert_id
    FROM concerts
    WHERE auditorium="Casa Colón"
)
GROUP BY performer_id
HAVING COUNT(DISTINCT concert_id) = (
    SELECT COUNT(DISTINCT concert_id)
    FROM concerts
    WHERE auditorium= "Casa Colón" )



-- 18. Intérpretes que no han participado en ningún concierto
-- de la Casa Colón

SELECT performer_id, COUNT(DISTINCT concert_id)
FROM con_per
WHERE concert_id NOT IN (
    SELECT concert_id
    FROM concerts
    WHERE auditorium="Casa Colón"
)
GROUP BY performer_id
-- 19. Para cada intérprete (que salgan todos), todos sus datos y número
-- de instrumentos que toca

-- 20. Modifica la tabla composers para que la clave primaria
-- sea autonumérica

-- 21. MySQL devuelve un error porque existe una clave ajena
-- en la tabla pieces que apunta a la clave primaria de composers

-- 22. Borrar la restricción de integridad de clave ajena

-- 23. Repetimos la instrucción que dió error

-- 24. Volvemos a crear la restricción de clave ajena

-- 25. Inserta al compositor Freddie Mercury, de forma que se genere su clave primaria

-- 26. La función LAST_INSERT_ID() devuelve la última clave primaria autonumérica
-- generada en una operación INSERT

-- 27. Inserta la pieza musical 'Bohemian Rapsody'

-- 28. Modifica la tabla performers para que la clave primaria sea autonumérica

-- 29. Insertar un nuevo intérprete, llamado 'Nganga, Mobutu' que tocó el piano
-- en los conciertos 2 y 3

-- 30. El intérprete que toca más instrumentos distintos

-- 31. Para cada intérprete (que salgan todos), número de veces que
-- ha actuado en la Casa Colón, ordenados por número de conciertos

-- 32. Para cada pieza musical (que salgan todas), número de veces
-- que ha sido interpretada en la Casa Colón

-- 33. Intérpretes que hayan participado en todos los conciertos

-- 34. Para cada concierto, número de violines y número de guitarras

-- 35. Para cada intérprete, número de conciertos en el Gran Teatro
-- y número de conciertos en la Casa Colón

-- 36. Para cada código de concierto, el código del compositor más antiguo

-- 37. Lo mismo pero mostrando todos los datos del concierto y el compositor

-- 38. Todos los datos de los intérpretes junto con el porcentaje de conciertos
-- en los que ha tocada 

-- 39. Crear una vista llamada per_con_per con el left join de las
-- tablas performers y con_per

-- 40. Crear una vista llamada com_pie con el left join de composers y pieces

-- 41. Para cada músico, todos sus datos y el número de piezas musicales

-- 42. Crear una vista llamada con_con_pie con el left join de concerts y con_pie

-- 43. Usando la vista con_con_pie, para cada concierto, número de piezas musicales

-- 44. Suma de público de conciertos donde se ha interpretado música de Mozart

-- 45. Usando la vista con_con_pie, para cada concierto, número de compositores

