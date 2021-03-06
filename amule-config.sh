#!/bin/bash

ask_usrkey(){
    echo "GEOLITE2 License Key Sign Up Page: https://www.maxmind.com/en/geolite2/signup "
    echo "Please input Your MAXMIND GEOLITE2 License Key: "
    read -r MAXMINDKEY
    echo "Please set the aMule admin password: "
    read -r PASSWD_AMULECLI
    HASHED_AMULEKEY=$(echo -n "${PASSWD_AMULECLI}" | md5sum | cut -d ' ' -f 1)
}

build_cfg(){
    mkdir -p "${HOME}"/amuledwd
    chmod -R 755 "${HOME}"/amuledwd
    mkdir -p "${HOME}"/.aMule
    mkdir -p "${HOME}"/.aMule/Temp
    mkdir -p "${HOME}"/.aMule/Incoming
    cd "${HOME}"/.aMule
    wget -O nodes.dat "http://kademlia.ru/download/nodes.dat"
    rm "${HOME}"/.aMule/server.met
    wget -O server.met "http://www.server-met.de/dl.php?load=min&trace=43958994.4722"
    cat <<EOF >"${HOME}"/.aMule/amule.conf
[eMule]
AppVersion=2.3.2
Nick=http://www.aMule.org
QueueSizePref=50
MaxUpload=0
MaxDownload=0
SlotAllocation=2
Port=4662
UDPPort=4672
UDPEnable=1
Address=
Autoconnect=1
MaxSourcesPerFile=300
MaxConnections=500
MaxConnectionsPerFiveSeconds=20
RemoveDeadServer=1
DeadServerRetry=3
ServerKeepAliveTimeout=0
Reconnect=1
Scoresystem=1
Serverlist=0
AddServerListFromServer=0
AddServerListFromClient=0
SafeServerConnect=0
AutoConnectStaticOnly=0
UPnPEnabled=0
UPnPTCPPort=50000
SmartIdCheck=1
ConnectToKad=1
ConnectToED2K=1
TempDir=${HOME}/.aMule/Temp
IncomingDir=${HOME}/amuledwd
ICH=1
AICHTrust=0
CheckDiskspace=1
MinFreeDiskSpace=1
AddNewFilesPaused=0
PreviewPrio=0
ManualHighPrio=0
StartNextFile=0
StartNextFileSameCat=0
StartNextFileAlpha=0
FileBufferSizePref=16
DAPPref=1
UAPPref=1
AllocateFullFile=0
OSDirectory=${HOME}/.aMule/
OnlineSignature=0
OnlineSignatureUpdate=5
EnableTrayIcon=0
MinToTray=0
ConfirmExit=1
StartupMinimized=0
3DDepth=10
ToolTipDelay=1
ShowOverhead=0
ShowInfoOnCatTabs=1
VerticalToolbar=0
GeoIPEnabled=1
ShowVersionOnTitle=0
VideoPlayer=
StatGraphsInterval=3
statsInterval=30
DownloadCapacity=300
UploadCapacity=100
StatsAverageMinutes=5
VariousStatisticsMaxValue=100
SeeShare=2
FilterLanIPs=1
ParanoidFiltering=1
IPFilterAutoLoad=1
IPFilterURL=
FilterLevel=127
IPFilterSystem=0
FilterMessages=1
FilterAllMessages=0
MessagesFromFriendsOnly=0
MessageFromValidSourcesOnly=1
FilterWordMessages=0
MessageFilter=
ShowMessagesInLog=1
FilterComments=0
CommentFilter=
ShareHiddenFiles=0
AutoSortDownloads=0
NewVersionCheck=0
AdvancedSpamFilter=1
MessageUseCaptchas=1
Language=
SplitterbarPosition=75
YourHostname=
DateTimeFormat=%A, %x, %X
AllcatType=0
ShowAllNotCats=0
SmartIdState=0
DropSlowSources=0
KadNodesUrl=http://kademlia.ru/download/nodes.dat
Ed2kServersUrl=http://www.server-met.de/dl.php?load=min&trace=43958994.4722
ShowRatesOnTitle=0
GeoLiteCountryUpdateUrl=https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MAXMINDKEY}&suffix=tar.gz
StatsServerName=Shorty's ED2K stats
StatsServerURL=http://ed2k.shortypower.dyndns.org/?hash=
CreateSparseFiles=1
[Browser]
OpenPageInTab=1
CustomBrowserString=
[Proxy]
ProxyEnableProxy=0
ProxyType=0
ProxyName=
ProxyPort=1080
ProxyEnablePassword=0
ProxyUser=
ProxyPassword=
[ExternalConnect]
UseSrcSeeds=0
AcceptExternalConnections=1
ECAddress=
ECPort=4712
ECPassword=${HASHED_AMULEKEY}
UPnPECEnabled=0
ShowProgressBar=1
ShowPercent=1
UseSecIdent=1
IpFilterClients=1
IpFilterServers=1
TransmitOnlyUploadingClients=0
[WebServer]
Enabled=0
Password=
PasswordLow=
Port=4711
WebUPnPTCPPort=50001
UPnPWebServerEnabled=0
UseGzip=1
UseLowRightsUser=0
PageRefreshTime=120
Template=
Path=amuleweb
[GUI]
HideOnClose=0
[Razor_Preferences]
FastED2KLinksHandler=1
[SkinGUIOptions]
Skin=
[Statistics]
MaxClientVersions=0
[Obfuscation]
IsClientCryptLayerSupported=1
IsCryptLayerRequested=1
IsClientCryptLayerRequired=0
CryptoPaddingLenght=254
CryptoKadUDPKey=424903445
[PowerManagement]
PreventSleepWhileDownloading=0
[UserEvents]
[UserEvents/DownloadCompleted]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[UserEvents/NewChatSession]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[UserEvents/OutOfDiskSpace]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[UserEvents/ErrorOnCompletion]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[HTTPDownload]
URL_1=
EOF
}

build_webcfg(){
    echo "Please set a web access password: "
    read -r PASSWD_AMULEWEB
    amuleweb --write-config --password="${PASSWD_AMULECLI}" --admin-pass="${PASSWD_AMULEWEB}"
}

main(){
    ask_usrkey
    build_cfg
    build_webcfg
}

main
