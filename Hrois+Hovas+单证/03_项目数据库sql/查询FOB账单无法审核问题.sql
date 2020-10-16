SELECT *
  FROM (SELECT DISTINCT AFN.ROW_ID,
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
                        AFN.UPLOAD_FILE
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
           AND SO.ORDER_TYPE IN ('005', '046', '047', '8')/*这个地方传参可以根据查询不到的信息修改*/
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
 INNER join (SELECT DEBIT_ID,
                    AFTER_CONFIRM,
                    CONFIRM_NAME,
                    MAX(CONFIRM_DATE) CONFIRM_DATE
               FROM ACT_FOB_DEBIT_CONFIRM_LOG
              GROUP BY DEBIT_ID, AFTER_CONFIRM, CONFIRM_NAME) C1
    ON C1.DEBIT_ID = P.ROW_ID
   AND C1.AFTER_CONFIRM = '1'
   AND P.LOGO = '1'
  left join (select debit_id, max(confirm_date) confirm_date
               from act_fob_debit_confirm_log
              group by debit_id) c1
    on c1.debit_id = P.row_id
 inner join (select prod_type_code as prod_code, prod_type
               from cd_prod_type
              group by prod_type_code, prod_type) c2
    on c2.prod_type = p.prod_type
   and c2.prod_code IN ('02', 'ZZ') /*这个地方传参可以根据查询不到的信息修改*/
 inner join (select debit_id,
                    prod_code,
                    prod_amount,
                    industry_pay,
                    factory_pay,
                    active_flag
               from act_fob_debit_note_item1
              group by debit_id,
                       prod_code,
                       prod_amount,
                       industry_pay,
                       factory_pay,
                       active_flag) c3
    on c3.prod_code = c2.prod_code
   and c3.debit_id = c1.debit_id
   and c3.active_flag <> '2'
   and c3.active_flag <> '-1'
 WHERE P.ORDER_CODE = 'MM2020070601797'/*订单号*/
