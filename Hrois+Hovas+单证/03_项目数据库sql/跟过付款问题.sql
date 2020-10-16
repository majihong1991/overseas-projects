-- 业务的一种解决办法是，将逾期表的中的，客户对应逾期记录的删除标识置为0
-- 根据客户编码(cust_code)作为查询条件查询 si_ar_overdue业务表，手动修改字段ACTIVE_FLAG为0（无效），
-- 业务办理完业务会通知运维人员修改回ACTIVE_FLAG为1（有效）

select * from si_ar_overdue where cust_code = '6000007251'