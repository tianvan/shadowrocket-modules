# 使用与排查

## 准备

先选择可用节点，临时使用全局路由「代理」确认能够访问目标服务。若全局代理也失败，应先检查节点连接；分流模块无法修复不可用的节点。

## 使用手机安装页

在 iPhone 的 **Safari** 打开 [安装页](https://tianvan.github.io/shadowrocket-modules/install/)，首次使用时点击「导入 direct.conf」，按需要点击服务模块的安装按钮，允许打开 Shadowrocket。

如果在电脑上浏览，用 **iPhone 系统相机**扫描以下二维码，打开同一个 HTTPS 安装页。模块添加页面只有 URL 输入入口，没有扫码入口；不用在小火箭内找相册扫码功能。

| ① 直连基础配置 | ② OpenAI 分流模块 |
| --- | --- |
| <img src="../assets/qrcodes/Direct.png" alt="导入 direct.conf" width="256"> | <img src="../assets/qrcodes/OpenAI.png" alt="安装 OpenAI 模块" width="256"> |

导入后：**direct.conf → 使用配置**，按需要启用 OpenAI、Twitter / X、Telegram、Google 模块，可以同时启用，首页全局路由选择「配置」，连接可用节点。希望其余直连时，只启用自己需要的服务模块。

二维码编码 HTTPS 安装页地址。网页按钮使用社区手册记录的 `shadowrocket://config/add/{url}` 和 `shadowrocket://install?module={url}` 安装协议，它们只是现有公开下载地址的快捷入口，不包含节点、账号或证书。手机仍需验证应用跳转和导入。

如果按钮无法跳转，点页面的「复制配置 URL」或「复制模块 URL」，返回对应的 URL 添加页粘贴。若浏览器禁止自动复制，页面会选中地址，长按选择「复制」即可。

原来的 `Direct.conf` 下载地址已改为小写 `direct.conf`；曾导入旧地址时，使用当前地址重新添加配置，确认成功后再删除旧配置。

## 添加 Telegram 和 Google 分流

在 iPhone Safari 打开对应安装页，点击安装按钮。电脑上浏览时用 iPhone 系统相机扫码：

| [Telegram 一键安装](https://tianvan.github.io/shadowrocket-modules/install/#telegram) | [Google 一键安装](https://tianvan.github.io/shadowrocket-modules/install/#google) |
| --- | --- |
| <img src="../assets/qrcodes/Telegram.png" alt="安装 Telegram 模块" width="256"> | <img src="../assets/qrcodes/Google.png" alt="安装 Google 模块" width="256"> |

按钮无法打开时，点「复制模块 URL」，在 **配置 → 模块 → 右上角＋** 粘贴对应地址并下载：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Telegram.module
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Google.module
```

启用 **Telegram 分流**和 **Google 分流**，保持当前配置为 direct.conf、全局路由为「配置」，连接可用节点。可以继续启用 OpenAI 和 Twitter 模块，已使用 direct.conf 时无需重复导入配置。

Telegram.list 单独以 RULE-SET 引用，已包含 TelegramNL、TelegramSG、TelegramUS 子规则；不必再添加这些地区规则。列表覆盖域名、IPv4 / IPv6 数据中心地址及 ASN，也包括部分第三方客户端相关域名。通话是否成功还取决于节点 UDP 能力及 Telegram 的通话设置，分流模块不改变通话设置。

Google.list 单独以 RULE-SET 引用，已包含 GoogleSearch、GoogleDrive、GoogleVoice；不必重复引用这些子规则。上游明确排除 YouTube / YouTubeMusic 专属规则，所以本模块不保证 YouTube 可用。它还覆盖广告、统计、公共资源和部分国内可访问的 Google 域名，公共 IP 及关键词规则也可能影响其他应用请求。

在「规则集 URL」确认 Telegram.list、Google.list 下载成功，再用「测试规则」检查：

| 已启用模块 | 测试目标 | 预期策略 |
| --- | --- | --- |
| Telegram | telegram.org、t.me、149.154.167.50 | PROXY |
| Google | google.com、mail.google.com、drive.google.com、gstatic.com | PROXY |
| 使用 direct.conf 且仅启用所需服务模块 | baidu.com | DIRECT |

随后在 Telegram 验证消息与图片，在 Google 验证搜索和所需服务。规则测试只证明匹配策略；实际访问仍取决于节点。禁用对应模块并重新使用配置后，telegram.org 或 google.com 应变为 DIRECT；重新启用后应恢复 PROXY。

## 添加 Twitter / X 分流

在 iPhone Safari 打开 [Twitter / X 一键安装页](https://tianvan.github.io/shadowrocket-modules/install/#twitter)，点击「安装 Twitter / X 模块」。电脑上浏览时用 iPhone 系统相机扫码打开该页面：

<img src="../assets/qrcodes/Twitter.png" alt="安装 Twitter / X 模块" width="256">

如果安装按钮无法跳转，复制模块 URL，在 **配置 → 模块 → 右上角＋** 粘贴并下载：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/Twitter.module
```

启用 **Twitter / X 分流**，保持当前基础配置为 direct.conf、全局路由为「配置」，连接可用代理节点。已导入 direct.conf 时不用重复添加；可以同时启用 OpenAI 模块。这样两个模块匹配的请求走代理，其余请求直连。

上游 [Twitter 规则说明](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/Twitter)建议以 RULE-SET 单独使用 Twitter.list；该版本的 IP 规则带 no-resolve。本模块按该方式引用，覆盖 x.com、twitter.com、t.co、twimg.com 等，当前也包含 grok.com、Twitter 关键词和部分 IP。它不按 App 进程隔离，不添加 DNS、FINAL、脚本或 HTTPS 解密。

验证时，在「规则集 URL」确认 Twitter.list 下载成功，使用「测试规则」检查 `x.com`、`twitter.com`、`t.co`、`pbs.twimg.com`、`grok.com` → `PROXY`；使用 direct.conf 且只启用所需服务模块时，`baidu.com` → `DIRECT`。再打开 X 检查登录、时间线、图片和视频。禁用 Twitter 模块并重新使用配置后，`x.com` 应变为 DIRECT；重新启用后应恢复 PROXY。

## 只代理 ChatGPT / OpenAI，其余直连

默认配置包含其他服务的分流规则。如果希望只有 OpenAI 模块匹配的请求使用代理，先下载并使用独立的直连基础配置：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/configs/direct.conf
```

1. 小火箭底部 **配置 → 右上角＋ → 粘贴上述 URL → 下载**。这里是配置页面的＋，不是模块页面的＋。
2. 点击下载后的 **direct.conf → 使用配置**，确认它成为当前配置。无需删除原来的 default.conf，可随时切回。
3. 按下方步骤添加并启用 OpenAI 模块；如果已经安装，直接启用。为本场景禁用其他分流模块，避免引入额外代理规则。
4. 首页全局路由选择「配置」，选中可用节点并连接。

direct.conf 的分流规则只有 `FINAL,DIRECT`。OpenAI 模块匹配的请求走 PROXY，其他请求走 DIRECT。General 明确设置加密 DNS、系统 DNS 回退、禁止直连解析失败后改走代理、允许私有 IP 应答，以及代理 UDP 不支持时拒绝。它不添加脚本、复写或证书。来源与取舍见 [社区核对记录](community-validation.md)。上游规则覆盖公共依赖域名，所以不是对 ChatGPT App 进程的严格隔离。

## 通过 URL 安装模块

复制 [OpenAI 模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module)：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module
```

也可以在 `modules/routing/OpenAI.module` 的 GitHub 文件页面点击 **Raw**，复制下载地址。不要复制 GitHub 的 `/blob/` 网页地址。

小火箭：**配置 → 模块 → 右上角＋ → 粘贴 URL → 下载 → 启用**。只代理 OpenAI 相关请求时使用 direct.conf；配合其他基础配置时，其余请求按该配置处理。首页全局路由选择「配置」，连接代理节点。必要时点击当前配置的「使用配置 / 编译配置」，使模块引用的资源重新拉取并应用。

OpenAI 模块只指定其引用规则的 `PROXY` 策略，使用当前选择的代理节点。其他请求仍按基础配置处理；模块不添加 FINAL 兜底规则，不更改 DNS，也不需要脚本或 HTTPS 解密。

## 检查结果

1. 当前配置 → 编辑配置 → **规则集 URL**，确认 OpenAI 规则下载成功。
2. **配置 → 测试规则**，分别测试 `chatgpt.com`、`openai.com`、`oaistatic.com`、`oaiusercontent.com`，预期最终策略为 `PROXY`。
3. 使用 direct.conf 且只启用 OpenAI 模块时，测试 `example.com`、`baidu.com` 和 `youtube.com`，预期最终策略为 `DIRECT`。YouTube 可能无法直连访问，这是本场景的预期策略；只需检查匹配结果。
4. 打开 ChatGPT，验证登录、发送消息和图片加载。规则测试通过只证明策略匹配，实际访问仍取决于节点和服务。
5. 禁用 OpenAI 模块并重新使用配置后，`chatgpt.com` 应匹配 DIRECT；重新启用后应匹配 PROXY。若不符合，检查是否选错基础配置或仍有其他模块启用。

## 排查

| 现象 | 检查方法 |
| --- | --- |
| 无法下载模块 | 检查 URL 是否为模块的 Raw 地址，仓库是否公开，当前网络是否可访问 GitHub Raw。 |
| 模块已下载，但远程规则失败 | 在规则集 URL 页面检查具体失败地址，修复连接后点击「使用配置 / 编译配置」。 |
| ChatGPT 仍然直连 | 确认模块已启用、全局路由为「配置」，检查是否有更优先的模块覆盖。 |
| 希望其余直连，但其他海外服务也走代理 | 确认当前配置是 direct.conf，检查是否启用了其他分流模块；只修改 default.conf 的 FINAL 不能移除它前面的代理规则。 |
| 策略为 PROXY，但不能访问 | 检查实际代理节点；用同一节点临时切换全局代理，比较是否仍失败。 |
| 文字可用，图片或语音不可用 | 在代理日志中检查失败请求和最终策略；语音还依赖节点的 UDP 等能力。 |
| 其他网站解析失败 | 检查当前网络能否访问配置中的 DoH，以及系统 DNS 是否正常；本配置不会把解析失败的直连请求自动转为代理。 |
| 开启模块后其他服务走代理 | 上游列表可能包含公共依赖域名；检查日志，按需要增加更优先的例外模块。 |

模块规则优先于基础配置规则，多个模块也有先后顺序。首次使用仅启用 OpenAI 模块，确认效果后再增加其他用途。

## 更新

规则内容更新：点击当前配置的「使用配置 / 编译配置」。模块本身更新：在模块页面更新远程模块。两者的区别与自动刷新条件见 [维护说明](maintenance.md)。
