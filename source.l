%{
#include "stdio.h"
#include "stdlib.h"
#include <iostream>
#include <vector>
#include <algorithm>
#include <unistd.h>
using namespace std;
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",#t);}
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

class symbolTable{
private:
	vector<string> symbol;
	
public:
	symbolTable();
	int lookup(const string& s);
	int insert(const string& s);
	int dump();
};

symbolTable *table;
%}

%x STR
%x COMMENT

%%
"("             {token('(');}
")"	        {token(')');}
"["             {token('[');}
"]"	        {token(']');}
"{"             {token('{');}
"}"	        {token('}');}
","	        {token(',');}
"."	        {token('.');}
":"	        {token(':');}
";"	        {token(';');}
"+"	        {token('+');}
"-"	        {token('-');}
"*"	        {token('*');}
"/"	        {token('/');}
"mod"	        {token('mod');}
":="	        {token(':=');}
"<"	        {token('<');}
"<="	        {token('<=');}
">="	        {token('>=');}
">"	        {token('>');}
"="	        {token('=');}
"not ="	        {token('not =');}
"and"	        {token(AND);}
"not"	        {token(NOT);}
"array"	        {token(ARRAY);}
"begin"	        {token(BEGIN);}
"bool"	        {token(BOOL);}
"char"	        {token(CHAR);}
"const"	        {token(CONST);}
"decreasing"    {token(DECREASING);}
"default"       {token(DEFAULT);}
"do"	        {token(DO);}
"else"	        {token(ELSE);}
"end"	        {token(END);}
"exit"	        {token(EXIT);}
"false"	        {token(FALSE);}
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
"true"	        {token(TRUE);}
"var"	        {token(VAR);}
"when"	        {token(WHEN);}
[0-9]+	        {tokenInteger(integer, yytext);}
[+-]?(0|([1-9][0-9]*))"."[0-9]+	{tokenString(real, yytext);}
[0-9]+"."[0-9]+[Ee][+-]?[0-9]+ 	{tokenString(real, yytext);}
[A-Za-z]([A-Za-z]|[0-9]+)*		{
	str_flag = 0;
	tokenString(id, yytext);
	table->insert(yytext);
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
        		//unput(c);
        		/*if(!str_flag && str_init){ 
        			printf("<\">\n");
        			str_flag = 0;
        		}*/
        		str_flag = 0;
        		BEGIN INITIAL;
        	}
        	flag = 0; 
        	str_flag = 1;
        	tokenString(string, strBuf);
        	unput(c);
        	//strBuf[0]='\0';
        	BEGIN INITIAL;
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
		tokenString(id, strBuf);
		table->insert(strBuf);
	}	
	unput('\n');
	BEGIN INITIAL;
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


\n      {
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
void create(){
	table = new symbolTable();
}

symbolTable::symbolTable(){
	symbol.clear();
}

int symbolTable::lookup(const string& s){
	vector<string>::iterator it = find(symbol.begin(), symbol.end(), s);
	if(it == symbol.end()){
		return -1;
	}
	else{
		return stoi(*it);
	}
}

int symbolTable::insert(const string& s){
	if(find(symbol.begin(), symbol.end(), s) == symbol.end()){
		symbol.push_back(s);
		return symbol.size();
		
	}
	else{
		return -1;
	}
}

int symbolTable::dump(){
	for(auto i : symbol) cout << i << "\n";
	return symbol.size();
}


int main(){
        create();
        yylex();
        cout << "Symbol Table:\n";
        table->dump();
        return 0;
}
