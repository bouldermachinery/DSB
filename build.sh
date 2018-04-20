#!/usr/bin/env bash

DSB="dsb68"
BASE_PATHS="dsb.ini base data dm csb"
SOURCE_FILES="src/winalleg.c src/fmod.c src/animap.c src/blenders.c src/callstack.c src/callstack_rerror.c src/common.c src/common_exp.c src/common_lua.c src/common_player.c src/common_timer.c src/compile.c src/console.c src/desktop.c src/destroy.c src/distort.c src/dsb_lua.c src/dungeon.c src/emblua.c src/export.c src/file.c src/fullscreen.c src/gamelock.c src/gameloop.c src/interact.c src/istack.c src/junk.c src/loadpng_loadpng.c src/lod.c src/lua_constants.c src/lua_constants_gii.c src/lua_exp_funcs.c src/main.c src/maintain.c src/memory.c src/mersenne.c src/monster.c src/movequeue.c src/mparty.c src/nosound.c src/object_actions.c src/objectsdata.c src/player.c src/rdefer.c src/render.c src/rhelper.c src/spawnburst.c src/systemtimer.c src/timer_events.c src/todo.c src/trans.c src/userdata.c src/util.c src/viewscale.c"
GCC_FLAGS="-w -L/usr/lib/x86_64-linux-gnu -L/usr/local/lib/libluajit-5.1.so.2 -L/usr/lib/x86_64-linux-gnu -I/usr/include -I/usr/include/luajit-2.0 -Isrc -fpermissive  -lluajit-5.1 -lalleg -lm -lpthread -lrt -lSM -lICE -lX11 -lXext -lXext -lXcursor -lXcursor -lXpm -lXxf86vm -lasound -lSM -lICE -lX11 -lXext -ldl -lpng"

ENGINE=${1:-allegro}
PLATFORM=${2:-win32}

case $ENGINE in
	allegro|love)
	;;
	*)
		echo "Invalid platform '$PLATFORM'; please choose allegro or love"
		exit 1
		;;
esac

case $PLATFORM in
	win32|linux)
	;;
	*)
		echo "Invalid engine '$ENGINE'; please choose win32 or linux"
		exit 1
		;;
esac

mkdir -p dist
rm -f $DSB.zip; zip -rq $DSB.zip $BASE_PATHS

echo "Building DSB with '$ENGINE' engine on platform '$PLATFORM'"

if [ $ENGINE == "love" ]; then
	mv $DSB.zip $DSB.love
	zip -q $DSB.love *.lua
	cp $DSB.love dist/


	if [ $PLATFORM == "win32" ]; then
		LOVE=win32/love-11.1.0-win32
		EXE=DSB-love.exe
		cat $LOVE/love.exe $DSB.love > $EXE
		rm *dll
		cp $LOVE/*dll .
		zip -rq dist/${DSB}-${ENGINE}_${PLATFORM}.zip *dll $EXE
	fi
else
	DIST=dist/${DSB}_${PLATFORM}.zip
	mv $DSB.zip $DIST

	EXE=dsb
	if [ $PLATFORM == "win32" ]; then
		rm *dll
		cp win32/lua5.1.dll .
		cp win32/allegro-4.2/*dll .
		zip -q $DIST *dll
		EXE=DSB.exe
	else
		gcc -o $EXE $SOURCE_FILES $GCC_FLAGS
	fi

	zip -q $DIST $EXE
fi
