
module seq_ckt (
input A
input B
input clk
output Q
);

wire w1;

and a1 (w1, A, B);
dff ff1 (Q, w1, clk);

endmodule