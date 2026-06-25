# 贡献指南

> 翻译自 [CONTRIBUTING.md](CONTRIBUTING.md)

本文档提供了一组为 VSCodeVim 做贡献的准则.
这些只是准则, 而非规则; 请根据你自己的判断来行事, 也欢迎对本文档提出修改建议.
如果你需要帮助, 可以到 [GitHub Discussions](https://github.com/azazo1/VSCodeVim/discussions) 或 [Slack](https://vscodevim.slack.com/) 来交流.

感谢你帮助我们让 VSCodeVim 变得更好! :clap:

## 提交 Issue

[GitHub issue tracker](https://github.com/azazo1/VSCodeVim/issues) 是追踪 bug 和功能建议的首选渠道.
在创建新的 bug 报告时, 请:

- 在已有的 issue 中搜索, 确认是否已经有人报告过你的问题或提出过你的想法
- 填写 issue 模板.

### 改善已有的 Issue

- 如果可以, 尝试复现 bug 并描述复现方法.
- 搜索 [重复的 issue](https://github.com/azazo1/VSCodeVim/issues?q=is%3Aissue+is%3Aopen+cursor). 看看哪些讨论更成熟, 并建议关闭重复的 issue, 或者直接提供相关 issue 的链接.
- 找出 [旧的 issue](https://github.com/azazo1/VSCodeVim/issues?page=25&q=is%3Aissue+is%3Aopen), 在最新版本的 VSCodeVim 中测试它们. 如果问题已经解决, 留言并建议原作者关闭 (如果未解决, 则提供更多信息).
- 给已有的 issue 点赞或点踩, 以表明你的支持 (或反对) 态度

## 提交 Pull Request

Pull request 棒极了.
如果你想为某个还没有对应 issue 的事情发起 PR, 可以考虑先创建一个 issue.

提交 PR 时, 请填写 GitHub 在打开 PR 时给出的模板.

## 首次配置

1. 安装前置依赖:
   - [Visual Studio Code](https://code.visualstudio.com/), 最新的稳定版或 insiders 版
   - [Node.js](https://nodejs.org/) v22.x 或更高版本
   - [Yarn](https://classic.yarnpkg.com/) v1.x
   - 可选: [Docker Community Edition](https://store.docker.com/search?type=edition&offering=community) 🐋

2. Fork 并克隆仓库:

   ```bash
   git clone git@github.com:<YOUR-FORK>/Vim.git
   cd Vim
   ```

3. 构建扩展:

   ```bash
   # 安装依赖
   yarn install

   # 在 VS Code 中打开
   code .

   # 用以下命令之一进行构建...
   yarn build-dev # 开发用的快速构建
   yarn build     # 发布用的慢速构建
   yarn watch     # 文件变动时进行快速构建
   ```

4. 使用 VS Code 的 "Run and Debug" 菜单运行扩展

5. 运行测试:

   ```bash
   # 如果已安装并运行 Docker:
   npx gulp test                 # 在 Docker 容器内运行测试
   npx gulp test --grep <REGEX>  # 在 Docker 容器内只运行匹配 <REGEX> 的测试/套件

   # 否则, 在本地构建并运行测试:
   yarn build                    # 构建
   yarn build-test               # 构建测试
   yarn test                     # 测试 (必须关闭所有 VS Code 实例)
   ```

6. 打包并安装扩展:

   ```bash
   # 将扩展打包为 `vim-<MAJOR>.<MINOR>.<PATCH>.vsix`
   # (它可以像 .zip 文件一样打开和查看)
   yarn package

   # 将打包好的扩展安装到你本地的 VS Code
   code --install-extension vim-<MAJOR>.<MINOR>.<PATCH>.vsix --force
   ```

## 代码架构

代码分为两个部分:

- ModeHandler - Vim 状态机
- Actions - 修改状态的 "动作"

### Actions

目前所有 action 都堆在 actions.ts 里 (抱歉!). 其中包括:

- `BaseAction` - 所有 Action 都派生自的基础 Action 类型.
- `BaseMovement` - 一个移动 (例如 `w`, `h`, `{` 等) 只会更新光标位置, 或返回一个表示起点和终点的 `IMovement`. 它用于像 `aw` 这样可能实际上起始于光标之前的移动.
- `BaseCommand` - 任何不只是移动的东西都是 Command. 这包括那些同时会以某种方式更新 Vim 状态的动作, 比如 `*`.

Action 应尽可能避免除修改 `vimState` 之外的副作用.

### Vim 状态机

由两个数据结构组成:

- `VimState` - 这是 Vim 的状态, 作用域为一个 `TextEditor`. 它是 action 所更新的对象.
- `RecordedState` - 这是临时状态, 会在一次变更结束时重置.

#### 工作原理

1. 以最近一次按键调用 `handleKeyEventHelper`.
2. `Actions.getRelevantAction` 判断目前已按下的所有键是否唯一对应 actions.ts 中的某个 action. 如果不是, 我们继续等待后续按键.
3. `runAction` 运行匹配到的 action. Movement, Command 和 Operator 各自有独立的函数来决定如何运行它们, 分别是 `executeMovement`, `handleCommand` 和 `executeOperator`.
4. 既然我们已经更新了 `VimState`, 就用新的 VimState 运行 `updateView`, 把 VS Code "重绘" 到新状态.

#### `vscode.window.onDidChangeTextEditorSelection`

这是我用来在一个 (暂时?) 没有点击事件 API 的 IDE 中模拟基于点击事件 API 的取巧做法. 我会检查刚传入的选区, 看它是否与我认为上次状态机更新时设置的选区相同. 如果不同, 用户 "很可能" 点击了鼠标 (但她也可能是用了 tab 补全!).

## 发布

在推送发布之前, 请务必确保 changelog 已更新!

要推送发布:

```bash
npx gulp release --semver [SEMVER]
git push --follow-tags
```

上面的 Gulp 命令会:

1. 根据提供的 semver 提升 package 版本号. 支持的值: patch, minor, major.
2. 用上述改动创建一个 Git commit.
3. 用新的 package 版本号创建一个 Git tag.

除了构建和测试扩展之外, 当某个 commit 被打上 tag 时, CI 服务器还会创建一个 GitHub release, 并将新版本发布到 Visual Studio marketplace.

## 故障排查

### VS Code 变慢

如果你注意到变慢, 并且曾经用 `yarn test` (而不是通过 VSCode) 运行过测试, 你可能会发现一个 `.vscode-test/` 文件夹, VSCode 会持续消耗 CPU 周期去索引它. 长话短说, 你可以这样加速 VSCode:

```bash
rm -rf .vscode-test/
```
