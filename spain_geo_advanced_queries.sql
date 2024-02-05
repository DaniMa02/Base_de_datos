-- 1. Suma de población de Andalucía

SELECT SUM(population)
FROM provinces
WHERE aut_region_id = (
    SELECT aut_region_id
    FROM aut_regions
    WHERE name="Andalucía"
)

-- 2. Provincias costeras de Andalucía

SELECT *
FROM provinces
WHERE aut_region_id = (
    SELECT aut_region_id
    FROM aut_regions
    WHERE name="Andalucía"
)
AND coast

-- 3. Provincias andaluzas con población comprendida
-- entre 500000 y 600000 habitantes

SELECT *
FROM provinces
WHERE aut_region_id IN (
    SELECT aut_region_id
    FROM aut_regions
    WHERE name="Andalucía"
)
AND population >500000
AND population <600000

-- 4. Número de provincias por las que atraviesa el Ebro

SELECT COUNT(province_id)
FROM pro_riv
WHERE river_id =(
    SELECT river_id
    FROM rivers
    WHERE name="Ebro"
)

-- 5. Todos los datos de provincias por las que atraviesa el Ebro

SELECT *
FROM provinces
WHERE province_id IN(
    SELECT province_id
    FROM pro_riv
    WHERE river_id=(
        SELECT river_id
        FROM rivers 
        WHERE name="Ebro"
    )
)

-- 6. Ríos que no pasan por Andalucía

SELECT *
FROM rivers
WHERE river_id NOT IN(
    SELECT river_id
    FROM pro_riv
    WHERE province_id IN(
        SELECT province_id
        FROM provinces
        WHERE aut_region_id=(
            SELECT aut_region_id
            FROM aut_regions
            WHERE name="Andalucía"
        )
    )
)

-- 7. Número de provincias y de comunidades por las que atraviesa el Ebro

SELECT COUNT(province_id), COUNT(DISTINCT aut_region_id)
FROM provinces
WHERE province_id IN (
    SELECT province_id
    FROM pro_riv
        WHERE river_id = (
        SELECT river_id
        FROM rivers
        WHERE name="Ebro"
        )
) 

-- 8. Ríos más largos que el Guadalquivir

SELECT *
FROM rivers
WHERE river_length > (
    SELECT river_length
    FROM rivers
    WHERE name="Guadalquivir"
)

-- 9. Provincias con menos población que Huelva

SELECT *
FROM provinces
WHERE population < (
    SELECT population
    FROM provinces
    WHERE name="Huelva"
)

-- 10. Regiones con más población que Galicia

SELECT *, SUM(population)
FROM aut_regions a, provinces p
WHERE a.aut_region_id=p.aut_region_id
GROUP BY a.aut_region_id, a.name
HAVING SUM(population) > (
    SELECT SUM(population)
    FROM aut_regions a, provinces p
    WHERE a.aut_region_id=p.aut_region_id
    AND a.name="Galicia"
)

-- Con equijoin

SELECT *, SUM(population)
FROM aut_regions a, provinces p
WHERE a.aut_region_id=p.aut_region_id
GROUP BY a.aut_region_id, a.name
HAVING SUM(population) > (
    SELECT SUM(population)
    FROM provinces
    WHERE aut_region_id = (
        SELECT aut_region_id
        FROM aut_regions
        WHERE name="Galicia"
    )
)

-- 11. Ríos aragoneses que desemboquen en el Mediterráneo

SELECT *
FROM rivers
WHERE sea="Mediterráneo"
AND river_id IN (
    SELECT river_id
    FROM pro_riv
    WHERE province_id IN (
        SELECT province_id
        FROM provinces
        WHERE aut_region_id = (
            SELECT aut_region_id
            FROM aut_regions
            WHERE name="Aragón"
        )
    )
)

-- 12. Ríos que nacen en Jaén y desembocan en el Atlántico

SELECT *
FROM rivers
WHERE sea="Atlántico"
AND river_id IN (
    SELECT river_id
    FROM pro_riv
    WHERE province_id IN (
        SELECT province_id
        FROM provinces
        WHERE name="Jaén" AND river_order=1
    )
)

-- 13. Número de ríos que nacen en Jaén

SELECT COUNT(*)
FROM pro_riv
WHERE province_id IN (
    SELECT province_id
    FROM provinces
    WHERE name="Jaén" AND river_order=1
)

-- 14. Densidad de población de Cataluña

SELECT SUM(population) / SUM(surface)
FROM provinces
WHERE aut_region_id IN (
    SELECT aut_region_id
    FROM aut_regions
    WHERE name="Cataluña"
)

-- 15. Número de ríos en Andalucía

SELECT COUNT(DISTINCT river_id)
FROM pro_riv
WHERE province_id IN (
    SELECT province_id
    FROM provinces
    WHERE aut_region_id = (
        SELECT aut_region_id
        FROM aut_regions
        WHERE name="Andalucía"
    )
)

-- 16. Todos los datos de los ríos de Andalucía

SELECT *
FROM rivers
WHERE river_id IN(
    SELECT river_id
    FROM pro_riv
    WHERE province_id IN (
    SELECT province_id
    FROM provinces
    WHERE aut_region_id = (
        SELECT aut_region_id
        FROM aut_regions
        WHERE name="Andalucía"
         )
    )
)

-- 17. Todos los datos de la región más grande

SELECT a.*, SUM(p.surface) AS área
FROM provinces p, aut_regions a
WHERE a.aut_region_id=p.aut_region_id
GROUP BY a.aut_region_id, a.name
HAVING SUM(surface) >= ALL (
    SELECT SUM(surface)
    FROM provinces
    GROUP BY aut_region_id
)

-- 18. Todos los datos de la región con más ríos

SELECT a.*, COUNT(DISTINCT pr.river_id)
FROM provinces p, aut_regions a, pro_riv pr
WHERE a.aut_region_id=p.aut_region_id
AND pr.province_id=p.province_id
GROUP BY a.aut_region_id, a.name
HAVING COUNT(DISTINCT pr.river_id) >= ALL (
    SELECT COUNT(DISTINCT pr.river_id)
    FROM provinces p, pro_riv pr
    WHERE pr.province_id=p.province_id
    GROUP BY aut_region_id
)

-- 19. Para cada mar, el río más largo

SELECT r1.*
FROM rivers r1
WHERE river_length >= ALL (
    SELECT river_length
    FROM rivers r2
    WHERE r1.sea=r2.sea -- Subconsultas correlacionadas cuando queremos obtener varios máximos o mínimos
)

-- 20. Para cada identificador de región, el río más largo

SELECT p1.aut_region_id, r1.name, r1.river_length
FROM provinces p1, pro_riv pr1, rivers r1
WHERE p1.province_id=pr1.province_id AND r1.river_id=pr1.river_id
AND r1.river_length >= ALL (
    SELECT r2.river_length
    FROM provinces p2, pro_riv pr2, rivers r2
    WHERE p2.province_id=pr2.province_id AND r2.river_id=pr2.river_id
    AND p1.aut_region_id=p2.aut_region_id
)

-- 21. Añadir a lo anterior el nombre de la región

-- 22. Para cada identificador de región, la 
-- provincia más poblada

SELECT *
FROM provinces p1
WHERE population >= ALL (
    SELECT population
    FROM provinces p2
    WHERE p1.aut_region_id=p2.aut_region_id
)

-- 23. Añadir a lo anterior el nombre de la región

SELECT a1.name, p1.*
FROM provinces p1, aut_regions a1
WHERE a1.aut_region_id=p1.aut_region_id 
AND population >= ALL (
    SELECT population
    FROM provinces p2
    WHERE p1.aut_region_id=p2.aut_region_id
)

-- 24. Porcentaje de población de Huelva respecto a España
-- Subconsulta en SELECT

SELECT population
FROM provinces
WHERE name="Huelva"
--519932
SELECT SUM(population)
FROM provinces
--46780772  

SELECT 519932/46780772*100

--Todo junto

SELECT (
    SELECT population
    FROM provinces
    WHERE name="Huelva"
)/ (
    SELECT SUM(population)
    FROM provinces
)*100


-- 25. Porcentaje de población de Huelva respecto a Andalucía
SELECT (
     SELECT population
    FROM provinces
    WHERE name="Huelva"
)/(
    SELECT SUM(population)
    FROM provinces
    WHERE aut_region_id=(
        SELECT aut_region_id
        FROM aut_regions
        WHERE name="Andalucía"
    )
)*100

-- 26. Porcentaje de Andalucía respecto a España

SELECT (
        SELECT SUM(population)
    FROM provinces
    WHERE aut_region_id=(
        SELECT aut_region_id
        FROM aut_regions
        WHERE name="Andalucía"

)/(
    SELECT SUM(population)
    FROM provinces
)*100

--27. Para cada región, su identificador, nombre, suma de superficio y porcentaje de superficio respecto a España


SELECT a.aut_region_id, a.name, SUM(p.surface) AS km2, SUM(p.surface)/(
    SELECT SUM(surface)
    FROM provinces
)*100 AS porcentaje
FROM provinces p, aut_regions a
WHERE a.aut_region_id=p.aut_region_id
GROUP BY a.aut_region_id, a.name

--28. Añadir a lo anterior la suma de poblacion y el porcentaje de poblacion respecto a España

SELECT a.aut_region_id, a.name, SUM(p.surface) AS km2, SUM(p.surface)/(
    SELECT SUM(surface)
    FROM provinces
)*100 AS porcentaje, SUM(p.population) AS population, SUM(p.population)/(
    SELECT SUM(population)
    FROM provinces
)*100
FROM provinces p, aut_regions a
WHERE a.aut_region_id=p.aut_region_id
GROUP BY a.aut_region_id, a.name