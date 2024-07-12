function dx = integration_parametric_rhs_param_single_structORclass(t,x,p)

a1 = p.a1;
a2 = p.a2;
a3 = p.a3;
a4 = p.a4;
a5 = p.a5;
b1 = p.b1;
b2 = p.b2;
b3 = p.b3;
b4 = p.b4;
b5 = p.b5;
c1 = p.c1;
c2 = p.c2;
c3 = p.c3;
c4 = p.c4;
c5 = p.c5;


dx = [ ( a1*x(1) + a2*x(2)^2 + a3*x(3)^1 + a4*x(2)^2 + a5*t ) / (x(2)+1.1)  ; ...
       ( b1*x(2) + b2*x(1)^2 + b3*x(1)^1 + b4*x(3)^2 + b5*t ) / (x(3)+1.1)  ; ...
       ( c1*x(3) + c2*x(3)^2 + c3*x(2)^1 + c4*x(1)^2 + c5*t ) / (x(1)+1.1)  ];
    
end
