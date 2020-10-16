SELECT PO.ACT_PREPARE_CODE, --小备单
		       PO.CREATED, --创建时间
		       SO.ORDER_SAP_TYPE ORDER_TYPE, --ZOR还是ZFO，订单类型
		       PO.FACTORY_SETTLEMENT_CODE, --结算工厂
		       SOI.PROD_T_CODE, --产品大类
		       POI.MATERIAL_CODE, --物料号
		       CUST.NAME                  AS CUSTNAME, --客户名称
		       L.ITEM_NAME_CN AS SALE_AREA, --市场区域
		       SO.ORDER_SOURCE_CODE, --hope订单号
		       POI.QUANTITY, --数量
		       DECODE(DT.HGVS_CODE,'',PO.FACTORY_PRODUCE_CODE,NULL,PO.FACTORY_PRODUCE_CODE,DT.HGVS_CODE) FACTORY_PRODUCE_CODE, --生产工厂
		       SO.DEPT_CODE, --经营主体编码
		       SO.ORDER_SOLD_TO, --HOPE售达方
		       M.SPLIT_FLAG, --套机标识0非，1套机
		       --SO.CUSTOMER_CODE, --客户编码
		       SO.US_ORDER_FLAG, --美国GVS
		       SO.ORDER_BUYOUT_FLAG       AS ORDER_BUYOUT_FLAG, --买断标识
		       SOI.AFFIRM_NUM, --特技单号
		       SO.CUSTOMER_CODE, --海外售达方
		       DECODE(SOI.ORDER_OPERATORS_CODE,
                       NULL,
                       DT.OPERATORS_CODE,
                       '',
                       DT.OPERATORS_CODE,
                       '0000006120',
                       '9100000300',
                       '0000006130',
                       '9100000302',
                       '0000006140',
                       '9100000301',
                       '0000006180',
                       '9109000445') AS OPERATORS_CODE, --售达方
		       SO.ORDER_CODE, --订单号
		       PO.MANU_END_DATE, --生产计划结束时间
		       CT.NAME                    AS COUNTRYNAME, --国家名称
		       DT.DEPT_NAME_CN, --工厂名称
		       SO.SALES_ORG_CODE, --销售组织
		       DT.STORE_LOCATION AS STORAGE_AREA --库存地点
		FROM   ACT_PREPARE_ORDER PO
		JOIN   ACT_PREPARE_ORDER_ITEM POI
		ON     PO.ACT_PREPARE_CODE = POI.ACT_PREPARE_ORDER_CODE
		JOIN   SO_SALES_ORDER SO
		ON     PO.ORDER_NUM = SO.ORDER_CODE
		JOIN   SO_SALES_ORDER_ITEM SOI
		ON     (PO.ORDER_NUM = SOI.ORDER_CODE AND
		       SOI.MATERIAL_CODE = POI.MATERIAL_CODE AND
       		   SOI.ORDER_ITEM_ID = POI.ORDER_ITEM_ID)
		LEFT   JOIN CD_CUSTOMER CUST
		ON     SO.ORDER_SOLD_TO = CUST.CUSTOMER_CODE   
		LEFT   JOIN CD_CUSTOMER CUSTT
		ON     SO.CUSTOMER_CODE = CUSTT.CUSTOMER_CODE
		LEFT   JOIN CD_MATERIAL M
		ON     POI.MATERIAL_CODE = M.MATERIAL_CODE
		LEFT   JOIN CD_DEPARTMENT DT
		ON     DT.DEPT_CODE = PO.FACTORY_PRODUCE_CODE
		LEFT   JOIN CD_COUNTRY CT
		ON     CT.COUNTRY_CODE = SO.COUNTRY_CODE
		LEFT   JOIN SYS_LOV L
		ON     (SO.SALE_AREA = L.ITEM_CODE AND L.ITEM_TYPE = '3')
		WHERE  PO.ACT_PREPARE_CODE =''