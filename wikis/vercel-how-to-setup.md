# Vercel 前后端分离部署教程（仅需手动部署API）

核心说明：本教程实现「前端user+后端admin 均部署在Vercel」，操作简单，仅需手动部署API相关仓库，无需额外配置复杂环境。

## 一、前置准备

- 拥有 GitHub 账号（用于存放项目仓库）

- 拥有 Vercel 账号（用于部署项目，可直接用 GitHub 账号登录）

- 已安装部署后端，并确保后端可运行； API 域名（示例：`https://api.yourwebsite.com`，需替换为自身实际 API 域名）

## 二、详细部署步骤（共6步，全程可视化操作）

### 步骤1：创建私有 GitHub 仓库（关键：保护个人信息）

由于项目可能包含个人敏感信息，**必须手动创建私有 GitHub 仓库**，具体操作：

1. 登录 GitHub，点击右上角「+」，选择「New repository」；

2. 填写仓库名称（建议与项目相关，如 user-api 或 admin-api）；

3. 勾选「Private」（私有仓库），避免信息泄露；

4. 无需修改其他设置，点击「Create repository」；

5. 将原项目（user 或 admin 相关后端代码）的所有文件，直接复制上传到该私有仓库，**无需做任何代码修改**。

### 步骤2：添加 vercel.json 配置文件（解决接口路径映射，关键步骤）

在新建的 GitHub 仓库根目录，手动创建 `vercel.json` 文件，用于配置接口路径重写（适配文档中 `/api/:path` 和 `/uploads/:path` 路径，避免“link fetch error”），文件内容如下：

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",  // 前端请求的API路径前缀
      "destination": "https://api.yourwebsite.com/api/:path*"  // 实际后端API地址（替换为你的API域名）
    },
    {
      "source": "/uploads/:path*",  // 前端请求的文件上传路径前缀
      "destination": "https://api.yourwebsite.com/uploads/:path*"  // 实际文件上传API地址（替换为你的API域名）
    }
  ]
}
```

⚠️ 注意：必须将 `https://api.yourwebsite.com` 替换为你自己的实际后端 API 域名，否则会导致接口请求失败（报错“link fetch error”）。

### 步骤3：登录 Vercel 并创建新项目

1. 访问 Vercel 官网（[https://vercel.com/](https://vercel.com/)），用 GitHub 账号登录（授权后可直接关联 GitHub 仓库）；

2. 登录后，点击右上角「Add New」下拉菜单，选择「Project」，进入项目创建页面。

### 步骤4：导入 GitHub 私有仓库

在项目创建页面，Vercel 会自动关联你的 GitHub 账号，显示所有仓库：

1. 找到步骤1中创建的私有仓库（可通过仓库名称搜索）；

2. 点击仓库右侧的「Import」，导入该仓库到 Vercel。

### 步骤5：项目编译配置（无需手动修改）

导入仓库后，Vercel 会自动识别项目框架（若为 Vite 框架，会直接识别）：

1. 无需修改任何编译配置，直接点击「Next」（下一步）；

2. Vercel 会自动开始安装依赖、编译项目，耐心等待1-3分钟（取决于项目大小）。

### 步骤6：部署完成，访问项目

1. 编译完成后，页面会显示「Deployed」（部署成功）；

2. 点击页面中显示的 Vercel 分配的域名（如 xxx.vercel.app），即可访问部署后的项目；

3. 若需绑定自定义域名，可在 Vercel 项目控制台的「Settings → Domains」中添加，具体操作可参考 Vercel 官方文档。

## 三、注意事项（避坑关键）

- 仓库必须为「私有」，防止个人信息、接口密钥等敏感内容泄露；

- `vercel.json` 中的 API 域名必须替换为自身实际域名，否则会出现“link fetch error”报错；

- 若项目框架不是 Vite，Vercel 识别失败，可在编译配置页手动选择对应框架（如 React、Vue 等）；

- 部署后若接口无法访问，可检查 vercel.json 路径配置是否正确，或后端 API 是否正常运行。

## 四、补充说明

若需更详细的 Vercel 基础操作（如自定义域名绑定、项目回滚、环境变量配置），可通过网络搜索「Vercel 官方教程」或相关实操指南，适配自身项目需求。
> （注：文档部分内容可能由 AI 生成）