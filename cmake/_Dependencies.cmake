# cmake/_Dependencies.cmake is generated by `mulle-sde`. Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

if( NOT MULLE_OBJC_RUNTIME_LIBRARY)
   find_library( MULLE_OBJC_RUNTIME_LIBRARY NAMES ${CMAKE_STATIC_LIBRARY_PREFIX}mulle-objc-runtime${CMAKE_STATIC_LIBRARY_SUFFIX} mulle-objc-runtime)
   message( STATUS "MULLE_OBJC_RUNTIME_LIBRARY is ${MULLE_OBJC_RUNTIME_LIBRARY}")

   # the order looks ascending, but due to the way this file is read
   # it ends up being descending, which is what we need
   if( MULLE_OBJC_RUNTIME_LIBRARY)
      set( ALL_LOAD_DEPENDENCY_LIBRARIES
         ${ALL_LOAD_DEPENDENCY_LIBRARIES}
         ${MULLE_OBJC_RUNTIME_LIBRARY}
         CACHE INTERNAL "need to cache this"
      )
      # temporarily expand CMAKE_MODULE_PATH
      get_filename_component( _TMP_MULLE_OBJC_RUNTIME_ROOT "${MULLE_OBJC_RUNTIME_LIBRARY}" DIRECTORY)
      get_filename_component( _TMP_MULLE_OBJC_RUNTIME_ROOT "${_TMP_MULLE_OBJC_RUNTIME_ROOT}" DIRECTORY)

      # search for DependenciesAndLibraries.cmake to include
      foreach( _TMP_MULLE_OBJC_RUNTIME_NAME in mulle-objc-runtime)
         set( _TMP_MULLE_OBJC_RUNTIME_DIR "${_TMP_MULLE_OBJC_RUNTIME_ROOT}/include/${_TMP_MULLE_OBJC_RUNTIME_NAME}/cmake")
         # use explicit path to avoid "surprises"
         if( EXISTS "${_TMP_MULLE_OBJC_RUNTIME_DIR}/DependenciesAndLibraries.cmake")
            unset( MULLE_OBJC_RUNTIME_DEFINITIONS)
            list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_OBJC_RUNTIME_DIR}")
            include( "${_TMP_MULLE_OBJC_RUNTIME_DIR}/DependenciesAndLibraries.cmake")
            list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_OBJC_RUNTIME_DIR}")
            set( INHERITED_DEFINITIONS
               ${INHERITED_DEFINITIONS}
               ${MULLE_OBJC_RUNTIME_DEFINITIONS}
               CACHE INTERNAL "need to cache this"
            )
            break()
         endif()
      endforeach()
   else()
      message( FATAL_ERROR "MULLE_OBJC_RUNTIME_LIBRARY was not found")
   endif()
endif()


if( NOT MULLE_CONTAINER_LIBRARY)
   find_library( MULLE_CONTAINER_LIBRARY NAMES ${CMAKE_STATIC_LIBRARY_PREFIX}mulle-container${CMAKE_STATIC_LIBRARY_SUFFIX} mulle-container)
   message( STATUS "MULLE_CONTAINER_LIBRARY is ${MULLE_CONTAINER_LIBRARY}")

   # the order looks ascending, but due to the way this file is read
   # it ends up being descending, which is what we need
   if( MULLE_CONTAINER_LIBRARY)
      set( DEPENDENCY_LIBRARIES
         ${DEPENDENCY_LIBRARIES}
         ${MULLE_CONTAINER_LIBRARY}
         CACHE INTERNAL "need to cache this"
      )
      # temporarily expand CMAKE_MODULE_PATH
      get_filename_component( _TMP_MULLE_CONTAINER_ROOT "${MULLE_CONTAINER_LIBRARY}" DIRECTORY)
      get_filename_component( _TMP_MULLE_CONTAINER_ROOT "${_TMP_MULLE_CONTAINER_ROOT}" DIRECTORY)

      # search for DependenciesAndLibraries.cmake to include
      foreach( _TMP_MULLE_CONTAINER_NAME in mulle-container)
         set( _TMP_MULLE_CONTAINER_DIR "${_TMP_MULLE_CONTAINER_ROOT}/include/${_TMP_MULLE_CONTAINER_NAME}/cmake")
         # use explicit path to avoid "surprises"
         if( EXISTS "${_TMP_MULLE_CONTAINER_DIR}/DependenciesAndLibraries.cmake")
            unset( MULLE_CONTAINER_DEFINITIONS)
            list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_CONTAINER_DIR}")
            include( "${_TMP_MULLE_CONTAINER_DIR}/DependenciesAndLibraries.cmake")
            list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_CONTAINER_DIR}")
            set( INHERITED_DEFINITIONS
               ${INHERITED_DEFINITIONS}
               ${MULLE_CONTAINER_DEFINITIONS}
               CACHE INTERNAL "need to cache this"
            )
            break()
         endif()
      endforeach()
   else()
      message( FATAL_ERROR "MULLE_CONTAINER_LIBRARY was not found")
   endif()
endif()
