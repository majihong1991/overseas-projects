--外包装箱用量*最外包装净重(kg) = 总净重
--外包装箱用量*最外包装毛重(kg) = 总毛重

--合箱不统计重量和数量（查看物料专用号一般是一样的后面会缀上-1等信息）


--查询明细数据是否正确
SELECT *
  FROM CD_SPECIAL_CNT_item a
 where a.special_cnt_prod_id in ('2020101700113637', '2020101700113638')
 and a.outer_info_flag = '1';

SELECT *
  FROM CD_SPECIAL_CNT_PROD a
 where a.special_cnt_prod_id in ('2020101700113637', '2020101700113638')
 and a.outer_info_flag = '1';

select *
  from CD_SPECIAL_CNT c
 where c.special_cnt_num like '%泰国散件五星36单相吊落机40HQ48内外机海尔牌201017%';
