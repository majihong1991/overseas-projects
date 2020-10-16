-- ORDER_AUDIT_FLAG
select case ORDER_AUDIT_FLAG 
when '0' then ORDER_AUDIT_FLAG||'-代表订单保存完成(尚未审核)' 
when '1' then ORDER_AUDIT_FLAG||'-订单审核完成' 
when '2' then ORDER_AUDIT_FLAG||'-订单已被取消' 
when '3' then ORDER_AUDIT_FLAG||'-调度单锁定状态' 
when '4' then ORDER_AUDIT_FLAG||'-调度单锁定可更新' 
when '5' then ORDER_AUDIT_FLAG||'-修改申请通过可以修改订单' 
ELSE '其他' END as "当前状态" from so_sales_order 
where order_code = '0004221094'
--审核标记,NULL=代表订单的补录状态，0=代表订单保存完成(尚未审核)，1=订单审核完成，2=订单已被取消， 3=调度单锁定状态,5=修改申请通过可以修改订单 4=调度单锁定可更新