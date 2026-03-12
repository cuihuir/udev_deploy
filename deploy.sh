#!/bin/bash
# RK3566 USB 自动挂载 - 部署脚本

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOUNT_POINT="/home/tope/printer_data/gcodes/usb_disk"
UDEV_DEST="/etc/udev/rules.d/99-usb-automount.rules"

echo "========================================="
echo "RK3566 USB 自动挂载 - 部署脚本"
echo "========================================="
echo ""

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    echo "  sudo ./deploy.sh"
    exit 1
fi

# 1. 创建挂载点目录
echo "[1/3] 创建挂载点目录..."
mkdir -p "$MOUNT_POINT"
chown tope:tope "$MOUNT_POINT"
echo "✓ 挂载点: $MOUNT_POINT"

# 2. 复制 udev 规则
echo "[2/3] 复制 udev 规则..."
cp "$PROJECT_DIR/udev/99-usb-automount.rules" "$UDEV_DEST"
echo "✓ udev 规则已复制到: $UDEV_DEST"

# 3. 确保 udev 服务运行
echo "[3/4] 确保 udev 服务运行..."
systemctl start systemd-udevd.service
systemctl enable systemd-udevd.service
echo "✓ udev 服务已启动"

# 4. 重载 udev 规则
echo "[4/4] 重载 udev 规则..."
udevadm control --reload
udevadm trigger
echo "✓ udev 规则已重载"

echo ""
echo "========================================="
echo "部署完成！"
echo "========================================="
echo ""
echo "测试方法："
echo "  1. 插入 U盘 或 SD卡"
echo "  2. 检查挂载: df -h | grep usb_disk"
echo "  3. 查看日志: journalctl -u systemd-udevd -f"
echo ""
echo "如需卸载，请使用: sudo ./undeploy.sh"
