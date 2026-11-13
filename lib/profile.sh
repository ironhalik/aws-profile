# vim: set ft=bash :
# Requires: lib/common.sh (sourced first by ../aws-profile)

aws-profile() {
  case "${1:-}" in
    -h|--help)
      echo "Usage: aws-profile [--clear | profile-name]"
      echo "  No args:     Print current AWS_PROFILE"
      echo "  --clear:     Unset all AWS environment variables"
      echo "  profile-name: Switch to the given profile"
      echo ""
      echo "MFA profiles get credentials via credential_process = bin/aws-mfa-process"
      echo "(see README), so they work in every shell, not just this one."
      return 0
      ;;
    --clear)
      aws-clear
      return
      ;;
    "")
      echo "${AWS_PROFILE:-<not set>}"
      return 0
      ;;
  esac

  local profile="${1}"

  if ! _aws_profile_exists "${profile}"; then
    echo "Error: Profile '${profile}' not found" >&2
    echo "Available profiles:" >&2
    _aws_get_profiles | sed 's/^/  /' >&2
    return 1
  fi

  # Env credentials beat AWS_PROFILE, so drop any left over from a previous session
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
  export AWS_PROFILE="${profile}"

  # Region follows the profile; the previous profile's region must not stick
  unset AWS_REGION
  local region
  region=$(_aws_get_profile_value "${profile}" region)
  if [[ -n "${region}" ]]; then
    export AWS_REGION="${region}"
  fi
}

if _aws_is_zsh; then
  _aws-profile-completion() {
    local profiles
    profiles=$(_aws_get_profiles)
    local -a completions=(${=profiles} --clear --help)
    _describe 'aws-profile' completions
  }
  (( $+functions[compdef] )) && compdef _aws-profile-completion aws-profile
else
  _aws-profile-completion() {
    local profiles
    profiles=$(_aws_get_profiles)
    mapfile -t COMPREPLY < <(compgen -W "${profiles} --clear --help" -- "${COMP_WORDS[${COMP_CWORD}]}")
  }
  complete -F _aws-profile-completion aws-profile
fi
