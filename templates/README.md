# Module Files for OpenMPI on SS11

This directory contains module files for the software packages built by the installation scripts in this repository.

## How Module Files are Generated

Module files are **automatically generated** from templates when you run the installation scripts. The system uses:

- **Templates**: Located in [templates/](../templates/) directory with placeholder variables
- **Generator Script**: [`generate_modulefiles.sh`](../generate_modulefiles.sh) substitutes variables 
- **Integration**: Installation scripts call the generator after successful builds

This ensures module files always use the correct paths and versions for your system.

## Available Modules

After running the installation scripts, the following modules will be available:

- **libfabric/&lt;version&gt;** - High-performance fabric software with CXI provider support
- **openmpi/&lt;version&gt;** - OpenMPI built with libfabric and GPU support  
- **nccl/&lt;version&gt;** - NVIDIA Collective Communications Library (requires CUDA)
- **rccl/&lt;version&gt;** - ROCm Communication Collectives Library (requires ROCm)

Versions are automatically detected from the installed software.

## Module File Formats

Both Lmod (Lua) and TCL format module files are provided:

- **Lmod (Lua)**: `.lua` extension (e.g., `libfabric/2.3.1.lua`)
- **TCL**: No extension (e.g., `libfabric/2.3.1`)

## Manual Generation

You can manually regenerate module files after installation:

```bash
# Generate all modules for installed software
./generate_modulefiles.sh

# Generate modules for specific software
./generate_modulefiles.sh libfabric
./generate_modulefiles.sh openmpi 
./generate_modulefiles.sh nccl
./generate_modulefiles.sh rccl
```

## Usage

### Setting up Module Path

Add this modulefiles directory to your MODULEPATH:

```bash
# Source the setup script (recommended)
source ./setup_modules.sh

# OR manually for Lmod (if using Lua modules)
export MODULEPATH="/path/to/your/openmpi_on_ss11/modulefiles:$MODULEPATH"

# OR manually for Environment Modules (if using TCL modules)  
module use /path/to/your/openmpi_on_ss11/modulefiles
```

### Loading Modules

```bash
# Load individual modules
module load libfabric/<version>
module load openmpi/<version>

# Or load specific GPU acceleration library
module load nccl/<version>    # For NVIDIA systems
# OR
module load rccl/<version>     # For AMD systems
```

### Typical Usage Patterns

For MPI applications on HPE SS11:
```bash
module load libfabric/<version>
module load openmpi/<version>
# Optionally load NCCL or RCCL for GPU-aware MPI
```

### Dependencies

- **OpenMPI** requires libfabric to be built/available
- **NCCL** requires CUDA runtime and compatible NVIDIA GPUs
- **RCCL** requires ROCm runtime and compatible AMD GPUs

## Installation Status

Before loading a module, ensure the corresponding software is installed:

- **libfabric**: Run `./install_libfabric.sh`
- **OpenMPI**: Run `./install_ompi.sh` (requires libfabric)
- **NCCL**: Run `./install_nccl.sh` (requires CUDA)
- **RCCL**: Run `./install_rccl.sh` (requires ROCm)

## Environment Variables

Each module sets appropriate environment variables:

- **libfabric**: `LIBFABRIC_ROOT`, `FI_PROVIDER=cxi`
- **OpenMPI**: `MPI_ROOT`, `OMPI_ROOT`, compiler variables
- **NCCL**: `NCCL_ROOT`
- **RCCL**: `RCCL_ROOT`

## Conflicts

Modules are configured with appropriate conflicts:
- NCCL and RCCL conflict with each other
- OpenMPI conflicts with other MPI implementations
- libfabric conflicts with other libfabric modules

## Performance Tuning

The modules include commented performance tuning options. Uncomment and modify as needed for your specific system and workload requirements.

For more information, use:
```bash
module help <modulename>/<version>
```