-- ZET DE SERVER OUTPUT AAN
SET SERVEROUTPUT ON

-- MAAK DE LANDEN TABEL
CREATE TABLE COUNTRY
(
  ID NUMBER PRIMARY KEY,
  CODE VARCHAR2(3) UNIQUE NOT NULL,
  NAME VARCHAR2(50) UNIQUE NOT NULL
);

-- MAAK DE UNIVERSITEITEN TABEL
CREATE TABLE UNIVERSITY
(
  ID NUMBER PRIMARY KEY,
  CODE VARCHAR2(4) UNIQUE NOT NULL,
  COUNTRYID NUMBER NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  SNL NUMBER NOT NULL,
  
  FOREIGN KEY (COUNTRYID) REFERENCES COUNTRY(ID)
);

-- VOEG WAT LANDEN TOE
INSERT INTO COUNTRY VALUES (1, 'NL', 'THE NETHERLANDS');
INSERT INTO COUNTRY VALUES (2, 'FR', 'FRANCE');
INSERT INTO COUNTRY VALUES (3, 'DE', 'GERMANY');
INSERT INTO COUNTRY VALUES (4, 'GB', 'UNITED KINGDOM');
INSERT INTO COUNTRY VALUES (5, 'BE', 'BELGIUM');
INSERT INTO COUNTRY VALUES (6, 'US', 'UNITED STATES OF AMERICA');
INSERT INTO COUNTRY VALUES (7, 'CA', 'CANADA');

-- UNIVERSITEITEN IN GELDERLAND
INSERT INTO UNIVERSITY VALUES (0, 'TUA',   1, 'THEOLOGISCHE UNIVERSITEIT APELDOORN', 8);
INSERT INTO UNIVERSITY VALUES (1, 'RUN',   1, 'RADBOUD UNIVERSITEIT NIJMEGEN', 10);
INSERT INTO UNIVERSITY VALUES (2, 'WUR',   1, 'WAGENINGEN UNIVERSITEIT', 10);

-- UNIVERSITEITEN IN GRONINGEN
INSERT INTO UNIVERSITY VALUES (3, 'RUG',   1, 'RIJKSUNIVERSITEIT GRONINGEN', 7);

-- UNIVERSITEITEN IN LIMBURG
INSERT INTO UNIVERSITY VALUES (4, 'UM',    1, 'UNIVERSITEIT MAASTRICHT', 8);
INSERT INTO UNIVERSITY VALUES (5, 'OU',    1, 'OPEN UNIVERSITEIT', 7);
INSERT INTO UNIVERSITY VALUES (6, 'MSM',   1, 'MAASTRICHT SCHOOL OF MANAGEMENT', 10);

-- UNIVERSITEITEN IN NOORD-BRABANT
INSERT INTO UNIVERSITY VALUES (7, 'TUE',   1, 'TECHNISCHE UNIVERSITEIT EINDHOVEN', 9);
INSERT INTO UNIVERSITY VALUES (8, 'TIU',   1, 'UNIVERSITEIT VAN TILBURG', 9);

-- UNIVERSITEITEN IN NOORD-HOLLAND
INSERT INTO UNIVERSITY VALUES (9, 'UVA',   1, 'UNIVERSITEIT VAN AMSTERDAM', 10);
INSERT INTO UNIVERSITY VALUES (10, 'VU',   1, 'VRIJE UNIVERSITEIT', 9);

-- UNIVERSITEITEN IN OVERIJSSEL
INSERT INTO UNIVERSITY VALUES (11, 'PTHU', 1, 'PROTESTANTSE THEOLOGISCHE UNIVERSITEIT VESTIGING KAMPEN', 7);
INSERT INTO UNIVERSITY VALUES (12, 'TUK',  1, 'THEOLOGISCHE UNIVERSITEIT KAMPEN', 6);
INSERT INTO UNIVERSITY VALUES (13, 'UT',   1, 'UNIVERSITEIT TWENTE', 7);

-- UNIVERSITEITEN IN UTRECHT
INSERT INTO UNIVERSITY VALUES (14, 'UU',   1, 'UNIVERSITEIT UTRECHT', 8);
INSERT INTO UNIVERSITY VALUES (15, 'NBU',  1, 'NYENRODE BUSINESS UNIVERSITEIT', 10);
INSERT INTO UNIVERSITY VALUES (16, 'UVH',  1, 'UNIVERSITEIT VOOR HUMANISTIEK', 6);
INSERT INTO UNIVERSITY VALUES (17, 'KTU',  1, 'KATHOLIEKE THEOLOGISCHE UNIVERSITEIT', 6);
INSERT INTO UNIVERSITY VALUES (18, 'TIAS', 1, 'TIASNIMBAS BUSINESS SCHOOL', 7);

-- UNIVERSITEITEN IN ZEELAND
INSERT INTO UNIVERSITY VALUES (19, 'UCR',  1, 'UNIVERSITY COLLEGE ROOSEVELT', 7);

-- UNIVERSITEITEN IN NOORD-HOLLAND
INSERT INTO UNIVERSITY VALUES (20, 'TUD',  1, 'TECHNISCHE UNIVERSITEIT DELFT', 9);
INSERT INTO UNIVERSITY VALUES (21, 'UL',   1, 'UNIVERSITEIT LEIDEN', 10);
INSERT INTO UNIVERSITY VALUES (22, 'RUR',  1, 'ERASMUS UNIVERSITEIT ROTTERDAM', 10);

--UNIVERSITEIT IN US
INTSERT INTO UNIVERSITY VALUES (23, 'UOPX', 4, 'UNIVERSITY OF PHOENIX', 30);


-- EEN FUNCTIE DIE DE CHECKSUM DOET
CREATE OR REPLACE FUNCTION TOCHECKSUM(
  INPUT VARCHAR2
)
RETURN VARCHAR2
AS
	--DECLARATIES VAN ALLE VARIABLES
  OUTPUT VARCHAR2(50) := '';
  STRINGLENGTH NUMBER;
  INDEXCOUNTER NUMBER := 0;
  CURRENTCHAR CHAR(1);
 
  PART_ARRAY DBMS_SQL.VARCHAR2_TABLE;
  ARRAY_LENGTH NUMBER := 0;
BEGIN
--HIER WORD DE STRING LENGTE VAN DE COMPLETE ISIN BEREKEND VOOR DE CHECKSUM
  STRINGLENGTH := LENGTH(INPUT);
  WHILE(INDEXCOUNTER < STRINGLENGTH)
  LOOP
    INDEXCOUNTER := INDEXCOUNTER + 1;
    CURRENTCHAR := SUBSTR(INPUT, INDEXCOUNTER, 1);
    CURRENTCHAR := UPPER(CURRENTCHAR);
	--HIER WORD GEKEKEN OF DE HUIDIGE TEKEN BUITEN DE ACSII NUMMERS 47 EN 58 VALLEN ALS DAT HET GEVAL IS DAN ZET HIM HEM OM BIJ ALS HET GEEN SPATIE IS BIJ DE ELSIF. ANDERS IS HET EEN NUMMER EN VOEGT HIJ DEZE TOE. 
    IF ASCII(CURRENTCHAR) > 47 AND ASCII(CURRENTCHAR) < 58 THEN
      OUTPUT := OUTPUT || CURRENTCHAR;
    ELSIF CURRENTCHAR != ' ' THEN
      OUTPUT := OUTPUT || TO_CHAR(ASCII(CURRENTCHAR) - 49);
    END IF;
  END LOOP;
  WHILE(LENGTH(OUTPUT) > 0)
  LOOP--HIER MAAKT DIE ER BLOKKEN VAN 4 VAN
    ARRAY_LENGTH := ARRAY_LENGTH + 1;
    PART_ARRAY(ARRAY_LENGTH) := SUBSTR(OUTPUT, 0, 4);
    OUTPUT := SUBSTR(OUTPUT, 5);
  END LOOP;
  OUTPUT := '';
  FOR I IN 1..ARRAY_LENGTH
  LOOP
  --HIER SCHRIJFT DE ANDERE VOLGORDE 
    OUTPUT := OUTPUT || PART_ARRAY(ARRAY_LENGTH - I + 1);
  END LOOP;
  --HIER GEEFT BIJ DE REST WAARDE WEER DIE OVERBLIJFT NAAR DELING DOOR 62
  OUTPUT := MOD(TO_NUMBER(OUTPUT), 62);
   if length(output) = 1 then
+    output := '0' || output;
+  end if;
  RETURN OUTPUT;
END;
/
 
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
--HIER MAAKT BIJ EEN TIJDELIJKE STRING AAN VAN STUDENTNUMMER EEN DE TOCHECKSUM MET UNICODE LANDCODE EN STUDNUMMER
  temp := studentNumber || tochecksum(universitycode || ' ' || countryCode || ' ' || studentnumber);
  while(length(temp) > 0)
  loop
    --HIER WORD EEN ARRAY AANGEMAAKT MET GROEPJES VAN 4
    array_length := array_length + 1;
    part_array(array_length) := substr(temp, 0, 4);
    temp := substr(temp, 5);
  end loop;
  
  for i in 1..part_array.count
  loop
    --HIER WORDEN VOOR WELKE ITEM IN DE ARRAY EEN SPATIE TUSSEN GEZET EN SAMEN GEVOEGD.
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
  --hier word de string in stukjes gehakt. Landcode de eerste keer, dan de blokken van nummers en als laatste de universityCode
  while(instr(temp,' ') > 0)
  loop
      array_length := array_length + 1;
      part_array(array_length) := trim(substr(temp, 0, instr(temp, ' ')));
      temp := substr(temp, instr(temp, ' ') + 1);
  end loop;
  part_array(array_length) := temp;
  --hier word het land uit de array gehaald
  country := part_array(1);
  --hier word de uni naam uit de array gehaald
  uni := part_array(part_array.count);
  --hier word die gecontolleerd od die bestaat in combinatie met het land.
  select count(*) into sqlResult from university, country where university.code = uni AND country.code = country ;
  if sqlResult < 1 then
    RETURN 0;
  end if;
  --hier word gekeken of de studentNumber geldig is. 
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
-- EEN HULP FUNCTIE DIE BIJ DE TEST CASES WORDT GEBRUIK
CREATE OR REPLACE PROCEDURE ASSERT_EQUALS (
  ACTUAL VARCHAR2,
  EXPECTED VARCHAR2
)
AS
BEGIN
  IF (NVL(ACTUAL, -1) ^= NVL(EXPECTED, -2)) THEN
    RAISE_APPLICATION_ERROR(-20000, 'ASSERT FAILS. ' || ACTUAL || ' != ' || EXPECTED);
  END IF;
END;
/

-- TEST CASES
-- ZIE MEEGELEVERDE TESTSCRIPTS
--DECLARE

--opdracht A
BEGIN
  ASSERT_EQUALS(generateISIN('NL','TUA','98162670'),'NL 9816 2670 60 TUA');
  ASSERT_EQUALS(generateISIN('NL','RUN','1889924721'),'NL 1889 9247 2130 RUN');
  ASSERT_EQUALS(generateISIN('NL','WUR','8760503442'),'NL 8760 5034 4210 WUR');
  ASSERT_EQUALS(generateISIN('NL','RUG','7948372'),'NL 7948 3725 2 RUG');
  ASSERT_EQUALS(generateISIN('NL','UM','10392781'),'NL 1039 2781 20 UM');
  ASSERT_EQUALS(generateISIN('NL','OU','2551716'),'NL 2551 7166 0 OU');
  ASSERT_EQUALS(generateISIN('NL','MSM','5337149774'),'NL 5337 1497 7446 MSM');
  ASSERT_EQUALS(generateISIN('NL','TUE','543595679'),'NL 5435 9567 926 TUE');
  ASSERT_EQUALS(generateISIN('NL','TIU','498476766'),'NL 4984 7676 634 TIU');
  ASSERT_EQUALS(generateISIN('NL','UVA','5389537253'),'NL 5389 5372 5343 UVA');
  ASSERT_EQUALS(generateISIN('NL','VU','658372658'),'NL 6583 7265 832 VU');
  ASSERT_EQUALS(generateISIN('NL','PTHU','7688668'),'NL 7688 6682 7 PTHU');
  ASSERT_EQUALS(generateISIN('NL','TUK','429859'),'NL 4298 5932 TUK');
  ASSERT_EQUALS(generateISIN('NL','UT','7279553'),'NL 7279 5534 5 UT');
  ASSERT_EQUALS(generateISIN('NL','UU','04692710'),'NL 0469 2710 10 UU');
  ASSERT_EQUALS(generateISIN('NL','NBU','1100500646'),'NL 1100 5006 4613 NBU');
  ASSERT_EQUALS(generateISIN('NL','UVH','862176'),'NL 8621 7619 UVH');
  ASSERT_EQUALS(generateISIN('NL','KTU','903151'),'NL 9031 5123 KTU');
  ASSERT_EQUALS(generateISIN('NL','TIAS','7294147'),'NL 7294 1472 8 TIAS');
  ASSERT_EQUALS(generateISIN('NL','UCR','7187419'),'NL 7187 4195 8 UCR');
  ASSERT_EQUALS(generateISIN('NL','TUD','548194600'),'NL 5481 9460 022 TUD');
  ASSERT_EQUALS(generateISIN('NL','UL','7906541256'),'NL 7906 5412 5643 UL');
  ASSERT_EQUALS(generateISIN('NL','RUR','6396609648'),'NL 6396 6096 4834 RUR');
END;

--opdracht B
BEGIN
  --testcases die fout moeten gaan
  --lengte gegeven studentnummer (3216 = lengte 4) komt niet overeen met die voor gegeven landcode NL en universiteitscode TUE nl. 9 (zie tabel University)
  ASSERT_EQUALS(checkForCorrectness('NL 3216 02 TUE'), 0);

  --testcases die goed moeten gaan
  ASSERT_EQUALS(checkForCorrectness('NL 4633 4809 KTU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 4954 2537 7808 MSM'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 8051 5891 4351 NBU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 0346 7021 0 OU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 1483 5380 9 PTHU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 8838 4630 6 RUG'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 0520 3256 8940 RUN'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 4755 8038 7646 RUR'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 9258 7513 6 TIAS'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 5663 9350 540 TIU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 0161 4530 10 TUA'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 6358 9764 150 TUD'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 4528 9748 456 TUE'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 9762 6150 TUK'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 6634 7173 0 UCR'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 2735 6509 1355 UL'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 2045 2808 14 UM'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 6341 6170 3 UT'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 0440 2982 10 UU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 7246 8587 8923 UVA'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 1714 3453 UVH'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 2487 5959 114 VU'),1);
  ASSERT_EQUALS(checkForCorrectness('NL 1087 6196 1850 WUR'),1);
END;
--opdracht C

BEGIN
  ASSERT_EQUALS(generateISIN('US','UOPX','816909877808647715885542447721'),'US 8169 0987 7808 6477 1588 5542 4477 2124 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','074795759770722298327778776676'),'US 0747 9575 9770 7222 9832 7778 7766 7618 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','637063404992150457666331979258'),'US 6370 6340 4992 1504 5766 6331 9792 5854 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','006986904436454238152799617042'),'US 0069 8690 4436 4542 3815 2799 6170 4236 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','747563384194517329142982182132'),'US 7475 6338 4194 5173 2914 2982 1821 3204 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','935769431817729045656997796217'),'US 9357 6943 1817 7290 4565 6997 7962 1748 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','106523035622674501572153494120'),'US 1065 2303 5622 6745 0157 2153 4941 2004 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','984821662810168324571387836256'),'US 9848 2166 2810 1683 2457 1387 8362 5604 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','611203363285790546322865716827'),'US 6112 0336 3285 7905 4632 2865 7168 2720 UOPX');
  ASSERT_EQUALS(generateISIN('US','UOPX','413656574238236164819073216380'),'US 4136 5657 4238 2361 6481 9073 2163 8016 UOPX');
END;
/
BEGIN
  ASSERT_EQUALS(checkForCorrectness('US 3021 9271 6933 9390 5593 2617 5745 0040 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 0572 1109 8708 7313 1702 5698 9849 8438 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 2461 9340 5386 6026 3492 8729 8769 8902 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 0740 0785 9222 1959 3508 4635 3587 0324 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 4101 7010 4800 4921 5877 4643 3367 3806 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 0063 1270 7538 4671 7929 8798 3436 7246 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 6746 0103 4216 4644 6227 7366 6947 8158 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 1162 5629 2824 2097 4176 3415 9462 7724 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 8698 5067 9756 5643 4867 9978 1103 4022 UOPX'),1);
  ASSERT_EQUALS(checkForCorrectness('US 1392 1860 3971 0426 0927 8935 0455 3232 UOPX'),1);
END;



-- DROP ALLE TABLES, FUNCTIES EN PROCEDURES WEER
DROP TABLE UNIVERSITY;
DROP TABLE COUNTRY;
DROP FUNCTION GENERATEISIN;
DROP FUNCTION CHECKFORCORRECTNESS;
DROP PROCEDURE ASSERT_EQUALS;