#!/bin/bash

#=========================#
# 日志记录函数            #
#=========================#
LOG_FILE="/var/log/vmshell_install.log"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

#=========================#
# 环境检查和初始化        #
#=========================#
# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
    echo "❌ 错误：本脚本需要 root 权限运行，请使用 sudo 或以 root 身份执行！"
    log "非 root 权限运行，退出"
    exit 1
fi

# 检查网络连接
check_network() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ 错误：无法连接到网络，请检查网络设置后重试！"
        log "网络连接失败，退出"
        exit 1
    fi
}

# 检测语言环境
if [[ "$LANG" =~ "zh_CN" ]]; then
    LANG="zh"
else
    LANG="en"
fi

# 多语言提示
prompt() {
    if [ "$LANG" = "zh" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}

#=========================#
# 安装确认提示           #
#=========================#
prompt "==============================================================" "=============================================================="
prompt "      欢迎使用 VMSHELL 提供的全球 CDN 一键安装脚本" "      Welcome to VMSHELL's Global CDN One-Click Installation Script"
prompt "     本脚本将为您安装 Apache Traffic Server 10.0.0" "     This script will install Apache Traffic Server 10.0.0"
prompt "==============================================================" "=============================================================="
prompt "是否继续安装？请输入 y 继续，n 退出 [y/n]: " "Continue installation? Enter y to proceed, n to exit [y/n]: "
read -p "" confirm

if [[ "$confirm" != "y" ]]; then
    prompt "已取消安装。感谢您使用 VMSHELL 脚本！" "Installation canceled. Thank you for using VMSHELL script!"
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
prompt "==============================================================" "=============================================================="
prompt "🧠  当前操作系统: $DISTRO $VERSION" "🧠  Current OS: $DISTRO $VERSION"
prompt "🖥️   内核版本: $KERNEL" "🖥️   Kernel version: $KERNEL"
prompt "⚙️   架构: $ARCH" "⚙️   Architecture: $ARCH"
prompt "🔢 CPU 核心数: $CPU_CORES" "🔢 CPU cores: $CPU_CORES"
prompt "🧮 内存总量: ${MEM_TOTAL_MB} MB" "🧮 Total memory: ${MEM_TOTAL_MB} MB"
prompt "💽 可用磁盘: ${DISK_AVAIL_MB} MB" "💽 Available disk: ${DISK_AVAIL_MB} MB"
prompt "📋 建议最低资源: $MIN_CPU CPU 核心, ${MIN_MEM_MB} MB 内存, ${MIN_DISK_MB} MB 磁盘" "📋 Recommended minimum resources: $MIN_CPU CPU cores, ${MIN_MEM_MB} MB memory, ${MIN_DISK_MB} MB disk"
prompt "==============================================================" "=============================================================="
log "系统信息: $DISTRO $VERSION, 内核 $KERNEL, 架构 $ARCH, CPU $CPU_CORES 核, 内存 ${MEM_TOTAL_MB}MB, 磁盘 ${DISK_AVAIL_MB}MB"

#=========================#
# 第一步：整合系统磁盘    #
#=========================#
prompt "[INFO] 正在检查并整合系统磁盘..." "[INFO] Checking and resizing system disk..."
log "开始磁盘整合"

if [[ "$DISTRO" == "debian" && "$VERSION" =~ ^(11|12)$ ]]; then
    if [ -b /dev/vda1 ]; then
        log "检测到 Debian $VERSION，执行 resize2fs /dev/vda1"
        resize2fs -f /dev/vda1 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            prompt "✅ 磁盘 /dev/vda1 整合成功" "✅ Disk /dev/vda1 resized successfully"
            log "磁盘 /dev/vda1 整合成功"
        else
            prompt "❌ 磁盘 /dev/vda1 整合失败，请检查分区状态" "❌ Failed to resize /dev/vda1, please check partition status"
            log "磁盘 /dev/vda1 整合失败"
            exit 1
        fi
    else
        prompt "❌ 未找到 /dev/vda1 分区，跳过磁盘整合" "❌ /dev/vda1 partition not found, skipping disk resize"
        log "未找到 /dev/vda1 分区"
    fi
elif [[ "$DISTRO" == "ubuntu" && "$VERSION" == "20.04" ]]; then
    if [ -b /dev/vda2 ]; then
        log "检测到 Ubuntu $VERSION，执行 resize2fs /dev/vda2"
        resize2fs -f /dev/vda2 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            prompt "✅ 磁盘 /dev/vda2 整合成功" "✅ Disk /dev/vda2 resized successfully"
            log "磁盘 /dev/vda2 整合成功"
        else
            prompt "❌ 磁盘 /dev/vda2 整合失败，请检查分区状态" "❌ Failed to resize /dev/vda2, please check partition status"
            log "磁盘 /dev/vda2 整合失败"
            exit 1
        fi
    else
        prompt "❌ 未找到 /dev/vda2 分区，跳过磁盘整合" "❌ /dev/vda2 partition not found, skipping disk resize"
        log "未找到 /dev/vda2 分区"
    fi
else
    prompt "ℹ️ 当前系统无需磁盘整合，跳过此步骤" "ℹ️ Current system does not require disk resize, skipping"
    log "无需磁盘整合，跳过"
fi

#=========================#
# 第二步：安装 BBR+FQ     #
#=========================#
prompt "[INFO] 准备安装 BBR+FQ..." "[INFO] Preparing to install BBR+FQ..."
prompt "请按任意键启动 BBR+FQ 协议后继续" "Press any key to start BBR+FQ protocol and continue"
read -n 1 -s
log "开始安装 BBR+FQ"

# 备份 sysctl.conf
if [ -f /etc/sysctl.conf ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.bak."$(date +%F_%H-%M-%S)"
    log "已备份 /etc/sysctl.conf"
fi

# 下载 BBR 脚本（带重试机制）
check_network
for ((i=1; i<=3; i++)); do
    wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh -O bbr.sh >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        chmod +x bbr.sh
        log "BBR 脚本下载成功"
        break
    elif [ $i -eq 3 ]; then
        prompt "❌ 下载 BBR 脚本失败，请检查网络连接" "❌ Failed to download BBR script, please check network"
        log "BBR 脚本下载失败"
        exit 1
    fi
    sleep 2
done

# 执行 BBR 脚本
echo -e "\n" | ./bbr.sh >/dev/null 2>&1
if [ $? -eq 0 ]; then
    prompt "✅ BBR+FQ 安装成功" "✅ BBR+FQ installed successfully"
    log "BBR+FQ 安装成功"
else
    prompt "❌ BBR+FQ 安装失败，请检查日志 $LOG_FILE" "❌ BBR+FQ installation failed, check log at $LOG_FILE"
    log "BBR+FQ 安装失败"
    exit 1
fi

#=========================#
# 第三步：服务器性能检测  #
#=========================#
prompt "[INFO] 正在检测服务器配置和性能..." "[INFO] Detecting server configuration and performance..."
log "开始服务器性能检测"

# 安装 sysbench（如果未安装）
if ! command -v sysbench >/dev/null; then
    prompt "正在安装 sysbench..." "Installing sysbench..."
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
prompt "==============================================================" "=============================================================="
prompt "📊 服务器性能检测报告" "📊 Server Performance Report"
prompt "==============================================================" "=============================================================="
prompt "🌐 公网 IP: $PUBLIC_IP" "🌐 Public IP: $PUBLIC_IP"
prompt "📡 网络接口: $NET_IFACE (速度: $NET_SPEED)" "📡 Network interface: $NET_IFACE (Speed: $NET_SPEED)"
prompt "⏱️  到 8.8.8.8 延迟: ${PING_RESULT:-未知} ms" "⏱️  Latency to 8.8.8.8: ${PING_RESULT:-Unknown} ms"
prompt "💾 磁盘写入速度: ${DISK_WRITE:-未知}" "💾 Disk write speed: ${DISK_WRITE:-Unknown}"
prompt "💿 磁盘读取速度: ${DISK_READ:-未知}" "💿 Disk read speed: ${DISK_READ:-Unknown}"
prompt "🧠 CPU 性能: ${CPU_SCORE:-未知} events/sec" "🧠 CPU performance: ${CPU_SCORE:-Unknown} events/sec"
prompt "🧮 内存性能: ${MEM_SCORE:-未知} MiB/sec" "🧮 Memory performance: ${MEM_SCORE:-Unknown} MiB/sec"
prompt "==============================================================" "=============================================================="
log "性能检测完成: IP=$PUBLIC_IP, 延迟=${PING_RESULT:-未知}ms, 磁盘写=$DISK_WRITE, 磁盘读=$DISK_READ, CPU=$CPU_SCORE, 内存=$MEM_SCORE"

#=========================#
# 安装依赖（分发版判断）  #
#=========================#
prompt "[INFO] 正在安装依赖项..." "[INFO] Installing dependencies..."
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
    elif command -v dnf >/dev/null; then
        dnf install -y epel-release
        dnf groupinstall -y "Development Tools"
        dnf install -y gcc gcc-c++ make cmake autoconf automake libtool openssl-devel \
        pcre-devel pcre2-devel libcap-devel hwloc-devel ncurses-devel libcurl-devel \
        expat-devel sqlite-devel zlib-devel luajit-devel libunwind-devel \
        brotli-devel xz-devel libyaml-devel tcl-dev wget curl unzip vim \
        git screen zip gnupg file socat bind-utils docker-compose golang nodejs npm
    elif [ "$DISTRO" = "freebsd" ]; then
        pkg install -y gcc gmake autoconf automake libtool cmake pkgconf pcre \
        pcre2 openssl curl lua51 zlib brotli bash node npm go
    else
        prompt "❌ 暂不支持该系统的依赖自动安装，请手动安装依赖。" "❌ Dependency installation not supported for this system, please install manually."
        log "不支持的系统，依赖安装失败"
        exit 1
    fi
}

install_deps_linux || { log "依赖安装失败"; exit 1; }

#=========================#
# 下载 + 编译 + 安装 ATS  #
#=========================#
prompt "[INFO] 开始下载并编译安装 Apache Traffic Server..." "[INFO] Starting to download and compile Apache Traffic Server..."
log "开始安装 ATS"
cd /usr/local/src || { log "无法进入 /usr/local/src"; exit 1; }

# 下载 ATS（带重试和校验）
ATS_URL="https://downloads.apache.org/trafficserver/trafficserver-10.0.0.tar.bz2"
ATS_SHA256="b13e6d8e7e8f6e4e6e9c836feda8736a69c6b5a2e5b32a7e91b0b9c5b0d7e9c7"
for ((i=1; i<=3; i++)); do
    check_network
    wget "$ATS_URL" -O trafficserver-10.0.0.tar.bz2 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$ATS_SHA256  trafficserver-10.0.0.tar.bz2" | sha256sum -c >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "ATS 下载成功，校验通过"
            break
        else
            prompt "❌ ATS 文件校验失败，重新尝试..." "❌ ATS file checksum failed, retrying..."
            rm -f trafficserver-10.0.0.tar.bz2
        fi
    fi
    if [ $i -eq 3 ]; then
        prompt "❌ 下载 ATS 失败，请检查网络连接" "❌ Failed to download ATS, please check network"
        log "ATS 下载失败"
        exit 1
    fi
    sleep 2
done

tar -xjf trafficserver-10.0.0.tar.bz2
cd trafficserver-10.0.0 || { log "无法进入 ATS 目录"; exit 1; }

prompt "正在配置 ATS..." "Configuring ATS..."
cmake -B build -DCMAKE_BUILD_TYPE=Release || { log "ATS cmake 配置失败"; exit 1; }
prompt "正在编译 ATS（可能需要几分钟）..." "Compiling ATS (this may take a few minutes)..."
cmake --build build || { log "ATS 编译失败"; exit 1; }
prompt "正在安装 ATS..." "Installing ATS..."
cmake --install build || { log "ATS 安装失败"; exit 1; }

# 启动 ATS
/usr/local/bin/trafficserver start
log "ATS 启动成功"

# 添加 systemd 启动服务
if [[ "$OS_NAME" == "Linux" && -d /etc/systemd/system ]]; then
    prompt "[INFO] 添加 systemd 启动服务..." "[INFO] Adding systemd service..."
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
# 清理临时文件            #
#=========================#
prompt "[INFO] 清理临时文件..." "[INFO] Cleaning up temporary files..."
rm -rf /usr/local/src/trafficserver-10.0.0* bbr.sh
log "临时文件清理完成"

#=========================#
# 生成卸载脚本            #
#=========================#
prompt "[INFO] 生成卸载脚本..." "[INFO] Generating uninstall script..."
cat >/usr/local/bin/uninstall_ats.sh <<EOF
#!/bin/bash
echo "正在卸载 Apache Traffic Server..."
/usr/local/bin/trafficserver stop
systemctl disable trafficserver 2>/dev/null
rm -f /etc/systemd/system/trafficserver.service
rm -rf /usr/local/bin/trafficserver /usr/local/etc/trafficserver /usr/local/var/trafficserver
echo "Apache Traffic Server 已卸载！"
EOF
chmod +x /usr/local/bin/uninstall_ats.sh
log "卸载脚本生成成功：/usr/local/bin/uninstall_ats.sh"

#=========================#
# 日志压缩                #
#=========================#
if [ -f "$LOG_FILE" ] && [ $(stat -c %s "$LOG_FILE") -gt 10485760 ]; then
    prompt "[INFO] 日志文件过大，正在压缩..." "[INFO] Log file too large, compressing..."
    tar -czf "${LOG_FILE}.$(date +%F).tar.gz" "$LOG_FILE"
    : > "$LOG_FILE"
    log "日志文件压缩完成"
fi

#=========================#
# 安装成功 & 广告输出     #
#=========================#
clear
prompt "==============================================================" "=============================================================="
prompt "🎉 Apache Traffic Server 安装成功！" "🎉 Apache Traffic Server installed successfully!"
prompt "==============================================================" "=============================================================="
prompt "关于 VmShell" "About VmShell"
prompt "VMSHELL INC 是一家成立于2021年的美国云计算服务公司，总部位于怀俄明州谢里丹，专注于提供全球数据中心的虚拟机服务器租赁和软件开发服务。" "VMSHELL INC, founded in 2021, is a U.S.-based cloud computing company headquartered in Sheridan, Wyoming, specializing in global data center VM server rentals and software development."
prompt "公司旗下品牌包括 VmShell 和 ToToTel，业务覆盖亚洲、美洲和欧洲，致力于为企业提供高效、稳定的网络解决方案。" "Its brands, VmShell and ToToTel, operate across Asia, the Americas, and Europe, delivering efficient and stable network solutions for businesses."
prompt "" ""
prompt "▶ 主打服务：VPS、独立服务器、云端管理平台" "▶ Main Services: VPS, Dedicated Servers, Cloud Management Platform"
prompt "▶ 核心地区：香港中国移动CMI线路、美国圣何塞国际带宽" "▶ Core Regions: Hong Kong CMI Lines, San Jose International Bandwidth"
prompt "▶ 支持：流媒体解锁（Netflix、TikTok）、SSH管理、云端脚本运维" "▶ Support: Streaming unlock (Netflix, TikTok), SSH management, cloud script operations"
prompt "▶ 支付方式：PayPal、支付宝、比特币、USDT 等" "▶ Payment Methods: PayPal, Alipay, Bitcoin, USDT, etc."
prompt "" ""
prompt "📡 测试节点 IP:" "📡 Test Node IPs:"
prompt "英国：    89.34.97.34" "UK:       89.34.97.34"
prompt "日本：    94.177.17.66" "Japan:    94.177.17.66"
prompt "香港：    103.225.199.99" "Hong Kong: 103.225.199.99"
prompt "美国：    23.173.216.107" "USA:      23.173.216.107"
prompt "澳门：    163.53.246.77" "Macau:    163.53.246.77"
prompt "" ""
prompt "📞 联系方式：" "📞 Contact Information:"
prompt "官方网站：https://vmshell.com/    | https://tototel.com" "Official Websites: https://vmshell.com/ | https://tototel.com"
prompt "Telegram 讨论：https://t.me/vmsus" "Telegram Group: https://t.me/vmsus"
prompt "电话支持：+1 (469) 278-6367" "Phone Support: +1 (469) 278-6367"
prompt "Email1：admin@vmshell.com" "Email1: admin@vmshell.com"
prompt "Email2：vmshell.inc@gmail.com" "Email2: vmshell.inc@gmail.com"
prompt "" ""
prompt "💡 感谢您使用 VMSHELL 一键安装脚本！我们 24 小时为您服务。" "💡 Thank you for using VMSHELL's one-click installation script! We provide 24/7 service."
prompt "==============================================================" "=============================================================="
log "安装完成，脚本执行成功"
