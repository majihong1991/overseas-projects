SELECT T0.start_date,
       T0.valid_date,
       T0.is_del,
       T0.status,      
       T1.Material_Code,
       t1.active_flag
  FROM TH_PRICE T0
  LEFT JOIN TH_MATERIAL T1
    ON T0.MATERIAL_CODE = T1.MATERIAL_CODE
  left join th_port t2
    on t0.LOADING_PORT = t2.PORT_CODE
  left join th_port t3
    on t0.DESTINATION_PORT = t3.PORT_CODE
 WHERE T0.CONTRACT_CODE = 'SC10010208'
      --AND trunc(?) >= trunc(t0.START_DATE)
      --AND trunc(?) <= trunc(t0.valid_date)
   AND T0.IS_DEL = 0
   AND T0.status = 2
   AND T1.ACTIVE_FLAG = 1
   AND T0.ACTIVE_FLAG = 1
   AND T0.MATERIAL_CODE IN (SELECT t4.MATERIAL_CODE
                              FROM TH_CONTRACT_ITEM T4
                             WHERE T4.CONTRACT_CODE = 'SC10010208'
                               AND T4.ACTIVE_FLAG = 1)
