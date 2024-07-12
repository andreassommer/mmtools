function dx = integration_parametric_rhs_global_single(t,x)

global gparamVECTOR

ga1 = gparamVECTOR(01);
ga2 = gparamVECTOR(02);
ga3 = gparamVECTOR(03);
ga4 = gparamVECTOR(04);
ga5 = gparamVECTOR(05);
gb1 = gparamVECTOR(06);
gb2 = gparamVECTOR(07);
gb3 = gparamVECTOR(08);
gb4 = gparamVECTOR(09);
gb5 = gparamVECTOR(10);
gc1 = gparamVECTOR(11);
gc2 = gparamVECTOR(12);
gc3 = gparamVECTOR(13);
gc4 = gparamVECTOR(14);
gc5 = gparamVECTOR(15);


dx = [ ( ga1*x(1) + ga2*x(2)^2 + ga3*x(3)^1 + ga4*x(2)^2 + ga5*t ) / (x(2)+1.1)  ; ...
       ( gb1*x(2) + gb2*x(1)^2 + gb3*x(1)^1 + gb4*x(3)^2 + gb5*t ) / (x(3)+1.1)  ; ...
       ( gc1*x(3) + gc2*x(3)^2 + gc3*x(2)^1 + gc4*x(1)^2 + gc5*t ) / (x(1)+1.1)  ];
    
end
