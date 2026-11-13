# aws-profile

Bash and zsh functions for AWS profile switching, MFA session tokens, and SSM instance management.

## Features

- **aws-profile** - Switch AWS profiles
- **bin/aws-mfa-process** - `credential_process` helper: MFA session tokens via 1Password, cached and shared by every shell, IDE and SDK
- **aws-session-token** - Obtain STS session tokens with MFA
- **aws-clear** - Clear all AWS environment variables
- **ssm** - List EC2 instances and start SSM sessions with fuzzy matching

Tab completion works in both bash and zsh.

## Dependencies

**Required:**
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [jq](https://jqlang.github.io/jq/) - `brew install jq`

**Optional:**
- [1Password CLI](https://developer.1password.com/docs/cli/) - `brew install --cask 1password-cli` - for `bin/aws-mfa-process`
- [bkt](https://github.com/dimo414/bkt) - `brew install bkt` - caches EC2 API calls for faster tab-completion in `ssm`

## Installation

### Clone and source

**bash** (`~/.bashrc`):
```bash
git clone https://github.com/ironhalik/aws-profile.git ~/.aws-profile
echo 'source ~/.aws-profile/aws-profile' >> ~/.bashrc
```

**zsh** (`~/.zshrc`):
```zsh
git clone https://github.com/ironhalik/aws-profile.git ~/.aws-profile
echo 'source ~/.aws-profile/aws-profile' >> ~/.zshrc
```

### As a git submodule

```bash
git submodule add https://github.com/ironhalik/aws-profile.git path/to/aws-profile
```

Then `source path/to/aws-profile/aws-profile` from your shell rc. It loads everything in `lib/`.

## Usage

### aws-profile

```
aws-profile              # Show current profile
aws-profile my-profile   # Switch profile
aws-profile --clear      # Clear AWS env vars
```

### aws-session-token

```
aws-session-token --profile my-profile --token 123456
aws-session-token my-profile 123456
AWS_PROFILE=prod aws-session-token --token 123456
```

### ssm

```
ssm                      # List all instances (color-coded, newest first)
ssm i-0abc123def456      # Connect by instance ID
ssm web-server           # Fuzzy search by name, ID, or IP
```

## MFA via 1Password (credential_process)

Keep the long-term keys in a 1Password item instead of on disk. The item needs these fields
(the same names the 1Password AWS shell plugin uses):

- `Access Key ID`
- `Secret Access Key`
- `MFA Serial` - e.g. `arn:aws:iam::123456789012:mfa/myuser`
- `one-time password` - the TOTP

```ini
[profile my-mfa-profile]
region = us-east-1
credential_process = /path/to/aws-profile/bin/aws-mfa-process "op://Vault/Item"
```

On the first AWS call, the script reads the item with `op read`, calls `sts get-session-token`, and caches
the result in `~/.aws/cli/cache/mfa-<vault>-<item>-<hash>.json` (mode 0600). Every terminal, IDE, Terraform run and
SDK reuses it until 15 minutes before expiry (12h by default). The profile must not also contain static keys,
or some SDKs (e.g. Terraform's Go SDK) will use those and skip MFA.

## License

MIT
