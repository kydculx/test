<%@ page language="java" contentType="text/html; charset=EUC-KR" %>
<%@ page import="com.galaxia.api.util.*"%>
<%
	/*
	------------------------------------------------------------------------------------- 
	�ش� �������� ������Ʈ ������ ���� "�� /���� ���� �׸��� üũ�� ���� "�׽�Ʈ ������ �Դϴ�.
	------------------------------------------------------------------------------------- 
	*/	
	
	String reqCheckSum = null;
	String respCheckSum = null;
	
	request.setCharacterEncoding("euc-kr");
	
	reqCheckSum = request.getParameter("CheckSum");
	respCheckSum = ChecksumUtil.genCheckSum(reqCheckSum);
	
	out.print(respCheckSum);	
%>
