function dx = integration_parametric_rhs_persistent_single(t,x)


persistent p

if ~isnumeric(t)
   disp('Initializing RHS');
   p = x;
   return
end

a1 = p(01);
a2 = p(02);
a3 = p(03);
a4 = p(04);
a5 = p(05);
b1 = p(06);
b2 = p(07);
b3 = p(08);
b4 = p(09);
b5 = p(10);
c1 = p(11);
c2 = p(12);
c3 = p(13);
c4 = p(14);
c5 = p(15);


dx = [ ( a1*x(1) + a2*x(2)^2 + a3*x(3)^1 + a4*x(2)^2 + a5*t ) / (x(2)+1.1)  ; ...
       ( b1*x(2) + b2*x(1)^2 + b3*x(1)^1 + b4*x(3)^2 + b5*t ) / (x(3)+1.1)  ; ...
       ( c1*x(3) + c2*x(3)^2 + c3*x(2)^1 + c4*x(1)^2 + c5*t ) / (x(1)+1.1)  ];
    
end
