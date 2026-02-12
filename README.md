# aws-profile

Bash and zsh functions for AWS profile switching, MFA session tokens, and SSM instance management.

## Features

- **aws-profile** - Switch AWS profiles with auto-MFA via 1Password
- **aws-session-token** - Obtain STS session tokens with MFA
- **aws-clear** - Clear all AWS environment variables
- **ssm** - List EC2 instances and start SSM sessions with fuzzy matching

Tab completion works in both bash and zsh.

## Dependencies

**Required:**
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [jq](https://jqlang.github.io/jq/) - `brew install jq`

**Optional:**
- [1Password CLI](https://developer.1password.com/docs/cli/) - `brew install --cask 1password-cli` - for auto-MFA in `aws-profile`
- [bkt](https://github.com/dimo414/bkt) - `brew install bkt` - caches EC2 API calls for faster tab-completion in `ssm`

## Installation

### Clone and source

**bash** (`~/.bashrc`):
```bash
git clone https://github.com/ironhalik/aws-profile.git ~/.aws-profile
echo 'for f in ~/.aws-profile/aws-*; do source "$f"; done' >> ~/.bashrc
```

**zsh** (`~/.zshrc`):
```zsh
git clone https://github.com/ironhalik/aws-profile.git ~/.aws-profile
echo 'for f in ~/.aws-profile/aws-*; do source "$f"; done' >> ~/.zshrc
```

### As a git submodule

```bash
git submodule add https://github.com/ironhalik/aws-profile.git path/to/aws-profile
```

Then source the files from your shell rc. Files are extensionless and sort correctly (`aws-common` loads first, providing shared helpers).

## Usage

### aws-profile

```
aws-profile              # Show current profile
aws-profile my-profile   # Switch profile (auto-MFA if configured)
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

## AWS Config for auto-MFA

Add `mfa_serial` and `mfa_otp_path` to your AWS config profile:

```ini
[profile my-mfa-profile]
region = us-east-1
mfa_serial = arn:aws:iam::123456789012:mfa/myuser
mfa_otp_path = op://vault/item/field
```

`mfa_otp_path` is a 1Password secret reference used by `op read` to fetch the current TOTP code.

## License

MIT
