-- 海运费删除
select * from SEE_FEE_BILL where BILL_NUM in(
'NOSNB20YK54114'
)   for update ;
select * from SEE_FEE_ITEM_BILL where BILL_NUM  in(
'NOSNB20YK54114'
)   for update ;
select * from SEE_FEE where BILL_NUM  in(
'NOSNB20YK54114'
)   for update ;
--海运费预算
select * from if_bcc_fee cc where cc.order_num
in(
'0004235086',
'0004277116','0004230131')
and cc.subject_name = '59' and cc.sub_subject is null

select * from si_exp_budget_bcc 0004027824
