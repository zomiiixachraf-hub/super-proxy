#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗    ███████╗███████╗██████╗ ██╗   ██╗     ║
# ║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝    ██╔════╝██╔════╝██╔══██╗██║   ██║     ║
# ║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗      ███████╗█████╗  ██████╔╝██║   ██║     ║
# ║   ██║     ██║   ██║██╔═██╗ ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══╝      ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝     ║
# ║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗    ███████║███████╗██║  ██║ ╚████╔╝      ║
# ║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝       ║
# ║                         🚀 ULTIMATE POWER v5.0 🚀                                                         ║
# ║   ✦ Multi-Port  ✦ BBR+TCP MAX  ✦ BadVPN UDP  ✦ User Stats  ✦ Cloudflare FULL  ✦ Speed Test              ║
# ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

VERSION="5.0"
DIR="/etc/lokmane"
CONFIG="$DIR/config"
USERS_DB="$DIR/users.db"
STATS_DIR="$DIR/stats"
MAX_USERS=5

R='\033[1;31m';G='\033[1;32m';Y='\033[1;33m';B='\033[1;34m';M='\033[1;35m';C='\033[1;36m';W='\033[1;37m';N='\033[0m'

mkdir -p "$DIR" "$STATS_DIR"
touch "$USERS_DB"

cf_api() { curl -s -X "$1" "https://api.cloudflare.com/client/v4$2" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_KEY" -H "Content-Type: application/json" ${3:+-d "$3"}; }

# ═══════════════════════════════════════════════════════════════════════════════
# ARABIC BANNER - سرفر لقمان و عائلته
# ═══════════════════════════════════════════════════════════════════════════════
create_banner() {
cat > /etc/ssh/banner << 'BANNER'

╔═══════════════════════════════════════════════════════════════════════════════════╗
║                                                                                   ║
║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗                  ║
║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝                  ║
║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗                    ║
║   ██║     ██║   ██║██╔═██╗ ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══╝                    ║
║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗                  ║
║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝                  ║
║                                                                                   ║
║═══════════════════════════════════════════════════════════════════════════════════║
║                                                                                   ║
║                 🌟 مرحباً بك في سيرفر لقمان و عائلته 🌟                           ║
║                        ⚡ ULTIMATE POWER v5.0 ⚡                                   ║
║                                                                                   ║
║     ⚡ سرعة خارقة بدون حدود              🔒 حماية عسكرية مشفرة                    ║
║     🌍 شبكة Cloudflare العالمية          💎 وصول VIP حصري                         ║
║     📱 دعم الألعاب والمكالمات            🚀 BBR + TCP Turbo                       ║
║                                                                                   ║
║═══════════════════════════════════════════════════════════════════════════════════║
║                    أهلاً وسهلاً - استمتع بأقصى سرعة ممكنة                         ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

BANNER

cat > /etc/motd << 'MOTD'

═══════════════════════════════════════════════════════════════════════════════════
               ✨ تم الاتصال بنجاح - سيرفر لقمان ULTIMATE ✨
═══════════════════════════════════════════════════════════════════════════════════
   
   🎉 مرحباً يا عضو VIP!
   
   📊 حالة السيرفر: متصل ومحسّن لأقصى سرعة
   🚀 السرعة: غير محدودة + BBR + TCP Turbo
   🔐 التشفير: الحد الأقصى
   📱 دعم UDP: مفعّل للألعاب والمكالمات
   ☁️  Cloudflare: كل الميزات المجانية مفعّلة
   
   💡 البورتات المتاحة:
      • WebSocket: 80, 8080, 8880, 2052, 2082, 2086, 2095
      • SSL/TLS: 443, 445, 2053, 2083, 2087, 2096, 8443
      • UDP Gateway: 7300
   
═══════════════════════════════════════════════════════════════════════════════════

MOTD
}

# ═══════════════════════════════════════════════════════════════════════════════
# KERNEL TURBO MAX - أقصى تحسينات السرعة
# ═══════════════════════════════════════════════════════════════════════════════
turbo_kernel() {
    echo -e "  ${Y}Applying MAXIMUM Kernel Turbo...${N}"
    
    # System Limits
    cat > /etc/security/limits.d/99-lokmane.conf << 'LIMITS'
* soft nofile 1048576
* hard nofile 1048576
* soft nproc unlimited
* hard nproc unlimited
root soft nofile 1048576
root hard nofile 1048576
LIMITS

    # Fast DNS
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    
    cat > /etc/sysctl.d/99-lokmane-turbo.conf << 'SYSCTL'
# LOKMANE ULTIMATE POWER - Maximum Speed
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# MASSIVE Buffers
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.rmem_default = 16777216
net.core.wmem_default = 16777216
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# TCP MAXIMUM Performance
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_frto = 0
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_adv_win_scale = 1

# Network Core MAX
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 65535
net.core.optmem_max = 25165824
net.netfilter.nf_conntrack_max = 1048576

# IP Forwarding
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv4.ip_local_port_range = 1024 65535

# UDP MAX
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# VM Tuning
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 5
SYSCTL

    sysctl -p /etc/sysctl.d/99-lokmane-turbo.conf 2>/dev/null
    
    # Disable unnecessary services
    systemctl disable --now snapd 2>/dev/null
    systemctl disable --now ModemManager 2>/dev/null
    
    echo -e "  ${G}✓ BBR + TCP TURBO MAX Enabled${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# WORKING PROXY CORE (Don't Touch!)
# ═══════════════════════════════════════════════════════════════════════════════
create_proxy() {
cat > "$DIR/proxy.py" << 'PROXY'
#!/usr/bin/env python3
import socket,threading,time,os

STATS_DIR = "/etc/lokmane/stats"

def log_bytes(user, bytes_count):
    try:
        path = f"{STATS_DIR}/{user}"
        current = int(open(path).read()) if os.path.exists(path) else 0
        open(path, "w").write(str(current + bytes_count))
    except: pass

def handle(client, port):
    ssh = None
    try:
        client.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        req = b''
        while b'\r\n\r\n' not in req and len(req) < 8192:
            chunk = client.recv(4096)
            if not chunk: return
            req += chunk
        
        ssh = socket.socket()
        ssh.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        ssh.connect(('127.0.0.1', 22))
        
        if b'websocket' in req.lower() or b'upgrade' in req.lower():
            client.sendall(b'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n')
        elif b'CONNECT' in req:
            client.sendall(b'HTTP/1.1 200 Connection Established\r\n\r\n')
        else:
            client.sendall(b'HTTP/1.1 200 OK\r\n\r\n')
        
        idx = req.find(b'\r\n\r\n')
        if idx != -1 and len(req) > idx + 4:
            ssh.sendall(req[idx+4:])
        
        total_bytes = [0]
        def fwd(src, dst):
            try:
                while True:
                    d = src.recv(65536)
                    if not d: break
                    dst.sendall(d)
                    total_bytes[0] += len(d)
            except: pass
        
        t1 = threading.Thread(target=fwd, args=(client, ssh), daemon=True)
        t2 = threading.Thread(target=fwd, args=(ssh, client), daemon=True)
        t1.start(); t2.start()
        t1.join(); t2.join()
        log_bytes("total", total_bytes[0])
    except: pass
    finally:
        try: client.close()
        except: pass
        try: ssh.close() if ssh else None
        except: pass

def start_server(port):
    sock = socket.socket()
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind(('0.0.0.0', port))
        sock.listen(500)
        print(f'Port {port} OK')
        while True:
            c, a = sock.accept()
            threading.Thread(target=handle, args=(c, port), daemon=True).start()
    except Exception as e:
        print(f'Port {port}: {e}')

for p in [80, 8080, 8880]:
    threading.Thread(target=start_server, args=(p,), daemon=True).start()

while True: time.sleep(3600)
PROXY
chmod +x "$DIR/proxy.py"
}

# ═══════════════════════════════════════════════════════════════════════════════
# BADVPN UDPGW - Fixed for Games/Calls
# ═══════════════════════════════════════════════════════════════════════════════
install_badvpn() {
    echo -e "  ${Y}Installing BadVPN...${N}"
    
    # Download pre-built binary
    wget -q -O /usr/bin/badvpn-udpgw "https://github.com/ambrop72/badvpn/releases/download/1.999.130/badvpn-udpgw-linux-x86_64" 2>/dev/null || \
    wget -q -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" 2>/dev/null
    
    chmod +x /usr/bin/badvpn-udpgw
    
    # Service with proper binding (0.0.0.0 for external access)
    cat > /etc/systemd/system/badvpn.service << 'SVC'
[Unit]
Description=BadVPN UDP Gateway
After=network.target

[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300 --max-clients 500 --max-connections-for-client 10
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
SVC

    systemctl daemon-reload
    systemctl enable badvpn
    systemctl restart badvpn
    echo -e "  ${G}✓ BadVPN on 0.0.0.0:7300${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STUNNEL SSL
# ═══════════════════════════════════════════════════════════════════════════════
install_stunnel() {
    echo -e "  ${Y}Installing Stunnel...${N}"
    apt-get install -y stunnel4 2>/dev/null
    
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/CN=LOKMANE-SERVER" -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem 2>/dev/null
    
    cat > /etc/stunnel/stunnel.conf << 'STUN'
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[ssh-ssl]
accept = 443
connect = 127.0.0.1:22

[ssh-ssl2]
accept = 445
connect = 127.0.0.1:22
STUN

    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4 2>/dev/null
    systemctl enable stunnel4; systemctl restart stunnel4
    echo -e "  ${G}✓ SSL on 443, 445${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALL
# ═══════════════════════════════════════════════════════════════════════════════
install() {
    clear
    echo -e "${M}"
    cat << 'LOGO'
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗              ║
   ║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝              ║
   ║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗                ║
   ║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗              ║
   ║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝              ║
   ║                    🚀 INSTALLING ULTIMATE v4.0 🚀                             ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
LOGO
    echo -e "${N}"
    
    echo -e "  ${Y}[1/7]${N} Packages..."; apt-get update -qq; apt-get install -y python3 openssh-server curl jq openssl vnstat 2>/dev/null; echo -e "  ${G}✓${N}"
    echo -e "  ${Y}[2/7]${N} Banner..."; create_banner; echo -e "  ${G}✓${N}"
    echo -e "  ${Y}[3/7]${N} SSH..."
    cat > /etc/ssh/sshd_config << 'SSH'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
AllowTcpForwarding yes
GatewayPorts yes
ClientAliveInterval 30
UseDNS no
Banner /etc/ssh/banner
PrintMotd yes
SSH
    systemctl restart ssh; echo -e "  ${G}✓${N}"
    
    echo -e "  ${Y}[4/7]${N} Proxy..."; create_proxy
    cat > /etc/systemd/system/lokmane.service << 'SVC'
[Unit]
Description=LOKMANE Proxy
After=network.target
[Service]
ExecStartPre=/bin/bash -c 'fuser -k 80/tcp 8080/tcp 8880/tcp 2>/dev/null || true'
ExecStart=/usr/bin/python3 -u /etc/lokmane/proxy.py
Restart=always
[Install]
WantedBy=multi-user.target
SVC
    systemctl daemon-reload; systemctl enable lokmane; systemctl restart lokmane; echo -e "  ${G}✓ Ports 80,8080,8880${N}"
    
    echo -e "  ${Y}[5/7]${N} BadVPN..."; install_badvpn
    echo -e "  ${Y}[6/7]${N} Stunnel..."; install_stunnel
    echo -e "  ${Y}[7/7]${N} Turbo..."; turbo_kernel
    
    cp "$0" /usr/bin/lokmane 2>/dev/null; chmod +x /usr/bin/lokmane
    
    clear
    echo -e "${G}"
    cat << 'DONE'
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║                    ✓ سيرفر لقمان مثبت بنجاح! ✓                                ║
   ╠═══════════════════════════════════════════════════════════════════════════════╣
   ║   WebSocket: 80, 8080, 8880    │   SSL: 443, 445                              ║
   ║   SSH: 22                      │   UDP: 7300                                  ║
   ║   BBR: مفعّل                    │   TCP Turbo: مفعّل                           ║
   ╠═══════════════════════════════════════════════════════════════════════════════╣
   ║                         الأمر: lokmane                                        ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
DONE
    echo -e "${N}"; read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# USER MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════
add_user() {
    clear; echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                    👤 Add New User                             ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}\n"
    
    COUNT=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    [ "$COUNT" -ge "$MAX_USERS" ] && { echo -e "  ${R}Max users reached!${N}"; read -p "  Enter..."; return; }
    
    read -p "  Username: " USER; [ -z "$USER" ] && return
    id "$USER" &>/dev/null && { echo -e "  ${R}Already exists!${N}"; read -p "  Enter..."; return; }
    read -p "  Password: " PASS; read -p "  Days [30]: " DAYS; DAYS=${DAYS:-30}
    
    EXP=$(date -d "+$DAYS days" +%Y-%m-%d)
    useradd -m -s /bin/bash -e "$EXP" "$USER"; echo "$USER:$PASS" | chpasswd
    echo "$USER|$PASS|$EXP" >> "$USERS_DB"; echo "0" > "$STATS_DIR/$USER"
    
    echo -e "\n  ${G}✓ Created: $USER / $PASS (Expires: $EXP)${N}"; read -p "  Enter..."
}

list_users() {
    clear; echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                    📋 User List                                ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}\n"
    
    if [ -s "$USERS_DB" ]; then
        printf "  ${W}%-10s %-10s %-12s %-10s %-10s${N}\n" "USER" "PASS" "EXPIRES" "STATUS" "DATA"
        echo "  ──────────────────────────────────────────────────────────"
        while IFS='|' read -r u p e; do
            BYTES=$(cat "$STATS_DIR/$u" 2>/dev/null || echo 0)
            MB=$(awk "BEGIN {printf \"%.1f\", $BYTES/1048576}")
            if [[ $(date -d "$e" +%s 2>/dev/null) -lt $(date +%s) ]]; then
                printf "  ${R}%-10s %-10s %-12s %-10s${N} ${Y}%sMB${N}\n" "$u" "$p" "$e" "EXPIRED" "$MB"
            else
                DAYS=$(( ($(date -d "$e" +%s) - $(date +%s)) / 86400 ))
                printf "  ${G}%-10s${N} %-10s ${Y}%-12s${N} ${G}%dd${N} ${Y}%sMB${N}\n" "$u" "$p" "$e" "$DAYS" "$MB"
            fi
        done < "$USERS_DB"
    else echo -e "  ${Y}No users found${N}"; fi
    echo ""; read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# LIVE CONNECTIONS
# ═══════════════════════════════════════════════════════════════════════════════
live_connections() {
    clear; echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                    🔗 Live Connections                         ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}\n"
    
    echo -e "  ${W}Currently Online:${N}\n"
    who | while read line; do echo -e "  ${G}●${N} $line"; done
    
    echo -e "\n  ${W}Port Connections:${N}"
    for p in 80 8080 8880 443 445; do
        COUNT=$(ss -tn | grep -c ":$p " 2>/dev/null || echo 0)
        echo -e "    Port $p: ${Y}$COUNT${N} connections"
    done
    
    echo ""; read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLOUDFLARE SETUP + TURBO (All Free Features!)
# ═══════════════════════════════════════════════════════════════════════════════
setup_cloudflare() {
    clear; IP=$(curl -s ifconfig.me)
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                   ☁️  Cloudflare Setup                        ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}\n"
    
    read -p "  Email: " CF_EMAIL; read -p "  API Key: " CF_KEY
    [ -z "$CF_EMAIL" ] || [ -z "$CF_KEY" ] && return
    
    ZONES=$(cf_api GET "/zones?per_page=50")
    ZONE_COUNT=$(echo "$ZONES" | jq -r '.result | length' 2>/dev/null || echo 0)
    [ "$ZONE_COUNT" -eq 0 ] && { echo -e "  ${R}Failed!${N}"; read -p "  Enter..."; return; }
    
    echo -e "\n  ${W}Domains:${N}"
    for ((i=0; i<ZONE_COUNT; i++)); do echo -e "    ${G}$((i+1))${N}) $(echo "$ZONES" | jq -r ".result[$i].name")"; done
    read -p "  Choose: " CHOICE; IDX=$((CHOICE-1))
    DOMAIN=$(echo "$ZONES" | jq -r ".result[$IDX].name"); ZONE_ID=$(echo "$ZONES" | jq -r ".result[$IDX].id")
    
    read -p "  Subdomain (empty=root): " SUB
    [ -n "$SUB" ] && FULL_DOMAIN="${SUB}.${DOMAIN}" || FULL_DOMAIN="$DOMAIN"
    
    echo -e "\n  ${Y}Configuring...${N}"
    
    # DNS Record
    EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN")
    RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
    [ -n "$RECORD_ID" ] && cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null || cf_api POST "/zones/$ZONE_ID/dns_records" "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null
    echo -e "  ${G}✓${N} DNS"
    
    # Enable all free features!
    cf_api PATCH "/zones/$ZONE_ID/settings/websockets" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} WebSocket"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/ssl" '{"value":"flexible"}' >/dev/null
    echo -e "  ${G}✓${N} SSL Flexible"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/always_use_https" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} Always HTTPS"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/brotli" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} Brotli Compression"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/minify" '{"value":{"css":"on","html":"on","js":"on"}}' >/dev/null
    echo -e "  ${G}✓${N} Auto Minify (CSS/JS/HTML)"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/early_hints" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} Early Hints (Faster!)"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/always_online" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} Always Online"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/browser_cache_ttl" '{"value":14400}' >/dev/null
    echo -e "  ${G}✓${N} Browser Cache (4 hours)"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/cache_level" '{"value":"aggressive"}' >/dev/null
    echo -e "  ${G}✓${N} Aggressive Caching"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/security_level" '{"value":"medium"}' >/dev/null
    echo -e "  ${G}✓${N} Security Level: Medium"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/ip_geolocation" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} IP Geolocation"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/http3" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} HTTP/3 (QUIC)"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/0rtt" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓${N} 0-RTT (Faster TLS)"
    
    echo "CF_EMAIL=$CF_EMAIL" > "$CONFIG"; echo "CF_KEY=$CF_KEY" >> "$CONFIG"
    echo "ZONE_ID=$ZONE_ID" >> "$CONFIG"; echo "DOMAIN=$FULL_DOMAIN" >> "$CONFIG"
    
    echo -e "\n  ${G}✓ All Cloudflare free features enabled!${N}"
    echo -e "  ${C}Domain: $FULL_DOMAIN${N}"; read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLOUDFLARE TURBO MENU
# ═══════════════════════════════════════════════════════════════════════════════
cloudflare_menu() {
    source "$CONFIG" 2>/dev/null
    [ -z "$CF_EMAIL" ] && { echo -e "\n  ${R}Please setup Cloudflare first (option 10)${N}"; read -p "  Enter..."; return; }
    
    clear
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║               ☁️  CLOUDFLARE TURBO MENU                       ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}\n"
    echo -e "  ${W}Domain:${N} ${C}$DOMAIN${N}\n"
    
    echo -e "    ${G}1${N}) 🛡️  Under Attack Mode"
    echo -e "    ${G}2${N}) 🔄  Update IP in Cloudflare"
    echo -e "    ${G}3${N}) 📊  Domain Info"
    echo -e "    ${G}4${N}) 🚀  Enable Development Mode"
    echo -e "    ${G}5${N}) 🧹  Purge Cache"
    echo -e "    ${G}0${N}) Back\n"
    
    read -p "  Choose: " OPT
    case $OPT in
        1)
            echo -e "\n  ${Y}Under Attack Mode:${N}"
            echo -e "    ${G}1${N}) Enable (I'm Under Attack)"
            echo -e "    ${G}2${N}) Disable (Medium Security)"
            read -p "  Choose: " ATK
            if [ "$ATK" = "1" ]; then
                cf_api PATCH "/zones/$ZONE_ID/settings/security_level" '{"value":"under_attack"}' >/dev/null
                echo -e "  ${G}✓ Under Attack Mode Enabled!${N}"
            else
                cf_api PATCH "/zones/$ZONE_ID/settings/security_level" '{"value":"medium"}' >/dev/null
                echo -e "  ${G}✓ Security Level: Medium${N}"
            fi
            ;;
        2)
            IP=$(curl -s ifconfig.me)
            EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN")
            RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
            [ -n "$RECORD_ID" ] && cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null
            echo -e "\n  ${G}✓ IP Updated to: $IP${N}"
            ;;
        3)
            INFO=$(cf_api GET "/zones/$ZONE_ID")
            echo -e "\n  ${W}Domain Info:${N}"
            echo "$INFO" | jq -r '.result | "  Name: \(.name)\n  Status: \(.status)\n  Plan: \(.plan.name)"' 2>/dev/null
            ;;
        4)
            cf_api PATCH "/zones/$ZONE_ID/settings/development_mode" '{"value":"on"}' >/dev/null
            echo -e "\n  ${G}✓ Development Mode (3 hours)${N}"
            ;;
        5)
            cf_api POST "/zones/$ZONE_ID/purge_cache" '{"purge_everything":true}' >/dev/null
            echo -e "\n  ${G}✓ Cache Purged${N}"
            ;;
    esac
    [ "$OPT" != "0" ] && read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# PAYLOADS
# ═══════════════════════════════════════════════════════════════════════════════
show_payloads() {
    clear; IP=$(curl -s ifconfig.me); source "$CONFIG" 2>/dev/null
    echo -e "${C}╔═══════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                              📱 Payloads                                    ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════════════════════╝${N}\n"
    
    echo -e "  ${Y}━━━ WebSocket ━━━${N}\n"
    echo -e "  GET / HTTP/1.1[crlf]Host: $IP[crlf]Upgrade: websocket[crlf][crlf]"
    echo -e "  ${W}Ports:${N} 80, 8080, 8880  ${W}UDP:${N} $IP:7300\n"
    
    echo -e "  ${Y}━━━ SSL Direct ━━━${N}\n"
    echo -e "  Host: $IP  Port: 443 or 445  SSL: ON\n"
    
    [ -n "$DOMAIN" ] && { echo -e "  ${Y}━━━ Cloudflare ━━━${N}\n"; echo -e "  GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"; echo -e "  Proxy: $DOMAIN:443 SSL ON\n"; }
    
    read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATUS
# ═══════════════════════════════════════════════════════════════════════════════
show_status() {
    clear; IP=$(curl -s -m2 ifconfig.me); source "$CONFIG" 2>/dev/null
    echo -e "${C}╔═══════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                         📊 Server Status                                  ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════════════════════╝${N}\n"
    
    echo -e "  ${W}Services:${N}"
    for svc in lokmane ssh stunnel4 badvpn; do
        ST=$(systemctl is-active $svc 2>/dev/null)
        echo -e "    $svc: $([ "$ST" = "active" ] && echo -e "${G}● Running${N}" || echo -e "${R}○ Stopped${N}")"
    done
    
    BBR=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q bbr && echo "Enabled" || echo "Disabled")
    echo -e "\n  ${W}IP:${N} $IP"; [ -n "$DOMAIN" ] && echo -e "  ${W}Domain:${N} $DOMAIN"
    echo -e "  ${W}BBR:${N} $BBR"
    
    RAM=$(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')
    TOTAL_BYTES=$(cat "$STATS_DIR/total" 2>/dev/null || echo 0)
    TOTAL_MB=$(awk "BEGIN {printf \"%.1f\", $TOTAL_BYTES/1048576}")
    echo -e "  ${W}RAM:${N} $RAM  ${W}Total Traffic:${N} ${TOTAL_MB}MB"
    
    USERS=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    CONN=$(ss -tn | grep -cE ":80|:8080|:8880|:443|:445" 2>/dev/null || echo 0)
    echo -e "  ${W}Users:${N} $USERS/$MAX_USERS  ${W}Connections:${N} $CONN\n"
    
    read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# SPEED TEST
# ═══════════════════════════════════════════════════════════════════════════════
speed_test() {
    clear
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                    ⚡ Server Speed Test                       ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}\n"
    
    echo -e "  ${Y}Testing...${N}\n"
    
    # Download test
    echo -e "  ${W}Download Speed:${N}"
    DL=$(curl -s -o /dev/null -w "%{speed_download}" --connect-timeout 10 --max-time 15 "https://speed.cloudflare.com/__down?bytes=10000000" 2>/dev/null)
    DL_MBPS=$(awk "BEGIN {printf \"%.2f\", $DL/1048576*8}")
    echo -e "    ${G}⬇️  $DL_MBPS Mbps${N}\n"
    
    # Upload test
    echo -e "  ${W}Upload Speed:${N}"
    UP=$(dd if=/dev/zero bs=1M count=5 2>/dev/null | curl -s -o /dev/null -w "%{speed_upload}" --connect-timeout 10 --max-time 15 -X POST -d @- "https://speed.cloudflare.com/__up" 2>/dev/null)
    UP_MBPS=$(awk "BEGIN {printf \"%.2f\", $UP/1048576*8}")
    echo -e "    ${G}⬆️  $UP_MBPS Mbps${N}\n"
    
    # Latency test
    echo -e "  ${W}Latency:${N}"
    PING=$(ping -c 3 1.1.1.1 2>/dev/null | tail -1 | awk -F'/' '{print $5}')
    echo -e "    ${G}📶 ${PING:-N/A} ms${N}\n"
    
    # BBR Status
    BBR=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
    echo -e "  ${W}TCP Congestion:${N} ${G}$BBR${N}"
    
    # Buffer sizes
    RMEM=$(sysctl net.core.rmem_max 2>/dev/null | awk '{print $3}')
    RMEM_MB=$(awk "BEGIN {printf \"%.0f\", $RMEM/1048576}")
    echo -e "  ${W}Buffer Size:${N} ${G}${RMEM_MB}MB${N}\n"
    
    read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# MENU
# ═══════════════════════════════════════════════════════════════════════════════
menu() {
    while true; do
        clear; IP=$(curl -s -m2 ifconfig.me 2>/dev/null || echo "..."); source "$CONFIG" 2>/dev/null
        USERS=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
        
        echo -e "${M}"
        cat << 'LOGO'
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗              ║
   ║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝              ║
   ║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗                ║
   ║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗              ║
   ║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝              ║
   ║                  🚀 سيرفر لقمان ULTIMATE POWER v5.0 🚀                         ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
LOGO
        echo -e "${N}"
        echo -e "    ${W}IP:${N} ${G}$IP${N}  ${W}Users:${N} ${Y}$USERS${N}/$MAX_USERS"
        [ -n "$DOMAIN" ] && echo -e "    ${W}Domain:${N} ${C}$DOMAIN${N}"
        echo ""
        
        echo -e "${C}    ╔═════════════════════════════════════════════════════════════════════╗${N}"
        echo -e "${C}    ║${N}   ${G}1${N}) Add User                  ${G}7${N}) Payloads                       ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}2${N}) Delete User               ${G}8${N}) Server Status                  ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}3${N}) User List                 ${G}9${N}) Restart Services               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}4${N}) Renew User               ${G}10${N}) Cloudflare Setup               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}5${N}) Quick User               ${G}11${N}) Live Connections               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}6${N}) Enable Turbo             ${G}12${N}) ☁️ Cloudflare Turbo              ${C}║${N}"
        echo -e "${C}    ║${N}                                 ${G}13${N}) ⚡ Speed Test                    ${C}║${N}"
        echo -e "${C}    ║${N}                                  ${R}0${N}) Exit                           ${C}║${N}"
        echo -e "${C}    ╚═════════════════════════════════════════════════════════════════════╝${N}\n"
        
        read -p "    Choose: " OPT
        case $OPT in
            1) add_user ;;
            2) read -p "  Username: " U; [ -n "$U" ] && { userdel -rf "$U" 2>/dev/null; sed -i "/^$U|/d" "$USERS_DB"; echo -e "  ${G}✓${N}"; sleep 1; } ;;
            3) list_users ;;
            4) read -p "  Username: " U; read -p "  Days: " D; [ -n "$U" ] && [ -n "$D" ] && { chage -E "$(date -d "+$D days" +%Y-%m-%d)" "$U"; echo -e "  ${G}✓${N}"; sleep 1; } ;;
            5) U="vip$(shuf -i 10-99 -n 1)"; P=$(shuf -i 1000-9999 -n 1); useradd -m -s /bin/bash "$U" 2>/dev/null; echo "$U:$P"|chpasswd; echo "$U|$P|$(date -d '+30 days' +%Y-%m-%d)" >> "$USERS_DB"; echo -e "\n  ${G}✓ $U / $P${N}"; sleep 2 ;;
            6) turbo_kernel; read -p "  Enter..." ;;
            7) show_payloads ;;
            8) show_status ;;
            9) systemctl restart lokmane ssh stunnel4 badvpn 2>/dev/null; echo -e "\n  ${G}✓ Done${N}"; sleep 1 ;;
            10) setup_cloudflare ;;
            11) live_connections ;;
            12) cloudflare_menu ;;
            13) speed_test ;;
            0) clear; echo -e "${G}\n    👋 Goodbye - LOKMANE SERVER\n${N}"; exit 0 ;;
        esac
    done
}

[ ! -f "$DIR/proxy.py" ] && install
menu
