<%@ page contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%@ page import="com.galaxia.api.merchant.* "%>
<%@ page import="com.galaxia.api.crypto.* "%>
<%@ page import="com.galaxia.api.*"%>   
<%@ page import="java.util.* "%> 
<%!
	//================================
	// static ���� �� �Լ� �����
	//================================
	public static final String VERSION ="0100";
	public static final String CONF_PATH ="D:/Dev/Workspace/BillgatePay-JSP/WEB-INF/classes/config.ini"; //*������ ���� �ʼ�
	
	//��ü ��� ��û
	public Message cancelProcess(Map<String,String> cancelInfo) throws Exception {
		String serviceId = cancelInfo.get("serviceId");
		String serviceCode =cancelInfo.get("serviceCode");
		String orderId = cancelInfo.get("orderId");
		String orderDate = cancelInfo.get("orderDate");
		String transactionId = cancelInfo.get("transactionId");
		String command = cancelInfo.get("command");

		Message requestMsg = new Message(VERSION, serviceId, 
				serviceCode,
				command,				
				orderId, 
				orderDate, 
				getCipher(serviceId, serviceCode)) ;

		Message responseMsg = null ;
		
		//����
		if(transactionId != null) requestMsg.put("1001", transactionId);
		
		//���� ���
		ServiceBroker sb = new ServiceBroker(CONF_PATH, serviceCode);    

		responseMsg = sb.invoke(requestMsg);
		
		return responseMsg;
	}

	//�κ� ��� ��û
	public Message partCancelProcess(Map<String,String> cancelInfo) throws Exception {
		String serviceId = cancelInfo.get("serviceId");
		String serviceCode =cancelInfo.get("serviceCode");
		String orderId = cancelInfo.get("orderId");
		String orderDate = cancelInfo.get("orderDate");
		String transactionId = cancelInfo.get("transactionId");
		String command = cancelInfo.get("command");
		String cancelAmount = cancelInfo.get("cancelAmount");
		String cancelType = cancelInfo.get("cancelType");

		Message requestMsg = new Message(VERSION, serviceId, 
				serviceCode,
				command,				
				orderId, 
				orderDate, 
				getCipher(serviceId, serviceCode)) ;

		Message responseMsg = null ;
		
		//�ſ�ī�� ����
		if("0900".equals(serviceCode)){
			if(transactionId != null) requestMsg.put("1001", transactionId);		//�ŷ���ȣ
			if(cancelAmount != null) requestMsg.put("0012", cancelAmount);		//��ұݾ�		
			if(cancelType != null) requestMsg.put("0082", cancelType);				//���Ÿ��

		//������ü ����
		}else if("1000".equals(serviceCode)){
			if(transactionId != null) requestMsg.put("1012", transactionId);				//���ŷ� �ŷ���ȣ (��ü��� �ŷ���ȣ��  tag �� �ٸ� ����!!)
			if(cancelAmount !=null )requestMsg.put("1033", cancelAmount);				//��ұݾ�
			if(cancelType != null) requestMsg.put("0015", cancelType);						//���Ÿ��
		
		//�޴��� ����
		}else if("1100".equals(serviceCode)){
			if(transactionId != null) requestMsg.put("1001", transactionId);				//�ŷ���ȣ
			if(cancelAmount != null) requestMsg.put("7043", cancelAmount);				//��� ��û�ݾ�
		}

		//���� ���
		ServiceBroker sb = new ServiceBroker(CONF_PATH, serviceCode); 

		responseMsg = sb.invoke(requestMsg);
		
		return responseMsg;
	}

	//���� ������ ���� key, iv�� ������
	private GalaxiaCipher getCipher(String serviceId, String serviceCode) throws Exception {

		GalaxiaCipher cipher = null ;

		String key = null ;
		String iv = null ;
	try {
			ConfigInfo config = new ConfigInfo(CONF_PATH, serviceCode);

			key = config.getKey();
			iv = config.getIv();
			
			cipher = new Seed();
			cipher.setKey(key.getBytes());
			cipher.setIV(iv.getBytes());
	} catch(Exception e) {
		throw e ;
	}
	return cipher;
	}
	
%> 

<%	
	/*
	------------------------------------------------------------------------------------- 
	�ش� �������� ������Ʈ ������ ���� "��� ��û" �׽�Ʈ ������ �Դϴ�.
	------------------------------------------------------------------------------------- 
	*/	
	String serviceId = null;
	String serviceCode = null;
	String command = null;
	String orderId = null;
	String orderDate = null;
	String transactionId = null;
	String cancelAmount = null;
	String cancelType = null;
	String outTransactionId = null;
	String outCancelAmount = null;
	String outPartCancelSequenceNumber = null;

	String partCancelType = null;			//�޴���
	String cancelTransactionId=null;		//�޴���
	String reauthOldTransactionId = null;//�޴���
	String reauthNewTransactionId = null;	 //�޴���

	String responseCode = null;
	String responseMessage = null;
	String detailResponseCode = null;
	String detailResponseMessage = null;

	Map<String,String> cancelInfo = null;
	
	try {
		if(null==request.getParameter("TRANSACTION_ID")){
%>
		<script type="text/javascript">
			alert("���� �ڵ� : 0901\n���� �޽��� : ��ҿ�ûâ(CancelReturn)! �Ķ���͸� ��Ȯ�� �Է����ּ���.");
			window.close();
		</script>
<%			
		}
		request.setCharacterEncoding("euc-kr");

		serviceId = request.getParameter("SERVICE_ID");							//������ ���� ���̵�
		serviceCode = request.getParameter("SERVICE_CODE");					//���� �ڵ� 
		orderId = request.getParameter("ORDER_ID");									//�ֹ� ��ȣ
		orderDate = request.getParameter("ORDER_DATE");						//�ֹ� �Ͻ�
		transactionId = request.getParameter("TRANSACTION_ID");				//�ŷ���ȣ
		cancelType = request.getParameter("CANCEL_TYPE");						//�κ���� Ÿ��
		cancelAmount= request.getParameter("CANCEL_AMOUNT");				//��� �ݾ�(�κ���� �� ���)

	//====================================
	// ���� ���� �� �и�
	//====================================
	Message respMsg = null;
	//��� ��û ���� Map�� ����
	cancelInfo = new HashMap<String,String>();	
		//�ſ�ī��
		if("0900".equals(serviceCode)){				
			//���� �Ķ����
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);
			cancelInfo.put("transactionId", transactionId);

			//�κ���� 
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				cancelInfo.put("command", "9010");					//�κ���� Command

				cancelInfo.put("cancelType", cancelType);		//��ұ��� (0000:�κ����, 1000:������ ��ü ���)
				cancelInfo.put("cancelAmount", cancelAmount);	//��ұݾ� (��ұ����� 1000 �� ��� �ڵ������)

				/*�κ���� ��û*/
				respMsg = partCancelProcess(cancelInfo);

			//��ü ���
			}else{
				cancelInfo.put("command", "9200");					//��ü��� Command
				
				/*��ü��� ��û*/
				respMsg = cancelProcess(cancelInfo);
			}


		//������ü 
		}else if("1000".equals(serviceCode)){

			//���� �Ķ����
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);

			//�κ���� 
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				cancelInfo.put("command", "9300");						//�κ���� Command

				cancelInfo.put("cancelType", cancelType);				//��ұ��� (0000:�κ����, 1000:������ ��ü ���)
				cancelInfo.put("cancelAmount", cancelAmount);		//��ұݾ� 
				cancelInfo.put("transactionId", transactionId);	//���ŷ� �ŷ���ȣ

				/*�κ���� ��û*/
				respMsg = partCancelProcess(cancelInfo);

			//��ü���
			}else{
				cancelInfo.put("command", "9000");						//��ü��� Command
				cancelInfo.put("transactionId", transactionId);		//��ü��� �ŷ���ȣ

				/*��ü��� ��û*/
				respMsg = cancelProcess(cancelInfo);
			}

		//�޴���
		}else if("1100".equals(serviceCode)){
			//���� �Ķ����
			cancelInfo.put("command", "9000");				//�κ�/��ü��� Command ����
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);
			cancelInfo.put("transactionId", transactionId);

			//�κ����
			if("0000".equals(cancelType)){
				if((!("".equals(cancelAmount))||null!=cancelAmount)){
					cancelInfo.put("cancelAmount", cancelAmount);	//��ұݾ�(*����* �κ���� �� �ݾ� ���� ��� ��ü ���)	
					
					/*�κ���� ��û*/
					respMsg = partCancelProcess(cancelInfo);
				}
			}else{
			
			/*��ü��� ��û*/
			respMsg = cancelProcess(cancelInfo);
			}

		//�޴���,�ſ�ī��,������ü �� ��� �������� ��� ����
		}else{
			cancelInfo.put("command", "9000");
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);
			cancelInfo.put("transactionId", transactionId);

			/*��ü��� ��û*/
			respMsg = cancelProcess(cancelInfo);
		}
	  

		/*
		��� ��û�� ���� ���� ��� ����
		*/
		//����
		responseCode = respMsg.get("1002");
		responseMessage = respMsg.get("1003");
		detailResponseCode = respMsg.get("1009");
		detailResponseMessage = respMsg.get("1010");

		//�ſ�ī�� ����
		if("0900".equals(serviceCode)){
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			
			//�κ����
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				outCancelAmount = respMsg.get("0012");					//�κ���� �ݾ�
				outPartCancelSequenceNumber = respMsg.get("5049");	//�κ���� ������
			
			//��ü���
			}else{
				outCancelAmount = respMsg.get("1033");	//��ұݾ�
			}

		//������ü ����
		}else if("1000".equals(serviceCode)){
			outCancelAmount = respMsg.get("1033");		//��ұݾ�

			//�κ����
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				outTransactionId  = respMsg.get("1012");						//�ŷ���ȣ
				outPartCancelSequenceNumber = respMsg.get("0096");	//�κ���� ������
			
			//��ü���
			}else{
				outTransactionId  = respMsg.get("1001");		//�ŷ���ȣ
			}		

		//�޴��� ����
		}else if("1100".equals(serviceCode)){
			outTransactionId  = respMsg.get("1001");			//�ŷ���ȣ
			partCancelType =respMsg.get("7049");					//�κ���� Ÿ��

			//�κ����
			if("0000".equals(cancelType)){
				outCancelAmount = respMsg.get("7043");				//�κ���� �ݾ�
				cancelTransactionId=respMsg.get("1032");				//��Ұŷ���ȣ
				reauthOldTransactionId = respMsg.get("1040");		//����� �����ŷ���ȣ
				reauthNewTransactionId = respMsg.get("1041");		//����� �ű԰ŷ���ȣ
			
			//��ü���
			}else{
				outCancelAmount  = respMsg.get("1007");		//��ұݾ�
			}	

		//Ƽ�Ӵ�(0700), ĳ�ð���Ʈ(1600) ����
		}else if("0700".equals(serviceCode)||"1600".equals(serviceCode)){
			outTransactionId  = respMsg.get("1001");	//�ŷ���ȣ
			outCancelAmount  = respMsg.get("0012");		//��ұݾ�
		
		//�� �� �������� ���
		}else{
			outTransactionId  = respMsg.get("1001");			//�ŷ���ȣ
		}
%>
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
<body>
	<div>
		<table width="380px" border="0" cellpadding="0"	cellspacing="0">
		<tr> 
	 		 <td height="25" style="padding-left:10px" class="title01"># ������ġ &gt;&gt; <b>������ ��� ������</b></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td align="center"><!--�������̺� ����--->
				<table width="380" border="0" cellpadding="4" cellspacing="1" bgcolor="#B0B0B0">	
					<tr>
						<td><b>��Ұ��</b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������ ���̵�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����ڵ�</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ���ȣ</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ��Ͻ�</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderDate%></b></td>
					</tr>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ŷ���ȣ</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outTransactionId%></b></td>
					</tr>
<%
	//�ſ�ī��(0900), ������ü(1000), �޴���(1100), ĳ�ð���Ʈ(0700), Ƽ�Ӵ�(1600) 
	if(outCancelAmount!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>��ұݾ�</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outCancelAmount%></b></td>
					</tr>
<%
	}
	//�ſ�ī��(0900), ������ü(1000)
	if(outPartCancelSequenceNumber!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�κ���� ������</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outPartCancelSequenceNumber%></b></td>
					</tr>

<%
	}
	//�޴���	
	if(partCancelType!=null){
%>

					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�κ���� Ÿ��</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=partCancelType%></b></td>
					</tr>
<%
	}	
	//�޴���	
	if(cancelTransactionId!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>��Ұŷ���ȣ</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=cancelTransactionId%></b></td>
					</tr>
<%
	}	
	//�޴���	
	if(reauthOldTransactionId!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>����� �����ŷ���ȣ</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reauthOldTransactionId%></b></td>
					</tr>
<%
	}	
	//�޴���	
	if(reauthNewTransactionId!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>����� �ű԰ŷ���ȣ</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reauthNewTransactionId%></b></td>
					</tr>
<%
	}	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����ڵ�</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>����޽���</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�������ڵ�</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������޽���</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseMessage%></b></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>
<%
	} catch (Exception ex) {
		ex.printStackTrace();
%>
<script type="text/javascript">
	alert("���� �ڵ� : 0901\n���� �޽��� : ��ҿ�ûâ(cancel)! �����ڿ��� ���� �ϼ���!");
	window.close();
	</script>
<%
	}
%>
</body>
</html>