<%@ page contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%@ page import="com.galaxia.api.merchant.* "%>
<%@ page import="com.galaxia.api.crypto.* "%>
<%@ page import="com.galaxia.api.*"%>
<%@ page import="java.sql.* "%>
<%@ page import="java.util.* "%> 
<%!
	//================================
	// static 변수 및 함수 선언부
	//================================
	public static final String VERSION ="0100";
	public static final String CONF_PATH ="D:/Dev/Workspace/BillgatePay-JSP/WEB-INF/classes/config.ini"; //*가맹점 수정 필수
	
	// 승인 요청
		public Message MessageAuthProcess(Map<String,String> authInfo) throws Exception {
			String serviceId = authInfo.get("serviceId");
			String serviceCode = authInfo.get("serviceCode");
			String msg = authInfo.get("message");

			//메시지 Length 제거
			byte[] b = new byte[msg.getBytes().length - 4] ;
			System.arraycopy(msg.getBytes(), 4, b, 0, b.length);

			Message requestMsg = new Message(b, getCipher(serviceId,serviceCode)) ;
			
			Message responseMsg = null ;

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
	해당 페이지는 빌게이트 결제를 위한 "인증결과 리턴 및 승인요청/응답 "테스트 페이지 입니다.
	------------------------------------------------------------------------------------- 
	*/	
	/* 인증 결과 변수 */
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
	String serviceType = null;		//서비스 구분(일반:0000/월자동:1000)
	String confType = null;			//틴캐시_인증 타입 구분(0000:ID 인증/1000:PIN 인증)

	String message = null;			//인증 응답 MESSAGE

	//가상계좌
	String accountNumber = null;		//가상계좌번호
	String bankCode = null;				//발급 은행 코드
	String mixType = null;				//거래 구분(일반:0000/에스크로:1000)
	String expireDate = null;				//입금마감일자(YYYYMMDD)
	String expireTime = null;			//입금마감시간(HH24MISS)
	String amount = null;					//입금예정금액

	/* 승인 결과 변수 */
	String outTransactionId = null;
	String outResponseCode = null;
	String outResponseMessage = null;
	String outDetailResponseCode = null;
	String outDetailResponseMessage = null;

	String authAmount = null; 		// 승인응답 추가 파라미터	_승인금액
	String authNumber = null;		// 승인응답 추가 파라미터_승인번호
	String authDate = null;			// 승인응답 추가 파라미터_승인일시

	String quota = null;					//신용카드 승인응답 추가 파라미터_할부개월 수 
	String cardCompanyCode = null; //신용카드 승인응답 추가 파라미터_발급사 코드 
	
	String balance = null;					//캐시게이트 승인응답 추가 파라미터_잔액
	String dealAmount = null;			//캐시게이트 승인응답 추가 파라미터_승인금액
	
	String usingType = null;				//계좌이체 승인응답 추가 파라미터_현금영수증 용도
	String identifier = null;				//계좌이체 승인응답 추가 파라미터_현금영수증 승인번호
	String identifierType = null;		//계좌이체 승인응답 추가 파라미터_현금영수증 자진발급 유무
	String inputBankCode = null;		//계좌이체  승인응답 추가 파라미터_은행 코드 
	String inputAccountName = null;	//계좌이체  승인응답 추가 파라미터_은행명

	String partCancelType = null;		//휴대폰 승인응답 추가 파라미터_부분 취소 타입(일반 결제시에만 전달)

	Map<String,String> authInfo = null;	 //승인요청 정보 저장

	Message respMsg = null;			

	try{
			
		//================================================
		// 1. 인증 결과 파라미터 수신
		//================================================
		request.setCharacterEncoding("euc-kr");
		
		serviceType = request.getParameter("SERVICE_TYPE");						//서비스 타입(일반 :0000 , 월자동:1000)
		confType = request.getParameter("CONF_TYPE");								//결제 인증 타입(ID인증: 0000, PIN인증: 1000) *틴캐시 
		serviceId = request.getParameter("SERVICE_ID");								//가맹점 서비스 아이디
		serviceCode = request.getParameter("SERVICE_CODE");						//결제 수단 별 서비스코드
		orderId = request.getParameter("ORDER_ID");										//주문 번호
		orderDate = request.getParameter("ORDER_DATE");							//주문 일자
		transactionId = request.getParameter("TRANSACTION_ID");					//거래번호
		responseCode = request.getParameter("RESPONSE_CODE");								//응답코드
		responseMessage = request.getParameter("RESPONSE_MESSAGE");					//응답메시지
		detailResponseCode = request.getParameter("DETAIL_RESPONSE_CODE");		//상세 응답코드
		detailResponseMessage = request.getParameter("DETAIL_RESPONSE_MESSAGE");//상세 응답 메시지

		message = request.getParameter("MESSAGE");								//인증 응답 전문 메시지
	
		reserved1 = request.getParameter("RESERVED1");							//예비변수1
		reserved2 = request.getParameter("RESERVED2");							//예비변수2
		reserved3 = request.getParameter("RESERVED3");							//예비변수3

		/*가상계좌 채번 응답*/		
		accountNumber =request.getParameter("ACCOUNT_NUMBER");			//가상계좌번호
		bankCode =request.getParameter("BANK_CODE");							//발급 은행 코드
		mixType = request.getParameter("MIX_TYPE");								//거래 구분(일반:0000/에스크로:1000)
		expireDate = request.getParameter("EXPIRE_DATE");						//입금마감일자(YYYYMMDD)
		expireTime = request.getParameter("EXPIRE_TIME");						//입금마감시간(HH24MISS)
		amount = request.getParameter("AMOUNT");									//입금예정금액
	
		//================================================
		// 2. 인증 성공일 경우에만 승인 요청 진행
		//================================================
		if(("0000").equals(responseCode)&&!("1800".equals(serviceCode))){ //가상계좌 제외
			
		//결제 정보 Map에 저장
		authInfo = new HashMap<String,String>();

		authInfo.put("serviceId", serviceId);
		authInfo.put("serviceCode", serviceCode);
		authInfo.put("message", message);

		//================================
		// 4. 승인 요청 & 승인 응답 결과 설정  
		//================================				
		//승인 요청(Message)
		respMsg = MessageAuthProcess(authInfo);

		//결제 수단 별 승인 응답 분리
		//휴대폰
		if("1100".equals(serviceCode)){ 			

			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");			//거래번호
			authDate = respMsg.get("1005");					//승인일시
			authAmount = respMsg.get("1007");				//승인금액
			partCancelType =respMsg.get("7049");			//부분 취소 타입

		//신용카드	
		}else if("0900".equals(serviceCode)){		
	
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");				//거래번호
			authNumber = respMsg.get("1004");					//승인번호	
			authDate = respMsg.get("1005");						//승인일시
			authAmount = respMsg.get("1007");					//승인금액
			quota = respMsg.get("0031");								//할부개월 수
			cardCompanyCode = respMsg.get("0034");			//카드발급사 코드

		
		//계좌이체
		}else if("1000".equals(serviceCode)){		
		
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");			//거래번호
			authAmount = respMsg.get("1007");				//승인금액
			authDate = respMsg.get("1005");					//승인일시
			usingType = respMsg.get("0015");					//현금영수증 용도
			identifier = respMsg.get("0017");					//현금영수증 승인번호
			identifierType = respMsg.get("0102");				//현금영수증 자진발급제유무
			mixType = respMsg.get("0037");						//거래구분
			inputBankCode = respMsg.get("0105");			//은행 코드
			inputAccountName = respMsg.get("0107");		//은행 명
		
		//도서문화상품권	
		}else if("0100".equals(serviceCode)){
		
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");			//거래번호
			authDate = respMsg.get("1005");					//승인일시	
			authNumber = respMsg.get("1004");				//승인번호	
			authAmount = respMsg.get("1007");				//승인금액		
	
		//문화상품권
		}else if("0200".equals(serviceCode)){
		
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시	
			authNumber = respMsg.get("1004");			//승인번호	
			authAmount = respMsg.get("1007");			//승인금액
		
		//게임문화상품권
		}else if("0300".equals(serviceCode)){
			
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시	
			authNumber = respMsg.get("1004");			//승인번호	
			authAmount = respMsg.get("1007");			//승인금액
		
		//해피머니상품권
		}else if("0500".equals(serviceCode)){
			
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시	
			authNumber = respMsg.get("1004");			//승인번호	
			authAmount = respMsg.get("1007");			//승인금액
		
		//캐시게이트	
		}else if("0700".equals(serviceCode)){		

			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			balance = respMsg.get("1006");					//결제 후 잔액
			dealAmount = respMsg.get("0012");			//승인금액(타 결제수단과  tag값이 다르므로 주의)
			authDate = respMsg.get("1005");				//승인일시
		
		//틴캐시	
		}else if("2500".equals(serviceCode)){		
		
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시	
			authNumber = respMsg.get("1004");			//승인번호	
			authAmount = respMsg.get("1007");			//승인금액

		// 에그머니	
		}else if("2600".equals(serviceCode)){		
		
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시	
			authNumber = respMsg.get("1004");			//승인번호	
			authAmount = respMsg.get("1007");			//승인금액
		
		//통합포인트	
		}else if("4100".equals(serviceCode)){		

			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시		
			authAmount = respMsg.get("1007");			//승인금액
		
		//티머니	
		}else if("1600".equals(serviceCode)){		
			
			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");				//승인일시		
			authAmount = respMsg.get("1007");			//승인금액
		
		//폰빌
		}else if("1200".equals(serviceCode)){	

			//승인 응답
			outResponseCode = respMsg.get("1002");
			outResponseMessage = respMsg.get("1003");
			outDetailResponseCode = respMsg.get("1009");
			outDetailResponseMessage = respMsg.get("1010");
			outTransactionId = respMsg.get("1001");		//거래번호
			authDate = respMsg.get("1005");						//승인일시		
			authAmount = respMsg.get("1007");			//승인금액

		//그 외
		}else {
%>				
			<script type="text/javascript">
				alert(<%=serviceCode%>+"RETURN 페이지 오류\n에러 메시지 : 결제수단의 서비스 코드를 확인해주세요!/ ");
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
			<td height="25" style="padding-left:10px" class="title01"># 현재위치 &gt;&gt; 결제테스트 &gt; <b>가맹점 Return Url</b></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td align="center">
				<table width="380" border="0" cellpadding="4" cellspacing="1" bgcolor="#B0B0B0">
					<tr>
						<td><b>인증결과</b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>가맹점 아이디</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>서비스 코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceCode%></b></td>
					</tr>
<%
	//휴대폰(1100), 폰빌(1200) 인증 결과 파라미터 추가_서비스타입(0000:일반/1000:월자동)
	if("1100".equals(serviceCode)||"1200".equals(serviceCode)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>서비스 타입</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=serviceType%></b></td>
					</tr>
<%
    }
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>주문번호</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderId%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>주문일시</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=orderDate%></b></td>
					</tr>
<%
	//캐시게이트(0700), 신용카드(0900) 거래번호 출력 제외
	if(!("0700".equals(serviceCode)||"0900".equals(serviceCode))){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>거래번호</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=transactionId%></b></td>
					</tr>
<%
    } 
	 //가상계좌(1800) 채번 정보
    if ("1800".equals(serviceCode) && "0000".equals(responseCode)) 
    {
%>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>가상계좌번호</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=accountNumber%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>금액</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=amount%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>은행코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=bankCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>거래구분</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=mixType%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>입금 유효 만료일</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=expireDate%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>입금 마감 시간</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=expireTime%></b></td>
					</tr>
<% 
    } 
	//틴캐시(2500) 인증구분
	if("2500".equals(serviceCode)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>인증 구분</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=confType%></b></td>
					</tr>
<%
	}	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>응답코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>응답메시지</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=responseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>상세응답코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>상세응답메시지</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=detailResponseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>예비변수1</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reserved1 %></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>예비변수2</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reserved2 %></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>예비변수3</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=reserved3 %></b></td>
					</tr>	
					
                    <!--인증결과 끝-->
                    <!--승인결과 시작-->

					<tr>
						<td><b>승인결과</b></td>
					</tr>
<%
    if (outResponseCode!=null){ 
%>	
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>거래번호</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outTransactionId%></b></td>
					</tr>					
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>승인일시</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=authDate%></b></td>
					</tr>
<% 
	//캐시게이트(0700) 일 경우, 결제금액은 dealAmount로 표시
	if("0700".equals(serviceCode)){	 
%>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>승인금액</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=dealAmount%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>잔액</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=balance%></b></td>
					</tr>			
<%
	}else{	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>승인금액</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=authAmount%></b></td>
					</tr>	
<%
}
	//신용카드(0900), 과세 금액 항목 추가
	if("0900".equals(serviceCode)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>할부개월 수</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=quota%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>카드 발급사 코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=cardCompanyCode%></b></td>
					</tr>
<%
	}
%>
				
<%
	//신용카드(0900), 계좌이체(0100), 문화상품권(0200), 게임문화상품권(0300), 해피머니상품권(0500), 틴캐시(2500),에그머니(2600), 승인 응답 파라미터 추가
	if("0900".equals(serviceCode)||"0100".equals(serviceCode)||"0200".equals(serviceCode)||"0300".equals(serviceCode)||"0500".equals(serviceCode)||"2500".equals(serviceCode)||"2600".equals(serviceCode)){	
%>			
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>승인번호</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=authNumber%></b></td>
					</tr>			
<%
	}
	//계좌이체(1000)일 경우, 응답 파라미터 추가		
	if("1000".equals(serviceCode)){		
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>거래구분</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=mixType%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>현금영수증 용도</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=usingType%></b></td>
					</tr>	
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>현금영수증 승인번호</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=identifier%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>현금영수증 자진발급제유무</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=identifierType%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>은행 코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=inputBankCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>은행명</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=inputAccountName%></b></td>
					</tr>
<%
	}	
	//휴대폰(1100)이면서 일반 결제(serviceType:0000) 일 경우, 승인 응답 파라미터 추가
	if("1100".equals(serviceCode)&&"0000".equals(serviceType)){
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>부분 취소 타입</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=partCancelType%></b></td>
					</tr>	
<%
	}	
%>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>응답코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>응답메시지</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outResponseMessage%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>상세응답코드</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outDetailResponseCode%></b></td>
					</tr>
					<tr>
						<td width="100" align="center" bgcolor="#F6F6F6"><b>상세응답메시지</b></td>
						<td width="200" align="left" bgcolor="#FFFFFF">&nbsp;<b><%=outDetailResponseMessage%></b></td>
					</tr>
<%
	}else{						
%>
					<tr>
						<td width="300" align="center" bgcolor="#F6F6F6" colspan="2"><b>승인 결과 없음</b></td>
					</tr>		
<%
	}	
%>					
					<!-- 승인결과 끝-->
			</table>
			</td>
		</tr>
	</table>
		
	<%	
	}catch(Exception ex){
%>				
			<script type="text/javascript">
				alert("RETURN 페이지 오류\n에러 메시지 : 승인 요청 오류! ");
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