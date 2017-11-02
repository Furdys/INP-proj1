library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (
    -- Input
    RESET: in std_logic;
    SMCLK: in std_logic;
    -- Output
    ROW: out std_logic_vector(7 downto 0);
    LED: out std_logic_vector(7 downto 0)
);
end ledc8x8;

architecture main of ledc8x8 is
    signal active_row: std_logic_vector(7 downto 0);
    signal counter_enable: std_logic;
    signal counter_value: std_logic_vector (21 downto 0);

begin

    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.

    -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
    -- v souboru ledc8x8.ucf.
    
    counter: process(RESET, SMCLK)
    begin
        if RESET = '1' then
            counter_value <= (others => '0');
        
        elsif rising_edge(SMCLK) then
				counter_value <= counter_value + 1; 
            
            if(counter_value(7 downto 0) = "11111111") then 
                counter_enable <= '1';
				--active_row <= "00100000"; -- DEBUG
            else 
                counter_enable <= '0';
				--active_row <= "00000100"; -- DEBUG
            end if;
            
        end if;            
        
    end process counter;
    
    
    
    rotation: process(RESET, SMCLK, counter_enable)
    begin
		--row <= active_row; -- DEBUG
        if RESET = '1' then
            active_row <= "10000000";
        elsif rising_edge(SMCLK) and counter_enable = '1' then
			case active_row is
                when "10000000" => active_row <= "01000000";
                when "01000000" => active_row <= "00100000";
                when "00100000" => active_row <= "00010000";
                when "00010000" => active_row <= "00001000";
                when "00001000" => active_row <= "00000100";
                when "00000100" => active_row <= "00000010";
                when "00000010" => active_row <= "00000001";
                when "00000001" => active_row <= "10000000";
                when others => null;
            end case;
        end if;
		ROW <= active_row;
    end process rotation;
    
    decoder: process(active_row) --
    begin
        -- if rising_edge(SMCLK) then
        case active_row is
            when "10000000" => LED <= "00010111";
            when "01000000" => LED <= "00010100";
            when "00100000" => LED <= "00010100";
            when "00010000" => LED <= "00010111";
            when "00001000" => LED <= "00010100";
            when "00000100" => LED <= "00010100";
            when "00000010" => LED <= "10010100";
            when "00000001" => LED <= "01100100";
            when others => LED <= "00000000";
        end case;
    end process decoder;

end main;
