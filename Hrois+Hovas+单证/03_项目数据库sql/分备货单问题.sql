--先登录系统，断点PrepareOrderAction.getActprepareName

select t.act_prepare_code, t.*
  from act_prepare_order t
 where t.act_prepare_code like 'B0120BH8%'
 order by t.act_prepare_code desc for update;



--已分备货单，需要删除
SELECT *
  from act_prepare_order t
 where t.ORDER_NUM in ('0004271520') for update;

SELECT *
  from ACT_PREPARE_ORDER_ITEM t
 where t.ORDER_ITEM_ID in
       (SELECT t.ORDER_ITEM_ID
          from so_sales_order_item t
         where t.order_code in ('0004271521'))
   for update;

--已分备货单 但是无法查看
SELECT ttt.order_code, t.*
  from ACT_PREPARE_ORDER_ITEM t, so_sales_order_item ttt
 where ttt.order_item_id = t.order_item_id
   and t.act_prepare_order_code not in
       (SELECT tt.act_prepare_code from act_prepare_order tt)
   and t.created >= to_date('2020-08-24', 'yyyy-mm-dd');
