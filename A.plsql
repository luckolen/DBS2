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