MODULE wlOpacityFieldsModule

  USE wlKindModule, ONLY: dp

  IMPLICIT NONE
  PRIVATE

  INTEGER, PUBLIC, PARAMETER :: iNu_e     = 1
  INTEGER, PUBLIC, PARAMETER :: iNu_e_bar = 2
  INTEGER, PUBLIC, PARAMETER :: iNu_x     = 3
  INTEGER, PUBLIC, PARAMETER :: iNu_x_bar = 4
  INTEGER, PUBLIC, PARAMETER :: nSpecies  = 4

!---------------------------------------------
!
! OpacityTypeEmAb (Emission / Absorption)
!   Dependency ( E, rho, T, Ye )
!     E:   Neutrino Energy
!     rho: Mass Density
!     T:   Temperature
!     Ye:  Electron Fraction
!
!---------------------------------------------

  TYPE :: ValueType_3D
    REAL(dp), DIMENSION(:,:,:), ALLOCATABLE :: Values
  END type ValueType_3D

  TYPE :: ValueType_4D
    REAL(dp), DIMENSION(:,:,:,:), ALLOCATABLE :: Values
  END type ValueType_4D

  TYPE, PUBLIC :: OpacityTypeEmAb
    INTEGER                         :: nOpacities
    INTEGER                         :: nPoints(4)
    CHARACTER(LEN=32),  ALLOCATABLE :: Names(:)
    CHARACTER(LEN=32),  ALLOCATABLE :: Units(:)
    REAL(dp),           ALLOCATABLE :: Offsets(:)
    TYPE(ValueType_4D), ALLOCATABLE :: Absorptivity(:)
  END TYPE OpacityTypeEmAb

!---------------------------------------------
!
! OpacityType B (Elastic Scattering)
!   Dependency ( E, rho, T, Ye, l )
!     E:   Neutrino Energy
!     rho: Mass Density
!     T:   Temperature
!     Ye:  Electron Fraction
!     l:   Legendre Moment
!
! OpacityType B (Inelastic Neutrino-Electron Scattering)
!   Dependency ( E', E, T, Eta, l )
!     E':  Neutrino Energy
!     E:   Neutrino Energy
!     T:   Temperature
!     Eta: Electron Chemical Pot. / Temperature
!     l:   Legendre Moment
!
!---------------------------------------------  

  TYPE :: ValueType_5D
    REAL(dp), DIMENSION(:,:,:,:,:), ALLOCATABLE :: Values
  END type ValueType_5D

  TYPE, PUBLIC :: OpacityTypeB
    INTEGER :: nOpacities
    INTEGER :: nMoments
    INTEGER, DIMENSION(4) :: nPoints
    REAL(dp),            DIMENSION(:,:), ALLOCATABLE :: Offsets
    CHARACTER(LEN=32),   DIMENSION(:), ALLOCATABLE :: Names
    CHARACTER(LEN=32),   DIMENSION(:), ALLOCATABLE :: Species
    CHARACTER(LEN=32),   DIMENSION(:), ALLOCATABLE :: Units
    TYPE(ValueType_5D),  DIMENSION(:), ALLOCATABLE :: Kernel
  END TYPE

!---------------------------------------------
!
! OpacityType C (Inelastic Scattering)
!   Dependency ( E_out, E_in, rho, T, Ye, l )
!
!---------------------------------------------

  TYPE :: ValueType_6D
    REAL(dp), DIMENSION(:,:,:,:,:,:), ALLOCATABLE :: Values
  END type ValueType_6D

  TYPE, PUBLIC :: OpacityTypeC
    INTEGER :: nOpacities
    INTEGER :: nMoments
    INTEGER, DIMENSION(4) :: nPoints
    REAL(dp),          DIMENSION(:), ALLOCATABLE :: Offsets
    CHARACTER(LEN=32), DIMENSION(:), ALLOCATABLE :: Names
    CHARACTER(LEN=32), DIMENSION(:), ALLOCATABLE :: Species
    CHARACTER(LEN=32), DIMENSION(:), ALLOCATABLE :: Units
    TYPE(ValueType_6D),  DIMENSION(:), ALLOCATABLE :: Kernel
  END TYPE

  PUBLIC :: AllocateOpacity
  PUBLIC :: DeallocateOpacity
  PUBLIC :: DescribeOpacity

  INTERFACE AllocateOpacity
    MODULE PROCEDURE AllocateOpacityTypeEmAb
    MODULE PROCEDURE AllocateOpacityTypeB
    MODULE PROCEDURE AllocateOpacityTypeC
  END INTERFACE AllocateOpacity

  INTERFACE DeallocateOpacity
    MODULE PROCEDURE DeallocateOpacityTypeEmAb
    MODULE PROCEDURE DeallocateOpacityTypeB
    MODULE PROCEDURE DeallocateOpacityTypeC
  END INTERFACE DeallocateOpacity

  INTERFACE DescribeOpacity
    MODULE PROCEDURE DescribeOpacityTypeEmAb
    MODULE PROCEDURE DescribeOpacityTypeB
    MODULE PROCEDURE DescribeOpacityTypeC
  END INTERFACE DescribeOpacity

CONTAINS

  SUBROUTINE AllocateOpacityTypeEmAb( Opacity, nPoints, nOpacities )

    TYPE(OpacityTypeEmAb), INTENT(inout) :: Opacity
    INTEGER,               INTENT(in)    :: nPoints(4)
    INTEGER,               INTENT(in)    :: nOpacities

    INTEGER :: i

    Opacity % nOpacities = nOpacities
    Opacity % nPoints    = nPoints
  
    ALLOCATE( Opacity % Names(nOpacities) )
    ALLOCATE( Opacity % Units(nOpacities) )
    ALLOCATE( Opacity % Offsets(nOpacities) )
    ALLOCATE( Opacity % Absorptivity(nOpacities) )

    DO i = 1, nOpacities

      ALLOCATE( Opacity % Absorptivity(i) % Values &
                  (nPoints(1), nPoints(2), nPoints(3), nPoints(4)) )
    END DO

  END SUBROUTINE AllocateOpacityTypeEmAb


  SUBROUTINE DeallocateOpacityTypeEmAb( Opacity )

    TYPE(OpacityTypeEmAb), INTENT(inout) :: Opacity

    INTEGER :: i

    DO i = 1, Opacity % nOpacities
      DEALLOCATE( Opacity % Absorptivity(i) % Values )
    END DO

    DEALLOCATE( Opacity % Absorptivity )
    DEALLOCATE( Opacity % Offsets )
    DEALLOCATE( Opacity % Units )
    DEALLOCATE( Opacity % Names )

  END SUBROUTINE DeallocateOpacityTypeEmAb
  

  SUBROUTINE DescribeOpacityTypeEmAb( Opacity )

    TYPE(OpacityTypeEmAb), INTENT(in) :: Opacity

    INTEGER :: i

    WRITE(*,*)
    WRITE(*,'(A4,A)') ' ', 'Opacity Type EmAb'
    WRITE(*,'(A4,A)') ' ', '--------------'
    WRITE(*,'(A6,A13,I3.3)') &
      ' ', 'nOpacities = ', Opacity % nOpacities
    WRITE(*,'(A6,A13,4I5.4)') &
      ' ', 'nPoints    = ', Opacity % nPoints
    WRITE(*,'(A6,A13,I10.10)') &
      ' ', 'DOFs       = ', &
      Opacity % nOpacities * PRODUCT( Opacity % nPoints )

    DO i = 1, Opacity % nOpacities
      WRITE(*,*)
      WRITE(*,'(A6,A8,I3.3,A3,A)') &
        ' ', 'Opacity(',i,'): ', TRIM( Opacity % Names(i) )
      WRITE(*,'(A8,A12,A)') &
        ' ', 'Units     = ', TRIM( Opacity % Units(i) )
      WRITE(*,'(A8,A12,ES12.4E3)') &
        ' ', 'Min Value = ', MINVAL( Opacity % Absorptivity(i) % Values )
      WRITE(*,'(A8,A12,ES12.4E3)') &
        ' ', 'Max Value = ', MAXVAL( Opacity % Absorptivity(i) % Values )
      WRITE(*,'(A8,A12,ES12.4E3)') &
        ' ', 'Offset    = ', Opacity % Offsets(i)
    END DO
    WRITE(*,*)

  END SUBROUTINE DescribeOpacityTypeEmAb


  SUBROUTINE AllocateOpacityTypeB( Opacity, nPoints, nMoments, nOpacities )

    TYPE(OpacityTypeB), INTENT(inout) :: &
      Opacity
    INTEGER, DIMENSION(4), INTENT(in) :: &
      nPoints
    INTEGER, INTENT(in) :: &
      nMoments, &
      nOpacities

    INTEGER :: i

    Opacity % nOpacities = nOpacities
    Opacity % nMoments   = nMoments
    Opacity % nPoints    = nPoints

    ALLOCATE( Opacity % Names(nOpacities) )
    ALLOCATE( Opacity % Species(nOpacities) )
    ALLOCATE( Opacity % Units(nOpacities) )
    ALLOCATE( Opacity % Offsets(nOpacities, nMoments) )
    ALLOCATE( Opacity % Kernel(nOpacities) )

    DO i = 1, nOpacities

      ALLOCATE( Opacity % Kernel(i) % Values &
                  ( nPoints(1), nPoints(2), nPoints(3), nPoints(4), &
                    nMoments) )

    END DO

  END SUBROUTINE AllocateOpacityTypeB


  SUBROUTINE DeallocateOpacityTypeB( Opacity )

    TYPE(OpacityTypeB), INTENT(inout) :: Opacity

    INTEGER :: i

    DO i = 1, Opacity % nOpacities
      DEALLOCATE( Opacity % Kernel(i) % Values )
    END DO

    DEALLOCATE( Opacity % Kernel )
    DEALLOCATE( Opacity % Offsets )
    DEALLOCATE( Opacity % Units )
    DEALLOCATE( Opacity % Species )
    DEALLOCATE( Opacity % Names )

  END SUBROUTINE DeallocateOpacityTypeB


  SUBROUTINE DescribeOpacityTypeB( Opacity )

    TYPE(OpacityTypeB), INTENT(in) :: Opacity

    INTEGER :: i, l

    WRITE(*,*)
    WRITE(*,'(A4,A)') ' ', 'Opacity Type B'
    WRITE(*,'(A4,A)') ' ', '--------------'
    WRITE(*,'(A6,A13,I3.3)') &
      ' ', 'nOpacities = ', Opacity % nOpacities
    WRITE(*,'(A6,A13,I3.3)') &
      ' ', 'nMoments   = ', Opacity % nMoments
    WRITE(*,'(A6,A13,5I5.4)') &
      ' ', 'nPoints    = ', Opacity % nPoints, Opacity % nMoments
    WRITE(*,'(A6,A13,I10.10)') &
      ' ', 'DOFs       = ', &
      Opacity % nOpacities * Opacity % nMoments &
        * PRODUCT( Opacity % nPoints )

    DO i = 1, Opacity % nOpacities
      WRITE(*,*)
      WRITE(*,'(A6,A8,I3.3,A3,A)') &
        ' ', 'Opacity(',i,'): ', TRIM( Opacity % Names(i) )
      WRITE(*,'(A8,A12,A)') &
        ' ', 'Species   = ', TRIM( Opacity % Species(i) )
      WRITE(*,'(A8,A12,A)') &
        ' ', 'Units     = ', TRIM( Opacity % Units(i) )

      DO l = 1, Opacity % nMoments
      WRITE(*,*)
         WRITE(*,'(A8,A16,I3.3)') &
           ' ', 'For Moments l = ', l
         WRITE(*,'(A8,A12,ES12.4E3)') &
           ' ', 'Min Value = ', MINVAL( Opacity % Kernel(i) % Values(:,:,:,:,l) )
         WRITE(*,'(A8,A12,ES12.4E3)') &
           ' ', 'Max Value = ', MAXVAL( Opacity % Kernel(i) % Values(:,:,:,:,l) )
         WRITE(*,'(A8,A12,ES12.4E3)') &
           ' ', 'Offset    = ', Opacity % Offsets(i,l)
      END DO ! l = nMoment
      WRITE(*,*)
    END DO
    WRITE(*,*)

  END SUBROUTINE DescribeOpacityTypeB


  SUBROUTINE AllocateOpacityTypeC( Opacity, nPoints, nMoments, nOpacities )

    TYPE(OpacityTypeC), INTENT(inout) :: &
      Opacity
    INTEGER, DIMENSION(4), INTENT(in) :: &
      nPoints
    INTEGER, INTENT(in) :: &
      nMoments, &
      nOpacities

    INTEGER :: i

    Opacity % nOpacities = nOpacities
    Opacity % nMoments   = nMoments
    Opacity % nPoints    = nPoints

    ALLOCATE( Opacity % Names(nOpacities) )
    ALLOCATE( Opacity % Species(nOpacities) )
    ALLOCATE( Opacity % Units(nOpacities) )
    ALLOCATE( Opacity % Kernel(nOpacities) )

    DO i = 1, nOpacities
      ALLOCATE( Opacity % Kernel(i) % Values &
                  (nPoints(1), nPoints(1), nPoints(2), nPoints(3), &
                   nPoints(4), nMoments) )
    END DO

  END SUBROUTINE AllocateOpacityTypeC


  SUBROUTINE DeallocateOpacityTypeC( Opacity )

    TYPE(OpacityTypeC), INTENT(inout) :: Opacity

    INTEGER :: i

    DO i = 1, Opacity % nOpacities
      DEALLOCATE( Opacity % Kernel(i) % Values )
    END DO

    DEALLOCATE( Opacity % Kernel )
    DEALLOCATE( Opacity % Units )
    DEALLOCATE( Opacity % Species )
    DEALLOCATE( Opacity % Names )

  END SUBROUTINE DeallocateOpacityTypeC


  SUBROUTINE DescribeOpacityTypeC( Opacity )

    TYPE(OpacityTypeC), INTENT(in) :: Opacity

    INTEGER :: i

    WRITE(*,*)
    WRITE(*,'(A4,A)') ' ', 'Opacity Type C'
    WRITE(*,'(A4,A)') ' ', '--------------'
    WRITE(*,'(A6,A13,I3.3)') &
      ' ', 'nOpacities = ', Opacity % nOpacities
    WRITE(*,'(A6,A13,I3.3)') &
      ' ', 'nMoments   = ', Opacity % nMoments
    WRITE(*,'(A6,A13,4I5.4)') &
      ' ', 'nPoints    = ', Opacity % nPoints
    WRITE(*,'(A6,A13,I10.10)') &
      ' ', 'DOFs       = ', &
      Opacity % nOpacities * Opacity % nMoments &
        * Opacity % nPoints(1) * PRODUCT( Opacity % nPoints )

    DO i = 1, Opacity % nOpacities
      WRITE(*,*)
      WRITE(*,'(A6,A8,I3.3,A3,A)') &
        ' ', 'Opacity(',i,'): ', TRIM( Opacity % Names(i) )
      WRITE(*,'(A8,A12,A)') &
        ' ', 'Species   = ', TRIM( Opacity % Species(i) )
      WRITE(*,'(A8,A12,A)') &
        ' ', 'Units     = ', TRIM( Opacity % Units(i) )
      WRITE(*,'(A8,A12,ES12.4E3)') &
        ' ', 'Min Value = ', MINVAL( Opacity % Kernel(i) % Values )
      WRITE(*,'(A8,A12,ES12.4E3)') &
        ' ', 'Max Value = ', MAXVAL( Opacity % Kernel(i) % Values )
    END DO
    WRITE(*,*)

  END SUBROUTINE DescribeOpacityTypeC

END MODULE wlOpacityFieldsModule
