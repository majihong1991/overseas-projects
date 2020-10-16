select distinct RES.*,
                P.*,
                P.*
  from ACT_RU_EXECUTION RES
 inner join ACT_RE_PROCDEF P
    on RES.PROC_DEF_ID_ = P.ID_
 inner join ACT_RU_IDENTITYLINK I
    on I.PROC_INST_ID_ = RES.ID_
   and res.business_key_ = '0004352660'
   
   select * from ACT_RU_EXECUTION a where a.business_key_ = '0004352660';


