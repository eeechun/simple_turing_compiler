#include "symbolTable.hpp"

void create(){
	symbolTable *table = new symbolTable();
}

symbolTable::symbolTable(){
	symbols.clear();
}

int symbolTable::insert(string id, string sscope, char* stype, string sflag){
	Symbol detail;
	detail.name = id;
	detail.scope = sscope;
	detail.valueType = stype;
	detail.flag = sflag;
	symbols.push_back(detail);

	return 1;
}

int symbolTable::lookup(string sscope, string id){
	vector<Symbol>::iterator it = find_if(symbols.begin(), symbols.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == symbols.end()) return -1;
	else{
		if(symbols.at(distance(symbols.begin(), it)).scope == sscope){
			return 1;
		}
		else return -1;
	}
}

Symbol* symbolTable::getDetail(string sscope, string id){
	vector<Symbol>::iterator it = find_if(symbols.begin(), symbols.end(), [id](const Symbol& s) { return s.name == id; });
	if(it == symbols.end()) return nullptr;
	if (symbols.at(distance(symbols.begin(), it)).scope != sscope)
	{
		vector<Symbol>::iterator it2 = find_if(it, symbols.end(), [id](const Symbol& s) { return s.name == id; });
		if(it2 != symbols.end()){
			return &symbols.at(distance(symbols.begin(), it));
		}
		else return nullptr;
	}
	else{
		return &symbols.at(distance(symbols.begin(), it));
	}
}

void symbolTable::removeItem(string sscope){
	vector<Symbol>::iterator it = remove_if(symbols.begin(), symbols.end(), [sscope](const Symbol& s) { return s.scope == sscope; });
	symbols.erase(it,symbols.end());
}

void symbolTable::dump(string sscope){
	cout << sscope << " symbol table:\n";
	
	int colWidth = 20;
	cout << setw(colWidth) << "id" << setw(colWidth) << "scope" << setw(colWidth) << "type" 
		<< setw(colWidth) << "flag" << "\n";
	cout << "----------------------------------------------------------------------------------\n";

	for(auto i : symbols){
		if(i.scope == sscope){
			dumpTable.push_back(i);
		}
	}
	for(auto i : dumpTable){
		cout << setw(colWidth) << i.name << setw(colWidth) << i.scope << setw(colWidth) 
				<< i.valueType << setw(colWidth) << i.flag << "\n";
	}

	dumpTable.clear();
	cout << "----------------------------------------------------------------------------------\n";

	if(sscope != "global") removeItem(sscope);
}