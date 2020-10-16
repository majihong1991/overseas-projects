--PRC_LIN_TEMP1

update if_bcc_fee a
   set (a.amount) =
       (select b.char3 from AA_LIN_TEMP2 b where a.order_num = b.char2)
 where exists (select 1 from AA_LIN_TEMP2 c where c.char2 = a.order_num)
   and a.subject_name = '59'
   and a.sub_subject is null
   
   
   select * from if_bcc_fee a ,AA_LIN_TEMP2 b where a.order_num = b.char2
and a.subject_name = '59'
   and a.sub_subject is null
