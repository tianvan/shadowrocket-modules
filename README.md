# shadowrocket-modules

个人维护的 Shadowrocket 分流模块，引用上游规则集，支持通过 URL 安装。

## 模块

| 模块 | 用途 | 策略 | HTTPS 解密 | 下载 |
| --- | --- | --- | --- | --- |
| [OpenAI](modules/routing/OpenAI.module) | ChatGPT / OpenAI 及规则集中包含的公共依赖域名 | PROXY，使用当前选择的节点 | 无需 | [模块 Raw URL](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/modules/routing/OpenAI.module) |

模块引用 [blackmatrix7/ios_rule_script 的 OpenAI 规则集](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Shadowrocket/OpenAI)。域名列表由上游维护，本仓库维护引用方式和策略。

## 安装

### ChatGPT 相关请求代理，其余直连（推荐组合）

先通过 **配置页面右上角＋** 下载 [Direct.conf](https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/configs/Direct.conf)，点击下载后的文件并选择「使用配置」：

```text
https://raw.githubusercontent.com/tianvan/shadowrocket-modules/main/configs/Direct.conf
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
2. 启用模块。需要其余直连时使用上面的 Direct.conf；也可以配合自己的基础配置使用。
3. 首页 **全局路由选择「配置」**，选择可用的代理节点并连接。
4. 使用「测试规则」检查 `chatgpt.com`，确认最终策略为 `PROXY`，再验证实际访问。

无需在手机上新建或编辑模块，也无需为此安装证书。

[详细安装与排查](docs/usage.md) · [更新与维护](docs/maintenance.md)

## 检查

使用 PowerShell 7，在仓库根目录执行：

```powershell
pwsh -NoProfile -File scripts/validate.ps1
pwsh -NoProfile -File scripts/validate.ps1 -CheckRemote
```

第一条检查直连基础配置、模块格式、策略、UTF-8 编码和 LF 换行；第二条还检查远程规则内容。检查器只验证本仓库约定的格式，并非 Shadowrocket 原生解析器。实际分流和 ChatGPT 访问需要在 iPhone 上确认。

在本仓库运行时，校验会要求 `configs/Direct.conf` 存在；CI 也显式使用 `-RequireDirectConfig`，防止安装入口被误删。

## 目录

```text
configs/         可通过 URL 下载的基础配置
modules/routing/  分流模块，保持发布路径稳定
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
