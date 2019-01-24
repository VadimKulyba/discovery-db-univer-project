-- create and user views
-- ver updated
CREATE OR REPLACE VIEW Ice AS
SELECT *
FROM Regions R
WHERE R.SpaceType = 'Ледники'
WITH CHECK OPTION CONSTRAINT check_Ice;

-- work
INSERT INTO Ice
VALUES(Seq.nextval, 'Работает', 'Ледники', 8, 'test');
-- not work
INSERT INTO Ice
VALUES(Seq.nextval, 'Не Работает', 'Пустыне', 8, 'test');

-- gor not updated
CREATE OR REPLACE VIEW Travel_exp AS
SELECT T.LastName, T.FirstName, E.ExpeditionName
FROM Travelers T, Forms F, Expeditions E
WHERE T.TravelerNumber = F.TravelerNumber AND F.ExpeditionNumber = E.ExpeditionNumber;

SELECT * FROM Travel_exp;

-- 3. create updated view for work view (from monday to friday) and (from 9 to 17)

Create or replace view Exp_time as
SELECT *
From Expeditions
WHERE to_char(sysdate,'D') between 1 and 5 
AND 
to_char(sysdate, 'HH24:MI:SS') between '09:00:00' and '17:00:00'
WITH CHECK OPTION;
