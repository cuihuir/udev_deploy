# RK3566 USB 自动挂载

用于 Orange Pi 3B (RK3566) 3D打印机的 USB 存储设备自动挂载方案。

## 功能

- 插入 U盘/SD卡自动挂载到 `/home/tope/printer_data/gcodes/usb_disk`
- 拔出设备自动卸载
- 支持中文文件名 (UTF-8)
- 自动设置文件权限为 tope 用户
- 使用 systemd-mount 实现可靠挂载

## 文件结构

```
rk3566-usb-automount/
├── udev/
│   └── 99-usb-automount.rules # udev 规则
├── deploy.sh                  # 部署脚本
├── undeploy.sh                # 卸载脚本
└── README.md                  # 本文件
```

## 快速部署

```bash
sudo ./deploy.sh
```

## 手动部署步骤

### 1. 创建挂载点目录

```bash
sudo mkdir -p /home/tope/printer_data/gcodes/usb_disk
sudo chown tope:tope /home/tope/printer_data/gcodes/usb_disk
```

### 2. 复制 udev 规则

```bash
sudo cp udev/99-usb-automount.rules /etc/udev/rules.d/
```

### 3. 重载 udev 规则

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## 测试

插入 U盘，检查是否自动挂载：

```bash
# 查看挂载状态
df -h | grep usb_disk
ls -la /home/tope/printer_data/gcodes/usb_disk

# 查看 udev 日志
sudo journalctl -u systemd-udevd -f
```

## 故障排查

### 设备插入后没有自动挂载

1. 检查设备是否被识别：
```bash
lsblk
```

2. 查看 udev 事件：
```bash
sudo udevadm monitor --environment --udev
```

3. 测试 udev 规则：
```bash
sudo udevadm test /sys/block/sda/sda1
```

4. 查看 systemd 日志：
```bash
sudo journalctl -u systemd-udevd -n 50
```

### 文件无法写入

检查挂载选项中的 gid 是否正确：
```bash
# 查看 tope 用户的组ID
id tope

# 如果 gid 不是 100，需要修改 udev 规则中的 gid 值
```

## 技术细节

### 过滤规则

- 只处理 USB 存储设备（跳过内部硬盘）
- 排除 Klipper 设备（避免误挂载3D打印机主板）
- 排除 HID 和 TTY 设备
- 排除标签为 CONFIG 的设备

### 挂载选项

- `relatime`: 减少磁盘写入，提升性能
- `sync`: 立即写入数据（防止拔出时数据丢失）
- `utf8`: 支持中文文件名
- `gid=100,umask=002`: 设置文件权限

## 卸载

```bash
sudo ./undeploy.sh
```

或手动卸载：

```bash
# 删除 udev 规则
sudo rm /etc/udev/rules.d/99-usb-automount.rules

# 重载 udev
sudo udevadm control --reload-rules
```

## 注意事项

- 此方案使用固定挂载点，只支持单个 USB 设备
- 如果同时插入多个 USB 设备，只有第一个会被挂载
- 卸载时如果设备正在被使用，umount 可能失败

## 许可

MIT License
