PROGRAM wlHDFInversionTest

!  The goal of this test is to read a CHIMERA-slice HDF file (only the NSE zones)
!  and then to read the internal energy density of each zone, and then to convert 
!  (via inversion) that value into a temperature, and then to compare with the 
!  local temperature, both to determine table accuracy capability, but also to 
!  examine the effective phase space used by CHIMERA
!--------------------------------------------------------------------------------

  USE wlKindModule, ONLY: dp 
  USE HDF5
  USE wlExtEOSWrapperModule, ONLY: wlGetFullEOS
  USE wlEquationOfStateTableModule
  USE wlInterpolationModule
  USE wlExtTableFinishingModule
  USE wlExtNumericalModule, ONLY: epsilon, zero
  USE wlIOModuleHDF, ONLY: InitializeHDF, FinalizeHDF,  & 
                           ReadEquationOfStateTableHDF, & 
                           WriteEquationOfStateTableHDF,&
                           ReadCHIMERAHDF
  implicit none

  INTEGER  :: i, j, k, kk, l, TestUnit, ErrorUnit, nx, ny, nz, imax, count, zonelimit
  REAL(dp) :: maxTnorm, L1TNorm, maxEnorm, L1ENorm
  REAL(dp), DIMENSION(1) :: Temperature, Energy, SingleTestRho, SingleTestT, &
                            SingleTestYe, SingleE_Test
  TYPE(EquationOfStateTableType) :: EOSTable
  LOGICAL, DIMENSION(3) :: LogInterp
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: TNorm
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: ENorm
  REAL(dp), DIMENSION(:), ALLOCATABLE :: Energy_Table, TestRho, TestYe

  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: Rho
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: T
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: Ye
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: E_Int
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: Entropy
  INTEGER, DIMENSION(:,:,:), ALLOCATABLE :: NSE

  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: E_Test
!  nPoints = (/81,24,24/) ! Low Res
!  nPoints = (/81,500,24/) ! High Res in T only
!  nPoints = (/161,47,47/) ! Standard Res
!  nPoints = (/321,93,93/) ! High Res

  LogInterp = (/.true.,.true.,.false./)

  CALL InitializeHDF( )

  CALL ReadEquationOfStateTableHDF( EOSTable, "LowResEquationOfStateTable7-31-15.h5" )

  OPEN( newunit = TestUnit, FILE="HDFInversionTableMap.d")
  OPEN( newunit = ErrorUnit, FILE="950000HDFInversionErrorsLow.d")

  ASSOCIATE( nPoints   => EOSTable % nPoints,                 &
             TableRho  => EOSTable % TS % States(1) % Values, &
             TableTemp => EOSTable % TS % States(2) % Values, &
             TableYe   => EOSTable % TS % States(3) % Values  )
  
  CALL ReadCHIMERAHDF( Rho, T, Ye, E_Int, Entropy, NSE, imax, nx, ny, nz, &
                       "chimera_000950000_grid_1_01.h5") 

  ALLOCATE( Energy_Table( nPoints(2) ), TestRho( nPoints(2) ), &
            TNorm(imax,ny,nz), TestYe( nPoints(2) ), E_Test(imax,ny,nz), &
            ENorm(imax,ny,nz) )

  WRITE (*,*) "imax, nx, ny, nz =", imax, nx, ny, nz
  WRITE (*,*) "Shape of Rho=", SHAPE(RHO)

  TNorm = 0.0d0 
  maxTnorm = 0.0d0
  ENorm = 0.0d0 
  maxEnorm = 0.0d0
  count = 0
  zonelimit = 0
  
  DO k = 1, nz
    DO j = 1, ny 
      DO i = 1, imax 

      IF ( NSE(i,j,k) == 0 ) THEN
        CYCLE
      END IF 

      IF ( Rho(i,j,k) < 1.0d11 ) THEN
        CYCLE
      END IF 
     
      CALL locate( TableRho, nPoints(1), Rho(i,j,k), kk )

      IF ( kk  == 0 ) THEN
        WRITE (*,*) "Zone below density limit", i, j, k
        CYCLE
      END IF 

      CALL locate( TableYe, nPoints(3), Ye(i,j,k), l )

      IF ( l == 0 ) THEN
        WRITE (*,*) "Zone below ye limit", i, j, k
        CYCLE
      END IF 


      TestRho = Rho(i,j,k)
      TestYe = Ye(i,j,k)

      CALL LogInterpolateSingleVariable &
             ( TestRho,        &
               TableTemp,                                   &
               TestYe,     &
               EOSTable % TS % States(1) % Values,           &
               EOSTable % TS % States(2) % Values,           &
               EOSTable % TS % States(3) % Values,           &
               LogInterp,                                    &
               EOSTable % DV % Offsets(3),                   &
               EOSTable % DV % Variables(3) % Values(:,:,:), &
               Energy_Table )

      SingleTestRho(1) = Rho(i,j,k)
      SingleTestT(1)= T(i,j,k)
      SingleTestYe(1) = Ye(i,j,k)

      CALL LogInterpolateSingleVariable &
             ( SingleTestRho,        &
               SingleTestT, &
               SingleTestYe,     &
               EOSTable % TS % States(1) % Values,           &
               EOSTable % TS % States(2) % Values,           &
               EOSTable % TS % States(3) % Values,           &
               LogInterp,                                    &
               EOSTable % DV % Offsets(3),                   &
               EOSTable % DV % Variables(3) % Values(:,:,:), &
               SingleE_Test )

      E_Test(i,j,k) = SingleE_Test(1)
      Energy(1) = E_Int(i,j,k)


      CALL ComputeTempFromIntEnergy( Energy, Energy_Table, TableTemp, &
                          EOSTable % DV % Offsets(3), Temperature )  

      IF ( Temperature(1) < 1.d0  ) THEN
        CYCLE
      END IF

      TNorm(i,j,k) = ABS( Temperature(1) - T(i,j,k) ) / T(i,j,k) 
      ENorm(i,j,k) = ABS( E_Test(i,j,k) - E_Int(i,j,k) ) / E_Int(i,j,k) 

      WRITE (ErrorUnit,'(2i4, 7es12.5, i4)') i, j, Rho(i,j,k), &
               Temperature, T(i,j,k), TNorm(i,j,k), E_Test(i,j,k), &
               E_Int(i,j,k), ENorm(i,j,k), NSE(i,j,k)

      IF ( TNorm(i,j,k) > maxTnorm) THEN 
        maxTnorm = TNorm(i,j,k)
      END IF

      IF ( ENorm(i,j,k) > maxEnorm) THEN 
        maxEnorm = ENorm(i,j,k)
      END IF

      IF ( i > zonelimit) THEN 
        zonelimit = i 
      END IF

      count = count + 1

      END DO
    END DO
  END DO

  L1TNorm = SUM( ABS( TNorm( 1:zonelimit , 1:ny, 1) ) ) &
              /( count ) 

  L1ENorm = SUM( ABS( ENorm( 1:zonelimit , 1:ny, 1) ) ) &
              /( count ) 

  !WRITE (ErrorUnit,*) L1TNorm, maxTnorm 
  END ASSOCIATE

  WRITE (ErrorUnit,*) "Max LS radial zone=", zonelimit 
  WRITE (ErrorUnit,*) "L1TNorm/N=", L1TNorm 
  WRITE (ErrorUnit,*) "maxTnorm =", maxTnorm 
  WRITE (ErrorUnit,*) "L1ENorm/N=", L1ENorm 
  WRITE (ErrorUnit,*) "maxEnorm =", maxEnorm 

  CALL DeAllocateEquationOfStateTable( EOSTable )

  CALL FinalizeHDF( )

  !  For commit: Added rho cutoff loop and zonelimit to omit regions in LS from statistics
  !  Changed error reporting to be dependent on LS cutoff
END PROGRAM wlHDFInversionTest
