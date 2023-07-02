#include "symbolTable.hpp"

void create(){
	symbolTable *table = new symbolTable();
}

symbolTable::symbolTable(){
	symbols.clear();
}

int symbolTable::insert(int idx, string id, Value svalue, string sscope, char* stype, string sflag){
	Symbol sym;
	sym.localidx = idx;
	sym.name = id;
	sym.value = svalue;
	sym.scope = sscope;
	sym.valueType = stype;
	sym.flag = sflag;
	symbols.push_back(sym);

	if(sscope == "global") global.push_back(sym);
	else local.push_back(sym);

	return 1;
}

int symbolTable::lookup(string sscope, string id){
	vector<Symbol>::iterator it = find_if(symbols.begin(), symbols.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == symbols.end()) return -1;
	else{
		if(symbols.at(distance(symbols.begin(), it)).scope == sscope){
			return distance(symbols.begin(), it);
		}
		else return -1;
	}
}

Symbol* symbolTable::getLocal(string id){
	vector<Symbol>::iterator it = find_if(local.begin(), local.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == symbols.end()) return nullptr;
	else return &local.at(distance(local.begin(), it));
}

Symbol* symbolTable::getItem(string id){
	vector<Symbol>::iterator it = find_if(local.begin(), local.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == local.end()) {
		vector<Symbol>::iterator it2 = find_if(global.begin(), global.end(), [id](const Symbol& s) { return s.name == id; });
		if(it2 == global.end()) return nullptr;
		else return &global.at(distance(global.begin(), it2));
	}
	else return &local.at(distance(local.begin(), it));
}

void symbolTable::removeItem(string sscope){
	vector<Symbol>::iterator it = remove_if(symbols.begin(), symbols.end(), [sscope](const Symbol& s) { return s.scope == sscope; });
	symbols.erase(it,symbols.end());

	vector<Symbol>::iterator it2 = remove_if(local.begin(), local.end(), [sscope](const Symbol& s) { return s.scope == sscope; });
	local.erase(it2,local.end());
}

void symbolTable::dump(string sscope){
	cout << sscope << " symbol table:\n";
	
	int colWidth = 20;
	cout << setw(colWidth) << "id" << setw(colWidth) << "scope" << setw(colWidth) << "type" 
		<< setw(colWidth) /*<< "value" << setw(colWidth)*/ << "flag" << setw(colWidth) << "local index" << "\n";
	cout << "---------------------------------------------------------------------------------------------------------\n";

	for(auto i : symbols){
		if(i.scope == sscope){
			dumpTable.push_back(i);
		}
	}
	for(auto i : dumpTable){
		cout << setw(colWidth) << i.name << setw(colWidth) << i.scope << setw(colWidth) 
				<< i.valueType << setw(colWidth);

		/*if(i.valueType == "int") cout << i.value.intVal << setw(colWidth);
		else if(i.valueType == "real") cout << i.value.dVal << setw(colWidth);
		else if(i.valueType == "str") cout << i.value.strVal << setw(colWidth);
		else if(i.valueType == "boolean") cout << i.value.boolVal << setw(colWidth);*/

		cout << i.flag << setw(colWidth) << i.localidx << "\n";
	}

	dumpTable.clear();
	cout << "---------------------------------------------------------------------------------------------------------\n";

	if(sscope != "global") removeItem(sscope);
}