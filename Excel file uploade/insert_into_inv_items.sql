CREATE OR REPLACE PROCEDURE DEVERP.insert_into_inv_items IS

--DECLARE
   -- Cursor to fetch distinct items from source table
   CURSOR cur_items
   IS
        SELECT *
          FROM (SELECT IIX.id,
                       IIX.NAME,                                  -- Item name
                       IC.ID AS CATEGORY,
                       SC.ID AS SUBCATE,
                       U.ID AS UNIT,                                   -- Unit
                       iix.unit_id,
                       IIX.CODE_NO,
                       IIX.POPULAR_NAME,
                       IIX.HS_CODE,
                       IIX.AIT_PER,                                     -- AIT
                       IIX.VAT_PER,                                     -- VAT
                       IIX.MIN_ORDER_QTY,
                       IIX.MAX_ORDER_QTY,
                       IIX.MATERIAL_TYPE,                   -- Material nature
                       IIX.AT1,
                       IIX.AT2,
                       IIX.AT3,
                       IIX.AT4,
                       IIX.AT5,
                       IIX.AT6,
                       IIX.AT7,
                       IIX.AT8,
                       IIX.AT9,
                       IIX.AT10,
                       IIX.V1,
                       IIX.V2,
                       IIX.V3,
                       IIX.V4,
                       IIX.V5,
                       IIX.V6,
                       IIX.V7,
                       IIX.V8,
                       IIX.V9,
                       IIX.V10
                  FROM INV_ITEMS_XL IIX,
                       UNITS U,
                       INV_CATEGORIES IC,
                       INV_GROUPS SC
                 WHERE     UPPER (TRIM (IIX.UNIT_ID)) =
                              UPPER (TRIM (U.SHORT_NAME(+)))
                       AND UPPER (TRIM (IIX.CATEGORY_ID)) =
                              UPPER (TRIM (IC.NAME(+)))
                       AND UPPER (TRIM (IIX.SUBCAT_ID)) =
                              UPPER (TRIM (SC.NAME(+)))
                       AND IC.ID = SC.CAT_ID(+)
                       and U.ID is not null
                       and IC.ID is not null
                       AND NOT EXISTS
                                  (SELECT 1
                                     FROM inv_items ii
                                    WHERE UPPER (TRIM (ii.name)) =
                                             UPPER (TRIM (IIX.name))))
      ORDER BY NAME ASC;

   -- Variable declarations
   v_master_exists    NUMBER := 0;
   v_inv_id           NUMBER := 0;
   v_ts_id            NUMBER := 0;
   v_item_name        VARCHAR2 (100);
   v_unit_id          VARCHAR2 (100);                                --add new
   v_concat_st        VARCHAR2 (500); -- Concatenated string for specifications
   v_technical_sp     NUMBER := 0;
   v_exist_item_id    NUMBER := 0;
   v_insert_success   BOOLEAN := FALSE;
   v_last_unit_id     VARCHAR2 (100) := 'N/A';
   v_last_item        VARCHAR2 (100) := 'N/A';
--   type item_name is table of number index by pls_integer;
BEGIN
   FOR rec_items IN cur_items
   LOOP
      v_concat_st :=
            CASE
               WHEN rec_items.AT1 IS NOT NULL
               THEN
                  rec_items.AT1 || ': ' || rec_items.V1
            END
         || CASE
               WHEN rec_items.AT2 IS NOT NULL
               THEN
                  ', ' || rec_items.AT2 || ': ' || rec_items.V2
            END
         || CASE
               WHEN rec_items.AT3 IS NOT NULL
               THEN
                  ', ' || rec_items.AT3 || ': ' || rec_items.V3
            END
         || CASE
               WHEN rec_items.AT4 IS NOT NULL
               THEN
                  ', ' || rec_items.AT4 || ': ' || rec_items.V4
            END
         || CASE
               WHEN rec_items.AT5 IS NOT NULL
               THEN
                  ', ' || rec_items.AT5 || ': ' || rec_items.V5
            END
         || CASE
               WHEN rec_items.AT6 IS NOT NULL
               THEN
                  ', ' || rec_items.AT6 || ': ' || rec_items.V6
            END
         || CASE
               WHEN rec_items.AT7 IS NOT NULL
               THEN
                  ', ' || rec_items.AT7 || ': ' || rec_items.V7
            END
         || CASE
               WHEN rec_items.AT8 IS NOT NULL
               THEN
                  ', ' || rec_items.AT8 || ': ' || rec_items.V8
            END
         || CASE
               WHEN rec_items.AT9 IS NOT NULL
               THEN
                  ', ' || rec_items.AT9 || ': ' || rec_items.V9
            END
         || CASE
               WHEN rec_items.AT10 IS NOT NULL
               THEN
                  ', ' || rec_items.AT10 || ': ' || rec_items.V10
            END;

      IF v_last_item != rec_items.name
      -- AND v_last_unit_id != rec_items.unit_id
      THEN
         v_inv_id := next_id ('INV_ITEMS');

         INSERT INTO INV_ITEMS (ID,
                                NAME,
                                CATEGORY_ID,
                                SUBCAT_ID,
                                UNIT_ID,
                                CODE_NO,
                                POPULAR_NAME,
                                HS_CODE,
                                AIT_PER,
                                VAT_PER,
                                MIN_ORDER_QTY,
                                MAX_ORDER_QTY,
                                MATERIAL_TYPE,
                                AT1,
                                AT2,
                                AT3,
                                AT4,
                                AT5,
                                AT6,
                                AT7,
                                AT8,
                                AT9,
                                AT10,
                                PACK_UNIT_ID,
                                UNIT_CONVERTION)
              VALUES (v_inv_id,
                      rec_items.name,
                      rec_items.CATEGORY,
                      rec_items.SUBCATE,
                      rec_items.UNIT,
                      rec_items.CODE_NO,
                      rec_items.POPULAR_NAME,
                      rec_items.HS_CODE,
                      rec_items.AIT_PER,
                      rec_items.VAT_PER,
                      rec_items.MIN_ORDER_QTY,
                      rec_items.MAX_ORDER_QTY,
                      rec_items.MATERIAL_TYPE,
                      rec_items.AT1,
                      rec_items.AT2,
                      rec_items.AT3,
                      rec_items.AT4,
                      rec_items.AT5,
                      rec_items.AT6,
                      rec_items.AT7,
                      rec_items.AT8,
                      rec_items.AT9,
                      rec_items.AT10,
                      rec_items.UNIT,
                      1);

                      --v_insert_success := true;

         v_ts_id := next_id ('INV_TECHNICAL_SPECIFICATIONS'); -- Generate next PK value

         INSERT INTO INV_TECHNICAL_SPECIFICATIONS (ID,
                                                   ITEM_ID,
                                                   TECHNICAL_SPECIFICATION,
                                                   AT_V1,
                                                   AT_V2,
                                                   AT_V3,
                                                   AT_V4,
                                                   AT_V5,
                                                   AT_V6,
                                                   AT_V7,
                                                   AT_V8,
                                                   AT_V9,
                                                   AT_V10,
                                                   XL_SL_NO)
              VALUES (v_ts_id,
                      v_inv_id,
                      v_concat_st,
                      rec_items.V1,
                      rec_items.V2,
                      rec_items.V3,
                      rec_items.V4,
                      rec_items.V5,
                      rec_items.V6,
                      rec_items.V7,
                      rec_items.V8,
                      rec_items.V9,
                      rec_items.V10,
                      0);

         v_last_item := rec_items.name;
         v_last_unit_id := rec_items.unit_id;
         COMMIT;
      ELSIF v_last_item = rec_items.name
      --AND v_last_unit_id = rec_items.unit_id
      THEN
         SELECT unit_id
           INTO v_last_unit_id
           FROM inv_items
          WHERE id = v_inv_id;

         IF v_last_unit_id = rec_items.unit
         THEN
            v_ts_id := next_id ('INV_TECHNICAL_SPECIFICATIONS'); -- Generate next PK value

            INSERT
              INTO INV_TECHNICAL_SPECIFICATIONS (ID,
                                                 ITEM_ID,
                                                 TECHNICAL_SPECIFICATION,
                                                 AT_V1,
                                                 AT_V2,
                                                 AT_V3,
                                                 AT_V4,
                                                 AT_V5,
                                                 AT_V6,
                                                 AT_V7,
                                                 AT_V8,
                                                 AT_V9,
                                                 AT_V10,
                                                 XL_SL_NO)
            VALUES (v_ts_id,
                    v_inv_id,
                    v_concat_st,
                    rec_items.V1,
                    rec_items.V2,
                    rec_items.V3,
                    rec_items.V4,
                    rec_items.V5,
                    rec_items.V6,
                    rec_items.V7,
                    rec_items.V8,
                    rec_items.V9,
                    rec_items.V10,
                    2);
            COMMIT;           
            
            -- v_insert_success := true;

         END IF;
            v_last_item := rec_items.name;
            --v_last_unit_id := rec_items.unit_id;
      END IF;
   END LOOP;
 
   DELETE FROM INV_ITEMS_XL;
   COMMIT;

EXCEPTION
   WHEN OTHERS
   THEN
      --NULL;
      DBMS_OUTPUT.PUT_LINE ('Error occurred: ' || SQLERRM);
END;
/
