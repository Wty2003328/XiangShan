// XiangShan SRAM Wrapper — replaces FIRRTL-generated array_* modules with FakeRAM macros
// This file is analyzed AFTER the RTL (overrides the register-based array implementations)
// Covers all 21 SRAMs: 17 x 1RW + 4 x 1R1W

// ============================================================================
// 1RW wrappers: RTL RW0_* interface -> FakeRAM 1RW interface
// ============================================================================

// array_0_8192x64 (L2 data array, largest SRAM: 524K bits)
module array_0_8192x64(
  input  [12:0] RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [63:0] RW0_wdata,
  output [63:0] RW0_rdata
);
  fakeram7_8192x64 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_0_1024x7 (tag/meta array)
module array_0_1024x7(
  input  [9:0] RW0_addr,
  input        RW0_en,
               RW0_clk,
               RW0_wmode,
  input  [6:0] RW0_wdata,
  output [6:0] RW0_rdata
);
  fakeram7_1024x7 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_1024x160 (with wmask — wmask ignored for macro, full-word write)
module array_1024x160(
  input  [9:0]   RW0_addr,
  input          RW0_en,
                 RW0_clk,
                 RW0_wmode,
  input  [159:0] RW0_wdata,
  output [159:0] RW0_rdata,
  input  [7:0]   RW0_wmask
);
  fakeram7_1024x160 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_1024x56 (with wmask)
module array_1024x56(
  input  [9:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [55:0] RW0_wdata,
  output [55:0] RW0_rdata,
  input  [7:0]  RW0_wmask
);
  fakeram7_1024x56 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_512x308 (with wmask)
module array_512x308(
  input  [8:0]   RW0_addr,
  input          RW0_en,
                 RW0_clk,
                 RW0_wmode,
  input  [307:0] RW0_wdata,
  output [307:0] RW0_rdata,
  input  [3:0]   RW0_wmask
);
  fakeram7_512x308 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_256x24 (with wmask)
module array_256x24(
  input  [7:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [23:0] RW0_wdata,
  output [23:0] RW0_rdata,
  input  [1:0]  RW0_wmask
);
  fakeram7_256x24 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_256x16 (with wmask)
module array_256x16(
  input  [7:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [15:0] RW0_wdata,
  output [15:0] RW0_rdata,
  input  [15:0] RW0_wmask
);
  fakeram7_256x16 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_128x230 (with wmask)
module array_128x230(
  input  [6:0]   RW0_addr,
  input          RW0_en,
                 RW0_clk,
                 RW0_wmode,
  input  [229:0] RW0_wdata,
  output [229:0] RW0_rdata,
  input  [9:0]   RW0_wmask
);
  fakeram7_128x230 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_128x100 (with wmask)
module array_128x100(
  input  [6:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [99:0] RW0_wdata,
  output [99:0] RW0_rdata,
  input  [1:0]  RW0_wmask
);
  fakeram7_128x100 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_128x50 (no wmask)
module array_128x50(
  input  [6:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [49:0] RW0_wdata,
  output [49:0] RW0_rdata
);
  fakeram7_128x50 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_128x40 (with wmask)
module array_128x40(
  input  [6:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [39:0] RW0_wdata,
  output [39:0] RW0_rdata,
  input  [9:0]  RW0_wmask
);
  fakeram7_128x40 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_64x192 (with wmask)
module array_64x192(
  input  [5:0]   RW0_addr,
  input          RW0_en,
                 RW0_clk,
                 RW0_wmode,
  input  [191:0] RW0_wdata,
  output [191:0] RW0_rdata,
  input  [7:0]   RW0_wmask
);
  fakeram7_64x192 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_64x64 (no wmask)
module array_64x64(
  input  [5:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [63:0] RW0_wdata,
  output [63:0] RW0_rdata
);
  fakeram7_64x64 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_32x1024 (with wmask)
module array_32x1024(
  input  [4:0]    RW0_addr,
  input           RW0_en,
                  RW0_clk,
                  RW0_wmode,
  input  [1023:0] RW0_wdata,
  output [1023:0] RW0_rdata,
  input  [3:0]    RW0_wmask
);
  fakeram7_32x1024 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_32x108 (with wmask)
module array_32x108(
  input  [4:0]   RW0_addr,
  input          RW0_en,
                 RW0_clk,
                 RW0_wmode,
  input  [107:0] RW0_wdata,
  output [107:0] RW0_rdata,
  input  [3:0]   RW0_wmask
);
  fakeram7_32x108 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_4x1044 (with wmask)
module array_4x1044(
  input  [1:0]    RW0_addr,
  input           RW0_en,
                  RW0_clk,
                  RW0_wmode,
  input  [1043:0] RW0_wdata,
  output [1043:0] RW0_rdata,
  input  [11:0]   RW0_wmask
);
  fakeram7_4x1044 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// array_4x2672 (with wmask)
module array_4x2672(
  input  [1:0]    RW0_addr,
  input           RW0_en,
                  RW0_clk,
                  RW0_wmode,
  input  [2671:0] RW0_wdata,
  output [2671:0] RW0_rdata,
  input  [15:0]   RW0_wmask
);
  fakeram7_4x2672 u_mem (
    .addr_in (RW0_addr),
    .clk     (RW0_clk),
    .ce_in   (RW0_en),
    .we_in   (RW0_en & RW0_wmode),
    .wd_in   (RW0_wdata),
    .rd_out  (RW0_rdata)
  );
endmodule

// ============================================================================
// 1R1W wrappers: RTL R0_*/W0_* interface -> FakeRAM 1R1W interface
// ============================================================================

// array_2048x4 (1R1W, with wmask)
module array_2048x4(
  input  [10:0] R0_addr,
  input         R0_en,
                R0_clk,
  output [3:0]  R0_data,
  input  [10:0] W0_addr,
  input         W0_en,
                W0_clk,
  input  [3:0]  W0_data,
  input  [1:0]  W0_mask
);
  fakeram7_2048x4 u_mem (
    .raddr_in (R0_addr),
    .waddr_in (W0_addr),
    .clk      (R0_clk),
    .ce_in    (R0_en | W0_en),
    .we_in    (W0_en),
    .wd_in    (W0_data),
    .rd_out   (R0_data)
  );
endmodule

// array_256x24_0 (1R1W, with wmask)
module array_256x24_0(
  input  [7:0]  R0_addr,
  input         R0_en,
                R0_clk,
  output [23:0] R0_data,
  input  [7:0]  W0_addr,
  input         W0_en,
                W0_clk,
  input  [23:0] W0_data,
  input  [3:0]  W0_mask
);
  fakeram7_256x24_0 u_mem (
    .raddr_in (R0_addr),
    .waddr_in (W0_addr),
    .clk      (R0_clk),
    .ce_in    (R0_en | W0_en),
    .we_in    (W0_en),
    .wd_in    (W0_data),
    .rd_out   (R0_data)
  );
endmodule

// array_8x236 (1R1W, no wmask)
module array_8x236(
  input  [2:0]   R0_addr,
  input          R0_en,
                 R0_clk,
  output [235:0] R0_data,
  input  [2:0]   W0_addr,
  input          W0_en,
                 W0_clk,
  input  [235:0] W0_data
);
  fakeram7_8x236 u_mem (
    .raddr_in (R0_addr),
    .waddr_in (W0_addr),
    .clk      (R0_clk),
    .ce_in    (R0_en | W0_en),
    .we_in    (W0_en),
    .wd_in    (W0_data),
    .rd_out   (R0_data)
  );
endmodule

// array_8x512 (1R1W, with wmask)
module array_8x512(
  input  [2:0]   R0_addr,
  input          R0_en,
                 R0_clk,
  output [511:0] R0_data,
  input  [2:0]   W0_addr,
  input          W0_en,
                 W0_clk,
  input  [511:0] W0_data,
  input  [1:0]   W0_mask
);
  fakeram7_8x512 u_mem (
    .raddr_in (R0_addr),
    .waddr_in (W0_addr),
    .clk      (R0_clk),
    .ce_in    (R0_en | W0_en),
    .we_in    (W0_en),
    .wd_in    (W0_data),
    .rd_out   (R0_data)
  );
endmodule
