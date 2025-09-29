// 2-to-1 Multiplexer
module mux2to1(
    input A, 
    input B, 
    input Sel,
    output Y
);

wire nSel, w1, w2;

not n1 (nSel, Sel);
and a1 (w1, A, nSel);
and a2 (w2, B, Sel);
or o1 (Y, w1, w2);

endmodule
