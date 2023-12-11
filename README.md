# BiliBili_Livestream_Reminder ![Build and Release Status](https://github.com/hydrotho/BiliBili_Livestream_Reminder/actions/workflows/main.yml/badge.svg)

一款监控哔哩哔哩直播间并通过 Telegram 机器人发送通知的工具。

## 简介

`BiliBili_Livestream_Reminder` 能够实时监控指定的哔哩哔哩直播间。当直播开始、标题变更或直播结束时，它会自动通过 Telegram 机器人发送相应通知。这一过程涵盖了直播开始通知、标题变更实时更新以及直播结束时删除通知，确保用户能够及时获取直播间的最新状态。

## 快速开始

### 安装

请从 [发布页](https://github.com/hydrotho/BiliBili_Livestream_Reminder/releases/latest) 下载适用于 Linux、Windows 和 macOS 的预构建静态链接二进制文件。

### 配置

请参考 [配置示例](config.example.yaml) 进行配置。

### 使用

```shell
❯ BiliBili_Livestream_Reminder --help

 Usage: BiliBili_Livestream_Reminder [OPTIONS]

╭─ Options ────────────────────────────────────────────────────────────────────╮
│ --config        TEXT  [default: config.yaml]                                 │
│ --help                Show this message and exit.                            │
╰──────────────────────────────────────────────────────────────────────────────╯
```

## 支持

如果您遇到任何问题或有任何建议，欢迎 [提出问题](https://github.com/hydrotho/BiliBili_Livestream_Reminder/issues)。

## 许可证

本项目采用 MIT 许可证，详情请参见 [LICENSE](LICENSE) 文件。
