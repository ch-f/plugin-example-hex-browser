# SPDX-License-Identifier: MIT
cmake_minimum_required(VERSION 3.10)
project(plugin_example_hex_browser)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Force a minimum Qt6 version of 6.4
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Qml Quick)

add_library(plugin_example_hex_browser SHARED
        PluginExampleHexBrowser.cpp
        HelloWorldItem.cpp
        Helper.cpp
        resources.qrc
)

set_target_properties(plugin_example_hex_browser PROPERTIES
	VERSION "0.0.1"
	SOVERSION "0"
)

target_include_directories(plugin_example_hex_browser PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(plugin_example_hex_browser PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS plugin_example_hex_browser
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# --- Standalone executable target ---
add_executable(example_hex_browser
        main.cpp
)

target_link_libraries(example_hex_browser PRIVATE
        plugin_example_hex_browser
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
)

install(TARGETS example_hex_browser
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
