# https://hub.docker.com/r/cwaffles/openpose
FROM ubuntu:focal

#get deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-dev python3-pip python3-setuptools git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
    libgoogle-glog-dev libboost-all-dev caffe-cpu libhdf5-dev libatlas-base-dev

#for python api
RUN pip3 install --upgrade pip
RUN pip3 install numpy opencv-python 

#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.tar.gz && \
tar xzf cmake-3.16.0-Linux-x86_64.tar.gz -C /opt && \
rm cmake-3.16.0-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.16.0-Linux-x86_64/bin:${PATH}"

#get openpose
RUN git clone https://github.com/KWNahyun/openpose.git
WORKDIR /openpose
RUN    cd /openpose/models/pose/body_25 && wget -O pose_iter_584000.caffemodel -c https://www.dropbox.com/s/3x0xambj2rkyrap/pose_iter_584000.caffemodel?dl=0
# pose_iter_116000.caffemodel
RUN    cd /openpose/models/face && wget -O pose_iter_116000.caffemodel-c https://www.dropbox.com/s/d08srojpvwnk252/pose_iter_116000.caffemodel?dl=0
# pose_iter_102000.caffemodel
RUN    cd /openpose/models/hand && wget -O pose_iter_102000.caffemodel -c https://www.dropbox.com/s/gqgsme6sgoo0zxf/pose_iter_102000.caffemodel?dl=0

# use 'sed' to comment out the line in the OpenPose repo that downloads the model from the failed link
RUN sed -i 's/executeShInItsFolder "getModels.sh"/# executeShInItsFolder "getModels.sh"/g' /openpose/scripts/ubuntu/install_openpose_JetsonTX2_JetPack3.1.sh
RUN sed -i 's/executeShInItsFolder "getModels.sh"/# executeShInItsFolder "getModels.sh"/g' /openpose/scripts/ubuntu/install_openpose_JetsonTX2_JetPack3.3.sh
RUN sed -i 's/download_model("BODY_25"/# download_model("BODY_25"/g' /openpose/CMakeLists.txt
RUN sed -i 's/78287B57CF85FA89C03F1393D368E5B7/# 78287B57CF85FA89C03F1393D368E5B7/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("body (COCO)"/# download_model("body (COCO)"/g' /openpose/CMakeLists.txt
RUN sed -i 's/5156d31f670511fce9b4e28b403f2939/# 5156d31f670511fce9b4e28b403f2939/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("body (MPI)"/# download_model("body (MPI)"/g' /openpose/CMakeLists.txt
RUN sed -i 's/2ca0990c7562bd7ae03f3f54afa96e00/# 2ca0990c7562bd7ae03f3f54afa96e00/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("face"/# download_model("face"/g' /openpose/CMakeLists.txt
RUN sed -i 's/e747180d728fa4e4418c465828384333/# e747180d728fa4e4418c465828384333/g' /openpose/CMakeLists.txt
RUN sed -i 's/download_model("hand"/# download_model("hand"/g' /openpose/CMakeLists.txt
RUN sed -i 's/a82cfc3fea7c62f159e11bd3674c1531/# a82cfc3fea7c62f159e11bd3674c1531/g' /openpose/CMakeLists.txt

#get openpose
#WORKDIR /openpose
#COPY . .

#build it
WORKDIR /openpose/build
RUN cmake -DBUILD_PYTHON=ON -DGPU_MODE=CPU_ONLY -DOWNLOAD_HAND_MODEL=OFF -DOWNLOAD_FACE_MODEL=OFF .. && make -j `nproc`