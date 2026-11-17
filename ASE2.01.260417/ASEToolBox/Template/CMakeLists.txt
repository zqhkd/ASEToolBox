# ASETarget/Slx2Rtw/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
# 查找所有源文件并添加到库中
file(GLOB_RECURSE UserModel_Slx2C_SRC Src/*.c)

# 添加库目标
add_library(UserModel_Slx2C STATIC ${UserModel_Slx2C_SRC})

# 包含头文件目录
target_include_directories(UserModel_Slx2C
    PUBLIC
    ${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Include
    ${ASE_PROJECT_WORK_DIR}/ASESysLib/Simulink_env/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/Include
)

link_directories(${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Lib)

target_link_libraries(UserModel_Slx2C
    m
    rfm2g
    DriverBlocks
)