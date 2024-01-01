# syntax=docker/dockerfile:1

FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

RUN <<EOF
apt-get update
apt-get install -y ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

COPY <<EOF /etc/apt/sources.list
deb https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ focal-security main restricted universe multiverse
EOF

ENV TZ=Asia/Shanghai

RUN <<EOF
apt-get update
apt-get install -y tzdata
apt-get install -y locales && locale-gen en_US.UTF-8
apt-get install -y gosu
rm -rf /var/lib/apt/lists/*
EOF

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN <<EOF
apt-get update
apt-get install -y git
apt-get install -y build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
rm -rf /var/lib/apt/lists/*
EOF

ENV PYENV_ROOT="/usr/local/pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
ARG PYTHON_VERSION="3.10"
# https://github.com/pyenv/pyenv/pull/2592
# https://github.com/pyenv/pyenv/wiki#how-to-build-cpython-for-maximum-performance
ARG PYTHON_CONFIGURE_OPTS="--disable-shared --enable-optimizations --with-lto"
ARG PYTHON_CFLAGS="-march=native -mtune=native"

RUN <<EOF
curl https://pyenv.run | bash
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
EOF

RUN <<EOF
python -m pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir nuitka
EOF

RUN <<EOF
apt-get update
apt-get install -y ccache patchelf
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /code

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
COPY docker-cmd.sh /usr/local/bin/
CMD ["docker-cmd.sh"]
