SELECT * FROM (SELECT '' AS ROW_ID,
       SO.ORDER_CODE,
       ABO.BOOK_CODE,
       ABOI.MERGE_CUST_FLAG,
       ZH_CONCAT(DISTINCT CPT.PROD_TYPE) AS PROD_TYPE,
                SO.ORDER_DEAL_TYPE,
                SL1.ITEM_NAME_CN AS PORT_START_NAME,
                CP.PORT_NAME AS PORT_END_NAME,
                TRIM(VOC.XXXL) AS XXXL,
                NULL AS CHAYI,
                NULL AS LUMP_SUM,
                CVV.VENDOR_NAME_CN,
                ABO.FORWARD_AGENT,
                ABO.FORWARD_AGENT_CONTACT,
                '' AS FOREIGN_SIGN,
                ACO.CUST_DATE,
                ASO.SAIL_DATE AS SAIL_DATE,
                UI1.NAME AS ORDER_MANGER_NAME,
                -2 AS LOGO,
                '' AS UPLOAD_FILE,
                NULL AS INDUSTRY_PAY,
                NULL AS FACTORY_PAY

  FROM SO_SALES_ORDER           SO,
       SO_SALES_ORDER_ITEM SOI,
       ACT_FOB_DEBIT_NOTE_ORDER AFO,
       SO_ACT                   SA1,
       ACT_BOOK_ORDER_ITEM      ABOI,
       ACT_BOOK_ORDER           ABO,
       CD_PROD_TYPE             CPT,
       SYS_LOV                  SL1,
       CD_PORT                  CP,
       VI_ORDER_CNT_CONCAT      VOC,
       CD_VENDOR                CVV,
       ACT_CUST_ORDER           ACO,
       ACT_SHIP_ORDER           ASO,
       USER_INFO                UI1
 WHERE SO.ORDER_CODE NOT IN (SELECT AFO.ORDER_CODE FROM ACT_FOB_DEBIT_NOTE_ORDER AFO)
 AND SO.ORDER_DEAL_TYPE = 'FOB'
 AND SO.ORDER_SHIPMENT = '01'
   AND SO.ORDER_CREATE_DATE >= TO_DATE('2018-01-01', 'YYYY-MM-DD')
   AND SO.ORDER_CODE = SA1.ORDER_NUM
   AND SA1.ACT_ID = 'declarationApply'
   AND SA1.STATUS_CODE = 'end'
   AND ABOI.ORDER_CODE = SO.ORDER_CODE
   AND ABOI.BOOK_CODE = ABO.BOOK_CODE
   AND SOI.ORDER_CODE = SO.ORDER_CODE
   AND SOI.PROD_T_CODE = CPT.PROD_TYPE_CODE
   AND SL1.ITEM_TYPE = '17'
   AND SO.PORT_START_CODE = SL1.ITEM_CODE
   AND SO.PORT_END_CODE = CP.PORT_CODE
   AND SO.ORDER_CODE = VOC.ORDER_CODE
   AND ABO.BOOK_AGENT = CVV.VENDOR_CODE
   AND SO.ORDER_CODE = ASO.ORDER_NUM(+)
   AND SO.ORDER_CODE = ACO.ORDER_CODE
   AND SO.ORDER_EXEC_MANAGER = UI1.EMP_CODE

   GROUP BY
          SO.ORDER_CODE,
          ABO.BOOK_CODE,
          ABOI.MERGE_CUST_FLAG,
          SO.ORDER_DEAL_TYPE,
          SL1.ITEM_NAME_CN,
          CP.PORT_NAME,
          VOC.XXXL,
          CVV.VENDOR_NAME_CN,
          ABO.FORWARD_AGENT,
          ABO.FORWARD_AGENT_CONTACT,
          ACO.CUST_DATE,
          ASO.SAIL_DATE,
          UI1.NAME

UNION ALL

SELECT DISTINCT AFN.ROW_ID,
                SO.ORDER_CODE,
                ABO.BOOK_CODE,
                ABOI.MERGE_CUST_FLAG,
                ZH_CONCAT(DISTINCT CPT.PROD_TYPE) AS PROD_TYPE,
                SO.ORDER_DEAL_TYPE,
                SL1.ITEM_NAME_CN AS PORT_START_NAME,
                CP.PORT_NAME AS PORT_END_NAME,
                TRIM(VOC.XXXL) AS XXXL,
                '' AS CHAYI,
                AFN.LUMP_SUM,
                CVV.VENDOR_NAME_CN,
                ABO.FORWARD_AGENT,
                ABO.FORWARD_AGENT_CONTACT,
                AFN.FOREIGN_SIGN,
                ACO.CUST_DATE,
                ASO.SAIL_DATE,
                UI1.NAME AS ORDER_MANGER_NAME,
                AFN.LOGO,
                AFN.UPLOAD_FILE,
                AFI.INDUSTRY_PAY,
                AFI.FACTORY_PAY


  FROM SO_SALES_ORDER           SO,
       SO_SALES_ORDER_ITEM      SOI,
       ACT_FOB_DEBIT_NOTE       AFN,
       ACT_FOB_DEBIT_NOTE_ITEM1 AFI,
       ACT_FOB_DEBIT_NOTE_ORDER AFO,
       ACT_BOOK_ORDER_ITEM      ABOI,
       ACT_BOOK_ORDER           ABO,
       CD_PROD_TYPE             CPT,
       SYS_LOV                  SL1,
       CD_PORT                  CP,
       VI_ORDER_CNT_CONCAT      VOC,
       CD_VENDOR                CVV,
       ACT_CUST_ORDER           ACO,
       ACT_SHIP_ORDER           ASO,
       USER_INFO                UI1
 WHERE SO.ORDER_CODE = AFO.ORDER_CODE
   AND AFO.DEBIT_ID = AFN.ROW_ID
   AND AFI.DEBIT_ID = AFN.ROW_ID
   AND ABOI.ORDER_CODE = SO.ORDER_CODE
   AND ABOI.BOOK_CODE = ABO.BOOK_CODE
   AND SOI.ORDER_CODE = SO.ORDER_CODE
   AND SOI.PROD_T_CODE = CPT.PROD_TYPE_CODE
   AND SL1.ITEM_TYPE = '17'
   AND SO.PORT_START_CODE = SL1.ITEM_CODE
   AND SO.PORT_END_CODE = CP.PORT_CODE
   AND SO.ORDER_CODE = VOC.ORDER_CODE
   AND ABO.BOOK_AGENT = CVV.VENDOR_CODE
   AND SO.ORDER_CODE = ASO.ORDER_NUM(+)
   AND SO.ORDER_CODE = ACO.ORDER_CODE
   AND SO.ORDER_EXEC_MANAGER = UI1.EMP_CODE

 GROUP BY AFN.ROW_ID,
          SO.ORDER_CODE,
          ABO.BOOK_CODE,
          ABOI.MERGE_CUST_FLAG,
          SO.ORDER_DEAL_TYPE,
          SL1.ITEM_NAME_CN,
          CP.PORT_NAME,
          VOC.XXXL,
          AFN.LUMP_SUM,
          CVV.VENDOR_NAME_CN,
          ABO.FORWARD_AGENT,
          ABO.FORWARD_AGENT_CONTACT,
          AFN.FOREIGN_SIGN,
          ACO.CUST_DATE,
          ASO.SAIL_DATE,
          UI1.NAME,
          AFN.LOGO,
          AFN.UPLOAD_FILE,
          AFI.INDUSTRY_PAY,
          AFI.FACTORY_PAY) P

           left join(
      select debit_id,max(confirm_date) confirm_date
                  from act_fob_debit_confirm_log
                 group by debit_id) c1
      on c1.debit_id = P.row_id

          WHERE P.LOGO >= 1
          AND P.SAIL_DATE > to_date('2020-03-01','yyyy-MM-dd')
          
