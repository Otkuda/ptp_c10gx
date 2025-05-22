//------------------------------------------------------
// author:	Olga Mamoutova
// email:	olga.mamoutova@spbpu.com
// project: general purpose IP
//------------------------------------------------------
// Antibounce for buttons and switches 

module antibounce 
#( 
	parameter DELAY = 50,   // ms
    parameter FREQ = 25     // MHz
 )(
    input clk,
    input rst_n,
    
    input i_sig,
    output reg o_sig
);
    localparam delay_time = FREQ* 1000 * DELAY;

    logic [$clog2(delay_time)-1:0] cnt;
    logic cout;

    always_ff @(posedge clk, posedge rst_n) begin
        if(!rst_n) 
            cnt <= '0;
        else begin
            if (~cout)
                if (i_sig) 
                    cnt <= cnt + 1;
                else 
                    cnt <= cnt - 1;
        end
    end

    assign cout = ((i_sig & cnt == delay_time) || (~i_sig & cnt == '0)) ? '1:'0;

    always_ff @(posedge clk, posedge rst_n) begin
        if(!rst_n)
            o_sig <= 1'b0;
        else if (cout)
            o_sig <= i_sig;
    end

endmodule
