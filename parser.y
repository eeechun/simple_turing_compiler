%{
#include "string.h"
#include <iostream>
#include <stdio.h>
#include <vector>
#include <unordered_map>
#include "lex.yy.cpp"
#include "symbolTable.hpp"
using namespace std;
#define Trace(t)        printf(t)

symbolTable* table = new symbolTable();
string scopeTemp = "global";
string returnType = "void";
string func_name = "";
bool argumentFlag = false;

void yyerror(string s);

vector<Symbol> argument_vector;
vector<Symbol> parameter_vector;

int countPara(string sscope){
    int cnt = count_if(parameter_vector.begin(), parameter_vector.end(), [sscope](const Symbol& s) { return s.scope == sscope; });
    return cnt;
}
int countArgu(string sscope){
    int cnt = count_if(argument_vector.begin(), argument_vector.end(), [sscope](const Symbol& s) { return s.scope == sscope; });
    return cnt;
}

void show(){
    cout<<"=====================================================\n";
    for(auto i: parameter_vector){

        cout<< "parameters:\n";
        cout << i.name<<" "<<i.scope<<" "<<i.valueType<<" "<<i.flag<<"\n";  
    }
    for(auto i: argument_vector){
        
        cout<< "arguments:\n";
        cout << i.name<<" "<<i.scope<<" "<<i.valueType<<" "<<i.flag<<"\n";
            
    }
    cout<<"=====================================================\n";
}

%}

%union{
    int intVal;
    double dVal;
    char* strVal;
    bool boolVal;
}

/* tokens */
%token PARENTHESES_L PARENTHESES_R SQUARE_BRACKETS_L SQUARE_BRACKETS_R  BRACKETS_L BRACKETS_R COMMA DOT COLON SEMICOLON
%token ADD SUB MUL DIV MOD ASSIGN LT LE GE GT EQ NE AND NOT OR
%token ARRAY BEGIN_ BOOL CHAR CONST DECREASING DEFAULT DO ELSE END EXIT FOR FUNCTION GET 
%token IF INT LOOP OF PUT PROCEDURE REAL RESULT RETURN SKIP STRING THEN VAR WHEN

%token <intVal>     INT_VAL
%token <dVal>       REAL_VAL
%token <boolVal>    BOOL_VAL
%token <strVal>     STR_VAL
%token <strVal>     ID

%type <strVal> types array_declare array_ref func_declare expr invocation

/*priority*/
%left OR
%left AND
%left NOT
%left LT LE GT GE EQ NE
%left ADD SUB
%left MUL DIV MOD
%nonassoc UMINUS

%start program

%%
program:    opts | stmts | opts stmts | %empty;

/*variable type*/
types: 
        INT     { $$ = (char*)"integer"; }
    |   STRING  { $$ = (char*)"str"; }
    |   BOOL    { $$ = (char*)"boolean"; }
    |   REAL    { $$ = (char*)"real"; }
    ;
    
/*constant*/
const_declare:  CONST ID COLON types ASSIGN expr
                {
                    if(string($4) != string($6)) yyerror("type error: not compatible");
                    if(table->lookup(scopeTemp, string($2)) == -1){
                        table->insert(string($2), scopeTemp, (char*)($4), "constant");
                    }
                    else yyerror("Constant had declared.");
                }
                |
                CONST ID ASSIGN expr
                {
                    if(table->lookup(scopeTemp, string($2)) == -1) table->insert(string($2), scopeTemp, (char*)($4), "constant");
                    else yyerror("Constant had declared.");
                }
                ;
/*variable*/
var_declare:    VAR ID COLON types ASSIGN expr //type & expr
                {
                    if(string($4) != string($6)) yyerror("type error: not compatible");
                    if(table->lookup(scopeTemp, string($2)) == -1){
                        table->insert(string($2), scopeTemp, (char*)($4), "variable");
                    }
                    else yyerror("variable had declared.");
                }
                |
                VAR ID ASSIGN expr  //expr
                {
                    if(table->lookup(scopeTemp, string($2)) == -1) table->insert(string($2), scopeTemp, (char*)($4), "variable");
                    else yyerror("variable had declared.");
                }
                |
                VAR ID COLON types //type
                {
                    if(table->lookup(scopeTemp, string($2)) == -1) table->insert(string($2), scopeTemp, (char*)($4), "variable");
                    else yyerror("variable had declared.");
                };

/*array*/
array_declare:
                VAR ID COLON ARRAY expr DOT DOT expr OF types
                {
                    if(string($5) != string($8)) yyerror("type error: type incompatable");
                    if(string($5) != "integer" || string($8) != "integer") yyerror("type error: array size must be integer");
                    if(table->lookup(scopeTemp, string($2)) == -1) table->insert(string($2), scopeTemp, (char*)($10), "array");
                    else yyerror("array had declared.");
                    $$ = (char*)($10);
                };

array_ref:  ID SQUARE_BRACKETS_L expr SQUARE_BRACKETS_R 
            {
                Symbol* id_d = table->getItem(scopeTemp, string($1));
                $$ = (char*)id_d->valueType;
            }

/*blocks*/
block:      BEGIN_
            {
                scopeTemp = "block";
            }
            opt_empty END
            {
                scopeTemp = "block";
                table->dump(scopeTemp);
                scopeTemp = "global";
            };

/*function*/
func_declare:
            FUNCTION ID 
            {
                scopeTemp = string($2);
            }    
            PARENTHESES_L params PARENTHESES_R COLON types opt_empty END ID
            {
                if(table->lookup("global", string($2)) == -1) table->insert(string($2), "global", (char*)($8) , "function");
                else yyerror("ERROR: redefinition");
                if(returnType != string($8)) yyerror("type error: function return in the wrong type");
                scopeTemp = string($2);
                table->dump(scopeTemp);
                //returnType = "void";
            };

opt_block: opt | stmt;
opt_blocks:  opt_block | opt_block opt_blocks;
opt_empty:  %empty | opt_blocks;

/*procedure*/
proc_declare:
            PROCEDURE ID
            {
                scopeTemp = string($2);
                cout<<"start procedure\n";
                if(table->lookup("global", string($2)) == -1) table->insert(string($2), "global", (char*)"void", "procedure");
                else yyerror("ERROR: redefinition");
            }
            PARENTHESES_L params PARENTHESES_R opt_empty END ID
            {
                if(returnType != "void") yyerror("type error: no return in procedure");
                scopeTemp = string($2);
                table->dump(scopeTemp);
            };


params:  param | param COMMA params;

param:  ID COLON types
        {
            Symbol p;
            if(table->lookup(scopeTemp, string($1)) == -1){
                table->insert(string($1), scopeTemp, (char*)($3), "parameter");

                p.name = string($1);
                p.scope = scopeTemp;
                p.valueType = (char*)($3);
                p.flag = "parameter";
                parameter_vector.push_back(p);
                
            }
            else yyerror("parameter had declared.");
        }
        |%empty
        ;


/*expression*/
exprs:      expr
            {
                func_name = scopeTemp;
                Symbol argu;
                argu.name = "";
                argu.scope = func_name;
                argu.valueType = (char*)($1);
                argu.flag = "argument";
                argument_vector.push_back(argu);
            }
        |   expr COMMA exprs
            {
                func_name = scopeTemp;
                Symbol argu;
                argu.name = "";
                argu.scope = func_name;
                argu.valueType = (char*)($1);
                argu.flag = "argument";
                argument_vector.push_back(argu);
            };

expr:       
            INT_VAL     { $$ = (char*)"integer"; }
        |   STR_VAL     { $$ = (char*)"str"; }
        |   BOOL_VAL    { $$ = (char*)"boolean"; }
        |   REAL_VAL    { $$ = (char*)"real"; }

        |   ID 
            {
                Symbol* id_d = table->getItem(scopeTemp, string($1));
                if(id_d == nullptr) yyerror("ID not found");
                if(id_d->flag == "function" || id_d->flag == "procedure") argumentFlag = true;
                $$ = (char*)id_d->valueType;
            }

        |   array_declare   { $$ = (char*)($1); }

        |   array_ref       { $$ = (char*)($1); }

        |   invocation      { $$ = (char*)($1); }

        |   SUB expr %prec UMINUS
            {
                if ((char*)($2) == "integer" || (char*)($2) == "real" || (char*)($2)== "str") $$ = (char*)($2);
                else yyerror("UMINUS type error");
            }

        |   expr ADD expr
            {
                if((char*)($1) == "string" || (char*)($3) == "string") yyerror("type error: ADD type incompatable");
                if((char*)($1) == "real" || (char*)($3) == "real") $$ = (char*)"real";
                $$ = (char*)($1);
            }

        |   expr SUB expr
            {
                if((char*)($1) == "string" || (char*)($3) == "string") yyerror("type error: SUB type incompatable");
                if((char*)($1) == "real" || (char*)($3) == "real") $$ = (char*)"real";
                $$ = (char*)($1);
            }

        |   expr MUL expr
            {
                if((char*)($1) == "string" || (char*)($3) == "string") yyerror("type error: MUL type incompatable");
                if((char*)($1) == "real" || (char*)($3) == "real") $$ = (char*)"real";
                $$ = (char*)($1);
            }

        |   expr DIV expr
            {
                if((char*)($1) == "string" || (char*)($3) == "string") yyerror("type error: DIV type incompatable");
                if((char*)($1) == "real" || (char*)($3) == "real") $$ = (char*)"real";
                $$ = (char*)($1);
            }

        |   expr MOD expr
            {
                if((char*)($1) == "string" || (char*)($3) == "string") yyerror("type error: MOD type incompatable");
                $$ = (char*)($1);
            }

        |   expr GT expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: GT type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr GE expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: GE type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr LT expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: LT type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr LE expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: LE type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr EQ expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: EQ type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr NE expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: NE type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr AND expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: AND type incompatable");
                $$ = (char*)"boolean";
            }

        |   expr OR expr
            {
                if((char*)($1) != (char*)($3)) yyerror("type error: OR type incompatable");
                $$ = (char*)"boolean";
            }

        |   NOT expr
            {
                if((char*)($2) != "boolean") yyerror("type error: NOT expression only allows boolean type");
                $$ = (char*)"boolean";
            }

        |   PARENTHESES_L expr PARENTHESES_R
            {
                $$ = (char*)($2);
            }
        ;

bool_expr:  
            expr 
            {  
                if((char*)($1) != "boolean") yyerror("type error: not boolean");
            };

/*statement*/
opt:    const_declare | var_declare | func_declare | proc_declare | array_declare | block;
opts:    opt | opt opts;

stmts:  stmt | stmt stmts;

stmt:   
        simple_stmt
    |   conditional_stmt
    |   loop
    |   for_loop
    |   expr
    ;
    
simple_stmt:
        ID ASSIGN expr
        {
            Symbol* id_d = table->getItem(scopeTemp, string($1));
            if(id_d->valueType != (char*)($3)) printf("!!! warning: type implicit conversion !!!\n");
        }
        |
        array_ref ASSIGN expr
        {
            if((char*)($1) != (char*)($3)) yyerror("type error: array assign denied");
        }
        |
        PUT expr
        |
        GET ID
        |
        RESULT expr
        {
            returnType = string($2);
        }
        |
        RETURN
        {
            returnType = "void";
        }
        |
        EXIT WHEN bool_expr
        |
        EXIT
        |
        SKIP
        ;

conditional_stmt:   IF
                    {
                        scopeTemp = "condition";
                    }
                    bool_expr THEN opt_empty else_stmt END IF
                    {
                        scopeTemp = "condition";
                        table->dump(scopeTemp);
                    };

else_stmt: ELSE opt_blocks | %empty;

loop:   LOOP
        {
            scopeTemp = "loop";
        }
        opt_empty END LOOP
        {
            scopeTemp = "loop";
            table->dump(scopeTemp);
        };

for_loop:
            FOR
            {
                scopeTemp = "for_loop";
            }
            ID COLON expr DOT DOT expr opt_empty END FOR
            {
                scopeTemp = "for_loop";
                table->dump(scopeTemp);
            }
            |
            FOR
            {
                scopeTemp = "decreasing_loop";
            }
            DECREASING ID COLON expr DOT DOT expr opt_empty END FOR
            {
                scopeTemp = "decreasing_loop";
                table->dump(scopeTemp);
            }
            ;

invocation:
            ID PARENTHESES_L arguments_empty PARENTHESES_R
            {
                if(countPara(scopeTemp) != countArgu(scopeTemp)) yyerror("arguments and parameters not match");
                for(auto i: parameter_vector){
                    for(auto j: argument_vector){
                        if(i.scope != j.scope) continue;
                        if(i.valueType != j.valueType) yyerror("type error: arguments and parameters not match");
                    }
                }
                
                Symbol* temp = table->getItem("global", scopeTemp);
                if(temp == nullptr) yyerror("invoke failed: not found");
                $$ = (char*)(temp->valueType);
            };


arguments_empty: %empty | exprs;

%%

void yyerror(string s){
    cerr << s << endl;
    exit(1);
}

int main(int argc, char* argv[])
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
    
    table->dump("global");
    return 0;
}