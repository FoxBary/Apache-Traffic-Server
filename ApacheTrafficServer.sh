#!/bin/bash

#=========================#
# 日志记录函数            #
#=========================#
LOG_FILE="/var/log/vmshell_install.log"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

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
    log "用户取消安装"
    exit 0
fi

#=========================#
#    通用信息检测模块     #
#=========================#

# 建议资源要求
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

# 输出系统信息和建议资源
echo "=============================================================="
echo "🧠  当前操作系统: $DISTRO $VERSION"
echo "🖥️   内核版本: $KERNEL"
echo "⚙️   架构: $ARCH"
echo "🔢 CPU 核心数: $CPU_CORES"
echo "🧮 内存总量: ${MEM_TOTAL_MB} MB"
echo "💽 可用磁盘: ${DISK_AVAIL_MB} MB"
echo "📋 建议最低资源: $MIN_CPU CPU 核心, ${MIN_MEM_MB} MB 内存, ${MIN_DISK_MB} MB 磁盘"
echo "=============================================================="
log "系统信息: $DISTRO $VERSION, 内核 $KERNEL, 架构 $ARCH, CPU $CPU_CORES 核, 内存 ${MEM_TOTAL_MB}MB, 磁盘 ${DISK_AVAIL_MB}MB"

#=========================#
# 第一步：整合系统磁盘    #
#=========================#
echo "[INFO] 正在检查并整合系统磁盘..."
log "开始磁盘整合"

if [[ "$DISTRO" == "debian" && "$VERSION" =~ ^(11|12)$ ]]; then
    if [ -b /dev/vda1 ]; then
        log "检测到 Debian $VERSION，执行 resize2fs /dev/vda1"
        resize2fs -f /dev/vda1 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ 磁盘 /dev/vda1 整合成功"
            log "磁盘 /dev/vda1 整合成功"
        else
            echo "❌ 磁盘 /dev/vda1 整合失败，请检查分区状态"
            log "磁盘 /dev/vda1 整合失败"
            exit 1
        fi
    else
        echo "❌ 未找到 /dev/vda1 分区，跳过磁盘整合"
        log "未找到 /dev/vda1 分区"
    fi
elif [[ "$DISTRO" == "ubuntu" && "$VERSION" == "20.04" ]]; then
    if [ -b /dev/vda2 ]; then
        log "检测到 Ubuntu $VERSION，执行 resize2fs /dev/vda2"
        resize2fs -f /dev/vda2 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ 磁盘 /dev/vda2 整合成功"
            log "磁盘 /dev/vda2 整合成功"
        else
            echo "❌ 磁盘 /dev/vda2 整合失败，请检查分区状态"
            log "磁盘 /dev/vda2 整合失败"
            exit 1
        fi
    else
        echo "❌ 未找到 /dev/vda2 分区，跳过磁盘整合"
        log "未找到 /dev/vda2 分区"
    fi
else
    echo "ℹ️ 当前系统无需磁盘整合，跳过此步骤"
    log "无需磁盘整合，跳过"
fi

#=========================#
# 第二步：安装 BBR+FQ     #
#=========================#
echo "[INFO] 正在安装 BBR+FQ..."
log "开始安装 BBR+FQ"

# 下载并执行 BBR 脚本
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh -O bbr.sh >/dev/null 2>&1
if [ $? -eq 0 ]; then
    chmod +x bbr.sh
    log "BBR 脚本下载成功"
else
    echo "❌ 下载 BBR 脚本失败，请检查网络连接"
    log "BBR 脚本下载失败"
    exit 1
fi

# 模拟按键输入以自动执行脚本
echo -e "\n" | ./bbr.sh >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ BBR+FQ 安装成功"
    log "BBR+FQ 安装成功"
else
    echo "❌ BBR+FQ 安装失败，请检查日志 $LOG_FILE"
    log "BBR+FQ 安装失败"
    exit 1
fi

#=========================#
# 第三步：服务器性能检测  #
#=========================#
echo "[INFO] 正在检测服务器配置和性能..."
log "开始服务器性能检测"

# 安装 sysbench（如果未安装）
if ! command -v sysbench >/dev/null; then
    if [[ "$DISTRO" == "debian" || "$DISTRO" == "ubuntu" ]]; then
        apt install -y sysbench >/dev/null 2>&1
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rocky" ]]; then
        yum install -y sysbench >/dev/null 2>&1
    fi
fi

# 收集网络信息
PUBLIC_IP=$(curl -s ifconfig.me)
NET_IFACE=$(ip link | awk -F: '$0 !~ "lo|vir|docker|br-|veth|wg" {print $2; exit}' | xargs)
NET_SPEED=$(ethtool "$NET_IFACE" 2>/dev/null | grep Speed | awk '{print $2}' || echo "未知")

# 测试网络延迟（到 Google DNS）
PING_RESULT=$(ping -c 4 8.8.8.8 | tail -1 | awk '{print $4}' | cut -d '/' -f 2)

# 测试磁盘性能
DISK_WRITE=$(dd if=/dev/zero of=/tmp/testfile bs=1M count=100 conv=fdatasync 2>&1 | grep -o '[0-9.]\+ [MG]B/s' | tail -1)
DISK_READ=$(dd if=/tmp/testfile of=/dev/null bs=1M count=100 2>&1 | grep -o '[0-9.]\+ [MG]B/s' | tail -1)
rm -f /tmp/testfile

# 测试 CPU 和内存性能
if command -v sysbench >/dev/null; then
    CPU_SCORE=$(sysbench cpu --threads=1 run | grep "events per second" | awk '{print $4}')
    MEM_SCORE=$(sysbench memory --memory-block-size=1M --memory-total-size=10G run | grep "MiB transferred" | awk '{print $3}' | tr -d '(')
else
    CPU_SCORE="未安装 sysbench，无法测试"
    MEM_SCORE="未安装 sysbench，无法测试"
fi

# 输出性能报告
echo "=============================================================="
echo "📊 服务器性能检测报告"
echo "=============================================================="
echo "🌐 公网 IP: $PUBLIC_IP"
echo "📡 网络接口: $NET_IFACE (速度: $NET_SPEED)"
echo "⏱️  到 8.8.8.8 延迟: ${PING_RESULT:-未知} ms"
echo "💾 磁盘写入速度: ${DISK_WRITE:-未知}"
echo "💿 磁盘读取速度: ${DISK_READ:-未知}"
echo "🧠 CPU 性能: ${CPU_SCORE:-未知} events/sec"
echo "🧮 内存性能: ${MEM_SCORE:-未知} MiB/sec"
echo "=============================================================="
log "性能检测完成: IP=$PUBLIC_IP, 延迟=${PING_RESULT:-未知}ms, 磁盘写=$DISK_WRITE, 磁盘读=$DISK_READ, CPU=$CPU_SCORE, 内存=$MEM_SCORE"

#=========================#
# 安装依赖（分发版判断）  #
#=========================#
echo "[INFO] 正在安装依赖项..."
log "开始安装依赖"

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
        brotli-devel xz-devel libyaml-devel tcl-dev wget curl unzip vim \
        git screen zip gnupg file socat bind-utils docker-compose golang nodejs npm
    elif [ "$DISTRO" = "freebsd" ]; then
        pkg install -y gcc gmake autoconf automake libtool cmake pkgconf pcre \
        pcre2 openssl curl lua51 zlib brotli bash node npm go
    else
        echo "❌ 暂不支持该系统的依赖自动安装，请手动安装依赖。"
        log "不支持的系统，依赖安装失败"
        exit 1
    fi
}

install_deps_linux || { log "依赖安装失败"; exit 1; }

#=========================#
# 下载 + 编译 + 安装 ATS  #
#=========================#
echo "[INFO] 开始下载并编译安装 Apache Traffic Server..."
log "开始安装 ATS"
cd /usr/local/src || { log "无法进入 /usr/local/src"; exit 1; }
wget https://downloads.apache.org/trafficserver/trafficserver-10.0.0.tar.bz2 || { log "ATS 下载失败"; exit 1; }
tar -xjf trafficserver-10.0.0.tar.bz2
cd trafficserver-10.0.0 || { log "无法进入 ATS 目录"; exit 1; }

cmake -B build -DCMAKE_BUILD_TYPE=Release || { log "ATS cmake 配置失败"; exit 1; }
cmake --build build || { log "ATS 编译失败"; exit 1; }
cmake --install build || { log "ATS 安装失败"; exit 1; }

# 启动 ATS
/usr/local/bin/trafficserver start
log "ATS 启动成功"

# 添加 systemd 启动服务
if [[ "$OS_NAME" == "Linux" && -d /etc/systemd/system ]]; then
    echo "[INFO] 添加 systemd 启动服务..."
    log "添加 ATS systemd 服务"
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
    log "ATS systemd 服务配置成功"
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
echo "▶ 核心地区：香港 막 国移动CMI线路、美国圣何塞国际带宽"
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
echo "Email2：admin@vmshell.com"
echo ""
echo "💡 感谢您使用 VMSHELL 一键安装脚本！我们 24 小时为您服务。"
echo "=============================================================="
log "安装完成，脚本执行成功"
