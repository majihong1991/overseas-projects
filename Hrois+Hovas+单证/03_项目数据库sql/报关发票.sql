SELECT *
    FROM   (SELECT D.ORDER_CODE,
                        D.CUSTOMER_MODEL,
                        D.HAIER_MODEL,
                        T.SIMPLE_CODE,
                        D.ORDER_CODE MARKS,
                        SUM(D.PROD_QUANTITY) PROD_QUANTITY,
                        R.CURRENCY,
                        TO_CHAR(ROUND(D.CUST_PRICE,2)) CONDITION_RATE,
                        TO_CHAR(ROUND(SUM(D.CUST_AMOUNT),2)) CONDITION_VALUE,
                 T.GOODS_DESC AS HAIER_PROD_DESC,
                 DECODE(D.UNIT, '', 'PC', D.UNIT) AS UNIT
            FROM   SO_SALES_ORDER_ITEM D
            JOIN   SO_SALES_ORDER R
            ON     (D.ORDER_CODE = R.ORDER_CODE AND
                     R.ORDER_TYPE IN ('005', '046', '047'))
            JOIN   ACT_BOOK_ORDER_ITEM T
            ON     (D.ORDER_CODE = T.ORDER_CODE AND
                   D.ORDER_ITEM_LINECODE = T.ORDER_ITEM_CODE)
            LEFT   JOIN CD_MATERIAL M
            ON     (D.MATERIAL_CODE = M.MATERIAL_CODE)
            WHERE  T.BOOK_CODE = #{bookCode}
            AND   R.ORDER_CODE NOT IN  (SELECT MO.MERGE_ORDER_NUM
            FROM   SO_ORDER_MERGE MO
            WHERE  MO.MERGE_ORDER_NUM IS NOT NULL
            UNION
            SELECT M1.ORDER_NUM FROM SO_ORDER_MERGE M1 WHERE M1.ORDER_NUM IS NOT NULL)
                GROUP BY D.ORDER_CODE,D.CUSTOMER_MODEL,D.HAIER_MODEL,R.CURRENCY,D.CUST_PRICE,T.SIMPLE_CODE,T.GOODS_DESC,D.UNIT
            UNION
            SELECT T.ORDER_NUM AS ORDER_CODE,
                   T.CUSTOMER_MODEL,
                   T.HAIER_MODEL,
                   T.SIMPLE_CODE AS SIMPLE_CODE,
                   T.ORDER_NUM MARKS,
                   T.QUANTITY AS PROD_QUANTITY,
                   R.CURRENCY,
                   TO_CHAR(T.CUST_PRICE) AS CONDITION_RATE,
                      TO_CHAR(T.CUST_AMOUNT) AS CONDITION_VALUE,
                      T.HAIER_PROD_DESC AS HAIER_PROD_DESC,
                      DECODE(T.UNIT, '', 'PC', T.UNIT) AS UNIT
            FROM   SO_ORDER_MERGE T
            LEFT   JOIN SO_SALES_ORDER R
            ON     T.ORDER_NUM = R.ORDER_CODE
            LEFT   JOIN ACT_BOOK_ORDER_ITEM M
            ON     T.ORDER_NUM = M.ORDER_CODE
            WHERE  M.BOOK_CODE = #{bookCode}
            UNION
         SELECT DISTINCT (D.HGMS_ITEM_CODE) ORDER_CODE,
                      D.CUSTOMER_MODEL,
                      D.HAIER_MODEL,
                      T.SIMPLE_CODE,
                      R.ORDER_CODE MARKS,
                      SUM(D.PROD_QUANTITY) PROD_QUANTITY,
                      R.CURRENCY,
                      TO_CHAR(ROUND(D.CUST_PRICE, 2)) CONDITION_RATE,
                      TO_CHAR(ROUND(SUM(D.CUST_AMOUNT), 2)) CONDITION_VALUE,
                      T.GOODS_DESC AS HAIER_PROD_DESC,
                      DECODE(D.UNIT, '', 'PC', D.UNIT) AS UNIT
      FROM   SP_SALES_ORDER_ITEM D,
           SO_SALES_ORDER R,
            CD_MATERIAL M,
            ACT_BOOK_ORDER_ITEM T
      WHERE    D.ORDER_CODE = R.ORDER_CODE AND R.ORDER_TYPE IN ('5', '6', '9')
      AND D.MATERIAL_CODE = M.MATERIAL_CODE(+)
      AND  R.ORDER_CODE = T.ORDER_CODE
      AND T.MARKS = D.HGMS_ITEM_CODE
      AND T.BOOK_CODE = #{bookCode}
      GROUP  BY D.HGMS_ITEM_CODE,
                D.CUSTOMER_MODEL,
                D.HAIER_MODEL,
                R.ORDER_CODE,
                R.CURRENCY,
                D.CUST_PRICE,
                T.SIMPLE_CODE,
                T.GOODS_DESC,
                D.UNIT
            <if test="queryFlag=='1'.toString()">
            UNION
            SELECT T.ORDER_NUM AS ORDER_CODE,
                   T.PART_NAME_ENGLISH AS CUSTOMER_MODEL,
                   '' GOODS_COMMENT,
                   '' HAIER_MODEL,
                   T.ORDER_NUM MARKS,
                   SUM(T.OUTER_QUA) AS PROD_QUANTITY,
                   '' CURRENCY,
                   '' AS CONDITION_RATE,
                   '' AS CONDITION_VALUE,
                   '' AS HAIER_PROD_DESC,
                   '' AS UNIT
            FROM   ACT_ORDER_SPECIAL_ITEM T
            JOIN   ACT_BOOK_ORDER_ITEM M
            ON     T.ORDER_NUM = M.ORDER_CODE
            WHERE  M.BOOK_CODE = #{bookCode}
            GROUP  BY T.ORDER_NUM,
                      T.PART_NAME_ENGLISH
            </if>) A
    ORDER  BY A.ORDER_CODE
