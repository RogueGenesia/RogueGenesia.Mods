#!/usr/bin/env bash
pushd work/game
echo "Starting game"
./RogueGenesia.exe --quit &
job_id=$!
counter=0
echo "Waiting for game to quit, or 1 minute, whichever comes first"
while [[ $counter -lt 10]] && ps -p $job_id >&-
do
	let counter++
	sleep 6
done

if ps -p $job_id >&-; then
	echo "WARNING: Game is still running, terminating it now."
	kill $job_id -9
fi

if [[ -f "./BepInEx/interop/ModGenesia.dll" ]] && [[ -f "./BepInEx/interop/RogueGenesia.dll" ]]; then
	echo "Successfully generated interop files"
	mkdir -p ../interop_output/
	cp ./BepInEx/interop/*.dll ../interop_output/
else
	echo "Error: Failed to generate mod interop libraries"
	exit 3
fi
