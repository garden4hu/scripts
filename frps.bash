#! /bin/bash

DownloadUrl=`curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep linux_amd64`

tempDir=/root/frpTemp
if [ ! -d $tempDir ]; then
    mkdir $tempDir
fi
cd $tempDir
tarName=${DownloadUrl##*/}
echo $tarName

if [ ! -e $tarName ]; then
    curl -L  $DownloadUrl
fi

folderName=${tarName%.tar.gz*}
echo $folderName

if [ -d $folderName ]; then
    rm -rf $folderName
fi

tar -zxf $tarName

cd $folderName

echo "source download ok. Installing..."



service=`systemctl | grep frps | awk '{print $1}'`

if [ $service != "" ]; then
    echo "停止已有的frps服务:$service..."
    systemctl stop $service && systemctl disable $service
fi


if [ ! -d "/etc/frp" ]; then
    mkdir /etc/frp
    mv frps.ini /etc/frp/frps.ini
fi

cp -f systemd/frps.service /lib/systemd/system/

cp -f frps /usr/bin/

systemctl enable frps && systemctl start frps

ufw allow 7000:7010/tcp

status=` systemctl list-units --type=service --state=running | grep frps| awk '{print $1}'`
if [ $status != "frps.service" ]; then
    echo "frps 没有运行，请检查log"
    echo "bin path: /usr/bin/frps"
    echo "config path: /etc/frp/frps.ini"
else
    echo "程序正确安装并在运行。结束"
fi
