DECLARE
    v_sysdate VARCHAR2(150) := nvl(TO_CHAR(:P1594_PRINT_DATE, 'DD-MM-YYYY'),' '); 
    -- Master cursor (Division & Department)
    CURSOR cur_master IS
        SELECT div.division_id,
               div.division_name, 
               dep.DEPT_NO,
               dep.DEPT_NAME
        FROM gbl_division div, 
             gbl_division_dtls dtl,
             DEPT_TBL dep
        WHERE div.active_ind = 'Y'
          AND div.division_id = dtl.division_id(+)
          AND div.DIVISION_ID = dep.DIVISION_ID(+)
          AND dtl.company_id = :P1594_COMPANY_1
          AND dtl.location_id = :P1594_LOCATION
          AND (:P1594_DIVISION IS NULL OR INSTR(':' || :P1594_DIVISION || ':', ':' || div.division_id || ':') > 0)
          AND (:P1594_DEPARTMENT IS NULL OR INSTR(':' || :P1594_DEPARTMENT || ':', ':' || dep.DEPT_NO || ':') > 0)
        ORDER BY div.division_id, dep.DEPT_NO;

    -- Detail cursor (Employees under a department)
    CURSOR cur_detail(p_division_id NUMBER, p_department_id NUMBER) IS
        SELECT he.EMPLOYEE_ID,
               he.AUTO_FORMATED_ID, 
               he.MANUALLY_FORMATTED_ID,
               he.FIRST_NAME,
               TO_CHAR(he.JOINING_DATE, 'dd/mm/yyyy') AS JOINING_DATE,
               to_char(sep.APPLICATION_DATE, 'dd/mm/yyyy') as notice_date,
               to_char(sep.EFFECTIVE_FROM, 'dd/mm/yyyy') as resign_date,
               NVL(TO_CHAR(he.GROSS_SALARY, '99,99,99,999'), 0) AS GROSS_SALARY,
               dt.DESIG_NAME,
               gsec.SECTION_NAME,
               he.PUNCH_CARD_NO
        FROM HRM_EMPLOYEE he,
             GBL_DIVISION div,
             DEPT_TBL dpt,
             gbl_section gsec,
             DESIG_TBL dt,
             HRM_EMP_SEPARATIONS sep
        WHERE he.current_division_id = div.division_id(+)
          AND div.DIVISION_ID = NVL(p_division_id, div.DIVISION_ID)
          AND he.current_dept_id = dpt.dept_no(+)
          AND dpt.DEPT_NO = NVL(p_department_id, dpt.DEPT_NO)
          AND he.current_section_id = gsec.section_id(+)
          AND he.CURRENT_DESIG_ID = dt.DESIG_ID(+)
          and sep.EMPLOYEE_ID = he.EMPLOYEE_ID(+)
          AND sep.EFFECTIVE_FROM BETWEEN NVL(TO_DATE(:P1594_FROM_DATE, 'DD/MM/YYYY'), sep.EFFECTIVE_FROM) AND NVL(TO_DATE(:P1594_TO_DATE, 'DD/MM/YYYY'), sep.EFFECTIVE_FROM)
          --AND sep.EFFECTIVE_FROM BETWEEN TO_DATE(:P1594_FROM_DATE, 'dd/mm/yyyy') AND TO_DATE(:P1594_TO_DATE, 'dd/mm/yyyy')
          AND TO_CHAR(sep.EFFECTIVE_FROM, 'YYYY') = NVL(:P1594_YEAR, TO_CHAR(sep.EFFECTIVE_FROM, 'YYYY'))
          AND TO_CHAR(sep.EFFECTIVE_FROM, 'MM') = NVL(:P1594_MONTH, TO_CHAR(sep.EFFECTIVE_FROM, 'MM'))
     ORDER BY TO_CHAR(sep.EFFECTIVE_FROM, 'YYYY') DESC, 
              TO_CHAR(sep.EFFECTIVE_FROM, 'MM') ASC;

     --division cursor 
     cursor cur_div is 
     SELECT div.division_id,
       div.division_name 
        FROM gbl_division div, 
             gbl_division_dtls dtl
        WHERE div.active_ind = 'Y'
          AND div.division_id = dtl.division_id(+)
          AND dtl.company_id = :P1594_COMPANY_1
          AND dtl.location_id = :P1594_LOCATION
          AND (:P1594_DIVISION IS NULL OR INSTR(':' || :P1594_DIVISION || ':', ':' || div.division_id || ':') > 0)
        ORDER BY div.division_id;
        

    -- Variables
    v_sl NUMBER := 0;
    v_emp_total NUMBER := 0;
    v_div_total number := 0;
    v_grand_total NUMBER := 0;
    v_company VARCHAR2(200);
    v_location VARCHAR2(500);
    v_last_division_id NUMBER := NULL; 
    v_month varchar2(50);
    v_attr varchar2(150);
    v_count_row number:=0;
    v_dtl_count number :=0;
    v_heading varchar2(400):='<h5 style="text-align:left; width: 100%; v_attr">Facility: &nbsp;division_name </h5>
        <h5 style="text-align:left; width: 100%; v_attr">Department: &nbsp;DEPT_NAME </h5>';
    
BEGIN
        htp.p('<div id="printArea">');
    htp.p('
    <style>
        #m-table {
            width: 100%;
            margin: 10px auto;
            border-collapse: collapse;
        }
        #m-table th,
        #m-table td {
            border: 1px solid gray;
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
         .parent_container{
             border-bottom: 1px solid black;
             overflow: hidden;
         }
    </style>
    ');
    
    -- Retrieve Company Name
    BEGIN
        SELECT UNIT_NAME
        INTO v_company
        FROM UNIT_DEPT_TBL
        WHERE UNIT_DEPT_NO = :P1594_COMPANY_1;
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
          AND d.company_id = :P1594_COMPANY_1
          AND m.id = :P1594_LOCATION;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            v_location := '';
    END;


   begin
    select  distinct to_char(EFFECTIVE_FROM, 'Month') 
        into v_month
        from HRM_EMP_SEPARATIONS
        where to_char(EFFECTIVE_FROM, 'MM') = :P1594_MONTH;
        exception when no_data_found then 
         v_month := 'All Month';
    end;

    
----*********************************
    htp.p('<div class="parent_container">');

        htp.p('<div style="width: 50%; float:left;">');
            -- Division Header
            htp.p('<h3 style="text-align:center; margin: 0px;">' || v_company || '</h3>');
            htp.p('<h5 style="text-align:center; margin:0px">' || v_location || '</h5>');
            htp.p('<h4 style="font-weight:900; text-align:center; margin:0px;">Resign list for the month of: '||v_month||', '||:P1594_YEAR||'</h4>');
           -- htp.p('<hr style="height:1px; background-color:gray; width: 100%; margin: 0px;">');
            
        htp.p('</div>
        <div style="width: 50%; float:right;">
            <table style="border-collapse: collapse; float: right; text-align: left;">
                <tr><td></td><td>
            ');

    -- Loop through each division
    FOR rec_div IN cur_div LOOP
        v_div_total := 0; -- Reset total for each division        
        -- Calculate division total by looping through employees
        FOR rec_master IN cur_master LOOP
            IF rec_master.division_id = rec_div.division_id THEN
                FOR rec_detail IN cur_detail(rec_master.division_id, rec_master.DEPT_NO) LOOP
                    v_div_total := v_div_total + 1;
                END LOOP;
            END IF;
        END LOOP;

        -- Add division total to grand total
        v_grand_total := v_grand_total + v_div_total;

        -- Display division total
        htp.p('<tr><td style="border: 1px solid gray; padding: 5px; border:none;">' 
              || rec_div.division_name || '</td><td>:</td><td><strong>' || v_div_total || '</strong></td></tr>');
    END LOOP;

    -- Display grand total row
    htp.p('<tr><td style="border-top: 1px solid black; font-weight: bold; padding: 5px;">'
          || 'Grand Total</td><td style="border-top: 1px solid black;">:</td><td  style="border-top: 1px solid black;font-weight: bold; padding: 5px;"><strong>' || v_grand_total || '</strong></td></tr>');

    htp.p('</td></tr></table></div>');

htp.p('</div>');
-------------------------

            htp.p('
            <table id="m-table">
                <tr>
                    <th style="width:5%; border: 1px solid black;">SL</th>
                    <th style="width:25%; text-align:left; border: 1px solid black;">Name</th>
                    <th style="text-align:center; width:10%; border: 1px solid black;">Code</th>
                    <th style="width:15%; text-align:left; border: 1px solid black;">Designation</th>
                    <th style="width:15%; border: 1px solid black; text-align:left;">Sub-Deptt</th>
                    <th style="width:10%; border: 1px solid black;">Join Date</th>
                    <th style="width:10%; border: 1px solid black;">Notice date</th>
                    <th style="width:10%; border: 1px solid black;">Left date</th>
                </tr>
        </table>');
        --v_div_total := 0; 
---------------

    -- Loop through divisions
    FOR rec_master IN cur_master LOOP
       v_count_row:=v_count_row+1;
        IF v_last_division_id IS NULL OR v_last_division_id != rec_master.division_id THEN
            v_last_division_id := rec_master.division_id;
          v_div_total := 0; 
        end if; 
            
        -- Department Header
         htp.p('<div class="heading-'||v_count_row||'">
               <h5 style="text-align:left; width: 100%; '||v_attr||'">Facility: &nbsp' || rec_master.division_name || '</h5>');
         htp.p('<h5 style="text-align:left; width: 100%; '||v_attr||'">Department: &nbsp' || rec_master.DEPT_NAME || '</h5>
         </div>
         ');

        -- Start table
        htp.p('
            <table id="m-table" class="table-'||v_count_row||'">
                
        ');

        -- Initialize counter for department totals
        v_emp_total := 0;

        -- Loop through employees
        FOR rec_detail IN cur_detail(rec_master.division_id, rec_master.DEPT_NO) LOOP
            v_sl := v_sl + 1;
            v_emp_total := v_emp_total + 1;
            --v_grand_total := v_grand_total + 1;
            --v_div_total := v_div_total + 1;
                v_dtl_count :=v_count_row;
            htp.p('
                <tr division="'||rec_master.division_name||'" department="'||rec_master.DEPT_NAME||'" >
                    <td style="width:5%">' || v_sl || '</td>
                    <td style="width:25%; text-align:left;">' || rec_detail.FIRST_NAME || '</td>
                    <td style="text-align:left; width:10%; text-align:center;">' || rec_detail.MANUALLY_FORMATTED_ID || '</td>
                    <td style="width:15%; text-align:left;">' || rec_detail.DESIG_NAME || '</td>
                    <td style="width:15%; text-align:left;">' || rec_detail.SECTION_NAME || '</td>
                    <td style="width:10%">' || rec_detail.JOINING_DATE || '</td>
                    <td style="width:10%">' || rec_detail.notice_date || '</td>
                    <td style="width:10%">' || rec_detail.resign_date || '</td>
                </tr>
            ');
        END LOOP;
        if v_emp_total > 0 then
        
            -- Total for the department
            htp.p('
                <tr style="'||case when v_emp_total>0 then ''end ||'">
                    <th style="width:5%; border:none;">Total:</th>
                    <th style="text-align:left; width:25%; border:none;">' || v_emp_total || '</th>
                    <th style="width:10%; border:none;"></th>
                    <th style="width:15%; border:none;"></th>
                    <th style="width:15%; border:none;"></th>
                    <th style="width:10%; border:none;"></th>
                    <th style="width:10%; border:none;"></th>
                    <th style="width:10%; border:none;"></th>
                </tr>
            ');
            
            v_attr:= 'display:block;';

        else 
            
            v_attr:= 'display:none;';
        end if;
        
        htp.p('</table>');

       

    END LOOP;

     -- Grand total
    htp.p('
        <div style="text-align:left; width: 100%;">
            <h4 style="padding: 5px; width: 17%; font-weight: bold;">Grand Total: &nbsp; &nbsp;' || v_grand_total || '</h4>
        </div>
    ');

    htp.p('</div>');
   htp.p(' <style>
    .heading-'||(v_dtl_count+1)||'{
         display:none;
    }
    </style>
    ');
END;
