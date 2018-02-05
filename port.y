%{
#include <stdio.h>
#include <stdlib.h>
#include "estrutura.c"
void yyerror(char *msg);
extern int yylex();
%}
%union{
	int iValue;
	char id;
	struct treeNode *node;
};

%token <iValue> num
%token <id> var
%token print
%token whilestmt
%token start_program
%token end_program
%left GE LE EQ NE '>' '<'
%type <node> exp term factor stmt stmts assign

%%
program : start_program stmts end_program {execute($2); exit(1);}
	    ;

stmts : stmts stmt			{$$ = buildNodeStmt(STMT, 2, $1, $2);}
	  | stmt				{$$ = $1;}
	  ;

stmt : print exp ';' 	  				{$$ = buildNodeStmt(PRINT, 1, $2);}
	 | assign			  				{$$ = $1;}
	 | whilestmt '(' exp ')' '{' stmts'}'	{$$ = buildNodeStmt(WHILE, 2, $3,$6);}
	 ;

assign : var '=' exp ';' {$$ = buildNodeStmt(ASSIGN, 2, buildNodeId($1), $3);}
	   ;
exp : exp '+' term	{$$ = buildNodeStmt(SUM, 2, $1, $3);}
	| exp '-' term  {$$ = buildNodeStmt(SUB, 2, $1, $3);}
	| exp '<' term  {$$ = buildNodeStmt('<',2,$1, $3);}
	| exp '<' term  {$$ = buildNodeStmt('<',2,$1, $3);}
	| exp EQ term   {$$ = buildNodeStmt(eq,2,$1, $3);}
	| exp GE term   {$$ = buildNodeStmt(ge,2,$1, $3);}
	| exp LE term   {$$ = buildNodeStmt(le,2,$1, $3);}
	| exp NE term   {$$ = buildNodeStmt(ne,2,$1, $3);}
	| term 			{$$ = $1;}
	;

term : term '*' factor 	{$$ = buildNodeStmt(MULT, 2, $1, $3);}	 
	 | term '/' factor  {$$ = buildNodeStmt(DIV, 2, $1, $3);}
	 | factor 			{$$ = $1;}
	 ; 

factor : '(' exp ')' 	{$$ = $2;}
	   | num			{$$ = buildNodeConst($1);}
	   | '-' num			{$$ = buildNodeConst(-$2);}
	   | var			{$$ = buildNodeId($1);}
	   ;

%%

void yyerror(char *msg){
	fprintf(stderr, "%s\n", msg);
	exit(1);
}

int main(){

	for(int i =0; i < 52; i++)
		tableSymbols[i] = 0;

	return yyparse();
}
