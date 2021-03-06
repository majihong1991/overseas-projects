select t.emp_code, t.name, t.gfname, t.description from 
(select uf.emp_code, uf.name, gf.name as gfname, gf.description,
row_number() over(partition by gf.name order by gf.name asc) rn 
  FROM USER_INFO UF, USER_GROUP UG, GROUP_INFO GF, LOG_ACTION la
 where UG.USER_ID = UF.ID
   and UG.GROUP_ID = GF.ID
   and la.empcode = uf.emp_code
   and uf.emp_code != 'admin'
group by uf.emp_code, uf.name, gf.name, gf.description) t 
where rn <= 5;



select uf.emp_code, uf.name, gf.name as gfname, gf.description
  FROM USER_INFO UF, USER_GROUP UG, GROUP_INFO GF
 where UG.USER_ID = UF.ID
   and UG.GROUP_ID = GF.ID
   and gf.name = '��������'
   and uf.using_flag = '1'
