set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

create_clock -period 20.000 [get_ports clkIn]
create_clock [get_ports clkIn]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports clkIn]

set_property -dict { PACKAGE_PIN F19 IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN E21 IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN D20 IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN C20 IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports rst]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports enBtn]

set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports stepBtn]

#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports {intTest}];
#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { btn }];

# Faster edges on output buses (watch for ringing/EMI!)
set_property SLEW FAST [get_ports {data[7]}]
set_property SLEW FAST [get_ports {data[6]}]
set_property SLEW FAST [get_ports {data[5]}]
set_property SLEW FAST [get_ports {data[4]}]
set_property SLEW FAST [get_ports {data[3]}]
set_property SLEW FAST [get_ports {data[2]}]
set_property SLEW FAST [get_ports {data[1]}]
set_property SLEW FAST [get_ports {data[0]}]
set_property DRIVE 16 [get_ports {data[7]}]
set_property DRIVE 16 [get_ports {data[6]}]
set_property DRIVE 16 [get_ports {data[5]}]
set_property DRIVE 16 [get_ports {data[4]}]
set_property DRIVE 16 [get_ports {data[3]}]
set_property DRIVE 16 [get_ports {data[2]}]
set_property DRIVE 16 [get_ports {data[1]}]
set_property DRIVE 16 [get_ports {data[0]}]

###J9###
#set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports {hardInterrupt[0]}];
#set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports {hardInterrupt[1]}];
#set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports {hardInterrupt[2]}];
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports {hardInterrupt[3]}];

set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports {data[7]}]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {data[6]}]
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports {data[5]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {data[4]}]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {data[3]}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {data[2]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {data[1]}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {data[0]}]

#set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 } [get_ports {portA[0]}];
#set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {portA[1]}];
#set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports {portA[2]}];
#set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports {portA[3]}];
#set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS33 } [get_ports {portA[4]}];
#set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVCMOS33 } [get_ports {portA[5]}];
#set_property -dict { PACKAGE_PIN A19 IOSTANDARD LVCMOS33 } [get_ports {portA[6]}];
#set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports {portA[7]}];

#set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {portB[0]}];
#set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {portB[1]}];
#set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {portB[2]}];
#set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports {portB[3]}];
#set_property -dict { PACKAGE_PIN B20 IOSTANDARD LVCMOS33 } [get_ports {portB[4]}];
#set_property -dict { PACKAGE_PIN C18 IOSTANDARD LVCMOS33 } [get_ports {portB[5]}];
#set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {portB[6]}];
#set_property -dict { PACKAGE_PIN B17 IOSTANDARD LVCMOS33 } [get_ports {portB[7]}];


###J10###
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {deviceEn[1]}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {deviceEn[0]}]

set_property -dict { PACKAGE_PIN AA18 IOSTANDARD LVCMOS33 } [get_ports {prgmSwitch}];
set_property -dict { PACKAGE_PIN V18 IOSTANDARD LVCMOS33 } [get_ports {haltSwitch}];
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {gotoSwitch}];

set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports memoryMode]
#set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports {wrt}];
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports tx]

### J10 ###
set_property SLEW SLOW [get_ports {addressOut[*]}]
set_property DRIVE 8 [get_ports {addressOut[*]}]

set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {addressOut[0]}]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports {addressOut[1]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {addressOut[2]}]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {addressOut[3]}]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {addressOut[4]}]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports {addressOut[5]}]
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {addressOut[6]}]
set_property -dict {PACKAGE_PIN Y22 IOSTANDARD LVCMOS33} [get_ports {addressOut[7]}]
set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33} [get_ports {addressOut[8]}]
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports {addressOut[9]}]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports {addressOut[10]}]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports {addressOut[11]}]
set_property -dict {PACKAGE_PIN AB18 IOSTANDARD LVCMOS33} [get_ports {addressOut[12]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {addressOut[13]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {addressOut[14]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {addressOut[15]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {addressOut[16]}]

set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {addressOut[17]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports {addressOut[18]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {addressOut[19]}]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {addressOut[20]}]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {addressOut[21]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports {addressOut[22]}]
set_property -dict {PACKAGE_PIN W21 IOSTANDARD LVCMOS33} [get_ports {addressOut[23]}]

set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN J6 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN K6 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {seg[7]}]

set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {disp[0]}]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {disp[1]}]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports {disp[2]}]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports {disp[3]}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {disp[4]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {disp[5]}]





#set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {wrt }];

## This file is a general .xdc for the Arty A7-35 Rev. D and Rev. E
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock Signals
#set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]; #IO_L13P_T2_MRCC_15 Sch=uclk
#create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }];
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { clk }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
#create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { clk }];
#
#set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
#set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
#
##Pmod Header JA
#set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { addressOut[0] }]; #IO_L4P_T0_D04_14 Sch=ja_p[1]
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { addressOut[1] }]; #IO_L4N_T0_D05_14 Sch=ja_n[1]
#set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { addressOut[2] }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]
#set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { addressOut[3] }]; #IO_L5N_T0_D07_14 Sch=ja_n[2]
#set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { addressOut[4] }]; #IO_L7P_T1_D09_14 Sch=ja_p[3]
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { addressOut[5] }]; #IO_L7N_T1_D10_14 Sch=ja_n[3]
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { addressOut[6] }]; #IO_L8P_T1_D11_14 Sch=ja_p[4]
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { addressOut[7] }]; #IO_L8N_T1_D12_14 Sch=ja_n[4]
### Pmod Header JB
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { addressOut[8] }]; #IO_L9P_T1_DQS_14 Sch=jb_p[1]
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { addressOut[9] }]; #IO_L9N_T1_DQS_D13_14 Sch=jb_n[1]
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { addressOut[10] }]; #IO_L10P_T1_D14_14 Sch=jb_p[2]
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { addressOut[11] }]; #IO_L10N_T1_D15_14 Sch=jb_n[2]
#set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { addressOut[12] }]; #IO_L11P_T1_SRCC_14 Sch=jb_p[3]
#set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { addressOut[13] }]; #IO_L11N_T1_SRCC_14 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { addressOut[14] }]; #IO_L12P_T1_MRCC_14 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { addressOut[15] }]; #IO_L12N_T1_MRCC_14 Sch=jb_n[4]
#
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { data[0] }]; #IO_L4P_T0_D04_14 Sch=ja_p[1]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { data[1] }]; #IO_L4N_T0_D05_14 Sch=ja_n[1]
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { data[2] }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { data[3] }]; #IO_L5N_T0_D07_14 Sch=ja_n[2]
#set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { data[4] }]; #IO_L7P_T1_D09_14 Sch=ja_p[3]
#set_property -dict { PACKAGE_PIN P13   IOSTANDARD LVCMOS33 } [get_ports { data[5] }]; #IO_L7N_T1_D10_14 Sch=ja_n[3]
#set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { data[6] }]; #IO_L8P_T1_D11_14 Sch=ja_p[4]
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { data[7] }]; #IO_L8N_T1_D12_14 Sch=ja_n[4]
#
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { clkOut }]; #IO_L20N_T3_A07_D23_14 Sch=jd1/ck_io[33]
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L18N_T2_A23_15 Sch=btn[0]
#
## WRT signal
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { wrt }]; #IO_L21P_T3_DQS_14 Sch=jd2/ck_io[32]
#
### This file is a general .xdc for the Arty S7-50 Rev. E
### To use it in a project:
### - uncomment the lines corresponding to used pins
### - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
#
### Clock Signals
##set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]; #IO_L13P_T2_MRCC_15 Sch=uclk
##create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }];
##set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { CLK100MHZ }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
##create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { CLK100MHZ }];
#
### Switches
##set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L20N_T3_A19_15 Sch=sw[0]
##set_property -dict { PACKAGE_PIN H18   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L21P_T3_DQS_15 Sch=sw[1]
##set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L21N_T3_DQS_A18_15 Sch=sw[2]
##set_property -dict { PACKAGE_PIN M5    IOSTANDARD SSTL135 } [get_ports { sw[3] }]; #IO_L6N_T0_VREF_34 Sch=sw[3]
#
### RGB LEDs
##set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { led0_r }]; #IO_L23N_T3_FWE_B_15 Sch=led0_r
##set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { led0_g }]; #IO_L14N_T2_SRCC_15 Sch=led0_g
##set_property -dict { PACKAGE_PIN F15   IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L13N_T2_MRCC_15 Sch=led0_b
##set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { led1_r }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=led1_r
##set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { led1_g }]; #IO_L16P_T2_A28_15 Sch=led1_g
##set_property -dict { PACKAGE_PIN E14   IOSTANDARD LVCMOS33 } [get_ports { led1_b }]; #IO_L15P_T2_DQS_15 Sch=led1_b
#
### LEDs
##set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { led }]; #IO_L16N_T2_A27_15 Sch=led[2]
##set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L16N_T2_A27_15 Sch=led[2]
##set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L17P_T2_A26_15 Sch=led[3]
##set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_L17N_T2_A25_15 Sch=led[4]
##set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L18P_T2_A24_15 Sch=led[5]
#
### Buttons
##set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L18N_T2_A23_15 Sch=btn[0]
##set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L19P_T3_A22_15 Sch=btn[1]
##set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L19N_T3_A21_VREF_15 Sch=btn[2]
##set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L20P_T3_A20_15 Sch=btn[3]
#
### Pmod Header JA
##set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { ja[0] }]; #IO_L4P_T0_D04_14 Sch=ja_p[1]
##set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_L4N_T0_D05_14 Sch=ja_n[1]
##set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { ja[2] }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]
##set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { ja[3] }]; #IO_L5N_T0_D07_14 Sch=ja_n[2]
##set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L7P_T1_D09_14 Sch=ja_p[3]
##set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { ja[5] }]; #IO_L7N_T1_D10_14 Sch=ja_n[3]
##set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L8P_T1_D11_14 Sch=ja_p[4]
##set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L8N_T1_D12_14 Sch=ja_n[4]
#
### Pmod Header JB
##set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { jb[0] }]; #IO_L9P_T1_DQS_14 Sch=jb_p[1]
##set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { jb[1] }]; #IO_L9N_T1_DQS_D13_14 Sch=jb_n[1]
##set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { jb[2] }]; #IO_L10P_T1_D14_14 Sch=jb_p[2]
##set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { jb[3] }]; #IO_L10N_T1_D15_14 Sch=jb_n[2]
##set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { jb[4] }]; #IO_L11P_T1_SRCC_14 Sch=jb_p[3]
##set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { jb[5] }]; #IO_L11N_T1_SRCC_14 Sch=jb_n[3]
##set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { jb[6] }]; #IO_L12P_T1_MRCC_14 Sch=jb_p[4]
##set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { jb[7] }]; #IO_L12N_T1_MRCC_14 Sch=jb_n[4]
#
### Pmod Header JC
##set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { jc[0] }]; #IO_L18P_T2_A12_D28_14 Sch=jc1/ck_io[41]
##set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { jc[1] }]; #IO_L18N_T2_A11_D27_14 Sch=jc2/ck_io[40]
##set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { jc[2] }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=jc3/ck_io[39]
##set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { jc[3] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=jc4/ck_io[38]
##set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { jc[4] }]; #IO_L16P_T2_CSI_B_14 Sch=jc7/ck_io[37]
##set_property -dict { PACKAGE_PIN P13   IOSTANDARD LVCMOS33 } [get_ports { jc[5] }]; #IO_L19P_T3_A10_D26_14 Sch=jc8/ck_io[36]
##set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { jc[6] }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=jc9/ck_io[35]
##set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { jc[7] }]; #IO_L20P_T3_A08_D24_14 Sch=jc10/ck_io[34]
#
### Pmod Header JD
##set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { jd[0] }]; #IO_L20N_T3_A07_D23_14 Sch=jd1/ck_io[33]
##set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { jd[1] }]; #IO_L21P_T3_DQS_14 Sch=jd2/ck_io[32]
##set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { jd[2] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=jd3/ck_io[31]
##set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { jd[3] }]; #IO_L22P_T3_A05_D21_14 Sch=jd4/ck_io[30]
##set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { jd[4] }]; #IO_L22N_T3_A04_D20_14 Sch=jd7/ck_io[29]
##set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { jd[5] }]; #IO_L23P_T3_A03_D19_14 Sch=jd8/ck_io[28]
##set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { jd[6] }]; #IO_L23N_T3_A02_D18_14 Sch=jd9/ck_io[27]
##set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { jd[7] }]; #IO_L24P_T3_A01_D17_14 Sch=jd10/ck_io[26]
#
### USB-UART Interface
##set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd_out }]; #IO_25_14 Sch=uart_rxd_out
##set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { uart_txd_in }]; #IO_L24N_T3_A00_D16_14 Sch=uart_txd_in
#
### ChipKit Outer Digital Header
##set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { ck_io0 }]; #IO_0_14 Sch=ck_io[0]
##set_property -dict { PACKAGE_PIN N13   IOSTANDARD LVCMOS33 } [get_ports { ck_io1 }]; #IO_L6N_T0_D08_VREF_14   Sch=ck_io[1]
##set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { ck_io2 }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=ck_io[2]
##set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { ck_io3 }]; #IO_L13P_T2_MRCC_14      Sch=ck_io[3]
##set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { ck_io4 }]; #IO_L13N_T2_MRCC_14      Sch=ck_io[4]
##set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ck_io5 }]; #IO_L14P_T2_SRCC_14      Sch=ck_io[5]
##set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ck_io6 }]; #IO_L14N_T2_SRCC_14      Sch=ck_io[6]
##set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { ck_io7 }]; #IO_L16N_T2_A15_D31_14   Sch=ck_io[7]
##set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { ck_io8 }]; #IO_L17P_T2_A14_D30_14   Sch=ck_io[8]
##set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { ck_io9 }]; #IO_L17N_T2_A13_D29_14   Sch=ck_io[9]
#
### ChipKit SPI Header
### NOTE: The ChipKit SPI header ports can also be used as digital I/O and share FPGA pins with ck_io10-13. Do not use both at the same time.
##set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { ck_io10_ss   }]; #IO_L22P_T3_A17_15   Sch=ck_io10_ss
##set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { ck_io11_mosi }]; #IO_L22N_T3_A16_15   Sch=ck_io11_mosi
##set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { ck_io12_miso }]; #IO_L23P_T3_FOE_B_15 Sch=ck_io12_miso
##set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { ck_io13_sck  }]; #IO_L14P_T2_SRCC_15  Sch=ck_io13_sck
#
### ChipKit Inner Digital Header
### Note: these pins are shared with PMOD Headers JC and JD and cannot be used at the same time as the applicable PMOD interface(s)
##set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { ck_io26 }]; #IO_L24P_T3_A01_D17_14        Sch=jd10/ck_io[26]
##set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { ck_io27 }]; #IO_L23N_T3_A02_D18_14        Sch=jd9/ck_io[27]
##set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { ck_io28 }]; #IO_L23P_T3_A03_D19_14        Sch=jd8/ck_io[28]
##set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { ck_io29 }]; #IO_L22N_T3_A04_D20_14        Sch=jd7/ck_io[29]
##set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { ck_io30 }]; #IO_L22P_T3_A05_D21_14        Sch=jd4/ck_io[30]
##set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { ck_io31 }]; #IO_L21N_T3_DQS_A06_D22_14    Sch=jd3/ck_io[31]
##set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { ck_io32 }]; #IO_L21P_T3_DQS_14            Sch=jd2/ck_io[32]
##set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { ck_io33 }]; #IO_L20N_T3_A07_D23_14        Sch=jd1/ck_io[33]
##set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { ck_io34 }]; #IO_L20P_T3_A08_D24_14        Sch=jc10/ck_io[34]
##set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { ck_io35 }]; #IO_L19N_T3_A09_D25_VREF_14   Sch=jc9/ck_io[35]
##set_property -dict { PACKAGE_PIN P13   IOSTANDARD LVCMOS33 } [get_ports { ck_io36 }]; #IO_L19P_T3_A10_D26_14        Sch=jc8/ck_io[36]
##set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { ck_io37 }]; #IO_L16P_T2_CSI_B_14          Sch=jc7/ck_io[37]
##set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { ck_io38 }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=jc4/ck_io[38]
##set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { ck_io39 }]; #IO_L15P_T2_DQS_RDWR_B_14     Sch=jc3/ck_io[39]
##set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { ck_io40 }]; #IO_L18N_T2_A11_D27_14        Sch=jc2/ck_io[40]
##set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { ck_io41 }]; #IO_L18P_T2_A12_D28_14        Sch=jc1/ck_io[41]
#
### Dedicated Analog Inputs
##set_property -dict { PACKAGE_PIN J10   } [get_ports { vp_in }]; #IO_L1P_T0_AD4P_35 Sch=v_p
##set_property -dict { PACKAGE_PIN K9    } [get_ports { vn_in }]; #IO_L1N_T0_AD4N_35 Sch=v_n
#
### ChipKit Outer Analog Header - as Single-Ended Analog Inputs
### NOTE: These ports can be used as single-ended analog inputs with voltages from 0-3.3V (ChipKit analog pins A0-A5) or as digital I/O.
### WARNING: Do not use both sets of constraints at the same time!
### NOTE: The following constraints should be used with the XADC IP core when using these ports as analog inputs.
##set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVCMOS33 } [get_ports { vaux0_p  }]; #IO_L1P_T0_AD0P_15     Sch=ck_an_p[0]   ChipKit pin=A0
##set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports { vaux0_n  }]; #IO_L1N_T0_AD0N_15     Sch=ck_an_n[0]   ChipKit pin=A0
##set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports { vaux1_p  }]; #IO_L3P_T0_DQS_AD1P_15 Sch=ck_an_p[1]   ChipKit pin=A1
##set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports { vaux1_n  }]; #IO_L3N_T0_DQS_AD1N_15 Sch=ck_an_n[1]   ChipKit pin=A1
##set_property -dict { PACKAGE_PIN E12   IOSTANDARD LVCMOS33 } [get_ports { vaux9_p  }]; #IO_L5P_T0_AD9P_15     Sch=ck_an_p[2]   ChipKit pin=A2
##set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { vaux9_n  }]; #IO_L5N_T0_AD9N_15     Sch=ck_an_n[2]   ChipKit pin=A2
##set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { vaux2_p  }]; #IO_L7P_T1_AD2P_15     Sch=ck_an_p[3]   ChipKit pin=A3
##set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { vaux2_n  }]; #IO_L7N_T1_AD2N_15     Sch=ck_an_n[3]   ChipKit pin=A3
##set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { vaux10_p }]; #IO_L8P_T1_AD10P_15    Sch=ck_an_p[4]   ChipKit pin=A4
##set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { vaux10_n }]; #IO_L8N_T1_AD10N_15    Sch=ck_an_n[4]   ChipKit pin=A4
##set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { vaux11_p }]; #IO_L10P_T1_AD11P_15   Sch=ck_an_p[5]   ChipKit pin=A5
##set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { vaux11_n }]; #IO_L10N_T1_AD11N_15   Sch=ck_an_n[5]   ChipKit pin=A5
### ChipKit Outer Analog Header - as Digital I/O
### NOTE: The following constraints should be used when using these ports as digital I/O.
##set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { ck_a0 }]; #IO_0_15            Sch=ck_a[0]
##set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { ck_a1 }]; #IO_L4P_T0_15       Sch=ck_a[1]
##set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports { ck_a2 }]; #IO_L4N_T0_15       Sch=ck_a[2]
##set_property -dict { PACKAGE_PIN C13   IOSTANDARD LVCMOS33 } [get_ports { ck_a3 }]; #IO_L6P_T0_15       Sch=ck_a[3]
##set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { ck_a4 }]; #IO_L6N_T0_VREF_15  Sch=ck_a[4]
##set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { ck_a5 }]; #IO_L11P_T1_SRCC_15 Sch=ck_a[5]
#
### ChipKit Inner Analog Header - as Differential Analog Inputs
### NOTE: These ports can be used as differential analog inputs with voltages from 0-1.0V (ChipKit analog pins A6-A11) or as digital I/O.
### WARNING: Do not use both sets of constraints at the same time!
### NOTE: The following constraints should be used with the XADC core when using these ports as analog inputs.
##set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS33 } [get_ports { vaux8_p }]; #IO_L2P_T0_AD8P_15     Sch=ad_p[8]   ChipKit pin=A6
##set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports { vaux8_n }]; #IO_L2N_T0_AD8N_15     Sch=ad_n[8]   ChipKit pin=A7
##set_property -dict { PACKAGE_PIN D16   IOSTANDARD LVCMOS33 } [get_ports { vaux3_p }]; #IO_L9P_T1_DQS_AD3P_15 Sch=ad_p[3]   ChipKit pin=A8
##set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { vaux3_n }]; #IO_L9N_T1_DQS_AD3N_15 Sch=ad_n[3]   ChipKit pin=A9
### ChipKit Inner Analog Header - as Digital I/O
### NOTE: The following constraints should be used when using the inner analog header ports as digital I/O.
##set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS33 } [get_ports { ck_a6  }]; #IO_L2P_T0_AD8P_15     Sch=ad_p[8]
##set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports { ck_a7  }]; #IO_L2N_T0_AD8N_15     Sch=ad_n[8]
##set_property -dict { PACKAGE_PIN D16   IOSTANDARD LVCMOS33 } [get_ports { ck_a8  }]; #IO_L9P_T1_DQS_AD3P_15 Sch=ad_p[3]
##set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { ck_a9  }]; #IO_L9N_T1_DQS_AD3N_15 Sch=ad_n[3]
##set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { ck_a10 }]; #IO_L12P_T1_MRCC_15    Sch=ck_a10_r   (Cannot be used as an analog input)
##set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { ck_a11 }]; #IO_L12N_T1_MRCC_15    Sch=ck_a11_r   (Cannot be used as an analog input)
#
### ChipKit I2C
##set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { ck_scl }]; #IO_L24N_T3_RS0_15 Sch=ck_scl
##set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { ck_sda }]; #IO_L24P_T3_RS1_15 Sch=ck_sda
#
### Misc. ChipKit Ports
##set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { ck_ioa }]; #IO_25_15 Sch=ck_ioa
##set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports { ck_rst }]; #IO_L11N_T1_SRCC_15
#
### Quad SPI Flash
### Note: the SCK clock signal can be driven using the STARTUPE2 primitive
##set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { qspi_cs }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
##set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
##set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
##set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
##set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { qspi_dq[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]
#
### Configuration options, can be used for all designs
#set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
#set_property CONFIG_VOLTAGE 3.3 [current_design]
#set_property CFGBVS VCCO [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property CONFIG_MODE SPIx4 [current_design]
#
### SW3 is assigned to a pin M5 in the 1.35v bank. This pin can also be used as
### the VREF for BANK 34. To ensure that SW3 does not define the reference voltage
### and to be able to use this pin as an ordinary I/O the following property must
### be set to enable an internal VREF for BANK 34. Since a 1.35v supply is being
### used the internal reference is set to half that value (i.e. 0.675v). Note that
### this property must be set even if SW3 is not used in the design.
#set_property INTERNAL_VREF 0.675 [get_iobanks 34]




















connect_debug_port u_ila_0/probe13 [get_nets [list clkEn]]




connect_debug_port u_ila_0/probe13 [get_nets [list clk]]










create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clkIn_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {control/exceptNum[0]} {control/exceptNum[1]} {control/exceptNum[2]} {control/exceptNum[3]} {control/exceptNum[4]} {control/exceptNum[5]} {control/exceptNum[6]} {control/exceptNum[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {control/mdr[0]} {control/mdr[1]} {control/mdr[2]} {control/mdr[3]} {control/mdr[4]} {control/mdr[5]} {control/mdr[6]} {control/mdr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {control/instruction[0]} {control/instruction[1]} {control/instruction[2]} {control/instruction[3]} {control/instruction[4]} {control/instruction[5]} {control/instruction[6]} {control/instruction[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 24 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {control/mar[0]} {control/mar[1]} {control/mar[2]} {control/mar[3]} {control/mar[4]} {control/mar[5]} {control/mar[6]} {control/mar[7]} {control/mar[8]} {control/mar[9]} {control/mar[10]} {control/mar[11]} {control/mar[12]} {control/mar[13]} {control/mar[14]} {control/mar[15]} {control/mar[16]} {control/mar[17]} {control/mar[18]} {control/mar[19]} {control/mar[20]} {control/mar[21]} {control/mar[22]} {control/mar[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 24 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {control/stackFramePointer[0]} {control/stackFramePointer[1]} {control/stackFramePointer[2]} {control/stackFramePointer[3]} {control/stackFramePointer[4]} {control/stackFramePointer[5]} {control/stackFramePointer[6]} {control/stackFramePointer[7]} {control/stackFramePointer[8]} {control/stackFramePointer[9]} {control/stackFramePointer[10]} {control/stackFramePointer[11]} {control/stackFramePointer[12]} {control/stackFramePointer[13]} {control/stackFramePointer[14]} {control/stackFramePointer[15]} {control/stackFramePointer[16]} {control/stackFramePointer[17]} {control/stackFramePointer[18]} {control/stackFramePointer[19]} {control/stackFramePointer[20]} {control/stackFramePointer[21]} {control/stackFramePointer[22]} {control/stackFramePointer[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {control/state[0]} {control/state[1]} {control/state[2]} {control/state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 24 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {control/retAddrDbg[0]} {control/retAddrDbg[1]} {control/retAddrDbg[2]} {control/retAddrDbg[3]} {control/retAddrDbg[4]} {control/retAddrDbg[5]} {control/retAddrDbg[6]} {control/retAddrDbg[7]} {control/retAddrDbg[8]} {control/retAddrDbg[9]} {control/retAddrDbg[10]} {control/retAddrDbg[11]} {control/retAddrDbg[12]} {control/retAddrDbg[13]} {control/retAddrDbg[14]} {control/retAddrDbg[15]} {control/retAddrDbg[16]} {control/retAddrDbg[17]} {control/retAddrDbg[18]} {control/retAddrDbg[19]} {control/retAddrDbg[20]} {control/retAddrDbg[21]} {control/retAddrDbg[22]} {control/retAddrDbg[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {control/cycleCount[0]} {control/cycleCount[1]} {control/cycleCount[2]} {control/cycleCount[3]} {control/cycleCount[4]} {control/cycleCount[5]} {control/cycleCount[6]} {control/cycleCount[7]} {control/cycleCount[8]} {control/cycleCount[9]} {control/cycleCount[10]} {control/cycleCount[11]} {control/cycleCount[12]} {control/cycleCount[13]} {control/cycleCount[14]} {control/cycleCount[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {control/r1Out[0]} {control/r1Out[1]} {control/r1Out[2]} {control/r1Out[3]} {control/r1Out[4]} {control/r1Out[5]} {control/r1Out[6]} {control/r1Out[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 24 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {addressOutDbg[0]} {addressOutDbg[1]} {addressOutDbg[2]} {addressOutDbg[3]} {addressOutDbg[4]} {addressOutDbg[5]} {addressOutDbg[6]} {addressOutDbg[7]} {addressOutDbg[8]} {addressOutDbg[9]} {addressOutDbg[10]} {addressOutDbg[11]} {addressOutDbg[12]} {addressOutDbg[13]} {addressOutDbg[14]} {addressOutDbg[15]} {addressOutDbg[16]} {addressOutDbg[17]} {addressOutDbg[18]} {addressOutDbg[19]} {addressOutDbg[20]} {addressOutDbg[21]} {addressOutDbg[22]} {addressOutDbg[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 2 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {deviceEnDbg[0]} {deviceEnDbg[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 8 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {uartStore[0]} {uartStore[1]} {uartStore[2]} {uartStore[3]} {uartStore[4]} {uartStore[5]} {uartStore[6]} {uartStore[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 8 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {r1[0]} {r1[1]} {r1[2]} {r1[3]} {r1[4]} {r1[5]} {r1[6]} {r1[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 8 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {dataOutDbg[0]} {dataOutDbg[1]} {dataOutDbg[2]} {dataOutDbg[3]} {dataOutDbg[4]} {dataOutDbg[5]} {dataOutDbg[6]} {dataOutDbg[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 32 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {clkCnt[0]} {clkCnt[1]} {clkCnt[2]} {clkCnt[3]} {clkCnt[4]} {clkCnt[5]} {clkCnt[6]} {clkCnt[7]} {clkCnt[8]} {clkCnt[9]} {clkCnt[10]} {clkCnt[11]} {clkCnt[12]} {clkCnt[13]} {clkCnt[14]} {clkCnt[15]} {clkCnt[16]} {clkCnt[17]} {clkCnt[18]} {clkCnt[19]} {clkCnt[20]} {clkCnt[21]} {clkCnt[22]} {clkCnt[23]} {clkCnt[24]} {clkCnt[25]} {clkCnt[26]} {clkCnt[27]} {clkCnt[28]} {clkCnt[29]} {clkCnt[30]} {clkCnt[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 8 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {dataDbg[0]} {dataDbg[1]} {dataDbg[2]} {dataDbg[3]} {dataDbg[4]} {dataDbg[5]} {dataDbg[6]} {dataDbg[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 24 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {pc[0]} {pc[1]} {pc[2]} {pc[3]} {pc[4]} {pc[5]} {pc[6]} {pc[7]} {pc[8]} {pc[9]} {pc[10]} {pc[11]} {pc[12]} {pc[13]} {pc[14]} {pc[15]} {pc[16]} {pc[17]} {pc[18]} {pc[19]} {pc[20]} {pc[21]} {pc[22]} {pc[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 8 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {dataInDbg[0]} {dataInDbg[1]} {dataInDbg[2]} {dataInDbg[3]} {dataInDbg[4]} {dataInDbg[5]} {dataInDbg[6]} {dataInDbg[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list clkEn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list enBtnDbg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list memoryModeDbg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list uartSend]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clkIn_IBUF_BUFG]
