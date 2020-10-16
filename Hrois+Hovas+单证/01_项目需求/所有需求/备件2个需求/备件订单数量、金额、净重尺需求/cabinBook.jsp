<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head><jsp:include page="/common/check.jsp"></jsp:include>
<jsp:include page="/common/common_js.jsp"></jsp:include>
<style>
<!--
.ro {
	background-color: #eeeded;
}
input,textarea{ 
    border: 1px solid #e7e8ee;
    font-size: 13px;
} 
input,label { vertical-align:middle;} 

.editAble { 
	position: absolute;
	width: 230px;
	height: 100px;
	margin-top: -10px;
	margin-left: -70px;
	overflow: visible;
}
.basic { 
	resize: none;
	height: 20px;
	width: 150px;
	overflow: hidden;
}

-->
</style>

<script src="${staticURL}/scripts/ajaxfileupload_.js"></script>
<script type="text/javascript">
    var params = "";
    var win_oc;
  	//是否存在中标信息标识
	var bidFlag = true;
    var number_editor = {
    		type:'validatebox',
    		options:{
    			required: true,
    			validType:"number['请输入数字']"
    		}
    };
    var zzs_editor = {
    		type:'validatebox',
    		options:{
    			required: true,
    			validType:"zzs['请输入整数']"
    		}
    };
    var zzs_editor2 = {
    		type:'validatebox',
    		options:{
    			required: false,
    			validType:"zzs['请输入整数']"
    		}
    };
    var zzs_editor3 = {
    		type:'validatebox',
    		options:{
    			required: false,
    			validType:"length[0,32]"
    		}
    };
    var zzs_editor4 = {
    		type:'validatebox',
    		options:{
    			required: true,
    			validType:"length[0,1000]"
    		}
    };
    var zzs_editor5 = {
    		type:'validatebox',
			options:{
				required: true,
				validType:"length[0,32]" 
			}	
    };
    $(document).ready(function(){
        $(${codes}).each(function(i,row){
        	params += "codes=" + row + "&";
        });
    	$('#cabinOrder').datagrid({
    		title:'订舱明细',
            url:'${dynamicURL}/bookorder/cabinBookItemAction!datagrid.do?'+params,
			fit : true,
			nowrap : true,
			fitColumns : true,
			singleSelect : true,
			border : false,
			showFooter: true,
            onLoadSuccess: function(){
            	$($('#cabinOrder').datagrid("getRows")).each(function(i,row){
            		$('#cabinOrder').datagrid('beginEdit', i);
            	});
            }, 
			onClickCell : function(index, field, value){
				if(field == "materialCode"){
					window.open('${dynamicURL}/basic/materialCompleteAction!goMaterialComplete.do?completeMaterialCode='+value);
				}
		    },
		    onBeforeEdit : function(idx,row){
		    	//if("5" == row.orderType || "6" == row.orderType || "8" == row.orderType || "9" == row.orderType){
		    	if("8" == row.orderType){
		    		var columnOption = $('#cabinOrder').datagrid('getColumnOption',"goodsAmount"); 
		    		columnOption.editor = zzs_editor;
		    		
		    		//var hsCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"hsCode"); 
		    		//var simpleCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"simpleCode"); 
		    		//备件Hs编码 Hrois简码非必输
		    		//hsCodecolumnOption.editor = zzs_editor2;
 		    		//simpleCodecolumnOption.editor = zzs_editor3;
		    	}
		    	//备件订单、散件订单
		    	//if("5" == row.orderType || "6" == row.orderType || "8" == row.orderType || "9" == row.orderType || "046" == row.orderType){
		    	if("8" == row.orderType || "046" == row.orderType){
		    		var columnOption1 = $('#cabinOrder').datagrid('getColumnOption',"goodsGrossWeight"); 
		    		columnOption1.editor = number_editor;
		    		var columnOption2 = $('#cabinOrder').datagrid('getColumnOption',"goodsMesurement"); 
		    		columnOption2.editor = number_editor;
		    		
		    		var brandColumnOption = $('#cabinOrder').datagrid('getColumnOption',"brand");
		    		var hsCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"hsCode"); 
		    		var simpleCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"simpleCode"); 
		    		brandColumnOption.editor = zzs_editor4;
		    		hsCodecolumnOption.editor = zzs_editor;
		    		simpleCodecolumnOption.editor = zzs_editor5;
		    	}
		    	//整机订单(标准订单、样机订单)
		    	/* if("005" == row.orderType || "047" == row.orderType){
		    		//品牌列、HS编码、HROIS简码信息
		    		var brandColumnOption = $('#cabinOrder').datagrid('getColumnOption',"brand");
		    		var hsCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"hsCode"); 
		    		var simpleCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"simpleCode"); 
		    		brandColumnOption.editor = null;
		    		hsCodecolumnOption.editor = null;
		    		simpleCodecolumnOption.editor = null;
		    	} */
		    	
		    	//2020-06-18  YXB   备件订单       件数、总毛重不允许修改   总体积可以进行修改
		    	if("5" == row.orderType || "6" == row.orderType || "9" == row.orderType){
		    		//数量
		    		/* var columnOption = $('#cabinOrder').datagrid('getColumnOption',"goodsAmount"); 
		    		columnOption.editor = zzs_editor; */
		    		//总毛重
		    		/* var columnOption1 = $('#cabinOrder').datagrid('getColumnOption',"goodsGrossWeight"); 
		    		columnOption1.editor = number_editor; */
		    		//总体积
		    		var columnOption2 = $('#cabinOrder').datagrid('getColumnOption',"goodsMesurement"); 
		    		columnOption2.editor = number_editor;
		    		//品牌
		    		var brandColumnOption = $('#cabinOrder').datagrid('getColumnOption',"brand");
		    		brandColumnOption.editor = zzs_editor4;
		    		//HS编码
		    		var hsCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"hsCode"); 
		    		hsCodecolumnOption.editor = zzs_editor;
		    		//HROIS简码
		    		var simpleCodecolumnOption = $('#cabinOrder').datagrid('getColumnOption',"simpleCode"); 
		    		simpleCodecolumnOption.editor = zzs_editor5;
		    	}
		    	//2020-06-18  YXB   除了备件    其他订单的件数都可维护
		    	if("8" == row.orderType || "005" == row.orderType || "046" == row.orderType || "047" == row.orderType){
		    		//件数
		    		var goodsCountColumnOption2 = $('#cabinOrder').datagrid('getColumnOption',"goodsCount"); 
		    		goodsCountColumnOption2.editor = zzs_editor;
		    	}
		    	
		    },
			columns : [ [ 
			   { field : 'orderCode', title : '订单编号',width : 80}, 
			   { field : 'orderItemCode', title : '行项目号',width : 70},  
			   { field : 'prodTname', title : '产品名称',width : 70}, 
			   { field : 'haierModel',	title : '产品型号',width : 80}, 
			   { field : 'customerModel', title : '客户型号',width : 80}, 
			   { field : 'materialCode', title : '物料号',width : 80 }, 
			   { field : 'brand', title : '品牌',width : 80 /* , editor:{
				   type:'validatebox',
				   options:{
					   required: true,
					   validType:"length[0,1000]" 
				   }
			   } */},
			   { field : 'hsCode', title : 'HS编码', width : 80/* , editor: zzs_editor */}, 
			   { field : 'simpleCode', title : 'HROIS简码', width:80/* , editor:{
				   type:'validatebox',
				   options:{
					   required: true,
					   validType:"length[0,32]" 
				   }
			   } */}, 
			   { field : 'goodsAmount', title : '数量',width : 60, align : "right", editor: null}, 
			   { field : 'unit', title : '单位',width : 40}, 
			   { field : 'goodsCount', title : '件数', width : 60, align : "right", editor: null}, 
			   { field : 'deptName', title : '生产工厂', width:80}, 
			   { field : 'cityName', title : '国家', width:80}, 
			   { field : 'goodsGrossWeight', title : '总毛重(Kg)',width : 70, align : "right", editor: null}, 
			   { field : 'goodsMesurement', title : '总体积(M³)',width : 70, align : "right", editor: null}, 
			   { field : 'marks', title : '唛头', width:120, editor:{
				   type:'validatebox',
				   options:{
					   validType:'length[0,1000]'
				   }
			   }}, 
			   { field : 'goodsDescription', title : '货描', width:120, editor:{
				   type:'validatebox',
				   options:{
					   validType:'length[0,1000]'
				   }
			   }}, 
			   { field : 'mergeCustFlag', title : '报关分组', width:60, editor:{
				   type:'combobox',
				   options:{
					   required : true,
					   editable : true,
					   validType : 'length[2,2]',
					   panelHeight : 100,
					   valueField:'id',
					   textField:'text',
					   data:[
					       {id:"01",text:"01"},
					       {id:"02",text:"02"},
					       {id:"03",text:"03"},
					       {id:"04",text:"04"},
					       {id:"05",text:"05"},
					       {id:"06",text:"06"},
					       {id:"07",text:"07"},
					       {id:"08",text:"08"},
					       {id:"09",text:"09"},
					       {id:"10",text:"10"},
					       {id:"11",text:"11"},
					       {id:"12",text:"12"},
					       {id:"13",text:"13"},
					       {id:"14",text:"14"},
					       {id:"15",text:"15"}
					   ],
					   onSelect : function(data){
						   var idx = $(this).closest(".datagrid-row").attr("datagrid-row-index");
						   var rows = $('#cabinOrder').datagrid("getRows");
						   $(rows).each(function(i,row){
							   if( i != idx ){
								   if( row.orderCode == rows[idx].orderCode ){
									   var ed = $('#cabinOrder').datagrid('getEditor', {index: i,field:'mergeCustFlag'});
									   $(ed.target).combobox('setValue', data.id );
								   }
							   }
						   });
					   }
				   }
			   }}
			 ] ]
		});
    	
		$("#portEndCode").combogrid({
		    url:'${dynamicURL}/basic/portAction!datagrid.action',
			idField:'portCode',  
		    textField:'portName',
			queryParams : {
				portCode : "${bookOrderQuery.portEndCode}"
			},
			panelWidth : 500,
			panelHeight : 240,
			rownumbers : true,
			pagination : true,
			editable : false,
			disabled : ${bookOrderQuery.fareDealType},
			toolbar : '#_PORTEND',
			pageSize : 5,
			pageList : [ 5, 10 ],
			fit : true,
			fitColumns : true,
			columns : [ [ {
				field : 'portCode',
				title : '目的港编码',
				width : 20
			},{
				field : 'portName',
				title : '目的港名称',
				width : 20
			}  ] ]
		}); 

		var shipment=${bookOrderQuery.orderShipment};
		var vendorType='';
		if(shipment=='01'){
			vendorType='0';
		}else if(shipment=='03'){
			vendorType='3';
		}else{
			vendorType='4';
		}
		
		$("#vendorCode").combogrid({
			url:'${dynamicURL}/basic/vendorAction!datagrid.action?vendorType=' + vendorType,
			idField:'vendorCode',  
			textField:'vendorNameCn',
			queryParams : {
				vendorCode : "${bookOrderQuery.vendorCode}"
			},
			panelWidth : 500,
			panelHeight : 240,
			pagination : true,
			editable:false,
			disabled:${bookOrderQuery.bookShippingUpdateJudge},
			toolbar : '#vendorGrid',
			pageSize : 5,
			pageList : [ 5, 10 ],
			fit : true,
			fitColumns : true,
			columns : [ [ {
				field : 'vendorCode',
				title : '船公司编码',
				width : 20
			},{
				field : 'vendorNameCn',
				title : '船公司名称',
				width : 20
			}  ] ],
			onSelect: function(rowIndex, rowData){
				//运输方式
				var orderShipment = $('#orderShipment').val();
				//成交方式
				var orderDealType = $('#orderDealType').val();
				//始发港
				var portStartCode = $('#portStartCode').val();
				//目的港
				var portEndCode = $('#portEndCode').val();
				//出运期
				var bookShipDate = $('#bookShipDate').val();
				//alert(orderShipment+"..."+orderDealType+"..."+portStartCode+"..."+portEndCode+"..."+bookShipDate);
				$.ajax({
	    			url:'${dynamicURL}/bookorder/cabinAgentAction!judgeBidInfoExist.do',
	    			dataType:'json',
	    			data:{
	    				orderShipment : orderShipment,
	    				orderDealType : orderDealType,
	    				portStartCode : portStartCode,
	    				portEndCode : portEndCode,
	    				vendorCode : rowData.vendorCode,
	    				bookShipDate : bookShipDate
	    			},
	    			success:function(data){
	    				if(data.success){
	    					bidFlag = true;
	    					$('#vendorCode').val(rowData.vendorCode);
	    				}else{
	    					bidFlag = false;
	    					$.messager.alert('提示','中标信息不存在，请维护！','info');
	    				}
	    			}
	    		});
			}
		});
    	
    	$(".validate-number").validatebox({ 
    		required: true,
    		validType: 'zzs["请输入正整数"]'  
    	});
    	$(".validate-length").validatebox({ 
    		validType: 'length[0,1000]'  
    	});
    	$(".validate-length30").validatebox({ 
    		validType: 'length[0,30]'  
    	});

    	
    	$("#actContainer").validatebox({ 
    		required: true,
    		validType: "reapet['#planContainer','实际与预算不符']"
    	}); 
    	
    	$('[name="bookSendMan"]').combobox({  
            url:'${dynamicURL}/basic/sysLovAction!combox.do?itemType=SEND_MAN',
	        valueField:'itemNameCn',
	        textField:'itemNameCn',
	        editable:true,
	        required:true,
	    	validType:['length[0,255]'],
	        panelHeight:140,
	        panelWidth:400
	    });
    	
    	$("[name='bookReceiveMan']").validatebox({ 
	    	required: true,
    		validType: 'length[0,255]'  
    	}).hover( function () {
    		$(this).removeClass("basic");
    		$(this).addClass("editAble");
    	},function () {
    		$(this).removeClass("editAble");
    		$(this).addClass("basic");
    	});
    	
    	$("[name='bookNotifyMan']").validatebox({ 
	    	required: true,
    		validType: 'length[0,400]'  
    	}).hover( function () {
    		$(this).removeClass("basic");
    		$(this).addClass("editAble");
    	},function () {
    		$(this).removeClass("editAble");
    		$(this).addClass("basic");
    	});
    	
    	new AjaxUpload('uploadFile', {
	        action: '${dynamicURL}/basic/fileUploadAction/uplaodFile.do',
	        name:'upload',
	        data: {remarks:'appicon'},
	        responseType:'json',
			onSubmit : function(file , ext){
	            // Allow only images. You should add security check on the server-side.
				if (ext == null || /^(exe|bat)$/.test(ext)){				
					// extension is not allowed
					$.messager.alert("系统警告",'非法文件禁止上传！');
					// cancel upload
					return false;				
				}		
			},
			onComplete : function(file,data){
				$("[name='stockNotification']").val(data.obj.id);
				$("#uploadFile").text(file);				
			}		
		});
    	
    	$("[name='stockFlag']").click(function(){
    		if(this.checked){
    			$('[name="upload"]').click();
    		}else{
				$("[name='stockNotification']").val("");
				$("#uploadFile").text("");	
    		}
    	});
    	
    	$("form").form("validate");
    	$("[name='bookCode']").focus();
    	
    	//指定货代
		$('#forwardAgent')
				.combogrid(
						{
							editable : false,
							url : '${dynamicURL}/basic/vendorAction!datagrid.action?vendorType=3',
							idField : 'vendorCode',
							textField : 'vendorNameCn',
							panelWidth : 500,
							panelHeight : 240,
							pagination : true,
							toolbar : '#_FORWARD',
							rownumbers : true,
							pageSize : 5,
							pageList : [ 5, 10 ],
							fit : true,
							fitColumns : true,
							columns : [ [ {
								field : 'vendorCode',
								title : '货代公司编码',
								width : 20
							}, {
								field : 'vendorNameCn',
								title : '货代公司名称',
								width : 20
							} ] ]
						});
	});

	function endEditing(){
		var rlt = true;
		$($('#cabinOrder').datagrid("getRows")).each(function(i,row){
			if ($('#cabinOrder').datagrid('validateRow', i)){
				$('#cabinOrder').datagrid('endEdit', i);
			} else {
				rlt = false;
			}
    	});
		return rlt;
	}
	
	function editCnt(type){
		$("body").append("<div id='winEditCnt'></div>");
		win_oc = $("#winEditCnt").dialog({
			title : "订单箱型箱量",
			width : 500,
			height : 300,
			modal : true,
			href : "${dynamicURL}/bookorder/bookOrderCntAction!goOrderCntList.do?bookCode="+$("[name='bookCode']").val()+"&orderShipment=" + type,
			onClose : function(){
				win_oc.panel("destroy");
			}
		});
	}
	
	function cabinBook(){
		var bookOrderItem = new Array();
		var fobCompanyAgent = $("input[name=fobCompanyAgent]:checked").val();
		var fobCompanyRemarks = $("[name=fobCompanyRemarks]").val();
		var bookGetTimes = $("#bookGetTimes").val();
		//alert(fobCompanyAgent + "................"+fobCompanyRemarks);
		if(fobCompanyAgent == "1" && (fobCompanyRemarks == null || fobCompanyRemarks == '')){
			$.messager.alert('系统提示','请维护FOB船公司备注信息!');  
		}else if(bookGetTimes == '' || bookGetTimes == null){
			$.messager.alert('系统提示','请选择提单类型！','warring');
		}else if(!bidFlag){
			$.messager.alert('提示','中标信息不存在，请维护！','info');
		}else{
			if( $("form").form("validate") && endEditing() ){
			    var bookOrder = $("form").serialize();
			    var bookCode = $("[name='bookCode']").val();
			    var bookOrderItem = new Array();
			    $($("#cabinOrder").datagrid("getRows")).each(function(i,row){
				    bookOrderItem[i] = {
						'orderCode':row.orderCode,
						'orderItemCode':row.orderItemCode,
						'bookCode':bookCode,
						'goodsAmount':row.goodsAmount,
						'goodsCount':row.goodsCount,
						'goodsComment': row.goodsComment,
						'goodsGrossWeight':row.goodsGrossWeight,
						'goodsMesurement':row.goodsMesurement,
						'marks' : row.marks,
						'goodsDescription' : row.goodsDescription,
						'simpleCode' : row.simpleCode,
						'hsCode' : row.hsCode,
						'brand' : row.brand,
						'mergeCustFlag' : row.mergeCustFlag
					};
			    });
				$.messager.progress({text:'系统处理中，请稍等...',interval:200});
				var params  = bookOrder + "&bookOrderItem=" + JSON.stringify(bookOrderItem).encodeURL();
	 		    $.ajax({
				    url: 'cabinBookAction!cabinBook.do',
				    type: 'post',
				    data: params,
				    dataType: 'json',
				    success: function(data){
						$.messager.progress("close");
					    if(data.success){
					    	$.messager.alert("系统提示","订单订舱申请发起成功，订单已进入下一节点！");
						    parent.window.HROS.window.close(currentappid);
						    customWindow.reloaddata();
					    }else{
						    $.messager.alert('系统提示','保存失败!' + data.msg);  
					    }
				    }
			    });
			}
		}
	}
	
	
	function onclickFobCompanyAgent(value){
		if(value == "1"){
			$("#fobCompanyRemarks").show();
		}else{
			$("#fobCompanyRemarks").hide();
		}
	}
	
	
	//模糊查询船公司下拉列表
	function searchVendor() {
		var _CCNCODE = $('#code').val();
		var _CCNTEMP = $('#name').val();

		$("#vendorCode").combogrid({ 
			queryParams : {
				vendorNameCn : _CCNTEMP,
				vendorCode : _CCNCODE
			} 
		});
	}
	//重置查询船公司信息输入框
	function cleanVendor() {
		$('#code').val("");
		$('#name').val("");
		$("#vendorCode").combogrid({ queryParams : {} });
	}
	
	//模糊查询目的港下拉列表
	function _PORTMY() {
		var _CCNCODE = $('#_PORTCODEINPUT').val();
		var _CCNTEMP = $('#_PORTINPUT').val();
		
		$("#portEndCode").combogrid({
			queryParams : {
				portName : _CCNTEMP,
				portCode : _CCNCODE
			}
		});
	}
	//重置查询目的港信息输入框
	function _PORTMYCLEAN() {
		$('#_PORTCODEINPUT').val("");
		$('#_PORTINPUT').val("");
		$("#portEndCode").combogrid({ queryParams : {} });
	}
	
	//指定货代
	function _VENDORMY(inputId, inputName, selectId) {
		var _CCNCODE = $('#' + inputId).val();
		var _CCNTEMP = $('#' + inputName).val();
		$('#' + selectId).combogrid({
			queryParams : {
				vendorNameCn : _CCNTEMP,
				vendorCode : _CCNCODE
			}
		});
	}

	//重置指定货代
	function _VENDORMYCLEAN(inputId, inputName, selectId) {
		$('#' + inputId).val("");
		$('#' + inputName).val("");
		$('#' + selectId).combogrid({
			queryParams : {}
		});
	}
</script>
</head>
<body>
<div class="easyui-layout" data-options="border:false" fit=true style="overflow: auto;">
   <div data-options="region:'north'" style="height:248px" title="订舱主信息">
	  <form>
		<table style="width: 100%; padding: 5px 0px 0px 5px;">
			<tr style="height: 24px;">
				<td width="120px">订舱号:</td>
				<td width="180px">
				<input name="bookCode" class="ro" readonly="readonly" value="${bookOrderQuery.bookCode}" />
				</td>
				<td width="120px">经营主体:</td>
				<td width="180px"><input class="ro" readonly="readonly" value="${bookOrderQuery.operators }" /></td>
				<td width="120px">始发港:</td>
				<td width="180px">
					<input id="portStartCode" name="portStartCode" type="hidden" value="${bookOrderQuery.portStartCode }"/>
					<input class="ro" readonly="readonly" value="${bookOrderQuery.portStartNameEn }" />
				</td>
				<td width="120px">目的港:</td>
				<td width="180px">
				   <input id="portEndCode" name="portEndCode" value="${bookOrderQuery.portEndCode }" />
				</td>
			</tr>
			<tr style="height: 24px;">
				<td>订舱人:</td>
				<td><input class="ro" readonly="readonly"  value="${bookOrderQuery.createdBy}" /></td>
				<td>发货人:</td>
				<td>
				<!--  <textarea name="bookSendMan" class="basic" style="resize: none">HAIER ELECTRICAL APPLIANCES CORP.LTD., HAIER INDUSTRIAL PARK,NO.1 HAIER ROAD QINGDAO, P.R.CHINA</textarea>-->
					<textarea name="bookSendMan" class="basic" style="resize: none">${bookOrderQuery.bookSendMan }</textarea>
				</td>
				<td>收货人:</td>
				<td><textarea name="bookReceiveMan" class="basic" style="resize: none">${bookOrderQuery.bookReceiveMan }</textarea></td>
				<td>通知人:</td>
				<td><textarea name="bookNotifyMan" class="basic" style="resize: none">${bookOrderQuery.bookReceiveMan }</textarea></td>
			</tr>
			<tr style="height: 24px;">
				<td>成交方式:</td>
				<td><input class="ro" id="orderDealType" name="orderDealType" readonly="readonly" value="${bookOrderQuery.orderDealName }" /></td>
				<td>运输方式:</td>
				<td>
					<input id="orderShipment" name="orderShipment" type="hidden" value="${bookOrderQuery.orderShipment }"/>
					<input class="ro" readonly="readonly" value="${bookOrderQuery.orderShipmentName }" />
				</td>
				<td>运输公司:</td>
				<td>
				     <input id="vendorCode" name="vendorCode" value="${bookOrderQuery.vendorCode }" /> 
				</td>
				<td>代理公司:</td>
				<td><input class="ro" readonly="readonly" /></td>
			</tr>
			<tr>
				<td>启运日期:</td>
				<td><input id="bookShipDate" name="bookShipDate" class="ro" readonly="readonly" value="${bookOrderQuery.bookShipDateStr }" /></td>
				<td>要求到货期:</td>
				<td><input class="ro" readonly="readonly" value="${bookOrderQuery.orderCustomDateStr }" /></td>
				<td>提单类型:</td>
				<td>
					<select id="bookGetTimes" name="bookGetTimes" style="width:150px;">
						<option value="" ></option>
						<option value="正本提单" >正本提单</option>
						<option value="电放提单" >电放提单</option>
						<option value="SWB" >SWB</option>
						<option value="FCR" >FCR</option>
						<option value="其他" >其他</option>
					</select>
				</td>
				<td>入货通知单:</td>
			    <td>
			        <input name="stockFlag" type="checkbox" style="margin-left: -3px;" value="1"/>
           		    <input name="stockNotification" type="hidden" style="vertical-align: middle;"/>
           		    <span id="uploadFile" style="vertical-align: middle;" ></span>
			    </td>
			</tr>
			<tr style="height: 24px;">
			    <s:if test="%{bookOrderQuery.orderShipment == \"01\"}">
				<td>预算箱型箱量:</td>
				<td><input id="planContainer" type="text" class="ro" value="${bookOrderQuery.container}" readonly="readonly"/></td>
				<td>实际箱型箱量:</td>
				<td>
				    <input id="actContainer" type="text" class="ro" value="${bookOrderQuery.cntContainer}" readonly="readonly"/>
				    <a id="editCnt" href="javascript:editCnt('01');" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon-mini-edit'"></a>
				</td>
				</s:if>
				
				<s:if test="%{bookOrderQuery.orderShipment == \"03\"}">
				<td>预算箱型箱量:</td>
				<td><input id="planContainer" type="text" class="ro" value="${bookOrderQuery.container}" readonly="readonly"/></td>
				<td>实际箱型箱量:</td>
				<td>
				    <input id="actContainer" type="text" class="ro" value="${bookOrderQuery.cntContainer}" readonly="readonly"/>
				    <a id="editCnt" href="javascript:editCnt('01');" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon-mini-edit'"></a>
				</td>
				</s:if>
				
				<s:if test="%{bookOrderQuery.orderShipment == \"02\"}">
				<td>SAP总运费:</td>
				<td><input id="planContainer" type="text" class="ro" value="${bookOrderQuery.container}" readonly="readonly"/></td>
				<td>实际总运费:</td>
				<td>
				    <input id="actContainer" type="text" class="ro" value="${bookOrderQuery.cntContainer}" readonly="readonly"/>
				    <a id="editCnt" href="javascript:editCnt('02');" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon-mini-edit'"></a>
				</td>
				</s:if>
				<s:if test="bookOrderQuery.orderType == '005' or bookOrderQuery.orderType == '046' or bookOrderQuery.orderType == '047' ">
				<td>关联备件订舱</td>
				<td><input name="waitCabin" type="checkbox" style="margin-left: -3px;" value="1"/></td>
				</s:if>
				<s:if test="bookOrderQuery.orderDealType == 'FOC' or bookOrderQuery.orderDealType == 'FAC' or bookOrderQuery.orderDealType == 'FCA' or bookOrderQuery.orderDealType == 'FAS' or bookOrderQuery.orderDealType == 'EXW' or bookOrderQuery.orderDealType == 'FOB'  or bookOrderQuery.orderDealType == 'FTC'">
				<td>
					<p>指定货代:</p>
					<s:if test="bookOrderQuery.orderDealType == 'FOB'">
					<p style="margin-top: 5px;">指定货代联系方式:</p>
					</s:if>
				</td>
				<td>
					<p><input id="forwardAgent_" name="forwardAgent"/></p>
					<s:if test="bookOrderQuery.orderDealType == 'FOB'">
					<p style="margin-top: 5px;"><input id="forwardAgentContact" name="forwardAgentContact"/></p>
					</s:if>
				</td>
				</s:if>
			</tr>

			<s:if test="bookOrderQuery.orderDealType == 'FOB'">
				<tr style="height: 24px;">
					<td>FOB船公司:&nbsp&nbsp<input name="fobCompanyAgent" type="radio" value="1" checked onclick="onclickFobCompanyAgent(1)"/></td>
					<td><input id="fobCompanyRemarks" name="fobCompanyRemarks" style="display:"/></td>
					<td>FOB货代:&nbsp&nbsp<input name="fobCompanyAgent" type="radio" value="2" onclick="onclickFobCompanyAgent(2)"/></td>
				</tr>
			</s:if>

			<tr>
				<td height="65">装箱/订舱说明:</td>
				<td colspan="3"><textarea class="validate-length" style="height: 60px; width: 492px;" name="bookComments"></textarea></td>
				<td>提单用货物描述:</td>
				<td colspan="3"><textarea class="validate-length" style="height: 60px; width: 492px;" name="bookGetComments"></textarea></td>
			</tr>
			<tr>
				<td>码头信息:</td>
				<td><input class="ro" readonly="readonly" value="${bookOrderQuery.duck }" /></td>
			</tr>
		</table>
		</form>
	</div>
	<div data-options="region:'center'" style="height:200px;width: 100%;">
		  <table id="cabinOrder"></table>
	</div>
	<div data-options="region:'south',split:false,border:false" style="height: 30px; text-align: right;">
		<div>
			<a href="#" class="easyui-linkbutton" onclick="javascript:cabinBook();" data-options="iconCls:'icon-save'">确认订舱</a>
		</div>
	</div>
</div>


<!-- 目的港下拉选信息 -->
<div id="_PORTEND">
	<div class="oneline">
		<div class="item25">
			<div class="itemleft100">目的港编号：</div>
			<div class="righttext">
				<input class="short50" id="_PORTCODEINPUT" type="text" />
			</div>
		</div>
		<div class="item25">
			<div class="itemleft100">目的港名称：</div>
			<div class="righttext">
				<input class="short50" id="_PORTINPUT" type="text" />
			</div>
		</div>
	</div>
	<div class="oneline">
		<div class="item25">
			<div align="right">
				<input type="button" value="查询" onclick="_PORTMY()" />
			</div>
		</div>
		<div class="item25">
			<div class="lefttext">
				<input type="button" value="重置" onclick="_PORTMYCLEAN()" />
			</div>
		</div>
	</div>
</div>
<!-- 船公司下拉选信息 -->
<div id="vendorGrid">
	<div class="oneline">
	     <div class="item25">
			<div class="itemleft100">船公司编号：</div>
			<div class="righttext">
				<input class="short50" id="code" type="text" />
			</div>
		</div>
		<div class="item25">
			<div class="itemleft100">船公司名称：</div>
			<div class="righttext">
				<input class="short50" id="name" type="text" />
			</div>
		</div>
	</div>
	<div class="oneline">
		<div class="item25">
			<div align="right">
				<input type="button" value="查询" onclick="searchVendor()" />
			</div>
		</div>
		<div class="item25">
			<div class="lefttext">
				<input type="button" value="重置" onclick="cleanVendor()" />
			</div>
		</div>
	</div>
</div>

<!-- 指定货代下拉选信息 -->
	<div id="_FORWARD">
		<div class="oneline">
			<div class="item25">
				<div class="itemleft100">货代公司编号：</div>
				<div class="righttext">
					<input class="short50" id="_VENDORCODE" type="text" />
				</div>
			</div>
			<div class="item25">
				<div class="itemleft100">货代公司名称：</div>
				<div class="righttext">
					<input class="short50" id="_VENDORNAME" type="text" />
				</div>
			</div>
		</div>
		<div class="oneline">
			<div class="item25">
				<div align="right">
					<input type="button" value="查询"
						onclick="_VENDORMY('_VENDORCODE','_VENDORNAME','forwardAgent')" />
				</div>
			</div>
			<div class="item25">
				<div class="lefttext">
					<input type="button" value="重置"
						onclick="_VENDORMYCLEAN('_VENDORCODE','_VENDORNAME','forwardAgent')" />
				</div>
			</div>
		</div>
	</div>
</body>
</html>
