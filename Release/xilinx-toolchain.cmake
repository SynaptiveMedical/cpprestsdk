SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)

# specify the cross compiler
SET(CMAKE_C_COMPILER   arm-linux-gnueabihf-gcc-4.9)
SET(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++-4.9) 

SET(CMAKE_FIND_ROOT_PATH /usr/lib/arm-linux-gnueabihf /home/stephure/boost_1_59_0-arm)

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
