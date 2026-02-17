#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║   ASHRAF SERVER - ULTIMATE v4.5 (UNIVERSAL DESIGN FIX)                                                    ║
# ║   Banner: Uses Safe HTML & Unicode Borders (No Broken CSS)                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

VERSION="4.5"
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
# BANNER FIX - EMOJI & GOLD TEXT (NO BROKEN CSS)
# ═══════════════════════════════════════════════════════════════════════════════
create_banner() {
# This design uses <font> tags and emojis which work on ALL Android VPN apps perfectly
cat > /etc/ssh/banner << 'EOF'
<br>
<center>
<font size="5" color="#D4AF37"><b>╔════════════════════╗</b></font>
<br><br>
<font size="7" color="#FFD700"><b>👑 سيرفر أشرف 👑</b></font>
<br>
<font size="6" color="#FFFFFF"><b>و عائلته</b></font>
<br><br>
<font size="5" color="#D4AF37"><b>╚════════════════════╝</b></font>
<br>
<font size="4" color="#00FF00"><b>⚡ اتصال سريع وآمن ⚡</b></font>
</center>
<br>
EOF
}

# ═══════════════════════════════════════════════════════════════════════════════
# KERNEL TURBO
# ═══════════════════════════════════════════════════════════════════════════════
turbo_kernel() {
    echo -e "  ${Y}Applying Kernel Turbo...${N}"
    cat > /etc/sysctl.d/99-lokmane-turbo.conf << 'SYSCTL'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.ipv4.tcp_rmem = 4096 1048576 67108864
net.ipv4.tcp_wmem = 4096 1048576 67108864
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
SYSCTL
    sysctl -p /etc/sysctl.d/99-lokmane-turbo.conf 2>/dev/null
    echo -e "  ${G}✓ BBR + TCP Turbo Enabled${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PROXY CORE
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
# BADVPN
# ═══════════════════════════════════════════════════════════════════════════════
install_badvpn() {
    echo -e "  ${Y}Installing BadVPN...${N}"
    wget -q -O /usr/bin/badvpn-udpgw "https://github.com/ambrop72/badvpn/releases/download/1.999.130/badvpn-udpgw-linux-x86_64" 2>/dev/null || \
    wget -q -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" 2>/dev/null
    chmod +x /usr/bin/badvpn-udpgw
    
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

    systemctl daemon-reload; systemctl enable badvpn; systemctl restart badvpn
    echo -e "  ${G}✓ BadVPN on 0.0.0.0:7300${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STUNNEL SSL
# ═══════════════════════════════════════════════════════════════════════════════
install_stunnel() {
    echo -e "  ${Y}Installing Stunnel...${N}"
    apt-get install -y stunnel4 2>/dev/null
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/CN=ASHRAF-SERVER" -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem 2>/dev/null
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
# INSTALL MAIN (AWS SAFE MODE)
# ═══════════════════════════════════════════════════════════════════════════════
install() {
    clear
    echo -e "${M}INSTALLING ASHRAF SERVER v4.5...${N}"
    
    echo -e "  ${Y}[1/8]${N} Setting Backup Password..."
    echo "ubuntu:123456" | chpasswd
    echo -e "  ${G}✓ Backup Password set to: 123456${N}"
    
    echo -e "  ${Y}[2/8]${N} Packages..."; apt-get update -qq; apt-get install -y python3 openssh-server curl jq openssl vnstat 2>/dev/null; echo -e "  ${G}✓${N}"
    echo -e "  ${Y}[3/8]${N} HTML Banner (Universal Mode)..."; create_banner; echo -e "  ${G}✓${N}"
    
    echo -e "  ${Y}[4/8]${N} SSH Config (Safe Mode)..."
    cat > /etc/ssh/sshd_config << 'SSH'
Port 22
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
AllowTcpForwarding yes
GatewayPorts yes
ClientAliveInterval 30
UseDNS no
Banner /etc/ssh/banner
PrintMotd yes
SSH
    systemctl restart ssh; echo -e "  ${G}✓ SSH Fixed${N}"
    
    echo -e "  ${Y}[5/8]${N} Proxy Service..."; create_proxy
    cat > /etc/systemd/system/lokmane.service << 'SVC'
[Unit]
Description=ASHRAF Proxy
After=network.target
[Service]
ExecStartPre=/bin/bash -c 'fuser -k 80/tcp 8080/tcp 8880/tcp 2>/dev/null || true'
ExecStart=/usr/bin/python3 -u /etc/lokmane/proxy.py
Restart=always
[Install]
WantedBy=multi-user.target
SVC
    systemctl daemon-reload; systemctl enable lokmane; systemctl restart lokmane; echo -e "  ${G}✓ Ports 80,8080,8880${N}"
    
    echo -e "  ${Y}[6/8]${N} BadVPN UDP..."; install_badvpn
    echo -e "  ${Y}[7/8]${N} Stunnel SSL..."; install_stunnel
    echo -e "  ${Y}[8/8]${N} Kernel Turbo..."; turbo_kernel
    
    cp "$0" /usr/bin/lokmane 2>/dev/null; chmod +x /usr/bin/lokmane
    
    clear
    echo -e "${G}Installation Complete!${N}"
    echo -e "-----------------------------------------------------"
    echo -e "AWS LOGIN INFO:"
    echo -e "1. Key (.pem) works: YES"
    echo -e "2. Backup Password: ${Y}123456${N}"
    echo -e "-----------------------------------------------------"
    echo -e "Command to run menu: ${Y}lokmane${N}"
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# USER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
add_user() {
    clear; echo -e "${C}=== ADD NEW USER ===${N}\n"
    COUNT=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    [ "$COUNT" -ge "$MAX_USERS" ] && { echo -e "  ${R}Max users reached!${N}"; read -p "  Enter..."; return; }
    read -p "  Username: " USER; [ -z "$USER" ] && return
    id "$USER" &>/dev/null && { echo -e "  ${R}User exists!${N}"; read -p "  Enter..."; return; }
    read -p "  Password: " PASS; read -p "  Days [30]: " DAYS; DAYS=${DAYS:-30}
    EXP=$(date -d "+$DAYS days" +%Y-%m-%d)
    useradd -m -s /bin/bash -e "$EXP" "$USER"; echo "$USER:$PASS" | chpasswd
    echo "$USER|$PASS|$EXP" >> "$USERS_DB"; echo "0" > "$STATS_DIR/$USER"
    echo -e "\n  ${G}✓ Created: $USER / $PASS (Expires: $EXP)${N}"; read -p "  Enter..."
}

list_users() {
    clear; echo -e "${C}=== USER LIST ===${N}\n"
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

live_connections() {
    clear; echo -e "${C}=== LIVE CONNECTIONS ===${N}\n"
    echo -e "  ${W}SSH Users Online:${N}\n"
    who | while read line; do echo -e "  ${G}●${N} $line"; done
    echo -e "\n  ${W}Port Connections:${N}"
    for p in 80 8080 8880 443 445; do
        COUNT=$(ss -tn | grep -c ":$p " 2>/dev/null || echo 0)
        echo -e "    Port $p: ${Y}$COUNT${N} connections"
    done
    echo ""; read -p "  Enter..."
}

setup_cloudflare() {
    clear; IP=$(curl -s ifconfig.me)
    echo -e "${C}=== CLOUDFLARE SETUP ===${N}\n"
    read -p "  Email: " CF_EMAIL; read -p "  API Key: " CF_KEY
    [ -z "$CF_EMAIL" ] || [ -z "$CF_KEY" ] && return
    ZONES=$(cf_api GET "/zones?per_page=50")
    ZONE_COUNT=$(echo "$ZONES" | jq -r '.result | length' 2>/dev/null || echo 0)
    [ "$ZONE_COUNT" -eq 0 ] && { echo -e "  ${R}Failed/No Zones!${N}"; read -p "  Enter..."; return; }
    echo -e "\n  ${W}Domains:${N}"
    for ((i=0; i<ZONE_COUNT; i++)); do echo -e "    ${G}$((i+1))${N}) $(echo "$ZONES" | jq -r ".result[$i].name")"; done
    read -p "  Select: " CHOICE; IDX=$((CHOICE-1))
    DOMAIN=$(echo "$ZONES" | jq -r ".result[$IDX].name"); ZONE_ID=$(echo "$ZONES" | jq -r ".result[$IDX].id")
    read -p "  Subdomain (empty=root): " SUB
    [ -n "$SUB" ] && FULL_DOMAIN="${SUB}.${DOMAIN}" || FULL_DOMAIN="$DOMAIN"
    EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN")
    RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
    [ -n "$RECORD_ID" ] && cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null || cf_api POST "/zones/$ZONE_ID/dns_records" "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null
    cf_api PATCH "/zones/$ZONE_ID/settings/websockets" '{"value":"on"}' >/dev/null
    cf_api PATCH "/zones/$ZONE_ID/settings/ssl" '{"value":"flexible"}' >/dev/null
    echo "CF_EMAIL=$CF_EMAIL" > "$CONFIG"; echo "CF_KEY=$CF_KEY" >> "$CONFIG"
    echo "ZONE_ID=$ZONE_ID" >> "$CONFIG"; echo "DOMAIN=$FULL_DOMAIN" >> "$CONFIG"
    echo -e "\n  ${G}✓ Done: $FULL_DOMAIN${N}"; read -p "  Enter..."
}

show_payloads() {
    clear; IP=$(curl -s ifconfig.me); source "$CONFIG" 2>/dev/null
    echo -e "${C}=== PAYLOAD GENERATOR ===${N}\n"
    echo -e "  ${Y}━━━ WebSocket ━━━${N}\n"
    echo -e "  GET / HTTP/1.1[crlf]Host: $IP[crlf]Upgrade: websocket[crlf][crlf]"
    echo -e "  ${W}Ports:${N} 80, 8080, 8880  ${W}UDP:${N} $IP:7300\n"
    echo -e "  ${Y}━━━ SSL Direct ━━━${N}\n"
    echo -e "  Host: $IP  Port: 443 or 445  SSL: ON\n"
    [ -n "$DOMAIN" ] && { echo -e "  ${Y}━━━ Cloudflare ━━━${N}\n"; echo -e "  GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"; echo -e "  Proxy: $DOMAIN:443 SSL ON\n"; }
    read -p "  Enter..."
}

show_status() {
    clear; IP=$(curl -s -m2 ifconfig.me); source "$CONFIG" 2>/dev/null
    echo -e "${C}=== SERVER STATUS ===${N}\n"
    echo -e "  ${W}Services:${N}"
    for svc in lokmane ssh stunnel4 badvpn; do
        ST=$(systemctl is-active $svc 2>/dev/null)
        echo -e "    $svc: $([ "$ST" = "active" ] && echo -e "${G}● RUNNING${N}" || echo -e "${R}○ STOPPED${N}")"
    done
    BBR=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q bbr && echo "ON" || echo "OFF")
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

menu() {
    while true; do
        clear; IP=$(curl -s -m2 ifconfig.me 2>/dev/null || echo "..."); source "$CONFIG" 2>/dev/null
        USERS=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
        echo -e "${M}"
        echo "  ASHRAF SERVER MANAGER v4.5"
        echo "  --------------------------"
        echo -e "${N}"
        echo -e "    ${W}IP:${N} ${G}$IP${N}  ${W}Users:${N} ${Y}$USERS${N}/$MAX_USERS"
        [ -n "$DOMAIN" ] && echo -e "    ${W}Domain:${N} ${C}$DOMAIN${N}"
        echo ""
        echo -e "${C}    ╔═════════════════════════════════════════════════════════════════════╗${N}"
        echo -e "${C}    ║${N}   ${G}1${N}) Add User                    ${G}7${N}) Show Payloads                  ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}2${N}) Delete User                 ${G}8${N}) Server Status                  ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}3${N}) List Users                  ${G}9${N}) Restart Services               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}4${N}) Renew User                  ${G}10${N}) Cloudflare Setup               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}5${N}) Quick User (Trial)          ${G}11${N}) Live Connections               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}6${N}) Enable Turbo                ${R}0${N}) Exit                           ${C}║${N}"
        echo -e "${C}    ╚═════════════════════════════════════════════════════════════════════╝${N}\n"
        read -p "    Select Option: " OPT
        case $OPT in
            1) add_user ;;
            2) read -p "  Username: " U; [ -n "$U" ] && { userdel -rf "$U" 2>/dev/null; sed -i "/^$U|/d" "$USERS_DB"; echo -e "  ${G}✓${N}"; sleep 1; } ;;
            3) list_users ;;
            4) read -p "  Username: " U; read -p "  Days: " D; [ -n "$U" ] && [ -n "$D" ] && { chage -E "$(date -d "+$D days" +%Y-%m-%d)" "$U"; echo -e "  ${G}✓${N}"; sleep 1; } ;;
            5) U="vip$(shuf -i 10-99 -n 1)"; P=$(shuf -i 1000-9999 -n 1); useradd -m -s /bin/bash "$U" 2>/dev/null; echo "$U:$P"|chpasswd; echo "$U|$P|$(date -d '+30 days' +%Y-%m-%d)" >> "$USERS_DB"; echo -e "\n  ${G}✓ Created: $U / $P${N}"; sleep 2 ;;
            6) turbo_kernel; read -p "  Enter..." ;;
            7) show_payloads ;;
            8) show_status ;;
            9) systemctl restart lokmane ssh stunnel4 badvpn 2>/dev/null; echo -e "\n  ${G}✓ Services Restarted${N}"; sleep 1 ;;
            10) setup_cloudflare ;;
            11) live_connections ;;
            0) clear; echo -e "${G}\n    👋 Bye - ASHRAF SERVER\n${N}"; exit 0 ;;
        esac
    done
}

[ ! -f "$DIR/proxy.py" ] && install
menu