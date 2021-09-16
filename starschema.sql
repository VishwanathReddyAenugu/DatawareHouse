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
