# reference: https://github.com/romkatv/powerlevel10k/issues/2212
() {

  function prompt_mise() {
    # Only invoke mise if a local config file actually exists
    local -a mise_files=(
      $PWD/mise.toml(N)
      $PWD/.mise.toml(N)
      $PWD/mise.local.toml(N)
      $PWD/.mise.local.toml(N)
      $PWD/.tool-versions(N)
    )
    if (( ${#mise_files} == 0 )); then
      return
    fi

    local mtime="${(j:,:)$(zstat +mtime ${mise_files} 2>/dev/null)}"

    if [[ "$_P10K_MISE_LAST_PWD" != "$PWD" || "$_P10K_MISE_LAST_MTIME" != "$mtime" ]]; then
      typeset -g _P10K_MISE_LAST_PWD="$PWD"
      typeset -g _P10K_MISE_LAST_MTIME="$mtime"
      typeset -g _P10K_MISE_CACHE="${(@f)$(mise ls --local 2>/dev/null | awk '!/\(symlink\)/ && $3!="~/.tool-versions" && $3!="~/.config/mise/config.toml" {print $1, $2}')}"
    fi

    local plugins=("${(@f)_P10K_MISE_CACHE}")
    local plugin
    for plugin in ${(k)plugins}; do
      local parts=("${(@s/ /)plugin}")
      local tool=${(U)parts[1]}
      local version=${parts[2]}
      local icon_var="POWERLEVEL9K_${tool}_ICON"
      if [[ -n "${(P)icon_var}" ]] || [[ -n "${icons[${tool}_ICON]}" ]]; then
        p10k segment -r -i "${tool}_ICON" -s $tool -t "$version"
      fi
    done
  }

  # Colors
  typeset -g POWERLEVEL9K_MISE_FOREGROUND=66
  typeset -g POWERLEVEL9K_MISE_RUBY_FOREGROUND=168
  typeset -g POWERLEVEL9K_MISE_PYTHON_FOREGROUND=37
  typeset -g POWERLEVEL9K_MISE_GOLANG_FOREGROUND=37
  typeset -g POWERLEVEL9K_MISE_NODE_FOREGROUND=70
  typeset -g POWERLEVEL9K_MISE_RUST_FOREGROUND=37
  typeset -g POWERLEVEL9K_MISE_DOTNET_CORE_FOREGROUND=134
  typeset -g POWERLEVEL9K_MISE_FLUTTER_FOREGROUND=38
  typeset -g POWERLEVEL9K_MISE_LUA_FOREGROUND=32
  typeset -g POWERLEVEL9K_MISE_JAVA_FOREGROUND=32
  typeset -g POWERLEVEL9K_MISE_PERL_FOREGROUND=67
  typeset -g POWERLEVEL9K_MISE_ERLANG_FOREGROUND=125
  typeset -g POWERLEVEL9K_MISE_ELIXIR_FOREGROUND=129
  typeset -g POWERLEVEL9K_MISE_POSTGRES_FOREGROUND=31
  typeset -g POWERLEVEL9K_MISE_PHP_FOREGROUND=99
  typeset -g POWERLEVEL9K_MISE_HASKELL_FOREGROUND=172
  typeset -g POWERLEVEL9K_MISE_JULIA_FOREGROUND=70

  # Substitute the default asdf prompt element
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/asdf/mise}")
}
