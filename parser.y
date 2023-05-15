%{
#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>
#include <unordered_map>
#include "lex.yy.cpp"
#include "symbolTable.hpp"
using namespace std;
#define Trace(t)        printf(t)

%}

%union{
    int intVal;
    double dVal;
    string strVal;
}

/* tokens */
%token PARENTHESES_L PARENTHESES_R SQUARE_BRACKETS_L SQUARE_BRACKETS_R SEMICOLON BRACKETS_L BRACKETS_R COMMA DOT COLON SEMICOLON
%token ADD SUB MUL DIV MOD ASSIGN LT LE GE GT EQ NE AND NOT
%token ARRAY BEGIN BOOL CHAR CONST DECREASING DEFAULT DO ELSE END EXIT FOR FUNCTION GET 
%token IF INT LOOP OF PUT PROCEDURE REAL RESULT RETURN SKIP STRING THEN VAR WHEN

%token <intVal> INT_VAL
%token <dVal> REAL_VAL
%token <boolVal> BOOL_VAL
%token <strVal> STR_VAL
%token <strVal> ID

%type <strVal> types
%type <sym_info> expr, constant_expr, func_invocation

/*priority*/
%left OR
%left AND
%left NOT
%left LT LE GT GE EQ NE
%left ADD SUB
%left MUL DIV MOD
%nonassoc UMINUS

%%
program:        identifier semi
                {
                Trace("Reducing to program\n");
                }
                ;

/*variable type*/
types: 
        INT     { $$ = (char*)"INT_VAL"; }
    |   STRING  { $$ = (char*)"STR_VAL";}
    |   BOOL    { $$ = (char*)"BOOL_VAL";} 
    |   REAL    { $$ = (char*)"REAL_VAL";}
    ;

/*constant*/
const_declare:  CONST ID COLON types ASSIGN expr
                {
                    if($4 != id.type) yyerror("type error");
                    if(table->lookup_local(*$2) == -1) {table->insert(*$2, "global", *$4, id.val, 0);}
                    else {yyerror("\'" + *$2 + "\' had been defined.");}
                }
                |
                CONST ID ASSIGN expr
                {
                    if(table->lookup_local(*$2) == -1) {table->insert(*$2, "global", *$4, id.val, 0);}
                    else {yyerror("\'" + *$2 + "\' had been defined.");}
                };

/*variable*/
var_declare:    VAR ID COLON types ASSIGN expr //type & expr
                {
                    if($4 != id.type) yyerror("type error");
                    if(table->lookup_local(*$2) == -1) {table->insert(*$2, "global", *$4, id.val, 1);}
                    else {yyerror("\'" + *$2 + "\' had been defined.");}
                }
                |
                VAR ID ASSIGN expr  //expr
                {
                    if(table->lookup_local(*$2) == -1) {table->insert(*$2, "global", *$4, id.val, 1);}
                    else {yyerror("\'" + *$2 + "\' had been defined.");}
                }
                |
                VAR ID COLON types //type
                {
                    Value v;
                    if(table->lookup_local(*$2) == -1) {table->insert(*$2, "global", *$4, v, 1);}
                }
                |
                VAR ID COLON ARRAY expr DOT DOT expr OF types   //array
                {
                    Value v;
                    v.arrSize = $6->val.intVal;
                    if(table->lookup_local(*$2) == -1) {table->insert(*$2, "global", *$10, v, 6);}
                };

/*block*/
block:      
            {
                symbolTable* tempTable = create();
            }
            stmt block | const_declare block | var_declare block | expr block | %empty
            ;

/*function*/
func_declare:
            FUNCTION ID PARENTHESES_L param_expr PARENTHESES_R COLON types
            {
                params.clear();
                Value v;
                symbolTable* funcTable = create();
                if(table->lookup(*$2) == -1) { table->insert(*$2, *$2, *$7, v, 3);}
                else {yyerror("\'" + *$2 + "\' function has defined.");}
            }
            |
            FUNCTION ID PARENTHESES_L PARENTHESES_R COLON types
            {
                Value v;
                if(table->lookup(*$2) == -1) { table->insert(*$2, *$2, *$7, v, 3);}
                else {yyerror("\'" + *$2 + "\' function has defined.");}
            };

/*procedure*/
proc_declare:
            PROCEDURE ID PARENTHESES_L param_expr PARENTHESES_R
            {
                params.clear();
                symbolTable* procTable = create();
            } 
            |
            PROCEDURE ID PARENTHESES_L PARENTHESES_R
            {
                symbolTable* procTable = create();
            };

/*expression*/
exprs:      expr COMMA exprs
        |   expr
        ;

expr:       
            INT_VAL
            { 
                Symbol* r = new Symbol();
                r->type = "INT_VAL"
                r->val.intVal = $1;
                $$ = r;
            }
        |   STR_VAL
            { 
                Symbol* r = new Symbol();
                r->type = "STR_VAL"
                r->val.strVal = *$1;
                $$ = r
            }
        |   BOOL_VAL
            { 
                Symbol* r = new Symbol();
                r->type = "BOOL_VAL"
                r->val.bVal = $1;
                $$ = r;
            }
        |   REAL_VAL
            { 
                Symbol* r = new Symbol();
                r->type = "REAL_VAL"
                r->val.dVal = $1;
                $$ = r;
            }
        |   ID          
            {
                Symbol* r = table->getDetail(*$1);
                if(r == nullptr) { yyerror("\'" + *$2 + "\' not declared."); }
                else { $$ = r; }
            }
            |   SUB expr %prec UMINUS
            {
                if($2->type == "INT_VAL" || $2->type == "REAL_VAL"){
                    Symbol* r = new Symbol();
                    r->name = *$2;
                    $$ = r;
                }
                else yyerror("type error");
            }
        |   expr ADD expr
            {   
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->name = *$1;
                r->type = $1->type;
                $$ = r;
            }
        |   expr SUB expr
            {   
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->name = *$1;
                r->type = $1->type;
                $$ = r;
            }
        |   expr MUL expr
            {   
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->name = *$1;
                r->type = $1->type;
                $$ = r;
            }
        |   expr DIV expr
            {   
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->name = *$1;
                r->type = $1->type;
                $$ = r;
            }
        |   expr MOD expr
            {   
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->name = *$1;
                r->type = $1->type;
                $$ = r;
            }
        |   expr GT expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr GE expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr LT expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr LE expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr EQ expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr NE expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr NOT expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr AND expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        |   expr OR expr
            {
                if($1->type != $3->type) yyerror("type error: incompatible type");
                if($1->flag == 5 || $3->flag == 5 || $1->flag == 2 || $1->flag == 2){
                    yyerror("type error: wrong type for computing");
                }
                Symbol* r = new Symbol();
                r->flag = 6;
                r->type = "BOOL_VAL";
                $$ = r;
            }
        ;


%%

yyerror(msg)
char *msg;
{
    fprintf(stderr, "%s\n", msg);
}

main()
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
}
