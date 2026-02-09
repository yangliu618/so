# Windows SSH 登录工具

## 一、说明

这是一个基于Windows PowerShell的SSH登录工具，支持密码和密钥两种登录方式，兼容Windows 10和Windows 11系统。

### 功能特点：
- 支持密码登录和密钥文件登录
- 配置文件与Linux版本保持一致
- 简单易用的命令行界面
- 支持自定义端口
- 密码自动填入功能

## 二、环境要求

- Windows 10 或 Windows 11
- PowerShell 5.1 或更高版本
- OpenSSH 客户端（Windows 10 1809及以上版本已内置，可在"设置 > 应用 > 可选功能"中安装）
- PuTTY 工具包（用于密码自动填入功能，可从 [PuTTY官网](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) 下载）

## 三、配置

### 密码文件配置：

1. 复制 `password.lst.simple` 文件并重命名为 `password.lst`
2. 编辑 `password.lst` 文件，按照以下格式添加主机信息：

```
序号:IP:端口:用户:密码:说明
1:192.168.88.128:22:root:toor:虚拟机web服务器
#2:192.168.88.128:22:root:toor:虚拟机web服务器  # 注释用#，该行不会展示
```

### 密钥文件配置：

1. 将密钥文件放在 `keys` 文件夹下
2. 密钥文件名必须以 `.pem` 结尾
3. 在 `password.lst` 文件中，密码位置填写密钥文件名

## 四、使用方法

### 方法一：直接运行批处理文件

1. 双击 `so.bat` 文件
2. 在弹出的命令行窗口中，输入主机序号选择要连接的主机
3. 对于密码登录，系统会自动使用plink.exe填入密码
4. 对于密钥登录，系统会自动使用指定的密钥文件

### 方法二：在命令行中运行

1. 打开命令提示符（cmd）或PowerShell
2. 导航到工具所在目录
3. 运行 `so.bat` 或 `powershell -ExecutionPolicy Bypass -File so.ps1`
4. 按照提示选择主机并登录

### 方法三：配置 `gg` 命令（推荐）

#### 方法 1：创建 PowerShell 函数

1. 打开 PowerShell 配置文件
   执行以下命令查看你的 PowerShell 配置文件路径：
   ```powershell
   $PROFILE
   ```
   通常输出类似：
   ```text
   C:\Users\username\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
   ```

2. 创建目录和配置文件（如果不存在）
   ```powershell
   mkdir (Split-Path $PROFILE) -Force
   notepad $PROFILE
   ```

3. 在打开的文件中添加以下内容：
   ```powershell
   function gg {
       cmd /c "D:\www\so\so.bat"
   }
   ```
   说明：
   - `cmd /c` 表示用 CMD 执行 .bat 文件（因为 .bat 是 CMD 脚本）
   - 如果 so.bat 需要接收参数，可以改成：
   ```powershell
   function gg {
       cmd /c "D:\www\so\so.bat $args"
   }
   ```

4. 保存文件并重启 PowerShell，或执行：
   ```powershell
   . $PROFILE
   ```

5. 现在你可以直接运行：
   ```powershell
   gg
   ```
   它就会执行 D:\www\so\so.bat！

## 五、密码自动填入功能说明

本工具使用plink.exe（PuTTY的命令行工具）来实现密码自动填入功能。plink.exe是PuTTY的一部分，支持通过命令行参数指定密码，这是实现自动登录的可靠方法。

### 配置步骤：

1. 从 [PuTTY官网](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) 下载PuTTY工具包
2. 安装PuTTY或解压到任意目录
3. 将PuTTY的安装目录添加到系统PATH环境变量中，或者将plink.exe复制到系统目录（如C:\Windows\System32）
4. 确保plink.exe可以在命令行中直接运行

### 验证plink.exe是否可用：

打开命令提示符或PowerShell，执行以下命令：
```
plink --version
```

如果能看到版本信息，则说明plink.exe已正确配置。

## 六、注意事项

1. 用户名和密码以明文形式保存在 `password.lst` 文件中，请妥善保管该文件
2. 确保 `keys` 文件夹中的密钥文件权限设置正确，建议设置为仅当前用户可访问
3. 如果遇到"ssh命令未找到"的错误，请检查是否已安装OpenSSH客户端
4. 如果遇到"plink.exe not found"的错误，请检查是否已安装PuTTY并正确配置PATH环境变量
5. 对于首次连接的主机，系统会提示确认主机指纹，输入"y"即可

## 七、示例

### 密码登录配置示例：

```
1:192.168.1.100:22:admin:password123:办公服务器
```

### 密钥登录配置示例：

```
2:192.168.1.200:22:ubuntu:mykey.pem:测试服务器
```

其中 `mykey.pem` 是放在 `keys` 文件夹下的密钥文件名。
