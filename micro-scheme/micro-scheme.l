%{

#include <stdio.h>
#include <iostream>
using namespace std;

%}

WhiteSpace     [ \n\t\r]+
Symbol         [a-z+\-\/*%!@#$\^&~>?]+
Number         [0-9]+

%%

{WhiteSpace}   {}
"("            { cout << "Opening parenthesis" << endl; }
")"            { cout << "Closing parenthesis" << endl; }
"quote"        { cout << "Keyword: quote" << endl; }
"lambda"       { cout << "Keyword: lambda" << endl; }
"and"          { cout << "Keyword: and" << endl; }
"or"           { cout << "Keyword: or" << endl; }
"not"          { cout << "Keyword: not" << endl; }
{Symbol}       { cout << "Symbol: \"" << yytext << "\"" << endl; }
{Number}       { cout << "Number: " << yytext << endl; }
.              { cout << "Unexpected Character: '" << yytext[0] << "'" << endl; }

%%

static FILE *getInputStream(char **argv, int argc) {
  if (argc == 1) return stdin;
  FILE *infile = fopen(argv[1], "r");
  if (infile == NULL) {
    cerr << "Supplied file named \"" << argv[1] << "\" could not be opened." << endl;
    abort();
  }
  
  return infile;
}

int main(int argc, char **argv) {
  yyin = getInputStream(argv, argc);
  yylex();
  return 0;
}

