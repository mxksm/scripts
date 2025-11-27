#/bin/bash

echo ""
echo ""

# Get timestamp prefix
timestamp() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

cd ~/Documents/university/tda/notes/

git add .
if [ $? -ne 0 ]; then
  echo "$(timestamp) Failed to git add" >&2
  exit 1
else
  echo "$(timestamp) Successful git add"
fi

git commit -m "automatic commit"
if [ $? -ne 0 ]; then
  echo "$(timestamp) Failed to git commit" >&2
  exit 1
else
  echo "$(timestamp) Successful git commit"
fi

git push
if [ $? -ne 0 ]; then
  echo "$(timestamp) Failed to git push" >&2
  exit 1
else
  echo "$(timestamp) Successful git push"
fi
