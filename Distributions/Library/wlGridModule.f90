MODULE wlGridModule

  USE wlKindModule, ONLY: dp

  implicit none
  PRIVATE

  PUBLIC MakeLinearGrid
  PUBLIC MakeLogGrid

CONTAINS 


  SUBROUTINE MakeLinearGrid( LowerBound, UpperBound, nPoints, Grid )

    INTEGER,                      INTENT(in)  :: nPoints
    REAL(dp),                     INTENT(in)  :: LowerBound
    REAL(dp),                     INTENT(in)  :: UpperBound
    REAl(dp), DIMENSION(nPoints), INTENT(out) :: Grid 

    INTEGER  :: i
    REAL(dp) :: BinWidth

    IF ( nPoints == 1 ) THEN
      Grid(1) = LowerBound
      RETURN
    END IF

    BinWidth = ( UpperBound - LowerBound ) / DBLE( nPoints - 1 )

    DO i = 1, nPoints
      Grid(i) = LowerBound + DBLE( i - 1 ) * BinWidth
    END DO
 
  END SUBROUTINE MakeLinearGrid


  SUBROUTINE MakeLogGrid( LowerBound, UpperBound, nPoints, Grid )

    Integer, INTENT(in)      :: nPoints
    REAL(dp), INTENT(in)     :: LowerBound
    Real(dp), INTENT(in)     :: UpperBound

    REAl(dp), DIMENSION(nPoints), INTENT(out)   :: Grid 

    Integer  :: m
    REAL(dp) :: ScaleFactor

    IF ( nPoints == 1 ) THEN
      Grid(1) = LowerBound
      RETURN
    END IF

    ScaleFactor =  EXP( LOG( UpperBound / LowerBound ) / DBLE( nPoints - 1 ) )

    Grid(1) = LowerBound

    DO m = 2, nPoints - 1
      Grid(m) = Grid(m-1) * ScaleFactor
    END DO

    Grid(nPoints) = UpperBound

  END SUBROUTINE MakeLogGrid


END MODULE wlGridModule
