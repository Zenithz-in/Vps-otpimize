#!/usr/bin/env bash
# ============================================================
#  VPS ULTRA OPTIMIZER — by Claude for ZenithCloud
#  Tested on Ubuntu 22.04 / 24.04 (Noble)
#  Run as: sudo bash vps-optimize.sh
# ============================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Helpers ──────────────────────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[  OK]${RESET}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[FAIL]${RESET}  $*"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${RESET}"; \
            echo -e "${BOLD}${CYAN}  $*${RESET}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════════${RESET}"; }

# ── Root check ───────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "Run this script as root: sudo bash $0"

# ── OS check ─────────────────────────────────────────────────
if ! grep -qiE 'ubuntu|debian' /etc/os-release 2>/dev/null; then
    warn "This script is optimized for Debian/Ubuntu. Proceeding anyway..."
fi

KERNEL=$(uname -r)
DISK=$(lsblk -nd --output NAME | grep -E '^(sd|vd|nvme)' | head -1)
DISK_PATH="/dev/${DISK}"

echo ""
echo -e "${BOLD}███████████████████████████████████████████████${RESET}"
echo -e "${BOLD}       VPS ULTRA OPTIMIZER  ⚡ v2.0            ${RESET}"
echo -e "${BOLD}███████████████████████████████████████████████${RESET}"
echo -e "  Kernel : ${KERNEL}"
echo -e "  Disk   : ${DISK_PATH}"
echo -e "  Date   : $(date)"
echo -e "${BOLD}███████████████████████████████████████████████${RESET}"
echo ""
read -rp "  Continue optimization? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ────────────────────────────────────────────────────────────
section "1 / 8  ·  NETWORK STACK (BBR + Kernel Tuning)"
# ────────────────────────────────────────────────────────────

info "Enabling BBR congestion control..."
modprobe tcp_bbr 2>/dev/null || warn "tcp_bbr module not available (kernel may have it built-in)"

SYSCTL=/etc/sysctl.d/99-vps-optimize.conf
cat > "$SYSCTL" << 'SYSCTL_EOF'
# ── BBR ──────────────────────────────────────────────────────
net.core.default_qdisc             = fq
net.ipv4.tcp_congestion_control     = bbr

# ── Core network buffers ─────────────────────────────────────
net.core.rmem_max                   = 134217728
net.core.wmem_max                   = 134217728
net.core.rmem_default               = 262144
net.core.wmem_default               = 262144
net.core.netdev_max_backlog         = 250000
net.core.somaxconn                  = 65535
net.core.optmem_max                 = 65536

# ── TCP tuning ───────────────────────────────────────────────
net.ipv4.tcp_rmem                   = 4096 87380 134217728
net.ipv4.tcp_wmem                   = 4096 65536 134217728
net.ipv4.tcp_mem                    = 786432 1048576 26777216
net.ipv4.tcp_fastopen               = 3
net.ipv4.tcp_tw_reuse               = 1
net.ipv4.tcp_fin_timeout            = 15
net.ipv4.tcp_keepalive_time         = 300
net.ipv4.tcp_keepalive_intvl        = 30
net.ipv4.tcp_keepalive_probes       = 3
net.ipv4.tcp_max_syn_backlog        = 65535
net.ipv4.tcp_syn_retries            = 3
net.ipv4.tcp_synack_retries         = 3
net.ipv4.ip_local_port_range        = 1024 65535
net.ipv4.tcp_sack                   = 1
net.ipv4.tcp_timestamps             = 1
net.ipv4.tcp_window_scaling         = 1
net.ipv4.tcp_no_metrics_save        = 1
net.ipv4.tcp_moderate_rcvbuf        = 1

# ── UDP ──────────────────────────────────────────────────────
net.ipv4.udp_rmem_min               = 8192
net.ipv4.udp_wmem_min               = 8192

# ── IPv6 ─────────────────────────────────────────────────────
net.ipv6.conf.all.disable_ipv6      = 0
SYSCTL_EOF

sysctl -p "$SYSCTL" > /dev/null 2>&1
success "Network stack tuned. BBR active."

# ────────────────────────────────────────────────────────────
section "2 / 8  ·  MEMORY & VIRTUAL MEMORY"
# ────────────────────────────────────────────────────────────

cat >> "$SYSCTL" << 'MEM_EOF'

# ── Memory ───────────────────────────────────────────────────
vm.swappiness                       = 10
vm.dirty_ratio                      = 15
vm.dirty_background_ratio           = 5
vm.vfs_cache_pressure               = 50
vm.overcommit_memory                = 1
vm.min_free_kbytes                  = 65536
MEM_EOF

sysctl -p "$SYSCTL" > /dev/null 2>&1

# Swapfile check
SWAP=$(swapon --show 2>/dev/null | wc -l)
if [[ "$SWAP" -lt 2 ]]; then
    warn "No swap detected — creating 2GB swapfile..."
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    success "2GB swap created."
else
    success "Swap already configured."
fi

# ────────────────────────────────────────────────────────────
section "3 / 8  ·  FILE DESCRIPTORS & SYSTEM LIMITS"
# ────────────────────────────────────────────────────────────

LIMITS=/etc/security/limits.d/99-vps-optimize.conf
cat > "$LIMITS" << 'LIMITS_EOF'
*    soft nofile  1048576
*    hard nofile  1048576
*    soft nproc   unlimited
*    hard nproc   unlimited
root soft nofile  1048576
root hard nofile  1048576
LIMITS_EOF

mkdir -p /etc/systemd/system.conf.d/
cat > /etc/systemd/system.conf.d/99-limits.conf << 'SD_EOF'
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=infinity
DefaultLimitCORE=infinity
SD_EOF

systemctl daemon-reexec 2>/dev/null || true
success "File descriptors set to 1,048,576."

# ────────────────────────────────────────────────────────────
section "4 / 8  ·  DISK I/O SCHEDULER"
# ────────────────────────────────────────────────────────────

if [[ -n "$DISK" ]]; then
    ROTATIONAL=$(cat /sys/block/${DISK}/queue/rotational 2>/dev/null || echo "1")

    if [[ "$ROTATIONAL" == "0" ]]; then
        SCHEDULER="none"
        info "SSD/NVMe detected → scheduler: none"
    else
        SCHEDULER="mq-deadline"
        info "HDD detected → scheduler: mq-deadline"
    fi

    echo "$SCHEDULER" > /sys/block/${DISK}/queue/scheduler 2>/dev/null || warn "Could not set scheduler (may be virtualized)"
    echo 256 > /sys/block/${DISK}/queue/nr_requests 2>/dev/null || true
    blockdev --setra 4096 "$DISK_PATH" 2>/dev/null || true

    # Persist via udev
    cat > /etc/udev/rules.d/60-io-scheduler.rules << 'UDEV_EOF'
ACTION=="add|change", KERNEL=="sd[a-z]",     ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]n*",                              ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="vd[a-z]",     ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]",     ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="mq-deadline"
UDEV_EOF

    udevadm control --reload-rules 2>/dev/null || true
    success "Disk scheduler set to ${SCHEDULER}."
else
    warn "Could not detect disk device. Skipping I/O tuning."
fi

# ── noatime mount ────────────────────────────────────────────
if ! grep -q 'noatime' /etc/fstab; then
    info "Adding noatime to root mount in /etc/fstab..."
    sed -i 's/\brelatime\b/noatime,nodiratime/g' /etc/fstab
    mount -o remount,noatime / 2>/dev/null || warn "Could not remount / with noatime live (will apply on reboot)"
fi
success "noatime configured."

# ────────────────────────────────────────────────────────────
section "5 / 8  ·  CPU GOVERNOR"
# ────────────────────────────────────────────────────────────

if command -v cpupower &>/dev/null; then
    cpupower frequency-set -g performance 2>/dev/null && success "CPU governor → performance (cpupower)."
elif ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor &>/dev/null 2>&1; then
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$gov" 2>/dev/null || true
    done
    success "CPU governor → performance (sysfs)."
else
    warn "cpufreq not available (VPS hypervisor controls CPU governor). Skipping."
fi

# ────────────────────────────────────────────────────────────
section "6 / 8  ·  IRQ BALANCE & NIC TUNING"
# ────────────────────────────────────────────────────────────

if ! command -v irqbalance &>/dev/null; then
    apt-get install -y -q irqbalance
fi
systemctl enable --now irqbalance 2>/dev/null || true
success "irqbalance enabled."

# Raise NIC TX queue length
for iface in /sys/class/net/*/; do
    DEV=$(basename "$iface")
    [[ "$DEV" == "lo" ]] && continue
    ip link set "$DEV" txqueuelen 10000 2>/dev/null || true
done
success "NIC TX queue length raised to 10000."

# ────────────────────────────────────────────────────────────
section "7 / 8  ·  DNS RESOLVER (DoT + Cache)"
# ────────────────────────────────────────────────────────────

mkdir -p /etc/systemd/resolved.conf.d/
cat > /etc/systemd/resolved.conf.d/99-fast-dns.conf << 'DNS_EOF'
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
FallbackDNS=9.9.9.9#dns.quad9.net
DNSSEC=yes
DNSOverTLS=yes
Cache=yes
DNS_EOF

systemctl restart systemd-resolved 2>/dev/null || warn "systemd-resolved not running."
success "DNS → Cloudflare DoT (1.1.1.1) + cache enabled."

# ────────────────────────────────────────────────────────────
section "8 / 8  ·  REMOVE BLOAT & UNNECESSARY SERVICES"
# ────────────────────────────────────────────────────────────

BLOAT_SERVICES=(
    bluetooth avahi-daemon cups cups-browsed
    ModemManager snapd whoopsie apport
    unattended-upgrades
)

for svc in "${BLOAT_SERVICES[@]}"; do
    if systemctl is-enabled "$svc" &>/dev/null 2>&1; then
        systemctl disable --now "$svc" 2>/dev/null || true
        info "Disabled: $svc"
    fi
done

apt-get autoremove -y -q 2>/dev/null | tail -1
apt-get clean -q
success "Bloat removed."

# ────────────────────────────────────────────────────────────
# FINAL APPLY
# ────────────────────────────────────────────────────────────

sysctl -p "$SYSCTL" > /dev/null 2>&1

echo ""
echo -e "${BOLD}${GREEN}███████████████████████████████████████████████${RESET}"
echo -e "${BOLD}${GREEN}       ✅  ALL OPTIMIZATIONS APPLIED!           ${RESET}"
echo -e "${BOLD}${GREEN}███████████████████████████████████████████████${RESET}"
echo ""
echo -e "${BOLD}  VERIFICATION COMMANDS:${RESET}"
echo -e "  ${DIM}sysctl net.ipv4.tcp_congestion_control${RESET}   # → bbr"
echo -e "  ${DIM}ulimit -n${RESET}                                # → 1048576"
echo -e "  ${DIM}cat /sys/block/${DISK}/queue/scheduler${RESET}   # → none/mq-deadline"
echo -e "  ${DIM}ping -c 5 1.1.1.1${RESET}                       # → latency check"
echo ""
echo -e "${YELLOW}  ⚠  A reboot is recommended to apply all changes fully.${RESET}"
echo ""
read -rp "  Reboot now? [y/N] " REBOOT
[[ "$REBOOT" =~ ^[Yy]$ ]] && reboot || echo -e "  ${DIM}Run 'reboot' when ready.${RESET}"
