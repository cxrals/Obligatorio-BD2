use DBCARGAS;
SET DATEFORMAT DMY;

--SE PIDE 4
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--a
SELECT DISTINCT CLIENTE.cliNom, CLIENTE.cliMail, CLIENTE.cliCantCargas
FROM CLIENTE
JOIN CARGA ON CARGA.cliID = CLIENTE.cliID
WHERE CARGA.cargaKilos > (SELECT AVG(cargaKilos)
						FROM CARGA
						WHERE YEAR(cargaFch) = (YEAR(GETDATE()) -1))
--me falto un AND YEAR(CARGA.cargaFch) = (YEAR(GETDATE()))
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--b
SELECT MAX(totalKilosCargadosPorAvion) AS 'Mayor peso cargado por un avion', MIN(totalKilosCargadosPorAvion) AS 'Menor peso cargado por un avion', AVG(totalKilosCargadosPorAvion) AS 'Promedio del peso total cargado por aviones'
FROM (SELECT SUM(CARGA.cargaKilos) totalKilosCargadosPorAvion
	FROM CARGA
	GROUP BY CARGA.avionID) suma
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--c
SELECT CONTAINERS.*, CARGAS.cantidadCargas, CARGAS.totalDeKilos
FROM DCONTAINER AS CONTAINERS
LEFT JOIN ( SELECT dContID, COUNT(idCarga) AS cantidadCargas, SUM(cargaKilos) AS totalDeKilos
			FROM CARGA 
			GROUP BY dContID
) AS CARGAS 
ON CONTAINERS.dContID = CARGAS.dContID
ORDER BY CARGAS.cantidadCargas DESC
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--d
SELECT Cl.cliID, Cl.cliNom, Cl.cliMail, Cl.cliCantCargas
FROM Cliente Cl, Carga C
WHERE Cl.cliID = C.cliID
GROUP BY Cl.cliID, Cl.cliNom, Cl.cliMail, Cl.cliCantCargas
HAVING COUNT(DISTINCT C.avionID) = (SELECT COUNT(Distinct avionID)
									FROM AVION) --relational division*
									--este segundo Distinct no era necesario
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--e
SELECT CARGA.idCarga, CARGA.cargaFch, ao.aeroNombre AS 'Origen', ad.aeroNombre AS 'Destino'
FROM CARGA
JOIN AEROPUERTO ao ON ao.codIATA = CARGA.aeroOrigen
JOIN AEROPUERTO ad ON ad.codIATA = CARGA.aeroDestino
WHERE YEAR(CARGA.cargaFch) = YEAR(GETDATE())
AND CARGA.avionID IN (SELECT AVION.avionID FROM AVION WHERE AVION.avionCapacidad > 100)
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--f
--Mostrar los datos del aeropuerto que recibió la mayor cantidad de kilos de los últimos 5 años.
SELECT AEROPUERTOS.*, CARGAS.totalDeKilos
FROM AEROPUERTO AS AEROPUERTOS
LEFT JOIN ( SELECT aeroDestino, SUM(cargaKilos) AS totalDeKilos
			FROM CARGA 
			WHERE DATEDIFF(YEAR, cargaFch, GETDATE()) <= 5
			GROUP BY aeroDestino
) AS CARGAS 
ON AEROPUERTOS.codIATA = CARGAS.aeroDestino
ORDER BY CARGAS.totalDeKilos DESC
--me falto el TOP 1