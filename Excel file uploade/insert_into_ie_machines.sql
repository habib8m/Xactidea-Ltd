CREATE OR REPLACE procedure DEVERP.insert_into_ie_machines
is 
--declare
cursor cur_machines is 
SELECT MX.NAME,
       MX.SHORT_NAME,
       CASE WHEN UPPER(TRIM(MX.POSITIONING)) = 'INSIDE' THEN 1
            WHEN UPPER(TRIM(MX.POSITIONING)) = 'OUTSIDE' THEN 2
            ELSE NULL END AS POSITIONING,
       P.ID AS PROCESS_NAME,
       MX.DIA,
       MX.GAUGE,
       MX.CYLINDER,
       MX.FEEDER,
       MX.CAPACITY_PER_DAY,
       U.ID AS UOM,
       MX.NO_OF_OPERATOR,
       MX.SEQUENCE,
       MX.MAX_RPM,
       MX.CPM,
       R.ID AS RESOURCES,
       MX.EFFICIENCY,
       MX.NO_OF_TUBE,
       MX.REMARKS,
       TI.ID AS MAC_NO
FROM IE_MACHINES_XL MX,
     GBL_PROCESSES P,
     UNITS U,
     GBL_RESOURCES R,
     TAB_INFO TI
WHERE UPPER(TRIM(MX.PROCESS_NAME)) = UPPER(TRIM(P.NAME(+)))
AND UPPER(TRIM(MX.UOM)) = UPPER(TRIM(U.NAME(+)))
AND UPPER(TRIM(MX.RESOURCES)) = UPPER(TRIM(R.NAME(+)))
AND UPPER(TRIM(MX.MAC_NO)) = UPPER(TRIM(TI.TAB_MAC_ID(+)))
AND MX.NAME IS NOT NULL
AND MX.SHORT_NAME IS NOT NULL;

--variable
v_pk number := 0;
v_name varchar2(200);
v_exists number := 0;

begin 
for rec_machines in cur_machines loop 
v_name := rec_machines.name;

--check duplicate name
    begin
    select count(*)
    into v_exists
    from IE_MACHINES im
    where upper(trim(im.name)) = upper(trim(rec_machines.name));
    exception 
    when no_data_found then 
    v_exists := 0;
    end;
    
if v_exists = 0 then
v_pk := next_id('IE_MACHINES');

insert into IE_MACHINES
(ID,
NAME,
SHORT_NAME,
POSITIONING,
CATEGORY_ID,
DIA,
GAUGE,
CYLINDER,
FEEDER,
CAPACITY_PER_DAY,
UOM_ID,
NO_OF_OPERATOR,
SEQUENCE,
MAX_RPM,
CPM,
PROCESS_TYPE_ID,
EFFICIENCY,
NO_OF_TUBE,
REMARKS,
ADD_DEVICE_ID
)

VALUES
(
v_pk,
rec_machines.NAME,
rec_machines.SHORT_NAME,
rec_machines.POSITIONING,
rec_machines.PROCESS_NAME,
rec_machines.DIA,
rec_machines.GAUGE,
rec_machines.CYLINDER,
rec_machines.FEEDER,
rec_machines.CAPACITY_PER_DAY,
rec_machines.UOM,
rec_machines.NO_OF_OPERATOR,
rec_machines.SEQUENCE,
rec_machines.MAX_RPM,
rec_machines.CPM,
rec_machines.RESOURCES,
rec_machines.EFFICIENCY,
rec_machines.NO_OF_TUBE,
rec_machines.REMARKS,
rec_machines.MAC_NO
);

commit;
end if;
end loop;

delete from IE_MACHINES_XL;
commit;

exception when others then 
null;

--dbms_output.put_line('Error in name: '|| v_name);
--dbms_output.put_line(SQLCODE||'-'||SQLERRM);

end;
/
