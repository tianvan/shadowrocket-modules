# 更新与维护

## 来源

| 模块 | 上游规则 | 策略 |
| --- | --- | --- |
| `modules/routing/OpenAI.module` | [OpenAI.list](https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/OpenAI/OpenAI.list) | PROXY |

模块直接引用 [blackmatrix7/ios_rule_script](https://github.com/blackmatrix7/ios_rule_script) 的 `master` 分支，不在本仓库镜像域名列表。因此不需要 fork、Git submodule 或同步上游工作流。

## 直连基础配置

`configs/direct.conf` 的规则部分只包含 `FINAL,DIRECT`，General 明确设置 DNS 和回退策略。它供「指定模块代理，其余直连」场景使用，不增加其他代理规则。现有校验器会拒绝额外规则、代理兜底、重复兜底，以及不符合目标的 General 设置。来源与参数取舍见 [社区核对记录](community-validation.md)。

新建其他类型的完整配置时，需要先扩展校验器和相应文档。不要把完整配置 URL 添加到模块页面。

校验当前仓库和 CI 时必须存在 `configs/direct.conf`。对独立模块目录使用 `-Root` 时默认不要求完整配置；若该目录也要发布直连配置，添加 `-RequireDirectConfig`。

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

安装文件路径固定为 `modules/routing/OpenAI.module` 和 `configs/direct.conf`。更新内容使用 Git 提交记录，路径不加入日期或版本号。确需移动时保留旧路径兼容，避免用户已有 URL 失效。

`assets/qrcodes/Direct.png` 和 `assets/qrcodes/OpenAI.png` 编码 HTTPS 安装页地址，分别为 `https://tianvan.github.io/shadowrocket-modules/install/#direct` 和 `https://tianvan.github.io/shadowrocket-modules/install/#openai`。iPhone 使用系统相机打开网页，再点击页面安装按钮或复制 URL；小火箭模块添加页面本身没有扫码入口。

`docs/install/index.html` 提供固定安装按钮和 Raw URL，不从查询参数拼接任意跳转目标。`install.js` 只处理复制按钮，复制失败会选择地址并提示手动复制。通过 GitHub Pages 从 `main` 分支的 `/docs` 发布，`docs/.nojekyll` 保留静态文件。

页面按钮的协议依据：[Shadowrocket 社区手册 URL-Schemes](https://github.com/LOWERTOP/Shadowrocket#url-schemes)。当前二维码使用标准黑白和四格空白边框；二维码解码和复制行为在电脑验证，手机应用跳转、导入仍需要实机验证。

仅修改模块或配置内容无需重新生成二维码。若改变仓库、分支或文件路径，同步更新安装页按钮、复制地址和文档；安装页地址改变时再更新二维码。2026-10-12 根据用户要求将配置由 Direct.conf 更名为 direct.conf，旧 Raw URL 不再作为安装入口。

上线前运行：

```powershell
pwsh -NoProfile -File scripts/validate.ps1
pwsh -NoProfile -File scripts/validate.ps1 -CheckRemote
git diff --check
```

GitHub Actions 在 push、pull request 和手动运行时执行相同检查，只有只读仓库权限。远程检查失败必须查看具体 URL 和错误原因；不得把返回 HTML 的网页当成可用规则集。

检查通过后，仍需在小火箭中确认下载状态、规则测试和实际访问。上游不可用时，保留已有内容和 Git 历史，修复引用后重新发布，避免清空模块。

不要把真实节点订阅、账号、密钥或证书写入公开仓库。`.env` 和 `work/` 等本地文件已忽略。
