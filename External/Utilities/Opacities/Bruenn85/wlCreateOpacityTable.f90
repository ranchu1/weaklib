PROGRAM wlCreateOpacityTable
!---------------------------------------------------------------------
!
!    Author:       R. Chu, Dept. Phys. & Astronomy
!                  U. Tennesee, Knoxville
!
!    Created:      10/23/18
!    WeakLib ver:  
!
!    Purpose:
!      Create table for opacity containing EoS table with BoltzTran.
!      Existing EoS table is readin. 
!      Function were created to fill OpacityTable and Chimera
!      routines were called.
! 
!    CONTAINS:
!    
!    Modules used:
!
!---------------------------------------------------------------------
!  NOTE: Only Type A interaction applied. Type B and Type C 
!        interaction needs to be added for future use.
!---------------------------------------------------------------------
!                         Three Opacity Type
!
! OpacityType A for  ABEM( rho, T, Ye, E)
!
!       e- + p/A <--> v_e + n/A*
!
! OpacityType B for  ISO( e, rho, T, Ye, l)
!                        
!       v_i/anti(v_i) + A --> v_i/anti(v_i) + A 
!       v_i/anti(v_i) + e+/e-/n/p  <-->  v_i/anti(v_i) + e+/e-/n/p
!
! OpacityType C for  NISO( e_in, e_out, rho, T, Ye, l)
!
!       e+ + e-  <--> v_i + anti(v_i);   i=e, muon, tau
!       N + N   <--> N + N + v_i + anti(v_i)
!                 
!---------------------------------------------------------------------


  USE wlKindModule, ONLY: dp
  USE wlGridModule, ONLY: MakeLogGrid 
  USE wlIOModuleHDF, ONLY: &
      InitializeHDF,       &
      FinalizeHDF
  USE wlOpacityTableModule, ONLY: &
      OpacityTableType,     &
      AllocateOpacityTable, &
      DescribeOpacityTable, &
      DeAllocateOpacityTable
  USE wlOpacityTableIOModuleHDF, ONLY: &
      WriteOpacityTableHDF
  USE wlExtPhysicalConstantsModule, ONLY: kMeV
  USE wlExtNumericalModule, ONLY: epsilon
  USE B85_scattIso
  USE B85_scattNES
  USE B85_pair
  USE prb_cntl_module, ONLY: &
      i_aeps, iaefnp, rhoaefnp, iaence, iaenct, roaenct, &
      edmpa, edmpe, iaenca

IMPLICIT NONE

   INTEGER*4 today(3), now(3)

   CHARACTER(256) :: EOSTableName = "wl-EOS-SFHo-15-25-50.h5"
 
   TYPE(OpacityTableType)  :: OpacityTable
   INTEGER                 :: nOpac_EmAb = 0  ! 2
   INTEGER                 :: nOpac_Iso = 0   ! 2
   INTEGER                 :: nMom_Iso  = 0   ! 2
   INTEGER                 :: nOpac_NES = 0   ! 1
   INTEGER                 :: nMom_NES  = 0   ! 4
   INTEGER                 :: nOpac_Pair  = 1 ! 1
   INTEGER                 :: nMom_Pair   = 4 ! 4
!---------------------------------------------------------------------
! Set E grid limits
!---------------------------------------------------------------------
   INTEGER,  PARAMETER     :: nPointsE = 40 
   REAL(dp), PARAMETER     :: Emin = 1.0d-1  
   REAL(dp), PARAMETER     :: Emax = 3.0d02

!---------------------------------------------------------------------
! Set Eta grid limits
!---------------------------------------------------------------------
   INTEGER                 :: nPointsEta = 60  ! NES: 60      Pair: 50
   REAL(dp), PARAMETER     :: Etamin = 1.0d-3  ! NES: 1.0d-3  Pair: 1.0d-2
   REAL(dp), PARAMETER     :: Etamax = 2.5d03

   ! --- other inner variables
   INTEGER                 :: i_r, i_rb, i_e, j_rho, k_t, l_ye, &
                              t_m, i_quad, i_eta, i_ep
   REAL(dp)                :: energy, rho, T, TMeV, ye, Z, A, &
                              chem_e, chem_n, chem_p, xheavy, xn, &
                              xp, xhe, bb, eta, minvar 
   REAL(dp), DIMENSION(nPointsE) :: absor, emit 
   REAL(dp), DIMENSION(nPointsE,2) :: cok 
   REAL(dp), DIMENSION(nPointsE, nPointsE) :: H0i, H0ii, H1i, H1ii
   REAL(dp)                :: j0i, j0ii, j1i, j1ii
   REAL(dp)                :: buffer1, buffer2

   CALL idate(today)
   CALL itime(now)
   WRITE ( *, 10000 )  today(2), today(1), today(3), now

   10000 format ( ' Date ', i2.2, '/', i2.2, '/', i4.4, '; Time ',&
     &         i2.2, ':', i2.2, ':', i2.2 )

   CALL InitializeHDF( ) 
   CALL AllocateOpacityTable &
            ( OpacityTable, nOpac_EmAb, nOpac_Iso, nMom_Iso, &
              nOpac_NES, nMom_NES, nOpac_Pair, nMom_Pair, &
              nPointsE, nPointsEta, &
              EquationOfStateTableName_Option = EOSTableName ) 
   CALL FinalizeHDF( )

! -- Set OpacityTableTypeEmAb  

   IF( nOpac_EmAb .gt. 0 ) THEN

   OpacityTable % EmAb % nOpacities = nOpac_EmAb

   OpacityTable % EmAb % nPoints(1) = nPointsE

   OpacityTable % EmAb % nPoints(2:4) = OpacityTable % nPointsTS

   OpacityTable % EmAb % Names = &
                                (/'Electron Neutrino           ',  &  
                                  'Electron Antineutrino       '/)

   OpacityTable % EmAb % Units = &
                                (/'Per Centimeter              ',  &
                                  'Per Centimeter              '/) 

   END IF
! -- Set OpacityTableTypeScat Iso
   IF( nOpac_Iso.gt. 0 ) THEN

   OpacityTable % Scat_Iso % nOpacities = nOpac_Iso
   
   OpacityTable % Scat_Iso % nMoments = nMom_Iso
   
   OpacityTable % Scat_Iso % nPoints(1) = nPointsE
   OpacityTable % Scat_Iso % nPoints(2) = nMom_Iso
   OpacityTable % Scat_Iso % nPoints(3:5) = OpacityTable % nPointsTS

   OpacityTable % Scat_Iso % Names = &
                                (/'Electron Neutrino           ',  &
                                  'Electron Antineutrino       '/)

   OpacityTable % Scat_Iso % Units = &
                                (/'Per Centimeter              ',  &
                                  'Per Centimeter              '/)
   END IF

! -- Set OpacityTableTypeScat NES
   IF( nOpac_NES .gt. 0 ) THEN

   OpacityTable % Scat_NES % nOpacities = nOpac_NES

   OpacityTable % Scat_NES % nMoments   = nMom_NES

   OpacityTable % Scat_NES % nPoints(1) = nPointsE
   OpacityTable % Scat_NES % nPoints(2) = nPointsE
   OpacityTable % Scat_NES % nPoints(3) = nMom_NES
   OpacityTable % Scat_NES % nPoints(4) = OpacityTable % nPointsTS(2)
   OpacityTable % Scat_NES % nPoints(5) = nPointsEta

   OpacityTable % Scat_NES % Names = &
                                (/'Kernels'/)

   OpacityTable % Scat_NES % Units = &
                                (/'Per Centimeter Per MeV^3'/)
   END IF
! -- Set OpacityTableTypeScat Pair

   IF( nOpac_Pair .gt. 0 ) THEN
   OpacityTable % Scat_Pair % nOpacities = nOpac_Pair

   OpacityTable % Scat_Pair % nMoments   = nMom_Pair

   OpacityTable % Scat_Pair % nPoints(1) = nPointsE
   OpacityTable % Scat_Pair % nPoints(2) = nPointsE
   OpacityTable % Scat_Pair % nPoints(3) = nMom_Pair
   OpacityTable % Scat_Pair % nPoints(4) = OpacityTable % nPointsTS(2)
   OpacityTable % Scat_Pair % nPoints(5) = nPointsEta

   OpacityTable % Scat_Pair % Names = (/'Kernels'/)

   OpacityTable % Scat_Pair % Units = (/'Per Centimeter Per MeV^3'/)
   END IF
!-----------------------------   
! Generate E grid from limits
!-----------------------------
PRINT*, "Making Energy Grid ... "

   ASSOCIATE( EnergyGrid => OpacityTable % EnergyGrid )

   EnergyGrid % Name &
     = 'Comoving Frame Neutrino Energy'

   EnergyGrid % Unit &
     = 'MeV                           '

   EnergyGrid % MinValue = Emin
   EnergyGrid % MaxValue = Emax
   EnergyGrid % LogInterp = 1

   CALL MakeLogGrid &
          ( EnergyGrid % MinValue, EnergyGrid % MaxValue, &
            EnergyGrid % nPoints,  EnergyGrid % Values )
 
   END ASSOCIATE ! EnergyGrid

!-----------------------------
! Generate Eta grid from limits
!-----------------------------
PRINT*, "Making Eta Grid ... "

   ASSOCIATE( EtaGrid => OpacityTable % EtaGrid )

   EtaGrid % Name &
     = 'Elect. Chem. Pot. / Temperature'

   EtaGrid % Unit &
     = 'DIMENSIONLESS                   '

   EtaGrid % MinValue = Etamin
   EtaGrid % MaxValue = Etamax
   EtaGrid % LogInterp = 1

   CALL MakeLogGrid &
          ( EtaGrid % MinValue, EtaGrid % MaxValue, &
            EtaGrid % nPoints, EtaGrid % Values )

   END ASSOCIATE ! EtaGrid

!---------------------------------------------------------------------
!              Fill OpacityTable
!---------------------------------------------------------------------

PRINT*, 'Filling OpacityTable ...'
   ASSOCIATE(  & 
       iRho    => OpacityTable % EOSTable % TS % Indices % iRho , &
       iT      => OpacityTable % EOSTable % TS % Indices % iT   , &
       iYe     => OpacityTable % EOSTable % TS % Indices % iYe  , &
       Indices => OpacityTable % EOSTable % DV % Indices        , &
       DVOffs  => OpacityTable % EOSTable % DV % Offsets        , &
       DVar    => OpacityTable % EOSTable % DV % Variables  )

!-----------------  ECAPEM -------------------- 
  IF( ( nOpac_EmAb + nOpac_Iso ) .gt. 0 ) THEN
  PRINT*, 'Calculating EmAb and Elastic Scattering Kernel ...'

   DO l_ye = 1, OpacityTable % nPointsTS(iYe)
   
     ye = OpacityTable % EOSTable % TS % States (iYe) % Values (l_ye)

     DO k_t = 1, OpacityTable % nPointsTS(iT)

       T = OpacityTable % EOSTable % TS % States (iT) % Values (k_t)

       DO j_rho = 1, OpacityTable % nPointsTS(iRho)

         rho = OpacityTable % EOSTable % TS % States (iRho) % &
               Values (j_rho)

         chem_e = 10**DVar(Indices % iElectronChemicalPotential) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iElectronChemicalPotential)   &
                  - epsilon            

         chem_p = 10**DVar(Indices % iProtonChemicalPotential) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iProtonChemicalPotential)   &
                  - epsilon 

         chem_n = 10**DVar(Indices % iNeutronChemicalPotential) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iNeutronChemicalPotential)   &
                  - epsilon

            xp  = 10**DVar(Indices % iProtonMassFraction) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iProtonMassFraction)   &
                  - epsilon

            xn  = 10**DVar(Indices % iNeutronMassFraction) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iNeutronMassFraction)   &
                  - epsilon

           xhe  = 10**DVar(Indices % iAlphaMassFraction) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iAlphaMassFraction)   &
                  - epsilon

        xheavy  = 10**DVar(Indices % iHeavyMassFraction) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iHeavyMassFraction)   &
                  - epsilon

            Z   = 10**DVar(Indices % iHeavyChargeNumber) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iHeavyChargeNumber)   &
                  - epsilon

            A   = 10**DVar(Indices % iHeavyMassNumber) % &
                  Values(j_rho, k_t, l_ye) &
                  - DVOffs(Indices % iHeavyMassNumber)   &
                  - epsilon
  
            bb  = (chem_e + chem_p - chem_n)/(T*kMev)
       
         DO i_r = 1, nOpac_EmAb
          
             iaefnp = 1
             i_aeps = 0
             rhoaefnp = HUGE(1.d0) ! (?) 
             iaence = 1
             edmpe = 3.d0
             iaenca = 1 
             edmpa = 3.d0
             iaenct = 0
             roaenct = TINY(1.d0)

             CALL abemrgn_weaklib &
                  ( i_r, OpacityTable % EnergyGrid % Values, &
                    rho, T, xn, xp, xheavy, &
                    A, Z, chem_n, chem_p, chem_e, & 
                    absor, emit, ye, nPointsE )

             DO i_e = 1, OpacityTable % nPointsE
                OpacityTable % EmAb % Opacity(i_r) % &
                        Values (i_e, j_rho, k_t, l_ye) &
                = absor(i_e) + emit(i_e)
             END DO  !i_e

         END DO !i_r

!----------------  Scat_Iso -----------------------
         DO i_rb = 1, nOpac_Iso

           CALL scatical_weaklib &
           ( i_rb, OpacityTable % EnergyGrid % Values, &
             nPointsE, rho, T, xn, xp, xhe, xheavy, A, Z, cok )

           DO t_m = 1, nMom_Iso

             OpacityTable % Scat_Iso % Kernel(i_rb) % Values &
             ( :, t_m, j_rho, k_t, l_ye )  = cok(:,t_m) 

           END DO !t_m         

         END DO !i_rb

       END DO  !j_rho
     END DO  !k_t
   END DO  !l_ye

!------- EmAb % Offsets
   DO i_r = 1, nOpac_EmAb  
     minvar = MINVAL( OpacityTable % EmAb % Opacity(i_r) % Values )
     OpacityTable % EmAb % Offsets(i_r) = -2.d0 * MIN( 0.d0, minvar ) 
   END DO

!------- Scat_Iso % Offsets
   DO i_r = 1, nOpac_Iso
     DO t_m = 1, nMom_Iso
       minvar = MINVAL( OpacityTable % Scat_Iso % Kernel(i_r) &
                       % Values(:,t_m,:,:,:) )
       OpacityTable % Scat_Iso % Offsets(i_r, t_m) =           &
                      -2.d0 * MIN( 0.d0, minvar )
     END DO
   END DO

   END IF
!----------------  Scat_NES -----------------------
  IF( nOpac_NES .gt. 0 ) THEN
  PRINT*, 'Calculating Scat_NES Kernel ... '

      DO i_eta = 1, nPointsEta
       
        eta = OpacityTable % EtaGrid % Values(i_eta)
      
        DO k_t = 1, OpacityTable % nPointsTS(iT)

          T = OpacityTable % EOSTable % TS % States (iT) % Values (k_t)
          TMeV = T * kMeV

          CALL scatergn_weaklib &
               ( nPointsE, OpacityTable % EnergyGrid % Values, &
                 TMeV, eta, H0i, H0ii, H1i, H1ii )

          OpacityTable % Scat_NES % Kernel(1) % Values &
               ( :, :, 1, k_t, i_eta )       &
          = TRANSPOSE(H0i(:,:)) ! H0i was saved as H0i(e,ep)

          OpacityTable % Scat_NES % Kernel(1) % Values &
               ( :, :, 2, k_t, i_eta)       &
          = TRANSPOSE(H0ii(:,:)) ! H0ii was saved as H0ii(e,ep)

          OpacityTable % Scat_NES % Kernel(1) % Values &
               ( :, :, 3, k_t, i_eta )       &
          = TRANSPOSE(H1i(:,:)) ! H1i was saved as H1i(e,ep)
          OpacityTable % Scat_NES % Kernel(1) % Values &
               ( :, :, 4, k_t, i_eta )       &
          = TRANSPOSE(H1ii(:,:)) ! H1ii was saved as H1ii(e,ep)

        END DO  !k_t

      END DO !i_eta

!------- Scat_NES % Offsets
    DO i_rb = 1, nOpac_NES
      DO t_m = 1, nMom_NES

       minvar = MINVAL( OpacityTable % Scat_NES % Kernel(i_rb) &
                       % Values(:,:,t_m,:,: ) )
       OpacityTable % Scat_NES % Offsets(i_rb, t_m) =          &
                      -2.d0 * MIN( 0.d0, minvar ) 

    END DO ! t_m
  END DO ! i_rb
  END IF
    
!----------------  Scat_Pair -----------------------

  IF( nOpac_Pair .gt. 0 ) THEN
  PRINT*, 'Calculating Scat_Pair Kernel ... '

      DO i_eta = 1, nPointsEta
   
        eta = OpacityTable % EtaGrid % Values(i_eta)
      
        DO k_t = 1, OpacityTable % nPointsTS(iT)

          T = OpacityTable % EOSTable % TS % States (iT) % Values (k_t)
          TMeV = T * kMeV
          chem_e = TMeV * eta

          DO i_e = 1, nPointsE
          
            DO i_ep = 1, nPointsE
             
             CALL paircal_weaklib &
                  ( OpacityTable % EnergyGrid % Values(i_e),  &
                    OpacityTable % EnergyGrid % Values(i_ep), &
                    chem_e, T, j0i, j0ii, j1i, j1ii )

             OpacityTable % Scat_Pair % Kernel(1) % Values  &
                          ( i_ep, i_e, 1, k_t, i_eta )       &
              = j0i

             OpacityTable % Scat_Pair % Kernel(1) % Values  &
                          ( i_ep, i_e, 2, k_t, i_eta )       &
              = j0ii

             OpacityTable % Scat_Pair % Kernel(1) % Values  &
                          ( i_ep, i_e, 3, k_t, i_eta )       &
              = j1i

             OpacityTable % Scat_Pair % Kernel(1) % Values  &
                          ( i_ep, i_e, 4, k_t, i_eta )       &
              = j1ii

            END DO ! i_ep
          END DO ! i_e
        END DO  !k_t
      END DO !i_eta

!------- Scat_Pair % Offsets
  DO i_rb = 1, nOpac_Pair
    DO t_m = 1, nMom_Pair

       minvar = MINVAL( OpacityTable % Scat_Pair % Kernel(i_rb) &
                       % Values(:,:,t_m,:,:) )
       OpacityTable % Scat_Pair % Offsets(i_rb, t_m) =          &
                      -2.d0 * MIN( 0.d0, minvar ) 
    END DO ! t_m
  END DO ! i_rb
  END IF

   END ASSOCIATE ! rho-T-Ye
!---------------------------------------------------------------------
!      Describe the Table ( give the real physical value )            
!---------------------------------------------------------------------

  CALL DescribeOpacityTable( OpacityTable )

! --------------------------------------------------------------------
!          LOG the WHOLE table for storage
! --------------------------------------------------------------------

  WRITE(*,*) 'LOG the whole table with relevant offset for storage'

  DO i_r = 1, nOpac_EmAb
     OpacityTable % EmAb % Opacity(i_r) % Values&
     = LOG10( OpacityTable % EmAb % Opacity(i_r) % &
              Values + OpacityTable % EmAb % Offsets(i_r) + epsilon )
  END DO  !i_r

  DO i_rb = 1, nOpac_Iso
    DO t_m = 1, nMom_Iso
      OpacityTable % Scat_Iso % Kernel(i_rb) % Values(:,t_m,:,:,:) &
      = LOG10 ( OpacityTable % Scat_Iso % Kernel(i_rb) % Values(:,t_m,:,:,:) &
                + OpacityTable % Scat_Iso % Offsets(i_rb,t_m) + epsilon )
    END DO ! t_m
  END DO ! i_rb

  DO i_rb = 1, nOpac_NES
    DO t_m = 1, nMom_NES
      OpacityTable % Scat_NES % Kernel(i_rb) % Values(:,:,t_m,:,:) &
      = LOG10 ( OpacityTable % Scat_NES % Kernel(i_rb) % Values(:,:,t_m,:,:) &
                + OpacityTable % Scat_NES % Offsets(i_rb, t_m) + epsilon )
    END DO
  END DO !i_rb

  DO i_rb = 1, nOpac_Pair
    DO t_m = 1, nMom_Pair
      OpacityTable % Scat_Pair % Kernel(i_rb) % Values(:,:,t_m,:,:) &
      = LOG10 ( OpacityTable % Scat_Pair % Kernel(i_rb) % Values(:,:,t_m,:,:) &
                + OpacityTable % Scat_Pair % Offsets(i_rb, t_m) + epsilon )
    END DO
  END DO !i_rb

! -- write into hdf5 file

  IF( nOpac_EmAb > 0 ) THEN
    CALL InitializeHDF( )
    WRITE(*,*) 'Write EmAb data into file temp_EmAb.h5 '
    CALL WriteOpacityTableHDF &
         ( OpacityTable, "temp_EmAb.h5", WriteOpacity_EmAb_Option = .true. )
    CALL FinalizeHDF( )
  END IF

  IF( nOpac_Iso> 0 ) THEN
    CALL InitializeHDF( )
    WRITE(*,*) 'Write Iso data into file temp_Iso.h5 '
    CALL WriteOpacityTableHDF &
         ( OpacityTable, "temp_Iso.h5", WriteOpacity_Iso_Option = .true. )
    CALL FinalizeHDF( )
  END IF
 
  IF( nOpac_NES > 0 ) THEN
    CALL InitializeHDF( )
    WRITE(*,*) 'Write Iso data into file temp_NES.h5 '
    CALL WriteOpacityTableHDF &
         ( OpacityTable, "temp_NES.h5", WriteOpacity_NES_Option = .true. )
    CALL FinalizeHDF( )
  END IF

  IF( nOpac_Pair > 0 ) THEN
    CALL InitializeHDF( )
    WRITE(*,*) 'Write Iso data into file temp_Pair.h5 '
    CALL WriteOpacityTableHDF &
         ( OpacityTable, "temp_Pair.h5", WriteOpacity_Pair_Option = .true. )
    CALL FinalizeHDF( )
  END IF
 
  WRITE (*,*) "HDF write successful"

  CALL DeAllocateOpacityTable( OpacityTable )
  !=============================================================

  CALL itime(now)
  WRITE ( *, 10000 )  today(2), today(1), today(3), now

END PROGRAM wlCreateOpacityTable
