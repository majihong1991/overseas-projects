-- 使用select update 方法如下 执行的时候最好对一下EMP_CODE 客户编号是不是修改了 begin

update act_ru_task art set ASSIGNEE_ = 'admin' where exists(SELECT
                  WP.PROCESSINSTANCE_ID PROC_INST_ID
           FROM CUST_FEE FEE
                    JOIN SO_SALES_ORDER SO
                         ON FEE.ORDER_CODE = SO.ORDER_CODE
                    LEFT JOIN SYS_LOV SHI
                              ON SO.PORT_START_CODE = SHI.ITEM_CODE
                                  AND SHI.ITEM_TYPE = '17'
                    JOIN ACT_CUST_ORDER CUST
                         ON SO.ORDER_CODE = CUST.ORDER_CODE
                    LEFT JOIN CD_VENDOR YSGS
                              ON CUST.CUST_COMPANY = YSGS.VENDOR_CODE
                                  AND YSGS.VENDOR_TYPE = '1'
                                  AND YSGS.ACTIVE_FLAG = '1'
                    JOIN IF_BCC_FEE BF
                         ON FEE.ORDER_CODE = BF.ORDER_NUM
                             AND BF.SUBJECT_NAME = '17'
                             AND BF.SUB_SUBJECT IS NULL
                    LEFT JOIN WF_PROCINSTANCE WP
                              ON FEE.ROW_ID = WP.BUSINFORM_ID
                                  AND WP.STATUS = '1'
           where FEE.STATUS = '1'
             and FEE.EMP_CODE = 'V600002084' and art.PROC_INST_ID_ = WP.PROCESSINSTANCE_ID );
             
 -- 使用select update 方法如下 end

-- 对数select update 对数语句如下
with a as (SELECT FEE.ROW_ID,
       WP.PROCESSINSTANCE_ID PROC_INST_ID, --流程id
       FEE.ORDER_CODE,
       FEE.ACTUAL_AMOUNT,
       FEE.ACTUAL_AMOUNT - BF.AMOUNT CHAYI,
       FEE.CURRENCY,
       FEE.STATUS,
       FEE.UPLOAD_ID,
       SO.PORT_START_CODE,
       SHI.ITEM_NAME_CN PORT_START_NAME,
       SO.VENDOR_CODE,
       YSGS.VENDOR_NAME_CN VENDOR_NAME,
       CUST.CUST_DATE ACTUAL_SHIP_DATE,
       CUST.CUST_NUM,
       BF.AMOUNT, --预算金额
       ROUND(FEE.ACTUAL_AMOUNT - BF.AMOUNT,2) BIJIAO, --实际金额-预算金额
       '1' XXXL,--XXX.XXXL,
       BF.EXP_BID_ROW_ID, --中标信息主键
       FEE.BHBJ,--驳回标记
       FEE.EMP_CODE --导入的人员信息
  FROM CUST_FEE FEE
  JOIN SO_SALES_ORDER SO
    ON FEE.ORDER_CODE = SO.ORDER_CODE
  LEFT JOIN SYS_LOV SHI
    ON SO.PORT_START_CODE = SHI.ITEM_CODE
   AND SHI.ITEM_TYPE = '17'
  JOIN ACT_CUST_ORDER CUST
    ON SO.ORDER_CODE = CUST.ORDER_CODE
  LEFT JOIN CD_VENDOR YSGS
    ON CUST.CUST_COMPANY = YSGS.VENDOR_CODE
   AND YSGS.VENDOR_TYPE = '1'
   AND YSGS.ACTIVE_FLAG = '1'
  JOIN IF_BCC_FEE BF
    ON FEE.ORDER_CODE = BF.ORDER_NUM
   AND BF.SUBJECT_NAME = '17'
   AND BF.SUB_SUBJECT IS NULL
  LEFT JOIN WF_PROCINSTANCE WP
    ON FEE.ROW_ID = WP.BUSINFORM_ID
   AND WP.STATUS = '1'
   where FEE.STATUS='1' and FEE.EMP_CODE='V600002084'
   ORDER BY CUST.CUST_NUM)
-- 对数的语句 begin 
select count(*) from a,act_ru_task art where art.PROC_INST_ID_ = a.PROC_INST_ID;


-- 对数的语句 end



--- 手动改数的方法 begin
with a as (SELECT FEE.ROW_ID,
       WP.PROCESSINSTANCE_ID PROC_INST_ID, --流程id
       FEE.ORDER_CODE,
       FEE.ACTUAL_AMOUNT,
       FEE.ACTUAL_AMOUNT - BF.AMOUNT CHAYI,
       FEE.CURRENCY,
       FEE.STATUS,
       FEE.UPLOAD_ID,
       SO.PORT_START_CODE,
       SHI.ITEM_NAME_CN PORT_START_NAME,
       SO.VENDOR_CODE,
       YSGS.VENDOR_NAME_CN VENDOR_NAME,
       CUST.CUST_DATE ACTUAL_SHIP_DATE,
       CUST.CUST_NUM,
       BF.AMOUNT, --预算金额
       ROUND(FEE.ACTUAL_AMOUNT - BF.AMOUNT,2) BIJIAO, --实际金额-预算金额
       '1' XXXL,--XXX.XXXL,
       BF.EXP_BID_ROW_ID, --中标信息主键
       FEE.BHBJ,--驳回标记
       FEE.EMP_CODE --导入的人员信息
  FROM CUST_FEE FEE
  JOIN SO_SALES_ORDER SO
    ON FEE.ORDER_CODE = SO.ORDER_CODE
  LEFT JOIN SYS_LOV SHI
    ON SO.PORT_START_CODE = SHI.ITEM_CODE
   AND SHI.ITEM_TYPE = '17'
  JOIN ACT_CUST_ORDER CUST
    ON SO.ORDER_CODE = CUST.ORDER_CODE
  LEFT JOIN CD_VENDOR YSGS
    ON CUST.CUST_COMPANY = YSGS.VENDOR_CODE
   AND YSGS.VENDOR_TYPE = '1'
   AND YSGS.ACTIVE_FLAG = '1'
  JOIN IF_BCC_FEE BF
    ON FEE.ORDER_CODE = BF.ORDER_NUM
   AND BF.SUBJECT_NAME = '17'
   AND BF.SUB_SUBJECT IS NULL
  LEFT JOIN WF_PROCINSTANCE WP
    ON FEE.ROW_ID = WP.BUSINFORM_ID
   AND WP.STATUS = '1'
   where FEE.STATUS='1' and FEE.EMP_CODE='V600000818'
   ORDER BY CUST.CUST_NUM)
   
    select b.* from act_ru_task b,a  where b.PROC_INST_ID_  = a.PROC_INST_ID;
      
   select * from act_ru_task where PROC_INST_ID_ in 
   --------
   --- 手动改数的方法 end
 
 
