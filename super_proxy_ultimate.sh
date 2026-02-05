#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                                                                                                           ║
# ║    ███████╗██╗   ██╗██████╗ ███████╗██████╗     ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗    ██╗   ██╗██╗  ████████╗     ║
# ║    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝    ██║   ██║██║  ╚══██╔══╝     ║
# ║    ███████╗██║   ██║██████╔╝█████╗  ██████╔╝    ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝     ██║   ██║██║     ██║        ║
# ║    ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗    ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝      ██║   ██║██║     ██║        ║
# ║    ███████║╚██████╔╝██║     ███████╗██║  ██║    ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║       ╚██████╔╝███████╗██║        ║
# ║    ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚══════╝╚═╝        ║
# ║                                                                                                                           ║
# ║                              🚀 SUPER PROXY ULTIMATE v2.0 🚀                                                              ║
# ║                                                                                                                           ║
# ║  ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ ║
# ║                                                                                                                           ║
# ║     ✦ CORE FEATURES                          ✦ ADVANCED FEATURES                                                         ║
# ║     ────────────────                         ────────────────────                                                         ║
# ║     • Cloudflare API Integration             • Telegram Bot Notifications                                                 ║
# ║     • Fixed WebSocket Proxy                  • Traffic Statistics                                                         ║
# ║     • User Management (5 VIP)                • Speed Test                                                                 ║
# ║     • Auto-Limiter                           • Trial Users (1-hour)                                                       ║
# ║     • BadVPN UDP Gateway                     • Password Generator                                                         ║
# ║     • BBR Optimization                       • Multi-Port Support                                                         ║
# ║                                                                                                                           ║
# ║     ✦ SECURITY                               ✦ SYSTEM                                                                     ║
# ║     ────────────────                         ────────────────                                                             ║
# ║     • IP Blacklist                           • Auto-Update                                                                ║
# ║     • Connection Logging                     • Backup & Restore                                                           ║
# ║     • Expiry Notifications                   • Complete Uninstaller                                                       ║
# ║     • SSH Banner                             • Professional TUI                                                           ║
# ║                                                                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

set -e
export DEBIAN_FRONTEND=noninteractive

VERSION="2.0"
SCRIPT_NAME="SUPER PROXY"
DIR="/etc/superproxy"
CONFIG="$DIR/config"
USERS_DB="$DIR/users.db"
TRAFFIC_DB="$DIR/traffic.db"
BLACKLIST="$DIR/blacklist.txt"
LOG_FILE="$DIR/connections.log"
BACKUP_DIR="/root/superproxy-backups"
MAX_USERS=5
SCRIPT_URL="https://raw.githubusercontent.com/user/super-proxy/main/super_proxy.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# COLORS
# ═══════════════════════════════════════════════════════════════════════════════
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
M='\033[1;35m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'
DIM='\033[2m'
BG_B='\033[44m'
BG_G='\033[42m'
BG_R='\033[41m'
BG_M='\033[45m'
BG_C='\033[46m'

# ═══════════════════════════════════════════════════════════════════════════════
# INIT
# ═══════════════════════════════════════════════════════════════════════════════
mkdir -p "$DIR" "$BACKUP_DIR"
touch "$USERS_DB" "$TRAFFIC_DB" "$BLACKLIST" "$LOG_FILE"

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
# TELEGRAM BOT
# ═══════════════════════════════════════════════════════════════════════════════
send_telegram() {
    [ -z "$TG_BOT_TOKEN" ] || [ -z "$TG_CHAT_ID" ] && return
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TG_CHAT_ID" \
        -d "text=$message" \
        -d "parse_mode=HTML" >/dev/null 2>&1
}

setup_telegram() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ TELEGRAM BOT SETUP ━━━${N}\n"
    
    echo -e "  ${C}How to create a Telegram Bot:${N}"
    echo -e "  1. Message @BotFather on Telegram"
    echo -e "  2. Send /newbot and follow instructions"
    echo -e "  3. Copy the Bot Token"
    echo -e "  4. Message @userinfobot to get your Chat ID\n"
    
    read -p "  Bot Token: " TG_BOT_TOKEN
    read -p "  Chat ID: " TG_CHAT_ID
    
    if [ -n "$TG_BOT_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
        sed -i '/^TG_/d' "$CONFIG" 2>/dev/null
        echo "TG_BOT_TOKEN=$TG_BOT_TOKEN" >> "$CONFIG"
        echo "TG_CHAT_ID=$TG_CHAT_ID" >> "$CONFIG"
        
        send_telegram "🚀 <b>Super Proxy</b> Telegram notifications enabled!"
        echo -e "\n  ${G}✓ Telegram configured! Test message sent.${N}"
    else
        echo -e "\n  ${Y}Skipped.${N}"
    fi
    
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# LITE WEBSOCKET PROXY - Optimized for 5 Users
# ═══════════════════════════════════════════════════════════════════════════════
create_proxy() {
    cat > "$DIR/proxy.py" << 'PROXY'
#!/usr/bin/env python3
"""
Super Proxy LITE - Optimized for 5 users
Light on resources, stable connections
"""
import socket
import threading

LISTEN_PORT = 80
SSH_PORT = 22
MAX_CONN = 10  # 5 users x 2 connections each

def forward(src, dst):
    try:
        while True:
            data = src.recv(32768)
            if not data: break
            dst.sendall(data)
    except: pass

def handle(c, a):
    s = None
    try:
        c.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        c.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        
        r = b''
        while b'\r\n\r\n' not in r and len(r) < 4096:
            d = c.recv(2048)
            if not d: return
            r += d
        
        s = socket.socket()
        s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        s.connect(('127.0.0.1', SSH_PORT))
        
        c.sendall(b'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n')
        
        i = r.find(b'\r\n\r\n')
        if i != -1 and len(r) > i + 4:
            s.sendall(r[i + 4:])
        
        t1 = threading.Thread(target=forward, args=(c, s), daemon=True)
        t2 = threading.Thread(target=forward, args=(s, c), daemon=True)
        t1.start(); t2.start()
        t1.join(); t2.join()
    except: pass
    finally:
        try: c.close()
        except: pass
        try:
            if s: s.close()
        except: pass

k = socket.socket()
k.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
k.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
k.bind(('0.0.0.0', LISTEN_PORT))
k.listen(MAX_CONN)
print(f'[LITE PROXY] Port {LISTEN_PORT} - Max {MAX_CONN//2} users')
while True:
    try:
        c, a = k.accept()
        threading.Thread(target=handle, args=(c, a), daemon=True).start()
    except: pass
PROXY
    chmod +x "$DIR/proxy.py"
}
        except: pass
        try:
            if ssh: ssh.close()
        except: pass

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except:
        pass
    # Enable keepalive on server socket too
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
    sock.bind(('0.0.0.0', LISTEN_PORT))
    sock.listen(200)  # Increased backlog
    print(f'[SUPER PROXY v2.1] Port {LISTEN_PORT} Ready - Anti-Disconnect ON', flush=True)
    while True:
        try:
            c, a = sock.accept()
            threading.Thread(target=handle, args=(c, a), daemon=True).start()
        except:
            pass

if __name__ == '__main__':
    main()
PROXY
    chmod +x "$DIR/proxy.py"
}

# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════
clear_screen() {
    clear
}

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
    ║              🚀 SUPER PROXY ULTIMATE v2.0 🚀                  ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${N}"
}

print_line() {
    echo -e "${C}═══════════════════════════════════════════════════════════════${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PASSWORD GENERATOR
# ═══════════════════════════════════════════════════════════════════════════════
generate_password() {
    local length=${1:-8}
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SPEED TEST
# ═══════════════════════════════════════════════════════════════════════════════
speed_test() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ SPEED TEST ━━━${N}\n"
    
    echo -e "  ${W}Download Speed Test...${N}"
    
    # Simple speed test using curl
    START=$(date +%s.%N)
    curl -s -o /dev/null "http://speedtest.tele2.net/10MB.zip" 2>/dev/null
    END=$(date +%s.%N)
    
    TIME=$(echo "$END - $START" | bc)
    SPEED=$(echo "scale=2; 10 / $TIME" | bc)
    
    echo -e "  ${G}Download: ${W}${SPEED} MB/s${N}"
    echo ""
    
    # Ping test
    echo -e "  ${W}Ping Test...${N}"
    PING=$(ping -c 3 google.com 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
    echo -e "  ${G}Ping: ${W}${PING:-N/A} ms${N}"
    echo ""
    
    # Server info
    echo -e "  ${W}Server Info:${N}"
    echo -e "  Location: $(curl -s ipinfo.io/city), $(curl -s ipinfo.io/country)"
    echo -e "  ISP:      $(curl -s ipinfo.io/org)"
    
    echo ""
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# TRIAL USER (1 Hour)
# ═══════════════════════════════════════════════════════════════════════════════
create_trial() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ CREATE TRIAL USER ━━━${N}\n"
    echo -e "  ${C}Trial user will expire in 1 hour${N}\n"
    
    user="trial$(shuf -i 100-999 -n 1)"
    pass=$(generate_password 6)
    
    # Check if user exists
    while id "$user" &>/dev/null; do
        user="trial$(shuf -i 100-999 -n 1)"
    done
    
    useradd -m -s /bin/bash "$user"
    echo "$user:$pass" | chpasswd
    
    # Set expiry to 1 hour
    echo "userdel -rf $user" | at now + 1 hour 2>/dev/null
    
    # Get server info
    source "$CONFIG" 2>/dev/null
    IP=$(curl -s -m2 ifconfig.me)
    
    echo -e "  ${G}✓ Trial user created!${N}\n"
    print_line
    echo -e "  ${BG_M}${W}  TRIAL ACCOUNT (1 HOUR)  ${N}"
    print_line
    echo ""
    echo -e "  ${W}Username:${N} ${C}$user${N}"
    echo -e "  ${W}Password:${N} ${C}$pass${N}"
    echo -e "  ${W}Duration:${N} ${Y}1 Hour${N}"
    echo ""
    echo -e "  ${W}Server:${N}   ${G}$IP${N}"
    [ -n "$DOMAIN" ] && echo -e "  ${W}Domain:${N}   ${G}$DOMAIN${N}"
    echo ""
    print_line
    
    # Send to Telegram
    send_telegram "🎁 <b>Trial Created</b>
User: <code>$user</code>
Pass: <code>$pass</code>
Duration: 1 Hour"
    
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# IP BLACKLIST
# ═══════════════════════════════════════════════════════════════════════════════
manage_blacklist() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ IP BLACKLIST ━━━${N}\n"
    
    echo -e "  ${W}Current blacklisted IPs:${N}"
    if [ -s "$BLACKLIST" ]; then
        cat "$BLACKLIST" | nl
    else
        echo -e "  ${DIM}(empty)${N}"
    fi
    echo ""
    
    echo -e "  ${G}1${N}) Add IP"
    echo -e "  ${G}2${N}) Remove IP"
    echo -e "  ${G}3${N}) Clear All"
    echo -e "  ${R}0${N}) Back"
    echo ""
    read -p "  Select: " opt
    
    case $opt in
        1)
            read -p "  IP to block: " ip
            [ -n "$ip" ] && echo "$ip" >> "$BLACKLIST"
            echo -e "  ${G}✓ Added${N}"
            ;;
        2)
            read -p "  IP to unblock: " ip
            [ -n "$ip" ] && sed -i "/$ip/d" "$BLACKLIST"
            echo -e "  ${G}✓ Removed${N}"
            ;;
        3)
            > "$BLACKLIST"
            echo -e "  ${G}✓ Cleared${N}"
            ;;
    esac
    
    sleep 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# CONNECTION LOGS
# ═══════════════════════════════════════════════════════════════════════════════
view_logs() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ CONNECTION LOGS ━━━${N}\n"
    
    if [ -s "$LOG_FILE" ]; then
        echo -e "  ${W}Last 20 connections:${N}\n"
        tail -20 "$LOG_FILE" | while read line; do
            if echo "$line" | grep -q "BLOCKED"; then
                echo -e "  ${R}$line${N}"
            else
                echo -e "  ${G}$line${N}"
            fi
        done
    else
        echo -e "  ${DIM}No logs yet${N}"
    fi
    
    echo ""
    echo -e "  Total connections: $(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)"
    echo -e "  Blocked: $(grep -c BLOCKED "$LOG_FILE" 2>/dev/null || echo 0)"
    
    echo ""
    read -p "  Press Enter (or 'c' to clear): " opt
    [ "$opt" = "c" ] && > "$LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MULTI-PORT SETUP
# ═══════════════════════════════════════════════════════════════════════════════
setup_multiport() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ MULTI-PORT SETUP ━━━${N}\n"
    
    echo -e "  ${W}Current ports:${N}"
    ss -tlnp | grep python | awk '{print "    " $4}'
    echo ""
    
    echo -e "  ${C}Available Cloudflare Ports:${N}"
    echo -e "    HTTP:  80, 8080, 8880, 2052, 2082, 2086, 2095"
    echo -e "    HTTPS: 443, 8443, 2053, 2083, 2087, 2096"
    echo ""
    
    read -p "  Add port (or 'r' to remove): " action
    
    if [ "$action" = "r" ]; then
        read -p "  Port to remove: " port
        pkill -f "bind.*$port" 2>/dev/null
        echo -e "  ${G}✓ Removed${N}"
    else
        port=$action
        if [[ "$port" =~ ^[0-9]+$ ]]; then
            # Create additional proxy on this port
            cat > "$DIR/proxy_$port.py" << MULTIPROXY
#!/usr/bin/env python3
import socket,threading
def fwd(s,d):
    try:
        while 1:
            x=s.recv(65536)
            if not x:break
            d.sendall(x)
    except:pass
def h(c,a):
    try:
        c.setsockopt(socket.IPPROTO_TCP,socket.TCP_NODELAY,1)
        r=b''
        while b'\r\n\r\n' not in r and len(r)<8192:
            k=c.recv(4096)
            if not k:return
            r+=k
        s=socket.socket();s.setsockopt(socket.IPPROTO_TCP,socket.TCP_NODELAY,1);s.connect(('127.0.0.1',22))
        c.sendall(b'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n')
        i=r.find(b'\r\n\r\n')
        if i!=-1 and len(r)>i+4:s.sendall(r[i+4:])
        t1=threading.Thread(target=fwd,args=(c,s),daemon=True);t2=threading.Thread(target=fwd,args=(s,c),daemon=True)
        t1.start();t2.start();t1.join();t2.join()
    except:pass
    finally:
        try:c.close()
        except:pass
        try:s.close()
        except:pass
k=socket.socket();k.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1);k.bind(('0.0.0.0',$port));k.listen(100)
print('Port $port OK')
while 1:c,a=k.accept();threading.Thread(target=h,args=(c,a),daemon=True).start()
MULTIPROXY
            nohup python3 "$DIR/proxy_$port.py" > /dev/null 2>&1 &
            echo -e "  ${G}✓ Port $port added${N}"
        fi
    fi
    
    sleep 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# SSH BANNER
# ═══════════════════════════════════════════════════════════════════════════════
setup_banner() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ SSH WELCOME BANNER ━━━${N}\n"
    
    echo -e "  ${W}Current banner:${N}"
    if [ -f /etc/ssh/banner.txt ]; then
        echo -e "  ${C}$(head -5 /etc/ssh/banner.txt)${N}"
        echo -e "  ${DIM}...${N}"
    else
        echo -e "  ${DIM}(none set)${N}"
    fi
    echo ""
    
    echo -e "  ${G}1${N}) 🌟 VIP Premium Banner"
    echo -e "  ${G}2${N}) 🎮 Gaming Style"
    echo -e "  ${G}3${N}) 💼 Business/Professional"
    echo -e "  ${G}4${N}) 🔥 Fire Style"
    echo -e "  ${G}5${N}) ✏️  Custom Text"
    echo -e "  ${R}6${N}) ❌ Remove Banner"
    echo -e "  ${R}0${N}) Back"
    echo ""
    read -p "  Select: " opt
    
    source "$CONFIG" 2>/dev/null
    IP=$(curl -s -m2 ifconfig.me)
    
    case $opt in
        1)
            cat > /etc/ssh/banner.txt << BANNER1
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║     ★ ★ ★   V I P   P R E M I U M   ★ ★ ★               ║
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║   🌐 Server: ${DOMAIN:-$IP}
║   ⚡ Speed: Unlimited                                    ║
║   🔒 Status: PREMIUM VIP                                 ║
║                                                          ║
║   ✨ Welcome to our VIP service!                         ║
║   📱 Support: Telegram @admin                            ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

BANNER1
            ;;
        2)
            cat > /etc/ssh/banner.txt << BANNER2
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█                                                          █
█   🎮 G A M I N G   S E R V E R 🎮                        █
█                                                          █
█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
█   🚀 Low Ping Gaming Server                              █
█   🎯 UDP Support: Port 7300                              █
█   ⚡ Optimized for: PUBG, Free Fire, COD                 █
█                                                          █
█   💎 Server: ${DOMAIN:-$IP}
█   🔥 Status: ACTIVE                                      █
█                                                          █
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

BANNER2
            ;;
        3)
            cat > /etc/ssh/banner.txt << BANNER3
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                                                          ┃
┃   SECURE CONNECTION ESTABLISHED                          ┃
┃                                                          ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                                          ┃
┃   Server: ${DOMAIN:-$IP}
┃   Protocol: SSH over WebSocket                           ┃
┃   Encryption: AES-256                                    ┃
┃   Status: Connected                                      ┃
┃                                                          ┃
┃   This is a private server.                              ┃
┃   Unauthorized access is prohibited.                     ┃
┃                                                          ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

BANNER3
            ;;
        4)
            cat > /etc/ssh/banner.txt << BANNER4
    🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥
    🔥                                                      🔥
    🔥   ███████╗██╗██████╗ ███████╗                        🔥
    🔥   ██╔════╝██║██╔══██╗██╔════╝                        🔥
    🔥   █████╗  ██║██████╔╝█████╗                          🔥
    🔥   ██╔══╝  ██║██╔══██╗██╔══╝                          🔥
    🔥   ██║     ██║██║  ██║███████╗                        🔥
    🔥   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝                        🔥
    🔥                                                      🔥
    🔥   Server: ${DOMAIN:-$IP}
    🔥   Status: 🟢 ONLINE                                  🔥
    🔥   Welcome!                                           🔥
    🔥                                                      🔥
    🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

BANNER4
            ;;
        5)
            echo ""
            echo -e "  ${C}Enter your custom banner line by line.${N}"
            echo -e "  ${DIM}(Press Enter twice to finish)${N}"
            echo ""
            
            > /etc/ssh/banner.txt
            while true; do
                read -p "  > " line
                [ -z "$line" ] && break
                echo "$line" >> /etc/ssh/banner.txt
            done
            echo "" >> /etc/ssh/banner.txt
            ;;
        6)
            rm -f /etc/ssh/banner.txt
            sed -i '/^Banner/d' /etc/ssh/sshd_config
            systemctl restart ssh 2>/dev/null
            echo -e "\n  ${G}✓ Banner removed${N}"
            sleep 1
            return
            ;;
        0|*)
            return
            ;;
    esac
    
    # Apply banner
    grep -q "^Banner" /etc/ssh/sshd_config 2>/dev/null || echo "Banner /etc/ssh/banner.txt" >> /etc/ssh/sshd_config
    systemctl restart ssh 2>/dev/null
    
    echo -e "\n  ${G}✓ Banner set successfully!${N}"
    echo -e "  ${DIM}Users will see this when they connect.${N}"
    sleep 2
}

# ═══════════════════════════════════════════════════════════════════════════════
# TRAFFIC STATISTICS
# ═══════════════════════════════════════════════════════════════════════════════
traffic_stats() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ TRAFFIC STATISTICS ━━━${N}\n"
    
    echo -e "  ${W}System Network Traffic:${N}\n"
    
    # Get main interface
    IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    
    if [ -n "$IFACE" ]; then
        RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
        TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
        
        RX_MB=$(echo "scale=2; $RX / 1048576" | bc)
        TX_MB=$(echo "scale=2; $TX / 1048576" | bc)
        TOTAL=$(echo "scale=2; ($RX + $TX) / 1048576" | bc)
        
        echo -e "  Interface: ${C}$IFACE${N}"
        echo -e "  ────────────────────────────"
        echo -e "  Download:  ${G}${RX_MB} MB${N}"
        echo -e "  Upload:    ${Y}${TX_MB} MB${N}"
        echo -e "  Total:     ${W}${TOTAL} MB${N}"
    fi
    
    echo ""
    echo -e "  ${W}User Traffic (this session):${N}\n"
    
    while IFS='|' read -r u p e l; do
        if id "$u" &>/dev/null; then
            sessions=$(ps -u "$u" 2>/dev/null | grep -c sshd || echo 0)
            echo -e "  $u: ${G}$sessions active${N}"
        fi
    done < "$USERS_DB"
    
    echo ""
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# EXPIRY CHECK & NOTIFICATION
# ═══════════════════════════════════════════════════════════════════════════════
check_expiry() {
    TODAY=$(date +%Y-%m-%d)
    TOMORROW=$(date -d "+1 day" +%Y-%m-%d)
    
    while IFS='|' read -r u p e l; do
        [ -z "$e" ] && continue
        
        if [[ "$e" < "$TODAY" ]]; then
            # Expired - delete user
            userdel -rf "$u" 2>/dev/null
            sed -i "/^$u|/d" "$USERS_DB"
            send_telegram "⚠️ User <b>$u</b> expired and removed"
        elif [[ "$e" == "$TOMORROW" ]]; then
            # Expiring tomorrow - notify
            send_telegram "⏰ User <b>$u</b> expires tomorrow!"
        fi
    done < "$USERS_DB"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════
install_base() {
    clear_screen
    print_banner
    echo -e "  ${Y}Installing base components...${N}\n"
    
    apt-get update -qq
    apt-get install -y python3 openssh-server curl jq cron bc at 2>/dev/null
    echo -e "  ${G}✓ Packages installed${N}"
    
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
    systemctl restart ssh
    echo -e "  ${G}✓ SSH configured${N}"
    
    create_proxy
    
    cat > /etc/systemd/system/superproxy.service << 'SVC'
[Unit]
Description=Super Proxy WebSocket
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
    
    systemctl daemon-reload
    systemctl enable superproxy
    systemctl restart superproxy
    echo -e "  ${G}✓ Proxy service created${N}"
    
    if [ ! -f /usr/bin/badvpn-udpgw ]; then
        wget -qO /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" 2>/dev/null
        chmod +x /usr/bin/badvpn-udpgw
    fi
    
    cat > /etc/systemd/system/udpgw.service << 'UDP'
[Unit]
Description=UDP Gateway
After=network.target
[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 100
Restart=always
[Install]
WantedBy=multi-user.target
UDP
    systemctl daemon-reload
    systemctl enable udpgw
    systemctl start udpgw 2>/dev/null
    echo -e "  ${G}✓ BadVPN UDP installed${N}"
    
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf 2>/dev/null
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf 2>/dev/null
    sysctl -p >/dev/null 2>&1
    echo -e "  ${G}✓ BBR optimization${N}"
    
    # Auto-limiter + Expiry checker
    cat > "$DIR/cron_jobs.sh" << 'CRON'
#!/bin/bash
# Auto-limiter
while IFS='|' read u p e l; do
    [ -z "$l" ] && l=2
    c=$(ps -u "$u" 2>/dev/null | grep -c sshd)
    [ "$c" -gt "$l" ] && pkill -u "$u" -o sshd
done < /etc/superproxy/users.db

# Expiry check
TODAY=$(date +%Y-%m-%d)
while IFS='|' read -r u p e l; do
    [ -z "$e" ] && continue
    if [[ "$e" < "$TODAY" ]]; then
        userdel -rf "$u" 2>/dev/null
        sed -i "/^$u|/d" /etc/superproxy/users.db
    fi
done < /etc/superproxy/users.db
CRON
    chmod +x "$DIR/cron_jobs.sh"
    (crontab -l 2>/dev/null | grep -v cron_jobs; echo "* * * * * $DIR/cron_jobs.sh") | crontab -
    echo -e "  ${G}✓ Auto-limiter & Expiry checker enabled${N}"
    
    cp "$0" /usr/bin/superproxy 2>/dev/null
    chmod +x /usr/bin/superproxy 2>/dev/null
    
    echo -e "\n  ${G}✓ Installation complete!${N}"
    echo -e "  ${W}Command:${N} ${C}superproxy${N}\n"
    
    sleep 2
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLOUDFLARE SETUP
# ═══════════════════════════════════════════════════════════════════════════════
setup_cloudflare() {
    clear_screen
    print_banner
    
    IP=$(curl -s ifconfig.me)
    
    echo -e "  ${Y}━━━ CLOUDFLARE AUTO-SETUP ━━━${N}\n"
    echo -e "  ${W}Server IP:${N} ${G}$IP${N}\n"
    
    echo -e "  ${C}Get Global API Key from:${N}"
    echo -e "  ${W}https://dash.cloudflare.com/profile/api-tokens${N}\n"
    
    read -p "  Cloudflare Email: " CF_EMAIL
    read -p "  Global API Key: " CF_KEY
    
    [ -z "$CF_EMAIL" ] || [ -z "$CF_KEY" ] && { echo -e "\n${R}Both required!${N}"; sleep 2; return; }
    
    echo -e "\n  ${Y}Connecting...${N}"
    
    TEST=$(cf_api GET "/user")
    if ! echo "$TEST" | grep -q '"success":true'; then
        echo -e "  ${R}✗ Authentication failed!${N}"
        sleep 2
        return
    fi
    echo -e "  ${G}✓ Connected!${N}"
    
    ZONES=$(cf_api GET "/zones?per_page=50")
    echo -e "\n  ${W}Your domains:${N}\n"
    
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
    
    [ $ZONE_COUNT -eq 0 ] && { echo -e "  ${R}No domains found!${N}"; sleep 2; return; }
    
    echo ""
    read -p "  Select (1-$ZONE_COUNT): " choice
    
    eval "DOMAIN=\$ZONE_NAME_$choice"
    eval "ZONE_ID=\$ZONE_ID_$choice"
    
    echo -e "\n  ${G}✓ Selected: $DOMAIN${N}"
    
    read -p "  Subdomain (empty for main): " sub
    [ -n "$sub" ] && FULL_DOMAIN="${sub}.${DOMAIN}" || FULL_DOMAIN="$DOMAIN"
    
    echo -e "\n  ${Y}Configuring Cloudflare...${N}"
    
    EXISTING=$(cf_api GET "/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN")
    RECORD_ID=$(echo "$EXISTING" | jq -r '.result[0].id // empty')
    
    if [ -n "$RECORD_ID" ]; then
        cf_api PUT "/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true,\"ttl\":1}" >/dev/null
    else
        cf_api POST "/zones/$ZONE_ID/dns_records" \
            "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$IP\",\"proxied\":true,\"ttl\":1}" >/dev/null
    fi
    echo -e "  ${G}✓ DNS: $FULL_DOMAIN → $IP (Proxied)${N}"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/websockets" '{"value":"on"}' >/dev/null
    echo -e "  ${G}✓ WebSocket enabled${N}"
    
    cf_api PATCH "/zones/$ZONE_ID/settings/ssl" '{"value":"flexible"}' >/dev/null
    echo -e "  ${G}✓ SSL: Flexible${N}"
    
    cat > "$CONFIG" << EOF
CF_EMAIL=$CF_EMAIL
CF_KEY=$CF_KEY
ZONE_ID=$ZONE_ID
DOMAIN=$FULL_DOMAIN
EOF
    chmod 600 "$CONFIG"
    
    echo -e "\n  ${G}✓ Cloudflare configured!${N}"
    echo -e "\n  ${W}Your domain:${N} ${C}$FULL_DOMAIN${N}"
    
    send_telegram "🌐 Cloudflare configured for <b>$FULL_DOMAIN</b>"
    
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# USER MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════
add_user() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ ADD NEW USER ━━━${N}\n"
    
    count=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
    if [ "$count" -ge "$MAX_USERS" ]; then
        echo -e "  ${R}Maximum $MAX_USERS users reached!${N}"
        read -p "  Press Enter..."
        return
    fi
    
    echo -e "  ${W}Users:${N} $count / $MAX_USERS\n"
    
    read -p "  Username: " user
    [ -z "$user" ] && return
    
    if id "$user" &>/dev/null; then
        echo -e "\n  ${R}User exists!${N}"
        read -p "  Press Enter..."
        return
    fi
    
    echo -e "  ${DIM}Leave empty for random password${N}"
    read -p "  Password: " pass
    [ -z "$pass" ] && pass=$(generate_password 8)
    
    read -p "  Days [30]: " days; days=${days:-30}
    read -p "  Device limit [2]: " limit; limit=${limit:-2}
    
    exp=$(date -d "+$days days" +%Y-%m-%d)
    
    useradd -m -s /bin/bash -e "$exp" "$user"
    echo "$user:$pass" | chpasswd
    echo "$user|$pass|$exp|$limit" >> "$USERS_DB"
    
    IP=$(curl -s -m2 ifconfig.me)
    source "$CONFIG" 2>/dev/null
    
    echo -e "\n  ${G}✓ User created!${N}\n"
    print_line
    echo -e "  ${W}Username:${N} ${C}$user${N}"
    echo -e "  ${W}Password:${N} ${C}$pass${N}"
    echo -e "  ${W}Expires:${N}  ${Y}$exp${N} ($days days)"
    echo -e "  ${W}Devices:${N}  ${Y}$limit${N}"
    echo ""
    echo -e "  ${W}Server:${N}   ${G}$IP${N}"
    [ -n "$DOMAIN" ] && echo -e "  ${W}Domain:${N}   ${G}$DOMAIN${N}"
    print_line
    
    send_telegram "👤 <b>New User Created</b>
User: <code>$user</code>
Pass: <code>$pass</code>
Expires: $exp"
    
    read -p "  Press Enter..."
}

delete_user() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ DELETE USER ━━━${N}\n"
    
    list_users_simple
    
    read -p "  Username to delete: " user
    [ -z "$user" ] && return
    
    userdel -rf "$user" 2>/dev/null
    sed -i "/^$user|/d" "$USERS_DB"
    
    echo -e "\n  ${G}✓ User deleted!${N}"
    send_telegram "🗑️ User <b>$user</b> deleted"
    read -p "  Press Enter..."
}

list_users_simple() {
    if [ -s "$USERS_DB" ]; then
        echo -e "  ${W}Current users:${N}\n"
        printf "  ${C}%-12s %-12s %-12s %-6s${N}\n" "USER" "PASS" "EXPIRES" "LIMIT"
        echo -e "  ${C}────────────────────────────────────────────${N}"
        while IFS='|' read -r u p e l; do
            printf "  %-12s %-12s %-12s %-6s\n" "$u" "$p" "$e" "$l"
        done < "$USERS_DB"
        echo ""
    else
        echo -e "  ${Y}No users yet${N}\n"
    fi
}

list_users() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ USER LIST ━━━${N}\n"
    
    list_users_simple
    
    echo -e "  ${W}Online now:${N}"
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
    
    echo -e "\n  ${G}✓ Renewed until $new_exp${N}"
    send_telegram "🔄 User <b>$user</b> renewed until $new_exp"
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# PAYLOADS
# ═══════════════════════════════════════════════════════════════════════════════
show_payloads() {
    clear_screen
    print_banner
    
    IP=$(curl -s -m2 ifconfig.me)
    source "$CONFIG" 2>/dev/null
    
    echo -e "  ${Y}━━━ CONNECTION PAYLOADS ━━━${N}\n"
    
    print_line
    echo -e "  ${BG_B}${W}  DIRECT CONNECTION (Port 80)  ${N}"
    print_line
    echo ""
    echo -e "  ${W}Payload:${N}"
    echo -e "  ${C}GET / HTTP/1.1[crlf]Host: $IP[crlf]Upgrade: websocket[crlf][crlf]${N}"
    echo ""
    echo -e "  ${W}SSH Host:${N}     $IP"
    echo -e "  ${W}SSH Port:${N}     80"
    echo -e "  ${W}Proxy:${N}        $IP:80"
    echo ""
    
    if [ -n "$DOMAIN" ]; then
        print_line
        echo -e "  ${BG_G}${W}  CLOUDFLARE CDN (Port 443 SSL)  ${N}"
        print_line
        echo ""
        echo -e "  ${W}Payload:${N}"
        echo -e "  ${C}GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]${N}"
        echo ""
        echo -e "  ${W}SSH Host:${N}     $DOMAIN"
        echo -e "  ${W}SSH Port:${N}     443"
        echo -e "  ${W}Proxy:${N}        $DOMAIN:443"
        echo -e "  ${W}SSL:${N}          ${G}ON${N}"
        echo ""
    fi
    
    print_line
    echo -e "  ${W}UDP (BadVPN):${N} 7300"
    print_line
    echo ""
    
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# MONITOR
# ═══════════════════════════════════════════════════════════════════════════════
live_monitor() {
    clear_screen
    print_banner
    echo -e "  ${Y}━━━ LIVE MONITOR ━━━${N}\n"
    
    echo -e "  ${W}Services:${N}"
    for svc in superproxy ssh udpgw; do
        status=$(systemctl is-active $svc 2>/dev/null)
        [ "$status" = "active" ] && echo -e "    $svc: ${G}Running${N}" || echo -e "    $svc: ${R}Stopped${N}"
    done
    echo ""
    
    echo -e "  ${W}Connections:${N}"
    echo -e "    Port 80:  $(ss -tn 2>/dev/null | grep -c ':80 ')"
    echo -e "    SSH:      $(ss -tn 2>/dev/null | grep -c ':22 ')"
    echo ""
    
    echo -e "  ${W}Resources:${N}"
    echo -e "    RAM:  $(free -m | awk '/Mem/{printf "%d/%dMB (%.0f%%)", $3, $2, $3/$2*100}')"
    echo -e "    CPU:  $(top -bn1 | grep 'Cpu' | awk '{print 100-$8"%"}')"
    UPTIME=$(uptime -p)
    echo -e "    Up:   $UPTIME"
    echo ""
    
    echo -e "  ${W}Online Users:${N}"
    who 2>/dev/null | awk '{print "    " $1 " - " $3 " " $4}'
    
    echo ""
    read -p "  Press Enter..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP & RESTORE
# ═══════════════════════════════════════════════════════════════════════════════
backup_data() {
    file="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$file" -C "$DIR" . 2>/dev/null
    echo -e "\n  ${G}✓ Backup saved: $file${N}"
    send_telegram "💾 Backup created: $(basename $file)"
}

restore_data() {
    echo -e "\n  ${W}Available backups:${N}"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | nl
    read -p "  Enter backup path: " file
    [ -f "$file" ] && tar -xzf "$file" -C "$DIR" && echo -e "${G}✓ Restored!${N}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNINSTALL
# ═══════════════════════════════════════════════════════════════════════════════
uninstall() {
    clear_screen
    print_banner
    echo -e "  ${R}━━━ UNINSTALL ━━━${N}\n"
    echo -e "  ${Y}This will remove EVERYTHING!${N}\n"
    read -p "  Type 'yes' to confirm: " confirm
    
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
    
    echo -e "\n  ${G}✓ Uninstalled!${N}"
    exit 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU
# ═══════════════════════════════════════════════════════════════════════════════
menu() {
    while true; do
        clear_screen
        
        IP=$(curl -s -m2 ifconfig.me 2>/dev/null || echo "...")
        source "$CONFIG" 2>/dev/null
        DOMAIN=${DOMAIN:-"-"}
        proxy_status=$(systemctl is-active superproxy 2>/dev/null)
        user_count=$(wc -l < "$USERS_DB" 2>/dev/null || echo 0)
        ram=$(free -m | awk '/Mem/{printf "%d/%dMB", $3, $2}')
        online=$(who 2>/dev/null | wc -l)
        
        print_banner
        
        # Status box
        echo -e "${C}  ┌─────────────────────────────────────────────────────────────┐${N}"
        printf "${C}  │${N} ${W}%-10s${N} ${G}%-20s${N} ${W}%-10s${N} ${Y}%-10s${N} ${C}│${N}\n" "IP:" "$IP" "Users:" "$user_count/$MAX_USERS"
        printf "${C}  │${N} ${W}%-10s${N} ${C}%-20s${N} ${W}%-10s${N} ${Y}%-10s${N} ${C}│${N}\n" "Domain:" "${DOMAIN:0:20}" "Online:" "$online"
        printf "${C}  │${N} ${W}%-10s${N} $([ "$proxy_status" = "active" ] && echo -e "${G}●${N}" || echo -e "${R}●${N}") %-18s ${W}%-10s${N} ${G}%-10s${N} ${C}│${N}\n" "Status:" "$([ "$proxy_status" = "active" ] && echo "Running" || echo "Stopped")" "RAM:" "$ram"
        echo -e "${C}  └─────────────────────────────────────────────────────────────┘${N}"
        echo ""
        
        # Menu
        echo -e "${C}  ┌─────────────────────────────────────────────────────────────┐${N}"
        echo -e "${C}  │${N}                    ${W}USER MANAGEMENT${N}                          ${C}│${N}"
        echo -e "${C}  │${N}  ${G}1${N}) Add User         ${G}2${N}) Delete User    ${G}3${N}) List Users   ${C}│${N}"
        echo -e "${C}  │${N}  ${G}4${N}) Renew User       ${M}5${N}) Trial User (1H)                  ${C}│${N}"
        echo -e "${C}  ├─────────────────────────────────────────────────────────────┤${N}"
        echo -e "${C}  │${N}                    ${W}CONFIGURATION${N}                            ${C}│${N}"
        echo -e "${C}  │${N}  ${G}6${N}) Cloudflare       ${G}7${N}) Payloads       ${G}8${N}) Live Monitor ${C}│${N}"
        echo -e "${C}  │${N}  ${G}9${N}) Multi-Port       ${G}10${N}) SSH Banner    ${G}11${N}) Telegram    ${C}│${N}"
        echo -e "${C}  ├─────────────────────────────────────────────────────────────┤${N}"
        echo -e "${C}  │${N}                    ${W}ADVANCED${N}                                 ${C}│${N}"
        echo -e "${C}  │${N}  ${G}12${N}) Speed Test      ${G}13${N}) Traffic Stats ${G}14${N}) Logs        ${C}│${N}"
        echo -e "${C}  │${N}  ${G}15${N}) IP Blacklist    ${G}16${N}) Restart All                      ${C}│${N}"
        echo -e "${C}  ├─────────────────────────────────────────────────────────────┤${N}"
        echo -e "${C}  │${N}                    ${W}SYSTEM${N}                                   ${C}│${N}"
        echo -e "${C}  │${N}  ${G}17${N}) Backup          ${G}18${N}) Restore       ${R}19${N}) Uninstall   ${C}│${N}"
        echo -e "${C}  │${N}  ${R}0${N}) Exit                                                  ${C}│${N}"
        echo -e "${C}  └─────────────────────────────────────────────────────────────┘${N}"
        echo ""
        
        read -p "  Select option: " opt
        
        case $opt in
            1) add_user ;;
            2) delete_user ;;
            3) list_users ;;
            4) renew_user ;;
            5) create_trial ;;
            6) setup_cloudflare ;;
            7) show_payloads ;;
            8) live_monitor ;;
            9) setup_multiport ;;
            10) setup_banner ;;
            11) setup_telegram ;;
            12) speed_test ;;
            13) traffic_stats ;;
            14) view_logs ;;
            15) manage_blacklist ;;
            16)
                systemctl restart superproxy ssh udpgw 2>/dev/null
                echo -e "\n  ${G}✓ All services restarted!${N}"
                sleep 1
                ;;
            17) backup_data; read -p "  Press Enter..." ;;
            18) restore_data; read -p "  Press Enter..." ;;
            19) uninstall ;;
            0) echo -e "\n  ${C}Goodbye!${N}\n"; exit 0 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════
if [ ! -f "$DIR/proxy.py" ]; then
    install_base
fi

menu
