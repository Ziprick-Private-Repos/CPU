if(cycleCount == 4)
begin
    //buffer time, for accumulator to finish processing

    cycleCount <= cycleCount - 1;
end

else if(cycleCount == 3)
begin
    if(instruction == ADDS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end

    else if(instruction == SUBS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end

    else if(instruction == INCS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end
    
    else if(instruction == DECS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end

    else if(instruction == ROLS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end

    else if(instruction == RORS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end
    
    /*else if(instruction == MULS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end*/
    
    else if(instruction == DIVS)
    begin
        tmpReg <= remainderS[15:8];
        r3En <= 1;
    end

    cycleCount <= cycleCount - 1;
end

else if(cycleCount == 2)
begin
    if(instruction == ADDS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 0;
    end

    else if(instruction == SUBS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 0;
    end

    else if(instruction == INCS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 0;
    end
    
    else if(instruction == DECS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 0;
    end

    else if(instruction == ROLS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 0;
    end

    else if(instruction == RORS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 0;
    end
    
    /*else if(instruction == MULS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;
    end*/
    
    else if(instruction == DIVS)
    begin
        tmpReg <= remainderS[15:8];
        r3En <= 0;
    end

    cycleCount <= cycleCount - 1;
end

else if(cycleCount == 1)
begin
    if(instruction == ADDS)
    begin
        tmpReg <= accumOutS[7:0];
        r2En <= 1;
    end

    else if(instruction == SUBS)
    begin
        r1En <= 0;
        tmpReg <= accumOutS[7:0];
        r2En <= 1;
    end

    else if(instruction == INCS)
    begin
        r1En <= 0;
        tmpReg <= accumOutS[7:0];
        r2En <= 1;
    end
    
    else if(instruction == DECS)
    begin
        r1En <= 0;
        tmpReg <= accumOutS[7:0];
        r2En <= 1;
    end

    else if(instruction == ROLS)
    begin
        r1En <= 0;
        tmpReg <= accumOutS[7:0];
        r2En <= 1;
    end

    else if(instruction == RORS)
    begin
        r1En <= 0;
        tmpReg <= accumOutS[7:0];
        r2En <= 1;
    end
    
    else if(instruction == MULS)
    begin
        tmpReg <= accumOutS[15:8];
        r1En <= 1;

        //r1En <= 0;
        //tmpReg <= accumOutS[7:0];
        //r2En <= 1;
    end
    
    else if(instruction == DIV)
    begin
        tmpReg <= remainder;
        r2En <= 1;
    end

    else if(instruction == DIVS)
    begin
        r3En <= 0;
        tmpReg <= remainderS[7:0];
        r4En <= 1;
    end

    memReadWrite <= ADDR_MODE_PC;
    cycleCount <= cycleCount - 1;
end

else if(cycleCount > 1) //this shouldn't occur, just a failsafe
begin
    cycleCount <= cycleCount - 1;
end

else
begin
    addressOutBuff <= pc;
    state <= I_IDLE;
    cycleCount <= 0;

    case(instruction)
        NOP:
        begin
            pc <= pc + 1;
        end

        MOV:
        begin
            pc <= pc + 2;
        end

        LODSB:
        begin
            pc <= pc + 1;
        end

        RLODSB:
        begin
            pc <= pc + 1;
        end

        LOD:
        begin
            pc <= pc + 2;
        end

        STB:
        begin
            pc <= pc + 4;
        end

        STBREG:
        begin
            pc <= pc + 4;
        end

        BNE:
        begin
            if(eqFlagBus == 0)
                pc <= addressLinesOutBuff;

            else
                pc <= pc + 4;
        end

        BEQ:
        begin
            if(eqFlagBus)
                pc <= addressLinesOutBuff;

            else
                pc <= pc + 4;
        end

        BGR:
        begin
            if(greaterFlagBus)
                pc <= addressLinesOutBuff;

            else
                pc <= pc + 4;
        end

        PUSH:
        begin
            pc <= pc + 2;
        end

        POP:
        begin
            pc <= pc + 2;
        end

        LDM:
        begin
            pc <= pc + 4;
        end

        LDMREG:
        begin
            pc <= pc + 4;
        end

        S_INT:
        begin
            //jump to int handler
            case(intNum)
                8'd16:
                begin
                    pc <= SOFT_INT_16_ADDR;
                end

                8'd17:
                begin
                    pc <= SOFT_INT_17_ADDR;
                end

                8'd18:
                begin
                    pc <= SOFT_INT_18_ADDR;
                end

                8'd19:
                begin
                    pc <= SOFT_INT_19_ADDR;
                end

                8'd20:
                begin
                    pc <= SOFT_INT_20_ADDR;
                end

                8'd21:
                begin
                    pc <= SOFT_INT_21_ADDR;
                end

                8'd22:
                begin
                    pc <= SOFT_INT_22_ADDR;
                end
            endcase
        end

        IRET:
        begin
            pc <= retAddr;
        end

        PUSHA:
        begin
            pc <= pc + 1;
        end

        POPA:
        begin
            pc <= pc + 1;
        end

        CLI:
        begin
            pc <= pc + 1;
        end

        STI:
        begin
            pc <= pc + 1;
        end

        HALT:
        begin
            pc <= pc;
        end

        CALL:
        begin
            pc <= addressLinesOutBuff;
        end

        RTS:
        begin
            pc <= retAddr;
        end

        RTSV:
        begin
            pc <= retAddr;
        end

        BRA:
        begin
            pc <= addressLinesOutBuff;
        end

        NSB:
        begin
            pc <= pc + 1;
        end

        BRZ:
        begin
            if(zeroFlagBus)
                pc <= addressLinesOutBuff;

            else
                pc <= pc + 4;
        end

        SPIR:
        begin
            pc <= pc + 4;
        end

        RST:
        begin
            pc <= 0;
        end

        SBP:
        begin
            pc <= pc + 4;
        end

        STOSB:
        begin
            pc <= pc + 1;
        end

        STOSBA:
        begin
            pc <= pc + 1;
        end

        RSTOSB:
        begin
            pc <= pc + 1;
        end

        SPDR:
        begin
            pc <= pc + 4;
        end

        XCHG:
        begin
            pc <= pc + 2;
        end

        SSPR:
        begin
            pc <= pc + 4;
        end

        SDEQUAL:
        begin
            pc <= pc + 1;
        end

        SDBEQ:
        begin
            if(srFlag)
                pc <= addressLinesOutBuff;

            else
                pc <= pc + 4;

            srFlag <= 0;
        end

        LDSP:
        begin
            pc <= pc + 1;
        end

        LDSPI:
        begin
            pc <= pc + 1;
        end

        SPIRFR:
        begin
            pc <= pc + 1;
        end

        SPDRFR:
        begin
            pc <= pc + 1;
        end

        SSFP:
        begin
            pc <= pc + 1;
        end

        SSFPM:
        begin
            pc <= pc + 1;
        end
        
        SSFPR:
        begin
            pc <= pc + 1;
        end

        GSFP:
        begin
            pc <= pc + 2;
        end

        //ALU
        OR:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        AND:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        SHL:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        SHR:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        CMP:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        NOT:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        XOR:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        H_INT:
        begin
            intNum <= 0;
            intLock <= 0;
            //jump to int handler
            case(intNum)
                8'd1:
                begin
                    pc <= IRQ_1_ADDR;
                end

                8'd2:
                begin
                    pc <= IRQ_2_ADDR;
                end

                8'd3:
                begin
                    pc <= IRQ_3_ADDR;
                end

                8'd4:
                begin
                    pc <= IRQ_4_ADDR;
                end

                8'd5:
                begin
                    pc <= IRQ_5_ADDR;
                end

                8'd6:
                begin
                    pc <= IRQ_6_ADDR;
                end

                8'd7:
                begin
                    pc <= IRQ_7_ADDR;
                end
            
                8'd8:
                begin
                    pc <= IRQ_8_ADDR;
                end

                8'd9:
                begin
                    pc <= IRQ_9_ADDR;
                end

                8'd10:
                begin
                    pc <= IRQ_10_ADDR;
                end

                8'd11:
                begin
                    pc <= IRQ_11_ADDR;
                end

                8'd12:
                begin
                    pc <= IRQ_12_ADDR;
                end

                8'd13:
                begin
                    pc <= IRQ_13_ADDR;
                end

                8'd14:
                begin
                    pc <= IRQ_14_ADDR;
                end

                8'd15:
                begin
                    pc <= IRQ_15_ADDR;
                end
            endcase
        end

        ADD:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        SUB:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        INC:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        DEC:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        ROL:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        ROR:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end

        MUL:
        begin
            r1En <= 1;
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        DIV:
        begin
            r1En <= 1;
            r2En <= 0;  
            tmpReg <= accumOut;
            pc <= pc + 2;
        end

        ADDS:
        begin
            //r1En <= 0;
            //r2En <= 0;  
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        SUBS:
        begin
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        INCS:
        begin
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        DECS:
        begin
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        ROLS:
        begin
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        RORS:
        begin
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        MULS:
        begin
            r1En <= 0;
            tmpReg <= accumOutS[7:0];
            r2En <= 1;
            //r1En <= 1;
            //tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        DIVS:
        begin
            r1En <= 1;
            r2En <= 0;  
            tmpReg <= accumOutS;
            pc <= pc + 1;
        end

        CMPS:
        begin
            tmpReg <= accumOut;
            pc <= pc + 1;
        end
        /*CMPI:
        begin
            tmpReg <= accumOut;
            pc <= pc + 2;
        end*/
        
        default:
        begin
            rst <= 1;
        end
    endcase   
end