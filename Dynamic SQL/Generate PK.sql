
--Next_ID--

CREATE OR REPLACE FUNCTION DEVERP.Next_ID(P_Table VARCHAR2)
 RETURN NUMBER
IS
    V_ID NUMBER;
BEGIN
    Execute Immediate 'SELECT nvl(Max(ID),0)+1 FROM '||P_Table INTO V_ID;
    Return V_ID;
END;
/

--Next_form_id--

CREATE OR REPLACE FUNCTION DEVERP.NEXT_FORM_ID(P_Table VARCHAR2)
 RETURN NUMBER
IS
    V_ID NUMBER;
BEGIN
    Execute Immediate 'SELECT nvl(Max(FORM_ID),0)+1 FROM '||P_Table INTO V_ID;
    Return V_ID;
END;
/

--***Next_gen_id***--
CREATE OR REPLACE FUNCTION DEVERP.Next_GEN_ID(P_Table VARCHAR2, P_COLUMN VARCHAR2)
 RETURN NUMBER
IS
    V_ID NUMBER;
BEGIN
    Execute Immediate 'SELECT nvl(Max('|| P_COLUMN ||'), 0) + 1 FROM '||P_Table INTO V_ID;
    Return V_ID;
END;
/

--Next_PID--
create or replace FUNCTION Next_PID(P_Table VARCHAR2)
 RETURN NUMBER
IS
    V_ID NUMBER;
BEGIN
    Execute Immediate 'SELECT nvl(Max(PID),0)+1 FROM '||P_Table INTO V_ID;
    Return V_ID;
END;
