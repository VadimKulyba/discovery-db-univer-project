create or replace package discovery as
PROCEDURE CHANGE_DANGER_LEVEL(
   new_level IN INTEGER, reg_number IN INTEGER);

PROCEDURE CREATE_EXPEDITION_FORM(
    travelerNumber Travelers.TravelerNumber%TYPE,
    travelerPosition Travelers.Department%TYPE DEFAULT '',
    expeditionNumber Expeditions.ExpeditionNumber%TYPE
);
FUNCTION CURRENT_EXP(
    travelerNumber Travelers.TravelerNumber%TYPE,
    deteval DATE DEFAULT SYSDATE
) RETURN VARCHAR2; 
end discovery;
/

create or replace package body discovery as
PROCEDURE CHANGE_DANGER_LEVEL(
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
      THEN RAISE_APPLICATION_ERROR(-20051, 'biggest LEVEL');
   ELSIF new_level < minLevel
      THEN RAISE_APPLICATION_ERROR(-20051, 'smallest LEVEL');
   ELSIF new_level <> current_level THEN
      UPDATE Regions SET DangerLevel=new_level
         WHERE NumberRegion = reg_number;
      COMMIT;
   END IF;
   EXCEPTION
   WHEN others THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
END CHANGE_DANGER_LEVEL;

PROCEDURE CREATE_EXPEDITION_FORM(
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

FUNCTION CURRENT_EXP(
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
END CURRENT_EXP;

end discovery; 
/


-- call proc
BEGIN
discovery.CREATE_EXPEDITION_FORM(travelerNumber => 8,
                    travelerPosition => 'Повар',
                    expeditionNumber => 1);
discovery.CREATE_EXPEDITION_FORM(travelerNumber => 6,
                    travelerPosition => 'Инженер',
                    expeditionNumber => 1);
discovery.CHANGE_DANGER_LEVEL(new_level => 11, reg_number => 1);
discovery.CHANGE_DANGER_LEVEL(new_level => 11, reg_number => NULL);
discovery.CHANGE_DANGER_LEVEL(new_level => 9, reg_number => 1);
DBMS_OUTPUT.PUT_LINE(CURRENT_EXP(travelerNumber => 2));
DBMS_OUTPUT.PUT_LINE(CURRENT_EXP(travelerNumber => 1));
END;
/
