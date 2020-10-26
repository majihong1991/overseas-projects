--delete from aa_lin_temp
--select * from aa_lin_temp for update

--P_ROLLPLAN_INSERT_GVS

select cc.actual_quantity
  from SI_OES_ROLLPLAN cc
 where cc.roll_rate = to_date('2020-10-19', 'yyyy-mm-dd');

update SI_OES_ROLLPLAN a
   set a.actual_quantity =
       (select b.char2 from aa_lin_temp b where a.rp_oes_audit_id = b.char1)
 where exists
 (select 1 from aa_lin_temp c where c.char1 = a.rp_oes_audit_id);
