function dx = integration_parametric_rhs_global_multi(t,x)

global ga1 ga2 ga3 ga4 ga5 gb1 gb2 gb3 gb4 gb5 gc1 gc2 gc3 gc4 gc5

dx = [ ( ga1*x(1) + ga2*x(2)^2 + ga3*x(3)^1 + ga4*x(2)^2 + ga5*t ) / (x(2)+1.1)  ; ...
       ( gb1*x(2) + gb2*x(1)^2 + gb3*x(1)^1 + gb4*x(3)^2 + gb5*t ) / (x(3)+1.1)  ; ...
       ( gc1*x(3) + gc2*x(3)^2 + gc3*x(2)^1 + gc4*x(1)^2 + gc5*t ) / (x(1)+1.1)  ];
    
end