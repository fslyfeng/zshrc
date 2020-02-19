#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 获取平台类型，mac还是linux平台
function get_platform_type() {
    echo $(uname)
}
# 获取linux发行版名称
function get_linux_distro() {
    if grep -Eq "Debian" /etc/*-release; then
        echo "Debian"
    else
        echo "Unknow"
    fi
}
# 获取日期
function get_datetime() {
    time=$(date "+%Y%m%d%H%M%S")
    echo $time
}
# 判断文件是否存在
function is_exist_file() {
    filename=$1
    if [ -f $filename ]; then
        echo 1
    else
        echo 0
    fi
}

# 判断目录是否存在
function is_exist_dir() {
    dir=$1
    if [ -d $dir ]; then
        echo 1
    else
        echo 0
    fi
}
#备份原有的.zshrc文件
function backup_zshrc_file() {
    old_zshrc=$HOME"/.zshrc"
    is_exist=$(is_exist_file $old_zshrc)
    if [ $is_exist == 1 ]; then
        time=$(get_datetime)
        backup_zshrc=$old_zshrc"_bak_"$time
        read -p "Find "$old_zshrc" already exists,backup "$old_zshrc" to "$backup_zshrc"? [Y/N] " ch
        if [[ $ch == "N" ]] || [[ $ch == "n" ]]; then
            echo "No backup file, continue installation."
        else
            cp $old_zshrc $backup_zshrc
            rm $HOME"/.zshrc"
        fi
    fi
}

# 判断是否是macos10.15版本
function is_macos1015() {
    product_version=$(sw_vers | grep ProductVersion)
    if [[ $product_version =~ "10.15" ]]; then
        echo 1
    else
        echo 0
    fi
}

# 安装mac平台必备软件
function install_prepare_software_on_mac() {
    xcode-select --install
    brew install zsh 
    # macos1015=$(is_macos1015)
    # if [ $macos1015 == 1 ]; then
    #     open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.15.pkg
    # fi
}

# 安装debian必备软件
function install_prepare_software_on_debian() {
    sudo apt-get update
    sudo apt-get install -y git curl zsh
}

# 下载文件
function linux_download_file() {
    cd ~
    git clone https://github.com/fslyfeng/zshrc.git \
        ~/.zsh

}
# 安装zsh插件
function install_zsh_plugin() {
    cd ~
    #安装oh my zsh
    curl -Lo install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    #改exec为bash 防止自动退出
    sed -i 's/exec zsh -l//g' install.sh
    #运行文件
    sh install.sh
    #安装zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    #安装zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}
# 设置默认shell
function change_default_shell() {
    source ~/.zshrc
    chsh -s $(which zsh)
    rm ~/install.sh
    zsh -l
}
function change_zshrc_file() {
    sed -i 's/\=\"robbyrussell\"/\=\"agnoster\"/g' .zshrc
    sed -i 's/(git/(git zsh\-syntax\-highlighting zsh\-autosuggestions/g' .zshrc
}
# 在mac平台安装zsh
function install_zsh_on_mac() {
    backup_zshrc_file
    install_prepare_software_on_mac
    install_zsh_plugin
}

# 在debian上安装zsh
function install_zsh_on_debian() {
    backup_zshrc_file
    install_prepare_software_on_debian
    # linux_download_file
    install_zsh_plugin
    change_zshrc_file
    change_default_shell

}

# 在linux平上台安装zsh
function install_zsh_on_linux() {
    distro=$(get_linux_distro)
    echo "Linux distro: "${distro}

    if [ ${distro} == "Debian" ]; then
        install_zsh_on_debian
    else
        echo "Not support linux distro: "${distro}
    fi
}

# 获取当前时间戳
function get_now_timestamp() {
    cur_sec_and_ns=$(date '+%s-%N')
    echo ${cur_sec_and_ns%-*}
}

# main函数
function main() {
    begin=$(get_now_timestamp)
    type=$(get_platform_type)
    echo "Platform type: "${type}

    if [ ${type} == "Darwin" ]; then
        install_zsh_on_mac
    elif [ ${type} == "Linux" ]; then
        install_zsh_on_linux
    else
        echo "Not support platform type: "${type}
    fi

    end=$(get_now_timestamp)
    second=$(expr ${end} - ${begin})
    echo "It takes "${second}" second."
    echo "Done!"
}

# 调用main函数
main
