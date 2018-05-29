git clone --recursive https://github.com/yeahkun/caffe-yolo.git
wget -O ./caffe-yolo/include/caffe/util/cudnn.hpp https://raw.githubusercontent.com/BVLC/caffe/master/include/caffe/util/cudnn.hpp
cp ./caffe-yolo/Makefile.config.example ./caffe-yolo/Makefile.config
sed -i "s/\# USE_CUDNN := 1/USE_CUDNN := 1/g" ./caffe-yolo/Makefile.config
sed -i "s/\# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/g" ./caffe-yolo/Makefile.config
sed -i "s/INCLUDE_DIRS := \$(PYTHON_INCLUDE) \/usr\/local\/include/INCLUDE_DIRS := \$(PYTHON_INCLUDE) \/usr\/local\/include \/usr\/include\/hdf5\/serial/g" ./caffe-yolo/Makefile.config
sed -i "s/LIBRARY_DIRS := \$(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib/LIBRARY_DIRS := \$(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib \/usr\/lib\/x86_64-linux-gnu \/usr\/lib\/x86_64-linux-gnu\/hdf5\/serial/g" ./caffe-yolo/Makefile.config
sed -i "s/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_hl hdf5/LIBRARIES += glog gflags protobuf boost_system boost_filesystem m hdf5_serial_hl hdf5_serial/g" ./caffe-yolo/Makefile
sed -i '164a\-DCUDA_NVCC_FLAGS=--Wno-deprecated-gpu-targets' ./caffe-yolo/Makefile
cd caffe-yolo \
  && make all -j"$(nproc)" \
  && make pycaffe
