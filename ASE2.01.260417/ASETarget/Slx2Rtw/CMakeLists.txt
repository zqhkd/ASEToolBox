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

# 添加静态库
if(NOT TARGET DriverBlocks)
    # 创建导入目标
    add_library(DriverBlocks STATIC IMPORTED)
    # 设置导入目标的位置
    set_target_properties(DriverBlocks PROPERTIES
        IMPORTED_LOCATION ${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Lib/libDriverBlocks.a
    )
endif()

link_directories(${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Lib)

target_link_libraries(UserModel_Slx2C
    -lrfm2g
    -lm
    DriverBlocks
)