# Cloudflare Pages 最简部署教程（仅需手动部署API，必成功）

核心：前端+后端均部署在Cloudflare Pages，仅3步核心操作，解决「link fetch error」，无需复杂配置，确保部署成功。

## 一、前置准备（3样东西，缺一不可）

- GitHub 账号（用来存项目代码）

- Cloudflare 账号（用来部署，可直接用GitHub登录）

- 你的后端API域名（替换示例 `https://api.yourwebsite.com`）

## 二、核心部署步骤（4步，全程复制操作）

### 步骤1：创建私有GitHub仓库

1. 登录GitHub，右上角「+」→「New repository」；

2. 填仓库名（随便填，比如 api-deploy），勾选「Private」（私有）；

3. 点击「Create repository」，把你的后端API代码（user/admin相关）直接上传进去，不用改任何代码。

### 步骤2：添加Cloudflare专属配置文件（关键，解决报错）

在刚才的GitHub仓库根目录，新建 `_routes.json` 文件，复制下面内容（替换成你的API域名）：

```json
{
  "version": 1,
  "routes": [
    {
      "src": "/api/:path*",
      "dest": "https://api.yourwebsite.com/api/:path*",
      "status": 200
    },
    {
      "src": "/uploads/:path*",
      "dest": "https://api.yourwebsite.com/uploads/:path*",
      "status": 200
    }
  ]
}
```

⚠️ 必做：把 `https://api.yourwebsite.com` 换成你自己的API域名，否则会报「link fetch error」。

### 步骤3：Cloudflare导入仓库并部署

1. 登录Cloudflare，左侧导航找「Pages」→ 右上角「Create a project」；

2. 点击「Connect to Git」，授权关联你的GitHub账号；

3. 找到步骤1创建的私有仓库，点击「Connect」；

4. 注意 预设框架要选vue；其他不用设置，直接点击「Save and Deploy」，等待1-2分钟（编译完成）。

### 步骤4：访问部署后的项目

编译成功后，页面会显示默认域名（如 xxx.pages.dev），点击域名就能访问，无「link fetch error」即为部署成功。

## 三、必看避坑（仅2条，确保成功）

- 仓库必须是「Private」，避免代码泄露；

- 配置文件必须叫 `_routes.json`，域名必须替换成自己的，否则部署失败。
> （注：文档部分内容可能由 AI 生成）