使用 yarn, 而不是使用其他的 node 工具.

## 版本号

本仓库是 upstream(VSCodeVim/Vim) 的 fork, 采用双重版本号机制:
上游版本 + fork 版本, 形如 `v1.32.4-v0.1.0`.

- 前段 `v1.32.4` 跟随 upstream 的版本(与 package.json 中的 version 一致).
- 后段 `-v0.1.0` 为本 fork 自身的版本, fork 每次发布递增.

打 tag 和创建 release 时使用此格式.
