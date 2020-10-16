SELECT DISTINCT TMP.PROD_TYPE AS 产品大类, --产品大类
                TMP.PROD_T_CODE AS 产品大类编码, --产品大类Code
                TMP.MATERIAL_CODE AS 物料, --物料
                TMP.HAIER_MODEL AS 海尔型号, --海尔型号
                TMP.CUSTOMER_MODEL AS 客户型号, --客户型号
                TMP.ROLL_RATE AS 计划时间, --计划时间
                TMP.START_DATE AS 开始时间, --开始时间
                TMP.END_DATE AS 结束时间, --结束时间
                TMP.PROD_MANAGER AS 工号,
                TMP.NAME AS 产品经理, --产品经理
                SUM(TMP.WEEK_QUANTITY) AS 计划数量,
                SUM(TMP.ACTUAL_QUANTITY) AS 滚动计划审核数量, --滚动计划数量
                SUM(TMP.PROD_QUANTITY) AS 已经销售数量, --已经销售数量
                SUM(TMP.RATIO_VAL) AS 差异, --差异
                CASE
                  WHEN SUM(TMP.RATIO_VAL) < SUM(TMP.ACTUAL_QUANTITY) THEN
                   ROUND(SUM(TMP.RATIO_VAL) / SUM(TMP.ACTUAL_QUANTITY) * 100,
                         2)
                  WHEN SUM(TMP.RATIO_VAL) = 0 THEN
                   0
                  WHEN SUM(TMP.RATIO_VAL) >= SUM(TMP.ACTUAL_QUANTITY) THEN
                   100
                END AS 离谱率, --离谱率
                CASE
                  WHEN SUM(TMP.RATIO_VAL) < SUM(TMP.ACTUAL_QUANTITY) THEN
                   ROUND((1 - SUM(TMP.RATIO_VAL) / SUM(TMP.ACTUAL_QUANTITY)) * 100,
                         2)
                  WHEN SUM(TMP.RATIO_VAL) = 0 THEN
                   100
                  WHEN SUM(TMP.RATIO_VAL) >= SUM(TMP.ACTUAL_QUANTITY) THEN
                   0
                END AS 准确率 --准确率
FROM   (
        
        SELECT DISTINCT CPT.PROD_TYPE,
                         PI.PROD_T_CODE,
                         PI.MATERIAL_CODE AS MATERIAL_CODE,
                         PI.HAIER_MODEL,
                         PI.CUSTOMER_MODEL,
                         TO_DATE('2013-12-16', 'YYYY-MM-DD') AS ROLL_RATE,
                         TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AS START_DATE,
                         TO_DATE('2013-12-16', 'YYYY-MM-DD')+91 AS END_DATE,
                         NVL((SELECT SUM(S1.WEEK_QUANTITY)
                             FROM   SI_OES_ROLLPLAN S1
                             WHERE  S1.ROLL_RATE =
                                    TO_DATE('2013-12-16', 'YYYY-MM-DD')
                             AND    S1.WEEK_N <> '3'
                             AND    S1.MATERIAL_CODE = PI.MATERIAL_CODE
                             AND    S1.PROD_MANAGER = S.ORDER_PROD_MANAGER),
                             0) AS WEEK_QUANTITY,
                         NVL((SELECT SUM(SR.ACTUAL_QUANTITY)
                             FROM   SI_OES_ROLLPLAN SR
                             WHERE  SR.MATERIAL_CODE = PI.MATERIAL_CODE
                             AND    SR.PROD_MANAGER = S.ORDER_PROD_MANAGER
                             AND    SR.ROLL_RATE =
                                    TO_DATE('2013-12-16', 'YYYY-MM-DD')
                             AND    SR.WEEK_N <> '3'),
                             0) AS ACTUAL_QUANTITY,
                         
                         (SELECT SUM(SSOI.PROD_QUANTITY)
                          FROM   SO_SALES_ORDER_ITEM SSOI,
                                 SO_ACT              AA,
                                 SO_SALES_ORDER      SSO
                          WHERE  SSOI.MATERIAL_CODE = PI.MATERIAL_CODE
                          AND    AA.ORDER_NUM = SSOI.ORDER_CODE
                          AND    SSOI.ORDER_CODE = SSO.ORDER_CODE
                          AND    AA.ACT_ID = 'followGoods'
                          AND    (SSO.ORDER_AUDIT_FLAG = '1' OR
                                SSO.ORDER_AUDIT_FLAG = '3' OR
                                SSO.ORDER_AUDIT_FLAG IS NULL)
                          AND    SSO.ORDER_PROD_MANAGER = S.ORDER_PROD_MANAGER
                          AND    AA.PLAN_FINISH_DATE BETWEEN
                                 TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AND
                                 TO_DATE('2013-12-16', 'YYYY-MM-DD')+91
                          
                          ) AS PROD_QUANTITY,
                         
                         ABS(NVL((SELECT SUM(SR.ACTUAL_QUANTITY)
                                 FROM   SI_OES_ROLLPLAN SR
                                 WHERE  SR.MATERIAL_CODE = PI.MATERIAL_CODE
                                 AND    SR.PROD_MANAGER = S.ORDER_PROD_MANAGER
                                 AND    SR.ROLL_RATE =
                                        TO_DATE('2013-12-16', 'YYYY-MM-DD')
                                 AND    SR.WEEK_N <> '3'),
                                 0) -
                             (SELECT SUM(SSOI.PROD_QUANTITY)
                              FROM   SO_SALES_ORDER_ITEM SSOI,
                                     SO_ACT              AA,
                                     SO_SALES_ORDER      SSO
                              WHERE  SSOI.MATERIAL_CODE = PI.MATERIAL_CODE
                              AND    AA.ORDER_NUM = SSOI.ORDER_CODE
                              AND    SSOI.ORDER_CODE = SSO.ORDER_CODE
                              AND    AA.ACT_ID = 'followGoods'
                              AND    (SSO.ORDER_AUDIT_FLAG = '1' OR
                                    SSO.ORDER_AUDIT_FLAG = '3' OR
                                    SSO.ORDER_AUDIT_FLAG IS NULL)
                              AND    SSO.ORDER_PROD_MANAGER =
                                     S.ORDER_PROD_MANAGER
                              AND    AA.PLAN_FINISH_DATE BETWEEN
                                     TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AND
                                     TO_DATE('2013-12-16', 'YYYY-MM-DD')+91
                              
                              )) AS RATIO_VAL,
                         
                         TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AS WEEK_START,
                         S.ORDER_PROD_MANAGER AS PROD_MANAGER,
                         UI.NAME
        
        FROM   SO_SALES_ORDER      S,
                SO_ACT              A,
                SO_SALES_ORDER_ITEM PI,
                CD_PROD_TYPE        CPT,
                USER_INFO           UI
        WHERE  1 = 1
        AND    A.ORDER_NUM = S.ORDER_CODE
        AND    PI.ORDER_CODE = S.ORDER_CODE
        AND    (S.ORDER_AUDIT_FLAG = '1' OR S.ORDER_AUDIT_FLAG = '3' OR
              S.ORDER_AUDIT_FLAG IS NULL)
        AND    A.ACT_ID = 'followGoods'
        AND    A.PLAN_FINISH_DATE BETWEEN TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AND
               TO_DATE('2013-12-16', 'YYYY-MM-DD')+91
        AND    PI.PROD_T_CODE = CPT.PROD_TYPE_CODE
        AND    S.ORDER_PROD_MANAGER = UI.EMP_CODE
              --AND S.ORDER_PROD_MANAGER = '00081141'
        AND    PI.FACTORY_CODE NOT IN ('9390', '9380', '9330') --1739374
        GROUP  BY CPT.PROD_TYPE,
                   PI.PROD_T_CODE,
                   PI.MATERIAL_CODE,
                   PI.HAIER_MODEL,
                   PI.CUSTOMER_MODEL,
                   PI.FACTORY_CODE,
                   S.ORDER_PROD_MANAGER,
                   A.PLAN_FINISH_DATE,
                   UI.NAME
        
        UNION ALL
        
        SELECT CPT.PROD_TYPE, --产品大类
               SOR.PROD_TYPE_CODE, --产品大类Code
               SOR.MATERIAL_CODE, --物料
               sor.haier_model,
               sor.customer_model,
               SOR.ROLL_RATE, --计划时间
               TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AS START_DATE, --开始时间
               TO_DATE('2013-12-16', 'YYYY-MM-DD')+91 AS END_DATE, --结束时间
               SUM(SOR.WEEK_QUANTITY) AS WEEK_QUANTITY,
               SUM(SOR.ACTUAL_QUANTITY) AS ACTUAL_QUANTITY,
               0 AS PROD_QUANTITY,
               SUM(SOR.ACTUAL_QUANTITY) AS RATIO_VAL,
               TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AS WEEK_START,
               SOR.PROD_MANAGER AS PROD_MANAGER,
               UI.NAME
        
        FROM   SI_OES_ROLLPLAN SOR,
               CD_PROD_TYPE    CPT,
               USER_INFO       UI
        WHERE  SOR.ROLL_RATE = TO_DATE('2013-12-16', 'YYYY-MM-DD')
        AND    SOR.PROD_TYPE_CODE = CPT.PROD_TYPE_CODE(+)
        AND    SOR.WEEK_N <> '3'
        AND    SOR.PROD_MANAGER = UI.EMP_CODE(+)
        AND    SOR.MATERIAL_CODE NOT IN
               (SELECT T.MATERIAL_CODE
                 FROM   SO_SALES_ORDER_ITEM T,
                        SO_ACT              A,
                        SO_SALES_ORDER      S
                 WHERE  A.ORDER_NUM = T.ORDER_CODE
                 AND    A.ACT_ID = 'followGoods'
                 AND    S.ORDER_CODE = T.ORDER_CODE
                 AND    (S.ORDER_AUDIT_FLAG = '1' OR S.ORDER_AUDIT_FLAG = '3' OR
                       S.ORDER_AUDIT_FLAG IS NULL)
                 AND    S.ORDER_PROD_MANAGER = SOR.PROD_MANAGER
                 AND    SOR.ACTUAL_QUANTITY > 0
                 AND    A.PLAN_FINISH_DATE BETWEEN
                        TO_DATE('2013-12-16', 'YYYY-MM-DD')+28 AND
                        TO_DATE('2014-01-19', 'YYYY-MM-DD')+91)
        GROUP  BY CPT.PROD_TYPE, --产品大类
                  SOR.PROD_TYPE_CODE, --产品大类Code
                  SOR.MATERIAL_CODE, --物料
                   sor.haier_model,
               sor.customer_model,
                  SOR.ROLL_RATE,
                  SOR.PROD_MANAGER,
                  UI.NAME
        
        ) TMP

GROUP  BY TMP.PROD_TYPE, --产品大类
          TMP.PROD_T_CODE, --产品大类Code
          TMP.HAIER_MODEL,
          TMP.CUSTOMER_MODEL,
          TMP.MATERIAL_CODE, --物料
          TMP.ROLL_RATE, --计划时间
          TMP.START_DATE, --开始时间
          TMP.END_DATE, --结束时间
          TMP.NAME,
          TMP.PROD_MANAGER
ORDER  BY TMP.START_DATE,
          TMP.MATERIAL_CODE
