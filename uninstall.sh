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
# 在mac平台安装zsh
function uninstall_zsh_on_mac() {
    uninstall_oh_my_zsh
    brew uninstall zsh
}
# 在debian上安装zsh
function uninstall_zsh_on_debian() {
    uninstall_oh_my_zsh
    sudo apt-get remove -y zsh
}

# 在linux平上台安装zsh
function uninstall_zsh_on_linux() {
    distro=$(get_linux_distro)
    echo "Linux distro: "${distro}

    if [ ${distro} == "Debian" ]; then
        uninstall_zsh_on_debian
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
        uninstall_zsh_on_mac
    elif [ ${type} == "Linux" ]; then
        uninstall_zsh_on_linux
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
