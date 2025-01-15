-- Exercise 1: Using Joins

-- Question 1
-- •	Write and execute a SQL query to list the school names, community names and average attendance for communities with a hardship index of 98.
SELECT b.NAME_OF_SCHOOL, b.COMMUNITY_AREA_NAME, b.AVERAGE_STUDENT_ATTENDANCE
FROM chicago_socioeconomic_data a 
LEFT JOIN chicago_public_schools b
ON a.COMMUNITY_AREA_NUMBER = b.COMMUNITY_AREA_NUMBER
WHERE a.HARDSHIP_INDEX = '98';

-- Question 2
-- •	Write and execute a SQL query to list all crimes that took place at a school. Include case number, crime type and community name.
SELECT b.CASE_NUMBER, b.PRIMARY_TYPE, a.COMMUNITY_AREA_NAME
FROM chicago_socioeconomic_data AS a
LEFT JOIN chicago_crime AS b
ON a.COMMUNITY_AREA_NUMBER = b.COMMUNITY_AREA_NUMBER
WHERE b.LOCATION_DESCRIPTION LIKE "%SCHOOL%";

-- Exercise 2: Creating a View

-- Question 1
-- •	Write and execute a SQL statement to create a view showing the columns listed in the following table, with new column names.
CREATE VIEW PRIVATE_VIEW AS
SELECT NAME_OF_SCHOOL AS School_Name,
Safety_Icon AS Safety_Rating,
Family_Involvement_Icon AS Family_Rating,
Environment_Icon AS Environment_Rating,
Instruction_Icon AS Instruction_Rating,
Leaders_Icon AS Leaders_Rating,
Teachers_Icon AS Teachers_Rating
FROM chicago_public_schools;
-- •	Write and execute a SQL statement that returns all of the columns from the view.
SELECT * 
FROM PRIVATE_VIEW;
-- •	Write and execute a SQL statement that returns just the school name and leaders rating from the view.
SELECT School_Name, Leaders_Rating 
FROM PRIVATE_VIEW;

-- Exercise 3: Creating a Stored Procedure

-- Question 1
-- •	Write the structure of a query to create or replace a stored procedure called UPDATE_LEADERS_SCORE that takes a in_School_ID parameter as an integer and a in_Leader_Score parameter as an integer.
-- Question 2
-- •	Inside your stored procedure, write a SQL statement to update the Leaders_Score field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID to the value in the in_Leader_Score parameter.
-- Question 3
-- •	Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID.
DELIMITER @

CREATE PROCEDURE UPDATE_LEADERS_SCORE(IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)

BEGIN
  UPDATE chicago_public_schools
  SET Leaders_Score = in_Leader_Score
  WHERE School_ID = in_School_ID;

  IF in_Leader_Score > 0 AND in_Leader_Score < 20 THEN
    UPDATE chicago_public_schools
    SET Leaders_Icon = 'Very weak'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 40 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Weak'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 60 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Average'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 80 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Strong'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 100 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Very strong'
    WHERE School_ID = in_School_ID;
  END IF;
END @

DELIMITER ;

-- Question 4
-- •	Run your code to create the stored procedure.
-- •	Write a query to call the stored procedure, passing a valid school ID and a leader score of 50, to check that the procedure works as expected.
CALL UPDATE_LEADERS_SCORE(400018, 50);

-- Exercise 4: Using Transactions

-- Question 1
-- •	Update your stored procedure definition. Add a generic ELSE clause to the IF statement that rolls back the current work if the score did not fit any of the preceding categories.
-- Question 2
-- •	Update your stored procedure definition again. Add a statement to commit the current unit of work at the end of the procedure.
-- •	Run your code to replace the stored procedure.
DELIMITER @

CREATE PROCEDURE UPDATE_LEADERS_SCORE(IN in_School_ID INTEGER, IN in_Leader_Score INTEGER)

BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  UPDATE chicago_public_schools
  SET Leaders_Score = in_Leader_Score
  WHERE School_ID = in_School_ID;

  IF in_Leader_Score > 0 AND in_Leader_Score < 20 THEN
    UPDATE chicago_public_schools
    SET Leaders_Icon = 'Very weak'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 40 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Weak'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 60 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Average'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 80 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Strong'
    WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 100 THEN
    UPDATE chicago_public_schools 
    SET Leaders_Icon = 'Very strong'
    WHERE School_ID = in_School_ID;
  ELSE 
    ROLLBACK WORK;
  END IF;
  COMMIT WORK;
END @

DELIMITER ;
-- •	Write and run one query to check that the updated stored procedure works as expected when you use a valid score of 38.
CALL UPDATE_LEADERS_SCORE(400018, 38)
-- •	Write and run another query to check that the updated stored procedure works as expected when you use an invalid score of 101.
CALL UPDATE_LEADERS_SCORE(400018, 101);