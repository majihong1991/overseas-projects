delete from AA_LIN_TEMP;--清空数据
-------------------------------将查询到的数据插入AA_LIN_TEMP表中-------------------------------
select a.bill_num as "提单号",
       'FOB' as "成交方式",
       a.import_name as "代理",
       a.amount as "总费用",
       a.b5 as "舱单录入费（按提单）",
       a.b6 as "订舱代理操作费（票）",
       a.b9 as "订舱代理操作费（箱）",
       a.b11 as "舱单信息费",
       a.b12 as "舱单录入费（按报关）",
       a.b18 as "账单港杂费"
  from ACT_FOB_PORT_IMPORT a
 where a.import_date > to_date('2020-06-01', 'yyyy-mm-dd')
   and a.bill_num not in
       (select distinct a.bill_num
          from ACT_FOB_PORT_import a, ACT_SHIP_ORDER b, SI_EXP_BUDGET_BCC c
         where a.bill_num = b.bill_num
           and b.order_num = c.order_num
           and import_date > to_date('2020-06-01', 'yyyy-mm-dd')
           and c.item_id = '18');

-------------------------------执行存储过程生成LOG_fob_PORT_FEE表数据---------------------------
--PRC_LIN_TEMP1 的PK_PORT_FEE.PRC_FOB_BUDGET_BILL(LS_BILL_NUM, LS_RETURN);

-------------------------------查询未生成预算数据的日志-------------------------------------------------
select distinct d.bill_num, d.messages
  from LOG_fob_PORT_FEE d, AA_LIN_TEMP e
 where d.bill_num = e.char1
   and to_char(d.log_date, 'mm-dd') = to_char(sysdate, 'mm-dd')
   and d.status = 'E';
-------------------------------查询实际导入数据-------------------------------------------------
select *
  from (select a.bill_num as "提单号",
               'FOB' as "成交方式",
               a.import_name as "代理",
               a.amount as "总费用",
               a.b5 as "舱单录入费（按提单）",
               a.b6 as "订舱代理操作费（票）",
               a.b9 as "订舱代理操作费（箱）",
               a.b11 as "舱单信息费",
               a.b12 as "舱单录入费（按报关）",
               a.b18 as "账单港杂费"
          from ACT_FOB_PORT_IMPORT a
         where a.import_date > to_date('2020-06-01', 'yyyy-mm-dd')
           and a.bill_num not in
               (select distinct a.bill_num
                  from ACT_FOB_PORT_import a,
                       ACT_SHIP_ORDER      b,
                       SI_EXP_BUDGET_BCC   c
                 where a.bill_num = b.bill_num
                   and b.order_num = c.order_num
                   and import_date > to_date('2020-06-01', 'yyyy-mm-dd')
                   and c.item_id = '18')) cc
 where cc.提单号 not in (select distinct d.bill_num
                        from LOG_fob_PORT_FEE d, AA_LIN_TEMP e
                       where d.bill_num = e.char1
                       and to_char(d.log_date, 'mm-dd') = to_char(sysdate, 'mm-dd')
                         and d.status = 'E');
-------------------------------查询预算数据费用-------------------------------------------------
select a.bill_num as "提单号",'FOB',c.import_name,
       sum(a.b5 + a.b6 + a.b9 + a.b11 + a.b12 + a.b18) as "总费用",
       a.b5 as "舱单录入费（按提单）",
       a.b6 as "订舱代理操作费（票）",
       a.b9 as "订舱代理操作费（箱）",
       a.b11 as "舱单信息费",
       a.b12 as "舱单录入费（按报关）",
       a.b18 as "账单港杂费"
  from ACT_FOB_PORT_BUDGET a, AA_LIN_TEMP b,ACT_FOB_PORT_import c
 where a.bill_num = b.char1
 and a.bill_num = c.bill_num
 group by a.bill_num, a.b5, a.b6, a.b9, a.b11, a.b12, a.b18,c.import_name;
