-- proc for create expedition forms
CREATE OR REPLACE PROCEDURE CREATE_EXPEDITION_FORM(
    travelerNumber Travelers.TravelerNumber%TYPE,
    travelerPosition Travelers.Department%TYPE DEFAULT '',
    expeditionNumber Expeditions.ExpeditionNumber%TYPE
)
IS

CURSOR exped_list(travelerNum IN INTEGER)
IS SELECT E.DateStart, E.DateFinish
    FROM Travelers T 
    LEFT JOIN Forms F ON T.TravelerNumber = F.TravelerNumber
    LEFT JOIN Expeditions E ON F.ExpeditionNumber = E.ExpeditionNumber
    WHERE T.TravelerNumber = travelerNum;

trip_dates exped_list%ROWTYPE;

TYPE EXPEDITION_INFO IS RECORD(
    TravelerNumber Expeditions.TravelerNumber%TYPE,
    DateStart Expeditions.DateStart%TYPE,
    DateFinish Expeditions.DateFinish%TYPE
);

expeditionInfo EXPEDITION_INFO;

FUNCTION getDefaultPosition (travelerNum IN INTEGER)
RETURN Travelers.Department%TYPE
IS
result Travelers.Department%TYPE;
BEGIN
    IF travelerPosition = ''
        THEN SELECT Department
                INTO result
                FROM Travelers
                WHERE TravelerNumber = travelerNum;
    ELSE
        result := travelerPosition;
    END IF;
RETURN result;
END getDefaultPosition;

FUNCTION getExpeditionInfo (expeditionNum IN INTEGER)
RETURN EXPEDITION_INFO
IS
result EXPEDITION_INFO;
BEGIN
    SELECT TravelerNumber, DateStart, DateFinish
        INTO result
        FROM Expeditions
        WHERE ExpeditionNumber = expeditionNum;
RETURN result;
END getExpeditionInfo;

BEGIN
    expeditionInfo := getExpeditionInfo(expeditionNumber);
    OPEN exped_list(travelerNumber);
    FETCH exped_list
        INTO trip_dates;
    WHILE exped_list%FOUND LOOP
        IF trip_dates.DateStart BETWEEN expeditionInfo.DateStart and expeditionInfo.DateFinish
            THEN GOTO label_busy;
        ELSIF trip_dates.DateFinish BETWEEN expeditionInfo.DateStart and expeditionInfo.DateFinish
            THEN GOTO label_busy;
        END IF;
        FETCH exped_list
            INTO trip_dates;
    END LOOP;

    IF SYSDATE < expeditionInfo.DateStart
        THEN
        IF NOT expeditionInfo.TravelerNumber = travelerNumber
            THEN DBMS_OUTPUT.PUT_LINE('good lucky');
            INSERT INTO Forms(NumberForm, TravelerPosition, TravelerNumber, ExpeditionNumber)
                VALUES(Seq3.nextval, travelerPosition, travelerNumber, expeditionNumber);
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('you expedition founder');
        END IF;
    ELSIF SYSDATE BETWEEN expeditionInfo.DateStart and expeditionInfo.DateFinish
        THEN DBMS_OUTPUT.PUT_LINE('in process');
    ELSIF SYSDATE > expeditionInfo.DateFinish
        THEN DBMS_OUTPUT.PUT_LINE('be late');
    END IF;
    
    <<label_busy>>
    CLOSE exped_list;
    DBMS_OUTPUT.PUT_LINE('time to busy');
END CREATE_EXPEDITION_FORM;
/

-- call proc
BEGIN
CREATE_EXPEDITION_FORM(travelerNumber => 8,
                    travelerPosition => 'Повар',
                    expeditionNumber => 1);
END;
/

-- current work func
CREATE OR REPLACE FUNCTION CURRENT_EXP(
    travelerNumber Travelers.TravelerNumber%TYPE,
    deteval DATE DEFAULT SYSDATE
) RETURN VARCHAR2
IS

CURSOR exped_list(travelerNum IN INTEGER)
IS SELECT E.ExpeditionName, E.DateStart, E.DateFinish
    FROM Travelers T 
    LEFT JOIN Forms F ON T.TravelerNumber = F.TravelerNumber
    LEFT JOIN Expeditions E ON F.ExpeditionNumber = E.ExpeditionNumber
    WHERE T.TravelerNumber = travelerNum;

trips exped_list%ROWTYPE;

BEGIN
    OPEN exped_list(travelerNumber);
    FETCH exped_list
        INTO trips;
    WHILE exped_list%FOUND LOOP
        IF deteval BETWEEN trips.DateStart and trips.DateFinish
            THEN GOTO label_on_the_way;
        END IF;
        FETCH exped_list
            INTO trips;
    END LOOP;
    CLOSE exped_list;
    RETURN 'free';
    <<label_on_the_way>>
    CLOSE exped_list;
    RETURN trips.ExpeditionName;
END;
/

-- call
DECLARE
BEGIN
DBMS_OUTPUT.PUT_LINE(CURRENT_EXP(travelerNumber => 2));
END;
/

-- proc
-- update danger level
CREATE OR REPLACE PROCEDURE CHANGE_DANGER_LEVEL(
   new_level IN INTEGER, reg_number IN INTEGER) IS
maxLevel Regions.DangerLevel%TYPE := 10;
minLevel Regions.DangerLevel%TYPE := 1;
current_level Regions.DangerLevel%TYPE;
BEGIN
   SELECT DangerLevel
      INTO current_level
      FROM Regions
      WHERE NumberRegion = reg_number;
   
   IF new_level > maxLevel
      THEN RAISE_APPLICATION_ERROR(-06502, 'biggest LEVEL');
   ELSIF new_level < minLevel
      THEN RAISE_APPLICATION_ERROR(-06502, 'smallest LEVEL');
   ELSIF new_level <> current_level THEN
      UPDATE Regions SET DangerLevel=new_level
         WHERE NumberRegion = reg_number;
      COMMIT;
   END IF;
   EXCEPTION
   WHEN no_data_found THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
   WHEN others THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
END CHANGE_DANGER_LEVEL;
/

-- call
BEGIN
CHANGE_DANGER_LEVEL(new_level => 5, reg_number => 1);
END;
/

-- example 9, create func
-- time in expeditions
CREATE OR REPLACE FUNCTION get_exp_date(
   expId Expeditions.ExpeditionNumber%TYPE,
   deteval DATE DEFAULT SYSDATE
) RETURN VARCHAR2 
IS
result INTERVAL DAY TO SECOND;
date_start Expeditions.DateStart%TYPE;
date_finish Expeditions.DateFinish%Type;
BEGIN
   SELECT DateStart, DateFinish
      INTO date_start, date_finish
      FROM Expeditions
      WHERE ExpeditionNumber = expId;
   IF deteval BETWEEN date_start and date_finish
      THEN result := (deteval - date_start) DAY TO SECOND;
   ELSE
      result := (date_finish - date_start) DAY TO SECOND;
   END IF;
   RETURN result;
END;
/

-- call func 
DECLARE
time INTERVAL DAY TO SECOND;
BEGIN
time := get_exp_date(expId => 3);
DBMS_OUTPUT.PUT_LINE(time);
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

-- Overload 
DECLARE
PROCEDURE getCountRegionBy(spaceType IN VARCHAR2) 
IS
count_S INTEGER;
BEGIN
    SELECT COUNT(*) INTO count_S FROM Regions WHERE SpaceType = spaceType;
    DBMS_OUTPUT.PUT_LINE('Result by spaceType ='||count_S);
END getCountRegionBy;

PROCEDURE getCountRegionBy(dangerLevel IN INTEGER) 
IS
count_D INTEGER;
BEGIN
    SELECT COUNT(*) INTO count_D FROM Regions WHERE DangerLevel = dangerLevel;
    DBMS_OUTPUT.PUT_LINE('Result by dangerLevel ='||count_D);
END getCountRegionBy;

BEGIN
    getCountRegionBy('Ледки');
    getCountRegionBy(4);
END;
/
