gap> START_TEST("HAP library");
gap> SetAssertionLevel(1);;
gap> e:=SpaceGroupBBNWZ(2,10);;
gap> G:=RelativeCentralQuotientSpaceGroup(e,4);;
gap> n:=30;;PoincareSeries(G,n);
(1)/(-x_1^4+2*x_1^3-2*x_1+1)
gap> STOP_TEST( "tst.tst", 1000 );


