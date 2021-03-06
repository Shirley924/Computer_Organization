module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

//write your code here
reg [11:0]cycle;
reg [2:0]state;  


always @(posedge clk or posedge rst)
begin
  if(rst)  //restart
    begin
	state=1; cycle=1; G=1; R=0; Y=0;
    end

  else if(pass && state!=1)
    begin
	state=1; cycle=1; G=1; R=0; Y=0;
    end
else
  case(state)
    1:  //initial green light
	begin
	  if(cycle>=1024)
			begin
		  	  cycle=1;
			  G=0; R=0; Y=0;
			  state=2;
			end
		  else
			begin
			  cycle=cycle+1;
			  G=1; R=0; Y=0;
			end
	end 
    2:  //no light
	begin
	  if(cycle>=128)  //goto next state
		  begin
			cycle=1;
			G=1; Y=0; R=0;
			state=3;
		  end
	  else
		begin
			cycle=cycle+1;
			G=0; Y=0; R=0;
		end
	end
    3:  //green light
		begin
		 if(cycle>=128)
		  begin
			cycle=1;
			G=0; Y=0; R=0;
			state=4;
		  end
		else
		  begin
			cycle=cycle+1;
			G=1; Y=0; R=0;
 		  end
		end
    4:  //no light
		begin
		 if(cycle>=128)
		  begin
			cycle=1;
			G=1; Y=0; R=0;
			state=5;
		  end
		else
		  begin
			cycle=cycle+1;
			G=0; Y=0; R=0;
		  end
		end
    5:  //green light
		begin
		 if(cycle>=128)
		  begin
			cycle=1;
			G=0; Y=1; R=0;
			state=6;
		  end
		else
		  begin
			cycle=cycle+1;
			G=1; Y=0; R=0;
		  end
		end
    6:  //yellow light
		begin
		if(cycle>=512)
		  begin
			cycle=1;
			G=0; Y=0; R=1;
			state=0;
		  end
		else
		 begin
		  cycle=cycle+1;
		  G=0; Y=1; R=0;
		 end
		end
    0:  //red light
	begin
	  if(cycle>=1024)
		    begin
		  	  cycle=1;
			  R=0; G=1; Y=0;
			  state=1;
			end
		  else
			begin
			  cycle=cycle+1;
			  R=1; G=0; Y=0;
			end
	end
    default:
	begin
	end
  endcase
end

endmodule
