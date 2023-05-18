#include <iostream>
#include <vector>
#include <algorithm>
#include <iomanip>
using namespace std;

struct Symbol{
	string name;
	char* valueType;
	string scope;
	string flag;
};

/*struct Value{
    int intVal;
    double dVal;
    string strVal;
};*/

class symbolTable{
private:
	vector<Symbol> symbols;
	vector<Symbol> dumpTable;

public:
	symbolTable();
	void create();
	int lookup(string sscope, string id);
	int insert(string name, string sscope, char* stype, string sflag);
	void dump(string sscope);
	Symbol* getDetail(string sscope, string id);
};