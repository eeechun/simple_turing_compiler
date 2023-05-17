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

void yyerror(string s);

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

%token INT_VAL
%token REAL_VAL
%token BOOL_VAL
%token STR_VAL
%token ID

//%type <strVal> types constant_expr expr invocation  

/*priority*/
//%left OR
//%left AND
//%left NOT
//%left LT LE GT GE EQ NE
//%left ADD SUB
//%left MUL DIV MOD
%nonassoc UMINUS

%start program

%%
program:    opts | stmts | opts stmts | %empty;

/*variable type*/
types: 
        INT     
    |   STRING  
    |   BOOL    
    |   REAL    
    
/*constant*/
const_declare:  CONST ID COLON types ASSIGN constant_expr
                |
                CONST ID ASSIGN constant_expr
                ;
/*variable*/
var_declare:    VAR ID COLON types ASSIGN constant_expr //type & expr
                |
                VAR ID ASSIGN constant_expr  //expr
                |
                VAR ID COLON types //type
                |
                VAR ID COLON ARRAY constant_expr DOT DOT constant_expr OF types   //array
                ;

/*blocks*/
block:      BEGIN_ opt_empty END;

/*function*/
func_declare:   
            FUNCTION ID PARENTHESES_L params PARENTHESES_R COLON types opt_empty END ID
            |
            FUNCTION ID PARENTHESES_L PARENTHESES_R COLON types opt_empty END ID
            ;

opt_block: opt | stmt;
opt_blocks:  opt_block | opt_block opt_blocks;
opt_empty:  %empty | opt_blocks;

/*procedure*/
proc_declare:
            PROCEDURE ID PARENTHESES_L params PARENTHESES_R opt_empty END ID
            |
            PROCEDURE ID PARENTHESES_L PARENTHESES_R opt_empty END ID
            ;


params:  param | param COMMA params;

param:  ID COLON types;


/*expression*/
exprs:      expr | expr COMMA exprs;
expr:       
            constant_expr

        |   ID

        |   invocation       

        |   SUB expr %prec UMINUS

        |   expr ADD expr

        |   expr SUB expr

        |   expr MUL expr

        |   expr DIV expr

        |   expr MOD expr

        |   expr GT expr

        |   expr GE expr

        |   expr LT expr

        |   expr LE expr

        |   expr EQ expr

        |   expr NE expr

        |   expr NOT expr

        |   expr AND expr

        |   expr OR expr
      ;

bool_expr: PARENTHESES_L exprs PARENTHESES_R | exprs;

constant_expr: 
        INT_VAL     
    |   STR_VAL     
    |   BOOL_VAL     
    |   REAL_VAL    
    ;


/*statement*/
opt:    const_declare | var_declare | func_declare | proc_declare | block;
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
        |
        PUT expr
        |
        GET ID
        |
        RESULT expr
        |
        RETURN
        |
        EXIT WHEN bool_expr
        |
        SKIP
        ;

conditional_stmt:   IF bool_expr THEN opt_empty else_stmt END IF;

else_stmt: ELSE opt_blocks | %empty;

loop:   LOOP opt_empty END LOOP;

for_loop:
            FOR ID COLON expr DOT DOT expr opt_empty END FOR
            |
            FOR DECREASING ID COLON expr DOT DOT expr opt_empty END FOR
            ;

invocation:
            ID PARENTHESES_L arguments_empty PARENTHESES_R;

arguments:  expr | expr COMMA arguments;
arguments_empty: %empty | arguments;

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
        
    return 0;
}
