-- (C) 2001-2024 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License Subscription 
-- Agreement, Intel FPGA IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Intel and sold by 
-- Intel or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


library ieee;
use ieee.std_logic_1164.all;

package sld_mod_ram_rom_pack is
constant SLD_INSTRUCTION_SET_SIZE   : natural := 8; 
constant SLD_IR_BITS                : natural := SLD_INSTRUCTION_SET_SIZE;
end package sld_mod_ram_rom_pack;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.sld_mod_ram_rom_pack.all;


entity sld_mod_ram_rom_top is
generic 
    (
        SLD_NODE_INFO               : natural := 270036480 ; -- The NODE ID to uniquely identify this node on the hub.  Type ID: 3 Version: 1 Inst: 0 MFG ID 110  @no_decl
        -- SLD Related new params
        BYTE_ENABLE_WIDTH           : natural := 4 ;
        FIFO_SIZE_DELAY             : natural := 3 ;
        QUEUE_SIZE_WIDTH            : natural := 5 ;
        LATENCY                     : natural := 2 ;
        WIDTH_WORD                  : natural := 8;  -- Specifies the width of the data_read[] and data_write[] input/output ports.
        NUMWORDS                    : natural := 1;  -- Number of words stored in memory.  This should be less than and equal to 2^WIDTHAD.
        WIDTHAD                     : natural := 16;  -- Specifies the width of the address_write[] and address_read[] input/output ports.
        SHIFT_COUNT_BITS            : natural := 4;  -- Specifies the counter width to count from 0 to WIDTH_WORD - 1.  = ceil(log2(WIDTH_WORD)) + 1
        IS_DATA_IN_RAM              : natural := 1;   -- Specifies whether the data source resides in RAM.  If not in RAM, additional update register for data is created in this entity.  Acceptable values are 0 or 1.  LPM_CONSTANT implementation sets it to 0.
        IS_READABLE                 : natural := 1;  -- Specifies whether the read port is active. Acceptable values are 0 or 1.
        BACKPRESSURE_ENABLED        : natural := 0; --Specifies whether backpressure is enabled. Acceptable values are 0 or 1.
        FIFO_SIZE                           : natural := 16;
        FIFO_SIZE_WIDTH             : natural := 4;
        NODE_NAME_DEC                   : natural := 0  -- Specifies the 4-byte name of debug node.  If empty, it is not defined.
    );

	port (
		clock0            : in  std_logic := '0';
		reset_out         : out std_logic;
        ismce_addr        : out std_logic_vector(WIDTHAD-1 downto 0);
        ismce_byteena     : out std_logic_vector(BYTE_ENABLE_WIDTH-1 downto 0);
        ismce_wdata       : out std_logic_vector(WIDTH_WORD-1 downto 0);
		ismce_wren        : out std_logic;
		ismce_rden        : out std_logic;
        ismce_rdata       : in  std_logic_vector(WIDTH_WORD-1 downto 0) := (others => '0');
		ismce_waitrequest : in  std_logic := '0';
		tck_usr           : out std_logic;
        -- HUB/Node Interface
        raw_tck                     : in std_logic := '0';  -- Real TCK from the JTAG HUB.  @no_decl
        tdi                         : in std_logic := '0';  -- TDI from the JTAG HUB.  It gets the data from JTAG TDI.  @no_decl
        usr1                        : in std_logic := '0';  -- USR1 from the JTAG HUB.  Indicate whether it is in USER1 or USER0  @no_decl
        jtag_state_cdr              : in std_logic := '0';  -- CDR from the JTAG HUB.  Indicate whether it is in Capture_DR state.  @no_decl
        jtag_state_sdr              : in std_logic := '0';  -- SDR from the JTAG HUB.  Indicate whether it is in Shift_DR state.  @no_decl
        jtag_state_e1dr             : in std_logic := '0';  -- EDR from the JTAG HUB.  Indicate whether it is in Exit1_DR state.  @no_decl
        jtag_state_udr              : in std_logic := '0';  -- UDR from the JTAG HUB.  Indicate whether it is in Update_DR state.  @no_decl
        jtag_state_uir              : in std_logic := '0';  -- UIR from the JTAG HUB.  Indicate whether it is in Update_IR state.  @no_decl
        clr                         : in std_logic := '0';  -- CLR from the JTAG HUB.  Indicate whether hub request global reset.  @no_decl
        ena                         : in std_logic := '0';  -- ENA from the JTAG HUB.  Indicate whether this node should establish JTAG chain.  @no_decl
        ir_in                       : in std_logic_vector (SLD_IR_BITS-1 downto 0) := (others=> '0');	-- IR_OUT from the JTAG HUB.  It hold the current instruction for the node.  @no_decl
        
        ir_out                      : out std_logic_vector (SLD_IR_BITS-1 downto 0);	-- IR_IN to the JTAG HUB.  It supplies the updated value for IR_IN.  @no_decl
        tdo                         : out std_logic -- TDO to the JTAG HUB.  It supplies the data to JTAG TDO.  @no_decl
	);
end entity sld_mod_ram_rom_top;

architecture rtl of sld_mod_ram_rom_top is
	component sld_mod_ram_rom is
		generic (
            SLD_NODE_INFO        : natural := 270036480 ;
            BYTE_ENABLE_WIDTH    : natural := 4 ;
            FIFO_SIZE_DELAY      : natural := 3 ;
            QUEUE_SIZE_WIDTH     : natural := 5 ;
            LATENCY              : natural := 2 ;
            WIDTH_WORD           : natural := 8;
            NUMWORDS             : natural := 1;
            WIDTHAD              : natural := 16;
            SHIFT_COUNT_BITS     : natural := 4;
            IS_DATA_IN_RAM       : natural := 1;
            IS_READABLE          : natural := 1;
            BACKPRESSURE_ENABLED : natural := 0;
            FIFO_SIZE            : natural := 16;
            FIFO_SIZE_WIDTH      : natural := 4;
            NODE_NAME            : natural := 0 
		);
		port (
			clock0            : in  std_logic                     := 'X';             -- clk
			reset_out         : out std_logic;                                        -- reset
			ismce_addr        : out std_logic_vector(WIDTHAD-1 downto 0);                    -- address
			ismce_byteena     : out std_logic_vector(BYTE_ENABLE_WIDTH-1 downto 0);                     -- byteenable
			ismce_wdata       : out std_logic_vector(WIDTH_WORD-1 downto 0);                    -- writedata
			ismce_wren        : out std_logic;                                        -- write
			ismce_rden        : out std_logic;                                        -- read
			ismce_rdata       : in  std_logic_vector(WIDTH_WORD-1 downto 0) := (others => 'X'); -- readdata
			ismce_waitrequest : in  std_logic                     := 'X';             -- waitrequest
			tck_usr           : out std_logic;                                         -- clk

            raw_tck                     : in std_logic := 'X';  -- Real TCK from the JTAG HUB.  @no_decl
            tdi                         : in std_logic := 'X';  -- TDI from the JTAG HUB.  It gets the data from JTAG TDI.  @no_decl
            usr1                        : in std_logic := 'X';  -- USR1 from the JTAG HUB.  Indicate whether it is in USER1 or USER0  @no_decl
            jtag_state_cdr              : in std_logic := 'X';  -- CDR from the JTAG HUB.  Indicate whether it is in Capture_DR state.  @no_decl
            jtag_state_sdr              : in std_logic := 'X';  -- SDR from the JTAG HUB.  Indicate whether it is in Shift_DR state.  @no_decl
            jtag_state_e1dr             : in std_logic := 'X';  -- EDR from the JTAG HUB.  Indicate whether it is in Exit1_DR state.  @no_decl
            jtag_state_udr              : in std_logic := 'X';  -- UDR from the JTAG HUB.  Indicate whether it is in Update_DR state.  @no_decl
            jtag_state_uir              : in std_logic := 'X';  -- UIR from the JTAG HUB.  Indicate whether it is in Update_IR state.  @no_decl
            clr                         : in std_logic := 'X';  -- CLR from the JTAG HUB.  Indicate whether hub request global reset.  @no_decl
            ena                         : in std_logic := 'X';  -- ENA from the JTAG HUB.  Indicate whether this node should establish JTAG chain.  @no_decl
            ir_in                       : in std_logic_vector (SLD_IR_BITS-1 downto 0) := (others=> 'X');	-- IR_OUT from the JTAG HUB.  It hold the current instruction for the node.  @no_decl
            ir_out                      : out std_logic_vector (SLD_IR_BITS-1 downto 0);	-- IR_IN to the JTAG HUB.  It supplies the updated value for IR_IN.  @no_decl
            tdo                         : out std_logic -- TDO to the JTAG HUB.  It supplies the data to JTAG TDO.  @no_decl
		);
	end component sld_mod_ram_rom;

begin

	sld_mod_ram_rom_inst : sld_mod_ram_rom
		generic map (
			SLD_NODE_INFO        => SLD_NODE_INFO       ,
			BYTE_ENABLE_WIDTH    => BYTE_ENABLE_WIDTH   ,
			FIFO_SIZE_DELAY      => FIFO_SIZE_DELAY     ,
			QUEUE_SIZE_WIDTH     => QUEUE_SIZE_WIDTH    ,
			LATENCY              => LATENCY             ,
			WIDTH_WORD           => WIDTH_WORD          ,
			NUMWORDS             => NUMWORDS            ,
			WIDTHAD              => WIDTHAD             ,
			SHIFT_COUNT_BITS     => SHIFT_COUNT_BITS    ,
			IS_DATA_IN_RAM       => IS_DATA_IN_RAM      ,
			IS_READABLE          => IS_READABLE         ,
			BACKPRESSURE_ENABLED => BACKPRESSURE_ENABLED,
			FIFO_SIZE            => FIFO_SIZE           ,
			FIFO_SIZE_WIDTH      => FIFO_SIZE_WIDTH     ,
			NODE_NAME            => NODE_NAME_DEC           
		)
		port map (
			clock0            => clock0,
			reset_out         => reset_out,
			ismce_addr        => ismce_addr,
			ismce_byteena     => ismce_byteena,
			ismce_wdata       => ismce_wdata,
			ismce_wren        => ismce_wren,
			ismce_rden        => ismce_rden,
			ismce_rdata       => ismce_rdata,
			ismce_waitrequest => ismce_waitrequest,
			tck_usr           => tck_usr,

            raw_tck           => raw_tck,
            tdi               => tdi,
            usr1              => usr1,
            jtag_state_cdr    => jtag_state_cdr,
            jtag_state_sdr    => jtag_state_sdr,
            jtag_state_e1dr   => jtag_state_e1dr,
            jtag_state_udr    => jtag_state_udr,
            jtag_state_uir    => jtag_state_uir,
            clr               => clr,
            ena               => ena,
            ir_in             => ir_in,
            ir_out            => ir_out,
            tdo               => tdo
		);

end architecture rtl; -- of sld_mod_ram_rom_top
-- pragma questa_oem_00 "uASR1sd/9pKb0QH+cNA/ieJbqeLJNyxgeWHlmBW2QbP4oir95C/p8PyyNmoth0GK33UTgZVGVbP/+Lyd/XQce++inBgVav1TbQMuUy7uYimbO3mWGWcgIAlS7PVsswnLJUilWRcG1mA7YoQws3xXAAudIE4jdA5x7qo6pctl5rAUaRh3TK+m7Bng5sxkBCTKBhtVAmA9AnAx7Gida8IhcYiMLvVr+U58cr5rk2w79/C/mAmGf6cLqTEpDQvWojDqZMIQ5vflWarmpAGGmGrjcxhW+EQBAleuqon4h+7v+n4cViEErPgOmbca5lk5vmvwiH99hXBcNv7gichC3b1B9gbXyMi4TjAwzFOR7HrOTK/Zp/a/QQMxz6FWpMhHOVPT2GBvNrr6lphb3P2u+50xwNB+ywRGIXziD7fp49bPM8cjC87R4Tb+TSK09/X2Ub3/rztDKDaZulDMp0Dzwg7zd1Zt8uCBIPHffLMyLft2CblMVrVGaKROtgOzV6Jd4kB1guSITFgoM9DPkfDYRfsLujFZD3jUBMEHqBuMvBl2ZAVxKDh6ncSuI25Vy+4ZK+nol75vQjUNObFmGHMlf+eHFewsYOhj9hX6y2M2OGzaxxbB1bjaUiSznDeh0XHaR4N4H2+XcaOev2wNdV6LOvi+wnq0P8vcyFzxmrRwmQgYJjUNSKsUZCiBpH2bp7r1AqnE4OWA/bD6fqmd/9735Oz7QFQp9iIyQpAgENXzaw/6MGnINEau6jx+g/RHytYPIY86DDy6aQbmJxNS/Y7pUjXLobdBZdjlvQtWhEbh1v3iFKXVrriagICB0s1a3N2TuHNBv1xP13DKRzctPRWopf95Uzq0oQz7tUmtFgB7sAfEJp43kc/EjHk6nGQAcnMfTC7M6b4ADKfSObq06PaOjA+7RV/tjGd0ei1j6qB7K1C4ExueZ3kHrmYvUBcJppnSCRmqgI7m2AttEHTsCebdz50i5oxt8mDu7Gt2+3vBk9JvGY0ztVbH6VWLf2x3BD4n+wvO"