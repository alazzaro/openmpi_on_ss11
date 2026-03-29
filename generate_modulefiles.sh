#!/bin/bash
# Script to generate module files from templates
# Called by installation scripts after successful builds

# Set default values if not provided
ROOT_DIR=${ROOT_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd -P)}
MODULEFILES_DIR="${ROOT_DIR}/modulefiles"
TEMPLATES_DIR="${ROOT_DIR}/templates"

# Function to detect version from installed software
detect_version() {
    local software="$1"
    local install_dir="$2"
    
    case "$software" in
        libfabric)
            if [[ -x "$install_dir/bin/fi_info" ]]; then
                "$install_dir/bin/fi_info" --version 2>/dev/null | head -1 | awk '{print $2}'
            else
                echo "2.3.1"  # Default fallback
            fi
            ;;
        openmpi)
            if [[ -x "$install_dir/bin/mpirun" ]]; then
                "$install_dir/bin/mpirun" --version 2>/dev/null | head -1 | awk '{print $3}'
            else
                echo "5.0.9"  # Default fallback
            fi
            ;;
        nccl)
            # NCCL version is harder to detect, use default or parameter
            echo "${NCCL_VERSION:-2.29.2}"
            ;;
        rccl)
            # RCCL version is harder to detect, use default or parameter
            echo "${RCCL_VERSION:-6.2.1}"
            ;;
    esac
}

# Function to generate module file from template
generate_module() {
    local software="$1"
    local version="$2"
    local template_file="$3"
    local output_file="$4"
    
    echo "Generating module file: $output_file"
    
    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$output_file")"
    
    # Replace template variables
    sed -e "s|@ROOT_DIR@|$ROOT_DIR|g" \
        -e "s|@${software^^}_VERSION@|$version|g" \
        "$template_file" > "$output_file"
    
    echo "  → Module file created: $output_file"
}

# Function to create modules for a specific software
create_modules() {
    local software="$1"
    local install_dir="$ROOT_DIR/install_$software"
    
    echo "Creating module files for $software..."
    
    # Detect version
    local version
    version=$(detect_version "$software" "$install_dir")
    echo "  → Detected version: $version"
    
    # Check if templates exist
    local lua_template="$TEMPLATES_DIR/${software}.lua.template"
    local tcl_template="$TEMPLATES_DIR/${software}.tcl.template"
    
    if [[ ! -f "$lua_template" ]]; then
        echo "  → Warning: Lua template not found: $lua_template"
    else
        generate_module "$software" "$version" "$lua_template" \
            "$MODULEFILES_DIR/$software/$version.lua"
    fi
    
    if [[ ! -f "$tcl_template" ]]; then
        echo "  → Warning: TCL template not found: $tcl_template"
    else
        generate_module "$software" "$version" "$tcl_template" \
            "$MODULEFILES_DIR/$software/$version"
    fi
    
    echo "  → Completed module files for $software"
}

# Main function
main() {
    local software="$1"
    
    echo "Module file generator"
    echo "Root directory: $ROOT_DIR"
    echo "Templates directory: $TEMPLATES_DIR"
    echo "Output directory: $MODULEFILES_DIR"
    echo ""
    
    # Create modulefiles directory if it doesn't exist
    mkdir -p "$MODULEFILES_DIR"
    
    if [[ -n "$software" ]]; then
        # Create modules for specific software
        case "$software" in
            libfabric|openmpi|nccl|rccl)
                create_modules "$software"
                ;;
            *)
                echo "Error: Unknown software '$software'"
                echo "Supported software: libfabric, openmpi, nccl, rccl"
                exit 1
                ;;
        esac
    else
        # Create modules for all software that has been built
        local any_created=false
        
        for sw in libfabric openmpi nccl rccl; do
            local install_dir="$ROOT_DIR/install_$sw"
            if [[ -d "$install_dir" ]] && [[ -n "$(find "$install_dir" -maxdepth 2 -type f 2>/dev/null | head -1)" ]]; then
                create_modules "$sw"
                any_created=true
                echo ""
            fi
        done
        
        if [[ "$any_created" == false ]]; then
            echo "No installed software found. Run installation scripts first:"
            echo "  ./install_libfabric.sh"
            echo "  ./install_ompi.sh"
            echo "  ./install_nccl.sh"
            echo "  ./install_rccl.sh"
        fi
    fi
    
    echo ""
    echo "Module files generation complete!"
    echo ""
    echo "To use the modules, run:"
    echo "  source ./setup_modules.sh"
    echo "  module load <software>/<version>"
}

# Run main function with all arguments
main "$@"