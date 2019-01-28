-- DML
CREATE TABLE log1(
    ID INTEGER primary key, 
    DbUser VARCHAR2(50) NOT NULL, 
    LogTime DATE NOT NULL, 
    ActionType varchar2(20) NOT NULL, 
    Changes varchar2(255) NOT NULL
);

CREATE SEQUENCE Seq_log1 INCREMENT BY 1 START WITH 1 MINVALUE 1;

CREATE OR REPLACE TRIGGER EXPEDITION_LOG_TRIGGER
    AFTER INSERT OR DELETE OR UPDATE ON Expeditions
        FOR EACH ROW
DECLARE
TYPE TRAVELER_INFO IS RECORD(
    firstName VARCHAR2(40),
    lastName VARCHAR2(50),
    email VARCHAR2(50)
);
founder TRAVELER_INFO;
SignalType VARCHAR2(6);
BEGIN
    IF INSERTING THEN
		  SignalType := 'INSERT';
	ELSIF UPDATING THEN
		  SignalType := 'UPDATE';
	ELSIF DELETING THEN
		  SignalType := 'DELETE';
	END IF;

    SELECT FirstName, LastName, TravelerEmail
    INTO founder
    FROM Travelers
    WHERE TravelerNumber = :NEW.TravelerNumber;

    INSERT INTO log1(ID, DbUser, LogTime, ActionType, Changes)
    VALUES(Seq_log1.nextval, USER, SYSDATE, SignalType, 'Expedition Founder: '||founder.lastName||' '||founder.firstName||' email: '||founder.email);
END EXPEDITION_LOG_TRIGGER;
/

-- DDL
CREATE TABLE log2(
    ID INTEGER primary key, 
    DbUser VARCHAR2(50) NOT NULL, 
    LogTime DATE NOT NULL, 
    ActionType varchar2(20) NOT NULL
);

CREATE SEQUENCE Seq_log2 INCREMENT BY 1 START WITH 1 MINVALUE 1;

CREATE OR REPLACE TRIGGER ManageSchema
    BEFORE CREATE OR DROP OR ALTER ON USERNAME.SCHEMA
BEGIN
    IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) > 20
        THEN RAISE_APPLICATION_ERROR(-20001, 'Work over - late');
    ELSIF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) < 9
        THEN RAISE_APPLICATION_ERROR(-20002, 'Work over - early');
    ELSIF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) BETWEEN 13 AND 14
        THEN RAISE_APPLICATION_ERROR(-20002, 'lunch')
    ELSE
        INSERT INTO log2(ID, DbUser, LogTime, ActionType)
            VALUES(Seq_log2.nextval, USER, SYSDATE, ora_SYSEVENT);
    END IF;
END ManageSchema;
/

--3. system audit trigger 
CREATE TABLE sys.log_sys(
    key integer primary key,
    my_user varchar2(50),
    type varchar2(50),
    time varchar2(255),
    counter number
);

create sequence sys_seq start with 1 increment by 1;

CREATE OR REPLACE TRIGGER trg3_1
	after LOGON ON DATABASE 
DECLARE
number_of_rows number;
BEGIN
SELECT COUNT(*) INTO number_of_rows FROM USERNAME.Expeditions;
INSERT INTO sys.log_sys(key, my_user, type, time, counter)
			VALUES(sys.sys_seq.nextval, USER, ora_SYSEVENT, sysdate, number_of_rows);
END trg3_1;
/

CREATE OR REPLACE TRIGGER trg3_2
	BEFORE LOGOFF ON DATABASE 
DECLARE
number_of_rows number;
BEGIN
SELECT COUNT(*) INTO number_of_rows FROM USERNAME.Expeditions;
INSERT INTO sys.log_sys(key, my_user, type, time, counter)
			VALUES(sys.sys_seq.nextval, USER, ora_SYSEVENT, sysdate, number_of_rows);
END trg3_2;
/

-- 4.1
-- write survive rating on db
CREATE TABLE SurviveRating(
    Rating NUMBER(6,2),
    TravelerNumber INTEGER primary key,
    CONSTRAINT rating_travelers
        FOREIGN KEY (TravelerNumber)
        REFERENCES Travelers(TravelerNumber)
);

ALTER TABLE SurviveRating
ADD FounderRating NUMBER(6,2);

CREATE SEQUENCE Seq_log3 INCREMENT BY 1 START WITH 1 MINVALUE 1;

-- solve this problem below
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);
INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
    VALUES(Seq_log3.nextval, 0, 0);

CREATE OR REPLACE TRIGGER RATING_TRIGGER
	BEFORE INSERT OR UPDATE ON Expeditions
	for each row
DECLARE
CURSOR counter_trg IS
    SELECT T.TravelerNumber AS TravelerID, COUNT(E.ExpeditionNumber) AS ExpeditionCount, 'lead' AS Status
    FROM Travelers T LEFT JOIN Expeditions E
    ON T.TravelerNumber = E.TravelerNumber
    GROUP BY T.TravelerNumber
    UNION
    SELECT T.TravelerNumber AS TravelerID, COUNT(E.ExpeditionNumber) AS ExpeditionCount, 'usual' AS Status
    FROM Travelers T
    LEFT JOIN Forms F ON T.TravelerNumber = F.TravelerNumber
    LEFT JOIN Expeditions E ON F.ExpeditionNumber = E.ExpeditionNumber
    GROUP BY T.TravelerNumber;

BEGIN
FOR exp_info in counter_trg LOOP
    IF exp_info.Status = 'lead'
        THEN
        IF exp_info.ExpeditionCount > 1 and exp_info.ExpeditionCount <= 2 THEN
        UPDATE SurviveRating SET FounderRating = 10
            WHERE TravelerNumber=exp_info.TravelerID;
        ELSIF exp_info.ExpeditionCount > 2 and exp_info.ExpeditionCount <= 3 THEN 
        UPDATE SurviveRating SET FounderRating = 20
            WHERE TravelerNumber=exp_info.TravelerID;
        ELSIF exp_info.ExpeditionCount > 3 THEN
        UPDATE SurviveRating SET FounderRating = 30
            WHERE TravelerNumber=exp_info.TravelerID;
        ELSE 
        UPDATE SurviveRating SET FounderRating = 0
            WHERE TravelerNumber=exp_info.TravelerID;
        END IF;
    ELSIF exp_info.Status = 'usual'
        THEN
        IF exp_info.ExpeditionCount > 1 and exp_info.ExpeditionCount <= 2 THEN
        UPDATE SurviveRating SET Rating = 2
            WHERE TravelerNumber=exp_info.TravelerID;
        ELSIF exp_info.ExpeditionCount > 2 and exp_info.ExpeditionCount <= 3 THEN 
        UPDATE SurviveRating SET Rating = 5
            WHERE TravelerNumber=exp_info.TravelerID;
        ELSIF exp_info.ExpeditionCount > 3 THEN
        UPDATE SurviveRating SET Rating = 10
            WHERE TravelerNumber=exp_info.TravelerID;
        ELSE 
        UPDATE SurviveRating SET Rating = 0
            WHERE TravelerNumber=exp_info.TravelerID;
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'not found status');
    END IF;
 END LOOP;
 end RATING_TRIGGER;
/

-- 4.2 fix
CREATE OR REPLACE TRIGGER AFTER_INSERT_TRAVELER
    AFTER INSERT ON Travelers
        FOR EACH ROW
BEGIN
    INSERT INTO SurviveRating(TravelerNumber, Rating, FounderRating)
        VALUES(:NEW.TravelerNumber, 0, 0);
END AFTER_INSERT_TRAVELER;
/

-- 4.3 insert form if validation true
CREATE OR REPLACE TRIGGER CREATE_EXPEDITION_FORM
    BEFORE INSERT ON Forms
    FOR EACH ROW
DECLARE

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
    expeditionInfo := getExpeditionInfo(:NEW.ExpeditionNumber);
    OPEN exped_list(:NEW.TravelerNumber);
    FETCH exped_list
        INTO trip_dates;
    WHILE exped_list%FOUND LOOP
        IF trip_dates.DateStart BETWEEN expeditionInfo.DateStart and expeditionInfo.DateFinish
            THEN CLOSE exped_list;
            RAISE_APPLICATION_ERROR(-20004, 'Time to busy');
        ELSIF trip_dates.DateFinish BETWEEN expeditionInfo.DateStart and expeditionInfo.DateFinish
            THEN CLOSE exped_list;
            RAISE_APPLICATION_ERROR(-20004, 'Time to busy');
        END IF;
        FETCH exped_list
            INTO trip_dates;
    END LOOP;

    IF SYSDATE < expeditionInfo.DateStart
        THEN
        IF NOT expeditionInfo.TravelerNumber = :NEW.TravelerNumber
            THEN DBMS_OUTPUT.PUT_LINE('good lucky');
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'you expedition founder');
        END IF;
    ELSIF SYSDATE BETWEEN expeditionInfo.DateStart and expeditionInfo.DateFinish
        THEN RAISE_APPLICATION_ERROR(-20002, 'in process');
    ELSIF SYSDATE > expeditionInfo.DateFinish
        THEN RAISE_APPLICATION_ERROR(-20001, 'be late');
    END IF;

    CLOSE exped_list;
END CREATE_EXPEDITION_FORM;
/

-- mutating
-- write status expedition on db
ALTER TABLE Expeditions
ADD Status VARCHAR2(20);

CREATE OR REPLACE TRIGGER EXP_STATUS
    BEFORE INSERT OR UPDATE ON Expeditions
    FOR EACH ROW
DECLARE
CURSOR exp_dates IS
    SELECT ExpeditionNumber, DateStart, DateFinish
    FROM Expeditions;
BEGIN
    FOR dates_info IN exp_dates LOOP
        IF SYSDATE BETWEEN dates_info.DateStart AND dates_info.DateFinish
            THEN UPDATE Expeditions SET Status = 'in process'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSIF SYSDATE < dates_info.DateStart
            THEN UPDATE Expeditions SET Status = 'prepare'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSIF SYSDATE > dates_info.DateFinish
            THEN UPDATE Expeditions SET Status = 'passed'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSE
            UPDATE Expeditions SET Status = 'not known'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        END IF;
    END LOOP;
END EXP_STATUS;
/

-- solve 1 - package with 2 triggers
CREATE OR REPLACE PACKAGE pkg
IS
    PROCEDURE AddStatus;
    flag BOOLEAN;
    CURSOR exp_dates IS
    SELECT ExpeditionNumber, DateStart, DateFinish
    FROM Expeditions;
END pkg;
/

CREATE OR REPLACE PACKAGE BODY pkg
IS
PROCEDURE AddStatus
IS
BEGIN
IF flag=true THEN 
flag:=false;
    FOR dates_info IN exp_dates LOOP
        IF SYSDATE BETWEEN dates_info.DateStart AND dates_info.DateFinish
            THEN UPDATE Expeditions SET Status = 'in process'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSIF SYSDATE < dates_info.DateStart
            THEN UPDATE Expeditions SET Status = 'prepare'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSIF SYSDATE > dates_info.DateFinish
            THEN UPDATE Expeditions SET Status = 'passed'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSE
            UPDATE Expeditions SET Status = 'not known'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        END IF;
    END LOOP;
END IF;
END;
END pkg;
/

CREATE OR REPLACE TRIGGER tr_1
BEFORE INSERT ON Expeditions
    FOR EACH ROW
BEGIN
    pkg.flag := true;
END;
/

CREATE OR REPLACE TRIGGER tr_2
AFTER INSERT ON Expeditions
BEGIN
    pkg.AddStatus;
END;
/

-- Solve 2 - COMPOUND
CREATE OR REPLACE TRIGGER EXP_STATUS
    FOR INSERT ON Expeditions
    COMPOUND TRIGGER
flag BOOLEAN;
CURSOR exp_dates IS
    SELECT ExpeditionNumber, DateStart, DateFinish
    FROM Expeditions;

BEFORE EACH ROW IS
BEGIN
flag := true;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
IF flag = true THEN 
flag := false;
    FOR dates_info IN exp_dates LOOP
        IF SYSDATE BETWEEN dates_info.DateStart AND dates_info.DateFinish
            THEN UPDATE Expeditions SET Status = 'in process'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSIF SYSDATE < dates_info.DateStart
            THEN UPDATE Expeditions SET Status = 'prepare'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSIF SYSDATE > dates_info.DateFinish
            THEN UPDATE Expeditions SET Status = 'passed'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        ELSE
            UPDATE Expeditions SET Status = 'not known'
                WHERE ExpeditionNumber = dates_info.ExpeditionNumber;
        END IF;
    END LOOP;
END IF;
END AFTER STATEMENT;
END EXP_STATUS;
/

-- 6. INSTEAD OF
-- from lab with views

-- grant CREATE VIEW to USERNAME;

CREATE OR REPLACE VIEW Travel_exp AS
SELECT T.LastName, T.FirstName, E.ExpeditionName, E.ExpeditionNumber
FROM Travelers T, Forms F, Expeditions E
WHERE T.TravelerNumber = F.TravelerNumber 
AND F.ExpeditionNumber = E.ExpeditionNumber;

SELECT * FROM Travel_exp;

CREATE OR REPLACE TRIGGER VIEW_TRIGGER
INSTEAD OF UPDATE ON Travel_exp
FOR EACH ROW
BEGIN
    UPDATE Expeditions SET ExpeditionName = :NEW.ExpeditionName
        WHERE ExpeditionNumber = :NEW.ExpeditionNumber;
END VIEW_TRIGGER;
/

UPDATE Travel_exp SET ExpeditionName = 'Центральная Америка' WHERE ExpeditionNumber = 3;
