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

%type <strVal> type

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

type: 
        INTEGER { $$ = (char*)"INT_VAL"; }
    |   STRING  { $$ = (char*)"STR_VAL";}
    |   BOOLEAN { $$ = (char*)"BOOL_VAL";} 
    |   FLOAT   { $$ = (char*)"REAL_VAL";}
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
