关于VmShell:
VMSHELL INC 是一家成立于2021年的美国云计算服务公司，总部位于怀俄明州谢里丹，专注于提供全球数据中心的虚拟机服务器租赁和软件开发服务。公司旗下品牌包括 VmShell 和 ToToTel，业务覆盖亚洲和美洲以及欧洲，致力于为企业提供高效、稳定的网络解决方案。其核心服务包括虚拟私有服务器（VPS）、独立服务器以及云端管理平台，广泛应用于企业业务拓展、流媒体优化和跨境电商等领域。
公司主打香港和美国圣何塞两大核心数据中心。香港数据中心采用中国移动CMI高速网络，支持三网优化，提供亚洲香港CMI三网大陆优化1Gbps和美国10Gbps的国际带宽，特别适合面向中国大陆及东南亚市场的用户；香港数据中心和美国圣何塞数据中心，我们都提供了香港IP和美国的IP供用户选择，支持流媒体解锁（如TikTok、Netflix等），满足电信和联通用户的优化需求。
VMSHELL INC 以用户体验为核心，提供24/7技术支持，承诺99.99%的服务器在线率，并支持PayPal、支付宝、比特币等多种支付方式，方便全球用户。公司还开发了移动端管理应用，支持服务器运行监控、SSH管理和Linux运维脚本，极大提升了用户管理效率。凭借可靠的网络性能和灵活的服务模式，VMSHELL INC 已成长为云计算领域值得信赖的品牌，未来计划持续优化技术社区功能，扩展更多创新服务。
VmShell官方网站：https://vmshell.com/  TOTOTEL官方网站: https://tototel.com
随时为您提供支持
24 小时 Telegram 在线服务：https://t.me/vmsus
24 小时电话支持：+1(469)278-6367
紧急电子邮件支持：
电子邮件一：admin@vmshell.com
电子邮件二：vmshell.inc@gmail.com
CDN网络测试,VMSHELL所有测试IP
英国数据中心：89.34.97.34
日本数据中心：94.177.17.66
香港数据中心：103.225.199.99
美国数据中心：23.173.216.107
澳门数据中心：163.53.246.77



第一步:安装整个依赖库:
apt update && apt -y upgrade && apt -y install build-essential autoconf automake libtool pkg-config libssl-dev libpcre2-dev libcap-dev libhwloc-dev libncurses5-dev libcurl4-openssl-dev libexpat1-dev libsqlite3-dev zlib1g-dev libluajit-5.1-dev libunwind-dev libbrotli-dev liblzma-dev libyaml-dev tcl-dev wget curl unzip vim xz-utils git screen zip gnupg file libpcre3-dev socat dnsutils docker-compose gcc g++ make cmake golang-go nodejs npm
第二步: 根据官方 CMake 教程手动构建与安装 Apache Traffic Server 的详细步骤（Ubuntu 专用）,你已经安装完依赖，以下是构建并安装 Traffic Server 的全部步骤：下载源码
cd /usr/local/src && wget https://downloads.apache.org/trafficserver/trafficserver-10.0.0.tar.bz2 && tar -xjf trafficserver-10.0.0.tar.bz2 && cd trafficserver-10.0.0 && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build
第三步:安装到系统
cmake --install build
第四步:验证安装成功
/usr/local/bin/traffic_server -V
第五步:启动 Apache Traffic Server
/usr/local/bin/trafficserver start
第六步:添加 systemd 启动服务（trafficserver.service）
创建服务文件：nano /etc/systemd/system/trafficserver.service
填入以下内容(默认安装在 /usr/local/trafficserver):
[Unit]
Description=Apache Traffic Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/trafficserver start
ExecStop=/usr/local/bin/trafficserver stop
ExecReload=/usr/local/bin/traffic_ctl config reload
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
启用并启动服务：
systemctl daemon-reload
systemctl enable trafficserver
systemctl start trafficserver
查看状态：
systemctl status trafficserver

