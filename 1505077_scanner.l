%x STR
%x STR1
%x STR2


%x COM
%x COM1

%x ALTCOM
%x ALTCOM1

%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include<bits/stdc++.h>
#include "SymbolTable.h"
#include "y.tab.h"


using namespace std;

int line_count=1;
int scopetableId=1;
int line_begin=1;
int err_count=0;


string zz="";
string com="";
bool slash_state=false;

extern YYSTYPE yylval;
extern SymbolTable st;
void yyerror(char *);


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

%%

{NEWLINE} {line_count++;}	
{WHITESPACE} {}

"if"	{
			return IF;		
		}
		
"else"	{
			
			return ELSE;		
		}


"for"	{	
		return FOR;	
			
		}

"while"	{
			
			return WHILE;		
		}

"do"	{
			//fprintf(tokenout,"<DO>");
			//fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}

"break"	{
			//fprintf(tokenout,"<BREAK>");
			//fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
			return BREAK;		
		}


"int"	{
			//fprintf(tokenout,"<INT>");
			//fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
			return INT;		
		}

"char"	{
			//fprintf(tokenout,"<CHAR>");
			//fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
			return CHAR;		
		}

"float"	{
			//fprintf(tokenout,"<FLOAT>");
			//fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
			return FLOAT;		
		}

"double"	{
			//fprintf(tokenout,"<DOUBLE>");
			//fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}

"void"	{
			//fprintf(tokenout,"<VOID>");
			//fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
			return VOID;		
		}
"return"	{
			//fprintf(tokenout,"<RETURN>");
			//fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
			return RETURN;		
		}
"switch"	{
			//fprintf(tokenout,"<SWITCH>");
			//fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
"case"	{
			//fprintf(tokenout,"<CASE>");
			//fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}
"default"	{
			//fprintf(tokenout,"<DEFAULT>");
			//fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
"continue"	{
			//fprintf(tokenout,"<CONTINUE>");
			//fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}



"println"	{return PRINTLN;}


"+"		|

"-"		{
			//fprintf(tokenout,"<ADDOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext,"ADDOP");
			yylval.s = s;			
			return ADDOP;
		
		}
				
"*"		|

"/"		|

"%"		{
			//fprintf(tokenout,"<MULOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext,"MULOP");
			yylval.s = s;			
			return MULOP;
			
		}

				

"++"	{
			//fprintf(tokenout,"<INCOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
			//SymbolInfo *s= new  SymbolInfo(yytext,"INCOP");
			//yylval.s = s;				
			return INCOP;


		}

"--"		{
			//fprintf(tokenout,"<INCOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
			//SymbolInfo *s= new  SymbolInfo(yytext,"DECOP");
			//yylval.s=s;				
			return DECOP;


		}


"="		{
			//fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			//SymbolInfo *s= new  SymbolInfo(yytext,"ASSIGNOP");
			//yylval.s = s;				
			return ASSIGNOP;
		}



"<="		|

">="		|

"<"		|

">"		|

"=="		|

"!="		{
			//fprintf(tokenout,"<RELOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext,"RELOP");
			yylval.s = s;							
			return RELOP;

		}


"&&"		|

"||"		{
			//fprintf(tokenout,"<LOGICOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext,"LOGICOP");
			yylval.s = s;			
			return LOGICOP;

		}

"&"		|

"|"		|

"^"		|

"<<"		|

">>"		{
			//fprintf(tokenout,"<BITOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
			
			
		}

"!"		{
			//fprintf(tokenout,"<NOT,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
			return NOT;
		}

"("		{
			//fprintf(tokenout,"<LPAREN,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
			return LPAREN;
		}

")"		{
			//fprintf(tokenout,"<RPAREN,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
			return RPAREN;
		}

"{"		{
			//fprintf(tokenout,"<LCURL,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
			return LCURL;
		}

"}"		{
			//fprintf(tokenout,"<RCURL,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
			return RCURL;
		}

"["		{
			//fprintf(tokenout,"<LTHIRD,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
			//printf("Haha\n");	
			return LTHIRD;
		}

"]"		{
			//fprintf(tokenout,"<RTHIRD,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
			return RTHIRD;
		}

","		{
			//fprintf(tokenout,"<COMMA,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
			return COMMA;
		}

";"		{
			//fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			return SEMICOLON;
		}
		
{DIGIT}+ 	{
				//fprintf(tokenout,"<CONST_INT,%s>",yytext);
				//fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				//insert in symbol table and print symbol table content(only non empty buckets)
				SymbolInfo *s= new  SymbolInfo(yytext,"CONST_INT");
				yylval.s = s;				
				//if(st.Insert(yytext,"CONST_INT")==true)
				//	st.PrintAll();
				return CONST_INT;		
		}

({DIGIT}*\.?{DIGIT}+|{DIGIT}+\.)(E[-+]?{DIGIT}+)?  {
							//fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
						        //fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext); 							
							//if(st.Insert(yytext,"CONST_FLOAT")==true)
							  //  st.PrintAll();
							SymbolInfo *s= new  SymbolInfo(yytext,"CONST_FLOAT");
							yylval.s = s;							
							return CONST_FLOAT;   
						}

'[^\n\\']'|'\\[ntafrbv0\\]' 		{	
							bool b=false;
							char* str=strdup(yytext);
							int len=strlen(str);
							string s="";
							for(int i=0;i<len;i++)
							{
								if(str[i]=='\\')
								{	
									b=true;
									
									if(str[i+1]=='n')
										s+="\n";
									else if(str[i+1]=='t')
										s+="\t";
									else if(str[i+1]=='a')
										s+="\a";
									else if(str[i+1]=='f')
										s+="\f";
									else if(str[i+1]=='r')
										s+="\r";
									else if(str[i+1]=='b')
										s+="\b";
									else if(str[i+1]=='v')
										s+="\v";
									else if(str[i+1]=='0')
										s+="\0";
									else if(str[i+1]=='\\')
										s+="\\";
																	
								}
							}
							
							if(!b)
								s=str[1];
							//fprintf(tokenout,"<CONST_CHAR,%s>",s.c_str());
							//fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
							//insert in symbol table and print symbol table content(only non empty buckets)
							//if(st.Insert(yytext,"CONST_CHAR")==true)
						//		st.PrintAll();


							
					

					    }


[_a-zA-Z][_a-zA-Z0-9]*		{

					//printf("<ID,%s>",yytext);
				        //fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
					//if(st.Insert(yytext,"ID")==true)
					 //   st.PrintAll();
					
					//SymbolInfo *s=st.Lookup(yytext);
					//if(s==NULL)					
					//{	
						//string m="ID",g=string(yytext);
						SymbolInfo *s= new SymbolInfo(yytext,"ID");
						//printf("Haha\n");
					//}						
						
					//printf("%s\n",s->getName().c_str());
					//printf("%s\n",s->getType().c_str());					
					yylval.s=s;					
					//printf("Token %s\n",yylval.s->getType().c_str());					
					return ID;				
				}



["]	{
		line_begin=line_count;		
		BEGIN(STR);
		
	}			


<STR>[^\\\n"]*	{
			char *m=strdup(yytext);
			string h=string(m);
			zz+=h;		
		}

<STR>\\		{
			slash_state=true;
			zz+=yytext;
			BEGIN(STR1);
		}


<STR1>[\\]	{
			slash_state= !slash_state;
			zz+=yytext;
		}

<STR1>[^\\\n"]	{
			
			zz+=yytext;
			slash_state=false;
			BEGIN(STR);		
		}	

<STR1>\n	{	
			line_count++;
			if(slash_state)
			{	
				slash_state=false;
				zz+="\n";
				BEGIN(STR);
			}			
			else
			{	
				slash_state=false;
				err_count++;
				string d,c="a";
				c[0]=34;
				d=c;			
				c+=zz;
				//fprintf(logout,"Line no %d: Unfinished String %s found\n",line_begin,c.c_str());
				zz="";			
				BEGIN(INITIAL);
			}
		}

<STR>["]	{	
			string d,c="a";
			c[0]=34;
			d=c;			
			
			c+=zz;
			c+=d;
			string s="";
			for(int i=0;i<c.size();i++)
			{	
				if(c[i]=='"')
					continue;
				if(c[i]=='\\'&&(c[i+1]=='n'||c[i+1]=='t'||c[i+1]=='a'||c[i+1]=='f'||c[i+1]=='b'||c[i+1]=='v'||c[i+1]=='0'||c[i+1]=='r'||c[i+1]=='\\'))
				{
					
					if(c[i+1]=='n')
						s+="\n";
					else if(c[i+1]=='t')
						s+="\t";
					else if(c[i+1]=='a')
						s+="\a";
					else if(c[i+1]=='f')
						s+="\f";
					else if(c[i+1]=='r')
						s+="\r";
					else if(c[i+1]=='b')
						s+="\b";
					else if(c[i+1]=='v')
						s+="\v";
					else if(c[i+1]=='\\')
						s+="\\";
					else if(c[i+1]=='0')
					{
						s+="\0";
						break;
					}						
																		

					i++;				
				}
				
				else
					s+=c[i];			
			}
			
			//fprintf(tokenout,"<STRING,%s",s.c_str());
			//fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_begin,c.c_str());					
			zz="";					
			BEGIN(INITIAL);
		}

<STR>\n		{	
			err_count++;
			string d,c="a";
			c[0]=34;
			d=c;			
			c+=zz;
			line_count++;
			//fprintf(logout,"Line no %d: Unfinished String %s found\n",line_begin,c.c_str());
			zz="";			
			BEGIN(INITIAL);

		}

<STR><<EOF>>	{
			err_count++;			
			string d,c="a";
			c[0]=34;
			d=c;			
			c+=zz;
			//fprintf(logout,"Line no %d: Unfinished String %s found\n",line_begin,c.c_str());
			zz="";			
			BEGIN(INITIAL);
		}

<STR1>["]	{	
			if(slash_state)
			{
				zz+=yytext;
				BEGIN(STR);	
			}	
			else
			{
				err_count++;			
				string d,c="a";
				c[0]=34;
				d=c;			
				c+=zz;
				c+=d;				
			//	fprintf(logout,"Line no %d: Unfinished String %s found\n",line_begin,c.c_str());
				zz="";			
				BEGIN(INITIAL);
			}
		}

<STR1><<EOF>>	{
			err_count++;
			string d,c="a";
			c[0]=34;
			d=c;			
			c+=zz;
			//fprintf(logout,"Line no %d: Unfinished String %s found\n",line_begin,c.c_str());
			zz="";			
			BEGIN(INITIAL);
		}


"//"		{	
			line_begin=line_count;
			com="//";
			BEGIN(COM);
		}

<COM>[^\n\\]+	{
			com+=yytext;
			
		}

<COM>[\\]	{
			com+=yytext;
			BEGIN(COM1);
		}

<COM1>[\\]+	{
			com+=yytext;
					
		}

<COM1>\n	{
			line_count++;
			com+="\n";
			BEGIN(COM);
		}

<COM1>[^\n\\]	{
			com+=yytext;
			BEGIN(COM);
		}

<COM>\n		{	
			line_count++;
			//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",line_begin,com.c_str());
			com="";			
			BEGIN(INITIAL);
		}

<COM><<EOF>>	{
			
			//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",line_begin,com.c_str());
			com="";			
			BEGIN(INITIAL);

		}

<COM1><<EOF>>	{
			
			//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",line_begin,com.c_str());
			com="";			
			BEGIN(INITIAL);

		}	

"/*"		{	
			line_begin=line_count;
			com="/*";
			BEGIN(ALTCOM);
		}

<ALTCOM>[^\n*]*	{
			com+=yytext;
		}

<ALTCOM>\n	{
			line_count++;
			com+=yytext;
		}

<ALTCOM>"*"	{
			com+=yytext;
			BEGIN(ALTCOM1);
		}

<ALTCOM1>[*]+	{
			com+=yytext;

		}

<ALTCOM1>[^*/]	{
			com+=yytext;
			BEGIN(ALTCOM);
		}	

<ALTCOM1>"/"	{
			com+=yytext;
			//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",line_begin,com.c_str());
			com="";			
			BEGIN(INITIAL);		
		}

<ALTCOM><<EOF>>	{	
			err_count++;
			//fprintf(logout,"Line no %d: Unfinished Comment %s found\n",line_begin,com.c_str());
			com="";			
			BEGIN(INITIAL);

		}

<ALTCOM1><<EOF>>	{
			err_count++;		
			//fprintf(logout,"Line no %d: Unfinished Comment %s found\n",line_begin,com.c_str());
			com="";			
			BEGIN(INITIAL);

		}

[0-9.]+		{
		
			//fprintf(logout,"Line no %d:Too many decimal points error %s\n",line_count,yytext);
			err_count++;
		}


({DIGIT}*\.?{DIGIT}+|{DIGIT}+\.)(E[-+]?(({DIGIT}*\.{DIGIT}+|{DIGIT}+\.))+)		{
		
											//fprintf(logout,"Line no %d:Ill formed number %s\n",line_count,yytext);
											err_count++;
		}


[0-9]+[_a-zA-Z][_a-zA-Z0-9]*	{

				//fprintf(logout,"Line no %d:Invalid suffix on numerical constant or Invalid prefix on identifier %s\n",line_count,yytext);
				err_count++;

			}


['](([^\\\n\t\a\f\v\r\0'][^'\n]+)|([\\][ntafrv0][^\n']+)|([\\][^ntafrv0'][^\n']*))[']	{

							//fprintf(logout,"Line no %d:Multi character constant error %s\n",line_count,yytext);
							err_count++;
						}


''	{

		//fprintf(logout,"Line no %d:Empty character constant error%s\n",line_count,yytext);
			err_count++;

	}

'[^\n'\\]		|

'[\\]'	|
		
'		{
			
			//fprintf(logout,"Line no %d:Unterminated character %s\n",line_count,yytext);
			err_count++;

		}

.	{
		//fprintf(logout,"Line no %d:Unrecognized character%s\n",line_count,yytext);
			err_count++;
	}





%%
int yywrap(void)
{return 1;}

/*
int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1505077_log.txt","w");
	tokenout= fopen("1505077_token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fprintf(logout,"Total lines = %d\n",line_count-1);
	fprintf(logout,"Total errors = %d\n",err_count);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
*/


