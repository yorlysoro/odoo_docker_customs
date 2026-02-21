#!/bin/bash

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/yorlys/anaconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/yorlys/anaconda/etc/profile.d/conda.sh" ]; then
        . "/home/yorlys/anaconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/yorlys/anaconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
#conda activate odoo312
