 --  查询某表的所有字段 + 字段注释 + 字段类型
 SELECT t.TABLE_NAME  tableName,
       t.COLUMN_NAME columnName,
      -- t.DATA_TYPE   dataType,
       a.COMMENTS
  FROM USER_TAB_COLUMNS t
  inner JOIN USER_COL_COMMENTS a
    ON t.table_name = a.table_NAME
   AND t.COLUMN_NAME = a.COLUMN_NAME
   and t.table_name = 'EXP_BID'
   
   -- SEE_FEE EXP_BID  so_sales_order
   
   
   
   
   select sso.VENDOR_CODE from SEE_FEE sf,so_sales_order sso where sf.order_code = sso.order_code and sf.BILL_NUM in ('COAU7224416850');
   
   
-- 中标信息
select * from EXP_BID 

a


 SELECT BID.BID_CODE, BID.ROW_ID 
        FROM EXP_BID BID 
       WHERE BID.BID_TYPE = '3'
         AND BID.ACTIVE_FLAG = '1'
         AND BID.PORT_START_CODE = a.PORT_START_CODE
         AND BID.PORT_END_CODE = a.PORT_END_CODE
         AND BID.BID_PAY_TYPE = a.ORDER_DEAL_TYPE
         AND BID.BID_START_DATE <= b.ACTUAL_SHIP_DATE
         AND BID.BID_END_DATE >= b.ACTUAL_SHIP_DATE
         AND BID.VENDER_CODE = a.VENDOR_CODE
         
         so_sales_order
         select * from so_sales_order where rownum < 2
         
         
         select * from see_fee where rownum < 2
         
         
         
         
with a as (
    select sso.VENDOR_CODE as VENDOR_CODE,
           sso.PORT_START_CODE as PORT_START_CODE,
           sso.PORT_END_CODE as PORT_END_CODE,
           sso.ORDER_DEAL_TYPE as ORDER_DEAL_TYPE
from SEE_FEE sf,
     so_sales_order sso
where sf.order_code = sso.order_code
  and sf.BILL_NUM = 'COAU7224416850'),
     b as (
         SELECT SHIP.ACTUAL_SHIP_DATE as ACTUAL_SHIP_DATE,
                sf.ORDER_CODE as ORDER_CODE
        FROM ACT_SHIP_ORDER SHIP,SEE_FEE sf
       WHERE SHIP.ORDER_NUM = sf.ORDER_CODE and sf.BILL_NUM = 'COAU7224416850'
     )

SELECT BID.BID_CODE, BID.ROW_ID
        FROM EXP_BID BID
       WHERE BID.BID_TYPE = '3'
         AND BID.ACTIVE_FLAG = '1'
         AND BID.PORT_START_CODE = to_char(a.PORT_START_CODE)
         AND BID.PORT_END_CODE = to_char(a.PORT_END_CODE)
         AND BID.BID_PAY_TYPE = to_char(a.ORDER_DEAL_TYPE)
         AND BID.BID_START_DATE <= to_date(b.ACTUAL_SHIP_DATE,'yyyy-MM-dd')
         AND BID.BID_END_DATE >= to_date(b.ACTUAL_SHIP_DATE,'yyyy-MM-dd')
         AND BID.VENDER_CODE = to_char(a.VENDOR_CODE);
         
         
         SELECT BID.BID_CODE, BID.ROW_ID
        FROM EXP_BID BID
       WHERE BID.BID_TYPE = LS_PARENT_CODE
         AND BID.ACTIVE_FLAG = '1'
         AND BID.PORT_START_CODE = LS_PORT_START_CODE
         AND BID.PORT_END_CODE = LS_PORT_END_CODE
         AND BID.BID_PAY_TYPE = LS_ORDER_DEAL_TYPE
         AND BID.BID_START_DATE <= LS_ACTUAL_SHIP_DATE
         AND BID.BID_END_DATE >= LS_ACTUAL_SHIP_DATE
         AND BID.VENDER_CODE = LS_VENDOR_CODE;
         
         
         
         
         
       select BID.BID_START_DATE,
BID.BID_TYPE,
BID.ACTIVE_FLAG,
BID.PORT_START_CODE,
BID.PORT_END_CODE,
BID.BID_PAY_TYPE,
BID.BID_START_DATE,
BID.BID_END_DATE,
BID.VENDER_CODE from EXP_BID BID where rownum < 2

SELECT BID.BID_CODE, BID.ROW_ID 
        FROM EXP_BID BID 
       WHERE BID.BID_TYPE = '1'
         AND BID.ACTIVE_FLAG = '1'
         AND BID.PORT_START_CODE = '001'
         AND BID.PORT_END_CODE = '310'
         AND BID.BID_PAY_TYPE = 'CIF'
         AND to_date(BID.BID_START_DATE,'yyyy-MM-dd') <= to_date('2020-07-01','yyyy-MM-dd')
         -AND to_date(BID.BID_END_DATE,'yyyy-MM-dd') >= to_date('2020-07-01','yyyy-MM-dd')
         AND BID.VENDER_CODE = 'V600000218'
         
         
         SELECT BID.BID_CODE, BID.ROW_ID,BID.BID_START_DATE,BID.BID_END_DATE
        FROM EXP_BID BID 
       WHERE BID.BID_TYPE = '1'
         AND BID.ACTIVE_FLAG = '1'
         AND BID.PORT_START_CODE = '001'
         AND BID.PORT_END_CODE = '310'
         AND BID.BID_PAY_TYPE = 'CIF'
         --AND to_date(BID.BID_START_DATE,'yyyy-MM-dd') <= to_date('2020-07-01','yyyy-MM-dd')
         AND to_date(BID.BID_END_DATE,'yyyy-MM-dd hh:ss:mm') >= to_date('2020-07-01','yyyy-MM-dd hh:ss:mm')
         AND BID.VENDER_CODE = 'V600000218'
         
         
         
