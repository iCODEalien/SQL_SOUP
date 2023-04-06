create or replace package EMP_PCK 
as                                      
                                        
procedure sp_employees_collection( p_error out varchar2,
                                   p_err_cnt out number,
                                   p_proc_cnt out number);

procedure sp_ctrl_procedure;

end EMP_PCK;
