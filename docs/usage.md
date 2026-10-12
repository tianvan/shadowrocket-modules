# 使用与排查

## 准备

先选择可用节点，临时使用全局路由「代理」确认能够访问 ChatGPT。若全局代理也失败，应先检查节点连接；分流模块无法修复不可用的节点。

## 只代理 ChatGPT / OpenAI，其余直连

默认配置包含其他服务的分流规则。如果希望只有 OpenAI 模块匹配的请求使用代理，先下载并使用独立的直连基础配置：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/configs/Direct.conf
```

1. 小火箭底部 **配置 → 右上角＋ → 粘贴上述 URL → 下载**。这里是配置页面的＋，不是模块页面的＋。
2. 点击下载后的 **Direct.conf → 使用配置**，确认它成为当前配置。无需删除原来的 default.conf，可随时切回。
3. 按下方步骤添加并启用 OpenAI 模块；如果已经安装，直接启用。为本场景禁用其他分流模块，避免引入额外代理规则。
4. 首页全局路由选择「配置」，选中可用节点并连接。

Direct.conf 的分流规则只有 `FINAL,DIRECT`。OpenAI 模块匹配的请求走 PROXY，其他请求走 DIRECT。General 明确设置加密 DNS、系统 DNS 回退、禁止直连解析失败后改走代理、允许私有 IP 应答，以及代理 UDP 不支持时拒绝。它不添加脚本、复写或证书。来源与取舍见 [社区核对记录](community-validation.md)。上游规则覆盖公共依赖域名，所以不是对 ChatGPT App 进程的严格隔离。

## 通过 URL 安装模块

复制 [OpenAI 模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module)：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module
```

也可以在 `modules/routing/OpenAI.module` 的 GitHub 文件页面点击 **Raw**，复制下载地址。不要复制 GitHub 的 `/blob/` 网页地址。

小火箭：**配置 → 模块 → 右上角＋ → 粘贴 URL → 下载 → 启用**。只代理 OpenAI 相关请求时使用 Direct.conf；配合其他基础配置时，其余请求按该配置处理。首页全局路由选择「配置」，连接代理节点。必要时点击当前配置的「使用配置 / 编译配置」，使模块引用的资源重新拉取并应用。

OpenAI 模块只指定其引用规则的 `PROXY` 策略，使用当前选择的代理节点。其他请求仍按基础配置处理；模块不添加 FINAL 兜底规则，不更改 DNS，也不需要脚本或 HTTPS 解密。

## 检查结果

1. 当前配置 → 编辑配置 → **规则集 URL**，确认 OpenAI 规则下载成功。
2. **配置 → 测试规则**，分别测试 `chatgpt.com`、`openai.com`、`oaistatic.com`、`oaiusercontent.com`，预期最终策略为 `PROXY`。
3. 使用 Direct.conf 且只启用 OpenAI 模块时，测试 `example.com`、`baidu.com` 和 `youtube.com`，预期最终策略为 `DIRECT`。YouTube 可能无法直连访问，这是本场景的预期策略；只需检查匹配结果。
4. 打开 ChatGPT，验证登录、发送消息和图片加载。规则测试通过只证明策略匹配，实际访问仍取决于节点和服务。
5. 禁用 OpenAI 模块并重新使用配置后，`chatgpt.com` 应匹配 DIRECT；重新启用后应匹配 PROXY。若不符合，检查是否选错基础配置或仍有其他模块启用。

## 排查

| 现象 | 检查方法 |
| --- | --- |
| 无法下载模块 | 检查 URL 是否为模块的 Raw 地址，仓库是否公开，当前网络是否可访问 GitHub Raw。 |
| 模块已下载，但远程规则失败 | 在规则集 URL 页面检查具体失败地址，修复连接后点击「使用配置 / 编译配置」。 |
| ChatGPT 仍然直连 | 确认模块已启用、全局路由为「配置」，检查是否有更优先的模块覆盖。 |
| 希望其余直连，但其他海外服务也走代理 | 确认当前配置是 Direct.conf，检查是否启用了其他分流模块；只修改 default.conf 的 FINAL 不能移除它前面的代理规则。 |
| 策略为 PROXY，但不能访问 | 检查实际代理节点；用同一节点临时切换全局代理，比较是否仍失败。 |
| 文字可用，图片或语音不可用 | 在代理日志中检查失败请求和最终策略；语音还依赖节点的 UDP 等能力。 |
| 其他网站解析失败 | 检查当前网络能否访问配置中的 DoH，以及系统 DNS 是否正常；本配置不会把解析失败的直连请求自动转为代理。 |
| 开启模块后其他服务走代理 | 上游列表可能包含公共依赖域名；检查日志，按需要增加更优先的例外模块。 |

模块规则优先于基础配置规则，多个模块也有先后顺序。首次使用仅启用 OpenAI 模块，确认效果后再增加其他用途。

## 更新

规则内容更新：点击当前配置的「使用配置 / 编译配置」。模块本身更新：在模块页面更新远程模块。两者的区别与自动刷新条件见 [维护说明](maintenance.md)。
