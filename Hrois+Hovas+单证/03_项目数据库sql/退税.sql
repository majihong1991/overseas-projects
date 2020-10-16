SELECT DISTINCT RES.ID_                          AS TASK_ID,
                RES.*,
                WF.*,
                FORMTABLE.*,
                TAXBACKINFO_.ROW_ID              AS TAX_ROW_ID,
                TAXBACKINFO_.APPLY_CODE,
                TAXBACKINFO_.APPLY_DATE,
                TAXBACKINFO_.CREATE_DATE,
                TAXBACKINFO_.COMPREE_CODE,
                TAXBACKINFO_.INVOICE_COMPANY,
                TAXBACKINFO_.PRODUCT_CODE,
                TAXBACKINFO_.HAIER_MODEL,
                TAXBACKINFO_.UNIT,
                TAXBACKINFO_.AMOUNT,
                TAXBACKINFO_.MONEY_TYPE,
                TAXBACKINFO_.PRICE,
                TAXBACKINFO_.EXPORT_AMOUNT,
                TAXBACKINFO_.SHIP_FEE,
                TAXBACKINFO_.FOB_AMOUNT,
                TAXBACKINFO_.USD_EXCHANGE_RATE,
                TAXBACKINFO_.APPLY_AMOUNT,
                TAXBACKINFO_.PREPARE_FACTORY,
                TAXBACKINFO_.CUSTOM_DATE,
                TAXBACKINFO_.AGENCY_BILL_CODE,
                TAXBACKINFO_.CUSTOM_CODE,
                TAXBACKINFO_.EXPORT_INVOICE_CODE,
                TAXBACKINFO_.ORIGINAL_USD_RATE,
                TAXBACKINFO_.PRODUCT_FACTORY,
                TAXBACKINFO_.CUSTOM_GOODS_NAME,
                TAXBACKINFO_.CUSTOM_GOODS_CODE,
                TAXBACKINFO_.MERGE_FALG,
                TAXBACKINFO_.MERGE_VALUE,
                TAXBACKINFO_.TAX_BACK_FALG,
                TAXBACKINFO_.TAX_BACK_DATE,
                DOC.DOC_CODE                     AS DOCCODE,
                DOC.BOOKS_NUM                    AS BOOKNUM
FROM   ACT_RU_TASK RES
INNER  JOIN ACT_RU_IDENTITYLINK I
ON     I.TASK_ID_ = RES.ID_
INNER  JOIN WF_PROCINSTANCE WF
ON     WF.PROCESSINSTANCE_ID = RES.PROC_INST_ID_
INNER  JOIN (SELECT T0.ORDER_CODE              AS ORDER_CODE,
                    T0.CONTRACT_CODE           AS CONTRACT_CODE,
                    T0.ORDER_SOURCE_CODE       AS ORDER_SOURCE_CODE,
                    T0.ORDER_PO_CODE           AS ORDER_PO_CODE,
                    T0.ORDER_TYPE              AS ORDER_TYPE,
                    T0.ORDER_CREATE_DATE       AS ORDER_CREATE_DATE,
                    T0.ORDER_SHIP_DATE         AS ORDER_SHIP_DATE,
                    T0.ORDER_CUSTOM_DATE       AS ORDER_CUSTOM_DATE,
                    T0.SALES_ORG_CODE          AS SALES_ORG_CODE,
                    T0.SALE_AREA               AS SALE_AREA,
                    T0.ORDER_DEAL_TYPE         AS ORDER_DEAL_TYPE,
                    T0.COUNTRY_CODE            AS COUNTRY_CODE,
                    T0.ORDER_MARKET_CENTER     AS ORDER_MARKET_CENTER,
                    T0.DEPT_CODE               AS DEPT_CODE,
                    T0.ORDER_SHIP_TO           AS ORDER_SHIP_TO,
                    T0.ORDER_SOLD_TO           AS ORDER_SOLD_TO,
                    T0.ORDER_CUST_NAMAGER      AS ORDER_CUST_NAMAGER,
                    T0.ORDER_PROD_MANAGER      AS ORDER_PROD_MANAGER,
                    T0.ORDER_EXEC_MANAGER      AS ORDER_EXEC_MANAGER,
                    T0.ORDER_TRANS_MANAGER     AS ORDER_TRANS_MANAGER,
                    T0.ORDER_REC_MANAGER       AS ORDER_REC_MANAGER,
                    T0.CURRENCY                AS CURRENCY,
                    T0.TO_USA_EXCHANGE         AS TO_USA_EXCHANGE,
                    T0.TO_CNY_EXCHANGE         AS TO_CNY_EXCHANGE,
                    T0.ORDER_LOCKEXCHANGE_FLAG AS ORDER_LOCKEXCHANGE_FLAG,
                    T0.ORDER_SHIPMENT          AS ORDER_SHIPMENT,
                    T0.ORDER_TRANS_TYPE        AS ORDER_TRANS_TYPE,
                    T0.PORT_START_CODE         AS PORT_START_CODE,
                    T0.PORT_END_CODE           AS PORT_END_CODE,
                    T0.VENDOR_CODE             AS VENDOR_CODE,
                    T0.ORDER_SETTLEMENT_TYPE   AS ORDER_SETTLEMENT_TYPE,
                    T0.ORDER_NEGO_SUBJECT      AS ORDER_NEGO_SUBJECT,
                    T0.ORDER_BRAND             AS ORDER_BRAND,
                    T0.ORDER_PAYMENT_METHOD    AS ORDER_PAYMENT_METHOD,
                    T0.ORDER_PAYMENT_TERMS     AS ORDER_PAYMENT_TERMS,
                    T0.ORDER_PAYMENT_CYCLE     AS ORDER_PAYMENT_CYCLE,
                    T0.ORDER_HGVS_FLAG         AS ORDER_HGVS_FLAG,
                    T0.ORDER_EXPRESS_FLAG      AS ORDER_EXPRESS_FLAG,
                    T0.ORDER_INSPECTION_FLAG   AS ORDER_INSPECTION_FLAG,
                    T0.SPECIAL_INSPECTION_FLAG AS SPECIAL_INSPECTION_FLAG,
                    T0.ORDER_AUDIT_FLAG        AS ORDER_AUDIT_FLAG,
                    T0.ORDER_AUDIT_DATE        AS ORDER_AUDIT_DATE,
                    T0.ACTIVE_FLAG             AS ACTIVE_FLAG,
                    T0.CREATED_BY              AS CREATED_BY,
                    T0.CREATED                 AS CREATED,
                    T0.LAST_UPD_BY             AS LAST_UPD_BY,
                    T0.LAST_UPD                AS LAST_UPD,
                    T0.MODIFICATION_NUM        AS MODIFICATION_NUM,
                    T0.ORDER_BUYOUT_FLAG       AS ORDER_BUYOUT_FLAG,
                    T0.ORDER_ATTACHMENTS       AS ORDER_ATTACHMENTS,
                    T0.CUSTOMER_CODE           AS CUSTOMER_CODE,
                    T0.TMODEL_CODE             AS TMODEL_CODE,
                    T0.INVOICE_NUM             AS INVOICE_NUM,
                    T0.COMPRE_NUM              AS COMPRE_NUM,
                    T0.INTERFACE_ROW_ID        AS INTERFACE_ROW_ID,
                    T0.US_ORDER_FLAG           AS US_ORDER_FLAG
             FROM   HROIS.SO_SALES_ORDER T0
             WHERE  ((T0.FACTORY_CODE) IN
                    (SELECT T0.CONFIG_VALUE AS CONFIG_VALUE
                      FROM   HROIS.USER_DATA_CONFIG T0
                      WHERE  (T0.EMPLOYEE_CODE = 'admin' AND
                             T0.CONFIG_TYPE = 'FACTORY')))) FORMTABLE
ON     FORMTABLE.ORDER_CODE = WF.BUSINFORM_ID
LEFT   JOIN ACT_TAX_BACK_INFO TAXBACKINFO_
ON     TAXBACKINFO_.ORDER_CODE = FORMTABLE.ORDER_CODE
LEFT   JOIN ACT_CHECK_EXPORT_DOC DOC
ON     DOC.ORDER_CODE = FORMTABLE.ORDER_CODE
WHERE  RES.TASK_DEF_KEY_ = 'backTax'
AND    ((RES.ASSIGNEE_ IN ('NAME')) OR
      (RES.ASSIGNEE_ IS NULL AND I.TYPE_ = 'candidate' AND
      (I.GROUP_ID_ IN ('GROUP'))))
AND    RES.SUSPENSION_STATE_ = 1
