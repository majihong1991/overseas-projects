SELECT HO.EXE_DATE, --导入时间
       PO.ORDER_NUM, --订单号 
       PO.ACT_PREPARE_CODE, --备货单号
       DT.DEPT_NAME_CN, --生产工厂
       HO.MATERIAL_CODE, -- 物料号
       HO.AFFIRM_CODE AS AFFIRM_NUM, --特技单号
       CY.NAME, --国家
       PO.MANU_END_DATE, --生产计划结束时间 
       HO.EXE_RESULT, --返回信息
       HO.EXE_FLAG --是否通过
FROM   ACT_PREPARE_ORDER PO
JOIN   SO_SALES_ORDER SO
ON     PO.ORDER_NUM = SO.ORDER_CODE
JOIN   SI_HGVS_ORDER_CREATE HO
ON     HO.ORDER_CODE = PO.ORDER_NUM
LEFT   JOIN CD_COUNTRY CY
ON     SO.COUNTRY_CODE = CY.COUNTRY_CODE
LEFT   JOIN CD_DEPARTMENT DT
ON     DT.DEPT_CODE = PO.FACTORY_PRODUCE_CODE
