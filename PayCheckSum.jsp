<%@ page language="java" contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%
	/*
	------------------------------------------------------------------------------------- 
	해당 페이지는 빌게이트 결제를 위한 "위 /변조 방지 항목인 체크썸 생성 "테스트 페이지 입니다.
	------------------------------------------------------------------------------------- 
	*/	
	
	String reqCheckSum = null;
	String respCheckSum = null;
	
	request.setCharacterEncoding("euc-kr");
	
	reqCheckSum = request.getParameter("CheckSum");
	respCheckSum = ChecksumUtil.genCheckSum(reqCheckSum);
	
	out.print(respCheckSum);	
%>
