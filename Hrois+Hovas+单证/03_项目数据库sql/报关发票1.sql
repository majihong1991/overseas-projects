SELECT *
FROM   (SELECT D.ORDER_CODE,
               D.CUSTOMER_MODEL,
               D.HAIER_MODEL,
               T.SIMPLE_CODE,
               SUM(D.PROD_QUANTITY) PROD_QUANTITY,
               R.CURRENCY,
               TO_CHAR(ROUND(D.CUST_PRICE, 2)) CONDITION_RATE,
               TO_CHAR(ROUND(SUM(D.CUST_AMOUNT), 2)) CONDITION_VALUE,
               T.GOODS_DESC AS HAIER_PROD_DESC,
               DECODE(D.UNIT, '', 'PC', D.UNIT) AS UNIT
        FROM   SO_SALES_ORDER_ITEM D
        LEFT   JOIN SO_SALES_ORDER R
        ON     D.ORDER_CODE = R.ORDER_CODE
        JOIN   ACT_BOOK_ORDER_ITEM T
        ON     (D.ORDER_CODE = T.ORDER_CODE AND
               D.ORDER_ITEM_LINECODE = T.ORDER_ITEM_CODE)
        LEFT   JOIN CD_MATERIAL M
        ON     (D.MATERIAL_CODE = M.MATERIAL_CODE)
        WHERE  T.BOOK_CODE = #{BOOKCODE}
        GROUP  BY D.ORDER_CODE,
                  D.CUSTOMER_MODEL,
                  D.HAIER_MODEL,
                  R.CURRENCY,
                  D.CUST_PRICE,
                  T.SIMPLE_CODE,
                  T.GOODS_DESC,
                  D.UNIT
        UNION
        SELECT T.ORDER_NUM AS ORDER_CODE,
               T.CUSTOMER_MODEL,
               T.HAIER_MODEL,
               '' GOODS_COMMENT,
               T.QUANTITY AS PROD_QUANTITY,
               R.CURRENCY,
               TO_CHAR(T.CUST_PRICE) AS CONDITION_RATE,
               TO_CHAR(T.CUST_AMOUNT) AS CONDITION_VALUE,
               '' AS HAIER_PROD_DESC,
               DECODE(T.UNIT, '', 'PC', T.UNIT) AS UNIT
        FROM   SO_ORDER_MERGE T
        LEFT   JOIN SO_SALES_ORDER R
        ON     T.ORDER_NUM = R.ORDER_CODE
        LEFT   JOIN ACT_BOOK_ORDER_ITEM M
        ON     T.ORDER_NUM = M.ORDER_CODE
        WHERE  M.BOOK_CODE = #{BOOKCODE}
        UNION
        SELECT D.ORDER_CODE,
               D.CUSTOMER_MODEL,
               D.HAIER_MODEL,
               T.SIMPLE_CODE,
               SUM(D.PROD_QUANTITY) PROD_QUANTITY,
               R.CURRENCY,
               TO_CHAR(ROUND(D.CUST_PRICE, 2)) CONDITION_RATE,
               TO_CHAR(ROUND(SUM(D.CUST_AMOUNT), 2)) CONDITION_VALUE,
               T.GOODS_DESC AS HAIER_PROD_DESC,
               DECODE(D.UNIT, '', 'PC', D.UNIT) AS UNIT
        FROM   SP_SALES_ORDER_ITEM D
        LEFT   JOIN SO_SALES_ORDER R
        ON     D.ORDER_CODE = R.ORDER_CODE
        JOIN   ACT_BOOK_ORDER_ITEM T
        ON     (D.ORDER_CODE = T.ORDER_CODE)
        LEFT   JOIN CD_MATERIAL M
        ON     (D.MATERIAL_CODE = M.MATERIAL_CODE)
        WHERE  T.BOOK_CODE = #{BOOKCODE}
        GROUP  BY D.ORDER_CODE,
                  D.CUSTOMER_MODEL,
                  D.HAIER_MODEL,
                  R.CURRENCY,
                  D.CUST_PRICE,
                  T.SIMPLE_CODE,
                  T.GOODS_DESC,
                  D.UNIT
        UNION
        SELECT T.ORDER_NUM AS ORDER_CODE,
               T.PART_NAME_ENGLISH AS CUSTOMER_MODEL,
               '' GOODS_COMMENT,
               '' HAIER_MODEL,
               SUM(T.OUTER_QUA) AS PROD_QUANTITY,
               '' CURRENCY,
               '' AS CONDITION_RATE,
               '' AS CONDITION_VALUE,
               '' AS HAIER_PROD_DESC,
               '' AS UNIT
        FROM   ACT_ORDER_SPECIAL_ITEM T
        JOIN   ACT_BOOK_ORDER_ITEM M
        ON     T.ORDER_NUM = M.ORDER_CODE
        WHERE  M.BOOK_CODE = #{BOOKCODE}
        GROUP  BY T.ORDER_NUM,
                  T.PART_NAME_ENGLISH) A
