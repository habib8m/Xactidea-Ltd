DECLARE
    v_sysdate varchar2(150) := to_char(sysdate, 'DD-MM-YYYY'); --nvl(:P190004_PRINT_DATE,' ');
    -- Master cursor
    CURSOR cur_master IS
        SELECT div.division_id,
               div.division_name, 
               dep.DEPT_NO,
               dep.DEPT_NAME,
               sec.SECTION_ID,
               sec.SECTION_NAME
        FROM gbl_division div, 
             gbl_division_dtls dtl,
             DEPT_TBL dep,
             gbl_section sec
        WHERE div.active_ind = 'Y'
          AND div.division_id = dtl.division_id(+)
          AND div.DIVISION_ID = dep.DIVISION_ID(+)
          AND dep.DEPT_NO = sec.DEPARTMENT_ID(+)
          AND dtl.company_id = :P1536_COMPANY_1
          AND dtl.location_id = :P1536_LOCATION
          AND (:P1536_DIVISION IS NULL OR INSTR(':' || :P1536_DIVISION || ':', ':' || div.division_id || ':') > 0)
          AND (:P1536_DEPARTMENT IS NULL OR INSTR(':' || :P1536_DEPARTMENT || ':', ':' || dep.DEPT_NO || ':') > 0)
          AND (:P1536_SECTION_1 IS NULL OR INSTR(':' || :P1536_SECTION_1 || ':', ':' || sec.SECTION_ID || ':') > 0)
          order by div.division_id, dep.DEPT_NO, sec.SECTION_ID
          ;

    -- Detail cursor
    CURSOR cur_detail(p_division_id NUMBER, p_department_id NUMBER, p_section_id NUMBER) IS
        SELECT he.EMPLOYEE_ID,
               he.AUTO_FORMATED_ID, 
               he.MANUALLY_FORMATTED_ID,
               he.FIRST_NAME,
               to_char(he.JOINING_DATE, 'dd/mm/yyyy') as JOINING_DATE,
               nvl(to_char(he.GROSS_SALARY, '99,99,99,999'), 0) as GROSS_SALARY,
               dt.DESIG_NAME,
               he.PUNCH_CARD_NO
        FROM HRM_EMPLOYEE he,
             GBL_DIVISION div,
             DEPT_TBL dpt,
             gbl_section gsec,
             DESIG_TBL dt
        WHERE he.current_division_id = div.division_id(+)
          AND div.DIVISION_ID = NVL(p_division_id, div.DIVISION_ID)
          AND he.current_dept_id = dpt.dept_no(+)
          AND dpt.DEPT_NO = NVL(p_department_id, dpt.DEPT_NO)
          AND he.current_section_id = gsec.section_id(+)
          AND gsec.SECTION_ID = NVL(p_section_id, gsec.SECTION_ID)
          AND he.CURRENT_DESIG_ID = dt.DESIG_ID(+)
          AND he.JOINING_DATE BETWEEN to_date(:P1536_FROM_DATE, 'dd/mm/yyyy') 
                              AND to_date(:P1536_TO_DATE, 'dd/mm/yyyy');

    -- Variables
    v_sl NUMBER := 0;
    v_emp_total NUMBER := 0;
    v_grand_total NUMBER := 0;
    v_company VARCHAR2(200);
    v_location VARCHAR2(500);
    v_last_division_id NUMBER := NULL; 
    
    --variable for date pate paremetter
    v_from_date date;

BEGIN
    htp.p('<div id="printArea">');
    htp.p('
    <style>
        #m-table {
            width: 90%;
            margin: 10px auto;
            border-collapse: collapse;
        }
        #m-table th,
        #m-table td {
            border: 1px solid #ddd;
            text-align: center;
            padding: 5px;
        }
        #m-table th {
            font-weight: bold;
        }
        #printArea {
            margin: 10px;
        }
         @page{
                    @bottom-right {
                        content: "'||v_sysdate||'";
                        margin-bottom: 20px!important;
                    }
                }
    </style>
    ');

    -- Retrieve Company Name
    BEGIN
        SELECT UNIT_NAME
        INTO v_company
        FROM UNIT_DEPT_TBL
        WHERE UNIT_DEPT_NO = :P1536_COMPANY_1;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            v_company := '';
    END;

    -- Retrieve Location Name
    BEGIN
        SELECT m.location_name || ' - ' || m.add_location
        INTO v_location
        FROM gbl_company_locations m,
             gbl_company_locations_dtls d
        WHERE d.location_id = m.id
          AND d.company_id = :P1536_COMPANY_1
          AND m.id = :P1536_LOCATION;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            v_location := '';
    END;

    -- Loop through divisions
    FOR rec_master IN cur_master LOOP
        v_sl := 0;
        v_emp_total := 0;

        -- Check if the division header needs to be displayed
        IF v_last_division_id IS NULL OR v_last_division_id != rec_master.division_id THEN
            v_last_division_id := rec_master.division_id;

            -- Division-specific header
            htp.p('<h3 style="text-align:center; margin: 0px">' || v_company || '</h3>');
            htp.p('<h4 style="text-align:center; margin:0px;">' || rec_master.division_name || '</h4>');
            htp.p('<h5 style="text-align:center; margin:0px">' || v_location || '</h5>');
            htp.p('<hr style="height:1px; background-color:gray; width: 90%; margin: 10px auto;">');
            htp.p('<h4 style="font-weight:900; text-decoration:underline; text-align:center">Joining Report</h4>');
            htp.p('<h4 style="text-align:center; margin:0px"><span>From: ' || :P1536_FROM_DATE || '&nbsp </span>&nbsp;&nbsp;&nbsp;&nbsp;<span>To: ' || :P1536_TO_DATE || '</span></h4>');
        END IF;

        -- Department and Section Information
        htp.p('<h5 style="text-align:left; width: 90%; margin: 10px auto;">Department &nbsp &nbsp &nbsp: &nbsp' || rec_master.DEPT_NAME || '</h5>');
        htp.p('<h5 style="text-align:left; width: 90%; margin: 10px auto;">Section &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp: &nbsp' || rec_master.SECTION_NAME || '</h5>');

        -- Start table
        htp.p('<div style="text-align:center;">');
        htp.p('
            <table id="m-table">
                <tr>
                    <th style="width:5%">SL</th>
                    <th style="text-align:left; width:10%">Emp.No.</th>
                    <th style="width:10%">Face ID</th>
                    <th style="width:25%; text-align:left;">Name</th>
                    <th style="width:20%; text-align:left;">Designation</th>
                    <th style="width:15%">Join Date</th>
                    <th style="width:15%">Gross</th>
                </tr>
        ');

        -- Loop through employees
        FOR rec_detail IN cur_detail(rec_master.division_id, rec_master.DEPT_NO, rec_master.SECTION_ID) LOOP
            v_sl := v_sl + 1;
            v_emp_total := v_emp_total + 1;
            v_grand_total := v_grand_total + 1;

            htp.p('
                <tr>
                    <td style="width:5%">' || v_sl || '</td>
                    <td style="text-align:left; width:10%">' || rec_detail.MANUALLY_FORMATTED_ID || '</td>
                    <td style="width:10%">' || rec_detail.PUNCH_CARD_NO || '</td>
                    <td style="width:25%; text-align:left;">' || rec_detail.FIRST_NAME || '</td>
                    <td style="width:20%; text-align:left;">' || rec_detail.DESIG_NAME || '</td>
                    <td style="width:15%">' || rec_detail.JOINING_DATE || '</td>
                    <td style="width:15%">' || rec_detail.GROSS_SALARY || '</td>
                </tr>
            ');
        END LOOP;

        -- Total for the department/section
        htp.p('
            <tr>
                <th>Total</th>
                <th>' || v_emp_total || '</th>
                <th colspan="5"></th>
            </tr>
        ');

        htp.p('</table>');
        htp.p('</div>');
    END LOOP;

    -- Grand total
    htp.p('
        <div style="text-align:left; width: 90%; margin: 10px auto;">
            <h4>
                <span style="border: 1px solid gray; padding: 5px; width: 17%; display: inline-block; font-weight: bold;">Grand Total:</span>
                &nbsp;&nbsp;
                <span style="border: 1px solid gray; padding: 5px; width: 15%; display: inline-block; font-weight: bold;">' || v_grand_total || '</span>
            </h4>
        </div>
    ');

    htp.p('</div>');
END;
