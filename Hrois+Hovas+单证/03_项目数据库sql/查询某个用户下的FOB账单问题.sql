select FORMTABLE.*
          from ACT_RU_TASK RES
         inner join WF_PROCINSTANCE WF
            on WF.PROCESSINSTANCE_ID = RES.PROC_INST_ID_
          LEFT join (SELECT SO.ORDER_CODE,
                           SO.ORDER_TYPE,
                           OT.ITEM_NAME_CN ORDER_TYPE_NAME,
                           SO.ORDER_SAP_TYPE,
                           SO.DEPT_CODE,
                           CD.DEPT_NAME_CN DEPT_NAME,
                           CD.OPERATORS,
                           SO.PORT_START_CODE,
                           SP.ITEM_NAME_EN PORT_START_NAME,
                           SO.PORT_END_CODE,
                           CP.ENGLISH_NAME PORT_END_NAME,
                           SO.ORDER_SOLD_TO,
                           CC.NAME CUSTOMER_NAME,
                           SO.VENDOR_CODE,
                           (SELECT CV.VENDOR_NAME_EN
                              FROM CD_VENDOR CV
                             WHERE CV.VENDOR_CODE = SO.VENDOR_CODE
                               AND CV.VENDOR_TYPE =
                                   DECODE(SO.ORDER_SHIPMENT,
                                          '02',
                                          '4',
                                          '03',
                                          '3',
                                          '0')
                               AND CV.ACTIVE_FLAG = '1') VENDOR_NAME,
                           SO.ORDER_SHIPMENT,
                           SM.ITEM_NAME_CN ORDER_SHIPMENT_NAME,
                           SO.ORDER_SHIP_DATE,
                           SO.ORDER_DEAL_TYPE,
                           DT.ITEM_NAME_CN ORDER_DEAL_NAME,
                           (SELECT TO_CHAR(WM_CONCAT(SO1.OBD_NAME_CN || '*' ||
                                                     TO_CHAR(SUM(SC.CONDITION_RATE),
                                                             'FM9999999990.00')))
                              FROM SO_SALES_ORDER_CONDITION SC, SYS_OBD SO1
                             WHERE SC.CONDITION_CODE = SO1.OBD_CODE
                               AND SO1.CONDITION_TYPE = 'A'
                               AND SC.CONDITION_RATE > 0
                               AND SC.ORDER_CODE = SO.ORDER_CODE
                             GROUP BY SO1.OBD_NAME_CN) AS CONTAINER,
                           CTY.ALIAS COUNTRYNAME,
                           OC.H20,
                           OC.H40,
                           OC.NH40,
                           OC.H45,
                           SO.SP_ZOR
                      FROM SO_SALES_ORDER SO,
                           (SELECT * FROM SYS_LOV WHERE ITEM_TYPE = '0') OT,
                           (SELECT * FROM CD_DEPARTMENT WHERE DEPT_TYPE = '1') CD,
                           (SELECT * FROM SYS_LOV WHERE ITEM_TYPE = '17') SP,
                           CD_PORT CP,
                           CD_CUSTOMER CC,
                           (SELECT * FROM SYS_LOV WHERE ITEM_TYPE = '7') SM,
                           (SELECT * FROM SYS_LOV WHERE ITEM_TYPE = '2') DT,
                           CD_COUNTRY CTY,
                           VI_ORDER_CNT_NUM OC
                     WHERE SO.ORDER_TYPE = OT.ITEM_CODE(+)
                       AND SO.DEPT_CODE = CD.DEPT_CODE(+)
                       AND SO.PORT_START_CODE = SP.ITEM_CODE(+)
                       AND SO.PORT_END_CODE = CP.PORT_CODE(+)
                       AND SO.ORDER_SOLD_TO = CC.CUSTOMER_CODE(+)
                       AND SO.ORDER_SHIPMENT = SM.ITEM_CODE(+)
                       AND SO.ORDER_DEAL_TYPE = DT.ITEM_CODE(+)
                       AND SO.COUNTRY_CODE = CTY.COUNTRY_CODE(+)
                       AND SO.ORDER_CODE = OC.ORDER_CODE(+)
                       AND SO.ORDER_AUDIT_FLAG != 2) FORMTABLE
            ON FORMTABLE.ORDER_CODE = WF.BUSINFORM_ID
         WHERE nvl(FORMTABLE.ORDER_CODE, '-') <> '-'
           and RES.ASSIGNEE_ in ('00049329')
           --and RES.TASK_DEF_KEY_ ='bookCabinConfirm'
           and RES.SUSPENSION_STATE_ = 1
         ORDER BY ORDER_SHIP_DATE ASC
