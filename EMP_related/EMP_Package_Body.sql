create or replace package body EMP_PCK
as

procedure sp_employees_collection( p_error out varchar2,
                                   p_err_cnt out number,
                                   p_proc_cnt out number)
    as
    type v_tab is table of employees%rowtype; -- declaring
    col_obj v_tab := v_tab(); -- defining and initializing.
    
    lv_error_count number := 0;
    lv_processed_count number := 0;
    lv_temp_emp_id number := 0;
    
begin
    --- get the current record employee id from temp table.
    select
        employee_id
        into
            lv_temp_emp_id
    from
        temp_table;
    
    col_obj.extend(3);
    
    --- populating the collection.
    select * bulk collect into col_obj from employees
    where employee_id > lv_temp_emp_id;
    
    for i in 1..col_obj.last
    loop
        if col_obj(i).first_name like 'S%' 
           or extract(year from col_obj(i).hire_date) < 2005 then
                dbms_output.put_line('BAD RECORD:                 '||col_obj(i).First_name||'  '||col_obj(i).salary||'  '||col_obj(i).hire_date);
                update temp_table
                SET EMPLOYEE_ID = col_obj(i).employee_id;
                lv_error_count := lv_error_count + 1;
                commit;
                exit;
        else 
            dbms_output.put_line('GOOD RECORD :   '||col_obj(i).First_name||'  '||col_obj(i).salary||'  '||col_obj(i).hire_date);
            lv_processed_count := lv_processed_count + 1;
            update temp_table
                SET EMPLOYEE_ID = col_obj(i).employee_id;
                lv_error_count := lv_error_count + 1;
            commit;
        end if;
    end loop;
    p_error := SQLERRM;
    p_err_cnt := lv_error_count;
    p_proc_cnt := lv_processed_count;
end;


procedure SP_CTRL_PROCEDURE  
    as
    pr_proc_cnt number :=0;
    pr_err_cnt number :=0;
    lv_err_m varchar2(200);
    total_records number := 0;
    lv_err_cntr number :=0;
    lv_processed_cntr number :=0;
    lv_temp_emp_id number;
begin
    -- getting the temp_employee_id
    select
        employee_id
        into
            lv_temp_emp_id
    from temp_table;
    
    --- Getting the count
    select 
        count(1) 
        into 
            total_records
    from
        employees
    where employee_id > lv_temp_emp_id;
        
    --- Feedback loop
     while total_records >  lv_err_cntr + lv_processed_cntr 
     loop
        sp_employees_collection(lv_err_m, pr_err_cnt,pr_proc_cnt);
        dbms_output.put_line ('Error MSG : '|| lv_err_m);
        dbms_output.put_line( 'Processed rows count: '||pr_proc_cnt||'    Error rows count: '||pr_err_cnt);
        lv_err_cntr := lv_err_cntr + pr_err_cnt;
        lv_processed_cntr := lv_processed_cntr + pr_proc_cnt;
    end loop;
    dbms_output.put_line('Process Completed. Total rows: '||total_records||'  Processed records: '||lv_processed_cntr||' Error records: '||lv_err_cntr);
end;

END EMP_PCK;