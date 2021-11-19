# Define a function which rename a `target` file to `target.backup` if the file
# exists and if it's a 'real' file, ie not a symlink
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "-----> Symlinking your new $link"
    ln -s $file $link
  fi
}

# For all files `$name` in the present folder except `*.sh`, `README.md`, `settings.json`,
# and `config`, backup the target file located at `~/.$name` and symlink `$name` to `~/.$name`
for name in .??*; do
  if [ ! -e "$name" ]; then
    target="$HOME/$name"
    if [[ ! "$name" =~ '\.sh$' ]] && [ "$name" != 'README.md' ] && [[ "$name" != 'config' ]]; then
      backup $target
      symlink $PWD/$name $target
    fi
  fi
done

echo "👌 Success!"
