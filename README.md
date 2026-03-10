
# Running OpenMPI on HPE SS11 network

> [!CAUTION]
> This repository is not an official guide on how to install OpenMPI

## Quick Start

1. **Install software** (in dependency order):
   ```bash
   ./install_libfabric.sh
   ./install_ompi.sh
   # Optional: ./install_nccl.sh OR ./install_rccl.sh
   ```

2. **Use modules** (recommended):
   ```bash
   source ./setup_modules.sh
   module load libfabric openmpi
   ```
   
   **OR use source scripts** (alternative):
   ```bash
   source sourceme_libfabric.sh
   source sourceme_ompi.sh
   ```

## Module Files

Installation scripts automatically generate portable module files for easy environment setup. See [modulefiles/README.md](modulefiles/README.md) for details.

## Dependencies

If not relying on system-installed libraries, then these scripts must be run in the correct order.  That is:

1. `./install_libfabric.sh` (if building libfabric from source)
2. `./install_nccl.sh` (if building NCCL from source) OR `./install_rccl.sh` (if building RCCL from source)
4. `./install_openmpi.sh` (must be run after libfabric and GPU libraries are configured)

## Configuration

### Libfabric Installation Selection

You can control how libfabric is obtained and configured by setting the `USER_LIBFABRIC` environment variable before sourcing the configuration scripts:

```bash
# Use system/module libfabric (fastest setup)
export USER_LIBFABRIC=system
source sourceme_libfabric.sh

# Build libfabric from source (optimal customization)
export USER_LIBFABRIC=build  
source sourceme_libfabric.sh

# Automatic detection (default)
export USER_LIBFABRIC=auto
source sourceme_libfabric.sh
```

**Valid options:**
- `system` - Use system or module libfabric when available
- `build` - Always build libfabric from source for custom XPMEM/GPU integration
- `auto` - Automatic selection based on system configuration (default)

**Automatic selection logic:**
- **NRIS and pre-installed systems**: Prefers system libfabric for faster setup
- **Cray ROCm/CUDA systems**: Builds from source for optimal XPMEM and GPU integration
- **Generic systems**: Falls back to building from source

### GPU Acceleration Library Selection

On systems with both AMD and NVIDIA GPU capabilities, you can explicitly choose which GPU acceleration library to use by setting the `USER_GPU_ACCEL` environment variable before sourcing the configuration scripts:

```bash
# Force NCCL/CUDA support  
export USER_GPU_ACCEL=nccl
source sourceme_nccl.sh

# Force RCCL/ROCm support
export USER_GPU_ACCEL=rccl  
source sourceme_rccl.sh

# Automatic detection (default)
export USER_GPU_ACCEL=auto
source sourceme_libfabric.sh
```

**Valid options:**
- `nccl` - Force NCCL (NVIDIA CUDA) support
- `rccl` - Force RCCL (AMD ROCm) support  
- `auto` - Automatic detection based on available hardware/modules (default)

> **Note:** For backwards compatibility, the `GPU_ACCEL` environment variable is also supported.

If you request a GPU acceleration library that is not available on the system, the script will display an error message and exit.

### CUDA Availability on HPC Systems

On many HPC systems, CUDA may only be available on compute nodes with GPUs, not on login nodes. If you encounter errors about missing CUDA when running `install_nccl.sh`, consider these options:

1. **Use pre-compiled NCCL module** (recommended):
   ```bash
   module load NCCL  # or similar, check with: module avail NCCL
   ```

2. **Build on compute node**:
   ```bash
   # Submit build job to GPU partition
   salloc -N 1 --partition=gpu
   ./install_nccl.sh
   ```

3. **Set CUDA_HOME manually** if you know the path:
   ```bash
   export CUDA_HOME=/path/to/cuda
   ./install_nccl.sh
   ```
