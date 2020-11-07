%{
/* C declarations */
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#define YYSTYPE double
double result; /*이전 result 값 기억*/
int yylex();
void yyerror(const char*); 
char* getword(int c);
%}
/* Bison declarations */
%token NUMBER
%token CEIL
%token FLOOR
%left '+' '-'
%left '*' '/'
%right '^'

%% /* Bison grammar rules */
input	:
		| input line
		;
line	: expr '\n'	{ result = $1; printf("Result: %f\n", $1);}
		| error '\n'	{yyerrok;}
		;
expr	: expr '+' term { $$ = $1 + $3; }
		| expr '-' term { $$ = $1 - $3; }
		| CEIL '(' expr ')' {$$ = ceil($2);}
		| FLOOR '(' expr ')' {$$ = floor($2);}
		| term { $$ = $1; }
		;
term	: term '*' factor { $$ = $1 * $3; }
		| term '/' factor { $$ = $1 / $3; }
		| factor { $$ = $1; }
		;
factor	: '(' expr ')' { $$ = $2; }
		| NUMBER { $$ = $1; }
		| '-' NUMBER { $$ = -$2; }
		| '_' { $$ = result; }
		;

%%
int yylex(void) {
	int c = getchar();
	if (c < 0) return 0;
	while (c == ' ' || c == '\t') c = getchar();
	if (isdigit(c) || c == '.') {
		ungetc(c, stdin);
		scanf("%lf", &yylval);
		return NUMBER;
	}
	if (isalpha(c)) {
		char *word;
		ungetc(c,stdin);
		word = getword(c); 
		if (strcmp(word,"ceil")) return CEIL;
		if (strcmp(word,"floor")) return FLOOR;
	}
	return c;
}

void yyerror(const char *s)
{
	fprintf(stderr, "%s\n", s);
}

int main(int argc, char *argv[])
{
	printf("Hello. Let's calculate~\n");
	yyparse();
} 