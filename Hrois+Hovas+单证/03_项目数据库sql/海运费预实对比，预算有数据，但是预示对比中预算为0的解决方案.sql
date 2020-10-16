--查询表数据，删除后将订单号新增入AA_LIN_TEMP2表中的char1字段上
select* from AA_LIN_TEMP2 for update;

--右键编辑存储过程，海运费就打开海运费过程，铁路费就打开铁路费过程，然后点击测试
PRC_LIN_TEMP1;

--执行完存储过程后，查看SEE_FEE表中的amount是否为0
select  * from SEE_FEE a where a.order_code = '0004274857'

--查看amount是否为0，如果为0则代表未生成预算，去生成
SELECT P.XLH,
           (SELECT MAX(O.FEE_ROW_ID)
              FROM SEE_FEE_ITEM O
             WHERE O.ORDER_CODE = M.ORDER_NUM),
           M.ORDER_NUM,
           (SELECT NVL(SUM(N.ACTUAL_AMOUNT), 0)
              FROM SEE_FEE_ITEM N
             WHERE N.ORDER_CODE = M.ORDER_NUM) as amount,
           P.CURRENCY,
           '1',
           NULL,
           P.EMP_CODE,
           SYSDATE,
           NULL,
           NULL
      FROM SEE_FEE_BILL P, ACT_SHIP_ORDER M,SO_SALES_ORDER SO
     WHERE P.BILL_NUM = M.BILL_NUM
       AND so.order_code = '0004274857'
       AND SO.ORDER_CODE = M.ORDER_NUM

--上条sql语句能查询到amount后，执行update
update SEE_FEE c
   set c.amount =
       (SELECT B.AMOUNT
          FROM IF_BCC_FEE B, AA_LIN_TEMP2 a
         WHERE B.ORDER_NUM = a.char1
           AND B.SUBJECT_NAME = '59'
           and c.order_code = a.char1
           AND B.SUB_SUBJECT IS NULL)
 where EXISTS (SELECT 1
          FROM IF_BCC_FEE B, AA_LIN_TEMP2 a
         WHERE B.ORDER_NUM = a.char1
           AND B.SUBJECT_NAME = '59'
           and c.order_code = a.char1
           AND B.SUB_SUBJECT IS NULL);

--修改比较值
update SEE_FEE c
   set c.bijiao =
       (c.actual_amount - c.amount)
 where c.order_code in (select char1 from AA_LIN_TEMP2);

--修改差异值
update SEE_FEE c
   set c.chayi =
       (c.actual_amount - c.amount)
 where c.order_code in (select char1 from AA_LIN_TEMP2);
