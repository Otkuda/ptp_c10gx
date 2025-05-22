
// Author: Алексей Головченко для дефектоскопа

`ifndef WB_IF_DEFS_SVH_INCLUDED
`define WB_IF_DEFS_SVH_INCLUDED

`ifndef WB_ADR_MAX_WIDTH
    `define WB_ADR_MAX_WIDTH 32
`endif

`ifndef WB_DAT_MAX_WIDTH
    `define WB_DAT_MAX_WIDTH 32
`endif

`define WB_SEL_MAX_WIDTH (`WB_DAT_MAX_WIDTH / 8)

`endif
