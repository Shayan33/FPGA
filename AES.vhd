----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:36:31 06/28/2016 
-- Design Name: 
-- Module Name:    AES - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_SIGNED.ALL; 
use IEEE.std_logic_textio.all;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AES is
port(clk,rst : in std_logic;
		d_out_0 : out std_logic_vector(7 downto 0);
		d_out_1 : out std_logic_vector(7 downto 0);
		d_out_2 : out std_logic_vector(7 downto 0);
		d_out_3 : out std_logic_vector(7 downto 0);
		d_out_4 : out std_logic_vector(7 downto 0);
		d_out_5 : out std_logic_vector(7 downto 0);
		d_out_6 : out std_logic_vector(7 downto 0);
		d_out_7 : out std_logic_vector(7 downto 0);
		d_out_8 : out std_logic_vector(7 downto 0);
		d_out_9 : out std_logic_vector(7 downto 0);
		d_out_10 : out std_logic_vector(7 downto 0);
		d_out_11 : out std_logic_vector(7 downto 0);
		d_out_12 : out std_logic_vector(7 downto 0);
		d_out_13 : out std_logic_vector(7 downto 0);
		d_out_14 : out std_logic_vector(7 downto 0);
		d_out_15 : out std_logic_vector(7 downto 0));
end AES;

architecture Behavioral of AES is



type state is (Load,Save,AddRoundReg,SubBytes,ShiftRows,MixColumns,finish ); 
signal pr_state,nx_state: state;
type matris_4_4 is array (0 to 15) of std_logic_vector(7 downto 0);
type matris_16_16 is array (0 to 255) of std_logic_vector(7 downto 0);
type vector_10 is array (0 to 9) of std_logic_vector(7 downto 0);
signal input,key,new_key,temp_key,current_key,After_AddRoundReg,After_SubBytes,After_ShiftRows,After_MixColumns,current : matris_4_4;

signal level : integer :=-1 ;
signal finish_flag,load_flag : std_logic ;
constant SBOX        :  matris_16_16 :=   (
                                             x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5", x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
                                             x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
                                             x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
                                             x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
                                             x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
                                             x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
                                             x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
                                             x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
                                             x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
                                             x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
                                             x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
                                             x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
                                             x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
                                             x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
                                             x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
                                             x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16"
                                             );

constant R_con : vector_10 :=  (x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36");

begin



p1_sequential_section: process(clk)

begin

if(clk'event and clk='1') then 
if rst='1' then 
pr_state<=load;
level <= 0;
else 
if(nx_state = AddRoundReg) then 
level <= level + 1;

new_key <= temp_key ;end if;

pr_state<=nx_state;

 
end if;end if;

end process;




p2_combinational_section:process(pr_state,finish_flag,level) 

begin
case pr_state is
 
when load=>
nx_state<= AddRoundReg;

when AddRoundReg => 
if (finish_flag = '1') then nx_state<= finish;
elsif (level mod 11 = 0 and level /=0) then nx_state<= save; 
else nx_state<= SubBytes;end if;

when SubBytes =>
nx_state<= ShiftRows;

when ShiftRows =>
nx_state<=MixColumns;

when MixColumns =>
nx_state<=AddRoundReg;

when Save =>
nx_state<=Load;



when others=>
--nx_state<=load; 
end case;
end process;




p3_load : process(clk)
file INFILE : text is in "mahmood.txt";
file INFILE2 : text is in "key.txt"; 
variable QDATA : std_logic_vector(7 downto 0);
variable IN_LINE : line;
variable IN_LINE2 : line;
begin
if (clk'event and clk='1') then
if (pr_state = Load) and (load_flag = '1')  then

if (not(endfile(INFILE)))  then

readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(0) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(1) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(2) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(3) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(4) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(5) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(6) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(7) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(8) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(9) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(10) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(11) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(12) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(13) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(14) <=  QDATA;
readline(INFILE, IN_LINE); 
hread(IN_LINE, QDATA);
input(15) <=  QDATA; 

if(level =0)then
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(0) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(1) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(2) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(3) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(4) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(5) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(6) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(7) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(8) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(9) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(10) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(11) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(12) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(13) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(14) <=  QDATA;
readline(INFILE2, IN_LINE2); 
hread(IN_LINE2, QDATA);
key(15) <=  QDATA;
end if;

else finish_flag <= '1';
end if;


end if; 
end if; 
end process;

p4_AddRoundReg : process(clk)
begin
if(clk'event and clk='1') then
if(pr_state = AddRoundReg)then
if(level mod 11 =0)then
After_AddRoundReg(0) <= After_MixColumns(0) xor new_key(0);
After_AddRoundReg(1) <= After_MixColumns(1) xor new_key(1);
After_AddRoundReg(2) <= After_MixColumns(2) xor new_key(2);
After_AddRoundReg(3) <= After_MixColumns(3) xor new_key(3);
After_AddRoundReg(4) <= After_MixColumns(4) xor new_key(4);
After_AddRoundReg(5) <= After_MixColumns(5) xor new_key(5);
After_AddRoundReg(6) <= After_MixColumns(6) xor new_key(6);
After_AddRoundReg(7) <= After_MixColumns(7) xor new_key(7);
After_AddRoundReg(8) <= After_MixColumns(8) xor new_key(8);
After_AddRoundReg(9) <= After_MixColumns(9) xor new_key(9);
After_AddRoundReg(10) <= After_MixColumns(10) xor new_key(10);
After_AddRoundReg(11) <= After_MixColumns(11) xor new_key(11);
After_AddRoundReg(12) <= After_MixColumns(12) xor new_key(12);
After_AddRoundReg(13) <= After_MixColumns(13) xor new_key(13);
After_AddRoundReg(14) <= After_MixColumns(14) xor new_key(14);
After_AddRoundReg(15) <= After_MixColumns(15) xor new_key(15);
else
After_AddRoundReg(0) <= current(0) xor current_key(0);
After_AddRoundReg(1) <= current(1) xor current_key(1);
After_AddRoundReg(2) <= current(2) xor current_key(2);
After_AddRoundReg(3) <= current(3) xor current_key(3);
After_AddRoundReg(4) <= current(4) xor current_key(4);
After_AddRoundReg(5) <= current(5) xor current_key(5);
After_AddRoundReg(6) <= current(6) xor current_key(6);
After_AddRoundReg(7) <= current(7) xor current_key(7);
After_AddRoundReg(8) <= current(8) xor current_key(8);
After_AddRoundReg(9) <= current(9) xor current_key(9);
After_AddRoundReg(10) <= current(10) xor current_key(10);
After_AddRoundReg(11) <= current(11) xor current_key(11);
After_AddRoundReg(12) <= current(12) xor current_key(12);
After_AddRoundReg(13) <= current(13) xor current_key(13);
After_AddRoundReg(14) <= current(14) xor current_key(14);
After_AddRoundReg(15) <= current(15) xor current_key(15);
end if;

end if; 
end if;
end process;

p5_SubBytes : process(clk)
variable key_calc : matris_4_4;
variable key_old : matris_4_4;
begin 
if(clk'event and clk='1') then
if(pr_state = SubBytes)then
After_SubBytes(0) <= SBOX(conv_integer(unsigned(After_AddRoundReg(0))));
After_SubBytes(1) <= SBOX(conv_integer(unsigned(After_AddRoundReg(1))));
After_SubBytes(2) <= SBOX(conv_integer(unsigned(After_AddRoundReg(2))));
After_SubBytes(3) <= SBOX(conv_integer(unsigned(After_AddRoundReg(3))));
After_SubBytes(4) <= SBOX(conv_integer(unsigned(After_AddRoundReg(4))));
After_SubBytes(5) <= SBOX(conv_integer(unsigned(After_AddRoundReg(5))));
After_SubBytes(6) <= SBOX(conv_integer(unsigned(After_AddRoundReg(6))));
After_SubBytes(7) <= SBOX(conv_integer(unsigned(After_AddRoundReg(7))));
After_SubBytes(8) <= SBOX(conv_integer(unsigned(After_AddRoundReg(8))));
After_SubBytes(9) <= SBOX(conv_integer(unsigned(After_AddRoundReg(9))));
After_SubBytes(10) <= SBOX(conv_integer(unsigned(After_AddRoundReg(10))));
After_SubBytes(11) <= SBOX(conv_integer(unsigned(After_AddRoundReg(11))));
After_SubBytes(12) <= SBOX(conv_integer(unsigned(After_AddRoundReg(12))));
After_SubBytes(13) <= SBOX(conv_integer(unsigned(After_AddRoundReg(13))));
After_SubBytes(14) <= SBOX(conv_integer(unsigned(After_AddRoundReg(14))));
After_SubBytes(15) <= SBOX(conv_integer(unsigned(After_AddRoundReg(15))));

if(level mod 11 = 1 or level = 1) then key_old := key; else key_old := new_key;end if;

key_calc(0) := SBOX(conv_integer(unsigned(key_old(13)))) xor key_old(0) xor R_con((level mod 11)-1);
key_calc(1) := SBOX(conv_integer(unsigned(key_old(14)))) xor key_old(1) ;
key_calc(2) := SBOX(conv_integer(unsigned(key_old(15)))) xor key_old(2) ;
key_calc(3) := SBOX(conv_integer(unsigned(key_old(12)))) xor key_old(3) ;


key_calc(4) := key_calc(0) xor key_old(4) ;
key_calc(5) := key_calc(1) xor key_old(5) ;
key_calc(6) := key_calc(2) xor key_old(6) ;
key_calc(7) := key_calc(3) xor key_old(7) ;

key_calc(8) := key_calc(4) xor key_old(8) ;
key_calc(9) := key_calc(5) xor key_old(9) ;
key_calc(10) := key_calc(6) xor key_old(10) ;
key_calc(11) := key_calc(7) xor key_old(11) ;

key_calc(12) := key_calc(8) xor key_old(12) ;
key_calc(13) := key_calc(9) xor key_old(13) ;
key_calc(14) := key_calc(10) xor key_old(14) ;
key_calc(15) := key_calc(11) xor key_old(15) ;

temp_key <= key_calc;

end if; 
end if;
end process;

p6_ShiftRows : process(clk)
begin
if(clk'event and clk='1') then
if(pr_state = ShiftRows)then
After_ShiftRows(0) <= After_SubBytes(0);
After_ShiftRows(1) <= After_SubBytes(5);
After_ShiftRows(2) <= After_SubBytes(10);
After_ShiftRows(3) <= After_SubBytes(15);
After_ShiftRows(4) <= After_SubBytes(4);
After_ShiftRows(5) <= After_SubBytes(9);
After_ShiftRows(6) <= After_SubBytes(14);
After_ShiftRows(7) <= After_SubBytes(3);
After_ShiftRows(8) <= After_SubBytes(8);
After_ShiftRows(9) <= After_SubBytes(13);
After_ShiftRows(10) <= After_SubBytes(2);
After_ShiftRows(11) <= After_SubBytes(7);
After_ShiftRows(12) <= After_SubBytes(12);
After_ShiftRows(13) <= After_SubBytes(1);
After_ShiftRows(14) <= After_SubBytes(6);
After_ShiftRows(15) <= After_SubBytes(11);

end if; 
end if;
end process;

p6_MixColumns : process(clk)
begin
if(clk'event and clk='1') then
if(pr_state = MixColumns)then
if(level mod 11 =10)then After_MixColumns <= After_ShiftRows; else
if((After_ShiftRows(0)(7) xor After_ShiftRows(1)(7)) = '0') then After_MixColumns(0) <= After_ShiftRows(0)(6 downto 0)& '0' xor After_ShiftRows(1) xor After_ShiftRows(1) (6 downto 0) &'0' xor After_ShiftRows(2) xor After_ShiftRows(3); 
else After_MixColumns(0) <= After_ShiftRows(0)(6 downto 0)& '0' xor After_ShiftRows(1) xor After_ShiftRows(1) (6 downto 0) &'0' xor After_ShiftRows(2) xor After_ShiftRows(3) xor x"1b";end if;

if((After_ShiftRows(1)(7) xor After_ShiftRows(2)(7)) = '0') then After_MixColumns(1) <= After_ShiftRows(1)(6 downto 0)& '0' xor After_ShiftRows(2) xor After_ShiftRows(2) (6 downto 0) &'0' xor After_ShiftRows(0) xor After_ShiftRows(3); 
else After_MixColumns(1) <= After_ShiftRows(1)(6 downto 0)& '0' xor After_ShiftRows(2) xor After_ShiftRows(2) (6 downto 0) &'0' xor After_ShiftRows(0) xor After_ShiftRows(3)xor x"1b";end if;

if((After_ShiftRows(2)(7) xor After_ShiftRows(3)(7)) = '0') then After_MixColumns(2) <= After_ShiftRows(2)(6 downto 0)& '0' xor After_ShiftRows(3) xor After_ShiftRows(3) (6 downto 0) &'0' xor After_ShiftRows(0) xor After_ShiftRows(1); 
else After_MixColumns(2) <= After_ShiftRows(2)(6 downto 0)& '0' xor After_ShiftRows(3) xor After_ShiftRows(3) (6 downto 0) &'0' xor After_ShiftRows(0) xor After_ShiftRows(1)xor x"1b";end if;

if((After_ShiftRows(0)(7) xor After_ShiftRows(3)(7)) = '0') then After_MixColumns(3) <= After_ShiftRows(3)(6 downto 0)& '0' xor After_ShiftRows(0) xor After_ShiftRows(0) (6 downto 0) &'0' xor After_ShiftRows(1) xor After_ShiftRows(2); 
else After_MixColumns(3) <= After_ShiftRows(3)(6 downto 0)& '0' xor After_ShiftRows(0) xor After_ShiftRows(0) (6 downto 0) &'0' xor After_ShiftRows(1) xor After_ShiftRows(2)xor x"1b";end if;

if((After_ShiftRows(4)(7) xor After_ShiftRows(5)(7)) = '0') then After_MixColumns(4) <= After_ShiftRows(4)(6 downto 0)& '0' xor After_ShiftRows(5) xor After_ShiftRows(5) (6 downto 0) &'0' xor After_ShiftRows(6) xor After_ShiftRows(7); 
else After_MixColumns(4) <= After_ShiftRows(4)(6 downto 0)& '0' xor After_ShiftRows(5) xor After_ShiftRows(5) (6 downto 0) &'0' xor After_ShiftRows(6) xor After_ShiftRows(7)xor x"1b";end if;

if((After_ShiftRows(5)(7) xor After_ShiftRows(6)(7)) = '0') then After_MixColumns(5) <= After_ShiftRows(5)(6 downto 0)& '0' xor After_ShiftRows(6) xor After_ShiftRows(6) (6 downto 0) &'0' xor After_ShiftRows(4) xor After_ShiftRows(7); 
else After_MixColumns(5) <= After_ShiftRows(5)(6 downto 0)& '0' xor After_ShiftRows(6) xor After_ShiftRows(6) (6 downto 0) &'0' xor After_ShiftRows(4) xor After_ShiftRows(7)xor x"1b";end if;

if((After_ShiftRows(6)(7) xor After_ShiftRows(7)(7)) = '0') then After_MixColumns(6) <= After_ShiftRows(6)(6 downto 0)& '0' xor After_ShiftRows(7) xor After_ShiftRows(7) (6 downto 0) &'0' xor After_ShiftRows(4) xor After_ShiftRows(5); 
else After_MixColumns(6) <= After_ShiftRows(6)(6 downto 0)& '0' xor After_ShiftRows(7) xor After_ShiftRows(7) (6 downto 0) &'0' xor After_ShiftRows(4) xor After_ShiftRows(5)xor x"1b";end if;

if((After_ShiftRows(4)(7) xor After_ShiftRows(7)(7)) = '0') then After_MixColumns(7) <= After_ShiftRows(7)(6 downto 0)& '0' xor After_ShiftRows(4) xor After_ShiftRows(4) (6 downto 0) &'0' xor After_ShiftRows(5) xor After_ShiftRows(6); 
else After_MixColumns(7) <= After_ShiftRows(7)(6 downto 0)& '0' xor After_ShiftRows(4) xor After_ShiftRows(4) (6 downto 0) &'0' xor After_ShiftRows(5) xor After_ShiftRows(6)xor x"1b";end if;

if((After_ShiftRows(8)(7) xor After_ShiftRows(9)(7)) = '0') then After_MixColumns(8) <= After_ShiftRows(8)(6 downto 0)& '0' xor After_ShiftRows(9) xor After_ShiftRows(9) (6 downto 0) &'0' xor After_ShiftRows(10) xor After_ShiftRows(11); 
else After_MixColumns(8) <= After_ShiftRows(8)(6 downto 0)& '0' xor After_ShiftRows(9) xor After_ShiftRows(9) (6 downto 0) &'0' xor After_ShiftRows(10) xor After_ShiftRows(11)xor x"1b";end if;

if((After_ShiftRows(9)(7) xor After_ShiftRows(10)(7)) = '0') then After_MixColumns(9) <= After_ShiftRows(9)(6 downto 0)& '0' xor After_ShiftRows(10) xor After_ShiftRows(10) (6 downto 0) &'0' xor After_ShiftRows(8) xor After_ShiftRows(11); 
else After_MixColumns(9) <= After_ShiftRows(9)(6 downto 0)& '0' xor After_ShiftRows(10) xor After_ShiftRows(10) (6 downto 0) &'0' xor After_ShiftRows(8) xor After_ShiftRows(11)xor x"1b";end if;

if((After_ShiftRows(10)(7) xor After_ShiftRows(11)(7)) = '0') then After_MixColumns(10) <= After_ShiftRows(10)(6 downto 0)& '0' xor After_ShiftRows(11) xor After_ShiftRows(11) (6 downto 0) &'0' xor After_ShiftRows(8) xor After_ShiftRows(9); 
else After_MixColumns(10) <= After_ShiftRows(10)(6 downto 0)& '0' xor After_ShiftRows(11) xor After_ShiftRows(11) (6 downto 0) &'0' xor After_ShiftRows(8) xor After_ShiftRows(9)xor x"1b";end if;

if((After_ShiftRows(8)(7) xor After_ShiftRows(11)(7)) = '0') then After_MixColumns(11) <= After_ShiftRows(11)(6 downto 0)& '0' xor After_ShiftRows(8) xor After_ShiftRows(8) (6 downto 0) &'0' xor After_ShiftRows(9) xor After_ShiftRows(10); 
else After_MixColumns(11) <= After_ShiftRows(11)(6 downto 0)& '0' xor After_ShiftRows(8) xor After_ShiftRows(8) (6 downto 0) &'0' xor After_ShiftRows(9) xor After_ShiftRows(10)xor x"1b";end if;

if((After_ShiftRows(12)(7) xor After_ShiftRows(13)(7)) = '0') then After_MixColumns(12) <= After_ShiftRows(12)(6 downto 0)& '0' xor After_ShiftRows(13) xor After_ShiftRows(13) (6 downto 0) &'0' xor After_ShiftRows(14) xor After_ShiftRows(15); 
else After_MixColumns(12) <= After_ShiftRows(12)(6 downto 0)& '0' xor After_ShiftRows(13) xor After_ShiftRows(13) (6 downto 0) &'0' xor After_ShiftRows(14) xor After_ShiftRows(15)xor x"1b";end if;

if((After_ShiftRows(13)(7) xor After_ShiftRows(14)(7)) = '0') then After_MixColumns(13) <= After_ShiftRows(13)(6 downto 0)& '0' xor After_ShiftRows(14) xor After_ShiftRows(14) (6 downto 0) &'0' xor After_ShiftRows(12) xor After_ShiftRows(15); 
else After_MixColumns(13) <= After_ShiftRows(13)(6 downto 0)& '0' xor After_ShiftRows(14) xor After_ShiftRows(14) (6 downto 0) &'0' xor After_ShiftRows(12) xor After_ShiftRows(15)xor x"1b";end if;

if((After_ShiftRows(14)(7) xor After_ShiftRows(15)(7)) = '0') then After_MixColumns(14) <= After_ShiftRows(14)(6 downto 0)& '0' xor After_ShiftRows(15) xor After_ShiftRows(15) (6 downto 0) &'0' xor After_ShiftRows(12) xor After_ShiftRows(13); 
else After_MixColumns(14) <= After_ShiftRows(14)(6 downto 0)& '0' xor After_ShiftRows(15) xor After_ShiftRows(15) (6 downto 0) &'0' xor After_ShiftRows(12) xor After_ShiftRows(13)xor x"1b";end if;

if((After_ShiftRows(12)(7) xor After_ShiftRows(15)(7)) = '0') then After_MixColumns(15) <= After_ShiftRows(15)(6 downto 0)& '0' xor After_ShiftRows(12) xor After_ShiftRows(12) (6 downto 0) &'0' xor After_ShiftRows(13) xor After_ShiftRows(14); 
else After_MixColumns(15) <= After_ShiftRows(15)(6 downto 0)& '0' xor After_ShiftRows(12) xor After_ShiftRows(12) (6 downto 0) &'0' xor After_ShiftRows(13) xor After_ShiftRows(14)xor x"1b";end if;

end if;
end if; 
end if;
end process;

p7_save : process(clk)
FILE RamFile_wr : text;
variable RamFileLine_wr : line;
begin
if(clk'event and clk='1') then
if(pr_state = save)then
file_open(ramfile_wr,"result.txt", append_mode);
hwrite (RamFileLine_wr,After_AddRoundReg(0) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(1) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(2) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(3) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(4) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(5) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(6) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(7) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(8) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(9) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(10) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(11) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(12) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(13) );
writeline (ramfile_wr, RamFileLine_wr); 
hwrite (RamFileLine_wr,After_AddRoundReg(14) );
writeline (ramfile_wr, RamFileLine_wr);
hwrite (RamFileLine_wr,After_AddRoundReg(15) );
writeline (ramfile_wr, RamFileLine_wr);  
file_close(ramfile_wr);
d_out_0 <= After_AddRoundReg(0);
d_out_1 <= After_AddRoundReg(1);
d_out_2 <= After_AddRoundReg(2);
d_out_3 <= After_AddRoundReg(3);
d_out_4 <= After_AddRoundReg(4);
d_out_5 <= After_AddRoundReg(5);
d_out_6 <= After_AddRoundReg(6);
d_out_7 <= After_AddRoundReg(7);
d_out_8 <= After_AddRoundReg(8);
d_out_9 <= After_AddRoundReg(9);
d_out_10 <= After_AddRoundReg(10);
d_out_11 <= After_AddRoundReg(11);
d_out_12 <= After_AddRoundReg(12);
d_out_13 <= After_AddRoundReg(13);
d_out_14 <= After_AddRoundReg(14);
d_out_15 <= After_AddRoundReg(15);

end if; 
end if;
end process;


current <= input   when (level mod 11 = 0 or level mod 11 = 1)  else After_MixColumns ;
 
current_key <= key when (level mod 11 = 0 or level mod 11 = 1)  else new_key;
load_flag <= '1'   when (level mod 11 = 0 or level =0) else '0';

end Behavioral;

