#!/bin/bash
# RK3566 USB 自动挂载 - 卸载脚本

set -e

echo "========================================="
echo "RK3566 USB 自动挂载 - 卸载脚本"
echo "========================================="
echo ""

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    echo "  sudo ./undeploy.sh"
    exit 1
fi

echo "此操作将："
echo "  - 删除 udev 规则"
echo "  - 保留挂载点目录"
echo ""
read -p "确认卸载？(y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 1. 删除 udev 规则
echo "[1/2] 删除 udev 规则..."
if [ -f "/etc/udev/rules.d/99-usb-automount.rules" ]; then
    rm /etc/udev/rules.d/99-usb-automount.rules
    echo "✓ udev 规则已删除"
else
    echo "× udev 规则不存在"
fi

# 2. 重载 udev
echo "[2/2] 重载 udev 规则..."
udevadm control --reload-rules
udevadm trigger
echo "✓ udev 规则已重载"

echo ""
echo "注意："
echo "  - 挂载点目录仍保留: /home/tope/printer_data/gcodes/usb_disk"
echo "  - 如需清理，请手动删除"
