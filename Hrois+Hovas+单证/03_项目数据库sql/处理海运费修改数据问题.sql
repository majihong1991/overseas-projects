-- 把需要修改的海运费订单号放到AA_LIN_TEMP2里里连表查询IF_BCC_FEE传bbc临时表中的数据，修改后调用PRC_LIN_TEMP1
  --   的 --传 PRC_FEE_TO_OLDHROIS(LS_BILL_NUM,'59')方法;

select *
  from IF_BCC_FEE t,AA_LIN_TEMP2 a
 where a.char1 = t.order_num
   and subject_name = '59'
   AND SUB_SUBJECT IS NULL
   AND AMOUNT > 0 and t.order_num = '0004170125' 