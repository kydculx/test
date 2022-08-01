<%@ page contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%@ page import="com.galaxia.api.merchant.* "%>
<%@ page import="com.galaxia.api.crypto.* "%>
<%@ page import="com.galaxia.api.*"%>
<%@ page import="java.sql.* "%>
<%@ page import="java.util.* "%> 
<%!
	//================================
	// static ���� �� �Լ� �����
	//================================
	public static final String VERSION ="0100";
	public static final String CONF_PATH ="D:/Dev/Workspace/BillgatePay-JSP/WEB-INF/classes/config.ini"; //*������ ���� �ʼ�
	
	// ���� ��û
		public Message MessageAuthProcess(Map<String,String> authInfo) throws Exception {
			String serviceId = authInfo.get("serviceId");
			String serviceCode = authInfo.get("serviceCode");
			String msg = authInfo.get("message");

			//�޽��� Length ����
			byte[] b = new byte[msg.getBytes().length - 4] ;
			System.arraycopy(msg.getBytes(), 4, b, 0, b.length);

			Message requestMsg = new Message(b, getCipher(serviceId,serviceCode)) ;
			
			Message responseMsg = null ;

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
	�ش� �������� ������Ʈ ������ ���� "������� ���� �� ���ο�û/���� "�׽�Ʈ ������ �Դϴ�.
	------------------------------------------------------------------------------------- 
	*/	
	/* ���� ��� ���� */
	String serviceId = null;
	String serviceCode = null; 
	String orderId = null;
	String orderDate = null;
	String transactionId = null;
	String responseCode = null;	
	String responseMessage = null;
	String detailResponseCode = null;
	String detailResponseMessage = null;
	String reserved1 = null;
	String reserved2 = null;
	String reserved3 = null;
	String serviceType = null;		//���� ����(�Ϲ�:0000/���ڵ�:1000)
	String confType = null;			//ƾĳ��_���� Ÿ�� ����(0000:ID ����/1000:PIN ����)

	String message = null;			//���� ���� MESSAGE

	//�������
	String accountNumber = null;		//������¹�ȣ
	String bankCode = null;				//�߱� ���� �ڵ�
	String mixType = null;				//�ŷ� ����(�Ϲ�:0000/����ũ��:1000)
	String expireDate = null;				//�Աݸ�������(YYYYMMDD)
	String expireTime = null;			//�Աݸ����ð�(HH24MISS)
	String amount = null;					//�Աݿ����ݾ�

	/* ���� ��� ���� */
	String outTransactionId = null;
	String outResponseCode = null;
	String outResponseMessage = null;
	String outDetailResponseCode = null;
	String outDetailResponseMessage = null;

	String authAmount = null; 		// �������� �߰� �Ķ����	_���αݾ�
	String authNumber = null;		// �������� �߰� �Ķ����_���ι�ȣ
	String authDate = null;			// �������� �߰� �Ķ����_�����Ͻ�

	String quota = null;					//�ſ�ī�� �������� �߰� �Ķ����_�Һΰ��� �� 
	String cardCompanyCode = null; //�ſ�ī�� �������� �߰� �Ķ����_�߱޻� �ڵ� 
	
	String balance = null;					//ĳ�ð���Ʈ �������� �߰� �Ķ����_�ܾ�
	String dealAmount = null;			//ĳ�ð���Ʈ �������� �߰� �Ķ����_���αݾ�
	
	String usingType = null;				//������ü �������� �߰� �Ķ����_���ݿ����� �뵵
	String identifier = null;				//������ü �������� �߰� �Ķ����_���ݿ����� ���ι�ȣ
	String identifierType = null;		//������ü �������� �߰� �Ķ����_���ݿ����� �����߱� ����
	String inputBankCode = null;		//������ü  �������� �߰� �Ķ����_���� �ڵ� 
	String inputAccountName = null;	//������ü  �������� �߰� �Ķ����_�����

	String partCancelType = null;		//�޴��� �������� �߰� �Ķ����_�κ� ��� Ÿ��(�Ϲ� �����ÿ��� ����)

	Map<String,String> authInfo = null;	 //���ο�û ���� ����

	Message respMsg = null;			

	try{
			
		//================================================
		// 1. ���� ��� �Ķ���� ����
		//================================================
		request.setCharacterEncoding("euc-kr");
		
		serviceType = request.getParameter("SERVICE_TYPE");						//���� Ÿ��(�Ϲ� :0000 , ���ڵ�:1000)
		confType = request.getParameter("CONF_TYPE");								//���� ���� Ÿ��(ID����: 0000, PIN����: 1000) *ƾĳ�� 
		serviceId = request.getParameter("SERVICE_ID");								//������ ���� ���̵�
		serviceCode = request.getParameter("SERVICE_CODE");						//���� ���� �� �����ڵ�
		orderId = request.getParameter("ORDER_ID");										//�ֹ� ��ȣ
		orderDate = request.getParameter("ORDER_DATE");							//�ֹ� ����
		transactionId = request.getParameter("TRANSACTION_ID");					//�ŷ���ȣ
		responseCode = request.getParameter("RESPONSE_CODE");								//�����ڵ�
		responseMessage = request.getParameter("RESPONSE_MESSAGE");					//����޽���
		detailResponseCode = request.getParameter("DETAIL_RESPONSE_CODE");		//�� �����ڵ�
		detailResponseMessage = request.getParameter("DETAIL_RESPONSE_MESSAGE");//�� ���� �޽���

		message = request.getParameter("MESSAGE");								//���� ���� ���� �޽���
	
		reserved1 = request.getParameter("RESERVED1");							//���񺯼�1
		reserved2 = request.getParameter("RESERVED2");							//���񺯼�2
		reserved3 = request.getParameter("RESERVED3");							//���񺯼�3

		/*������� ä�� ����*/		
		accountNumber =request.getParameter("ACCOUNT_NUMBER");			//������¹�ȣ
		bankCode =request.getParameter("BANK_CODE");							//�߱� ���� �ڵ�
		mixType = request.getParameter("MIX_TYPE");								//�ŷ� ����(�Ϲ�:0000/����ũ��:1000)
		expireDate = request.getParameter("EXPIRE_DATE");						//�Աݸ�������(YYYYMMDD)
		expireTime = request.getParameter("EXPIRE_TIME");						//�Աݸ����ð�(HH24MISS)
		amount = request.getParameter("AMOUNT");									//�Աݿ����ݾ�
	
		//================================================
		// 2. ���� ������ ��쿡�� ���� ��û ����
		//================================================
		if(("0000").equals(responseCode)&&!("1800".equals(serviceCode))){ //������� ����
			
		//���� ���� Map�� ����
		authInfo = new HashMap<String,String>();

		authInfo.put("serviceId", serviceId);
		authInfo.put("serviceCode", serviceCode);
		authInfo.put("message", message);

		//================================
		// 4. ���� ��û & ���� ���� ��� ����  
		//================================				
		//���� ��û(Message)
		respMsg = MessageAuthProcess(authInfo);

		//���� ���� �� ���� ���� �и�
		//�޴���
		if("1100".equals(serviceCode)){ 			

			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");			//�ŷ���ȣ
			authDate = respMsg.get("1005");					//�����Ͻ�
			authAmount = respMsg.get("1007");				//���αݾ�
			partCancelType =respMsg.get("7049");			//�κ� ��� Ÿ��

		//�ſ�ī��	
		}else if("0900".equals(serviceCode)){		
	
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");				//�ŷ���ȣ
			authNumber = respMsg.get("1004");					//���ι�ȣ	
			authDate = respMsg.get("1005");						//�����Ͻ�
			authAmount = respMsg.get("1007");					//���αݾ�
			quota = respMsg.get("0031");								//�Һΰ��� ��
			cardCompanyCode = respMsg.get("0034");			//ī��߱޻� �ڵ�

		
		//������ü
		}else if("1000".equals(serviceCode)){		
		
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");			//�ŷ���ȣ
			authAmount = respMsg.get("1007");				//���αݾ�
			authDate = respMsg.get("1005");					//�����Ͻ�
			usingType = respMsg.get("0015");					//���ݿ����� �뵵
			identifier = respMsg.get("0017");					//���ݿ����� ���ι�ȣ
			identifierType = respMsg.get("0102");				//���ݿ����� �����߱�������
			mixType = respMsg.get("0037");						//�ŷ�����
			inputBankCode = respMsg.get("0105");			//���� �ڵ�
			inputAccountName = respMsg.get("0107");		//���� ��
		
		//������ȭ��ǰ��	
		}else if("0100".equals(serviceCode)){
		
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");			//�ŷ���ȣ
			authDate = respMsg.get("1005");					//�����Ͻ�	
			authNumber = respMsg.get("1004");				//���ι�ȣ	
			authAmount = respMsg.get("1007");				//���αݾ�		
	
		//��ȭ��ǰ��
		}else if("0200".equals(serviceCode)){
		
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�	
			authNumber = respMsg.get("1004");			//���ι�ȣ	
			authAmount = respMsg.get("1007");			//���αݾ�
		
		//���ӹ�ȭ��ǰ��
		}else if("0300".equals(serviceCode)){
			
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�	
			authNumber = respMsg.get("1004");			//���ι�ȣ	
			authAmount = respMsg.get("1007");			//���αݾ�
		
		//���ǸӴϻ�ǰ��
		}else if("0500".equals(serviceCode)){
			
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�	
			authNumber = respMsg.get("1004");			//���ι�ȣ	
			authAmount = respMsg.get("1007");			//���αݾ�
		
		//ĳ�ð���Ʈ	
		}else if("0700".equals(serviceCode)){		

			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			balance = respMsg.get("1006");					//���� �� �ܾ�
			dealAmount = respMsg.get("0012");			//���αݾ�(Ÿ �������ܰ�  tag���� �ٸ��Ƿ� ����)
			authDate = respMsg.get("1005");				//�����Ͻ�
		
		//ƾĳ��	
		}else if("2500".equals(serviceCode)){		
		
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�	
			authNumber = respMsg.get("1004");			//���ι�ȣ	
			authAmount = respMsg.get("1007");			//���αݾ�

		// ���׸Ӵ�	
		}else if("2600".equals(serviceCode)){		
		
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�	
			authNumber = respMsg.get("1004");			//���ι�ȣ	
			authAmount = respMsg.get("1007");			//���αݾ�
		
		//��������Ʈ	
		}else if("4100".equals(serviceCode)){		

			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�		
			authAmount = respMsg.get("1007");			//���αݾ�
		
		//Ƽ�Ӵ�	
		}else if("1600".equals(serviceCode)){		
			
			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");				//�����Ͻ�		
			authAmount = respMsg.get("1007");			//���αݾ�
		
		//����
		}else if("1200".equals(serviceCode)){	

			//���� ����
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//�ŷ���ȣ
			authDate = respMsg.get("1005");						//�����Ͻ�		
			authAmount = respMsg.get("1007");			//���αݾ�

		//�� ��
		}else {
%>				
			<script type="text/javascript">
				alert(<%=serviceCode%>+"RETURN ������ ����\n���� �޽��� : ���������� ���� �ڵ带 Ȯ�����ּ���!/ ");
				window.close();
			</script>
<%	
		}
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
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceCode%></b></td>
					</tr>
<%
	//�޴���(1100), ����(1200) ���� ��� �Ķ���� �߰�_����Ÿ��(0000:�Ϲ�/1000:���ڵ�)
	if("1100".equals(serviceCode)||"1200".equals(serviceCode)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� Ÿ��</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceType%></b></td>
					</tr>
<%
    }
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ���ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ֹ��Ͻ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderDate%></b></td>
					</tr>
<%
	//ĳ�ð���Ʈ(0700), �ſ�ī��(0900) �ŷ���ȣ ��� ����
	if(!("0700".equals(serviceCode)||"0900".equals(serviceCode))){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ŷ���ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=transactionId%></b></td>
					</tr>
<%
    } 
	 //�������(1800) ä�� ����
    if ("1800".equals(serviceCode) && "0000".equals(responseCode)) 
    {
%>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������¹�ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=accountNumber%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ݾ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=amount%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=bankCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ŷ�����</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=mixType%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�Ա� ��ȿ ������</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=expireDate%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�Ա� ���� �ð�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=expireTime%></b></td>
					</tr>
<% 
    } 
	//ƾĳ��(2500) ��������
	if("2500".equals(serviceCode)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� ����</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=confType%></b></td>
					</tr>
<%
	}	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>����޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�������ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���񺯼�1</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reserved1 %></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���񺯼�2</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reserved2 %></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���񺯼�3</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reserved3 %></b></td>
					</tr>	
					
                    <!--������� ��-->
                    <!--���ΰ�� ����-->

					<tr>
						<td><b>���ΰ��</b></td>
					</tr>
<%
    if (outResponseCode!=null){ 
%>	
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ŷ���ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outTransactionId%></b></td>
					</tr>					
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����Ͻ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=authDate%></b></td>
					</tr>
<% 
	//ĳ�ð���Ʈ(0700) �� ���, �����ݾ��� dealAmount�� ǥ��
	if("0700".equals(serviceCode)){	 
%>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���αݾ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=dealAmount%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ܾ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=balance%></b></td>
					</tr>			
<%
	}else{	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���αݾ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=authAmount%></b></td>
					</tr>	
<%
}
	//�ſ�ī��(0900), ���� �ݾ� �׸� �߰�
	if("0900".equals(serviceCode)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�Һΰ��� ��</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=quota%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>ī�� �߱޻� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=cardCompanyCode%></b></td>
					</tr>
<%
	}
%>
				
<%
	//�ſ�ī��(0900), ������ü(0100), ��ȭ��ǰ��(0200), ���ӹ�ȭ��ǰ��(0300), ���ǸӴϻ�ǰ��(0500), ƾĳ��(2500),���׸Ӵ�(2600), ���� ���� �Ķ���� �߰�
	if("0900".equals(serviceCode)||"0100".equals(serviceCode)||"0200".equals(serviceCode)||"0300".equals(serviceCode)||"0500".equals(serviceCode)||"2500".equals(serviceCode)||"2600".equals(serviceCode)){	
%>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���ι�ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=authNumber%></b></td>
					</tr>			
<%
	}
	//������ü(1000)�� ���, ���� �Ķ���� �߰�		
	if("1000".equals(serviceCode)){		
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�ŷ�����</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=mixType%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���ݿ����� �뵵</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=usingType%></b></td>
					</tr>	
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���ݿ����� ���ι�ȣ</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=identifier%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���ݿ����� �����߱�������</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=identifierType%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>���� �ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=inputBankCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=inputAccountName%></b></td>
					</tr>
<%
	}	
	//�޴���(1100)�̸鼭 �Ϲ� ����(serviceType:0000) �� ���, ���� ���� �Ķ���� �߰�
	if("1100".equals(serviceCode)&&"0000".equals(serviceType)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�κ� ��� Ÿ��</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=partCancelType%></b></td>
					</tr>	
<%
	}	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�����ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>����޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outResponseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>�������ڵ�</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outDetailResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>������޽���</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outDetailResponseMessage%></b></td>
					</tr>
<%
	}else{						
%>
					<tr>
						<td width="300" align="center" bgcolor="#F6F6F6" colspan="2"><b>���� ��� ����</b></td>
					</tr>		
<%
	}	
%>					
					<!-- ���ΰ�� ��-->
			</table>
			</td>
		</tr>
	</table>
		
	<%	
	}catch(Exception ex){
%>				
			<script type="text/javascript">
				alert("RETURN ������ ����\n���� �޽��� : ���� ��û ����! ");
				window.close();
			</script>
<%	
		ex.printStackTrace();
	}
	%>
	</div>
	<br>
</body>

</html>