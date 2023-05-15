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
        intVal  { $$ = (char*)"INT_VAL"; }
    |   strVal  { $$ = (char*)"STR_VAL";}
    |   bVal    { $$ = (char*)"BOOL_VAL";} 
    |   dVal    { $$ = (char*)"REAL_VAL";}
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
