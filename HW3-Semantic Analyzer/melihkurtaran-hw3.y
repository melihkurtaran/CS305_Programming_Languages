%{
#include <stdio.h>
int yylex(void);
void yyerror (const char *s)
{ /* Called by yyparse on error */
        printf ("%s\n", s); }

typedef struct DM{
    int row;
    int col;
} DM;

typedef struct R{
    int current;
    int next;
} R;

extern int line;

%}

%union {

  struct {
    int row;
    int col;
  } dm;

  struct {
     int current;
     int next;
  } r;

}

%type <r> row
%type <dm> rows
%type <dm> value
%type <dm> tIDENT
%type <dm> tINTNUM
%type <dm> tREALNUM
%type <dm> expr
%type <dm> matrixLit
%type <dm> vectorLit
%type <dm> transpose
%type <dm> tTRANSPOSE

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

prog:                    stmtlst
                         ;
stmtlst:                 stmtlst stmt
                         | stmt
                         ;
stmt:                    decl
                         | asgn
                         | if
                         ;
decl:                    type vars '=' expr ';'
                         ;
asgn:                    tIDENT '=' expr ';'
                         ;
if:                      tIF '(' bool ')' stmtlst tENDIF
                         ;
type:                    tINTTYPE
                         | tINTVECTORTYPE
                         | tINTMATRIXTYPE
                         | tREALTYPE
                         | tREALVECTORTYPE
                         | tREALMATRIXTYPE
                         ;
vars:                    vars ',' tIDENT
                         | tIDENT
                         ;
expr:                    value
                         | vectorLit
                         | matrixLit
                         | expr tDOTPROD expr { if($1.row == 1 && $3.row == 1 && $1.col == $3.col)
                            {
                             	$$.row = 0; $$.col = 0;
                            }
                           else
                            {
                            printf("ERROR 2: %d dimension mismatch\n",line); return 1;
                            }
                         }
                         | expr '*' expr { if($1.col == $3.row)
                                            {
                                             	$$.row = $1.row;
                                                $$.col = $3.col;
                                            }
                        else if($1.row == 0 && $1.col== 0)
                        {
                            $$.row = $3.row; $$.col = $3.col;
                        }
                        else if($3.row == 0 && $3.col== 0)
                        {
                            $$.row = $1.row; $$.col = $1.col;
                        }
                                           else
                                            {
                                             	printf("ERROR 2: %d dimension mismatch\n",line); return 1;
                                            }
                                         }
                         | expr '/' expr { if($3.row == $3.col && $1.col == $3.row)
                            {
                            $$.row = $1.row;
                            $$.col = $3.col;
                            }
                        else if($1.row == 0 && $1.col== 0 && $3.row == $3.col)
                        {
                            $$.row = $3.row; $$.col = $3.col;
                        }
                        else if($3.row == 0 && $3.col== 0)
                        {
                            $$.row = $1.row; $$.col = $1.col;
                        }
                            else
                            {
                             	printf("ERROR 2: %d dimension mismatch\n",line); return 1;
                            }
                         }
                         | expr '+' expr { if($1.row == $3.row && $1.col == $3.col)
                                           {
                                            	$$.row = $1.row;
                                                $$.col = $1.col;
                                           }
                                           else
                                           {
                                            	printf("ERROR 2: %d dimension mismatch\n",line); return 1;
                                           }
                                         }
                         | expr '-' expr { if($1.row == $3.row && $1.col == $3.col)
                                           {
                                            	$$.row = $1.row;
                                                $$.col = $1.col;
                                           }
                                           else
                                           {
                                            	printf("ERROR 2: %d dimension mismatch\n",line); return 1;
                                           }
                                         }
                         | transpose { $$.row = $1.row; $$.col = $1.col; }
                         ;
transpose:               tTRANSPOSE '(' expr ')' {$$.row = $3.col; $$.col = $3.row;}
                         ;
bool:                    comp
                         | bool tAND bool
                         | bool tOR bool
                         ;
comp:                    tIDENT relation tIDENT
                         ;
relation:                tGT
                         | tLT
                         | tGTE
                         | tLTE
                         | tEQ
                         | tNE
                         ;
vectorLit:               '[' row ']' { $$.row = 1;
                                    $$.col = $2.current;
                                      }
                         ;
row:             row ',' value { $$.current = $1.next;
                             $$.next = $$.current+1;
                                      }
                         | value { $$.current = 1;
                       $$.next = 2;
                               }
                         ;
matrixLit:               '[' rows ']' { $$.row = $2.row;
                                        $$.col = $2.col;
                                      }
                         ;
rows:                    row ';' row {
                                      	if($1.current != $3.current)
                                        { printf("ERROR 1: %d inconsistent matrix size\n",line);
                                         return 1; }
                                        else {
                                          $$.col = $1.current;
                      $$.row = 2;
                                        }
                                      }
                    | rows ';' row {
                                    	if($1.col != $3.current)
                                        { printf("ERROR 1: %d inconsistent matrix size\n",line);
                                          return 1;
                                         }
                    else{
                        $$.col = $1.col;
                        $$.row = $1.row+1;
                        }
                                      }
                         ;
value:                   tIDENT
                         | tINTNUM { $$.row = 0; $$.col = 0; }
                         | tREALNUM { $$.row = 0; $$.col = 0; }
                         ;

%%

int main ()
{
   if (!yyparse()) {
   // successful parsing
      printf("OK\n");
      return 0;
  }
}

