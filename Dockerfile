FROM python:3.9-cuda11.8-devel

# Clone et build votre repo AuraSR
RUN git clone https://github.com/Cichelg/cog-aura-sr-v2.git /cog-aura-sr-v2
WORKDIR /cog-aura-sr-v2

# Install Cog
RUN curl -o /usr/local/bin/cog -L https://github.com/replicate/cog/releases/latest/download/cog_Linux_x86_64
RUN chmod +x /usr/local/bin/cog

# Build the Cog model
RUN cog build

WORKDIR /

ENV RUNPOD_REQUEST_TIMEOUT=600

# Install necessary packages and Python 3.10
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends software-properties-common curl git openssh-server && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends python3.10 python3.10-dev python3.10-distutils && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 &&\
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Install runpod within the virtual environment
RUN /opt/venv/bin/pip install runpod

ADD src/handler.py /rp_handler.py

CMD ["/opt/venv/bin/python3", "-u", "/rp_handler.py"]
