%{
/* C declarations */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#define YYSTYPE double
double result = 0; /*이전 result 값 기억*/
int yylex();
void yyerror(const char*); 
char* getword(int c);
%}
/* Bison declarations */
%token NUMBER
%token EMPTY
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
		| '\n' {printf("empty input^^\n"); printf("Last result: %f\n", result);}
		| error '\n'	{yyerrok;}
		;
expr	: expr '+' term { $$ = $1 + $3; }
		| expr '-' term { $$ = $1 - $3; }
		| term { $$ = $1; }
		;
term	: term '*' factor { $$ = $1 * $3; }
		| term '/' factor { $$ = $1 / $3; }
		| term '^' factor { $$ = pow($1, $3); }
		| CEIL factor {$$ = ceil($2);}		// $2보다 작지 않은 최소 크기의 정수 반환
		| FLOOR factor {$$ = floor($2);}	//$2보다 크지않은 최대크기의 정수 반환
		| factor { $$ = $1; }
		;
factor	: '(' expr ')' { $$ = $2; }
		| NUMBER { $$ = $1; }
		| '_' { $$ = result; }
		| EMPTY { $$ = result; }
		| '-' NUMBER { $$ = -$2; }
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
		if (strcmp(word,"ceil") == 0) return CEIL;
		if (strcmp(word,"floor") == 0) return FLOOR;
	}
	return c;
}

char* getword(int c) {
	char *word;
	int len = 0;
	while ((c=getchar()) != EOF && isalpha(c)) {
		word[len++] = c;
	}
	ungetc(c,stdin);
	word[len] = '\0';
	return word;
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