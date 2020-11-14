%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<bits/stdc++.h>

#include "SymbolTable.h"
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count,err_count;
FILE *fp,*errorout,*logout,*assembly;


SymbolTable st(7);
Utility utility;

bool returnCheck=false;
vector<string> returnType;
vector<int>returnLine;

vector<string>funcList;
vector<string>varNames;
vector<string>arrNames;
vector<string>labelNames;


void yyerror(char *s)
{	
	printf("Error at line %d : %s\n",line_count,s);
	err_count++;
	//write your code
}


%}

%union{
SymbolInfo* s;
}


%token IF ELSE FOR WHILE BREAK LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD PRINTLN RETURN ASSIGNOP NOT INCOP DECOP CHAR MAIN THEN
%token <s> CONST_INT CONST_FLOAT ID ADDOP MULOP LOGICOP RELOP
//%token <s> CONST_FLOAT
//%token <s> ID
//%token <s> ADDOP
//%token <s> MULOP
//%token <s> LOGICOP
//%token <s> RELOP

%type <s> declaration_list type_specifier parameter_list expression_statement factor variable argument_list expression logic_expression rel_expression simple_expression term unary_expression arguments
%type <s> compound_statement unit program statement statements var_declaration func_declaration func_definition

//%left ADDOP
//%left MULOP
//%right LPAREN
//%right	ASSIGNOP

%nonassoc THEN
%nonassoc ELSE 


%%

start : program
	{	
		string returnVar="RETVAR";
		varNames.push_back(returnVar);
		//write your code in this block in all the similar blocks below
		//fprintf(logout,"\tSymbol Table\n\n");
		//st.PrintAll(logout);
		fprintf(errorout,"Total lines : %d\n\n",line_count-1);
		fprintf(errorout,"Total errors : %d\n\n",err_count);
		
		string s1="include \"emu8086.inc\"\n";
		string s2=".model small\n.stack 100h\n.data\n";
		string s3="",s4,s5=".code\n",s7="";
		for(int i=0;i<varNames.size();i++)
		{
			s4=varNames[i]+" dw ?\n";
			s3+=s4;
		}

		for(int i=0;i<arrNames.size();i++)
		{
			s4=arrNames[i]+" dw 100 dup (?)\n";
			s7+=s4;		
		}
		
		string asmCode1="";
		
		for(int i=0;i<funcList.size();i++)
		{
			asmCode1+=funcList[i]+"\n";
		}

		string s6="DEFINE_PRINT_NUM\nDEFINE_PRINT_NUM_UNS\nend main\n";
		//string asmCode1=$1->getAsmCode();
		string asmCode=s1+s2+s3+s7+s5+asmCode1+s6;
		fprintf(assembly,"%s",asmCode.c_str());	
	}
	;

program : program unit
		{
			//fprintf(logout,"At line no :%d  program : program unit \n",line_count);
			//fprintf(logout,"\n%s %s\n\n",$1->getName().c_str(),$2->getName().c_str());
			string name=$1->getName()+" "+$2->getName();
			string type=$1->getType()+"@"+$2->getType();
			$$=new SymbolInfo(name,type);
			string asmCode1=$1->getAsmCode();
			string asmCode2=$2->getAsmCode();
			string asmCode=asmCode1+asmCode2;
			$$->setAsmCode(asmCode);
		} 
	| unit
		{
			//fprintf(logout,"At line no :%d  program : unit \n",line_count);
			//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
		}
	;
	
unit : var_declaration
	{
		//fprintf(logout,"At line no :%d  unit : var_declaration \n",line_count);
		//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
		$$=$1;
	}
     | func_declaration
	{
		//fprintf(logout,"At line no :%d  unit : func_declaration \n",line_count);
		//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
		$$=$1;
	}
     | func_definition
	{
		//fprintf(logout,"At line no :%d  unit : func_definition \n",line_count);
		//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
		$$=$1;
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
			{
				//fprintf(logout,"At line no :%d  func_declaration : type_specifier ID parameter_list LPAREN RPAREN SEMICOLON \n",line_count);
				//fprintf(logout,"\n%s %s(%s);\n\n",$1->getName().c_str(),$2->getName().c_str(),$4->getName().c_str());
				
				string funcType=$1->getName();			
				string funcName=$2->getName();
				string parameterList=$4->getName();				
				if(st.Lookup(funcName)!=NULL)
				{
					fprintf(errorout,"Error at line %d: Multiple Declaration of %s\n\n",line_count,funcName.c_str());
					//cout<<"HaHoHa"<<endl;					
					err_count++;
				}					
				else
				{
					
					vector<string>parameters;
					vector<string>parameterType;
					utility.tokenize(parameters,parameterType,parameterList);
					int n=parameterType.size();
					
					vector<bool>flag(n,false);			
					for(int i=n-1;i>=0;i--)
					{	
						//cout<<parameterType[i]<<" "<<parameters[i]<<endl;
						if(parameterType[i]=="void")
							flag[i]=true;
					}
					//cout<<parameterList<<endl;					
					
					for(int i=n-1;i>=0;i--)
					{	
						if(flag[i]==true)
							continue;
						string n1=parameters[i];
						for(int j=i-1;j>=0;j--)
						{	
							//cout<<"HaiHai"<<endl;
							string n2=parameters[j];
							//cout<<"HauHau"<<endl;	
							if(parameters[i]==parameters[j])
							{	
								err_count++;
								fprintf(errorout,"Error at line %d: Multiple Declaration of %s\n\n",line_count,parameters[i].c_str());
								flag[j]=true;
								
							}
						}
					}
					//cout<<"Hahare"<<endl;
					SymbolInfo temp(funcName,"ID");
					temp.setFuncReturnType(funcType);
					temp.funcOn();					
					
					//assembly code start

					string asmFuncName=funcName;
					
					
					temp.setAsmName(asmFuncName);
					//funcNames.push_back(asmFuncName);
						
					for(int i=0;i<n;i++)
					{
						temp.InsertParameter(parameters[i],parameterType[i]);
						
						string asmVar=utility.newVariable();
						temp.insertAsmParameter(asmVar);// variables that will be used as the parameters of that function
						varNames.push_back(asmVar);					
					}					
					//assembly code end					

					st.Insert(temp);
							
				}	

				string name=$1->getName()+" "+$2->getName()+"("+$4->getName()+");\n";
				string type=$1->getType()+"@"+$2->getType()+"@LPAREN@"+$4->getType()+"@RPAREN@SEMICOLON";
				$$=new SymbolInfo(name,type);
				
				


				//st.PrintAll(logout);
			}
		| type_specifier ID LPAREN RPAREN SEMICOLON
			{
				//fprintf(logout,"At line no :%d  func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n",line_count);
				//fprintf(logout,"\n%s %s();\n\n",$1->getName().c_str(),$2->getName().c_str());
				
				string funcType=$1->getName();			
				string funcName=$2->getName();
				//cout<<funcType<<"gege"<<endl;				
				if(st.Lookup(funcName)!=NULL)
				{
					fprintf(errorout,"Error at line %d: Multiple Declaration of %s\n\n",line_count,funcName.c_str());
					err_count++;
				}					
				else
				{
					SymbolInfo temp(funcName,"ID");
					temp.setFuncReturnType(funcType);
					temp.funcOn();					
					
					//assembly code start
					string asmFuncName=funcName;
					
					temp.setAsmName(asmFuncName);
					//funcNames.push_back(asmFuncName);					

					//assembly code end
					st.Insert(temp);				
				}				
			
				string name=$1->getName()+" "+$2->getName()+"();\n";
				string type=$1->getType()+"@"+$2->getType()+"@LPAREN@RPAREN@SEMICOLON";
				$$=new SymbolInfo(name,type);

				//st.PrintAll(logout);
			}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
			{
				string funcType=$1->getName();
				string funcName=$2->getName();
				string parameterList=$4->getName();				
				SymbolInfo *s=st.Lookup(funcName);
				if(s==NULL)
				{
					vector<string>parameters;
					vector<string>parameterType;
					utility.tokenize(parameters,parameterType,parameterList);
					int n=parameterType.size();
					
					vector<bool>flag(n,false);			
					//cout<<flag.size()<<endl;					
					for(int i=n-1;i>=0;i--)
					{	
						//cout<<parameterType[i]<<" "<<parameters[i]<<endl;
						if(parameterType[i]=="void")
							flag[i]=true;
					}
					//cout<<parameterList<<endl;					
					
					for(int i=n-1;i>=0;i--)
					{	
						if(flag[i]==true)
							continue;
						//string n1=parameters[i];
						for(int j=i-1;j>=0;j--)
						{	
							//cout<<"HaiHai"<<endl;
							//string n2=parameters[j];
							//cout<<"HauHau"<<endl;	
							if(parameters[i]==parameters[j])
							{	
								err_count++;
								fprintf(errorout,"Error at line %d: Multiple Declaration of %s\n\n",line_count,parameters[i].c_str());
								flag[j]=true;
								
							}
						}
					}
					//cout<<"Hahare"<<endl;
					SymbolInfo temp(funcName,"ID");
					temp.setFuncReturnType(funcType);
					temp.funcOn();					
					string asmVarName;
					vector<string>asmNamesList;					
					for(int i=0;i<n;i++)
					{
						temp.InsertParameter(parameters[i],parameterType[i]);
						asmVarName=utility.newVariable();
						temp.insertAsmParameter(asmVarName);
						asmNamesList.push_back(asmVarName);
						varNames.push_back(asmVarName);					
					}					
					st.Insert(temp);
					//SymbolInfo *qq=st.Lookup(funcName);				
					st.Enter_Scope(7);
					//cout<<"HoHo"<<endl;
					for(int i=n-1;i>=0;i--)
					{
						if(flag[i]==true)
							continue;
						SymbolInfo gg(parameters[i],"ID");
						gg.setVarType(parameterType[i]);
						//string asmVarName=utility.newVariable();
						gg.setAsmName(asmNamesList[i]);						
						st.Insert(gg);
						//varNames.push_back(asmVarName);
					}
					int idNum=st.getCurrentId();
					//fprintf(logout,"New ScopeTable with id %d created \n\n",idNum);					
					//cout<<"GeReRe"<<endl;					
					//st.PrintAll(logout);				
				}
				else
				{	
					vector<string>parameters;
					vector<string>parameterType;
					utility.tokenize(parameters,parameterType,parameterList);
					int n=parameterType.size();
					vector<bool>flag(n,false);

					for(int i=n-1;i>=0;i--)
					{	
						//cout<<parameterType[i]<<" "<<parameters[i]<<endl;
						if(parameterType[i]=="void")
							flag[i]=true;
					}
					//cout<<parameterList<<endl;					
					
					for(int i=n-1;i>=0;i--)
					{	
						if(flag[i]==true)
							continue;
						//string n1=parameters[i];
						for(int j=i-1;j>=0;j--)
						{	
							//cout<<"HaiHai"<<endl;
							//string n2=parameters[j];
							//cout<<"HauHau"<<endl;	
							if(parameters[i]==parameters[j])
							{	
								//err_count++;
								//fprintf(errorout,"Error at line %d: Multiple Declaration of %s\n\n",line_count,parameters[i].c_str());
								flag[j]=true;
								
							}
						}
					}
	
					if(s->isFunc()==false)
					{
						fprintf(errorout,"Error at line %d: %s is not a function \n\n",line_count,funcName.c_str());
						err_count++;
						//Need to do something about the return type	
					}
					else
					{

						vector<string>v1,v2;
						v1=s->getParameter();
						v2=s->getParameterType();
						string trueType=s->getFuncReturnType();						
						
						int n1=v2.size();
						if(n1!=n)
						{
							fprintf(errorout,"Error at line %d: Parameters do not match with previous declaration \n\n",line_count);
							err_count++;
						}
						else
						{
							for(int i=0;i<n1;i++)
							{
								if(v1[i]!=parameters[i]||v2[i]!=parameterType[i])
								{
									fprintf(errorout,"Error at line %d: Parameters do not match with previous declaration \n\n",line_count);
									err_count++;
									break;
								}
							}
						}
						if(funcType!=trueType)
						{
							fprintf(errorout,"Error at line %d: Return type does not match with previous declaration \n\n",line_count);
							err_count++;
							
	
						}					
					}
					st.Enter_Scope(7);
					
					

					//cout<<"HoHo"<<endl;
					vector<string>asmParameterList=s->getAsmParameter();
					for(int i=n-1;i>=0;i--)
					{
						if(flag[i]==true)
							continue;
						SymbolInfo gg(parameters[i],"ID");
						gg.setVarType(parameterType[i]);
						gg.setAsmName(asmParameterList[i]);
						st.Insert(gg);
					}
					int idNum=st.getCurrentId();
					//st.PrintAll(logout);					
					//fprintf(logout,"New ScopeTable with id %d created \n\n",idNum);	
					
				}	
			}
		compound_statement
			{	

				//fprintf(logout,"At line no :%d  func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n",line_count);
				//fprintf(logout,"\n%s %s(%s)\n%s\n\n",$1->getName().c_str(),$2->getName().c_str(),$4->getName().c_str(),$7->getName().c_str());
				
				//Need to check for return type
				
				string name=$1->getName()+" "+$2->getName()+"("+$4->getName()+")\n"+$7->getName();
				string type=$1->getType()+"@"+$2->getType()+"@LPAREN@"+$4->getType()+"@RPAREN@"+$7->getType();
				$$=new SymbolInfo(name,type);

				int idNum=st.getCurrentId();
								
				//st.PrintAll(logout);				
				st.Exit_Scope();
				//fprintf(logout,"Scope with id %d removed \n\n",idNum);				
				
				string funcType=$1->getName();
				
				if(funcType=="void"&&returnCheck==true)
				{	
					for(int i=0;i<returnLine.size();i++)
					{
						fprintf(errorout,"Error at line %d: Void functions do not contain return statement \n\n",returnLine[i]);
						err_count++;
					}
					
				}
				else if(funcType!="void" && returnCheck==false)
				{
					fprintf(errorout,"Error at line %d: Function missing return statement \n\n",line_count);
					err_count++;
				}
				else if(funcType!="void" && returnCheck==true)
				{
					for(int i=0;i<returnLine.size();i++)
					{
						if(funcType!=returnType[i])
						{
							fprintf(errorout,"Error at line %d: Return type mismatch \n\n",returnLine[i]);
							err_count++;
						}					
					}
				}
				
				returnCheck=false;
				returnType.clear();
				returnLine.clear();
				//assembly code start
				string asmCode1=$7->getAsmCode();
				
				string funcName=$2->getName();
				string line1=funcName+" proc\n";
				string line2=funcName+" endp\n";
				//string asmCode1=$6->getAsmCode();
				
				string asmCodePart1,asmCodePart2;
				asmCodePart1=utility.getCodeWithoutReturnSegment(asmCode1);
				asmCodePart2=utility.getReturnSegment(asmCode1);
				
				string pushToStack="PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\n";				
				
				//string funcType=$1->getName();
				if(funcType=="void")
					asmCodePart2="POP DX\nPOP CX\nPOP BX\nPOP AX\nRET";
				string asmCode;
				
				
					asmCode=line1+pushToStack+asmCodePart1+asmCodePart2+line2;
				
				$$->setAsmCode(asmCode);
				
					funcList.push_back(asmCode);		


				//assembly code end				
				

			}
		| type_specifier ID LPAREN RPAREN
			{
				string funcType=$1->getName();
				string funcName=$2->getName();
				SymbolInfo *s=st.Lookup(funcName);
				if(s==NULL)
				{
					
					SymbolInfo temp(funcName,"ID");
					temp.setFuncReturnType(funcType);
					temp.funcOn();					
									
					st.Insert(temp);
					//SymbolInfo *qq=st.Lookup(funcName);				
					st.Enter_Scope(7);
					//cout<<"HoHo"<<endl;
					
					int idNum=st.getCurrentId();
					//fprintf(logout,"New ScopeTable with id %d created \n\n",idNum);					
					//cout<<"GeReRe"<<endl;					
					//st.PrintAll(logout);				
				}
				else
				{
					if(s->isFunc()==false)
					{
						fprintf(errorout,"Error at line %d: %s is not a function \n\n",line_count,funcName.c_str());
						err_count++;
						//Need to do something about the return type	
					}
					else
					{

						vector<string>v1,v2;
						v1=s->getParameter();
						v2=s->getParameterType();
						string trueType=s->getFuncReturnType();						
						
						int n1=v2.size();
						if(n1>0)
						{
							fprintf(errorout,"Error at line %d: Parameters do not match with previous declaration \n\n",line_count);
							err_count++;
						}
						
					}
				
					st.Enter_Scope(7);				
					int idNum=st.getCurrentId();
					//fprintf(logout,"New ScopeTable with id %d created \n\n",idNum);
				}
			
			}
			 compound_statement
			{	
				


				//fprintf(logout,"At line no :%d  func_definition : type_specifier ID LPAREN RPAREN compound_statement \n",line_count);
				//fprintf(logout,"\n%s %s()\n%s\n\n",$1->getName().c_str(),$2->getName().c_str(),$6->getName().c_str());
				string name=$1->getName()+" "+$2->getName()+"()\n"+$6->getName();
				string type=$1->getType()+"@"+$2->getType()+"@LPAREN@RPAREN@"+$6->getType();
				$$=new SymbolInfo(name,type);

				int idNum=st.getCurrentId();
								
				//st.PrintAll(logout);				
				st.Exit_Scope();
				//fprintf(logout,"Scope with id %d removed \n\n",idNum);

				string funcType=$1->getName();
				
				if(funcType=="void"&&returnCheck==true)
				{	
					for(int i=0;i<returnLine.size();i++)
					{
						fprintf(errorout,"Error at line %d: Void functions do not contain return statement \n\n",returnLine[i]);
						err_count++;
					}
					
				}
				else if(funcType!="void" && returnCheck==false)
				{
					fprintf(errorout,"Error at line %d: Function missing return statement \n\n",line_count);
					err_count++;
				}
				else if(funcType!="void" && returnCheck==true)
				{
					for(int i=0;i<returnLine.size();i++)
					{
						if(funcType!=returnType[i])
						{
							fprintf(errorout,"Error at line %d: Return type mismatch \n\n",returnLine[i]);
							err_count++;
						}					
					}
				}
				returnCheck=false;
				returnType.clear();
				returnLine.clear();
				
				//assembly code start


				string funcName=$2->getName();
				string line1=funcName+" proc\n";
				string line2=funcName+" endp\n";
				string asmCode1=$6->getAsmCode();
				
				string asmCodePart1,asmCodePart2;
				asmCodePart1=utility.getCodeWithoutReturnSegment(asmCode1);
				asmCodePart2=utility.getReturnSegment(asmCode1);
				
				string pushToStack="PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\n";				
				string misc="MOV AX,@DATA\nMOV DS,AX\n";
				string asmCode;
				if(funcName=="main")
				{
					asmCodePart2="MOV AH,4Ch\nINT 21h\n";
					asmCode=line1+misc+asmCodePart1+asmCodePart2+line2;				
				}
				else if(funcType=="void")
					asmCodePart2="POP DX\nPOP CX\nPOP BX\nPOP AX\nRET";				
				else
					asmCode=line1+pushToStack+asmCodePart1+asmCodePart2+line2;
				//string asmCode=line1+asmCodePart1+asmCodePart2+line2;
				$$->setAsmCode(asmCode);
				if(funcName=="main")
				{
					vector<string>::iterator it=funcList.begin();
					funcList.insert(it,asmCode);				
				}
				else
					funcList.push_back(asmCode);				
				//assembly code end
			}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
			{
				//fprintf(logout,"At line no :%d  parameter_list : parameter_list COMMA type_specifier ID\n",line_count);
				//fprintf(logout,"\n%s, %s %s\n\n",$1->getName().c_str(),$3->getName().c_str(),$4->getName().c_str());
				
				if($3->getType()=="VOID")
				{
					fprintf(errorout,"Error at line %d: Variable or field declared 'void'\n\n",line_count);	
					err_count++;
				}					
							
				

				string name=$1->getName()+", "+$3->getName()+" "+$4->getName();
				string type=$1->getName()+"@"+"COMMA"+"@"+$3->getType()+"@"+$4->getType();
				$$=new SymbolInfo(name,type);
			}
		| parameter_list COMMA type_specifier
			{
				//fprintf(logout,"At line no :%d  parameter_list : parameter_list COMMA type_specifier\n",line_count);
				//fprintf(logout,"\n%s , %s\n\n",$1->getName().c_str(),$3->getName().c_str());
				
				if($3->getType()=="VOID")
				{
					fprintf(errorout,"Error at line %d: Variable or field declared 'void'\n\n",line_count);	
					err_count++;
					
				}				
								

				
				string name=$1->getName()+", "+$3->getName();
				string type=$1->getType()+"@"+"COMMA"+"@"+$3->getType();
				$$=new SymbolInfo(name,type);

			}
 		| type_specifier ID
			{
				//fprintf(logout,"At line no :%d  parameter_list : type_specifier ID\n",line_count);
				//fprintf(logout,"\n%s %s\n\n",$1->getName().c_str(),$2->getName().c_str());
				
				if($1->getType()=="VOID")
				{
					fprintf(errorout,"Error at line %d: Variable or field declared 'void'\n\n",line_count);	
					err_count++;
				}	

				string name=$1->getName()+" "+$2->getName();
				string type=$1->getType()+"@"+$2->getType();
				$$=new SymbolInfo(name,type);
			}
		| type_specifier
			{
				//fprintf(logout,"At line no :%d  parameter_list : type_specifier \n",line_count);
				//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				
				if($1->getType()=="VOID")
				{
					fprintf(errorout,"Error at line %d: Variable or field declared 'void'\n\n",line_count);	
					err_count++;
				}					

				$$=$1;			
			}
 		;

 		
compound_statement : LCURL statements RCURL
			{
				//fprintf(logout,"At line no :%d  parameter_list : type_specifier \n",line_count);
				//fprintf(logout,"\n{\n%s\n}\n\n",$2->getName().c_str());
				string name="{\n"+$2->getName()+"\n}\n";
				string type="LCURL@"+$2->getType()+"RCURL";
				$$=new SymbolInfo(name,type);
				string asmCode=$2->getAsmCode();
				$$->setAsmCode(asmCode);
			}
 		    | LCURL RCURL
			{
				//fprintf(logout,"At line no :%d  compound_statement : LCURL RCURL \n",line_count);
				//fprintf(logout,"\n{\n}\n\n");
				string name="{\n}\n";
				string type="LCURL@RCURL";
				$$=new SymbolInfo(name,type);			
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
			{
				string var_type=$1->getType();
				if(var_type=="VOID")
				{
					fprintf(errorout,"Error at line %d: Variable or field declared 'void'\n\n",line_count);
					err_count++;		
				}
				else
				{	
					
					vector<string>var_names;
					vector<bool>arrayFlag;
					string var_list=$2->getName();
					utility.tokenize(var_names,arrayFlag,var_list);
					for(int i=0;i<var_names.size();i++)
					{
						if(st.Insert(var_names[i],"ID")==false)
						{
							fprintf(errorout,"Error at line %d: Multiple Declaration of %s\n\n",line_count,var_names[i].c_str());
							err_count++;
						}							
						else
						{	
							SymbolInfo *gg=st.Lookup(var_names[i]);
							string type=$1->getName();
							gg->setVarType(type);
							
							string varName=utility.newVariable();
							gg->setAsmName(varName);
							//varNames.push_back(varName);							
							if(arrayFlag[i])
								gg->arrayOn();
							//st.Insert(temp);					
							//SymbolInfo *qq=st.Lookup(var_names[i]);
							if(gg->isArray())
								arrNames.push_back(gg->getAsmName());
							else
								varNames.push_back(gg->getAsmName());
						}
					}						
				}				
				//fprintf(logout,"At line no :%d  var_declaration : type_specifier declaration_list SEMICOLON \n",line_count);
				//fprintf(logout,"\n%s %s ;\n",$1->getName().c_str(),$2->getName().c_str());
				string name=$1->getName()+" "+$2->getName()+";\n";
				string type=$1->getType()+"@"+$2->getType()+"@SEMICOLON";
				$$=new SymbolInfo(name,type);
				

			}
 		 ;
 		 
type_specifier	: INT
			{
				//fprintf(logout,"At line no :%d type_specifier : INT\n",line_count);
				//fprintf(logout,"\nint\n\n");
				$$=new SymbolInfo("int","INT");
				//printf("%s",$$->getType().c_str());			
			}
 		| FLOAT
			{
				//fprintf(logout,"At line no :%d type_specifier : FLOAT\n",line_count);
				//fprintf(logout,"\nfloat\n");
				$$=new SymbolInfo("float","FLOAT");			
			}
 		| VOID
			{
				//fprintf(logout,"At line no :%d type_specifier : VOID\n",line_count);
				//fprintf(logout,"\nvoid\n");
				$$=new SymbolInfo("void","VOID");			
			}		
		;
 		
declaration_list : declaration_list COMMA ID
			{
				//fprintf(logout,"At line no :%d declaration_list : declaration_list COMMA ID\n",line_count);
				//fprintf(logout,"\n%s, %s\n\n",$1->getName().c_str(),$3->getName().c_str());			
				$$=new SymbolInfo($1->getName()+", "+$3->getName(),$1->getType()+"@"+"COMMA"+"@"+$3->getType());
				//printf("%s %s\n",$$->getName().c_str(),$$->getType().c_str());
				//$$->getName($1->getName()+","+$3->getName());
				//$$->getType($1->getType()+" Comma "+$3->getType());	
			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
			{
				//fprintf(logout,"At line no :%d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n",line_count);
				//fprintf(logout,"\n%s, %s[%s]\n\n",$1->getName().c_str(),$3->getName().c_str(),$5->getName().c_str());
				string name=$1->getName()+", "+$3->getName()+"["+$5->getName()+"]";
				string type=$1->getType()+"@"+"COMMA"+"@"+$3->getType()+"LTHIRD"+"@"+$5->getType()+"@"+"RTHIRD";
				$$=new SymbolInfo(name,type);			
			}
 		  | ID	
			{
				//fprintf(logout,"At line no :%d declaration_list : ID\n",line_count);
				//fprintf(logout,"\n%s\n\n",$1->getName().c_str());			
				//fprintf(logout,"\n")				
				//printf("%s\n",$1->getType().c_str());				
				$$=$1;			
			}
 		  | ID LTHIRD CONST_INT RTHIRD
			{
				//fprintf(logout,"At line no :%d declaration_list : ID LTHIRD CONST_INT RTHIRD\n",line_count);
				//fprintf(logout,"\n%s[%s]\n",$1->getName().c_str(),$3->getName().c_str());
				$$=new SymbolInfo($1->getName()+"["+$3->getName()+"]",$1->getType()+"@"+"LTHIRD"+"@"+$3->getType()+"@"+"RTHIRD");			
			}
 		  ;
 		  
statements : statement
			{
				//fprintf(logout,"At line no :%d statements : statement\n",line_count);
				//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				$$=$1;
			}
	   | statements statement
			{
				//fprintf(logout,"At line no :%d statements : statements statement\n",line_count);
				//fprintf(logout,"\n%s %s\n\n",$1->getName().c_str(),$2->getName().c_str());
				string name=$1->getName()+" "+$2->getName();
				string type=$1->getType()+"@"+$2->getType();
				$$=new SymbolInfo(name,type);
				string asmCode1=$1->getAsmCode();
				string asmCode2=$2->getAsmCode();
				string asmCode=asmCode1+asmCode2;
				$$->setAsmCode(asmCode);
			}
	   ;
	   
statement : var_declaration
		{
			//fprintf(logout,"At line no :%d statement : var_declaration\n",line_count);
			//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
		}
	  | expression_statement
		{
			//fprintf(logout,"At line no :%d statement : expression_statement\n",line_count);
			//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
		}
	  | {
		st.Enter_Scope(7);
		int idNum=st.getCurrentId();
		//fprintf(logout,"New ScopeTable with id %d created \n\n",idNum);
		
		}
		compound_statement
		{
			//fprintf(logout,"At line no :%d statement : compound_statement\n",line_count);
			//fprintf(logout,"\n%s\n\n",$2->getName().c_str());
			$$=$2;
			//st.PrintAll(logout);
			int idNum=st.getCurrentId();			
			st.Exit_Scope();
			//fprintf(logout,"Scope with id %d removed \n\n",idNum);
			
		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  	{
			//fprintf(logout,"At line no :%d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",line_count);
			
			string exp1=$3->getName();
			string exp2=$4->getName();
			
			string true1,true2;
			for(int i=0;i<exp1.size();i++)
			{
				if(exp1[i]=='\n')
					continue;
				true1+=exp1[i];
			}

			for(int i=0;i<exp2.size();i++)
			{
				if(exp2[i]=='\n')
					continue;
				true2+=exp2[i];
			}

			
			string expT1=$3->getVarType();
			string expT2=$4->getVarType();
			string expT3=$5->getVarType();
			if(expT1=="void"||expT2=="void"||expT3=="void")
			{
				fprintf(errorout,"Error at line %d: Expression of condition cannot be of type 'void'\n\n",line_count);	
				err_count++;
			}

			//fprintf(logout,"\nfor(%s %s %s)\n%s\n\n",true1.c_str(),true2.c_str(),$5->getName().c_str(),$7->getName().c_str());
			string name="for("+true1+" "+true2+" "+$5->getName()+")\n"+$7->getName();			
			string type="FOR@LPAREN@"+$3->getType()+"@"+$4->getType()+"@"+$5->getType()+"@RPAREN@"+$7->getType();			
			$$=new SymbolInfo(name,type);

			//assembly code start

			string asmCode1=$3->getAsmCode();
			string asmCode2=$4->getAsmCode();
			string asmCode3=$5->getAsmCode();
			string asmCode4=$7->getAsmCode();
			string label1=utility.newLabel();
			string label2=utility.newLabel();
			string asmVar=$4->getAsmName();
			string asmCode=asmCode1+label1+":\n"+asmCode2+"CMP "+asmVar+",0\nJE "+label2+"\n"+asmCode4+asmCode3+"JMP "+label1+"\n"+label2+":\n";
			$$->setAsmCode(asmCode);
			
			
			//assembly code end
			
			

		}
	  | IF LPAREN expression RPAREN statement	%prec THEN
		{
			//fprintf(logout,"At line no :%d statement : IF LPAREN expression RPAREN statement\n",line_count);
			//fprintf(logout,"\nif(%s)\n%s\n\n",$3->getName().c_str(),$5->getName().c_str());
			
			string expT=$3->getVarType();

			if(expT=="void")
			{
				fprintf(errorout,"Error at line %d: Expression of condition cannot be of type 'void'\n\n",line_count);	
				err_count++;
			}
			

			string name="if("+$3->getName()+")\n"+$5->getName();			
			string type="IF@LPAREN@"+$3->getType()+"@RPAREN@"+$5->getType();			
			$$=new SymbolInfo(name,type);
			//assembly code start
			string label1=utility.newLabel();
			string asmCode1=$3->getAsmCode();
			//cout<<asmCode1<<endl;
			string expVar=$3->getAsmName();
			string asmCode2="CMP "+expVar+",0\n";
			string asmCode3="JE "+label1+"\n";
			string asmCode4=$5->getAsmCode();
			string asmCode=asmCode1+asmCode2+asmCode3+asmCode4+label1+":\n";
			$$->setAsmCode(asmCode);
			//cout<<"\n"<<asmCode<<endl;			
						
			//assembly code end
		}
	  | IF LPAREN expression RPAREN statement ELSE statement 	%prec ELSE
	  	{
			//fprintf(logout,"At line no :%d statement : IF LPAREN expression RPAREN statement ELSE statement\n",line_count);
			//fprintf(logout,"\nif(%s)\n%s\nelse\n%s\n\n",$3->getName().c_str(),$5->getName().c_str(),$7->getName().c_str());

			string expT=$3->getVarType();

			if(expT=="void")
			{
				fprintf(errorout,"Error at line %d: Expression of condition cannot be of type 'void'\n\n",line_count);	
				err_count++;
			}


			string name="if("+$3->getName()+")\n"+$5->getName()+"\nelse\n"+$7->getName();			
			string type="IF@LPAREN@"+$3->getType()+"@RPAREN@"+$5->getType()+"@ELSE"+$7->getType();			
			$$=new SymbolInfo(name,type);
			//assembly code start

			string label1=utility.newLabel();
			string label2=utility.newLabel();
			string asmCode1=$3->getAsmCode();
			//cout<<asmCode1<<endl;
			string expVar=$3->getAsmName();
			string asmCode2="CMP "+expVar+",0\n";
			string asmCode3="JE "+label1+"\n";
			string asmCode4=$5->getAsmCode();
			string asmCode5=$7->getAsmCode();
			string asmCode=asmCode1+asmCode2+asmCode3+asmCode4+"JMP "+label2+"\n"+label1+":\n"+asmCode5+label2+":\n";
			$$->setAsmCode(asmCode);
			//cout<<"\n"<<asmCode<<endl;			
			


		}
	  | WHILE LPAREN expression RPAREN statement
		{
			//fprintf(logout,"At line no :%d statement : WHILE LPAREN expression RPAREN statement\n",line_count);
			//fprintf(logout,"\nwhile(%s)\n%s\n\n",$3->getName().c_str(),$5->getName().c_str());
			
			string expT=$3->getVarType();

			if(expT=="void")
			{
				fprintf(errorout,"Error at line %d: Expression of condition cannot be of type 'void'\n\n",line_count);	
				err_count++;
			}


			string name="while("+$3->getName()+")\n"+$5->getName();			
			string type="WHILE@LPAREN@"+$3->getType()+"@RPAREN@"+$5->getType();			
			$$=new SymbolInfo(name,type);

			//assembly code start
			string label1=utility.newLabel();
			string label2=utility.newLabel();
			string asmCode1=$3->getAsmCode();			
			string asmVar=$3->getAsmName();
						

			string asmCode2=$5->getAsmCode();
			string asmCode=label1+":\n"+asmCode1+"CMP "+asmVar+",0\nJE "+label2+"\n"+asmCode2+"JMP "+label1+"\n"+label2+":\n";
			
			$$->setAsmCode(asmCode);

		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
			//fprintf(logout,"At line no :%d statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n",line_count);
			//fprintf(logout,"\nprintln(%s);\n\n",$3->getName().c_str());
			string name="println("+$3->getName()+");\n";			
			string type="PRINTLN@LPAREN@"+$3->getType()+"@RPAREN@SEMICOLON";			
			$$=new SymbolInfo(name,type);
			
			//assembly code start
			SymbolInfo *s=st.Lookup($3->getName());
			string asmName=s->getAsmName();
			string asmCode="MOV AX, "+asmName+"\n";
			asmCode+="CALL print_num\n";
			$$->setAsmCode(asmCode);
			//assembly code end
			

		}
	  | RETURN expression SEMICOLON
		{
			//fprintf(logout,"At line no :%d statement : RETURN expression SEMICOLON\n",line_count);
			//fprintf(logout,"\nreturn %s;\n\n",$2->getName().c_str());
			string name="return "+$2->getName()+";\n";			
			string type="RETURN@"+$2->getType()+"@SEMICOLON";			
			
			returnCheck=true;
			string returnString=$2->getVarType();
			returnType.push_back(returnString);
			returnLine.push_back(line_count);
			$$=new SymbolInfo(name,type);
			
			//assembly code start
			string asmVar=$2->getAsmName();
			string asmCode1=$2->getAsmCode();
			string line1="MOV AX, "+asmVar+"\n";
			string line2="MOV RETVAR, AX\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET\n";	//will probably need to change this part if I want to handle recursion. Keep that in mind		
			string asmCode="#"+asmCode1+line1+line2;
			$$->setAsmCode(asmCode);
			//cout<<asmCode<<endl;			
			//assembly code end
		}
	  ;
	  
expression_statement 	: SEMICOLON
				{	
			//		fprintf(logout,"At line no :%d expression_statement : SEMICOLON\n",line_count);
			//		fprintf(logout,"\n;\n\n");
					$$=new SymbolInfo(";\n","SEMICOLON");
					$$->setVarType("int");
				}			
			| expression SEMICOLON
				{
			//		fprintf(logout,"At line no :%d expression_statement : expression SEMICOLON\n",line_count);
			//		fprintf(logout,"\n%s ;\n\n",$1->getName().c_str());
					string name=$1->getName()+" ;\n";
					string type=$1->getType()+"@SEMICOLON";
					$$=new SymbolInfo(name,type);				
					string varType=$1->getVarType();
					$$->setVarType(varType);

					//assembly
					$$->setAsmCode($1->getAsmCode());
					$$->setAsmName($1->getAsmName());				
				}
			;
	  
variable : ID
		{
			//fprintf(logout,"At line no :%d variable : ID\n",line_count);
			//fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			SymbolInfo *s=st.Lookup($1->getName());			
			if(s==NULL)
			{
				
				fprintf(errorout,"Error at line %d: Undeclared variable : %s\n\n",line_count,$1->getName().c_str());
				err_count++;
			}			
			$$=$1;
			$$->setVarName($1->getName());			
						
			if(s==NULL)
				$$->setVarType("$");// $ means variable is undeclared
			else
			{
				string varType;
				if(s->isArray())
					$$->arrayOn();
				if(s->isFunc())
					$$->funcOn();
				
				if($$->isArray())
				{
					fprintf(errorout,"Error at line %d: Array subscript not used with %s\n\n",line_count,$1->getName().c_str());	
					err_count++;				
				}
				if($$->isFunc())			
				{
					fprintf(errorout,"Error at line %d: Function cannot be used as a variable\n\n",line_count);	
					err_count++;
					varType=s->getFuncReturnType();				
				}
				else
					varType=s->getVarType();
				$$->setVarType(varType);

				}		
			//assembly code						
				//cout<<s->getAsmName()<<endl;
				$$->setAsmName(s->getAsmName());
			//$$->setAsmName(s->getAsmName());			
			//cout<<$$->getAsmName()<<endl;
			
		} 		
	 | ID LTHIRD expression RTHIRD
		{
			//fprintf(logout,"At line no :%d variable : ID LTHIRD expression RTHIRD\n",line_count);
			//fprintf(logout,"\n%s[%s]\n\n",$1->getName().c_str(),$3->getName().c_str());
			
			SymbolInfo *s=st.Lookup($1->getName());
			if(s==NULL)
			{
				fprintf(errorout,"Error at line %d: Undeclared variable %s\n\n",line_count,$1->getName().c_str());
				err_count++;
			}						
			
			//check expression value later

			string name=$1->getName()+"["+$3->getName()+"]";
			string type=$1->getType()+"@"+"LTHIRD"+"@"+$3->getType()+"@"+"RTHIRD";
			$$=new SymbolInfo(name,type);
			$$->setVarName($1->getName());			
			
			if(s==NULL)
				$$->setVarType("$");// $ means variable is undeclared
			else
			{
				$$->setVarType(s->getVarType());
				if(s->isArray())
					$$->arrayOn();
				if(s->isFunc())
					$$->funcOn();
				
				if($$->isArray()==false)
				{
					fprintf(errorout,"Error at line %d: Invalid array subscript used with %s\n\n",line_count,$1->getName().c_str());	
					err_count++;				
				}
				else
				{
					string expType=$3->getVarType();
					if(expType=="void"||expType=="$"||expType=="float")
					{
						fprintf(errorout,"Error at line %d: Non-integer array index\n\n",line_count);	
						err_count++;
					}
				}			
			}		
			
			//assembly code start
			string asmCode1=$3->getAsmCode();
			string asmCode2="MOV BX, AX\n";
			string asmVar=s->getAsmName();
			string newAsmName=asmVar+"[BX]";
			string asmCode=asmCode1+asmCode2;			
			$$->setAsmName(newAsmName);
			$$->setAsmCode(asmCode);
			//assembly code end
			

		}
	 ;
	 
 expression : logic_expression
		{
		//	fprintf(logout,"At line no :%d expression : logic_expression\n",line_count);
		//	fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
			//cout<<$$->getAsmName()<<endl;
		}	
	   | variable ASSIGNOP logic_expression
		{
		//	fprintf(logout,"At line no :%d expression : variable ASSIGNOP logic_expression\n",line_count);
		//	fprintf(logout,"\n%s = %s\n\n",$1->getName().c_str(),$3->getName().c_str());
			
			string idName=$1->getVarName(),idType=$1->getVarType();//gets the variable names and variable type($ type means undefined variable)
			string expType=$3->getVarType();
			
			if(idType=="$")
			{
				fprintf(errorout,"Error at line %d: Undeclared variable cannot be used in assignment\n\n",line_count);
				err_count++;
			}			
			if(expType=="$")
			{
				fprintf(errorout,"Error at line %d: Undeclared expression cannot be used in assignment\n\n",line_count);
				err_count++;
			}			
			else if(expType=="void")
			{
				fprintf(errorout,"Error at line %d: Expressions of type 'void' cannot be used in assignment\n\n",line_count);
				err_count++;
			}
			if((idType=="int"||idType=="float")&&(expType=="int"||expType=="float"))
			{
				if(expType!=idType)
				{
					fprintf(errorout,"Error at line %d: Type mismatch\n\n",line_count);
					err_count++;	
				}
			}


			string name=$1->getName()+" = "+$3->getName();
			string type=$1->getType()+"@ASSIGNOP@"+$3->getType();
			$$=new SymbolInfo(name,type);
			$$->setVarType(idType);
			//assembly code start
			string asmVar=$1->getAsmName();
			string asmCode1=$1->getAsmCode();			
			string asmCode2=$3->getAsmCode();
			string asmCode=asmCode1+asmCode2+"MOV "+asmVar+", AX\n";
			$$->setAsmCode(asmCode);
			$$->setAsmName(asmVar);
			//assembly code end
			//cout<<asmCode<<endl;	
		} 	
	   ;
			
logic_expression : rel_expression
			{
		//		fprintf(logout,"At line no :%d logic_expression : rel_expression\n",line_count);
		//		fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				$$=$1;
			} 	
		 | rel_expression LOGICOP rel_expression 
			{
		//		fprintf(logout,"At line no :%d logic_expression : rel_expression LOGICOP rel_expression\n",line_count);
		//		fprintf(logout,"\n%s %s %s\n\n",$1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
				string name=$1->getName()+" "+$2->getName()+" "+$3->getName();
				string type=$1->getType()+"@"+$2->getType()+"@"+$3->getType();
				$$=new SymbolInfo(name,type);
				
				if($1->getVarType()=="void"||$3->getVarType()=="void")
				{
					fprintf(errorout,"Error at line %d: Expression of type 'void' used in operation\n\n",line_count);
					err_count++;				
				}
				else if($1->getVarType()=="$"||$3->getVarType()=="$")
				{
					fprintf(errorout,"Error at line %d: Undefined expression present in operation\n\n",line_count);
					err_count++;				
				}
				string varType="int";
				$$->setVarType(varType);

				//assembly code start
				string asmCode1=$1->getAsmCode();
				string asmCode2=$3->getAsmCode();
				
				string tempVar=utility.newVariable();
				varNames.push_back(tempVar);				
				
				string asmCode=asmCode1+"MOV "+tempVar+", AX\n"+asmCode2;
				string operation=$2->getName();
				string label1=utility.newLabel();
				string label2=utility.newLabel();
				if(operation=="||")
				{
					string asmCode3="CMP AX, 0\n";
					asmCode3=asmCode3+"JNE "+label1+"\n";
					asmCode3=asmCode3+"CMP "+tempVar+", 0\n";
					asmCode3=asmCode3+"JNE "+label1+"\n";
					asmCode3=asmCode3+"MOV AX, 0\nJMP "+label2+"\n"+label1+":\nMOV AX, 1\n"+label2+":\n";
					asmCode=asmCode+asmCode3;
					
				}
				else if(operation=="&&")
				{
					string asmCode3="CMP AX, 0\n";
					asmCode3=asmCode3+"JE "+label1+"\n";
					asmCode3=asmCode3+"CMP "+tempVar+", 0\n";
					asmCode3=asmCode3+"JE "+label1+"\n";
					asmCode3=asmCode3+"MOV AX, 1\nJMP "+label2+"\n"+label1+":\nMOV AX, 0\n"+label2+":\n";
					asmCode=asmCode+asmCode3;
				}
				//fprintf(assembly,"%s\n",asmCode.c_str());
				$$->setAsmCode(asmCode);
				$$->setAsmName("AX");
				//assembly code end
			} 
		;
			
rel_expression	: simple_expression
			{
		//		fprintf(logout,"At line no :%d rel_expression : simple_expression\n",line_count);
		//		fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				$$=$1;
			} 
		| simple_expression RELOP simple_expression
			{
		//		fprintf(logout,"At line no :%d rel_expression : simple_expression RELOP simple_expression\n",line_count);
		//		fprintf(logout,"\n%s %s %s\n\n",$1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
				string name=$1->getName()+" "+$2->getName()+" "+$3->getName();
				string type=$1->getType()+"@"+$2->getType()+"@"+$3->getType();
				$$=$1;
				if($1->getVarType()=="void"||$3->getVarType()=="void")
				{
					fprintf(errorout,"Error at line %d: Expression of type 'void' used in operation\n\n",line_count);
					err_count++;				
				}
				else if($1->getVarType()=="$"||$3->getVarType()=="$")
				{
					fprintf(errorout,"Error at line %d: Undefined expression present in operation\n\n",line_count);
					err_count++;				
				}
				string varType="int";
				$$->setVarType(varType);
				
				//assembly code start
				string prevCode1=$1->getAsmCode();
				string prevCode2=$3->getAsmCode();
				
				string tempVar=utility.newVariable();
				varNames.push_back(tempVar);
				string asmCode1="MOV "+tempVar+", AX\n";
				string asmCode=prevCode2+asmCode1+prevCode1;
				string cmp="CMP AX, "+tempVar+"\n";
				asmCode+=cmp;
				string operation=$2->getName();
				string label1=utility.newLabel();
				string label2=utility.newLabel();
								
				if(operation== "==")
				{
					asmCode=asmCode+"JE "+label1+"\nMOV AX, 0\nJMP "+label2+"\n";
					asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":\n";
				}
				else if(operation=="<=")
				{
					asmCode=asmCode+"JLE "+label1+"\nMOV AX, 0\nJMP "+label2+"\n";
					asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":\n";
				}
				else if(operation=="<")
				{
					asmCode=asmCode+"JL "+label1+"\nMOV AX, 0\nJMP "+label2+"\n";
					asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":\n";
				}
				else if(operation==">")
				{
					asmCode=asmCode+"JG "+label1+"\nMOV AX, 0\nJMP "+label2+"\n";
					asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":\n";
				}
				else if(operation==">=")
				{
					asmCode=asmCode+"JGE "+label1+"\nMOV AX, 0\nJMP "+label2+"\n";
					asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":\n";
				}
				else if(operation=="!")
				{
					asmCode=asmCode+"JNE "+label1+"\nMOV AX, 0\nJMP "+label2+"\n";
					asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":\n";
				}
				//cout<<asmCode<<endl;				
				$$->setAsmCode(asmCode);
				$$->setAsmName("AX");
				//assembly code end
				
			}	
		;
				
simple_expression : term
			{
		//		fprintf(logout,"At line no :%d simple_expression : term\n",line_count);
		//		fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				$$=$1;
			}		
		  | simple_expression ADDOP term
			{
		//		fprintf(logout,"At line no :%d simple_expression : simple_expression ADDOP term\n",line_count);
		//		fprintf(logout,"\n%s %s %s\n\n",$1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
				string name=$1->getName()+" "+$2->getName()+" "+$3->getName();
				string type=$1->getType()+"@"+$2->getType()+"@"+$3->getType();
				
				
				string varType;
				//cout<<$1->getVarType()<<endl;
				//cout<<$3->getVarType()<<endl;				

				
				if($1->getVarType()=="void"||$3->getVarType()=="void")
				{
					fprintf(errorout,"Error at line %d: Void type invalid with binary operation\n\n",line_count);
					err_count++;
					
					if($1->getVarType()=="float"||$3->getVarType()=="float")
						varType="float";
					else
						varType="int";
				}				
				else if($1->getVarType()=="$"||$3->getVarType()=="$")
				{
					fprintf(errorout,"Error at line %d: Undefined term invalid with binary operation\n\n",line_count);
					err_count++;
					
					if($1->getVarType()=="float"||$3->getVarType()=="float")
						varType="float";
					else
						varType="int";
				}
				else if($1->getVarType()=="float"||$3->getVarType()=="float")
					varType="float";
				else
					varType="int";
				
				//assembly code start
				string operation=$2->getName();				
				string prevCode1=$3->getAsmCode();
				string prevCode2=$1->getAsmCode();
				string tempVar=utility.newVariable();
				
				varNames.push_back(tempVar);				

				string asmCode1="MOV "+tempVar+", AX\n";
				string asmCode=prevCode1+asmCode1+prevCode2;
				if(operation=="+")
					asmCode=asmCode+"ADD AX, "+tempVar+"\n";
				else
					asmCode=asmCode+"SUB AX, "+tempVar+"\n";


				$$=new SymbolInfo(name,type);
				$$->setVarType(varType);
				$$->setAsmCode(asmCode);
				$$->setAsmName("AX");
				//cout<<asmCode<<endl;
				//assembly code end			
			}
		  ;
					
term :	unary_expression
		{
		//	fprintf(logout,"At line no :%d term : unary_expression\n",line_count);
		//	fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
			string varType;
			if($1->isFunc())
				varType=$1->getFuncReturnType();
			else
				varType=$1->getVarType();
			$$->funcOff();
			$$->setFuncReturnType("");
			$$->setVarType(varType);	
	// the term will now be considered as a variable (since unary_expression can be either a function or variable)(If the varType is void, term is guarateed to be a function)
		}
     |  term MULOP unary_expression
		{
		//	fprintf(logout,"At line no :%d term : term MULOP unary_expression\n",line_count);
		//	fprintf(logout,"\n%s %s %s\n\n",$1->getName().c_str(),$2->getName().c_str(),$3->getName().c_str());
			string name=$1->getName()+" "+$2->getName()+" "+$3->getName();		
			string type=$1->getType()+"@"+$2->getType()+"@"+$3->getType();			
			$$=new SymbolInfo(name,type);

			string termType,mulSymbol,expType;
			termType=$1->getVarType();
			mulSymbol=$2->getName();
			string finalType;
			if($3->isFunc())
				expType=$3->getFuncReturnType();
			else
				expType=$3->getVarType();
			if(expType=="void"||termType=="void")
			{
				fprintf(errorout,"Error at line %d: Void type invalid with binary operation\n\n",line_count);
				err_count++;
				
				if(mulSymbol=="%")
					finalType="int";				
				else if((termType=="float"||expType=="float"))				
					finalType="float";
				else
					finalType="int";
			}
			else if(expType=="$"||termType=="$")
			{
				fprintf(errorout,"Error at line %d: Undeclared expression invalid with binary operation\n\n",line_count);
				err_count++;
				
				if(mulSymbol=="%")
					finalType="int";				
				else if((termType=="float"||expType=="float"))				
					finalType="float";
				else
					finalType="int";
			}
			else
			{
				if(mulSymbol=="%"&&(termType=="float"||expType=="float"))
				{
					fprintf(errorout,"Error at line %d: Integer operand on modulus operator\n\n",line_count);
					err_count++;
					finalType="int";				
				}
				else if(mulSymbol=="*"||mulSymbol=="/")
				{
					if(termType=="float"||expType=="float")
						finalType="float";
					else
						finalType="int";
				}
			
				//assembly code start
				string var=utility.newVariable();
				
				varNames.push_back(var);				
				
				string prevCode1=$3->getAsmCode();
				string asmCode1="MOV "+var+", AX\n";
				string prevCode2=$1->getAsmCode();
				string asmCode=prevCode1+asmCode1+prevCode2;
				if(mulSymbol=="*")
					asmCode=asmCode+"IMUL "+var+"\n";
				else
				{
					asmCode=asmCode+"CWD\nIDIV "+var+"\n";
					if(mulSymbol=="%")
						asmCode=asmCode+"MOV AX,DX\n";
				}			
				$$->setAsmCode(asmCode);
				$$->setAsmName("AX");
				//cout<<asmCode<<endl;

				//assembly code end
			

			}
			$$->setVarType(finalType);//assigns the type of overall term		
		}
     ;

unary_expression : ADDOP unary_expression
			{
		//		fprintf(logout,"At line no :%d unary_expression : ADDOP unary_expression\n",line_count);
		//		fprintf(logout,"\n%s %s\n\n",$1->getName().c_str(),$2->getName().c_str());
				$$=new SymbolInfo($1->getName()+" "+$2->getName(),$1->getType()+"@"+$2->getType());
				string varType;
				if($2->isFunc())
					varType=$2->getFuncReturnType();
				else
					varType=$2->getVarType();
				/*				
				if(varType=="void")
				{
					fprintf(errorout,"Error at line %d: Void type invalid with unary operation\n\n",line_count);
					err_count++;				
				}
				else if(varType=="$")//$ means undefined
				{	
					fprintf(errorout,"Error at line %d: Undefined expression cannot be used with unary operation\n\n",line_count);
					err_count++;
					//write later
				}
				*/				
				$$->setVarType(varType);
				
				//assembly code starts
				string operation=$1->getName();
				$$->setAsmName("AX");
				if(operation=="-")
				{
					string asmCode="NEG AX\n";
					string prevCode=$2->getAsmCode();
					asmCode=prevCode+asmCode;
					$$->setAsmCode(asmCode);
					//cout<<asmCode<<endl;
				}
				//assembly code end
			}  
		 | NOT unary_expression
			{
		//		fprintf(logout,"At line no :%d unary_expression : NOT unary_expression\n",line_count);
		//		fprintf(logout,"\n! %s\n\n",$2->getName().c_str());
				$$=new SymbolInfo("! "+$2->getName(),"NOT@"+$2->getType());
					
				string varType;
				if($2->isFunc())
					varType=$2->getFuncReturnType();
				else
					varType=$2->getVarType();
				
				if(varType=="void")
				{
					fprintf(errorout,"Error at line %d: Void type invalid with unary operation\n\n",line_count);
					err_count++;
				}
				else if(varType=="$")
				{
					fprintf(errorout,"Error at line %d: Undefined expression cannot be used with unary operation\n\n",line_count);
					err_count++;

				}

				// NOT unary_expression type will be converterd to int now (if unary_expression was a function before, it is not a function now)
				$$->setVarType("int");
				//assembly code start
				//string label1=utility.newLabel();
				//string label2=utility.newLabel();
				string asmCode="NOT AX\n";
				//asmCode=asmCode+"JE "+label1+"\nMOV AX, 0\n"+"JMP "+label2+"\n";
				//asmCode=asmCode+label1+":\nMOV AX, 1\n"+label2+":";
				string prevCode=$2->getAsmCode();
				asmCode=prevCode+asmCode;
				$$->setAsmName("AX");
				$$->setAsmCode(asmCode);
				//cout<<$$->getAsmCode()<<endl;
				//assembly code end

					
			}
		 | factor
			{
		//		fprintf(logout,"At line no :%d unary_expression : factor\n",line_count);
		//		fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				$$=$1;
			} 
		 ;
	
factor	: variable	
		{
		//	fprintf(logout,"At line no :%d	factor : variable\n",line_count);
		//	fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;

			//assembly code
			string prevCode=$1->getAsmCode();
			string asmName=$1->getAsmName();
			string asmCode="MOV AX, "+asmName+"\n";
			asmCode=prevCode+asmCode;
			$$->setAsmCode(asmCode);
			$$->setAsmName("AX");
			//assembly code end
			
		}
	| ID LPAREN argument_list RPAREN
		{
		//	fprintf(logout,"At line no :%d	factor : ID LPAREN argument_list RPAREN\n",line_count);
		//	fprintf(logout,"\n%s(%s)\n\n",$1->getName().c_str(),$3->getName().c_str());
			
			string name=$1->getName()+"("+$3->getName()+")";
			string type=$1->getType()+"@LPAREN@"+$3->getType()+"@RPAREN";
			$$=new SymbolInfo(name,type);
			$$->funcOn();// code will proceed as though factor is a function	
			SymbolInfo *s=st.Lookup($1->getName());
			
			if(s==NULL)
			{
				fprintf(errorout,"Error at line %d: Undeclared function: %s\n\n",line_count,$1->getName().c_str());
				err_count++;
				$$->setFuncReturnType("$"); //means that the function is undeclared			
							
			}
			else
			{	
				//cout<<"Haha"<<endl;
				if(s->isFunc()==false)
				{
					fprintf(errorout,"Error at line %d: %s cannot be used as a function\n\n",line_count,$1->getName().c_str());
					err_count++;				
						//cout<<"HahaHehe"<<endl;			
					$$->setFuncReturnType(s->getVarType());				
									
				}
				else
				{	
					string parameterType=$3->getType();
					vector<string>v1=s->getParameterType();					
					int trueSize=v1.size();
					if(parameterType=="empty"&&trueSize!=0)
					{
						fprintf(errorout,"Error at line %d: Inserted arguments do not match with the parameter list of function\n\n",line_count);
						err_count++;
					}
					else if(parameterType!="empty")
					{
						vector<string>v;
						utility.tokenize(parameterType,'@',v);
					
						//write code checking the errors in argument_list
						v1=s->getParameterType();
						
						int curSize=v.size();
						if(trueSize!=curSize)
						{
							fprintf(errorout,"Error at line %d: Inserted arguments do not match with the parameter list of function\n\n",line_count);
							err_count++;
						}
						else
						{

							for(int i=0;i<trueSize;i++)
							{
								if(v1[i]!=v[i])
								{
									fprintf(errorout,"Error at line %d: Inserted arguments do not match with the parameter list of function\n\n",line_count);
									err_count++;
									break;
								}
							}
													
						}
					}					

					
					
					
					$$->setFuncReturnType(s->getFuncReturnType());
					//cout<<$$->getFuncReturnType()<<endl;				
					
					//assembly code start
					vector<string>argListCode=$3->getArgumentCodeList();
					vector<string>asmParams=s->getAsmParameter();					
					
					//cout<<asmParams.size()<<endl;
					//cout<<argListCode.size()<<endl;					

					string asmCode1="",temp="",var;
					for(int i=0;i<argListCode.size();i++)
					{
						temp=argListCode[i];
						var=asmParams[i];
						asmCode1+=(temp+("MOV "+var+", AX\n"));
					}			
					asmCode1+=("CALL "+$1->getName()+"\n");
					string funcType=s->getFuncReturnType();
					string line="";					
					if(funcType!="void")
						line="MOV AX, RETVAR\n";
					string asmCode=asmCode1+line;
					$$->setAsmCode(asmCode);
					$$->setAsmName("AX");
					//assembly code end
				}								
	
			}
			

		}
		
	| LPAREN expression RPAREN
		{
		//	fprintf(logout,"At line no :%d factor : LPAREN expression RPAREN\n",line_count);
		//	fprintf(logout,"\n(%s)\n\n",$2->getName().c_str());
			string name="("+$2->getName()+")";
			string type="LPAREN@"+$2->getType()+"@RPAREN";
			string varType=$2->getVarType();			
			$$=new SymbolInfo(name,type);
			$$->setVarType(varType);

			//assembly code start
			string asmCode1=$2->getAsmCode();
			string asmVar=$2->getAsmName();
			string line="MOV AX, "+asmVar+"\n";
			string asmCode=asmCode1+line;
			$$->setAsmCode(asmCode);
			$$->setAsmName("AX");
			//assembly code end		
		}
	| CONST_INT
		{
		//	fprintf(logout,"At line no :%d factor : CONST_INT\n",line_count);
		//	fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
			$$->setVarType("int");
			
			//assembly code generation
			string getNum=$1->getName();
			string asmCode="MOV AX,"+getNum+"\n";
			$$->setAsmCode(asmCode);
			$$->setAsmName("AX");			
			//assembly code end		
		}		
	| CONST_FLOAT
		{
		//	fprintf(logout,"At line no :%d factor : CONST_FLOAT\n",line_count);
		//	fprintf(logout,"\n%s\n\n",$1->getName().c_str());
			$$=$1;
			$$->setVarType("float");
			
			//will perform later

		}	
	| variable INCOP
		{
		//	fprintf(logout,"At line no :%d factor : variable INCOP\n",line_count);
		//	fprintf(logout,"\n%s ++\n\n",$1->getName().c_str());		
			string name=$1->getName()+"++";
			string type=$1->getType()+"@INCOP";
			$$=new SymbolInfo(name,type);
			$$->setVarType($1->getVarType());
			if($1->isArray())
				$$->arrayOn();
			if($1->isFunc())
				$$->funcOn();
								
			//assembly code
				//this part assumes that the variable is a normal one and NOT an array. Will handle array later				
				string asmName=$1->getAsmName();
				string asmCode="INC "+asmName+"\n"+"MOV AX, "+asmName+"\n";
				string prevCode=$1->getAsmCode();
				string newCode=prevCode+asmCode;
				$$->setAsmCode(newCode);
				$$->setAsmName("AX");
			//assembly code end		
			} 
	| variable DECOP
		{
		//	fprintf(logout,"At line no :%d factor : variable DECOP\n",line_count);
		//	fprintf(logout,"\n%s --\n\n",$1->getName().c_str());
			string name=$1->getName()+"--";
			string type=$1->getType()+"@DECOP";
			$$=new SymbolInfo(name,type);
			$$->setVarType($1->getVarType());
			if($1->isArray())
				$$->arrayOn();
			if($1->isFunc())
				$$->funcOn();

			//assembly code
				//this part assumes that the variable is a normal one and NOT an array. Will handle array later				
				string asmName=$1->getAsmName();
				string asmCode="DEC "+asmName+"\n"+"MOV AX, "+asmName+"\n";
				string prevCode=$1->getAsmCode();
				string newCode=prevCode+asmCode;
				$$->setAsmCode(newCode);
				$$->setAsmName("AX");
			//assembly code end
		}
	;
	
argument_list : arguments
			{
		//		fprintf(logout,"At line no :%d argument_list : arguments\n",line_count);
		//		fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				$$=$1;	
			}
			  |
				{
					$$=new SymbolInfo("","empty");
				}			  
			;
	
arguments : arguments COMMA logic_expression
		{
		//	fprintf(logout,"At line no :%d arguments : arguments COMMA logic_expression\n",line_count);
		//	fprintf(logout,"\n%s, %s\n\n",$1->getName().c_str(),$3->getName().c_str());
			string name=$1->getName()+", "+$3->getName();
			string type=$1->getType()+"@"+$3->getVarType();
			$$=new SymbolInfo(name,type);
			$$->setType(type);
			string asmCode=$3->getAsmCode();
			vector<string>v=$1->getArgumentCodeList();
			for(int i=0;i<v.size();i++)
				$$->insertArgumentCode(v[i]);
			$$->insertArgumentCode(asmCode);
		}
	      | logic_expression
			{
		//		fprintf(logout,"At line no :%d arguments : logic_expression\n",line_count);
		//		fprintf(logout,"\n%s\n\n",$1->getName().c_str());
				string varType=$1->getVarType();				
				$$=$1;
				$$->setType(varType);
				string asmCode=$1->getAsmCode();
				$$->insertArgumentCode(asmCode);	
				//assembly code start			

			}
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	errorout= fopen(argv[2],"w");
	fclose(errorout);
	//logout= fopen(argv[3],"w");
	//fclose(logout);
	
	errorout= fopen(argv[2],"a");
	//logout= fopen(argv[3],"a");
	
	
	assembly=fopen("1505077_code.asm","w");

	yyin=fp;
	yyparse();
	

	fclose(errorout);
	//fclose(logout);
	fclose(assembly);
	utility.optimize("1505077_code.asm","1505077_optimized.asm");
	return 0;
}

