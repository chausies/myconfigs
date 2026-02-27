This is the a bunch of config files for my labtop, like .bashrc.

Before using, first do the following ssh stuff so you can work with Github.
```bash
# Enter nothing for file, check Bitwarden for pass
ssh-keygen -t ed25519 -C "chausies7@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```
Whatever got pasted out by the final command, copy it, and paste it to
[https://github.com/settings/ssh/new](https://github.com/settings/ssh/new)

Finally, you can run the following.

```bash
cd ~
git clone git@github.com:chausies/myconfigs.git
bash ~/myconfigs/INIT_RUN_THIS.sh
```
