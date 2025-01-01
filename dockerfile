# Use the official Arch Linux base image
FROM archlinux:latest

# Set environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Disable Landlock to avoid warnings
RUN echo -e "[options]\nRestrictFS = off" >> /etc/pacman.conf

# Update and install necessary packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel curl git zsh neovim

# Install Yay (Yet Another Yaourt) as a non-root user
RUN useradd -m builduser && echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    su - builduser -c "git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    makepkg -si --noconfirm" && \
    rm -rf /tmp/yay

# Install additional packages using Yay
RUN yay -S --noconfirm btop bat neovim fzf lsd ripgrep tldr duf jq sd lazygit yazi procs gitui navi neofetch python3 tmux xclip rustup

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Install Zsh plugins
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc

# Add custom aliases to .zshrc
RUN echo 'alias vi=nvim' >> ~/.zshrc && \
    echo 'alias cat=bat' >> ~/.zshrc && \
    echo 'alias lgit=lazygit' >> ~/.zshrc && \
    echo 'alias ls=lsd' >> ~/.zshrc && \
    echo 'alias help=tldr' >> ~/.zshrc && \
    echo 'neofetch' >> ~/.zshrc

# Add NERDTree plugin for Neovim
RUN mkdir -p ~/.config/nvim/pack/vendor/start && \
    git clone https://github.com/preservim/nerdtree.git ~/.config/nvim/pack/vendor/start/nerdtree

#COPY .config/nvim/init.lua /root/.config/nvim

# Set Zsh as the default shell
RUN chsh -s $(which zsh)

RUN git config --global alias.co commit \
&& git config --global alias.br branch \
&& git config --global alias.st status \
&& git config --global alias.re reset \
&& git config --global alias.ch checkout \
&& git config --global alias.sb submodule

# Set working directory
WORKDIR /workspace

# Copy the pre-configured Powerlevel10k configuration
COPY .p10k.zsh /root/.p10k.zsh
COPY .zshrc /root/.zshrc

CMD ["/bin/zsh"]
