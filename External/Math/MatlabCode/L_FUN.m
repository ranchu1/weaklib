function [ L ] = L_FUN( N, R_In, R_Out, theta, N_g )

  k = R_Out * ones( N_g, 1 ) + theta .* ( R_In - R_Out ) * N;
  L = R_In - diag( k );
  
end

