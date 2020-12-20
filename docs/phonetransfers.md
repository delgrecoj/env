# Phone Transfers

(none of the other mtp packages work)

```sh
su
cdd
mkdir phonemnt
jmtpfs ./phonemnt
# cp ...
fusermount -u phonemnt
rmdir phonemnt
```
