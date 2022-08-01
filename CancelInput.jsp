<%@ page contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%@ page import="java.util.* "%>    

<%
	/*-------------------------------------------------------------------------------------
	�ش� �������� ������Ʈ ���� �׽�Ʈ�� ���� "��� ��û �Է�" ������ �Դϴ�.
		�� ������ ȯ�濡 �°� cancelUrl ���� �ʿ�

		�� ��� ��ȯ �� �������
		1. ��������(SERVICE_ID) ���� -> ��� �� �߱� �� SERVICE_ID ���� �Է�
		2. config.ini Key, Iv ���� (������ ������ ���ο��� Ȯ�� ����)
		3. config.ini mode = 1 ���� (��� ��� ����)

		- ��� �׽�Ʈ�� ���� ��Ұ� �̷����� �� �����Ͻñ� �ٶ��ϴ�.
	-------------------------------------------------------------------------------------*/

	//��¥���� ���� 
	Calendar today = Calendar.getInstance(); 
	String year = Integer.toString(today.get(Calendar.YEAR));
	String month = Integer.toString(today.get(Calendar.MONTH)+1);
	String date = Integer.toString(today.get(Calendar.DATE));
	String hour = Integer.toString(today.get(Calendar.HOUR_OF_DAY));
	String minute = Integer.toString(today.get(Calendar.MINUTE));
	String second = Integer.toString(today.get(Calendar.SECOND));
		
	if(today.get(Calendar.MONTH)+1 < 10) month = "0" + month ;
	if(today.get(Calendar.DATE) < 10) date = "0" + date ;
	if(today.get(Calendar.HOUR_OF_DAY) < 10) hour = "0" + hour ;
	if(today.get(Calendar.MINUTE) < 10) minute = "0" + minute ;
	if(today.get(Calendar.SECOND) < 10) second = "0" + second ;

	//================================================
	// 1. ������ ���� ��û �׽�Ʈ ���� ����
	//================================================
	String serviceId			="glx_api";				//�׽�Ʈ ���̵� �Ϲݰ��� : glx_api, �� �ڵ� ���� : glx_at 	
	String orderDate		= year+month+date+hour+minute+second ;
	String orderId			="cancel_"+orderDate;
	String cancelUrl			="http://127.0.0.1/BillgatePay-JSP/CancelReturn.jsp";  // *������ ���� �ʼ�

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>������Ʈ ���� �׽�Ʈ ����������</title>
<script>
	
	//==========================
	// ���� ��� ��û
	//==========================
	function requestCancel(){
		var HForm = document.cancel;
		var serviceCode = HForm.SERVICE_CODE.options[HForm.SERVICE_CODE.selectedIndex].value;
		var transactionId = HForm.TRANSACTION_ID.value;

		if("" == serviceCode){
			alert("���������� �������ּ���.");
			return;
		}

		if("" == transactionId) {
			alert("�ŷ���ȣ�� �Է����ּ���.");
			return;
		}

		var HForm = document.cancel;
		var option ="width=400,height=600,titlebar=no,fullscreen=no,toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=no,left=50,top=50";
		var objPopup = window.open("", "cancel", option);
		
		HForm.target="cancel";
		HForm.action= HForm.CANCEL_URL.value;
		HForm.submit();
	}
	

	//==========================
	// ���� ���� ����
	//==========================
	function paySelect(){

		var HForm = document.cancel;

		HForm.ORDER_ID.value = "cancel_"+getStrDate();	//�ֹ���ȣ �����
		HForm.ORDER_DATE.value = getStrDate();				//�ֹ��Ͻ� �����
		var serviceCodeSelect = HForm.SERVICE_CODE;
		var serviceCode = serviceCodeSelect.options[serviceCodeSelect.selectedIndex].value;
		
		var  cancelType = HForm.CANCEL_TYPE;

		cancelType[0].selected = true;

		if ( cancelType.options.length > 2 ) {
			cancelType.options[cancelType.options.length -1] = null;
			cancelType.options[cancelType.options.length -1] = null;
		}else if ( cancelType.options.length > 1) {
			cancelType.options[cancelType.options.length -1] = null;
		}

		document.getElementById("add_view").style.display="none";
		document.getElementById("add_cancel_view1").style.display="none";
		HForm.TRANSACTION_ID.value = "";
		HForm.CANCEL_AMOUNT.value = "";


		//����â ȣ�� URL����
		switch(serviceCode){
			case'0900':	//�ſ�ī��
				document.getElementById("add_view").style.display="";
				document.getElementById("add_cancel_view1").style.display="";

				cancelType.options[cancelType.options.length] = new Option("�κ����(0000)","0000");
				cancelType.options[cancelType.options.length] = new Option("������ �ݾ� �κ����(1000)","1000");

				break;
			case'1000':	//������ü
				document.getElementById("add_view").style.display="";
				document.getElementById("add_cancel_view1").style.display="";

				cancelType.options[cancelType.options.length] = new Option("�κ����(0000)","0000");
				cancelType.options[cancelType.options.length] = new Option("������ �ݾ� �κ����(1000)","1000");

				break;
			case'1100':	//�޴���
				document.getElementById("add_view").style.display="";
				document.getElementById("add_cancel_view1").style.display="";

				cancelType.options[cancelType.options.length] = new Option("�κ����(0000)","0000");
				
				break;
			default:	//�׿�
				break;
		}	
	}

	function selectCancelType(){
		var HForm = document.cancel;

		HForm.CANCEL_AMOUNT.value = "";
	}

	 //���� ��¥ �� �ð� ��������
	function getStrDate() {
		var date = new Date();
		var strDate = 	(date.getFullYear().toString()) + 
						((date.getMonth() + 1) < 10 ? "0" + (date.getMonth() + 1).toString() : (date.getMonth() + 1).toString()) +
						((date.getDate()) < 10 ? "0" + (date.getDate()).toString() : (date.getDate()).toString()) +
						((date.getHours()) < 10 ? "0" + (date.getHours()).toString() : (date.getHours()).toString()) +
						((date.getMinutes()) < 10 ? "0" + (date.getMinutes()).toString() : (date.getMinutes()).toString()) +
						((date.getSeconds()) < 10 ? "0" + (date.getSeconds()).toString() : (date.getSeconds()).toString());
		return strDate;
	}

</script>	
<style>
	header{position: fixed;	top: 0;	left: 0; right: 0;}	
	body, tr, td {font-size:9pt; font-family:�������,verdana; }
	table {	border-collapse: collapse;}	
</style>
</head>
<body>
<header>
	<div style="width:100%; heghit:12px; font-size:13px; font-weight:bold; color: #FFFFFF; background:#ff4280;text-align: center;">
		������Ʈ ���� �׽�Ʈ ����������
	</div>
</header>

	<div  style="padding : 20px 0 20px 0; width:100%; display: block; float:left; ">
		<b style="color:red;"><���ǻ���></b><br/>
		<b>- ��翡�� �����ϴ� ������ ������ ���ظ� �������� �ܰ躰�� ������ ���̹Ƿ�, ������ ������ ������ �ʿ䰡 ������ �˷��帳�ϴ�.</b><br/>
		- �޴���, �ſ�ī��, ������ü ���񽺸� �κ���� ��� ������ �����մϴ�. <b style="color:red;">��(����� ���� �� ���� ����)</b><br/>
	</div>
	
	<div style="width:100%; display: block; float:left;">
		<form name="cancel" method="post">
			<table border="1px solid" cellpadding="5" cellspacing="1" bgcolor="#B0B0B0">
				<tr>
					<td colspan="2" height="20" align="left" bgcolor="#C0C0C0"><b>��� ����</b></td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">���������̵�<br/>(SERVICE_ID)</td>
					<td width="150" bgcolor="#FFFFFF"><input type="text" name="SERVICE_ID" size=30 class="input" value="<%=serviceId%>"></td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">�ֹ���ȣ<br/>(ORDER_ID)</td>
					<td width="150" bgcolor="#FFFFFF"><input type="text" name="ORDER_ID" size=30 class="input" value="<%=orderId%>"></td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">�ֹ��Ͻ�<br/>(ORDER_DATE)</td>
					<td width="150" bgcolor="#FFFFFF"><input type="text" name="ORDER_DATE" size=30 class="input" value="<%=orderDate%>"></td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">�����ڵ�<br/>(SERVICE_CODE)</td>
					<td width="150" bgcolor="#FFFFFF">
						<select name="SERVICE_CODE" onChange="paySelect()">
							<option value="" selected>==����==</option>
							<option value="0100">����(0100)</option>
							<option value="0200">��ȭ(0200)</option>
							<option value="0300">���ӹ�ȭ(0300)</option>
							<option value="0500">���ǸӴ�(0500)</option>
							<option value="0700">ĳ�ð���Ʈ(0700)</option>
							<option value="0900">�ſ�ī��(0900)</option>
							<option value="1100">�޴���(1100)</option>
							<option value="1200">����(1200)</option>
							<option value="1600">Ƽ�Ӵ�(1600)</option>
							<option value="1000">������ü(1000)</option>
							<option value="2500">ƾĳ��(2500)</option>
							<option value="2600">���׸Ӵ�(2600)</option>
							<option value="4100">��������Ʈ(4100)</option>
						</select>
					</td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">���Ÿ��<br/>(CANCEL_TYPE)</td>
					<td width="150" bgcolor="#FFFFFF">
						<select name="CANCEL_TYPE" onchange="selectCancelType()">
							<option value="" selected>��ü���(����)</option>
							<!--option value="0000">�κ����(0000)</option-->
							<!--option value="1000">������ �ݾ� �κ����(1000)</option-->
						</select>
					</td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">�ŷ���ȣ<br/>(TRANSACTION_ID)</td>
					<td width="150" bgcolor="#FFFFFF"><input type="text" name="TRANSACTION_ID" size=30 class="input" value="" placeholder="��ҿ�û �� �ŷ���ȣ�� �����ּ���."></td>
				</tr>
				<tr>
					<td width="150" align="left" bgcolor="#F6F6F6">��ҿ�û URL<br/>(CANCEL_URL)</td>
					<td width="150" bgcolor="#FFFFFF"><input type="text" name="CANCEL_URL" size=80 class="input" value="<%=cancelUrl%>"></td>
				</tr>
				<tr id="add_view" style="display:none;">
					<td colspan="4"><b>�߰� �Ķ����</b></td>
				</tr>
				<tr id="add_cancel_view1" style="display:none;">
					<td width="150" align="left" bgcolor="#F6F6F6">��ұݾ�(CANCEL_AMOUNT)</td>
					<td width="150" bgcolor="#FFFFFF"><input type="text" name="CANCEL_AMOUNT" size=30 class="input" value=""><br/>(<b>���Ÿ��:"������ �ݾ� �κ����"</b> ������ ��� �Է±ݾװ� ������� ��ü �ݾ� ��� ��.)</td>
				</tr>
			</table>
		</form>

		<div>
			<br/><input type="button" value="��ҿ�û" onclick="javascript:requestCancel();">
			<br/>
		</div>
	</div>

</body>
</html>