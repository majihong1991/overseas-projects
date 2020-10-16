SELECT DISTINCT
	tt.order_code AS 订单号,
	ai.act_cnt_code AS 装箱预编号,
	t.loading_box_code AS 集装箱号,
	vi.getpackageinfo_actual AS 实际完成装箱时间,
	ab.book_code AS 订舱号,
	ab.ship_paper_code AS 下货纸提单号,
	(
	SELECT
		cpt.prod_type
	FROM
		cd_prod_type cpt
	WHERE
		cpt.prod_type_code = st.prod_t_code
	) AS 产品大类,
	st.material_code AS 物料号,
	st.haier_model AS 海尔型号,
	st.customer_model AS 客户型号,
	st.affirm_num AS 特技单号,
	(
	SELECT
		T.NAME
	FROM
		CD_COUNTRY T
	WHERE
	tt.country_code = T.COUNTRY_CODE ) AS 国家,
	(
	SELECT
		cct.name
	FROM
		cd_customer cct
	WHERE
	tt.order_ship_to = cct.customer_code ) AS 送达方,
	(
	SELECT
		ct.name
	FROM
		cd_customer ct
	WHERE
	tt.order_sold_to = ct.customer_code) AS 售达方,
	st.prod_quantity AS 订单数量,
	sum( t.budget_quantity ) AS 本箱数量,
	cd.dept_name_cn AS 所属事业部,
	(
	SELECT
		u.NAME
	FROM
		user_info u
	WHERE
		u.emp_code = tt.order_exec_manager
	) AS 订单执行经理,
	(
	SELECT
		uu.NAME
	FROM
		user_info uu
	WHERE
		uu.emp_code = tt.order_prod_manager
	) AS 产品经理,
	tt.order_po_code AS 客户PO号,
	(
	SELECT
		s.item_name_cn
	FROM
		sys_lov s
	WHERE
		s.item_code = tt.port_start_code
		AND ITEM_TYPE = '17'
	) AS 始发港,
	(
	SELECT
		cp.port_name
	FROM
		cd_port cp
	WHERE
		cp.port_code = tt.port_end_code
	) AS 目的港,
	(
	SELECT
		cvv.vendor_name_cn
	FROM
		cd_vendor cvv
	WHERE
		abo.vendor_code = cvv.vendor_code
		AND cvv.vendor_type = '0'
	) AS 船公司,
	(
	SELECT
		cvcv.vendor_name_cn
	FROM
		cd_vendor cvcv
	WHERE
		abo.book_agent = cvcv.vendor_code
		AND cvcv.vendor_type = '3'
	) AS 货代,
	tt.invoice_num AS 发票号,
	tt.order_ship_date AS 客户要求出运时间,
	vi.schedule_actual AS 计划排定完成时间,
	vi.paymoney_actual AS 付款保障完成时间,
	vi.book_actual AS 订舱完成时间,
	vi.followgoods_actual AS 跟踪备货完成时间,
	vi.getpackageinfo_actual AS 装箱完成时间,
	vi.comprehensive_actual AS 制单完成时间,
	vi.declarationapply_actual AS 报关完成时间,
	vi.shipMent_actual AS 出运完成时间,
	vi.getnegoinfofromhope_actual AS 议付完成时间,
	vi.factorydetection_actual AS 首样完成时间
FROM
	so_sales_order tt,
	so_sales_order_item st,
	act_cnt t,
	act_cnt_item ai,
	act_ship_paper ab,
	vi_order_tmod vi,
	act_book_order_item ao,
	cd_department cd,
	act_book_order abo
WHERE
	tt.order_code = st.order_code
	AND tt.order_code = ai.order_num
	AND tt.order_code = vi.order_code
	AND tt.order_code = ao.order_code
	AND ao.book_code = ab.book_code
	AND ao.book_code = abo.book_code
	AND ai.act_cnt_code = t.loading_plan_code
	AND st.factory_code = cd.dept_code
	AND cd.dept_type = '0'
	AND tt.order_code

    in (
        '0004251999',
'0004251988',
'0004251954',
'0004149074'
            )
GROUP BY
	tt.order_code,
	ai.act_cnt_code,
	t.loading_box_code,
	vi.getpackageinfo_actual,
	ab.book_code,
	ab.ship_paper_code,
	st.prod_t_code,
	st.material_code,
	st.haier_model,
	st.customer_model,
	st.affirm_num,
	st.prod_quantity,
	cd.dept_name_cn,
	tt.order_exec_manager,
	tt.order_ship_to,
	vi.schedule_actual,
	vi.paymoney_actual,
	vi.book_actual,
	vi.followgoods_actual,
	vi.getpackageinfo_actual,
	vi.comprehensive_actual,
	vi.declarationapply_actual,
	vi.shipMent_actual,
	vi.getnegoinfofromhope_actual,
	vi.factorydetection_actual,
	st.prod_t_code,
	tt.port_start_code,
	tt.port_end_code,
	tt.country_code,
	tt.order_ship_to,
	tt.order_sold_to,
	tt.order_prod_manager,
	tt.order_po_code,
	tt.order_ship_date,
	abo.vendor_code,
	abo.book_agent,
	tt.invoice_num