<%@ page contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%@ page import="com.galaxia.api.merchant.* "%>
<%@ page import="com.galaxia.api.crypto.* "%>
<%@ page import="com.galaxia.api.*"%>   
<%@ page import="java.util.* "%> 
<%!
	//================================
	// static 변수 및 함수 선언부
	//================================
	public static final String VERSION ="0100";
	public static final String CONF_PATH ="D:/Dev/Workspace/BillgatePay-JSP/WEB-INF/classes/config.ini"; //*가맹점 수정 필수
	
	//전체 취소 요청
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
		
		//공통
		if(transactionId != null) requestMsg.put("1001", transactionId);
		
		//전문 통신
		ServiceBroker sb = new ServiceBroker(CONF_PATH, serviceCode);    

		responseMsg = sb.invoke(requestMsg);
		
		return responseMsg;
	}

	//부분 취소 요청
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
		
		//신용카드 전용
		if("0900".equals(serviceCode)){
			if(transactionId != null) requestMsg.put("1001", transactionId);		//거래번호
			if(cancelAmount != null) requestMsg.put("0012", cancelAmount);		//취소금액		
			if(cancelType != null) requestMsg.put("0082", cancelType);				//취소타입

		//계좌이체 전용
		}else if("1000".equals(serviceCode)){
			if(transactionId != null) requestMsg.put("1012", transactionId);				//원거래 거래번호 (전체취소 거래번호와  tag 값 다름 주의!!)
			if(cancelAmount !=null )requestMsg.put("1033", cancelAmount);				//취소금액
			if(cancelType != null) requestMsg.put("0015", cancelType);						//취소타입
		
		//휴대폰 전용
		}else if("1100".equals(serviceCode)){
			if(transactionId != null) requestMsg.put("1001", transactionId);				//거래번호
			if(cancelAmount != null) requestMsg.put("7043", cancelAmount);				//취소 요청금액
		}

		//전문 통신
		ServiceBroker sb = new ServiceBroker(CONF_PATH, serviceCode); 

		responseMsg = sb.invoke(requestMsg);
		
		return responseMsg;
	}

	//설정 파일을 통해 key, iv값 가져옴
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
	해당 페이지는 빌게이트 결제를 위한 "취소 요청" 테스트 페이지 입니다.
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

	String partCancelType = null;			//휴대폰
	String cancelTransactionId=null;		//휴대폰
	String reauthOldTransactionId = null;//휴대폰
	String reauthNewTransactionId = null;	 //휴대폰

	String responseCode = null;
	String responseMessage = null;
	String detailResponseCode = null;
	String detailResponseMessage = null;

	Map<String,String> cancelInfo = null;
	
	try {
		if(null==request.getParameter("TRANSACTION_ID")){
%>
		<script type="text/javascript">
			alert("에러 코드 : 0901\n에러 메시지 : 취소요청창(CancelReturn)! 파라미터를 정확히 입력해주세요.");
			window.close();
		</script>
<%			
		}
		request.setCharacterEncoding("euc-kr");

		serviceId = request.getParameter("SERVICE_ID");							//가맹점 서비스 아이디
		serviceCode = request.getParameter("SERVICE_CODE");					//서비스 코드 
		orderId = request.getParameter("ORDER_ID");									//주문 번호
		orderDate = request.getParameter("ORDER_DATE");						//주문 일시
		transactionId = request.getParameter("TRANSACTION_ID");				//거래번호
		cancelType = request.getParameter("CANCEL_TYPE");						//부분취소 타입
		cancelAmount= request.getParameter("CANCEL_AMOUNT");				//취소 금액(부분취소 일 경우)

	//====================================
	// 결제 수단 별 분리
	//====================================
	Message respMsg = null;
	//취소 요청 정보 Map에 저장
	cancelInfo = new HashMap<String,String>();	
		//신용카드
		if("0900".equals(serviceCode)){				
			//공통 파라미터
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);
			cancelInfo.put("transactionId", transactionId);

			//부분취소 
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				cancelInfo.put("command", "9010");					//부분취소 Command

				cancelInfo.put("cancelType", cancelType);		//취소구분 (0000:부분취소, 1000:나머지 전체 취소)
				cancelInfo.put("cancelAmount", cancelAmount);	//취소금액 (취소구분이 1000 인 경우 자동계산함)

				/*부분취소 요청*/
				respMsg = partCancelProcess(cancelInfo);

			//전체 취소
			}else{
				cancelInfo.put("command", "9200");					//전체취소 Command
				
				/*전체취소 요청*/
				respMsg = cancelProcess(cancelInfo);
			}


		//계좌이체 
		}else if("1000".equals(serviceCode)){

			//공통 파라미터
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);

			//부분취소 
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				cancelInfo.put("command", "9300");						//부분취소 Command

				cancelInfo.put("cancelType", cancelType);				//취소구분 (0000:부분취소, 1000:나머지 전체 취소)
				cancelInfo.put("cancelAmount", cancelAmount);		//취소금액 
				cancelInfo.put("transactionId", transactionId);	//원거래 거래번호

				/*부분취소 요청*/
				respMsg = partCancelProcess(cancelInfo);

			//전체취소
			}else{
				cancelInfo.put("command", "9000");						//전체취소 Command
				cancelInfo.put("transactionId", transactionId);		//전체취소 거래번호

				/*전체취소 요청*/
				respMsg = cancelProcess(cancelInfo);
			}

		//휴대폰
		}else if("1100".equals(serviceCode)){
			//공통 파라미터
			cancelInfo.put("command", "9000");				//부분/전체취소 Command 동일
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);
			cancelInfo.put("transactionId", transactionId);

			//부분취소
			if("0000".equals(cancelType)){
				if((!("".equals(cancelAmount))||null!=cancelAmount)){
					cancelInfo.put("cancelAmount", cancelAmount);	//취소금액(*주의* 부분취소 시 금액 없는 경우 전체 취소)	
					
					/*부분취소 요청*/
					respMsg = partCancelProcess(cancelInfo);
				}
			}else{
			
			/*전체취소 요청*/
			respMsg = cancelProcess(cancelInfo);
			}

		//휴대폰,신용카드,계좌이체 외 모든 결제수단 취소 전문
		}else{
			cancelInfo.put("command", "9000");
			cancelInfo.put("serviceId", serviceId);
			cancelInfo.put("serviceCode", serviceCode);
			cancelInfo.put("orderId", orderId);
			cancelInfo.put("orderDate", orderDate);
			cancelInfo.put("transactionId", transactionId);

			/*전체취소 요청*/
			respMsg = cancelProcess(cancelInfo);
		}
	  

		/*
		취소 요청에 대한 응답 결과 설정
		*/
		//공통
		responseCode = respMsg.get("1002");
		responseMessage = respMsg.get("1003");
		detailResponseCode = respMsg.get("1009");
		detailResponseMessage = respMsg.get("1010");

		//신용카드 전용
		if("0900".equals(serviceCode)){
			outTransactionId = respMsg.get("1001");		//거래번호
			
			//부분취소
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				outCancelAmount = respMsg.get("0012");					//부분취소 금액
				outPartCancelSequenceNumber = respMsg.get("5049");	//부분취소 시퀀스
			
			//전체취소
			}else{
				outCancelAmount = respMsg.get("1033");	//취소금액
			}

		//계좌이체 전용
		}else if("1000".equals(serviceCode)){
			outCancelAmount = respMsg.get("1033");		//취소금액

			//부분취소
			if("0000".equals(cancelType)||"1000".equals(cancelType)){
				outTransactionId  = respMsg.get("1012");						//거래번호
				outPartCancelSequenceNumber = respMsg.get("0096");	//부분취소 시퀀스
			
			//전체취소
			}else{
				outTransactionId  = respMsg.get("1001");		//거래번호
			}		

		//휴대폰 전용
		}else if("1100".equals(serviceCode)){
			outTransactionId  = respMsg.get("1001");			//거래번호
			partCancelType =respMsg.get("7049");					//부분취소 타입

			//부분취소
			if("0000".equals(cancelType)){
				outCancelAmount = respMsg.get("7043");				//부분취소 금액
				cancelTransactionId=respMsg.get("1032");				//취소거래번호
				reauthOldTransactionId = respMsg.get("1040");		//재승인 이전거래번호
				reauthNewTransactionId = respMsg.get("1041");		//재승인 신규거래번호
			
			//전체취소
			}else{
				outCancelAmount  = respMsg.get("1007");		//취소금액
			}	

		//티머니(0700), 캐시게이트(1600) 전용
		}else if("0700".equals(serviceCode)||"1600".equals(serviceCode)){
			outTransactionId  = respMsg.get("1001");	//거래번호
			outCancelAmount  = respMsg.get("0012");		//취소금액
		
		//그 외 결제수단 모두
		}else{
			outTransactionId  = respMsg.get("1001");			//거래번호
		}
%>
<html>
<head>
<title></title>
<style>
	body, tr, td {font-size:9pt; font-family:맑은고딕,verdana; }
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
	 		 <td height="25" style="padding-left:10px" class="title01"># 현재위치 &gt;&gt; <b>가맹점 취소 페이지</b></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td align="center"><!--본문테이블 시작--->
				<table width="380" border="0" cellpadding="4" cellspacing="1" bgcolor="#B0B0B0">	
					<tr>
						<td><b>취소결과</b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>가맹점 아이디</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>서비스코드</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>주문번호</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>주문일시</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderDate%></b></td>
					</tr>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>거래번호</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outTransactionId%></b></td>
					</tr>
<%
	//신용카드(0900), 계좌이체(1000), 휴대폰(1100), 캐시게이트(0700), 티머니(1600) 
	if(outCancelAmount!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>취소금액</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outCancelAmount%></b></td>
					</tr>
<%
	}
	//신용카드(0900), 계좌이체(1000)
	if(outPartCancelSequenceNumber!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>부분취소 시퀀스</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outPartCancelSequenceNumber%></b></td>
					</tr>

<%
	}
	//휴대폰	
	if(partCancelType!=null){
%>

					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>부분취소 타입</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=partCancelType%></b></td>
					</tr>
<%
	}	
	//휴대폰	
	if(cancelTransactionId!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>취소거래번호</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=cancelTransactionId%></b></td>
					</tr>
<%
	}	
	//휴대폰	
	if(reauthOldTransactionId!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>재승인 이전거래번호</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reauthOldTransactionId%></b></td>
					</tr>
<%
	}	
	//휴대폰	
	if(reauthNewTransactionId!=null){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>재승인 신규거래번호</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reauthNewTransactionId%></b></td>
					</tr>
<%
	}	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>응답코드</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>응답메시지</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>상세응답코드</b></td>
						<td align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>상세응답메시지</b></td>
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
	alert("에러 코드 : 0901\n에러 메시지 : 취소요청창(cancel)! 관리자에게 문의 하세요!");
	window.close();
	</script>
<%
	}
%>
</body>
</html>