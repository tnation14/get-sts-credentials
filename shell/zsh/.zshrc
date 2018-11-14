# Path to your oh-my-zsh installation.
export ZSH=/Users/tnation/.oh-my-zsh
export VENV_DIR=$HOME/.venvs
export EDITOR=/usr/local/bin/EDITOR
export HOMEBREW_GITHUB_API_TOKEN=""
# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
 export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
 ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
 COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='subl -w'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PS1="%{$fg[blue]%}%n@%m%{$reset_color%}:%{$fg[cyan]%}%2d %# %{$reset_color%}"
export OLD_PS1=$PS1

function parse_git_branch(){
  BRANCH=$(git branch 2>/dev/null | grep \* | awk '{print $2}')
  if [ -z $BRANCH ]
  then
    BRANCH="Not in repo"
  fi
  
  echo $BRANCH
    
}

function workon() {
  export VARSFILE=$(printf "%s/%s_vars" $VENV_DIR $1)
  # Create project directory if it doesn't exist
  WORKDIR=~/Documents/projects/src/$1
  if ! [ -d $WORKDIR ]
  then
    mkdir -p $WORKDIR
  fi

  cd $WORKDIR
  
#  if ls "~/.ssh/$1*" > /dev/null 2>&1
#  then
#    for file in ~/.ssh/$1 do
#      ssh-add ~/.ssh/$file
#    done
#  fi 

  # create environment vars file, source during activation
  if ! [ -f $VARSFILE ] 
  then
    echo "creating environment variables file at $VARSFILE..." 
    echo "export WORKSPACE=$1" >> $VARSFILE
  fi

 # Give the user a chance to associate a github url
  if ! $(grep "GITHUB=" $VARSFILE)
  then
    echo "Add github URL?"
    read RESPONSE
    while [ $RESPONSE != "y" -a $RESPONSE != "n" ]
    do
      echo "Your response $RESPONSE is invalid. Please type y (continue)" \
           "or n (exit)"
      read RESPONSE
    done

    echo "Azavea repo?"
    read AZAVEA
    while [ $AZAVEA != "y" -a $AZAVEA != "n" ]
    do
      echo "Your response $AZAVEA is invalid. Please type y (continue)" \
           "or n (exit)"
      read AZAVEA
    done

    if [ "$RESPONSE" = "y" ]
    then
      if [ "$AZAVEA" = "y" ]
        then
          GITHUB="https://github.com/azavea/$1"
      else
        echo "Enter github URL: "
        read GITHUB
        while [ -z $GITHUB ]
        do
          echo "Please provide a github url"
          read GITHUB
        done
      fi
      echo "Writing to $VARSFILE"
      echo "export GITHUB=$GITHUB" >> $VARSFILE
    fi
  fi

  # Start virtualenv if it exists, create it if it doesn't.
  if [ -d $VENV_DIR/$1-venv/ ]
  then

    if ! $(grep "source $VARSFILE" $VENV_DIR/$1-venv/bin/activate)
    then
      echo "Adding environment variable support..."
      echo "source $VARSFILE" >> $VENV_DIR/$1-venv/bin/activate
    fi

    # Backwards compatibility for old virtual env name structure
    source ~/.venvs/$1-venv/bin/activate > /dev/null

  elif [ -d $VENV_DIR/$1/ ] 
  then

    # Make sure we import workspace environment variables when we activate

    if ! $(grep "source $VARSFILE" $VENV_DIR/$1/bin/activate)
    then
      echo "Adding environment variable support..."
      echo "source $VARSFILE" >> $VENV_DIR/$1/bin/activate
    fi
    source $VENV_DIR/$1/bin/activate > /dev/null

  else
    echo "Venv $1 does not exist. Creating now..."
    virtualenv $VENV_DIR/$1
    
    # Make sure we import workspace environment variables when we activate
    if ! $(grep "source $VARSFILE" $VENV_DIR/$1/bin/activate)
    then
      echo "Adding environment variable support..."
      echo "source $VARSFILE" >> $VENV_DIR/$1/bin/activate
    fi

    source $VENV_DIR/$1/bin/activate > /dev/null
  fi

  if ! [ -d $WORKDIR/.git ]
  then
    pushd ..
    git clone $GITHUB
    popd
  fi
  export PS1="%{$fg[green]%}--->\$(parse_git_branch)
%{$fg[blue]%}%n@%m%{$reset_color%}:%{$fg[cyan]%}%2d %# %{$reset_color%}"

  clear
  # Spin up dev environment, if it exists
  if [ -f Vagrantfile ]
  then
    vagrant up
  fi
}

function donewith(){
  VARSFILE=$(printf "%s/%s_vars" $VENV_DIR $1)
  FIRST_PATH_DIR=$(echo $PATH | cut -d ":" -f1)
  echo "FIRST_PATH_DIR: $FIRST_PATH_DIR"
  # Deactivate the virtual env if it's active
  if [ "$FIRST_PATH_DIR" = $VENV_DIR/$1/bin  -o  "$FIRST_PATH_DIR" = $VENV_DIR/$1-venv/bin ]
  then
    deactivate
  fi

  WORKDIR=~/Documents/projects/src/$1
  if [ -f $WORKDIR/Vagrantfile ]
  then
    pushd $WORKDIR
    vagrant halt
    popd
  fi

  echo "Delete your virtualenv and the project directory"
  echo " $WORKDIR? Type y to continue, n to deactivate and exit"
  read RESPONSE
  while [ $RESPONSE != "y" -a $RESPONSE != "n" ]
  do
    echo "Your response $RESPONSE is invalid. Please type y (continue)" /
         "or n (exit)"
    read RESPONSE
    done

  echo "response: $RESPONSE"
  cd ~
  if [ $RESPONSE = "y" ]
  then
    if [ -f $VARSFILE ]
    then
      echo "Deleting environment variables file..."
      rm $VARSFILE
    fi

    if [ -d $VENV_DIR/$1-venv/ ]
    then
    # Backwards compatibility for old virtual env name structure
      echo "Deleting virtual env: ~/.venvs/$1-venv"
      rm -r ~/.venvs/$1-venv
    else
      echo "Deleting virtual env: ~/.venvs/$1"
      rm -r ~/.venvs/$1
    fi
    
    if [ -f $WORKDIR/Vagrantfile ] && $(vagrant status | grep -E "running|poweroff")
    then
      pushd $WORKDIR
      echo "Destroying Vagrant box"
      vagrant destroy
      popd
    fi

    echo "Deleting workdir"
    sudo rm -rf $WORKDIR
  else
    if [ -f $WORKDIR/Vagrantfile ] && $(vagrant status | grep -E "running|poweroff")
    then
      pushd $WORKDIR
      echo "Destroying Vagrant box"
      vagrant destroy
      popd
    fi
  fi
  echo "Exiting..."
  export PS1=$OLD_PS1
}


function addvar(){
  WS_DIR=$(printf %s/%s_vars $VENV_DIR $WORKSPACE)
  echo "export $1=$2" >> $WS_DIR
  source $WS_DIR
}

function rmvar(){
  WS_DIR=$(printf %s/%s_vars $VENV_DIR $WORKSPACE)
  echo $WS_DIR $1
  sed -i '.bak' "s/$1=.*//g" $WS_DIR
  source $(printf %s/%s_vars $VENV_DIR $WORKSPACE)
}

function setvar(){
  WS_DIR=$(printf %s/%s_vars $VENV_DIR $WORKSPACE)
  sed -i '.bak' "s/$1=.*/$1=$2/g" $WS_DIR
  source $WS_DIR 
}

function venvs(){
  ls ${VENV_DIR} | grep -v "_vars" 
  # for VENV in $(ls $VENV_DIR)
  # do 
  #  # Only show the non-variable files
  #  echo $VENV | grep -v "_vars"
  # done
}


function vars(){
  if [ -f $(printf "%s/%s_vars" $VENV_DIR $WORKSPACE) ]
  then
    cat $(printf %s/%s_vars $VENV_DIR $WORKSPACE) | cut -d " " -f2
  else
    printf "No %s_vars file found." $WORKSPACE
  fi
}

function allvars(){
  for FILE in $(ls $VENV_DIR | grep "_vars")
  do
    NAME=$(echo $FILE | cut -d "_" -f1) 
    echo "FROM FILE $NAME: "
    cat $VENV_DIR/$FILE | cut -d " " -f2
    printf  "\n\n\n"
  done
  
}


compdef venvs workon

export NVM_DIR="/Users/tnation/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# added by travis gem
[ -f /Users/tnation/.travis/travis.sh ] && source /Users/tnation/.travis/travis.sh

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/tnation/Documents/projects/src/cicero-monitor/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/tnation/Documents/projects/src/cicero-monitor/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/tnation/Documents/projects/src/cicero-monitor/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/tnation/Documents/projects/src/cicero-monitor/node_modules/tabtab/.completions/sls.zsh