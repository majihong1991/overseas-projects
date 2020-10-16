--代码 AuditMainAction.review()

--首先查看行项目有几条
SELECT 
       ORDER_ITEM_LINECODE
  FROM SO_SALES_ORDER_ITEM
 WHERE ORDER_CODE = '0004340024';

--与审核节点对应行项目是否正常,hrnum是否有不存在的情况，如果有，则删除
SELECT ORDER_NUM,
       ORDER_ITEM_LINECODE,
       HR_NUM,
       HR_DATE,
       HAVE_BOM,
       DELISTING,
       FAILURE_RATE,
       QUALITY_PROBLEM,
       HAVE_ROLL_PLAN
  FROM SO_AUDIT_DETAIL
 WHERE ORDER_NUM = '0004340024'
   for update;
