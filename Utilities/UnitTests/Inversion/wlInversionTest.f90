PROGRAM wlInversionTest

  USE wlKindModule, ONLY: dp 
  USE HDF5
  USE wlExtEOSWrapperModule, ONLY: wlGetFullEOS
  USE wlEquationOfStateTableModule
  USE wlInterpolationModule
  USE wlExtTableFinishingModule
  USE wlExtNumericalModule, ONLY: epsilon, zero
  USE wlIOModuleHDF, ONLY: InitializeHDF, FinalizeHDF,  & 
                           ReadEquationOfStateTableHDF, & 
                           WriteEquationOfStateTableHDF
  implicit none

  INTEGER  :: i, j, k, TestUnit, ErrorUnit
  !INTEGER, PARAMETER :: RhoIndex = 139
  !INTEGER, PARAMETER :: YeIndex = 1
  REAL(dp) :: maxnorm, L1Norm
  TYPE(EquationOfStateTableType) :: EOSTable
  LOGICAL, DIMENSION(3) :: LogInterp
  REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: Norm
  REAL(dp), DIMENSION(:), ALLOCATABLE :: Energy_Table, Temp_Table, E_Internal, &
                                         Temperature, Test_Temps, Test_Rho,    &
                                         Test_Ye
  LogInterp = (/.true.,.true.,.false./)
  CALL InitializeHDF( )

  CALL ReadEquationOfStateTableHDF( EOSTable, "EquationOfStateTable.h5" )

  OPEN( newunit = TestUnit, FILE="InversionTableMap.d")
  OPEN( newunit = ErrorUnit, FILE="InversionErrors.d")

  ASSOCIATE( nPoints => EOSTable % nPoints )

  ALLOCATE( Energy_Table( nPoints(2) ), Temp_Table( nPoints(2) ),          &
            E_Internal( nPoints(2) - 1 ), Temperature( nPoints(2) - 1 ),   &
            Test_Temps( nPoints(2) - 1 ) , Test_Rho ( nPoints(2) -1 ),    &
            Test_Ye( nPoints(2) - 1 ), &
            Norm(nPoints(1), nPoints(2)-1, nPoints(3) - 1 ) )  
  

!  nPoints = (/81,24,24/) ! Low Res
!  nPoints = (/81,500,24/) ! High Res in T only
!  nPoints = (/161,47,47/) ! Standard Res
!  nPoints = (/321,93,93/) ! High Res
  !DO i = 1, 55
  !WRITE (*,'(i4, 3es22.15)') i, EOSTable % TS % States(2) % Values(i), &
  !        10**(EOSTable % DV % Variables(3) % Values(RhoIndex,i,YeIndex)) &
  !        - EOSTable % DV % Offsets(3)
  !END DO

  Temp_Table = ( EOSTable % TS % States(2) % Values ) 

  DO i = 1, SIZE(Temp_Table) - 1 
    Test_Temps(i) = ( Temp_Table(i+1) - Temp_Table(i) )/2 + Temp_Table(i)
  END DO

  maxnorm = 0.0d0

  DO k = 1, nPoints(3) - 1 
    DO i = 1, nPoints(1) 

    Test_Rho = EOSTable % TS % States(1) % Values(i)
    Test_Ye = EOSTable % TS % States(3) % Values(k)
    CALL LogInterpolateSingleVariable &
           ( Test_Rho,        &
             Test_Temps,                                   &
             Test_Ye,     &
             EOSTable % TS % States(1) % Values,           &
             EOSTable % TS % States(2) % Values,           &
             EOSTable % TS % States(3) % Values,           &
             LogInterp,                                    &
             EOSTable % DV % Offsets(3),                   &
             EOSTable % DV % Variables(3) % Values(:,:,:), &
             E_Internal )

      Energy_Table = 10.d0**( EOSTable % DV % Variables(3) % Values(i,:,k) ) &
                     - EOSTable % DV % Offsets(3) 

      CALL ComputeTempFromIntEnergy( E_Internal, Energy_Table, Temp_Table, &
                          EOSTable % DV % Offsets(3), Temperature )  

      DO j = 1, SIZE(Temperature)
        Norm(i,j,k) = ABS( Temperature(j) - Test_Temps(j) ) / Test_Temps(j) 
        WRITE (ErrorUnit,'(i4, 4es12.5, 2i4)') j, E_Internal(j), &
                 Temperature(j), Test_Temps(j), Norm(i,j,k), i, k
        IF ( Norm(i,j,k) > maxnorm) THEN 
          maxnorm = Norm(i,j,k)
        END IF
      END DO  
    END DO
  END DO

  L1Norm = SUM( ABS( Norm( 1:nPoints(1), 1:( nPoints(2) - 1), 1:nPoints(3) - 1 ) ) ) &
             /( nPoints(1) * (nPoints(2) - 1 ) * ( nPoints(3) - 1 ) ) 

  END ASSOCIATE

  WRITE (ErrorUnit,*) "L1Norm/N=", L1Norm 
  WRITE (ErrorUnit,*) "maxnorm =", maxnorm 

  !DO i = 1 , SIZE( EOSTable % TS % States(2) % Values )
  !  WRITE(TestUnit,'(i4,7es22.15)' ) i, EOSTable % TS % States(2) % Values(i),  &
  !                      10**(EOSTable % DV % Variables(3) % Values(140,i,2)), &
  !                      10**(EOSTable % DV % Variables(3) % Values(144,i,46)), &
  !                      10**(EOSTable % DV % Variables(3) % Values(145,i,46))
  !END DO


  CALL DeAllocateEquationOfStateTable( EOSTable )

  CALL FinalizeHDF( )

END PROGRAM wlInversionTest
