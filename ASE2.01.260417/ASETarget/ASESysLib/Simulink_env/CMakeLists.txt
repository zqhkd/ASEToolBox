# ASETarget/ASESysLib/Simulink_env/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
# 定义项目名称
project(SimulinkProject)

# 查找所有源文件并添加到库中
file(GLOB_RECURSE SIMULINK_ENV_SRC Src/*.c)

# 链接最终可执行文件
add_executable(asebin ${SIMULINK_ENV_SRC})

# 包含头文件目录
target_include_directories(asebin
    PUBLIC
    ${ASE_PROJECT_WORK_DIR}/ASESysLib/drivers/Include
    ${ASE_PROJECT_WORK_DIR}/ASESysLib/Simulink_env/Include
    ${ASE_PROJECT_WORK_DIR}/${ASE_SLX2RTW_WORK_DIR}/Include
)

# # # 链接所需的库
target_link_libraries(asebin
    rfm2g
    DriverBlocks  
    UserModel_Slx2C
)
