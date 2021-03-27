FROM ubuntu:focal

# Utilities and libraries
RUN apt update && \
	DEBIAN_FRONTEND="noninteractive" apt install -y \
	cmake \
	doxygen \
	g++ \
	gir1.2-gtk-3.0 \
	git \
	libboost-all-dev \
	libfftw3-dev \
	libgmp3-dev \
	liblog4cpp5-dev \
	libqwt-qt5-dev \
	python3-click-plugins \
	python3-distutils \
	python3-gi-cairo \
	python3-mako \
	python3-numpy \
	python3-pip \
	python3-pyqt5 \
	python3-pyqtgraph \
	python3-scipy \
	python3-yaml \
	qtbase5-dev

# Pip dependencies
RUN pip3 install "pybind11[global]" pygccxml

# Volk
RUN mkdir src/ && cd src/ && \
	git clone --recursive https://github.com/gnuradio/volk.git && \
	cd volk && mkdir build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 ../ \
	&& make && make test && make install

# Configure the env vars required to run GR
ENV GR_PREFIX=/root/gr_prefix
WORKDIR $GR_PREFIX
RUN echo "export PATH=$GR_PREFIX/bin/:${PATH}" >> /root/.bashrc
RUN echo "export LD_LIBRARY_PATH=$GR_PREFIX/lib/:${LD_LIBRARY_PATH}" >> /root/.bashrc
RUN echo "export PYTHONPATH=$GR_PREFIX/lib/python3/dist-packages/:${PYTHONPATH}" >> /root/.bashrc

# Change the entrypoint to run ldconfig on startup
ADD entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]
CMD ["/bin/bash"]