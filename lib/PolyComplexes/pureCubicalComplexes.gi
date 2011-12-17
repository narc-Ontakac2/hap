#C 2009 Graham Ellis

#####################################################################
#####################################################################
InstallGlobalFunction(ArrayToPureCubicalComplex,
function(AA,threshold)

# Inputs an array of integers where 0 represents black 
# and 753 represents white. It returns a pure cubical complex
# where all integers below the threshold are converted to 1, and
# higher integers are converted to 0, in the binary list f the cubical
# complex. 

local
        int2binary,A;

##############################
int2binary:=function(A)
local i;
if ArrayDimension(A)=1 then 
for i in [1..Length(A)] do
if A[i] <threshold then A[i]:=1; else
A[i]:=0;fi;
od;return A;
fi;
return List(A,x->int2binary(StructuralCopy(x)));
end;
##############################

A:=int2binary(AA);

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=A,
           properties:=[
           ["dimension",ArrayDimension(A)],
           ["arraySize",ArrayDimensions(A)]]
           ));
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallGlobalFunction(PureCubicalComplex,
function(AA)
# Inputs a binary array and returns a pure cubical complex.
local
        A;

A:=StructuralCopy(AA);

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=A,
           properties:=[
           ["dimension",ArrayDimension(A)],
           ["arraySize",ArrayDimensions(A)]]
           ));
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallOtherMethod(Dimension,
"Dimension of pure cubical complex",
[IsHapPureCubicalComplex],
function(f) return EvaluateProperty(f,"dimension");
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallOtherMethod(Size,
"Volume of a pure cubical complex",
[IsHapPureCubicalComplex],
function(f) return Sum(Flat(f!.binaryArray));
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallOtherMethod(Dimension,
"Dimension of  cubical complex",
[IsHapCubicalComplex],
function(f) return EvaluateProperty(f,"dimension");
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallMethod(EulerCharacteristic,
"Euler characteristic  of a pure  cubical complex",
[IsHapPureCubicalComplex],
function(M) local  C,D;
C:=rec();
C.binaryArray:=StructuralCopy(M!.binaryArray);
C.properties:=StructuralCopy(M!.properties);
C:=Objectify(HapPureCubicalComplex,C);
ContractPureCubicalComplex(C);
D:=ChainComplexOfCubicalComplex(
PureCubicalComplexToCubicalComplex(C),true);
return
Sum(List([0..Dimension(C)],i->((-1)^i)*D!.dimension(i)));
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallOtherMethod(EulerCharacteristic,
"Euler characteristic  of a cubical complex",
[IsHapCubicalComplex],
function(M) local  C;
C:=ChainComplexOfCubicalComplex(M,true);
return
Sum(List([0..Dimension(M)],i->((-1)^i)*C!.dimension(i)));
end);
#####################################################################
#####################################################################


HAPAAA:=0;
#################################################################
#################################################################
InstallGlobalFunction(ReadImageAsPureCubicalComplex,
function(file,threshold)
# Inputs a string "file" that points either to a single image file, or 
# to a list of suitable image files, and returns either a 2-dimensional 
# or 3-dimensional cubical complex.
local f,i,x,prog,B,A,AA;

prog:=Concatenation(GAP_ROOT_PATHS[1],"pkg/Hap1.9/lib/PolyComplexes/prog");
#MUST FIX THIS

##################################
if IsString(file) then

i:=Concatenation("convert ",file," /tmp/im.txt");
Exec(i);
i:=Concatenation("perl ",prog," /tmp/im.txt >/tmp/im.g");
Exec(i);

Read("/tmp/im.g");
Exec("rm /tmp/im.g");
Exec("rm /tmp/im.txt");
B:=StructuralCopy(HAPAAA);
HAPAAA:=0;

A:=[];
for i in [1..B[1]] do
A[i]:=List([1..B[2]],a->0);
od;
for x in B{[3..Length(B)-1]} do
A[x[1]][x[2]]:=x[3];
od;
return ArrayToPureCubicalComplex(A,threshold);
fi;
#################################  

##################################
if IsList(file) then
AA:=[];
for f in file do
i:=Concatenation("convert ",f," /tmp/im.txt");
Exec(i);
i:=Concatenation("perl ",prog," /tmp/im.txt >/tmp/im.g");
Exec(i);

Read("/tmp/im.g");
Exec("rm /tmp/im.g");
Exec("rm /tmp/im.txt");
B:=StructuralCopy(HAPAAA);
A:=[];
for i in [1..B[1]] do
A[i]:=List([1..B[2]],a->0);
od;
for x in B{[3..Length(B)-1]} do
A[x[1]][x[2]]:=x[3];
od;
Add(AA,StructuralCopy(A));
HAPAAA:=0;
od;

return ArrayToPureCubicalComplex(AA,threshold);
fi;
#################################

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(ReadImageSequenceAsPureCubicalComplex,
function(directory,threshold)
local L,file,linecommand,instr,f;

file:="/tmp/imagesfile.txt";
L:=[];

linecommand:=Concatenation("ls ",directory," > ",file);
Exec(linecommand);

instr:=InputTextFile(file);

f:=ReadLine(instr);
while not f=fail do
Add(L,Concatenation(directory,"/",f{[1..Length(f)-1]}));
f:=ReadLine(instr);
od;

return 
ReadImageAsPureCubicalComplex(L,threshold);
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(PureCubicalComplexToCubicalComplex,
function(M)
# Converts a pure cubical complex to a cubical complex
local A,x,i,dim,dim1,dims,ball,b,dimsM,ArrayValueDim, ArrayValueDim1,
ArrayAssignDim,ArrayIt,dimsSet,Fun;
  
dim:=Dimension(M);
dim1:=dim-1;
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim-1);
ArrayAssignDim:=ArrayAssignFunctions(dim);
ArrayIt:=ArrayIterate(dim);
dimsM:=EvaluateProperty(M,"arraySize");
dims:=List(EvaluateProperty(M,"arraySize"),n->2*n+1);
A:=List([1..dims[1]],a->0);
for i in [2..Dimension(M)] do
A:=List([1..dims[i]],a->StructuralCopy(A));
od;

ball:=Cartesian(List([1..dim],i->[-1,0,1]));
dimsSet:=List([1..dim],x->[1..dimsM[x]]);

#########################
Fun:=function(i);
if ArrayValueDim(M!.binaryArray,i)=1 then
for b in ball do
x:=2*i+b;
ArrayAssignDim(A,x,1);
od;
fi;
end;
#########################
ArrayIt(dimsSet,Fun);

return Objectify(HapCubicalComplex,
           rec(
           binaryArray:=A,
           properties:=[
           ["dimension",dim],
           ["arraySize",dims]]
           ));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(ChainComplexOfCubicalComplex,
function(arg)
local M,faces,dims,dim,dim1,x,y,z,numevens,Dimsn,Boundary,BinLst,LstBin,
ArrayValueDim,ArrayValueDim1,ArrayAssignDim,ArrayIt,dimsSet,Fun;
# Inputs a cubical complex and returns the associated cellular 
# chain complex.

M:=arg[1];

faces:=List([0..Dimension(M)+10],i->0);
dims:=EvaluateProperty(M,"arraySize");
dimsSet:=List(dims,d->[1..d]);
dim:=Dimension(M);
dim1:=dim-1;
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim1);
ArrayAssignDim:=ArrayAssignFunctions(dim);
ArrayIt:=ArrayIterate(dim);


BinLst:=M!.binaryArray*0; #BinLst will be an array where the value 
                         #of an entry is the position of the cell 
                         #corresponding to that entry in the list 
                         #of all cells of similar dimension.
LstBin:=List([0..Dimension(M)],i->[]);	         
                         #LstBin is a list of lists. The i-th entry of the
                         #j-th list is the coordinates in M!.binaryArray
                         #of the i-th cell in dimension j-1.


##############################
numevens:=function(x);
return Length(Filtered(x,i->IsEvenInt(i)));
end;
##############################

if Length(arg)=1 then

#######################
Fun:=function(x) local y,z;
if ArrayValueDim(M!.binaryArray,x)=1 then
y:=numevens(x)+1;
faces[y]:=faces[y]+1;
ArrayAssignDim(BinLst,x,faces[y]);
LstBin[y][faces[y]]:=x;
fi;
end;
#######################
ArrayIt(dimsSet,Fun);

else

#######################
Fun:=function(x) local y;
if ArrayValueDim(M!.binaryArray,x)=1 then
y:=numevens(x)+1;
faces[y]:=faces[y]+1;
fi;
end;
#######################
ArrayIt(dimsSet,Fun);

fi;

#######################################
Dimsn:=function(n);
return faces[n+1];
end;
#######################################

#######################################
Boundary:=function(n,j)
local x,poscells,negcells,nn,a,b,cnt;
poscells:=[];
negcells:=[];

cnt:=0;
nn:=LstBin[n+1][j];
for x in [1..Length(nn)] do
if IsEvenInt(nn[x]) then
cnt:=cnt+1;
a:=StructuralCopy(nn);
a[x]:=a[x]+1;
b:=StructuralCopy(nn);
b[x]:=b[x]-1;
if IsOddInt(cnt) then
Add(poscells,a);
Add(negcells,b);
else
Add(poscells,b);
Add(negcells,a);
fi;
fi;
od;

Apply(poscells,x->ArrayValueDim(BinLst,x));
Apply(negcells,x->ArrayValueDim(BinLst,x));

nn:=List([1..faces[n]],i->0);
for x in poscells do
nn[x]:=-1;
od;
for x in negcells do
nn[x]:=1;
od;

return nn;
end;
#######################################

return
Objectify(HapChainComplex,
           rec(
           dimension:=Dimsn,
	   boundary:=Boundary,
	   coordinateToPosition:=BinLst,
	   positionToCoordinate:=LstBin,
           properties:=[
	   ["length",EvaluateProperty(M,"dimension")],
	   ["type","chainComplex"],
           ["characteristic",0]]
           ));

end);
#################################################################
#################################################################


#####################################################################
#####################################################################
InstallMethod(ChainComplex,
"Cellular chain complex of a cubical complex",
[IsHapCubicalComplex],
function(M) 
return ChainComplexOfCubicalComplex(M);;
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallMethod(ChainComplexOfPair,
"Cellular chain complex of a pair of cubical complexes",
[IsHapCubicalComplex,IsHapCubicalComplex],
function(M,S)
return ChainComplexOfCubicalPair(M,S);;
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallOtherMethod(ChainComplexOfPair,
"Cellular chain complex of a pair of pure cubical complexes",
[IsHapPureCubicalComplex,IsHapPureCubicalComplex],
function(M,S)
return ChainComplexOfCubicalPair(
PureCubicalComplexToCubicalComplex(M),
PureCubicalComplexToCubicalComplex(S));;
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallOtherMethod(ChainComplex,
"Cellular chain complex of a pure cubical complex",
[IsHapPureCubicalComplex],
function(M)
return ChainComplexOfCubicalComplex(PureCubicalComplexToCubicalComplex(M));;
end);
#####################################################################
#####################################################################


#####################################################################
#####################################################################
InstallGlobalFunction(ChainComplexOfCubicalPair,
function(M,S)
local faces,dim,dim1,dims,index,x,y,z,numevens,Dimsn,Boundary,BinLst,LstBin,
ArrayValueDim,ArrayValueDim1,Generator2Coordinates,Coordinates2Generator;
# Inputs a pair of cubical complexes and returns the  cellular
# chain complex of " M/S ".

faces:=List([0..Dimension(M)],i->0);
dims:=EvaluateProperty(M,"arraySize");
index:=Cartesian(List([1..Dimension(M)],x->[1..dims[x]]));
dim:=Dimension(M);
dim1:=dim-1;
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim1);

BinLst:=M!.binaryArray*0; #BinLst will be an array where the value
                         #of an entry is the position of the cell
                         #corresponding to that entry in the list
                         #of all cells of similar dimension.
LstBin:=List([0..Dimension(M)],i->[]);
                         #LstBin is a list of lists. The i-th entry of the
                         #j-th list is the coordinates in M!.binaryArray
                         #of the i-th cell in dimension j-1.


##############################
numevens:=function(x);
return Length(Filtered(x,i->IsEvenInt(i)));
end;
##############################

for x in index do
if 
	ArrayValueDim(M!.binaryArray,x)=1 
	and ArrayValueDim(S!.binaryArray,x)=0
then
y:=numevens(x)+1;
faces[y]:=faces[y]+1;
z:=ArrayValueDim1(BinLst,x{[2..Length(x)]});
z[x[1]]:=faces[y];
LstBin[y][faces[y]]:=x;
fi;
od;

#######################################
Dimsn:=function(n);
return faces[n+1];
end;
#######################################

#######################################
Boundary:=function(n,j)
local x,poscells,negcells,nn,a,b,cnt;
poscells:=[];
negcells:=[];

cnt:=0;
nn:=LstBin[n+1][j];
for x in [1..Length(nn)] do
if IsEvenInt(nn[x]) then
cnt:=cnt+1;
a:=StructuralCopy(nn);
a[x]:=a[x]+1;
b:=StructuralCopy(nn);
b[x]:=b[x]-1;
if IsOddInt(cnt) then
if ArrayValueDim(S!.binaryArray,a)=0 then
Add(poscells,a);
fi;
if ArrayValueDim(S!.binaryArray,b)=0 then
Add(negcells,b);
fi;
else
if ArrayValueDim(S!.binaryArray,b)=0 then
Add(poscells,b);
fi;
if ArrayValueDim(S!.binaryArray,a)=0 then
Add(negcells,a);
fi;
fi;
fi;
od;

Apply(poscells,x->ArrayValueDim(BinLst,x));
Apply(negcells,x->ArrayValueDim(BinLst,x));

nn:=List([1..faces[n]],i->0);
for x in poscells do
nn[x]:=-1;
od;
for x in negcells do
nn[x]:=1;
od;

return nn;
end;
#######################################

#######################################
Generator2Coordinates:=function(n,j);
return LstBin[n+1][j];
end;
#######################################

#######################################
Coordinates2Generator:=function(x);
return ArrayValueDim(BinLst,x);
end;
#######################################

return
Objectify(HapChainComplex,
           rec(
           dimension:=Dimsn,
           boundary:=Boundary,
	   generator2Coordinates:=Generator2Coordinates,
	   coordinates2Generator:=Coordinates2Generator, 
           properties:=[
           ["length",EvaluateProperty(M,"dimension")],
           ["type","chainComplex"],
           ["characteristic",0]]
           ));

end);
#####################################################################
#####################################################################

#####################################################################
#####################################################################
InstallGlobalFunction(ChainMapOfCubicalPairs,
function(arg)
			#X is a subspace of Y.
			#S is a contractible subspace of X (and T). 
			#T is a contractible subspace of Y.
			#We return C(X/S)-->C(Y/T).
local
	X,S,Y,T,C,D,map;

###########INPUT####################
if Length(arg)=4 then
X:=arg[1];
S:=arg[2];
Y:=arg[3];
T:=arg[4];
C:=ChainComplexOfPair(X,S);
D:=ChainComplexOfPair(Y,T);
fi;

if Length(arg)=2 then
C:=arg[1];
D:=arg[2];
fi;
####################################

###############################################
map:=function(v,n)
local x,w,i;

w:=List([1..D!.dimension(n)],a->0);

for i in [1..Length(v)] do
if not v[i]=0 then
x:=C!.generator2Coordinates(n,i);
x:=D!.coordinates2Generator(x);
if not x=0 then w[x]:=v[i]; fi;
fi;
od;

return w;
end;
###############################################

return Objectify(HapChainMap,
        rec(
           source:=C,
           target:=D,
           mapping:=map,
           properties:=[ ["type","chainMap"],
           ["characteristic", 0]
           ]));

end);
#####################################################################
##################################################################### 

######################################################################
######################################################################
InstallGlobalFunction(ContractPureCubicalComplex,
function(T);

if not IsHapPureCubicalComplex(T) then 
Print("This contraction can only be applied to pure cubical complexes.\n");
return fail;
fi;
 
if EvaluateProperty(T,"contracted")=true then return T; fi;

T!.binaryArray:=ContractArray(T!.binaryArray);
Add(T!.properties,["contracted",true]);
return T;

end);
######################################################################
######################################################################


#####################################################################
#####################################################################
InstallMethod(ContractedComplex,
"Contracted complex of a pure cubical complex",
[IsHapPureCubicalComplex],
function(M) local  C,A;

if not IsHapPureCubicalComplex(M) then
Print("This contraction can only be applied to pure cubical complexes.\n");
return fail;
fi;

A:=StructuralCopy(M!.binaryArray);;
C:=rec();
C.properties:=StructuralCopy(M!.properties);
C:=Objectify(HapPureCubicalComplex,C);

if not EvaluateProperty(M,"contracted")=true then 
A:=ContractArray(A);
Add(C!.properties,["contracted",true]);
fi;

C!.binaryArray:=A;
return C;
end);
#####################################################################
#####################################################################


######################################################################
######################################################################
InstallGlobalFunction(ContractibleSubcomplexOfPureCubicalComplex,
function(T)
local S,A,P,mx;

if not IsHapPureCubicalComplex(T) then
Print("This function can only be applied to pure cubical complexes.\n");
return fail;
fi;

P:=PathComponentOfPureCubicalComplex(T,0);
P:=List([1..P],x->PathComponentOfPureCubicalComplex(T,x));
S:=List(P,Size);
mx:=Position(S,Maximum(S));
A:=ContractibleSubArray(P[mx]!.binaryArray);

#A:=ContractibleSubArray(T!.binaryArray);

return Objectify(HapPureCubicalComplex,
	rec(
	binaryArray:=A,
	properties:=StructuralCopy(T!.properties)
	));

end);
######################################################################
######################################################################


######################################################################
######################################################################
InstallGlobalFunction(AlmostContractibleSubcomplexOfPureCubicalComplex,
function(T)
local A,P,mx,i;

if not IsHapPureCubicalComplex(T) then
Print("This function can only be applied to pure cubical complexes.\n");
return fail;
fi;

P:=PathComponentOfPureCubicalComplex(T,0);
P:=List([1..P],x->PathComponentOfPureCubicalComplex(T,x));
P:=List(P,p->ContractibleSubcomplexOfPureCubicalComplex(p));

A:=P[1];
for i in [2..Length(P)] do
A:=PureCubicalComplexUnion(A,P[i]);
od;

return A;

end);
######################################################################
######################################################################


######################################################################
######################################################################
InstallGlobalFunction(HomotopyEquivalentMaximalPureCubicalSubcomplex,
function(T,S)
local A;

if (not IsHapPureCubicalComplex(T))
and
(not IsHapPureCubicalComplex(S))
then
Print("This function can only be applied to pure cubical complexes.\n");
return fail;
fi;

A:=HomotopyEquivalentLargerSubArray(T!.binaryArray,S!.binaryArray);

return Objectify(HapPureCubicalComplex,
        rec(
        binaryArray:=A,
        properties:=StructuralCopy(T!.properties)
        ));

end);
######################################################################
######################################################################

######################################################################
######################################################################
InstallGlobalFunction(HomotopyEquivalentMinimalPureCubicalSubcomplex,
function(T,S)
local A;

if (not IsHapPureCubicalComplex(T))
and
(not IsHapPureCubicalComplex(S))
then
Print("This function can only be applied to pure cubical complexes.\n");
return fail;
fi;

A:=HomotopyEquivalentSmallerSubArray(T!.binaryArray,S!.binaryArray);

return Objectify(HapPureCubicalComplex,
        rec(
        binaryArray:=A,
        properties:=StructuralCopy(T!.properties)
        ));

end);
######################################################################
######################################################################


#################################################################
#################################################################
InstallGlobalFunction(WritePureCubicalComplexAsImage,
function(T,file,ext)
local
        A,i,j,rows,cols,colour,filetxt;
# This writes a 2-dimensional cubical complex to an image file.

if not Dimension(T)=2 then
Print("There is no method for viewing a topological manifold of dimension ",
Dimension(T),".\n"); return fail; fi;

A:=T!.binaryArray;
rows:=Length(A);;
cols:=Length(A[1]);

filetxt:=Concatenation(file,".txt");

PrintTo(filetxt,"# ImageMagick pixel enumeration: ",
Length(A),",",Length(A[1]),",255,RGB\n");

for i in [1..rows] do
for j in [1..cols] do
if A[i][j]=0 then colour:="(255,255,255)"; else colour:="(0,0,100)";fi;
AppendTo(filetxt,i,",",j,": ",colour,"\n");
od;
od;

i:=Concatenation("convert ",filetxt," ",file,".",ext);
Exec(i);
i:=Concatenation("rm ",filetxt);
Exec(i);

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(ViewPureCubicalComplex,
function(arg)
local i,A,viewer,T;
# Function for viewing 2-dimensional pure cubical complexes.

T:=arg[1];
if not Dimension(T)=2 then
Print("There is no method for viewing a topological maqnifold of dimension ",
Dimension(T),".\n"); return fail; fi;

if Length(arg)>1 then viewer:=arg[2];
else viewer:=DISPLAY_PATH;fi;
WritePureCubicalComplexAsImage(T,"/tmp/HAPtmpImage","png");
Exec(Concatenation(viewer," ","/tmp/HAPtmpImage.png"));
Sleep(2);
Exec(Concatenation("rm  ","/tmp/HAPtmpImage.png"));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(CechComplexOfPureCubicalComplex,
function(M)
local
	Vertices,
	Simplices,
	SimplicesLst,
	NrSimplices,
	EnumeratedSimplex,
 	S,
	VertexCoordinates,
        dim,dim1,dims, 
	CartProd,
	Ball,
	Star,
	EdgeStar,
	ArrayValueDim,
	ArrayValueDim1,
	v, x, y, U, V, i;

if not IsHapPureCubicalComplex(M) then
Print("This function can only be applied to a pure cubical complex.\n");
return fail; fi;

dim:=Dimension(M);
dim1:=dim-1;
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim1);
dims:=EvaluateProperty(M,"arraySize");
S:=StructuralCopy(M!.binaryArray);
Vertices:=0;
VertexCoordinates:=[];
Ball:=Cartesian(List([1..dim],i->[-1,1]));
CartProd:=Cartesian(List([1..dim],a->[1..dims[a]]));

for x in CartProd do
if ArrayValueDim(M!.binaryArray,x)=1 then Vertices:=Vertices+1;
y:=ArrayValueDim1(S,x{[2..dim]});
y[x[1]]:=Vertices;
VertexCoordinates[Vertices]:=x;
fi;
od;

Vertices:=[1..Vertices];
SimplicesLst:=List([1..1000],i->[]);  #VERY SLOPPY!!!
SimplicesLst[1]:=List(Vertices,i->[i]);

#################################################################
NrSimplices:=function(n);
return Length(SimplicesLst[n+1]);
end;
#################################################################

#################################################################
Simplices:=function(n,i);
return SimplicesLst[n+1][i];
end;
#################################################################

#################################################################
Star:=function(x)
# For an odd  array point x in the corresponding cubical complex T 
# this function returns the list of all integers in Vertices
# corresponding to those pure cells in T that touch the vertex
# T!.binaryArray[x].
local y,z,verts;

verts:=[];

for y in Ball do
z:=(x+y)/2; #z is even
if (not 0 in z) and (not -1 in dims - z) then
     if ArrayValueDim(M!.binaryArray,z)=1 then
     Add(verts, ArrayValueDim(S,z)); fi;
fi;
od;

return verts;
end;
#################################################################

for v in Cartesian(List([1..dim],a->List([0..dims[a]],j->2*j+1))) do
U:=Star(v);
for i in [2..Length(U)] do
V:=Combinations(U,i);

for y in V do
AddSet(SimplicesLst[i],y);
od;
od;
od;

#############################################
EnumeratedSimplex:=function(v);
return
Position(SimplicesLst[Length(v)],v);
end;
#############################################

return
Objectify(HapSimplicialComplex,
           rec(
           vertices:=Vertices,
           simplices:=Simplices,
	   nrSimplices:=NrSimplices,
	   enumeratedSimplex:=EnumeratedSimplex,
           properties:=[
           ["dimension",PositionProperty(SimplicesLst,IsEmpty)-2]
	   ]
           ));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(PathComponentOfPureCubicalComplex,
function(M,N)
local
	PathCompBinList,dim,dims, dimsSet,
	ArrayValueDim,ArrayValueDim1, ArrayAssignDim,
	ArrayIt, revdimsSet,Fun, 
	w,P,x,z,i,n;
n:=N+1;
dims:=EvaluateProperty(M,"arraySize");
revdimsSet:=List(dims,d->Reversed([2..d+1]));
dim:=Dimension(M);

ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim-1);
ArrayAssignDim:=ArrayAssignFunctions(dim);
ArrayIt:=ArrayIterate(dim);

#############################################
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  #
PathCompBinList:=function()
local B,ColourNeighbours,ColourComponent,cart,CART,
NEWLYCOLOURED,GetStart,start,colour;

B:=StructuralCopy(FrameArray(M!.binaryArray));
cart:=Cartesian(List([1..Dimension(M)],i->[-1,0,1]));
RemoveSet(cart,List([1..Dimension(M)],i->0));


################################
ColourNeighbours:=function(x,j)
local w,y,z,bool;
bool:=false;

if ArrayValueDim(B,x)=j then
	for y in cart do
	z:=x+y;

	if ArrayValueDim(B,z)=1 then
	ArrayAssignDim(B,z,j);
	bool:=true;
	Add(NEWLYCOLOURED,z);
  	fi;
	od;
fi;

return bool;
end;
################################

################################
ColourComponent:=function(j)
local bool,x,CPNC;
bool:=true;

while bool do
bool:=false;
CPNC:=ShallowCopy(NEWLYCOLOURED);
for x in CPNC do
if ColourNeighbours(x,j) then bool:=true; fi;;
Unbind(NEWLYCOLOURED[Position(NEWLYCOLOURED,x)]);
od;
NEWLYCOLOURED:=SSortedList(NEWLYCOLOURED);
od;

return bool;
end;
################################

################################
GetStart:=function()
local Fun,start;

start:=fail;

Fun:=function(x);
if ArrayValueDim(B,x)=1 then start:=x;  fi;
end;

ArrayIt(revdimsSet,Fun);

return start;
end;
################################

colour:=1;
start:=GetStart();
while not start=fail do
colour:=colour+1;
ArrayAssignDim(B,start,colour);
NEWLYCOLOURED:=[start];
ColourComponent(colour);
start:=GetStart();

od;

M!.pathCompBinList:=UnframeArray(B);
M!.zeroBetti:=colour-1;
end;
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  #
#############################################

if not "pathCompBinList" in NamesOfComponents(M) then 
PathCompBinList();
fi;

######################################
if N=0 then return M!.zeroBetti;fi;###
######################################

Fun:=function(z); if z=n then return 1;else return 0;fi;end;
P:=Array(M!.pathCompBinList,Fun);

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=P,
           properties:=[
           ["dimension",Dimension(M)],
           ["arraySize",dims]]
           ));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallOtherMethod(Homology,
"Homology of a pure cubical complex",
[IsHapPureCubicalComplex],
function(M)
local S,T,C,H,dim,b,P,i;
dim:=Dimension(M);
T:=rec();
T.binaryArray:=StructuralCopy(M!.binaryArray);
T.properties:=StructuralCopy(M!.properties);
T:=Objectify(HapPureCubicalComplex,T);
ContractPureCubicalComplex(T);


b:=PathComponentOfPureCubicalComplex(T,0);
P:=PathComponentOfPureCubicalComplex(T,1);
S:=ContractibleSubcomplexOfPureCubicalComplex(P);
for i in [2..b] do
P:=PathComponentOfPureCubicalComplex(T,i);
S:=PureCubicalComplexUnion(S,
ContractibleSubcomplexOfPureCubicalComplex(P));
od;
C:=ChainComplexOfPair(T,S);

H:=[];
H[1]:=List([1..PathComponentOfPureCubicalComplex(T,0)],a->0);
for i in [1..dim-1] do
H[i+1]:=Homology(C,i);
od;
H[dim+1]:=[];
return H;
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallOtherMethod(Bettinumbers,
"Ranks of homologies of a pure cubical complex",
[IsHapPureCubicalComplex],
function(M)
local H,T;

############################
if Dimension(M)=2 then
return BettinumbersOfPureCubicalComplex_dim_2(M);
fi;
############################

H:=Homology(M);
H:=List(H,x->Length(Filtered(x,a->a=0)));
return H;
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallOtherMethod(Bettinumbers,
"Rank of n-th homology of a pure cubical complex",
[IsHapPureCubicalComplex,IsInt],
function(M,n)
local H;
if Dimension(M)=2 then return Bettinumbers(M)[n+1]; fi;
H:=Homology(M,n);
H:=Length(Filtered(H,a->a=0));
return H;
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallOtherMethod(Homology,
"Homology of a pure cubical complex",
[IsHapPureCubicalComplex,IsInt],
function(M,n) 
local S,T,C,H,b,P,i;
if n>=Dimension(M) then return [ ]; fi;

T:=rec();
T.binaryArray:=StructuralCopy(M!.binaryArray);
T.properties:=StructuralCopy(M!.properties);
T:=Objectify(HapPureCubicalComplex,T);
ContractPureCubicalComplex(T);

if n=0 then return
List([1..PathComponentOfPureCubicalComplex(T,0)],a->0);
fi;

if n=1 and Dimension(M)=2 then
C:=PathComponentOfPureCubicalComplex(T,0)-EulerCharacteristic(T);
return List([1..C],a->0);
fi;

b:=PathComponentOfPureCubicalComplex(T,0);
P:=PathComponentOfPureCubicalComplex(T,1);
S:=ContractibleSubcomplexOfPureCubicalComplex(P);
for i in [2..b] do
P:=PathComponentOfPureCubicalComplex(T,i);
S:=PureCubicalComplexUnion(S,
ContractibleSubcomplexOfPureCubicalComplex(P));
od;
C:=ChainComplexOfPair(T,S);
return Homology(C,n);

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(BoundaryOfPureCubicalComplex,
function(M)
local
	B,
	cart,dim,dims,
	InBoundary,
	ArrayValueDim,
	ArrayAssignDim,ArrayIt, 
	Fun,
	dimsSet,
	x,z;

#############################################
if not IsHapPureCubicalComplex(M) then
Print("This function must be applied to a pure cubical complex.\n");
return fail;
fi;
#############################################

dim:=Dimension(M);
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayAssignDim:=ArrayAssignFunctions(dim);
ArrayIt:=ArrayIterate(dim);
dims:=EvaluateProperty(M,"arraySize");
B:=M!.binaryArray*0;

dimsSet:=List([1..dim],a->[1..dims[a]]);
cart:=Cartesian(List([1..dim],a->[-1,0,1]));

########################
InBoundary:=function(y)
local  x, z;

if ArrayValueDim(M!.binaryArray,y)=0 then return false;fi;

for x in cart do
z:=x+y;
if (not 0 in z) and (not -1 in dims - z) then
   if ArrayValueDim(M!.binaryArray,z)=0 then return true; fi; 
fi;
od;

return false;
end;
########################


####################
Fun:=function(x);
if InBoundary(x) then 
ArrayAssignDim(B,x,1);
fi;
end;
####################

ArrayIt(dimsSet,Fun);

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=B,
           properties:=[
           ["dimension",Dimension(M)],
           ["arraySize",dims]]
           ));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(ThickenedPureCubicalComplex,
function(M)
local
        B,
        cart, CART, dim,dim1,dims,
        Thicken,
	ArrayValueDim,
	ArrayValueDim1,
        x,z;

#############################################
if not IsHapPureCubicalComplex(M) then
Print("This function must be applied to a pure cubical complex.\n");
return fail;
fi;
#############################################

dim:=Dimension(M);

if dim=2 then return ThickenedPureCubicalComplex_dim2(M); fi;

dim1:=dim-1;
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim1);
dims:=EvaluateProperty(M,"arraySize");
B:=StructuralCopy(M!.binaryArray);
CART:=Cartesian(List([1..dim],a->[1..dims[a]]));
cart:=Cartesian(List([1..dim],a->[-1,0,1]));

########################
Thicken:=function(y)
local  x, z, w;

if ArrayValueDim(M!.binaryArray,y)=0 then return false;fi;

for x in cart do
z:=x+y;
if (not 0 in z) and (not -1 in dims - z) then
  w:=ArrayValueDim1(B,z{[2..Length(z)]});
w[z[1]]:=1;
fi;
od;

end;
########################

for x in CART do
Thicken(x);
od;

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=B,
           properties:=[
           ["dimension",Dimension(M)],
           ["arraySize",dims]]
           ));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(ComplementOfPureCubicalComplex,
function(M)
local
        B,
        CART, dim,dim1,dims,
        Opp,
	ArrayValueDim,
	ArrayValueDim1,
        x,z;

#############################################
if not IsHapPureCubicalComplex(M) then
Print("This function must be applied to a pure cubical complex.\n");
return fail;
fi;
#############################################

dim:=Dimension(M);
dim1:=dim-1;
dims:=EvaluateProperty(M,"arraySize");
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim1);
B:=StructuralCopy(M!.binaryArray);
CART:=Cartesian(List([1..dim],a->[1..dims[a]]));

########################
Opp:=function(y)
local z;
z:=ArrayValueDim1(B,y{[2..Length(y)]});
if ArrayValueDim(M!.binaryArray,y)=0 then 
z[y[1]]:=1;
else
z[y[1]]:=0;
fi;
end;
########################

for x in CART do
Opp(x);
od;

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=B,
           properties:=[
           ["dimension",Dimension(M)],
           ["arraySize",dims]]
           ));

end);
#################################################################
#################################################################


#################################################################
################################################################
InstallGlobalFunction(SingularitiesOfPureCubicalComplex,
function(MM,radius,tolerance)
local
        M,B,
        CART, dim,dim1,dims,
        IsSingular,
	Circle, Ball, dimsBall,
	ArrayValueDim,
	ArrayValueDim1,
        x,z;

#############################################
if not IsHapPureCubicalComplex(MM) then
Print("This function must be applied to a pure cubical complex.\n");
return fail;
fi;
#############################################

M:=BoundaryOfPureCubicalComplex(MM);
#M:=ContractPureCubicalComplex(M);
B:=M!.binaryArray*0;

dim:=Dimension(M);
dim1:=dim-1;
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim1);
dims:=EvaluateProperty(M,"arraySize");
CART:=Cartesian(List([1..dim],a->[1..dims[a]]));

Circle:=Cartesian(List([1..dim],i->[-radius..radius]));
Ball:=Cartesian(List([1..dim],i->[-radius+1..radius-1]));
Circle:=Filtered(Circle,x->not x in Ball);

Ball:=[1..2*radius+1];
for x in [2..dim] do
Ball:=List(Ball,x->StructuralCopy(Ball));
od;
Ball:=Ball*0;

for x in Circle do
z:=ArrayValueDim1(Ball,x{[2..Length(x)]}+radius+1);
z[x[1]+radius+1]:=1;
od;


Ball:=rec(
	  binaryArray:=Ball,
	  properties:=[
	  ["dimension",dim],
	  ["arraySize", List([1..dim],a->2*radius+1)]]);
Ball:=Objectify(HapPureCubicalComplex,Ball);


dimsBall:=EvaluateProperty(Ball,"arraySize");


########################
IsSingular:=function(x)
local w,y,yy,z,B,ball,L,w1,y1;
if ArrayValueDim(M!.binaryArray,x)=0 then return false;fi;
B:=StructuralCopy(Ball!.binaryArray);
ball:=ArrayToPureCubicalComplex(B,1);
ball!.binaryArray:=B;

for y in Circle do
z:=x+y;yy:=y+radius+1;
if (not  Minimum(z)<1) and (not  Minimum(dims - z)<0) then
  if ArrayValueDim(M!.binaryArray,z)=1 then
  w:=ArrayValueDim1(ball!.binaryArray,yy{[2..Length(yy)]});
  w[yy[1]]:=0;
  fi;
fi;

od;


yy:=PathComponentOfPureCubicalComplex(ball,0);  
L:=List([1..yy],a->PathComponentOfPureCubicalComplex(ball,a));
L:=List(L,a->Flat(a!.binaryArray));
L:=List(L, a->Filtered(a,i->i=1));
L:=List(L,a->Length(a));
w:=Maximum(L);
w1:=Position(L,w);
L[w1]:=0;
y:=Maximum(L);

if 100*AbsInt(y-w)/Length(Circle)>tolerance then return true; else return false; fi;

end;
########################

for x in CART do
if IsSingular(x) then
z:=ArrayValueDim1(B,x{[2..dim]});
z[x[1]]:=1;
fi;
od;

return Objectify(HapPureCubicalComplex,
           rec(
           binaryArray:=B,
           properties:=[
           ["dimension",Dimension(M)],
           ["arraySize",dims]]
           ));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(PureCubicalComplexDifference,
function(M,N)
local
	D,
	dim,dims,
	CART,
	ArrayValueDim,
	ArrayValueDim1,
	x,w,d;

###################################
if not
IsHapPureCubicalComplex(M)
and
IsHapPureCubicalComplex(N)
then 
Print("This function must be applied to a pair of pure cubical complexes.\n");
return fail;
fi;
if not
EvaluateProperty(M,"arraySize")=
EvaluateProperty(N,"arraySize")
then 
Print("The pure cubical complexes have different array sizes.\n");
return fail;
fi;
###################################

D:=PureCubicalComplex(M!.binaryArray);
dim:=Dimension(D);
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim-1);
dims:=EvaluateProperty(D,"arraySize");
CART:=Cartesian(List([1..dim],a->[1..dims[a]]));

for x in CART do
if ArrayValueDim1(N!.binaryArray,x)=1 then
w:=ArrayValueDim1(D!.binaryArray,x{[2..dim]});
w[x[1]]:=0;
fi;
od;

return D;
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(PureCubicalComplexUnion,
function(M,N)
local
        D,
        dim,dims,
        CART,
	ArrayValueDim,
	ArrayValueDim1,
        x,w,d;

###################################
if not
IsHapPureCubicalComplex(M)
and
IsHapPureCubicalComplex(N)
then
Print("This function must be applied to a pair of pure cubical complexes.\n");
return fail;
fi;
if not
EvaluateProperty(M,"arraySize")=
EvaluateProperty(N,"arraySize")
then
Print("The pure cubical complexes have different array sizes.\n");
return fail;
fi;
###################################

D:=PureCubicalComplex(M!.binaryArray);
dim:=Dimension(D);
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim-1);
dims:=EvaluateProperty(D,"arraySize");
CART:=Cartesian(List([1..dim],a->[1..dims[a]]));


for x in CART do
if ArrayValueDim(N!.binaryArray,x)=1 then
w:=ArrayValueDim1(D!.binaryArray,x{[2..dim]});
w[x[1]]:=1;
fi;
od;

return D;
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(PureCubicalComplexIntersection,
function(M,N)
local
        D,
        dim,dims,
        CART,
	ArrayValueDim,
	ArrayValueDim1,

        x,w,d;

###################################
if not
IsHapPureCubicalComplex(M)
and
IsHapPureCubicalComplex(N)
then
Print("This function must be applied to a pair of pure cubical complexes.\n");
return fail;
fi;
if not
EvaluateProperty(M,"arraySize")=
EvaluateProperty(N,"arraySize")
then
Print("The pure cubical complexes have different array sizes.\n");
return fail;
fi;
###################################

D:=PureCubicalComplex(M!.binaryArray*0);
dim:=Dimension(D);
ArrayValueDim:=ArrayValueFunctions(dim);
ArrayValueDim1:=ArrayValueFunctions(dim-1);
dims:=EvaluateProperty(D,"arraySize");
CART:=Cartesian(List([1..dim],a->[1..dims[a]]));

for x in CART do
if ArrayValueDim(N!.binaryArray,x)=1 and ArrayValueDim(M!.binaryArray,x)=1 then
w:=ArrayValueDim1(D!.binaryArray,x{[2..dim]});
w[x[1]]:=1;
fi;
od;

return D;
end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(ChainInclusionOfPureCubicalPair,
function(M,N)
local
	map,C,D,k,U;

C:=ChainComplex(M);
D:=ChainComplex(N);

U:=[];
for k in [0..EvaluateProperty(D,"length")] do
U[k+1]:=List([1..D!.dimension(k)],i->0);
od;

###########################
map:=function(v,k)
local u,i;

u:=U[k+1]*0;

for i in [1..C!.dimension(k)] do
if not v[i]=0 then
u[ ArrayValue(D!.coordinateToPosition,C!.positionToCoordinate[k+1][i]) ]:=v[i];
fi;
od;

return u;
end;
###########################


return Objectify(HapChainMap,
        rec(
           source:=C,
           target:=D,
           mapping:=map,
           properties:=[ ["type","chainMap"],
           ["characteristic", 0],
           ]));

end);
#################################################################
#################################################################


#################################################################
#################################################################
InstallGlobalFunction(DirectProductOfPureCubicalComplexes,
function(M,N)
local
	D,
	dimM,dimN,dim,
	dimsM,dimsN,dims,
	CART,
ArrayValueDimM,
ArrayValueDimN,
ArrayValueDim1,
	x,w;

dimM:=Dimension(M);
dimN:=Dimension(N);
dim:=dimM+dimN;
ArrayValueDimM:=ArrayValueFunctions(dimM);
ArrayValueDimN:=ArrayValueFunctions(dimN);
ArrayValueDim1:=ArrayValueFunctions(dim-1);

dimsM:=EvaluateProperty(M,"arraySize");
dimsN:=EvaluateProperty(N,"arraySize");
dims:=Concatenation(dimsM,dimsN);
CART:=Cartesian(List([1..dim],i->[1..dims[i]]));
D:=[1..dims[1]]*0;
for x in [2..dim] do
D:=List([1..dims[x]],i->StructuralCopy(D));
od;


for x in CART do
if ArrayValueDimM(M!.binaryArray,x{[1..dimM]})=1 and ArrayValueDimN(N!.binaryArray,x{[dimM+1..dimM+dimN]})=1
then
w:=ArrayValueDim1(D,x{[2..dim]});
w[x[1]]:=1;
fi;
od;

D:=PureCubicalComplex(D);


return D;
end);
#################################################################
#################################################################

#################################################################
#################################################################
InstallGlobalFunction(PureCubicalComplexToFile,
function(M,file)
local
	dim,dims,CART,x,i;

dim:=Dimension(M);
dims:=EvaluateProperty(M,"arraySize");
CART:=Cartesian(List(dims,d->[1..d]));

for x in CART do
if ArrayValue(M!.binaryArray,x)=1 then 
for i in [1..dim] do
AppendTo(file,String(x[i])," ");
od;
AppendTo(file,"\n");
fi;
od;

end);
#################################################################
#################################################################

