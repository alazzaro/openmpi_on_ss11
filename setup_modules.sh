#!/bin/bash
# Setup script to add modulefiles to environment

# Use existing ROOT_DIR if set, otherwise determine from script location
if [[ -z "$ROOT_DIR" ]]; then
    export ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
fi
export MODULEFILES_DIR="$ROOT_DIR/modulefiles"

# Check if Lmod is available (look for common Lmod commands/variables)
if command -v ml >/dev/null 2>&1 || [ -n "$LMOD_VERSION" ]; then
    echo "Detected Lmod system"
    echo "Adding modulefiles directory to MODULEPATH: $MODULEFILES_DIR"
    export MODULEPATH="$MODULEFILES_DIR:$MODULEPATH"
    
    echo ""
    echo "Available modules:"
    module avail 2>&1 | grep -E "(libfabric|openmpi|nccl|rccl)" || echo "  No modules found - run installation scripts first"
    
elif command -v module >/dev/null 2>&1; then
    echo "Detected Environment Modules system"
    echo "Adding modulefiles directory to module path: $MODULEFILES_DIR"
    module use "$MODULEFILES_DIR"
    
    echo ""
    echo "Available modules:"
    module avail 2>&1 | grep -E "(libfabric|openmpi|nccl|rccl)" || echo "  No modules found - run installation scripts first"
    
else
    echo "Warning: No module system detected (neither Lmod nor Environment Modules)"
    echo "You may need to manually configure your module system to use:"
    echo "  $MODULEFILES_DIR"
    echo ""
    echo "For Lmod: export MODULEPATH=\"$MODULEFILES_DIR:\$MODULEPATH\""
    echo "For Environment Modules: module use $MODULEFILES_DIR"
fi

echo ""
echo "Usage examples:"
echo "  module load libfabric/2.3.1"
echo "  module load openmpi/5.0.9" 
echo "  module load nccl/2.29.2     # For NVIDIA systems"
echo "  module load rccl/6.2.1      # For AMD systems"
echo ""
echo "For help on any module:"
echo "  module help <module>/<version>"