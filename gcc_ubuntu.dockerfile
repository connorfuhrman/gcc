from ubuntu:latest as gccbuilder 

# Update base image packages 
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential g++-multilib wget
# Download and install GCC
# Configuration info is at https://gcc.gnu.org/install/configure.html
# Wiki example is at https://gcc.gnu.org/wiki/InstallingGCC
ENV GCC_VERSION=11.2.0
# Download step
RUN mkdir /gcc_workdir && cd /gcc_workdir && \
    wget https://bigsearcher.com/mirrors/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz && \
    tar -xzf gcc-$GCC_VERSION.tar.gz && cd gcc-$GCC_VERSION && ./contrib/download_prerequisites
# Configure and build
RUN mkdir /gcc_workdir/gcc-build && cd /gcc_workdir/gcc-build && \
    /gcc_workdir/gcc-$GCC_VERSION/configure --prefix=/usr/local --enable-languages=c,c++,fortran,go && \
    make -j$(nproc) && make install
# Cleanup step
RUN rm -fr /gcc_workdir


from debian:bullseye-slim
# Copy GCC from the builder
COPY --from=gccbuilder /usr/local/ /usr/local/

