classdef integration_parametric_dataclass < handle
   
   properties
      a1
      a2
      a3
      a4
      a5
      b1
      b2
      b3
      b4
      b5
      c1
      c2
      c3
      c4
      c5
   end
   
   methods

      
      % Constructor
      function obj = integration_parametric_dataclass(a1, a2, a3, a4, a5, b1, b2, b3, b4, b5, c1, c2, c3, c4, c5)
         obj.a1 = a1;
         obj.a2 = a2;
         obj.a3 = a3;
         obj.a4 = a4;
         obj.a5 = a5;
         obj.b1 = b1;
         obj.b2 = b2;
         obj.b3 = b3;
         obj.b4 = b4;
         obj.b5 = b5;
         obj.c1 = c1;
         obj.c2 = c2;
         obj.c3 = c3;
         obj.c4 = c4;
         obj.c5 = c5;
      end
     
      
   end
   
end