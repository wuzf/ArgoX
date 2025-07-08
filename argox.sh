#!/usr/bin/env bash

# 当前脚本版本号
VERSION='1.7.0 (2025.01.07) - Multi-region Socks5 Support'

# 各变量默认值
GH_PROXY='https://ghfast.top/'
# 多个路径和对应的地区
declare -A WS_PATHS=(
  ["hk"]="🇭🇰香港"
  ["sg"]="🇸🇬新加坡"
  ["jp"]="🇯🇵日本"
  ["tw"]="🇹🇼台湾"
  ["vn"]="🇻🇳越南"
)
declare -A SOCKS5_PORTS=(
  ["hk"]="20000"
  ["sg"]="10001"
  ["jp"]="50000"
  ["tw"]="30000"
  ["vn"]="40000"
)
WORK_DIR='/etc/argox'
TEMP_DIR='/tmp/argox'
TLS_SERVER='addons.mozilla.org'
# 端口定义
METRICS_PORT='3333'      # cloudflared监控指标端口
LOCAL_PROXY_PORT='8080'  # 本地代理服务端口（Xray监听端口）
CDN_DOMAIN=("skk.moe" "ip.sb" "time.is" "cfip.xxxxxxxx.tk" "bestcf.top" "cdn.2020111.xyz" "xn--b6gac.eu.org")
SUBSCRIBE_TEMPLATE="https://raw.githubusercontent.com/fscarmen/client_template/main"
DEFAULT_XRAY_VERSION='25.4.30'

export DEBIAN_FRONTEND=noninteractive

trap "rm -rf $TEMP_DIR; echo -e '\n' ;exit 1" INT QUIT TERM EXIT

mkdir -p $TEMP_DIR

E[0]="Language:\n 1. English \n 2. 简体中文 (default)"
C[0]="${E[0]}"
E[1]="Added multi-region SOCKS5 proxy support with automatic path-based routing."
C[1]="新增多地区 SOCKS5 代理支持，自动基于路径进行路由分流"
E[2]="Project to create Argo tunnels and Xray specifically for VPS, detailed:[https://github.com/wuzf/ArgoXForAlice]\n Features:\n\t • Allows the creation of Argo tunnels via Token, Json and ad hoc methods. User can easily obtain the json at https://fscarmen.cloudflare.now.cc .\n\t • Extremely fast installation method, saving users time.\n\t • Support system: Ubuntu, Debian, CentOS, Alpine and Arch Linux 3.\n\t • Support architecture: AMD,ARM and s390x\n"
C[2]="本项目专为 VPS 添加 Argo 隧道及 Xray,详细说明: [https://github.com/wuzf/ArgoXForAlice]\n 脚本特点:\n\t • 允许通过 Token, Json 及 临时方式来创建 Argo 隧道,用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc\n\t • 极速安装方式,大大节省用户时间\n\t • 智能判断操作系统: Ubuntu 、Debian 、CentOS 、Alpine 和 Arch Linux,请务必选择 LTS 系统\n\t • 支持硬件结构类型: AMD 和 ARM\n"
E[3]="Input errors up to 5 times.The script is aborted."
C[3]="输入错误达5次,脚本退出"
E[4]="UUID should be 36 characters, please re-enter \(\${a} times remaining\)"
C[4]="UUID 应为36位字符,请重新输入 \(剩余\${a}次\)"
E[5]="The script supports Debian, Ubuntu, CentOS, Alpine or Arch systems only. Feedback: [https://github.com/wuzf/ArgoXForAlice/issues]"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Alpine 或 Arch 系统,问题反馈:[https://github.com/wuzf/ArgoXForAlice/issues]"
E[6]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/wuzf/ArgoXForAlice/issues]"
C[6]="当前操作是 \$SYS\\\n 不支持 \$SYSTEM \${MAJOR[int]} 以下系统,问题反馈:[https://github.com/wuzf/ArgoXForAlice/issues]"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="All dependencies already exist and do not need to be installed additionally."
C[8]="所有依赖已存在，不需要额外安装"
E[9]="To upgrade, press [y]. No upgrade by default:"
C[9]="升级请按 [y]，默认不升级:"
E[10]="(3/6) Please enter Argo Domain (Default is temporary domain if left blank):"
C[10]="(3/6) 请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
E[11]="Please enter Argo Token or Json ( User can easily obtain the json at https://fscarmen.cloudflare.now.cc ):"
C[11]="请输入 Argo Token 或者 Json ( 用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc ):"
E[12]="\(6/6\) Please enter Xray UUID \(Default is \$UUID_DEFAULT\):"
C[12]="\(6/6\) 请输入 Xray UUID \(默认为 \$UUID_DEFAULT\):"

E[14]="Multiple WS paths configured automatically for load balancing across regions:"
C[14]="已自动配置多个 WS 路径用于不同地区的负载均衡:"
E[15]="ArgoX script has not been installed yet."
C[15]="ArgoX 脚本还没有安装"
E[16]="ArgoX is completely uninstalled."
C[16]="ArgoX 已彻底卸载"
E[17]="Version"
C[17]="脚本版本"
E[18]="New features"
C[18]="功能新增"
E[19]="System infomation"
C[19]="系统信息"
E[20]="Operating System"
C[20]="当前操作系统"
E[21]="Kernel"
C[21]="内核"
E[22]="Architecture"
C[22]="处理器架构"
E[23]="Virtualization"
C[23]="虚拟化"
E[24]="Choose (default 1):"
C[24]="请选择 (默认选择 1):"
E[25]="Curren architecture \$(uname -m) is not supported. Feedback: [https://github.com/wuzf/ArgoXForAlice/issues]"
C[25]="当前架构 \$(uname -m) 暂不支持,问题反馈:[https://github.com/wuzf/ArgoXForAlice/issues]"
E[26]="Not install"
C[26]="未安装"
E[27]="close"
C[27]="关闭"
E[28]="open"
C[28]="开启"
E[29]="View links (argox -n)"
C[29]="查看节点信息 (argox -n)"
E[30]="Change the Argo tunnel (argox -t)"
C[30]="更换 Argo 隧道 (argox -t)"
E[31]="Sync Argo and Xray to the latest version (argox -v)"
C[31]="同步 Argo 和 Xray 至最新版本 (argox -v)"
E[32]="Upgrade kernel, turn on BBR, change Linux system (argox -b)"
C[32]="升级内核、安装BBR、DD脚本 (argox -b)"
E[33]="Uninstall (argox -u)"
C[33]="卸载 (argox -u)"
E[34]="Install ArgoX script (argo + xray)"
C[34]="安装 ArgoX 脚本 (argo + xray)"
E[35]="Exit"
C[35]="退出"
E[36]="Please enter the correct number"
C[36]="请输入正确数字"
E[37]="successful"
C[37]="成功"
E[38]="failed"
C[38]="失败"
E[39]="ArgoX is not installed."
C[39]="ArgoX 未安装"
E[40]="Argo tunnel is: \$ARGO_TYPE\\\n The domain is: \$ARGO_DOMAIN"
C[40]="Argo 隧道类型为: \$ARGO_TYPE\\\n 域名是: \$ARGO_DOMAIN"
E[41]="Argo tunnel type:\n 1. Try\n 2. Token or Json"
C[41]="Argo 隧道类型:\n 1. Try\n 2. Token 或者 Json"
E[42]="\(5/6\) Please select or enter the preferred domain, the default is \${CDN_DOMAIN[0]}:"
C[42]="\(5/6\) 请选择或者填入优选域名，默认为 \${CDN_DOMAIN[0]}:"
E[43]="\$APP local verion: \$LOCAL.\\\t The newest verion: \$ONLINE"
C[43]="\$APP 本地版本: \$LOCAL.\\\t 最新版本: \$ONLINE"
E[44]="No upgrade required."
C[44]="不需要升级"
E[45]="Argo authentication message does not match the rules, neither Token nor Json, script exits. Feedback:[https://github.com/wuzf/ArgoXForAlice/issues]"
C[45]="Argo 认证信息不符合规则，既不是 Token，也是不是 Json，脚本退出，问题反馈:[https://github.com/wuzf/ArgoXForAlice/issues]"
E[46]="Connect"
C[46]="连接"
E[47]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback:[https://github.com/wuzf/ArgoXForAlice/issues]"
C[47]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/wuzf/ArgoXForAlice/issues]"
E[48]="Downloading the latest version \$APP failed, script exits. Feedback:[https://github.com/wuzf/ArgoXForAlice/issues]"
C[48]="下载最新版本 \$APP 失败，脚本退出，问题反馈:[https://github.com/wuzf/ArgoXForAlice/issues]"

E[50]="\${APP[@]} services are not enabled, node information cannot be output. Press [y] if you want to open."
C[50]="\${APP[@]} 服务未开启，不能输出节点信息。如需打开请按 [y]: "
E[51]="Install Sing-box multi-protocol scripts [https://github.com/fscarmen/sing-box]"
C[51]="安装 Sing-box 协议全家桶脚本 [https://github.com/fscarmen/sing-box]"
E[52]="Memory Usage"
C[52]="内存占用"
E[53]="The xray service is detected to be installed. Script exits."
C[53]="检测到已安装 xray 服务，脚本退出!"
E[54]="Warp / warp-go was detected to be running. Please enter the correct server IP:"
C[54]="检测到 warp / warp-go 正在运行，请输入确认的服务器 IP:"
E[55]="The script runs today: \$TODAY. Total: \$TOTAL"
C[55]="脚本当天运行次数: \$TODAY，累计运行次数: \$TOTAL"
E[56]="\(4/6\) Please enter the Reality port \(Default is \${REALITY_PORT_DEFAULT}\):"
C[56]="\(4/6\) 请输入 Reality 的端口号 \(默认为 \${REALITY_PORT_DEFAULT}\):"
E[57]="Install sba scripts (argo + sing-box) [https://github.com/fscarmen/sba]"
C[57]="安装 sba 脚本 (argo + sing-box) [https://github.com/fscarmen/sba]"
E[58]="No server ip, script exits. Feedback:[https://github.com/fscarmen/sing-box/issues]"
C[58]="没有 server ip，脚本退出，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
E[59]="\(2/6\) Please enter VPS IP \(Default is: \${SERVER_IP_DEFAULT}\):"
C[59]="\(2/6\) 请输入 VPS IP \(默认为: \${SERVER_IP_DEFAULT}\):"
E[60]="Quicktunnel domain can be obtained from: http://\${SERVER_IP_1}:\${METRICS_PORT}/quicktunnel"
C[60]="临时隧道域名可以从以下网站获取: http://\${SERVER_IP_1}:\${METRICS_PORT}/quicktunnel"
E[61]="Ports are in used: \$REALITY_PORT"
C[61]="正在使用中的端口: \$REALITY_PORT"
E[62]="Create shortcut [ argox ] successfully."
C[62]="创建快捷 [ argox ] 指令成功!"
E[63]="The full template can be found at:\n https://t.me/ztvps/67\n https://github.com/chika0801/sing-box-examples/tree/main/Tun"
C[63]="完整模板可参照:\n https://t.me/ztvps/67\n https://github.com/chika0801/sing-box-examples/tree/main/Tun"
E[64]="subscribe"
C[64]="订阅"
E[65]="To uninstall Nginx press [y], it is not uninstalled by default:"
C[65]="如要卸载 Nginx 请按 [y]，默认不卸载:"
E[66]="Adaptive Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM Clients"
C[66]="自适应 Clash / V2rayN / NekoBox / ShadowRocket / SFI / SFA / SFM 客户端"
E[67]="template"
C[67]="模版"
E[68]="(1/6) Output subscription QR code and https service, need to install nginx\n If not, please enter [n]. Default installation:"
C[68]="(1/6) 输出订阅二维码和 https 服务，需要安装依赖 nginx\n 如不需要，请输入 [n]，默认安装:"
E[69]="Set SElinux: enforcing --> disabled"
C[69]="设置 SElinux: enforcing --> disabled"
E[70]="ArgoX is not installed and cannot change the CDN."
C[70]="ArgoX 未安装，不能更换 CDN"
E[71]="Current CDN is: \${CDN_NOW}"
C[71]="当前 CDN 为: \${CDN_NOW}"
E[72]="Please select or enter a new CDN (press Enter to keep the current one):"
C[72]="请选择或输入新的 CDN (回车保持当前值):"
E[73]="CDN has been changed from \${CDN_NOW} to \${CDN_NEW}"
C[73]="CDN 已从 \${CDN_NOW} 更改为 \${CDN_NEW}"
E[74]="Unable to access api.github.com. This may be due to IP restrictions (HTTP/1.1 403 Rate Limit Exceeded). Please try again later"
C[74]="无法访问 api.github.com，可能是由于 IP 限制导致的（HTTP/1.1 403 Rate Limit Exceeded），请稍后重试"

# 自定义字体彩色，read 函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色
reading() { read -rp "$(info "$1")" "$2"; }
text() { grep -q '\$' <<< "${E[$*]}" && eval echo "\$(eval echo "\${${L}[$*]}")" || eval echo "\${${L}[$*]}"; }

# 检测是否需要启用 Github CDN，如能直接连通，则不使用
check_cdn() {
  [ -n "$GH_PROXY" ] && wget --server-response --quiet --output-document=/dev/null --no-check-certificate --tries=2 --timeout=3 https://raw.githubusercontent.com/wuzf/ArgoXForAlice/main/README.md >/dev/null 2>&1 && unset GH_PROXY
}

# 检测是否解锁 chatGPT，以决定是否使用 warp 链式代理或者是 direct out，此处判断改编自 https://github.com/lmc999/RegionRestrictionCheck
check_chatgpt() {
  local CHECK_STACK=$1
  local UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
  local UA_SEC_CH_UA='"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'
  wget --help | grep -q '\-\-ciphers' && local IS_CIPHERS=is_ciphers

  # 首先检查API访问
  local CHECK_RESULT1=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} -qO- --content-on-error --header='authority: api.openai.com' --header='accept: */*' --header='accept-language: en-US,en;q=0.9' --header='authorization: Bearer null' --header='content-type: application/json' --header='origin: https://platform.openai.com' --header='referer: https://platform.openai.com/' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: empty' --header='sec-fetch-mode: cors' --header='sec-fetch-site: same-site' --user-agent="${UA_BROWSER}" 'https://api.openai.com/compliance/cookie_requirements')

  grep -q "^$" <<< "$CHECK_RESULT1" && grep -qw is_ciphers <<< "$IS_CIPHERS" && local CHECK_RESULT1=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} --ciphers=DEFAULT@SECLEVEL=1 --no-check-certificate -qO- --content-on-error --header='authority: api.openai.com' --header='accept: */*' --header='accept-language: en-US,en;q=0.9' --header='authorization: Bearer null' --header='content-type: application/json' --header='origin: https://platform.openai.com' --header='referer: https://platform.openai.com/' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: empty' --header='sec-fetch-mode: cors' --header='sec-fetch-site: same-site' --user-agent="${UA_BROWSER}" 'https://api.openai.com/compliance/cookie_requirements')

  # 如果API检测失败或者检测到unsupported_country,直接返回ban
  if grep -q "^$" <<< "$CHECK_RESULT1" || grep -qi 'unsupported_country' <<< "$CHECK_RESULT1"; then
    echo "ban"
    return
  fi

  # API检测通过后,继续检查网页访问
  local CHECK_RESULT2=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} -qO- --content-on-error --header='authority: ios.chat.openai.com' --header='accept: */*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='accept-language: en-US,en;q=0.9' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: document' --header='sec-fetch-mode: navigate' --header='sec-fetch-site: none' --header='sec-fetch-user: ?1' --header='upgrade-insecure-requests: 1' --user-agent="${UA_BROWSER}" https://ios.chat.openai.com/)

  [ -z "$CHECK_RESULT2" ] && grep -qw is_ciphers <<< "$IS_CIPHERS" && local CHECK_RESULT2=$(wget --timeout=2 --tries=2 --retry-connrefused --waitretry=5 ${CHECK_STACK} --ciphers=DEFAULT@SECLEVEL=1 --no-check-certificate -qO- --content-on-error --header='authority: ios.chat.openai.com' --header='accept: */*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='accept-language: en-US,en;q=0.9' --header="sec-ch-ua: ${UA_SEC_CH_UA}" --header='sec-ch-ua-mobile: ?0' --header='sec-ch-ua-platform: "Windows"' --header='sec-fetch-dest: document' --header='sec-fetch-mode: navigate' --header='sec-fetch-site: none' --header='sec-fetch-user: ?1' --header='upgrade-insecure-requests: 1' --user-agent="${UA_BROWSER}" https://ios.chat.openai.com/)

  # 检查第二个结果
  if [ -z "$CHECK_RESULT2" ] || grep -qi 'VPN' <<< "$CHECK_RESULT2"; then
    echo "ban"
  else
    echo "unlock"
  fi
}

# 脚本当天及累计运行次数统计
statistics_of_run-times() {
  local UPDATE_OR_GET=$1
  local SCRIPT=$2
  if grep -q 'update' <<< "$UPDATE_OR_GET"; then
    { wget -qO- --timeout=3 "https://stat-api.netlify.app/updateStats?script=${SCRIPT}" > $TEMP_DIR/statistics 2>/dev/null || true; }&
  elif grep -q 'get' <<< "$UPDATE_OR_GET"; then
    [ -s $TEMP_DIR/statistics ] && [[ $(cat $TEMP_DIR/statistics) =~ \"todayCount\":([0-9]+),\"totalCount\":([0-9]+) ]] && local TODAY="${BASH_REMATCH[1]}" && local TOTAL="${BASH_REMATCH[2]}" && rm -f $TEMP_DIR/statistics
    hint "\n*******************************************\n\n $(text 55) \n"
  fi
}

# 选择中英语言
select_language() {
  if [ -z "$L" ]; then
    case $(cat $WORK_DIR/language 2>&1) in
      E ) L=E ;;
      C ) L=C ;;
      * ) [ -z "$L" ] && L=C && ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && hint "\n $(text 0) \n" && reading " $(text 24) " LANGUAGE
      [ "$LANGUAGE" = 1 ] && L=E ;;
    esac
  fi
}

# 只允许 root 用户安装脚本
check_root() {
  [ "$(id -u)" != 0 ] && error "\n $(text 47) \n"
}

  # 判断处理器架构
check_arch() {
  case $(uname -m) in
    aarch64|arm64 )
      ARGO_ARCH=arm64; XRAY_ARCH=arm64-v8a; JQ_ARCH=arm64; QRENCODE_ARCH=arm64
      ;;
    x86_64|amd64 )
      ARGO_ARCH=amd64; XRAY_ARCH=64; JQ_ARCH=amd64; QRENCODE_ARCH=amd64
      ;;
    armv7l )
      ARGO_ARCH=arm; XRAY_ARCH=arm32-v7a; JQ_ARCH=armhf; QRENCODE_ARCH=arm
      ;;
    * )
      error " $(text 25) "
  esac
}

# 查安装及运行状态，下标0: argo，下标1: xray，下标2：docker；状态码: 26 未安装， 27 已安装未运行， 28 运行中
check_install() {
  [ -s $WORK_DIR/nginx.conf ] && IS_NGINX=is_nginx || IS_NGINX=no_nginx
  STATUS[0]=$(text 26)

  # 检查 argo 服务
  [ -s ${ARGO_DAEMON_FILE} ] && STATUS[0]=$(text 27) && cmd_systemctl status argo &>/dev/null && STATUS[0]=$(text 28)
  STATUS[1]=$(text 26)
  # xray systemd 文件存在的话，检测一下是否本脚本安装的，如果不是则提示并提出
  if [ -s ${XRAY_DAEMON_FILE} ]; then
    ! grep -q "$WORK_DIR" ${XRAY_DAEMON_FILE} && error " $(text 53)\n $(grep "${DAEMON_RUN_PATTERN}" ${XRAY_DAEMON_FILE}) "
    STATUS[1]=$(text 27) && cmd_systemctl status xray &>/dev/null && STATUS[1]=$(text 28)
  fi

  # 下载所需文件
  [[ ${STATUS[0]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/cloudflared ] && { wget --no-check-certificate -qO $TEMP_DIR/cloudflared ${GH_PROXY}https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/cloudflared >/dev/null 2>&1; }&
  [[ ${STATUS[1]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/xray ] && { wget --no-check-certificate -qO $TEMP_DIR/Xray.zip ${GH_PROXY}https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip >/dev/null 2>&1; unzip -qo $TEMP_DIR/Xray.zip xray *.dat -d $TEMP_DIR >/dev/null 2>&1; }&
  { wget --no-check-certificate --continue -qO $TEMP_DIR/jq ${GH_PROXY}https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-$JQ_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/jq >/dev/null 2>&1; }&
  { wget --no-check-certificate --continue -qO $TEMP_DIR/qrencode ${GH_PROXY}https://github.com/fscarmen/client_template/raw/main/qrencode-go/qrencode-go-linux-$QRENCODE_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/qrencode >/dev/null 2>&1; }&
}

# 为了适配 alpine，定义 cmd_systemctl 的函数
cmd_systemctl() {
  nginx_run() {
    $(type -p nginx) -c $WORK_DIR/nginx.conf
  }

  nginx_stop() {
    local NGINX_PID=$(ps -ef | awk -v work_dir="$WORK_DIR" '$0 ~ "nginx -c " work_dir "/nginx.conf" {print $2; exit}')
    ss -nltp | sed -n "/pid=$NGINX_PID,/ s/,/ /gp" | grep -oP 'pid=\K\S+' | sort -u | xargs kill -9 >/dev/null 2>&1
  }

  [ -s $WORK_DIR/nginx.conf ] && local IS_NGINX=is_nginx || local IS_NGINX=no_nginx
  local ENABLE_DISABLE=$1
  local APP=$2
  if [ "$ENABLE_DISABLE" = 'enable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      # 使用 openrc 启动服务
      rc-service $APP start
      # 添加到开机启动
      rc-update add $APP default
    elif [ "$IS_CENTOS" = 'CentOS7' ]; then
      systemctl daemon-reload
      systemctl enable --now $APP
      [[ "$APP" = 'xray' && "$IS_NGINX" = 'is_nginx' ]] && [ -s $WORK_DIR/nginx.conf ] && { nginx_run; firewall_configuration open; }
    else
      systemctl daemon-reload
      systemctl enable --now $APP
    fi

  elif [ "$ENABLE_DISABLE" = 'disable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP stop
      rc-update del $APP default
    elif [ "$IS_CENTOS" = 'CentOS7' ]; then
      systemctl disable --now $APP
      [[ "$APP" = 'xray' && "$IS_NGINX" = 'is_nginx' ]] && [ -s $WORK_DIR/nginx.conf ] && { nginx_stop; firewall_configuration close; }
    else
      systemctl disable --now $APP
    fi
  elif [ "$ENABLE_DISABLE" = 'status' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      rc-service $APP status
    else
      systemctl is-active $APP
    fi
  fi
}

check_system_info() {
  # 判断虚拟化
  if [ -x "$(type -p systemd-detect-virt)" ]; then
    VIRT=$(systemd-detect-virt)
  elif [ -x "$(type -p hostnamectl)" ]; then
    VIRT=$(hostnamectl | awk '/Virtualization/{print $NF}')
  elif [ -x "$(type -p virt-what)" ]; then
    VIRT=$(virt-what)
  fi

  [ -s /etc/os-release ] && SYS="$(awk -F '"' 'tolower($0) ~ /pretty_name/{print $2}' /etc/os-release)"
  [[ -z "$SYS" && -x "$(type -p hostnamectl)" ]] && SYS="$(hostnamectl | awk -F ': ' 'tolower($0) ~ /operating system/{print $2}')"
  [[ -z "$SYS" && -x "$(type -p lsb_release)" ]] && SYS="$(lsb_release -sd)"
  [[ -z "$SYS" && -s /etc/lsb-release ]] && SYS="$(awk -F '"' 'tolower($0) ~ /distrib_description/{print $2}' /etc/lsb-release)"
  [[ -z "$SYS" && -s /etc/redhat-release ]] && SYS="$(cat /etc/redhat-release)"
  [[ -z "$SYS" && -s /etc/issue ]] && SYS="$(sed -E '/^$|^\\/d' /etc/issue | awk -F '\\' '{print $1}' | sed 's/[ ]*$//g')"

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky" "arch linux" "alpine" "fedora")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Arch" "Alpine" "Fedora")
  EXCLUDE=("---")
  MAJOR=("9" "16" "7" "" "" "37")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "pacman -Sy" "apk update -f" "dnf -y update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "pacman -S --noconfirm" "apk add --no-cache" "dnf -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "pacman -Rcnsu --noconfirm" "apk del -f" "dnf -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done
  [ -z "$SYSTEM" ] && error " $(text 5) "

  # 针对各厂商的订制系统
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  # 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
  for ex in "${EXCLUDE[@]}"; do [[ ! "{$SYS,,}" =~ $ex ]]; done &&
  [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text 6) "

  # 针对部分系统作特殊处理
  ARGO_DAEMON_FILE='/etc/systemd/system/argo.service'; XRAY_DAEMON_FILE='/etc/systemd/system/xray.service'; DAEMON_RUN_PATTERN="ExecStart="
  if [ "$SYSTEM" = 'CentOS' ]; then
    IS_CENTOS="CentOS$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)"
  elif [ "$SYSTEM" = 'Alpine' ]; then
    ARGO_DAEMON_FILE='/etc/init.d/argo'; XRAY_DAEMON_FILE='/etc/init.d/xray'; DAEMON_RUN_PATTERN="command_args="
  fi
}

# 检测 IPv4 IPv6 信息
check_system_ip() {
  [ "$L" = 'C' ] && local IS_CHINESE='?lang=zh-CN'
  local DEFAULT_LOCAL_INTERFACE4=$(ip -4 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
  local DEFAULT_LOCAL_INTERFACE6=$(ip -6 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
  if [ -n "${DEFAULT_LOCAL_INTERFACE4}${DEFAULT_LOCAL_INTERFACE6}" ]; then
    local DEFAULT_LOCAL_IP4=$(ip -4 addr show $DEFAULT_LOCAL_INTERFACE4 | sed -n 's#.*inet \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
    local DEFAULT_LOCAL_IP6=$(ip -6 addr show $DEFAULT_LOCAL_INTERFACE6 | sed -n 's#.*inet6 \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
    [ -n "$DEFAULT_LOCAL_IP4" ] && local BIND_ADDRESS4="--bind-address=$DEFAULT_LOCAL_IP4"
    [ -n "$DEFAULT_LOCAL_IP6" ] && local BIND_ADDRESS6="--bind-address=$DEFAULT_LOCAL_IP6"
  fi

  WAN4=$(wget $BIND_ADDRESS4 -qO- --no-check-certificate --tries=2 --timeout=2 http://api-ipv4.ip.sb)
  [ -n "$WAN4" ] && local IP4_JSON=$(wget -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.forvps.gq/${WAN4}${IS_CHINESE}) &&
  COUNTRY4=$(sed -En 's/.*"country":[ ]*"([^"]+)".*/\1/p' <<< "$IP4_JSON") &&
  ASNORG4=$(sed -En 's/.*"(isp|asn_org)":[ ]*"([^"]+)".*/\2/p' <<< "$IP4_JSON")

  WAN6=$(wget $BIND_ADDRESS6 -qO- --no-check-certificate --tries=2 --timeout=2 http://api-ipv6.ip.sb)
  [ -n "$WAN6" ] && local IP6_JSON=$(wget -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.forvps.gq/${WAN6}${IS_CHINESE}) &&
  COUNTRY6=$(sed -En 's/.*"country":[ ]*"([^"]+)".*/\1/p' <<< "$IP6_JSON") &&
  ASNORG6=$(sed -En 's/.*"(isp|asn_org)":[ ]*"([^"]+)".*/\2/p' <<< "$IP6_JSON")
}

# 定义 Argo 变量
argo_variable() {
  ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [[ -z "$INSTALL_NGINX" && ! -d $WORK_DIR ]] && reading "\n $(text 68) " INSTALL_NGINX
  INSTALL_NGINX=${INSTALL_NGINX:-"y"}
  [ "${INSTALL_NGINX,,}" != 'n' ] && check_nginx >/dev/null 2>&1 &

  if grep -qi 'cloudflare' <<< "$ASNORG4$ASNORG6"; then
    if grep -qi 'cloudflare' <<< "$ASNORG6" && [ -n "$WAN4" ] && ! grep -qi 'cloudflare' <<< "$ASNORG4"; then
      SERVER_IP_DEFAULT=$WAN4
    elif grep -qi 'cloudflare' <<< "$ASNORG4" && [ -n "$WAN6" ] && ! grep -qi 'cloudflare' <<< "$ASNORG6"; then
      SERVER_IP_DEFAULT=$WAN6
    else
      local a=6
      until [ -n "$SERVER_IP" ]; do
        ((a--)) || true
        [ "$a" = 0 ] && error "\n $(text 3) \n"
        reading "\n $(text 54) " SERVER_IP
      done
    fi
  elif [ -n "$WAN6" ]; then
    SERVER_IP_DEFAULT=$WAN6
  elif [ -n "$WAN4" ]; then
    SERVER_IP_DEFAULT=$WAN4
  fi

  # 输入服务器 IP,默认为检测到的服务器 IP，如果全部为空，则提示并退出脚本
  if [ ! -d $WORK_DIR ]; then
    ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [ -z "$SERVER_IP" ] && reading "\n $(text 59) " SERVER_IP
    SERVER_IP=${SERVER_IP:-"$SERVER_IP_DEFAULT"}
    [ -z "$SERVER_IP" ] && error " $(text 58) "

    # 检测是否解锁 chatGPT
    if [ ! -d $WORK_DIR ]; then
      [[ "$SERVER_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && CHATGPT_STACK='-4' || CHATGPT_STACK='-6'
      if [ "$(check_chatgpt ${CHATGPT_STACK})" = 'unlock' ]; then
        CHAT_GPT_OUT_V4=direct && CHAT_GPT_OUT_V6=direct
      else
        CHAT_GPT_OUT_V4=warp-IPv4 && CHAT_GPT_OUT_V6=warp-IPv6
      fi
    fi
  fi

  # 处理可能输入的错误，去掉开头和结尾的空格，去掉最后的 :
  [[ "$NONINTERACTIVE_INSTALL" != 'noninteractive_install' && -z "$ARGO_DOMAIN" ]] && reading "\n $(text 10) " ARGO_DOMAIN
  ARGO_DOMAIN=$(sed 's/[ ]*//g; s/:[ ]*//' <<< "$ARGO_DOMAIN")

  # 输入 ARGO_AUTH
  if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && [[ -n "$ARGO_DOMAIN" && -z "$ARGO_AUTH" ]]; then
    local a=5
    until [[ "$ARGO_AUTH" =~ TunnelSecret || "${ARGO_AUTH,,}" =~ ^[a-z0-9=]{120,250}$ || "${ARGO_AUTH,,}" =~ .*cloudflared.*service[[:space:]]+install[[:space:]]+[a-z0-9=]{1,100} ]]; do
      if [ "$a" = 0 ]; then
        error "\n $(text 3) \n"
      else
        [ "$a" != 5 ] && warning "\n $(text 45) \n"
        reading "\n $(text 11) " ARGO_AUTH
      fi
      ((a--)) || true
    done
  fi

  # 根据输入的 ARGO_AUTH 变量，判断是 TunnelSecret 还是 Token
  if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
    ARGO_JSON=${ARGO_AUTH//[ ]/}
  elif [[ "${ARGO_AUTH,,}" =~ .*[a-z0-9=]{120,250}$ ]]; then
    ARGO_TOKEN=$(awk '{print $NF}' <<< "$ARGO_AUTH")
  fi
}

# 端口分配函数
allocate_reality_ports() {
  local start_port=$1
  local count=$2
  local allocated_ports=()
  local current_port=$start_port
  
  for ((i=0; i<count; i++)); do
    # 检查端口是否被占用，如果被占用就递增
    while ss -nltup | grep -q ":$current_port"; do
      ((current_port++))
      # 防止端口超出范围
      [ "$current_port" -gt 65535 ] && current_port=1000
    done
    allocated_ports+=($current_port)
    ((current_port++))
  done
  
  echo "${allocated_ports[@]}"
}

# 定义 Xray 变量
xray_variable() {
  local a=6
  until [ -n "$REALITY_PORT" ]; do
    ((a--)) || true
    [ "$a" = 0 ] && error "\n $(text 3) \n"
    REALITY_PORT_DEFAULT=$(shuf -i 1000-65535 -n 1)
    ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && reading "\n $(text 56) " REALITY_PORT
    REALITY_PORT=${REALITY_PORT:-"$REALITY_PORT_DEFAULT"}
    ss -nltup | grep -q ":$REALITY_PORT" && warning "\n $(text 61) \n" && unset REALITY_PORT
  done
  
  # 分配多地区Reality端口，需要10个端口（5个地区 x 2个协议）
  REALITY_PORTS=($(allocate_reality_ports $REALITY_PORT 10))
  
  # 创建地区到端口的映射
  local port_index=0
  for region in "${!WS_PATHS[@]}"; do
    declare -g "REALITY_PORT_${region}_vision"="${REALITY_PORTS[$port_index]}"
    declare -g "REALITY_PORT_${region}_grpc"="${REALITY_PORTS[$((port_index+1))]}"
    ((port_index+=2))
  done

  # 提供网上热心网友的anycast域名
  if [ -z "$SERVER" ]; then
    if ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL"; then
      echo ""
      for c in "${!CDN_DOMAIN[@]}"; do
        hint " $[c+1]. ${CDN_DOMAIN[c]} "
      done

      reading "\n $(text 42) " CUSTOM_CDN
    fi
    case "$CUSTOM_CDN" in
      [1-${#CDN_DOMAIN[@]}] )
        SERVER="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}"
      ;;
      ?????* )
        SERVER="$CUSTOM_CDN"
      ;;
      * )
        SERVER="${CDN_DOMAIN[0]}"
    esac
  fi

  local a=6
  until [[ "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; do
    (( a-- )) || true
    [ "$a" = 0 ] && error "\n $(text 3) \n"
    UUID_DEFAULT=$(cat /proc/sys/kernel/random/uuid)
    ! grep -q 'noninteractive_install' <<< "$NONINTERACTIVE_INSTALL" && reading "\n $(text 12) " UUID
    UUID=${UUID:-"$UUID_DEFAULT"}
    [[ ! "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]] && warning "\n $(text 4) "
  done

  # 不再询问路径，使用预定义的多个路径
  # WS_PATH 将在生成配置时处理多个路径

  # 直接使用默认节点名，不再询问用户输入
  if [ -z "$NODE_NAME" ]; then
    if [ -x "$(type -p hostname)" ]; then
      NODE_NAME="$(hostname)"
    elif [ -s /etc/hostname ]; then
      NODE_NAME="$(cat /etc/hostname)"
    else
      NODE_NAME="ArgoX"
    fi
  fi
}

check_dependencies() {
  # 如果是 Alpine，先升级 wget
  if [ "$SYSTEM" = 'Alpine' ]; then
    local CHECK_WGET=$(wget 2>&1 | head -n 1)
    grep -qi 'busybox' <<< "$CHECK_WGET" && ${PACKAGE_INSTALL[int]} wget >/dev/null 2>&1

    # Alpine 系统只检查必要的依赖，不需要 systemctl 和 python3
    local DEPS_CHECK=("bash" "rc-update" "virt-what")
    local DEPS_INSTALL=("bash" "openrc" "virt-what")
    for g in "${!DEPS_CHECK[@]}"; do
      [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS_ALPINE+=(${DEPS_INSTALL[g]})
    done
    if [ "${#DEPS_ALPINE[@]}" -ge 1 ]; then
      info "\n $(text 7) $(sed "s/ /,&/g" <<< ${DEPS_ALPINE[@]}) \n"
      ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
      ${PACKAGE_INSTALL[int]} ${DEPS_ALPINE[@]} >/dev/null 2>&1
      [[ -z "$VIRT" && "${DEPS_ALPINE[@]}" =~ 'virt-what' ]] && VIRT=$(virt-what | tr '\n' ' ')
    fi
  fi

  # 检测 Linux 系统的依赖，升级库并重新安装依赖
  # 所有系统都需要的基本依赖
  local DEPS_CHECK=("wget" "ss" "unzip" "bash")
  local DEPS_INSTALL=("wget" "iproute2" "unzip" "bash")

  # 非 Alpine 系统额外需要 systemctl
  [ "$SYSTEM" != 'Alpine' ] && DEPS_CHECK+=("systemctl") && DEPS_INSTALL+=("systemctl")

  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS+=(${DEPS_INSTALL[g]})
  done
  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 7) $(sed "s/ /,&/g" <<< ${DEPS[@]}) \n"
    [ "$SYSTEM" != 'CentOS' ] && ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
  else
    info "\n $(text 8) \n"
  fi

  # 不需要 nginx 原来的服务
  [[ "${DEPS[@]}" =~ 'nginx' ]] && cmd_systemctl disable nginx >/dev/null 2>&1
}

# 检测本地代理端口是否被占用，如果被占用自动寻找下一个可用端口
check_local_proxy_port() {
  local original_port=$LOCAL_PROXY_PORT
  while ss -nltup | grep -q ":$LOCAL_PROXY_PORT"; do
    warning "端口 $LOCAL_PROXY_PORT 已被占用，正在寻找下一个可用端口..."
    ((LOCAL_PROXY_PORT++))
    # 防止端口超出范围
    [ "$LOCAL_PROXY_PORT" -gt 65535 ] && LOCAL_PROXY_PORT=8081
    # 避免无限循环
    [ "$LOCAL_PROXY_PORT" -eq "$original_port" ] && error "无法找到可用端口，请检查系统配置"
  done
  [ "$LOCAL_PROXY_PORT" != "$original_port" ] && info "已将本地代理端口从 $original_port 更改为 $LOCAL_PROXY_PORT"
}

# 检查并安装 nginx
check_nginx() {
  if [ ! -x "$(type -p nginx)" ]; then
    info "\n $(text 7) nginx \n"
    ${PACKAGE_INSTALL[int]} nginx >/dev/null 2>&1
    # 如果新安装的 Nginx ，先停掉服务
    [ "$SYSTEM" != 'Alpine' ] && systemctl disable --now nginx >/dev/null 2>&1
  fi
}

# 处理防火墙规则
firewall_configuration() {
  # 获取所有Reality端口
  local REALITY_PORTS=($(awk -F [:,] '/"port"/{print $2}' $WORK_DIR/inbound.json | sort -n | uniq))
  
  if grep -q "open" <<< "$1"; then
    for port in "${REALITY_PORTS[@]}"; do
      firewall-cmd --zone=public --add-port=${port}/tcp --permanent >/dev/null 2>&1
    done
  elif grep -q "close" <<< "$1"; then
    for port in "${REALITY_PORTS[@]}"; do
      firewall-cmd --zone=public --remove-port=${port}/tcp --permanent >/dev/null 2>&1
    done
  fi
  firewall-cmd --reload >/dev/null 2>&1

  if [[ -s /etc/selinux/config && -x "$(type -p getenforce)" && $(getenforce) = 'Enforcing' ]]; then
    hint "\n $(text 69) "
    setenforce 0
    grep -qs '^SELINUX=disabled$' /etc/selinux/config || sed -i 's/^SELINUX=[epd].*/# &/; /SELINUX=[epd]/a\SELINUX=disabled' /etc/selinux/config
  fi
}

# Nginx 配置文件
json_nginx() {
  if [ -s $WORK_DIR/*inbound*.json ]; then
    JSON=$(cat $WORK_DIR/*inbound*.json)
    SERVER_IP=${SERVER_IP:-"$(awk -F '"' '/"SERVER_IP"/{print $4}' <<< "$JSON")"}
    UUID=$(awk -F '"' '/"password"/{print $4; exit}' <<< "$JSON")
  fi

  [[ "$SERVER_IP" =~ : ]] && REVERSE_IP="[$SERVER_IP]" || REVERSE_IP="$SERVER_IP"
  cat > $WORK_DIR/nginx.conf << EOF
user  root;
worker_processes  auto;

error_log  /dev/null;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
  map \$http_user_agent \$path {
    default                    /;                # 默认路径
    ~*v2rayN|Neko              /base64;          # 匹配 V2rayN / NekoBox 客户端
    ~*clash                    /clash;           # 匹配 Clash 客户端
    ~*ShadowRocket             /shadowrocket;    # 匹配 ShadowRocket  客户端
    ~*SFM                      /sing-box-pc;     # 匹配 Sing-box pc 客户端
    ~*SFI|SFA                  /sing-box-phone;  # 匹配 Sing-box phone 客户端
 #   ~*Chrome|Firefox|Mozilla  /;                # 添加更多的分流规则
  }

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /dev/null;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    #include /etc/nginx/conf.d/*.conf;

  server {
    listen 127.0.0.1:3006 proxy_protocol; # xray fallbacks

    # 来自 /auto 的分流
    location ~ ^/${UUID}/auto {
      default_type 'text/plain; charset=utf-8';
      alias ${WORK_DIR}/subscribe/\$path;
    }

    location ~ ^/${UUID}/(.*) {
      autoindex on;
      proxy_set_header X-Real-IP \$proxy_protocol_addr;
      default_type 'text/plain; charset=utf-8';
      alias ${WORK_DIR}/subscribe/\$1;
    }
  }
}
EOF
}

# Json 生成两个配置文件
json_argo() {
  [ ! -s $WORK_DIR/tunnel.json ] && echo $ARGO_JSON > $WORK_DIR/tunnel.json
  [ ! -s $WORK_DIR/tunnel.yml ] && cat > $WORK_DIR/tunnel.yml << EOF
tunnel: $(cut -d\" -f12 <<< $ARGO_JSON)
credentials-file: $WORK_DIR/tunnel.json

ingress:
  - hostname: ${ARGO_DOMAIN}
    service: http://localhost:${LOCAL_PROXY_PORT}
  - service: http_status:404
EOF
}

install_argox() {
  argo_variable
  xray_variable
  
  # 检测本地代理端口是否被占用
  check_local_proxy_port

  wait
  # 生成 reality 的公私钥
  [[ -z "$REALITY_PRIVATE" || -z "$REALITY_PUBLIC" ]] && REALITY_KEYPAIR=$($TEMP_DIR/xray x25519)
  [ -z "$REALITY_PRIVATE" ] && REALITY_PRIVATE=$(awk '/Private/{print $NF}' <<< "$REALITY_KEYPAIR")
  [ -z "$REALITY_PUBLIC" ] && REALITY_PUBLIC=$(awk '/Public/{print $NF}' <<< "$REALITY_KEYPAIR")

  [ ! -d /etc/systemd/system ] && mkdir -p /etc/systemd/system
  mkdir -p $WORK_DIR/subscribe && echo "$L" > $WORK_DIR/language
  [ -s "$VARIABLE_FILE" ] && cp $VARIABLE_FILE $WORK_DIR/

  wait
  [[ ! -s $WORK_DIR/cloudflared && -x $TEMP_DIR/cloudflared ]] && mv $TEMP_DIR/cloudflared $WORK_DIR
  [[ ! -s $WORK_DIR/jq && -x $TEMP_DIR/jq ]] && mv $TEMP_DIR/jq $WORK_DIR
  [[ "$INSTALL_NGINX" != 'n' && ! -s $WORK_DIR/qrencode && -x $TEMP_DIR/qrencode ]] && mv $TEMP_DIR/qrencode $WORK_DIR
  if [[ -n "${ARGO_JSON}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
    json_argo
  elif [[ -n "${ARGO_TOKEN}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}"
  else
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url http://localhost:${LOCAL_PROXY_PORT}"
  fi

  # Argo 生成守护进程文件
  if [ "$SYSTEM" = 'Alpine' ]; then
    # 分离命令和参数
    local COMMAND=${ARGO_RUNS%% --*}  # 提取命令部分（包括 cloudflared tunnel）
    local ARGS=${ARGO_RUNS#$COMMAND }  # 提取参数部分

    # 为 Alpine 创建 OpenRC 服务文件
    cat > ${ARGO_DAEMON_FILE} << EOF
#!/sbin/openrc-run

name="argo"
description="Cloudflare Tunnel"
command="${COMMAND}"
command_args="${ARGS}"
pidfile="/var/run/\${RC_SVCNAME}.pid"
command_background="yes"
output_log="$WORK_DIR/argo.log"
error_log="$WORK_DIR/argo.log"

depend() {
    need net
    after net
}

start_pre() {
    # 确保日志目录存在
    mkdir -p $WORK_DIR

    # 如果需要启动 nginx
    if [ -s $WORK_DIR/nginx.conf ]; then
        $(type -p nginx) -c $WORK_DIR/nginx.conf
    fi
}

stop_post() {
    # 停止服务时检查并关闭相关的 nginx 进程
    if [ -s $WORK_DIR/nginx.conf ]; then
        # 查找使用我们配置文件的 nginx 进程并停止它
        local NGINX_PIDS=\$(ps -ef | awk -v work_dir="$WORK_DIR" '{if (\$0 ~ "nginx.*" work_dir "/nginx.conf") print \$1}')
        [ -n "\$NGINX_PIDS" ] && echo " * Stopping nginx processes: \$NGINX_PIDS" && kill -15 \$NGINX_PIDS 2>/dev/null
    fi
}
EOF
    chmod +x ${ARGO_DAEMON_FILE}

    # 为 Xray 创建 OpenRC 服务文件
    cat > ${XRAY_DAEMON_FILE} << EOF
#!/sbin/openrc-run

name="xray"
description="Xray Service"
command="$WORK_DIR/xray"
command_args="run -c $WORK_DIR/inbound.json -c $WORK_DIR/outbound.json"
pidfile="/var/run/\${RC_SVCNAME}.pid"
command_background="yes"
output_log="$WORK_DIR/xray.log"
error_log="$WORK_DIR/xray.log"

depend() {
    need net
    after net
}
EOF
    chmod +x ${XRAY_DAEMON_FILE}
  else
    # 非 Alpine 系统使用 systemd
    local ARGO_SERVER="[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0"
    [[ "$INSTALL_NGINX" != 'n' && "$IS_CENTOS" != 'CentOS7' ]] && ARGO_SERVER+="
ExecStartPre=$(type -p nginx) -c $WORK_DIR/nginx.conf"
    ARGO_SERVER+="
ExecStart=$ARGO_RUNS
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target"

    echo "$ARGO_SERVER" > ${ARGO_DAEMON_FILE}

    # 创建 Xray systemd 服务文件
    cat > ${XRAY_DAEMON_FILE} << EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target

[Service]
User=root
ExecStart=$WORK_DIR/xray run -c $WORK_DIR/inbound.json -c $WORK_DIR/outbound.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF
  fi

  # 生成配置文件及守护进程文件
  local i=1
  [ ! -s $WORK_DIR/xray ] && wait && while [ "$i" -le 20 ]; do [[ -s $TEMP_DIR/xray && -s $TEMP_DIR/geoip.dat && -s $TEMP_DIR/geosite.dat ]] && mv $TEMP_DIR/xray $TEMP_DIR/geo*.dat $WORK_DIR && break; ((i++)); sleep 2; done
  [ "$i" -ge 20 ] && local APP=Xray && error "\n $(text 48) "
  # 生成多地区Reality节点配置
  REALITY_INBOUNDS=""
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local vision_port_var="REALITY_PORT_${region}_vision"
    local grpc_port_var="REALITY_PORT_${region}_grpc"
    local vision_port="${!vision_port_var}"
    local grpc_port="${!grpc_port_var}"
    
    # Vision Reality节点
    REALITY_INBOUNDS+="{
            \"tag\":\"${region_name}-Reality-Vision-${NODE_NAME}\",
            \"protocol\":\"vless\",
            \"port\":${vision_port},
            \"settings\":{
                \"clients\":[
                    {
                        \"id\":\"${UUID}\",
                        \"flow\":\"xtls-rprx-vision\"
                    }
                ],
                \"decryption\":\"none\"
            },
            \"streamSettings\":{
                \"network\":\"tcp\",
                \"security\":\"reality\",
                \"realitySettings\":{
                    \"show\":true,
                    \"dest\":\"${TLS_SERVER}:443\",
                    \"xver\":0,
                    \"serverNames\":[
                        \"${TLS_SERVER}\"
                    ],
                    \"privateKey\":\"${REALITY_PRIVATE}\",
                    \"publicKey\":\"${REALITY_PUBLIC}\",
                    \"maxTimeDiff\":70000,
                    \"shortIds\":[
                        \"\"
                    ]
                }
            },
            \"sniffing\":{
                \"enabled\":true,
                \"destOverride\":[
                    \"http\",
                    \"tls\"
                ]
            }
        },
        {
            \"port\":${grpc_port},
            \"protocol\":\"vless\",
            \"tag\":\"${region_name}-Reality-gRPC-${NODE_NAME}\",
            \"settings\":{
                \"clients\":[
                    {
                        \"id\":\"${UUID}\",
                        \"flow\":\"\"
                    }
                ],
                \"decryption\":\"none\"
            },
            \"streamSettings\":{
                \"network\":\"grpc\",
                \"security\":\"reality\",
                \"realitySettings\":{
                    \"show\":true,
                    \"dest\":\"${TLS_SERVER}:443\",
                    \"xver\":0,
                    \"serverNames\":[
                        \"${TLS_SERVER}\"
                    ],
                    \"privateKey\":\"${REALITY_PRIVATE}\",
                    \"publicKey\":\"${REALITY_PUBLIC}\",
                    \"maxTimeDiff\":70000,
                    \"shortIds\":[
                        \"\"
                    ]
                },
                \"grpcSettings\":{
                    \"serviceName\":\"grpc\",
                    \"multiMode\":true
                }
            },
            \"sniffing\":{
                \"enabled\":true,
                \"destOverride\":[
                    \"http\",
                    \"tls\"
                ]
            }
        },"
  done
  
  # 去掉最后的逗号
  REALITY_INBOUNDS=${REALITY_INBOUNDS%,}
  
  cat > $WORK_DIR/inbound.json << EOF
//  "SERVER_IP":"${SERVER_IP}"
//  "REALITY_PUBLIC":"${REALITY_PUBLIC}"
//  "SERVER":"${SERVER}"
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        ${REALITY_INBOUNDS},
        {
            "listen":"127.0.0.1",
            "port":${LOCAL_PROXY_PORT},
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "path":"/hk-vl",
                        "dest":3002
                    },
                    {
                        "path":"/sg-vl",
                        "dest":3007
                    },
                    {
                        "path":"/jp-vl",
                        "dest":3012
                    },
                    {
                        "path":"/tw-vl",
                        "dest":3017
                    },
                    {
                        "path":"/vn-vl",
                        "dest":3022
                    },
                    {
                        "path":"/hk-vm",
                        "dest":3003
                    },
                    {
                        "path":"/sg-vm",
                        "dest":3008
                    },
                    {
                        "path":"/jp-vm",
                        "dest":3013
                    },
                    {
                        "path":"/tw-vm",
                        "dest":3018
                    },
                    {
                        "path":"/vn-vm",
                        "dest":3023
                    },
                    {
                        "path":"/hk-tr",
                        "dest":3004
                    },
                    {
                        "path":"/sg-tr",
                        "dest":3009
                    },
                    {
                        "path":"/jp-tr",
                        "dest":3014
                    },
                    {
                        "path":"/tw-tr",
                        "dest":3019
                    },
                    {
                        "path":"/vn-tr",
                        "dest":3024
                    },
                    {
                        "path":"/hk-sh",
                        "dest":3005
                    },
                    {
                        "path":"/sg-sh",
                        "dest":3010
                    },
                    {
                        "path":"/jp-sh",
                        "dest":3015
                    },
                    {
                        "path":"/tw-sh",
                        "dest":3020
                    },
                    {
                        "path":"/vn-sh",
                        "dest":3025
                    },
                    {
                        "dest":3006,
                        "alpn": "",
                        "xver": 1
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":3002,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "tag":"hk-vl",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/hk-vl"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3003,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "tag":"hk-vm",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/hk-vm"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3004,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "tag":"hk-tr",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/hk-tr"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3005,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "tag":"hk-sh",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/hk-sh"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3007,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "tag":"sg-vl",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/sg-vl"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3008,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "tag":"sg-vm",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/sg-vm"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3009,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "tag":"sg-tr",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/sg-tr"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3010,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "tag":"sg-sh",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/sg-sh"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3012,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "tag":"jp-vl",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/jp-vl"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3013,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "tag":"jp-vm",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/jp-vm"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3014,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "tag":"jp-tr",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/jp-tr"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3015,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "tag":"jp-sh",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/jp-sh"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3017,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "tag":"tw-vl",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/tw-vl"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3018,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "tag":"tw-vm",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/tw-vm"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3019,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "tag":"tw-tr",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/tw-tr"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3020,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "tag":"tw-sh",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/tw-sh"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3022,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "tag":"vn-vl",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/vn-vl"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3023,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "tag":"vn-vm",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/vn-vm"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3024,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "tag":"vn-tr",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/vn-tr"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3025,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "tag":"vn-sh",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/vn-sh"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    }
}
EOF
  cat > $WORK_DIR/outbound.json << EOF
{
    "outbounds":[
        {
            "protocol":"freedom",
            "tag":"direct"
        },
        {
            "protocol":"blackhole",
            "settings":{

            },
            "tag":"block"
        },
        {
            "protocol":"socks",
            "settings":{
                "servers":[
                    {
                        "address":"2a14:67c0:116::1",
                        "port":20000,
                        "users":[
                            {
                                "user":"alice",
                                "pass":"alicefofo123..OVO"
                            }
                        ]
                    }
                ]
            },
            "tag":"socks5-hk"
        },
        {
            "protocol":"socks",
            "settings":{
                "servers":[
                    {
                        "address":"2a14:67c0:116::1",
                        "port":10001,
                        "users":[
                            {
                                "user":"alice",
                                "pass":"alicefofo123..OVO"
                            }
                        ]
                    }
                ]
            },
            "tag":"socks5-sg"
        },
        {
            "protocol":"socks",
            "settings":{
                "servers":[
                    {
                        "address":"2a14:67c0:116::1",
                        "port":50000,
                        "users":[
                            {
                                "user":"alice",
                                "pass":"alicefofo123..OVO"
                            }
                        ]
                    }
                ]
            },
            "tag":"socks5-jp"
        },
        {
            "protocol":"socks",
            "settings":{
                "servers":[
                    {
                        "address":"2a14:67c0:116::1",
                        "port":30000,
                        "users":[
                            {
                                "user":"alice",
                                "pass":"alicefofo123..OVO"
                            }
                        ]
                    }
                ]
            },
            "tag":"socks5-tw"
        },
        {
            "protocol":"socks",
            "settings":{
                "servers":[
                    {
                        "address":"2a14:67c0:116::1",
                        "port":40000,
                        "users":[
                            {
                                "user":"alice",
                                "pass":"alicefofo123..OVO"
                            }
                        ]
                    }
                ]
            },
            "tag":"socks5-vn"
        },
        {
            "protocol":"wireguard",
            "settings":{
                "secretKey":"YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
                "address":[
                    "172.16.0.2/32",
                    "2606:4700:110:8a36:df92:102a:9602:fa18/128"
                ],
                "peers":[
                    {
                        "publicKey":"bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "allowedIPs":[
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint":"engage.cloudflareclient.com:2408"
                    }
                ],
                "reserved":[
                    78,
                    135,
                    76
                ],
                "mtu":1280
            },
            "tag":"wireguard"
        },
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv4"
            },
            "proxySettings":{
                "tag":"wireguard"
            },
            "tag":"warp-IPv4"
        },
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv6"
            },
            "proxySettings":{
                "tag":"wireguard"
            },
            "tag":"warp-IPv6"
        }
    ],
    "routing":{
        "domainStrategy":"AsIs",
        "rules":[
            {
                "type":"field",
                "inboundTag":["hk-vl","hk-vm","hk-tr","hk-sh","🇭🇰香港-Reality-Vision-${NODE_NAME}","🇭🇰香港-Reality-gRPC-${NODE_NAME}"],
                "outboundTag":"socks5-hk"
            },
            {
                "type":"field",
                "inboundTag":["sg-vl","sg-vm","sg-tr","sg-sh","🇸🇬新加坡-Reality-Vision-${NODE_NAME}","🇸🇬新加坡-Reality-gRPC-${NODE_NAME}"],
                "outboundTag":"socks5-sg"
            },
            {
                "type":"field",
                "inboundTag":["jp-vl","jp-vm","jp-tr","jp-sh","🇯🇵日本-Reality-Vision-${NODE_NAME}","🇯🇵日本-Reality-gRPC-${NODE_NAME}"],
                "outboundTag":"socks5-jp"
            },
            {
                "type":"field",
                "inboundTag":["tw-vl","tw-vm","tw-tr","tw-sh","🇹🇼台湾-Reality-Vision-${NODE_NAME}","🇹🇼台湾-Reality-gRPC-${NODE_NAME}"],
                "outboundTag":"socks5-tw"
            },
            {
                "type":"field",
                "inboundTag":["vn-vl","vn-vm","vn-tr","vn-sh","🇻🇳越南-Reality-Vision-${NODE_NAME}","🇻🇳越南-Reality-gRPC-${NODE_NAME}"],
                "outboundTag":"socks5-vn"
            },
            {
                "type":"field",
                "domain":[
                    "api.openai.com"
                ],
                "outboundTag":"${CHAT_GPT_OUT_V4}"
            },
            {
                "type":"field",
                "domain":[
                    "geosite:openai"
                ],
                "outboundTag":"${CHAT_GPT_OUT_V6}"
            }
        ]
    }
}
EOF

  # 生成 Nginx 配置文件
  [ "$INSTALL_NGINX" != 'n' ] && json_nginx

  # 再次检测状态，运行 Argo 和 Xray
  check_install
  case "${STATUS[0]}" in
    "$(text 26)" )
      warning "\n Argo $(text 28) $(text 38) \n"
      ;;
    "$(text 27)" )
      cmd_systemctl enable argo
      cmd_systemctl status argo &>/dev/null && info "\n Argo $(text 28) $(text 37) \n" || warning "\n Argo $(text 28) $(text 38) \n"
      ;;
    "$(text 28)" )
      info "\n Argo $(text 28) $(text 37) \n"
  esac

  case "${STATUS[1]}" in
    "$(text 26)" )
      warning "\n Xray $(text 28) $(text 38) \n"
      ;;
    "$(text 27)" )
      cmd_systemctl enable xray
      cmd_systemctl status xray &>/dev/null && info "\n Xray $(text 28) $(text 37) \n" || warning "\n Xray $(text 28) $(text 38) \n"
      ;;
    "$(text 28)" )
      info "\n Xray $(text 28) $(text 37) \n"
  esac
}

# 创建快捷方式
create_shortcut() {
  cat > $WORK_DIR/ax.sh << EOF
#!/usr/bin/env bash

bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/wuzf/ArgoXForAlice/main/argox.sh) \$1
EOF
  chmod +x $WORK_DIR/ax.sh
  ln -sf $WORK_DIR/ax.sh /usr/bin/argox

  # 如果 /usr/bin 不在 PATH 中，添加到 ~/.bashrc
  if [[ ! ":$PATH:" == *":/usr/bin:"* ]]; then
    echo 'export PATH=$PATH:/usr/bin' >> ~/.bashrc
    source ~/.bashrc
  fi

  [ -s /usr/bin/argox ] && hint "\n $(text 62) "
}

export_list() {
  check_install

  # 没有开启 Argo 和 Xray 服务，将不输出节点信息
  local APP
  [ "${STATUS[0]}" != "$(text 28)" ] && APP+=(Argo)
  [ "${STATUS[1]}" != "$(text 28)" ] && APP+=(Xray)
  if [ "${#APP[@]}" -gt 0 ]; then
    reading "\n $(text 50) " OPEN_APP
    if [ "${OPEN_APP,,}" = 'y' ]; then
      [ "${STATUS[0]}" != "$(text 28)" ] && cmd_systemctl enable argo
      [ "${STATUS[1]}" != "$(text 28)" ] && cmd_systemctl enable xray
    else
      exit
    fi
  fi

  if grep -qs "^${DAEMON_RUN_PATTERN}.*:${LOCAL_PROXY_PORT}" ${ARGO_DAEMON_FILE}; then
    local a=5
    until [[ -n "$ARGO_DOMAIN" || "$a" = 0 ]]; do
      sleep 2
      ARGO_DOMAIN=$(wget -qO- http://localhost:${METRICS_PORT}/quicktunnel | awk -F '"' '{print $4}')
      ((a--)) || true
    done
  else
    ARGO_DOMAIN=${ARGO_DOMAIN:-"$(grep -m1 '^vless.*host=.*' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")"}
  fi
  JSON=$(cat $WORK_DIR/*inbound*.json)
  SERVER_IP=${SERVER_IP:-"$(awk -F '"' '/"SERVER_IP"/{print $4; exit}' <<< "$JSON")"}
  # 获取最小的Reality端口作为起始端口
  REALITY_PORT=${REALITY_PORT:-"$(awk -F '[:,]' '/"port"/{print $2}' <<< "$JSON" | sort -n | head -1)"}
  REALITY_PUBLIC=${REALITY_PUBLIC:-"$(awk -F '"' '/"publicKey"/{print $4; exit}' <<< "$JSON")"}
  REALITY_PRIVATE=${REALITY_PRIVATE:-"$(awk -F '"' '/"privateKey"/{print $4; exit}' <<< "$JSON")"}
  TLS_SERVER=${TLS_SERVER:-"$(awk -F '"' '/"server_name"/{print $4}' <<< "$JSON")"}
  SERVER=${SERVER:-"$(awk -F '"' '/"SERVER"/{print $4; exit}' <<< "$JSON")"}
  UUID=${UUID:-"$(awk -F '"' '/"password"/{print $4; exit}' <<< "$JSON")"}
  NODE_NAME=${NODE_NAME:-"$(sed -n 's/.*tag":".*-Reality-Vision-\(.*\)".*/\1/gp' <<< "$JSON" | head -1)"}
  SS_METHOD=${SS_METHOD:-"$(awk -F '"' '/"method"/{print $4; exit}' <<< "$JSON")"}

  # 重新设置各地区Reality端口变量 - 使用更可靠的方法
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    
    # 使用多种方法尝试提取端口
    local vision_port=""
    local grpc_port=""
    
    # 方法1: 尝试使用jq提取端口（如果可用且JSON有效）
    if [ -x "$WORK_DIR/jq" ]; then
      # 测试JSON是否有效
      if echo "$JSON" | $WORK_DIR/jq . >/dev/null 2>&1; then
        vision_port=$(echo "$JSON" | $WORK_DIR/jq -r ".inbounds[] | select(.tag==\"${region_name}-Reality-Vision-${NODE_NAME}\") | .port" 2>/dev/null)
        grpc_port=$(echo "$JSON" | $WORK_DIR/jq -r ".inbounds[] | select(.tag==\"${region_name}-Reality-gRPC-${NODE_NAME}\") | .port" 2>/dev/null)
        
        # 检查jq结果是否有效
        [ "$vision_port" = "null" ] && vision_port=""
        [ "$grpc_port" = "null" ] && grpc_port=""
        
        # 如果jq找不到节点，尝试更宽松的匹配
        if [ -z "$grpc_port" ]; then
          grpc_port=$(echo "$JSON" | $WORK_DIR/jq -r ".inbounds[] | select(.tag | contains(\"Reality-gRPC\") and contains(\"${NODE_NAME}\") and contains(\"${region_name}\")) | .port" 2>/dev/null)
          [ "$grpc_port" = "null" ] && grpc_port=""
        fi
        
        if [ -z "$vision_port" ]; then
          vision_port=$(echo "$JSON" | $WORK_DIR/jq -r ".inbounds[] | select(.tag | contains(\"Reality-Vision\") and contains(\"${NODE_NAME}\") and contains(\"${region_name}\")) | .port" 2>/dev/null)
          [ "$vision_port" = "null" ] && vision_port=""
        fi
      fi
    fi
    
    # 方法2: 如果jq方法失败，使用简单的grep+awk组合
    if [ -z "$vision_port" ]; then
      # 尝试精确匹配
      vision_port=$(echo "$JSON" | grep -A 10 "\"tag\":\"${region_name}-Reality-Vision-${NODE_NAME}\"" | grep "\"port\"" | head -1 | awk -F'[:]' '{print $2}' | tr -d ' ,"' | grep -o '[0-9]*')
      
      # 如果精确匹配失败，尝试宽松匹配
      if [ -z "$vision_port" ]; then
        vision_port=$(echo "$JSON" | grep -A 10 "Reality-Vision.*${NODE_NAME}" | grep "\"port\"" | head -1 | awk -F'[:]' '{print $2}' | tr -d ' ,"' | grep -o '[0-9]*')
      fi
    fi
    
    if [ -z "$grpc_port" ]; then
      # 尝试精确匹配
      grpc_port=$(echo "$JSON" | grep -A 10 "\"tag\":\"${region_name}-Reality-gRPC-${NODE_NAME}\"" | grep "\"port\"" | head -1 | awk -F'[:]' '{print $2}' | tr -d ' ,"' | grep -o '[0-9]*')
      
      # 如果精确匹配失败，尝试宽松匹配
      if [ -z "$grpc_port" ]; then
        grpc_port=$(echo "$JSON" | grep -A 10 "Reality-gRPC.*${NODE_NAME}" | grep "\"port\"" | head -1 | awk -F'[:]' '{print $2}' | tr -d ' ,"' | grep -o '[0-9]*')
      fi
    fi
    
    # 方法3: 如果仍然失败，尝试直接从文件中按行解析
    if [ -z "$vision_port" ]; then
      vision_port=$(grep -A 20 "\"tag\":\"${region_name}-Reality-Vision-${NODE_NAME}\"" $WORK_DIR/inbound.json 2>/dev/null | grep "\"port\"" | head -1 | sed 's/.*"port"[[:space:]]*:[[:space:]]*\([0-9]\+\).*/\1/')
      
      # 如果仍然失败，尝试按端口顺序推算（Vision应该是奇数端口）
      if [ -z "$vision_port" ]; then
        # 根据地区顺序计算端口：vn(0), sg(1), hk(2), tw(3), jp(4) -> base_port + region_index * 2
        case "$region" in
          "vn") vision_port=$(awk '/Reality.*Vision.*'"${NODE_NAME}"'/{found=1} found && /port/{print $2; exit}' $WORK_DIR/inbound.json | tr -d ',' | head -1) ;;
          "sg") local base_port=$(awk '/Reality.*Vision.*'"${NODE_NAME}"'/{found=1} found && /port/{print $2; exit}' $WORK_DIR/inbound.json | tr -d ',' | head -1)
                [ -n "$base_port" ] && vision_port=$((base_port + 2)) ;;
          "hk") local base_port=$(awk '/Reality.*Vision.*'"${NODE_NAME}"'/{found=1} found && /port/{print $2; exit}' $WORK_DIR/inbound.json | tr -d ',' | head -1)
                [ -n "$base_port" ] && vision_port=$((base_port + 4)) ;;
          "tw") local base_port=$(awk '/Reality.*Vision.*'"${NODE_NAME}"'/{found=1} found && /port/{print $2; exit}' $WORK_DIR/inbound.json | tr -d ',' | head -1)
                [ -n "$base_port" ] && vision_port=$((base_port + 6)) ;;
          "jp") local base_port=$(awk '/Reality.*Vision.*'"${NODE_NAME}"'/{found=1} found && /port/{print $2; exit}' $WORK_DIR/inbound.json | tr -d ',' | head -1)
                [ -n "$base_port" ] && vision_port=$((base_port + 8)) ;;
        esac
      fi
    fi
    
    if [ -z "$grpc_port" ]; then
      grpc_port=$(grep -A 20 "\"tag\":\"${region_name}-Reality-gRPC-${NODE_NAME}\"" $WORK_DIR/inbound.json 2>/dev/null | grep "\"port\"" | head -1 | sed 's/.*"port"[[:space:]]*:[[:space:]]*\([0-9]\+\).*/\1/')
      
      # 如果vision_port存在，gRPC端口应该是vision_port + 1
      if [ -z "$grpc_port" ] && [ -n "$vision_port" ] && [[ "$vision_port" =~ ^[0-9]+$ ]]; then
        grpc_port=$((vision_port + 1))
      fi
    fi
    
    # 方法4: 如果解析仍然失败，尝试使用全局变量（如果存在）
    if [ -z "$vision_port" ]; then
      local vision_var="REALITY_PORT_${region}_vision"
      vision_port="${!vision_var}"
    fi
    
    if [ -z "$grpc_port" ]; then
      local grpc_var="REALITY_PORT_${region}_grpc"
      grpc_port="${!grpc_var}"
    fi
    
    # 验证端口是否为有效数字
    if [[ ! "$vision_port" =~ ^[0-9]+$ ]] || [ "$vision_port" -lt 1 ] || [ "$vision_port" -gt 65535 ]; then
      vision_port=""
    fi
    
    if [[ ! "$grpc_port" =~ ^[0-9]+$ ]] || [ "$grpc_port" -lt 1 ] || [ "$grpc_port" -gt 65535 ]; then
      grpc_port=""
    fi
    
    # 调试信息（只在端口完全解析失败时显示）
    [ -z "$vision_port" ] && warning "Warning: Unable to get vision port for region $region_name"
    [ -z "$grpc_port" ] && warning "Warning: Unable to get grpc port for region $region_name"
    
    declare -g "REALITY_PORT_${region}_vision"="$vision_port"
    declare -g "REALITY_PORT_${region}_grpc"="$grpc_port"
  done

  # IPv6 时的 IP 处理
  if [[ "$SERVER_IP" =~ : ]]; then
    SERVER_IP_1="[$SERVER_IP]"
    SERVER_IP_2="[[$SERVER_IP]]"
  else
    SERVER_IP_1="$SERVER_IP"
    SERVER_IP_2="$SERVER_IP"
  fi

  # 若为临时隧道，处理查询方法
  grep -q 'metrics.*url' ${ARGO_DAEMON_FILE} && QUICK_TUNNEL_URL=$(text 60)

  # 生成各订阅文件
  # 生成 Clash proxy providers 订阅文件
  local CLASH_SUBSCRIBE="proxies:"
  
  # 生成多地区Reality节点
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local vision_port_var="REALITY_PORT_${region}_vision"
    local grpc_port_var="REALITY_PORT_${region}_grpc"
    local vision_port="${!vision_port_var}"
    local grpc_port="${!grpc_port_var}"
    
    # 只有当端口有效时才生成节点
    if [ -n "$vision_port" ] && [ "$vision_port" != "" ] && [ "$vision_port" != "-1" ]; then
      CLASH_SUBSCRIBE+="
  - {name: \"${region_name}-Reality-Vision-${NODE_NAME}\", type: vless, server: ${SERVER_IP}, port: ${vision_port}, uuid: ${UUID}, network: tcp, udp: true, tls: true, servername: ${TLS_SERVER}, flow: xtls-rprx-vision, client-fingerprint: chrome, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"} }"
    fi
    
    if [ -n "$grpc_port" ] && [ "$grpc_port" != "" ] && [ "$grpc_port" != "-1" ]; then
      CLASH_SUBSCRIBE+="
  - {name: \"${region_name}-Reality-gRPC-${NODE_NAME}\", type: vless, server: ${SERVER_IP}, port: ${grpc_port}, uuid: ${UUID}, network: grpc, udp: true, tls: true, servername: ${TLS_SERVER}, flow: , client-fingerprint: chrome, reality-opts: {public-key: ${REALITY_PUBLIC}, short-id: \"\"}, grpc-opts: {grpc-service-name: \"grpc\"} }"
    fi
  done

  # 按协议分组生成节点 - 先生成所有地区的vless
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    CLASH_SUBSCRIBE+="
  - {name: \"${region_name}-Vl-${NODE_NAME}\", type: vless, server: ${SERVER}, port: 443, uuid: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: {path: \"/${region}-vl\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2408, \"early_data_header_name\":\"Sec-WebSocket-Protocol\"} }"
  done

  # 生成所有地区的vmess
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    CLASH_SUBSCRIBE+="
  - {name: \"${region_name}-Vm-${NODE_NAME}\", type: vmess, server: ${SERVER}, port: 443, uuid: ${UUID}, udp: true, alterId: 0, cipher: none, tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: true, network: ws, ws-opts: {path: \"/${region}-vm\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2408, \"early_data_header_name\":\"Sec-WebSocket-Protocol\"}}"
  done

  # 生成所有地区的trojan
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    CLASH_SUBSCRIBE+="
  - {name: \"${region_name}-Tr-${NODE_NAME}\", type: trojan, server: ${SERVER}, port: 443, password: ${UUID}, udp: true, tls: true, servername: ${ARGO_DOMAIN}, sni: ${ARGO_DOMAIN}, skip-cert-verify: false, network: ws, ws-opts: { path: \"/${region}-tr\", headers: {Host: ${ARGO_DOMAIN}}, \"max_early_data\":2408, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }"
  done

  # 生成所有地区的shadowsocks
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    CLASH_SUBSCRIBE+="
  - {name: \"${region_name}-Sh-${NODE_NAME}\", type: ss, server: ${SERVER}, port: 443, cipher: ${SS_METHOD}, password: ${UUID}, udp: true, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${ARGO_DOMAIN}, path: \"/${region}-sh\", tls: true, servername: ${ARGO_DOMAIN}, skip-cert-verify: false, mux: false } }"
  done

  echo -n "${CLASH_SUBSCRIBE}" > $WORK_DIR/subscribe/proxies

  # 生成 clash 订阅配置文件
  wget --no-check-certificate -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/clash | sed "s#NODE_NAME#${NODE_NAME}#g; s#PROXY_PROVIDERS_URL#http://${ARGO_DOMAIN}/${UUID}/proxies#" > $WORK_DIR/subscribe/clash

  # 生成 Shadowrocket 订阅文件
  local SHADOWROCKET_SUBSCRIBE=""
  
  # 生成多地区Reality节点
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local vision_port_var="REALITY_PORT_${region}_vision"
    local grpc_port_var="REALITY_PORT_${region}_grpc"
    local vision_port="${!vision_port_var}"
    local grpc_port="${!grpc_port_var}"
    
    # 只有当端口有效时才生成节点
    if [ -n "$vision_port" ] && [ "$vision_port" != "" ] && [ "$vision_port" != "-1" ]; then
      SHADOWROCKET_SUBSCRIBE+="vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${vision_port}" | base64 -w0)?remarks=${region_name}-Reality-Vision-${NODE_NAME}&obfs=none&tls=1&peer=${TLS_SERVER}&xtls=2&pbk=${REALITY_PUBLIC}
"
    fi
    
    if [ -n "$grpc_port" ] && [ "$grpc_port" != "" ] && [ "$grpc_port" != "-1" ]; then
      SHADOWROCKET_SUBSCRIBE+="vless://$(echo -n "auto:${UUID}@${SERVER_IP_2}:${grpc_port}" | base64 -w0)?remarks=${region_name}-Reality-gRPC-${NODE_NAME}&path=grpc&obfs=grpc&tls=1&peer=${TLS_SERVER}&pbk=${REALITY_PUBLIC}
"
    fi
  done

  # 按协议分组生成节点 - 先生成所有地区的vless
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    SHADOWROCKET_SUBSCRIBE+="
vless://${UUID}@${SERVER}:443?encryption=none&security=tls&type=ws&host=${ARGO_DOMAIN}&path=/${region}-vl?ed=2048&sni=${ARGO_DOMAIN}#${region_name}-Vl-${NODE_NAME}"
  done

  # 生成所有地区的vmess
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    SHADOWROCKET_SUBSCRIBE+="
vmess://$(echo -n "none:${UUID}@${SERVER}:443" | base64 -w0)?remarks=${region_name}-Vm-${NODE_NAME}&obfsParam=${ARGO_DOMAIN}&path=/${region}-vm?ed=2048&obfs=websocket&tls=1&peer=${ARGO_DOMAIN}&alterId=0"
  done

  # 生成所有地区的trojan
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    SHADOWROCKET_SUBSCRIBE+="
trojan://${UUID}@${SERVER}:443?peer=${ARGO_DOMAIN}&plugin=obfs-local;obfs=websocket;obfs-host=${ARGO_DOMAIN};obfs-uri=/${region}-tr?ed=2048#${region_name}-Tr-${NODE_NAME}"
  done

  echo -n "${SHADOWROCKET_SUBSCRIBE}" | base64 -w0 > $WORK_DIR/subscribe/shadowrocket

  # 生成 V2rayN / NekoBox 订阅文件
  local V2RAYN_SUBSCRIBE=""
  
  # 生成多地区Reality节点
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local vision_port_var="REALITY_PORT_${region}_vision"
    local grpc_port_var="REALITY_PORT_${region}_grpc"
    local vision_port="${!vision_port_var}"
    local grpc_port="${!grpc_port_var}"
    
    # 只有当端口有效时才生成节点
    if [ -n "$vision_port" ] && [ "$vision_port" != "" ] && [ "$vision_port" != "-1" ]; then
      V2RAYN_SUBSCRIBE+="vless://${UUID}@${SERVER_IP_1}:${vision_port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=tcp&headerType=none#${region_name}-Reality-Vision-${NODE_NAME}
"
    fi
    
    if [ -n "$grpc_port" ] && [ "$grpc_port" != "" ] && [ "$grpc_port" != "-1" ]; then
      V2RAYN_SUBSCRIBE+="vless://${UUID}@${SERVER_IP_1}:${grpc_port}?security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&encryption=none#${region_name}-Reality-gRPC-${NODE_NAME}
"
    fi
  done

  # 按协议分组生成节点 - 先生成所有地区的vless
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    V2RAYN_SUBSCRIBE+="
vless://${UUID}@${SERVER}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${region}-vl%3Fed%3D2048#${region_name}-Vl-${NODE_NAME}"
  done

  # 生成所有地区的vmess
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local VMESS="{ \"v\": \"2\", \"ps\": \"${region_name}-Vm-${NODE_NAME}\", \"add\": \"${SERVER}\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${region}-vm?ed=2048\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"
    V2RAYN_SUBSCRIBE+="
vmess://$(echo -n "$VMESS" | base64 -w0)"
  done

  # 生成所有地区的trojan
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    V2RAYN_SUBSCRIBE+="
trojan://${UUID}@${SERVER}:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=/${region}-tr?ed%3D2048#${region_name}-Tr-${NODE_NAME}"
  done

  echo -n "${V2RAYN_SUBSCRIBE}" | base64 -w0 > $WORK_DIR/subscribe/base64

  # 生成 Sing-box 订阅文件
  local INBOUND_REPLACE=""
  local NODE_REPLACE=""
  
  # 生成多地区Reality节点
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local vision_port_var="REALITY_PORT_${region}_vision"
    local grpc_port_var="REALITY_PORT_${region}_grpc"
    local vision_port="${!vision_port_var}"
    local grpc_port="${!grpc_port_var}"
    
    # 检查端口是否有效
    if [ -n "$vision_port" ] && [ "$vision_port" != "" ] && [ -n "$grpc_port" ] && [ "$grpc_port" != "" ]; then
      if [ -n "$INBOUND_REPLACE" ]; then
        INBOUND_REPLACE+=", "
        NODE_REPLACE+=", "
      fi
      
      INBOUND_REPLACE+="{ \"type\":\"vless\", \"tag\":\"${region_name}-Reality-Vision-${NODE_NAME}\", \"server\":\"${SERVER_IP}\", \"server_port\": ${vision_port}, \"uuid\":\"${UUID}\", \"flow\":\"xtls-rprx-vision\", \"packet_encoding\":\"xudp\", \"tls\":{ \"enabled\":true, \"server_name\":\"${TLS_SERVER}\", \"utls\":{ \"enabled\":true, \"fingerprint\":\"chrome\" }, \"reality\":{ \"enabled\":true, \"public_key\":\"${REALITY_PUBLIC}\", \"short_id\":\"\" } } }, { \"type\": \"vless\", \"tag\":\"${region_name}-Reality-gRPC-${NODE_NAME}\", \"server\": \"${SERVER_IP}\", \"server_port\": ${grpc_port}, \"uuid\": \"${UUID}\", \"packet_encoding\":\"xudp\", \"tls\": { \"enabled\": true, \"server_name\": \"${TLS_SERVER}\", \"utls\": { \"enabled\": true, \"fingerprint\": \"chrome\" }, \"reality\": { \"enabled\": true, \"public_key\": \"${REALITY_PUBLIC}\", \"short_id\": \"\" } }, \"transport\": { \"type\": \"grpc\", \"service_name\": \"grpc\" } }"
      
      NODE_REPLACE+="\"${region_name}-Reality-Vision-${NODE_NAME}\", \"${region_name}-Reality-gRPC-${NODE_NAME}\""
    fi
  done

  # 按协议分组生成节点 - 先生成所有地区的vless
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    if [ -n "$INBOUND_REPLACE" ]; then
      INBOUND_REPLACE+=", "
      NODE_REPLACE+=", "
    fi
    INBOUND_REPLACE+="{ \"type\":\"vless\", \"tag\":\"${region_name}-Vl-${NODE_NAME}\", \"server\":\"${SERVER}\", \"server_port\":443, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${region}-vl\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2048, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }"
    NODE_REPLACE+="\"${region_name}-Vl-${NODE_NAME}\""
  done

  # 生成所有地区的vmess
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    if [ -n "$INBOUND_REPLACE" ]; then
      INBOUND_REPLACE+=", "
      NODE_REPLACE+=", "
    fi
    INBOUND_REPLACE+="{ \"type\":\"vmess\", \"tag\":\"${region_name}-Vm-${NODE_NAME}\", \"server\":\"${SERVER}\", \"server_port\":443, \"uuid\":\"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${region}-vm\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2048, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }"
    NODE_REPLACE+="\"${region_name}-Vm-${NODE_NAME}\""
  done

  # 生成所有地区的trojan
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    if [ -n "$INBOUND_REPLACE" ]; then
      INBOUND_REPLACE+=", "
      NODE_REPLACE+=", "
    fi
    INBOUND_REPLACE+="{ \"type\":\"trojan\", \"tag\":\"${region_name}-Tr-${NODE_NAME}\", \"server\": \"${SERVER}\", \"server_port\": 443, \"password\": \"${UUID}\", \"tls\": { \"enabled\":true, \"server_name\":\"${ARGO_DOMAIN}\", \"utls\": { \"enabled\":true, \"fingerprint\":\"chrome\" } }, \"transport\": { \"type\":\"ws\", \"path\":\"/${region}-tr\", \"headers\": { \"Host\": \"${ARGO_DOMAIN}\" }, \"max_early_data\":2048, \"early_data_header_name\":\"Sec-WebSocket-Protocol\" } }"
    NODE_REPLACE+="\"${region_name}-Tr-${NODE_NAME}\""
  done

  # 模板
  local SING_BOX_JSON1=$(wget --no-check-certificate -qO- --tries=3 --timeout=2 ${SUBSCRIBE_TEMPLATE}/sing-box1)
  
  # 只有当有有效节点时才生成Sing-box配置
  if [ -n "$INBOUND_REPLACE" ] && [ -n "$SING_BOX_JSON1" ]; then
    echo "$SING_BOX_JSON1" | sed 's#, {[^}]\+"tun-in"[^}]\+}##' | sed "s#\"<INBOUND_REPLACE>\"#$INBOUND_REPLACE#; s#\"<NODE_REPLACE>\"#$NODE_REPLACE#g" | $WORK_DIR/jq > $WORK_DIR/subscribe/sing-box-pc 2>/dev/null || echo '{"outbounds":[]}' > $WORK_DIR/subscribe/sing-box-pc
    echo "$SING_BOX_JSON1" | sed 's# {[^}]\+"mixed"[^}]\+},##; s#, "auto_detect_interface": true##' | sed "s#\"<INBOUND_REPLACE>\"#$INBOUND_REPLACE#; s#\"<NODE_REPLACE>\"#$NODE_REPLACE#g" | $WORK_DIR/jq > $WORK_DIR/subscribe/sing-box-phone 2>/dev/null || echo '{"outbounds":[]}' > $WORK_DIR/subscribe/sing-box-phone
  else
    echo '{"outbounds":[]}' > $WORK_DIR/subscribe/sing-box-pc
    echo '{"outbounds":[]}' > $WORK_DIR/subscribe/sing-box-phone
  fi

  # 生成二维码 url 文件
  [ "$IS_NGINX" = 'is_nginx' ] && cat > $WORK_DIR/subscribe/qr << EOF
$(text 66):
$(text 67):
https://${ARGO_DOMAIN}/${UUID}/auto

$(text 67):
$(text 64) QRcode:
https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://${ARGO_DOMAIN}/${UUID}/auto

$(text 67):
$($WORK_DIR/qrencode "https://${ARGO_DOMAIN}/${UUID}/auto")
EOF

  # 生成客户端配置文件
  EXPORT_LIST_FILE="*******************************************
┌────────────────┐  ┌────────────────┐
│                │  │                │
│     $(warning "V2rayN")     │  │    $(warning "NekoBox")     │
│                │  │                │
└────────────────┘  └────────────────┘
----------------------------
$(info "$(sed "G" <<< "${V2RAYN_SUBSCRIBE}")")"

EXPORT_LIST_FILE+="

多地区 ShadowSocks 节点:"
  
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    EXPORT_LIST_FILE+="
ss://$(echo -n "${SS_METHOD}:${UUID}" | base64 -w0)@${SERVER}:443#${region_name}-Sh-${NODE_NAME}"
  done
  
  EXPORT_LIST_FILE+="
由于该软件导出的链接不全，请自行处理如下: 传输协议: WS , 伪装域名: ${ARGO_DOMAIN} , 路径: /{region}-sh?ed=2048 , 传输层安全: tls , sni: ${ARGO_DOMAIN}

多地区 Reality 节点:"
  
  for region in "${!WS_PATHS[@]}"; do
    local region_name="${WS_PATHS[$region]}"
    local vision_port_var="REALITY_PORT_${region}_vision"
    local grpc_port_var="REALITY_PORT_${region}_grpc"
    local vision_port="${!vision_port_var}"
    local grpc_port="${!grpc_port_var}"
    
    # 只有当端口有效时才显示节点
    if [ -n "$vision_port" ] && [ "$vision_port" != "" ] && [ "$vision_port" != "-1" ]; then
      EXPORT_LIST_FILE+="
vless://${UUID}@${SERVER_IP}:${vision_port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=tcp&headerType=none#${region_name}-Reality-Vision-${NODE_NAME}"
    fi
    
    if [ -n "$grpc_port" ] && [ "$grpc_port" != "" ] && [ "$grpc_port" != "-1" ]; then
      EXPORT_LIST_FILE+="
vless://${UUID}@${SERVER_IP}:${grpc_port}?security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&encryption=none#${region_name}-Reality-gRPC-${NODE_NAME}"
    fi
  done

  EXPORT_LIST_FILE+="

*******************************************
┌────────────────┐
│                │
│  $(warning "Shadowrocket")  │
│                │
└────────────────┘
----------------------------

$(hint "$(sed "G" <<< "${SHADOWROCKET_SUBSCRIBE}")")

*******************************************
┌────────────────┐
│                │
│   $(warning "Clash Meta")   │
│                │
└────────────────┘
----------------------------

$(info "$(sed '1d;G' <<< "$CLASH_SUBSCRIBE")")

*******************************************
┌────────────────┐
│                │
│    $(warning "Sing-box")    │
│                │
└────────────────┘
----------------------------

$(hint "$(if [ -n "$INBOUND_REPLACE" ]; then echo "{ \"outbounds\":[ ${INBOUND_REPLACE%,} ] }" | $WORK_DIR/jq 2>/dev/null || echo "{ \"outbounds\":[ ${INBOUND_REPLACE%,} ] }"; else echo '{"outbounds":[]}'; fi)

 $(text 63)")
"
[ "$IS_NGINX" = 'is_nginx' ] && EXPORT_LIST_FILE+="

*******************************************

$(info "Index:
https://${ARGO_DOMAIN}/${UUID}/

QR code:
https://${ARGO_DOMAIN}/${UUID}/qr

V2rayN / Nekoray $(text 66):
https://${ARGO_DOMAIN}/${UUID}/base64")

$(info "Clash $(text 66):
https://${ARGO_DOMAIN}/${UUID}/clash

sing-box for pc $(text 66):
https://${ARGO_DOMAIN}/${UUID}/sing-box-pc

sing-box for cellphone $(text 66):
https://${ARGO_DOMAIN}/${UUID}/sing-box-phone

Shadowrocket $(text 66):
https://${ARGO_DOMAIN}/${UUID}/shadowrocket")

*******************************************

$(hint " $(text 66):
$(text 67):
https://${ARGO_DOMAIN}/${UUID}/auto

 $(text 64) QRcode:
$(text 67):
https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://${ARGO_DOMAIN}/${UUID}/auto")

$($WORK_DIR/qrencode https://${ARGO_DOMAIN}/${UUID}/auto)
"

EXPORT_LIST_FILE+="
$(info "\n*******************************************

 ${QUICK_TUNNEL_URL} ")
"
  # 生成并显示节点信息
  echo "$EXPORT_LIST_FILE" > $WORK_DIR/list
  cat $WORK_DIR/list

  # 显示脚本使用情况数据
  statistics_of_run-times get
}

# 更换 Argo 隧道类型
change_argo() {
  check_install
  [[ ${STATUS[0]} = "$(text 26)" ]] && error " $(text 39) "

  # 统一处理 Argo 隧道类型检测
  case $(grep "${DAEMON_RUN_PATTERN}" ${ARGO_DAEMON_FILE}) in
    *--config* )
      ARGO_TYPE='Json'; ARGO_DOMAIN="$(grep -m1 '^vless.*&host=' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")" ;;
    *--token* )
      ARGO_TYPE='Token'; ARGO_DOMAIN="$(grep -m1 '^vless.*&host=' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")" ;;
    * )
      ARGO_TYPE='Try'
      ARGO_DOMAIN=$(wget -qO- http://localhost:${METRICS_PORT}/quicktunnel | awk -F '"' '{print $4}')
  esac

  hint "\n $(text 40) \n"
  unset ARGO_DOMAIN
  
  # 检测本地代理端口是否被占用
  check_local_proxy_port
  
  hint " $(text 41) \n" && reading " $(text 24) " CHANGE_TO
    case "$CHANGE_TO" in
      1 )
        cmd_systemctl disable argo
          [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
        if [ "$SYSTEM" = 'Alpine' ]; then
          # 修改 Alpine 的 OpenRC 服务文件
          local ARGS="--edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url http://localhost:${LOCAL_PROXY_PORT}"
          sed -i "s@^command_args=.*@command_args=\"$ARGS\"@g" ${ARGO_DAEMON_FILE}
        else
          # 修改 systemd 服务文件
          sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url http://localhost:${LOCAL_PROXY_PORT}@g" ${ARGO_DAEMON_FILE}
        fi
        ;;
      2 )
        SERVER_IP=$(awk -F '"' '/"SERVER_IP"/{print $4}' $WORK_DIR/*inbound*.json)
        argo_variable
        cmd_systemctl disable argo
          if [ -n "$ARGO_TOKEN" ]; then
            [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
          if [ "$SYSTEM" = 'Alpine' ]; then
            # 修改 Alpine 的 OpenRC 服务文件
            local ARGS="--edge-ip-version auto run --token ${ARGO_TOKEN}"
            sed -i "s@^command_args=.*@command_args=\"$ARGS\"@g" ${ARGO_DAEMON_FILE}
          else
            # 修改 systemd 服务文件
            sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}@g" ${ARGO_DAEMON_FILE}
          fi
          elif [ -n "$ARGO_JSON" ]; then
            [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
            json_argo
          if [ "$SYSTEM" = 'Alpine' ]; then
            # 修改 Alpine 的 OpenRC 服务文件
            local ARGS="--edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
            sed -i "s@^command_args=.*@command_args=\"$ARGS\"@g" ${ARGO_DAEMON_FILE}
          else
            # 修改 systemd 服务文件
            sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run@g" ${ARGO_DAEMON_FILE}
          fi
        fi
        ;;
      * )
        exit 0
    esac

    [ "$IS_NGINX" = 'is_nginx' ] && json_nginx
    cmd_systemctl enable argo
    export_list
}

# 更换 cdn
change_cdn() {
  [ ! -d "${WORK_DIR}" ] && error " $(text 70) "

  # 检测是否有使用 CDN，方法是查找是否有 ${WORK_DIR}/conf/
  local CDN_NOW=$(awk -F '"' '/"SERVER"/{print $4; exit}' ${WORK_DIR}/inbound.json)

  # 提示当前使用的 CDN 并让用户选择或输入新的 CDN
  hint "\n $(text 71) \n"
  for ((c=0; c<${#CDN_DOMAIN[@]}; c++)); do
    hint " $[c+1]. ${CDN_DOMAIN[c]} "
  done
  reading "\n $(text 72) " CDN_CHOOSE

  # 如果用户直接回车，保持当前 CDN
  [ -z "$CDN_CHOOSE" ] && exit 0

  # 如果用户输入数字，选择对应的 CDN
  [[ "$CDN_CHOOSE" =~ ^[1-9][0-9]*$ && "$CDN_CHOOSE" -le "${#CDN_DOMAIN[@]}" ]] && CDN_NEW=${CDN_DOMAIN[$((CDN_CHOOSE-1))]} || CDN_NEW=$CDN_CHOOSE

  # 使用 sed 更新所有文件中的 CDN 值
  find ${WORK_DIR} -type f | xargs -P 50 sed -i "s/${CDN_NOW}/${CDN_NEW}/g"

  # 更新完成后提示并导出订阅列表
  export_list; info "\n $(text 73) \n"
}

# 卸载 ArgoX
uninstall() {
  if [ -d $WORK_DIR ]; then
    cmd_systemctl disable argo
    cmd_systemctl disable xray
    [[ -s $WORK_DIR/nginx.conf && $(ps -ef | grep 'nginx' | wc -l) -le 1 ]] && reading "\n $(text 65) " REMOVE_NGINX
    [ "${REMOVE_NGINX,,}" = 'y' ] && ${PACKAGE_UNINSTALL[int]} nginx >/dev/null 2>&1

    # 根据系统类型删除不同的服务文件
    [ "$SYSTEM" = 'Alpine' ] && rm -rf $WORK_DIR $TEMP_DIR /etc/init.d/{xray,argo} /usr/bin/argox || rm -rf $WORK_DIR $TEMP_DIR /etc/systemd/system/{xray,argo}.service /usr/bin/argox

    info "\n $(text 16) \n"
  else
    error "\n $(text 15) \n"
  fi
}

# Argo 与 Xray 的最新版本
version() {
  # Argo 版本
  local ONLINE=$(wget --no-check-certificate -qO- "${GH_PROXY}https://api.github.com/repos/cloudflare/cloudflared/releases/latest" | grep "tag_name" | cut -d \" -f4)
  [ -z "$ONLINE" ] && error " $(text 74) "
  local LOCAL=$($WORK_DIR/cloudflared -v | awk '{for (i=0; i<NF; i++) if ($i=="version") {print $(i+1)}}')
  local APP=ARGO && info "\n $(text 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[0] || info " $(text 44) "

  local ONLINE=$(wget --no-check-certificate -qO- "${GH_PROXY}https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep "tag_name" | sed "s@.*\"v\(.*\)\",@\1@g")
  [ -z "$ONLINE" ] && error " $(text 74) "
  local LOCAL=$($WORK_DIR/xray version | awk '{for (i=0; i<NF; i++) if ($i=="Xray") {print $(i+1)}}')
  local APP=Xray && info "\n $(text 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[1] || info " $(text 44) "

  [[ "${UPDATE[*],,}" =~ y ]] && check_system_info
  if [ "${UPDATE[0],,}" = 'y' ]; then
    wget --no-check-certificate -O $TEMP_DIR/cloudflared ${GH_PROXY}https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH
    if [ -s $TEMP_DIR/cloudflared ]; then
      cmd_systemctl disable argo
      chmod +x $TEMP_DIR/cloudflared && mv $TEMP_DIR/cloudflared $WORK_DIR/cloudflared
      cmd_systemctl enable argo
      cmd_systemctl status argo &>/dev/null && info " Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "
    else
      local APP=ARGO && error "\n $(text 48) "
    fi
  fi
  if [ "${UPDATE[1],,}" = 'y' ]; then
    wget --no-check-certificate -O $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ${GH_PROXY}https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip
    if [ -s $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ]; then
      cmd_systemctl disable xray
      unzip -qo $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip xray *.dat -d $WORK_DIR; rm -f $TEMP_DIR/Xray*.zip
      cmd_systemctl enable xray
      cmd_systemctl status xray &>/dev/null && info " Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
    else
      local APP=Xray && error "\n $(text 48) "
    fi
  fi
}

# 判断当前 Argo-X 的运行状态，并对应的给菜单和动作赋值
menu_setting() {
  if [[ "${STATUS[*]}" =~ $(text 27)|$(text 28) ]]; then
    if [ -s $WORK_DIR/cloudflared ]; then
      ARGO_VERSION=$($WORK_DIR/cloudflared -v | awk '{print $3}' | sed "s@^@Version: &@g")
      grep -q '^Alpine$' <<< "$SYSTEM" && local PID_COLUMN='1' || local PID_COLUMN='2'
      local PID=$(ps -ef | awk -v work_dir="${WORK_DIR}" -v col="$PID_COLUMN" '$0 ~ work_dir".*cloudflared" && !/grep/ {print $col; exit}')
      local REALTIME_METRICS_PORT=$(ss -nltp | awk -v pid=$PID '$0 ~ "pid="pid"," {split($4, a, ":"); print a[length(a)]}')
      ss -nltp | grep -q "cloudflared.*pid=${PID}," && ARGO_CHECKHEALTH="$(text 46): $(wget -qO- http://localhost:${REALTIME_METRICS_PORT}/healthcheck | sed "s/OK/$(text 37)/")"
    fi
    [ -s $WORK_DIR/xray ] && XRAY_VERSION=$($WORK_DIR/xray version | awk 'NR==1 {print $2}' | sed "s@^@Version: &@g")
    grep -q '^Alpine$' <<< "$SYSTEM" && PS_LIST=$(ps -ef) || PS_LIST=$(ps -ef | awk '{ $1=""; sub(/^ */, ""); print $0 }')
    [ "$IS_NGINX" = 'is_nginx' ] && NGINX_VERSION=$(nginx -v 2>&1 | sed "s#.*/#Version: #")

    OPTION[1]="1.  $(text 29)"
    if [ ${STATUS[0]} = "$(text 28)" ]; then
      AEGO_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f\n", $2/1024}' /proc/$(awk '/\/etc\/argox\/cloudflared/{print $1}' <<< "$PS_LIST")/status) MB"
      [ "$IS_NGINX" = 'is_nginx' ] && NGINX_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f\n", $2/1024}' /proc/$(awk '/\/etc\/argox\/nginx/{print $1}' <<< "$PS_LIST")/status) MB"
      OPTION[2]="2.  $(text 27) Argo (argox -a)"
    else
      OPTION[2]="2.  $(text 28) Argo (argox -a)"
    fi
    [ ${STATUS[1]} = "$(text 28)" ] && XRAY_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f\n", $2/1024}' /proc/$(awk '/\/etc\/argox\/xray.*\/etc\/argox/{print $1}' <<< "$PS_LIST")/status) MB" && OPTION[3]="3.  $(text 27) Xray (argox -x)" || OPTION[3]="3.  $(text 28) Xray (argox -x)"
    OPTION[4]="4.  $(text 30)"
    OPTION[5]="5.  $(text 31)"
    OPTION[6]="6.  $(text 32)"
    OPTION[7]="7.  $(text 33)"
    OPTION[8]="8.  $(text 51)"
    OPTION[9]="9.  $(text 57)"

    ACTION[1]() { export_list; exit 0; }
    [[ ${STATUS[0]} = "$(text 28)" ]] &&
    ACTION[2]() {
      cmd_systemctl disable argo
      cmd_systemctl status argo &>/dev/null && error " Argo $(text 27) $(text 38) " || info "\n Argo $(text 27) $(text 37)"
    } ||
    ACTION[2]() {
      cmd_systemctl enable argo
      sleep 2
      cmd_systemctl status argo &>/dev/null && info "\n Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "
      grep -qs "^${DAEMON_RUN_PATTERN}.*${LOCAL_PROXY_PORT}$" ${ARGO_DAEMON_FILE} && export_list
    }

    [[ ${STATUS[1]} = "$(text 28)" ]] &&
    ACTION[3]() {
      cmd_systemctl disable xray
      cmd_systemctl status xray &>/dev/null && error " Xray $(text 27) $(text 38) " || info "\n Xray $(text 27) $(text 37)"
    } ||
    ACTION[3]() {
      cmd_systemctl enable xray
      sleep 2
      cmd_systemctl status xray &>/dev/null && info "\n Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
    }
    ACTION[4]() { change_argo; exit; }
    ACTION[5]() { version; exit; }
    ACTION[6]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
    ACTION[7]() { uninstall; exit; }
    ACTION[8]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) -$L; exit; }
    ACTION[9]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sba/main/sba.sh) -$L; exit; }

  else
    OPTION[1]="1.  $(text 34)"
    OPTION[2]="2.  $(text 32)"
    OPTION[3]="3.  $(text 51)"
    OPTION[4]="4.  $(text 57)"

    ACTION[1]() { install_argox; export_list; create_shortcut; exit; }
    ACTION[2]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
    ACTION[3]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh) -$L; exit; }
    ACTION[4]() { bash <(wget --no-check-certificate -qO- ${GH_PROXY}https://raw.githubusercontent.com/fscarmen/sba/main/sba.sh) -$L; exit; }
  fi

  [ "${#OPTION[@]}" -ge '10' ] && OPTION[0]="0 .  $(text 35)" || OPTION[0]="0.  $(text 35)"
  ACTION[0]() { exit; }
}

menu() {
  clear
  ### hint " $(text 2) "
  echo -e "======================================================================================================================\n"
  info " $(text 17):$VERSION\n $(text 18):$(text 1)\n $(text 19):\n\t $(text 20):$SYS\n\t $(text 21):$(uname -r)\n\t $(text 22):$ARGO_ARCH\n\t $(text 23):$VIRT "
  info "\t IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  info "\t IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  info "\t Argo: ${STATUS[0]}\t $ARGO_VERSION\t $AEGO_MEMORY\t $ARGO_CHECKHEALTH\n\t Xray: ${STATUS[1]}\t $XRAY_VERSION\t\t $XRAY_MEMORY "
  [ "$IS_NGINX" = 'is_nginx' ] && info "\t Nginx: ${STATUS[0]}\t $NGINX_VERSION\t $NGINX_MEMORY "
  echo -e "\n======================================================================================================================\n"
  for ((b=1;b<${#OPTION[*]};b++)); do hint " ${OPTION[b]} "; done
  hint " ${OPTION[0]} "
  reading "\n $(text 24) " CHOOSE
  
  # 如果用户没有输入，默认选择第1项
  [ -z "$CHOOSE" ] && CHOOSE=1

  # 输入必须是数字且少于等于最大可选项
  if grep -qE "^[0-9]$" <<< "$CHOOSE" && [ "$CHOOSE" -lt "${#OPTION[*]}" ]; then
    ACTION[$CHOOSE]
  else
    warning " $(text 36) [0-$((${#OPTION[*]}-1))] " && sleep 1 && menu
  fi
}

check_cdn
statistics_of_run-times update argox.sh

# 传参
[[ "${*,,}" =~ -e ]] && L=E
[[ "${*,,}" =~ -c ]] && L=C

while getopts ":AaXxTtDdUuNnVvBbF:f:" OPTNAME; do
  case "${OPTNAME,,}" in
    a ) select_language; check_system_info; check_install
        [ "${STATUS[0]}" = "$(text 28)" ] && {
          cmd_systemctl disable argo
          cmd_systemctl status argo &>/dev/null && error " Argo $(text 27) $(text 38) " || info "\n Argo $(text 27) $(text 37)"
        } || {
          cmd_systemctl enable argo
          sleep 2
          if cmd_systemctl status argo &>/dev/null; then
            info "\n Argo $(text 28) $(text 37)"
            grep -qs "^${DAEMON_RUN_PATTERN}.*${LOCAL_PROXY_PORT}$" ${ARGO_DAEMON_FILE} && export_list
          else
            error " Argo $(text 28) $(text 38) "
          fi
        }; exit 0 ;;

    x ) select_language; check_system_info; check_install
        [ "${STATUS[1]}" = "$(text 28)" ] && {
          cmd_systemctl disable xray
          cmd_systemctl status xray &>/dev/null && error " Xray $(text 27) $(text 38) " || info "\n Xray $(text 27) $(text 37)"
        } || {
          cmd_systemctl enable xray
          sleep 2
          cmd_systemctl status xray &>/dev/null && info "\n Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
        }; exit 0 ;;
    t ) select_language; check_system_info; change_argo; exit 0 ;;
    d ) select_language; check_system_info; change_cdn; exit 0 ;;
    u ) select_language; check_system_info; uninstall; exit 0;;
    n ) select_language; check_system_info; export_list; exit 0 ;;
    v ) select_language; check_arch; version; exit 0;;
    b ) select_language; bash <(wget --no-check-certificate -qO- "${GH_PROXY}https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); exit ;;
    f ) NONINTERACTIVE_INSTALL='noninteractive_install'; VARIABLE_FILE=$OPTARG; . $VARIABLE_FILE ;;
  esac
done

select_language
check_root
check_arch
check_system_info
check_dependencies
check_system_ip
check_install
menu_setting
[ -z "$VARIABLE_FILE" ] && menu || ACTION[1]
