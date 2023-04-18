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
plain_real	{digits}"."{digits}
expreal	{digits}"."{digits}[Ee][+-]?{digits}
real	{plain_real}|{expreal}
letter	[A-Za-z]

%%
"("     {token('(');}
")"		{token(')');}
"["     {token('[');}
"]"		{token(']');}
"{"     {token('{');}
"}"		{token('}');}
","		{token(',');}
"."		{token('.');}
":"		{token(':');}
";"		{token(';');}
"+"		{token('+');}
"-"		{token('-');}
"*"		{token('*');}
"/"		{token('/');}
"mod"	{token('mod');}
"array"	{token('array');}
"begin"	{token('begin');}
"bool"	{token('bool');}
"char"	{token('char');}
"const"	{token('const');}
"decreasing"	{token('decreasing');}
"default"	{token('default');}
"do"	{token('do');}
"else"	{token('else');}
"end"	{token('end');}
"exit"	{token('exit');}
"false"	{token('false');}
"for"	{token('for');}
"function"	{token('function');}
"get"	{token('get');}
"if"	{token('if');}
"int"	{token('int');}
"loop"	{token('loop');}
"of"	{token('of');}
"put"	{token('put');}
"procedure"	{token('procedure');}
"real"	{token('real');}
"result"	{token('result');}
"return"	{token('return');}
"skip"	{token('skip');}
"string"	{token('string');}
"then"	{token('then');}
"true"	{token('true');}
"var"	{token('var');}
"when"	{token('when');}

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