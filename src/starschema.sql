-- Creating star schema tables
DROP TABLE fact_flights CASCADE CONSTRAINTS;
CREATE TABLE fact_flights
(
    fact_key    INTEGER NOT NULL,
    NoOfFlightsArrivalDelayedPerMonthPerDestinationAirport  INTEGER,
    NoOfFlightsWithTaxiInTimeDelayedPerMonthPerDestinationAirport   INTEGER,
    fk1_time_key    INTEGER NOT NULL,
    fk2_airport_key INTEGER NOT NULL,
    
    CONSTRAINT  pk_fact_flights PRIMARY KEY (fact_key)
);

DROP TABLE time_dim CASCADE CONSTRAINTS;
CREATE TABLE time_dim
(
    time_key    INTEGER NOT NULL,
    year    INTEGER,
    month   INTEGER,
    
    CONSTRAINT  pk_time_dim PRIMARY KEY (time_key)
);

DROP TABLE airport_dim CASCADE CONSTRAINTS;
CREATE TABLE airport_dim
(
    airport_key INTEGER NOT NULL,
    airport_code    VARCHAR(8),
    city_name_current   VARCHAR(20),
    city_name_new   VARCHAR(20),
    effective_date  TIMESTAMP(8),

    CONSTRAINT  pk_airport_dim PRIMARY KEY (airport_key)
);

ALTER TABLE fact_flights ADD CONSTRAINT fk1_fact_flights_to_time_dim FOREIGN KEY(fk1_time_key) REFERENCES time_dim(time_key);
ALTER TABLE fact_flights ADD CONSTRAINT fk2_fact_flights_to_airport_dim FOREIGN KEY(fk2_airport_key) REFERENCES airport_dim(airport_key);

DROP SEQUENCE timekey_Seq;
CREATE SEQUENCE timekey_Seq
start with 1 
increment by 1;

DROP SEQUENCE airportkey_Seq ;
CREATE SEQUENCE airportkey_Seq
start with 1 
increment by 1;

DROP sequence FACT_SEQ;
create sequence FACT_SEQ
start with 1
increment by 1;

-- Stage Area 1
Drop Table stagearea1 CASCADE CONSTRAINTS;
 CREATE TABLE stagearea1
  (       
    pk                   NUMBER NOT NULL,
    flightDate           DATE, 
    destAirportcode      VARCHAR2(4),
    DESTINTION_CITY      VARCHAR2(20),
    departureDelay       NUMBER,
    taxiIn               NUMBER,
    source               VARCHAR2(10)      
  );  

DROP SEQUENCE srcSeq ;
CREATE SEQUENCE srcSeq
start with 1 
increment by 1;

-- SEQUENCE FOR LOGTABLE
DROP SEQUENCE logSeq ;
CREATE SEQUENCE logSeq
start with 1
increment by 1;

DROP TABLE logETL CASCADE CONSTRAINTS;
CREATE TABLE logETL (eventId Number, tableName VARCHAR2(20), eventDate DATE, description VARCHAR2(20), pk_value NUMBER,CODE VARCHAR2(5));

CREATE OR REPLACE TRIGGER trig_etl
   BEFORE UPDATE ON stagearea1
   FOR EACH ROW
   BEGIN
     IF UPDATING THEN
     INSERT INTO logETL VALUES (logSeq.nextval,'stageArea1',SYSDATE,'UPDATE',:OLD.pk,NULL);
     END IF;
   END;

  -- Loading data from sources into stage-area 1
INSERT INTO stagearea1(pk, flightDate, destAirportcode, DESTINTION_CITY ,departureDelay, taxiIn, source )
SELECT srcseq.nextval, FL_DATE, DEST,DESTINTION_CITY,DEP_DELAY, TAXI_IN, 'year 2017' FROM SOURCE1;

INSERT INTO stagearea1(pk, flightDate, destAirportcode, DESTINTION_CITY ,departureDelay, taxiIn, source )
SELECT srcseq.nextval, FL_DATE, DEST,DESTINTION_CITY,DEP_DELAY, TAXI_IN, 'year 2018' FROM SOURCE2;




-- setting negative values of departure delay to zero as they correspond to early departure.
UPDATE stagearea1 SET DEPARTUREDELAY = 0 WHERE DEPARTUREDELAY < 0; 
UPDATE stagearea1 SET TAXIIN = 0 WHERE TAXIIN < 0; 

UPDATE stagearea1 SET DESTINTION_CITY = 'Not Known' WHERE DESTINTION_CITY = NULL;
UPDATE stagearea1 SET DESTINTION_CITY = 'Not Known' WHERE DESTINTION_CITY = '-';



-- UPDATE the missing city names
UPDATE stagearea1 SET DESTINTION_CITY = 'Columbus' where DESTAIRPORTCODE = 'CMH';
UPDATE stagearea1 SET DESTINTION_CITY = 'Nashville' where DESTAIRPORTCODE = 'BNA';
UPDATE stagearea1 SET DESTINTION_CITY = 'Hebron' where DESTAIRPORTCODE = 'CVG';
UPDATE stagearea1 SET DESTINTION_CITY = 'Sandston' where DESTAIRPORTCODE = 'RIC';
UPDATE stagearea1 SET DESTINTION_CITY = 'Worcester' where DESTAIRPORTCODE = 'ORH';
UPDATE stagearea1 SET DESTINTION_CITY = 'Ontario' where DESTAIRPORTCODE = 'ONT';
UPDATE stagearea1 SET DESTINTION_CITY = 'Nantucket' where DESTAIRPORTCODE = 'ACK';
UPDATE stagearea1 SET DESTINTION_CITY = 'Indianapolis' where DESTAIRPORTCODE = 'IND';
UPDATE stagearea1 SET DESTINTION_CITY = 'Norfolk' where DESTAIRPORTCODE = 'ORF';
UPDATE stagearea1 SET DESTINTION_CITY = 'Baltimore/Washington' where DESTAIRPORTCODE = 'BWI';
UPDATE stagearea1 SET DESTINTION_CITY = 'Bangor' where DESTAIRPORTCODE = 'BGR';
UPDATE stagearea1 SET DESTINTION_CITY = 'Hyannis' where DESTAIRPORTCODE = 'HYA';
UPDATE stagearea1 SET DESTINTION_CITY = 'Cleveland' where DESTAIRPORTCODE = 'CLE';
UPDATE stagearea1 SET DESTINTION_CITY = 'Irvine' where DESTAIRPORTCODE = 'SNA';
UPDATE stagearea1 SET DESTINTION_CITY = 'Philadelphia ' where DESTAIRPORTCODE = 'PHL';
UPDATE stagearea1 SET DESTINTION_CITY = 'Vineyard Haven ' where DESTAIRPORTCODE = 'MVY';

-- stage area 2

Drop Table stagearea2 CASCADE CONSTRAINTS;
CREATE TABLE stagearea2 AS
SELECT PK, 
to_number(to_char(STAGEAREA1.FLIGHTDATE,'YYYY')) as The_year,
to_number(to_char(STAGEAREA1.FLIGHTDATE,'MM')) as The_month,
DESTAIRPORTCODE as AirportId,
DESTINTION_CITY AS DESTINTION_CITY,
DEPARTUREDELAY as departureDelayMin,
TAXIIN as taxiInTimeInMin FROM STAGEAREA1;
DROP TABLE tmp1_DD CASCADE CONSTRAINTS;
CREATE TABLE tmp1_DD AS SELECT THE_YEAR, THE_MONTH, AIRPORTID, COUNT(*) no_Of_Flights_DD FROM STAGEAREA2 where DEPARTUREDELAYMIN > 0 GROUP by THE_YEAR, THE_MONTH,  AIRPORTID
ORDER BY THE_YEAR, THE_MONTH,AIRPORTID;

DROP TABLE tmp1_TD CASCADE CONSTRAINTS;
CREATE TABLE tmp1_TD AS SELECT THE_YEAR, THE_MONTH, AIRPORTID, COUNT(*) no_Of_Flights_TD FROM STAGEAREA2 where TAXIINTIMEINMIN > 0 GROUP by THE_YEAR, THE_MONTH, AIRPORTID 
ORDER BY THE_YEAR, THE_MONTH, AIRPORTID;

--TIME DIM
DROP TABLE tmp_time CASCADE CONSTRAINTS;
CREATE TABLE tmp_time (THE_YEAR,THE_MONTH) AS SELECT DISTINCT THE_YEAR, THE_MONTH FROM STAGEAREA2 ORDER BY THE_YEAR, THE_MONTH;

--AIRPORT dimenSion;
DROP TABLE tmp_airport CASCADE CONSTRAINTS;
CREATE TABLE tmp_airport AS SELECT DISTINCT AIRPORTID, DESTINTION_CITY FROM STAGEAREA2;

--Populating Time dimenion
insert into time_dim select timekey_Seq.nextval, the_year, the_month from tmp_time;

--Populating Airport dimension
insert into airport_dim select airportkey_Seq.nextval, AIRPORTID , DESTINTION_CITY ,NULL, NULL from TMP_airport;

--Populating Fact table
DROP TABLE TMP_FACT;
CREATE TABLE TMP_FACT AS SELECT tmp1_TD.THE_YEAR, tmp1_TD.THE_MONTH, tmp1_TD.AIRPORTID, tmp1_TD.NO_OF_FLIGHTS_TD, tmp1_DD.NO_OF_FLIGHTS_DD 
from tmp1_TD FULL OUTER JOIN tmp1_DD ON
tmp1_DD.THE_YEAR = tmp1_TD.THE_YEAR AND tmp1_DD.THE_MONTH = tmp1_TD.THE_MONTH AND tmp1_DD.AIRPORTID=tmp1_TD.AIRPORTID;

INSERT INTO FACT_flights (FACT_KEY, FK1_TIME_KEY, FK2_AIRPORT_KEY, NoOfFlightsDepDelayedPerMonthPerDestinationAirport, NOOFFLIGHTSWITHTAXIINTIMEDELAYEDPERMONTHPERDESTINATIONAIRPORT)
SELECT FACT_SEQ.nextval, TIME_DIM.TIME_KEY, Airport_DIM.AIRPORT_KEY, NO_OF_FLIGHTS_DD, NO_OF_FLIGHTS_TD FROM TIME_DIM, AIRPORT_DIM,TMP_FACT
WHERE TMP_FACT.THE_MONTH=TIME_DIM.MONTH AND TMP_FACT.THE_YEAR=TIME_DIM.YEAR AND AIRPORT_DIM.AIRPORT_CODE=TMP_FACT.AIRPORTID;

--slowly changing dimension type-3
UPDATE AIRPORT_DIM ad SET ad.CITY_NAME_NEW = 'NEW_NAME', ad.EFFECTIVE_DATE = sysdate WHERE ad.AIRPORT_CODE = 'CODE';


-- Reports

DROP TABLE report1;
CREATE TABLE report1 AS SELECT TD.YEAR, TD.MONTH, AD.AIRPORT_CODE ,F.NOOFFLIGHTSARRIVALDELAYEDPERMONTHPERDESTINATIONAIRPORT NUM_OF_FLIGHTS_DEPARTURE_DELAYED 
FROM  AIRPORT_DIM AD, TIME_DIM TD,FACT_FLIGHTS F
WHERE AD.AIRPORT_KEY=F.FK2_AIRPORT_KEY AND TD.TIME_KEY = F.FK1_TIME_KEY;

DROP TABLE report2;
CREATE TABLE report2 AS SELECT TD.YEAR, TD.MONTH, AD.AIRPORT_CODE ,F.NOOFFLIGHTSWITHTAXIINTIMEDELAYEDPERMONTHPERDESTINATIONAIRPORT NUM_OF_FLIGHTS_TAXI_IN_TIME_DELAYED 
FROM  AIRPORT_DIM AD, TIME_DIM TD,FACT_FLIGHTS F
WHERE AD.AIRPORT_KEY=F.FK2_AIRPORT_KEY AND TD.TIME_KEY = F.FK1_TIME_KEY;



