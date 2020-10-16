/*
 * Powered By [rapid-framework]
 * Web Site: http://www.rapid-framework.org.cn
 * Google Code: http://code.google.com/p/rapid-framework/
 * Since 2008 - 2013
 */

package com.haier.hrois.order.cnt.webapp.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

import com.haier.base.model.DataGrid;
import com.haier.base.model.Json;
import com.haier.hrois.basic.webapp.action.BaseRapidAction;
import com.haier.hrois.datatrans.dao.DbLinkDao;
import com.haier.hrois.datatrans.domain.DbLink;
import com.haier.hrois.datatrans.service.CosmoInfoService;
//import com.haier.hrois.datatrans.service.CosmoInfoService;
import com.haier.hrois.datatrans.service.impl.PLMInterfaceService;
import com.haier.hrois.order.cnt.domain.ActCntItem;
import com.haier.hrois.order.cnt.domain.ActReturnApply;
import com.haier.hrois.order.cnt.query.ActCntItemQuery;
import com.haier.hrois.order.cnt.query.ActCntQuery;
import com.haier.hrois.order.cnt.service.ActCntItemService;
import com.haier.hrois.order.cnt.service.ActReturnApplyService;
import com.haier.hrois.order.confirm.query.SalesOrderQuery;
import com.haier.hrois.order.confirm.service.SalesOrderService;
import com.haier.hrois.order.tmod.service.ActService;
import com.haier.hrois.security.domain.UserGroup;
import com.haier.hrois.security.service.GroupService;
import com.haier.hrois.security.service.UserService;
import com.haier.hrois.util.FtpNasUpload;
import com.haier.openplatform.security.LoginContextHolder;
import com.haier.openplatform.util.SpringApplicationContextHolder;
import com.opensymphony.xwork2.ModelDriven;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
/**
 * @ClassName: ActCntItemAction
 * @Description: Description
 * @date 2018年2月7日 下午5:28:45
 */
@Controller
@Scope("prototype")
public class ActCntItemAction extends BaseRapidAction implements ModelDriven<ActCntItemQuery> {
	private static final long serialVersionUID = 1L;

	@Resource
	private ActCntItemService actCntItemService;
	@Resource
	private ActService actService;
	@Resource
	private UserService userService;
	@Resource
	private CosmoInfoService cosmoInfoService;
	@Resource
	private SalesOrderService salesOrderService;
	@Resource
	private GroupService groupService;
	private ActCntItemQuery actCntItemQuery = new ActCntItemQuery();
	private ActCntItem actCntItem;
	private DataGrid datagrid;
	private List<ActCntItemQuery> actCntItemList = new ArrayList<ActCntItemQuery>();
	private Json json = new Json();
	private String para;
	private List<ActCntQuery> paraActs;
//	private FtpNasUpload ftpNasUpload = new FtpNasUpload();
	private String filename;
	private PLMInterfaceService pLMInterfaceService = SpringApplicationContextHolder.getBean("pLMInterfaceService");
	@Resource
	private DbLinkDao dbLinkDao;
	@Resource
	private ActReturnApplyService actReturnApplyService;
	/** 通过spring自动注入 */
	public void setActCntItemService(ActCntItemService service) {
		this.actCntItemService = service;
	}

	// ---------------------------------------------------------------

	/**
	 * 跳转到装箱明细表管理页面
	 * 
	 * @return
	 */
	public String goActCntItem() {
		return "actCntItem";
	}

	/**
	 * 跳转到查看desc页面
	 * 
	 * @return
	 */
	public String showDesc() {
		actCntItem = actCntItemService.get(actCntItemQuery);
		BeanUtils.copyProperties(actCntItem, actCntItemQuery);
		return "showDesc";
	}

	/**
	 * 获得pageHotel数据表格
	 */
	public String datagrid() {
		datagrid = actCntItemService.datagrid(actCntItemQuery);
		return "datagrid";
	}

	public String listAll() {
		actCntItemList = actCntItemService.findActCntItem(actCntItemQuery.getActCntCode());
		return "actCntItemList";
	}
	
	/**
	 * 根据预编号查询物料个数
	 * @return
	 */
	public String getMaterialNumber() {
		List<String> materialList= actCntItemService.getMaterialByLoadingPlanCode(actCntItemQuery.getActCntCode());
		/*if(materialList!=null && materialList.size()>0){
			json.setObj(materialList.size());
		}else {
			json.setObj("0");
		}*/
		json.setObj(materialList);
		return "materialNumber";
	}
	/**
	 * 从FTP上下载装箱图纸
	 * @return
	 * @throws FileNotFoundException 
	 */
	public InputStream getDownloadFile() {
		//从PLM获取文件名 CA0K79E0M actCntItemQuery.getMaterialSetCode()CE0JGQE0H
		pLMInterfaceService.setDbId("2015081800001860");
		List<String> relativePathList = pLMInterfaceService.getPLMDataByMaterial(actCntItemQuery.getMaterialSetCode());
		String relativePath = relativePathList!=null && relativePathList.size()!=0?relativePathList.get(0):"";
		DbLink dbLink = this.dbLinkDao.getById("2015091400001988");
		String url = dbLink.getServerIp();
		String ftpFileName = dbLink.getDbName();
		//下载FTP文件
		File file = FtpNasUpload.downLoadRegulationFile(url, 21, 
				ftpFileName, relativePath);
		FileInputStream fis = null;
		if(file!=null){
			try {
				filename = file.getName();
				fis = new FileInputStream(file); //获取文件流
				try {
					filename = new String(file.getName().getBytes("GBK"),"ISO-8859-1");
				} catch (UnsupportedEncodingException e) {
					logger.error("编码格式转换失败！"+e.getMessage(), e);
				}
			} catch (FileNotFoundException e) {
				logger.error("文件不存在！"+e.getMessage(), e);
			}
		}else {
			//new String(ff.getName().getBytes("GBK"),"ISO-8859-1")
			filename = "空.txt";
			file = FtpNasUpload.downLoadRegulationFile("10.135.5.1", 21, 
					ftpFileName, filename);
			try {
				filename = new String(file.getName().getBytes("GBK"),"ISO-8859-1");
			} catch (UnsupportedEncodingException e1) {
				logger.error("编码格式转换失败！"+e1.getMessage(), e1);
			}
			try {
				fis = new FileInputStream(file);
			} catch (FileNotFoundException e) {
				logger.error("文件不存在！"+e.getMessage(), e);
			} 
		}
		return fis;
	}
	/**
	 * @Title: downFTPModel
	 * @Description: TODO(这里用一句话描述这个方法的作用)
	 * @return    参数
	 * @return String    返回类型
	 * @throws
	 * @date 2018年2月7日 下午5:29:06
	 */
	public String downFTPModel(){
		return "downfile";
	}
	/**
	 * 获得无分页的所有数据
	 */
	public String combox() {
		actCntItemList = actCntItemService.listAll(actCntItemQuery);
		return "actCntItemList";
	}

	/**
	 * 添加一个装箱明细表
	 */
	public String add() {
		actCntItemService.add(actCntItemQuery);
		json.setSuccess(true);
		json.setObj(actCntItemQuery);
		json.setMsg("添加成功！");
		return SUCCESS;
	}

	/**
	 * 编辑装箱明细表
	 */
	public String edit() {
		actCntItemService.update(actCntItemQuery);
		json.setSuccess(true);
		json.setObj(actCntItemQuery);
		json.setMsg("编辑成功！");
		return SUCCESS;
	}

	/**
	 * 删除装箱明细表
	 */
	public String delete() {
		actCntItemService.delete(actCntItemQuery.getIds());
		json.setSuccess(true);
		return SUCCESS;
	}
   /**
    * 根据装箱预边发送工厂
    * @return
    * @throws Exception
    */
	public String sendPackingFactory() throws Exception {
		List<String> orderCodes = this.actCntItemService.getOrderCodeByLoadingPlanCode(actCntItemQuery.getIds());
		/*String[] codes = orderCodes.toArray(new String[orderCodes.size()]);
		if( actService.findActCountByOrder("factoryDetection", "end", codes) != orderCodes.size() ){
			json.setSuccess(false);
			json.setMsg("该装箱预编下有订单未过首样，不允许发送工厂!");
		}else if( actService.findActCountByOrder("factoryCheck", "end", codes) != orderCodes.size() ){
			json.setSuccess(false);
			json.setMsg("该装箱预编下有订单未过质量合格，不允许发送工厂!");
		}else{
			for (String orderCode : orderCodes){
				this.actCntItemService.sendPackingFactory(orderCode);
			}
			//根据装箱单号传输 给工厂
			 cosmoInfoService.Send(actCntItemQuery.getIds());
		     json.setSuccess(true);
		}*/
		
		for (String orderCode : orderCodes){
			this.actCntItemService.sendPackingFactory(orderCode);
		}
	    json.setSuccess(true);
		
		return SUCCESS;
	}

	   /**
	    * 新箱封号发送SAP
	    * @return
	    * @throws Exception
	    */
		public String updateLoadingBoxCode() throws Exception {
			
			StringBuffer sbResult = new StringBuffer("");
			String empCode = userService.getUserById(LoginContextHolder.get().getUserId()).getEmpCode();
			String ids[] = actCntItemQuery.getIds();
			for(String actCntCode:ids){
				
				String[] actCntCodeArr = new String[]{actCntCode};
				List<String> orderCodes = this.actCntItemService.getOrderCodeByLoadingPlanCode(actCntCodeArr);
				String[] codes = orderCodes.toArray(new String[orderCodes.size()]);
				for (String orderCode : orderCodes){
					JSONObject jsonRtn = this.actCntItemService.updateLoadingBoxCode(orderCode,empCode,actCntCode);
					if("E".equals(jsonRtn.getString("flag"))){
						sbResult.append(jsonRtn.getString("message"));
					}
				}
			}
			if(StringUtils.isNotBlank(sbResult)){
				json.setSuccess(false);
				json.setMsg(sbResult.toString());
			}else{
				json.setSuccess(true);
			}
			return SUCCESS;
		}
		
	/**
	 * @Title: getPackingFromFactory
	 * @Description: TODO(这里用一句话描述这个方法的作用)
	 * @return
	 * @throws Exception    参数
	 * @return String    返回类型
	 * @throws
	 * @date 2018年2月7日 下午5:29:14
	 */
	public String getPackingFromFactory() throws Exception {
		List<String> orderCodes = this.actCntItemService.getOrderCodeByLoadingPlanCode(actCntItemQuery.getIds());
		for (String orderCode : orderCodes) {
			//this.actCntItemService.getPackingFromFactory(orderCode);
			this.actCntItemService.getPackingFromFactory2(orderCode);
		}
		cosmoInfoService.getOrderCodeByLoadingPlanCodes(actCntItemQuery.getIds());
		json.setSuccess(true);
		return SUCCESS;
	}

	/**
	 * author gechao 拆箱
	 */
	public String devanBox() {
		boolean f = true;
		String empCode = userService.getUserById(LoginContextHolder.get().getUserId()).getEmpCode();
	 
		String[] paras = para.split(",");
		for (String p : paras) {
			actCntItemQuery.setActCntCode(p);
			actCntItemList = actCntItemService.listAll(actCntItemQuery);
			for (ActCntItemQuery aq : actCntItemList) {
				SalesOrderQuery soq = new SalesOrderQuery();
				soq.setOrderCode(aq.getOrderNum());
				List<SalesOrderQuery> list = salesOrderService.listAll(soq);
				if(null != list && empCode.equals(list.get(0).getOrderExecManager())){
					f = true;
				}else{
					f = false;
					break;
				}
			}
		}
		if(f){
			actCntItemService.devnBox(paraActs);
			actCntItemService.sendDevanBox(para);
			/**
			 * http请求拆箱接口停用 ,下次启用时间未知
			 */
			//cosmoInfoService.getOrderCodeByLoading(actCntItemQuery.getActCntCode());
			
			json.setMsg("拆箱成功!");
		}else{
			json.setMsg("没有权限对该订单进行拆箱操作!");
		}
		return "actCntItemListJson";
	}
	
	/**
	 * author feng 退货拆箱
	 */
	public String devanBoxReturn() {
		//String empCode = userService.getUserById(LoginContextHolder.get().getUserId()).getEmpCode();
		//根据用户userid查询组
		//验证用户是否有订单主管权限
		List<UserGroup> groups = groupService.getGroupsByUserId(LoginContextHolder.get().getUserId());
		boolean flag = false;
		for(UserGroup ug : groups){
			if(ug.getGroup().getId().toString().equals("1004")){
				flag = true;
				break;
			}
		}							
		if(flag){
			json.setSuccess(true);
			String[] paras = para.split(",");
			boolean audit = false;
			for (String p : paras) {
				actCntItemQuery.setActCntCode(p);
				actCntItemList = actCntItemService.listAll(actCntItemQuery);
				if(actCntItemList==null || actCntItemList.size()<=0){
					json.setSuccess(false);
					json.setMsg("装箱预编号无效!");
					break;
				}
				//验证是否已经审核
				List<ActReturnApply> aras = actReturnApplyService.getByActCntCode(p);
				if(aras!=null && aras.size()>0){
					for(ActReturnApply a : aras){
						if(!("0").equals(a.getAuditFlag())){
							audit = true;
							break;
						}
					}
					if(audit){
						json.setSuccess(false);
						json.setMsg("退货拆箱申请已审核，不能编辑!");
						break;
					}
				}
			}
		}else{
			json.setSuccess(false);
			json.setMsg("没有权限进行退货拆箱操作!");
		}

		return "actCntItemListJson";
	}

	/**
	 * author gechao 拆箱发送标示
	 */
	public String devanBoxFlag() {
		actCntItemService.sendDevanBox(para);
		return "actCntItemListJson";
	}
	
	// --------------------------------------------------------------
	@Override
	public ActCntItemQuery getModel() {
		return actCntItemQuery;
	}
	/**
	 * @Title: getActCntItemQuery
	 * @return
	 */
	public ActCntItemQuery getActCntItemQuery() {
		return actCntItemQuery;
	}
	/**
	 * @Title: setActCntItemQuery
	 * @param actCntItemQuery
	 */
	public void setActCntItemQuery(ActCntItemQuery actCntItemQuery) {
		this.actCntItemQuery = actCntItemQuery;
	}
	/**
	 * @Title: getActCntItem
	 * @return
	 */
	public ActCntItem getActCntItem() {
		return actCntItem;
	}
	/**
	 * @Title: getActCntItemList
	 * @return
	 */
	public List<ActCntItemQuery> getActCntItemList() {
		return actCntItemList;
	}
	/**
	 * @Title: getDatagrid
	 * @return
	 */
	public DataGrid getDatagrid() {
		return datagrid;
	}
	/**
	 * @Title: getJson
	 * @return
	 */
	public Json getJson() {
		return json;
	}
	/**
	 * @Title: getParaActs
	 * @return
	 */
	public List<ActCntQuery> getParaActs() {
		return paraActs;
	}
	@SuppressWarnings("unchecked")
	public void setParaActs(String paraActs) {
		JSONArray ja = JSONArray.fromObject(paraActs);
		this.paraActs = (List<ActCntQuery>) JSONArray.toCollection(ja, ActCntQuery.class);
	}
	/**
	 * @Title: getPara
	 * @return
	 */
	public String getPara() {
		return para;
	}
	/**
	 * @Title: setPara
	 * @param para
	 */
	public void setPara(String para) {
		this.para = para;
	}
	/**
	 * @Title: getFilename
	 * @return
	 */
	public String getFilename() {
		return filename;
	}
	/**
	 * @Title: setFilename
	 * @param filename
	 */
	public void setFilename(String filename) {
		this.filename = filename;
	}

	/**
	 * @param groupService the groupService to set
	 */
	public void setGroupService(GroupService groupService) {
		this.groupService = groupService;
	}

	/**
	 * @param actReturnApplyService the actReturnApplyService to set
	 */
	public void setActReturnApplyService(ActReturnApplyService actReturnApplyService) {
		this.actReturnApplyService = actReturnApplyService;
	}

}
