TARGET = lex
.PHONY : all clean
all : $(TARGET)
$(TARGET) : lex.yy.cpp
              g++ lex.yy.cpp -ll
              mv a.out p1.out
lex.yy.cpp : source.l
              lex source.l
              mv lex.yy.c lex.yy.cpp
clean :
        rm -f p1.out lex.yy.*
