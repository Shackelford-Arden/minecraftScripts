#!/usr/bin/env bash

# This script downloads and installs MineCraft server.
# Per user input, will also download and install the Forge mod.

# Get Latest versions before installing

./minecraftCommands.sh getVersions


## TODO Add support for other popular distros (Fedora, CentOS, Arch, etc)

## Check User; Exit if not root/sudo
currUser=$EUID
if [[ ! ${currUser} -eq 0 ]];
then
  echo "Please run this script as root."
  exit 20
fi
echo "Set Variables"
## Set variables
mcVersionMohjang=""
versionFileURL=""
javaVersion=""

echo "set installation dir"
### Set Installation Directory
installDir=$1
if [[ -z ${installDir} ]];
then
  installDir="/opt/minecraft/"
fi
### Create Installation directory if it doesn't exist
if [[ -d ${installDir} ]];
then
  echo "Installation directory exists. Continuing..."
else
  mkdir ${installDir}
  if [[ -d $installDir ]];
  then
    echo "Installation directory has been created in ${installDir}."
    echo "Continuing threw script."
  else
    echo "Installation directory could not be created."
    echo "This is likely due to permissions."
    exit 3
  fi
fi

echo "Adding serverInfo.properties files to ${installDir}"
cp ./serverInfo.properties ${installDir}
echo "Adding versions.txt to ${installDir}"
cp ./versions.txt ${installDir}

# Set installation of Forge to true or false
echo "Checking dependencies..."

## Check for Java
### Is Java installed?
echo "Checking for Java..."
checkJava=$(which java &>/dev/null ; echo $?)

if [[ $checkJava -eq 0 ]];
then
  echo "Java is installed... Checking version..."
  javaVersion=$(java -version 2>&1 | grep -oP "openjdk version \"\K\d{1,2}\.\d{1,2}\.\d{1}_\d{1,3}")
  echo "The Java version I found is: ${javaVersion}"

  # Get main version
  mainVersion=$(java -version 2>&1 | grep -oP "openjdk version \"\d{1,2}\.\K\d{1,2}")

  # Provide necessary output or exit depending on version of Java found
  case $mainVersion in
    8)
      echo "You have the current version installed!"
      echo "Hooray! This script will continue"
      ;;
    9)
      echo "You have a newer than recommended version installed."
      echo "Please consider downgrading to 8 as it is the recommended version of Java at this time."
      echo "This script will continue but bear in mind that you are prone to run into issues."
      ;;
    [1-7])
      echo "You need to upgrade to a more recent version of Java."
      echo "Please install at least Java 8 and re-run this script."
      exit 10
      ;;
    *)
      echo "Something went wrong when getting the version of Java installed."
      exit 3
      ;;
  esac
elif [[ $checkJava -eq 1 ]];
then
  echo "Java is not installed. Will attempt to download and install OpenJDK"
  apt install -y openjdk-8-jre-headless tmux
  installJavaCode=$($?)
  if [[ ${installJavaCode} -eq 0 ]];
  then
    echo "OpenJDK 8 JRE has been successfully installed."
  else
    echo "Something went wrong when installing 'openjdk-8-jre-headless'."
    echo "Apt Error Code: ${installJavaCode}"
    echo "Please resolve this error and re-run this script."
    exit 15
  fi
fi
### IF a current installation is found, find current version.
#### IF local version < current version, backup and upgrade.
#### IF local version = current version
## Get latest version of MC Server

versionFileURL="https://launchermeta.mojang.com/mc/game/version_manifest.json"

wget -qN  ${versionFileURL} -O /tmp/mcVersion.json
mcVersionMohjang=$(grep -oP "\"release\":\"\K\d{1,2}\.\d{1,2}\.\d{1,2}" /tmp/mcVersion.json)
wget -N https://s3.amazonaws.com/Minecraft.Download/versions/${mcVersionMohjang}/minecraft_server.${mcVersionMohjang}.jar -O /tmp/minecraft_server.${mcVersionMohjang}.jar

### Copy server.jar to /opt/minecraft
echo "Copy server.jar to /opt/minecraft"

cp  /tmp/minecraft_server.${mcVersionMohjang}.jar $installDir

### Run Server once to generate some needed files
#### Create eula.txt with true value
echo "eula=true" > /opt/minecraft/eula.txt
### Best to use Screen for this part
tmuxSessionName=minecraftServer
tmux new -ds ${tmuxSessionName}
tmux send -t $tmuxSessionName 'cd '$installDir ENTER
tmux send -t $tmuxSessionName 'java -jar ./minecraft_server.'${mcVersionMohjang}'.jar -Xms512M -Xmx512M nogui' ENTER

echo "Wait a moment for the server to fully start."
sleep 60
echo "$(tput setaf 1)Stop server$(tput sgr0)"
tmux send -t ${tmuxSessionName} "/stop" ENTER

## Download & Install MC Forge

### Get latest versions

#### TODO Add option to install latest or recommended.
#### For now we will only install recommended for a more stable experience
echo "Getting MineCraft Forge server files..."
forgeInfoPage="/tmp/mcForgeInfo.html"
wget -qN https://files.minecraftforge.net  -O ${forgeInfoPage}
mcForgeRecommendedVersion=$(grep -Po "<small>\K\d{1,2}\.\d{1,2}\.\d{1,2} - \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,4}" ${forgeInfoPage} | tail -n 1 | sed 's/[[:space:]]//g')

echo "Current Recommended version is: ${mcForgeRecommendedVersion}"
echo "Downloading now..."
### Download recommended version
comboVersion="${mcForgeRecommendedVersion}"
wget -qN http://files.minecraftforge.net/maven/net/minecraftforge/forge/${comboVersion}/forge-${comboVersion}-installer.jar -O ${installDir}forge-${comboVersion}-installer.jar

echo "Installing Forge..."
tmux send -t $tmuxSessionName 'java -Xms512M -Xmx512M -jar '${installDir}'forge-'${comboVersion}'-installer.jar --installServer' ENTER

### Downloading Universal Forge Filegg
wget -qN http://files.minecraftforge.net/maven/net/minecraftforge/forge/${comboVersion}/forge-${comboVersion}-universal.jar -O ${installDir}forge-${comboVersion}-universal.jar

### Run the Forge server once
tmux send -t $tmuxSessionName "java -Xms512M -Xmx512M -jar ${installDir}forge-${comboVersion}-universal.jar nogui"
echo "Wait while Forge runs for the first time."
sleep 60
echo "Turn off server."
tmux send -t ${tmuxSessionName} "/stop" ENTER
echo "Making changes to the server.properties."

### Change Configuration Files
servPropFile=${installDir}server.properties
#### Set level-type to BIOMESOP
sed -i 's/DEFAULT/BIOMESOP/' ${servPropFile}

#### Set Generator Settings

## Using ~ as a sperator due to the large amount of forward slashes in the desired line
sed -i 's/generator-settings\=/generator-settings={"landScheme"\:"vanilla","tempScheme"\:"medium_zones","rainScheme"\:"medium_zones","biomeSize"\:"medium","amplitude"\:1.0,"generateBopOre"\:true,"generateBopSoils"\:true,"generateBopTrees"\:true,"generateBopGrasses"\:true,"generateBopFoliage"\:true,"generateBopFlowers"\:true,"generateBopPlants"\:true,"generateBopWaterPlants"\:true,"generateBopMushrooms"\:true,"generateRockFormations"\:true,"generatePoisonIvy"\:false,"generateFlax"\:true,"generateBerryBushes"\:true,"generateThorns"\:true,"generateQuicksand"\:true,"generateLiquidPoison"\:true,"generateHotSprings"\:true,"generateNetherHives"\:true,"generateNetherPlants"\:true,"generateEndFeatures"\:true}/' ${servPropFile}

#### Set Difficulty
sed -i 's/difficulty=[1,9]/difficulty=3/' ${servPropFile}

### Download Mods

### Cleanup

find $installDir -iname "*-installer.jar" -delete

### Start Server

tmux send -t $tmuxSessionName 'java -Xms1G -Xmx1G -jar '${installDir}'forge-'${comboVersion}'-universal.jar nogui' ENTER
