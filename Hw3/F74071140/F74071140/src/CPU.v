// Please include verilog file if you write module in other file

module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output reg        instr_read,
    output reg        data_read,
    output reg [31:0] instr_addr,
    output reg [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in
);
//Main control
reg [31:0] PC, imm;
reg [6:0] opcode;
//ALU control
reg [4:0] shamt;
reg [4:0] rs1, rs2, rd;
reg [2:0] funct3;
reg [6:0] funct7;
reg [1:0] count;
reg [31:0] Register [0:31];

integer i;

initial begin // Initial block.
	instr_read<=1;
	data_read<=0;
	instr_addr<=0;
	data_addr<=0;
	data_write<=0;
	data_in<=0;
	Register[0] <= 32'd0;
	count<=0;
	imm<=0;
end

always@(posedge clk) begin
	
	if(rst) begin
		instr_read<=1;
		data_read<=0;
		instr_addr<=0;
		data_addr<=0;
		data_write<=0;
		data_in<=0;
		count<=0;
		PC<=0;
		imm<=0;
	end
	else if(count==2) begin  //DM time
		count<=count+1;
	end
	else if(count==0) begin  //IM time
		Register[0]<=0;
		instr_read<=0;
		data_in<=0;
		PC<=instr_addr;
		data_write<=0;
		count<=count+1;
	end
	else if(count==3) begin   //Write Back
		instr_read<=1;
		instr_addr<=PC;
		count<=0;
		if(opcode==7'b0000011 && funct3==3'b010)  //lw
			Register[rd]=data_out;
		else if(opcode==7'b0000011 && funct3==3'b000)  //lb
			Register[rd]={{24{data_out[7]}},data_out[7:0]};
		else if(opcode==7'b0000011 && funct3==3'b001)  //lh
			Register[rd]={{16{data_out[15]}},data_out[15:0]};
		else if(opcode==7'b0000011 && funct3==3'b100)  //lbu
			Register[rd]={24'b0,data_out[7:0]};
		else if(opcode==7'b0000011 && funct3==3'b101)  //lhu
			Register[rd]={16'b0,data_out[15:0]};

	end
        else if(count == 1) begin
            opcode = instr_out[6:0];
	    count = 2'b10;
	    case(opcode)
	    //R-type
            7'b0110011: begin 
		{funct7, rs2, rs1, funct3, rd, opcode} = instr_out;
		shamt = Register[rs2][4:0];
		case(funct3)
			3'b000: begin
				if(funct7===7'b0000000) //add
					Register[rd]=Register[rs1]+Register[rs2];
				else if(funct7==7'b0100000) //sub
					Register[rd]=Register[rs1]-Register[rs2];
			end
			3'b001: begin //sll
				Register[rd]=$unsigned(Register[rs1])<<shamt;
			end
			3'b010: begin //slt
				Register[rd]=$signed(Register[rs1])<$signed(Register[rs2])?1:0;
			end
			3'b011: begin //sltu
				Register[rd]=$unsigned(Register[rs1])<$unsigned(Register[rs2])?1:0;
			end
			3'b100: begin //xor
				Register[rd]=Register[rs1]^Register[rs2];
			end
			3'b101: begin 
				if(funct7==7'b0000000) //srl
					Register[rd]=$unsigned(Register[rs1])>>shamt;
				else if(funct7==7'b0100000) //sra
					Register[rd]=$signed(Register[rs1])>>shamt;
			end
			3'b110: begin //or
				Register[rd]=Register[rs1]|Register[rs2];
			end
			3'b111: begin //and
				Register[rd]=Register[rs1]&Register[rs2];
			end
		endcase
		              PC = PC + 4;   
            end
	    //I-type
             7'b0000011: begin //load
			{funct7, rs2, rs1, funct3, rd, opcode} = instr_out;
                	shamt = rs2;
			imm[31:0]={{20{instr_out[31]}},instr_out[31:20]};
                        PC = PC + 4;
				case(funct3)
					3'b010: begin //lw                    -->haven't put in Register[rd]
						data_addr=Register[rs1]+imm;
						data_read<=1;
					end
					3'b000: begin //lb                    -->haven't put in Register[rd]
						data_addr=Register[rs1]+imm;
						data_read<=1;
					end
					3'b001: begin //lh                    -->haven't put in Register[rd]
						data_addr=Register[rs1]+imm;
						data_read<=1;
					end
					3'b100: begin //lbu                   -->haven't put in Register[rd]
						data_addr=Register[rs1]+imm;
						data_read<=1;
					end
					3'b101: begin //lhu                   -->haven't put in Register[rd]
						data_addr=Register[rs1]+imm;
						data_read<=1;
					end
				endcase
                end
               7'b0010011: begin
			{funct7, rs2, rs1, funct3, rd, opcode} = instr_out;
                	shamt = rs2;
			imm[31:0]={{20{instr_out[31]}},instr_out[31:20]};
                        PC = PC + 4;
			case(funct3)
				3'b000: begin //addi
					Register[rd]=Register[rs1]+imm;
				end
				3'b010: begin //slti
					Register[rd]=$signed(Register[rs1])<$signed(imm)?1:0;
				end
				3'b011: begin //sltiu
					Register[rd]=$unsigned(Register[rs1])<$unsigned(imm)?1:0;
				end
				3'b100: begin //xori
					Register[rd]=Register[rs1]^imm;
				end
				3'b110: begin //ori
					Register[rd]=Register[rs1]|imm;
				end
				3'b111: begin //andi
					Register[rd]=Register[rs1]&imm;
				end
				3'b001: begin //slli
					Register[rd]=$unsigned(Register[rs1])<<shamt;
				end
				3'b101: begin
					if(instr_out[31:25]==7'b0000000)  //srli
						Register[rd]=$unsigned(Register[rs1])>>shamt;
					else if(instr_out[31:25]==7'b0100000)  //srai
						Register[rd]=$signed(Register[rs1])>>>shamt;
					end
			endcase
                end
                7'b1100111: begin  //jalr
		    {funct7, rs2, rs1, funct3, rd, opcode} = instr_out;
                    shamt = rs2;
		    imm[31:0]={{20{instr_out[31]}},instr_out[31:20]};
                    Register[rd] <= PC + 4;
                    PC <= imm + Register[rs1]; 
                end
		// S-type
		7'b0100011: begin 
		{funct7, rs2, rs1, funct3, rd, opcode} = instr_out;
		imm[31:0]={{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
                data_addr = Register[rs1] + imm;
		
		if(funct3 == 3'b010)begin  //sw
                    data_in = Register[rs2];
                    data_write = 4'b1111; 
                end               
                else if(funct3 == 3'b000)begin //sb
                    if(data_addr[1:0] == 2'b00)begin
                        data_write = 4'b0001;
                        data_in = {24'b0,Register[rs2][7:0]};
                    end
                    else if(data_addr[1:0] == 2'b10)begin
                        data_write = 4'b0100;
                        data_in = {16'b0,Register[rs2][7:0],7'b0};
                    end
                    else if(data_addr[1:0] == 2'b01)begin
                        data_write = 4'b0010;
                        data_in = {16'b0,Register[rs2][7:0],7'b0};
                    end 
                    else if(data_addr[1:0] == 2'b11)begin
                        data_write = 4'b1000;
                        data_in[31:24] = Register[rs2][7:0];
                        for(i = 0; i < 24; i = i + 1)begin
                            data_in[i] = 1'b0;  
                        end 
                    end   
                end
                else if(funct3 == 3'b001)begin //sh
                    if(data_addr[1:0] == 2'b00)begin
                        data_write = 4'b0011;
                        data_in[15:0] = {16'b0,Register[rs2][15:0]};
                    end
                    else if(data_addr[1:0] == 2'b01)begin
                        data_write = 4'b0110;
                        data_in[23:8] = {8'b0,Register[rs2][15:0],8'b0};
                    end
                    else if(data_addr[1:0] == 2'b10)begin
                        data_write = 4'b1100;
                        data_in[31:16] = Register[rs2][15:0];
                        for(i = 0; i < 16; i = i + 1)begin
                            data_in[i] = 1'b0;  
                        end 
                    end  
                end
                PC = PC + 4;
            end
	    // B-type
            7'b1100011: begin  
		{funct7, rs2, rs1, funct3, rd, opcode} = instr_out;
		imm[31:0]={{19{instr_out[31]}},instr_out[7],instr_out[30:25],instr_out[11:8],1'b0};
		case(funct3)
			3'b000: PC=Register[rs1]==Register[rs2]?PC+imm:PC+4;  //beq
			3'b001: PC=Register[rs1]!=Register[rs2]?PC+imm:PC+4;  //bne
			3'b100: PC=$signed(Register[rs1])<$signed(Register[rs2])?PC+imm:PC+4;  //blt
			3'b101: PC=$signed(Register[rs1])>=$signed(Register[rs2])?PC+imm:PC+4;  //bge
			3'b110: PC=$unsigned(Register[rs1])<$unsigned(Register[rs2])?PC+imm:PC+4;  //bltu
			3'b111: PC=$unsigned(Register[rs1])>=$unsigned(Register[rs2])?PC+imm:PC+4;  //bgeu
		endcase
            end
            7'b0010111: begin  //auipc
                rd = instr_out[11:7];
		imm[31:0]={instr_out[31:12],12'd0};
                Register[rd] = PC + imm;  
                PC = PC + 4;
            end
            7'b0110111: begin //lui
                rd = instr_out[11:7];
		imm[31:0]={instr_out[31:12],12'd0};
                Register[rd] = imm;  
                PC = PC + 4;
            end
            7'b1101111: begin  // jal
                rd = instr_out[11:7];
		imm[31:0]={{12{instr_out[31]}},instr_out[19:12],instr_out[20],instr_out[30:21],1'b0};
                Register[rd] = PC + 32'h4;
                PC = PC + imm; 
            end
	endcase
        end
end

//if want to do more add code here
endmodule
