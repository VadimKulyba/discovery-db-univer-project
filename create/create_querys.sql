-- 1. Сonditional query
-- Return travelers names and photo if role admin
SELECT LastName, FirstName, PhoneNumber FROM Travelers
WHERE TravelerRole='admin';

-- 2. Final query, total distance traveled

SELECT T.LastName, T.FirstName, SUM(Tr.Distance) as FullDist
FROM Travelers T 
LEFT JOIN Forms F ON T.TravelerNumber = F.TravelerNumber
LEFT JOIN Expeditions E ON F.ExpeditionNumber = E.ExpeditionNumber
LEFT JOIN Trips Tr ON Tr.ExpeditionNumber = E.ExpeditionNumber
WHERE Tr.Distance > 0
GROUP BY T.LastName, T.FirstName;

-- 3. Parametric query

SELECT NumberRegion, RegionName, SpaceType, DangerLevel
FROM Regions
WHERE NumberRegion = &NumberRegion;

-- 4. UNION query Count exp, lead and usuql
-- 
SELECT T.LastName, T.FirstName, T.TravelerEmail, COUNT(E.TravelerNumber), 'lead'
FROM Travelers T LEFT JOIN Expeditions E
ON T.TravelerNumber = E.TravelerNumber
GROUP BY T.LastName, T.FirstName, T.TravelerEmail
UNION
SELECT T.LastName, T.FirstName, T.TravelerEmail, COUNT(E.ExpeditionNumber), 'usual'
FROM Travelers T 
LEFT JOIN Forms F ON T.TravelerNumber = F.TravelerNumber
LEFT JOIN Expeditions E ON F.ExpeditionNumber = E.ExpeditionNumber
GROUP BY T.LastName, T.FirstName, T.TravelerEmail;

-- 5. Query with date type
-- execute now
-- 
SELECT * FROM Expeditions
WHERE sysdate > Expeditions.DateStart AND sysdate < DateFinish;

-- calculate expedition days and sort by days
SELECT ExpeditionNumber, ExpeditionName, DateStart,
to_date(DateFinish, 'DD/MM/YYYY') - to_date(DateStart, 'DD/MM/YYYY') as TripCount
FROM Expeditions
ORDER BY TripCount;

-- 6. JOIN ON (AND) USING

SELECT TeleshowName, ExpeditionName
FROM Teleshows T 
LEFT JOIN Shows S ON T.NumberTeleshow = S.NumberTeleshow
LEFT JOIN Expeditions E ON S.ExpeditionNumber = E.ExpeditionNumber
WHERE T.Chanel = 'Discovery';

SELECT TeleshowName, ExpeditionName
FROM Teleshows T 
LEFT JOIN Shows S USING(NumberTeleshow)
LEFT JOIN Expeditions E USING(ExpeditionNumber)
WHERE T.Chanel = 'Discovery';

-- 7. LEFT JOIN
-- sum expedition distans > 850
-- 
SELECT ExpeditionName, SUM(T.Distance) as SumDist
FROM Expeditions E LEFT JOIN Trips T
USING(ExpeditionNumber)
GROUP BY ExpeditionName
HAVING SUM(T.Distance) > 850;

-- 8. IN with query
-- travelers join exp in 2017
SELECT FirstName, LastName, PhoneNumber 
FROM Travelers
WHERE TravelerNumber IN 
(SELECT TravelerNumber 
FROM Forms
WHERE to_char(JoinDate, 'YYYY') = '2017');

-- 9. Query ANY/ALL
--  max count expedition for travelers
SELECT FirstName, LastName, TravelerEmail, COUNT(F.TravelerNumber) as ExpCount 
FROM Travelers T, Forms F
WHERE T.TravelerNumber = F.TravelerNumber
GROUP BY LastName, FirstName, TravelerEmail
HAVING COUNT(F.TravelerNumber) >= ALL(
    SELECT COUNT(ExpeditionNumber) FROM Forms
    GROUP BY TravelerNumber);

-- 10. Query EXISTS/NOT EXISTS 
-- not going expeditions
SELECT LastName, FirstName FROM Travelers T
WHERE NOT EXISTS (
    SELECT * FROM Forms F
    WHERE F.TravelerNumber = T.TravelerNumber 
);