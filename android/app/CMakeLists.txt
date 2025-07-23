cmake_minimum_required(VERSION 3.4.1)  # for example

add_definitions(-D__GCC -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0)

include_directories("${CMAKE_SOURCE_DIR}/scif2_src/head" "${CMAKE_SOURCE_DIR}/scif2_src" "${CMAKE_SOURCE_DIR}/scif2_src/src")

add_library( recorn

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ./scif2_src/src/sc2.cpp ./scif2_src/src/friend_client.cpp ./scif2_src/src/sc2_memory.cpp ./scif2_src/src/friend_client.cpp ./scif2_src/src/proc_data_talk.cpp ./scif2_src/src/proc_connect_build.cpp ./scif2_src/src/proc_sync_handle.cpp ./scif2_src/src/proc_ftp.cpp ./scif2_src/src/common_function.cpp)