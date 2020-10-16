-------------------------------------下货纸重复问题-----------------------------------------
select * from ACT_SHIP_PAPER a where a.row_id in ('GSPI202009141244','2020091600932239')for update

select * from ACT_SHIP_PAPER_ITEM b where b.order_code in  
('0004271532') for update
--------------------------------------------------------------------------------------------
SELECT PI.*,
       OI.HAIER_MODEL    as HAIER_MODEL,
       OI.CUSTOMER_MODEL as CUSTOMER_MODEL,
       OI.FACTORY_CODE   as FACTORY_CODE,
       OI.MATERIAL_CODE  as MATERIAL_CODE
  FROM ACT_SHIP_PAPER_ITEM PI
  LEFT JOIN SO_SALES_ORDER_ITEM OI
    ON (PI.ORDER_CODE = OI.ORDER_CODE and
       PI.ORDER_ITEM_LINE_CODE = OI.ORDER_ITEM_LINECODE)
 WHERE PI.SHIP_PAPER_ROW_ID =
       (SELECT SP.ROW_ID FROM ACT_SHIP_PAPER SP WHERE SP.BOOK_CODE = '2020090301073017')

SELECT * FROM ACT_SHIP_PAPER SP WHERE SP.BOOK_CODE = '2020090301073017'


,0004314357,GSPI202009100986

