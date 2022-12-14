#!/usr/bin/env bash
echo "Installing dependencies, this will take a while."
echo steam steam/question select "I AGREE" | debconf-set-selections
echo steam steam/license note '' | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive
export WINE_PACKAGE_VERSION=7.22~jammy-1
apt-get update
apt-get install -y wget software-properties-common curl
add-apt-repository --yes multiverse
add-apt-repository --yes "deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse"
dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
cat winehq.key | tee /etc/apt/keyrings/winehq-archive.key
rm -f winehq.key
wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
mv winehq-jammy.sources /etc/apt/sources.list.d/
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates gnupg cabextract unzip
apt-get install -y --install-recommends xvfb lib32gcc-s1 steamcmd \
                                        winehq-staging=$WINE_PACKAGE_VERSION \
                                        wine-staging=$WINE_PACKAGE_VERSION \
                                        wine-staging-i386=$WINE_PACKAGE_VERSION \
                                        wine-staging-amd64=$WINE_PACKAGE_VERSION

wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
mv winetricks /usr/local/bin
chmod +x /usr/local/bin/winetricks

ln -s /usr/games/steamcmd /usr/bin/steamcmd
mkdir -p /workspace/work/game
chmod 777 /workspace/work
chmod 777 /workspace/work/game
cd /workspace || exit 4
curl "https://builds.bepinex.dev/projects/bepinex_be/660/BepInEx-Unity.IL2CPP-win-x64-6.0.0-be.660%2B40bf261.zip" --output work/bepinex.zip
