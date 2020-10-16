select count(b.material_code), b.material_code, b.factory_code
  from so_sales_order_item b
 where b.material_code in (
                           
                           )
 group by b.material_code, b.factory_code
