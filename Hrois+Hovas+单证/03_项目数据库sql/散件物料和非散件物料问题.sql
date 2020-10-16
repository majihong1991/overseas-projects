select material_type
  from CD_MATERIAL   
 where material_code = 'BC10F3Z1G' ;--for update
  
update CD_MATERIAL set MATERIAL_TYPE = '0' where  MATERIAL_code = 'BC10F3Z1G';
