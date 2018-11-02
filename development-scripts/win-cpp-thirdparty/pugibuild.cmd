call msvc_flags.cmd

@echo on
@rem debug
cl /c src/pugixml.cpp %DEBUG_CPPFALGS% %DEBUG_DEFINES% /MDd /Fobuild/
lib build/pugixml.obj -out:build/pugixml-mt-gd.lib
del build\pugixml.obj

@rem static debug
cl /c src/pugixml.cpp %DEBUG_CPPFALGS% %DEBUG_DEFINES% /MTd /Fobuild/
lib build/pugixml.obj -out:build/pugixml-mt-sgd.lib
del build\pugixml.obj

@rem release
cl /c src/pugixml.cpp %RELEASE_CPPFALGS% %RELEASE_DEFINES% /MD /Fobuild/
lib build/pugixml.obj -out:build/pugixml-mt.lib
del build\pugixml.obj

@rem static release
cl /c src/pugixml.cpp %RELEASE_CPPFALGS% %RELEASE_DEFINES% /MT /Fobuild/
lib build/pugixml.obj -out:build/pugixml-mt-s.lib
del build\pugixml.obj