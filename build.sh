#!/usr/bin/env bash

function build {
	DSB="dsb68"
	BASE_PATHS="dsb.ini base data dm csb mfi_dungeon"
	SOURCE_FILES="src/animap.c src/blenders.c src/callstack.c src/callstack_rerror.c src/common.c src/common_exp.c src/common_lua.c src/common_player.c src/common_timer.c src/compile.c src/console.c src/desktop.c src/destroy.c src/distort.c src/dsb_lua.c src/dungeon.c src/emblua.c src/export.c src/file.c src/fullscreen.c src/gamelock.c src/gameloop.c src/interact.c src/istack.c src/junk.c src/loadpng_loadpng.c src/lod.c src/lua_constants.c src/lua_constants_gii.c src/lua_exp_funcs.c src/main.c src/maintain.c src/memory.c src/mersenne.c src/monster.c src/movequeue.c src/mparty.c src/object_actions.c src/objectsdata.c src/player.c src/rdefer.c src/render.c src/rhelper.c src/spawnburst.c src/systemtimer.c src/timer_events.c src/todo.c src/trans.c src/userdata.c src/util.c src/viewscale.c"
	GCC_FLAGS="-w -Isrc -fpermissive -std=gnu90"

	ENGINE=${1:-none}
	PLATFORM=${2:-none}
	SOUND=${3:-none}

	MSG="Building DSB with '$ENGINE' engine"
	case $ENGINE in
		allegro)
			case $PLATFORM in
				win32|linux64)
				;;
				*)
					echo "Invalid platform '$PLATFORM'; choose either win32 or linux64"
					exit 1
					;;
			esac

			case $SOUND in
				fmod|none)
					MSG="$MSG and sound system '$SOUND'"
					;;
				*)
					echo "Invalid sound system '$SOUND'; choose either fmod or none"
					exit 1
					;;
			esac
			;;
		love)
			;;
		*)
			echo "Invalid engine '$ENGINE'; choose either allegro or love"
			exit 1
			;;
	esac

	if [ $PLATFORM != "none" ]; then
		MSG="$MSG on platform '$PLATFORM'"
	fi

	echo $MSG

	mkdir -p dist
	rm -f $DSB.zip; zip -rq $DSB.zip $BASE_PATHS

	if [ $ENGINE == "love" ]; then
		mv $DSB.zip $DSB.love
		echo "- Creating $DSB.love"
		zip -q $DSB.love *.lua
		cp $DSB.love dist/

		if [ $PLATFORM == "win32" ]; then
			LOVE=win32/love-11.1.0-win32
			EXE=DSB-love.exe
			echo "- Creating $EXE"
			cat $LOVE/love.exe $DSB.love > $EXE
			rm *dll
			cp $LOVE/*dll .
			DIST=dist/${DSB}-${ENGINE}_${PLATFORM}.zip
			echo "- Creating $DIST"
			zip -rq $DIST *dll $EXE
		fi
	else
		DIST=dist/${DSB}_${PLATFORM}

		if [ $PLATFORM == "win32" ]; then
			EXE="DSB"
			# GCC="/usr/lib/mxe/usr/bin/i686-w64-mingw32.static-gcc" # mxe
			GCC="i686-w64-mingw32-gcc-win32" # apt install mingw-w64-i686-dev
			GCC_FLAGS="$GCC_FLAGS -Iwin32/allegro-4.2/include/ -Iwin32/allegro-4.2/include/allegro -Iwin32 -Iwin32/lua-5.1.4_Win32_dll12_lib/include -Lwin32/allegro-4.2/ -lalleg42 -Lwin32 -lpng12 -lzlib1 -Lwin32/lua-5.1.4_Win32_dll12_lib -llua5.1"
		else
			EXE="dsb"
			GCC="gcc"
			GCC_FLAGS="$GCC_FLAGS -L/usr/lib/x86_64-linux-gnu -L/usr/local/lib/libluajit-5.1.so.2 -I/usr/include -I/usr/include/luajit-2.0 -lluajit-5.1 -lalleg -lm -lpthread -lrt -lSM -lICE -lX11 -lXext -lXext -lXcursor -lXcursor -lXpm -lXxf86vm -lasound -lSM -lICE -lX11 -lXext -ldl -lpng"
			SOURCE_FILES="$SOURCE_FILES src/dummywin.c"
		fi

		if [ $SOUND == "fmod" ]; then
			SOURCE_FILES="$SOURCE_FILES src/sound.c"
			# EXE="$EXE-fmod"
			# DIST="$DIST-fmod"
		else
			EXE="$EXE-nosound"
			DIST="$DIST-nosound"
			SOURCE_FILES="$SOURCE_FILES src/fmod.c src/nosound.c"
		fi

		DIST="$DIST.zip"
		mv $DSB.zip $DIST

		if [ $PLATFORM == "win32" ]; then

			rm -f *dll
			cp win32/lua-5.1.4_Win32_dll12_lib/lua5.1.dll win32/allegro-4.2/*dll win32/libpng12.dll .

			if [ $SOUND == "fmod" ]; then
				# cp "fmodex/fmodapi42636win32/api/fmodex.dll" .
				FMOD=win32/fmodex.dll
				if [ ! -f $FMOD ]; then
					echo "Error: Please download fmod from https://github.com/alexey-lysiuk/fmodex-zdoom/raw/master/4.26/fmodapi42636win32-installer.exe and place the .dll library here: $FMOD"
					exit 1
				fi
				cp $FMOD .
				GCC_FLAGS="-Ifmodex/fmodapi42636win32/api/inc $GCC_FLAGS -L. -lfmodex -Wl,--enable-stdcall-fixup"
			fi

			zip -q $DIST *dll
		else

			if [ $SOUND == "fmod" ]; then
				rm -f *.so
				# cp fmodex/fmodapi42636linux64/api/lib/libfmodex64-4.26.36.so libfmodex64.so
				FMOD=linux64/libfmodex64-4.26.36.so
				if [ ! -f $FMOD ]; then
					echo "Error: Please download fmod from https://github.com/alexey-lysiuk/fmodex-zdoom/raw/master/4.26/fmodapi42636linux64.tar.gz and place the .so library here: $FMOD"
					exit 1
				fi
				cp $FMOD libfmodex64.so
				GCC_FLAGS="-Ifmodex/fmodapi42636linux64/api/inc $GCC_FLAGS -L. -lfmodex64"
				zip -q $DIST *so
				echo "LD_LIBRARY_PATH=. ./dsb-fmod" > dsb-fmod.sh
				chmod 777 dsb-fmod.sh
				zip -q $DIST dsb-fmod.sh
			fi
		fi

		if [ $PLATFORM == "win32" ]; then
			EXE="$EXE.exe"
		fi
		echo "- Creating $EXE"
		$GCC -o $EXE $SOURCE_FILES $GCC_FLAGS

		echo "- Creating $DIST"
		zip -q $DIST $EXE
	fi
}

if [ -z $1 ]; then
	echo "Removing dist/*"
	rm dist/*
	build allegro win32
	build allegro win32 fmod
	build allegro linux64
	build allegro linux64 fmod
	build love
	build love win32
elif [ $1 == "clean" ]; then
	rm dsb
	rm dsb-*
	rm DSB*
	rm *so
	rm *dll
	rm *.love
else
	build "$@"
fi