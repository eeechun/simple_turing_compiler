#include "codeGenerate.hpp"

void programStart(string name){
    assFile << "class " << name << "{\n";
}

void programEnd(){
    assFile << "}\n";
}

void getConst(int num){
    assFile << "sipush " << num << "\n";
}

void pushGlobalIntVar(string id, int num){
    assFile << "field static int " << id << " = " << num << "\n";
}

void pushGlobalIntVar(string id){
    assFile << "field static int " << id << "\n";
}

void pushGlobalBoolVar(string id, int b){
    assFile << "field static boolean " << id << " = ";
    if(b == 1) assFile << "1\n";
    else assFile << "0\n";
}

void pushGlobalBoolVar(string id){
    assFile << "field static boolean " << id << "\n";
}

void getGlobalIntVar(string id){
    assFile << "getstatic int " << className << "." << id << "\n";
}

void getGlobalBoolVar(string id){
    assFile << "getstatic boolean " << className << "." << id << "\n";
}

void storeGlobalVar(string id, string type){
    assFile << "putstatic " << type << " " << className << "." << id << "\n";
}

void pushLocalIntVar(int num, int idx){
    assFile << "sipush " << num << "\n";
    assFile << "istore " << idx << "\n";
}

void pushLocalBoolVar(int b, int idx){
    pushBool(b);
    assFile << "istore " << idx << "\n";
}

void getLocalVar(int idx){
    assFile << "iload " << idx <<"\n";
}

void storeLocalVar(int idx){
    assFile << "istore " << idx << "\n";
}

void storeString(string str){
    assFile << "ldc \"" << str << "\"\n";
}

void pushBool(int b){
    if(b == true) assFile << "iconst_1\n";
    else assFile << "iconst_0\n";
}

void mainFunc(){
    assFile << "method public static void main (java.lang.String[])\n";
    createStack();
    assFile << "{\n";
}

void mainEnd(){
    assFile << "return\n";
    assFile << "}\n";
}

void voidFunc(string id){
    assFile << "method public static void " << id << "()\n";
    createStack();
    assFile << "{\n";
}

void voidFunc(string id, vector<string> params){
    assFile << "method public static void " << id << "(";

    //one param
    if(params[0] == "int") assFile << "int";    
    else if(params[0] == "str") assFile << "string";
    else if(params[0] == "real") assFile << "float";

    //multiple params
    for(int i = 1; i < params.size(); i++){
        if(params[i] == "int") assFile << ", int";
        else if(params[1] == "str") assFile << ", string";
        else if(params[1] == "real") assFile << ", float";
    }

    assFile << ")\n";
    createStack();
    assFile << "{\n";
}

void voidFuncEnd(){
    assFile << "return\n";
    assFile << "}\n";
}

void typeFunc(string id, string t){
    assFile << "method public static int " << id << "()\n";
    createStack();
    assFile << "{\n";
}

void boolFunc(string id, string t){
    assFile << "method public static boolean " << id << "()\n";
    createStack();
    assFile << "{\n";
}

void boolFunc(string id, string t, vector<string> params){
    assFile << "method public static boolean " << id << "()\n";
    //one param
    if(params[0] == "int") assFile << "int";    
    else if(params[0] == "str") assFile << "string";
    else if(params[0] == "real") assFile << "float";

    //multiple params
    for(int i = 1; i < params.size(); i++){
        if(params[i] == "int") assFile << ", int";
        else if(params[i] == "str") assFile << ", string";
        else if(params[i] == "real") assFile << ", float";
    }

    assFile << ")\n";
    createStack();
    assFile << "{\n";
}

void typeFunc(string id, string t, vector<string> params){ //with params
    assFile << "method public static int " << id << "(";

    //one param
    if(params[0] == "int") assFile << "int";    
    else if(params[0] == "str") assFile << "string";
    else if(params[0] == "real") assFile << "float";

    //multiple params
    for(int i = 1; i < params.size(); i++){
        if(params[i] == "int") assFile << ", int";
        else if(params[i] == "str") assFile << ", string";
        else if(params[i] == "real") assFile << ", float";
    }

    assFile << ")\n";
    createStack();
    assFile << "{\n";
}

void typeFuncEnd(){
    assFile << "ireturn\n";
    assFile << "}\n";
}

void funcInvoke(string id, string t, vector<string> argu){
    assFile << "invokestatic ";
    if(t != "void") type(t);
    else assFile << "void";
    assFile << " " << className << "." << id << "(";

    if(argu.size() != 0){
        //one param
        if(argu[0] == "int") assFile << "int";    
        else if(argu[0] == "str") assFile << "string";
        else if(argu[0] == "real") assFile << "float";

        //multiple params
        for(int i = 1; i < argu.size(); i++){
            if(argu[i] == "int") assFile << ", int";
            else if(argu[1] == "str") assFile << ", string";
            else if(argu[1] == "real") assFile << ", float";
        }
    }

    assFile << ")\n";
}
void getOperator(int op){
    switch(op){
        case IADD:
            assFile << "iadd\n";
            break;
        case ISUB:
            assFile << "isub\n";
            break;
        case IMUL:
            assFile << "imul\n";
            break;
        case IDIV:
            assFile << "idiv\n";
            break;
        case IMOD:
            assFile << "irem\n";
            break;
        case IAND:
            assFile << "iand\n";
            break;
        case IOR:
            assFile << "ior\n";
            break;
        case INOT:
            assFile << "ixor\n";
            break;
        default:
        break;
    }
}

void negative(){
    assFile << "ineg\n";
}

void type(string t){
    if(t == "int") assFile << "int";
    else if(t == "string") assFile << "string";
    else if(t == "real") assFile << "float";
    else return;
}

void putstr(string str){
    storeString(str);
    assFile << "invokevirtual void java.io.PrintStream.print(java.lang.String)\n";
}

void putstmt(){
    assFile << "getstatic java.io.PrintStream java.lang.System.out\n";
}

void putint(){
    assFile << "invokevirtual void java.io.PrintStream.print(int)\n";
}

void putBool(){
    assFile << "invokevirtual void java.io.PrintStream.println(boolean)\n";
}

void skipstmt(){
    assFile << "getstatic java.io.PrintStream java.lang.System.out\n"
        << "invokevirtual void java.io.PrintStream.println()\n";
}

void createStack(){
    assFile << "max_stack 15\n";
    assFile << "max_locals 15\n";
}

void condBranch(int cond){
    switch(cond){
        case CONDGT:
            assFile << "ifgt";
            break;
        case CONDGE:
            assFile << "ifge";
            break;
        case CONDLT:
            assFile << "iflt";
            break;
        case CONDLE:
            assFile << "ifle";
            break;
        case CONDEQ:
            assFile << "ifeq";
            break;
        case CONDNE:
            assFile << "ifne";
            break;
        default:
        break;
    }
}

void condExpr(int cond, int cnt){
    assFile << "isub\n";
    condBranch(cond);
    assFile << " L" << cnt << "\n";
    assFile << "iconst_0\n";
    assFile << "goto L" << cnt + 1 << "\n";
    assFile << "L" << cnt << ":\n";
    assFile << "iconst_1\n";
    assFile << "L" << cnt + 1 << ":\n";
}

void condStmt(int cnt){
    assFile << "ifeq L" << cnt << "\n";
}

void boolCondStmt(){
    assFile << "ifeq Lfalse\n";
}

void elseStmt(int gotoLabel, int label){
    assFile << "goto L" << gotoLabel << "\n";
    assFile << "L" << label << ":\n";
}

void boolElseStmt(){
    assFile << "goto Lexit\n";
    assFile << "Lfalse:\n";
}

void condStmtEnd(int cnt){
    assFile << "L" << cnt << ":\n";
}

void boolCondStmtEnd(){
    assFile << "Lexit:\n";
}

void loopStart(int cnt){
    assFile << "L" << cnt << ":\n";
}

void loopStmt(int loopCond, int cnt){
    assFile << "ifne L" << cnt << "\n";
}

void loopEnd(int gotoLabel, int label){
    assFile << "goto L" << gotoLabel <<"\n";
    assFile << "L"<< label << ":\n";
}

void forLoopStart(int cnt){
    assFile << "L" << cnt << ":\n";
}

void forLoopStmt(int loopCond, int cnt){
    assFile << "isub\n";
    condBranch(loopCond);
    assFile << " Fortrue\n";
    assFile << "iconst_0\n";
    assFile << "goto Forfalse\n";
    assFile << "Fortrue:\n";
    assFile << "iconst_1\n";
    assFile << "Forfalse:\n";
    assFile << "ifne Forexit\n";
}

void forLoopEnd(int gotoLabel, int label){
    assFile << "goto L" << gotoLabel <<"\n";
    assFile << "L"<< label << ":\n";
}