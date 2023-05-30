# pp

a safer wrapper around dd(1)

are you a sysadmin?

are you sad `--dry-run` has not been evangelized to you yet?

well look no more:

```
$ sudo pp if=./void-live-x86_64-20221001-base.iso of=/dev/sdb conv=fdatasync status=progress

Argument 'of' points to sdb: Cruzer Blade
At least one block device was found in this invocation.
        do you wish to continue? (say 'yes'): yes
Operation confirmed, running dd.
410227200 bytes (410 MB, 391 MiB) copied, 153 s, 2.7 MB/s
```

## installing

- linux only because i know sysfs exists there

```
git clone https://github.com/lun-4/pp.git
cd pp
sudo make install
```

## uninstalling

```
sudo make uninstall
```
