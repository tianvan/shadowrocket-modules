# 更新与维护

## 来源

| 模块 | 上游规则 | 策略 |
| --- | --- | --- |
| `modules/routing/OpenAI.module` | [OpenAI.list](https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/OpenAI/OpenAI.list) | PROXY |

模块直接引用 [blackmatrix7/ios_rule_script](https://github.com/blackmatrix7/ios_rule_script) 的 `master` 分支，不在本仓库镜像域名列表。因此不需要 fork、Git submodule 或同步上游工作流。

## 两种更新

- **上游规则更新**：模块文件不变，小火箭通过「使用配置 / 编译配置」重新下载规则。直接引用分支地址意味着下一次刷新会跟随上游修改，不保证规则始终完整或无误。
- **本仓库模块更新**：提交新的模块内容并发布到 GitHub，用户通过模块页面更新远程模块。

可以启用小火箭的配置资源和模块自动后台更新，并在 iOS「通用 → 后台 App 刷新」中允许小火箭刷新。后台任务受系统调度影响，不保证立即执行；模块刷新与其引用的规则集刷新需分别确认。

「更新配置」可能覆盖对远程基础配置做过的本地修改。只刷新规则资源时，使用「使用配置 / 编译配置」。操作说明参考 [社区手册](https://github.com/LOWERTOP/Shadowrocket#自动更新)。

## 新增模块约定

1. 纯分流放入 `modules/routing/`，统一以服务或用途命名，后缀为 `.module`。
2. 每个模块至少包含 `#!name`、`#!desc`、`[Rule]` 和一条有效引用。
3. 第一版校验器仅支持 HTTPS 的 `RULE-SET` / `DOMAIN-SET` 引用，以及 `PROXY` / `DIRECT` / `REJECT` 内置策略。增加新类型前先扩展检查；不要误以为这是小火箭全部支持的语法。
4. 上游 README 要求成对使用的文件必须同时引用：普通 `.list` 用 RULE-SET，纯域名 `_Domain.list` 用 DOMAIN-SET。OpenAI.list 可以单独使用。
5. 新增复写模块时创建 `modules/rewrite/`，同时说明脚本来源、配置修改范围和解密需求，并扩展校验工具。
6. 一项用途一个模块，避免把 FINAL、DNS 等全局设置混入服务分流模块。公共依赖域名可能影响其他应用，不承诺按应用进程隔离。

## 发布与回退

GitHub 仓库为 [tianvan/shadowrocket-modules](https://github.com/tianvan/shadowrocket-modules)，模块安装入口见 README。发布更新时，先检查再提交并推送 `main`，确认 GitHub Actions 和公开模块下载结果。

安装文件路径固定为 `modules/routing/OpenAI.module`。更新内容使用 Git 提交记录，路径不加入日期或版本号。确需移动时保留旧路径兼容，避免用户已有 URL 失效。

上线前运行：

```powershell
pwsh -NoProfile -File scripts/validate.ps1
pwsh -NoProfile -File scripts/validate.ps1 -CheckRemote
git diff --check
```

GitHub Actions 在 push、pull request 和手动运行时执行相同检查，只有只读仓库权限。远程检查失败必须查看具体 URL 和错误原因；不得把返回 HTML 的网页当成可用规则集。

检查通过后，仍需在小火箭中确认下载状态、规则测试和实际访问。上游不可用时，保留已有内容和 Git 历史，修复引用后重新发布，避免清空模块。

不要把真实节点订阅、账号、密钥或证书写入公开仓库。`.env` 和 `work/` 等本地文件已忽略。
