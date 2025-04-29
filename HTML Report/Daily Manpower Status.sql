declare
v_print_date varchar2(150) := :P1550_PRINT_DATE; 
--master cursor
cursor cur_m is 
select nvl (sec.SHORT_NAME, sec.SECTION_NAME)AS ABB,       
       gd.DIVISION_ID,
       dpt.DEPT_NO,
       sec.SECTION_ID
from GBL_SECTION sec,
     DEPT_TBL dpt,
     GBL_DIVISION gd
where sec.DEPARTMENT_ID = dpt.DEPT_NO(+)
   and sec.SECTION_ID = nvl(:P1550_SECTION_1, sec.SECTION_ID)
   and dpt.DEPT_NO = nvl(:P1550_DEPARTMENT, dpt.DEPT_NO)
   and dpt.DIVISION_ID = gd.DIVISION_ID(+)
   and gd.DIVISION_ID = :P1550_DIVISION;

-- detail cursor 
cursor cur_d(p_division_id number, p_department_id number, p_section_id number,P_list varchar2) is 
SELECT COUNT(A.EMP_ID) AS total_emp
FROM HRM_ATTENDANCE A,
     GBL_DIVISION DV,
     DEPT_TBL GB,
     GBL_SECTION S,
     DESIG_TBL D
WHERE A.ATTND_DATE = to_date(:P1550_FROM_DATE, 'DD-MON-YYYY')
AND A.SIGN_IN_TIME IS NOT NULL
AND A.DIVISION_ID = DV.DIVISION_ID(+) 
AND DV.DIVISION_ID = p_division_id --7
AND DV.DIVISION_ID = GB.DIVISION_ID(+)
AND GB.DEPT_NO = nvl(p_department_id, GB.DEPT_NO) --28 
AND GB.DEPT_NO = S.DEPARTMENT_ID(+)
AND S.SECTION_ID = nvl(p_section_id, S.SECTION_ID) --70
AND A.DESIGNATION_ID = D.DESIG_ID(+) 
AND D.DESIG_ID IN (select column_value from TABLE(apex_string.split(P_list,':')))
;

cursor dtl is select * from 
(select 1 sot, 'Operator' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%OPERATOR%' 
union
select 2 sot ,'Helper' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%HELPER%'
union
select 3 sot ,'Scissor Man' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%SCISSOR MAN%' 
union
select 4 sot, 'Iron Man (Line)' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%IRON MAN (LINE)%'
union
select 5 sot, 'Input Man' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%INPUT MAN%'
union
select 6 sot, 'Output Receiver' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%OUTPUT RECEIVER%'
union
select 7 sot, 'Supervisor' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%SUPERVISOR%'
union
select 8 sot, 'Line Chief' Name, listagg(distinct DESIG_ID,':')desi_ids from DESIG_TBL where upper(DESIG_NAME) LIKE '%LINE CHIEF%')
order by 1
;
--variable
v_company varchar2(200);
v_location varchar2(500);
v_total number := 0;


begin
htp.p('<div id="printArea">');
    htp.p('
    <style>
        #m-table {
            width: 100%;
            border-collapse: collapse;
        }
        #m-table th,
        #m-table td {
            border: 1px solid gray;
            text-align: center;
            padding: 5px;
        }
        #m-table th {
            font-weight: 900;
        }
        #printArea {
            margin: 10px;
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
            
    </style>
    ');

    BEGIN
        SELECT UNIT_NAME
        INTO v_company
        FROM UNIT_DEPT_TBL
        WHERE UNIT_DEPT_NO = :P1550_COMPANY_1;
        exception when no_data_found then
         v_company:= '';
    END;

    BEGIN 
        SELECT m.location_name || ' - ' || m.add_location
        INTO v_location
        FROM gbl_company_locations m,
             gbl_company_locations_dtls d
        WHERE d.location_id = m.id
          AND d.company_id = :P1550_COMPANY_1
          AND m.id = :P1550_LOCATION;
          exception when no_data_found then
          v_location:= '';
    END;

    
    htp.p('<div style="float:left; text-align:center; width:80%;">
    <h3 style="text-align:center; margin:0px">' || v_company || '</h3>
    <h5 style="text-align:center; margin:0px">' || v_location || '</h5>
    <h5 style="text-align:left; margin:0px; text-decoration:underline; text-decoration-thickness: 2px; margin-bottom: 10px;">Daily Manpower Status</h5>
    </div>
    ');

    htp.p('<div style="float:left; text-align:right; width:20%;">
    <h5>
    <span style="text-decoration:underline; text-decoration-thickness: 2px;">Report Date:</span>
    <span style="text-decoration:underline; text-decoration-thickness: 2px;"> &nbsp; &nbsp;'||:P1550_FROM_DATE||'</span>
    </h5>
    </div>
    ');

--master table
htp.p('<table id="m-table">');
htp.p('<tr>
<th style="text-align:left;">Line</th>
');

FOR rec_m IN cur_m LOOP
    htp.p('<th>' || rec_m.ABB || '</th>');
END LOOP;
htp.p('<th>Total</th>');
htp.p('</tr>'); 


for x in dtl loop
    v_total := 0;
    htp.p('<tr>'); 
    htp.p('<th style="text-align:left;"> '||x.Name||' </th>');

FOR rec_m IN cur_m LOOP
 htp.p('<th>'); 
 for rec_d in cur_d(rec_m.DIVISION_ID, rec_m.DEPT_NO, rec_m.SECTION_ID, x.desi_ids) loop  htp.p('<span>' || rec_d.total_emp || '</span>'); v_total := v_total + rec_d.total_emp; END LOOP;
htp.p('</th>');
END LOOP;
htp.p('<td>' || v_total || '</td>');
htp.p('</tr>'); 

end loop;
htp.p('</table>');

htp.p('</div>');
end;