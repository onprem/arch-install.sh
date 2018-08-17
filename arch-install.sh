#!/bin/bash

function set-time {
	timedatectl set-local-rtc 1 --adjust-system-clock
}

function partion {
	read -r -p "Do you want to do partioning? [y/N] " resp
	case "$resp" in
	    [yY][eE][sS]|[yY])
		read -r -p "which drive you want to partition? " drive
	        gdisk $drive
	        ;;
	    *)
	        ;;
	esac
}

function mounting {
	read -r -p "which is your root partition? " rootp
	mkfs.ext4 $rootp
	mount $rootp /mnt
	mkdir /mnt/boot
	read -r -p "which is your boot partition? " bootp
	read -r -p "Do you want to format your boot partition? [y/N] " response
	case "$response" in
	    [yY][eE][sS]|[yY])
	        mkfs.fat -F32 $bootp
	        ;;
	    *)
	        ;;
	esac
	mount $bootp /mnt/boot
}

function base {
	pacstrap /mnt base base-devel networkmanager sudo bash-completion git vim exfat-utils ntfs-3g grub os-prober efibootmgr htop
	genfstab -U /mnt >> /etc/fstab
}

function archroot {
	read -r -p "Enter the username: " uname
	read -r -p "Enter the hostname: " hname
	arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && hwclock --systohc && nano /etc/locale.gen && locale-gen && echo 'LANG=en_US.UTF-8' > /etc/locale.conf && echo $hname > /etc/hostname && echo 127.0.0.1	$hname >> /etc/hosts && echo ::1	$hname >> /etc/hosts && echo 127.0.1.1	$hname.localdomain	$hname >> /etc/hosts && passwd && useradd --create-home $uname && passwd $uname && groupadd sudo && gpasswd -a $uname sudo && EDITOR=vim visudo && pacman -S gnome gnome-tweaks papirus-icon-theme ttf-hack && systemctl enable gdm NetworkManager bluetooth && vim /etc/pacman.conf && pacman -Syu && sleep 1 && vim /etc/gdm/custom.conf && grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch && grub-mkconfig -o /boot/grub/grub.cfg && exit"
}

function browser {
	read -r -p "Install firefox? [y/N] " ff
	case "$ff" in
	    [yY][eE][sS]|[yY])
	        arch-chroot /mnt bash -c "pacman -S firefox && exit"
	        ;;
	    *)
	        ;;
	esac
	read -r -p "Install chromium? [y/N] " chrom
	case "$chrom" in
	    [yY][eE][sS]|[yY]) 
	        arch-chroot /mnt bash -c "pacman -S chromium && exit"
	        ;;
	    *)
	        ;;
	esac
}

function graphics {
	read -r -p "Do you want proprietary nvidia drivers? " graphic
	case "$graphic" in
	    [yY][eE][sS]|[yY]) 
	        arch-chroot /mnt bash -c "pacman -Sy nvidia nvidia-settings nvidia-utils lib32-nvidia-utils && exit"
	        ;;
	    *)
	        ;;
	esac
}

function installsteam {
	read -r -p "Do you want to install steam? " isteam
	case "$isteam" in
	    [yY][eE][sS]|[yY])
	        arch-chroot /mnt bash -c "pacman -Sy steam lib32-gtk2 lib32-gtk3 lib32-libpulse lib32-libvdpau lib32-libva lib32-libva-vdpau-driver lib32-openal && exit"
	        ;;
	    *)
	        ;;
	esac
}

function additional {
	read -r -p "Do you want to install fun stuff? " funyes
	case "$funyes" in
	    [yY][eE][sS]|[yY])
	        arch-chroot /mnt bash -c "pacman -S sl neofetch lolcat cmatrix && exit"
	        ;;
	    *)
	        ;;
	esac
}

function main {
	set-time
	partion
	mounting
	base
	archroot
	browser
	graphics
	installsteam
	additional
	echo "Installation complete. Reboot you lazy bastard."
}

read -r -p "Start Installation? [y/n] " starti
case "$starti" in
	    [yY][eE][sS]|[yY])
	        main
	        ;;
	    *)
	        ;;
esac
