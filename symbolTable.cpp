#include "symbolTable.hpp"

void create(){
	symbolTable *table = new symbolTable();
}

symbolTable::symbolTable(){
	symbols.clear();
}

int symbolTable::lookup(string id){
	vector<Symbol>::iterator it = find_if(symbols.begin(), symbols.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == symbols.end()){
		return -1;
	}
	else{
		return distance(symbols.begin(), it);
	}
}

Symbol* symbolTable::getDetail(string id){
	vector<Symbol>::iterator it = find_if(symbols.begin(), symbols.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == symbols.end()){
		return nullptr;
	}
	else{
		return { &(symbols.at(distance(symbols.begin(), it))) };
	}
}

int symbolTable::insert(string id, string sscope, string stype, Value sval, int sflag){
	Symbol detail;
	detail.name = id;
	detail.scope = sscope;
	detail.type = stype;
	detail.val = sval;
	symbols.push_back(detail);

	if(sscope == "global" && sflag != 4) global.push_back(id);
	else if(sflag != 4) local.push_back(id);
	
	if(sflag == 4) param_vec.push_back(id);		//parameters
	if(sflag == 3) func_name.push_back(id);		//functions
	if(sflag == 2) proc_name.push_back(id);		//procedures

	return 1;
}

int symbolTable::dump(){
	cout << "symbol table:\n";
	int colWidth = 20;
	cout << setw(colWidth) << "id" << setw(colWidth) << "scope" << setw(colWidth) << "type" 
		<< setw(colWidth) << "value" << setw(colWidth) << "flag";
	cout << setfill('*') << setw(5 * colWidth) << "*" << endl;
	cout << setfill(' ') << fixed;
	for(auto i : symbols){
		cout << setw(colWidth) << i.name << setw(colWidth) << i.scope << setw(colWidth) << i.type;
		if(typeid(i.val).name() == typeid(i.val.dVal).name()) cout << setw(colWidth) << i.val.dVal << setw(colWidth) << i.flag << "\n";
		else if(typeid(i.val).name() == typeid(i.val.intVal).name())cout << setw(colWidth) << i.val.intVal << setw(colWidth) << i.flag << "\n";
		else if(typeid(i.val).name() == typeid(i.val.strVal).name()){
			cout << setw(colWidth) << i.val.strVal;
		}
		cout << setw(colWidth) << i.flag << "\n";
	}
	return symbols.size();
}