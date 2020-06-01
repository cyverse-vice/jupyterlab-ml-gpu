# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.6    (apt)
# pytorch       latest (pip)
# ==================================================================
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP3_INSTALL="python3 -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \
    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \
# ==================================================================
# tools
# ------------------------------------------------------------------
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        ca-certificates bash \
        cmake net-tools iputils-ping wget \
        byobu curl git htop man unzip vim \
        liblapack3 libblas-dev liblapack-dev gfortran \
        && \
# ==================================================================
# python 3
# ------------------------------------------------------------------
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3 python3-dev \
        python3-lxml python3-numpy python3-tk \
        libsm6 libxext6 libxrender1 libfontconfig1 \
	&& \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3 ~/get-pip.py && \
    ln -s /usr/bin/python3 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3 /usr/local/bin/python && \
    rm -f /usr/bin/python && \
    $PIP3_INSTALL \
        setuptools \
        && \
    $PIP3_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-learn==0.20.0 \
        matplotlib \
        Cython \
        && \
# ==================================================================
# tensorflow
# ------------------------------------------------------------------
    $PIP3_INSTALL \
        future \
        protobuf \
        enum34 \
        pyyaml \
        typing \
	Pillow \
	tqdm \
	nltk \
	opencv-python \
	opencv-contrib-python \
	h5py \
	imgaug \
	IPython[all] \
        && \

    $PIP3_INSTALL \
	jupyterlab \
        tensorflow-gpu>=1.3.0 \
        keras>=2.0.8 \
        && \
# ==================================================================
# Additional packages
# ------------------------------------------------------------------
    $PIP3_INSTALL \
        SimpleITK \
	scikit-image \
	morphsnakes \
        && \
    $PIP3_INSTALL \
    requests==2.18.4 \
	six \
	requests_toolbelt==0.6.2 \
        && \
# ==================================================================
# config & cleanup
# ------------------------------------------------------------------
    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*
# ==================================================================
# Volume  & Entry Layer
# ------------------------------------------------------------------
RUN mkdir /module
RUN mkdir /module/mrcnn
RUN mkdir /module/workspace
WORKDIR /module
COPY ./mrcnn /module/mrcnn
COPY jupyter_entry.sh /module/
RUN cd mrcnn && python setup.py install 
RUN cd mrcnn && wget https://github.com/matterport/Mask_RCNN/releases/download/v2.0/mask_rcnn_coco.h5

# Set entry and environment
ENV PATH /module:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENTRYPOINT ["jupyter"]

CMD ["lab", "--no-browser"]
