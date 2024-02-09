# testing construction stages

# primary model units (m | s | kg --> N/m²)
# modelunit_length = 'm'
# modelunit_time   = 's'
# modelunit_mass   = 'kg'

#some model-specific variables
material_density = 21.5E3         # ${units 21.5E3 kg/m^3 -> ${modelunit_density}}
gravitational_acceleration = 9.81 # ${units 9.81 m/s^2 -> ${modelunit_acceleration}}
z_top = 10.0
sig_top = 20E3                    # ${units 20 kN/m^2 -> ${modelunit_pressure}}

# read the mesh
[Mesh]
  [File]
    type = FileMeshGenerator
    file = "stages.msh"
    show_info = false
  []
[]

# define some variables containing the (geometric) group names
!include "stages.groups.i"

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  large_kinematics = false
[]

[UserObjects]
  [./BlockActivation_StatesCSV]
    type = PropertyReadFile
    prop_file_name = 'stages.block_activation_t0000.csv stages.block_activation_t0001.csv stages.block_activation_t0002.csv stages.block_activation_t0003.csv'
    read_type = 'block'
    nprop = 2
    nblock = 7
    use_zero_based_block_indexing = false
  []
[]

[Modules/TensorMechanics/Master]
  [./all]
    new_system = true                     # TRUE to use the new lagrangian kernel system
    formulation = total                   # controlling if the UPDATED or TOTAL Lagrangian formulation is used (default is TOTAL)
    strain = small                        # FINITE or SMALL kinematic formulations
    #volumetric_locking_correction = true

    add_variables = true

    generate_output = 'stress_xx stress_xy stress_xz stress_yy stress_yz stress_zz '
                      #'max_principal_stress mid_principal_stress min_principal_stress '
  []
[]

# ===== Gravity =====
[Kernels]
  [./Gravity]
    type = Gravity
    use_displaced_mesh = false
    variable = disp_z
    value = -${gravitational_acceleration}
  []
[]

# ===== Boundary Conditions: Fixies at XMin, XMax, YMin, YMax, ZMin =====
[BCs]
  
  [./BoundaryXMin_DispX]
    type = DirichletBC
    boundary = 'BoundaryXMin'
    variable = disp_x
    value = 0
  []

  [./BoundaryXMax_DispX]
    type = DirichletBC
    boundary = 'BoundaryXMax'
    variable = disp_x
    value = 0
  []
  
  [./BoundaryYMin_DispY]
    type = DirichletBC
    boundary = 'BoundaryYMin'
    variable = disp_y
    value = 0
  []
  
  [./BoundaryYMax_DispY]
    type = DirichletBC
    boundary = 'BoundaryYMax'
    variable = disp_y
    value = 0
  []
  
  [./BoundaryZMin_DispX]
    type = DirichletBC
    boundary = 'BoundaryZMin'
    variable = disp_x
    value = 0
  []

  [./BoundaryZMin_DispY]
    type = DirichletBC
    boundary = 'BoundaryZMin'
    variable = disp_y
    value = 0
  []

  [./BoundaryZMin_DispZ]
    type = DirichletBC
    boundary = 'BoundaryZMin'
    variable = disp_z
    value = 0
  []

[]

# ===== Boundary Conditions: overburden pressure at ZMax =====
[BCs]
  
  [./BoundaryZMax_Pressure]
    type = Pressure
    variable ='disp_z'
    boundary = 'BoundaryZMax'
    function = ${sig_top}
  []

[]

# ===== Initial Conditions: Initial Stress Field =====
[Functions]
  [ini_xx]
    type = ParsedFunction
    expression = '(-sig_top - rho * g * (z_top - z)) * K0'
    symbol_names  = 'sig_top     z_top      rho                   g                               K0  '
    symbol_values = '${sig_top}  ${z_top}   ${material_density}   ${gravitational_acceleration}   0.3 '
  []
  [ini_yy]
    type = ParsedFunction
    expression = '-sig_top - rho * g * (z_top - z)'
    symbol_names  = 'sig_top     z_top      rho                   g                               K0  '
    symbol_values = '${sig_top}  ${z_top}   ${material_density}   ${gravitational_acceleration}   0.3 '
  []
  [ini_zz]
    type = ParsedFunction
    expression = '(-sig_top - rho * g * (z_top - z)) * K0'
    symbol_names  = 'sig_top     z_top      rho                   g                               K0  '
    symbol_values = '${sig_top}  ${z_top}   ${material_density}   ${gravitational_acceleration}   0.3 '
  []
[]

[Materials]

  [./volAll_elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    #block = ${volPlates}
    youngs_modulus = 4500E6 #${units 4500 MN/m^2 -> ${modelunit_pressure}}
    poissons_ratio = 0.15
  []

  [./volAll_stress]
    type = ComputeLagrangianWrappedStress
    #block = ${volPlates}
  []

  [./volAll_stress_base]
    type = ComputeLinearElasticStress
    #block = ${volPlates}
  []

  [./volAll_ini_stress]
    type = ComputeEigenstrainFromInitialStress
    eigenstrain_name = ini_stress
    initial_stress = 'ini_xx 0 0  0 ini_yy 0  0 0 ini_zz'
  []

  [./density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = ${material_density}
  []

[]

# ===== Block Activation/Deactivation =====
[Functions]
  [BlockActivation_AdvanceStatesFileReaderFunction]   # this function gives 1 in case the user object BlockActivation_StatesCSV should be advanced to the next CSV.
    type = ParsedFunction
    expression = 'if(t=0.0, 1, 0) | if(t=0.2, 1, 0) | if(t=0.4, 1, 0) | if(t=0.6, 1, 0) | if(t=1.0, 1, 0)'
  []
[]
[Controls]
  [BlockActivation_AdvanceStatesFileReaderControl]
    type = ConditionalFunctionEnableControl
    conditional_function = BlockActivation_AdvanceStatesFileReaderFunction
    enable_objects = 'UserObjects::BlockActivation_StatesCSV'
    execute_on = 'TIMESTEP_BEGIN'
  []
[]
[Functions]
  [BlockActivation_BlockStatesFunction]
    type = PiecewiseConstantFromCSV
    read_prop_user_object = 'BlockActivation_StatesCSV'
    read_type = 'block'
    column_number = 2
  []
[]
[AuxVariables]
  [BlockActivation_StateAuxVariable]
    family = MONOMIAL
    #order = CONSTANT
  []
[]
[AuxKernels]
  [BlockActivation_StateAux]
    type = FunctionAux
    variable = 'BlockActivation_StateAuxVariable'
    function = 'BlockActivation_BlockStatesFunction'
  []
[]
[UserObjects]
  [BlockActivation]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'BlockActivation_StateAuxVariable'
    criterion_type = BELOW
    threshold = 0
    subdomain_id = 1
    complement_subdomain_id = 2
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[Executioner]
  type = Transient
  #automatic_scaling = true
  #verbose = true

  # more than one time stepper might be provided 
  # (then to be merged by an CompositionDT) 
  end_time = 1.0
  [TimeSteppers]

    [CSVTimeStepper]
      type = CSVTimeSequenceStepper
      file_name = 'stages.csv'
      column_name = 'time'
    []

  []
  # start_time = 0.0
  # end_time = 1.0
  # dt = 1.0

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       mumps'
  
  nl_abs_tol = 1E-3
  #nl_rel_tol = 1E-12
  nl_max_its = 400
  
  l_tol = 1E-3
  l_max_its = 200
[]

[Outputs]
  perf_graph = true
  exodus = true
[]