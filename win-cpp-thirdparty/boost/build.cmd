setlocal
call config.cmd

pushd %boost_dir%
b2 stage --stagedir=..\%stage_dir86% --build-dir=..\boost-build toolset=msvc-14.0 runtime-link=static,shared address-model=32 -j4
b2 stage --stagedir=..\%stage_dir64% --build-dir=..\boost-build toolset=msvc-14.0 runtime-link=static,shared address-model=64 -j4
popd