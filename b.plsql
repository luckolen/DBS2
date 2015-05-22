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

  RETURN 1;
END;
/
