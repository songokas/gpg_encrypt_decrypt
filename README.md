## Encrypt/Decrypt directories recursively using gpg

### Encrypting

```bash
All contents of --encrypt-path directory will be encrypted to --output directory
Usage: ./encrypt.sh --recipient|-r Recipient Id --encrypt-path|-e ~/not_encrypted --output|-o ~/tmp [--skip-existing|-s true]
```

### Decrypting

```bash
All contents of --decrypt-path directory will be decrypted to --output directory
Usage: ./decrypt.sh --decrypt-path|-d ~/encrypted --output|-o ~/tmp [--skip-existing|-s true]
```

### This script is mainly for home usage, uploading private files to cloud, ftp, dropbox, etc.


### Requirements

* gpg
* bash
