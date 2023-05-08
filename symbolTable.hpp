#include <iostream>
#include <vector>
#include <algorithm>
#include <iomanip>
using namespace std;

enum Flag{
	constant,
	variable,
	procedure,
	func,
	param,
	arr
};

struct Symbol{
	string name;
	string type;
	string scope;
	Value val;
	int flag;
};

struct Value{
    int intVal;
    double dVal;
    string strVal;
};

class symbolTable{
private:
	vector<Symbol> symbols;
	
public:
	symbolTable();
	int lookup(string id);
	int insert(string name, string stype, string sscope, Value sval, int sflag);
	int dump();
};
