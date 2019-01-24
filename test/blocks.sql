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


