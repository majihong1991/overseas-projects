SELECT A.*,A.rowid FROM act_tax_back_info a WHERE A.ORDER_CODE IN ('SOP201311080000004','SOP201311080000041');

SELECT * FROM so_sales_order s WHERE s.order_code IN ('SOP201311080000004','SOP201311080000041');

SELECT * FROM so_sales_order_item soi WHERE soi.order_code IN ('SOP201311080000004','SOP201311080000041');

SELECT * FROM ACT_CUST_ORDER  O WHERE O.ORDER_CODE IN ('SOP201311080000004','SOP201311080000041') 

SELECT * FROM CD_DEPARTMENT D WHERE D.DEPT_CODE IN ('9050','9092')
