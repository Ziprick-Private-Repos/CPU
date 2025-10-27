if(instruction == MOV)
begin                    
    if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;
    end
    
    else
    begin
        case(dataIn[1:0])
            2'b00:
                tmpReg <= r1Out;
                
            2'b01:
                tmpReg <= r2Out;
                
            2'b10:
                tmpReg <= r3Out;
                
            2'b11:
                tmpReg <= r4Out;
        endcase

        state <= I_ACCESS_REG_WRITE;
    end
end

else if(instruction == XCHG)
begin                    
    case(dataIn[1:0])
        2'b00:
            tmpReg <= r1Out;
            
        2'b01:
            tmpReg <= r2Out;
            
        2'b10:
            tmpReg <= r3Out;
            
        2'b11:
            tmpReg <= r4Out;
    endcase

    cycleCount <= 1;
    state <= I_ACCESS_REG_WRITE;
end

else if(instruction == STOSB)
begin
    toDataBus <= r1Out;
    memReadWrite <= ADDR_MODE_WRT;
    state <= I_ACCESS_MEM_WRITE;
end

else if(instruction == STOSBA)
begin
    toDataBus <= r1Out;
    memReadWrite <= ADDR_MODE_WRT;
    state <= I_ACCESS_MEM_WRITE;
end

else if(instruction == RSTOSB)
begin
    toDataBus <= r1Out;
    memReadWrite <= ADDR_MODE_WRT;
    state <= I_ACCESS_MEM_WRITE;
end

else if(instruction == SPIRFR)
begin
    si <= {r3Out, r2Out, r1Out};
    state <= I_PC_NEXT;
end

else if(instruction == SPDRFR)
begin
    di <= {r3Out, r2Out, r1Out};
    state <= I_PC_NEXT;
end