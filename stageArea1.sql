--Stage Area 1:
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

-- Loading data into stage area1 from data sources

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