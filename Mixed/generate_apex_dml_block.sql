CREATE OR REPLACE FUNCTION DEVERP.generate_apex_dml_block(p_table_name IN VARCHAR2)
RETURN CLOB
IS
  v_pk_column    VARCHAR2(50);
  v_insert_cols  CLOB := '';
  v_insert_vals  CLOB := '';
  v_update_stmt  CLOB := '';
  v_code         CLOB := '';
  v_counter      NUMBER := 0;

-- Cursor for table coumn name
  CURSOR cur_columns IS
    SELECT COLUMN_NAME
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = UPPER(p_table_name)
    ORDER BY COLUMN_ID;

BEGIN
  -- Get primary key column
  BEGIN
    SELECT DISTINCT acc.COLUMN_NAME
    INTO v_pk_column
    FROM ALL_CONSTRAINTS ac,
         ALL_CONS_COLUMNS acc
    WHERE    ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
         AND ac.OWNER = acc.OWNER
         AND ac.TABLE_NAME = UPPER(p_table_name)
         AND ac.CONSTRAINT_TYPE = 'P';
  EXCEPTION
    WHEN OTHERS THEN
      v_pk_column := 'ID'; -- fallback
  END;

  -- Build insert and update components
  FOR rec IN cur_columns LOOP
    v_counter := v_counter + 1;

    -- Insert
    IF v_counter = 1 THEN
      v_insert_cols := rec.COLUMN_NAME;
      v_insert_vals := CASE WHEN rec.COLUMN_NAME = v_pk_column THEN
                              'Next_GEN_ID(''' || p_table_name || ''', ''' || v_pk_column || ''')'
                            ELSE
                              ':' || rec.COLUMN_NAME
                         END;
    ELSE
      v_insert_cols := v_insert_cols || ', ' || rec.COLUMN_NAME;
      v_insert_vals := v_insert_vals || ', ' || CASE WHEN rec.COLUMN_NAME = v_pk_column THEN
                              'Next_GEN_ID(''' || p_table_name || ''', ''' || v_pk_column || ''')'
                            ELSE
                              ':' || rec.COLUMN_NAME
                         END;
    END IF;

    -- Update (skip PK)
    IF rec.COLUMN_NAME != v_pk_column THEN
      v_update_stmt := v_update_stmt || rec.COLUMN_NAME || ' = :' || rec.COLUMN_NAME || ', ';
    END IF;
  END LOOP;

  v_update_stmt := RTRIM(v_update_stmt, ', ');

  -- Build full block
  v_code := v_code || 'BEGIN' || CHR(10);
  v_code := v_code || '  CASE :APEX$ROW_STATUS' || CHR(10);
  v_code := v_code || '    WHEN ''C'' THEN' || CHR(10);
  v_code := v_code || '      INSERT INTO ' || p_table_name || ' (' || v_insert_cols || ')' || CHR(10);
  v_code := v_code || '      VALUES (' || v_insert_vals || ');' || CHR(10);
  v_code := v_code || '    WHEN ''U'' THEN' || CHR(10);
  v_code := v_code || '      UPDATE ' || p_table_name || CHR(10);
  v_code := v_code || '      SET ' || v_update_stmt || CHR(10);
  v_code := v_code || '      WHERE ' || v_pk_column || ' = :' || v_pk_column || ';' || CHR(10);
  v_code := v_code || '  END CASE;' || CHR(10);
  v_code := v_code || 'END;';

  RETURN v_code;
END generate_apex_dml_block;
/
