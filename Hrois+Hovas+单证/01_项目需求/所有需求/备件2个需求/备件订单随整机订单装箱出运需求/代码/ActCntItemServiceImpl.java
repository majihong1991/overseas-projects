/* Powered By [rapid-framework] Web Site: http://www.rapid-framework.org.cn
 * Google Code: http://code.google.com/p/rapid-framework/ Since 2008 - 2013 */
package com.haier.hrois.order.cnt.service.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.activiti.engine.RuntimeService;
import org.activiti.engine.TaskService;
import org.activiti.engine.impl.persistence.entity.ExecutionEntity;
import org.activiti.engine.impl.persistence.entity.SuspensionState;
import org.activiti.engine.runtime.Execution;
import org.activiti.engine.task.Task;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.ui.freemarker.FreeMarkerTemplateUtils;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;

import com.haier.base.model.DataGrid;
import com.haier.hrois.activiti.dao.WfProcinstanceDao;
import com.haier.hrois.activiti.domain.WfProcinstance;
import com.haier.hrois.activiti.service.WfProcinstanceService;
import com.haier.hrois.basic.domain.SysLov;
import com.haier.hrois.datatrans.dao.DbLinkDao;
import com.haier.hrois.datatrans.domain.DbLink;
import com.haier.hrois.datatrans.facade.DatabaseFactory;
import com.haier.hrois.datatrans.service.impl.HopeInterfaceService;
import com.haier.hrois.order.cnt.dao.ActCntDao;
import com.haier.hrois.order.cnt.dao.ActCntItemDao;
import com.haier.hrois.order.cnt.domain.ActCnt;
import com.haier.hrois.order.cnt.domain.ActCntItem;
import com.haier.hrois.order.cnt.domain.ComoUp;
import com.haier.hrois.order.cnt.domain.PackingInfo;
import com.haier.hrois.order.cnt.query.ActCntItemQuery;
import com.haier.hrois.order.cnt.query.ActCntQuery;
import com.haier.hrois.order.cnt.service.ActCntItemService;
import com.haier.hrois.order.confirm.dao.SalesOrderDao;
import com.haier.hrois.order.confirm.domain.SalesOrder;
import com.haier.hrois.order.confirm.query.SalesOrderQuery;
import com.haier.hrois.order.confirm.service.SalesOrderService;
import com.haier.hrois.order.edit.service.OrderEditService;
import com.haier.hrois.specialschema.domain.SpecialBarcode;
import com.haier.hrois.specialschema.service.SpecialBarcodeService;
import com.haier.hrois.util.Env;
import com.haier.hrois.util.SysLovUtil;
import com.haier.hrois.util.ValidateUtil;
import com.haier.openplatform.console.info.spi.SendEmailServiceClient;
import com.haier.openplatform.hmc.domain.Email;
import com.haier.openplatform.hmc.domain.Recipient;
import com.haier.openplatform.util.Pager;

import freemarker.core.ParseException;
import freemarker.template.MalformedTemplateNameException;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateNotFoundException;
import net.sf.json.JSONObject;

/** @author */
@Service("actCntItemService")
public class ActCntItemServiceImpl implements ActCntItemService {
	@Resource
	private ActCntItemDao actCntItemDao;
	@Resource
	private DbLinkDao dbLinkDao;
	@Resource
	private ActCntDao actCntDao;
	@Resource
	private RuntimeService runtimeService;
	@Resource
	private WfProcinstanceDao wfProcinstanceDao;
	@Resource
	private OrderEditService orderEditService;
	@Resource
	private TaskService taskService;
	@Resource
	private WfProcinstanceService wfProcinstanceService;
	@Resource
	private SendEmailServiceClient sendEmailServiceClient;
	@Resource
	private SalesOrderDao salesOrderDao;
	@Resource
	private SalesOrderService salesOrderService;
	@Resource
	private SpecialBarcodeService specialBarcodeService;
	@Resource
	private ActCntItemService actCntItemService;
	
    @Autowired
    public JavaMailSenderImpl mailSender;
    @Autowired
    private FreeMarkerConfigurer freemarkerConfig;
    @Resource
    private HopeInterfaceService hopeInterfaceService;
    
	private String[] str;
	private Logger logger = Logger.getLogger(ActCntItemServiceImpl.class);

	public void setActCntItemDao(ActCntItemDao dao) {
		this.actCntItemDao = dao;
	}

	public DataGrid datagrid(ActCntItemQuery actCntItemQuery) {
		DataGrid j = new DataGrid();
		Pager<ActCntItem> pager = find(actCntItemQuery);
		j.setRows(getQuerysFromEntitys(pager.getRecords()));
		j.setTotal(pager.getTotalRecords());
		return j;
	}

	/**
	 * @param actCntItems
	 * @return
	 */
	private List<ActCntItemQuery> getQuerysFromEntitys(List<ActCntItem> actCntItems) {
		List<ActCntItemQuery> actCntItemQuerys = new ArrayList<ActCntItemQuery>();
		if (actCntItems != null && actCntItems.size() > 0) {
			for (ActCntItem tb : actCntItems) {
				ActCntItemQuery b = new ActCntItemQuery();
				BeanUtils.copyProperties(tb, b);
				actCntItemQuerys.add(b);
			}
		}
		return actCntItemQuerys;
	}

	/**
	 * @param actCntItemQuery
	 * @return
	 */
	private Pager<ActCntItem> find(ActCntItemQuery actCntItemQuery) {
		return actCntItemDao.findPage(actCntItemQuery);
	}

	public ActCntItem add(ActCntItemQuery actCntItemQuery) {
		ActCntItem t = new ActCntItem();
		BeanUtils.copyProperties(actCntItemQuery, t);
		actCntItemDao.save(t);
		actCntItemQuery.setActCntItemCode(t.getActCntItemCode());
		return t;
	}

	/**
	 * @author zhangjk @2013-8-30
	 * @description 添加
	 * @param actCntItemQuery
	 * @return
	 */
	public ActCntItem addCntItem(ActCntItemQuery actCntItemQuery) {
		ActCntItem t = new ActCntItem();
		BeanUtils.copyProperties(actCntItemQuery, t);
		actCntItemDao.addCntItem(t);
		return t;
	}

	public void update(ActCntItemQuery actCntItemQuery) {
		ActCntItem t = actCntItemDao.getById(actCntItemQuery.getActCntItemCode());
		if (t != null) {
			BeanUtils.copyProperties(actCntItemQuery, t);
		}
		actCntItemDao.update(t);
	}

	/**
	 * @author zhangjk @2013-8-30
	 * @description 修改
	 * @param orderCode
	 */
	public int deleteActItem(String orderCode) {
		return actCntItemDao.deleteActItem(orderCode);
	}

	public void delete(java.lang.String[] ids) {
		if (ids != null) {
			for (java.lang.String id : ids) {
				ActCntItem t = actCntItemDao.getById(id);
				if (t != null) {
					actCntItemDao.deleteById(id);
				}
			}
		}
	}

	public void deleteByOrderCode(String orderCode) {
		actCntItemDao.deleteById(orderCode);
	}

	public ActCntItem get(ActCntItemQuery actCntItemQuery) {
		return actCntItemDao.getById(actCntItemQuery.getActCntItemCode());
	}

	public ActCntItem get(String id) {
		return actCntItemDao.getById(id);
	}

	public List<ActCntItemQuery> listAll(ActCntItemQuery actCntItemQuery) {
		List<ActCntItem> list = actCntItemDao.findList(actCntItemDao.getMybatisMapperNamesapce() + ".findList",
				actCntItemQuery);
		List<ActCntItemQuery> listQuery = getQuerysFromEntitys(list);
		return listQuery;
	}

	public List<ActCntItemQuery> findActCntItem(String loadingPlanCode) {
		return this.actCntItemDao.findActCntItem(loadingPlanCode);
	}

	/*
	 * 获取胶州空调二期散件订单条码传到iMES
	 */
	public void sendUTD() {
		List<SpecialBarcode> datas = specialBarcodeService.findBarcodeByDate();
		for (SpecialBarcode data : datas) {
			this.queryUTD(data);
		}
	}

	/**
	 * 查询
	 * 
	 * @param data
	 */
	public void queryUTD(SpecialBarcode data) {
		DbLink dblink = this.dbLinkDao.getById("20160825001");
		String querySQL = "select * from UDT_IO_Q_HORISINFO_SJ where WorkUser_SaleOrderNUM = ?";
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dblink);
			pstmt = conn.prepareStatement(querySQL);
			pstmt.setString(1, data.getOrderCode());
			rs = pstmt.executeQuery();
			if (rs.next()) { // 已经存在了，更新
				this.updUTD(data, dblink);
			} else {
				this.saveUTD(data, dblink);
			}
		} catch (Exception e) {
			logger.error(e.getMessage());
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
		}
	}

	/**
	 * 保存
	 * 
	 * @param data
	 */
	public void saveUTD(SpecialBarcode data, DbLink dblink) {
		StringBuffer saveSQL = new StringBuffer();
		saveSQL.append("insert into UDT_IO_Q_HORISINFO_SJ(");
		saveSQL.append("FactoryNo,WorkUser_SaleOrderNUM,PackTagNum,PreliminaryNumbers,Quantity)");
		saveSQL.append(" values(?,?,?,?,?)");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dblink);
			pstmt = conn.prepareStatement(saveSQL.toString());
			pstmt.setObject(1, data.getFactoryCode());
			pstmt.setObject(2, data.getOrderCode());
			pstmt.setObject(3, data.getBarcode());
			pstmt.setObject(4, data.getActCntCode());
			pstmt.setObject(5, data.getPackageQua());
			pstmt.execute();
		} catch (Exception e) {
			logger.error(e.getMessage());
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
		}
	}

	/**
	 * 更新
	 * 
	 * @param data
	 */
	public void updUTD(SpecialBarcode data, DbLink dblink) {
		StringBuffer updSQL = new StringBuffer();
		updSQL.append("update UDT_IO_Q_HORISINFO_SJ set FactoryNo = ?, PackTagNum = ?, ");
		updSQL.append("PreliminaryNumbers = ?, Quantity = ? where WorkUser_SaleOrderNUM = ?");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dblink);
			pstmt = conn.prepareStatement(updSQL.toString());
			pstmt.setObject(1, data.getFactoryCode());
			pstmt.setObject(2, data.getBarcode());
			pstmt.setObject(3, data.getActCntCode());
			pstmt.setObject(4, data.getPackageQua());
			pstmt.setObject(5, data.getOrderCode());
			pstmt.execute();
		} catch (Exception e) {
			logger.error(e.getMessage());
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
		}
	}

	@Override
	public void sendPackingFactory(String orderCode) {
		List<String> conTractCodes = new ArrayList<String>();
		conTractCodes.add("0040002495");
		conTractCodes.add("0040003150");
		conTractCodes.add("0040004500");
		conTractCodes.add("0040002656");
		conTractCodes.add("0040004259");
		conTractCodes.add("0040004804");
		conTractCodes.add("0040004076");
		conTractCodes.add("0040004269");
		conTractCodes.add("0040004066");
		conTractCodes.add("0040004587");
		conTractCodes.add("0040004096");
		conTractCodes.add("0040004230");
		conTractCodes.add("0040004782");
		conTractCodes.add("0040004783");
		conTractCodes.add("0040004093");
		conTractCodes.add("0040004072");
		conTractCodes.add("0040004641");
		conTractCodes.add("0040004174");
		conTractCodes.add("0040002431");
		conTractCodes.add("0040004753");
		conTractCodes.add("0040004733");
		SalesOrder salesOrder = salesOrderDao.getOrderInfoByOrderCode(orderCode);
		
		/**
		 * 备件订单随整机装箱扫描发货
		 * 2020-03-24
		 * 整机订单装箱信息发送工厂之前，更新一起装箱发运的备件订单号
		 * @param attachOrder
		 */
		this.actCntItemDao.updateLoadingAttachOrder(orderCode);
		
		boolean b = conTractCodes.contains(salesOrder.getContractCode());
		List<Map<String, String>> datas = this.actCntItemDao.findSendData(orderCode);
		for (Map<String, String> data : datas) {
			this.queryFactory(data, salesOrder, b, orderCode);
		}
		logger.debug("装箱信息发送完毕。。。");
	}

	public void queryFactory(Map<String, String> data, SalesOrder salesOrder, boolean b, String orderCode) {
		String querySQL = "select * from WXtidanOUT where cnt_item_id = ?";
		DbLink dblink = this.dbLinkDao.findDbLinkByOrderCode(orderCode);
		
		/**
		 * WMS测试数据库
		 */
		dblink.setServerIp("rm-m5et6zj830n5y6ga8.mysql.rds.aliyuncs.com");
		dblink.setDbName("gwms_test_1999");
		dblink.setDbUser("gwms_test_1999");
		dblink.setDbPass("Xv6Sg*IHb4");
		dblink.setDbPorts("3306");
		
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dblink);
			pstmt = conn.prepareStatement(querySQL);
			pstmt.setString(1, data.get("CNT_ITEM_ID"));
			rs = pstmt.executeQuery();
			if (rs.next()) {
				this.updFactory(data, salesOrder, b, dblink);
			} else {
				this.saveFactory(data, salesOrder, b, dblink);
			}
		} catch (Exception e) {
			logger.error(e.getMessage());
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
		}
	}

	/**
	 * 保存
	 * 
	 * @param data
	 */
	public void saveFactory(Map<String, String> data, SalesOrder salesOrder, boolean b, DbLink dblink) {
		StringBuffer saveSQL = new StringBuffer();
		if (b && "9230".equals(salesOrder.getFactoryCode())) {
			saveSQL.append("insert into WXtidanOUT(");
			saveSQL.append(
					"cnt_id,cnt_item_id,bill_loading_code,cnt_bg_code,td_name,dn_lfimg,arktx,bdhao,quxiang,danwei,");
			saveSQL.append("rel_material_code,BEZEI,MATNR,ATTACH_ORDER,KHM,PROD_TYPE_CODE,PROD_TYPE,HAIER_MODEL,TOTAL_VOLUME) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
		} else {
			saveSQL.append("insert into WXtidanOUT(");
			saveSQL.append(
					"cnt_id,cnt_item_id,bill_loading_code,cnt_bg_code,td_name,dn_lfimg,arktx,bdhao,quxiang,danwei,");
			saveSQL.append("rel_material_code,BEZEI,MATNR,ATTACH_ORDER,PROD_TYPE_CODE,PROD_TYPE,HAIER_MODEL,TOTAL_VOLUME) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
		}
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dblink);
			pstmt = conn.prepareStatement(saveSQL.toString());
			pstmt.setObject(1, data.get("CNT_ID"));
			pstmt.setObject(2, data.get("CNT_ITEM_ID"));
			pstmt.setObject(3, data.get("BILL_LOADING_CODE"));
			pstmt.setObject(4, data.get("CNT_BG_CODE"));
			pstmt.setObject(5, data.get("TD_NAME"));
			pstmt.setObject(6, data.get("DN_LFIMG"));
			pstmt.setObject(7, data.get("ARKTX"));
			pstmt.setObject(8, data.get("BDHAO"));
			pstmt.setObject(9, data.get("QUXIANG"));
			pstmt.setObject(10, data.get("DANWEI"));
			pstmt.setObject(11, data.get("REL_MATERIAL_CODE"));
			String bezei = data.get("BEZEI");
			String volume = String.valueOf(data.get("VOLUME1"));
			if (bezei != null && bezei.length() > 15) {
				bezei = bezei.substring(0, 15);
			}
			pstmt.setObject(12, bezei);
			pstmt.setObject(13, data.get("MATNR"));
			
			//备件订单随整机装箱扫描发货
			//2020-03-24 YXB  
			//随整机一起装箱出运的备件订单号
			pstmt.setObject(14, data.get("ATTACH_ORDER"));
			
			if (b && "9230".equals(salesOrder.getFactoryCode())) {
				pstmt.setObject(15, data.get("KHM"));
				pstmt.setObject(16, data.get("PROD_T_CODE"));
				pstmt.setObject(17, data.get("PROD_TYPE"));
				pstmt.setObject(18, data.get("HAIER_MODEL"));
				if(volume != null && !"".equals(volume) && !"null".equals(volume)){
					pstmt.setObject(19, data.get("VOLUME1"));
				}else{
					pstmt.setObject(19, data.get("VOLUME2"));
				}
			}else{
				pstmt.setObject(15, data.get("PROD_T_CODE"));
				pstmt.setObject(16, data.get("PROD_TYPE"));
				pstmt.setObject(17, data.get("HAIER_MODEL"));
				if(volume != null && !"".equals(volume) && !"null".equals(volume)){
					pstmt.setObject(18, data.get("VOLUME1"));
				}else{
					pstmt.setObject(18, data.get("VOLUME2"));
				}
			}
			pstmt.execute();
			logger.debug("*****执行成功，更新装箱主表数据状态******");
			this.actCntDao.updActCntLoadingFlag(data.get("CNT_BG_CODE"), "0");
		} catch (Exception e) {
			logger.error(e.getMessage());
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
		}
	}

	/**
	 * 更新
	 * 
	 * @param data
	 */
	public void updFactory(Map<String, String> data, SalesOrder salesOrder, boolean b, DbLink dblink) {
		StringBuffer updSQL = new StringBuffer();
		if (b && "9230".equals(salesOrder.getFactoryCode())) {
			updSQL.append("update WxtidanOUT set cnt_id = ?,bill_loading_code = ?,");
			updSQL.append("cnt_bg_code = ?,td_name = ?,dn_lfimg = ?,arktx = ?,bdhao = ?,quxiang = ?,danwei = ?,");
			updSQL.append("rel_material_code = ?,bezei = ?,matnr = ?,attach_order = ?,khm = ?,prod_type_code = ?,prod_type = ?,haier_model = ?,total_volume = ? where cnt_item_id = ? ");
		} else {
			updSQL.append("update WxtidanOUT set cnt_id = ?,bill_loading_code = ?,");
			updSQL.append("cnt_bg_code = ?,td_name = ?,dn_lfimg = ?,arktx = ?,bdhao = ?,quxiang = ?,danwei = ?,");
			updSQL.append("rel_material_code = ?,bezei = ?,matnr = ?,attach_order = ?,prod_type_code = ?,prod_type = ?,haier_model = ?,total_volume = ? where cnt_item_id = ? ");
		}
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dblink);
			pstmt = conn.prepareStatement(updSQL.toString());
			pstmt.setString(1, data.get("CNT_ID"));
			pstmt.setString(2, data.get("BILL_LOADING_CODE"));
			pstmt.setString(3, data.get("CNT_BG_CODE"));
			pstmt.setString(4, data.get("TD_NAME"));
			pstmt.setObject(5, data.get("DN_LFIMG"));
			pstmt.setString(6, data.get("ARKTX"));
			pstmt.setObject(7, data.get("BDHAO"));
			pstmt.setString(8, data.get("QUXIANG"));
			pstmt.setString(9, data.get("DANWEI"));
			pstmt.setString(10, data.get("REL_MATERIAL_CODE"));
			String bezei = data.get("BEZEI");
			String volume = String.valueOf(data.get("VOLUME1"));
			if (bezei != null && bezei.length() > 15) {
				bezei = bezei.substring(0, 15);
			}
			pstmt.setString(11, bezei);
			pstmt.setString(12, data.get("MATNR"));
			
			//备件订单随整机装箱扫描发货
			//2020-03-24 YXB  
			//随整机一起装箱出运的备件订单号
			pstmt.setString(13, data.get("ATTACH_ORDER"));
			
			if (b && "9230".equals(salesOrder.getFactoryCode())) {
				pstmt.setString(14, data.get("KHM"));
				pstmt.setObject(15, data.get("PROD_T_CODE"));
				pstmt.setObject(16, data.get("PROD_TYPE"));
				pstmt.setObject(17, data.get("HAIER_MODEL"));
				if(volume != null && !"".equals(volume) && !"null".equals(volume)){
					pstmt.setObject(18, data.get("VOLUME1"));
				}else{
					pstmt.setObject(18, data.get("VOLUME2"));
				}
				pstmt.setString(19, data.get("CNT_ITEM_ID"));
			} else {
				pstmt.setObject(14, data.get("PROD_T_CODE"));
				pstmt.setObject(15, data.get("PROD_TYPE"));
				pstmt.setObject(16, data.get("HAIER_MODEL"));
				if(volume != null && !"".equals(volume) && !"null".equals(volume)){
					pstmt.setObject(17, data.get("VOLUME1"));
				}else{
					pstmt.setObject(17, data.get("VOLUME2"));
				}
				pstmt.setString(18, data.get("CNT_ITEM_ID"));
			}
			pstmt.execute();
			logger.debug("*****执行成功，更新装箱主表数据状态******");
			this.actCntDao.updActCntLoadingFlag(data.get("CNT_BG_CODE"), "0");
		} catch (Exception e) {
			logger.error(e.getMessage());
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error(e.getMessage());
				}
			}
		}
	}

	@Override
	public Boolean getPackingFromFactory(String orderCode) {
		boolean flag = true;
		Date backCntDate = null;
		String query = "select * from WXtidanOUT where cnt_item_id = ?";
		List<ActCntItem> items = this.actCntItemDao.getCntItemByOrderCode(orderCode);
		DbLink dl = this.dbLinkDao.findDbLinkByOrderCode(orderCode);
		logger.debug("通过订单那获取数据库连接：" + JSONObject.fromObject(dl));
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dl);
			pstmt = conn.prepareStatement(query);
			for (ActCntItem item : items) {
				pstmt.setString(1, item.getActCntItemCode());
				rs = pstmt.executeQuery();
				if (rs.next()) {
					String aciid = rs.getString("cnt_item_id");
					Long scanQuantity = rs.getLong("fh_lfimg");
					String loadingBoxCode = rs.getString("cnt_code");
					if (rs.getString("endtime") != null) {
						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						backCntDate = sdf.parse(rs.getString("endtime"));
					}
					item.setScanQuantity(scanQuantity);
					item.setBackCntDate(backCntDate);
					item.setLoadingBoxCode(loadingBoxCode);
					if (item.getBudgetQuantity().compareTo(scanQuantity) == 0) {
						item.setScanFinishFlag("1");
					} else {
						flag = false;
					}
					this.actCntItemDao.updActCntItemScanQuantity(item);
					logger.debug("更新本地扫描数量 " + aciid + " --> " + scanQuantity);
				} else {
					flag = false;
				}
			}
			this.actCntItemDao.updateMainStatus(orderCode);
		} catch (Exception e) {
			flag = false;
		} finally {
			if (rs != null) {
				try {
					rs.close();
				} catch (SQLException e) {
					logger.error("excute sql got exception:", e);
				}
			}
			if (pstmt != null) {
				try {
					pstmt.close();
				} catch (SQLException e) {
					logger.error("excute sql got exception:", e);
				}
			}
			if (conn != null) {
				try {
					conn.close();
				} catch (SQLException e) {
					logger.error("excute sql got exception:", e);
				}
			}
		}
		if (flag) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("BUSINFORM_ID", orderCode);
			map.put("PROCESSDEFINITION_KEY", "orderTrace");
			WfProcinstance wp = wfProcinstanceDao.findProidByBusid(map);
			String id = wp.getProcessinstanceId();
			Execution execution = runtimeService.createExecutionQuery().processInstanceId(id)
					.activityId("getPackageInfo").singleResult();
			ExecutionEntity executionEntity = (ExecutionEntity) execution;
			Date orderMaxBackCntDate = this.actCntItemDao.getMaxBackCntDateByOrderCode(orderCode);
			// execution 不为空 而且是处于活动状态
			if (execution != null && SuspensionState.ACTIVE.getStateCode() == executionEntity.getSuspensionState()) {
				runtimeService.setVariable(execution.getId(), "actualFinishDateVar", orderMaxBackCntDate);
				runtimeService.signal(execution.getId());
			}
			// 查询一下是否也处于跟踪备货节点
			execution = runtimeService.createExecutionQuery().processInstanceId(id).activityId("followGoods")
					.singleResult();
			executionEntity = (ExecutionEntity) execution;
			if (execution != null && SuspensionState.ACTIVE.getStateCode() == executionEntity.getSuspensionState()) {
				// 检查一下是否也需要结束这票订单的跟踪备货
				boolean ifNeedCompleteFollowGoods = checkIfNeedCompleteFollowGoods(orderCode);
				if (ifNeedCompleteFollowGoods) {
					runtimeService.setVariable(execution.getId(), "followgoodsActualFinishDateVar", backCntDate);
					runtimeService.signal(execution.getId());// 结束跟踪备货，时间是装箱结束时间
				}
			}
		}
		logger.debug("订单扫描数量获取完毕。");
		return flag;
	}

	//
	@Override
	public Boolean getPackingFrom(ComoUp pars) {
		try {
			List<PackingInfo> pack = pars.getList();
			for (PackingInfo pk : pack) {
				    List<ActCntItem> cntBagCode = this.actCntItemService.getCntBagCode(pk.getCntBagCode());
				    for (ActCntItem actCntItem : cntBagCode) {
				    	//出货数量和扫描数量不相同 
				        if(actCntItem.getBudgetQuantity() != Long.valueOf(pk.getOutAmount())){
				        	// 更改装箱预边数量
							ActCntItem item = new ActCntItem();
							item.setScanQuantity(Long.valueOf(pk.getOutAmount()));
							item.setBackCntDate(pk.getScanTimeEnd());
							item.setLoadingBoxCode(pk.getCntCode());
							item.setActCntItemCode(pk.getCntItemId()); 
							this.actCntItemDao.updActCntItemScan(item);
							List<String> orderCodes = this.actCntItemService.getOrderCodeByLoadingPlan(pk.getCntBagCode());
							for (String orderCode : orderCodes) {
								this.actCntItemDao.updateMainStatus(orderCode);
							}
				        }else if(actCntItem.getBudgetQuantity() == Long.valueOf(pk.getOutAmount())){//出货数量和扫描数量相同
				        	// 更改装箱预边数量
							ActCntItem item = new ActCntItem();
							item.setScanQuantity(Long.valueOf(pk.getOutAmount()));
							item.setBackCntDate(pk.getScanTimeEnd());
							item.setLoadingBoxCode(pk.getCntCode());
							item.setActCntItemCode(pk.getCntItemId()); 
							item.setScanFinishFlag("1");
							this.actCntItemDao.updActCntItemScan(item);
							List<String> orderCodes = this.actCntItemService.getOrderCodeByLoadingPlan(pk.getCntBagCode());
							for (String orderCode : orderCodes) {
								this.actCntItemDao.updateMainStatus(orderCode);
								Map<String, String> map = new HashMap<String, String>();
								map.put("BUSINFORM_ID", orderCode);
								map.put("PROCESSDEFINITION_KEY", "orderTrace");
								WfProcinstance wp = wfProcinstanceDao.findProidByBusid(map);
								String id = wp.getProcessinstanceId();
								Execution execution = runtimeService.createExecutionQuery().processInstanceId(id)
										.activityId("getPackageInfo").singleResult();
								ExecutionEntity executionEntity = (ExecutionEntity) execution;
								Date orderMaxBackCntDate = this.actCntItemDao.getMaxBackCntDateByOrderCode(orderCode);
								// execution 不为空 而且是处于活动状态
								if (execution != null
										&& SuspensionState.ACTIVE.getStateCode() == executionEntity.getSuspensionState()) {
									runtimeService.setVariable(execution.getId(), "actualFinishDateVar", orderMaxBackCntDate);
									runtimeService.signal(execution.getId());
								}
								// 查询一下是否也处于跟踪备货节点
								execution = runtimeService.createExecutionQuery().processInstanceId(id)
										.activityId("followGoods").singleResult();
								executionEntity = (ExecutionEntity) execution;
								if (execution != null
										&& SuspensionState.ACTIVE.getStateCode() == executionEntity.getSuspensionState()) {
									// 检查一下是否也需要结束这票订单的跟踪备货
									boolean ifNeedCompleteFollowGoods = checkIfNeedCompleteFollowGoods(orderCode);
									if (ifNeedCompleteFollowGoods) {
										runtimeService.setVariable(execution.getId(),"followgoodsActualFinishDateVar", pk.getScanTimeEnd());
										runtimeService.signal(execution.getId());// 结束跟踪备货，时间是装箱结束时间
									}
								}
							}
				        }
					}
				 
				
			}
		} catch (Exception e) {

			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 判断订单装箱结束时是否需要自动结束跟踪备货
	 * 
	 * @param orderCode
	 *            订单号
	 * @return
	 */
	private boolean checkIfNeedCompleteFollowGoods(String orderCode) {
		Map<String, SysLov> lovMap = SysLovUtil.getSysLovMap("AUTO_followGoods");// 取出配置表
		SalesOrder salesOrder = salesOrderDao.getById(orderCode);
		String factoryCode = salesOrder.getFactoryCode();
		if (lovMap.get(factoryCode) != null) {// 工厂编码在配置表中
			return true;
		}
		return false;
	}

	@Override
	public Long getTotalNum(ActCntItemQuery query) {
		return actCntItemDao.getTotalNum(query);
	}

	@Override
	public List<ActCntItem> getNoScanOkOrderCode() {
		return this.actCntItemDao.getNoScanOkOrderCode();
	}

	public List<ActCntItem> getCntItemByOrderCode(String orderCode) {
		return actCntItemDao.getCntItemByOrderCode(orderCode);
	}

	public Integer updActCntItemScanQuantity(ActCntItem actCntItem) {
		return this.actCntItemDao.updActCntItemScanQuantity(actCntItem);
	}
	

	public List<String> getLoadingPlanCodeByOrderCode(String orderCode) {
		return this.actCntItemDao.getLoadingPlanCodeByOrderCode(orderCode);
	}

	public List<String> getOrderCodeByLoadingPlanCode(String[] loadingPlanCode) {
		return this.actCntItemDao.getOrderCodeByLoadingPlanCode(loadingPlanCode);
	}
	public List<String> getOrderCodeByLoadingPlan(String loadingPlanCode) {
		return this.actCntItemDao.getOrderCodeByLoadingPlan(loadingPlanCode);
	}
	/**
	 * 根据订单号查询指定数据
	 */
	public List<ActCntItem> getCntBagCode(String orderCode) {
		return actCntItemDao.getCntBagCode(orderCode);
	}


	/**
	 * @author zhangjk
	 * @2013-8-6 @description 根据标准箱方案号、集装箱序号、订单号查询装箱明细所需要的数据
	 * @param query
	 * @return
	 */
	public List<ActCntItemQuery> listActCntItem(ActCntItemQuery query) {
		return this.actCntItemDao.listActCntItem(query);
	}

	@Override
	public void deleteByActcntCode(String actcntCode) {
		actCntItemDao.deleteByActcntCode(actcntCode);
	}

	/**
	 * @Description: 根据主键删除装箱明细
	 * @author 韩建效 hanjianxiao@jbinfo.cn
	 * @date 2016-7-27 下午4:04:35
	 * @param actCntItemCode
	 */
	public void deleteByActcntItemCode(String actCntItemCode) {
		actCntItemDao.deleteByActcntItemCode(actCntItemCode);
	}

	public Integer sendDevanBox(String para) {
		int i = 0;
		String[] paras = para.split(",");
		if (paras.length > 0) {
			for (String loadPlanCode : paras) {
				String hql = "UPDATE WXtidanOUT SET flag = ?, cxflag = ? WHERE cnt_bg_code = ?";
				DbLink dblink = this.dbLinkDao.findDbLinkByActCntCode(loadPlanCode);
				Connection conn = null;
				PreparedStatement pstmt = null;
				try {
					conn = DatabaseFactory.getConnection(dblink);
					pstmt = conn.prepareStatement(hql);
					pstmt.setString(1, "0");
					pstmt.setString(2, "2");
					pstmt.setString(3, loadPlanCode);
					pstmt.execute();
					logger.debug("*****执行成功，更新装箱标示状态******");
					logger.debug("装箱标示发送完毕。。。");
				} catch (Exception e) {
					i = -2;
					logger.error(e);
				} finally {
					if (pstmt != null) {
						try {
							pstmt.close();
						} catch (SQLException e) {
							logger.error(e.getMessage());
						}
					}
					if (conn != null) {
						try {
							conn.close();
						} catch (SQLException e) {
							logger.error(e.getMessage());
						}
					}
				}
			}
		}
		return i;
	}

	public String devnBox(List<ActCntQuery> paras) {
		for (int i = 0; i < paras.size(); i++) {
			Set<String> orderCodeSet = new HashSet<String>();
			List<ActCntItem> listActQuery = this.getByActcntCode(paras.get(i).getLoadingPlanCode()); // 查询订单号
			for (int m = 0; m < listActQuery.size(); m++) {
				SalesOrderQuery sq = new SalesOrderQuery();
				sq.setOrderCode(listActQuery.get(m).getOrderNum());
				List<SalesOrderQuery> listtemp = salesOrderService.listAll(sq);
				if (ValidateUtil.isValid(listtemp)) {
					if (!"2".equals(listtemp.get(0).getOrderAuditFlag())) {
						orderCodeSet.add(listActQuery.get(m).getOrderNum());
					}
				}
			}
			for (String orderCode : orderCodeSet) {
				String processInstanceId = wfProcinstanceService.findProcinstanceId(orderCode, "SO_SALES_ORDER",
						"orderTrace", "1");
				if (ValidateUtil.isValid(processInstanceId)) {
					List<Task> taskList = taskService.createTaskQuery().taskDefinitionKey("packageBudget")
							.processInstanceId(processInstanceId).list();
					if (!ValidateUtil.isValid(taskList)) {
						runtimeService.setVariableLocal(processInstanceId, "devenFlag", 1);
						orderEditService.reDoTask("packageBudget", processInstanceId);
					}
					runtimeService.removeVariableLocal(processInstanceId, "devenFlag");
				}
			}
			// 获取发送邮件地址(根据装箱预编查询邮件地址)
			List<String> listEmail = this.getEmailByActCntCode(paras.get(i).getLoadingPlanCode());
			List<ActCntItemQuery> list = findActCntItem(paras.get(i).getLoadingPlanCode());
			List<Recipient> toRecipients = new ArrayList<Recipient>();
			for (String sendEmaul : listEmail) {
				Recipient toRecipient = new Recipient(sendEmaul, " 	装箱经理");
				toRecipients.add(toRecipient);
			}
			ActCntItemQuery aq = new ActCntItemQuery();
			aq.setActCntCode(paras.get(i).getLoadingPlanCode());
			List<ActCntItemQuery> listActCntItemQuery = this.listAll(aq);
			String orderCodeList = "";
			if (ValidateUtil.isValid(listActCntItemQuery)) {
				for (int j = 0; j < listActCntItemQuery.size(); j++) {
					SalesOrderQuery sqq = new SalesOrderQuery();
					sqq.setOrderCode(listActCntItemQuery.get(j).getOrderNum());
					List<SalesOrderQuery> listSalesOrderQuery = salesOrderService.listAll(sqq);
					String facCode = "";
					if (ValidateUtil.isValid(listSalesOrderQuery)) {
						facCode = listSalesOrderQuery.get(0).getFactoryCode();
					}
					orderCodeList = "订单号 ： " + listActCntItemQuery.get(j).getOrderNum() + ",生产工厂编码:  " + facCode + "。";
				}
			}
			// 工厂装箱经理发送邮件
			Email email = new Email();
			StringBuffer bodyContent = new StringBuffer();
			bodyContent.append("<html> <head></head> <body>你好 : <br/>")
					.append("<table style='border-collapse:collapse;border:1px solid #ccc;'>")
					.append("<tr style='border-collapse:collapse;border:1px solid #ccc;'>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>装箱预编号</th>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>订单号</th>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>生产工厂</th>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>订单经理</th>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>国家</th>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>海尔型号</th>")
					.append("<th style='border-collapse:collapse;border:1px solid #ccc;'>本箱数量</th>").append("</tr>");
			for (int r = 0; r < list.size(); r++) {
				bodyContent.append("<tr style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((paras.get(i).getLoadingPlanCode() == null ? "" : paras.get(i).getLoadingPlanCode()))
						.append("</td>").append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((paras.get(i).getBelongOrder() == null ? "" : paras.get(i).getBelongOrder()))
						.append("</td>").append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((paras.get(i).getFactoryName() == null ? "" : paras.get(i).getFactoryName()))
						.append("</td>").append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((paras.get(i).getOrderExecManager() == null ? "" : paras.get(i).getOrderExecManager()))
						.append("</td>").append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((paras.get(i).getCountryName() == null ? "" : paras.get(i).getCountryName()))
						.append("</td>").append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((list.get(r).getHaierModel() == null ? "" : list.get(r).getHaierModel()))
						.append("</td>").append("<td style='border-collapse:collapse;border:1px solid #ccc;'>")
						.append((list.get(r).getBudgetQuantity() == null ? "" : list.get(r).getBudgetQuantity()))
						.append("</td>").append("</tr>");
			}
			bodyContent.append("</table>").append(",已经拆箱,请查看！关联订单号信息 --- ").append(orderCodeList);
			bodyContent.append("</body></html>");
			email.setToRecipient(toRecipients);
			email.setSender(new Recipient("hrois@haier.com", "hrois系统"));
			email.setBodyContent(bodyContent.toString(), true);
			email.setSubject("HROIS装箱预算发生变化");
			email.setSystem("HROIS");
			sendEmailServiceClient.sendEmail(email);
			// 删除数据
			this.deleteByActcntCode(paras.get(i).getLoadingPlanCode());
			actCntDao.deleteById(paras.get(i).getLoadingPlanCode());
		}
		return null;
	}

	/* (非 Javadoc)
	 * 
	 * 
	 * @param paras
	 * @see com.haier.hrois.order.cnt.service.ActCntItemService#devnBoxReturn(java.util.List)
	*/
	@Override
	public String devnBoxReturn(Map<String,String> paras) {
		for(String s:paras.keySet()){
			//退货装箱前copy数据到return表
			this.copyDeleteData(s);
		}
		return null;
	}
	
	/** 
	 * @Title: copyDeleteData
	 * @Description: 装箱退货在删除数据前copy数据到return表
	 * @param actCntCode 
	 * @date 2018年11月21日
	*/
	private void copyDeleteData(String actCntCode) {
		actCntItemDao.copyCntItemToReturn(actCntCode);
		actCntDao.copyCntToReturn(actCntCode);
	}

	/* (非 Javadoc)
	 * 
	 * 
	 * @param cntCode
	 * @return
	 * @see com.haier.hrois.order.cnt.service.ActCntItemService#getReturnByCntCode(java.lang.String)
	*/
	@Override
	public boolean getReturnByPlanCode(String planCode) {
		ActCnt ac = actCntDao.getReturnByPlanCode(planCode);
		if(ac!=null){
			return true;
		}
		return false;
	}
	
	@Override
	public List<ActCntItem> getByActcntCode(String actCntCode) {
		return actCntItemDao.getByActcntCode(actCntCode);
	}

	@Override
	public List<String> getTaskDefKeyList(String orderCode) {
		return actCntItemDao.getTaskDefKeyList(orderCode);
	}

	@Override
	public List<String> getProcessIdByOrderCode(String orderCode) {
		return actCntItemDao.getProcessIdByOrderCode(orderCode);
	}

	@Override
	public List<String> getEmailByActCntCode(String code) {
		return actCntItemDao.getEmailByActCntCode(code);
	}

	@Override
	public long getSumNumberByOrderCode(ActCntItemQuery actCntItemQuery) {
		return actCntItemDao.getSumNumberByOrderCode(actCntItemQuery);
	}

	public List<String> getMaterialByLoadingPlanCode(String loadingPlanCode) {
		return actCntItemDao.getMaterialByLoadingPlanCode(loadingPlanCode);
	}

	public String[] getStr() {
		return str;
	}

	public void setStr(String[] str) {
		this.str = str;
	}
	
	/**
	 * HROIS传出运产生的inbound信息，更新集装箱号 Z_HROIS_UPDATE_INBOUND
	 * @param orderCode
	 */
	@Override
	public JSONObject updateLoadingBoxCode(String orderCode,String empCode,String actCntCode) {
		
		logger.info(orderCode+"-箱封号信息更新到SAP。。。");
		//根据订单号获取actcntItem
		Map<String,String> actItemMap = new HashMap<String,String>();
		actItemMap.put("orderCode", orderCode);
		actItemMap.put("actCntCode",actCntCode);
		List<ActCntItem> items = actCntItemDao.getCntItemByOrderCodeAndLoadCode(actItemMap);
		StringBuffer msg = new StringBuffer(orderCode+"错误信息：");
		JSONObject rtnJsonRst= hopeInterfaceService.pushInboundContainerNoToHope(orderCode,items);
		//S,更新主表根据订单号SAPFLAG
		if("S".equals(rtnJsonRst.getString("flag"))){
			//更新LCODE_SAPFLAG=1到主表
			Map<String,String> actCntMap = new HashMap<String,String>();
			actCntMap.put("orderCode", orderCode);
			actCntMap.put("empCode", empCode);
			actCntMap.put("actCntCode",actCntCode);
			this.actCntItemDao.updateMainSAPFLAGByOrderCode(actCntMap);
		}
		return rtnJsonRst;
		
	}
	
	/**
	 * 新增发送邮件
	 * 新增inbound接口
	 */
	@Override
	public Boolean getPackingFromFactory2(String orderCode) {
		boolean flag = true;
		Date backCntDate = null;
		String query = "select * from WXtidanOUT where cnt_item_id = ?";
		List<ActCntItem> items = this.actCntItemDao.getCntItemByOrderCode(orderCode);
		
		//20200311已完成出运的订单，先根据ORDER_CODE和老的OLD_CONTAINERNO在HOPE获取IN_BOUND
		Integer chuYunCount = this.actCntItemDao.getIsChuYunOrder(orderCode);
		boolean isChuYunOrder = false;
		if(chuYunCount>0){
			isChuYunOrder = true;
		}
		//----20200311
		DbLink dl = this.dbLinkDao.findDbLinkByOrderCode(orderCode);
		logger.debug("通过订单那获取数据库连接：" + JSONObject.fromObject(dl));
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = DatabaseFactory.getConnection(dl);
			pstmt = conn.prepareStatement(query);
			//箱封号
			HashMap<String,String> cntMap = new HashMap<String,String>(); 
			for (ActCntItem item : items) {
				//出运订单
				if(isChuYunOrder){
					//执行HOPE获取IN_BOUND方法
					Map<String,String> rtnResult =hopeInterfaceService.createInboundContainerNoFromHope(item);
					if("S".equals(rtnResult.get("flag"))){
						item.setInBound(rtnResult.get("inbound"));
					}else{
						logger.error(rtnResult.get("message"));
					}
				}
				pstmt.setString(1, item.getActCntItemCode());
				rs = pstmt.executeQuery();
				if (rs.next()) {
					String aciid = rs.getString("cnt_item_id");
					Long scanQuantity = rs.getLong("fh_lfimg");
					String loadingBoxCode = rs.getString("cnt_code");
					//箱封号
					if(StringUtils.isNotBlank(item.getInBound())&&item.getLoadingBoxCode()!=null && !(item.getLoadingBoxCode().equals(loadingBoxCode))){
						cntMap.put(item.getLoadingBoxCode(),item.getActCntItemCode());
						item.setIsChanged("isChanged");
					}
					if (rs.getString("endtime") != null) {
						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						backCntDate = sdf.parse(rs.getString("endtime"));
					}
					item.setScanQuantity(scanQuantity);
					item.setBackCntDate(backCntDate);
					item.setLoadingBoxCode(loadingBoxCode);
					if (item.getBudgetQuantity().compareTo(scanQuantity) == 0) {
						item.setScanFinishFlag("1");
					} else {
						flag = false;
					}
					this.actCntItemDao.updActCntItemScanQuantity(item);
					logger.debug("更新本地扫描数量 " + aciid + " --> " + scanQuantity);
				} else {
					flag = false;
				}
			}
			
			this.actCntItemDao.updateMainStatus(orderCode);
			//更新ACT_CNT的LCODE_SAPFLAG 为2
			this.actCntItemDao.updateMainStatusWithSapFlag(orderCode);
			
			//箱封号变动发送邮件
			if(cntMap.size()>0){
				
				List<Map<String,String>> allContent = new ArrayList<Map<String,String>>();
				for(Map.Entry<String,String> item : cntMap.entrySet()){
					String oldCntNum = item.getKey();
					String actCntItemsCode = item.getValue();
					Map<String,String> itemMap = actCntItemDao.getEmailContent(actCntItemsCode);
					itemMap.put("OLD_LOADING_BOX_CODE", oldCntNum);
					allContent.add(itemMap);
				}
				
			    //发送提醒邮件
			    mailSender.setPort(25);	 
			    mailSender.setProtocol("smtp");
			    List<InternetAddress> toAddressList = new ArrayList<InternetAddress>();
			    MimeMessage mimeMessage = mailSender.createMimeMessage();
				MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true,"UTF-8");
				//发送人
				String fromName = "HroisAdmin";
				String fromAddress = "hrois@haier.net";
				helper.setFrom(new InternetAddress(fromAddress,fromName));
				//收件人
				String prodEmail = allContent.get(0).get("PROD_EMAIL");
				String prodName = allContent.get(0).get("PROD_NAME");
				String execEmail = allContent.get(0).get("EXEC_EMAIL");
				String execName = allContent.get(0).get("EXEC_NAME");
				String transEmail = allContent.get(0).get("TRANS_EMAIL");
				String transName = allContent.get(0).get("TRANS_NAME");
				
				if(StringUtils.isNotBlank(prodEmail)){
					InternetAddress prodEmailAddress = new InternetAddress(prodEmail,prodName);
					toAddressList.add(prodEmailAddress);
				}
				if(StringUtils.isNotBlank(execEmail)){
					InternetAddress execEmailAddress = new InternetAddress(execEmail,execName);
					toAddressList.add(execEmailAddress);
				}
				if(StringUtils.isNotBlank(transEmail)){
					
					String transEmails[] = transEmail.split(",");
					String transNames[] = transName.split(",");
					int emailCount = 0;
					for(String tEmail: transEmails){
						InternetAddress transEmailAddress = new InternetAddress(tEmail,transNames[emailCount]);
						toAddressList.add(transEmailAddress);
						emailCount++;
					}
				}
				helper.setTo(toAddressList.toArray(new InternetAddress[toAddressList.size()]));
				
				//主题
				String title ="Hrois展示箱封号更改记录：";
			    helper.setSubject(title);
			    //构建内容
				Map<String, Object> parameters = new HashMap<String, Object>();
			    parameters.put("appName", Env.getProperty(Env.APP_NAME.isEmpty()
					  || Env.APP_NAME == null ? "" : Env.APP_NAME));
			    parameters.put("title", title);
			    parameters.put("cntItemList", allContent);
	            Template template = freemarkerConfig.getConfiguration().getTemplate("email_containerNum_update.ftl");
			    String contentText = FreeMarkerTemplateUtils.processTemplateIntoString(template,parameters);
	            helper.setText(contentText,true);
	            mailSender.send(mimeMessage);
		       //发送完毕
				
			}
		} catch (Exception e) {
			e.printStackTrace();
			flag = false;
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (conn != null) {
					conn.close();
				}
				if (pstmt != null) {
					pstmt.close();
				}
			} catch (SQLException e) {
				logger.error("excute sql got exception:", e);
			}
		}
		
		if (flag) {
			Map<String, String> map = new HashMap<String, String>();
			map.put("BUSINFORM_ID", orderCode);
			map.put("PROCESSDEFINITION_KEY", "orderTrace");
			WfProcinstance wp = wfProcinstanceDao.findProidByBusid(map);
			String id = wp.getProcessinstanceId();
			Execution execution = runtimeService.createExecutionQuery().processInstanceId(id)
					.activityId("getPackageInfo").singleResult();
			ExecutionEntity executionEntity = (ExecutionEntity) execution;
			Date orderMaxBackCntDate = this.actCntItemDao.getMaxBackCntDateByOrderCode(orderCode);
			// execution 不为空 而且是处于活动状态
			if (execution != null && SuspensionState.ACTIVE.getStateCode() == executionEntity.getSuspensionState()) {
				runtimeService.setVariable(execution.getId(), "actualFinishDateVar", orderMaxBackCntDate);
				runtimeService.signal(execution.getId());
			}
			// 查询一下是否也处于跟踪备货节点
			execution = runtimeService.createExecutionQuery().processInstanceId(id).activityId("followGoods")
					.singleResult();
			executionEntity = (ExecutionEntity) execution;
			if (execution != null && SuspensionState.ACTIVE.getStateCode() == executionEntity.getSuspensionState()) {
				// 检查一下是否也需要结束这票订单的跟踪备货
				boolean ifNeedCompleteFollowGoods = checkIfNeedCompleteFollowGoods(orderCode);
				if (ifNeedCompleteFollowGoods) {
					runtimeService.setVariable(execution.getId(), "followgoodsActualFinishDateVar", backCntDate);
					runtimeService.signal(execution.getId());// 结束跟踪备货，时间是装箱结束时间
				}
			}
		}
		
		logger.debug("订单扫描数量获取完毕。");
		return flag;
	}
	
	
	
	/**
	 * 备件订单随整机装箱扫描发货
	 * 更新整机装箱信息，关联备件订单
	 * 2020-03-24  YXB
	 * @param actCntItemQuery
	 */
	@Override
	public void updateAttachOrder(ActCntItemQuery actCntItemQuery){
		this.actCntItemDao.updateAttachOrder(actCntItemQuery);
	}
	
	/**
	 * 备件订单随整机装箱扫描发货
	 * 根据备件订单号查询关联装箱的并且已经发送工厂的整机订单号
	 * 2020-03-24  YXB
	 * @param actCntItemQuery
	 */
	@Override
	public List<String> selectOrderLoadingStatus(String attachOrder){
		return actCntItemDao.selectOrderLoadingStatus(attachOrder);
	}
	
	
	/**
	 * 备件订单随整机装箱扫描发货
	 * 2020-03-24
	 * 清除之前关联的整机订单装箱信息，更新WMS装箱预算信息
	 * @param attachOrder
	 */
	@Override
	public void dealLoadingAttachOrder(String attachOrder){
		//查询关联装箱的并且已经发送工厂的整机订单号，更新WMS数据
		List<String> orderCodes = this.selectOrderLoadingStatus(attachOrder);
		if(orderCodes != null && orderCodes.size() > 0){
			for(String orderCode : orderCodes){
				this.actCntItemService.sendPackingFactory(orderCode);
			}
		}
		//删除备件订单与整机订单装箱信息关联关系
		actCntItemDao.deleteLoadingAttachOrder(attachOrder);
	}
	
	
	
	
}
