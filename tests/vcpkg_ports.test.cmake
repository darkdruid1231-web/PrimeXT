# the vcpkg PhysX port must not depend on patches downloaded from GitHub,
# see vcpkg_ports/physx and vcpkg_ports/check_physx_port.cmake
primext_add_script_test( vcpkg_physx_port
	SCRIPT vcpkg_ports/check_physx_port.cmake
	ARGS -DREPO_ROOT=${PRIMEXT_ROOT} )

# the overlay Android triplets must build the vcpkg dependencies against the same
# API level as the app, see vcpkg_triplets and vcpkg_ports/check_android_triplets.cmake
primext_add_script_test( vcpkg_android_triplets
	SCRIPT vcpkg_ports/check_android_triplets.cmake
	ARGS -DREPO_ROOT=${PRIMEXT_ROOT} )
