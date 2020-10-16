delete from AA_LIN_TEMP2;--清空数据
-------------------------------将查询到的数据插入AA_LIN_TEMP表中-------------------------------
select a.bill_num,
       'CIF',
       a.import_name,
       a.amount,
       a.a1,
       a.a2,
       a.a3,
       a.a4,
       a.a5,
       a.a6,
       a.a7,
       a.a8,
       a.a9,
       a.a10,
       a.a11,
       a.a12,
       a.a13,
       a.a14,
       a.a15,
       a.a16,
       a.a17,
       a.a18,
       a.a19,
       a.a20,
       a.a21,
       a.a22,
       a.a23,
       a.a24,
       a.a25,
       a.a26,
       a.a27,
       a.a28,
       a.a29,
       a.a30,
       a.a31,
       a.a32,
       a.a33,
       a.a34,
       a.a35
  from ACT_CIF_PORT_IMPORT a
 where a.import_date > to_date('2020-06-01', 'yyyy-mm-dd')
   and a.bill_num not in
       (select distinct a.bill_num
          from ACT_CIF_PORT_IMPORT a, ACT_SHIP_ORDER b, SI_EXP_BUDGET_BCC c
         where a.bill_num = b.bill_num
           and b.order_num = c.order_num
           and import_date > to_date('2020-06-01', 'yyyy-mm-dd')
           and c.item_id = '18');
-------------------------------执行存储过程生成LOG_CIF_PORT_FEE表数据---------------------------
--PRC_LIN_TEMP1 的PK_PORT_FEE.PRC_CIF_BUDGET_BILL(LS_BILL_NUM, LS_RETURN);
-------------------------------查询未生成预算数据的日志-------------------------------------------------
select distinct d.bill_num, d.messages
  from LOG_CIF_PORT_FEE d, AA_LIN_TEMP2 e
 where d.bill_num = e.char1
   and to_char(d.log_date, 'mm-dd') = to_char(sysdate, 'mm-dd')
   and d.status = 'E';
-------------------------------查询实际导入数据-------------------------------------------------
select *
  from (select a.bill_num,
               'CIF',
               a.import_name,
               a.amount,
               a.a1,
               a.a2,
               a.a3,
               a.a4,
               a.a5,
               a.a6,
               a.a7,
               a.a8,
               a.a9,
               a.a10,
               a.a11,
               a.a12,
               a.a13,
               a.a14,
               a.a15,
               a.a16,
               a.a17,
               a.a18,
               a.a19,
               a.a20,
               a.a21,
               a.a22,
               a.a23,
               a.a24,
               a.a25,
               a.a26,
               a.a27,
               a.a28,
               a.a29,
               a.a30,
               a.a31,
               a.a32,
               a.a33,
               a.a34,
               a.a35
          from ACT_CIF_PORT_IMPORT a
         where a.import_date > to_date('2020-06-01', 'yyyy-mm-dd')
           and a.bill_num not in
               (select distinct a.bill_num
                  from ACT_CIF_PORT_IMPORT a,
                       ACT_SHIP_ORDER      b,
                       SI_EXP_BUDGET_BCC   c
                 where a.bill_num = b.bill_num
                   and b.order_num = c.order_num
                   and import_date > to_date('2020-06-01', 'yyyy-mm-dd')
                   and c.item_id = '18')) cc
 where cc.bill_num not in (select distinct d.bill_num
                             from LOG_CIF_PORT_FEE d, AA_LIN_TEMP2 e
                            where d.bill_num = e.char1
                               and to_char(d.log_date, 'mm-dd') = to_char(sysdate, 'mm-dd')
                              and d.status = 'E');
-------------------------------查询预算数据费用-------------------------------------------------
select a.bill_num,
       'CIF',
       c.import_name,
       sum(A.S01 + A.S02 + A.S03 + A.S04 + A.S05 + A.S06 + A.S07 + A.S08 +
           A.S09 + A.S10 + A.S11 + A.S12 + A.S13 + A.S14 + A.S15 + A.S16 +
           A.S21 + A.S22 + A.S23 + A.S24 + A.S25 + A.S26 + A.S27 + A.S28 +
           A.S29 + A.S30 + A.S31 + A.S32 + A.S37 + A.S38 + A.S39 + A.S40 +
           A.S41 + A.S42 + A.S43 + A.S44 + A.S53 + A.S54 + A.S55 + A.S56 +
           A.S57 + A.S58 + A.S59 + A.S60 + A.S62 + A.S64 + A.S65 + A.S66 +
           A.S67 + A.S68 + A.S69 + A.S70 + A.S71 + A.S72 + A.S73 + A.S74 +
           A.S75 + A.S76 + A.S77 + A.S78 + A.S79 + A.S80 + A.S81 + A.S82 +
           A.S83 + A.S84 + A.S85 + A.S86 + A.S87 + A.S88 + A.S89 + A.S90 +
           A.S91 + A.S92 + A.S93 + A.S94 + A.S95 + A.S96 + A.S97 + A.S98 +
           A.S99 + A.S100 + A.S101 + A.S102 + A.S103 + A.S104),
       A.S01 + A.S02 + A.S03 + A.S04,
       A.S05 + A.S06 + A.S07 + A.S08,
       A.S09 + A.S10 + A.S11 + A.S12,
       A.S13 + A.S14 + A.S15 + A.S16,
       A.S21 + A.S22 + A.S23 + A.S24,
       A.S25 + A.S26 + A.S27 + A.S28,
       A.S29 + A.S30 + A.S31 + A.S32,
       A.S37 + A.S38 + A.S39 + A.S40,
       A.S41 + A.S42 + A.S43 + A.S44,
       A.S53 + A.S54 + A.S55 + A.S56,
       A.S57,
       A.S58,
       A.S59,
       A.S60,
       A.S62,
       A.S64,
       A.S65 + A.S66 + A.S67 + A.S68,
       A.S69,
       A.S70,
       A.S71,
       A.S72,
       A.S73,
       A.S74 + A.S75 + A.S76 + A.S77,
       A.S78,
       A.S79 + A.S80 + A.S81 + A.S82,
       A.S83,
       A.S84,
       A.S85 + A.S86 + A.S87 + A.S88,
       A.S89 + A.S90 + A.S91 + A.S92,
       A.S93 + A.S94 + A.S95 + A.S96,
       A.S97 + A.S98 + A.S99 + A.S100,
       A.S101,
       A.S102,
       A.S103,
       A.S104
  from ACT_CIF_PORT_BUDGET a, AA_LIN_TEMP2 b, ACT_CIF_PORT_IMPORT c
 where a.bill_num = b.char1
   and a.bill_num = c.bill_num
 group by a.bill_num,
          c.import_name,
          A.S01 + A.S02 + A.S03 + A.S04,
          A.S05 + A.S06 + A.S07 + A.S08,
          A.S09 + A.S10 + A.S11 + A.S12,
          A.S13 + A.S14 + A.S15 + A.S16,
          A.S21 + A.S22 + A.S23 + A.S24,
          A.S25 + A.S26 + A.S27 + A.S28,
          A.S29 + A.S30 + A.S31 + A.S32,
          A.S37 + A.S38 + A.S39 + A.S40,
          A.S41 + A.S42 + A.S43 + A.S44,
          A.S53 + A.S54 + A.S55 + A.S56,
          A.S57,
          A.S58,
          A.S59,
          A.S60,
          A.S62,
          A.S64,
          A.S65 + A.S66 + A.S67 + A.S68,
          A.S69,
          A.S70,
          A.S71,
          A.S72,
          A.S73,
          A.S74 + A.S75 + A.S76 + A.S77,
          A.S78,
          A.S79 + A.S80 + A.S81 + A.S82,
          A.S83,
          A.S84,
          A.S85 + A.S86 + A.S87 + A.S88,
          A.S89 + A.S90 + A.S91 + A.S92,
          A.S93 + A.S94 + A.S95 + A.S96,
          A.S97 + A.S98 + A.S99 + A.S100,
          A.S101,
          A.S102,
          A.S103,
          A.S104;
