DECLARE

 CURSOR cur_master
   IS
          SELECT nvl(a.DEPARTMENT_ID, 0) as DEPARTMENT_ID,
              d.DEPT_NAME, 
              NVL (a.SECTION_ID, 0) AS SECTION_ID, 
              s.SECTION_NAME,
              nvl(a.DESIGNATION_ID, 0) as DESIGNATION_ID,
              d.DESIG_NAME,
              count(*) over(partition by a.DEPARTMENT_ID)
               dept_row_span,
              --count(a.SECTION_ID) over(partition by s.DEPARTMENT_ID)
               0 sec_row_span

          FROM HRM_ATTENDANCE a,
               DEPT_TBL d,
               GBL_SECTION s,
               DESIG_TBL d
         WHERE     a.ATTND_DATE = TO_DATE (:P1434_ATTENDANCE_DATE, 'DD-MON-YYYY') --'31-OCT-2024'
               AND a.DEPARTMENT_ID = NVL (:P1434_DEPARTMENT, a.DEPARTMENT_ID)
               AND a.SECTION_ID = NVL (:P1434_SECTION, a.SECTION_ID)
               AND a.DESIGNATION_ID = NVL (:P1434_DESIGNATION, a.DESIGNATION_ID)
                and a.DEPARTMENT_ID = d.DEPT_NO(+)
                and a.DEPARTMENT_ID < 4
               and a.SECTION_ID = s.SECTION_ID(+)
               and a.DESIGNATION_ID = d.DESIG_ID(+)
      GROUP BY a.DEPARTMENT_ID, a.SECTION_ID, a.DESIGNATION_ID, d.DEPT_NAME, s.SECTION_NAME, d.DESIG_NAME
      ORDER BY a.DEPARTMENT_ID, a.SECTION_ID,a.DESIGNATION_ID;

   CURSOR cur_detail (
      p_date       DATE,
      p_dept_id     NUMBER,
      p_section_id    NUMBER,
      p_desig_id      NUMBER)
   IS
      SELECT NVL (A, 0) AS A,
             NVL (CH, 0) AS CH,
             NVL (CL, 0) AS CL,
             NVL (CML, 0) AS CML,
             NVL (EL, 0) AS EL,
             NVL (FH, 0) AS FH,
             NVL (GH, 0) AS GH,
             NVL (HDA, 0) AS HDA,
             NVL (LT, 0) AS LT,
             NVL (LWP, 0) AS LWP,
             NVL (ML, 0) AS ML,
             NVL (MR, 0) AS MR,
             NVL (OH, 0) AS OH,
             NVL (P, 0) AS P,
             NVL (SL, 0) AS SL,
             NVL (SPL, 0) AS SPL,
             NVL (WO, 0) AS WO,
               NVL (A, 0)
             + NVL (CH, 0)
             + NVL (CL, 0)
             + NVL (CML, 0)
             + NVL (EL, 0)
             + NVL (FH, 0)
             + NVL (GH, 0)
             + NVL (HDA, 0)
             + NVL (LT, 0)
             + NVL (LWP, 0)
             + NVL (ML, 0)
             + NVL (MR, 0)
             + NVL (OH, 0)
             + NVL (P, 0)
             + NVL (SL, 0)
             + NVL (SPL, 0)
             + NVL (WO, 0)
                AS Total
        FROM (SELECT ATTND_DAY_STATUS
                FROM V_HRM_ATTENDANCE
               WHERE   ATTENDANCE_DATE = p_date
                     and nvl(DEPARTMENT_ID, 0) = p_dept_id
                      AND nvl(SECTION_id, 0) = p_section_id
                     AND nvl(DESIGNATION_ID, 0) = p_desig_id)
                         PIVOT (COUNT (
                                                            ATTND_DAY_STATUS)
                                                  FOR ATTND_DAY_STATUS
                                                  IN  ('A' AS A,
                                                      'CH' AS CH,
                                                      'CL' AS CL,
                                                      'CML' AS CML,
                                                      'EL' AS EL,
                                                      'FH' AS FH,
                                                      'GH' AS GH,
                                                      'HDA' AS HDA,
                                                      'LT' AS LT,
                                                      'LWP' AS LWP,
                                                      'ML' AS ML,
                                                      'MR' AS MR,
                                                      'OH' AS OH,
                                                      'P' AS P,
                                                      'SL' AS SL,
                                                      'SPL' AS SPL,
                                                      'WO' AS WO));

       v_count number:=0;
       v_last_dept number:=0.1;
       v_last_sec number:=0.1;
       v_last_dept_br number:=0.1;
       v_last_sec_br number:=0.1;
       v_last_desi number:=0.1;
       v_brk_count number:=1;      

       v_tag_brk varchar2(4000);


             --section wise total
   v_a_total        number:=0;
   v_ch_total       number:=0;
   v_cl_total       number:=0;
   v_cml_total      number:=0;
   v_el_total       number:=0;
   v_fh_total       number:=0;
   v_gh_total       number:=0;
   v_hda_total      number:=0;
   v_lt_total       number:=0;
   v_lwp_total      number:=0;
   v_ml_total       number:=0;
   v_mr_total       number:=0;
   v_oh_total       number:=0;
   v_p_total        number:=0;
   v_sl_total       number:=0;
   v_spl_total      number:=0;
   v_wo_total       number:=0;
   v_sec_total      number:= 0;

   --dept wise total
   v_a_total_dep        number:=0;
   v_ch_total_dep       number:=0;
   v_cl_total_dep       number:=0;
   v_cml_total_dep      number:=0;
   v_el_total_dep       number:=0;
   v_fh_total_dep       number:=0;
   v_gh_total_dep       number:=0;
   v_hda_total_dep      number:=0;
   v_lt_total_dep       number:=0;
   v_lwp_total_dep      number:=0;
   v_ml_total_dep       number:=0;
   v_mr_total_dep       number:=0;
   v_oh_total_dep       number:=0;
   v_p_total_dep        number:=0;
   v_sl_total_dep       number:=0;
   v_spl_total_dep      number:=0;
   v_wo_total_dep       number:=0;
   v_sec_total_dep      number:= 0;


   --grand total
   v_a_grand    number:=0;
   v_ch_grand   number:=0;
   v_cl_grand   number:=0;
   v_cml_grand  number:=0;
   v_el_grand   number:=0;
   v_fh_grand   number:=0;
   v_gh_grand   number:=0;
   v_hda_grand  number:=0;
   v_lt_grand   number:=0;
   v_lwp_grand  number:=0;
   v_ml_grand   number:=0;
   v_mr_grand   number:=0;
   v_oh_grand   number:=0;
   v_p_grand    number:=0;
   v_sl_grand   number:=0;
   v_spl_grand  number:=0;
   v_wo_grand   number:=0;
   v_sec_grand  number:= 0;

v_dept_rowspan number:=0;
v_dept_string varchar2(200);

BEGIN
REPORT_STYLE.table_style;
   htp.p('<h3 style="text-align:center;">Attendance Daily Summary</br>' || :P1434_ATTENDANCE_DATE || '</h3>');
   htp.p('<table id="detail-table" border="1"> 
        ');
   htp.p('<tr>
            <th>Department Name</th>
            <th>Section Name</th>
            <th>Designation Name</th>
            <th class="A">A</th>
            <th class="CH">CH</th>
            <th class="CL">CL</th>
            <th class="CML">CML</th>
            <th class="EL">EL</th>
            <th class="FH">FH</th>
            <th class="GH">GH</th>
            <th class="HDA">HDA</th>
            <th class="LT">LT</th>
            <th class="LWP">LWP</th>
            <th class="ML">ML</th>
            <th class="MR">MR</th>
            <th class="OH">OH</th>
            <th class="P">P</th>
            <th class="SL">SL</th>
            <th class="SPL">SPL</th>
            <th class="WO">WO</th>
            <th>Total</th>
         </tr>
         </thead>
         ');
   FOR rec_master IN cur_master
   LOOP
   v_dept_rowspan :=v_dept_rowspan+1;

   v_count :=v_count+1;
   if v_count>1 then
      if  v_last_dept != rec_master.DEPARTMENT_ID 
        or    v_last_sec != rec_master.SECTION_ID --or
       --v_last_desi =rec_master.DESIGNATION_ID
       then
      v_dept_rowspan :=0;


 v_tag_brk:=    case
            when v_last_dept != rec_master.DEPARTMENT_ID then
                  '<tr class="u-color-10" group="g-'||v_last_dept||'" subgroup="sg-'||v_last_dept||'-'||v_last_sec||'"  rowdept="'||rec_master.dept_row_span||'"   sec_row_span="'||rec_master.sec_row_span||'" > 
                     <td></td>                   
                     <td>'||v_last_sec||'</td>                  
                     <td>Section Total</td>
                     <td class="A">' || v_a_total || '</td>
                     <td class="CH">' || v_ch_total || '</td>
                     <td class="CL">' || v_cl_total || '</td>
                     <td class="CML">' || v_cml_total || '</td>
                     <td class="EL">' || v_el_total || '</td>
                     <td class="FH">' || v_fh_total || '</td>
                     <td class="GH">' || v_gh_total || '</td>
                     <td class="HDA>' || v_hda_total || '</td>
                     <td class="LT">' || v_lt_total || '</td>
                     <td class="LWP">' || v_lwp_total || '</td>
                     <td class="ML">' || v_ml_total || '</td>
                     <td class="MR">' || v_mr_total || '</td>
                     <td class="OH">' || v_oh_total || '</td>
                     <td class="P">' || v_p_total || '</td>
                     <td class="SL">' || v_sl_total || '</td>
                     <td class="SPL">' || v_spl_total || '</td>
                     <td class="WO">' || v_wo_total || '</td>
                     <td>' || v_sec_total || '</td>
         </tr>    
         <tr class="u-color-11" group="g-'||v_last_dept||'" subgroup="sg-'||v_last_dept||'-'||v_last_sec||'" rowdept="'||rec_master.dept_row_span||'"  sec_row_span="'||rec_master.sec_row_span||'"> 
                      <td>'||v_last_dept||'</td>
                     <td>Department Total</td>
                     <td></td>                     
                     <td class="A">' || v_a_total_dep || '</td>
                     <td class="CH">' || v_ch_total_dep || '</td>
                     <td class="CL">' || v_cl_total_dep || '</td>
                     <td class="CML">' || v_cml_total_dep || '</td>
                     <td class="EL">' || v_el_total_dep || '</td>
                     <td class="FH">' || v_fh_total_dep || '</td>
                     <td class="GH">' || v_gh_total_dep || '</td>
                     <td class="HDA>' || v_hda_total_dep || '</td>
                     <td class="LT">' || v_lt_total_dep || '</td>
                     <td class="LWP">' || v_lwp_total_dep || '</td>
                     <td class="ML">' || v_ml_total_dep || '</td>
                     <td class="MR">' || v_mr_total_dep || '</td>
                     <td class="OH">' || v_oh_total_dep || '</td>
                     <td class="P">' || v_p_total_dep || '</td>
                     <td class="SL">' || v_sl_total_dep || '</td>
                     <td class="SPL">' || v_spl_total_dep || '</td>
                     <td class="WO">' || v_wo_total_dep || '</td>
                     <td>' || v_sec_total_dep || '</td>
                     </tr>
               '
               
                when v_last_sec != rec_master.SECTION_ID then
                     '<tr class="u-color-21" group="g-'||v_last_dept||'" subgroup="sg-'||v_last_dept||'-'||v_last_sec||'" rowdept="'||rec_master.dept_row_span||'"  sec_row_span="'||rec_master.sec_row_span||'"> 
                      <td>'||v_last_dept||'</td>
                     <td>'||v_last_sec||'</td>                
                     <td>Section Total</td>               
                     
                     <td class="A">' || v_a_total || '</td>
                     <td class="CH">' || v_ch_total || '</td>
                     <td class="CL">' || v_cl_total || '</td>
                     <td class="CML">' || v_cml_total || '</td>
                     <td class="EL">' || v_el_total || '</td>
                     <td class="FH">' || v_fh_total || '</td>
                     <td class="GH">' || v_gh_total || '</td>
                     <td class="HDA>' || v_hda_total || '</td>
                     <td class="LT">' || v_lt_total || '</td>
                     <td class="LWP">' || v_lwp_total || '</td>
                     <td class="ML">' || v_ml_total || '</td>
                     <td class="MR">' || v_mr_total || '</td>
                     <td class="OH">' || v_oh_total || '</td>
                     <td class="P">' || v_p_total || '</td>
                     <td class="SL">' || v_sl_total || '</td>
                     <td class="SPL">' || v_spl_total || '</td>
                     <td class="WO">' || v_wo_total || '</td>
                     <td>' || v_sec_total || '</td>

         </tr>'  
           
            end ;
          htp.p(v_tag_brk);

          v_a_total :=0;
         v_ch_total :=0;
         v_cl_total :=0;
         v_cml_total :=0;
         v_el_total :=0;
         v_fh_total :=0;
         v_gh_total :=0;
         v_hda_total :=0;
         v_lt_total :=0;
         v_lwp_total :=0;
         v_ml_total :=0;
         v_mr_total :=0;
         v_oh_total :=0;
         v_p_total :=0;
         v_sl_total :=0;
         v_spl_total :=0;
         v_wo_total :=0;
         v_sec_total :=0;

         if  v_last_dept !=rec_master.DEPARTMENT_ID then
          v_a_total_dep :=0;
         v_ch_total_dep :=0;
         v_cl_total_dep :=0;
         v_cml_total_dep :=0;
         v_el_total_dep :=0;
         v_fh_total_dep :=0;
         v_gh_total_dep :=0;
         v_hda_total_dep :=0;
         v_lt_total_dep :=0;
         v_lwp_total_dep :=0;
         v_ml_total_dep :=0;
         v_mr_total_dep :=0;
         v_oh_total_dep :=0;
         v_p_total_dep :=0;
         v_sl_total_dep :=0;
         v_spl_total_dep :=0;
         v_wo_total_dep :=0;
         v_sec_total_dep :=0;
         end if;
         
         v_last_dept :=rec_master.DEPARTMENT_ID ; 
         v_last_sec := rec_master.SECTION_ID ;
         -- v_last_desi :=rec_master.DESIGNATION_ID;

         v_brk_count :=v_brk_count+1;

         v_last_dept_br :=v_last_dept;
         v_last_sec_br :=v_last_sec;

         end if;
    else 
         v_last_dept :=rec_master.DEPARTMENT_ID ; 
         v_last_sec := rec_master.SECTION_ID ;
          --v_last_desi :=rec_master.DESIGNATION_ID;
          
   end if;
   
      FOR rec_detail_2nd IN cur_detail (TO_DATE (:P1434_ATTENDANCE_DATE, 'DD-MON-YYYY'),rec_master.DEPARTMENT_ID, rec_master.SECTION_ID, rec_master.DESIGNATION_ID)
      LOOP
       
         v_a_total := v_a_total + NVL(rec_detail_2nd.A, 0);
         v_ch_total := v_ch_total + NVL(rec_detail_2nd.CH, 0);
         v_cl_total := v_cl_total + NVL(rec_detail_2nd.CL, 0);
         v_cml_total := v_cml_total + NVL(rec_detail_2nd.CML, 0);
         v_el_total := v_el_total + NVL(rec_detail_2nd.EL, 0);
         v_fh_total := v_fh_total + NVL(rec_detail_2nd.FH, 0);
         v_gh_total := v_gh_total + NVL(rec_detail_2nd.GH, 0);
         v_hda_total := v_hda_total + NVL(rec_detail_2nd.HDA, 0);
         v_lt_total := v_lt_total + NVL(rec_detail_2nd.LT, 0);
         v_lwp_total := v_lwp_total + NVL(rec_detail_2nd.LWP, 0);
         v_ml_total := v_ml_total + NVL(rec_detail_2nd.ML, 0);
         v_mr_total := v_mr_total + NVL(rec_detail_2nd.MR, 0);
         v_oh_total := v_oh_total + NVL(rec_detail_2nd.OH, 0);
         v_p_total := v_p_total + NVL(rec_detail_2nd.P, 0);
         v_sl_total := v_sl_total + NVL(rec_detail_2nd.SL, 0);
         v_spl_total := v_spl_total + NVL(rec_detail_2nd.SPL, 0);
         v_wo_total := v_wo_total + NVL(rec_detail_2nd.WO, 0);
         v_sec_total := v_sec_total + nvl(rec_detail_2nd.total, 0);

          v_a_grand := v_a_grand + NVL(rec_detail_2nd.A, 0);
         v_ch_grand := v_ch_grand + NVL(rec_detail_2nd.CH, 0);
         v_cl_grand := v_cl_grand + NVL(rec_detail_2nd.CL, 0);
         v_cml_grand := v_cml_grand + NVL(rec_detail_2nd.CML, 0);
         v_el_grand := v_el_grand + NVL(rec_detail_2nd.EL, 0);
         v_fh_grand := v_fh_grand + NVL(rec_detail_2nd.FH, 0);
         v_gh_grand := v_gh_grand + NVL(rec_detail_2nd.GH, 0);
         v_hda_grand := v_hda_grand + NVL(rec_detail_2nd.HDA, 0);
         v_lt_grand := v_lt_grand + NVL(rec_detail_2nd.LT, 0);
         v_lwp_grand := v_lwp_grand + NVL(rec_detail_2nd.LWP, 0);
         v_ml_grand := v_ml_grand + NVL(rec_detail_2nd.ML, 0);
         v_mr_grand := v_mr_grand + NVL(rec_detail_2nd.MR, 0);
         v_oh_grand := v_oh_grand + NVL(rec_detail_2nd.OH, 0);
         v_p_grand := v_p_grand + NVL(rec_detail_2nd.P, 0);
         v_sl_grand := v_sl_grand + NVL(rec_detail_2nd.SL, 0);
         v_spl_grand := v_spl_grand + NVL(rec_detail_2nd.SPL, 0);
         v_wo_grand := v_wo_grand + NVL(rec_detail_2nd.WO, 0);
         v_sec_grand := v_sec_grand + nvl(rec_detail_2nd.total, 0);




          v_a_total_dep := v_a_total_dep + NVL(rec_detail_2nd.A, 0);
         v_ch_total_dep := v_ch_total_dep + NVL(rec_detail_2nd.CH, 0);
         v_cl_total_dep := v_cl_total_dep + NVL(rec_detail_2nd.CL, 0);
         v_cml_total_dep := v_cml_total_dep + NVL(rec_detail_2nd.CML, 0);
         v_el_total_dep := v_el_total_dep + NVL(rec_detail_2nd.EL, 0);
         v_fh_total_dep := v_fh_total_dep + NVL(rec_detail_2nd.FH, 0);
         v_gh_total_dep := v_gh_total_dep + NVL(rec_detail_2nd.GH, 0);
         v_hda_total_dep := v_hda_total_dep + NVL(rec_detail_2nd.HDA, 0);
         v_lt_total_dep := v_lt_total_dep + NVL(rec_detail_2nd.LT, 0);
         v_lwp_total_dep := v_lwp_total_dep + NVL(rec_detail_2nd.LWP, 0);
         v_ml_total_dep := v_ml_total_dep + NVL(rec_detail_2nd.ML, 0);
         v_mr_total_dep := v_mr_total_dep + NVL(rec_detail_2nd.MR, 0);
         v_oh_total_dep := v_oh_total_dep + NVL(rec_detail_2nd.OH, 0);
         v_p_total_dep := v_p_total_dep + NVL(rec_detail_2nd.P, 0);
         v_sl_total_dep := v_sl_total_dep + NVL(rec_detail_2nd.SL, 0);
         v_spl_total_dep := v_spl_total_dep + NVL(rec_detail_2nd.SPL, 0);
         v_wo_total_dep := v_wo_total_dep + NVL(rec_detail_2nd.WO, 0);
         v_sec_total_dep := v_sec_total_dep + nvl(rec_detail_2nd.total, 0);

         htp.p (
               '<tr group="g-'||v_last_dept||'" subgroup="sg-'||v_last_dept||'-'||v_last_sec||'"  rowdept="'||rec_master.dept_row_span||'"  sec_row_span="'||rec_master.sec_row_span||'">
                   <td>'|| rec_master.DEPT_NAME|| '</td>
                   <td >'|| rec_master.SECTION_NAME||'</td>
                   <td>'|| rec_master.DESIG_NAME|| '</td>                     
                   <td class="A">'|| rec_detail_2nd.A || '</td>
                   <td class="CH">'|| rec_detail_2nd.CH|| '</td>
                   <td class="CL">'|| rec_detail_2nd.CL|| '</td>
                   <td class="CML">'|| rec_detail_2nd.CML|| '</td>
                   <td class="EL">'|| rec_detail_2nd.EL || '</td>
                   <td class="FH">'|| rec_detail_2nd.FH || '</td>
                   <td class="GH">'|| rec_detail_2nd.GH || '</td>
                   <td class="HDA">'|| rec_detail_2nd.HDA|| '</td>
                   <td class="LT">'|| rec_detail_2nd.LT || '</td>
                   <td class="LWP">'|| rec_detail_2nd.LWP|| '</td>
                   <td class="ML">'|| rec_detail_2nd.ML || '</td>
                   <td class="MR">'|| rec_detail_2nd.MR || '</td>
                   <td class="OH">'|| rec_detail_2nd.OH || '</td>
                   <td class="P">'|| rec_detail_2nd.P || '</td>
                   <td class="SL">'|| rec_detail_2nd.SL || '</td>
                   <td class="SPL">'|| rec_detail_2nd.SPL || '</td>
                   <td class="WO">'|| rec_detail_2nd.WO|| '</td>
                   <td class="TOTAL">'|| rec_detail_2nd.Total || '</td>
                </tr>');
      END LOOP;
   END LOOP;
   
   if  v_last_dept = v_last_dept_br and    v_last_sec = v_last_sec_br --or
       --v_last_desi =rec_master.DESIGNATION_ID
       then
        --
        htp.p('
                  <tr class="u-color-10" group="g-'||v_last_dept||'" subgroup="sg-'||v_last_dept||'-'||v_last_sec||'" >
                     <td></td>
                     <td></td>
                     <td>Section Total</td>
                     <td class="A">' || v_a_total || '</td>
                     <td class="CH">' || v_ch_total || '</td>
                     <td class="CL">' || v_cl_total || '</td>
                     <td class="CML">' || v_cml_total || '</td>
                     <td class="EL">' || v_el_total || '</td>
                     <td class="FH">' || v_fh_total || '</td>
                     <td class="GH">' || v_gh_total || '</td>
                     <td class="HDA">' || v_hda_total || '</td>
                     <td class="LT">' || v_lt_total || '</td>
                     <td class="LWP">' || v_lwp_total || '</td>
                     <td class="ML">' || v_ml_total || '</td>
                     <td class="MR">' || v_mr_total || '</td>
                     <td class="OH">' || v_oh_total || '</td>
                     <td class="P">' || v_p_total || '</td>
                     <td class="SL">' || v_sl_total || '</td>
                     <td class="SPL">' || v_spl_total || '</td>
                     <td class="WO">' || v_wo_total || '</td>
                     <td class="SEC">' || v_sec_total || '</td>
         </tr>    
          <tr class="u-color-11" group="g-'||v_last_dept||'" subgroup="sg-'||v_last_dept||'-'||v_last_sec||'">
                     <td></td>
                    <td>Department Total</td>
                      <td></td>
                     <td class="A">' || v_a_total_dep || '</td>
                     <td class="CH">' || v_ch_total_dep || '</td>
                     <td class="CL">' || v_cl_total_dep || '</td>
                     <td class="CML">' || v_cml_total_dep || '</td>
                     <td class="EL">' || v_el_total_dep || '</td>
                     <td class="FH">' || v_fh_total_dep || '</td>
                     <td class="GH">' || v_gh_total_dep || '</td>
                     <td class="HDA">' || v_hda_total_dep || '</td>
                     <td class="LT">' || v_lt_total_dep || '</td>
                     <td class="LWP">' || v_lwp_total_dep || '</td>
                     <td class="ML">' || v_ml_total_dep || '</td>
                     <td class="MR">' || v_mr_total_dep || '</td>
                     <td class="OH">' || v_oh_total_dep || '</td>
                     <td class="P">' || v_p_total_dep || '</td>
                     <td class="SL">' || v_sl_total_dep || '</td>
                     <td class="SPL">' || v_spl_total_dep || '</td>
                     <td class="WO">' || v_wo_total_dep || '</td>
                     <td class="SEC">' || v_sec_total_dep || '</td>
                     </tr>
               ');
        -- htp.p(v_tag_brk);
         end if;
           htp.p('<tr class="u-color-31">
                     <td></td>
                     <td>Grand Total</td>
                      <td></td>
                     <td class="A">' || v_a_grand || '</td>
                     <td class="CH">' || v_ch_grand || '</td>
                     <td class="CL">' || v_cl_grand || '</td>
                     <td class="CML">' || v_cml_grand || '</td>
                     <td class="EL">' || v_el_grand || '</td>
                     <td class="FH">' || v_fh_grand || '</td>
                     <td class="GH">' || v_gh_grand || '</td>
                     <td class="HDA">' || v_hda_grand || '</td>
                     <td class="LT">' || v_lt_grand || '</td>
                     <td class="LWP">' || v_lwp_grand || '</td>
                     <td class="ML">' || v_ml_grand || '</td>
                     <td class="MR">' || v_mr_grand || '</td>
                     <td class="OH">' || v_oh_grand || '</td>
                     <td class="P">' || v_p_grand || '</td>
                     <td class="SL">' || v_sl_grand || '</td>
                     <td class="SPL">' || v_spl_grand || '</td>
                     <td class="WO">' || v_wo_grand || '</td>
                     <td class="SEC">' || v_sec_grand || '</td>
                     </tr>');
                 
      htp.p('</table>
      <style>
 .A{
     '||
     case when v_a_grand =0 then 'display:none;' end
     ||'
 }
.CH{
    '||
    case when v_ch_grand =0 then 'display:none;' end
    ||'
}
.CL{
    '||
    case when v_cl_grand =0 then 'display:none;' end
    ||'
}
.CML{
    '||
    case when v_cml_grand =0 then 'display:none;' end
    ||'
}
.EL{
    '||
    case when v_el_grand =0 then 'display:none;' end
    ||'
}
.FH{
    '||
    case when v_fh_grand =0 then 'display:none;' end
    ||'
}
.GH{
    '||
    case when v_gh_grand =0 then 'display:none;' end
    ||'
}
.HDA{
    '||
    case when v_hda_grand =0 then 'display:none;' end
    ||'
}
.LT{
    '||
    case when v_lt_grand =0 then 'display:none;' end
    ||'
}
.LWP{
    '||
    case when v_lwp_grand =0 then 'display:none;' end
    ||'
}
.ML{
    '||
    case when v_ml_grand =0 then 'display:none;' end
    ||'
}
.MR{
    '||
    case when v_mr_grand =0 then 'display:none;' end
    ||'
}
.OH{
    '||
    case when v_oh_grand =0 then 'display:none;' end
    ||'
}
.P{
    '||
    case when v_p_grand =0 then 'display:none;' end
    ||'
}
.SL{
    '||
    case when v_sl_grand =0 then 'display:none;' end
    ||'
}
.SPL{
    '||
    case when v_spl_grand =0 then 'display:none;' end
    ||'
}
.WO{
    '||
    case when v_wo_grand =0 then 'display:none;' end
    ||'
}
.SEC{
    '||
    case when v_sec_grand =0 then 'display:none;' end
    ||'
}
      </style>
      ');
      
END;