TARGET = yacc
.PHONY : all clean
all : $(TARGET)
$(TARGET) : lex.yy.cpp y.tab.cpp symbolTable.hpp symbolTable.cpp codeGenerate.hpp codeGenerate.cpp
		g++ y.tab.cpp symbolTable.cpp codeGenerate.cpp -ll
		mv a.out p3.out
lex.yy.cpp : scanner.l
		lex scanner.l
		mv lex.yy.c lex.yy.cpp
y.tab.cpp : parser.y
		yacc -d parser.y
		mv y.tab.c y.tab.cpp
		mv y.tab.h y.tab.hpp
run : $(TARGET)
		./p3.out $(assFile).st
		./javaa $(assFile).jasm
clean :
	rm -f lex.yy.cpp y.tab.* *.out *.jasm *.class