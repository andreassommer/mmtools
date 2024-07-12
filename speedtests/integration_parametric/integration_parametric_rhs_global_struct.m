function dx = integration_parametric_rhs_global_single(t,x)

global gparamSTRUCT

a1 = gparamSTRUCT.a1;
a2 = gparamSTRUCT.a2;
a3 = gparamSTRUCT.a3;
a4 = gparamSTRUCT.a4;
a5 = gparamSTRUCT.a5;
b1 = gparamSTRUCT.b1;
b2 = gparamSTRUCT.b2;
b3 = gparamSTRUCT.b3;
b4 = gparamSTRUCT.b4;
b5 = gparamSTRUCT.b5;
c1 = gparamSTRUCT.c1;
c2 = gparamSTRUCT.c2;
c3 = gparamSTRUCT.c3;
c4 = gparamSTRUCT.c4;
c5 = gparamSTRUCT.c5;


dx = [ ( a1*x(1) + a2*x(2)^2 + a3*x(3)^1 + a4*x(2)^2 + a5*t ) / (x(2)+1.1)  ; ...
       ( b1*x(2) + b2*x(1)^2 + b3*x(1)^1 + b4*x(3)^2 + b5*t ) / (x(3)+1.1)  ; ...
       ( c1*x(3) + c2*x(3)^2 + c3*x(2)^1 + c4*x(1)^2 + c5*t ) / (x(1)+1.1)  ];
    
end
