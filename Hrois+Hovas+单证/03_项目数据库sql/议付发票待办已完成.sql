SELECT DISTINCT RES.ID_                AS TASK_ID,
                                RES.*,
                                WF.*,
                                FORMTABLE.*,
                                NEGO.NEGO_INVOICE_NUM,
                                COUNTRY.NAME           AS CTYNAME,
                                DEP.DEPT_NAME_CN       AS DEPNAME,
                                CUS.NAME               AS CUSNAME,
                                ORDERTYPE.ITEM_NAME_CN ORDERTYPENAME,
                                FACTORY.OPERATORS      AS OPERATORS
                FROM   ACT_HI_TASKINST RES
                INNER  JOIN WF_PROCINSTANCE WF
                ON     WF.PROCESSINSTANCE_ID = RES.PROC_INST_ID_
                INNER  JOIN (SELECT * FROM SO_SALES_ORDER) FORMTABLE
                ON     FORMTABLE.ORDER_CODE = WF.BUSINFORM_ID
                LEFT   JOIN SO_SALES_ORDER_ITEM SOI
                ON     FORMTABLE.ORDER_CODE = SOI.ORDER_CODE
                LEFT   JOIN ACT_NEGO_ORDER NEGO
                ON     NEGO.ORDER_CODE = FORMTABLE.ORDER_CODE
                LEFT   JOIN CD_COUNTRY COUNTRY
                ON     COUNTRY.COUNTRY_CODE = FORMTABLE.COUNTRY_CODE
                LEFT   JOIN CD_DEPARTMENT DEP
                ON     (DEP.DEPT_CODE = FORMTABLE.DEPT_CODE AND
                       DEP.DEPT_TYPE = '1')
                LEFT   JOIN SYS_LOV ORDERTYPE
                ON     (ORDERTYPE.ITEM_CODE = FORMTABLE.ORDER_SETTLEMENT_TYPE AND
                       ORDERTYPE.ITEM_TYPE = '9')
                LEFT   JOIN CD_DEPARTMENT FACTORY
                ON     (FACTORY.DEPT_CODE = SOI.FACTORY_CODE AND
                       FACTORY.DEPT_TYPE = '0')
                LEFT   JOIN CD_CUSTOMER CUS
                ON     CUS.CUSTOMER_CODE = FORMTABLE.ORDER_SOLD_TO
                WHERE  RES.TASK_DEF_KEY_ = 'conferPayInvoice'
               -- AND    RES.ASSIGNEE_ = ?
                AND    RES.END_TIME_ IS NOT NULL
