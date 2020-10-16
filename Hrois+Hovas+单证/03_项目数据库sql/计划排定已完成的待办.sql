SELECT DISTINCT RES.ID_                     AS TASK_ID,
                        RES.*,
                        WF.*,
                        FORMTABLE.ORDER_CODE        ORDERCODE,
                        FACTORY.DEPT_NAME_CN        FACTORYPRODUCENAME,
                        ORDERTYPE.ITEM_NAME_CN      ORDERTYPENAME,
                        FORMTABLE.CONTRACT_CODE     CONTRACTCODE,
                        FORMTABLE.ORDER_SHIP_DATE   ORDERSHIPDATE,
                        FORMTABLE.ORDER_CUSTOM_DATE ORDERCUSTOMDATE,
                        DEALTYPE.ITEM_NAME_CN       DEALTYPENAME,
                        CURRENCY.ITEM_NAME_CN       CURRENCYNAME,
                        FORMTABLE.ORDER_TYPE        ORDERTYPECODE,
                        PAYMENT.TERMS_DESC          TERMSDESC,
                        SALESORG.SALE_ORG_NAME      SALESORGNAME,
                        COUNTRY.NAME                COUNTRYNAME,
                        CUSTOMER.NAME               CUSTOMERNAME,
                        FORMTABLE.ORDER_PO_CODE     ORDERSOURCECODE,
                        DEPARTMENT.DEPT_NAME_CN     DEPARTMENTNAME,
                        PORTSTART.ITEM_NAME_CN      PORTSTARTNAME,
                        PORTEND.PORT_NAME           PORTENDNAME,
                        VENDOR.VENDOR_NAME_CN       VENDORNAME
        FROM   ACT_HI_TASKINST RES
        INNER  JOIN WF_PROCINSTANCE WF
        ON     WF.PROCESSINSTANCE_ID = RES.PROC_INST_ID_
        INNER  JOIN (SELECT T0.ORDER_CODE              AS ORDER_CODE,
                           T1.FACTORY_PRODUCE_CODE    AS FACTORY_PRODUCE_CODE,
                           T6.NAME                    AS ORDER_PRO_MANAGER,
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
                           T0.ORDER_NOTIFY            AS ORDER_NOTIFY,
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
                           T0.US_ORDER_FLAG           AS US_ORDER_FLAG,
                           T0.ORDER_DOC_MANAGER       AS ORDER_DOC_MANAGER
                    FROM   HROIS.SO_SALES_ORDER    T0,
                           HROIS.ACT_PREPARE_ORDER T1,
                           HROIS.USER_INFO         T6
                    WHERE  (T0.ORDER_CODE = T1.ORDER_NUM AND
                           T0.ORDER_PROD_MANAGER = T6.EMP_CODE AND
                           T0.ORDER_AUDIT_FLAG = '1' AND
                           (T1.FACTORY_PRODUCE_CODE) IN
                           (SELECT T0.CONFIG_VALUE AS CONFIG_VALUE
                             FROM   HROIS.USER_DATA_CONFIG T0
                             WHERE  (T0.EMPLOYEE_CODE = 'admin' AND
                                    T0.CONFIG_TYPE = 'FACTORY')))) FORMTABLE
        ON     FORMTABLE.ORDER_CODE = WF.BUSINFORM_ID
        LEFT   JOIN SYS_LOV ORDERTYPE
        ON     (ORDERTYPE.ITEM_CODE = FORMTABLE.ORDER_TYPE AND
               ORDERTYPE.ITEM_TYPE = '0')
        LEFT   JOIN CD_DEPARTMENT DEPARTMENT
        ON     (DEPARTMENT.DEPT_CODE = FORMTABLE.DEPT_CODE AND
               DEPARTMENT.DEPT_TYPE = '1')
        LEFT   JOIN CD_SALE_ORG SALESORG
        ON     SALESORG.SALE_ORG_CODE = FORMTABLE.SALES_ORG_CODE
        LEFT   JOIN SYS_LOV DEALTYPE
        ON     (DEALTYPE.ITEM_CODE = FORMTABLE.ORDER_DEAL_TYPE AND
               DEALTYPE.ITEM_TYPE = '2')
        LEFT   JOIN CD_DEPARTMENT FACTORY
        ON     (FACTORY.DEPT_CODE = FORMTABLE.FACTORY_PRODUCE_CODE AND
               FACTORY.DEPT_TYPE = '0')
        LEFT   JOIN SYS_LOV CURRENCY
        ON     (CURRENCY.ITEM_CODE = FORMTABLE.CURRENCY AND
               CURRENCY.ITEM_TYPE = '13')
        LEFT   JOIN CD_PAYMENT_TERMS PAYMENT
        ON     PAYMENT.TERMS_CODE = FORMTABLE.ORDER_PAYMENT_TERMS
        LEFT   JOIN CD_COUNTRY COUNTRY
        ON     COUNTRY.COUNTRY_CODE = FORMTABLE.COUNTRY_CODE
        LEFT   JOIN CD_CUSTOMER CUSTOMER
        ON     CUSTOMER.CUSTOMER_CODE = FORMTABLE.ORDER_SOLD_TO
        LEFT   JOIN SYS_LOV PORTSTART
        ON     (PORTSTART.ITEM_CODE = FORMTABLE.PORT_START_CODE AND
               PORTSTART.ITEM_TYPE = '17')
        LEFT   JOIN CD_PORT PORTEND
        ON     PORTEND.PORT_CODE = FORMTABLE.PORT_END_CODE
        LEFT   JOIN CD_VENDOR VENDOR
        ON     (VENDOR.VENDOR_CODE = FORMTABLE.VENDOR_CODE AND
               VENDOR.VENDOR_TYPE = '0')
        WHERE RES.END_TIME_ IS NOT NULL
        AND    FORMTABLE.CREATED >= TO_DATE('2013-10-14 00:00','yyyy-MM-dd HH24:mi')
        AND    FORMTABLE.CREATED <= TO_DATE('2013-10-15 00:00','yyyy-MM-dd HH24:mi')
