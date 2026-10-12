# shadowrocket-modules 目录设计

状态：用户已于 2026-10-12 批准。项目目录已创建，模块和校验工具待实施。

## 目标

项目位于 `D:\Repos\shadowrocket-modules`，使用 Git `main` 分支。用户通过公开的 Raw URL 在 Shadowrocket 的模块页面下载安装，不必在手机上编辑模块。第一版实现 ChatGPT/OpenAI 分流，后续按功能添加模块。

## 推荐目录

```text
shadowrocket-modules/
├── README.md
├── modules/
│   └── routing/
│       └── OpenAI.module
├── docs/
│   ├── usage.md
│   └── maintenance.md
├── scripts/
│   └── validate.ps1
├── .github/
│   └── workflows/
│       └── validate.yml
├── .gitattributes
└── .gitignore
```

未来新增复写模块时创建 `modules/rewrite/`。第一版不创建空目录或占位文件。

## 各部分职责

| 路径 | 职责 |
| --- | --- |
| `README.md` | 项目介绍、模块目录、安装步骤、来源链接。发布 GitHub 仓库后使用真实安装地址。 |
| `modules/routing/` | 仅处理代理、直连、拒绝等流量策略的模块。第一版只有 `OpenAI.module`。 |
| `modules/rewrite/` | 将来存放请求重写、响应处理等模块；说明所需脚本和 HTTPS 解密条件。 |
| `docs/usage.md` | 下载启用、全局路由设置、规则测试、下载失败和常见故障排查。 |
| `docs/maintenance.md` | 上游来源、模块与规则集分别如何刷新、命名及新增模块约定。 |
| `scripts/validate.ps1` | 检查模块元信息、支持的结构、分流策略及远程规则引用；可选联网检查 URL 是否返回规则文本而非 HTML。 |
| `.github/workflows/validate.yml` | 在 push、pull request 和手动触发时运行检查；只读权限。 |
| `.gitattributes` | 规范文本文件的 LF 换行；UTF-8 无 BOM 由保存方式和校验脚本保证。 |
| `.gitignore` | 忽略系统临时文件、工作缓存及本地环境文件；不忽略模块和文档。 |

## 第一版模块行为

- 模块名为「ChatGPT / OpenAI 分流」。
- 使用 `[Rule]` 中的 `RULE-SET` 引用上游：
  `https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/OpenAI/OpenAI.list`。
- 策略为 `PROXY`，使用用户当前选定的代理节点。
- 不改变基础配置的最终兜底策略和 DNS 设置。
- 无脚本和 HTTPS 解密需求。
- 文档说明 `OpenAI.list` 可能覆盖公共依赖域名，因此效果并非严格按 iOS 应用进程隔离。
- 上游链接失效时检查应明确报错；保留 Git 历史，便于修复和回退。

## 更新与安装地址

自己的仓库保存模块，blackmatrix7 仓库维护规则。模块直接引用上游，无需 fork、Git submodule 或定时同步仓库。Shadowrocket 下载模块后还需成功下载其远程规则集。

上游规则更新后，使用 Shadowrocket 的「使用配置 / 编译配置」重新拉取规则，或启用相关后台刷新。后台刷新不保证实时执行。自己的模块内容变化时，另行更新远程模块。

安装路径保持为 `modules/routing/OpenAI.module`，稳定路径不包含日期或版本号。GitHub 仓库发布后，安装 URL 的格式为：

```text
https://raw.githubusercontent.com/<owner>/shadowrocket-modules/main/modules/routing/OpenAI.module
```

此处为设计中的地址格式，不是已发布的可用 URL。

## 维护约定

- 模块按「分流 / 复写」分目录，以服务或用途命名；分流文件统一使用 `.module` 后缀。
- 一项用途一个模块，避免启用大型合集后难以判断覆盖范围。
- 每个模块至少包含 `#!name`、`#!desc` 和有效配置段。
- 上游网址保留原始作者地址；README 和维护文档标明来源。
- 安装路径发布后尽量不移动；确需调整时保留旧路径兼容。
- 第一版检查验证文件及远程依赖，不冒充小火箭原生解析器；实际分流仍需在 iPhone 上通过规则测试及访问确认。

## 创建顺序

1. 确认本设计后，在指定目录初始化 Git。
2. 创建 OpenAI 模块、文档、Git 属性和忽略规则。
3. 创建轻量校验脚本及只读 GitHub Actions 工作流。
4. 检查文件编码、模块内容、规则直链和 Git 状态。
5. 本地项目创建与 GitHub 仓库发布是两个步骤；发布后才能得到手机可访问的公开模块 URL。
