#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                                                                                           ║
# ║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗    ███████╗███████╗██████╗ ██╗   ██╗     ║
# ║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝    ██╔════╝██╔════╝██╔══██╗██║   ██║     ║
# ║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗      ███████╗█████╗  ██████╔╝██║   ██║     ║
# ║   ██║     ██║   ██║██╔═██╗ ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══╝      ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝     ║
# ║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗    ███████║███████╗██║  ██║ ╚████╔╝      ║
# ║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝       ║
# ║                                                                                                           ║
# ║                              🚀 LOKMANE SERVER ULTIMATE v3.0 🚀                                           ║
# ║                                                                                                           ║
# ║   ✦ Multi-Port SSH WebSocket (80, 443, 8080, 8880)     ✦ BadVPN UDPGW (Gaming/Calls)                     ║
# ║   ✦ Cloudflare API Integration                         ✦ Dropbear SSH (Low RAM)                         ║
# ║   ✦ User Management (5 VIP)                            ✦ Stunnel SSL                                    ║
# ║   ✦ Beautiful Banners                                  ✦ Optimized for AWS Free Tier                    ║
# ║                                                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝

VERSION="3.0"
DIR="/etc/lokmane"
CONFIG="$DIR/config"
USERS_DB="$DIR/users.db"
MAX_USERS=5

# Colors
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
M='\033[1;35m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'

mkdir -p "$DIR"
touch "$USERS_DB"

# ═══════════════════════════════════════════════════════════════════════════════
# CLOUDFLARE API
# ═══════════════════════════════════════════════════════════════════════════════
cf_api() {
    curl -s -X "$1" "https://api.cloudflare.com/client/v4$2" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_KEY" \
        -H "Content-Type: application/json" \
        ${3:+-d "$3"}
}

# ═══════════════════════════════════════════════════════════════════════════════
# CREATE LOKMANE BANNER
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
║   ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗                                ║
║   ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗                               ║
║   ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝                               ║
║   ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗                               ║
║   ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║                               ║
║   ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝                               ║
║                                                                                   ║
║═══════════════════════════════════════════════════════════════════════════════════║
║                                                                                   ║
║                    🌟 Welcome to LOKMANE VIP Server 🌟                            ║
║                                                                                   ║
║     ⚡ Ultra High Speed Connection          🔒 Military Grade Security            ║
║     🌍 Global Premium Network               💎 Exclusive VIP Access               ║
║     📱 WhatsApp/Gaming Support              🚀 Unlimited Bandwidth                ║
║                                                                                   ║
╚═══════════════════════════════════════════════════════════════════════════════════╝

BANNER

    # MOTD
    cat > /etc/motd << 'MOTD'

═══════════════════════════════════════════════════════════════════════════════════
                        ✨ LOKMANE SERVER - CONNECTION SUCCESSFUL ✨
═══════════════════════════════════════════════════════════════════════════════════
   
   🎉 Welcome VIP Member!
   
   📊 Server Status: ONLINE & OPTIMIZED
   🚀 Speed: UNLIMITED
   🔐 Encryption: MAXIMUM
   📱 UDP Support: ENABLED
   
   💡 Services Available:
      • SSH WebSocket (Ports: 80, 443, 8080, 8880)
      • BadVPN UDPGW (Port: 7300) - For Gaming & Calls
      • SSL/TLS Secure Connection
   
═══════════════════════════════════════════════════════════════════════════════════
                         Powered by LOKMANE SERVER v3.0
═══════════════════════════════════════════════════════════════════════════════════

MOTD
}

# ═══════════════════════════════════════════════════════════════════════════════
# MULTI-PORT PROXY (Working Core - Don't Touch!)
# ═══════════════════════════════════════════════════════════════════════════════
create_proxy() {
    cat > "$DIR/proxy.py" << 'PROXY'
#!/usr/bin/env python3
import socket
import threading
import sys

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
        
        def fwd(src, dst):
            try:
                while True:
                    d = src.recv(65536)
                    if not d: break
                    dst.sendall(d)
            except: pass
        
        t1 = threading.Thread(target=fwd, args=(client, ssh), daemon=True)
        t2 = threading.Thread(target=fwd, args=(ssh, client), daemon=True)
        t1.start(); t2.start()
        t1.join(); t2.join()
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
        sock.listen(100)
        print(f'Port {port} OK')
        while True:
            c, a = sock.accept()
            threading.Thread(target=handle, args=(c, port), daemon=True).start()
    except Exception as e:
        print(f'Port {port} Error: {e}')

# Start on multiple ports
ports = [80, 8080, 8880]
for p in ports:
    threading.Thread(target=start_server, args=(p,), daemon=True).start()

# Keep main thread alive
import time
while True:
    time.sleep(3600)
PROXY
    chmod +x "$DIR/proxy.py"
}

# ═══════════════════════════════════════════════════════════════════════════════
# BADVPN UDPGW (For Games & WhatsApp Calls)
# ═══════════════════════════════════════════════════════════════════════════════
install_badvpn() {
    echo -e "  ${Y}Installing BadVPN UDPGW...${N}"
    
    # Check if already installed
    if command -v badvpn-udpgw &>/dev/null; then
        echo -e "  ${G}✓ Already installed${N}"
        return
    fi
    
    # Install dependencies
    apt-get install -y cmake make gcc g++ 2>/dev/null
    
    # Download and compile
    cd /tmp
    wget -q https://github.com/nicolarevelant/badvpn/archive/refs/tags/1.999.130.tar.gz -O badvpn.tar.gz 2>/dev/null
    
    if [ -f badvpn.tar.gz ]; then
        tar xzf badvpn.tar.gz
        cd badvpn-1.999.130
        mkdir build && cd build
        cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 2>/dev/null
        make 2>/dev/null
        cp udpgw/badvpn-udpgw /usr/bin/ 2>/dev/null
        cd /tmp && rm -rf badvpn*
        echo -e "  ${G}✓ Compiled${N}"
    else
        # Fallback: try to get pre-built binary
        wget -q -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" 2>/dev/null
        chmod +x /usr/bin/badvpn-udpgw
        echo -e "  ${G}✓ Downloaded${N}"
    fi
    
    # Create service
    cat > /etc/systemd/system/badvpn.service << 'SVC'
[Unit]
Description=BadVPN UDPGW
After=network.target

[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=always

[Install]
WantedBy=multi-user.target
SVC

    systemctl daemon-reload
    systemctl enable badvpn 2>/dev/null
    systemctl start badvpn 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# DROPBEAR (Lightweight SSH - Low RAM)
# ═══════════════════════════════════════════════════════════════════════════════
install_dropbear() {
    echo -e "  ${Y}Installing Dropbear...${N}"
    apt-get install -y dropbear 2>/dev/null
    
    # Configure
    cat > /etc/default/dropbear << 'DROP'
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109"
DROPBEAR_BANNER="/etc/ssh/banner"
DROP

    systemctl enable dropbear 2>/dev/null
    systemctl restart dropbear 2>/dev/null
    echo -e "  ${G}✓ Dropbear on ports 109, 143${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STUNNEL (SSL Wrapper)
# ═══════════════════════════════════════════════════════════════════════════════
install_stunnel() {
    echo -e "  ${Y}Installing Stunnel...${N}"
    apt-get install -y stunnel4 2>/dev/null
    
    # Generate certificate
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/CN=LOKMANE-SERVER" \
        -keyout /etc/stunnel/stunnel.pem \
        -out /etc/stunnel/stunnel.pem 2>/dev/null
    
    # Configure
    cat > /etc/stunnel/stunnel.conf << 'STUN'
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:109

[openssh]
accept = 445
connect = 127.0.0.1:22
STUN

    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4 2>/dev/null
    systemctl enable stunnel4 2>/dev/null
    systemctl restart stunnel4 2>/dev/null
    echo -e "  ${G}✓ Stunnel SSL on ports 443, 445${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALL EVERYTHING
# ═══════════════════════════════════════════════════════════════════════════════
install() {
    clear
    echo -e "${M}"
    cat << 'LOGO'
    
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║                                                                               ║
   ║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗              ║
   ║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝              ║
   ║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗                ║
   ║   ██║     ██║   ██║██╔═██╗ ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══╝                ║
   ║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗              ║
   ║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝              ║
   ║                                                                               ║
   ║                    🚀 INSTALLING SERVER v3.0... 🚀                            ║
   ║                                                                               ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
    
LOGO
    echo -e "${N}"
    
    echo -e "  ${Y}[1/8]${N} Updating system..."
    apt-get update -qq
    apt-get install -y --no-install-recommends python3 openssh-server curl jq openssl 2>/dev/null
    echo -e "  ${G}✓ Done${N}"
    
    echo -e "  ${Y}[2/8]${N} Creating LOKMANE banner..."
    create_banner
    echo -e "  ${G}✓ Done${N}"
    
    echo -e "  ${Y}[3/8]${N} Configuring SSH..."
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
    systemctl restart ssh
    echo -e "  ${G}✓ Done${N}"
    
    echo -e "  ${Y}[4/8]${N} Creating multi-port proxy..."
    create_proxy
    
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

    systemctl daemon-reload
    systemctl enable lokmane
    systemctl restart lokmane
    echo -e "  ${G}✓ Proxy on ports 80, 8080, 8880${N}"
    
    echo -e "  ${Y}[5/8]${N} Installing BadVPN UDPGW..."
    install_badvpn
    
    echo -e "  ${Y}[6/8]${N} Installing Dropbear..."
    install_dropbear
    
    echo -e "  ${Y}[7/8]${N} Installing Stunnel SSL..."
    install_stunnel
    
    echo -e "  ${Y}[8/8]${N} Finishing setup..."
    cp "$0" /usr/bin/lokmane 2>/dev/null
    chmod +x /usr/bin/lokmane 2>/dev/null
    echo -e "  ${G}✓ Done${N}"
    
    sleep 1
    clear
    echo -e "${G}"
    cat << 'DONE'
    
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║                                                                               ║
   ║                    ✓ LOKMANE SERVER INSTALLED! ✓                              ║
   ║                                                                               ║
   ╠═══════════════════════════════════════════════════════════════════════════════╣
   ║                                                                               ║
   ║   📡 Services Running:                                                        ║
   ║                                                                               ║
   ║      SSH WebSocket:   Ports 80, 8080, 8880                                    ║
   ║      SSH Direct:      Port 22                                                 ║
   ║      Dropbear:        Ports 109, 143                                          ║
   ║      Stunnel SSL:     Ports 443, 445                                          ║
   ║      BadVPN UDPGW:    Port 7300 (UDP)                                         ║
   ║                                                                               ║
   ║   🎮 For Games/WhatsApp: Enable UDP Gateway to 127.0.0.1:7300                 ║
   ║                                                                               ║
   ║   Command: lokmane                                                            ║
   ║                                                                               ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
    
DONE
    echo -e "${N}"
    read -p "  Press Enter to continue..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# USER MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════
add_user() {
    clear
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                    👤 ADD NEW VIP USER                        ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}"
    echo ""
    
    COUNT=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    echo -e "  ${W}Users:${N} $COUNT / $MAX_USERS"
    
    if [ "$COUNT" -ge "$MAX_USERS" ]; then
        echo -e "\n  ${R}⚠ Limit reached!${N}"
        read -p "  Enter..."; return
    fi
    
    echo ""
    read -p "  Username: " USER
    [ -z "$USER" ] && return
    
    if id "$USER" &>/dev/null; then
        echo -e "  ${R}Exists!${N}"
        read -p "  Enter..."; return
    fi
    
    read -p "  Password: " PASS
    read -p "  Days [30]: " DAYS
    DAYS=${DAYS:-30}
    
    EXP=$(date -d "+$DAYS days" +%Y-%m-%d)
    
    useradd -m -s /bin/bash -e "$EXP" "$USER"
    echo "$USER:$PASS" | chpasswd
    echo "$USER|$PASS|$EXP" >> "$USERS_DB"
    
    echo ""
    echo -e "  ${G}╔═══════════════════════════════════════════════════════╗${N}"
    echo -e "  ${G}║              ✓ VIP USER CREATED                       ║${N}"
    echo -e "  ${G}╠═══════════════════════════════════════════════════════╣${N}"
    echo -e "  ${G}║${N}  👤 Username:   ${C}$USER${N}"
    echo -e "  ${G}║${N}  🔑 Password:   ${C}$PASS${N}"
    echo -e "  ${G}║${N}  📅 Expires:    ${Y}$EXP${N}"
    echo -e "  ${G}║${N}  🎮 UDP Port:   ${Y}7300${N}"
    echo -e "  ${G}╚═══════════════════════════════════════════════════════╝${N}"
    echo ""
    read -p "  Enter..."
}

list_users() {
    clear
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                    📋 VIP USER LIST                           ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}"
    echo ""
    
    if [ -s "$USERS_DB" ]; then
        printf "  ${W}%-12s %-12s %-12s %-10s${N}\n" "USER" "PASS" "EXPIRES" "STATUS"
        echo "  ─────────────────────────────────────────────────────"
        while IFS='|' read -r u p e; do
            if [[ $(date -d "$e" +%s 2>/dev/null) -lt $(date +%s) ]]; then
                printf "  ${R}%-12s %-12s %-12s EXPIRED${N}\n" "$u" "$p" "$e"
            else
                DAYS=$(( ($(date -d "$e" +%s) - $(date +%s)) / 86400 ))
                printf "  ${G}%-12s${N} %-12s ${Y}%-12s${N} ${G}%d days${N}\n" "$u" "$p" "$e" "$DAYS"
            fi
        done < "$USERS_DB"
    else
        echo -e "  ${Y}No users yet${N}"
    fi
    echo ""
    read -p "  Enter..."
}

quick_user() {
    QUSER="vip$(shuf -i 10-99 -n 1)"
    QPASS=$(shuf -i 1000-9999 -n 1)
    QEXP=$(date -d '+30 days' +%Y-%m-%d)
    
    useradd -m -s /bin/bash -e "$QEXP" "$QUSER" 2>/dev/null
    echo "$QUSER:$QPASS" | chpasswd
    echo "$QUSER|$QPASS|$QEXP" >> "$USERS_DB"
    
    echo -e "\n  ${G}✓ Quick: $QUSER / $QPASS${N}"
    sleep 2
}

delete_user() {
    read -p "  Delete username: " USER
    [ -n "$USER" ] && { userdel -rf "$USER" 2>/dev/null; sed -i "/^$USER|/d" "$USERS_DB"; echo -e "  ${G}✓${N}"; }
    sleep 1
}

renew_user() {
    read -p "  Username: " USER
    read -p "  Add days: " DAYS
    [ -n "$USER" ] && [ -n "$DAYS" ] && {
        NEW_EXP=$(date -d "+$DAYS days" +%Y-%m-%d)
        chage -E "$NEW_EXP" "$USER" 2>/dev/null
        sed -i "s/^\($USER|[^|]*|\).*/\1$NEW_EXP/" "$USERS_DB"
        echo -e "  ${G}✓ Until $NEW_EXP${N}"
    }
    sleep 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLOUDFLARE SETUP
# ═══════════════════════════════════════════════════════════════════════════════
setup_cloudflare() {
    clear
    IP=$(curl -s ifconfig.me)
    
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                   ☁️  CLOUDFLARE SETUP                        ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}"
    echo ""
    echo -e "  ${W}Server:${N} ${G}$IP${N}"
    echo ""
    
    read -p "  Email: " CF_EMAIL
    read -p "  API Key: " CF_KEY
    [ -z "$CF_EMAIL" ] || [ -z "$CF_KEY" ] && return
    
    ZONES=$(cf_api GET "/zones?per_page=50")
    [ ! "$(echo "$ZONES" | grep '"success":true')" ] && { echo -e "  ${R}Failed!${N}"; read -p "  Enter..."; return; }
    
    ZONE_COUNT=$(echo "$ZONES" | jq -r '.result | length')
    echo -e "\n  ${W}Domains:${N}"
    for ((i=0; i<ZONE_COUNT; i++)); do
        echo -e "    ${G}$((i+1))${N}) $(echo "$ZONES" | jq -r ".result[$i].name")"
    done
    
    read -p "  Select: " CHOICE
    IDX=$((CHOICE-1))
    DOMAIN=$(echo "$ZONES" | jq -r ".result[$IDX].name")
    ZONE_ID=$(echo "$ZONES" | jq -r ".result[$IDX].id")
    
    read -p "  Subdomain (empty=main): " SUB
    [ -n "$SUB" ] && FULL_DOMAIN="${SUB}.${DOMAIN}" || FULL_DOMAIN="$DOMAIN"
    
    EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN")
    RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
    
    if [ -n "$RECORD_ID" ]; then
        cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null
    else
        cf_api POST "/zones/$ZONE_ID/dns_records" "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true}" >/dev/null
    fi
    
    cf_api PATCH "/zones/$ZONE_ID/settings/websockets" '{"value":"on"}' >/dev/null
    cf_api PATCH "/zones/$ZONE_ID/settings/ssl" '{"value":"flexible"}' >/dev/null
    
    echo "CF_EMAIL=$CF_EMAIL" > "$CONFIG"
    echo "CF_KEY=$CF_KEY" >> "$CONFIG"
    echo "ZONE_ID=$ZONE_ID" >> "$CONFIG"
    echo "DOMAIN=$FULL_DOMAIN" >> "$CONFIG"
    
    echo -e "\n  ${G}✓ Configured: $FULL_DOMAIN${N}"
    read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# PAYLOADS
# ═══════════════════════════════════════════════════════════════════════════════
show_payloads() {
    clear
    IP=$(curl -s ifconfig.me)
    source "$CONFIG" 2>/dev/null
    
    echo -e "${C}╔═══════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                         📱 CONNECTION PAYLOADS                               ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════════════════════╝${N}"
    echo ""
    
    echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "  ${W}📡 WEBSOCKET (HTTP Custom, HTTP Injector)${N}"
    echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
    echo -e "  ${C}Payload:${N}"
    echo -e "  GET / HTTP/1.1[crlf]Host: $IP[crlf]Upgrade: websocket[crlf][crlf]"
    echo ""
    echo -e "  ${W}Ports:${N} ${G}80${N}, ${G}8080${N}, ${G}8880${N}"
    echo -e "  ${W}UDP:${N}   ${Y}127.0.0.1:7300${N}"
    echo ""
    
    echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "  ${W}🔒 SSL/STUNNEL (Direct)${N}"
    echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
    echo -e "  ${W}Host:${N} ${G}$IP${N}"
    echo -e "  ${W}Port:${N} ${G}443${N} or ${G}445${N}"
    echo -e "  ${W}SSL:${N}  ${G}ON${N}"
    echo ""
    
    echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "  ${W}📞 DROPBEAR (Low RAM)${N}"
    echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
    echo -e "  ${W}Host:${N} ${G}$IP${N}"
    echo -e "  ${W}Port:${N} ${G}109${N} or ${G}143${N}"
    echo ""
    
    if [ -n "$DOMAIN" ]; then
        echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
        echo -e "  ${W}☁️  CLOUDFLARE CDN${N}"
        echo -e "  ${Y}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
        echo ""
        echo -e "  ${C}Payload:${N}"
        echo -e "  GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
        echo ""
        echo -e "  ${W}Host:${N}  ${G}$DOMAIN${N}"
        echo -e "  ${W}Port:${N}  ${G}443${N}"
        echo -e "  ${W}SSL:${N}   ${G}ON${N}"
        echo ""
    fi
    
    read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATUS
# ═══════════════════════════════════════════════════════════════════════════════
show_status() {
    clear
    IP=$(curl -s -m2 ifconfig.me)
    source "$CONFIG" 2>/dev/null
    
    echo -e "${C}╔═══════════════════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║                         📊 LOKMANE SERVER STATUS                             ║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════════════════════╝${N}"
    echo ""
    
    echo -e "  ${W}🔧 Services:${N}"
    for svc in lokmane ssh dropbear stunnel4 badvpn; do
        ST=$(systemctl is-active $svc 2>/dev/null)
        echo -e "    $svc: $([ "$ST" = "active" ] && echo -e "${G}● Running${N}" || echo -e "${R}○ Stopped${N}")"
    done
    echo ""
    
    echo -e "  ${W}🌐 Network:${N}"
    echo -e "    IP: ${G}$IP${N}"
    [ -n "$DOMAIN" ] && echo -e "    Domain: ${C}$DOMAIN${N}"
    echo ""
    
    echo -e "  ${W}📡 Ports:${N}"
    echo -e "    WebSocket: ${Y}80, 8080, 8880${N}"
    echo -e "    SSH:       ${Y}22${N}"
    echo -e "    Dropbear:  ${Y}109, 143${N}"
    echo -e "    SSL:       ${Y}443, 445${N}"
    echo -e "    UDPGW:     ${Y}7300${N}"
    echo ""
    
    RAM=$(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')
    echo -e "  ${W}💻 RAM:${N} ${Y}$RAM${N}"
    echo ""
    
    USERS=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    CONN=$(ss -tn | grep -c ":80\|:8080\|:8880" 2>/dev/null || echo 0)
    echo -e "  ${W}👥 Users:${N} ${G}$USERS${N} / $MAX_USERS"
    echo -e "  ${W}🔗 Connections:${N} ${G}$CONN${N}"
    echo ""
    
    read -p "  Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# MENU
# ═══════════════════════════════════════════════════════════════════════════════
menu() {
    while true; do
        clear
        IP=$(curl -s -m2 ifconfig.me 2>/dev/null || echo "...")
        source "$CONFIG" 2>/dev/null
        USERS=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
        
        echo -e "${M}"
        cat << 'LOGO'
    
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║                                                                               ║
   ║   ██╗      ██████╗ ██╗  ██╗███╗   ███╗ █████╗ ███╗   ██╗███████╗              ║
   ║   ██║     ██╔═══██╗██║ ██╔╝████╗ ████║██╔══██╗████╗  ██║██╔════╝              ║
   ║   ██║     ██║   ██║█████╔╝ ██╔████╔██║███████║██╔██╗ ██║█████╗                ║
   ║   ██║     ██║   ██║██╔═██╗ ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══╝                ║
   ║   ███████╗╚██████╔╝██║  ██╗██║ ╚═╝ ██║██║  ██║██║ ╚████║███████╗              ║
   ║   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝              ║
   ║                                                                               ║
   ║                        🚀 SERVER v3.0 🚀                                      ║
   ║                                                                               ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
    
LOGO
        echo -e "${N}"
        
        echo -e "    ${W}IP:${N}       ${G}$IP${N}"
        [ -n "$DOMAIN" ] && echo -e "    ${W}Domain:${N}   ${C}$DOMAIN${N}"
        echo -e "    ${W}Users:${N}    ${Y}$USERS${N} / $MAX_USERS"
        echo ""
        
        echo -e "${C}    ╔═════════════════════════════════════════════════════════════════════╗${N}"
        echo -e "${C}    ║${N}     ${W}USER MANAGEMENT${N}                    ${W}SERVER${N}                      ${C}║${N}"
        echo -e "${C}    ╠═════════════════════════════════════════════════════════════════════╣${N}"
        echo -e "${C}    ║${N}   ${G}1${N}) Add User                     ${G}7${N}) Show Payloads               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}2${N}) Delete User                  ${G}8${N}) Server Status               ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}3${N}) List Users                   ${G}9${N}) Restart All                 ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}4${N}) Renew User                  ${G}10${N}) Cloudflare Setup            ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}5${N}) Quick User                  ${G}11${N}) View Logs                   ${C}║${N}"
        echo -e "${C}    ║${N}   ${G}6${N}) ──────                       ${R}0${N}) Exit                        ${C}║${N}"
        echo -e "${C}    ╚═════════════════════════════════════════════════════════════════════╝${N}"
        echo ""
        
        read -p "    Select: " OPT
        
        case $OPT in
            1) add_user ;;
            2) delete_user ;;
            3) list_users ;;
            4) renew_user ;;
            5) quick_user ;;
            7) show_payloads ;;
            8) show_status ;;
            9)
                systemctl restart lokmane ssh dropbear stunnel4 badvpn 2>/dev/null
                echo -e "\n    ${G}✓ All services restarted${N}"
                sleep 1
                ;;
            10) setup_cloudflare ;;
            11) journalctl -u lokmane -n 50 --no-pager; read -p "  Enter..." ;;
            0) 
                clear
                echo -e "${G}"
                cat << 'BYE'
    
   ╔═══════════════════════════════════════════════════════════════════════════════╗
   ║                                                                               ║
   ║                    👋 LOKMANE SERVER - Goodbye! 👋                            ║
   ║                                                                               ║
   ║                         Command: lokmane                                      ║
   ║                                                                               ║
   ╚═══════════════════════════════════════════════════════════════════════════════╝
    
BYE
                echo -e "${N}"
                exit 0
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# ENTRY
# ═══════════════════════════════════════════════════════════════════════════════
[ ! -f "$DIR/proxy.py" ] && install
menu
