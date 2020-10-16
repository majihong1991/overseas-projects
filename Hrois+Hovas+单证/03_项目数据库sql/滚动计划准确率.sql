SELECT U.NAME AS PROD_MANAGER_NAME,
       TMP.PROD_MANAGER, --产品经理编码
       SUM(ACTUAL_QUANTITY) AS ROLLPLAN_QUANTITY, --滚动计划数量
       SUM(QUANTITY) AS PREPARE_QUANTITY, --已经销售数量
       SUM(TMP.RATIO_VAL) AS OVERSTEP_QUANTITY, --差异
       CASE
         WHEN SUM(TMP.RATIO_VAL) < SUM(TMP.ACTUAL_QUANTITY) THEN
          ROUND(SUM(TMP.RATIO_VAL) / SUM(TMP.ACTUAL_QUANTITY) * 100, 2)
         WHEN SUM(TMP.RATIO_VAL) = 0 THEN
          0
         WHEN SUM(TMP.RATIO_VAL) >= SUM(TMP.ACTUAL_QUANTITY) THEN
          100
       END AS OVERSTEP_RATE, --离谱率
       CASE
         WHEN SUM(TMP.RATIO_VAL) < SUM(TMP.ACTUAL_QUANTITY) THEN
          ROUND((1 - SUM(TMP.RATIO_VAL) / SUM(TMP.ACTUAL_QUANTITY)) * 100, 2)
         WHEN SUM(TMP.RATIO_VAL) = 0 THEN
          100
         WHEN SUM(TMP.RATIO_VAL) >= SUM(TMP.ACTUAL_QUANTITY) THEN
          0
       END AS ACCURACY_RATE --准确率

  FROM (SELECT SOR.PROD_TYPE_CODE,
               SOR.MARKET,
               SOR.FACTORY_CODE,
               SOR.MATERIAL_CODE,
               SOR.HAIER_MODEL,
               SOR.CUSTOMER_MODEL,
               SOR.ROLL_RATE,
               SOR.START_DATE,
               SOR.END_DATE,
               SOR.MONTH_DATE,
               SOR.MONTH_N,
               SOR.WEEK_N,
               SUM(SOR.WEEK_QUANTITY) WEEK_QUANTITY,
               SUM(SOR.ACTUAL_QUANTITY) ACTUAL_QUANTITY, --滚动计划数量
               SOR.R3_DATE,
               SOR.ERROR_DECRIBE,
               SOR.REASON,
               SOR.PROD_MANAGER, --产品经理
               SOR.DEPT_CODE, --经营体
               NVL((SELECT SUM(V.QUANTITY)
                     FROM VI_ROLLPLAN_ACT_PREPARE V
                    WHERE V.MATERIAL_CODE = SOR.Material_Code
                      AND V.MANU_END_DATE BETWEEN SOR.START_DATE AND
                          SOR.END_DATE
                      AND V.ORDER_PROD_MANAGER = SOR.PROD_MANAGER),
                   0) AS QUANTITY, --已经销售数量
               ABS(NVL((SELECT SUM(V.QUANTITY)
                         FROM VI_ROLLPLAN_ACT_PREPARE V
                        WHERE V.MATERIAL_CODE = SOR.MATERIAL_CODE
                          AND V.MANU_END_DATE BETWEEN SOR.START_DATE AND
                              SOR.END_DATE
                          AND V.ORDER_PROD_MANAGER = SOR.PROD_MANAGER),
                       0) - SUM(SOR.ACTUAL_QUANTITY)) AS RATIO_VAL
          FROM SI_OES_ROLLPLAN SOR
         GROUP BY SOR.PROD_TYPE_CODE,
                  SOR.MARKET,
                  SOR.FACTORY_CODE,
                  SOR.MATERIAL_CODE,
                  SOR.HAIER_MODEL,
                  SOR.CUSTOMER_MODEL,
                  SOR.ROLL_RATE,
                  SOR.START_DATE,
                  SOR.END_DATE,
                  SOR.MONTH_DATE,
                  SOR.MONTH_N,
                  SOR.WEEK_N,
                  SOR.R3_DATE,
                  SOR.ERROR_DECRIBE,
                  SOR.REASON,
                  SOR.PROD_MANAGER,
                  SOR.DEPT_CODE) TMP
  LEFT JOIN USER_INFO U
    ON U.EMP_CODE = TMP.PROD_MANAGER
 WHERE 1 = 1
   AND tmp.PROD_MANAGER = '00065505'
   AND tmp.WEEK_N >= 3
   AND tmp.WEEK_N <= 3
   AND tmp.ROLL_RATE = TO_DATE('2014-04-28', 'yyyy-MM-dd')
	   GROUP BY U.NAME, TMP.PROD_MANAGER
