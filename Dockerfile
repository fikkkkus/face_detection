FROM python:3.6-alpine

WORKDIR /usr/src/

# Обновление apk индекса и установка необходимых зависимостей
RUN apk update && apk add --no-cache \
    build-base \
    ca-certificates \
    clang-dev \
    clang \
    cmake \
    libwebp-dev \
    linux-headers \
    openssl \
    python3-dev \
    unzip \
    zlib-dev \
    libxml2-dev \
    libxslt-dev \
    && rm -rf /var/cache/apk/*  # Удаление кеша после установки

# Установка Python-зависимостей
RUN pip3 install numpy

# Задание версии OpenCV
ENV OPENCV_VERSION=4.2.0

RUN mkdir /usr/src/opencv-tmp

# Загрузка и распаковка OpenCV core
RUN wget -O /usr/src/opencv-tmp/opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
    && unzip /usr/src/opencv-tmp/opencv.zip \
    && mv opencv-${OPENCV_VERSION} /usr/src/opencv

# Загрузка и распаковка OpenCV contrib
RUN wget -O /usr/src/opencv-tmp/opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
    && unzip /usr/src/opencv-tmp/opencv_contrib.zip \
    && mv opencv_contrib-${OPENCV_VERSION} /usr/src/opencv_contrib

WORKDIR /usr/src/opencv/build

# Конфигурация опций сборки
RUN cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_C_COMPILER=/usr/bin/clang \
    -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/usr/src/opencv_contrib/modules \
    -D PYTHON3_LIBRARY=`python -c 'import subprocess ; import sys ; s = subprocess.check_output("python-config --configdir", shell=True).decode("utf-8").strip() ; (M, m) = sys.version_info[:2] ; print("{}/libpython{}.{}.dylib".format(s, M, m))'` \
    -D PYTHON3_INCLUDE_DIR=`python -c 'import distutils.sysconfig as s; print(s.get_python_inc())'` \
    -D PYTHON3_EXECUTABLE=/usr/local/bin/python3 \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D BUILD_EXAMPLES=ON \
    ..

# Компиляция (с использованием всех доступных ядер)
RUN make -j$(nproc)

# Установка OpenCV
RUN make install

# Обновление ссылок на библиотеки
RUN ldconfig /etc/ld.so.conf.d

# Переход в директорию проекта
WORKDIR /usr/src/project

# Очистка временных файлов после сборки
RUN rm -rf /usr/src/opencv/build \
    && rm -rf /usr/src/opencv-tmp  # Удаление временной директории

# Копирование скрипта и файлов по умолчанию
COPY face_detector.py /usr/src/project/face_detector.py
COPY default_image.jpg /usr/src/project/default_image.jpg
COPY haarcascade_frontalface_default.xml /usr/src/project/haarcascade_frontalface_default.xml

# Установка точки входа для запуска скрипта
ENTRYPOINT ["python3", "/usr/src/project/face_detector.py"]
