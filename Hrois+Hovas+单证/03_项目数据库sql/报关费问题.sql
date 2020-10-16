SELECT T.* FROM VI_CUST_FEE T where t.order_code = '0004228303' 
--预算金额
select * from IF_BCC_FEE a where a.order_num = '0004228303'; --for update
--实际金额
select * from cust_fee b where b.order_code = '0004228303'; --for update
