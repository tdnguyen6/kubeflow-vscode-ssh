FROM ghcr.io/tidunguyen/vscode-ssh:base

RUN mkdir -p ~/miniconda3 && \
    curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda3/miniconda.sh && \
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
    rm -rf ~/miniconda3/miniconda.sh && \
    ~/miniconda3/bin/conda init bash && \
    ~/miniconda3/bin/conda init zsh

# This line is always needed to install things overlayed on top of mounted $HOME
RUN cp -pr ${HOME} /tmp_home
