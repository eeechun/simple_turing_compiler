TARGET = lex
.PHONY : all clean
all : $(TARGET)
$(TARGET) : lex.yy.cpp y.tab.cpp symbolTable.hpp symbolTable.cpp
		g++ y.tab.cpp symbolTable.cpp -ll
		mv a.out p2.out
lex.yy.cpp : scanner.l
		lex scanner.l
		mv lex.yy.c lex.yy.cpp
y.tab.cpp : parser.y
		yacc -d parser.y
		mv y.tab.c y.tab.cpp
		mv y.tab.h y.tab.hpp
clean :
	rm -f lex.yy.cpp y.tab.* p2.out