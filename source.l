%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n","t");}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n","t",i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n","t",s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
%}

digits	[0-9]+
integer	{digits}
plain_real	(0|([1-9][0-9]*))"."[0-9]+
expreal	{digits}"."{digits}[Ee][+-]?{digits}
real	{plain_real}|{expreal}
letter	[A-Za-z]
id		{letter}({letter}|{digits})*

%s		COMMENT

%%
<INITIAL>	"("     {token('(');}
<INITIAL>	")"		{token(')');}
<INITIAL>	"["     {token('[');}
<INITIAL>	"]"		{token(']');}
<INITIAL>	"{"     {token('{');}
<INITIAL>	"}"		{token('}');}
<INITIAL>	","		{token(',');}
<INITIAL>	"."		{token('.');}
<INITIAL>	":"		{token(':');}
<INITIAL>	";"		{token(';');}
<INITIAL>	"+"		{token('+');}
<INITIAL>	"-"		{token('-');}
<INITIAL>	"*"		{token('*');}
<INITIAL>	"/"		{token('/');}
<INITIAL>	"mod"	{token('mod');}
<INITIAL>	"array"	{token('array');}
<INITIAL>	"begin"	{token('begin');}
<INITIAL>	"bool"	{token('bool');}
<INITIAL>	"char"	{token('char');}
<INITIAL>	"const"	{token('const');}
<INITIAL>	"decreasing"	{token('decreasing');}
<INITIAL>	"default"	{token('default');}
<INITIAL>	"do"	{token('do');}
<INITIAL>	"else"	{token('else');}
<INITIAL>	"end"	{token('end');}
<INITIAL>	"exit"	{token('exit');}
<INITIAL>	"false"	{token('false');}
<INITIAL>	"for"	{token('for');}
<INITIAL>	"function"	{token('function');}
<INITIAL>	"get"	{token('get');}
<INITIAL>	"if"	{token('if');}
<INITIAL>	"int"	{token('int');}
<INITIAL>	"loop"	{token('loop');}
<INITIAL>	"of"	{token('of');}
<INITIAL>	"put"	{token('put');}
<INITIAL>	"procedure"	{token('procedure');}
<INITIAL>	"real"	{token('real');}
<INITIAL>	"result"	{token('result');}
<INITIAL>	"return"	{token('return');}
<INITIAL>	"skip"	{token('skip');}
<INITIAL>	"string"	{token('string');}
<INITIAL>	"then"	{token('then');}
<INITIAL>	"true"	{token('true');}
<INITIAL>	"var"	{token('var');}
<INITIAL>	"when"	{token('when');}
<INITIAL>	digits	{tokenInteger(integer, yytext);}
<INITIAL>	real	{tokenString(real, yytext);}
<INITIAL>	id		{tokenString(id, yytext);}

\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%
int main(){
        while(1){
                yylex();
        }
}