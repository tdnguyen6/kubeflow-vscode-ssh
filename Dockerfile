FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/base:master

# ========================== First become root to run privileged commands ==========================

USER root 

RUN apt-get update

RUN curl https://i.jpillora.com/chisel! | bash

RUN apt-get install -y openssh-server sudo zsh jq --no-install-recommends

RUN usermod -aG sudo ${NB_USER}

RUN echo ${NB_USER}:${NB_USER} | chpasswd

RUN echo "${NB_USER} ALL=(root) NOPASSWD:SETENV: /init" >> /etc/sudoers

COPY ssh-configs/* /etc/ssh

COPY bin/* /usr/local/bin
# build-img
ADD https://gist.githubusercontent.com/tidunguyen/82c0c67091f6b967bf1f0e58e0eb100c/raw/77219b01eb6887245de4a2b64ffaf51665720f2a/build-img /usr/local/bin/build-img
RUN chmod +rx /usr/local/bin/build-img

# Crane tool 
RUN cd /tmp && \
  curl -LO https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_x86_64.tar.gz && \
  curl -Ls https://github.com/google/go-containerregistry/releases/latest/download/checksums.txt | grep go-containerregistry_Linux_x86_64.tar.gz | sha256sum -c && \
  mkdir /go-container-registry && \
  tar xzvf /tmp/go-containerregistry_Linux_x86_64.tar.gz -C /go-container-registry && \
  ln -sf /go-container-registry/crane /usr/local/bin/crane && \
  ln -sf /go-container-registry/gcrane /usr/local/bin/gcrane

# s6 - copy init scripts
COPY s6/ /etc

RUN mkdir -p -m 777 /tmp_home

COPY instructions/dist /instructions

# ===================== Become NB_USER to install things in $HOME and as default container user =====================

USER ${NB_USER}

# RUN mkdir -p ~/miniconda3 && \
#     curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda3/miniconda.sh && \
#     bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
#     rm -rf ~/miniconda3/miniconda.sh && \
#     ~/miniconda3/bin/conda init bash && \
#     ~/miniconda3/bin/conda init zsh

RUN mkdir ${HOME}/.init.d

# This line is always needed to install things overlayed on top of mounted $HOME
RUN cp -pr ${HOME} /tmp_home

EXPOSE 8888

ENTRYPOINT ["sudo", "-E", "/init"]
