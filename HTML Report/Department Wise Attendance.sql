DECLARE
v_sysdate varchar2(150) := to_date(:P1521_PRINT_DATE, 'DD-MON-YYYY');
    -- Master cursor
    CURSOR cur_m IS
        SELECT d.division_name, d.division_id
          FROM gbl_division d, gbl_division_dtls s
         WHERE d.active_ind = 'Y'
           AND d.division_id = s.division_id
           AND s.company_id = :P1521_COMPANY_1
           AND s.location_id = :P1521_LOCATION
           AND ( :P1521_DIVISION IS NULL OR INSTR(':' || :P1521_DIVISION || ':', ':' || d.division_id || ':') > 0 );

    -- Detail cursor
    CURSOR cur_atten(p_division_id NUMBER) IS
        SELECT DEPT_NAME,
               NVL(Present, 0) AS Present,
               NVL(Absent, 0) AS Absent,
               NVL(SL, 0) + NVL(PL, 0) + NVL(CL, 0) + NVL(EL, 0) + NVL(ML, 0) +
               NVL(LWP, 0) + NVL(SPL, 0) + NVL(UL, 0) + NVL(ICL, 0) + NVL(CPL, 0) AS Leave
          FROM (SELECT dt.DEPT_NAME,
                       hc.SHORT_NAME
                  FROM HRM_ATTENDANCE ha,
                       UNIT_DEPT_TBL udt,
                       DEPT_TBL dt,
                       HRM_CATEGORIES hc
                 WHERE ha.COMPANY_ID = udt.UNIT_DEPT_NO(+)
                   AND udt.UNIT_DEPT_NO = NVL(:P1521_COMPANY_1, udt.UNIT_DEPT_NO)
                   AND ha.DEPARTMENT_ID = dt.DEPT_NO(+)
                   AND dt.DEPT_NO = NVL(:P1521_DEPARTMENT, dt.DEPT_NO)
                   AND ha.ATTND_DATE = TO_DATE(:P1521_FROM_DATE, 'DD-MON-YYYY')
                   AND ha.EMP_DAY_STATUS = hc.ID
                   AND ha.DIVISION_ID IN (p_division_id))
        PIVOT (COUNT(SHORT_NAME)
               FOR SHORT_NAME IN ('A' AS Absent, 'P' AS Present, 'SL' AS SL, 'PL' AS PL,
                                  'CL' AS CL, 'EL' AS EL, 'ML' AS ML, 'LWP' AS LWP,
                                  'SPL' AS SPL, 'UL' AS UL, 'ICL' AS ICL, 'CPL' AS CPL));

    -- Variables
    v_sl NUMBER := 0;
    v_p_total NUMBER := 0;
    v_a_total NUMBER := 0;
    v_l_total NUMBER := 0;

BEGIN
    
    htp.p('<div id="printArea">');
    htp.p('<h3 style="text-align:center; margin:0px">Daily Summary</h3>');
    htp.p('<h3 style="text-align:center; margin:0px">' || :P1521_FROM_DATE || '</h3>');
    
    htp.p('<style  type="text/css">
        :root{
            --date:'||v_sysdate||';
        }
        #cssDate::before{
            content: var(--date);
        }
        @page{
            @bottom-right {
                content: "'||v_sysdate||'";
                margin-bottom: 20px;
            }
        }
    </style>');
    FOR rec_m IN cur_m LOOP
        v_sl := 0;
        v_p_total := 0;
        v_a_total := 0;
        v_l_total := 0;

        htp.p('<h4 style="text-align:left; text-decoration: underline; width:90%; margin: 10px auto;">' || rec_m.division_name || '</h4>');

        htp.p('<div class="content-section">');
        htp.p('
            <table id="m-table">
                <tr>
                    <th style="width:5%">SL</th>
                    <th style="text-align:left; width:50%">Department</th>
                    <th style="width:15%">Present</th>
                    <th style="width:15%">Absent</th>
                    <th style="width:15%">Leave</th>
                </tr>
        ');

        FOR rec_atten IN cur_atten(rec_m.division_id) LOOP
            v_sl := v_sl + 1;
            v_p_total := v_p_total + rec_atten.Present;
            v_a_total := v_a_total + rec_atten.Absent;
            v_l_total := v_l_total + rec_atten.Leave;

            htp.p('
                <tr>
                    <td style="width:5%">' || v_sl || '</td>
                    <td style="text-align:left; width:50%">' || rec_atten.DEPT_NAME || '</td>
                    <td style="width:15%">' || rec_atten.Present || '</td>
                    <td style="width:15%">' || rec_atten.Absent || '</td>
                    <td style="width:15%">' || rec_atten.Leave || '</td>
                </tr>
            ');
        END LOOP;

        htp.p('
            <tr>
                <th colspan="2">Total</th>
                <th>' || v_p_total || '</th>
                <th>' || v_a_total || '</th>
                <th>' || v_l_total || '</th>
            </tr>
        ');

        htp.p('</table>');
        htp.p('</div>');
    END LOOP;
exception when others then null;
END;
