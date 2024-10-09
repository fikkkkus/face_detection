# Этап сборки
FROM python:3.9-slim AS builder

# Установка необходимых системных зависимостей
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libv4l-dev \
    libatlas-base-dev \
    gfortran \
    python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Установка numpy
RUN pip install numpy

# Клонирование и сборка OpenCV
RUN git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Финальный образ
FROM python:3.9-slim

# Копирование собранных файлов из этапа сборки
COPY --from=builder /usr/local /usr/local

# Копирование вашего приложения в контейнер
COPY . /app
WORKDIR /app

# Установка зависимостей вашего приложения
RUN pip install -r requirements.txt

# Команда для запуска приложения
ENTRYPOINT ["python", "face_detection.py"]
