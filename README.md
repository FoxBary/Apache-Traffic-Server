<p><a href="https://linuxword.com/wp-content/uploads/2025/05/e85d8729d2c18216f35c182158a5e119.png"><img class="alignnone size-full wp-image-46283" src="https://linuxword.com/wp-content/uploads/2025/05/e85d8729d2c18216f35c182158a5e119.png" alt="" width="1195" height="1174" /></a></p>
<p>关于VmShell:<br />
VMSHELL INC 是一家成立于2021年的美国云计算服务公司，总部位于怀俄明州谢里丹，专注于提供全球数据中心的虚拟机服务器租赁和软件开发服务。公司旗下品牌包括 VmShell 和 ToToTel，业务覆盖亚洲和美洲以及欧洲，致力于为企业提供高效、稳定的网络解决方案。其核心服务包括虚拟私有服务器（VPS）、独立服务器以及云端管理平台，广泛应用于企业业务拓展、流媒体优化和跨境电商等领域。<br />
公司主打香港和美国圣何塞两大核心数据中心。香港数据中心采用中国移动CMI高速网络，支持三网优化，提供亚洲香港CMI三网大陆优化1Gbps和美国10Gbps的国际带宽，特别适合面向中国大陆及东南亚市场的用户；香港数据中心和美国圣何塞数据中心，我们都提供了香港IP和美国的IP供用户选择，支持流媒体解锁（如TikTok、Netflix等），满足电信和联通用户的优化需求。<br />
VMSHELL INC 以用户体验为核心，提供24/7技术支持，承诺99.99%的服务器在线率，并支持PayPal、支付宝、比特币等多种支付方式，方便全球用户。公司还开发了移动端管理应用，支持服务器运行监控、SSH管理和Linux运维脚本，极大提升了用户管理效率。凭借可靠的网络性能和灵活的服务模式，VMSHELL INC 已成长为云计算领域值得信赖的品牌，未来计划持续优化技术社区功能，扩展更多创新服务。<br />
VmShell官方网站：https://vmshell.com/ TOTOTEL官方网站: https://tototel.com<br />
随时为您提供支持<br />
24 小时 Telegram 在线服务：https://t.me/vmsus<br />
24 小时电话支持：+1(469)278-6367<br />
紧急电子邮件支持：<br />
电子邮件一：admin@vmshell.com<br />
电子邮件二：vmshell.inc@gmail.com<br />
CDN网络测试,VMSHELL所有测试IP<br />
英国数据中心：89.34.97.34<br />
日本数据中心：94.177.17.66<br />
香港数据中心：103.225.199.99<br />
美国数据中心：23.173.216.107<br />
澳门数据中心：163.53.246.77</p>
<p><a href="https://linuxword.com/wp-content/uploads/2025/05/Traffic-Control-Logo-FINAL-Black-Text-scaled.png"><img class="alignnone size-full wp-image-46334" src="https://linuxword.com/wp-content/uploads/2025/05/Traffic-Control-Logo-FINAL-Black-Text-scaled.png" alt="" width="2560" height="642" /></a></p>
<p>第一步:安装整个依赖库:<br />
apt update &amp;&amp; apt -y upgrade &amp;&amp; apt -y install build-essential autoconf automake libtool pkg-config libssl-dev libpcre2-dev libcap-dev libhwloc-dev libncurses5-dev libcurl4-openssl-dev libexpat1-dev libsqlite3-dev zlib1g-dev libluajit-5.1-dev libunwind-dev libbrotli-dev liblzma-dev libyaml-dev tcl-dev wget curl unzip vim xz-utils git screen zip gnupg file libpcre3-dev socat dnsutils docker-compose gcc g++ make cmake golang-go nodejs npm<br />
第二步: 根据官方 CMake 教程手动构建与安装 Apache Traffic Server 的详细步骤（Ubuntu 专用）,你已经安装完依赖，以下是构建并安装 Traffic Server 的全部步骤：下载源码<br />
cd /usr/local/src &amp;&amp; wget https://downloads.apache.org/trafficserver/trafficserver-10.0.0.tar.bz2 &amp;&amp; tar -xjf trafficserver-10.0.0.tar.bz2 &amp;&amp; cd trafficserver-10.0.0 &amp;&amp; cmake -B build -DCMAKE_BUILD_TYPE=Release &amp;&amp; cmake --build build<br />
第三步:安装到系统<br />
cmake --install build<br />
第四步:验证安装成功<br />
/usr/local/bin/traffic_server -V<br />
第五步:启动 Apache Traffic Server<br />
/usr/local/bin/trafficserver start<br />
第六步:添加 systemd 启动服务（trafficserver.service）<br />
创建服务文件：nano /etc/systemd/system/trafficserver.service<br />
填入以下内容(默认安装在 /usr/local/trafficserver):<br />
[Unit]<br />
Description=Apache Traffic Server<br />
After=network.target</p>
<p>[Service]<br />
Type=forking<br />
ExecStart=/usr/local/bin/trafficserver start<br />
ExecStop=/usr/local/bin/trafficserver stop<br />
ExecReload=/usr/local/bin/traffic_ctl config reload<br />
Restart=always<br />
LimitNOFILE=65536</p>
<p>[Install]<br />
WantedBy=multi-user.target<br />
启用并启动服务：<br />
systemctl daemon-reload<br />
systemctl enable trafficserver<br />
systemctl start trafficserver<br />
查看状态：<br />
systemctl status trafficserver</p>
<p>&nbsp;</p>
<p><span style="font-size: 10pt;"><a href="https://linuxword.com/wp-content/uploads/2025/05/wechat_2025-05-11_210354_584t.png"><img class="alignnone size-full wp-image-46278" src="https://linuxword.com/wp-content/uploads/2025/05/wechat_2025-05-11_210354_584t.png" alt="" width="1260" height="965" /></a></span></p>
<p><span style="font-size: 10pt;">ToToTel官网：https://tototel.com</span><br />
<span style="font-size: 10pt;">支付方式：Paypal/支付宝/比特币/USDT/信用卡/微信</span><br />
<span style="font-size: 10pt;">Affman提成：销售金额的10.00%,支持银行和支付宝（PAYPAL）提现!</span><br />
<span style="font-size: 10pt;">退款策略：大部分所有产品支持原路退款在3日新购以内</span><br />
<span style="font-size: 10pt;">关于ToToTel ,ToToTel是VmShell INC美国公司旗下的全球云计算品牌(由于是美国公司,请遵守美国法律要求的服务内容),其中覆盖了香港CMI(三网优化),英国伦敦1Gbps不限流量服务器 ,美国全媒体IP(电信/联通优化)10Gbps基础网络，自2021年成立至今已超过四年的老牌IDC基础网络提供/服务商,ToToTel采用集成度更高的PVE云服务器架构，简洁高效,</span><br />
<span style="font-size: 10pt;"><strong>至此</strong>:整个VmShell覆盖了英国.欧洲/香港/日本.亚洲/美国.美洲三个主要国际地区的网络CDN覆盖,欢庆日本10Gbps服务器回归!</span></p>
<hr />
<h3><span style="font-size: 10pt;">限制流量产品</span></h3>
<table border="1">
<thead>
<tr>
<th><span style="font-size: 10pt;">地区/名称</span></th>
<th><span style="font-size: 10pt;">配置</span></th>
<th><span style="font-size: 10pt;">带宽</span></th>
<th><span style="font-size: 10pt;">流媒体支持</span></th>
<th><span style="font-size: 10pt;">优惠码</span></th>
<th><span style="font-size: 10pt;">付款/价格</span></th>
<th><span style="font-size: 10pt;">订购链接</span></th>
</tr>
</thead>
<tbody>
<tr>
<td><span style="font-size: 10pt;">香港 - HK-CMI-Media</span></td>
<td><span style="font-size: 10pt;">1C / 768MB / 10GB / 2TB</span></td>
<td><span style="font-size: 10pt;">1Gbps 共享</span></td>
<td><span style="font-size: 10pt;">香港.奈菲 / 迪士尼+</span></td>
<td><span style="font-size: 10pt;">无</span></td>
<td><span style="font-size: 10pt;">$13USD/月</span></td>
<td><span style="font-size: 10pt;"><a href="https://portal.tototel.com/aff.php?aff=1&amp;pid=1">订购</a></span></td>
</tr>
<tr>
<td><span style="font-size: 10pt;">日本 - TOKYO-10Gbps</span></td>
<td><span style="font-size: 10pt;">1C / 1GB / 10GB / 4TB</span></td>
<td><span style="font-size: 10pt;">10Gbps 共享</span></td>
<td><span style="font-size: 10pt;">TikTok/Gemini/ChatGPT</span></td>
<td><span style="font-size: 10pt;"><code>jphuigui</code></span></td>
<td><span style="font-size: 10pt;">$45.60 年付</span></td>
<td><span style="font-size: 10pt;"><a href="https://portal.tototel.com/aff.php?aff=1&amp;pid=14">订购</a></span></td>
</tr>
<tr>
<td><span style="font-size: 10pt;">美国 - USA-IP.HK-Media</span></td>
<td><span style="font-size: 10pt;">1C / 512MB / 6GB / 4TB</span></td>
<td><span style="font-size: 10pt;">10Gbps 共享</span></td>
<td><span style="font-size: 10pt;">奈菲 / 迪士尼+（港IP）</span></td>
<td><span style="font-size: 10pt;">无需优惠码</span></td>
<td><span style="font-size: 10pt;">$15.15 年付</span></td>
<td><span style="font-size: 10pt;"><a href="https://vmshell.com/aff.php?aff=2689&amp;pid=18">订购</a></span></td>
</tr>
<tr>
<td><span style="font-size: 10pt;">英国 - LONDON.UK-KVM</span></td>
<td><span style="font-size: 10pt;">1C / 512MB / 10GB / 4TB</span></td>
<td><span style="font-size: 10pt;">1Gbps 共享</span></td>
<td><span style="font-size: 10pt;">TikTok.UK AND ChatGPT</span></td>
<td><span style="font-size: 10pt;"><code>england4t</code></span></td>
<td><span style="font-size: 10pt;">$36.00 年付</span></td>
<td><span style="font-size: 10pt;"><a href="https://vmshell.com/aff.php?aff=2689&amp;pid=5">订购</a></span></td>
</tr>
</tbody>
</table>
<hr />
<h3><span style="font-size: 10pt;">不限流量产品</span></h3>
<table border="1">
<thead>
<tr>
<th><span style="font-size: 10pt;">地区/名称</span></th>
<th><span style="font-size: 10pt;">配置</span></th>
<th><span style="font-size: 10pt;">带宽</span></th>
<th><span style="font-size: 10pt;">流媒体支持</span></th>
<th><span style="font-size: 10pt;">优惠码</span></th>
<th><span style="font-size: 10pt;">年付价格</span></th>
<th><span style="font-size: 10pt;">订购链接</span></th>
</tr>
</thead>
<tbody>
<tr>
<td><span style="font-size: 10pt;">香港 - CMI.HK-Unlimited</span></td>
<td><span style="font-size: 10pt;">不限流量 / 1C / 512MB / 10GB</span></td>
<td><span style="font-size: 10pt;">35Mbps 独享</span></td>
<td><span style="font-size: 10pt;">香港.奈菲 / 迪士尼+</span></td>
<td><span style="font-size: 10pt;"><code>ToToCMIHK40</code></span></td>
<td><span style="font-size: 10pt;"><em>$72.00 年付</em></span></td>
<td><span style="font-size: 10pt;"><a href="https://portal.tototel.com/aff.php?aff=1&amp;pid=11">订购</a></span></td>
</tr>
<tr>
<td><span style="font-size: 10pt;">日本 - TOKYO-Unlimited</span></td>
<td><span style="font-size: 10pt;">不限流量 / 1C / 2GB / 20GB</span></td>
<td><span style="font-size: 10pt;">10Gbps 共享</span></td>
<td><span style="font-size: 10pt;">TikTok/Gemini/ChatGPT</span></td>
<td><span style="font-size: 10pt;"><code>jpmobile50</code></span></td>
<td><span style="font-size: 10pt;">$120.00 年付</span></td>
<td><span style="font-size: 10pt;"><a href="https://portal.tototel.com/aff.php?aff=1&amp;pid=1">订购</a></span></td>
</tr>
<tr>
<td><span style="font-size: 10pt;">美国 - Unlimit-HKIP</span></td>
<td><span style="font-size: 10pt;">不限流量 / 1C / 1GB / 20GB</span></td>
<td><span style="font-size: 10pt;">10Gbps 共享</span></td>
<td><span style="font-size: 10pt;">奈菲 / 迪士尼+（港IP）</span></td>
<td><span style="font-size: 10pt;">无需优惠码</span></td>
<td><span style="font-size: 10pt;">$54.00 年付</span></td>
<td><span style="font-size: 10pt;"><a href="https://vmshell.com/aff.php?aff=2689&amp;pid=20">订购</a></span></td>
</tr>
<tr>
<td><span style="font-size: 10pt;">英国 - UK-Unlimited</span></td>
<td><span style="font-size: 10pt;">不限流量 / 1C / 1GB / 20GB</span></td>
<td><span style="font-size: 10pt;">1Gbps 共享</span></td>
<td><span style="font-size: 10pt;">TikTok.UK AND ChatGPT</span></td>
<td><span style="font-size: 10pt;"><code>England50</code></span></td>
<td><span style="font-size: 10pt;">$70.00 年付</span></td>
<td><span style="font-size: 10pt;"><a href="https://portal.tototel.com/aff.php?aff=1&amp;pid=12">订购</a></span></td>
</tr>
</tbody>
</table>
<hr />
<p>&nbsp;</p>
