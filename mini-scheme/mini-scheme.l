%{

#include <stdio.h>
#include <iostream>
using namespace std;

/**
 * See documentation within the micro-scheme example as
 * to why the lexical structure of the language is defined
 * the way it is.
 */

/**
 * Constants given to identity the token class of the
 * most recently scanned lexeme.  Each of the single character
 * tokens is identified by its ASCII code.  But tokens
 * compromised of two or more characters generally fall
 * into one of a finite number of types/categories (symbol, number,
 * reserved word and, reserved word lambda, etc.).  We assign
 * a number (outside the ASCII range) to each of these types,
 * and make sure yylex returns the correct type constant.
 */

static const int kSchemeSymbol = 256;
static const int kSchemeNumber = 257;
static const int kSchemeQuote = 258;
static const int kSchemeLambda = 259;
static const int kSchemeAnd = 260;
static const int kSchemeOr = 261;
static const int kSchemeNot = 262;

/**
 * Defines a single global variable that's populated
 * just prior to the moment that yylex returns.  In all cases,
 * yylex returns the type constants associated with the most
 * recent scanned token.  But in cases where the type constant
 * doesn't tell us the full story (i.e. kSchemeNumber is returns,
 * but what was the number??), we expect the token global to
 * be populated with information about the token/lexeme itself.
 * In this case, if kSchemeSymbol is returned, the strValue field
 * token.value houses the token's characters.  If kSchemeNumber is
 * returned, then the intValue field of token.value is relevant and
 * stored the integer equivalent of the recently scanned digit string.
 * 
 * Globals are normally verboten, but we don't choose the interface for
 * yylex, and the only reasonable way for yylex to return information beyond
 * a type constant is to use a global variable.  We'll see with
 * later examples that the parser and the lexer communicate data back and
 * forth via global variables.
 */

struct token_t {
  int type;
  union {
    char strValue[1024];
    int intValue;
  } value;
} token;

%}

WhiteSpace     [ \n\t\r]+
Symbol         [a-z+\-\/*%!@#$\^&~>?]+
Number         [0-9]+

%%

{WhiteSpace}   { ; }
"("            { return token.type = '('; }
")"            { return token.type = ')'; }
quote          { return token.type = kSchemeQuote; }
lambda         { return token.type = kSchemeLambda; }
and            { return token.type = kSchemeAnd; }
or             { return token.type = kSchemeOr; }
not            { return token.type = kSchemeNot; }
{Symbol}       { strcpy(token.value.strValue, yytext); return token.type = kSchemeSymbol; }
{Number}       { token.value.intValue = strtol(yytext, NULL, 10); return token.type = kSchemeNumber; }
.              { cerr << "Unexpected Character: '" << yytext[0] << "'" << endl; }

%%

static void publishTokenInfo(const token_t& t) {
  if (token.type < kSchemeSymbol) {
    cout << "Single character: " << char(t.type) << endl;
    return;
  }

  switch (t.type) {
  case kSchemeSymbol:
    cout << "Scheme Symbol: \"" << t.value.strValue << "\"" << endl;
    return;
  case kSchemeNumber:
    cout << "Scheme Number: " << t.value.intValue << endl;
    return;
  case kSchemeQuote:
    cout << "Scheme Keyword: quote" << endl;
    return;
  case kSchemeLambda:
    cout << "Scheme Keyword: lambda" << endl;
    return;
  case kSchemeAnd:
    cout << "Scheme Keyword: and" << endl;
    return;
  case kSchemeOr:
    cout << "Scheme Keyword: or" << endl;
    return;
  case kSchemeNot:
    cout << "Scheme Keyword: not" << endl;
    return;
  }
}

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
  while (yylex() != 0) {
    publishTokenInfo(token);
  }
  
  cout << "Reached end of file!" << endl;
  return 0;
}
