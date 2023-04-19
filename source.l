%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n","t");}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n","t",i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n","t",s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
%}

%x COMMENT STR

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
"array"	        {token('array');}
"begin"	        {token('begin');}
"bool"	        {token('bool');}
"char"	        {token('char');}
"const"	        {token('const');}
"decreasing"    {token('decreasing');}
"default"       {token('default');}
"do"	        {token('do');}
"else"	        {token('else');}
"end"	        {token('end');}
"exit"	        {token('exit');}
"false"	        {token('false');}
"for"	        {token('for');}
"function"      {token('function');}
"get"	        {token('get');}
"if"	        {token('if');}
"int"	        {token('int');}
"loop"	        {token('loop');}
"of"	        {token('of');}
"put"	        {token('put');}
"procedure"     {token('procedure');}
"real"	        {token('real');}
"result"        {token('result');}
"return"        {token('return');}
"skip"	        {token('skip');}
"string"        {token('string');}
"then"	        {token('then');}
"true"	        {token('true');}
"var"	        {token('var');}
"when"	        {token('when');}
[0-9]+	        {tokenInteger(integer, yytext);}
(0|([1-9][0-9]*))"."[0-9]+	{tokenString(real, yytext);}
[0-9]+"."[0-9]+[Ee][+-]?[0-9]+  {tokenString(real_exp, yytext);}
[A-Za-z]([A-Za-z]|[0-9]+)*	{tokenString(id, yytext);}

"\"" {
        LIST;
        BEGIN STR; 
}

<STR> "\"" {
        char c = yyinput();
        if(c != '\"'){
                tokenString(string, strBuf);
                strBuf[0]='/0';
                BEGIN INITIAL;
        }
        else{
                LIST;
                strcat(strBuf,'\"');
        }
}

<STR> [^"\n]* { //string content
        LIST;
        strcat(strBuf, yytext);
}

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