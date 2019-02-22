﻿<#assign base=request.contextPath />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
	
	<div class="easyui-layout" data-options="fit:true">
		<div data-options="region:'north', height:100">
		<#-- 条查 -->
		用户姓名:<input id="list_name" class="easyui-textbox">	
		<a onclick="userSearch()" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-search'">搜索</a>
		</div>
		<div data-options="region:'center'">
		<#-- 声明数据表格容器 -->
		<table id="table_dg"></table>
		</div>
	</div>

<script type="text/javascript">


	//用户名称下拉展示
	$('#list_name').combogrid({
		panelWidth:450,
		idField:'userName',
		textField:'userName',
		url:'${base}/user/queryUserInfo',
		//开启分页
		pagination:true,
		//可选每页条数
		pageList:[3,6,9],
		//每页条数
		pageSize:3,
		//列属性
		columns:[[
		{field:'user_XX',checkbox:true},
	        {field:'userId',title:'用户编号'},    
	        {field:'userName',title:'用户姓名'}, 
	        {field:'userPhone',title:'用户手机号'},
	        {field:'userAge',title:'用户年龄'},
	        {field:'userSex',title:'用户性别'},
	        
	    ]],
	});
	

	//初始化数据表格
	$("#table_dg").datagrid({
		//数据接口
		url:"${base}/user/queryUserInfo",
		//开启分页
		pagination:true,
		//可选每页条数
		pageList:[3,6,9],
		//每页条数
		pageSize:3,
		//分页工具栏位置
		//pagePosition:'bottom',
		//自适应窗口大小
		fit:true,
		//只能选一条
		//singleSelect:true,
		//按ctrl键多选
		ctrlSelect:true,
		//列属性
		columns:[[
		{field:'user_XX',checkbox:true},
	        {field:'userId',title:'用户编号'},    
	        {field:'userName',title:'用户姓名'}, 
	        {field:'userAge',title:'用户年龄'},
	        {field:'userSex',title:'用户性别', width:80, formatter:function(v, r, i) {
	        	if (1 == v) {
	        		return "男";
	        	}
	        	if (2 == v) {
	        		return "女";
	        	}
	        }},
	        {field:'userPhone',title:'用户手机号'},
	    ]],
	    //工具栏
	    toolbar: [{
		text:"添加",
			iconCls: 'icon-add',
			handler: function(){openAdd()}
		},'-',{
			text:"修改",
			iconCls: 'icon-edit',
			handler: function(){openEdit()}
		
		},'-',{
			text:"删除",
			iconCls: 'icon-remove',
			handler: function(){openDel()}
		
		}]
	});

	//用户搜索
	function userSearch(searchType) {
		var list_name = $("#list_name").textbox("getValue");
		
		
		var paramJson = {
			userName:list_name,
			
		};
		
		if (null == searchType) {
		searchType = "load";
		}
		//调用搜索方法
		$("#table_dg").datagrid(searchType, paramJson);
	}
	
	//打开添加用户对话框
	function openAdd() {
		var add_dialog = $("<div></div>").dialog({
			title:"添加用户",
			width:800,
			height:560,
			modal:true,
			href:"${base}/user/toUserAdd",
			onClose:function() {
				add_dialog.dialog("destroy");
			},
			buttons:[{
				text:'保存',
				handler:function(){
					//把数据进行同步
					data_sync();
					//ajax提交表单
					$('#add_form').form('submit', {
						url:"${base}/user/insertUserInfo",
						novalidate:true,
					    success: function(data){ 
					    	//回掉函数中关闭对话框   
					        add_dialog.dialog("destroy");
					        //刷新datagrid列表
					        userSearch();
					    }    
					});
				}
			},{
				text:'关闭',
				handler:function(){
					add_dialog.dialog("destroy");
				}
			}]
		});
	}
	
	//打开编辑用户对话框
	function openEdit() {
		//是否选中了数据
		var selected_edit_array = $("#table_dg").datagrid("getSelections");
		if (1 == selected_edit_array.length) {
			var userId = selected_edit_array[0].userId;
			var edit_dialog = $("<div></div>").dialog({
				title:"编辑用户",
				width:800,
				height:560,
				modal:true,
				href:"${base}/user/toEdit?userId=" + userId,
				onClose:function() {
					edit_dialog.dialog("destroy");
				},
				buttons:[{
					text:'保存',
					handler:function(){
						
						//ajax提交表单
						$('#edit_form').form('submit', {
							url:"${base}/user/updateUserInfo",
						    success: function(data){ 
						    	//回掉函数中关闭对话框   
						        edit_dialog.dialog("destroy");
						        //刷新datagrid列表
						       userSearch("reload");
						    }    
						});
					}
				},{
					text:'关闭',
					handler:function(){
						edit_dialog.dialog("destroy");
					}
				}]
			});
		} else {
			$.messager.alert('提示', '请编辑一条数据！');
		}
	}
	//关闭
	function tabsClose() {
		var tab = $('#tt').tabs("getSelected");
		var index = $('#tt').tabs("getTabIndex", tab);
		$('#tt').tabs("close", index);
	}


	//批量删除
	function openDel() {
		//是否选中了数据
		var selected_delete_array = $("#table_dg").datagrid("getSelections");
		var count = selected_delete_array.length;
		if (0 == selected_delete_array.length) {
			$.messager.alert("提示", "请至少选中一条数据！");
		} else {
			$.messager.confirm("确认","您确认想要删除这"+count+"个用户吗？",function(r){    
			    if (r){    
			        //删除操作
			        var userIds = "";
			        for (var i = 0; i < selected_delete_array.length; i++) {
			        	userIds += "," + selected_delete_array[i].userId;
			        }
			        if (0 < userIds.length) {
			        	userIds = userIds.substr(1);
			        }
			        $.ajax({
			        	url:"${base}/user/deleteUser",
			        	data:{userIds:userIds},
			        	type:"post",
			        	success:function(data) {
			        		userSearch();
			        	}
			        });
			    }    
			});
		}
	}
	
</script>
</body>
</html>