-- 订单无法导HGVS，系统提示交货期过期
-- 处理办法，修改字段MANU_END_DATE，将日期改为明天

select MANU_END_DATE from ACT_PREPARE_ORDER where order_num in (
'0004287607'
) for update;
