%{
#include <stdio.h>

void yyerror (const char *s) 
{
	printf ("%s\n", s); 
}
%}

%token tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE tREALVECTORTYPE tREALMATRIXTYPE tTRANSPOSE tIDENT tDOTPROD tIF tENDIF tREALNUM tINTNUM tAND tOR tGT tLT tGTE tLTE tNE tEQ

%left '='
%left tOR
%left tAND
%left tEQ tNE
%left tLTE tGTE tLT tGT
%left '+' '-'
%left '*' '/'
%left tDOTPROD
%left '(' ')'
%left tTRANSPOSE

%start prog

%%


prog: 		stmtlst
;
stmtlst:	stmtlst stmt 
			| stmt
;
stmt:       decl
            | asgn
            | if   
;
decl:		type vars '=' expr ';'
;
asgn:		tIDENT '=' expr ';'
;
if:			tIF '(' bool ')' stmtlst tENDIF
;
type:		tINTTYPE
			| tINTVECTORTYPE
            | tINTMATRIXTYPE
            | tREALTYPE
            | tREALVECTORTYPE    
            | tREALMATRIXTYPE
;
vars:		vars ',' tIDENT
			| tIDENT
;
expr:		value
			| vectorLit
  			| matrixLit
            | expr	'*' expr
            | expr	'/' expr
            | expr	'+' expr
            | expr	'-' expr
            | expr tDOTPROD expr
			| transpose 
;    
transpose: 	tTRANSPOSE '(' expr ')'
;
vectorLit:	'[' row ']'
;
row:		row ',' value
			| value
;
matrixLit: 	'[' rows ']'
;
rows:		row ';' row
			| rows ';' row
;
value:		tINTNUM
			| tREALNUM
;
bool: 		comp
			| bool tAND bool
			| bool tOR bool
;
comp:		tIDENT relation tIDENT
;
relation:	tGT
			| tLT
			| tGTE
            | tLTE
			| tEQ
			| tNE
;

%%
int main ()
{
   if (yyparse()) {
   // parse error
       printf("ERROR\n");
       return 1;
   }
   else {
   // successful parsing
      printf("OK\n");
      return 0;
   }
}
