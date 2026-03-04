
# Running OpenMPI on HPE SS11 network

> [!CAUTION]
> This repository is not an official guide on how to install OpenMPI

## Configuration

### GPU Acceleration Library Selection

On systems with both AMD and NVIDIA GPU capabilities, you can explicitly choose which GPU acceleration library to use by setting the `GPU_ACCEL` environment variable before sourcing the configuration scripts:

```bash
# Force NCCL/CUDA support  
export GPU_ACCEL=nccl
source sourceme_nccl.sh

# Force RCCL/ROCm support
export GPU_ACCEL=rccl  
source sourceme_rccl.sh

# Automatic detection (default)
export GPU_ACCEL=auto
source sourceme_libfabric.sh
```

**Valid options:**
- `nccl` - Force NCCL (NVIDIA CUDA) support
- `rccl` - Force RCCL (AMD ROCm) support  
- `auto` - Automatic detection based on available hardware/modules (default)

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
