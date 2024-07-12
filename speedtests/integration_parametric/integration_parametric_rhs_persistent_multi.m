function dx = integration_parametric_rhs_persistent_multi(t,x)


persistent a1 a2 a3 a4 a5 b1 b2 b3 b4 b5 c1 c2 c3 c4 c5

if ~isnumeric(t)
   disp('Initializing RHS');
   a1 = x(01);
   a2 = x(02);
   a3 = x(03);
   a4 = x(04);
   a5 = x(05);
   b1 = x(06);
   b2 = x(07);
   b3 = x(08);
   b4 = x(09);
   b5 = x(10);
   c1 = x(11);
   c2 = x(12);
   c3 = x(13);
   c4 = x(14);
   c5 = x(15);
   return
end


dx = [ ( a1*x(1) + a2*x(2)^2 + a3*x(3)^1 + a4*x(2)^2 + a5*t ) / (x(2)+1.1)  ; ...
       ( b1*x(2) + b2*x(1)^2 + b3*x(1)^1 + b4*x(3)^2 + b5*t ) / (x(3)+1.1)  ; ...
       ( c1*x(3) + c2*x(3)^2 + c3*x(2)^1 + c4*x(1)^2 + c5*t ) / (x(1)+1.1)  ];
    
end
