#!/bin/bash

#=========================#
# 安装确认提示           #
#=========================#
echo "=============================================================="
echo "      欢迎使用 VMSHELL 提供的全球 CDN 一键安装脚本"
echo "     本脚本将为您安装 Apache Traffic Server 10.0.0"
echo "=============================================================="
read -p "是否继续安装？请输入 y 继续，n 退出 [y/n]: " confirm

if [[ "$confirm" != "y" ]]; then
    echo "已取消安装。感谢您使用 VMSHELL 脚本！"
    exit 0
fi

#=========================#
#    通用信息检测模块     #
#=========================#

# 最低资源要求
MIN_CPU=2
MIN_MEM_MB=2048
MIN_DISK_MB=2048

# 获取系统信息
OS_NAME=$(uname -s)
KERNEL=$(uname -r)
ARCH=$(uname -m)

# 检测 Linux 发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
elif [ "$(uname -s)" == "FreeBSD" ]; then
    DISTRO="freebsd"
    VERSION=$(freebsd-version)
else
    DISTRO="unknown"
    VERSION="unknown"
fi

# 获取资源信息
CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
MEM_TOTAL_MB=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}')
if [[ -z "$MEM_TOTAL_MB" ]]; then
    MEM_TOTAL_MB=$(sysctl -n hw.physmem | awk '{printf "%.0f", $1 / 1024 / 1024}')
fi
DISK_AVAIL_MB=$(df / | tail -1 | awk '{print int($4 / 1024)}')

# 输出系统信息
echo "=============================================================="
echo "🧠  当前操作系统: $DISTRO $VERSION"
echo "🖥️   内核版本: $KERNEL"
echo "⚙️   架构: $ARCH"
echo "🔢 CPU 核心数: $CPU_CORES"
echo "🧮 内存总量: ${MEM_TOTAL_MB} MB"
echo "💽 可用磁盘: ${DISK_AVAIL_MB} MB"
echo "=============================================================="

# 判断是否满足要求
if [[ $CPU_CORES -lt $MIN_CPU || $MEM_TOTAL_MB -lt $MIN_MEM_MB || $DISK_AVAIL_MB -lt $MIN_DISK_MB ]]; then
    echo "❌ 当前系统资源不足！建议至少：$MIN_CPU CPU，${MIN_MEM_MB}MB 内存，${MIN_DISK_MB}MB 磁盘。"
    echo "请升级服务器配置后重试。"
    exit 1
fi

read -p "✅ 资源足够，是否继续安装 Apache Traffic Server？(y/n): " confirm2
if [[ "$confirm2" != "y" ]]; then
    echo "已取消安装，感谢使用 VMSHELL 脚本！"
    exit 0
fi

#=========================#
# 安装依赖（分发版判断）  #
#=========================#
echo "[INFO] 正在安装依赖项..."

install_deps_linux() {
    if command -v apt >/dev/null; then
        apt update && apt -y upgrade
        apt -y install build-essential autoconf automake libtool pkg-config libssl-dev \
        libpcre2-dev libcap-dev libhwloc-dev libncurses5-dev libcurl4-openssl-dev \
        libexpat1-dev libsqlite3-dev zlib1g-dev libluajit-5.1-dev libunwind-dev \
        libbrotli-dev liblzma-dev libyaml-dev tcl-dev wget curl unzip vim xz-utils \
        git screen zip gnupg file libpcre3-dev socat dnsutils docker-compose \
        gcc g++ make cmake golang-go nodejs npm
    elif command -v yum >/dev/null; then
        yum install -y epel-release
        yum groupinstall -y "Development Tools"
        yum install -y gcc gcc-c++ make cmake autoconf automake libtool openssl-devel \
        pcre-devel pcre2-devel libcap-devel hwloc-devel ncurses-devel libcurl-devel \
        expat-devel sqlite-devel zlib-devel luajit-devel libunwind-devel \
        brotli-devel xz-devel libyaml-devel tcl-devel wget curl unzip vim \
        git screen zip gnupg file socat bind-utils docker-compose golang nodejs npm
    elif [ "$DISTRO" = "freebsd" ]; then
        pkg install -y gcc gmake autoconf automake libtool cmake pkgconf pcre \
        pcre2 openssl curl lua51 zlib brotli bash node npm go
    else
        echo "❌ 暂不支持该系统的依赖自动安装，请手动安装依赖。"
        exit 1
    fi
}

install_deps_linux || exit 1

#=========================#
# 下载 + 编译 + 安装 ATS  #
#=========================#
echo "[INFO] 开始下载并编译安装 Apache Traffic Server..."
cd /usr/local/src || exit 1
wget https://downloads.apache.org/trafficserver/trafficserver-10.0.0.tar.bz2 || exit 1
tar -xjf trafficserver-10.0.0.tar.bz2
cd trafficserver-10.0.0 || exit 1

cmake -B build -DCMAKE_BUILD_TYPE=Release || exit 1
cmake --build build || exit 1
cmake --install build || exit 1

# 启动 ATS
/usr/local/bin/trafficserver start

# 添加 systemd 启动服务
if [[ "$OS_NAME" == "Linux" && -d /etc/systemd/system ]]; then
    echo "[INFO] 添加 systemd 启动服务..."
    cat >/etc/systemd/system/trafficserver.service <<EOF
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
EOF

    systemctl daemon-reload
    systemctl enable trafficserver
    systemctl start trafficserver
fi

#=========================#
# 安装成功 & 广告输出     #
#=========================#
clear
echo "=============================================================="
echo "🎉 Apache Traffic Server 安装成功！"
echo "=============================================================="
echo "关于 VmShell"
echo "VMSHELL INC 是一家成立于2021年的美国云计算服务公司，总部位于怀俄明州谢里丹，专注于提供全球数据中心的虚拟机服务器租赁和软件开发服务。"
echo "公司旗下品牌包括 VmShell 和 ToToTel，业务覆盖亚洲、美洲和欧洲，致力于为企业提供高效、稳定的网络解决方案。"
echo ""
echo "▶ 主打服务：VPS、独立服务器、云端管理平台"
echo "▶ 核心地区：香港中国移动CMI线路、美国圣何塞国际带宽"
echo "▶ 支持：流媒体解锁（Netflix、TikTok）、SSH管理、云端脚本运维"
echo "▶ 支付方式：PayPal、支付宝、比特币、USDT 等"
echo ""
echo "📡 测试节点 IP:"
echo "英国：    89.34.97.34"
echo "日本：    94.177.17.66"
echo "香港：    103.225.199.99"
echo "美国：    23.173.216.107"
echo "澳门：    163.53.246.77"
echo ""
echo "📞 联系方式："
echo "官方网站：https://vmshell.com/    | https://tototel.com"
echo "Telegram 讨论：https://t.me/vmsus"
echo "电话支持：+1 (469) 278-6367"
echo "Email1：admin@vmshell.com"
echo "Email2：vmshell.inc@gmail.com"
echo ""
echo "💡 感谢您使用 VMSHELL 一键安装脚本！我们 24 小时为您服务。"
echo "=============================================================="
