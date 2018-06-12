FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu16.04
LABEL maintainer="aaronmarkham@fb.com"

# caffe install with gpu support

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libprotobuf-dev \
    libleveldb-dev \
    libsnappy-dev \
    libopencv-dev \
    libhdf5-serial-dev \
    protobuf-compiler \
    libboost-all-dev \
    libopenblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    liblmdb-dev \
    python-dev \
    python-numpy \
    python-pip \
    python-pydot \
    python-setuptools \
    python-scipy \
    wget \
    && rm -rf /var/lib/apt/lists/*

#RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
RUN pip install --no-cache-dir setuptools wheel && \
    pip install --no-cache-dir \
    flask \
    future \
    graphviz \
    hypothesis \
    jupyter \
    matplotlib \
    numpy \
    protobuf \
    pydot \
    python-nvd3 \
    pyyaml \
    requests \
    scikit-image \
    scipy \
    setuptools \
    six \
    tornado

########## INSTALLATION OF CAFFE ###################
RUN git clone --recursive https://github.com/BVLC/caffe.git
RUN cp ./caffe/Makefile.config.example ./caffe/Makefile.config
RUN sed -i "s/\# USE_CUDNN := 1/USE_CUDNN := 1/g" ./caffe/Makefile.config
RUN sed -i "s/\# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/g" ./caffe/Makefile.config
RUN sed -i "s/INCLUDE_DIRS := \$(PYTHON_INCLUDE) \/usr\/local\/include/INCLUDE_DIRS := \$(PYTHON_INCLUDE) \/usr\/local\/include \/usr\/include\/hdf5\/serial/g" ./caffe/Makefile.config
RUN sed -i "s/LIBRARY_DIRS := \$(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib/LIBRARY_DIRS := \$(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib \/usr\/lib\/x86_64-linux-gnu \/usr\/lib\/x86_64-linux-gnu\/hdf5\/serial/g" ./caffe/Makefile.config
RUN sed -i "s/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_hl hdf5/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_serial_hl hdf5_serial/g" ./caffe/Makefile
RUN sed -i '164a\-DCUDA_NVCC_FLAGS=--Wno-deprecated-gpu-targets' ./caffe/Makefile
#RUN cd caffe && mkdir build && cd build \
RUN cd caffe \
    && make all -j"$(nproc)"
    && make pycaffe 
#     && make runtest -j"$(nproc)"
#    && cmake .. \
#    && make -j"$(nproc)" install \
#    && ldconfig \
#    && make clean \
#    && cd .. \
#    && rm -rf build

ENV PYTHONPATH /usr/local

######## INSTALLATION OF CAFFE-YOLO ################
RUN git clone --recursive https://github.com/yeahkun/caffe-yolo.git
RUN wget -O ./caffe-yolo/include/caffe/util/cudnn.hpp https://raw.githubusercontent.com/BVLC/caffe/master/include/caffe/util/cudnn.hpp
RUN cp ./caffe-yolo/Makefile.config.example ./caffe-yolo/Makefile.config
RUN sed -i "s/\# USE_CUDNN := 1/USE_CUDNN := 1/g" ./caffe-yolo/Makefile.config
RUN sed -i "s/\# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/g" ./caffe-yolo/Makefile.config
RUN sed -i "s/INCLUDE_DIRS := \$(PYTHON_INCLUDE) \/usr\/local\/include/INCLUDE_DIRS := \$(PYTHON_INCLUDE) \/usr\/local\/include \/usr\/include\/hdf5\/serial/g" ./caffe-yolo/Makefile.config
RUN sed -i "s/LIBRARY_DIRS := \$(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib/LIBRARY_DIRS := \$(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib \/usr\/lib\/x86_64-linux-gnu \/usr\/lib\/x86_64-linux-gnu\/hdf5\/serial/g" ./caffe-yolo/Makefile.config
RUN sed -i "s/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_hl hdf5/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_serial_hl hdf5_serial/g" ./caffe-yolo/Makefile
RUN sed -i '164a\-DCUDA_NVCC_FLAGS=--Wno-deprecated-gpu-targets' ./caffe-yolo/Makefile
RUN cd caffe-yolo \
  && make all -j"$(nproc)" \
  && make pycaffe

RUN apt-get update
RUN apt-get install python-opencv

