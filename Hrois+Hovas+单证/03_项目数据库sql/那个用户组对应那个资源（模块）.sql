select d.* from RESOURCE_INFO a,role_resource b,role_group c,group_info d where 
a.id = b.resource_id
and b.role_id = c.role_id
and c.group_id = d.id 

and a.name like 'F-GAS%'

select * from role_resource  where a.resource_id = '6525'

select * from role_group  where b.role_id in ('2','1','7','8') 

select * from group_info  where c.id in ('2','1','7','8') 


select ug.*
  from user_info ui, user_group ug, group_info gi
 where ui.id = ug.user_id
   and gi.id = ug.group_id
--and ui.emp_code = '01492130'
   and gi.code = 'BUSSINESSMANAGER'
   
    
   select * from user_group aa where aa.group_id = '6' and aa.emp_code = '01492130' for update
