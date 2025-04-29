CREATE OR REPLACE PROCEDURE DEVERP.INSERT_INTO_SUPPLIER_TBL(P_ERR out varchar2) IS
--DECLARE
--P_ERR VARCHAR2(100);

--QUERY FROM XLSX UPLOADE TABLE--
CURSOR CUR_EMP_INFO IS

SELECT DISTINCT SX.SUPPLIER_ID,
         SX.SUPPLIER_NAME,
         SX.SUP_ADD_1,
         SX.CELL_NO,
         SX.SUP_PHONE,
         SX.SUP_E_MAIL,
         SX.CONT_PERSON,
         SX.GROUP_NO,
         DEKKO_REF, --SX.REFERENCE
         SX.FAX,
         SX.SHORT_NAME,
         SX.LEADING_DAY,
         O.PID AS ORIGIN_ID,   --SX.ORIGIN_ID
         D.PORT_ID AS PORT_ID,
         INCO3.ID as ITEM, --SX.ITEM
         SX.NOTE,
         SX.GRADE,
         SX.MILLS_NAME,
         SX.PARTNARS,
         SX.PROVINCE,
         SX.FACTORY_ADD,
         SX.CORE_PROD,
         SX.STATUS,
         SX.RANKING,
         SX.DESIGNATION,
         SX.STREET,
         SX.HOUSE_NO,
         SX.AREA,
         SX.CITY,
         SX.POSTAL_CODE,
         SX.TIN_NO,
         SX.BIN_NO,
         SX.TRADE_NO,
         SX.ACCOUNT_NO,
         SX.ACCOUNT_NAME,
         SX.ROUTING_NO,
         B.PID AS BANK_NAME, --SX.BANK_NAME
         BB.PID AS BANK_BRANCH_ID, --SX.BANK_BRANCH_ID
         T.ID AS TENOR_ID, --SX.TENOR_ID
         PM.PAYMENT_MODE_ID AS PAYMODE, --SX.PAYMODE
         PTT.PAYMENT_TERM_NO AS PAY_TERM, --SX.PAY_TERM
         CASE WHEN UPPER(SX.SOURCE) = 'LOCAL' THEN 'L'
              WHEN UPPER(SX.SOURCE) = 'FOREIGN' THEN 'F'
              WHEN UPPER(SX.SOURCE) = 'WITHIN-GROUP' THEN 'W'
         ELSE NULL
         END AS SOURCE,
         SX.ACCEPT_TYPE,
         CASE WHEN UPPER(SX.QC_REQUIRED) = 'NO' THEN 0
              WHEN UPPER(SX.QC_REQUIRED) = 'YES' THEN 1
         ELSE NULL
         END AS QC_REQUIRED, --SX.QC_REQUIRED
         INCO2.ID DEL_MODE, --SX.DEL_MODE
         PT.port_id AS DEST_PORT, --SX.DEST_PORT
         INCO.ID AS INCOTERM_ID, --SX.INCOTERM_ID
         PT.port_id AS INCOTERM_PLACE, --SX.INCOTERM_PLACE
         SX.REPORTING_ADDRESS,
         SX.REPORTING_NAME,
         SX.REPORTING_CONTACT,
         ST.ID SUPPLIER_TYPE, --SX.SUPPLIER_TYPE
         CASE WHEN UPPER(SX.IS_SUPP_LISTED) = 'UNLISTED' THEN 'U'
              WHEN UPPER(SX.IS_SUPP_LISTED) = 'ENLISTED' THEN 'L'
         ELSE NULL
         END AS IS_SUPP_LISTED,         --SX.IS_SUPP_LISTED
         SX.DISPLAY_SERIAL
    FROM SUPPLIER_TBL_XL SX,
         ORIGIN O,
         BANK B,
         port_tbl D,
         BANKBRANCH BB,
         TENORS T,
         (SELECT NAME, ID FROM REFERENCES WHERE KEY = 'PAYMENT_MODE') INCO,
         (SELECT NAME, ID FROM REFERENCES WHERE KEY = 'DELIVERY_MODE') INCO2,
         payment_mode PM,
         PAYMENT_TERM_TBL PTT,
         port_tbl PT,
         supplier_types ST,
         (select Name,Id from REFERENCES where key = 'ITEM_REF') INCO3
WHERE TRIM(UPPER(SX.ORIGIN_ID)) = TRIM(UPPER(O.ORIGIN_NAME(+))) --SX.ORIGIN_ID VARCHAR2
AND TRIM(UPPER(SX.BANK_NAME)) = TRIM(UPPER(B.BANK_NAME(+))) --BOOTH ARE VARCHAR2 COL
AND TRIM(UPPER(SX.PORT_ID)) = TRIM(UPPER(D.PORT_NAME(+))) --SX.PORT_ID VARCHAR2 
AND TRIM(UPPER(SX.BANK_BRANCH_ID)) = TRIM(UPPER(BB.BANK_BRANCH_NAME(+))) --SX.BANK_BRANCH_ID VARCHAR2
AND TRIM(UPPER(SX.TENOR_ID)) = TRIM(UPPER(T.NAME(+))) --SX.TENOR_ID VARCHAR2
AND TRIM(UPPER(SX.INCOTERM_ID)) = TRIM(UPPER(INCO.NAME(+))) --SX.INCOTERM_ID VARCHAR2
AND TRIM(UPPER(SX.PAYMODE)) = TRIM(UPPER(PM.PAYMENT_MODE_NAME(+)))
AND TRIM(UPPER(SX.PAY_TERM)) = TRIM(UPPER(PTT.PAYMENT_TERM_NAME(+)))
AND TRIM(UPPER(SX.INCOTERM_PLACE)) = TRIM(UPPER(PT.port_name(+)))
AND TRIM(UPPER(SX.DEL_MODE)) = TRIM(UPPER(INCO2.NAME(+)))
AND TRIM(UPPER(SX.SUPPLIER_TYPE)) = TRIM(UPPER(ST.NAME(+)))
AND TRIM(UPPER(SX.ITEM)) = TRIM(UPPER(INCO3.NAME(+)))
ORDER BY SX.SUPPLIER_ID;

V_ROW_COUNT NUMBER := 0;
V_SUPPLIER_ID NUMBER;
V_DUPLICATE_SUPPLIER NUMBER(10);

BEGIN
  -- Generate Supplier ID
  SELECT NVL(MAX(SUPPLIER_ID), 0) + 1
  INTO V_SUPPLIER_ID
  FROM SUPPLIER_TBL;

  -- Check Duplicate Supplier Name
  BEGIN
    SELECT count(1)
    INTO V_DUPLICATE_SUPPLIER
    FROM SUPPLIER_TBL ST, 
         SUPPLIER_TBL_XL STX
    WHERE TRIM(UPPER(ST.SUPPLIER_NAME)) = TRIM(UPPER(STX.SUPPLIER_NAME));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_DUPLICATE_SUPPLIER := 0;
  END;

  IF V_DUPLICATE_SUPPLIER = 0 THEN
    FOR REC IN CUR_EMP_INFO LOOP
      BEGIN
 --INSERT INTO BASE TABLE--
 INSERT INTO SUPPLIER_TBL (
                SUPPLIER_ID,
                SUPPLIER_NAME,
                SUP_ADD_1,
                CELL_NO,
                SUP_PHONE,
                SUP_E_MAIL,
                CONT_PERSON,
                GROUP_NO,
                DEKKO_REF,
                FAX,
                SHORT_NAME,
                LEADING_DAY,
                ORIGIN_ID,
                PORT_ID,
                ITEM,
                NOTE,
                GRADE,
                MILLS_NAME,
                PARTNARS,
                PROVINCE,
                FACTORY_ADD,
                CORE_PROD,
                STATUS,
                RANKING,
                DESIGNATION,
                STREET,
                HOUSE_NO,
                AREA,
                CITY,
                POSTAL_CODE,
                TIN_NO,
                BIN_NO,
                TRADE_NO,
                ACCOUNT_NO,
                ACCOUNT_NAME,
                ROUTING_NO,
                BANK_ID,
                BANK_BRANCH_ID,
                TENOR_ID,
                PAYMODE,
                PAY_TERM,
                SOURCE,
                ACCEPT_TYPE,
                QC_REQUIRED,
                DEL_MODE,
                DEST_PORT,
                INCOTERM_ID,
                INCOTERM_PLACE,
                REPORTING_ADDRESS,
                REPORTING_NAME,
                REPORTING_CONTACT,
                SUPPLIER_TYPE,
                ACTIVE_IND,
                IS_SUPP_LISTED,
                DISPLAY_SERIAL)
            VALUES (
                V_SUPPLIER_ID,
                REC.SUPPLIER_NAME,
                REC.SUP_ADD_1,
                REC.CELL_NO,
                REC.SUP_PHONE,
                REC.SUP_E_MAIL,
                REC.CONT_PERSON,
                REC.GROUP_NO,
                REC.DEKKO_REF,
                REC.FAX,
                REC.SHORT_NAME,
                REC.LEADING_DAY,
                REC.ORIGIN_ID,
                REC.PORT_ID,
                REC.ITEM,
                REC.NOTE,
                REC.GRADE,
                REC.MILLS_NAME,
                REC.PARTNARS,
                REC.PROVINCE,
                REC.FACTORY_ADD,
                REC.CORE_PROD,
                REC.STATUS,
                REC.RANKING,
                REC.DESIGNATION,
                REC.STREET,
                REC.HOUSE_NO,
                REC.AREA,
                REC.CITY,
                REC.POSTAL_CODE,
                REC.TIN_NO,
                REC.BIN_NO,
                REC.TRADE_NO,
                REC.ACCOUNT_NO,
                REC.ACCOUNT_NAME,
                REC.ROUTING_NO,
                REC.BANK_NAME,
                REC.BANK_BRANCH_ID,
                REC.TENOR_ID,
                REC.PAYMODE,
                REC.PAY_TERM,
                REC.SOURCE,
                REC.ACCEPT_TYPE,
                REC.QC_REQUIRED,
                REC.DEL_MODE,
                REC.DEST_PORT,
                REC.INCOTERM_ID,
                REC.INCOTERM_PLACE,
                REC.REPORTING_ADDRESS,
                REC.REPORTING_NAME,
                REC.REPORTING_CONTACT,
                REC.SUPPLIER_TYPE,
                1,
                REC.IS_SUPP_LISTED,
                REC.DISPLAY_SERIAL);
                commit;

       V_ROW_COUNT := V_ROW_COUNT + 1;
        V_SUPPLIER_ID := V_SUPPLIER_ID + 1;
      EXCEPTION
        WHEN OTHERS THEN
          P_ERR := SQLERRM;
           DBMS_OUTPUT.PUT_LINE(SQLERRM);
      END;
    END LOOP;

IF V_ROW_COUNT > 0 THEN
      DELETE FROM SUPPLIER_TBL_XL;
      COMMIT;
      DBMS_OUTPUT.PUT_LINE(V_ROW_COUNT || ' rows inserted');
    ELSE
     DBMS_OUTPUT.PUT_LINE('No rows inserted');
    END IF;
  ELSE
    P_ERR := 'Duplicate Supplier Name Found.';
  END IF;

END INSERT_INTO_SUPPLIER_TBL;
/
