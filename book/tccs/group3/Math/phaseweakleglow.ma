%Orthorhombic approximations
%1. Exact Expression
ClearAll[c11,c12,c13,c12,c23,c22,c33,c44,c55,c66,n1,n2,n3,two,trace,G,H,angle,vhelbig,vpphase,vecdiff,vpgroup,vpg,pn12,pn22,pn32]
mat = {{c11,c12,c13,0,0,0},{c12,c22,c23,0,0,0},{c13,c23,c33,0,0,0},{0,0,0,c44,0,0},{0,0,0,0,c55,0},{0,0,0,0,0,c66}};
matn = {{n1,0,0,0,n3,n2},{0,n2,0,n3,0,n1},{0,0,n3,n2,n1,0}} ;
chris = matn.mat.Transpose[matn];
%Exact qP phase velocity from schoenberg and helbig (1997)
two = (chris[[1,1]]chris[[2,2]] + chris[[1,1]]chris[[3,3]] + chris[[2,2]]chris[[3,3]] - chris[[1,2]]^2 - chris[[1,3]]^2 - chris[[2,3]]^2) //FullSimplify;
trace = (chris[[1,1]] +chris[[2,2]] + chris[[3,3]]) ;
G = (trace^2)/9 - two/3 ;
H = (trace^3)/27 -(two *trace/6) + Det[chris]/2;
angle = ArcCos[H/Sqrt[G^3]];
vhelbig = 2 Sqrt[G]Cos[angle/3] + trace/3;
n1=.;n2=.; n3=.;
vecn = {n1,n2,n3} ;
vpphase = Sqrt[vhelbig];
vecdiff = {D[vpphase,n1],D[vpphase,n2],D[vpphase,n3]};
vpgroup = vpphase vecn  +(IdentityMatrix[3]-Transpose[{vecn}].{vecn}).vecdiff;
vgp = vpgroup[[1]]^2 + vpgroup[[2]]^2 +vpgroup[[3]]^2 ;
pn12 = (vpgroup[[1]]^2)/vgp;
pn22 = (vpgroup[[2]]^2)/vgp;
pn32 = (vpgroup[[3]]^2)/vgp;

%Phase velocity
vp0=Sqrt[c33];
eps2=(c11-c33)/(2*c33);
delta2=((c13+c55)^2-(c33-c55)^2)/(2*c33*(c33-c55));
eps1=(c22-c33)/(2*c33);
delta1=((c23+c44)^2-(c33-c44)^2)/(2*c33*(c33-c44));
delta3=((c12+c66)^2-(c11-c66)^2)/(2*c11*(c11-c66));

vpphaseweak=vp0^2*(1+2*n1^4*eps2+2*n2^4*eps1+2*n1^2*n3^2*delta2+2*n2^2*n3^2*delta1+2*n1^2*n2^2*(2*eps2+delta3))//FullSimplify;
shift =0;
orthoplot=Graphics[{Text[Style[phi,FontSize->16],{shift+110Cos[Pi/4],shift+110Sin[Pi/4]}],Text[Style[theta,FontSize->16],{shift,shift+100}],Text[Style[theta,FontSize->16],{shift+100,shift}],{Thick,Arrow[BSplineCurve[Table[{shift+100Cos[i],shift+ 100 Sin[i]},{i,Pi/9,7Pi/18,Pi/90}]]]},{Dashed,Table[Line[{{shift,shift},{shift + 90Cos[i],shift+90 Sin[i]}}],{i,0,2 Pi,Pi/6}]},PointSize[Large],Table[Point[{shift+ 90Cos[i],shift+ 90 Sin[i]}],{i,0,2 Pi,Pi/6}],{Thick,Circle[{shift,shift},90]}},PlotRange->{{-90+shift,90+shift},{-90+shift,90+shift}},Axes->True,AxesOrigin->{shift,shift},AxesStyle->Directive[Bold,Black,Thick],LabelStyle->{FontWeight->"Bold",FontSize->22},Ticks->{{{-60+shift,"60"},{-30+shift,"30"},{0+shift,"0"},{30+shift,"30"},{60+shift,"60"}},{{-60+shift,"60"},{-30+shift,"30"},{0+shift,"0"},{30+shift,"30"},{60+shift,"60"}}},ImagePadding->50];
phasex =theta Cos[phi*Pi/180];
phasey =theta Sin[phi*Pi/180];
phaseweak =100*Abs[Sqrt[vpphaseweak/vhelbig]-1]/.{n1->Sin[theta*Pi/180]Cos[phi*Pi/180],n2->Sin[theta*Pi/180]Sin[phi*Pi/180],n3->Cos[theta*Pi/180],c11->9,c33->5.9375,c55->1.6,c13->2.25,c22->9.84,c44->2,c12->3.6,c23->2.4,c66->2.182};
ga =Show[Rasterize[ParametricPlot3D[{phasex,phasey,phaseweak},{theta,0,90},{phi,0,360},PlotRange->{Full,Full,All},Axes->{False,False,False},Boxed->False,LabelStyle->{FontWeight->"Bold",FontSize->22},ColorFunction->ColorData[{"DarkRainbow",{0,2.0}}],ViewPoint->{0,0,Infinity},Mesh->None,PlotPoints->200,ColorFunctionScaling->False,ImagePadding->40],Background->None,ImageSize->600],Rasterize[orthoplot,Background->None,ImageSize->600]]
Export["junk_ma.eps",ga,"EPS"]
