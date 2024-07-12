function dx = integration_parametric_rhs_global_class(t,x)

global gparamCLASS

a1 = gparamCLASS.a1;
a2 = gparamCLASS.a2;
a3 = gparamCLASS.a3;
a4 = gparamCLASS.a4;
a5 = gparamCLASS.a5;
b1 = gparamCLASS.b1;
b2 = gparamCLASS.b2;
b3 = gparamCLASS.b3;
b4 = gparamCLASS.b4;
b5 = gparamCLASS.b5;
c1 = gparamCLASS.c1;
c2 = gparamCLASS.c2;
c3 = gparamCLASS.c3;
c4 = gparamCLASS.c4;
c5 = gparamCLASS.c5;


dx = [ ( a1*x(1) + a2*x(2)^2 + a3*x(3)^1 + a4*x(2)^2 + a5*t ) / (x(2)+1.1)  ; ...
       ( b1*x(2) + b2*x(1)^2 + b3*x(1)^1 + b4*x(3)^2 + b5*t ) / (x(3)+1.1)  ; ...
       ( c1*x(3) + c2*x(3)^2 + c3*x(2)^1 + c4*x(1)^2 + c5*t ) / (x(1)+1.1)  ];
    
end
