FROM balenalib/raspberrypi4-64:buster

RUN apt-get update \
 && apt-get install -yq \
    build-essential \
    g++ \
    gcc \
    git \
    libjpeg-dev \
    openssh-server \
    python3 \
    python3-dev \
    python3-influxdb \
    python3-pip \
    python3-setuptools \
    tzdata \
    vim \
    wget \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd \
 && echo 'root:balena' | chpasswd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN git clone https://github.com/RPi-Distro/RTIMULib \
 && cd ./RTIMULib/Linux/python \
 && python3 setup.py build \
 && python3 setup.py install \
 && rm -rf ~/RTIMULib

WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY messenger.py messenger.py
COPY start.sh start.sh

ENV FLASK_APP=messenger.py
ENV FLASK_ENV=development
ENV TZ=Europe/Stockholm

EXPOSE 5000
CMD ./start.sh
