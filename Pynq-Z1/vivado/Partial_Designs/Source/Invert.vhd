----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Andrew Wilson
-- 
-- Create Date: 01/30/2017 10:24:00 AM
-- Design Name: Invert Filter
-- Module Name: Video_Box - Behavioral
-- Project Name: 
-- Tool Versions: Vivado 2016.3 
-- Description: This design is for a partial bitstream to be programmed
-- on Brigham Young Univeristy's Video Base Design.
-- This filter inverts the image passing through the filter. This is 
-- done by taking the make RGB value and subtracting the actual from 
-- the max, creating the inverse of the RGB value.
-- 
-- Revision:
-- Revision 1.0
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Video_Box is
generic (
    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH    : integer    := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH    : integer    := 11
);
port (
    S_AXI_ARESETN : in std_logic;
    slv_reg_wren : in std_logic;
    slv_reg_rden : in std_logic;
     S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    axi_awaddr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_WDATA    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    axi_araddr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    reg_data_out    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    
    --Bus Clock
    S_AXI_ACLK : in std_logic;
    --Video
    RGB_IN : in std_logic_vector(23 downto 0); -- Parallel video data (required)
    VDE_IN : in std_logic; -- Active video Flag (optional)

    HS_IN : in std_logic; -- Horizontal sync signal (optional)
    VS_IN : in std_logic; -- Veritcal sync signal (optional)

    --  additional ports here
    RGB_OUT : out std_logic_vector(23 downto 0); -- Parallel video data (required)
    VDE_OUT : out std_logic; -- Active video Flag (optional)

    HS_OUT : out std_logic; -- Horizontal sync signal (optional)
    VS_OUT : out std_logic; -- Veritcal sync signal (optional)

    
    PIXEL_CLK : in std_logic;
    
    X_Coord : in std_logic_vector(15 downto 0);
    Y_Coord : in std_logic_vector(15 downto 0)

);
end Video_Box;

--Begin Invert Architecture Design
architecture Behavioral of Video_Box is

--Complete RGB value
signal full_const : unsigned(7 downto 0):= "11111111";
--Inverted signals for the red, green, and blue values
signal red_i,green_i,blue_i : unsigned(7 downto 0);

signal RGB_IN_reg, RGB_OUT_reg: std_logic_vector(23 downto 0):= (others=>'0');
signal X_Coord_reg,Y_Coord_reg : std_logic_vector(15 downto 0):= (others=>'0');
signal VDE_IN_reg,VDE_OUT_reg,HS_IN_reg,HS_OUT_reg,VS_IN_reg,VS_OUT_reg : std_logic := '0';
signal USER_LOGIC : std_logic_vector(23 downto 0);

begin

--Take the max value and subtract away the RGB values to invert the image
red_i <= full_const - unsigned(RGB_IN_reg(23 downto 16));
green_i <= full_const - unsigned(RGB_IN_reg(15 downto 8));
blue_i <= full_const - unsigned(RGB_IN_reg(7 downto 0));

--Concatenate the inverted Red, Green, and Blue values together
--Route the inverted RGB values out
USER_LOGIC 	<= std_logic_vector(red_i&green_i&blue_i);

--Pass all the other signals through the region
	RGB_OUT 	<= RGB_OUT_reg;
	VDE_OUT		<= VDE_OUT_reg;

	HS_OUT		<= HS_OUT_reg;
	VS_OUT		<= VS_OUT_reg;


	
process(PIXEL_CLK) is
    begin
        if (rising_edge (PIXEL_CLK)) then
            -- Video Input Signals
            RGB_IN_reg <= RGB_IN;
            X_Coord_reg <= X_Coord;
            Y_Coord_reg  <= Y_Coord;
            VDE_IN_reg  <= VDE_IN;
            HS_IN_reg  <= HS_IN;
            VS_IN_reg  <= VS_IN;
            -- Video Output Signals
            RGB_OUT_reg  <= USER_LOGIC;
            VDE_OUT_reg  <= VDE_IN_reg;
            HS_OUT_reg  <= HS_IN_reg;
            VS_OUT_reg  <= VS_IN_reg;
 
         end if;
    end process;

end Behavioral;
--End Invert Architecture Design