MODULE wlOpacityTableIOModuleHDF
!-----------------------------------------------------------------------
!
!    File:         wlOpacityTableIOModuleHDF.f90
!    Module:       wlOpacityTableIOModuleHDF
!    Type:         Module w/ Subroutines
!    Author:       R. Chu, Dept. Phys. & Astronomy
!                  U. Tennesee, Knoxville
!
!    Created:      3/22/16
!    WeakLib ver:  
!
!    Purpose:
!      Subroutines needed for reading, printing OpacityTable
!
!    CONTAINS:
!       DescribeOpacityTable
!
!    Modules used:
!       wlOpacityTableModule, ONLY: OpacityTableType, OpacityTypeA
!       wlEOSIOModuleHDF, ONLY: DescribeEquationOfStateTable
!       wlGridModule, ONLY: EnergyGridType
!       wlKindModule, ONLY:dp
!       HDF5
!       wlIOModuleHDF
!       wlEquationOfStateTableModule
!
!-----------------------------------------------------------------------
!  NOTE: Only Type A interaction applied. Type B and Type C interaction 
!        needs to be added for future use.
!-----------------------------------------------------------------------

  USE wlKindModule, ONLY:dp
  USE wlEnergyGridModule, ONLY: &
    EnergyGridType
  USE wlOpacityTableModule, ONLY:&
    OpacityTableType,&
    AllocateOpacityTable
  USE wlOpacityFieldsModule, ONLY:&
    OpacityTypeA, OpacityTypeB, OpacityTypeC
  USE wlIOModuleHDF
  USE wlEquationOfStateTableModule

  USE HDF5

  IMPLICIT NONE
  PRIVATE

  INTEGER :: hdferr

  PUBLIC WriteOpacityTableHDF
  PUBLIC ReadOpacityTableHDF

CONTAINS
 
  SUBROUTINE WriteOpacityTableHDF( OpacityTable )
 
    TYPE(OpacityTableType), INTENT(inout) :: OpacityTable

    INTEGER(HID_T)                                :: file_id
    INTEGER(HID_T)                                :: group_id

    CHARACTER(LEN=32), DIMENSION(1)             :: tempString
    INTEGER, DIMENSION(1)                       :: tempInteger
    INTEGER(HSIZE_T), DIMENSION(1)              :: datasize1d
   
    CALL OpenFileHDF( "OpacityTable_NS.h5", .true., file_id )

    datasize1d(1) = 1
    tempInteger(1) = OpacityTable % nOpacitiesA
    CALL Write1dHDF_integer&
         ( "nOpacitiesA", tempInteger, file_id, datasize1d )

    tempInteger(1) = OpacityTable % nOpacitiesB 
    CALL Write1dHDF_integer&
         ( "nOpacitiesB", tempInteger, file_id, datasize1d )
  
    tempInteger(1) = OpacityTable % nMomentsB     
    CALL Write1dHDF_integer&
         ( "nMomentsB", tempInteger, file_id, datasize1d )

    tempInteger(1) = OpacityTable % nOpacitiesC     
    CALL Write1dHDF_integer&
         ( "nOpacitiesC", tempInteger, file_id, datasize1d )

    tempInteger(1) = OpacityTable % nMomentsC   
    CALL Write1dHDF_integer&
         ( "nMomentsC", tempInteger, file_id, datasize1d )

    tempInteger(1) = OpacityTable % nPointsE  
    CALL Write1dHDF_integer&
         ( "nPointsE", tempInteger, file_id, datasize1d )

    datasize1d = 3
    CALL Write1dHDF_integer&
         ( "nPointsTS", OpacityTable % nPointsTS, file_id, datasize1d )

    CALL OpenGroupHDF( "thermEmAb", .true., file_id, group_id )
    CALL WriteOpacityTableTypeAHDF( OpacityTable % thermEmAb, group_id )
    CALL CloseGroupHDF( group_id )

    CALL OpenGroupHDF( "scatt_Iso", .true., file_id, group_id )
    CALL WriteOpacityTableTypeBHDF( OpacityTable % scatt_Iso, group_id )
    CALL CloseGroupHDF( group_id )

    CALL OpenGroupHDF( "scatt_nIso", .true., file_id, group_id )
    CALL WriteOpacityTableTypeCHDF( OpacityTable % scatt_nIso, group_id )
    CALL CloseGroupHDF( group_id )   

    CALL OpenGroupHDF( "EnergyGrid", .true., file_id, group_id )
    CALL WriteEnergyGridHDF( OpacityTable % EnergyGrid, group_id )
    CALL CloseGroupHDF( group_id )

!    CALL OpenGroupHDF( "EOSTable", .true., file_id, group_id )
!    CALL WriteEOSTableHDF( OpacityTable % EOSTable, file_id, group_id )
!    CALL CloseGroupHDF( group_id )
     
    CALL CloseFileHDF( file_id )

  END SUBROUTINE WriteOpacityTableHDF


  SUBROUTINE WriteEOSTableHDF( EOSTable, file_id, group_id )

    TYPE(EquationOfStateTableType), INTENT(in)    :: EOSTable
    INTEGER(HID_T), INTENT(in)                    :: file_id
    INTEGER(HID_T), INTENT(in)                    :: group_id

    INTEGER(HID_T)                                :: subgroup_id

    CALL OpenGroupHDF( "ThermoState", .true., group_id, subgroup_id )
    CALL WriteThermoStateHDF( EOSTable % TS, subgroup_id )
    CALL CloseGroupHDF( subgroup_id )

    CALL OpenGroupHDF( "DependentVariables", .true., group_id, subgroup_id )
    CALL WriteDependentVariablesHDF( EOSTable % DV, subgroup_id )
    CALL CloseGroupHDF( subgroup_id )

  END SUBROUTINE WriteEOSTableHDF


  SUBROUTINE WriteEnergyGridHDF( EnergyGrid, group_id )

    TYPE(EnergyGridType), INTENT(in)           :: EnergyGrid
    INTEGER(HID_T), INTENT(in)                 :: group_id

    INTEGER(HSIZE_T), DIMENSION(1)              :: datasize1d
    INTEGER                                     :: i
    INTEGER, DIMENSION(1)                       :: buffer

    CHARACTER(LEN=32), DIMENSION(1)             :: tempString
    INTEGER, DIMENSION(1)                       :: tempInteger          

    datasize1d(1) = 1

    tempString(1) = EnergyGrid % Name
    CALL Write1dHDF_string( "Name", tempString, &
                             group_id, datasize1d )
    
    tempString(1) = EnergyGrid % Unit
    CALL Write1dHDF_string( "Unit", tempString, &
                            group_id, datasize1d )

    tempInteger(1) = EnergyGrid % nPoints  
    CALL Write1dHDF_integer( "nPoints", tempInteger, &
                            group_id, datasize1d )
   
    tempInteger(1) = EnergyGrid % LogInterp 
    CALL Write1dHDF_integer( "LogInterp", tempInteger, &
                             group_id, datasize1d )
   
    datasize1d(1) = EnergyGrid % nPoints
    CALL Write1dHDF_double( "Values", EnergyGrid % Values(:), &
                              group_id, datasize1d )
  
  END SUBROUTINE WriteEnergyGridHDF


  SUBROUTINE WriteOpacityTableTypeAHDF( thermEmAb, group_id )

    TYPE(OpacityTypeA), INTENT(in)              :: thermEmAb
    INTEGER(HID_T), INTENT(in)                  :: group_id

    INTEGER(HSIZE_T)                            :: datasize1d
    INTEGER(HSIZE_T), DIMENSION(4)              :: datasize4d
    INTEGER                                     :: i
    INTEGER, DIMENSION(1)                       :: buffer


    CHARACTER(LEN=32), DIMENSION(1)             :: tempString
    INTEGER, DIMENSION(1)                       :: tempInteger
    INTEGER(HSIZE_T), DIMENSION(1)              :: datasize1dtemp

    INTEGER(HID_T)                                :: subgroup_id


    datasize1dtemp(1) = 1
    tempInteger(1) = thermEmAb % nOpacities
    CALL Write1dHDF_integer&
         ( "nOpacities", tempInteger, group_id, datasize1dtemp )

    datasize1dtemp(1) = 4
    CALL Write1dHDF_integer&
         ( "nPoints", thermEmAb % nPoints, group_id, datasize1dtemp )

    datasize1dtemp(1) = thermEmAb % nOpacities
    CALL Write1dHDF_string&
         ( "Names", thermEmAb % Names, group_id, datasize1dtemp ) 

    CALL Write1dHDF_string&
         ( "Species", thermEmAb % Species, group_id, datasize1dtemp ) 

    CALL Write1dHDF_string&
         ( "Units", thermEmAb % Units, group_id, datasize1dtemp ) 

    datasize1d = thermEmAb % nOpacities 
    datasize4d = thermEmAb % nPoints
    CALL OpenGroupHDF( "Absorptivity", .true., group_id, subgroup_id )
    DO i = 1, datasize1d
      CALL Write4dHDF_double( thermEmAb % Names(i), thermEmAb % Absorptivity(i) % Values(:,:,:,:), &
                              subgroup_id, datasize4d )
    END DO
    CALL CloseGroupHDF( subgroup_id )
 
  END SUBROUTINE WriteOpacityTableTypeAHDF

  SUBROUTINE WriteOpacityTableTypeBHDF( scattI , group_id )

    TYPE(OpacityTypeB), INTENT(in)              :: scattI
    INTEGER(HID_T), INTENT(in)                  :: group_id

  END SUBROUTINE WriteOpacityTableTypeBHDF

  SUBROUTINE WriteOpacityTableTypeCHDF( scattn, group_id )

    TYPE(OpacityTypeC), INTENT(in)              :: scattn
    INTEGER(HID_T), INTENT(in)                  :: group_id

  END SUBROUTINE WriteOpacityTableTypeCHDF



  SUBROUTINE Write4dHDF_double &
              ( name, values, group_id, datasize, desc_option, unit_option )

    CHARACTER(*), INTENT(in)                    :: name
    CHARACTER(*), INTENT(in), OPTIONAL          :: unit_option
    CHARACTER(*), INTENT(in), OPTIONAL          :: desc_option
    INTEGER(HID_T)                              :: group_id
    INTEGER(HSIZE_T), DIMENSION(4), INTENT(in)  :: datasize
    REAL(dp), DIMENSION(:,:,:,:), INTENT(in)      :: values
   
    INTEGER(HID_T)                              :: dataset_id
    INTEGER(HID_T)                              :: dataspace_id
    INTEGER(HID_T)                              :: atype_id
    INTEGER(HID_T)                              :: attr_id
    INTEGER(SIZE_T)                             :: attr_len
    INTEGER(HSIZE_T), DIMENSION(1)              :: adims = (/1/)
  
    
    CALL h5screate_simple_f( 4, datasize, dataspace_id, hdferr )

    CALL h5dcreate_f( group_id, name, H5T_NATIVE_DOUBLE, &
           dataspace_id, dataset_id, hdferr )

    CALL h5dwrite_f( dataset_id, H5T_NATIVE_DOUBLE, &
           values, datasize, hdferr )

    CALL h5sclose_f( dataspace_id, hdferr ) 

    CALL h5dclose_f( dataset_id, hdferr )

  END SUBROUTINE Write4dHDF_double


  SUBROUTINE ReadOpacityTableHDF( OpacityTable, FileName )
 
    TYPE(OpacityTableType), INTENT(inout)   :: OpacityTable
    CHARACTER(len=*), INTENT(in)            :: FileName

    INTEGER, DIMENSION(3)                         :: nPointsTS
    INTEGER                                       :: nPointsE
    INTEGER                                       :: nOpacA
    INTEGER                                       :: nOpacB, nMomB
    INTEGER                                       :: nOpacC, nMomC
    INTEGER(HID_T)                                :: file_id
    INTEGER(HID_T)                                :: group_id
    INTEGER(HID_T)                                :: subgroup_id
    INTEGER(HSIZE_T), DIMENSION(1)                :: datasize1d
    INTEGER, DIMENSION(1)                         :: buffer
    CHARACTER(LEN=32), DIMENSION(1)               :: buffer_string

    CALL OpenFileHDF( FileName, .false., file_id )

    datasize1d(1) = 1
    CALL Read1dHDF_integer( "nOpacitiesA", buffer, file_id, datasize1d )
    nOpacA = buffer(1)   

    CALL Read1dHDF_integer( "nOpacitiesB", buffer, file_id, datasize1d )
    nOpacB = buffer(1)

    CALL Read1dHDF_integer( "nMomentsB", buffer, file_id, datasize1d )
    nMomB = buffer(1)

    CALL Read1dHDF_integer( "nOpacitiesC", buffer, file_id, datasize1d )
    nOpacC = buffer(1)

    CALL Read1dHDF_integer( "nMomentsC", buffer, file_id, datasize1d )
    nMomC = buffer(1)

    CALL Read1dHDF_integer( "nPointsE", buffer, file_id, datasize1d )
    nPointsE = buffer(1)

    CALL Read1dHDF_integer( "nPointsTS", nPointsTS, file_id, datasize1d )

    CALL AllocateOpacityTable &
               ( OpacityTable, nOpacA, nOpacB, nMomB, nOpacC, nMomC, nPointsE )  
    
    CALL OpenGroupHDF( "thermEmAb", .false., file_id, group_id )
    CALL ReadOpacityTypeAHDF( OpacityTable % thermEmAb, group_id )
    CALL CloseGroupHDF( group_id )

    CALL OpenGroupHDF( "scatt_Iso", .false., file_id, group_id )
    CALL ReadOpacityTypeBHDF( OpacityTable % scatt_Iso , group_id )
    CALL CloseGroupHDF( group_id )

    CALL OpenGroupHDF( "scatt_nIso", .false., file_id, group_id )
    CALL ReadOpacityTypeCHDF( OpacityTable % scatt_nIso , group_id )
    CALL CloseGroupHDF( group_id )

    CALL OpenGroupHDF( "EnergyGrid", .false., file_id, group_id )
    CALL ReadEnergyGridHDF( OpacityTable % EnergyGrid, group_id )
    CALL CloseGroupHDF( group_id )
 
    CALL CloseFileHDF( file_id )

  END SUBROUTINE ReadOpacityTableHDF


  SUBROUTINE ReadOpacityTypeAHDF( thermEmAb, group_id )

    TYPE(OpacityTypeA),INTENT(inout)                 :: thermEmAb
    INTEGER(HID_T), INTENT(in)                       :: group_id


    INTEGER(HSIZE_T), DIMENSION(1)                   :: datasize1d
    INTEGER(HSIZE_T), DIMENSION(4)                   :: datasize4d
    INTEGER                                          :: i
    INTEGER, DIMENSION(1)                            :: buffer
    INTEGER(HID_T)                                   :: subgroup_id

    datasize1d(1) = 1
    CALL Read1dHDF_integer( "nOpacities", buffer, group_id, datasize1d )
    thermEmAb % nOpacities = buffer(1)

    datasize1d = buffer(1)
    Call Read1dHDF_string( "Names", thermEmAb % Names, group_id, datasize1d )

    Call Read1dHDF_string( "Units", thermEmAb % Units, group_id, datasize1d )

    CALL Read1dHDF_string( "Species", thermEmAb % Species, group_id, datasize1d )

    datasize1d(1) = 4
    CALL Read1dHDF_integer( "nPoints", thermEmAb % nPoints, group_id, datasize1d )

    datasize4d = thermEmAb % nPoints

    CALL OpenGroupHDF( "Absorptivity", .false., group_id, subgroup_id )
    DO i = 1, thermEmAb % nOpacities
    WRITE (*,*) 'Reading', ' ', thermEmAb % Names(i)
    CALL Read4dHDF_double( thermEmAb % Names(i), thermEmAb % Absorptivity(i) % Values, subgroup_id, datasize4d )
    END DO
    CALL CloseGroupHDF( subgroup_id )

  END SUBROUTINE ReadOpacityTypeAHDF



  SUBROUTINE ReadOpacityTypeBHDF( thermEmAb, group_id )

    TYPE(OpacityTypeB),INTENT(inout)                 :: thermEmAb
    INTEGER(HID_T), INTENT(in)                       :: group_id
  END SUBROUTINE ReadOpacityTypeBHDF

  SUBROUTINE ReadOpacityTypeCHDF( thermEmAb, group_id )

    TYPE(OpacityTypeC),INTENT(inout)                 :: thermEmAb
    INTEGER(HID_T), INTENT(in)                       :: group_id

  END SUBROUTINE ReadOpacityTypeCHDF



  SUBROUTINE Read4dHDF_double( name, values, group_id, datasize )

    CHARACTER(*), INTENT(in)                    :: name
    INTEGER(HID_T)                              :: group_id
    INTEGER(HSIZE_T), DIMENSION(4), INTENT(in)  :: datasize
    REAL(dp), DIMENSION(:,:,:,:), INTENT(out)   :: values
   
    INTEGER(HID_T)                               :: dataset_id
 
    CALL h5dopen_f( group_id, name, dataset_id, hdferr )
    CALL h5dread_f( dataset_id, H5T_NATIVE_DOUBLE, values, datasize, hdferr )
    CALL h5dclose_f( dataset_id, hdferr )

  END SUBROUTINE Read4dHDF_double


  SUBROUTINE ReadEnergyGridHDF( EnergyGrid, group_id )

    TYPE(EnergyGridType), INTENT(inout)         :: EnergyGrid
    INTEGER(HID_T), INTENT(in)                  :: group_id

    INTEGER(HSIZE_T), DIMENSION(1)              :: datasize1d
    INTEGER, DIMENSION(1)                       :: buffer
    CHARACTER(LEN=32), DIMENSION(1)             :: buffer_string

    datasize1d(1) = 1
    Call Read1dHDF_string( "Name", buffer_string, group_id, datasize1d )
    EnergyGrid % Name = buffer_string(1)

    Call Read1dHDF_string( "Unit", buffer_string, group_id, datasize1d )
    EnergyGrid % Unit = buffer_string(1)

    CALL Read1dHDF_integer( "nPoints", buffer, group_id, datasize1d )
    EnergyGrid % nPoints = buffer(1)

    CALL Read1dHDF_integer( "LogInterp", buffer, group_id, datasize1d )
    EnergyGrid % LogInterp = buffer(1)
 
    datasize1d = EnergyGrid % nPoints
    CALL Read1dHDF_double( "Values", EnergyGrid % Values, &
                              group_id, datasize1d )

    EnergyGrid % minValue = MINVAL( EnergyGrid % Values )
    
    EnergyGrid % maxValue = MAXVAL( EnergyGrid % Values )

  END SUBROUTINE ReadEnergyGridHDF


END MODULE wlOpacityTableIOModuleHDF
