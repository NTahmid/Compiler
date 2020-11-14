#include<bits/stdc++.h>
using namespace std;

class Utility{
	
	private:
	int labelNum;
	int varNum;
	int funcNum;	
	public:
	
	Utility()
	{
		labelNum=1;
		varNum=1;
		funcNum=1;	
	}

	string newLabel()
	{
		string label="L";
		stringstream ss;
		ss<<labelNum;		
		label+=ss.str();
		labelNum++;		
		return label;	
	}	
	
	string newVariable()
	{
		string var="T";
		stringstream ss;
		ss<<varNum;
		var+=ss.str();
		varNum++;
		return var;
	}
	
	string newFunc()
	{
		string func="func";
		stringstream ss;
		ss<<funcNum;		
		func+=ss.str();
		funcNum++;		
		return func;
	}

	void tokenize(vector<string>&var_names,vector<bool>&arrayFlags,string &var_list)
	{
		string variables="";
		bool ignore_flag=false;
		bool isArray=false;
		for(int i=0;i<var_list.size();i++)
		{
			if(var_list[i]==',')
			{	
				//cout<<variables<<endl;
				var_names.push_back(variables);
				arrayFlags.push_back(isArray);				
				variables="";
				isArray=false;			
			}
			if(ignore_flag==false)
			{
				if(var_list[i]>='0'&&var_list[i]<='9'||var_list[i]>='A'&&var_list[i]<='Z'||var_list[i]>='a'&&var_list[i]<='z'||var_list[i]=='_')
					variables+=var_list[i];
				else if(var_list[i]=='[')
				{
					ignore_flag=true;
					isArray=true;	
				}					
										
			}					
			if(ignore_flag==true&&var_list[i]==']')
				ignore_flag=false;					
		}
		//cout<<variables<<endl;
		var_names.push_back(variables);		
		arrayFlags.push_back(isArray);
	}
	
	void tokenize(vector<string>&parameterList,vector<string>&parameterType,string &parameters)
	{
		string variables="",type="";
		bool type_flag=true,start=false;
		for(int i=0;i<parameters.size();i++)
		{	
			//cout<<"Haha"<<endl;
			if(parameters[i]==',')
			{	
				//cout<<variables<<endl;
				parameterList.push_back(variables);
				parameterType.push_back(type);
							
				type="";				
				variables="";
				type_flag=true;
				start=false;
			}
			if(type_flag)
			{
				if(parameters[i]>='a'&&parameters[i]<='z')
					start=true;
				if(start && parameters[i]>='a'&&parameters[i]<='z')
					type+=parameters[i];
				if(start&& !(parameters[i]>='a'&&parameters[i]<='z'))
				{
					start=false;
					type_flag=false;
				}						
			}					
			else
			{
				if(parameters[i]>='0'&&parameters[i]<='9'||parameters[i]>='A'&&parameters[i]<='Z'||parameters[i]>='a'&&parameters[i]<='z'||parameters[i]=='_')
					variables+=parameters[i];
			}					
		}
		//cout<<variables<<endl;
		parameterList.push_back(variables);
		parameterType.push_back(type);		

	}
	void tokenize(string s,char symbol,vector<string>&v)
	{

		string n="";
		for(int i=0;i<s.size();i++)
		{
			if(s[i]==symbol)
			{
				v.push_back(n);
				n="";
			}
			else
				n+=s[i];		
		}
		v.push_back(n);	
	}
	
	string getCodeWithoutReturnSegment(string code)
	{
		string segment="";
		
		for(int i=0;i<code.size();i++)
		{
			if(code[i]=='#')
				return segment;
			segment+=code[i];		
		}
		return segment;
	}

	string getReturnSegment(string code)
	{	
		string segment="";
		int i=0;		
		for(;i<code.size();i++)
		{
			if(code[i]=='#')
			{
				i++;
				break;
			}
		}
		for(;i<code.size();i++)
			segment+=code[i];
		return segment;	
	}
	void optimize(string prevFileName,string newFileName)
	{	
		ifstream readFile;
		ofstream writeFile;
		readFile.open(prevFileName.c_str());
		writeFile.open(newFileName.c_str());
		string currLine="",writeLine,prevLine="",prevAction="",currAction="" ,var1="",var2="",var3="",var4="";
		
		while(getline(readFile,currLine) )
		{
			if(prevLine=="")
			{
				prevLine=currLine;
				writeFile<<currLine;
				writeFile<<"\n";
				continue;			
			}
			
			for(int i=0;i<currLine.size()&&i<3;i++)
				currAction+=currLine[i];
			for(int i=0;i<prevLine.size()&&i<3;i++)
				prevAction+=prevLine[i];
			
			if(currAction!="MOV")
			{
				currAction="";
				prevAction="";
				writeFile<<currLine;					
				writeFile<<"\n";				
				prevLine=currLine;
			}				
			else
			{	
				int i;
				for(i=3;i<currLine.size();i++)
				{
					if(currLine[i]==',')
					{
						i++;
						break;
					}
					else if(currLine[i]!=' '&&currLine[i]!='\n')
						var1+=currLine[i];					
				}

				for(;i<currLine.size();i++)
				{
					
					if(currLine[i]!=' '&&currLine[i]!='\n')
						var2+=currLine[i];					
				}
				
				//cout<<var1<<" "<<var2<<endl;
				if(var1==var2)
				{	

					currAction=prevAction=var1=var2=var3=var4="";
					continue;
				}					
				if(prevAction!="MOV")
				{
					currAction=prevAction=var1=var2=var3=var4="";
					writeFile<<currLine;					
					writeFile<<"\n";					
					prevLine=currLine;
				}
				else
				{
					for(i=3;i<prevLine.size();i++)
					{
						if(prevLine[i]==',')
						{
							i++;
							break;
					}
						else if(prevLine[i]!=' '&&prevLine[i]!='\n')
							var3+=prevLine[i];					
					}

					for(;i<prevLine.size();i++)
					{
					
						if(prevLine[i]!=' '&&prevLine[i]!='\n')
							var4+=prevLine[i];					
					}				
					if(var2=="AX"||var2=="BX"||var2=="CX"||var2=="DX")				
					{
						if(var3==var2&&var1==var4)
						{
							currAction=prevAction=var1=var2=var3=var4="";
							continue;						
						}
						else
						{
							writeFile<<currLine;
							writeFile<<"\n";							
							prevLine=currLine;
							currAction=prevAction=var1=var2=var3=var4="";
							continue;
						}
						
					}
					else
					{
						writeFile<<currLine;
						writeFile<<"\n";						
						prevLine=currLine;
						currAction=prevAction=var1=var2=var3=var4="";
						continue;	
					}				
				}
				
									
				
			}	
			
					
		}
		readFile.close();
		writeFile.close();

	}
};



class SymbolInfo{
    private:
        string symbolName;
        string typeName;
	
	string varName;        
	string varType;//type of variable
	
	string funcName;//don't think this field is needed. Check later
	string funcReturnType;//return type of function
	vector<string>parameter;//list of parameter
	vector<string>parameterType;//list of parameters' types
	
	string asmCode;
	
	string asmName;
	
	vector<string>asmParameter;// assembly procedures do not have parameters. However, this list will contain names that will be used as parameters for that function
	
	vector<string>argumentCodeList;


	bool arrayFlag;
	bool funcFlag;

	SymbolInfo *next;

	string asmReturn;
    public:
        SymbolInfo(string name="",string type="")
        {
		asmCode="";
		asmName="";
            symbolName=name;
            typeName=type;
		varType="";
		funcReturnType="";
		arrayFlag=false;
		funcFlag=false;
		asmReturn="";
            next=NULL;
        }
	
	void arrayOn()
	{
		arrayFlag=true;
	}
	
	void arrayOff()
	{
		arrayFlag=false;
	}

	bool isArray()
	{
		return arrayFlag;
	}

	void funcOn()
	{
		funcFlag=true;
	}
	
	void funcOff()
	{
		funcFlag=false;
	}

	bool isFunc()
	{
		return funcFlag;
	}
	


	void setVarName(string s)
        {
            varName=s;
        }

        string getVarName()
        {
            return varName;
        }

	void setFuncName(string s)
        {
            funcName=s;
        }

        string getFuncName()
        {
            return funcName;
        }


        void setName(string s)
        {
            symbolName=s;
        }

        string getName()
        {
            return symbolName;
        }

        void setType(string s)
        {
            typeName=s;
        }

        string getType()
        {
            return typeName;
        }
        
	void setVarType(string s)
	{
		varType=s;
	}
	
	string getVarType()
	{
		return varType;
	}
	
	void setNext(SymbolInfo* temp)
        {
            next=temp;
        }
	void setFuncReturnType(string s)
	{
		funcReturnType=s;
	}
	string getFuncReturnType()
	{
		return funcReturnType;
	}
	void InsertParameter(string parameterName,string type)
	{
		parameter.push_back(parameterName);
		parameterType.push_back(type);
	}
	vector<string>getParameter()
	{
		return parameter;
	}
	vector<string>getParameterType()
	{
		return parameterType;
	}
	SymbolInfo* getNext()
        {
            return next;
        }
	
	void setAsmName(string s)
	{
		asmName=s;
	}
	
	string getAsmName()
	{
		return asmName;
	}
	
	void setAsmCode(string s)
	{
		asmCode=s;
	}
	
	string getAsmCode()
	{
		return asmCode;

	}
	void insertAsmParameter(string s)
	{
		asmParameter.push_back(s);
	}
	
	vector<string>getAsmParameter()
	{
		return asmParameter;
	}

	void setAsmReturn(string s)
	{
		asmReturn=s;
	}
	
	string getAsmReturn()
	{
		return asmReturn;
	}
	
	void insertArgumentCode(string s)
	{
		argumentCodeList.push_back(s);
	}
	
	vector<string>getArgumentCodeList()
	{
		return argumentCodeList;
	}

};


class ScopeTable{
    private:
        SymbolInfo **table;
        ScopeTable *parentScope;
        int scopeId;
        int bucketNumber;
   
    public:
        ScopeTable(int n=7)
        {
            table=new SymbolInfo*[n];
            for(int i=0;i<n;i++)
                table[i]=NULL;
            bucketNumber=n;
        }
        void setScopeId(int x)
        {
            scopeId=x;
        }
        int getScopeId()
        {
            return scopeId;
        }
        unsigned long Hash(string s)
        {

            unsigned long int h = 2166136261UL;
            int n=s.size();
            unsigned char c;
            for(int i=0;i<n;i++)
            {
                c=s[i];
                h=(h^c)*16777619;
            }
            return h%bucketNumber;

        }

        SymbolInfo* Lookup(string name,bool f=true)
        {
            int pos=Hash(name);
            if(table[pos]==NULL)
            {
                
                return NULL;
            }
            SymbolInfo* temp=table[pos];
            int counter=0;
            while(temp!=NULL)
            {
                if(temp->getName()==name)
                {
                    
                    return temp;
                }

                temp=temp->getNext();
                counter++;
            }
            
            return temp;
        }
        bool Insert(string name,string type)
        {
            if(Lookup(name,false)!=NULL)
            {
		//fprintf(logout,"\nSymbol already exists in current ScopeTable\n");                
		return false;
            }
            int pos=Hash(name);
            SymbolInfo* f=new SymbolInfo();
            f->setName(name);
            f->setType(type);
            int counter=0;
            if(table[pos]==NULL)
                table[pos]=f;
            else
            {
                SymbolInfo *temp=table[pos];
                while(temp->getNext()!=NULL)
                {
                    counter++;
                    temp=temp->getNext();
                }
                counter++;
                temp->setNext(f);
            }
            return true;
        }
	
	bool Insert(SymbolInfo &s)
	{	
		string name=s.getName();
		if(Lookup(name,false)!=NULL)
	            {
			//fprintf(logout,"\nSymbol already exists in current ScopeTable\n");                
			return false;
	            }
		int pos=Hash(name);
		string type=s.getType();
		string varType=s.getVarType();
		string funcType=s.getFuncReturnType();		
		
		string asmName=s.getAsmName();
		string asmCode=s.getAsmCode();

		vector<string>v1=s.getParameter();
		vector<string>v2=s.getParameterType();            	
		vector<string>v3=s.getAsmParameter();
		vector<string>v4=s.getArgumentCodeList();		

		SymbolInfo* f=new SymbolInfo();
		f->setName(name);
           	f->setType(type);
		f->setVarType(varType);
		f->setFuncReturnType(funcType);
		f->setAsmName(asmName);
		f->setAsmCode(asmCode);		
		f->setAsmReturn(s.getAsmReturn());		
		if(s.isArray()==true)
			f->arrayOn();
		if(s.isFunc()==true)
			f->funcOn();
		for(int i=0;i<v2.size();i++)
		{
			f->InsertParameter(v1[i],v2[i]);
			f->insertAsmParameter(v3[i]);
		}			
		
		
		//vector<string>v5=f->getAsmParameter();
		//cout<<v5.size()<<" Haha"<<f->getName()<<endl;

		for(int i=0;i<v4.size();i++)
			f->insertArgumentCode(v4[i]);

		int counter=0;
		         	

		if(table[pos]==NULL)
            	    table[pos]=f;
	    	else
	    	{
	     		SymbolInfo *temp=table[pos];
	       		while(temp->getNext()!=NULL)
	        	{
	         		counter++;
	            		temp=temp->getNext();
	        	}
	        	counter++;
	        	temp->setNext(f);
	    	}
	    	return true;
	}

        bool Delete(string name)
        {
            int pos=Hash(name);
            SymbolInfo *prev,*current;
            current=prev=table[pos];
            int counter=0;
            if(current==NULL)
            {
                //cout<<"Not Found"<<endl;
                return false;
            }
            if(current->getName()==name&&current==table[pos])
            {
                table[pos]=current->getNext();
                //cout<<"Found in ScopeTable # "<<scopeId<<" at position "<<pos<<", "<<counter<<endl;
                //cout<<"Deleted entry at "<<pos<<", "<<counter<<" from current ScopeTable"<<endl;
                delete current;
                return true;
            }
            current=current->getNext();
            counter++;
            while(current!=NULL)
            {
                if(current->getName()==name)
                {
                    prev->setNext(current->getNext());
                    delete current;
                 //   cout<<"Found in ScopeTable # "<<scopeId<<" at position "<<pos<<", "<<counter<<endl;
                  //  cout<<"Deleted entry at "<<pos<<", "<<counter<<" from current ScopeTable"<<endl;
                    return true;
                }
                prev=current;
                current=current->getNext();
                counter++;
            }
           // cout<<"Not Found"<<endl;
            return false;
        }
        void Print(FILE *f)
        {
            fprintf(f,"\nScopeTable # %d\n",scopeId);
	    
            for(int i=0;i<bucketNumber;i++)
            {
                SymbolInfo *temp=table[i];
                int counter=0;
		if(temp!=NULL)                
			fprintf(f,"\n%d --> ",i);
                while(temp!=NULL)
                {   
		    fprintf(f,"< %s , %s > ",temp->getName().c_str(),temp->getType().c_str() );
                    
                    temp=temp->getNext();
                }
		if(temp!=NULL)                
			fprintf(f,"\n");

            }
		fprintf(f,"\n");        
	}
        void setParentScope(ScopeTable *temp)
        {
            parentScope=temp;
        }
        ScopeTable* getParentScope()
        {
            return parentScope;
        }
	~ScopeTable()
	{
		for(int i=0;i<bucketNumber;i++)
			delete table[i];
		delete table;
	}

};

class SymbolTable
{
    private:
        ScopeTable *currentTable;
	int init_id;
    public:
        int getCurrentId()
	{
		return currentTable->getScopeId();
	}
	SymbolTable(int n)
        {	
		init_id=1;
            ScopeTable *temp=new ScopeTable(n);
            temp->setParentScope(NULL);
            temp->setScopeId(init_id);
            currentTable=temp;
        }
        void Enter_Scope(int n)
        {
            ScopeTable *temp=new ScopeTable(n);
            temp->setParentScope(currentTable);
		init_id++;            
		temp->setScopeId(init_id);
            currentTable=temp;
            
        }
        void Exit_Scope()
        {
            if(currentTable==NULL)
            {
                //cout<<"No Scope"<<endl;
                return;
            }

            ScopeTable *temp=currentTable->getParentScope();
            int prevId=currentTable->getScopeId();
            delete currentTable;
		init_id--;
            //cout<<"ScopeTable with id "<<prevId<<" removed"<<endl;
            currentTable=temp;
        }
        bool Insert(string name,string type)
        {
            if(currentTable==NULL)
            {
                //cout<<"No Scope"<<endl;
                return false;
            }
            return currentTable->Insert(name,type);
        }
        bool Insert(SymbolInfo &s)
	{
		if(currentTable==NULL)
            	{
                	//cout<<"No Scope"<<endl;
                	return false;
            	}
		return currentTable->Insert(s);
	}

	bool Remove(string name)
        {
            if(currentTable==NULL)
            {
        //        cout<<"No Scope"<<endl;
                return false;
            }
            return currentTable->Delete(name);
        }
        SymbolInfo* Lookup(string name)
        {
            if(currentTable==NULL)
            {
          //      cout<<"No Scope"<<endl;
                return NULL;
            }
            ScopeTable *temp=currentTable;
            SymbolInfo *result=NULL;
            while(temp!=NULL)
            {
                result=temp->Lookup(name);
                if(result!=NULL)
                    return result;
                temp=temp->getParentScope();
            }
		//if(result==NULL)
		//{
	//		printf("HahaHo\n");
		//}            
		//return result;
        }
        void PrintCurrent(FILE *f)
        {
            if(currentTable==NULL)
            {
            //    cout<<"No Scope"<<endl;
                return;
            }

            currentTable->Print(f);
        }
        void PrintAll(FILE *f)
        {
            if(currentTable==NULL)
            {
            //    cout<<"No Scope"<<endl;
                return;
            }
            ScopeTable* temp=currentTable;
            while(temp!=NULL)
            {
                temp->Print(f);
                temp=temp->getParentScope();
            }
        }
};
