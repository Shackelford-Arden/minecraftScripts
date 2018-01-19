#!/usr/bin/env bash

## Compile all existing functionality into once script that uses functions
echo "opening minecraftCommands.sh"
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
echo "current param is $key";
case $key in
    -n|--servername|--name)
    serverName="$2"
    minecraftServer="$serverName"
    installDir="/opt/minecraft/$serverName"
    shift # past argument
    shift # past value
    ;;
    -v|--mcversion)
    vanillaVersion="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--forgeversion)
    forgeVersion="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--backupdir)
    backupDir="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--servertype)
    serverType="$2"
    shift # past argument
    shift # past value
    ;;
    --xms|-xms)
    Xms="$2"
    shift # past argument
    shift # past value
    ;;
    --xmx|-xmx)
    Xmx="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
# if [[ -n $1 ]]; then
#     echo "Last line of file specified as non-opt/last argument:"
#     tail -1 "$1"
# fi







action=$1
serverProperties="./serverInfo.properties"
# serverVersions="./versions.txt"
if [ -z "$minecraftServer"]; then minecraftServer="minecraftServer";                                    fi
if [ -z "$installDir"     ]; then installDir=$(grep -oP "installDir=\K.*" ${serverProperties});         fi
if [ -z "$Xms"            ]; then Xms=$(grep -oP "minMem=\K.*" ${serverProperties});                    fi
if [ -z "$Xmx"            ]; then Xmx=$(grep -oP "maxMem=\K.*" ${serverProperties});                    fi
if [ -z "$vanillaVersion" ]; then vanillaVersion=$(grep -oP "vanillaVersion=\K.*" ${serverProperties}); fi
if [ -z "$forgeVersion"   ]; then forgeVersion=$(grep -oP "forgeVersion=\K.*" ${serverProperties});     fi
if [ -z "$backupDir"      ]; then backupDir=$(grep -oP "backupDir=\K.*" ${serverProperties});           fi
if [ -z "$serverType"     ]; then serverType="forge";           fi

# if versions aren't supplied in CLA or serverProperties, get reccomended versions.
if [ -z "$vanillaVersion" ]; then vanillaVersion=getReccomendedVanilla; fi
if [ -z "$forgeVersion"   ]; then forgeVersion=getReccomendedForge;     fi
if [ -z "$installDir"     ]; then installDir="/opt/minecraft/$minecraftServer";   fi
if [ -z "$Xms"            ]; then Xms=1G;                               fi
if [ -z "$Xmx"            ]; then Xmx=1G;                               fi
# Start MC Server



echo "Show values for each of these"
echo "............................."
echo "minecraftServer:  $minecraftServer"
echo "installDir:       $installDir"
echo "Xms:              $Xms"
echo "Xmx:              $Xmx"
echo "vanillaVersion:   $vanillaVersion"
echo "forgeVersion:     $forgeVersion"
echo "backupDir:        $backupDir"
echo "serverType:       $serverType"
echo "Action:           $action"






backupServer() {

  # Check for Backup Dir
  if [[ -d ${backupDir} ]]; then
    echo "Backup directory exists. Continuing to backup."
  else
    echo "Backup dir doesn't exist. Creating..."
    mkdir ${backupDir}
    if [[ -d ${backupDir} ]]; then
      echo "Backup dir created. Moving on to backup..."
    else
      echo "Backup dir not created. Please check permissions for creating ${backupDir}"
      echo "Then re-run the backup."
      exit 4
    fi
  fi

  ######################
  # Backup Naming
  ######################
  # TODO Add functionality to backup per World
  echo "Set variable for backup name."
  # Create a variable that will use today's date.
  # Format: Year-Month-Day-Hour-Minute
  backupTimeStamp=$(date '+%Y-%m-%d-%H-%M')

  echo "We'll move into the backup directory then create the backup"
  tmux send -t minecraftServer 'cd '${backupDir} ENTER

  echo "Creating compressed tar of server..."
  tmux send -t minecraftServer 'tar -czvf '${backupTimeStamp}'minecraft.tar '${installDir} ENTER
  echo "And we'll wait for the tar to be created - 5 Minutes"
  # This ensures no other commands are thrown at the server during the backup
  sleep 300
  completeBackup=$(ls -t /home/ubuntu/minecraftBackups | head -n1)

  echo "Backup name = $completeBackup"
  echo "Backup Complete!"
}
getReccomendedVanilla(){
  # TODO: use version_manifest.json
          # versionFileURL="https://launchermeta.mojang.com/mc/game/version_manifest.json"

          # wget -qN ${versionFileURL} -O /tmp/mcVersion.json
          # mcVersionMohjang=$(grep -oP "\"release\":\"\K\d{1,2}\.\d{1,2}\.\d{1,2}" /tmp/mcVersion.json)
          # wget -N https://s3.amazonaws.com/Minecraft.Download/versions/${mcVersionMohjang}/minecraft_server.${mcVersionMohjang}.jar -O /tmp/minecraft_server.${mcVersionMohjang}.jar

  # Check Vanilla Server Version
  vanillaManifest="https://launchermeta.mojang.com/mc/game/version_manifest.json"
  wget -qN ${vanillaManifest} -O /tmp/vanillaMCVersion.json
  localVanillaVersion=$(grep -oP "\"release\":\"\K\d{1,2}\.\d{1,2}\.\d{1,2}" /tmp/vanillaMCVersion.json)
  # Add version to serverInfo.properties
  # sed -i "s/(vanillaVersion=).*/${localVanillaVersion}/" ${serverVersions}
  # echo "Vanilla Version: ${localVanillaVersion}"
  # echo "Vanilla Versions: ${serverVersions}"
  return "$localVanillaVersion";
}
getReccomendedForge(){
  # Check Forge Version
  echo "Getting MineCraft Forge server files..."
  forgeManifest="/tmp/forgeManifest.html"
  wget -qN https://files.minecraftforge.net -O ${forgeManifest}
  echo "Find Reccomended version"
  # Find Recommended Version
  localrecommendedForge=$(grep -A1 "Download Recommended" ${forgeManifest} | grep -oP "<small>\K\d{1,2}\.\d{1,2}\.\d{1,2} - \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,4}" | sed 's/[[:space:]]//g')
  return "$localrecommendedForge";
}
getLatestVersions() {

  # Check Vanilla Server Version
  vanillaManifest="https://launchermeta.mojang.com/mc/game/version_manifest.json"
  wget -qN ${vanillaManifest} -O /tmp/vanillaMCVersion.json
  localVanillaVersion=$(grep -oP "\"release\":\"\K\d{1,2}\.\d{1,2}\.\d{1,2}" /tmp/vanillaMCVersion.json)
  # Add version to serverInfo.properties
  sed -i "s/(vanillaVersion=).*/${localVanillaVersion}/" ${serverVersions}
  echo "Vanilla Version: ${localVanillaVersion}"
  echo "Vanilla Versions: ${serverVersions}"

  # Check Forge Version

  echo "Getting MineCraft Forge server files..."
  forgeManifest="/tmp/forgeManifest.html"
  wget -qN https://files.minecraftforge.net -O ${forgeManifest}

  echo "Find Reccomended version"
  # Find Recommended Version
  recommendedForge=$(grep -A1 "Download Recommended" ${forgeManifest} | grep -oP "<small>\K\d{1,2}\.\d{1,2}\.\d{1,2} - \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,4}" | sed 's/[[:space:]]//g')

  ## Set Recommended Version in versions.txt
  sed -i "s/(recommendedForge=).*/${recommendedForge}/" ${serverVersions}

  echo "Find Latest version"
  # Find Latest Version
  latestForge=$(grep -A1 "Download Latest" ${forgeManifest} | grep -oP "<small>\K\d{1,2}\.\d{1,2}\.\d{1,2} - \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,4}" | sed 's/[[:space:]]//g')

  ## Set Latest Version in versions.txt
  sed -i "s/(latestForge=).*/${latestForge}/" ${serverVersions}
  echo "End get latest version"
}
startServer() {
  echo "starting 'startServer()'"
  # Let's start the Server
  tmux new -ds $minecraftServer
  tmux send -t $minecraftServer 'cd '${installDir} ENTER
  echo "Starting ${serverType} server..."
  case $serverType in
  "vanilla")
    echo "Inside vanilla exeution"
    echo "starting ${installDir}minecraft_server.${vanillaVersion}.jar."
    if [[ -f ${installDir}minecraft_server.${vanillaVersion}.jar ]]; then
      # tmux send -t $minecraftServer 'java -Xms'${Xms}' -Xms'${Xmx}' -jar '${installDir}'minecraft_server.*.jar nogui' ENTER
      tmux send -t $minecraftServer 'java -Xms'${Xms}' -Xms'${Xmx}' -jar '${installDir}'minecraft_server.'${vanillaVersion}'.jar nogui' ENTER
    else
      echo "Failed to start server; ${installDir}minecraft_server.${vanillaVersion}.jar could not be found."
      echo "Please look into this and try again."
      exit 1
    fi
    ;;
  "forge")
    echo "Inside forge exeution"
    echo "Starting ${installDir}forge-${forgeVersion}-universal.jar."
    if [[ -f "${installDir}forge-${forgeVersion}-universal.jar" ]]; then
      # tmux send -t minecraftServer 'java -Xms'${Xms}' -Xms'${Xmx}' -jar '${installDir}'forge-*-universal.jar nogui' ENTER
      tmux send -t $minecraftServer 'java -Xms'${Xms}' -Xms'${Xmx}' -jar '${installDir}'forge-'${forgeVersion}'-universal.jar nogui' ENTER
    else
      echo "Failed to start server; ${installDir}forge-${forgeVersion}-universal.jar could not be found."
      echo "Please look into this and try again."
      exit 1
    fi
    ;;
  *)
    echo "Provided server type not recognized."
    echo "Usage: minecraftCommands.sh vanilla|forge"
    ;;
  esac
  echo "Ending startServer() function"
}
stopServer() {
  tmux send -t $minecraftServer '/stop' ENTER
}
installServer() {
  ## TODO Add support for other popular distros (Fedora, CentOS, Arch, etc)
  ## Check User; Exit if not root/sudo
  currUser=$EUID
  if [[ ! ${currUser} -eq 0 ]]; then
    echo "Please run this script as root."
    exit 20
  fi
  echo "Set Variables"
  ## Set variables
  mcVersionMohjang=""
  versionFileURL=""
  javaVersion=""

  echo "set installation dir"
  ### Set Installation Directory to default if not found in serverProperties
  if [[ -z ${installDir} ]]; then
    echo "Setting installDir to default /opt/<serverName>/"
    installDir="/opt/$serverName/"
  fi
  ### Create Installation directory if it doesn't exist
  if [[ -d ${installDir} ]]; then
    echo "Installation directory exists. Continuing..."
  else
    mkdir ${installDir}
    if [[ -d $installDir ]]; then
      echo "Installation directory has been created in ${installDir}."
      echo "Continuing through script."
    else
      echo "Installation directory could not be created."
      echo "This is likely due to permissions."
      exit 3
    fi
  fi

  # echo "Adding serverInfo.properties files to ${installDir}"
  # cp ./serverInfo.properties ${installDir}
  # echo "Adding versions.txt to ${installDir}"
  # cp ./versions.txt ${installDir}

  # Set installation of Forge to true or false
  echo "Checking dependencies..."

  ## Check for Java
  ### Is Java installed?
  echo "Checking for Java..."
  checkJava=$(
    which java &>/dev/null
    echo $?
  )

  if [[ $checkJava -eq 0 ]]; then
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
  elif [[ $checkJava -eq 1 ]]; then
    echo "Java is not installed. Will attempt to download and install OpenJDK"
    apt install -y openjdk-8-jre-headless tmux
    installJavaCode=$($?)
    if [[ ${installJavaCode} -eq 0 ]]; then
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

  # versionFileURL="https://launchermeta.mojang.com/mc/game/version_manifest.json"

  # wget -qN ${versionFileURL} -O /tmp/mcVersion.json
  # mcVersionMohjang=$(grep -oP "\"release\":\"\K\d{1,2}\.\d{1,2}\.\d{1,2}" /tmp/mcVersion.json)
  wget -N https://s3.amazonaws.com/Minecraft.Download/versions/${vanillaVersion}/minecraft_server.${vanillaVersion}.jar -O /tmp/minecraft_server.${vanillaVersion}.jar

  ### Copy server.jar to /opt/minecraft
  echo "Copy server.jar to /opt/minecraft"

  cp /tmp/minecraft_server.${vanillaVersion}.jar $installDir

  ### Run Server once to generate some needed files
  #### Create eula.txt with true value
  echo "eula=true" > "$installDir/eula.txt"
  ### Best to use Screen for this part
  tmuxSessionName=$minecraftServer
  tmux new -ds ${tmuxSessionName}
  tmux send -t $tmuxSessionName 'cd '$installDir ENTER
  tmux send -t $tmuxSessionName 'java -jar ./minecraft_server.'${mcVersionMohjang}'.jar -Xms512M -Xmx512M nogui' ENTER

  echo "Wait a moment for the server to fully start."
  sleep 60
  echo "$(tput setaf 1)Stop server$(tput sgr0)"
  tmux send -t ${tmuxSessionName} "/stop" ENTER
  if [[ "${serverType}" == "forge" ]]; then
    ## Download & Install MC Forge

    ### Get latest versions

    #### TODO: Add option to install latest or recommended.
    #### For now we will only install recommended for a more stable experience
    echo "Getting MineCraft Forge server files..."
            # forgeInfoPage="/tmp/mcForgeInfo.html"
            # wget -qN https://files.minecraftforge.net -O ${forgeInfoPage}
            # mcForgeRecommendedVersion=$(grep -Po "<small>\K\d{1,2}\.\d{1,2}\.\d{1,2} - \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,4}" ${forgeInfoPage} | tail -n 1 | sed 's/[[:space:]]//g')

    # echo "Current Recommended version is: ${latestForge}"
    echo "Current Recommended version is: ${forgeVersion}"
    echo "Downloading now..."
    ### Download recommended version
    # comboVersion="${latestForge}"
    comboVersion="${forgeVersion}"
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
    echo "End Forge Installation"
  fi

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
  # tmux send -t $tmuxSessionName 'java -Xms1G -Xmx1G -jar '${installDir}'forge-'${comboVersion}'-universal.jar nogui' ENTER

  ### end session
  echo "about to kill tmux"
  tmux kill-session -t $tmuxSessionName
  echo "killed tmux"
}
removeMinecraft() {
  if [[ -d ${installDir} ]]; then
    echo "An installation exists."
    echo "Removing..."
    rm -rf ${installDir}
    echo "Cleanup /tmp..."
    rm /tmp/mcVersion.json
    find /tmp -iname "*forge*.jar" -delete
    find /tmp -iname "*minecraft*.jar" -delete
    rm /tmp/mcVersion.json
    echo "installation Removed"
  else
    echo "${installDir} Doesn't exist. Nothing to remove."
    echo "Nothing else to see here... move along..."
  fi
}
usage() {
  echo "minecraftCommands.sh startServer | stopServer | backupServer | installVanilla | install | installForge | getVersions | cleanupScript | uninstall | remove"
}

case $action in
"startServer")
  # getLatestVersions
  # serverType="forge"
  startServer
  ;;
"stopServer")
  stopServer
  ;;
"backupServer")
  # getLatestVersions
  backupServer
  ;;
"installVanilla")
  # getLatestVersions
  serverType="vanilla"
  installServer
  ;;
"install" | "installForge")
  # getLatestVersions
  # serverType="forge"
  installServer
  ;;
"getVersions")
  getLatestVersions
  ;;
"cleanupScript" | "uninstall" | "remove")
  removeMinecraft
  ;;
*)
  echo "Action ($action) not recognized."
  usage
  ;;
esac
