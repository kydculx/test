<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>

<%
	request.setCharacterEncoding("EUC_KR");

	String serviceId = request.getParameter("SERVICE_ID");
	String serviceCode = request.getParameter("SERVICE_CODE");
	String orderId = request.getParameter("ORDER_ID");
	String orderDate = request.getParameter("ORDER_DATE");
	String responseCode = request.getParameter("RESPONSE_CODE");
	String responseMessage = request.getParameter("RESPONSE_MESSAGE");
	String detailResponseCode = request.getParameter("DETAIL_RESPONSE_CODE");
	String detailResponseMessage = request.getParameter("DETAIL_RESPONSE_MESSAGE");
	String payMessage = request.getParameter("PAY_MESSAGE");
	
	/*���� ��û URL ����*/
	String webApiUrl = "https://twebapi.billgate.net:10443/webapi/approve.jsp"; //�׽�Ʈ ���� �� 
	//String webApiUrl = "https://webapi.billgate.net:8443/webapi/approve.jsp";  //��� ���� ��

	if(serviceId == null || serviceCode == null || orderId == null || orderDate == null || responseCode == null){
		responseMessage = "���� ��� �Ķ���� ����";
		detailResponseMessage = "RETURN_URL�� ���� �ٶ��ϴ�.";
	}

%>

<!--	�����þ� �Ӵ�Ʈ�� ����â�� ���� ���� ���� ���� �� ���� ��û�� �����ϴ� ������
		HTTP �������� ����� �̿��� ���� ��û�� �ش� ������ó�� Ŭ���̾�Ʈ ������ �ݵ�� ����� �ʿ�� ������ ������ ���� �ʿ信 ���� WEB �������� HTTP ��û ����
		������ �⺻ ������ ���� �� ���� ���� ����Ʈ ������ ���� ���� ����
		���� ���ܺ� �Ķ���� ���� �԰��� ������ �޴��� 4.2 ���� ��û/���� ������ ����
-->

<!DOCTYPE html>
<html>
<head>
<title></title>
<style>
	body, tr, td {font-size:9pt; font-family:�������,verdana; }
	div {width: 98%; height:100%; overflow-y: auto; overflow-x:hidden;}
</style>
<meta charset="EUC-KR">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
<title>Insert title here</title>
</head>

<script language="JavaScript">

	//���� ��û
	function ajaxSubmit(){
		var HForm = document.payment;
		
		var xhr = new XMLHttpRequest();
		var data =	"SERVICE_CODE=" + document.getElementsByName("SERVICE_CODE")[0].value + 
					"&SERVICE_ID=" + document.getElementsByName("SERVICE_ID")[0].value + 
					"&ORDER_ID=" + document.getElementsByName("ORDER_ID")[0].value + 
					"&ORDER_DATE=" + document.getElementsByName("ORDER_DATE")[0].value + 
					"&PAY_MESSAGE=" + document.getElementsByName("PAY_MESSAGE")[0].value;
	
		//Ajax ���
		xhr.onload = function(){
			if(xhr.readyState == 4 && xhr.status == 200){ //��� ���� ��				
				console.log(xhr.responseText);
				var respData = JSON.parse(xhr.responseText.trim());
				document.getElementById("auth_serviceId").innerHTML = respData.SERVICE_ID;
				document.getElementById("auth_serviceCode").innerHTML = respData.SERVICE_CODE;
				document.getElementById("auth_orderId").innerHTML = respData.ORDER_ID;
				document.getElementById("auth_orderDate").innerHTML = respData.ORDER_DATE;
				document.getElementById("auth_transactionId").innerHTML = respData.TRANSACTION_ID;
				document.getElementById("auth_cancelKey").innerHTML = respData.CANCEL_KEY;
				document.getElementById("auth_authDate").innerHTML = respData.AUTH_DATE;
				document.getElementById("auth_authAmount").innerHTML = respData.AUTH_AMOUNT;
				document.getElementById("auth_responseCode").innerHTML = respData.RESPONSE_CODE;
				document.getElementById("auth_responseMessage").innerHTML = respData.RESPONSE_MESSAGE;
				document.getElementById("auth_detailResponseCode").innerHTML = respData.DETAIL_RESPONSE_CODE;
				document.getElementById("auth_detailResponseMessage").innerHTML = respData.DETAIL_RESPONSE_MESSAGE;
			}
		};
		
		xhr.open("POST","<%=webApiUrl%>",true);
		xhr.setRequestHeader('Accept','application/x-www-form-urlencoded xml');
		xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=EUC-KR');
		xhr.setRequestHeader('Accept-language','gx');
		xhr.send(data);
	}
	
</script>
<body>
	<div>
		<table width="380px" border="0" cellpadding="0"	cellspacing="0">
		<tr> 
			<td height="25" style="padding-left:10px" class="title01"># ������ġ &gt;&gt; �����׽�Ʈ &gt; <b>������ Return Url</b></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td align="center">
				<table width="380" border="0" cellpadding="4" cellspacing="1" bgcolor="#B0B0B0">
					<tr>
						<td><b>�������</b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������ ���̵�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; 
							<input name="SERVICE_ID" type="text" size=30 value="<%=serviceId%>">
						</td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; 
							<input name="SERVICE_CODE" type="text" size=30 value="<%=serviceCode%>">
						</td>
					</tr>
						<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ���ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; 
							<input name="ORDER_ID" type="text" size=30 value="<%=orderId%>">
						</td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ��Ͻ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; 
							<input name="ORDER_DATE" type="text" size=30 value="<%=orderDate%>">
						</td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; <%=responseCode%></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; <%=responseMessage%></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�� ���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; <%=detailResponseCode%></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�� ���� �޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; <%=detailResponseMessage%></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>PAY_MESSAGE</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp; 
							<input name="PAY_MESSAGE" type="text" size=30 value="<%=payMessage%>">
						</td>
					</tr>
					<tr>
						<td align="center" bgcolor="#FFFFFF" colspan="2">
							<input type="button" value="���� ��û" onclick="javascript:ajaxSubmit();"/>
						</td>
					</tr>
				
					<tr>
						<td><b>���ΰ��</b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������ ���̵�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_serviceId"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_serviceCode"></td>
					</tr>
						<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ���ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_orderId"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ��Ͻ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_orderDate"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ŷ���ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_transactionId"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���Ű</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_cancelKey"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����Ͻ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_authDate"></td>
					</tr>				
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���αݾ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_authAmount"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_responseCode"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_responseMessage"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�� ���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_detailResponseCode"></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�� ���� �޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF" id = "auth_detailResponseMessage"></td>
					</tr>
				</table>
			</td>
		</tr>
		</table>
	</div>
</body>

</html>