#ifndef _codeGenerate_H_
#define _codeGenerate_H_
#endif
#pragma once

#include "symbolTable.hpp"
#include <iostream>
#include <fstream>
#include <vector>
#include <stack>
using namespace std;

extern ofstream assFile;
extern string className;

enum op{
    IADD,
    ISUB,
    IMUL,
    IDIV,
    IMOD,
    IAND,
    IOR,
    INOT
};

enum condOP{
    CONDGT,
    CONDGE,
    CONDLT,
    CONDLE,
    CONDEQ,
    CONDNE
};

void programStart(string pid);
void programEnd();
void getConst(int num);
void pushGlobalIntVar(string id, int num);
void pushGlobalIntVar(string id);
void pushGlobalBoolVar(string, int b);
void pushGlobalBoolVar(string);
void getGlobalIntVar(string id);
void getGlobalBoolVar(string id);
void storeGlobalVar(string id, string t);
void storeLocalVar(int idx);
void pushLocalIntVar(int num, int idx);
void pushLocalBoolVar(int b, int idx);
void getLocalVar(int idx);
void storeString(string str);
void pushBool(int b);
void mainFunc();
void mainEnd();
void voidFunc(string id);
void voidFunc(string id, vector<string> params);
void voidFuncEnd();
void typeFunc(string id, string t);
void typeFunc(string id, string t, vector<string> params);
void boolFunc(string id, string t);
void boolFunc(string id, string t, vector<string> params);
void typeFuncEnd();
void funcInvoke(string id, string t, vector<string> argu);
void getOperator(int op);
void negative();
void type(string t);
void putstr(string str);
void putstmt();
void putint();
void putBool();
void skipstmt();
void createStack();
void condBranch(int cond);
void condExpr(int cond, int cnt);
void condStmt(int cnt);
void boolCondStmt();
void elseStmt(int gotoLabel, int label);
void boolElseStmt();
void condStmtEnd(int cnt);
void boolCondStmtEnd();
void loopStart(int cnt);
void loopStmt(int loopCond, int cnt);
void loopEnd(int gotoLabel, int label);
void forLoopStart(int cnt);
void forLoopStmt(int loopCond, int cnt);
void forLoopEnd(int gotoLabel, int label);