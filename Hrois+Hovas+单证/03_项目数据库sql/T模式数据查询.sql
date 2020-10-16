select *
  from cd_tmod_set
 where tmod_name = '内销标准订单T模式'
and tmod_act_id = 'getNegoInfoFromHope'
   AND auto_flag = '1'
   AND active_flag = '1' for update;
   
   
   
               
SELECT COUNT(*)
  FROM SO_SALES_ORDER T
 WHERE T.ORDER_TYPE = '005'
   AND T.SALES_ORG_CODE = '6180'
   AND T.ORDER_HGVS_FLAG = '1'
   AND T.ORDER_INSPECTION_FLAG = '0'
   AND T.ORDER_EXPRESS_FLAG = '0'
   AND T.ORDER_CODE =;
   
select * from CD_TMOD_CONFIG t; --where t.tmod_sql like '%6180%';


