/* Powered By [rapid-framework] Web Site: http://www.rapid-framework.org.cn
 * Google Code: http://code.google.com/p/rapid-framework/ Since 2008 - 2013 */
package com.haier.hrois.order.bookcabin.service.impl;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.activiti.engine.RuntimeService;
import org.activiti.engine.TaskService;
import org.activiti.engine.impl.ServiceImpl;
import org.activiti.engine.impl.persistence.entity.SuspensionState;
import org.activiti.engine.task.Task;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.ui.freemarker.FreeMarkerTemplateUtils;
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer;

import com.alibaba.dubbo.common.utils.CollectionUtils;
import com.haier.base.model.DataGrid;
import com.haier.base.model.HroisLoginContext;
import com.haier.base.model.Json;
import com.haier.hrois.I18n.HroisException;
import com.haier.hrois.activiti.dao.WfProcinstanceDao;
import com.haier.hrois.activiti.query.HroisHistoricTaskInstanceQueryImpl;
import com.haier.hrois.activiti.query.HroisTaskQueryImpl;
import com.haier.hrois.activiti.service.ActivitiService;
import com.haier.hrois.activiti.service.WfProcinstanceService;
import com.haier.hrois.activiti.service.impl.ChangeProcessInstanceStateCmd;
import com.haier.hrois.basic.domain.Port;
import com.haier.hrois.basic.domain.SysLov;
import com.haier.hrois.basic.service.PortService;
import com.haier.hrois.basic.service.SysLovService;
import com.haier.hrois.bid.query.BidQuery;
import com.haier.hrois.credit.domain.Tproduct;
import com.haier.hrois.credit.query.TproductQuery;
import com.haier.hrois.datatrans.service.EdiSendMsgService;
import com.haier.hrois.datatrans.service.impl.HopeInterfaceService;
import com.haier.hrois.fee.query.ActImportFeeQuery;
import com.haier.hrois.fee.service.ActImportFeeService;
import com.haier.hrois.order.bookcabin.dao.BookOrderCntDao;
import com.haier.hrois.order.bookcabin.dao.BookOrderDao;
import com.haier.hrois.order.bookcabin.dao.BookOrderItemDao;
import com.haier.hrois.order.bookcabin.dao.BookPortUpdateLogDao;
import com.haier.hrois.order.bookcabin.dao.BookShippingUpdateLogDao;
import com.haier.hrois.order.bookcabin.dao.ShipPaperDao;
import com.haier.hrois.order.bookcabin.domain.BookOrder;
import com.haier.hrois.order.bookcabin.domain.BookOrderCnt;
import com.haier.hrois.order.bookcabin.domain.BookOrderItem;
import com.haier.hrois.order.bookcabin.domain.BookPortUpdateLog;
import com.haier.hrois.order.bookcabin.domain.BookShippingUpdateLog;
import com.haier.hrois.order.bookcabin.domain.ShipPaper;
import com.haier.hrois.order.bookcabin.query.BookOrderItemQuery;
import com.haier.hrois.order.bookcabin.query.BookOrderQuery;
import com.haier.hrois.order.bookcabin.query.ShipPaperItemQuery;
import com.haier.hrois.order.bookcabin.query.ShipPaperQuery;
import com.haier.hrois.order.bookcabin.service.BookOrderService;
import com.haier.hrois.order.bookcabin.service.ShipPaperItemService;
import com.haier.hrois.order.bookcabin.service.ShipPaperService;
import com.haier.hrois.order.cnt.dao.ActCntDao;
import com.haier.hrois.order.cnt.domain.ActCnt;
import com.haier.hrois.order.cnt.query.ActCntItemQuery;
import com.haier.hrois.order.cnt.query.ActCntQuery;
import com.haier.hrois.order.cnt.service.ActCntItemService;
import com.haier.hrois.order.cnt.service.ActCntService;
import com.haier.hrois.order.confirm.domain.SalesOrder;
import com.haier.hrois.order.confirm.query.SalesOrderItemQuery;
import com.haier.hrois.order.confirm.query.SalesOrderQuery;
import com.haier.hrois.order.confirm.service.SalesOrderItemService;
import com.haier.hrois.order.confirm.service.SalesOrderService;
import com.haier.hrois.order.edit.behavior.UpdateAssgineeService;
import com.haier.hrois.order.edit.service.OrderEditService;
import com.haier.hrois.order.ordemerge.domain.OrderMerge;
import com.haier.hrois.order.ordermerge.dao.OrderMergeDao;
import com.haier.hrois.order.tmod.dao.ActDao;
import com.haier.hrois.security.domain.User;
import com.haier.hrois.security.service.UserService;
import com.haier.hrois.util.CopySpecialProperties;
import com.haier.hrois.util.Env;
import com.haier.hrois.util.GenerateTableSeqUtil;
import com.haier.hrois.util.MyBatisSqlUtils;
import com.haier.hrois.util.ValidateUtil;
import com.haier.openplatform.console.info.spi.SendEmailServiceClient;
import com.haier.openplatform.hmc.domain.Email;
import com.haier.openplatform.hmc.domain.Recipient;
import com.haier.openplatform.security.LoginContextHolder;
import com.haier.openplatform.util.Pager;
import com.haier.openplatform.util.SpringApplicationContextHolder;

import freemarker.core.ParseException;
import freemarker.template.MalformedTemplateNameException;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateNotFoundException;
@Service("bookOrderService")
public class BookOrderServiceImpl implements BookOrderService, UpdateAssgineeService {
	@Resource
	private BookOrderDao bookOrderDao;
	@Resource
	private BookOrderItemDao bookOrderItemDao;
	@Resource
	private SalesOrderService salesOrderService;
	@Resource
	private SysLovService sysLovService;
	@Resource
	private TaskService taskService;
	@Resource
	private WfProcinstanceDao wfProcinstanceDao;
	@Resource
	private ActDao actDao;
	@Resource
	private BookOrderCntDao bookOrderCntDao;
	@Resource
	private SalesOrderItemService salesOrderItemService;
	@Resource
	private ActivitiService activitiService;
	@Resource
	private WfProcinstanceService wfProcinstanceService;
	@Resource
	private RuntimeService runtimeService;
	@Resource
	private OrderEditService orderEditService;
	@Resource
	private SendEmailServiceClient sendEmailServiceClient;
	@Autowired
    public JavaMailSenderImpl mailSender;
	@Autowired
    private FreeMarkerConfigurer freemarkerConfig;
	@Resource
	private UserService userService;
	@Resource
	private OrderMergeDao orderMergeDao;
	@Resource
	private ActImportFeeService actImportFeeService;
	@Resource
	private ShipPaperDao shipPaperDao;
	@Resource
	private ShipPaperService shipPaperService;
	@Resource
	private ShipPaperItemService shipPaperItemService;
	@Resource
	private ActCntService actCntService;
	@Resource
	private ActCntItemService actCntItemService;
	@Resource
	private ActCntDao actCntDao;
	@Resource
	private PortService portService;
	@Resource
	private EdiSendMsgService ediSendMsgService;
	@Resource
	private HopeInterfaceService hopeInterfaceService;
	@Resource
	private BookShippingUpdateLogDao bookShippingUpdateLogDao;
	@Resource
	private BookPortUpdateLogDao bookPortUpdateLogDao;
	
	
	public void setBookOrderDao(BookOrderDao dao) {
		this.bookOrderDao = dao;
	}
	public DataGrid datagrid(BookOrderQuery bookOrderQuery) {
		HroisTaskQueryImpl hroisTaskQueryImpl = new HroisTaskQueryImpl();
		hroisTaskQueryImpl.taskAssigneeCurrUser();
		hroisTaskQueryImpl.taskDefinitionKey(bookOrderQuery.getDefinitionKey());
		String subSql = MyBatisSqlUtils.getMyBatisSql("BookOrder.cabinTask.sql", bookOrderQuery).toString();
		hroisTaskQueryImpl.setIdColm("ORDER_CODE");
		hroisTaskQueryImpl.setReturnColum("DISTINCT BOOK_CODE,FORMTABLE.CREATED");
		hroisTaskQueryImpl.setSubSql(subSql);
		hroisTaskQueryImpl.setSort("CREATED");
		hroisTaskQueryImpl.setOrder("DESC");
		Pager<BookOrder> p = bookOrderQuery.getPager();
		int currentPager = p.getCurrentPage().intValue();
		int pagerSize = p.getPageSize().intValue();
		hroisTaskQueryImpl.setFirstResult((currentPager - 1) * pagerSize);
		hroisTaskQueryImpl.setMaxResults(pagerSize);
		hroisTaskQueryImpl.setSeqCol("BOOK_CODE");
		Pager<Map> pager = wfProcinstanceDao.queryPageByHroisTask(hroisTaskQueryImpl);
		List<String> codes = new ArrayList<String>();
		for (Map record : pager.getRecords()) {
			codes.add(String.valueOf(record.get("bookCode")));
		}
		DataGrid j = new DataGrid();
		//列表信息查询
		List<BookOrderQuery> listQuery = this.bookOrderDao.findCabinList(codes);
		int shuliang = listQuery.size();
		BigDecimal bg = new BigDecimal(shuliang);
		j.setRows(listQuery);
		j.setTotal(bg.longValue());
		return j;
	}
	public DataGrid datagridHis(BookOrderQuery bookOrderQuery) {
		HroisHistoricTaskInstanceQueryImpl hroisTaskQueryImpl = new HroisHistoricTaskInstanceQueryImpl();
		hroisTaskQueryImpl.taskAssigneeCurrUser();
		hroisTaskQueryImpl.taskDefinitionKey(bookOrderQuery.getDefinitionKey()).finished();
		String subSql = MyBatisSqlUtils.getMyBatisSql("BookOrder.cabinTask.sql", bookOrderQuery).toString();
		hroisTaskQueryImpl.setIdColm("ORDER_CODE");
		hroisTaskQueryImpl.setReturnColum("DISTINCT FORMTABLE.BOOK_CODE,FORMTABLE.CREATED");
		hroisTaskQueryImpl.setSubSql(subSql);
		hroisTaskQueryImpl.setSort("CREATED");
		hroisTaskQueryImpl.setOrder("DESC");
		Pager<BookOrder> p = bookOrderQuery.getPager();
		int currentPager = p.getCurrentPage().intValue();
		int pagerSize = p.getPageSize().intValue();
		hroisTaskQueryImpl.setFirstResult((currentPager - 1) * pagerSize);
		hroisTaskQueryImpl.setMaxResults(pagerSize);
		hroisTaskQueryImpl.setSeqCol("BOOK_CODE");
		Pager<Map> pager = wfProcinstanceDao.queryPageByHroisTask(hroisTaskQueryImpl);
		List<String> codes = new ArrayList<String>();
		for (Map record : pager.getRecords()) {
			codes.add(String.valueOf(record.get("bookCode")));
		}
		DataGrid j = new DataGrid();
		j.setRows(this.bookOrderDao.findCabinList(codes));
		j.setTotal(pager.getTotalRecords());
		return j;
	}
	
	/**
	 * FOB货代入货通知单
	 * 2020-01-07  YXB
	 */
	public DataGrid datagridFobNoticeTask(BookOrderQuery bookOrderQuery) {
		HroisHistoricTaskInstanceQueryImpl hroisTaskQueryImpl = new HroisHistoricTaskInstanceQueryImpl();
		hroisTaskQueryImpl.taskAssigneeCurrUser();
		hroisTaskQueryImpl.taskDefinitionKey(bookOrderQuery.getDefinitionKey()).finished();
		String subSql = MyBatisSqlUtils.getMyBatisSql("BookOrder.cabinTask.sql", bookOrderQuery).toString();
		hroisTaskQueryImpl.setIdColm("ORDER_CODE");
		hroisTaskQueryImpl.setReturnColum("DISTINCT FORMTABLE.BOOK_CODE,FORMTABLE.CREATED");
		hroisTaskQueryImpl.setSubSql(subSql);
		hroisTaskQueryImpl.setSort("CREATED");
		hroisTaskQueryImpl.setOrder("DESC");
		Pager<BookOrder> p = bookOrderQuery.getPager();
		int currentPager = p.getCurrentPage().intValue();
		int pagerSize = p.getPageSize().intValue();
		hroisTaskQueryImpl.setFirstResult((currentPager - 1) * pagerSize);
		hroisTaskQueryImpl.setMaxResults(pagerSize);
		hroisTaskQueryImpl.setSeqCol("BOOK_CODE");
		Pager<Map> pager = wfProcinstanceDao.queryPageByHroisTask(hroisTaskQueryImpl);
		List<String> codes = new ArrayList<String>();
		for (Map record : pager.getRecords()) {
			codes.add(String.valueOf(record.get("bookCode")));
		}
		DataGrid j = new DataGrid();
		//列表信息查询
		List<BookOrderQuery> listQuery = this.bookOrderDao.findFobNoticeList(codes);
		int shuliang = listQuery.size();
		BigDecimal bg = new BigDecimal(shuliang);
		j.setRows(listQuery);
		j.setTotal(bg.longValue());
		return j;
	}
	
	
	public DataGrid datagridRedoTask(BookOrderQuery bookOrderQuery) {
		UserService uService = SpringApplicationContextHolder.getBean("userService");
		User user = uService.getUserById(LoginContextHolder.get().getUserId());
		bookOrderQuery.setOrderExecManager(user.getEmpCode());
		Pager<BookOrder> pager = this.bookOrderDao.findCabinRedoPage(bookOrderQuery);
		List<String> codes = new ArrayList<String>();
		for (BookOrder bo : pager.getRecords()) {
			codes.add(bo.getBookCode());
		}
		DataGrid j = new DataGrid();
		j.setRows(this.bookOrderDao.findCabinList(codes));
		j.setTotal(pager.getTotalRecords());
		return j;
	}
	public BookOrder get(String id) { return bookOrderDao.getById(id); }
	@Override
	public BookOrderQuery initCabinByOrder(String[] codes) throws Exception {
		String bookCode = GenerateTableSeqUtil.generateTableSeq("ACT_BOOK_ORDER");
		BookOrderQuery bookOrderQuery = new BookOrderQuery();
		SalesOrderQuery salesOrderQuery = this.salesOrderService.getSalesOrderDetialByCode(codes[0]);
		bookOrderQuery.setBookCode(bookCode);//
		bookOrderQuery.setBookReceiveMan(salesOrderQuery.getOrderShipToName());//
		bookOrderQuery.setBookNotifyMan(salesOrderQuery.getCustName());//
		bookOrderQuery.setBookShipDate(salesOrderQuery.getOrderShipDate());//
		bookOrderQuery.setOrderType(salesOrderQuery.getOrderType());
		//bookOrderQuery.setDuck(salesOrderQuery.getDuck());
		CopySpecialProperties.copyBeanToBean(salesOrderQuery, bookOrderQuery);
		HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
		String empName = loginContext.getUserName();
		Date custDate = this.salesOrderService.getMinCustDate(codes);
		List<SalesOrderItemQuery> sois = this.salesOrderItemService.getSalesOrderItemDetial(codes);
		List<BookOrderCnt> bocs = this.bookOrderCntDao.findFromView(codes);//通过订单查询实际箱型箱量
		for (BookOrderCnt boc : bocs) { //初始化ACT_BOOK_ORDER_CNT表
			boc.setRowId(GenerateTableSeqUtil.generateTableSeq("ACT_BOOK_ORDER_CNT"));
			boc.setBookCode(bookCode);
			this.bookOrderCntDao.saveOrUpdate(boc);
		}
		String plan = "", act = "";
		if ("01".equals(salesOrderQuery.getOrderShipment()) || "03".equals(salesOrderQuery.getOrderShipment())) {
			plan = this.salesOrderService.getPlanContainer(codes);//查询订单预算箱型箱量
			act = this.bookOrderCntDao.findContainerByBookCode(bookCode);  //从ACT_BOOK_ORDER_CNT表抓取订舱箱型箱量信息
		} else if ("02".equals(salesOrderQuery.getOrderShipment())) {
			plan = this.salesOrderService.getPlanFee(codes);
			act = this.bookOrderCntDao.findActFeeByBookCode(bookCode);
		}
		bookOrderQuery.setContainer(plan);
		bookOrderQuery.setCntContainer(act);
		bookOrderQuery.setCreatedBy(empName);
		bookOrderQuery.setOrderCustomDate(custDate);
		bookOrderQuery.setOperators(sois != null && sois.size() > 0?sois.get(0).getOrderOperatorsName():""); //首先获取so_sales_order_item表的经营主体，否则取CD_DEPARTMENT表数据
		SysLov sysLov = this.sysLovService.getByItemCode("BUSINESS_SENDMAN_RELATIONSHIP", sois != null && sois.size() > 0?sois.get(0).getOrderOperatorsCode():""); //获取经营主体与发货人的关系
		bookOrderQuery.setBookSendMan(sysLov != null?sysLov.getItemNameEn():"");
		List<String> list = Arrays.asList(codes);
		bookOrderQuery.setFareDealType(this.salesOrderService.hasFareDealType(list));
		/**
		 * 订舱判断船公司是否可以进行修改
		 * 订舱申请、订舱修改、货代分配
		 * 2020-04-26  YXB
		 */
		bookOrderQuery.setBookShippingUpdateJudge(this.salesOrderService.bookShippingUpdateJudge(list));
		return bookOrderQuery;
	}
	public BookOrderQuery initCabinByOrderCom(String[] codes) throws Exception {
		String bookCode = GenerateTableSeqUtil.generateTableSeq("ACT_BOOK_ORDER");
		BookOrderQuery bookOrderQuery = new BookOrderQuery();
		ActImportFeeQuery actImportFeeQuery = new ActImportFeeQuery();
		actImportFeeQuery.setOrderCode(codes[0]);
		ActImportFeeQuery feeQuery = actImportFeeService.getOemBookDetail(actImportFeeQuery);
		bookOrderQuery.setOrderPoCode(feeQuery.getOrderPoCode());
		CopySpecialProperties.copyBeanToBean(feeQuery, bookOrderQuery);
		SalesOrderQuery salesOrderQuery = this.salesOrderService.getSalesOrderDetialByCode(codes[0]);
		bookOrderQuery.setBookCode(bookCode);//
		bookOrderQuery.setOrderType(salesOrderQuery.getOrderType());
		CopySpecialProperties.copyBeanToBean(salesOrderQuery, bookOrderQuery);
		bookOrderQuery.setBookShipDate(salesOrderQuery.getOrderShipDate());
		HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
		String empName = loginContext.getUserName();
		bookOrderQuery.setCreatedBy(empName);
		List<String> list = Arrays.asList(codes);
		bookOrderQuery.setFareDealType(this.salesOrderService.hasFareDealType(list));
		return bookOrderQuery;
	}
	@Override
	public BookOrderQuery getBookOrderDetail(String bookCode) throws Exception {
		BookOrderQuery bookOrderQuery = new BookOrderQuery();
		BookOrder bookOrder = this.bookOrderDao.getBookOrderDetail(bookCode);
		if (bookOrder == null) {
			return bookOrderQuery;
		}
		CopySpecialProperties.copyBeanToBean(bookOrder, bookOrderQuery);
		List<String> codes = this.bookOrderItemDao.findOrderCodeByBookCode(new String[] { bookOrder.getBookCode() });
		String[] tmp = codes.toArray(new String[codes.size()]);
		Set<String> orderCodes = new HashSet<String>(Arrays.asList(tmp));
		SalesOrderQuery query = this.salesOrderService.getSalesOrderDetialByCode(codes.get(0));
		CopySpecialProperties.copyBeanToBean(query, bookOrderQuery);
		bookOrderQuery.setOrderType(query.getOrderType());
		bookOrderQuery.setCreatedBy(bookOrder.getCreatedBy());
		Date custDate = this.salesOrderService.getMinCustDate(tmp);
		List<SalesOrderItemQuery> sois = this.salesOrderItemService.getSalesOrderItemDetial(tmp);
		String plan = "", act = "";
		if ("01".equals(bookOrderQuery.getOrderShipment()) || "03".equals(bookOrderQuery.getOrderShipment())) {
			plan = this.salesOrderService.getPlanContainer(tmp);//查询订单预算箱型箱量
			act = this.bookOrderCntDao.findContainerByBookCode(bookCode);  //从ACT_BOOK_ORDER_CNT表抓取订舱箱型箱量信息
		} else if ("02".equals(bookOrderQuery.getOrderShipment())) {
			plan = this.salesOrderService.getPlanFee(tmp);
			act = this.bookOrderCntDao.findActFeeByBookCode(bookCode);
		}
		bookOrderQuery.setContainer(plan);
		bookOrderQuery.setCntContainer(act);
		bookOrderQuery.setOrderCodes(orderCodes);
		bookOrderQuery.setOrderCustomDate(custDate);
		bookOrderQuery.setOperators(sois != null && sois.size() > 0?sois.get(0).getOrderOperatorsName():"");  //首先获取so_sales_order_item表的经营主体，否则取CD_DEPARTMENT表数据
		bookOrderQuery.setOrderCodes(orderCodes);
		bookOrderQuery.setFareDealType(this.salesOrderService.hasFareDealType(codes));
		/**
		 * 订舱判断船公司是否可以进行修改
		 * 订舱申请、订舱修改、货代分配
		 * 订舱分配船公司显示订舱中选择的船公司
		 * 2020-04-26  YXB
		 */
		bookOrderQuery.setVendorCode(bookOrder.getVendorCode());
		bookOrderQuery.setVendorName(bookOrder.getVendorName());
		bookOrderQuery.setBookShippingUpdateJudge(this.salesOrderService.bookShippingUpdateJudge(codes));
		return bookOrderQuery;
	}
	
	public BookOrderQuery getBookDetailCom(String bookCode) throws Exception {
		BookOrderQuery bookOrderQuery = new BookOrderQuery();
		BookOrder bookOrder = this.bookOrderDao.getBookOrderDetail(bookCode);
		if (bookOrder == null) {
			return bookOrderQuery;
		}
		CopySpecialProperties.copyBeanToBean(bookOrder, bookOrderQuery);
		List<String> codes = this.bookOrderItemDao.findOrderCodeByBookCode(new String[] { bookOrder.getBookCode() });
		String[] tmp = codes.toArray(new String[codes.size()]);
		Set<String> orderCodes = new HashSet<String>(Arrays.asList(tmp));
		SalesOrderQuery query = this.salesOrderService.getSalesOrderDetialByCode(codes.get(0));
		CopySpecialProperties.copyBeanToBean(query, bookOrderQuery);
		Port p = portService.getByCode(query.getPortEndCode());
		bookOrderQuery.setPortEndNameEn(p!=null?p.getPortName():"");
		bookOrderQuery.setOrderType(query.getOrderType());
		bookOrderQuery.setCreatedBy(bookOrder.getCreatedBy());
		Date custDate = this.salesOrderService.getMinCustDate(tmp);
		bookOrderQuery.setOrderCodes(orderCodes);
		bookOrderQuery.setOrderCustomDate(custDate);
		bookOrderQuery.setOrderCodes(orderCodes);
		bookOrderQuery.setFareDealType(this.salesOrderService.hasFareDealType(codes));
		ShipPaperQuery shipPaperQuery=new ShipPaperQuery();
		shipPaperQuery.setBookCode(bookCode);
		List<ShipPaper> shipPaperList = shipPaperDao.findList(shipPaperDao.getMybatisMapperNamesapce() + ".findList", shipPaperQuery);  //根据订舱号，查下货纸。
		if(shipPaperList!=null && shipPaperList.size()>0){
			ShipPaper paper = shipPaperList.get(0);
			bookOrderQuery.setShipPaperCode(paper.getShipPaperCode());
			bookOrderQuery.setVessel(paper.getVessel());
			bookOrderQuery.setVoyno(paper.getVoyno());
			bookOrderQuery.setPlanArrivalDate(paper.getPlanArrivalDate());
		}
		return bookOrderQuery;
	}
	public void add(BookOrderQuery bookOrderQuery, List<BookOrderItem> bookOrderItems) {
		HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
		Set<String> codes = new HashSet<String>();
		bookOrderQuery.setActiveFlag("1");
		bookOrderQuery.setCreatedBy(loginContext.getEmpCode());
		bookOrderQuery.setCreated(new Date());
		bookOrderQuery.setLastUpd(new Date());
		bookOrderQuery.setModificationNum(Long.valueOf(0));
		this.add(bookOrderQuery);
		for (BookOrderItem item : bookOrderItems) {
			codes.add(item.getOrderCode());
			item.setBookItemCode(GenerateTableSeqUtil.generateTableSeq("ACT_BOOK_ORDER_ITEM"));
			item.setActiveFlag("1");
			item.setCreated(new Date());
			item.setLastUpd(new Date());
			this.bookOrderItemDao.save(item);
		}
		List<String> orderCodes = this.bookOrderItemDao.findOrderCodes(bookOrderQuery.getBookCode(), null);
		/**
		 * 订舱目的港修改
		 * 修改订单主数据并保存修改记录
		 */
		//this.salesOrderService.updateEndPortByCode(bookOrderQuery.getPortEndCode(), orderCodes);
		bookPortUpdateLog(orderCodes, bookOrderQuery.getBookCode(), bookOrderQuery.getPortEndCode());
		/**
		 * 订舱船公司修改回传SAP
		 * 取消订舱船公司信息修改后同步修改订单信息
		 * 2020-04-26
		 */
		//this.salesOrderService.updateVendor(bookOrderQuery.getVendorCode(), orderCodes);
		boolean isDocConfirm = salesOrderService.hasLc(orderCodes);   //信用证订单走信用证审核，非信用证订单直接到订舱分配
		Map<String, Object> variables = new HashMap<String, Object>();
		for (String code : codes) {
			SalesOrder so = this.salesOrderService.get(code);
			variables.put("orderDocManager", so.getDocManager());
			String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
			Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("bookCabinConfirm").singleResult();
			taskService.setVariable(task.getId(), "isDocConfirm", isDocConfirm);
			taskService.setVariable(task.getId(), "isWaitCabin", bookOrderQuery.isWaitCabin());
			taskService.complete(task.getId(), variables);
		}
	}
	public void addCom(BookOrderQuery bookOrderQuery,List<BookOrderItem> bookOrderItems) {
		HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
		Set<String> codes = new HashSet<String>();
		bookOrderQuery.setActiveFlag("1");
		bookOrderQuery.setCreatedBy(loginContext.getEmpCode());
		bookOrderQuery.setCreated(new Date());
		bookOrderQuery.setLastUpd(new Date());
		bookOrderQuery.setModificationNum(Long.valueOf(0));
		this.add(bookOrderQuery);
		for (BookOrderItem item : bookOrderItems) {
			codes.add(item.getOrderCode());
			item.setBookItemCode(GenerateTableSeqUtil.generateTableSeq("ACT_BOOK_ORDER_ITEM"));
			item.setActiveFlag("1");
			item.setCreated(new Date());
			item.setLastUpd(new Date());
			this.bookOrderItemDao.save(item);
		}
		ShipPaperQuery shipPaperQuery=new ShipPaperQuery();
		shipPaperQuery.setBookCode(bookOrderQuery.getBookCode());
		List<ShipPaper> shipPaperList = shipPaperDao.findList(shipPaperDao.getMybatisMapperNamesapce() + ".findList", shipPaperQuery);  //根据订舱号，查下货纸。
		if(shipPaperList!=null && shipPaperList.size()>0){
			ShipPaper shipPaper=shipPaperList.get(0);
			shipPaper.setVessel(bookOrderQuery.getVessel());
			shipPaper.setVoyno(bookOrderQuery.getVoyno());
			shipPaper.setPlanArrivalDate(bookOrderQuery.getPlanArrivalDate());
			shipPaper.setBookCode(bookOrderQuery.getBookCode());
			shipPaper.setShipPaperCode(bookOrderQuery.getShipPaperCode());
			shipPaper.setBookShipDate(bookOrderQuery.getBookShipDate());
			shipPaperDao.update(shipPaper);
		}else{
			String shipPaperRowId=GenerateTableSeqUtil.generateTableSeq("ACT_SHIP_PAPER");
			shipPaperQuery.setRowId(shipPaperRowId);
			shipPaperQuery.setVessel(bookOrderQuery.getVessel());
			shipPaperQuery.setVoyno(bookOrderQuery.getVoyno());
			shipPaperQuery.setPlanArrivalDate(bookOrderQuery.getPlanArrivalDate());
			shipPaperQuery.setShipPaperCode(bookOrderQuery.getShipPaperCode());
			shipPaperQuery.setBookShipDate(bookOrderQuery.getBookShipDate());
			shipPaperService.add(shipPaperQuery);
			for(int j=0;j<bookOrderItems.size();j++){
				BookOrderItem t = bookOrderItems.get(j);
				ShipPaperItemQuery shipPaperItemQuery=new ShipPaperItemQuery();
				shipPaperItemQuery.setRowId(GenerateTableSeqUtil.generateTableSeq("ACT_SHIP_PAPER_ITEM"));
				shipPaperItemQuery.setOrderCode(t.getOrderCode());
				shipPaperItemQuery.setShipPaperRowId(shipPaperRowId);
				shipPaperItemQuery.setOrderItemLineCode(t.getOrderItemCode());
				shipPaperItemService.add(shipPaperItemQuery);
			}
		}
		for(int i=0;i<bookOrderItems.size();i++){
			BookOrderItem te = bookOrderItems.get(i);
			String orderItemCode=te.getOrderItemCode();//行项目号
			String loadingBoxCode=te.getLoadingBoxCode();//集装箱号
			String loadingPlanCode=loadingBoxCode;//actImportFeeQuery.getLoadingPlanCode();//装箱预编号
			ActCntQuery actCntQuery=new ActCntQuery();//装箱活动表
			actCntQuery.setLoadingPlanCode(loadingPlanCode);
			List<ActCnt> actCntList = actCntDao.findList(actCntDao.getMybatisMapperNamesapce() + ".findList", actCntQuery);
			if(actCntList==null || actCntList.size()<1){
				actCntQuery.setActCntCode(GenerateTableSeqUtil.generateTableSeq("ACT_CNT"));
				actCntQuery.setLoadingBoxCode(loadingBoxCode);
				actCntService.add(actCntQuery);
			}
			ActCntItemQuery actCntItemQuery=new ActCntItemQuery();//装箱明细表
			actCntItemQuery.setActCntCode(loadingPlanCode);
			actCntItemQuery.setLoadingBoxCode(loadingBoxCode);
			actCntItemQuery.setOrderNum(te.getOrderCode());
			actCntItemQuery.setOrderItemId(orderItemCode);
			actCntItemQuery.setOrderItemCode(orderItemCode);
			actCntItemQuery.setCustomerModel(te.getCustomerModel());
			actCntItemQuery.setActCntItemCode(GenerateTableSeqUtil.generateTableSeq("ACT_CNT_ITEM"));
			actCntItemService.add(actCntItemQuery);
		}
		List<String> orderCodes = this.bookOrderItemDao.findOrderCodes(bookOrderQuery.getBookCode(), null);
//		this.salesOrderService.updateEndPortByCode(bookOrderQuery.getPortEndCode(), orderCodes);
		//this.salesOrderService.updateVendor(bookOrderQuery.getVendorCode(), orderCodes);
		ShipPaperQuery paperQuery = new ShipPaperQuery();
		paperQuery.setBookCode(bookOrderQuery.getBookCode());
		this.shipPaperService.updateCallPrcDocument(paperQuery);//传单证系统、生成客户发票
		for(int i=0;i<bookOrderItems.size();i++){            //往EDI_SEND_MSG表村数据
			ediSendMsgService.prcToEdi(bookOrderItems.get(i).getOrderCode());
		}
		boolean isDocConfirm = salesOrderService.hasLc(orderCodes);//信用证订单走信用证审核，非信用证订单直接到出运
		Map<String, Object> variables = new HashMap<String, Object>();
		for (String code : codes) {
			SalesOrder so = this.salesOrderService.get(code);
			variables.put("orderDocManager", so.getDocManager());
			String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
			Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("ComputerBook").singleResult();
			taskService.setVariable(task.getId(), "isDocConfirm", isDocConfirm);
			taskService.setVariable(task.getId(), "isWaitCabin", bookOrderQuery.isWaitCabin());
			taskService.complete(task.getId(), variables);
		}
	}
	public BookOrder add(BookOrderQuery bookOrderQuery) {
		BookOrder t = new BookOrder();
		BeanUtils.copyProperties(bookOrderQuery, t);
		this.bookOrderDao.save(t);
		return t;
	}
	/**
	 * 订舱分配
	 */
	public void update(String[] bookCodes, String vendorCode, String shipCompany, String pickUpArea, Boolean transConfirm) {
		List<String> companyChangeOrder = new ArrayList<String>();
		Boolean updateCompanyFlag = true;
		HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
		List<String> codes = this.bookOrderItemDao.findOrderCodeByBookCode(bookCodes);
		if (transConfirm) {
			//调用SAP接口传输订单船公司
			//订舱分配货代，判断船公司是否发生变化；
			//2020-04-03  YXB
			if(!"".equals(shipCompany) && shipCompany != null){
				SalesOrder soInfo = salesOrderService.get(codes.get(0));
				if(!shipCompany.equals(soInfo.getVendorCode())){
					for (String updateOrderCode : codes) {
						//去除备件订单
						if(updateOrderCode.startsWith("000")){
							String resultStatus = null;
							String resultMsg = null;
							//if("ZOR".equals(soInfo.getSapType())){
								//调用SAP接口传输订单船公司信息
								String resultInfo = hopeInterfaceService.returnSAPOrderShipping(updateOrderCode,shipCompany);
								JSONObject returnJson = JSONObject.fromObject(resultInfo);
								resultStatus = returnJson.getString("result");
								resultMsg = returnJson.getString("msg");
								if(!"S".equals(resultStatus)){
									updateCompanyFlag = false;
								}else{
									//修改船公司的订单信息
									//2020-05-19  FOB订单直接传输SAP，更新HROIS主表数据，不需要重新获取，不变更状态
									List<String> panduanFobOrderList = new ArrayList<String>();
									panduanFobOrderList.add(updateOrderCode);
									boolean panduanFob = this.salesOrderService.hasFareDealType(panduanFobOrderList);
									if(!panduanFob){
										//FOB订单直接修改订单主表船公司
										List<String> FobOrderList = new ArrayList<String>();
										FobOrderList.add(updateOrderCode);
										this.salesOrderService.updateVendor(shipCompany, FobOrderList);
									}else{
										//非FOB订单
										companyChangeOrder.add(updateOrderCode);
									}
								}
							/*}else{
								List<String> panduanFobOrderList = new ArrayList<String>();
								panduanFobOrderList.add(updateOrderCode);
								boolean panduanFob = this.salesOrderService.hasFareDealType(panduanFobOrderList);
								if(!panduanFob){
									//FOB订单直接修改订单主表船公司
									List<String> FobOrderList = new ArrayList<String>();
									FobOrderList.add(updateOrderCode);
									this.salesOrderService.updateVendor(shipCompany, FobOrderList);
								}
							}*/
							//订舱船公司修改记录
							//2020-05-18  YXB
							BookShippingUpdateLog bookShippingUpdateLog = new BookShippingUpdateLog();
							bookShippingUpdateLog.setBookCode(bookCodes[0]);//订舱号
							bookShippingUpdateLog.setOrderCode(updateOrderCode);//订单号
							bookShippingUpdateLog.setOrderShippingCode(soInfo.getVendorCode());//订单船公司
							bookShippingUpdateLog.setOrderExceManager(soInfo.getOrderExecManager());//订单执行经理
							BookOrder t = bookOrderDao.getById(bookCodes[0]);
							bookShippingUpdateLog.setBookShippingCode1(t.getVendorCode());//订单经理订舱船公司
							bookShippingUpdateLog.setOrderTransManager(soInfo.getOrderTransManager());//订单物流经理
							bookShippingUpdateLog.setBookShippingCode2(shipCompany);//物流经理订舱船公司
							bookShippingUpdateLog.setInterfaceStatus(resultStatus);//sap返回状态
							bookShippingUpdateLog.setInterfaceMessage(resultMsg);//sap返回信息
							bookShippingUpdateLog.setInterfaceDate(new Date());//接口时间
							bookShippingUpdateLogDao.saveOrUpdate(bookShippingUpdateLog);
						}
					}
				}
			}
			
			//若传输SAP修改订单船公司接口失败
			//分配货代无法保存完成
			if(updateCompanyFlag){
				for (String code : bookCodes) {
					BookOrder t = bookOrderDao.getById(code);
					if (t != null) {
						//船公司
						t.setVendorCode(shipCompany);
						//货代
						t.setBookAgent(vendorCode);
						t.setPickUpArea(pickUpArea);
						t.setLastUpd(new Date());
						t.setLastUpdBy(loginContext.getEmpCode());
						bookOrderDao.update(t);
					}
				}
				
				//订舱分配节点完成
				Map<String, Object> variables = new HashMap<String, Object>();
				variables.put("orderAgents", vendorCode);
				for (String code : codes) {
					String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
					Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("boonAgent").singleResult();
					taskService.setVariable(task.getId(), "transConfirm", true);
					taskService.complete(task.getId(), variables);
				}
				
				//调用SAP接口传输订单船公司
				//船公司是否修改，是否需要锁定，整机订单
				//2020-04-03  YXB
				if(companyChangeOrder != null && companyChangeOrder.size() > 0){
					for(String changeOrder : companyChangeOrder){
						//将订单流程锁定挂起
						SalesOrder salesOrder = new SalesOrder();
						salesOrder.setOrderCode(changeOrder);
						salesOrder.setOrderAuditFlag("3");
						salesOrder.setLockObtainFlag("1");
						salesOrderService.updateLockObtainFlag(salesOrder);
						String processInstanceId = wfProcinstanceService.findProcinstanceId(changeOrder, "SO_SALES_ORDER", "orderTrace", "1");
						if (ValidateUtil.isValid(processInstanceId)) {
							ServiceImpl serviceImpl = (ServiceImpl) runtimeService;
							ChangeProcessInstanceStateCmd changeProcessInstanceStateCmd = new ChangeProcessInstanceStateCmd(SuspensionState.SUSPENDED, processInstanceId);
							serviceImpl.getCommandExecutor().execute(changeProcessInstanceStateCmd);
						}
					}
					//2020-05-14
					//发送船公司修改邮件-订单执行经理
					try {
						String[] updateOrderCodes = companyChangeOrder.toArray(new String[companyChangeOrder.size()]);
						shipCompanyChangeMail(updateOrderCodes);
					} catch (Exception e) {
						e.getMessage();
					}
				}
			}
		} else {
			for (String code : bookCodes) {
				BookOrder t = bookOrderDao.getById(code);
				t.setActiveFlag("0");
				bookOrderDao.update(t);
			}
			List<String> orderCodes = bookOrderItemDao.findOrderCodeByBookCode(bookCodes);
			String[] ids = (String[]) orderCodes.toArray(new String[orderCodes.size()]);
			List<SalesOrder> salesOrders = this.salesOrderService.findOrderByIds(ids);
			List<String> empCodes = new ArrayList<String>();
			for (SalesOrder order : salesOrders) {
				empCodes.add(order.getOrderExecManager());
			}
			List<User> users = userService.getUserByEmpCodes(empCodes);
			sendMail(bookCodes, users);
		}
	}
	
	
	/**
	 * 测试
	 */
	public void bookCompanyToSAP(){
		List<BookOrder> list = bookOrderDao.selectOrderCode();
		if(list != null){
			for(BookOrder bookOrder : list){
				String orderCode = bookOrder.getBookCode();
				String vendorCode = bookOrder.getVendorCode();
				//传输SAP
				hopeInterfaceService.returnSAPOrderShipping(orderCode,vendorCode);
				
				//将订单流程锁定挂起
				SalesOrder salesOrder = new SalesOrder();
				salesOrder.setOrderCode(orderCode);
				salesOrder.setOrderAuditFlag("3");
				salesOrder.setLockObtainFlag("1");
				salesOrderService.updateLockObtainFlag(salesOrder);
				String processInstanceId = wfProcinstanceService.findProcinstanceId(orderCode, "SO_SALES_ORDER", "orderTrace", "1");
				if (ValidateUtil.isValid(processInstanceId)) {
					ServiceImpl serviceImpl = (ServiceImpl) runtimeService;
					ChangeProcessInstanceStateCmd changeProcessInstanceStateCmd = new ChangeProcessInstanceStateCmd(SuspensionState.SUSPENDED, processInstanceId);
					serviceImpl.getCommandExecutor().execute(changeProcessInstanceStateCmd);
				}
			}
		}
	}
	
	
	
	
	/**
	 * 批量订舱分配
	 * 2020-05-13  YXB
	 */
	public void batchUpdate(String[] bookCodes, String vendorCode, String pickUpArea, Boolean transConfirm) {
		List<String> companyChangeOrder = new ArrayList<String>();
		Boolean updateCompanyFlag = true;
		HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
		List<String> codes = this.bookOrderItemDao.findOrderCodeByBookCode(bookCodes);
		if (transConfirm) {
			//订舱分配货代，判断船公司是否发生变化；
			for (String updateOrderCode : codes) {
				//去除备件订单
				if(updateOrderCode.startsWith("000")){
					//订单船公司
					SalesOrder soInfo = salesOrderService.get(updateOrderCode);
					String orderVendor = soInfo.getVendorCode();
					//订舱船公司
					String bookVendor = salesOrderService.selectBookShippingByOrderCode(updateOrderCode);
					//判断船公司是否发生修改
					if(!orderVendor.equals(bookVendor)){
						String resultStatus = null;
						String resultMsg = null;
						//if("ZOR".equals(soInfo.getSapType())){
							//调用SAP接口传输订单船公司信息
							String resultInfo = hopeInterfaceService.returnSAPOrderShipping(updateOrderCode,bookVendor);
							JSONObject returnJson = JSONObject.fromObject(resultInfo);
							resultStatus = returnJson.getString("result");
							resultMsg = returnJson.getString("msg");
							if(!"S".equals(resultStatus)){
								updateCompanyFlag = false;
							}else{
								//修改船公司的订单信息
								//2020-05-19  FOB订单直接传输SAP，更新HROIS主表数据，不需要重新获取，不变更状态
								List<String> panduanFobOrderList = new ArrayList<String>();
								panduanFobOrderList.add(updateOrderCode);
								boolean panduanFob = this.salesOrderService.hasFareDealType(panduanFobOrderList);
								if(!panduanFob){
									//FOB订单直接修改订单主表船公司
									List<String> FobOrderList = new ArrayList<String>();
									FobOrderList.add(updateOrderCode);
									this.salesOrderService.updateVendor(bookVendor, FobOrderList);
								}else{
									//非FOB订单
									companyChangeOrder.add(updateOrderCode);
								}
							}
						/*}else{
							List<String> panduanFobOrderList = new ArrayList<String>();
							panduanFobOrderList.add(updateOrderCode);
							boolean panduanFob = this.salesOrderService.hasFareDealType(panduanFobOrderList);
							if(!panduanFob){
								//FOB订单直接修改订单主表船公司
								List<String> FobOrderList = new ArrayList<String>();
								FobOrderList.add(updateOrderCode);
								this.salesOrderService.updateVendor(bookVendor, FobOrderList);
							}
						}*/
						//订舱船公司修改记录
						//2020-05-18  YXB
						BookShippingUpdateLog bookShippingUpdateLog = new BookShippingUpdateLog();
						List<BookOrderItem> updateBookList = bookOrderItemDao.findByOrderCode0(updateOrderCode);
						bookShippingUpdateLog.setBookCode(updateBookList.get(0).getBookCode());//订舱号
						bookShippingUpdateLog.setOrderCode(updateOrderCode);//订单号
						bookShippingUpdateLog.setOrderShippingCode(soInfo.getVendorCode());//订单船公司
						bookShippingUpdateLog.setOrderExceManager(soInfo.getOrderExecManager());//订单执行经理
						bookShippingUpdateLog.setBookShippingCode1(bookVendor);//订单经理订舱船公司
						bookShippingUpdateLog.setOrderTransManager(soInfo.getOrderTransManager());//订单物流经理
						bookShippingUpdateLog.setBookShippingCode2(bookVendor);//物流经理订舱船公司
						bookShippingUpdateLog.setInterfaceStatus(resultStatus);//sap返回状态
						bookShippingUpdateLog.setInterfaceMessage(resultMsg);//sap返回信息
						bookShippingUpdateLog.setInterfaceDate(new Date());//接口时间
						bookShippingUpdateLogDao.saveOrUpdate(bookShippingUpdateLog);
					}
				}
			}
			
			//若传输SAP修改订单船公司接口失败
			//分配货代无法保存完成
			if(updateCompanyFlag){
				for (String code : bookCodes) {
					BookOrder t = bookOrderDao.getById(code);
					if (t != null) {
						//货代
						t.setBookAgent(vendorCode);
						t.setPickUpArea(pickUpArea);
						t.setLastUpd(new Date());
						t.setLastUpdBy(loginContext.getEmpCode());
						bookOrderDao.update(t);
					}
				}
				
				//订舱分配节点完成
				Map<String, Object> variables = new HashMap<String, Object>();
				variables.put("orderAgents", vendorCode);
				for (String code : codes) {
					String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
					Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("boonAgent").singleResult();
					taskService.setVariable(task.getId(), "transConfirm", true);
					taskService.complete(task.getId(), variables);
				}
				
				//调用SAP接口传输订单船公司
				//船公司是否修改，是否需要锁定，整机订单
				//2020-04-03  YXB
				if(companyChangeOrder != null && companyChangeOrder.size() > 0){
					for(String changeOrder : companyChangeOrder){
						//将订单流程锁定挂起
						SalesOrder salesOrder = new SalesOrder();
						salesOrder.setOrderCode(changeOrder);
						salesOrder.setOrderAuditFlag("3");
						salesOrder.setLockObtainFlag("1");
						salesOrderService.updateLockObtainFlag(salesOrder);
						String processInstanceId = wfProcinstanceService.findProcinstanceId(changeOrder, "SO_SALES_ORDER", "orderTrace", "1");
						if (ValidateUtil.isValid(processInstanceId)) {
							ServiceImpl serviceImpl = (ServiceImpl) runtimeService;
							ChangeProcessInstanceStateCmd changeProcessInstanceStateCmd = new ChangeProcessInstanceStateCmd(SuspensionState.SUSPENDED, processInstanceId);
							serviceImpl.getCommandExecutor().execute(changeProcessInstanceStateCmd);
						}
					}
					//2020-05-14
					//发送船公司修改邮件-订单执行经理
					try {
						String[] updateOrderCodes = companyChangeOrder.toArray(new String[companyChangeOrder.size()]);
						shipCompanyChangeMail(updateOrderCodes);
					} catch (Exception e) {
						e.getMessage();
					}
				}
			}
		} else {
			for (String code : bookCodes) {
				BookOrder t = bookOrderDao.getById(code);
				t.setActiveFlag("0");
				bookOrderDao.update(t);
			}
			List<String> orderCodes = bookOrderItemDao.findOrderCodeByBookCode(bookCodes);
			String[] ids = (String[]) orderCodes.toArray(new String[orderCodes.size()]);
			List<SalesOrder> salesOrders = this.salesOrderService.findOrderByIds(ids);
			List<String> empCodes = new ArrayList<String>();
			for (SalesOrder order : salesOrders) {
				empCodes.add(order.getOrderExecManager());
			}
			List<User> users = userService.getUserByEmpCodes(empCodes);
			sendMail(bookCodes, users);
		}
	}
	
	
	/**
	 * 订舱船公司修改邮件提醒
	 * 2020-05-14   YXB
	 * @throws MessagingException 
	 * @throws IOException 
	 * @throws ParseException 
	 * @throws MalformedTemplateNameException 
	 * @throws TemplateNotFoundException 
	 * @throws TemplateException 
	 */
	private void shipCompanyChangeMail(String[] orderCodes) throws MessagingException, TemplateNotFoundException, MalformedTemplateNameException, ParseException, IOException, TemplateException{
		//根据订单号查询订单执行经理
		List<BookOrder> managerList = bookOrderDao.selectOrderExecManager(orderCodes);
		for(BookOrder managerInfo : managerList){
			List<BookOrder> bookVendorInfoList = bookOrderDao.selectOrderShipInfo(managerInfo.getOrderManagerCode(), orderCodes);
			if(bookVendorInfoList != null && bookVendorInfoList.size() > 0){
				//邮箱设置
				mailSender.setPort(25);	 
				mailSender.setProtocol("smtp");
				MimeMessage mimeMessage = mailSender.createMimeMessage();
				MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true,"UTF-8");
				//发送人
				String fromName = "HroisAdmin";
				String fromAddress = "hrois@haier.net";
				helper.setFrom(new InternetAddress(fromAddress,fromName));
				//收件人
				List<InternetAddress> toAddressList = new ArrayList<InternetAddress>();
				InternetAddress toRecipient = new InternetAddress(managerInfo.getOrderManagerEmail(), managerInfo.getOrderManagerName());
				if(StringUtils.isNotBlank(managerInfo.getOrderManagerEmail())){
					toAddressList.add(toRecipient);
				}
				helper.setTo(toAddressList.toArray(new InternetAddress[toAddressList.size()]));
				//设置主题
				helper.setSubject("【HROIS】订舱船公司修改提醒！！！");
				//构建内容
				Map<String, Object> parameters = new HashMap<String, Object>();
				parameters.put("appName", Env.getProperty(Env.APP_NAME.isEmpty() || Env.APP_NAME == null ? "" : Env.APP_NAME));
				parameters.put("title", "【HROIS】订舱船公司修改提醒！！！");
				parameters.put("bookVendorInfoList", bookVendorInfoList);
	            Template template = freemarkerConfig.getConfiguration().getTemplate("update_bookShipping_tip-content.ftl");
			    String contentText = FreeMarkerTemplateUtils.processTemplateIntoString(template,parameters);
	            helper.setText(contentText,true);
	            //邮件发送
				mailSender.send(mimeMessage);
			}
		}
	}
	
	
	private void sendMail(String[] bookCodes, List<User> users) {
		Email email = new Email();
		email.setSystem("HROIS");
		Recipient recipient = new Recipient();
		recipient.setUserName("HroisAdmin");
		recipient.setEmailAddress(Env.getProperty(Env.APP_EAMIL.isEmpty() || Env.APP_EAMIL == null ? "" : Env.APP_EAMIL));
		email.setSender(recipient);
		email.setSubject("订舱申请退回提醒【HROIS】");
		List<Recipient> recipients = new ArrayList<Recipient>();
		for (User user : users) {
			recipients.add(new Recipient(user.getEmail(), user.getName()));
		}
		email.setToRecipient(recipients);
		StringBuffer bodyContent = new StringBuffer();
		bodyContent.append("您好，\n");
		bodyContent.append("      ");
		bodyContent.append("编码为 ").append(JSONArray.fromObject(bookCodes)).append("的订舱已被退回，请注意查收！\n");
		bodyContent.append("谢谢");
		email.setBodyContent(bodyContent.toString(), false);
		sendEmailServiceClient.sendEmail(email);
	}
	public void delBookCabin(String[] bookCodes) {
		List<String> codes = this.bookOrderItemDao.findOrderCodeByBookCode(bookCodes);
		for (String bookCode : bookCodes) {
			this.bookOrderItemDao.deleteByBookCode(bookCode);
			this.bookOrderDao.deleteById(bookCode);
		}
		for (String code : codes) {
			String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
			orderEditService.reDoTask("bookCabinConfirm", processInstanceId);
		}
	}
	/** @author 门光耀  * @description 根据订舱号和合并报关标志来查询订舱下面订单的数量 */
	public Long fintCountByBookCode(BookOrderItemQuery query) {
		return bookOrderItemDao.fintCountByBookCode(query);
	}
	public void update(BookOrder bookOrder) { this.bookOrderDao.update(bookOrder); }
	public void setWfProcinstanceDao(WfProcinstanceDao wfProcinstanceDao) { this.wfProcinstanceDao = wfProcinstanceDao; }
	public void deleteById(String id) { this.bookOrderDao.deleteById(id); }
	public BookOrder getByOrderCode(String code) { return this.bookOrderDao.getByOrderCode(code); }
	public Integer updateAssignerByBookCode(String agentCode, String[] bookCodes) {
		for (String bookCode : bookCodes) {
			int i = this.actDao.findAct("agentsConfirm", "end", bookCode);
			if (i > 0) { return 0; }
		}
		for (String bookCode : bookCodes) {
			BookOrder t = bookOrderDao.getById(bookCode);
			if (t != null) {
				t.setBookAgent(agentCode);
				bookOrderDao.update(t);
			}
		}
		List<String> orderCodes = this.bookOrderItemDao.findOrderCodeByBookCode(bookCodes);
		for (String orderCode : orderCodes) {            //工作流办理人变更
			String processInstanceId = wfProcinstanceService.findProcinstanceId(orderCode, "SO_SALES_ORDER", "orderTrace", "1");
			runtimeService.setVariable(processInstanceId, "orderAgents", agentCode);
			activitiService.updateAssgin(processInstanceId, orderCode);
		}
		return 1;
	}
	public JSONObject findCabinPaper(String bookCode) {
		Map<String, Object> cabinPaperMain = this.bookOrderDao.findCabinPaper(bookCode);
		if (cabinPaperMain == null) {
			cabinPaperMain = new HashMap<String, Object>();
		} else {
			cabinPaperMain.put("BOOK_CODE", bookCode);
			DataGrid dg = this.bookOrderDao.findCabinPaperItem(bookCode);
			cabinPaperMain.put("items", dg);
		}
		return JSONObject.fromObject(cabinPaperMain);
	}
	public JSONArray findMergeOrder(String[] orderCodes) { return JSONArray.fromObject(this.bookOrderDao.findMergeOrder(orderCodes)); }
	public Integer updateStockNotification(BookOrderQuery bookOrderQuery) { return this.bookOrderDao.updateStockNotification(bookOrderQuery); }
	public boolean checkStockNotification(String[] codes) { return this.bookOrderDao.checkStockNotification(codes); }
	public void updCabinCredit(BookOrderQuery bookOrderQuery) {
		String bookCode = bookOrderQuery.getBookCode();
		BookOrder t = bookOrderDao.getById(bookCode);
		if (t != null) {
			t.setBookSendMan(bookOrderQuery.getBookSendMan());
			t.setBookReceiveMan(bookOrderQuery.getBookReceiveMan());
			t.setBookNotifyMan(bookOrderQuery.getBookNotifyMan());
			t.setBookGetComments(bookOrderQuery.getBookGetComments());
			t.setLcNum(bookOrderQuery.getLcNum());
			bookOrderDao.update(t);
			List<String> codes = this.bookOrderItemDao.findOrderCodeByBookCode(new String[] { bookCode });
			for (String code : codes) {
				String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
				Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("docManagerConfirm").singleResult();
				if (task != null) { taskService.complete(task.getId()); }
			}
		}
	}
	@Override
	public String getNewAssgineeService(String processInstanceId, String orderCode) {
		BookOrder bo = this.bookOrderDao.getByOrderCode(orderCode);
		if (bo != null) { return bo.getBookAgent(); }
		return null;
	}
	public void updCabin(BookOrderQuery bookOrderQuery, List<BookOrderItem> bookOrderItems) throws Exception {
		BookOrder bookOrder = this.get(bookOrderQuery.getBookCode());
		CopySpecialProperties.copyBeanToBean(bookOrderQuery, bookOrder);
		bookOrder.setActiveFlag("1");
		this.update(bookOrder);
		for (BookOrderItem bookOrderItem : bookOrderItems) {
			BookOrderItem bi = this.bookOrderItemDao.getById(bookOrderItem.getBookItemCode());
			CopySpecialProperties.copyBeanToBean(bookOrderItem, bi);
			bi.setLastUpd(new Date());
			this.bookOrderItemDao.update(bi);
		}
		List<String> orderCodes = this.bookOrderItemDao.findOrderCodes(bookOrderQuery.getBookCode(), null);
		/**
		 * 订舱目的港修改
		 * 修改订单主数据并保存修改记录
		 */
		//this.salesOrderService.updateEndPortByCode(bookOrderQuery.getPortEndCode(), orderCodes);
		bookPortUpdateLog(orderCodes, bookOrderQuery.getBookCode(), bookOrderQuery.getPortEndCode());
		/**
		 * 订舱船公司修改回传SAP
		 * 取消订舱船公司信息修改后同步修改订单信息
		 * 2020-04-26
		 */
		//this.salesOrderService.updateVendor(bookOrderQuery.getVendorCode(), orderCodes);
	}
	public List<BookOrderQuery> findWaitCabin(BookOrderQuery bookOrderQuery) {
		HroisTaskQueryImpl hroisTaskQueryImpl = new HroisTaskQueryImpl();
		hroisTaskQueryImpl.taskDefinitionKey("waitCabin");
		String subSql = MyBatisSqlUtils.getMyBatisSql("BookOrder.cabinTask.sql", bookOrderQuery).toString();
		hroisTaskQueryImpl.setIdColm("ORDER_CODE");
		hroisTaskQueryImpl.setReturnColum("DISTINCT BOOK_CODE");
		hroisTaskQueryImpl.setSubSql(subSql);
		List<Map<String, Object>> list = wfProcinstanceDao.queryByHroisTask(hroisTaskQueryImpl);
		List<String> codes = new ArrayList<String>();
		for (Map<String, Object> map : list) {
			codes.add(String.valueOf(map.get("BOOK_CODE")));
		}
		List<BookOrderQuery> querys = this.bookOrderDao.findCabinList(codes);
		return querys;
	}
	public DataGrid datagridWaitCabin(BookOrderQuery bookOrderQuery) {
		HroisTaskQueryImpl hroisTaskQueryImpl = new HroisTaskQueryImpl();
		hroisTaskQueryImpl.taskDefinitionKey("waitCabin");
		String subSql = MyBatisSqlUtils.getMyBatisSql("BookOrder.cabinTask.sql", bookOrderQuery).toString();
		hroisTaskQueryImpl.setSubSql(subSql);
		hroisTaskQueryImpl.setIdColm("ORDER_CODE");
		hroisTaskQueryImpl.setReturnColum("DISTINCT FORMTABLE.BOOK_CODE,FORMTABLE.CREATED");
		hroisTaskQueryImpl.setSort("CREATED");
		hroisTaskQueryImpl.setOrder("DESC");
		hroisTaskQueryImpl.setSubSql(subSql);
		Pager<BookOrder> p = bookOrderQuery.getPager();
		int currentPager = p.getCurrentPage().intValue();
		int pagerSize = p.getPageSize().intValue();
		hroisTaskQueryImpl.setFirstResult((currentPager - 1) * pagerSize);
		hroisTaskQueryImpl.setMaxResults(pagerSize);
		hroisTaskQueryImpl.setSeqCol("BOOK_CODE");
		Pager<Map> pager = wfProcinstanceDao.queryPageByHroisTask(hroisTaskQueryImpl);
		List<String> codes = new ArrayList<String>();
		for (Map record : pager.getRecords()) {
			codes.add(String.valueOf(record.get("bookCode")));
		}
		DataGrid j = new DataGrid();
		j.setRows(this.bookOrderDao.findCabinList(codes));
		j.setTotal(pager.getTotalRecords());
		return j;
	}
	public DataGrid datagridWaitCabinHis(BookOrderQuery bookOrderQuery) {
		HroisHistoricTaskInstanceQueryImpl hroisTaskQueryImpl = new HroisHistoricTaskInstanceQueryImpl();
		hroisTaskQueryImpl.taskDefinitionKey("waitCabin").finished();
		String subSql = MyBatisSqlUtils.getMyBatisSql("BookOrder.cabinTask.sql", bookOrderQuery).toString();
		hroisTaskQueryImpl.setSubSql(subSql);
		hroisTaskQueryImpl.setIdColm("ORDER_CODE");
		hroisTaskQueryImpl.setReturnColum("DISTINCT FORMTABLE.BOOK_CODE,FORMTABLE.CREATED");
		hroisTaskQueryImpl.setSort("CREATED");
		hroisTaskQueryImpl.setOrder("DESC");
		Pager<BookOrder> p = bookOrderQuery.getPager();
		int currentPager = p.getCurrentPage().intValue();
		int pagerSize = p.getPageSize().intValue();
		hroisTaskQueryImpl.setFirstResult((currentPager - 1) * pagerSize);
		hroisTaskQueryImpl.setMaxResults(pagerSize);
		hroisTaskQueryImpl.setSeqCol("BOOK_CODE");
		Pager<Map> pager = wfProcinstanceDao.queryPageByHroisTask(hroisTaskQueryImpl);
		List<String> codes = new ArrayList<String>();
		for (Map record : pager.getRecords()) {
			codes.add(String.valueOf(record.get("bookCode")));
		}
		DataGrid j = new DataGrid();
		j.setRows(this.bookOrderDao.findCabinList(codes));
		j.setTotal(pager.getTotalRecords());
		return j;
	}
	public void endWaitCabin(List<String> bookCodes) {
		for (String bookCode : bookCodes) {
			boolean attachBookFlag = false;
			List<String> codes = this.bookOrderItemDao.findOrderCodes(bookCode, null);
			boolean isDocConfirm = salesOrderService.hasLc(codes);
			Map<String, Object> variables = new HashMap<String, Object>();//信用证订单走信用证审核，非信用证订单直接到订舱分配
			
			//备件订单随整机装箱扫描发货
			//2020-03-24  YXB  
			//查询需要关联整机订舱的备件订单号
			List<String> attachOrderCode = bookOrderDao.selectAttachOrder(bookCode);
			
			if(attachOrderCode != null && attachOrderCode.size() > 0){
				//清除之前关联的整机订单装箱信息，更新WMS装箱预算信息
				actCntItemService.dealLoadingAttachOrder(attachOrderCode.get(0));
				
				//根据备件订单号+订舱单号查询备件订单订舱信息，判断备件订单是否订舱
				//如果备件订单存在订舱数据，说明合并订舱；否则整机订单单独执行订舱，未等待备件订单
				BookOrderItem bookItemQuery = new BookOrderItem();
				bookItemQuery.setBookCode(bookCode);
				bookItemQuery.setOrderCode(attachOrderCode.get(0));
				List<BookOrderItem> orderBooklist = bookOrderItemDao.findList(bookOrderItemDao.getMybatisMapperNamesapce() + ".findList", bookItemQuery);
				if(orderBooklist != null && orderBooklist.size() > 0){
					attachBookFlag = true;
				}
			}
			
			
			for (String code : codes) {
				SalesOrder so = this.salesOrderService.get(code);
				variables.put("orderDocManager", so.getDocManager());
				String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
				Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("waitCabin").singleResult();
				taskService.setVariable(task.getId(), "isDocConfirm", isDocConfirm);
				taskService.complete(task.getId(), variables);
				
				//备件订单随整机装箱扫描发货
				//2020-03-24  YXB  
				//更新整机装箱信息，关联备件订单
				if(attachBookFlag){
					ActCntItemQuery cntQuery = new ActCntItemQuery();
					cntQuery.setOrderNum(code);
					cntQuery.setAttachOrder(attachOrderCode.get(0));
					actCntItemService.updateAttachOrder(cntQuery);
				}
			}
			
			//备件订单随整机装箱扫描发货
			//2020-03-24  YXB 
			//判断整机的装箱信息是否发送工厂，如果已经发送工厂，更新发送工厂WMS数据
			if(attachBookFlag){
				//根据备件订单号查询已经发送工厂的整机订单号
				List<String> zhengjiOrderCode = actCntItemService.selectOrderLoadingStatus(attachOrderCode.get(0));
				//zhengjiOrderCode有值，代表已经发送工厂，需要重新更新WMS数据
				if(zhengjiOrderCode != null && zhengjiOrderCode.size() > 0){
					//传输WMS订单装箱预算信息
					for (String orderCode : zhengjiOrderCode) {
						actCntItemService.sendPackingFactory(orderCode);
					}
				}
			}
			
		}
	}
	/*public void endWaitCabin(List<String> bookCodes) {
		for (String bookCode : bookCodes) {
			List<String> codes = this.bookOrderItemDao.findOrderCodes(bookCode, null);
			boolean isDocConfirm = salesOrderService.hasLc(codes);
			Map<String, Object> variables = new HashMap<String, Object>();//信用证订单走信用证审核，非信用证订单直接到订舱分配
			for (String code : codes) {
				SalesOrder so = this.salesOrderService.get(code);
				variables.put("orderDocManager", so.getDocManager());
				String processInstanceId = wfProcinstanceService.findProcinstanceId(code, "SO_SALES_ORDER", "orderTrace", "1");
				Task task = taskService.createTaskQuery().processInstanceId(processInstanceId).taskDefinitionKey("waitCabin").singleResult();
				taskService.setVariable(task.getId(), "isDocConfirm", isDocConfirm);
				taskService.complete(task.getId(), variables);
			}
		}
	}*/
	@Override
	public BookOrderQuery getBookOrderByBookOrder(String bookCode) { return bookOrderDao.getBookOrderByBookOrder(bookCode); }
	@Override
	public DataGrid getISFOrder(BookOrderQuery bookOrderQuery) {
		List<Map<String, String>> list = bookOrderDao.getISFOrder(bookOrderQuery);
		DataGrid j = new DataGrid();
		j.setRows(list);
		j.setTotal(bookOrderDao.getISFOrderCount(bookOrderQuery));
		return j;
	}
	@Override
	public Integer updateIsf(BookOrderQuery bookOrderQuery) { return bookOrderDao.updateIsf(bookOrderQuery); }
	public List<Map<String, String>> comboxDzName(BookOrderQuery bookOrderQuery) { return bookOrderDao.comboxDzName(bookOrderQuery); }
	/**判断所有订单是否与合并报关订单同时发起订舱*/
	public Json findOrderMergeCheck(String[] orders){
		Json json = new Json();
		Map<String, String> map = new HashMap<String, String>();
		List<OrderMerge> list = orderMergeDao.findAllMergeQueryByCodes(orders);
		if (list != null && list.size() > 0) {
			for (OrderMerge orderMerge : list) {
				String orderNum = orderMerge.getOrderNum();
				String mergeOrderNum = orderMerge.getMergeOrderNum();
				map.put(orderNum, mergeOrderNum);
				map.put(mergeOrderNum, orderNum);
			}
		}
		for (String order : orders) {//判断每个订单是否与合并报关订单合并订舱，若是返回true
			boolean mergeFlag = false;
			String mergeOrder = map.get(order);
			if (StringUtils.isNotBlank(mergeOrder)) {
				for (String code : orders) {
					if (code.equals(mergeOrder)) {
						mergeFlag = true;
						continue;
					}
				}
			}else{mergeFlag = true;continue;}
			if (!mergeFlag) {
				StringBuffer s = new StringBuffer();
				s.append("订单").append(order).append("与订单").append(mergeOrder).append("已维护合并报关关系，但未同时发起订舱，请核实！");
				json.setMsg(s.toString());
				json.setSuccess(mergeFlag);
				return json;
			}
		}
		json.setSuccess(true);
		return json;
	}
	/**判断所有订单是否与合并报关订单为相同合并报关分组*/
	public Map<String, Object> findOrderMergeCustFlagCheck(List<BookOrderItem> bookOrderItemList){
		Map<String, Object> resultMap = new HashMap<String, Object>();
		Map<String, String> orderMap = new HashMap<String, String>();
		Map<String, String> custFlagMap = new HashMap<String, String>();
		String[] coders = null;
		if (bookOrderItemList != null && bookOrderItemList.size() > 0) {
			coders = new String[bookOrderItemList.size()];
			for (int i = 0; i < bookOrderItemList.size(); i++) {
				String orderCode = bookOrderItemList.get(i).getOrderCode();
				String mergeCustFlag = bookOrderItemList.get(i).getMergeCustFlag();
				coders[i] = orderCode;
				custFlagMap.put(orderCode, mergeCustFlag);
			}
			List<OrderMerge> list = orderMergeDao.findAllMergeQueryByCodes(coders);
			if (list != null && list.size() > 0) {
				for (OrderMerge orderMerge : list) {
					String orderNum = orderMerge.getOrderNum();
					String mergeOrderNum = orderMerge.getMergeOrderNum();
					orderMap.put(orderNum, mergeOrderNum);
					orderMap.put(mergeOrderNum, orderNum);
				}
			}
			for (String code : coders) {
				boolean mergeFlag = false;
				String mergeCode = orderMap.get(code);
				if (StringUtils.isNotBlank(mergeCode)) {
					String flag1 = custFlagMap.get(code);
					String flag2 = custFlagMap.get(mergeCode);
					if (flag1.equals(flag2)) {mergeFlag = true;continue;}
				}else{mergeFlag = true;continue;}
				if (!mergeFlag) {
					StringBuffer s = new StringBuffer();
					s.append("订单").append(code).append("与订单").append(mergeCode).append("已维护合并报关关系，但未分配到相同报关分组，请核实！");
					resultMap.put("msg", s.toString());
					resultMap.put("flag", false);
					return resultMap;
				}
			}
		}
		resultMap.put("flag", true);
		return resultMap;
	}
	
	
	
	/**
	 * 根据成交方式、运输方式、始发港、目的港、船公司、出运时间，判断中标信息是否存在
	 * 2020-04-07  YXB
	 * @param bookOrderQuery
	 * @return
	 */
	@Override
	public boolean judgeBidInfoExist(BookOrderQuery bookOrderQuery){
		SalesOrderQuery salesOrderQuery = new SalesOrderQuery();
		salesOrderQuery.setOrderShipment(bookOrderQuery.getOrderShipment());
		salesOrderQuery.setOrderDealType(bookOrderQuery.getOrderDealType());
		salesOrderQuery.setPortStartCode(bookOrderQuery.getPortStartCode());
		salesOrderQuery.setPortEndCode(bookOrderQuery.getPortEndCode());
		salesOrderQuery.setVendorCode(bookOrderQuery.getVendorCode());
		salesOrderQuery.setOrderShipDate(bookOrderQuery.getBookShipDate());
		List<BidQuery> bidList = salesOrderService.selectBidInfo(salesOrderQuery);
		if(CollectionUtils.isNotEmpty(bidList)){
			return true;
		}else{
			return false;
		}
	}
	
	
	/**
	 * FOB订舱目的港修改
	 * 修改订单目的港信息
	 * 保存修改记录
	 * 2020-05-15  YXB
	 */
	public void bookPortUpdateLog(List<String> orderCodes, String bookCode, String bookPort){
		if(orderCodes != null && orderCodes.size() > 0){
			for(String orderCode : orderCodes){
				SalesOrder soInfo = salesOrderService.get(orderCode);
				String orderPort = soInfo.getPortEndCode();
				//判断订单目的港、订舱目的港是否一致，是否发生修改
				if(!orderPort.equals(bookPort)){
					BookPortUpdateLog portUpdateLog = new BookPortUpdateLog();
					portUpdateLog.setBookCode(bookCode);
					portUpdateLog.setOrderCode(orderCode);
					portUpdateLog.setOrderPortCode(orderPort);
					portUpdateLog.setBookPortCode(bookPort);
					HroisLoginContext loginContext = (HroisLoginContext) LoginContextHolder.get();
					portUpdateLog.setCreatedBy(loginContext.getEmpCode());
					portUpdateLog.setCreateDate(new Date());
					bookPortUpdateLogDao.saveOrUpdate(portUpdateLog);
				}
			}
			salesOrderService.updateEndPortByCode(bookPort, orderCodes);
		}
	}
	
	
	
}
