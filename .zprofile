export BROWSER="firefox"
export EDITOR="nvim"
export VISUAL="nvim"
export ZDOTDIR="$HOME/.config/zsh"
export PDF="zathura"
export VCPKG_ROOT="$HOME/dev/github/vcpkg"
export XDG_CONFIG_HOME="$HOME/.config"
# Scaling factor for alacritty. Alacritty scales with dpi by default.
# When having two screens of different sizes this means that the font size
# can be ridiculously small. We try to override this by setting this environment variable
# so we don't scale, but rather keep a fixed font size.
export WINIT_X11_SCALE_FACTOR=1

export PATH="$HOME/.local/bin:$PATH:$HOME/.zsh:$HOME/bin:$HOME/.cargo/bin:$VCPKG_ROOT"

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
   exec startx
fi

export SSH_ENV="$HOME/.ssh/environment"

# Starts ssh-agent by writing the output of ssh-agent into a file determined by $SSH_ENV
# and finally sources the contents of $SSH_ENV to the environment.
# Inspiration from here: https://www.tomaszmik.us/2020/09/21/auto-start-ssh-agent-zsh/
ssh_agent_start() {
   ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
   chmod 600 "${SSH_ENV}"
   source "${SSH_ENV}" > /dev/null

   ssh-add -q $HOME/.ssh/id_ed25519
   ssh-add -q $HOME/.ssh/id_ed25519_nordic
}

#if [ $(ps ax | grep "[s]sh-agent" | wc -l) -eq 0 ]; then
if [ -f "${SSH_ENV}" ]; then
   source "${SSH_ENV}" > /dev/null
   ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ > /dev/null || {
      ssh_agent_start
   }
else
   ssh_agent_start
fi

