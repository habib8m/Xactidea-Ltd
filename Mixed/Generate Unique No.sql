SELECT 'AS' || TO_CHAR(SYSDATE, 'YYMM') || 
       LPAD(NVL(MAX(TO_NUMBER(SUBSTR(ASSESSMENT_NO, -4))), 0) + 1, 4, '0') AS NEXT_ASSESSMENT_NO
       into :P1757_ASSESSMENT_NO
FROM HRM_ASSESSMENT_SETUP
WHERE SUBSTR(ASSESSMENT_NO, 3, 4) = TO_CHAR(SYSDATE, 'YYMM');


-- Make function for generate unique number
CREATE OR REPLACE FUNCTION DEVERP.qnique_no_generate (
    p_table   VARCHAR2,
    p_column  VARCHAR2,
    p_concat  VARCHAR2
) RETURN VARCHAR2
IS
    v_sql     VARCHAR2(1000);
    v_value   VARCHAR2(500);
    v_max_val NUMBER;
BEGIN
    -- Build dynamic SQL to find the maximum value
    v_sql := 'SELECT NVL(MAX(TO_NUMBER(SUBSTR(' || p_column || ', 7))), 0) FROM ' || p_table ||
             ' WHERE SUBSTR(' || p_column || ', 3, 4) = :1';

    -- Execute dynamic SQL
    EXECUTE IMMEDIATE v_sql INTO v_max_val USING TO_CHAR(SYSDATE, 'YYMM');

    -- Generate the unique number
    v_value := p_concat
               || TO_CHAR(SYSDATE, 'YYMM')
               || LPAD(v_max_val + 1, 4, '0');

    RETURN v_value;
END;
/
