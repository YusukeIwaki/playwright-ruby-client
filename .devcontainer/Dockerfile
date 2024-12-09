FROM docker.io/debian:bookworm

ARG RUBY_VERSION=2.7.8
ARG NODEJS_VERSION=22.12.0

SHELL [ "bash", "-lc" ]
# install version managers
RUN apt update \
  && apt install -y curl git build-essential zlib1g-dev \
  && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1 \
  && echo 'export ASDF_DIR="$HOME/.asdf"' >> ~/.bashrc\
  && echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc

RUN asdf plugin add nodejs \
  && asdf install nodejs ${NODEJS_VERSION} \
  && asdf global nodejs ${NODEJS_VERSION}

RUN asdf plugin add ruby \
  && asdf install ruby ${RUBY_VERSION} \
  && asdf global ruby ${RUBY_VERSION}

COPY ./entrypoint.sh .
ENTRYPOINT [ "/entrypoint.sh"]

WORKDIR /src
