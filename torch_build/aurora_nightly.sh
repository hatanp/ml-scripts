#!/bin/bash -x
#

################
#Forked from https://github.com/argonne-lcf/frameworks-standalone/blob/users/khalid/pytorch-2.7/pytorch_2p8_release_build_scripts/sunspot/build_pytorch_2p8_rel_oneapi_2025.2.0_PTI_0.12.3_python_3.10.14.sh
#Credits to anyone who has worked on this before
################

# Time Stamp
tstamp() {
     date +"%Y-%m-%d-%H%M%S"
}
## Proxies to clone from a compute node
export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128
#
TMP_WORK=/tmp/torch_build_dir
mkdir -p ${TMP_WORK}
CONDA_ENV_INSTALL_DIR=$TMP_WORK/conda_env
TSTAMP=20251007
mkdir -p /flare/datascience/vhat/build_torch/envs/nightly_${TSTAMP}
CONDA_ENV_NAME=pytorch_dev${TSTAMP}_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8


#source /opt/aurora/25.190.0/spack/unified/0.10.0/install/linux-sles15-x86_64/gcc-13.3.0/miniforge3-24.3.0-0-gfganax/bin/activate
ENVPREFIX=$CONDA_ENV_INSTALL_DIR/$CONDA_ENV_NAME
rm -rf ${ENVPREFIX}
mkdir -p ${ENVPREFIX}

export CONDA_PKGS_DIRS=${ENVPREFIX}/../.conda/pkgs
export PIP_CACHE_DIR=${ENVPREFIX}/../.pip

echo "Creating Conda environment with Python 3.12.8"
conda create python=3.12.8 --prefix ${ENVPREFIX} --override-channels \
           --channel https://software.repos.intel.com/python/conda/linux-64 \
           --channel conda-forge \
           --strict-channel-priority \
           --yes

conda activate ${ENVPREFIX}
echo "Conda is coming from $(which conda)"

# Use default modules on Sunspot with oneapi/2025.2.0 with PTI 0.12.3
module load cmake
unset CMAKE_ROOT
module load pti-gpu

export CXX=$(which g++)
export CC=$(which gcc)

export REL_WITH_DEB_INFO=1
export USE_CUDA=0
export USE_ROCM=0
export USE_MKLDNN=1
export USE_MKL=1
export USE_ROCM=0
export USE_CUDNN=0
export USE_FBGEMM=0
export USE_NNPACK=0
export USE_QNNPACK=0
export USE_NCCL=0
export USE_CUDA=0
export BUILD_CAFFE2_OPS=0
export BUILD_TEST=0
export USE_DISTRIBUTED=1
export USE_NUMA=0
export USE_MPI=0
export _GLIBCXX_USE_CXX11_ABI=1
export USE_XPU=1
export USE_XCCL=1
export XPU_ENABLE_KINETO=1
export USE_ONEMKL=1
export USE_KINETO=1

export USE_AOT_DEVLIST='pvc'
export TORCH_XPU_ARCH_LIST='pvc'

export INTEL_MKL_DIR=$MKLROOT

cd ${TMP_WORK}
git clone https://github.com/pytorch/pytorch.git
cd pytorch
git checkout nightly
#git checkout release/2.8
git submodule sync && git submodule update --init --recursive

pip install --no-cache-dir -r requirements.txt

set +e

rm_conda_pkgs=(
        "dpcpp-cpp-rt"
        "impi_rt"
        "intel-cmplr-lib-rt"
        "intel-cmplr-lib-ur"
        "intel-cmplr-lic-rt"
        "intel-gpu-ocl-icd-system"
        "intel-opencl-rt"
        "intel-openmp"
        "intelpython"
        "intel-sycl-rt"
        "level-zero"
        "libedit"
        "numpy"
        "numpy-base"
        "mkl"
        "mkl_fft"
        "mkl_random"
        "mkl-service"
        "mkl_umath"
        "onemkl-sycl-blas"
        "onemkl-sycl-dft"
        "onemkl-sycl-lapack"
        "onemkl-sycl-rng"
        "onemkl-sycl-stats"
        "onemkl-sycl-vm"
        "pyedit"
        "tbb"
        "tcm"
        "umf"
        "tcmlib"
        "intel-pti"
        "impi-rt"
        "oneccl"
        "oneccl-devel"
        "onemkl-sycl-sparse"
    )

for pkg in "${rm_conda_pkgs[@]}"
do
    conda uninstall $pkg \
        --prefix ${ENVPREFIX} \
        --force \
        --yes
    pip uninstall $pkg -y
done

pip uninstall -y numpy
pip install --no-cache-dir numpy==2.2.6

python setup.py clean
#make triton
pip install --no-cache-dir pytorch-triton-xpu==3.5.0 --index-url https://download.pytorch.org/whl/nightly/

for pkg in "${rm_conda_pkgs[@]}"
do
    conda uninstall $pkg \
        --prefix ${ENVPREFIX} \
        --force \
        --yes
    pip uninstall $pkg -y
done

pip install --no-cache-dir numpy==2.2.6

MAX_JOBS=32 python setup.py bdist_wheel --dist-dir ${TMP_WORK}/${CONDA_ENV_NAME} 2>&1 | tee ${TMP_WORK}/${CONDA_ENV_NAME}/"torch-build-whl-$(tstamp).log"
echo "Finished building PyTorch nightly wheel with oneapi/2025.2.0, PTI-0.12.3 and numpy-2.2.6"
LOCAL_WHEEL_LOC=${TMP_WORK}/${CONDA_ENV_NAME}

pip install --no-deps --no-cache-dir --force-reinstall $LOCAL_WHEEL_LOC/torch-*.whl 2>&1 | tee ${TMP_WORK}/${CONDA_ENV_NAME}/"torch-install-$(tstamp).log"
echo "Finished installing the wheel and dependencies"
 

pip install --no-cache-dir -r /flare/AuroraGPT/vhat/TT_MoE/torchtitan_main/torchtitan/requirements.txt

cd /tmp/torch_build_dir/conda_env/
tar -cf $CONDA_ENV_NAME.tar -C $CONDA_ENV_INSTALL_DIR $CONDA_ENV_NAME
cp $LOCAL_WHEEL_LOC/torch-*.whl /flare/datascience/vhat/build_torch/envs/
cp $CONDA_ENV_NAME.tar /flare/datascience/vhat/build_torch/envs/nightly_${TSTAMP}
#tar -xf pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8.tar -C /tmp