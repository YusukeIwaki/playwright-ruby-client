export ASDF_DIR="$HOME/.asdf"
. "$HOME/.asdf/asdf.sh"
bundle
npm install playwright@latest
npx playwright install --with-deps
exec "$@"
