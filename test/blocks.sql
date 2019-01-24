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

-- example 6 cursors
DECLARE
expNum Trips.ExpeditionNumber%TYPE := 1;
minDist Trips.Distance%TYPE := 200.00;
maxDist Trips.Distance%TYPE := 1000.00;
pcDist NUMBER(5,2) := 10;
   CURSOR list_trip(expN IN NUMBER)
   IS
      SELECT * FROM Trips
      WHERE ExpeditionNumber = expN;
trip list_trip%ROWTYPE;
new_dist Trips.Distance%TYPE;
BEGIN
   OPEN list_trip(expNum);
   DBMS_OUTPUT.PUT_LINE('open cupsor');
   FETCH list_trip
      INTO trip;
   WHILE list_trip%FOUND LOOP
      new_dist := trip.Distance*(100 + pcDist) / 100;
      IF new_dist > maxDist
         THEN new_dist := maxDist;
      ELSIF new_dist < minDist
         THEN new_dist := minDist;
      END IF;
      DBMS_OUTPUT.PUT_LINE('Trip'||trip.NumberTrip||', old distance = '||trip.Distance||' ,new distance'||new_dist);
      FETCH list_trip
         INTO trip;
   END LOOP;
   CLOSE list_trip;
   DBMS_OUTPUT.PUT_LINE('close cupsor');
END;
/
