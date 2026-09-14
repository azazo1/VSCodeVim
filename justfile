# just --list
# 列出全部可用的 recipe.
[private]
default:
    @just --list

# 按 yarn.lock 严格安装依赖.
install:
    yarn install --frozen-lockfile

# 快速开发构建, 产物输出到 out/.
build-dev:
    yarn build-dev

# 生产构建, 打包与发布前使用.
build:
    yarn build

# 监听源码变化并持续重建.
watch:
    yarn watch

# 编译测试代码 (gulp prepare-test), 本地测试前使用.
build-test:
    yarn build-test

# just test
# just test "Yank"
# 本地运行测试, 需要先关闭本机全部 VS Code 窗口, 参数为正则过滤用例名.
test *grep:
    yarn build
    yarn build-test
    MOCHA_GREP="{{grep}}" yarn test

# just docker-test
# just docker-test "Yank"
# 在 Docker 容器内运行测试 (推荐), 不需要关闭本机 VS Code, 参数为正则过滤用例名.
docker-test *grep:
    npx gulp test --grep "{{grep}}"

# 检查代码风格.
lint:
    yarn lint

# 自动修复代码风格问题.
lint-fix:
    yarn lint:fix

# 用 prettier 格式化全部文件.
prettier:
    yarn prettier

# 检查 prettier 格式, 只报告不修改.
prettier-check:
    yarn prettier:check

# 按 CI 的顺序执行格式检查, 风格检查与生产构建.
check:
    yarn prettier:check
    yarn lint
    yarn build

# 打包扩展为 vim-<version>.vsix.
package:
    yarn package

# 把最近打包出的 vsix 安装到本机 VS Code (会覆盖同 id 的旧版本).
install-vsix:
    code --install-extension "$(ls -t vim-*.vsix | head -1)" --force

# 清理构建与测试产物.
clean:
    rm -rf out .vscode-test testing vim-*.vsix
