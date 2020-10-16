select order_item_id,prod_quantity from so_sales_order_item a where a.order_code = '0004308481'


(SELECT CI.ORDER_ITEM_ID as order_item_id,
               SUM(CI.BUDGET_QUANTITY) BUDGET_QUANTITY
          		FROM ACT_CNT_ITEM CI
              where ci.ORDER_ITEM_ID in(
              '2020082603599534',
              '2020082603599535',
              '2020082603599536'
              )
         		GROUP BY CI.ORDER_ITEM_ID) 
            
--Èç¹ûprod_quantity-BUDGET_QUANTITY
