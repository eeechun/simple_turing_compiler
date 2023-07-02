#ifndef _symbolTable_H_
#define _symbolTable_H_
#endif
#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <iomanip>
using namespace std;

struct Value{
	int intVal;
	double dVal;
	string strVal;
    bool boolVal;
};

struct Symbol{
	string name;
	char* valueType;
	string scope;
	string flag;
	Value value;
	int localidx;
};

class symbolTable{
private:
	vector<Symbol> symbols;
	vector<Symbol> dumpTable;
	vector<Symbol> local;
	vector<Symbol> global;

public:
	symbolTable();
	void create();
	int lookup(string sscope, string id);
	Symbol* getLocal(string id);
	int insert(int idx, string name, Value svalue, string sscope, char* stype, string sflag);
	void removeItem(string sscope);
	void dump(string sscope);
	Symbol* getItem(string id);
};