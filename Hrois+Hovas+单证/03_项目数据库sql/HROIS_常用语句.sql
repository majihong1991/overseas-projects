--查询传BCC数据
SELECT * from  SI_EXP_BUDGET_BCC t
WHERE --rownum<=100
t.ITEM_ID='18'
and t.ORDER_NUM in('0004224087');
--and t.LAST_UPDATE>to_date('2020-08-02','yyyy-mm-dd')
--t.ORDER_NUM='0004185134';

--传BCC中间表 
SELECT * from  IF_BCC_FEE t
WHERE --rownum<=100
--and
t.ORDER_NUM in ('0004224087')
and t.SUBJECT_NAME='18';


--获取OES评审结果 如果获取成功后会更新actual_quantity字段
-- roll_rate 是计划周次（建表的人打错了应该是date）
SELECT * from SI_OES_ROLLPLAN t
where t.MATERIAL_CODE='BC10R2E00'
and t.START_DATE>to_date('2020-08-02','yyyy-mm-dd')


--滚动计划导入的表
SELECT * from RP_INPUT t
WHERE t.MATERIAL_CODE='B30JU3E00'

--查询是否传入传HGVS接口表，这个是EAI封装的主动来取，然后传给HGVS
--EAI的接口人是 裴宝盼
--EAI取数逻辑是SI_HGVS_ORDER_PLAN WHERE SI_HGVS_ORDER_PLAN.FLAG='0' and SI_HGVS_ORDER_PLAN.PLANT is not null
--FLAG看来待传输的是0，已传的会更新为1，报错的更新为2
SELECT * from  SI_HGVS_ORDER_PLAN t
WHERE t.ROLL_DATE>to_date('2020-07-27','yyyy-mm-dd');

--订单信息
--so_sales_order_item
--so_sales_order_condition
SELECT * from so_sales_order_item t
--so_sales_order t
where t.MATERIAL_CODE='B70TN1E8N';
--t.ORDER_CODE='0004278478'
--and t.ORDER_CREATE_DATE>to_date('2020-07-01','yyyy-mm-dd')
--and   t.ORDER_TYPE='047';

--备货单
SELECT * from act_prepare_order t
where t.ORDER_NUM in('0004271621');

SELECT * from ACT_PREPARE_ORDER_ITEM t
where t.ORDER_ITEM_ID in (
SELECT t.ORDER_ITEM_ID from so_sales_order_item t
--so_sales_order t
where --t.MATERIAL_CODE='B70TN1E8N';
t.ORDER_CODE in('0004271621')
);

--用户97036273
SELECT* from USER_INFO t
where t.NAME='郑慧';


--CIF预算
    --PK_PORT_FEE.PRC_CIF_BUDGET_BILL(LS_BILL_NUM, LS_RETURN);
    --CIF对比
    --PK_PORT_FEE.PRC_CIF_BALANCE_ORDER(LS_BILL_NUM, LS_RETURN);
    --FOB预算
    --PK_PORT_FEE.PRC_FOB_BUDGET_BILL(LS_BILL_NUM, LS_RETURN);
    --FOB对比
    --PK_PORT_FEE.PRC_FOB_BALANCE_BILL(LS_BILL_NUM, LS_RETURN);
    --传BCC
    --PK_PORT_FEE.PRC_BALANCE_TO_BCC(LS_BILL_NUM, LS_RETURN);
    --工厂
     --PK_PORT_FEE.PRC_CIF_IMP_SPLIT_FAC(LS_BILL_NUM, LS_RETURN);
     --海运费  订单号
-- PK_BCC_FEE.PRC_FREIGHT_FEE(LS_BILL_NUM, LS_RETURN);
     --铁路费  订单号
      -- PK_BCC_FEE.PRC_RAIL_FEE(LS_BILL_NUM, LS_RETURN);
     --海运费、铁路费预实对比  提单号
--      PRC_SEE_TO_ORDER(LS_BILL_NUM);
     --报关费预算
--       PK_BCC_FEE.PRC_CUST_FEE2(LS_BILL_NUM, LS_RETURN);
      --报关费预实对比
      --PRC_CUST_TO_ORDER(LS_BILL_NUM);
      --佣金3
      --PK_BCC_FEE.PRC_COMMISSION_FEE(LS_BILL_NUM, LS_RETURN);
--报关
--ITEM_ID-17:报关费，59-海运费(或者铁路运费),18-港杂费

SELECT * FROM act_cust_order t
WHERE --rownum<=100
t.CUST_NUM='516620200660153640';
			
--报关费
SELECT * FROM CUST_FEE t
WHERE --rownum<=100
--t.EMP_CODE='V600000818'
--and t.CREATE_TIME>to_date('2020-08-07','yyyy-mm-dd')
t.ORDER_CODE='0004130955';

SELECT * FROM CUST_FEE_ITEM t
WHERE t.ORDER_CODE='0004196898';

select * from CUST_FEE_CUST t 
where t.CUST_NUM='516620200660149528';

select * from CUST_FEE_ITEM_CUST t
WHERE t



--港杂费导入 提单维度 FOB
select * from ACT_FOB_PORT_import t
WHERE t.IMPORT_DATE>to_date('2020-07-01','yyyy-mm-dd')


--港杂费导入 订单维度
select distinct b.order_num, a.bill_num,a.import_name,a.import_date
  from ACT_FOB_PORT_import a, ACT_SHIP_ORDER b
  where  a.bill_num = b.bill_num
  and import_date>to_date('2020-05-01','yyyy-mm-dd');
	
--查下港杂费导入后但是没有传BCC的 信息
select distinct b.order_num, a.bill_num,a.import_name,a.import_date
  from ACT_FOB_PORT_import a, ACT_SHIP_ORDER b
  where  a.bill_num = b.bill_num
  and import_date>to_date('2020-05-01','yyyy-mm-dd')
  and  b.order_num not in(
  
  select distinct b.order_num
  from ACT_FOB_PORT_import a, ACT_SHIP_ORDER b,SI_EXP_BUDGET_BCC c
  where  a.bill_num = b.bill_num
  and b.order_num = c.order_num
  and import_date>to_date('2020-05-01','yyyy-mm-dd'))
	
	--订舱
	SELECT * FROM ACT_BOOK_ORDER t
	WHERE rownum<=100;
	
	SELECT * FROM ACT_BOOK_ORDER_ITEM t
	WHERE rownum<=100
	t.ORDER_CODE='0004272648';
	
	SELECT * FROM ACT_SHIP_ORDER t
	where t；
	
	--提单表
	SELECT *
	FROM	ACT_BILL_ORDER t
	where t.BILL_NUM='QDSYD2080027';
	
	
	--中标信息
	select *from EXP_BID b where b.BID_CODE ='20200616002';
	select *from EXP_BID_DETAIL b where b.BID_CODE ='20200616002';
	
	--港杂费导入 cif
	SELECT * from act_cif_port_import t
	WHERE --t.IMPORT_DATE>to_date('2020-07-28','yyyy-mm-dd')
	t.BILL_NUM='COSU6260776500';
	SELECT * from 	ACT_CIF_PORT_BUDGET t
	WHERE t.BILL_NUM='COSU6260776500';
	SELECT * from 	ACT_CIF_PORT_MERGE t
	WHERE t.BILL_NUM='COSU6260776500'
	
	SELECT * from ACT_CIF_PORT_ACTUAL t
	WHERE t.BILL_NUM='COAU7222014210';
	
	--港杂费 FOB
	SELECT * from ACT_FOB_PORT_IMPORT t
	WHERE t.IMPORT_DATE>to_date('2020-07-28','yyyy-mm-dd')
	
	--报关费 CUST_FEE  CUST_FEE_ITEM
	-- 删除报关费 根据cust_num 
select * from CUST_FEE_CUST t
where  t.CUST_NUM in('516620200660124109','516620200660125145');
--in ('090420200040026493','090420200040027445','090420200040027834','090420200040028384','090420200040029131') for update;

select * from CUST_FEE_ITEM_CUST t
where cust_num--='51662020066017318'
in('516620200660124109','516620200660125145');
for update;

-- 海运费删除
select * from SEE_FEE_BILL where BILL_NUM = 'QDGA311099' or BILL_NUM = 'QDGA311100' for update ;
select * from SEE_FEE_ITEM_BILL where BILL_NUM = 'QDGA311099' or BILL_NUM = 'QDGA311100' for update;
select * from SEE_FEE where BILL_NUM = 'QDGA311099' or BILL_NUM = 'QDGA311100' for update;
		
--付款保障明细，从付款保障的行项目中，扩展出来N次付款的表。并且本身也允许多行，用来支持同一次付款中，多种付款方式组合
select 
sum(t.AMOUNT)
from ACT_CONF_PAY_ORDER_ITEM t
where t.PAYMENT_METHOD='O'
--rownum<=100
--t.ORDER_NUM='0004035360';
AND t.PAY_CODE='60K0'
and t.ACTIVE_FLAG='1'

select * from ACT_CONF_PAY_ORDER t
WHERE t.ORDER_CODE


select *
from SO_ACT t
where
rownum<=100;
--用户
SELECT* from USER_INFO t
WHERE t.EMP_CODE='admin'
--rownum<=100
t.NAME='01445659';

--物流平台账户权限 LMS这个权限需要单独添加，否则就算有了这个菜单的权限也查不出数据来
SELECT* from ACT_LMS_ACCOUNT


-- 海运费删除
select * from SEE_FEE_BILL where BILL_NUM = '799010311922' or BILL_NUM = '799010300360' for update ;
select * from SEE_FEE_ITEM_BILL where BILL_NUM = '799010311922' or BILL_NUM = '799010300360' for update;
select * from SEE_FEE 
where BILL_NUM = '799010300360' or BILL_NUM = '799010311922' for update;


--订舱 下货纸
select * from ACT_BOOK_ORDER t
where t.BOOK_CODE='2020081801069341';

select * from ACT_BOOK_ORDER_ITEM t
where t.ORDER_CODE='0004281645';

select * from ACT_SHIP_ORDER t
where t.ORDER_NUM='0004281645'

select * from ACT_SHIP_PAPER t
WHERE t.or

--海运费
SEE_FEE

--中标
select * from EXP_BID t
where T.CREATED>to_date('2020-08-25','yyyy-mm-dd')
--rownum<=100;

select * from EXP_BID_DETAIL t
where rownum<=100;

--查询自动审核的调度单
select ac.BUSINESS_KEY_, a.NAME_,ASSIGNEE_
from ACT_HI_TASKINST a
       left join act_hi_procinst ac on ac.PROC_INST_ID_ = a.PROC_INST_ID_
where a.TASK_DEF_KEY_ = 'businessmanagerConfirm'
  and ac.BUSINESS_KEY_ in (
  select distinct substr(EDIT_ID, 1, 16)
  from OE_ORDER_EDIT_ITEM
  where EDIT_ID in
        (
          select id
          from OE_ORDER_EDIT
          where id like '2020090%'
            and APPLY_DATE >= to_date('2020-08-27 23:59:00', 'yyyy-MM-dd HH24:mi:ss')
        )
    and ITEM_NAME in (
                      '2013112000000356','2013112000000358','2013112000000357','2013112000000360','2013112000000356'
    )
)
order by a.ASSIGNEE_;

--
SELECT * FROM SI_OES_ROLLPLAN t
WHERE rownum<=100;


--调度单大项小项类型表
SELECT  *
FROM OE_TYPE_CONF  t
LEFT JOIN  CD_TMOD_CONFIG M on TMODEL = M.CONFIG_ID
LEFT JOIN  GROUP_INFO G on MANAGER = G.CODE
where t.TYPE_NAME in ('更改-经营体长','更改-收汇经理','更改-产品经理','更改-单证经理','更改-订单执行经理');
