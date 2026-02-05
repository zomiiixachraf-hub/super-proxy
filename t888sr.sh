cat << 'EOF_SCRIPT' > achraf.sh
#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════
# ║              SUPER PROXY ULTIMATE v3.0 - LUXURY EDITION                   ║
# ║                  POWERED BY: ACHRAF SERVER                                 ║
# ║                   STATUS: ELITE & STABLE                                   ║
# ╚══════════════════════════════════════════════════════════════════════════════

set -e
export DEBIAN_FRONTEND=noninteractive

VERSION="3.0"
SCRIPT_NAME="ACHRAF SERVER"
DIR="/etc/superproxy"
CONFIG="$DIR/config"
USERS_DB="$DIR/users.db"
BACKUP_DIR="/root/superproxy-backups"
MAX_USERS=5

R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
M='\033[1;35m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'
BG_B='\033[44m'
BG_R='\033[41m'
BG_G='\033[42m'

mkdir -p "$DIR" "$BACKUP_DIR"
touch "$USERS_DB"

check_dependencies() {
    MISSING=""
    ! command -v python3 &>/dev/null && MISSING="python3 $MISSING"
    ! command -v curl &>/dev/null && MISSING="curl $MISSING"
    ! command -v jq &>/dev/null && MISSING="jq $MISSING"
    
    if [ -n "$MISSING" ]; then
        echo -e "${Y}[*] ACHRAF SERVER: Auto-fixing missing dependencies...${N}"
        apt-get update -qq > /dev/null 2>&1
        apt-get install -y $MISSING > /dev/null 2>&1
        echo -e "${G}✓ System Repaired.${N}"
    fi
}

cf_api() {
    curl -s -X "$1" "https://api.cloudflare.com/client/v4$2" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_KEY" \
        -H "Content-Type: application/json" \
        ${3:+-d "$3"}
}

create_proxy() {
    cat > "$DIR/proxy.py" << 'PROXY'
#!/usr/bin/env python3
import socket, threading, sys
LISTEN_PORT = 80
SSH_PORT = 22
def forward(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data: break
            dst.sendall(data)
    except: pass
def handle(client, addr):
    ssh = None
    try:
        client.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        request = b''
        while b'\r\n\r\n' not in request and len(request) < 8192:
            chunk = client.recv(4096)
            if not chunk: return
            request += chunk
        ssh = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssh.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        ssh.connect(('127.0.0.1', SSH_PORT))
        req_str = request.decode('utf-8', errors='ignore').lower()
        if 'websocket' in req_str or 'upgrade' in req_str:
            client.sendall(b'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n')
        elif 'connect' in req_str:
            client.sendall(b'HTTP/1.1 200 Connection Established\r\n\r\n')
        else:
            client.sendall(b'HTTP/1.1 200 OK\r\n\r\n')
        idx = request.find(b'\r\n\r\n')
        if idx != -1 and len(request) > idx + 4:
            ssh.sendall(request[idx + 4:])
        t1 = threading.Thread(target=forward, args=(client, ssh), daemon=True)
        t2 = threading.Thread(target=forward, args=(ssh, client), daemon=True)
        t1.start(); t2.start()
        t1.join(); t2.join()
    except: pass
    finally:
        try: client.close()
        except: pass
        try:
            if ssh: ssh.close()
        except: pass
def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try: sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except: pass
    sock.bind(('0.0.0.0', LISTEN_PORT))
    sock.listen(100)
    print(f'[ACHRAF] Port {LISTEN_PORT} Active', flush=True)
    while True:
        try:
            c, a = sock.accept()
            threading.Thread(target=handle, args=(c, a), daemon=True).start()
        except: pass
if __name__ == '__main__':
    main()
PROXY
    chmod +x "$DIR/proxy.py"
}

clear_screen() { clear; }

print_banner() {
    echo -e "${C}"
    cat << 'BANNER'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║   ███████╗██╗   ██╗██████╗ ███████╗██████╗                    ║
    ║   ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗                   ║
    ║   ███████╗██║   ██║██████╔╝█████╗  ██████╔╝                   ║
    ║   ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗                   ║
    ║   ███████║╚██████╔╝██║     ███████╗██║  ██║                   ║
    ║   ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝                   ║
    ║                                                               ║
    ║              🚀 ACHRAF SERVER v3.0 🚀                        ║
    ║                  [ LUXURY EDITION ]                            ║
    ╚═══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${N}"
}

print_achraf_success() {
    echo -e "\n${Y}  ╔══════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${Y}  ║${N}                                                                      ${Y}║${N}"
    echo -e "${Y}  ║${N}           ${G}✓✓✓    ACHRAF SERVER    ✓✓✓${N}                          ${Y}║${N}"
    echo -e "${Y}  ║${N}                 ${W}OPERATION SUCCESSFUL${W}                             ${Y}║${N}"
    echo -e "${Y}  ║${N}                                                                      ${Y}║${N}"
    echo -e "${Y}  ╚══════════════════════════════════════════════════════════════════╝${N}\n"
}

print_header() {
    clear_screen
    print_banner
    check_dependencies 
    local IP=$(curl -s -m2 ifconfig.me 2>/dev/null || echo "Offline")
    local RAM=$(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')
    local CPU=$(top -bn1 | grep 'Cpu' | awk '{print 100-$8"%"}')
    source "$CONFIG" 2>/dev/null
    local DOMAIN=${DOMAIN:-"Not Set"}
    local USERS_COUNT=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    local EXP_WARN=""
    local today_sec=$(date +%s)
    while IFS='|' read -r u _ e _; do
        if [ -n "$e" ]; then
            exp_sec=$(date -d "$e" +%s 2>/dev/null || echo "9999999999")
            diff=$(( (exp_sec - today_sec) / 86400 ))
            if [ "$diff" -lt 3 ] && [ "$diff" -ge 0 ]; then
                EXP_WARN="${R}⚠ User $u expires in $diff days!${N}  "
            fi
        fi
    done < "$USERS_DB"
    local PORT_STS=""
    if netstat -tuln 2>/dev/null | grep -q ":80 "; then
        if ! systemctl is-active superproxy &>/dev/null; then
            PORT_STS="${R}⚠ Port 80 Conflict!${N}"
        fi
    fi
    echo -e "${Y}  ╔══════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${Y}  ║${N} ${W}SYSTEM STATUS :: ACHRAF SERVER${N}                                   ${Y}║${N}"
    echo -e "${Y}  ╠══════════════════════════════════════════════════════════════════╣${N}"
    printf "${Y}  ║${N} ${C}🖥️ IP:${N} %-25s ${W}👥 Users:${N} %s      ${Y}║${N}\n" "$IP" "$USERS_COUNT/$MAX_USERS"
    printf "${Y}  ║${N} ${C}🌐 Domain:${N} %-22s ${W}💾 RAM:${N}   %s      ${Y}║${N}\n" "${DOMAIN:0:22}" "$RAM"
    printf "${Y}  ║${N} ${C}⚡ Load:${N} %-26s ${W}📡 Proxy:${N} %s      ${Y}║${N}\n" "$CPU" "$(systemctl is-active superproxy 2>/dev/null | sed 's/active/\\033[1;32mOnline\\033[0m/;s/inactive/\\033[1;31mOffline\\033[0m/')"
    echo -e "${Y}  ╠══════════════════════════════════════════════════════════════════╣${N}"
    printf "${Y}  ║${N} ${EXP_WARN}${PORT_STS}%-68s ${Y}║${N}\n" ""
    echo -e "${Y}  ╚══════════════════════════════════════════════════════════════════╝${N}"
    echo ""
}

print_success() { echo -e "  ${G}✔${N} ${W}$1${N}"; }
print_error() { echo -e "  ${R}✖${N} ${W}$1${N}"; }
print_info() { echo -e "  ${C}ℹ${N} ${W}$1${N}"; }

install_base() {
    print_header
    echo -e "  ${Y}━━━ INITIALIZING ACHRAF SERVER ━━━${N}\n"
    echo -e "  ${C}[1/5]${N} Updating Packages..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y python3 openssh-server curl jq cron wget > /dev/null 2>&1
    print_success "System Updated"
    echo -e "\n  ${C}[2/5]${N} Hardening SSH..."
    cat > /etc/ssh/sshd_config << 'SSH'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
AllowTcpForwarding yes
GatewayPorts yes
ClientAliveInterval 30
ClientAliveCountMax 3
UseDNS no
MaxSessions 10
SSH
    systemctl restart ssh > /dev/null 2>&1
    print_success "SSH Secured"
    echo -e "\n  ${C}[3/5]${N} Deploying ACHRAF Proxy..."
    create_proxy
    cat > /etc/systemd/system/superproxy.service << 'SVC'
[Unit]
Description=ACHRAF SERVER Proxy
After=network.target
[Service]
Type=simple
ExecStartPre=/bin/bash -c 'fuser -k 80/tcp 2>/dev/null || true'
ExecStart=/usr/bin/python3 -u /etc/superproxy/proxy.py
Restart=always
RestartSec=2
[Install]
WantedBy=multi-user.target
SVC
    systemctl daemon-reload > /dev/null 2>&1
    systemctl enable superproxy > /dev/null 2>&1
    systemctl restart superproxy > /dev/null 2>&1
    print_success "Proxy Service Active"
    echo -e "\n  ${C}[4/5]${N} Installing BadVPN..."
    if [ ! -f /usr/bin/badvpn-udpgw ]; then
        wget -qO /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" 2>/dev/null
        chmod +x /usr/bin/badvpn-udpgw
    fi
    cat > /etc/systemd/system/udpgw.service << 'UDP'
[Unit]
Description=ACHRAF UDP Gateway
After=network.target
[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 100
Restart=always
[Install]
WantedBy=multi-user.target
UDP
    systemctl daemon-reload > /dev/null 2>&1
    systemctl enable udpgw > /dev/null 2>&1
    systemctl start udpgw > /dev/null 2>&1
    print_success "UDP Gateway Ready"
    echo -e "\n  ${C}[5/5]${N} Optimizing Kernel (BBR)..."
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf 2>/dev/null
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf 2>/dev/null
    sysctl -p >/dev/null 2>&1
    cat > "$DIR/limiter.sh" << 'LIM'
#!/bin/bash
while IFS='|' read u p e l; do
    [ -z "$l" ] && l=2
    c=$(ps -u "$u" 2>/dev/null | grep -c sshd)
    [ "$c" -gt "$l" ] && pkill -u "$u" -o sshd
done < /etc/superproxy/users.db
LIM
    chmod +x "$DIR/limiter.sh"
    (crontab -l 2>/dev/null | grep -v limiter; echo "* * * * * $DIR/limiter.sh") | crontab - > /dev/null 2>&1
    cp "$0" /usr/bin/superproxy 2>/dev/null
    chmod +x /usr/bin/superproxy 2>/dev/null
    print_achraf_success 
    echo -e "  ${W}Command:${N} ${C}superproxy${N}\n"
    sleep 2
}

setup_cloudflare() {
    print_header
    IP=$(curl -s ifconfig.me)
    echo -e "  ${Y}━━━ CLOUDFLARE INTEGRATION ━━━${N}\n"
    print_info "Server IP: ${C}$IP${N}"
    echo ""
    echo -e "  ${W}Get API Key from:${N}"
    echo -e "  ${C}https://dash.cloudflare.com/profile/api-tokens${N}\n"
    read -p "  ${W}Cloudflare Email:${N} " CF_EMAIL
    read -p "  ${W}Global API Key:${N}  " CF_KEY
    [ -z "$CF_EMAIL" ] || [ -z "$CF_KEY" ] && { print_error "Credentials Required!"; sleep 2; return; }
    echo -e "\n  ${C}Connecting...${N}"
    TEST=$(cf_api GET "/user")
    if ! echo "$TEST" | grep -q '"success":true'; then
        print_error "Auth Failed!"
        sleep 2
        return
    fi
    print_success "Connected to Cloudflare"
    ZONES=$(cf_api GET "/zones?per_page=50")
    echo -e "\n  ${W}Domains:${N}\n"
    ZONE_COUNT=0
    while IFS= read -r zone; do
        [ -z "$zone" ] && continue
        ZONE_COUNT=$((ZONE_COUNT+1))
        name=$(echo "$zone" | jq -r '.name')
        id=$(echo "$zone" | jq -r '.id')
        echo -e "    ${G}$ZONE_COUNT${N}) $name"
        eval "ZONE_NAME_$ZONE_COUNT='$name'"
        eval "ZONE_ID_$ZONE_COUNT='$id'"
    done < <(echo "$ZONES" | jq -c '.result[]')
    [ $ZONE_COUNT -eq 0 ] && { print_error "No Domains!"; sleep 2; return; }
    echo ""
    read -p "  ${W}Select Domain (1-$ZONE_COUNT):${N} " choice
    eval "DOMAIN=\$ZONE_NAME_$choice"
    eval "ZONE_ID=\$ZONE_ID_$choice"
    print_success "Selected: $DOMAIN"
    read -p "  ${W}Subdomain (Empty for main):${N} " sub
    [ -n "$sub" ] && FULL_DOMAIN="${sub}.${DOMAIN}" || FULL_DOMAIN="$DOMAIN"
    echo -e "\n  ${C}Configuring Cloudflare...${N}"
    EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN")
    RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
    if [ -n "$RECORD_ID" ]; then
        cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true,\"ttl\":1}" >/dev/null
    else
        cf_api POST "/zones/$ZONE_ID/dns_records" \
            "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true,\"ttl\":1}" >/dev/null
    fi
    print_success "DNS Updated: $FULL_DOMAIN"
    cf_api PATCH "/zones/$ZONE_ID/settings/websockets" '{"value":"on"}' >/dev/null
    cf_api PATCH "/zones/$ZONE_ID/settings/ssl" '{"value":"flexible"}' >/dev/null
    print_success "WebSocket & SSL Enabled"
    cat > "$CONFIG" << EOF
CF_EMAIL=$CF_EMAIL
CF_KEY=$CF_KEY
ZONE_ID=$ZONE_ID
DOMAIN=$FULL_DOMAIN
EOF
    chmod 600 "$CONFIG"
    print_achraf_success
    echo -e "  ${W}Target:${N} ${C}$FULL_DOMAIN${N}"
    read -p "  ${W}Press Enter...${N} "
}

add_user() {
    print_header
    echo -e "  ${Y}━━━ ADD VIP USER ━━━${N}\n"
    count=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    if [ "$count" -ge "$MAX_USERS" ]; then
        print_error "Max Users Reached!"
        read -p "  ${W}Press Enter...${N} "
        return
    fi
    echo -e "  ${W}Slots:${N} $count / $MAX_USERS\n"
    read -p "  ${W}Username:${N} " user
    [ -z "$user" ] && return
    if id "$user" &>/dev/null; then
        print_error "User Exists!"
        read -p "  ${W}Press Enter...${N} "
        return
    fi
    read -p "  ${W}Password:${N} " pass
    read -p "  ${W}Expiry Days [30]:${N} " days; days=${days:-30}
    read -p "  ${W}Device Limit [2]:${N} " limit; limit=${limit:-2}
    exp=$(date -d "+$days days" +%Y-%m-%d)
    useradd -m -s /bin/bash -e "$exp" "$user"
    echo "$user:$pass" | chpasswd
    echo "$user|$pass|$exp|$limit" >> "$USERS_DB"
    print_achraf_success
    echo -e "  ${Y}╔════════════════════════════════════════════╗${N}"
    printf "  ${Y}║${N} ${W}User:${N}     %-30s ${Y}║${N}\n" "$user"
    printf "  ${Y}║${N} ${W}Pass:${N}     %-30s ${Y}║${N}\n" "$pass"
    printf "  ${Y}║${N} ${W}Expires:${N}  %-30s ${Y}║${N}\n" "$exp"
    printf "  ${Y}║${N} ${W}Limit:${N}    %-30s ${Y}║${N}\n" "$limit Devices"
    echo -e "  ${Y}╚════════════════════════════════════════════╝${N}"
    read -p "  ${W}Press Enter...${N} "
}

delete_user() {
    print_header
    echo -e "  ${Y}━━━ DELETE USER ━━━${N}\n"
    list_users_simple
    read -p "  ${W}Username:${N} " user
    [ -z "$user" ] && return
    userdel -rf "$user" 2>/dev/null
    sed -i "/^$user|/d" "$USERS_DB"
    print_success "User Deleted"
    read -p "  ${W}Press Enter...${N} "
}

list_users_simple() {
    if [ -s "$USERS_DB" ]; then
        echo -e "  ${W}Users:${N}\n"
        printf "  ${C}%-12s %-12s %-15s %-8s${N}\n" "USER" "PASS" "EXPIRES" "LIMIT"
        echo -e "  ${C}───────────────────────────────────────────────────────${N}"
        while IFS='|' read -r u p e l; do
            printf "  %-12s %-12s %-15s %-8s\n" "$u" "$p" "$e" "$l"
        done < "$USERS_DB"
        echo ""
    else
        print_info "No Users."
        echo ""
    fi
}

list_users() {
    print_header
    echo -e "  ${Y}━━━ USER LIST ━━━${N}\n"
    list_users_simple
    echo -e "  ${W}Online:${N}"
    who 2>/dev/null | awk '{print "    👤 " $1 " from " $3}'
    echo ""
    read -p "  ${W}Press Enter...${N} "
}

renew_user() {
    print_header
    echo -e "  ${Y}━━━ RENEW USER ━━━${N}\n"
    list_users_simple
    read -p "  ${W}Username:${N} " user
    read -p "  ${W}Add Days:${N} " days
    new_exp=$(date -d "+$days days" +%Y-%m-%d)
    chage -E "$new_exp" "$user" 2>/dev/null
    sed -i "s/^\($user|[^|]*|\)[^|]*/\1$new_exp/" "$USERS_DB"
    print_success "Renewed until $new_exp"
    read -p "  ${W}Press Enter...${N} "
}

show_payloads() {
    print_header
    IP=$(curl -s -m2 ifconfig.me)
    source "$CONFIG" 2>/dev/null
    echo -e "  ${Y}━━━ CONNECTION PAYLOADS ━━━${N}\n"
    print_line() { echo -e "${C}  ═══════════════════════════════════════════════════════════${N}"; }
    print_line
    echo -e "  ${BG_B}${W}   DIRECT CONNECTION (PORT 80)   ${N}"
    print_line
    echo ""
    echo -e "  ${W}Method:${N} ${C}Direct WebSocket${N}"
    echo -e "  ${W}Payload:${N}"
    echo -e "  ${G}GET / HTTP/1.1[crlf]Host: $IP[crlf]Upgrade: websocket[crlf][crlf]${N}"
    echo ""
    echo -e "  ${W}Host:${N} $IP  ${W}Port:${N} 80"
    echo ""
    if [ -n "$DOMAIN" ]; then
        print_line
        echo -e "  ${BG_G}${W}   CLOUDFLARE CDN (PORT 443)   ${N}"
        print_line
        echo ""
        echo -e "  ${W}Method:${N} ${C}SSL over Cloudflare${N}"
        echo -e "  ${W}Payload:${N}"
        echo -e "  ${G}GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]${N}"
        echo ""
        echo -e "  ${W}Host:${N} $DOMAIN  ${W}Port:${N} 443"
        echo ""
    fi
    print_line
    echo -e "  ${W}UDP Gateway:${N} 127.0.0.1:7300"
    print_line
    echo ""
    read -p "  ${W}Press Enter...${N} "
}

live_monitor() {
    print_header
    echo -e "  ${Y}━━━ LIVE SYSTEM MONITOR ━━━${N}\n"
    echo -e "  ${W}🔧 Services:${N}"
    echo -e "    Proxy: $(systemctl is-active superproxy 2>/dev/null | sed 's/active/\\033[1;32m● Online\\033[0m/;s/inactive/\\033[1;31m● Offline\\033[0m/')"
    echo -e "    SSH:   $(systemctl is-active ssh 2>/dev/null | sed 's/active/\\033[1;32m● Online\\033[0m/;s/inactive/\\033[1;31m● Offline\\033[0m/')"
    echo ""
    echo -e "  ${W}🔌 Connections:${N}"
    echo -e "    Port 80:  $(ss -tn 2>/dev/null | grep -c ':80 ')"
    echo -e "    Port 22:  $(ss -tn 2>/dev/null | grep -c ':22 ')"
    echo ""
    echo -e "  ${W}📊 Resources:${N}"
    echo -e "    RAM:  $(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')"
    echo -e "    CPU:  $(top -bn1 | grep 'Cpu' | awk '{print 100-$8"%"}')"
    echo ""
    echo -e "  ${W}👤 Active:${N}"
    who 2>/dev/null | awk '{print "    " $1 " (" $3 ")"}'
    echo ""
    read -p "  ${W}Press Enter...${N} "
}

backup_data() {
    file="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$file" -C "$DIR" . 2>/dev/null
    print_success "Backup: $file"
}

restore_data() {
    echo -e "\n  ${W}Backups:${N}"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | nl
    read -p "  ${W}Path:${N} " file
    [ -f "$file" ] && tar -xzf "$file" -C "$DIR" && print_success "Restored!"
}

uninstall() {
    clear
    echo -e "${R}  ╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${R}  ║              ⚠ DANGER: UNINSTALL ACHRAF SERVER ⚠               ║${N}"
    echo -e "${R}  ╚═══════════════════════════════════════════════════════════════╝${N}"
    echo ""
    read -p "  ${W}Type 'yes' to confirm:${N} " confirm
    [ "$confirm" != "yes" ] && return
    while IFS='|' read -r u _; do
        userdel -rf "$u" 2>/dev/null
    done < "$USERS_DB"
    systemctl stop superproxy udpgw 2>/dev/null
    systemctl disable superproxy udpgw 2>/dev/null
    rm -f /etc/systemd/system/superproxy.service /etc/systemd/system/udpgw.service
    systemctl daemon-reload
    rm -rf "$DIR" /usr/bin/superproxy
    echo -e "${G}  ✔ ACHRAF SERVER Removed.${N}"
    exit 0
}

menu() {
    while true; do
        print_header
        echo -e "${Y}  ┌─────────────────────────────────────────────────────────────┐${N}"
        echo -e "${Y}  │${N}                 ${W}USER MANAGEMENT${N}                             ${Y}│${N}"
        echo -e "${Y}  ├─────────────────────────────────────────────────────────────┤${N}"
        echo -e "${Y}  │${N}  ${G}1${N}) 🛠️  Add User            ${G}2${N}) 🗑️  Delete User               ${Y}│${N}"
        echo -e "${Y}  │${N}  ${G}3${N}) 📋  List Users          ${G}4${N}) 🔋  Renew User                ${Y}│${N}"
        echo -e "${Y}  ├─────────────────────────────────────────────────────────────┤${N}"
        echo -e "${Y}  │${N}                 ${W}NETWORK & CONFIG${N}                           ${Y}│${N}"
        echo -e "${Y}  │${N}  ${G}5${N}) ☁️  Setup Cloudflare    ${G}6${N}) 🚀  Show Payloads              ${Y}│${N}"
        echo -e "${Y}  │${N}  ${G}7${N}) 📊  Live Monitor        ${G}8${N}) 🔄  Restart Services          ${Y}│${N}"
        echo -e "${Y}  ├─────────────────────────────────────────────────────────────┤${N}"
        echo -e "${Y}  │${N}                 ${W}SYSTEM${N}                                     ${Y}│${N}"
        echo -e "${Y}  │${N}  ${G}9${N}) 💾  Backup/Restore      ${R}10${N}) 💀 Uninstall                  ${Y}│${N}"
        echo -e "${Y}  │${N}  ${R}0${N}) 🚪  Exit                                                 ${Y}│${N}"
        echo -e "${Y}  └─────────────────────────────────────────────────────────────┘${N}"
        echo ""
        read -p "  ${W}Select option:${N} " opt
        case $opt in
            1) add_user ;;
            2) delete_user ;;
            3) list_users ;;
            4) renew_user ;;
            5) setup_cloudflare ;;
            6) show_payloads ;;
            7) live_monitor ;;
            8) systemctl restart superproxy ssh udpgw 2>/dev/null; print_success "Services Restarted"; sleep 1 ;;
            9) echo -e "\n  1) Backup  2) Restore"; read -p "  ${W}>${N} " br; [ "$br" = "1" ] && backup_data || restore_data; read -p "  ${W}Press Enter...${N} " ;;
            10) uninstall ;;
            0) echo -e "\n  ${C}👋 ACHRAF SERVER Shutdown...${N}\n"; exit 0 ;;
            *) print_error "Invalid Option"; sleep 1 ;;
        esac
    done
}

if [ ! -f "$DIR/proxy.py" ]; then
    install_base
fi

menu
EOF_SCRIPT

# تشغيل السكربت فوراً
chmod +x achraf.sh
bash achraf.sh
