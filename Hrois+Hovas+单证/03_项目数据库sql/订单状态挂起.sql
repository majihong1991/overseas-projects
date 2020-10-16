--审核标记,NULL=代表订单的补录状态，
--0=代表订单保存完成(尚未审核)，
--1=订单审核完成，
--2=订单已被取消， 
--3=调度单锁定状态,
--4=调度单锁定可更新
--5=修改申请通过可以修改订单 

--查看订单状态是否为锁定，将状态修改为4
select a.order_code, a.order_audit_flag
  from so_sales_order a
 where a.order_code in (
'0004287382'
)for update;

--查看工作流
SELECT T.STATUS,P.SUSPENSION_STATE_,t.*
  FROM WF_PROCINSTANCE T, ACT_RU_TASK P
 WHERE T.BUSINFORM_ID in ('0004287382')
   AND T.PROCESSINSTANCE_ID = P.PROC_INST_ID_;

--查看状态是否等于1，如果不等于1则修改为1
SELECT * FROM WF_PROCINSTANCE T WHERE T.BUSINFORM_ID in(
'0004328227'
) for update;
--查看SUSPENSION_STATE_是否不等于1，如果等于1则修改为2
select * from ACT_RU_TASK p where p.PROC_INST_ID_ in (
'113337543'
) --for update;

--select * from ACT_RU_IDENTITYLINK i where I.TASK_ID_ = '90358892'--for update

--进入系统，财务锁定订单模块，查看数据，选择解锁，然后订单应该就解挂成功了
---------------------------------------------------------------------------------
update ACT_RU_TASK p
   set p.assignee_ = '97028546'
 where p.PROC_INST_ID_ in
       (SELECT T.PROCESSINSTANCE_ID
          FROM WF_PROCINSTANCE T
         WHERE T.BUSINFORM_ID in ('0004312619', '0004312620'));
---------------------------------------------------------------------------------
