declare
    v_print_date varchar2(150) := :P1592_PRINT_DATE; 
    -- Master cursor
    cursor cur_m is
SELECT COM.UNIT_DEPT_NO AS COMPANY_ID,
       L.ID AS LOCATION_ID,
       D.DIVISION_ID,
       DPT.DEPT_NO,
       D.DIVISION_NAME,
       DPT.DEPT_NAME
FROM GBL_DIVISION D,
     gbl_division_dtls DD,
     UNIT_DEPT_TBL COM,
     GBL_COMPANY_LOCATIONS L,
     DEPT_TBL DPT
WHERE d.division_id = DD.division_id(+)
AND DD.COMPANY_ID = COM.UNIT_DEPT_NO(+)
AND COM.UNIT_DEPT_NO = :P1592_COMPANY_1
AND DD.LOCATION_ID = L.ID(+)
AND L.ID = :P1592_LOCATION
and (:P1592_DIVISION IS NULL OR INSTR(':' || :P1592_DIVISION || ':', ':' || dd.DIVISION_ID || ':') > 0)
AND DD.DIVISION_ID = DPT.DIVISION_ID(+)
and (:P1592_DEPARTMENT IS NULL OR INSTR(':' || :P1592_DEPARTMENT || ':', ':' || DPT.DEPT_NO || ':') > 0)
ORDER BY 2, 3;

--detail cursor
cursor cur_d(p_division_id NUMBER) is 
SELECT S.SECTION_ID,
       S.SECTION_NAME, 
       COUNT(A.EMP_ID) AS ttl_employee_id,
       
    SUM(CASE WHEN D.DESIG_ID = 100 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) AS P_GN_OPERATOR,
    SUM(CASE WHEN D.DESIG_ID = 173 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) AS P_JR_OPERATOR,
    SUM(CASE WHEN D.DESIG_ID = 262 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) AS P_OPERATOR,
    SUM(CASE WHEN D.DESIG_ID = 342 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) AS P_SR_OPERATOR,
    
    SUM(CASE WHEN D.DESIG_ID = 100 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) +
    SUM(CASE WHEN D.DESIG_ID = 173 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) + 
    SUM(CASE WHEN D.DESIG_ID = 262 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) +
    SUM(CASE WHEN D.DESIG_ID = 342 AND UPPER(CT.SHORT_NAME) IN ('P', 'LT', 'MP') THEN 1 ELSE 0 END) AS P_SUM,

    SUM(CASE WHEN D.DESIG_ID = 100 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) AS A_GN_OPERATOR,
    SUM(CASE WHEN D.DESIG_ID = 173 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) AS A_JR_OPERATOR,
    SUM(CASE WHEN D.DESIG_ID = 262 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) AS A_OPERATOR,
    SUM(CASE WHEN D.DESIG_ID = 342 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) AS A_SR_OPERATOR,
    
    SUM(CASE WHEN D.DESIG_ID = 100 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) +
    SUM(CASE WHEN D.DESIG_ID = 173 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) +
    SUM(CASE WHEN D.DESIG_ID = 262 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) +
    SUM(CASE WHEN D.DESIG_ID = 342 AND UPPER(CT.SHORT_NAME) = 'A' THEN 1 ELSE 0 END) AS A_SUM,

    SUM(CASE WHEN D.DESIG_ID = 100 AND UPPER(CT.SHORT_NAME) IN 
             ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
              'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
              'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
              'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) AS LEAVE_GN_OPERATOR,

    SUM(CASE WHEN D.DESIG_ID = 173 AND UPPER(CT.SHORT_NAME) IN 
             ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
              'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
              'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
              'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) AS LEAVE_JR_OPERATOR,

    SUM(CASE WHEN D.DESIG_ID = 262 AND UPPER(CT.SHORT_NAME) IN 
             ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
              'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
              'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
              'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) AS LEAVE_OPERATOR,

    SUM(CASE WHEN D.DESIG_ID = 342 AND UPPER(CT.SHORT_NAME) IN 
             ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
              'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
              'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
              'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) AS LEAVE_SR_OPERATOR,
              
              
    SUM(CASE WHEN D.DESIG_ID = 100 AND UPPER(CT.SHORT_NAME) IN 
             ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
              'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
              'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
              'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) +
    SUM(CASE WHEN D.DESIG_ID = 173 AND UPPER(CT.SHORT_NAME) IN 
         ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
          'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
          'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
          'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) +
SUM(CASE WHEN D.DESIG_ID = 262 AND UPPER(CT.SHORT_NAME) IN 
         ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
          'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
          'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
          'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) +
SUM(CASE WHEN D.DESIG_ID = 342 AND UPPER(CT.SHORT_NAME) IN 
         ('SL', 'ML', 'CL', 'OL', 'EL', 'LWP', 'PL', 'SPL', 'HDL', 'UL', 
          'CML', 'ICL', 'ANNUAL LEAVE (RUNNING)', 'MARRIAGE LEAVE', 'LEAVE BY DH', 
          'BY-YEARLY LEAVE', 'EXPATRIATE-YEARLY LEAVE', 'SUBSTITUTE LEAVE', 'CORONA LEAVE', 
          'ESL', 'PDL', 'OTHERS LEAVE', 'MCL') THEN 1 ELSE 0 END) AS LEAVE_SUM
          
FROM HRM_ATTENDANCE A,
     HRM_EMPLOYEE E,
     GBL_SECTION S,
     DESIG_TBL D, --DESIG_ID
     HRM_CATEGORIES CT,
     GBL_DIVISION div
WHERE A.EMP_ID = E.EMPLOYEE_ID(+)
AND E.EMPLOYEE_CATEGORY_ID = 4042  -- Worker
AND A.SECTION_ID = S.SECTION_ID(+)
AND A.DESIGNATION_ID = D.DESIG_ID(+)
AND A.ATTND_DATE = TO_DATE(:P1592_FROM_DATE, 'DD-MON-YYYY')
AND D.DESIG_ID IN (100, 173, 262, 342)  -- Gn Operator, JR. Operator, Operator, SR. Operator
AND A.EMP_DAY_STATUS = CT.ID
AND E.ACTIVE_IND = 'Y'
--AND A.COMPANY_ID = 4
and A.DIVISION_ID = DIV.DIVISION_ID(+)
AND DIV.DIVISION_ID = nvl(p_division_id, DIV.DIVISION_ID)
GROUP BY S.SECTION_ID,
         S.SECTION_NAME
ORDER BY S.SECTION_ID;

    -- Variable declarations
    v_sl NUMBER := 0;
    v_company varchar2(200);

    v_man number := 0;

    v_gn_p number := 0;
    v_gn_a number := 0;
    v_gn_l number := 0;

    v_jo_p number := 0;
    v_jo_a number := 0;
    v_jo_l number := 0;
    
    v_o_p number := 0;
    v_o_a number := 0;
    v_o_l number := 0;

    v_so_p number := 0;
    v_so_a number := 0;
    v_so_l number := 0;

    v_t_p number := 0;
    v_t_a number := 0;
    v_t_l number := 0;
------------------
    g_man number := 0;

    g_gn_p number := 0;
    g_gn_a number := 0;
    g_gn_l number := 0;

    g_jo_p number := 0;
    g_jo_a number := 0;
    g_jo_l number := 0;
	
    g_o_p number := 0;
    g_o_a number := 0;
    g_o_l number := 0;
	
    g_so_p number := 0;
    g_so_a number := 0;
    g_so_l number := 0;
	
    g_t_p number := 0;
    g_t_a number := 0;
    g_t_l number := 0;

begin
    htp.p('<div id="printArea">');
    htp.p('
    <style type="text/css">
        #m-table {
            width: 100%;
            border-collapse: collapse;
        }
        #m-table th, #m-table td {
            border: 1px solid gray;
            text-align: center;
            padding: 5px;
            width: 5.55%;
        }
        #m-table th {
            font-weight: 900;
        }
        #printArea {
            margin: 10px;
        }
        #header_bg{
            background-color: #ddd;
        }

        @media print{
               #header_bg{
                    background-color: #ddd!important;
                }
            }

         @page {
                margin: 20mm;
                @bottom-right {
                    content: "Page " counter(page) " of " counter(pages);
                    margin-bottom: 20px;
                }
                @bottom-left {
                    content: "' || v_print_date || '";
                    margin-bottom: 20px !important;
                }
            }

            

    </style>');

    -- Fetch the company name
    BEGIN
        SELECT UNIT_NAME
        INTO v_company
        FROM UNIT_DEPT_TBL
        WHERE UNIT_DEPT_NO = :P1592_COMPANY_1;
        exception when no_data_found then
         v_company := '';
    END;

for rec_m in cur_m loop 

for rec_d in cur_d(rec_m.DIVISION_ID) loop 


v_sl := v_sl + 1;

v_man := v_man + rec_d.ttl_employee_id;

v_gn_p := v_gn_p + rec_d.P_GN_OPERATOR;
v_gn_a := v_gn_a + rec_d.A_GN_OPERATOR;
v_gn_l := v_gn_l + rec_d.LEAVE_GN_OPERATOR;

v_jo_p := v_jo_p + rec_d.P_JR_OPERATOR;
v_jo_a := v_jo_a + rec_d.A_JR_OPERATOR;
v_jo_l := v_jo_l + rec_d.LEAVE_JR_OPERATOR;

v_o_p := v_o_p + rec_d.P_OPERATOR;
v_o_a := v_o_a + rec_d.A_OPERATOR;
v_o_l := v_o_l + rec_d.LEAVE_OPERATOR;

v_so_p := v_so_p + rec_d.P_SR_OPERATOR;
v_so_a := v_so_a + rec_d.A_SR_OPERATOR;
v_so_l := v_so_l + rec_d.LEAVE_SR_OPERATOR;

v_t_p := v_t_p + rec_d.P_SUM;
v_t_a := v_t_a + rec_d.A_SUM;
v_t_l := v_t_l + rec_d.LEAVE_SUM;

-------------------
g_man := g_man + rec_d.ttl_employee_id;

g_gn_p := g_gn_p + rec_d.P_GN_OPERATOR;
g_gn_a := g_gn_a + rec_d.A_GN_OPERATOR;
g_gn_l := g_gn_l + rec_d.LEAVE_GN_OPERATOR;

g_jo_p := g_jo_p + rec_d.P_JR_OPERATOR;
g_jo_a := g_jo_a + rec_d.A_JR_OPERATOR;
g_jo_l := g_jo_l + rec_d.LEAVE_JR_OPERATOR;

g_o_p := g_o_p + rec_d.P_OPERATOR;
g_o_a := g_o_a + rec_d.A_OPERATOR;
g_o_l := g_o_l + rec_d.LEAVE_OPERATOR;

g_so_p := g_so_p + rec_d.P_SR_OPERATOR;
g_so_a := g_so_a + rec_d.A_SR_OPERATOR;
g_so_l := g_so_l + rec_d.LEAVE_SR_OPERATOR;

g_t_p := g_t_p + rec_d.P_SUM;
g_t_a := g_t_a + rec_d.A_SUM;
g_t_l := g_t_l + rec_d.LEAVE_SUM;

if rec_d.ttl_employee_id > 0 then

htp.p('<div style="width:80%; float:left; margin:0;">');
htp.p('<h3 style="text-align:center; margin:0px">' || v_company || '</h3>');
htp.p('<h3 style="text-align:center; margin:0px">' || rec_m.DEPT_NAME || '</h3>');
htp.p('<h3 style="text-align:center; margin:0px; text-decoration:underline;">' || :P1592_FROM_DATE || '</h3>');

htp.p('<h4 id="header_bg" style="text-align:left; width:467px; margin-bottom:0px; text-decoration:underline; background-color:#ddd!important;">' || rec_m.DIVISION_NAME || '</h4>');
htp.p('</div>');

htp.p('<div  style="width:20%;float:left; text-align: right; margin-top: 64px;">
    <p><strong>P = Present <br> A = Absent</strong>
</div>');


htp.p('<table id="m-table">
<tr>
<th rowspan="2">SL</th>
<th rowspan="2">LINE</th>
<th rowspan="2">Man</th>
<th colspan="3">Gn. Operator</th>
<th colspan="3">Jr. Operator</th>
<th colspan="3">Operator</th>
<th colspan="3">Sr. Operator</th>
<th colspan="3">Total</th>
</tr>

<tr>
<th>P</th>
<th>A</th>
<th>Leave</th>

<th>P</th>
<th>A</th>
<th>Leave</th>

<th>P</th>
<th>A</th>
<th>Leave</th>

<th>P</th>
<th>A</th>
<th>Leave</th>

<th>P</th>
<th>A</th>
<th>Leave</th>

</tr>
');

end if; 

htp.p('
<tr>
<td>'||v_sl||'</td>
<td>'||rec_d.SECTION_NAME||'</td>
<td>'||rec_d.ttl_employee_id||'</td>

<td>'||rec_d.P_GN_OPERATOR||'</td>
<td>'||rec_d.A_GN_OPERATOR||'</td>
<td>'||rec_d.LEAVE_GN_OPERATOR||'</td>

<td>'||rec_d.P_JR_OPERATOR||'</td>
<td>'||rec_d.A_JR_OPERATOR||'</td>
<td>'||rec_d.LEAVE_JR_OPERATOR||'</td>

<td>'||rec_d.P_OPERATOR||'</td>
<td>'||rec_d.A_OPERATOR||'</td>
<td>'||rec_d.LEAVE_OPERATOR||'</td>

<td>'||rec_d.P_SR_OPERATOR||'</td>
<td>'||rec_d.A_SR_OPERATOR||'</td>
<td>'||rec_d.LEAVE_SR_OPERATOR||'</td>

<td>'||rec_d.P_SUM||'</td>
<td>'||rec_d.A_SUM||'</td>
<td>'||rec_d.LEAVE_SUM||'</td>
</tr>

<tr>
<td colspan="2">Total:</td>
<td>'||v_man||'</td>

<td>'||v_gn_p||'</td>
<td>'||v_gn_a||'</td>
<td>'||v_gn_l||'</td>

<td>'||v_jo_p||'</td>
<td>'||v_jo_a||'</td>
<td>'||v_jo_l||'</td>

<td>'||v_o_p||'</td>
<td>'||v_o_a||'</td>
<td>'||v_o_l||'</td>

<td>'||v_so_p||'</td>
<td>'||v_so_a||'</td>
<td>'||v_so_l||'</td>

<td>'||v_t_p||'</td>
<td>'||v_t_a||'</td>
<td>'||v_t_l||'</td>
</tr>

');

end loop;
--reseat the variable value
v_man := 0;

v_gn_p := 0;
v_gn_a := 0;
v_gn_l := 0;

v_jo_p := 0;
v_jo_a := 0;
v_jo_l := 0;

v_o_p := 0;
v_o_a := 0;
v_o_l := 0;

v_so_p := 0;
v_so_a := 0;
v_so_l := 0;

v_t_p := 0;
v_t_a := 0;
v_t_l := 0;

htp.p('</table>');
end loop;

htp.p('<table id="m-table">
<tr>
<td>Grand total:</td>
<td></td>
<td>'||g_man||'</td>

<td>'||g_gn_p||'</td>
<td>'||g_gn_a||'</td>
<td>'||g_gn_l||'</td>

<td>'||g_jo_p||'</td>
<td>'||g_jo_a||'</td>
<td>'||g_jo_l||'</td>

<td>'||g_o_p||'</td>
<td>'||g_o_a||'</td>
<td>'||g_o_l||'</td>

<td>'||g_so_p||'</td>
<td>'||g_so_a||'</td>
<td>'||g_so_l||'</td>

<td>'||g_t_p||'</td>
<td>'||g_t_a||'</td>
<td>'||g_t_l||'</td>
</tr>
</table>
');

htp.p('</div>');
end;
