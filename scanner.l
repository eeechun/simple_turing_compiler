%{
#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include "y.tab.hpp"
#include <iostream>
using namespace std;

#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",#t); return(t);}
#define tokenInteger(t,i) {LIST; printf("<%s: %s>\n",#t,i);}
#define tokenString(t,s) {LIST; printf("<%s: %s>\n",#t,s);}
#define yyinput input
#define MAX_LINE_LENG 256

int linenum = 1;
int flag = 0;
int str_flag = 1;
int str_init = 0;
char buf[MAX_LINE_LENG];
char strBuf[MAX_LINE_LENG];

%}

%x STR
%x COMMENT

%%
"("         	{token(PARENTHESES_L);}
")"	        	{token(PARENTHESES_R);}
"["         	{token(SQUARE_BRACKETS_L);}
"]"	        	{token(SQUARE_BRACKETS_R);}
"{"         	{token(BRACKETS_L);}
"}"	        	{token(BRACKETS_R);}
","	        	{token(COMMA);}
"."	        	{token(DOT);}
":"	        	{token(COLON);}
";"	        	{token(SEMICOLON);}
"+"	        	{token(ADD);}
"-"	        	{token(SUB);}
"*"	        	{token(MUL);}
"/"	        	{token(DIV);}
"mod"	    	{token(MOD);}
":="	    	{token(ASSIGN);}
"<"	        	{token(LT);}
"<="	    	{token(LE);}
">="	    	{token(GE);}
">"	        	{token(GT);}
"="	        	{token(EQ);}
"not ="	        {token(NE);}
"and"	        {token(AND);}
"or"			{token(OR);}
"not"	        {token(NOT);}
"array"	        {token(ARRAY);}
"begin"	        {token(BEGIN_);}
"bool"	        {token(BOOL);}
"char"	        {token(CHAR);}
"const"	        {token(CONST);}
"decreasing"    {token(DECREASING);}
"default"       {token(DEFAULT);}
"do"	        {token(DO);}
"else"	        {token(ELSE);}
"end"	        {token(END);}
"exit"	        {token(EXIT);}
"for"	        {token(FOR);}
"function"      {token(FUNCTION);}
"get"	        {token(GET);}
"if"	        {token(IF);}
"int"	        {token(INT);}
"loop"	        {token(LOOP);}
"of"	        {token(OF);}
"put"	        {token(PUT);}
"procedure"     {token(PROCEDURE);}
"real"	        {token(REAL);}
"result"        {token(RESULT);}
"return"        {token(RETURN);}
"skip"	        {token(SKIP);}
"string"        {token(STRING);}
"then"	        {token(THEN);}
"var"	        {token(VAR);}
"when"	        {token(WHEN);}
"false"	        {
	LIST;
	yylval.boolVal = false;
	printf("<FALSE>\n");
	return BOOL_VAL;
}
"true"	        {
	LIST;
	yylval.boolVal = true;
	printf("<TRUE>\n");
	return BOOL_VAL;
}
[0-9]+	        {
	tokenInteger(integer, yytext);
	yylval.intVal = atoi(yytext);
	return INT_VAL;
}
(0|([1-9][0-9]*))"."[0-9]+	{
	tokenString(real, yytext);
	yylval.dVal = atof(yytext);
	return REAL_VAL;
}
[0-9]+"."[0-9]+[Ee][+-]?[0-9]+ 	{
	tokenString(real, yytext);
	yylval.dVal = atof(yytext);
	return REAL_VAL;	
}
[A-Za-z]([A-Za-z]|[0-9]+)*		{
	str_flag = 0;
	tokenString("id",yytext);
	yylval.strVal = strdup(yytext);
	return ID;
}

"\"" {
	str_init = 1;
        LIST;
        strBuf[0]='\0';
        BEGIN STR;   	
}

<STR>"\"" {
        char c = yyinput();
        if(c != '\"'){
        	if(!flag && c != '\n'){
        		str_flag = 0;
        		BEGIN INITIAL;
        	}
        	flag = 0; 
        	str_flag = 1;
			tokenString(string, strBuf);
			yylval.strVal = strdup(strBuf);
        	unput(c);
        	BEGIN INITIAL;
			return STR_VAL;	
        }
        else{
        	LIST;
        	flag = 1;
        	strcat(buf,"\"");
        	strcat(strBuf,"\"");
        }
}

<STR>([^"\n])* {
	LIST;
	strcat(strBuf, yytext);	
}
<STR>\n {	//"a"b
	if(!str_flag){
		printf("<\">\n");
	}
	if(strBuf[0] != '\0'){
		tokenString(id, yytext);
		yylval.strVal = strdup(strBuf);
	}
	unput('\n');
	BEGIN INITIAL;
	
	return ID;
}

"%"([^"\n])*    {
        LIST;
}

"{%"	{
	LIST;
	BEGIN COMMENT;
}
<COMMENT>. {LIST;}
<COMMENT>\n {
	LIST;
	printf("%d: %s\n", linenum++, buf);
	buf[0] = '\0';
	
}
<COMMENT>"%}" {
        LIST;  
        BEGIN INITIAL;
}


\n  {
		str_flag = 1 ;
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
	}

[ \t]*	{LIST;}

.	{
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
}
%%