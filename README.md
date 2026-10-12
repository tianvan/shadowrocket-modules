# shadowrocket-modules

个人维护的 Shadowrocket 分流模块，引用上游规则集，支持通过 URL 安装。

## 模块

| 模块 | 用途 | 策略 | HTTPS 解密 | 一键安装 | 下载 |
| --- | --- | --- | --- | --- | --- |
| [OpenAI](modules/routing/OpenAI.module) | ChatGPT / OpenAI 及规则集中包含的公共依赖域名 | PROXY，使用当前选择的节点 | 无需 | [安装页](https://tianvan.github.io/shadowrocket-modules/install/#openai) | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module) |
| [Twitter / X](modules/routing/Twitter.module) | Twitter / X、短链接、媒体及 Grok 等上游规则覆盖的请求 | PROXY，使用当前选择的节点 | 无需 | [安装页](https://tianvan.github.io/shadowrocket-modules/install/#twitter) | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Twitter.module) |
| [Telegram](modules/routing/Telegram.module) | Telegram 域名、数据中心 IP 及 ASN 等相关请求 | PROXY，使用当前选择的节点 | 无需 | [安装页](https://tianvan.github.io/shadowrocket-modules/install/#telegram) | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Telegram.module) |
| [Google](modules/routing/Google.module) | 搜索、Gmail、Drive 等 Google 服务，不包含 YouTube 专属规则 | PROXY，使用当前选择的节点 | 无需 | [安装页](https://tianvan.github.io/shadowrocket-modules/install/#google) | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Google.module) |
| [GitHub](modules/routing/GitHub.module) | GitHub 网站、Raw、Pages、下载资源、GHCR、npm 及部分 Copilot 相关请求 | PROXY，使用当前选择的节点 | 无需 | [安装页](https://tianvan.github.io/shadowrocket-modules/install/#github) | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/GitHub.module) |
| [Reddit](modules/routing/Reddit.module) | Reddit 主站、短链接及自有媒体资源 | PROXY，使用当前选择的节点 | 无需 | [安装页](https://tianvan.github.io/shadowrocket-modules/install/#reddit) | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Reddit.module) |

模块分别引用 blackmatrix7/ios_rule_script 的 [OpenAI](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/OpenAI)、[Twitter](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/Twitter)、[Telegram](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/Telegram)、[Google](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/Google)、[GitHub](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/GitHub) 和 [Reddit](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/Reddit) 规则集。规则列表由上游维护，本仓库维护引用方式和策略。

## 安装

### 手机安装页与二维码

在 iPhone 的 **Safari** 打开 [安装页](https://tianvan.github.io/shadowrocket-modules/install/)，首次使用时点击「导入 direct.conf」，再按需要点击服务模块的安装按钮，允许跳转到 Shadowrocket。

如果页面显示在电脑上，用 **iPhone 系统相机**扫描下列二维码打开安装页。模块添加页面只有 URL 输入入口，没有扫码入口；二维码不需要在模块页面扫描。

| ① 导入直连基础配置 | ② 安装 OpenAI 模块 |
| --- | --- |
| <img src="assets/qrcodes/Direct.png" alt="导入 direct.conf 二维码" width="256"> | <img src="assets/qrcodes/OpenAI.png" alt="安装 OpenAI 模块二维码" width="256"> |

导入后选择 **direct.conf → 使用配置**，按需要启用服务模块，可以同时启用，首页 **全局路由选择「配置」**，连接可用代理节点。若安装按钮没有跳转，可点页面的「复制 URL」后返回对应添加页面粘贴，仍无需手输地址。二维码解码与网页按钮可在电脑验证；iPhone 的应用跳转和导入需实机确认。

### 添加 Reddit 模块

用 iPhone Safari 打开 [Reddit 一键安装页](https://tianvan.github.io/shadowrocket-modules/install/#reddit)，点击「安装 Reddit 模块」。电脑上可用 iPhone 系统相机扫描：

<img src="assets/qrcodes/Reddit.png" alt="安装 Reddit 模块二维码" width="256">

下载后启用 **Reddit 分流**，保持 direct.conf 和全局路由「配置」，可与其他服务模块同时启用，已使用 direct.conf 时无需重复导入配置。检查 `reddit.com`、`i.redd.it`、`v.redd.it`、`redditstatic.com` → `PROXY`，`baidu.com` → `DIRECT`，再验证帖子、图片和视频加载。

模块覆盖上游列出的 Reddit 域名；帖子中的外部网站仍按已有分流规则处理。无需 HTTPS 解密或证书。按钮无法打开时，复制模块 URL 到 **配置 → 模块 → 右上角＋**：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Reddit.module
```

### 添加 GitHub 模块

用 iPhone Safari 打开 [GitHub 一键安装页](https://tianvan.github.io/shadowrocket-modules/install/#github)，点击「安装 GitHub 模块」。电脑上可用 iPhone 系统相机扫描：

<img src="assets/qrcodes/GitHub.png" alt="安装 GitHub 模块二维码" width="256">

下载后启用 **GitHub 分流**，保持 direct.conf 和全局路由「配置」，可与现有服务模块同时启用，已使用 direct.conf 时无需重复导入配置。检查 `github.com`、`raw.githubusercontent.com`、`github.io`、`ghcr.io`、`registry.npmjs.org` → `PROXY`，`baidu.com` → `DIRECT`，再打开仓库页面或下载文件实测。

上游规则还包含 npm、部分 Copilot 域名和 GitHub 关键词，因此覆盖范围不限于 GitHub 主站，不保证覆盖 Copilot 的全部外部依赖。无需 HTTPS 解密或证书。按钮无法打开时，复制模块 URL 到 **配置 → 模块 → 右上角＋**：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/GitHub.module
```

### 添加 Telegram 和 Google 模块

用 iPhone Safari 打开对应安装页，点击安装按钮；电脑上可用 iPhone 系统相机扫描：

| [Telegram 一键安装](https://tianvan.github.io/shadowrocket-modules/install/#telegram) | [Google 一键安装](https://tianvan.github.io/shadowrocket-modules/install/#google) |
| --- | --- |
| <img src="assets/qrcodes/Telegram.png" alt="安装 Telegram 模块二维码" width="256"> | <img src="assets/qrcodes/Google.png" alt="安装 Google 模块二维码" width="256"> |

下载后启用 **Telegram 分流**和 **Google 分流**。已使用 direct.conf 时无需重复导入配置，OpenAI 和 Twitter 模块也可继续启用；启用模块匹配的请求走代理，其余直连。

Telegram 模块包括域名、IP 和 ASN 规则，检查 `telegram.org`、`t.me`、`149.154.167.50` → `PROXY`，再验证消息与媒体加载。通话还取决于节点 UDP 能力及 Telegram 的通话设置。

Google 模块覆盖搜索、Gmail、Drive 等，不包含 YouTube 专属规则；广告、统计、公共资源和部分国内可访问的 Google 域名也可能走代理。检查 `google.com`、`mail.google.com`、`drive.google.com`、`gstatic.com` → `PROXY`，`baidu.com` → `DIRECT`，再验证实际访问。上游的公共 IP / 关键词规则可能覆盖其他请求，不保证按应用隔离。

按钮无法打开时，复制对应地址到 **配置 → 模块 → 右上角＋**：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Telegram.module
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Google.module
```

### 添加 Twitter / X 模块

用 iPhone Safari 打开 [Twitter / X 一键安装页](https://tianvan.github.io/shadowrocket-modules/install/#twitter)，点击「安装 Twitter / X 模块」。电脑上可用 iPhone 系统相机扫描：

<img src="assets/qrcodes/Twitter.png" alt="安装 Twitter / X 模块二维码" width="256">

已使用 direct.conf 时，只需添加并启用 **Twitter / X 分流**，可同时保留 OpenAI 模块；匹配这两个模块的请求走代理，其余直连。在「测试规则」检查 `x.com`、`twitter.com`、`t.co`、`pbs.twimg.com` → `PROXY`，`baidu.com` → `DIRECT`，再打开 X 验证登录、图片和视频。

上游 Twitter 规则包含 `grok.com`、`DOMAIN-KEYWORD,twitter` 和部分 IP，因此覆盖范围不限于 X App 本身。不需要 HTTPS 解密或证书。手动添加时使用以下 Raw URL：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Twitter.module
```

### ChatGPT 相关请求代理，其余直连（推荐组合）

先通过 **配置页面右上角＋** 下载 [direct.conf](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/configs/direct.conf)，点击下载后的文件并选择「使用配置」：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/configs/direct.conf
```

这个基础配置的分流规则只有 `FINAL,DIRECT`，另明确设置 DNS 与回退行为：直连解析失败不自动改走代理，代理 UDP 不支持时不回退直连。只启用 OpenAI 模块时，匹配其规则的请求走代理，其余直连。启用其他分流模块后，也会应用那些模块的规则。

配置选择已核对多个高星标社区项目，详见 [社区核对记录](docs/community-validation.md)。

### 添加 OpenAI 模块

复制下面的模块 URL：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module
```

在小火箭中执行：

1. **配置 → 模块 → 右上角＋**，粘贴模块 Raw URL 并下载。
2. 启用模块。需要其余直连时使用上面的 direct.conf；也可以配合自己的基础配置使用。
3. 首页 **全局路由选择「配置」**，选择可用的代理节点并连接。
4. 使用「测试规则」检查 `chatgpt.com`，确认最终策略为 `PROXY`，再验证实际访问。

无需在手机上新建或编辑模块，也无需为此安装证书。

[详细安装与排查](docs/usage.md) · [更新与维护](docs/maintenance.md)

## 检查

使用 PowerShell 7，在仓库根目录执行：

```powershell
pwsh -NoProfile -File scripts/validate.ps1
pwsh -NoProfile -File scripts/validate.ps1 -CheckRemote
pwsh -NoProfile -File scripts/test-rule-content.ps1
```

第一条检查直连基础配置、模块格式、策略、UTF-8 编码和 LF 换行；第二条还检查远程规则内容；第三条运行 IP 规则校验的回归检查。检查器只验证本仓库约定的格式，并非 Shadowrocket 原生解析器。实际分流和服务访问需要在 iPhone 上确认。

在本仓库运行时，校验会要求 `configs/direct.conf` 存在；CI 也显式使用 `-RequireDirectConfig`，防止安装入口被误删。

## 目录

```text
configs/         可通过 URL 下载的基础配置
modules/routing/  分流模块，保持发布路径稳定
assets/qrcodes/   打开 HTTPS 安装页的二维码
docs/install/    Safari 安装按钮与复制 URL 页面
docs/            使用说明、维护约定、已批准设计和实施计划
scripts/         本地与 CI 共用的校验工具
.github/workflows/ GitHub Actions 检查
```

新增复写功能时再建立 `modules/rewrite/`，并为新格式扩展校验器。一项用途一个模块，避免重复叠加。

## 来源与范围

- 上游项目：[blackmatrix7/ios_rule_script](https://github.com/blackmatrix7/ios_rule_script)，使用前参阅其说明和许可。本仓库不复制上游规则数据。
- 使用说明参考：[Shadowrocket 社区手册](https://github.com/LOWERTOP/Shadowrocket)。本仓库属于社区项目。
- 上游规则可能包含公共依赖域名，其他应用访问这些域名时也会走代理；这不是按 iOS 应用进程隔离。
- `PROXY` 依赖用户自己的代理节点。本仓库不提供节点、订阅或账号。
