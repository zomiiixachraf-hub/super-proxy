#!/bin/bash
# SUPER PROXY ULTIMATE v2.0 - Clean Version
set -e
export DEBIAN_FRONTEND=noninteractive

VERSION="2.0"
DIR="/etc/superproxy"
CONFIG="$DIR/config"
USERS_DB="$DIR/users.db"
BACKUP_DIR="/root/superproxy-backups"
MAX_USERS=5

# Colors
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'

mkdir -p "$DIR" "$BACKUP_DIR"
touch "$USERS_DB"

# Cloudflare API
cf_api() {
    curl -s -X "$1" "https://api.cloudflare.com/client/v4$2" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_KEY" \
        -H "Content-Type: application/json" \
        ${3:+-d "$3"}
}

# Create Proxy
create_proxy() {
    cat > "$DIR/proxy.py" << 'PROXYEND'
#!/usr/bin/env python3
import socket
import threading

LISTEN_PORT = 80
SSH_PORT = 22

def forward(src, dst):
    try:
        while True:
            data = src.recv(32768)
            if not data:
                break
            dst.sendall(data)
    except:
        pass

def handle(client, addr):
    ssh = None
    try:
        client.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        client.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        
        request = b''
        while b'\r\n\r\n' not in request and len(request) < 4096:
            chunk = client.recv(2048)
            if not chunk:
                return
            request += chunk
        
        ssh = socket.socket()
        ssh.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        ssh.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        ssh.connect(('127.0.0.1', SSH_PORT))
        
        client.sendall(b'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n')
        
        idx = request.find(b'\r\n\r\n')
        if idx != -1 and len(request) > idx + 4:
            ssh.sendall(request[idx + 4:])
        
        t1 = threading.Thread(target=forward, args=(client, ssh), daemon=True)
        t2 = threading.Thread(target=forward, args=(ssh, client), daemon=True)
        t1.start()
        t2.start()
        t1.join()
        t2.join()
    except:
        pass
    finally:
        try:
            client.close()
        except:
            pass
        try:
            if ssh:
                ssh.close()
        except:
            pass

if __name__ == '__main__':
    server = socket.socket()
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
    server.bind(('0.0.0.0', LISTEN_PORT))
    server.listen(10)
    print(f'[PROXY] Port {LISTEN_PORT} Ready')
    while True:
        try:
            c, a = server.accept()
            threading.Thread(target=handle, args=(c, a), daemon=True).start()
        except:
            pass
PROXYEND
    chmod +x "$DIR/proxy.py"
}

clear_screen() { clear; }

print_banner() {
    echo -e "${C}"
    echo "    ╔═══════════════════════════════════════════════════════════════╗"
    echo "    ║              🚀 SUPER PROXY ULTIMATE v2.0 🚀                  ║"
    echo "    ╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${N}"
}

print_line() {
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
}

# Install
install_base() {
    clear_screen
    print_banner
    echo -e "  ${Y}Installing...${N}\n"
    
    apt-get update -qq
    apt-get install -y python3 openssh-server curl jq cron 2>/dev/null
    echo -e "  ${G}✓ Packages${N}"
    
    cat > /etc/ssh/sshd_config << 'SSHCFG'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
AllowTcpForwarding yes
GatewayPorts yes
ClientAliveInterval 30
ClientAliveCountMax 3
UseDNS no
MaxSessions 10
SSHCFG
    systemctl restart ssh
    echo -e "  ${G}✓ SSH${N}"
    
    create_proxy
    
    cat > /etc/systemd/system/superproxy.service << 'SVCEND'
[Unit]
Description=Super Proxy
After=network.target
[Service]
Type=simple
ExecStartPre=/bin/bash -c 'fuser -k 80/tcp 2>/dev/null || true'
ExecStart=/usr/bin/python3 /etc/superproxy/proxy.py
Restart=always
RestartSec=2
[Install]
WantedBy=multi-user.target
SVCEND
    
    systemctl daemon-reload
    systemctl enable superproxy
    systemctl restart superproxy
    echo -e "  ${G}✓ Proxy Service${N}"
    
    if [ ! -f /usr/bin/badvpn-udpgw ]; then
        wget -qO /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" 2>/dev/null
        chmod +x /usr/bin/badvpn-udpgw
    fi
    
    cat > /etc/systemd/system/udpgw.service << 'UDPEND'
[Unit]
Description=UDP Gateway
After=network.target
[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 100
Restart=always
[Install]
WantedBy=multi-user.target
UDPEND
    systemctl daemon-reload
    systemctl enable udpgw
    systemctl start udpgw 2>/dev/null
    echo -e "  ${G}✓ BadVPN${N}"
    
    grep -q "net.ipv4.tcp_congestion_control" /etc/sysctl.conf || {
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1
    }
    echo -e "  ${G}✓ BBR${N}"
    
    cat > "$DIR/limiter.sh" << 'LIMEND'
#!/bin/bash
while IFS='|' read u p e l; do
    [ -z "$l" ] && l=2
    c=$(ps -u "$u" 2>/dev/null | grep -c sshd)
    [ "$c" -gt "$l" ] && pkill -u "$u" -o sshd
done < /etc/superproxy/users.db
LIMEND
    chmod +x "$DIR/limiter.sh"
    (crontab -l 2>/dev/null | grep -v limiter; echo "* * * * * $DIR/limiter.sh") | crontab -
    echo -e "  ${G}✓ Limiter${N}"
    
    cp "$0" /usr/bin/superproxy 2>/dev/null
    chmod +x /usr/bin/superproxy 2>/dev/null
    
    echo -e "\n  ${G}✓ Done! Use: superproxy${N}\n"
    sleep 2
}

# Cloudflare Setup
setup_cloudflare() {
    clear_screen
    print_banner
    
    IP=$(curl -s ifconfig.me)
    echo -e "  ${Y}━━━ CLOUDFLARE SETUP ━━━${N}\n"
    echo -e "  ${W}Server IP:${N} ${G}$IP${N}\n"
    
    read -p "  Cloudflare Email: " CF_EMAIL
    read -p "  Global API Key: " CF_KEY
    
    [ -z "$CF_EMAIL" ] || [ -z "$CF_KEY" ] && { echo -e "\n${R}Required!${N}"; sleep 2; return; }
    
    echo -e "\n  ${Y}Connecting...${N}"
    
    TEST=$(cf_api GET "/user")
    if ! echo "$TEST" | grep -q '"success":true'; then
        echo -e "  ${R}✗ Auth failed!${N}"
        sleep 2
        return
    fi
    echo -e "  ${G}✓ Connected${N}"
    
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
    
    [ $ZONE_COUNT -eq 0 ] && { echo -e "  ${R}No domains!${N}"; sleep 2; return; }
    
    echo ""
    read -p "  Select (1-$ZONE_COUNT): " choice
    
    eval "DOMAIN=\$ZONE_NAME_$choice"
    eval "ZONE_ID=\$ZONE_ID_$choice"
    
    read -p "  Subdomain (empty=main): " sub
    [ -n "$sub" ] && FULL_DOMAIN="${sub}.${DOMAIN}" || FULL_DOMAIN="$DOMAIN"
    
    echo -e "\n  ${Y}Configuring...${N}"
    
    EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN")
    RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
    
    if [ -n "$RECORD_ID" ]; then
        cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true,\"ttl\":1}" >/dev/null
    else
        cf_api POST "/zones/$ZONE_ID/dns_records" \
            "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true,\"ttl\":1}" >/dev/null
    fi
    echo -e "  ${G}✓ DNS${N}"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/websockets" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓ WebSocket${N}"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/ssl" '{"value":"flexible"}' >/dev/null
    echo -e "  ${G}✓ SSL${N}"
    
    cat > "$CONFIG" << EOF
CF_EMAIL=$CF_EMAIL
CF_KEY=$CF_KEY
ZONE_ID=$ZONE_ID
DOMAIN=$FULL_DOMAIN
EOF
    chmod 600 "$CONFIG"
    
    echo -e "\n  ${G}✓ Domain: $FULL_DOMAIN${N}"
    read -p "  Press Enter..."
}

# User Management
add_user() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ ADD USER ━━━${N}\n"
    
    count=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    if [ "$count" -ge "$MAX_USERS" ]; then
        echo -e "  ${R}Max $MAX_USERS users!${N}"
        read -p "  Press Enter..."
        return
    fi
    
    echo -e "  ${W}Users:${N} $count/$MAX_USERS\n"
    
    read -p "  Username: " user
    [ -z "$user" ] && return
    
    if id "$user" &>/dev/null; then
        echo -e "\n  ${R}Exists!${N}"
        read -p "  Press Enter..."
        return
    fi
    
    read -p "  Password: " pass
    [ -z "$pass" ] && pass=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)
    
    read -p "  Days [30]: " days
    days=${days:-30}
    
    read -p "  Devices [2]: " limit
    limit=${limit:-2}
    
    exp=$(date -d "+$days days" +%Y-%m-%d)
    
    useradd -m -s /bin/bash -e "$exp" "$user"
    echo "$user:$pass" | chpasswd
    echo "$user|$pass|$exp|$limit" >> "$USERS_DB"
    
    source "$CONFIG" 2>/dev/null
    IP=$(curl -s -m2 ifconfig.me)
    
    echo -e "\n  ${G}✓ Created!${N}\n"
    print_line
    echo -e "  ${W}Username:${N} ${C}$user${N}"
    echo -e "  ${W}Password:${N} ${C}$pass${N}"
    echo -e "  ${W}Expires:${N}  ${Y}$exp${N}"
    echo -e "  ${W}Devices:${N}  ${Y}$limit${N}"
    echo -e "  ${W}Server:${N}   ${G}${DOMAIN:-$IP}${N}"
    print_line
    
    read -p "  Press Enter..."
}

delete_user() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ DELETE USER ━━━${N}\n"
    
    list_users_simple
    
    read -p "  Username: " user
    [ -z "$user" ] && return
    
    userdel -rf "$user" 2>/dev/null
    sed -i "/^$user|/d" "$USERS_DB"
    
    echo -e "\n  ${G}✓ Deleted${N}"
    read -p "  Press Enter..."
}

list_users_simple() {
    if [ -s "$USERS_DB" ]; then
        printf "  ${C}%-12s %-12s %-12s %-6s${N}\n" "USER" "PASS" "EXPIRES" "LIMIT"
        echo -e "  ${C}────────────────────────────────────────────${N}"
        while IFS='|' read -r u p e l; do
            printf "  %-12s %-12s %-12s %-6s\n" "$u" "$p" "$e" "$l"
        done < "$USERS_DB"
        echo ""
    else
        echo -e "  ${Y}No users${N}\n"
    fi
}

list_users() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ USERS ━━━${N}\n"
    list_users_simple
    echo -e "  ${W}Online:${N}"
    who 2>/dev/null | awk '{print "    " $1}' | sort -u
    read -p "  Press Enter..."
}

renew_user() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ RENEW USER ━━━${N}\n"
    list_users_simple
    
    read -p "  Username: " user
    read -p "  Add days: " days
    
    new_exp=$(date -d "+$days days" +%Y-%m-%d)
    chage -E "$new_exp" "$user" 2>/dev/null
    sed -i "s/^\($user|[^|]*|\)[^|]*/\1$new_exp/" "$USERS_DB"
    
    echo -e "\n  ${G}✓ Renewed: $new_exp${N}"
    read -p "  Press Enter..."
}

# Payloads
show_payloads() {
    clear_screen
    print_banner
    
    IP=$(curl -s -m2 ifconfig.me)
    source "$CONFIG" 2>/dev/null
    
    echo -e "  ${Y}━━━ PAYLOADS ━━━${N}\n"
    
    print_line
    echo -e "  ${W}Direct (Port 80):${N}"
    echo -e "  GET / HTTP/1.1[crlf]Host: $IP[crlf]Upgrade: websocket[crlf][crlf]"
    echo ""
    
    if [ -n "$DOMAIN" ]; then
        print_line
        echo -e "  ${W}Cloudflare (Port 443 SSL):${N}"
        echo -e "  GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
        echo ""
    fi
    
    print_line
    echo -e "  ${W}UDP:${N} 7300"
    
    read -p "  Press Enter..."
}

# Monitor
live_monitor() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ MONITOR ━━━${N}\n"
    
    echo -e "  ${W}Services:${N}"
    for svc in superproxy ssh udpgw; do
        status=$(systemctl is-active $svc 2>/dev/null)
        [ "$status" = "active" ] && echo -e "    $svc: ${G}Running${N}" || echo -e "    $svc: ${R}Stopped${N}"
    done
    echo ""
    
    echo -e "  ${W}Connections:${N}"
    echo -e "    Port 80: $(ss -tn 2>/dev/null | grep -c ':80 ')"
    echo -e "    SSH:     $(ss -tn 2>/dev/null | grep -c ':22 ')"
    echo ""
    
    echo -e "  ${W}Resources:${N}"
    echo -e "    RAM: $(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')"
    echo ""
    
    echo -e "  ${W}Online:${N}"
    who 2>/dev/null | awk '{print "    " $1 " - " $3 " " $4}'
    
    read -p "  Press Enter..."
}

# SSH Banner
setup_banner() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ SSH BANNER ━━━${N}\n"
    
    echo -e "  ${G}1${N}) VIP Premium"
    echo -e "  ${G}2${N}) Gaming"
    echo -e "  ${G}3${N}) Custom"
    echo -e "  ${R}4${N}) Remove"
    echo -e "  ${R}0${N}) Back"
    echo ""
    read -p "  Select: " opt
    
    source "$CONFIG" 2>/dev/null
    IP=$(curl -s -m2 ifconfig.me)
    
    case $opt in
        1)
            cat > /etc/ssh/banner.txt << BANNEREND
╔══════════════════════════════════════════════════════════╗
║     ★ ★ ★   V I P   P R E M I U M   ★ ★ ★               ║
╠══════════════════════════════════════════════════════════╣
║   Server: ${DOMAIN:-$IP}
║   Status: PREMIUM VIP                                    ║
║   Welcome!                                               ║
╚══════════════════════════════════════════════════════════╝
BANNEREND
            ;;
        2)
            cat > /etc/ssh/banner.txt << BANNEREND
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█   🎮 G A M I N G   S E R V E R 🎮                        █
█   Server: ${DOMAIN:-$IP}
█   UDP: Port 7300                                         █
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
BANNEREND
            ;;
        3)
            echo -e "  Enter banner (empty line to finish):"
            > /etc/ssh/banner.txt
            while true; do
                read -p "  > " line
                [ -z "$line" ] && break
                echo "$line" >> /etc/ssh/banner.txt
            done
            ;;
        4)
            rm -f /etc/ssh/banner.txt
            sed -i '/^Banner/d' /etc/ssh/sshd_config
            systemctl restart ssh 2>/dev/null
            echo -e "  ${G}✓ Removed${N}"
            sleep 1
            return
            ;;
        *) return ;;
    esac
    
    grep -q "^Banner" /etc/ssh/sshd_config || echo "Banner /etc/ssh/banner.txt" >> /etc/ssh/sshd_config
    systemctl restart ssh 2>/dev/null
    echo -e "  ${G}✓ Banner set${N}"
    sleep 1
}

# Backup
backup_data() {
    file="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$file" -C "$DIR" . 2>/dev/null
    echo -e "\n  ${G}✓ Saved: $file${N}"
}

restore_data() {
    echo -e "\n  ${W}Backups:${N}"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | nl
    read -p "  Path: " file
    [ -f "$file" ] && tar -xzf "$file" -C "$DIR" && echo -e "${G}✓ Restored${N}"
}

# Uninstall
uninstall() {
    clear_screen
    print_banner
    echo -e "  ${R}━━━ UNINSTALL ━━━${N}\n"
    read -p "  Type 'yes': " confirm
    
    [ "$confirm" != "yes" ] && return
    
    while IFS='|' read -r u _; do
        userdel -rf "$u" 2>/dev/null
    done < "$USERS_DB"
    
    systemctl stop superproxy udpgw 2>/dev/null
    systemctl disable superproxy udpgw 2>/dev/null
    rm -f /etc/systemd/system/superproxy.service
    rm -f /etc/systemd/system/udpgw.service
    systemctl daemon-reload
    
    rm -rf "$DIR"
    rm -f /usr/bin/superproxy
    rm -f /etc/ssh/banner.txt
    
    echo -e "\n  ${G}✓ Done${N}"
    exit 0
}

# Menu
menu() {
    while true; do
        clear_screen
        
        IP=$(curl -s -m2 ifconfig.me 2>/dev/null || echo "...")
        source "$CONFIG" 2>/dev/null
        DOMAIN=${DOMAIN:-"-"}
        proxy_status=$(systemctl is-active superproxy 2>/dev/null)
        user_count=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
        ram=$(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')
        
        print_banner
        
        echo -e "${C}  ┌─────────────────────────────────────────────────────────────┐${N}"
        printf "${C}  │${N} IP: ${G}%-20s${N} Users: ${Y}%s/%s${N}              ${C}│${N}\n" "$IP" "$user_count" "$MAX_USERS"
        printf "${C}  │${N} Domain: ${C}%-16s${N} RAM: ${Y}%s${N}             ${C}│${N}\n" "${DOMAIN:0:16}" "$ram"
        printf "${C}  │${N} Proxy: $([ "$proxy_status" = "active" ] && echo -e "${G}Running${N}" || echo -e "${R}Stopped${N}")                                              ${C}│${N}\n"
        echo -e "${C}  └─────────────────────────────────────────────────────────────┘${N}"
        echo ""
        
        echo -e "${C}  ┌─────────────────────────────────────────────────────────────┐${N}"
        echo -e "${C}  │${N}  ${G}1${N}) Add User      ${G}2${N}) Delete User   ${G}3${N}) List Users      ${C}│${N}"
        echo -e "${C}  │${N}  ${G}4${N}) Renew User    ${G}5${N}) Cloudflare    ${G}6${N}) Payloads        ${C}│${N}"
        echo -e "${C}  │${N}  ${G}7${N}) Monitor       ${G}8${N}) SSH Banner    ${G}9${N}) Restart All     ${C}│${N}"
        echo -e "${C}  │${N}  ${G}10${N}) Backup       ${G}11${N}) Restore      ${R}12${N}) Uninstall      ${C}│${N}"
        echo -e "${C}  │${N}  ${R}0${N}) Exit                                                  ${C}│${N}"
        echo -e "${C}  └─────────────────────────────────────────────────────────────┘${N}"
        echo ""
        
        read -p "  Select: " opt
        
        case $opt in
            1) add_user ;;
            2) delete_user ;;
            3) list_users ;;
            4) renew_user ;;
            5) setup_cloudflare ;;
            6) show_payloads ;;
            7) live_monitor ;;
            8) setup_banner ;;
            9)
                systemctl restart superproxy ssh udpgw 2>/dev/null
                echo -e "\n  ${G}✓ Restarted${N}"
                sleep 1
                ;;
            10) backup_data; read -p "  Press Enter..." ;;
            11) restore_data; read -p "  Press Enter..." ;;
            12) uninstall ;;
            0) echo -e "\n  ${C}Bye!${N}\n"; exit 0 ;;
        esac
    done
}

# Entry Point
if [ ! -f "$DIR/proxy.py" ]; then
    install_base
fi

menu
