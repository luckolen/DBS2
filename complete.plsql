-- Zet de server output aan
set serveroutput on

-- Drop alle tables, functies en procedures weer
DROP TABLE University;
DROP TABLE Country;
DROP FUNCTION generateISIN;
DROP FUNCTION checkForCorrectness;
DROP PROCEDURE ASSERT_EQUALS;

-- Maak de landen tabel
CREATE TABLE Country
(
  ID NUMBER PRIMARY KEY,
  Code VARCHAR2(3) UNIQUE NOT NULL,
  Name VARCHAR2(50) UNIQUE NOT NULL
);

-- Maak de universiteiten tabel
CREATE TABLE University
(
  ID NUMBER PRIMARY KEY,
  Code VARCHAR2(4) UNIQUE NOT NULL,
  CountryID NUMBER NOT NULL,
  Name VARCHAR2(100) NOT NULL,
  SNL NUMBER NOT NULL,
  
  FOREIGN KEY (CountryID) REFERENCES Country(ID)
);

-- Voeg wat landen toe
INSERT INTO Country VALUES (1, 'NL', 'The Netherlands');
INSERT INTO Country VALUES (2, 'FR', 'France');
INSERT INTO Country VALUES (3, 'DE', 'Germany');
INSERT INTO Country VALUES (4, 'GB', 'United Kingdom');
INSERT INTO Country VALUES (5, 'BE', 'Belgium');
INSERT INTO Country VALUES (6, 'US', 'United States of America');
INSERT INTO Country VALUES (7, 'CA', 'Canada');

-- Universiteiten in Gelderland
INSERT INTO University VALUES (0, 'TUA',   1, 'Theologische Universiteit Apeldoorn', 8);
INSERT INTO University VALUES (1, 'RUN',   1, 'Radboud Universiteit Nijmegen', 10);
INSERT INTO University VALUES (2, 'WUR',   1, 'Wageningen Universiteit', 10);

-- Universiteiten in Groningen
INSERT INTO University VALUES (3, 'RUG',   1, 'Rijksuniversiteit Groningen', 7);

-- Universiteiten in Limburg
INSERT INTO University VALUES (4, 'UM',    1, 'Universiteit Maastricht', 8);
INSERT INTO University VALUES (5, 'OU',    1, 'Open Universiteit', 7);
INSERT INTO University VALUES (6, 'MSM',   1, 'Maastricht School of Management', 10);

-- Universiteiten in Noord-Brabant
INSERT INTO University VALUES (7, 'TUE',   1, 'Technische Universiteit Eindhoven', 9);
INSERT INTO University VALUES (8, 'TIU',   1, 'Universiteit van Tilburg', 9);

-- Universiteiten in Noord-Holland
INSERT INTO University VALUES (9, 'UVA',   1, 'Universiteit van Amsterdam', 10);
INSERT INTO University VALUES (10, 'VU',   1, 'Vrije Universiteit', 9);

-- Universiteiten in Overijssel
INSERT INTO University VALUES (11, 'PTHU', 1, 'Protestantse Theologische Universiteit vestiging Kampen', 7);
INSERT INTO University VALUES (12, 'TUK',  1, 'Theologische Universiteit Kampen', 6);
INSERT INTO University VALUES (13, 'UT',   1, 'Universiteit Twente', 7);

-- Universiteiten in Utrecht
INSERT INTO University VALUES (14, 'UU',   1, 'Universiteit Utrecht', 8);
INSERT INTO University VALUES (15, 'NBU',  1, 'Nyenrode Business Universiteit', 10);
INSERT INTO University VALUES (16, 'UVH',  1, 'Universiteit voor Humanistiek', 6);
INSERT INTO University VALUES (17, 'KTU',  1, 'Katholieke Theologische Universiteit', 6);
INSERT INTO University VALUES (18, 'TIAS', 1, 'TiasNimbas Business School', 7);

-- Universiteiten in Zeeland
INSERT INTO University VALUES (19, 'UCR',  1, 'University College Roosevelt', 7);

-- Universiteiten in Noord-Holland
INSERT INTO University VALUES (20, 'TUD',  1, 'Technische Universiteit Delft', 9);
INSERT INTO University VALUES (21, 'UL',   1, 'Universiteit Leiden', 10);
INSERT INTO University VALUES (22, 'RUR',  1, 'Erasmus Universiteit Rotterdam', 10);

CREATE OR REPLACE FUNCTION tochecksum(
  input VARCHAR2
)
RETURN VARCHAR2
AS
  output VARCHAR2(50) := '';
  stringLength number;
  indexCounter number := 0;
  currentChar char(1);
  
  part_array dbms_sql.varchar2_table;
  array_length number := 0;
BEGIN
  stringLength := length(input);
  while(indexCounter < stringLength)
  loop
    indexCounter := indexCounter + 1;
    currentChar := substr(input, indexCounter, 1);
    currentChar := upper(currentChar);
    if ASCII(currentChar) > 47 and ASCII(currentChar) < 58 then
      output := output || currentChar;
    elsif currentChar != ' ' then
      output := output || to_char(ASCII(currentChar) - 49);
    end if;
  end loop;
  while(length(output) > 0)
  loop
    array_length := array_length + 1;
    part_array(array_length) := substr(output, 0, 4);
    output := substr(output, 5);
  end loop;
  output := '';
  for i in 1..array_length
  loop
    output := output || part_array(array_length - i + 1);
  end loop;
  output := MOD(TO_NUMBER(output), 62);
  if length(output) = 1 then
    output := '0' || output;
  end if;
  RETURN output;
END;
/

-- Een functie om een International Student Identification Number (ISIN) te genereren
CREATE OR REPLACE FUNCTION generateISIN(
  countryCode Country.Code%TYPE,
  universityCode University.Code%TYPE,
  studentNumber VARCHAR2
)
RETURN VARCHAR2
AS
  temp VARCHAR2(50);
  part_array dbms_sql.varchar2_table;
  array_length number := 0;
  newStudentNumber VARCHAR2(50) := '';
BEGIN
  temp := studentNumber || tochecksum(universitycode || ' ' || countryCode || ' ' || studentnumber);
  while(length(temp) > 0)
  loop
    array_length := array_length + 1;
    part_array(array_length) := substr(temp, 0, 4);
    temp := substr(temp, 5);
  end loop;
  
  for i in 1..part_array.count
  loop
    newStudentNumber := newStudentNumber || part_array(i) || ' ';
  end loop;
  
  newStudentNumber := countrycode  || ' ' || newStudentNumber || universitycode;
  RETURN newStudentNumber;
END;
/

-- Een functie die controleert of een gegeven ISIN voldoet aan de eisen
CREATE OR REPLACE FUNCTION checkForCorrectness (
  ISIN VARCHAR2
)
RETURN INTEGER
AS
  part_array DBMS_SQL.varchar2_table;
  array_length NUMBER := 0;
  country VARCHAR2(50);
  uni VARCHAR2(50);
  temp VARCHAR2(50);
  sqlString VARCHAR2(200);
  sqlResult number(10);
  checksum VARCHAR2(2);
BEGIN
  temp := ISIN;
  while(instr(temp,' ') > 0)
  loop
      array_length := array_length + 1;
      part_array(array_length) := trim(substr(temp, 0, instr(temp, ' ')));
      temp := substr(temp, instr(temp, ' ') + 1);
  end loop;
  part_array(array_length) := temp;
  country := part_array(1);
  uni := part_array(part_array.count);
  
  select count(*) into sqlResult from university, country where university.code = uni AND country.code = country ;
  if sqlResult < 1 then
    RETURN 0;
  end if;
  
  temp := ISIN;
  temp := replace(temp, country);
  temp := replace(temp, uni);
  temp := replace(temp, ' ');
  checksum := substr(temp, length(temp) - 1);
  temp := substr(temp, 0, length(temp) - 2);
  if tochecksum(uni || ' ' || country || ' ' || temp) != checksum then
    RETURN 0;
  end if;
  
  select snl into sqlResult from university where code = uni;
  if sqlResult != length(temp) then
    RETURN 0;
  end if;

  RETURN 1;
END;
/

-- Een hulp functie die bij de test cases wordt gebruik
CREATE OR REPLACE PROCEDURE ASSERT_EQUALS (
  actual VARCHAR2,
  expected VARCHAR2
)
AS
BEGIN
  IF (NVL(actual, -1) ^= NVL(expected, -2)) THEN
    RAISE_APPLICATION_ERROR(-20000, 'ASSERT FAILS. ' || actual || ' != ' || expected);
  END IF;
END;
/
