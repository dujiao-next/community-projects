# LangGe Dujiao-Next 安装脚本

Language: [English](./README.md) | **简体中文**

> 维护者：LangGe  
> Telegram：[@luoyanglang](https://t.me/luoyanglang)

## 视频教程

如果你更习惯跟着视频一步一步操作，可以直接参考下面的教程：

- Docker 部署完整实战：[Dujiao-Next 一键部署教程：Docker 部署完整实战｜域名、HTTPS、初始化一次搞定](https://youtu.be/VtsY82mak4Q)
- 二进制部署完整实战：[Dujiao-Next 一键部署教程：二进制部署完整实战｜PostgreSQL、Redis、Nginx 全流程](https://youtu.be/-C63BCOe4Qs)
- 外部面板环境部署：[Dujiao-Next 一键部署教程：外部面板环境部署｜1Panel / 宝塔复用 Redis、PostgreSQL、Nginx](https://youtu.be/6XPZdTmtISA)
- 系统安全加固实战：[Dujiao-Next 一键部署教程：系统安全加固实战｜SSH、UFW、Fail2ban、防锁死配置](https://www.youtube.com/watch?v=vdMRXAIUzfw)

## 项目简介

`langge-dujiao-next-install` 是一个社区维护的 Dujiao-Next 一键部署与运维脚本。

支持能力包括：

- Docker Compose 部署
- 二进制部署
- 外部数据库支持
- HTTPS 配置
- 版本检查
- 基础日常运维
- 系统安全加固

这个项目以独立社区脚本的形式发布，不覆盖官方社区仓里已有的一键部署脚本。

## 适用场景

这份脚本更适合下面这些场景：

- 想快速部署 `api + user + admin` 的新用户
- 需要一份统一入口来完成部署、更新、HTTPS、运维和基础加固的运维人员
- 需要在 Docker、二进制、外部面板环境之间灵活切换的使用者
- 希望把部署过程标准化、减少手工配置步骤的团队

不太适合的场景：

- 完全定制化的生产环境编排
- 对基础设施已经有成熟 IaC / CI/CD 体系的团队
- 不希望脚本修改系统 SSH、防火墙、安全基线配置的服务器

## 功能列表

- 菜单式交互，适合新手与轻运维场景
- 覆盖 `api + user + admin` 三端部署、更新、HTTPS、运维与加固
- 同时支持 Docker Compose、二进制、外部环境三种部署形态
- 二进制部署支持：
  - SQLite + Redis
  - PostgreSQL + Redis
- 内置版本检测、日常管理、数据库备份、日志查看、服务重启
- 支持检测半安装残留，并在重装前提示清理
- 证书申请前支持本机防火墙放行与云安全组确认
- 对状态文件读取与 `acme.sh` 安装方式做了额外安全收口

## 菜单结构与完整功能

### 一级菜单

脚本主菜单包含 6 个功能入口：

1. 开始部署
2. 一键更新
3. 配置 HTTPS
4. 日常管理
5. 检查版本
6. 系统加固

### 1. 开始部署

二级菜单包含 3 种部署模式：

1. Docker 部署（推荐）
2. 二进制部署
3. 外部环境部署

#### 1.1 Docker 部署

三级能力包括：

- 自动安装 / 检查 Docker 与 Docker Compose
- Docker 自动安装支持 Debian / Ubuntu，并会按系统自动选择对应的 Docker APT 仓库路径
- 自动配置 Docker 镜像源
- 自动修复 Redis 相关内核参数
- 选择数据库模式：
  - SQLite + Redis
  - PostgreSQL + Redis
- 选择镜像版本 TAG
- 自定义部署目录、时区、API/User/Admin 端口
- 自定义 Redis 端口与密码
- PostgreSQL 模式下自定义数据库端口、库名、用户名、密码
- Docker 启动前预检查 Redis / PostgreSQL 宿主机端口占用，并明确选择停用旧宿主机服务、重新输入端口或取消
- 设置默认管理员用户名与密码
- 收集域名配置：
  - User 域名
  - Admin 域名
  - API 域名
  - 是否启用 HTTPS
  - ACME 邮箱
- 自动写入分销模式基础配置：
  - 启用 `reseller.enabled`
  - 将 User / Admin / API 三端域名写入 `reseller.main_hosts`
  - 将 User 主域名写入 `reseller.subdomain_base`
- 自动生成：
  - `.env`
  - `config/config.yml`
  - `docker-compose.sqlite.yml`
  - `docker-compose.postgres.yml`
- 自动拉取镜像并启动服务
- 自动执行 API 健康检查
- 检测并清理未完成安装残留
- 等待 PostgreSQL / Redis 健康后自动重启 API / User / Admin 容器
- 自动安装 Nginx
- 支持两种站点接入方式：
  - HTTP 反向代理
  - 申请证书并自动配置 HTTPS
- 部署完成后自动保存本地部署状态

#### 1.2 二进制部署

三级能力包括：

- 自动识别 CPU 架构：
  - Linux x86_64
  - Linux arm64
- 自动安装依赖：
  - `tar`
  - `unzip`
  - `curl`
  - `redis-server`
  - `nginx`
- 可选择数据库方案：
  - SQLite + Redis
  - PostgreSQL + Redis
- 自动下载 API / User / Admin Release 包
- 自动解压并安装：
  - API 二进制
  - User 前端静态文件
  - Admin 前端静态文件
- 选择 `PostgreSQL + Redis` 时自动安装本机 PostgreSQL
- 写入配置前自动做 PostgreSQL 可用性预检查
- 自动创建或复用 PostgreSQL 数据库与用户，新建本机数据库时强制使用 UTF-8 编码
- 自动生成 API 配置文件
- 自动生成 JWT / User JWT / Redis 队列配置
- 自动写入分销模式基础配置，将 User / Admin / API 三端域名写入 `reseller.main_hosts`，并将 User 主域名写入 `reseller.subdomain_base`
- 自动设置默认管理员账户
- 自动写入 systemd 服务
- 自动配置 Nginx 站点
- 可选域名 + HTTPS 配置
- 自动写入本地部署状态

#### 1.3 外部环境部署

适用于已经有 1Panel / 宝塔 / 外部 PostgreSQL / 外部 Redis 的场景。

三级能力包括：

- 检测并选择现有 Docker 网络
- 自定义镜像版本 TAG
- 自定义部署目录与三端端口
- 录入外部 PostgreSQL 连接信息
- 从所选 Docker 网络验证 PostgreSQL 连通性与账号密码是否正确
- 录入外部 Redis 连接信息
- 从所选 Docker 网络验证 Redis 连通性与密码是否正确
- 设置默认管理员账户
- 录入 User / Admin / API 三端主域名，用于生成 `reseller.main_hosts` 与 `reseller.subdomain_base`
- 自动生成：
  - `config.yml`
  - `docker-compose.yml`
- 自动拉取并启动容器
- 自动保存本地部署状态
- 输出面板侧需要配置的反向代理说明

### 2. 一键更新

根据已保存的部署状态执行更新。

二级能力包括：

- 自动检查当前版本与最新版本
- 支持手动输入目标版本
- 按部署模式分别更新：
  - Docker 模式：更新 `.env` 中 TAG，重新拉取镜像并重启
  - 二进制模式：下载新版本 API / User / Admin 包并替换
  - 外部环境模式：更新 `docker-compose.yml` 镜像 TAG 并重启
- 更新时若配置文件缺少 `reseller:` 段，会基于已记录的 User / Admin / API 域名自动追加；已有 `reseller:` 段时不会覆盖
- 更新完成后写回部署状态

### 3. 配置 HTTPS

根据部署模式选择不同的 HTTPS 方案：

- Docker 模式：Nginx + `acme.sh`
- 二进制模式：`acme.sh` + Nginx
- 外部环境模式：提示在面板中自行配置证书

三级能力包括：

- 域名解析预检查
- 自动放行本机 UFW / firewalld 的 `80/443`
- 申请证书前提示确认云安全组 / 服务商防火墙已放行 `80/443`
- 自动安装 `socat`
- 检测到旧证书记录但缺失可安装的 ECC 文件时，自动尝试重新签发
- 证书申请
- Nginx/Caddy 配置写入
- 自动续期任务配置
- HTTPS 状态写回本地状态文件

### 4. 日常管理

二级菜单包含：

1. 查看服务状态
2. 查看日志
3. 重启服务
4. 备份数据库
5. 清理 Docker 资源
6. 卸载系统

三级能力包括：

- 查看服务状态：
  - Docker / 外部环境：查看 compose 服务状态
  - 二进制模式：查看 systemd 服务状态
  - API 健康检查
- 查看日志：
  - API
  - User
  - Admin
  - 全部
- 重启服务：
  - Docker 模式：重启 API / User / Admin / 全部
  - 二进制模式：重启 API 服务 / Nginx / 全部
- 备份数据库：
  - SQLite 备份
  - PostgreSQL 备份
  - 上传目录备份
- 更准确的备份结果提示：
  - 备份完成
  - 备份部分完成
  - 备份失败
- 清理 Docker：
  - 停止容器
  - 无用镜像
  - 无用网络
  - 构建缓存
- 卸载系统：
  - 停止服务
  - 删除安装目录
  - 删除状态文件
  - 清理 Nginx 配置
  - 若 Redis / PostgreSQL 由脚本在二进制部署时安装，则同时停用宿主机 Redis / PostgreSQL，避免切回 Docker 模式时端口冲突

### 5. 检查版本

功能包括：

- 读取本地部署状态
- 获取官方最新 Release 版本
- 对比 API / User / Admin 当前版本与最新版本
- 展示部署模式、部署目录、数据库类型、HTTPS 状态、域名信息

### 6. 系统加固

这部分本身就是一个独立的系统加固工具集。

三级能力包括：

- 自定义 SSH 端口、面板端口、额外开放端口
- 可选 `root` SSH 登录模式：
  - 密码 + 密钥（兼容模式）
  - 仅密钥登录（更安全）
- 检查并安装 Lynis
- 系统更新与自动安全更新
- 长时间软件更新阶段输出保活提示，降低远程 SSH 因长时间无输出而中断的风险
- 安装 `libpam-tmpdir`
- SSH 安全基线配置
- `sshd_config` 校验与回滚
- `rsyslog` 与日志权限配置
- `sysctl` 内核安全参数
- 系统文件权限修复
- Fail2ban 安装与 SSH Jail 配置
- UFW 防火墙配置
- Docker 与 UFW 规则协同
- UFW 规则失败回滚
- 禁用高风险协议与 USB 存储
- `login.defs` 基础策略
- `pwquality` 密码复杂度策略
- 登录 Banner 与 `su` 限制
- 系统加固仅支持 Debian / Ubuntu，其他发行版会在入口处直接拦截

## 安全说明

相较于更简单的远程执行脚本，这个项目额外做了几项安全收口：

- 不再通过 `source state.env` 直接执行状态文件
- `acme.sh` 改为先下载到本地临时文件再执行
- 通过 `.gitattributes` 固定 `*.sh` 为 `LF`，避免 Windows 换行符导致安装失败

## 风险提示

请在使用前注意下面这些风险点：

- 脚本会修改部署目录、配置文件、Nginx、systemd、Docker 资源
- 启用 HTTPS 时会申请证书，并写入 Caddy / Nginx 配置
- 执行系统加固时会修改：
  - SSH 配置
  - UFW 防火墙
  - Fail2ban
  - 密码策略
  - 内核安全参数
- 如果选择“仅密钥登录”，`root` 的 SSH 密码登录会被禁用；此时即使密码正确，也会表现为认证失败
- 二进制部署会写入 systemd 服务文件
- 二进制部署可能安装并启用本机 Redis / PostgreSQL；卸载时仅在确认它们由脚本安装的情况下停用
- Dujiao-Next 要求 PostgreSQL 数据库使用 UTF-8 编码；已有非 UTF-8 数据库需要先备份并重建后再使用
- 默认管理员账号密码仅适合初始化使用，部署完成后必须立即修改

建议：

- 先在测试机验证流程
- 在正式环境执行前做好快照或备份
- 系统加固功能建议在新服务器或可回滚环境中执行
- 远程 SSH 连接环境下，修改 SSH 端口前请先确认安全组 / 防火墙策略
- 远程 SSH 执行系统加固时，仍建议放在 `tmux` / `screen` 中运行，以降低链路抖动导致的中断影响
- 如果当前系统不是 Debian / Ubuntu，请不要使用本脚本的“系统加固”菜单

## 环境要求

- 建议使用 `root` 用户执行脚本
- 如果不是 `root`，请先切换到 `root`，或确保当前用户具备完整 `sudo` 权限
- Linux
- Docker 自动安装推荐 Debian / Ubuntu；如果系统 APT 源本身不可用，请先修复 `/etc/apt/sources.list*`
- `bash`
- `curl`
- `openssl`

Docker 模式：

- `docker`
- `docker compose`

二进制模式：

- `tar`
- `unzip`

## 使用方式

执行前请先确认当前会话具备 `root` 权限，例如：

```bash
sudo -i
```

或：

```bash
su - root
```

推荐方式：

```bash
bash <(curl -fsSL https://down.dujiao-next.cc/dujiao-next-install.sh)
```

请完整复制上面的命令执行；本脚本是交互式脚本，不要改成 `curl ... | bash`，否则菜单可能无法读取键盘输入。

备用下载方式：

```bash
curl -fsSL https://down.dujiao-next.cc/dujiao-next-install.sh -o dujiao-next-install.sh
bash dujiao-next-install.sh
```

GitHub 源码下载：

```bash
curl -fsSL https://raw.githubusercontent.com/dujiao-next/community-projects/main/scripts/langge-dujiao-next-install/dujiao-next-install.sh -o dujiao-next-install.sh
bash dujiao-next-install.sh
```

如果已经在本地仓库中：

```bash
bash dujiao-next-install.sh
```

## 功能截图

### 主菜单
![主菜单](./assets/screenshots/main-menu.png)

### 部署二级菜单
![部署二级菜单](./assets/screenshots/deploy-menu.png)

### Docker 部署流程
![Docker 部署流程](./assets/screenshots/docker-deploy.png)

### 二进制部署流程
![二进制部署流程](./assets/screenshots/binary-deploy.png)

### 日常管理菜单
![日常管理菜单](./assets/screenshots/ops-menu.png)

### 版本检查
![版本检查](./assets/screenshots/update-check.png)

### 版本检查明细
![版本检查明细](./assets/screenshots/update-check1.png)

### 系统安全加固
![系统安全加固](./assets/screenshots/security-hardening.png)

## 目录结构

```text
langge-dujiao-next-install/
  dujiao-next-install.sh
  tests/
    reseller_config_test.sh
  assets/screenshots/
  README.md
  README.zh-CN.md
  LICENSE
  .gitattributes
```

## 兼容性说明

- 面向 Dujiao-Next 社区部署场景
- Docker 自动安装会区分 Debian 与 Ubuntu：Debian 使用 `docker-ce/linux/debian`，Ubuntu 使用 `docker-ce/linux/ubuntu`
- 如果安装时报 `Release file`、`404`、`no installation candidate`，请优先检查系统 APT 源与 Docker 源是否匹配当前发行版和 codename
- 建议先在全新 Debian / Ubuntu 服务器上测试，再用于正式环境

## 开源协议

MIT，详见 [LICENSE](./LICENSE)。
