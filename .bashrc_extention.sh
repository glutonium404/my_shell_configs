##################################################
########## this goes in the .bashrc ##############
##################################################

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w >> \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u:\w >> '
fi
