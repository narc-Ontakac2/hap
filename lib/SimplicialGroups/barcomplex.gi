#################################################################################
#################################################################################
InstallGlobalFunction(BarComplexEquivalence,
function(R)
local 
	e,dim,lenR,
	BHe,Phi,Psi,Equiv,
	CPhi,CPsi,CEquiv;	

	e:=Identity(R!.group);
	dim:=R!.dimension;
	BHe:=BarResolutionEquivalence(R);
	Phi:=BHe!.phi;
	Psi:=BHe!.psi;
	Equiv:=BHe!.equiv;
	lenR:=EvaluateProperty(R,"length");
#################################################	
CPhi:=function(n,w)  ###w:=[[m1,g11..,g1n],[mk,gk1,..gkn]]
	local Ew,iw,tmp,phiw,i,Rew;
	Ew:=[];  
	for iw in w do  
		tmp:=[iw[1],e]; #### add indentity element
		for i in [2..n+1] do
			Add(tmp,iw[i]);
		od;
		Add(Ew,tmp);
	od;
    phiw:=Phi(n,Ew);
    Rew:= List([ 1..dim(n)],x->0);
	for tmp in phiw do
		i:=tmp[2];
		Rew[i]:=Rew[i]+tmp[1];
    od;
return Rew;
end;	
#######################################################
CPsi:=function(n,w)  ###w:=[[m1,e1],..,[m1,ek]] with k:=dim(n); ex w:=[[-2,1],[4,2]...]
local Rew,tmp,cw;	
	cw:=StructuralCopy(w);  
	for tmp in cw do
		Add(tmp,1);
	od;
	Rew:=Psi(n,cw);
	for tmp in Rew do
		Remove(tmp,2);
	od;
return Rew;
end;	
########################################################		
CEquiv:=function(n,w) ######w:=[[m1,g11..,g1n],[mk,gk1,..gkn]
	local ew,iw,i,tmp,Rew;
	ew:=[];
	for iw in w do  
		tmp:=[-iw[1],e]; #### add indentity element and minus
		for i in [2..n+1] do
			Add(tmp,iw[i]);
		od;
		Add(ew,tmp);
	od;
    Rew:=Equiv(n,ew);
	for tmp in Rew do
		Remove(tmp,2);
	od;
	return Rew;
end;
############################################################
#############################################################
return rec(
            phi:=CPhi,
			psi:=CPsi,
			equiv:=CEquiv
          );
end);
	