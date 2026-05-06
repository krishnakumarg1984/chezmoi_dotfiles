# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:

# ((( Notes/comments (README) about this file (~/.profile)

# ~/.profile is sourced only for login shells (non-login shells and scripts will NOT source this file at all).
# In my setup, scripts can be made to source this file indirectly by using the `--login` flag

# Nothing from ~/.profile other than exported variables and exported functions will be automatically provided to independent subprocess shells.
# Functions can be exported with export -f (with Bash)

# Note that this file (~/.profile) is EXPLICITLY sourced from my ~/.bash_profile
# For the `bash` interpreter, my ~/.bash_profile file MUST be present.
# This is because several settings (aliases, functions etc) for `bash` interactive sub-shells are configured in my ~/.bashrc which is sourced by ~/.bash_profile.

# Upon login, ~/.profile is read by `sh` (any shell with bourne-shell compatibility e.g. `bash` & `ksh`; But NOT `csh`, `tcsh` & `zsh`)
# Put stuff that applies to your whole session, such as programs to start when you log in (e.g. ssh-agent, screen -m etc., but not graphical programs; they go into a different file), environment variable definitions, and any other shell-agnostic startup settings/content.
# Graphical logins DO NOT read ~/.profile (there is no standard location for graphical logins to read environment variables from)

# LOGIN sourcing order for `bash`
# -------------------------------
# Many Linux systems also have another layer called PAM which is relevant here. Before "execing" bash, login will read the /etc/pam.d/login file
# (or its equivalent on your system), which may tell it to read various other files such as /etc/environment.
# Other systems such as OpenBSD have an /etc/login.conf file which controls resource limits for various classes of user accounts.
# So you may have some extra environment variables, process limits, and so on, before your shell reads /etc/profile.

# 0. Source /etc/profile if it exists and attempt to source the FIRST of the following user-startup files.
# Will also source /etc/profile.d/*.sh. If you plan on setting your own system wide environmental variables it is recommended to place your
# configuration in a **POSIX** shell script within /etc/profile.d. Linux Standard Base Core Specification 3.2 requires that the sh utility shall
# also read and execute commands in its current execution environment from all the shell scripts in the directory /etc/profile.d. Such scripts
# are read and executed as a part of reading and executing /etc/profile.

# 1. ~/.bash_profile is sourced if it exists (and stops there). If it doesn't exist, go to #2 below
# 2. ~/.bash_login is sourced if it exists (and stops there). If it doesn't exist, go to #3 below
# 3. THIS FILE: ~/.profile  (if `bash` is started as `sh` (e.g. /bin/sh is a link to /bin/bash) or is started with the --posix flag, it tries to
# emulate `sh`, and only reads ~/.profile)

# http://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

# For Bash, read down the appropriate column.
# Sources A, then B, then C, etc. The B1, B2, B3 means it sources only the first of those files found.

# +----------------+-----------+-----------+------+
# |                |Interactive|Interactive|Script|
# |                |login      |non-login  |      |
# +----------------+-----------+-----------+------+
# |/etc/profile    |   A       |           |      |  # Typically does the following: a) sets up $PS1 for root and normal users, b) sources scripts in /etc/profile.d/, c) in a system with bash interpreter, sources /etc/bash.bashrc (Debian only) or /etc/bashrc
# +----------------+-----------+-----------+------+
# |/etc/bash.bashrc|           |    A      |      |  # Debian-specific
# +----------------+-----------+-----------+------+
# |~/.bashrc       |           |    B      |      |
# +----------------+-----------+-----------+------+
# |~/.bash_profile |   B1      |           |      |
# +----------------+-----------+-----------+------+
# |~/.bash_login   |   B2      |           |      |
# +----------------+-----------+-----------+------+
# |~/.profile      |   B3      |           |      |
# +----------------+-----------+-----------+------+
# |BASH_ENV        |           |           |  A   |
# +----------------+-----------+-----------+------+
# |                |           |           |      |
# +----------------+-----------+-----------+------+
# |                |           |           |      |
# +----------------+-----------+-----------+------+
# |~/.bash_logout  |    C      |           |      |
# +----------------+-----------+-----------+------+

# ))) Notes/comments (README) about this file (~/.profile)

# ((( Nice/detailed explanations of shell startup concepts and configuration files
# https://unix.stackexchange.com/questions/3052/is-there-a-bashrc-equivalent-file-read-by-all-shells
# https://superuser.com/questions/183870/difference-between-bashrc-and-bash-profile/183980
# ----------------------------------------------------------------------------------------

# Back in the old days, when pseudo tty's weren't pseudo and actually, well, typed, and UNIXes were accessed by modems so slow you could see each
# letter being printed to your screen, efficiency was paramount. To help efficiency somewhat you had a concept of a main login window and
# whatever other windows you used to actually work. In your main window, you'd like notifications to any new mail, possibly run some other
# programs in the background.
#
# To support this, shells sourced a file .profile specifically on 'login shells'. This would do the special, once a session setup. Bash extended
# this somewhat to look at .bash_profile first before .profile, this way you could put bash only things in there (so they don't screw up Bourne
# shell, etc, that also looked at .profile). Other shells, non-login, would just source the rc file, .bashrc (or .kshrc, etc).
#
# This is a bit of an anachronism now. You don't log into a main shell as much as you log into a gui window manager. There is no main window any
# different than any other window.

# https://mywiki.wooledge.org/DotFiles
# Console logins
# --------------

# Let's start with the simplest configuration: a local login on the Linux text console, without any graphical environment at all, without systemd
# in the picture. In this case, when you boot the computer, you eventually see a "login:" prompt. This prompt is produced by a program called
# getty(8) which runs on the tty (terminal) device. When you type a username, getty reads it and passes it to the program called login(1). login
# reads the password database and decides whether it needs to ask you for a password. Once you've provided your password, login "execs" your
# login shell, bash, with a hyphen in front of the process name ("-/bin/bash" for example). This leading hyphen is a special ancient hack which
# means "this is a login shell, not a regular shell".

# Now, since bash is being invoked as a login shell, it reads /etc/profile first. On Linux systems, this will typically also source some or all
# files in /etc/profile.d (as suggested by the Linux Standard Base
# (https://refspecs.linuxfoundation.org/LSB_3.2.0/LSB-Core-generic/LSB-Core-generic/sh.html) -- generally /etc/profile should include code for
# this). This specification requires that the sh utility shall also read and execute commands in its current execution environment from all the
# shell scripts in the directory /etc/profile.d. Such scripts are read and executed as a part of reading and executing /etc/profile. Then, bash
# looks in your home directory for .bash_profile, and if it finds it, it reads that. If it doesn't find .bash_profile, it looks for .bash_login,
# and if it doesn't find that, it looks for .profile (the standard Bourne/POSIX/Korn shell configuration file). Otherwise, it stops looking for
# dot files, and gives you a prompt.

# Many Linux systems also have another layer called PAM which is relevant here. Before "execing" bash, login will read the /etc/pam.d/login file
# (or its equivalent on your system), which may tell it to read various other files such as /etc/environment. Other systems such as OpenBSD have
# an /etc/login.conf file which controls resource limits for various classes of user accounts. So you may have some extra environment variables,
# process limits, and so on, before your shell reads /etc/profile.

# Why is .bashrc a separate file from .bash_profile, then? There are a couple reasons. The first is performance -- when machines were extremely
# slow compared to today's workstations, processing the commands in .profile or .bash_profile could take quite a long time, especially on
# machines where a lot of the work had to be done by external commands (before Korn/Bash shells). So the difficult initial set-up commands, which
# create environment variables that can be passed down to child processes, are put in .bash_profile. The transient settings and aliases/functions
# which are not inherited are put in .bashrc so that they can be re-read by every new interactive shell.

# The second reason why .bashrc is separate is due to work habits. If you work in an office setting with a terminal on your desk, you probably
# login one time at the start of each day, and logout at the end of the day. You may put various special commands in your .bash_profile that you
# want to run at the start of each day, when you login -- checking for announcements from management, etc. You wouldn't want those to be done
# every time you launch a new shell. So, having this separation gives you some flexibility.

# Let's take a moment to review. A system administrator has set up a Debian system (which is Linux-based and uses PAM) and has a locale setting
# of LANG=en_US in /etc/environment. A local user named pierre prefers to use the fr_CA locale instead, so he puts export LANG=fr_CA in his
# .bash_profile. He also puts source ~/.bashrc in that same file, and then puts set +o histexpand in his .bashrc. Now he logs in to the Debian
# system by sitting at the console. login(1) (via PAM) reads /etc/environment and puts LANG=en_US in the environment. Then login "execs" bash,
# which reads /etc/profile and .bash_profile. The export command in .bash_profile causes the environment variable LANG to be changed from en_US
# to fr_CA. Finally, the source command causes bash to read .bashrc, so that the set +o histexpand command is executed for this shell. After all
# this, pierre gets his prompt and is ready to type commands interactively.


# Remote shell logins
# -------------------

# Now let's take the second-simplest example: an ssh login. This is extremely similar to the text console login, except that instead of using
# getty and login to handle the initial greeting and password authentication, sshd(8) handles it. sshd in Debian is also linked with PAM, and it
# will read the /etc/pam.d/ssh file (instead of /etc/pam.d/login). Otherwise, the handling is the same. Once sshd has run through the PAM steps
# (if applicable to your system), it "execs" bash as a login shell, which causes it to read /etc/profile and then one of .bash_profile or
# .bash_login or .profile.

# The major difference when using a remote shell login instead of a local console login is that there is a client ssh process running on your
# local system (or wherever you ssh-ed from) which already has its own environment variables -- and some of those may be sent to the sshd on the
# system you're logging into. In particular, it is desirable for the LANG and LC_* variables to be preserved by the remote shell. Unfortunately,
# the configuration files on the server may override them. Getting this set up to work correctly in all cases is tricky. (Here's an example
# procedure for Debian.)

# Remote non login non interactive shells ---------------------------------------

# Bash has a special compile time option that will cause it to source the .bashrc file on non-login, non-interactive ssh sessions. This feature
# is only enabled by certain OS vendors (mostly Linux distributions). It is not enabled in a default upstream Bash build, and (empirically) not
# on OpenBSD either.

# If this feature is enabled on your system, Bash detects that SSH_CLIENT or SSH_CLIENT2 is in the environment and in this case source .bashrc.
# For example, suppose you have var=foo in your remote .bashrc and you do ssh remotehost echo \$var it will print foo.

# This shell is non-interactive so you can test $- or $PS1, if you don't want things to be executed this way in your .bashrc.
# Without this option bash will test if stdin is connected to a socket and will also source .bashrc in this case BUT this test fails if you use a
# recent openssh server (>5.0) which means that you will probably only see this on older systems.

# Note that a test on SHLVL is also done, so if you do: ssh remotehost bash -c echo then the first bash will source .bashrc but not the second
# one (the explicit bash on the command line that runs echo).

# The behaviour of the bash patched to source a system level bashrc by some vendors is left as an exercise.


# X sessions ----------
#
# Let's suppose pierre (our console user) decides he wants to run X for a while. He types startx, which invokes whichever set of X clients he
# prefers. startx is a wrapper around xinit, which runs the X server ("X"), and then runs through pierre's .xinitrc or .xsession file (if either
# one exists), or the system-wide default Xsession otherwise. Let's suppose pierre has the command exec fluxbox (and nothing else) in his
# .xsession file. When the smoke clears, he'll have an X server process running (as root), and a fluxbox process running (as pierre). fluxbox was
# created as a child of xinit, which was a child of startx, which was a child of bash, so it inherited pierre's LANG and other environment
# variables. When pierre launches something from the window manager's menu, that new command will be a child of fluxbox, so it inherits LANG,
# PATH, MAIL, etc. as well. In addition to all of that, fluxbox inherits the DISPLAY environment variable which tells it which X server to
# contact (in this case, probably :0).
#
# So what happens when pierre runs an xterm? fluxbox "forks" and "execs" an xterm process, which inherits DISPLAY, and so on. xterm contacts the
# X server, authenticates if necessary, and then draws itself on the display. In addition to DISPLAY, it inherited pierre's SHELL variable, which
# probably contains /bin/bash, so it sets up a pseudo-terminal, then spawns a /bin/bash process to run in it. Since /bin/bash doesn't start with
# a -, this one will not be a login shell. It will be a normal shell, which doesn't read /etc/profile or .bash_profile or .profile. Instead, it
# reads .bashrc which in our example contains the line set +o histexpand. So his new xterm is running a bash shell, with all of his environment
# variables set (remember, they were inherited from his initial text console login shell), and his shell option of choice has been enabled (from
# .bashrc).
#
# What we've seen so far is the normal Unix setup. Many people choose to run their systems this way, and it works well. It's also fairly simple
# to understand once you've been exposed to the basic concepts. If you want to change something, you know precisely what file to edit to make it
# happen -- aliases and transient shell options go in .bashrc, and environment variables, process limits, and so on go in .bash_profile. If you
# want to run various X client commands before your window manager or desktop environment is invoked (for example, xterm & or xmodmap -e 'keysym
# Super_R = Multi_key'), you can put them in .xsession before the exec YourWindowManager line.

# Display Manager logins
# ----------------------
#
# However, some people like to have a graphical login (display manager), and that changes pretty much everything we've seen so far. Instead of
# getty and login, there's an xdm (or gdm or kdm or wdm or ...) process handling the authentication. And the biggest difference of all is that
# when our *dm process finishes authenticating the user, it doesn't "exec" a login shell. Instead, it "execs" an X session directly. Therefore,
# none of the "normal" user configuration files are read in at all -- no /etc/profile, no .bash_profile and no .profile. (But /etc/environment is
# still read in by PAM, assuming /etc/pam.d/*dm is configured to use pam_limits, as is the case on Debian.)
#
# Let's take xdm as an example. Pierre comes back from vacation one day and discovers that his system administrator has installed xdm on the
# Debian system. He logs in just fine, and xdm reads his .xsession file and runs fluxbox. Everything seems to be OK until he gets an error
# message in the wrong locale! Since he overrides the LANG variable in his .bash_profile, and since xdm never reads .bash_profile, his LANG
# variable is now set to en_US instead of fr_CA.
#
# Now, the naive solution to this problem is that instead of launching xterm, he could configure his window manager to launch xterm -ls. This
# flag tells xterm that instead of launching a normal shell, it should launch a login shell. Under this setup, xterm spawns /bin/bash but it puts
# -/bin/bash (or maybe -bash) in the argument vector, so bash acts like a login shell. This means that every time he opens up a new xterm, it
# will read /etc/profile and .bash_profile (built-in bash behavior), and then .bashrc (because his .bash_profile says to do that). This may seem
# to work fine at first -- his dot files aren't heavy, so he doesn't even notice the delay -- but there's a more subtle problem. He also launches
# a web browser directly from his fluxbox menu, and the web browser inherits the LANG variable from fluxbox, which is still set to the wrong
# locale. So while his xterms may be fine, and anything launched from his xterms may be fine, his web browser is still giving him pages in the
# wrong locale.

# So, what's the best solution to this problem? There really isn't a universal one.


# ))) Nice/detailed explanations of shell startup concepts and configuration files
