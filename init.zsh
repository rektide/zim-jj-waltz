# zim-jj-waltz: cached shell integration + completions for jw (jj-waltz).
#
# Caches the cd-enabling jw() wrapper from `jw shell init zsh` — minus its
# trailing completions eval — zcompiles it, and sources it. Regenerates only
# when the jw binary is newer than the cache. Completions regenerate into
# functions/_jw on fpath (zim-jujutsu idiom), so compinit autoloads them
# without an eval at every shell start.

(( ${+commands[jw]} )) || return

local _zim_jw_dir=${0:h}

# --- completions: regenerated on fpath, autoloaded by compinit ---
local _zim_jw_compfile=${_zim_jw_dir}/functions/_jw
if [[ ! -e ${_zim_jw_compfile} || ${_zim_jw_compfile} -ot ${commands[jw]} ]]; then
  mkdir -p -- ${_zim_jw_dir}/functions
  command jw shell completions zsh >| ${_zim_jw_compfile} || return 1
  print -u2 -PR "* Detected a new version of 'jw'. Regenerated completions."
fi

# --- wrapper: cached, precompiled ---
local _zim_jw_cache=${_zim_jw_dir}/.jw-init.zsh
if [[ ! -e ${_zim_jw_cache} || ${commands[jw]} -nt ${_zim_jw_cache} ]]; then
  # Strip the trailing completions eval: completions ship on fpath above, and
  # compdef does not exist yet at module-load time (completion loads later).
  command jw shell init zsh \
    | grep -v '^eval "$(command jw shell completions' >| ${_zim_jw_cache} || {
    rm -f -- ${_zim_jw_cache}
    return 1
  }
  zcompile -UR ${_zim_jw_cache}
  print -u2 -PR "* Detected a new version of 'jw'. Regenerated init cache."
fi

source ${_zim_jw_cache}
