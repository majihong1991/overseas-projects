SELECT HO.EXE_DATE, --导入时间
       PO.ORDER_NUM, --订单号
       PO.ACT_PREPARE_CODE, --备货单号  
       DT.DEPT_NAME_CN     AS FACTORY_PRODUCE_CODE, --生产工厂 
       HO.MATERIAL_CODE, -- 物料号   
       HO.AFFIRM_CODE      AS AFFIRM_NUM, --特技单号 
       HO.QUANTITY, -- 数量   
       SO.SALES_ORG_CODE, --销售组织 
       HO.SHIP_TO, -- 客户售达方 
       HO.STORAGE_AREA, -- 库存地点
       HO.ORDER_HGVS_CODE, --HGVS销售订单号 
       HO.EXE_FLAG, -- 取数标识  
       HO.EXE_RESULT, --接口信息  
       HO.TJ_FLAG, --套机标识  
       SO.ORDER_TYPE, --订单类型  
       HO.ORDER_HGVS_TYPE, --美国GVS类型
       CY.NAME, --国家    
       PO.MANU_END_DATE --生产计划结束时间 
FROM   ACT_PREPARE_ORDER    PO,
       SO_SALES_ORDER       SO,
       CD_COUNTRY           CY,
       CD_DEPARTMENT        DT,
       SI_HGVS_ORDER_CREATE HO
WHERE  PO.ORDER_NUM = SO.ORDER_CODE
AND    SO.COUNTRY_CODE = CY.COUNTRY_CODE
AND    DT.DEPT_CODE = PO.FACTORY_PRODUCE_CODE
AND    HO.ORDER_CODE = PO.ORDER_NUM
