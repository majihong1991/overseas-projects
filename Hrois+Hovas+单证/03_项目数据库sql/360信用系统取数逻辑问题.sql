select a.AMOUNT from VI_HROIS_TO_CWJC_TEMP a where a.ORDER_num = '0004190907'


SELECT T.AMOUNT,t.*
          FROM SO_SALES_ORDER_ITEM T
          where t.order_code = '0004190907' for update
          
          
          SELECT A.ORDER_AMOUNT,a.AMOUNT
            FROM ACT_CONF_PAY_ORDER_ITEM A
           WHERE A.ACTIVE_FLAG = '1'
             and a.ORDER_NUM = '0004153369' for update


