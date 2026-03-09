export ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

<<<<<<< main
# ============================================================================
# USER CONFIGURATION SECTION - MODIFY THESE PATHS AS NEEDED FOR YOUR SYSTEM
# ============================================================================

# OSU Micro-benchmarks installation path
# Set this to your OSU benchmark installation or set OSU_HOME environment variable
# Examples:
#   export USER_OSU_HOME="/path/to/your/osu-micro-benchmarks/libexec/osu-micro-benchmarks"
#   export USER_OSU_HOME="$HOME/software/osu/libexec/osu-micro-benchmarks" 
export USER_OSU_HOME="${OSU_HOME:-$ROOT_DIR/osu/install/libexec/osu-micro-benchmarks}"

# GPU binding script path (optional override)
# If not set, will use the select_gpu.sh script in this repository
export USER_GPUBIND="${GPUBIND:-$ROOT_DIR/select_gpu.sh}"

# GPU acceleration library preference (for systems with both options available)
# Set to "rccl", "nccl", or "auto" (default: "auto" for automatic detection)
# Examples:
#   export USER_GPU_ACCEL="nccl"    # Force NCCL/CUDA support
#   export USER_GPU_ACCEL="rccl"    # Force RCCL/ROCm support  
#   export USER_GPU_ACCEL="auto"    # Automatic detection (default)
export USER_GPU_ACCEL="${GPU_ACCEL:-auto}"

# Libfabric installation preference
# Set to "system", "build", or "auto" (default: "auto" for automatic selection)
# Examples:
#   export USER_LIBFABRIC="system" # Use system/module libfabric when available
#   export USER_LIBFABRIC="build"  # Always build libfabric from source
#   export USER_LIBFABRIC="auto"   # Automatic selection based on system (default)
export USER_LIBFABRIC="${USER_LIBFABRIC:-auto}"

# ============================================================================
# END USER CONFIGURATION SECTION
# ============================================================================

# Enhanced system detection that properly handles CUDA/NCCL vs ROCm configurations
detect_system_config() {
    local is_cray=false
    local has_rocm=false
    local has_cuda=false
    local has_nccl=false
    local is_nris=false
    
    # Check if this is a Cray system
    if [[ -n "$CRAY_MPICH_VER" || -n "$PE_ENV" ]] || [[ -d "/opt/cray" ]]; then
        is_cray=true
    fi
    
    # Check for NRIS environment
    if module avail NRIS/GPU &>/dev/null 2>&1; then
        is_nris=true
    fi
    
    # Check for ROCm availability
    if [[ -n "$ROCM_PATH" ]] || module avail rocm &>/dev/null 2>&1 || [[ -d "/opt/rocm" ]]; then
        has_rocm=true
    fi
    
    # Check for CUDA availability  
    if command -v nvidia-smi &>/dev/null || [[ -n "$CUDA_HOME" ]] || [[ -n "$CUDA_PATH" ]] || 
       module avail cuda &>/dev/null 2>&1 || [[ -d "/usr/local/cuda" ]] || [[ -d "/opt/cuda" ]]; then
        has_cuda=true
    fi
    
    # Check for NCCL availability
    if [[ -n "$NCCL_PATH" ]] || module avail NCCL &>/dev/null 2>&1 || module avail nccl &>/dev/null 2>&1; then
        has_nccl=true
    fi
    
    # Handle user preference for GPU acceleration library
    case "${USER_GPU_ACCEL}" in
        "rccl")
            if ! $has_rocm; then
                echo "ERROR: RCCL/ROCm support requested but ROCm not available on this system" >&2
                echo "Available options: CUDA=$has_cuda, NCCL=$has_nccl" >&2
                return 1
            fi
            # Force ROCm selection by disabling CUDA detection 
            has_cuda=false
            has_nccl=false
            ;;
        "nccl")
            if ! $has_cuda && ! $has_nccl; then
                echo "ERROR: NCCL/CUDA support requested but CUDA/NCCL not available on this system" >&2
                echo "Available options: ROCm=$has_rocm" >&2
                return 1
            fi
            # Force CUDA/NCCL selection by disabling ROCm detection
            has_rocm=false  
            ;;
        "auto")
            ;;
        *)
            echo "WARNING: Invalid USER_GPU_ACCEL value '${USER_GPU_ACCEL}'. Valid options: rccl, nccl, auto" >&2
            echo "Falling back to automatic detection"
            ;;
    esac
    
    # Determine system configuration based on detected features
    if $is_cray; then
        if $has_rocm; then
            echo "cray_rocm"
        elif $has_cuda || $has_nccl; then
            echo "cray_cuda" 
        elif [[ -d "/opt/cray/libfabric" ]]; then
            echo "cray_preinstalled"
        else
            echo "cray_generic"
        fi
    elif $is_nris; then
        if $has_cuda || $has_nccl; then
            echo "nris_cuda"
        else
            echo "nris_generic" 
        fi
    elif $has_rocm; then
        echo "rocm_generic"
    elif $has_cuda; then
        echo "cuda_generic"
    else
        echo "generic"
    fi
}

export SYSTEM_CONFIG=$(detect_system_config)
echo "Detected system configuration: $SYSTEM_CONFIG"

# Display user preference information
case "${USER_GPU_ACCEL}" in
    "rccl")
        echo "User preference: Forcing RCCL/ROCm support"
        ;;
    "nccl")
        echo "User preference: Forcing NCCL/CUDA support"
        ;;
    "auto")
        echo "User preference: Automatic GPU detection"
        ;;
esac

# Handle libfabric configuration based on user preference and system capabilities
configure_libfabric() {
    local use_system_libfabric=false
    local system_libfabric_path=""
    
    # Check for available system libfabric
    if [[ -n "$CRAY_MPICH_VER" ]] && [[ -d "/opt/cray/libfabric" ]]; then
        # Cray system with system libfabric
        local cray_lf_version=$(ls -1 /opt/cray/libfabric/ | sort -V | tail -1)
        if [[ -n "$cray_lf_version" ]]; then
            system_libfabric_path="/opt/cray/libfabric/$cray_lf_version"
        fi
    elif module avail libfabric &>/dev/null 2>&1; then
        # System has libfabric module
        if module list 2>&1 | grep -q libfabric; then
            # Already loaded, get path from PKG_CONFIG_PATH or LD_LIBRARY_PATH
            if pkg-config --exists libfabric 2>/dev/null; then
                system_libfabric_path=$(pkg-config --variable=prefix libfabric)
            fi
        elif module load libfabric &>/dev/null 2>&1; then
            # Try to load and get path
            if pkg-config --exists libfabric 2>/dev/null; then
                system_libfabric_path=$(pkg-config --variable=prefix libfabric)
            fi
        fi
    fi
    
    # Make decision based on user preference
    case "${USER_LIBFABRIC}" in
        "system")
            if [[ -n "$system_libfabric_path" ]]; then
                use_system_libfabric=true
                echo "User preference: Using system libfabric at $system_libfabric_path"
            else
                echo "ERROR: System libfabric requested but not found"
                echo "Available options: build libfabric from source"
                return 1
            fi
            ;;
        "build")
            use_system_libfabric=false
            echo "User preference: Building libfabric from source"
            ;;
        "auto")
            # Auto-detect: prefer system libfabric for certain cases, build for others
            if [[ "$SYSTEM_CONFIG" == "cray_preinstalled" ]] || [[ "$SYSTEM_CONFIG" == "nris_"* ]]; then
                if [[ -n "$system_libfabric_path" ]]; then
                    use_system_libfabric=true
                    echo "Auto-detected: Using system libfabric at $system_libfabric_path"
                fi
            else
                use_system_libfabric=false
                echo "Auto-detected: Building libfabric from source for optimal configuration"
            fi
            ;;
        *)
            echo "WARNING: Invalid USER_LIBFABRIC value '${USER_LIBFABRIC}'. Valid options: system, build, auto"
            echo "Falling back to automatic detection"
            use_system_libfabric=false
            ;;
    esac
    
    # Set PREFIX_LIBFABRIC based on decision
    if $use_system_libfabric && [[ -n "$system_libfabric_path" ]]; then
        export PREFIX_LIBFABRIC="$system_libfabric_path"
        export LIBFABRIC_SOURCE="system"
        echo "Using system libfabric: $PREFIX_LIBFABRIC"
    else
        export PREFIX_LIBFABRIC="$ROOT_DIR/install_libfabric"
        export LIBFABRIC_SOURCE="build"
        echo "Will build libfabric at: $PREFIX_LIBFABRIC"
    fi
}

# Configure libfabric before setting up the environment
configure_libfabric

# Initialize XPMEM variables to ensure they're always defined
export XPMEM_ROOT=""
export XPMEM_LIBFABRIC=""

# Initialize GPU variables to ensure they're always defined  
export GPU_INCLUDE=""
export GPU_LIBFABRIC=""

case "$SYSTEM_CONFIG" in
    "cray_rocm")
        # Cray system with ROCm/AMD GPUs
		module load PrgEnv-gnu
		module load rocm
		# Try different XPMEM module variations
		if module avail cray-xpmem 2>&1 | grep -q "cray-xpmem"; then
			module load cray-xpmem
			XPMEM_ROOT=$(pkg-config --variable=prefix cray-xpmem)
			XPMEM_LIBFABRIC="--enable-xpmem=${XPMEM_ROOT}"
			echo "XPMEM prefix path = "$XPMEM_ROOT
		elif module avail xpmem 2>&1 | grep -q "xpmem"; then
			module load xpmem
			XPMEM_ROOT=$(pkg-config --variable=prefix xpmem)
			XPMEM_LIBFABRIC="--enable-xpmem=${XPMEM_ROOT}"
			echo "XPMEM prefix path = "$XPMEM_ROOT
		else
			echo "Warning: No XPMEM modules found (cray-xpmem/xpmem), proceeding without XPMEM support"
			XPMEM_LIBFABRIC=""
		fi

		echo "ROCM_PATH = "$ROCM_PATH

		GPU_INCLUDE="-I$ROCM_PATH/include"
		GPU_LIBFABRIC="--with-rocr=$ROCM_PATH"
        ;;
    "cray_cuda")
        # Cray system with CUDA/NVIDIA GPUs
        module load PrgEnv-gnu
        
        # Add NVIDIA HPC SDK module paths
        module use /opt/nvidia/hpc_sdk/modulefiles 2>/dev/null || true
        module use /global/opt/nvidia/hpc_sdk/modulefiles 2>/dev/null || true
        
        # Try different CUDA module variations with actual loading attempts
        cuda_loaded=false
        if module load nvhpc-hpcx-cuda12 &>/dev/null 2>&1; then
            echo "Loaded nvhpc-hpcx-cuda12 module"
            # Set CUDA_HOME for NVIDIA HPC SDK
            export CUDA_HOME="/opt/nvidia/hpc_sdk/Linux_x86_64/$(module list 2>&1 | grep nvhpc-hpcx-cuda12 | sed 's/.*nvhpc-hpcx-cuda12\///g' | awk '{print $1}')/cuda"
            cuda_loaded=true
        elif module load cuda &>/dev/null 2>&1; then
            echo "Loaded cuda module"
            cuda_loaded=true
		elif module load cpe-cuda &>/dev/null 2>&1; then
			echo "Loaded cpe-cuda module"
            # For cpe-cuda, try to find CUDA in standard NVIDIA HPC SDK location
            if [[ -d "/opt/nvidia/hpc_sdk/Linux_x86_64" ]]; then
                # Find the latest version directory
                latest_cuda=$(ls -1 /opt/nvidia/hpc_sdk/Linux_x86_64/ | grep -E '^[0-9]+\.[0-9]+$' | sort -V | tail -1)
                if [[ -n "$latest_cuda" && -d "/opt/nvidia/hpc_sdk/Linux_x86_64/$latest_cuda/cuda" ]]; then
                    export CUDA_HOME="/opt/nvidia/hpc_sdk/Linux_x86_64/$latest_cuda/cuda"
                    echo "Found CUDA at: $CUDA_HOME"
                    cuda_loaded=true
                fi
            fi
		elif module load cray-cuda &>/dev/null 2>&1; then
			echo "Loaded cray-cuda module"
            cuda_loaded=true
		fi
        
        if ! $cuda_loaded; then
			echo "Info: No CUDA modules available on login node (nvhpc-hpcx-cuda12/cuda/cpe-cuda/cray-cuda)"
            echo "Info: Checking for CUDA in standard NVIDIA HPC SDK locations..."
            # Fallback: try to find CUDA in NVIDIA HPC SDK without modules
            if [[ -d "/opt/nvidia/hpc_sdk/Linux_x86_64" ]]; then
                latest_cuda=$(ls -1 /opt/nvidia/hpc_sdk/Linux_x86_64/ | grep -E '^[0-9]+\.[0-9]+$' | sort -V | tail -1)
                if [[ -n "$latest_cuda" && -d "/opt/nvidia/hpc_sdk/Linux_x86_64/$latest_cuda/cuda" ]]; then
                    export CUDA_HOME="/opt/nvidia/hpc_sdk/Linux_x86_64/$latest_cuda/cuda"
                    echo "Found CUDA at: $CUDA_HOME (without module)"
                else
                    echo "Info: No CUDA installation found in NVIDIA HPC SDK"
                fi
            else
                echo "Info: NVIDIA HPC SDK not found - CUDA may only be available on compute nodes"
            fi
        fi
		# Try different XPMEM module variations
		if module avail cray-xpmem 2>&1 | grep -q "cray-xpmem"; then
			module load cray-xpmem
			XPMEM_ROOT=$(pkg-config --variable=prefix cray-xpmem 2>/dev/null)
			if [[ -n "$XPMEM_ROOT" ]]; then
				XPMEM_LIBFABRIC="--enable-xpmem=${XPMEM_ROOT}"
				echo "XPMEM prefix path = "$XPMEM_ROOT
			else
				echo "Warning: cray-xpmem loaded but pkg-config failed"
				XPMEM_LIBFABRIC=""
			fi
		elif module avail xpmem 2>&1 | grep -q "xpmem"; then
			module load xpmem
			XPMEM_ROOT=$(pkg-config --variable=prefix xpmem 2>/dev/null)
			if [[ -n "$XPMEM_ROOT" ]]; then
				XPMEM_LIBFABRIC="--enable-xpmem=${XPMEM_ROOT}"
				echo "XPMEM prefix path = "$XPMEM_ROOT
			else
				echo "Warning: xpmem loaded but pkg-config failed"
				XPMEM_LIBFABRIC=""
			fi
		else
			echo "Info: No XPMEM modules available (cray-xpmem/xpmem), proceeding without XPMEM support"
			XPMEM_LIBFABRIC=""
		fi
		
		# Try different NCCL module variations with actual loading attempts
		if module load NCCL &>/dev/null 2>&1; then
			echo "Loaded NCCL module"
		elif module load nccl &>/dev/null 2>&1; then
			echo "Loaded nccl module"
		elif module load cray-nccl &>/dev/null 2>&1; then
			echo "Loaded cray-nccl module"
		else
			echo "Info: No NCCL modules available - may need manual installation"
		fi

        module list
        
        # Ensure CUDA_HOME is set for GPU configuration
        if [[ -z "$CUDA_HOME" && -n "$CUDA_PATH" ]]; then
            export CUDA_HOME="$CUDA_PATH"
        fi
        
        if [[ -n "$CUDA_HOME" ]]; then
            GPU_INCLUDE="-I$CUDA_HOME/include"
            GPU_LIBFABRIC="--with-cuda=$CUDA_HOME"
            echo "Using CUDA_HOME: $CUDA_HOME"
        elif [[ -n "$CUDA_PATH" ]]; then
            GPU_INCLUDE="-I$CUDA_PATH/include"  
            GPU_LIBFABRIC="--with-cuda=$CUDA_PATH"
            echo "Using CUDA_PATH: $CUDA_PATH"
        else
            echo "Info: No CUDA_HOME or CUDA_PATH found on login node"
            echo "Note: CUDA may only be available on compute nodes with GPUs"
            echo "Consider building NCCL on a compute node or using pre-compiled NCCL"
        fi
        ;;
    "nris_cuda"|"cray_preinstalled") 
        # NRIS system or Cray with pre-installed libfabric
        if [ "${CRAY_MPICH_VER}" == "" ]; then
            ml load NRIS/GPU
            # Only try to load NRIS libfabric if we're supposed to use system libfabric
            if [[ "$LIBFABRIC_SOURCE" == "system" ]]; then
                if module avail libfabric/2.3.1-GCCcore-14.3.0 &>/dev/null 2>&1; then
                    ml load libfabric/2.3.1-GCCcore-14.3.0
                elif module avail libfabric &>/dev/null 2>&1; then
                    ml load libfabric
                fi
            fi
            return 0
        fi
        # For Cray MPI systems, use the configured libfabric (system or build)
        return 0
        ;;
    "nris_generic")
        # NRIS system without specific GPU detection
        ml load NRIS/GPU
        # Only try to load NRIS libfabric if we're supposed to use system libfabric
        if [[ "$LIBFABRIC_SOURCE" == "system" ]]; then
            if module avail libfabric/2.3.1-GCCcore-14.3.0 &>/dev/null 2>&1; then
                ml load libfabric/2.3.1-GCCcore-14.3.0
            elif module avail libfabric &>/dev/null 2>&1; then
                ml load libfabric
            fi
        fi
        return 0
        ;;
    "rocm_generic")
        # Generic ROCm system (non-Cray)
        # No XPMEM on generic systems
        XPMEM_LIBFABRIC=""
        if [[ -n "$ROCM_PATH" ]]; then
            GPU_INCLUDE="-I$ROCM_PATH/include"
            GPU_LIBFABRIC="--with-rocr=$ROCM_PATH"
        fi
        ;;
    "cuda_generic")
        # Generic CUDA system (non-Cray)
        # No XPMEM on generic systems
        XPMEM_LIBFABRIC=""
        if [[ -n "$CUDA_HOME" ]]; then
            GPU_INCLUDE="-I$CUDA_HOME/include"
            GPU_LIBFABRIC="--with-cuda=$CUDA_HOME"
        elif [[ -n "$CUDA_PATH" ]]; then
            GPU_INCLUDE="-I$CUDA_PATH/include"
            GPU_LIBFABRIC="--with-cuda=$CUDA_PATH"
        fi
        ;;
    "cray_generic"|"generic")
        # Default configurations
		echo "System not recognized or no GPU acceleration configured"
		XPMEM_LIBFABRIC=""
		return -1
        ;;
=======
case "$USER" in
    lazzaroa)
	module load PrgEnv-gnu
	module load rocm
	module list

	echo "ROCM_PATH = "$ROCM_PATH

	XPMEM_ROOT=$(pkg-config --variable=libdir cray-xpmem)
	XPMEM_LIBFABRIC="--enable-xpmem=${XPMEM_ROOT}"
	echo "XPMEM Lib path  = "$XPMEM_ROOT

	GPU_INCLUDE="-I$ROCM_PATH/include"
	GPU_LIBFABRIC="--with-rocr=$ROCM_PATH"
	;;
    marcink)
	if [ "${CRAY_MPICH_VER}" == "" ]; then
	    ml load NRIS/GPU
	    ml load libfabric/2.3.1-GCCcore-14.3.0
	    return 0
	fi

	# with cray mpi use the pre-installed libfabric
	export PREFIX_LIBFABRIC=/opt/cray/libfabric/1.22.0/
	return 0
	;;
    *)
	echo "User not recongnized"
	return -1
	;;
>>>>>>> main
esac

# Summary of configuration  
echo "User GPU acceleration preference: ${USER_GPU_ACCEL}"
echo "User libfabric preference: ${USER_LIBFABRIC}"  
echo "Libfabric source: ${LIBFABRIC_SOURCE}"
echo "Libfabric path: ${PREFIX_LIBFABRIC}"
echo "XPMEM configuration: ${XPMEM_LIBFABRIC:-"(disabled)"}"
echo "GPU acceleration: ${GPU_LIBFABRIC:-"(disabled)"}"

export PREFIX_CXI=$ROOT_DIR/install_cxi # installation directory
# PREFIX_LIBFABRIC is already set by configure_libfabric function
export LIBFABRIC_DIR=$ROOT_DIR/libfabric
export LIBCXI_DIR=$LIBFABRIC_DIR/libcxi

export c=gnu
export CC=gcc-14
export CFLAGS="-g -O -Wno-error=maybe-uninitialized -I$PREFIX_CXI/include $GPU_INCLUDE"
export CPPFLAGS="-I$PREFIX_CXI/include $GPU_INCLUDE"

export CXX=g++-14
export CXXFLAGS="-g -O -I$PREFIX_CXI/include $GPU_INCLUDE"

export FC=gfortran-14
export FCFLAGS="-O -I$PREFIX_CXI/include $GPU_INCLUDE"

export LDFLAGS="-g -O -L$PREFIX_CXI/lib -L$ROCM_PATH/lib"

export PATH=${PREFIX_CXI}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_CXI}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_CXI/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_CXI/man:$MANPATH
export MANPATH=$PREFIX_CXI/share/man:$MANPATH

export PATH=${PREFIX_LIBFABRIC}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_LIBFABRIC}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_LIBFABRIC/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_LIBFABRIC/share/man:$MANPATH
