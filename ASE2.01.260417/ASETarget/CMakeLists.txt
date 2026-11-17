# ASETarget/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(ASE_PROJECT)

# 启用C11标准
# set(CMAKE_C_STANDARD 11)
set(ASE_PROJECT_WORK_DIR  "/home/administrator/projects/ASETarget")
# set(ASE_SLX2RTW_WORK_DIR "Demo/zhuxh_GE5565Demo_rtbak_ert_rtw")
set(ASE_SLX2RTW_WORK_DIR "Slx2Rtw")

# C++17 Compiler
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置CMake构建类型
# set(CMAKE_BUILD_TYPE Release)
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g")


# 设置CMake输出目录
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# message(STATUS "Library path: ${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Lib")
# file /home/administrator/projects/ASETarget/ASESysLib/drivers/Lib/libDriverBlocks.a     # 这是一条bash命令
link_directories(${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Lib)

# 添加子目录
option(BUILD_DRIVERS "Build drivers library" OFF)  # 添加一个选项来控制是否编译 drivers
if(BUILD_DRIVERS)
    add_subdirectory(ZFDevLib/drivers)     # cmake -DBUILD_DRIVERS=ON .. && make
endif()
add_subdirectory(${ASE_SLX2RTW_WORK_DIR})
add_subdirectory(ASESysLib/Simulink_env)
