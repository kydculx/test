<%@ page contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%@ page import="java.util.* "%>    
<%
	/*
	 ------------------------------------------------------------------------------------- 
	 해당 페이지는 빌게이트 결제를 위한 "결제 요청(인증요청)" 테스트 페이지 입니다.
	 ------------------------------------------------------------------------------------- 

	 ※테스트 결제를 원하신다면,
	 1. 결제 정보 (returnUrl, cancelUrl) 가맹점 환경에 맞게 변경
	 2. PayReturn.jsp의 CONF_PATH경로 설정 (config.ini 경로 설정)
	 3. CancleReturn.jsp의 CONF_PAHT경로 설정	(config.ini 경로 설정)
	 4. config.ini 의 로그 파일 경로 및 권한 설정
	 	- 해당 설정 완료 후 그대로 테스트 결제 진행하시면 됩니다.
	 
	 ※실제 상용 테스트를 원하신다면,
	 1. 결제 정보 (serviceId, returnUrl, cancelUrl)를 변경  -> 계약 시 받은 serviceId 정보를 넣으시면 됩니다.
	 2. config.ini 의 Key,Iv 값 변경 (가맹점 관리자 어드민에서 확인 가능)
	 3. config.ini 의 mode = 1(상용)으로 변경 후 실 결제 테스트 하시길 바랍니다. 
	  	- 상용 테스트는 실제 과금이 이뤄지는 점 유의하시길 바랍니다.
	  	------------------------------------------------------------------------------------- 
	*/
	
	//변수 정의
	String transactionId = null;
	String responseCode =null;  
	String responseMessage = null;
	String detailResponseCode = null;
	String detailResponseMessage = null;
	String serviceCode = null;
	
	//날짜변수 선언 
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
	// 1. 가맹점 결제 요청 테스트 공통 정보
	//================================================
	String serviceId			="glx_api";				//테스트 아이디 일반결제 : glx_api	
	String userId 				="user_id";
	String itemName		="테스트상품_123";
	String itemCode			="item_code";
	String amount			="1004";
	String userName		="홍길동";
	String userEmail		="test@test.com";		
	String orderDate		= year+month+date+hour+minute+second ;
	String orderId			="test_"+orderDate;
	String returnUrl			="http://127.0.0.1/BillgatePay-JSP/PayReturn.jsp";  // *가맹점 수정 필수 
	String checkSum		="";
	String cancelFlag		="Y";
	String reserved1		="예비변수1";
	String reserved2		="예비변수2";
	String reserved3		="예비변수3";
    
	//================================================
	// 2. 결제 요청 시 위변조 방지를 위한 CHECKSUM 생성
	//================================================
	/*
	*	*CHECK_SUM 
	*	: 결제 요청 시 위변조 방지 체크를 위해 CHECK_SUM 생성
	*	SERVICE_ID , ORDER_ID , AMOUNT 3개의 값을 가지고 당사 결제 모듈 billgateApi.jar를 통해 중복되지 않는 유일한 값 생성.		
	*/		
	String temp = serviceId + orderId + amount;
	checkSum = ChecksumUtil.genCheckSum(temp);

%>
<html>
<head>
<meta charset="EUC-KR">
<title>빌게이트 결제 테스트 샘플페이지</title>
<!--테스트 서버 js-->
<script type="text/javascript" src="http://tpay.billgate.net/paygate/plugin/gx_web_client.js" />
<!--상용 서버 js-->
<!--<script type="text/javascript" src="https://pay.billgate.net/paygate/plugin/gx_web_client.js" /> -->
<script type="text/javascript"></script>
<script>

	//============================================================
    // 결제창 호출 
    //==========================================================
    function checkSubmit(viewType) {
        var serviceCode = document.getElementById("selectPay").value;

        if ("null" == serviceCode || "" == serviceCode) {
            alert("결제수단을 선택해주세요.");
            return;
        }

		if ("null" == viewType || "" == viewType) {
			alert("뷰 타입을 입력해주세요.");
			return;
		}

		/*
		GX_pay(
		frmName : 결제 form name 입력, 
		viewType : layerpopup 레이어팝업, popup : 윈도우팝업, submit : 페이지 이동 
		protocolType : http_tpay(테스트 http), https_tpay(테스트 https), https_pay(상용 https)
		*/	
		GX_pay("payment",viewType,"https_tpay");
    }

	//==========================
	// 레이어 팝업 닫기
	//==========================
	function layer_close(){
		GX_payClose();
	}

	//==========================
	// 체크섬 재생성
	//==========================
	function makeCheckSum(){
		var HForm = document.payment;
		HForm.ORDER_ID.value = "test_"+getStrDate();	//주문번호 재생성
		
	    var CheckSum = HForm.SERVICE_ID.value + HForm.ORDER_ID.value + HForm.AMOUNT.value;
		var xhr = new XMLHttpRequest();
		var data = "CheckSum="+CheckSum;

		//Ajax 통신
		xhr.onload = function(){
			if(xhr.readyState == 4 && xhr.status == 200){ //통신 성공 시
				console.log(xhr.responseText);
				HForm.CHECK_SUM.value = xhr.responseText.trim();  //재생성된 체크썸
			}
		};
		
		xhr.open("POST","./PayCheckSum.jsp",true);
		xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
		xhr.send(data);    
	}
 
	//==========================
	// 현재 날짜시간 가져오기
	//==========================
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
	
	//==========================
	// 결제 수단 선택
	//==========================
    function paySelect() {

		var HForm = document.payment;

		var serviceCodeSelect = document.getElementById("selectPay");
		var serviceCode = serviceCodeSelect.options[serviceCodeSelect.selectedIndex].value;
		
		HForm.SERVICE_CODE.value = serviceCode;
		HForm.ORDER_ID.value = "test_" + getStrDate();//주문번호 재생성
		HForm.ORDER_DATE.value = getStrDate();			//주문일시 재생성
		makeCheckSum();

		document.getElementById("add_view").style.display="none";
		document.getElementById("add_card_view1").style.display="none";
		document.getElementById("add_card_view2").style.display="none";
		document.getElementById("add_card_view3").style.display="none";
		document.getElementById("add_vaccount_view").style.display="none";
		document.getElementById("add_mobile_view1").style.display="none";
		document.getElementById("add_mobile_view2").style.display="none";
		document.getElementById("add_moneytree_view").style.display="none";
		document.getElementById("add_common_view1").style.display="none";
		document.getElementById("add_common_view2").style.display="none";

		//결제창 호출 URL설정
		switch(serviceCode){
			case'0900':	//신용카드
				document.getElementById("add_view").style.display="";
				document.getElementById("add_card_view1").style.display="";
				document.getElementById("add_card_view2").style.display="";
				document.getElementById("add_card_view3").style.display="";

				break;

			case'1800':	//가상계좌
				document.getElementById("add_view").style.display="";
				document.getElementById("add_vaccount_view").style.display="";
				document.getElementById("add_common_view2").style.display="";

				break;

			case'1100':	//휴대폰
				document.getElementById("add_view").style.display="";
				document.getElementById("add_mobile_view1").style.display="";
				document.getElementById("add_mobile_view2").style.display="";
				document.getElementById("add_common_view1").style.display="";
				
				(document.getElementsByName("SOCIAL_NUMBER"))[0].disabled = false;
				(document.getElementsByName("SOCIAL_NUMBER"))[1].disabled = true;

				break;

			case'4100':	//머니트리
				document.getElementById("add_view").style.display="";
				document.getElementById("add_moneytree_view").style.display="";
				document.getElementById("add_common_view1").style.display="";
				
				(document.getElementsByName("SOCIAL_NUMBER"))[0].disabled = true;
                (document.getElementsByName("SOCIAL_NUMBER"))[1].disabled = false;
				
				break;

			default:	//그외
				break;
		}	
    }
</script>	
<style>
	header{position: fixed;	top: 0;	left: 0; right: 0;}	
	body, tr, td {font-size:9pt; font-family:맑은고딕,verdana; }
	table {	border-collapse: collapse;}	}
</style>
</head>
<body>
<header>
	<div style="width:100%; heghit:12px; font-size:13px; font-weight:bold; color: #FFFFFF; background:#ff4280;text-align: center;">
		빌게이트 결제 테스트 샘플페이지
	</div>
</header>

	<div id="payAll">
		<div style="padding : 20px 0 20px 0; width:100%; display: block; float:left">
			<b style="color:red;"><유의사항></b><br/>
		<b>- 당사에서 제공하는 샘플은 연동에 이해를 돕기위해 단계별로 나열한 것이므로, 동일한 구조를 유지할 필요가 없음을 알려드립니다.</b><br/>
		- SERVICE_ID, AMOUNT, ORDER_ID 변경 시 <b>[체크썸 재생성]</b> 버튼을 클릭하여 체크썸을 재생성하여야 결제가 가능합니다.<br/>
		- 거래 건 구별을 위해 중복된 주문번호(ORDER_ID)로 과금 요청은 권장하지 않습니다.<br/>	
		</div>
		
	<div style="width:100%; display: block; float:left;">
			<form name="payment" method="post">
				<table border="1px solid" cellpadding="5" cellspacing="1" bgcolor="#B0B0B0">	
					<tr>
						<td colspan="4" height="20" align="left" bgcolor="#C0C0C0"><b>결제 정보</b></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">결제수단</td>
						<td width="150" bgcolor="#FFFFFF" colspan="3">
							<select id="selectPay" onChange="paySelect()">
								<option value="" selected>==선택==</option>
								<option value="0100">도서(0100)</option>
								<option value="0200">문화(0200)</option>
								<option value="0300">게임문화(0300)</option>
								<option value="0500">해피머니(0500)</option>
								<option value="0700">캐시게이트(0700)</option>
								<option value="0900">신용카드(0900)</option>
								<option value="1100">휴대폰(1100)</option>
								<option value="1200">폰빌(1200)</option>
								<option value="1600">티머니(1600)</option>
								<option value="1800">가상계좌(1800)</option>
								<option value="1000">계좌이체(1000)</option>
								<option value="2500">틴캐시(2500)</option>
								<option value="2600">에그머니(2600)</option>
								<option value="4100">통합포인트(4100)</option>
							</select>
						</td>
					</tr>	
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">가맹점아이디<br/>(SERVICE_ID)</td>
						<td  width="150" bgcolor="#FFFFFF"><input type="text" name="SERVICE_ID" id="SERVICE_ID" size=30 class="input" value="<%=serviceId%>"><br/>(일반결제:glx_api)</td>
						<td width="150" align="left" bgcolor="#F6F6F6">결제타입<br/>(SERVICE_TYPE)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="SERVICE_TYPE" size=40 class="input" value="0000"><br/>(일반결제:0000)</td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">서비스코드<br/>(SERVICE_CODE)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="SERVICE_CODE" id="SERVICE_CODE" size=30 class="input" value=""></td>
						<td width="150" align="left" bgcolor="#F6F6F6">결제 금액<br/>(AMOUNT)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="AMOUNT" size=40 class="input" value="<%=amount%>"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">상품명<br/>(ITEM_NAME)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="ITEM_NAME" size=30 class="input" value="<%=itemName%>"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">상품코드<br/>(ITEM_CODE)</td>
						<td bgcolor="#FFFFFF"><input type="text" name="ITEM_CODE" size=40 class="input" value="<%=itemCode%>"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">고객 아이디<br/>(USER_ID)</td>
						<td bgcolor="#FFFFFF"><input type="text" name="USER_ID" size=30 class="input" value="<%=userId%>"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">고객명<br/>(USER_NAME)</td>
						<td bgcolor="#FFFFFF"><input type="text" name="USER_NAME" size=40 class="input" value="<%=userName%>"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">주문번호<br/>(ORDER_ID)</td>
						<td bgcolor="#FFFFFF"><input type="text" name="ORDER_ID" size=30 class="input" value="<%=orderId%>"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">주문일시<br/>(ORDER_DATE)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="ORDER_DATE" size=40 class="input" value="<%=orderDate%>"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">리턴URL<br/>(RETURN_URL)</td>
						<td bgcolor="#FFFFFF" colspan="3"><input type="text" name="RETURN_URL" size=80 class="input" value="<%=returnUrl%>"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">고객이메일<br/>(USER_EMAIL)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="USER_EMAIL" size=30 class="input" value="<%=userEmail%>"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">CheckSum<br/>(CHECK_SUM)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="CHECK_SUM" size=40 class="input" value=""><input type="button" name="" value="체크썸 재생성" onclick="javascript:makeCheckSum()"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">예비변수1<br/>(RESERVED1)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="RESERVED1" size=30 class="input" value="<%=reserved1%>"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">예비변수2<br/>(RESERVED2)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="RESERVED2" size=40 class="input" value="<%=reserved2%>"></td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">예비변수3<br/>(RESERVED3)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="RESERVED3" size=30 class="input" value="<%=reserved3%>"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">취소결과 전달여부<br/>(CANCEL_FLAG)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="CANCEL_FLAG" size=40 class="input" value="<%=cancelFlag%>"><br/>(Y:Return 취소 응답, N:self.close())</td>
					</tr>
					<tr>
						<td width="150" align="left" bgcolor="#F6F6F6">로고<br/>(LOGO)</td>
						<td width="150" bgcolor="#FFFFFF" colspan="3"><input type="text" name="LOGO" size=80 class="input" value=""><br/>(이미지 로고 URL 입력)</td>
					</tr>
					<tr id="add_view" style="display:none;">
						<td colspan="4"><b>추가 파라미터</b></td>
					</tr>

					<!-- 신용카드 영역start -->
					<tr id="add_card_view1" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">할부개월수<br/>(INSTALLMENT_PERIOD)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="INSTALLMENT_PERIOD" size=30 class="input" value="0:3:6:9:12"></td>
						<td width="150" align="left" bgcolor="#F6F6F6">카드사선택<br/>(CARD_TYPE)</td>
						<td bgcolor="#FFFFFF">
							<select name="CARD_TYPE" >
								<option value="0000">---카드사 선택---</option>
									<option value="0052">비씨카드(BC card)</option>
									<option value="0050">국민카드(KB card)</option>
									<option value="0073">현대카드(Hyundai card)</option>
									<option value="0054">삼성카드(Samsung card)</option>
									<option value="0053">신한(LG)카드(Shinhan(LG) card)</option>
									<option value="0055">롯데카드(Lotte card)</option>
									<option value="0089">저축은행(savings bank)</option>
									<option value="0051">외환카드(Yes card)</option>
									<option value="0076">하나(Hana card)</option>
									<option value="0079">제주(e-jeju bank)</option>
									<option value="0080">광주(kjbank)</option>
									<option value="0073">신협(현대)(cu(Hyundai))</option>
									<option value="0075">수협(suhyup)</option>
									<option value="0081">전북(jbbank)</option>
									<option value="0078">농협(NH card)</option>
									<option value="0084">씨티(Citi card)</option>
							</select>
						</td>
					</tr>
					<tr id="add_card_view2" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">[해외전용]국내/해외카드<br/>(USING_TYPE)</td>
						<td width="150" bgcolor="#FFFFFF" ><input type="text" name="USING_TYPE" size=30 class="input" value="">(0001:해외카드, 그외)</td>
						<td width="150" align="left" bgcolor="#F6F6F6">[해외전용]승인통화구분<br/>(CURRENCY)</td>
						<td width="150" bgcolor="#FFFFFF" ><input type="text" name="CURRENCY" size=30 class="input" value=""><br/>(0000:원화승인, 0001:달러승인)</td>
					</tr>
					<tr id="add_card_view3" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">인증밴더 직접호출<br/>(DIRECT_USE)</td>
						<td width="150" bgcolor="#FFFFFF"  colspan="3"><input type="text" name="DIRECT_USE" size=30 class="input" value="">(0001:직접호출, 그외)</td>
					</tr>
					<!-- 신용카드 영역end -->
					<!-- 휴대폰 영역start -->
					<tr id="add_mobile_view1" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">주민번호 앞6자리<br/>(SOCIAL_NUMBER)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="SOCIAL_NUMBER" size=30 class="input" value="" maxlength="6"><br/>생년월일(YYMMDD)</td>
						<td width="150" align="left" bgcolor="#F6F6F6">이동통신사 코드<br/>(MOBILE_COMPANY_CODE)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="MOBILE_COMPANY_CODE" size=30 class="input" value="" maxlength="4"><br/>0000:SKT, 0001:KT, 0002:LGU, 0011:CJH, 0010:KCT, 0012:SKL</td>
					</tr>
					<tr id="add_mobile_view2" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">사전전달 휴대폰번호 수정여부<br/>(READONLY_HP)</td>
						<td width="150" bgcolor="#FFFFFF" colspan="3"><input type="text" name="READONLY_HP" size=30 class="input" value=""><br/>(Y:수정불가, N:수정가능)</td>
					</tr>
					<!-- 휴대폰 영역 end-->
					<!-- 통합포인트 영역 start-->
					<tr id="add_moneytree_view" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">생년월일<br/>(SOCIAL_NUMBER)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="SOCIAL_NUMBER" size=30 class="input" value="" maxlength="8"><br/>(YYYYMMDD)</td>
						<td width="150" align="left" bgcolor="#F6F6F6">회원 CI<br/>(USER_CI)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="USER_CI" size=30 class="input" value=""><br/></td>
					</tr>
					<!-- 통합포인트 영역 end-->
					<!-- 가상계좌 영역 start -->
					<tr id="add_vaccount_view" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">입금마감 유효일<br/>(QUOTA)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="QUOTA" size=30 class="input" value="" maxlength="2"><br/>(미입력시 기본(5), 지정가능일[1 - 30])</td>
						<td width="150" align="left" bgcolor="#F6F6F6">입금마감 유효시간<br/>(EXPIRE_TIME)</td>
						<td width="150" bgcolor="#FFFFFF"><input type="text" name="EXPIRE_TIME" size=30 class="input" value="" maxlength="6"><br/>(미입력시 기본(235959) [HH24MISS])</td>
					</tr>
					<!-- 가상계좌 영역 end-->
					<!-- (휴대폰, 통합포인트) 영역 start-->
					<tr id="add_common_view1" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">휴대폰 번호<br/>(MOBILE_NUMBER)</td>
						<td width="150" bgcolor="#FFFFFF" colspan="3"><input type="text" name="MOBILE_NUMBER" size=30 class="input" value="" maxlength="11"><br/>-(하이픈) 없이 입력</td>
					</tr>
					<!-- (휴대폰, 통합포인트) 영역 end-->
					<!-- 가상계좌 영역 start -->
					<tr id="add_common_view2" style="display:none;">
						<td width="150" align="left" bgcolor="#F6F6F6">에스크로 사용 여부(ESCROW_FLAG)</td>
						<td width="150" bgcolor="#FFFFFF" colspan="3"><input type="text" name="ESCROW_FLAG" size=30 class="input" value="">(Y:에스크로 필수 동의, N:에스크로 미적용)</td>
					</tr>
					<!-- 가상계좌 영역 end -->		
				</table>
			</form>

		<div>
			<br/><input type="button" value="결제창 호출(layerpopup) PC 전용" onclick="javascript:checkSubmit('layerpopup');">
							&nbsp;<input type="button" value="결제창 호출(submit)" onclick="javascript:checkSubmit('submit');">
							&nbsp;<input type="button" value="결제창 호출(popup)" onclick="javascript:checkSubmit('popup');">	
		</div>
	</div>				
			
</body>
</html>