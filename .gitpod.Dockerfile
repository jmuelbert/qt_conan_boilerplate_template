FROM trainiteu/gitpod-cpp

# Add clang-12 and clang-15 apt repositories
RUN lsb_rel=`lsb_release -cs` \
    && add-apt-repository "deb http://apt.llvm.org/${lsb_rel}/ llvm-toolchain-${lsb_rel}-12 main" \
    && add-apt-repository "deb http://apt.llvm.org/${lsb_rel}/ llvm-toolchain-${lsb_rel}-13 main" \
    && add-apt-repository "deb http://apt.llvm.org/${lsb_rel}/ llvm-toolchain-${lsb_rel} main"

# Install older compilers supported by the project as well as clang-format-15 for code formatting
RUN install-packages \
    g++-10 \
    clang-12 \
    clang-13 \
    clang-format-15
