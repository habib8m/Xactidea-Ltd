CREATE OR REPLACE procedure DEVERP.insert_into_ie_operations
is 
cursor cur_operation is 
SELECT IO.ID,
       IO.NAME,
       IO.SHORT_NAME,
       IP.ID AS PLACE,
       nvl(case when UPPER(TRIM(io.TYPE)) = 'BASIC' then 'B'
            when UPPER(TRIM(io.TYPE)) = 'CRITICAL' then 'C'
            when UPPER(TRIM(io.TYPE)) = 'SEMI CRITICAL' then 'S'
            end, 'B') as type,
       vm.id as machine,
       git.g_item_code as gmt_item,
       up.id as BODY_PART,
       gr.id as RESOURCE_ID,
       case when upper(trim(io.SMV_TYPE)) = 'CALCULATIVE' then 1
            when upper(trim(io.SMV_TYPE)) = 'NON CALCULATIVE' then 0
            end as smv_type,
       io.CODE,
       IO.MACHINE_SMV,
       IO.MAN_SMV,
       IO.TOTAL,
       gp.id as process,
       gbn.id as BN
FROM IE_OPERATIONS_XL IO,
     IE_PLACES IP,
     (select name , id from V_MACHINES_NEW where status = 'Active') vm,
     g_item_tbl git,
     (SELECT name, id FROM references WHERE key = 'ACC_USED_PLACE' OR key = 'FAB_USED_PLACE') up,
     gbl_resources gr,
     GBL_PROCESSES gp,
     GBL_BUSINESS_NATURES gbn
WHERE UPPER(TRIM(IO.PLACE)) = UPPER(TRIM(IP.NAME(+)))
and upper(trim(io.MACHINE)) = upper(trim(vm.name(+)))
and upper(trim(io.GMT_ITEM)) = upper(trim(git.g_item_name(+)))
and upper(trim(io.BODY_PART)) = upper(trim(up.name(+)))
and upper(trim(io.RESOURCE_ID)) = upper(trim(gr.name(+)))
and upper(trim(io.PROCESS)) = upper(trim(gp.name(+)))
and upper(trim(io.bn)) = upper(trim(gbn.BUSINESS_NATURE(+)));

--variable
v_pk number := 0;
v_name varchar2(200);
v_exists number := 0;

begin 
for rec_operation in cur_operation loop 
v_name := rec_operation.name;

--check duplicate name
    begin
    select count(*)
    into v_exists
    from IE_OPERATIONS io
    where upper(trim(io.name)) = upper(trim(rec_operation.name))
    or (upper(trim(io.name)) = upper(trim(rec_operation.name)) and upper(trim(io.total)) = upper(trim(rec_operation.total)));
    exception 
    when no_data_found then 
    v_exists := 0;
    end;
    
if v_exists = 0 then
v_pk := next_id('IE_OPERATIONS');

insert into IE_OPERATIONS
(ID,
NAME,
SHORT_NAME,
PLACE_ID,
TYPE,
GMT_ITEM_ID,
RESOURCE_ID,
BODY_PART_ID,
CODE,
SMV_TYPE,
MACHINE_SMV,
MAN_SMV,
TOTAL,
PROCESS_ID,
BN_ID,
MACHINE_ID
)
VALUES 
(
v_pk,
rec_operation.NAME,
rec_operation.SHORT_NAME,
rec_operation.PLACE,
rec_operation.type,
rec_operation.gmt_item,
rec_operation.RESOURCE_ID,
rec_operation.BODY_PART,
rec_operation.CODE,
rec_operation.SMV_TYPE,
rec_operation.MACHINE_SMV,
rec_operation.MAN_SMV,
rec_operation.TOTAL,
rec_operation.process,
rec_operation.BN,
rec_operation.machine
);
commit;
end if;
end loop;


delete from IE_OPERATIONS_XL;
commit;

exception when others then 
null;
--dbms_output.put_line('Error in name: '|| v_name);
--dbms_output.put_line(SQLCODE||'-'||SQLERRM);
end insert_into_ie_operations;
/
