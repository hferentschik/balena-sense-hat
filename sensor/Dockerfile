FROM balenalib/raspberrypi4-64:buster

RUN apt-get update \
 && apt-get install -yq \
    build-essential \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-influxdb \
    zlib1g-dev \
    libjpeg-dev \
    gcc \
    g++ \
    vim \
    git \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/RPi-Distro/RTIMULib \
 && cd ./RTIMULib/Linux/python \
 && python3 setup.py build \
 && python3 setup.py install \
 && rm -rf ~/RTIMULib

WORKDIR /usr/src/app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY measure.py measure.py

ENV INITSYSTEM on
CMD ["python3", "measure.py"]
