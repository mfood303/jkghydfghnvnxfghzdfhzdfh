#!/usr/bin/env zsh

error() {
  echo "error: ${@:-unknown error}"
  exit 1
}

decrypt() {
  openssl enc -d -pbkdf2 -aes-256-cbc -pass pass:$PASS -in $1 -out temp &> /dev/null
  if [[ "$?" -gt 1 ]]; then
    error "failed to decrypt $1"
  else
    rm -rf "$1" || error "failed to delete $1"
  fi
}

decompress() {
  tar -xvf $1 &> /dev/null
  if [[ "$?" -gt 1 ]]; then
    error "failed to decompress $1"
  else
    rm -rf "$1" || error "failed to delete $1"
  fi
}

# get PASS
if [[ ! -f password.txt ]]; then
  error "missing file: password.txt"
else
  PASS="$(cat password.txt)" || error "failed to set PASS"
fi

# create images
if [[ -d images ]]; then
  rm -rf images &> /dev/null || error "failed to remove old image dir"
fi
mkdir images &> /dev/null || error "failed to create images"

for file in *.tar.gz.enc; do
  decrypt "$file"
  decompress temp
done

mv batch_*/* images/ || error "failed to merge batches"
rm -rf batch_* || error "failed to remove batch dirs"

exit 0
