// c17 benchmark circuit
module c17 ( N1, N2, N3, N6, N7, N22, N23 );

  input N1, N2, N3, N6, N7;
  output N22, N23;
  wire N10, N11, N16, N19;

  nand g1 (N10, N1, N3);
  nand g2 (N11, N3, N6);
  nand g3 (N16, N2, N11);
  nand g4 (N19, N11, N7);
  nand g5 (N22, N10, N16);
  nand g6 (N23, N16, N19);

endmodule