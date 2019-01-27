SET SERVEROUTPUT ON

-- example 1
DECLARE
X INTEGER := 8;
Y INTEGER := 5;
BEGIN
X := X + Y;
Y := Y - 3;
DBMS_OUTPUT.PUT_LINE ('X = '||X||' Y = '||Y);
END;
/

-- example 2 - mark block
<<outerblock>>
DECLARE
counter INTEGER := 0;
BEGIN
   DECLARE
counter INTEGER := 1;
   BEGIN
      IF counter = outerblock.counter
        THEN DBMS_OUTPUT.PUT_LINE('X_out = '||outerblock.counter);
      ELSE  DBMS_OUTPUT.PUT_LINE('X_int = '||counter);
      END IF;
   END;
END outerblock;
/

-- example 3 - record type
DECLARE
TYPE trevel_date IS RECORD(
    ExpeditionNumber INTEGER,
    DateStart DATE,
    DateFinish DATE
);
my_dates trevel_date;
selected_id INTEGER := 2;
BEGIN
   SELECT ExpeditionNumber, DateStart, DateFinish
   INTO my_dates
   FROM Expeditions
   WHERE ExpeditionNumber = selected_id;
DBMS_OUTPUT.PUT_LINE(my_dates.DateStart||':'||my_dates.DateFinish);
END;
/

-- example 4 - control operators
-- part 1 if-else-end if
DECLARE
x NUMBER := 6;
BEGIN
   IF x = 3
      THEN DBMS_OUTPUT.PUT_LINE('3');
   ELSIF x = 5
      THEN DBMS_OUTPUT.PUT_LINE('5');
   ELSIF x = 10
      THEN DBMS_OUTPUT.PUT_LINE('10');
   ELSE
      DBMS_OUTPUT.PUT_LINE('not found');
   END IF;
END;
/

-- part 2 case
DECLARE
x NUMBER := 6;
BEGIN
   CASE x
      WHEN 3 THEN DBMS_OUTPUT.PUT_LINE('3');
      WHEN 5 THEN DBMS_OUTPUT.PUT_LINE('5');
      WHEN 10 THEN DBMS_OUTPUT.PUT_LINE('10');
   ELSE
      DBMS_OUTPUT.PUT_LINE('not found');
   END CASE;
END;
/

-- part 3 case experession
DECLARE
x NUMBER := 6;
y NUMBER := 0;
BEGIN
y :=
   CASE x
      WHEN 3 THEN 9
      WHEN 5 THEN 25
      WHEN 10 THEN 100
   ELSE
      100
   END;
DBMS_OUTPUT.PUT_LINE('y = '||y);
END;
/

-- example 5 circle
-- part 1: loop
DECLARE
i INTEGER := 0;
y INTEGER := 10;
BEGIN
   LOOP
      IF i >= y 
         THEN EXIT;
      END IF;
      i := i + 1;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('last value '||i);
END;
/

/* part 2 while
WHILE условие LOOP
   исполняемые_операторы;
END LOOP;
*/

-- part 3 for
DECLARE
m INTEGER := 3 * 2;
BEGIN
   FOR i IN 1..m LOOP
      DBMS_OUTPUT.PUT_LINE ('max=' || m || ' i=' || i);
   END LOOP;
END;
/

--  part 4 goto
DECLARE
cntreg INTEGER := 6;
reg INTEGER;
BEGIN
   SELECT MAX(NumberRegion)
   INTO reg
   FROM Regions;
   FOR i IN reg + 1..reg + cntreg LOOP
      DBMS_OUTPUT.PUT_LINE('i = '||i||' reg = '||reg);
      IF i > 10
         THEN GOTO label_exit;
      END IF;
      INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
      VALUES(Seq.nextval, 'Намибия', 'Смешанный', 8);
   END LOOP;
   <<label_exit>>
   NULL; /* after goto mark should opr */
END;
/

-- example 7 exceptions
DECLARE
vals VARCHAR2(30) := 'S';
valn NUMBER;
expChar_To_number EXCEPTION;
   PRAGMA EXCEPTION_INIT(expChar_To_number, -06502);
BEGIN
   DBMS_OUTPUT.PUT_LINE('string ='||vals);
   valn := TO_NUMBER(vals);
   DBMS_OUTPUT.PUT_LINE('number ='||valn);
   EXCEPTION
      WHEN expChar_To_number THEN
      DBMS_OUTPUT.PUT_LINE('not number');
END;
/

-- example 8, create proc
-- current date
CREATE OR REPLACE PROCEDURE show_date
IS
today DATE DEFAULT SYSDATE;
BEGIN
DBMS_OUTPUT.PUT_LINE('current date = '||today);
END show_date;
/

-- call
BEGIN
show_date;
END;
/
