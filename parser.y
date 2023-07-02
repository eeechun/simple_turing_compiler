%{
#include <iostream>
#include <stdio.h>
#include <vector>
#include <string>
#include <stack>
#include <fstream>
#include "symbolTable.hpp"
#include "codeGenerate.hpp"
#include "lex.yy.cpp"
using namespace std;
#define Trace(t)        printf(t)

//ofstream assFile;
string className;

symbolTable* table = new symbolTable();
string scopeTemp = "global";
string pre_scope = "global";
string returnType = "void";
string func_name = "";

int localCnt = -1;
int pre_idx = -1;
int elseFlag = 0;
int mainFlag = 0;
int varFlag = 0;
int constFlag = 0;
int boolCondFlag = 0;
int getstaticFlag = 0;
int loopFlag = 0;
int localFlag = 0;
int forLoopFlag = 0;
int branchCount = 0;


bool argumentFlag = false;

void yyerror(string s);

vector<Symbol> argument_vector;
vector<Symbol> parameter_vector;
vector<string> paramTypes;
vector<string> arguTypes;

stack<int> branchStack;

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
        cout << i.name<<" "<<i.scope<< " "<<i.valueType<<" "<<i.flag<<"\n";  
    }
    for(auto i: argument_vector){
        
        cout<< "arguments:\n";
        cout << i.name<<" "<<i.scope<<" " <<i.value.intVal<<" "<<i.valueType<<" "<<i.flag<<"\n";
            
    }
    cout<<"=====================================================\n";
}

%}

%union{
    int intVal;
    double dVal;
    char* strVal;
    bool boolVal;
    Symbol* symbol;
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

%type <strVal> types 
%type <symbol> expr func_declare invocation

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
program:   opt;

/*variable type*/
types: 
        INT     { $$ = (char*)"int"; }
    |   STRING  { $$ = (char*)"str"; }
    |   BOOL    { $$ = (char*)"boolean"; }
    |   REAL    { $$ = (char*)"real"; }
    ;
    
/*constant*/
const_declare:  CONST ID COLON types ASSIGN expr
                {
                    constFlag = 1;
                    if((char*)$4 != ($6)->valueType) cout << "<type error: not compatible>\n";
                    if(table->lookup(scopeTemp, string($2)) == -1){
                        table->insert(localCnt, string($2), ($6)->value, scopeTemp, (char*)($4), "constant");
                    }
                    else cout<<"<error: Constant redefinition.>\n";

                    constFlag = 0;
                }
                |
                CONST ID ASSIGN expr
                {
                    constFlag = 1;
                    if(table->lookup(scopeTemp, string($2)) == -1) {
                        table->insert(localCnt, string($2), ($4)->value, scopeTemp, ($4)->valueType, "constant");
                    }
                    else cout<<"<error: Constant redefinition.>\n";

                    constFlag = 0;
                }
                ;
/*variable*/
var_declare:    VAR ID COLON types ASSIGN expr //type & expr
                {
                    varFlag = 1;
                    if((char*)($4) != ($6)->valueType) cout << "<type error: not compatible>\n";

                    if(localFlag) localCnt++;
                    cout << "[current local count: " << localCnt << "]\n";

                    if(table->lookup(scopeTemp, string($2)) == -1){
                        table->insert(localCnt, string($2), ($6)->value, scopeTemp, (char*)($4), "variable");
                    }
                    else cout<<"<error: Variable redefinition.>\n";

                    Symbol* tmp = table->getItem(string($2));
                    if(tmp == nullptr) cout<<"<error: variable not inserted.>\n";
                    else{
                        if(!localFlag){
                            if($4 == (char*)"int"){
                                pushGlobalIntVar(tmp->name, ($6)->value.intVal);
                            }
                            else if($4 == (char*)"boolean"){
                                pushGlobalIntVar(tmp->name, ($6)->value.boolVal);
                            }
                        }
                        else{
                            if($4 == (char*)"int"){
                                pushLocalIntVar(($6)->value.intVal, localCnt);
                            }
                            else if($4 == (char*)"boolean"){
                                pushLocalBoolVar(($6)->value.boolVal, localCnt);
                            }
                            
                        }
                    }
                    varFlag = 0;
                }
                |
                VAR ID ASSIGN expr  //expr
                {
                    varFlag = 1;
                    if(localFlag) localCnt++;
                    cout << "[current local count: " << localCnt << "]\n";

                    if(table->lookup(scopeTemp, string($2)) == -1){
                        table->insert(localCnt, string($2), ($4)->value, scopeTemp, ($4)->valueType, "variable");
                    }
                    else cout<<"<error: Variable redefinition.>\n";

                    Symbol* tmp = table->getItem(string($2));
                    if(tmp == nullptr) cout<<"<error: variable not inserted.>\n";
                    else{
                        if(!localFlag){
                            if($4->valueType == (char*)"int"){
                                pushGlobalIntVar(tmp->name, ($4)->value.intVal);
                            }
                            else if($4->valueType == (char*)"boolean"){
                                pushGlobalIntVar(tmp->name, ($4)->value.boolVal);
                            }
                        }
                        else{
                            if($4->valueType == (char*)"int"){
                                pushLocalIntVar(($4)->value.intVal, localCnt);
                            }
                            else if($4->valueType == (char*)"boolean"){
                                pushLocalBoolVar(($4)->value.boolVal, localCnt);
                            }
                            
                        }
                    }
                    varFlag = 0;
                }
                |
                VAR ID COLON types //type
                {
                    varFlag = 1;
                    Value v;
                    if(localFlag) localCnt++;
                    cout << "[current local count: " << localCnt << "]\n";

                    if(table->lookup(scopeTemp, string($2)) == -1){
                        table->insert(localCnt, string($2), v, scopeTemp, (char*)($4), "variable");
                    }
                    else cout<<"<error: Variable redefinition.>\n";

                    Symbol* tmp = table->getItem(string($2));
                    if(tmp == nullptr) cout<<"<error: variable not inserted.>\n";
                    else{
                        if(!localFlag){
                            if($4 == (char*)"int"){
                                pushGlobalIntVar(tmp->name);
                            }
                            else if($4 == (char*)"boolean"){
                                pushGlobalBoolVar(tmp->name);
                            }
                        }
                        else{
                            if($4 == (char*)"int"){
                                pushLocalIntVar(0, localCnt);
                            }
                            //else if($4 == (char*)"boolean"){
                            //    storeLocalVar(tmp->localidx);
                            //}
                            
                        }
                    }
                    varFlag = 0;
                }
                ;

/*array*/
//array_declare:
//                VAR ID COLON ARRAY expr DOT DOT expr OF types
//                {
//                    if(string($5) != string($8)) cout<<"<type error: type incompatable>\n";
//                    if(string($5) != "int" || string($8) != "int") cout<<"<type error: array size must be integer>\n";
//                    if(table->getItem(scopeTemp, string($2)) == -1) table->insert(string($2), scopeTemp, (char*)($10), "array");
//                    else cout<<"<redefinition: array had declared.>\n";
//                    $$ = (char*)($10);
//                }
//                ;
//
//array_ref:  ID SQUARE_BRACKETS_L expr SQUARE_BRACKETS_R 
//            {
//                Symbol* id_d = table->getItem(scopeTemp, string($1));
//                $$ = (char*)id_d->valueType;
//            }
//            ;
//
///*blocks*/
block:      BEGIN_
            {   
                localFlag = 1;
                pre_scope = scopeTemp;
                if(pre_scope != "global"){
                    pre_idx = localCnt;
                    localCnt = -1;
                }
                scopeTemp = "block";
            }
            opt
            {
                scopeTemp = "block";
            }
            END
            {
                table->dump(scopeTemp);
                scopeTemp = pre_scope;
                if(pre_scope != "global"){
                    localCnt = pre_idx;
                }
                else localCnt = -1;
                localFlag = 0;
            };

/*function*/
func_declare:
            FUNCTION ID 
            {
                localFlag = 1;
                pre_scope = scopeTemp;
                if(pre_scope != "global"){
                    pre_idx = localCnt;
                    localCnt = -1;
                }
                scopeTemp = string($2);
            }    
            PARENTHESES_L params PARENTHESES_R COLON types 
            {
                Value v;
                if(table->lookup(scopeTemp, string($2)) == -1) table->insert(-1, string($2), v, "global", (char*)($8) , "function");
                else cout<<"redefinition: function had declared\n";
                scopeTemp = string($2);

                if(paramTypes.empty()){
                    if((string)($8) == "int") typeFunc((string)($2), (string)($8));
                    else if((string)($8) == "boolean") boolFunc((string)($2), (string)($8));
                }
                else{
                    if((string)($8) == "int") typeFunc((string)($2), (string)($8), paramTypes);
                    else if((string)($8) == (string)"boolean") boolFunc((string)($2), (string)($8), paramTypes);
                }
            }
            opt
            {
                if(returnType != string($8)) cout<<"<type error: function return in the wrong type>\n";
            }
            END ID
            {
                typeFuncEnd();
                paramTypes.clear();
                table->dump(string($2));
                
                scopeTemp = pre_scope;
                if(pre_scope != "global"){
                    localCnt = pre_idx;
                }
                else localCnt = -1;

                localFlag = 0;
            };

//opt_block: opt | stmt;
//opt_blocks:  opt_block | opt_block opt_blocks;
//opt_empty:  %empty | opt_blocks;

/*procedure*/
proc_declare:
            PROCEDURE ID
            {
                localFlag = 1;
                pre_scope = scopeTemp;
                if(pre_scope != "global"){
                    pre_idx = localCnt;
                    localCnt = -1;
                }
                scopeTemp = string($2);
                Value v;
                if(table->lookup(scopeTemp, string($2)) == -1) table->insert(-1, string($2), v, "global", (char*)"void", "procedure");
                else cout<<"<redefinition: procedure has declared>\n";
            }
            PARENTHESES_L params PARENTHESES_R
            {
                scopeTemp = string($2);
                if(paramTypes.empty()) voidFunc((string)($2));
                else voidFunc((string)($2), paramTypes);
            }
            opt
            {
                if(returnType != "void") cout<<"<type error: no return in procedure>\n";
            }
            END ID
            {
                scopeTemp = string($2);
                paramTypes.clear();
                table->dump(scopeTemp);
                voidFuncEnd();
                scopeTemp = pre_scope;
                if(pre_scope != "global"){
                    localCnt = pre_idx;
                }
                else localCnt = -1;
                localFlag = 1;
            };


params:  param | param COMMA params;

param:  ID COLON types
        {
            Symbol p;
            Value v;
            localCnt++;
            if(table->lookup(scopeTemp, string($1)) == -1){
                table->insert(localCnt, string($1), v, scopeTemp, (char*)($3), "parameter");
                p.name = string($1);
                p.scope = scopeTemp;
                p.valueType = (char*)($3);
                p.flag = "parameter";
                parameter_vector.push_back(p);           
                paramTypes.push_back((string)($3));     
            }
            else cout<< "<redefinition: parameter had declared.>\n";
            
        }
        |
        expr
        {
            Symbol argu;
            argu.name = ($1)->name;
            argu.scope = func_name;
            argu.valueType = ($1)->valueType;
            argu.value = ($1)->value;
            argu.flag = "argument";
            argument_vector.push_back(argu);
            arguTypes.push_back(argu.valueType);
            if(($1)->flag == "constant") getConst(($1)->value.intVal);
            else if(($1)->flag == "variable"){
                if(($1)->valueType == "int") getGlobalIntVar(($1)->name);
                else getGlobalBoolVar(($1)->name);
            }
        }
        |%empty
        ;


/*expression*/
/*exprs:  expr
        {
            Symbol argu;
            argu.name = ($1)->name;
            argu.scope = func_name;
            argu.valueType = ($1)->valueType;
            argu.value = ($1)->value;
            argu.flag = "argument";
            argument_vector.push_back(argu);
            arguTypes.push_back(argu.valueType);
            if(($1)->flag == "constant") getConst(($1)->value.intVal);
            else if(($1)->flag == "variable"){
                if(($1)->valueType == "int") getGlobalIntVar(($1)->name);
                else getGlobalBoolVar(($1)->name);
            }
        }
        | 
        expr COMMA exprs
        {
            Symbol argu;
            argu.name = ($1)->name;
            argu.scope = func_name;
            argu.valueType = ($1)->valueType;
            argu.value = ($1)->value;
            argu.flag = "argument";
            argument_vector.push_back(argu);
            arguTypes.push_back(argu.valueType);
            if(($1)->flag == "constant") getConst(($1)->value.intVal);
            else if(($1)->flag == "variable"){
                if(($1)->valueType == "int") getGlobalIntVar(($1)->name);
                else getGlobalBoolVar(($1)->name);
            }
        };*/
expr:       
            INT_VAL
            { 
                Symbol *tmp = new Symbol();
                tmp->valueType = (char*)"int";
                tmp->value.intVal = $1;
                tmp->scope = scopeTemp;
                if(varFlag == 1) tmp->flag = "variable";
                else if(constFlag == 1) tmp->flag = "constant";
                else tmp->flag = "constant";
                $$ = tmp;
            }
        |   STR_VAL
            { 
                Symbol *tmp = new Symbol();
                tmp->valueType = (char*)"str";
                tmp->value.strVal = $1;
                tmp->scope = scopeTemp;
                if(varFlag == 1) tmp->flag = "variable";
                else if(constFlag == 1) tmp->flag = "constant";
                else tmp->flag = "constant";
                $$ = tmp;
            }
        |   BOOL_VAL
            { 
                Symbol *tmp = new Symbol();
                tmp->valueType = (char*)"boolean";
                tmp->value.boolVal = $1;
                tmp->scope = scopeTemp;
                if(varFlag == 1) tmp->flag = "variable";
                else if(constFlag == 1) tmp->flag = "constant";
                else tmp->flag = "constant";
                $$ = tmp;
            }
        |   REAL_VAL
            { 
                Symbol *tmp = new Symbol();
                tmp->valueType = (char*)"real";
                tmp->value.dVal = $1;
                tmp->scope = scopeTemp;
                if(varFlag == 1) tmp->flag = "variable";
                else if(constFlag == 1) tmp->flag = "constant";
                $$ = tmp;
            }
        |   ID 
            {
                Symbol* id_d = table->getItem(string($1));
                if(id_d == nullptr) cout<<"<Error: " << string($1) <<" not found>\n";
                if(id_d->flag == "function" || id_d->flag == "procedure") argumentFlag = true;
                $$ = id_d;
            }

//        |   array_declare   { $$ = (char*)($1); }
//
//        |   array_ref       { $$ = (char*)($1); }
//
        |   invocation

        |   SUB expr %prec UMINUS
            {
                if (($2)->valueType == "int" || ($2)->valueType == "real"){
                    Symbol* r = new Symbol();
                    r->scope = scopeTemp;
                    r->value = ($2)->value;
                    r->valueType = ($2)->valueType;
                    r->flag = "expr";
                    r->name = ($2)->name;

                    if(($2)->localidx == -1 && ($2)->flag == "variable") getGlobalIntVar(($2)->name);
                    else if(($2)->localidx != -1 && ($2)->flag == "variable") getLocalVar(($2)->localidx);
                    else getConst(($2)->value.intVal);
                    negative();

                    $$ = r;
                }
                
                else cout<<"<type error: UMINUS type error>\n";
                
            }

        |   expr ADD expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: ADD type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = ($1)->valueType;
                r->flag = "expr";
                if(localFlag){
                    if(($1)->flag != "function"){
                        if(($1)->valueType == "int"){
                            if(($1)->flag != "expr"){
                                if(($1)->flag == "constant") getConst(($1)->value.intVal);
                                else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                                else getLocalVar(($1)->localidx);
                            }
                        }
                        if(($1)->valueType == "boolean"){
                            if(($1)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }

                    if(($3)->flag != "function"){
                        if(($3)->valueType == "int"){
                            if(($3)->flag != "expr"){
                                if(($3)->flag == "constant") getConst(($3)->value.intVal);
                                else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                                else getLocalVar(($3)->localidx);
                            }
                        }
                        if(($3)->valueType == "boolean"){
                            if(($3)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }
                    getOperator(IADD);
                }
                else{
                    if(($1)->flag == "constant" && ($3)->flag == "constant"){
                        r->value.intVal = ($1)->value.intVal + ($3)->value.intVal;
                        r->flag = "constant";
                    }
                    else{
                        if(($1)->flag == "variable"){
                            if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                        else if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        
                        if(($3)->flag == "variable"){
                            if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                            
                        }
                        else if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        getOperator(IADD);
                    }
                    
                }
                $$ = r;
            }

        |   expr SUB expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: SUB type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = ($1)->valueType;
                r->flag = "expr";
                if(localFlag){
                    if(($1)->flag != "function"){
                        if(($1)->valueType == "int"){
                            if(($1)->flag != "expr"){
                                if(($1)->flag == "constant") getConst(($1)->value.intVal);
                                else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                                else getLocalVar(($1)->localidx);
                            }
                        }
                        if(($1)->valueType == "boolean"){
                            if(($1)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }

                    if(($3)->flag != "function"){
                        if(($3)->valueType == "int"){
                            if(($3)->flag != "expr"){
                                if(($3)->flag == "constant") getConst(($3)->value.intVal);
                                else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                                else getLocalVar(($3)->localidx);
                            }
                        }
                        if(($3)->valueType == "boolean"){
                            if(($3)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }
                    getOperator(ISUB);
                }
                else{
                    if(($1)->flag == "constant" && ($3)->flag == "constant"){
                        r->value.intVal = ($1)->value.intVal - ($3)->value.intVal;
                        r->flag = "constant";
                    }
                    else{
                        if(($1)->flag == "variable"){
                            if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                        else if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        
                        if(($3)->flag == "variable"){
                            if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                            
                        }
                        else if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        getOperator(ISUB);
                    }
                    
                }
                $$ = r;
            }

        |   expr MUL expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: MUL type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = ($1)->valueType;
                r->flag = "expr";
                if(localFlag){
                    if(($1)->flag != "function"){
                        if(($1)->valueType == "int"){
                            if(($1)->flag != "expr"){
                                if(($1)->flag == "constant") getConst(($1)->value.intVal);
                                else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                                else getLocalVar(($1)->localidx);
                            }
                        }
                        if(($1)->valueType == "boolean"){
                            if(($1)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }

                    if(($3)->flag != "function"){
                        if(($3)->valueType == "int"){
                            if(($3)->flag != "expr"){
                                if(($3)->flag == "constant") getConst(($3)->value.intVal);
                                else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                                else getLocalVar(($3)->localidx);
                            }
                        }
                        if(($3)->valueType == "boolean"){
                            if(($3)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }
                    getOperator(IMUL);
                }
                else{
                    if(($1)->flag == "constant" && ($3)->flag == "constant"){
                        r->value.intVal = ($1)->value.intVal * ($3)->value.intVal;
                        r->flag = "constant";
                    }
                    else{
                        if(($1)->flag == "variable"){
                            if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                        else if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        
                        if(($3)->flag == "variable"){
                            if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                            
                        }
                        else if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        getOperator(IMUL);
                    }
                    
                }
                $$ = r;
            }

        |   expr DIV expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: DIV type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = ($1)->valueType;
                r->flag = "expr";
                if(localFlag){
                    if(($1)->flag != "function"){
                        if(($1)->valueType == "int"){
                            if(($1)->flag != "expr"){
                                if(($1)->flag == "constant") getConst(($1)->value.intVal);
                                else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                                else getLocalVar(($1)->localidx);
                            }
                        }
                        if(($1)->valueType == "boolean"){
                            if(($1)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }

                    if(($3)->flag != "function"){
                        if(($3)->valueType == "int"){
                            if(($3)->flag != "expr"){
                                if(($3)->flag == "constant") getConst(($3)->value.intVal);
                                else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                                else getLocalVar(($3)->localidx);
                            }
                        }
                        if(($3)->valueType == "boolean"){
                            if(($3)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }
                    getOperator(IDIV);
                }
                else{
                    if(($1)->flag == "constant" && ($3)->flag == "constant"){
                        r->value.intVal = ($1)->value.intVal / ($3)->value.intVal;
                        r->flag = "constant";
                    }
                    else{
                        if(($1)->flag == "variable"){
                            if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                        else if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        
                        if(($3)->flag == "variable"){
                            if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                            
                        }
                        else if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        getOperator(IDIV);
                    }
                    
                }
                $$ = r;
            }

        |   expr MOD expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: MOD type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = ($1)->valueType;
                r->flag = "expr";
                if(localFlag){
                    if(($1)->flag != "function"){
                        if(($1)->valueType == "int"){
                            if(($1)->flag != "expr"){
                                if(($1)->flag == "constant") getConst(($1)->value.intVal);
                                else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                                else getLocalVar(($1)->localidx);
                            }
                        }
                        if(($1)->valueType == "boolean"){
                            if(($1)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }

                    if(($3)->flag != "function"){
                        if(($3)->valueType == "int"){
                            if(($3)->flag != "expr"){
                                if(($3)->flag == "constant") getConst(($3)->value.intVal);
                                else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                                else getLocalVar(($3)->localidx);
                            }
                        }
                        if(($3)->valueType == "boolean"){
                            if(($3)->value.boolVal){
                                pushBool(1);
                            }
                            else{
                                pushBool(0);
                            }
                        }
                    }
                    getOperator(IMOD);
                }
                else{
                    if(($1)->flag == "constant" && ($3)->flag == "constant"){
                        r->value.intVal = ($1)->value.intVal % ($3)->value.intVal;
                        r->flag = "constant";
                    }
                    else{
                        if(($1)->flag == "variable"){
                            if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                        else if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        
                        if(($3)->flag == "variable"){
                            if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                            
                        }
                        else if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        getOperator(IMOD);
                    }
                    
                }
                $$ = r;
            }

        |   expr GT expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: GT type incompatable>\n";
                Symbol* r = new Symbol();
                r->flag = "bool expr";
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                condExpr(CONDGT, branchCount);
                branchCount += 2;
                $$ = r;
            }

        |   expr GE expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: GE type incompatable>\n";
                Symbol* r = new Symbol();
                r->flag = "bool expr";
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                condExpr(CONDGE, branchCount);
                branchCount += 2;
                $$ = r;
            }

        |   expr LT expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: LT type incompatable>\n";
                Symbol* r = new Symbol();
                r->flag = "bool expr";
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                condExpr(CONDLT, branchCount);
                branchCount += 2;
                $$ = r;
            }

        |   expr LE expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: LE type incompatable>\n";
                Symbol* r = new Symbol();
                r->flag = "bool expr";
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                condExpr(CONDLE, branchCount);
                branchCount += 2;
                $$ = r;
            }

        |   expr EQ expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: EQ type incompatable>\n";
                Symbol* r = new Symbol();
                r->flag = "bool expr";
                
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                condExpr(CONDEQ, branchCount);
                branchCount += 2;
                $$ = r;
            }

        |   expr NE expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: NE type incompatable>\n";
                Symbol* r = new Symbol();
                r->flag = "bool expr";
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                condExpr(CONDNE, branchCount);
                branchCount += 2;
                $$ = r;
            }

        |   expr AND expr
            {
                //if(($1)->valueType != (char*)"boolean" || ($3)->valueType != (char*)"boolean") cout<<"<type error: AND must be boolean>\n";
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: AND type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = (char*)"boolean";
                r->flag = "bool expr";
                if(($1)->value.boolVal != ($3)->value.boolVal) r->value.boolVal = false;
                else r->value.boolVal = true;
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }
                
                getOperator(IAND);
                $$ = r;
            }

        |   expr OR expr
            {
                if(($1)->valueType != ($3)->valueType) cout<<"<type error: OR type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = (char*)"boolean";
                r->flag = "bool expr";
                if(($1)->value.boolVal || ($3)->value.boolVal) r->value.boolVal = true;
                else r->value.boolVal = false;
                if(($1)->flag != "function"){
                    if(($1)->valueType == "str"){
                        if(($1)->flag == "constant") getConst(($1)->value.intVal);
                        else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                        else getLocalVar(($1)->localidx);
                    }
                    if(($1)->valueType == "int"){
                        if(($1)->flag != "expr"){
                            if(($1)->flag == "constant") getConst(($1)->value.intVal);
                            else if(($1)->localidx == -1) getGlobalIntVar(($1)->name);
                            else getLocalVar(($1)->localidx);
                        }
                    }
                    if(($1)->valueType == "boolean"){
                        if(($1)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($3)->flag != "function"){
                    if(($3)->valueType == "str"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                    if(($3)->valueType == "int"){
                        if(($3)->flag != "expr"){
                            if(($3)->flag == "constant") getConst(($3)->value.intVal);
                            else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                            else getLocalVar(($3)->localidx);
                        }
                    }
                    if(($3)->valueType == "boolean"){
                        if(($3)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                getOperator(IOR);
                $$ = r;
            }

        |   NOT expr
            {
                if(($2)->valueType != (char*)"boolean") cout<<"<type error: NOT type incompatable>\n";
                //else if(($1)->valueType == "real" || ($3)->valueType == "real") $$ = (char*)"real";

                Symbol* r = new Symbol();
                r->scope = scopeTemp;
                r->valueType = (char*)"boolean";
                r->flag = "bool expr";
                if(($2)->flag != "function"){
                    if(($2)->valueType == "str"){
                        if(($2)->flag == "constant") getConst(($2)->value.intVal);
                        else if(($2)->localidx == -1) getGlobalIntVar(($2)->name);
                        else getLocalVar(($2)->localidx);
                    }
                    if(($2)->valueType == "int"){
                        if(($2)->flag != "expr"){
                            if(($2)->flag == "constant") getConst(($2)->value.intVal);
                            else if(($2)->localidx == -1) getGlobalIntVar(($2)->name);
                            else getLocalVar(($2)->localidx);
                        }
                    }
                    if(($2)->valueType == "boolean"){
                        if(($2)->value.boolVal){
                            pushBool(1);
                        }
                        else{
                            pushBool(0);
                        }
                    }
                }

                if(($2)->value.boolVal == true) pushBool(1);
                else pushBool(0);
                getOperator(INOT);
                ($2)->value.boolVal = !($2)->value.boolVal;
                r->value.boolVal = ($2)->value.boolVal;
                $$ = r;
            }

        |   PARENTHESES_L expr PARENTHESES_R
            {
                $$ = ($2);
            }
        ;

//bool_expr:  
//            expr 
//            {  
//                if(($1)->valueType != (char*)"boolean") cout<<"<type error: not boolean>\n";
//            };

/*statement*/
opt:    const_declare opt | var_declare opt | func_declare opt | proc_declare opt
        | 
        {
            if(scopeTemp == "global" && mainFlag == 0){
                mainFlag = 1;
                mainFunc();
            }
        }
        block opt 
        |
        {
            if(scopeTemp == "global" && mainFlag == 0){
                mainFlag = 1;
                mainFunc();
            }
        }
        stmt opt
        |
        {
            if(scopeTemp == "global" && mainFlag == 0){
                mainFlag = 1;
                mainFunc();
            }
        }
        %empty;

//opts:    opt | opt opts;
//
//stmts:  stmt | stmt stmts;

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
            Symbol* id_d = table->getItem(string($1));
            if(id_d->flag == "constant") cout<<"<error: assigment to constant variable not permitted.>\n";
            if(id_d->valueType != ($3)->valueType) cout<<"<warning: type implicit conversion>\n";
            if(id_d == nullptr) cout << "<error: id not found.>\n";

            /*if(($3)->flag == "variable" && ($3)->valueType == (char*)"int"){
                if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                else getLocalVar(($3)->localidx); 
            }
            if(($3)->valueType == (char*)"int" && ($3)->flag == "constant") getConst(($3)->value.intVal);
            if(($3)->valueType == (char*)"boolean" && ($3)->flag != "bool expr"){
                if(($3)->value.boolVal) pushBool(1);
                else pushBool(0);
            }*/

            if(($3)->flag != "function"){
                if(($3)->valueType == "str"){
                    storeString(($3)->value.strVal);
                }
                if(($3)->valueType == "int"){
                    if(($3)->flag != "expr"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                        else getLocalVar(($3)->localidx);
                    }
                }
                if(($3)->valueType == "boolean"){
                    if(($3)->value.boolVal){
                        pushBool(1);
                    }
                    else{
                        pushBool(0);
                    }
                }
            }            

            if(id_d->localidx == -1) storeGlobalVar(id_d->name, id_d->valueType);
            else storeLocalVar(id_d->localidx);
        }
//        |
//        array_ref ASSIGN expr
//        {
//            if(($1)->valueType != ($3)->valueType) cout<< "<type error: array must be " << ($1)->valueType << ">\n";
//        }
        |
        PUT
        {
            putstmt();
        }
        expr
        {
            //cout << "put check: " << ($3)->valueType <<"\n";
            if(($3)->flag != "function"){
                if(($3)->valueType == "str"){
                    putstr(($3)->value.strVal);
                    if(($3)->flag == "constant") getConst(($3)->value.intVal);
                    else if(($3)->localidx == -1) getGlobalIntVar(($3)->name);
                    else getLocalVar(($3)->localidx);
                }
                if(($3)->valueType == "int"){
                    if(($3)->flag != "expr"){
                        if(($3)->flag == "constant") getConst(($3)->value.intVal);
                        else if(($3)->localidx == -1 && ($3)->flag == "variable") getGlobalIntVar(($3)->name);
                        else if(($3)->localidx != -1 && ($3)->flag == "variable") getLocalVar(($3)->localidx);
                    }
                    putint();
                }
                if(($3)->valueType == "boolean"){
                    if(($3)->value.boolVal){
                        pushBool(1);
                    }
                    else{
                        pushBool(0);
                    }
                    putint();
                }
            }
            else putint();
            if(($3)->flag == "bool expr") putBool();

        }
        |
        GET ID
        |
        RESULT expr
        {
            returnType = (string)($2)->valueType;
            if(($2)->flag != "expr") {
                if(($2)->flag == "constant") getConst(($2)->value.intVal);
                else{
                    if(($2)->scope != "global" && ($2)->flag == "variable") getLocalVar(($2)->localidx);
                    else if(($2)->scope == "global") getGlobalIntVar(($2)->name);
                }
            }
        }
        |
        RETURN
        {
            returnType = "void";
        }
        |
        EXIT WHEN expr
        {
            loopStmt(CONDEQ, branchStack.top());
            branchStack.pop();
        }
        |
        EXIT
        |
        SKIP
        {
            skipstmt();
        }
        ;

conditional_stmt:   IF
                    {
                        scopeTemp = "condition";
                    }
                    expr THEN
                    {
                        branchStack.push(branchCount + 1);
                        branchStack.push(branchCount);
                        branchStack.push(branchCount + 1);
                        branchStack.push(branchCount);
                        branchCount += 2;

                        condStmt(branchStack.top());
                        branchStack.pop();
                    }
                    opt else_stmt
                    {
                        if(elseFlag) condStmtEnd(branchStack.top());
                        branchStack.pop();
                    }
                    END IF
                    {
                        table->dump("condition");
                    };

else_stmt:  ELSE
            {
                elseFlag = 1;

                int gotoL = branchStack.top();
                branchStack.pop();
                int curL = branchStack.top();
                branchStack.pop();
                elseStmt(gotoL, curL);
            }
            opt
            | %empty;

loop:   LOOP
        {
            scopeTemp = "loop";
            branchStack.push(branchCount + 1);
            branchStack.push(branchCount);
            branchStack.push(branchCount + 1);
            branchStack.push(branchCount);
            branchCount += 2;

            loopStart(branchStack.top());
            branchStack.pop();
        }
        opt END LOOP
        {
            int gotoL = branchStack.top();
            branchStack.pop();
            int curL = branchStack.top();
            branchStack.pop();
            loopEnd(gotoL, curL);
        };

for_loop:
            FOR ID COLON expr DOT DOT expr
            {
                pre_scope = scopeTemp;
                scopeTemp = "for_loop";
                if(($4)->value.intVal > ($7)->value.intVal) cout << "<error: loop condition must be increasing>\n";
                Symbol* loopC = table->getItem(string($2));
                if(loopC == nullptr) cout << "<error: " << string($2) << " not declared.>\n";
                if(($4)->valueType != (char*)"int") cout << "<type error: wrong type for loop condition.>\n";
                if(($7)->valueType != (char*)"int") cout << "<type error: wrong type for loop condition.>\n";

                if(($4)->flag == "constant") getConst(($4)->value.intVal);
                else if(($4)->flag == "variable"){
                    if(($4)->scope == "global") getGlobalIntVar(($4)->name);
                    else getLocalVar(($4)->localidx);
                }
                storeGlobalVar(loopC->name, (string)loopC->valueType);

                branchStack.push(branchCount + 1);
                branchStack.push(branchCount);
                branchStack.push(branchCount + 1);
                branchStack.push(branchCount);
                branchCount += 2;
                forLoopStart(branchStack.top());
                branchStack.pop();
            }
            opt
            {
                if(($7)->flag != "expr"){
                    if(($7)->flag == "constant") getConst(($7)->value.intVal);
                    else if(($7)->localidx == -1 && ($7)->flag == "variable") getGlobalIntVar(($7)->name);
                    else if(($7)->localidx != -1 && ($7)->flag == "variable") getLocalVar(($7)->localidx);
                }

                Symbol* loopC = table->getItem(string($2));
                if(loopC != nullptr){
                    if(loopC->localidx == -1) getGlobalIntVar(string($2));
                    else getLocalVar(loopC->localidx);
                }

                assFile << "isub\n";
                assFile << "ifeq L" << branchStack.top() << "\n";
                branchStack.pop();

                assFile << "iconst_1\n";
                if(loopC != nullptr){
                    if(loopC->localidx == -1) getGlobalIntVar(string($2));
                    else getLocalVar(loopC->localidx);
                }

                assFile << "iadd\n";
                if(loopC != nullptr){
                    if(loopC->localidx == -1) storeGlobalVar(string($2), (string)loopC->valueType);
                    else storeLocalVar(loopC->localidx);
                }

                int gotoL = branchStack.top();
                branchStack.pop();
                int curL = branchStack.top();
                branchStack.pop();

                forLoopEnd(gotoL, curL);
            }
            END FOR
            {
                table->dump("for_loop");
            }
            |
            FOR DECREASING ID COLON expr DOT DOT expr
            {
                pre_scope = scopeTemp;
                scopeTemp = "decreasing_loop";
                if(($5)->value.intVal < ($8)->value.intVal) cout << "<error: loop condition must be decreasing>\n";

                Symbol* loopC = table->getItem(string($3));
                if(loopC == nullptr) cout << "<error: " << string($3) << " not declared.>\n";
                if(($5)->valueType != (char*)"int") cout << "<type error: wrong type for loop condition.>\n";
                if(($8)->valueType != (char*)"int") cout << "<type error: wrong type for loop condition.>\n";

                if(($5)->flag == "constant") getConst(($5)->value.intVal);
                else{
                    if(($5)->scope == "global") getGlobalIntVar(($5)->name);
                    else getLocalVar(($5)->localidx);
                }

                branchStack.push(branchCount + 1);
                branchStack.push(branchCount);
                branchStack.push(branchCount + 1);
                branchStack.push(branchCount);
                branchCount += 2;
                forLoopStart(branchStack.top());
                branchStack.pop();
            } 
            opt
            {
                if(($8)->flag != "expr"){
                    if(($8)->flag == "constant") getConst(($8)->value.intVal);
                    else if(($8)->localidx == -1 && ($8)->flag == "variable") getGlobalIntVar(($8)->name);
                    else if(($8)->localidx != -1 && ($8)->flag == "variable") getLocalVar(($8)->localidx);
                }

                Symbol* loopC = table->getItem(string($3));
                if(loopC != nullptr){
                    if(loopC->localidx == -1) getGlobalIntVar(string($3));
                    else getLocalVar(loopC->localidx);
                }

                assFile << "isub\n";
                assFile << "ifeq L" << branchStack.top() << "\n";
                branchStack.pop();

                assFile << "iconst_1\n";
                if(loopC != nullptr){
                    if(loopC->localidx == -1) getGlobalIntVar(string($3));
                    else getLocalVar(loopC->localidx);
                }

                assFile << "isub\n";
                if(loopC != nullptr){
                    if(loopC->localidx == -1) getGlobalIntVar(string($3));
                    else getLocalVar(loopC->localidx);
                }

                int gotoL = branchStack.top();
                branchStack.pop();
                int curL = branchStack.top();
                branchStack.pop();

                forLoopEnd(gotoL, curL);
            }
            END FOR
            {
                table->dump("decreasing_loop");
            }
            ;

invocation:
            ID PARENTHESES_L
            {
                func_name = string($1);
            }
            arguments_empty PARENTHESES_R
            {
                if(countPara((string)($1)) != countArgu((string)($1))) cout<<"<Exception: Incorrect number of arguments>\n";
                for(auto i: parameter_vector){
                    for(auto j: argument_vector){
                        if(i.scope != j.scope) continue;
                        if(i.valueType != j.valueType) cout<<"<type error: parameter type mismatch>\n";
                    }
                }
                //show();
                Symbol* temp = table->getItem((string)($1));
                if(temp == nullptr) cout<<"<Invocation error: symbol not found>\n";
                funcInvoke(temp->name, temp->valueType, arguTypes);
                
                $$ = temp;
            }
            ;

arguments_empty: params;


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

    /* java file */
    string fileName = string(argv[1]);
    className = fileName.substr(0, fileName.find(".st"));
    assFile.open(className + ".jasm");
    programStart(className);

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */

    table->dump("global");
    if(mainFlag == 1) mainEnd();
    programEnd();
    return 0;
}