# shadowrocket-modules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. 本项目建议在当前聊天由主代理直接执行，不需要并行子代理。Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** 在本地建立可通过 GitHub Raw URL 安装的 OpenAI 分流模块仓库，附中文使用说明、轻量校验和 GitHub Actions。

**Architecture:** 自有模块仅引用 blackmatrix7 的规则集并指定 PROXY。模块、文档和校验按职责分目录；远程规则由小火箭刷新，无需 fork、Git submodule、生成器或上游同步工作流。

**Tech Stack:** Shadowrocket 文本模块、Markdown、Git、PowerShell 7、GitHub Actions；没有运行时依赖。

**Spec:** `docs/design.md`（用户已于 2026-10-12 批准）。

## Global Constraints

- 项目位于 `D:\Repos\shadowrocket-modules`，使用 Git `main` 分支。
- 安装路径保持为 `modules/routing/OpenAI.module`，稳定路径不包含日期或版本号。
- 第一版只有 OpenAI 分流模块，不创建空的 `modules/rewrite/`。
- 上游引用固定为 `https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/OpenAI/OpenAI.list`，策略为 `PROXY`。
- 不改变基础配置的最终兜底策略和 DNS 设置。无脚本和 HTTPS 解密需求。
- `.gitattributes` 规范 LF 换行；文本保存为 UTF-8 无 BOM。
- 本地创建和 GitHub 发布是两个步骤，未经发布不将示例安装 URL 标为可用链接。
- 校验不冒充小火箭原生解析器；真实分流须由 iPhone 规则测试及实际访问确认。

## Review Focus

1. 200 响应实际是 HTML 错误页：联网检查必须失败，不能把可连接等同于规则可用。
2. 上游超时、404 或无有效规则：联网检查非零退出，输出具体 URL 和原因。
3. 模块缺少元信息、配置段或指定了不支持的策略：离线检查失败，给出文件和行号。
4. BOM、非 UTF-8 或 CRLF 导致不同工具读取差异：离线检查明确报错。
5. CI 检查绕过、误用写权限，或文档夸大验证结果：工作流使用只读权限；说明原生解析和真实访问尚需手机验证。

## Task 1: 模块、文档和 Git 基础

**Files:**
- 已创建：`docs/design.md`、本计划。
- Create: `modules/routing/OpenAI.module`。
- Create: `README.md`、`docs/usage.md`、`docs/maintenance.md`。
- Create: `.gitignore`、`.gitattributes`。

**Interfaces:**
- 输入：已批准的设计、上游 OpenAI.list。
- 输出：可直接被 Shadowrocket 模块 URL 安装机制读取的纯分流文件；可由 Task 2 扫描的 `modules/routing/*.module`。

- [x] 按设计建立目录和 OpenAI.module，至少包含 `#!name=ChatGPT / OpenAI 分流`、`#!desc`、`[Rule]` 与指定的 RULE-SET 行。
- [x] README 提供模块相对文件链接、功能范围和安装流程；明确发布前没有公开安装地址。usage.md 说明 PROXY 使用当前节点、全局路由选择配置、规则测试及下载状态。maintenance.md 区分模块更新和远程规则刷新，标明公共依赖域名可能影响其他应用。
- [x] 按 sire:gitignore 从 github/gitignore 的 Global/Windows.gitignore 获取系统模板，追加 `work/`、`.env`、`.env.*`、`!.env.example`；不复制真实密钥、节点订阅或证书。写 `.gitattributes` 使用 `* text=auto eol=lf`。
- [x] 检查模块恰好引用上述上游 URL，策略为 PROXY，未包含 FINAL、DNS、Script 或 MITM 段。对新增文件运行 `git diff --check`，并用 `git check-ignore -v --no-index` 检查忽略规则。
- [x] 提交模块、文档及 Git 配置，保留已批准设计的历史。

## Task 2: 校验脚本与 CI

**Files:**
- Create: `scripts/validate.ps1`。
- Create: `.github/workflows/validate.yml`。
- 临时验收数据和测试脚本使用当前聊天的 `work/`，不新增固定测试目录。

**Interfaces:**
- 脚本参数：`[string]$Root` 默认为脚本所在目录的上一级；`[switch]$CheckRemote`；`[int]$TimeoutSeconds = 20`。
- 成功返回进程退出码 0；错误返回非零退出码，给出路径、行号或 URL，汇总通过与失败数量。
- 第一版 routing 模块只允许 `[Rule]` 配置段；允许的规则行为为带有 HTTPS URL 和内置策略 PROXY/DIRECT/REJECT 的 RULE-SET 或 DOMAIN-SET 引用。不尝试支持或验证尚未创建的复写模块。
- 离线模式不访问网络；联网模式对引用的去重 URL 执行有超时的读取，RULE-SET 检查有效规则文本、DOMAIN-SET 检查有效域名文本，拒绝 HTML 和空数据。

- [x] 先在 `work/` 编写验收用例：合法模块通过；缺少 `#!name` 失败；错误策略失败；未预期的 `[MITM]` 段失败；BOM、非 UTF-8、CRLF 失败；无模块失败。联网用例通过本地临时 HTTP fixture 验证 HTML、空内容、404 与有效规则响应；生产模块仍要求 HTTPS，HTTP fixture 只用于验证响应分类函数。
- [x] 验收脚本先检查目标校验器存在，运行并确认失败原因是尚未创建校验器。
- [x] 实现脚本，边界解析使用严格 UTF-8 解码，输出可定位的错误；网络检查读取实际响应正文，不只检查 HEAD 或状态码。函数界面为 `Test-RuleContent([string]$Content, [string]$Kind)`，返回 `$true/$false`；脚本入口不能在 dot-source 时自行执行，方便验收调用。
- [x] 运行离线和本地 fixture 验收；对真实 OpenAI 规则执行联网校验，输出来源 URL 和有效规则数量。网络失败时如实报告，不绕过检查。
- [x] 创建 validate.yml：push、pull_request、workflow_dispatch；`permissions: contents: read`；ubuntu-latest；使用审阅过的 actions/checkout 提交 SHA；分别执行 PowerShell 离线和联网校验。工作流不含 secrets、发布、定时同步或写仓库操作。
- [x] 检查 YAML 结构、工作流命令及固定 action 引用；检查所有项目文本的编码和换行，运行 `git diff --check`。
- [x] 提交校验脚本和 CI，最终检查分支、提交历史及工作区状态。

## 完成与实际限制

- 本地结果包含已批准设计中的所有文件，以及保存批准和实施决策的 `docs/design.md`、`docs/implementation-plan.md`。
- 用户已在 Codex 界面关联项目，当前聊天工作目录为 `D:\Repos\shadowrocket-modules`。
- GitHub 仓库尚未创建，Actions 尚未在 GitHub 运行；手机上的原生模块解析和 ChatGPT 访问尚未验证。完成报告分别标明这些边界。
- 发布授权取得后再创建 GitHub 仓库、更新真实 Raw URL、推送并检查公开下载结果。

## 实施与验收记录（2026-10-12）

- 用户已批准在指定目录的 `main` 分支实施，当前聊天已关联此项目。没有另建 worktree。
- 按已批准的 `work/` 约定保存临时验收和执行账本，使用原生 PowerShell；未使用技能的 Bash 辅助脚本。实施记录保留在 Git 历史和本文档中。
- 校验脚本写入前，验收因脚本不存在而失败；实现后初始 30 个用例全部通过。
- 独立审阅发现无效域名、CIDR、ASN 会被接受。新增用例先复现 5 项失败，再修复目标基本格式验证；完整验收为 38 通过、0 失败。
- 联网检查真实 OpenAI.list：35 条规则，0 错误。PowerShell 语法、YAML 结构、只读权限、固定 checkout 提交和 Git diff 检查通过。
- Minor 待改进：缺失/空元信息的提示包含文件名和原因，但没有行号；其他逐行结构错误包含行号。
- 验收范围：仅验证本仓库约定的格式和远程正文；原生 Shadowrocket 全语法、iPhone 实际分流、GitHub Actions 执行及公开下载仍需发布和手机验证。上游未来变化及用户节点可用性由运行时状态决定，无法由本地校验保证。

## 发布授权（2026-10-12）

用户授权提交并 push。目标为当前 GitHub 账号 `tianvan` 下的公开仓库 `shadowrocket-modules`，远程名为 `origin`，分支为 `main`；README 和使用说明使用对应的真实 Raw URL。公开下载和 GitHub Actions 结果在推送后检查，iPhone 实测仍由用户完成。
