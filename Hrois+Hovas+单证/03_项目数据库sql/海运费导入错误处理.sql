-- BILL_NUM 提单号
-- 业务处理逻辑是根据提单号，查询出下面三个表的业务数据，先备份一下在删除后通知业务就可以
-- select * from so_s
select * from SEE_FEE_BILL where BILL_NUM in ('QDGA298362'
'QDGA298363');
x`
select * from SEE_FEE_ITEM_BILL where BILL_NUM in ('QDGA298362'
'QDGA298363');

select * from SEE_FEE where BILL_NUM in ('QDGA298362'
'QDGA298363');