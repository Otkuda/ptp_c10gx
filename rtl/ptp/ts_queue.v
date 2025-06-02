`timescale 1ns/1ns

module ts_queue (
  input          aclr,
  input	 [ 79:0] data,
  input	         rdclk,
  input	         rdreq,
  input	         wrclk,
  input	         wrreq,
  output [ 79:0] q,
  output         rdempty,
  output [  3:0] rdusedw,
  output         wrfull,
  output [  3:0] wrusedw
);


ts_fifo ts_fifo_inst(
  .aclr(aclr),

  .wrclk(wrclk),
  .wrreq(wrreq),
  .data(data),
  .wrfull(wrfull),
  .wrusedw(wrusedw),

  .rdclk(rdclk),
  .rdreq(rdreq),
  .q(q),
  .rdempty(rdempty),
  .rdusedw(rdusedw)
);



endmodule