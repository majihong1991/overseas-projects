/*
 * Powered By [rapid-framework]
 * Web Site: http://www.rapid-framework.org.cn
 * Google Code: http://code.google.com/p/rapid-framework/
 * Since 2008 - 2013
 */

package com.haier.hrois.order.cnt.service;

import java.util.List;
import java.util.Map;
import net.sf.json.JSONObject;
import com.haier.base.model.DataGrid;
import com.haier.hrois.order.cnt.domain.ActCntItem;
import com.haier.hrois.order.cnt.domain.ComoUp;
import com.haier.hrois.order.cnt.query.ActCntItemQuery;
import com.haier.hrois.order.cnt.query.ActCntQuery;

public interface ActCntItemService {

	/**
	 * 获得数据表格
	 * 
	 * @param bug
	 * @return
	 */
	public DataGrid datagrid(ActCntItemQuery actCntItemQuery);

	/**
	 * 添加
	 * 
	 * @param actCntItemQuery
	 */
	public ActCntItem add(ActCntItemQuery actCntItemQuery);
	
	/** 
	* @Description: 根据主键删除装箱明细
	* @author 韩建效 hanjianxiao@jbinfo.cn 
	* @date 2016-7-27 下午4:04:35 
	* @param actCntItemCode  
	*/ 
	public void deleteByActcntItemCode(String actCntItemCode);
	
	/**
	 * @author zhangjk
	 * @2013-8-30
	 * @description 添加
	 * @param actCntItemQuery
	 * @return
	*/
	public ActCntItem addCntItem(ActCntItemQuery actCntItemQuery);

	/**
	 * 修改
	 * 
	 * @param actCntItemQuery
	 */
	public void update(ActCntItemQuery actCntItemQuery);
	
	/**
	 * @author zhangjk
	 * @2013-8-30
	 * @description 修改
	 * @param orderCode
	 * @return 
	*/
	public int deleteActItem(String orderCode);

	/**
	 * 删除
	 * 
	 * @param ids
	 */
	public void delete(java.lang.String[] ids);

	/**
	 * 获得
	 * 
	 * @param ActCntItem
	 * @return
	 */
	public ActCntItem get(ActCntItemQuery actCntItemQuery);

	/**
	 * 获得
	 * 
	 * @param obid
	 * @return
	 */
	public ActCntItem get(String id);

	/**
	 * 获取所有数据
	 */
	public List<ActCntItemQuery> listAll(ActCntItemQuery actCntItemQuery);

	/**
	 * 通过装箱预编号获得装箱明细
	 * 
	 * @param loadingPlanCode
	 * @return
	 */
	public List<ActCntItemQuery> findActCntItem(String loadingPlanCode);
	
	/**
	 * 根据预编号查询物料个数
	 * @param loadingPlanCode
	 * @return
	 */
	public List<String> getMaterialByLoadingPlanCode(String loadingPlanCode);
		
	/**
	 * 装箱信息发送工厂 1.根据装箱预编号抓取订单编码 2.通过订单编码抓取DbLink 3.通过装箱预编号、订单号抓取 发送信息
	 * 4.向服务器发送信息（更新/新增）
	 * 
	 * @param loadingPlanCode
	 * @return
	 */
	public void sendPackingFactory(String orderCode);

	/**
	 * 从工厂获取装箱信息
	 * 
	 * 1.通过装箱预编号抓取订单号 2.通过订单号查询每个订单生产工厂服务器连接信息
	 * 3.通过装箱明细ID抓取生产工厂已扫描数量跟新Hrois系统装箱明细表已扫描数量字段
	 * 
	 * @param orderCode
	 * @param packingPlanCode
	 * @param serverId
	 * @return
	 */
	public Boolean getPackingFromFactory(String orderCode) throws Exception;
	/**
	 * 装箱信息 获取完成后更新数据
     */
	public Boolean getPackingFrom(ComoUp parse);
	/**
	 * 获取已发送工厂，但未完成装箱活动的装箱预编号
	 * 
	 * @return
	 */
	public List<ActCntItem> getNoScanOkOrderCode();

	/**
	 * 获取已发送工厂，单位完成装箱获得的装箱预算明细
	 * 
	 * @return
	 */
	// public List<ActCntItemQuery> getNoScanOkCntItem();

	/**
	 * 获取已分配总数量 author gechao
	 */
	public Long getTotalNum(ActCntItemQuery query);

	/**
	 * @author guomm
	 * @param orderCode
	 * @return
	 * @description 通过订单编码查询装箱预算明细
	 */
	public List<ActCntItem> getCntItemByOrderCode(String orderCode);

	public Integer updActCntItemScanQuantity(ActCntItem actCntItem);

	public List<String> getLoadingPlanCodeByOrderCode(String orderCode);

	public List<String> getOrderCodeByLoadingPlanCode(String[]loadingPlanCode);

	/**
	 * @author zhangjk
	 * @2013-8-6
	 * @description 根据标准箱方案号、集装箱序号、订单号查询装箱明细所需要的数据
	 * @param query
	 * @return
	 */
	public List<ActCntItemQuery> listActCntItem(ActCntItemQuery query);

	/**
	 * @author
	 * @description 拆箱删数据
	 */
	public void deleteByActcntCode(String actcntCode);
	public String devnBox(List<ActCntQuery> paraActs);
	public List<ActCntItem> getByActcntCode(String actCntCode);
	public void deleteByOrderCode(String orderCode);
	public Integer sendDevanBox(String orderCode);
	
	public List<String> getTaskDefKeyList(String orderCode);
	
	/**
	 * @author gechao 通过订单编码获得流程ID
	 * @param orderCode
	 * @return
	 */
	public List<String> getProcessIdByOrderCode(String orderCode);
	
	/**
	 * @author gechao 发送邮箱查询
	 * @param orderCode
	 * @return
	 */
	public List<String> getEmailByActCntCode(String code);
	
	/**
	 * @author gechao 根据订单号和装箱预编号查询 数量
	 * @param orderNum actcntCode 
	 * @return
	 */
	public long getSumNumberByOrderCode(ActCntItemQuery actCntItemQuery);
	/**
	 * 
	* @Description: 获取胶州空调二期散件订单条码传到iMES
	* @author Wang Yanan   
	* @date 2016-8-19 下午4:47:43 
	* @return
	 */
	public void sendUTD();

	public List<String> getOrderCodeByLoadingPlan(String cntBagCode);
    /**
     * 根据箱号查询所有数据
     * @param cntBagCode
     */
	public List<ActCntItem> getCntBagCode(String cntBagCode);

	/**
	 * 
	 * @Title: devnBoxReturn
	 * @Description: 退货拆箱
	 * @param paraActs
	 * @return 
	 * @date 2018年11月21日
	 */
	public String devnBoxReturn(Map<String,String> paraActs);

	/** 
	 * 查询装箱预编是否已经copy
	 * @Title: getReturnByPlanCode
	 * @Description: TODO(用一句话描述该方法做什么)
	 * @param planCode
	 * @return 
	 * @date 2018年12月25日
	*/
	public boolean getReturnByPlanCode(String planCode);
	
	public JSONObject updateLoadingBoxCode(String orderCode,String empCode,String actCntCode);
	
	public Boolean getPackingFromFactory2(String orderCode) throws Exception;

	
	/**
	 * 备件订单随整机装箱扫描发货
	 * 更新整机装箱信息，关联备件订单
	 * 2020-03-24  YXB
	 * @param actCntItemQuery
	 */
	public void updateAttachOrder(ActCntItemQuery actCntItemQuery);
	
	
	/**
	 * 备件订单随整机装箱扫描发货
	 * 根据备件订单号查询关联装箱的并且已经发送工厂的整机订单号
	 * 2020-03-24  YXB
	 * @param actCntItemQuery
	 */
	public List<String> selectOrderLoadingStatus(String attachOrder);
	
	
	/**
	 * 备件订单随整机装箱扫描发货
	 * 2020-03-24
	 * 清除之前关联的整机订单装箱信息，更新WMS装箱预算信息
	 * @param attachOrder
	 */
	public void dealLoadingAttachOrder(String attachOrder);
	
	
}
