%{
#include <stdio.h>

void yyerror (const char *s) 
{ /* Called by yyparse on error */
	printf ("%s\n", s); }
%}

%token tINTTYPE
%token tINTVECTORTYPE
%token tINTMATRIXTYPE
%token tREALTYPE
%token tREALVECTORTYPE
%token tREALMATRIXTYPE
%token tTRANSPOSE
%token tIDENT
%token tDOTPROD
%token tIF
%token tENDIF
%token tREALNUM
%token tINTNUM
%token tAND
%token tOR
%token tGT
%token tLT
%token tGTE
%token tLTE
%token tNE
%token tEQ

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


prog: 			 stmtlst
			 ;
stmtlst:	   	 stmtlst stmt 
			 | stmt
			 ;
stmt:                    decl
                         | asgn
                         | if   
                         ;
decl:			 type vars '=' expr ';'
			 ;
asgn:			 tIDENT '=' expr ';'
			 ;
if:			 tIF '(' bool ')' stmtlst tENDIF
			 ;
type:			 tINTTYPE
			 | tINTVECTORTYPE
                         | tINTMATRIXTYPE
                         | tREALTYPE
                         | tREALVECTORTYPE    
                         | tREALMATRIXTYPE
                         ;
vars:			 vars ',' tIDENT
			 | tIDENT
			 ;
expr:			 value
			 | vectorLit
  			 | matrixLit
			 | expr tDOTPROD expr
                         | expr	'*' expr
                         | expr	'/' expr
                         | expr	'+' expr
                         | expr	'-' expr
			 | transpose 
			 ;    
transpose: 		 tTRANSPOSE '(' expr ')'
			 ;
bool: 			 comp
			 | bool tAND bool
			 | bool tOR bool
			 ;
comp:			 tIDENT relation tIDENT
			 ;
relation:		 tGT
			 | tLT
                         | tGTE
                         | tLTE
                         | tEQ
                         | tNE
			 ;
vectorLit:		 '[' row ']'
			 ;
row:			 row ',' value
			 | value
			 ;
matrixLit: 		 '[' rows ']'
			 ;
rows:			 row ';' row
			 | rows ';' row
			 ;
value:			 tIDENT
			 | tINTNUM
			 | tREALNUM
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
