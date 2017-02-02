function [ Interpolant ] = interpolate3D( D, T, Y, D1D, T1D, Y1D, V3D, OS )

  Interpolant = zeros( size( D, 1 ), 1 );
  for i = 1 : size( D, 1 )

    iD = find( D1D < D(i), 1, 'last' );
    iT = find( T1D < T(i), 1, 'last' );
    iY = find( Y1D < Y(i), 1, 'last' );

    dD = log10( D(i) / D1D(iD) ) / log10( D1D(iD+1) / D1D(iD) );
    dT = log10( T(i) / T1D(iT) ) / log10( T1D(iT+1) / T1D(iT) );
    dY = ( Y(i) - Y1D(iY) ) / ( Y1D(iY+1) - Y1D(iY) );
    
    p000 = log10( V3D( iD  , iT  , iY   ) + OS );
    p100 = log10( V3D( iD+1, iT  , iY   ) + OS );
    p010 = log10( V3D( iD  , iT+1, iY   ) + OS );
    p110 = log10( V3D( iD+1, iT+1, iY   ) + OS );
    p001 = log10( V3D( iD  , iT  , iY+1 ) + OS );
    p101 = log10( V3D( iD+1, iT  , iY+1 ) + OS );
    p011 = log10( V3D( iD  , iT+1, iY+1 ) + OS );
    p111 = log10( V3D( iD+1, iT+1, iY+1 ) + OS );
    
    Interpolant(i)...
      = 10.0^(...
          (1.0d0 - dY)...
          * (   (1.0d0 - dD) * (1.0d0 - dT) * p000...
              +          dD  * (1.0d0 - dT) * p100...
              + (1.0d0 - dD) *          dT  * p010...
              +          dD  *          dT  * p110 )...
          +         dY...
          * (   (1.0d0 - dD) * (1.0d0 - dT) * p001...
              +          dD  * (1.0d0 - dT) * p101...
              + (1.0d0 - dD) *          dT  * p011...
              +          dD  *          dT  * p111 ) )...
          - OS;
    
  end

end

