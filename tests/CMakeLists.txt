cmake_minimum_required(VERSION 3.19)

# This directory works both as a subproject of the main build and standalone:
#
#   cmake -S tests -B build-tests -G Ninja && cmake --build build-tests && ctest
#
# The standalone mode matters because the main build pulls in the vcpkg
# dependencies of the game libraries, while the tests are deliberately
# dependency-free and must stay buildable everywhere.
#
# The tests follow the conventions of the engine unit tests
# (xash3d-fwgs: public/tests, filesystem/tests): every test is a standalone
# program with its own main() that returns 0 on success and a non-zero value
# on failure, so that a failing test doesn't hide the result of the others.

if( NOT PROJECT_NAME STREQUAL "primext_tests" )
	project( primext_tests CXX )
endif()

set( CMAKE_CXX_STANDARD 17 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )

enable_testing()

# The root of the repository, for the include directories and scripts of the tests
set( PRIMEXT_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/.. )

# primext_add_test( <name> SOURCES <files...> [INCLUDES <dirs...>] [LIBS <libs...>] )
#
# A unit test: a standalone program with its own main(). SOURCES are relative to
# this directory, INCLUDES are the directories of the headers it checks.
function( primext_add_test name )
	cmake_parse_arguments( ARG "" "" "SOURCES;INCLUDES;LIBS" ${ARGN} )

	add_executable( ${name} ${ARG_SOURCES} )
	target_include_directories( ${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${ARG_INCLUDES} )

	if( ARG_LIBS )
		target_link_libraries( ${name} PRIVATE ${ARG_LIBS} )
	endif()

	add_test( NAME ${name} COMMAND ${name} )
endfunction()

# primext_add_script_test( <name> SCRIPT <file> [ARGS <-Dvar=value...>] )
#
# A test that is a "cmake -P" script, it doesn't need a compiler. SCRIPT is
# relative to this directory.
function( primext_add_script_test name )
	cmake_parse_arguments( ARG "" "SCRIPT" "ARGS" ${ARGN} )

	get_filename_component( script ${ARG_SCRIPT} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR} )
	add_test( NAME ${name} COMMAND ${CMAKE_COMMAND} ${ARG_ARGS} -P ${script} )
endfunction()

# Every "<something>.test.cmake" file in this directory registers its own tests
# with the functions above, so adding a test means adding files and never editing
# this one. That keeps independent changes from conflicting over the same lines.
#
#   tests/fs_openmode.test.cmake:
#     primext_add_test( test_fs_openmode
#         SOURCES test_fs_openmode.cpp
#         INCLUDES ${PRIMEXT_ROOT}/utils/common )
file( GLOB test_registrations CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.test.cmake )
foreach( registration ${test_registrations} )
	include( ${registration} )
endforeach()
