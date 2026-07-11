#!/bin/bash

# Installs PyTorch into the active conda environment.
# Detects CUDA availability and installs the appropriate build.
# Run after: mamba env create -f ml-env.yml && mamba activate ml

if ! command -v python >/dev/null 2>&1; then
    echo "No Python found. Activate the target env first: mamba activate ml"
    exit 1
fi

if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | grep -q .; then
    CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $NF}')
    echo "GPU detected. CUDA $CUDA_VERSION"

    # Pick channel based on major CUDA version (adjust if needed)
    CUDA_MAJOR=$(echo "$CUDA_VERSION" | cut -d. -f1)
    if [ "$CUDA_MAJOR" -ge 12 ]; then
        CUDA_TAG="cu121"
    else
        CUDA_TAG="cu118"
    fi

    echo "Installing PyTorch with $CUDA_TAG..."
    pip install torch torchvision --index-url "https://download.pytorch.org/whl/$CUDA_TAG"
else
    echo "No GPU detected. Installing CPU-only PyTorch..."
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
fi

echo "Installing fastai..."
pip install fastai

echo "Done. Verify with: python -c \"import torch; print(torch.__version__, torch.cuda.is_available())\""
