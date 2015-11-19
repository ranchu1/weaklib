MODULE wlEquationOfStateTableModule

  USE wlKindModule, ONLY: dp
  USE HDF5
  USE wlThermoStateModule
  USE wlDependentVariablesModule

  implicit none
  PRIVATE

  TYPE, PUBLIC :: EquationOfStateTableType
    !CHARACTER(LEN=32), DIMENSION(:), ALLOCATABLE :: Name
    INTEGER                                      :: nVariables
    INTEGER, DIMENSION(3)                        :: nPoints
    TYPE(ThermoStateType)           :: TS 
    TYPE(DependentVariablesType)    :: DV
  END TYPE


  PUBLIC AllocateEquationOfStateTable
  PUBLIC DeAllocateEquationOfStateTable
  PUBLIC TableLimitFail
  PUBLIC MatchTableStructure

CONTAINS 

  SUBROUTINE AllocateEquationOfStateTable( EOSTable, nPoints, nVariables )

    TYPE(EquationOfStateTableType), INTENT(inout)    :: EOSTable
    INTEGER, INTENT(in)               :: nVariables
    INTEGER, DIMENSION(3), INTENT(in) :: nPoints
   
    EOSTable % nPoints(1:3) = nPoints(1:3)
    EOSTable % nVariables = nVariables

    CALL AllocateThermoState( EOSTable % TS, EOSTable % nPoints )
    CALL AllocateDependentVariables( EOSTable % DV, EOSTable % nPoints, &
                                     EOSTable % nVariables ) 

  END SUBROUTINE AllocateEquationOfStateTable

  SUBROUTINE DeAllocateEquationOfStateTable( EOSTable )

    TYPE(EquationOfStateTableType) :: EOSTable

    CALL DeAllocateThermoState( EOSTable % TS )
    CALL DeAllocateDependentVariables( EOSTable % DV )

  END SUBROUTINE DeAllocateEquationOfStateTable

  LOGICAL FUNCTION TableLimitFail( rho, t, ye, EOSTable )

    !LOGICAL                                    :: TableLimitFail
    REAL(dp), INTENT(in)                       :: rho, t, ye
    TYPE(EquationOfStateTableType), INTENT(in) :: EOSTable

      TableLimitFail = .false.
      IF ( rho < EOSTable % TS % minValues(1) ) TableLimitFail = .true.
      IF ( rho > EOSTable % TS % maxValues(1) ) TableLimitFail = .true.
      IF (   t < EOSTable % TS % minValues(2) ) TableLimitFail = .true.
      IF (   t > EOSTable % TS % maxValues(2) ) TableLimitFail = .true.
      IF (  ye < EOSTable % TS % minValues(3) ) TableLimitFail = .true.
      IF (  ye > EOSTable % TS % maxValues(3) ) TableLimitFail = .true.

  END FUNCTION TableLimitFail

  SUBROUTINE MatchTableStructure( EOSTableIn, EOSTableOut, NewDVID, NewnVariables )
  
    TYPE(EquationOfStateTableType), INTENT(inout) :: EOSTableIn
    TYPE(EquationOfStateTableType), INTENT(out) :: EOSTableOut
    TYPE(DVIDType), INTENT(in)                 :: NewDVID
    INTEGER, INTENT(in)                        :: NewnVariables


    CALL AllocateEquationOfStateTable( EOSTableOut, EOSTableIn % nPoints, &
                                     NewnVariables )

    EOSTableOut % DV % Indices = NewDVID
    EOSTableOut % DV % Repaired(:,:,:) = EOSTableIn % DV % Repaired(:,:,:)

    EOSTableOut % TS = EOSTableIn % TS

    ASSOCIATE( &
    
    NewiPressure => NewDVID % iPressure, &
    NewiEntropy => NewDVID % iEntropyPerBaryon, &
    NewiIntEnergy => NewDVID % iInternalEnergyDensity, &
    NewiEChemPot => NewDVID % iElectronChemicalPotential, &
    NewiPChemPot => NewDVID % iProtonChemicalPotential, &
    NewiNChemPot => NewDVID % iNeutronChemicalPotential, &
    NewiPMassFrac => NewDVID % iProtonMassFraction, &
    NewiNMassFrac => NewDVID % iNeutronMassFraction, &
    NewiAMassFrac => NewDVID % iAlphaMassFraction, &
    NewiHMassFrac => NewDVID % iHeavyMassFraction, &
    NewiHCharNum => NewDVID % iHeavyChargeNumber, &
    NewiHMassNum => NewDVID % iHeavyMassNumber, &
    NewiHeavyBE => NewDVID % iHeavyBindingEnergy, &
    NewiThermEnergy => NewDVID % iThermalEnergy, &
    NewiGamma1 => NewDVID % iGamma1, &

    OldiPressure => EOSTableIn % DV % Indices % iPressure , &
    OldiEntropy => EOSTableIn % DV % Indices % iEntropyPerBaryon, &
    OldiIntEnergy => EOSTableIn % DV % Indices % iInternalEnergyDensity, &
    OldiEChemPot => EOSTableIn % DV % Indices % iElectronChemicalPotential, &
    OldiPChemPot => EOSTableIn % DV % Indices % iProtonChemicalPotential, &
    OldiNChemPot => EOSTableIn % DV % Indices % iNeutronChemicalPotential, &
    OldiPMassFrac => EOSTableIn % DV % Indices % iProtonMassFraction, &
    OldiNMassFrac => EOSTableIn % DV % Indices % iNeutronMassFraction, &
    OldiAMassFrac => EOSTableIn % DV % Indices % iAlphaMassFraction, &
    OldiHMassFrac => EOSTableIn % DV % Indices % iHeavyMassFraction, &
    OldiHCharNum => EOSTableIn % DV % Indices % iHeavyChargeNumber, &
    OldiHMassNum => EOSTableIn % DV % Indices % iHeavyMassNumber, &
    OldiHeavyBE => EOSTableIn % DV % Indices % iHeavyBindingEnergy, &
    OldiThermEnergy => EOSTableIn % DV % Indices % iThermalEnergy, &
    OldiGamma1 => EOSTableIn % DV % Indices % iGamma1 )

    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiPressure, OldiPressure )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiEntropy, OldiEntropy )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiIntEnergy, OldiIntEnergy )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiEChemPot, OldiEChemPot )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiPChemPot, OldiPChemPot )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiNChemPot, OldiNChemPot )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiPMassFrac, OldiPMassFrac )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiNMassFrac, OldiNMassFrac )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiAMassFrac, OldiAMassFrac )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiHMassFrac, OldiHMassFrac )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiHCharNum, OldiHCharNum )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiHMassNum, OldiHMassNum )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiHeavyBE, OldiHeavyBE )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiThermEnergy, OldiThermEnergy )
    CALL TransferDependentVariables( EOSTableIn % DV, EOSTableOut % DV, &
                                     NewiGamma1, OldiGamma1 )

    END ASSOCIATE

  END SUBROUTINE MatchTableStructure

  SUBROUTINE SwapDependentVariables( EOSTable, TargetBuffer, IndexBuffer )

    TYPE(EquationOfStateTableType), INTENT(inout)  :: EOSTable
    CHARACTER(LEN=32)                              :: NameBuffer
    CHARACTER(LEN=32)                              :: UnitBuffer
    INTEGER, INTENT(in)                            :: IndexBuffer
    INTEGER, INTENT(in)                            :: TargetBuffer
    REAL(dp), DIMENSION(:,:,:), ALLOCATABLE        :: ValuesBuffer

    ALLOCATE( ValuesBuffer( EOSTable % DV % nPoints(1), &
               EOSTable % DV % nPoints(2), EOSTable % DV % nPoints(3) ) )

      ValuesBuffer(:,:,:) = EOSTable % DV % Variables( TargetBuffer ) % Values(:,:,:)
      NameBuffer = EOSTable % DV % Names( TargetBuffer )
      UnitBuffer = EOSTable % DV % Units( TargetBuffer )

      EOSTable % DV % Variables( TargetBuffer ) % Values(:,:,:) &
                = EOSTable % DV % Variables( IndexBuffer ) % Values(:,:,:)
      EOSTable % DV % Names( TargetBuffer ) = EOSTable % DV % Names( IndexBuffer )
      EOSTable % DV % Units( TargetBuffer ) = EOSTable % DV % Units( IndexBuffer )

      EOSTable % DV % Variables( IndexBuffer ) % Values(:,:,:) = ValuesBuffer(:,:,:)
      EOSTable % DV % Names( IndexBuffer ) = NameBuffer
      EOSTable % DV % Units( IndexBuffer ) = UnitBuffer


      CALL IndexMatch( TargetBuffer, IndexBuffer, &
                       EOSTable % DV % Indices )

  END SUBROUTINE SwapDependentVariables

  SUBROUTINE TransferDependentVariables( OldDV, NewDV, NewLocation, OldLocation )

    TYPE(DependentVariablesType), INTENT(inout)  :: OldDV 
    TYPE(DependentVariablesType), INTENT(inout)  :: NewDV 
    INTEGER, INTENT(in)                          :: OldLocation
    INTEGER, INTENT(in)                          :: NewLocation

     IF ( NewLocation == 0 ) THEN
       WRITE (*,*) "Dependent Variable", OldDV % Names( OldLocation ), "omitted" 
       RETURN
     END IF

     NewDV % Variables( NewLocation ) % Values(:,:,:) &
               = OldDV % Variables( OldLocation ) % Values(:,:,:)
     NewDV % Names( NewLocation ) = OldDV % Names( OldLocation )
     NewDV % Units( NewLocation ) = OldDV % Units( OldLocation )
     NewDV % Offsets( NewLocation ) = OldDV % OffSets( OldLocation )

  END SUBROUTINE TransferDependentVariables

  SUBROUTINE IndexMatch( TargetBuffer, IndexBuffer, Indices )

    INTEGER, INTENT(in)        :: TargetBuffer
    INTEGER, INTENT(in)        :: IndexBuffer
    TYPE(DVIDType), INTENT(inout) :: Indices  

      IF ( TargetBuffer == 1) THEN 
      Indices % iPressure = IndexBuffer 
      ELSE IF ( TargetBuffer == 2) THEN 
      Indices % iEntropyPerBaryon = IndexBuffer 
      ELSE IF ( TargetBuffer == 3) THEN 
      Indices % iInternalEnergyDensity = IndexBuffer 
      ELSE IF ( TargetBuffer == 4) THEN 
      Indices % iElectronChemicalPotential = IndexBuffer 
      ELSE IF ( TargetBuffer == 5) THEN 
      Indices % iProtonChemicalPotential = IndexBuffer 
      ELSE IF ( TargetBuffer == 6) THEN 
      Indices % iNeutronChemicalPotential = IndexBuffer 
      ELSE IF ( TargetBuffer == 7) THEN 
      Indices % iProtonMassFraction = IndexBuffer 
      ELSE IF ( TargetBuffer == 8) THEN 
      Indices % iNeutronMassFraction = IndexBuffer 
      ELSE IF ( TargetBuffer == 9) THEN 
      Indices % iAlphaMassFraction = IndexBuffer 
      ELSE IF (TargetBuffer == 10) THEN 
      Indices % iHeavyMassFraction = IndexBuffer 
      ELSE IF (TargetBuffer == 11) THEN 
      Indices % iHeavyChargeNumber = IndexBuffer 
      ELSE IF (TargetBuffer == 12) THEN 
      Indices % iHeavyMassNumber = IndexBuffer 
      ELSE IF (TargetBuffer == 13) THEN 
      Indices % iHeavyBindingEnergy = IndexBuffer 
      ELSE IF (TargetBuffer == 14) THEN 
      Indices % iThermalEnergy = IndexBuffer 
      ELSE IF (TargetBuffer == 15) THEN 
      Indices % iGamma1 = IndexBuffer 
      END IF

  END SUBROUTINE IndexMatch


END MODULE wlEquationOfStateTableModule
