#!/usr/bin/env bash
./prepare.sh

export WINEDLLOVERRIDES="mscoree,winhttp=n,b"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export WINEDEBUG="+loaddlls"
export WINEDLLOVERRIDES="mscoree,mshtml="
xvfb-run wineboot -i
xvfb-run winetricks -q dxvk
export WINEDLLOVERRIDES="mscoree,winhttp=n,b;mshtml="

echo "Installing steam game 2067920 - Rouge Genesia"
steamcmd +quit
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir /workspace/work/game +login $STEAMCMD_USER_NAME $STEAMCMD_USER_PASSWORD +app_update "2067920 -beta beta validate" +quit
ls /workspace/work/game
echo "Game installed. Unpacking BepInEx into game folder"
unzip work/bepinex.zip -d /workspace/work/game/
pushd /workspace/work/game/ || exit 2
echo "Starting game to extract mod DLLs"
dir ./
export WINEDEBUG="+loaddlls"
export WINEPATH="/workspace/work/game"
export WINEDLLOVERRIDES="mscoree,winhttp=n,b;mshtml="
xvfb-run wine64 ./Rogue\ Genesia.exe &
job_id=$!
counter=0
echo "Waiting for game to quit, or 3 minutes, whichever comes first"
while true
do
  if [[ "$counter" -gt '30' ]]; then 
    echo "Timed out waiting for game to create mod DLLs"
    break
  fi
  
  if [[ -f "./BepInEx/interop/ModGenesia.dll" ]] && [[ -f "./BepInEx/interop/RogueGenesia.dll" ]]; then 
    echo "Game mod binaries detected, sleeping for 1 second, then shutting down game"
    sleep 1
    break
  fi
  
  if ps $job_id &>/dev/null;
  then
    ((counter++))
    sleep 6
    echo -n '.'
  else
    echo "Game has exited."
    break
  fi
done

if ps $job_id >/dev/null; then
	echo "WARNING: Game is still running, terminating it now."
	kill -9 $job_id &> /dev/null || true
fi

if [[ -f "./BepInEx/interop/ModGenesia.dll" ]] && [[ -f "./BepInEx/interop/RogueGenesia.dll" ]]; then
	echo "Successfully generated interop files"
	cp -vR ./BepInEx/interop /workspace
	rm -f /workspace/interop/{Assembly-CSharp,Discord,com.rlabrecque.steamworks.net}.dll
	rm -f /workspace/interop/*.{txt,db}
	sha256sum /workspace/interop/* > /workspace/hashes.txt
else
	echo "Error: Failed to generate mod interop libraries"
	exit 3
fi

popd || exit 0
