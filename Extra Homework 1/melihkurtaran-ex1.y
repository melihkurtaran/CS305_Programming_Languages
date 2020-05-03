%{
#include <stdio.h>
#include <string.h>
int yylex();
void yyerror (const char *s) 
{ /* Called by yyparse on error */
	printf ("%s\n", s); }

extern int identLine;
char variables[100][30];
int counter = 0;

char funcVariables[20][30];

int isDefinedinGlobal(char v[]);
int isDefinedinFunction(char v[]);
void clearFunc();
int fCounter;
%}

%union {
    char name[30];
}

%token tINT
%token tSTRING
%token tRETURN
%token tPRINT
%token tPOSINTVAL
%token tNEGINTVAL
%token tLPAR;
%token tRPAR
%token tCOMMA
%token tMOD
%token tASSIGNM
%token tMINUS
%token tPLUS
%token tDIV
%token tSTAR
%token tSEMI
%token tLBRAC
%token tRBRAC
%token tIDENT
%token tSTRINGVAL

%left tASSIGNM
%left tMOD
%left tPLUS tMINUS
%left tSTAR tDIV

%start prog

%type <name> tIDENT

%%

prog:               stmtlst
                    ;
stmtlst:            stmtlst stmt
                    | stmt
                    ;
stmt:               decl
                    | asgn
                    | print
                    | function
                    ;
decl:               type tIDENT tASSIGNM expr tSEMI { if(!isDefinedinGlobal($2)){
                                                       strcpy(variables[counter], $2); counter++;
                                                      }else{
                                                        printf("%d Redefinition of variable\n",identLine); return 1;
                                                      }
                                                     }
                    ;
type:               tINT
                    | tSTRING
                    ;
expr:               value
                    | functionCall
                    | expr tSTAR expr
                    | expr tPLUS expr
                    | expr tDIV expr
                    | expr tMOD expr
                    | expr tMINUS expr
                    | expr tNEGINTVAL
                    ;
value:              tIDENT { if(!isDefinedinGlobal($1)){
                                printf("%d Undefined variable\n",identLine); return 1;
                             }
                            }
                    | tPOSINTVAL
                    | tNEGINTVAL
                    | tSTRINGVAL
                    ;
functionCall:       tIDENT tLPAR actuals tRPAR
                    | tIDENT tLPAR tRPAR
                    ;
actuals:            actuals tCOMMA expr
                    | expr
                    ;
asgn:               tIDENT tASSIGNM expr tSEMI { if(!isDefinedinGlobal($1)){
                                                    printf("%d Undefined variable\n",identLine); return 1;
                                                 }
                                                }
                    ;
function:           type tIDENT tLPAR parameters tRPAR tLBRAC functionBody tRBRAC {clearFunc(); fCounter = 0;}
                    |  type tIDENT tLPAR tRPAR tLBRAC functionBody tRBRAC {clearFunc(); fCounter = 0;}
                    ;
parameters:         parameters tCOMMA type tIDENT { if(!isDefinedinGlobal($4) && !isDefinedinFunction($4)){
                                                     strcpy(funcVariables[fCounter], $4); fCounter++;
                                                    }else{
                                                      printf("%d Redefinition of variable\n",identLine); return 1;
                                                    }
                                                   }
                    | type tIDENT {if(!isDefinedinGlobal($2) && !isDefinedinFunction($2)){
                      strcpy(funcVariables[fCounter], $2); fCounter++;
                     }else{
                       printf("%d Redefinition of variable\n",identLine); return 1;
                     }
                    }
                    ;
functionBody:       functionstmtlst return
                    | return
                    ;
functionstmtlst:    functionstmtlst functionstmt
                    | functionstmt
                    ;
functionstmt:       funcdecl
                    | funcasgn
                    | funcprint
                    ;
funcasgn:           tIDENT tASSIGNM funcexpr tSEMI { if(!isDefinedinGlobal($1) && !isDefinedinFunction($1)){
                                                    printf("%d Undefined variable\n",identLine); return 1;
                                                 }
                                                }
                    ;
funcdecl:           type tIDENT tASSIGNM funcexpr tSEMI { if(!isDefinedinGlobal($2) && !isDefinedinFunction($2)){
                                                          strcpy(funcVariables[fCounter], $2); fCounter++;
                                                      }else{
                                                          printf("%d Redefinition of variable\n",identLine); return 1;
                                                      }
                                                    }
                    ;
funcprint:          tPRINT tLPAR funcexpr tRPAR tSEMI
                    ;
return:             tRETURN funcexpr tSEMI
                    ;
funcexpr:           funcvalue
                    | functionCallinF
                    | funcexpr tSTAR funcexpr
                    | funcexpr tPLUS funcexpr
                    | funcexpr tDIV funcexpr
                    | funcexpr tMOD funcexpr
                    | funcexpr tMINUS funcexpr
                    | funcexpr tNEGINTVAL
                    ;
funcvalue:          tIDENT { if(!isDefinedinGlobal($1) && !isDefinedinFunction($1)){
                                printf("%d Undefined variable\n",identLine); return 1;
                             }
                            }
                    | tPOSINTVAL
                    | tNEGINTVAL
                    | tSTRINGVAL
                    ;
functionCallinF:     tIDENT tLPAR functionactuals tRPAR
                    |  tIDENT tLPAR tRPAR
                    ;
functionactuals:    functionactuals tCOMMA funcexpr
                    | funcexpr
                    ;
print:              tPRINT tLPAR expr tRPAR tSEMI
                    ;   

%%

int isDefinedinGlobal(char v[])
{
    int i;
    for(i=0; i<100;i++)
    {   if(!strcmp(variables[i], v))
        {  return 1;  }
    }
    return 0;
}

int isDefinedinFunction(char v[])
{
    int i;
    for(i=0; i<20;i++)
    {   if(!strcmp(funcVariables[i], v))
        {  return 1;  }
    }
    return 0;
}

void clearFunc()
{
    int i;
    for(i=0; i<20;i++)
    {
         strcpy(funcVariables[i], "");
    }
}
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
