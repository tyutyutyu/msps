# MSPS - Maven Settings Profile Switcher

![PyPI - Version](https://img.shields.io/pypi/v/msps?style=for-the-badge)
![PyPI - Python Version](https://img.shields.io/pypi/pyversions/msps?style=for-the-badge)
![PyPI - License](https://img.shields.io/pypi/l/msps?style=for-the-badge)
![Sonar Coverage](https://img.shields.io/sonar/coverage/tyutyutyu_msps?server=https%3A%2F%2Fsonarcloud.io&style=for-the-badge)
![Sonar Quality Gate](https://img.shields.io/sonar/quality_gate/tyutyutyu_msps?server=https%3A%2F%2Fsonarcloud.io&style=for-the-badge)

MSPS is a user-friendly tool that simplifies switching between various Maven
settings profiles.

## The problem

Profiles let you set up repositories or servers for each project or
environment, streamlining your workflow and keeping your workspace clean. You
can set up different settings for personal coding, testing new tools, and
work. However, there are a few settings, like mirror configurations, that
can't be tucked away in profiles.

This means if you need to switch between a private mirror in one environment
and the Maven Central in another, you'll need to make those adjustments
directly in the settings.xml file itself, or you might need to replace the
entire file. This can be cumbersome, especially when managing many profiles and
switching between them frequently.

## :hammer: Requirements

- Python 3.10 or later

> [!NOTE]
> Developed and tested on Linux (Ubuntu); may also work on macOS.

## :floppy_disk: Installation

```bash
pip install msps
```

## :gear: Configuration

### Maven settings profiles

The tool expects the Maven settings profiles to be stored in the Maven home directory.

MSPS first checks the `M2_HOME` environment variable to identify the Maven home directory. If this variable is not set, it searches for the `.m2` directory within the user's home directory.

The profiles should be named in the following format:

```plain
settings__profile_name.xml
```

## :wrench: Usage

```plain
msps <command> [profile]
```

### Commands

- `switch` - Switch to the next available profile or the specified profile.
- `list` - List available profiles.

### Profile

- The name of the profile to switch to.

## :man_mechanic: Examples

### Unspecified profile switch

The tool will automatically switch to the next available profile.

```bash
msps switch
```

```plain
╭──────────── Maven Settings Profile Switcher ────────────╮
│                                                         │
│  Profile changed from current_profile to next_profile.  │
│                                                         │
╰─────────────────────────────────────────────────────────╯
```

### Switch to profile

The specified profile will be activated.

```bash
msps switch work
```

```plain
╭───────────── Maven Settings Profile Switcher ──────────────╮
│                                                            │
│  M2_HOME: /home/testuser/.m2/                              │
│  Available settings profiles:                              │
│    - personal (/home/testuser/.m2/settings__personal.xml)  │
│    - work (/home/testuser/.m2/settings__work.xml)          │
│  Profile changed from personal to work.            │
│                                                            │
╰────────────────────────────────────────────────────────────╯
```

### Switch to non-existent profile

No changes will be made if the specified profile is not found.

```bash
msps switch target_profile
```

```plain
╭───────────── Maven Settings Profile Switcher ──────────────╮
│                                                            │
│  Missing profile: target_profile                           │
│                                                            │
│  M2_HOME: /home/testuser/.m2/                              │
│  Available settings profiles:                              │
│    - personal (/home/testuser/.m2/settings__personal.xml)  │
│    - work (/home/testuser/.m2/settings__work.xml)          │
│  No changes were made.                                     │
│                                                            │
╰────────────────────────────────────────────────────────────╯
```

### List available profiles

```bash
msps list
```

```plain
╭───────────── Maven Settings Profile Switcher ──────────────╮
│                                                            │
│  Available settings profiles:                              │
│    - personal (/home/testuser/.m2/settings__personal.xml)  │
│    - work (/home/testuser/.m2/settings__work.xml)          │
│                                                            │
╰────────────────────────────────────────────────────────────╯
```
