if(instruction == STB)
begin
    if(cycleCount == 1)
    begin
        toDataBus <= r1Out;
        cycleCount <= cycleCount - 1;    
    end

    else
    begin
        addressOutBuff <= addressLinesOutBuff;
        memReadWrite <= ADDR_MODE_WRT; 
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

if(instruction == STBREG)
begin
    if(cycleCount == 1)
    begin
        toDataBus <= r1Out;
        cycleCount <= cycleCount - 1;    
    end

    else
    begin
        addressOutBuff <= addressLinesOutBuff;
        memReadWrite <= ADDR_MODE_WRT; 
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == PUSH)
begin
    toDataBus <= tmpReg;
    addressOutBuff <= stackPointer;
    stackPointer <= stackPointer - 1;
    memReadWrite <= ADDR_MODE_WRT;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == PUSHA)
begin
    if(cycleCount == 3)
    begin
        toDataBus <= r1Out;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer - 1;
        memReadWrite <= ADDR_MODE_WRT;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        toDataBus <= r2Out;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer - 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        toDataBus <= r3Out;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer - 1;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 0)
    begin
        toDataBus <= r4Out;
        addressOutBuff <= stackPointer;
        stackPointer <= stackPointer - 1;
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == CALL)
begin
    if(cycleCount == 4)
    begin
        toDataBus <= retAddr[7:0];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        memReadWrite <= ADDR_MODE_WRT;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        cycleCount <= cycleCount - 1;
        addressOutBuff <= stackPointer;
    end
    
    else if(cycleCount == 2)
    begin
        toDataBus <= retAddr[15:8];
        stackPointer <= stackPointer - 1;
        
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 1)
    begin
        cycleCount <= cycleCount - 1;   
        addressOutBuff <= stackPointer;         
    end

    else if(cycleCount == 0)
    begin
        toDataBus <= retAddr[23:16];
        stackPointer <= stackPointer - 1;
        
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == STOSB)
begin
    di <= di + 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == STOSBA)
begin
    memReadWrite <= ADDR_MODE_RD;
    di <= di + 1;
    state <= I_ACCESS_REG_READ_2;
    cycleCount <= 1;   
end

else if(instruction == RSTOSB)
begin
    di <= di - 1;
    state <= I_PC_NEXT;
    cycleCount <= 1;
end

else if(instruction == H_INT)
begin
    //push return address
    if(cycleCount == 4)
    begin
        toDataBus <= retAddr[7:0];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        memReadWrite <= ADDR_MODE_WRT;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        toDataBus <= retAddr[15:8];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        toDataBus <= retAddr[23:16];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    //push flags
    else if(cycleCount == 1)
    begin
        toDataBus <= {2'b00, srFlag, divZero, greaterFlag, zeroFlag, eqFlag, overflowFlag};
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    //push registers
    else if(cycleCount == 0)
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end

else if(instruction == S_INT)
begin
    //push return address
    if(cycleCount == 4)
    begin
        toDataBus <= retAddr[7:0];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        memReadWrite <= ADDR_MODE_WRT;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 3)
    begin
        toDataBus <= retAddr[15:8];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    else if(cycleCount == 2)
    begin
        toDataBus <= retAddr[23:16];
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    //push flags
    else if(cycleCount == 1)
    begin
        toDataBus <= {2'b00, srFlag, divZero, greaterFlag, zeroFlag, eqFlag, overflowFlag};
        stackPointer <= stackPointer - 1;
        addressOutBuff <= stackPointer;
        cycleCount <= cycleCount - 1;
    end

    //push registers
    else if(cycleCount == 0)
    begin
        state <= I_PC_NEXT;
        cycleCount <= 1;
    end
end