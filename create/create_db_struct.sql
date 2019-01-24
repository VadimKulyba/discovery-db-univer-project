CREATE TABLE Travelers(
    TravelerNumber INTEGER primary key,
    TravelerEmail VARCHAR2(50) not null,
    FirstName VARCHAR2(40) not null,
    LastName VARCHAR2(50) not null,
    Department VARCHAR2(40) not null,
    TravelerRole VARCHAR2(10) DEFAULT ('traveler') CHECK( TravelerRole IN ('admin', 'traveler', 'worker') )
);

ALTER TABLE Travelers
ADD PhoneNumber VARCHAR2(13) not null;

ALTER TABLE Travelers
ADD CONSTRAINT traveler_uniq_number UNIQUE (PhoneNumber);

CREATE SEQUENCE Seq0 INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'bear@gmail.com', 'Беар', 'Гриллс', 'Исследователь', 'traveler', '+375295678315');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'heardall.t@gmail.com', 'Тур', 'Хейердал', 'Путешественник', 'traveler', '+375338765431');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'jack@gmail.com', 'Жак-Ив', 'Кусто́', 'Путешественник', 'traveler', '+375299783125');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'nick@gmail.com', 'Николай', 'Дроздов', 'Путешественник', 'traveler', '+375297831578');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'fedor@gmail.com', 'Фёдор', 'Конюхов', 'Путешественник', 'traveler', '+375297116751');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'wil.ed@gmail.com', 'Энди', 'Уилманом', 'Продюсер', 'admin', '375173490233');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'merry.d@gmail.com', 'Мэри', 'Донахью', 'Продюсер', 'admin', '375296580686');
INSERT INTO Travelers(TravelerNumber, TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber)
    VALUES(Seq0.nextval, 'pet@gmail.com', 'Пэтти', 'Дженкинс', 'Автор', 'admin', '+375225707964');

CREATE TABLE Regions(
    NumberRegion INTEGER primary key,
    RegionName VARCHAR2(30) not null,
    SpaceType VARCHAR2(30) not null,
    DangerLevel INTEGER not null CHECK( DangerLevel BETWEEN 1 AND 10 ) ,
    RegionDescription VARCHAR2(100)
);

CREATE SEQUENCE Seq INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Патагония', 'Ледники', 8);
INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Сахара', 'Пустня', 9);
INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Долина смерти', 'Пустынный', 7);
INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Большой Каньен', 'Горный', 4);
INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Океания', 'Острова', 5);
INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Джунгли Китая', 'Джунгли', 6);
INSERT INTO Regions(NumberRegion, RegionName, SpaceType, DangerLevel)
    VALUES(Seq.nextval, 'Арктика', 'Ледники', 9);

CREATE TABLE Teleshows(
    NumberTeleshow INTEGER primary key,
    Chanel VARCHAR2(25) not null,
    TeleshowName VARCHAR2(50) not null
);

CREATE SEQUENCE Seq1 INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Teleshows(NumberTeleshow, Chanel, TeleshowName)
    VALUES(Seq1.nextval, 'Discovery', 'Выжить любой ценой');
INSERT INTO Teleshows(NumberTeleshow, Chanel, TeleshowName)
    VALUES(Seq1.nextval, 'Discovery', 'Хуже быть не могло');
INSERT INTO Teleshows(NumberTeleshow, Chanel, TeleshowName)
    VALUES(Seq1.nextval, 'Discovery', 'Выживание без купюр');
INSERT INTO Teleshows(NumberTeleshow, Chanel, TeleshowName)
    VALUES(Seq1.nextval, 'Discovery', 'Голые и напуганные');
INSERT INTO Teleshows(NumberTeleshow, Chanel, TeleshowName)
    VALUES(Seq1.nextval, 'Discovery', 'Выжить вместе');
INSERT INTO Teleshows(NumberTeleshow, Chanel, TeleshowName)
    VALUES(Seq1.nextval, 'Первый', 'В мире животных');

CREATE TABLE Expeditions(
    ExpeditionNumber INTEGER primary key,
    ExpeditionName VARCHAR2(50) not null,
    ExpeditionTarget VARCHAR2(100) not null,
    Plan VARCHAR2(100),
    DateStart DATE not null,
    DateFinish DATE not null,
    TravelerNumber INTEGER not null,
    CONSTRAINT expedition_travelers
        FOREIGN KEY (TravelerNumber)
        REFERENCES Travelers(TravelerNumber)
);

CREATE SEQUENCE Seq2 INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Expeditions(ExpeditionNumber, ExpeditionName, ExpeditionTarget, DateStart, DateFinish, TravelerNumber)
    VALUES(Seq2.nextval, 'Исследование пустынь', 'Животные пустынь', to_date('01/12/2019', 'DD/MM/YYYY'), to_date('01/11/2020', 'DD/MM/YYYY'), 6);
INSERT INTO Expeditions(ExpeditionNumber, ExpeditionName, ExpeditionTarget, DateStart, DateFinish, TravelerNumber)
    VALUES(Seq2.nextval, 'Океания', 'Изучение океании', to_date('20/03/2017', 'DD/MM/YYYY'), to_date('23/04/2017', 'DD/MM/YYYY'), 1);
INSERT INTO Expeditions(ExpeditionNumber, ExpeditionName, ExpeditionTarget, DateStart, DateFinish, TravelerNumber)
    VALUES(Seq2.nextval, 'Поход по каньену', 'Поход по руслу большого каньена', to_date('11/11/2018', 'DD/MM/YYYY'), to_date('11/01/2019', 'DD/MM/YYYY'), 1);
INSERT INTO Expeditions(ExpeditionNumber, ExpeditionName, ExpeditionTarget, DateStart, DateFinish, TravelerNumber)
    VALUES(Seq2.nextval, 'Заполярье', 'Исследование полярных животных', to_date('01/10/2010', 'DD/MM/YYYY'), to_date('26/11/2010', 'DD/MM/YYYY'), 4);
INSERT INTO Expeditions(ExpeditionNumber, ExpeditionName, ExpeditionTarget, DateStart, DateFinish, TravelerNumber)
    VALUES(Seq2.nextval, 'Животные китая', 'Исследование редких видов китайских животных', to_date('10/05/2015', 'DD/MM/YYYY'), to_date('03/07/2015', 'DD/MM/YYYY'), 4);

CREATE TABLE Forms(
    NumberForm INTEGER primary key,
    TravelerPosition VARCHAR2(30) not null,
    JoinDate DATE DEFAULT (sysdate),
    TravelerNumber INTEGER not null,
    ExpeditionNumber INTEGER not null,
    CONSTRAINT TE FOREIGN KEY (TravelerNumber) REFERENCES Travelers (TravelerNumber),
    CONSTRAINT EN FOREIGN KEY (ExpeditionNumber) REFERENCES Expeditions (ExpeditionNumber)
);

CREATE SEQUENCE Seq3 INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Forms(NumberForm, TravelerPosition, JoinDate, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Путешественник', to_date('10/10/2018', 'DD/MM/YYYY'), 3, 3);
INSERT INTO Forms(NumberForm, TravelerPosition, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Исследователь', 2, 1);
INSERT INTO Forms(NumberForm, TravelerPosition, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Руководитель', 1, 1);
INSERT INTO Forms(NumberForm, TravelerPosition, JoinDate, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Руководитель', to_date('02/02/2017', 'DD/MM/YYYY'), 1, 2);
INSERT INTO Forms(NumberForm, TravelerPosition, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Оператор', 7, 1);
INSERT INTO Forms(NumberForm, TravelerPosition, JoinDate, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Оператор', to_date('05/02/2017', 'DD/MM/YYYY'), 7, 2);
INSERT INTO Forms(NumberForm, TravelerPosition, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Путешественник', 4, 1);
INSERT INTO Forms(NumberForm, TravelerPosition, JoinDate, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Иследователь', to_date('05/02/2017', 'DD/MM/YYYY'), 4, 2);
INSERT INTO Forms(NumberForm, TravelerPosition, JoinDate, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Руководитель', to_date('10/10/2018','DD/MM/YYYY'), 1, 3);
INSERT INTO Forms(NumberForm, TravelerPosition, TravelerNumber, ExpeditionNumber)
    VALUES(Seq3.nextval, 'Картограф', 5, 1);

CREATE TABLE Trips(
    NumberTrip INTEGER primary key,
    Distance NUMBER(8,4) not null CHECK (Distance > 0),
    ExpeditionNumber INTEGER not null,
    NumberRegion INTEGER not null,
    CONSTRAINT E_N FOREIGN KEY (ExpeditionNumber) REFERENCES Expeditions (ExpeditionNumber),
    CONSTRAINT NR FOREIGN KEY (NumberRegion) REFERENCES Regions (NumberRegion)
);

CREATE SEQUENCE Seq4 INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 300.00, 1, 3);
INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 550.00, 1, 2);
INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 445.00, 4, 1);
INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 553.00, 4, 7);
INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 1003.00, 2, 5);
INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 555.00, 3, 4);
INSERT INTO Trips(NumberTrip, Distance, ExpeditionNumber, NumberRegion)
    VALUES(Seq4.nextval, 897.00, 5, 6);

CREATE TABLE Shows(
    NumberShow INTEGER primary key,
    ExpeditionNumber INTEGER not null,
    NumberTeleshow INTEGER not null,
    CONSTRAINT E__N FOREIGN KEY (ExpeditionNumber) REFERENCES Expeditions (ExpeditionNumber),
    CONSTRAINT NT FOREIGN KEY (NumberTeleshow) REFERENCES Teleshows (NumberTeleshow)
);

CREATE SEQUENCE Seq5 INCREMENT BY 1 START WITH 1 MINVALUE 1;

INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 1, 2);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 2, 1);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 3, 3);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 4, 4);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 5, 1);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 1, 5);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 2, 3);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 3, 4);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 5, 3);
INSERT INTO Shows(NumberShow, ExpeditionNumber, NumberTeleshow)
    VALUES(Seq5.nextval, 4, 2);

-- update struct
UPDATE Expeditions
SET DateFinish = to_date('11/03/2019', 'DD/MM/YYYY')
WHERE ExpeditionNumber = 3;

DELETE FROM Regions WHERE NumberRegion = 21; 

-- add index and ...