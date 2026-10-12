# 直连基础配置的社区核对

核对日期：2026-10-12。检查的是项目维护者实际发布的配置正文和注释，星标数来自 GitHub API；下方使用提交固定链接，方便复核当时内容。社区配置能够支持语法和设计选择，但不能代替当前 iPhone 上的原生解析、DNS 和实际访问验证。

## 核对项目

| 项目 | 查询时 Stars | 检查文件 | 观察结果 |
| --- | ---: | --- | --- |
| Johnshall/Shadowrocket-ADBlock-Rules-Forever | 31,087 | [sr_direct_banad.conf](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever/blob/ed03e4d59bc1c1fa5acea1e292c14a20d3369410/sr_direct_banad.conf) | 直连去广告配置使用 FINAL,direct，同时设置 General 的 DNS 和本地网络参数。 |
| Hackl0us/SS-Rule-Snippet | 11,232 | [Shadowrocket.conf](https://github.com/Hackl0us/SS-Rule-Snippet/blob/6fb5c342fbe3c63a3baa4f0e8bb32046631809f6/LAZY_RULES/Shadowrocket.conf) | 完整配置提供 General、加密 DNS 和本地网络参数；用于通用分流，兜底是代理，不直接符合本仓库的其余直连场景。 |
| GMOogway/shadowrocket-rules | 5,583 | [03.shadowsocks_tiny.conf](https://github.com/GMOogway/shadowrocket-rules/blob/b7f205e6b87204296e933b95c285b18e51ae1d86/docs/03.shadowsocks_tiny.conf) | 模块配套的极简配置仍明确设置 General；关闭 dns-direct-fallback-proxy，并允许 private-ip-answer。其通用代理兜底不直接复制。 |
| LOWERTOP/Shadowrocket | 4,678 | [lazy.conf](https://github.com/LOWERTOP/Shadowrocket/blob/8c2d9949fbc5a25cfbcd6ca3952934e82ff4bd58/lazy.conf) | 注释说明模块规则优先、DNS 回退和 UDP 回退含义；它开启直连解析失败后的代理回退，适合其通用分流目标，但不符合本仓库的其余直连目标。 |

## 由证据得出的配置选择

1. **规则部分只写 `FINAL,DIRECT`**：以 Johnshall 的直连兜底为参照。代理例外由 OpenAI 模块提供，避免基础配置带入其他海外服务规则。
2. **补充 General，避免依赖未验证的默认值**：上述完整配置均设置 General。因此最初只有 `[Rule]` / `FINAL,DIRECT` 的草案不足以证明完整运行行为，现已补充与本场景直接有关的参数。
3. **DNS 使用可在国内连接的加密服务**：选择社区配置中出现的阿里 DNS 和 DNSPod DoH：`https://dns.alidns.com/dns-query`、`https://doh.pub/dns-query`。解析失败回退 `system`；网络可达性以实际网络为准。它们服务于 DNS 解析，不给其他服务增加代理规则。
4. **关闭直连失败的代理回退**：`dns-direct-fallback-proxy = false`。LOWERTOP 的正文注释解释此参数会把直连解析失败的请求改走代理；GMOogway 的极简配置明确关闭它，符合用户的目标。
5. **允许私有 IP 应答**：`private-ip-answer = true`。按 LOWERTOP 的解释，关闭它可能因 DNS 返回私有 IP 而触发强制代理；这里保留其直连策略。
6. **代理 UDP 不回退直连**：`udp-policy-not-supported-behaviour = REJECT`。与 LOWERTOP 的做法相同；节点不支持所需 UDP 时拒绝请求，不把本应代理的流量发到直连路径。可能影响语音等功能，需要节点支持。

这些判断是针对「模块指定代理，其余直连」的取舍，并非直接复制某个项目的完整配置，也不是所有场景的统一最佳参数。

本次不复制各仓库之间不同的 IPv6、旧版 bypass-system、QUIC、DNS 劫持或大量跳过域名设置。它们会扩大配置影响范围，且社区不同项目的取舍不一致。真实网络或 iPhone 测试发现具体问题时，再按证据调整。

## 本仓库验收

- 检查 Direct.conf 的规则只包含 FINAL,DIRECT，必需 General 参数不会被删除、重复或改为违背目标的值。
- 检查 OpenAI 模块引用的上游真实内容及编码；它包含公共依赖域名，不是只针对 ChatGPT App 进程。
- 本地 18 个直连配置用例及原有 38 个模块/远程正文用例通过，真实 OpenAI 规则下载得到 35 条。两个 DoH 服务在当前电脑上使用 DNS wire-format 查询 example.com 均得到有效响应，另外使用 `--noproxy '*'` 的请求也通过；这只说明当前电脑网络与服务的结果，不代表 iPhone 网络已验证。
- 在 iPhone 中只启用 OpenAI 模块并使用 Direct.conf：ChatGPT 核心域名应匹配 PROXY，example.com / baidu.com / youtube.com 应匹配 DIRECT。
- 禁用模块并重新应用配置，chatgpt.com 应切回 DIRECT；再启用时恢复 PROXY。
- 以上规则结果和 ChatGPT 实际访问均需要用户在 iPhone 验证，本地校验不声明它们已通过。
